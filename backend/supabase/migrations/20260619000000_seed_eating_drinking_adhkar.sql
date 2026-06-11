-- =============================================================================
-- Seed: "In daily life" category -> "Eating & drinking" subcategory + 15 adhkars.
--
-- Source: user-provided translation sheet
--   (eating_hosting_fasting_adhkar_translations.csv). All 15 entries (eating /
-- drinking, du'a for the host, and breaking-the-fast) are placed in a single
-- "Eating & drinking" subcategory per request.
--
-- Localization mirrors 20260618000000:
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
-- Source-sheet fix applied: Indonesian & Malay host du'a #1 ("orang-orang yang
-- bak" -> "orang-orang yang baik").
--
-- Reference left NULL: "After Eating #5" (Allāhumma aṭʿamta wa asqayta…) — no
-- confident single-source attribution; do not assume a hadith number.
--
-- Idempotent: category / subcategory inserted only if missing; adhkars inserted
-- only when the subcategory has none yet.
--
-- REVIEW NOTE: hadith references and the ur/bn/ru phonetic transcriptions were
-- not part of the source sheet — they follow the standard Hisnul-Muslim
-- attributions and should be reviewed by a qualified native speaker before
-- production use.
-- =============================================================================

-- ── 1) Category: In daily life ───────────────────────────────────────────────
insert into public.adhkar_categories
  (title_en, title_fr, title_ar, title_de, title_nl, title_tr, title_id, title_ur, title_bn, title_ms, title_ru, position)
select
  'In daily life', 'Dans la vie quotidienne', 'في الحياة اليومية', 'Im täglichen Leben',
  'In het dagelijks leven', 'Günlük hayatta', 'Dalam kehidupan sehari-hari', 'روزمرہ زندگی میں',
  'দৈনন্দিন জীবনে', 'Dalam kehidupan seharian', 'В повседневной жизни', 4
where not exists (
  select 1 from public.adhkar_categories where title_en = 'In daily life'
);

-- ── 2) Subcategory: Eating & drinking ────────────────────────────────────────
insert into public.adhkar_subcategories
  (adhkar_category_id, title_en, title_fr, title_ar, title_de, title_nl, title_tr,
   title_id, title_ur, title_bn, title_ms, title_ru, position)
select
  c.id, 'Eating & drinking', 'Manger et boire', 'الأكل والشرب', 'Essen & Trinken',
  'Eten & drinken', 'Yeme & İçme', 'Makan & minum', 'کھانا اور پینا',
  'খাওয়া ও পান করা', 'Makan & minum', 'Еда и питьё', 1
from public.adhkar_categories c
where c.title_en = 'In daily life'
  and not exists (
    select 1 from public.adhkar_subcategories s
    where s.title_en = 'Eating & drinking' and s.adhkar_category_id = c.id
  );

-- ── 3) Adhkars ───────────────────────────────────────────────────────────────
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
  -- ═══════════════════════════════ 1. Before eating #1 ══════════════════════
  (
    'بِسْمِ اللّٰهِ.',
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
    'Before eating', 'Avant de manger', 'قبل الطعام',
    'Vor dem Essen', 'Voor het eten', 'Yemekten önce', 'Sebelum makan', 'Sebelum makan',
    'کھانے سے پہلے', 'খাওয়ার আগে', 'Перед едой',
    'Bukhārī 5376', 'Bukhārī 5376', 'صحيح البخاري ٥٣٧٦',
    1::smallint, 5::smallint
  ),
  -- ═══════════════════════════════ 2. Before eating #2 ══════════════════════
  (
    'اَللّٰهُمَّ بَارِكْ لَنَا فِيْهِ وَأَطْعِمْنَا خَيْراً مِنْهُ.',
    'Allāhumma bārik lanā fīhi wa aṭʿimnā khayran minhu.',
    'O Allah, bless us in it and feed us that which is better than it.',
    'Ô Allah, bénis-nous en cela et nourris-nous de quelque chose de meilleur.',
    'O Allah, segne uns darin und speise uns mit etwas Besserem als diesem.',
    'O Allah, zegen ons erin en voed ons met iets beters dan dit.',
    'Allah''ım! Bize bunu mübarek kıl ve bize bundan daha hayırlısını yedir.',
    'Ya Allah, berkahilah kami di dalam makanan ini dan berilah kami makanan yang lebih baik darinya.',
    'اے اللہ! ہمارے لیے اس میں برکت عطا فرما اور ہمیں اس سے بہتر کھلا۔',
    'হে আল্লাহ! আপনি আমাদের জন্য এতে বরকত দিন এবং আমাদের এর চেয়ে উত্তম আহার দান করুন।',
    'Ya Allah, berkahilah kami di dalam makanan ini dan berilah kami makanan yang lebih baik daripadanya.',
    'О Аллах, благослови нас в этом и накорми нас тем, что лучше этого.',
    'Before eating', 'Avant de manger', 'قبل الطعام',
    'Vor dem Essen', 'Voor het eten', 'Yemekten önce', 'Sebelum makan', 'Sebelum makan',
    'کھانے سے پہلے', 'খাওয়ার আগে', 'Перед едой',
    'Tirmidhī 3455', 'Tirmidhī 3455', 'سنن الترمذي ٣٤٥٥',
    1::smallint, 5::smallint
  ),
  -- ═══════════════════ 3. If one forgets Bismillah at the start ═════════════
  (
    'بِسْمِ اللّٰهِ أَوَّلَهُ وَآخِرَهُ.',
    'Bismi-llāhi awwalahu wa ākhirahu.',
    'In the Name of Allah at the beginning and at the end of it.',
    'Au nom d''Allah, au début et à la fin.',
    'Im Namen Allahs am Anfang und am Ende.',
    'In de naam van Allah aan het begin en aan het einde ervan.',
    'Başında da sonunda da Allah''ın adıyla.',
    'Dengan nama Allah di awal dan di akhirnya.',
    'اللہ کے نام کے ساتھ اس کے اول اور اس کے آخر میں۔',
    'এর শুরুতে এবং শেষে আল্লাহর নামে।',
    'Dengan nama Allah pada awal dan akhirnya.',
    'С именем Аллаха в начале и в конце его.',
    'If one forgets to say Bismillah at the start', 'Si l''on oublie de dire Bismillah au début', 'إذا نسي التسمية في أوله',
    'Wenn man am Anfang das Bismillah vergisst', 'Als men aan het begin Bismillah vergeet', 'Başında besmeleyi unutursa',
    'Jika lupa membaca Bismillah di awal', 'Jika terlupa membaca Bismillah pada awalnya',
    'اگر شروع میں بسم اللہ بھول جائے', 'শুরুতে বিসমিল্লাহ বলতে ভুলে গেলে', 'Если забыл сказать «Бисмиллях» в начале',
    'Abū Dāwūd 3767', 'Abū Dāwūd 3767', 'سنن أبي داود ٣٧٦٧',
    1::smallint, 5::smallint
  ),
  -- ═══════════════════════════════ 4. After eating #1 ═══════════════════════
  (
    'اَلْحَمْدُ لِلّٰهِ الَّذِيْ أَطْعَمَنِيْ هٰذَا ، وَرَزَقَنِيْهِ مِنْ غَيْرِ حَوْلٍ مِنِّيْ وَلَا قُوَّةٍ.',
    'Alḥamdu li-llāhi-l-ladhī aṭʿamanī hādhā, wa razaqanīhi min ghayri ḥawlin minnī wa lā quwwah.',
    'Praise be to Allah who has fed me this and provided me with it without any power and might from me.',
    'Louange à Allah qui m''a nourri de cela et me l''a accordé sans aucune force ni puissance de ma part.',
    'Alles Lob gebührt Allah, Der mich mit diesem gespeist und es mir gegeben hat, ohne Kraft und Macht von mir.',
    'Alle lof toekomt aan Allah, Die mij hiermee heeft gevoed en het mij heeft geschonken, zonder kracht of macht van mijzelf.',
    'Kendim hiçbir güç ve kuvvet harcamaksızın beni bu yiyecekle rızıklandıran ve bana bunu yediren Allah''a hamdolsun.',
    'Segala puji bagi Allah yang telah memberi makanan ini kepadaku dan menganugerahkannya kepadaku tanpa daya dan kekuatan dariku.',
    'تمام تعریفیں اللہ کے لیے ہیں جس نے مجھے یہ کھلایا اور میری کسی طاقت اور قوت کے بغیر مجھے یہ رزق عطا فرمایا۔',
    'সমস্ত প্রশংসা আল্লাহর জন্য, যিনি আমার কোনো চেষ্টা ও সামর্থ্য ছাড়াই আমাকে এটি আহার করিয়েছেন এবং এটি আমার জীবিকা হিসেবে দান করেছেন।',
    'Segala puji bagi Allah yang telah memberi makanan ini kepadaku dan mengurniakannya kepadaku tanpa sebarang daya dan kekuatan daripadaku.',
    'Хвала Аллаху, Который накормил меня этим и наделил меня этим, тогда как сам я не обладаю ни силой, ни могуществом.',
    'After eating', 'Après avoir mangé', 'بعد الطعام',
    'Nach dem Essen', 'Na het eten', 'Yemekten sonra', 'Setelah makan', 'Selepas makan',
    'کھانے کے بعد', 'খাওয়ার পর', 'После еды',
    'Tirmidhī 3458', 'Tirmidhī 3458', 'سنن الترمذي ٣٤٥٨',
    1::smallint, 5::smallint
  ),
  -- ═══════════════════════════════ 5. After eating #2 ═══════════════════════
  (
    'اَلْحَمْدُ لِلّٰهِ حَمْدًا كَثِيْرًا طَيِّبًا مُبَارَكًا فِيْهِ ، غَيْرَ مَكْفِيٍّ وَلَا مُوَدَّعٍ ، وَلَا مُسْتَغْنًى عَنْهُ رَبَّنَا.',
    'Alḥamdu li-llāhi ḥamdan kathīran ṭayyiban mubārakan fīh, ghayra makfiyyin wa lā muwaddaʿin, wa lā mustaghnan ʿanhu rabbanā.',
    'Allah be praised with an abundant beautiful blessed praise, a never-ending praise, a praise which we will never bid farewell to and an indispensable praise, our Lord.',
    'Louange abondante, pure et bénie à Allah, une louange qui ne peut être ni délaissée, ni abandonnée, et dont on ne peut se passer, ô notre Seigneur.',
    'Alles Lob gebührt Allah; ein reichliches, reines und gesegnetes Lob, ein niemals endendes Lob, von dem wir uns niemals verabschieden und das unentbehrlich ist, unser Herr.',
    'Alle lof komt toe aan Allah; een overvloedige, reine en gezegende lofprijzing, een nooit eindigende lofprijzing, een lofprijzing waarvan we nooit afscheid nemen en die onmisbaar is, onze Heer.',
    'Rabbimiz! Sana tükenmeyen, terk edilmeyen, kendisinden müstağni olunmayan (bırakılmayan), çok, tertemiz ve mübarek hamdler ile hamdederiz.',
    'Segala puji bagi Allah dengan pujian yang banyak, baik, lagi penuh berkah di dalamnya, pujian yang tidak pernah berhenti, tidak pernah ditinggalkan, dan selalu dibutuhkan, wahai Tuhan kami.',
    'اللہ ہی کے لیے تمام تعریفیں ہیں، ایسی تعریف جو بہت زیادہ، پاکیزہ اور برکت والی ہو، ایسی تعریف جسے نہ کافی سمجھا جائے، نہ رخصت کیا جائے اور نہ اس سے بے نیازی برتی جائے، اے ہمارے رب۔',
    'আল্লাহর জন্য প্রচুর, পবিত্র ও বরকতময় প্রশংসা; যে প্রশংসার সমাপ্তি নেই, যা বিদায় দেওয়া যায় না এবং যা থেকে মুখ ফিরিয়ে নেওয়া যায় না, হে আমাদের প্রতিপালক।',
    'Segala puji bagi Allah dengan pujian yang banyak, baik, lagi penuh berkat di dalamnya, pujian yang tidak pernah cukup, tidak pernah ditinggalkan, dan sentiasa diperlukan, wahai Tuhan kami.',
    'Хвала Аллаху, хвала многая, благая и благословенная, хвала непрерывная, которую мы не покинем и без которой нам не обойтись, Господь наш.',
    'After eating', 'Après avoir mangé', 'بعد الطعام',
    'Nach dem Essen', 'Na het eten', 'Yemekten sonra', 'Setelah makan', 'Selepas makan',
    'کھانے کے بعد', 'খাওয়ার পর', 'После еды',
    'Bukhārī 5458', 'Bukhārī 5458', 'صحيح البخاري ٥٤٥٨',
    1::smallint, 5::smallint
  ),
  -- ═══════════════════════════════ 6. After eating #3 ═══════════════════════
  (
    'اَلْحَمْدُ لِلّٰهِ الَّذِيْ كَفَانَا وَأَرْوَانَا ، غَيْرَ مَكْفِىٍّ وَلَا مَكْفُوْرٍ.',
    'Alḥamdu li-llāhi-l-ladhī kafānā wa arwānā, ghayra makfiyyin wa lā makfūr.',
    'Praise be to Allah Who has sufficed us and quenched our thirst unsufficed and unrejected.',
    'Louange à Allah qui nous a suffi et nous a désaltérés, d''une manière qui ne saurait être rejetée ou méconnue.',
    'Alles Lob gebührt Allah, Der uns genügt und unseren Durst gelöscht hat, ohne abgewiesen oder undankbar behandelt zu werden.',
    'Alle lof toekomt aan Allah, Die ons heeft voldaan en onze dorst heeft gelest, zonder te worden afgewezen of ondankbaar te worden behandeld.',
    'Bize yeten, susuzluğumuzu gideren, nankörlük edilmeyen ve reddedilmeyen Allah''a hamdolsun.',
    'Segala puji bagi Allah yang telah memberikan kecukupan kepada kami dan menghilangkan dahaga kami, dengan pujian yang tidak ditolak dan tidak diingkari.',
    'تمام تعریفیں اللہ کے لیے ہیں جس نے ہمیں کافی رزق دیا اور سیراب کیا، ایسا رزق جو نہ کم پڑتا ہے اور نہ اس کی ناشکری کی جاتی ہے۔',
    'সমস্ত প্রশংসা আল্লাহর জন্য, যিনি আমাদের জন্য যথেষ্ট করেছেন এবং আমাদের তৃষ্ণা নিবারণ করেছেন; এমন প্রশংসা যা অপর্যাপ্ত নয় এবং যা প্রত্যাখ্যাত নয়।',
    'Segala puji bagi Allah yang telah memberikan kecukupan kepada kami dan menghilangkan dahaga kami, dengan pujian yang tidak ditolak dan tidak diingkari.',
    'Хвала Аллаху, Который удовлетворил наши нужды и утолил нашу жажду, Которого не отвергают и пред Которым не проявляют неблагодарности.',
    'After eating', 'Après avoir mangé', 'بعد الطعام',
    'Nach dem Essen', 'Na het eten', 'Yemekten sonra', 'Setelah makan', 'Selepas makan',
    'کھانے کے بعد', 'খাওয়ার পর', 'После еды',
    'Bukhārī 5459', 'Bukhārī 5459', 'صحيح البخاري ٥٤٥٩',
    1::smallint, 5::smallint
  ),
  -- ═══════════════════════════════ 7. After eating #4 ═══════════════════════
  (
    'اَلْحَمْدُ لِلّٰهِ الَّذِيْ أَطْعَمَنَا وَسَقَانَا وَجَعَلَنَا مُسْلِمِيْنَ.',
    'Alḥamdu li-llāhi-l-ladhī aṭʿamanā wa saqānā wa jaʿalanā muslimīn.',
    'All praise is for Allah, who has fed us and given us drink and made us Muslims.',
    'Louange à Allah qui nous a nourris, nous a abreuvés et nous a faits musulmans.',
    'Alles Lob gebührt Allah, Der uns gespeist, uns zu trinken gegeben und uns zu Muslimen gemacht hat.',
    'Alle lof toekomt aan Allah, Die ons heeft gevoed, ons te drinken heeft gegeven en ons tot moslims heeft gemaakt.',
    'Bizi yediren, içiren ve bizi Müslümanlardan kılan Allah''a hamdolsun.',
    'Segala puji bagi Allah yang telah memberi kami makan dan minum, serta menjadikan kami orang-orang muslim.',
    'تمام تعریفیں اللہ کے لیے ہیں جس نے ہمیں کھلایا، پلایا اور مسلمان بنایا۔',
    'সমস্ত প্রশংসা আল্লাহর জন্য, যিনি আমাদের আহার করিয়েছেন, পান করিয়েছেন এবং আমাদের মুসলমান বানিয়েছেন।',
    'Segala puji bagi Allah yang telah memberi kami makan dan minum, serta menjadikan kami orang-orang muslim.',
    'Хвала Аллаху, Который накормил нас, напоил нас и сделал нас мусульманами.',
    'After eating', 'Après avoir mangé', 'بعد الطعام',
    'Nach dem Essen', 'Na het eten', 'Yemekten sonra', 'Setelah makan', 'Selepas makan',
    'کھانے کے بعد', 'খাওয়ার পর', 'После еды',
    'Tirmidhī 3457', 'Tirmidhī 3457', 'سنن الترمذي ٣٤٥٧',
    1::smallint, 5::smallint
  ),
  -- ═══════════════════════════════ 8. After eating #5 ═══════════════════════
  (
    'اَللّٰهُمَّ أَطْعَمْتَ وَأَسْقَيْتَ ، وَهَدَيْتَ وَأَحْيَيْتَ ، فَلَكَ الْحَمْدُ عَلَىٰ مَا أَعْطَيْتَ.',
    'Allāhumma aṭʿamta wa asqayta, wa hadayta wa aḥyayta, fa-laka-l-ḥamdu ʿalā mā aʿṭayta.',
    'O Allah, You have fed and given to drink, You have guided us and revived us. So, to You be all praise for what You have granted.',
    'Ô Allah, Tu as nourri, Tu as abreuvé, Tu as guidé et Tu as fait revivre. À Toi la louange pour ce que Tu as donné.',
    'O Allah, Du hast gespeist und zu trinken gegeben, Du hast geleitet und belebt. Dir gebührt alles Lob für das, was Du gewährt hast.',
    'O Allah, U heeft gevoed en te drinken gegeven, U heeft geleid en tot leven gewekt. Aan U behoort alle lof voor wat U heeft geschonken.',
    'Allah''ım! Yedirdin, içirdin, hidayet ettin ve hayat verdin. Verdiklerine karşı Sana hamdolsun.',
    'Ya Allah, Engkau telah memberi makan, memberi minum, memberi petunjuk, dan menghidupkan. Maka bagi-Mu segala puji atas apa yang telah Engkau berikan.',
    'اے اللہ! تو نے کھلایا اور پلایا، اور تو نے ہدایت دی اور زندہ کیا، پس جو کچھ تو نے عطا فرمایا اس پر تیرے ہی لیے تمام تعریفیں ہیں۔',
    'হে আল্লাহ! আপনি আহার করিয়েছেন, পান করিয়েছেন, হেদায়েত দিয়েছেন এবং জীবন দান করেছেন। অতএব, আপনি যা দান করেছেন তার জন্য সমস্ত প্রশংসা আপনারই।',
    'Ya Allah, Engkau telah memberi makan, memberi minum, memberi petunjuk, dan menghidupkan. Maka bagi-Mu segala puji atas apa yang telah Engkau kurniakan.',
    'О Аллах, Ты накормил, напоил, наставил на прямой путь и оживил, и Тебе хвала за то, что Ты даровал.',
    'After eating', 'Après avoir mangé', 'بعد الطعام',
    'Nach dem Essen', 'Na het eten', 'Yemekten sonra', 'Setelah makan', 'Selepas makan',
    'کھانے کے بعد', 'খাওয়ার পর', 'После еды',
    NULL, NULL, NULL,
    1::smallint, 5::smallint
  ),
  -- ═══════════════════════════════ 9. After eating #7 ═══════════════════════
  (
    'اَلْحَمْدُ لِلّٰهِ الَّذِيْ أَطْعَمَ وَسَقَىٰ ، وَسَوَّغَهُ وَجَعَلَ لَهُ مَخْرَجًا.',
    'Alḥamdu li-llāhi-l-ladhī aṭʿama wa saqā, wa sawwaghahu wa jaʿala lahu makhrajan.',
    'Praise be to Allah, Who has provided [food and drink], made it easy to swallow, and made a way out for it.',
    'Louange à Allah qui a nourri et abreuvé, a facilité sa déglutition et lui a tracé une issue.',
    'Alles Lob gebührt Allah, Der gespeist und zu trinken gegeben hat, es leicht zu schlucken machte und einen Ausweg dafür schuf.',
    'Alle lof toekomt aan Allah, Die heeft gevoed en te drinken heeft gegeven, het gemakkelijk te slikken heeft gemaakt en er een uitweg voor heeft gemaakt.',
    'Yediren, içiren, yutulmasını kolaylaştıran ve ona bir çıkış yolu var eden Allah''a hamdolsun.',
    'Segala puji bagi Allah yang telah memberi makan dan minum, menjadikannya mudah ditelan, dan menjadikannya jalan keluar.',
    'تمام تعریفیں اللہ کے لیے ہیں جس نے کھلایا اور پلایا، اور اسے حلق سے اترنا آسان کیا اور اس کے نکلنے کا راستہ بنایا۔',
    'সমস্ত প্রশংসা আল্লাহর জন্য, যিনি আহার করিয়েছেন ও পান করিয়েছেন, তা সহজে গলাধঃকরণ করার উপযোগী করেছেন এবং তার নির্গমনের পথ তৈরি করেছেন।',
    'Segala puji bagi Allah yang telah memberi makan dan minum, menjadikannya mudah ditelan, dan menjadikannya jalan keluar.',
    'Хвала Аллаху, Который накормил и напоил, сделал пищу легко усвояемой и устроил для нее выход.',
    'After eating', 'Après avoir mangé', 'بعد الطعام',
    'Nach dem Essen', 'Na het eten', 'Yemekten sonra', 'Setelah makan', 'Selepas makan',
    'کھانے کے بعد', 'খাওয়ার পর', 'После еды',
    'Abū Dāwūd 3851', 'Abū Dāwūd 3851', 'سنن أبي داود ٣٨٥١',
    1::smallint, 5::smallint
  ),
  -- ═══════════════════════════════ 10. After drinking milk ══════════════════
  (
    'اَللّٰهُمَّ بَارِكْ لَنَا فِيْهِ وَزِدْنَا مِنْهُ.',
    'Allāhumma bārik lanā fīhi wa zidnā minhu.',
    'O Allah, bless us in it and give us more of it.',
    'Ô Allah, bénis-nous en cela et accorde-nous-en davantage.',
    'O Allah, segne uns darin und gib uns mehr davon.',
    'O Allah, zegen ons erin en schenk ons er meer van.',
    'Allah''ım! Bize bunda bereket ver ve bize bundan daha çok ver.',
    'Ya Allah, berkahilah kami di dalamnya dan tambahkanlah kepada kami darinya.',
    'اے اللہ! ہمارے لیے اس میں برکت فرما اور ہمیں اس سے مزید زیادہ عطا فرما۔',
    'হে আল্লাহ! আপনি আমাদের জন্য এতে বরকত দিন এবং আমাদের এতে আরও বাড়িয়ে দিন।',
    'Ya Allah, berkahilah kami di dalamnya dan tambahkanlah kepada kami daripadanya.',
    'О Аллах, благослови нас в этом и прибавь нам этого.',
    'After drinking milk', 'Après avoir bu du lait', 'بعد شرب اللبن',
    'Nach dem Trinken von Milch', 'Na het drinken van melk', 'Süt içtikten sonra',
    'Setelah minum susu', 'Selepas minum susu', 'دودھ پینے کے بعد',
    'দুধ পান করার পর', 'После питья молока',
    'Abū Dāwūd 3730', 'Abū Dāwūd 3730', 'سنن أبي داود ٣٧٣٠',
    1::smallint, 5::smallint
  ),
  -- ════════════════ 11. For one who gives you food or drink ═════════════════
  (
    'اللَّهُمَّ أَطْعَمْ مَنْ أَطْعَمَنِيْ وَاسْقِ مَنْ سَقَانِي.',
    'Allāhumma aṭʿim man aṭʿamanī wa-sqi man saqānī.',
    'O Allah, feed the one who has fed me and give to drink the one who has given me to drink.',
    'Ô Allah, nourris celui qui m''a nourri et abreuve celui qui m''a abreuvé.',
    'O Allah, speise den, der mich gespeist hat, und gib dem zu trinken, der mir zu trinken gegeben hat.',
    'O Allah, voed degene die mij heeft gevoed en geef te drinken aan degene die mij te drinken heeft gegeven.',
    'Allah''ım! Beni doyuranı doyur, bana içirene içir.',
    'Ya Allah, berilah makan orang yang telah memberi makan kepadaku, dan berilah minum orang yang telah memberi minum kepadaku.',
    'اے اللہ! اسے کھلا جس نے مجھے کھلایا اور اسے پلا جس نے مجھے پلایا۔',
    'হে আল্লাহ! যে আমাকে আহার করিয়েছে তাকে আহার করান এবং যে আমাকে পান করিয়েছে তাকে পান করান।',
    'Ya Allah, berilah makan kepada orang yang telah memberi makan kepadaku, dan berilah minum kepada orang yang telah memberi minum kepadaku.',
    'О Аллах, накорми того, кто накормил меня, и напои того, кто напоил меня.',
    'For one who gives you food or drink', 'Pour celui qui vous offre à manger ou à boire', 'الدعاء لمن أطعمك أو سقاك',
    'Für den, der dir zu essen oder zu trinken gibt', 'Voor wie u eten of drinken geeft', 'Seni doyurana veya içirene dua',
    'Doa untuk orang yang memberi makan atau minum', 'Doa untuk orang yang memberi makan atau minum',
    'کھلانے یا پلانے والے کے لیے دعا', 'যে খাওয়ায় বা পান করায় তার জন্য দোয়া', 'За того, кто накормил или напоил',
    'Muslim 2055', 'Muslim 2055', 'صحيح مسلم ٢٠٥٥',
    1::smallint, 5::smallint
  ),
  -- ═══════════════════════════════ 12. Du'a for the host #1 ═════════════════
  (
    'أَفْطَرَ عِنْدَكُمُ الصَّائِمُوْنَ ، وَأَكَلَ طَعَامَكُمُ الأَبْرَارُ ، وَصَلَّتْ عَلَيْكُمُ الْمَلَائِكَةُ.',
    'Afṭara ʿindakumu-ṣ-ṣā''imūn, wa akala ṭaʿāmakumu-l-abrār, wa ṣallat ʿalaykumu-l-malā''ikah.',
    'May the fasting open their fasts with you, the pious eat your food, and the angels pray for blessings on you.',
    'Que les jeûneurs rompent leur jeûne chez vous, que les pieux mangent votre nourriture et que les anges prient pour votre bénédiction.',
    'Mögen die Fastenden ihr Fasten bei euch brechen, mögen die Frommen eure Speise essen und mögen die Engel für euren Segen beten.',
    'Mogen de vastenden hun vasten bij u breken, mogen de vromen uw voedsel eten en mogen de engelen om zegeningen voor u bidden.',
    'Yanınızda oruçlular iftar etsin, yemeğinizi iyiler yesin ve melekler size dua etsin.',
    'Telah berbuka di tempat kalian orang-orang yang berpuasa, dan telah memakan makanan kalian orang-orang yang baik, dan semoga para malaikat mendoakan kebaikan bagi kalian.',
    'تمہارے پاس روزہ دار افطار کریں، اور تمہارا کھانا نیک لوگ کھائیں، اور فرشتے تمہارے لیے رحمت کی دعا کریں۔',
    'রোজাদাররা যেন তোমাদের কাছে ইফতার করে, সৎকর্মপরায়ণ ব্যক্তিরা যেন তোমাদের খাদ্য আহার করে এবং ফেরেশতারা যেন তোমাদের জন্য কল্যাণের দোয়া করে।',
    'Telah berbuka di tempat kamu orang-orang yang berpuasa, dan telah memakan makanan kamu orang-orang yang baik, dan semoga para malaikat mendoakan kebaikan ke atas kamu.',
    'Да разговляются у вас постящиеся, и да вкушают вашу пищу праведные, и да благословляют вас ангелы.',
    'Du''a for the host', 'Invocation pour l''hôte', 'الدعاء للمضيف',
    'Bittgebet für den Gastgeber', 'Smeekbede voor de gastheer', 'Ev sahibi için dua',
    'Doa untuk tuan rumah', 'Doa untuk tuan rumah', 'میزبان کے لیے دعا',
    'মেজবানের জন্য দোয়া', 'Дуа за хозяина (угостившего)',
    'Abū Dāwūd 3854', 'Abū Dāwūd 3854', 'سنن أبي داود ٣٨٥٤',
    1::smallint, 5::smallint
  ),
  -- ═══════════════════════════════ 13. Du'a for the host #2 ═════════════════
  (
    'اَللّٰهُمَّ بَارِك لَهُمْ فِيْ مَا رَزَقْتَهُمْ ، وَاغْفِر لَهُمْ وَارْحَمْهُمْ.',
    'Allāhumma bārik lahum fīmā razaqtahum, wa-ghfir lahum wa-rḥamhum.',
    'O Allah, bless them in what You have provided them, forgive them and have mercy upon them.',
    'Ô Allah, bénis-les dans ce que Tu leur as attribué, pardonne-leur et fais-leur miséricorde.',
    'O Allah, segne sie in dem, was Du ihnen gegeben hast, vergib ihnen und erbarme Dich ihrer.',
    'O Allah, zegen hen in wat U hun hebt geschonken, vergeef hen en wees hen barmhartig.',
    'Allah''ım! Onlara verdiğin rızkı mübarek kıl, onları bağışla ve onlara merhamet et.',
    'Ya Allah, berkahilah mereka dalam apa yang Engkau rezekikan kepada mereka, ampunilah mereka dan rahmatilah mereka.',
    'اے اللہ! جو رزق تو نے انہیں دیا ہے اس میں ان کے لیے برکت فرما، انہیں بخش دے اور ان پر رحم فرما۔',
    'হে আল্লাহ! আপনি তাদের যে জীবিকা দান করেছেন তাতে বরকত দিন, তাদের ক্ষমা করুন এবং তাদের প্রতি দয়া করুন।',
    'Ya Allah, berkahilah mereka pada apa yang Engkau rezekikan kepada mereka, ampunilah mereka dan rahmatilah mereka.',
    'О Аллах, благослови их в том, чем Ты их наделил, прости их и помилуй.',
    'Du''a for the host', 'Invocation pour l''hôte', 'الدعاء للمضيف',
    'Bittgebet für den Gastgeber', 'Smeekbede voor de gastheer', 'Ev sahibi için dua',
    'Doa untuk tuan rumah', 'Doa untuk tuan rumah', 'میزبان کے لیے دعا',
    'মেজবানের জন্য দোয়া', 'Дуа за хозяина (угостившего)',
    'Muslim 2042', 'Muslim 2042', 'صحيح مسلم ٢٠٤٢',
    1::smallint, 5::smallint
  ),
  -- ═══════════════════════════════ 14. After breaking the fast #1 ═══════════
  (
    'ذَهَبَ الظَّمَأُ ، وَابْتَلَّتِ الْعُرُوْقُ ، وَثَبَتَ الْأَجْرُ إِنْ شَاءَ اللّٰهُ.',
    'Dhahaba-ẓ-ẓama''u, wa-btallati-l-ʿurūq, wa thabata-l-ajru in shā''a-llāh.',
    'The thirst has gone, the veins have been moistened, and the reward has been secured, if Allah wills.',
    'La soif est étanchée, les veines sont irriguées et la récompense est assurée, si Allah le veut.',
    'Der Durst ist vergangen, die Adern sind feucht geworden und der Lohn ist gesichert, so Allah will.',
    'De dorst is verdwenen, de aderen zijn vochtig geworden en de beloning staat vast, als Allah het wil.',
    'Susuzluk gitti, damarlar ıslandı ve inşallah ecir (sevap) kesinleşti.',
    'Rasa dahaga telah hilang, urat-urat telah basah, dan pahala telah ditetapkan, insya Allah.',
    'پیاس چلی گئی، رگیں تر ہو گئیں، اور اللہ نے چاہا تو اجر ثابت ہو گیا۔',
    'পিপাসা দূর হলো, শিরা-উপশিরা সিক্ত হলো এবং আল্লাহ চাহেন তো পুরস্কার নির্ধারিত হলো।',
    'Rasa dahaga telah hilang, urat-urat telah basah, dan pahala telah tetap, insya-Allah.',
    'Ушла жажда, жилы наполнились влагой, и награда уже созрела, если угодно будет Аллаху.',
    'After breaking the fast', 'Après la rupture du jeûne', 'بعد الإفطار',
    'Nach dem Fastenbrechen', 'Na het verbreken van het vasten', 'Orucu açtıktan sonra',
    'Setelah berbuka puasa', 'Selepas berbuka puasa', 'افطار کے بعد',
    'ইফতারের পর', 'После разговения (ифтара)',
    'Abū Dāwūd 2357', 'Abū Dāwūd 2357', 'سنن أبي داود ٢٣٥٧',
    1::smallint, 5::smallint
  ),
  -- ═══════════════════════════════ 15. When breaking the fast #2 ════════════
  (
    'اَللّٰهُمَّ لَكَ صُمْتُ وَعَلَىٰ رِزْقِكَ أَفْطَرْتُ.',
    'Allāhumma laka ṣumtu wa ʿalā rizqika afṭartu.',
    'O Allah, for You I have fasted, and with Your provision I have broken my fast.',
    'Ô Allah, pour Toi j''ai jeûné et c''est avec Ta subsistance que j''ai rompu mon jeûne.',
    'O Allah, für Dich habe ich gefastet und mit Deiner Versorgung breche ich mein Fasten.',
    'O Allah, voor U heb ik gevast en met Uw voorziening verbreek ik mijn vasten.',
    'Allah''ım! Senin rızan için oruç tuttum ve Senin rızkınla iftar ettim.',
    'Ya Allah, untuk-Mu aku berpuasa dan dengan rezeki-Mu aku berbuka.',
    'اے اللہ! میں نے تیرے ہی لیے روزہ رکھا اور تیرے ہی دیے ہوئے رزق پر افطار کیا۔',
    'হে আল্লাহ! আমি আপনার জন্যই রোজা রেখেছিলাম এবং আপনার দেওয়া রিজিক দিয়েই ইফতার করলাম।',
    'Ya Allah, untuk-Mu aku berpuasa dan dengan rezeki-Mu aku berbuka.',
    'О Аллах, ради Тебя я постился и Твоим пропитанием разговелся.',
    'When breaking the fast', 'En rompant le jeûne', 'عند الإفطار',
    'Beim Fastenbrechen', 'Bij het verbreken van het vasten', 'Orucu açarken',
    'Ketika berbuka puasa', 'Ketika berbuka puasa', 'افطار کے وقت',
    'ইফতারের সময়', 'При разговении (ифтаре)',
    'Abū Dāwūd 2358', 'Abū Dāwūd 2358', 'سنن أبي داود ٢٣٥٨',
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
where s.title_en = 'Eating & drinking'
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
  and s.title_en = 'Eating & drinking';

-- 4c) Reference for Latin-script languages: collection names stay romanised
-- (NULL reference for "After Eating #5" propagates as NULL).
update public.adhkars a
set
  reference_de = a.reference_en,
  reference_nl = a.reference_en,
  reference_tr = a.reference_en,
  reference_id = a.reference_en,
  reference_ms = a.reference_en
from public.adhkar_subcategories s
where a.adhkar_subcategory_id = s.id
  and s.title_en = 'Eating & drinking';

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
  -- 1. Before eating #1
  ('Bismi-llāh.',
   'بِسْمِ اللہ۔', 'বিসমিল্লাহ।', 'Бисми-Ллях.',
   'بخاری 5376', 'বুখারী 5376', 'аль-Бухари 5376'),
  -- 2. Before eating #2
  ('Allāhumma bārik lanā fīhi wa aṭʿimnā khayran minhu.',
   'اَللّٰھُمَّ بَارِکْ لَنَا فِیْہِ وَاَطْعِمْنَا خَیْرًا مِّنْہُ۔',
   'আল্লাহুম্মা বারিক লানা ফীহি ওয়া আতইমনা খাইরাম মিনহু।',
   'Аллахумма барик ляна фихи ва ат’имна хайран минху.',
   'ترمذی 3455', 'তিরমিযী 3455', 'ат-Тирмизи 3455'),
  -- 3. If one forgets at the start
  ('Bismi-llāhi awwalahu wa ākhirahu.',
   'بِسْمِ اللہِ اَوَّلَہٗ وَآخِرَہٗ۔',
   'বিসমিল্লাহি আওয়ালাহূ ওয়া আখিরাহূ।',
   'Бисми-Лляхи аввалаху ва ахираху.',
   'ابو داؤد 3767', 'আবু দাউদ 3767', 'Абу Дауд 3767'),
  -- 4. After eating #1
  ('Alḥamdu li-llāhi-l-ladhī aṭʿamanī hādhā, wa razaqanīhi min ghayri ḥawlin minnī wa lā quwwah.',
   'اَلْحَمْدُ لِلہِ الَّذِیْ اَطْعَمَنِیْ ھٰذَا، وَرَزَقَنِیْہِ مِنْ غَیْرِ حَوْلٍ مِّنِّیْ وَلَا قُوَّۃٍ۔',
   'আলহামদু লিল্লাহিল্লাযী আতআমানী হাযা, ওয়া রাযাকানীহি মিন গাইরি হাওলিম মিন্নী ওয়ালা কুওয়াহ।',
   'Аль-хамду ли-Лляхи-ллязи ат’амани хаза, ва разаканихи мин гайри хаулин минни ва ля кувва.',
   'ترمذی 3458', 'তিরমিযী 3458', 'ат-Тирмизи 3458'),
  -- 5. After eating #2
  ('Alḥamdu li-llāhi ḥamdan kathīran ṭayyiban mubārakan fīh, ghayra makfiyyin wa lā muwaddaʿin, wa lā mustaghnan ʿanhu rabbanā.',
   'اَلْحَمْدُ لِلہِ حَمْدًا کَثِیْرًا طَیِّبًا مُّبَارَکًا فِیْہِ، غَیْرَ مَکْفِیٍّ وَلَا مُوَدَّعٍ، وَلَا مُسْتَغْنًی عَنْہُ رَبَّنَا۔',
   'আলহামদু লিল্লাহি হামদান কাছীরান তাইয়িবাম মুবারাকান ফীহি, গাইরা মাকফিইয়িঁও ওয়ালা মুওয়াদ্দাইন, ওয়ালা মুসতাগনান আনহু রাব্বানা।',
   'Аль-хамду ли-Лляхи хамдан касиран таййибан мубаракан фих, гайра макфиййин ва ля муваддаин, ва ля мустагнан ’анху раббана.',
   'بخاری 5458', 'বুখারী 5458', 'аль-Бухари 5458'),
  -- 6. After eating #3
  ('Alḥamdu li-llāhi-l-ladhī kafānā wa arwānā, ghayra makfiyyin wa lā makfūr.',
   'اَلْحَمْدُ لِلہِ الَّذِیْ کَفَانَا وَاَرْوَانَا، غَیْرَ مَکْفِیٍّ وَلَا مَکْفُوْرٍ۔',
   'আলহামদু লিল্লাহিল্লাযী কাফানা ওয়া আরওয়ানা, গাইরা মাকফিইয়িঁও ওয়ালা মাকফূর।',
   'Аль-хамду ли-Лляхи-ллязи кафана ва арвана, гайра макфиййин ва ля макфур.',
   'بخاری 5459', 'বুখারী 5459', 'аль-Бухари 5459'),
  -- 7. After eating #4
  ('Alḥamdu li-llāhi-l-ladhī aṭʿamanā wa saqānā wa jaʿalanā muslimīn.',
   'اَلْحَمْدُ لِلہِ الَّذِیْ اَطْعَمَنَا وَسَقَانَا وَجَعَلَنَا مُسْلِمِیْنَ۔',
   'আলহামদু লিল্লাহিল্লাযী আতআমানা ওয়া সাকানা ওয়া জাআলানা মুসলিমীন।',
   'Аль-хамду ли-Лляхи-ллязи ат’амана ва сакана ва джа’аляна муслимин.',
   'ترمذی 3457', 'তিরমিযী 3457', 'ат-Тирмизи 3457'),
  -- 8. After eating #5 (reference left NULL)
  ('Allāhumma aṭʿamta wa asqayta, wa hadayta wa aḥyayta, fa-laka-l-ḥamdu ʿalā mā aʿṭayta.',
   'اَللّٰھُمَّ اَطْعَمْتَ وَاَسْقَیْتَ، وَھَدَیْتَ وَاَحْیَیْتَ، فَلَکَ الْحَمْدُ عَلٰی مَا اَعْطَیْتَ۔',
   'আল্লাহুম্মা আতআমতা ওয়া আসকাইতা, ওয়া হাদাইতা ওয়া আহইয়াইতা, ফালাকাল হামদু আলা মা আতাইতা।',
   'Аллахумма ат’амта ва аскайта, ва хадайта ва ахьяйта, фа-ляка-ль-хамду ’аля ма а’тайта.',
   NULL, NULL, NULL),
  -- 9. After eating #7
  ('Alḥamdu li-llāhi-l-ladhī aṭʿama wa saqā, wa sawwaghahu wa jaʿala lahu makhrajan.',
   'اَلْحَمْدُ لِلہِ الَّذِیْ اَطْعَمَ وَسَقٰی، وَسَوَّغَہٗ وَجَعَلَ لَہٗ مَخْرَجًا۔',
   'আলহামদু লিল্লাহিল্লাযী আতআমা ওয়া সাকা, ওয়া সাওয়াগাহূ ওয়া জাআলা লাহূ মাখরাজা।',
   'Аль-хамду ли-Лляхи-ллязи ат’ама ва сака, ва саввагаху ва джа’аля ляху махраджан.',
   'ابو داؤد 3851', 'আবু দাউদ 3851', 'Абу Дауд 3851'),
  -- 10. After drinking milk
  ('Allāhumma bārik lanā fīhi wa zidnā minhu.',
   'اَللّٰھُمَّ بَارِکْ لَنَا فِیْہِ وَزِدْنَا مِنْہُ۔',
   'আল্লাহুম্মা বারিক লানা ফীহি ওয়া যিদনা মিনহু।',
   'Аллахумма барик ляна фихи ва зидна минху.',
   'ابو داؤد 3730', 'আবু দাউদ 3730', 'Абу Дауд 3730'),
  -- 11. For one who gives you food or drink
  ('Allāhumma aṭʿim man aṭʿamanī wa-sqi man saqānī.',
   'اَللّٰھُمَّ اَطْعِمْ مَنْ اَطْعَمَنِیْ وَاسْقِ مَنْ سَقَانِیْ۔',
   'আল্লাহুম্মা আতইম মান আতআমানী ওয়াসকি মান সাকানী।',
   'Аллахумма ат’им ман ат’амани васкы ман сакани.',
   'مسلم 2055', 'মুসলিম 2055', 'Муслим 2055'),
  -- 12. Du'a for the host #1
  ('Afṭara ʿindakumu-ṣ-ṣā''imūn, wa akala ṭaʿāmakumu-l-abrār, wa ṣallat ʿalaykumu-l-malā''ikah.',
   'اَفْطَرَ عِنْدَکُمُ الصَّائِمُوْنَ، وَاَکَلَ طَعَامَکُمُ الْاَبْرَارُ، وَصَلَّتْ عَلَیْکُمُ الْمَلَائِکَۃُ۔',
   'আফতারা ইনদাকুমুস সায়িমূন, ওয়া আকালা তাআমাকুমুল আবরার, ওয়া সাল্লাত আলাইকুমুল মালাইকাহ।',
   'Афтара ’индакуму-с-сайимун, ва акаля та’амакуму-ль-абрар, ва салляат ’аляйкуму-ль-маляика.',
   'ابو داؤد 3854', 'আবু দাউদ 3854', 'Абу Дауд 3854'),
  -- 13. Du'a for the host #2
  ('Allāhumma bārik lahum fīmā razaqtahum, wa-ghfir lahum wa-rḥamhum.',
   'اَللّٰھُمَّ بَارِکْ لَھُمْ فِیْ مَا رَزَقْتَھُمْ، وَاغْفِرْ لَھُمْ وَارْحَمْھُمْ۔',
   'আল্লাহুম্মা বারিক লাহুম ফীমা রাযাকতাহুম, ওয়াগফির লাহুম ওয়ারহামহুম।',
   'Аллахумма барик ляхум фима разактахум, ва-гфир ляхум ва-рхамхум.',
   'مسلم 2042', 'মুসলিম 2042', 'Муслим 2042'),
  -- 14. After breaking the fast #1
  ('Dhahaba-ẓ-ẓama''u, wa-btallati-l-ʿurūq, wa thabata-l-ajru in shā''a-llāh.',
   'ذَھَبَ الظَّمَأُ، وَابْتَلَّتِ الْعُرُوْقُ، وَثَبَتَ الْاَجْرُ اِنْ شَاءَ اللہُ۔',
   'যাহাবায যামাউ, ওয়াবতাল্লাতিল উরূকু, ওয়া ছাবাতাল আজরু ইনশাআল্লাহ।',
   'Захаба-з-зама’у, ва-бталляти-ль-’урук, ва сабата-ль-аджру ин ша’а-Ллах.',
   'ابو داؤد 2357', 'আবু দাউদ 2357', 'Абу Дауд 2357'),
  -- 15. When breaking the fast #2
  ('Allāhumma laka ṣumtu wa ʿalā rizqika afṭartu.',
   'اَللّٰھُمَّ لَکَ صُمْتُ وَعَلٰی رِزْقِکَ اَفْطَرْتُ۔',
   'আল্লাহুম্মা লাকা সুমতু ওয়া আলা রিযকিকা আফতারতু।',
   'Аллахумма ляка сумту ва ’аля ризкика афтарту.',
   'ابو داؤد 2358', 'আবু দাউদ 2358', 'Абу Дауд 2358')
) as m(tr_key, t_ur, t_bn, t_ru, r_ur, r_bn, r_ru)
where a.adhkar_subcategory_id = s.id
  and s.title_en = 'Eating & drinking'
  and a.transcription_en = m.tr_key;
