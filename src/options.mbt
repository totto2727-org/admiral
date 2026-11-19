///|
/// sentinel value for "no short flag"
let no_short : Char = '\u0000'

///|
fn[T] option_def(
  name : String,
  config : String?,
  type_ : OptionType,
  short : Char,
  description : String,
  env : String?,
  required : Bool,
  default_value : String?,
  multiple : Bool,
  interactive : FieldEditor[T]?,
  read : (Context, OptionDef[T]) -> T? raise,
  write : (Context, String, T, Bool) -> Context,
) -> OptionDef[T] {
  let field : OptionDef[T] = {
    name,
    config,
    metadata: {
      type_,
      short,
      description,
      env,
      required,
      default_value,
      multiple,
      interactive: interactive is Some(_),
    },
    editor: None,
  }
  { ..field, editor: field_edit(field, interactive, read, write, required), }
}

///|
/// Defines a scalar string option. Set `required` when the command must receive
/// a value and `default` when a fallback should be used. `env` and `config`
/// select independent environment and configuration keys.
pub fn string(
  name : String,
  short~ : Char = '\u0000',
  description~ : String = "",
  env? : String,
  config? : String,
  required~ : Bool = false,
  default~ : String? = None,
  interactive? : FieldEditor[String],
) -> OptionDef[String] {
  option_def(
    name,
    config,
    StringOpt,
    short,
    description,
    env,
    default is None && required,
    default,
    false,
    interactive,
    (ctx, field) => ctx.get_string(field),
    write_string,
  )
}

///|
/// Defines a repeated string option. Values are returned by
/// `Context::get_strings`; configuration values must be JSON arrays.
pub fn strings(
  name : String,
  short~ : Char = '\u0000',
  description~ : String = "",
  env? : String,
  config? : String,
  required~ : Bool = false,
  interactive? : FieldEditor[Array[String]],
) -> OptionDef[Array[String]] {
  option_def(
    name,
    config,
    StringOpt,
    short,
    description,
    env,
    required,
    None,
    true,
    interactive,
    (ctx, field) => nonempty(ctx.get_strings(field)),
    write_strings,
  )
}

///|
/// Defines a boolean flag. An omitted flag resolves to `false`; environment
/// values use the boolean literals accepted by `core/argparse`.
pub fn bool(
  name : String,
  short~ : Char = '\u0000',
  description~ : String = "",
  env? : String,
  config? : String,
  interactive? : FieldEditor[Bool],
) -> OptionDef[Bool] {
  option_def(
    name,
    config,
    BoolOpt,
    short,
    description,
    env,
    false,
    None,
    false,
    interactive,
    (ctx, field) => Some(ctx.get_bool(field)),
    write_flag,
  )
}

///|
/// Defines a scalar signed integer option with optional defaults and required
/// validation.
pub fn int(
  name : String,
  short~ : Char = '\u0000',
  description~ : String = "",
  env? : String,
  config? : String,
  required~ : Bool = false,
  default~ : Int32? = None,
  interactive? : FieldEditor[Int32],
) -> OptionDef[Int32] {
  option_def(
    name,
    config,
    IntOpt,
    short,
    description,
    env,
    default is None && required,
    default.map(fn(value) { value.to_string() }),
    false,
    interactive,
    Context::get_int,
    write_scalar,
  )
}

///|
/// Defines a repeated signed integer option. Use `Context::get_ints` to read
/// all values after parsing.
pub fn ints(
  name : String,
  short~ : Char = '\u0000',
  description~ : String = "",
  env? : String,
  config? : String,
  required~ : Bool = false,
  interactive? : FieldEditor[Array[Int32]],
) -> OptionDef[Array[Int32]] {
  option_def(
    name,
    config,
    IntOpt,
    short,
    description,
    env,
    required,
    None,
    true,
    interactive,
    (ctx, field) => nonempty(ctx.get_ints(field)),
    write_array,
  )
}

///|
/// Defines a scalar 64-bit signed integer option.
pub fn int64(
  name : String,
  short~ : Char = '\u0000',
  description~ : String = "",
  env? : String,
  config? : String,
  required~ : Bool = false,
  default~ : Int64? = None,
  interactive? : FieldEditor[Int64],
) -> OptionDef[Int64] {
  option_def(
    name,
    config,
    Int64Opt,
    short,
    description,
    env,
    default is None && required,
    default.map(fn(value) { value.to_string() }),
    false,
    interactive,
    Context::get_int64,
    write_scalar,
  )
}

///|
/// Defines a repeated 64-bit signed integer option.
pub fn int64s(
  name : String,
  short~ : Char = '\u0000',
  description~ : String = "",
  env? : String,
  config? : String,
  required~ : Bool = false,
  interactive? : FieldEditor[Array[Int64]],
) -> OptionDef[Array[Int64]] {
  option_def(
    name,
    config,
    Int64Opt,
    short,
    description,
    env,
    required,
    None,
    true,
    interactive,
    (ctx, field) => nonempty(ctx.get_int64s(field)),
    write_array,
  )
}

///|
/// Defines a scalar unsigned integer option.
pub fn uint(
  name : String,
  short~ : Char = '\u0000',
  description~ : String = "",
  env? : String,
  config? : String,
  required~ : Bool = false,
  default~ : UInt32? = None,
  interactive? : FieldEditor[UInt32],
) -> OptionDef[UInt32] {
  option_def(
    name,
    config,
    UIntOpt,
    short,
    description,
    env,
    default is None && required,
    default.map(fn(value) { value.to_string() }),
    false,
    interactive,
    Context::get_uint,
    write_scalar,
  )
}

///|
/// Defines a repeated unsigned integer option.
pub fn uints(
  name : String,
  short~ : Char = '\u0000',
  description~ : String = "",
  env? : String,
  config? : String,
  required~ : Bool = false,
  interactive? : FieldEditor[Array[UInt32]],
) -> OptionDef[Array[UInt32]] {
  option_def(
    name,
    config,
    UIntOpt,
    short,
    description,
    env,
    required,
    None,
    true,
    interactive,
    (ctx, field) => nonempty(ctx.get_uints(field)),
    write_array,
  )
}

///|
/// Defines a scalar 64-bit unsigned integer option.
pub fn uint64(
  name : String,
  short~ : Char = '\u0000',
  description~ : String = "",
  env? : String,
  config? : String,
  required~ : Bool = false,
  default~ : UInt64? = None,
  interactive? : FieldEditor[UInt64],
) -> OptionDef[UInt64] {
  option_def(
    name,
    config,
    UInt64Opt,
    short,
    description,
    env,
    default is None && required,
    default.map(fn(value) { value.to_string() }),
    false,
    interactive,
    Context::get_uint64,
    write_scalar,
  )
}

///|
/// Defines a repeated 64-bit unsigned integer option.
pub fn uint64s(
  name : String,
  short~ : Char = '\u0000',
  description~ : String = "",
  env? : String,
  config? : String,
  required~ : Bool = false,
  interactive? : FieldEditor[Array[UInt64]],
) -> OptionDef[Array[UInt64]] {
  option_def(
    name,
    config,
    UInt64Opt,
    short,
    description,
    env,
    required,
    None,
    true,
    interactive,
    (ctx, field) => nonempty(ctx.get_uint64s(field)),
    write_array,
  )
}

///|
/// Defines a scalar double-precision floating-point option.
pub fn double(
  name : String,
  short~ : Char = '\u0000',
  description~ : String = "",
  env? : String,
  config? : String,
  required~ : Bool = false,
  default~ : Double? = None,
  interactive? : FieldEditor[Double],
) -> OptionDef[Double] {
  option_def(
    name,
    config,
    DoubleOpt,
    short,
    description,
    env,
    default is None && required,
    default.map(fn(value) { value.to_string() }),
    false,
    interactive,
    Context::get_double,
    write_scalar,
  )
}

///|
/// Defines a repeated double-precision floating-point option.
pub fn doubles(
  name : String,
  short~ : Char = '\u0000',
  description~ : String = "",
  env? : String,
  config? : String,
  required~ : Bool = false,
  interactive? : FieldEditor[Array[Double]],
) -> OptionDef[Array[Double]] {
  option_def(
    name,
    config,
    DoubleOpt,
    short,
    description,
    env,
    required,
    None,
    true,
    interactive,
    (ctx, field) => nonempty(ctx.get_doubles(field)),
    write_array,
  )
}
