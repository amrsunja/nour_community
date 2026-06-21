-- =============================================================================
-- Seed: "Around salah" category
--        -> "Adhan & call to prayer" subcategory (3 adhkars)
--        -> "The Masjid"            subcategory (5 adhkars)
--
-- Source: user-provided translation sheet
--   (adhan_and_masjid_adhkar_translations.csv).
--
-- Localization mirrors 20260615000000 / 20260616000000:
--   * arabic_text      – exact source text
--   * translation_*    – en, fr, de, nl, tr, id, ur, bn, ms, ru (from the sheet)
--   * transcription_*  – Latin transliteration in VALUES; fanned out to every
--                        Latin-script column (step 4b) + dedicated ur/bn/ru
--                        native-script transcription (step 4d, keyed on the
--                        unique transcription_en across both subcategories)
--   * when_*           – per-adhkar context phrase, localised to every language
--   * reference_*      – en/fr/ar in VALUES; de/nl/tr/id/ms via step 4c and
--                        ur/bn/ru via step 4d
--
-- Source-sheet fix applied: French #3 stray glyph ("ce白 appel" -> "cet appel").
-- The salawat (subcat 1, #2) is intentionally abbreviated in the sheet ("…");
-- kept verbatim.
--
-- Idempotent: category / subcategories inserted only if missing; adhkars
-- inserted per-subcategory only when that subcategory has none yet.
--
-- REVIEW NOTE: hadith references and the ur/bn/ru phonetic transcriptions were
-- not part of the source sheet — they follow the standard Hisnul-Muslim
-- attributions and should be reviewed by a qualified native speaker before
-- production use.
-- =============================================================================

-- ── 1) Category: Around salah ────────────────────────────────────────────────
insert into public.adhkar_categories
  (title_en, title_fr, title_ar, title_de, title_nl, title_tr, title_id, title_ur, title_bn, title_ms, title_ru, position)
select
  'Around salah', 'Autour de la salât', 'حول الصلاة', 'Rund um das Gebet',
  'Rondom het gebed', 'Namaz çevresinde', 'Seputar salat', 'نماز کے گرد و نواح',
  'সালাত সম্পর্কিত', 'Sekitar solat', 'Вокруг молитвы', 3
where not exists (
  select 1 from public.adhkar_categories where title_en = 'Around salah'
);

-- ── 2) Subcategory: Adhan & call to prayer ───────────────────────────────────
insert into public.adhkar_subcategories
  (adhkar_category_id, title_en, title_fr, title_ar, title_de, title_nl, title_tr,
   title_id, title_ur, title_bn, title_ms, title_ru, position)
select
  c.id, 'Adhan & call to prayer', 'Adhan et appel à la prière', 'الأذان والنداء للصلاة',
  'Adhan & Gebetsruf', 'Adhan & oproep tot gebed', 'Ezan & namaza çağrı',
  'Azan & seruan salat', 'اذان اور بلاوا', 'আযান ও সালাতের আহ্বান',
  'Azan & seruan solat', 'Азан и призыв на молитву', 1
from public.adhkar_categories c
where c.title_en = 'Around salah'
  and not exists (
    select 1 from public.adhkar_subcategories s
    where s.title_en = 'Adhan & call to prayer' and s.adhkar_category_id = c.id
  );

-- ── 3) Subcategory: The Masjid ───────────────────────────────────────────────
insert into public.adhkar_subcategories
  (adhkar_category_id, title_en, title_fr, title_ar, title_de, title_nl, title_tr,
   title_id, title_ur, title_bn, title_ms, title_ru, position)
select
  c.id, 'The Masjid', 'La mosquée', 'المسجد', 'Die Moschee', 'De moskee', 'Mescid',
  'Masjid', 'مسجد', 'মসজিদ', 'Masjid', 'Мечеть', 2
from public.adhkar_categories c
where c.title_en = 'Around salah'
  and not exists (
    select 1 from public.adhkar_subcategories s
    where s.title_en = 'The Masjid' and s.adhkar_category_id = c.id
  );

-- ── 4) Adhkars: Adhan & call to prayer ───────────────────────────────────────
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
  -- ══════════════════════ 1. After the adhan #1 (shahada) ═══════════════════
  (
    'وَأَنَا أَشْهَدُ أَنْ لَّا إِلٰهَ إِلَّا اللهُ وَحْدَهُ لَا شَرِيْكَ لَهُ ، وَأَنَّ مُحَمَّدًا عَبْدُهُ وَرَسُوْلُهُ ، رَضِيْتُ بِاللهِ رَبًّا ، وَبِمُحَمَّدٍ رَسُوْلًا ، وَبِالْإِسْلَامِ دِيْنًا',
    'Wa anā ashhadu an lā ilāha illa-llāhu waḥdahū lā sharīka lah, wa anna Muḥammadan ʿabduhū wa rasūluh, raḍītu bi-llāhi Rabban, wa bi-Muḥammadin rasūlan, wa bi-l-Islāmi dīnan.',
    'I also bear witness that there is no god but Allah. He is Alone and He has no partner whatsoever, and that Muhammad ﷺ is His servant and His Messenger. I am satisfied with Allah as my Lord, with Muhammad as my Messenger, and with Islam as my religion.',
    'Et je témoigne aussi qu''il n''y a de divinité d''autre qu''Allah, Seul et sans aucun associé, et que Muhammad ﷺ est Son serviteur et Son Messager. J''agréé Allah comme mon Seigneur, Muhammad comme mon Messager, et l''Islam comme ma religion.',
    'Und ich bezeuge, dass es keinen Gott gibt außer Allah. Er ist allein und Er hat keinen Partner, und dass Muhammad ﷺ Sein Diener und Sein Gesandter ist. Ich bin zufrieden mit Allah als meinem Herrn, mit Muhammad als meinem Gesandten und mit dem Islam als meiner Religion.',
    'En ik getuig ook dat er geen god is dan Allah. Hij is de Enige en Hij heeft geen enkele partner, en dat Muhammad ﷺ Zijn dienaar en Zijn Boodschapper is. Ik ben tevreden met Allah als mijn Heer, met Muhammad als mijn Boodschapper, en met de Islam als mijn godsdienst.',
    'Ben de şehadet ederim ki, tek olan Allah''tan başka ilah yoktur, O''nun ortağı yoktur. Ve Muhammed ﷺ O''nun kulu ve elçisidir. Rab olarak Allah''tan, elçi olarak Muhammed''den ve din olarak İslam''dan razı oldum.',
    'Dan aku juga bersaksi bahwa tidak ada tuhan yang berhak disembah selain Allah Yang Maha Esa, tidak ada sekutu bagi-Nya, dan bahwa Muhammad ﷺ adalah hamba dan Utusan-Nya. Aku rida Allah sebagai Tuhanku, Muhammad sebagai Utusanku, dan Islam sebagai agamaku.',
    'اور میں بھی گواہی دیتا ہوں کہ اللہ کے سوا کوئی معبود نہیں، وہ اکیلا ہے، اس کا کوئی شریک نہیں، اور یہ کہ محمد ﷺ اس کے بندے اور اس کے رسول ہیں۔ میں اللہ کے رب ہونے، محمد ﷺ کے رسول ہونے اور اسلام کے دین ہونے پر راضی ہوں۔',
    'এবং আমিও সাক্ষ্য দিচ্ছি যে, এক আল্লাহ ছাড়া কোনো উপাস্য নেই, তাঁর কোনো শরিক নেই এবং মুহাম্মদ ﷺ তাঁর বান্দা ও রাসুল। আমি আল্লাহকে রব হিসেবে, মুহাম্মদ ﷺ-কে রাসুল হিসেবে এবং ইসলামকে দ্বীন (ধর্ম) হিসেবে পেয়ে সন্তুষ্ট হলাম।',
    'Dan aku juga bersaksi bahawa tiada tuhan yang berhak disembah melainkan Allah, Yang Maha Esa dan tiada sekutu bagi-Nya, dan bahawa Muhammad ﷺ adalah hamba dan Utusan-Nya. Aku reda Allah sebagai Tuhanku, Muhammad sebagai Utusanku, dan Islam sebagai agamaku.',
    'И я свидетельствую, что нет божества, достойного поклонения, кроме одного лишь Аллаха, у Которого нет сотоварища, и что Мухаммад ﷺ — Его раб и Его посланник. Доволен я Аллахом как Господом, Мухаммадом — как посланником и Исламом — как религией.',
    'After the adhan', 'Après l''adhan', 'بعد الأذان',
    'Nach dem Adhan', 'Na de adhan', 'Ezandan sonra', 'Setelah azan', 'Selepas azan',
    'اذان کے بعد', 'আযানের পর', 'После азана',
    'Muslim 386', 'Muslim 386', 'صحيح مسلم ٣٨٦',
    1::smallint, 5::smallint
  ),
  -- ═══════════════════════ 2. After the adhan #2 (salawat) ══════════════════
  (
    'اَللّٰهُمَّ صَلِّ عَلَىٰ مُحَمَّدٍ ، وَعَلَىٰ آلِ مُحَمَّدٍ',
    'Allāhumma ṣalli ʿalā Muḥammad, wa ʿalā āli Muḥammad.',
    'O Allah, honour and have mercy upon Muhammad and the family of Muhammad…',
    'Ô Allah, accorde Tes bénédictions et Ta miséricorde à Muhammad et à la famille de Muhammad…',
    'O Allah, segne Muhammad und die Familie Muhammads…',
    'O Allah, schenk eer en genade aan Muhammad en aan de familie van Muhammad…',
    'Allah''ım! Muhammed''e ve Muhammed''in ailesine salât eyle…',
    'Ya Allah, berikanlah selawat kepada Muhammad dan kepada keluarga Muhammad…',
    'اے اللہ! محمد ﷺ پر اور محمد ﷺ کی آل پر رحمت نازل فرما…',
    'হে আল্লাহ! আপনি মুহাম্মদ ও মুহাম্মদের বংশধরদের ওপর রহমত বর্ষণ করুন…',
    'Ya Allah, berikanlah selawat ke atas Muhammad dan ke atas keluarga Muhammad…',
    'О Аллах, благослови Мухаммада и семейство Мухаммада…',
    'After the adhan', 'Après l''adhan', 'بعد الأذان',
    'Nach dem Adhan', 'Na de adhan', 'Ezandan sonra', 'Setelah azan', 'Selepas azan',
    'اذان کے بعد', 'আযানের পর', 'После азана',
    'Muslim 384', 'Muslim 384', 'صحيح مسلم ٣٨٤',
    1::smallint, 5::smallint
  ),
  -- ════════════════════ 3. After the adhan #3 (al-wasila) ═══════════════════
  (
    'اَللّٰهُمَّ رَبَّ هٰذِهِ الدَّعْوَةِ التَّامَّةِ وَالصَّلَاةِ الْقَائِمَةِ ، آتِ مُحَمَّدًا الْوَسِيْلَةَ وَالْفَضِيْلَةَ ، وَابْعَثْهُ مَقَامًا مَّحْمُوْدًا الَّذِيْ وَعَدْتَّهُ',
    'Allāhumma Rabba hādhihi-d-daʿwati-t-tāmmah, wa-ṣ-ṣalāti-l-qā''imah, āti Muḥammada-l-wasīlata wa-l-faḍīlah, wa-bʿathhu maqāmam-maḥmūdan alladhī waʿadtah.',
    'O Allah, Lord of this perfect call and established prayer, grant Muhammad the status (a unique lofty status in Paradise) and pre-eminence, and resurrect him to the praiseworthy station that You have promised him.',
    'Ô Allah, Seigneur de cet appel parfait et de la prière imminente, accorde à Muhammad la place éminente et la distinction, et ressuscite-le à la station louable que Tu lui as promise.',
    'O Allah, Herr dieses perfekten Rufs und des bevorstehenden Gebets, gewähre Muhammad die höchste Stufe (al-Wasila) und den Vorzug, und erwecke ihn zu der lobenswerten Stätte, die Du ihm versprochen hast.',
    'O Allah, Heer van deze volmaakte roep en het vastgestelde gebed, schenk Muhammad de hoogste rang (al-Wasila) en de voortreffelijkheid, en doe hem opstaan op de prijzenswaardige plaats die U hem beloofd heeft.',
    'Allah''ım! Ey bu eksiksiz davetin ve kılınacak namazın Rabbi! Muhammed''e Vesîle makamını ve fazileti ver. Onu, kendisine vaat ettiğin Övülen Makam''a (Makam-ı Mahmud''a) ulaştır.',
    'Ya Allah, Tuhan pemilik panggilan yang sempurna ini dan shalat yang akan didirikan, berilah kepada Muhammad wasilah (kedudukan yang tinggi di surga) dan keutamaan, dan bangkitkanlah beliau di tempat yang terpuji yang telah Engkau janjikan kepadanya.',
    'اے اللہ! اس کامل پکار اور قائم ہونے والی نماز کے رب! محمد ﷺ کو وسیلہ اور فضیلت عطا فرما اور انہیں اس مقام محمود پر پہنچا جس کا تو نے ان سے وعدہ فرمایا ہے۔',
    'হে আল্লাহ! আপনি এই পূর্ণাঙ্গ আহ্বান এবং প্রতিষ্ঠিত সালাতের প্রতিপালক, মুহাম্মদ ﷺ-কে ওসিলা (জান্নাতের একটি উচ্চ মর্যাদা) ও ফযিলত (শ্রেষ্ঠত্ব) দান করুন এবং তাঁকে সেই প্রশংসিত স্থানে (মাকামে মাহমুদ) পুনরুত্থিত করুন, যার প্রতিশ্রুতি আপনি তাঁকে দিয়েছেন।',
    'Ya Allah, Tuhan pemilik seruan yang sempurna ini dan solat yang akan didirikan, kurniakanlah kepada Muhammad wasilah (kedudukan yang tinggi di syurga) dan keutamaan, dan bangkitkanlah beliau di tempat yang terpuji yang telah Engkau janjikan kepadanya.',
    'О Аллах, Господь этого совершенного призыва и устанавливающейся молитвы! Надели Мухаммада самым высоким положением (аль-Василя) и достоинством и воскреси его на месте достохвальном, которое Ты обещал ему.',
    'After the adhan', 'Après l''adhan', 'بعد الأذان',
    'Nach dem Adhan', 'Na de adhan', 'Ezandan sonra', 'Setelah azan', 'Selepas azan',
    'اذان کے بعد', 'আযানের পর', 'После азана',
    'Bukhārī 614', 'Bukhārī 614', 'صحيح البخاري ٦١٤',
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
where s.title_en = 'Adhan & call to prayer'
  and not exists (
    select 1 from public.adhkars a where a.adhkar_subcategory_id = s.id
  );

-- ── 5) Adhkars: The Masjid ───────────────────────────────────────────────────
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
  -- ═══════════════════════ 4. Whilst going to the masjid ════════════════════
  (
    'اَللّٰهُمَّ اجْعَلْ فِيْ قَلْبِيْ نُوْرًا ، وَفِيْ بَصَرِيْ نُوْرًا ، وَفِيْ سَمْعِيْ نُوْرًا ، وَعَنْ يَّمِيْنِيْ نُوْرًا ، وَعَنْ يَّسَارِيْ نُوْرًا ، وَفَوْقِيْ نُوْرًا ، وَتَحْتِيْ نُوْرًا ، وَأَمَامِيْ نُوْرًا ، وَخَلْفِيْ نُوْرًا ، وَاجْعَلْ لِيْ نُوْرًا',
    'Allāhumma-jʿal fī qalbī nūran, wa fī baṣarī nūran, wa fī samʿī nūran, wa ʿan yamīnī nūran, wa ʿan yasārī nūran, wa fawqī nūran, wa taḥtī nūran, wa amāmī nūran, wa khalfī nūran, wa-jʿal lī nūran.',
    'O Allah, place light in my heart, light in my sight and light in my hearing. Place light on my right and place light on my left. Place light above me and place light beneath me. Place light in front of me, place light behind me and grant me light.',
    'Ô Allah, mets de la lumière dans mon cœur, de la lumière dans ma vue et de la lumière dans mon ouïe. Mets de la lumière à ma droite et de la lumière à ma gauche. Mets de la lumière au-dessus de moi et de la lumière au-dessous de moi. Mets de la lumière devant moi, de la lumière derrière moi et accorde-moi de la lumière.',
    'O Allah, bringe Licht in mein Herz, Licht in mein Sehvermögen und Licht in mein Gehör. Bringe Licht zu meiner Rechten und Licht zu meiner Linken. Bringe Licht über mich und Licht unter mich. Bringe Licht vor mich, Licht hinter mich und schenke mir Licht.',
    'O Allah, plaats licht in mijn hart, licht in mijn gezichtsvermogen en licht in mijn gehoor. Plaats licht aan mijn rechterzijde en licht aan mijn linkerzijde. Plaats licht boven mij en licht onder mij. Plaats licht voor mij, licht achter mij en schenk mij licht.',
    'Allah''ım! Kalbime nur, gözüme nur, kulağıma nur ver. Sağma nur, soluma nur ver. Üstüme nur, altıma nur ver. Önüme nur, arkama nur ver. Bana büyük bir nur ihsan eyle.',
    'Ya Allah, jadikanlah cahaya di hatiku, cahaya di penglihatanku, dan cahaya di pendengaranku. Cahaya di sebelah kanan-ku, cahaya di sebelah kiri-ku, cahaya di atasku, dan cahaya di bawahku. Cahaya di depanku, cahaya di belakangku, dan berikanlah aku cahaya.',
    'اے اللہ! میرے دل میں نور پیدا کر دے، اور میری آنکھ میں نور، اور میرے کان میں نور، اور میرے دائیں نور، اور میرے بائیں نور، اور میرے اوپر نور، اور میرے نیچے نور، اور میرے آگے نور، اور میرے پیچھے نور پیدا کر دے، اور میرے لیے نور کو بڑا کر دے۔',
    'হে আল্লাহ! আমার অন্তরে আলো দিন, আমার দৃষ্টিতে আলো দিন, আমার শ্রবণে আলো দিন। আমার ডানে আলো দিন, আমার বামে আলো দিন। আমার ওপরে আলো দিন, আমার নিচে আলো দিন। আমার সামনে আলো দিন, আমার পেছনে আলো দিন এবং আমাকে প্রচুর আলো দান করুন।',
    'Ya Allah, jadikanlah cahaya di dalam hatiku, cahaya pada penglihatanku, dan cahaya pada pendengaranku. Cahaya di sebelah kananku, cahaya di sebelah kiriku, cahaya di atasku, dan cahaya di bawahku. Cahaya di depanku, cahaya di belakangku, dan kurniakanlah aku cahaya.',
    'О Аллах, сотвори в сердце моем свет, и в зрении моем свет, и в слухе моем свет, и справа от меня свет, и слева от меня свет, и надо мной свет, и подо мной свет, и передо мной свет, и позади меня свет, и даруй мне свет.',
    'Whilst going to the masjid', 'En se rendant à la mosquée', 'عند الذهاب إلى المسجد',
    'Auf dem Weg zur Moschee', 'Onderweg naar de moskee', 'Mescide giderken',
    'Ketika pergi ke masjid', 'Ketika pergi ke masjid', 'مسجد جاتے وقت',
    'মসজিদে যাওয়ার সময়', 'По дороге в мечеть',
    'Muslim 763', 'Muslim 763', 'صحيح مسلم ٧٦٣',
    1::smallint, 5::smallint
  ),
  -- ═══════════════════════ 5. When entering the masjid #1 ═══════════════════
  (
    'أَعُوْذُ بِاللّٰهِ الْعَظِيْمِ ، وَبِوَجْهِهِ الْكَرِيْمِ ، وَسُلْطَانِهِ الْقَدِيْمِ ، مِنَ الشَّيْطَانِ الرَّجِيْمِ',
    'Aʿūdhu bi-llāhi-l-ʿAẓīm, wa bi-wajhihi-l-karīm, wa sulṭānihi-l-qadīm, mina-sh-Shayṭāni-r-rajīm.',
    'I seek protection in Allah, the Supreme, His Noble Countenance, and His Eternal Authority from the accursed Shaytān.',
    'Je cherche refuge auprès d''Allah l''Immense, auprès de Son noble Visage et de Son autorité éternelle, contre le Diable maudit.',
    'Ich suche Zuflucht bei Allah, dem Allgewaltigen, bei Seinem edlen Angesicht und Seiner ewigen Macht vor dem gesteinigten Satan.',
    'Ik zoek toevlucht bij Allah, de Almachtige, bij Zijn Edele Aangezicht en Zijn Eeuwige Gezag tegen de vervloekte Sjaitan.',
    'Kovulmuş şeytandan, Yüce Allah''a, O''nun kerem sahibi vechine ebedi kudretine sığınırım.',
    'Aku berlindung kepada Allah Yang Maha Agung, dengan wajah-Nya Yang Maha Mulia dan kekuasaan-Nya yang qadim (terdahulu/abadi), dari setan yang terkutuk.',
    'میں عظمت والے اللہ کی، اس کے کریم چہرے کی اور اس کی قدیم سلطنت کی پناہ مانگتا ہوں مردود شیطان سے۔',
    'আমি বিতাড়িত শয়তান থেকে মহান আল্লাহর, তাঁর সম্মানিত চেহারার এবং তাঁর চিরন্তন রাজত্বের আশ্রয় প্রার্থনা করছি।',
    'Aku berlindung dengan Allah Yang Maha Agung, dengan wajah-Nya Yang Maha Mulia dan kekuasaan-Nya yang qadim (abadi), daripada syaitan yang terkutuk.',
    'Прибегаю к защите Великого Аллаха, Его благородного Лика и Его вечной власти от проклятого шайтана.',
    'When entering the masjid', 'En entrant dans la mosquée', 'عند دخول المسجد',
    'Beim Betreten der Moschee', 'Bij het betreden van de moskee', 'Mescide girerken',
    'Ketika masuk masjid', 'Ketika masuk masjid', 'مسجد میں داخل ہوتے وقت',
    'মসজিদে প্রবেশের সময়', 'При входе в мечеть',
    'Abū Dāwūd 466', 'Abū Dāwūd 466', 'سنن أبي داود ٤٦٦',
    1::smallint, 5::smallint
  ),
  -- ═══════════════════════ 6. When entering the masjid #2 ═══════════════════
  (
    'بِسْمِ اللّٰهِ ، وَالصَّلَاةُ وَالسَّلَامُ عَلَىٰ رَسُوْلِ اللّٰهِ ، اَللّٰهُمَّ اغْفِرْ لِيْ ذُنُوْبِيْ ، اَللّٰهُمَّ افْتَحْ لِيْ أَبْوَابَ رَحْمَتِكَ',
    'Bismi-llāh, wa-ṣ-ṣalātu wa-s-salāmu ʿalā Rasūli-llāh, allāhumma-ghfir lī dhunūbī, allāhumma-ftaḥ lī abwāba raḥmatik.',
    'In the Name of Allah. Peace and blessings be upon the Messenger of Allah. O Allah, forgive my sins. O Allah, open the gates of Your mercy for me.',
    'Au nom d''Allah, et que la prière et le salut soient sur le Messager d''Allah. Ô Allah, pardonne-moi mes péchés. Ô Allah, ouvre-moi les portes de Ta miséricorde.',
    'Im Namen Allahs, und Segen und Frieden seien auf dem Gesandten Allahs. O Allah, vergib mir meine Sünden. O Allah, öffne mir die Tore Deiner Barmherzigkeit.',
    'In de naam van Allah, en vrede en zegeningen zijn met de Boodschapper van Allah. O Allah, vergeef mij mijn zonden. O Allah, open de poorten van Uw barmhartigheid voor mij.',
    'Allah''ın adıyla. Salât ve selâm Allah''ın Elçisi''nin üzerine olsun. Allah''ım! Günahlarımı bağışla. Allah''ım! Bana rahmet kapılarını aç.',
    'Dengan nama Allah, semoga selawat dan salam tercurah kepada Utusan Allah. Ya Allah, ampunilah dosa-dosaku. Ya Allah, bukakanlah bagiku pintu-pintu rahmat-Mu.',
    'اللہ کے نام کے ساتھ، اور درود و سلام ہو اللہ کے رسول پر۔ اے اللہ! میرے گناہ معاف فرما۔ اے اللہ! میرے لیے اپنی رحمت کے دروازے کھول دے۔',
    'আল্লাহর নামে, আর সালাত ও সালাম বর্ষিত হোক আল্লাহর রাসুলের ওপর। হে আল্লাহ! আমার গুনাহগুলো ক্ষমা করে দিন। হে আল্লাহ! আমার জন্য আপনার রহমতের দরজাগুলো খুলে দিন।',
    'Dengan nama Allah, dan selawat serta salam ke atas Utusan Allah. Ya Allah, ampunilah dosa-dosaku. Ya Allah, bukakanlah bagiku pintu-pintu rahmat-Mu.',
    'С именем Аллаха, благословение и мир посланнику Аллаха. О Аллах, прости мне грехи мои. О Аллах, открой для меня врата Твоего милосердия.',
    'When entering the masjid', 'En entrant dans la mosquée', 'عند دخول المسجد',
    'Beim Betreten der Moschee', 'Bij het betreden van de moskee', 'Mescide girerken',
    'Ketika masuk masjid', 'Ketika masuk masjid', 'مسجد میں داخل ہوتے وقت',
    'মসজিদে প্রবেশের সময়', 'При входе в мечеть',
    'Muslim 713', 'Muslim 713', 'صحيح مسلم ٧١٣',
    1::smallint, 5::smallint
  ),
  -- ═══════════════════════ 7. When leaving the masjid #1 ════════════════════
  (
    'بِسْمِ اللّٰهِ ، وَالصَّلَاةُ وَالسَّلَامُ عَلَىٰ رَسُوْلِ اللّٰهِ ، اَللّٰهُمَّ إِنِّيْ أَسْأَلُكَ مِنْ فَضْلِكَ',
    'Bismi-llāh, wa-ṣ-ṣalātu wa-s-salāmu ʿalā Rasūli-llāh, allāhumma innī as''aluka min faḍlik.',
    'In the Name of Allah. Peace and blessings be upon the Messenger of Allah. O Allah, I ask You from Your bounty.',
    'Au nom d''Allah, et que la prière et le salut soient sur le Messager d''Allah. Ô Allah, je Te demande de Ta grâce.',
    'Im Namen Allahs, und Segen und Frieden seien auf dem Gesandten Allahs. O Allah, ich bitte Dich um Deine Huld.',
    'In de naam van Allah, en vrede en zegeningen zijn met de Boodschapper van Allah. O Allah, ik vraag U om Uw gunst.',
    'Allah''ın adıyla. Salât ve selâm Allah''ın Elçisi''nin üzerine olsun. Allah''ım! Senden lütuf ve ihsanını dilerim.',
    'Dengan nama Allah, semoga selawat dan salam tercurah kepada Utusan Allah. Ya Allah, sesungguhnya aku memohon karunia-Mu.',
    'اللہ کے نام کے ساتھ، اور درود و سلام ہو اللہ کے رسول پر۔ اے اللہ! میں تجھ سے تیرے فضل کا سوال کرتا ہوں۔',
    'আল্লাহর নামে, আর সালাত ও সালাম বর্ষিত হোক আল্লাহর রাসুলের ওপর। হে আল্লাহ! আমি আপনার কাছে আপনার অনুগ্রহ প্রার্থনা করছি।',
    'Dengan nama Allah, dan selawat serta salam ke atas Utusan Allah. Ya Allah, sesungguhnya aku memohon daripada limpah kurnia-Mu.',
    'С именем Аллаха, благословение и мир посланнику Аллаха. О Аллах, поистине, я прошу Тебя о Твоей милости.',
    'When leaving the masjid', 'En sortant de la mosquée', 'عند الخروج من المسجد',
    'Beim Verlassen der Moschee', 'Bij het verlaten van de moskee', 'Mescidden çıkarken',
    'Ketika keluar dari masjid', 'Ketika keluar dari masjid', 'مسجد سے نکلتے وقت',
    'মসজিদ থেকে বের হওয়ার সময়', 'При выходе из мечети',
    'Muslim 713', 'Muslim 713', 'صحيح مسلم ٧١٣',
    1::smallint, 5::smallint
  ),
  -- ═══════════════════════ 8. When leaving the masjid #2 ════════════════════
  (
    'اَللّٰهُمَّ اعْصِمْنِيْ مِنَ الشَّيْطَانِ الرَّجِيْمِ',
    'Allāhumma-ʿṣimnī mina-sh-Shayṭāni-r-rajīm.',
    'O Allah, protect me from the rejected Shaytān.',
    'Ô Allah, préserve-moi du Diable maudit.',
    'O Allah, schütze mich vor dem gesteinigten Satan.',
    'O Allah, bescherm mij tegen de vervloekte Sjaitan.',
    'Allah''ım! Beni kovulmuş şeytandan koru.',
    'Ya Allah, lindungilah aku dari setan yang terkutuk.',
    'اے اللہ! مجھے مردود شیطان سے محفوظ رکھ۔',
    'হে আল্লাহ! আপনি আমাকে বিতাড়িত শয়তান থেকে রক্ষা করুন।',
    'Ya Allah, peliharalah aku daripada syaitan yang terkutuk.',
    'О Аллах, защити меня от проклятого шайтана.',
    'When leaving the masjid', 'En sortant de la mosquée', 'عند الخروج من المسجد',
    'Beim Verlassen der Moschee', 'Bij het verlaten van de moskee', 'Mescidden çıkarken',
    'Ketika keluar dari masjid', 'Ketika keluar dari masjid', 'مسجد سے نکلتے وقت',
    'মসজিদ থেকে বের হওয়ার সময়', 'При выходе из мечети',
    'Ibn Mājah 773', 'Ibn Mājah 773', 'سنن ابن ماجه ٧٧٣',
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
where s.title_en = 'The Masjid'
  and not exists (
    select 1 from public.adhkars a where a.adhkar_subcategory_id = s.id
  );

-- ── Step 6: language fan-out (transliteration + references) ───────────────────

-- 6b) Transliteration is language-neutral Latin, reused for every Latin-script
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
  and s.title_en in ('Adhan & call to prayer', 'The Masjid');

-- 6c) Reference for Latin-script languages: collection names stay romanised.
update public.adhkars a
set
  reference_de = a.reference_en,
  reference_nl = a.reference_en,
  reference_tr = a.reference_en,
  reference_id = a.reference_en,
  reference_ms = a.reference_en
from public.adhkar_subcategories s
where a.adhkar_subcategory_id = s.id
  and s.title_en in ('Adhan & call to prayer', 'The Masjid');

-- 6d) Native-script transliteration + reference for ur / bn / ru, keyed by the
-- (unique across both subcategories) Latin transcription of each adhkar.
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
  -- 1. After the adhan #1
  ('Wa anā ashhadu an lā ilāha illa-llāhu waḥdahū lā sharīka lah, wa anna Muḥammadan ʿabduhū wa rasūluh, raḍītu bi-llāhi Rabban, wa bi-Muḥammadin rasūlan, wa bi-l-Islāmi dīnan.',
   'وَاَنَا اَشْھَدُ اَنْ لَّا اِلٰہَ اِلَّا اللہُ وَحْدَہٗ لَا شَرِیْکَ لَہٗ، وَاَنَّ مُحَمَّدًا عَبْدُہٗ وَرَسُوْلُہٗ، رَضِیْتُ بِاللہِ رَبًّا، وَبِمُحَمَّدٍ رَسُوْلًا، وَبِالْاِسْلَامِ دِیْنًا۔',
   'ওয়া আনা আশহাদু আল্লা ইলাহা ইল্লাল্লাহু ওয়াহদাহূ লা শারীকা লাহ, ওয়া আন্না মুহাম্মাদান আবদুহূ ওয়া রাসূলুহ, রাদীতু বিল্লাহি রাব্বা, ওয়া বিমুহাম্মাদিন রাসূলা, ওয়া বিল ইসলামি দীনা।',
   'Ва ана ашхаду ан ля иляха илля-Ллаху вахдаху ля шарика лях, ва анна Мухаммадан ’абдуху ва расулюх, радыту би-Лляхи Раббан, ва би-Мухаммадин расулян, ва би-ль-Ислями динан.',
   'مسلم 386', 'মুসলিম 386', 'Муслим 386'),
  -- 2. After the adhan #2
  ('Allāhumma ṣalli ʿalā Muḥammad, wa ʿalā āli Muḥammad.',
   'اَللّٰھُمَّ صَلِّ عَلٰی مُحَمَّدٍ، وَعَلٰی آلِ مُحَمَّدٍ۔',
   'আল্লাহুম্মা সাল্লি আলা মুহাম্মাদিন, ওয়া আলা আলি মুহাম্মাদ।',
   'Аллахумма салли ’аля Мухаммад, ва ’аля али Мухаммад.',
   'مسلم 384', 'মুসলিম 384', 'Муслим 384'),
  -- 3. After the adhan #3
  ('Allāhumma Rabba hādhihi-d-daʿwati-t-tāmmah, wa-ṣ-ṣalāti-l-qā''imah, āti Muḥammada-l-wasīlata wa-l-faḍīlah, wa-bʿathhu maqāmam-maḥmūdan alladhī waʿadtah.',
   'اَللّٰھُمَّ رَبَّ ھٰذِہِ الدَّعْوَۃِ التَّامَّۃِ وَالصَّلَاۃِ الْقَائِمَۃِ، آتِ مُحَمَّدَۨ الْوَسِیْلَۃَ وَالْفَضِیْلَۃَ، وَابْعَثْہُ مَقَامًا مَّحْمُوْدَۨ الَّذِیْ وَعَدْتَّہٗ۔',
   'আল্লাহুম্মা রাব্বা হাযিহিদ দা’ওয়াতিত তাম্মাহ, ওয়াস সালাতিল কায়িমাহ, আতি মুহাম্মাদানিল ওয়াসীলাতা ওয়াল ফাদীলাহ, ওয়াব’আছহু মাকামাম মাহমূদানিল্লাযী ওয়াআদতাহ।',
   'Аллахумма Рабба хазихи-д-да’вати-т-таммах, ва-с-саляти-ль-каима, ати Мухаммада-ль-василята валь-фадыля, ваб’асху макамам махмуданиллязи ва’адтах.',
   'بخاری 614', 'বুখারী 614', 'аль-Бухари 614'),
  -- 4. Whilst going to the masjid
  ('Allāhumma-jʿal fī qalbī nūran, wa fī baṣarī nūran, wa fī samʿī nūran, wa ʿan yamīnī nūran, wa ʿan yasārī nūran, wa fawqī nūran, wa taḥtī nūran, wa amāmī nūran, wa khalfī nūran, wa-jʿal lī nūran.',
   'اَللّٰھُمَّ اجْعَلْ فِیْ قَلْبِیْ نُوْرًا، وَفِیْ بَصَرِیْ نُوْرًا، وَفِیْ سَمْعِیْ نُوْرًا، وَعَنْ یَّمِیْنِیْ نُوْرًا، وَعَنْ یَّسَارِیْ نُوْرًا، وَفَوْقِیْ نُوْرًا، وَتَحْتِیْ نُوْرًا، وَاَمَامِیْ نُوْرًا، وَخَلْفِیْ نُوْرًا، وَاجْعَلْ لِّیْ نُوْرًا۔',
   'আল্লাহুম্মাজআল ফী কালবী নূরা, ওয়া ফী বাসারী নূরা, ওয়া ফী সাম’ঈ নূরা, ওয়া আন ইয়ামীনী নূরা, ওয়া আন ইয়াসারী নূরা, ওয়া ফাওকী নূরা, ওয়া তাহতী নূরা, ওয়া আমামী নূরা, ওয়া খালফী নূরা, ওয়াজআল লী নূরা।',
   'Аллахумма-дж’аль фи кальби нуран, ва фи басари нуран, ва фи сам’и нуран, ва ’ан ямини нуран, ва ’ан ясари нуран, ва фауки нуран, ва тахти нуран, ва амами нуран, ва хальфи нуран, ва-дж’аль ли нуран.',
   'مسلم 763', 'মুসলিম 763', 'Муслим 763'),
  -- 5. When entering the masjid #1
  ('Aʿūdhu bi-llāhi-l-ʿAẓīm, wa bi-wajhihi-l-karīm, wa sulṭānihi-l-qadīm, mina-sh-Shayṭāni-r-rajīm.',
   'اَعُوْذُ بِاللہِ الْعَظِیْمِ، وَبِوَجْھِہِ الْکَرِیْمِ، وَسُلْطَانِہِ الْقَدِیْمِ، مِنَ الشَّیْطَانِ الرَّجِیْمِ۔',
   'আঊযু বিল্লাহিল আযীম, ওয়া বিওয়াজহিহিল কারীম, ওয়া সুলতানিহিল কাদীম, মিনাশ শাইতানির রাজীম।',
   'А’узу би-Лляхи-ль-’Азым, ва би-ваджхихи-ль-карим, ва султанихи-ль-кадим, мина-ш-шайтани-р-раджим.',
   'ابو داؤد 466', 'আবু দাউদ 466', 'Абу Дауд 466'),
  -- 6. When entering the masjid #2
  ('Bismi-llāh, wa-ṣ-ṣalātu wa-s-salāmu ʿalā Rasūli-llāh, allāhumma-ghfir lī dhunūbī, allāhumma-ftaḥ lī abwāba raḥmatik.',
   'بِسْمِ اللہِ، وَالصَّلَاۃُ وَالسَّلَامُ عَلٰی رَسُوْلِ اللہِ، اَللّٰھُمَّ اغْفِرْ لِیْ ذُنُوْبِیْ، اَللّٰھُمَّ افْتَحْ لِیْ اَبْوَابَ رَحْمَتِکَ۔',
   'বিসমিল্লাহ, ওয়াস সালাতু ওয়াস সালামু আলা রাসূলিল্লাহ, আল্লাহুম্মাগফির লী যুনূবী, আল্লাহুম্মাফতাহ লী আবওয়াবা রাহমাতিক।',
   'Бисми-Ллях, ва-с-саляту ва-с-саляму ’аля Расули-Ллях, Аллахумма-гфир ли зунуби, Аллахумма-фтах ли абваба рахматик.',
   'مسلم 713', 'মুসলিম 713', 'Муслим 713'),
  -- 7. When leaving the masjid #1
  ('Bismi-llāh, wa-ṣ-ṣalātu wa-s-salāmu ʿalā Rasūli-llāh, allāhumma innī as''aluka min faḍlik.',
   'بِسْمِ اللہِ، وَالصَّلَاۃُ وَالسَّلَامُ عَلٰی رَسُوْلِ اللہِ، اَللّٰھُمَّ اِنِّیْ اَسْاَلُکَ مِنْ فَضْلِکَ۔',
   'বিসমিল্লাহ, ওয়াস সালাতু ওয়াস সালামু আলা রাসূলিল্লাহ, আল্লাহুম্মা ইন্নী আসআলুকা মিন ফাদলিক।',
   'Бисми-Ллях, ва-с-саляту ва-с-саляму ’аля Расули-Ллях, Аллахумма инни ас’алюка мин фадлик.',
   'مسلم 713', 'মুসলিম 713', 'Муслим 713'),
  -- 8. When leaving the masjid #2
  ('Allāhumma-ʿṣimnī mina-sh-Shayṭāni-r-rajīm.',
   'اَللّٰھُمَّ اعْصِمْنِیْ مِنَ الشَّیْطَانِ الرَّجِیْمِ۔',
   'আল্লাহুম্মা’সিমনী মিনাশ শাইতানির রাজীম।',
   'Аллахумма-’сымни мина-ш-шайтани-р-раджим.',
   'ابن ماجہ 773', 'ইবনে মাজাহ 773', 'Ибн Маджа 773')
) as m(tr_key, t_ur, t_bn, t_ru, r_ur, r_bn, r_ru)
where a.adhkar_subcategory_id = s.id
  and s.title_en in ('Adhan & call to prayer', 'The Masjid')
  and a.transcription_en = m.tr_key;
