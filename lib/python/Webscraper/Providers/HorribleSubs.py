import requests
from bs4 import BeautifulSoup
import sys
import os
import cloudscraper

class HorribleSubs:
    def search_for_anime(self, anime):
        found_animes = []
        scraper = cloudscraper.create_scraper()
        response = scraper.get("https://horriblesubs.info/shows/")
        soup = BeautifulSoup(response.content.decode(),'html.parser')
        for row in soup.find_all("div", class_="ind-show"):
            link = BeautifulSoup(row.decode(),'html.parser').find("a")
            if re.match(".*"+self.anime+".*",link["title"], re.I):
                found_animes.append({"title": link["title"], "href": link["href"]})
        return found_animes

    def get_episodes(self):
        if not self._get_anime_id(): return
        i = 0
        available_episodes = {
            "Batch": [],
            "Episodes": []
        }
        response = requests.post("https://horriblesubs.info/api.php?method=getshows&type=batch&showid="+self.anime_id)
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
                    available_episodes["Batch"].append(subhash)
                else:
                    available_episodes["Episodes"].append(subhash)
            response = requests.post("https://horriblesubs.info/api.php?method=getshows&type=show&showid="+self.anime_id+"&nextid="+str(i))
            i += 1

        for array in available_episodes:
            available_episodes[array] = sorted(available_episodes[array], key=lambda i: int(i["number"]))
        return available_episodes

    def _get_anime_id(self):
        anime = input("Which anime do you want to download?[1] ") or 1
        response = requests.post("https://horriblesubs.info"+self.found_animes[int(anime)])
        soup = BeautifulSoup(response.content.decode(),'html.parser')
        for row in soup.find_all("script"):
            text = BeautifulSoup(row.decode(),'html.parser').get_text()
            match = re.match(".*var hs_showid = (\d+).*",text)
            if match: self.anime_id = match.group(1)
        return True
