import importlib
import subprocess
import json
import sys
import re

class Anime_downloader:
    def __init__(self, provider, anime):
        self.providers = {
            "horriblesubs": {
                "libpath": "Webscraper.Providers.HorribleSubs",
                "class": "HorribleSubs"
            },
            "erai_raws": {
                "libpath": "Webscraper.Providers.Erai_raws",
                "class": "Erai_raws"
            }
        }
        if not provider.lower() in self.providers:
            raise ValueError("The specified provider \"%s\" does not exit" % provider)

        self.anime = anime
        self.provider = provider
        self.chosen_episodes = []
        self.chosen_qualites_from_episodes = []

    def run(self):
        self.handler = getattr(importlib.import_module(self.providers[self.provider.lower()]["libpath"]), self.providers[self.provider.lower()]["class"])()
        if not hasattr(self, "handler"):
            raise ValueError("Couldn't create handler for %s" % self.provider)

        self.found_animes = self.handler.search_for_anime(self.anime)
        if not len(self.found_animes):
            print("Found no animes!")
            return True

        if not self.print_available_animes(): return
        if not self.get_anime_url(): return

        self.available_episodes = self.handler.get_episodes(self.anime_url)
        if not len(self.available_episodes["Batch"]) and not len(self.available_episodes["Episodes"]):
            print("Found no Episodes!")
            return True
        if not self.print_available_episodes(): return

        if not self.filter_to_chosen_episodes(): return
        if not len(self.chosen_episodes):
            print("Found no Episodes matching your input!")
            return True
        if not self.print_chosen_episodes(): return

        if not self.filter_to_chosen_quality(): return
        if not len(self.chosen_qualites_from_episodes):
            print("Found no Episodes matching your input!")
            return True
        if not self.print_chosen_quality(): return

        if not self.send_to_deluge(): return
        return True

    def filter_from_array(self, text, array):
        return [k for k in array if k["number"] == text]

    def print_available_animes(self):
        print("="*40)
        for anime in self.found_animes:
            print("%s: %s" % (self.found_animes.index(anime), anime["title"]))
        print("="*40)
        return True

    def print_available_episodes(self):
        print("Available episodes: ")
        print ("="*40)
        for array in self.available_episodes.keys():
            if not len(self.available_episodes[array]): continue
            print(array + ":")
            for episode in self.available_episodes[array]:
                qualities = ", ".join(map(lambda x: str(x+"p"), sorted(episode["quality"].keys(), key=int)))
                print("  %s: %s" % (episode["number"], qualities))
        print ("="*40)
        return True

    def print_chosen_episodes(self):
        print("Matches:")
        print ("="*40)
        for episode in self.chosen_episodes:
            qualities = ", ".join(map(lambda x: str(x+"p"), sorted(episode["quality"].keys(), key=int)))
            print("%s: %s" % (episode["number"], qualities))
        print ("="*40)
        return True

    def print_chosen_quality(self):
        print("Matches:")
        print ("="*40)
        for episode in self.chosen_qualites_from_episodes:
            print (episode["number"]+": "+episode["quality"]+"p")
        print ("="*40)
        return True

    def get_anime_url(self):
        chosen_anime = input("Which anime do you want to download?[0] ") or 0
        self.anime_url = self.found_animes[int(chosen_anime)]["href"]
        return True

    def filter_to_chosen_episodes(self):
        episodelist = input("Which episodes do you want?(comma separated list)\nx-y: all episodes betweeen and including x to y\nx-: all episodes after and including x\n-y: all episodes until including y\n[All except batches]: ")
        array = episodelist.split(",")

        if array[0] == "":
            self.chosen_episodes = self.available_episodes["Episodes"]
            return True
        for row in array:
            (x,y) = (None, None)
            if re.match("^\d*-\d*$", row):
                batcharray = self.filter_from_array(row, self.available_episodes["Batch"])
                if len(batcharray):
                    self.chosen_episodes.extend(batcharray)
                    continue
                (x,y) = row.split("-")
                x = x or self.available_episodes["Episodes"][0]["number"]
                y = y or self.available_episodes["Episodes"][-1]["number"]
            else:x = y = row

            if int(x) > int(y) or len(self.filter_from_array(x, self.available_episodes["Episodes"])) == 0 or len(self.filter_from_array(y, self.available_episodes["episodes"])) == 0:sys.exit("Invalid episode range or episode doesn't exist: "+row)
            for i in range(int(x),int(y)+1):
                episodesarray = self.filter_from_array(str(i), self.available_episodes["Episodes"])
                if len(episodesarray) > 0:
                    self.chosen_episodes.extend(episodesarray)
        return True

    def filter_to_chosen_quality(self):
        quality = input("Which quality do you want?[Best possible]: ")

        if quality != "": quality = quality.replace("p","")

        for episode in self.chosen_episodes:
            if not len(episode["quality"].keys()):
                continue
            if quality == "":
                quality = sorted(episode["quality"].keys(), key=int)[-1]
            if not quality in episode["quality"]:
                continue

            subhash = {
                "number": episode["number"],
                "quality": quality,
                "link": episode["quality"][quality]
            }
            self.chosen_qualites_from_episodes.append(subhash)
        return True

    def send_to_deluge(self):
        confirm = input("Do you want to download these files?(yes/no)[yes]: ") or "yes"
        if confirm.lower() != "yes": return True

        move = subprocess.check_output(["deluge-console","config","move_completed"]).strip().decode().split(": ")[1].lower()
        move_complete = input("Do you want to move completed?(yes/no)[no]: ") or "no"

        if move == "true" and move_complete.lower() == "no":subprocess.run(["deluge-console","config","-s","move_completed","false"],stdout=subprocess.DEVNULL)
        elif move == "false" and move_complete.lower() == "yes":subprocess.run(["deluge-console","config","-s","move_completed","true"],stdout=subprocess.DEVNULL)

        array = ["deluge-console","add"]
        for episode in self.chosen_qualites_from_episodes:
            array.append(episode["link"])
        subprocess.run(array)
        subprocess.run(["deluge-console","config","-s","move_completed",move],stdout=subprocess.DEVNULL)
        return True
