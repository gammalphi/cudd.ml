all:
	dune build
	dune exec test/test.exe
