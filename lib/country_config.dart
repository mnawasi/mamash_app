class CountryConfig {
  final String name; // saved on the user's account
  final String flag;
  final String dial;
  final String currencyCode;
  final String currencyName;
  final String symbol;

  const CountryConfig(this.name, this.flag, this.dial, this.currencyCode, this.currencyName, this.symbol);

  static const List<CountryConfig> all = [
    CountryConfig('Nigeria', '\u{1F1F3}\u{1F1EC}', '+234', 'NGN', 'Naira', '\u20a6'),
    CountryConfig('Ghana', '\u{1F1EC}\u{1F1ED}', '+233', 'GHS', 'Cedi', 'GH\u20b5'),
    CountryConfig('Canada', '\u{1F1E8}\u{1F1E6}', '+1', 'CAD', 'Canadian Dollar', 'C\$'),
    CountryConfig('USA', '\u{1F1FA}\u{1F1F8}', '+1', 'USD', 'Dollar', '\$'),
    CountryConfig('England', '\u{1F1EC}\u{1F1E7}', '+44', 'GBP', 'Pound', '\u00a3'),
  ];

  static CountryConfig fromName(String? name) {
    for (final c in all) {
      if (c.name == name) return c;
    }
    return all.first;
  }
}
