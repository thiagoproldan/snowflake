{
  inputs.snowflake.url = "github:thiagoproldan/snowflake";
  outputs = inputs:
    inputs.snowflake.lib.mkFlake { inherit inputs; } ({ withSystem, ... }: {
      systems = [ ];
      perSystem = { system, ... }:
        builtins.trace "Evaluating perSystem for ${system}" { };
      flake.result =
        let
          a = withSystem "foo" ({ config, ... }: null);
          b = withSystem "foo" ({ config, ... }: "ok");
        in
        builtins.seq a b;
    });
}
