# Python program to read
# json file


import json


def main():
    # Opening JSON file
    f = open('db_file.json')

    # returns JSON object as
    # a dictionary
    data = json.load(f)

    # Iterating through the json
    # list
    for i in data:
        print(i)

    # Closing file
    f.close()


main()
