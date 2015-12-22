%
%   Gomoku-2 
%	Continued: December 2015
%	
%   This is an agent making decisions on the basis
%   of position evaluation. Neither learning, nor game tree search are used.
%   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

-module(evil_bot).
-export([init_evaluation/2,
		get_move/2,
		change_evaluation/2
		]).


% Evaluation = {165Vert,165Hor,121D1,121D2, Counters}
% 

init_evaluation(Color,{Turn,_,Board}) ->
	Lv = lines:extract_vert_lines(15,Board),
	V = lists:foldl(fun({_,_,L},Acc)->
		L1 = lists:reverse(L),
		[list_to_tuple([ fiver:state(lists:sublist(L1,J,5)) || J <- lists:seq(1,11)]) | Acc]
	end,[],Lv),
	list_to_tuple(V).


get_move({1,_,_Board},_Evaluation) -> {8,8};
get_move({Turn,LastMove,Board},Evaluation) -> 
	Size = min(8,round(math:sqrt(Turn))),
	{9,9}.




% internal representation of the state. It may contain 
% different parameters reflecting evaluation of the current state
% random agent does not use any such information
change_evaluation(_PrevEval, _Move) -> no_change.



