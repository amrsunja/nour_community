package com.nourcommunity.nour

import com.ryanheise.audioservice.AudioServiceFragmentActivity

// flutter_stripe requires a FlutterFragmentActivity; just_audio_background
// (audio_service) requires its engine-sharing activity. AudioServiceFragmentActivity
// is audio_service's FlutterFragmentActivity variant — it satisfies both, so it
// replaces the manifest's former com.ryanheise.audioservice.AudioServiceActivity.
class MainActivity : AudioServiceFragmentActivity()
