import json
import re
import time
import wikipediaapi
import threading
import sys
import requests
from bs4 import BeautifulSoup
import redis

crawl = True
crawled_urls = {}
pois = []

redis_client = redis.Redis(host='localhost', port=6379, db=0)

uuu = redis_client.exists('usernamea')
print(uuu)

# return poi position, or empty position if poi doesn't have any
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


# languages dictionary
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
    name_to_search = re.sub("(https:.+\.wikipedia\.org/wiki/)", "", url)
    return search_page(name_to_search, language)


# return poi from given page
def get_poi_from_page(wiki_page: wikipediaapi.WikipediaPage):
    poi = {'title': wiki_page.title, 'summary': wiki_page.summary, 'categories': [], 'URL': wiki_page.fullurl,
           'language': wiki_page.language}
    for category in wiki_page.categories:
        poi['categories'].append(category)
    poi['position'] = get_position(wiki_page.fullurl)
    return poi


# return true if wiki_page is relevant
def is_relevant_page(wiki_page):
    irrelevant_key_words = ['Cities in', 'Arab villages in']
    categories = wiki_page.categories
    for category in categories:
        for irrelevant_key in irrelevant_key_words:
            if re.search(irrelevant_key, category):
                return False
    return True


def check_and_insert_wiki_page(wiki_page: wikipediaapi.WikipediaPage, languages):
    if not wiki_page.exists():
        print("not exist")
        return
    # if new poi
    if  not redis_client.exists(wiki_page.fullurl):
        print("crawling in: " + wiki_page.fullurl)
        poi = get_poi_from_page(wiki_page)
        if poi['position']:
            if not is_relevant_page(wiki_page):  # if not relevant page
                return
            pois.append(poi)
            redis_client.set(wiki_page.fullurl, '1')
            #crawled_urls[wiki_page.fullurl] = '1'
            print("this page entered to db: " + wiki_page.fullurl)
            add_page_lang(wiki_page, languages)
    else:
        print("not crawling in: " + wiki_page.fullurl)


# add same pages in other languages
def add_page_lang(page, languages):
    # lang_links = page.langlinks very expensive
    lang_links = page.langlinks_customize(languages=languages)
    for language in lang_links:
        lang_page = lang_links[language]
        if not redis_client.exists(lang_page.fullurl):
            poi = get_poi_from_page(lang_page)
            pois.append(poi)
            redis_client.set(lang_page.fullurl, '1')
            #crawled_urls[lang_page.fullurl] = '1'
            print("this page entered to db: " + lang_page.fullurl)


def crawl(wiki_page: wikipediaapi.WikipediaPage, languages):
    check_and_insert_wiki_page(wiki_page=wiki_page, languages=languages)
    links = wiki_page.links
    while crawl:
        for title in sorted(links.keys()):
            if not crawl:
                break
            wiki_page_l = links[title]  # the wikipedia page from the link
            check_and_insert_wiki_page(wiki_page=wiki_page_l, languages=languages)

        for title in sorted(links.keys()):
            if not crawl:
                break
            wiki_page_l = links[title]  # the wikipedia page from the link
            crawl(wiki_page=wiki_page_l, language=languages)


def crawl_with_thread(wiki_page: wikipediaapi.WikipediaPage, languages):
    crawler_thread = threading.Thread(target=crawl, args=(wiki_page, languages,))
    crawler_thread.start()
    return crawler_thread


def stop_crawler():
    global crawl
    crawl = False


def start_logic():
    wiki_page = search_page('Masada', 'en')
    # wiki_page = search_page('Kiryat Ata', 'en')
    tread = crawl_with_thread(wiki_page=wiki_page, languages=['en', 'he'])
    time.sleep(100)
    stop_crawler()
    tread.join()
    pois_file = open("db_file.json", 'w')
    json.dump(pois, pois_file)
    pois_file.close()
    urls_file = open("urls_file.json", 'w')
    #json.dump(crawled_urls, urls_file)
    urls_file.close()


def main():
    start_logic()


main()
