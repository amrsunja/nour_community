import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:nour/src/core/utils/islamic_tools/islamic_tools.dart';
import 'package:nour/src/core/utils/typedefs.dart';

import 'mosque_prayer_day_model.dart';

/// Row of `fn_search_mosques`: lightweight mosque + today's times.
class MosqueSearchItemModel extends Equatable {
  final int id;
  final String name;
  final String? slug;
  final String? logoUrl;
  final String? coverUrl;
  final String? addressLine;
  final String? city;
  final String? postalCode;
  final double? lat;
  final double? lng;
  final double? distanceKm;
  final int followersCount;
  final int membersCount;
  final String timezone;
  final Map<PrayerSlot, TimeOfDay> times;
  final TimeOfDay? sunrise;
  final TimeOfDay? jumua;
  final bool hasTimes;

  const MosqueSearchItemModel({
    required this.id,
    required this.name,
    this.slug,
    this.logoUrl,
    this.coverUrl,
    this.addressLine,
    this.city,
    this.postalCode,
    this.lat,
    this.lng,
    this.distanceKm,
    this.followersCount = 0,
    this.membersCount = 0,
    this.timezone = 'Europe/Paris',
    this.times = const {},
    this.sunrise,
    this.jumua,
    this.hasTimes = false,
  });

  String get fullAddress => [
        addressLine,
        [postalCode, city].where((e) => e != null && e.isNotEmpty).join(' '),
      ].where((e) => e != null && e.isNotEmpty).join(', ');

  String get initials => name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).take(2).map((p) => p[0].toUpperCase()).join();

  bool get hasLocation => lat != null && lng != null;

  factory MosqueSearchItemModel.fromJson(Json json) => MosqueSearchItemModel(
        id: json['id'] as int,
        name: json['name'] as String? ?? '',
        slug: json['slug'] as String?,
        logoUrl: json['logo_url'] as String?,
        coverUrl: json['cover_url'] as String?,
        addressLine: json['address_line'] as String?,
        city: json['city'] as String?,
        postalCode: json['postal_code'] as String?,
        lat: (json['lat'] as num?)?.toDouble(),
        lng: (json['lng'] as num?)?.toDouble(),
        distanceKm: (json['distance_km'] as num?)?.toDouble(),
        followersCount: json['followers_count'] as int? ?? 0,
        membersCount: json['members_count'] as int? ?? 0,
        timezone: json['timezone'] as String? ?? 'Europe/Paris',
        times: {
          for (final s in PrayerSlot.values)
            if (MosquePrayerDayModel.parseTime(json[s.name]?.toString()) != null)
              s: MosquePrayerDayModel.parseTime(json[s.name]?.toString())!,
        },
        sunrise: MosquePrayerDayModel.parseTime(json['sunrise']?.toString()),
        jumua: MosquePrayerDayModel.parseTime(json['jumua']?.toString()),
        hasTimes: json['has_times'] as bool? ?? false,
      );

  @override
  List<Object?> get props => [id, name, logoUrl, addressLine, city, lat, lng, distanceKm, followersCount, membersCount, times, hasTimes];
}
