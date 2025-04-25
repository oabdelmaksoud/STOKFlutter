import 'package:equatable/equatable.dart';

/// Represents technical analysis data for a stock
class TechnicalAnalysis extends Equatable {
  final String symbol;
  final String date;
  final String name;
  final double currentPrice;
  final String sector;
  final String industry;
  final double marketCap;
  final double peRatio;
  final double eps;
  final double dividendYield;
  final double weekHigh52;
  final double weekLow52;
  final double volume;
  final double avgVolume;
  final double volatility;
  final double impliedVolatility;
  final double sma50;
  final double sma200;
  final double rsi;
  final double macd;
  final double macdSignal;
  final double macdHistogram;
  final String technicalOutlook;

  const TechnicalAnalysis({
    required this.symbol,
    required this.date,
    required this.name,
    required this.currentPrice,
    required this.sector,
    required this.industry,
    required this.marketCap,
    required this.peRatio,
    required this.eps,
    required this.dividendYield,
    required this.weekHigh52,
    required this.weekLow52,
    required this.volume,
    required this.avgVolume,
    required this.volatility,
    required this.impliedVolatility,
    required this.sma50,
    required this.sma200,
    required this.rsi,
    required this.macd,
    required this.macdSignal,
    required this.macdHistogram,
    required this.technicalOutlook,
  });

  /// Creates a TechnicalAnalysis instance from JSON data
  factory TechnicalAnalysis.fromJson(Map<String, dynamic> json) {
    return TechnicalAnalysis(
      symbol: json['symbol'] ?? '',
      date: json['date'] ?? '',
      name: json['name'] ?? '',
      currentPrice: (json['current_price'] ?? 0.0).toDouble(),
      sector: json['sector'] ?? 'Unknown',
      industry: json['industry'] ?? 'Unknown',
      marketCap: (json['market_cap'] ?? 0.0).toDouble(),
      peRatio: (json['pe_ratio'] ?? 0.0).toDouble(),
      eps: (json['eps'] ?? 0.0).toDouble(),
      dividendYield: (json['dividend_yield'] ?? 0.0).toDouble(),
      weekHigh52: (json['52_week_high'] ?? 0.0).toDouble(),
      weekLow52: (json['52_week_low'] ?? 0.0).toDouble(),
      volume: (json['volume'] ?? 0.0).toDouble(),
      avgVolume: (json['avg_volume'] ?? 0.0).toDouble(),
      volatility: (json['volatility'] ?? 0.0).toDouble(),
      impliedVolatility: (json['implied_volatility'] ?? 0.0).toDouble(),
      sma50: (json['sma_50'] ?? 0.0).toDouble(),
      sma200: (json['sma_200'] ?? 0.0).toDouble(),
      rsi: (json['rsi'] ?? 50.0).toDouble(),
      macd: (json['macd'] ?? 0.0).toDouble(),
      macdSignal: (json['macd_signal'] ?? 0.0).toDouble(),
      macdHistogram: (json['macd_histogram'] ?? 0.0).toDouble(),
      technicalOutlook: json['technical_outlook'] ?? 'Neutral',
    );
  }

  /// Converts TechnicalAnalysis instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'symbol': symbol,
      'date': date,
      'name': name,
      'current_price': currentPrice,
      'sector': sector,
      'industry': industry,
      'market_cap': marketCap,
      'pe_ratio': peRatio,
      'eps': eps,
      'dividend_yield': dividendYield,
      '52_week_high': weekHigh52,
      '52_week_low': weekLow52,
      'volume': volume,
      'avg_volume': avgVolume,
      'volatility': volatility,
      'implied_volatility': impliedVolatility,
      'sma_50': sma50,
      'sma_200': sma200,
      'rsi': rsi,
      'macd': macd,
      'macd_signal': macdSignal,
      'macd_histogram': macdHistogram,
      'technical_outlook': technicalOutlook,
    };
  }

  /// Creates a copy of TechnicalAnalysis with modified fields
  TechnicalAnalysis copyWith({
    String? symbol,
    String? date,
    String? name,
    double? currentPrice,
    String? sector,
    String? industry,
    double? marketCap,
    double? peRatio,
    double? eps,
    double? dividendYield,
    double? weekHigh52,
    double? weekLow52,
    double? volume,
    double? avgVolume,
    double? volatility,
    double? impliedVolatility,
    double? sma50,
    double? sma200,
    double? rsi,
    double? macd,
    double? macdSignal,
    double? macdHistogram,
    String? technicalOutlook,
  }) {
    return TechnicalAnalysis(
      symbol: symbol ?? this.symbol,
      date: date ?? this.date,
      name: name ?? this.name,
      currentPrice: currentPrice ?? this.currentPrice,
      sector: sector ?? this.sector,
      industry: industry ?? this.industry,
      marketCap: marketCap ?? this.marketCap,
      peRatio: peRatio ?? this.peRatio,
      eps: eps ?? this.eps,
      dividendYield: dividendYield ?? this.dividendYield,
      weekHigh52: weekHigh52 ?? this.weekHigh52,
      weekLow52: weekLow52 ?? this.weekLow52,
      volume: volume ?? this.volume,
      avgVolume: avgVolume ?? this.avgVolume,
      volatility: volatility ?? this.volatility,
      impliedVolatility: impliedVolatility ?? this.impliedVolatility,
      sma50: sma50 ?? this.sma50,
      sma200: sma200 ?? this.sma200,
      rsi: rsi ?? this.rsi,
      macd: macd ?? this.macd,
      macdSignal: macdSignal ?? this.macdSignal,
      macdHistogram: macdHistogram ?? this.macdHistogram,
      technicalOutlook: technicalOutlook ?? this.technicalOutlook,
    );
  }

  @override
  List<Object?> get props => [
        symbol,
        date,
        name,
        currentPrice,
        sector,
        industry,
        marketCap,
        peRatio,
        eps,
        dividendYield,
        weekHigh52,
        weekLow52,
        volume,
        avgVolume,
        volatility,
        impliedVolatility,
        sma50,
        sma200,
        rsi,
        macd,
        macdSignal,
        macdHistogram,
        technicalOutlook,
      ];
}
