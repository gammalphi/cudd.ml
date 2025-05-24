[@@@warning "-32"]

module C = Cudd.Bdd ()

let test1 () =
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
  Format.printf "x=%a@\ny=%a@\ny_or_x=%a@."
    (C.print Format.pp_print_int)
    x
    (C.print Format.pp_print_int)
    y
    (C.print Format.pp_print_int)
    y_or_x;
  Format.printf "\nTEST1 OK\n%!"

let rec evaluate bdd =
  match C.inspect bdd with
  | C.True -> true
  | C.False -> false
  | Ifte (_, x, y) -> evaluate x && evaluate y

let test2 () =
  let x = C.var 0 in
  for _ = 0 to 100000 do
    ignore @@ C.not_ x
  done;
  Format.printf "\nTEST2 OK\n%!"

let test3 () =
  let x =
    List.init 10000 (fun _ -> C.newvar ())
    |> List.fold_left C.and_ (C.newvar ())
  in
  ignore @@ evaluate @@ C.not_ x;
  Format.printf "\nTEST3 OK\n%!"

let test4 () =
  let x = List.init 10000 C.var |> List.fold_left C.and_ (C.newvar ()) in
  ignore @@ evaluate @@ C.not_ x;
  Format.printf "\nTEST4 OK\n%!"

let () =
  test1 ();
  test2 ();
  test3 ();
  test4 ();
  Printf.printf "All tests done.\n"
