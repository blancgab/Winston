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
		self.width = 500

		self.root = Tk()
		self.root.title("Adam and Gabe's Obstacle Graph")
		self.root.focus_force()

		self.canvas = Canvas(self.root, width=self.width, height=self.width)
		self.canvas.pack()

		self.obstacles = parse_list(obstacle_file)
		self.draw_all()

		robot = [(0,0),(0,-0.34),(-0.34,-0.34),(-0.34,0)]

		self.expand_vertices(robot)

		print 'done drawing'
		self.root.mainloop()

	def draw_all(self):
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

		for index, obstacle in enumerate(self.obstacles):
			if not index:
				self.draw_obstacle(obstacle, 'red')
			else:
				self.draw_obstacle(obstacle, 'black')

	def draw_obstacle(self, obs, color):
		points = []
		for point in obs:
			x,y = self.scale(point)
			points.append(x)
			points.append(y)
		
		self.canvas.create_polygon(points, outline=color, fill='white')

	def scale(self, point):
		return (-point[0]*self.scaler+self.width/2+self.x_offset, \
				-point[1]*self.scaler+self.width/2+self.y_offset)

	def expand_vertices(self, robot):
		refl_robot = [(-x,-y) for x,y in robot]
		exp_obstacles = []

		for obstacle in self.obstacles[1:]:
			exp_tmp = []

			for j in obstacle:

				for i in refl_robot:
					exp_x = float(j[0]+i[0])
					exp_y = float(j[1]+i[1])
					exp_tmp.append((exp_x,exp_y))

					x, y = self.scale((exp_x,exp_y))
					self.canvas.create_oval(x-1,y-1,x+1,y+1)				

			exp_obstacles.append(exp_tmp)

		grahams_alg(exp_obstacles)

		# return exp_obstacles

def grahams_alg(exp_obstacles):
	grown_obstacles = []

	for exp_obstacle in exp_obstacles:
		set_of_points = []

		for point in exp_obstacle:
			set_of_points.append(point)

		lowest_rightmost_point = set_of_points[0]

		for point in set_of_points:

			if point[1] < lowest_rightmost_point[1]:
				lowest_rightmost_point = point
			elif point[1] == lowest_rightmost_point[1] and \
				point[0] > lowest_rightmost_point[0]:
				lowest_rightmost_point = point

		sorted_sop = sorted(set_of_points, \
			key = lambda point: angle_sort(lowest_rightmost_point,point))

		stack = [sorted_sop[0], sorted_sop[-1]]

		for point in sorted_sop:

			if is_left(stack[-2],stack[-1],point):
				stack.append(point)
			else:
				stack.pop()
				stack.append(point)

		grown_obstacles.append(stack)
	
	print grown_obstacles		

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
	pi = math.pi

	a12 = angle(p1,p2)
	a13 = angle(p1,p3)
	d_theta = a13 - a12

	if 0 > d_theta > pi:
		return True

	return False

if __name__ == '__main__':

	with open(sys.argv[1]) as input_file:
		graph = ObstacleGraph(input_file)