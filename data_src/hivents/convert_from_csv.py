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
      self.thumbnail = "data/hivent_icons/icon_join.png"

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

  assets_path =  target_path + "/hivent_assets/"
  html_path = assets_path + "html/"

  if not os.path.exists(html_path):
    os.makedirs(html_path)

  json_target = open(target_path + "/hivent_collection.json", "w")
  json_target.write("[\n")

  #load multimedia sheet and store combination of id/data for later use
  multimedia_map = dict()

  with open(csv_multimedia_file_path, 'rb') as csvfile:
    rows = list(csv.reader(csvfile, delimiter='|', quotechar='\"'))
    row_count = len(rows)
    for row in rows:
      if row != rows[0]:
        id = row[0]
        multimedia = Multimedia(row[1], row[2], row[3])

        multimedia_map[id] = multimedia

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

        mm_html_string = ""

        if hivent_mm_ids != "":
          gallery_id = hivent_id + "_gallery"
          mm_html_string = '\t<ul class=\"gallery clearfix\">\n'
          hivent_mm_ids = hivent_mm_ids.split(",")
          gallery_tag = ""
          if len(hivent_mm_ids) > 1:
            gallery_tag = "[" + gallery_id + "]"
          for id in hivent_mm_ids:
            if not id in multimedia_map:
              print "Multimedia ID " + hivent_mm_id + " is invalid!"
            else:
              multimedia = multimedia_map[id]
              mm_html_string += str('\t\t<li><a href=\"' +
                                multimedia.link + '\" rel=\"prettyPhoto' +
                                gallery_tag + '\" title=\"' +
                                multimedia.description + '\"> <img src=\"' +
                                multimedia.thumbnail + '\" width=\"60px\" /></a></li>\n')

          mm_html_string += "\t</ul>\n"

        #create html
        date_string = hivent_startDate
        if hivent_startDate != hivent_endDate:
          date_string += '-' + hivent_endDate

        html_name = hivent_id + ".htm"
        html_target = open(html_path + html_name, "w")
        html_target.write('<div class = \"hiventInfoPopoverContent\">\n' +
                           '\t<h3>' + hivent_location + ', ' +
                           date_string+ '</h3>\n' +
                           mm_html_string +
                           '\t<p>\n\t\t' +
                           hivent_description +
                           '\n\t</p>\n' +
                          '</div>\n'
                         )
        html_target.close()

        #create json

        json_target.write('\t{\n')
        json_target.write('\t\t\"id\": \"' + hivent_id + '\",\n')
        json_target.write('\t\t\"name\": \"' + hivent_name + '\",\n')

        startDay, startMonth, startYear = hivent_startDate.split(".")
        json_target.write('\t\t\"startDay\": ' + str(int(startDay)) + ',\n')
        json_target.write('\t\t\"startMonth\": ' + str(int(startMonth)) + ',\n')
        json_target.write('\t\t\"startYear\": ' + str(int(startYear)) + ',\n')

        endDay, endMonth, endYear = hivent_endDate.split(".")
        json_target.write('\t\t\"endDay\": ' + str(int(endDay)) + ',\n')
        json_target.write('\t\t\"endMonth\": ' + str(int(endMonth)) + ',\n')
        json_target.write('\t\t\"endYear\": ' + str(int(startYear)) + ',\n')

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
