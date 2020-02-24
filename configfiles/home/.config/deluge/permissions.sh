#!/bin/bash

find /mnt/NAS/new/Edit/ -iname '*.mkv' -exec mkvpropedit {} --delete-attachment mime-type:image/jpeg \; , -regextype posix-egrep -regex '.*\.(exe|jpg|nfo|txt|sub|idx|png|sfv)' -delete , -iname '*sample*' -delete;
filebot -script /home/marwinfaiter/.filebot/amc.groovy --def "exec=/home/marwinfaiter/.filebot/permissions.sh \"{folder}/\" \"{file}\" \"{folder.dir}\"" -r -non-strict --action move /mnt/NAS/new/Edit;
find /mnt/NAS/new/Edit/* -iname '*.srt' -delete , -empty -delete;
