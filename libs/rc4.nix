{
  lib ? (import <nixpkgs> { }).lib,
  ...
}:
let
  N = 255;
  mod = base: mod: base - (mod * (base / mod));
  modN = lib.bitAnd N;
  rangeN = lib.range 0 N;

  stringToBytes =
    str:
    lib.pipe str [
      lib.stringToCharacters
      (map lib.strings.charToInt)
    ];
  ensureBytes =
    bytes:
    if lib.isString bytes then
      stringToBytes bytes
    else if lib.isList bytes then
      bytes
    else
      throw "Unexpected bytes type";

  swap =
    box: ai: bi:
    box
    // lib.optionalAttrs (ai != bi) {
      ${toString ai} = box.${toString bi};
      ${toString bi} = box.${toString ai};
    };

  keySchedule =
    key:
    let
      keyBytes = ensureBytes key;
      keyLength = lib.length keyBytes;
      keyAt = i: lib.elemAt keyBytes (mod i keyLength);
      initial = lib.genAttrs' rangeN (i: lib.nameValuePair (toString i) i);
    in
    lib.foldl'
      (
        { box, j }:
        i:
        let
          j' = modN (j + box.${toString i} + keyAt i);
        in
        {
          box = swap box i j';
          j = j';
        }
      )
      {
        box = initial;
        j = 0;
      }
      rangeN;

  keyStream =
    box: plaintext:
    lib.foldl'
      (
        {
          box,
          ct,
          i,
          j,
        }:
        ptByte:
        let
          i' = modN (i + 1);
          j' = modN (j + box.${toString i'});
          box' = swap box i' j';
          rnd = box'.${toString (modN (box'.${toString i'} + box'.${toString j'}))};
        in
        {
          box = box';
          ct = ct ++ [ (lib.bitXor ptByte rnd) ];
          i = i';
          j = j';
        }
      )
      {
        inherit box;
        ct = [ ];
        i = 0;
        j = 0;
      }
      (ensureBytes plaintext);
in
rec {
  rc4encrypt =
    key: plaintext:
    let
      inherit (keySchedule key) box;
    in
    (keyStream box plaintext).ct;

  rc4encryptTest = lib.runTests (
    let
      fromTOMLValue = value: (fromTOML "result = ${value}").result;
    in
    {
      testEncryption = {
        expr = rc4encrypt "key" "plaintext";
        expected = fromTOMLValue "[0x7b, 0x00, 0x55, 0x84, 0x4a, 0xfb, 0x1e, 0x32, 0x3c]";
      };
      testDecryption = {
        expr = rc4encrypt "key" (fromTOMLValue "[0x7b, 0x00, 0x55, 0x84, 0x4a, 0xfb, 0x1e, 0x32, 0x3c]");
        expected = ensureBytes "plaintext";
      };
    }
  );
}
