%
%   Gomoku-2 
%	Continued: December 2015
%	
%   This is an agent making decisions on the basis
%   of position evaluation. Neither learning, nor game tree search are used.
%   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

-module(evil_bot).
-export([							% mondatory methods of any agent
		get_move/2, learn_dataset/1
		]). 

-export([							% methods shared with smart_bot
		init_w/0,
		init_evaluation/1,
		change_evaluation/3,
		get_counters_after_move/3,
		get_best_moves/2,
		get_value/3
		]).

-define(TERMINAL_VALUE,100).
-define(THRESHOLD,0.75).

-define(MY_SINGL,0).
-define(OPP_SINGL,-0.5).
-define(MY_DUPL,2).
-define(OPP_DUPL,-4).
-define(MY_TRIPL,7).
-define(OPP_TRIPL,-14).
-define(MY_QUART,26).
-define(OPP_QUART,-51).
-define(MY_QUINT,100).
-define(OPP_QUINT,-100).
-define(FREE,0).
-define(MIXED,0).

-define(W_DIVERGENCE,1.2).


init_w() -> 
	random:seed(now()),
	dict:from_list([{{free,blacks},d(?FREE)},{{free,whites},d(?FREE)},
	{{mixed,blacks},d(?MIXED)},{{mixed,whites},d(?MIXED)},
	{{b_singlet,blacks},d(?MY_SINGL)},{{w_singlet,blacks},d(?OPP_SINGL)},
	{{b_duplet,blacks},d(?MY_DUPL)},{{w_duplet,blacks},d(?OPP_DUPL)},
	{{b_triplet,blacks},d(?MY_TRIPL)},{{w_triplet,blacks},d(?OPP_TRIPL)},
	{{b_quartet,blacks},d(?MY_QUART)},{{w_quartet,blacks},d(?OPP_QUART)},
	{{b_quintet,blacks},d(?MY_QUINT)},{{w_quintet,blacks},d(?OPP_QUINT)},
	{{b_singlet,whites},d(?OPP_SINGL)},{{w_singlet,whites},d(?MY_SINGL)},
	{{b_duplet,whites},d(?OPP_DUPL)},{{w_duplet,whites},d(?MY_DUPL)},
	{{b_triplet,whites},d(?OPP_TRIPL)},{{w_triplet,whites},d(?MY_TRIPL)},
	{{b_quartet,whites},d(?OPP_QUART)},{{w_quartet,whites},d(?MY_QUART)},
	{{b_quintet,whites},d(?OPP_QUINT)},{{w_quintet,whites},d(?MY_QUINT)}]).


d(V) -> d(V,?W_DIVERGENCE).
d(V,1) -> V;
d(V,D) -> V/D + random:uniform()*V*(D-1/D).



learn_dataset(_) -> ok.




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

	{V,H,D1,D2,fiver:count(V,H,D1,D2),init_w()}.



get_move({1,_,_}=State,no_evaluation) -> 
	FirstMove = {8,8},
	{_,_,Board} = state:change_state(State,FirstMove),
	{ FirstMove,init_evaluation(Board)};
get_move({1,_,_}=State,{given_W,W}) -> 
	FirstMove = {8,8},
	{_,_,Board} = state:change_state(State,FirstMove),
	{V,H,D1,D2,Counts,_} = init_evaluation(Board),
	{ FirstMove,{V,H,D1,D2,Counts,W} };
get_move({Turn,LastMove,_}=State,LastEval) ->
	OppColor = state:color(Turn-1),
	MyColor = state:color(Turn),
	CurrEval = change_evaluation(LastEval,LastMove,OppColor),
	BestMoves = get_best_moves(State,CurrEval),
	%io:format("Best moves: ~p~n",[BestMoves]),

	M = smart_bot:choose_move([ {M,P} || {M,_,P}<-BestMoves]),
	NewEval = change_evaluation(CurrEval,M,MyColor),
	{M,NewEval}.



get_best_moves(State,CurrEval) ->
	{Turn,_,_}=State, MyColor=state:color(Turn),
	{_,_,_,_,_,W}=CurrEval,
	CandidateMoves = moves:get_candidate_moves(State),
	RatedMoves = [ {Move,get_value(get_counters_after_move(Move,CurrEval,MyColor),W,MyColor)} 
		|| Move <- CandidateMoves],
	[{_,MaxRate}|_]=SortedMoves=lists:sort(fun({_,R1},{_,R2})-> R1>R2 end, RatedMoves),
	Shift = 50 - MaxRate, Thld = 50*?THRESHOLD,
	Selected = lists:filter(fun({_,R})-> R+Shift > Thld end,SortedMoves),
	Norma = lists:sum([ R ||{_,R} <- Selected ]) + (Shift-Thld+1)*length(Selected),
	[ {M,R,(R+Shift-Thld+1)/Norma} || {M,R} <- Selected].



% internal representation of the state. 
% Eval = {Vert,Hor,Diag1,Diag2,Counters}
change_evaluation(no_evaluation, {8,8}, blacks) -> 
	{2,{8,8},Board} = state:init_state([{8,8}]),
	init_evaluation(Board);

change_evaluation({given_W,W}, {8,8}, blacks) -> 
	{2,{8,8},Board} = state:init_state([{8,8}]),
	{V,H,D1,D2,Counts,_} = init_evaluation(Board),
	{V,H,D1,D2,Counts,W};

change_evaluation({Vert,Hor,D1,D2,Cnts,W}, {I,J}, OppColor) -> 
	%io:format("before move:~p~n",[dict:to_list(Cnts)]),
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
	%io:format("after vert:~p~n",[dict:to_list(Cnts1)]),

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
	%io:format("after hor:~p~n",[dict:to_list(Cnts2)]),

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
	%io:format("after diag1:~p~n",[dict:to_list(Cnts3)]),

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
	%io:format("~p~n",[dict:to_list(Cnts4)]),
	{Vert2,Hor2,D12,D22,Cnts4,W}.



get_counters_after_move({I,J},{Vert,Hor,D1,D2,Cnts,_},MyColor) ->
	%Cnts = fiver:init_counters(),
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
	Cnts4.




get_value(Cnts,W,Color) ->
	lists:foldl(fun(Key,Acc)->
		Acc + dict:fetch(Key,Cnts)*dict:fetch({Key,Color},W)
	end,0,dict:fetch_keys(Cnts)).
	

