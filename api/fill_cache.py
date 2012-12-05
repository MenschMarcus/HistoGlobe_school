#!/usr/bin/python

import httplib
import re
import sys
from datetime import date,timedelta

if (len(sys.argv) < 2):
	print "Usage:  python " + sys.argv[0] + ' <base path>\n'
	print "Example: To access http://localhost/test/fbjon/\n python " + sys.argv[0] + ' "/test/fbjon/"\n'
	print 
	sys.exit(1)

conn = httplib.HTTPConnection("localhost")

dir = '/' + sys.argv[1]
page = '/api/tilegenerator.php?layer=borders'
tfind = re.compile(r'.*&now=(\d+)-(\d+)-(\d+).*')
def prtime(date):
	return str(date.year) +"-"+ str(date.month) +"-"+ str(date.day)

for zoom in [4,3,5,2,6,7]:
	print "zoom level " + str(zoom) + "\n"
	sys.stdout.flush()
	time = date(2012,12,12)
	while time >= date(1803,7,26): # earliest date
		print "  date " + prtime(time),
		sys.stdout.flush()
		conn.request("HEAD", dir + page + "&zoom=" + str(zoom) + "&now=" + prtime(time))
		r1 = conn.getresponse()
		
		if r1.status == 302: #redirected
			print " -> redir",
			sys.stdout.flush()
			m = tfind.match(r1.getheader("Location"))
			if (m == None):
				print 'nomatch'
				break
			time = date(int(m.group(1)),int(m.group(2)),int(m.group(3)))
		else:
			print " done"
			time = time - timedelta(1)
			
