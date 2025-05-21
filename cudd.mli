module Bdd () : sig
  type t
  type 'a result = Bool of bool | Ifte of int * t * t

  (* val init : unit -> unit *)
  val quit : unit -> unit
  val bdd_true : unit -> t
  val bdd_false : unit -> t
  val bdd_not : t -> t
  val bdd_and : t -> t -> t
  val bdd_or : t -> t -> t
  val bdd_var : int -> t
  val bdd_is_equal : t -> t -> bool
  val bdd_is_false : t -> bool
  val bdd_is_true : t -> bool
  val bdd_is_inter_empty : t -> t -> bool
  (* val bdd_is_included_in : t -> t -> bool *)
end
