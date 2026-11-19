///|
/// Edits one field. The read-only context exposes other already resolved fields.
/// Return `None` to retain the current value, or raise an error to stop execution.
/// A component needs no terminal and can run on any target supported by its host.
pub type FieldEditor[T] = @interactive.Editor[Context, T]

///|
priv struct FieldEdit {
  apply : async (Context, Bool) -> Context
}

///|
impl Debug for FieldEdit with fn to_repr(_) {
  @debug.Repr::literal("<field editor>")
}

///|
fn[T, M] field_edit(
  field : ArgDef[T, M],
  editor : FieldEditor[T]?,
  read : (Context, ArgDef[T, M]) -> T? raise,
  write : (Context, String, T, Bool) -> Context,
  required : Bool,
) -> FieldEdit? {
  guard editor is Some(edit) else { return None }
  Some({
    apply: (ctx, global) => {
      let initial = read(ctx, field)
      let updated = match edit(ctx, initial) {
        Some(value) => write(ctx, field.name, value, global)
        None => ctx
      }
      if required && read(updated, field) is None {
        fail("missing required argument: " + field.name)
      }
      updated
    },
  })
}

///|
fn[T] nonempty(values : ReadOnlyArray[T]) -> Array[T]? {
  if values.is_empty() {
    None
  } else {
    Some(values.iter().to_array())
  }
}

///|
fn write_string(
  ctx : Context,
  name : String,
  value : String,
  global : Bool,
) -> Context {
  write_items(ctx, name, [value], global)
}

///|
fn write_strings(
  ctx : Context,
  name : String,
  values : Array[String],
  global : Bool,
) -> Context {
  write_items(ctx, name, values, global)
}

///|
fn[T : Show] write_scalar(
  ctx : Context,
  name : String,
  value : T,
  global : Bool,
) -> Context {
  write_items(ctx, name, [value.to_string()], global)
}

///|
fn[T : Show] write_array(
  ctx : Context,
  name : String,
  values : Array[T],
  global : Bool,
) -> Context {
  write_items(ctx, name, values.map(value => value.to_string()), global)
}

///|
fn write_items(
  ctx : Context,
  name : String,
  items : Array[String],
  global : Bool,
) -> Context {
  let subcommand = if global {
    ctx.subcommand.map(sub => {
      let (command, child) = sub
      (command, write_items(child, name, items, true))
    })
  } else {
    ctx.subcommand
  }
  Context::{
    ..ctx,
    interactive_values: ctx.interactive_values.add(
      name,
      ReadOnlyArray::from_array(items),
    ),
    subcommand,
  }
}

///|
fn write_flag(
  ctx : Context,
  name : String,
  value : Bool,
  global : Bool,
) -> Context {
  let subcommand = if global {
    ctx.subcommand.map(sub => {
      let (command, child) = sub
      (command, write_flag(child, name, value, true))
    })
  } else {
    ctx.subcommand
  }
  Context::{
    ..ctx,
    interactive_flags: ctx.interactive_flags.add(name, value),
    subcommand,
  }
}
