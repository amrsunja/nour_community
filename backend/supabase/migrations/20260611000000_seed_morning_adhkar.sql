-- =============================================================================
-- Seed: "Daily routine" category -> "Morning adhkar" subcategory + 24 adhkars
--
-- Source content (Arabic, English translation, transliteration, references and
-- repetition counts) taken from Life With Allah – Morning Adhkar:
--   https://lifewithallah.com/dhikr-dua/main-adhkar/morning/
--
-- Localization:
--   * arabic_text             – exact source text
--   * translation_*           – en (source) + fr, de, nl, tr, id, ur, bn, ms, ru
--   * transcription_*         – Latin transliteration (source); copied to every
--                               language column at the end of this migration
--   * when_* / reference_*    – en/fr/ar in VALUES; copied to the remaining
--                               languages at the end (app falls back to *_en).
--
-- NOTE: the non-English/Arabic translations of Qur'anic verses (Ayah al-Kursi,
-- the 3 Quls) and prophetic supplications should ideally be reviewed by a
-- qualified native speaker before production use.
--
-- Idempotent: category / subcategory inserted only if missing; adhkars inserted
-- only when the subcategory has none yet.
-- =============================================================================

-- ── 1) Category: Daily routine ───────────────────────────────────────────────
insert into public.adhkar_categories
  (title_en, title_fr, title_ar, title_de, title_nl, title_tr, title_id, title_ur, title_bn, title_ms, title_ru, position)
select
  'Daily routine', 'Routine quotidienne', 'الروتين اليومي', 'Tägliche Routine',
  'Dagelijkse routine', 'Günlük rutin', 'Rutinitas harian', 'روزمرہ کا معمول',
  'দৈনন্দিন রুটিন', 'Rutin harian', 'Ежедневные дела', 1
where not exists (
  select 1 from public.adhkar_categories where title_en = 'Daily routine'
);

-- ── 2) Subcategory: Morning adhkar ───────────────────────────────────────────
-- Recommended window: Fajr -> mid-morning (≈ 04:00–09:00 => 240–540 min).
insert into public.adhkar_subcategories
  (adhkar_category_id, title_en, title_fr, title_ar, title_de, title_nl, title_tr,
   title_id, title_ur, title_bn, title_ms, title_ru,
   recommended_start_minute, recommended_end_minute, position)
select
  c.id, 'Morning adhkar', 'Adhkar du matin', 'أذكار الصباح', 'Morgen-Adhkar',
  'Ochtend-adhkar', 'Sabah ezkârı', 'Zikir pagi', 'صبح کے اذکار',
  'সকালের আযকার', 'Zikir pagi', 'Утренние азкары',
  240, 540, 1
from public.adhkar_categories c
where c.title_en = 'Daily routine'
  and not exists (
    select 1 from public.adhkar_subcategories s
    where s.title_en = 'Morning adhkar' and s.adhkar_category_id = c.id
  );

-- ── 3) Adhkars ───────────────────────────────────────────────────────────────
insert into public.adhkars (
  adhkar_subcategory_id,
  arabic_text,
  transcription_en,
  translation_en, translation_fr, translation_de, translation_nl, translation_tr,
  translation_id, translation_ur, translation_bn, translation_ms, translation_ru,
  when_en, when_fr, when_ar,
  reference_en, reference_fr, reference_ar,
  min_count, ajr
)
select s.id, v.*
from public.adhkar_subcategories s
cross join (
  values
  -- ════════════════════════════ 1. Ayat al-Kursi ════════════════════════════
  (
    'أَعُوْذُ بِاللّٰهِ مِنَ الشَّيْطَانِ الرَّجِيْمِ. اَللّٰهُ لَآ إِلٰهَ إِلَّا هُوَ الْحَىُّ الْقَيُّوْمُ ، لَا تَأْخُذُهُۥ سِنَةٌ وَّلَا نَوْمٌ ، لَهُ مَا فِى السَّمٰـوٰتِ وَمَا فِى الْأَرْضِ ، مَنْ ذَا الَّذِىْ يَشْفَعُ عِنْدَهُ إِلَّا بِإِذْنِهِۦ ، يَعْلَمُ مَا بَيْنَ أَيْدِيْهِمْ وَمَا خَلْفَهُمْ ، وَلَا يُحِيْطُوْنَ بِشَىْءٍ مِّنْ عِلْمِهِٓ إِلَّا بِمَا شَآءَ ، وَسِعَ كُرْسِيُّهُ السَّمٰـوٰتِ وَالْأَرْضَ، وَلَا يَئُوْدُهُۥ حِفْظُهُمَا ، وَهُوَ الْعَلِىُّ الْعَظِيْمُ.',
    'Aʿūdhu bi-llāhi mina-sh-Shayṭāni-r-rajīm. Allāhu lā ilāha illā Huwa-l-Ḥayyu-l-Qayyūm, lā ta''khudhuhū sinatuw-wa lā nawm, lahū mā fi-s-samāwāti wa mā fi-l-arḍ, man dhā''lladhī yashfaʿu ʿindahū illā bi-idhnih, yaʿlamu mā bayna aydīhim wa mā khalfahum, wa lā yuḥīṭūna bi-shay''im-min ʿilmihī illā bi-mā shā'', wasiʿa kursiyyuhu-s-samāwāti wa-l-arḍ, wa lā ya''ūduhū ḥifẓuhumā wa Huwa-l-ʿAlliyu-l-ʿAẓīm.',
    'I seek the protection of Allah from the accursed Shayṭān. Allah, there is no god worthy of worship but He, the Ever Living, The Sustainer of all. Neither drowsiness overtakes Him nor sleep. To Him Alone belongs whatever is in the heavens and whatever is on the earth. Who is it that can intercede with Him except with His permission? He knows what is before them and what will be after them, and they encompass not a thing of His knowledge except for what He wills. His Kursī extends over the heavens and the earth, and their preservation does not tire Him. And He is the Most High, the Magnificent. (2:255)',
    'Je cherche la protection d''Allah contre Satan le maudit. Allah, point de divinité digne d''adoration à part Lui, le Vivant, Celui qui subsiste par Lui-même. Ni somnolence ni sommeil ne Le saisissent. À Lui appartient tout ce qui est dans les cieux et sur la terre. Qui peut intercéder auprès de Lui sans Sa permission ? Il connaît leur passé et leur avenir, et ils n''embrassent de Sa science que ce qu''Il veut. Son Trône (Kursī) déborde les cieux et la terre, et leur garde ne Lui coûte aucune peine. Et Il est le Très-Haut, le Très-Grand. (2:255)',
    'Ich suche Schutz bei Allah vor dem verfluchten Satan. Allah – es gibt keinen Gott außer Ihm, dem Lebendigen, dem Beständigen. Ihn überkommt weder Schlummer noch Schlaf. Ihm gehört, was in den Himmeln und was auf der Erde ist. Wer ist es, der bei Ihm Fürsprache einlegen könnte – außer mit Seiner Erlaubnis? Er weiß, was vor ihnen und was hinter ihnen liegt, sie aber umfassen nichts von Seinem Wissen außer dem, was Er will. Sein Thronschemel (Kursī) umfasst die Himmel und die Erde, und ihre Bewahrung fällt Ihm nicht schwer. Und Er ist der Erhabene, der Gewaltige. (2:255)',
    'Ik zoek bescherming bij Allah tegen de vervloekte Satan. Allah, er is geen god die aanbidding waard is behalve Hij, de Eeuwig Levende, de Onderhouder van alles. Sluimer noch slaap overvalt Hem. Aan Hem behoort wat in de hemelen en op de aarde is. Wie kan bij Hem bemiddelen behalve met Zijn toestemming? Hij weet wat vóór hen en wat achter hen is, en zij bevatten niets van Zijn kennis behalve wat Hij wil. Zijn Kursī omvat de hemelen en de aarde, en het behoud ervan vermoeit Hem niet. En Hij is de Allerhoogste, de Geweldige. (2:255)',
    'Kovulmuş şeytandan Allah''a sığınırım. Allah, kendisinden başka ibadete layık ilah olmayandır; O, Hayy''dır (diridir), Kayyûm''dur (her şeyi ayakta tutandır). O''nu ne uyuklama ne de uyku tutar. Göklerde ve yerde ne varsa hepsi O''nundur. İzni olmadan O''nun katında kim şefaat edebilir? O, kullarının önündekini ve arkasındakini bilir. Onlar O''nun ilminden, ancak O''nun dilediği kadarını kavrayabilirler. O''nun Kürsî''si gökleri ve yeri kaplamıştır; bunları korumak O''na ağır gelmez. O, çok yücedir, çok büyüktür. (2:255)',
    'Aku berlindung kepada Allah dari setan yang terkutuk. Allah, tidak ada tuhan yang berhak disembah selain Dia, Yang Maha Hidup lagi terus-menerus mengurus (makhluk-Nya). Dia tidak mengantuk dan tidak tidur. Milik-Nya apa yang ada di langit dan di bumi. Siapakah yang dapat memberi syafaat di sisi-Nya tanpa izin-Nya? Dia mengetahui apa yang di hadapan mereka dan apa yang di belakang mereka, dan mereka tidak mengetahui sesuatu pun dari ilmu-Nya kecuali apa yang Dia kehendaki. Kursi-Nya meliputi langit dan bumi, dan Dia tidak merasa berat memelihara keduanya. Dan Dia Maha Tinggi lagi Maha Besar. (2:255)',
    'میں شیطان مردود سے اللہ کی پناہ مانگتا ہوں۔ اللہ، اس کے سوا کوئی معبودِ برحق نہیں، وہ زندہ ہے، سب کا تھامنے والا ہے۔ نہ اسے اونگھ آتی ہے نہ نیند۔ آسمانوں اور زمین میں جو کچھ ہے سب اسی کا ہے۔ کون ہے جو اس کی اجازت کے بغیر اس کے ہاں سفارش کرے؟ وہ جانتا ہے جو ان کے آگے ہے اور جو ان کے پیچھے ہے، اور وہ اس کے علم میں سے کسی چیز کا احاطہ نہیں کر سکتے مگر جتنا وہ چاہے۔ اس کی کرسی آسمانوں اور زمین پر محیط ہے، اور ان کی حفاظت اسے تھکاتی نہیں۔ اور وہ بلند مرتبہ، عظمت والا ہے۔ (2:255)',
    'আমি বিতাড়িত শয়তান থেকে আল্লাহর আশ্রয় চাই। আল্লাহ, তিনি ছাড়া ইবাদতের যোগ্য কোনো উপাস্য নেই, তিনি চিরঞ্জীব, সর্বসত্তার ধারক। তন্দ্রা ও নিদ্রা তাঁকে স্পর্শ করে না। আসমান ও জমিনে যা কিছু আছে সবই তাঁর। কে আছে যে তাঁর অনুমতি ছাড়া তাঁর কাছে সুপারিশ করবে? তিনি জানেন যা তাদের সামনে আছে এবং যা তাদের পেছনে আছে; আর তারা তাঁর জ্ঞানের কিছুই আয়ত্ত করতে পারে না, তিনি যা চান তা ছাড়া। তাঁর কুরসি আসমান ও জমিনকে পরিব্যাপ্ত করে আছে এবং এ দুটির রক্ষণাবেক্ষণ তাঁকে ক্লান্ত করে না। আর তিনি সর্বোচ্চ, মহান। (2:255)',
    'Aku berlindung kepada Allah daripada syaitan yang direjam. Allah, tiada tuhan yang berhak disembah melainkan Dia, Yang Maha Hidup lagi Maha Berdiri Sendiri (mentadbir makhluk). Dia tidak mengantuk dan tidak tidur. Milik-Nya segala yang di langit dan di bumi. Siapakah yang dapat memberi syafaat di sisi-Nya tanpa izin-Nya? Dia mengetahui apa yang di hadapan dan di belakang mereka, dan mereka tidak mengetahui sesuatu pun daripada ilmu-Nya kecuali apa yang Dia kehendaki. Kursi-Nya meliputi langit dan bumi, dan Dia tidak merasa berat memelihara keduanya. Dan Dia Maha Tinggi lagi Maha Agung. (2:255)',
    'Прибегаю к Аллаху от проклятого шайтана. Аллах — нет божества, достойного поклонения, кроме Него, Живого, Вседержителя. Им не овладевают ни дремота, ни сон. Ему принадлежит то, что на небесах, и то, что на земле. Кто станет заступаться пред Ним без Его дозволения? Он знает их будущее и прошлое, а они постигают из Его знания только то, что Он пожелает. Его Престол (Курси) объемлет небеса и землю, и не тяготит Его охрана их. Он — Возвышенный, Великий. (2:255)',
    'In the morning, between Fajr and sunrise', 'Le matin, entre le Fajr et le lever du soleil', 'في الصباح، بين الفجر وطلوع الشمس',
    'Qur''an 2:255; Ḥākim 2064', 'Coran 2:255 ; Ḥākim 2064', 'القرآن ٢:٢٥٥؛ الحاكم ٢٠٦٤',
    1::smallint, 10::smallint
  ),
  -- ════════════════════════════ 2. The 3 Quls ═══════════════════════════════
  (
    'بِسْمِ اللّٰهِ الرَّحْمٰنِ الرَّحِيْمِ. قُلْ هُوَ اللّٰهُ أَحَدٌ ، اَللّٰهُ الصَّمَدُ ، لَمْ يَلِدْ وَلَمْ يُوْلَدْ ، وَلَمْ يَكُنْ لَّهُ كُفُوًا أَحَدٌ. بِسْمِ اللّٰهِ الرَّحْمٰنِ الرَّحِيْمِ. قُلْ أَعُوْذُ بِرَبِّ الْفَلَقِ ، مِنْ شَرِّ مَا خَلَقَ ، وَمِنْ شَرِّ غَاسِقٍ إِذَا وَقَبَ ، وَمِنْ شَرِّ النَّفَّاثَاتِ فِي الْعُقَدِ ، وَمِنْ شَرِّ حَاسِدٍ إِذَا حَسَدَ. بِسْمِ اللّٰهِ الرَّحْمٰنِ الرَّحِيْمِ. قُلْ أَعُوْذُ بِرَبِّ النَّاسِ ، مَلِكِ النَّاسِ ، إِلٰهِ النَّاسِ ، مِنْ شَرِّ الْوَسْوَاسِ الْخَنَّاسِ ، اَلَّذِيْ يُوَسْوِسُ فِيْ صُدُوْرِ النَّاسِ ، مِنَ الْجِنَّةِ وَالنَّاسِ.',
    'Bismi-llāhi-r-Raḥmāni-r-Raḥīm. Qul Huwa-llāhu Aḥad. Allāhu-ṣ-Ṣamad. Lam yalid wa lam yūlad. Wa lam yakul-lahū kufuwan aḥad. Bismi-llāhi-r-Raḥmāni-r-Raḥīm. Qul aʿūdhu bi-Rabbi-l-falaq. Min sharri mā khalaq. Wa min sharri ghāsiqin idhā waqab. Wa min sharri-n-naffāthāti fi-l-ʿuqad. Wa min sharri ḥāsidin idhā ḥasad. Bismi-llāhi-r-Raḥmāni-r-Raḥīm. Qul aʿūdhu bi-Rabbi-n-nās. Maliki-n-nās. Ilāhi-n-nās. Min sharri-l-waswāsi-l-khannās. Al-ladhī yuwaswisu fī ṣudūri-n-nās. Mina-l-jinnati wa-n-nās.',
    'In the name of Allah, the All-Merciful, the Very Merciful. Say, He is Allah, the One, the Self-Sufficient Master, Who has not given birth and was not born, and to Whom no one is equal. (112) Say, I seek protection of the Lord of the daybreak, from the evil of what He has created, and from the evil of the darkening night when it settles, and from the evil of the blowers in knots, and from the evil of the envier when he envies. (113) Say, I seek protection of the Lord of mankind, the King of mankind, the God of mankind, from the evil of the whisperer who withdraws, who whispers in the hearts of mankind, whether they be Jinn or people. (114)',
    'Au nom d''Allah, le Tout-Miséricordieux, le Très-Miséricordieux. Dis : Il est Allah, l''Unique, le Seul à être imploré pour ce que nous désirons, qui n''a pas engendré et n''a pas été engendré, et nul n''est égal à Lui. (112) Dis : Je cherche protection auprès du Seigneur de l''aube naissante, contre le mal de ce qu''Il a créé, contre le mal de l''obscurité quand elle s''étend, contre le mal de celles qui soufflent sur les nœuds, et contre le mal de l''envieux quand il envie. (113) Dis : Je cherche protection auprès du Seigneur des hommes, le Souverain des hommes, le Dieu des hommes, contre le mal du mauvais conseiller furtif qui souffle le mal dans les poitrines des hommes, qu''il soit djinn ou humain. (114)',
    'Im Namen Allahs, des Allerbarmers, des Barmherzigen. Sprich: Er ist Allah, ein Einziger, Allah, der Absolute (von dem alles abhängt). Er hat nicht gezeugt und ist nicht gezeugt worden, und niemand ist Ihm gleich. (112) Sprich: Ich suche Schutz beim Herrn des Tagesanbruchs vor dem Übel dessen, was Er erschaffen hat, vor dem Übel der Dunkelheit, wenn sie hereinbricht, vor dem Übel der in Knoten Blasenden und vor dem Übel eines Neiders, wenn er neidet. (113) Sprich: Ich suche Schutz beim Herrn der Menschen, dem König der Menschen, dem Gott der Menschen, vor dem Übel des einflüsternden Zurückweichenden, der in die Brüste der Menschen einflüstert, sei er von den Dschinn oder den Menschen. (114)',
    'In de naam van Allah, de Erbarmer, de Meest Barmhartige. Zeg: Hij is Allah, de Enige, de Onafhankelijke tot wie alles zich wendt, Hij heeft niet verwekt en is niet verwekt, en niemand is aan Hem gelijk. (112) Zeg: Ik zoek bescherming bij de Heer van de dageraad, tegen het kwaad van wat Hij heeft geschapen, tegen het kwaad van de duisternis wanneer zij invalt, tegen het kwaad van hen die op knopen blazen, en tegen het kwaad van de afgunstige wanneer hij afgunstig is. (113) Zeg: Ik zoek bescherming bij de Heer van de mensen, de Koning van de mensen, de God van de mensen, tegen het kwaad van de wegglippende influisteraar, die influistert in de harten van de mensen, of hij nu van de djinn of de mensen is. (114)',
    'Rahmân ve Rahîm olan Allah''ın adıyla. De ki: O Allah birdir. Allah Samed''dir (her şey O''na muhtaçtır, O hiçbir şeye muhtaç değildir). O doğurmamış ve doğurulmamıştır. Hiçbir şey O''na denk değildir. (112) De ki: Yarattığı şeylerin şerrinden, çöktüğü zaman karanlığın şerrinden, düğümlere üfleyenlerin şerrinden ve haset ettiği zaman hasetçinin şerrinden, sabahın Rabbine sığınırım. (113) De ki: İnsanların Rabbine, insanların Melik''ine (hükümdarına), insanların İlah''ına sığınırım; cinlerden ve insanlardan olup insanların göğüslerine vesvese veren sinsi vesvesecinin şerrinden. (114)',
    'Dengan nama Allah Yang Maha Pengasih lagi Maha Penyayang. Katakanlah: Dialah Allah Yang Maha Esa. Allah tempat bergantung segala sesuatu. Dia tidak beranak dan tidak pula diperanakkan. Dan tidak ada sesuatu pun yang setara dengan Dia. (112) Katakanlah: Aku berlindung kepada Tuhan yang menguasai subuh (fajar), dari kejahatan makhluk-Nya, dari kejahatan malam apabila telah gelap gulita, dari kejahatan (tukang sihir) yang meniup pada buhul-buhul, dan dari kejahatan orang yang dengki apabila ia dengki. (113) Katakanlah: Aku berlindung kepada Tuhan manusia, Raja manusia, Sembahan manusia, dari kejahatan (bisikan) setan yang biasa bersembunyi, yang membisikkan (kejahatan) ke dalam dada manusia, dari (golongan) jin dan manusia. (114)',
    'اللہ کے نام سے جو نہایت مہربان رحم والا ہے۔ کہو، وہ اللہ ایک ہے۔ اللہ بے نیاز ہے (سب اسی کے محتاج ہیں)۔ نہ اس نے کسی کو جنا اور نہ وہ جنا گیا، اور نہ کوئی اس کے برابر ہے۔ (112) کہو، میں صبح کے رب کی پناہ مانگتا ہوں، اس کی مخلوق کے شر سے، اور اندھیری رات کے شر سے جب وہ چھا جائے، اور گرہوں میں پھونکنے والیوں کے شر سے، اور حسد کرنے والے کے شر سے جب وہ حسد کرے۔ (113) کہو، میں لوگوں کے رب کی پناہ مانگتا ہوں، لوگوں کے بادشاہ کی، لوگوں کے معبود کی، اس وسوسہ ڈالنے والے کے شر سے جو پیچھے ہٹ جاتا ہے، جو لوگوں کے دلوں میں وسوسہ ڈالتا ہے، خواہ وہ جنوں میں سے ہو یا انسانوں میں سے۔ (114)',
    'পরম করুণাময় অসীম দয়ালু আল্লাহর নামে। বলো, তিনিই আল্লাহ, এক ও অদ্বিতীয়। আল্লাহ অমুখাপেক্ষী (সবাই তাঁর মুখাপেক্ষী)। তিনি কাউকে জন্ম দেননি এবং তাঁকেও জন্ম দেওয়া হয়নি, আর তাঁর সমতুল্য কেউ নেই। (১১২) বলো, আমি প্রভাতের রবের আশ্রয় চাই, তিনি যা সৃষ্টি করেছেন তার অনিষ্ট থেকে, অন্ধকার রাতের অনিষ্ট থেকে যখন তা ছেয়ে যায়, গিঁটে ফুঁ-দানকারীদের অনিষ্ট থেকে এবং হিংসুকের অনিষ্ট থেকে যখন সে হিংসা করে। (১১৩) বলো, আমি মানুষের রবের আশ্রয় চাই, মানুষের অধিপতির, মানুষের উপাস্যের, সেই কুমন্ত্রণাদাতার অনিষ্ট থেকে যে পিছিয়ে যায়, যে মানুষের অন্তরে কুমন্ত্রণা দেয়, জিন ও মানুষের মধ্য থেকে। (১১৪)',
    'Dengan nama Allah Yang Maha Pemurah lagi Maha Mengasihani. Katakanlah: Dialah Allah Yang Maha Esa. Allah tempat bergantung segala sesuatu. Dia tidak beranak dan tidak diperanakkan. Dan tiada sesuatu pun yang setara dengan-Nya. (112) Katakanlah: Aku berlindung kepada Tuhan yang menguasai waktu subuh, dari kejahatan makhluk-Nya, dari kejahatan malam apabila gelap-gulita, dari kejahatan (tukang sihir) yang meniup pada simpulan, dan dari kejahatan orang yang dengki apabila ia berdengki. (113) Katakanlah: Aku berlindung kepada Tuhan manusia, Raja manusia, Tuhan yang disembah manusia, dari kejahatan pembisik yang bersembunyi, yang membisikkan kejahatan ke dalam dada manusia, dari (golongan) jin dan manusia. (114)',
    'С именем Аллаха, Милостивого, Милосердного. Скажи: Он — Аллах Единый, Аллах Самодостаточный. Он не родил и не был рожден, и нет никого, равного Ему. (112) Скажи: Прибегаю к защите Господа рассвета от зла того, что Он сотворил, от зла мрака, когда он наступает, от зла дующих на узлы (колдуний) и от зла завистника, когда он завидует. (113) Скажи: Прибегаю к защите Господа людей, Царя людей, Бога людей, от зла искусителя отступающего, который наущает в груди людей, от джиннов и людей. (114)',
    'In the morning, between Fajr and sunrise', 'Le matin, entre le Fajr et le lever du soleil', 'في الصباح، بين الفجر وطلوع الشمس',
    'Qur''an 112–114; Tirmidhī 3575', 'Coran 112–114 ; Tirmidhī 3575', 'القرآن ١١٢–١١٤؛ الترمذي ٣٥٧٥',
    3::smallint, 10::smallint
  ),
  -- ════════════════════════ 3. Sayyid al-Istighfar ══════════════════════════
  (
    'اَللّٰهُمَّ أَنْتَ رَبِّيْ لَا إِلٰهَ إِلَّا أَنْتَ ، خَلَقْتَنِيْ وَأَنَا عَبْدُكَ ، وَأَنَا عَلَىٰ عَهْدِكَ وَوَعْدِكَ مَا اسْتَطَعْتُ ، أَعُوْذُ بِكَ مِنْ شَرِّ مَا صَنَعْتُ ، أَبُوْءُ لَكَ بِنِعْمَتِكَ عَلَيَّ وَأَبُوْءُ لَكَ بِذَنْبِيْ ، فَاغْفِرْ لِيْ فَإِنَّهُ لَا يَغْفِرُ الذُّنُوْبَ إِلَّا أَنْتَ.',
    'Allāhumma Anta Rabbī, lā ilāha illā Ant, khalaqtanī wa ana ʿabduk, wa ana ʿalā ʿahdika wa waʿdika mā''staṭaʿt, aʿūdhu bika min sharri mā ṣanaʿt, abū''u laka bi niʿmatika ʿalayya wa abū''u laka bi-dhambī fa-ghfir lī fa-innahū lā yaghfiru-dh-dhunūba illā Ant.',
    'O Allah, You are my Lord. There is no god worthy of worship except You. You have created me, and I am Your slave, and I am under Your covenant and pledge (to fulfil it) to the best of my ability. I seek Your protection from the evil that I have done. I acknowledge the favours that You have bestowed upon me, and I admit my sins. Forgive me, for none forgives sins but You.',
    'Ô Allah, Tu es mon Seigneur. Il n''y a de divinité digne d''adoration que Toi. Tu m''as créé et je suis Ton serviteur. Je respecte Ton engagement et Ta promesse autant que je le peux. Je cherche Ta protection contre le mal que j''ai commis. Je reconnais Tes bienfaits envers moi et j''avoue mes péchés. Pardonne-moi, car nul ne pardonne les péchés à part Toi.',
    'O Allah, Du bist mein Herr. Es gibt keinen Gott außer Dir. Du hast mich erschaffen, und ich bin Dein Diener, und ich halte mich an Deinen Bund und Dein Versprechen, so gut ich kann. Ich suche Schutz bei Dir vor dem Übel, das ich getan habe. Ich erkenne Deine Gunst mir gegenüber an und gestehe meine Sünden ein. So vergib mir, denn niemand vergibt die Sünden außer Dir.',
    'O Allah, U bent mijn Heer. Er is geen god die aanbidding waard is behalve U. U hebt mij geschapen en ik ben Uw dienaar, en ik houd mij aan Uw verbond en belofte zo goed als ik kan. Ik zoek bescherming bij U tegen het kwaad dat ik heb gedaan. Ik erken Uw gunsten aan mij en ik beken mijn zonden. Vergeef mij, want niemand vergeeft de zonden behalve U.',
    'Allah''ım, Sen benim Rabbimsin. Senden başka ibadete layık ilah yoktur. Beni Sen yarattın ve ben Senin kulunum. Gücüm yettiğince Sana verdiğim söz ve ahd üzereyim. İşlediğim kötülüklerin şerrinden Sana sığınırım. Bana olan nimetini ikrar eder, günahımı da itiraf ederim. Beni bağışla; çünkü günahları Senden başka bağışlayacak yoktur.',
    'Ya Allah, Engkau adalah Tuhanku. Tidak ada tuhan yang berhak disembah selain Engkau. Engkau menciptakanku dan aku adalah hamba-Mu. Aku berada di atas perjanjian dan janji-Mu semampuku. Aku berlindung kepada-Mu dari keburukan yang telah aku perbuat. Aku mengakui nikmat-Mu atasku dan aku mengakui dosaku. Maka ampunilah aku, sebab tidak ada yang dapat mengampuni dosa kecuali Engkau.',
    'اے اللہ! تو میرا رب ہے، تیرے سوا کوئی معبودِ برحق نہیں۔ تو نے مجھے پیدا کیا اور میں تیرا بندہ ہوں، اور میں اپنی استطاعت کے مطابق تیرے عہد و وعدے پر قائم ہوں۔ میں اپنے کیے کے شر سے تیری پناہ مانگتا ہوں۔ میں تیری اپنے اوپر کی گئی نعمتوں کا اعتراف کرتا ہوں اور اپنے گناہوں کا بھی اقرار کرتا ہوں۔ پس مجھے بخش دے، کیونکہ تیرے سوا گناہ کوئی نہیں بخشتا۔',
    'হে আল্লাহ! তুমিই আমার রব, তুমি ছাড়া ইবাদতের যোগ্য কোনো উপাস্য নেই। তুমি আমাকে সৃষ্টি করেছ এবং আমি তোমার বান্দা। আমি সাধ্যমতো তোমার অঙ্গীকার ও প্রতিশ্রুতির উপর আছি। আমি আমার কৃতকর্মের অনিষ্ট থেকে তোমার আশ্রয় চাই। আমি তোমার দেওয়া নিয়ামতের স্বীকৃতি দিচ্ছি এবং আমার পাপও স্বীকার করছি। সুতরাং আমাকে ক্ষমা করো, কারণ তুমি ছাড়া পাপ ক্ষমা করার কেউ নেই।',
    'Ya Allah, Engkaulah Tuhanku. Tiada tuhan yang berhak disembah melainkan Engkau. Engkau menciptakan aku dan aku hamba-Mu. Aku berada di atas perjanjian dan janji-Mu sekadar kemampuanku. Aku berlindung kepada-Mu daripada kejahatan yang telah aku lakukan. Aku mengakui nikmat-Mu ke atasku dan aku mengakui dosaku. Maka ampunkanlah aku, kerana tiada yang mengampunkan dosa melainkan Engkau.',
    'О Аллах, Ты — мой Господь. Нет божества, достойного поклонения, кроме Тебя. Ты создал меня, и я — Твой раб. Я храню верность Твоему завету и обещанию, насколько мне под силу. Прибегаю к Тебе от зла того, что я совершил. Признаю милость Твою ко мне и признаю свой грех. Прости же меня, ибо никто не прощает грехи, кроме Тебя.',
    'In the morning, between Fajr and sunrise', 'Le matin, entre le Fajr et le lever du soleil', 'في الصباح، بين الفجر وطلوع الشمس',
    'Bukhārī 6306', 'Bukhārī 6306', 'صحيح البخاري ٦٣٠٦',
    1::smallint, 10::smallint
  ),
  -- ═══════════════ 4. Protection from anxiety, laziness, debt ════════════════
  (
    'اَللّٰهُمَّ إِنِّيْ أَعُوْذُ بِكَ مِنَ الْهَمِّ وَالْحَزَنِ ، وَأَعُوْذُ بِكَ مِنَ الْعَجْزِ وَالْكَسَلِ، وَأَعُوْذُ بِكَ مِنَ الْجُبْنِ وَالْبُخْلِ ، وَأَعُوْذُ بِكَ مِنْ غَلَبَةِ الدَّيْنِ وَقَهْرِ الرِّجَالِ.',
    'Allāhumma innī aʿūdhu bika min-l-hammi wa-l-ḥazan, wa aʿūdhu bika min-l-ʿajzi wa-l-kasal, wa aʿūdhu bika min-l-jubni wa-l-bukhl, wa aʿūdhu bika min ghalabati-d-dayni wa qahri-r-rijāl.',
    'O Allah, I seek Your protection from anxiety and grief. I seek Your protection from inability and laziness. I seek Your protection from cowardice and miserliness, and I seek Your protection from being overcome by debt and being overpowered by men.',
    'Ô Allah, je cherche Ta protection contre l''anxiété et la tristesse. Je cherche Ta protection contre l''incapacité et la paresse. Je cherche Ta protection contre la lâcheté et l''avarice, et je cherche Ta protection contre le poids de la dette et la domination des hommes.',
    'O Allah, ich suche Schutz bei Dir vor Sorge und Kummer. Ich suche Schutz bei Dir vor Unvermögen und Faulheit. Ich suche Schutz bei Dir vor Feigheit und Geiz, und ich suche Schutz bei Dir davor, von Schulden überwältigt und von Menschen unterdrückt zu werden.',
    'O Allah, ik zoek bescherming bij U tegen zorgen en verdriet. Ik zoek bescherming bij U tegen onvermogen en luiheid. Ik zoek bescherming bij U tegen lafheid en gierigheid, en ik zoek bescherming bij U tegen het overweldigd worden door schulden en het overheerst worden door mensen.',
    'Allah''ım, kederden ve üzüntüden Sana sığınırım. Acizlikten ve tembellikten Sana sığınırım. Korkaklıktan ve cimrilikten Sana sığınırım. Borcun altında ezilmekten ve insanların kahrına uğramaktan Sana sığınırım.',
    'Ya Allah, aku berlindung kepada-Mu dari kegelisahan dan kesedihan. Aku berlindung kepada-Mu dari kelemahan dan kemalasan. Aku berlindung kepada-Mu dari sifat pengecut dan kikir, dan aku berlindung kepada-Mu dari lilitan utang dan tekanan orang-orang.',
    'اے اللہ! میں فکر اور غم سے تیری پناہ مانگتا ہوں، اور عاجزی و سستی سے تیری پناہ مانگتا ہوں، اور بزدلی و بخل سے تیری پناہ مانگتا ہوں، اور قرض کے غلبے اور لوگوں کے دباؤ سے تیری پناہ مانگتا ہوں۔',
    'হে আল্লাহ! আমি দুশ্চিন্তা ও দুঃখ থেকে তোমার আশ্রয় চাই, অক্ষমতা ও অলসতা থেকে তোমার আশ্রয় চাই, কাপুরুষতা ও কৃপণতা থেকে তোমার আশ্রয় চাই, এবং ঋণের বোঝা ও মানুষের প্রাধান্য থেকে তোমার আশ্রয় চাই।',
    'Ya Allah, aku berlindung kepada-Mu daripada kebimbangan dan kesedihan. Aku berlindung kepada-Mu daripada kelemahan dan kemalasan. Aku berlindung kepada-Mu daripada sifat pengecut dan bakhil, dan aku berlindung kepada-Mu daripada bebanan hutang dan penindasan manusia.',
    'О Аллах, прибегаю к Тебе от тревоги и печали, прибегаю к Тебе от неспособности и лени, прибегаю к Тебе от трусости и скупости, и прибегаю к Тебе от бремени долга и притеснения людей.',
    'In the morning, between Fajr and sunrise', 'Le matin, entre le Fajr et le lever du soleil', 'في الصباح، بين الفجر وطلوع الشمس',
    'Abū Dāwūd 1555', 'Abū Dāwūd 1555', 'سنن أبي داود ١٥٥٥',
    1::smallint, 5::smallint
  ),
  -- ═══════════════ 5. Well-being in this world and the hereafter ═════════════
  (
    'اَللّٰهُمَّ إِنِّيْ أَسْأَلُكَ الْعَافِيَةَ فِي الدُّنْيَا وَالْآخِرَةِ ، اَللّٰهُمَّ إِنِّيْ أَسْأَلُكَ الْعَفْوَ وَالْعَافِيَةَ فِيْ دِيْنِيْ وَدُنْيَايَ وَأَهْلِيْ وَمَالِيْ ، اَللّٰهُمَّ اسْتُرْ عَوْرَاتِيْ وَآمِنْ رَوْعَاتِيْ ، اَللّٰهُمَّ احْفَظْنِيْ مِنْ بَيْنِ يَدَيَّ ، وَمِنْ خَلْفِيْ ، وَعَنْ يَّمِيْنِيْ ، وَعَنْ شِمَالِيْ ، وَمِنْ فَوْقِيْ ، وَأَعُوْذُ بِعَظَمَتِكَ أَنْ أُغْتَالَ مِنْ تَحْتِيْ.',
    'Allāhumma innī as''aluka-l-ʿāfiyata fi-d-dunyā wa-l-ākhirah. Allāhumma innī as''aluka-l-ʿafwa wa-l-ʿāfiyata fī dīnī wa dunyāya wa ahlī wa mālī, Allāhumma-stur ʿawrātī wa āmin rawʿātī. Allāhumma-ḥfaẓnī mim bayni yadayya wa min khalfī, wa ʿan yamīnī wa ʿan shimālī wa min fawqī, wa aʿūdhu bi-ʿaẓamatika an ughtāla min taḥtī.',
    'O Allah, I ask You for well-being in this world and the next. O Allah, I ask You for forgiveness and well-being in my religion, in my worldly affairs, in my family and in my wealth. O Allah, conceal my faults and calm my fears. O Allah, guard me from in front of me and behind me, from my right, and from my left, and from above me. I seek protection in Your Greatness from being unexpectedly destroyed from beneath me.',
    'Ô Allah, je Te demande le bien-être dans ce monde et dans l''au-delà. Ô Allah, je Te demande le pardon et le bien-être dans ma religion, mes affaires d''ici-bas, ma famille et mes biens. Ô Allah, couvre mes défauts et apaise mes craintes. Ô Allah, protège-moi de devant moi et de derrière moi, de ma droite, de ma gauche et d''au-dessus de moi. Et je cherche protection en Ta Grandeur contre le fait d''être anéanti par en dessous de moi.',
    'O Allah, ich bitte Dich um Wohlergehen in dieser Welt und im Jenseits. O Allah, ich bitte Dich um Vergebung und Wohlergehen in meiner Religion, meinen weltlichen Angelegenheiten, meiner Familie und meinem Besitz. O Allah, verdecke meine Blößen und beruhige meine Ängste. O Allah, behüte mich von vorn und von hinten, von meiner Rechten und meiner Linken und von oben. Und ich suche Zuflucht bei Deiner Größe davor, von unten her unerwartet vernichtet zu werden.',
    'O Allah, ik vraag U om welzijn in deze wereld en het hiernamaals. O Allah, ik vraag U om vergeving en welzijn in mijn religie, mijn wereldse zaken, mijn familie en mijn bezit. O Allah, bedek mijn gebreken en stel mijn angsten gerust. O Allah, bewaak mij van voren en van achteren, van mijn rechterzijde en van mijn linkerzijde en van boven mij. En ik zoek bescherming in Uw Grootheid tegen het onverwacht vernietigd worden van onder mij.',
    'Allah''ım, dünyada ve ahirette afiyet (esenlik) dilerim. Allah''ım, dinimde, dünyamda, ailemde ve malımda affını ve afiyetini dilerim. Allah''ım, ayıplarımı ört ve korkularımı gider. Allah''ım, beni önümden, arkamdan, sağımdan, solumdan ve üstümden koru. Altımdan ansızın helak edilmekten de Senin azametine sığınırım.',
    'Ya Allah, aku memohon kepada-Mu keselamatan (afiat) di dunia dan akhirat. Ya Allah, aku memohon kepada-Mu ampunan dan keselamatan dalam agamaku, duniaku, keluargaku, dan hartaku. Ya Allah, tutupilah auratku (aibku) dan tenangkanlah ketakutanku. Ya Allah, jagalah aku dari depan, dari belakang, dari kananku, dari kiriku, dan dari atasku. Dan aku berlindung dengan keagungan-Mu dari dibinasakan secara tiba-tiba dari bawahku.',
    'اے اللہ! میں تجھ سے دنیا و آخرت میں عافیت کا سوال کرتا ہوں۔ اے اللہ! میں تجھ سے اپنے دین، دنیا، اہلِ خانہ اور مال میں معافی اور عافیت کا سوال کرتا ہوں۔ اے اللہ! میری پردہ پوشی فرما اور میرے خوف کو امن میں بدل دے۔ اے اللہ! میری حفاظت فرما میرے آگے سے، میرے پیچھے سے، میرے دائیں سے، میرے بائیں سے اور میرے اوپر سے، اور میں تیری عظمت کی پناہ مانگتا ہوں کہ میں نیچے سے اچانک ہلاک کر دیا جاؤں۔',
    'হে আল্লাহ! আমি তোমার কাছে দুনিয়া ও আখিরাতে নিরাপত্তা (আফিয়াত) চাই। হে আল্লাহ! আমি তোমার কাছে আমার দ্বীন, দুনিয়া, পরিবার ও সম্পদে ক্ষমা ও নিরাপত্তা চাই। হে আল্লাহ! আমার দোষগুলো ঢেকে রাখো এবং আমার ভয়গুলো নিরাপত্তায় পরিণত করো। হে আল্লাহ! আমাকে রক্ষা করো আমার সামনে থেকে, পেছন থেকে, ডান থেকে, বাম থেকে ও উপর থেকে; আর আমি তোমার মহত্ত্বের আশ্রয় চাই যেন আমার নিচ থেকে আকস্মিকভাবে ধ্বংস না করা হই।',
    'Ya Allah, aku memohon kepada-Mu keselamatan (afiat) di dunia dan akhirat. Ya Allah, aku memohon kepada-Mu keampunan dan keselamatan dalam agamaku, duniaku, keluargaku dan hartaku. Ya Allah, tutupilah keaibanku dan tenangkanlah ketakutanku. Ya Allah, peliharalah aku dari hadapanku, dari belakangku, dari kananku, dari kiriku dan dari atasku. Dan aku berlindung dengan keagungan-Mu daripada dibinasakan secara tiba-tiba dari bawahku.',
    'О Аллах, прошу у Тебя благополучия в этом мире и в мире вечном. О Аллах, прошу у Тебя прощения и благополучия в моей религии, моих мирских делах, моей семье и моём имуществе. О Аллах, прикрой мои изъяны и успокой мои страхи. О Аллах, храни меня спереди и сзади, справа и слева и сверху. И прибегаю к величию Твоему от того, чтобы быть нежданно погубленным снизу.',
    'In the morning, between Fajr and sunrise', 'Le matin, entre le Fajr et le lever du soleil', 'في الصباح، بين الفجر وطلوع الشمس',
    'Abū Dāwūd 5074; Ibn Mājah 3871', 'Abū Dāwūd 5074 ; Ibn Mājah 3871', 'سنن أبي داود ٥٠٧٤؛ ابن ماجه ٣٨٧١',
    1::smallint, 5::smallint
  ),
  -- ═══════════════════════ 6. Protection from the 4 evils ═══════════════════
  (
    'اَللّٰهُمَّ فَاطِرَ السَّمٰوَاتِ وَالْأَرْضِ ، عَالِمَ الْغَيْبِ وَالشَّهَادَةِ ، رَبَّ كُلِّ شَيْءٍ وَّمَلِيْكَهُ ، أَشْهَدُ أَنْ لَّا إِلٰهَ إِلَّا أَنْتَ ، أَعُوْذُ بِكَ مِنْ شَرِّ نَفْسِيْ ، وَمِنْ شَرِّ الشَّيْطَانِ وَشِرْكِهِ ، وَأَنْ أَقْتَرِفَ عَلَىٰ نَفْسِيْ سُوْءًا أَوْ أَجُرَّهُ إِلَىٰ مُسْلِمٍ.',
    'Allāhumma fāṭir-as-samāwāti wa-l-arḍ, ʿālima-l-ghaybi wa-sh-shahādah, rabba kulli shay''iw-wa malīkah, ash-hadu al-lā ilāha illā Ant, aʿūdhu bika min sharri nafsī wa min sharri-sh-shayṭāni wa shirkihī wa an aqtarifa ʿalā nafsī sū''an aw ajurrahū ilā muslim.',
    'O Allah, Creator of the heavens and the earth, Knower of the unseen and the seen, the Lord and Sovereign of everything; I bear witness that there is no god worthy of worship but You. I seek Your protection from the evil of my own self, from the evil of Shayṭān and from the evil of polytheism to which he calls, and from inflicting evil on myself, or bringing it upon a Muslim.',
    'Ô Allah, Créateur des cieux et de la terre, Connaisseur de l''invisible et du visible, Seigneur et Souverain de toute chose ; je témoigne qu''il n''y a de divinité digne d''adoration que Toi. Je cherche Ta protection contre le mal de mon âme, contre le mal de Satan et de l''associationnisme auquel il appelle, et contre le fait de commettre un mal contre moi-même ou de l''attirer sur un musulman.',
    'O Allah, Schöpfer der Himmel und der Erde, Kenner des Verborgenen und des Sichtbaren, Herr und Gebieter aller Dinge; ich bezeuge, dass es keinen Gott außer Dir gibt. Ich suche Schutz bei Dir vor dem Übel meiner selbst, vor dem Übel des Satans und seiner Beigesellung, und davor, mir selbst Böses zuzufügen oder es einem Muslim zuzufügen.',
    'O Allah, Schepper van de hemelen en de aarde, Kenner van het onzichtbare en het zichtbare, Heer en Soeverein van alles; ik getuig dat er geen god is die aanbidding waard is behalve U. Ik zoek bescherming bij U tegen het kwaad van mijzelf, tegen het kwaad van Shayṭān en de afgoderij waartoe hij oproept, en ertegen dat ik mijzelf kwaad berokken of het een moslim aandoe.',
    'Allah''ım, gökleri ve yeri yoktan var eden, görüleni ve görülmeyeni bilen, her şeyin Rabbi ve sahibi! Senden başka ibadete layık ilah olmadığına şahitlik ederim. Nefsimin şerrinden, şeytanın ve onun şirkinin şerrinden, kendime bir kötülük yapmaktan ya da onu bir Müslümana bulaştırmaktan Sana sığınırım.',
    'Ya Allah, Pencipta langit dan bumi, Yang Mengetahui yang gaib dan yang nyata, Tuhan dan Penguasa segala sesuatu; aku bersaksi bahwa tidak ada tuhan yang berhak disembah selain Engkau. Aku berlindung kepada-Mu dari kejahatan diriku sendiri, dari kejahatan setan dan ajakan syiriknya, dan dari melakukan kejahatan terhadap diriku atau menimpakannya kepada seorang muslim.',
    'اے اللہ! آسمانوں اور زمین کے پیدا کرنے والے، غیب اور حاضر کے جاننے والے، ہر چیز کے رب اور مالک! میں گواہی دیتا ہوں کہ تیرے سوا کوئی معبودِ برحق نہیں۔ میں اپنے نفس کے شر سے، شیطان اور اس کے شرک کے شر سے، اور اس بات سے کہ میں اپنے آپ پر کوئی برائی کروں یا کسی مسلمان کی طرف کھینچ لاؤں، تیری پناہ مانگتا ہوں۔',
    'হে আল্লাহ! আসমান ও জমিনের স্রষ্টা, গায়েব ও প্রকাশ্যের জ্ঞাতা, প্রতিটি বস্তুর রব ও মালিক! আমি সাক্ষ্য দিচ্ছি যে তুমি ছাড়া ইবাদতের যোগ্য কোনো উপাস্য নেই। আমি আমার নফসের অনিষ্ট থেকে, শয়তান ও তার শিরকের অনিষ্ট থেকে, এবং নিজের উপর কোনো মন্দ ডেকে আনা বা তা কোনো মুসলিমের উপর টেনে আনা থেকে তোমার আশ্রয় চাই।',
    'Ya Allah, Pencipta langit dan bumi, Yang Mengetahui yang ghaib dan yang nyata, Tuhan dan Penguasa segala sesuatu; aku bersaksi bahawa tiada tuhan yang berhak disembah melainkan Engkau. Aku berlindung kepada-Mu daripada kejahatan diriku, daripada kejahatan syaitan dan ajakan syiriknya, dan daripada melakukan kejahatan terhadap diriku atau menimpakannya kepada seorang Muslim.',
    'О Аллах, Творец небес и земли, Знающий сокровенное и явное, Господь и Владыка всего сущего! Свидетельствую, что нет божества, достойного поклонения, кроме Тебя. Прибегаю к Тебе от зла моей души, от зла шайтана и его призыва к многобожию, и от того, чтобы навлечь зло на себя или причинить его мусульманину.',
    'In the morning, between Fajr and sunrise', 'Le matin, entre le Fajr et le lever du soleil', 'في الصباح، بين الفجر وطلوع الشمس',
    'Tirmidhī 3392, 3529', 'Tirmidhī 3392, 3529', 'سنن الترمذي ٣٣٩٢، ٣٥٢٩',
    1::smallint, 5::smallint
  ),
  -- ═══════════════════ 7. Entrust all your matters to Allah ═════════════════
  (
    'يَا حَيُّ يَا قَيُّوْمُ ، بِرَحْمَتِكَ أَسْتَغِيْثُ ، أَصْلِحْ لِيْ شَأْنِيْ كُلَّهُ ، وَلَا تَكِلْنِيْ إِلَىٰ نَفْسِيْ طَرْفَةَ عَيْنٍ.',
    'Yā Ḥayyu yā Qayyūm, bi-raḥmatika astaghīth, aṣliḥ lī sha''nī kullah, wa lā takilnī ilā nafsī ṭarfata ʿayn.',
    'O The Ever Living, The Sustainer of all; I seek assistance through Your mercy. Rectify all of my affairs and do not entrust me to myself for the blink of an eye.',
    'Ô Vivant, ô Celui qui subsiste par Lui-même ; c''est par Ta miséricorde que j''implore secours. Améliore toutes mes affaires et ne me confie pas à moi-même, ne serait-ce que le temps d''un clin d''œil.',
    'O Lebendiger, o Beständiger; durch Deine Barmherzigkeit suche ich Hilfe. Bring all meine Angelegenheiten in Ordnung und überlass mich nicht mir selbst, auch nicht für einen Augenblick.',
    'O Eeuwig Levende, o Onderhouder van alles; door Uw barmhartigheid zoek ik hulp. Breng al mijn zaken in orde en laat mij niet aan mijzelf over, zelfs niet voor een oogwenk.',
    'Ey Hayy (diri) olan, ey Kayyûm (her şeyi ayakta tutan)! Rahmetinle yardım dilerim. Bütün işlerimi düzelt ve beni göz açıp kapayıncaya kadar bile nefsime bırakma.',
    'Wahai Yang Maha Hidup, wahai Yang Maha Berdiri Sendiri; dengan rahmat-Mu aku memohon pertolongan. Perbaikilah seluruh urusanku dan janganlah Engkau serahkan aku kepada diriku sendiri walau sekejap mata.',
    'اے زندہ! اے سب کو تھامنے والے! میں تیری رحمت کے وسیلے سے مدد مانگتا ہوں۔ میرے سارے کام درست فرما دے اور مجھے پلک جھپکنے کے برابر بھی میرے نفس کے حوالے نہ کر۔',
    'হে চিরঞ্জীব! হে সর্বসত্তার ধারক! তোমার রহমতের অসিলায় আমি সাহায্য চাই। আমার সকল কাজ ঠিক করে দাও এবং চোখের পলক পরিমাণ সময়ের জন্যও আমাকে আমার নফসের কাছে সোপর্দ করো না।',
    'Wahai Yang Maha Hidup, wahai Yang Maha Berdiri Sendiri; dengan rahmat-Mu aku memohon pertolongan. Perbaikilah segala urusanku dan janganlah Engkau serahkan aku kepada diriku sendiri walau sekelip mata.',
    'О Живой, о Вседержитель! Милостью Твоей я взываю о помощи. Приведи в порядок все мои дела и не оставляй меня самому себе даже на мгновение ока.',
    'In the morning, between Fajr and sunrise', 'Le matin, entre le Fajr et le lever du soleil', 'في الصباح، بين الفجر وطلوع الشمس',
    'Nasā''ī, ʿAmal al-Yawm wa-l-Laylah 570', 'Nasā''ī, ʿAmal al-Yawm wa-l-Laylah 570', 'النسائي، عمل اليوم والليلة ٥٧٠',
    1::smallint, 5::smallint
  ),
  -- ═══════════════════ 8. Fulfil your obligation to thank Allah ═════════════
  (
    'اَللّٰهُمَّ مَا أَصْبَحَ بِيْ مِنْ نِّعْمَةٍ أَوْ بِأَحَدٍ مِّنْ خَلْقِكَ ، فَمِنْكَ وَحْدَكَ لَا شَرِيْكَ لَكَ ، فَلَكَ الْحَمْدُ وَلَكَ الشُّكْرُ.',
    'Allāhumma mā aṣbaḥa bī min niʿmatin aw bi-aḥadim-min khalqik, fa-minka waḥdaka lā sharīka lak, fa laka-l-ḥamdu wa laka-sh-shukr.',
    'O Allah, all the favours that I or anyone from Your creation has received in the morning, are from You Alone. You have no partner. To You Alone belong all praise and all thanks.',
    'Ô Allah, tout bienfait que moi ou l''une de Tes créatures avons reçu ce matin vient de Toi Seul, Tu n''as point d''associé. À Toi la louange et à Toi la gratitude.',
    'O Allah, jede Gunst, die mir oder irgendeinem Deiner Geschöpfe am Morgen zuteilwird, kommt von Dir allein, Du hast keinen Teilhaber. Dir gebührt alles Lob und Dir gebührt aller Dank.',
    'O Allah, elke gunst die mij of een van Uw schepselen vanmorgen ten deel valt, komt van U alleen, U hebt geen deelgenoot. U komt alle lof toe en U komt alle dank toe.',
    'Allah''ım, bu sabah bana ya da yarattıklarından herhangi birine ulaşan her nimet yalnız Sendendir; Senin ortağın yoktur. Hamd Sana mahsustur ve şükür Sana mahsustur.',
    'Ya Allah, segala nikmat yang kuterima atau yang diterima oleh siapa pun dari makhluk-Mu pada pagi ini, hanyalah dari-Mu semata, tiada sekutu bagi-Mu. Maka bagi-Mu segala puji dan bagi-Mu segala syukur.',
    'اے اللہ! جو نعمت بھی اس صبح مجھے یا تیری مخلوق میں سے کسی کو ملی، وہ تیری ہی طرف سے ہے، تیرا کوئی شریک نہیں۔ پس تیرے ہی لیے ہر تعریف ہے اور تیرا ہی شکر ہے۔',
    'হে আল্লাহ! এই সকালে আমার বা তোমার সৃষ্টির কারও কাছে যে নিয়ামতই পৌঁছেছে, তা কেবল তোমার পক্ষ থেকেই; তোমার কোনো শরিক নেই। সুতরাং সমস্ত প্রশংসা তোমারই এবং সমস্ত শুকরিয়া তোমারই।',
    'Ya Allah, segala nikmat yang kuterima atau yang diterima oleh sesiapa pun daripada makhluk-Mu pada pagi ini, hanyalah daripada-Mu semata, tiada sekutu bagi-Mu. Maka bagi-Mu segala pujian dan bagi-Mu segala kesyukuran.',
    'О Аллах, всякое благо, которое получил я или кто-либо из Твоих творений этим утром, — лишь от Тебя одного, нет у Тебя сотоварища. Тебе хвала и Тебе благодарность.',
    'In the morning', 'Le matin', 'في الصباح',
    'Abū Dāwūd 5073', 'Abū Dāwūd 5073', 'سنن أبي داود ٥٠٧٣',
    1::smallint, 5::smallint
  ),
  -- ═══════════════════ 9. Start the day renewing Tawhid ═════════════════════
  (
    'أَصْبَحْنَا عَلَىٰ فِطْرَةِ الْإِسْلَامِ ، وَعَلَىٰ كَلِمَةِ الْإِخْلَاصِ ، وَعَلَىٰ دِيْنِ نَبِيِّنَا مُحَمَّدٍ ، وَعَلَىٰ مِلَّةِ أَبِيْنَا إِبْرَاهِيْمَ حَنِيْفًا مُّسْلِمًا وَّمَا كَانَ مِنَ الْمُشْرِكِيْنَ.',
    'Aṣbaḥnā ʿalā fiṭrati-l-islām, wa ʿalā kalimati-l-ikhlāṣ, wa ʿalā dīni Nabiyyinā Muḥammadin ṣallallāhu ʿalayhi wa sallam, wa ʿalā millati abīnā Ibrāhīma ḥanīfam-muslima, wa mā kāna min-l-mushrikīn.',
    'We have entered the morning upon the natural religion of Islam, the statement of pure faith (i.e. Shahādah), the religion of our Prophet Muhammad ﷺ and upon the way of our father Ibrāhīm, who turned away from all that is false, having surrendered to Allah, and he was not of the polytheists.',
    'Nous voici au matin sur la religion naturelle de l''Islam, sur la parole de la foi pure (la Shahādah), sur la religion de notre Prophète Muhammad ﷺ et sur la voie de notre père Ibrāhīm, monothéiste pur soumis à Allah, et il n''était pas du nombre des associateurs.',
    'Wir sind in den Morgen eingetreten auf der natürlichen Veranlagung des Islam, auf dem Wort des reinen Glaubens (der Schahāda), auf der Religion unseres Propheten Muhammad ﷺ und auf dem Weg unseres Vaters Ibrāhīm, der sich aufrichtig Allah ergab und nicht zu den Götzendienern gehörte.',
    'Wij zijn de ochtend ingegaan op de natuurlijke aanleg van de islam, op het woord van het zuivere geloof (de Shahāda), op de religie van onze Profeet Mohammed ﷺ en op de weg van onze vader Ibrāhīm, die zich oprecht aan Allah overgaf en niet tot de afgodendienaars behoorde.',
    'İslam fıtratı üzere, ihlâs kelimesi üzere, Peygamberimiz Muhammed''in ﷺ dini üzere ve babamız İbrahim''in dosdoğru, hakka yönelmiş, Müslüman olan ve müşriklerden olmayan milleti üzere sabahladık.',
    'Kami memasuki waktu pagi di atas fitrah Islam, di atas kalimat keikhlasan (syahadat), di atas agama Nabi kami Muhammad ﷺ, dan di atas agama bapak kami Ibrahim yang lurus lagi berserah diri, dan dia bukanlah termasuk orang-orang musyrik.',
    'ہم نے اسلام کی فطرت پر، کلمۂ اخلاص پر، اپنے نبی محمد ﷺ کے دین پر، اور اپنے باپ ابراہیم کی ملت پر صبح کی، جو یکسو ہو کر فرماں بردار تھے اور مشرکوں میں سے نہ تھے۔',
    'আমরা ইসলামের ফিতরাতের উপর, ইখলাসের কালিমার উপর, আমাদের নবী মুহাম্মাদ ﷺ-এর দ্বীনের উপর এবং আমাদের পিতা ইবরাহীমের মিল্লাতের উপর সকালে উপনীত হয়েছি, যিনি একনিষ্ঠভাবে আত্মসমর্পণকারী ছিলেন এবং মুশরিকদের অন্তর্ভুক্ত ছিলেন না।',
    'Kami memasuki waktu pagi di atas fitrah Islam, di atas kalimah keikhlasan (syahadah), di atas agama Nabi kami Muhammad ﷺ, dan di atas agama bapa kami Ibrahim yang lurus lagi berserah diri, dan dia bukanlah daripada golongan musyrik.',
    'Мы вступили в утро в естестве Ислама, на слове чистой веры (шахады), на религии нашего Пророка Мухаммада ﷺ и на пути отца нашего Ибрахима, который был склонен к истине, предан Аллаху и не был из числа многобожников.',
    'In the morning', 'Le matin', 'في الصباح',
    'Aḥmad 15360', 'Aḥmad 15360', 'مسند أحمد ١٥٣٦٠',
    1::smallint, 5::smallint
  ),
  -- ═══════════════════ 10. Start the morning praising Allah ═════════════════
  (
    'أَصْبَحْتُ أُثْنِيْ عَلَيْكَ حَمْدًا ، وَأَشْهَدُ أَنْ لَّا إِلٰهَ إِلَّا اللّٰهُ.',
    'Aṣbaḥtu uthnī ʿalayka ḥamdā, wa ash-hadu al-lā ilāha illā-llāh.',
    'I have entered the morning praising You, and I bear witness that there is no god worthy of worship but Allah.',
    'Me voici au matin, Te louant, et je témoigne qu''il n''y a de divinité digne d''adoration qu''Allah.',
    'Ich bin in den Morgen eingetreten, indem ich Dich lobe, und ich bezeuge, dass es keinen Gott außer Allah gibt.',
    'Ik ben de ochtend ingegaan terwijl ik U prijs, en ik getuig dat er geen god is die aanbidding waard is behalve Allah.',
    'Sana hamd ederek sabahladım ve şahitlik ederim ki Allah''tan başka ibadete layık ilah yoktur.',
    'Aku memasuki waktu pagi dalam keadaan memuji-Mu, dan aku bersaksi bahwa tidak ada tuhan yang berhak disembah selain Allah.',
    'میں نے اس حال میں صبح کی کہ میں تیری حمد بیان کرتا ہوں، اور میں گواہی دیتا ہوں کہ اللہ کے سوا کوئی معبودِ برحق نہیں۔',
    'আমি তোমার প্রশংসা করতে করতে সকালে উপনীত হয়েছি, এবং আমি সাক্ষ্য দিচ্ছি যে আল্লাহ ছাড়া ইবাদতের যোগ্য কোনো উপাস্য নেই।',
    'Aku memasuki waktu pagi dalam keadaan memuji-Mu, dan aku bersaksi bahawa tiada tuhan yang berhak disembah melainkan Allah.',
    'Я вступил в утро, восхваляя Тебя, и свидетельствую, что нет божества, достойного поклонения, кроме Аллаха.',
    'In the morning', 'Le matin', 'في الصباح',
    'Nasā''ī, al-Sunan al-Kubrā 10331', 'Nasā''ī, al-Sunan al-Kubrā 10331', 'النسائي، السنن الكبرى ١٠٣٣١',
    3::smallint, 5::smallint
  ),
  -- ═══════════════════ 11. Ask Allah for a good day ═════════════════════════
  (
    'أَصْبَحْنَا وَأَصْبَحَ الْمُلْكُ لِلّٰهِ وَالْحَمْدُ لِلّٰهِ ، لَا إِلٰهَ إِلَّا اللّٰهُ وَحْدَهُ لَا شَرِيْكَ لَهُ ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ ، وَهُوَ عَلَىٰ كُلِّ شَيْءٍ قَدِيْرٌ ، رَبِّ أَسْأَلُكَ خَيْرَ مَا فِيْ هٰذَا الْيَوْمِ وَخَيْرَ مَا بَعْدَهُ ، وَأَعُوْذُ بِكَ مِنْ شَرِّ مَا فِيْ هٰذَا الْيَوْمِ وَشَرِّ مَا بَعْدَهُ ، رَبِّ أَعُوْذُ بِكَ مِنَ الْكَسَلِ وَسُوْءِ الْكِبَرِ ، رَبِّ أَعُوْذُ بِكَ مِنْ عَذَابٍ فِي النَّارِ وَعَذَابٍ فِي الْقَبْرِ.',
    'Aṣbaḥnā wa aṣbaḥa-l-mulku li-llāh, wa-l-ḥamdu li-llāh, lā ilāha illa-llāhu waḥdahū lā sharīka lah, lahu-l-mulku wa lahu-l-ḥamd, wa huwa ʿalā kulli shay''in Qadīr, Rabbi as''aluka khayra mā fī hādha-l-yawmi wa khayra mā baʿdah, wa aʿūdhu bika min sharri mā fī hādha-l-yawmi wa sharri mā baʿdah. Rabbi aʿūdhu bika mina-l-kasali wa sū''i-l-kibar, Rabbi aʿūdhu bika min ʿadhābin fi-n-nāri wa ʿadhābin fi-l-qabr.',
    'We have entered the morning and at this very time the whole kingdom belongs to Allah. All praise is due to Allah. There is no god worthy of worship except Allah, the One; He has no partner with Him. The entire kingdom belongs solely to Him, to Him is all praise due, and He is All-Powerful over everything. My Lord, I ask You for the good that is in this day and the good that follows it, and I seek Your protection from the evil that is in this day and from the evil that follows it. My Lord, I seek Your protection from laziness and the misery of old age. My Lord, I seek Your protection from the torment of the Hell-fire and the punishment of the grave.',
    'Nous voici au matin et la royauté tout entière appartient à Allah en cet instant. Louange à Allah. Il n''y a de divinité digne d''adoration qu''Allah, l''Unique, sans associé. À Lui la royauté, à Lui la louange, et Il est Omnipotent. Mon Seigneur, je Te demande le bien de ce jour et le bien de ce qui le suit, et je cherche Ta protection contre le mal de ce jour et le mal de ce qui le suit. Mon Seigneur, je cherche Ta protection contre la paresse et la misère de la vieillesse. Mon Seigneur, je cherche Ta protection contre le châtiment du Feu et le châtiment de la tombe.',
    'Wir sind in den Morgen eingetreten, und in diesem Augenblick gehört die ganze Herrschaft Allah. Alles Lob gebührt Allah. Es gibt keinen Gott außer Allah, dem Einzigen, ohne Teilhaber. Sein ist die Herrschaft und Sein ist das Lob, und Er hat Macht über alle Dinge. Mein Herr, ich bitte Dich um das Gute dieses Tages und das Gute dessen, was danach kommt, und ich suche Schutz bei Dir vor dem Übel dieses Tages und dem Übel dessen, was danach kommt. Mein Herr, ich suche Schutz bei Dir vor Faulheit und dem Elend des Greisenalters. Mein Herr, ich suche Schutz bei Dir vor der Strafe des Feuers und der Strafe des Grabes.',
    'Wij zijn de ochtend ingegaan en op dit moment behoort het hele koninkrijk aan Allah. Alle lof komt Allah toe. Er is geen god die aanbidding waard is behalve Allah, de Enige, zonder deelgenoot. Aan Hem behoort het koninkrijk en aan Hem komt alle lof toe, en Hij is tot alle dingen in staat. Mijn Heer, ik vraag U om het goede van deze dag en het goede dat erop volgt, en ik zoek bescherming bij U tegen het kwaad van deze dag en het kwaad dat erop volgt. Mijn Heer, ik zoek bescherming bij U tegen luiheid en de ellende van de ouderdom. Mijn Heer, ik zoek bescherming bij U tegen de bestraffing van het Vuur en de bestraffing van het graf.',
    'Sabahladık ve bu anda bütün mülk Allah''ındır. Hamd Allah''a mahsustur. Allah''tan başka ibadete layık ilah yoktur, O tektir, ortağı yoktur. Mülk O''nundur, hamd O''nundur ve O her şeye kadirdir. Rabbim, bugünün ve sonrasının hayrını Senden isterim; bugünün ve sonrasının şerrinden de Sana sığınırım. Rabbim, tembellikten ve ihtiyarlığın kötülüğünden Sana sığınırım. Rabbim, cehennem azabından ve kabir azabından Sana sığınırım.',
    'Kami memasuki waktu pagi dan pada saat ini seluruh kerajaan milik Allah. Segala puji bagi Allah. Tidak ada tuhan yang berhak disembah selain Allah Yang Maha Esa, tiada sekutu bagi-Nya. Milik-Nya kerajaan dan bagi-Nya segala puji, dan Dia Maha Kuasa atas segala sesuatu. Tuhanku, aku memohon kepada-Mu kebaikan hari ini dan kebaikan sesudahnya, dan aku berlindung kepada-Mu dari keburukan hari ini dan keburukan sesudahnya. Tuhanku, aku berlindung kepada-Mu dari kemalasan dan keburukan usia tua. Tuhanku, aku berlindung kepada-Mu dari azab neraka dan azab kubur.',
    'ہم نے صبح کی اور اس وقت ساری بادشاہی اللہ ہی کی ہے، اور تمام تعریف اللہ کے لیے ہے۔ اللہ کے سوا کوئی معبودِ برحق نہیں، وہ اکیلا ہے، اس کا کوئی شریک نہیں۔ اسی کی بادشاہی ہے اور اسی کی تعریف ہے، اور وہ ہر چیز پر قادر ہے۔ اے میرے رب! میں تجھ سے اس دن کی بھلائی اور اس کے بعد کی بھلائی مانگتا ہوں، اور اس دن کے شر اور اس کے بعد کے شر سے تیری پناہ مانگتا ہوں۔ اے میرے رب! میں سستی اور بڑھاپے کی خرابی سے تیری پناہ مانگتا ہوں۔ اے میرے رب! میں آگ کے عذاب اور قبر کے عذاب سے تیری پناہ مانگتا ہوں۔',
    'আমরা সকালে উপনীত হয়েছি এবং এই মুহূর্তে সমস্ত রাজত্ব আল্লাহরই, আর সমস্ত প্রশংসা আল্লাহরই। আল্লাহ ছাড়া ইবাদতের যোগ্য কোনো উপাস্য নেই, তিনি একক, তাঁর কোনো শরিক নেই। রাজত্ব তাঁরই এবং প্রশংসা তাঁরই, আর তিনি সর্ববিষয়ে ক্ষমতাবান। হে আমার রব! আমি তোমার কাছে এই দিনের কল্যাণ ও এর পরবর্তী কল্যাণ চাই, এবং এই দিনের অনিষ্ট ও এর পরবর্তী অনিষ্ট থেকে তোমার আশ্রয় চাই। হে আমার রব! আমি অলসতা ও বার্ধক্যের মন্দ থেকে তোমার আশ্রয় চাই। হে আমার রব! আমি জাহান্নামের আযাব ও কবরের আযাব থেকে তোমার আশ্রয় চাই।',
    'Kami memasuki waktu pagi dan pada saat ini seluruh kerajaan milik Allah. Segala puji bagi Allah. Tiada tuhan yang berhak disembah melainkan Allah Yang Maha Esa, tiada sekutu bagi-Nya. Milik-Nya kerajaan dan bagi-Nya segala pujian, dan Dia Maha Kuasa atas segala sesuatu. Tuhanku, aku memohon kepada-Mu kebaikan hari ini dan kebaikan sesudahnya, dan aku berlindung kepada-Mu daripada keburukan hari ini dan keburukan sesudahnya. Tuhanku, aku berlindung kepada-Mu daripada kemalasan dan keburukan usia tua. Tuhanku, aku berlindung kepada-Mu daripada azab neraka dan azab kubur.',
    'Мы вступили в утро, и в этот миг вся власть принадлежит Аллаху. Хвала Аллаху. Нет божества, достойного поклонения, кроме Аллаха Единого, нет у Него сотоварища. Ему принадлежит власть и Ему хвала, и Он над всякой вещью властен. Господь мой, прошу у Тебя блага этого дня и блага того, что после него, и прибегаю к Тебе от зла этого дня и зла того, что после него. Господь мой, прибегаю к Тебе от лени и тягот старости. Господь мой, прибегаю к Тебе от мучения в Огне и мучения в могиле.',
    'In the morning', 'Le matin', 'في الصباح',
    'Muslim 2723', 'Muslim 2723', 'صحيح مسلم ٢٧٢٣',
    1::smallint, 5::smallint
  ),
  -- ═══════════════════ 12. Ask Allah to bless your day ══════════════════════
  (
    'أَصْبَحْنَا وَأَصْبَحَ الْمُلْكُ لِلّٰهِ رَبِّ الْعَالَمِيْنَ ، اَللّٰهُمَّ إِنِّيْ أَسْأَلُكَ خَيْرَ هٰذَا الْيَوْمِ ، فَتْحَهُ وَنَصْرَهُ وَنُوْرَهُ وَبَرَكَتَهُ وَهُدَاهُ ، وَأَعُوْذُ بِكَ مِنْ شَرِّ مَا فِيْهِ وَشَرِّ مَا بَعْدَهُ.',
    'Aṣbaḥnā wa aṣbaḥa-l-mulku li-llāhi Rabbi-l-ʿālamīn, Allāhumma innī as''aluka khayra hādha-l-yawm, fatḥahū wa naṣrahū wa nūrahū wa barakatahū wa hudāh, wa aʿūdhu bika min sharri mā fīhi wa sharri mā baʿdah.',
    'We have entered the morning and at this very time the whole kingdom belongs to Allah, Lord of the Worlds. O Allah, I ask You for the goodness of this day: its victory, its help, its light, and its blessings and guidance. I seek Your protection from the evil that is in it and from the evil that follows it.',
    'Nous voici au matin et la royauté tout entière appartient à Allah, Seigneur des mondes. Ô Allah, je Te demande le bien de ce jour : son ouverture (succès), son secours, sa lumière, sa bénédiction et sa guidée. Et je cherche Ta protection contre le mal qu''il contient et le mal de ce qui le suit.',
    'Wir sind in den Morgen eingetreten, und in diesem Augenblick gehört die ganze Herrschaft Allah, dem Herrn der Welten. O Allah, ich bitte Dich um das Gute dieses Tages: seinen Sieg, seine Hilfe, sein Licht, seinen Segen und seine Rechtleitung. Und ich suche Schutz bei Dir vor dem Übel, das er enthält, und dem Übel dessen, was danach kommt.',
    'Wij zijn de ochtend ingegaan en op dit moment behoort het hele koninkrijk aan Allah, de Heer der werelden. O Allah, ik vraag U om het goede van deze dag: zijn overwinning, zijn hulp, zijn licht, zijn zegen en zijn leiding. En ik zoek bescherming bij U tegen het kwaad dat erin is en het kwaad dat erop volgt.',
    'Sabahladık ve bu anda bütün mülk âlemlerin Rabbi olan Allah''ındır. Allah''ım, bu günün hayrını Senden isterim: onun fethini, yardımını, nurunu, bereketini ve hidayetini. İçindeki şerden ve sonrasının şerrinden de Sana sığınırım.',
    'Kami memasuki waktu pagi dan pada saat ini seluruh kerajaan milik Allah, Tuhan semesta alam. Ya Allah, aku memohon kepada-Mu kebaikan hari ini: kemenangannya, pertolongannya, cahayanya, keberkahannya, dan petunjuknya. Dan aku berlindung kepada-Mu dari keburukan yang ada padanya dan keburukan sesudahnya.',
    'ہم نے صبح کی اور اس وقت ساری بادشاہی اللہ، تمام جہانوں کے رب کی ہے۔ اے اللہ! میں تجھ سے اس دن کی بھلائی مانگتا ہوں: اس کی فتح، اس کی مدد، اس کا نور، اس کی برکت اور اس کی ہدایت۔ اور اس میں جو شر ہے اور اس کے بعد کے شر سے تیری پناہ مانگتا ہوں۔',
    'আমরা সকালে উপনীত হয়েছি এবং এই মুহূর্তে সমস্ত রাজত্ব আল্লাহর, যিনি সকল জগতের রব। হে আল্লাহ! আমি তোমার কাছে এই দিনের কল্যাণ চাই: এর বিজয়, এর সাহায্য, এর আলো, এর বরকত ও এর হিদায়াত। আর এর মধ্যে যা অনিষ্ট আছে এবং এর পরবর্তী অনিষ্ট থেকে তোমার আশ্রয় চাই।',
    'Kami memasuki waktu pagi dan pada saat ini seluruh kerajaan milik Allah, Tuhan sekalian alam. Ya Allah, aku memohon kepada-Mu kebaikan hari ini: kemenangannya, pertolongannya, cahayanya, keberkatannya, dan petunjuknya. Dan aku berlindung kepada-Mu daripada keburukan yang ada padanya dan keburukan sesudahnya.',
    'Мы вступили в утро, и в этот миг вся власть принадлежит Аллаху, Господу миров. О Аллах, прошу у Тебя блага этого дня: его победы, его помощи, его света, его благословения и его верного руководства. И прибегаю к Тебе от зла, что в нём, и от зла того, что после него.',
    'In the morning', 'Le matin', 'في الصباح',
    'Abū Dāwūd 5084', 'Abū Dāwūd 5084', 'سنن أبي داود ٥٠٨٤',
    1::smallint, 5::smallint
  ),
  -- ═══════════════════ 13. Get yourself freed from the Hell-fire ════════════
  (
    'اَللّٰهُمَّ إِنِّيْ أَصْبَحْتُ أُشْهِدُكَ ، وَأُشْهِدُ حَمَلَةَ عَرْشِكَ وَمَلَائِكَتَكَ وَجَمِيْعَ خَلْقِكَ ، أَنَّكَ أَنْتَ اللّٰهُ لَا إِلٰهَ إِلَّا أَنْتَ وَحْدَكَ لَا شَرِيْكَ لَكَ ، وَأَنَّ مُحَمَّدًا عَبْدُكَ وَرَسُوْلُكَ.',
    'Allāhumma innī aṣbaḥtu ush-hiduk, wa ush-hidu ḥamlata ʿarshik, wa malā''ikatika wa jamīʿa khalqik, an-naka Anta-llāhu lā ilāha illā Anta waḥdak, lā sharīka lak, wa anna Muḥammadan ʿabduka wa rasūluk.',
    'O Allah, I have entered the morning, and I call upon You, the bearers of Your Throne, Your angels and all creation, to bear witness that surely You are Allah. There is no god worthy of worship except You Alone. You have no partners, and that Muḥammad ﷺ is Your slave and Your Messenger.',
    'Ô Allah, me voici au matin, et je Te prends à témoin, ainsi que les porteurs de Ton Trône, Tes anges et toute Ta création, que Tu es bien Allah ; il n''y a de divinité digne d''adoration que Toi Seul, sans associé, et que Muhammad ﷺ est Ton serviteur et Ton Messager.',
    'O Allah, ich bin in den Morgen eingetreten, und ich rufe Dich, die Träger Deines Thrones, Deine Engel und die gesamte Schöpfung zu Zeugen an, dass Du wahrlich Allah bist; es gibt keinen Gott außer Dir allein, ohne Teilhaber, und dass Muhammad ﷺ Dein Diener und Dein Gesandter ist.',
    'O Allah, ik ben de ochtend ingegaan, en ik roep U, de dragers van Uw Troon, Uw engelen en de hele schepping op om te getuigen dat U waarlijk Allah bent; er is geen god die aanbidding waard is behalve U alleen, zonder deelgenoot, en dat Mohammed ﷺ Uw dienaar en Uw Boodschapper is.',
    'Allah''ım, sabahladım ve Seni, Arşının taşıyıcılarını, meleklerini ve bütün yaratıklarını şahit tutarım ki gerçekten Sen Allah''sın; Senden başka ibadete layık ilah yoktur, teksin, ortağın yoktur ve Muhammed ﷺ Senin kulun ve elçindir.',
    'Ya Allah, aku memasuki waktu pagi, dan aku mempersaksikan Engkau, para pemikul Arasy-Mu, para malaikat-Mu, dan seluruh makhluk-Mu, bahwa sesungguhnya Engkau adalah Allah; tidak ada tuhan yang berhak disembah selain Engkau semata, tiada sekutu bagi-Mu, dan bahwa Muhammad ﷺ adalah hamba dan utusan-Mu.',
    'اے اللہ! میں نے صبح کی اور میں تجھے، تیرے عرش کے اٹھانے والوں کو، تیرے فرشتوں کو اور تیری ساری مخلوق کو گواہ بناتا ہوں کہ بے شک تُو ہی اللہ ہے، تیرے سوا کوئی معبودِ برحق نہیں، تُو اکیلا ہے، تیرا کوئی شریک نہیں، اور بے شک محمد ﷺ تیرے بندے اور تیرے رسول ہیں۔',
    'হে আল্লাহ! আমি সকালে উপনীত হয়েছি এবং আমি তোমাকে, তোমার আরশ বহনকারীদেরকে, তোমার ফেরেশতাদেরকে ও তোমার সমস্ত সৃষ্টিকে সাক্ষী রাখছি যে নিশ্চয়ই তুমিই আল্লাহ, তুমি ছাড়া ইবাদতের যোগ্য কোনো উপাস্য নেই, তুমি একক, তোমার কোনো শরিক নেই, এবং নিশ্চয়ই মুহাম্মাদ ﷺ তোমার বান্দা ও তোমার রাসূল।',
    'Ya Allah, aku memasuki waktu pagi, dan aku mempersaksikan Engkau, para pemikul Arasy-Mu, para malaikat-Mu, dan seluruh makhluk-Mu, bahawa sesungguhnya Engkaulah Allah; tiada tuhan yang berhak disembah melainkan Engkau semata, tiada sekutu bagi-Mu, dan bahawa Muhammad ﷺ ialah hamba dan utusan-Mu.',
    'О Аллах, я вступил в утро и призываю Тебя в свидетели, а также носителей Твоего Престола, Твоих ангелов и все Твоё творение, что поистине Ты — Аллах, нет божества, достойного поклонения, кроме Тебя одного, нет у Тебя сотоварища, и что Мухаммад ﷺ — Твой раб и Твой посланник.',
    'In the morning', 'Le matin', 'في الصباح',
    'Abū Dāwūd 5069', 'Abū Dāwūd 5069', 'سنن أبي داود ٥٠٦٩',
    4::smallint, 5::smallint
  ),
  -- ═══════════════════ 14. Upon entering the morning ════════════════════════
  (
    'اَللّٰهُمَّ بِكَ أَصْبَحْنَا وَبِكَ أَمْسَيْنَا وَبِكَ نَحْيَا وَبِكَ نَمُوْتُ وَإِلَيْكَ النُّشُوْرُ.',
    'Allāhumma bika aṣbaḥnā wa bika amsaynā wa bika naḥyā wa bika namūtu wa ilayka-n-nushūr.',
    'O Allah, by You we have entered the morning and by You we enter upon the evening. By You, we live and we die, and to You is the resurrection.',
    'Ô Allah, c''est par Toi que nous voici au matin et par Toi que nous parvenons au soir, par Toi que nous vivons et par Toi que nous mourons, et c''est vers Toi qu''est la résurrection.',
    'O Allah, durch Dich sind wir in den Morgen eingetreten und durch Dich treten wir in den Abend ein, durch Dich leben wir und durch Dich sterben wir, und zu Dir ist die Auferstehung.',
    'O Allah, door U zijn wij de ochtend ingegaan en door U gaan wij de avond in, door U leven wij en door U sterven wij, en tot U is de opstanding.',
    'Allah''ım, Seninle sabahladık, Seninle akşamladık, Seninle yaşar, Seninle ölürüz ve dönüş ancak Sanadır.',
    'Ya Allah, dengan-Mu kami memasuki waktu pagi dan dengan-Mu kami memasuki waktu petang, dengan-Mu kami hidup dan dengan-Mu kami mati, dan kepada-Mu tempat kembali (kebangkitan).',
    'اے اللہ! تیری ہی توفیق سے ہم نے صبح کی اور تیری ہی توفیق سے ہم نے شام کی، تیری ہی توفیق سے ہم جیتے ہیں اور تیری ہی توفیق سے ہم مرتے ہیں، اور تیری ہی طرف اٹھ کر جانا ہے۔',
    'হে আল্লাহ! তোমারই (অনুগ্রহে) আমরা সকালে উপনীত হয়েছি এবং তোমারই (অনুগ্রহে) সন্ধ্যায় উপনীত হই, তোমারই (অনুগ্রহে) আমরা বাঁচি ও মরি, এবং তোমারই দিকে পুনরুত্থান।',
    'Ya Allah, dengan-Mu kami memasuki waktu pagi dan dengan-Mu kami memasuki waktu petang, dengan-Mu kami hidup dan dengan-Mu kami mati, dan kepada-Mu tempat kembali (kebangkitan).',
    'О Аллах, благодаря Тебе мы вступили в утро и благодаря Тебе вступаем в вечер, благодаря Тебе мы живём и благодаря Тебе умираем, и к Тебе — воскрешение.',
    'In the morning', 'Le matin', 'في الصباح',
    'al-Adab al-Mufrad 1199', 'al-Adab al-Mufrad 1199', 'الأدب المفرد ١١٩٩',
    1::smallint, 5::smallint
  ),
  -- ═══════════════════ 15. Ask Allah for good health and protection ═════════
  (
    'اَللّٰهُمَّ عَافِنِيْ فِيْ بَدَنِيْ ، اَللّٰهُمَّ عَافِنِيْ فِيْ سَمْعِيْ ، اَللّٰهُمَّ عَافِنِيْ فِيْ بَصَرِيْ ، لَا إِلٰهَ إِلَّا أَنْتَ ، اَللّٰهُمَّ إِنِّيْ أَعُوْذُ بِكَ مِنَ الْكُفْرِ وَالْفَقْرِ، وأَعُوْذُ بِكَ مِنْ عَذَابِ الْقَبْرِ، لَا إِلٰهَ إِلَّا أَنْتَ.',
    'Allāhumma ʿāfinī fī badanī, Allāhumma ʿāfinī fī samʿī, Allāhumma ʿāfinī fī baṣarī, lā ilāha illā Ant, Allāhumma innī aʿūdhu bika mina-l-kufri wa-l-faqr, wa aʿūdhu bika min ʿadhābi-l-qabr, lā ilāha illā Ant.',
    'O Allah, grant me well-being in my body. O Allah, grant me well-being in my hearing. O Allah, grant me well-being in my sight. There is no god worthy of worship except You. O Allah, I seek Your protection from disbelief and poverty and I seek Your protection from the punishment of the grave. There is no god worthy of worship except You.',
    'Ô Allah, accorde-moi la santé dans mon corps. Ô Allah, accorde-moi la santé dans mon ouïe. Ô Allah, accorde-moi la santé dans ma vue. Il n''y a de divinité digne d''adoration que Toi. Ô Allah, je cherche Ta protection contre la mécréance et la pauvreté, et je cherche Ta protection contre le châtiment de la tombe. Il n''y a de divinité digne d''adoration que Toi.',
    'O Allah, schenke mir Wohlergehen in meinem Körper. O Allah, schenke mir Wohlergehen in meinem Gehör. O Allah, schenke mir Wohlergehen in meinem Sehvermögen. Es gibt keinen Gott außer Dir. O Allah, ich suche Schutz bei Dir vor Unglauben und Armut, und ich suche Schutz bei Dir vor der Strafe des Grabes. Es gibt keinen Gott außer Dir.',
    'O Allah, schenk mij welzijn in mijn lichaam. O Allah, schenk mij welzijn in mijn gehoor. O Allah, schenk mij welzijn in mijn gezichtsvermogen. Er is geen god die aanbidding waard is behalve U. O Allah, ik zoek bescherming bij U tegen ongeloof en armoede, en ik zoek bescherming bij U tegen de bestraffing van het graf. Er is geen god die aanbidding waard is behalve U.',
    'Allah''ım, bedenime afiyet ver. Allah''ım, işitmeme afiyet ver. Allah''ım, görmeme afiyet ver. Senden başka ibadete layık ilah yoktur. Allah''ım, küfürden ve fakirlikten Sana sığınırım; kabir azabından da Sana sığınırım. Senden başka ibadete layık ilah yoktur.',
    'Ya Allah, anugerahkanlah kesehatan pada tubuhku. Ya Allah, anugerahkanlah kesehatan pada pendengaranku. Ya Allah, anugerahkanlah kesehatan pada penglihatanku. Tidak ada tuhan yang berhak disembah selain Engkau. Ya Allah, aku berlindung kepada-Mu dari kekufuran dan kefakiran, dan aku berlindung kepada-Mu dari azab kubur. Tidak ada tuhan yang berhak disembah selain Engkau.',
    'اے اللہ! مجھے میرے بدن میں عافیت دے۔ اے اللہ! مجھے میری سماعت میں عافیت دے۔ اے اللہ! مجھے میری بینائی میں عافیت دے۔ تیرے سوا کوئی معبودِ برحق نہیں۔ اے اللہ! میں کفر اور فقر سے تیری پناہ مانگتا ہوں، اور قبر کے عذاب سے تیری پناہ مانگتا ہوں۔ تیرے سوا کوئی معبودِ برحق نہیں۔',
    'হে আল্লাহ! আমার শরীরে নিরাপত্তা (সুস্থতা) দাও। হে আল্লাহ! আমার শ্রবণে নিরাপত্তা দাও। হে আল্লাহ! আমার দৃষ্টিতে নিরাপত্তা দাও। তুমি ছাড়া ইবাদতের যোগ্য কোনো উপাস্য নেই। হে আল্লাহ! আমি কুফর ও দারিদ্র্য থেকে তোমার আশ্রয় চাই, এবং কবরের আযাব থেকে তোমার আশ্রয় চাই। তুমি ছাড়া ইবাদতের যোগ্য কোনো উপাস্য নেই।',
    'Ya Allah, kurniakanlah kesihatan pada tubuhku. Ya Allah, kurniakanlah kesihatan pada pendengaranku. Ya Allah, kurniakanlah kesihatan pada penglihatanku. Tiada tuhan yang berhak disembah melainkan Engkau. Ya Allah, aku berlindung kepada-Mu daripada kekufuran dan kefakiran, dan aku berlindung kepada-Mu daripada azab kubur. Tiada tuhan yang berhak disembah melainkan Engkau.',
    'О Аллах, даруй мне благополучие в моём теле. О Аллах, даруй мне благополучие в моём слухе. О Аллах, даруй мне благополучие в моём зрении. Нет божества, достойного поклонения, кроме Тебя. О Аллах, прибегаю к Тебе от неверия и бедности, и прибегаю к Тебе от мучения в могиле. Нет божества, достойного поклонения, кроме Тебя.',
    'In the morning', 'Le matin', 'في الصباح',
    'Abū Dāwūd 5090; Aḥmad 20430', 'Abū Dāwūd 5090 ; Aḥmad 20430', 'سنن أبي داود ٥٠٩٠؛ مسند أحمد ٢٠٤٣٠',
    3::smallint, 5::smallint
  ),
  -- ═══════════════════ 16. Allah will suffice you in everything ═════════════
  (
    'حَسْبِيَ اللّٰهُ لَا إِلٰهَ إِلَّا هُوَ ، عَلَيْهِ تَوَكَّلْتُ ، وَهُوَ رَبُّ الْعَرْشِ الْعَظِيْمِ.',
    'Ḥasbiya-Allāhu lā ilāha illā Huwa, ʿalayhi tawakkaltu, wa Huwa Rabbu-l-ʿArshi-l-ʿaẓīm.',
    'Allah is sufficient for me. There is no god worthy of worship except Him. I have placed my trust in Him only and He is the Lord of the Magnificent Throne.',
    'Allah me suffit. Il n''y a de divinité digne d''adoration que Lui. C''est en Lui seul que je place ma confiance, et Il est le Seigneur du Trône immense.',
    'Allah genügt mir. Es gibt keinen Gott außer Ihm. Auf Ihn allein vertraue ich, und Er ist der Herr des gewaltigen Thrones.',
    'Allah is mij voldoende. Er is geen god die aanbidding waard is behalve Hij. Op Hem alleen stel ik mijn vertrouwen, en Hij is de Heer van de geweldige Troon.',
    'Allah bana yeter. O''ndan başka ibadete layık ilah yoktur. Yalnız O''na tevekkül ettim ve O, büyük Arşın Rabbidir.',
    'Cukuplah Allah bagiku. Tidak ada tuhan yang berhak disembah selain Dia. Hanya kepada-Nya aku bertawakal, dan Dia adalah Tuhan pemilik Arasy yang agung.',
    'مجھے اللہ کافی ہے، اس کے سوا کوئی معبودِ برحق نہیں، اسی پر میں نے بھروسا کیا، اور وہی عظیم عرش کا رب ہے۔',
    'আল্লাহই আমার জন্য যথেষ্ট। তিনি ছাড়া ইবাদতের যোগ্য কোনো উপাস্য নেই। তাঁরই উপর আমি ভরসা করেছি, এবং তিনিই মহান আরশের রব।',
    'Cukuplah Allah bagiku. Tiada tuhan yang berhak disembah melainkan Dia. Hanya kepada-Nya aku bertawakal, dan Dia ialah Tuhan pemilik Arasy yang agung.',
    'Достаточно мне Аллаха. Нет божества, достойного поклонения, кроме Него. На Него одного я уповаю, и Он — Господь великого Престола.',
    'In the morning', 'Le matin', 'في الصباح',
    'Ibn al-Sunnī 71', 'Ibn al-Sunnī 71', 'ابن السني ٧١',
    7::smallint, 5::smallint
  ),
  -- ═══════════════════ 17. The Prophet ﷺ holds your hand to Paradise ════════
  (
    'رَضِيْتُ بِاللّٰهِ رَبًّا ، وَبِالْإِسْلَامِ دِيْنًا ، وَبِمُحَمَّدٍ نَّبِيًّا.',
    'Raḍītu bi-llāhi Rabbā, wa bi-l-islāmi dīnā, wa bi Muḥammadin-Nabiyyā.',
    'I am pleased with Allah as my Lord, with Islām as my religion and with Muḥammad ﷺ as my Prophet.',
    'Je suis satisfait d''Allah comme Seigneur, de l''Islam comme religion et de Muhammad ﷺ comme Prophète.',
    'Ich bin zufrieden mit Allah als Herrn, mit dem Islam als Religion und mit Muhammad ﷺ als Prophet.',
    'Ik ben tevreden met Allah als mijn Heer, met de islam als mijn religie en met Mohammed ﷺ als mijn Profeet.',
    'Rab olarak Allah''tan, din olarak İslam''dan ve peygamber olarak Muhammed''den ﷺ razı oldum.',
    'Aku ridha Allah sebagai Tuhanku, Islam sebagai agamaku, dan Muhammad ﷺ sebagai Nabiku.',
    'میں اللہ کے رب ہونے پر، اسلام کے دین ہونے پر اور محمد ﷺ کے نبی ہونے پر راضی ہوں۔',
    'আমি আল্লাহকে রব হিসেবে, ইসলামকে দ্বীন হিসেবে এবং মুহাম্মাদ ﷺ-কে নবী হিসেবে পেয়ে সন্তুষ্ট।',
    'Aku reda Allah sebagai Tuhanku, Islam sebagai agamaku, dan Muhammad ﷺ sebagai Nabiku.',
    'Я доволен Аллахом как Господом, Исламом как религией и Мухаммадом ﷺ как Пророком.',
    'In the morning', 'Le matin', 'في الصباح',
    'Aḥmad 18927; Ṭabarānī 838', 'Aḥmad 18927 ; Ṭabarānī 838', 'مسند أحمد ١٨٩٢٧؛ الطبراني ٨٣٨',
    3::smallint, 5::smallint
  ),
  -- ═══════════════════ 18. Protection from all harm ════════════════════════
  (
    'بِسْمِ اللّٰهِ الَّذِيْ لَا يَضُرُّ مَعَ اسْمِهِ شَيْءٌ فِي الْأَرْضِ وَلَا فِي السَّمَاءِ ، وَهُوَ السَّمِيْعُ الْعَلِيْمُ.',
    'Bismi-llāhi-lladhī lā yaḍurru maʿasmihi shay''un fi-l-arḍi wa lā fi-s-samā'', wa Huwa-s-Samīʿu-l-ʿAlīm.',
    'In the Name of Allah, with whose Name nothing can harm in the earth nor in the sky. He is The All-Hearing and All-Knowing.',
    'Au nom d''Allah, avec le Nom duquel rien ne peut nuire sur la terre ni dans le ciel. Et Il est l''Audient, l''Omniscient.',
    'Im Namen Allahs, mit dessen Namen nichts auf der Erde noch im Himmel Schaden zufügen kann. Und Er ist der Allhörende, der Allwissende.',
    'In de Naam van Allah, met wiens Naam niets kan schaden op de aarde noch in de hemel. En Hij is de Alhorende, de Alwetende.',
    'Adıyla yerde ve gökte hiçbir şeyin zarar veremeyeceği Allah''ın adıyla. O, hakkıyla işiten, hakkıyla bilendir.',
    'Dengan nama Allah yang dengan nama-Nya tidak ada sesuatu pun yang dapat membahayakan, baik di bumi maupun di langit. Dan Dia Maha Mendengar lagi Maha Mengetahui.',
    'اللہ کے نام سے، جس کے نام کے ساتھ زمین اور آسمان میں کوئی چیز نقصان نہیں پہنچا سکتی، اور وہ سب کچھ سننے والا، جاننے والا ہے۔',
    'আল্লাহর নামে, যাঁর নামের সঙ্গে জমিনে ও আসমানে কোনো কিছুই ক্ষতি করতে পারে না। আর তিনি সর্বশ্রোতা, সর্বজ্ঞ।',
    'Dengan nama Allah yang dengan nama-Nya tidak ada sesuatu pun yang dapat memudaratkan, baik di bumi mahupun di langit. Dan Dia Maha Mendengar lagi Maha Mengetahui.',
    'С именем Аллаха, с именем Которого ничто не причинит вреда ни на земле, ни на небе. Он — Всеслышащий, Всезнающий.',
    'In the morning', 'Le matin', 'في الصباح',
    'Tirmidhī 3388; Abū Dāwūd 5088', 'Tirmidhī 3388 ; Abū Dāwūd 5088', 'سنن الترمذي ٣٣٨٨؛ سنن أبي داود ٥٠٨٨',
    3::smallint, 5::smallint
  ),
  -- ═══════════════════ 19. Get your sins forgiven ══════════════════════════
  (
    'سُبْحَانَ اللّٰهِ وَبِحَمْدِهِ.',
    'Subḥāna-llāhi wa bi ḥamdih.',
    'Allah is free from imperfection, and all praise is due to Him.',
    'Gloire et pureté à Allah, et à Lui la louange.',
    'Gepriesen sei Allah, und Ihm gebührt alles Lob.',
    'Glorie aan Allah, en Hem komt alle lof toe.',
    'Allah''ı her türlü eksiklikten tenzih ederim ve hamd O''na mahsustur.',
    'Maha Suci Allah dan segala puji bagi-Nya.',
    'اللہ پاک ہے اور اسی کے لیے ہر تعریف ہے۔',
    'আল্লাহ পবিত্র এবং সমস্ত প্রশংসা তাঁরই।',
    'Maha Suci Allah dan segala pujian bagi-Nya.',
    'Пречист Аллах и хвала Ему.',
    'In the morning', 'Le matin', 'في الصباح',
    'Muslim 2692; Bukhārī 6405', 'Muslim 2692 ; Bukhārī 6405', 'صحيح مسلم ٢٦٩٢؛ صحيح البخاري ٦٤٠٥',
    100::smallint, 5::smallint
  ),
  -- ═══════════════════ 20. An unparalleled reward ══════════════════════════
  (
    'لَا إِلٰهَ إِلَّا اللّٰهُ وَحْدَهُ لَا شَرِيْكَ لَهُ ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ ، وَهُوَ عَلَىٰ كُلِّ شَيْءٍ قَدِيْرٌ.',
    'Lā ilāha illā-llāh, waḥdahū lā sharīka lah, lahu-l-mulk, wa lahu-l-ḥamd, wa Huwa ʿalā kulli shay''in Qadīr.',
    'There is no god worthy of worship except Allah. He is Alone and He has no partner whatsoever. To Him Alone belong all sovereignty and all praise. He is over all things All-Powerful.',
    'Il n''y a de divinité digne d''adoration qu''Allah, Seul, sans aucun associé. À Lui la royauté et à Lui la louange, et Il est Omnipotent.',
    'Es gibt keinen Gott außer Allah, Er allein, ohne jeglichen Teilhaber. Sein ist die Herrschaft und Sein ist das Lob, und Er hat Macht über alle Dinge.',
    'Er is geen god die aanbidding waard is behalve Allah, Hij alleen, zonder enige deelgenoot. Aan Hem behoort alle heerschappij en alle lof, en Hij is tot alle dingen in staat.',
    'Allah''tan başka ibadete layık ilah yoktur, O tektir, hiçbir ortağı yoktur. Mülk O''nundur, hamd O''nundur ve O her şeye kadirdir.',
    'Tidak ada tuhan yang berhak disembah selain Allah semata, tiada sekutu bagi-Nya. Milik-Nya kerajaan dan bagi-Nya segala puji, dan Dia Maha Kuasa atas segala sesuatu.',
    'اللہ کے سوا کوئی معبودِ برحق نہیں، وہ اکیلا ہے، اس کا کوئی شریک نہیں۔ اسی کی بادشاہی ہے اور اسی کی تعریف ہے، اور وہ ہر چیز پر قادر ہے۔',
    'আল্লাহ ছাড়া ইবাদতের যোগ্য কোনো উপাস্য নেই, তিনি একক, তাঁর কোনো শরিক নেই। রাজত্ব তাঁরই এবং প্রশংসা তাঁরই, আর তিনি সর্ববিষয়ে ক্ষমতাবান।',
    'Tiada tuhan yang berhak disembah melainkan Allah semata, tiada sekutu bagi-Nya. Milik-Nya kerajaan dan bagi-Nya segala pujian, dan Dia Maha Kuasa atas segala sesuatu.',
    'Нет божества, достойного поклонения, кроме Аллаха одного, нет у Него сотоварища. Ему принадлежит власть и Ему хвала, и Он над всякой вещью властен.',
    'In the morning', 'Le matin', 'في الصباح',
    'Bukhārī 3293; Muslim 2691', 'Bukhārī 3293 ; Muslim 2691', 'صحيح البخاري ٣٢٩٣؛ صحيح مسلم ٢٦٩١',
    100::smallint, 5::smallint
  ),
  -- ═══════════════════ 21. Tasbih, Tahmid and Takbir ═══════════════════════
  (
    'سُبْحَانَ اللّٰهِ ، اَلْحَمْدُ لِلّٰهِ ، اَللّٰهُ أَكْبَرُ.',
    'Subḥāna-llāh, Alḥamdu li-llāh, Allāhu akbar.',
    'Allah is free from imperfection. All praise be to Allah. Allah is the Greatest.',
    'Gloire et pureté à Allah. Louange à Allah. Allah est le plus Grand.',
    'Gepriesen sei Allah. Alles Lob gebührt Allah. Allah ist der Größte.',
    'Glorie aan Allah. Alle lof komt Allah toe. Allah is de Grootste.',
    'Allah''ı tenzih ederim. Hamd Allah''a mahsustur. Allah en büyüktür.',
    'Maha Suci Allah. Segala puji bagi Allah. Allah Maha Besar.',
    'اللہ پاک ہے۔ تمام تعریفیں اللہ کے لیے ہیں۔ اللہ سب سے بڑا ہے۔',
    'আল্লাহ পবিত্র। সমস্ত প্রশংসা আল্লাহর। আল্লাহ সর্বশ্রেষ্ঠ।',
    'Maha Suci Allah. Segala puji bagi Allah. Allah Maha Besar.',
    'Пречист Аллах. Хвала Аллаху. Аллах велик.',
    'In the morning', 'Le matin', 'في الصباح',
    'Nasā''ī, al-Sunan al-Kubrā 10657', 'Nasā''ī, al-Sunan al-Kubrā 10657', 'النسائي، السنن الكبرى ١٠٦٥٧',
    100::smallint, 5::smallint
  ),
  -- ═══════════════════ 22. Ṣalāh upon the Prophet ﷺ ════════════════════════
  (
    'اَللّٰهُمَّ صَلِّ عَلَىٰ مُحَمَّدٍ وَّعَلَىٰ اٰلِ مُحَمَّدٍ ، كَمَا صَلَّيْتَ عَلَىٰ إِبْرَاهِيْمَ وَعَلَىٰ اٰلِ إِبْرَاهِيْمَ ، إِنَّكَ حَمِيْدٌ مَّجِيْدٌ ، اَللّٰهُمَّ بَارِكْ عَلَىٰ مُحَمَّدٍ وَّعَلَىٰ اٰلِ مُحَمَّدٍ ، كَمَا بَارَكْتَ عَلَىٰ إِبْرَاهِيْمَ وَعَلَىٰ اٰلِ إِبْرَاهِيْمَ ، إِنَّكَ حَمِيْدٌ مَّجِيْدٌ.',
    'Allāhumma ṣalli ʿalā Muḥammad wa ʿalā āli Muḥammad, kamā ṣallayta ʿalā Ibrāhīma wa ʿalā āli Ibrāhīm, innaka Ḥamīdu-m-Majīd, Allāhumma bārik ʿalā Muḥammad wa ʿalā āli Muḥammad, kamā bārakta ʿalā Ibrāhīma wa ʿalā āli Ibrāhīm, innaka Ḥamīdu-m-Majīd.',
    'O Allah, honour and have mercy upon Muhammad and the family of Muhammad as You have honoured and had mercy upon Ibrāhīm and the family of Ibrāhīm. Indeed, You are the Most Praiseworthy, the Most Glorious. O Allah, bless Muhammad and the family of Muhammad as You have blessed Ibrāhīm and the family of Ibrāhīm. Indeed, You are the Most Praiseworthy, the Most Glorious.',
    'Ô Allah, honore et fais miséricorde à Muhammad et à la famille de Muhammad, comme Tu as honoré et fait miséricorde à Ibrāhīm et à la famille d''Ibrāhīm. Tu es certes le Digne de louange, le Glorieux. Ô Allah, bénis Muhammad et la famille de Muhammad, comme Tu as béni Ibrāhīm et la famille d''Ibrāhīm. Tu es certes le Digne de louange, le Glorieux.',
    'O Allah, ehre und sei Muhammad und der Familie Muhammads gnädig, wie Du Ibrāhīm und die Familie Ibrāhīms geehrt und ihnen gnädig warst. Wahrlich, Du bist der Lobenswürdige, der Ruhmreiche. O Allah, segne Muhammad und die Familie Muhammads, wie Du Ibrāhīm und die Familie Ibrāhīms gesegnet hast. Wahrlich, Du bist der Lobenswürdige, der Ruhmreiche.',
    'O Allah, eer en wees genadig voor Mohammed en de familie van Mohammed, zoals U Ibrāhīm en de familie van Ibrāhīm hebt geëerd en genadig was. Voorwaar, U bent de Lofwaardige, de Roemrijke. O Allah, zegen Mohammed en de familie van Mohammed, zoals U Ibrāhīm en de familie van Ibrāhīm hebt gezegend. Voorwaar, U bent de Lofwaardige, de Roemrijke.',
    'Allah''ım, İbrahim''e ve İbrahim''in ailesine rahmet ettiğin gibi Muhammed''e ve Muhammed''in ailesine de rahmet et. Şüphesiz Sen övgüye layıksın, şanı yücesin. Allah''ım, İbrahim''e ve ailesine bereket verdiğin gibi Muhammed''e ve Muhammed''in ailesine de bereket ver. Şüphesiz Sen övgüye layıksın, şanı yücesin.',
    'Ya Allah, limpahkanlah shalawat (rahmat) kepada Muhammad dan keluarga Muhammad, sebagaimana Engkau telah melimpahkannya kepada Ibrahim dan keluarga Ibrahim. Sesungguhnya Engkau Maha Terpuji lagi Maha Mulia. Ya Allah, berkahilah Muhammad dan keluarga Muhammad, sebagaimana Engkau telah memberkahi Ibrahim dan keluarga Ibrahim. Sesungguhnya Engkau Maha Terpuji lagi Maha Mulia.',
    'اے اللہ! محمد ﷺ پر اور آلِ محمد پر رحمت نازل فرما، جیسے تُو نے ابراہیم اور آلِ ابراہیم پر رحمت نازل فرمائی۔ بے شک تُو قابلِ تعریف، بزرگی والا ہے۔ اے اللہ! محمد ﷺ پر اور آلِ محمد پر برکت نازل فرما، جیسے تُو نے ابراہیم اور آلِ ابراہیم پر برکت نازل فرمائی۔ بے شک تُو قابلِ تعریف، بزرگی والا ہے۔',
    'হে আল্লাহ! মুহাম্মাদ ﷺ ও মুহাম্মাদের পরিবারের উপর রহমত বর্ষণ করো, যেমন তুমি ইবরাহীম ও ইবরাহীমের পরিবারের উপর রহমত বর্ষণ করেছ। নিশ্চয়ই তুমি প্রশংসিত, মহিমান্বিত। হে আল্লাহ! মুহাম্মাদ ﷺ ও মুহাম্মাদের পরিবারের উপর বরকত দাও, যেমন তুমি ইবরাহীম ও ইবরাহীমের পরিবারের উপর বরকত দিয়েছ। নিশ্চয়ই তুমি প্রশংসিত, মহিমান্বিত।',
    'Ya Allah, limpahkanlah selawat (rahmat) ke atas Muhammad dan keluarga Muhammad, sebagaimana Engkau telah melimpahkannya ke atas Ibrahim dan keluarga Ibrahim. Sesungguhnya Engkau Maha Terpuji lagi Maha Mulia. Ya Allah, berkatilah Muhammad dan keluarga Muhammad, sebagaimana Engkau telah memberkati Ibrahim dan keluarga Ibrahim. Sesungguhnya Engkau Maha Terpuji lagi Maha Mulia.',
    'О Аллах, благослови Мухаммада и род Мухаммада, как Ты благословил Ибрахима и род Ибрахима. Поистине, Ты — Достохвальный, Славный. О Аллах, ниспошли благодать Мухаммаду и роду Мухаммада, как Ты ниспослал благодать Ибрахиму и роду Ибрахима. Поистине, Ты — Достохвальный, Славный.',
    'In the morning', 'Le matin', 'في الصباح',
    'Ṭabarānī, al-Muʿjam al-Kabīr 6357', 'Ṭabarānī, al-Muʿjam al-Kabīr 6357', 'الطبراني، المعجم الكبير ٦٣٥٧',
    10::smallint, 5::smallint
  ),
  -- ═══════════════════ 23. Seek forgiveness and repent ═════════════════════
  (
    'أَسْتَغْفِرُ اللّٰهَ وَأَتُوْبُ إِلَيْهِ.',
    'Astaghfiru-l-llāha wa atūbu ilayh.',
    'I seek Allah''s forgiveness and turn to Him in repentance.',
    'Je demande pardon à Allah et je me repens à Lui.',
    'Ich bitte Allah um Vergebung und wende mich Ihm reuig zu.',
    'Ik vraag Allah om vergeving en wend mij berouwvol tot Hem.',
    'Allah''tan bağışlanma diler ve O''na tövbe ederim.',
    'Aku memohon ampun kepada Allah dan bertaubat kepada-Nya.',
    'میں اللہ سے بخشش مانگتا ہوں اور اسی کی طرف توبہ کرتا ہوں۔',
    'আমি আল্লাহর কাছে ক্ষমা চাই এবং তাঁর দিকে তওবা করি।',
    'Aku memohon ampun kepada Allah dan bertaubat kepada-Nya.',
    'Прошу прощения у Аллаха и приношу Ему покаяние.',
    'In the morning', 'Le matin', 'في الصباح',
    'Ṭabarānī, al-Muʿjam al-Awsaṭ 3879', 'Ṭabarānī, al-Muʿjam al-Awsaṭ 3879', 'الطبراني، المعجم الأوسط ٣٨٧٩',
    100::smallint, 5::smallint
  ),
  -- ═══════════════════ 24. Four phrases that outweigh all dhikr ════════════
  (
    'سُبْحَانَ اللّٰهِ وَبِحَمْدِهِ ، عَدَدَ خَلْقِهِ ، وَرِضَا نَفْسِهِ ، وَزِنَةَ عَرْشِهِ ، وَمِدَادَ كَلِمَاتِهِ.',
    'Subḥāna-llāhi wa bi ḥamdih, ʿadada khalqih, wa riḍā nafsih, wa zinata ʿarshih, wa midāda kalimātih.',
    'Allah is free from imperfection and all praise is due to Him, (in ways) as numerous as all He has created, (as vast) as His pleasure, (as limitless) as the weight of His Throne, and (as endless) as the ink of His words.',
    'Gloire et pureté à Allah, et à Lui la louange, autant que le nombre de Ses créatures, autant que Sa satisfaction, autant que le poids de Son Trône et autant que l''encre de Ses paroles.',
    'Gepriesen sei Allah, und Ihm gebührt alles Lob – so zahlreich wie Seine Schöpfung, so groß wie Sein Wohlgefallen, so schwer wie Sein Thron und so unerschöpflich wie die Tinte Seiner Worte.',
    'Glorie aan Allah, en Hem komt alle lof toe – zo talrijk als Zijn schepping, zo groot als Zijn welbehagen, zo zwaar als Zijn Troon en zo onuitputtelijk als de inkt van Zijn woorden.',
    'Allah''ı hamd ile tenzih ederim: yarattıklarının sayısınca, Zatının hoşnutluğunca, Arşının ağırlığınca ve kelimelerinin mürekkebince.',
    'Maha Suci Allah dan segala puji bagi-Nya, sebanyak bilangan makhluk-Nya, sejauh keridhaan diri-Nya, seberat ''Arasy-Nya, dan sebanyak tinta (untuk menulis) kalimat-kalimat-Nya.',
    'اللہ پاک ہے اور اسی کے لیے ہر تعریف ہے، اس کی مخلوق کی تعداد کے برابر، اس کی ذات کی رضا کے برابر، اس کے عرش کے وزن کے برابر اور اس کے کلمات کی سیاہی کے برابر۔',
    'আল্লাহ পবিত্র এবং সমস্ত প্রশংসা তাঁরই—তাঁর সৃষ্টির সংখ্যার সমান, তাঁর সত্তার সন্তুষ্টির সমান, তাঁর আরশের ওজনের সমান এবং তাঁর কালিমাসমূহের কালির সমান।',
    'Maha Suci Allah dan segala pujian bagi-Nya, sebanyak bilangan makhluk-Nya, sepenuh keredaan diri-Nya, seberat Arasy-Nya, dan sebanyak dakwat (untuk menulis) kalimah-kalimah-Nya.',
    'Пречист Аллах и хвала Ему — числом Его творений, мерой Его довольства, весом Его Престола и чернилами Его слов.',
    'In the morning', 'Le matin', 'في الصباح',
    'Muslim 2140; Abū Dāwūd 1503', 'Muslim 2140 ; Abū Dāwūd 1503', 'صحيح مسلم ٢١٤٠؛ سنن أبي داود ١٥٠٣',
    3::smallint, 10::smallint
  )
) as v(
  arabic_text,
  transcription_en,
  translation_en, translation_fr, translation_de, translation_nl, translation_tr,
  translation_id, translation_ur, translation_bn, translation_ms, translation_ru,
  when_en, when_fr, when_ar,
  reference_en, reference_fr, reference_ar,
  min_count, ajr
)
where s.title_en = 'Morning adhkar'
  and v.arabic_text is not null
  and not exists (
    select 1 from public.adhkars a where a.adhkar_subcategory_id = s.id
  );

-- ── 4) Fan-out transliteration / when / reference to remaining languages ─────
-- The Latin transliteration is language-neutral, so it is reused for every
-- *_transcription column. "when" + "reference" are copied from en/fr/ar onto
-- the remaining languages (the app falls back to *_en anyway, this keeps the
-- columns explicitly populated for all supported languages).
update public.adhkars a
set
  transcription_fr = coalesce(a.transcription_fr, a.transcription_en),
  transcription_de = coalesce(a.transcription_de, a.transcription_en),
  transcription_nl = coalesce(a.transcription_nl, a.transcription_en),
  transcription_tr = coalesce(a.transcription_tr, a.transcription_en),
  transcription_id = coalesce(a.transcription_id, a.transcription_en),
  transcription_ur = coalesce(a.transcription_ur, a.transcription_en),
  transcription_bn = coalesce(a.transcription_bn, a.transcription_en),
  transcription_ms = coalesce(a.transcription_ms, a.transcription_en),
  transcription_ru = coalesce(a.transcription_ru, a.transcription_en),
  when_de = coalesce(a.when_de, a.when_en),
  when_nl = coalesce(a.when_nl, a.when_en),
  when_tr = coalesce(a.when_tr, a.when_en),
  when_id = coalesce(a.when_id, a.when_en),
  when_ur = coalesce(a.when_ur, a.when_en),
  when_bn = coalesce(a.when_bn, a.when_en),
  when_ms = coalesce(a.when_ms, a.when_en),
  when_ru = coalesce(a.when_ru, a.when_en),
  reference_de = coalesce(a.reference_de, a.reference_en),
  reference_nl = coalesce(a.reference_nl, a.reference_en),
  reference_tr = coalesce(a.reference_tr, a.reference_en),
  reference_id = coalesce(a.reference_id, a.reference_en),
  reference_ur = coalesce(a.reference_ur, a.reference_en),
  reference_bn = coalesce(a.reference_bn, a.reference_en),
  reference_ms = coalesce(a.reference_ms, a.reference_en),
  reference_ru = coalesce(a.reference_ru, a.reference_en)
from public.adhkar_subcategories s
where a.adhkar_subcategory_id = s.id
  and s.title_en = 'Morning adhkar';
