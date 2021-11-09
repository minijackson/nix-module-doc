{ outputAttrPath, optionsAttrPath, optionsInternal ? true, }:

{ lib, options, pkgs, ... }:

with lib;

let
  visibleOptionDocs = filter (opt: opt.visible && !opt.internal) (optionAttrSetToDocList options);

  isLiteral = value:
    value ? _type &&
    (value._type == "literalExpression" || value._type == "literalExample");

  toValue = value:
    if isLiteral value then value.text
    else generators.toPretty { } value;

  toMarkdown = option:
    ''
      ## `${option.name}`

      ${option.description}

      ${optionalString (option ? default) ''
        **Default value**:

        ```nix
        ${toValue option.default}
        ```
      ''}

      **Type**: ${option.type}${optionalString option.readOnly " (read only)"}

      ${optionalString (option ? example) ''
        **Example**:

        ```nix
        ${toValue option.example}
        ```
      ''}

      Declared in:

      ${concatStringsSep "\n" (map (decl: "- ${decl}") option.declarations)}

    '';

  # TODO: rewrite "Declared in" so that it points to GitHub repository

  options-md = concatStringsSep "\n" (map toMarkdown visibleOptionDocs);
in
{
  config = setAttrByPath outputAttrPath {
    doc-options-md = pkgs.writeText "options.md" options-md;
  };
}
