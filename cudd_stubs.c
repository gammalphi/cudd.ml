#include <stdlib.h>
#include <stdio.h>
#include <cudd.h>
#include <caml/mlvalues.h>
#include <caml/memory.h>
#include <caml/custom.h>
#include <caml/fail.h>

/* This assume a single static manager. Maybe we should not.  A
   possibility is to use a generative functor, where each call would
   create a distinct manager, and where it is impossible to use
   variables of different managers. */
static DdManager *manager = NULL;

typedef DdNode* bdd_t;

/* Do we need this wrapper? Not sure. */
struct bdd_wrapper {
  bdd_t ptr;
};

#define Bddwrapper_val(v) ((struct bdd_wrapper*) Data_custom_val(v))
#define Bdd_val(v) (Bddwrapper_val(v)->ptr)

static void bdd_finalize(value v) {
  struct bdd_wrapper* w = Bddwrapper_val(v);
  if (w->ptr != NULL) {
    Cudd_RecursiveDeref(manager, w->ptr);
    w->ptr = NULL;
  }
}

static struct custom_operations bdd_ops = {
  "cudd.bdd",
  bdd_finalize,
  custom_compare_default,
  custom_hash_default,
  custom_serialize_default,
  custom_deserialize_default
};

CAMLprim value caml_cudd_init(value unit) {
  CAMLparam1(unit);
  if (manager == NULL) {
    manager = Cudd_Init(0, 0, CUDD_UNIQUE_SLOTS, CUDD_CACHE_SLOTS, 0);
  }
  CAMLreturn(Val_unit);
}

CAMLprim value caml_cudd_quit(value unit) {
  CAMLparam1(unit);
  if (manager != NULL) {
    Cudd_Quit(manager);
    manager = NULL;
  }
  CAMLreturn(Val_unit);
}

static value alloc_bdd(bdd_t node) {
  value block = caml_alloc_custom(&bdd_ops, sizeof(struct bdd_wrapper), 0, 1);
  struct bdd_wrapper* w = Bddwrapper_val(block);
  w->ptr = node;
  return block;
}

CAMLprim value caml_cudd_bdd_true(value unit) {
  CAMLparam1(unit);
  bdd_t node = Cudd_ReadOne(manager);
  Cudd_Ref(node);
  CAMLreturn(alloc_bdd(node));
}

CAMLprim value caml_cudd_bdd_false(value unit) {
  CAMLparam1(unit);
  bdd_t node = Cudd_ReadLogicZero(manager);
  Cudd_Ref(node);
  CAMLreturn(alloc_bdd(node));
}

CAMLprim value caml_cudd_bdd_var(value vidx) {
  CAMLparam1(vidx);
  int idx = Int_val(vidx);
  bdd_t node = Cudd_bddIthVar(manager, idx);
  Cudd_Ref(node);
  CAMLreturn(alloc_bdd(node));
}


CAMLprim value caml_cudd_bdd_and(value vbdd1, value vbdd2) {
  CAMLparam2(vbdd1, vbdd2);
  bdd_t b1 = Bdd_val(vbdd1);
  bdd_t b2 = Bdd_val(vbdd2);
  bdd_t res = Cudd_bddAnd(manager, b1, b2);
  Cudd_Ref(res);
  CAMLreturn(alloc_bdd(res));
}

CAMLprim value caml_cudd_bdd_or(value vbdd1, value vbdd2) {
  CAMLparam2(vbdd1, vbdd2);
  bdd_t b1 = Bdd_val(vbdd1);
  bdd_t b2 = Bdd_val(vbdd2);
  bdd_t res = Cudd_bddOr(manager, b1, b2);
  Cudd_Ref(res);
  CAMLreturn(alloc_bdd(res));
}

CAMLprim value caml_cudd_bdd_not(value vbdd) {
  CAMLparam1(vbdd);
  bdd_t b = Bdd_val(vbdd);  
  bdd_t res = Cudd_Not(b);
  Cudd_Ref(res);
  CAMLreturn(alloc_bdd(res));
}

CAMLprim value caml_cudd_bdd_equal(value vbdd1, value vbdd2) {
  CAMLparam2(vbdd1, vbdd2);
  bdd_t b1 = Bdd_val(vbdd1);
  bdd_t b2 = Bdd_val(vbdd2);
  _Bool res = b1 == b2;
  CAMLreturn(Val_int(res));
}

