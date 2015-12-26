%
%	Gomoku 
%	Continued: September 2015
%	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

-module(lines).
-export([check_five/1,
		extract_vert_lines/2,
		extract_hor_lines/2,
		extract_diagonals1/1,
		extract_diagonals2/1
		]).



check_five({Turn,_,Board}) -> 
	case state:color(Turn) of
		blacks -> check_five(board, w,Board);
		whites -> check_five(board, b,Board)
	end.

check_five(board,Color,Board) ->
	check_five(lines,Color,extract_lines(Board));

check_five(lines,Color,[{{X1,Y1},{X2,Y2},Line}|Lines]) ->
	case check_five_in_line(0,1,Color,Line) of
		false-> check_five(lines,Color,Lines);
		Index -> [index_to_XY({X1,Y1},{X2,Y2},Index-J) || J <- lists:seq(0,4)]
	end;
check_five(lines,_,[]) -> false.

check_five_in_line(5,Index,_,_) -> Index-1;
check_five_in_line(Count,J,Color,[Stone|Line]) ->
	case Stone == Color of
		true -> check_five_in_line(Count+1,J+1,Color,Line);
		false-> check_five_in_line(0,J+1,Color,Line)
	end;
check_five_in_line(_,_,_,[]) -> false.

	

extract_lines(Board) ->
	extract_vert_lines(15,Board) ++
	extract_hor_lines(15,Board) ++
	extract_diagonals1(Board)++
	extract_diagonals2(Board).


extract_vert_lines(0,_) -> [];
extract_vert_lines(N,Board) -> [{ {N,15}, {N,1}, lists:foldl(fun(I,Acc) -> [element(N,element(I,Board))|Acc] 
				end, [], lists:seq(1,15)) } | extract_vert_lines(N-1,Board) ].

extract_hor_lines(0,_) -> [];
extract_hor_lines(N,Board) -> 
	[ { {1,N}, {15,N}, tuple_to_list(element(N, Board)) } | extract_hor_lines(N-1,Board) ].


extract_diagonals1(Board) ->
	[{{1,1-H},{15+H,15},[ element(I, element(I-H,Board)) || I <- lists:seq(1,15+H) ]} || H <- lists:seq(-10,0) ] ++
	[{{1+H,1},{15,15-H},[ element(I, element(I-H,Board)) || I <- lists:seq(1+H,15) ]} || H <- lists:seq(1,10) ].

extract_diagonals2(Board) ->
	[{{1,H-1},{H-1,1},[ element(I, element(H-I,Board)) || I <- lists:seq(1,H-1) ]} || H <- lists:seq(6,16) ] ++
	[{{H-15,15},{15,H-15},[ element(I, element(H-I,Board)) || I <- lists:seq(H-15,15) ]} || H <- lists:seq(17,26) ].
	


index_to_XY({X1,Y1},{X2,Y2},Index) ->
	if X2>X1 -> Dx=1; X2<X1 -> Dx=-1; true -> Dx=0 end,
	if Y2>Y1 -> Dy=1; Y2<Y1 -> Dy=-1; true -> Dy=0 end,
	{X1+Dx*(Index-1),Y1+Dy*(Index-1)}.


