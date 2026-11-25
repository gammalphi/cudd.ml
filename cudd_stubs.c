/**************************************************************************/
/*  This file is part of the Codex semantics library.                     */
/*                                                                        */
/*  Copyright (C) 2013-2025                                               */
/*    CEA (Commissariat à l'énergie atomique et aux énergies              */
/*         alternatives)                                                  */
/*                                                                        */
/*  you can redistribute it and/or modify it under the terms of the GNU   */
/*  Lesser General Public License as published by the Free Software       */
/*  Foundation, version 2.1.                                              */
/*                                                                        */
/*  It is distributed in the hope that it will be useful,                 */
/*  but WITHOUT ANY WARRANTY; without even the implied warranty of        */
/*  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         */
/*  GNU Lesser General Public License for more details.                   */
/*                                                                        */
/*  See the GNU Lesser General Public License version 2.1                 */
/*  for more details (enclosed in the file LICENSE).                      */
/*                                                                        */
/**************************************************************************/

#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <cudd.h>

#include "caml/alloc.h"
#include "caml/callback.h"
#include "caml/custom.h"
#include "caml/fail.h"
#include "caml/memory.h"
#include "caml/mlvalues.h"

#include <assert.h>


typedef DdNode* bdd_t;
typedef DdManager* manager_t;

struct manager_wrapper {
  manager_t manager;
};

struct bdd_wrapper {
  bdd_t ptr;
  manager_t manager;
};

#define Manager_val(v) (((struct manager_wrapper *)Data_custom_val(v))->manager)
#define Bddwrapper_val(v) ((struct bdd_wrapper *)Data_custom_val(v))
#define Bdd_val(v) (Bddwrapper_val(v)->ptr)

static void finalize_manager(value v) {
  manager_t m = Manager_val(v);
  if (m != NULL) {
    Cudd_Quit(m);
  }
}

static struct custom_operations manager_ops = {
    "cudd.manager",
    finalize_manager,
    custom_compare_default,
    custom_hash_default,
    custom_serialize_default,
    custom_deserialize_default
};
static void bdd_finalize(value v) {
  struct bdd_wrapper *w = Bddwrapper_val(v);
  if (w->ptr != NULL) {
    Cudd_RecursiveDeref(w->manager, w->ptr);
    w->ptr = NULL;
  }
}

/* BDDs are hash-consed by CUDD: two BDDs of a manager are equal iff they
   are the same node pointer (complement bit included). */

/* The low bits of a node address are constant (alignment): mix them in. */
static inline intnat bdd_hash(bdd_t b) {
  uint64_t h = (uint64_t)(uintptr_t)b;
  h ^= h >> 30;
  h *= 0xbf58476d1ce4e5b9ULL;
  h ^= h >> 27;
  h *= 0x94d049bb133111ebULL;
  h ^= h >> 31;
  return (intnat)h;
}

static inline int bdd_compare(bdd_t b1, bdd_t b2) {
  return (b1 > b2) - (b1 < b2);
}

static int bdd_custom_compare(value v1, value v2) {
  return bdd_compare(Bdd_val(v1), Bdd_val(v2));
}

static intnat bdd_custom_hash(value v) { return bdd_hash(Bdd_val(v)); }

static struct custom_operations bdd_ops = {
    "cudd.bdd",
    bdd_finalize,
    bdd_custom_compare,
    bdd_custom_hash,
    custom_serialize_default,
    custom_deserialize_default
};

///////////////////////////////////////////////////


static value alloc_manager(manager_t m) {
  CAMLparam0();
  CAMLlocal1(v);
  v = caml_alloc_custom(&manager_ops, sizeof(struct manager_wrapper), 0, 1);
  ((struct manager_wrapper *)Data_custom_val(v))->manager = m;
  CAMLreturn(v);
}



static value alloc_bdd(manager_t manager, bdd_t node) {
  CAMLparam0();
  CAMLlocal1(block);
  block = caml_alloc_custom(&bdd_ops, sizeof(struct bdd_wrapper), 0, 1);
  struct bdd_wrapper *w = Bddwrapper_val(block);
  w->ptr = node;
  w->manager = manager;
  CAMLreturn(block);
}


///////////////////////////////////////////////////

CAMLprim value caml_cudd_init(value unit) {
  CAMLparam1(unit);
  manager_t m = Cudd_Init(0, 0, CUDD_UNIQUE_SLOTS, CUDD_CACHE_SLOTS, 0);
  CAMLreturn(alloc_manager(m));
}

CAMLprim value caml_cudd_bdd_true(value man) {
  CAMLparam1(man);
  manager_t manager = Manager_val(man);
  bdd_t node = Cudd_ReadOne(manager);
  Cudd_Ref(node);
  CAMLreturn(alloc_bdd(manager, node));
}

CAMLprim value caml_cudd_bdd_false(value man) {
  CAMLparam1(man);
  manager_t manager = Manager_val(man);
  bdd_t node = Cudd_ReadLogicZero(manager);
  Cudd_Ref(node);
  CAMLreturn(alloc_bdd(manager, node));
}

CAMLprim value caml_cudd_bdd_var(value man, value vidx) {
  CAMLparam2(man, vidx);
  manager_t manager = Manager_val(man);
  int idx = Int_val(vidx);
  bdd_t node = Cudd_bddIthVar(manager, idx);
  Cudd_Ref(node);
  CAMLreturn(alloc_bdd(manager, node));
}

CAMLprim value caml_cudd_bdd_newvar(value man) {
  CAMLparam1(man);
  manager_t manager = Manager_val(man);
  bdd_t node = Cudd_bddNewVar(manager);
  Cudd_Ref(node);
  CAMLreturn(alloc_bdd(manager, node));
}

#define ar2_bdd_bdd_bdd(name) \
  CAMLprim value caml_##name(value man, value vbdd1, value vbdd2) { \
    CAMLparam3(man, vbdd1, vbdd2); \
    manager_t manager = Manager_val(man); \
    bdd_t b1 = Bdd_val(vbdd1); \
    bdd_t b2 = Bdd_val(vbdd2); \
    bdd_t res = name(manager, b1, b2); \
    Cudd_Ref(res); \
    CAMLreturn(alloc_bdd(manager, res)); \
  }

ar2_bdd_bdd_bdd(Cudd_bddAnd)
ar2_bdd_bdd_bdd(Cudd_bddOr)

CAMLprim value caml_cudd_bdd_not(value man, value vbdd) {
  CAMLparam2(man, vbdd);
  manager_t manager = Manager_val(man);
  bdd_t b = Bdd_val(vbdd);
  bdd_t res = Cudd_Not(b);
  Cudd_Ref(res);
  CAMLreturn(alloc_bdd(manager, res));
}

/* The following are [@@noalloc]. */
CAMLprim value caml_cudd_bdd_is_equal(value vbdd1, value vbdd2) {
  return Val_bool(Bdd_val(vbdd1) == Bdd_val(vbdd2));
}

CAMLprim value caml_cudd_bdd_compare(value vbdd1, value vbdd2) {
  return Val_int(bdd_compare(Bdd_val(vbdd1), Bdd_val(vbdd2)));
}

CAMLprim value caml_cudd_bdd_hash(value vbdd) {
  return Val_long(bdd_hash(Bdd_val(vbdd)));
}

CAMLprim value caml_cudd_bdd_leq(value man, value vbdd1, value vbdd2) {
  CAMLparam3(man, vbdd1, vbdd2);
  manager_t manager = Manager_val(man);
  int res = Cudd_bddLeq(manager, Bdd_val(vbdd1), Bdd_val(vbdd2));
  CAMLreturn(Val_bool(res));
}

CAMLprim value caml_cudd_bdd_is_inter_empty(value man, value vbdd1, value vbdd2) {
  manager_t manager = Manager_val(man);
  return Val_bool(Cudd_bddLeq(manager, Bdd_val(vbdd1), Cudd_Not(Bdd_val(vbdd2))));
}

CAMLprim value caml_cudd_bdd_inspect(value man, value vbdd) {
  CAMLparam2(man, vbdd);
  CAMLlocal3(vres, vthen, velse);
  manager_t manager = Manager_val(man);
  bdd_t v = Bdd_val(vbdd);
  if (Cudd_IsConstant(v)) {
    CAMLreturn(v == Cudd_ReadOne(manager) ? Val_true : Val_false);
  } else {
    bdd_t th = Cudd_T(v);
    bdd_t el = Cudd_E(v);
    if (Cudd_IsConstant(v)){
      th = Cudd_Not(th);
      el = Cudd_Not(th);
    }
    Cudd_Ref(th);
    Cudd_Ref(el);
    int i = Cudd_NodeReadIndex(v);
    vres = caml_alloc_small(3, 1);
    Field(vres, 0) = Val_int(i);
    Field(vres, 1) = alloc_bdd(manager, th);
    Field(vres, 2) = alloc_bdd(manager, el);
    CAMLreturn(vres);
  }
}

CAMLprim value caml_cudd_print(value man, value v) {
  CAMLparam2(man, v);
  manager_t manager = Manager_val(man);
  bdd_t b = Bdd_val(v);
  fflush(stdout);
  Cudd_PrintMinterm(manager, b);
  fflush(stdout);
  CAMLreturn(Val_unit);
}

