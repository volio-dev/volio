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
    backupName,
    iconUrl,
    totalVolume,
  ) {
    return Coin(
      name: json1["name"] ?? backupName ?? "",
      ticker: json1["symbol"],
      marketCap:
          json1["fullyDilutedValuation"] != null
              ? double.parse(json1["fullyDilutedValuation"])
              : 0,
      volume: totalVolume,
      address: json1["tokenAddress"] ?? "",
      logoUrl: iconUrl,
    );
  }
}
