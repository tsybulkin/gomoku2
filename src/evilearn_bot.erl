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




% the agent utilises evil_boat methods as init_valuation9) or change_evaluation()
%
get_move({1,_,_}=State,no_evaluation) -> 
	FirstMove = {8,8},
	{_,_,Board} = state:change_state(State,FirstMove),
	{ FirstMove,evil_boat:init_evaluation(Board)};
get_move({Turn,LastMove,_}=State,{_,_,_,_,_,W}=LastEval) ->
	OppColor = state:color(Turn-1),
	MyColor = state:color(Turn),
	CurrEval = evil_bot:change_evaluation(LastEval,LastMove,OppColor),
	CandidateMoves = moves:get_candidate_moves(State),
	RatedMoves = [ {Move,evil_bot:estimate_move(Move,CurrEval,MyColor,W)} || Move <- CandidateMoves],
	[{M,_}|_]=SortedMoves=lists:sort(fun({_,R1},{_,R2})-> R1>R2 end, RatedMoves),
	io:format("Candidate moves: ~p~n",[lists:sublist(SortedMoves,10)]),
	{_,_,_,_,Aggregates} = NewEval = evil_bot:change_evaluation(CurrEval,M,MyColor),
	io:format("State value: ~p~n",[evil_bot:get_value(Aggregates,W,MyColor)]),
	{M,NewEval}.
