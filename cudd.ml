type man
type bdd

external init : unit -> man = "caml_cudd_init"
external quit : man -> unit = "caml_cudd_quit"
external bdd_true : man -> bdd = "caml_cudd_bdd_true"
external bdd_false : man -> bdd = "caml_cudd_bdd_false"
external bdd_var : man -> int -> bdd = "caml_cudd_bdd_var"
external bdd_and : man -> bdd -> bdd -> bdd = "caml_cudd_bdd_and"
external bdd_or : man -> bdd -> bdd -> bdd = "caml_cudd_bdd_or"
external bdd_not : man -> bdd -> bdd = "caml_cudd_bdd_not"

module Init () = struct
  let man = init ()

  type 'a bdd_result = Bool of bool | Ifte of int * bdd * bdd

  external bdd_is_equal : bdd -> bdd -> bool = "caml_cudd_bdd_is_equal"
  [@@noalloc]

  external bdd_is_included_in : bdd -> bdd -> bool = "caml_cudd_bdd_leq"

  (*TODO: do this properly*)
  let bdd_is_true b = bdd_is_equal b (bdd_true man)
  let bdd_is_false b = bdd_is_equal b (bdd_false man)
  let bdd_is_inter_empty b1 b2 = bdd_is_included_in b1 (bdd_not man b2)
  let () = at_exit (fun () -> quit man)
end
