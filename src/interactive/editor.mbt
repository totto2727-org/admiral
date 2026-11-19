///|
/// An async editor for one field, with its read context and current value.
/// Return `None` to retain the current value, or raise to stop the command.
pub type Editor[Context, T] = async (Context, T?) -> T?

///|
/// Adapts an editor that only needs the current field value.
pub fn[Context, T] from_value(edit : async (T?) -> T?) -> Editor[Context, T] {
  (_, value) => edit(value)
}
