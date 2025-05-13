import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:volio/model/coin.dart';
import '../dio/api_client.dart';

final newCoinEnhancedProvider = FutureProvider<List<Coin>>((ref) async {
  final dio = Dio();
  dio.options.headers['X-API-KEY'] = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJub25jZSI6IjIyODFhOTI3LTlmZmEtNGY5MS1hYzg0LWVlYzBmMmE3Zjc4NCIsIm9yZ0lkIjoiNDM5MTAxIiwidXNlcklkIjoiNDUxNzQ0IiwidHlwZUlkIjoiYThmMTcxOTQtOWUzZi00MzkyLWI3ZWYtZDU0N2NhMjM1ZDRhIiwidHlwZSI6IlBST0pFQ1QiLCJpYXQiOjE3NDM1MDYyNzEsImV4cCI6NDg5OTI2NjI3MX0.qQESIfuQqwFZguH2K_ffmZrNIZm9KzKBHP9FrWfIeVA';

  final client = ApiClient(dio: dio);
  const url = 'https://solana-gateway.moralis.io/token/mainnet/exchange/pumpfun/new?limit=5';

  List<dynamic> rawCoinData = await client.fetchJsonData(url);
  List<Coin> coinList = [];
  for (var rawNewCoin in rawCoinData[0]["result"]) {
    final address = rawNewCoin["tokenAddress"] ?? "";
    final backupNameUrl = "https://solana-gateway.moralis.io/token/mainnet/$address/metadata";
    final volumeUrl = "https://deep-index.moralis.io/api/v2.2/tokens/$address/analytics?chain=solana";

    final responses = await Future.wait([
      client.fetchJsonData(backupNameUrl).catchError((e) => [{}]),
      client.fetchJsonData(volumeUrl).catchError((e) => [{}]),
    ]);

    final backupNameCoinData = responses[0];
    final volumeCoinData = responses[1];

    final backupName = backupNameCoinData.isNotEmpty ? (backupNameCoinData[0]["name"] ?? 'Unknown') : 'Unknown';
    final iconUrl = backupNameCoinData.isNotEmpty ? (backupNameCoinData[0]["logo"] ?? '') : '';
    final buy5m = volumeCoinData.isNotEmpty ? (volumeCoinData[0]["totalBuyVolume"]?["5m"] ?? 0) : 0;
    final sell5m = volumeCoinData.isNotEmpty ? (volumeCoinData[0]["totalSellVolume"]?["5m"] ?? 0) : 0;

    double parseVolume(dynamic value) {
      if (value == null) return 0.0;
      try {
        if (value is String) return double.parse(value);
        if (value is num) return value.toDouble();
        return 0.0;
      } catch (_) {
        return 0.0;
      }
    }

    final double totalVolume = parseVolume(buy5m) + parseVolume(sell5m);

    Coin newEnhancedCoin = Coin.fromJson(rawNewCoin, backupName, iconUrl, totalVolume);
    coinList.add(newEnhancedCoin);
  }
  return coinList;
});

final trendingCoinsProvider = FutureProvider<List<Coin>>((ref) async {
  final dio = Dio();
  final client = ApiClient(dio: dio);
  const url = 'https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd&order=volume_desc&per_page=5&page=1';

  final data = await client.fetchJsonData(url);
  return data.map((json) {
    return Coin(
      name: json['name'],
      ticker: json['symbol'],
      marketCap: (json['market_cap'] ?? 0).toDouble(),
      volume: (json['total_volume'] ?? 0).toDouble(),
      logoUrl: json['image'],
      address: '',
    );
  }).toList();
});