%
%   Gomoku-2 
%	Continued: December 2015
%	
%   This is an agent for playing Gomoku as a human
%   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


-module(human_bot).
-export([
		get_move/2,
		save_data/1
		]).


save_data(_) -> ok.



get_move({_,_,Board},_) -> 
	{X,Y} = enter_move(2),
	case element(X,element(Y,Board)) of
		e -> { {X,Y}, no_evaluation};
		_ -> io:format("Entered position is already occupied. Choose another one~n"),
			enter_move(1)
	end.



enter_move(0) -> illegal_move;
enter_move(N) ->
	case io:fread("Enter your move. (Example: j9 or f12): ","~s") of
		{error,_} ->
			io:format("You entered wrong numbers.~nPlease try again.~n"),
			enter_move(N-1);
		{ok,[[X|Y]]} ->
			Y1 = list_to_integer(Y),
			case lists:member(X,"abcdefghijklmno") andalso Y1>0 andalso Y1<16 of
				true ->
					X1 = 1+length(lists:takewhile(fun(A)-> A=/=X end,"abcdefghijklmno")),
					{X1,Y1};
				false->
					io:format("Move format should be as it is shown: d4 or i10 or m7.~nPlease try again.~n"),
					enter_move(N-1)
			end;
		{ok,_} ->
			io:format("Move format should be as it is shown: d4 or i10 or m7.~nPlease try again.~n"),
			enter_move(N-1)
	end.


