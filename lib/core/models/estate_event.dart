import 'package:flutter/material.dart';

enum EventStatus {
  upcoming,
  active,
  completed,
  cancelled;

  String get displayName {
    switch (this) {
      case EventStatus.upcoming:
        return 'UPCOMING';
      case EventStatus.active:
        return 'ACTIVE';
      case EventStatus.completed:
        return 'COMPLETED';
      case EventStatus.cancelled:
        return 'CANCELLED';
    }
  }
}

class EstateEvent {
  final String id;
  final String name;
  final DateTime eventDate;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final int expectedGuests;
  final DateTime createdAt;
  final EventStatus status;

  const EstateEvent({
    required this.id,
    required this.name,
    required this.eventDate,
    required this.startTime,
    required this.endTime,
    required this.expectedGuests,
    required this.createdAt,
    this.status = EventStatus.upcoming,
  });

  EstateEvent copyWith({
    String? name,
    DateTime? eventDate,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    int? expectedGuests,
    EventStatus? status,
  }) {
    return EstateEvent(
      id: id,
      name: name ?? this.name,
      eventDate: eventDate ?? this.eventDate,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      expectedGuests: expectedGuests ?? this.expectedGuests,
      createdAt: createdAt,
      status: status ?? this.status,
    );
  }
}
