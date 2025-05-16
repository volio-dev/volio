import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fl_chart/fl_chart.dart';

import '../providers/api_provider.dart';
import '../model/coin.dart';

class ListWidget extends ConsumerStatefulWidget {
  const ListWidget({super.key});

  @override
  ConsumerState<ListWidget> createState() => _ListWidgetState();
}

class _ListWidgetState extends ConsumerState<ListWidget> {
  bool _isDarkMode = false;
  String _sortOption = 'volume_desc';
  final Set<String> _favorites = {};
  DateTime? _lastUpdated;
  String _searchQuery = '';
  bool _isLoading = false;
  bool _showFavoritesOnly = false;
  final TextEditingController _searchController = TextEditingController();

  String formatMarketCap(double value) {
    if (value >= 1e9) return '${(value / 1e9).toStringAsFixed(2)}B';
    if (value >= 1e6) return '${(value / 1e6).toStringAsFixed(2)}M';
    if (value >= 1e3) return '${(value / 1e3).toStringAsFixed(2)}K';
    return value.toStringAsFixed(2);
  }

  Future<void> _launchTwitterUrl() async {
    final Uri url = Uri.parse('https://x.com/voliosolana');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) throw 'Could not launch $url';
  }

  Future<void> _launchPumpUrl(String address) async {
    final Uri url = Uri.parse('https://pump.fun/coin/$address');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }

  void _refreshData() {
    setState(() => _isLoading = true);
    ref.invalidate(newCoinEnhancedProvider);
    ref.invalidate(trendingCoinsProvider);
  }

  ThemeData _buildThemeData() {
    return _isDarkMode
        ? ThemeData.dark().copyWith(
      scaffoldBackgroundColor: Colors.grey[900],
      cardColor: Colors.grey[850],
      textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
      iconTheme: const IconThemeData(color: Colors.white),
    )
        : ThemeData.light().copyWith(
      scaffoldBackgroundColor: const Color(0xFFF5F7FA),
      cardColor: Colors.white,
      textTheme: GoogleFonts.poppinsTextTheme(ThemeData.light().textTheme),
      iconTheme: const IconThemeData(color: Colors.black87),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pumpFuture = ref.watch(newCoinEnhancedProvider);
    return Theme(
      data: _buildThemeData(),
      child: Scaffold(
        body: pumpFuture.when(
          data: (pumpCoins) => _buildContent(context, pumpCoins),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Error: $err')),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, List<Coin> pumpCoins) {
    final trendingFuture = ref.watch(trendingCoinsProvider);
    return trendingFuture.when(
      data: (trendingCoins) {
        final isWide = MediaQuery.of(context).size.width > 600;
        return Column(
          children: [
            _buildHeader(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search by name or ticker...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                  )
                      : null,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
                onChanged: (value) => setState(() => _searchQuery = value),
              ),
            ),
            if (_lastUpdated != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  'Last updated: ${DateFormat.Hm().format(_lastUpdated!)}',
                  style: TextStyle(fontSize: 12, color: _isDarkMode ? Colors.white70 : Colors.grey[700]),
                ),
              ),
            Expanded(
              child: isWide
                  ? Row(
                children: [
                  Expanded(child: _buildCoinList("New Pump.fun Tokens", pumpCoins)),
                  const VerticalDivider(width: 1),
                  Expanded(child: _buildCoinList("Trending Big Coins", trendingCoins)),
                ],
              )
                  : ListView(
                children: [
                  _buildCoinList("New Pump.fun Tokens", pumpCoins, height: 300),
                  const Divider(height: 1),
                  _buildCoinList("Trending Big Coins", trendingCoins, height: 300),
                ],
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error loading trending coins: $err')),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 32, 16, 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _isDarkMode ? [Colors.indigo[900]!, Colors.purple[600]!] : [Colors.indigo[500]!, Colors.teal[400]!],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(24), bottomRight: Radius.circular(24)),
        boxShadow: [BoxShadow(color: Colors.indigo.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('VOLIO', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 3.0)),
              SizedBox(height: 6),
              Text('Tracker for Volume Tokens', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: Colors.white70)),
            ],
          ),
          Row(
            children: [
              IconButton(
                tooltip: 'Toggle Light/Dark Mode',
                icon: Icon(_isDarkMode ? Icons.wb_sunny : Icons.nightlight_round, color: Colors.white),
                onPressed: () => setState(() => _isDarkMode = !_isDarkMode),
              ),
              IconButton(
                tooltip: 'Refresh Data',
                icon: const Icon(Icons.refresh, color: Colors.white),
                onPressed: _refreshData,
              ),
              IconButton(
                tooltip: 'Show Favorites Only',
                icon: Icon(_showFavoritesOnly ? Icons.star : Icons.star_border, color: Colors.white),
                onPressed: () => setState(() => _showFavoritesOnly = !_showFavoritesOnly),
              ),
              PopupMenuButton<String>(
                tooltip: 'Sort Options',
                icon: const Icon(Icons.sort, color: Colors.white),
                onSelected: (value) => setState(() => _sortOption = value),
                itemBuilder: (context) => const [
                  PopupMenuItem(value: 'volume_desc', child: Text('Volume (Descending)')),
                  PopupMenuItem(value: 'volume_asc', child: Text('Volume (Ascending)')),
                  PopupMenuItem(value: 'market_cap_desc', child: Text('Market Cap (Descending)')),
                ],
              ),
              IconButton(
                tooltip: 'Visit Twitter/X',
                icon: const Icon(Icons.share, color: Colors.white),
                onPressed: _launchTwitterUrl,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCoinList(String title, List<Coin> coins, {double? height}) {
    var filteredCoins = coins.where((coin) {
      final name = coin.name?.toLowerCase() ?? '';
      final ticker = coin.ticker?.toLowerCase() ?? '';
      final query = _searchQuery.toLowerCase();
      return name.contains(query) || ticker.contains(query);
    }).toList();

    if (_showFavoritesOnly) {
      filteredCoins = filteredCoins.where((coin) => _favorites.contains(coin.address)).toList();
    }

    final sortedCoins = List<Coin>.from(filteredCoins)..sort((a, b) {
      if (_favorites.contains(a.address) && !_favorites.contains(b.address)) return -1;
      if (!_favorites.contains(a.address) && _favorites.contains(b.address)) return 1;
      if (_sortOption == 'volume_desc') {
        return (b.volume ?? 0.0).compareTo(a.volume ?? 0.0);
      } else if (_sortOption == 'volume_asc') {
        return (a.volume ?? 0.0).compareTo(b.volume ?? 0.0);
      } else {
        return (b.marketCap ?? 0.0).compareTo(a.marketCap ?? 0.0);
      }
    });

    return SizedBox(
      height: height,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text('$title (${sortedCoins.length})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: sortedCoins.length,
              itemBuilder: (context, index) {
                final coin = sortedCoins[index];
                final hasLogo = coin.logoUrl != null && coin.logoUrl!.isNotEmpty;
                final isNewToken = title.toLowerCase().contains("pump");

                return ListTile(
                  leading: hasLogo
                      ? CircleAvatar(backgroundImage: CachedNetworkImageProvider(coin.logoUrl!))
                      : CircleAvatar(
                    backgroundColor: isNewToken ? Colors.purple[50] : Colors.grey[300],
                    child: Icon(Icons.token, color: isNewToken ? Colors.purple : Colors.grey[700]),
                  ),
                  title: Text('${coin.name} (${coin.ticker})'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Vol: ${coin.volume?.toStringAsFixed(2)}\nCap: ${formatMarketCap(coin.marketCap ?? 0)}'),
                      SizedBox(
                        height: 40,
                        child: LineChart(
                          LineChartData(
                            lineBarsData: [
                              LineChartBarData(
                                spots: [
                                  FlSpot(0, 1),
                                  FlSpot(1, 1.5),
                                  FlSpot(2, 1.4),
                                  FlSpot(3, 1.7),
                                  FlSpot(4, 2),
                                ],
                                isCurved: true,
                                color: Colors.green[200],
                                dotData: FlDotData(show: false),
                                belowBarData: BarAreaData(show: false),
                              )
                            ],
                            titlesData: FlTitlesData(show: false),
                            gridData: FlGridData(show: false),
                            borderData: FlBorderData(show: false),
                          ),
                        ),
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    tooltip: 'Favorite',
                    icon: Icon(
                      _favorites.contains(coin.address) ? Icons.star : Icons.star_border,
                      color: _favorites.contains(coin.address) ? Colors.amber : (_isDarkMode ? Colors.white : Colors.grey),
                    ),
                    onPressed: () => setState(() {
                      if (_favorites.contains(coin.address)) {
                        _favorites.remove(coin.address);
                      } else {
                        _favorites.add(coin.address!);
                      }
                    }),
                  ),
                  onTap: () => _launchPumpUrl(coin.address ?? ''),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}