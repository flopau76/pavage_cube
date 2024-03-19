import numpy as np
from numpy.linalg import matrix_power
import matplotlib.pyplot as plt
import mayavi.mlab as mlab  # better than pyplot for 3d plot
from math import sqrt
import sys, os
import argparse


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

def draw_cube1(piece, T,R):
    """3d plot using matplotlib: has some display artifacts were a back object is displayed in front of a front object"""
    n = len(R)
    colors = plt.cm.jet(np.linspace(0,1,n))
    fig = plt.figure()
    ax = plt.axes(projection='3d')
    for i in range(n):
        position = get_position(piece, T[i],R[i])
        print(position)
        ax.plot3D(position[:,0], position[:,1], position[:,2], color=colors[i], linewidth=5)
        #ax.scatter(position[:,0], position[:,1], position[:,2], color=colors[i], s=100)
    plt.show()

def draw_cube2(piece, T,R):
    """3d plot using mayavi: better display than matplotlib, but may be harder to install."""
    n = len(R)
    m = sqrt(n)-1
    colors = plt.cm.jet(np.linspace(0,1,n))
    colors = [tuple(c) for c in colors[:,:3]]
    for i in range(len(T)):
        position = get_position(piece, T[i],R[i])
        print(position)
        position = position/m # necessity to be between 0 and 1 to work with mlab
        mlab.plot3d(position[:,0], position[:,1], position[:,2], color=colors[i])
        # mlab.points3d(position[:,0], position[:,1], position[:,2], color=colors[i])
    mlab.show()

piece3 = [[0,1,0],[0,0,0],[0,0,1]]
piece4 = [[0,1,0],[0,0,0],[0,0,2]]
piece4_T = [[0,1,1],[0,0,1],[0,0,0],[0,0,2]]
piece5 = [[0,1,0],[0,0,0],[0,0,3]]
        
if __name__ == '__main__':
    """ Chose wich function to use, depending if you succeded to install mayavi or not."""
    # draw_cube = draw_cube1
    draw_cube = draw_cube2

    folder = "/home/flopau/Documents/3A/P2/INF580_math_optimisation/test_cube/res_auto/"

    T, R = read_result(folder + '4x4_T.res')
    draw_cube(piece4_T, T, R)

    T, R = read_result(folder + '4x4.res')
    draw_cube(piece4, T, R)