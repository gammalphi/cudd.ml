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


/* This assume a single static manager. Maybe we should not.  A
   possibility is to use a generative functor, where each call would
   create a distinct manager, and where it is impossible to use
   variables of different managers. */
// static DdManager *manager = NULL;

typedef DdNode* bdd_t;
typedef DdManager* manager_t;

/* Do we need this wrapper? Not sure. */
struct bdd_wrapper {
  bdd_t ptr;
  manager_t manager;
};

#define Bddwrapper_val(v) ((struct bdd_wrapper *)Data_custom_val(v))
#define Bdd_val(v) (Bddwrapper_val(v)->ptr)

static value Val_manager(manager_t manager) {
  assert(((intptr_t) manager & 1) == 0);
  return Val_long((intptr_t) manager >> 1);
}

static manager_t manager_Val(value v) {
  return (manager_t) (Long_val(v) << 1);
}


static void bdd_finalize(value v) {
  struct bdd_wrapper *w = Bddwrapper_val(v);
  assert(w->ptr != NULL);
  Cudd_RecursiveDeref(w->manager, w->ptr);
  w->ptr = NULL;		/* For debugging only. */
}

static struct custom_operations bdd_ops = {
    "cudd.bdd",
    bdd_finalize,
    custom_compare_default, custom_hash_default, custom_serialize_default,
    custom_deserialize_default};

value caml_cudd_init(value unit) {
  CAMLparam1(unit);
  manager_t ret = Cudd_Init(0, 0, CUDD_UNIQUE_SLOTS, CUDD_CACHE_SLOTS, 0);
  CAMLreturn(Val_manager(ret));
}

CAMLprim value caml_cudd_quit(value man) {
  CAMLparam1(man);
  manager_t manager = manager_Val(man);
  if (manager != NULL) {
    Cudd_Quit(manager);
    manager = NULL;
  }
  CAMLreturn(Val_unit);
}


static value alloc_bdd(manager_t manager, bdd_t node) {
  value block = caml_alloc_custom(&bdd_ops, sizeof(struct bdd_wrapper), 0, 1);
  struct bdd_wrapper *w = Bddwrapper_val(block);
  w->ptr = node;
  w->manager = manager;
  return block;
}

CAMLprim value caml_cudd_bdd_true(value man) {
  CAMLparam1(man);
  manager_t manager = manager_Val(man);
  bdd_t node = Cudd_ReadOne(manager);
  Cudd_Ref(node);
  CAMLreturn(alloc_bdd(manager,node));
}

CAMLprim value caml_cudd_bdd_false(value man) {
  CAMLparam1(man);
  manager_t manager = manager_Val(man);
  bdd_t node = Cudd_ReadLogicZero(manager);
  Cudd_Ref(node);
  CAMLreturn(alloc_bdd(manager,node));
}

CAMLprim value caml_cudd_bdd_var(value man, value vidx) {
  CAMLparam2(man,vidx);
  manager_t manager = manager_Val(man);
  int idx = Int_val(vidx);
  bdd_t node = Cudd_bddIthVar(manager, idx);
  Cudd_Ref(node);
  CAMLreturn(alloc_bdd(manager,node));
}
CAMLprim value caml_cudd_bdd_newvar(value man) {
  CAMLparam1(man);
  manager_t manager = manager_Val(man);
  bdd_t node = Cudd_bddNewVar(manager);
  Cudd_Ref(node);
  CAMLreturn(alloc_bdd(manager,node));
}

CAMLprim value caml_cudd_bdd_and(value man, value vbdd1, value vbdd2) {
  CAMLparam3(man,vbdd1, vbdd2);
  manager_t manager = manager_Val(man);
  bdd_t b1 = Bdd_val(vbdd1);
  bdd_t b2 = Bdd_val(vbdd2);
  bdd_t res = Cudd_bddAnd(manager, b1, b2);
  Cudd_Ref(res);
  CAMLreturn(alloc_bdd(manager,res));
}

CAMLprim value caml_cudd_bdd_or(value man, value vbdd1, value vbdd2) {
  CAMLparam3(man,vbdd1, vbdd2);
  manager_t manager = manager_Val(man);
  bdd_t b1 = Bdd_val(vbdd1);
  bdd_t b2 = Bdd_val(vbdd2);
  bdd_t res = Cudd_bddOr(manager, b1, b2);
  Cudd_Ref(res);
  CAMLreturn(alloc_bdd(manager,res));
}

CAMLprim value caml_cudd_bdd_not(value man, value vbdd) {
  CAMLparam2(man,vbdd);
  manager_t manager = manager_Val(man);
  bdd_t b = Bdd_val(vbdd);
  bdd_t res = Cudd_Not(b);
  Cudd_Ref(res);
  CAMLreturn(alloc_bdd(manager, res));
}

CAMLprim value caml_cudd_bdd_is_equal(value vbdd1, value vbdd2) {
  CAMLparam2(vbdd1, vbdd2);
  bdd_t b1 = Bdd_val(vbdd1);
  bdd_t b2 = Bdd_val(vbdd2);
  _Bool res = b1 == b2;
  CAMLreturn(Val_int(res));
}

CAMLprim value caml_cudd_bdd_leq(value man, value vbdd1, value vbdd2) {
  CAMLparam3(man,vbdd1, vbdd2);
  manager_t manager = manager_Val(man);
  bdd_t b1 = Bdd_val(vbdd1);
  bdd_t b2 = Bdd_val(vbdd2);
  int res = Cudd_bddLeq(manager, b1, b2);
  CAMLreturn(Val_int(res));
}

CAMLprim value caml_cudd_bdd_inspect(value man, value vbdd) {
  CAMLparam2(man,vbdd);
  manager_t manager = manager_Val(man);
  CAMLlocal3(vres, vthen, velse);
  bdd_t v = Bdd_val(vbdd);
  if (Cudd_IsConstant(v)) {
    vres = caml_alloc_small(1, 0);
    if (v == Cudd_ReadOne(manager)) {
      Field(vres, 0) = Val_true;
    } else
      Field(vres, 0) = Val_false;
  } else {
    bdd_t th, el;
    th = Cudd_T(v);
    el = Cudd_T(v);
    int i = Cudd_NodeReadIndex(v);
    vres = caml_alloc_small(3, 1);
    Field(vres, 0) = Val_int(i);
    Field(vres, 1) = alloc_bdd(manager,th);
    Field(vres, 2) = alloc_bdd(manager,el);
  }
  CAMLreturn(vres);
}

CAMLprim value caml_cudd_print(value man, value v) {
  CAMLparam2(man,v);
  manager_t manager = manager_Val(man);
  bdd_t b = Bdd_val(v);
  fflush(stdout);
  Cudd_PrintMinterm(manager, b);
  fflush(stdout);
  CAMLreturn(Val_unit);
}

