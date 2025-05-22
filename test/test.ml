module C = Cudd.Bdd ()

let () =
  let x = C.var 0 in
  let y = C.var 1 in
  let not_x = C.not_ x in
  let not_y = C.not_ y in
  let not_x_and_not_y = C.and_ not_x not_y in
  let not_not_x_and_not_y = C.not_ not_x_and_not_y in
  let y_or_x = C.or_ y x in
  assert (C.is_equal not_not_x_and_not_y y_or_x);
  assert (not @@ C.is_equal not_x_and_not_y y_or_x);
  assert (C.is_equal x (C.or_ (C.and_ x not_y) (C.and_ x y)));
  for _ = 0 to 100000 do
    let _ = C.not_ x in
    ()
  done;
  Printf.printf "All tests done.\n"
