class AppointmentSlot {
  const AppointmentSlot({
    required this.id,
    required this.therapistId,
    required this.startsAt,
    required this.endsAt,
    required this.status,
    required this.timezone,
  });

  final int id;
  final int therapistId;
  final DateTime startsAt;
  final DateTime endsAt;
  final String status;
  final String timezone;

  factory AppointmentSlot.fromJson(Map<String, dynamic> json) {
    return AppointmentSlot(
      id: _asInt(json['id']),
      therapistId: _asInt(json['therapist_id']),
      startsAt: _asDateTime(json['starts_at']),
      endsAt: _asDateTime(json['ends_at']),
      status: json['status']?.toString() ?? 'available',
      timezone: json['timezone']?.toString() ?? 'Africa/Blantyre',
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
