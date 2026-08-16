{ config, lib, ... }:
let
  inherit (lib)
    mkOption
    types
    ;
in
{
  options = {
    touchup = mkOption {
      description = ''
        Controls which attributes appear in [`processedFlake`](flake-parts.md#opt-processedFlake) and how they are transformed.

        The touchup configuration forms a tree that mirrors the flake output structure.
        At each level, [`attr`](#opt-touchup.attr) targets specific attributes by name,
        and [`any`](#opt-touchup.any) applies to all attributes at that level.

        **Examples**:

        Only output explicitly listed flake output attributes:

        ```nix
        touchup = {
          any = {
            enable = lib.mkDefault false;
          };
          attr.packages.enable = true;
          attr.checks.enable = true;
        }
        ```

        Hide a package from users, but not from your own modules:

        ```nix
        touchup = {
          attr.packages.any.attr.hello.enable = false;
        };
        ```

        Hide a package on a set of systems:

        ```nix
        touchup = {
          attr.packages.any = { attrName, ... }: { attr.hello.enable = ! lib.strings.hasSuffix "-darwin" attrName; }
        };
        ```

      '';
      type = types.submoduleWith {
        modules = [ ./touchup/attrs.nix ];
      };
    };
  };
  config = {
    processedFlake = config.touchup.touchupApply config.flake;
  };
}
