-- =============================================================================
-- Seed: "By intention" category -> "Istighfar" subcategory + 9 adhkars
--        (8 Qur'anic istighfar verses + Sayyid al-Istighfar from the Sunnah).
--
-- Source: user-provided translation sheet (istighfar_adhkar_translations.csv).
--
-- Localization mirrors 20260621000000:
--   * arabic_text      – exact source text
--   * translation_*    – en, fr, de, nl, tr, id, ur, bn, ms, ru (from the sheet)
--   * transcription_*  – Latin transliteration in VALUES; fanned out to every
--                        Latin-script column (step 4b) + dedicated ur/bn/ru
--                        native-script transcription (step 4d, keyed on the
--                        unique transcription_en)
--   * when_*           – istighfar context phrase, localised to every language
--   * reference_*      – Qur'an surah:ayah for #1-8, Bukhārī 6306 for the
--                        Sayyid al-Istighfar; en/fr/ar in VALUES, de/nl/tr/id/ms
--                        via step 4c, ur/bn/ru via step 4d
--
-- Source-sheet fixes applied (cross-language leaks / typos):
--   * German #1  "ich gehört" -> "ich gehörte"
--   * Dutch  #2  "voorwaar, ich heb" -> "voorwaar, ik heb"
--   * German #3  Arabic "لنا" -> "uns"
--   * German #4  French "notre" -> "unser"
--   * Bengali #5 Urdu "ہم" -> "আমরা"
--   * Turkish #7 "oluruz" -> "olurum" (1st-person singular, per the verse)
--   * German Sunnah Cyrillic "и" -> "und"
--
-- Idempotent: category / subcategory inserted only if missing; adhkars inserted
-- only when the subcategory has none yet.
--
-- REVIEW NOTE: the ur/bn/ru phonetic transcriptions and (non-Qur'anic) hadith
-- reference were not part of the source sheet and should be reviewed by a
-- qualified native speaker before production use.
-- =============================================================================

-- ── 1) Category: By intention ────────────────────────────────────────────────
insert into public.adhkar_categories
  (title_en, title_fr, title_ar, title_de, title_nl, title_tr, title_id, title_ur, title_bn, title_ms, title_ru, position)
select
  'By intention', 'Par intention', 'حسب النية', 'Nach Absicht', 'Naar intentie',
  'Niyete göre', 'Berdasarkan niat', 'نیت کے اعتبار سے', 'নিয়ত অনুসারে',
  'Mengikut niat', 'По намерению', 5
where not exists (
  select 1 from public.adhkar_categories where title_en = 'By intention'
);

-- ── 2) Subcategory: Istighfar ────────────────────────────────────────────────
insert into public.adhkar_subcategories
  (adhkar_category_id, title_en, title_fr, title_ar, title_de, title_nl, title_tr,
   title_id, title_ur, title_bn, title_ms, title_ru, position)
select
  c.id, 'Istighfar', 'Istighfar (demande de pardon)', 'الاستغفار',
  'Istighfar (Um Vergebung bitten)', 'Istighfar (om vergeving vragen)', 'İstiğfar',
  'Istighfar', 'استغفار', 'ইস্তিগফার', 'Istighfar', 'Истигфар (прошение прощения)', 1
from public.adhkar_categories c
where c.title_en = 'By intention'
  and not exists (
    select 1 from public.adhkar_subcategories s
    where s.title_en = 'Istighfar' and s.adhkar_category_id = c.id
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
  -- ════════════════════════ 1. Qur'an 21:87 (Yūnus a.s.) ════════════════════
  (
    'لَآ إِلٰهَ إِلَّآ أَنْتَ سُبْحَانَكَ إِنِّيْ كُنْتُ مِنَ الظَّالِمِيْنَ',
    'Lā ilāha illā anta subḥānaka innī kuntu mina-ẓ-ẓālimīn.',
    'There is no god worthy of worship except You; You are free from all imperfection. Indeed, I have been of the wrongdoers. (21:87)',
    'Il n''y a de divinité digne d''adoration que Toi ! Pureté à Toi ! J''ai été vraiment du nombre des injustes. (21:87)',
    'Es gibt keinen Gott außer Dir! Gepriesen seist Du! Gewiss, ich gehörte zu den Ungerechten. (21:87)',
    'Er is geen god dan U, U bent vrij van elke imperfectie! Voorwaar, ik behoorde tot de onrechtvaardigen. (21:87)',
    'Senden başka hiçbir ilah yoktur. Seni eksik sıfatlardan tenzih ederim. Gerçekten ben zalimlerden oldum. (21:87)',
    'Tidak ada tuhan selain Engkau. Maha Suci Engkau, sesungguhnya aku termasuk orang-orang yang zalim. (21:87)',
    'تیرے سوا کوئی معبود نہیں، تو پاک ہے، بلاشبہ میں ہی ظالموں میں سے تھا۔ (21:87)',
    'আপনি ছাড়া কোনো সত্য উপাস্য নেই, আপনি পবিত্র! নিশ্চয়ই আমি জালেমদের অন্তর্ভুক্ত ছিলাম। (২১:৮৭)',
    'Tiada tuhan melainkan Engkau. Maha Suci Engkau, sesungguhnya aku termasuk dalam kalangan orang-orang yang zalim. (21:87)',
    'Нет божества, достойного поклонения, кроме Тебя! Пречист Ты! Поистине, я был одним из беззаконников. (21:87)',
    'Seeking forgiveness (from the Qur''an)', 'Demande de pardon (tirée du Coran)', 'الاستغفار من القرآن',
    'Um Vergebung bitten (aus dem Koran)', 'Om vergeving vragen (uit de Koran)', 'Bağışlanma dileme (Kur''an''dan)',
    'Memohon ampun (dari Al-Qur''an)', 'Memohon keampunan (daripada al-Quran)', 'استغفار (قرآن سے)',
    'ক্ষমা প্রার্থনা (কুরআন থেকে)', 'Прошение прощения (из Корана)',
    'Qur''an 21:87', 'Coran 21:87', 'القرآن ٢١:٨٧',
    1::smallint, 5::smallint
  ),
  -- ════════════════════════ 2. Qur'an 28:16 (Mūsā a.s.) ═════════════════════
  (
    'رَبِّ إِنِّي ظَلَمْتُ نَفْسِي فَاغْفِرْ لِي',
    'Rabbi innī ẓalamtu nafsī fa-ghfir lī.',
    'My Lord, I have certainly wronged myself, so forgive me. (28:16)',
    'Seigneur, je me suis fait du tort à moi-même ; pardonne-moi donc ! (28:16)',
    'Mein Herr, ich habe mir selbst Unrecht getan, so vergib mir. (28:16)',
    'Mijn Heer, voorwaar, ik heb mezelf onrecht aangedaan, vergeef mij dus. (28:16)',
    'Rabbim! Doğrusu kendime zulmettim; beni bağışla. (28:16)',
    'Ya Tuhanku, sesungguhnya aku telah menzalimi diriku sendiri, maka ampunilah aku. (28:16)',
    'اے میرے رب! بلاشبہ میں نے اپنے نفس پر ظلم کیا، پس مجھے معاف فرما دے۔ (28:16)',
    'হে আমার প্রতিপালক! নিশ্চয়ই আমি নিজের প্রতি জুলুম করেছি, অতএব আমাকে ক্ষমা করুন। (২৮:১৬)',
    'Wahai Tuhanku, sesungguhnya aku telah menzalimi diriku sendiri, maka ampunilah aku. (28:16)',
    'Господи! Я поступил несправедливо по отношению к себе. Прости же меня! (28:16)',
    'Seeking forgiveness (from the Qur''an)', 'Demande de pardon (tirée du Coran)', 'الاستغفار من القرآن',
    'Um Vergebung bitten (aus dem Koran)', 'Om vergeving vragen (uit de Koran)', 'Bağışlanma dileme (Kur''an''dan)',
    'Memohon ampun (dari Al-Qur''an)', 'Memohon keampunan (daripada al-Quran)', 'استغفار (قرآن سے)',
    'ক্ষমা প্রার্থনা (কুরআন থেকে)', 'Прошение прощения (из Корана)',
    'Qur''an 28:16', 'Coran 28:16', 'القرآن ٢٨:١٦',
    1::smallint, 5::smallint
  ),
  -- ════════════════════ 3. Qur'an 7:23 (Ādam & Ḥawwāʾ) ══════════════════════
  (
    'رَبَّنَا ظَلَمْنَا أَنْفُسَنَا وَإِنْ لَّمْ تَغْفِرْ لَنَا وَتَرْحَمْنَا لَنَكُونَنَّ مِنَ الْخَاسِرِينَ',
    'Rabbanā ẓalamnā anfusanā wa in lam taghfir lanā wa tarḥamnā lanakūnanna mina-l-khāsirīn.',
    'Our Lord, we have wronged ourselves. If You do not forgive us and have mercy upon us, we will surely be amongst the losers. (7:23)',
    'Ô notre Seigneur, nous avons fait du tort à nous-mêmes. Et si Tu ne nous pardonnes pas et ne nous fais pas miséricorde, nous serons très certainement du nombre des perdants. (7:23)',
    'Unser Herr, wir haben uns selbst Unrecht getan. Wenn Du uns nicht vergibst und Dich unser erbarmst, werden wir ganz gewiss zu den Verlierern gehören. (7:23)',
    'Onze Heer, wij hebben onszelf onrecht aangedaan. Als U ons niet vergeeft en ons geen barmhartigheid schenkt, zullen wij zeker tot de verliezers behoren. (7:23)',
    'Rabbimiz! Biz kendimize zulmettik. Eğer bizi bağışlamaz ve bize merhamet etmezsen, şüphesiz hüsrana uğrayanlardan oluruz. (7:23)',
    'Ya Tuhan kami, kami telah menzalimi diri kami sendiri. Jika Engkau tidak mengampuni kami dan memberi rahmat kepada kami, niscaya kami termasuk orang-orang yang rugi. (7:23)',
    'اے ہمارے رب! ہم نے اپنی جانوں پر ظلم کیا، اور اگر تو نے ہمیں نہ بخشا اور ہم پر رحم نہ کیا تو ہم یقیناً نقصان اٹھانے والوں میں سے ہو جائیں گے۔ (7:23)',
    'হে আমাদের প্রতিপালক! আমরা নিজেদের প্রতি জুলুম করেছি; আপনি যদি আমাদের ক্ষমা না করেন এবং আমাদের প্রতি দয়া না করেন, তবে নিশ্চয়ই আমরা ক্ষতিগ্রস্তদের অন্তর্ভুক্ত হব। (৭:২৩)',
    'Wahai Tuhan kami, kami telah menzalimi diri kami sendiri. Jika Engkau tidak mengampuni kami dan memberi rahmat kepada kami, nescaya kami termasuk dalam kalangan orang-orang yang rugi. (7:23)',
    'Господь наш! Мы поступили несправедливо по отношению к себе, и если Ты не простишь нас и не помилуешь, мы непременно окажемся в числе потерпевших убыток. (7:23)',
    'Seeking forgiveness (from the Qur''an)', 'Demande de pardon (tirée du Coran)', 'الاستغفار من القرآن',
    'Um Vergebung bitten (aus dem Koran)', 'Om vergeving vragen (uit de Koran)', 'Bağışlanma dileme (Kur''an''dan)',
    'Memohon ampun (dari Al-Qur''an)', 'Memohon keampunan (daripada al-Quran)', 'استغفار (قرآن سے)',
    'ক্ষমা প্রার্থনা (কুরআন থেকে)', 'Прошение прощения (из Корана)',
    'Qur''an 7:23', 'Coran 7:23', 'القرآن ٧:٢٣',
    1::smallint, 5::smallint
  ),
  -- ════════════════════════ 4. Qur'an 7:155 (Mūsā a.s.) ═════════════════════
  (
    'أَنْتَ وَلِيُّنَا فَاغْفِرْ لَنَا وَارْحَمْنَا ۖ وَأَنْتَ خَيْرُ الْغَافِرِينَ',
    'Anta waliyyunā fa-ghfir lanā wa-rḥamnā wa anta khayru-l-ghāfirīn.',
    'You are our Protector, so forgive us and have mercy upon us. You are the best of those who forgive. (7:155)',
    'Tu es notre Protecteur ! Pardonne-nous donc et fais-nous miséricorde, car Tu es le Meilleur des pardonneurs. (7:155)',
    'Du bist unser Schutzherr, so vergib uns und erbarme Dich unser; Du bist der Beste derer, die vergeben. (7:155)',
    'U bent onze Beschermer, vergeef ons dan en schenk ons barmhartigheid; U bent de Beste van degenen die vergeven. (7:155)',
    'Sen bizim velimizsin (dostumuzsun), bizi bağışla ve bize merhamet et. Sen bağışlayanların en hayırlısısın. (7:155)',
    'Engkaulah Pelindung kami, maka ampunilah kami dan berilah kami rahmat. Engkaulah Pemberi ampun yang terbaik. (7:155)',
    'تو ہی ہمارا کارساز ہے، پس ہمیں بخش دے اور ہم پر رحم فرما، اور تو سب سے بہتر معاف کرنے والا ہے۔ (7:155)',
    'আপনিই তো আমাদের অভিভাবক, সুতরাং আমাদের ক্ষমা করুন এবং আমাদের প্রতি দয়া করুন; আর আপনিই তো সর্বশ্রেষ্ঠ ক্ষমাকারী। (৭:১৫৫)',
    'Engkaulah Pelindung kami, maka ampunilah kami dan berilah kami rahmat. Engkaulah Pemberi ampun yang terbaik. (7:155)',
    'Ты — наш Покровитель, прости же нас и помилуй, ведь Ты — Наилучший из прощающих! (7:155)',
    'Seeking forgiveness (from the Qur''an)', 'Demande de pardon (tirée du Coran)', 'الاستغفار من القرآن',
    'Um Vergebung bitten (aus dem Koran)', 'Om vergeving vragen (uit de Koran)', 'Bağışlanma dileme (Kur''an''dan)',
    'Memohon ampun (dari Al-Qur''an)', 'Memohon keampunan (daripada al-Quran)', 'استغفار (قرآن سے)',
    'ক্ষমা প্রার্থনা (কুরআন থেকে)', 'Прошение прощения (из Корана)',
    'Qur''an 7:155', 'Coran 7:155', 'القرآن ٧:١٥٥',
    1::smallint, 5::smallint
  ),
  -- ════════════════════════ 5. Qur'an 3:16 ══════════════════════════════════
  (
    'رَبَّنَا إِنَّنَا آمَنَّا فَاغْفِرْ لَنَا ذُنُوبَنَا وَقِنَا عَذَابَ النَّارِ',
    'Rabbanā innanā āmannā fa-ghfir lanā dhunūbanā wa qinā ʿadhāba-n-nār.',
    'Our Lord, indeed we have believed, so forgive us our sins and protect us from the punishment of the Fire. (3:16)',
    'Ô notre Seigneur, nous avons cru ; pardonne-nous donc nos péchés et protège-nous du châtiment du Feu. (3:16)',
    'Unser Herr, gewiss, wir glauben, so vergib uns unsere Sünden und bewahre uns vor der Strafe des Feuers. (3:16)',
    'Onze Heer, voorwaar, wij geloven, vergeef ons dan onze zonden en bescherm ons tegen de bestraffing van het Vuur. (3:16)',
    'Rabbimiz! Şüphesiz biz iman ettik, bizim günahlarımızı bağışla ve bizi ateşin azabından koru. (3:16)',
    'Ya Tuhan kami, sesungguhnya kami telah beriman, maka ampunilah dosa-dosa kami dan lindungilah kami dari azab neraka. (3:16)',
    'اے ہمارے رب! بلاشبہ ہم ایمان لائے، پس ہمارے گناہ معاف فرما اور ہمیں آگ کے عذاب سے بچا۔ (3:16)',
    'হে আমাদের প্রতিপালক! নিশ্চয়ই আমরা ঈমান এনেছি, অতএব আমাদের পাপসমূহ ক্ষমা করুন এবং আমাদের আগুনের আজাব থেকে রক্ষা করুন। (৩:১৬)',
    'Wahai Tuhan kami, sesungguhnya kami telah beriman, maka ampunilah dosa-dosa kami dan peliharalah kami daripada azab neraka. (3:16)',
    'Господь наш! Поистине, мы уверовали, прости же нам наши грехи и защити нас от мучений в Огне. (3:16)',
    'Seeking forgiveness (from the Qur''an)', 'Demande de pardon (tirée du Coran)', 'الاستغفار من القرآن',
    'Um Vergebung bitten (aus dem Koran)', 'Om vergeving vragen (uit de Koran)', 'Bağışlanma dileme (Kur''an''dan)',
    'Memohon ampun (dari Al-Qur''an)', 'Memohon keampunan (daripada al-Quran)', 'استغفار (قرآن سے)',
    'ক্ষমা প্রার্থনা (কুরআন থেকে)', 'Прошение прощения (из Корана)',
    'Qur''an 3:16', 'Coran 3:16', 'القرآن ٣:١٦',
    1::smallint, 5::smallint
  ),
  -- ════════════════════════ 6. Qur'an 23:118 ════════════════════════════════
  (
    'رَبِّ اغْفِرْ وَارْحَمْ وَأَنْتَ خَيْرُ الرَّاحِمِينَ',
    'Rabbi-ghfir wa-rḥam wa anta khayru-r-rāḥimīn.',
    'My Lord, forgive and have mercy. You are the Best of those who are merciful. (23:118)',
    'Seigneur, pardonne et fais miséricorde, car Tu es le Meilleur des miséricordieux. (23:118)',
    'Mein Herr, vergib und erbarme Dich, denn Du bist der Beste der Barmherzigen. (23:118)',
    'Mijn Heer, vergeef en schenk barmhartigheid, want U bent de Beste van de barmhartigen. (23:118)',
    'Rabbim! Bağışla ve merhamet et, Sen merhamet edenlerin en hayırlısısın. (23:118)',
    'Ya Tuhanku, ampunilah dan berilah rahmat, Engkaulah Pemberi rahmat yang terbaik. (23:118)',
    'اے میرے رب! بخش دے اور رحم فرما، اور تو سب سے بہتر رحم کرنے والا ہے۔ (23:118)',
    'হে আমার প্রতিপালক! ক্ষমা করুন ও দয়া করুন, আর আপনিই তো সর্বশ্রেষ্ঠ দয়ালু। (২৩:১১৮)',
    'Wahai Tuhanku, ampunilah dan berilah rahmat, Engkaulah Pemberi rahmat yang terbaik. (23:118)',
    'Господи, прости и помилуй, ведь Ты — Наилучший из милосердных! (23:118)',
    'Seeking forgiveness (from the Qur''an)', 'Demande de pardon (tirée du Coran)', 'الاستغفار من القرآن',
    'Um Vergebung bitten (aus dem Koran)', 'Om vergeving vragen (uit de Koran)', 'Bağışlanma dileme (Kur''an''dan)',
    'Memohon ampun (dari Al-Qur''an)', 'Memohon keampunan (daripada al-Quran)', 'استغفار (قرآن سے)',
    'ক্ষমা প্রার্থনা (কুরআন থেকে)', 'Прошение прощения (из Корана)',
    'Qur''an 23:118', 'Coran 23:118', 'القرآن ٢٣:١١٨',
    1::smallint, 5::smallint
  ),
  -- ════════════════════════ 7. Qur'an 11:47 (Nūḥ a.s.) ══════════════════════
  (
    'رَبِّ إِنِّي أَعُوذُ بِكَ أَنْ أَسْأَلَكَ مَا لَيْسَ لِي بِهِ عِلْمٌ ۖ وَإِلَّا تَغْفِرْ لِي وَتَرْحَمْنِي أَكُنْ مِنَ الْخَاسِرِينَ',
    'Rabbi innī aʿūdhu bika an as''alaka mā laysa lī bihi ʿilm, wa illā taghfir lī wa tarḥamnī akun mina-l-khāsirīn.',
    'My Lord, I seek Your protection from asking You anything about which I have no knowledge. And unless You forgive me and have mercy upon me, I shall be amongst the losers. (11:47)',
    'Seigneur, je cherche Ta protection contre toute demande d''une chose dont je n''ai aucune connaissance. Et si Tu ne me pardonnes pas et ne me fais pas miséricorde, je serai du nombre des perdants. (11:47)',
    'Mein Herr, ich suche Zuflucht bei Dir davor, Dich um etwas zu bitten, wovon ich kein Wissen habe. Wenn Du mir nicht vergibst und Dich meiner erbarmst, werde ich zu den Verlierern gehören. (11:47)',
    'Mijn Heer, voorwaar, ik zoek Uw bescherming tegen het vragen naar iets waar ik geen kennis over heb. En tenzij U mij vergeeft en barmhartigheid schenkt, zal ik tot de verliezers behoren. (11:47)',
    'Rabbim! Hakkında bilgim olmayan bir şeyi Senden istemekten Sana sığınırım. Eğer beni bağışlamaz ve bana merhamet etmezsen hüsrana uğrayanlardan olurum. (11:47)',
    'Ya Tuhanku, sesungguhnya aku berlindung kepada-Mu dari memohon sesuatu yang aku tidak mempunyai pengetahuan tentangnya. Dan sekiranya Engkau tidak mengampuni aku dan memberi rahmat kepadaku, niscaya aku termasuk orang-orang yang rugi. (11:47)',
    'اے میرے رب! میں اس بات سے تیری پناہ مانگتا ہوں کہ تجھ سے وہ چیز مانگوں جس کا مجھے علم نہیں، اور اگر تو نے مجھے نہ بخشا اور مجھ پر رحم نہ کیا تو میں نقصان اٹھانے والوں میں سے ہو جاؤں گا۔ (11:47)',
    'হে আমার প্রতিপালক! যে বিষয়ে আমার কোনো জ্ঞান নেই, এমন কিছু আপনার কাছে চাওয়া থেকে আমি আপনার আশ্রয় প্রার্থনা করছি। আপনি যদি আমাকে ক্ষমা না করেন এবং আমার প্রতি দয়া না করেন, তবে আমি ক্ষতিগ্রস্তদের অন্তর্ভুক্ত হব। (১১:৪৭)',
    'Wahai Tuhanku, sesungguhnya aku berlindung kepada-Mu daripada memohon sesuatu yang aku tidak mempunyai pengetahuan tentangnya. Dan sekiranya Engkau tidak mengampuni aku dan memberi rahmat kepadaku, nescaya aku termasuk dalam kalangan orang-orang yang rugi. (11:47)',
    'Господи! Я прибегаю к Тебе от того, чтобы просить Тебя о том, чего я не знаю. И если Ты не простишь меня и не помилуешь, я окажусь среди потерпевших убыток. (11:47)',
    'Seeking forgiveness (from the Qur''an)', 'Demande de pardon (tirée du Coran)', 'الاستغفار من القرآن',
    'Um Vergebung bitten (aus dem Koran)', 'Om vergeving vragen (uit de Koran)', 'Bağışlanma dileme (Kur''an''dan)',
    'Memohon ampun (dari Al-Qur''an)', 'Memohon keampunan (daripada al-Quran)', 'استغفار (قرآن سے)',
    'ক্ষমা প্রার্থনা (কুরআন থেকে)', 'Прошение прощения (из Корана)',
    'Qur''an 11:47', 'Coran 11:47', 'القرآن ١١:٤٧',
    1::smallint, 5::smallint
  ),
  -- ════════════════════════ 8. Qur'an 66:8 ══════════════════════════════════
  (
    'رَبَّنَا أَتْمِمْ لَنَا نُورَنَا وَاغْفِرْ لَنَا ۖ إِنَّكَ عَلَىٰ كُلِّ شَيْءٍ قَدِيرٌ',
    'Rabbanā atmim lanā nūranā wa-ghfir lanā innaka ʿalā kulli shay''in qadīr.',
    'Our Lord, perfect for us our light and forgive us. Indeed, You are All-Powerful over everything. (66:08)',
    'Ô notre Seigneur, parfais-nous notre lumière et pardonne-nous. Car Tu es Omnipotent. (66:08)',
    'Unser Herr, mache unser Licht für uns vollkommen und vergib uns. Gewiss, Du hast Macht über alle Dinge. (66:08)',
    'Onze Heer, vervolmaak voor ons ons licht en vergeef ons. Voorwaar, U bent Almachtig over alle dingen. (66:08)',
    'Rabbimiz! Nurumuzu bizim için tamamla ve bizi bağışla. Şüphesiz Sen her şeye kadirsin. (66:08)',
    'Ya Tuhan kami, sempurnakanlah untuk kami cahaya kami dan ampunilah kami; sesungguhnya Engkau Maha Kuasa atas segala sesuatu. (66:08)',
    'اے ہمارے رب! ہمارے لیے ہمارا نور پورا فرما اور ہمیں بخش دے، بلاشبہ تو ہر چیز پر قادر ہے۔ (66:08)',
    'হে আমাদের প্রতিপালক! আমাদের জন্য আমাদের আলো পূর্ণ করে দিন এবং আমাদের ক্ষমা করুন; নিশ্চয়ই আপনি সব কিছুর ওপর ক্ষমতাবান। (৬৬:০৮)',
    'Wahai Tuhan kami, sempurnakanlah untuk kami cahaya kami dan ampunilah kami; sesungguhnya Engkau Maha Kuasa atas segala sesuatu. (66:08)',
    'Господь наш! Даруй нам совершенный свет наш и прости нас, поистине, Ты Всемогущ! (66:08)',
    'Seeking forgiveness (from the Qur''an)', 'Demande de pardon (tirée du Coran)', 'الاستغفار من القرآن',
    'Um Vergebung bitten (aus dem Koran)', 'Om vergeving vragen (uit de Koran)', 'Bağışlanma dileme (Kur''an''dan)',
    'Memohon ampun (dari Al-Qur''an)', 'Memohon keampunan (daripada al-Quran)', 'استغفار (قرآن سے)',
    'ক্ষমা প্রার্থনা (কুরআন থেকে)', 'Прошение прощения (из Корана)',
    'Qur''an 66:8', 'Coran 66:8', 'القرآن ٦٦:٨',
    1::smallint, 5::smallint
  ),
  -- ════════════════ 9. Sayyid al-Istighfar (Bukhārī 6306) ═══════════════════
  (
    'اَللّٰهُمَّ أَنْتَ رَبِّيْ لَا إِلٰهَ إِلَّا أَنْتَ ، خَلَقْتَنِيْ وَأَنَا عَبْدُكَ ، وَأَنَا عَلَىٰ عَهْدِكَ وَوَعْدِكَ مَا اسْتَطَعْتُ ، أَعُوْذُ بِكَ مِنْ شَرِّ مَا صَنَعْتُ ، أَبُوْءُ لَكَ بِنِعْمَتِكَ عَلَيَّ وَأَبُوْءُ بِذَنْبِيْ ، فَاغْفِرْ لِيْ فَإِنَّهُ لَا يَغْفِرُ الذُّنُوْبَ إِلَّا أَنْتَ',
    'Allāhumma anta Rabbī lā ilāha illā ant, khalaqtanī wa anā ʿabduk, wa anā ʿalā ʿahdika wa waʿdika ma-staṭaʿt, aʿūdhu bika min sharri mā ṣanaʿt, abū''u laka bi-niʿmatika ʿalayya wa abū''u bi-dhanbī, fa-ghfir lī fa-innahu lā yaghfiru-dh-dhunūba illā ant.',
    'O Allah, You are my Lord. There is no god except You. You have created me, and I am Your slave, and I am under Your covenant and pledge (to fulfil it) to the best of my ability. I seek Your protection from the evil that I have done. I acknowledge the favours that You have bestowed upon me, and I admit my sins. Forgive me, for none forgives sins but You.',
    'Ô Allah, Tu es mon Seigneur, il n''y a de divinité que Toi. Tu m''as créé et je suis Ton serviteur. Je suis fidèle à Ton engagement et à Ta promesse autant que je le puis. Je cherche protection auprès de Toi contre le mal de ce que j''ai fait. Je reconnais Tes bienfaits envers moi et je confesse mon péché. Pardonne-moi donc, car nul ne pardonne les péchés si ce n''est Toi.',
    'O Allah, Du bist mein Herr, es gibt keinen Gott außer Dir. Du hast mich erschaffen und ich bin Dein Diener, und ich halte mich an Deinen Bund und Dein Versprechen, so gut ich kann. Ich suche Zuflucht bei Dir vor dem Übel dessen, was ich getan habe. Ich erkenne Deine Gnade an, die Du mir erwiesen hast, und ich gestehe meine Sünde. So vergib mir, denn niemand vergibt Sünden außer Dir.',
    'O Allah, U bent mijn Heer, er is geen god dan U. U heeft mij geschapen en ik ben Uw dienaar, en ik houd mij aan Uw verbond en Uw belofte voor zover ik daartoe in staat ben. Ik zoek bescherming bij U tegen het kwaad van wat ik heb gedaan. Ik erken Uw gunsten aan mij en ik erken mijn zonde. Vergeef mij dus, want niemand vergeeft zonden behalve U.',
    'Allah''ım! Sen benim Rabbimsin, Senden başka ilah yoktur. Beni Sen yarattın ve ben Senin kulunum; gücüm yettiğince Sana verdiğim söz ve ahid üzereyim. Yaptıklarımın şerrinden Sana sığınırım. Üzerimdeki nimetini itiraf eder, günahımı da kabul ederim. Beni bağışla; çünkü Senden başka günahları bağışlayacak kimse yoktur.',
    'Ya Allah, Engkau adalah Tuhanku, tidak ada tuhan selain Engkau. Engkau telah menciptakanku dan aku adalah hamba-Mu, dan aku berada di atas perjanjian-Mu dan janji-Mu semampuku. Aku berlindung kepada-Mu dari keburukan apa yang telah aku perbuat. Aku mengakui nikmat-Mu kepadaku dan aku mengakui dosaku, maka ampunilah aku, karena tidak ada yang mengampuni dosa-dosa selain Engkau.',
    'اے اللہ! تو ہی میرا رب ہے، تیرے سوا کوئی معبود نہیں، تو نے مجھے پیدا کیا اور میں تیرا بندہ ہوں، اور میں اپنی طاقت کے مطابق تیرے عہد اور وعدے پر قائم ہوں۔ میں اپنے کیے کے شر سے تیری پناہ مانگتا ہوں، میں تیرے سامنے ان نعمتوں کا اعتراف کرتا ہوں جو تو نے مجھ پر کیں اور اپنے گناہوں کا اعتراف کرتا ہوں، پس مجھے بخش دے کیونکہ تیرے سوا کوئی گناہوں کو معاف نہیں کر سکتا۔',
    'হে আল্লাহ! আপনিই আমার প্রতিপালক, আপনি ছাড়া কোনো সত্য উপাস্য নেই। আপনি আমাকে সৃষ্টি করেছেন এবং আমি আপনার বান্দা, আর আমি আপনার অঙ্গীকার ও প্রতিশ্রুতির ওপর যথাসাধ্য অবিচল আছি। আমি আমার কৃতকর্মের অনিষ্ট থেকে আপনার আশ্রয় চাচ্ছি। আমার প্রতি আপনার নেয়ামতসমূহ স্বীকার করছি এবং আমার পাপসমূহও স্বীকার করছি। অতএব আমাকে ক্ষমা করুন, কারণ আপনি ছাড়া আর কেউ পাপ ক্ষমা করতে পারে না।',
    'Ya Allah, Engkau adalah Tuhanku, tiada tuhan melainkan Engkau. Engkau telah menciptakanku dan aku adalah hamba-Mu, dan aku berada di atas perjanjian-Mu dan janji-Mu semampuku. Aku berlindung kepada-Mu daripada keburukan apa yang telah aku perbuat. Aku mengakui nikmat-Mu kepadaku dan aku mengakui dosaku, maka ampunilah aku, kerana tiada yang mengampuni dosa-dosa melainkan Engkau.',
    'О Аллах, Ты — мой Господь, и нет божества, достойного поклонения, кроме Тебя. Ты сотворил меня, а я — Твой раб, и я верен договору с Тобой и обещанию, данному Тебе, пока у меня хватает сил. Прибегаю к Твоей защите от зла того, что я сделал, признаю милость, оказанную Тобой мне, и признаю свой грех. Прости же меня, ведь никто не прощает грехов, кроме Тебя!',
    'Sayyid al-Istighfar (the best way of seeking forgiveness)', 'Sayyid al-Istighfar (la meilleure formule de demande de pardon)', 'سيد الاستغفار',
    'Sayyid al-Istighfar (die beste Art, um Vergebung zu bitten)', 'Sayyid al-Istighfar (de beste manier om vergeving te vragen)', 'Seyyidü''l-İstiğfar (bağışlanma dilemenin en faziletlisi)',
    'Sayyidul Istighfar (penghulu istighfar)', 'Sayyidul Istighfar (penghulu istighfar)', 'سید الاستغفار (استغفار کا سردار)',
    'সাইয়িদুল ইস্তিগফার (ক্ষমা প্রার্থনার শ্রেষ্ঠ দোয়া)', 'Сайид аль-истигфар (господин прошений о прощении)',
    'Bukhārī 6306', 'Bukhārī 6306', 'صحيح البخاري ٦٣٠٦',
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
where s.title_en = 'Istighfar'
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
  and s.title_en = 'Istighfar';

-- 4c) Reference for Latin-script languages: collection names / "Qur'an" stay romanised.
update public.adhkars a
set
  reference_de = a.reference_en,
  reference_nl = a.reference_en,
  reference_tr = a.reference_en,
  reference_id = a.reference_en,
  reference_ms = a.reference_en
from public.adhkar_subcategories s
where a.adhkar_subcategory_id = s.id
  and s.title_en = 'Istighfar';

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
  -- 1. Qur'an 21:87
  ('Lā ilāha illā anta subḥānaka innī kuntu mina-ẓ-ẓālimīn.',
   'لَا اِلٰہَ اِلَّا اَنْتَ سُبْحَانَکَ اِنِّیْ کُنْتُ مِنَ الظَّالِمِیْنَ۔',
   'লা ইলাহা ইল্লা আনতা সুবহানাকা ইন্নী কুনতু মিনায যালিমীন।',
   'Ля иляха илля анта субханака инни кунту мина-з-залимин.',
   'القرآن 21:87', 'কুরআন 21:87', 'Коран 21:87'),
  -- 2. Qur'an 28:16
  ('Rabbi innī ẓalamtu nafsī fa-ghfir lī.',
   'رَبِّ اِنِّیْ ظَلَمْتُ نَفْسِیْ فَاغْفِرْ لِیْ۔',
   'রাব্বি ইন্নী যালামতু নাফসী ফাগফির লী।',
   'Рабби инни заламту нафси фа-гфир ли.',
   'القرآن 28:16', 'কুরআন 28:16', 'Коран 28:16'),
  -- 3. Qur'an 7:23
  ('Rabbanā ẓalamnā anfusanā wa in lam taghfir lanā wa tarḥamnā lanakūnanna mina-l-khāsirīn.',
   'رَبَّنَا ظَلَمْنَا اَنْفُسَنَا وَاِنْ لَّمْ تَغْفِرْ لَنَا وَتَرْحَمْنَا لَنَکُوْنَنَّ مِنَ الْخَاسِرِیْنَ۔',
   'রাব্বানা যালামনা আনফুসানা ওয়া ইল্লাম তাগফির লানা ওয়া তারহামনা লানাকূনান্না মিনাল খাসিরীন।',
   'Раббана заламна анфусана ва ин лям тагфир ляна ва тархамна лянакунанна мина-ль-хасирин.',
   'القرآن 7:23', 'কুরআন 7:23', 'Коран 7:23'),
  -- 4. Qur'an 7:155
  ('Anta waliyyunā fa-ghfir lanā wa-rḥamnā wa anta khayru-l-ghāfirīn.',
   'اَنْتَ وَلِیُّنَا فَاغْفِرْ لَنَا وَارْحَمْنَا وَاَنْتَ خَیْرُ الْغَافِرِیْنَ۔',
   'আনতা ওয়ালিইয়ুনা ফাগফির লানা ওয়ারহামনা ওয়া আনতা খাইরুল গাফিরীন।',
   'Анта валиййуна фа-гфир ляна ва-рхамна ва анта хайру-ль-гафирин.',
   'القرآن 7:155', 'কুরআন 7:155', 'Коран 7:155'),
  -- 5. Qur'an 3:16
  ('Rabbanā innanā āmannā fa-ghfir lanā dhunūbanā wa qinā ʿadhāba-n-nār.',
   'رَبَّنَا اِنَّنَا آمَنَّا فَاغْفِرْ لَنَا ذُنُوْبَنَا وَقِنَا عَذَابَ النَّارِ۔',
   'রাব্বানা ইন্নানা আমান্না ফাগফির লানা যুনূবানা ওয়া কিনা আযাবান নার।',
   'Раббана иннана аманна фа-гфир ляна зунубана ва кына ’азаба-н-нар.',
   'القرآن 3:16', 'কুরআন 3:16', 'Коран 3:16'),
  -- 6. Qur'an 23:118
  ('Rabbi-ghfir wa-rḥam wa anta khayru-r-rāḥimīn.',
   'رَبِّ اغْفِرْ وَارْحَمْ وَاَنْتَ خَیْرُ الرَّاحِمِیْنَ۔',
   'রাব্বিগফির ওয়ারহাম ওয়া আনতা খাইরুর রাহিমীন।',
   'Рабби-гфир ва-рхам ва анта хайру-р-рахимин.',
   'القرآن 23:118', 'কুরআন 23:118', 'Коран 23:118'),
  -- 7. Qur'an 11:47
  ('Rabbi innī aʿūdhu bika an as''alaka mā laysa lī bihi ʿilm, wa illā taghfir lī wa tarḥamnī akun mina-l-khāsirīn.',
   'رَبِّ اِنِّیْ اَعُوْذُ بِکَ اَنْ اَسْاَلَکَ مَا لَیْسَ لِیْ بِہٖ عِلْمٌ، وَاِلَّا تَغْفِرْ لِیْ وَتَرْحَمْنِیْ اَکُنْ مِّنَ الْخَاسِرِیْنَ۔',
   'রাব্বি ইন্নী আঊযু বিকা আন আসআলাকা মা লাইসা লী বিহী ইলম, ওয়া ইল্লা তাগফির লী ওয়া তারহামনী আকুম মিনাল খাসিরীন।',
   'Рабби инни а’узу бика ан ас’аляка ма ляйса ли бихи ’ильм, ва илля тагфир ли ва тархамни акун мина-ль-хасирин.',
   'القرآن 11:47', 'কুরআন 11:47', 'Коран 11:47'),
  -- 8. Qur'an 66:8
  ('Rabbanā atmim lanā nūranā wa-ghfir lanā innaka ʿalā kulli shay''in qadīr.',
   'رَبَّنَا اَتْمِمْ لَنَا نُوْرَنَا وَاغْفِرْ لَنَا اِنَّکَ عَلٰی کُلِّ شَیْءٍ قَدِیْرٌ۔',
   'রাব্বানা আতমিম লানা নূরানা ওয়াগফির লানা ইন্নাকা আলা কুল্লি শাইইন কাদীর।',
   'Раббана атмим ляна нурана ва-гфир ляна иннака ’аля кулли шайъин кадир.',
   'القرآن 66:8', 'কুরআন 66:8', 'Коран 66:8'),
  -- 9. Sayyid al-Istighfar
  ('Allāhumma anta Rabbī lā ilāha illā ant, khalaqtanī wa anā ʿabduk, wa anā ʿalā ʿahdika wa waʿdika ma-staṭaʿt, aʿūdhu bika min sharri mā ṣanaʿt, abū''u laka bi-niʿmatika ʿalayya wa abū''u bi-dhanbī, fa-ghfir lī fa-innahu lā yaghfiru-dh-dhunūba illā ant.',
   'اَللّٰھُمَّ اَنْتَ رَبِّیْ لَا اِلٰہَ اِلَّا اَنْتَ، خَلَقْتَنِیْ وَاَنَا عَبْدُکَ، وَاَنَا عَلٰی عَھْدِکَ وَوَعْدِکَ مَا اسْتَطَعْتُ، اَعُوْذُ بِکَ مِنْ شَرِّ مَا صَنَعْتُ، اَبُوْءُ لَکَ بِنِعْمَتِکَ عَلَیَّ وَاَبُوْءُ بِذَنْبِیْ، فَاغْفِرْ لِیْ فَاِنَّہٗ لَا یَغْفِرُ الذُّنُوْبَ اِلَّا اَنْتَ۔',
   'আল্লাহুম্মা আনতা রাব্বী লা ইলাহা ইল্লা আনতা, খালাকতানী ওয়া আনা আবদুক, ওয়া আনা আলা আহদিকা ওয়া ওয়াদিকা মাসতাতাতু, আঊযু বিকা মিন শাররি মা সানাতু, আবূউ লাকা বিনিমাতিকা আলাইয়া ওয়া আবূউ বিযানবী, ফাগফির লী ফাইন্নাহূ লা ইয়াগফিরুয যুনূবা ইল্লা আনতা।',
   'Аллахумма анта Рабби ля иляха илля ант, халяктани ва ана ’абдук, ва ана ’аля ’ахдика ва ва’дика ма-стата’ту, а’узу бика мин шарри ма сана’ту, абуу ляка би-ни’матика ’аляйя ва абуу би-занби, фа-гфир ли фа-иннаху ля ягфиру-з-зунуба илля ант.',
   'بخاری 6306', 'বুখারী 6306', 'аль-Бухари 6306')
) as m(tr_key, t_ur, t_bn, t_ru, r_ur, r_bn, r_ru)
where a.adhkar_subcategory_id = s.id
  and s.title_en = 'Istighfar'
  and a.transcription_en = m.tr_key;
