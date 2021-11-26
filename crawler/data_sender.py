# Python program to read
# json file


import json


def send(file_to_send):
    for name_file in file_to_send:
        print("------------------------------------------------------------")
        f = open(name_file)
        pois = json.load(f)
        f.close()
        for p in pois:
            print(p)





def main():
    file_to_send = ['json_file_1', 'json_file_2', 'json_file_3']
    send(file_to_send)


main()
