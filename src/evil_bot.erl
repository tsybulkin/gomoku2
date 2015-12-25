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
	MyColor = state:color(Turn),
	W = w(MyColor),
	CurrEval = change_evaluation(LastEval,LastMove,OppColor),
	CandidateMoves = moves:get_candidate_moves(State),
	RatedMoves = [ {Move,estimate_move(Move,CurrEval,MyColor,W)} || Move <- CandidateMoves],
	[{M,_}|_]=SortedMoves=lists:sort(fun({_,R1},{_,R2})-> R1>R2 end, RatedMoves),
	io:format("Candidate moves: ~p~n",[SortedMoves]),
	{M,change_evaluation(CurrEval,M,MyColor)}.



% internal representation of the state. 
% Eval = {Vert,Hor,Diag1,Diag2,Counters}
change_evaluation(no_evaluation, {8,8}, blacks) -> 
	{2,{8,8},Board} = state:init_state([{8,8}]),
	init_evaluation(Board);

change_evaluation({Vert,Hor,D1,D2,Cnts}, {I,J}, OppColor) -> 
	io:format("before move:~p~n",[dict:to_list(Cnts)]),
	Column = element(I,Vert),
	{Cnts1,Column1} = lists:foldl(fun(N,{Dict,Col})->
		S = element(N,Col),
		S1 = fiver:change_state(S,OppColor),
		Col1 = erlang:delete_element(N,Col),
		Col2 = erlang:insert_element(N,Col1,S1),
		{dict:update_counter(S1,1,dict:update_counter(S,-1,Dict)),Col2}
	end,{Cnts,Column},lists:seq(max(J-4,1),min(J,11))),
	Vert1 = erlang:delete_element(I,Vert),
	Vert2 = erlang:insert_element(I,Vert1,Column1),
	io:format("after vert:~p~n",[dict:to_list(Cnts1)]),

	Row = element(J,Hor),
	{Cnts2,Row1} = lists:foldl(fun(N,{Dict,R})->
		S = element(N,R),
		S1 = fiver:change_state(S,OppColor),
		R1 = erlang:delete_element(N,R),
		R2 = erlang:insert_element(N,R1,S1),
		{dict:update_counter(S1,1,dict:update_counter(S,-1,Dict)),R2}
	end,{Cnts1,Row},lists:seq(max(I-4,1),min(I,11) )),
	Hor1 = erlang:delete_element(J,Hor),
	Hor2 = erlang:insert_element(J,Hor1,Row1),
	io:format("after hor:~p~n",[dict:to_list(Cnts2)]),

	D1_index = J-I+11,
	if 
		D1_index<1 orelse D1_index>21 -> 
			Cnts3=Cnts2, D12=D1;
		true -> 
			Diag1=element(D1_index,D1), Size1=size(Diag1),
			if I < J -> Ind1=I; true -> Ind1=J end,
			{Cnts3,Diag11} = lists:foldl(fun(N,{Dict,Dia})->
				S = element(N,Dia),
				S1 = fiver:change_state(S,OppColor),
				Dia1 = erlang:delete_element(N,Dia),
				Dia2 = erlang:insert_element(N,Dia1,S1),
				{dict:update_counter(S1,1,dict:update_counter(S,-1,Dict)),Dia2}
			end,{Cnts2,Diag1},lists:seq(max(Ind1-4,1),min(Ind1,Size1) )),
			D11 = erlang:delete_element(D1_index,D1),
			D12 = erlang:insert_element(D1_index,D11,Diag11)
	end,
	io:format("after diag1:~p~n",[dict:to_list(Cnts3)]),

	D2_index = J+I-5,
	if 
		D2_index<1 orelse D2_index>21 -> 
			Cnts4=Cnts3, D22=D2;
		true -> 
			Diag2=element(D2_index,D2), Size2=size(Diag2),
			if I+J < 15 -> Ind2=I; true -> Ind2=16-J end,
			{Cnts4,Diag12} = lists:foldl(fun(N,{Dict,Dia})->
				S = element(N,Dia),
				S1 = fiver:change_state(S,OppColor),
				Dia1 = erlang:delete_element(N,Dia),
				Dia2 = erlang:insert_element(N,Dia1,S1),
				{dict:update_counter(S1,1,dict:update_counter(S,-1,Dict)),Dia2}
			end,{Cnts3,Diag2},lists:seq(max(Ind2-4,1),min(Ind2,Size2) )),
			D21 = erlang:delete_element(D2_index,D2),
			D22 = erlang:insert_element(D2_index,D21,Diag12)
	end,
	io:format("~p~n",[dict:to_list(Cnts4)]),
	{Vert2,Hor2,D12,D22,Cnts4}.



estimate_move({I,J},{Vert,Hor,D1,D2,_},MyColor,W) ->
	Cnts = fiver:init_counters(),
	Column = element(I,Vert),
	Cnts1 = lists:foldl(fun(N,Acc)->
		S = element(N,Column),
		S1 = fiver:change_state(S,MyColor),
		dict:update_counter(S1,1,dict:update_counter(S,-1,Acc))
	end,Cnts,lists:seq(max(J-4,1),min(J,11))),

	Row = element(J,Hor),
	Cnts2 = lists:foldl(fun(N,Acc)->
		S = element(N,Row),
		S1 = fiver:change_state(S,MyColor),
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
				S1 = fiver:change_state(S,MyColor),
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
				S1 = fiver:change_state(S,MyColor),
				dict:update_counter(S1,1,dict:update_counter(S,-1,Acc))
			end,Cnts3,lists:seq(max(Ind2-4,1),min(Ind2,Size2) ))
	end,
	lists:foldl(fun(Key,Acc)->
		Acc + dict:fetch(Key,Cnts4)*dict:fetch(Key,W)
	end,0,dict:fetch_keys(Cnts4)).


w(blacks) -> dict:from_list([{free,0},{mixed,0},{b_singlet,0},{w_singlet,-1},
	{b_duplet,1.5},{w_duplet,-3},{b_triplet,9},{w_triplet,-20},
	{b_quartet,40},{w_quartet,-80},{b_quintet,200},{w_quintet,0}]);
w(whites) -> dict:from_list([{free,0},{mixed,0},{b_singlet,-1},{w_singlet,0},
	{b_duplet,-2},{w_duplet,1},{b_triplet,-20},{w_triplet,10},
	{b_quartet,-80},{w_quartet,45},{b_quintet,0},{w_quintet,200}]).



