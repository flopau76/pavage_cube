# Normal problem: translation and rotation

# test one: rotation = matrix: need constraints to ensure it is a rotation matrix (# det(A)=1 and A* A.T = I); too many parameters
# test two: rotation = (a,b,c) decomposition into Rx^a * Ry^b * Rz^c
# several possibilities:  -store only Rx, Ry, Rz
#                         -store  Rx, Ry, Rz and there powers
#                         -precompute and store all possible rotations (via python)

# here: store all possible rotations (via python): error running cplex: termination code 9 (aka insufficient memory)


## sets and parameters
# size of the problem
param size_cube;
param nb_pieces;
param size_piece;
set space:= {x in 0..size_cube-1, y in 0..size_cube-1, z in 0..size_cube-1};

# precomputed rotation matrices: R[a,b,c] = Rx^a * Ry^b * Rz^c
param R{0..3, 0..2, 0..1, 1..3, 1..3} default 0;

# description of a piece: piece[c] = (X_1,X_2,X_3)
param piece{1..size_piece, 1..3} integer;

## decision variables
var translation{1..nb_pieces, 1..3} integer >=0 <=size_cube-1; # position of the extremity
var rot{1..nb_pieces, 0..3, 0..2, 0..1} binary; # which precomputed rotation_matrix to use
var rotation_matrix{1..nb_pieces, 1..3, 1..3};  # integer <=1 >=-1

var dist{1..nb_pieces, 1..size_piece, space};
var position{1..nb_pieces, 1..size_piece, space} binary;

var occupation{space};

minimize empty_cubes: sum{(x,y,z) in space}
    sum{p in 1..nb_pieces, c in 1..size_piece} occupation[x,y,z];

## constraints
# occupation[x,y,z] = |sum{p in 1..nb_pieces, c in 1..size_piece} position[p,c,x,y,z] -1|
subject to occupation1{(x,y,z) in space}:
   sum{p in 1..nb_pieces, c in 1..size_piece} position[p,c,x,y,z] -1 <= occupation[x,y,z];

subject to occupation2{(x,y,z) in space}:
   -occupation[x,y,z] <= sum{p in 1..nb_pieces, c in 1..size_piece} position[p,c,x,y,z] -1;

#rotation decomposition
subject to unique_rotation_decomposition{p in 1..nb_pieces}:
    sum{l in 0..3, m in 0..2, n in 0..1} rot[p,l,m,n] = 1;

subject to unique_rotation{p in 1..nb_pieces, i in 1..3, j in 1..3}:
    rotation_matrix[p,i,j] = sum{l in 0..3, m in 0..2, n in 0..1} rot[p,l,m,n]*R[l,m,n,i,j];

# infinity norm between A.p + T and (x,y,z)
subject to distances1a{p in 1..nb_pieces, c in 1..size_piece, (x,y,z) in space}:
    -dist[p,c,x,y,z] <= sum{k in 1..3} rotation_matrix[p,1,k] * piece[c,k] + translation[p,1] - x;
subject to distances1b{p in 1..nb_pieces, c in 1..size_piece, (x,y,z) in space}:
    sum{k in 1..3} rotation_matrix[p,1,k] * piece[c,k] + translation[p,1] - x <= dist[p,c,x,y,z];

subject to distances2a{p in 1..nb_pieces, c in 1..size_piece, (x,y,z) in space}:
    -dist[p,c,x,y,z] <= sum{k in 1..3} rotation_matrix[p,2,k] * piece[c,k] + translation[p,2] - y;
subject to distances2b{p in 1..nb_pieces, c in 1..size_piece, (x,y,z) in space}:
    sum{k in 1..3} rotation_matrix[p,2,k] * piece[c,k] + translation[p,2] - y <= dist[p,c,x,y,z];

subject to distances3a{p in 1..nb_pieces, c in 1..size_piece, (x,y,z) in space}:
    -dist[p,c,x,y,z] <= sum{k in 1..3} rotation_matrix[p,3,k] * piece[c,k] + translation[p,3] - z;
subject to distances3b{p in 1..nb_pieces, c in 1..size_piece, (x,y,z) in space}:
    sum{k in 1..3} rotation_matrix[p,3,k] * piece[c,k] + translation[p,3] - z <= dist[p,c,x,y,z];

# dist = 0 -> position = 1
subject to movement1{p in 1..nb_pieces, c in 1..size_piece, (x,y,z) in space}:
    1-position[p,c,x,y,z] <= dist[p,c,x,y,z];

# dist > 0 -> position[p,x,y,z] = 0
subject to movement2{p in 1..nb_pieces, c in 1..size_piece, (x,y,z) in space}:
    dist[p,c,x,y,z] <= 100*(1-position[p,c,x,y,z]);

# # each piece has a unique position
# subject to unique_position{p in 1..nb_pieces, c in 1..size_piece}:
#     sum{(x,y,z) in space} position[p,c,x,y,z] = 1;

# # each square is occupated by at most one piece
# subject to max_occupation{(x,y,z) in space}:
#     sum{p in 1..nb_pieces, c in 1..size_piece } position[p,c,x,y,z] = 1;

option cplex_options 'mipdisplay 2 mipinterval 1000';   # to display computation options

data test_cube/cube4x4.dat;
option solver cplex;
solve;
display empty_cubes, translation;
option omit_zero_rows 1;
display rot;