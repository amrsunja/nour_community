import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:nour/src/core/utils/islamic_tools/islamic_tools.dart';
import 'package:nour/src/core/utils/typedefs.dart';

import 'mosque_enums.dart';
import 'mosque_prayer_day_model.dart';

/// Row of `mosque_posts` (+ the viewer's own interaction flags when embedded).
class MosquePostModel extends Equatable {
  final int id;
  final int mosqueId;
  final MosquePostType type;
  final MosquePostStatus status;
  final MosquePostAudience audience;
  final String title;
  final String? body;
  final String? coverUrl;
  final bool isUrgent;
  final DateTime? eventDate;
  final TimeOfDay? eventTime;
  final TimeOfDay? eventEndTime;
  final String? location;
  final PrayerSlot? afterPrayer;
  final String? language;
  final int? volunteersNeeded;
  final DateTime publishedAt;
  final DateTime? expiresAt;
  final int viewsCount;
  final int attendeesCount;
  final int applicantsCount;
  final int duasCount;
  final DateTime? notifiedAt;
  // viewer flags (from embedded self rows)
  final bool attending;
  final bool applied;
  final bool duaSaid;

  const MosquePostModel({
    required this.id,
    required this.mosqueId,
    required this.type,
    this.status = MosquePostStatus.published,
    this.audience = MosquePostAudience.public,
    required this.title,
    this.body,
    this.coverUrl,
    this.isUrgent = false,
    this.eventDate,
    this.eventTime,
    this.eventEndTime,
    this.location,
    this.afterPrayer,
    this.language,
    this.volunteersNeeded,
    required this.publishedAt,
    this.expiresAt,
    this.viewsCount = 0,
    this.attendeesCount = 0,
    this.applicantsCount = 0,
    this.duasCount = 0,
    this.notifiedAt,
    this.attending = false,
    this.applied = false,
    this.duaSaid = false,
  });

  bool get isEvent => type == MosquePostType.event;
  bool get isJanaza => type == MosquePostType.janaza;
  bool get isVolunteering => type == MosquePostType.volunteering;
  bool get isHighlight => type == MosquePostType.highlight;

  /// Absolute start (event date + time), null when not an event-like post.
  DateTime? get startsAt {
    final d = eventDate;
    if (d == null) return null;
    final t = eventTime;
    return DateTime(d.year, d.month, d.day, t?.hour ?? 0, t?.minute ?? 0);
  }

  String get deepLink => 'nour://mosque/$mosqueId/post/$id';

  /// Embedded select used by every reader:
  /// `*, mosque_post_attendees(user_id), mosque_post_applicants(user_id), mosque_post_duas(user_id)`
  /// — RLS restricts the embedded rows to the viewer's own (self policies).
  static const selectColumns =
      '*, mosque_post_attendees(user_id), mosque_post_applicants(user_id), mosque_post_duas(user_id)';

  factory MosquePostModel.fromJson(Json json, {String? viewerId}) {
    bool has(String key) {
      final rows = json[key];
      if (rows is! List) return false;
      if (viewerId == null) return rows.isNotEmpty;
      return rows.any((r) => r is Map && r['user_id'] == viewerId);
    }

    return MosquePostModel(
      id: json['id'] as int,
      mosqueId: json['mosque_id'] as int,
      type: MosquePostType.fromDb(json['type'] as String?),
      status: MosquePostStatus.fromDb(json['status'] as String?),
      audience: MosquePostAudience.fromDb(json['audience'] as String?),
      title: json['title'] as String? ?? '',
      body: json['body'] as String?,
      coverUrl: json['cover_url'] as String?,
      isUrgent: json['is_urgent'] as bool? ?? false,
      eventDate: json['event_date'] == null ? null : DateTime.tryParse(json['event_date'] as String),
      eventTime: MosquePrayerDayModel.parseTime(json['event_time']?.toString()),
      eventEndTime: MosquePrayerDayModel.parseTime(json['event_end_time']?.toString()),
      location: json['location'] as String?,
      afterPrayer: MosquePrayerDayModel.slotFromDb(json['after_prayer'] as String?),
      language: json['language'] as String?,
      volunteersNeeded: json['volunteers_needed'] as int?,
      publishedAt: DateTime.tryParse(json['published_at']?.toString() ?? '') ?? DateTime.now(),
      expiresAt: DateTime.tryParse(json['expires_at']?.toString() ?? ''),
      viewsCount: json['views_count'] as int? ?? 0,
      attendeesCount: json['attendees_count'] as int? ?? 0,
      applicantsCount: json['applicants_count'] as int? ?? 0,
      duasCount: json['duas_count'] as int? ?? 0,
      notifiedAt: DateTime.tryParse(json['notified_at']?.toString() ?? ''),
      attending: has('mosque_post_attendees'),
      applied: has('mosque_post_applicants'),
      duaSaid: has('mosque_post_duas'),
    );
  }

  MosquePostModel copyWith({
    bool? attending,
    bool? applied,
    bool? duaSaid,
    int? attendeesCount,
    int? applicantsCount,
    int? duasCount,
    MosquePostStatus? status,
    DateTime? notifiedAt,
  }) =>
      MosquePostModel(
        id: id,
        mosqueId: mosqueId,
        type: type,
        status: status ?? this.status,
        audience: audience,
        title: title,
        body: body,
        coverUrl: coverUrl,
        isUrgent: isUrgent,
        eventDate: eventDate,
        eventTime: eventTime,
        eventEndTime: eventEndTime,
        location: location,
        afterPrayer: afterPrayer,
        language: language,
        volunteersNeeded: volunteersNeeded,
        publishedAt: publishedAt,
        expiresAt: expiresAt,
        viewsCount: viewsCount,
        attendeesCount: attendeesCount ?? this.attendeesCount,
        applicantsCount: applicantsCount ?? this.applicantsCount,
        duasCount: duasCount ?? this.duasCount,
        notifiedAt: notifiedAt ?? this.notifiedAt,
        attending: attending ?? this.attending,
        applied: applied ?? this.applied,
        duaSaid: duaSaid ?? this.duaSaid,
      );

  @override
  List<Object?> get props => [
        id, mosqueId, type, status, audience, title, body, coverUrl, isUrgent, eventDate, eventTime, eventEndTime,
        location, afterPrayer, language, volunteersNeeded, publishedAt, expiresAt, viewsCount, attendeesCount,
        applicantsCount, duasCount, notifiedAt, attending, applied, duaSaid,
      ];
}

/// Payload of the admin "create/edit post" form.
class MosquePostDraft {
  MosquePostDraft({
    required this.mosqueId,
    required this.type,
    this.audience = MosquePostAudience.public,
    required this.title,
    this.body,
    this.coverUrl,
    this.isUrgent = false,
    this.eventDate,
    this.eventTime,
    this.location,
    this.afterPrayer,
    this.language,
    this.volunteersNeeded,
    this.expiresAt,
  });

  final int mosqueId;
  final MosquePostType type;
  final MosquePostAudience audience;
  final String title;
  final String? body;
  final String? coverUrl;
  final bool isUrgent;
  final DateTime? eventDate;
  final TimeOfDay? eventTime;
  final String? location;
  final PrayerSlot? afterPrayer;
  final String? language;
  final int? volunteersNeeded;
  final DateTime? expiresAt;

  Json toJson() => {
        'mosque_id': mosqueId,
        'type': type.dbValue,
        'audience': audience.dbValue,
        'title': title.trim(),
        'body': body?.trim(),
        'cover_url': coverUrl,
        'is_urgent': isUrgent,
        'event_date': eventDate == null
            ? null
            : '${eventDate!.year.toString().padLeft(4, '0')}-${eventDate!.month.toString().padLeft(2, '0')}-${eventDate!.day.toString().padLeft(2, '0')}',
        'event_time': eventTime == null ? null : MosquePrayerDayModel.toDb(eventTime!),
        'location': location,
        'after_prayer': afterPrayer?.name,
        'language': language,
        'volunteers_needed': volunteersNeeded,
        'expires_at': expiresAt?.toUtc().toIso8601String(),
        'status': 'published',
      };
}
