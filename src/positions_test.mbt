///|
test "position helpers encode scalar and array result types" {
  let input : @admiral.PositionDef[String] = @admiral.position_string(
    "input",
    description="Input file",
    required=true,
  )
  let files : @admiral.PositionDef[Array[String]] = @admiral.position_strings(
    "files",
  )
  let count : @admiral.PositionDef[Int32] = @admiral.position_int("count")
  let counts : @admiral.PositionDef[Array[Int32]] = @admiral.position_ints(
    "counts",
  )
  inspect(input.name, content="input")
  inspect(input.metadata.required, content="true")
  inspect(input.metadata.multiple, content="false")
  inspect(files.metadata.multiple, content="true")
  inspect(count.metadata.type_, content="IntOpt")
  inspect(counts.metadata.multiple, content="true")
}

///|
test "position helpers retain config keys" {
  let input = @admiral.position_string("input", config="input_path")
  let files = @admiral.position_strings("files", config="input_files")
  debug_inspect(input.config, content="Some(\"input_path\")")
  debug_inspect(files.config, content="Some(\"input_files\")")
}

///|
test "position_string() retains interactive input metadata" {
  let input = @admiral.position_string("input", interactive=true)
  inspect(input.metadata.interactive, content="true")
}
