%
%   Gomoku-2 
%	Continued: December 2015
%	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

-module(state).

-export([init_state/0
		]).



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
	{1, undef,
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