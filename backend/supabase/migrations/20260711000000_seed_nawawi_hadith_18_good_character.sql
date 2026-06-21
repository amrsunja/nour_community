-- =============================================================================
-- 40 Hadith Nawawi — Hadith 18: "Taqwa, good deeds after bad, good character"
-- Target collection: public.hadith_collections.id = 2  /  position = 18
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
  'Taqwa and good character',
  'La bonne moralité',
  'حسن الخلق',
  'Gottesfurcht und guter Charakter',
  'Godsvrees en goed karakter',
  'Takvâ ve güzel ahlak',
  'Takwa dan akhlak yang baik',
  'تقویٰ اور حسنِ اخلاق',
  'তাকওয়া ও সচ্চরিত্র',
  'Takwa dan akhlak yang baik',
  'Богобоязненность и благой нрав',
  -- arabic_text
  'عَنْ أَبِي ذَرٍّ جُنْدُبِ بْنِ جُنَادَةَ وَأَبِي عَبْدِ الرَّحْمَنِ مُعَاذِ بْنِ جَبَلٍ رَضِيَ اللَّهُ عَنْهُمَا عَنْ رَسُولِ اللَّهِ صَلَّى اللَّهُ عَلَيْهِ وَسَلَّمَ قَالَ: «اتَّقِ اللَّهَ حَيْثُمَا كُنْتَ، وَأَتْبِعِ السَّيِّئَةَ الْحَسَنَةَ تَمْحُهَا، وَخَالِقِ النَّاسَ بِخُلُقٍ حَسَنٍ»',
  -- transcription
  'ʿan Abī Dharrin Jundubi bni Junādata wa-Abī ʿAbdi r-Raḥmāni Muʿādhi bni Jabalin raḍiya Llāhu ʿanhumā ʿan Rasūli Llāhi ṣalla Llāhu ʿalayhi wa-sallama qāla: ittaqi Llāha ḥaythumā kunta, wa-atbiʿi s-sayyiʾata l-ḥasanata tamḥuhā, wa-khāliqi n-nāsa bi-khuluqin ḥasanin.',
  'ʿan Abî Dharrin Joundoubi bni Jounâdata wa Abî ʿAbdi r-Rahmâni Mouʿâdhi bni Jabalin (radia Llâhou ʿanhoumâ) ʿan Rassôli Llâhi (salla Llâhou ʿalayhi wa sallam) qâla : ittaqi Llâha haythoumâ kounta, wa atbiʿi s-sayyiʾata l-hasanata tamhouhâ, wa khâliqi n-nâsa bi-khouluqin hasanin.',
  'ʿan Abī Dharrin Dschundubi bni Dschunādata wa-Abī ʿAbdi r-Rahmāni Muʿādhi bni Dschabalin (radiya Llāhu ʿanhumā) ʿan Rasūli Llāhi (salla Llāhu ʿalaihi wa-sallam) qāla: ittaqi Llāha haithumā kunta, wa-atbiʿi s-sajjiʾata l-hasanata tamhuhā, wa-chāliqi n-nāsa bi-chuluqin hasanin.',
  'ʿan Abie Dharrin Dzjoendoebi bni Dzjoenaadata wa-Abie ʿAbdi r-Rahmaani Moeʿaadhi bni Dzjabalin (radia Llaahoe ʿanhoemaa) ʿan Rasoeli Llaahi (salla Llaahoe ʿalaihi wa-sallam) qaala: ittaqi Llaaha haithoemaa koenta, wa-atbiʿi s-sajjiʾata l-hasanata tamhoehaa, wa-chaaliqi n-naasa bi-choeloeqin hasanin.',
  'an Ebû Zer Cündüb ibn Cünâde ve Ebû Abdurrahman Muâz ibn Cebel''den (radıyallâhu anhümâ) Resûlullah''tan (s.a.v.) rivayetle buyurdu: ittekı''llâhe haysumâ kunte, ve etbiʿi''s-seyyiete''l-hasenete temhuhâ, ve hâliki''n-nâse bi-hulukın hasenin.',
  'ʿan Abī Dzarr Jundub bin Junādah dan Abī ʿAbdurrahman Muʿadz bin Jabal (radhiyallāhu ʿanhumā) dari Rasulullah (shallallāhu ʿalaihi wa sallam) bersabda: ittaqillāha haitsumā kunta, wa atbiʿis-sayyiʾatal-hasanata tamhuhā, wa khāliqin-nāsa bi-khuluqin hasanin.',
  'ابو ذر جندب بن جنادہ اور ابو عبد الرحمن معاذ بن جبل رضی اللہ عنہما سے، رسول اللہ صلی اللہ علیہ وسلم سے روایت ہے کہ آپ نے فرمایا: اِتَّقِ اللہَ حَیثُما کُنتَ، وَاَتبِعِ السَّیِّئَۃَ الحَسَنَۃَ تَمحُہا، وَخالِقِ النّاسَ بِخُلُقٍ حَسَنٍ۔',
  'আবু যার জুনদুব ইবনে জুনাদা ও আবু আবদুর রহমান মুআয ইবনে জাবাল (রাদিয়াল্লাহু আনহুমা) থেকে, রাসূলুল্লাহ (সাল্লাল্লাহু আলাইহি ওয়া সাল্লাম) থেকে বর্ণিত, তিনি বলেছেন: ইত্তাকিল্লাহা হাইসুমা কুনতা, ওয়া আতবিইস সাইয়িআতাল হাসানাতা তামহুহা, ওয়া খালিকিন নাসা বিখুলুকিন হাসানিন।',
  'ʿan Abī Dzarr Jundub bin Junādah dan Abī ʿAbdurrahman Muʿadz bin Jabal (radhiallāhu ʿanhumā) daripada Rasulullah (sallallāhu ʿalaihi wa sallam) bersabda: ittaqillāha haitsumā kunta, wa atbiʿis-sayyiʾatal-hasanata tamhuhā, wa khāliqin-nāsa bi-khuluqin hasanin.',
  'Ан Аби Зарр Джундуб ибн Джунада ва Аби Абдиррахман Муаз ибн Джабаль (да будет доволен Аллах ими обоими) от Посланника Аллаха ﷺ передал, что он сказал: иттаки Ллаха хайсума кунта, ва атбиʿи с-саййиʾата ль-хасаната тамхуха, ва халики н-наса би-хулюкин хасанин.',
  -- translation
  'On the authority of Abu Dharr Jundub ibn Junada and Abu ʿAbd ar-Rahman Muʿadh ibn Jabal (may Allah be pleased with them both), the Messenger of Allah ﷺ said: "Fear Allah wherever you are, follow a bad deed with a good one and it will erase it, and treat people with good character."',
  'D''après Abû Dharr Jundub ibn Junâda et Abû ʿAbd ar-Rahmân Muʿâdh ibn Jabal (qu''Allah les agrée tous deux), l''Envoyé d''Allah ﷺ a dit : « Crains Allah où que tu sois, fais suivre la mauvaise action d''une bonne action, elle l''effacera, et comporte-toi envers les gens avec une bonne moralité. »',
  'Nach Abu Dharr Jundub ibn Junada und Abu ʿAbd ar-Rahman Muʿadh ibn Jabal (möge Allah mit beiden zufrieden sein) sagte der Gesandte Allahs ﷺ: „Fürchte Allah, wo immer du bist, lass auf eine schlechte Tat eine gute folgen, sie wird sie auslöschen, und begegne den Menschen mit gutem Charakter."',
  'Op gezag van Abu Dharr Jundub ibn Junada en Abu ʿAbd ar-Rahman Muʿadh ibn Jabal (moge Allah tevreden met hen beiden zijn) zei de Boodschapper van Allah ﷺ: „Vrees Allah waar je ook bent, laat op een slechte daad een goede volgen, die zal haar uitwissen, en ga met de mensen om met goed karakter."',
  'Ebû Zer Cündüb ibn Cünâde ve Ebû Abdurrahman Muâz ibn Cebel''den (Allah her ikisinden de razı olsun) rivayet edildiğine göre Resûlullah ﷺ şöyle buyurdu: „Nerede olursan ol Allah''tan kork (sakın); kötülüğün ardından bir iyilik yap ki onu silsin; ve insanlara güzel ahlakla muamele et."',
  'Dari Abu Dzarr Jundub bin Junadah dan Abu Abdurrahman Muʿadz bin Jabal (semoga Allah meridhai keduanya), Rasulullah ﷺ bersabda: "Bertakwalah kepada Allah di mana pun engkau berada, iringilah perbuatan buruk dengan perbuatan baik niscaya ia akan menghapusnya, dan pergaulilah manusia dengan akhlak yang baik."',
  'ابو ذر جندب بن جنادہ اور ابو عبد الرحمن معاذ بن جبل رضی اللہ عنہما سے روایت ہے کہ رسول اللہ ﷺ نے فرمایا: ”جہاں کہیں بھی ہو اللہ سے ڈرو، اور برائی کے بعد نیکی کرو جو اسے مٹا دے گی، اور لوگوں کے ساتھ اچھے اخلاق سے پیش آؤ۔“',
  'আবু যার জুনদুব ইবনে জুনাদা ও আবু আবদুর রহমান মুআয ইবনে জাবাল (রাদিয়াল্লাহু আনহুমা) থেকে বর্ণিত, রাসূলুল্লাহ ﷺ বলেছেন: "তুমি যেখানেই থাকো আল্লাহকে ভয় করো, মন্দ কাজের পর ভালো কাজ করো যা তা মুছে দেবে, এবং মানুষের সাথে উত্তম চরিত্রে আচরণ করো।"',
  'Daripada Abu Dzarr Jundub bin Junadah dan Abu Abdul Rahman Muʿadz bin Jabal (semoga Allah meredai keduanya), Rasulullah ﷺ bersabda: "Bertakwalah kepada Allah di mana sahaja engkau berada, iringilah perbuatan buruk dengan perbuatan baik nescaya ia akan menghapuskannya, dan pergaulilah manusia dengan akhlak yang baik."',
  'Со слов Абу Зарра Джундуба ибн Джунады и Абу ʿАбд ар-Рахмана Муаза ибн Джабаля (да будет доволен Аллах ими обоими) Посланник Аллаха ﷺ сказал: «Бойся Аллаха, где бы ты ни был, и вслед за дурным поступком соверши добрый — он сотрёт его, и обходись с людьми, проявляя благой нрав».',
  -- reference
  'Hasan — reported by Ahmad (5/153), ad-Darimi (2/323), and at-Tirmidhi (no. 1987), who said: "A good hadith (hasan); in some copies: hasan sahih."',
  'Hadith hasan rapporté par Ahmad (5/153), ad-Dârimî (2/323) et at-Tirmidhî (n°1987), qui a dit : « Hadith hasan ; dans certaines copies : hasan sahih. »',
  'حديث حسن، رواه أحمد (٥/١٥٣) والدارمي (٢/٣٢٣) والترمذي (رقم ١٩٨٧) وقال: حديث حسن، وفي بعض النسخ: حسن صحيح',
  'Hasan — überliefert von Ahmad (5/153), ad-Darimi (2/323) und at-Tirmidhi (Nr. 1987), der sagte: „Ein guter Hadith (hasan); in einigen Abschriften: hasan sahih."',
  'Hasan — overgeleverd door Ahmad (5/153), ad-Darimi (2/323) en at-Tirmidhi (nr. 1987), die zei: „Een goede hadith (hasan); in sommige afschriften: hasan sahih."',
  'Hasen — Ahmed (5/153), Dârimî (2/323) ve Tirmizî (no. 1987) rivayet etmiştir; Tirmizî: „Hasen bir hadistir; bazı nüshalarda: hasen-sahih" demiştir',
  'Hadis hasan, diriwayatkan oleh Ahmad (5/153), ad-Darimi (2/323), dan at-Tirmidzi (no. 1987), yang berkata: "Hadis hasan; dalam sebagian naskah: hasan sahih."',
  'حسن حدیث، اسے احمد (۵/۱۵۳)، دارمی (۲/۳۲۳) اور ترمذی (نمبر ۱۹۸۷) نے روایت کیا، اور ترمذی نے کہا: حدیث حسن ہے، اور بعض نسخوں میں: حسن صحیح',
  'হাসান হাদীস — আহমাদ (৫/১৫৩), দারিমী (২/৩২৩) ও তিরমিযী (নং ১৯৮৭) বর্ণনা করেছেন; তিরমিযী বলেছেন: "হাদীসটি হাসান; কোনো কোনো কপিতে: হাসান সহীহ।"',
  'Hadis hasan, diriwayatkan oleh Ahmad (5/153), ad-Darimi (2/323), dan at-Tirmizi (no. 1987), yang berkata: "Hadis hasan; dalam sebahagian naskhah: hasan sahih."',
  'Хороший (хасан) хадис, передали Ахмад (5/153), ад-Дарими (2/323) и ат-Тирмизи (№ 1987), который сказал: «Хадис хасан; в некоторых списках: хасан сахих».',
  -- tafsir
  '"Fear (Allah)": this is an imperative verb derived from the word taqwa (mindful fear), which is to protect oneself against the punishment of Allah by fulfilling His commands and avoiding His prohibitions — this is the most correct definition. "Fear Allah wherever you are": do not fear Allah only in a place where people see you, but fear Him also where people do not see you. "Follow a bad deed with a good one": when you commit a bad deed, follow it with a good deed; indeed, repenting to Allah from that bad deed is itself a good deed. "It will erase it": if a good deed comes after a bad deed, it erases it, for the Exalted said: {Indeed, good deeds do away with bad deeds} (11:114). "Treat people with good character": this is good conduct towards people.',
  '« Crains » : c''est un verbe à l''impératif venant du mot taqwâ (prémunition), qui est le fait de se prémunir contre le châtiment d''Allah en accomplissant Ses ordres et en évitant Ses interdits — c''est la définition la plus correcte. « Crains Allah où que tu sois » : ne crains pas Allah seulement là où les gens te voient, mais crains-Le aussi là où les gens ne te voient pas. « Fais suivre la mauvaise action d''une bonne action » : quand tu commets une mauvaise action, fais-la suivre d''une bonne action ; d''ailleurs, se repentir à Allah de cette mauvaise action est en soi une bonne action. « Elle l''effacera » : si une bonne action vient après une mauvaise action, elle l''efface, car le Très-Haut a dit : {Les bonnes actions dissipent les mauvaises} (11:114). « Comporte-toi envers les gens avec une bonne moralité » : c''est le bon comportement envers les gens.',
  '«اتق»: فعل أمر من التقوى، وهي أن يقي الإنسان نفسه عذاب الله بفعل أوامره واجتناب نواهيه، وهذا أصح تعريف. «اتق الله حيثما كنت»: لا تتق الله في المكان الذي يراك فيه الناس فحسب، بل اتقه أيضاً في المكان الذي لا يراك فيه الناس. «وأتبع السيئة الحسنة»: إذا عملت سيئة فأتبعها حسنة، والتوبة إلى الله من تلك السيئة هي في نفسها حسنة. «تمحها»: إذا جاءت الحسنة بعد السيئة محتها، فقد قال تعالى: {إن الحسنات يذهبن السيئات} (١١:١١٤). «وخالق الناس بخلق حسن»: أي عاملهم بالخلق الحسن.',
  '„Fürchte": dies ist ein Befehlsverb, abgeleitet vom Wort Taqwa (gottesfürchtige Vorsicht), nämlich dass der Mensch sich vor der Strafe Allahs schützt, indem er Seine Gebote erfüllt und Seine Verbote meidet — dies ist die korrekteste Definition. „Fürchte Allah, wo immer du bist": fürchte Allah nicht nur an einem Ort, wo die Menschen dich sehen, sondern fürchte Ihn auch dort, wo die Menschen dich nicht sehen. „Lass auf eine schlechte Tat eine gute folgen": wenn du eine schlechte Tat begehst, lass eine gute Tat folgen; ja, die Reue zu Allah von jener schlechten Tat ist selbst eine gute Tat. „Sie wird sie auslöschen": kommt eine gute Tat nach einer schlechten, so löscht sie diese aus, denn der Erhabene sagte: {Wahrlich, die guten Taten lassen die schlechten verschwinden} (11:114). „Begegne den Menschen mit gutem Charakter": das ist gutes Verhalten den Menschen gegenüber.',
  '„Vrees": dit is een gebiedend werkwoord, afgeleid van het woord taqwa (godvruchtige voorzichtigheid), namelijk dat de mens zichzelf beschermt tegen de bestraffing van Allah door Zijn geboden te vervullen en Zijn verboden te mijden — dit is de juiste definitie. „Vrees Allah waar je ook bent": vrees Allah niet alleen op een plaats waar de mensen je zien, maar vrees Hem ook waar de mensen je niet zien. „Laat op een slechte daad een goede volgen": wanneer je een slechte daad begaat, laat er een goede daad op volgen; sterker nog, berouw tonen aan Allah van die slechte daad is op zichzelf een goede daad. „Die zal haar uitwissen": als een goede daad na een slechte komt, wist zij die uit, want de Verhevene zei: {Voorwaar, de goede daden doen de slechte verdwijnen} (11:114). „Ga met de mensen om met goed karakter": dat is goed gedrag jegens de mensen.',
  '„Kork (sakın)": bu, takvâ kelimesinden türeyen bir emir fiilidir; takvâ, insanın Allah''ın emirlerini yerine getirip yasaklarından kaçınarak kendini Allah''ın azabından koruması demektir — en doğru tanım budur. „Nerede olursan ol Allah''tan kork": Allah''tan yalnızca insanların seni gördüğü yerde değil, görmediği yerde de kork. „Kötülüğün ardından bir iyilik yap": bir kötülük işlediğinde ardından bir iyilik yap; nitekim o kötülükten Allah''a tövbe etmek bizzat bir iyiliktir. „Onu silsin": iyilik kötülüğün ardından gelirse onu siler; zira Yüce Allah şöyle buyurdu: {Şüphesiz iyilikler kötülükleri giderir} (11:114). „İnsanlara güzel ahlakla muamele et": yani onlara güzel ahlakla davran.',
  '"Bertakwalah": ini adalah kata kerja perintah yang berasal dari kata takwa, yaitu seseorang menjaga dirinya dari azab Allah dengan menjalankan perintah-Nya dan menjauhi larangan-Nya — inilah definisi yang paling benar. "Bertakwalah kepada Allah di mana pun engkau berada": janganlah bertakwa kepada Allah hanya di tempat yang dilihat manusia, tetapi bertakwalah juga di tempat yang tidak dilihat manusia. "Iringilah perbuatan buruk dengan perbuatan baik": apabila engkau melakukan keburukan, iringilah dengan kebaikan; bahkan bertaubat kepada Allah dari keburukan itu sendiri merupakan kebaikan. "Niscaya ia menghapusnya": apabila kebaikan datang setelah keburukan, ia menghapusnya, sebab Allah Taʿala berfirman: {Sesungguhnya kebaikan-kebaikan itu menghapuskan keburukan-keburukan} (11:114). "Pergaulilah manusia dengan akhlak yang baik": yaitu memperlakukan mereka dengan akhlak yang baik.',
  '”ڈرو“: یہ تقویٰ سے ماخوذ فعلِ امر ہے، اور تقویٰ یہ ہے کہ انسان اللہ کے احکام بجا لا کر اور اس کی منہیات سے بچ کر اپنے آپ کو اللہ کے عذاب سے بچائے — یہی سب سے درست تعریف ہے۔ ”جہاں کہیں بھی ہو اللہ سے ڈرو“: اللہ سے صرف اس جگہ نہ ڈرو جہاں لوگ تمہیں دیکھتے ہیں، بلکہ اس جگہ بھی ڈرو جہاں لوگ تمہیں نہیں دیکھتے۔ ”برائی کے بعد نیکی کرو“: جب تم کوئی برائی کرو تو اس کے بعد نیکی کرو؛ بلکہ اس برائی سے اللہ کی طرف توبہ کرنا بذاتِ خود ایک نیکی ہے۔ ”جو اسے مٹا دے گی“: اگر نیکی برائی کے بعد آئے تو اسے مٹا دیتی ہے، اللہ تعالیٰ نے فرمایا: {بے شک نیکیاں برائیوں کو مٹا دیتی ہیں} (۱۱:۱۱۴)۔ ”لوگوں کے ساتھ اچھے اخلاق سے پیش آؤ“: یعنی ان کے ساتھ اچھے اخلاق سے معاملہ کرو۔',
  '"ভয় করো": এটি তাকওয়া শব্দ থেকে উদ্ভূত একটি আদেশসূচক ক্রিয়া, আর তাকওয়া হলো মানুষ আল্লাহর আদেশ পালন করে ও তাঁর নিষেধাজ্ঞা এড়িয়ে নিজেকে আল্লাহর শাস্তি থেকে রক্ষা করা — এটিই সবচেয়ে সঠিক সংজ্ঞা। "তুমি যেখানেই থাকো আল্লাহকে ভয় করো": কেবল যেখানে মানুষ তোমাকে দেখে সেখানেই আল্লাহকে ভয় করো না, বরং যেখানে মানুষ তোমাকে দেখে না সেখানেও ভয় করো। "মন্দ কাজের পর ভালো কাজ করো": যখন তুমি কোনো মন্দ কাজ করো, তখন তার পরে ভালো কাজ করো; বরং সেই মন্দ কাজ থেকে আল্লাহর নিকট তওবা করাই নিজে একটি ভালো কাজ। "যা তা মুছে দেবে": যদি মন্দ কাজের পর ভালো কাজ আসে, তা তা মুছে দেয়, কারণ আল্লাহ তাআলা বলেছেন: {নিশ্চয়ই সৎকর্ম অসৎকর্মকে মুছে দেয়} (১১:১১৪)। "মানুষের সাথে উত্তম চরিত্রে আচরণ করো": অর্থাৎ তাদের সাথে উত্তম চরিত্রে আচরণ করো।',
  '"Bertakwalah": ini ialah kata kerja perintah yang berasal daripada kata takwa, iaitu seseorang menjaga dirinya daripada azab Allah dengan melaksanakan perintah-Nya dan menjauhi larangan-Nya — inilah takrif yang paling tepat. "Bertakwalah kepada Allah di mana sahaja engkau berada": janganlah bertakwa kepada Allah hanya di tempat yang dilihat manusia, tetapi bertakwalah juga di tempat yang tidak dilihat manusia. "Iringilah perbuatan buruk dengan perbuatan baik": apabila engkau melakukan keburukan, iringilah dengan kebaikan; bahkan bertaubat kepada Allah daripada keburukan itu sendiri merupakan kebaikan. "Nescaya ia menghapuskannya": apabila kebaikan datang selepas keburukan, ia menghapuskannya, kerana Allah Taʿala berfirman: {Sesungguhnya kebaikan-kebaikan itu menghapuskan keburukan-keburukan} (11:114). "Pergaulilah manusia dengan akhlak yang baik": iaitu memperlakukan mereka dengan akhlak yang baik.',
  '«Бойся»: это глагол повелительного наклонения, производный от слова таква (богобоязненная осторожность), а именно — чтобы человек оберегал себя от наказания Аллаха, исполняя Его повеления и избегая Его запретов; это наиболее верное определение. «Бойся Аллаха, где бы ты ни был»: бойся Аллаха не только там, где тебя видят люди, но и там, где люди тебя не видят. «Вслед за дурным поступком соверши добрый»: когда ты совершаешь дурной поступок, соверши вслед за ним добрый; более того, покаяние перед Аллахом за этот дурной поступок само по себе является добрым делом. «Он сотрёт его»: если доброе дело приходит вслед за дурным, оно стирает его, ибо Всевышний сказал: {Поистине, добрые деяния удаляют дурные} (11:114). «Обходись с людьми, проявляя благой нрав»: то есть относись к ним с благим нравом.',
  -- audio_url, ajr, position
  'https://www.40-hadith-nawawi.com/wp-content/uploads/2022/08/Hadith-18-Nawawi-Psalmodie-Arabe.mp3',
  5,
  18
where not exists (
  select 1 from public.hadiths
  where hadith_collection_id = 2 and position = 18
);
