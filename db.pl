:- dynamic pred/1.

to_list([X|L]):-
	pred(X),
	retract(pred(X)),
	to_list(L),
	assert(pred(X)).
to_list([]).