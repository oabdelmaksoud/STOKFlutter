import 'package:equatable/equatable.dart';

/// Represents options analysis and recommendations
class OptionsAnalysis extends Equatable {
  final String symbol;
  final String date;
  final double currentPrice;
  final double volatility;
  final String technicalOutlook;
  final List<OptionRecommendation> recommendedOptions;

  const OptionsAnalysis({
    required this.symbol,
    required this.date,
    required this.currentPrice,
    required this.volatility,
    required this.technicalOutlook,
    required this.recommendedOptions,
  });

  /// Creates an OptionsAnalysis instance from JSON data
  factory OptionsAnalysis.fromJson(Map<String, dynamic> json) {
    return OptionsAnalysis(
      symbol: json['symbol'] ?? '',
      date: json['date'] ?? '',
      currentPrice: (json['current_price'] ?? 0.0).toDouble(),
      volatility: (json['volatility'] ?? 0.0).toDouble(),
      technicalOutlook: json['technical_outlook'] ?? 'Neutral',
      recommendedOptions: json['recommended_options'] != null
          ? List<OptionRecommendation>.from(json['recommended_options']
              .map((x) => OptionRecommendation.fromJson(x)))
          : [],
    );
  }

  /// Converts OptionsAnalysis instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'symbol': symbol,
      'date': date,
      'current_price': currentPrice,
      'volatility': volatility,
      'technical_outlook': technicalOutlook,
      'recommended_options': recommendedOptions.map((x) => x.toJson()).toList(),
    };
  }

  /// Creates a copy of OptionsAnalysis with modified fields
  OptionsAnalysis copyWith({
    String? symbol,
    String? date,
    double? currentPrice,
    double? volatility,
    String? technicalOutlook,
    List<OptionRecommendation>? recommendedOptions,
  }) {
    return OptionsAnalysis(
      symbol: symbol ?? this.symbol,
      date: date ?? this.date,
      currentPrice: currentPrice ?? this.currentPrice,
      volatility: volatility ?? this.volatility,
      technicalOutlook: technicalOutlook ?? this.technicalOutlook,
      recommendedOptions: recommendedOptions ?? this.recommendedOptions,
    );
  }

  @override
  List<Object?> get props => [
        symbol,
        date,
        currentPrice,
        volatility,
        technicalOutlook,
        recommendedOptions,
      ];
}

/// Represents a specific option recommendation
class OptionRecommendation extends Equatable {
  final String type;
  final double strike;
  final String expiry;
  final double premium;
  final double? delta;
  final double? gamma;
  final double? theta;
  final double? vega;
  final double riskReward;
  final String confidence;
  
  // For strangle/straddle strategies
  final double? callStrike;
  final double? putStrike;
  final double? callPremium;
  final double? putPremium;
  final double? totalPremium;

  const OptionRecommendation({
    required this.type,
    required this.strike,
    required this.expiry,
    required this.premium,
    this.delta,
    this.gamma,
    this.theta,
    this.vega,
    required this.riskReward,
    required this.confidence,
    this.callStrike,
    this.putStrike,
    this.callPremium,
    this.putPremium,
    this.totalPremium,
  });

  /// Creates an OptionRecommendation instance from JSON data
  factory OptionRecommendation.fromJson(Map<String, dynamic> json) {
    return OptionRecommendation(
      type: json['type'] ?? '',
      strike: json['strike'] != null ? (json['strike'] ?? 0.0).toDouble() : 0.0,
      expiry: json['expiry'] ?? '',
      premium: json['premium'] != null ? (json['premium'] ?? 0.0).toDouble() : 0.0,
      delta: json['delta'] != null ? (json['delta'] ?? 0.0).toDouble() : null,
      gamma: json['gamma'] != null ? (json['gamma'] ?? 0.0).toDouble() : null,
      theta: json['theta'] != null ? (json['theta'] ?? 0.0).toDouble() : null,
      vega: json['vega'] != null ? (json['vega'] ?? 0.0).toDouble() : null,
      riskReward: (json['risk_reward'] ?? 0.0).toDouble(),
      confidence: json['confidence'] ?? 'Medium',
      callStrike: json['call_strike'] != null ? (json['call_strike'] ?? 0.0).toDouble() : null,
      putStrike: json['put_strike'] != null ? (json['put_strike'] ?? 0.0).toDouble() : null,
      callPremium: json['call_premium'] != null ? (json['call_premium'] ?? 0.0).toDouble() : null,
      putPremium: json['put_premium'] != null ? (json['put_premium'] ?? 0.0).toDouble() : null,
      totalPremium: json['total_premium'] != null ? (json['total_premium'] ?? 0.0).toDouble() : null,
    );
  }

  /// Converts OptionRecommendation instance to JSON
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'type': type,
      'expiry': expiry,
      'risk_reward': riskReward,
      'confidence': confidence,
    };
    
    if (strike > 0) data['strike'] = strike;
    if (premium > 0) data['premium'] = premium;
    if (delta != null) data['delta'] = delta;
    if (gamma != null) data['gamma'] = gamma;
    if (theta != null) data['theta'] = theta;
    if (vega != null) data['vega'] = vega;
    
    // For strangle/straddle strategies
    if (callStrike != null) data['call_strike'] = callStrike;
    if (putStrike != null) data['put_strike'] = putStrike;
    if (callPremium != null) data['call_premium'] = callPremium;
    if (putPremium != null) data['put_premium'] = putPremium;
    if (totalPremium != null) data['total_premium'] = totalPremium;
    
    return data;
  }

  @override
  List<Object?> get props => [
        type,
        strike,
        expiry,
        premium,
        delta,
        gamma,
        theta,
        vega,
        riskReward,
        confidence,
        callStrike,
        putStrike,
        callPremium,
        putPremium,
        totalPremium,
      ];
}

/// Represents multiple expiry recommendations
class MultipleExpiryRecommendations extends Equatable {
  final String symbol;
  final String date;
  final double currentPrice;
  final double volatility;
  final String oneWeekExpiry;
  final String twoWeekExpiry;
  final String monthlyExpiry;
  final double oneWeekExpectedMove;
  final double twoWeekExpectedMove;
  final double monthlyExpectedMove;
  final List<OptionRecommendation> oneWeekExpiryRecommendations;
  final List<OptionRecommendation> twoWeekExpiryRecommendations;
  final List<OptionRecommendation> monthlyExpiryRecommendations;
  final String expiryComparison;

  const MultipleExpiryRecommendations({
    required this.symbol,
    required this.date,
    required this.currentPrice,
    required this.volatility,
    required this.oneWeekExpiry,
    required this.twoWeekExpiry,
    required this.monthlyExpiry,
    required this.oneWeekExpectedMove,
    required this.twoWeekExpectedMove,
    required this.monthlyExpectedMove,
    required this.oneWeekExpiryRecommendations,
    required this.twoWeekExpiryRecommendations,
    required this.monthlyExpiryRecommendations,
    required this.expiryComparison,
  });

  /// Creates a MultipleExpiryRecommendations instance from JSON data
  factory MultipleExpiryRecommendations.fromJson(Map<String, dynamic> json) {
    return MultipleExpiryRecommendations(
      symbol: json['symbol'] ?? '',
      date: json['date'] ?? '',
      currentPrice: (json['current_price'] ?? 0.0).toDouble(),
      volatility: (json['volatility'] ?? 0.0).toDouble(),
      oneWeekExpiry: json['one_week_expiry'] ?? '',
      twoWeekExpiry: json['two_week_expiry'] ?? '',
      monthlyExpiry: json['monthly_expiry'] ?? '',
      oneWeekExpectedMove: (json['one_week_expected_move'] ?? 0.0).toDouble(),
      twoWeekExpectedMove: (json['two_week_expected_move'] ?? 0.0).toDouble(),
      monthlyExpectedMove: (json['monthly_expected_move'] ?? 0.0).toDouble(),
      oneWeekExpiryRecommendations: json['one_week_expiry_recommendations'] != null
          ? List<OptionRecommendation>.from(json['one_week_expiry_recommendations']
              .map((x) => OptionRecommendation.fromJson(x)))
          : [],
      twoWeekExpiryRecommendations: json['two_week_expiry_recommendations'] != null
          ? List<OptionRecommendation>.from(json['two_week_expiry_recommendations']
              .map((x) => OptionRecommendation.fromJson(x)))
          : [],
      monthlyExpiryRecommendations: json['monthly_expiry_recommendations'] != null
          ? List<OptionRecommendation>.from(json['monthly_expiry_recommendations']
              .map((x) => OptionRecommendation.fromJson(x)))
          : [],
      expiryComparison: json['expiry_comparison'] ?? '',
    );
  }

  /// Converts MultipleExpiryRecommendations instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'symbol': symbol,
      'date': date,
      'current_price': currentPrice,
      'volatility': volatility,
      'one_week_expiry': oneWeekExpiry,
      'two_week_expiry': twoWeekExpiry,
      'monthly_expiry': monthlyExpiry,
      'one_week_expected_move': oneWeekExpectedMove,
      'two_week_expected_move': twoWeekExpectedMove,
      'monthly_expected_move': monthlyExpectedMove,
      'one_week_expiry_recommendations': oneWeekExpiryRecommendations.map((x) => x.toJson()).toList(),
      'two_week_expiry_recommendations': twoWeekExpiryRecommendations.map((x) => x.toJson()).toList(),
      'monthly_expiry_recommendations': monthlyExpiryRecommendations.map((x) => x.toJson()).toList(),
      'expiry_comparison': expiryComparison,
    };
  }

  @override
  List<Object?> get props => [
        symbol,
        date,
        currentPrice,
        volatility,
        oneWeekExpiry,
        twoWeekExpiry,
        monthlyExpiry,
        oneWeekExpectedMove,
        twoWeekExpectedMove,
        monthlyExpectedMove,
        oneWeekExpiryRecommendations,
        twoWeekExpiryRecommendations,
        monthlyExpiryRecommendations,
        expiryComparison,
      ];
}
