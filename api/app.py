import requests
from fastapi import Query
import json
import os
from fastapi import FastAPI, HTTPException
from typing import Dict, Any

app = FastAPI(title="Bible API with Strong's Numbers")

BOOK_CODE_MAP = {
  "GEN": {"api": "genesis", "code": "01"},
  "EXO": {"api": "exodus", "code": "02"},
  "LEV": {"api": "leviticus", "code": "03"},
  "NUM": {"api": "numbers", "code": "04"},
  "DEU": {"api": "deuteronomy", "code": "05"},
  "JOS": {"api": "joshua", "code": "06"},
  "JDG": {"api": "judges", "code": "07"},
  "RUT": {"api": "ruth", "code": "08"},
  "1SA": {"api": "i_samuel", "code": "09"},
  "2SA": {"api": "ii_samuel", "code": "10"},
  "1KI": {"api": "i_kings", "code": "11"},
  "2KI": {"api": "ii_kings", "code": "12"},
  "1CH": {"api": "i_chronicles", "code": "13"},
  "2CH": {"api": "ii_chronicles", "code": "14"},
  "EZR": {"api": "ezra", "code": "15"},
  "NEH": {"api": "nehemiah", "code": "16"},
  "EST": {"api": "esther", "code": "17"},
  "JOB": {"api": "job", "code": "18"},
  "PSA": {"api": "psalms", "code": "19"},
  "PRO": {"api": "proverbs", "code": "20"},
  "ECC": {"api": "ecclesiastes", "code": "21"},
  "SNG": {"api": "song_of_solomon", "code": "22"},
  "ISA": {"api": "isaiah", "code": "23"},
  "JER": {"api": "jeremiah", "code": "24"},
  "LAM": {"api": "lamentations", "code": "25"},
  "EZK": {"api": "ezekiel", "code": "26"},
  "DAN": {"api": "daniel", "code": "27"},
  "HOS": {"api": "hosea", "code": "28"},
  "JOL": {"api": "joel", "code": "29"},
  "AMO": {"api": "amos", "code": "30"},
  "OBA": {"api": "obadiah", "code": "31"},
  "JON": {"api": "jonah", "code": "32"},
  "MIC": {"api": "micah", "code": "33"},
  "NAM": {"api": "nahum", "code": "34"},
  "HAB": {"api": "habakkuk", "code": "35"},
  "ZEP": {"api": "zephaniah", "code": "36"},
  "HAG": {"api": "haggai", "code": "37"},
  "ZEC": {"api": "zechariah", "code": "38"},
  "MAL": {"api": "malachi", "code": "39"},
  "MAT": {"api": "matthew", "code": "40"},
  "MRK": {"api": "mark", "code": "41"},
  "LUK": {"api": "luke", "code": "42"},
  "JHN": {"api": "john", "code": "43"},
  "ACT": {"api": "acts", "code": "44"},
  "ROM": {"api": "romans", "code": "45"},
  "1CO": {"api": "i_corinthians", "code": "46"},
  "2CO": {"api": "ii_corinthians", "code": "47"},
  "GAL": {"api": "galatians", "code": "48"},
  "EPH": {"api": "ephesians", "code": "49"},
  "PHP": {"api": "philippians", "code": "50"},
  "COL": {"api": "colossians", "code": "51"},
  "1TH": {"api": "i_thessalonians", "code": "52"},
  "2TH": {"api": "ii_thessalonians", "code": "53"},
  "1TI": {"api": "i_timothy", "code": "54"},
  "2TI": {"api": "ii_timothy", "code": "55"},
  "TIT": {"api": "titus", "code": "56"},
  "PHM": {"api": "philemon", "code": "57"},
  "HEB": {"api": "hebrews", "code": "58"},
  "JAS": {"api": "james", "code": "59"},
  "1PE": {"api": "i_peter", "code": "60"},
  "2PE": {"api": "ii_peter", "code": "61"},
  "1JN": {"api": "i_john", "code": "62"},
  "2JN": {"api": "ii_john", "code": "63"},
  "3JN": {"api": "iii_john", "code": "64"},
  "JUD": {"api": "jude", "code": "65"},
  "REV": {"api": "revelation", "code": "66"},
}
# Map HELLOAO codes and aliases to local folder keys:
BOOK_FOLDER_MAP = {
    "GEN": "genesis",
    "EXO": "exodus",
    "LEV": "leviticus",
    "NUM": "numbers",
    "DEU": "deuteronomy",
    "JOS": "joshua",
    "JDG": "judges",
    "RUT": "ruth",
    "1SA": "i_samuel",
    "2SA": "ii_samuel",
    "1KI": "i_kings",
    "2KI": "ii_kings",
    "1CH": "i_chronicles",
    "2CH": "ii_chronicles",
    "EZR": "ezra",
    "NEH": "nehemiah",
    "EST": "esther",
    "JOB": "job",
    "PSA": "psalms",
    "PRO": "proverbs",
    "ECC": "ecclesiastes",
    "SNG": "song_of_solomon",
    "ISA": "isaiah",
    "JER": "jeremiah",
    "LAM": "lamentations",
    "EZK": "ezekiel",
    "DAN": "daniel",
    "HOS": "hosea",
    "JOL": "joel",
    "AMO": "amos",
    "OBA": "obadiah",
    "JON": "jonah",
    "MIC": "micah",
    "NAM": "nahum",
    "HAB": "habakkuk",
    "ZEP": "zephaniah",
    "HAG": "haggai",
    "ZEC": "zechariah",
    "MAL": "malachi",
    "MAT": "matthew",
    "MRK": "mark",
    "LUK": "luke",
    "JHN": "john",
    "ACT": "acts",
    "ROM": "romans",
    "1CO": "i_corinthians",
    "2CO": "ii_corinthians",
    "GAL": "galatians",
    "EPH": "ephesians",
    "PHP": "philippians",
    "COL": "colossians",
    "1TH": "i_thessalonians",
    "2TH": "ii_thessalonians",
    "1TI": "i_timothy",
    "2TI": "ii_timothy",
    "TIT": "titus",
    "PHM": "philemon",
    "HEB": "hebrews",
    "JAS": "james",
    "1PE": "i_peter",
    "2PE": "ii_peter",
    "1JN": "i_john",
    "2JN": "ii_john",
    "3JN": "iii_john",
    "JUD": "jude",
    "REV": "revelation",
}
FOLDER_TO_CODE = {v: k for k, v in BOOK_FOLDER_MAP.items()}

BIBLE_DATA: Dict[str, Any] = {}

BIBLE_FOLDER = "./bible"

HELLOAO_BASE = "https://bible.helloao.org/api"

# Load all local Strong's data
for filename in os.listdir(BIBLE_FOLDER):
    if filename.endswith(".json"):
        book_name = filename.replace(".json", "")
        with open(os.path.join(BIBLE_FOLDER, filename), "r", encoding="utf-8") as f:
            BIBLE_DATA[book_name] = json.load(f)
@app.get("/books/{translation}/{book}/{chapter}")
def get_helloao_chapter(translation: str, book: str, chapter: int):
    # Validate translation? (optional)
    # Normalize book code
    try:
        _, api_code = normalize_book(book)
    except HTTPException as e:
        raise e
    
    # Call HelloAO API for that translation
    url = f"{HELLOAO_BASE}/{translation}/{api_code}/{chapter}.json"
    r = requests.get(url)
    if r.status_code != 200:
        raise HTTPException(status_code=404, detail=f"Chapter not found in HelloAO for translation '{translation}'")
    return r.json()

@app.get("/books/{translation}/{book}/{chapter}/{verse}")
def get_helloao_verse(translation: str, book: str, chapter: int, verse: int):
    try:
        _, api_code = normalize_book(book)
    except HTTPException as e:
        raise e
    
    url = f"{HELLOAO_BASE}/{translation}/{api_code}/{chapter}.json"
    r = requests.get(url)
    if r.status_code != 200:
        raise HTTPException(status_code=404, detail=f"Chapter not found in HelloAO for translation '{translation}'")

    data = r.json()
    verse_entry = next(
        (v for v in data["chapter"]["content"] if v.get("type") == "verse" and v.get("number") == verse),
        None,
    )
    if not verse_entry:
        raise HTTPException(status_code=404, detail="Verse not found in HelloAO data")
    
    # Return verse only, or wrap in some structure
    return {
        "book": data["book"]["name"],
        "chapter": chapter,
        "verse_number": verse,
        "content": verse_entry,
    }

def fetch_clean_chapter(book_code: str, chapter: int, translation="eng_kjv"):
    """Fetch chapter data from HelloAO API."""
    url = f"{HELLOAO_BASE}/{translation}/{book_code}/{chapter}.json"
    r = requests.get(url)
    if r.status_code != 200:
        raise HTTPException(status_code=404, detail="Unable to fetch clean text from HelloAO")
    return r.json()
def normalize_book(book: str):
    book_upper = book.upper()
    book_lower = book.lower()

    if book_upper in BOOK_FOLDER_MAP:
        folder_key = BOOK_FOLDER_MAP[book_upper]
        api_code = book_upper
    elif book_lower in FOLDER_TO_CODE:
        folder_key = book_lower
        api_code = FOLDER_TO_CODE[book_lower]
    else:
        raise HTTPException(status_code=404, detail="Book not found")

    return folder_key, api_code
def merge_chapter(book: str, chapter: int):
    folder_key, api_code = normalize_book(book)

    strongs_book = BIBLE_DATA.get(folder_key)
    if not strongs_book:
        raise HTTPException(status_code=404, detail=f"Local data for '{folder_key}' not found")

    clean_data = fetch_clean_chapter(api_code, chapter)

    book_code = BOOK_CODE_MAP[api_code]["code"]

    merged_verses = []
    for verse_entry in clean_data["chapter"]["content"]:
        if verse_entry["type"] != "verse":
            continue

        verse_number = verse_entry["number"]
        clean_text = " ".join(
            part if isinstance(part, str) else part.get("text", "")
            for part in verse_entry["content"]
        )

        verse_id = f"{book_code}{chapter:03}{verse_number:03}"
        local_verse = next((v for v in strongs_book if v["id"] == verse_id), None)

        if local_verse:
            strongs_phrases = local_verse.get("verse", [])
            matched_phrases = []
            for phrase in strongs_phrases:
                phrase_text = phrase.get("text", "")
                if phrase_text and phrase_text.lower() in clean_text.lower():
                    matched_phrases.append({
                        "text": phrase_text,
                        "word": phrase.get("word"),
                        "number": phrase.get("number")
                    })
        else:
            matched_phrases = []

        merged_verses.append({
            "verse_number": verse_number,
            "clean_text": clean_text,
            "strongs": matched_phrases
        })

    return {
        "book": clean_data["book"]["name"],
        "chapter": chapter,
        "verses": merged_verses
    }

@app.get("/merged/{book}/{chapter}")
def get_merged_chapter(book: str, chapter: int):
    return merge_chapter(book, chapter)

from fastapi import Query

@app.get("/merged/{book}/{chapter}/{verse}")
def get_single_verse(book: str, chapter: int, verse: int):
    folder_key, api_code = normalize_book(book)

    strongs_book = BIBLE_DATA.get(folder_key)
    if not strongs_book:
        raise HTTPException(status_code=404, detail=f"Local data for '{folder_key}' not found")

    # Compose verse ID like "01001001" = book_code + chapter (3 digits) + verse (2 digits)
    book_code = BOOK_CODE_MAP[book.upper()]
    verse_id = f"{book_code['code']}{chapter:03}{verse:03}"

    local_verse = next((v for v in strongs_book if v["id"] == verse_id), None)
    if not local_verse:
        raise HTTPException(status_code=404, detail="Verse not found")

    clean_data = fetch_clean_chapter(api_code, chapter)

    # Find clean text for the verse
    verse_entry = next(
        (v for v in clean_data["chapter"]["content"] if v.get("type") == "verse" and v.get("number") == verse),
        None,
    )
    if not verse_entry:
        raise HTTPException(status_code=404, detail="Clean verse text not found")

    clean_text = " ".join(
        part if isinstance(part, str) else part.get("text", "")
        for part in verse_entry["content"]
    )

    return {
        "verse_number": verse,
        "clean_text": clean_text,
        "strongs": local_verse.get("verse", []),
    }


@app.get("/search")
def search_verses(q: str = Query(..., min_length=1)):
    q_lower = q.lower()
    results = []

    for book_name, verses in BIBLE_DATA.items():
        for verse in verses:
            # Join phrase texts for searching
            verse_text = "".join(p.get("text", "") for p in verse.get("verse", [])).lower()
            if q_lower in verse_text:
                results.append({
                    "id": verse.get("id"),
                    "book": book_name,
                    "chapter": int(verse.get("id")[2:5]),
                    "verse": int(verse.get("id")[5:]),
                    "text": verse_text,
                    "strongs": verse.get("verse"),
                })

    return {"results": results}

@app.get("/")
def read_root():
    return {"message": "Welcome to your Bible API!"}

@app.get("/books")
def list_books():
    return {"books": list(BIBLE_DATA.keys())}

@app.get("/books/{book}")
def get_book(book: str):
    book_data = BIBLE_DATA.get(book)
    if not book_data:
        raise HTTPException(status_code=404, detail="Book not found")
    return book_data

@app.get("/books/{book}/{chapter}")
def get_chapter(book: str, chapter: int):
    book_lower = book.lower()
    book_code = BOOK_CODE_MAP.get(book_lower)
    if not book_code:
        raise HTTPException(status_code=404, detail="Book not found")

    chapter_str = f"{book_code}{chapter:03}"  # e.g. "41005" for Mark chapter 5
    book_data = BIBLE_DATA.get(book_lower)
    if not book_data:
        raise HTTPException(status_code=404, detail="Book data not found")

    verses = [v for v in book_data if v["id"].startswith(chapter_str)]

    if not verses:
        raise HTTPException(status_code=404, detail="Chapter not found")

    return verses


@app.get("/books/{book}/{chapter}/{verse}")
def get_verse(book: str, chapter: int, verse: int):
    book_data = BIBLE_DATA.get(book)
    if not book_data:
        raise HTTPException(status_code=404, detail="Book not found")

    verse_id = f"{int(book):02}{chapter:03}{verse:02}"  # e.g. "0200101"
    verse_data = next((v for v in book_data if v["id"] == verse_id), None)

    if not verse_data:
        raise HTTPException(status_code=404, detail="Verse not found")

    return verse_data
@app.get("/search")
def search_verses(q: str = Query(..., min_length=1), translation: str = "default"):
    results = []

    q_lower = q.lower()

    # Iterate all books and verses in BIBLE_DATA
    for book_name, verses in BIBLE_DATA.items():
        for verse in verses:
            # Your verse text might be constructed by joining all phrase 'text' fields inside 'verse' key
            verse_text = "".join([p.get("text", "") for p in verse.get("verse", [])]).lower()

            if q_lower in verse_text:
                # Compose minimal verse info for response
                results.append({
                    "id": verse.get("id"),
                    "book": book_name,
                    "chapter": int(verse.get("id")[2:5]),  # Extract chapter from id string
                    "verse": int(verse.get("id")[5:]),     # Extract verse number from id string
                    "text": verse_text,
                    "verse_data": verse.get("verse"),      # Optional: full phrase data if needed
                })

    return {"results": results}