%
%   Gomoku-2 
%	Continued: December 2015
%	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

-module(state).

-export([init_state/0,
		change_state/2,
		print_state/1,
		print_board/1,
		color/1
		]).

-define(MAX_TURN,60).


% changes assumes that at a given State a given Move has been done.
% returns a new state. If new state is terminal, returns one of the terminal states 
change_state({Turn,_,Board},{I,J}) ->
	Color = color(Turn),
	e = element(I,element(J,Board)),

	io:format("~nNew ~p move:(~p,~p)~n",[Turn,I,J]),
	Row1 = erlang:delete_element(I,element(J,Board)),
	Board1 = erlang:delete_element(J,Board),
	case Color of
		whites -> Row2 = erlang:insert_element(I,Row1,w);
		blacks -> Row2 = erlang:insert_element(I,Row1,b)
	end,
	Next_state = {Turn+1,{I,J},erlang:insert_element(J,Board1,Row2)},

	case lines:check_five(Next_state) of
		false when Turn =:= 59 -> draw;
		false -> Next_state;
		Fiver -> 
			case Color of
				blacks -> {blacks_won,Fiver};
				whites -> {whites_won,Fiver}
			end	
	end.	




print_state({Turn,Board}) -> io:format("Turn:~p~n",[Turn]), print_board(Board).



print_board(Board) ->
	Rows = lists:reverse(tuple_to_list(Board)),
	print_rows(15,Rows),
	io:format("  a b c d f g h i j k l m n o p~n~n").

print_rows(N,[Row|Rows]) ->
	print_stones(" " ++ integer_to_list(N rem 10), tuple_to_list(Row)),
	print_rows(N-1,Rows);
print_rows(_,[]) -> ok.
	%io:format("~n").


print_stones(Acc,[Stone|Stones]) ->
	case Stone of
		e -> print_stones("|-"++Acc,Stones);
		b -> print_stones("X-"++Acc,Stones);
		w -> print_stones("O-"++Acc,Stones)
	end;
print_stones(Acc,[]) ->
	[E1,E2,_|Tile] = lists:reverse(Acc),
	io:format("~s~n",[[E1,E2|Tile]]).


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



color(Turn) when Turn rem 2 =:= 0 -> whites;
color(_Turn) -> blacks.

