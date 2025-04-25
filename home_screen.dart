import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:stock_options_analyzer/data/models/stock.dart';
import 'package:stock_options_analyzer/presentation/screens/stock_detail_screen.dart';
import 'package:stock_options_analyzer/presentation/blocs/stock_bloc.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<String> defaultSymbols = [
    'AAPL', 'MSFT', 'GOOGL', 'AMZN', 'META', 'TSLA', 'NVDA', 'PLTR'
  ];
  
  final TextEditingController _symbolController = TextEditingController();
  bool _isLoading = false;
  
  @override
  void initState() {
    super.initState();
    _loadDefaultStocks();
  }
  
  void _loadDefaultStocks() {
    setState(() {
      _isLoading = true;
    });
    
    // In a real app, this would be handled by a BLoC
    final yahooFinanceService = GetIt.instance<YahooFinanceService>();
    yahooFinanceService.getMultipleStocksData(defaultSymbols).then((stocks) {
      setState(() {
        _isLoading = false;
      });
    }).catchError((error) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading stocks: $error')),
      );
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stock Options Analyzer'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDefaultStocks,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _symbolController,
                          decoration: const InputDecoration(
                            labelText: 'Enter Stock Symbol',
                            hintText: 'e.g., AAPL, MSFT',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: () {
                          final symbol = _symbolController.text.trim().toUpperCase();
                          if (symbol.isNotEmpty) {
                            // In a real app, this would be handled by a BLoC
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => StockDetailScreen(symbol: symbol),
                              ),
                            );
                          }
                        },
                        child: const Text('Analyze'),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: defaultSymbols.length,
                    itemBuilder: (context, index) {
                      final symbol = defaultSymbols[index];
                      return StockListItem(symbol: symbol);
                    },
                  ),
                ),
              ],
            ),
    );
  }
  
  @override
  void dispose() {
    _symbolController.dispose();
    super.dispose();
  }
}

class StockListItem extends StatelessWidget {
  final String symbol;
  
  const StockListItem({super.key, required this.symbol});
  
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(symbol[0]),
        ),
        title: Text(symbol),
        subtitle: Text('Tap to analyze'),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => StockDetailScreen(symbol: symbol),
            ),
          );
        },
      ),
    );
  }
}
