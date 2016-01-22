%
%   Gomoku-2 
%	Continued: December 2015
%	
%   This module provides genetic algorithm that 
%   runs a given number of matches between evil_bots that have
%   different feature coefficients. Depending on who wins the algorithm
%   modifies the coefficients in accordance with gradient between two agents.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

-module(evil_bot_learning).
-export([run/4
		]).




run(Nbr_agents,Nbr_matches,Feat1,Feat2) ->
	Coeffs = [ evil_bot:init_w() || _ <- lists:seq(1,Nbr_agents)],
	Stat_file = "data/stat_file.dat",
	run_matches(Nbr_matches,Coeffs,Stat_file,Feat1,Feat2).


run_matches(0,_Coeffs,Stat_file,_,_) -> 
	io:format("All matches done. Results are in ~p file~n",[Stat_file]);

run_matches(Nbr_matches,Coeffs,Stat_file,Feat1,Feat2) ->
	log_features(Stat_file,Coeffs,Feat1,Feat2),

	[W1|Coeff1] = Coeffs,
	{L1,[W2|L2]} = lists:split(random:uniform(length(Coeff1)-1),Coeff1),

	State = state:init_state(),
	case {W1,W2} of
		{no_evaluation,no_evaluation} -> E1=no_evaluation, E2=no_evaluation;
		{no_evaluation,_} -> E1=no_evaluation,E2={given_W,W2};
		{_,no_evaluation} -> E1={given_W,W1},E2=no_evaluation;
		{_,_} -> E1={given_W,W1},E2={given_W,W2}
	end, 
	{Res1,{_,_,_,_,_,W11},{_,_,_,_,_,W22}} = game:run(State,evil_bot,E1,evil_bot,E2),
	{Res2,_,_} = game:run(State,evil_bot,{given_W,W22},evil_bot,{given_W,W11}),
	Coeffs2 = case {Res1,Res2} of
		{Same,Same} ->             L1++L2++[W11,W22];
		{blacks_won,whites_won} -> L1++L2++[W11,get_w2(W11,W22,lost_lost)];
		{whites_won,blacks_won} -> L1++L2++[W22,get_w2(W22,W11,lost_lost)];
		{blacks_won,draw} ->       L1++L2++[W11,get_w2(W11,W22,lost_draw)];
		{whites_won,draw} ->	   L1++L2++[W22,get_w2(W22,W11,lost_draw)];
		{draw,blacks_won} ->	   L1++L2++[W22,get_w2(W22,W11,lost_draw)];
		{draw,whites_won} ->	   L1++L2++[W11,get_w2(W11,W22,lost_draw)]
	end,
	run_matches(Nbr_matches-1,Coeffs2,Stat_file,Feat1,Feat2).



get_w2(Won,Lost,lost_lost) -> get_w2(Won,Lost,lost_draw);

get_w2(Won,Lost,lost_draw) -> 
	lists:foldl(fun(Feat,Acc) ->
		V1 = dict:fetch(Feat,Won), V2 = dict:fetch(Feat,Lost),
		dict:store(Feat,(V1+V2)/2,Acc)
	end,dict:new(),dict:fetch_keys(Lost)
	).



log_features(File,Coeffs,Feat1,Feat2) -> ok.

