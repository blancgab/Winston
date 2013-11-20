#!/usr/bin/env python

__author__ = """$Adam Reis <ahr2127@columbia.edu>, 
				Gabriel Blanco <gab2135@columbia.edu>, 
				Sophie Chou <sbc2125@columbia.edu>"""
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
from collections import defaultdict
from copy import deepcopy
from Queue import PriorityQueue

class ObstacleGraph:
	"""
	Graphs a room and a bunch of objects in a GUI!
	"""
	def __init__(self, obstacle_file):
		self.width = 1200
		self.exp_obstacles = []

		self.root = Tk()
		self.root.title("Adam and Gabe and Sophie's Obstacle Graph")
		self.root.focus_force()
		self.canvas = Canvas(self.root, width=self.width, height=self.width)
		self.canvas.pack()

		self.obstacles = parse_list(obstacle_file)
		self.calc_frame()

		self.start	  = (-3.107,  0.58)
		self.end 	  = (10.657, -0.03)
		self.removed_vert = []
		self.colliding_edges = []
		self.best_path = []

		# self.robot = make_ngon(.17,8)
		self.robot	  = [(.2,.2),(.2,-.2),(-.2,-.2),(-.2,.2)]	
		self.expanded = self.expand_vertices()
		self.grown	  = grahams_alg(self.expanded)
		self.edges	= self.remove_collisions()
		for obstacle in self.grown:
			new_edges = [(obstacle[i], obstacle[i+1]) for i in range(len(obstacle)-1)]
			
			for edge in new_edges:
				# import pdb; pdb.set_trace()	
				self.edges.append(edge)
			self.edges.append((obstacle[-1], obstacle[0]))

 		self.vertices = self.non_overlapping_vertices() + [self.start, self.end]
		# self.best_path = dijkstra(deepcopy(self.vertices), deepcopy(self.edges), self.start, self.end)
		adjacencies = self.find_adjacencies()
		self.dijkstra(adjacencies, self.start, self.end)

		self.draw_all()
		# print 'done drawing'
		self.root.mainloop()

	def find_adjacencies(self):
		adjacencies = defaultdict(set)
		for edge in self.edges:
			adjacencies[edge[0]].add(edge[1])
			adjacencies[edge[1]].add(edge[0])
		return adjacencies

	def dijkstra(self, adjacencies, start_point, end_point):
		seen_so_far = defaultdict(float)
		for k in adjacencies:
			seen_so_far[k] = float('inf')

		q = PriorityQueue()
		start = Vertex(start_point, [], 0.0)
		q.put(start)
		seen_so_far[start_point] = 0

		while not q.empty():
			v = q.get()
			if v.coords == end_point:
				new_path = v.path
				new_path.append(end_point)

				# write to file
				with open("output", "w") as out_file:
					for point in new_path:
						out_file.write('{} {}\n'.format(point[0], point[1]))
				self.best_path = [(new_path[i], new_path[i+1]) for i in range(len(new_path)-1)]
				return
			for point in adjacencies[v.coords]:
				# import pdb; pdb.set_trace()
				new_cost = v.cost+distance(v.coords, point)
				if seen_so_far[point]<new_cost:
					continue
				seen_so_far[point]=new_cost
				new_path = deepcopy(v.path)
				new_path.append(v.coords)
				q.put(Vertex(point, new_path, new_cost))




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
		
		# for edge in self.edges:
		# 	self.draw_line(edge)

		# import pdb; pdb.set_trace()
		for edge in self.best_path:
			self.draw_line(edge, 'red')	

		# for edge in self.colliding_edges:
		# 	self.draw_line(edge, 'yellow')

		self.draw_point(self.start, 'green','black',3)
		self.draw_point(self.end,   'green','black',3)
		self.draw_point((0,0), 'red','black',3)

		# Uncomment to draw all vertices

		# for e_obs in self.grown:
		# 	for point in e_obs:
		# 		self.draw_point(point)
		# 	self.draw_lrp(e_obs)

		# for point in self.removed_vert:
		# 	self.draw_point(point, 'yellow')
		# self.draw_lrp(e_obs)

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
		all_vertices = self.non_overlapping_vertices()
		all_vertices.append(self.start)
		all_vertices.append(self.end)

		for v1 in all_vertices:
			for v2 in all_vertices:
				if (v1[0] != v2[0]) and (v1[1] != v2[1]):
					yield sorted((v1, v2))

	def remove_collisions(self):		
		prelim_edges = []
		room = self.obstacles[0]

		# Detect collisions with grown obstacles
		for edge in self.all_edges():
			collides = False
			for obs in self.grown:
				if collision(obs,edge):
					collides = True
				elif collision(room,edge):
					collides = True
			if not collides:
				prelim_edges.append(edge)

		# Repeat for original obstacles
		edges = []
		for edge in prelim_edges:
			collides = False
			for obs in self.obstacles:
				if collision(obs,edge, True):
					collides = True
			if collides:
				self.colliding_edges.append(edge)
			else:
				edges.append(edge)

		# print '{} edges'.format(len(edges))
		return edges

	def non_overlapping_vertices(self):
		vertices = [coords for obj in self.grown for coords in obj]

		for obstacle in self.grown:

			y_max = max([i[1] for i in obstacle])
			y_min = min([i[1] for i in obstacle])
			x_max = max([i[0] for i in obstacle])
			x_min = min([i[0] for i in obstacle])

			for obs in self.grown:
				for v in obs:
					if y_min < v[1] < y_max and x_min < v[0] < x_max:
						vertices.remove(v)
						self.removed_vert.append(v)

		return vertices


##############################################################################
class Vertex:
    def __init__(self, coords, path, cost):
        
        self.coords = coords
        self.path = path
        self.cost = cost

    def __lt__(self, other):
        return self.cost<other.cost

##############################################################################
def distance(a, b):
    """
    Returns the euclidian distance from (ax, ay) to (bx, by)
    """
    return sqrt((b[0]-a[0])^2 + (b[1]-a[1])^2)

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

def collision(obstacle,edge, inclusive=False):
	for obs_edge in zip(obstacle, obstacle[1:]):
		if line_collision(edge,obs_edge):
			return True

	obs_edge = (obstacle[0],obstacle[-1])

	if inclusive:
		if line_collision_inclusive(edge, obs_edge):
			return True
	else:
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

def line_collision_inclusive(l1,l2):
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

	if 0 <= t <= 1 and 0 <= u <= 1:
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



# def dijkstra(V, E, s, g):

# 	path = defaultdict(list)
# 	path[s].append(s)

# 	dist = {}
# 	for v in V:
# 		if v == s:
# 			dist[v] = 0.0
# 		else:
# 			dist[v] = float("inf")

# 	print "path", path

# 	i = 0	
# 	x = []
# 	while V:
# 		i += 1 #should not exceed O(n^2) = 961

# 		l = sorted(dist, key=dist.get, reverse=True)

# 		v = l.pop()
# 		while v not in V:
# 			v = l.pop()

# 		print "dist", dist
# 		print "v", v

# 		poss_edges = [e for e in E if e[0] == v]
# 		neighbors = [n[1] for n in poss_edges]

# 		for u in neighbors:
# 			if dist[u] > dist[v] + cost(v, u):
# 				dist[u] = dist[v] + cost(v,u)
# 				path[u] = path[v] + [u]

# 		V.remove(v)
# 		for x in poss_edges:
# 			E.remove(x)

# 	bestpath = path[g]

# 	return [[bestpath[i], bestpath[i+1]] for i in range(len(bestpath) -1)]


# def dijkstra(V, E, s, g):	
# 	#init
# 	d = {} #dist from path to vertex
# 	pi = {} #predecessors graph

# 	for v in V:
# 		d[v] = float("inf")
# 		pi[v] = []
	
# 	d[s] = 0.0

# 	S = [] #set of vertices whose shortest path from source already det

# 	while V:
# 		l = sorted(d, key=d.get, reverse=True)
# 		u = l.pop()
# 		while u in S:
# 			u = l.pop()

# 		print S
# 		print u in S

# 		#u = min(d, key=d.get)  #vertex w. shortest distance
		
# 		print 'u', u
# 		print d[u]	
# 		if u == g:
# 			"Reached goal"
# 			break
# 		S.append(u) #add u to finished set
	
# 		poss_edges = [e for e in E if e[0] == u]
# 		neighbors = set([n[1] for n in poss_edges])

# 		for v in neighbors:
# 			print 'v', v
# 			print d[v]	
# 			if d[v] > d[u] + cost(u, v):
# 				d[v] = d[u] + cost(u, v)
# 				pi[v] = u

# 		#print u
# 		V.remove(u) 
# 		S.append(u)
		
# 	return d, pi

def cost(v1, v2):
	"""Euclidean distance"""
	return ((v2[0] - v1[0])**2 + (v2[1] - v1[1])**2)**(0.5)

##############################################################################

def usage():
	print """
	Usage:
		python path_finder.py [input_map]

	"""

if __name__ == '__main__':
	if len(sys.argv)!=2:
		usage()
		sys.exit(2)

	with open(sys.argv[1]) as input_file:
		graph = ObstacleGraph(input_file)
