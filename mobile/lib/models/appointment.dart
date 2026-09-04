class Appointment {
  const Appointment({
    required this.id,
    required this.therapistName,
    required this.scheduledStart,
    required this.scheduledEnd,
    required this.mode,
    required this.status,
    this.reason,
  });

  final int id;
  final String therapistName;
  final DateTime scheduledStart;
  final DateTime scheduledEnd;
  final String mode;
  final String status;
  final String? reason;

  bool get isCancelled => status == 'cancelled';
  bool get isPast => scheduledEnd.isBefore(DateTime.now());

  factory Appointment.fromJson(Map<String, dynamic> json) {
    final therapist = json['therapist'];
    final user =
        therapist is Map<String, dynamic>
            ? therapist['user']
            : therapist is Map
            ? therapist['user']
            : null;
    final therapistName =
        user is Map && user['name'] != null
            ? user['name'].toString()
            : 'Verified therapist';

    return Appointment(
      id: _asInt(json['id']),
      therapistName: therapistName,
      scheduledStart: _asDateTime(json['scheduled_start']),
      scheduledEnd: _asDateTime(json['scheduled_end']),
      mode: json['mode']?.toString() ?? 'online',
      status: json['status']?.toString() ?? 'confirmed',
      reason: json['reason']?.toString(),
    );
  }
}

int _asInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

DateTime _asDateTime(Object? value) {
  return DateTime.tryParse(value?.toString() ?? '') ?? DateTime.now();
}
