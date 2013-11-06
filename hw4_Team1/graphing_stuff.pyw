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
		self.draw_obstacles()

		print 'done drawing'
		self.root.mainloop()

	def draw_obstacles(self):
		room = self.obstacles[0]
		up_bound = min([-i[1] for i in room])
		low_bound = max([-i[1] for i in room])
		left_bound = min([-i[0] for i in room])
		right_bound = max([-i[0] for i in room])

		scale = 20
		x_offset = 0
		y_offset = 0

		up_bound = (up_bound*scale+self.width/2)
		low_bound = (low_bound*scale+self.width/2)
		left_bound = (left_bound*scale+self.width/2)
		right_bound = (right_bound*scale+self.width/2)


		self.canvas.create_line(0,up_bound,self.width,up_bound)
		self.canvas.create_line(0,low_bound,self.width,low_bound)
		self.canvas.create_line(left_bound, 0, left_bound, self.width)
		self.canvas.create_line(right_bound, 0, right_bound, self.width)

		for obstacle in self.obstacles:
			last_x,last_y = obstacle[-1]
			for x,y in obstacle:
				x1 = (scale*-last_x+self.width/2)
				y1 = (scale*-last_y+self.width/2)
				x2 = (scale*-x+self.width/2)
				y2 = (scale*-y+self.width/2)
				self.canvas.create_line(x1, y1, x2, y2)
				last_x = x
				last_y = y

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


if __name__ == '__main__':

	with open(sys.argv[1]) as input_file:
		graph = ObstacleGraph(input_file)