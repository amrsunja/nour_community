-- =============================================================================
-- Seed: "Travel & transit" subcategory (under existing "In daily life" category)
--        + 9 adhkars.
--
-- Source: user-provided translation sheet (travel_adhkar_translations.csv).
-- The "In daily life" category is created by 20260619000000; here we only
-- resolve it by title.
--
-- Localization mirrors 20260620000000:
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
-- Source-sheet fix applied: Dutch "Resident for Traveller #2" ("Möge" -> "Moge").
--
-- References left NULL: "When Entering Upon One's Family" (Tawban tawban…) and
-- "When One is Unable to Keep Steady on a Conveyance" (Allāhumma thabbithu…) —
-- no confident single-source attribution; do not assume a hadith number.
--
-- Idempotent: subcategory inserted if missing; adhkars inserted only when the
-- subcategory has none yet.
--
-- REVIEW NOTE: hadith references and the ur/bn/ru phonetic transcriptions were
-- not part of the source sheet — they follow the standard Hisnul-Muslim
-- attributions and should be reviewed by a qualified native speaker before
-- production use.
-- =============================================================================

-- ── Subcategory: Travel & transit ────────────────────────────────────────────
insert into public.adhkar_subcategories
  (adhkar_category_id, title_en, title_fr, title_ar, title_de, title_nl, title_tr,
   title_id, title_ur, title_bn, title_ms, title_ru, position)
select
  c.id, 'Travel & transit', 'Voyage et déplacements', 'السفر والتنقل', 'Reise & Unterwegs',
  'Reizen & onderweg', 'Yolculuk & Seyahat', 'Perjalanan & transit', 'سفر اور آمد و رفت',
  'সফর ও যাতায়াত', 'Perjalanan & transit', 'Путешествие и в пути', 3
from public.adhkar_categories c
where c.title_en = 'In daily life'
  and not exists (
    select 1 from public.adhkar_subcategories s
    where s.title_en = 'Travel & transit' and s.adhkar_category_id = c.id
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
  -- ═══════════════════════════════ 1. When travelling ═══════════════════════
  (
    'سُبْحَانَكَ إِنِّي ظَلَمْتُ نَفْسِي ، فَاغْفِرْ لِي ، فَإِنَّهُ لاَ يَغْفِرُ الذُّنُوبَ إِلاَّ أَنْتَ',
    'Subḥānaka innī ẓalamtu nafsī, fa-ghfir lī, fa-innahu lā yaghfiru-dh-dhunūba illā ant.',
    'You are free from imperfection. I have wronged myself, so forgive me, because none but You can forgive sins.',
    'Gloire à Toi ! J''ai été injuste envers moi-même, pardonne-moi donc, car nul autre que Toi ne pardonne les péchés.',
    'Gepriesen seist Du! Ich habe mir selbst Unrecht getan, so vergib mir, denn niemand außer Dir kann Sünden vergeben.',
    'U bent vrij van imperfecties! Ik heb mezelf onrecht aangedaan, vergeef mij dus, want niemand behalve U vergeeft zonden.',
    'Seni tenzih ederim. Şüphesiz ben nefsime zulmettim, beni bağışla; çünkü Senden başka günahları bağışlayacak kimse yoktur.',
    'Maha Suci Engkau, sesungguhnya aku telah menzalimi diriku sendiri, maka ampunilah aku, karena tidak ada yang mengampuni dosa-dosa selain Engkau.',
    'تو پاک ہے، بلاشبہ میں نے اپنی جان پر ظلم کیا، پس مجھے بخش دے، کیونکہ تیرے سوا کوئی گناہوں کو معاف نہیں کر سکتا۔',
    'আপনি পবিত্র! নিশ্চয়ই আমি নিজের প্রতি অবিচার করেছি, সুতরাং আমাকে ক্ষমা করুন; কারণ আপনি ছাড়া আর কেউ পাপ ক্ষমা করতে পারে না।',
    'Maha Suci Engkau, sesungguhnya aku telah menzalimi diriku sendiri, maka ampunilah aku, kerana tiada yang mengampuni dosa-dosa melainkan Engkau.',
    'Пречист Ты! Поистине, я поступил несправедливо по отношению к себе, прости же меня, ведь никто не прощает грехов, кроме Тебя.',
    'When travelling', 'En voyage', 'عند السفر',
    'Auf Reisen', 'Tijdens het reizen', 'Yolculuk sırasında', 'Ketika bepergian', 'Ketika bermusafir',
    'سفر کے وقت', 'সফরের সময়', 'Во время путешествия',
    'Tirmidhī 3446', 'Tirmidhī 3446', 'سنن الترمذي ٣٤٤٦',
    1::smallint, 5::smallint
  ),
  -- ═══════════════════════════ 2. Upon returning from travel ════════════════
  (
    'آئِبُوْنَ ، تَائِبُوْنَ ، عَابِدُوْنَ ، لِرَبِّنَا حَامِدُوْنَ',
    'Āyibūna, tā''ibūna, ʿābidūna, li-Rabbinā ḥāmidūn.',
    'Returning, repenting, worshipping and praising our Lord.',
    'Nous revenons, nous nous repentons, nous adorons et nous louons notre Seigneur.',
    'Zurückkehrend, bereuend, anbetend und unseren Herrn preisend.',
    'Terugkerend, berouw tonend, aanbiddend en onze Heer prijzend.',
    'Bizler dönenler, tövbe edenler, kulluk edenler ve Rabbimize hamdedenleriz.',
    'Kami kembali, kami bertobat, kami beribadah, dan kepada Tuhan kami, kami memuji.',
    'ہم واپس لوٹنے والے، توبہ کرنے والے، عبادت کرنے والے اور اپنے رب کی تعریف کرنے والے ہیں۔',
    'আমরা প্রত্যাবর্তনকারী, তাওবাকারী, ইবাদতকারী এবং আমাদের প্রতিপালকের প্রশংসাকারী।',
    'Kami kembali, kami bertaubat, kami beribadah, dan kepada Tuhan kami, kami memuji.',
    'Мы возвращаемся, каемся, поклоняемся и Господа нашего славим.',
    'Upon returning from travel', 'Au retour de voyage', 'عند الرجوع من السفر',
    'Bei der Rückkehr von einer Reise', 'Bij terugkeer van een reis', 'Yolculuktan dönerken',
    'Ketika kembali dari perjalanan', 'Ketika pulang dari musafir', 'سفر سے واپسی پر',
    'সফর থেকে ফেরার সময়', 'При возвращении из путешествия',
    'Muslim 1342', 'Muslim 1342', 'صحيح مسلم ١٣٤٢',
    1::smallint, 5::smallint
  ),
  -- ════════════════════ 3. When stopping at a place (dismounting) ═══════════
  (
    'أَعُوْذُ بِكَلِمَاتِ اللهِ التَّامَّاتِ مِنْ شَرِّ مَا خَلَقَ',
    'Aʿūdhu bi-kalimāti-llāhi-t-tāmmāti min sharri mā khalaq.',
    'I seek protection in Allah’s perfect words from the evil of whatever He has created.',
    'Je cherche protection auprès des paroles parfaites d''Allah contre le mal de ce qu''Il a créé.',
    'Ich suche Zuflucht bei den vollkommenen Worten Allahs vor dem Übel dessen, was Er erschaffen hat.',
    'Ik zoek bescherming in de volmaakte woorden van Allah tegen het kwaad van wat Hij geschapen heeft.',
    'Yarattıklarının şerrinden Allah''ın eksiksiz kelimelerine sığınırım.',
    'Aku berlindung dengan kalimat-kalimat Allah yang sempurna dari kejahatan apa yang diciptakan-Nya.',
    'میں اللہ کے کامل کلمات کی پناہ مانگتا ہوں ہر اس چیز کے شر سے جو اس نے پیدا کی ہے۔',
    'আল্লাহর সৃষ্টি সমস্ত কিছুর অনিষ্ট থেকে তাঁর পরিপূর্ণ বাণীসমূহের আশ্রয় প্রার্থনা করছি।',
    'Aku berlindung dengan kalimah-kalimah Allah yang sempurna daripada kejahatan makhluk yang diciptakan-Nya.',
    'Прибегаю к защите совершенных слов Аллаха от зла того, что Он сотворил.',
    'When stopping at a place (dismounting)', 'En faisant halte (en descendant de sa monture)', 'عند النزول منزلًا',
    'Beim Anhalten an einem Ort (Absteigen)', 'Bij het stoppen op een plaats (afstappen)', 'Bir yerde konaklarken (inerken)',
    'Ketika singgah di suatu tempat (turun)', 'Ketika singgah di sesuatu tempat (turun)', 'کسی جگہ پڑاؤ کرتے وقت (سواری سے اترتے وقت)',
    'কোনো স্থানে যাত্রাবিরতি করার সময় (অবতরণের সময়)', 'При остановке в каком-либо месте (сходя с верхового животного)',
    'Muslim 2708', 'Muslim 2708', 'صحيح مسلم ٢٧٠٨',
    1::smallint, 5::smallint
  ),
  -- ═══════════════ 4. When entering upon one's family (on return) ═══════════
  (
    'تَوْبًا تَوْبًا ، لِرَبِّنَا أَوْبًا ، لَا يُغَادِرُ عَلَيْنَا حَوْبًا',
    'Tawban tawban, li-Rabbinā awban, lā yughādiru ʿalaynā ḥūban.',
    'Turning turning, to our Lord returning, not leaving behind any sin [unforgiven].',
    'Nous nous repentons sincèrement, nous revenons vers notre Seigneur, un repentir qui ne laisse aucun péché.',
    'Wir bereuen, wir bereuen, zu unserem Herrn kehren wir zurück, ohne eine Sünde ungehalten zu hinterlassen.',
    'Berouw tonend, berouw tonend, naar onze Heer terugkerend, zonder een zonde achter te laten.',
    'Tövbe ederiz, tövbe ederiz, Rabbimize döneriz; üzerimizde hiçbir günah bırakmayacak bir tövbe ile.',
    'Kami bertobat, kami bertobat, kepada Tuhan kami, kami kembali, tobat yang tidak menyisakan dosa bagi kami.',
    'توبہ کرتے ہوئے، توبہ کرتے ہوئے، اپنے رب کی طرف لوٹتے ہوئے، ایسی توبہ جو ہمارے اوپر کوئی گناہ باقی نہ چھوڑے۔',
    'বারবার তাওবা করছি, আমাদের প্রতিপালকের দিকে ফিরে যাচ্ছি, যা আমাদের কোনো পাপই অবশিষ্ট রাখবে না।',
    'Kami bertaubat, kami bertaubat, kepada Tuhan kami, kami kembali, taubat yang tidak meninggalkan sebarang dosa bagi kami.',
    'Каемся, каемся, к Господу нашему возвращаемся, да не оставит Он за нами греха.',
    'When entering upon one''s family (on return)', 'En retrouvant sa famille (au retour)', 'عند الدخول على الأهل (عند العودة)',
    'Beim Eintreten bei der Familie (nach Rückkehr)', 'Bij het binnentreden bij het gezin (bij terugkeer)', 'Aileye dönünce (yolculuk sonrası)',
    'Ketika menemui keluarga (saat pulang)', 'Ketika menemui keluarga (ketika pulang)', 'اپنے گھر والوں کے پاس آتے وقت (واپسی پر)',
    'নিজের পরিবারের কাছে ফেরার সময় (প্রত্যাবর্তনে)', 'При возвращении к семье',
    NULL, NULL, NULL,
    1::smallint, 5::smallint
  ),
  -- ════════════ 5. The traveller's du'a for those staying behind ════════════
  (
    'أَسْتَوْدِعُكُمُ اللهَ الَّذِيْ لَا تَضِيْعُ وَدَائِعُهُ',
    'Astawdiʿukumu-llāha-l-ladhī lā taḍīʿu wadā''iʿuh.',
    'I leave you in the care of Allah, who does not allow anything entrusted to Him to be lost.',
    'Je vous confie à Allah, Celui dont les dépôts ne se perdent jamais.',
    'Ich vertraue euch Allah an, Dessen anvertraute Güter niemals verloren gehen.',
    'Ik vertrouw jullie toe aan Allah, Die de aan Hem toevertrouwde zaken niet verloren laat gaan.',
    'Sizi, kendisine emanet edilen şeylerin asla kaybolmadığı Allah''a emanet ediyorum.',
    'Aku menitipkan kamu kepada Allah yang tidak akan hilang titipan-titipan-Nya.',
    'میں تم کو اللہ کے حوالے کرتا ہوں جس کی دی ہوئی امانتیں کبھی ضائع نہیں ہوتیں۔',
    'আমি তোমাদের আল্লাহর হেফাজতে রেখে যাচ্ছি, যাঁর কাছে কোনো কিছু গচ্ছিত রাখলে তা কখনো নষ্ট হয় না।',
    'Aku menyerahkan kamu kepada jagaan Allah, yang tidak akan mensia-siakan apa-apa yang diamanahkan kepada-Nya.',
    'Вверяю вас Аллаху, у Которого не теряется то, что отдано Ему на хранение.',
    'The traveller''s du''a for those staying behind', 'Invocation du voyageur pour ceux qui restent', 'دعاء المسافر لمن يقيم',
    'Bittgebet des Reisenden für die Zurückbleibenden', 'Smeekbede van de reiziger voor wie achterblijven', 'Yolcunun, geride kalanlar için duası',
    'Doa musafir untuk orang yang ditinggalkan', 'Doa musafir untuk orang yang ditinggalkan', 'مسافر کی، رہنے والوں کے لیے دعا',
    'মুসাফিরের, যারা থেকে যাচ্ছে তাদের জন্য দোয়া', 'Дуа путника за остающихся',
    'Ibn Mājah 2825', 'Ibn Mājah 2825', 'سنن ابن ماجه ٢٨٢٥',
    1::smallint, 5::smallint
  ),
  -- ═══════════════ 6. Du'a for one setting out on a journey #1 ══════════════
  (
    'أَسْتَوْدِعُ اللهَ دِيْنَكَ ، وَأَمَانَتَكَ ، وَخَوَاتِيْمَ عَمَلِكَ',
    'Astawdiʿu-llāha dīnaka, wa amānataka, wa khawātīma ʿamalik.',
    'I leave your religion, your trust and the last of your deeds in the care of Allah.',
    'Je confie à Allah ta religion, ton dépôt et la fin de tes œuvres.',
    'Ich vertraue Allah deinen Glauben, deine Treue und das Ende deiner Taten an.',
    'Ik vertrouw aan Allah jouw religie toe, jouw betrouwbaarheid en het einde van jouw daden.',
    'Senin dinini, emanetini ve işlerinin sonunu Allah''a emanet ederim.',
    'Aku menitipkan kepada Allah agamamu, amanahmu, dan akhir penutup amalanmu.',
    'میں اللہ کے سپرد کرتا ہوں تمہارا دین، تمہاری امانت اور تمہارے عمل کا خاتمہ۔',
    'আমি তোমার দ্বীন, তোমার আমানত এবং তোমার শেষ আমলসমূহ আল্লাহর হেফাজতে সমর্পণ করছি।',
    'Aku menyerahkan kepada Allah agamamu, amanahmu, dan penghujung amalanmu.',
    'Вверяю Аллаху твою религию, твою верность и исход твоих дел.',
    'Du''a for one setting out on a journey', 'Invocation pour celui qui part en voyage', 'دعاء المقيم للمسافر',
    'Bittgebet für den Aufbrechenden', 'Smeekbede voor wie op reis gaat', 'Yolculuğa çıkan için dua',
    'Doa untuk orang yang hendak bepergian', 'Doa untuk orang yang hendak bermusafir', 'سفر پر روانہ ہونے والے کے لیے دعا',
    'সফরে রওনা হওয়া ব্যক্তির জন্য দোয়া', 'Дуа за отправляющегося в путь',
    'Tirmidhī 3443', 'Tirmidhī 3443', 'سنن الترمذي ٣٤٤٣',
    1::smallint, 5::smallint
  ),
  -- ═══════════════ 7. Du'a for one setting out on a journey #2 ══════════════
  (
    'زَوَّدَكَ اللَّهُ التَّقْوَى ، وَغَفَرَ ذَنْبَكَ ، وَيَسَّرَ لَكَ الْخَيْرَ حَيْثُمَا كُنْتَ',
    'Zawwadaka-llāhu-t-taqwā, wa ghafara dhanbaka, wa yassara laka-l-khayra ḥaythumā kunt.',
    'May Allah grant you Taqwa as your provision, and may He forgive your sin, and may He make goodness easy for you wherever you are.',
    'Qu''Allah te pourvoie de piété (Taqwa), qu''Il pardonne ton péché et qu''Il te facilite le bien où que tu sois.',
    'Möge Allah dich mit Gottesfurcht (Taqwa) versorgen, deine Sünden vergeben und dir das Gute erleichtern, wo immer du bist.',
    'Moge Allah je voorzien van godsvrucht (Taqwa), je zonden vergeven en het goede voor je vergemakkelijken waar je ook bent.',
    'Allah sana takva azığı versin, günahını bağışlasın ve her nerede olursan ol hayrı sana kolaylaştırsın.',
    'Semoga Allah membekalimu ketakwaan, mengampuni dosamu, dan memudahkan kebaikan bagimu di mana pun kamu berada.',
    'اللہ تمہیں تقویٰ کا زادِ راہ عطا فرمائے، تمہارے گناہ معاف کرے، اور تم جہاں کہیں بھی ہو تمہارے لیے بھلائی آسان کر دے۔',
    'আল্লাহ তোমাকে তাকওয়ার পাথেয় দান করুন, তোমার পাপ ক্ষমা করুন এবং তুমি যেখানেই থাকো তোমার জন্য কল্যাণ সহজ করে দিন।',
    'Semoga Allah membekalkanmu ketakwaan, mengampuni dosamu, dan memudahkan kebaikan bagimu di mana jua kamu berada.',
    'Да наделит тебя Аллах богобоязненностью, да простит твой грех и да облегчит тебе благо, где бы ты ни был.',
    'Du''a for one setting out on a journey', 'Invocation pour celui qui part en voyage', 'دعاء المقيم للمسافر',
    'Bittgebet für den Aufbrechenden', 'Smeekbede voor wie op reis gaat', 'Yolculuğa çıkan için dua',
    'Doa untuk orang yang hendak bepergian', 'Doa untuk orang yang hendak bermusafir', 'سفر پر روانہ ہونے والے کے لیے دعا',
    'সফরে রওনা হওয়া ব্যক্তির জন্য দোয়া', 'Дуа за отправляющегося в путь',
    'Tirmidhī 3444', 'Tirmidhī 3444', 'سنن الترمذي ٣٤٤٤',
    1::smallint, 5::smallint
  ),
  -- ═══════════════ 8. Du'a for one setting out on a journey #3 ══════════════
  (
    'اللَّهُمَّ اطْوِ لَهُ الْأَرْضَ وَهَوِّنْ عَلَيْهِ السَّفَرَ',
    'Allāhumma-ṭwi lahu-l-arḍa wa hawwin ʿalayhi-s-safar.',
    'O Allah, shorten the distance for him and make travel easy for him.',
    'Ô Allah, raccourcis-lui les distances et rends-lui le voyage facile.',
    'O Allah, verkürze ihm die Entfernung der Erde und mache ihm die Reise leicht.',
    'O Allah, verkort de afstand van de aarde voor hem en vergemakkelijk de reis voor hem.',
    'Allah''ım! Ona yeryüzünü dür (mesafeleri kısalt) ve yolculuğu ona kolaylaştır.',
    'Ya Allah, dekatkanlah jarak bumi baginya dan mudahkanlah perjalanan atasnya.',
    'اے اللہ! اس کے لیے زمین کو سمیٹ دے (مسافت کم کر دے) اور اس پر سفر آسان کر دے۔',
    'হে আল্লাহ! তার জন্য পথ সংক্ষেপ করে দিন (দূরত্ব কমিয়ে দিন) এবং তার সফর সহজ করে দিন।',
    'Ya Allah, dekatkanlah jarak bumi baginya dan mudahkanlah perjalanan ke atasnya.',
    'О Аллах, сократи для него землю и облегчи ему путь.',
    'Du''a for one setting out on a journey', 'Invocation pour celui qui part en voyage', 'دعاء المقيم للمسافر',
    'Bittgebet für den Aufbrechenden', 'Smeekbede voor wie op reis gaat', 'Yolculuğa çıkan için dua',
    'Doa untuk orang yang hendak bepergian', 'Doa untuk orang yang hendak bermusafir', 'سفر پر روانہ ہونے والے کے لیے دعا',
    'সফরে রওনা হওয়া ব্যক্তির জন্য দোয়া', 'Дуа за отправляющегося в путь',
    'Tirmidhī 3445', 'Tirmidhī 3445', 'سنن الترمذي ٣٤٤٥',
    1::smallint, 5::smallint
  ),
  -- ═════════════ 9. For one who cannot stay steady on a mount/vehicle ═══════
  (
    'اللَّهُمَّ ثَبِّتْهُ وَاجْعَلْهُ هَادِيًا مَهْدِيًّا',
    'Allāhumma thabbithu wa-jʿalhu hādiyan mahdiyyan.',
    'O Allah, make him steady and make him a guide who is guided.',
    'Ô Allah, affermis-le et fais de lui un guide bien guidé.',
    'O Allah, mache ihn standhaft und mache ihn zu einem Führer, der rechtgeleitet ist.',
    'O Allah, maak hem standvastig en maak hem een gids die rechtgeleid is.',
    'Allah''ım! Onu sabit (sağlam) kıl, onu hidayete erdiren ve hidayete ermiş bir rehber yap.',
    'Ya Allah, teguhkanlah dia dan jadikanlah dia pemberi petunjuk yang diberi petunjuk.',
    'اے اللہ! اسے ثابت قدم رکھ اور اسے ہدایت دینے والا اور ہدایت یافتہ بنا۔',
    'হে আল্লাহ! তাকে অবিচল রাখুন এবং তাকে হেদায়েতকারী ও হেদায়েতপ্রাপ্ত করুন।',
    'Ya Allah, tetapkanlah dia dan jadikanlah dia pemberi petunjuk yang mendapat petunjuk.',
    'О Аллах, укрепи его и сделай его ведущим прямым путем и идущим по нему.',
    'For one who cannot stay steady on a mount/vehicle', 'Pour celui qui ne tient pas en selle (sur une monture/un véhicule)', 'لمن لا يثبت على الدابة',
    'Für den, der sich nicht auf dem Reittier/Fahrzeug halten kann', 'Voor wie zich niet staande kan houden op een rijdier/voertuig', 'Bineğinde/araçta sabit duramayan kimse için',
    'Untuk orang yang tidak dapat tegak di atas kendaraan', 'Untuk orang yang tidak dapat tetap di atas tunggangan/kenderaan', 'جو سواری پر ثابت نہ رہ سکے اس کے لیے',
    'যে বাহনে স্থির থাকতে পারে না তার জন্য', 'Для того, кто не может удержаться на верховом животном/транспорте',
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
where s.title_en = 'Travel & transit'
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
  and s.title_en = 'Travel & transit';

-- 4c) Reference for Latin-script languages: collection names stay romanised
-- (NULL references for #4/#9 propagate as NULL).
update public.adhkars a
set
  reference_de = a.reference_en,
  reference_nl = a.reference_en,
  reference_tr = a.reference_en,
  reference_id = a.reference_en,
  reference_ms = a.reference_en
from public.adhkar_subcategories s
where a.adhkar_subcategory_id = s.id
  and s.title_en = 'Travel & transit';

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
  -- 1. When travelling
  ('Subḥānaka innī ẓalamtu nafsī, fa-ghfir lī, fa-innahu lā yaghfiru-dh-dhunūba illā ant.',
   'سُبْحَانَکَ اِنِّیْ ظَلَمْتُ نَفْسِیْ، فَاغْفِرْ لِیْ، فَاِنَّہٗ لَا یَغْفِرُ الذُّنُوْبَ اِلَّا اَنْتَ۔',
   'সুবহানাকা ইন্নী যালামতু নাফসী, ফাগফির লী, ফাইন্নাহূ লা ইয়াগফিরুয যুনূবা ইল্লা আনতা।',
   'Субханака инни заламту нафси, фа-гфир ли, фа-иннаху ля ягфиру-з-зунуба илля ант.',
   'ترمذی 3446', 'তিরমিযী 3446', 'ат-Тирмизи 3446'),
  -- 2. Upon returning from travel
  ('Āyibūna, tā''ibūna, ʿābidūna, li-Rabbinā ḥāmidūn.',
   'آئِبُوْنَ، تَائِبُوْنَ، عَابِدُوْنَ، لِرَبِّنَا حَامِدُوْنَ۔',
   'আয়িবূনা, তায়িবূনা, আবিদূনা, লিরাব্বিনা হামিদূন।',
   'Айибуна, таибуна, ’абидуна, ли-Раббина хамидун.',
   'مسلم 1342', 'মুসলিম 1342', 'Муслим 1342'),
  -- 3. When stopping at a place
  ('Aʿūdhu bi-kalimāti-llāhi-t-tāmmāti min sharri mā khalaq.',
   'اَعُوْذُ بِکَلِمَاتِ اللہِ التَّامَّاتِ مِنْ شَرِّ مَا خَلَقَ۔',
   'আঊযু বিকালিমাতিল্লাহিত তাম্মাতি মিন শাররি মা খালাক।',
   'А’узу би-калимати-Лляхи-т-таммати мин шарри ма халяк.',
   'مسلم 2708', 'মুসলিম 2708', 'Муслим 2708'),
  -- 4. When entering upon one's family (reference left NULL)
  ('Tawban tawban, li-Rabbinā awban, lā yughādiru ʿalaynā ḥūban.',
   'تَوْبًا تَوْبًا، لِرَبِّنَا اَوْبًا، لَا یُغَادِرُ عَلَیْنَا حَوْبًا۔',
   'তাওবান তাওবান, লিরাব্বিনা আওবান, লা ইউগাদিরু আলাইনা হাওবা।',
   'Таубан таубан, ли-Раббина аубан, ля югадиру ’аляйна хубан.',
   NULL, NULL, NULL),
  -- 5. The traveller's du'a for those staying behind
  ('Astawdiʿukumu-llāha-l-ladhī lā taḍīʿu wadā''iʿuh.',
   'اَسْتَوْدِعُکُمُ اللہَ الَّذِیْ لَا تَضِیْعُ وَدَائِعُہٗ۔',
   'আসতাওদিউকুমুল্লাহাল্লাযী লা তাদীউ ওয়াদাইউহ।',
   'Астауди’укуму-Ллаха-ллязи ля тады’у вадаи’ух.',
   'ابن ماجہ 2825', 'ইবনে মাজাহ 2825', 'Ибн Маджа 2825'),
  -- 6. Du'a for one setting out #1
  ('Astawdiʿu-llāha dīnaka, wa amānataka, wa khawātīma ʿamalik.',
   'اَسْتَوْدِعُ اللہَ دِیْنَکَ، وَاَمَانَتَکَ، وَخَوَاتِیْمَ عَمَلِکَ۔',
   'আসতাওদিউল্লাহা দীনাকা, ওয়া আমানাতাকা, ওয়া খাওয়াতীমা আমালিক।',
   'Астауди’у-Ллаха динака, ва аманатака, ва хаватима ’амалик.',
   'ترمذی 3443', 'তিরমিযী 3443', 'ат-Тирмизи 3443'),
  -- 7. Du'a for one setting out #2
  ('Zawwadaka-llāhu-t-taqwā, wa ghafara dhanbaka, wa yassara laka-l-khayra ḥaythumā kunt.',
   'زَوَّدَکَ اللہُ التَّقْوٰی، وَغَفَرَ ذَنْبَکَ، وَیَسَّرَ لَکَ الْخَیْرَ حَیْثُمَا کُنْتَ۔',
   'যাওয়াদাকাল্লাহুত তাকওয়া, ওয়া গাফারা যানবাকা, ওয়া ইয়াসসারা লাকাল খাইরা হাইছুমা কুনতা।',
   'Заввадака-Ллаху-т-таква, ва гафара занбака, ва яссара ляка-ль-хайра хайсума кунт.',
   'ترمذی 3444', 'তিরমিযী 3444', 'ат-Тирмизи 3444'),
  -- 8. Du'a for one setting out #3
  ('Allāhumma-ṭwi lahu-l-arḍa wa hawwin ʿalayhi-s-safar.',
   'اَللّٰھُمَّ اطْوِ لَہُ الْاَرْضَ وَھَوِّنْ عَلَیْہِ السَّفَرَ۔',
   'আল্লাহুম্মাতবি লাহুল আরদা ওয়া হাওবিন আলাইহিস সাফার।',
   'Аллахумма-тви ляху-ль-арда ва хаввин ’аляйхи-с-сафар.',
   'ترمذی 3445', 'তিরমিযী 3445', 'ат-Тирмизи 3445'),
  -- 9. For one who cannot stay steady (reference left NULL)
  ('Allāhumma thabbithu wa-jʿalhu hādiyan mahdiyyan.',
   'اَللّٰھُمَّ ثَبِّتْہُ وَاجْعَلْہُ ھَادِیًا مَّھْدِیًّا۔',
   'আল্লাহুম্মা ছাব্বিতহু ওয়াজআলহু হাদিয়াম মাহদিইয়া।',
   'Аллахумма саббитху ва-дж’альху хадиян махдиййан.',
   NULL, NULL, NULL)
) as m(tr_key, t_ur, t_bn, t_ru, r_ur, r_bn, r_ru)
where a.adhkar_subcategory_id = s.id
  and s.title_en = 'Travel & transit'
  and a.transcription_en = m.tr_key;
