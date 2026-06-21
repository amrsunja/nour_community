#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Generate a Supabase-import-ready CSV for the public.duas table.
Columns and order match backend/supabase/sql_database.md exactly.
11 languages: en, fr, ar, de, nl, tr, id, ur, bn, ms, ru
- translation_* : all langs except ar (arabic_text is the original)
- transcription_*: all langs except ar (single Latin transliteration reused)
- title/when/reference/tafsir : all 11 langs
- tafsir_* left empty (no source text); when_* generated from context
"""
import csv

# Exact column order from the duas table DDL
COLUMNS = [
    "id", "arabic_text",
    "transcription_en", "transcription_fr",
    "translation_en", "translation_fr",
    "when_en", "when_fr", "when_ar",
    "reference_en", "reference_fr", "reference_ar",
    "tafsir_en", "tafsir_fr", "tafsir_ar",
    "audio_url", "ajr", "likes_count", "is_active",
    "created_at", "updated_at",
    "title_en", "title_fr", "title_ar",
    "position",
    "title_de", "title_nl", "title_tr", "title_id", "title_ur", "title_bn", "title_ms",
    "transcription_de", "transcription_nl", "transcription_tr", "transcription_id",
    "transcription_ur", "transcription_bn", "transcription_ms",
    "translation_de", "translation_nl", "translation_tr", "translation_id",
    "translation_ur", "translation_bn", "translation_ms",
    "when_de", "when_nl", "when_tr", "when_id", "when_ur", "when_bn", "when_ms",
    "reference_de", "reference_nl", "reference_tr", "reference_id",
    "reference_ur", "reference_bn", "reference_ms",
    "tafsir_de", "tafsir_nl", "tafsir_tr", "tafsir_id",
    "tafsir_ur", "tafsir_bn", "tafsir_ms",
    "title_ru", "transcription_ru", "translation_ru", "when_ru", "reference_ru", "tafsir_ru",
]

# Languages with their own transcription column (single Latin translit reused)
TRANSCRIPTION_LANGS = ["en", "fr", "de", "nl", "tr", "id", "ur", "bn", "ms", "ms_unused"]
# (handled explicitly in row builder)

# ---- digit localisation for references ----
AR_DIGITS = str.maketrans("0123456789", "٠١٢٣٤٥٦٧٨٩")
UR_DIGITS = str.maketrans("0123456789", "۰۱۲۳۴۵۶۷۸۹")
BN_DIGITS = str.maketrans("0123456789", "০১২৩৪৫৬৭৮৯")

QURAN_WORD = {
    "en": "Qur'an", "fr": "Coran", "ar": "القرآن", "de": "Koran", "nl": "Koran",
    "tr": "Kur'an", "id": "Al-Qur'an", "ur": "قرآن", "bn": "কুরআন",
    "ms": "Al-Quran", "ru": "Коран",
}

def reference(lang, ref):
    """ref like '1:1-7' -> localised reference string."""
    word = QURAN_WORD[lang]
    s = ref
    if lang == "ar":
        s = ref.translate(AR_DIGITS)
    elif lang == "ur":
        s = ref.translate(UR_DIGITS)
    elif lang == "bn":
        s = ref.translate(BN_DIGITS)
    return f"{word} {s}"

from seed_duas_data import DUAS

# transcription columns get the single Latin transliteration; ar has no transcription column
TRANSLIT_LANGS = ["en", "fr", "de", "nl", "tr", "id", "ur", "bn", "ms", "ru"]
# translation columns: every language except ar
TRANSLATION_LANGS = ["en", "fr", "de", "nl", "tr", "id", "ur", "bn", "ms", "ru"]
# title / when / reference / tafsir: all 11
ALL_LANGS = ["en", "fr", "ar", "de", "nl", "tr", "id", "ur", "bn", "ms", "ru"]


def build_row(idx, d):
    row = {c: "" for c in COLUMNS}
    row["arabic_text"] = d["arabic"]
    # transcription_* : same Latin translit everywhere
    for lang in TRANSLIT_LANGS:
        row[f"transcription_{lang}"] = d["translit"]
    # translation_* : all langs except ar
    for lang in TRANSLATION_LANGS:
        row[f"translation_{lang}"] = d["translation"][lang]
    # title_* / when_* : all 11 langs
    for lang in ALL_LANGS:
        row[f"title_{lang}"] = d["title"][lang]
        row[f"when_{lang}"] = d["when"][lang]
        row[f"reference_{lang}"] = reference(lang, d["ref"])
        # tafsir_* left empty (no source text)
    # scalar defaults (explicit so Supabase NOT NULL defaults are satisfied)
    row["ajr"] = 5
    row["likes_count"] = 0
    row["is_active"] = "true"
    row["audio_url"] = ""
    row["position"] = idx
    # id / created_at / updated_at left blank -> DB identity & defaults
    return row


def main():
    out_path = "/sessions/nice-ecstatic-goodall/mnt/outputs/duas_quranic.csv"
    rows = [build_row(i, d) for i, d in enumerate(DUAS, start=1)]
    with open(out_path, "w", newline="", encoding="utf-8") as f:
        w = csv.DictWriter(f, fieldnames=COLUMNS, quoting=csv.QUOTE_MINIMAL)
        w.writeheader()
        w.writerows(rows)
    print(f"Wrote {len(rows)} rows, {len(COLUMNS)} columns -> {out_path}")


if __name__ == "__main__":
    main()
