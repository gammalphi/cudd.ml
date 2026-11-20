## v0.2.0 - (unreleased)
- `Bdd.hash` and `Bdd.compare`; the bdd custom block has a hash and a
  compare (node address), so the polymorphic `Hashtbl` and `compare` work
  on BDDs (every BDD used to hash to 0).

## v0.1.0 - (2025-06-10)
- First release of the CUDD.ml library 
- Only contains a minimal set of binding to interact with BDD for now
