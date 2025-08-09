import requests
from bs4 import BeautifulSoup
import json

def scrape_kjv_genesis_chapter(chapter=1):
    url = f'https://quod.lib.umich.edu/cgi/k/kjv/kjv-idx?byte=1493&type=DIV2&chunk=gen{chapter}.1'
    r = requests.get(url)
    soup = BeautifulSoup(r.text, 'html.parser')
    text = soup.get_text('\n')
    verses = {}
    for line in text.split('\n'):
        line = line.strip()
        if line.startswith('[') and ']' in line:
            verse_num, verse_text = line.lstrip('[').split(']', 1)
            if verse_num.isdigit():
                verses[int(verse_num)] = verse_text.strip()
    return verses

sample = scrape_kjv_genesis_chapter(1)
for v in range(1,6):
    print(f"{v}: {sample.get(v)}")
