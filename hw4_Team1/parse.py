__author__="Adam Reis <ahr2127@columbia.edu> and Gabriel Blanco <gab2135@columbia.edu"
__date__ ="$Nov 5, 2013"

import sys

def parse_list(input_file):
	input_file.seek(0,0)

	num_obstacles = int(input_file.readline().strip())
	obstacles = []

	for j in range(num_obstacles):
		num_vertices = int(input_file.readline().strip())
		tmp = []

		for i in range(num_vertices):
			x, y = [float(k) for k in input_file.readline().rstrip().split()]
			tmp.append((x,y))

		obstacles.append(tmp)

if __name__ == "__main__":
	with open(sys.argv[1]) as input_file:
		parse_list(input_file)	
