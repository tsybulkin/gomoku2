%
%   Gomoku-2 
%	Continued: December 2015
%	
%   This modules deals with moves
%   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


-module(moves).
-export([get_candidate_moves/1
		]).





get_candidate_moves({Turn,_,Board}) ->
	Size = 1+min(7,round(math:sqrt(Turn))),
	%Color = own_color(Turn),
	lists:usort(lists:foldl(fun({I,J},Acc)->
		case element(I,element(J,Board)) of
			e -> if abs(I-8)<Size andalso abs(J-8)<Size -> [{I,J}|Acc]; true -> Acc end;
			_ -> if abs(I-8)+1<Size andalso abs(J-8)+1<Size -> Acc; true -> get_arround({I,J},2,Board)++Acc end
		end
	end,[],[{I,J} || I<-lists:seq(1,15), J<-lists:seq(1,15) ])).
	


get_arround({X,Y},Size,Board) ->
	lists:filter(fun({X1,Y1})->
		if 
			X1<1 orelse Y1<1 orelse X1>15 orelse Y1>15 -> false;
			element(X1,element(Y1,Board)) =/= e -> false;
			true -> true
		end
	end, [{X-Size+I,Y-Size+J} || I<-lists:seq(1,2*Size-1), J<-lists:seq(1,2*Size-1)]).



%own_color(Turn) when Turn rem 2 =:= 0 -> w;
%own_color(_) -> b.

