
# Running the tests

`nix flake check`, from the top of the repository, runs them all:

- `nix-unit.nix`, the nix-unit tests: the modules, the lib, and every
  template evaluated against this snowflake.
- `perSystem-memoize.nix`: `withSystem` evaluates `perSystem` once for a
  system, however many times it is called.

nix-unit fetches the dev partition's inputs (`../flake.nix`) over the network
inside its sandbox.
