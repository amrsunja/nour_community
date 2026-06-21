-- =============================================================================
-- 40 Hadith Nawawi — Hadith 9: "Obligation only within capacity"
-- Target collection: public.hadith_collections.id = 2  /  position = 9
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
  'Obligation within one''s capacity',
  'La prise en charge de ce qui est supportable',
  'التكليف بما يُستطاع',
  'Verpflichtung nach Vermögen',
  'Verplichting naar vermogen',
  'Güç yetenle mükellef olmak',
  'Pembebanan sesuai kemampuan',
  'استطاعت کے مطابق تکلیف',
  'সাধ্যের মধ্যে দায়িত্ব',
  'Pembebanan mengikut kemampuan',
  'Возложение лишь посильного',
  -- arabic_text
  'عَنْ أَبِي هُرَيْرَةَ عَبْدِ الرَّحْمَنِ بْنِ صَخْرٍ رَضِيَ اللَّهُ عَنْهُ قَالَ: سَمِعْتُ رَسُولَ اللَّهِ صَلَّى اللَّهُ عَلَيْهِ وَسَلَّمَ يَقُولُ: «مَا نَهَيْتُكُمْ عَنْهُ فَاجْتَنِبُوهُ، وَمَا أَمَرْتُكُمْ بِهِ فَأْتُوا مِنْهُ مَا اسْتَطَعْتُمْ، فَإِنَّمَا أَهْلَكَ الَّذِينَ مِنْ قَبْلِكُمْ كَثْرَةُ مَسَائِلِهِمْ وَاخْتِلَافُهُمْ عَلَى أَنْبِيَائِهِمْ»',
  -- transcription
  'ʿan Abī Hurayrata ʿAbdi r-Raḥmāni bni Ṣakhrin raḍiya Llāhu ʿanhu qāla: samiʿtu Rasūla Llāhi ṣalla Llāhu ʿalayhi wa-sallama yaqūlu: mā nahaytukum ʿanhu fa-jtanibūhu, wa-mā amartukum bihi fa-ʾtū minhu mā staṭaʿtum, fa-innamā ahlaka lladhīna min qablikum kathratu masāʾilihim wa-khtilāfuhum ʿalā anbiyāʾihim.',
  'ʿan Abî Hourayrata ʿAbdi r-Rahmâni bni Sakhrin (radia Llâhou ʿanhou) qâla : samiʿtou Rassôla Llâhi (salla Llâhou ʿalayhi wa sallam) yaqôlou : mâ nahaytoukoum ʿanhou fa-jtanibôhou, wa mâ amartoukoum bihi fa-ʾtô minhou mâ stataʿtoum, fa-innamâ ahlaka lladhîna min qablikoum kathratou masâʾilihim wa khtilâfouhoum ʿalâ anbiyâʾihim.',
  'ʿan Abī Hurairata ʿAbdi r-Rahmāni bni Sachrin (radiya Llāhu ʿanhu) qāla: samiʿtu Rasūla Llāhi (salla Llāhu ʿalaihi wa-sallam) jaqūlu: mā nahaitukum ʿanhu fa-dschtanibūhu, wa-mā amartukum bihi fa-ʾtū minhu mā stataʿtum, fa-innamā ahlaka lladhīna min qablikum kathratu masāʾilihim wa-chtilāfuhum ʿalā anbijāʾihim.',
  'ʿan Abie Hoerairata ʿAbdi r-Rahmaani bni Sachrin (radia Llaahoe ʿanhoe) qaala: samiʿtoe Rasoela Llaahi (salla Llaahoe ʿalaihi wa-sallam) jaqoeloe: maa nahaitoekoem ʿanhoe fa-dzjtanieboehoe, wa-maa amartoekoem bihi fa-ʾtoe minhoe maa stataʿtoem, fa-innamaa ahlaka lladhiena min qablikoem kathratoe masaaʾilihim wa-chtilaafoehoem ʿalaa anbijaaʾihim.',
  'an Ebû Hüreyre Abdurrahman ibn Sahr''dan (radıyallâhu anh) rivayetle dedi ki: Resûlullah''ın (s.a.v.) şöyle dediğini işittim: mâ neheytukum anhu fe''ctenibûhu, ve mâ emertukum bihî fe''tû minhu mâ''stetaʿtum, fe-innemâ ehleke''llezîne min kablikum kesretu mesâilihim ve''htilâfuhum alâ enbiyâihim.',
  'ʿan Abī Hurairah ʿAbdir-Rahmān bin Shakhr (radhiyallāhu ʿanhu) berkata: aku mendengar Rasulullah (shallallāhu ʿalaihi wa sallam) bersabda: mā nahaitukum ʿanhu fajtanibūhu, wa mā amartukum bihi faʾtū minhu mastathaʿtum, fa-innamā ahlakalladzīna min qablikum katsratu masāʾilihim wakhtilāfuhum ʿalā anbiyāʾihim.',
  'ابو ہریرہ عبد الرحمن بن صخر رضی اللہ عنہ سے روایت ہے، انہوں نے کہا: میں نے رسول اللہ صلی اللہ علیہ وسلم کو فرماتے سنا: ما نَہَیتُکُم عَنہُ فَاجتَنِبُوہُ، وَما اَمَرتُکُم بِہِ فَأتُوا مِنہُ مَا استَطَعتُم، فَاِنَّما اَہلَکَ الَّذِینَ مِن قَبلِکُم کَثرَۃُ مَسائِلِہِم وَاختِلافُہُم عَلٰی اَنبِیائِہِم۔',
  'আবু হুরায়রা আবদুর রহমান ইবনে সাখর (রাদিয়াল্লাহু আনহু) থেকে বর্ণিত, তিনি বলেন: আমি রাসূলুল্লাহ (সাল্লাল্লাহু আলাইহি ওয়া সাল্লাম)-কে বলতে শুনেছি: মা নাহাইতুকুম আনহু ফাজতানিবূহু, ওয়া মা আমারতুকুম বিহি ফাʾতূ মিনহু মাসতাতাʿতুম, ফাইন্নামা আহলাকাল্লাযীনা মিন কাবলিকুম কাসরাতু মাসাইলিহিম ওয়াখতিলাফুহুম আলা আম্বিয়াইহিম।',
  'ʿan Abī Hurairah ʿAbdir-Rahmān bin Sakhr (radhiallāhu ʿanhu) berkata: aku mendengar Rasulullah (sallallāhu ʿalaihi wa sallam) bersabda: mā nahaitukum ʿanhu fajtanibūhu, wa mā amartukum bihi faʾtū minhu mastatoʿtum, fa-innamā ahlakalladzīna min qablikum katsratu masāʾilihim wakhtilāfuhum ʿalā anbiyāʾihim.',
  'Ан Аби Хурайра Абдиррахман ибн Сахр (да будет доволен им Аллах) сказал: я слышал, как Посланник Аллаха ﷺ говорил: ма нахайтукум анху фа-джтанибуху, ва ма амартукум бихи фа-ʾту минху ма стататум, фа-иннама ахлака ллязина мин каблику касрату масаʾилихим ва-хтилафухум аля анбияʾихим.',
  -- translation
  'On the authority of Abu Hurayra ʿAbd ar-Rahman ibn Sakhr (may Allah be pleased with him), I heard the Messenger of Allah ﷺ say: "What I have forbidden you, avoid it; and what I have commanded you, do of it as much as you are able. For those before you were destroyed only by their excessive questioning and their disagreement with their prophets."',
  'D''après Abû Hurayra ʿAbd ar-Rahman ibn Sakhr (qu''Allah l''agrée), j''ai entendu l''Envoyé d''Allah ﷺ dire : « Ce que je vous ai interdit, évitez-le ; et ce que je vous ai ordonné, accomplissez-en autant que vous le pouvez. Car ceux qui vous ont précédés n''ont péri que par l''abondance de leurs questions et leurs divergences à l''égard de leurs prophètes. »',
  'Nach Abu Hurayra ʿAbd ar-Rahman ibn Sakhr (möge Allah mit ihm zufrieden sein) hörte ich den Gesandten Allahs ﷺ sagen: „Was ich euch verboten habe, das meidet; und was ich euch geboten habe, davon tut so viel, wie ihr vermögt. Denn diejenigen vor euch wurden nur durch ihre vielen Fragen und ihre Uneinigkeit gegenüber ihren Propheten zugrunde gerichtet."',
  'Op gezag van Abu Hurayra ʿAbd ar-Rahman ibn Sakhr (moge Allah tevreden met hem zijn) hoorde ik de Boodschapper van Allah ﷺ zeggen: „Wat ik jullie verboden heb, mijd het; en wat ik jullie geboden heb, doe daarvan zoveel als jullie kunnen. Want zij die vóór jullie waren, gingen slechts ten onder door hun overvloed aan vragen en hun onenigheid met hun profeten."',
  'Ebû Hüreyre Abdurrahman ibn Sahr''dan (Allah ondan razı olsun): Resûlullah''ın ﷺ şöyle buyurduğunu işittim: „Size yasakladığım şeyden kaçının; size emrettiğim şeyi de gücünüz yettiğince yapın. Çünkü sizden öncekileri ancak çok soru sormaları ve peygamberlerine karşı görüş ayrılığına düşmeleri helâk etmiştir."',
  'Dari Abu Hurairah Abdurrahman bin Shakhr (semoga Allah meridhainya), aku mendengar Rasulullah ﷺ bersabda: "Apa yang aku larang bagi kalian maka jauhilah, dan apa yang aku perintahkan kepada kalian maka kerjakanlah semampu kalian. Sesungguhnya yang membinasakan orang-orang sebelum kalian hanyalah banyaknya pertanyaan mereka dan perselisihan mereka terhadap nabi-nabi mereka."',
  'ابو ہریرہ عبد الرحمن بن صخر رضی اللہ عنہ سے روایت ہے، میں نے رسول اللہ ﷺ کو فرماتے سنا: ”میں نے تمہیں جس چیز سے منع کیا ہے اس سے بچو، اور جس چیز کا حکم دیا ہے اسے اپنی استطاعت کے مطابق بجا لاؤ۔ کیونکہ تم سے پہلے لوگوں کو صرف ان کے کثرتِ سوال اور اپنے انبیاء کے ساتھ اختلاف نے ہلاک کیا۔“',
  'আবু হুরায়রা আবদুর রহমান ইবনে সাখর (রাদিয়াল্লাহু আনহু) থেকে বর্ণিত, আমি রাসূলুল্লাহ ﷺ-কে বলতে শুনেছি: "আমি তোমাদের যা থেকে নিষেধ করেছি তা পরিহার করো, আর যা আদেশ করেছি তা তোমাদের সাধ্য অনুযায়ী সম্পাদন করো। কারণ তোমাদের পূর্ববর্তীদের ধ্বংস করেছে কেবল তাদের অধিক প্রশ্ন এবং তাদের নবীগণের সাথে মতবিরোধ।"',
  'Daripada Abu Hurairah Abdul Rahman bin Sakhr (semoga Allah meredainya), aku mendengar Rasulullah ﷺ bersabda: "Apa yang aku larang ke atas kamu maka jauhilah, dan apa yang aku perintahkan kepada kamu maka kerjakanlah sekadar kemampuan kamu. Sesungguhnya yang membinasakan orang-orang sebelum kamu hanyalah banyaknya pertanyaan mereka dan perselisihan mereka terhadap nabi-nabi mereka."',
  'Со слов Абу Хурайры ʿАбд ар-Рахмана ибн Сахра (да будет доволен им Аллах): Я слышал, как Посланник Аллаха ﷺ сказал: «То, что я вам запретил, — избегайте этого; а то, что я вам повелел, — исполняйте по мере ваших возможностей. Поистине, живших до вас погубили лишь множество их вопросов и их разногласия со своими пророками».',
  -- reference
  'Sahih — reported by Al-Bukhari (13/7288) and Muslim (no. 1337)',
  'Hadith authentique rapporté par Al-Bukhari (13/7288) et Muslim (n°1337)',
  'حديث صحيح، رواه البخاري (١٣/٧٢٨٨) ومسلم (رقم ١٣٣٧)',
  'Sahih — überliefert von Al-Bukhari (13/7288) und Muslim (Nr. 1337)',
  'Sahih — overgeleverd door Al-Bukhari (13/7288) en Muslim (nr. 1337)',
  'Sahih — Buhârî (13/7288) ve Müslim (no. 1337) rivayet etmiştir',
  'Hadis sahih, diriwayatkan oleh Al-Bukhari (13/7288) dan Muslim (no. 1337)',
  'صحیح حدیث، اسے بخاری (۱۳/۷۲۸۸) اور مسلم (نمبر ۱۳۳۷) نے روایت کیا',
  'সহীহ হাদীস — বুখারী (১৩/৭২৮৮) ও মুসলিম (নং ১৩৩৭) বর্ণনা করেছেন',
  'Hadis sahih, diriwayatkan oleh Al-Bukhari (13/7288) dan Muslim (no. 1337)',
  'Достоверный хадис, передали аль-Бухари (13/7288) и Муслим (№ 1337)',
  -- tafsir
  'Everything the Prophet ﷺ forbade must be avoided, for refraining from a forbidden act is easier than carrying out an act commanded by the religion. As for the command, the Prophet ﷺ said: "When I command you to do something, do it as much as you are able." For a commanded act may be difficult to perform; that is why the Prophet ﷺ set the following restriction: "do of it as much as you are able."',
  'Tout ce que le Prophète ﷺ a interdit doit être évité, car s''abstenir d''un acte interdit est plus facile que d''accomplir un acte ordonné par la religion. À propos de l''ordre, le Prophète ﷺ a dit : « Quand je vous ordonne de faire quelque chose, faites-le dans la mesure de vos possibilités. » La chose ordonnée est en effet un acte qui peut être difficile à accomplir ; c''est pourquoi le Prophète ﷺ a posé la restriction suivante : « faites-en autant que cela vous est possible ».',
  'كل ما نهى عنه النبي صلى الله عليه وسلم يجب اجتنابه، لأن الكف عن الفعل المنهي عنه أيسر من فعل المأمور به في الدين. وأما الأمر فقد قال النبي صلى الله عليه وسلم: «إذا أمرتكم بشيء فأتوا منه ما استطعتم». فالمأمور به قد يكون فعلاً يشق القيام به، ولذلك وضع النبي صلى الله عليه وسلم القيد التالي: «فأتوا منه ما استطعتم».',
  'Alles, was der Prophet ﷺ verboten hat, muss gemieden werden, denn das Unterlassen einer verbotenen Handlung ist leichter als das Ausführen einer von der Religion gebotenen Handlung. Was das Gebot betrifft, sagte der Prophet ﷺ: „Wenn ich euch etwas gebiete, so tut davon, wie ihr vermögt." Denn eine gebotene Handlung kann schwer auszuführen sein; deshalb setzte der Prophet ﷺ die folgende Einschränkung: „tut davon so viel, wie ihr vermögt."',
  'Alles wat de Profeet ﷺ heeft verboden, moet gemeden worden, want het zich onthouden van een verboden daad is gemakkelijker dan het verrichten van een door de religie geboden daad. Wat het gebod betreft, zei de Profeet ﷺ: „Wanneer ik jullie iets gebied, doe daarvan zoveel als jullie kunnen." Want een geboden daad kan moeilijk te verrichten zijn; daarom stelde de Profeet ﷺ de volgende beperking: „doe daarvan zoveel als jullie kunnen."',
  'Peygamber''in ﷺ yasakladığı her şeyden kaçınmak gerekir, çünkü yasaklanan bir fiilden uzak durmak, dinde emredilen bir fiili yerine getirmekten daha kolaydır. Emre gelince, Peygamber ﷺ şöyle buyurdu: „Size bir şey emrettiğimde, gücünüz yettiğince onu yapın." Zira emredilen şey, yerine getirilmesi zor olabilecek bir fiildir; bu yüzden Peygamber ﷺ şu kaydı koymuştur: „gücünüz yettiğince onu yapın."',
  'Segala yang dilarang oleh Nabi ﷺ wajib dijauhi, karena meninggalkan perbuatan yang dilarang lebih mudah daripada melaksanakan perbuatan yang diperintahkan dalam agama. Adapun perintah, Nabi ﷺ bersabda: "Apabila aku memerintahkan kalian sesuatu, maka kerjakanlah semampu kalian." Sebab perkara yang diperintahkan bisa jadi merupakan amal yang sulit dilaksanakan; karena itulah Nabi ﷺ meletakkan batasan berikut: "kerjakanlah semampu kalian."',
  'نبی ﷺ نے جس چیز سے منع فرمایا اس سے بچنا واجب ہے، کیونکہ کسی منع کردہ کام سے رک جانا، دین میں کسی مامور کام کو انجام دینے سے آسان ہے۔ رہا حکم تو نبی ﷺ نے فرمایا: ”جب میں تمہیں کسی چیز کا حکم دوں تو اسے اپنی استطاعت کے مطابق بجا لاؤ۔“ کیونکہ مامور کام بعض اوقات ایسا فعل ہوتا ہے جس کی ادائیگی دشوار ہوتی ہے، اسی لیے نبی ﷺ نے یہ قید لگائی: ”اسے اپنی استطاعت کے مطابق بجا لاؤ۔“',
  'নবী ﷺ যা থেকে নিষেধ করেছেন তা পরিহার করা ওয়াজিব, কারণ নিষিদ্ধ কাজ থেকে বিরত থাকা দ্বীনে আদিষ্ট কাজ সম্পাদন করার চেয়ে সহজ। আর আদেশের ব্যাপারে নবী ﷺ বলেছেন: "যখন আমি তোমাদের কোনো কিছুর আদেশ দিই, তখন তা তোমাদের সাধ্য অনুযায়ী সম্পাদন করো।" কারণ আদিষ্ট কাজ কখনও এমন আমল হয় যা সম্পাদন করা কঠিন; এজন্যই নবী ﷺ এই শর্ত আরোপ করেছেন: "তা তোমাদের সাধ্য অনুযায়ী সম্পাদন করো।"',
  'Segala yang dilarang oleh Nabi ﷺ wajib dijauhi, kerana meninggalkan perbuatan yang dilarang lebih mudah daripada melaksanakan perbuatan yang diperintahkan dalam agama. Adapun perintah, Nabi ﷺ bersabda: "Apabila aku memerintahkan kamu sesuatu, maka kerjakanlah sekadar kemampuan kamu." Kerana perkara yang diperintahkan mungkin merupakan amalan yang sukar dilaksanakan; itulah sebabnya Nabi ﷺ meletakkan batasan berikut: "kerjakanlah sekadar kemampuan kamu."',
  'Всё, что запретил Пророк ﷺ, должно быть оставлено, ибо воздержаться от запретного деяния легче, чем совершить деяние, повелённое религией. Что же касается повеления, Пророк ﷺ сказал: «Когда я повелеваю вам что-либо, исполняйте это по мере ваших возможностей». Ведь повелённое деяние может быть трудным для исполнения; поэтому Пророк ﷺ установил следующее ограничение: «исполняйте из него столько, сколько можете».',
  -- audio_url, ajr, position
  'https://www.40-hadith-nawawi.com/wp-content/uploads/2022/08/Hadith-9-Nawawi-Psalmodie-Arabe.mp3',
  5,
  9
where not exists (
  select 1 from public.hadiths
  where hadith_collection_id = 2 and position = 9
);
