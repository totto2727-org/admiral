///|
test "get_bool returns flag value" {
  let flags : Map[String, Bool] = { "verbose": true }
  let ctx : Context = { flags, values: Map([]), subcommand: None }
  inspect(ctx.get_bool("verbose"), content="true")
  inspect(ctx.get_bool("missing"), content="false")
}

///|
test "get_string returns first value" {
  let values : Map[String, Array[String]] = { "name": ["alice"] }
  let ctx : Context = { flags: Map([]), values, subcommand: None }
  debug_inspect(ctx.get_string("name"), content="Some(\"alice\")")
  debug_inspect(ctx.get_string("missing"), content="None")
}

///|
test "get_string_required raises on missing" {
  let ctx : Context = { flags: Map([]), values: Map([]), subcommand: None }
  let mut raised = false
  try ctx.get_string_required("name") |> ignore catch {
    _ => raised = true
  }
  inspect(raised, content="true")
}

///|
test "get_int parses integer value" {
  let values : Map[String, Array[String]] = { "count": ["42"] }
  let ctx : Context = { flags: Map([]), values, subcommand: None }
  debug_inspect(ctx.get_int("count"), content="Some(42)")
  debug_inspect(ctx.get_int("missing"), content="None")
}

///|
test "get_int returns None for non-integer" {
  let values : Map[String, Array[String]] = { "count": ["abc"] }
  let ctx : Context = { flags: Map([]), values, subcommand: None }
  debug_inspect(ctx.get_int("count"), content="None")
}

///|
test "get_int returns None for overflow" {
  let values : Map[String, Array[String]] = { "n": ["99999999999999999999"] }
  let ctx : Context = { flags: Map([]), values, subcommand: None }
  debug_inspect(ctx.get_int("n"), content="None")
}

///|
test "get_int parses negative" {
  let values : Map[String, Array[String]] = { "n": ["-42"] }
  let ctx : Context = { flags: Map([]), values, subcommand: None }
  debug_inspect(ctx.get_int("n"), content="Some(-42)")
}

///|
test "get_int_required raises on missing" {
  let ctx : Context = { flags: Map([]), values: Map([]), subcommand: None }
  let mut raised = false
  try ctx.get_int_required("port") |> ignore catch {
    _ => raised = true
  }
  inspect(raised, content="true")
}

///|
test "get_int_required raises on non-integer" {
  let values : Map[String, Array[String]] = { "port": ["abc"] }
  let ctx : Context = { flags: Map([]), values, subcommand: None }
  let mut raised = false
  try ctx.get_int_required("port") |> ignore catch {
    _ => raised = true
  }
  inspect(raised, content="true")
}

///|
test "get_int_required returns value" {
  let values : Map[String, Array[String]] = { "port": ["8080"] }
  let ctx : Context = { flags: Map([]), values, subcommand: None }
  let result = ctx.get_int_required("port") catch { _ => -1 }
  inspect(result, content="8080")
}

///|
test "numeric getters parse supported string number types" {
  let values : Map[String, Array[String]] = {
    "int64": ["9223372036854775807"],
    "uint": ["4294967295"],
    "uint64": ["18446744073709551615"],
    "double": ["1.25"],
  }
  let ctx : Context = { flags: Map([]), values, subcommand: None }
  debug_inspect(
    ctx.get_int64("int64").map(fn(value) { value.to_string() }),
    content="Some(\"9223372036854775807\")",
  )
  debug_inspect(
    ctx.get_uint("uint").map(fn(value) { value.to_string() }),
    content="Some(\"4294967295\")",
  )
  debug_inspect(
    ctx.get_uint64("uint64").map(fn(value) { value.to_string() }),
    content="Some(\"18446744073709551615\")",
  )
  debug_inspect(ctx.get_double("double"), content="Some(1.25)")
}

///|
test "numeric getters return None for invalid values" {
  let values : Map[String, Array[String]] = {
    "int64": ["invalid"],
    "uint": ["-1"],
    "uint64": ["invalid"],
    "double": ["invalid"],
  }
  let ctx : Context = { flags: Map([]), values, subcommand: None }
  debug_inspect(ctx.get_int64("int64"), content="None")
  debug_inspect(ctx.get_uint("uint"), content="None")
  debug_inspect(ctx.get_uint64("uint64"), content="None")
  debug_inspect(ctx.get_double("double"), content="None")
}

///|
test "required numeric getters return parsed values" {
  let values : Map[String, Array[String]] = {
    "int64": ["42"],
    "uint": ["42"],
    "uint64": ["42"],
    "double": ["1.25"],
  }
  let ctx : Context = { flags: Map([]), values, subcommand: None }
  inspect(ctx.get_int64_required("int64").to_string(), content="42")
  inspect(ctx.get_uint_required("uint").to_string(), content="42")
  inspect(ctx.get_uint64_required("uint64").to_string(), content="42")
  inspect(ctx.get_double_required("double"), content="1.25")
}

///|
test "get_strings returns all values" {
  let values : Map[String, Array[String]] = { "files": ["a.txt", "b.txt"] }
  let ctx : Context = { flags: Map([]), values, subcommand: None }
  let files = ctx.get_strings("files")
  inspect(files.length(), content="2")
  inspect(files[0], content="a.txt")
}

///|
test "get_subcommand returns nested context" {
  let sub_ctx : Context = {
    flags: Map([]),
    values: { "port": ["8080"] },
    subcommand: None,
  }
  let ctx : Context = {
    flags: Map([]),
    values: Map([]),
    subcommand: Some(("serve", sub_ctx)),
  }
  match ctx.get_subcommand() {
    Some((name, sub)) => {
      inspect(name, content="serve")
      debug_inspect(sub.get_string("port"), content="Some(\"8080\")")
    }
    None => fail("expected subcommand")
  }
}
