import 'package:flutter/material.dart';

enum Weekday {
  monday,
  tuesday,
  wednesday,
  thursday,
  friday,
  saturday,
  sunday;

  String get label {
    switch (this) {
      case Weekday.monday:
        return 'Monday';
      case Weekday.tuesday:
        return 'Tuesday';
      case Weekday.wednesday:
        return 'Wednesday';
      case Weekday.thursday:
        return 'Thursday';
      case Weekday.friday:
        return 'Friday';
      case Weekday.saturday:
        return 'Saturday';
      case Weekday.sunday:
        return 'Sunday';
    }
  }

  String get shortLabel => label.substring(0, 3);

  static Weekday fromName(String? value) {
    if (value == null) return Weekday.monday;
    return Weekday.values.firstWhere(
      (day) => day.name == value,
      orElse: () => Weekday.monday,
    );
  }
}

class DailyAvailability {
  const DailyAvailability({
    required this.day,
    this.isEnabled = true,
    this.startTime = '09:00',
    this.endTime = '17:00',
  });

  final Weekday day;
  final bool isEnabled;
  final String startTime;
  final String endTime;

  DailyAvailability copyWith({
    Weekday? day,
    bool? isEnabled,
    String? startTime,
    String? endTime,
  }) {
    return DailyAvailability(
      day: day ?? this.day,
      isEnabled: isEnabled ?? this.isEnabled,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'day': day.name,
      'isEnabled': isEnabled,
      'startTime': startTime,
      'endTime': endTime,
    };
  }

  factory DailyAvailability.fromMap(Map<String, dynamic> map) {
    return DailyAvailability(
      day: map['day'] != null
          ? Weekday.fromName(map['day'] as String?)
          : Weekday.monday,
      isEnabled: map['isEnabled'] as bool? ?? true,
      startTime: map['startTime'] as String? ?? '09:00',
      endTime: map['endTime'] as String? ?? '17:00',
    );
  }

  static DailyAvailability fromLegacy(Weekday day, dynamic value) {
    if (value is Map<String, dynamic>) {
      return DailyAvailability(
        day: day,
        isEnabled: value['isEnabled'] as bool? ?? true,
        startTime: value['startTime'] as String? ?? '09:00',
        endTime: value['endTime'] as String? ?? '17:00',
      );
    }
    if (value is String) {
      final parts = value.split('-');
      if (parts.length == 2) {
        return DailyAvailability(
          day: day,
          startTime: parts[0].trim(),
          endTime: parts[1].trim(),
        );
      }
    }
    return DailyAvailability(day: day);
  }

  bool hasValidRange() {
    final start = _parseMinutes(startTime);
    final end = _parseMinutes(endTime);
    return end > start;
  }

  int _parseMinutes(String value) {
    final parts = value.split(':');
    if (parts.length != 2) return 0;
    final hours = int.tryParse(parts[0]) ?? 0;
    final minutes = int.tryParse(parts[1]) ?? 0;
    return hours * 60 + minutes;
  }

  TimeOfDay get startAsTimeOfDay {
    final parts = startTime.split(':');
    final hour = int.tryParse(parts[0]) ?? 9;
    final minute = int.tryParse(parts[1]) ?? 0;
    return TimeOfDay(hour: hour, minute: minute);
  }

  TimeOfDay get endAsTimeOfDay {
    final parts = endTime.split(':');
    final hour = int.tryParse(parts[0]) ?? 17;
    final minute = int.tryParse(parts[1]) ?? 0;
    return TimeOfDay(hour: hour, minute: minute);
  }

  String formatRange() => '$startTime - $endTime';
}

class AvailabilitySchedule {
  AvailabilitySchedule({
    required List<DailyAvailability> days,
  }) : days = days..sort((a, b) => a.day.index.compareTo(b.day.index));

  final List<DailyAvailability> days;

  Map<String, dynamic> toMap() {
    return {
      'days': days.map((day) => day.toMap()).toList(),
    };
  }

  factory AvailabilitySchedule.fromMap(Map<String, dynamic> map) {
    if (map.containsKey('days') && map['days'] is List) {
      final days = (map['days'] as List)
          .map(
            (item) => DailyAvailability.fromMap(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList();
      return AvailabilitySchedule(days: days);
    }

    final parsedDays = Weekday.values
        .map(
          (day) => map.containsKey(day.name)
              ? DailyAvailability.fromLegacy(
                  day,
                  map[day.name],
                )
              : DailyAvailability(day: day, isEnabled: false),
        )
        .toList();

    return AvailabilitySchedule(days: parsedDays);
  }

  factory AvailabilitySchedule.defaultWeek() {
    return AvailabilitySchedule(
      days: Weekday.values
          .map(
            (day) => DailyAvailability(
              day: day,
              isEnabled: day != Weekday.sunday,
              startTime: '08:00',
              endTime: '18:00',
            ),
          )
          .toList(),
    );
  }

  DailyAvailability dayAvailability(Weekday day) {
    return days.firstWhere(
      (item) => item.day == day,
      orElse: () => DailyAvailability(day: day, isEnabled: false),
    );
  }

  AvailabilitySchedule copyWithDay(DailyAvailability updatedDay) {
    final replacement = updatedDay.copyWith(day: updatedDay.day);
    final copied = days.map((day) {
      if (day.day == updatedDay.day) {
        return replacement;
      }
      return day;
    }).toList();
    return AvailabilitySchedule(days: copied);
  }

  AvailabilitySchedule applyToDays(
    DailyAvailability template,
    List<Weekday> targetDays,
  ) {
    final copied = days.map((day) {
      if (targetDays.contains(day.day)) {
        return template.copyWith(day: day.day);
      }
      return day;
    }).toList();
    return AvailabilitySchedule(days: copied);
  }

  bool get hasAvailability =>
      days.any((day) => day.isEnabled && day.hasValidRange());

  List<DailyAvailability> get enabledDays =>
      days.where((day) => day.isEnabled && day.hasValidRange()).toList();

  static String formatTimeOfDay(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

