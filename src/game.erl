%
%   Gomoku-2 
%	Continued: December 2015
%	
%   This modules deals with a single game played
%   betwen two selected agents
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

-module(game).
-export([run/2
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
	run(State,Blacks,no_evaluation,Whites,no_evaluation).

run({Turn,_,_}=State,Blacks,B_eval,Whites,W_eval) when Turn rem 2 =:= 0 ->
	{Move,W_eval1} = Whites:get_move(State,W_eval),
	case state:change_state(State,Move) of
		{whites_won,_Fiver} -> whites_won;
		draw -> draw;
		NextState -> 
			io:format("(~p) Whites' move: ~p~n",[Turn,convert(Move)]),
			run(NextState,Blacks,B_eval,Whites,W_eval1)
	end;
run({Turn,_,_}=State,Blacks,B_eval,Whites,W_eval) ->
	{Move,B_eval1} = Blacks:get_move(State,B_eval),
	case state:change_state(State,Move) of
		{blacks_won,_Fiver} -> blacks_won;
		draw -> draw;
		NextState -> 
			io:format("(~p) Blacks' move: ~p~n",[Turn,convert(Move)]),
			run(NextState,Blacks,B_eval1,Whites,W_eval)
	end.



convert({I,J}) -> [lists:nth(I,"abcdefghijklmno")|integer_to_list(J)].
