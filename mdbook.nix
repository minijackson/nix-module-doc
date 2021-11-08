{ outputAttrPath, optionsAttrPath, optionsInternal ? true, }:

{ config, lib, pkgs, ... }:

with lib;

let
  cfg = getAttrFromPath (optionsAttrPath  ++ [ "mdbook" ]) config;
in
{
  options = setAttrByPath optionsAttrPath {
    mdbook = {
      src = mkOption {
        type = with types; either path package;
        description = ''
          Root directory of mdbook sources to compile.
        '';
        internal = optionsInternal;
      };
    };
  };

  config = setAttrByPath outputAttrPath {
    # TODO: make pandoc pre-processor
    mdbook = pkgs.runCommand "mdbook"
      {
        src = cfg.src;
        nativeBuildInputs = with pkgs; [ mdbook ];
      } ''
      unpackFile "$src"
      chmod -R u+w .
      cd */

      mkdir theme
      cp ${pkgs.documentation-highlighter}/highlight.pack.js theme/highlight.js
      cp ${pkgs.documentation-highlighter}/mono-blue.css theme/highlight.css

      cp "${getAttrFromPath (outputAttrPath ++ ["doc-options-md"]) config}" src/options.md

      mdbook build

      cp -r book "$out"
    '';
  };
}
