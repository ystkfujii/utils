#!/bin/bash

for i in `find ./content/en -type f -name '*.md'`; do
        item=$(echo ${i} |  cut -d '/' -f 4-)
        if [ ! -e ./content/ja/${item} ]; then
                echo [NONE $(wc -l ./content/en/${item} | cut -d ' ' -f 1)] ./content/ja/${item}
                continue
        fi
        if [ ! ./content/ja/${item} -ot ./content/en/${item} ] && [ ! ./content/ja/${item} -nt ./content/en/${item} ] ; then
                /usr/share/rsync/scripts/git-set-file-times content/ja/${item} > /dev/null 2>&1
                /usr/share/rsync/scripts/git-set-file-times content/en/${item} > /dev/null 2>&1
                break
        fi
        echo [OLD] ./content/ja/${item}
done

for i in `find ./content/ja -type f -name '*.md'`; do
        item=$(echo ${i} |  cut -d '/' -f 4-)
        if [ ! -e ./content/en/${item} ]; then
                echo [MOVE] ./content/ja/${item}
                continue
        fi
done
