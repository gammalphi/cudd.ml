type bdd

val init : unit -> unit
val quit : unit -> unit
val bdd_true : unit -> bdd
val bdd_false : unit -> bdd
val bdd_not : bdd -> bdd
val bdd_and : bdd -> bdd -> bdd
val bdd_or : bdd -> bdd -> bdd
val bdd_var : int -> bdd
val bdd_equal : bdd -> bdd -> bool
(* val bdd_is_inter_empty : bdd -> bdd -> bool *)

