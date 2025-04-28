import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/api_provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'model/coin.dart';

class ListWidget extends ConsumerStatefulWidget {
  const ListWidget({super.key});

  @override
  ConsumerState<ListWidget> createState() => _ListWidgetState();
}

class _ListWidgetState extends ConsumerState<ListWidget> {
  List<dynamic>? _lastData;

  // Hilfsfunktion zur Formatierung des Market Cap
  String formatMarketCap(double value) {
    try {
      if (value >= 1e9) return '${(value / 1e9).toStringAsFixed(2)}B';
      if (value >= 1e6) return '${(value / 1e6).toStringAsFixed(2)}M';
      if (value >= 1e3) return '${(value / 1e3).toStringAsFixed(2)}K';
      return value.toStringAsFixed(2);
    } catch (e) {
      return 'N/A';
    }
  }

  // Funktion zum Öffnen der Twitter/X-URL
  Future<void> _launchTwitterUrl() async {
    final Uri url = Uri.parse('https://x.com/voliosolana');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    final coinsFuture = ref.watch(newCoinEnhancedProvider);
    return Scaffold(
      backgroundColor: const Color(0xFFE3F2FD),
      body: coinsFuture.when(
        data: (coins) {
          //          _lastData = data;
          return _buildContent(context, coins);
        },
        loading:
            () => Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[800]!),
                strokeWidth: 4,
              ),
            ),
        error:
            (err, stack) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, color: Colors.red[400], size: 40),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to load tokens. Please try again later.',
                    style: TextStyle(
                      color: Colors.blue[900],
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error details: $err',
                    style: TextStyle(color: Colors.blue[700], fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, List<Coin> coins) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(20.0, 40.0, 20.0, 20.0),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue[900]!, Colors.blue[600]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Stack(
            children: [
              Center(
                child: Column(
                  children: [
                    Text(
                      'VOLIO',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 2.0,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tracker for Volume Tokens',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 40.0,
                right: 20.0,
                child: IconButton(
                  icon: Icon(Icons.share, color: Colors.white, size: 28),
                  onPressed: _launchTwitterUrl,
                  tooltip: 'Visit us on Twitter/X',
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(20.0),
            itemCount: coins.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.1),
                        spreadRadius: 2,
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                    border: Border.all(color: Colors.blue[200]!, width: 1.5),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CachedNetworkImage(
                          imageUrl: coins[index].logoUrl ?? "",
                          width: 40,
                          height: 40,
                          placeholder:
                              (context, url) => CircularProgressIndicator(
                                color: Colors.blue,
                              ),
                          errorWidget:
                              (context, url, error) => Icon(Icons.error),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                coins[index].name!,
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.blue[900],
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Text(
                                    'Ticker: ',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.blue[700],
                                    ),
                                  ),
                                  Text(
                                    coins[index].ticker!,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.blue[600],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Market Cap: ${formatMarketCap(coins[index].marketCap!)}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.blue[600],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Volume: ${coins[index].volume} USD',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.blue[600],
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Address: ${coins[index].address}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.blue[600],
                                  fontFamily: 'RobotoMono',
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 18,
                          color: Colors.blue[400],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
