(lang dune 3.6)
(name cudd)

(source (uri "https://github.com/ivmai/cudd/archive/refs/tags/cudd-3.0.0.tar.gz"))

(using directory-targets 0.1)

; it overrides the build options...
(generate_opam_files true)

(maintainers "Toto <toto@toto.toto>")


(package
 (name cudd)
 (synopsis "minimal cudd bindings")
 (allow_empty))
