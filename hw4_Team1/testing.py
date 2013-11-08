import math

def angle_sort(origin,target):
	delta_y = target[1]-origin[1]
	delta_x = target[0]-origin[0]
	angle   = math.atan2(delta_y,delta_x)
	dist    = math.sqrt(delta_y**2+delta_x**2)

	return (angle,dist)

def distance(p1,p2):
	delta_y = p2[1]-p1[1]
	delta_x = p2[0]-p1[0]
	return math.sqrt(delta_y**2+delta_x**2)	

def angle(p1,p2):
	delta_y = p2[1]-p1[1]
	delta_x = p2[0]-p1[0]
	return math.atan2(delta_y,delta_x)	

if __name__ == '__main__':

	set_of_points = [(0,0),(2,1),(1,2),(-1,1),(-2,0),(1,0),(3,2),(1,3),(-2,2)]

	lowest_rightmost_point = set_of_points[0]

	for point in set_of_points:

		if point[1] < lowest_rightmost_point[1]:
			lowest_rightmost_point = point
		elif point[1] == lowest_rightmost_point[1] and \
			point[0] > lowest_rightmost_point[0]:
			lowest_rightmost_point = point

	print "LRP is {}".format(lowest_rightmost_point)

	sorted_sop = sorted(set_of_points, \
		key = lambda point: angle_sort(lowest_rightmost_point,point))

	for index, point in enumerate(sorted_sop):
		print "index {} point {}".format(index,point)

	# p1 = (0,0)
	# p2 = (1,0)
	# p3 = (-4,-1)

	# pi = math.pi

	# a12 = angle(p1,p2)
	# a13 = angle(p1,p3)

	# print "a13 = {}, a12 = {}".format(a13, a12)
	# print "difference is {}".format((a13-a12))

