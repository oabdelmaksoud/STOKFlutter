import 'package:equatable/equatable.dart';

/// Represents support and resistance levels for a stock
class SupportResistance extends Equatable {
  final String symbol;
  final String date;
  final double currentPrice;
  final List<double> supportLevels;
  final List<double> resistanceLevels;
  final DayTraderRecommendation dayTraderRecommendation;

  const SupportResistance({
    required this.symbol,
    required this.date,
    required this.currentPrice,
    required this.supportLevels,
    required this.resistanceLevels,
    required this.dayTraderRecommendation,
  });

  /// Creates a SupportResistance instance from JSON data
  factory SupportResistance.fromJson(Map<String, dynamic> json) {
    return SupportResistance(
      symbol: json['symbol'] ?? '',
      date: json['date'] ?? '',
      currentPrice: (json['current_price'] ?? 0.0).toDouble(),
      supportLevels: List<double>.from(
          (json['support_levels'] ?? []).map((e) => (e ?? 0.0).toDouble())),
      resistanceLevels: List<double>.from(
          (json['resistance_levels'] ?? []).map((e) => (e ?? 0.0).toDouble())),
      dayTraderRecommendation: json['day_trader_recommendation'] != null
          ? DayTraderRecommendation.fromJson(json['day_trader_recommendation'])
          : DayTraderRecommendation.empty(),
    );
  }

  /// Converts SupportResistance instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'symbol': symbol,
      'date': date,
      'current_price': currentPrice,
      'support_levels': supportLevels,
      'resistance_levels': resistanceLevels,
      'day_trader_recommendation': dayTraderRecommendation.toJson(),
    };
  }

  /// Creates a copy of SupportResistance with modified fields
  SupportResistance copyWith({
    String? symbol,
    String? date,
    double? currentPrice,
    List<double>? supportLevels,
    List<double>? resistanceLevels,
    DayTraderRecommendation? dayTraderRecommendation,
  }) {
    return SupportResistance(
      symbol: symbol ?? this.symbol,
      date: date ?? this.date,
      currentPrice: currentPrice ?? this.currentPrice,
      supportLevels: supportLevels ?? this.supportLevels,
      resistanceLevels: resistanceLevels ?? this.resistanceLevels,
      dayTraderRecommendation:
          dayTraderRecommendation ?? this.dayTraderRecommendation,
    );
  }

  @override
  List<Object?> get props => [
        symbol,
        date,
        currentPrice,
        supportLevels,
        resistanceLevels,
        dayTraderRecommendation,
      ];
}

/// Represents day trader recommendation based on support and resistance levels
class DayTraderRecommendation extends Equatable {
  final String signal;
  final String confidence;
  final double entry;
  final double stopLoss;
  final double target1;
  final double target2;
  final double riskReward;
  final int positionSize;
  final String timeframe;

  const DayTraderRecommendation({
    required this.signal,
    required this.confidence,
    required this.entry,
    required this.stopLoss,
    required this.target1,
    required this.target2,
    required this.riskReward,
    required this.positionSize,
    required this.timeframe,
  });

  /// Creates an empty DayTraderRecommendation with default values
  factory DayTraderRecommendation.empty() {
    return const DayTraderRecommendation(
      signal: 'NEUTRAL',
      confidence: 'Low',
      entry: 0.0,
      stopLoss: 0.0,
      target1: 0.0,
      target2: 0.0,
      riskReward: 0.0,
      positionSize: 0,
      timeframe: '1-2 days',
    );
  }

  /// Creates a DayTraderRecommendation instance from JSON data
  factory DayTraderRecommendation.fromJson(Map<String, dynamic> json) {
    return DayTraderRecommendation(
      signal: json['signal'] ?? 'NEUTRAL',
      confidence: json['confidence'] ?? 'Low',
      entry: (json['entry'] ?? 0.0).toDouble(),
      stopLoss: (json['stop_loss'] ?? 0.0).toDouble(),
      target1: (json['target_1'] ?? 0.0).toDouble(),
      target2: (json['target_2'] ?? 0.0).toDouble(),
      riskReward: (json['risk_reward'] ?? 0.0).toDouble(),
      positionSize: (json['position_size'] ?? 0).toInt(),
      timeframe: json['timeframe'] ?? '1-2 days',
    );
  }

  /// Converts DayTraderRecommendation instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'signal': signal,
      'confidence': confidence,
      'entry': entry,
      'stop_loss': stopLoss,
      'target_1': target1,
      'target_2': target2,
      'risk_reward': riskReward,
      'position_size': positionSize,
      'timeframe': timeframe,
    };
  }

  /// Creates a copy of DayTraderRecommendation with modified fields
  DayTraderRecommendation copyWith({
    String? signal,
    String? confidence,
    double? entry,
    double? stopLoss,
    double? target1,
    double? target2,
    double? riskReward,
    int? positionSize,
    String? timeframe,
  }) {
    return DayTraderRecommendation(
      signal: signal ?? this.signal,
      confidence: confidence ?? this.confidence,
      entry: entry ?? this.entry,
      stopLoss: stopLoss ?? this.stopLoss,
      target1: target1 ?? this.target1,
      target2: target2 ?? this.target2,
      riskReward: riskReward ?? this.riskReward,
      positionSize: positionSize ?? this.positionSize,
      timeframe: timeframe ?? this.timeframe,
    );
  }

  @override
  List<Object?> get props => [
        signal,
        confidence,
        entry,
        stopLoss,
        target1,
        target2,
        riskReward,
        positionSize,
        timeframe,
      ];
}
