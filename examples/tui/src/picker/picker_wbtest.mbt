///|
test "non-terminal picker resolves a unique query without replacing an explicit project" {
  assert_true(resolve_without_terminal(None, "LENS") is Some("lens"))
  assert_true(resolve_without_terminal(Some("admiral"), "lens") is None)
  assert_true(resolve_without_terminal(None, "") is None)
}

///|
test "non-terminal picker reports absent and ambiguous matches" {
  let absent = Ok(resolve_without_terminal(None, "not-a-project")) catch {
    err => Err(err)
  }
  assert_true(absent is Err(NoProjectMatch("not-a-project")))
  let ambiguous = Ok(resolve_without_terminal(None, "sdk")) catch {
    err => Err(err)
  }
  assert_true(ambiguous is Err(AmbiguousProjectQuery("sdk")))
}
