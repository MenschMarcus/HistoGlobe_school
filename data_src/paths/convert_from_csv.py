###############################################################
#This script converts csv files containing path data into
#a path_collection.json needed by HistoGlobe.
#
#Data within the csv file has to be formatted as follows:
#
#ID|startHivent|endHivent|coordsInbetween|category|type
#
###############################################################

import sys, os
import csv

def main():
  csv_path_file_path = ""
  target_path = ""

  if len(sys.argv) < 2:
    print "A csv paths file and a target path have to be specified!"
    print "Usage: convert_from_csv.py PATH_TO_PATHS_CSV TARGET_PATH"
    return -1

  csv_path_file_path = sys.argv[1]
  target_path = sys.argv[2]

  json_target = open(target_path + "/path_collection.json", "w")
  json_target.write("[\n")

  #load path sheet
  with open(csv_path_file_path, 'rb') as csvfile:
    rows = list(csv.reader(csvfile, delimiter='|', quotechar='\"'))
    row_count = len(rows)
    for row in rows:
      if row != rows[0]:
        path_id              = row[0]
        path_startHivent     = row[1]
        path_endHivent       = row[2]
        path_coordsInbetween = row[3]
        path_category        = row[4]
        path_type            = row[5]
        path_movingMarker    = row[6]
        path_startMarker     = row[7]
        path_endMarker       = row[8]

        #create json

        json_target.write('\t{\n')
        json_target.write('\t\t\"id\": \"' + path_id + '\",\n')

        json_target.write('\t\t\"startHivent\": \"' + path_startHivent + '\",\n')
        json_target.write('\t\t\"endHivent\": \"' + path_endHivent + '\",\n')

        json_target.write('\t\t\"coordsInbetween\": \"' +  path_coordsInbetween + '\",\n')

        json_target.write('\t\t\"category\": \"' +  path_category + '\",\n')

        json_target.write('\t\t\"type\": \"' +  path_type + '\",\n')
        json_target.write('\t\t\"movingMarker\": ' +  path_movingMarker.lower() + ',\n')
        json_target.write('\t\t\"startMarker\": ' +  path_startMarker.lower() + ',\n')
        json_target.write('\t\t\"endMarker\": ' +  path_endMarker.lower() + '\n')

        json_target.write('\t}')
        if row != rows[-1]:
          json_target.write(',')
        json_target.write('\n')

  json_target.write("]")
  json_target.close()

  return 0

if __name__ == "__main__":
  sys.exit(main())
