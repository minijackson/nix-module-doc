{
  description = "Generate documentation for your own projects using the NixOS module system";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-21.05";

  outputs = {
    self,
    nixpkgs,
  }: let
    pkgs = nixpkgs.legacyPackages.x86_64-linux;
  in {
    lib.modules = {
      doc-options-md = import ./doc-options-md.nix;
      mdbook = import ./mdbook.nix;
      manpage = import ./manpage.nix;
    };

    checks.x86_64-linux = let
      evalModules = modules:
        pkgs.lib.evalModules {
          modules =
            [
              {config._module.args = {inherit pkgs;};}
            ]
            ++ modules;
        };
      simpleModule = with pkgs.lib; {
        options.my.simple.module.outputs = mkOption {
          type = with types; attrsOf package;
          default = {};
          description = ''
            Output products of my simple module system.
          '';
        };
      };
      params = {
        outputAttrPath = ["my" "simple" "module" "outputs"];
        optionsAttrPath = ["my" "simple" "module" "doc"];
        optionsInternal = false;
      };

      simple-manpage = {
        name = "my simple module system";
        shortDescription = "A sample module system";
      };

      advanced-manpage = {
        name = "my simple module system";
        section = 5;
        shortDescription = "A sample module system";
        description = ''
          This is a very advanced module system, for advanced people.
        '';

        textBefore = ''
          # A SECTION BEFORE

          This is a section before the options.
        '';

        textAfter = ''
          # A SECTION AFTER

          This is a section after the options.
        '';
      };
    in {
      simple-doc-options-md =
        (evalModules [
          simpleModule
          (self.lib.modules.doc-options-md params)
        ])
        .config
        .my
        .simple
        .module
        .outputs
        .doc-options-md;

      simple-manpage =
        (evalModules [
          simpleModule
          (self.lib.modules.doc-options-md params)
          (self.lib.modules.manpage params)
          {
            my.simple.module.doc.manpage = simple-manpage;
          }
        ])
        .config
        .my
        .simple
        .module
        .outputs
        .manpage;

      advanced-manpage =
        (evalModules [
          simpleModule
          (self.lib.modules.doc-options-md params)
          (self.lib.modules.manpage params)
          {
            my.simple.module.doc.manpage = advanced-manpage;
          }
        ])
        .config
        .my
        .simple
        .module
        .outputs
        .manpage;

      simple-mdbook =
        (evalModules [
          simpleModule
          (self.lib.modules.doc-options-md params)
          (self.lib.modules.mdbook params)
          {
            my.simple.module.doc.mdbook.src = ./checks/simple-mdbook;
          }
        ])
        .config
        .my
        .simple
        .module
        .outputs
        .mdbook;
    };

    devShell.x86_64-linux = pkgs.mkShell {
      nativeBuildInputs = with pkgs; [mdbook pandoc];
    };
  };
}
