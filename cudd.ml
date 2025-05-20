type bdd
type 'a bdd_result = Bool of bool | Ifte of int * bdd * bdd

external init : unit -> unit = "caml_cudd_init"
external quit : unit -> unit = "caml_cudd_quit"
external bdd_true : unit -> bdd = "caml_cudd_bdd_true"
external bdd_false : unit -> bdd = "caml_cudd_bdd_false"
external bdd_var : int -> bdd = "caml_cudd_bdd_var"
external bdd_and : bdd -> bdd -> bdd = "caml_cudd_bdd_and"
external bdd_or : bdd -> bdd -> bdd = "caml_cudd_bdd_or"
external bdd_not : bdd -> bdd = "caml_cudd_bdd_not"

external bdd_is_equal : bdd -> bdd -> bool = "caml_cudd_bdd_is_equal"
[@@noalloc]

external bdd_is_included_in : bdd -> bdd -> bool = "caml_cudd_bdd_leq"

(*TODO: do this properly*)
let bdd_is_true b = bdd_is_equal b (bdd_true ())
let bdd_is_false b = bdd_is_equal b (bdd_false ())
let bdd_is_inter_empty b1 b2 = bdd_is_included_in b1 (bdd_not b2)
let () = at_exit quit
