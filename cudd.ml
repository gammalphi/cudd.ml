type man
type bdd

external init : unit -> man = "caml_cudd_init"
external quit : man -> unit = "caml_cudd_quit"
external bdd_true : man -> bdd = "caml_cudd_bdd_true"
external bdd_false : man -> bdd = "caml_cudd_bdd_false"
external bdd_var : man -> int -> bdd = "caml_cudd_bdd_var"
external bdd_newvar : man -> bdd = "caml_cudd_bdd_var"
external bdd_and : man -> bdd -> bdd -> bdd = "caml_cudd_bdd_and"
external bdd_or : man -> bdd -> bdd -> bdd = "caml_cudd_bdd_or"
external bdd_not : man -> bdd -> bdd = "caml_cudd_bdd_not"

external bdd_is_equal : bdd -> bdd -> bool = "caml_cudd_bdd_is_equal"
[@@noalloc]

external bdd_leq : man -> bdd -> bdd -> bool = "caml_cudd_bdd_not" [@@noalloc]
(* external bdd_is_included_in : bdd -> bdd -> bool = "caml_cudd_bdd_leq" *)
(* external bdd_print : man -> bdd -> unit = "caml_cudd_bdd_print" *)

module Bdd () = struct
  type t = bdd
  type result = Bool of bool | Ifte of int * t * t

  external bdd_inspect : man -> bdd -> result = "caml_cudd_bdd_inspect"

  let man = init ()
  let quit () = quit man
  let bdd_true () = bdd_true man
  let bdd_false () = bdd_false man
  let bdd_not = bdd_not man
  let bdd_and = bdd_and man
  let bdd_or = bdd_or man
  let bdd_var = bdd_var man
  let bdd_newvar () = bdd_newvar man
  let bdd_is_equal = bdd_is_equal
  let bdd_is_included_in = bdd_leq man
  let bdd_inspect = bdd_inspect man

  (*TODO: do this properly*)
  let bdd_is_true b = bdd_is_equal b (bdd_true ())
  let bdd_is_false b = bdd_is_equal b (bdd_false ())
  let bdd_is_inter_empty b1 b2 = bdd_is_included_in b1 (bdd_not b2)

  let rec bdd_print print_id fmt b =
    match bdd_inspect b with
    | Bool _ -> ()
    | Ifte (x, b1, b2) ->
        Format.fprintf fmt "ITE(@[<hv>%a;@,%a;@,%a)@])" print_id x
          (bdd_print print_id) b1 (bdd_print print_id) b2

  let () = at_exit quit
end
