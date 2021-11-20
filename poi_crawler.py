import json
import re
import time
import wikipediaapi
import threading
import sys
import requests
from bs4 import BeautifulSoup
crawl = True
crawled_urls = {}
pois = []


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


def check_and_insert_wiki_page(wiki_page: wikipediaapi.WikipediaPage):
    if not wiki_page.exists():
        print("not exist")
        return
    if wiki_page.fullurl not in crawled_urls:
        print("crawling in: " + wiki_page.fullurl)
        poi = get_poi_from_page(wiki_page)
        if poi['position']:
            pois.append(poi)
            crawled_urls[wiki_page.fullurl] = '1'
            print("this page entered to db: " + wiki_page.fullurl)
    else:
        print("not crawling in: " + wiki_page.fullurl)


def crawl(wiki_page: wikipediaapi.WikipediaPage, language: str):
    check_and_insert_wiki_page(wiki_page=wiki_page)
    links = wiki_page.links
    while crawl:
        for title in sorted(links.keys()):
            if not crawl:
                break
            wiki_page_l = links[title]  # the wikipedia page from the link
            check_and_insert_wiki_page(wiki_page=wiki_page_l)

        for title in sorted(links.keys()):
            if not crawl:
                break
            wiki_page_l = links[title]  # the wikipedia page from the link
            crawl(wiki_page=wiki_page_l, language=language)


def crawl_with_thread(wiki_page: wikipediaapi.WikipediaPage, language: str):
    wiki_page = search_page('Masada', 'en')
    crawler_thread = threading.Thread(target=crawl, args=(wiki_page, language,))
    crawler_thread.start()
    return crawler_thread


def stop_crawler():
    global crawl
    crawl = False


def main():
    # 'Alcsút Palace'
    wiki_page = search_page('Masada', 'en')
    tread = crawl_with_thread(wiki_page=wiki_page, language='en')
    time.sleep(10)
    stop_crawler()
    tread.join()
    pois_file = open("db_file.json", 'w')
    json.dump(pois, pois_file)
    pois_file.close()
    urls_file = open("urls_file.json", 'w')
    json.dump(crawled_urls, urls_file)
    urls_file.close()

main()
