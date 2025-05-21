module C = Cudd.Init ()

let () =
  let x = C.bdd_var 0 in
  let y = C.bdd_var 1 in
  let not_x = C.bdd_not x in
  let not_y = C.bdd_not y in
  let not_x_and_not_y = C.bdd_and not_x not_y in
  let not_not_x_and_not_y = C.bdd_not not_x_and_not_y in
  let y_or_x = C.bdd_or y x in
  assert (C.bdd_is_equal not_not_x_and_not_y y_or_x);
  assert (not @@ C.bdd_is_equal not_x_and_not_y y_or_x);
  assert (C.bdd_is_equal x (C.bdd_or (C.bdd_and x not_y) (C.bdd_and x y)));
  Printf.printf "All tests done.\n"
