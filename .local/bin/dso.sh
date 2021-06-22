#!/usr/bin/env bash

echo "Daily Share-Out Generator v1.0"

mkdir -pv ~/.dso

echo "#---- $(date +%Y%m%d) ----#" >> ~/.dso/$(date +%Y%m%d)
echo "" >> ~/.dso/$(date +%Y%m%d)
echo "#---- Goals for today ----#" >> ~/.dso/$(date +%Y%m%d)
>&2 echo "What you plan to work on today. (1-3s, JIRAs)"
while IFS= read -r LINE || [[ -n "$LINE" ]]; do
    echo "${LINE}"
done >> ~/.dso/$(date +%Y%m%d)
echo "" >> ~/.dso/$(date +%Y%m%d)
echo "#---- 1-day Lookback----#" >> ~/.dso/$(date +%Y%m%d)
>&2 echo "What you achieved yesterday. (1-3s, JIRAs))"
while IFS= read -r LINE || [[ -n "$LINE" ]]; do
    echo "${LINE}"
done >> ~/.dso/$(date +%Y%m%d)
echo "" >> ~/.dso/$(date +%Y%m%d)
echo "#---- Blockers/needs ----#" >> ~/.dso/$(date +%Y%m%d)
>&2 echo "Blockers, dependencies, or questions."
while IFS= read -r LINE || [[ -n "$LINE" ]]; do
    echo "${LINE}"
done >> ~/.dso/$(date +%Y%m%d)
echo "" >> ~/.dso/$(date +%Y%m%d)
echo "#---- Any call-outs? ----#" >> ~/.dso/$(date +%Y%m%d)
>&2 echo "Wins and Shout-Outs (optional)"
while IFS= read -r LINE || [[ -n "$LINE" ]]; do
    echo "${LINE}"
done >> ~/.dso/$(date +%Y%m%d)
echo "" >> ~/.dso/$(date +%Y%m%d)
echo "#---- Items of interest? ----#" >> ~/.dso/$(date +%Y%m%d)
>&2 echo "Interesting Things"
while IFS= read -r LINE || [[ -n "$LINE" ]]; do
    echo "${LINE}"
done >> ~/.dso/$(date +%Y%m%d)
echo "" >> ~/.dso/$(date +%Y%m%d)
echo "#---- DSO generated at $(date -u --iso-8601=seconds)Z ----#" >> ~/.dso/$(date +%Y%m%d)
echo "" >> ~/.dso/$(date +%Y%m%d)
echo "################################################################################" >> ~/.dso/$(date +%Y%m%d)
cat ~/.dso/$(date +%Y%m%d)
