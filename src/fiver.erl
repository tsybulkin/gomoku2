%
%   Gomoku-2 
%	Continued: December 2015
%	
%   This is an agent making decisions on the basis
%   of position evaluation. Neither learning, nor game tree search are used.
%   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


-module(fiver).
-export([state/1
		]).


state(Fiver) -> state(free,Fiver).

state(State,[e|Fiver]) -> state(State,Fiver);
state(free,[b|Fiver]) -> state(b_singlet,Fiver);
state(free,[w|Fiver]) -> state(w_singlet,Fiver);

state(b_singlet,[w|Fiver]) -> mixed;
state(w_singlet,[b|Fiver]) -> mixed;
state(b_singlet,[b|Fiver]) -> state(b_duplet,Fiver);
state(w_singlet,[w|Fiver]) -> state(w_duplet,Fiver);

state(b_duplet,[w|Fiver]) -> mixed;
state(w_duplet,[b|Fiver]) -> mixed;
state(b_duplet,[b|Fiver]) -> state(b_triplet,Fiver);
state(w_duplet,[w|Fiver]) -> state(w_triplet,Fiver);

state(b_triplet,[w|Fiver]) -> mixed;
state(w_triplet,[b|Fiver]) -> mixed;
state(b_triplet,[b|Fiver]) -> state(b_quartet,Fiver);
state(w_triplet,[w|Fiver]) -> state(w_quartet,Fiver);

state(b_quartet,[w|Fiver]) -> mixed;
state(w_quartet,[b|Fiver]) -> mixed;
state(b_quartet,[b|Fiver]) -> state(b_quintet,Fiver);
state(w_quartet,[w|Fiver]) -> state(w_quintet,Fiver);

state(State,[]) -> State.