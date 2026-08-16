
# Snowflake

_Module system for writing Nix flakes — personal infrastructure edition._

`snowflake` provides the options that represent standard flake attributes
and establishes a way of working with `system`.
Opinionated features are provided by modules that you can import.

---

> **Provenance and scope.** snowflake started as a copy of
> [flake-parts](https://github.com/hercules-ci/flake-parts) by Hercules CI, used
> under the MIT License — see [LICENSE](./LICENSE), whose copyright notice is
> retained because most of this code is still theirs.
>
> It is **not** a fork in the collaborative sense and **not** a replacement for
> flake-parts. Upstream is not tracked, and nothing here is aimed at general use.
> This is a personal framework for one person's infrastructure: flake-parts was
> simply the best available starting point, and it is being adapted from here on.
>
> Practical consequence: the API is renamed, so third-party flake-parts modules
> need a compat shim (see `dev/flake-module.nix` for the pattern). Upstream docs at
> [flake.parts](https://flake.parts) still describe the design accurately, but use
> the original `flake-parts` names.

---

# Why Modules?

Flakes are configuration. The module system lets you refactor configuration
into modules that can be shared.

It reduces the proliferation of custom Nix glue code, similar to what the
module system has done for NixOS configurations.

Unlike NixOS, but following Flakes' spirit, `snowflake` is not a
monorepo with the implied goal of absorbing all of open source, but rather
a single module that other repositories can build upon, while ensuring a
baseline level of compatibility: the core attributes that constitute a flake.

# Features

 - Split your `flake.nix` into focused units, each in their own file.

 - Take care of [system](https://flake.parts/system.html).

 - Allow users of your library flake to easily integrate your generated flake outputs
   into their flake.

 - Reuse project logic written by others

<!-- end_of_intro -->
<!-- ^^^^^^^^^^^^ used by https://github.com/hercules-ci/flake.parts-website -->

# Getting Started

If your project does not have a flake yet:

```console
nix flake init -t github:thiagoproldan/snowflake
```

# Migrate

Otherwise, add the input,

```nix
    snowflake.url = "github:thiagoproldan/snowflake";
```

then slide `mkFlake` between your outputs function head and body,

```nix
  outputs = inputs@{ snowflake, ... }:
    snowflake.lib.mkFlake { inherit inputs; } {
      flake = {
        # Put your original flake attributes here.
      };
      systems = [
        # systems for which you want to build the `perSystem` attributes
        "x86_64-linux"
        # ...
      ];
    };
```

Now you can add the remaining module attributes like in the [the template](./template/default/flake.nix).

# Templates

See [the template](./template/default/flake.nix).

# Examples

See the [examples/](./examples) directory.

# Projects using snowflake

- [nixd](https://github.com/nix-community/nixd/blob/main/flake.nix) (c++)
- [hyperswitch](https://github.com/juspay/hyperswitch/blob/main/flake.nix) (rust)
- [argo-workflows](https://github.com/argoproj/argo-workflows/blob/master/dev/nix/flake.nix) (go)
- [nlp-service](https://github.com/recap-utr/nlp-service/blob/main/flake.nix) (python)
- [emanote](https://github.com/srid/emanote/blob/master/flake.nix) (haskell)

# Options Reference

See [flake.parts options](https://flake.parts/options/flake-parts.html)
