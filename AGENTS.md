# admiral

## Repository structure

```text
src/*.mbt                         Public Admiral implementation and tests
src/usage_examples.mbt.md         Checked examples linked from the root README
src/examples/                     End-user CLI examples
src/interactive/                  Portable field editor contract
examples/tui/                     Separate module for the terminal picker example
src/util/target-file-discovery/   Filesystem target-file helper package and README
README.mbt.md                     Physical canonical module overview
README.md                         Relative symbolic link to README.mbt.md
moon.mod                          Mooncakes module metadata and target policy
flake.nix                         Reproducible MoonBit and Node.js development shell
.github/workflows/                CI and Mooncakes publication workflows
```

## Development commands

### Execution rules

- Run commands from this repository root.
- Enter the pinned toolchain with `nix develop` before running MoonBit commands.
- Read the `mbt-coding` skill before changing MoonBit production code and `docs-moonbit` when language-reference details are needed.
- Keep the physical root `README.mbt.md` and the relative `README.md -> README.mbt.md` symbolic link; do not create a second README or a `CLAUDE.md` file.
- Keep public API behavior documented beside its declaration with `///` comments; the Mooncakes page is the canonical generated API index.

### Standard tasks

- `nix develop --command moon info` — Regenerate package interface information after public API changes.
- `nix develop --command moon check src/usage_examples.mbt.md` — Type-check the executable examples linked from the root README in their owning package.
- `nix develop --command moon check src/util/target-file-discovery/README.mbt.md` — Type-check the target discovery README examples.
- `nix develop --command moon check` — Type-check all packages and supported targets.
- `nix develop --command moon test src/usage_examples.mbt.md` — Run the executable examples linked from the root README in their owning package.
- `nix develop --command moon test src/util/target-file-discovery/README.mbt.md` — Run the checked target discovery README examples in its package.
- `nix develop --command moon test` — Run package, blackbox, whitebox, and documentation tests.
- `nix develop --command moon test --target wasm` — Run the CLI and field editor tests on linear Wasm.
- `nix develop --command moon -C examples check --target native ./tui/src/main` — Check the optional terminal picker and its adapter.
- `nix develop --command moon package --list` — Confirm the packages included in publication.
- `nix develop --command nix flake check --all-systems --no-build` — Validate the flake without building its outputs.

## Architecture

### Declarative CLI model

- `OptionDef` and `PositionDef` keep a typed definition shared between parser declarations and `Context` getters.
- `CommandDef` describes options, positions, nested commands, examples, and async execution.
- `CliApp` builds on `moonbitlang/core/argparse`, resolves `argv > env > config > default`, and dispatches callbacks.

### Runtime surfaces

- Option and positional definitions can each register an editor. Editors receive resolved input and return a typed value for that field only.
- TTY detection and `totto2727/tui` belong to the separate example module, never to the core or portable editor package.
- Schema rendering and `ToJson` expose the complete CLI definition for tooling, while completion methods emit Bash, Zsh, and Fish scripts.
- `util/target-file-discovery` is a separate filesystem helper package with native, JavaScript, and Wasm support through `mizchi/x`.

### Target policy

- The CLI, editor contract, and target discovery helper support `js+native+wasm`. JavaScript remains preferred.
- The optional TUI example supports `js+native`.

### Package ownership

- `src` owns the published `totto2727/admiral` CLI package; the root README is its sole user guide.
- `src/util/target-file-discovery` owns the filesystem discovery helpers and their package-specific guide.
- The repository root owns module metadata, the module overview, examples, and release workflows; it does not duplicate package API guides.

## Development tools

- **MoonBit**: Checks, tests, documentation examples, and package metadata.
- **Nix flakes**: Pin the MoonBit and Node.js development environment.
- **Mooncakes**: Publishes `totto2727/admiral` and hosts its generated API reference.
- **GitHub Actions**: Runs strict checks and publishes only from protected `main`.

## Package-specific rules

- Place trait extensions with their type or trait implementation. Do not collect unrelated declarations in `extensions.mbt`.
- Keep CLI schema wire types in `src/schema.mbt` and generate their JSON codecs with `moonx totto2727/serde-gen@0.1.0 src/schema.mbt --output src/schema.generated.mbt`, then run `moon fmt src`. Commit the generated source so dependency builds do not need the generator.
- Use the registry-first API policy: link README users to [Mooncakes Admiral API docs](https://mooncakes.io/docs/totto2727/admiral), and keep behavior, constraints, and representative examples in `///` docs or `src/examples/`.
- Preserve the physical root `README.mbt.md` module overview and the relative root `README.md -> README.mbt.md` alias.
- Keep the `totto2727/admiral` consumer guide at the root and the separate target-file-discovery package guide in `src/util/target-file-discovery/README.mbt.md`.
- Keep publication metadata in `moon.mod` synchronized with the latest release; run the full standard task set before a release.
- Do not broaden this standalone package with unrelated monorepo or upstream-fork changes.

_This AGENTS.md was generated from the [share-artifact skill](https://raw.githubusercontent.com/totto2727-org/agent/refs/heads/main/plugins/totto2727-coding/skills/share-artifact/SKILL.md) and [AGENTS template](https://raw.githubusercontent.com/totto2727-org/agent/refs/heads/main/plugins/totto2727-coding/skills/share-artifact/agents/template.md)._
