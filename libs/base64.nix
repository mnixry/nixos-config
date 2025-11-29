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
in
rec {
  mod2 = lib.bitAnd 1;
  mod4 = lib.bitAnd 3;
  mod8 = lib.bitAnd 7;

  bitShift =
    base: bits:
    if bits > 0 then
      base * (lib.elemAt bitShiftMap bits)
    else if bits < 0 then
      base / (lib.elemAt bitShiftMap (-bits))
    else
      base;

  padRight =
    len: str: pad:
    let
      diff = len - (lib.stringLength str);
    in
    if diff > 0 then (lib.concatStrings (lib.genList (_: pad) diff)) + str else str;

  base64DecodeWithCharset =
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
      (data: map (val: "\\u${padRight 4 (lib.toHexString val) "0"}") data)
      lib.strings.concatStrings
      (total: builtins.fromJSON "\"${total}\"")
    ];

  base64Decode = base64DecodeWithCharset "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
}
