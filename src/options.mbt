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
  interactive : Bool,
) -> OptionDef[T] {
  {
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
      interactive,
    },
  }
}

///|
/// Defines a scalar string option. Set `required` when the command must receive
/// a value and `default` when a fallback should be used. `env` and `config`
/// select independent environment and configuration keys.
pub fn string(
  name : String,
  short? : Char = '\u0000',
  description? : String = "",
  env? : String,
  config? : String,
  required? : Bool = false,
  default? : String? = None,
  interactive? : Bool = false,
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
  )
}

///|
/// Defines a repeated string option. Values are returned by
/// `Context::get_strings`; configuration values must be JSON arrays.
pub fn strings(
  name : String,
  short? : Char = '\u0000',
  description? : String = "",
  env? : String,
  config? : String,
  required? : Bool = false,
  interactive? : Bool = false,
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
  )
}

///|
/// Defines a boolean flag. An omitted flag resolves to `false`; environment
/// values use the boolean literals accepted by `core/argparse`.
pub fn bool(
  name : String,
  short? : Char = '\u0000',
  description? : String = "",
  env? : String,
  config? : String,
  interactive? : Bool = false,
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
  )
}

///|
/// Defines a scalar signed integer option with optional defaults and required
/// validation.
pub fn int(
  name : String,
  short? : Char = '\u0000',
  description? : String = "",
  env? : String,
  config? : String,
  required? : Bool = false,
  default? : Int? = None,
  interactive? : Bool = false,
) -> OptionDef[Int] {
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
  )
}

///|
/// Defines a repeated signed integer option. Use `Context::get_ints` to read
/// all values after parsing.
pub fn ints(
  name : String,
  short? : Char = '\u0000',
  description? : String = "",
  env? : String,
  config? : String,
  required? : Bool = false,
  interactive? : Bool = false,
) -> OptionDef[Array[Int]] {
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
  )
}

///|
/// Defines a scalar 64-bit signed integer option.
pub fn int64(
  name : String,
  short? : Char = '\u0000',
  description? : String = "",
  env? : String,
  config? : String,
  required? : Bool = false,
  default? : Int64? = None,
  interactive? : Bool = false,
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
  )
}

///|
/// Defines a repeated 64-bit signed integer option.
pub fn int64s(
  name : String,
  short? : Char = '\u0000',
  description? : String = "",
  env? : String,
  config? : String,
  required? : Bool = false,
  interactive? : Bool = false,
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
  )
}

///|
/// Defines a scalar unsigned integer option.
pub fn uint(
  name : String,
  short? : Char = '\u0000',
  description? : String = "",
  env? : String,
  config? : String,
  required? : Bool = false,
  default? : UInt? = None,
  interactive? : Bool = false,
) -> OptionDef[UInt] {
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
  )
}

///|
/// Defines a repeated unsigned integer option.
pub fn uints(
  name : String,
  short? : Char = '\u0000',
  description? : String = "",
  env? : String,
  config? : String,
  required? : Bool = false,
  interactive? : Bool = false,
) -> OptionDef[Array[UInt]] {
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
  )
}

///|
/// Defines a scalar 64-bit unsigned integer option.
pub fn uint64(
  name : String,
  short? : Char = '\u0000',
  description? : String = "",
  env? : String,
  config? : String,
  required? : Bool = false,
  default? : UInt64? = None,
  interactive? : Bool = false,
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
  )
}

///|
/// Defines a repeated 64-bit unsigned integer option.
pub fn uint64s(
  name : String,
  short? : Char = '\u0000',
  description? : String = "",
  env? : String,
  config? : String,
  required? : Bool = false,
  interactive? : Bool = false,
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
  )
}

///|
/// Defines a scalar double-precision floating-point option.
pub fn double(
  name : String,
  short? : Char = '\u0000',
  description? : String = "",
  env? : String,
  config? : String,
  required? : Bool = false,
  default? : Double? = None,
  interactive? : Bool = false,
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
  )
}

///|
/// Defines a repeated double-precision floating-point option.
pub fn doubles(
  name : String,
  short? : Char = '\u0000',
  description? : String = "",
  env? : String,
  config? : String,
  required? : Bool = false,
  interactive? : Bool = false,
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
  )
}
