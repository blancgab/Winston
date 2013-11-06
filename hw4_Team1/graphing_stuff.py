from sys import stdin

# class ObstacleGraph:
# 	"""
# 	Graphs a room and a bunch of objects in a GUI!
# 	"""



if __name__ == '__main__':
	room = []
	num_points = int(stdin.readline().strip())

	for i in range(num_points):
		x,y = [float(i) for i in stdin.readline().rstrip().split()]
		room.append((x,y))

	print room