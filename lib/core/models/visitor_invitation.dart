import 'package:flutter/material.dart';

/// Represents a local visitor invitation created by a resident.
class VisitorInvitation {
  final String id;
  final String visitorName;
  final String phoneNumber;
  final DateTime visitDate;
  final TimeOfDay arrivalTime;
  final String? vehiclePlate;
  final String? vehicleDescription;
  final DateTime createdAt;

  const VisitorInvitation({
    required this.id,
    required this.visitorName,
    required this.phoneNumber,
    required this.visitDate,
    required this.arrivalTime,
    this.vehiclePlate,
    this.vehicleDescription,
    required this.createdAt,
  });

  bool get hasVehicle =>
      (vehiclePlate != null && vehiclePlate!.trim().isNotEmpty) ||
      (vehicleDescription != null && vehicleDescription!.trim().isNotEmpty);
}
