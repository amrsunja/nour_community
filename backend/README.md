# Nour Community Backend

## Supabase

The backend of the nour app was created with Supabase so in this folder you can find all supabase configurations, migrations, keys etc...


##### Local App features
It means that this faetures I will implement in the app with libraries and this datas will be static wich means that if we want to change something we need to update the app version

- quran 
- ayahs
- zakat calculator
- qibla finder
- prayer time
- hijri calendar,

##### Remote App features (with Supabase)
It means that this faetures I will implement in the supabase and app will fetch this datas wich means that if we want to change something we need to update it in the supabase and app will recieve the last updated data

- Sign In & Sign Up (anonime, email & password, google, apple)
- Dhikr list (admin can add many dhikrs from supabase)
- Adhkar list (admin can add many adhkars from supabase)
- Quizs (each quiz has 5 options)
- Hadiths
- Ajr system for each user action he will recieve some ajr depending on the action category (dhikrs, adhkar, duas, ayahs, quizs) I think we need to create some table for this where we can see al ajr that user wins 
- Profile progress system (earned ajr counts, completed dhikrs, completed deeds) we can filter them by all time, week and today
- Streak system (max 7 days streak wich means one week)
- Impact projects list (projects for zakat, dons)
- Transactions list (we need to save each user transaction)
- Favorite list (we can add ayahs, duas, and impact projects)


## Supabase Structure and general logic


#### Enums

This enums will be core enums for bougth app and backend and they should be used inside the models

**levelType**: (begining, growing, established, returning)
**genderType**: (male, female)
**languageType**: (en, fr, ar)
**errorKey**: (error_message_key...) for supabase edge functions etc.. that we will return for some logic

#### Supabase error model

This error message should be returned for each edge function or supabase api calling error response

```json
{
  "key": "errorKey",
  "message": "Description error message",
}
```


#### Authorization - Sign in & Sign up

I want that the user connects automaticaly with anonime session but after he can connect his anonime session with real account (he can do it with sign in or sign up after)
here is the official documentation that you need to know [https://supabase.com/docs/guides/auth/auth-anonymous?queryGroups=language&language=dart]

##### User Model
```json
{
  "id": 1, //int unique
  "email": "emai@gmail.com",  // Email unique field
  "name": "Amir Azdoyev", // String
  "avatar_url": "https://link_to", // Can be null,
  "gender": "GenderType or null", // genderType enum - can be null
  "level": "LevelType or null", // levelType enum - can be null
  "language": "LanguageType or null", // languageType enum
  "onboarding_completed": false,
  "last_onboarding_screen": 4, // this is a last onboaridng screen where user was before completing it
  "daily_practice_time": 5, // minutes - int,
}
```

#### Onboarding

After ther user connects to anonime session or real session he will see the onboarding. And for each screen the data that the user will select will be automatically saved to the profile of this user session.
And after the field `onboarding_completed` will be true

We will have 10 screens of this feature
- Welcome
- Everything you need overview
- Build a beatiful daily routine
- Where are you on your journey? (selected LevelType for the profile we need this info for the V2 for the future)
- How much time daily? (selected the minutes that user will pass on the app we need this info for the V2 for the future)
- Gentle Reminders (this data is not setted on supabase I will save them on local app storage)
- Choose a favorite reciter voice (this data I will save for the local app storage beacause I will use a local quran library)
- Choose lanaguage (this info will be saved on supabase profile table)
- Tell us about yourself (the screen where we enter the profile name and select the GenderType)
- Let's create your account (the screen where user can skip or sign in or sign up to his old or new account)


#### Home Page

This is page where we can see the 
1. User app bar info, streak info, 
2. Daily ajr goal widget where we see a big progress of his minimum daily dhikr by default it will be the 66 and big button start dhikr.
3. After that we see the Quick Actions block and inside this block we see the:
- Daily Ayah,
- Daily Dua,
- Daily Quiz, 

4. After we see the block Next prayer

5. Quick tools we see the blocks
- Qibla Finder
- Prayer time
- Hidjri Calendar

6. We can see the Nour Impact projects first three projects


#### Dhikr page

In this page we can see the list of daily dhikrs. Min value of Dhirk is by default 33 (value from supabase model). This page has two main blocks
1. Continue Dhikr - in this block the user can see his started before dhikrs but that is not finished. 
For example the minimum dhikr is 33 and user maked only 20 so he will see this dhikr in this block and he can continue.
2. Essential dhikr - here he can find all finished Dhirks or not started dhikrs.

Very important notes
- the user can make dhikr more that minimum value (33). It means that user total count of user dhikrs per day can be more that minimum value (33). for example like this 156(today)/33 (state: completed)
- Each dhikr has his ajr. It means when user complete the dhikr he will recieve auomatically the ajr on his profile it should be and trigger or auto funtion in supabase.

##### Dhikr Model
```json
{
  "id": 1, //int unique
  "arabic_text": "سُبْحَانَ اللَّهِ",
  "transcription_en": "SubhanAllah", 
  "transcription_fr": "SubhanAllah", 
  "translation_en": "Glory be to Allah",
  "translation_fr": "Gloire à Allah", 
  "min_count": 33, // This is the count of how much times the user should to do this dhirk per day,
  "ajr": 5, // Ajr count that user can obtain if user complete the dhikr
}
```

##### Add Datas for the V1
- SubhanAllah, سُبْحَانَ اللَّهِ
- Alhamdulilah, الْحَمْدُ لِلَّهِ
- Allahu Akbar, اللَّهُ أَكْبَرُ
- La ilaha illallah, لَا إِلَٰهَ إِلَّا اللَّهُ
- Astaghfirullah, أَسْتَغْفِرُ اللَّهَ
- Hasbunallah, حَسْبُنَا اللَّهُ
- La hawla wa la quwwata, لَا حَوْلَ وَلَا قُوَّةَ


#### Daily streak 

One daily streak is completed when the user did one daily dhikr and one daily quick action (Ayah or Dua or Quiz).
The maximum value of streak is 7 (one week). And  it will be reseted if the user don't completed his daily streak ones or if the week is finished. (it should be an supabase trigger or db function that refreshes when the Daily Streak conditions is done or break)


#### Daily Adhkar page

On This page we will see the list of all categories and subcategories of adhkars. After for each subcategory we have multiple Adhkars model.

##### Adhkar Category Model
```json
{
  "id": 1, //int unique
  "title_en": "EN title",
  "title_fr": "FR title",
  "title_ar": "AR title",
}
```


##### Adhkar Subcategory Model
```json
{
  "id": 1, //int unique
  "adhkar_category_id": 1, //int unique
  "title_en": "EN title",
  "title_fr": "FR title",
  "title_ar": "AR title",
}
```

##### Adhkar Model
```json
{
  "id": 1, //int unique
  "adhkar_subcategory_id": 1, //int unique
  "arabic_text": "سُبْحَانَ اللّٰهِ وَبِحَمْدِهِ ، عَدَدَ خَلْقِهِ ، وَرِضَا نَفْسِهِ ، وَزِنَةَ عَرْشِهِ ، وَمِدَادَ كَلِمَاتِهِ.",
  "transcription_en": "Transcription text on english",
  "transcription_fr": "Transcription text on french", 
  "translation_en": "Allah is free from imperfection and all praise is due to Him, (in ways) as numerous as all He has created, (as vast) as His pleasure, (as limitless) as the weight of His Throne, and (as endless) as the ink of His words.",
  "translation_fr": "Allah est exempt de toute imperfection et toute louange Lui revient, en nombre aussi grand que tout ce qu’Il a créé, aussi vaste que Son bon plaisir, aussi illimité que le poids de Son Trône, et aussi infini que l’encre de Ses paroles.", 
  "when_en": "Invocation to recite when we wake up",
  "when_fr": "Invocation to recite when we wake up",
  "when_ar": "arabic_when_text",
  "reference_en": "Sahih muslim 2083/4, Sahih Boukhari 113/11",
  "reference_fr": "Sahih muslim 2083/4, Sahih Boukhari 113/11",
  "reference_ar": "صحيح مسلم 2083/4، صحيح البخاري 113/11",
  "min_count": 33, // how many time you need to reread this adhkar,
  "ajr": 5, // Ajr count that user can obtain if user complete this adhkar
  "likes_count": 23, // this value will change dynamically for example trigger functions each time when some user will like the adhkar
}
```



##### Add Datas for the V1
- Daily routine
  - Morning adhkar
  - Evening adhkar
  - Before sleep
  - When waking up
- Hygiene & Wudu
  - Wudu & purification
  - Clothing
- Around salah
  - Adhan & call to prayer
  - Mosque
  - After salah
- In daily life
  - Eating & drinking
  - Entering & leaving home
  - Travel & transit
- Hard moments
  - Anxiety, fear & sadness
  - Health & illness
- By intention
  - Istighfar
  - Protection
  - Gratitude
  - Knowledge


#### Daily Dua page

THis is a daily dua feature. 
We will have a table of duas list in the supabase.
User can access to the daily dua by the Home Page in the quick actions block. The daily dua will opears randomly.


##### Dua Model
```json
{
  "id": 1, //int unique
  "arabic_text": "سُبْحَانَ اللّٰهِ وَبِحَمْدِهِ ، عَدَدَ خَلْقِهِ ، وَرِضَا نَفْسِهِ ، وَزِنَةَ عَرْشِهِ ، وَمِدَادَ كَلِمَاتِهِ.",
  "transcription_en": "Transcription text on english",
  "transcription_fr": "Transcription text on french", 
  "translation_en": "Allah is free from imperfection and all praise is due to Him, (in ways) as numerous as all He has created, (as vast) as His pleasure, (as limitless) as the weight of His Throne, and (as endless) as the ink of His words.",
  "translation_fr": "Allah est exempt de toute imperfection et toute louange Lui revient, en nombre aussi grand que tout ce qu’Il a créé, aussi vaste que Son bon plaisir, aussi illimité que le poids de Son Trône, et aussi infini que l’encre de Ses paroles.", 
  "when_en": "After salah",
  "when_fr": "Apres le prier",
  "when_ar": "arabic_when_text",
  "reference_en": "Sahih muslim 2083/4, Sahih Boukhari 113/11",
  "reference_fr": "Sahih muslim 2083/4, Sahih Boukhari 113/11",
  "reference_ar": "صحيح مسلم 2083/4، صحيح البخاري 113/11",
  "tafsir_en": "Recite once after every obligatory prayer. Aisha (RA) reported the Prophet ﷺ would say this immediately after making salam.",
  "tafsir_fr": "Récitez-la une fois après chaque prière obligatoire. Aïcha (RA) a rapporté que le Prophète ﷺ prononçait ces mots immédiatement après avoir fait le salam.",
  "tafsir_ar": "تُتلى مرة واحدة بعد كل صلاة فريضة. وقد روت عائشة (رضي الله عنها) أن النبي ﷺ كان يقولها فور إلقاء السلام.",
  "audio_url": "String or null", // can be null
  "ajr": 5, // Ajr count that user can obtain if user complete this dua
  "likes_count": 23, // this value will change dynamically for example with supabase functions each time when some user will like the dua
}
```


#### Hadiths

This datas we will recieve from supabase. So we will have table Hadith Collection for example "40 Hadiths Nawawi" or "Buhari",
and for each hadith collection we have hadith model

##### Hadith Collection Model
```json
{
  "id": 1, //int unique
  "title_en": "40 Hadith Nawawi",
  "title_fr": "40 Hadith de Nawawi",
  "title_ar": "سُبْحَانَ اللّٰهِ وَبِحَمْدِهِ ،",
  "description_en": "Imam An-Nawawi | The essential 40",
  "description_fr": "Imam An-Nawawi | The essential 40",
  "description_ar": "Imam An-Nawawi | arabic The essential 40",
}
```


##### Hadith Model
```json
{
  "id": 1, //int unique
  "hadith_collection_id": "HadithCollectionModel.id" int,
  "title_en": "Intentions",
  "title_fr": "Intentions",
  "title_ar": "سُبْحَانَ اللّٰهِ وَبِحَمْدِهِ ،",
  "description_en": "“Actions are (judged) by motives..”",
  "description_fr": "“Actions are (judged) by motives..”",
  "description_ar": "سُبْحَانَ اللّٰهِ وَبِحَمْدِهِ",
  "arabic_text": "سُبْحَانَ اللّٰهِ وَبِحَمْدِهِ ، عَدَدَ خَلْقِهِ ، وَرِضَا نَفْسِهِ ، وَزِنَةَ عَرْشِهِ ، وَمِدَادَ كَلِمَاتِهِ.",
  "transcription_en": "Transcription text on english",
  "transcription_fr": "Transcription text on french", 
  "translation_en": "Allah is free from imperfection and all praise is due to Him, (in ways) as numerous as all He has created, (as vast) as His pleasure, (as limitless) as the weight of His Throne, and (as endless) as the ink of His words.",
  "translation_fr": "Allah est exempt de toute imperfection et toute louange Lui revient, en nombre aussi grand que tout ce qu’Il a créé, aussi vaste que Son bon plaisir, aussi illimité que le poids de Son Trône, et aussi infini que l’encre de Ses paroles.", 
  "reference_en": "Sahih muslim 2083/4, Sahih Boukhari 113/11",
  "reference_fr": "Sahih muslim 2083/4, Sahih Boukhari 113/11",
  "reference_ar": "صحيح مسلم 2083/4، صحيح البخاري 113/11",
  "tafsir_en": "Recite once after every obligatory prayer. Aisha (RA) reported the Prophet ﷺ would say this immediately after making salam.",
  "tafsir_fr": "Récitez-la une fois après chaque prière obligatoire. Aïcha (RA) a rapporté que le Prophète ﷺ prononçait ces mots immédiatement après avoir fait le salam.",
  "tafsir_ar": "تُتلى مرة واحدة بعد كل صلاة فريضة. وقد روت عائشة (رضي الله عنها) أن النبي ﷺ كان يقولها فور إلقاء السلام.",
  "audio_url": "String or null", // can be null
  "ajr": 5, // Ajr count that user can obtain if user complete this adhkar
  "likes_count": 23, // this value will change dynamically for example with supabase functions each time when some user will like the dua
}
```


#### Profile Progress system

Each user has his own progress system, each time when he complete some hadith, quran, Dhikrs, the progress will be saved on a table,
after we need this informations to show where user stoped his hadith, quran, dhikr, etc... And this informations should automatically updated in the table when user save his progress

##### Quran Progress Model (for each user for all time his own model (on user create), we need to do just updates, we need to create it on user creation)
```json
{
  "id": 1, //int unique
  "user_id": 1,
  "current_surah_number": 1,
  "current_ayah_number": 4,
}
```

##### Dhikr Progress Model
We will save the dhikr progress for every day. So each day we have created_at value and depending on this value we will show the dhikr progress on Dhikr Page
```json
{
  "id": 1, //int unique
  "user_id": 1,
  "current_dhikr_id": 1,
  "current_count": 4, 
  "created_at": "DateTime",
}
```


##### Hadith Progress Model (for each user and hadith collection we need to create this model (on user create) to save the user progress of reading hadith)
```json
{
  "id": 1, //int unique
  "user_id": 1,
  "hadith_collection_id": 1, // Daily routins, Around salah etc...
  "current_hadith_id": 2, // Morning adhkar, Before sleep etc...
}
```

##### Dua Progress Model (for each user we need to create this model (on user create) to save the user progress of reading duas, we need to do just updates)
```json
{
  "id": 1, //int unique
  "user_id": 1,
  "hadith_collection_id": 1, // Daily routins, Around salah etc...
  "current_hadith_id": 2, // Morning adhkar, Before sleep etc...
}
```




#### Ajr system

Each user action like reading quran ayah, hadith, making dhikr, daily dua gives hime some ajr it is like HP and this value he can see in his profile page after in statistics tab. 
I want that this ajr calculats to user each time when he makes some progress (ayah, dhikr, hadith, daily dua) automaticaly like a trigger function. It should be an table where we can find something like this:


In the profile page in statistics table we will show all ajr that user earned for all time, week, today by created_at

##### Ajr Model
```json
{
  "id": 1, //int unique
  "user_id": 1,
  "earned_ajr": 5,
  "create_at": "DateTime"
}
```


  "current_streak": 3, // int - this is a daily streak of user. 
  "earned_ajr_count": 324, // int - this value is calculated dynamically when the user maked some dhikr, dua, readed aya



#### Profile favorites system

User can save or like the Adhkar, Quran Ayahs, Hadiths, duas, Adhkars, Impact Projects and he can see them on his profile page in Favorites tab.
For each feature I think we need his table to separate the profile favorites things for example favorite_hadiths, favorite_ayahs, favorite_duas etc... Tables


#### Impacts Projects

This is projects with our parteners and each project can be eligible to zakat. User can donate to the projects and can see his donated mount.
Each project has also Stories where user can see the events that organization maked for this project. 


##### Project Category Model
```json
{
  "id": 1, //int unique
  "title_en": "title",
  "title_fr": "title",
  "title_ar": "title",
  "created_at": "DateTime"
}
```

##### Partener Organization Model
```json
{
  "id": 1, //int unique
  "name_en": "Islamic Organization",
  "name_fr": "Islamic Organization",
  "name_ar": "Arabic Organization name",
  "avatar_url": "url", //can be null
  "is_verified": true,
  "created_at": "DateTime"
}
```

##### Impact Project Model
```json
{
  "id": 1, //int unique
  "organizaton_id": 1,
  "project_category_id": 1,
  "title_en": "EN title",
  "title_fr": "FR title",
  "title_ar": "AR title",
  "subtitle_en": "subtitle",
  "subtitle_fr": "subtitle",
  "subtitle_ar": "subtitle",
  "description_en": "description",
  "description_fr": "description",
  "description_ar": "description",
  "required_amount": 50000, // The amount alwasy be on euro
  "eligible_for_zakat": true, // Do the project eligible to zakat
  "created_at": "DateTime"
}
```

##### Project Story Model 
```json
{
  "id": 1, //int unique
  "impact_project_id": 1,
  "title_en": "EN title",
  "title_fr": "FR title",
  "title_ar": "AR title",
  "description_en": "description",
  "description_fr": "description",
  "description_ar": "description",
  "images": ["url", "url"], // can be null
  "created_at": "DateTime"
}
```


#### Zakat payments

User can give his zakat to a impact project that is eligible to it. The selected projects for giving zakat can be multiple and it mean that we need to create for each selected project his zakat transaction after paying zakat.

We need to create a zakats transactions table for it.


##### Zakat Transaction
```json
{
  "id": 1, //int unique
  "impact_project_id": 1, // We can give our zakat to multiple projects
  "user_id": 1,
  "zakat_mount": 1200,
  "created_at": "DateTime"
}
```


#### Donations payments

User can donate to any Impact project that is in db.

We need to create a donation transactions table for it.


##### Donation Transaction
```json
{
  "id": 1, //int unique
  "impact_project_id": 1, // We can give our zakat to multiple projects
  "user_id": 1, 
  "zakat_mount": 1200,
  "created_at": "DateTime"
}
```



#### Quizs

User can play to quizs. In the DB we have only the Quiz Question models generated by admin. 

We will create an Edge Function from Supabase getQuiz which will generate quiz of 4 questions 

Users can access questions whose level is less than or equal to the user’s level. If a question’s level is higher than the user’s level, the user does not have access to it.
This means the getQuiz function must not return questions that are above the user’s level, except for the 4th question, where getQuiz should return a question that is one level higher than the user’s level.
This means the model will look approximately like this:

###### If don't played
```json
{
  "quizs": [
    @QuizQuestionModel, // quiz.level <= user.level
    @QuizQuestionModel, // quiz.level <= user.level
    @QuizQuestionModel, // quiz.level <= user.level
    @QuizQuestionModel, // return quiz.level > user.level if exist, if not filter by quiz.level <= user.level
  ],
  "already_played": false,
}
```


###### If played
```json
{
  "quizs": [],
  "already_played": true,
}
```

##### Quiz Question Model 
```json
{
  "id": 1, //int unique
  "level": "LevelType",
  "question_en": "EN question",
  "question_fr": "FR question",
  "question_ar": "AR question",
  "arabic_text": "الْحَمْدُ لِلَّهِ", // can be null
  "transcription_en": "Alhamdulilah", // can be null
  "transcription_fr": "Alhamdulilah", // can  be null
  "subtitle_en": "EN subtitle", // can be null
  "subtitle_fr": "FR subtitle", // can be null
  "subtitle_ar": "AR subtitle", // can be null

  "option_a_en": "EN Option title",
  "option_a_fr": "FR Option title",
  "option_a_ar": "AR Option title",
  "option_b_en": "EN Option title",
  "option_b_fr": "FR Option title",
  "option_b_ar": "AR Option title",
  "option_c_en": "EN Option title",
  "option_c_fr": "FR Option title",
  "option_c_ar": "AR Option title",
  "option_d_en": "EN Option title",
  "option_d_fr": "FR Option title",
  "option_d_ar": "AR Option title",

  "congratulation_en": "EN congratulation",
  "congratulation_fr": "FR congratulation",
  "congratulation_ar": "AR congratulation",
  "correct_option_index": 3, // must be an integer 1<=4
  "ajr": 5,
  "bonus_ajr": 20, // can be null - If the user responded all questions without error
}
```

