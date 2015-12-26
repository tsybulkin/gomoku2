%
%   Gomoku-2 
%	Continued: December 2015
%	
%   This is an extension to evil_bot. The bot can improve play by learning
%   analyzing a game tree.
%   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



-module(evilearn_bot).
-export([
		get_move/2
		]).

-define(THRESHOLD,0.75).


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
	
	CandidateMoves = moves:get_candidate_moves(State),
	RatedMoves = [ {Move,evil_bot:estimate_move(Move,CurrEval,MyColor)} || Move <- CandidateMoves],
	MovesProbability = assign_probability(RatedMoves),
	io:format("Selected moves: ~p~n",[MovesProbability]),
	
	M = choose_move(MovesProbability),

	{_,_,_,_,Aggregates,W} = NewEval = evil_bot:change_evaluation(CurrEval,M,MyColor),
	io:format("State value: ~p~n",[evil_bot:get_value(Aggregates,W,MyColor)]),
	{M,NewEval}.



assign_probability(RatedMoves) ->
	[{_,MaxRate}|_]=SortedMoves=lists:sort(fun({_,R1},{_,R2})-> R1>R2 end, RatedMoves),
	SelectedMoves = lists:filter(fun({_,R})-> R > ?THRESHOLD*MaxRate end,SortedMoves),
	Norm = lists:sum([ R || {_,R} <- SelectedMoves ]),
	[ {M,R/Norm} || {M,R} <- SelectedMoves ].



choose_move(Moves) -> choose_move(Moves,0).
	
choose_move([{M,P}|Moves],P0) ->
	case random:uniform() < P+P0 of
		true -> M;
		false-> choose_move(Moves,P0+P)
	end.

