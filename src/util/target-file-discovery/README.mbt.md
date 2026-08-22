# target-file-discovery

`target-file-discovery` provides asynchronous helpers for locating named files in a home directory, an ancestor directory, or a recursive tree.

The module [README](../../../README.mbt.md) owns installation and the shared usage path. These helpers support native, JavaScript, and Wasm through `mizchi/x`; the calling process must be able to read the searched directories.

## API

### `find_home_target_file`

`find_home_target_file(home_dir, file_name)` returns the path when `file_name` exists directly below `home_dir`; it raises when the file is absent.

```mbt check
///|
async test "README target discovery API - finds a home-level target" {
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

_This README was generated from the [share-artifact skill](https://raw.githubusercontent.com/totto2727-org/agent/refs/heads/main/plugins/totto2727-coding/skills/share-artifact/SKILL.md) and [README template](https://raw.githubusercontent.com/totto2727-org/agent/refs/heads/main/plugins/totto2727-coding/skills/share-artifact/readme/template.md)._
