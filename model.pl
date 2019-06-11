:- dynamic
	root/1,
	record/2,
	attribute/3,
	question/4.
:-['db.pl'].

save:-
	tell('db.pl'),
	write_records,
	write_questions,
	write_attributes,
	root(X),
	write(root(X)),write("."),nl,
	told.

write_records:-
	record(ID, Value),
	write(record(ID, Value)),write("."),nl,
	fail; true.

write_questions:-
	question(ID, Value, QNodes, RNodes),
	write(question(ID, Value, QNodes, RNodes)),write("."),nl,
	fail; true.

write_attributes:-
	attribute(ID, Name, Value),
	write(record(ID, Name, Value)),write("."),nl,
	fail; true.

add_question(Value, QID).


generate_question_id(ID):-
	question(ID, _, _, _),
	ID > ID1,
	generate_question_id(ID1).
generate_question_id(0).

% getChildrenCount(QID, Cnt):-
% 	question(QID, _, QNodes, RNodes),
% 	length(QNodes, QCnt),
% 	length(RNodes, RCnt),
% 	plus(QCnt, RCnt, Cnt).

