# file to precompute the possible rotations

import numpy as np
from numpy.linalg import matrix_power

Rx = np.array([[1,0,0],[0,0,-1],[0,1,0]])
Ry = np.array([[0,0,1],[0,1,0],[-1,0,0]])
Rz = np.array([[0,-1,0],[1,0,0],[0,0,1]])

# all possible rotations
f = open("Rotation.dat", "w")
f.write("param R:=\n")
for i in range(4):
    for j in range(3):
        for k in range(2):
            mat = matrix_power(Rx, i) @ matrix_power(Ry,j) @ matrix_power(Rz,k)
            print(i,j,k)
            print(mat)
            for row in range(3):
                for col in range(3):
                    L = [i,j,k,row+1,col+1, mat[row,col]]
                    f.write(' '.join([str(x) for x in L]))
                    f.write('\n')
f.write(';')
f.close()

# only the elementary rotations and their powers
f = open("Rotation2.dat", "w")
f.write("param R:=\n")
for mat in range(3):
    for i in range(4):
        matmat = matrix_power([Rx,Ry,Rz][mat], i)
        for row in range(3):
            for col in range(3):
                L = [mat+1,i,row+1,col+1, matmat[row,col]]
                f.write(' '.join([str(x) for x in L]))
                f.write('\n')
f.write(';')
f.close()