[@@@warnings "-27"]

type man
type bdd

external init : unit -> man = "caml_cudd_init"
external quit : man -> unit = "caml_cudd_quit"
external bdd_true : man -> bdd = "caml_cudd_bdd_true"
external bdd_false : man -> bdd = "caml_cudd_bdd_false"
external bdd_var : man -> int -> bdd = "caml_cudd_bdd_var"
external bdd_newvar : man -> bdd = "caml_cudd_bdd_newvar"
external bdd_and : man -> bdd -> bdd -> bdd = "caml_Cudd_bddAnd"
external bdd_or : man -> bdd -> bdd -> bdd = "caml_Cudd_bddOr"
external bdd_not : man -> bdd -> bdd = "caml_cudd_bdd_not"

external bdd_is_equal : bdd -> bdd -> bool = "caml_cudd_bdd_is_equal"
[@@noalloc]

external bdd_leq : man -> bdd -> bdd -> bool = "caml_cudd_bdd_not" [@@noalloc]
(* external bdd_is_included_in : bdd -> bdd -> bool = "caml_cudd_bdd_leq" *)
(* external bdd_print : man -> bdd -> unit = "caml_cudd_bdd_print" *)

module Bdd () = struct
  type t = bdd
  type result = False | True | Ifte of int * t * t

  external bdd_inspect : man -> bdd -> result = "caml_cudd_bdd_inspect"

  let man = init ()
  let quit () = quit man
  let true_ () = bdd_true man
  let false_ () = bdd_false man
  let not_ = bdd_not man
  let and_ = bdd_and man
  let or_ = bdd_or man
  let var _ =  assert false
  let newvar () = assert false
  let is_equal = bdd_is_equal
  let is_included_in = bdd_leq man
  let inspect = bdd_inspect man

  (*TODO: do this properly*)
  let is_true b = bdd_is_equal b (true_ ())
  let is_false b = bdd_is_equal b (false_ ())
  let is_inter_empty b1 b2 = is_included_in b1 (not_ b2)
  let rec print print_id fmt b = 
  match inspect b with
  | True -> Format.fprintf fmt "true"
  | False -> Format.fprintf fmt "false"
  | Ifte (x, b1, b2) ->
      Format.fprintf fmt "ITE(@[<hv>%a;@,%a;@,%a)@])" print_id x
        (print print_id) b1 (print print_id) b2

  let () = at_exit quit
end
