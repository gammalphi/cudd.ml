(lang dune 3.6)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  This file is part of the Codex semantics library.                     ;;
;;                                                                        ;;
;;  Copyright (C) 2013-2025                                               ;;
;;    CEA (Commissariat à l'énergie atomique et aux énergies              ;;
;;         alternatives)                                                  ;;
;;                                                                        ;;
;;  you can redistribute it and/or modify it under the terms of the GNU   ;;
;;  Lesser General Public License as published by the Free Software       ;;
;;  Foundation, version 2.1.                                              ;;
;;                                                                        ;;
;;  It is distributed in the hope that it will be useful,                 ;;
;;  but WITHOUT ANY WARRANTY; without even the implied warranty of        ;;
;;  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         ;;
;;  GNU Lesser General Public License for more details.                   ;;
;;                                                                        ;;
;;  See the GNU Lesser General Public License version 2.1                 ;;
;;  for more details (enclosed in the file LICENSE).                      ;;
;;                                                                        ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(name cudd)

(using directory-targets 0.1)

(generate_opam_files true)

(license "LGPL-2.1-only")

(homepage "https://git.frama-c.com/pub/codex/cudd.ml")

(bug_reports "https://git.frama-c.com/pub/codex/cudd.ml/-/issues")

(authors
 "Matthieu Lemerre <matthieu.lemerre@cea.fr>"
 "Paul Robert <paul.robert@cea.fr>")

(maintainers
 "Matthieu Lemerre <matthieu.lemerre@cea.fr>"
 "Paul Robert <paul.robert@cea.fr>")


(package
 (name cudd)
 (synopsis "Minimal cudd bindings"))
