import json
import re

import wikipediaapi
import sys
import requests
from bs4 import BeautifulSoup


def get_position(URL):
    req = requests.get(URL).text
    soup = BeautifulSoup(req, "html.parser")
    latitude = soup.find("span", {"class": "latitude"})
    longitude = soup.find("span", {"class": "longitude"})
    position = {}
    if latitude is None or longitude is None:  # if no position
        return position
    position['latitude'] = latitude.text
    position['longitude'] = longitude.text
    return position


def get_language(language):
    languages = {"english": "en", "hebrew": "he"}
    return languages[language]


# search wikipedia page by name
def search_page(name_to_search, language):
    wiki_wiki = wikipediaapi.Wikipedia(language)
    page = wiki_wiki.page(name_to_search)

    page_exist = page.exists()
    if page_exist:
        return page
    else:
        raise ValueError('page ' + name_to_search + ' not found')


def search_page_by_url(url, language):
    name_to_search = re.sub("(https:.+\.wikipedia\.org\/wiki\/)", "", url)
    return search_page(name_to_search, language)


def get_poi_from_page(wiki_page: wikipediaapi.WikipediaPage):
    poi = {}
    poi['title'] = wiki_page.title
    poi['summary'] = wiki_page.summary
    poi['categories'] = []
    for category in wiki_page.categories:
        poi['categories'].append(category)
    poi['URL'] = wiki_page.fullurl
    poi['language'] = wiki_page.language
    poi['position'] = get_position(wiki_page.fullurl)
    return poi


def print_links(page):
    links = page.links
    for title in sorted(links.keys()):
        print("%s: %s" % (title, links[title]))


def crawl(file, wiki_page : wikipediaapi.WikipediaPage, language: str):
    poi = get_poi_from_page(wiki_page)
    if poi['position']:
        json.dump(poi, file)
    # print_links(wiki_page)
    links = wiki_page.links
    for title in sorted(links.keys()):
        print(links[title].fullurl)
        crawl(file, links[title], language)



def main():
    wiki_page = search_page('masada', 'en')
    file = open("db_file.txt", 'a')
    crawl(file=file, wiki_page=wiki_page, language='en')
    file.close()
    # pos = get_position('https://en.wikipedia.org/wiki/Book')
    # if pos:
    #     print("possssssss")

    # page = search_page('masada', get_language('english'))
    # print(page.summary)
    # page = search_page_by_url("https://en.wikipedia.org/wiki/Masada", 'en')
    # print(page.summary)


main()
