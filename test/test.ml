(**************************************************************************)
(*  This file is part of the Codex semantics library.                     *)
(*                                                                        *)
(*  Copyright (C) 2013-2025                                               *)
(*    CEA (Commissariat à l'énergie atomique et aux énergies              *)
(*         alternatives)                                                  *)
(*                                                                        *)
(*  you can redistribute it and/or modify it under the terms of the GNU   *)
(*  Lesser General Public License as published by the Free Software       *)
(*  Foundation, version 2.1.                                              *)
(*                                                                        *)
(*  It is distributed in the hope that it will be useful,                 *)
(*  but WITHOUT ANY WARRANTY; without even the implied warranty of        *)
(*  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *)
(*  GNU Lesser General Public License for more details.                   *)
(*                                                                        *)
(*  See the GNU Lesser General Public License version 2.1                 *)
(*  for more details (enclosed in the file LICENSE).                      *)
(*                                                                        *)
(**************************************************************************)

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
  assert (C.is_equal x (C.not_ @@ C.not_ x));
  Format.printf "\nTEST3 OK\n%!"

let test4 () =
  let l = List.init 10000 C.var in
  let a = l |> List.fold_left C.and_ (C.true_ ()) |> C.not_
  and b = l |> List.fold_left (fun s x -> C.or_ s (C.not_ x)) (C.false_ ()) in
  assert (C.is_equal a b);
  assert (evaluate a == evaluate b);
  (* ignore @@ evaluate @@ C.not_ x; *)
  Format.printf "\nTEST4 OK\n%!"

(* BDDs as keys of the polymorphic Hashtbl: needs a hash that tells
   BDDs apart and a compare on the custom block. *)
let test5 () =
  let l = List.init 1000 C.var in
  let hashes = List.sort_uniq Int.compare (List.map Hashtbl.hash l) in
  assert (List.length hashes > 900);
  let h = Hashtbl.create 17 in
  List.iteri (fun i x -> Hashtbl.replace h x i) l;
  List.iteri (fun i x -> assert (Hashtbl.find h (C.not_ (C.not_ x)) = i)) l;
  Format.printf "\nTEST5 OK\n%!"

let () =
  test1 ();
  test2 ();
  test3 ();
  test4 ();
  test5 ();
  Printf.printf "All tests done.\n"
