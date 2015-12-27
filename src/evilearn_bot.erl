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
		choose_move/1
		]).

-define(THRESHOLD,0.75).
-define(TERMINAL_VALUE,100).



% the agent utilises evil_boat methods as init_valuation() or change_evaluation()
%
get_move({1,_,_}=State,no_evaluation) -> 
	FirstMove = {8,8},
	{_,_,Board} = state:change_state(State,FirstMove),
	{ FirstMove,evil_boat:init_evaluation(Board)};
get_move({Turn,LastMove,_}=State,LastEval) ->
	OppColor = state:color(Turn-1),
	MyColor = state:color(Turn),
	{_,_,_,_,_,W}=CurrEval = evil_bot:change_evaluation(LastEval,LastMove,OppColor),
	
	Moves = rate_best_moves(State,CurrEval,MyColor),
	io:format("Rated moves: ~p~n",[Moves]),

	M = choose_move([ Mo ||{Mo,_,_}<-Moves]),
	
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



	



choose_move(Moves) -> 
	N = random:uniform(length(Moves)),
	lists:nth(N,Moves).
	
