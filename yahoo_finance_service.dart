import 'package:dio/dio.dart';
import 'package:stock_options_analyzer/data/models/stock.dart';

/// Service for retrieving stock data from Yahoo Finance
class YahooFinanceService {
  final Dio _dio;
  final String _baseUrl = 'https://query1.finance.yahoo.com/v8/finance';

  YahooFinanceService({Dio? dio}) : _dio = dio ?? Dio();

  /// Get stock data for a symbol
  Future<Stock> getStockData(String symbol, {
    String period = '1y',
    String interval = '1d',
  }) async {
    try {
      // Get historical data
      final historyUrl = '$_baseUrl/chart/$symbol';
      final historyResponse = await _dio.get(
        historyUrl,
        queryParameters: {
          'range': period,
          'interval': interval,
          'includePrePost': false,
          'events': 'div,split',
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        },
      );

      // Get quote data
      final quoteUrl = '$_baseUrl/quote';
      final quoteResponse = await _dio.get(
        quoteUrl,
        queryParameters: {
          'symbols': symbol,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        },
      );

      // Get options data
      final optionsUrl = '$_baseUrl/options/$symbol';
      final optionsResponse = await _dio.get(
        optionsUrl,
        queryParameters: {
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        },
      );

      // Process historical data
      final historyResult = historyResponse.data['chart']['result'][0];
      final timestamps = List<int>.from(historyResult['timestamp'] ?? []);
      final quotes = historyResult['indicators']['quote'][0];
      
      final dates = timestamps.map((ts) => 
        DateTime.fromMillisecondsSinceEpoch(ts * 1000).toIso8601String().split('T')[0]
      ).toList();
      
      final openPrices = List<double>.from(quotes['open'] ?? [])
          .map((price) => price ?? 0.0)
          .toList();
      
      final highPrices = List<double>.from(quotes['high'] ?? [])
          .map((price) => price ?? 0.0)
          .toList();
      
      final lowPrices = List<double>.from(quotes['low'] ?? [])
          .map((price) => price ?? 0.0)
          .toList();
      
      final closePrices = List<double>.from(quotes['close'] ?? [])
          .map((price) => price ?? 0.0)
          .toList();
      
      final volumeHistory = List<double>.from(quotes['volume'] ?? [])
          .map((vol) => vol?.toDouble() ?? 0.0)
          .toList();

      // Process quote data
      final quoteResult = quoteResponse.data['quoteResponse']['result'][0];
      final currentPrice = quoteResult['regularMarketPrice']?.toDouble() ?? 0.0;
      final marketCap = quoteResult['marketCap']?.toDouble() ?? 0.0;
      final peRatio = quoteResult['trailingPE']?.toDouble() ?? 0.0;
      final eps = quoteResult['epsTrailingTwelveMonths']?.toDouble() ?? 0.0;
      final dividendYield = quoteResult['dividendYield']?.toDouble() ?? 0.0;
      final weekHigh52 = quoteResult['fiftyTwoWeekHigh']?.toDouble() ?? 0.0;
      final weekLow52 = quoteResult['fiftyTwoWeekLow']?.toDouble() ?? 0.0;
      final volume = quoteResult['regularMarketVolume']?.toDouble() ?? 0.0;
      final avgVolume = quoteResult['averageDailyVolume3Month']?.toDouble() ?? 0.0;
      final name = quoteResult['shortName'] ?? quoteResult['longName'] ?? symbol;
      final sector = quoteResult['sector'] ?? 'Unknown';
      final industry = quoteResult['industry'] ?? 'Unknown';

      // Calculate volatility
      double volatility = 0.0;
      if (closePrices.length > 1) {
        final returns = <double>[];
        for (int i = 1; i < closePrices.length; i++) {
          if (closePrices[i-1] > 0 && closePrices[i] > 0) {
            returns.add(closePrices[i] / closePrices[i-1] - 1);
          }
        }
        
        if (returns.isNotEmpty) {
          final mean = returns.reduce((a, b) => a + b) / returns.length;
          final squaredDiffs = returns.map((r) => (r - mean) * (r - mean));
          final variance = squaredDiffs.reduce((a, b) => a + b) / returns.length;
          volatility = (variance * 252).sqrt(); // Annualized volatility
        }
      }

      // Process options data
      OptionsData? optionsData;
      try {
        final optionsResult = optionsResponse.data['optionChain']['result'][0];
        final expirationDates = List<int>.from(optionsResult['expirationDates'] ?? []);
        
        if (expirationDates.isNotEmpty) {
          final expiry = DateTime.fromMillisecondsSinceEpoch(expirationDates[0] * 1000)
              .toIso8601String()
              .split('T')[0];
          
          final options = optionsResult['options'][0];
          final calls = List<Map<String, dynamic>>.from(options['calls'] ?? []);
          final puts = List<Map<String, dynamic>>.from(options['puts'] ?? []);
          
          final callContracts = calls.map((call) => OptionContract(
            strike: call['strike']?.toDouble() ?? 0.0,
            premium: call['lastPrice']?.toDouble() ?? 0.0,
            delta: call['delta']?.toDouble(),
            gamma: call['gamma']?.toDouble(),
            theta: call['theta']?.toDouble(),
            vega: call['vega']?.toDouble(),
          )).toList();
          
          final putContracts = puts.map((put) => OptionContract(
            strike: put['strike']?.toDouble() ?? 0.0,
            premium: put['lastPrice']?.toDouble() ?? 0.0,
            delta: put['delta']?.toDouble(),
            gamma: put['gamma']?.toDouble(),
            theta: put['theta']?.toDouble(),
            vega: put['vega']?.toDouble(),
          )).toList();
          
          optionsData = OptionsData(
            expiry: expiry,
            calls: callContracts,
            puts: putContracts,
          );
        }
      } catch (e) {
        // Options data might not be available for all stocks
        print('Error processing options data: $e');
      }

      // Create and return Stock object
      return Stock(
        symbol: symbol,
        name: name,
        sector: sector,
        industry: industry,
        currentPrice: currentPrice,
        marketCap: marketCap,
        peRatio: peRatio,
        eps: eps,
        dividendYield: dividendYield,
        weekHigh52: weekHigh52,
        weekLow52: weekLow52,
        volume: volume,
        avgVolume: avgVolume,
        dates: dates,
        openPrices: openPrices,
        highPrices: highPrices,
        lowPrices: lowPrices,
        closePrices: closePrices,
        volumeHistory: volumeHistory,
        volatility: volatility,
        impliedVolatility: optionsData != null ? 0.3 : 0.0, // Default value, would need more complex calculation
        retrievalTime: DateTime.now().toIso8601String(),
        options: optionsData,
      );
    } catch (e) {
      throw Exception('Failed to get stock data for $symbol: $e');
    }
  }

  /// Get multiple stocks data
  Future<Map<String, Stock>> getMultipleStocksData(List<String> symbols, {
    String period = '1y',
    String interval = '1d',
  }) async {
    final Map<String, Stock> results = {};
    
    for (final symbol in symbols) {
      try {
        final stock = await getStockData(symbol, period: period, interval: interval);
        results[symbol] = stock;
      } catch (e) {
        print('Error getting data for $symbol: $e');
        // Add a placeholder with error information
        results[symbol] = Stock(
          symbol: symbol,
          name: symbol,
          sector: 'Unknown',
          industry: 'Unknown',
          currentPrice: 0.0,
          marketCap: 0.0,
          peRatio: 0.0,
          eps: 0.0,
          dividendYield: 0.0,
          weekHigh52: 0.0,
          weekLow52: 0.0,
          volume: 0.0,
          avgVolume: 0.0,
          dates: [],
          openPrices: [],
          highPrices: [],
          lowPrices: [],
          closePrices: [],
          volumeHistory: [],
          volatility: 0.0,
          impliedVolatility: 0.0,
          retrievalTime: DateTime.now().toIso8601String(),
        );
      }
    }
    
    return results;
  }
}
