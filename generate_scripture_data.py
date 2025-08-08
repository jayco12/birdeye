#!/usr/bin/env python3
import requests
import json
import time

GEMINI_API_KEY = 'AIzaSyBJeeNKH9MfS1dU_GwJOcRly7DY7zIiYnM'  # Replace with your key
BIBLE_API_BASE = 'https://biblesdk.com'

BIBLE_BOOKS = {
    'GEN': 50, 'EXO': 40, 'LEV': 27, 'NUM': 36, 'DEU': 34,
    'JOS': 24, 'JDG': 21, 'RUT': 4, '1SA': 31, '2SA': 24,
    '1KI': 22, '2KI': 25, '1CH': 29, '2CH': 36, 'EZR': 10,
    'NEH': 13, 'EST': 10, 'JOB': 42, 'PSA': 150, 'PRO': 31,
    'ECC': 12, 'SNG': 8, 'ISA': 66, 'JER': 52, 'LAM': 5,
    'EZK': 48, 'DAN': 12, 'HOS': 14, 'JOL': 3, 'AMO': 9,
    'OBA': 1, 'JON': 4, 'MIC': 7, 'NAM': 3, 'HAB': 3,
    'ZEP': 3, 'HAG': 2, 'ZEC': 14, 'MAL': 4, 'MAT': 28,
    'MRK': 16, 'LUK': 24, 'JHN': 21, 'ACT': 28, 'ROM': 16,
    '1CO': 16, '2CO': 13, 'GAL': 6, 'EPH': 6, 'PHP': 4,
    'COL': 4, '1TH': 5, '2TH': 3, '1TI': 6, '2TI': 4,
    'TIT': 3, 'PHM': 1, 'HEB': 13, 'JAS': 5, '1PE': 5,
    '2PE': 3, '1JN': 5, '2JN': 1, '3JN': 1, 'JUD': 1, 'REV': 22,
}

def call_gemini(prompt):
    url = f'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash-latest:generateContent?key={GEMINI_API_KEY}'
    data = {
        'contents': [{'parts': [{'text': prompt}]}],
        'generationConfig': {'temperature': 0.7, 'maxOutputTokens': 200}
    }
    
    response = requests.post(url, json=data)
    if response.status_code == 200:
        return response.json()['candidates'][0]['content']['parts'][0]['text'].strip()
    print(f'Gemini API error: {response.status_code} - {response.text}')
    raise Exception(f'Gemini API error: {response.status_code}')

def fetch_chapter_verses(book, chapter):
    url = f'{BIBLE_API_BASE}/api/books/{book}/chapters/{chapter}/verses?concordance=true'
    response = requests.get(url)
    
    if response.status_code == 200:
        data = response.json()
        phrases = data.get('phrases', [])
        
        verse_map = {}
        for phrase in phrases:
            if phrase.get('verse'):
                verse_num = phrase['verse']
                if verse_num not in verse_map:
                    verse_map[verse_num] = []
                verse_map[verse_num].append(phrase)
        
        return [{'verse': v, 'text': ' '.join(p['text'] for p in phrases)} 
                for v, phrases in verse_map.items()]
    return []

def generate_insights(verse_text, book, chapter, verse):
    prompt = f'''Provide a concise spiritual insight for this Bible verse (2-3 sentences max):
"{verse_text}" ({book} {chapter}:{verse})

Focus on:
- Key spiritual principle or lesson
- Practical application for daily life
- Historical or cultural context if relevant

Also analyze significant Greek/Hebrew words with:
- Different meanings from typical usage (like "allos" vs "heteros" for "another")
- Theological significance
- Cultural/historical context
- Original language nuances lost in translation'''
    return call_gemini(prompt)

def generate_study_questions(verse_text):
    prompt = f'''Generate 3 thoughtful study questions for this Bible verse:
"{verse_text}"

Questions should:
- Encourage deep reflection
- Be applicable to modern life
- Vary in difficulty (basic understanding, application, deeper analysis)

Return as JSON array of strings.'''
    
    response = call_gemini(prompt)
    try:
        return json.loads(response)
    except:
        return response.split('\n')[:3]

def generate_word_analysis(verse_text, book, chapter, verse):
    prompt = f'''Analyze significant Greek/Hebrew words in this Bible verse for unique or notable usage:
"{verse_text}" ({book} {chapter}:{verse})

Identify words with:
- Different meanings from typical usage (like "allos" vs "heteros" for "another")
- Theological significance
- Cultural/historical context
- Original language nuances lost in translation

Return as JSON array: [{{"word": "english_word", "original": "greek/hebrew", "analysis": "explanation"}}]
Return empty array [] if no significant words found.'''
    
    response = call_gemini(prompt)
    try:
        return json.loads(response)
    except:
        return []

def main():
    all_data = []
    
    for book, chapters in BIBLE_BOOKS.items():
        print(f'Processing {book} ({chapters} chapters)...')
        
        for chapter in range(1, chapters + 1):
            try:
                verses = fetch_chapter_verses(book, chapter)
                
                for verse_data in verses:
                    verse_text = verse_data['text']
                    verse_num = verse_data['verse']
                    
                    insights = generate_insights(verse_text, book, chapter, verse_num)
                    questions = generate_study_questions(verse_text)
                    word_analysis = generate_word_analysis(verse_text, book, chapter, verse_num)
                    
                    all_data.append({
                        'book': book,
                        'chapter': chapter,
                        'verse': verse_num,
                        'text': verse_text,
                        'insights': insights,
                        'study_questions': questions,
                        'word_analysis': word_analysis,
                        'generated_at': time.strftime('%Y-%m-%dT%H:%M:%S')
                    })
                    
                    time.sleep(1)  # Rate limiting - slower to avoid quota
                
                # Save progress
                with open(f'progress_{book}_{chapter}.json', 'w') as f:
                    json.dump(all_data, f, indent=2)
                    
            except Exception as e:
                print(f'Error processing {book} {chapter}: {e}')
    
    # Save final data
    with open('complete_scripture_data.json', 'w') as f:
        json.dump(all_data, f, indent=2)
    
    print(f'Generation complete! {len(all_data)} verses processed')

if __name__ == '__main__':
    main()