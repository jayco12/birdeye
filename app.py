# main.py
import json
import os
from fastapi import FastAPI, HTTPException
from typing import Dict, Any

app = FastAPI(title="Bible API with Strong's Numbers")

BIBLE_DATA: Dict[str, Any] = {}

BIBLE_FOLDER = "./bible"

# Load all books from folder
for filename in os.listdir(BIBLE_FOLDER):
    if filename.endswith(".json"):
        book_name = filename.replace(".json", "")
        with open(os.path.join(BIBLE_FOLDER, filename), "r", encoding="utf-8") as f:
            BIBLE_DATA[book_name] = json.load(f)

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
def get_chapter(book: str, chapter: str):
    book_data = BIBLE_DATA.get(book)
    if not book_data:
        raise HTTPException(status_code=404, detail="Book not found")
    chapter_data = book_data.get(chapter)
    if not chapter_data:
        raise HTTPException(status_code=404, detail="Chapter not found")
    return chapter_data

@app.get("/books/{book}/{chapter}/{verse}")
def get_verse(book: str, chapter: str, verse: str):
    book_data = BIBLE_DATA.get(book)
    if not book_data:
        raise HTTPException(status_code=404, detail="Book not found")
    chapter_data = book_data.get(chapter)
    if not chapter_data:
        raise HTTPException(status_code=404, detail="Chapter not found")
    verse_data = chapter_data.get(verse)
    if not verse_data:
        raise HTTPException(status_code=404, detail="Verse not found")
    return verse_data
