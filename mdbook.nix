{ outputAttrPath, optionsAttrPath, optionsInternal ? true, }:

{ config, lib, pkgs, ... }:

with lib;

let
  cfg = getAttrFromPath (optionsAttrPath ++ [ "mdbook" ]) config;
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

      pages = mkOption {
        type = with types; attrsOf (submodule ({ name, config, ... }: {
          options = {
            target = mkOption {
              type = types.str;
              default = name;
              description = ''
                Where to install the page, relative to the `src/` directory.
              '';
              internal = optionsInternal;
            };

            text = mkOption {
              type = types.lines;
              description = ''
                Content of the page.
              '';
              internal = optionsInternal;
            };

            source = mkOption {
              type = types.path;
              description = ''
                Path of the source file for this page.

                If both `text` and `source` are defined, `source` takes
                precedence.
              '';
              internal = optionsInternal;
            };
          };

          config.source = mkDefault (pkgs.writeText name config.text);
        }));
        default = { };
        example = {
          "my-page.md".text = ''
            # Title

            hello, world!
          '';
        };
        description = ''
          Pages to add to the source directory before building.
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

  config = mkMerge [
    (setAttrByPath (optionsAttrPath ++ [ "mdbook" ]) {
      pages."options.md".text = ''
        # Available options

        You can use the following options:


        ${readFile (getAttrFromPath (outputAttrPath ++ [ "doc-options-md" ]) config)}
      '';
    })

    (setAttrByPath outputAttrPath {
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

        ${concatMapStrings (page: ''
          cp "${page.source}" "src/${page.target}"
        '') (attrValues cfg.pages)}

        ${cfg.preBuild}

        mdbook build

        ${cfg.postBuild}

        cp -r book "$out"
      '';
    })
  ];
}
