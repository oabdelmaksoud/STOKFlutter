import 'package:stock_options_analyzer/data/models/stock.dart';
import 'package:stock_options_analyzer/data/models/support_resistance.dart';

/// Service for analyzing support and resistance levels
class SupportResistanceService {
  /// Analyze support and resistance levels for a stock
  SupportResistance analyzeSupportResistance(Stock stock) {
    try {
      final closePrices = stock.closePrices;
      final highPrices = stock.highPrices;
      final lowPrices = stock.lowPrices;
      
      if (closePrices.isEmpty || highPrices.isEmpty || lowPrices.isEmpty || closePrices.length < 2) {
        throw Exception('Insufficient price data');
      }
      
      final currentPrice = stock.currentPrice;
      
      // Calculate support and resistance levels using multiple methods
      
      // Method 1: Recent highs and lows
      final recentHigh = _getMaxValue(highPrices.sublist(highPrices.length > 20 ? highPrices.length - 20 : 0));
      final recentLow = _getMinValue(lowPrices.sublist(lowPrices.length > 20 ? lowPrices.length - 20 : 0));
      
      // Method 2: Pivot points
      final prevHigh = highPrices.length >= 2 ? highPrices[highPrices.length - 2] : highPrices.last;
      final prevLow = lowPrices.length >= 2 ? lowPrices[lowPrices.length - 2] : lowPrices.last;
      final prevClose = closePrices.length >= 2 ? closePrices[closePrices.length - 2] : closePrices.last;
      
      final pivot = (prevHigh + prevLow + prevClose) / 3;
      final s1 = 2 * pivot - prevHigh;
      final s2 = pivot - (prevHigh - prevLow);
      final r1 = 2 * pivot - prevLow;
      final r2 = pivot + (prevHigh - prevLow);
      
      // Method 3: Moving averages
      final sma50 = _calculateSMA(closePrices, 50);
      final sma200 = _calculateSMA(closePrices, 200);
      
      // Method 4: Fibonacci retracements
      double fib38 = currentPrice;
      double fib50 = currentPrice;
      double fib62 = currentPrice;
      
      if (highPrices.length >= 100 && lowPrices.length >= 100) {
        final highestHigh = _getMaxValue(highPrices.sublist(highPrices.length - 100));
        final lowestLow = _getMinValue(lowPrices.sublist(lowPrices.length - 100));
        final rangePrice = highestHigh - lowestLow;
        
        if (rangePrice > 0) {
          fib38 = highestHigh - rangePrice * 0.382;
          fib50 = highestHigh - rangePrice * 0.5;
          fib62 = highestHigh - rangePrice * 0.618;
        }
      }
      
      // Combine all levels and sort
      final allLevels = [
        recentLow, s1, s2, sma50, sma200, fib38, fib50, fib62, recentHigh, r1, r2
      ].where((level) => level > 0).toList();
      
      final allSupport = allLevels.where((level) => level < currentPrice).toList()..sort((a, b) => b.compareTo(a));
      final allResistance = allLevels.where((level) => level > currentPrice).toList()..sort();
      
      // Get top 3 closest support and resistance levels (remove duplicates)
      final supportLevels = _getUniqueValues(allSupport).take(3).toList();
      final resistanceLevels = _getUniqueValues(allResistance).take(3).toList();
      
      if (supportLevels.isEmpty) {
        supportLevels.add(currentPrice * 0.95);
      }
      
      if (resistanceLevels.isEmpty) {
        resistanceLevels.add(currentPrice * 1.05);
      }
      
      // Generate day trader recommendation
      final dayTraderRecommendation = _getDayTraderRecommendation(
        stock.symbol,
        currentPrice,
        supportLevels,
        resistanceLevels,
        stock.technicalOutlook ?? 'Neutral',
      );
      
      return SupportResistance(
        symbol: stock.symbol,
        date: DateTime.now().toIso8601String().split('T')[0],
        currentPrice: currentPrice,
        supportLevels: supportLevels,
        resistanceLevels: resistanceLevels,
        dayTraderRecommendation: dayTraderRecommendation,
      );
    } catch (e) {
      print('Error analyzing support and resistance: $e');
      return SupportResistance(
        symbol: stock.symbol,
        date: DateTime.now().toIso8601String().split('T')[0],
        currentPrice: stock.currentPrice,
        supportLevels: [stock.currentPrice * 0.95],
        resistanceLevels: [stock.currentPrice * 1.05],
        dayTraderRecommendation: DayTraderRecommendation.empty(),
      );
    }
  }
  
  /// Calculate Simple Moving Average
  double _calculateSMA(List<double> prices, int period) {
    if (prices.isEmpty) return 0.0;
    
    final int length = prices.length;
    final int start = length > period ? length - period : 0;
    final int actualPeriod = length > period ? period : length;
    
    double sum = 0.0;
    for (int i = start; i < length; i++) {
      sum += prices[i];
    }
    
    return sum / actualPeriod;
  }
  
  /// Get maximum value from a list
  double _getMaxValue(List<double> values) {
    if (values.isEmpty) return 0.0;
    return values.reduce((curr, next) => curr > next ? curr : next);
  }
  
  /// Get minimum value from a list
  double _getMinValue(List<double> values) {
    if (values.isEmpty) return 0.0;
    return values.reduce((curr, next) => curr < next ? curr : next);
  }
  
  /// Get unique values from a list
  List<double> _getUniqueValues(List<double> values) {
    final uniqueValues = <double>[];
    for (final value in values) {
      if (!uniqueValues.contains(value)) {
        uniqueValues.add(value);
      }
    }
    return uniqueValues;
  }
  
  /// Get day trader recommendation based on support and resistance levels
  DayTraderRecommendation _getDayTraderRecommendation(
    String symbol,
    double currentPrice,
    List<double> supportLevels,
    List<double> resistanceLevels,
    String technicalOutlook,
  ) {
    try {
      // Get nearest support and resistance
      final nearestSupport = supportLevels.isNotEmpty ? supportLevels.first : currentPrice * 0.98;
      final nearestResistance = resistanceLevels.isNotEmpty ? resistanceLevels.first : currentPrice * 1.02;
      
      final supportDistance = currentPrice > 0 ? (currentPrice - nearestSupport) / currentPrice : 0;
      final resistanceDistance = currentPrice > 0 ? (nearestResistance - currentPrice) / currentPrice : 0;
      
      // Initialize recommendation defaults
      String signal = 'NEUTRAL';
      String confidence = 'Low';
      double entry = currentPrice;
      double stopLoss = technicalOutlook.contains('Bullish') ? nearestSupport : nearestResistance;
      double target1 = technicalOutlook.contains('Bullish') ? nearestResistance : nearestSupport;
      double target2 = target1;
      
      // Determine signal based on technical outlook and price position
      if (technicalOutlook.contains('Bullish')) {
        // Check if price is near support
        if (supportDistance < 0.02) { // Within 2% of support
          signal = 'BUY';
          confidence = technicalOutlook.contains('Strongly') ? 'High' : 'Medium';
          entry = currentPrice;
          stopLoss = nearestSupport * 0.99; // 1% below support
          target1 = nearestResistance;
          target2 = nearestResistance > 0 ? nearestResistance * 1.05 : currentPrice * 1.05;
        } else {
          signal = 'NEUTRAL';
          confidence = 'Medium';
          entry = nearestSupport * 1.01; // 1% above support
          stopLoss = nearestSupport * 0.99; // 1% below support
          target1 = nearestResistance;
          target2 = nearestResistance > 0 ? nearestResistance * 1.05 : currentPrice * 1.05;
        }
      } else if (technicalOutlook.contains('Bearish')) {
        // Check if price is near resistance
        if (resistanceDistance < 0.02) { // Within 2% of resistance
          signal = 'SELL';
          confidence = technicalOutlook.contains('Strongly') ? 'High' : 'Medium';
          entry = currentPrice;
          stopLoss = nearestResistance * 1.01; // 1% above resistance
          target1 = nearestSupport;
          target2 = nearestSupport > 0 ? nearestSupport * 0.95 : currentPrice * 0.95;
        } else {
          signal = 'NEUTRAL';
          confidence = 'Medium';
          entry = nearestResistance * 0.99; // 1% below resistance
          stopLoss = nearestResistance * 1.01; // 1% above resistance
          target1 = nearestSupport;
          target2 = nearestSupport > 0 ? nearestSupport * 0.95 : currentPrice * 0.95;
        }
      } else {
        signal = 'NEUTRAL';
        confidence = 'Low';
        entry = currentPrice;
        stopLoss = currentPrice > nearestSupport ? nearestSupport * 0.99 : nearestResistance * 1.01;
        target1 = currentPrice < nearestResistance ? nearestResistance : nearestSupport;
        target2 = target1;
      }
      
      // Calculate risk/reward ratio
      final risk = (entry - stopLoss).abs();
      final reward = (entry - target1).abs();
      final riskReward = risk > 0 ? reward / risk : 0;
      
      // Calculate position size based on risk management (1% account risk)
      final accountSize = 10000; // Default account size
      final riskPerTrade = accountSize * 0.01; // 1% risk
      final positionSize = risk > 0 ? (riskPerTrade / risk).toInt() : 0;
      
      return DayTraderRecommendation(
        signal: signal,
        confidence: confidence,
        entry: entry,
        stopLoss: stopLoss,
        target1: target1,
        target2: target2,
        riskReward: riskReward,
        positionSize: positionSize,
        timeframe: '1-2 days',
      );
    } catch (e) {
      print('Error getting day trader recommendation: $e');
      return DayTraderRecommendation.empty();
    }
  }
}
