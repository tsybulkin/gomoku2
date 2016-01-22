%
%   Gomoku-2 
%	Continued: December 2015
%	
%   This modules deals with a single game played
%   betwen two selected agents
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

-module(game).
-export([run/2,
		run_match/3
		]).


% runs a single game between Black agent and White agent
% Any agent should have tree methods:
%   - init_evaluation(Color,State)
%   - change_evaluation(State,Move)
%   - get_move(State, Evaluation)
%
% returns blacks_won, whites_won, or draw
run(Blacks,Whites) ->
	State = state:init_state(),
	run(State,Blacks,no_evaluation,[],Whites,no_evaluation,[]).

run({Turn,_,Board}=State,Blacks,B_eval,TrainingSetB,Whites,W_eval,TrainingSetW) ->
	Color = state:color(Turn),
	state:print_board(Board),
	case Color of
		blacks -> {Move,B_eval1,TrainingCases} = Blacks:get_move(State,B_eval), W_eval1=W_eval;
		whites -> {Move,W_eval1,TrainingCases} = Whites:get_move(State,W_eval), B_eval1=B_eval
	end,

	case state:change_state(State,Move) of
		{whites_won,_Fiver} -> 
			Blacks:learn_dataset(TrainingSetB),
			Whites:learn_dataset(TrainingSetW),
			whites_won;
			
		{blacks_won,_Fiver} -> 
			Blacks:learn_dataset(TrainingSetB),
			Whites:learn_dataset(TrainingSetW),
			blacks_won;

		draw -> 
			Blacks:learn_dataset(TrainingSetB),
			Whites:learn_dataset(TrainingSetW),
			draw;
		NextState -> 
			case Color of
				blacks ->
					io:format("(~p) Blacks' move: ~p~n",[Turn,state:convert(Move)]),
					run(NextState,Blacks,B_eval1,TrainingCases++TrainingSetB,Whites,W_eval1,TrainingSetW);
				whites ->
					io:format("(~p) Whites' move: ~p~n",[Turn,state:convert(Move)]), 
					run(NextState,Blacks,B_eval1,TrainingSetB,Whites,W_eval1,TrainingCases++TrainingSetW)
			end
	end.



% returns score
run_match(Blacks,Whites,Game_number) -> run_match(Blacks,Whites,Game_number,0,0,0).

run_match(_,_,0,B_won,Draw,W_won) -> {B_won,Draw,W_won};
run_match(Blacks,Whites,Game_number,B_won,Draw,W_won) ->
	case run(Blacks,Whites) of
		blacks_won -> run_match(Blacks,Whites,Game_number-1,B_won+1,Draw,W_won);
		whites_won -> run_match(Blacks,Whites,Game_number-1,B_won,Draw,W_won+1);
		draw -> run_match(Blacks,Whites,Game_number-1,B_won,Draw+1,W_won)
	end.




