import requests
from bs4 import BeautifulSoup
import sys
import os
import re

class Erai_raws:
    def search_for_anime(self, anime):
        found_animes = []
        response = requests.post("https://erai-raws.info/anime-list/")
        soup = BeautifulSoup(response.content.decode(),'html.parser')
        for row in soup.find_all("div", class_="ind-show"):
            link = BeautifulSoup(row.decode(),'html.parser').find("a")
            if re.search(anime, link["title"], re.I):
                found_animes.append({"href": link["href"], "title": link["title"]})
        return found_animes

    def get_episodes(self, anime_url):
        urls = {
            "Batch": {
                "url": 'https://erai-raws.info/wp-admin/admin-ajax.php',
                "data": {
                    "action": "load_more_3",
                    "query": '{"anime-list":"'+anime_url+'","order":"ASC","nopaging":true}'
                }
            },
            "Episodes": {
                "url": 'https://erai-raws.info/wp-admin/admin-ajax.php',
                "data": {
                    "action": "load_more_0",
                    "query": '{"anime-list":"'+anime_url+'","order":"ASC","nopaging":true}',
                }
            }
        }

        available_episodes = {
            "Batch": [],
            "Episodes": []
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
                available_episodes[url].append(subhash)
        return available_episodes
