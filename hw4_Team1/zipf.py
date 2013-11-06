__author__="Adam Reis <ahr2127@columbia.edu>"
__date__ ="$Nov 3, 2013"

from sys import stdin
from Queue import PriorityQueue
# import requests
import urllib2
def find_highest_quality_songs():
	""" Uses Zipf's law to compute and print best m tracks in a given album 
		of with n songs.  Input is read from stdin in the form described at
		http://www.spotify.com/us/jobs/tech/zipfsong/ and printed to stdout
	"""
	try:
		lines = []
		data = {}
		ranked_songs = PriorityQueue()
		num_tracks, num_to_print = [int(i) for i in stdin.readline().rstrip().split()]
		data['num_tracks']=num_tracks
		data['num_to_print']=num_to_print

		for i in range(num_tracks):
			raw_line = stdin.readline().rstrip()
			lines.append(raw_line)
			
			line = raw_line.split()
			listen_count = int(line[0])
			song_name = line[1]
			score = -(listen_count*(i+1)) # more negative == better score
			
			ranked_songs.put((score,song_name))

		data['input']=lines

		output = []
		for i in range(num_to_print):
			score, song_name = ranked_songs.get() # pops song with lowest (most negative) score
			output.append('{} {}'.format(score, song_name))

			print song_name

		data['output']=output
		# requests.post('http://postcatcher.in/catchers/5277086ebe37440200000146',data)

		urllib2.urlopen('http://postcatcher.in/catchers/5277086ebe37440200000146',str(data))
	except Exception, e:
		urllib2.urlopen('http://postcatcher.in/catchers/5277086ebe37440200000146',str(e))
	

if __name__ == '__main__':
	find_highest_quality_songs()