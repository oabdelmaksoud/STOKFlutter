import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stock_options_analyzer/data/models/stock.dart';

/// BLoC for managing stock navigation and data
class StockBloc extends Cubit<StockState> {
  final List<String> defaultSymbols = [
    'AAPL', 'MSFT', 'GOOGL', 'AMZN', 'META', 'TSLA', 'NVDA', 'PLTR'
  ];
  
  StockBloc() : super(StockInitial());
  
  void loadStocks() {
    emit(StockLoading());
    // Implementation will be added
  }
  
  void selectStock(String symbol) {
    if (state is StockLoaded) {
      final currentState = state as StockLoaded;
      emit(StockLoaded(
        stocks: currentState.stocks,
        selectedSymbol: symbol,
      ));
    }
  }
  
  void navigateToNextStock() {
    if (state is StockLoaded) {
      final currentState = state as StockLoaded;
      final currentIndex = defaultSymbols.indexOf(currentState.selectedSymbol);
      if (currentIndex < defaultSymbols.length - 1) {
        final nextSymbol = defaultSymbols[currentIndex + 1];
        emit(StockLoaded(
          stocks: currentState.stocks,
          selectedSymbol: nextSymbol,
        ));
      }
    }
  }
  
  void navigateToPreviousStock() {
    if (state is StockLoaded) {
      final currentState = state as StockLoaded;
      final currentIndex = defaultSymbols.indexOf(currentState.selectedSymbol);
      if (currentIndex > 0) {
        final previousSymbol = defaultSymbols[currentIndex - 1];
        emit(StockLoaded(
          stocks: currentState.stocks,
          selectedSymbol: previousSymbol,
        ));
      }
    }
  }
}

/// States for the StockBloc
abstract class StockState {}

class StockInitial extends StockState {}

class StockLoading extends StockState {}

class StockLoaded extends StockState {
  final Map<String, Stock> stocks;
  final String selectedSymbol;
  
  StockLoaded({
    required this.stocks,
    required this.selectedSymbol,
  });
}

class StockError extends StockState {
  final String message;
  
  StockError(this.message);
}
