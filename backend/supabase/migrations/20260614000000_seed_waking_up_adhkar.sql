-- =============================================================================
-- Seed: "Waking up" subcategory (under existing "Daily routine" category)
--        + 5 adhkars.
--
-- Source: Life With Allah – Waking up
--   https://lifewithallah.com/dhikr-dua/other-adhkar/waking-up/
--
-- Localization mirrors 20260611000000_seed_morning_adhkar.sql,
-- 20260612000000_seed_evening_adhkar.sql and
-- 20260613000000_seed_before_sleep_adhkar.sql:
--   * arabic_text      – exact source text
--   * translation_*    – en (source) + fr, de, nl, tr, id, ur, bn, ms, ru
--   * transcription_*  – Latin transliteration (source); fanned out to every
--                        Latin-script language column at the end (step 4b)
--   * when_*           – per-adhkar context phrase, localised to every language
--                        directly in VALUES (the 5 adhkars do not share a single
--                        "when", unlike the before-sleep set)
--   * reference_*      – en/fr/ar in VALUES; de/nl/tr/id/ms via step 4c and
--                        ur/bn/ru via step 4d
--
-- The "Daily routine" category is created by the morning migration; here we
-- only resolve it by title. Idempotent: subcategory inserted if missing,
-- adhkars inserted only when the subcategory has none yet.
--
-- REVIEW NOTE: non-English/Arabic translations of the Qur'anic passage
-- (Āl ʿImrān 3:190-200) and prophetic supplications, and the ur/bn/ru phonetic
-- transcriptions, should be reviewed by a qualified native speaker before
-- production use.
-- =============================================================================

-- ── Subcategory: Waking up ───────────────────────────────────────────────────
-- Recommended window: night-waking -> just after Fajr (≈ 00:00–08:00 => 0–480 min).
insert into public.adhkar_subcategories
  (adhkar_category_id, title_en, title_fr, title_ar, title_de, title_nl, title_tr,
   title_id, title_ur, title_bn, title_ms, title_ru,
   recommended_start_minute, recommended_end_minute, position)
select
  c.id, 'Waking up', 'Au réveil', 'أذكار الاستيقاظ', 'Beim Aufwachen',
  'Bij het ontwaken', 'Uyanma ezkârı', 'Zikir bangun tidur', 'بیدار ہونے کے اذکار',
  'ঘুম থেকে জাগার আযকার', 'Zikir bangun tidur', 'Азкары при пробуждении',
  0, 480, 4
from public.adhkar_categories c
where c.title_en = 'Daily routine'
  and not exists (
    select 1 from public.adhkar_subcategories s
    where s.title_en = 'Waking up' and s.adhkar_category_id = c.id
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
  -- ════════════════════ 1. When changing sides at night ═════════════════════
  (
    'لَا إِلٰهَ إِلاَّ اللّٰهُ الْوَاحِدُ الْقَهَّارُ ، رَبُّ السَّمٰـوٰتِ وَالْأَرْضِ وَمَا بَيْنَهُمَا الْعَزِيْزُ الْغَفَّارُ',
    'Lā ilāha illa-Allāhu-l-Wāḥid-ul-Qahhār, Rabbu-s-samāwāti wa-l-ardi wa mā baynahuma-l-ʿAzīz-ul-Ghaffār.',
    'There is no god worthy of worship but Allah: The One, The All-Dominant; Lord of the heavens, the earth and whatever is between them; The Mighty, The Most Forgiving.',
    'Il n''y a de divinité digne d''adoration qu''Allah, l''Unique, le Tout-Dominateur ; Seigneur des cieux, de la terre et de ce qui est entre eux ; le Puissant, le Très-Pardonnant.',
    'Es gibt keinen Gott, der der Anbetung würdig ist, außer Allah, dem Einen, dem Allbezwinger; dem Herrn der Himmel, der Erde und dessen, was zwischen ihnen ist; dem Allmächtigen, dem stets Vergebenden.',
    'Er is geen god die aanbidding waard is behalve Allah, de Enige, de Albeheerser; de Heer van de hemelen, de aarde en wat daartussen is; de Almachtige, de Meest Vergevende.',
    'Allah''tan başka ibadete layık ilah yoktur; O, Tek''tir, Kahhâr''dır (her şeye mutlak galip); göklerin, yerin ve ikisi arasındakilerin Rabbidir; Azîz''dir (mutlak güç sahibi), Gaffâr''dır (çok bağışlayan).',
    'Tidak ada tuhan yang berhak disembah selain Allah, Yang Maha Esa, Yang Maha Menundukkan; Tuhan langit, bumi, dan apa yang ada di antara keduanya; Yang Maha Mulia lagi Maha Pengampun.',
    'اللہ کے سوا کوئی معبودِ برحق نہیں، وہ یکتا ہے، سب پر غالب ہے؛ آسمانوں، زمین اور جو کچھ ان کے درمیان ہے سب کا رب ہے؛ زبردست، بہت بخشنے والا ہے۔',
    'আল্লাহ ছাড়া ইবাদতের যোগ্য কোনো উপাস্য নেই, তিনি এক, মহাপরাক্রমশালী; আসমান, জমিন ও এ দুটির মধ্যবর্তী সবকিছুর রব; মহাশক্তিধর, অত্যন্ত ক্ষমাশীল।',
    'Tiada tuhan yang berhak disembah melainkan Allah, Yang Maha Esa, Yang Maha Menundukkan; Tuhan langit, bumi dan apa yang ada di antara keduanya; Yang Maha Perkasa lagi Maha Pengampun.',
    'Нет божества, достойного поклонения, кроме Аллаха, Единого, Всепокоряющего; Господа небес, земли и того, что между ними; Могущественного, Всепрощающего.',
    'When changing sides at night', 'En se retournant la nuit', 'عند التقلب في الليل',
    'Beim Umdrehen in der Nacht', 'Bij het omdraaien in de nacht',
    'Gece yan değiştirirken', 'Ketika berganti sisi di malam hari',
    'Ketika bertukar sisi pada waktu malam', 'رات کو کروٹ بدلتے وقت',
    'রাতে পাশ ফেরার সময়', 'При повороте на другой бок ночью',
    'Nasā''ī al-Kubrā 10700', 'Nasā''ī al-Kubrā 10700', 'السنن الكبرى للنسائي ١٠٧٠٠',
    1::smallint, 5::smallint
  ),
  -- ═══════════════════════ 2. When one wakes up at night ════════════════════
  (
    'لَا إِلٰهَ إِلَّا اللّٰهُ وَحْدَهُ لَا شَرِيْكَ لَهُ ، لَهُ الْمُلْكُ ، وَلَهُ الْحَمْدُ ، وَهُوَ عَلَىٰ كُلِّ شَيْءٍ قَدِيْرٌ‏ ، اَلْحَمْدُ لِلّٰهِ‏ ، وَسُبْحَانَ اللّٰهِ ، وَلَا إِلٰهَ إِلَّا اللّٰهُ ، وَاللّٰهُ أَكْبَرُ ، وَلَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللّٰهِ ، اَللّٰهُمَّ اغْفِرْ لِيْ.',
    'Lā ilāha illā-l-lāhu waḥdahū lā sharīka lah, lahu-l-mulku wa lahu-l-ḥamd, wa Huwa ʿalā kulli shay''in Qadīr, alḥamdu li-llāh, wa subḥāna-llāh, wa lā ilāha illā-l-llāh, wa-llāhu akbar, wa lā ḥawla wa lā quwwata illā bi-llāh, allāhumma-ghfir lī.',
    'There is no god worthy of worship but Allah. He is Alone and He has no partner whatsoever. To Him Alone belong all sovereignty and all praise. He is over all things All-Powerful. All praise be to Allah and Allah is free from imperfection. There is no god but Allah. Allah is the Greatest. There is no power (in averting evil) or strength (in attaining good) except through Allah. O Allah, forgive me.',
    'Il n''y a de divinité digne d''adoration qu''Allah, Seul, sans aucun associé. À Lui Seul appartiennent la royauté et la louange, et Il est Omnipotent sur toute chose. Louange à Allah, et gloire et pureté à Allah ; il n''y a de divinité qu''Allah ; Allah est le plus Grand ; et il n''y a de force (pour éviter le mal) ni de puissance (pour accomplir le bien) qu''en Allah. Ô Allah, pardonne-moi.',
    'Es gibt keinen Gott, der der Anbetung würdig ist, außer Allah, allein, ohne jeglichen Teilhaber. Ihm allein gehören die Herrschaft und alles Lob, und Er hat Macht über alle Dinge. Alles Lob gebührt Allah, und gepriesen sei Allah; es gibt keinen Gott außer Allah; Allah ist der Größte; und es gibt keine Macht (das Böse abzuwenden) noch Kraft (das Gute zu erlangen) außer durch Allah. O Allah, vergib mir.',
    'Er is geen god die aanbidding waard is behalve Allah, alleen, zonder enige deelgenoot. Aan Hem alleen behoren de heerschappij en alle lof, en Hij is tot alle dingen in staat. Alle lof komt Allah toe, en glorie aan Allah; er is geen god behalve Allah; Allah is de Grootste; en er is geen macht (om kwaad af te wenden) noch kracht (om goed te bereiken) behalve door Allah. O Allah, vergeef mij.',
    'Allah''tan başka ibadete layık ilah yoktur; O tektir, hiçbir ortağı yoktur. Mülk yalnız O''nundur, hamd yalnız O''nadır ve O her şeye kâdirdir. Hamd Allah''a mahsustur, Allah''ı tenzih ederim; Allah''tan başka ilah yoktur; Allah en büyüktür; (kötülükten kaçınmak için) güç, (iyiliğe ulaşmak için) kuvvet ancak Allah iledir. Allah''ım, beni bağışla.',
    'Tidak ada tuhan yang berhak disembah selain Allah semata, tiada sekutu bagi-Nya. Milik-Nya seluruh kerajaan dan segala pujian, dan Dia Mahakuasa atas segala sesuatu. Segala puji bagi Allah, Maha Suci Allah; tidak ada tuhan selain Allah; Allah Maha Besar; tidak ada daya (untuk menghindari keburukan) dan kekuatan (untuk meraih kebaikan) kecuali dengan (pertolongan) Allah. Ya Allah, ampunilah aku.',
    'اللہ کے سوا کوئی معبودِ برحق نہیں، وہ اکیلا ہے، اس کا کوئی شریک نہیں۔ اسی کے لیے بادشاہی ہے اور اسی کے لیے ہر تعریف ہے، اور وہ ہر چیز پر قادر ہے۔ تمام تعریفیں اللہ کے لیے ہیں، اور اللہ پاک ہے؛ اللہ کے سوا کوئی معبود نہیں؛ اللہ سب سے بڑا ہے؛ اور (برائی سے بچنے کی) کوئی طاقت اور (بھلائی پانے کی) کوئی قوت نہیں مگر اللہ کی مدد سے۔ اے اللہ! مجھے بخش دے۔',
    'আল্লাহ ছাড়া ইবাদতের যোগ্য কোনো উপাস্য নেই, তিনি একক, তাঁর কোনো শরিক নেই। সমস্ত রাজত্ব তাঁরই এবং সমস্ত প্রশংসা তাঁরই, আর তিনি সর্ববিষয়ে ক্ষমতাবান। সমস্ত প্রশংসা আল্লাহর, আল্লাহ পবিত্র; আল্লাহ ছাড়া কোনো উপাস্য নেই; আল্লাহ সর্বশ্রেষ্ঠ; আর (অনিষ্ট রোধের) কোনো শক্তি ও (কল্যাণ লাভের) কোনো ক্ষমতা নেই আল্লাহর সাহায্য ছাড়া। হে আল্লাহ! আমাকে ক্ষমা করো।',
    'Tiada tuhan yang berhak disembah melainkan Allah semata-mata, tiada sekutu bagi-Nya. Bagi-Nya segala kerajaan dan bagi-Nya segala pujian, dan Dia Maha Berkuasa atas segala sesuatu. Segala puji bagi Allah, Maha Suci Allah; tiada tuhan melainkan Allah; Allah Maha Besar; dan tiada daya (untuk mengelak keburukan) dan kekuatan (untuk mencapai kebaikan) melainkan dengan (pertolongan) Allah. Ya Allah, ampunilah aku.',
    'Нет божества, достойного поклонения, кроме Аллаха, Единственного, у Которого нет сотоварищей. Ему принадлежит вся власть и вся хвала, и Он способен на всякую вещь. Хвала Аллаху, и пречист Аллах; нет божества, кроме Аллаха; Аллах велик; и нет ни силы (чтобы отвратить зло), ни мощи (чтобы обрести благо), кроме как с (помощью) Аллаха. О Аллах, прости меня.',
    'When waking up at night', 'En se réveillant la nuit', 'عند الاستيقاظ من الليل',
    'Beim Aufwachen in der Nacht', 'Bij het ontwaken in de nacht',
    'Gece uyanınca', 'Ketika bangun di malam hari',
    'Ketika terjaga pada waktu malam', 'رات کو بیدار ہونے پر',
    'রাতে জেগে উঠলে', 'При пробуждении ночью',
    'Bukhārī 1154', 'Bukhārī 1154', 'صحيح البخاري ١١٥٤',
    1::smallint, 5::smallint
  ),
  -- ══════════════════════════ 3. After waking up #1 ═════════════════════════
  (
    'اَلْحَمْدُ لِلّٰهِ الَّذِيْ عَافَانِيْ فِيْ جَسَدِيْ ، وَرَدَّ عَليَّ رُوْحِيْ ، وَأَذِنَ لِييْ بِذِكْرِهِ.',
    'Alḥamdu li-llāhi-l-ladhī ʿāfānī fī jasadī, wa radda ʿalayya rūḥī, wa adhina lī bi dhikrih.',
    'All praise is for Allah Who granted me well-being in my body, and returned my soul to me and allowed me to remember Him.',
    'Louange à Allah qui m''a accordé la santé dans mon corps, m''a rendu mon âme et m''a permis de L''évoquer.',
    'Alles Lob gebührt Allah, der mir Wohlergehen in meinem Körper gewährt, mir meine Seele zurückgegeben und mir erlaubt hat, Seiner zu gedenken.',
    'Alle lof komt Allah toe, Die mij welzijn in mijn lichaam heeft geschonken, mijn ziel aan mij heeft teruggegeven en mij heeft toegestaan Hem te gedenken.',
    'Hamd, bedenime afiyet veren, ruhumu bana geri döndüren ve kendisini anmama izin veren Allah''a mahsustur.',
    'Segala puji bagi Allah yang telah memberikan kesehatan pada tubuhku, mengembalikan ruhku kepadaku, dan mengizinkanku untuk mengingat-Nya.',
    'تمام تعریفیں اس اللہ کے لیے ہیں جس نے میرے جسم کو عافیت دی، میری روح مجھے لوٹائی اور مجھے اپنے ذکر کی اجازت دی۔',
    'সমস্ত প্রশংসা সেই আল্লাহর জন্য যিনি আমার শরীরে সুস্থতা দান করেছেন, আমার রুহ আমাকে ফিরিয়ে দিয়েছেন এবং আমাকে তাঁর স্মরণের অনুমতি দিয়েছেন।',
    'Segala puji bagi Allah yang telah memberi kesihatan pada tubuhku, mengembalikan rohku kepadaku, dan mengizinkanku untuk mengingati-Nya.',
    'Хвала Аллаху, Который даровал благополучие моему телу, вернул мне мою душу и позволил мне поминать Его.',
    'Upon waking up', 'Au réveil', 'عند الاستيقاظ من النوم',
    'Beim Aufwachen', 'Bij het ontwaken',
    'Uyanınca', 'Ketika bangun tidur',
    'Ketika bangun tidur', 'بیدار ہونے پر',
    'ঘুম থেকে জেগে উঠে', 'После пробуждения',
    'Tirmidhī 3401', 'Tirmidhī 3401', 'سنن الترمذي ٣٤٠١',
    1::smallint, 5::smallint
  ),
  -- ══════════════════════════ 4. After waking up #2 ═════════════════════════
  (
    'اَلْحَمْدُ لِلّٰهِ الَّذِيْ أَحْيَانَا بَعْدَ مَا أَمَاتَنَا وَإِلَيْهِ النُّشُوْرُ',
    'Alḥamdu li-llāhi-l-ladhī aḥyānā baʿda mā amātanā wa ilayhi-n-nushūr.',
    'All praise is for Allah who gave us life after having taken it from us, and unto Him is the resurrection.',
    'Louange à Allah qui nous a rendu la vie après nous l''avoir ôtée, et c''est vers Lui qu''est la résurrection.',
    'Alles Lob gebührt Allah, der uns das Leben gegeben hat, nachdem Er uns hatte sterben lassen, und zu Ihm ist die Auferstehung.',
    'Alle lof komt Allah toe, Die ons het leven heeft gegeven nadat Hij ons had doen sterven, en tot Hem is de opstanding.',
    'Hamd, bizi öldürdükten sonra dirilten Allah''a mahsustur; dönüş de ancak O''nadır.',
    'Segala puji bagi Allah yang telah menghidupkan kami setelah mematikan kami, dan kepada-Nyalah tempat kembali (kebangkitan).',
    'تمام تعریفیں اس اللہ کے لیے ہیں جس نے ہمیں مارنے کے بعد زندہ کیا، اور اسی کی طرف اٹھ کر جانا ہے۔',
    'সমস্ত প্রশংসা সেই আল্লাহর জন্য যিনি আমাদের মৃত্যুর পর জীবিত করেছেন, আর তাঁরই দিকে পুনরুত্থান।',
    'Segala puji bagi Allah yang telah menghidupkan kami setelah mematikan kami, dan kepada-Nyalah tempat kembali (kebangkitan).',
    'Хвала Аллаху, Который оживил нас после того, как умертвил, и к Нему — воскрешение.',
    'Upon waking up', 'Au réveil', 'عند الاستيقاظ من النوم',
    'Beim Aufwachen', 'Bij het ontwaken',
    'Uyanınca', 'Ketika bangun tidur',
    'Ketika bangun tidur', 'بیدار ہونے پر',
    'ঘুম থেকে জেগে উঠে', 'После пробуждения',
    'Bukhārī 6325', 'Bukhārī 6325', 'صحيح البخاري ٦٣٢٥',
    1::smallint, 5::smallint
  ),
  -- ════════════════ 5. Last 10 ayat of Sūrah Āl ʿImrān (3:190-200) ══════════
  (
    'إِنَّ فِىْ خَلْقِ السَّمـٰوٰتِ وَالْأَرْضِ وَاخْتِلٰـفِ الَّيْلِ وَالنَّهَارِ لاٰيٰاتٍ لِّأُولِى الْأَلْبَـٰبِ. الَّذِيْنَ يَذْكُرُوْنَ اللّٰهَ قِيَـٰمًا وَّقُعُوْدًا وَّعَلَىٰ جُنُوْبِهِمْ وَيَتَفَكَّرُوْنَ فِىْ خَلْقِ السَّمـٰوٰتِ وَالْأَرْضِ ، رَبَّنَا مَا خَلَقْتَ هَـٰذَا بٰطِلًا ، سُبْحٰنَكَ فَقِنَا عَذَابَ النَّارِ. رَبَّنَآ إِنَّكَ مَنْ تُدْخِلِ النَّارَ فَقَدْ أَخْزَيْتَهُۥ ۖ ، وَمَا لِلظّـٰلِمِيْنَ مِنْ أَنصَارٍ. رَبَّنَآ إِنَّنَا سَمِعْنَا مُنَادِيًا يُّنَادِىْ لِلْإِيْمَـٰنِ أَنْ اٰمِنُوْا بِرَبِّكُمْ فَاٰمَنَّا ۚ ، رَبَّنَا فَاغْفِرْ لَنَا ذُنُوْبَنَا وَكَفِّرْ عَنَّا سَيِّـاٰتِنَا وَتَوَفَّنَا مَعَ الْأَبْرَارِ. رَبَّنَا وَاٰتِنَا مَا وَعَدْتَّنَا عَلَىٰ رُسُلِكَ وَلَا تُخْزِنَا يَوْمَ الْقِيـٰمَةِ ۗ ، إِنَّكَ لَا تُخْلِفُ الْمِيْعَادَ. فَاسْتَجَابَ لَهُمْ رَبُّهُمْ أَنِّىْ لَآ أُضِيْعُ عَمَلَ عَـامِلٍ مِّنْكُمْ مِّنْ ذَكَرٍ أَوْ أُنثَىٰ ۖ ، بَعْضُكُمْ مِّنۢ بَعْضٍ ۖ ، فَالَّذِيْنَ هَاجَرُوْا وَأُخْرِجُوْا مِن دِيَارِهِمْ وَأُوْذُوْا فِىْ سَبِيْلِىْ وَقٰتَلُوْا وَقُتِلُوْا لَأُكَفِّرَنَّ عَنْهُمْ سَيِّاٰتِهِمْ وَلَأُدْخِلَنَّهُمْ جَنَّـٰتٍ تَجْرِىْ مِنْ تَحْتِهَا الْأَنْهٰرُ ، ثَوَابًا مِّنْ عِندِ اللّٰهِ ۗ ، وَاللّٰهُ عِندَهُۥ حُسْنُ الثَّوَابِ. لَا يَغُرَّنَّكَ تَقَلُّبُ الَّذِيْنَ كَفَرُوْا فِىْ الْبِلَـٰدِ ، مَتاَعٌ قَلِيْلٌ ثُمَّ مَأْوٰهُمْ جَهَنَّمُ ۚ وَبِئْسَ الْمِهَادُ. لٰكِنِ الَّذِيْنَ اتَّقَوْا رَبَّهُمْ لَهُمْ جَنَّـٰتٌ تَجْرِىْ مِنْ تَحْتِهَا الْأَنْهٰرُ خٰلِدِيْنَ فِيْهَا نُزُلًا مِّنْ عِنْدِ اللّٰهِ ۗ ، وَمَا عِنْدَ اللّٰهِ خَيْرٌ لِّلْأَبْرَارِ. وَإِنَّ مِنْ أَهْلِ الْكِتٰبِ لَمَنْ يُّؤْمِنُ بِاللّٰهِ وَمَآ أُنْزِلَ إِلَيْكُمْ وَمَآ أُنْزِلَ إِلَيْهِمْ خٰشِعِيْنَ لِلّٰهِ لَا يَشْتَرُوْنَ بِاٰيٰتِ اللّٰهِ ثَمَنًا قَلِيْلًا ۗ ، أُولـٰٓئِكَ لَهُمْ أَجْرُهُمْ عِنْدَ رَبِّهِمْ ۗ ، إِنَّ اللّٰهَ سَرِيْعُ الْحِسَابِ. يَـٰٓأَيُّهَا الَّذِيْنَ اٰمَنُوا اصْبِرُوْا وَصَابِرُوْا وَرَابِطُوْا وَاتَّقُوا اللّٰهَ لَعَلَّكُمْ تُفْلِحُونَ.',
    'Inna fī khalqis samāwāti wa-l-arḍi wa-khtilāfi-l-layli wan-nahāri la āyātil li-uli-l-albāb, Alladhīna yadhkurūnal-lāha qiyāmaw-wa quʿudaw-wa ʿalā junūbihim wa yatafakkarūna fī khalqi-s-samāwāti wa-l-arḍi Rabbanā mā khalaqta hādhā bātilā, Subhānaka faqinā ʿadhāba-n-nār. Rabbāna innaka man tudkhili-n-nāra fa-qad akhzaytah wa mā li-dhālimīnā min anṣār. Rabbanā in-nanā samiʿnā munādiya-y-yunādi lil imāni an āminu bi Rabbikum fa āmannā; Rabbanā faghfir lanā dhunūbanā wa-kaffir ʿannā sayyi''ātinā wa tawaffanā maʿal abrār. Rabbanā wa ātinā mā wa''dattanā ʿalā rusulika wa lā tukhzinā Yawmal Qiyāmah; innaka lā tukhliful miʿād. Fastajāba lahum Rabbuhum annī lā udīu ʿamala ʿāmili-m-minkum min dhakariw-w-unthā ba''dhukum min ba''dhin fal-l-adhīna hājaru wa ukhrijū min diyārihim wa ūdhū fī sabīlī wa qātalu wa qutilū la-ukaffiranna ʿanhum sayyi''ātihim wa la-udkhilannahum Jannātin tajrī min taḥtiha-l-anhāru thawābam min ʿindi-l-lāh; wallāhu ʿindahu ḥusnu-th-thawāb. Lā yaghurrannaka taqal-lubul ladhīna kafarū fi-l-bilād. Matāʿun qalīl; thumma ma''wāhum Jahannam; wa bi''sa-l-mihād. Lākini-l-ladhīna-t-taqaw Rabbahum lahum Jannātun tajrī min tahtiha-l-anāru khālidīna fīhā nuzulam-min ʿindil lāh, wa mā ʿindal lāhi khayrul-lil-abrār. Wa inna min Ahli-l-Kitābi lamay-y-yu''minu billāhi wa mā unzila ilaykum wa mā unzila ilayhim khāshiʿeena lillāhi lā yashtaroona bi Āyātil lāhi samanan qaleelaa; ulā''ika lahum ajruhum ʿinda Rabbihim; inna-l-lāha sarīʿul hisāb. Yā-ayyuha-l-ladhīna āmanu-ṣbirū wa ṣābirū wa rābiṭū wa-t-taqul-lāha laʿallakum tufliḥūn.',
    'Indeed, in the creation of the heavens and the earth and the alternation of the day and night there are signs for people of reason. (3:190) (They are) those who remember Allah while standing, sitting, and lying on their sides, and reflect on the creation of the heavens and the earth (and pray), “Our Lord! You have not created (all of) this without purpose. Glory be to You! Protect us from the torment of the Fire. (3:191) Our Lord! Indeed, those You commit to the Fire will be (completely) disgraced! And the wrongdoers will have no helpers. (3:192) Our Lord! We have heard the caller to (true) belief, (proclaiming,) ‘Believe in your Lord (alone),’ so we believed. Our Lord! Forgive our sins, absolve us of our misdeeds, and allow us each to die as one of the virtuous. (3:193) Our Lord! Grant us what You have promised us through Your messengers and do not put us to shame on Judgment Day—for certainly You never fail in Your promise.” (3:194) So their Lord responded to them: “I will never deny any of you—male or female—the reward of your deeds. Both are equal in reward. Those who migrated or were expelled from their homes, and were persecuted for My sake and fought and (some) were martyred—I will certainly forgive their sins and admit them into Gardens under which rivers flow, as a reward from Allah. And with Allah is the finest reward!” (3:195) Do not be deceived by the prosperity of the disbelievers throughout the land. (3:196) It is only a brief enjoyment. Then Hell will be their home—what an evil place to rest! (3:197) But those who are mindful of their Lord will be in Gardens under which rivers flow, to stay there forever—as an accommodation from Allah. And what is with Allah is best for the virtuous. (3:198) Indeed, there are some among the People of the Book who truly believe in Allah and what has been revealed to you and what was revealed to them. They humble themselves before Allah—never trading Allah’s revelations for a fleeting gain. Their reward is with their Lord. Surely Allah is swift in reckoning. (3:199) O believers! Patiently endure, persevere, stand on guard, and be mindful of Allah, so you may be successful. (3:200)',
    'Certes, dans la création des cieux et de la terre, et dans l''alternance de la nuit et du jour, il y a des signes pour les doués d''intelligence. (3:190) Ceux qui évoquent Allah debout, assis et couchés sur leurs côtés, et qui méditent sur la création des cieux et de la terre (disent) : « Notre Seigneur, Tu n''as pas créé cela en vain. Gloire et pureté à Toi ! Préserve-nous du châtiment du Feu. (3:191) Notre Seigneur, quiconque Tu fais entrer dans le Feu, Tu l''as certes couvert d''ignominie, et les injustes n''auront aucun secoureur. (3:192) Notre Seigneur, nous avons entendu un appel qui invitait à la foi : « Croyez en votre Seigneur », et nous avons cru. Notre Seigneur, pardonne-nous nos péchés, efface nos méfaits et fais-nous mourir parmi les vertueux. (3:193) Notre Seigneur, accorde-nous ce que Tu nous as promis par Tes messagers, et ne nous couvre pas d''ignominie le Jour de la Résurrection. Certes, Tu ne manques jamais à Ta promesse. » (3:194) Leur Seigneur les a exaucés : « Je ne laisse pas perdre l''œuvre de quiconque parmi vous œuvre, homme ou femme : vous procédez les uns des autres. Ceux qui ont émigré, qui ont été expulsés de leurs demeures, qui ont été persécutés dans Mon chemin, qui ont combattu et qui ont été tués, J''effacerai certes leurs méfaits et les ferai entrer dans des Jardins sous lesquels coulent les rivières, en récompense de la part d''Allah. » Et c''est auprès d''Allah qu''est la plus belle récompense. (3:195) Que ne t''abuse point la liberté d''action des mécréants à travers le pays. (3:196) Éphémère jouissance ! Puis leur refuge sera l''Enfer ; et quelle détestable couche ! (3:197) Mais ceux qui craignent leur Seigneur auront des Jardins sous lesquels coulent les rivières, pour y demeurer éternellement, comme demeure de la part d''Allah. Et ce qui est auprès d''Allah est meilleur pour les vertueux. (3:198) Il y a certes parmi les gens du Livre ceux qui croient en Allah et en ce qui vous a été révélé et en ce qui leur a été révélé, humbles devant Allah, n''échangeant pas les versets d''Allah contre un vil prix. Ceux-là auront leur récompense auprès de leur Seigneur. Certes Allah est prompt à faire les comptes. (3:199) Ô vous qui croyez ! Soyez endurants, rivalisez d''endurance, soyez vigilants et craignez Allah, afin que vous réussissiez. (3:200)',
    'Wahrlich, in der Erschaffung der Himmel und der Erde und im Wechsel von Nacht und Tag liegen Zeichen für die Einsichtigen. (3:190) Diejenigen, die Allahs gedenken im Stehen, im Sitzen und auf ihren Seiten (liegend), und die über die Erschaffung der Himmel und der Erde nachdenken (und sagen): „Unser Herr, Du hast (all) dies nicht umsonst erschaffen. Gepriesen seist Du! Bewahre uns vor der Strafe des (Höllen)feuers. (3:191) Unser Herr, wen Du ins (Höllen)feuer eingehen lässt, den hast Du gewiss in Schande gestürzt, und die Ungerechten werden keine Helfer haben. (3:192) Unser Herr, wir haben einen Rufer gehört, der zum Glauben ruft: ‚Glaubt an euren Herrn!‘, und so glaubten wir. Unser Herr, vergib uns unsere Sünden, tilge unsere bösen Taten und lass uns mit den Frommen sterben. (3:193) Unser Herr, gib uns, was Du uns durch Deine Gesandten versprochen hast, und stürze uns nicht in Schande am Tag der Auferstehung. Gewiss, Du brichst das Versprechen nicht. (3:194) Da erhörte sie ihr Herr: „Ich lasse kein Werk eines von euch, der (gut) handelt, verlorengehen, sei es Mann oder Frau; die einen von euch sind von den anderen. Denen, die ausgewandert und aus ihren Wohnstätten vertrieben worden sind und denen auf Meinem Weg Leid zugefügt wurde und die gekämpft haben und getötet worden sind, werde Ich gewiss ihre bösen Taten tilgen und sie gewiss in Gärten eingehen lassen, durcheilt von Bächen, als Belohnung von Allah. Und Allah – bei Ihm ist die schöne Belohnung. (3:195) Lass dich nicht durch das Umherziehen derer, die ungläubig sind, in den Landen täuschen. (3:196) Ein geringer Genuss; hierauf wird die Hölle ihre Zuflucht sein – ein schlimmes Lager! (3:197) Aber für diejenigen, die ihren Herrn fürchten, wird es Gärten geben, durcheilt von Bächen, ewig darin zu bleiben, als Aufenthalt von Allah. Und was bei Allah ist, ist besser für die Frommen. (3:198) Und unter den Leuten der Schrift gibt es wahrlich manche, die an Allah glauben und an das, was zu euch herabgesandt worden ist, und an das, was zu ihnen herabgesandt worden ist, voll Demut gegenüber Allah, und die die Zeichen Allahs nicht für einen geringen Preis verkaufen. Jene haben ihren Lohn bei ihrem Herrn. Gewiss, Allah ist schnell im Abrechnen. (3:199) O die ihr glaubt, seid standhaft, wetteifert in Standhaftigkeit, haltet stand und fürchtet Allah, auf dass es euch wohl ergehen möge! (3:200)',
    'Voorwaar, in de schepping van de hemelen en de aarde en in de afwisseling van nacht en dag zijn er tekenen voor mensen met verstand. (3:190) Degenen die Allah gedenken, staand, zittend en (liggend) op hun zij, en die nadenken over de schepping van de hemelen en de aarde (zeggen): „Onze Heer, U hebt dit niet voor niets geschapen. Glorie aan U! Bescherm ons tegen de bestraffing van het Vuur. (3:191) Onze Heer, voorwaar, wie U het Vuur doet binnengaan, die hebt U waarlijk vernederd, en voor de onrechtplegers zijn er geen helpers. (3:192) Onze Heer, voorwaar, wij hebben een oproeper horen oproepen tot het geloof: ‚Gelooft in jullie Heer‘, en wij geloofden. Onze Heer, vergeef ons onze zonden en wis onze slechte daden uit en neem ons (de dood) tot U met de vromen. (3:193) Onze Heer, schenk ons wat U ons door Uw boodschappers hebt beloofd en verneder ons niet op de Dag der Opstanding. Voorwaar, U verbreekt de belofte niet. (3:194) Hun Heer verhoorde hen toen: „Voorwaar, Ik doe het werk van een werker onder jullie, man of vrouw, niet verloren gaan; jullie komen uit elkaar voort. Degenen die emigreerden en uit hun woningen verdreven werden en op Mijn weg gekweld werden en streden en gedood werden, voor hen zal Ik zeker hun slechte daden uitwissen en hen zeker Tuinen doen binnengaan waar de rivieren onder door stromen, als een beloning van Allah. En bij Allah is de beste beloning. (3:195) Laat je niet bedriegen door het heen en weer trekken van degenen die ongelovig zijn in het land. (3:196) Een kort genot; daarna is hun verblijfplaats de Hel, en dat is de slechtste rustplaats! (3:197) Maar voor degenen die hun Heer vrezen zijn er Tuinen waar de rivieren onder door stromen, daarin eeuwig levend, als een onthaal van Allah. En wat bij Allah is, is beter voor de vromen. (3:198) En voorwaar, onder de Lieden van het Boek zijn er zeker die in Allah geloven en in wat aan jullie is neergezonden en in wat aan hen is neergezonden, nederig tegenover Allah; zij verruilen de Verzen van Allah niet voor een geringe prijs. Zij zijn degenen voor wie er een beloning is bij hun Heer. Voorwaar, Allah is snel in de afrekening. (3:199) O jullie die geloven, weest geduldig en weest standvastig en weest waakzaam en vreest Allah. Hopelijk zullen jullie welslagen. (3:200)',
    'Şüphesiz göklerin ve yerin yaratılışında, gece ile gündüzün birbiri ardınca gelişinde akıl sahipleri için ayetler vardır. (3:190) Onlar ayakta, otururken ve yanları üzerine (yatarken) Allah''ı anarlar ve göklerin ve yerin yaratılışı üzerinde düşünürler: „Rabbimiz! Sen bunu boş yere yaratmadın. Seni tenzih ederiz. Bizi ateşin azabından koru. (3:191) Rabbimiz! Şüphesiz Sen kimi ateşe sokarsan onu rezil etmişsindir; zalimlerin hiçbir yardımcısı yoktur. (3:192) Rabbimiz! Biz, ‚Rabbinize iman edin‘ diye imana çağıran bir davetçiyi işittik ve hemen iman ettik. Rabbimiz! Günahlarımızı bağışla, kötülüklerimizi ört ve canımızı iyilerle beraber al. (3:193) Rabbimiz! Peygamberlerin aracılığıyla bize vaat ettiğini ver ve kıyamet günü bizi rezil etme. Şüphesiz Sen sözünden dönmezsin. (3:194) Rableri onlara şöyle karşılık verdi: „Ben, erkek olsun kadın olsun, sizden çalışan hiç kimsenin amelini boşa çıkarmam; siz birbirinizdensiniz. Hicret edenlerin, yurtlarından çıkarılanların, Benim yolumda eziyet görenlerin, savaşanların ve öldürülenlerin, andolsun ki kötülüklerini örteceğim ve onları, Allah katından bir mükâfat olarak, altlarından ırmaklar akan cennetlere koyacağım. Mükâfatın en güzeli Allah katındadır. (3:195) İnkâr edenlerin diyar diyar dolaşması seni aldatmasın. (3:196) Az bir yararlanmadır; sonra varacakları yer cehennemdir. Ne kötü bir yataktır o! (3:197) Fakat Rablerine karşı gelmekten sakınanlar için, içinde ebedî kalacakları, Allah katından bir konaklama yeri olarak, altlarından ırmaklar akan cennetler vardır. Allah katındaki ise iyiler için daha hayırlıdır. (3:198) Şüphesiz Kitap ehlinden öyleleri vardır ki, Allah''a, size indirilene ve kendilerine indirilene, Allah''a huşû duyarak iman ederler; Allah''ın ayetlerini az bir bedelle değişmezler. İşte onların, Rableri katında mükâfatları vardır. Şüphesiz Allah hesabı çabuk görendir. (3:199) Ey iman edenler! Sabredin, sabır yarışında düşmanlarınızı geçin, (cihad için) hazır ve bağlı olun ve Allah''a karşı gelmekten sakının ki kurtuluşa eresiniz. (3:200)',
    'Sesungguhnya pada penciptaan langit dan bumi serta silih bergantinya malam dan siang terdapat tanda-tanda bagi orang-orang yang berakal. (3:190) (Yaitu) orang-orang yang mengingat Allah sambil berdiri, duduk, dan dalam keadaan berbaring, dan mereka memikirkan tentang penciptaan langit dan bumi (seraya berkata), „Ya Tuhan kami, tidaklah Engkau menciptakan ini dengan sia-sia. Maha Suci Engkau, maka peliharalah kami dari azab neraka. (3:191) Ya Tuhan kami, sesungguhnya siapa yang Engkau masukkan ke dalam neraka, sungguh telah Engkau hinakan dia, dan tidak ada seorang penolong pun bagi orang-orang yang zalim. (3:192) Ya Tuhan kami, sesungguhnya kami telah mendengar seorang penyeru yang menyeru kepada iman, ‚Berimanlah kamu kepada Tuhanmu‘, maka kami pun beriman. Ya Tuhan kami, ampunilah dosa-dosa kami, hapuskanlah kesalahan-kesalahan kami, dan matikanlah kami beserta orang-orang yang berbakti. (3:193) Ya Tuhan kami, berilah kami apa yang telah Engkau janjikan kepada kami melalui rasul-rasul-Mu, dan janganlah Engkau hinakan kami pada hari Kiamat. Sungguh, Engkau tidak pernah mengingkari janji. (3:194) Maka Tuhan mereka memperkenankan permohonan mereka (dengan berfirman), „Sesungguhnya Aku tidak menyia-nyiakan amal orang yang beramal di antara kamu, baik laki-laki maupun perempuan; sebagian kamu adalah (keturunan) dari sebagian yang lain. Maka orang-orang yang berhijrah, yang diusir dari kampung halamannya, yang disakiti di jalan-Ku, yang berperang, dan yang terbunuh, pasti akan Aku hapus kesalahan-kesalahan mereka dan pasti Aku masukkan mereka ke dalam surga yang mengalir di bawahnya sungai-sungai, sebagai pahala dari sisi Allah. Dan di sisi Allah ada pahala yang terbaik. (3:195) Janganlah sekali-kali kamu terperdaya oleh kebebasan orang-orang kafir bergerak di seluruh negeri. (3:196) Itu hanyalah kesenangan sementara, kemudian tempat kembali mereka ialah Jahanam, dan itulah seburuk-buruk tempat tinggal. (3:197) Tetapi orang-orang yang bertakwa kepada Tuhannya, mereka mendapat surga yang mengalir di bawahnya sungai-sungai, mereka kekal di dalamnya sebagai karunia dari sisi Allah. Dan apa yang di sisi Allah lebih baik bagi orang-orang yang berbakti. (3:198) Dan sesungguhnya di antara Ahli Kitab ada orang yang beriman kepada Allah dan kepada apa yang diturunkan kepadamu dan yang diturunkan kepada mereka, sedang mereka berendah hati kepada Allah, dan mereka tidak menukar ayat-ayat Allah dengan harga yang murah. Mereka itu memperoleh pahala di sisi Tuhannya. Sungguh, Allah sangat cepat perhitungan-Nya. (3:199) Wahai orang-orang yang beriman! Bersabarlah kamu dan kuatkanlah kesabaranmu dan tetaplah bersiap-siaga (di perbatasan) dan bertakwalah kepada Allah agar kamu beruntung. (3:200)',
    'بے شک آسمانوں اور زمین کی تخلیق میں اور رات اور دن کے باری باری آنے میں عقل والوں کے لیے نشانیاں ہیں۔ (3:190) جو کھڑے، بیٹھے اور اپنے پہلوؤں پر (لیٹے) اللہ کو یاد کرتے ہیں اور آسمانوں اور زمین کی تخلیق میں غور کرتے ہیں (اور کہتے ہیں): ”اے ہمارے رب! تو نے یہ سب بے مقصد نہیں بنایا۔ تو پاک ہے، پس ہمیں آگ کے عذاب سے بچا۔ (3:191) اے ہمارے رب! بے شک جسے تو آگ میں داخل کرے اسے تو نے رسوا کر دیا، اور ظالموں کا کوئی مددگار نہیں۔ (3:192) اے ہمارے رب! ہم نے ایک پکارنے والے کو سنا جو ایمان کی طرف بلا رہا تھا کہ ’اپنے رب پر ایمان لاؤ‘، تو ہم ایمان لے آئے۔ اے ہمارے رب! ہمارے گناہ بخش دے، ہماری برائیاں مٹا دے اور ہمیں نیکوکاروں کے ساتھ موت دے۔ (3:193) اے ہمارے رب! ہمیں وہ عطا کر جس کا تو نے اپنے رسولوں کے ذریعے ہم سے وعدہ کیا ہے، اور قیامت کے دن ہمیں رسوا نہ کر۔ بے شک تو وعدہ خلافی نہیں کرتا۔“ (3:194) پس ان کے رب نے ان کی دعا قبول کر لی (کہ): ”میں تم میں سے کسی عمل کرنے والے کا عمل ضائع نہیں کرتا، خواہ مرد ہو یا عورت، تم ایک دوسرے سے ہو۔ پس جنہوں نے ہجرت کی، اپنے گھروں سے نکالے گئے، میری راہ میں ستائے گئے، لڑے اور مارے گئے، میں ضرور ان کی برائیاں مٹا دوں گا اور انہیں ایسے باغوں میں داخل کروں گا جن کے نیچے نہریں بہتی ہیں، اللہ کی طرف سے بدلہ۔ اور اللہ ہی کے پاس بہترین بدلہ ہے۔ (3:195) کافروں کا شہروں میں چلنا پھرنا تجھے دھوکے میں نہ ڈالے۔ (3:196) یہ تھوڑا سا فائدہ ہے، پھر ان کا ٹھکانا جہنم ہے، اور وہ بہت برا ٹھکانا ہے۔ (3:197) لیکن جو لوگ اپنے رب سے ڈرتے ہیں ان کے لیے ایسے باغ ہیں جن کے نیچے نہریں بہتی ہیں، وہ ان میں ہمیشہ رہیں گے، اللہ کی طرف سے مہمانی۔ اور جو اللہ کے پاس ہے وہ نیکوکاروں کے لیے بہتر ہے۔ (3:198) اور بے شک اہلِ کتاب میں سے کچھ ایسے بھی ہیں جو اللہ پر ایمان لاتے ہیں اور اس پر جو تمہاری طرف اتارا گیا اور اس پر جو ان کی طرف اتارا گیا، اللہ کے آگے عاجزی کرنے والے، وہ اللہ کی آیتوں کو تھوڑی قیمت پر نہیں بیچتے۔ ان کے لیے ان کے رب کے پاس ان کا اجر ہے۔ بے شک اللہ جلد حساب لینے والا ہے۔ (3:199) اے ایمان والو! صبر کرو، (مقابلے میں) صبر میں بڑھ جاؤ، (سرحدوں پر) مورچہ بند رہو اور اللہ سے ڈرو تاکہ تم کامیاب ہو جاؤ۔ (3:200)',
    'নিশ্চয়ই আসমান ও জমিনের সৃষ্টিতে এবং রাত ও দিনের পরিবর্তনে জ্ঞানবানদের জন্য নিদর্শন রয়েছে। (3:190) যারা দাঁড়িয়ে, বসে ও কাত হয়ে শুয়ে আল্লাহকে স্মরণ করে এবং আসমান ও জমিনের সৃষ্টি নিয়ে চিন্তা করে (এবং বলে): “হে আমাদের রব! তুমি এসব অনর্থক সৃষ্টি করোনি। তুমি পবিত্র, সুতরাং আমাদের জাহান্নামের আযাব থেকে রক্ষা করো। (3:191) হে আমাদের রব! নিশ্চয়ই তুমি যাকে আগুনে প্রবেশ করাবে তাকে তো অপমানিত করলে, আর জালিমদের কোনো সাহায্যকারী নেই। (3:192) হে আমাদের রব! আমরা এক আহ্বানকারীকে শুনেছি যিনি ঈমানের দিকে ডাকছিলেন যে, ‘তোমাদের রবের প্রতি ঈমান আনো’, তাই আমরা ঈমান এনেছি। হে আমাদের রব! আমাদের গুনাহসমূহ মাফ করো, আমাদের মন্দ কাজগুলো মোচন করো এবং আমাদের নেককারদের সাথে মৃত্যু দাও। (3:193) হে আমাদের রব! তোমার রাসূলগণের মাধ্যমে আমাদের কাছে যে প্রতিশ্রুতি দিয়েছ তা আমাদের দান করো এবং কিয়ামতের দিন আমাদের অপমানিত করো না। নিশ্চয়ই তুমি প্রতিশ্রুতি ভঙ্গ করো না। (3:194) অতঃপর তাদের রব তাদের ডাকে সাড়া দিলেন (যে): “নিশ্চয়ই আমি তোমাদের মধ্যে কোনো আমলকারীর আমল বিনষ্ট করি না, সে পুরুষ হোক বা নারী; তোমরা একে অপরের অংশ। সুতরাং যারা হিজরত করেছে, নিজেদের ঘরবাড়ি থেকে বহিষ্কৃত হয়েছে, আমার পথে কষ্ট পেয়েছে, যুদ্ধ করেছে ও নিহত হয়েছে, আমি অবশ্যই তাদের মন্দ কাজগুলো মোচন করব এবং তাদের এমন জান্নাতে প্রবেশ করাব যার নিচ দিয়ে নদী প্রবাহিত, আল্লাহর পক্ষ থেকে প্রতিদান। আর আল্লাহরই কাছে রয়েছে উত্তম প্রতিদান। (3:195) দেশে দেশে কাফিরদের অবাধ বিচরণ যেন তোমাকে ধোঁকায় না ফেলে। (3:196) এ তো সামান্য ভোগমাত্র, অতঃপর তাদের ঠিকানা জাহান্নাম, আর তা কতই না নিকৃষ্ট আবাস! (3:197) কিন্তু যারা তাদের রবকে ভয় করে তাদের জন্য রয়েছে এমন জান্নাত যার নিচ দিয়ে নদী প্রবাহিত, তারা সেখানে চিরকাল থাকবে, আল্লাহর পক্ষ থেকে আতিথেয়তা। আর আল্লাহর কাছে যা আছে তা নেককারদের জন্য উত্তম। (3:198) আর নিশ্চয়ই আহলে কিতাবের মধ্যে এমনও কিছু লোক আছে যারা আল্লাহর প্রতি, তোমাদের প্রতি যা নাযিল হয়েছে এবং তাদের প্রতি যা নাযিল হয়েছে তাতে ঈমান আনে, আল্লাহর প্রতি বিনয়াবনত হয়ে; তারা আল্লাহর আয়াত তুচ্ছ মূল্যে বিক্রি করে না। তাদের জন্য তাদের রবের কাছে রয়েছে তাদের প্রতিদান। নিশ্চয়ই আল্লাহ দ্রুত হিসাব গ্রহণকারী। (3:199) হে ঈমানদারগণ! তোমরা ধৈর্য ধরো, ধৈর্যে অবিচল থাকো, (সীমান্ত পাহারায়) দৃঢ় থাকো এবং আল্লাহকে ভয় করো, যাতে তোমরা সফল হও। (3:200)',
    'Sesungguhnya pada penciptaan langit dan bumi serta pada pertukaran malam dan siang terdapat tanda-tanda bagi orang yang berakal. (3:190) (Iaitu) orang yang mengingati Allah ketika berdiri, duduk dan ketika berbaring, serta memikirkan tentang penciptaan langit dan bumi (sambil berkata): „Wahai Tuhan kami, tidaklah Engkau menciptakan ini dengan sia-sia. Maha Suci Engkau, maka peliharalah kami daripada azab neraka. (3:191) Wahai Tuhan kami, sesungguhnya sesiapa yang Engkau masukkan ke dalam neraka, maka sungguh Engkau telah menghinakannya, dan tiadalah bagi orang-orang zalim sebarang penolong. (3:192) Wahai Tuhan kami, sesungguhnya kami telah mendengar seorang penyeru yang menyeru kepada iman, ‚Berimanlah kamu kepada Tuhan kamu‘, lalu kami pun beriman. Wahai Tuhan kami, ampunkanlah dosa-dosa kami, hapuskanlah kesalahan-kesalahan kami, dan matikanlah kami bersama orang-orang yang berbakti. (3:193) Wahai Tuhan kami, berikanlah kepada kami apa yang telah Engkau janjikan kepada kami melalui rasul-rasul-Mu, dan janganlah Engkau hinakan kami pada hari Kiamat. Sesungguhnya Engkau tidak memungkiri janji. (3:194) Maka Tuhan mereka memperkenankan doa mereka (dengan berfirman): „Sesungguhnya Aku tidak mensia-siakan amal orang yang beramal di antara kamu, sama ada lelaki atau perempuan; sebahagian kamu daripada sebahagian yang lain. Maka orang-orang yang berhijrah, yang diusir dari kampung halaman mereka, yang disakiti pada jalan-Ku, yang berperang dan yang terbunuh, pasti Aku hapuskan kesalahan-kesalahan mereka dan pasti Aku masukkan mereka ke dalam syurga yang mengalir di bawahnya sungai-sungai, sebagai pahala daripada sisi Allah. Dan di sisi Allah jualah pahala yang sebaik-baiknya. (3:195) Janganlah sekali-kali engkau terpedaya oleh kebebasan orang-orang kafir bergerak di dalam negeri. (3:196) Itu hanyalah kesenangan sementara, kemudian tempat kembali mereka ialah neraka Jahanam, dan itulah seburuk-buruk tempat berbaring. (3:197) Tetapi orang-orang yang bertakwa kepada Tuhan mereka, bagi mereka syurga yang mengalir di bawahnya sungai-sungai, mereka kekal di dalamnya, sebagai sambutan daripada sisi Allah. Dan apa yang ada di sisi Allah itu lebih baik bagi orang-orang yang berbakti. (3:198) Dan sesungguhnya di antara Ahli Kitab ada orang yang beriman kepada Allah dan kepada apa yang diturunkan kepada kamu serta apa yang diturunkan kepada mereka, dalam keadaan tunduk khusyuk kepada Allah; mereka tidak menukar ayat-ayat Allah dengan harga yang sedikit. Mereka itu beroleh pahala di sisi Tuhan mereka. Sesungguhnya Allah Amat segera hitungan hisab-Nya. (3:199) Wahai orang-orang yang beriman! Bersabarlah kamu, kuatkanlah kesabaran kamu, dan tetaplah bersiap siaga (di sempadan), serta bertakwalah kepada Allah supaya kamu berjaya. (3:200)',
    'Воистину, в сотворении небес и земли и в смене ночи и дня есть знамения для обладающих разумом. (3:190) Тех, которые поминают Аллаха стоя, сидя и (лёжа) на боку и размышляют о сотворении небес и земли (говоря): „Господь наш! Ты сотворил это не напрасно. Пречист Ты! Защити нас от мучений в Огне. (3:191) Господь наш! Кого Ты ввергнешь в Огонь, того Ты опозорил, и не будет у несправедливых помощников. (3:192) Господь наш! Мы услышали призывающего, который призывал к вере: ‚Уверуйте в вашего Господа‘, и мы уверовали. Господь наш! Прости нам наши грехи, отпусти нам наши прегрешения и упокой нас вместе с благочестивыми. (3:193) Господь наш! Даруй нам то, что Ты обещал нам через Своих посланников, и не позорь нас в День воскресения. Воистину, Ты не нарушаешь обещаний. (3:194) Господь их ответил им: „Я не дам пропасть деяниям, совершённым любым из вас, будь то мужчина или женщина; одни из вас — от других. Тем, которые переселились, были изгнаны из своих жилищ, подверглись мучениям на Моём пути, сражались и были убиты, Я непременно прощу их прегрешения и введу их в сады, под которыми текут реки, в награду от Аллаха. У Аллаха — наилучшая награда. (3:195) Пусть не обольщает тебя свобода действий неверующих на земле. (3:196) Это — недолгое наслаждение, а затем их пристанищем будет Геенна. Как же скверно это ложе! (3:197) Но для тех, которые боятся своего Господа, уготованы сады, под которыми текут реки. Они пребудут там вечно как почётное угощение от Аллаха. А то, что у Аллаха, лучше для благочестивых. (3:198) Воистину, среди людей Писания есть такие, которые веруют в Аллаха и в то, что было ниспослано вам и что было ниспослано им, смиряясь перед Аллахом и не продавая знамения Аллаха за ничтожную цену. Их награда — у их Господа. Воистину, Аллах скор в расчёте. (3:199) О те, которые уверовали! Будьте терпеливы, будьте выдержаннее в терпении, будьте стойки на страже и бойтесь Аллаха, — быть может, вы преуспеете. (3:200)',
    'When waking up at night', 'En se réveillant la nuit', 'عند الاستيقاظ من الليل',
    'Beim Aufwachen in der Nacht', 'Bij het ontwaken in de nacht',
    'Gece uyanınca', 'Ketika bangun di malam hari',
    'Ketika terjaga pada waktu malam', 'رات کو بیدار ہونے پر',
    'রাতে জেগে উঠলে', 'При пробуждении ночью',
    'Bukhārī 183', 'Bukhārī 183', 'صحيح البخاري ١٨٣',
    1::smallint, 10::smallint
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
where s.title_en = 'Waking up'
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
  and s.title_en = 'Waking up';

-- 4c) Reference for Latin-script languages: collection names stay romanised
-- (none of these references contain the word "Qur'an", so this is a verbatim copy).
update public.adhkars a
set
  reference_de = a.reference_en,
  reference_nl = a.reference_en,
  reference_tr = a.reference_en,
  reference_id = a.reference_en,
  reference_ms = a.reference_en
from public.adhkar_subcategories s
where a.adhkar_subcategory_id = s.id
  and s.title_en = 'Waking up';

-- 4d) Native-script transliteration + reference for ur / bn / ru, keyed by the
-- (unique) English reference of each adhkar. Hadith/verse numbers are kept in
-- Western digits for consistency with the app's reference display.
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
  -- 1. When changing sides at night
  ('Nasā''ī al-Kubrā 10700',
   'لَا اِلٰہَ اِلَّا اللہُ الْوَاحِدُ الْقَھَّار، رَبُّ السَّمٰوٰتِ وَالْاَرْضِ وَمَا بَیْنَھُمَا الْعَزِیْزُ الْغَفَّار۔',
   'লা ইলাহা ইল্লাল্লাহুল ওয়াহিদুল কাহহার, রাব্বুস সামাওয়াতি ওয়াল আরদি ওয়ামা বাইনাহুমাল আযীযুল গাফফার।',
   'Ля иляха илля-Ллаху-ль-Вахиду-ль-Каххар, Раббу-с-самавати ва-ль-арды ва ма байнахума-ль-’Азизу-ль-Гаффар.',
   'نسائی، السنن الکبریٰ 10700', 'নাসায়ী, আস-সুনানুল কুবরা 10700', 'ан-Насаи, ас-Сунан аль-Кубра 10700'),
  -- 2. When one wakes up at night
  ('Bukhārī 1154',
   'لَا اِلٰہَ اِلَّا اللہُ وَحْدَہٗ لَا شَرِیْکَ لَہٗ، لَہُ الْمُلْکُ وَلَہُ الْحَمْد، وَھُوَ عَلٰی کُلِّ شَیْءٍ قَدِیْر، اَلْحَمْدُ لِلہ، وَسُبْحَانَ اللہ، وَلَا اِلٰہَ اِلَّا اللہ، وَاللہُ اَکْبَر، وَلَا حَوْلَ وَلَا قُوَّۃَ اِلَّا بِاللہ، اَللّٰھُمَّ اغْفِرْ لِیْ۔',
   'লা ইলাহা ইল্লাল্লাহু ওয়াহদাহূ লা শারীকা লাহ, লাহুল মুলকু ওয়া লাহুল হামদ, ওয়া হুওয়া আলা কুল্লি শাইইন কাদীর, আলহামদু লিল্লাহ, ওয়া সুবহানাল্লাহ, ওয়ালা ইলাহা ইল্লাল্লাহ, ওয়াল্লাহু আকবার, ওয়ালা হাওলা ওয়ালা কুওয়াতা ইল্লা বিল্লাহ, আল্লাহুম্মাগফির লী।',
   'Ля иляха илля-Ллаху вахдаху ля шарика лях, ляху-ль-мульку ва ляху-ль-хамд, ва Хува ’аля кулли шайъин Кадир, аль-хамду ли-Ллях, ва субхана-Ллах, ва ля иляха илля-Ллах, ва-Ллаху акбар, ва ля хауля ва ля куввата илля би-Ллях, Аллахумма-гфир ли.',
   'صحیح بخاری 1154', 'সহীহ বুখারী 1154', 'Сахих аль-Бухари 1154'),
  -- 3. After waking up #1
  ('Tirmidhī 3401',
   'اَلْحَمْدُ لِلہِ الَّذِیْ عَافَانِیْ فِیْ جَسَدِیْ، وَرَدَّ عَلَیَّ رُوْحِیْ، وَاَذِنَ لِیْ بِذِکْرِہٖ۔',
   'আলহামদু লিল্লাহিল্লাযী আফানী ফী জাসাদী, ওয়া রাদ্দা আলাইয়া রূহী, ওয়া আযিনা লী বিযিকরিহ।',
   'Аль-хамду ли-Лляхи-ллязи ’афани фи джасади, ва радда ’аляйя рухи, ва азина ли би зикрих.',
   'ترمذی 3401', 'তিরমিযী 3401', 'ат-Тирмизи 3401'),
  -- 4. After waking up #2
  ('Bukhārī 6325',
   'اَلْحَمْدُ لِلہِ الَّذِیْۤ اَحْیَانَا بَعْدَ مَاۤ اَمَاتَنَا وَاِلَیْہِ النُّشُوْر۔',
   'আলহামদু লিল্লাহিল্লাযী আহইয়ানা বা’দা মা আমাতানা ওয়া ইলাইহিন নুশূর।',
   'Аль-хамду ли-Лляхи-ллязи ахьяна ба’да ма аматана ва иляйхи-н-нушур.',
   'صحیح بخاری 6325', 'সহীহ বুখারী 6325', 'Сахих аль-Бухари 6325'),
  -- 5. Last 10 ayat of Al-Imran (3:190-200)
  ('Bukhārī 183',
   'اِنَّ فِیْ خَلْقِ السَّمٰوٰتِ وَالْاَرْضِ وَاخْتِلَافِ الَّیْلِ وَالنَّھَارِ لَاٰیٰتٍ لِّاُولِی الْاَلْبَاب۔ اَلَّذِیْنَ یَذْکُرُوْنَ اللہَ قِیَامًا وَّقُعُوْدًا وَّعَلٰی جُنُوْبِھِمْ وَیَتَفَکَّرُوْنَ فِیْ خَلْقِ السَّمٰوٰتِ وَالْاَرْض، رَبَّنَا مَا خَلَقْتَ ھٰذَا بَاطِلًا، سُبْحٰنَکَ فَقِنَا عَذَابَ النَّار۔ رَبَّنَاۤ اِنَّکَ مَنْ تُدْخِلِ النَّارَ فَقَدْ اَخْزَیْتَہٗ، وَمَا لِلظّٰلِمِیْنَ مِنْ اَنْصَار۔ رَبَّنَاۤ اِنَّنَا سَمِعْنَا مُنَادِیًا یُّنَادِیْ لِلْاِیْمَانِ اَنْ اٰمِنُوْا بِرَبِّکُمْ فَاٰمَنَّا، رَبَّنَا فَاغْفِرْ لَنَا ذُنُوْبَنَا وَکَفِّرْ عَنَّا سَیِّاٰتِنَا وَتَوَفَّنَا مَعَ الْاَبْرَار۔ رَبَّنَا وَاٰتِنَا مَا وَعَدْتَّنَا عَلٰی رُسُلِکَ وَلَا تُخْزِنَا یَوْمَ الْقِیٰمَۃ، اِنَّکَ لَا تُخْلِفُ الْمِیْعَاد۔ فَاسْتَجَابَ لَھُمْ رَبُّھُمْ اَنِّیْ لَاۤ اُضِیْعُ عَمَلَ عَامِلٍ مِّنْکُمْ مِّنْ ذَکَرٍ اَوْ اُنْثٰی، بَعْضُکُمْ مِّنْۢ بَعْض، فَالَّذِیْنَ ھَاجَرُوْا وَاُخْرِجُوْا مِنْ دِیَارِھِمْ وَاُوْذُوْا فِیْ سَبِیْلِیْ وَقَاتَلُوْا وَقُتِلُوْا لَاُکَفِّرَنَّ عَنْھُمْ سَیِّاٰتِھِمْ وَلَاُدْخِلَنَّھُمْ جَنّٰتٍ تَجْرِیْ مِنْ تَحْتِھَا الْاَنْھٰر، ثَوَابًا مِّنْ عِنْدِ اللہ، وَاللہُ عِنْدَہٗ حُسْنُ الثَّوَاب۔ لَا یَغُرَّنَّکَ تَقَلُّبُ الَّذِیْنَ کَفَرُوْا فِی الْبِلَاد۔ مَتَاعٌ قَلِیْل، ثُمَّ مَاْوٰھُمْ جَھَنَّم، وَبِئْسَ الْمِھَاد۔ لٰکِنِ الَّذِیْنَ اتَّقَوْا رَبَّھُمْ لَھُمْ جَنّٰتٌ تَجْرِیْ مِنْ تَحْتِھَا الْاَنْھٰرُ خٰلِدِیْنَ فِیْھَا نُزُلًا مِّنْ عِنْدِ اللہ، وَمَا عِنْدَ اللہِ خَیْرٌ لِّلْاَبْرَار۔ وَاِنَّ مِنْ اَھْلِ الْکِتٰبِ لَمَنْ یُّؤْمِنُ بِاللہِ وَمَاۤ اُنْزِلَ اِلَیْکُمْ وَمَاۤ اُنْزِلَ اِلَیْھِمْ خٰشِعِیْنَ لِلہِ لَا یَشْتَرُوْنَ بِاٰیٰتِ اللہِ ثَمَنًا قَلِیْلًا، اُولٰٓئِکَ لَھُمْ اَجْرُھُمْ عِنْدَ رَبِّھِمْ، اِنَّ اللہَ سَرِیْعُ الْحِسَاب۔ یٰۤاَیُّھَا الَّذِیْنَ اٰمَنُوا اصْبِرُوْا وَصَابِرُوْا وَرَابِطُوْا وَاتَّقُوا اللہَ لَعَلَّکُمْ تُفْلِحُوْن۔',
   'ইন্না ফী খালকিস সামাওয়াতি ওয়াল আরদি ওয়াখতিলাফিল লাইলি ওয়ান নাহারি লা আয়াতিল লিউলিল আলবাব। আল্লাযীনা ইয়াযকুরূনাল্লাহা কিয়ামাঁও ওয়া কুঊদাঁও ওয়া আলা জুনূবিহিম ওয়া ইয়াতাফাক্কারূনা ফী খালকিস সামাওয়াতি ওয়াল আরদ, রাব্বানা মা খালাকতা হাযা বাতিলা, সুবহানাকা ফাকিনা আযাবান নার। রাব্বানা ইন্নাকা মান তুদখিলিন নারা ফাকাদ আখযাইতাহ, ওয়ামা লিজ্জালিমীনা মিন আনসার। রাব্বানা ইন্নানা সামি’না মুনাদিইয়াঁই ইউনাদী লিল ঈমানি আন আমিনূ বিরাব্বিকুম ফাআমান্না, রাব্বানা ফাগফির লানা যুনূবানা ওয়া কাফফির আন্না সাইয়িআতিনা ওয়া তাওয়াফফানা মাআল আবরার। রাব্বানা ওয়া আতিনা মা ওয়াআদতানা আলা রুসুলিকা ওয়ালা তুখযিনা ইয়াওমাল কিয়ামাহ, ইন্নাকা লা তুখলিফুল মীআদ। ফাসতাজাবা লাহুম রাব্বুহুম আন্নী লা উদীউ আমালা আমিলিম মিনকুম মিন যাকারিন আও উনছা, বা’দুকুম মিম বা’দ, ফাল্লাযীনা হাজারূ ওয়া উখরিজূ মিন দিয়ারিহিম ওয়া ঊযূ ফী সাবীলী ওয়া কাতালূ ওয়া কুতিলূ লাউকাফফিরান্না আনহুম সাইয়িআতিহিম ওয়া লাউদখিলান্নাহুম জান্নাতিন তাজরী মিন তাহতিহাল আনহার, ছাওয়াবাম মিন ইনদিল্লাহ, ওয়াল্লাহু ইনদাহূ হুসনুছ ছাওয়াব। লা ইয়াগুররান্নাকা তাকাল্লুবুল্লাযীনা কাফারূ ফিল বিলাদ। মাতাউন কালীল, ছুম্মা মা’ওয়াহুম জাহান্নাম, ওয়া বি’সাল মিহাদ। লাকিনিল্লাযীনাত তাকাও রাব্বাহুম লাহুম জান্নাতুন তাজরী মিন তাহতিহাল আনহারু খালিদীনা ফীহা নুযুলাম মিন ইনদিল্লাহ, ওয়ামা ইনদাল্লাহি খাইরুল লিল আবরার। ওয়া ইন্না মিন আহলিল কিতাবি লামাঁই ইউ’মিনু বিল্লাহি ওয়ামা উনযিলা ইলাইকুম ওয়ামা উনযিলা ইলাইহিম খাশিঈনা লিল্লাহি লা ইয়াশতারূনা বিআয়াতিল্লাহি ছামানান কালীলা, উলাইকা লাহুম আজরুহুম ইনদা রাব্বিহিম, ইন্নাল্লাহা সারীউল হিসাব। ইয়া আইয়ুহাল্লাযীনা আমানুসবিরূ ওয়া সাবিরূ ওয়া রাবিতূ ওয়াত্তাকুল্লাহা লাআল্লাকুম তুফলিহূন।',
   'Инна фи халькыс-самавати валь-арды вахтиляфи-ль-ляйли ван-нахари ля аятил ли-ули-ль-альбаб. Аллязина язкуруна-Ллаха кыямав-ва ку’удав-ва ’аля джунубихим ва ятафаккаруна фи халькыс-самавати валь-ард, Раббана ма халякта хаза батыля, субханака факына ’азабан-нар. Раббана иннака ман тудхили-н-нара факад ахзайтах, ва ма ли-з-залимина мин ансар. Раббана иннана сами’на мунадияй-юнади лиль-имани ан амину би-Раббикум фа аманна, Раббана фагфир ляна зунубана ва каффир ’анна сайиатина ва таваффана ма’аль-абрар. Раббана ва атина ма ва’аттана ’аля русулика ва ля тухзина яумаль-кыяма, иннака ля тухлифуль-ми’ад. Фастаджаба ляхум Раббухум анни ля уды’у ’амаля ’амилим-минкум мин закарин ау унса, ба’дукум мим ба’д, фаллязина хаджару ва ухриджу мин диярихим ва узу фи сабили ва каталю ва кутилю ляукаффиранна ’анхум сайиатихим ва ляудхиланнахум джаннатин таджри мин тахтиха-ль-анхар, савабам-мин ’инди-Ллах, ва-Ллаху ’индаху хуснус-саваб. Ля ягурраннака такаллюбуллязина кафару филь-биляд. Мата’ун калиль, сумма ма’вахум джаханнам, ва би’саль-михад. Лякини-ллязина-ттакау Раббахум ляхум джаннатун таджри мин тахтиха-ль-анхару халидина фиха нузулям-мин ’инди-Ллах, ва ма ’инда-Ллахи хайрул лиль-абрар. Ва инна мин ахли-ль-китаби лямаий-ю’мину би-Лляхи ва ма унзиля иляйкум ва ма унзиля иляйхим хаши’ина ли-Лляхи ля яштаруна би аяти-Лляхи саманан калиля, уляика ляхум аджрухум ’инда Раббихим, инна-Ллаха сари’уль-хисаб. Я айюхаллязина аманусбиру ва сабиру ва рабиту ваттаку-Ллаха ля’аллякум туфлихун.',
   'صحیح بخاری 183', 'সহীহ বুখারী 183', 'Сахих аль-Бухари 183')
) as m(ref_key, t_ur, t_bn, t_ru, r_ur, r_bn, r_ru)
where a.adhkar_subcategory_id = s.id
  and s.title_en = 'Waking up'
  and a.reference_en = m.ref_key;
