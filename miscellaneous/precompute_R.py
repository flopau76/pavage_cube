# file to precompute the possible rotations

import numpy as np
from numpy.linalg import matrix_power

Rx = np.array([[1,0,0],[0,0,-1],[0,1,0]])
Ry = np.array([[0,0,1],[0,1,0],[-1,0,0]])
Rz = np.array([[0,-1,0],[1,0,0],[0,0,1]])

# all possible rotations
def write_all(file):
    f = open(file, "w")
    f.write("param R:=\n")
    for i in range(4):
        for j in range(4):
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
def write_elem(file):
    f = open(file, "w")
    f.write("param R:=\n")
    for mat in range(3):
        for pow in range(4):
            matmat = matrix_power([Rx,Ry,Rz][mat], pow)
            for row in range(3):
                for col in range(3):
                    L = [mat+1,pow,row+1,col+1, matmat[row,col]]
                    f.write(' '.join([str(x) for x in L]))
                    f.write('\n')
    f.write(';')
    f.close()

# test the number of unnique decompositions
ids = []
Res = []
for i in range(4):
    for j in range(4):
        for k in range(2):
            mat = matrix_power(Rx, i) @ matrix_power(Ry,j) @ matrix_power(Rz,k)
            it = 0
            while it<len(Res) and (Res[it]!=mat).any():
                it+=1
            if it==len(Res):
                Res.append(mat)
                ids.append([i,j,k])
print(len(Res))
for tup in ids:
    print(tup)

write_all("R.dat")     