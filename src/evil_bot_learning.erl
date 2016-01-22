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
	Coeffs = lists:duplicate(Nbr_agents,no_evaluation),
	Stat_file = "data/stat_file.dat",
	run_matches(Nbr_matches,Coeffs,Stat_file,Feat1,Feat2).


run_matches(0,_Coeffs,Stat_file,_,_) -> 
	io:format("All matches done. Results are in ~p file~n",[Stat_file]);

run_matches(Nbr_matches,Coeffs,Stat_file,Feat1,Feat2) ->
	[W1|Coeff1] = Coeffs,
	{L1,[W2|L2]} = lists:split(random:uniform(length(Coeff1)-1),Coeff1),

	State = state:init_state(),
	case {W1,W2} of
		{no_evaluation,no_evaluation} -> game:run(evil_bot,evil_bot);
		{no_evaluation,_} -> game:run(State,evil_bot,no_evaluation,evil_bot,{given_W,W2});
		{_,no_evaluation} -> game:run(State,evil_bot,{given_W,W1},evil_bot,no_evaluation);
		{_,_} -> game:run(State,evil_bot,{given_W,W1},evil_bot,{given_W,W2})
	end.

