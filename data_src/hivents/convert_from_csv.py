###############################################################
#This script converts csv files containing hivent data into
#formats needed by HistoGlobe: one hivent_collection.json file
#referencing all hivents and one [HIVENT_ID].htm file for each
#hivent.
#
#Data within the csv file has to be formatted as follows:
#
#ID|name|description|date|locName|long|lat|category
#
###############################################################

import sys, os
import csv

def main():
  csv_file_path = ""
  target_path = ""

  if len(sys.argv) < 3:
    print "A csv file and a target path have to be specified!"
    print "Usage: convert_from_csv.py PATH_TO_CSV TARGET_PATH"
    return -1

  csv_file_path = sys.argv[1]
  target_path = sys.argv[2]

  assets_path =  target_path + "/hivent_assets/"
  html_path = assets_path + "html/"

  if not os.path.exists(html_path):
    os.makedirs(html_path)

  json_target = open(target_path + "/hivent_collection.json", "w")
  json_target.write("[\n")


  with open(csv_file_path, 'rb') as csvfile:
    rows = list(csv.reader(csvfile, delimiter='|', quotechar='\"'))
    row_count = len(rows)
    for row in rows:
      if row != rows[0]:
        hivent_id = row[0]
        hivent_name = row[1]
        hivent_description = row[2]
        hivent_date = row[3]
        hivent_location = row[4]
        hivent_long = row[6]
        hivent_lat = row[5]
        hivent_category = row[7]

        #create html
        html_name = hivent_id + ".htm"
        html_target = open(html_path + html_name, "w")
        html_target.write('<div class = \"hiventInfoPopoverContent\">\n' +
                           '\t<h3>' + hivent_location + ', ' +
                           hivent_date + '</h3>\n' +
                           '\t<p>\n\t\t' +
                           hivent_description +
                           '\n\t</p>\n' +
                          '</div>'
                         )
        html_target.close()

        #create json

        json_target.write('\t{\n')
        json_target.write('\t\t\"name\": \"' + hivent_name + '\",\n')

        day, month, year = hivent_date.split(".")
        json_target.write('\t\t\"day\": ' + str(int(day)) + ',\n')
        json_target.write('\t\t\"month\": ' + str(int(month)) + ',\n')
        json_target.write('\t\t\"year\": ' + str(int(year)) + ',\n')

        json_target.write('\t\t\"long\": ' + hivent_long + ',\n')
        json_target.write('\t\t\"lat\": ' + hivent_lat + ',\n')

        json_target.write('\t\t\"category\": \"' +  hivent_category + '\",\n')

        json_target.write('\t\t\"content\": \"' + html_path + html_name + '\"\n')

        json_target.write('\t}')
        if row != rows[-1]:
          json_target.write(',')
        json_target.write('\n')

  json_target.write("]")
  json_target.close()

  return 0

if __name__ == "__main__":
  sys.exit(main())
