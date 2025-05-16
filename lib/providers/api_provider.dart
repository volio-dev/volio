import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:volio/model/coin.dart';
import 'package:volio/providers/api_key_provider.dart';
import '../dio/api_client.dart';

final newCoinEnhancedProvider = FutureProvider<List<Coin>>((ref) async {
  final dio = Dio();
  final apiKey = ref.read(apiKeyProvider.notifier).get();
  dio.options.headers['X-API-KEY'] = apiKey;

  final client = ApiClient(dio: dio);

  const url =
      'https://solana-gateway.moralis.io/token/mainnet/exchange/pumpfun/new?limit=5';

  final rawCoinData = await client.fetchJsonData(url);
  final List<Coin> coinList = [];

  for (final rawCoin in rawCoinData[0]['result']) {
    final address = rawCoin['tokenAddress'] ?? '';
    final metadataUrl =
        'https://solana-gateway.moralis.io/token/mainnet/$address/metadata';
    final analyticsUrl =
        'https://deep-index.moralis.io/api/v2.2/tokens/$address/analytics?chain=solana';

    final responses = await Future.wait([
      client.fetchJsonData(metadataUrl).catchError((_) => [{}]),
      client.fetchJsonData(analyticsUrl).catchError((_) => [{}]),
    ]);

    final metadata = responses[0].isNotEmpty ? responses[0][0] : {};
    final analytics = responses[1].isNotEmpty ? responses[1][0] : {};

    final backupName = metadata['name'] ?? 'Unknown';
    final iconUrl = metadata['logo'] ?? '';

    final buy5m = analytics['totalBuyVolume']?['5m'];
    final sell5m = analytics['totalSellVolume']?['5m'];

    double parseVolume(dynamic value) {
      try {
        if (value == null) return 0.0;
        if (value is String) return double.parse(value);
        if (value is num) return value.toDouble();
      } catch (_) {}
      return 0.0;
    }

    final totalVolume = parseVolume(buy5m) + parseVolume(sell5m);

    final coin = Coin.fromJson(
      rawCoin,
      backupName,
      iconUrl,
      totalVolume,
    );

    coinList.add(coin);
  }

  return coinList;
});

final trendingCoinsProvider = FutureProvider<List<Coin>>((ref) async {
  final dio = Dio();
  final client = ApiClient(dio: dio);
  const url =
      'https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd&order=volume_desc&per_page=5&page=1';

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
