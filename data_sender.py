# Python program to read
# json file


import json


def send():
    # Opening JSON file
    f = open('db_file.json')

    # returns JSON object as
    # a dictionary
    pois = json.load(f)

    # Iterating through the json
    # list
    # for i in pois:
    #     print(i)
    poi = pois[0]
    print(poi)
    # print(poi['categories'])
    for category in poi['categories']:
        print(category)

    # Closing file
    f.close()


send()
