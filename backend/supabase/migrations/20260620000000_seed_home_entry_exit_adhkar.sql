-- =============================================================================
-- Seed: "Entering & leaving home" subcategory (under existing "In daily life"
--        category) + 3 adhkars.
--
-- Source: user-provided translation sheet
--   (home_entrance_exit_adhkar_translations.csv).
-- The "In daily life" category is created by 20260619000000; here we only
-- resolve it by title.
--
-- Localization mirrors 20260619000000:
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
-- Source-sheet fix applied: Dutch "When Entering the Home" stray word removed
-- ("naar buiten, hinges en op Allah" -> "naar buiten, en op Allah").
--
-- Idempotent: subcategory inserted if missing; adhkars inserted only when the
-- subcategory has none yet.
--
-- REVIEW NOTE: hadith references and the ur/bn/ru phonetic transcriptions were
-- not part of the source sheet — they follow the standard Hisnul-Muslim
-- attributions and should be reviewed by a qualified native speaker before
-- production use.
-- =============================================================================

-- ── Subcategory: Entering & leaving home ─────────────────────────────────────
insert into public.adhkar_subcategories
  (adhkar_category_id, title_en, title_fr, title_ar, title_de, title_nl, title_tr,
   title_id, title_ur, title_bn, title_ms, title_ru, position)
select
  c.id, 'Entering & leaving home', 'Entrer et sortir de la maison', 'دخول المنزل والخروج منه',
  'Betreten & Verlassen des Hauses', 'Het huis betreden & verlaten', 'Eve girmek & çıkmak',
  'Masuk & keluar rumah', 'گھر میں داخلہ اور خروج', 'ঘরে প্রবেশ ও বের হওয়া',
  'Masuk & keluar rumah', 'Вход и выход из дома', 2
from public.adhkar_categories c
where c.title_en = 'In daily life'
  and not exists (
    select 1 from public.adhkar_subcategories s
    where s.title_en = 'Entering & leaving home' and s.adhkar_category_id = c.id
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
  -- ═══════════════════════════ 1. When leaving the home #1 ══════════════════
  (
    'بِسْمِ اللّٰهِ تَوَكَّلْتُ عَلَى اللّٰهِ ، لَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللّٰهِ.',
    'Bismi-llāhi tawakkaltu ʿala-llāh, lā ḥawla wa lā quwwata illā bi-llāh.',
    'In the Name of Allah, I have placed my trust in Allah. There is no power (in averting evil) or strength (in attaining good) except through Allah.',
    'Au nom d''Allah, je place ma confiance en Allah. Il n''y a de force ni de puissance que par Allah.',
    'Im Namen Allahs, ich vertraue auf Allah. Es gibt keine Macht noch Kraft außer durch Allah.',
    'In de naam van Allah, ik stel mijn vertrouwen in Allah. Er is geen macht of kracht behalve door Allah.',
    'Allah''ın adıyla, Allah''a tevekkül ettim. Güç ve kuvvet ancak Allah''ın yardımıyladır.',
    'Dengan nama Allah, aku bertawakal kepada Allah. Tidak ada daya dan kekuatan kecuali dengan pertolongan Allah.',
    'اللہ کے نام کے ساتھ، میں نے اللہ پر توکل کیا، اللہ کی مدد کے بغیر نہ گناہوں سے بچنے کی طاقت ہے اور نہ نیکی کرنے کی قوت۔',
    'আল্লাহর নামে, আমি আল্লাহর ওপর ভরসা করলাম। আল্লাহর সাহায্য ছাড়া (পাপ থেকে) ফিরে থাকার কোনো উপায় নেই এবং (পুণ্য কাজ করার) কোনো শক্তি নেই।',
    'Dengan nama Allah, aku bertawakal kepada Allah. Tiada daya dan kekuatan melainkan dengan pertolongan Allah.',
    'С именем Аллаха, я уповаю на Аллаха. Нет мощи и силы ни у кого, кроме Аллаха.',
    'When leaving the home', 'En quittant la maison', 'عند الخروج من المنزل',
    'Beim Verlassen des Hauses', 'Bij het verlaten van het huis', 'Evden çıkarken',
    'Ketika keluar rumah', 'Ketika keluar rumah', 'گھر سے نکلتے وقت',
    'ঘর থেকে বের হওয়ার সময়', 'При выходе из дома',
    'Abū Dāwūd 5095', 'Abū Dāwūd 5095', 'سنن أبي داود ٥٠٩٥',
    1::smallint, 5::smallint
  ),
  -- ═══════════════════════════ 2. When leaving the home #2 ══════════════════
  (
    'اَللّٰهُمَّ إِنِّيْ أَعُوْذُ بِكَ أَنْ أَضِلَّ أَوْ أُضَلَّ ، أَوْ أَزِلَّ أَوْ أُزَلَّ ، أَوْ أَظْلِمَ أَوْ أُظْلَمَ ، أَوْ أَجْهَلَ أَوْ يُجْهَلَ عَلَيَّ.',
    'Allāhumma innī aʿūdhu bika an aḍilla aw uḍalla, aw azilla aw uzalla, aw aẓlima aw uẓlama, aw ajhala aw yujhala ʿalayya.',
    'O Allah, I seek Your protection from misguiding others or being misguided; from erring or others causing me to err; from oppressing others or being oppressed; and from acting ignorantly or others acting ignorantly towards me.',
    'Ô Allah, je cherche Ta protection contre le fait d''égarer autrui ou d''être égaré, de commettre une faute ou qu''on me la fasse commettre, d''opprimer ou d''être opprimé, d''agir avec ignorance ou qu''on agisse avec ignorance envers moi.',
    'O Allah, ich suche Zuflucht bei Dir davor, andere in die Irre zu führen oder selbst irregeführt zu werden; Fehler zu begehen oder dazu verleitet zu werden; Unrecht zu tun oder Unrecht zu erleiden; oder unwissend zu handeln oder dass man mir gegenüber unwissend handelt.',
    'O Allah, ik zoek Uw bescherming tegen het misleiden van anderen of misleid te worden; tegen het dwalen of door anderen tot dwalen te worden gebracht; tegen het onderdrukken of onderdrukt te worden; en tegen het onwetend handelen of dat men onwetend tegenover mij handelt.',
    'Allah''ım! Sapmaktan veya saptırılmaktan, hataya düşmekten veya hataya düşürülmekten, zulmetmekten veya zulme uğramaktan, cahillik etmekten veya bana karşı cahillik edilmesinden Sana sığınırım.',
    'Ya Allah, sesungguhnya aku berlindung kepada-Mu dari menyesatkan atau disesatkan, menggelincirkan atau digelincirkan, menganiaya atau dianiaya, dan berbuat bodoh atau diperlakukan bodoh.',
    'اے اللہ! میں تیری پناہ مانگتا ہوں اس بات سے کہ میں گمراہ ہو جاؤں یا گمراہ کر دیا جاؤں، یا میں پھسل جاؤں یا مجھے پھسلا دیا جائے، یا میں ظلم کروں یا مجھ پر ظلم کیا جائے، یا میں جاہلانہ کام کروں یا میرے ساتھ جاہلانہ سلوک کیا جائے۔',
    'হে আল্লাহ! আমি আপনার কাছে আশ্রয় চাচ্ছি যেন আমি পথভ্রষ্ট না হই অথবা পথভ্রষ্ট করা না হই; চ্যুত না হই অথবা চ্যুত করা না হই; অত্যাচার না করি অথবা অত্যাচারিত না হই; অজ্ঞতা প্রকাশ না করি অথবা আমার সাথে অজ্ঞতাসুলভ আচরণ না করা হয়।',
    'Ya Allah, sesungguhnya aku berlindung kepada-Mu daripada menyesatkan atau disesatkan, menggelincirkan atau digelincirkan, menganiaya atau dianiaya, dan berbuat jahil atau diperlakukan jahil ke atas diriku.',
    'О Аллах, поистине, я прибегаю к Тебе от того, чтобы сбиться с пути или быть сбитым с него, от того, чтобы допустить ошибку или быть понуждаемым к ней, от того, чтобы поступать несправедливо или быть несправедливо обиженным, и от того, чтобы поступать невежественно или быть в невежестве относительно меня.',
    'When leaving the home', 'En quittant la maison', 'عند الخروج من المنزل',
    'Beim Verlassen des Hauses', 'Bij het verlaten van het huis', 'Evden çıkarken',
    'Ketika keluar rumah', 'Ketika keluar rumah', 'گھر سے نکلتے وقت',
    'ঘর থেকে বের হওয়ার সময়', 'При выходе из дома',
    'Abū Dāwūd 5094', 'Abū Dāwūd 5094', 'سنن أبي داود ٥٠٩٤',
    1::smallint, 5::smallint
  ),
  -- ═══════════════════════════ 3. When entering the home ════════════════════
  (
    'اَللّٰهُمَّ إِنِّيْ أَسْأَلُكَ خَيْرَ الْمَوْلَجِ ، وَخَيْرَ الْمَخْرَجِ ، بِسْمِ اللّٰهِ وَلَجْنَا ، وَبِسْمِ اللّٰهِ خَرَجْنَا ، وَعَلَى اللّٰهِ رَبِّنَا تَوَكَّلْنَا.',
    'Allāhumma innī as''aluka khayra-l-mawlaji wa khayra-l-makhraj, bismi-llāhi walajnā, wa bismi-llāhi kharajnā, wa ʿala-llāhi Rabbinā tawakkalnā.',
    'O Allah, I ask You for the best entrance and the best exit. In the Name of Allah we enter, in the Name of Allah we leave, and in Allah our Lord do we trust.',
    'Ô Allah, je Te demande la meilleure entrée et la meilleure sortie. Au nom d''Allah nous entrons, au nom d''Allah nous sortons, et en Allah notre Seigneur nous plaçons notre confiance.',
    'O Allah, ich bitte Dich um den besten Eintritt und den besten Ausgang. Im Namen Allahs treten wir ein, im Namen Allahs gehen wir hinaus, und auf Allah, unseren Herrn, vertrauen wir.',
    'O Allah, ik vraag U om de beste binnenkomst en de beste uitgang. In de naam van Allah gaan we naar binnen, in de naam van Allah gaan we naar buiten, en op Allah onze Heer vertrouwen wij.',
    'Allah''ım! Senden girişin de çıkışın da hayırlısını isterim. Allah''ın adıyla girdik, Allah''ın adıyla çıktık ve Rabbimiz Allah''a tevekkül ettik.',
    'Ya Allah, sesungguhnya aku memohon kepada-Mu kebaikan tempat masuk dan kebaikan tempat keluar. Dengan nama Allah kami masuk, dengan nama Allah kami keluar, dan kepada Allah Tuhan kami, kami bertawakal.',
    'اے اللہ! میں تجھ سے بہترین داخل ہونے اور بہترین نکلنے کا سوال کرتا ہوں۔ اللہ کے نام کے ساتھ ہم داخل ہوئے اور اللہ ہی کے نام کے ساتھ ہم نکلے، اور اپنے رب اللہ ہی پر ہم نے توکل کیا۔',
    'হে আল্লাহ! আমি আপনার কাছে উত্তম প্রবেশ এবং উত্তম বহির্গমন প্রার্থনা করছি। আল্লাহর নামে আমরা প্রবেশ করলাম, আল্লাহর নামে আমরা বের হলাম এবং আমাদের প্রতিপালক আল্লাহর ওপরই আমরা ভরসা করলাম।',
    'Ya Allah, sesungguhnya aku memohon kepada-Mu kebaikan tempat masuk dan kebaikan tempat keluar. Dengan nama Allah kami masuk, dengan nama Allah kami keluar, dan kepada Allah Tuhan kami, kami bertawakal.',
    'О Аллах, поистине, я прошу Тебя о благом входе и благом выходе. С именем Аллаха мы вошли, с именем Аллаха мы вышли и на Аллаха, Господа нашего, уповаем.',
    'When entering the home', 'En entrant dans la maison', 'عند دخول المنزل',
    'Beim Betreten des Hauses', 'Bij het betreden van het huis', 'Eve girerken',
    'Ketika masuk rumah', 'Ketika masuk rumah', 'گھر میں داخل ہوتے وقت',
    'ঘরে প্রবেশের সময়', 'При входе в дом',
    'Abū Dāwūd 5096', 'Abū Dāwūd 5096', 'سنن أبي داود ٥٠٩٦',
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
where s.title_en = 'Entering & leaving home'
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
  and s.title_en = 'Entering & leaving home';

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
  and s.title_en = 'Entering & leaving home';

-- 4d) Native-script transliteration + reference for ur / bn / ru, keyed by the
-- (unique) Latin transcription of each adhkar.
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
  -- 1. When leaving the home #1
  ('Bismi-llāhi tawakkaltu ʿala-llāh, lā ḥawla wa lā quwwata illā bi-llāh.',
   'بِسْمِ اللہِ تَوَکَّلْتُ عَلَی اللہِ، لَا حَوْلَ وَلَا قُوَّۃَ اِلَّا بِاللہِ۔',
   'বিসমিল্লাহি তাওয়াক্কালতু আলাল্লাহ, লা হাওলা ওয়ালা কুওয়াতা ইল্লা বিল্লাহ।',
   'Бисми-Лляхи таваккальту ’аля-Ллах, ля хауля ва ля куввата илля би-Ллях.',
   'ابو داؤد 5095', 'আবু দাউদ 5095', 'Абу Дауд 5095'),
  -- 2. When leaving the home #2
  ('Allāhumma innī aʿūdhu bika an aḍilla aw uḍalla, aw azilla aw uzalla, aw aẓlima aw uẓlama, aw ajhala aw yujhala ʿalayya.',
   'اَللّٰھُمَّ اِنِّیْ اَعُوْذُ بِکَ اَنْ اَضِلَّ اَوْ اُضَلَّ، اَوْ اَزِلَّ اَوْ اُزَلَّ، اَوْ اَظْلِمَ اَوْ اُظْلَمَ، اَوْ اَجْھَلَ اَوْ یُجْھَلَ عَلَیَّ۔',
   'আল্লাহুম্মা ইন্নী আঊযু বিকা আন আদিল্লা আও উদাল্লা, আও আযিল্লা আও উযাল্লা, আও আযলিমা আও উযলামা, আও আজহালা আও ইউজহালা আলাইয়া।',
   'Аллахумма инни а’узу бика ан адылля ау удалля, ау азилля ау узалля, ау азлима ау узляма, ау аджхаля ау юджхаля ’аляйя.',
   'ابو داؤد 5094', 'আবু দাউদ 5094', 'Абу Дауд 5094'),
  -- 3. When entering the home
  ('Allāhumma innī as''aluka khayra-l-mawlaji wa khayra-l-makhraj, bismi-llāhi walajnā, wa bismi-llāhi kharajnā, wa ʿala-llāhi Rabbinā tawakkalnā.',
   'اَللّٰھُمَّ اِنِّیْ اَسْاَلُکَ خَیْرَ الْمَوْلَجِ، وَخَیْرَ الْمَخْرَجِ، بِسْمِ اللہِ وَلَجْنَا، وَبِسْمِ اللہِ خَرَجْنَا، وَعَلَی اللہِ رَبِّنَا تَوَکَّلْنَا۔',
   'আল্লাহুম্মা ইন্নী আসআলুকা খাইরাল মাওলাজি, ওয়া খাইরাল মাখরাজি, বিসমিল্লাহি ওয়ালাজনা, ওয়া বিসমিল্লাহি খারাজনা, ওয়া আলাল্লাহি রাব্বিনা তাওয়াক্কালনা।',
   'Аллахумма инни ас’алюка хайра-ль-мавляджи, ва хайра-ль-махраджи, бисми-Лляхи валяджна, ва бисми-Лляхи хараджна, ва ’аля-Ллахи Раббина таваккальна.',
   'ابو داؤد 5096', 'আবু দাউদ 5096', 'Абу Дауд 5096')
) as m(tr_key, t_ur, t_bn, t_ru, r_ur, r_bn, r_ru)
where a.adhkar_subcategory_id = s.id
  and s.title_en = 'Entering & leaving home'
  and a.transcription_en = m.tr_key;
