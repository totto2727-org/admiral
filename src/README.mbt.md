# admiral

Declarative CLI builder for MoonBit, inspired by [gunshi](https://github.com/kazupon/gunshi).

This package is a fork of [mizchi/admiral](https://github.com/mizchi/admiral). It preserves the upstream MIT license and adds async-first command execution and help fallback behavior to its cross-target `moonbitlang/core/argparse` wrapper.

This package-local document is canonical `README.mbt.md`; maintain the repository links `README.mbt.md -> src/README.mbt.md` and `README.md -> README.mbt.md`.

## Usage

```moonbit
async fn main {
  let name = @admiral.string(
    "name",
    short='n',
    description="Name to greet",
    env="ADMIRAL_NAME",
    required=true,
  )
  let verbose = @admiral.bool("verbose", short='v', description="Verbose output")
  let count = @admiral.int("count", short='c', description="Repeat count", default=Some(1))
  let app = @admiral.CliApp::CliApp(
    name="myapp",
    version="1.0.0",
    description="My CLI tool",
    commands=[
      @admiral.CommandDef::CommandDef(
        name="greet",
        description="Greet someone",
        options=[name, verbose, count],
        run=Some(async fn(ctx) {
          let name_value = try { ctx.get_string_required(name) } catch { _ => return }
          let is_verbose = ctx.get_bool(verbose)
          let count_value = match ctx.get_int(count) { Some(n) => n; None => 1 }
          for i = 0; i < count_value; i = i + 1 {
            if is_verbose {
              println("Hello, " + name_value + "! (" + (i + 1).to_string() + ")")
            } else {
              println("Hello, " + name_value + "!")
            }
          }
        }),
      ),
    ],
  )
  app.run()
}
```

```text
$ myapp greet --name Alice
Hello, Alice!

$ myapp greet -n Bob -v -c 3
Hello, Bob! (1)
Hello, Bob! (2)
Hello, Bob! (3)
```

```mbt check
///|
test "README option definition 1 - preserves name and environment metadata" {
  let name = string("name", env="ADMIRAL_NAME", required=true)
  inspect(name.name, content="name")
  debug_inspect(name.metadata.env, content="Some(\"ADMIRAL_NAME\")")
  inspect(name.metadata.required, content="true")
}
```

## Key features

- Typed scalar and repeated option and positional helpers for strings and numeric values
- Independent environment and JSON configuration sources with deterministic precedence
- Async command callbacks, nested subcommands, and TTY-gated interactive input
- JSON schema output plus Bash, Zsh, and Fish completion generation
- Automatic `--help` and `--version`, including help for incomplete command paths

## Prerequisites

- **MoonBit**: Install the MoonBit toolchain and enter the pinned Nix development shell when working from source.
- **Supported targets**: JavaScript, native, and Wasm are enabled by the module; the default preferred target is JavaScript.

## Setup

Add Admiral and its async runtime to `moon.mod`:

```moonbit
import {
  "totto2727/admiral@0.6.4",
  "moonbitlang/async@0.20.3",
}

preferred_target = "js"

supported_targets = "js+native+wasm"
```

Add to `moon.pkg`:

```moonbit
import {
  "totto2727/admiral" @admiral,
  "moonbitlang/async",
}
```

## API

The [Mooncakes Admiral API reference](https://mooncakes.io/docs/totto2727/admiral) is the canonical generated API index. It includes the published signatures and the `///` documentation for every public helper, type, getter, and completion method.

## Guide

### Defining Options

Options and positions use the same value types and `Context` getters:

```moonbit
// String option: --name value or -n value
@admiral.string("name", short='n', description="User name", env="MYAPP_NAME", config="name", required=true)

// Bool flag: --verbose or -v
@admiral.bool("verbose", short='v', description="Verbose output", env="MYAPP_VERBOSE", config="verbose")

// Int option: --port 8080 or -p 8080
@admiral.int("port", short='p', description="Port number", env="MYAPP_PORT", config="port", default=Some(3000))

// Scalar position: file
@admiral.position_string("file", description="Input file", config="input", required=true)

// Variadic position: file...
@admiral.position_strings("files", description="Input files")
```

`short`, `env`, and `config` are optional. Omit `short` to only allow the long form (`--name`); set `env` to read an environment variable and `config` to read a separately named configuration key.

### Environment Variables

`string`, `bool`, and `int` accept an optional `env` argument containing the environment variable name:

```moonbit
@admiral.string("name", env="MYAPP_NAME")
@admiral.bool("verbose", env="MYAPP_VERBOSE")
@admiral.int("port", env="MYAPP_PORT")
```

`app.run()` reads process arguments and the process environment by default. For tests or embedding, inject either source explicitly:

```moonbit
app.run(
  argv=Some(["serve"]),
  env={
    "MYAPP_PORT": "8080",
    "MYAPP_VERBOSE": "true",
  },
)

// An empty map prevents ambient process variables from affecting the parse.
app.run(argv=Some(["serve"]), env=Map([]))
```

Values resolve in the order `argv > env > default_values`. Environment-backed boolean flags accept `1`, `0`, `true`, `false`, `yes`, `no`, `on`, and `off`.
Precedence is defined by [`moonbitlang/core/argparse`](https://github.com/moonbitlang/core/blob/1332a066d4143511c1b7db58877bc99991f548d6/argparse/command.mbt#L97-L115).
Boolean literals are handled by its [`bool` environment parser](https://github.com/moonbitlang/core/blob/1332a066d4143511c1b7db58877bc99991f548d6/argparse/parser_values.mbt#L293-L305).
The default process map comes from [`moonbitlang/core/env`](https://mooncakes.io/docs/moonbitlang/core/env).

The generated schema contains only configured environment-variable names and config keys; it never resolves or embeds runtime values.

Each helper returns a typed, read-only definition such as `OptionDef[String]`, `OptionDef[Bool]`, or `OptionDef[Int]`.
Pass the same definition to `command` or `cli` and to the matching `Context` getter; this makes the option name a single source of truth and causes mismatched getters to fail at compile time.

### Interactive Input

Set `interactive=true` on each option or position that participates in interactive input, then pass one async `interactive` callback to the owning `command` or root `cli`.
Admiral invokes the callback only when at least one registered definition opts in and `mizchi/tui` reports that an input TTY is available.
On native platforms, `mizchi/tui` treats either TTY-backed standard input or an available controlling terminal (`/dev/tty` or `CONIN$`) as interactive.
When no input TTY is available, Admiral skips the callback and preserves ordinary parsing and required-value validation.

```moonbit
let project = @admiral.position_string(
  "project",
  required=true,
  interactive=true,
)
let query = @admiral.string(
  "query",
  env="ADMIRAL_PROJECT_QUERY",
  default=Some(""),
  interactive=true,
)

let app = @admiral.CliApp::CliApp(
  name="project-search",
  positionals=[project],
  options=[query],
  interactive=Some(input => {
    let initial = input.to_context()
    let selected = run_project_search_tui(
      initial.get_string(project),
      initial.get_string(query).unwrap_or(""),
    )
    input.set_string(project, selected)
  }),
  run=Some(ctx => println(ctx.get_string_required(project))),
)
```

`InteractiveContext::to_context()` resolves initial values through the same `argv > env > config > default` rules as the final command callback.
The typed `set_bool`, `set_string`, `set_strings`, numeric scalar, and numeric array methods replace selected values before `run` executes.
Required interactive definitions are deferred until the callback only in an interactive environment, so a search selector can supply an otherwise missing required value.

The callback owns the entire interaction rather than a single component.
It can perform asynchronous discovery, maintain search state, run multiple screens, or mount a complete [`mizchi/tui`](https://github.com/mizchi/tui.mbt) event loop.
See [`src/examples/interactive`](examples/interactive) for a native searchable project selector based on the official `mizchi/tui` virtual DOM, keyboard input, and terminal APIs.

### Configuration

Pass an optional argument-less `load_config` callback to `cli`.
The callback can read any configuration format, but must return a `Map[String, Json]` whose keys match the independent `config` names declared on options or positions:

```moonbit
fn load_config() -> Map[String, Json] raise @admiral.ConfigLoadFailure {
  {
    "port": (7000).to_json(),
    "verbose": (true).to_json(),
    "tags": ["release", "signed"].to_json(),
  }
}

let app = @admiral.CliApp::CliApp(
  name="myapp",
  load_config=Some(load_config),
  commands=[...],
)
```

`CliApp::run` passes only the real environment map to `core/argparse` and stores the loaded configuration map separately in each command `Context`.
Each `Context` getter inspects the parser's [`ValueSource`](https://github.com/moonbitlang/core/blob/1332a066d4143511c1b7db58877bc99991f548d6/argparse/matches.mbt#L15-L41).
Each getter first decides whether config should be used.
An `Argv` or `Env` source skips config and continues with the existing value parsing; a `Default` or absent source first checks the definition's `config` key and decodes an available JSON value with `FromJson`, then falls back to parsing the declared default or missing-value behavior only when that config key is unavailable.

Values resolve in the order `argv > env > config > default`.
Option names, environment-variable names, and config keys are independent.
Config values are available to options and positions that declare `config`.
When a loaded config key satisfies a required argument, admiral relaxes the corresponding parser requirement; when it is absent, ordinary `core/argparse` required validation remains active.

Environment values remain scalar strings and continue to use `core/argparse` parsing.
Config values are decoded by the matching MoonBit [`FromJson`](https://github.com/moonbitlang/core/blob/1332a066d4143511c1b7db58877bc99991f548d6/json/from_json.mbt) implementation inside each getter.
Plural definitions such as `strings` and `ints` require a JSON array and preserve its elements.
An active config value that cannot be decoded raises `JsonDecodeError` instead of falling back to a declared default; scalar getters use `None` for an unavailable value, while plural getters return an empty array.
Numeric parsing failures from argv, environment variables, or declared defaults also propagate as errors instead of returning `None`.
Required plural getters return `NonEmptyArray[T]`, exposing `first: T`, `rest: ArrayView[T]`, and `all: ReadOnlyArray[T]`; they raise when the resolved array is empty.
Return `Map([])` when no configuration values are available.

`ConfigLoadFailure` is the typed error for the callback.
For example, a loader can report `raise @admiral.ConfigLoadFailure("config file is unreadable")`.

`CliApp` is a public record.
Direct struct-literal callers must include `interactive` and `load_config` in `CliApp`; direct `CommandDef` literals must include `interactive`; and direct `Context` literals must include `sources`, `config`, `interactive_flags`, and `interactive_values`.
Calls through `cli`, `command`, and `Context::Context` remain source-compatible because the new inputs are optional or initialized internally.

### Reading Values from Context

Inside an async `run` callback, use `Context` methods to read parsed values:

```moonbit
let verbose = @admiral.bool("verbose")
let name = @admiral.string("name", required=true)
let port = @admiral.int("port", required=true)
let input = @admiral.position_int("input", required=true)

// Register definitions with CommandDef::CommandDef(options=[verbose, name, port], positionals=[input]).
run=Some(async fn(ctx) {
  // Bool — returns false if not specified
  let is_verbose = ctx.get_bool(verbose)

  // String — returns None if not specified
  let name_value = ctx.get_string(name)       // String?

  // String (required) — raises if missing
  let name_value = try { ctx.get_string_required(name) } catch { _ => return }

  // Int — parses string value to Int, returns None if missing or invalid
  let port_value = ctx.get_int(port)           // Int?

  // Int (required) — raises if missing or not a valid integer
  let port_value = try { ctx.get_int_required(port) } catch { _ => return }

  // The same getter accepts PositionDef[Int]
  let input_value = try { ctx.get_int_required(input) } catch { _ => return }
})
```

### Nested Subcommands

Commands can nest arbitrarily deep:

```moonbit
let dry_run = @admiral.bool("dry-run", description="Preview without applying")
let up_steps = @admiral.int("steps", short='s', description="Number of steps")
let down_steps = @admiral.int("steps", short='s', description="Steps to rollback", default=Some(1))
let seed_file = @admiral.string("file", short='f', description="Seed file", default=Some("seeds/default.sql"))

let app = @admiral.CliApp::CliApp(
  name="myapp",
  commands=[
    @admiral.CommandDef::CommandDef(
      name="db",
      description="Database commands",
      subcommands=[
        @admiral.CommandDef::CommandDef(
          name="migrate",
          description="Run migrations",
          subcommands=[
            @admiral.CommandDef::CommandDef(
              name="up",
              description="Apply pending migrations",
              options=[dry_run, up_steps],
              examples=[
                "myapp db migrate up",
                "myapp db migrate up --dry-run",
                "myapp db migrate up --steps 5",
              ],
              run=Some(async fn(ctx) {
                if ctx.get_bool(dry_run) {
                  println("[DRY RUN] Would apply migrations")
                } else {
                  match ctx.get_int(up_steps) {
                    Some(n) => println("Applying " + n.to_string() + " migrations...")
                    None => println("Applying all pending migrations...")
                  }
                }
              }),
            ),
            @admiral.CommandDef::CommandDef(
              name="down",
              description="Rollback migrations",
              options=[down_steps],
              run=Some(async fn(ctx) {
                let steps = match ctx.get_int(down_steps) { Some(n) => n; None => 1 }
                println("Rolling back " + steps.to_string() + " migration(s)...")
              }),
            ),
          ],
        ),
        @admiral.CommandDef::CommandDef(
          name="seed",
          description="Seed the database",
          options=[seed_file],
          run=Some(async fn(ctx) {
            let file = match ctx.get_string(seed_file) { Some(f) => f; None => "seeds/default.sql" }
            println("Seeding from: " + file)
          }),
        ),
      ],
    ),
  ],
)
```

```
$ myapp db migrate up --dry-run
[DRY RUN] Would apply migrations

$ myapp db migrate down --steps 3
Rolling back 3 migration(s)...

$ myapp db seed --file custom.sql
Seeding from: custom.sql
```

### Positional Arguments

```moonbit
let files = @admiral.position_strings("files", description="Files to concatenate")

@admiral.CommandDef::CommandDef(
  name="cat",
  description="Concatenate files",
  positionals=[files],
  run=Some(async fn(ctx) {
    let file_values = ctx.get_strings(files)
    for file in file_values {
      println("Reading: " + file)
    }
  }),
)
```

```
$ myapp cat a.txt b.txt c.txt
Reading: a.txt
Reading: b.txt
Reading: c.txt
```

### Testing with Explicit argv

```moonbit
// In async tests, pass argv explicitly:
async test {
  app.run(argv=Some(["greet", "--name", "alice"]))
}

// In production, omit argv to use process args:
app.run()
```

### Structured Schema Output

admiral can output the full CLI definition as JSON — useful for AI agents, documentation generators, and tooling:

```moonbit
println(app.render_schema())         // -> JSON string
let json = ToJson::to_json(app)      // -> Json value
```

Example output:

```json
{
  "name": "myapp",
  "version": "1.0.0",
  "description": "My CLI tool",
  "commands": {
    "greet": {
      "description": "Greet someone",
      "options": {
        "name": {
          "type": "string",
          "description": "Name to greet",
          "required": true,
          "short": "n",
          "env": "ADMIRAL_NAME"
        },
        "verbose": { "type": "bool", "description": "Verbose output", "required": false, "short": "v" },
        "count": { "type": "int", "description": "Repeat count", "required": false, "short": "c", "default": "1" }
      },
      "examples": ["myapp greet --name Alice", "myapp greet -n Bob -v -c 3"]
    },
    "db": {
      "description": "Database commands",
      "commands": {
        "migrate": {
          "description": "Run migrations",
          "commands": {
            "up": {
              "description": "Apply pending migrations",
              "options": {
                "dry-run": { "type": "bool", "description": "Preview without applying", "required": false },
                "steps": { "type": "int", "description": "Number of steps", "required": false, "short": "s" }
              },
              "examples": ["myapp db migrate up", "myapp db migrate up --dry-run"]
            }
          }
        }
      }
    }
  }
}
```

This enables AI agents to understand CLI interfaces without parsing `--help` text — types, required/optional, defaults, and examples are all machine-readable.

### Shell Completion

Generate completion scripts for bash, zsh, and fish:

```moonbit
// Bash
println(app.render_bash_completion())

// Zsh
println(app.render_zsh_completion())

// Fish
println(app.render_fish_completion())
```

Typical usage — add a `completion` subcommand:

```moonbit
let shell = @admiral.string(
  "shell",
  short='s',
  description="Shell type (bash, zsh, fish)",
  required=true,
)

@admiral.CommandDef::CommandDef(
  name="completion",
  description="Generate shell completion script",
  options=[shell],
  run=Some(async fn(ctx) {
    match ctx.get_string(shell) {
      Some("bash") => println(app.render_bash_completion())
      Some("zsh") => println(app.render_zsh_completion())
      Some("fish") => println(app.render_fish_completion())
      _ => println("Unsupported shell. Use: bash, zsh, fish")
    }
  }),
)
```

```bash
# Bash: add to ~/.bashrc
eval "$(myapp completion --shell bash)"

# Zsh: add to ~/.zshrc
eval "$(myapp completion --shell zsh)"

# Fish: save to completions dir
myapp completion --shell fish > ~/.config/fish/completions/myapp.fish
```

## Targets

The primary Admiral library and CLI surfaces support native and JavaScript targets and prefer JavaScript. The filesystem-based `util/target-file-discovery` subpackage additionally supports Wasm through [`mizchi/x`](https://github.com/mizchi/x), which delegates to `moonbitlang/async/fs` on native and Wasm and provides a Node.js implementation on JavaScript.

## Development

For repository structure and development commands, see [AGENTS.md](../AGENTS.md).

## License

MIT. See [LICENSE](../LICENSE).

The upstream project declares its original license as MIT in [mizchi/admiral's module manifest](https://github.com/mizchi/admiral/blob/main/moon.mod.json).

_This README was generated from the [share-artifact skill](https://raw.githubusercontent.com/totto2727-org/agent/refs/heads/main/plugins/totto2727-coding/skills/share-artifact/SKILL.md) and [README template](https://raw.githubusercontent.com/totto2727-org/agent/refs/heads/main/plugins/totto2727-coding/skills/share-artifact/readme/template.md)._
