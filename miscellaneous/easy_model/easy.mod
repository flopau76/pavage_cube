# Simplified problem: without rotation
# First implementation: MINLP -> baron

## sets and parameters
param size_cube;
param nb_pieces;
param size_piece;
set space:= {x in 0..size_cube-1, y in 0..size_cube-1, z in 0..size_cube-1};

# description of a piece: piece[c] = (X_1,X_2,X_3)
param piece{1..size_piece, 1..3} integer;

## decision variables
var translation{1..nb_pieces, 1..3} integer >=0 <=size_cube-1; # position of extremity
# no rotation

var dist{1..nb_pieces, 1..size_piece, space} integer;
var position{1..nb_pieces, 1..size_piece, space} binary;

minimize empty_cubes: sum{(x,y,z) in space}
    ((sum{p in 1..nb_pieces, c in 1..size_piece} position[p,c,x,y,z])-1)**2;

## constraints
# square norm
# subject to distances{p in 1..nb_pieces, c in 1..size_piece, (x,y,z) in space}:
#     dist[p,c,x,y,z] = (piece[c,1] + translation[p,1] - x)**2 + (piece[c,2] + translation[p,2] - y)**2 + (piece[c,3] + translation[p,3] - z)**2;

# infinity norm
# A.p + T -(x,y,z)
subject to distances1a{p in 1..nb_pieces, c in 1..size_piece, (x,y,z) in space}:
    -dist[p,c,x,y,z] <= piece[c,1] + translation[p,1] - x;
subject to distances1b{p in 1..nb_pieces, c in 1..size_piece, (x,y,z) in space}:
    piece[c,1] + translation[p,1] - x <= dist[p,c,x,y,z];

subject to distances2a{p in 1..nb_pieces, c in 1..size_piece, (x,y,z) in space}:
    -dist[p,c,x,y,z] <= piece[c,2] + translation[p,2] - y;
subject to distances2b{p in 1..nb_pieces, c in 1..size_piece, (x,y,z) in space}:
    piece[c,2] + translation[p,2] - y <= dist[p,c,x,y,z];

subject to distances3a{p in 1..nb_pieces, c in 1..size_piece, (x,y,z) in space}:
    -dist[p,c,x,y,z] <= piece[c,3] + translation[p,3] - z;
subject to distances3b{p in 1..nb_pieces, c in 1..size_piece, (x,y,z) in space}:
    piece[c,3] + translation[p,3] - z <= dist[p,c,x,y,z];

# dist = 0 -> position = 1
subject to movement1{p in 1..nb_pieces, c in 1..size_piece, (x,y,z) in space}:
    1-position[p,c,x,y,z] <= dist[p,c,x,y,z];

# dist > 0 -> position[p,x,y,z] = 0
subject to movement2{p in 1..nb_pieces, c in 1..size_piece, (x,y,z) in space}:
    dist[p,c,x,y,z] <= 100*(1-position[p,c,x,y,z]);


data miscellaneous/easy_model/easy.dat;
option solver cplex;
solve;
display empty_cubes, translation;
option omit_zero_rows 1;
display position;