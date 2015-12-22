%
%   Gomoku-2 
%	Continued: December 2015
%	
%   This is a simple random agent
%   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

-module(randy_bot).
-export([init_evaluation/2,
		get_move/2,
		change_evaluation/2
		]).


init_evaluation(_,_State) -> nothing.



get_move({Turn,_,Board},_Evaluation) -> 
	Size = min(7,round(math:sqrt(2*Turn))),
	get_rand_move(Size,Size*Size,Board).

get_rand_move(7,0,Board) -> get_rand_move(7,49,Board);
get_rand_move(Size,0,Board) -> get_rand_move(Size+1,(Size+1)*(Size+1),Board);
get_rand_move(Size,N_attempts,Board) ->
	I = 8 - Size + random:uniform(2*Size-1),
	J = 8 - Size + random:uniform(2*Size-1),
	case element(I,element(J,Board)) of
		e -> {I,J};
		_ -> get_rand_move(Size,N_attempts-1,Board)
	end.



% internal representation of the state. It may contain 
% different parameters reflecting evaluation of the current state
% random agent does not use any such information
change_evaluation(_PrevEval, _Move) -> no_change.



