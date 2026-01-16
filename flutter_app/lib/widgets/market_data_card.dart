import 'package:flutter/material.dart';
import '../models/market_data_model.dart';
import 'package:intl/intl.dart';

class MarketDataCard extends StatelessWidget {
  final MarketData marketData;
  final Duration animationDuration;

  const MarketDataCard({
    super.key,
    required this.marketData,
    this.animationDuration = const Duration(milliseconds: 500),
  });

  @override
  Widget build(BuildContext context) {
    final NumberFormat currencyFormat = NumberFormat.currency(symbol: '\$');
    final Color changeColor =
        marketData.change24h >= 0 ? Colors.green : Colors.red;
    final String percentText = marketData.changePercent24h >= 0
        ? '+${marketData.changePercent24h.toStringAsFixed(2)}%'
        : '${marketData.changePercent24h.toStringAsFixed(2)}%';
    final String amountText = marketData.change24h >= 0
        ? '+${marketData.change24h.toStringAsFixed(2)}'
        : '${marketData.change24h.toStringAsFixed(2)}';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Symbol and animated price
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  marketData.symbol,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),

                // TweenAnimationBuilder for price
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(
                      begin: marketData.price, end: marketData.price),
                  duration: animationDuration,
                  builder: (context, value, child) {
                    return Text(
                      currencyFormat.format(value),
                      style:
                          const TextStyle(fontSize: 14, color: Colors.black87),
                    );
                  },
                ),
              ],
            ),

            // 24h change
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  amountText,
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: changeColor),
                ),
                Text(
                  percentText,
                  style: TextStyle(color: changeColor),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
