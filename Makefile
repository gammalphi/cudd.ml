# -*- mode:Makefile -*-

deps: cudd/cudd.tar.gz

# Download cudd from the web. The benefit of using make is that the
# file will not be re-downloaded (this cannot be achieved with dune).
cudd/cudd.tar.gz:
	wget `grep -o -e 'https.*cudd.*gz' cudd.opam` -O $@
