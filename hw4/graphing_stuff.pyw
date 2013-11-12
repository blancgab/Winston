__author__ = "$Adam Reis <ahr2127@columbia.edu>, Gabriel Blanco <gab2135@columbia.edu>"
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

		self.robot    = make_ngon(.17,16)		
		self.expanded = self.expand_vertices()
		self.grown    = grahams_alg(self.expanded)

		self.draw_all()
		print 'done drawing'
		self.root.mainloop()

	def calc_frame(self):
		room = self.obstacles[0]
		up_bound    = min([-i[1] for i in room])
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

		# Uncomment to draw all vertices

		# for e_obs in self.expanded:
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

	def draw_point(self, point, outline_color='black', fill_color='white'):
		x,y = self.scale(point)
		self.canvas.create_oval(x-1,y-1,x+1,y+1, \
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

	def scale(self, point):
		x = -(point[0]*self.scaler-self.x_offset)+self.width/2
		y = -(point[1]*self.scaler-self.y_offset)+self.width/2
		return (x,y)


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