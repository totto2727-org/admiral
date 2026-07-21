///|
test "string() creates StringOpt OptionDef" {
  let opt = string("name", short='n', description="User name", required=true)
  inspect(opt.name, content="name")
  inspect(opt.type_, content="StringOpt")
  inspect(
    opt.short,
    content=(
      #|n
    ),
  )
  inspect(opt.required, content="true")
  debug_inspect(opt.default_value, content="None")
}

///|
test "string() with default value" {
  let opt = string("output", description="Output path", default=Some("stdout"))
  debug_inspect(opt.default_value, content="Some(\"stdout\")")
  inspect(opt.required, content="false")
}

///|
test "bool() creates BoolOpt OptionDef" {
  let opt = bool("verbose", short='v', description="Verbose output")
  inspect(opt.type_, content="BoolOpt")
  inspect(opt.required, content="false")
}

///|
test "int() creates IntOpt OptionDef" {
  let opt = int("count", short='c', description="Repeat count", default=Some(3))
  inspect(opt.type_, content="IntOpt")
  debug_inspect(opt.default_value, content="Some(\"3\")")
}

///|
test "int() required" {
  let opt = int("port", short='p', description="Port number", required=true)
  inspect(opt.required, content="true")
  debug_inspect(opt.default_value, content="None")
}

///|
test "numeric option helpers create typed definitions" {
  let int64_opt = int64("offset", default=Some(42L))
  let uint_opt = uint("retries", default=Some(42U))
  let uint64_opt = uint64("limit", default=Some(42UL))
  let double_opt = double("ratio", default=Some(1.25))
  inspect(int64_opt.type_, content="Int64Opt")
  inspect(uint_opt.type_, content="UIntOpt")
  inspect(uint64_opt.type_, content="UInt64Opt")
  inspect(double_opt.type_, content="DoubleOpt")
  debug_inspect(int64_opt.default_value, content="Some(\"42\")")
  debug_inspect(uint_opt.default_value, content="Some(\"42\")")
  debug_inspect(uint64_opt.default_value, content="Some(\"42\")")
  debug_inspect(double_opt.default_value, content="Some(\"1.25\")")
}

///|
test "option helpers retain environment variable metadata" {
  let name = string("name", env="APP_NAME")
  let verbose = bool("verbose", env="APP_VERBOSE")
  let port = int("port", env="APP_PORT")
  let offset = int64("offset", env="APP_OFFSET")
  let retries = uint("retries", env="APP_RETRIES")
  let limit = uint64("limit", env="APP_LIMIT")
  let ratio = double("ratio", env="APP_RATIO")
  debug_inspect(name.env, content="Some(\"APP_NAME\")")
  debug_inspect(verbose.env, content="Some(\"APP_VERBOSE\")")
  debug_inspect(port.env, content="Some(\"APP_PORT\")")
  debug_inspect(offset.env, content="Some(\"APP_OFFSET\")")
  debug_inspect(retries.env, content="Some(\"APP_RETRIES\")")
  debug_inspect(limit.env, content="Some(\"APP_LIMIT\")")
  debug_inspect(ratio.env, content="Some(\"APP_RATIO\")")
}
