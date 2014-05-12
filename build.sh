gitbook build src &&
python2 arrange.py &&
rm -r src/_book/_book &&
rm -r gitbook &&
mv src/_book/* . &&
rmdir src/_book
