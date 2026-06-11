-- =============================================================================
-- Seed: "Istiftah (Opening duʿā)" subcategory (under existing "Around salah"
--        category) + 6 opening supplications recited at the start of salah.
--
-- Source: user-provided translation sheet (istiftah_adhkar_translations.csv).
-- The "Around salah" category is created by 20260617000000; here we only
-- resolve it by title.
--
-- Localization mirrors 20260617000000:
--   * arabic_text      – exact source text
--   * translation_*    – en, fr, de, nl, tr, id, ur, bn, ms, ru (from the sheet)
--   * transcription_*  – Latin transliteration in VALUES; fanned out to every
--                        Latin-script column (step 4b) + dedicated ur/bn/ru
--                        native-script transcription (step 4d, keyed on the
--                        unique transcription_en)
--   * when_*           – istiftah context phrase, localised to every language
--   * reference_*      – en/fr/ar in VALUES; de/nl/tr/id/ms via step 4c and
--                        ur/bn/ru via step 4d
--
-- Source-sheet fix applied: Turkish #3 stray Arabic glyph ("و" -> "ve").
--
-- References: #1 (Abū Dāwūd 776), #3 (Muslim 600), #4 (Muslim 601),
-- #5 (Muslim 770) are the standard attributions. #8 and #9 are left NULL
-- because a confident single-source attribution was not available — do not
-- assume a hadith number without verification.
--
-- Idempotent: subcategory inserted if missing; adhkars inserted only when the
-- subcategory has none yet.
--
-- REVIEW NOTE: hadith references and the ur/bn/ru phonetic transcriptions were
-- not part of the source sheet — they follow the standard Hisnul-Muslim
-- attributions and should be reviewed by a qualified native speaker before
-- production use.
-- =============================================================================

-- ── Subcategory: Istiftah (Opening duʿā) ─────────────────────────────────────
insert into public.adhkar_subcategories
  (adhkar_category_id, title_en, title_fr, title_ar, title_de, title_nl, title_tr,
   title_id, title_ur, title_bn, title_ms, title_ru, position)
select
  c.id, 'Istiftah (Opening duʿā)', 'Istiftah (du''a d''ouverture)', 'دعاء الاستفتاح',
  'Istiftah (Eröffnungsbittgebet)', 'Istiftah (openingssmeekbede)', 'İstiftah (açılış duası)',
  'Istiftah (doa pembuka)', 'استفتاح (دعائے آغاز)', 'ইস্তিফতাহ (সূচনা দোয়া)',
  'Istiftah (doa pembuka)', 'Истифтах (вступительная дуа)', 3
from public.adhkar_categories c
where c.title_en = 'Around salah'
  and not exists (
    select 1 from public.adhkar_subcategories s
    where s.title_en = 'Istiftah (Opening duʿā)' and s.adhkar_category_id = c.id
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
  -- ═══════════════════════════════ 1. Istiftah #1 ═══════════════════════════
  (
    'سُبْحَانَكَ اللّٰهُمَّ وَبِحَمْدِكَ ، وَتَبَارَكَ اسْمُكَ ، وَتَعَالَىٰ جَدُّكَ ، وَلَا إِلٰهَ غَيْرُكَ.',
    'Subḥānaka-llāhumma wa bi-ḥamdik, wa tabāraka-smuk, wa taʿālā jadduk, wa lā ilāha ghayruk.',
    'How Perfect are You O Allah, and all praise is Yours. Your Name is most blessed, Your majesty is exalted and there is no god worthy of worship except You.',
    'Gloire et louange à Toi, ô Allah. Béni soit Ton Nom, exaltée soit Ta majesté, et il n''y a pas d''autre divinité digne d''adoration que Toi.',
    'Gepriesen seist Du, o Allah, und alles Lob gebührt Dir. Gesegnet ist Dein Name, erhaben ist Deine Majestät, und es gibt keinen Gott außer Dir.',
    'U bent vrij van imperfecties, o Allah, en alle lof komt U toe. Gezegend is Uw Naam, verheven is Uw majesteit en er is geen god waardig om aanbeden te worden behalve U.',
    'Allah''ım! Seni eksik sıfatlardan tenzih eder ve hamdimi Sana sunarım. Senin adın mübarektir, şanın yücedir ve Senden başka hiçbir ilah yoktur.',
    'Maha Suci Engkau, ya Allah, dan segala puji bagi-Mu. Maha Berkah nama-Mu, Maha Tinggi keagungan-Mu, dan tidak ada tuhan yang berhak disembah selain Engkau.',
    'اے اللہ! تو پاک ہے اور تمام تعریفیں تیرے ہی لیے ہیں، اور تیرا نام برکت والا ہے، اور تیری شان بہت بلند ہے، اور تیرے سوا کوئی معبود نہیں۔',
    'হে আল্লাহ! আপনি পবিত্র এবং সমস্ত প্রশংসা আপনারই। আপনার নাম বরকতময়, আপনার মহিমা সুউচ্চ এবং আপনি ছাড়া কোনো সত্য উপাস্য নেই।',
    'Maha Suci Engkau, ya Allah, dan segala puji bagi-Mu. Maha Berkat nama-Mu, Maha Tinggi keagungan-Mu, dan tiada tuhan yang berhak disembah melainkan Engkau.',
    'Пречист Ты, о Аллах, и хвала Тебе! Благословенно имя Твое, превыше всего величие Твое, и нет божества, достойного поклонения, кроме Тебя.',
    'Opening dua (istiftah), after takbir', 'Du''a d''ouverture (istiftah), après le takbir', 'دعاء الاستفتاح',
    'Eröffnungsbittgebet (Istiftah), nach dem Takbir', 'Openingssmeekbede (istiftah), na de takbir',
    'Açılış duası (istiftah), tekbirden sonra', 'Doa pembuka (istiftah), setelah takbir',
    'Doa pembuka (istiftah), selepas takbir', 'دعائے استفتاح، تکبیر کے بعد',
    'দোয়ায়ে ইস্তিফতাহ, তাকবিরের পর', 'Дуа-истифтах (вступительная), после такбира',
    'Abū Dāwūd 776', 'Abū Dāwūd 776', 'سنن أبي داود ٧٧٦',
    1::smallint, 5::smallint
  ),
  -- ═══════════════════════════════ 2. Istiftah #3 ═══════════════════════════
  (
    'اَلْحَمْدُ لِلّٰهِ حَمْدًا كَثِيْرًا طَيِّبًا مُّبَارَكًا فِيْهِ.',
    'Alḥamdu li-llāhi ḥamdan kathīran ṭayyiban mubārakan fīh.',
    'All praise is for Allah; an abundant, sincere and blessed praise.',
    'Louange à Allah, une louange abondante, pure et bénie.',
    'Alles Lob gebührt Allah; ein reichliches, reines und gesegnetes Lob.',
    'Alle lof komt toe aan Allah; een overvloedige, oprechte en gezegende lofprijzing.',
    'Çok, tertemiz ve mübarek hamdler Allah''a mahsustur.',
    'Segala puji bagi Allah dengan pujian yang banyak, baik, lagi penuh berkah di dalamnya.',
    'تمام تعریفیں اللہ ہی کے لیے ہیں، ایسی تعریف جو بہت زیادہ، پاکیزہ اور برکت والی ہو۔',
    'সমস্ত প্রশংসা আল্লাহর জন্য; এমন প্রশংসা যা প্রচুর, পবিত্র এবং বরকতময়।',
    'Segala puji bagi Allah dengan pujian yang banyak, baik, lagi penuh berkat di dalamnya.',
    'Хвала Аллаху, хвала многая, благая и благословенная!',
    'Opening dua (istiftah), after takbir', 'Du''a d''ouverture (istiftah), après le takbir', 'دعاء الاستفتاح',
    'Eröffnungsbittgebet (Istiftah), nach dem Takbir', 'Openingssmeekbede (istiftah), na de takbir',
    'Açılış duası (istiftah), tekbirden sonra', 'Doa pembuka (istiftah), setelah takbir',
    'Doa pembuka (istiftah), selepas takbir', 'دعائے استفتاح، تکبیر کے بعد',
    'দোয়ায়ে ইস্তিফতাহ, তাকবিরের পর', 'Дуа-истифтах (вступительная), после такбира',
    'Muslim 600', 'Muslim 600', 'صحيح مسلم ٦٠٠',
    1::smallint, 5::smallint
  ),
  -- ═══════════════════════════════ 3. Istiftah #4 ═══════════════════════════
  (
    'اَللّٰهُمَّ أَكْبَرُ كَبِيْرًا ، وَالْحَمْدُ لِلّٰهِ كَثِيْرًا ، وَسُبْحَانَ اللّٰهِ بُكْرَةً وَّأَصِيْلًا.',
    'Allāhu akbaru kabīran, wa-l-ḥamdu li-llāhi kathīran, wa subḥāna-llāhi bukratan wa aṣīlan.',
    'Allah is Greater, the Greatest: abundant praise is for Allah, and how Perfect is Allah in the morning and the evening.',
    'Allah est le Plus Grand, infiniment Grand. Louange abondante à Allah, et gloire à Allah matin et soir.',
    'Allah ist unvergleichlich groß; reichliches Lob gebührt Allah, und gepriesen sei Allah morgens und abends.',
    'Allah is de Grootste, buitengewoon Groot; overvloedige lof komt toe aan Allah, en hoe volmaakt is Allah in de ochtend en in de avond.',
    'Allah en büyüktür, hamd çokça O''na aittir. Sabah ve akşam Allah''ı tüm noksanlıklardan tenzih ederim.',
    'Allah Maha Besar dengan segala kebesaran, segala puji yang banyak bagi Allah, dan Maha Suci Allah pada waktu pagi dan petang.',
    'اللہ سب سے بڑا ہے بہت بڑا، اور اللہ کے لیے بہت زیادہ تعریفیں ہیں، اور صبح و شام اللہ کی پاکیزگی بیان کرتا ہوں۔',
    'আল্লাহ মহান, পরম মহান; আল্লাহর জন্য প্রচুর প্রশংসা এবং সকাল-সন্ধ্যায় আল্লাহর পবিত্রতা ঘোষণা করছি।',
    'Allah Maha Besar dengan segala kebesaran, segala puji yang banyak bagi Allah, dan Maha Suci Allah pada waktu pagi dan petang.',
    'Аллах велик, намного величественнее всего, хвала Аллаху многая, и пречист Аллах утром и вечером.',
    'Opening dua (istiftah), after takbir', 'Du''a d''ouverture (istiftah), après le takbir', 'دعاء الاستفتاح',
    'Eröffnungsbittgebet (Istiftah), nach dem Takbir', 'Openingssmeekbede (istiftah), na de takbir',
    'Açılış duası (istiftah), tekbirden sonra', 'Doa pembuka (istiftah), setelah takbir',
    'Doa pembuka (istiftah), selepas takbir', 'دعائے استفتاح، تکبیر کے بعد',
    'দোয়ায়ে ইস্তিফতাহ, তাকবিরের পর', 'Дуа-истифтах (вступительная), после такбира',
    'Muslim 601', 'Muslim 601', 'صحيح مسلم ٦٠١',
    1::smallint, 5::smallint
  ),
  -- ═══════════════════════════════ 4. Istiftah #5 ═══════════════════════════
  (
    'اَللّٰهُمَّ رَبَّ جَبْرَائِيْلَ وَمِيْكَائِيْلَ وَإِسْرَافِيْلَ ، فَاطِرَ السَّمٰـوٰتِ وَالْأَرْضِ ، عَالِمَ الْغَيْبِ وَالشَّهَادَةِ ، أَنْتَ تَحْكُمُ بَيْنَ عِبَادِكَ فِيْمَا كَانُوْا فِيْهِ يَخْتَلِفُوْنَ ، اِهْدِنِيْ لِمَا اخْتُلِفَ فِيْهِ مِنَ الْحَقِّ بِإِذْنِكَ ، إِنَّكَ تَهْدِيْ مَنْ تَشَآءُ إِلَىٰ صِرَاطٍ مُّسْتَقِيْمٍ.',
    'Allāhumma Rabba Jabrā''īla wa Mīkā''īla wa Isrāfīl, Fāṭira-s-samāwāti wa-l-arḍ, ʿĀlima-l-ghaybi wa-sh-shahādah, anta taḥkumu bayna ʿibādika fīmā kānū fīhi yakhtalifūn, ihdinī limā-khtulifa fīhi mina-l-ḥaqqi bi-idhnik, innaka tahdī man tashā''u ilā ṣirāṭim-mustaqīm.',
    'O Allah, Lord of Jabrā’īl, Mīkā’īl and Isrāfīl; Creator of the heavens and the earth; Knower of the unseen and seen, You will judge between Your servants in what they used to differ. Guide me to the truth in matters over which there is disagreement, by Your permission. Certainly, You guide whomsoever You will to a straight path.',
    'Ô Allah, Seigneur de Gabriel, de Michel et d''Israfil ; Créateur des cieux et de la terre ; Connaisseur du monde invisible et visible, c''est Toi qui jugeras entre Tes serviteurs sur ce quoi ils divergeaient. Guide-moi, par Ta permission, vers la vérité là où il y a eu divergence. Certes, Tu guides qui Tu veux vers le droit chemin.',
    'O Allah, Herr von Jabra''il, Mika''il und Israfil; Schöpfer der Himmel und der Erde; Kenner des Verborgenen und des Offenkundigen, Du wirst zwischen Deinen Dienern richten über das, worüber sie uneins waren. Leite mich mit Deiner Erlaubnis zur Wahrheit in den Fragen, über die Uneinigkeit herrscht. Gewiss, Du leitest, wen Du willst, auf einen geraden Weg.',
    'O Allah, Heer van Jabra''il, Mika''il en Israfil; Schepper van de hemelen en de aarde; Kenner van het onwaarneembare en het waarneembare, U zult oordelen tussen Uw dienaren over datgene waarin zij plachten te verschillen. Leid mij met Uw toestemming naar de waarheid in zaken waarover onenigheid bestaat. Voorwaar, U leidt wie U wilt naar het rechte pad.',
    'Ey Cebrail''in, Mikail''in ve İsrafil''in Rabbi, göklerin ve yerin yaratanı, gizliyi ve açığı bilen Allah''ım! Kullarının ihtilaf ettikleri şeyler hakkında aralarında Sen hükmedersin. İzinle, hakkında ihtilaf edilen hakkı bulmam için bana hidayet et. Şüphesiz Sen dilediğini dosdoğru yola iletirsin.',
    'Ya Allah, Tuhan Jibril, Mikail, dan Israfil; Pencipta langit dan bumi; Yang Mengetahui hal yang gaib dan yang nyata, Engkaulah yang menghakimi di antara hamba-hamba-Mu dalam apa yang mereka perselisihkan. Tunjukkanlah aku pada kebenaran dari apa yang diperselisihkan dengan izin-Mu. Sesungguhnya Engkau memberi petunjuk kepada siapa yang Engkau kehendaki ke jalan yang lurus.',
    'اے اللہ! جبرائیل، میکائیل اور اسرافیل کے رب، آسمانوں اور زمین کو پیدا کرنے والے، چھپے اور ظاہر کے جاننے والے، تو ہی اپنے بندوں کے درمیان ان باتوں کا فیصلہ کرے گا جن میں وہ اختلاف کرتے تھے۔ تو حق کے معاملے میں جو اختلاف کیا گیا ہے، اپنے حکم سے میری رہنمائی فرما، یقیناً تو جسے چاہتا ہے سیدھے راستے کی طرف ہدایت دیتا ہے۔',
    'হে আল্লাহ! জিবরাঈল, মিকাঈল ও ইসরাফীলের প্রতিপালক; আসমান ও জমিনের স্রষ্টা; দৃশ্য ও অদৃশ্যের পরিজ্ঞাত, আপনার বান্দারা যে বিষয়ে মতবিরোধ করত, আপনি তাদের মধ্যে তার ফয়সালা করবেন। যে বিষয়ে মতভেদ সৃষ্টি হয়েছে, আপনার অনুমতিতে আমাকে সত্যের দিকে পরিচালিত করুন। নিশ্চয়ই আপনি যাকে ইচ্ছা সরল সঠিক পথ দেখান।',
    'Ya Allah, Tuhan Jibril, Mikail, dan Israfil; Pencipta langit dan bumi; Yang Mengetahui perkara ghaib dan nyata, Engkaulah yang menghakimi di antara hamba-hamba-Mu dalam apa yang mereka perselisihkan. Tunjukkanlah aku kepada kebenaran daripada apa yang diperselisihkan dengan izin-Mu. Sesungguhnya Engkau memberi petunjuk kepada sesiapa yang Engkau kehendaki ke jalan yang lurus.',
    'О Аллах, Господь Джибраила, Микаила и Исрафила, Творец небес и земли, Знающий сокровенное и явное, Ты рассудишь между Своими рабами в том, в чем они расходились между собой. Руководи мной по Своей воле к истине в том, в чем возникли расхождения, поистине, Ты ведешь, кого пожелаешь, к прямому пути.',
    'Opening dua (istiftah), after takbir', 'Du''a d''ouverture (istiftah), après le takbir', 'دعاء الاستفتاح',
    'Eröffnungsbittgebet (Istiftah), nach dem Takbir', 'Openingssmeekbede (istiftah), na de takbir',
    'Açılış duası (istiftah), tekbirden sonra', 'Doa pembuka (istiftah), setelah takbir',
    'Doa pembuka (istiftah), selepas takbir', 'دعائے استفتاح، تکبیر کے بعد',
    'দোয়ায়ে ইস্তিফতাহ, তাকবিরের পর', 'Дуа-истифтах (вступительная), после такбира',
    'Muslim 770', 'Muslim 770', 'صحيح مسلم ٧٧٠',
    1::smallint, 5::smallint
  ),
  -- ═══════════════════════════════ 5. Istiftah #8 ═══════════════════════════
  (
    'سُبْحَانَ اللّٰهِ رَبِّ الْعَالَمِيْنَ ، سُبْحَانَ اللّٰهِ وَبِحَمْدِهِ.',
    'Subḥāna-llāhi Rabbi-l-ʿālamīn, subḥāna-llāhi wa bi-ḥamdih.',
    'Allah is free from imperfection, the Lord of all the worlds. Allah is free from imperfection, and all praise is due to Him.',
    'Gloire à Allah, Seigneur de l''univers. Gloire à Allah et à Lui la louange.',
    'Gepriesen sei Allah, der Herr der Welten. Gepriesen sei Allah und Lob gebührt Ihm.',
    'Gepriesen is Allah, de Heer der werelden. Gepriesen is Allah en alle lof komt Hem toe.',
    'Âlemlerin Rabbi olan Allah''ı noksan sıfatlardan tenzih ederim. Allah''ı hamdiyle tenzih ederim.',
    'Maha Suci Allah, Tuhan semesta alam. Maha Suci Allah dan dengan memuji-Nya.',
    'پاک ہے اللہ جو تمام جہانوں کا رب ہے، پاک ہے اللہ اپنی تعریفوں کے ساتھ۔',
    'সৃষ্টিজগতের প্রতিপালক আল্লাহ পবিত্র, আল্লাহর প্রশংসাসহ তাঁর পবিত্রতা ঘোষণা করছি।',
    'Maha Suci Allah, Tuhan semesta alam. Maha Suci Allah dan dengan memuji-Nya.',
    'Пречист Аллах, Господь миров. Пречист Аллах, и хвала Ему.',
    'Opening dua (istiftah), after takbir', 'Du''a d''ouverture (istiftah), après le takbir', 'دعاء الاستفتاح',
    'Eröffnungsbittgebet (Istiftah), nach dem Takbir', 'Openingssmeekbede (istiftah), na de takbir',
    'Açılış duası (istiftah), tekbirden sonra', 'Doa pembuka (istiftah), setelah takbir',
    'Doa pembuka (istiftah), selepas takbir', 'دعائے استفتاح، تکبیر کے بعد',
    'দোয়ায়ে ইস্তিফতাহ, তাকবিরের পর', 'Дуа-истифтах (вступительная), после такбира',
    NULL, NULL, NULL,
    1::smallint, 5::smallint
  ),
  -- ═══════════════════════════════ 6. Istiftah #9 ═══════════════════════════
  (
    'اَللهُ أَكْبَرُ (x10)، اَلْحَمْدُ لِلّٰهِ (x10)، سُبْحَانَ اللهِ (x10)، لَا إِلٰهَ إِلَّا اللهُ (x10)، أَسْتَغْفِرُ اللهَ (x10)، اَللّٰهُمَّ اغْفِرْ لِيْ وَاهْدِنِيْ وَارْزُقْنِيْ وَعَافِنِيْ ، أَعُوْذُ بِاللّٰهِ مِنْ ضِيْقِ الْمَقَامِ يَوْمَ الْقِيَامَةِ.',
    'Allāhu akbar (x10), alḥamdu li-llāh (x10), subḥāna-llāh (x10), lā ilāha illa-llāh (x10), astaghfiru-llāh (x10), allāhumma-ghfir lī wa-hdinī wa-rzuqnī wa ʿāfinī, aʿūdhu bi-llāhi min ḍīqi-l-maqāmi yawma-l-qiyāmah.',
    'Allah is the Greatest. All praise be to Allah. Allah is free from imperfection. There is no god but Allah. I seek Allah’s forgiveness. O Allah, forgive me, guide me, grant me sustenance and wellbeing. I seek your protection from the anguish of standing on the Day of Judgement.',
    'Allah est le Plus Grand (x10). Louange à Allah (x10). Gloire à Allah (x10). Il n''y a de divinité d''autre qu''Allah (x10). Je demande pardon à Allah (x10). Ô Allah, pardonne-moi, guide-moi, accorde-moi ma subsistance et la santé. Je cherche Ta protection contre l''angoisse de la station au Jour de la Résurrection.',
    'Allah ist am größten (x10). Alles Lob gebührt Allah (x10). Gepriesen sei Allah (x10). Es gibt keinen Gott außer Allah (x10). Ich bitte Allah um Vergebung (x10). O Allah, vergib mir, leite mich, versorge mich und gewähre mir Wohlergehen. Ich suche Zuflucht bei Dir vor der Enge des Stehens am Tag der Auferstehung.',
    'Allah is de Grootste (x10). Alle lof komt toe aan Allah (x10). Gepriesen is Allah (x10). Er is geen god dan Allah (x10). Ik vraag Allah om vergeving (x10). O Allah, vergeef mij, leid mij, schenk mij onderhoud en schenk mij gezondheid. Ik zoek Uw bescherming tegen de angst van het staan op de Dag des Oordeels.',
    'Allah en büyüktür (x10). Allah''a hamdolsun (x10). Allah noksanlıklardan uzaktır (x10). Allah''tan başka ilah yoktur (x10). Allah''tan bağışlanma dilerim (x10). Allah''ım, beni bağışla, bana hidayet et, beni rızıklandır ve bana afiyet ver. Kıyamet günündeki makamın darlığından (sıkıntısından) Allah''a sığınırım.',
    'Allah Maha Besar (x10). Segala puji bagi Allah (x10). Maha Suci Allah (x10). Tidak ada tuhan yang berhak disembah selain Allah (x10). Aku memohon ampunan kepada Allah (x10). Ya Allah, ampunilah aku, berilah aku petunjuk, berilah aku rezeki, dan berilah aku kesehatan. Aku berlindung kepada Allah dari kesempitan tempat berdiri pada hari kiamat.',
    'اللہ سب سے بڑا ہے (10 بار)، تمام تعریفیں اللہ ہی کے لیے ہیں (10 بار)، اللہ پاک ہے (10 بار)، اللہ کے سوا کوئی معبود نہیں (10 بار)، میں اللہ سے مغفرت مانگتا ہوں (10 بار)۔ اے اللہ! مجھے بخش دے، مجھے ہدایت دے، مجھے رزق عطا فرما اور مجھے عافیت دے۔ میں قیامت کے دن کھڑے ہونے کی جگہ کی تنگی سے اللہ کی پناہ مانگتا ہوں۔',
    'আল্লাহ মহান (১০ বার), সমস্ত প্রশংসা আল্লাহর (১০ বার), আল্লাহ পবিত্র (১০ বার), আল্লাহ ছাড়া কোনো উপাস্য নেই (১০ বার), আমি আল্লাহর কাছে ক্ষমা প্রার্থনা করছি (১০ বার)। হে আল্লাহ! আমাকে ক্ষমা করুন, আমাকে হেদায়েত দিন, আমাকে জীবিকা দান করুন এবং আমাকে সুস্থতা দিন। কিয়ামত দিবসের অবস্থানের সংকীর্ণতা থেকে আমি আল্লাহর আশ্রয় চাচ্ছি।',
    'Allah Maha Besar (x10). Segala puji bagi Allah (x10). Maha Suci Allah (x10). Tiada tuhan yang berhak disembah melainkan Allah (x10). Aku memohon ampun kepada Allah (x10). Ya Allah, ampunilah aku, berilah aku petunjuk, kurniakanlah aku rezeki, dan berilah aku kesihatan. Aku berlindung kepada Allah daripada kesempitan tempat berdiri pada hari kiamat.',
    'Аллах велик (х10). Хвала Аллаху (х10). Пречист Аллах (х10). Нет божества, достойного поклонения, кроме Аллаха (х10). Прошу Аллаха о прощении (х10). О Аллах, прости меня, наставь меня, даруй мне удел и избавление. Прибегаю к Аллаху от тягости стояния в День воскресения.',
    'Opening dua (istiftah), after takbir', 'Du''a d''ouverture (istiftah), après le takbir', 'دعاء الاستفتاح',
    'Eröffnungsbittgebet (Istiftah), nach dem Takbir', 'Openingssmeekbede (istiftah), na de takbir',
    'Açılış duası (istiftah), tekbirden sonra', 'Doa pembuka (istiftah), setelah takbir',
    'Doa pembuka (istiftah), selepas takbir', 'دعائے استفتاح، تکبیر کے بعد',
    'দোয়ায়ে ইস্তিফতাহ, তাকবিরের পর', 'Дуа-истифтах (вступительная), после такбира',
    NULL, NULL, NULL,
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
where s.title_en = 'Istiftah (Opening duʿā)'
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
  and s.title_en = 'Istiftah (Opening duʿā)';

-- 4c) Reference for Latin-script languages: collection names stay romanised
-- (NULL references for #8/#9 propagate as NULL).
update public.adhkars a
set
  reference_de = a.reference_en,
  reference_nl = a.reference_en,
  reference_tr = a.reference_en,
  reference_id = a.reference_en,
  reference_ms = a.reference_en
from public.adhkar_subcategories s
where a.adhkar_subcategory_id = s.id
  and s.title_en = 'Istiftah (Opening duʿā)';

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
  -- 1. Istiftah #1
  ('Subḥānaka-llāhumma wa bi-ḥamdik, wa tabāraka-smuk, wa taʿālā jadduk, wa lā ilāha ghayruk.',
   'سُبْحَانَکَ اللّٰھُمَّ وَبِحَمْدِک، وَتَبَارَکَ اسْمُک، وَتَعَالٰی جَدُّک، وَلَا اِلٰہَ غَیْرُک۔',
   'সুবহানাকাল্লাহুম্মা ওয়া বিহামদিক, ওয়া তাবারাকাসমুক, ওয়া তাআলা জাদ্দুক, ওয়া লা ইলাহা গাইরুক।',
   'Субханака-Ллахумма ва би-хамдик, ва табаракасмук, ва та’аля джаддук, ва ля иляха гайрук.',
   'ابو داؤد 776', 'আবু দাউদ 776', 'Абу Дауд 776'),
  -- 2. Istiftah #3
  ('Alḥamdu li-llāhi ḥamdan kathīran ṭayyiban mubārakan fīh.',
   'اَلْحَمْدُ لِلہِ حَمْدًا کَثِیْرًا طَیِّبًا مُّبَارَکًا فِیْہِ۔',
   'আলহামদু লিল্লাহি হামদান কাছীরান তাইয়িবাম মুবারাকান ফীহ।',
   'Аль-хамду ли-Лляхи хамдан касиран таййибан мубаракан фих.',
   'مسلم 600', 'মুসলিম 600', 'Муслим 600'),
  -- 3. Istiftah #4
  ('Allāhu akbaru kabīran, wa-l-ḥamdu li-llāhi kathīran, wa subḥāna-llāhi bukratan wa aṣīlan.',
   'اَللہُ اَکْبَرُ کَبِیْرًا، وَالْحَمْدُ لِلہِ کَثِیْرًا، وَسُبْحَانَ اللہِ بُکْرَۃً وَّاَصِیْلًا۔',
   'আল্লাহু আকবারু কাবীরা, ওয়াল হামদু লিল্লাহি কাছীরা, ওয়া সুবহানাল্লাহি বুকরাতাঁও ওয়া আসীলা।',
   'Аллаху акбару кабиран, валь-хамду ли-Лляхи касиран, ва субхана-Ллахи букратан ва асыля.',
   'مسلم 601', 'মুসলিম 601', 'Муслим 601'),
  -- 4. Istiftah #5
  ('Allāhumma Rabba Jabrā''īla wa Mīkā''īla wa Isrāfīl, Fāṭira-s-samāwāti wa-l-arḍ, ʿĀlima-l-ghaybi wa-sh-shahādah, anta taḥkumu bayna ʿibādika fīmā kānū fīhi yakhtalifūn, ihdinī limā-khtulifa fīhi mina-l-ḥaqqi bi-idhnik, innaka tahdī man tashā''u ilā ṣirāṭim-mustaqīm.',
   'اَللّٰھُمَّ رَبَّ جَبْرَائِیْلَ وَمِیْکَائِیْلَ وَاِسْرَافِیْلَ، فَاطِرَ السَّمٰوٰتِ وَالْاَرْضِ، عَالِمَ الْغَیْبِ وَالشَّھَادَۃِ، اَنْتَ تَحْکُمُ بَیْنَ عِبَادِکَ فِیْمَا کَانُوْا فِیْہِ یَخْتَلِفُوْنَ، اِھْدِنِیْ لِمَا اخْتُلِفَ فِیْہِ مِنَ الْحَقِّ بِاِذْنِکَ، اِنَّکَ تَھْدِیْ مَنْ تَشَاءُ اِلٰی صِرَاطٍ مُّسْتَقِیْمٍ۔',
   'আল্লাহুম্মা রাব্বা জিবরাঈলা ওয়া মীকাঈলা ওয়া ইসরাফীল, ফাতিরাস সামাওয়াতি ওয়াল আরদ, আলিমাল গাইবি ওয়াশ শাহাদাহ, আনতা তাহকুমু বাইনা ইবাদিকা ফীমা কানূ ফীহি ইয়াখতালিফূন, ইহদিনী লিমাখতুলিফা ফীহি মিনাল হাক্কি বিইযনিক, ইন্নাকা তাহদী মান তাশাউ ইলা সিরাতিম মুসতাকীম।',
   'Аллахумма Рабба Джибраиля ва Микаиля ва Исрафиль, Фатыра-с-самавати валь-ард, ’Алима-ль-гайби ва-ш-шахада, анта тахкуму байна ’ибадика фима кяню фихи яхталифун, ихдини лима-хтулифа фихи мина-ль-хаккы би-изник, иннака тахди ман таша’у иля сыратым мустаким.',
   'مسلم 770', 'মুসলিম 770', 'Муслим 770'),
  -- 5. Istiftah #8 (reference left NULL)
  ('Subḥāna-llāhi Rabbi-l-ʿālamīn, subḥāna-llāhi wa bi-ḥamdih.',
   'سُبْحَانَ اللہِ رَبِّ الْعَالَمِیْنَ، سُبْحَانَ اللہِ وَبِحَمْدِہٖ۔',
   'সুবহানাল্লাহি রাব্বিল আলামীন, সুবহানাল্লাহি ওয়া বিহামদিহ।',
   'Субхана-Ллахи Рабби-ль-’алямин, субхана-Ллахи ва би-хамдих.',
   NULL, NULL, NULL),
  -- 6. Istiftah #9 (reference left NULL)
  ('Allāhu akbar (x10), alḥamdu li-llāh (x10), subḥāna-llāh (x10), lā ilāha illa-llāh (x10), astaghfiru-llāh (x10), allāhumma-ghfir lī wa-hdinī wa-rzuqnī wa ʿāfinī, aʿūdhu bi-llāhi min ḍīqi-l-maqāmi yawma-l-qiyāmah.',
   'اَللہُ اَکْبَرُ (10 بار)، اَلْحَمْدُ لِلہِ (10 بار)، سُبْحَانَ اللہِ (10 بار)، لَا اِلٰہَ اِلَّا اللہُ (10 بار)، اَسْتَغْفِرُ اللہَ (10 بار)، اَللّٰھُمَّ اغْفِرْ لِیْ وَاھْدِنِیْ وَارْزُقْنِیْ وَعَافِنِیْ، اَعُوْذُ بِاللہِ مِنْ ضِیْقِ الْمَقَامِ یَوْمَ الْقِیَامَۃِ۔',
   'আল্লাহু আকবার (১০ বার), আলহামদু লিল্লাহ (১০ বার), সুবহানাল্লাহ (১০ বার), লা ইলাহা ইল্লাল্লাহ (১০ বার), আসতাগফিরুল্লাহ (১০ বার), আল্লাহুম্মাগফির লী ওয়াহদিনী ওয়ারযুকনী ওয়া আফিনী, আঊযু বিল্লাহি মিন দীকিল মাকামি ইয়াওমাল কিয়ামাহ।',
   'Аллаху акбар (х10), аль-хамду ли-Ллях (х10), субхана-Ллах (х10), ля иляха илля-Ллах (х10), астагфиру-Ллах (х10), Аллахумма-гфир ли ва-хдини ва-рзукни ва ’афини, а’узу би-Лляхи мин дыкы-ль-макыми яума-ль-кыяма.',
   NULL, NULL, NULL)
) as m(tr_key, t_ur, t_bn, t_ru, r_ur, r_bn, r_ru)
where a.adhkar_subcategory_id = s.id
  and s.title_en = 'Istiftah (Opening duʿā)'
  and a.transcription_en = m.tr_key;
