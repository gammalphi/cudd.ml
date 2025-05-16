let () =
  Cudd.init ();
  let x = Cudd.bdd_var 0 in
  let y = Cudd.bdd_var 1 in
  let not_x = Cudd.bdd_not x in
  let not_y = Cudd.bdd_not y in
  let not_x_and_not_y = Cudd.bdd_and not_x not_y in
  let not_not_x_and_not_y = Cudd.bdd_not not_x_and_not_y in
  let y_or_x = Cudd.bdd_or y x in
  assert (Cudd.bdd_is_equal not_not_x_and_not_y y_or_x);
  assert (not @@ Cudd.bdd_is_equal not_x_and_not_y y_or_x);
  assert (
    Cudd.bdd_is_equal x (Cudd.bdd_or (Cudd.bdd_and x not_y) (Cudd.bdd_and x y)));
  Printf.printf "All tests done.\n"
