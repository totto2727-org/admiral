# admiral

## Repository structure

```text
src/*.mbt                         Public Admiral implementation and tests
src/README.mbt.md                 Detailed canonical README for the Admiral package
src/examples/                     End-user CLI and interactive examples
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
- Keep `README.mbt.md -> src/README.mbt.md` and `README.md -> README.mbt.md` as relative symbolic links; do not create a second README or a `CLAUDE.md` file.
- Keep public API behavior documented beside its declaration with `///` comments; the Mooncakes page is the canonical generated API index.

### Standard tasks

- `nix develop --command moon info` — Regenerate package interface information after public API changes.
- `nix develop --command moon check README.mbt.md` — Type-check the physical module overview.
- `nix develop --command moon check src/README.mbt.md` — Type-check the Admiral package README examples.
- `nix develop --command moon check src/util/target-file-discovery/README.mbt.md` — Type-check the target discovery README examples.
- `nix develop --command moon check` — Type-check all packages and supported targets.
- `nix develop --command moon test src/README.mbt.md` — Run the checked Admiral package README examples.
- `nix develop --command moon test src/util/target-file-discovery/README.mbt.md` — Run the checked target discovery README examples.
- `nix develop --command moon test` — Run package, blackbox, whitebox, and documentation tests.
- `nix develop --command moon package --list` — Confirm the packages included in publication.
- `nix develop --command nix flake check --all-systems --no-build` — Validate the flake without building its outputs.

## Architecture

### Declarative CLI model

- `OptionDef` and `PositionDef` keep a typed definition shared between parser declarations and `Context` getters.
- `CommandDef` describes options, positions, nested commands, examples, interactive input, and async execution.
- `CliApp` builds on `moonbitlang/core/argparse`, resolves `argv > env > config > default`, and dispatches callbacks.

### Runtime surfaces

- Interactive callbacks run only when selected definitions opt in and a TTY is available; typed setters override values before execution.
- Schema rendering and `ToJson` expose the complete CLI definition for tooling, while completion methods emit Bash, Zsh, and Fish scripts.
- `util/target-file-discovery` is a separate filesystem helper package with native, JavaScript, and Wasm support through `mizchi/x`.

### Target policy

- The module supports `js+native+wasm` and prefers JavaScript.
- The root package uses core argparse and environment APIs; asynchronous callbacks use `moonbitlang/async`.

### Package ownership

- `src` owns the published `totto2727/admiral` CLI package and its detailed user guide.
- `src/util/target-file-discovery` owns the filesystem discovery helpers and their package-specific guide.
- The repository root owns module metadata, the module overview, examples, and release workflows; it does not duplicate package API guides.

## Development tools

- **MoonBit**: Checks, tests, documentation examples, and package metadata.
- **Nix flakes**: Pin the MoonBit and Node.js development environment.
- **Mooncakes**: Publishes `totto2727/admiral` and hosts its generated API reference.
- **GitHub Actions**: Runs strict checks and publishes only from protected `main`.

## Package-specific rules

- Use the registry-first API policy: link README users to [Mooncakes Admiral API docs](https://mooncakes.io/docs/totto2727/admiral), and keep behavior, constraints, and representative examples in `///` docs or `src/examples/`.
- Preserve the physical root `README.mbt.md` module overview and the relative root `README.md -> README.mbt.md` alias.
- Keep package-specific details in `src/README.mbt.md` and `src/util/target-file-discovery/README.mbt.md`; do not aggregate module metadata in the `src` guide.
- Keep publication metadata in `moon.mod` synchronized with the latest release; run the full standard task set before a release.
- Do not broaden this standalone package with unrelated monorepo or upstream-fork changes.

_This AGENTS.md was generated from the [share-artifact skill](https://raw.githubusercontent.com/totto2727-org/agent/refs/heads/main/plugins/totto2727-coding/skills/share-artifact/SKILL.md) and [AGENTS template](https://raw.githubusercontent.com/totto2727-org/agent/refs/heads/main/plugins/totto2727-coding/skills/share-artifact/agents/template.md)._
