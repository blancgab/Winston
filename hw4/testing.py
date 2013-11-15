import math
import pdb

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

def is_left(p1, p2, p3):
	pi = math.pi

	a12 = angle(p1,p2) 
	a13 = angle(p1,p3)

	if a12 > 0 and a13 < 0:
		a13 = a13 % (2*pi) 

	d_theta = (a13 - a12)

	# print a12*(180/pi)
	# print a13*(180/pi)
	# print d_theta*(180/pi)

	if 0 < d_theta < pi:
		return True

	return False

if __name__ == '__main__':
	a1 = (-1,1)
	a2 = (-3,1)
	a3 = (-3,-1)

	print "True:\t{}".format(is_left(a1,a2,a3))
	print "True:\t{}".format(is_left(a2,a3,a1))
	print "True:\t{}".format(is_left(a3,a1,a2))

	print "False:\t{}".format(is_left(a2,a1,a3))
	print "False:\t{}".format(is_left(a1,a3,a2))
	print "False:\t{}".format(is_left(a3,a2,a1))

	b1 = (2,0)
	b2 = (0,2)
	b3 = (-2,-1)

	print "True:\t{}".format(is_left(b1,b2,b3))
	print "True:\t{}".format(is_left(b2,b3,b1))
	print "True:\t{}".format(is_left(b3,b1,b2))

	print "False:\t{}".format(is_left(b2,b1,b3))
	print "False:\t{}".format(is_left(b1,b3,b2))
	print "False:\t{}".format(is_left(b3,b2,b1))


	c1 = (-0.6938532541079281, 0.7391036260090295)
	c2 = (-1.306146745892072, 0.7391036260090295)
	c3 = (-1.306146745892072, -0.7391036260090295)

	print "True:\t{}".format(is_left(c1,c2,c3))
	print "True:\t{}".format(is_left(c2,c3,c1))
	print "True:\t{}".format(is_left(c3,c1,c2))

	print "False:\t{}".format(is_left(c2,c1,c3))
	print "False:\t{}".format(is_left(c1,c3,c2))
	print "False:\t{}".format(is_left(c3,c2,c1))

	# set_of_points = [(0,0),(2,1),(1,2),(-1,1),(-2,0),(1,0),(3,2),(1,3),(-2,2)]

	# lowest_rightmost_point = set_of_points[0]

	# for point in set_of_points:

	# 	if point[1] < lowest_rightmost_point[1]:
	# 		lowest_rightmost_point = point
	# 	elif point[1] == lowest_rightmost_point[1] and \
	# 		point[0] > lowest_rightmost_point[0]:
	# 		lowest_rightmost_point = point

	# print "LRP is {}".format(lowest_rightmost_point)

	# sorted_sop = sorted(set_of_points, \
	# 	key = lambda point: angle_sort(lowest_rightmost_point,point))

	# for index, point in enumerate(sorted_sop):
	# 	print "index {} point {}".format(index,point)

	# p1 = (0,0)
	# p2 = (1,0)
	# p3 = (-4,-1)

	# pi = math.pi

	# a12 = angle(p1,p2)
	# a13 = angle(p1,p3)

	# print "a13 = {}, a12 = {}".format(a13, a12)
	# print "difference is {}".format((a13-a12))