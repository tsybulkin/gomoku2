%
%   Gomoku-2 
%	Continued: December 2015
%	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

-module(state).

-export([init_state/0, init_state/1,
		change_state/2,
		print_state/1,
		print_board/1,
		convert/1,
		color/1
		]).

-define(MAX_TURN,60).


% changes assumes that at a given State a given Move has been done.
% returns a new state. If new state is terminal, returns one of the terminal states 
change_state({Turn,_,Board},{I,J}) ->
	Color = color(Turn),
	e = element(I,element(J,Board)),

	%io:format("~nmove ~p: {~p,~p}~n",[Turn,I,J]),
	Row1 = erlang:delete_element(I,element(J,Board)),
	Board1 = erlang:delete_element(J,Board),
	case Color of
		whites -> Row2 = erlang:insert_element(I,Row1,w);
		blacks -> Row2 = erlang:insert_element(I,Row1,b)
	end,
	Next_state = {Turn+1,{I,J},Board2=erlang:insert_element(J,Board1,Row2)},
	print_board(Board2),

	case lines:check_five(Next_state) of
		false when Turn =:= 59 -> draw;
		false -> Next_state;
		Fiver -> 
			case Color of
				blacks -> {blacks_won,Fiver};
				whites -> {whites_won,Fiver}
			end	
	end.	



convert({I,J}) -> [lists:nth(I,"abcdefghijklmno")|integer_to_list(J)].



print_state({Turn,Board}) -> io:format("Turn:~p~n",[Turn]), print_board(Board).



print_board(Board) ->
	Rows = lists:reverse(tuple_to_list(Board)),
	print_rows(15,Rows),
	io:format("   a b c d e f g h i j k l m n o~n~n").

print_rows(N,[Row|Rows]) ->
	print_stones(pad3(integer_to_list(N)++" "), lists:reverse(tuple_to_list(Row)),""),
	print_rows(N-1,Rows);
print_rows(_,[]) -> ok.
	%io:format("~n").


print_stones(Head,[Stone|Stones],Acc) ->
	case Stone of
		e -> print_stones(Head,Stones,[$-,$| |Acc]);
		b -> print_stones(Head,Stones,[$-,$X |Acc]);
		w -> print_stones(Head,Stones,[$-,$O |Acc])
	end;
print_stones(Head,[],Acc) ->
	[$-|Tile] = Acc,
	io:format("~s~n",[Head++Tile]).


pad3(Str) when length(Str) =:= 2 -> [" "|Str];
pad3(Str) when length(Str) =:= 3 -> Str;
pad3(_) -> error('wrong length of the string').


init_state() ->
	{1, none,
	{{e,e,e,e,e,e,e,e,e,e,e,e,e,e,e},
	 {e,e,e,e,e,e,e,e,e,e,e,e,e,e,e},
	 {e,e,e,e,e,e,e,e,e,e,e,e,e,e,e}, 
	 {e,e,e,e,e,e,e,e,e,e,e,e,e,e,e},
	 {e,e,e,e,e,e,e,e,e,e,e,e,e,e,e},
	 {e,e,e,e,e,e,e,e,e,e,e,e,e,e,e},
	 {e,e,e,e,e,e,e,e,e,e,e,e,e,e,e},
	 {e,e,e,e,e,e,e,e,e,e,e,e,e,e,e},
	 {e,e,e,e,e,e,e,e,e,e,e,e,e,e,e},
	 {e,e,e,e,e,e,e,e,e,e,e,e,e,e,e},
	 {e,e,e,e,e,e,e,e,e,e,e,e,e,e,e},
	 {e,e,e,e,e,e,e,e,e,e,e,e,e,e,e},
	 {e,e,e,e,e,e,e,e,e,e,e,e,e,e,e},
	 {e,e,e,e,e,e,e,e,e,e,e,e,e,e,e},
	 {e,e,e,e,e,e,e,e,e,e,e,e,e,e,e}}
	 }.


init_state(Moves) -> init_state(init_state(),Moves).

init_state(State,[Move|Moves]) -> init_state(state:change_state(State,Move),Moves);
init_state(State,[]) -> State.


color(Turn) when Turn rem 2 =:= 0 -> whites;
color(_Turn) -> blacks.

