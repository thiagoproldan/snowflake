{ config, lib, options, docsVisible, ... }:
let
  inherit (lib)
    addErrorContext
    concatMapAttrs
    evalModules
    mkOption
    types
    ;

  unNull = v:
    if v == null then
      { }
    else
      v;

  touchupAttrs =
    v:
    concatMapAttrs
      (name: value:
      let
        eval = evalModules {
          prefix = lib.lists.init options.attr.loc; # arbitrary pick
          specialArgs = {
            attrName = name;
          };
          modules = [
            (config.attr.${name} or ./attr.nix)
            (unNull config.any)
          ];
        };
      in
      if addErrorContext "while figuring out whether to enable '${name}'" eval.config.enable then
      # Apply the touchup configuration to the value.
        {
          "${name}" =
            addErrorContext "while touching up attribute '${name}'" (
              (addErrorContext "while evaluating the touchup configuration for '${name}'" eval.config.touchupApply)
                (addErrorContext "while evaluating the original value of '${name}'" value)
            );
        }
      else
        { }
      )
      v;
in
{
  options = {
    attr = mkOption {
      type = types.lazyAttrsOf (types.deferredModuleWith {
        staticModules = [ ./attr.nix ];
      });
      default = { };
      visible = docsVisible;
      description =
        if docsVisible == "shallow" then ''
          Touchup configuration for the next level of nesting.
          Same structure as [`attr`](#opt-touchup.attr); see its description.
        ''
        else ''
          Per-attribute touchup configuration. Each value is a module that controls
          whether and how the corresponding attribute appears in the output.

          Each module contains the full touchup option set (`enable`, `attr`, `any`, `finish`),
          so nested attributes can be configured to arbitrary depth.

          This module is called with module argument `attrName`, which is the name of the attribute being touched up.
        '';
    };
    any = mkOption {
      type = types.nullOr (types.deferredModuleWith {
        staticModules = [ ./attr.nix ];
      });
      default = null;
      visible = docsVisible;
      description =
        if docsVisible == "shallow" then ''
          Default configuration for all attributes at the next level.
          Same structure as [`any`](#opt-touchup.any); see its description.
        ''
        else ''
          A module whose options are merged into every attribute's touchup configuration.
          For example, `any.enable = false` disables all attributes by default.
          Override specific ones via `attr.<name>`.

          Only applies to immediate children — does not recurse into nested attributes automatically.

          This module is called with module argument `attrName`, which is the name of the attribute being touched up.
        '';
    };

    type = mkOption {
      type = types.raw;
      default = types.raw;
      defaultText = "raw";
      description = ''
        The type used for merging multiple definitions of ${options.finish}.
        Override this if multiple modules need to compose their ${options.finish} functions.
      '';
    };
    finish = mkOption {
      type = types.functionTo config.type;
      default = v: v;
      defaultText = lib.literalMD "`v: v`, the identity function";
      description = ''
        A function applied after filtering and transforming (e.g. by ${options.attr} and ${options.any} at this level).
        It receives the resulting attribute set and must return the value to use in its place.
      '';
    };

    touchupApply = mkOption {
      internal = true;
      description = ''
        A generated function that applies the touchups that are configured with the other options in this module.
      '';
      type = types.functionTo types.raw;
      readOnly = true;
    };
  };
  config = {
    _module.args.docsVisible = lib.mkDefault true;
    touchupApply = v:
      config.finish
        (if config.attr != { } || config.any != null
        then
          addErrorContext "while applying touchups from ${options.attr}: ${lib.options.showDefs options.attr.definitionsWithLocations}\n  and from ${options.any}: ${lib.options.showDefs options.any.definitionsWithLocations}"
            (touchupAttrs v)
        else v);
  };
}

