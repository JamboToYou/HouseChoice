:-dynamic man/1.

test:-
	tell('testdb.pl'),
	X = 1,
	writeq(man(X)),
	write("."),
	told.