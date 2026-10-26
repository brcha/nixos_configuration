# A group switch whose children default to it: my.<groupName>.enable plus one
# boolean per child
lib: config: groupName: description: children:
{
  enable = lib.mkEnableOption description;
} // lib.genAttrs children (name: lib.mkOption {
  type = lib.types.bool;
  default = config.my.${groupName}.enable;
  defaultText = lib.literalExpression "config.my.${groupName}.enable";
  description = "Whether to enable ${groupName} ${name} (defaults to my.${groupName}.enable).";
})
