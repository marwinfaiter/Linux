#!/bin/bash

pids=($(pgrep -f .config/deluge/permissions.sh));
pids=(${pids[@]/$$});

if [[ ${#pids[@]} -gt 0 ]]; then
    tail -f --pid=${pids[-1]} /dev/null;
fi

find /mnt/NAS/new/Edit/ -iname '*.mkv' -exec mkvpropedit {} --delete-attachment mime-type:image/jpeg \; , -regextype posix-egrep -regex '.*\.(exe|jpg|nfo|txt|sub|idx|png|sfv)' -delete , -iname '*sample*' -delete;

filebot -script /home/marwinfaiter/.filebot/amc.groovy --def "exec=/home/marwinfaiter/.filebot/permissions.sh \"{folder}/\" \"{file}\" \"{folder.dir}\"" -r -non-strict --action move /mnt/NAS/new/Edit;
find /mnt/NAS/new/Edit/ -mindepth 1 -iname '*.srt' -delete , -empty -delete;
