-- =============================================================================
-- 40 Hadith Nawawi — Hadith 26: "A charity due upon every joint / reconciliation"
-- Target collection: public.hadith_collections.id = 2  /  position = 26
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
  'Reconciling people and a charity on every joint',
  'La vertu de la conciliation entre les gens',
  'الصدقة على كل سُلامى',
  'Versöhnung und eine Wohltat auf jedem Gelenk',
  'Verzoening en een aalmoes op elk gewricht',
  'İnsanları barıştırmak ve her ekleme sadaka',
  'Mendamaikan manusia dan sedekah pada setiap sendi',
  'لوگوں میں صلح اور ہر جوڑ پر صدقہ',
  'মানুষের মধ্যে মীমাংসা ও প্রতিটি গ্রন্থিতে সদকা',
  'Mendamaikan manusia dan sedekah pada setiap sendi',
  'Примирение людей и милостыня за каждый сустав',
  -- arabic_text (cleaned)
  'عَنْ أَبِي هُرَيْرَةَ رَضِيَ اللَّهُ عَنْهُ قَالَ: قَالَ رَسُولُ اللَّهِ صَلَّى اللَّهُ عَلَيْهِ وَسَلَّمَ: «كُلُّ سُلَامَى مِنَ النَّاسِ عَلَيْهِ صَدَقَةٌ كُلَّ يَوْمٍ تَطْلُعُ فِيهِ الشَّمْسُ: تَعْدِلُ بَيْنَ اثْنَيْنِ صَدَقَةٌ، وَتُعِينُ الرَّجُلَ فِي دَابَّتِهِ فَتَحْمِلُهُ عَلَيْهَا أَوْ تَرْفَعُ لَهُ عَلَيْهَا مَتَاعَهُ صَدَقَةٌ، وَالْكَلِمَةُ الطَّيِّبَةُ صَدَقَةٌ، وَبِكُلِّ خُطْوَةٍ تَمْشِيهَا إِلَى الصَّلَاةِ صَدَقَةٌ، وَتُمِيطُ الْأَذَى عَنِ الطَّرِيقِ صَدَقَةٌ»',
  -- transcription
  'ʿan Abī Hurayrata raḍiya Llāhu ʿanhu qāla: qāla Rasūlu Llāhi ṣalla Llāhu ʿalayhi wa-sallama: kullu sulāmā mina n-nāsi ʿalayhi ṣadaqatun kulla yawmin taṭluʿu fīhi sh-shamsu: taʿdilu bayna thnayni ṣadaqatun, wa-tuʿīnu r-rajula fī dābbatihi fa-taḥmiluhu ʿalayhā aw tarfaʿu lahu ʿalayhā matāʿahu ṣadaqatun, wa-l-kalimatu ṭ-ṭayyibatu ṣadaqatun, wa-bi-kulli khuṭwatin tamshīhā ila ṣ-ṣalāti ṣadaqatun, wa-tumīṭu l-adhā ʿani ṭ-ṭarīqi ṣadaqatun.',
  'ʿan Abî Hourayrata (radia Llâhou ʿanhou) qâla : qâla Rassôlou Llâhi (salla Llâhou ʿalayhi wa sallam) : koullou soulâmâ mina n-nâsi ʿalayhi sadaqatoun koulla yawmin tatlouʿou fîhi ch-chamsou : taʿdilou bayna thnayni sadaqatoun, wa touʿînou r-rajoula fî dâbbatihi fa-tahmilouhou ʿalayhâ aw tarfaʿou lahou ʿalayhâ matâʿahou sadaqatoun, wa l-kalimatou t-tayyibatou sadaqatoun, wa bi-koulli khoutwatin tamchîhâ ila s-salâti sadaqatoun, wa toumîtou l-adhâ ʿani t-tarîqi sadaqatoun.',
  'ʿan Abī Hurairata (radiya Llāhu ʿanhu) qāla: qāla Rasūlu Llāhi (salla Llāhu ʿalaihi wa-sallam): kullu sulāmā mina n-nāsi ʿalaihi sadaqatun kulla jaumin tatluʿu fīhi sch-schamsu: taʿdilu baina thnaini sadaqatun, wa-tuʿīnu r-radschula fī dābbatihi fa-tahmiluhu ʿalaihā au tarfaʿu lahu ʿalaihā matāʿahu sadaqatun, wa-l-kalimatu t-tajjibatu sadaqatun, wa-bi-kulli chutwatin tamschīhā ila s-salāti sadaqatun, wa-tumītu l-adhā ʿani t-tarīqi sadaqatun.',
  'ʿan Abie Hoerairata (radia Llaahoe ʿanhoe) qaala: qaala Rasoeloe Llaahi (salla Llaahoe ʿalaihi wa-sallam): koelloe soelaamaa mina n-naasi ʿalaihi sadaqatoen koella jaumin tatloeʿoe fiehi sj-sjamsoe: taʿdiloe baina thnaini sadaqatoen, wa-toeʿienoe r-radzjoela fie daabbatihi fa-tahmiloehoe ʿalaihaa au tarfaʿoe lahoe ʿalaihaa mataaʿahoe sadaqatoen, wa-l-kalimatoe t-tajjibatoe sadaqatoen, wa-bi-koelli choetwatin tamsjiehaa ila s-salaati sadaqatoen, wa-toemietoe l-adhaa ʿani t-tarieqi sadaqatoen.',
  'an Ebû Hüreyre''den (radıyallâhu anh) rivayetle dedi ki: Resûlullah (s.a.v.) şöyle buyurdu: güneşin doğduğu her gün, insanın her bir eklemi için bir sadaka gerekir: iki kişinin arasını adaletle bulman bir sadakadır, bir kimseye bineğine binmesinde yardım etmen yahut eşyasını ona yüklemen bir sadakadır, güzel söz bir sadakadır, namaza yürüdüğün her adım bir sadakadır, yoldan eziyet veren şeyi gidermen bir sadakadır.',
  'an Abi Hurairah (radhiyallahu ʿanhu) berkata: Rasulullah (shallallahu ʿalaihi wa sallam) bersabda: setiap ruas (sendi) tulang manusia wajib bersedekah setiap hari ketika matahari terbit: mendamaikan antara dua orang adalah sedekah, menolong seseorang menaiki kendaraannya atau mengangkatkan barangnya ke atasnya adalah sedekah, kata-kata yang baik adalah sedekah, setiap langkah yang kamu ayunkan menuju shalat adalah sedekah, dan menyingkirkan gangguan dari jalan adalah sedekah.',
  'ابو ہریرہ رضی اللہ عنہ سے روایت ہے، انہوں نے کہا: رسول اللہ صلی اللہ علیہ وسلم نے فرمایا: ہر روز جب سورج طلوع ہوتا ہے، انسان کے ہر جوڑ پر ایک صدقہ ہے: دو آدمیوں کے درمیان انصاف سے فیصلہ کرنا صدقہ ہے، کسی شخص کو اس کی سواری پر سوار ہونے میں مدد دینا یا اس کا سامان اس پر رکھ دینا صدقہ ہے، اچھی بات کہنا صدقہ ہے، نماز کی طرف چلتے ہوئے ہر قدم صدقہ ہے، اور راستے سے تکلیف دہ چیز ہٹانا صدقہ ہے۔',
  'আবু হুরায়রা (রাদিয়াল্লাহু আনহু) থেকে বর্ণিত, তিনি বলেন: রাসূলুল্লাহ (সাল্লাল্লাহু আলাইহি ওয়া সাল্লাম) বলেছেন: প্রতিদিন যখন সূর্য উদিত হয়, মানুষের প্রতিটি গ্রন্থির (জোড়ার) উপর একটি সদকা রয়েছে: দুই ব্যক্তির মধ্যে ন্যায়বিচার করা সদকা, কাউকে তার বাহনে আরোহণে সাহায্য করা বা তার মালপত্র তাতে তুলে দেওয়া সদকা, ভালো কথা বলা সদকা, সালাতের দিকে হেঁটে যাওয়া প্রতিটি পদক্ষেপ সদকা, এবং রাস্তা থেকে কষ্টদায়ক বস্তু সরানো সদকা।',
  'an Abi Hurairah (radhiallahu ʿanhu) berkata: Rasulullah (sallallahu ʿalaihi wa sallam) bersabda: setiap ruas (sendi) tulang manusia wajib bersedekah setiap hari ketika matahari terbit: mendamaikan antara dua orang adalah sedekah, menolong seseorang menaiki tunggangannya atau mengangkatkan barangnya ke atasnya adalah sedekah, kata-kata yang baik adalah sedekah, setiap langkah yang kamu langkahkan menuju solat adalah sedekah, dan menyingkirkan gangguan dari jalan adalah sedekah.',
  'Ан Аби Хурайра (да будет доволен им Аллах) сказал: сказал Посланник Аллаха ﷺ: за каждый сустав человека полагается милостыня каждый день, когда восходит солнце: рассудить справедливо между двумя — милостыня, помочь человеку сесть на его верховое животное или поднять на него его поклажу — милостыня, доброе слово — милостыня, каждый шаг, что ты делаешь к молитве, — милостыня, и устранение того, что причиняет вред, с дороги — милостыня.',
  -- translation
  'On the authority of Abu Hurayra (may Allah be pleased with him), the Messenger of Allah ﷺ said: "Upon every joint (bone) of a person a charity is due every day on which the sun rises: to act justly between two people is a charity; to help a man with his mount, lifting him onto it or hoisting up his belongings onto it, is a charity; a good word is a charity; every step you take towards the prayer is a charity; and removing what is harmful from the road is a charity."',
  'D''après Abû Hourayra (qu''Allah l''agrée), l''Envoyé d''Allah ﷺ a dit : « Pour chacune des articulations de l''homme, une aumône est due chaque jour où le soleil se lève : pratiquer l''équité entre deux personnes est une aumône ; aider un homme avec sa monture, en l''y faisant monter ou en y hissant ses bagages, est une aumône ; une bonne parole est une aumône ; chaque pas que tu fais vers la prière est une aumône ; et écarter de la route ce qui est nuisible est une aumône. »',
  'Nach Abu Hurayra (möge Allah mit ihm zufrieden sein) sagte der Gesandte Allahs ﷺ: „Für jedes Gelenk (jeden Knochen) eines Menschen ist eine Wohltat fällig an jedem Tag, an dem die Sonne aufgeht: zwischen zwei Menschen gerecht zu schlichten ist eine Wohltat; einem Mann mit seinem Reittier zu helfen, ihn darauf zu heben oder ihm sein Gepäck darauf zu laden, ist eine Wohltat; ein gutes Wort ist eine Wohltat; jeder Schritt, den du zum Gebet gehst, ist eine Wohltat; und das Entfernen dessen, was schädlich ist, vom Weg ist eine Wohltat."',
  'Op gezag van Abu Hurayra (moge Allah tevreden met hem zijn) zei de Boodschapper van Allah ﷺ: „Op elk gewricht (bot) van een mens rust een aalmoes elke dag waarop de zon opgaat: rechtvaardig oordelen tussen twee mensen is een aalmoes; een man helpen met zijn rijdier, hem erop tillen of zijn bagage erop hijsen, is een aalmoes; een goed woord is een aalmoes; elke stap die je naar het gebed zet is een aalmoes; en het verwijderen van wat schadelijk is van de weg is een aalmoes."',
  'Ebû Hüreyre''den (Allah ondan razı olsun) rivayet edildiğine göre Resûlullah ﷺ şöyle buyurdu: „Güneşin doğduğu her gün, insanın her bir eklemi için bir sadaka gerekir: iki kişinin arasını adaletle bulmak bir sadakadır; bir kimseye bineğine binmesinde yardım etmek yahut eşyasını ona yüklemek bir sadakadır; güzel söz bir sadakadır; namaza doğru attığın her adım bir sadakadır; ve yoldan eziyet veren şeyi gidermek bir sadakadır."',
  'Dari Abu Hurairah (semoga Allah meridhainya), Rasulullah ﷺ bersabda: "Setiap ruas (sendi) tulang manusia wajib bersedekah setiap hari ketika matahari terbit: mendamaikan antara dua orang adalah sedekah; menolong seseorang menaiki kendaraannya atau mengangkatkan barangnya ke atasnya adalah sedekah; kata-kata yang baik adalah sedekah; setiap langkah yang engkau ayunkan menuju shalat adalah sedekah; dan menyingkirkan gangguan dari jalan adalah sedekah."',
  'ابو ہریرہ رضی اللہ عنہ سے روایت ہے کہ رسول اللہ ﷺ نے فرمایا: ”ہر روز جب سورج طلوع ہوتا ہے، انسان کے ہر جوڑ پر ایک صدقہ ہے: دو آدمیوں کے درمیان انصاف سے فیصلہ کرنا صدقہ ہے؛ کسی شخص کو اس کی سواری پر سوار ہونے میں مدد دینا یا اس کا سامان اس پر اٹھا کر رکھنا صدقہ ہے؛ اچھی بات صدقہ ہے؛ نماز کی طرف چلتے ہوئے تمہارا ہر قدم صدقہ ہے؛ اور راستے سے تکلیف دہ چیز ہٹانا صدقہ ہے۔“',
  'আবু হুরায়রা (রাদিয়াল্লাহু আনহু) থেকে বর্ণিত, রাসূলুল্লাহ ﷺ বলেছেন: "প্রতিদিন যখন সূর্য উদিত হয়, মানুষের প্রতিটি গ্রন্থির (হাড়ের জোড়ার) উপর একটি সদকা রয়েছে: দুই ব্যক্তির মধ্যে ন্যায়বিচার করা সদকা; কাউকে তার বাহনে আরোহণে সাহায্য করা বা তার মালপত্র তাতে তুলে দেওয়া সদকা; ভালো কথা সদকা; সালাতের দিকে তোমার প্রতিটি পদক্ষেপ সদকা; এবং রাস্তা থেকে কষ্টদায়ক বস্তু সরানো সদকা।"',
  'Daripada Abu Hurairah (semoga Allah meredainya), Rasulullah ﷺ bersabda: "Setiap ruas (sendi) tulang manusia wajib bersedekah setiap hari ketika matahari terbit: mendamaikan antara dua orang adalah sedekah; menolong seseorang menaiki tunggangannya atau mengangkatkan barangnya ke atasnya adalah sedekah; kata-kata yang baik adalah sedekah; setiap langkah yang engkau langkahkan menuju solat adalah sedekah; dan menyingkirkan gangguan dari jalan adalah sedekah."',
  'Со слов Абу Хурайры (да будет доволен им Аллах) Посланник Аллаха ﷺ сказал: «За каждый сустав человека полагается милостыня в каждый день, когда восходит солнце: справедливо рассудить между двумя — милостыня; помочь человеку с его верховым животным, подсадив его на него или подняв на него его поклажу, — милостыня; доброе слово — милостыня; каждый шаг, что ты делаешь к молитве, — милостыня; и устранение вредного с дороги — милостыня».',
  -- reference
  'Sahih — reported by Al-Bukhari (6/132, no. 2989) and Muslim (2/699, no. 1009)',
  'Hadith authentique rapporté par Al-Bukhari (6/132, n°2989) et Muslim (2/699, n°1009)',
  'حديث صحيح، رواه البخاري (٦/١٣٢) (رقم ٢٩٨٩) ومسلم (٢/٦٩٩) (رقم ١٠٠٩)',
  'Sahih — überliefert von Al-Bukhari (6/132, Nr. 2989) und Muslim (2/699, Nr. 1009)',
  'Sahih — overgeleverd door Al-Bukhari (6/132, nr. 2989) en Muslim (2/699, nr. 1009)',
  'Sahih — Buhârî (6/132, no. 2989) ve Müslim (2/699, no. 1009) rivayet etmiştir',
  'Hadis sahih, diriwayatkan oleh Al-Bukhari (6/132, no. 2989) dan Muslim (2/699, no. 1009)',
  'صحیح حدیث، اسے بخاری (۶/۱۳۲، نمبر ۲۹۸۹) اور مسلم (۲/۶۹۹، نمبر ۱۰۰۹) نے روایت کیا',
  'সহীহ হাদীস — বুখারী (৬/১৩২, নং ২৯৮৯) ও মুসলিম (২/৬৯৯, নং ১০০৯) বর্ণনা করেছেন',
  'Hadis sahih, diriwayatkan oleh Al-Bukhari (6/132, no. 2989) dan Muslim (2/699, no. 1009)',
  'Достоверный хадис, передали аль-Бухари (6/132, № 2989) и Муслим (2/699, № 1009)',
  -- tafsir
  '• Every day on which the sun rises, every person owes a number of charities equal to his joints, which number three hundred and sixty.\n• Everything that draws one closer to Allah, the Exalted — whether an act of worship or kindness towards His servants — is a charity. The Prophet ﷺ gave examples of this, and he said in another hadith: "But two rakʿahs that the believer prays after the sun has risen to the height of a spear (the duha prayer) suffice in place of all that."',
  '• Chaque jour où le soleil se lève, à tout homme incombe un nombre d''aumônes équivalent à ses articulations, qui sont au nombre de trois cent soixante.\n• Tout ce qui rapproche d''Allah, le Très-Haut — qu''il s''agisse d''un acte d''adoration ou de bonté envers Ses serviteurs — est une aumône. Le Prophète ﷺ en a cité des exemples, et il a dit dans un autre hadith : « Mais deux rakʿas que le fidèle accomplit après que le soleil s''est levé de la hauteur d''une lance (la prière du Duhâ) suffisent à la place de tout cela. »',
  '• كل يوم تطلع فيه الشمس، على كل إنسان عدد من الصدقات بعدد مفاصله، وهي ثلاثمائة وستون مفصلاً.\n• كل ما يقرّب من الله تعالى من عبادة وإحسان إلى عباده فهو صدقة، وقد ضرب النبي صلى الله عليه وسلم أمثلة على ذلك، وقال في حديث آخر: «ويجزئ من ذلك كله ركعتان يركعهما العبد من الضحى».',
  '• An jedem Tag, an dem die Sonne aufgeht, schuldet jeder Mensch eine Anzahl von Wohltaten entsprechend seinen Gelenken, deren es dreihundertsechzig sind.\n• Alles, was Allah, dem Erhabenen, näherbringt — sei es ein Akt der Anbetung oder Güte gegenüber Seinen Dienern — ist eine Wohltat. Der Prophet ﷺ gab Beispiele dafür und sagte in einem anderen Hadith: „Doch zwei Rakʿas, die der Gläubige verrichtet, nachdem die Sonne speerhoch aufgestiegen ist (das Duha-Gebet), genügen anstelle all dessen."',
  '• Op elke dag waarop de zon opgaat, is elke mens een aantal aalmoezen verschuldigd gelijk aan zijn gewrichten, die driehonderdzestig in getal zijn.\n• Alles wat dichter bij Allah, de Verhevene, brengt — of het nu een daad van aanbidding of goedheid jegens Zijn dienaren is — is een aalmoes. De Profeet ﷺ gaf hier voorbeelden van, en hij zei in een andere hadith: „Maar twee rakʿahs die de gelovige verricht nadat de zon speerhoog is gestegen (het Duha-gebed) volstaan in plaats van dat alles."',
  '• Güneşin doğduğu her gün, her insanın üzerine, eklemlerinin sayısınca — ki üç yüz altmış eklemdir — sadaka gerekir.\n• Allah''a yaklaştıran her şey — ister ibadet ister kullarına iyilik olsun — bir sadakadır. Peygamber ﷺ buna örnekler verdi ve başka bir hadiste şöyle buyurdu: „Bütün bunların yerine, kulun güneş bir mızrak boyu yükseldikten sonra kıldığı iki rekât (kuşluk namazı) yeterlidir."',
  '• Setiap hari ketika matahari terbit, atas setiap orang ada sejumlah sedekah sebanyak ruas tulangnya, yang berjumlah tiga ratus enam puluh ruas.\n• Segala yang mendekatkan diri kepada Allah Taʿala — baik berupa ibadah maupun kebaikan kepada hamba-hamba-Nya — adalah sedekah. Nabi ﷺ memberikan contoh-contohnya, dan beliau bersabda dalam hadis lain: "Dan cukuplah sebagai ganti semua itu dua rakaat yang dikerjakan seorang hamba dari shalat Dhuha (setelah matahari naik setinggi tombak)."',
  '• ہر روز جب سورج طلوع ہوتا ہے، ہر انسان پر اس کے جوڑوں کی تعداد کے برابر صدقے واجب ہوتے ہیں، اور یہ تین سو ساٹھ جوڑ ہیں۔\n• ہر وہ چیز جو اللہ تعالیٰ کے قریب کرے — خواہ عبادت ہو یا بندوں کے ساتھ احسان — وہ صدقہ ہے۔ نبی ﷺ نے اس کی مثالیں دیں، اور ایک اور حدیث میں فرمایا: ”اور ان سب کے بدلے میں وہ دو رکعتیں کافی ہیں جو بندہ چاشت کے وقت (سورج کے ایک نیزے کے برابر بلند ہونے کے بعد) پڑھتا ہے۔“',
  '• প্রতিদিন যখন সূর্য উদিত হয়, প্রত্যেক মানুষের উপর তার গ্রন্থির সংখ্যা পরিমাণ সদকা ওয়াজিব হয়, আর তা তিনশত ষাটটি গ্রন্থি।\n• যা কিছু আল্লাহ তাআলার নিকটবর্তী করে — তা ইবাদত হোক বা বান্দাদের প্রতি অনুগ্রহ — তা সদকা। নবী ﷺ এর উদাহরণ দিয়েছেন, এবং অন্য এক হাদীসে বলেছেন: "আর এ সবকিছুর পরিবর্তে যথেষ্ট হলো সেই দুই রাকাত যা বান্দা চাশতের সময় (সূর্য এক বর্শা পরিমাণ উঁচু হওয়ার পর) আদায় করে।"',
  '• Setiap hari ketika matahari terbit, ke atas setiap orang ada sejumlah sedekah sebanyak ruas tulangnya, yang berjumlah tiga ratus enam puluh ruas.\n• Segala yang mendekatkan diri kepada Allah Taʿala — sama ada berupa ibadah mahupun kebaikan kepada hamba-hamba-Nya — adalah sedekah. Nabi ﷺ memberikan contoh-contohnya, dan baginda bersabda dalam hadis lain: "Dan cukuplah sebagai ganti semua itu dua rakaat yang dikerjakan seorang hamba daripada solat Dhuha (selepas matahari naik setinggi tombak)."',
  '• В каждый день, когда восходит солнце, на каждом человеке лежит число милостынь, равное числу его суставов, которых триста шестьдесят.\n• Всё, что приближает к Аллаху Всевышнему — будь то акт поклонения или доброта к Его рабам — есть милостыня. Пророк ﷺ привёл этому примеры и сказал в другом хадисе: «Но вместо всего этого достаточно двух ракаатов, которые раб совершает после того, как солнце поднимется на высоту копья (молитва духа)».',
  -- audio_url, ajr, position
  'https://www.40-hadith-nawawi.com/wp-content/uploads/2023/01/Hadith-26-Nawawi-Psalmodie-Arabe.mp3',
  5,
  26
where not exists (
  select 1 from public.hadiths
  where hadith_collection_id = 2 and position = 26
);
