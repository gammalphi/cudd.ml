type bdd

external init : unit -> unit = "caml_cudd_init"
external quit : unit -> unit = "caml_cudd_quit"
external bdd_true : unit -> bdd = "caml_cudd_bdd_true"
external bdd_false : unit -> bdd = "caml_cudd_bdd_false"
external bdd_var : int -> bdd = "caml_cudd_bdd_var"
external bdd_and : bdd -> bdd -> bdd = "caml_cudd_bdd_and"
external bdd_or : bdd -> bdd -> bdd = "caml_cudd_bdd_or"
external bdd_not : bdd -> bdd = "caml_cudd_bdd_not"
external bdd_equal : bdd -> bdd -> bool = "caml_cudd_bdd_equal"  

let () = at_exit quit
