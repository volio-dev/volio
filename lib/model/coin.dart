class Coin {
  String? name;
  String? ticker;
  double? marketCap;
  double? volume;
  String? address;
  String? logoUrl;

  Coin({
    this.name,
    this.ticker,
    this.marketCap,
    this.volume,
    this.address,
    this.logoUrl,
  });

  factory Coin.fromJson(
      Map<String, dynamic> json1,
      String? backupName,
      String? iconUrl,
      double? totalVolume,
      ) {
    print('fullyDilutedValuation: ${json1["fullyDilutedValuation"]}');
    double parseMarketCap(dynamic value) {
      if (value == null) return 0.0;
      try {
        if (value is String) return double.parse(value);
        if (value is num) return value.toDouble();
        return 0.0;
      } catch (e) {
        print('Error parsing fullyDilutedValuation: $e');
        return 0.0;
      }
    }

    return Coin(
      name: json1["name"] ?? backupName ?? "",
      ticker: json1["symbol"],
      marketCap: parseMarketCap(json1["fullyDilutedValuation"]),
      volume: totalVolume,
      address: json1["tokenAddress"] ?? "",
      logoUrl: iconUrl,
    );
  }
}