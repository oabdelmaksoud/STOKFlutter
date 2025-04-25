import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:stock_options_analyzer/data/models/stock.dart';
import 'package:stock_options_analyzer/data/services/yahoo_finance_service.dart';
import 'package:stock_options_analyzer/presentation/blocs/stock_bloc.dart';

class StockNavigator extends StatelessWidget {
  final String currentSymbol;
  final List<String> symbols;
  final Function(String) onSymbolChanged;

  const StockNavigator({
    super.key,
    required this.currentSymbol,
    required this.symbols,
    required this.onSymbolChanged,
  });

  @override
  Widget build(BuildContext context) {
    final currentIndex = symbols.indexOf(currentSymbol);
    final hasPrevious = currentIndex > 0;
    final hasNext = currentIndex < symbols.length - 1;

    return Card(
      margin: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: hasPrevious
                  ? () => onSymbolChanged(symbols[currentIndex - 1])
                  : null,
              tooltip: hasPrevious ? 'Previous: ${symbols[currentIndex - 1]}' : null,
            ),
            DropdownButton<String>(
              value: currentSymbol,
              items: symbols.map((symbol) {
                return DropdownMenuItem<String>(
                  value: symbol,
                  child: Text(symbol),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  onSymbolChanged(value);
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.arrow_forward),
              onPressed: hasNext
                  ? () => onSymbolChanged(symbols[currentIndex + 1])
                  : null,
              tooltip: hasNext ? 'Next: ${symbols[currentIndex + 1]}' : null,
            ),
          ],
        ),
      ),
    );
  }
}

class NavigableStockDetailScreen extends StatefulWidget {
  final String initialSymbol;
  
  const NavigableStockDetailScreen({
    super.key,
    required this.initialSymbol,
  });
  
  @override
  State<NavigableStockDetailScreen> createState() => _NavigableStockDetailScreenState();
}

class _NavigableStockDetailScreenState extends State<NavigableStockDetailScreen> {
  late StockBloc _stockBloc;
  late String _currentSymbol;
  final List<String> _symbols = [
    'AAPL', 'MSFT', 'GOOGL', 'AMZN', 'META', 'TSLA', 'NVDA', 'PLTR'
  ];
  
  @override
  void initState() {
    super.initState();
    _currentSymbol = widget.initialSymbol;
    _stockBloc = StockBloc();
  }
  
  void _navigateToStock(String symbol) {
    setState(() {
      _currentSymbol = symbol;
    });
    // In a real implementation, this would trigger data loading for the new stock
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_currentSymbol),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Refresh data for current stock
            },
          ),
        ],
      ),
      body: Column(
        children: [
          StockNavigator(
            currentSymbol: _currentSymbol,
            symbols: _symbols,
            onSymbolChanged: _navigateToStock,
          ),
          Expanded(
            child: Center(
              child: Text('Stock details for $_currentSymbol would be displayed here'),
            ),
          ),
        ],
      ),
    );
  }
  
  @override
  void dispose() {
    _stockBloc.close();
    super.dispose();
  }
}
