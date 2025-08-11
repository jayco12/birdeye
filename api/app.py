# main.py
import json
import os
from fastapi import FastAPI, HTTPException
from typing import Dict, Any

app = FastAPI(title="Bible API with Strong's Numbers")
BOOK_CODE_MAP = {
    "genesis": "01",
    "exodus": "02",
    "leviticus": "03",
    "numbers": "04",
    "deuteronomy": "05",
    "joshua": "06",
    "judges": "07",
    "ruth": "08",
    "i_samuel": "09",
    "ii_samuel": "10",
    "i_kings": "11",
    "ii_kings": "12",
    "i_chronicles": "13",
    "ii_chronicles": "14",
    "ezra": "15",
    "nehemiah": "16",
    "esther": "17",
    "job": "18",
    "psalms": "19",
    "proverbs": "20",
    "ecclesiastes": "21",
    "song_of_solomon": "22",
    "isaiah": "23",
    "jeremiah": "24",
    "lamentations": "25",
    "ezekiel": "26",
    "daniel": "27",
    "hosea": "28",
    "joel": "29",
    "amos": "30",
    "obadiah": "31",
    "jonah": "32",
    "micah": "33",
    "nahum": "34",
    "habakkuk": "35",
    "zephaniah": "36",
    "haggai": "37",
    "zechariah": "38",
    "malachi": "39",
    "matthew": "40",
    "mark": "41",
    "luke": "42",
    "john": "43",
    "acts": "44",
    "romans": "45",
    "i_corinthians": "46",
    "ii_corinthians": "47",
    "galatians": "48",
    "ephesians": "49",
    "philippians": "50",
    "colossians": "51",
    "i_thessalonians": "52",
    "ii_thessalonians": "53",
    "i_timothy": "54",
    "ii_timothy": "55",
    "titus": "56",
    "philemon": "57",
    "hebrews": "58",
    "james": "59",
    "i_peter": "60",
    "ii_peter": "61",
    "i_john": "62",
    "ii_john": "63",
    "iii_john": "64",
    "jude": "65",
    "revelation": "66"
}

BIBLE_DATA: Dict[str, Any] = {}

BIBLE_FOLDER = "./bible"

# Load all books from folder
for filename in os.listdir(BIBLE_FOLDER):
    if filename.endswith(".json"):
        book_name = filename.replace(".json", "")
        with open(os.path.join(BIBLE_FOLDER, filename), "r", encoding="utf-8") as f:
            BIBLE_DATA[book_name] = json.load(f)
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
