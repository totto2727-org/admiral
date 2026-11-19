///|
fn[T] position_def(
  name : String,
  config : String?,
  type_ : OptionType,
  description : String,
  required : Bool,
  multiple : Bool,
  interactive : FieldEditor[T]?,
  read : (Context, PositionDef[T]) -> T? raise,
  write : (Context, String, T, Bool) -> Context,
) -> PositionDef[T] {
  let field : PositionDef[T] = {
    name,
    config,
    metadata: {
      type_,
      description,
      required,
      multiple,
      interactive: interactive is Some(_),
    },
    editor: None,
  }
  { ..field, editor: field_edit(field, interactive, read, write, required), }
}

///|
/// Defines a scalar string positional argument. A required position can be
/// supplied by a configured value or a registered field editor.
pub fn position_string(
  name : String,
  description~ : String = "",
  config? : String,
  required~ : Bool = false,
  interactive? : FieldEditor[String],
) -> PositionDef[String] {
  position_def(
    name,
    config,
    StringOpt,
    description,
    required,
    false,
    interactive,
    (ctx, field) => ctx.get_string(field),
    write_string,
  )
}

///|
/// Defines a variadic string positional argument. Read all values with
/// `Context::get_strings`.
pub fn position_strings(
  name : String,
  description~ : String = "",
  config? : String,
  required~ : Bool = false,
  interactive? : FieldEditor[Array[String]],
) -> PositionDef[Array[String]] {
  position_def(
    name,
    config,
    StringOpt,
    description,
    required,
    true,
    interactive,
    (ctx, field) => nonempty(ctx.get_strings(field)),
    write_strings,
  )
}

///|
/// Defines a scalar signed integer positional argument.
pub fn position_int(
  name : String,
  description~ : String = "",
  config? : String,
  required~ : Bool = false,
  interactive? : FieldEditor[Int32],
) -> PositionDef[Int32] {
  position_def(
    name,
    config,
    IntOpt,
    description,
    required,
    false,
    interactive,
    Context::get_int,
    write_scalar,
  )
}

///|
/// Defines a variadic signed integer positional argument.
pub fn position_ints(
  name : String,
  description~ : String = "",
  config? : String,
  required~ : Bool = false,
  interactive? : FieldEditor[Array[Int32]],
) -> PositionDef[Array[Int32]] {
  position_def(
    name,
    config,
    IntOpt,
    description,
    required,
    true,
    interactive,
    (ctx, field) => nonempty(ctx.get_ints(field)),
    write_array,
  )
}

///|
/// Defines a scalar 64-bit signed integer positional argument.
pub fn position_int64(
  name : String,
  description~ : String = "",
  config? : String,
  required~ : Bool = false,
  interactive? : FieldEditor[Int64],
) -> PositionDef[Int64] {
  position_def(
    name,
    config,
    Int64Opt,
    description,
    required,
    false,
    interactive,
    Context::get_int64,
    write_scalar,
  )
}

///|
/// Defines a variadic 64-bit signed integer positional argument.
pub fn position_int64s(
  name : String,
  description~ : String = "",
  config? : String,
  required~ : Bool = false,
  interactive? : FieldEditor[Array[Int64]],
) -> PositionDef[Array[Int64]] {
  position_def(
    name,
    config,
    Int64Opt,
    description,
    required,
    true,
    interactive,
    (ctx, field) => nonempty(ctx.get_int64s(field)),
    write_array,
  )
}

///|
/// Defines a scalar unsigned integer positional argument.
pub fn position_uint(
  name : String,
  description~ : String = "",
  config? : String,
  required~ : Bool = false,
  interactive? : FieldEditor[UInt32],
) -> PositionDef[UInt32] {
  position_def(
    name,
    config,
    UIntOpt,
    description,
    required,
    false,
    interactive,
    Context::get_uint,
    write_scalar,
  )
}

///|
/// Defines a variadic unsigned integer positional argument.
pub fn position_uints(
  name : String,
  description~ : String = "",
  config? : String,
  required~ : Bool = false,
  interactive? : FieldEditor[Array[UInt32]],
) -> PositionDef[Array[UInt32]] {
  position_def(
    name,
    config,
    UIntOpt,
    description,
    required,
    true,
    interactive,
    (ctx, field) => nonempty(ctx.get_uints(field)),
    write_array,
  )
}

///|
/// Defines a scalar 64-bit unsigned integer positional argument.
pub fn position_uint64(
  name : String,
  description~ : String = "",
  config? : String,
  required~ : Bool = false,
  interactive? : FieldEditor[UInt64],
) -> PositionDef[UInt64] {
  position_def(
    name,
    config,
    UInt64Opt,
    description,
    required,
    false,
    interactive,
    Context::get_uint64,
    write_scalar,
  )
}

///|
/// Defines a variadic 64-bit unsigned integer positional argument.
pub fn position_uint64s(
  name : String,
  description~ : String = "",
  config? : String,
  required~ : Bool = false,
  interactive? : FieldEditor[Array[UInt64]],
) -> PositionDef[Array[UInt64]] {
  position_def(
    name,
    config,
    UInt64Opt,
    description,
    required,
    true,
    interactive,
    (ctx, field) => nonempty(ctx.get_uint64s(field)),
    write_array,
  )
}

///|
/// Defines a scalar double-precision floating-point positional argument.
pub fn position_double(
  name : String,
  description~ : String = "",
  config? : String,
  required~ : Bool = false,
  interactive? : FieldEditor[Double],
) -> PositionDef[Double] {
  position_def(
    name,
    config,
    DoubleOpt,
    description,
    required,
    false,
    interactive,
    Context::get_double,
    write_scalar,
  )
}

///|
/// Defines a variadic double-precision floating-point positional argument.
pub fn position_doubles(
  name : String,
  description~ : String = "",
  config? : String,
  required~ : Bool = false,
  interactive? : FieldEditor[Array[Double]],
) -> PositionDef[Array[Double]] {
  position_def(
    name,
    config,
    DoubleOpt,
    description,
    required,
    true,
    interactive,
    (ctx, field) => nonempty(ctx.get_doubles(field)),
    write_array,
  )
}
