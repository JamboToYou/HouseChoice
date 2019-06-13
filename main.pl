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
	add_record/2,
	add_question/2,
	edit_question/2.
:- ['model.pl'].

cls:-
	write('\33\[2J').

key_exit:-
	nl,write("Нажмите любую клавишу чтобы выйти . . ."),nl,
	get_single_char(_).


enable_debug_mode:-debug_mode.
enable_debug_mode:-assert(debug_mode).

disable_debug_mode:-not(debug_mode).
disable_debug_mode:-retract(debug_mode).

interview(QID):-
	cls,
	debug_mode,
	question(QID, Question, _, _),
	write(Question),nl,
	debug_menu(QID).
interview(QID):-
	cls,
	question(QID, Question, QNodes, RNodes),
	append(QNodes, RNodes, Nodes),
	write(Question),nl,
	enumerate(Nodes, Out),
	get_user_answer(Out, Answer),
	react(Answer, QNodes, RNodes).

debug_menu(QID):-
	write("1: Двигаться дальше"),nl,
	write("2: Добавить вопрос"),nl,
	write("3: Добавить терминальный узел"),nl,
	write("4: Выйти"),nl,
	readln([Cmd|_]),
	debug_command(Cmd, QID).

debug_command(1, QID):-
	question(QID, _, QNodes, RNodes),
	append(QNodes, RNodes, Nodes),
	enumerate(Nodes, Out),
	get_user_answer(Out, Answer),
	react(Answer, QNodes, RNodes).

debug_command(2, QID):-
	cls,
	question(QID, Question, QNodes, RNodes),
	write("Введите новый вариант ответа на текущий вопрос:"),nl,
	readln([RawA|AT]),atomics_to_string([RawA|AT], " ", Answer),
	not(member([Answer,_], QNodes)),
	write("Введите новый вопрос:"),nl,
	readln([RawQ|QT]),atomics_to_string([RawQ|QT], " ", NewQuestion),
	add_question(NewQuestion, NewQID),
	edit_question(QID, [Question, [[Answer,NewQID]|QNodes], RNodes]),
	save,
	write("Вопрос успешно добавлен"),nl.
debug_command(2, QID):-
	cls,
	write("Такой ответ уже есть"),nl,
	debug_command(2, QID).

debug_command(3, QID):-
	cls,
	question(QID, Question, QNodes, RNodes),
	write("Введите новый вариант ответа на текущий вопрос:"),nl,
	readln([RawA|AT]),atomics_to_string([RawA|AT], " ", Answer),
	not(member([Answer,_], RNodes)),
	write("Введите новый ответ:"),nl,
	readln([RawR|RT]),atomics_to_string([RawR|RT], " ", NewRecord),
	add_record(NewRecord, NewRID),
	edit_question(QID, [Question, QNodes, [[Answer,NewRID]|RNodes]]),
	save,
	write("Вопрос успешно добавлен"),nl.
debug_command(3, QID):-
	cls,
	write("Такой ответ уже есть"),nl,
	debug_command(3, QID).

debug_command(4, _).

react(Answer, QNodes, _ ):-
	member([Answer, QID], QNodes),
	interview(QID).
react(Answer, _, RNodes ):-
	member([Answer, RID], RNodes),
	display_record(RID).

display_record(RID):-
	cls,
	record(RID, Value),
	write("Your destination!"),nl,
	write(Value),nl,
	attribute(RID, Name, AttrValue),
	write(Name), write(": "), write(AttrValue), nl,
	fail;
	key_exit.

display_attributes(RID):-
	attribute(RID, Name, AttrValue),
	write(Name),write(": "),write(AttrValue),nl,
	fail;true.

get_user_answer(Variants,Answer):-
	write_variants(Variants),
	readln([Idx|_]),
	member([Idx,Answer,_],Variants).

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
	cls,
	write("1: Начать отладку"),nl,
	write("2: Выключить режим отладки"),nl,
	write("3: Редактировать запись"),nl,
	write("4: Выйти"),nl,
	readln([Cmd|_]),
	command(Cmd),!.
menu:-
	cls,
	write("1: Начать"),nl,
	write("2: Включить режим отладки"),nl,
	write("3: Выйти"),nl,
	readln([Cmd|_]),
	command(Cmd),!.

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

command(3):-
	debug_mode,
	process_editing_records.
command(3).

command(4):-
	debug_mode.

process_editing_records:-
	cls,
	record(RID, Value),
	write(RID),write(": "),write(Value),nl,
	fail;
	readln([RID]),
	edit_record(RID,0).

edit_record(RID, 0):-
	write("1: Редактировать значение"),nl,
	write("2: Добавить аттрибут"),nl,
	write("3: Редактировать аттрибут"),nl,
	write("4: Удалить запись"),nl,
	write("5: Отмена"),nl,
	readln([Cmd]),
	edit_record(RID, Cmd),
	menu.

edit_record(RID, 1):-
	write("Введите новое значение:"),nl,
	readln(RNV),atomics_to_string(RNV, " ", NV),
	record(RID, OldValue),
	retract(record(RID, OldValue)),
	assert(record(RID, NV)),
	save,
	write("Запись успешно отредактирована"),nl,
	key_exit.

edit_record(RID, 2):-
	write("Введите название аттрибута:"),nl,
	readln(RAN),atomics_to_string(RAN, " ", AN),
	not(attribute(RID, AN, _)),
	write("Введите значение аттрибута:"),nl,
	readln(RAV),atomics_to_string(RAV, " ", AV),
	assert(attribute(RID, AN, AV)),
	save,
	write("Аттрибут успешно добавлен"),nl,key_exit;
	write("Такой аттрибут уже существует. Воспользуйтесь опцией Редактирование аттрибута"),nl,key_exit,
	edit_record(RID, 0).

edit_record(RID, 3):-
	cls,
	record(RID, _),
	attribute(RID, _, _),
	write("Выберите аттрибут:"),nl,
	display_attributes(RID),
	readln(RAV),atomics_to_string(RAV, " ", AV),
	write("Введите новое значение:"),nl,
	readln(RNAV),atomics_to_string(RNAV, " ", NAV),
	attribute(RID, AV, OldValue),
	retract(attribute(RID, Name, OldValue)),
	assert(attribute(RID, Name, NAV)),
	save,
	write("Аттрибут успешно отредактирован"),nl,
	key_exit.
edit_record(RID, 3):-
	cls,write("У этой записи нет аттрибутов"),nl,key_exit,edit_record(RID, 0).

edit_record(RID, 4):-
	record(RID, Value),
	retract(record(RID, Value)),
	retractall(attribute(RID, _, _)),
	save,
	write("Запись успешно удалена"),nl,key_exit.

edit_record(_, 5).