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

  /// The second wallet shown next to the user's own currency.
  /// Change this one place to change what each country sees.
  static CountryConfig secondaryFor(CountryConfig c) {
    switch (c.name) {
      case 'USA':
        return all[4]; // Pound (England's currency)
      default:
        return all[3]; // Dollar
    }
  }

  /// The signed-in user's country. fromName() sets it, so any page can show
  /// amounts in the user's own currency with CountryConfig.current.symbol.
  static CountryConfig current = all.first;

  static String groupInt(int v) =>
      v.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => ',');

  /// Daily send limit for tiers 1, 2 and 3 in this country's own currency.
  /// Nigeria's figures are the real ones. The others are PLACEHOLDER
  /// equivalents: replace them with your real limits.
  List<int> get tierLimits {
    switch (name) {
      case 'Ghana':
        return [4000, 40000, 250000];
      case 'Canada':
        return [500, 5000, 30000];
      case 'USA':
        return [350, 3500, 20000];
      case 'England':
        return [250, 2500, 16000];
      default:
        return [500000, 5000000, 30000000];
    }
  }

  static CountryConfig fromName(String? name) {
    for (final c in all) {
      if (c.name == name) {
        current = c;
        return c;
      }
    }
    return all.first;
  }
}
