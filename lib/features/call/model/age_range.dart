enum AgeRange {
  age0to5('0-5', '0~5세'),
  age6to9('6-9', '6~9세'),
  age10s('10s', '10대'),
  age20s('20s', '20대'),
  age30s('30s', '30대'),
  age40s('40s', '40대'),
  age50s('50s', '50대'),
  age60s('60s', '60대');

  final String code;
  final String description;

  const AgeRange(this.code, this.description);
}