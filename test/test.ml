module C = Cudd.Bdd ()

let test1() =   
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
    (C.print Format.pp_print_int) x
    (C.print Format.pp_print_int) y
    (C.print Format.pp_print_int) y_or_x
;;



let test2() =
  let x = C.var 0 in
  for _ = 0 to 100000 do
    let _ = C.not_ x in
    ()
  done
;;

let test3() = 
  let x =
    List.init 1000 (fun _ -> C.newvar ()) |> List.fold_left C.and_ (C.newvar ())
  in
  let _ = C.not_ x in
  ()
;;

let () =
  test1();
  test2();
  test3();
  Printf.printf "All tests done.\n"
