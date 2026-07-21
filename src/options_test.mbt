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
test "option helpers retain environment variable metadata" {
  let name = string("name", env="APP_NAME")
  let verbose = bool("verbose", env="APP_VERBOSE")
  let port = int("port", env="APP_PORT")
  debug_inspect(name.env, content="Some(\"APP_NAME\")")
  debug_inspect(verbose.env, content="Some(\"APP_VERBOSE\")")
  debug_inspect(port.env, content="Some(\"APP_PORT\")")
}
