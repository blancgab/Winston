__author__ = "$Adam Reis <ahr2127@columbia.edu>, Gabriel Blanco <gab2135@columbia.edu>, Sophie Chou <sbc2125@columbia.edu>"
__date__ = "$Nov 5, 2013"

try:
	from tkinter import *
except ImportError:
	from Tkinter import *
try:
	from tkinter.filedialog import askopenfilename
except ImportError:
	from tkFileDialog import askopenfilename
try:
	from tkinter.messagebox import *
except ImportError:
	from tkMessageBox import *

from sys import stdin
import pdb
import math
import numpy

class ObstacleGraph:
	"""
	Graphs a room and a bunch of objects in a GUI!
	"""
	def __init__(self, obstacle_file):
		self.width = 1000
		self.exp_obstacles = []

		self.root = Tk()
		self.root.title("Adam and Gabe's Obstacle Graph")
		self.root.focus_force()
		self.canvas = Canvas(self.root, width=self.width, height=self.width)
		self.canvas.pack()

		self.obstacles = parse_list(obstacle_file)
		self.calc_frame()

		self.start	  = (-3.107,  0.58)
		self.end 	  = (10.657, -0.03)

		# self.robot = make_ngon(.17,16)
		self.robot	  = [(.17,.17),(.17,-.17),(-.17,-.17),(-.17,.17)]	
		self.expanded = self.expand_vertices()
		self.grown	  = grahams_alg(self.expanded)
		self.edges    = self.remove_collisions()

		self.draw_all()
		print 'done drawing'
		self.root.mainloop()


	def calc_frame(self):
		room = self.obstacles[0]
		up_bound	= min([-i[1] for i in room])
		low_bound   = max([-i[1] for i in room])
		left_bound  = min([-i[0] for i in room])
		right_bound = max([-i[0] for i in room])

		max_range = max((abs(up_bound-low_bound),abs(left_bound-right_bound)))
		self.scaler = .9*(self.width/max_range)

		mid_x = (left_bound+right_bound)/2
		mid_y = (up_bound+low_bound)/2
		self.x_offset = -mid_x*self.scaler
		self.y_offset = -mid_y*self.scaler

	def expand_vertices(self):
		refl_robot = [(-x,-y) for x,y in self.robot]
		exp_obstacles = []

		for obstacle in self.obstacles[1:]:
			tmp = []

			for op in obstacle:
				tmp.append((op[0],op[1]))

				for rp in refl_robot:
					x = float(op[0]+rp[0])
					y = float(op[1]+rp[1])
					tmp.append((x,y))	

			exp_obstacles.append(tmp)
		return exp_obstacles

	def draw_all(self):
		self.draw_obstacle(self.obstacles[0],'red')	

		for g_obstacle in self.grown:
			self.draw_obstacle(g_obstacle, 'blue', 'light blue')

		for obstacle in self.obstacles[1:]:
			self.draw_obstacle(obstacle, 'black')

		for edge in self.edges:
			self.draw_line(edge)

		self.draw_point(self.start, 'green','black',3)
		self.draw_point(self.end,   'green','black',3)
		self.draw_point((0,0), 'red','black',3)

		# Uncomment to draw all vertices

	 	#for e_obs in self.grown:
		# 	for point in e_obs:
		# 		self.draw_point(point)
		# 	self.draw_lrp(e_obs)

	def draw_obstacle(self, obs, outline_color="blue", fill_color="white"):
		points = []
		for point in obs:
			x,y = self.scale(point)
			points.append(x)
			points.append(y)
		
		self.canvas.create_polygon(points, \
			outline=outline_color, fill=fill_color)

	def draw_point(self, point, outline_color='black', fill_color='white', \
		size=1):
		x,y = self.scale(point)
		self.canvas.create_oval(x-size,y-size,x+size,y+size, \
			outline=outline_color, fill=fill_color)

	def draw_lrp(self, obstacle, color='red'):
		lowest_rightmost_point = obstacle[0]

		for point in obstacle:
			if point[1] < lowest_rightmost_point[1]:
				lowest_rightmost_point = point
			elif point[1] == lowest_rightmost_point[1] and \
				point[0] < lowest_rightmost_point[0]:
				lowest_rightmost_point = point

		self.draw_point(lowest_rightmost_point,color,color)

	def draw_line(self, edge, color="purple"):
		x1,y1 = self.scale(edge[0])
		x2,y2 = self.scale(edge[1])

		self.canvas.create_line(x1,y1,x2,y2, fill=color)

	def scale(self, point):
		x = -(point[0]*self.scaler-self.x_offset)+self.width/2
		y = -(point[1]*self.scaler-self.y_offset)+self.width/2
		return (x,y)

	def all_edges(self):
		"""All edges in visibility graph"""
		all_vertices = [coords for obj in self.grown for coords in obj]
		all_vertices.append(self.start)
		all_vertices.append(self.end)

		edges = []
		for v1 in all_vertices:
			for v2 in all_vertices:
				if (v1[0] != v2[0]) and (v1[1] != v2[1]):
					edges.append(sorted((v1, v2)))
		return edges

	def remove_collisions(self):
		all_edges = self.all_edges()
		edges = []

		for edge in all_edges:
			collides = False
			for obs in self.grown:
				if collision(obs,edge):
					collides = True
			if not collides:
				edges.append(edge)
		return edges

##############################################################################


##############################################################################

def grahams_alg(exp_obstacles):
	grown_obstacles = []

	for exp_obstacle in exp_obstacles:
		lowest_rightmost_point = exp_obstacle[0]
		for point in exp_obstacle:
			if point[1] < lowest_rightmost_point[1]:
				lowest_rightmost_point = point
			elif point[1] == lowest_rightmost_point[1] and \
				point[0] > lowest_rightmost_point[0]:
				lowest_rightmost_point = point

		sorted_sop = sorted(exp_obstacle, \
			key = lambda point: angle_sort(lowest_rightmost_point,point))

		stack = [sorted_sop[-1], sorted_sop[0]]

		i = 1
		while i < len(sorted_sop):
			if is_left(stack[-2], stack[-1], sorted_sop[i]):
				stack.append(sorted_sop[i])
				i += 1
			else:
				stack.pop()
		stack.pop()

		grown_obstacles.append(stack)
	return grown_obstacles

def collision(obstacle,edge):
	for obs_edge in zip(obstacle, obstacle[1:]):
		if line_collision(edge,obs_edge):
			return True

	obs_edge = (obstacle[1],obstacle[-1])

	if line_collision(edge, obs_edge):
		return True

	return False


def line_collision(l1,l2):
	l1_dx = l1[1][0]-l1[0][0]		
	l1_dy = l1[1][1]-l1[0][1]

	l2_dx = l2[1][0]-l2[0][0]	
	l2_dy = l2[1][1]-l2[0][1]	

	p = l1[0]
	r = (l1_dx,l1_dy)

	q = l2[0]
	s = (l2_dx,l2_dy)

	norm = float(xprod(r,s))

	if norm == 0:
		return False

	t = xprod( diff(q,p), s) / norm
	u = xprod( diff(q,p), r) / norm

	if 0 < t < 1 and 0 < u < 1:
		return True

	return False

def diff(p1,p2):
	return (p1[0]-p2[0],p1[1]-p2[1])

def xprod(p1,p2):
	return p1[0]*p2[1]-p1[1]*p2[0]


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
	return obstacles

def make_ngon(r,n):
	n_gon = []
	for i in range(n):
		theta = i*(2*math.pi/n)
		x = r*math.cos(theta)
		y = r*math.sin(theta)
		n_gon.append((x,y))
	return n_gon

def angle_sort(origin,target):
	a = angle(origin,target)
	d = distance(origin,target)
	return (a,d)

def angle(p1,p2):
	delta_y = p2[1]-p1[1]
	delta_x = p2[0]-p1[0]
	return math.atan2(delta_y,delta_x)

def distance(p1,p2):
	delta_y = p2[1]-p1[1]
	delta_x = p2[0]-p1[0]
	return math.sqrt(delta_y**2+delta_x**2)

def slope(p1,p2):
	delta_y = p2[1]-p1[1]
	delta_x = p2[0]-p1[0]

	if delta_x == 0:
		return float('inf')

	return delta_y/delta_x

def is_left(p1, p2, p3):
	pi  = math.pi
	a12 = angle(p1,p2) 
	a13 = angle(p1,p3)
	if a12 > 0 and a13 < 0:
		a13 = a13 % (2*pi) 

	d_theta = (a13 - a12)
	if 0 < d_theta < pi:
		return True

	return False

##############################################################################

if __name__ == '__main__':
	with open(sys.argv[1]) as input_file:
		graph = ObstacleGraph(input_file)