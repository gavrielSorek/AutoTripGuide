import json
import re

import wikipediaapi
import sys
import requests
from bs4 import BeautifulSoup

crawled_urls = {}


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
        return None


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


def check_and_insert_wiki_page(file, wiki_page: wikipediaapi.WikipediaPage, language: str):
    if not wiki_page.exists():
        print("not exist")
        return
    if wiki_page.fullurl not in crawled_urls:
        print("crawling in: " + wiki_page.fullurl)
        poi = get_poi_from_page(wiki_page)
        if poi['position']:
            json.dump(poi, file)
            print("this page entered to db: " + wiki_page.fullurl)
    else:
        print("not crawling in: " + wiki_page.fullurl)


def crawl(file, wiki_page: wikipediaapi.WikipediaPage, language: str):
    check_and_insert_wiki_page(file=file, wiki_page=wiki_page, language=language)
    links = wiki_page.links
    for title in sorted(links.keys()):
        wiki_page_l = links[title]  # the wikipedia page from the link
        check_and_insert_wiki_page(file=file, wiki_page=wiki_page_l, language=language)

    for title in sorted(links.keys()):
        wiki_page_l = links[title]  # the wikipedia page from the link
        crawl(file=file, wiki_page=wiki_page_l, language=language)

        # if not wiki_page_l.exists():
        #     continue
        # if wiki_page_l.fullurl not in crawled_urls and get_position(wiki_page_l.fullurl):
        #     print("not crawled")
        #     print(links[title].fullurl)
        #     crawled_urls[links[title].fullurl] = '1'
        #     crawl(file, links[title], language)
        # else:
        #     print("crawled or no position!!!!")
        #     print(links[title].fullurl)


def main():
    # 'Alcsút Palace'
    wiki_page = search_page('Masada', 'en')
    # wiki_page = search_page('Alcsút Palace', 'en')
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
