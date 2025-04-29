import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:volio/model/coin.dart';
import '../dio/api_client.dart';

final newCoinProvider = FutureProvider<List<Coin>>((ref) async {
  final dio = Dio();
  dio.options.headers['X-API-KEY'] = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJub25jZSI6ImEzZTdmODllLTkwMDktNGJlZC05MzU1LTk5ZDRlMjU4YjM1MiIsIm9yZ0lkIjoiNDQzNzY3IiwidXNlcklkIjoiNDU2NTgxIiwidHlwZUlkIjoiMTg3MjZmZmEtYjA5OC00ODI3LTlkMjQtZGM4YTViODRhMDhkIiwidHlwZSI6IlBST0pFQ1QiLCJpYXQiOjE3NDU1Nzg2MjUsImV4cCI6NDkwMTMzODYyNX0.w-9S0c9ZvsqHR_vxYz5yL6sZ3xtpn7yZGOvuiQWq8Pg'; // Replace with your actual key

  final client = ApiClient(dio: dio);
  const url = 'https://solana-gateway.moralis.io/token/mainnet/exchange/pumpfun/new?limit=5';

  List<dynamic> rawCoinData = await client.fetchJsonData(url);
  List<Coin> coinList = [];
  for (var rawNewCoin in rawCoinData[0]["result"]) {
    Coin coin = Coin.fromJson(rawNewCoin,"","",0.0);
    coinList.add(coin);
  }
  return coinList;
});

final newCoinEnhancedProvider = FutureProvider<List<Coin>>((ref) async {
  final dio = Dio();
  dio.options.headers['X-API-KEY'] = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJub25jZSI6ImEzZTdmODllLTkwMDktNGJlZC05MzU1LTk5ZDRlMjU4YjM1MiIsIm9yZ0lkIjoiNDQzNzY3IiwidXNlcklkIjoiNDU2NTgxIiwidHlwZUlkIjoiMTg3MjZmZmEtYjA5OC00ODI3LTlkMjQtZGM4YTViODRhMDhkIiwidHlwZSI6IlBST0pFQ1QiLCJpYXQiOjE3NDU1Nzg2MjUsImV4cCI6NDkwMTMzODYyNX0.w-9S0c9ZvsqHR_vxYz5yL6sZ3xtpn7yZGOvuiQWq8Pg'; // Replace with your actual key

  final client = ApiClient(dio: dio);
  const url = 'https://solana-gateway.moralis.io/token/mainnet/exchange/pumpfun/new?limit=5';

  List<dynamic> rawCoinData = await client.fetchJsonData(url);
  List<Coin> coinList = [];
  for (var rawNewCoin in rawCoinData[0]["result"]) {
    Coin newCoin = Coin.fromJson(rawNewCoin,"","",0.0);
    final address = newCoin.address;
    final backupNameUrl = "https://solana-gateway.moralis.io/token/mainnet/$address/metadata";
    List<dynamic> backupNameCoinData = await client.fetchJsonData(backupNameUrl);
    final backupName = backupNameCoinData[0]["name"];
    final iconUrl = backupNameCoinData[0]["logo"];
    final volumeUrl = "https://deep-index.moralis.io/api/v2.2/tokens/$address/analytics?chain=solana";
    List<dynamic> volumeCoinData = await client.fetchJsonData(volumeUrl);
    final buy5m = volumeCoinData[0]["totalBuyVolume"]["5m"];
    final sell5m = volumeCoinData[0]["totalSellVolume"]["5m"];
    final totalVolume = buy5m + sell5m;
    Coin newEnhancedCoin = Coin.fromJson(rawNewCoin, backupName, iconUrl, totalVolume);
    coinList.add(newEnhancedCoin);
  }
  return coinList;
});
