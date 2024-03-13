import numpy as np
from numpy.linalg import matrix_power
import matplotlib.pyplot as plt

Rx = np.array([[1,0,0],[0,0,-1],[0,1,0]])
Ry = np.array([[0,0,1],[0,1,0],[-1,0,0]])
Rz = np.array([[0,-1,0],[1,0,0],[0,0,1]])

def coeff_to_matrix(coeff):
    return matrix_power(Rx, coeff[0]) @ matrix_power(Ry,coeff[1]) @ matrix_power(Rz,coeff[2])

def read_result(file):
    print(f"Reading file: {file}")
    translation = []
    rotation = []
    with open(file, 'r') as f:
        for line in f:
            if line.startswith('#'):
                continue
            if line.startswith('trans'):
                header = f.readline()
                end = False
                while not end:
                    line = f.readline()
                    if ";" in line:
                        end = True
                        break
                    line = line.split()
                    translation.append([float(x) for x in line[1:]])
            elif line.startswith('rot'):
                # header = f.readline()
                end = False
                while not end:
                    line = f.readline()
                    if ";" in line:
                        end = True
                        break
                    line = line.split()
                    rotation.append([int(x) for x in line[1:-1]])
        translation = np.array(translation)
        rotation = [coeff_to_matrix(r) for r in rotation]
        return translation, rotation

def get_position(piece, translation, rotation):
    res = []
    for c in piece:
        res.append(rotation @ c + translation)
    return np.array(res, dtype=int)

def draw_piece(piece, color='b', axes=None):
    if axes is not None:
        ax = axes
    else:
        fig = plt.figure()
        ax = plt.axes(projection='3d')
    ax.plot3D(piece[:,0], piece[:,1], piece[:,2], color)

def draw_cube(piece, T,R):
    n = len(R)
    colors = plt.cm.jet(np.linspace(0,1,n))
    print(colors)
    fig = plt.figure()
    ax = plt.axes(projection='3d')
    for i in range(n):
        piece = get_position(piece, T[i],R[i])
        ax.plot3D(piece[:,0], piece[:,1], piece[:,2], color=colors[i])
    plt.show()
        

if __name__ == '__main__':

    piece3 = [[0,0,1],[0,0,0],[0,1,0]]
    piece4 = [[0,1,0],[0,0,0],[0,0,2]]

    T, R = read_result('cube3x3.res')
    piece = np.array(piece3)
    
    draw_cube(piece, T,R)