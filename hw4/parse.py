__author__="Adam Reis <ahr2127@columbia.edu> and Gabriel Blanco <gab2135@columbia.edu"
__date__ ="$Nov 5, 2013"

import sys
import pdb

obstacles = []

def parse_list(input_file):
	input_file.seek(0,0)

	num_obstacles = int(input_file.readline().strip())
	global obstacles

	for j in range(num_obstacles):
		num_vertices = int(input_file.readline().strip())
		tmp = []

		for i in range(num_vertices):
			x, y = [float(k) for k in input_file.readline().rstrip().split()]
			tmp.append((x,y))

		obstacles.append(tmp)
	return obstacles

def expand_vertices(robot):
	refl_robot = [(-x,-y) for x,y in robot]
	print obstacles[4]

	exp_obstacles = []

	for obstacle in obstacles:

		exp_tmp = []

		for j in obstacle:

			for i in refl_robot:

				exp_x = float(j[0]+i[0])
				exp_y = float(j[1]+i[1])

				exp_tmp.append((exp_x,exp_y))

		print "Obstacle: {}\n".format(obstacle)
		print "Expanded: {}\n".format(exp_tmp)

		exp_obstacles.append(exp_tmp)



if __name__ == "__main__":
	with open(sys.argv[1]) as input_file:
		parse_list(input_file)	

		robot = [(0,0),(0,-0.34),(-0.34,-0.34),(-0.34,0)]

		expand_vertices(robot)
