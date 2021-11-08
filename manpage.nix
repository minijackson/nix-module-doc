{ outputAttrPath, optionsAttrPath, optionsInternal ? true, }:

{ config, lib, pkgs, ... }:

with lib;

let
  cfg = getAttrFromPath (optionsAttrPath  ++ [ "manpage" ]) config;
in
{
  options = setAttrByPath optionsAttrPath {
    manpage = {
      name = mkOption {
        type = types.str;
        description = ''
          Name of the generated manpage.
        '';
        internal = optionsInternal;
      };

      shortDescription = mkOption {
        type = types.str;
        description = ''
          A short description of the generated manpage.
        '';
        internal = optionsInternal;
      };

      description = mkOption {
        type = with types; nullOr lines;
        description = ''
          A long description of the generated manpage.
        '';
        default = null;
        internal = optionsInternal;
      };

      section = mkOption {
        type = types.int;
        default = 5;
        description = ''
          The section number for the generated manpage.

          The table below shows the section numbers of the manual followed by the types of pages they contain.

          1. Executable programs or shell commands
          2. System calls (functions provided by the kernel)
          3. Library calls (functions within program libraries)
          4. Special files (usually found in /dev)
          5. File formats and conventions, e.g. /etc/passwd
          6. Games
          7. Miscellaneous (including macro packages and conventions), e.g. man(7), groff(7)
          8. System administration commands (usually only for root)
          9. Kernel routines [Non standard]
        '';
        internal = optionsInternal;
      };

      file = mkOption {
        type = types.str;
        description = ''
          The file containing the generated manpage.
        '';
        default = "${strings.sanitizeDerivationName cfg.name}.${toString cfg.section}";
        defaultText = "\${lib.strings.sanitizeDerivationName cfg.name}.\${toString cfg.section}";
        internal = optionsInternal;
      };

      title = mkOption {
        type = types.str;
        default = "${toUpper (strings.sanitizeDerivationName cfg.name)}(${toString cfg.section})";
        defaultText = "\${toUpper cfg.name}(\${toString cfg.section})";
        description = ''
          Title of the generated manpage.
        '';
        internal = optionsInternal;
      };

      textBefore = mkOption {
        type = types.lines;
        description = ''
          Some text to insert before the list of options.
        '';
        default = "";
        internal = optionsInternal;
      };

      textAfter = mkOption {
        type = types.lines;
        description = ''
          Some text to insert after the list of options.
        '';
        default = "";
        internal = optionsInternal;
      };

    };
  };

  config = setAttrByPath outputAttrPath {
    manpage = pkgs.runCommand cfg.file
      {
        src = pkgs.writeText "${cfg.file}.md" ''
          % ${cfg.title}

          # NAME

          ${cfg.name} - ${cfg.shortDescription}


          ${optionalString (cfg.description != null) ''
            # DESCRIPTION

            ${cfg.description}
          ''}


          ${cfg.textBefore}


          # OPTIONS

          You can use the following options:

          ${readFile (getAttrFromPath (outputAttrPath ++ ["doc-options-md"]) config)}


          ${cfg.textAfter}
        '';

        nativeBuildInputs = [ pkgs.pandoc ];
      } ''
      pandoc "$src" --from=markdown --to=man --standalone --output="$out"
    '';
  };
}
