-- =============================================================================
-- 40 Hadith Nawawi — Hadith 3: "The Pillars of Islam"
-- Target collection: public.hadith_collections.id = 2  /  position = 3
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
  'The Pillars of Islam',
  'Les piliers de l''Islam',
  'أركان الإسلام',
  'Die Säulen des Islam',
  'De zuilen van de islam',
  'İslam''ın esasları',
  'Rukun-rukun Islam',
  'اسلام کے ارکان',
  'ইসলামের স্তম্ভসমূহ',
  'Rukun-rukun Islam',
  'Столпы ислама',
  -- arabic_text
  'عَنْ عَبْدِ اللَّهِ بْنِ عُمَرَ رَضِيَ اللَّهُ عَنْهُمَا قَالَ: قَالَ النَّبِيُّ صَلَّى اللَّهُ عَلَيْهِ وَسَلَّمَ: «بُنِيَ الْإِسْلَامُ عَلَى خَمْسٍ: شَهَادَةِ أَنْ لَا إِلَهَ إِلَّا اللَّهُ وَأَنَّ مُحَمَّدًا رَسُولُ اللَّهِ، وَإِقَامِ الصَّلَاةِ، وَإِيتَاءِ الزَّكَاةِ، وَصَوْمِ رَمَضَانَ، وَالْحَجِّ»',
  -- transcription
  'ʿan ʿAbdi Llāhi bni ʿUmara raḍiya Llāhu ʿanhumā qāla: qāla n-Nabiyyu ṣalla Llāhu ʿalayhi wa-sallama: buniya l-islāmu ʿalā khamsin: shahādati an lā ilāha illa Llāhu wa-anna Muḥammadan Rasūlu Llāhi, wa-iqāmi ṣ-ṣalāti, wa-ītāʾi z-zakāti, wa-ṣawmi Ramaḍāna, wa-l-ḥajj.',
  'ʿan ʿAbdi Llâhi bni ʿOumar (radia Llâhou ʿanhoumâ) qâla : qâla n-Nabiyyou (salla Llâhou ʿalayhi wa sallam) : bouniya l-islâmou ʿalâ khamsin : chahâdati an lâ ilâha illa Llâh wa anna Mouhammadan Rassôlou Llâh, wa iqâmi s-salât, wa îtâʾi z-zakât, wa sawmi Ramadân, wa l-hajj.',
  'ʿan ʿAbdi Llāhi bni ʿUmar (radiya Llāhu ʿanhumā) qāla: qāla n-Nabijju (salla Llāhu ʿalaihi wa-sallam): bunija l-islāmu ʿalā chamsin: schahādati an lā ilāha illa Llāh wa-anna Muhammadan Rasūlu Llāh, wa-iqāmi s-salāt, wa-ītāʾi z-zakāt, wa-sawmi Ramadān, wa-l-hadschdsch.',
  'ʿan ʿAbdi Llaahi bni ʿOemar (radia Llaahoe ʿanhoemaa) qaala: qaala n-Nabijjoe (salla Llaahoe ʿalaihi wa-sallam): boenija l-islaamoe ʿalaa chamsin: sjahaadati an laa ilaaha illa Llaah wa-anna Moehammadan Rasoeloe Llaah, wa-iqaami s-salaat, wa-ietaaʾi z-zakaat, wa-sawmi Ramadaan, wa-l-hadzjdzj.',
  'an Abdullah ibn Ömer''den (radıyallâhu anhümâ) rivayetle Nebî (s.a.v.) şöyle buyurdu: İslâm beş esas üzerine kurulmuştur: Allah''tan başka ilâh olmadığına ve Muhammed''in Allah''ın Resûlü olduğuna şehâdet etmek, namazı kılmak, zekâtı vermek, Ramazan orucunu tutmak ve haccetmek.',
  'ʿan ʿAbdillāh bin ʿUmar (radhiyallāhu ʿanhumā) berkata: Nabi (shallallāhu ʿalaihi wa sallam) bersabda: bunival-islāmu ʿalā khamsin: syahādati an lā ilāha illallāh wa anna Muhammadan Rasūlullāh, wa iqāmish-shalāh, wa ītāʾiz-zakāh, wa shaumi Ramadhān, wal-hajj.',
  'عبد اللہ بن عمر رضی اللہ عنہما سے روایت ہے، نبی صلی اللہ علیہ وسلم نے فرمایا: بُنِیَ الاِسلامُ عَلٰی خَمسٍ: شَہادَۃِ اَن لا اِلٰہَ اِلَّا اللہُ وَاَنَّ مُحَمَّدًا رَسُولُ اللہِ، وَاِقامِ الصَّلاۃِ، وَاِیتاءِ الزَّکاۃِ، وَصَومِ رَمَضانَ، وَالحَجِّ۔',
  'আবদুল্লাহ ইবনে উমার (রাদিয়াল্লাহু আনহুমা) থেকে বর্ণিত, নবী (সাল্লাল্লাহু আলাইহি ওয়া সাল্লাম) বলেছেন: বুনিয়াল ইসলামু আলা খামসিন: শাহাদাতি আন লা ইলাহা ইল্লাল্লাহু ওয়া আন্না মুহাম্মাদান রাসূলুল্লাহি, ওয়া ইকামিস সালাতি, ওয়া ঈতাইজ যাকাতি, ওয়া সাওমি রামাদান, ওয়াল হাজ্জ।',
  'ʿan ʿAbdillāh bin ʿUmar (radhiallāhu ʿanhumā) berkata: Nabi (sallallāhu ʿalaihi wa sallam) bersabda: bunival-islāmu ʿalā khamsin: syahādati an lā ilāha illallāh wa anna Muhammadan Rasūlullāh, wa iqāmish-solāh, wa ītāʾiz-zakāh, wa saumi Ramadān, wal-hajj.',
  'Ан Абдиллях ибн Умар (да будет доволен Аллах ими обоими) сказал: Пророк ﷺ сказал: буниял-ислям аля хамсин: шахáдати ан ля иляха илля Ллах ва анна Мухаммадан Расулу Ллах, ва икáми с-салят, ва итáʾи з-закят, ва сауми Рамадáн, ва-ль-хадж.',
  -- translation
  'On the authority of Abu ʿAbd ar-Rahman ʿAbd Allah ibn ʿUmar (may Allah be pleased with them both), the Messenger of Allah ﷺ said: "Islam is built upon five: the testimony that there is no god but Allah and that Muhammad is the Messenger of Allah, the establishment of the prayer, the giving of the zakat, the fasting of Ramadan, and the pilgrimage (Hajj)."',
  'D''après Abû ʿAbd ar-Rahman ʿAbd Allah ibn ʿUmar (qu''Allah les agrée tous deux), l''Envoyé d''Allah ﷺ a dit : « L''Islam est bâti sur cinq : l''attestation qu''il n''est de dieu digne d''adoration qu''Allah et que Muhammad est l''Envoyé d''Allah, l''accomplissement de la prière, l''acquittement de l''aumône légale (zakât), le jeûne du mois de Ramadan, et le pèlerinage. »',
  'Nach Abu ʿAbd ar-Rahman ʿAbd Allah ibn ʿUmar (möge Allah mit beiden zufrieden sein) sagte der Gesandte Allahs ﷺ: „Der Islam ist auf fünf (Säulen) erbaut: das Zeugnis, dass es keinen Gott außer Allah gibt und dass Muhammad der Gesandte Allahs ist, das Verrichten des Gebets, das Entrichten der Zakat, das Fasten im Ramadan und die Pilgerfahrt (Hadsch)."',
  'Op gezag van Abu ʿAbd ar-Rahman ʿAbd Allah ibn ʿUmar (moge Allah tevreden met hen beiden zijn) zei de Boodschapper van Allah ﷺ: „De islam is gebouwd op vijf (zuilen): het getuigenis dat er geen god is behalve Allah en dat Muhammad de Boodschapper van Allah is, het verrichten van het gebed, het geven van de zakat, het vasten in de Ramadan en de bedevaart (Hadj)."',
  'Abdullah ibn Ömer''den (Allah her ikisinden de razı olsun) rivayet edildiğine göre, Resûlullah ﷺ şöyle buyurdu: „İslâm beş esas üzerine kurulmuştur: Allah''tan başka ilâh olmadığına ve Muhammed''in Allah''ın Resûlü olduğuna şehâdet etmek, namazı kılmak, zekâtı vermek, Ramazan orucunu tutmak ve haccetmek."',
  'Dari Abu Abdurrahman Abdullah bin Umar (semoga Allah meridhai keduanya), Rasulullah ﷺ bersabda: "Islam dibangun di atas lima perkara: bersaksi bahwa tidak ada tuhan yang berhak disembah selain Allah dan bahwa Muhammad adalah utusan Allah, mendirikan shalat, menunaikan zakat, berpuasa Ramadhan, dan menunaikan haji."',
  'ابو عبد الرحمن عبد اللہ بن عمر رضی اللہ عنہما سے روایت ہے کہ رسول اللہ ﷺ نے فرمایا: ”اسلام کی بنیاد پانچ چیزوں پر ہے: اس بات کی گواہی دینا کہ اللہ کے سوا کوئی معبود نہیں اور محمد اللہ کے رسول ہیں، نماز قائم کرنا، زکوٰۃ ادا کرنا، رمضان کے روزے رکھنا اور حج کرنا۔“',
  'আবু আবদুর রহমান আবদুল্লাহ ইবনে উমার (রাদিয়াল্লাহু আনহুমা) থেকে বর্ণিত, রাসূলুল্লাহ ﷺ বলেছেন: "ইসলাম পাঁচটি স্তম্ভের ওপর প্রতিষ্ঠিত: সাক্ষ্য দেওয়া যে আল্লাহ ছাড়া কোনো ইলাহ নেই এবং মুহাম্মাদ আল্লাহর রাসূল, সালাত কায়েম করা, যাকাত প্রদান করা, রমজানের সিয়াম পালন করা এবং হজ করা।"',
  'Daripada Abu Abdul Rahman Abdullah bin Umar (semoga Allah meredai keduanya), Rasulullah ﷺ bersabda: "Islam dibina atas lima perkara: bersaksi bahawa tiada tuhan yang berhak disembah melainkan Allah dan bahawa Muhammad ialah utusan Allah, mendirikan solat, menunaikan zakat, berpuasa Ramadan, dan mengerjakan haji."',
  'Со слов Абу ʿАбд ар-Рахмана ʿАбдуллаха ибн ʿУмара (да будет доволен Аллах ими обоими) Посланник Аллаха ﷺ сказал: «Ислам построен на пяти (столпах): свидетельстве, что нет божества, кроме Аллаха, и что Мухаммад — Посланник Аллаха, совершении молитвы, выплате закята, посте в Рамадан и совершении хаджа».',
  -- reference
  'Sahih — reported by Al-Bukhari in his Sahih (no. 8) and Muslim in his Sahih (no. 16)',
  'Hadith authentique rapporté par Al-Bukhari dans son Sahih (n°8) et Muslim dans son Sahih (n°16)',
  'حديث صحيح، رواه البخاري في صحيحه (رقم ٨) ومسلم في صحيحه (رقم ١٦)',
  'Sahih — überliefert von Al-Bukhari in seinem Sahih (Nr. 8) und Muslim in seinem Sahih (Nr. 16)',
  'Sahih — overgeleverd door Al-Bukhari in zijn Sahih (nr. 8) en Muslim in zijn Sahih (nr. 16)',
  'Sahih — Buhârî Sahîh''inde (no. 8) ve Müslim Sahîh''inde (no. 16) rivayet etmiştir',
  'Hadis sahih, diriwayatkan oleh Al-Bukhari dalam Sahih-nya (no. 8) dan Muslim dalam Sahih-nya (no. 16)',
  'صحیح حدیث، اسے بخاری نے اپنی صحیح میں (نمبر ۸) اور مسلم نے اپنی صحیح میں (نمبر ۱۶) روایت کیا',
  'সহীহ হাদীস — বুখারী তাঁর সহীহতে (নং ৮) ও মুসলিম তাঁর সহীহতে (নং ১৬) বর্ণনা করেছেন',
  'Hadis sahih, diriwayatkan oleh Al-Bukhari dalam Sahihnya (no. 8) dan Muslim dalam Sahihnya (no. 16)',
  'Достоверный хадис, передали аль-Бухари в своём «Сахихе» (№ 8) и Муслим в своём «Сахихе» (№ 16)',
  -- tafsir
  'In this hadith, the Prophet ﷺ showed that Islam is like a building in which its owner takes shelter and protects himself, and that it is built upon five things: the testimony that there is no god worthy of worship except Allah and that Muhammad is the Messenger of Allah, the establishment of the prayer, the giving of the zakat, the fasting of Ramadan, and the pilgrimage to the House. We have already discussed the five pillars in the hadith reported by ʿUmar ibn al-Khattab.',
  'Dans ce hadith, le Prophète ﷺ a montré que l''Islam est comme une construction dans laquelle son propriétaire s''abrite et se protège, et qu''il est bâti sur cinq choses : le témoignage qu''il n''est de dieu digne d''adoration qu''Allah et que Muhammad est l''Envoyé d''Allah, l''accomplissement de la prière, l''acquittement de la zakât, le jeûne de Ramadan et le pèlerinage vers la Maison. Nous avons précédemment parlé des cinq piliers dans le hadith rapporté par ʿUmar ibn al-Khattab.',
  'في هذا الحديث بيّن النبي صلى الله عليه وسلم أن الإسلام كالبناء الذي يأوي إليه صاحبه ويحتمي به، وأنه مبني على خمسة أشياء: شهادة أن لا إله إلا الله وأن محمداً رسول الله، وإقام الصلاة، وإيتاء الزكاة، وصوم رمضان، والحج إلى البيت. وقد سبق الكلام على الأركان الخمسة في حديث عمر بن الخطاب.',
  'In diesem Hadith zeigte der Prophet ﷺ, dass der Islam wie ein Gebäude ist, in dem sein Besitzer Schutz und Zuflucht findet, und dass er auf fünf Dingen erbaut ist: dem Zeugnis, dass es keinen Gott außer Allah gibt und dass Muhammad der Gesandte Allahs ist, dem Verrichten des Gebets, dem Entrichten der Zakat, dem Fasten im Ramadan und der Pilgerfahrt zum Hause. Über die fünf Säulen haben wir bereits im Hadith von ʿUmar ibn al-Khattab gesprochen.',
  'In deze hadith toonde de Profeet ﷺ aan dat de islam als een gebouw is waarin de eigenaar beschutting en bescherming vindt, en dat hij op vijf dingen is gebouwd: het getuigenis dat er geen god is behalve Allah en dat Muhammad de Boodschapper van Allah is, het verrichten van het gebed, het geven van de zakat, het vasten in de Ramadan en de bedevaart naar het Huis. Over de vijf zuilen hebben wij reeds gesproken in de hadith van ʿUmar ibn al-Khattab.',
  'Bu hadiste Peygamber ﷺ, İslâm''ın, sahibinin içinde barındığı ve korunduğu bir bina gibi olduğunu ve beş şey üzerine kurulu olduğunu beyan etmiştir: Allah''tan başka ilâh olmadığına ve Muhammed''in Allah''ın Resûlü olduğuna şehâdet etmek, namazı kılmak, zekâtı vermek, Ramazan orucunu tutmak ve Beyt''e haccetmek. Beş esas hakkında Ömer ibn el-Hattâb hadisinde daha önce konuşmuştuk.',
  'Dalam hadis ini, Nabi ﷺ menjelaskan bahwa Islam itu seperti bangunan yang pemiliknya berlindung dan menjaga diri di dalamnya, dan bahwa ia dibangun di atas lima perkara: bersaksi bahwa tidak ada tuhan yang berhak disembah selain Allah dan bahwa Muhammad adalah utusan Allah, mendirikan shalat, menunaikan zakat, berpuasa Ramadhan, dan berhaji ke Baitullah. Kami telah membahas kelima rukun ini dalam hadis yang diriwayatkan oleh Umar bin al-Khattab.',
  'اس حدیث میں نبی ﷺ نے بیان فرمایا کہ اسلام ایک عمارت کی مانند ہے جس میں اس کا مالک پناہ لیتا اور خود کو محفوظ رکھتا ہے، اور یہ پانچ چیزوں پر بنا ہے: اس بات کی گواہی کہ اللہ کے سوا کوئی معبود نہیں اور محمد اللہ کے رسول ہیں، نماز قائم کرنا، زکوٰۃ ادا کرنا، رمضان کے روزے رکھنا اور بیت اللہ کا حج کرنا۔ ہم پانچ ارکان کے بارے میں عمر بن الخطاب کی حدیث میں پہلے گفتگو کر چکے ہیں۔',
  'এই হাদীসে নবী ﷺ দেখিয়েছেন যে ইসলাম একটি ইমারতের মতো যার মধ্যে এর মালিক আশ্রয় নেয় ও নিজেকে রক্ষা করে, এবং তা পাঁচটি বিষয়ের ওপর নির্মিত: সাক্ষ্য দেওয়া যে আল্লাহ ছাড়া কোনো ইলাহ নেই এবং মুহাম্মাদ আল্লাহর রাসূল, সালাত কায়েম করা, যাকাত প্রদান করা, রমজানের সিয়াম পালন করা এবং বাইতুল্লাহর হজ করা। আমরা পাঁচটি স্তম্ভ সম্পর্কে উমার ইবনুল খাত্তাবের হাদীসে ইতিপূর্বে আলোচনা করেছি।',
  'Dalam hadis ini, Nabi ﷺ menjelaskan bahawa Islam itu seperti sebuah bangunan yang pemiliknya berlindung dan memelihara diri di dalamnya, dan bahawa ia dibina atas lima perkara: bersaksi bahawa tiada tuhan yang berhak disembah melainkan Allah dan bahawa Muhammad ialah utusan Allah, mendirikan solat, menunaikan zakat, berpuasa Ramadan, dan mengerjakan haji ke Baitullah. Kami telah membincangkan kelima-lima rukun ini dalam hadis yang diriwayatkan oleh Umar bin al-Khattab.',
  'В этом хадисе Пророк ﷺ показал, что ислам подобен зданию, в котором его обладатель находит укрытие и защиту, и что он построен на пяти вещах: свидетельстве, что нет божества, достойного поклонения, кроме Аллаха, и что Мухаммад — Посланник Аллаха, совершении молитвы, выплате закята, посте в Рамадан и совершении хаджа к Дому. О пяти столпах мы уже говорили в хадисе, переданном Умаром ибн аль-Хаттабом.',
  -- audio_url, ajr, position
  'https://www.40-hadith-nawawi.com/wp-content/uploads/2022/08/Hadith-3-Nawawi-Psalmodie-Arabe.mp3',
  5,
  3
where not exists (
  select 1 from public.hadiths
  where hadith_collection_id = 2 and position = 3
);
