class SupportContact {
  const SupportContact({
    required this.id,
    required this.countryCode,
    required this.countryName,
    required this.serviceName,
    this.description,
    this.phoneNumber,
    this.whatsappNumber,
    this.smsNumber,
    this.websiteUrl,
    this.email,
    this.availabilityText,
    this.isEmergencyService = false,
    this.isCrisisSupport = true,
  });

  final int id;
  final String countryCode;
  final String countryName;
  final String serviceName;
  final String? description;
  final String? phoneNumber;
  final String? whatsappNumber;
  final String? smsNumber;
  final String? websiteUrl;
  final String? email;
  final String? availabilityText;
  final bool isEmergencyService;
  final bool isCrisisSupport;

  bool get isDemo => serviceName.toUpperCase().contains('DEMO ONLY');
  bool get hasDirectAction =>
      _has(phoneNumber) ||
      _has(whatsappNumber) ||
      _has(smsNumber) ||
      _has(websiteUrl) ||
      _has(email);

  factory SupportContact.fromJson(Map<String, dynamic> json) {
    return SupportContact(
      id: _asInt(json['id']),
      countryCode: json['country_code']?.toString() ?? '',
      countryName: json['country_name']?.toString() ?? 'Unknown country',
      serviceName: json['service_name']?.toString() ?? 'Support contact',
      description: _nullable(json['description']),
      phoneNumber: _nullable(json['phone_number']),
      whatsappNumber: _nullable(json['whatsapp_number']),
      smsNumber: _nullable(json['sms_number']),
      websiteUrl: _nullable(json['website_url']),
      email: _nullable(json['email']),
      availabilityText: _nullable(json['availability_text']),
      isEmergencyService:
          json['is_emergency_service'] == true ||
          json['is_emergency_service'] == 1,
      isCrisisSupport:
          json['is_crisis_support'] == true || json['is_crisis_support'] == 1,
    );
  }

  static bool _has(String? value) => value != null && value.trim().isNotEmpty;
}

int _asInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

String? _nullable(Object? value) {
  final text = value?.toString().trim();
  return text == null || text.isEmpty ? null : text;
}
