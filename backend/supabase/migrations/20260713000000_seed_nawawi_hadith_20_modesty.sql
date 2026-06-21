-- =============================================================================
-- 40 Hadith Nawawi — Hadith 20: "Modesty (haya) is part of faith"
-- Target collection: public.hadith_collections.id = 2  /  position = 20
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
  'Modesty is part of faith',
  'La pudeur fait partie de la foi',
  'الحياء من الإيمان',
  'Schamhaftigkeit gehört zum Glauben',
  'Schaamte hoort bij het geloof',
  'Hayâ imandandır',
  'Rasa malu sebagian dari iman',
  'حیا ایمان کا حصہ ہے',
  'লজ্জা ঈমানের অংশ',
  'Rasa malu sebahagian daripada iman',
  'Стыдливость — часть веры',
  -- arabic_text
  'عَنْ أَبِي مَسْعُودٍ عُقْبَةَ بْنِ عَمْرٍو الْأَنْصَارِيِّ الْبَدْرِيِّ رَضِيَ اللَّهُ عَنْهُ قَالَ: قَالَ رَسُولُ اللَّهِ صَلَّى اللَّهُ عَلَيْهِ وَسَلَّمَ: «إِنَّ مِمَّا أَدْرَكَ النَّاسُ مِنْ كَلَامِ النُّبُوَّةِ الْأُولَى: إِذَا لَمْ تَسْتَحِ فَاصْنَعْ مَا شِئْتَ»',
  -- transcription
  'ʿan Abī Masʿūdin ʿUqbata bni ʿAmrin al-Anṣāriyyi l-Badriyyi raḍiya Llāhu ʿanhu qāla: qāla Rasūlu Llāhi ṣalla Llāhu ʿalayhi wa-sallama: inna mimmā adraka n-nāsu min kalāmi n-nubuwwati l-ūlā: idhā lam tastaḥi fa-ṣnaʿ mā shiʾta.',
  'ʿan Abî Masʿôdin ʿOuqbata bni ʿAmrin al-Ansâriyyi l-Badriyyi (radia Llâhou ʿanhou) qâla : qâla Rassôlou Llâhi (salla Llâhou ʿalayhi wa sallam) : inna mimmâ adraka n-nâsou min kalâmi n-noubouwwati l-ôlâ : idhâ lam tastahi fa-snaʿ mâ chiʾta.',
  'ʿan Abī Masʿūdin ʿUqbata bni ʿAmrin al-Ansārijji l-Badrijji (radiya Llāhu ʿanhu) qāla: qāla Rasūlu Llāhi (salla Llāhu ʿalaihi wa-sallam): inna mimmā adraka n-nāsu min kalāmi n-nubuwwati l-ūlā: idhā lam tastahi fa-snaʿ mā schiʾta.',
  'ʿan Abie Masʿoedin ʿOeqbata bni ʿAmrin al-Ansaarijji l-Badrijji (radia Llaahoe ʿanhoe) qaala: qaala Rasoeloe Llaahi (salla Llaahoe ʿalaihi wa-sallam): inna mimmaa adraka n-naasoe min kalaami n-noeboewwati l-oelaa: idhaa lam tastahi fa-snaʿ maa sjiʾta.',
  'an Ebû Mesʿûd Ukbe ibn Amr el-Ensârî el-Bedrî''den (radıyallâhu anh) rivayetle dedi ki: Resûlullah (s.a.v.) şöyle buyurdu: inne mimmâ edreke''n-nâsu min kelâmi''n-nubuvveti''l-ûlâ: izâ lem testehı fasnaʿ mâ şiʾte.',
  'ʿan Abī Masʿud ʿUqbah bin ʿAmr al-Anshari al-Badri (radhiyallāhu ʿanhu) berkata: Rasulullah (shallallāhu ʿalaihi wa sallam) bersabda: inna mimmā adrakan-nāsu min kalāmin-nubuwwatil-ūlā: idzā lam tastahi fashnaʿ mā syiʾta.',
  'ابو مسعود عقبہ بن عمرو الانصاری البدری رضی اللہ عنہ سے روایت ہے، انہوں نے کہا: رسول اللہ صلی اللہ علیہ وسلم نے فرمایا: اِنَّ مِمّا اَدرَکَ النّاسُ مِن کَلامِ النُّبُوَّۃِ الاُولٰی: اِذا لَم تَستَحِ فَاصنَع ما شِئتَ۔',
  'আবু মাসউদ উকবা ইবনে আমর আল-আনসারী আল-বাদরী (রাদিয়াল্লাহু আনহু) থেকে বর্ণিত, তিনি বলেন: রাসূলুল্লাহ (সাল্লাল্লাহু আলাইহি ওয়া সাল্লাম) বলেছেন: ইন্না মিম্মা আদরাকান নাসু মিন কালামিন নুবুওয়াতিল ঊলা: ইযা লাম তাসতাহি ফাসনা মা শিতা।',
  'ʿan Abī Masʿud ʿUqbah bin ʿAmr al-Ansari al-Badri (radhiallāhu ʿanhu) berkata: Rasulullah (sallallāhu ʿalaihi wa sallam) bersabda: inna mimmā adrakan-nāsu min kalāmin-nubuwwatil-ūlā: idzā lam tastahi fasnaʿ mā syiʾta.',
  'Ан Аби Масуд Укба ибн Амр аль-Ансари аль-Бадри (да будет доволен им Аллах) сказал: сказал Посланник Аллаха ﷺ: инна мимма адрака н-насу мин калями н-нубуввати ль-уля: иза лам тастахи фа-снаʿ ма шиʾта.',
  -- translation
  'On the authority of Abu Masʿud ʿUqba ibn ʿAmr al-Ansari al-Badri (may Allah be pleased with him), the Messenger of Allah ﷺ said: "Among the words that people have received from the earlier prophethood is this: If you have no modesty (shame), then do whatever you wish."',
  'D''après Abû Masʿûd ʿUqba ibn ʿAmr al-Ansârî al-Badrî (qu''Allah l''agrée), l''Envoyé d''Allah ﷺ a dit : « Parmi les paroles que les gens ont retenues de la prophétie ancienne, il y a celle-ci : Si tu n''as pas de pudeur, alors fais ce que tu veux. »',
  'Nach Abu Masʿud ʿUqba ibn ʿAmr al-Ansari al-Badri (möge Allah mit ihm zufrieden sein) sagte der Gesandte Allahs ﷺ: „Zu dem, was die Menschen von den Worten des früheren Prophetentums erhalten haben, gehört dies: Wenn du keine Schamhaftigkeit hast, dann tu, was du willst."',
  'Op gezag van Abu Masʿud ʿUqba ibn ʿAmr al-Ansari al-Badri (moge Allah tevreden met hem zijn) zei de Boodschapper van Allah ﷺ: „Tot wat de mensen hebben ontvangen van de woorden van het vroegere profeetschap behoort dit: Als je geen schaamte hebt, doe dan wat je wilt."',
  'Ebû Mesʿûd Ukbe ibn Amr el-Ensârî el-Bedrî''den (Allah ondan razı olsun) rivayet edildiğine göre Resûlullah ﷺ şöyle buyurdu: „İnsanların önceki peygamberlik sözlerinden eriştiği şeylerden biri de şudur: Utanmıyorsan dilediğini yap."',
  'Dari Abu Masʿud ʿUqbah bin ʿAmr al-Anshari al-Badri (semoga Allah meridhainya), Rasulullah ﷺ bersabda: "Sesungguhnya di antara perkataan yang didapati manusia dari kenabian terdahulu adalah: Jika engkau tidak punya rasa malu, maka berbuatlah sesukamu."',
  'ابو مسعود عقبہ بن عمرو الانصاری البدری رضی اللہ عنہ سے روایت ہے کہ رسول اللہ ﷺ نے فرمایا: ”لوگوں نے سابقہ نبوت کے کلام میں سے جو کچھ پایا اس میں یہ بھی ہے: جب تجھ میں حیا نہ ہو تو جو چاہے کر۔“',
  'আবু মাসউদ উকবা ইবনে আমর আল-আনসারী আল-বাদরী (রাদিয়াল্লাহু আনহু) থেকে বর্ণিত, রাসূলুল্লাহ ﷺ বলেছেন: "পূর্ববর্তী নবুওয়াতের বাণী থেকে মানুষ যা পেয়েছে তার অন্যতম হলো: যখন তোমার লজ্জা নেই, তখন যা ইচ্ছা করো।"',
  'Daripada Abu Masʿud ʿUqbah bin ʿAmr al-Ansari al-Badri (semoga Allah meredainya), Rasulullah ﷺ bersabda: "Sesungguhnya antara perkataan yang didapati manusia daripada kenabian terdahulu ialah: Jika engkau tidak mempunyai rasa malu, maka buatlah sesuka hatimu."',
  'Со слов Абу Масуда Укбы ибн Амра аль-Ансари аль-Бадри (да будет доволен им Аллах) Посланник Аллаха ﷺ сказал: «Среди того, что люди унаследовали из слов прежнего пророчества, есть и это: Если у тебя нет стыда, то делай что хочешь».',
  -- reference
  'Sahih — reported by Al-Bukhari (10/523, no. 6120)',
  'Hadith authentique rapporté par Al-Bukhari (10/523, n°6120)',
  'حديث صحيح، رواه البخاري (١٠/٥٢٣) (رقم ٦١٢٠)',
  'Sahih — überliefert von Al-Bukhari (10/523, Nr. 6120)',
  'Sahih — overgeleverd door Al-Bukhari (10/523, nr. 6120)',
  'Sahih — Buhârî (10/523, no. 6120) rivayet etmiştir',
  'Hadis sahih, diriwayatkan oleh Al-Bukhari (10/523, no. 6120)',
  'صحیح حدیث، اسے بخاری (۱۰/۵۲۳، نمبر ۶۱۲۰) نے روایت کیا',
  'সহীহ হাদীস — বুখারী (১০/৫২৩, নং ৬১২০) বর্ণনা করেছেন',
  'Hadis sahih, diriwayatkan oleh Al-Bukhari (10/523, no. 6120)',
  'Достоверный хадис, передал аль-Бухари (10/523, № 6120)',
  -- tafsir
  '"Among the words of the earlier prophethood…" means that among the traces of the early prophethood — that of the previous communities, which the Sacred Law (Shariʿa) has approved — is this saying: "If you have no modesty, then do what you wish." Two meanings are distinguished in this statement:\n• The first: If a person does no act that offends modesty, then he is free to do what he wishes — in that sense (it is a permission for one whose deeds are blameless).\n• The second: When a person has no modesty, then he dares to do whatever he wishes without any restraint (a warning of rebuke). Both meanings are correct.',
  '« Parmi les paroles de la prophétie ancienne… » signifie que parmi les traces de la première prophétie — celle des communautés précédentes, que la Loi (Sharîʿa) a approuvée — il y a cette parole : « Si tu n''as pas de pudeur, alors fais ce que tu veux. » On distingue deux significations dans cette parole :\n• La première : Si l''homme ne commet aucun acte qui offense la pudeur, alors il est libre de faire ce qu''il veut — en ce sens (c''est une permission pour celui dont les actes sont irréprochables).\n• La deuxième : Quand l''homme n''a pas de pudeur, alors il ose faire ce qu''il veut sans aucune retenue (c''est une menace de blâme). Les deux significations sont correctes.',
  '«إن مما أدرك الناس من كلام النبوة الأولى» أي أن مما بقي من آثار النبوة الأولى — نبوة الأمم السابقة التي أقرتها الشريعة — هذه الكلمة: «إذا لم تستح فاصنع ما شئت». وفي هذه الكلمة معنيان:\n• الأول: إذا كان الإنسان لا يفعل فعلاً يخل بالحياء، فهو حر في أن يفعل ما يشاء بهذا المعنى (وهي إباحة لمن كانت أفعاله سليمة).\n• الثاني: إذا لم يكن للإنسان حياء، فإنه يجرؤ على فعل ما يشاء دون مبالاة (وهو تهديد ووعيد). والمعنيان صحيحان.',
  '„Zu den Worten des früheren Prophetentums…" bedeutet, dass zu den Spuren des frühen Prophetentums — dem der vorigen Gemeinschaften, das die Scharia gebilligt hat — dieser Ausspruch gehört: „Wenn du keine Schamhaftigkeit hast, dann tu, was du willst." In dieser Aussage werden zwei Bedeutungen unterschieden:\n• Die erste: Wenn ein Mensch keine Tat begeht, die die Schamhaftigkeit verletzt, dann steht es ihm frei zu tun, was er will — in diesem Sinne (eine Erlaubnis für den, dessen Taten tadellos sind).\n• Die zweite: Wenn ein Mensch keine Schamhaftigkeit hat, dann wagt er, alles zu tun, was er will, ohne jede Zurückhaltung (eine Drohung des Tadels). Beide Bedeutungen sind richtig.',
  '„Tot de woorden van het vroegere profeetschap…" betekent dat tot de sporen van het vroege profeetschap — dat van de vorige gemeenschappen, dat de Sjaria heeft goedgekeurd — deze uitspraak behoort: „Als je geen schaamte hebt, doe dan wat je wilt." In deze uitspraak worden twee betekenissen onderscheiden:\n• De eerste: Als een mens geen daad verricht die de schaamte schendt, dan staat het hem vrij te doen wat hij wil — in die zin (een toestemming voor wie onberispelijke daden heeft).\n• De tweede: Wanneer een mens geen schaamte heeft, dan durft hij te doen wat hij wil zonder enige terughoudendheid (een dreiging van afkeuring). Beide betekenissen zijn juist.',
  '„İnsanların önceki peygamberlik sözlerinden eriştiği şeylerden…" yani önceki peygamberliğin — şeriatın onayladığı, geçmiş ümmetlerin peygamberliğinin — izlerinden biri de şu sözdür: „Utanmıyorsan dilediğini yap." Bu sözde iki mana ayırt edilir:\n• Birincisi: İnsan hayâya aykırı bir fiil işlemiyorsa, bu manada dilediğini yapmakta serbesttir (fiilleri kusursuz olan için bir ruhsattır).\n• İkincisi: İnsanda hayâ olmadığında, hiç aldırmadan dilediğini yapmaya cüret eder (bu bir tehdit ve uyarıdır). Her iki mana da doğrudur.',
  '"Sesungguhnya di antara perkataan kenabian terdahulu…" maksudnya bahwa di antara jejak kenabian terdahulu — kenabian umat-umat sebelumnya yang disetujui oleh syariat — adalah perkataan ini: "Jika engkau tidak punya rasa malu, maka berbuatlah sesukamu." Dalam perkataan ini dibedakan dua makna:\n• Pertama: Jika seseorang tidak melakukan perbuatan yang melanggar rasa malu, maka ia bebas melakukan apa yang ia kehendaki dalam makna ini (ini kebolehan bagi orang yang perbuatannya bersih).\n• Kedua: Apabila seseorang tidak memiliki rasa malu, maka ia berani melakukan apa saja yang ia kehendaki tanpa peduli (ini ancaman dan celaan). Kedua makna ini benar.',
  '”لوگوں نے سابقہ نبوت کے کلام میں سے جو پایا…“ یعنی پہلی نبوت کے آثار میں سے — جو پچھلی امتوں کی نبوت ہے اور جسے شریعت نے برقرار رکھا — یہ کلمہ ہے: ”جب تجھ میں حیا نہ ہو تو جو چاہے کر۔“ اس کلمے میں دو معنی ہیں:\n• پہلا: اگر انسان کوئی ایسا کام نہ کرے جو حیا کے خلاف ہو، تو اس معنی میں وہ جو چاہے کرنے میں آزاد ہے (یہ اس کے لیے اجازت ہے جس کے اعمال درست ہوں)۔\n• دوسرا: جب انسان میں حیا نہ ہو تو وہ بے پروا ہو کر جو چاہے کرنے کی جرأت کرتا ہے (یہ تہدید اور وعید ہے)۔ دونوں معنی درست ہیں۔',
  '"পূর্ববর্তী নবুওয়াতের বাণী থেকে মানুষ যা পেয়েছে…" অর্থাৎ পূর্ববর্তী নবুওয়াতের নিদর্শনসমূহের মধ্যে — যা পূর্ববর্তী উম্মতগণের নবুওয়াত, যা শরীয়ত অনুমোদন করেছে — রয়েছে এই বাণী: "যখন তোমার লজ্জা নেই, তখন যা ইচ্ছা করো।" এই বাণীতে দুটি অর্থ পৃথক করা হয়:\n• প্রথম: যদি কোনো ব্যক্তি লজ্জার পরিপন্থী কোনো কাজ না করে, তবে এই অর্থে সে যা ইচ্ছা করতে স্বাধীন (এটি তার জন্য অনুমতি যার কাজ নিষ্কলুষ)।\n• দ্বিতীয়: যখন কোনো ব্যক্তির লজ্জা থাকে না, তখন সে বেপরোয়াভাবে যা ইচ্ছা করার দুঃসাহস করে (এটি একটি হুমকি ও তিরস্কার)। উভয় অর্থই সঠিক।',
  '"Sesungguhnya antara perkataan kenabian terdahulu…" bermaksud bahawa antara kesan kenabian terdahulu — kenabian umat-umat sebelumnya yang disetujui oleh syariat — ialah perkataan ini: "Jika engkau tidak mempunyai rasa malu, maka buatlah sesuka hatimu." Dalam perkataan ini dibezakan dua makna:\n• Pertama: Jika seseorang tidak melakukan perbuatan yang melanggar rasa malu, maka dia bebas melakukan apa yang dikehendakinya dalam makna ini (ini keizinan bagi orang yang perbuatannya bersih).\n• Kedua: Apabila seseorang tidak mempunyai rasa malu, maka dia berani melakukan apa sahaja yang dikehendakinya tanpa peduli (ini ancaman dan celaan). Kedua-dua makna ini betul.',
  '«Среди слов прежнего пророчества…» означает, что среди следов раннего пророчества — пророчества прежних общин, которое одобрил Шариат, — есть это изречение: «Если у тебя нет стыда, то делай что хочешь». В этом высказывании различают два смысла:\n• Первый: Если человек не совершает поступка, нарушающего стыдливость, то в этом смысле он волен делать что хочет (это дозволение для того, чьи дела безупречны).\n• Второй: Когда у человека нет стыда, он осмеливается делать всё, что хочет, без всякого удержа (это угроза и порицание). Оба смысла верны.',
  -- audio_url, ajr, position
  'https://www.40-hadith-nawawi.com/wp-content/uploads/2022/08/Hadith-20-Nawawi-Psalmodie-Arabe.mp3',
  5,
  20
where not exists (
  select 1 from public.hadiths
  where hadith_collection_id = 2 and position = 20
);
