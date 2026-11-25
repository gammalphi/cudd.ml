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


type man
type bdd

external init : unit -> man = "caml_cudd_init"

(* external quit : man -> unit = "caml_cudd_quit" *)
external bdd_true : man -> bdd = "caml_cudd_bdd_true"
external bdd_false : man -> bdd = "caml_cudd_bdd_false"
external bdd_var : man -> int -> bdd = "caml_cudd_bdd_var"
external bdd_newvar : man -> bdd = "caml_cudd_bdd_newvar"
external bdd_and : man -> bdd -> bdd -> bdd = "caml_Cudd_bddAnd"
external bdd_or : man -> bdd -> bdd -> bdd = "caml_Cudd_bddOr"
external bdd_not : man -> bdd -> bdd = "caml_cudd_bdd_not"

external bdd_is_equal : bdd -> bdd -> bool = "caml_cudd_bdd_is_equal"
[@@noalloc]

external bdd_compare : bdd -> bdd -> int = "caml_cudd_bdd_compare" [@@noalloc]
external bdd_hash : bdd -> int = "caml_cudd_bdd_hash" [@@noalloc]

external bdd_leq : man -> bdd -> bdd -> bool = "caml_cudd_bdd_leq" [@@noalloc]
external bdd_is_inter_empty : man -> bdd -> bdd -> bool = "caml_cudd_bdd_is_inter_empty" [@@noalloc]

module Bdd () = struct
  type t = bdd
  type result = False | True | Ifte of int * t * t

  external bdd_inspect : man -> bdd -> result = "caml_cudd_bdd_inspect"

  let man = init ()
  let true_ () = bdd_true man
  let false_ () = bdd_false man
  let not_ = bdd_not man
  let and_ = bdd_and man
  let or_ = bdd_or man
  let var = bdd_var man
  let newvar () = bdd_newvar man
  let is_equal = bdd_is_equal
  let compare = bdd_compare
  let hash = bdd_hash
  let is_included_in = bdd_leq man
  let inspect = bdd_inspect man

  (*TODO: do this properly*)
  let is_true b = bdd_is_equal b (true_ ())
  let is_false b = bdd_is_equal b (false_ ())
  let is_inter_empty = bdd_is_inter_empty man

  let rec print print_id fmt b =
    match inspect b with
    | True -> Format.fprintf fmt "true"
    | False -> Format.fprintf fmt "false"
    | Ifte (x, b1, b2) ->
        Format.fprintf fmt "ITE(@[<hv>%a;@,%a;@,%a)@])" print_id x
          (print print_id) b1 (print print_id) b2

  (* let () = at_exit quit *)
end
