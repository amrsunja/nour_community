-- =============================================================================
-- Seed: "Before sleep" subcategory (under existing "Daily routine" category)
--        + 17 adhkars.
--
-- Source: Life With Allah – Before Sleep
--   https://lifewithallah.com/dhikr-dua/main-adhkar/before-sleep/
--
-- Localization mirrors 20260611000000_seed_morning_adhkar.sql and
-- 20260612000000_seed_evening_adhkar.sql:
--   * arabic_text      – exact source text
--   * translation_*    – en (source) + fr, de, nl, tr, id, ur, bn, ms, ru
--   * transcription_*  – Latin transliteration (source); fanned out to every
--                        Latin-script language column at the end (step 4)
--   * when_/reference_ – en/fr/ar in VALUES; remaining languages localised in
--                        step 4 (no longer copied verbatim from *_en)
--
-- The "Daily routine" category is created by the morning migration; here we
-- only resolve it by title. Idempotent: subcategory inserted if missing,
-- adhkars inserted only when the subcategory has none yet.
--
-- NOTE: the source page lists "Surah al-Sajdah & al-Mulk" as item 1, but only
-- points to the two full surahs (no reproduced text / translation); it is
-- intentionally omitted here. Ayat al-Kursi, the 3 Quls, the Tasbih/Tahmid/
-- Takbir and the "4 evils" duʿa are textually identical to the morning set, so
-- their translations are reused; only the before-sleep reference/"when" differ.
--
-- REVIEW NOTE: non-English/Arabic translations of Qur'anic verses and prophetic
-- supplications, and the ur/bn/ru phonetic transcriptions, should be reviewed
-- by a qualified native speaker before production use.
-- =============================================================================

-- ── Subcategory: Before sleep ────────────────────────────────────────────────
-- Recommended window: after ʿIshāʾ -> end of day (≈ 21:00–23:59 => 1260–1439 min).
insert into public.adhkar_subcategories
  (adhkar_category_id, title_en, title_fr, title_ar, title_de, title_nl, title_tr,
   title_id, title_ur, title_bn, title_ms, title_ru,
   recommended_start_minute, recommended_end_minute, position)
select
  c.id, 'Before sleep', 'Avant de dormir', 'أذكار النوم', 'Vor dem Schlafen',
  'Voor het slapengaan', 'Uyku ezkârı', 'Zikir sebelum tidur', 'سونے کے اذکار',
  'ঘুমানোর আগের আযকার', 'Zikir sebelum tidur', 'Азкары перед сном',
  1260, 1439, 3
from public.adhkar_categories c
where c.title_en = 'Daily routine'
  and not exists (
    select 1 from public.adhkar_subcategories s
    where s.title_en = 'Before sleep' and s.adhkar_category_id = c.id
  );

-- ── Adhkars ──────────────────────────────────────────────────────────────────
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
  -- ════════════════════════ 1. Ayat al-Kursi (reused) ═══════════════════════
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
    'Before sleep', 'Avant de dormir', 'قبل النوم',
    'Bukhārī 2311', 'Bukhārī 2311', 'صحيح البخاري ٢٣١١',
    1::smallint, 10::smallint
  ),
  -- ════════════ 2. Last two ayahs of Surah al-Baqarah (2:285-286) ════════════
  (
    'أَعُوْذُ بِاللّٰهِ مِنَ الشَّيْطَانِ الرَّجِيْمِ. اٰمَنَ الرَّسُوْلُ بِمَآ أُنْزِلَ إِلَيْهِ مِنْ رَّبِّهِ وَالْمُؤْمِنُوْنَ ، كُلٌّ اٰمَنَ بِاللّٰهِ وَمَلآئِكَتِهِ وَكُتُبِهِ وَرُسُلِهِ ، لَا نُفَرِّقُ بَيْنَ أَحَدٍ مِّنْ رُّسُلِهِ ، وَقَالُوْا سَمِعْنَا وَأَطَعْنَا غُفْرَانَكَ رَبَّنَا وَإِلَيْكَ الْمَصِيْرُ. لَا يُكَلِّفُ اللّٰهُ نَفْسًا إِلَّا وُسْعَهَا ، لَهَا مَا كَسَبَتْ وَعَلَيْهَا مَا اكْتَسَبَتْ ، رَبَّنَا لَا تُؤَاخِذْنَآ إِنْ نَّسِينَآ أَوْ أَخْطَأْنَا ، رَبَّنَا وَلَا تَحْمِلْ عَلَيْنَآ إِصْرًا كَمَا حَمَلْتَهُ عَلَى الَّذِيْنَ مِنْ قَبْلِنَا ، رَبَّنَا وَلَا تُحَمِّلْنَا مَا لَا طَاقَةَ لَنَا بِهِ ، وَاعْفُ عَنَّا وَاغْفِرْ لَنَا وَارْحَمْنَا ، أَنْتَ مَوْلَانَا فَانْصُرْنَا عَلَى الْقَوْمِ الْكٰـفِرِيْنَ.',
    'Aʿūdhu bi-llāhi mina-sh-Shayṭāni-r-rajīm. Āmana-r-rasūlu bimā unzila ilayhi mi-r-rabbihī wa-l-mu''minūn, kullun āmana bi-l-llāhi wa malā''ikatihī wa kutubihī wa rusulih, lā nufarriqu bayna aḥadim-mi-r-rusulih, wa qālū samiʿnā wa aṭaʿnā ghufrānaka Rabbanā wa ilayka-l-maṣīr. Lā yukallifu-l-llāhu nafsan illā wusʿahā, lahā mā kasabat wa ʿalayhā ma-ktasabat, Rabbanā lā tuākhidhnā i-n-nasīnā aw akhṭa''nā, Rabbanā walā taḥmil ʿalaynā iṣran kamā ḥamaltahū ʿala-l-ladhīna min qablinā, Rabbanā wa lā tuḥammilnā mā lā ṭāqata lanā bih, waʿfu ʿannā wa-ghfir lanā war-ḥamnā, Anta Mawlānā fan-ṣurnā ʿala-l-qawmi-l-kāfirīn.',
    'I seek the protection of Allah from the accursed Shayṭān. The Messenger has believed in what was revealed to him from his Lord, and [so have] the believers. All of them have believed in Allah, His angels, His books and His messengers, [saying], "We make no distinction between any of His Messengers." And they say, "We hear and we obey. We seek Your forgiveness, our Lord, and to You is the final destination." Allah does not charge a soul except [with that within] its capacity. It will have [the consequence of] what [good] it has gained, and it will bear [the consequence of] what [evil] it has earned. "Our Lord, do not impose blame upon us if we have forgotten or erred. Our Lord, and lay not upon us a burden like that which You laid upon those before us. Our Lord, and burden us not with that which we have no ability to bear. And pardon us; and forgive us; and have mercy upon us. You are our protector, so give us victory over the disbelieving people." (2:285-286)',
    'Je cherche la protection d''Allah contre Satan le maudit. Le Messager a cru en ce qui lui a été révélé de la part de son Seigneur, et les croyants aussi. Tous ont cru en Allah, en Ses anges, en Ses livres et en Ses messagers ; (ils disent) : « Nous ne faisons aucune distinction entre Ses messagers. » Et ils ont dit : « Nous avons entendu et nous avons obéi. Ton pardon, notre Seigneur ! Et c''est vers Toi qu''est le retour. » Allah n''impose à aucune âme une charge supérieure à sa capacité. Elle sera récompensée du bien qu''elle aura acquis, et punie du mal qu''elle aura commis. « Notre Seigneur, ne nous châtie pas si nous oublions ou commettons une erreur. Notre Seigneur, ne nous charge pas d''un fardeau semblable à celui dont Tu as chargé ceux qui nous ont précédés. Notre Seigneur, ne nous impose pas ce que nous ne pouvons supporter. Efface nos fautes, pardonne-nous et fais-nous miséricorde. Tu es notre Maître : accorde-nous la victoire sur le peuple mécréant. » (2:285-286)',
    'Ich suche Schutz bei Allah vor dem verfluchten Satan. Der Gesandte glaubt an das, was zu ihm von seinem Herrn herabgesandt wurde, und (ebenso) die Gläubigen. Alle glauben an Allah, Seine Engel, Seine Bücher und Seine Gesandten; (sie sagen:) „Wir machen keinen Unterschied zwischen Seinen Gesandten.“ Und sie sagen: „Wir hören und gehorchen. Deine Vergebung, unser Herr! Und zu Dir ist die Heimkehr.“ Allah erlegt keiner Seele mehr auf, als sie zu leisten vermag. Ihr kommt zugute, was sie verdient hat, und ihr obliegt, was sie begangen hat. „Unser Herr, belange uns nicht, wenn wir vergessen oder einen Fehler begehen. Unser Herr, lege uns keine Bürde auf, wie Du sie denen aufgelegt hast, die vor uns waren. Unser Herr, bürde uns nichts auf, wozu wir keine Kraft haben. Verzeihe uns, vergib uns und erbarme Dich unser. Du bist unser Beschützer; so hilf uns gegen das ungläubige Volk.“ (2:285-286)',
    'Ik zoek bescherming bij Allah tegen de vervloekte Satan. De Boodschapper gelooft in wat van zijn Heer aan hem is neergezonden, en (ook) de gelovigen. Allen geloven in Allah, Zijn engelen, Zijn boeken en Zijn boodschappers; (zij zeggen:) „Wij maken geen onderscheid tussen Zijn boodschappers.“ En zij zeggen: „Wij horen en wij gehoorzamen. Uw vergeving, onze Heer! En tot U is de terugkeer.“ Allah belast geen ziel boven haar vermogen. Haar komt ten goede wat zij heeft verricht, en haar komt ten laste wat zij heeft begaan. „Onze Heer, reken het ons niet aan als wij vergeten of een fout maken. Onze Heer, leg ons geen last op zoals U die hebt opgelegd aan hen die vóór ons waren. Onze Heer, belast ons niet met wat wij niet kunnen dragen. Scheld ons kwijt, vergeef ons en wees ons genadig. U bent onze Beschermer; help ons daarom tegen het ongelovige volk.“ (2:285-286)',
    'Kovulmuş şeytandan Allah''a sığınırım. Peygamber, Rabbinden kendisine indirilene iman etti, müminler de. Hepsi Allah''a, meleklerine, kitaplarına ve peygamberlerine iman etti. (Dediler ki:) „O''nun peygamberleri arasında ayırım yapmayız.“ Ve dediler ki: „İşittik ve itaat ettik. Rabbimiz, bağışlamanı dileriz; dönüş ancak Sanadır.“ Allah hiç kimseye gücünün üstünde bir şey yüklemez. Herkesin kazandığı (iyilik) kendi lehine, işlediği (kötülük) kendi aleyhinedir. „Rabbimiz, unutur veya hata edersek bizi sorumlu tutma. Rabbimiz, bizden öncekilere yüklediğin gibi bize de ağır bir yük yükleme. Rabbimiz, gücümüzün yetmeyeceği şeyi bize taşıtma. Bizi affet, bizi bağışla ve bize merhamet et. Sen bizim Mevlâmızsın; kâfir topluluğa karşı bize yardım et.“ (2:285-286)',
    'Aku berlindung kepada Allah dari setan yang terkutuk. Rasul telah beriman kepada apa yang diturunkan kepadanya dari Tuhannya, demikian pula orang-orang yang beriman. Semuanya beriman kepada Allah, malaikat-malaikat-Nya, kitab-kitab-Nya, dan rasul-rasul-Nya. (Mereka berkata,) "Kami tidak membeda-bedakan seorang pun dari rasul-rasul-Nya." Dan mereka berkata, "Kami dengar dan kami taat. Ampunilah kami, ya Tuhan kami, dan kepada-Mu tempat kembali." Allah tidak membebani seseorang melainkan sesuai dengan kesanggupannya. Ia mendapat (pahala) dari (kebajikan) yang diusahakannya dan ia mendapat (siksa) dari (kejahatan) yang dikerjakannya. "Ya Tuhan kami, janganlah Engkau hukum kami jika kami lupa atau kami melakukan kesalahan. Ya Tuhan kami, janganlah Engkau bebankan kepada kami beban yang berat sebagaimana Engkau bebankan kepada orang-orang sebelum kami. Ya Tuhan kami, janganlah Engkau pikulkan kepada kami apa yang tidak sanggup kami memikulnya. Maafkanlah kami, ampunilah kami, dan rahmatilah kami. Engkaulah pelindung kami, maka tolonglah kami terhadap kaum yang kafir." (2:285-286)',
    'میں شیطان مردود سے اللہ کی پناہ مانگتا ہوں۔ رسول اس پر ایمان لائے جو ان کے رب کی طرف سے ان پر اتارا گیا، اور مومن بھی۔ سب اللہ پر، اس کے فرشتوں پر، اس کی کتابوں پر اور اس کے رسولوں پر ایمان لائے۔ (وہ کہتے ہیں:) ”ہم اس کے رسولوں میں سے کسی کے درمیان فرق نہیں کرتے۔“ اور انہوں نے کہا: ”ہم نے سنا اور اطاعت کی، اے ہمارے رب! تیری بخشش (چاہتے ہیں) اور تیری ہی طرف لوٹ کر جانا ہے۔“ اللہ کسی جان پر اس کی طاقت سے زیادہ بوجھ نہیں ڈالتا۔ اس کے لیے وہی ہے جو اس نے کمایا اور اسی پر وہ ہے جو اس نے کیا۔ ”اے ہمارے رب! اگر ہم بھول جائیں یا خطا کریں تو ہمیں نہ پکڑ۔ اے ہمارے رب! ہم پر ایسا بوجھ نہ ڈال جیسا تو نے ہم سے پہلے لوگوں پر ڈالا۔ اے ہمارے رب! ہم پر وہ بوجھ نہ ڈال جس کی ہم میں طاقت نہیں۔ ہمیں معاف کر، ہمیں بخش دے اور ہم پر رحم فرما۔ تو ہی ہمارا مولا ہے، پس کافر قوم کے مقابلے میں ہماری مدد فرما۔“ (2:285-286)',
    'আমি বিতাড়িত শয়তান থেকে আল্লাহর আশ্রয় চাই। রাসূল তাঁর রবের পক্ষ থেকে তাঁর প্রতি যা নাযিল হয়েছে তাতে ঈমান এনেছেন, এবং মুমিনগণও। সকলে আল্লাহ, তাঁর ফেরেশতাগণ, তাঁর কিতাবসমূহ ও তাঁর রাসূলগণের প্রতি ঈমান এনেছে। (তারা বলে,) “আমরা তাঁর রাসূলগণের মধ্যে কারও মাঝে পার্থক্য করি না।” আর তারা বলে, “আমরা শুনলাম ও মান্য করলাম। হে আমাদের রব! তোমার ক্ষমা (চাই) এবং তোমারই দিকে প্রত্যাবর্তন।” আল্লাহ কোনো ব্যক্তিকে তার সাধ্যের অতিরিক্ত দায়িত্ব দেন না। সে যা (ভালো) অর্জন করেছে তা তার জন্য, এবং যা (মন্দ) অর্জন করেছে তা তার উপর। “হে আমাদের রব! আমরা যদি ভুলে যাই বা ভুল করি তবে আমাদের পাকড়াও করো না। হে আমাদের রব! আমাদের উপর এমন বোঝা চাপিয়ো না যেমন আমাদের পূর্ববর্তীদের উপর চাপিয়েছিলে। হে আমাদের রব! আমাদের উপর এমন বোঝা চাপিয়ো না যা বহন করার শক্তি আমাদের নেই। আমাদের ক্ষমা করো, আমাদের মাফ করো এবং আমাদের প্রতি দয়া করো। তুমিই আমাদের অভিভাবক, সুতরাং কাফির সম্প্রদায়ের বিরুদ্ধে আমাদের সাহায্য করো।” (2:285-286)',
    'Aku berlindung kepada Allah daripada syaitan yang direjam. Rasul beriman kepada apa yang diturunkan kepadanya daripada Tuhannya, demikian juga orang-orang yang beriman. Semuanya beriman kepada Allah, malaikat-malaikat-Nya, kitab-kitab-Nya dan rasul-rasul-Nya. (Mereka berkata,) "Kami tidak membezakan seorang pun daripada rasul-rasul-Nya." Dan mereka berkata, "Kami dengar dan kami taat. Ampunilah kami, wahai Tuhan kami, dan kepada-Mu tempat kembali." Allah tidak membebani seseorang melainkan menurut kesanggupannya. Ia memperoleh (pahala) daripada (kebaikan) yang diusahakannya dan menanggung (dosa) daripada (kejahatan) yang dilakukannya. "Wahai Tuhan kami, janganlah Engkau hukum kami jika kami terlupa atau tersilap. Wahai Tuhan kami, janganlah Engkau bebankan kepada kami bebanan berat sebagaimana yang Engkau bebankan kepada orang-orang sebelum kami. Wahai Tuhan kami, janganlah Engkau pikulkan kepada kami apa yang kami tidak terdaya memikulnya. Maafkanlah kami, ampunilah kami dan rahmatilah kami. Engkaulah Pelindung kami, maka tolonglah kami menentang kaum yang kafir." (2:285-286)',
    'Прибегаю к Аллаху от проклятого шайтана. Посланник уверовал в то, что ниспослано ему от его Господа, и верующие (тоже). Все они уверовали в Аллаха, Его ангелов, Его Писания и Его посланников. (Они говорят:) «Мы не делаем различий между Его посланниками». И они сказали: «Слушаем и повинуемся! Прощения Твоего (просим), Господь наш, и к Тебе — возвращение». Аллах не возлагает на душу ничего, кроме того, что ей по силам. Ей достанется то (благо), что она приобрела, и против неё будет то (зло), что она совершила. «Господь наш! Не наказывай нас, если мы забыли или ошиблись. Господь наш! Не возлагай на нас бремя, которое Ты возложил на наших предшественников. Господь наш! Не обременяй нас тем, что нам не под силу. Извини нас, прости нас и помилуй нас. Ты — наш Покровитель, так помоги же нам против неверующих людей». (2:285-286)',
    'Before sleep', 'Avant de dormir', 'قبل النوم',
    'Bukhārī 4008, 807', 'Bukhārī 4008, 807', 'صحيح البخاري ٤٠٠٨، ٨٠٧',
    1::smallint, 10::smallint
  ),
  -- ════════════════════ 3. Surah al-Kafirun (109) ═══════════════════════════
  (
    'بِسْمِ اللّٰهِ الرَّحْمٰنِ الرَّحِيْمِ. قُلْ يَـٰٓأَيُّهَا الْكَافِرُوْنَ ، لَآ أَعْبُدُ مَا تَعْبُدُوْنَ ، وَلَآ أَنْتُمْ عَابِدُوْنَ مَآ أَعْبُدُ ، وَلَآ أَنَا عَابِدٌ مَّا عَبَدْتُّمْ ، وَلَآ أَنْتُمْ عَابِدُوْنَ مَآ أَعْبُدُ ، لَكُمْ دِيْنُكُمْ وَلِيَ دِيْنِ.',
    'Bismi-llāhi-r-Raḥmāni-r-Raḥīm. Qul yā ayyuha-l-kāfirūn, lā aʿbudu mā taʿbudūn, wa lā antum ʿābidūna mā aʿbud, wa lā ana ʿābidūm-mā ʿabat-tum, wa lā antum ʿābidūna mā aʿbud, lakum dīnukum waliya dīn.',
    'In the name of Allah, the All-Merciful, the Very Merciful. Say: O disbelievers, I worship not that which you worship. And nor do you worship that which I worship. And I shall not worship that which you worship. Nor will you worship that which I worship. To you be your religion, and to me my religion. (109)',
    'Au nom d''Allah, le Tout-Miséricordieux, le Très-Miséricordieux. Dis : Ô mécréants, je n''adore pas ce que vous adorez, et vous n''adorez pas ce que j''adore. Je ne suis pas adorateur de ce que vous adorez, et vous n''êtes pas adorateurs de ce que j''adore. À vous votre religion, et à moi ma religion. (109)',
    'Im Namen Allahs, des Allerbarmers, des Barmherzigen. Sprich: O ihr Ungläubigen, ich diene nicht dem, dem ihr dient, und ihr dient nicht dem, dem ich diene. Und ich werde nicht dem dienen, dem ihr gedient habt, und ihr werdet nicht dem dienen, dem ich diene. Euch eure Religion und mir meine Religion. (109)',
    'In de naam van Allah, de Erbarmer, de Meest Barmhartige. Zeg: O ongelovigen, ik aanbid niet wat jullie aanbidden, en jullie aanbidden niet wat ik aanbid. En ik zal niet aanbidden wat jullie aanbidden, en jullie zullen niet aanbidden wat ik aanbid. Voor jullie jullie godsdienst en voor mij mijn godsdienst. (109)',
    'Rahmân ve Rahîm olan Allah''ın adıyla. De ki: Ey kâfirler! Ben sizin taptıklarınıza tapmam. Siz de benim taptığıma tapmazsınız. Ben sizin taptığınıza tapacak değilim. Siz de benim taptığıma tapacak değilsiniz. Sizin dininiz size, benim dinim banadır. (109)',
    'Dengan nama Allah Yang Maha Pengasih lagi Maha Penyayang. Katakanlah: Wahai orang-orang kafir, aku tidak akan menyembah apa yang kamu sembah. Dan kamu bukan penyembah apa yang aku sembah. Dan aku tidak pernah menjadi penyembah apa yang kamu sembah. Dan kamu tidak pernah (pula) menjadi penyembah apa yang aku sembah. Untukmu agamamu, dan untukku agamaku. (109)',
    'اللہ کے نام سے جو نہایت مہربان رحم والا ہے۔ کہو: اے کافرو! میں اس کی عبادت نہیں کرتا جس کی تم عبادت کرتے ہو، اور نہ تم اس کی عبادت کرنے والے ہو جس کی میں عبادت کرتا ہوں۔ اور نہ میں اس کی عبادت کرنے والا ہوں جس کی تم نے عبادت کی، اور نہ تم اس کی عبادت کرنے والے ہو جس کی میں عبادت کرتا ہوں۔ تمہارے لیے تمہارا دین اور میرے لیے میرا دین۔ (109)',
    'পরম করুণাময় অসীম দয়ালু আল্লাহর নামে। বলো: হে কাফিরগণ! তোমরা যার ইবাদত করো আমি তার ইবাদত করি না। আর তোমরাও তার ইবাদতকারী নও যাঁর ইবাদত আমি করি। আর আমি তার ইবাদতকারী নই যার ইবাদত তোমরা করেছ, আর তোমরাও তাঁর ইবাদতকারী নও যাঁর ইবাদত আমি করি। তোমাদের জন্য তোমাদের দ্বীন, আর আমার জন্য আমার দ্বীন। (109)',
    'Dengan nama Allah Yang Maha Pemurah lagi Maha Mengasihani. Katakanlah: Wahai orang-orang kafir! Aku tidak menyembah apa yang kamu sembah, dan kamu tidak menyembah apa yang aku sembah. Dan aku tidak akan menyembah apa yang kamu sembah, dan kamu tidak akan menyembah apa yang aku sembah. Bagimu agamamu, dan bagiku agamaku. (109)',
    'С именем Аллаха, Милостивого, Милосердного. Скажи: О неверующие! Я не поклоняюсь тому, чему поклоняетесь вы, и вы не поклоняетесь Тому, Кому поклоняюсь я. И я не поклоняюсь так, как поклонялись вы, и вы не поклоняетесь Тому, Кому поклоняюсь я. У вас — ваша религия, а у меня — моя религия. (109)',
    'Before sleep', 'Avant de dormir', 'قبل النوم',
    'Tirmidhī 3403', 'Tirmidhī 3403', 'سنن الترمذي ٣٤٠٣',
    1::smallint, 10::smallint
  ),
  -- ════════════════════ 4. The Three Quls (reused) ══════════════════════════
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
    'Before sleep', 'Avant de dormir', 'قبل النوم',
    'Bukhārī 5017', 'Bukhārī 5017', 'صحيح البخاري ٥٠١٧',
    3::smallint, 10::smallint
  ),
  -- ════════════════ 5. Tasbih, Tahmid and Takbir (reused) ════════════════════
  (
    'سُبْحَانَ اللّٰهِ (×٣٣) ، اَلْحَمْدُ لِلّٰهِ (×٣٣) ، اَللّٰهُ أَكْبَرُ (×٣٤).',
    'Subḥāna-llāh (×33), Alḥamdu li-llāh (×33), Allāhu akbar (×34).',
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
    'Before sleep', 'Avant de dormir', 'قبل النوم',
    'Bukhārī 3705', 'Bukhārī 3705', 'صحيح البخاري ٣٧٠٥',
    101::smallint, 5::smallint
  ),
  -- ═══════════════════ 6. Mercy and protection (lying down) ══════════════════
  (
    'بِاسْمِكَ رَبِّيْ وَضَعْتُ جَنْبِيْ ، وَبِكَ أَرْفَعُهُ ، إِنْ أَمْسَكْتَ نَفْسِيْ فَارْحَمْهَا ، وَإِنْ أَرْسَلْتَهَا فَاحْفَظْهَا بِمَا تَحْفَظُ بِهِ عِبَادَكَ الصَّالِحِيْنَ.',
    'Bismika Rabbī waḍaʿtu jambī, wa bika arfaʿuh, in amsakta nafsī fa-r-ḥamhā, wa in arsaltahā, fa-ḥ-faẓhā bimā taḥfaẓu bihī ʿibādaka-s-sāliḥīn.',
    'In Your Name my Lord, I lie down, and in Your Name, I rise. If You take my soul away then have mercy upon it, and if You return my soul then protect it with what you protect Your righteous servants with.',
    'En Ton Nom, mon Seigneur, je me couche, et c''est par Toi que je me relève. Si Tu retiens mon âme, fais-lui miséricorde, et si Tu la renvoies, protège-la par ce avec quoi Tu protèges Tes serviteurs vertueux.',
    'In Deinem Namen, mein Herr, lege ich mich nieder, und mit Dir erhebe ich mich. Wenn Du meine Seele zurückhältst, so erbarme Dich ihrer, und wenn Du sie zurücksendest, so behüte sie mit dem, womit Du Deine rechtschaffenen Diener behütest.',
    'In Uw Naam, mijn Heer, leg ik mij neer, en met U sta ik op. Als U mijn ziel neemt, wees haar dan genadig, en als U haar terugzendt, bescherm haar dan met datgene waarmee U Uw rechtschapen dienaren beschermt.',
    'Rabbim, Senin adınla yanımı (yatağa) koydum ve Seninle onu kaldırırım. Eğer canımı alırsan ona merhamet et; eğer onu (bana) geri gönderirsen, salih kullarını koruduğun şeyle onu koru.',
    'Dengan nama-Mu, wahai Tuhanku, aku membaringkan lambungku, dan dengan-Mu aku mengangkatnya. Jika Engkau menahan jiwaku (mematikannya), maka rahmatilah ia; dan jika Engkau melepaskannya (menghidupkannya), maka jagalah ia dengan apa yang Engkau gunakan untuk menjaga hamba-hamba-Mu yang saleh.',
    'اے میرے رب! تیرے نام کے ساتھ میں نے اپنا پہلو (بستر پر) رکھا، اور تیرے ہی سہارے اسے اٹھاؤں گا۔ اگر تو میری جان روک لے تو اس پر رحم فرما، اور اگر تو اسے واپس بھیج دے تو اس کی ایسے حفاظت فرما جیسے تو اپنے نیک بندوں کی حفاظت کرتا ہے۔',
    'হে আমার রব! তোমার নামে আমি আমার পার্শ্ব (বিছানায়) রাখলাম, এবং তোমারই সাহায্যে তা উঠাব। যদি তুমি আমার প্রাণ ধরে রাখো (মৃত্যু দাও) তবে তার প্রতি দয়া করো, আর যদি তুমি তা ফিরিয়ে দাও (জীবিত রাখো) তবে তা এমনভাবে রক্ষা করো যেমন তুমি তোমার নেক বান্দাদের রক্ষা করো।',
    'Dengan nama-Mu, wahai Tuhanku, aku membaringkan rusukku, dan dengan-Mu aku mengangkatnya. Jika Engkau menahan jiwaku (mematikannya), maka rahmatilah ia; dan jika Engkau melepaskannya (menghidupkannya), maka peliharalah ia dengan apa yang Engkau gunakan untuk memelihara hamba-hamba-Mu yang soleh.',
    'С именем Твоим, Господь мой, я кладу свой бок (на постель), и с Тобой я поднимаю его. Если Ты заберёшь мою душу, то помилуй её, а если отпустишь её, то оберегай её тем, чем оберегаешь Своих праведных рабов.',
    'Before sleep', 'Avant de dormir', 'قبل النوم',
    'Bukhārī 6320', 'Bukhārī 6320', 'صحيح البخاري ٦٣٢٠',
    1::smallint, 5::smallint
  ),
  -- ═══════════════════ 7. Protection from punishment ════════════════════════
  (
    'اَللّٰهُمَّ قِنِيْ عَذَابَكَ يَوْمَ تَبْعَثُ عِبَادَكَ.',
    'Allāhumma qinī ʿadhābaka yawma tabʿathu ʿibādak.',
    'O Allah, protect me from Your punishment on the day You resurrect Your servants.',
    'Ô Allah, protège-moi de Ton châtiment le jour où Tu ressusciteras Tes serviteurs.',
    'O Allah, bewahre mich vor Deiner Strafe an dem Tag, da Du Deine Diener auferweckst.',
    'O Allah, bescherm mij tegen Uw bestraffing op de dag waarop U Uw dienaren opwekt.',
    'Allah''ım, kullarını dirilteceğin gün beni azabından koru.',
    'Ya Allah, peliharalah aku dari azab-Mu pada hari Engkau membangkitkan hamba-hamba-Mu.',
    'اے اللہ! مجھے اپنے عذاب سے بچا، اس دن جب تو اپنے بندوں کو دوبارہ اٹھائے گا۔',
    'হে আল্লাহ! যেদিন তুমি তোমার বান্দাদের পুনরুত্থিত করবে সেদিন আমাকে তোমার আযাব থেকে রক্ষা করো।',
    'Ya Allah, peliharalah aku daripada azab-Mu pada hari Engkau membangkitkan hamba-hamba-Mu.',
    'О Аллах, защити меня от Твоего наказания в день, когда Ты воскресишь Своих рабов.',
    'Before sleep', 'Avant de dormir', 'قبل النوم',
    'Abū Dāwūd 5045', 'Abū Dāwūd 5045', 'سنن أبي داود ٥٠٤٥',
    3::smallint, 5::smallint
  ),
  -- ═══════════════════ 8. Thank Allah for blessing you ══════════════════════
  (
    'اَلْحَمْدُ لِلّٰهِ الَّذِيْ أَطْعَمَنَا وَسَقَانَا ، وَكَفَانَا ، وَآوَانَا ، فَكَمْ مِّمَّنْ لَا كَافِيَ لَهُ وَلَا مُؤْوِيَ.',
    'Al-ḥamdu li-llāhi-l-ladhī aṭʿamanā wa saqānā, wa kafānā, wa āwānā, fakam-mim-man lā kāfīya lahū walā mu''wiy.',
    'All praise is for Allah, Who provided us food and drink and Who sufficed us and has sheltered us; for how many have none to suffice them or shelter them.',
    'Louange à Allah qui nous a nourris et désaltérés, qui nous a suffi et nous a donné un abri ; combien sont ceux qui n''ont personne pour leur suffire ni pour les abriter.',
    'Alles Lob gebührt Allah, der uns gespeist und getränkt, der uns genügt und uns Obdach gegeben hat; wie viele gibt es doch, die niemanden haben, der ihnen genügt oder ihnen Obdach gibt.',
    'Alle lof komt Allah toe, Die ons voedsel en drank heeft gegeven, Die ons heeft volstaan en ons onderdak heeft gegeven; hoevelen zijn er die niemand hebben die hen volstaat of onderdak biedt.',
    'Hamd, bizi yediren, içiren, bize yeten ve bizi barındıran Allah''a mahsustur. Nice kimseler vardır ki, ne kendilerine yeten biri ne de barındıran biri vardır.',
    'Segala puji bagi Allah yang telah memberi kami makan dan minum, mencukupi kami, dan memberi kami tempat berteduh; betapa banyak orang yang tidak ada yang mencukupinya dan tidak ada yang memberinya tempat berteduh.',
    'تمام تعریفیں اس اللہ کے لیے ہیں جس نے ہمیں کھلایا اور پلایا، ہمیں کافی ہوا اور ہمیں ٹھکانا دیا؛ پس کتنے ہی لوگ ہیں جن کے لیے نہ کوئی کفایت کرنے والا ہے اور نہ کوئی ٹھکانا دینے والا۔',
    'সমস্ত প্রশংসা সেই আল্লাহর জন্য যিনি আমাদের খাইয়েছেন ও পান করিয়েছেন, আমাদের জন্য যথেষ্ট হয়েছেন এবং আমাদের আশ্রয় দিয়েছেন; অথচ কত মানুষ আছে যাদের জন্য কোনো যথেষ্টকারী নেই এবং কোনো আশ্রয়দাতাও নেই।',
    'Segala puji bagi Allah yang telah memberi kami makan dan minum, mencukupkan kami, dan memberi kami tempat berteduh; betapa ramai orang yang tiada sesiapa yang mencukupkannya dan tiada yang memberinya tempat berteduh.',
    'Хвала Аллаху, Который накормил нас и напоил, Который избавил нас (от нужды) и дал нам приют; а сколько есть тех, у кого нет ни избавителя, ни дающего приют.',
    'Before sleep', 'Avant de dormir', 'قبل النوم',
    'Muslim 2715', 'Muslim 2715', 'صحيح مسلم ٢٧١٥',
    1::smallint, 5::smallint
  ),
  -- ═══════════════ 9. Protect yourself from the 4 evils (reused) ═════════════
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
    'Before sleep', 'Avant de dormir', 'قبل النوم',
    'Tirmidhī 3392, 3529; Aḥmad 82', 'Tirmidhī 3392, 3529 ; Aḥmad 82', 'سنن الترمذي ٣٣٩٢، ٣٥٢٩؛ مسند أحمد ٨٢',
    1::smallint, 5::smallint
  ),
  -- ═══════════ 10. Protection from evil and settling of debts ════════════════
  (
    'اَللّٰهُمَّ رَبَّ السَّمٰوَاتِ وَرَبَّ الأَرْضِ وَرَبَّ الْعَرْشِ الْعَظِيْمِ ، رَبَّنَا وَرَبَّ كُلِّ شَيْءٍ ، فَالِقَ الْحَبِّ وَالنَّوَىٰ ، وَمُنْزِلَ التَّوْرَاةِ وَالْإِنْجِيْلِ وَالْفُرْقَانِ ، أَعُوْذُ بِكَ مِنْ شَرِّ كُلِّ شَيْءٍ أَنْتَ آخِذٌ بِنَاصِيَتِهِ ، اَللّٰهُمَّ أَنْتَ الْأَوَّلُ فَلَيْسَ قَبْلَكَ شَيْءٌ ، وَأَنْتَ الْآخِرُ فَلَيْسَ بَعْدَكَ شَيْءٌ ، وَأَنْتَ الظَّاهِرُ فَلَيْسَ فَوْقَكَ شَيْءٌ ، وَأَنْتَ الْبَاطِنُ فَلَيْسَ دُوْنَكَ شَيْءٌ ، اِقْضِ عَنَّا الدَّيْنَ وَأَغْنِنَا مِنَ الْفَقْرِ.',
    'Allāhumma Rabb-as-samāwāti wa Rabba-l-arḍi wa Rabba-l-ʿArshi-l-ʿaẓīm, Rabbanā wa Rabba kulli shay'', fāliqa-l-ḥabbi wa-n-nawā, wa munzila-t-tawrāti wa-l-injīli wa-l-furqān, aʿūdhu bika min sharri kulli shay''in Anta ākhidhun bi-nāṣiyatih, Allāhumma Anta-l-Awwalu fa-laysa qablaka shay'', wa Anta-l-Ākhiru fa-laysa baʿdaka shay'', wa Anta-ẓ-Ẓāhiru fa-laysa fawqaka shay'', wa Anta-l-Bāṭinu fa-laysa dūnaka shay'', iqḍi ʿanna-d-dayna wa aghninā mina-l-faqr.',
    'O Allah, Lord of the heavens, Lord of the earth and Lord of the Magnificent Throne, our Lord and Lord of all things, Splitter of the seed and the date stone, Revealer of the Torah, the Injīl and the Criterion (Qur''ān); I seek Your protection from the evil of every thing You hold by the forehead. You are the First and there is nothing before You. You are the Last and there is nothing after You. You are the Most High and there is nothing above You. You are the Most Near and nothing is closer than You; settle our debts for us and spare us from poverty.',
    'Ô Allah, Seigneur des cieux, Seigneur de la terre et Seigneur du Trône immense, notre Seigneur et le Seigneur de toute chose, Toi qui fends la graine et le noyau, qui as révélé la Torah, l''Évangile et le Critère (le Coran) ; je cherche Ta protection contre le mal de toute chose que Tu tiens par le toupet. Tu es le Premier, rien n''existe avant Toi ; Tu es le Dernier, rien n''existe après Toi ; Tu es l''Apparent, rien n''est au-dessus de Toi ; Tu es le Caché, rien n''est plus proche que Toi. Acquitte pour nous nos dettes et préserve-nous de la pauvreté.',
    'O Allah, Herr der Himmel, Herr der Erde und Herr des gewaltigen Thrones, unser Herr und Herr aller Dinge, Spalter des Korns und des Dattelkerns, Offenbarer der Tora, des Evangeliums und der Unterscheidung (des Qur''an); ich suche Schutz bei Dir vor dem Übel jeder Sache, die Du am Schopf hältst. Du bist der Erste, vor Dir ist nichts; Du bist der Letzte, nach Dir ist nichts; Du bist der Offenbare, über Dir ist nichts; Du bist der Verborgene, näher als Du ist nichts. Begleiche für uns unsere Schulden und bewahre uns vor Armut.',
    'O Allah, Heer van de hemelen, Heer van de aarde en Heer van de geweldige Troon, onze Heer en Heer van alle dingen, Splijter van de korrel en de dadelpit, Neerzender van de Thora, het Evangelie en de Furqān (de Koran); ik zoek bescherming bij U tegen het kwaad van alles wat U bij de voorlok houdt. U bent de Eerste, er is niets vóór U; U bent de Laatste, er is niets na U; U bent de Zichtbare, er is niets boven U; U bent de Verborgene, niets is dichterbij dan U. Vereffen onze schulden voor ons en behoed ons voor armoede.',
    'Allah''ım! Göklerin Rabbi, yerin Rabbi ve büyük Arşın Rabbi; Rabbimiz ve her şeyin Rabbi; taneyi ve çekirdeği yaran; Tevrat''ı, İncil''i ve Furkan''ı (Kur''an''ı) indiren! Perçeminden tuttuğun her şeyin şerrinden Sana sığınırım. Sen Evvel''sin, Senden önce hiçbir şey yoktur; Sen Âhir''sin, Senden sonra hiçbir şey yoktur; Sen Zâhir''sin, Senin üstünde hiçbir şey yoktur; Sen Bâtın''sın, Senden daha yakın hiçbir şey yoktur. Borcumuzu öde ve bizi fakirlikten kurtar.',
    'Ya Allah, Tuhan langit, Tuhan bumi, dan Tuhan ''Arasy yang agung; Tuhan kami dan Tuhan segala sesuatu; Yang membelah biji dan benih; Yang menurunkan Taurat, Injil, dan al-Furqan (Al-Qur''an); aku berlindung kepada-Mu dari kejahatan segala sesuatu yang ubun-ubunnya berada dalam genggaman-Mu. Ya Allah, Engkau Yang Awal, tidak ada sesuatu pun sebelum-Mu; Engkau Yang Akhir, tidak ada sesuatu pun setelah-Mu; Engkau Yang Zahir, tidak ada sesuatu pun di atas-Mu; Engkau Yang Batin, tidak ada sesuatu pun yang lebih dekat daripada-Mu. Lunasilah utang kami dan cukupkanlah kami dari kefakiran.',
    'اے اللہ! آسمانوں کے رب، زمین کے رب اور عرشِ عظیم کے رب! ہمارے رب اور ہر چیز کے رب! دانے اور گٹھلی کو پھاڑنے والے! تورات، انجیل اور فرقان (قرآن) کو اتارنے والے! میں ہر اس چیز کے شر سے تیری پناہ مانگتا ہوں جس کی پیشانی تیرے قبضے میں ہے۔ اے اللہ! تو ہی اول ہے، تجھ سے پہلے کچھ نہیں؛ تو ہی آخر ہے، تیرے بعد کچھ نہیں؛ تو ہی ظاہر ہے، تیرے اوپر کچھ نہیں؛ تو ہی باطن ہے، تجھ سے زیادہ قریب کچھ نہیں۔ ہمارا قرض ادا فرما اور ہمیں محتاجی سے بے نیاز کر دے۔',
    'হে আল্লাহ! আসমানসমূহের রব, জমিনের রব ও মহান আরশের রব! আমাদের রব ও প্রতিটি বস্তুর রব! শস্যবীজ ও আঁটি বিদীর্ণকারী! তাওরাত, ইনজীল ও ফুরকান (কুরআন) অবতীর্ণকারী! আমি প্রতিটি বস্তুর অনিষ্ট থেকে তোমার আশ্রয় চাই যার ললাট তোমার হাতে। হে আল্লাহ! তুমিই প্রথম, তোমার আগে কিছু নেই; তুমিই শেষ, তোমার পরে কিছু নেই; তুমিই প্রকাশ্য, তোমার উপরে কিছু নেই; তুমিই অপ্রকাশ্য, তোমার চেয়ে নিকটবর্তী কিছু নেই। আমাদের ঋণ পরিশোধ করে দাও এবং আমাদের দারিদ্র্য থেকে অভাবমুক্ত করো।',
    'Ya Allah, Tuhan langit, Tuhan bumi dan Tuhan ''Arasy yang agung; Tuhan kami dan Tuhan segala sesuatu; Yang membelah biji benih dan biji buah; Yang menurunkan Taurat, Injil dan al-Furqan (Al-Qur''an); aku berlindung kepada-Mu daripada kejahatan segala sesuatu yang ubun-ubunnya dalam genggaman-Mu. Ya Allah, Engkau Yang Awal, tiada sesuatu pun sebelum-Mu; Engkau Yang Akhir, tiada sesuatu pun selepas-Mu; Engkau Yang Zahir, tiada sesuatu pun di atas-Mu; Engkau Yang Batin, tiada sesuatu pun yang lebih hampir daripada-Mu. Selesaikanlah hutang kami dan cukupkanlah kami daripada kefakiran.',
    'О Аллах, Господь небес, Господь земли и Господь великого Престола! Господь наш и Господь всякой вещи! Раскалывающий зерно и косточку! Ниспославший Тору, Евангелие и Различение (Коран)! Прибегаю к Тебе от зла всякой вещи, которую Ты держишь за хохол. О Аллах, Ты — Первый, и нет ничего до Тебя; Ты — Последний, и нет ничего после Тебя; Ты — Явный, и нет ничего над Тобой; Ты — Сокровенный, и нет ничего ближе Тебя. Погаси за нас наш долг и избавь нас от бедности.',
    'Before sleep', 'Avant de dormir', 'قبل النوم',
    'Muslim 2713', 'Muslim 2713', 'صحيح مسلم ٢٧١٣',
    1::smallint, 5::smallint
  ),
  -- ═══════════════════ 11. Ask Allah to protect you from evil ════════════════
  (
    'اَللّٰهُمَّ إِنِّيْ أَعُوْذُ بِوَجْهِكَ الْكَرِيْمِ ، وَكَلِمَاتِكَ التَّامَّةِ مِنْ شَرِّ مَا أَنْتَ آخِذٌ بِنَاصِيَتِهِ ، اَللّٰهُمَّ أَنْتَ تَكْشِفُ الْمَغْرَمَ وَالْمَأْثَمَ ، اَللّٰهُمَّ لَا يُهْزَمُ جُنْدُكَ ، وَلَا يُخْلَفُ وَعْدُكَ ، وَلَا يَنْفَعُ ذَا الْجَدِّ مِنْكَ الْجَدُّ ، سُبْحَانَكَ وَبِحَمْدِكَ.',
    'Allāhumma innī aʿūdhu bi wajhika-l-karīm, wa kalimātika-t-tāmmati min sharri mā Anta ākhidhun bi nāṣiyatih, Allāhumma Anta takshifu-l-maghrama wa-l-ma''tham, Allāhumma lā yuhzamu junduk, wa lā yukhlafu waʿduk, wa lā yanfaʿu dha-l-jaddi minka-l-jadd, subḥānaka wa bi-ḥamdik.',
    'O Allah, I seek protection by Your Noble Countenance and by Your perfect words from the evil of all that You hold by the forehead. O Allah, it is You who removes debt and sin. O Allah, Your army is never defeated and Your promise is never broken. The wealth of the wealthy does not avail them against You. You are free from imperfection, and to You belongs all praise.',
    'Ô Allah, je cherche protection par Ta Noble Face et par Tes paroles parfaites contre le mal de tout ce que Tu tiens par le toupet. Ô Allah, c''est Toi qui ôtes la dette et le péché. Ô Allah, Ton armée n''est jamais vaincue et Ta promesse n''est jamais rompue. La fortune du fortuné ne lui sert à rien contre Toi. Gloire et pureté à Toi, et à Toi la louange.',
    'O Allah, ich suche Schutz bei Deinem edlen Angesicht und bei Deinen vollkommenen Worten vor dem Übel all dessen, was Du am Schopf hältst. O Allah, Du bist es, der Schuld und Sünde hinwegnimmt. O Allah, Dein Heer wird nie besiegt und Dein Versprechen wird nie gebrochen. Der Reichtum des Reichen nützt ihm nichts gegen Dich. Gepriesen seist Du, und Dir gebührt alles Lob.',
    'O Allah, ik zoek bescherming bij Uw Edele Aangezicht en bij Uw volmaakte woorden tegen het kwaad van alles wat U bij de voorlok houdt. O Allah, U bent het die schuld en zonde wegneemt. O Allah, Uw leger wordt nooit verslagen en Uw belofte wordt nooit gebroken. De rijkdom van de rijke baat hem niets tegen U. Glorie aan U, en U komt alle lof toe.',
    'Allah''ım! Perçeminden tuttuğun her şeyin şerrinden, Senin kerim zatına (vechine) ve eksiksiz kelimelerine sığınırım. Allah''ım! Borcu ve günahı kaldıran Sensin. Allah''ım! Senin ordun yenilmez, vaadin bozulmaz; servet sahibinin serveti Sana karşı kendisine fayda vermez. Seni tenzih ederim ve hamd Sanadır.',
    'Ya Allah, aku berlindung dengan wajah-Mu yang mulia dan dengan kalimat-kalimat-Mu yang sempurna dari kejahatan segala sesuatu yang ubun-ubunnya Engkau genggam. Ya Allah, Engkaulah yang menghapus utang dan dosa. Ya Allah, tentara-Mu tidak terkalahkan, dan janji-Mu tidak dilanggar; kekayaan orang kaya tidak berguna baginya di hadapan-Mu. Maha Suci Engkau dan dengan memuji-Mu.',
    'اے اللہ! میں تیری بزرگ ذات (چہرے) اور تیرے کامل کلمات کے ساتھ ہر اس چیز کے شر سے پناہ مانگتا ہوں جس کی پیشانی تیرے قبضے میں ہے۔ اے اللہ! تو ہی قرض اور گناہ کو دور کرنے والا ہے۔ اے اللہ! تیرا لشکر شکست نہیں کھاتا، تیرا وعدہ خلاف نہیں ہوتا، اور دولت والے کو اس کی دولت تیرے مقابلے میں کوئی نفع نہیں دیتی۔ تو پاک ہے اور تیری ہی حمد کے ساتھ۔',
    'হে আল্লাহ! আমি তোমার সম্মানিত সত্তা (চেহারা) ও তোমার পরিপূর্ণ কালিমাসমূহের অসিলায় প্রতিটি বস্তুর অনিষ্ট থেকে আশ্রয় চাই যার ললাট তোমার হাতে। হে আল্লাহ! তুমিই ঋণ ও পাপ দূরকারী। হে আল্লাহ! তোমার বাহিনী পরাজিত হয় না, তোমার অঙ্গীকার ভঙ্গ হয় না, এবং সম্পদশালীর সম্পদ তোমার মোকাবিলায় তার কোনো উপকারে আসে না। তুমি পবিত্র এবং তোমারই প্রশংসা সহকারে।',
    'Ya Allah, aku berlindung dengan wajah-Mu yang mulia dan dengan kalimah-kalimah-Mu yang sempurna daripada kejahatan segala sesuatu yang ubun-ubunnya dalam genggaman-Mu. Ya Allah, Engkaulah yang menghapuskan hutang dan dosa. Ya Allah, tentera-Mu tidak terkalahkan, dan janji-Mu tidak dimungkiri; kekayaan orang kaya tidak memberi manfaat kepadanya di hadapan-Mu. Maha Suci Engkau dan dengan memuji-Mu.',
    'О Аллах, прибегаю к Твоему благородному Лику и к Твоим совершенным словам от зла всего, что Ты держишь за хохол. О Аллах, Ты — Тот, Кто избавляет от долга и греха. О Аллах, Твоё войско непобедимо, Твоё обещание нерушимо, и богатство богатого не спасёт его от Тебя. Пречист Ты, и Тебе хвала.',
    'Before sleep', 'Avant de dormir', 'قبل النوم',
    'Abū Dāwūd 5052', 'Abū Dāwūd 5052', 'سنن أبي داود ٥٠٥٢',
    1::smallint, 5::smallint
  ),
  -- ═══════════════ 12. Protection, well-being and forgiveness ════════════════
  (
    'اَللّٰهُمَّ إِنَّكَ خَلَقْتَ نَفْسِيْ وَأَنْتَ تَوَفَّاهَا ، لَكَ مَمَاتُهَا وَمَحْيَاهَا ، إِنْ أَحْيَيْتَهَا فَاحْفَظْهَا ، وَإِنْ أَمَتَّهَا فَاغْفِرْ لَهَا ، اَللّٰهُمَّ إِنِّيْ أَسْأَلُكَ الْعَافِيَةَ.',
    'Allāhumma innaka khalaqta nafsī wa Anta tawaffāhā, laka mamātuhā wa maḥyāhā, in aḥyaytahā fa-ḥfaẓhā, wa in amattahā fa-ghfir lahā, Allāhumma innī as''aluka-l-ʿāfiyah.',
    'O Allah, verily You have created my soul and You shall take its life. To You Alone belongs its life and death. If You keep my soul alive then protect it, and if You take it away, then forgive it. O Allah, I ask You to grant me well-being.',
    'Ô Allah, c''est Toi qui as créé mon âme et c''est Toi qui la reprendras. À Toi appartiennent sa mort et sa vie. Si Tu la maintiens en vie, protège-la, et si Tu la fais mourir, pardonne-lui. Ô Allah, je Te demande le bien-être.',
    'O Allah, wahrlich, Du hast meine Seele erschaffen, und Du wirst sie abberufen. Dein sind ihr Tod und ihr Leben. Wenn Du sie am Leben erhältst, so behüte sie, und wenn Du sie sterben lässt, so vergib ihr. O Allah, ich bitte Dich um Wohlergehen.',
    'O Allah, voorwaar, U hebt mijn ziel geschapen en U zult haar wegnemen. Aan U behoren haar dood en haar leven. Als U haar in leven houdt, bescherm haar dan, en als U haar laat sterven, vergeef haar dan. O Allah, ik vraag U om welzijn.',
    'Allah''ım! Şüphesiz benim nefsimi Sen yarattın ve onu Sen vefat ettireceksin. Onun ölümü de hayatı da Sana aittir. Eğer onu yaşatırsan onu koru, eğer öldürürsen ona mağfiret et. Allah''ım! Senden afiyet (esenlik) dilerim.',
    'Ya Allah, sesungguhnya Engkau telah menciptakan jiwaku dan Engkau pula yang mewafatkannya. Milik-Mu kematian dan kehidupannya. Jika Engkau menghidupkannya, maka jagalah ia; dan jika Engkau mematikannya, maka ampunilah ia. Ya Allah, aku memohon kepada-Mu keselamatan (afiat).',
    'اے اللہ! بے شک تو نے میری جان پیدا کی اور تو ہی اسے وفات دے گا۔ اسی کی موت اور اسی کی زندگی تیرے ہی لیے ہے۔ اگر تو اسے زندہ رکھے تو اس کی حفاظت فرما، اور اگر تو اسے موت دے تو اسے بخش دے۔ اے اللہ! میں تجھ سے عافیت کا سوال کرتا ہوں۔',
    'হে আল্লাহ! নিশ্চয়ই তুমি আমার প্রাণ সৃষ্টি করেছ এবং তুমিই তার মৃত্যু ঘটাবে। তার মৃত্যু ও জীবন তোমারই। যদি তুমি তা জীবিত রাখো তবে তা রক্ষা করো, আর যদি তা মৃত্যু দাও তবে তা ক্ষমা করো। হে আল্লাহ! আমি তোমার কাছে নিরাপত্তা (আফিয়াত) চাই।',
    'Ya Allah, sesungguhnya Engkau telah menciptakan jiwaku dan Engkau jualah yang mematikannya. Milik-Mu kematian dan kehidupannya. Jika Engkau menghidupkannya, maka peliharalah ia; dan jika Engkau mematikannya, maka ampunkanlah ia. Ya Allah, aku memohon kepada-Mu keselamatan (afiat).',
    'О Аллах, поистине Ты создал мою душу, и Ты упокоишь её. Тебе принадлежат её смерть и её жизнь. Если Ты оставишь её живой, то оберегай её, а если умертвишь её, то прости ей. О Аллах, прошу у Тебя благополучия (’афия).',
    'Before sleep', 'Avant de dormir', 'قبل النوم',
    'Aḥmad 5502', 'Aḥmad 5502', 'مسند أحمد ٥٥٠٢',
    1::smallint, 5::smallint
  ),
  -- ═══════════════════ 13. Forgiveness and protection ═══════════════════════
  (
    'بِسْمِ اللّٰهِ وَضَعْتُ جَنْبِيْ ، اَللّٰهُمَّ اغْفِرْ لِيْ ذَنْبِيْ ، وَأَخْسِئْ شَيْطَانِيْ ، وَفُكَّ رِهَانِيْ ، وَاجْعَلْنِيْ فِي النَّدِيِّ الْأَعْلَىٰ.',
    'Bismillāhi waḍaʿtu jambī, Allāhumma-ghfir lī dhambī, wa akhsi'' shayṭānī, wa fukka rihānī, wa-jʿalnī fi-n-Nadiyyi-l-Aʿlā.',
    'In the Name of Allah, I lie down. O Allah, forgive my sins, ward off from me my shaytān, free me from my obligations (to others) and enter me into the loftiest assembly (of angels).',
    'Au nom d''Allah, je me couche. Ô Allah, pardonne-moi mes péchés, repousse loin de moi mon diable, libère-moi de mes obligations (envers autrui) et place-moi dans l''assemblée la plus élevée (des anges).',
    'Im Namen Allahs lege ich mich nieder. O Allah, vergib mir meine Sünden, treibe meinen Satan von mir fort, befreie mich von meinen Verpflichtungen (gegenüber anderen) und nimm mich in die höchste Versammlung (der Engel) auf.',
    'In de Naam van Allah leg ik mij neer. O Allah, vergeef mij mijn zonden, verdrijf mijn shaytān van mij, bevrijd mij van mijn verplichtingen (jegens anderen) en plaats mij in de hoogste vergadering (van de engelen).',
    'Allah''ın adıyla yanımı (yatağa) koydum. Allah''ım! Günahımı bağışla, şeytanımı benden uzaklaştır, (başkalarına olan) borcumu/yükümü çöz ve beni en yüce topluluğa (meleklerin arasına) kat.',
    'Dengan nama Allah aku membaringkan tubuhku. Ya Allah, ampunilah dosaku, usirlah setanku, bebaskanlah aku dari tanggunganku (kepada orang lain), dan jadikanlah aku berada di perkumpulan yang tertinggi (para malaikat).',
    'اللہ کے نام سے میں نے اپنا پہلو (بستر پر) رکھا۔ اے اللہ! میرا گناہ بخش دے، میرے شیطان کو مجھ سے دور کر دے، میرا بوجھ (دوسروں کے حقوق) ہلکا کر دے، اور مجھے سب سے بلند مجلس (فرشتوں) میں شامل فرما۔',
    'আল্লাহর নামে আমি আমার পার্শ্ব (বিছানায়) রাখলাম। হে আল্লাহ! আমার গুনাহ ক্ষমা করো, আমার শয়তানকে আমার থেকে দূর করো, আমার দায় (অন্যের হক) থেকে মুক্ত করো এবং আমাকে সর্বোচ্চ মজলিসে (ফেরেশতাদের মাঝে) স্থান দাও।',
    'Dengan nama Allah aku membaringkan rusukku. Ya Allah, ampunkanlah dosaku, usirlah syaitanku, bebaskanlah aku daripada tanggunganku (kepada orang lain), dan jadikanlah aku berada dalam perhimpunan yang tertinggi (para malaikat).',
    'С именем Аллаха я кладу свой бок (на постель). О Аллах, прости мне мой грех, прогони от меня моего шайтана, освободи меня от моих обязательств (перед другими) и введи меня в высочайшее собрание (ангелов).',
    'Before sleep', 'Avant de dormir', 'قبل النوم',
    'Abū Dāwūd 5054', 'Abū Dāwūd 5054', 'سنن أبي داود ٥٠٥٤',
    1::smallint, 5::smallint
  ),
  -- ════════ 14. Praise Allah with the praises of the entire creation ═════════
  (
    'اَلْحَمْدُ لِلّٰهِ الَّذِيْ كَفَانِيْ وَآوَانِيْ ، اَلْحَمْدُ لِلّٰهِ الَّذِيْ أَطْعَمَنِيْ وَسَقَانِيْ ، اَلْحَمْدُ لِلّٰهِ الَّذِيْ مَنَّ عَلَيَّ فَأَفْضَلَ ، اَللّٰهُمَّ إِنِّيْ أَسْأَلُكَ بِعِزَّتِكَ أَنْ تُنَجِّيَنِيْ مِنَ النَّارِ.',
    'Al-ḥamdu li-llāhi-lladhī kafānī wa āwānī, al-ḥamdu li-llāhi-lladhī aṭʿamanī wa saqānī, al-ḥamdu li-llāhi-l-ladhī manna ʿalayya fa-afḍal, Allāhumma innī as''aluka bi ʿizzatika an tunajjiyanī min-an-nār.',
    'All praise is for Allah Who has sufficed me and given me refuge. All praise is for Allah Who has fed me and given me drink. All praise is for Allah Who has been gracious to me and showered favours on me. O Allah, I ask You by Your Glory, save me from the Hell-Fire.',
    'Louange à Allah qui m''a suffi et m''a donné refuge. Louange à Allah qui m''a nourri et désaltéré. Louange à Allah qui m''a comblé de Sa grâce et de Ses faveurs. Ô Allah, je Te demande par Ta Gloire de me sauver du Feu.',
    'Alles Lob gebührt Allah, der mir genügt und mir Zuflucht gewährt hat. Alles Lob gebührt Allah, der mich gespeist und getränkt hat. Alles Lob gebührt Allah, der mir Gnade erwiesen und mich überreich beschenkt hat. O Allah, ich bitte Dich bei Deiner Erhabenheit, errette mich vor dem Höllenfeuer.',
    'Alle lof komt Allah toe, Die mij heeft volstaan en mij toevlucht heeft gegeven. Alle lof komt Allah toe, Die mij heeft gevoed en te drinken heeft gegeven. Alle lof komt Allah toe, Die mij gunsten heeft bewezen en mij overvloedig heeft begiftigd. O Allah, ik vraag U bij Uw Glorie: red mij van het Hellevuur.',
    'Hamd, bana yeten ve beni barındıran Allah''a mahsustur. Hamd, beni yediren ve içiren Allah''a mahsustur. Hamd, bana lütufta bulunup ihsanını bol bol veren Allah''a mahsustur. Allah''ım! İzzetin hakkı için Senden beni cehennem ateşinden kurtarmanı dilerim.',
    'Segala puji bagi Allah yang telah mencukupiku dan memberiku tempat berteduh. Segala puji bagi Allah yang telah memberiku makan dan minum. Segala puji bagi Allah yang telah berbuat baik kepadaku dan melimpahkan karunia kepadaku. Ya Allah, aku memohon kepada-Mu dengan keagungan-Mu, selamatkanlah aku dari api neraka.',
    'تمام تعریفیں اس اللہ کے لیے ہیں جس نے مجھے کافی ہوا اور مجھے ٹھکانا دیا۔ تمام تعریفیں اس اللہ کے لیے ہیں جس نے مجھے کھلایا اور پلایا۔ تمام تعریفیں اس اللہ کے لیے ہیں جس نے مجھ پر احسان فرمایا اور خوب نوازا۔ اے اللہ! میں تیری عزت کے واسطے سے سوال کرتا ہوں کہ مجھے آگ سے نجات دے۔',
    'সমস্ত প্রশংসা সেই আল্লাহর জন্য যিনি আমার জন্য যথেষ্ট হয়েছেন এবং আমাকে আশ্রয় দিয়েছেন। সমস্ত প্রশংসা সেই আল্লাহর জন্য যিনি আমাকে খাইয়েছেন ও পান করিয়েছেন। সমস্ত প্রশংসা সেই আল্লাহর জন্য যিনি আমার উপর অনুগ্রহ করেছেন ও প্রচুর দান করেছেন। হে আল্লাহ! আমি তোমার ইজ্জতের অসিলায় তোমার কাছে চাই যেন তুমি আমাকে জাহান্নাম থেকে মুক্তি দাও।',
    'Segala puji bagi Allah yang telah mencukupkanku dan memberiku tempat berteduh. Segala puji bagi Allah yang telah memberiku makan dan minum. Segala puji bagi Allah yang telah berbuat baik kepadaku dan melimpahkan kurnia kepadaku. Ya Allah, aku memohon kepada-Mu dengan keagungan-Mu, selamatkanlah aku daripada api neraka.',
    'Хвала Аллаху, Который избавил меня (от нужды) и дал мне приют. Хвала Аллаху, Который накормил меня и напоил. Хвала Аллаху, Который оказал мне милость и щедро одарил меня. О Аллах, прошу Тебя ради Твоего величия — спаси меня от Огня.',
    'Before sleep', 'Avant de dormir', 'قبل النوم',
    'Ḥākim 2001', 'Ḥākim 2001', 'المستدرك للحاكم ٢٠٠١',
    1::smallint, 5::smallint
  ),
  -- ═══════════════════ 15. Sleep in the name of your Lord ════════════════════
  (
    'اَللّٰهُمَّ بِاسْمِكَ أَمُوْتُ وَأَحْيَا.',
    'Allāhumma bismika amūtu wa aḥyā.',
    'O Allah, solely in Your Name I die and I live.',
    'Ô Allah, c''est en Ton Nom que je meurs et que je vis.',
    'O Allah, in Deinem Namen sterbe ich und lebe ich.',
    'O Allah, in Uw Naam sterf ik en leef ik.',
    'Allah''ım! Senin adınla ölür ve Senin adınla dirilirim (yaşarım).',
    'Ya Allah, dengan nama-Mu aku mati dan aku hidup.',
    'اے اللہ! تیرے ہی نام کے ساتھ میں مرتا ہوں اور جیتا ہوں۔',
    'হে আল্লাহ! তোমার নামেই আমি মরি এবং বাঁচি।',
    'Ya Allah, dengan nama-Mu aku mati dan aku hidup.',
    'О Аллах, с именем Твоим я умираю и оживаю (живу).',
    'Before sleep', 'Avant de dormir', 'قبل النوم',
    'Bukhārī 6325', 'Bukhārī 6325', 'صحيح البخاري ٦٣٢٥',
    1::smallint, 5::smallint
  ),
  -- ═══════════════════ 16. Get forgiven before going to sleep ════════════════
  (
    'لَا إِلٰهَ إِلَّا اللّٰهُ وَحْدَهُ لَا شَرِيْكَ لَهُ ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ ، وَهُوَ عَلَىٰ كُلِّ شَيْءٍ قَدِيْرٌ ، وَلَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللّٰهِ ، سُبْحَانَ اللّٰهِ وَالْحَمْدُ لِلّٰهِ وَلَا إِلٰهَ إِلَّا اللّٰهُ وَاللّٰهُ أَكْبَرُ.',
    'Lā ilāha illā-l-lāhu waḥdahu lā sharīka lah, lahu-l-mulku wa lahu-l-ḥamd, wa Huwa ʿalā kulli shay''in qadīr, wa lā ḥawla wa lā quwwata illā billāh, subḥāna-llāhi wa-l-ḥamdu lillāhi wa lā ilāha illā Allāhu wa-llāhu akbar.',
    'There is no god but Allah. He is Alone and He has no partner whatsoever. To Him Alone belong all sovereignty and all praise. He is over all things All-Powerful. There is no power (in averting evil) or strength (in attaining good) except through Allah. Allah is free from imperfection, and all praise is for Allah. There is no god but Allah and Allah is the Greatest.',
    'Il n''y a de dieu qu''Allah, Seul, sans aucun associé. À Lui la royauté et à Lui la louange, et Il est Omnipotent. Il n''y a de force ni de puissance qu''en Allah. Gloire à Allah, louange à Allah, il n''y a de dieu qu''Allah, et Allah est le plus Grand.',
    'Es gibt keinen Gott außer Allah, Er allein, ohne jeglichen Teilhaber. Sein ist die Herrschaft und Sein ist das Lob, und Er hat Macht über alle Dinge. Es gibt keine Macht und keine Kraft außer durch Allah. Gepriesen sei Allah, alles Lob gebührt Allah, es gibt keinen Gott außer Allah, und Allah ist der Größte.',
    'Er is geen god dan Allah, Hij alleen, zonder enige deelgenoot. Aan Hem behoort alle heerschappij en alle lof, en Hij is tot alle dingen in staat. Er is geen macht en geen kracht behalve door Allah. Glorie aan Allah, alle lof komt Allah toe, er is geen god dan Allah, en Allah is de Grootste.',
    'Allah''tan başka ilah yoktur, O tektir, hiçbir ortağı yoktur. Mülk O''nundur, hamd O''nundur ve O her şeye kadirdir. Güç ve kuvvet ancak Allah iledir. Allah''ı tenzih ederim, hamd Allah''a mahsustur, Allah''tan başka ilah yoktur ve Allah en büyüktür.',
    'Tidak ada tuhan selain Allah semata, tiada sekutu bagi-Nya. Milik-Nya kerajaan dan bagi-Nya segala puji, dan Dia Maha Kuasa atas segala sesuatu. Tidak ada daya dan kekuatan kecuali dengan (pertolongan) Allah. Maha Suci Allah, segala puji bagi Allah, tidak ada tuhan selain Allah, dan Allah Maha Besar.',
    'اللہ کے سوا کوئی معبود نہیں، وہ اکیلا ہے، اس کا کوئی شریک نہیں۔ اسی کی بادشاہی ہے اور اسی کی تعریف ہے، اور وہ ہر چیز پر قادر ہے۔ اور کوئی طاقت اور قوت نہیں مگر اللہ کی توفیق سے۔ اللہ پاک ہے، اور تمام تعریفیں اللہ کے لیے ہیں، اور اللہ کے سوا کوئی معبود نہیں، اور اللہ سب سے بڑا ہے۔',
    'আল্লাহ ছাড়া কোনো উপাস্য নেই, তিনি একক, তাঁর কোনো শরিক নেই। রাজত্ব তাঁরই এবং প্রশংসা তাঁরই, আর তিনি সর্ববিষয়ে ক্ষমতাবান। আল্লাহর সাহায্য ছাড়া কোনো শক্তি ও সামর্থ্য নেই। আল্লাহ পবিত্র, সমস্ত প্রশংসা আল্লাহর, আল্লাহ ছাড়া কোনো উপাস্য নেই, এবং আল্লাহ সর্বশ্রেষ্ঠ।',
    'Tiada tuhan selain Allah semata, tiada sekutu bagi-Nya. Milik-Nya kerajaan dan bagi-Nya segala pujian, dan Dia Maha Kuasa atas segala sesuatu. Tiada daya dan kekuatan melainkan dengan (pertolongan) Allah. Maha Suci Allah, segala puji bagi Allah, tiada tuhan selain Allah, dan Allah Maha Besar.',
    'Нет божества, кроме Аллаха одного, нет у Него сотоварища. Ему принадлежит власть и Ему хвала, и Он над всякой вещью властен. Нет мощи и силы ни у кого, кроме Аллаха. Пречист Аллах, хвала Аллаху, нет божества, кроме Аллаха, и Аллах велик.',
    'Before sleep', 'Avant de dormir', 'قبل النوم',
    'Nasā''ī', 'Nasā''ī', 'النسائي',
    1::smallint, 5::smallint
  ),
  -- ═══════════════════ 17. Die upon the Fitrah ══════════════════════════════
  (
    'اَللّٰهُمَّ أَسْلَمْتُ نَفْسِيْ إِلَيْكَ ، وَفَوَّضْتُ أَمْرِيْ إِلَيْكَ ، وَوَجَّهْتُ وَجْهِيْ إِلَيْكَ ، وَأَلْجَاْتُ ظَهْرِيْ إِلَيْكَ ، رَغْبَةً وَرَهْبَةً إِلَيْكَ ، لَا مَلْجَأَ وَلَا مَنْجَا مِنْكَ إِلَّا إِلَيْكَ ، آمَنْتُ بِكِتَابِكَ الَّذِيْ أَنْزَلْتَ وَبِنَبِيِّكَ الَّذِيْ أَرْسَلْتَ.',
    'Allāhumma aslamtu nafsī ilayk, wa fawwaḍtu amrī ilayk, wa wajjahtu wajhī ilayk, wa alja''tu ẓahrī ilayk, raghbatan wa rahbatan ilayk, lā malja''a wa lā manjā minka illā ilayk, āmantu bi kitābika-l-ladhī anzalt, wa bi Nabiyyika-lladhī arsalt.',
    'O Allah, I submit my soul unto You, and I entrust my affair unto You, and I turn my face towards You, and I totally rely on You, in hope and fear of You. Verily there is no refuge or safe haven from You except with You. I believe in Your Book which You have revealed and in Your Prophet whom You have sent.',
    'Ô Allah, je soumets mon âme à Toi, je Te confie mon affaire, je tourne mon visage vers Toi et j''adosse mon dos à Toi, par désir et par crainte de Toi. Il n''y a de refuge ni de salut contre Toi qu''auprès de Toi. Je crois en Ton Livre que Tu as révélé et en Ton Prophète que Tu as envoyé.',
    'O Allah, ich ergebe meine Seele Dir, und ich vertraue meine Angelegenheit Dir an, und ich wende mein Angesicht Dir zu, und ich stütze meinen Rücken auf Dich, aus Verlangen nach Dir und aus Furcht vor Dir. Es gibt keine Zuflucht und keine Rettung vor Dir außer bei Dir. Ich glaube an Dein Buch, das Du herabgesandt hast, und an Deinen Propheten, den Du entsandt hast.',
    'O Allah, ik geef mijn ziel aan U over, en ik vertrouw mijn zaak aan U toe, en ik wend mijn gezicht naar U, en ik steun mijn rug op U, uit verlangen naar U en uit vrees voor U. Er is geen toevlucht of redding tegen U behalve bij U. Ik geloof in Uw Boek dat U hebt neergezonden en in Uw Profeet die U hebt gezonden.',
    'Allah''ım! Kendimi Sana teslim ettim, işimi Sana havale ettim, yüzümü Sana çevirdim ve sırtımı Sana dayadım; Sana rağbet ederek ve Senden korkarak. Senden kaçıp sığınılacak ve kurtulunacak yer ancak Sensin. İndirdiğin Kitabına ve gönderdiğin Peygamberine iman ettim.',
    'Ya Allah, aku menyerahkan jiwaku kepada-Mu, aku menyerahkan urusanku kepada-Mu, aku menghadapkan wajahku kepada-Mu, dan aku menyandarkan punggungku kepada-Mu, karena penuh harap dan takut kepada-Mu. Tidak ada tempat berlindung dan tempat selamat dari (siksa)-Mu kecuali kepada-Mu. Aku beriman kepada kitab-Mu yang telah Engkau turunkan dan kepada nabi-Mu yang telah Engkau utus.',
    'اے اللہ! میں نے اپنی جان تیرے سپرد کر دی، اپنا معاملہ تیرے حوالے کر دیا، اپنا چہرہ تیری طرف کر لیا، اور اپنی پشت تیرے سہارے لگا دی، تیری رغبت اور تیرے خوف کے ساتھ۔ تجھ سے بچنے اور پناہ کی کوئی جگہ نہیں سوائے تیرے۔ میں تیری اس کتاب پر ایمان لایا جو تو نے اتاری اور تیرے اس نبی پر جسے تو نے بھیجا۔',
    'হে আল্লাহ! আমি আমার প্রাণ তোমার কাছে সমর্পণ করলাম, আমার বিষয় তোমার কাছে ন্যস্ত করলাম, আমার মুখ তোমার দিকে ফেরালাম, এবং আমার পিঠ তোমার উপর ঠেকালাম—তোমার প্রতি আগ্রহ ও তোমার ভয়সহকারে। তোমার (পাকড়াও) থেকে তুমি ছাড়া আশ্রয় ও মুক্তির কোনো স্থান নেই। আমি তোমার সেই কিতাবের প্রতি ঈমান আনলাম যা তুমি নাযিল করেছ এবং তোমার সেই নবীর প্রতি যাঁকে তুমি পাঠিয়েছ।',
    'Ya Allah, aku menyerahkan jiwaku kepada-Mu, aku menyerahkan urusanku kepada-Mu, aku menghadapkan wajahku kepada-Mu, dan aku menyandarkan belakangku kepada-Mu, kerana penuh harap dan takut kepada-Mu. Tiada tempat berlindung dan tempat selamat daripada (azab)-Mu melainkan kepada-Mu. Aku beriman kepada kitab-Mu yang telah Engkau turunkan dan kepada nabi-Mu yang telah Engkau utus.',
    'О Аллах, я предал свою душу Тебе, и вверил Тебе своё дело, и обратил своё лицо к Тебе, и оперся спиной на Тебя, со стремлением к Тебе и страхом пред Тобой. Нет убежища и спасения от Тебя, кроме как у Тебя. Я уверовал в Твою Книгу, которую Ты ниспослал, и в Твоего Пророка, которого Ты послал.',
    'Before sleep', 'Avant de dormir', 'قبل النوم',
    'Bukhārī 6313, 247', 'Bukhārī 6313, 247', 'صحيح البخاري ٦٣١٣، ٢٤٧',
    1::smallint, 5::smallint
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
where s.title_en = 'Before sleep'
  and v.arabic_text is not null
  and not exists (
    select 1 from public.adhkars a where a.adhkar_subcategory_id = s.id
  );

-- ── 4) Localise transliteration / when / reference per language ──────────────
-- Mirrors step 4 of the morning/evening migrations. Only one "when" phrase is
-- used here ("Before sleep"), so 4a is a direct assignment. All statements stay
-- scoped to "Before sleep" and are safe to re-run (direct assignment).
--
-- REVIEW NOTE: the ur / bn / ru phonetic transcriptions in 4d are
-- transliterations of the Arabic and should be reviewed by a qualified native
-- speaker before production use (as already noted for the translations above).

-- 4a) "when" — single source phrase across all 17 adhkars.
update public.adhkars a
set
  when_de = 'Vor dem Schlafen',
  when_nl = 'Voor het slapengaan',
  when_tr = 'Uyumadan önce',
  when_id = 'Sebelum tidur',
  when_ms = 'Sebelum tidur',
  when_ur = 'سونے سے پہلے',
  when_bn = 'ঘুমানোর আগে',
  when_ru = 'Перед сном'
from public.adhkar_subcategories s
where a.adhkar_subcategory_id = s.id
  and s.title_en = 'Before sleep';

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
  and s.title_en = 'Before sleep';

-- 4c) Reference for Latin-script languages: collection names stay romanised;
-- only the word "Qur'an" is localised (a no-op for references without it).
update public.adhkars a
set
  reference_de = replace(a.reference_en, 'Qur''an', 'Koran'),
  reference_nl = replace(a.reference_en, 'Qur''an', 'Koran'),
  reference_tr = replace(a.reference_en, 'Qur''an', 'Kur''an'),
  reference_id = replace(a.reference_en, 'Qur''an', 'Al-Qur''an'),
  reference_ms = replace(a.reference_en, 'Qur''an', 'Al-Qur''an')
from public.adhkar_subcategories s
where a.adhkar_subcategory_id = s.id
  and s.title_en = 'Before sleep';

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
  -- 1. Ayat al-Kursi (identical to morning)
  ('Bukhārī 2311',
   'اَعُوْذُ بِاللہِ مِنَ الشَّیْطٰنِ الرَّجِیْم۔ اَللہُ لَا اِلٰہَ اِلَّا ھُوَ الْحَیُّ الْقَیُّوْم، لَا تَاْخُذُہٗ سِنَۃٌ وَّلَا نَوْم، لَہٗ مَا فِی السَّمٰوٰتِ وَمَا فِی الْاَرْض، مَنْ ذَا الَّذِیْ یَشْفَعُ عِنْدَہٗ اِلَّا بِاِذْنِہٖ، یَعْلَمُ مَا بَیْنَ اَیْدِیْہِمْ وَمَا خَلْفَہُمْ، وَلَا یُحِیْطُوْنَ بِشَیْءٍ مِّنْ عِلْمِہٖ اِلَّا بِمَا شَآء، وَسِعَ کُرْسِیُّہُ السَّمٰوٰتِ وَالْاَرْض، وَلَا یَؤُوْدُہٗ حِفْظُہُمَا وَھُوَ الْعَلِیُّ الْعَظِیْم۔',
   'আঊযু বিল্লাহি মিনাশ শাইতানির রাজীম। আল্লাহু লা ইলাহা ইল্লা হুওয়াল হাইয়ুল কাইয়ূম, লা তা’খুযুহূ সিনাতুঁও ওয়ালা নাউম, লাহূ মা ফিস সামাওয়াতি ওয়ামা ফিল আরদ, মান যাল্লাযী ইয়াশফাউ ইনদাহূ ইল্লা বিইযনিহ, ইয়া’লামু মা বাইনা আইদীহিম ওয়ামা খালফাহুম, ওয়ালা ইউহীতূনা বিশাইইম মিন ইলমিহী ইল্লা বিমা শা’, ওয়াসিআ কুরসিইয়ুহুস সামাওয়াতি ওয়াল আরদ, ওয়ালা ইয়াঊদুহূ হিফযুহুমা ওয়া হুওয়াল আলিইয়ুল আযীম।',
   'А’узу би-Лляхи мина-ш-шайтани-р-раджим. Аллаху ля иляха илля Хуваль-Хаййуль-Каййум, ля та’хузуху синатун ва ля наум, ляху ма фи-с-самавати ва ма филь-ард, ман заллязи яшфа’у ’индаху илля би-изних, я’ляму ма байна айдихим ва ма хальфахум, ва ля юхитуна би-шайъим-мин ’ильмихи илля би-ма ша’, васи’а курсиййуху-с-самавати валь-ард, ва ля я’удуху хифзухума ва Хуваль-’Алиййуль-’Азым.',
   'صحیح بخاری 2311', 'সহীহ বুখারী 2311', 'Сахих аль-Бухари 2311'),
  -- 2. Last two ayahs of al-Baqarah (2:285-286)
  ('Bukhārī 4008, 807',
   'اَعُوْذُ بِاللہِ مِنَ الشَّیْطٰنِ الرَّجِیْم۔ اٰمَنَ الرَّسُوْلُ بِمَا اُنْزِلَ اِلَیْہِ مِنْ رَّبِّہٖ وَالْمُؤْمِنُوْن، کُلٌّ اٰمَنَ بِاللہِ وَمَلٰئِکَتِہٖ وَکُتُبِہٖ وَرُسُلِہٖ، لَا نُفَرِّقُ بَیْنَ اَحَدٍ مِّنْ رُّسُلِہٖ، وَقَالُوْا سَمِعْنَا وَاَطَعْنَا غُفْرَانَکَ رَبَّنَا وَاِلَیْکَ الْمَصِیْر۔ لَا یُکَلِّفُ اللہُ نَفْسًا اِلَّا وُسْعَہَا، لَہَا مَا کَسَبَتْ وَعَلَیْہَا مَا اکْتَسَبَتْ، رَبَّنَا لَا تُؤَاخِذْنَا اِنْ نَّسِیْنَا اَوْ اَخْطَاْنَا، رَبَّنَا وَلَا تَحْمِلْ عَلَیْنَا اِصْرًا کَمَا حَمَلْتَہٗ عَلَی الَّذِیْنَ مِنْ قَبْلِنَا، رَبَّنَا وَلَا تُحَمِّلْنَا مَا لَا طَاقَۃَ لَنَا بِہٖ، وَاعْفُ عَنَّا وَاغْفِرْ لَنَا وَارْحَمْنَا، اَنْتَ مَوْلَانَا فَانْصُرْنَا عَلَی الْقَوْمِ الْکٰفِرِیْن۔',
   'আঊযু বিল্লাহি মিনাশ শাইতানির রাজীম। আমানার রাসূলু বিমা উনযিলা ইলাইহি মির রাব্বিহী ওয়াল মুমিনূন, কুল্লুন আমানা বিল্লাহি ওয়া মালাইকাতিহী ওয়া কুতুবিহী ওয়া রুসুলিহ, লা নুফাররিকু বাইনা আহাদিম মির রুসুলিহ, ওয়া কালূ সামি’না ওয়া আতা’না গুফরানাকা রাব্বানা ওয়া ইলাইকাল মাসীর। লা ইউকাল্লিফুল্লাহু নাফসান ইল্লা উসআহা, লাহা মা কাসাবাত ওয়া আলাইহা মাকতাসাবাত, রাব্বানা লা তুআখিযনা ইন নাসীনা আও আখতা’না, রাব্বানা ওয়ালা তাহমিল আলাইনা ইসরান কামা হামালতাহূ আলাল্লাযীনা মিন কাবলিনা, রাব্বানা ওয়ালা তুহাম্মিলনা মা লা তাকাতা লানা বিহ, ওয়া’ফু আন্না ওয়াগফির লানা ওয়ারহামনা, আনতা মাওলানা ফানসুরনা আলাল কাওমিল কাফিরীন।',
   'А’узу би-Лляхи мина-ш-шайтани-р-раджим. Амана-р-расулю бима унзиля иляйхи ми-р-раббихи ва-ль-муъминун, куллюн амана би-Лляхи ва маляикятихи ва кутубихи ва русулих, ля нуфаррику байна ахадим-ми-р-русулих, ва калю сами’на ва ата’на гуфранака Раббана ва иляйка-ль-масир. Ля юкяллифу-Ллаху нафсан илля вус’аха, ляха ма касабат ва ’аляйха мактасабат, Раббана ля туахизна ин насина ау ахта’на, Раббана валя тахмиль ’аляйна исран кама хамальтаху ’аля-ллязина мин каблина, Раббана ва ля тухаммильна ма ля таката ляна бих, ва’фу ’анна ва-гфир ляна вар-хамна, Анта Мауляна фан-сурна ’аля-ль-кауми-ль-кафирин.',
   'صحیح بخاری 4008، 807', 'সহীহ বুখারী 4008, 807', 'Сахих аль-Бухари 4008, 807'),
  -- 3. Surah al-Kafirun (109)
  ('Tirmidhī 3403',
   'بِسْمِ اللہِ الرَّحْمٰنِ الرَّحِیْم۔ قُلْ یٰۤاَیُّہَا الْکَافِرُوْن، لَاۤ اَعْبُدُ مَا تَعْبُدُوْن، وَلَاۤ اَنْتُمْ عَابِدُوْنَ مَاۤ اَعْبُد، وَلَاۤ اَنَا عَابِدٌ مَّا عَبَدْتُّم، وَلَاۤ اَنْتُمْ عَابِدُوْنَ مَاۤ اَعْبُد، لَکُمْ دِیْنُکُمْ وَلِیَ دِیْن۔',
   'বিসমিল্লাহির রাহমানির রাহীম। কুল ইয়া আইয়ুহাল কাফিরূন, লা আবুদু মা তাবুদূন, ওয়ালা আনতুম আবিদূনা মা আবুদ, ওয়ালা আনা আবিদুম মা আবাত্তুম, ওয়ালা আনতুম আবিদূনা মা আবুদ, লাকুম দীনুকুম ওয়ালিয়া দীন।',
   'Бисми-Лляхи-р-Рахмани-р-Рахим. Куль я айюха-ль-кяфирун, ля а’буду ма та’будун, ва ля антум ’абидуна ма а’буд, ва ля ана ’абидум-ма ’абаттум, ва ля антум ’абидуна ма а’буд, лякум динукум ва лия дин.',
   'ترمذی 3403', 'তিরমিযী 3403', 'ат-Тирмизи 3403'),
  -- 4. The Three Quls (identical to morning)
  ('Bukhārī 5017',
   'بِسْمِ اللہِ الرَّحْمٰنِ الرَّحِیْم۔ قُلْ ھُوَ اللہُ اَحَد۔ اَللہُ الصَّمَد۔ لَمْ یَلِدْ وَلَمْ یُوْلَدْ۔ وَلَمْ یَکُنْ لَّہٗ کُفُوًا اَحَد۔ بِسْمِ اللہِ الرَّحْمٰنِ الرَّحِیْم۔ قُلْ اَعُوْذُ بِرَبِّ الْفَلَق۔ مِنْ شَرِّ مَا خَلَق۔ وَمِنْ شَرِّ غَاسِقٍ اِذَا وَقَب۔ وَمِنْ شَرِّ النَّفّٰثٰتِ فِی الْعُقَد۔ وَمِنْ شَرِّ حَاسِدٍ اِذَا حَسَد۔ بِسْمِ اللہِ الرَّحْمٰنِ الرَّحِیْم۔ قُلْ اَعُوْذُ بِرَبِّ النَّاس۔ مَلِکِ النَّاس۔ اِلٰہِ النَّاس۔ مِنْ شَرِّ الْوَسْوَاسِ الْخَنَّاس۔ الَّذِیْ یُوَسْوِسُ فِیْ صُدُوْرِ النَّاس۔ مِنَ الْجِنَّۃِ وَالنَّاس۔',
   'বিসমিল্লাহির রাহমানির রাহীম। কুল হুওয়াল্লাহু আহাদ। আল্লাহুস সামাদ। লাম ইয়ালিদ ওয়ালাম ইউলাদ। ওয়ালাম ইয়াকুল্লাহূ কুফুওয়ান আহাদ। বিসমিল্লাহির রাহমানির রাহীম। কুল আঊযু বিরাব্বিল ফালাক। মিন শাররি মা খালাক। ওয়ামিন শাররি গাসিকিন ইযা ওয়াকাব। ওয়ামিন শাররিন নাফফাছাতি ফিল উকাদ। ওয়ামিন শাররি হাসিদিন ইযা হাসাদ। বিসমিল্লাহির রাহমানির রাহীম। কুল আঊযু বিরাব্বিন নাস। মালিকিন নাস। ইলাহিন নাস। মিন শাররিল ওয়াসওয়াসিল খান্নাস। আল্লাযী ইউওয়াসউইসু ফী সুদূরিন নাস। মিনাল জিন্নাতি ওয়ান নাস।',
   'Бисми-Лляхи-р-Рахмани-р-Рахим. Куль Хуваллаху Ахад. Аллаху-с-Самад. Лям ялид ва лям юляд. Ва лям якуль-ляху куфуван ахад. Бисми-Лляхи-р-Рахмани-р-Рахим. Куль а’узу би-Рабби-ль-фаляк. Мин шарри ма халяк. Ва мин шарри гасикин иза вакаб. Ва мин шарри-н-наффасати фи-ль-’укад. Ва мин шарри хасидин иза хасад. Бисми-Лляхи-р-Рахмани-р-Рахим. Куль а’узу би-Рабби-н-нас. Малики-н-нас. Иляхи-н-нас. Мин шарри-ль-васваси-ль-ханнас. Аллязи ювасвису фи судури-н-нас. Мина-ль-джиннати ва-н-нас.',
   'صحیح بخاری 5017', 'সহীহ বুখারী 5017', 'Сахих аль-Бухари 5017'),
  -- 5. Tasbih, Tahmid and Takbir (identical to morning, counts 33/33/34)
  ('Bukhārī 3705',
   'سُبْحَانَ اللہ (×33)، اَلْحَمْدُ لِلہ (×33)، اَللہُ اَکْبَر (×34)۔',
   'সুবহানাল্লাহ (×৩৩), আলহামদু লিল্লাহ (×৩৩), আল্লাহু আকবার (×৩৪)।',
   'Субхана-Ллах (×33), Альхамду ли-Ллях (×33), Аллаху акбар (×34).',
   'صحیح بخاری 3705', 'সহীহ বুখারী 3705', 'Сахих аль-Бухари 3705'),
  -- 6. Mercy and protection (Bismika Rabbi)
  ('Bukhārī 6320',
   'بِاسْمِکَ رَبِّیْ وَضَعْتُ جَنْبِیْ، وَبِکَ اَرْفَعُہٗ، اِنْ اَمْسَکْتَ نَفْسِیْ فَارْحَمْہَا، وَاِنْ اَرْسَلْتَہَا فَاحْفَظْہَا بِمَا تَحْفَظُ بِہٖ عِبَادَکَ الصَّالِحِیْن۔',
   'বিসমিকা রাব্বী ওয়াদা’তু জামবী, ওয়া বিকা আরফাউহ, ইন আমসাকতা নাফসী ফারহামহা, ওয়া ইন আরসালতাহা ফাহফাযহা বিমা তাহফাযু বিহী ইবাদাকাস সালিহীন।',
   'Бисмика Рабби вада’ту джамби, ва бика арфа’ух, ин амсакта нафси фа-рхамха, ва ин арсальтаха фа-хфазха бима тахфазу бихи ’ибадака-с-салихин.',
   'صحیح بخاری 6320', 'সহীহ বুখারী 6320', 'Сахих аль-Бухари 6320'),
  -- 7. Protection from punishment (Allahumma qini)
  ('Abū Dāwūd 5045',
   'اَللّٰھُمَّ قِنِیْ عَذَابَکَ یَوْمَ تَبْعَثُ عِبَادَک۔',
   'আল্লাহুম্মা কিনী আযাবাকা ইয়াওমা তাবআছু ইবাদাক।',
   'Аллахумма кини ’азабака йаума таб’асу ’ибадак.',
   'سنن ابی داؤد 5045', 'সুনান আবু দাউদ 5045', 'Сунан Абу Дауд 5045'),
  -- 8. Thank Allah for blessing you
  ('Muslim 2715',
   'اَلْحَمْدُ لِلہِ الَّذِیْۤ اَطْعَمَنَا وَسَقَانَا، وَکَفَانَا، وَاٰوَانَا، فَکَمْ مِّمَّنْ لَّا کَافِیَ لَہٗ وَلَا مُؤْوِیَ۔',
   'আলহামদু লিল্লাহিল্লাযী আত’আমানা ওয়া সাকানা, ওয়া কাফানা, ওয়া আওয়ানা, ফাকাম মিম্মান লা কাফিয়া লাহূ ওয়ালা মু’উইয়া।',
   'Аль-хамду ли-Лляхи-ллязи ат’амана ва сакана, ва кафана, ва авана, факам-мим-ман ля кафия ляху валя му’вий.',
   'صحیح مسلم 2715', 'সহীহ মুসলিম 2715', 'Сахих Муслим 2715'),
  -- 9. Protect from the 4 evils (identical to morning)
  ('Tirmidhī 3392, 3529; Aḥmad 82',
   'اَللّٰھُمَّ فَاطِرَ السَّمٰوَاتِ وَالْاَرْض، عَالِمَ الْغَیْبِ وَالشَّہَادَۃ، رَبَّ کُلِّ شَیْءٍ وَّمَلِیْکَہٗ، اَشْہَدُ اَنْ لَّا اِلٰہَ اِلَّا اَنْتَ، اَعُوْذُ بِکَ مِنْ شَرِّ نَفْسِیْ وَمِنْ شَرِّ الشَّیْطٰنِ وَشِرْکِہٖ وَاَنْ اَقْتَرِفَ عَلٰی نَفْسِیْ سُوْٓءًا اَوْ اَجُرَّہٗ اِلٰی مُسْلِم۔',
   'আল্লাহুম্মা ফাতিরাস সামাওয়াতি ওয়াল আরদ, আলিমাল গাইবি ওয়াশ শাহাদাহ, রাব্বা কুল্লি শাইইঁও ওয়া মালীকাহ, আশহাদু আল্লা ইলাহা ইল্লা আনতা, আঊযু বিকা মিন শাররি নাফসী ওয়া মিন শাররিশ শাইতানি ওয়া শিরকিহী ওয়া আন আকতারিফা আলা নাফসী সূআন আও আজুররাহূ ইলা মুসলিম।',
   'Аллахумма фатира-с-самавати ва-ль-ард, ’алима-ль-гайби ва-ш-шахада, рабба кулли шайъиу-ва малика, аш-хаду алля иляха илля Ант, а’узу бика мин шарри нафси ва мин шарри-ш-шайтани ва ширкихи ва ан актарифа ’аля нафси суъан ау аджурраху иля муслим.',
   'ترمذی 3392، 3529؛ مسند احمد 82', 'তিরমিযী 3392, 3529; মুসনাদে আহমাদ 82', 'ат-Тирмизи 3392, 3529; Муснад Ахмад 82'),
  -- 10. Protection from evil and settling of debts
  ('Muslim 2713',
   'اَللّٰھُمَّ رَبَّ السَّمٰوَاتِ وَرَبَّ الْاَرْضِ وَرَبَّ الْعَرْشِ الْعَظِیْم، رَبَّنَا وَرَبَّ کُلِّ شَیْء، فَالِقَ الْحَبِّ وَالنَّوٰی، وَمُنْزِلَ التَّوْرَاۃِ وَالْاِنْجِیْلِ وَالْفُرْقَان، اَعُوْذُ بِکَ مِنْ شَرِّ کُلِّ شَیْءٍ اَنْتَ اٰخِذٌ بِنَاصِیَتِہٖ، اَللّٰھُمَّ اَنْتَ الْاَوَّلُ فَلَیْسَ قَبْلَکَ شَیْء، وَاَنْتَ الْاٰخِرُ فَلَیْسَ بَعْدَکَ شَیْء، وَاَنْتَ الظَّاہِرُ فَلَیْسَ فَوْقَکَ شَیْء، وَاَنْتَ الْبَاطِنُ فَلَیْسَ دُوْنَکَ شَیْء، اِقْضِ عَنَّا الدَّیْنَ وَاَغْنِنَا مِنَ الْفَقْر۔',
   'আল্লাহুম্মা রাব্বাস সামাওয়াতি ওয়া রাব্বাল আরদি ওয়া রাব্বাল আরশিল আযীম, রাব্বানা ওয়া রাব্বা কুল্লি শাইইন, ফালিকাল হাব্বি ওয়ান নাওয়া, ওয়া মুনযিলাত তাওরাতি ওয়াল ইনজীলি ওয়াল ফুরকান, আঊযু বিকা মিন শাররি কুল্লি শাইইন আনতা আখিযুম বিনাসিয়াতিহ, আল্লাহুম্মা আনতাল আউওয়ালু ফালাইসা কাবলাকা শাই, ওয়া আনতাল আখিরু ফালাইসা বা’দাকা শাই, ওয়া আনতায যাহিরু ফালাইসা ফাওকাকা শাই, ওয়া আনতাল বাতিনু ফালাইসা দূনাকা শাই, ইকদি আন্নাদ দাইনা ওয়া আগনিনা মিনাল ফাকর।',
   'Аллахумма Раббас-самавати ва Раббаль-арды ва Раббаль-’Аршиль-’азым, Раббана ва Рабба кулли шайъ, фаликаль-хабби ван-нава, ва мунзилят-Таврати валь-Инджили валь-Фуркан, а’узу бика мин шарри кулли шайъин Анта ахизун би-насиятих, Аллахумма Анталь-Аввалю фа-ляйса каблака шайъ, ва Анталь-Ахиру фа-ляйса ба’дака шайъ, ва Анта-з-Захиру фа-ляйса фаукака шайъ, ва Анталь-Батину фа-ляйса дунака шайъ, икди ’анна-д-дайна ва агнина миналь-факр.',
   'صحیح مسلم 2713', 'সহীহ মুসলিম 2713', 'Сахих Муслим 2713'),
  -- 11. Ask Allah to protect you from evil
  ('Abū Dāwūd 5052',
   'اَللّٰھُمَّ اِنِّیْۤ اَعُوْذُ بِوَجْہِکَ الْکَرِیْم، وَکَلِمَاتِکَ التَّآمَّۃِ مِنْ شَرِّ مَاۤ اَنْتَ اٰخِذٌ بِنَاصِیَتِہٖ، اَللّٰھُمَّ اَنْتَ تَکْشِفُ الْمَغْرَمَ وَالْمَاْثَم، اَللّٰھُمَّ لَا یُہْزَمُ جُنْدُکَ، وَلَا یُخْلَفُ وَعْدُکَ، وَلَا یَنْفَعُ ذَا الْجَدِّ مِنْکَ الْجَدّ، سُبْحَانَکَ وَبِحَمْدِکَ۔',
   'আল্লাহুম্মা ইন্নী আঊযু বিওয়াজহিকাল কারীম, ওয়া কালিমাতিকাত তাম্মাতি মিন শাররি মা আনতা আখিযুম বিনাসিয়াতিহ, আল্লাহুম্মা আনতা তাকশিফুল মাগরামা ওয়াল মা’ছাম, আল্লাহুম্মা লা ইউহযামু জুনদুক, ওয়ালা ইউখলাফু ওয়া’দুক, ওয়ালা ইয়ানফাউ যাল জাদ্দি মিনকাল জাদ্দ, সুবহানাকা ওয়া বিহামদিক।',
   'Аллахумма инни а’узу би ваджхика-ль-карим, ва калиматика-т-таммати мин шарри ма Анта ахизун би насиятих, Аллахумма Анта такшифу-ль-маграма ва-ль-ма’сам, Аллахумма ля юхзаму джундук, ва ля юхляфу ва’дук, ва ля янфа’у за-ль-джадди минка-ль-джадд, субханака ва би хамдик.',
   'سنن ابی داؤد 5052', 'সুনান আবু দাউদ 5052', 'Сунан Абу Дауд 5052'),
  -- 12. Protection, well-being and forgiveness
  ('Aḥmad 5502',
   'اَللّٰھُمَّ اِنَّکَ خَلَقْتَ نَفْسِیْ وَاَنْتَ تَوَفَّاہَا، لَکَ مَمَاتُہَا وَمَحْیَاہَا، اِنْ اَحْیَیْتَہَا فَاحْفَظْہَا، وَاِنْ اَمَتَّہَا فَاغْفِرْ لَہَا، اَللّٰھُمَّ اِنِّیْۤ اَسْاَلُکَ الْعَافِیَۃ۔',
   'আল্লাহুম্মা ইন্নাকা খালাকতা নাফসী ওয়া আনতা তাওয়াফফাহা, লাকা মামাতুহা ওয়া মাহইয়াহা, ইন আহইয়াইতাহা ফাহফাযহা, ওয়া ইন আমাত্তাহা ফাগফির লাহা, আল্লাহুম্মা ইন্নী আস’আলুকাল আফিয়াহ।',
   'Аллахумма иннака халякта нафси ва Анта таваффаха, ляка мамятуха ва махьяха, ин ахйайтаха фа-хфазха, ва ин аматтаха фа-гфир ляха, Аллахумма инни ас’алюка-ль-’афия.',
   'مسند احمد 5502', 'মুসনাদে আহমাদ 5502', 'Муснад Ахмад 5502'),
  -- 13. Forgiveness and protection (Bismillahi wadaʿtu jambi)
  ('Abū Dāwūd 5054',
   'بِسْمِ اللہِ وَضَعْتُ جَنْبِیْ، اَللّٰھُمَّ اغْفِرْ لِیْ ذَنْبِیْ، وَاَخْسِئْ شَیْطَانِیْ، وَفُکَّ رِہَانِیْ، وَاجْعَلْنِیْ فِی النَّدِیِّ الْاَعْلٰی۔',
   'বিসমিল্লাহি ওয়াদা’তু জামবী, আল্লাহুম্মাগফির লী যামবী, ওয়া আখসি’ শাইতানী, ওয়া ফুক্কা রিহানী, ওয়াজআলনী ফিন নাদিইয়িল আ’লা।',
   'Бисми-Лляхи вада’ту джамби, Аллахумма-гфир ли замби, ва ахси’ шайтани, ва фукка рихани, ва-дж’альни фи-н-Надиййи-ль-А’ля.',
   'سنن ابی داؤد 5054', 'সুনান আবু দাউদ 5054', 'Сунан Абу Дауд 5054'),
  -- 14. Praise Allah with the praises of the entire creation
  ('Ḥākim 2001',
   'اَلْحَمْدُ لِلہِ الَّذِیْ کَفَانِیْ وَاٰوَانِیْ، اَلْحَمْدُ لِلہِ الَّذِیْۤ اَطْعَمَنِیْ وَسَقَانِیْ، اَلْحَمْدُ لِلہِ الَّذِیْ مَنَّ عَلَیَّ فَاَفْضَلَ، اَللّٰھُمَّ اِنِّیْۤ اَسْاَلُکَ بِعِزَّتِکَ اَنْ تُنَجِّیَنِیْ مِنَ النَّار۔',
   'আলহামদু লিল্লাহিল্লাযী কাফানী ওয়া আওয়ানী, আলহামদু লিল্লাহিল্লাযী আত’আমানী ওয়া সাকানী, আলহামদু লিল্লাহিল্লাযী মান্না আলাইয়া ফাআফদাল, আল্লাহুম্মা ইন্নী আস’আলুকা বিইযযাতিকা আন তুনাজ্জিয়ানী মিনান নার।',
   'Аль-хамду ли-Лляхи-ллязи кафани ва авани, аль-хамду ли-Лляхи-ллязи ат’амани ва сакани, аль-хамду ли-Лляхи-ллязи манна ’аляйя фа-афдаль, Аллахумма инни ас’алюка би ’иззатика ан тунаджжияни мина-н-нар.',
   'حاکم 2001', 'হাকিম 2001', 'аль-Хаким 2001'),
  -- 15. Sleep in the name of your Lord
  ('Bukhārī 6325',
   'اَللّٰھُمَّ بِاسْمِکَ اَمُوْتُ وَاَحْیَا۔',
   'আল্লাহুম্মা বিসমিকা আমূতু ওয়া আহইয়া।',
   'Аллахумма бисмика амуту ва ахья.',
   'صحیح بخاری 6325', 'সহীহ বুখারী 6325', 'Сахих аль-Бухари 6325'),
  -- 16. Get forgiven before going to sleep
  ('Nasā''ī',
   'لَاۤ اِلٰہَ اِلَّا اللہُ وَحْدَہٗ لَا شَرِیْکَ لَہٗ، لَہُ الْمُلْکُ وَلَہُ الْحَمْدُ، وَھُوَ عَلٰی کُلِّ شَیْءٍ قَدِیْر، وَلَا حَوْلَ وَلَا قُوَّۃَ اِلَّا بِاللہ، سُبْحَانَ اللہِ وَالْحَمْدُ لِلہِ وَلَاۤ اِلٰہَ اِلَّا اللہُ وَاللہُ اَکْبَر۔',
   'লা ইলাহা ইল্লাল্লাহু ওয়াহদাহূ লা শারীকা লাহ, লাহুল মুলকু ওয়া লাহুল হামদ, ওয়া হুওয়া আলা কুল্লি শাইইন কাদীর, ওয়ালা হাওলা ওয়ালা কুওয়াতা ইল্লা বিল্লাহ, সুবহানাল্লাহি ওয়াল হামদু লিল্লাহি ওয়ালা ইলাহা ইল্লাল্লাহু ওয়াল্লাহু আকবার।',
   'Ля иляха илля-Ллаху вахдаху ля шарика лях, ляху-ль-мульку ва ляху-ль-хамд, ва Хува ’аля кулли шайъин Кадир, ва ля хауля ва ля куввата илля би-Лляхь, субхана-Лляхи ва-ль-хамду ли-Лляхи ва ля иляха илля-Ллаху ва-Ллаху акбар.',
   'نسائی', 'নাসায়ী', 'ан-Насаи'),
  -- 17. Die upon the Fitrah
  ('Bukhārī 6313, 247',
   'اَللّٰھُمَّ اَسْلَمْتُ نَفْسِیْۤ اِلَیْکَ، وَفَوَّضْتُ اَمْرِیْۤ اِلَیْکَ، وَوَجَّہْتُ وَجْہِیْۤ اِلَیْکَ، وَاَلْجَاْتُ ظَہْرِیْۤ اِلَیْکَ، رَغْبَۃً وَّرَہْبَۃً اِلَیْکَ، لَا مَلْجَاَ وَلَا مَنْجَا مِنْکَ اِلَّاۤ اِلَیْکَ، اٰمَنْتُ بِکِتَابِکَ الَّذِیْۤ اَنْزَلْتَ وَبِنَبِیِّکَ الَّذِیْۤ اَرْسَلْتَ۔',
   'আল্লাহুম্মা আসলামতু নাফসী ইলাইক, ওয়া ফাওয়াদতু আমরী ইলাইক, ওয়া ওয়াজ্জাহতু ওয়াজহী ইলাইক, ওয়া আলজা’তু যাহরী ইলাইক, রাগবাতাঁও ওয়া রাহবাতান ইলাইক, লা মালজাআ ওয়ালা মানজা মিনকা ইল্লা ইলাইক, আমানতু বিকিতাবিকাল্লাযী আনযালতা ওয়া বিনাবিইয়িকাল্লাযী আরসালতা।',
   'Аллахумма аслямту нафси иляйк, ва фаввадту амри иляйк, ва ваджжахту ваджхи иляйк, ва альджа’ту захри иляйк, рагбатан ва рахбатан иляйк, ля мальджа’а ва ля манджа минка илля иляйк, амянту би китабика-ллязи анзальт, ва би Набийика-ллязи арсальт.',
   'صحیح بخاری 6313، 247', 'সহীহ বুখারী 6313, 247', 'Сахих аль-Бухари 6313, 247')
) as m(ref_key, t_ur, t_bn, t_ru, r_ur, r_bn, r_ru)
where a.adhkar_subcategory_id = s.id
  and s.title_en = 'Before sleep'
  and a.reference_en = m.ref_key;
