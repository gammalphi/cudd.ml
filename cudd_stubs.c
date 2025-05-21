#include "caml/alloc.h"
#include "caml/callback.h"
#include "caml/custom.h"
#include "caml/fail.h"
#include "caml/memory.h"
// #include "cudd/cudd.h"
#include <cudd.h>
#include <stdio.h>
#include <stdlib.h>

/* This assume a single static manager. Maybe we should not.  A
   possibility is to use a generative functor, where each call would
   create a distinct manager, and where it is impossible to use
   variables of different managers. */
// static DdManager *manager = NULL;

typedef DdNode *bdd_t;

/* Do we need this wrapper? Not sure. */
struct bdd_wrapper {
  bdd_t ptr;
};

#define Bddwrapper_val(v) ((struct bdd_wrapper *)Data_custom_val(v))
#define Bdd_val(v) (Bddwrapper_val(v)->ptr)

static void bdd_finalize(DdManager *manager, value v) {
  struct bdd_wrapper *w = Bddwrapper_val(v);
  if (w->ptr != NULL) {
    Cudd_RecursiveDeref(manager, w->ptr);
    w->ptr = NULL;
  }
}

static struct custom_operations bdd_ops = {
    "cudd.bdd",
    // bdd_finalize,
    custom_compare_default, custom_hash_default, custom_serialize_default,
    custom_deserialize_default};

struct DdManager *caml_cudd_init(value unit) {
  CAMLparam1(unit);
  return (Cudd_Init(0, 0, CUDD_UNIQUE_SLOTS, CUDD_CACHE_SLOTS, 0));
}

CAMLprim value caml_cudd_quit(DdManager *manager, value unit) {
  CAMLparam1(unit);
  if (manager != NULL) {
    Cudd_Quit(manager);
    manager = NULL;
  }
  CAMLreturn(Val_unit);
}

static value alloc_bdd(bdd_t node) {
  value block = caml_alloc_custom(&bdd_ops, sizeof(struct bdd_wrapper), 0, 1);
  struct bdd_wrapper *w = Bddwrapper_val(block);
  w->ptr = node;
  return block;
}

CAMLprim value caml_cudd_bdd_true(DdManager *manager, value unit) {
  CAMLparam1(unit);
  bdd_t node = Cudd_ReadOne(manager);
  Cudd_Ref(node);
  CAMLreturn(alloc_bdd(node));
}

CAMLprim value caml_cudd_bdd_false(DdManager *manager, value unit) {
  CAMLparam1(unit);
  bdd_t node = Cudd_ReadLogicZero(manager);
  Cudd_Ref(node);
  CAMLreturn(alloc_bdd(node));
}

CAMLprim value caml_cudd_bdd_var(DdManager *manager, value vidx) {
  CAMLparam1(vidx);
  int idx = Int_val(vidx);
  bdd_t node = Cudd_bddIthVar(manager, idx);
  Cudd_Ref(node);
  CAMLreturn(alloc_bdd(node));
}
CAMLprim value caml_cudd_bdd_newvar(DdManager *manager, value unit) {
  CAMLparam1(unit);
  bdd_t node = Cudd_bddNewVar(manager);
  Cudd_Ref(node);
  CAMLreturn(alloc_bdd(node));
}

CAMLprim value caml_cudd_bdd_and(DdManager *manager, value vbdd1, value vbdd2) {
  CAMLparam2(vbdd1, vbdd2);
  bdd_t b1 = Bdd_val(vbdd1);
  bdd_t b2 = Bdd_val(vbdd2);
  bdd_t res = Cudd_bddAnd(manager, b1, b2);
  Cudd_Ref(res);
  CAMLreturn(alloc_bdd(res));
}

CAMLprim value caml_cudd_bdd_or(DdManager *manager, value vbdd1, value vbdd2) {
  CAMLparam2(vbdd1, vbdd2);
  bdd_t b1 = Bdd_val(vbdd1);
  bdd_t b2 = Bdd_val(vbdd2);
  bdd_t res = Cudd_bddOr(manager, b1, b2);
  Cudd_Ref(res);
  CAMLreturn(alloc_bdd(res));
}

CAMLprim value caml_cudd_bdd_not(DdManager *manager, value vbdd) {
  CAMLparam1(vbdd);
  bdd_t b = Bdd_val(vbdd);
  bdd_t res = Cudd_Not(b);
  Cudd_Ref(res);
  CAMLreturn(alloc_bdd(res));
}

CAMLprim value caml_cudd_bdd_is_equal(DdManager *manager, value vbdd1,
                                      value vbdd2) {
  CAMLparam2(vbdd1, vbdd2);
  bdd_t b1 = Bdd_val(vbdd1);
  bdd_t b2 = Bdd_val(vbdd2);
  _Bool res = b1 == b2;
  CAMLreturn(Val_int(res));
}

CAMLprim value caml_cudd_bdd_leq(DdManager *manager, value vbdd1, value vbdd2) {
  CAMLparam2(vbdd1, vbdd2);
  bdd_t b1 = Bdd_val(vbdd1);
  bdd_t b2 = Bdd_val(vbdd2);
  int res = Cudd_bddLeq(manager, b1, b2);
  CAMLreturn(Val_int(res));
}

CAMLprim value caml_cudd_bdd_inspect(DdManager *manager, value vbdd) {
  CAMLparam1(vbdd);
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
    Field(vres, 1) = alloc_bdd(th);
    Field(vres, 2) = alloc_bdd(el);
  }
  CAMLreturn(vres);
}


CAMLprim value caml_cudd_print(DdManager *manager,value v){
  CAMLparam1(v);
  bdd_t b = Bdd_val(b);
  fflush(stdout);
  Cudd_PrintMinterm(manager,b);
  fflush(stdout);
  CAMLreturn(Val_unit);
}
