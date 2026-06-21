-- =============================================================================
-- 40 Hadith Nawawi — Hadith 16: "Do not become angry"
-- Target collection: public.hadith_collections.id = 2  /  position = 16
-- Idempotent guard on (collection, position). All 11 content languages.
-- =============================================================================

insert into public.hadiths (
  hadith_collection_id,
  title_en, title_fr, title_ar, title_de, title_nl, title_tr, title_id, title_ur, title_bn, title_ms, title_ru,
  arabic_text,
  transcription_en, transcription_fr, transcription_de, transcription_nl, transcription_tr,
  transcription_id, transcription_ur, transcription_bn, transcription_ms, transcription_ru,
  translation_en, translation_fr, translation_de, translation_nl, translation_tr,
  translation_id, translation_ur, translation_bn, translation_ms, translation_ru,
  reference_en, reference_fr, reference_ar, reference_de, reference_nl, reference_tr,
  reference_id, reference_ur, reference_bn, reference_ms, reference_ru,
  tafsir_en, tafsir_fr, tafsir_ar, tafsir_de, tafsir_nl, tafsir_tr,
  tafsir_id, tafsir_ur, tafsir_bn, tafsir_ms, tafsir_ru,
  audio_url, ajr, position
)
select
  2,
  -- title
  'Do not become angry',
  'Se départir de la colère',
  'النهي عن الغضب',
  'Werde nicht zornig',
  'Word niet boos',
  'Öfkelenme',
  'Larangan marah',
  'غصہ نہ کرنا',
  'রাগ করো না',
  'Larangan marah',
  'Запрет на гнев',
  -- arabic_text
  'عَنْ أَبِي هُرَيْرَةَ رَضِيَ اللَّهُ عَنْهُ أَنَّ رَجُلًا قَالَ لِلنَّبِيِّ صَلَّى اللَّهُ عَلَيْهِ وَسَلَّمَ: أَوْصِنِي. قَالَ: «لَا تَغْضَبْ». فَرَدَّدَ مِرَارًا، قَالَ: «لَا تَغْضَبْ»',
  -- transcription
  'ʿan Abī Hurayrata raḍiya Llāhu ʿanhu anna rajulan qāla li-n-Nabiyyi ṣalla Llāhu ʿalayhi wa-sallama: awṣinī. qāla: lā taghḍab. fa-raddada mirāran, qāla: lā taghḍab.',
  'ʿan Abî Hourayrata (radia Llâhou ʿanhou) anna rajoulan qâla li-n-Nabiyyi (salla Llâhou ʿalayhi wa sallam) : awsinî. qâla : lâ taghdab. fa-raddada mirâran, qâla : lâ taghdab.',
  'ʿan Abī Hurairata (radiya Llāhu ʿanhu) anna radschulan qāla li-n-Nabijji (salla Llāhu ʿalaihi wa-sallam): ausinī. qāla: lā taghdab. fa-raddada mirāran, qāla: lā taghdab.',
  'ʿan Abie Hoerairata (radia Llaahoe ʿanhoe) anna radzjoelan qaala li-n-Nabijji (salla Llaahoe ʿalaihi wa-sallam): ausinie. qaala: laa taghdab. fa-raddada miraaran, qaala: laa taghdab.',
  'an Ebû Hüreyre''den (radıyallâhu anh) rivayetle bir adam Nebî''ye (s.a.v.) dedi ki: bana tavsiyede bulun. Buyurdu: lâ tagdab (öfkelenme). Adam birkaç kez tekrarladı, (Peygamber) yine: lâ tagdab, dedi.',
  'ʿan Abī Hurairah (radhiyallāhu ʿanhu) bahwa seorang lelaki berkata kepada Nabi (shallallāhu ʿalaihi wa sallam): ausinī (berilah aku wasiat). Beliau bersabda: lā taghdhab (jangan marah). Lelaki itu mengulanginya beberapa kali, beliau tetap berkata: lā taghdhab.',
  'ابو ہریرہ رضی اللہ عنہ سے روایت ہے کہ ایک شخص نے نبی صلی اللہ علیہ وسلم سے کہا: مجھے کوئی وصیت کیجیے۔ آپ نے فرمایا: لا تَغضَب (غصہ نہ کرو)۔ اس نے کئی بار دہرایا، آپ نے (ہر بار) فرمایا: لا تَغضَب۔',
  'আবু হুরায়রা (রাদিয়াল্লাহু আনহু) থেকে বর্ণিত, এক ব্যক্তি নবী (সাল্লাল্লাহু আলাইহি ওয়া সাল্লাম)-কে বলল: আমাকে কোনো উপদেশ দিন। তিনি বললেন: লা তাগদাব (রাগ করো না)। লোকটি কয়েকবার পুনরাবৃত্তি করল, তিনি (প্রতিবার) বললেন: লা তাগদাব।',
  'ʿan Abī Hurairah (radhiallāhu ʿanhu) bahawa seorang lelaki berkata kepada Nabi (sallallāhu ʿalaihi wa sallam): ausinī (berilah aku wasiat). Baginda bersabda: lā taghdhab (jangan marah). Lelaki itu mengulanginya beberapa kali, baginda tetap berkata: lā taghdhab.',
  'Ан Аби Хурайра (да будет доволен им Аллах), что один человек сказал Пророку ﷺ: дай мне наставление. Он сказал: ля тагдаб (не гневайся). Тот повторил несколько раз, (Пророк каждый раз) говорил: ля тагдаб.',
  -- translation
  'On the authority of Abu Hurayra (may Allah be pleased with him): A man said to the Prophet ﷺ: "Advise me." He said: "Do not become angry." The man repeated his request several times, and each time he said: "Do not become angry."',
  'D''après Abû Hurayra (qu''Allah l''agrée) : Un homme dit au Prophète ﷺ : « Fais-moi une recommandation. » Il répondit : « Ne te mets pas en colère. » L''homme répéta plusieurs fois sa demande, et à chaque fois il lui disait : « Ne te mets pas en colère. »',
  'Nach Abu Hurayra (möge Allah mit ihm zufrieden sein): Ein Mann sagte zum Propheten ﷺ: „Gib mir eine Ermahnung." Er sagte: „Werde nicht zornig." Der Mann wiederholte seine Bitte mehrmals, und jedes Mal sagte er: „Werde nicht zornig."',
  'Op gezag van Abu Hurayra (moge Allah tevreden met hem zijn): Een man zei tegen de Profeet ﷺ: „Geef mij een vermaning." Hij zei: „Word niet boos." De man herhaalde zijn verzoek meerdere keren, en telkens zei hij: „Word niet boos."',
  'Ebû Hüreyre''den (Allah ondan razı olsun): Bir adam Peygamber''e ﷺ: „Bana tavsiyede bulun" dedi. Buyurdu: „Öfkelenme." Adam isteğini birkaç kez tekrarladı, her seferinde: „Öfkelenme" dedi.',
  'Dari Abu Hurairah (semoga Allah meridhainya): Seorang lelaki berkata kepada Nabi ﷺ: "Berilah aku wasiat." Beliau bersabda: "Janganlah engkau marah." Lelaki itu mengulangi permintaannya beberapa kali, dan setiap kali beliau bersabda: "Janganlah engkau marah."',
  'ابو ہریرہ رضی اللہ عنہ سے روایت ہے: ایک شخص نے نبی ﷺ سے کہا: ”مجھے کوئی نصیحت کیجیے۔“ آپ نے فرمایا: ”غصہ نہ کرو۔“ اس نے کئی بار اپنی درخواست دہرائی، اور ہر بار آپ نے فرمایا: ”غصہ نہ کرو۔“',
  'আবু হুরায়রা (রাদিয়াল্লাহু আনহু) থেকে বর্ণিত: এক ব্যক্তি নবী ﷺ-কে বলল: "আমাকে উপদেশ দিন।" তিনি বললেন: "রাগ করো না।" লোকটি কয়েকবার তার অনুরোধ পুনরাবৃত্তি করল, আর প্রতিবার তিনি বললেন: "রাগ করো না।"',
  'Daripada Abu Hurairah (semoga Allah meredainya): Seorang lelaki berkata kepada Nabi ﷺ: "Berilah aku wasiat." Baginda bersabda: "Janganlah engkau marah." Lelaki itu mengulangi permintaannya beberapa kali, dan setiap kali baginda bersabda: "Janganlah engkau marah."',
  'Со слов Абу Хурайры (да будет доволен им Аллах): Один человек сказал Пророку ﷺ: «Дай мне наставление». Он сказал: «Не гневайся». Тот человек повторил свою просьбу несколько раз, и каждый раз он говорил: «Не гневайся».',
  -- reference
  'Sahih — reported by Al-Bukhari (no. 6116), at-Tirmidhi (no. 2021), and Malik in al-Muwatta (2/362, 466)',
  'Hadith authentique rapporté par Al-Bukhari (n°6116), at-Tirmidhî (n°2021) et Mâlik dans « al-Muwatta » (2/362, 466)',
  'حديث صحيح، رواه البخاري (رقم ٦١١٦) والترمذي (رقم ٢٠٢١) ومالك في الموطأ (٢/٣٦٢، ٤٦٦)',
  'Sahih — überliefert von Al-Bukhari (Nr. 6116), at-Tirmidhi (Nr. 2021) und Malik im al-Muwatta (2/362, 466)',
  'Sahih — overgeleverd door Al-Bukhari (nr. 6116), at-Tirmidhi (nr. 2021) en Malik in al-Muwatta (2/362, 466)',
  'Sahih — Buhârî (no. 6116), Tirmizî (no. 2021) ve Mâlik el-Muvatta''da (2/362, 466) rivayet etmiştir',
  'Hadis sahih, diriwayatkan oleh Al-Bukhari (no. 6116), at-Tirmidzi (no. 2021), dan Malik dalam al-Muwatta (2/362, 466)',
  'صحیح حدیث، اسے بخاری (نمبر ۶۱۱۶)، ترمذی (نمبر ۲۰۲۱) اور مالک نے الموطأ میں (۲/۳۶۲، ۴۶۶) روایت کیا',
  'সহীহ হাদীস — বুখারী (নং ৬১১৬), তিরমিযী (নং ২০২১) ও মালিক আল-মুওয়াত্তায় (২/৩৬২, ৪৬৬) বর্ণনা করেছেন',
  'Hadis sahih, diriwayatkan oleh Al-Bukhari (no. 6116), at-Tirmizi (no. 2021), dan Malik dalam al-Muwatta (2/362, 466)',
  'Достоверный хадис, передали аль-Бухари (№ 6116), ат-Тирмизи (№ 2021) и Малик в «аль-Муватта» (2/362, 466)',
  -- tafsir
  'This man asked the Prophet ﷺ to give him an admonition, and he answered: "Do not become angry." He set aside the admonition of the fear of Allah (taqwa) — which Allah enjoined upon this community and upon those who received the Book before us — because he knew that this person was often prone to anger. What is intended by this hadith is not a prohibition of anger itself, for it is part of human nature; rather it aims at a person controlling himself when angry and not letting it explode. Anger, in fact, is an ember that Shaytan casts into the heart of the son of Adam; that is why his cheeks redden and the veins of his neck swell, and he may even become unaware of what he is doing, possibly committing acts with grave consequences that later become a source of great regret.',
  'Cet homme a demandé au Prophète ﷺ de lui faire une recommandation, et il lui a répondu : « Ne te mets pas en colère. » Il a laissé de côté la recommandation de la crainte d''Allah (taqwâ) — qu''Allah a prescrite à cette communauté et à ceux qui ont reçu le Livre avant nous — parce qu''il savait que cette personne se mettait souvent en colère. Ce qui est visé par ce hadith n''est pas l''interdiction de se mettre en colère, car c''est une nature de l''homme, mais que l''homme se contrôle lors de la colère et ne la laisse pas exploser. La colère, en effet, est une braise que Chaytân jette dans le cœur du fils d''Adam ; c''est pour cela que ses joues rougissent et que les veines de son cou gonflent, il devient même inconscient de ce qu''il fait, et peut commettre des actes aux répercussions graves qui seront ensuite sources de grands regrets.',
  'هذا الرجل سأل النبي صلى الله عليه وسلم أن يوصيه، فقال له: «لا تغضب». وترك الوصية بتقوى الله التي أوصى الله بها هذه الأمة وأوصى بها من أُوتي الكتاب من قبلنا، لأنه علم أن هذا الشخص كثير الغضب. والمقصود بهذا الحديث ليس تحريم الغضب نفسه، فإنه من طبيعة الإنسان، وإنما يقصد أن يملك الإنسان نفسه عند الغضب ولا يدعه ينفجر. والغضب في الحقيقة جمرة يلقيها الشيطان في قلب ابن آدم، ولذلك تحمرّ وجنتاه وتنتفخ أوداج عنقه، حتى إنه قد يغيب عن وعيه بما يفعل، وربما ارتكب أفعالاً وخيمة العواقب تكون بعد ذلك مصدر ندم عظيم.',
  'Dieser Mann bat den Propheten ﷺ um eine Ermahnung, und er antwortete ihm: „Werde nicht zornig." Er ließ die Ermahnung zur Gottesfurcht (Taqwa) — die Allah dieser Gemeinschaft und denen, die vor uns die Schrift erhielten, auferlegte — beiseite, weil er wusste, dass dieser Mensch oft zum Zorn neigte. Was dieser Hadith bezweckt, ist nicht ein Verbot des Zornes selbst, denn er gehört zur menschlichen Natur; vielmehr geht es darum, dass sich der Mensch im Zorn beherrscht und ihn nicht explodieren lässt. Der Zorn ist in Wahrheit eine Glut, die Schaitan in das Herz des Sohnes Adams wirft; deshalb röten sich seine Wangen und die Adern seines Halses schwellen an, und er kann sogar die Kontrolle über sein Handeln verlieren und Taten mit schweren Folgen begehen, die später eine Quelle großer Reue werden.',
  'Deze man vroeg de Profeet ﷺ om een vermaning, en hij antwoordde hem: „Word niet boos." Hij liet de vermaning tot godsvrees (taqwa) — die Allah deze gemeenschap en hen die vóór ons de Schrift ontvingen heeft opgelegd — terzijde, omdat hij wist dat deze persoon vaak tot woede geneigd was. Wat deze hadith beoogt, is niet een verbod op woede zelf, want die behoort tot de menselijke natuur; het gaat er veeleer om dat de mens zichzelf beheerst tijdens woede en haar niet laat ontploffen. Woede is in werkelijkheid een gloeiende kool die Sjaytan in het hart van de zoon van Adam werpt; daarom worden zijn wangen rood en zwellen de aderen van zijn hals op, en hij kan zelfs de controle over zijn handelen verliezen en daden begaan met ernstige gevolgen die later een bron van grote spijt worden.',
  'Bu adam Peygamber''den ﷺ kendisine bir tavsiyede bulunmasını istedi, o da: „Öfkelenme" buyurdu. Allah''ın bu ümmete ve bizden önce Kitap verilenlere emrettiği takvâ tavsiyesini bir kenara bıraktı, çünkü bu kişinin çok öfkelendiğini biliyordu. Bu hadisle kastedilen, öfkenin kendisinin haram kılınması değildir, zira o insan tabiatındandır; aksine kastedilen, kişinin öfke anında kendine hâkim olması ve öfkenin patlamasına izin vermemesidir. Öfke, gerçekte şeytanın âdemoğlunun kalbine attığı bir kordur; bu yüzden yanakları kızarır, boynunun damarları şişer, hatta ne yaptığının farkında olmayacak hâle gelir ve sonradan büyük pişmanlık kaynağı olacak vahim sonuçlu işler işleyebilir.',
  'Lelaki ini meminta Nabi ﷺ untuk memberinya wasiat, maka beliau menjawab: "Janganlah engkau marah." Beliau meninggalkan wasiat takwa kepada Allah — yang Allah perintahkan kepada umat ini dan kepada orang-orang yang diberi Kitab sebelum kita — karena beliau mengetahui bahwa orang ini sering marah. Yang dimaksud dengan hadis ini bukanlah pengharaman marah itu sendiri, karena ia termasuk tabiat manusia; melainkan yang dimaksud adalah agar seseorang menguasai dirinya ketika marah dan tidak membiarkannya meledak. Marah pada hakikatnya adalah bara yang dilemparkan setan ke dalam hati anak Adam; karena itulah kedua pipinya memerah dan urat-urat lehernya menggembung, bahkan ia bisa kehilangan kesadaran atas apa yang ia perbuat, dan mungkin melakukan perbuatan-perbuatan berakibat buruk yang kemudian menjadi sumber penyesalan yang besar.',
  'اس شخص نے نبی ﷺ سے درخواست کی کہ آپ اسے کوئی نصیحت فرمائیں، تو آپ نے فرمایا: ”غصہ نہ کرو۔“ آپ نے تقویٰ کی وصیت چھوڑ دی — جس کی اللہ نے اس امت کو اور ہم سے پہلے اہلِ کتاب کو وصیت کی تھی — کیونکہ آپ جانتے تھے کہ یہ شخص بہت غصہ کرتا ہے۔ اس حدیث کا مقصد خود غصے کی حرمت نہیں، کیونکہ یہ انسان کی فطرت ہے؛ بلکہ مقصد یہ ہے کہ آدمی غصے کے وقت اپنے آپ پر قابو رکھے اور اسے پھٹنے نہ دے۔ غصہ درحقیقت ایک انگارہ ہے جسے شیطان ابنِ آدم کے دل میں ڈالتا ہے؛ اسی لیے اس کے رخسار سرخ ہو جاتے ہیں اور گردن کی رگیں پھول جاتی ہیں، یہاں تک کہ وہ اپنے کیے سے بے خبر ہو جاتا ہے، اور ایسے سنگین نتائج والے کام کر بیٹھتا ہے جو بعد میں بڑے پچھتاوے کا سبب بنتے ہیں۔',
  'এই ব্যক্তি নবী ﷺ-এর কাছে তাকে কোনো উপদেশ দেওয়ার অনুরোধ করল, তিনি উত্তর দিলেন: "রাগ করো না।" তিনি আল্লাহভীতির (তাকওয়া) উপদেশ একপাশে রাখলেন — যা আল্লাহ এই উম্মতকে এবং আমাদের পূর্বে যারা কিতাব পেয়েছে তাদের নির্দেশ দিয়েছেন — কারণ তিনি জানতেন যে এই ব্যক্তি প্রায়ই রাগ করে। এই হাদীসের উদ্দেশ্য রাগ করাকেই হারাম করা নয়, কারণ তা মানুষের স্বভাবের অন্তর্ভুক্ত; বরং উদ্দেশ্য হলো মানুষ যেন রাগের সময় নিজেকে নিয়ন্ত্রণ করে এবং তা বিস্ফোরিত হতে না দেয়। রাগ মূলত একটি অঙ্গার যা শয়তান আদম সন্তানের অন্তরে নিক্ষেপ করে; এজন্যই তার গাল লাল হয়ে যায় ও ঘাড়ের রগ ফুলে ওঠে, এমনকি সে যা করছে তা সম্পর্কে অচেতন হয়ে যায়, এবং এমন গুরুতর পরিণতির কাজ করে ফেলতে পারে যা পরবর্তীতে বড় অনুশোচনার কারণ হয়।',
  'Lelaki ini meminta Nabi ﷺ untuk memberinya wasiat, maka baginda menjawab: "Janganlah engkau marah." Baginda meninggalkan wasiat takwa kepada Allah — yang Allah perintahkan kepada umat ini dan kepada orang-orang yang diberi Kitab sebelum kita — kerana baginda mengetahui bahawa orang ini kerap marah. Yang dimaksudkan dengan hadis ini bukanlah pengharaman marah itu sendiri, kerana ia termasuk tabiat manusia; sebaliknya yang dimaksudkan ialah agar seseorang menguasai dirinya ketika marah dan tidak membiarkannya meledak. Marah pada hakikatnya ialah bara yang dilemparkan syaitan ke dalam hati anak Adam; itulah sebabnya kedua-dua pipinya memerah dan urat-urat lehernya menggembung, bahkan dia boleh hilang kesedaran atas apa yang dilakukannya, dan mungkin melakukan perbuatan-perbuatan berakibat buruk yang kemudian menjadi sumber penyesalan yang besar.',
  'Этот человек попросил Пророка ﷺ дать ему наставление, и он ответил ему: «Не гневайся». Он оставил в стороне наставление о богобоязненности (таква) — которую Аллах заповедал этой общине и тем, кому было даровано Писание до нас, — потому что знал, что этот человек часто гневается. Целью этого хадиса не является запрет самого гнева, ибо он относится к человеческой природе; скорее, цель в том, чтобы человек владел собой во время гнева и не давал ему вырваться наружу. Гнев на самом деле — это уголёк, который Шайтан бросает в сердце сына Адама; поэтому щёки его краснеют, вены на шее вздуваются, и он может даже потерять осознание того, что делает, и совершить поступки с тяжкими последствиями, которые затем становятся источником великого сожаления.',
  -- audio_url, ajr, position
  'https://www.40-hadith-nawawi.com/wp-content/uploads/2022/08/Hadith-16-Nawawi-Psalmodie-Arabe.mp3',
  5,
  16
where not exists (
  select 1 from public.hadiths
  where hadith_collection_id = 2 and position = 16
);
