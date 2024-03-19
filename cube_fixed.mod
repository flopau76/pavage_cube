# Same as cube.mod but by arbitrarily fixing the first piece, reducing the possibility space

## sets and parameters
# size of the problem
param size_cube;
param nb_pieces;
param size_piece;
set space:= {x in 0..size_cube-1, y in 0..size_cube-1, z in 0..size_cube-1};

# precomputed rotation matrices: R[a,b,c] = Rx^a * Ry^b * Rz^c
param R{0..3, 0..3, 0..1, 1..3, 1..3} default 0;

# description of a piece: piece[c] = (X_1,X_2,X_3)
param piece{1..size_piece, 1..3} integer;

## decision variables
var translation{1..nb_pieces, 1..3} integer >=0 <=size_cube-1; # position of the extremity
var rot{1..nb_pieces, 0..3, 0..3, 0..1} binary; # which precomputed rotation_matrix to use
var rotation_matrix{1..nb_pieces, 1..3, 1..3};  # integer <=1 >=-1

var dist{1..nb_pieces, 1..size_piece, space};
var position{1..nb_pieces, 1..size_piece, space} binary;

var dist2obj{space};

minimize empty_cubes: sum{(x,y,z) in space} dist2obj[x,y,z];

## constraints
# dist2obj[x,y,z] = |sum{p in 1..nb_pieces, c in 1..size_piece} position[p,c,x,y,z] -1|
subject to dist2obj1{(x,y,z) in space}:
   (sum{p in 1..nb_pieces, c in 1..size_piece} position[p,c,x,y,z]) -1 <= dist2obj[x,y,z];

subject to dist2obj2{(x,y,z) in space}:
   -dist2obj[x,y,z] <= (sum{p in 1..nb_pieces, c in 1..size_piece} position[p,c,x,y,z]) -1;

#rotation decomposition
subject to unique_rotation_decomposition{p in 1..nb_pieces}:
    sum{a in 0..3, b in 0..3, c in 0..1} rot[p,a,b,c] = 1;

subject to unique_rotation{p in 1..nb_pieces, i in 1..3, j in 1..3}:
    rotation_matrix[p,i,j] = sum{a in 0..3, b in 0..3, c in 0..1} rot[p,a,b,c]*R[a,b,c,i,j];

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

# fix first piece: might reduce possibility space
subject to fix_translation{d in 1..3}:
    translation[1,d] = 0;
subject to fix_rotation:
    rot[1,0,0,0] = 1;