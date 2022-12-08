{
  outputAttrPath,
  optionsAttrPath,
  optionsInternal ? true,
}: {
  lib,
  options,
  pkgs,
  ...
}:
with lib; let
  visibleOptionDocs = filter (opt: opt.visible && !opt.internal) (optionAttrSetToDocList options);

  isLiteral = value:
    value
    ? _type
    && (value._type == "literalExpression"
      || value._type == "literalExample"
      || value._type == "literalMD");

  toValue = value:
    if isLiteral value
    then value.text
    else generators.toPretty {} value;

  toText = value:
    if value ? _type
    then value.text
    else value;

  toMarkdown = option: ''
    ## `${option.name}`

    ${toText option.description}

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
in {
  config = setAttrByPath outputAttrPath {
    doc-options-md = pkgs.writeText "options.md" options-md;
  };
}
