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





type bdd

module Bdd () : sig
  type result = False | True | Ifte of int * bdd * bdd

  (* val init : unit -> unit *)
  (* val quit : unit -> unit *)
  val true_ : unit -> bdd
  val false_ : unit -> bdd
  val not_ : bdd -> bdd
  val and_ : bdd -> bdd -> bdd
  val or_ : bdd -> bdd -> bdd
  val var : int -> bdd
  val newvar : unit -> bdd
  val is_equal : bdd -> bdd -> bool

  val compare : bdd -> bdd -> int
  (** Total order on the BDDs of the manager (node addresses: not stable
      across runs). *)

  val hash : bdd -> int
  (** Compatible with [is_equal]; [Hashtbl.hash] also is. *)

  val is_false : bdd -> bool
  val is_true : bdd -> bool
  val is_inter_empty : bdd -> bdd -> bool
  val is_included_in : bdd -> bdd -> bool
  val inspect : bdd -> result

  val print :
    (Format.formatter -> int -> unit) -> Format.formatter -> bdd -> unit
end
