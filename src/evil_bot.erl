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


% Evaluation = {165Vert={15x11},165Hor={15x11},121D1={21x..},121D2={21x..}, Counters}
% Vert going from left to right
% Hor going from bottom to top
% D1 going from left upper corner to bottom right corner
% D2 going from bottom left corner to top right corner
%
%   Counters:
% Keys: free,mixed,b_siglet,w_singlet, ...
%
init_evaluation(Color,{Turn,_,Board}) ->
	Lv = lines:extract_vert_lines(15,Board),
	V = list_to_tuple(lists:foldl(fun({_,_,L},Acc)->
		L1 = lists:reverse(L),
		[list_to_tuple([ fiver:state(lists:sublist(L1,J,5)) || J <- lists:seq(1,11)]) | Acc]
	end,[],Lv)),

	Lh = lines:extract_hor_lines(15,Board),
	H = list_to_tuple(lists:foldl(fun({_,_,L},Acc)->
		[list_to_tuple([ fiver:state(lists:sublist(L,J,5)) || J <- lists:seq(1,11)]) | Acc]
	end,[],Lh)),

	Ld1 = lists:reverse(lines:extract_diagonals1(Board)),
	D1 = list_to_tuple(lists:foldl(fun({_,_,L},Acc)->
		[list_to_tuple([ fiver:state(lists:sublist(L,J,5)) || J <- lists:seq(1,length(L)-4)]) | Acc]
	end,[],Ld1)),

	Ld2 = lists:reverse(lines:extract_diagonals2(Board)),
	D2 = list_to_tuple(lists:foldl(fun({_,_,L},Acc)->
		[list_to_tuple([ fiver:state(lists:sublist(L,J,5)) || J <- lists:seq(1,length(L)-4)]) | Acc]
	end,[],Ld2)),

	Cnts = fiver:count(V,H,D1,D2),
	{V,H,D1,D2,dict:to_list(Cnts)}.


get_move({1,_,_Board},_Evaluation) -> {8,8};
get_move({Turn,LastMove,Board},Evaluation) -> 
	{9,9}.




% internal representation of the state. It may contain 
% different parameters reflecting evaluation of the current state
% random agent does not use any such information
change_evaluation(_PrevEval, _Move) -> no_change.



