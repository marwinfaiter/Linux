import requests
from bs4 import BeautifulSoup
import sys
import os
import re
from Webscraper.Anime_downloader import Anime_downloader

class Erai_raws(Anime_downloader):
    def __init__(self, provider, anime):
        Anime_downloader.__init__(self, provider, anime)

    def search_for_anime(self):
        response = requests.post("https://erai-raws.info/anime-list/")
        soup = BeautifulSoup(response.content.decode(),'html.parser')
        for row in soup.find_all("div", class_="ind-show"):
            link = BeautifulSoup(row.decode(),'html.parser').find("a")
            if re.search(self.anime, link["title"], re.I):
                self.found_animes.append({"href": link["href"], "title": link["title"]})
        return True

    def get_episodes(self):
        urls = {
            "Batch": {
                "url": 'https://erai-raws.info/wp-admin/admin-ajax.php',
                "data": {
                    "action": "load_more_3",
                    "query": '{"anime-list":"'+self.anime_url+'","order":"ASC","nopaging":true}'
                }
            },
            "Episodes": {
                "url": 'https://erai-raws.info/wp-admin/admin-ajax.php',
                "data": {
                    "action": "load_more_0",
                    "query": '{"anime-list":"'+self.anime_url+'","order":"ASC","nopaging":true}',
                }
            }
        }

        for url in urls:
            response = requests.post(urls[url]["url"], data = urls[url]["data"])
            soup = BeautifulSoup(response.content.decode(),'html.parser')
            for article in soup.find_all("article"):
                episode_div = article.find("div")
                episode_id = episode_div["id"]
                episode_number = episode_div.find("h1").find_all("a")[-1].find("font").text
                episode_number = re.sub("\n", "", episode_number)
                episode_number = re.sub("\s+", " ", episode_number)
                episode_number = episode_number.strip()
                episode_number = re.sub(" ~ ", "-", episode_number)

                subhash = {
                    "id": episode_id,
                    "number": episode_number,
                    "quality": {},
                }

                episode_quality_divs = episode_div.find_all("div",class_="release-links")
                for quality_div in episode_quality_divs:
                    quality = re.sub("p|«|»","",quality_div.find("i").text)
                    for a in quality_div.find_all("a"):
                        if a.text == "Magnet":
                            subhash["quality"][quality] = a["href"]
                        elif a.text == "Torrent" and not quality in subhash["quality"]:
                            subhash["quality"][quality] = a["href"]

                self.available_episodes[url].append(subhash)
        return True