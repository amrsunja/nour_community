-- =============================================================================
-- Seed: "Clothing" subcategory (under existing "Hygiene & Wudu" category)
--        + 4 adhkars.
--
-- Source: user-provided translation sheet (clothes_adhkar_translations.csv).
-- The "Hygiene & Wudu" category is created by 20260615000000; here we only
-- resolve it by title.
--
-- Localization mirrors 20260615000000_seed_wudu_purification_adhkar.sql:
--   * arabic_text      – exact source text
--   * translation_*    – en, fr, de, nl, tr, id, ur, bn, ms, ru (from the sheet)
--   * transcription_*  – Latin transliteration in VALUES; fanned out to every
--                        Latin-script column (step 4b) + dedicated ur/bn/ru
--                        native-script transcription (step 4d, keyed on the
--                        unique transcription_en)
--   * when_*           – per-adhkar context phrase, localised to every language
--   * reference_*      – en/fr/ar in VALUES; de/nl/tr/id/ms via step 4c and
--                        ur/bn/ru via step 4d
--
-- Source-sheet fixes applied: Malay #1 ("With nama" -> "Dengan nama"),
-- French #3 (Indonesian "telah" leak -> "a été"), Dutch #3 ("pack" -> "en").
--
-- Idempotent: subcategory inserted if missing; adhkars inserted only when the
-- subcategory has none yet.
--
-- REVIEW NOTE: hadith references and the ur/bn/ru phonetic transcriptions were
-- not part of the source sheet — they follow the standard Hisnul-Muslim
-- attributions and should be reviewed by a qualified native speaker before
-- production use.
-- =============================================================================

-- ── Subcategory: Clothing ────────────────────────────────────────────────────
-- No recommended time window (said whenever dressing/undressing).
insert into public.adhkar_subcategories
  (adhkar_category_id, title_en, title_fr, title_ar, title_de, title_nl, title_tr,
   title_id, title_ur, title_bn, title_ms, title_ru, position)
select
  c.id, 'Clothing', 'Vêtements', 'اللباس', 'Kleidung', 'Kleding', 'Giyim',
  'Pakaian', 'لباس', 'পোশাক', 'Pakaian', 'Одежда', 2
from public.adhkar_categories c
where c.title_en = 'Hygiene & Wudu'
  and not exists (
    select 1 from public.adhkar_subcategories s
    where s.title_en = 'Clothing' and s.adhkar_category_id = c.id
  );

-- ── Adhkars ──────────────────────────────────────────────────────────────────
insert into public.adhkars (
  adhkar_subcategory_id,
  arabic_text,
  transcription_en,
  translation_en, translation_fr, translation_de, translation_nl, translation_tr,
  translation_id, translation_ur, translation_bn, translation_ms, translation_ru,
  when_en, when_fr, when_ar, when_de, when_nl, when_tr, when_id, when_ms, when_ur,
  when_bn, when_ru,
  reference_en, reference_fr, reference_ar,
  min_count, ajr
)
select s.id, v.*
from public.adhkar_subcategories s
cross join (
  values
  -- ═══════════════════════════ 1. Before removing clothes ═══════════════════
  (
    'بِسْمِ اللّٰهِ',
    'Bismi-llāh.',
    'In the Name of Allah.',
    'Au nom d''Allah.',
    'Im Namen Allahs.',
    'In de naam van Allah.',
    'Allah''ın adıyla.',
    'Dengan nama Allah.',
    'اللہ کے نام کے ساتھ۔',
    'আল্লাহর নামে।',
    'Dengan nama Allah.',
    'С именем Аллаха.',
    'Before removing clothes', 'Avant d''ôter ses vêtements', 'قبل خلع الثوب',
    'Vor dem Ausziehen der Kleidung', 'Voor het uittrekken van kleding',
    'Elbiseyi çıkarmadan önce', 'Sebelum melepas pakaian',
    'Sebelum menanggalkan pakaian', 'کپڑے اتارنے سے پہلے',
    'পোশাক খোলার আগে', 'Перед снятием одежды',
    'Tirmidhī 606', 'Tirmidhī 606', 'سنن الترمذي ٦٠٦',
    1::smallint, 5::smallint
  ),
  -- ════════════════════════════ 2. After wearing clothes ════════════════════
  (
    'اَلْحَمْدُ لِلّٰهِ الَّذِيْ كَسَانِيْ هٰذَا الثَّوْبَ ، وَرَزَقَنِيْهِ مِنْ غَيْرِ حَوْلٍ مِّنِّيْ وَلَا قُوَّةٍ.',
    'Alḥamdu li-llāhi-l-ladhī kasānī hādha-th-thawba, wa razaqanīhi min ghayri ḥawlin minnī wa lā quwwah.',
    'All praise is for Allah who has clothed me with this garment and provided it for me, without any power or might from me.',
    'Louange à Allah qui m''a vêtu de ce vêtement et me l''a accordé sans aucune force ni puissance de ma part.',
    'Alles Lob gebührt Allah, Der mich mit diesem Gewand gekleidet und es mir gegeben hat, ohne Kraft und Macht von mir.',
    'Alle lof toekomt aan Allah, Die mij met dit gewaad heeft gekleed en het mij heeft geschonken, zonder kracht of macht van mijzelf.',
    'Bana bu elbiseyi giydiren ve kendim hiçbir güç ve kuvvet harcamaksızın beni bununla rızıklandıran Allah''a hamdolsun.',
    'Segala puji bagi Allah yang telah memakaikan pakaian ini kepadaku dan menganugerahkannya kepadaku tanpa daya dan kekuatan dariku.',
    'تمام تعریفیں اللہ کے لیے ہیں جس نے مجھے یہ کپڑا پہنایا اور میری کسی طاقت اور قوت کے بغیر مجھے یہ عطا فرمایا۔',
    'সমস্ত প্রশংসা আল্লাহর জন্য, যিনি আমাকে এই পোশাকটি পরিধান করিয়েছেন এবং আমার কোনো চেষ্টা ও সামর্থ্য ছাড়াই আমাকে এটি দান করেছেন।',
    'Segala puji bagi Allah yang telah memakaikan pakaian ini kepadaku dan mengurniakannya kepadaku tanpa sebarang daya dan kekuatan daripadaku.',
    'Хвала Аллаху, Который одел меня в эту одежду и даровал мне её, тогда как сам я не обладаю ни силой, ни могуществом.',
    'After putting on clothes', 'Après avoir mis ses vêtements', 'عند لبس الثوب',
    'Nach dem Anziehen der Kleidung', 'Na het aantrekken van kleding',
    'Elbise giydikten sonra', 'Setelah mengenakan pakaian',
    'Selepas memakai pakaian', 'کپڑے پہننے کے بعد',
    'পোশাক পরিধানের পর', 'После надевания одежды',
    'Abū Dāwūd 4023', 'Abū Dāwūd 4023', 'سنن أبي داود ٤٠٢٣',
    1::smallint, 5::smallint
  ),
  -- ══════════════════════════ 3. When wearing new clothes ═══════════════════
  (
    'اَللّٰهُمَّ لَكَ الْحَمْدُ أَنْتَ كَسَوْتَنِيْهِ ، أَسْأَلُكَ مِنْ خَيْرِهِ وَخَيْرِ مَا صُنِعَ لَهُ ، وَأَعُوذُ بِكَ مِنْ شَرِّهِ وَشَرِّ مَا صُنِعَ لَهُ.',
    'Allāhumma laka-l-ḥamdu anta kasawtanīhi, as''aluka min khayrihi wa khayri mā ṣuniʿa lah, wa aʿūdhu bika min sharrihi wa sharri mā ṣuniʿa lah.',
    'O Allah, all praise is for You Alone — You have clothed me with it. I ask You for its good and the good of that for which it was made; and I seek Your protection from its evil and the evil of that for which it was made.',
    'Ô Allah, à Toi la louange, c''est Toi qui m''en as vêtu. Je Te demande son bien et le bien pour lequel il a été conçu, et je cherche Ta protection contre son mal et le mal pour lequel il a été conçu.',
    'O Allah, Dir gebührt das Lob, Du hast mich damit gekleidet. Ich bitte Dich um das Gute daran und das Gute, wofür es gemacht wurde, und ich suche Zuflucht bei Dir vor dem Bösen daran und dem Bösen, wofür es gemacht wurde.',
    'O Allah, aan U behoort alle lof, U heeft mij ermee gekleed. Ik vraag U om het goede ervan en het goede waarvoor het gemaakt is, en ik zoek bescherming bij U tegen het slechte ervan en het slechte waarvoor het gemaakt is.',
    'Allah''ım! Hamd Sana mahsustur, bunu bana Sen giydirdin. Senden bunun hayrını ve yapılış gayesinin hayrını dilerim. Onun şerrinden ve yapılış gayesinin şerrinden de Sana sığınırım.',
    'Ya Allah, bagi-Mu segala puji, Engkau yang telah memakaikannya kepadaku. Aku memohon kepada-Mu kebaikannya dan kebaikan sesuatu yang ia dibuat untuknya, dan aku berlindung kepada-Mu dari keburukannya dan keburukan sesuatu yang ia dibuat untuknya.',
    'اے اللہ! تیرے ہی لیے تمام تعریف ہے، تو نے ہی مجھے یہ پہنایا ہے۔ میں تجھ سے اس کی خیر اور اس چیز کی خیر کا سوال کرتا ہوں جس کے لیے یہ بنایا گیا ہے، اور میں اس کے شر اور اس چیز کے شر سے تیری پناہ مانگتا ہوں جس کے لیے یہ بنایا گیا ہے۔',
    'হে আল্লাহ! সমস্ত প্রশংসা আপনারই, আপনিই আমাকে এটি পরিধান করিয়েছেন। আমি আপনার কাছে এর কল্যাণ ও এটি যে উদ্দেশ্যে তৈরি করা হয়েছে তার কল্যাণ প্রার্থনা করছি; এবং এর অনিষ্ট ও এটি যে উদ্দেশ্যে তৈরি করা হয়েছে তার অনিষ্ট থেকে আপনার আশ্রয় চাচ্ছি।',
    'Ya Allah, bagi-Mu segala puji, Engkau yang telah memakaikannya kepadaku. Aku memohon kepada-Mu kebaikannya dan kebaikan apa yang dibuat untuknya, dan aku berlindung kepada-Mu daripada keburukannya dan keburukan apa yang dibuat untuknya.',
    'О Аллах, Тебе хвала! Ты одел меня в это. Я прошу Тебя о его благе и благе того, для чего оно было создано, и прибегаю к Тебе от его зла и зла того, для чего оно было создано.',
    'When wearing new clothes', 'En portant de nouveaux vêtements', 'عند لبس الثوب الجديد',
    'Beim Tragen neuer Kleidung', 'Bij het dragen van nieuwe kleding',
    'Yeni elbise giyerken', 'Ketika mengenakan pakaian baru',
    'Ketika memakai pakaian baharu', 'نیا کپڑا پہنتے وقت',
    'নতুন পোশাক পরিধানের সময়', 'При надевании новой одежды',
    'Abū Dāwūd 4020', 'Abū Dāwūd 4020', 'سنن أبي داود ٤٠٢٠',
    1::smallint, 5::smallint
  ),
  -- ════════════════ 4. To be said to someone wearing new clothes ════════════
  (
    'تُبْلِيْ وَيُخْلِفُ اللّٰهُ تَعَالَىٰ.',
    'Tubli wa yukhliful-lāhu taʿālā.',
    'May you wear it out and may Allah replace it (with another).',
    'Puisse-tu le porter jusqu''à l''user, et qu''Allah le Très-Haut te le remplace.',
    'Mögest du es abtragen und möge Allah, der Erhabene, es ersetzen.',
    'Moge je het verslijten en moge Allah de Verhevene het vervangen.',
    'Eskitirsin, Allah Teâlâ da yerine yenisini verir inşallah.',
    'Semoga engkau memakainya sampai usang, dan semoga Allah Yang Maha Tinggi menggantinya dengan yang baru.',
    'تم اسے پرانا کرو اور اللہ تعالیٰ اس کا نعم البدل عطا فرمائے۔',
    'তুমি এটি পুরোনো করো এবং আল্লাহ তাআলা এর স্থলাভিষিক্ত (নতুন পোশাক) দান করুন।',
    'Semoga engkau memakainya sehingga buruk, dan semoga Allah Taala menggantikannya dengan yang lain.',
    'Носи до износа, и пусть Аллах Всевышний заменит её тебе (другой).',
    'Said to someone wearing new clothes',
    'À dire à quelqu''un qui porte de nouveaux vêtements', 'يُقال لمن لبس ثوبًا جديدًا',
    'Zu jemandem gesagt, der neue Kleidung trägt', 'Gezegd tegen iemand die nieuwe kleding draagt',
    'Yeni elbise giyen birine söylenir', 'Diucapkan kepada orang yang mengenakan pakaian baru',
    'Diucapkan kepada orang yang memakai pakaian baharu', 'نیا کپڑا پہننے والے کو کہا جائے',
    'নতুন পোশাক পরিহিত ব্যক্তিকে বলা হয়', 'Говорится тому, кто надел новую одежду',
    'Abū Dāwūd 4020 (Umm Khālid)', 'Abū Dāwūd 4020 (Umm Khālid)', 'سنن أبي داود ٤٠٢٠ (أم خالد)',
    1::smallint, 5::smallint
  )
) as v(
  arabic_text,
  transcription_en,
  translation_en, translation_fr, translation_de, translation_nl, translation_tr,
  translation_id, translation_ur, translation_bn, translation_ms, translation_ru,
  when_en, when_fr, when_ar, when_de, when_nl, when_tr, when_id, when_ms, when_ur,
  when_bn, when_ru,
  reference_en, reference_fr, reference_ar,
  min_count, ajr
)
where s.title_en = 'Clothing'
  and not exists (
    select 1 from public.adhkars a where a.adhkar_subcategory_id = s.id
  );

-- ── Step 4: language fan-out (transliteration + references) ───────────────────

-- 4b) Transliteration is language-neutral Latin, reused for every Latin-script
-- language column.
update public.adhkars a
set
  transcription_fr = a.transcription_en,
  transcription_de = a.transcription_en,
  transcription_nl = a.transcription_en,
  transcription_tr = a.transcription_en,
  transcription_id = a.transcription_en,
  transcription_ms = a.transcription_en
from public.adhkar_subcategories s
where a.adhkar_subcategory_id = s.id
  and s.title_en = 'Clothing';

-- 4c) Reference for Latin-script languages: collection names stay romanised.
update public.adhkars a
set
  reference_de = a.reference_en,
  reference_nl = a.reference_en,
  reference_tr = a.reference_en,
  reference_id = a.reference_en,
  reference_ms = a.reference_en
from public.adhkar_subcategories s
where a.adhkar_subcategory_id = s.id
  and s.title_en = 'Clothing';

-- 4d) Native-script transliteration + reference for ur / bn / ru, keyed by the
-- (unique) Latin transcription of each adhkar (references are not unique here:
-- #3 and #4 both cite Abū Dāwūd 4020).
update public.adhkars a
set
  transcription_ur = m.t_ur,
  transcription_bn = m.t_bn,
  transcription_ru = m.t_ru,
  reference_ur = m.r_ur,
  reference_bn = m.r_bn,
  reference_ru = m.r_ru
from public.adhkar_subcategories s,
(values
  -- 1. Before removing clothes
  ('Bismi-llāh.',
   'بِسْمِ اللہ۔',
   'বিসমিল্লাহ।',
   'Бисми-Ллях.',
   'ترمذی 606', 'তিরমিযী 606', 'ат-Тирмизи 606'),
  -- 2. After wearing clothes
  ('Alḥamdu li-llāhi-l-ladhī kasānī hādha-th-thawba, wa razaqanīhi min ghayri ḥawlin minnī wa lā quwwah.',
   'اَلْحَمْدُ لِلہِ الَّذِیْ کَسَانِیْ ھٰذَا الثَّوْبَ، وَرَزَقَنِیْہِ مِنْ غَیْرِ حَوْلٍ مِّنِّیْ وَلَا قُوَّۃ۔',
   'আলহামদু লিল্লাহিল্লাযী কাসানী হাযাছ ছাওবা, ওয়া রাযাকানীহি মিন গাইরি হাওলিম মিন্নী ওয়ালা কুওয়াহ।',
   'Аль-хамду ли-Лляхи-ллязи касани хаза-с-сауба, ва разаканихи мин гайри хаулин минни ва ля кувва.',
   'ابو داؤد 4023', 'আবু দাউদ 4023', 'Абу Дауд 4023'),
  -- 3. When wearing new clothes
  ('Allāhumma laka-l-ḥamdu anta kasawtanīhi, as''aluka min khayrihi wa khayri mā ṣuniʿa lah, wa aʿūdhu bika min sharrihi wa sharri mā ṣuniʿa lah.',
   'اَللّٰھُمَّ لَکَ الْحَمْدُ اَنْتَ کَسَوْتَنِیْہِ، اَسْاَلُکَ مِنْ خَیْرِہٖ وَخَیْرِ مَا صُنِعَ لَہٗ، وَاَعُوْذُ بِکَ مِنْ شَرِّہٖ وَشَرِّ مَا صُنِعَ لَہٗ۔',
   'আল্লাহুম্মা লাকাল হামদু আনতা কাসাওতানীহি, আসআলুকা মিন খাইরিহী ওয়া খাইরি মা সুনিআ লাহ, ওয়া আঊযু বিকা মিন শাররিহী ওয়া শাররি মা সুনিআ লাহ।',
   'Аллахумма ляка-ль-хамду анта касавтанихи, ас’алюка мин хайрихи ва хайри ма сунинъа лях, ва а’узу бика мин шаррихи ва шарри ма сунинъа лях.',
   'ابو داؤد 4020', 'আবু দাউদ 4020', 'Абу Дауд 4020'),
  -- 4. To be said to someone wearing new clothes
  ('Tubli wa yukhliful-lāhu taʿālā.',
   'تُبْلِیْ وَیُخْلِفُ اللہُ تَعَالٰی۔',
   'তুবলী ওয়া ইউখলিফুল্লাহু তাআলা।',
   'Тубли ва юхлифу-Ллаху та’аля.',
   'ابو داؤد 4020 (ام خالد)', 'আবু দাউদ 4020 (উম্মে খালিদ)', 'Абу Дауд 4020 (Умм Халид)')
) as m(tr_key, t_ur, t_bn, t_ru, r_ur, r_bn, r_ru)
where a.adhkar_subcategory_id = s.id
  and s.title_en = 'Clothing'
  and a.transcription_en = m.tr_key;
