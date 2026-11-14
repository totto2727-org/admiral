///|
test "string() creates StringOpt OptionDef" {
  let opt = @admiral.string(
    "name",
    short='n',
    description="User name",
    required=true,
  )
  inspect(opt.name, content="name")
  inspect(opt.metadata.type_, content="StringOpt")
  inspect(
    opt.metadata.short,
    content=(
      #|n
    ),
  )
  inspect(opt.metadata.required, content="true")
  debug_inspect(opt.metadata.default_value, content="None")
}

///|
test "string() with default value" {
  let opt = @admiral.string(
    "output",
    description="Output path",
    default=Some("stdout"),
  )
  debug_inspect(opt.metadata.default_value, content="Some(\"stdout\")")
  inspect(opt.metadata.required, content="false")
}

///|
test "string() retains interactive input metadata" {
  let opt = @admiral.string("project", interactive=true)
  inspect(opt.metadata.interactive, content="true")
}

///|
test "bool() creates BoolOpt OptionDef" {
  let opt = @admiral.bool("verbose", short='v', description="Verbose output")
  inspect(opt.metadata.type_, content="BoolOpt")
  inspect(opt.metadata.required, content="false")
}

///|
test "int() creates IntOpt OptionDef" {
  let opt = @admiral.int(
    "count",
    short='c',
    description="Repeat count",
    default=Some(3),
  )
  inspect(opt.metadata.type_, content="IntOpt")
  debug_inspect(opt.metadata.default_value, content="Some(\"3\")")
}

///|
test "int() required" {
  let opt = @admiral.int(
    "port",
    short='p',
    description="Port number",
    required=true,
  )
  inspect(opt.metadata.required, content="true")
  debug_inspect(opt.metadata.default_value, content="None")
}

///|
test "numeric option helpers create typed definitions" {
  let int64_opt = @admiral.int64("offset", default=Some(42L))
  let uint_opt = @admiral.uint("retries", default=Some(42U))
  let uint64_opt = @admiral.uint64("limit", default=Some(42UL))
  let double_opt = @admiral.double("ratio", default=Some(1.25))
  inspect(int64_opt.metadata.type_, content="Int64Opt")
  inspect(uint_opt.metadata.type_, content="UIntOpt")
  inspect(uint64_opt.metadata.type_, content="UInt64Opt")
  inspect(double_opt.metadata.type_, content="DoubleOpt")
  debug_inspect(int64_opt.metadata.default_value, content="Some(\"42\")")
  debug_inspect(uint_opt.metadata.default_value, content="Some(\"42\")")
  debug_inspect(uint64_opt.metadata.default_value, content="Some(\"42\")")
  debug_inspect(double_opt.metadata.default_value, content="Some(\"1.25\")")
}

///|
test "option helpers retain environment variable metadata" {
  let name = @admiral.string("name", env="APP_NAME")
  let verbose = @admiral.bool("verbose", env="APP_VERBOSE")
  let port = @admiral.int("port", env="APP_PORT")
  let offset = @admiral.int64("offset", env="APP_OFFSET")
  let retries = @admiral.uint("retries", env="APP_RETRIES")
  let limit = @admiral.uint64("limit", env="APP_LIMIT")
  let ratio = @admiral.double("ratio", env="APP_RATIO")
  debug_inspect(name.metadata.env, content="Some(\"APP_NAME\")")
  debug_inspect(verbose.metadata.env, content="Some(\"APP_VERBOSE\")")
  debug_inspect(port.metadata.env, content="Some(\"APP_PORT\")")
  debug_inspect(offset.metadata.env, content="Some(\"APP_OFFSET\")")
  debug_inspect(retries.metadata.env, content="Some(\"APP_RETRIES\")")
  debug_inspect(limit.metadata.env, content="Some(\"APP_LIMIT\")")
  debug_inspect(ratio.metadata.env, content="Some(\"APP_RATIO\")")
}

///|
test "option helpers retain independent config keys" {
  let name = @admiral.string("name", env="APP_NAME", config="display_name")
  let verbose = @admiral.bool("verbose", config="debug")
  let port = @admiral.int("port", config="listen_port")
  debug_inspect(name.config, content="Some(\"display_name\")")
  debug_inspect(verbose.config, content="Some(\"debug\")")
  debug_inspect(port.config, content="Some(\"listen_port\")")
  debug_inspect(name.metadata.env, content="Some(\"APP_NAME\")")
}

///|
test "plural option helpers encode Array result types" {
  let names : @admiral.OptionDef[Array[String]] = @admiral.strings("name")
  let counts : @admiral.OptionDef[Array[Int32]] = @admiral.ints("count")
  let offsets : @admiral.OptionDef[Array[Int64]] = @admiral.int64s("offset")
  let retries : @admiral.OptionDef[Array[UInt32]] = @admiral.uints("retry")
  let limits : @admiral.OptionDef[Array[UInt64]] = @admiral.uint64s("limit")
  let ratios : @admiral.OptionDef[Array[Double]] = @admiral.doubles("ratio")
  inspect(names.metadata.multiple, content="true")
  inspect(counts.metadata.multiple, content="true")
  inspect(offsets.metadata.multiple, content="true")
  inspect(retries.metadata.multiple, content="true")
  inspect(limits.metadata.multiple, content="true")
  inspect(ratios.metadata.multiple, content="true")
}
