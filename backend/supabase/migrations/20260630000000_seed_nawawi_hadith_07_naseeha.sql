-- =============================================================================
-- 40 Hadith Nawawi — Hadith 7: "Religion is sincere advice (an-Nasiha)"
-- Target collection: public.hadith_collections.id = 2  /  position = 7
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
  'Religion is sincere advice',
  'La religion est le bon conseil',
  'الدين النصيحة',
  'Religion ist aufrichtiger Rat',
  'Religie is oprecht advies',
  'Din nasihattir',
  'Agama adalah nasihat',
  'دین خیر خواہی ہے',
  'দ্বীন হলো কল্যাণকামিতা',
  'Agama ialah nasihat',
  'Религия — это искренний совет',
  -- arabic_text
  'عَنْ أَبِي رُقَيَّةَ تَمِيمِ بْنِ أَوْسٍ الدَّارِيِّ رَضِيَ اللَّهُ عَنْهُ أَنَّ النَّبِيَّ صَلَّى اللَّهُ عَلَيْهِ وَسَلَّمَ قَالَ: «الدِّينُ النَّصِيحَةُ». قُلْنَا: لِمَنْ؟ قَالَ: «لِلَّهِ، وَلِكِتَابِهِ، وَلِرَسُولِهِ، وَلِأَئِمَّةِ الْمُسْلِمِينَ وَعَامَّتِهِمْ»',
  -- transcription
  'ʿan Abī Ruqayyata Tamīmi bni Awsin ad-Dāriyyi raḍiya Llāhu ʿanhu anna n-Nabiyya ṣalla Llāhu ʿalayhi wa-sallama qāla: ad-dīnu n-naṣīḥatu. qulnā: li-man? qāla: li-Llāhi, wa-li-kitābihi, wa-li-rasūlihi, wa-li-aʾimmati l-muslimīna wa-ʿāmmatihim.',
  'ʿan Abî Rouqayyata Tamîmi bni Awsin ad-Dâriyyi (radia Llâhou ʿanhou) anna n-Nabiyya (salla Llâhou ʿalayhi wa sallam) qâla : ad-dînou n-nasîhatou. qoulnâ : li-man ? qâla : li-Llâhi, wa li-kitâbihi, wa li-rassôlihi, wa li-aʾimmati l-mouslimîna wa ʿâmmatihim.',
  'ʿan Abī Ruqajjata Tamīmi bni Ausin ad-Dārijji (radiya Llāhu ʿanhu) anna n-Nabijja (salla Llāhu ʿalaihi wa-sallam) qāla: ad-dīnu n-nasīhatu. qulnā: li-man? qāla: li-Llāhi, wa-li-kitābihi, wa-li-rasūlihi, wa-li-aʾimmati l-muslimīna wa-ʿāmmatihim.',
  'ʿan Abie Roeqajjata Tamiemi bni Ausin ad-Daarijji (radia Llaahoe ʿanhoe) anna n-Nabijja (salla Llaahoe ʿalaihi wa-sallam) qaala: ad-dienoe n-nasiehatoe. qoelnaa: li-man? qaala: li-Llaahi, wa-li-kitaabihi, wa-li-rasoelihi, wa-li-aʾimmati l-moeslimiena wa-ʿaammatihim.',
  'an Ebû Rukayye Temîm ibn Evs ed-Dârî''den (radıyallâhu anh) rivayetle Nebî (s.a.v.) şöyle buyurdu: din nasihattir. Biz: kimin için? dedik. Buyurdu: Allah için, Kitabı için, Resûlü için, Müslümanların imamları ve geneli için.',
  'ʿan Abī Ruqayyah Tamīm bin Aus ad-Dārī (radhiyallāhu ʿanhu) bahwa Nabi (shallallāhu ʿalaihi wa sallam) bersabda: ad-dīnun-nashīhah. Kami bertanya: untuk siapa? Beliau menjawab: lillāhi, wa li-kitābihi, wa li-rasūlihi, wa li-aʾimmatil-muslimīna wa ʿāmmatihim.',
  'ابو رقیہ تمیم بن اوس الداری رضی اللہ عنہ سے روایت ہے کہ نبی صلی اللہ علیہ وسلم نے فرمایا: اَلدِّینُ النَّصِیحَۃُ۔ ہم نے کہا: کس کے لیے؟ فرمایا: لِلّٰہِ، وَلِکِتابِہِ، وَلِرَسُولِہِ، وَلِاَئِمَّۃِ المُسلِمِینَ وَعامَّتِہِم۔',
  'আবু রুকাইয়া তামীম ইবনে আউস আদ-দারী (রাদিয়াল্লাহু আনহু) থেকে বর্ণিত, নবী (সাল্লাল্লাহু আলাইহি ওয়া সাল্লাম) বলেছেন: আদ-দীনুন নাসীহাহ। আমরা বললাম: কার জন্য? তিনি বললেন: লিল্লাহি, ওয়া লিকিতাবিহি, ওয়া লিরাসূলিহি, ওয়া লিআইম্মাতিল মুসলিমীনা ওয়া আম্মাতিহিম।',
  'ʿan Abī Ruqayyah Tamīm bin Aus ad-Dārī (radhiallāhu ʿanhu) bahawa Nabi (sallallāhu ʿalaihi wa sallam) bersabda: ad-dīnun-nasīhah. Kami bertanya: untuk siapa? Baginda menjawab: lillāhi, wa li-kitābihi, wa li-rasūlihi, wa li-aʾimmatil-muslimīna wa ʿāmmatihim.',
  'Ан Аби Рукаййа Тамим ибн Аус ад-Дари (да будет доволен им Аллах), что Пророк ﷺ сказал: ад-дину н-насиха. Мы спросили: кому? Он сказал: ли-Лляхи, ва ли-китабихи, ва ли-расулихи, ва ли-аʾимматиль-муслимина ва аммати-хим.',
  -- translation
  'On the authority of Abu Ruqayya Tamim ibn Aws ad-Dari (may Allah be pleased with him), the Prophet ﷺ said: "Religion is sincere advice (nasiha)." We said: "To whom?" He said: "To Allah, to His Book, to His Messenger, to the leaders of the Muslims, and to their common folk."',
  'D''après Abû Ruqayya Tamîm ibn Aws ad-Dârî (qu''Allah l''agrée), le Prophète ﷺ a dit : « La religion est le bon conseil (nasîha). » On demanda : « Pour qui ? » Il répondit : « Pour Allah, pour Son Livre, pour Son Messager, pour les imams des musulmans et pour l''ensemble d''entre eux. »',
  'Nach Abu Ruqayya Tamim ibn Aws ad-Dari (möge Allah mit ihm zufrieden sein) sagte der Prophet ﷺ: „Die Religion ist aufrichtiger Rat (Nasiha)." Wir fragten: „Wem gegenüber?" Er sagte: „Allah gegenüber, Seinem Buch, Seinem Gesandten, den Führern der Muslime und ihrer Allgemeinheit."',
  'Op gezag van Abu Ruqayya Tamim ibn Aws ad-Dari (moge Allah tevreden met hem zijn) zei de Profeet ﷺ: „De religie is oprecht advies (nasiha)." Wij vroegen: „Aan wie?" Hij zei: „Aan Allah, aan Zijn Boek, aan Zijn Boodschapper, aan de leiders van de moslims en aan hun gewone mensen."',
  'Ebû Rukayye Temîm ibn Evs ed-Dârî''den (Allah ondan razı olsun) rivayet edildiğine göre Peygamber ﷺ şöyle buyurdu: „Din nasihattir." Biz: „Kimin için?" dedik. Buyurdu: „Allah için, Kitabı için, Resûlü için, Müslümanların imamları (önderleri) ve geneli için."',
  'Dari Abu Ruqayyah Tamim bin Aus ad-Dari (semoga Allah meridhainya), Nabi ﷺ bersabda: "Agama adalah nasihat." Kami bertanya: "Untuk siapa?" Beliau menjawab: "Untuk Allah, untuk Kitab-Nya, untuk Rasul-Nya, untuk para pemimpin kaum muslimin, dan untuk kaum muslimin pada umumnya."',
  'ابو رقیہ تمیم بن اوس الداری رضی اللہ عنہ سے روایت ہے کہ نبی ﷺ نے فرمایا: ”دین خیر خواہی (نصیحت) ہے۔“ ہم نے عرض کیا: ”کس کے لیے؟“ فرمایا: ”اللہ کے لیے، اس کی کتاب کے لیے، اس کے رسول کے لیے، مسلمانوں کے اماموں (حکمرانوں) کے لیے اور عام مسلمانوں کے لیے۔“',
  'আবু রুকাইয়া তামীম ইবনে আউস আদ-দারী (রাদিয়াল্লাহু আনহু) থেকে বর্ণিত, নবী ﷺ বলেছেন: "দ্বীন হলো কল্যাণকামিতা (নাসীহাহ)।" আমরা বললাম: "কার জন্য?" তিনি বললেন: "আল্লাহর জন্য, তাঁর কিতাবের জন্য, তাঁর রাসূলের জন্য, মুসলমানদের নেতৃবৃন্দের জন্য এবং সাধারণ মুসলমানদের জন্য।"',
  'Daripada Abu Ruqayyah Tamim bin Aus ad-Dari (semoga Allah meredainya), Nabi ﷺ bersabda: "Agama ialah nasihat." Kami bertanya: "Untuk siapa?" Baginda menjawab: "Untuk Allah, untuk Kitab-Nya, untuk Rasul-Nya, untuk para pemimpin kaum Muslimin, dan untuk kaum Muslimin amnya."',
  'Со слов Абу Рукаййи Тамима ибн Ауса ад-Дари (да будет доволен им Аллах) Пророк ﷺ сказал: «Религия — это искренний совет (насиха)». Мы спросили: «Кому?» Он сказал: «Аллаху, Его Книге, Его Посланнику, предводителям мусульман и простым мусульманам».',
  -- reference
  'Sahih — reported by Muslim (1/74)',
  'Hadith authentique rapporté par Muslim (1/74)',
  'حديث صحيح، رواه مسلم (١/٧٤)',
  'Sahih — überliefert von Muslim (1/74)',
  'Sahih — overgeleverd door Muslim (1/74)',
  'Sahih — Müslim (1/74) rivayet etmiştir',
  'Hadis sahih, diriwayatkan oleh Muslim (1/74)',
  'صحیح حدیث، اسے مسلم (۱/۷۴) نے روایت کیا',
  'সহীহ হাদীস — মুসলিম (১/৭৪) বর্ণনা করেছেন',
  'Hadis sahih, diriwayatkan oleh Muslim (1/74)',
  'Достоверный хадис, передал Муслим (1/74)',
  -- tafsir
  'Sincere advice towards Allah, the Exalted, also means sincere advice towards His religion: by fulfilling His commands, avoiding His prohibitions, accepting His reports as true, repenting to Him, relying upon Him, and so forth. Sincere advice towards His Book is to believe that it is the speech of Allah, that it contains true reports, just laws, and beneficial accounts, and that we must refer to the judgement of the Book in all our affairs. Sincere advice towards the Messenger ﷺ is to believe in him, to believe that he is the Messenger of Allah to all people, to love him and follow him, to accept as true what he conveyed of information, to observe his commands, to avoid what he forbade, and to defend his religion.',
  'Le bon conseil envers Allah, le Très-Haut, c''est aussi le bon conseil envers Sa religion : en accomplissant Ses ordres, en évitant Ses interdits, en tenant pour vraies Ses informations, en se repentant à Lui, en s''en remettant à Lui, etc. Le bon conseil envers Son Livre consiste à croire qu''il s''agit de la parole d''Allah, qu''il renferme les informations vraies, les lois justes et les récits utiles, et que nous devons nous en remettre au jugement du Livre dans toutes nos affaires. Le bon conseil envers le Messager ﷺ, c''est de croire en lui, de croire qu''il est l''Envoyé d''Allah à toute l''humanité, de l''aimer et de se conformer à lui, de tenir pour vrai ce qu''il a apporté comme information, d''observer ses ordres, d''éviter ce qu''il a interdit et de défendre sa religion.',
  'النصيحة لله تعالى هي أيضاً النصيحة لدينه: بامتثال أوامره، واجتناب نواهيه، وتصديق أخباره، والتوبة إليه، والتوكل عليه، ونحو ذلك. والنصيحة لكتابه تكون بالإيمان بأنه كلام الله، وأنه يتضمن الأخبار الصادقة والأحكام العادلة والقصص النافعة، وأنه يجب أن نحتكم إلى الكتاب في جميع أمورنا. والنصيحة للرسول صلى الله عليه وسلم هي الإيمان به، والإيمان بأنه رسول الله إلى الناس كافة، ومحبته واتباعه، وتصديق ما جاء به من الأخبار، وامتثال أوامره، واجتناب ما نهى عنه، والذب عن دينه.',
  'Aufrichtiger Rat gegenüber Allah, dem Erhabenen, bedeutet auch aufrichtigen Rat gegenüber Seiner Religion: indem man Seine Gebote erfüllt, Seine Verbote meidet, Seine Berichte für wahr hält, zu Ihm umkehrt, sich auf Ihn verlässt und dergleichen. Aufrichtiger Rat gegenüber Seinem Buch besteht darin, zu glauben, dass es das Wort Allahs ist, dass es wahre Berichte, gerechte Gesetze und nützliche Erzählungen enthält, und dass wir uns in all unseren Angelegenheiten dem Urteil des Buches unterwerfen müssen. Aufrichtiger Rat gegenüber dem Gesandten ﷺ ist es, an ihn zu glauben, zu glauben, dass er der Gesandte Allahs an alle Menschen ist, ihn zu lieben und ihm zu folgen, das von ihm Überbrachte für wahr zu halten, seine Gebote zu befolgen, das von ihm Verbotene zu meiden und seine Religion zu verteidigen.',
  'Oprecht advies jegens Allah, de Verhevene, betekent ook oprecht advies jegens Zijn religie: door Zijn geboden te vervullen, Zijn verboden te mijden, Zijn berichten voor waar te houden, tot Hem berouw te tonen, op Hem te vertrouwen, enzovoort. Oprecht advies jegens Zijn Boek bestaat erin te geloven dat het het woord van Allah is, dat het ware berichten, rechtvaardige wetten en nuttige verhalen bevat, en dat wij ons in al onze zaken aan het oordeel van het Boek moeten onderwerpen. Oprecht advies jegens de Boodschapper ﷺ is in hem te geloven, te geloven dat hij de Boodschapper van Allah aan de hele mensheid is, hem lief te hebben en hem te volgen, het door hem overgebrachte voor waar te houden, zijn geboden na te leven, het door hem verbodene te mijden en zijn religie te verdedigen.',
  'Allah Teâlâ''ya nasihat, aynı zamanda O''nun dinine nasihattir: emirlerini yerine getirmek, yasaklarından kaçınmak, haberlerini tasdik etmek, O''na tövbe etmek, O''na tevekkül etmek vb. ile. Kitabına nasihat, onun Allah''ın kelâmı olduğuna, doğru haberleri, adil hükümleri ve faydalı kıssaları içerdiğine inanmak ve bütün işlerimizde Kitab''ın hükmüne başvurmamız gerektiğine inanmakla olur. Resûl''e ﷺ nasihat ise, ona iman etmek, onun bütün insanlığa gönderilmiş Allah''ın Resûlü olduğuna inanmak, onu sevmek ve ona uymak, getirdiği haberleri tasdik etmek, emirlerini yerine getirmek, yasakladıklarından kaçınmak ve dinini savunmaktır.',
  'Nasihat kepada Allah Taʿala juga merupakan nasihat kepada agama-Nya: dengan menjalankan perintah-Nya, menjauhi larangan-Nya, membenarkan kabar-kabar-Nya, bertaubat kepada-Nya, bertawakal kepada-Nya, dan sebagainya. Nasihat kepada Kitab-Nya adalah dengan meyakini bahwa ia adalah kalam Allah, bahwa ia mengandung kabar-kabar yang benar, hukum-hukum yang adil, dan kisah-kisah yang bermanfaat, dan bahwa kita wajib berhukum kepada Kitab dalam segala urusan kita. Nasihat kepada Rasul ﷺ adalah beriman kepadanya, meyakini bahwa ia adalah utusan Allah kepada seluruh manusia, mencintainya dan mengikutinya, membenarkan kabar yang ia bawa, menjalankan perintahnya, menjauhi apa yang ia larang, dan membela agamanya.',
  'اللہ تعالیٰ کے لیے خیر خواہی دراصل اس کے دین کے لیے خیر خواہی ہے: اس کے احکام بجا لا کر، اس کی منہیات سے بچ کر، اس کی خبروں کی تصدیق کر کے، اس کی طرف توبہ کر کے، اس پر توکل کر کے وغیرہ۔ اس کی کتاب کے لیے خیر خواہی یہ ہے کہ یہ ایمان رکھا جائے کہ یہ اللہ کا کلام ہے، اس میں سچی خبریں، عادلانہ احکام اور مفید قصے ہیں، اور یہ کہ ہمیں اپنے تمام معاملات میں کتاب ہی کی طرف رجوع کرنا ہے۔ رسول ﷺ کے لیے خیر خواہی یہ ہے کہ آپ پر ایمان لایا جائے، یقین کیا جائے کہ آپ تمام انسانوں کی طرف اللہ کے رسول ہیں، آپ سے محبت اور آپ کی پیروی کی جائے، آپ کی لائی ہوئی خبروں کی تصدیق کی جائے، آپ کے احکام پر عمل کیا جائے، آپ کی منع کردہ چیزوں سے بچا جائے اور آپ کے دین کا دفاع کیا جائے۔',
  'আল্লাহ তাআলার প্রতি কল্যাণকামিতা মূলত তাঁর দ্বীনের প্রতি কল্যাণকামিতা: তাঁর আদেশ পালন করে, তাঁর নিষেধাজ্ঞা এড়িয়ে চলে, তাঁর সংবাদসমূহ সত্য বলে মেনে, তাঁর নিকট তওবা করে, তাঁর ওপর তাওয়াক্কুল করে ইত্যাদি। তাঁর কিতাবের প্রতি কল্যাণকামিতা হলো এই বিশ্বাস রাখা যে তা আল্লাহর কালাম, তাতে রয়েছে সত্য সংবাদ, ন্যায়সঙ্গত বিধান ও উপকারী কাহিনী, এবং আমাদের সকল বিষয়ে কিতাবের দিকেই ফিরে যেতে হবে। রাসূল ﷺ-এর প্রতি কল্যাণকামিতা হলো তাঁর প্রতি ঈমান আনা, বিশ্বাস করা যে তিনি সমগ্র মানবজাতির প্রতি আল্লাহর রাসূল, তাঁকে ভালোবাসা ও অনুসরণ করা, তিনি যে সংবাদ এনেছেন তা সত্য বলে মানা, তাঁর আদেশ পালন করা, তিনি যা নিষেধ করেছেন তা এড়িয়ে চলা এবং তাঁর দ্বীনের পক্ষে দাঁড়ানো।',
  'Nasihat kepada Allah Taʿala juga merupakan nasihat kepada agama-Nya: dengan melaksanakan perintah-Nya, menjauhi larangan-Nya, membenarkan khabar-khabar-Nya, bertaubat kepada-Nya, bertawakal kepada-Nya, dan sebagainya. Nasihat kepada Kitab-Nya ialah dengan meyakini bahawa ia ialah kalam Allah, bahawa ia mengandungi khabar-khabar yang benar, hukum-hukum yang adil, dan kisah-kisah yang bermanfaat, dan bahawa kita wajib berhukum kepada Kitab dalam segala urusan kita. Nasihat kepada Rasul ﷺ ialah beriman kepadanya, meyakini bahawa baginda ialah utusan Allah kepada seluruh manusia, mencintainya dan mengikutinya, membenarkan khabar yang dibawanya, melaksanakan perintahnya, menjauhi apa yang dilarangnya, dan membela agamanya.',
  'Искренний совет по отношению к Аллаху Всевышнему — это также искренний совет по отношению к Его религии: исполнением Его повелений, избеганием Его запретов, признанием истинности Его сообщений, покаянием перед Ним, упованием на Него и тому подобным. Искренний совет по отношению к Его Книге состоит в вере в то, что это речь Аллаха, что она содержит истинные сообщения, справедливые установления и полезные повествования, и что мы должны обращаться к суду Книги во всех наших делах. Искренний совет по отношению к Посланнику ﷺ — это вера в него, вера в то, что он Посланник Аллаха ко всем людям, любовь к нему и следование ему, признание истинности того, что он принёс, исполнение его повелений, избегание того, что он запретил, и защита его религии.',
  -- audio_url, ajr, position
  'https://www.40-hadith-nawawi.com/wp-content/uploads/2022/08/Hadith-7-Nawawi-Psalmodie-Arabe.mp3',
  5,
  7
where not exists (
  select 1 from public.hadiths
  where hadith_collection_id = 2 and position = 7
);
