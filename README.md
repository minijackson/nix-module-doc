# nix-module-doc

Generate documentation for your NixOS-like modules.

`nix-module-doc` is capable of generating a markdown file, a manpage, and an
mkbook.

## Usage

In your `flake.nix`

```nix
{
  inputs.nix-module-doc.url = "github:minijackson/nix-module-doc";

  outputs = inputs: {
    nixosModule.yourModule = let
      docParams = {
        # Where to store the outputs
        outputAttrPath = ["your" "module" "outputs"];
        # Where to store the documentation options
        optionsAttrPath = ["your" "module" "doc"];
      };
    in {
      imports = [
        (inputs.nix-module-doc.lib.modules.doc-options-md docParams)
        (inputs.nix-module-doc.lib.modules.manpage docParams)
        (inputs.nix-module-doc.lib.modules.mdbook docParams)
      ];
    }
  };
}
```
