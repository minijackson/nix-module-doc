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

      preBuild = mkOption {
        type = types.lines;
        description = ''
          Extra commands executed before running `mdbook build`.
        '';
        default = "";
        internal = optionsInternal;
      };

      postBuild = mkOption {
        type = types.lines;
        description = ''
          Extra commands executed after running `mdbook build`.
        '';
        default = "";
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

      ${cfg.preBuild}

      mdbook build

      ${cfg.postBuild}

      cp -r book "$out"
    '';
  };
}
