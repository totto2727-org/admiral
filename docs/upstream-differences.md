# Upstream differences

This fork is based on [`mizchi/admiral` at `3793ad7d9a8f755f6cbb88a4f6c24de61bc7e1c8`](https://github.com/mizchi/admiral/commit/3793ad7d9a8f755f6cbb88a4f6c24de61bc7e1c8).

## Runtime and public API

- The fork publishes `totto2727/admiral`, an async-first typed CLI with nested commands, independent config keys, schema, shell completion, and a separate file-discovery package.
- The CLI resolves argv, environment, configuration, and defaults before running field-level editors. Editors replace only their registered option or positional value. `src/interactive` defines the host-independent editor contract.
- The CLI and editor contract support linear Wasm without terminal dependencies. The optional terminal picker in `examples/tui` is a separate JavaScript and native example module. It registers its editor only with a TTY.
- Code using the former fork-specific command-wide interactive callback must migrate to field editors. See [Interactive input](../README.mbt.md#interactive-input).

## Build and publication

- The fork uses a pinned MoonBit toolchain through its Nix shell and publishes `totto2727/admiral` through its protected `main` workflow. The terminal example has no separate publication and is not in the main module's dependency graph.
