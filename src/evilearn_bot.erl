%
%   Gomoku-2 
%	Continued: December 2015
%	
%   This is an extension to evil_bot. The bot can improve its play by 
%   analyzing a game tree and learning from experience.
%   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



-module(evilearn_bot).
-export([
		get_move/2,
		save_data/1
		]).

-define(TERMINAL_VALUE,100).
-define(ALPHA,0.1).



save_data({_,_,_,_,_,W}) -> 
	file:write_file("data/evilearn_W_vector.dat",io_lib:format("~tp.~n", [W])).


% the agent utilises evil_boat methods as init_valuation() or change_evaluation()
%
get_move({1,_,_}=State,no_evaluation) -> 
	FirstMove = {8,8},
	{_,_,Board} = state:change_state(State,FirstMove),
	{V,H,D1,D2,Cnts,W} = evil_bot:init_evaluation(Board),
	case file:consult("data/evilearn_W_vector.dat") of
		{ok,[W1]} -> { FirstMove,{V,H,D1,D2,Cnts,W1}};
		{error,_} -> { FirstMove,{V,H,D1,D2,Cnts,W}}
	end;
get_move({Turn,LastMove,_}=State,LastEval) ->
	OppColor = state:color(Turn-1),
	MyColor = state:color(Turn),
	{_,_,_,_,_,W}=CurrEval = evil_bot:change_evaluation(LastEval,LastMove,OppColor),
	
	Moves = rate_best_moves(State,CurrEval,MyColor),
	io:format("Rated moves: ~p~n",[Moves]),

	M = choose_move([ Mo || {Mo,_,_} <- Moves]),
	
	{_,_,_,_,Aggregates,W} = NewEval = evil_bot:change_evaluation(CurrEval,M,MyColor),
	io:format("State value: ~p~n",[evil_bot:get_value(Aggregates,W,MyColor)]),
	{M,NewEval}.


% evaluate afterstate values and returns the list of best moves
% with its state evaluation and afterstate evaluation
rate_best_moves(State,CurrEval,MyColor) ->
	BestMoves = evil_bot:get_best_moves(State,CurrEval),
	lists:sort(fun({_,_,A},{_,_,B}) -> A>B end,
		[ { Move,R,est_value(state:change_state(State,Move),
							evil_bot:change_evaluation(CurrEval,Move,MyColor),
							MyColor) } || {Move,R} <- BestMoves ]).




est_value({Turn,_,_}=State,CurrEval,MyColor) ->

	case state:color(Turn) of
		MyColor -> [{_,R}|_] = evil_bot:get_best_moves(State,CurrEval), R;
		OppColor -> 
			BestMoves = evil_bot:get_best_moves(State,CurrEval),
			lists:sum([est_value(state:change_state(State,M),
								evil_bot:change_evaluation(CurrEval,M,OppColor),
								MyColor)||{M,_}<-BestMoves]) / length(BestMoves)
	end;
est_value({blacks_won,_},_,blacks) -> ?TERMINAL_VALUE;
est_value({blacks_won,_},_,whites) -> -?TERMINAL_VALUE;
est_value({whites_won,_},_,blacks) -> -?TERMINAL_VALUE;
est_value({whites_won,_},_,whites) -> ?TERMINAL_VALUE;
est_value(draw,_,_) -> 0.




choose_move(Moves) -> choose_move(Moves,1).

choose_move(Moves,J) ->
	case random:uniform()<0.77 of
		true -> lists:nth(1+((J-1) rem length(Moves)),Moves);
		false-> choose_move(Moves,J+1)
	end.

