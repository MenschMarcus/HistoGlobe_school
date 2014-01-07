###############################################################
#This script converts csv files containing hivent data into
#formats needed by HistoGlobe: one hivent_collection.json file
#referencing all hivents and one [HIVENT_ID].htm file for each
#hivent.
#
#Data within the csv file has to be formatted as follows:
#
#ID|name|description|startDate|endDate|locName|long|lat|category|multimedia_ID
#
###############################################################

import sys, os
import csv

class Multimedia:
  type = ""
  description = ""
  link = ""
  thumbnail = ""

  def __init__(self, type, description, link):
    self.type = type
    self.description = description
    self.link = link
    self.thumbnail = link
    if link.split('.')[-1] in iframe_criteria:
      self.link += "?iframe=true"
      self.thumbnail = "data/video.png"

def main():
  csv_label_file_path = ""
  target_path = ""

  if len(sys.argv) < 2:
    print "A csv hivents file and a target path have to be specified!"
    print "Usage: convert_from_csv.py PATH_TO_LABEL_CSV TARGET_PATH"
    return -1

  csv_label_file_path = sys.argv[1]
  target_path = sys.argv[2]

  json_target = open(target_path + "/label_collection.json", "w")
  json_target.write("[\n")

  #load hivent sheet
  with open(csv_label_file_path, 'rb') as csvfile:
    rows = list(csv.reader(csvfile, delimiter='|', quotechar='\"'))
    row_count = len(rows)
    for row in rows:
      if row != rows[0]:
        label_id          = row[0]
        label_type        = row[1]
        label_label       = row[2]
        label_size        = row[3]
        label_startDate   = row[4]
        label_endDate     = row[5]
        label_lat         = row[6]
        label_long        = row[7]

        #create json

        json_target.write('\t{\n')
        json_target.write('\t\t\"category\": \"' + label_type + '\",\n')

        startDay, startMonth, startYear = label_startDate.split(".")
        json_target.write('\t\t\"startDay\": ' + str(int(startDay)) + ',\n')
        json_target.write('\t\t\"startMonth\": ' + str(int(startMonth)) + ',\n')
        json_target.write('\t\t\"startYear\": ' + str(int(startYear)) + ',\n')

        endDay, endMonth, endYear = label_endDate.split(".")
        json_target.write('\t\t\"endDay\": ' + str(int(endDay)) + ',\n')
        json_target.write('\t\t\"endMonth\": ' + str(int(endMonth)) + ',\n')
        json_target.write('\t\t\"endYear\": ' + str(int(endYear)) + ',\n')

        json_target.write('\t\t\"label\": \"' + label_label + '\",\n')

        json_target.write('\t\t\"size\": ' + label_size + ',\n')

        json_target.write('\t\t\"long\": ' + label_long + ',\n')
        json_target.write('\t\t\"lat\": ' + label_lat + '\n')

        json_target.write('\t}')
        if row != rows[-1]:
          json_target.write(',')
        json_target.write('\n')

  json_target.write("]")
  json_target.close()

  return 0

if __name__ == "__main__":
  sys.exit(main())
