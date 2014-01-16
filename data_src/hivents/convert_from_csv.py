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

iframe_criteria = ['flv', 'ogv', 'mp4', 'ogg']

def main():
  csv_hivents_file_path = ""
  csv_multimedia_file_path = ""
  target_path = ""

  if len(sys.argv) < 3:
    print "A csv hivents file, a csv data file and a target path have to be specified!"
    print "Usage: convert_from_csv.py PATH_TO_HIVENT_CSV PATH_TO_MULTIMEDIA_CSV TARGET_PATH"
    return -1

  csv_hivents_file_path = sys.argv[1]
  csv_multimedia_file_path = sys.argv[2]
  target_path = sys.argv[3]

  if not os.path.exists(target_path):
    os.makedirs(target_path)


  #load multimedia sheet
  multimedia_json_target = open(target_path + "/multimedia_collection.json", "w")
  multimedia_json_target.write("[\n")

  with open(csv_multimedia_file_path, 'rb') as csvfile:
    rows = list(csv.reader(csvfile, delimiter='|', quotechar='\"'))
    row_count = len(rows)
    for row in rows:
      if row != rows[0]:
        multimedia_id          = row[0]
        multimedia_type        = row[1]
        multimedia_description = row[2]
        multimedia_link        = row[3]

        #create json

        multimedia_json_target.write('\t{\n')
        multimedia_json_target.write('\t\t\"id\": \"' + multimedia_id + '\",\n')
        multimedia_json_target.write('\t\t\"type\": \"' + multimedia_type + '\",\n')

        clean_description = multimedia_description.replace("\"", "\\\"")

        multimedia_json_target.write('\t\t\"description\": \"' + clean_description + '\",\n')
        multimedia_json_target.write('\t\t\"link\": \"' + multimedia_link + '\"\n')

        multimedia_json_target.write('\t}')
        if row != rows[-1]:
          multimedia_json_target.write(',')
        multimedia_json_target.write('\n')

  multimedia_json_target.write("]")
  multimedia_json_target.close()

  hivent_json_target = open(target_path + "/hivent_collection.json", "w")
  hivent_json_target.write("[\n")

  #load hivent sheet
  with open(csv_hivents_file_path, 'rb') as csvfile:
    rows = list(csv.reader(csvfile, delimiter='|', quotechar='\"'))
    row_count = len(rows)
    for row in rows:
      if row != rows[0]:
        hivent_id          = row[0]
        hivent_name        = row[1]
        hivent_description = row[2]
        hivent_startDate   = row[3]
        hivent_endDate     = row[4]
        hivent_location    = row[5]
        hivent_long        = row[7]
        hivent_lat         = row[6]
        hivent_category    = row[8]
        hivent_mm_ids      = row[9]
        hivent_displayDate = ""

        #create json

        hivent_json_target.write('\t{\n')
        hivent_json_target.write('\t\t\"id\": \"' + hivent_id + '\",\n')
        hivent_json_target.write('\t\t\"name\": \"' + hivent_name + '\",\n')

        clean_description = hivent_description.replace("\"", "\\\"")

        hivent_json_target.write('\t\t\"description\": \"' + clean_description + '\",\n')
        hivent_json_target.write('\t\t\"multimedia\": \"' + hivent_mm_ids + '\",\n')

        hivent_json_target.write('\t\t\"startDate\": \"' + hivent_startDate + '\",\n')

        hivent_json_target.write('\t\t\"endDate\": \"' + hivent_endDate + '\",\n')

        hivent_json_target.write('\t\t\"displayDate\": \"' + hivent_displayDate + '\",\n')
        hivent_json_target.write('\t\t\"location\": \"' + hivent_location + '\",\n')

        hivent_json_target.write('\t\t\"long\": ' + hivent_long + ',\n')
        hivent_json_target.write('\t\t\"lat\": ' + hivent_lat + ',\n')

        hivent_json_target.write('\t\t\"category\": \"' +  hivent_category + '\"\n')

        hivent_json_target.write('\t}')
        if row != rows[-1]:
          hivent_json_target.write(',')
        hivent_json_target.write('\n')

  hivent_json_target.write("]")
  hivent_json_target.close()

  return 0

if __name__ == "__main__":
  sys.exit(main())
