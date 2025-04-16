enum AgeRange {
  BABY('BABY', '0~5세'),
  CHILD('CHILD', '6~9세'),
  TEEN('TEEN', '10대'),
  TWENTY('TWENTY', '20대'),
  THIRTY('THIRTY', '30대'),
  FORTY('FORTY', '40대'),
  FIFTY('FIFTY', '50대'),
  SENIOR('SENIOR', '60대 이상');

  final String code;
  final String description;

  const AgeRange(this.code, this.description);
}
