#!/usr/bin/env bash

echo "Daily Share-Out Generator v1.0"
>&2 echo

mkdir -pv ~/.dso

echo "#---- $(date +%Y%m%d) ----#" >> ~/.dso/$(date +%Y%m%d)
echo "" >> ~/.dso/$(date +%Y%m%d)
echo "__Goals for today:__" >> ~/.dso/$(date +%Y%m%d)
>&2 echo "What you plan to work on today. (1-3s, JIRAs) (Ctrl-D to move to next section)"
while IFS= read -r LINE || [[ -n "$LINE" ]]; do
    echo "* ${LINE}"
done >> ~/.dso/$(date +%Y%m%d)
echo "" >> ~/.dso/$(date +%Y%m%d)
>&2 echo
echo "__1-day Lookback__" >> ~/.dso/$(date +%Y%m%d)
>&2 echo "What you achieved yesterday. (1-3s, JIRAs) (Ctrl-D to move to next section)"
while IFS= read -r LINE || [[ -n "$LINE" ]]; do
    echo "* ${LINE}"
done >> ~/.dso/$(date +%Y%m%d)
echo "" >> ~/.dso/$(date +%Y%m%d)
>&2 echo
echo "__Blockers/needs__" >> ~/.dso/$(date +%Y%m%d)
>&2 echo "Blockers, dependencies, or questions. (Ctrl-D to move to next section)"
while IFS= read -r LINE || [[ -n "$LINE" ]]; do
    echo "* ${LINE}"
done >> ~/.dso/$(date +%Y%m%d)
echo "" >> ~/.dso/$(date +%Y%m%d)
>&2 echo
echo "__Any call-outs?__" >> ~/.dso/$(date +%Y%m%d)
>&2 echo "Wins and Shout-Outs (optional) (Ctrl-D to move to next section)"
while IFS= read -r LINE || [[ -n "$LINE" ]]; do
    echo "* ${LINE}"
done >> ~/.dso/$(date +%Y%m%d)
echo "" >> ~/.dso/$(date +%Y%m%d)
>&2 echo
echo "__Items of interest?__" >> ~/.dso/$(date +%Y%m%d)
>&2 echo "Interesting Things (Ctrl-D to move to next section)"
while IFS= read -r LINE || [[ -n "$LINE" ]]; do
    echo "* ${LINE}"
done >> ~/.dso/$(date +%Y%m%d)
echo "" >> ~/.dso/$(date +%Y%m%d)
>&2 echo
echo "_DSO generated at $(date -u --iso-8601=seconds)Z_" >> ~/.dso/$(date +%Y%m%d)
echo "" >> ~/.dso/$(date +%Y%m%d)
cat ~/.dso/$(date +%Y%m%d)
