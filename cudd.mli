type bdd

module Bdd () : sig
  type result = Bool of bool | Ifte of int * bdd * bdd

  (* val init : unit -> unit *)
  val quit : unit -> unit
  val true_ : unit -> bdd
  val false_ : unit -> bdd
  val not_ : bdd -> bdd
  val and_ : bdd -> bdd -> bdd
  val or_ : bdd -> bdd -> bdd
  val var : int -> bdd
  val newvar : unit -> bdd
  val is_equal : bdd -> bdd -> bool
  val is_false : bdd -> bool
  val is_true : bdd -> bool
  val is_inter_empty : bdd -> bdd -> bool
  val is_included_in : bdd -> bdd -> bool
  val inspect : bdd -> result

  val print :
    (Format.formatter -> int -> unit) -> Format.formatter -> bdd -> unit
end
