// =============================================================================
// Shared drawing helpers for the receipt renderers.
//
// pdf-lib's StandardFonts are WinAnsi-encoded: drawText THROWS on any character
// outside Latin-1 — and mosque names routinely carry Arabic. Everything written
// to a page therefore goes through winAnsi() first.
// =============================================================================

import { PDFDocument, PDFFont, PDFImage, PDFPage, RGB, rgb } from "npm:pdf-lib@1.17.1";

export const INK = rgb(0.09, 0.09, 0.11);
export const MUTED = rgb(0.42, 0.42, 0.46);
export const RULE = rgb(0.78, 0.78, 0.82);

/**
 * WinAnsi code points above Latin-1 that the standard fonts DO encode.
 * The euro sign matters: Intl currency formatting emits it and dropping it
 * turns "190,50 EUR" into a bare "190,50" on a legal document.
 */
const WIN_ANSI_EXTRA = new Set([0x20ac, 0x2022, 0x2020, 0x2021, 0x2030, 0x2122, 0x0152, 0x0153]);

/**
 * Makes a string safe for a WinAnsi standard font: drawText THROWS on anything
 * the encoding cannot represent, and mosque names routinely carry Arabic.
 *
 * Accented Latin is PRESERVED (Mosquee -> Mosquée stays correct): only the
 * characters that are genuinely unrepresentable are folded, and what survives
 * neither folding nor the allow-list is dropped rather than crashing the render.
 */
export function winAnsi(input: string | null | undefined): string {
  if (!input) return "";
  const pre = input
    .normalize("NFC")
    .replace(/[\u2018\u2019\u201B]/g, "'")
    .replace(/[\u201C\u201D]/g, '"')
    .replace(/[\u2013\u2014]/g, "-")
    .replace(/\u2026/g, "...")
    .replace(/[\u00A0\u202F\u2007\u2009]/g, " ");

  let out = "";
  for (const ch of pre) {
    const cp = ch.codePointAt(0)!;
    if (cp <= 0xff || WIN_ANSI_EXTRA.has(cp)) {
      out += ch;
      continue;
    }
    // Last resort: strip the character down to its base letters, if any.
    const folded = ch.normalize("NFKD").replace(/[\u0300-\u036f]/g, "");
    for (const f of folded) {
      const c2 = f.codePointAt(0)!;
      if (c2 <= 0xff || WIN_ANSI_EXTRA.has(c2)) out += f;
    }
  }
  return out.replace(/\s{2,}/g, " ").trim();
}

/** Same, but keeps a placeholder so a fully non-Latin name is not silently empty. */
export function winAnsiOr(input: string | null | undefined, fallback: string): string {
  const v = winAnsi(input);
  return v.length ? v : fallback;
}

export function formatMoney(amount: number, currency: string, locale: string): string {
  try {
    return new Intl.NumberFormat(locale, { style: "currency", currency }).format(amount);
  } catch {
    return `${amount.toFixed(2)} ${currency}`;
  }
}

export function formatDate(value: string | Date, locale: string): string {
  const d = value instanceof Date ? value : new Date(value);
  try {
    return new Intl.DateTimeFormat(locale, { day: "2-digit", month: "2-digit", year: "numeric" }).format(d);
  } catch {
    return d.toISOString().slice(0, 10);
  }
}

// ── Amount in words ─────────────────────────────────────────────────────────
// Mandatory in FR ("montant en chiffres et en lettres"); the previous
// implementation printed digits, which does not satisfy it.

const FR_UNITS = [
  "zero", "un", "deux", "trois", "quatre", "cinq", "six", "sept", "huit", "neuf", "dix",
  "onze", "douze", "treize", "quatorze", "quinze", "seize", "dix-sept", "dix-huit", "dix-neuf",
];
const FR_TENS: Record<number, string> = {
  20: "vingt", 30: "trente", 40: "quarante", 50: "cinquante",
  60: "soixante", 70: "soixante", 80: "quatre-vingt", 90: "quatre-vingt",
};

function frBelow100(n: number): string {
  if (n < 20) return FR_UNITS[n];
  const tens = Math.floor(n / 10) * 10;
  const unit = n % 10;
  if (tens === 70 || tens === 90) {
    const base = tens === 70 ? "soixante" : "quatre-vingt";
    return `${base}-${FR_UNITS[10 + unit]}`;
  }
  const base = FR_TENS[tens];
  if (unit === 0) return tens === 80 ? "quatre-vingts" : base;
  if (unit === 1 && tens !== 80) return `${base}-et-un`;
  return `${base}-${FR_UNITS[unit]}`;
}

function frBelow1000(n: number): string {
  if (n < 100) return frBelow100(n);
  const hundreds = Math.floor(n / 100);
  const rest = n % 100;
  const head = hundreds === 1 ? "cent" : `${FR_UNITS[hundreds]} cent${rest === 0 ? "s" : ""}`;
  return rest === 0 ? head : `${head} ${frBelow100(rest)}`;
}

function frInteger(n: number): string {
  if (n === 0) return "zero";
  const parts: string[] = [];
  const millions = Math.floor(n / 1_000_000);
  const thousands = Math.floor((n % 1_000_000) / 1000);
  const rest = n % 1000;
  if (millions) parts.push(`${millions === 1 ? "un million" : `${frBelow1000(millions)} millions`}`);
  if (thousands) parts.push(thousands === 1 ? "mille" : `${frBelow1000(thousands)} mille`);
  if (rest) parts.push(frBelow1000(rest));
  return parts.join(" ");
}

const EN_UNITS = [
  "zero", "one", "two", "three", "four", "five", "six", "seven", "eight", "nine", "ten",
  "eleven", "twelve", "thirteen", "fourteen", "fifteen", "sixteen", "seventeen", "eighteen", "nineteen",
];
const EN_TENS = ["", "", "twenty", "thirty", "forty", "fifty", "sixty", "seventy", "eighty", "ninety"];

function enBelow1000(n: number): string {
  if (n < 20) return EN_UNITS[n];
  if (n < 100) {
    const u = n % 10;
    return u ? `${EN_TENS[Math.floor(n / 10)]}-${EN_UNITS[u]}` : EN_TENS[Math.floor(n / 10)];
  }
  const rest = n % 100;
  const head = `${EN_UNITS[Math.floor(n / 100)]} hundred`;
  return rest ? `${head} and ${enBelow1000(rest)}` : head;
}

function enInteger(n: number): string {
  if (n === 0) return "zero";
  const parts: string[] = [];
  const millions = Math.floor(n / 1_000_000);
  const thousands = Math.floor((n % 1_000_000) / 1000);
  const rest = n % 1000;
  if (millions) parts.push(`${enBelow1000(millions)} million`);
  if (thousands) parts.push(`${enBelow1000(thousands)} thousand`);
  if (rest) parts.push(enBelow1000(rest));
  return parts.join(" ");
}

const CURRENCY_WORDS: Record<string, { fr: [string, string]; en: [string, string] }> = {
  EUR: { fr: ["euro", "centime"], en: ["euro", "cent"] },
  USD: { fr: ["dollar", "cent"], en: ["dollar", "cent"] },
  GBP: { fr: ["livre", "penny"], en: ["pound", "penny"] },
  CAD: { fr: ["dollar canadien", "cent"], en: ["canadian dollar", "cent"] },
};

/** "quatre-vingt-dix euros et cinquante centimes" */
export function amountInWords(amount: number, currency: string, locale: string): string {
  const lang = locale.startsWith("fr") ? "fr" : "en";
  const rounded = Math.round(amount * 100);
  const whole = Math.floor(rounded / 100);
  const cents = rounded % 100;
  const words = CURRENCY_WORDS[currency.toUpperCase()] ?? CURRENCY_WORDS.EUR;
  const [unit, sub] = words[lang];

  if (lang === "fr") {
    const digits = frInteger(whole);
    // "deux millions d'euros", not "deux millions euros"
    const elided = /\bmillions?$/.test(digits) && /^[aeiouy]/i.test(unit);
    const plural = whole > 1 ? `${unit}s` : unit;
    const head = elided ? `${digits} d'${plural}` : `${digits} ${plural}`;
    return cents === 0 ? head : `${head} et ${frInteger(cents)} ${cents > 1 ? `${sub}s` : sub}`;
  }
  const head = `${enInteger(whole)} ${whole === 1 ? unit : `${unit}s`}`;
  return cents === 0 ? head : `${head} and ${enInteger(cents)} ${cents === 1 ? sub : `${sub}s`}`;
}

// ── Layout ──────────────────────────────────────────────────────────────────

export const PAGE = { width: 595, height: 842, margin: 50 };

export class Cursor {
  y: number;
  constructor(
    readonly page: PDFPage,
    readonly font: PDFFont,
    readonly bold: PDFFont,
    start = PAGE.height - 60,
  ) {
    this.y = start;
  }

  text(
    value: string,
    opts: { size?: number; bold?: boolean; color?: RGB; gap?: number; x?: number } = {},
  ): void {
    const size = opts.size ?? 10.5;
    const safe = winAnsi(value);
    if (safe) {
      this.page.drawText(safe, {
        x: opts.x ?? PAGE.margin,
        y: this.y,
        size,
        font: opts.bold ? this.bold : this.font,
        color: opts.color ?? INK,
      });
    }
    this.y -= size + (opts.gap ?? 5);
  }

  /** Naive width-aware wrap; good enough for legal boilerplate. */
  paragraph(value: string, opts: { size?: number; color?: RGB; width?: number } = {}): void {
    const size = opts.size ?? 8.5;
    const width = opts.width ?? PAGE.width - PAGE.margin * 2;
    const words = winAnsi(value).split(" ");
    let line = "";
    for (const w of words) {
      const candidate = line ? `${line} ${w}` : w;
      if (this.font.widthOfTextAtSize(candidate, size) > width && line) {
        this.text(line, { size, color: opts.color, gap: 2 });
        line = w;
      } else {
        line = candidate;
      }
    }
    if (line) this.text(line, { size, color: opts.color, gap: 2 });
  }

  rule(gap = 10): void {
    this.page.drawLine({
      start: { x: PAGE.margin, y: this.y },
      end: { x: PAGE.width - PAGE.margin, y: this.y },
      thickness: 0.6,
      color: RULE,
    });
    this.y -= gap;
  }

  space(n = 8): void {
    this.y -= n;
  }

  section(title: string): void {
    this.space(6);
    this.text(title.toUpperCase(), { size: 9, bold: true, color: MUTED, gap: 4 });
  }
}

export async function embedSignature(
  pdf: PDFDocument,
  image: IssuerImageLike | null,
): Promise<PDFImage | null> {
  if (!image) return null;
  try {
    return image.mime.includes("png")
      ? await pdf.embedPng(image.bytes)
      : await pdf.embedJpg(image.bytes);
  } catch {
    return null; // a broken upload must not take the whole document down
  }
}

interface IssuerImageLike {
  bytes: Uint8Array;
  mime: string;
}

/** Wraps `text` at `width` and draws it downward from `y`. Returns the final y. */
export function drawWrapped(
  page: PDFPage,
  font: PDFFont,
  text: string,
  opts: { x: number; y: number; width: number; size: number; color?: RGB; leading?: number },
): number {
  const words = winAnsi(text).split(" ");
  const leading = opts.leading ?? opts.size + 2.5;
  let line = "";
  let y = opts.y;
  const flush = () => {
    if (!line) return;
    page.drawText(line, { x: opts.x, y, size: opts.size, font, color: opts.color ?? MUTED });
    y -= leading;
    line = "";
  };
  for (const w of words) {
    const candidate = line ? `${line} ${w}` : w;
    if (font.widthOfTextAtSize(candidate, opts.size) > opts.width && line) {
      flush();
      line = w;
    } else {
      line = candidate;
    }
  }
  flush();
  return y;
}
