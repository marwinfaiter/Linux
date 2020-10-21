import requests
from bs4 import BeautifulSoup
import sys
import os
from Webscraper.Anime_downloader import Anime_downloader

class HorribleSubs(Anime_downloader):
    def __init__(self, provider, anime):
        Anime_downloader.__init__(self, provider, anime)

    def search_for_anime(self):
        response = requests.post("https://horriblesubs.info/shows/")
        soup = BeautifulSoup(response.content.decode(),'html.parser')
        for row in soup.find_all("div", class_="ind-show"):
            link = BeautifulSoup(row.decode(),'html.parser').find("a")
            if re.match(".*"+self.anime+".*",link["title"], re.I):
                self.found_animes.append("title": link["title"], "href": link["href"])
        return True

    def get_episodes(self):
        if not self._get_anime_id(): return
        i = 0
        response = requests.post("https://horriblesubs.info/api.php?method=getshows&type=batch&showid="+self.id)
        while True:
            if response.content.decode() == "DONE":break
            soup = BeautifulSoup(response.content.decode(),'html.parser')
            for div in soup.find_all("div",class_="rls-info-container"):
                episode = re.sub("^0*","",div.get("id"))
                if episode == "": continue
                if i == 0 and not re.match("^\d+-\d+$", episode): continue
                elif i > 0 and not re.match("^\d+$", episode): continue

                subhash = {
                    "number": episode,
                    "quality": {}
                }

                for link in div.find_all("div", class_="rls-link"):
                    if link.find("a",{"title":"Magnet Link"}):
                        subhash["quality"][re.sub("\d+-|p","",link.get("id"))] = link.find("a",{"title":"Magnet Link"}).get("href")
                if i == 0:
                    self.available_episodes["Batch"].append(subhash)
                else:
                    self.available_episodes["Episodes"].append(subhash)
            response = requests.post("https://horriblesubs.info/api.php?method=getshows&type=show&showid="+self.id+"&nextid="+str(i))
            i += 1

        for array in self.available_episodes:
            self.available_episodes[array] = sorted(self.available_episodes[array], key=lambda i: i["number"])

    def _get_anime_id(self):
        anime = input("Which anime do you want to download?[1] ") or 1
        response = requests.post("https://horriblesubs.info"+self.found_animes[int(anime)])
        soup = BeautifulSoup(response.content.decode(),'html.parser')
        for row in soup.find_all("script"):
            text = BeautifulSoup(row.decode(),'html.parser').get_text()
            match = re.match(".*var hs_showid = (\d+).*",text)
            if match: self.id = match.group(1)
        return True