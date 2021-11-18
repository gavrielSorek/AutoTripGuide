import wikipediaapi
import sys
import requests

S = requests.Session()

def get_position(URL):
    S = requests.Session()

    PARAMS = {
        "action": "query",
        "format": "json",
        "titles": "Wikimedia Foundation",
        "prop": "coordinates"
    }
    R = S.get(url="https://en.wikipedia.org/wiki/Israel", params=PARAMS)
    DATA = R.json()
    PAGES = DATA['query']['pages']

    for k, v in PAGES.items():
        print("Latitute: " + str(v['coordinates'][0]['lat']))
        print("Longitude: " + str(v['coordinates'][0]['lon']))
    return 1999999


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
        raise ValueError('page ' + name_to_search + 'not found')


def crawl(db_name, first_page, language):
    db_file = open(db_name, 'a')
    wiki_page = search_page(first_page, language)

    print(wiki_page.title)
    print(wiki_page.summary)
    print(wiki_page.categories)
    print(wiki_page.langlinks)
    print(wiki_page.text)
    print(wiki_page.fullurl)
    print(get_position(wiki_page.fullurl))


    db_file.close()


def main():
    crawl(db_name="POI'S_DB", first_page='masada', language='en')
    # get_position('https://en.wikipedia.org/wiki/Masada')
    # page = search_page('masada', get_language('english'))
    # print(page.summary)


main()
