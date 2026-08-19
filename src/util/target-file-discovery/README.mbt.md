# target-file-discovery

`target-file-discovery` provides asynchronous helpers for locating named files in a home directory, an ancestor directory, or a recursive tree.

## Usage

Use `find_home_target_file` when the target must be directly below a known directory:

```mbt check
///|
async test "README target discovery 1 - finds a home-level target" {
  let root = @fs.tmpdir(prefix="admiral-readme-home-")
  let path = @path.Path::join(root, "project.toml").to_string()
  @fs.write_file(path, "demo", create_mode=CreateOrTruncate)
  inspect(
    @target-file-discovery.find_home_target_file(root, "project.toml"),
    content=path,
  )
  @fs.rmdir(root, recursive=true)
}
```

## Key features

- Finds a target file directly under a home directory.
- Searches upward from a start directory without crossing a caller-provided boundary.
- Recursively collects matching files in deterministic order.
- Applies inherited `.gitignore`-style rules while traversing descendants.
- Supports native, JavaScript, and Wasm through `mizchi/x` filesystem APIs.

## Prerequisites

- **MoonBit**: Install the MoonBit toolchain.
- **Filesystem access**: The calling process must be able to read the directories it searches.

## Setup

Add Admiral and its async runtime to the consuming module's `moon.mod`:

```text
import {
  "totto2727/admiral@0.6.4",
  "moonbitlang/async@0.20.3",
}

preferred_target = "js"
supported_targets = "js+native+wasm"
```

Import target-file-discovery with an explicit alias in the consuming package's `moon.pkg`:

```text
supported_targets = "js+native+wasm"

import {
  "totto2727/admiral/util/target-file-discovery" @target-file-discovery,
  "moonbitlang/async",
}
```

## API

### `find_home_target_file`

`find_home_target_file(home_dir, file_name)` returns the path when `file_name` exists directly below `home_dir`; it raises when the file is absent.

### `find_parent_target_file`

`find_parent_target_file(file_name, top_dir, start_dir)` searches `start_dir` and its ancestors through `top_dir`, returning the nearest match and raising when no match exists inside the boundary.

### `collect_recursive_target_files`

`collect_recursive_target_files(start_dir, file_name)` returns a deterministic read-only array of matching descendant paths after applying inherited `.gitignore` rules.

```text
let target_files = @target-file-discovery.collect_recursive_target_files(
  ".",
  "moon.pkg",
)
```

## Development

For development guidance, see [AGENTS.md](../../../AGENTS.md).

## License

MIT. See [LICENSE](../../../LICENSE).

_This README was generated from the [share-artifact skill](https://raw.githubusercontent.com/totto2727-org/agent/refs/heads/main/plugins/totto2727-coding/skills/share-artifact/SKILL.md) and [README template](https://raw.githubusercontent.com/totto2727-org/agent/refs/heads/main/plugins/totto2727-coding/skills/share-artifact/readme/template.md)._
