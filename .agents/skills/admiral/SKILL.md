---
name: admiral
description: Define typed MoonBit CLI options, positions, and command callbacks with Admiral. Use when resolving command input from argv, environment, configuration, or interactive editors.
---

# Convert Admiral input at the command boundary

1. Declare each option or positional once in the command that owns it.
   Register that typed definition and pass the same value to the matching `Context` getter in the command callback.
   See the [checked option and nested-command examples](https://github.com/totto2727-org/admiral/blob/main/src/usage_examples.mbt.md#typed-option).
2. Let Admiral resolve `argv > env > config > default`.
   Set `env` and `config` on the definition when those sources apply, rather than reading them again in the callback.
   If a field has an interactive editor, it receives the resolved value before dispatch and can replace only its own field.
3. Match the getter to the command's contract.
   For example, `get_int` returns `None` when the option is absent but raises on malformed input.
   Apply an optional fallback only to absence, not to a parse failure.
   Use a `_required` getter for a required value and a repeated getter for multiple values.
   The required repeated getter returns a `NonEmptyArray`, not a guarantee of exactly one value.
4. Convert resolved fields into the application's command input before invoking its operation.
   Represent mutually exclusive modes with an enum and reject conflicting combinations at this boundary.
   Pass the resulting input, not `Context`, to downstream code.
5. Exercise the callback through `CliApp::run` with explicit `argv` and `env` to verify precedence and failure behavior without relying on the developer's shell.
   Include the chosen value when two configured sources disagree, an absent required input, and an invalid supplied value.

Consult the [published Admiral API](https://mooncakes.io/docs/totto2727/admiral) for the signatures in the consumer's release.
Use the [package guide](https://github.com/totto2727-org/admiral/blob/main/README.mbt.md#environment-and-configuration) for configuration loading, field editors, schema output, and completion.
