-- =============================================================================
-- Seed the dhikrs catalog (V1 list) with full localization.
--
-- Inserts the 7 V1 dhikrs with the Arabic source + all 10 transcription_* /
-- translation_* language pairs (en, fr, de, nl, tr, id, ur, bn, ms, ru) =
-- 11 supported languages total.
--
-- Idempotent: each row is inserted only when no dhikr with the same
-- transcription_en already exists, so re-running is safe even without a
-- unique constraint on the table.
-- =============================================================================

insert into public.dhikrs (
  arabic_text,
  transcription_en, transcription_fr, transcription_de, transcription_nl,
  transcription_tr, transcription_id, transcription_ur, transcription_bn,
  transcription_ms, transcription_ru,
  translation_en, translation_fr, translation_de, translation_nl,
  translation_tr, translation_id, translation_ur, translation_bn,
  translation_ms, translation_ru,
  min_count, ajr
)
select v.* from (
  values
  -- ── SubhanAllah ────────────────────────────────────────────────────────────
  (
    'سُبْحَانَ اللَّهِ',
    'SubhanAllah', 'SubhanAllah', 'SubhanAllah', 'SubhanAllah',
    'Sübhanallah', 'Subhanallah', 'سبحان اللہ', 'সুবহানাল্লাহ',
    'Subhanallah', 'СубханАллах',
    'Glory be to Allah', 'Gloire à Allah', 'Gepriesen sei Allah', 'Glorie zij aan Allah',
    'Allah''ı her türlü eksiklikten tenzih ederim', 'Maha Suci Allah', 'اللہ پاک ہے', 'আল্লাহ পবিত্র',
    'Maha Suci Allah', 'Пречист Аллах',
    33::smallint, 5::smallint
  ),
  -- ── Alhamdulilah ───────────────────────────────────────────────────────────
  (
    'الْحَمْدُ لِلَّهِ',
    'Alhamdulilah', 'Alhamdulilah', 'Alhamdulillah', 'Alhamdulillah',
    'Elhamdülillah', 'Alhamdulillah', 'الحمد للہ', 'আলহামদুলিল্লাহ',
    'Alhamdulillah', 'Альхамдулиллях',
    'All praise is due to Allah', 'Toute louange est à Allah', 'Alles Lob gebührt Allah', 'Alle lof komt toe aan Allah',
    'Hamd Allah''a mahsustur', 'Segala puji bagi Allah', 'تمام تعریفیں اللہ کے لیے ہیں', 'সমস্ত প্রশংসা আল্লাহর জন্য',
    'Segala puji bagi Allah', 'Хвала Аллаху',
    33::smallint, 5::smallint
  ),
  -- ── Allahu Akbar ───────────────────────────────────────────────────────────
  (
    'اللَّهُ أَكْبَرُ',
    'Allahu Akbar', 'Allahu Akbar', 'Allahu Akbar', 'Allahu Akbar',
    'Allahu Ekber', 'Allahu Akbar', 'اللہ اکبر', 'আল্লাহু আকবার',
    'Allahu Akbar', 'Аллаху Акбар',
    'Allah is the Greatest', 'Allah est le plus Grand', 'Allah ist der Größte', 'Allah is de Grootste',
    'Allah en büyüktür', 'Allah Maha Besar', 'اللہ سب سے بڑا ہے', 'আল্লাহ সর্বশ্রেষ্ঠ',
    'Allah Maha Besar', 'Аллах велик',
    33::smallint, 5::smallint
  ),
  -- ── La ilaha illallah ──────────────────────────────────────────────────────
  (
    'لَا إِلَٰهَ إِلَّا اللَّهُ',
    'La ilaha illallah', 'La ilaha illallah', 'La ilaha illallah', 'La ilaha illallah',
    'La ilahe illallah', 'La ilaha illallah', 'لا الٰہ الا اللہ', 'লা ইলাহা ইল্লাল্লাহ',
    'La ilaha illallah', 'Ля иляха илляллах',
    'There is no deity but Allah', 'Il n''y a de divinité qu''Allah', 'Es gibt keine Gottheit außer Allah', 'Er is geen god dan Allah',
    'Allah''tan başka ilah yoktur', 'Tiada tuhan selain Allah', 'اللہ کے سوا کوئی معبود نہیں', 'আল্লাহ ছাড়া কোনো উপাস্য নেই',
    'Tiada tuhan melainkan Allah', 'Нет божества, кроме Аллаха',
    33::smallint, 7::smallint
  ),
  -- ── Astaghfirullah ─────────────────────────────────────────────────────────
  (
    'أَسْتَغْفِرُ اللَّهَ',
    'Astaghfirullah', 'Astaghfirullah', 'Astaghfirullah', 'Astaghfirullah',
    'Estağfirullah', 'Astaghfirullah', 'استغفر اللہ', 'আস্তাগফিরুল্লাহ',
    'Astaghfirullah', 'Астагфируллах',
    'I seek forgiveness from Allah', 'Je demande pardon à Allah', 'Ich bitte Allah um Vergebung', 'Ik vraag Allah om vergeving',
    'Allah''tan bağışlanma dilerim', 'Aku memohon ampun kepada Allah', 'میں اللہ سے بخشش مانگتا ہوں', 'আমি আল্লাহর কাছে ক্ষমা প্রার্থনা করি',
    'Aku memohon ampun kepada Allah', 'Прошу прощения у Аллаха',
    33::smallint, 7::smallint
  ),
  -- ── Hasbunallah ────────────────────────────────────────────────────────────
  (
    'حَسْبُنَا اللَّهُ',
    'Hasbunallah', 'Hasbunallah', 'Hasbunallah', 'Hasbunallah',
    'Hasbunallah', 'Hasbunallah', 'حسبنا اللہ', 'হাসবুনাল্লাহ',
    'Hasbunallah', 'Хасбуналлах',
    'Allah is sufficient for us', 'Allah nous suffit', 'Allah genügt uns', 'Allah is ons voldoende',
    'Allah bize yeter', 'Cukuplah Allah bagi kami', 'ہمیں اللہ کافی ہے', 'আল্লাহই আমাদের জন্য যথেষ্ট',
    'Cukuplah Allah bagi kami', 'Достаточно нам Аллаха',
    33::smallint, 5::smallint
  ),
  -- ── La hawla wa la quwwata ─────────────────────────────────────────────────
  (
    'لَا حَوْلَ وَلَا قُوَّةَ',
    'La hawla wa la quwwata', 'La hawla wa la quwwata', 'La hawla wa la quwwata', 'La hawla wa la quwwata',
    'La havle ve la kuvvete', 'La hawla wala quwwata', 'لا حول ولا قوۃ', 'লা হাওলা ওয়ালা কুওয়াতা',
    'La haula wala quwwata', 'Ля хавля ва ля куввата',
    'There is no power nor strength except with Allah', 'Il n''y a de force ni de puissance qu''en Allah', 'Es gibt keine Macht und keine Kraft außer bei Allah', 'Er is geen macht noch kracht behalve bij Allah',
    'Güç ve kuvvet ancak Allah iledir', 'Tiada daya dan kekuatan kecuali dengan Allah', 'اللہ کے سوا نہ کوئی طاقت ہے نہ قوت', 'আল্লাহ ছাড়া কোনো শক্তি ও সামর্থ্য নেই',
    'Tiada daya dan kekuatan kecuali dengan Allah', 'Нет силы и могущества, кроме как у Аллаха',
    33::smallint, 5::smallint
  )
) as v(
  arabic_text,
  transcription_en, transcription_fr, transcription_de, transcription_nl,
  transcription_tr, transcription_id, transcription_ur, transcription_bn,
  transcription_ms, transcription_ru,
  translation_en, translation_fr, translation_de, translation_nl,
  translation_tr, translation_id, translation_ur, translation_bn,
  translation_ms, translation_ru,
  min_count, ajr
)
where not exists (
  select 1 from public.dhikrs d where d.transcription_en = v.transcription_en
);
