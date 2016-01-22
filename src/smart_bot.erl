%
%   Gomoku-2 
%	Continued: December 2015
%	
%   This is an extension to evil_bot. The bot can improve its play by 
%   analyzing a game tree and learning from experience.
%   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



-module(smart_bot).
-export([
		get_move/2,
		learn_dataset/1
		]).

-export([choose_move/1]).

-define(TERMINAL_VALUE,100).
-define(ALPHA,0).



learn_dataset(_) -> ok.


save_data({_,_,_,_,_,W}) -> 
	file:write_file("data/evilearn_W_vector.dat",io_lib:format("~tp.~n", [W])).


% the agent utilises evil_boat methods as init_valuation() or change_evaluation()
%
get_move({1,_,_}=State,no_evaluation) -> 
	FirstMove = {8,8},
	{_,_,Board} = state:change_state(State,FirstMove),
	{V,H,D1,D2,Cnts,W} = evil_bot:init_evaluation(Board),
	case file:consult("data/evilearn_W_vector.dat") of
		{ok,[W1]} -> { FirstMove,{V,H,D1,D2,Cnts,W1},[] };
		{error,_} -> { FirstMove,{V,H,D1,D2,Cnts,W},[] }
	end;
get_move({Turn,LastMove,_}=State,LastEval) ->
	OppColor = state:color(Turn-1),
	MyColor = state:color(Turn),
	{V0,H0,D10,D20,Cnts0,W0} = evil_bot:change_evaluation(LastEval,LastMove,OppColor),
	if LastEval =:= no_evaluation ->
		case file:consult("data/evilearn_W_vector.dat") of
			{ok,[Wsaved]} -> W = Wsaved;
			{error,_} -> W = W0
		end;
		true -> 
			W = W0
	end, CurrEval = {V0,H0,D10,D20,Cnts0,W},
	
	Moves = rate_best_moves(State,CurrEval,MyColor),

	%% MODIFY

	Features = lists:foldl(fun({M,_,_},Feat)-> 
		Cn = evil_bot:get_counters_after_move(M,CurrEval,MyColor),
		
		%io:format("After move ~p counters: ~p~n",[state:convert(M),[ {Fi,V} ||{Fi,V}<-dict:to_list(Cn)] ]),
		lists:foldl(fun(Key,D)->
			dict:store({M,Key},dict:fetch(Key,Cn),D)
		end,Feat,dict:fetch_keys(Cn))
	end,dict:new(),Moves),
	io:format("Rated moves: ~p~n",[Moves]),
	
	ProbMoves = assign_prob(Moves),
	io:format("Probable moves:~p~n",[ProbMoves]),
	M = choose_move(ProbMoves),

	W1 = learn(W,Moves,Features,MyColor),
	
	{V,H,D1,D2,F,W} = evil_bot:change_evaluation(CurrEval,M,MyColor),
	{M,{V,H,D1,D2,F,W1},[] }.


% evaluate afterstate values and returns the list of best moves
% with its state evaluation and afterstate evaluation
rate_best_moves(State,CurrEval,MyColor) ->
	BestMoves = evil_bot:get_best_moves(State,CurrEval),
	lists:sort(fun({_,_,A},{_,_,B}) -> A>B end,
		[ { Move,R,est_value(state:change_state(State,Move),
							evil_bot:change_evaluation(CurrEval,Move,MyColor),
							MyColor) } || {Move,R,_} <- BestMoves ]).




est_value({Turn,_,_}=State,CurrEval,MyColor) ->

	case state:color(Turn) of
		MyColor -> [{_,R,_}|_] = evil_bot:get_best_moves(State,CurrEval), R;
		OppColor -> 
			BestMoves = evil_bot:get_best_moves(State,CurrEval),
			lists:sum([est_value(state:change_state(State,M),
								evil_bot:change_evaluation(CurrEval,M,OppColor),
								MyColor) * P || {M,_,P}<-BestMoves])
	end;
est_value({blacks_won,_},_,blacks) -> ?TERMINAL_VALUE;
est_value({blacks_won,_},_,whites) -> -?TERMINAL_VALUE;
est_value({whites_won,_},_,blacks) -> -?TERMINAL_VALUE;
est_value({whites_won,_},_,whites) -> ?TERMINAL_VALUE;
est_value(draw,_,_) -> 0.



learn(W,Moves,Features,Color) ->
	Dq = [ {M,Rstar-R} || {M,R,Rstar} <- Moves],
	Keys = lists:usort([ Key || {Key,_} <- dict:fetch_keys(W),
		Key=/=free andalso Key=/= mixed andalso Key=/= b_singlet andalso Key=/= w_singlet]),

	lists:foldl(fun(Key,Acc)->
		Dw = ?ALPHA * lists:sum([ Delta*dict:fetch({M,Key},Features) || {M,Delta} <- Dq]),
		dict:store({Key,Color},dict:fetch({Key,Color},Acc) - Dw,Acc)
	end,W,Keys).


assign_prob(Moves) ->
	[{_,_,MinRate}|_] = lists:reverse(Moves),
	Shift = MinRate-1,
	Norma = lists:sum([ (R-Shift)*(R-Shift) ||{_,_,R} <- Moves ]),
	[ {M,(R-Shift)*(R-Shift)/Norma} ||{M,_,R} <- Moves].



choose_move(Moves) -> choose_move(Moves,0).

choose_move([{M,P}|Moves],Pt) ->
	case random:uniform()<P+Pt of
		true -> M;
		false-> choose_move(Moves,P+Pt)
	end.

