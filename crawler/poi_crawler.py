import json
import re
import time
import wikipediaapi
import threading
import sys
import requests
from bs4 import BeautifulSoup
import redis


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


# languages dictionary.
def get_language(language):
    languages = {"english": "en", "hebrew": "he"}
    return languages[language]


# search wikipedia page by name and returns it.
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


# return relevant categories
def is_relevant_category(category):
    irrelevant_key_words = ['cs1', 'articles', 'wikipedia', 'wikidata']
    for irrelevant_key in irrelevant_key_words:
        if re.search(irrelevant_key, category.lower()):
            return False
    return True


def get_relevant_categories(categories: wikipediaapi.WikipediaPage.categories):
    relevant_categories = []
    for category in categories:
        category = re.sub("Category:", "", category, count=1)  # delete the word category
        if is_relevant_category(category):
            relevant_categories.append(category)
    return relevant_categories


# return poi from given page
def get_poi_from_page(wiki_page: wikipediaapi.WikipediaPage):
    poi = {'title': wiki_page.title, 'summary': wiki_page.summary,
           'categories': get_relevant_categories(wiki_page.categories),
           'URL': wiki_page.fullurl, 'language': wiki_page.language, 'position': get_position(wiki_page.fullurl)}
    return poi


# return true if wiki_page is relevant
def is_relevant_page(wiki_page):
    irrelevant_key_words = ['cities', 'villages in', 'moshavim', 'district in', 'countries in', "villages", "lists of roads",
                            'district name']
    categories = wiki_page.categories
    for category in categories:
        for irrelevant_key in irrelevant_key_words:
            if re.search(irrelevant_key, category.lower()):
                return False
    return True


# return the title of the last crawled page with given languages
def last_crawled_lang_title(pois, lang):
    size = len(pois)
    idx = size - 1
    if size == 0:
        return "no pois"
    while idx >= 0:
        if pois[idx]['language'] == lang:
            return pois[idx]['title']
        idx -= 1
    return "no pois"  # if not found requested poi


# responsible on crawling and inserting pois logic
class Crawler:
    def __init__(self, start_wiki_page: wikipediaapi.WikipediaPage, redis_client, languages, output_json_f_name):
        self.redis_client = redis_client
        self.start_wiki_page = start_wiki_page
        self.languages = languages
        self.crawler_thread = None
        self.pois = []
        self.output_json_f_name = output_json_f_name
        self.continue_crawl = True

    def check_and_insert_wiki_page(self, wiki_page: wikipediaapi.WikipediaPage):
        if not wiki_page.exists():
            print("not exist")
            return
        # if new poi
        if not self.redis_client.exists(wiki_page.fullurl):
            print("crawling in: " + wiki_page.fullurl)
            poi = get_poi_from_page(wiki_page)
            if poi['position']:
                if not is_relevant_page(wiki_page):  # if not relevant page
                    return
                self.pois.append(poi)
                self.redis_client.set(wiki_page.fullurl, '1')
                # crawled_urls[wiki_page.fullurl] = '1'
                print("this page entered to db: " + wiki_page.fullurl)
                self.add_page_lang(page=wiki_page, position=poi['position'])
        else:
            print("not crawling in: " + wiki_page.fullurl)

    # add same pages in other languages
    def add_page_lang(self, page, position):
        # lang_links = page.langlinks very expensive
        lang_links = page.langlinks_customize(languages=self.languages)
        for language in lang_links:
            lang_page = lang_links[language]
            if not self.redis_client.exists(lang_page.fullurl):
                poi = get_poi_from_page(lang_page)
                if not poi['position']:  # if the position doesnt appeared in this page
                    poi['position'] = position
                self.pois.append(poi)
                self.redis_client.set(lang_page.fullurl, '1')
                print("this page entered to db: " + lang_page.fullurl)

    # start crawling from wiki_page
    def crawl(self, wiki_page: wikipediaapi.WikipediaPage):
        # if page is invalid
        self.check_and_insert_wiki_page(wiki_page=wiki_page)
        links = wiki_page.links
        while self.continue_crawl:
            for title in sorted(links.keys()):
                if not self.continue_crawl:
                    break
                wiki_page_l = links[title]  # the wikipedia page from the link
                self.check_and_insert_wiki_page(wiki_page=wiki_page_l)
            # crawling in all the links of wiki_page
            for title in sorted(links.keys()):
                if not self.continue_crawl:
                    break
                wiki_page_l = links[title]  # the wikipedia page from the link
                self.crawl(wiki_page=wiki_page_l)

    def crawl_with_thread(self):
        self.crawler_thread = threading.Thread(target=self.crawl, args=(self.start_wiki_page,))
        self.crawler_thread.start()

    def stop_crawler(self):
        self.continue_crawl = False
        if self.crawler_thread is not None:
            self.crawler_thread.join()
            # enters pois
            pois_file = open(self.output_json_f_name, 'w')
            json.dump(self.pois, pois_file)
            pois_file.close()
            # return last url crawled
            if len(self.pois) > 0:
                return last_crawled_lang_title(pois=self.pois, lang=self.start_wiki_page.language)
            return "no pois"
        return "no thread to stop"


# write the last file where crawlers stopped
def add_crawlers_last_title_file(file_name, last_titles):
    pois_file = open(file_name, 'w')
    json.dump(last_titles, pois_file)
    pois_file.close()


def start_logic():
    redis_client1 = redis.Redis(host='localhost', port=6379, db=0)
    num_of_thread = 3
    # pages num need to be = number of threads
    pages_to_start = [search_page('Masada', 'en'), search_page('Rujm el-Hiri', 'en'),
                      search_page('Nahal Betzet', 'en')]
    languages_for_threads = [['en', 'he'], ['en', 'he'], ['en', 'he']]
    crawlers = [None] * num_of_thread
    for i in range(num_of_thread):
        crawlers[i] = Crawler(pages_to_start[i], redis_client=redis_client1, languages=languages_for_threads[i]
                              , output_json_f_name='data_sender/json_file_' + str(i) + ".json")
    for i in range(num_of_thread):
        crawlers[i].crawl_with_thread()
    time.sleep(400)

    # add the last page that the crawlers crawled
    crawlers_last_title = []
    for i in range(num_of_thread):
        crawlers_last_title.append(crawlers[i].stop_crawler())
    add_crawlers_last_title_file("crawlers_last_title.json", crawlers_last_title)


def main():
    start_logic()


main()
