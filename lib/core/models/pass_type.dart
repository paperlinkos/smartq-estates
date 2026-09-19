/// Represents the categorical pass types that will eventually be encoded
/// into secure QR codes and verified at estate security gates.
enum PassType {
  visitor,
  event,
  delivery,
  service,
  temporaryAccess;

  String get displayName {
    switch (this) {
      case PassType.visitor:
        return 'Visitor Pass';
      case PassType.event:
        return 'Event Access Pass';
      case PassType.delivery:
        return 'Delivery Pass';
      case PassType.service:
        return 'Service / Contractor Pass';
      case PassType.temporaryAccess:
        return 'Temporary Access Pass';
    }
  }
}
