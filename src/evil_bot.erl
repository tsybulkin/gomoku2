%
%   Gomoku-2 
%	Continued: December 2015
%	
%   This is an agent making decisions on the basis
%   of position evaluation. Neither learning, nor game tree search are used.
%   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

-module(evil_bot).
-export([
		get_move/2
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
init_evaluation(Board) ->
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

	{V,H,D1,D2,fiver:count(V,H,D1,D2)}.



get_move({1,_,_}=State,no_evaluation) -> 
	FirstMove = {8,8},
	{_,_,Board} = state:change_state(State,FirstMove),
	{ FirstMove,init_evaluation(Board)};
get_move({Turn,LastMove,_}=State,LastEval) ->
	OppColor = state:color(Turn-1),
	PrevEval = change_evaluation(LastEval,LastMove,OppColor),
	CandidateMoves = moves:get_candidate_moves(State),
	{9,9}.




% internal representation of the state. 
% Eval = {Vert,Hor,Diag1,Diag2,Counters}
change_evaluation(no_evaluation, {8,8}, blacks) -> 
	{2,{8,8},Board} = state:init_state([{8,8}]),
	init_evaluation(Board);

change_evaluation({Vert,Hor,D1,D2,Cnts}, {I,J}, OppColor) -> 
	Column = element(I,Vert),
	Cnts1 = lists:foldl(fun(N,Acc)->
		S = element(N,Column),
		S1 = fiver:change_state(S,OppColor),
		dict:update_counter(S1,1,dict:update_counter(S,-1,Acc))
	end,Cnts,lists:seq(max(J-4,1),min(J,11))),

	Row = element(J,Hor),
	Cnts2 = lists:foldl(fun(N,Acc)->
		S = element(N,Row),
		S1 = fiver:change_state(S,OppColor),
		dict:update_counter(S1,1,dict:update_counter(S,-1,Acc))
	end,Cnts1,lists:seq(max(I-4,1),min(I,11) )),

	D1_index = J-I+11,
	if 
		D1_index<1 orelse D1_index>21 -> Cnts3 = Cnts2;
		true -> 
			Diag1 = element(D1_index,D1), Size1 = size(Diag1),
			if I < J -> Ind1=I; true -> Ind1=J end,
			Cnts3 = lists:foldl(fun(N,Acc)->
				S = element(N,Diag1),
				S1 = fiver:change_state(S,OppColor),
				dict:update_counter(S1,1,dict:update_counter(S,-1,Acc))
			end,Cnts2,lists:seq(max(Ind1-4,1),min(Ind1,Size1) ))
	end,

	D2_index = J+I-5,
	if 
		D2_index<1 orelse D2_index>21 -> Cnts4 = Cnts3;
		true -> 
			Diag2=element(D2_index,D2), Size2 = size(Diag2),
			if I+J < 15 -> Ind2=I; true -> Ind2=16-J end,
			Cnts4 = lists:foldl(fun(N,Acc)->
				S = element(N,Diag2),
				S1 = fiver:change_state(S,OppColor),
				dict:update_counter(S1,1,dict:update_counter(S,-1,Acc))
			end,Cnts3,lists:seq(max(Ind2-4,1),min(Ind2,Size2) ))
	end,
	Cnts4.



