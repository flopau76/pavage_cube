import numpy as np
from numpy.linalg import matrix_power
import matplotlib.pyplot as plt
import mayavi.mlab as mlab  # better than pyplot for 3d plot


Rx = np.array([[1,0,0],[0,0,-1],[0,1,0]])
Ry = np.array([[0,0,1],[0,1,0],[-1,0,0]])
Rz = np.array([[0,-1,0],[1,0,0],[0,0,1]])

def coeff_to_matrix(coeff):
    return matrix_power(Rx, coeff[0]) @ matrix_power(Ry,coeff[1]) @ matrix_power(Rz,coeff[2])

def get_position(piece, translation, rotation):
    res = []
    for c in piece:
        res.append(rotation @ c + translation)
    return np.array(res, dtype=int)

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

def draw_cube(piece, T,R):
    """3d plot using matplotlib: has some display artifacts were a back object is displayed in front of a front object"""
    n = len(R)
    colors = plt.cm.jet(np.linspace(0,1,n))
    print(colors)
    fig = plt.figure()
    ax = plt.axes(projection='3d')
    for i in range(n):
        position = get_position(piece, T[i],R[i])
        print(position)
        ax.plot3D(position[:,0], position[:,1], position[:,2], color=colors[i], linewidth=5)
    plt.show()

def draw_cube2(piece, T,R):
    n = len(R)
    colors = [plt.cm.get_cmap('Spectral')(i/(n-1))[:3] for i in range(n) ]
    print(colors)
    for i in range(len(T)):
        position = get_position(piece, T[i],R[i])/4 # necessity to be between 0 and 1 to work with mlab
        print(position)
        mlab.plot3d(position[:,0], position[:,1], position[:,2], color=colors[i])
        # mlab.points3d(position[:,0], position[:,1], position[:,2], color=colors[i])
    mlab.show()
        

if __name__ == '__main__':

    piece3 = [[0,1,0],[0,0,0],[0,0,1]]
    piece4 = [[0,1,0],[0,0,0],[0,0,2]]
    piece41 = [[0,1,1],[0,0,1],[0,0,0],[0,0,2]]

    T3, R3 = read_result('cube3x3.res')
    T4, R4 = read_result('cube4x4.res')

    draw_cube(piece3, T3, R3)
    draw_cube(piece4, T4, R4)