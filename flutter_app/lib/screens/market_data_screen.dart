import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/market_data_provider.dart';
import '../widgets/market_data_card.dart';

class MarketDataScreen extends StatefulWidget {
  const MarketDataScreen({super.key});

  @override
  State<MarketDataScreen> createState() => _MarketDataScreenState();
}

class _MarketDataScreenState extends State<MarketDataScreen> {
  @override
  void initState() {
    super.initState();
    // Load data after first frame to avoid setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<MarketDataProvider>(context, listen: false);
      provider.loadMarketData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<MarketDataProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.marketData.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(provider.error!),
                  const SizedBox(height: 10),
                  ElevatedButton(
                      onPressed: () => provider.loadMarketData(),
                      child: const Text('Retry')),
                ],
              ),
            );
          }

          if (provider.marketData.isEmpty) {
            return const Center(
                child: Text('No market data available',
                    style: TextStyle(fontSize: 16, color: Colors.grey)));
          }

          return RefreshIndicator(
            onRefresh: () => provider.loadMarketData(refresh: true),
            child: ListView.builder(
              itemCount: provider.marketData.length,
              itemBuilder: (context, index) {
                final marketData = provider.marketData[index];
                return MarketDataCard(marketData: marketData);
              },
            ),
          );
        },
      ),
    );
  }
}
