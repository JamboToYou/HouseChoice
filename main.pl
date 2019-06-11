/**
* db structure:
*	record(ID, Value).
*	attribute(RID, Name, Value).
*
*	question(ID, Question, [...[Answer,QID]...], [...[Answer,RID]...]).
*	root(QID).
* */

:- dynamic
	debug_mode/0,
	root/1,
	record/2,
	attribute/3,
	question/4.

:- dynamic
	save/0,
	add_question/2.
:- ['model.pl'].

enable_debug_mode:-debug_mode.
enable_debug_mode:-assert(debug_mode).

disable_debug_mode:-not(debug_mode).
disable_debug_mode:-retract(debug_mode).

interview(QID):-
	debug_mode,
	debug_menu,
	readln([Cmd|_]),
	debug_command(Cmd, QID).

debug_menu:-
	write("1: Двигаться дальше"),nl,
	write("2: Добавить вопрос"),nl,
	write("3: Добавить терминальный узел"),nl.

debug_command(1, QID):-
	question(QID, Question, QNodes, RNodes),
	append(QNodes, RNodes, Nodes),
	write(Question),nl,
	enumerate(Nodes, Out),
	get_user_answer(Out, Answer),
	react(Answer, QNodes, RNodes ).

debug_command(2, QID):-
	question(QID, Question, QNodes, RNodes),
	create_question(NewQNode).

create_question([Answer, QID]):-
	add_question




interview(QID):-
	question(QID, Question, QNodes, RNodes),
	append(QNodes, RNodes, Nodes),
	write(Question),nl,
	enumerate(Nodes, Out),
	get_user_answer(Out, Answer),
	react(Answer, QNodes, RNodes).

react(Answer, QNodes, _ ):-
	member([Answer, QID], QNodes),
	interview(QID).
react(Answer, _, RNodes ):-
	member([Answer, RID], RNodes),
	display_record(RID).

display_record(RID):-
	record(RID, Value),
	write("Your destination!"),nl,!,
	attribute(RID, Name, Value),
	write(Name), write(": "), write(Value), nl,
	fail; true.

get_user_answer(Variants,Answer):-
	write_variants(Variants),
	readln([Answer|_]).

write_variants([]).
write_variants([[Idx, Answer, _]|T]):-
	write_variants(T),
	write(Idx), write(": "), write(Answer), nl.

enumerate([[Answer, ID]],[[1, Answer, ID]]).
enumerate(
		[[Answer, ID]|T],
		[[N1, Answer, ID],[N,PrevAnswer,PrevID]|Out]):-
	enumerate(T,[[N,PrevAnswer,PrevID]|Out]),
	plus(N, 1, N1).

menu:-
	debug_mode,
	write("1: Начать отладку"),nl,
	write("2: Выключить режим отладки"),nl,
	write("3: Выйти"),nl,
	readln([Cmd|_]),
	command(Cmd).
menu:-
	write("1: Начать"),nl,
	write("2: Включить режим отладки"),nl,
	write("3: Выйти"),nl,
	readln([Cmd|_]),
	command(Cmd).

command(1):-
	root(QID),
	interview(QID),
	menu.

command(2):-
	debug_mode,
	disable_debug_mode,
	menu.
command(2):-
	enable_debug_mode,
	menu.

command(3).