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
	writeq(root(X)),write("."),nl,
	told.

write_records:-
	record(ID, Value),
	writeq(record(ID, Value)),write("."),nl,
	fail; true.

write_questions:-
	question(ID, Value, QNodes, RNodes),
	writeq(question(ID, Value, QNodes, RNodes)),write("."),nl,
	fail; true.

write_attributes:-
	attribute(ID, Name, Value),
	writeq(record(ID, Name, Value)),write("."),nl,
	fail; true.

add_question(Value, NewID):-
	generate_question_id(NewID),
	assert(question(NewID, Value, [], [])).

edit_question(QID, [Value, QNodes, RNodes]):-
	question(QID, OldValue, OldQNodes, OldRNodes),
	retract(question(QID, OldValue, OldQNodes, OldRNodes)),
	assert(question(QID, Value, QNodes, RNodes)).

questions_as_list([QID|L]):-
	question(QID, Question, QNodes, RNodes),
	retract(question(QID, Question, QNodes, RNodes)),
	questions_as_list(L),
	assert(question(QID, Question, QNodes, RNodes)).
questions_as_list([]).

generate_question_id(ID):-
	questions_as_list(Questions),
	max_list(Questions, MaxID),
	plus(MaxID, 1, ID).

% getChildrenCount(QID, Cnt):-
% 	question(QID, _, QNodes, RNodes),
% 	length(QNodes, QCnt),
% 	length(RNodes, RCnt),
% 	plus(QCnt, RCnt, Cnt).

