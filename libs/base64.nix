{ lib, ... }:
let
  bitShiftMap =
    let
      generator =
        list: end:
        if end > (lib.lists.length list) then
          (generator (list ++ [ ((lib.lists.last list) * 2) ]) end)
        else
          list;
    in
    generator [ 0 2 ] 32;
  charsetToMap =
    charset:
    lib.pipe charset [
      lib.stringToCharacters
      (lib.imap0 (i: c: lib.nameValuePair c i))
      lib.listToAttrs
    ];

  mod = base: mod: base - (mod * (base / mod));
  mod3 = base: mod base 3;
  mod4 = lib.bitAnd 3;

  bitShift =
    base: bits:
    if bits > 0 then
      base * (lib.elemAt bitShiftMap bits)
    else if bits < 0 then
      base / (lib.elemAt bitShiftMap (-bits))
    else
      base;

  padRight =
    len: pad: str:
    let
      diff = len - (lib.stringLength str);
    in
    if diff > 0 then (lib.concatStrings (lib.genList (_: pad) diff)) + str else str;

  base64DecodeToBytesWithCharset =
    charset:
    let
      charsetMap = charsetToMap charset;
    in
    input:
    let
      decode =
        {
          content,
          pos ? 0,
          data ? [ ],
          next ? 0,
          value ? lib.elemAt content pos,
        }:
        if pos < (lib.lists.length content) then
          if (mod4 pos) == 0 then
            decode {
              inherit content data;
              pos = pos + 1;
              next = bitShift value 2;
            }
          else if (mod4 pos) == 1 then
            decode {
              inherit content;
              pos = pos + 1;
              data = data ++ [ (lib.bitOr next (bitShift value (-4))) ];
              next = lib.bitAnd (bitShift value 4) 255;
            }
          else if (mod4 pos) == 2 then
            decode {
              inherit content;
              pos = pos + 1;
              data = data ++ [ (lib.bitOr next (bitShift value (-2))) ];
              next = lib.bitAnd (bitShift value 6) 255;
            }
          else if (mod4 pos) == 3 then
            decode {
              inherit content;
              pos = pos + 1;
              data = data ++ [ (lib.bitOr next value) ];
              next = 0;
            }
          else
            throw "Unreachable"
        else
          data;
    in
    lib.pipe input [
      lib.stringToCharacters
      (lib.foldl' (
        acc: char: acc ++ lib.optional (builtins.hasAttr char charsetMap) (builtins.getAttr char charsetMap)
      ) [ ])
      (content: decode { inherit content; })
    ];

  asciiBytesToString =
    bytes:
    lib.pipe bytes [
      (data: map (val: "\\u${padRight 4 "0" (lib.toHexString val)}") data)
      lib.strings.concatStrings
      (total: builtins.fromJSON "\"${total}\"")
    ];

  base64DecodeWithCharset =
    charset: input: asciiBytesToString (base64DecodeToBytesWithCharset charset input);

  base64Decode = base64DecodeWithCharset "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
  base64DecodeToBytes = base64DecodeToBytesWithCharset "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

  base64EncodeWithCharset =
    charset:
    let
      charsetList = lib.stringToCharacters charset;
    in
    input:
    lib.pipe input [
      lib.stringToCharacters
      (lib.imap0 (
        i: c: {
          inherit i;
          c = lib.strings.charToInt c;
        }
      ))
      (lib.foldl' (
        acc:
        { i, c }:
        if (mod3 i) == 0 then
          acc ++ [ (bitShift c 16) ]
        else if (mod3 i) == 1 then
          (lib.dropEnd 1 acc) ++ [ (lib.bitOr (lib.last acc) (bitShift c 8)) ]
        else if (mod3 i) == 2 then
          (lib.dropEnd 1 acc) ++ [ (lib.bitOr (lib.last acc) c) ]
        else
          throw "Unreachable"
      ) [ ])
      (groups: map (lib.toBaseDigits 64) groups)
      (
        groups:
        map (
          chars:
          lib.pipe chars [
            (map (lib.elemAt charsetList))
            lib.strings.concatStrings
            (padRight 4 (lib.elemAt charsetList 0))
          ]
        ) groups
      )
      (
        groups:
        let
          length = lib.lists.length groups;
          remain = mod3 (lib.stringLength input);
        in
        lib.concatImapStrings (
          i: group:
          if i == length then
            if remain == 0 then
              group
            else if remain == 1 then
              "${lib.substring 0 2 group}=="
            else if remain == 2 then
              "${lib.substring 0 3 group}="
            else
              throw "Unreachable"
          else
            group
        ) groups
      )
    ];

  base64Encode = base64EncodeWithCharset "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

  # RFC 4648 §10 test vectors
  base64EncodeTest = lib.runTests {
    testEncodeEmpty = {
      expr = base64Encode "";
      expected = "";
    };
    testEncodeF = {
      expr = base64Encode "f";
      expected = "Zg==";
    };
    testEncodeFo = {
      expr = base64Encode "fo";
      expected = "Zm8=";
    };
    testEncodeFoo = {
      expr = base64Encode "foo";
      expected = "Zm9v";
    };
    testEncodeFoob = {
      expr = base64Encode "foob";
      expected = "Zm9vYg==";
    };
    testEncodeFooba = {
      expr = base64Encode "fooba";
      expected = "Zm9vYmE=";
    };
    testEncodeFoobar = {
      expr = base64Encode "foobar";
      expected = "Zm9vYmFy";
    };
  };

  base64DecodeTest = lib.runTests {
    testDecodeEmpty = {
      expr = base64Decode "";
      expected = "";
    };
    testDecodeF = {
      expr = base64Decode "Zg==";
      expected = "f";
    };
    testDecodeFo = {
      expr = base64Decode "Zm8=";
      expected = "fo";
    };
    testDecodeFoo = {
      expr = base64Decode "Zm9v";
      expected = "foo";
    };
    testDecodeFoob = {
      expr = base64Decode "Zm9vYg==";
      expected = "foob";
    };
    testDecodeFooba = {
      expr = base64Decode "Zm9vYmE=";
      expected = "fooba";
    };
    testDecodeFoobar = {
      expr = base64Decode "Zm9vYmFy";
      expected = "foobar";
    };
  };

  base64DecodeToBytesTest = lib.runTests {
    testDecodeBytesEmpty = {
      expr = base64DecodeToBytes "";
      expected = builtins.fromJSON "[]";
    };
    testDecodeBytesF = {
      expr = base64DecodeToBytes "Zg==";
      expected = builtins.fromJSON "[102]";
    };
    testDecodeBytesFoo = {
      expr = base64DecodeToBytes "Zm9v";
      expected = builtins.fromJSON "[102,111,111]";
    };
    testDecodeBytesFoobar = {
      expr = base64DecodeToBytes "Zm9vYmFy";
      expected = builtins.fromJSON "[102,111,111,98,97,114]";
    };
  };

  base64RoundtripTest = lib.runTests {
    testRoundtripShort = {
      expr = base64Decode (base64Encode "Hello, World!");
      expected = "Hello, World!";
    };
    testRoundtripLong = {
      expr = base64Decode (base64Encode "The quick brown fox jumps over the lazy dog");
      expected = "The quick brown fox jumps over the lazy dog";
    };
  };

  allBase64Tests =
    base64EncodeTest ++ base64DecodeTest ++ base64DecodeToBytesTest ++ base64RoundtripTest;
in
builtins.seq
  (lib.assertMsg (allBase64Tests == [ ]) "base64 tests failed: ${builtins.toJSON allBase64Tests}")
  {
    inherit
      base64Decode
      base64DecodeWithCharset
      base64DecodeToBytes
      base64DecodeToBytesWithCharset
      base64Encode
      base64EncodeWithCharset

      asciiBytesToString
      ;
  }
