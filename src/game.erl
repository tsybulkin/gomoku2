%
%   Gomoku-2 
%	Continued: December 2015
%	
%   This modules deals with a single game played
%   betwen two selected agents
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

-module(game).
-export([
		]).


% runs a single game between Black agent and white agent
% returns blacks_won, whites_won, or draw
run(Blacks,Whites) ->
	State = state:init_state(),
	B_state = Blacks:init_state(blacks,State),
	W_state = Whites:init_state(whites,State),
	run(State,Blacks,B_state,Whites,W_state).

run({Turn,LastMove,Board},Blacks,B_state,Whites,W_state) ->
