{ lib, ... }:
let
  inherit (lib)
    mkOption
    types
    ;
in
{
  imports = [ ./attrs.nix ];
  options = {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to include the attribute in the output.";
    };
  };
  config = {
    _module.args.docsVisible = "shallow";
  };
}
