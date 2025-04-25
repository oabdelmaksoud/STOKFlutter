import 'package:stock_options_analyzer/data/models/stock.dart';
import 'package:stock_options_analyzer/data/models/technical_analysis.dart';

/// Service for analyzing technical indicators
class TechnicalAnalysisService {
  /// Analyze technical indicators for a stock
  TechnicalAnalysis analyzeTechnicalIndicators(Stock stock) {
    try {
      // Calculate SMA
      final closePrices = stock.closePrices;
      final sma50 = _calculateSMA(closePrices, 50);
      final sma200 = _calculateSMA(closePrices, 200);

      // Calculate RSI
      final rsi = _calculateRSI(closePrices);

      // Calculate MACD
      final macdResult = _calculateMACD(closePrices);
      final macd = macdResult['macd'] ?? 0.0;
      final macdSignal = macdResult['signal'] ?? 0.0;
      final macdHistogram = macdResult['histogram'] ?? 0.0;

      // Determine technical outlook
      final technicalOutlook = _determineTechnicalOutlook(
        sma50: sma50,
        sma200: sma200,
        rsi: rsi,
        macd: macd,
        macdSignal: macdSignal,
      );

      return TechnicalAnalysis(
        symbol: stock.symbol,
        date: DateTime.now().toIso8601String().split('T')[0],
        name: stock.name,
        currentPrice: stock.currentPrice,
        sector: stock.sector,
        industry: stock.industry,
        marketCap: stock.marketCap,
        peRatio: stock.peRatio,
        eps: stock.eps,
        dividendYield: stock.dividendYield,
        weekHigh52: stock.weekHigh52,
        weekLow52: stock.weekLow52,
        volume: stock.volume,
        avgVolume: stock.avgVolume,
        volatility: stock.volatility,
        impliedVolatility: stock.impliedVolatility,
        sma50: sma50,
        sma200: sma200,
        rsi: rsi,
        macd: macd,
        macdSignal: macdSignal,
        macdHistogram: macdHistogram,
        technicalOutlook: technicalOutlook,
      );
    } catch (e) {
      print('Error analyzing technical indicators: $e');
      return TechnicalAnalysis(
        symbol: stock.symbol,
        date: DateTime.now().toIso8601String().split('T')[0],
        name: stock.name,
        currentPrice: stock.currentPrice,
        sector: stock.sector,
        industry: stock.industry,
        marketCap: stock.marketCap,
        peRatio: stock.peRatio,
        eps: stock.eps,
        dividendYield: stock.dividendYield,
        weekHigh52: stock.weekHigh52,
        weekLow52: stock.weekLow52,
        volume: stock.volume,
        avgVolume: stock.avgVolume,
        volatility: stock.volatility,
        impliedVolatility: stock.impliedVolatility,
        sma50: 0.0,
        sma200: 0.0,
        rsi: 50.0,
        macd: 0.0,
        macdSignal: 0.0,
        macdHistogram: 0.0,
        technicalOutlook: 'Neutral',
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

  /// Calculate Relative Strength Index
  double _calculateRSI(List<double> prices) {
    if (prices.length < 15) return 50.0; // Default to neutral if not enough data
    
    final gains = <double>[];
    final losses = <double>[];
    
    // Calculate price changes
    for (int i = 1; i < prices.length; i++) {
      final change = prices[i] - prices[i - 1];
      if (change >= 0) {
        gains.add(change);
        losses.add(0);
      } else {
        gains.add(0);
        losses.add(-change);
      }
    }
    
    // Calculate average gain and loss over 14 periods
    final int period = 14;
    final int dataPoints = gains.length;
    final int start = dataPoints > period ? dataPoints - period : 0;
    
    double avgGain = 0.0;
    double avgLoss = 0.0;
    
    for (int i = start; i < dataPoints; i++) {
      avgGain += gains[i];
      avgLoss += losses[i];
    }
    
    avgGain /= period;
    avgLoss /= period;
    
    // Calculate RSI
    if (avgLoss == 0) return 100.0;
    
    final rs = avgGain / avgLoss;
    return 100.0 - (100.0 / (1.0 + rs));
  }

  /// Calculate Moving Average Convergence Divergence
  Map<String, double> _calculateMACD(List<double> prices) {
    if (prices.length < 26) {
      return {
        'macd': 0.0,
        'signal': 0.0,
        'histogram': 0.0,
      };
    }
    
    // Calculate EMA 12
    final ema12 = _calculateEMA(prices, 12);
    
    // Calculate EMA 26
    final ema26 = _calculateEMA(prices, 26);
    
    // Calculate MACD line
    final macd = ema12 - ema26;
    
    // Calculate signal line (9-day EMA of MACD)
    final macdHistory = <double>[];
    for (int i = prices.length - 26; i < prices.length; i++) {
      final idx = i - (prices.length - 26);
      if (idx >= 0) {
        final ema12Point = _calculateEMAPoint(prices.sublist(0, i + 1), 12);
        final ema26Point = _calculateEMAPoint(prices.sublist(0, i + 1), 26);
        macdHistory.add(ema12Point - ema26Point);
      }
    }
    
    final signal = _calculateEMAPoint(macdHistory, 9);
    
    // Calculate histogram
    final histogram = macd - signal;
    
    return {
      'macd': macd,
      'signal': signal,
      'histogram': histogram,
    };
  }

  /// Calculate Exponential Moving Average
  double _calculateEMA(List<double> prices, int period) {
    if (prices.isEmpty) return 0.0;
    if (prices.length <= period) return _calculateSMA(prices, prices.length);
    
    final double k = 2.0 / (period + 1.0);
    final double emaYesterday = _calculateEMAPoint(prices.sublist(0, prices.length - 1), period);
    return (prices.last - emaYesterday) * k + emaYesterday;
  }

  /// Calculate EMA for a specific point
  double _calculateEMAPoint(List<double> prices, int period) {
    if (prices.isEmpty) return 0.0;
    if (prices.length <= period) return _calculateSMA(prices, prices.length);
    
    // Start with SMA for the first period
    double ema = _calculateSMA(prices.sublist(0, period), period);
    final double k = 2.0 / (period + 1.0);
    
    // Calculate EMA for the rest of the points
    for (int i = period; i < prices.length; i++) {
      ema = (prices[i] - ema) * k + ema;
    }
    
    return ema;
  }

  /// Determine technical outlook based on indicators
  String _determineTechnicalOutlook({
    required double sma50,
    required double sma200,
    required double rsi,
    required double macd,
    required double macdSignal,
  }) {
    if (sma50 > sma200 && rsi > 50 && macd > macdSignal) {
      return 'Strongly Bullish';
    } else if (sma50 > sma200 && (rsi > 50 || macd > macdSignal)) {
      return 'Moderately Bullish';
    } else if (sma50 < sma200 && rsi < 50 && macd < macdSignal) {
      return 'Strongly Bearish';
    } else if (sma50 < sma200 && (rsi < 50 || macd < macdSignal)) {
      return 'Moderately Bearish';
    } else {
      return 'Neutral';
    }
  }
}
