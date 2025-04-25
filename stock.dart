import 'package:equatable/equatable.dart';

/// Represents stock data retrieved from Yahoo Finance
class Stock extends Equatable {
  final String symbol;
  final String name;
  final String sector;
  final String industry;
  final double currentPrice;
  final double marketCap;
  final double peRatio;
  final double eps;
  final double dividendYield;
  final double weekHigh52;
  final double weekLow52;
  final double volume;
  final double avgVolume;
  final List<String> dates;
  final List<double> openPrices;
  final List<double> highPrices;
  final List<double> lowPrices;
  final List<double> closePrices;
  final List<double> volumeHistory;
  final double volatility;
  final double impliedVolatility;
  final String retrievalTime;
  final OptionsData? options;

  const Stock({
    required this.symbol,
    required this.name,
    required this.sector,
    required this.industry,
    required this.currentPrice,
    required this.marketCap,
    required this.peRatio,
    required this.eps,
    required this.dividendYield,
    required this.weekHigh52,
    required this.weekLow52,
    required this.volume,
    required this.avgVolume,
    required this.dates,
    required this.openPrices,
    required this.highPrices,
    required this.lowPrices,
    required this.closePrices,
    required this.volumeHistory,
    required this.volatility,
    required this.impliedVolatility,
    required this.retrievalTime,
    this.options,
  });

  /// Creates a Stock instance from JSON data
  factory Stock.fromJson(Map<String, dynamic> json) {
    return Stock(
      symbol: json['symbol'] ?? '',
      name: json['name'] ?? json['symbol'] ?? '',
      sector: json['sector'] ?? 'Unknown',
      industry: json['industry'] ?? 'Unknown',
      currentPrice: (json['current_price'] ?? 0.0).toDouble(),
      marketCap: (json['market_cap'] ?? 0.0).toDouble(),
      peRatio: (json['pe_ratio'] ?? 0.0).toDouble(),
      eps: (json['eps'] ?? 0.0).toDouble(),
      dividendYield: (json['dividend_yield'] ?? 0.0).toDouble(),
      weekHigh52: (json['52_week_high'] ?? 0.0).toDouble(),
      weekLow52: (json['52_week_low'] ?? 0.0).toDouble(),
      volume: (json['volume'] ?? 0.0).toDouble(),
      avgVolume: (json['avg_volume'] ?? 0.0).toDouble(),
      dates: List<String>.from(json['dates'] ?? []),
      openPrices: List<double>.from((json['open'] ?? []).map((e) => (e ?? 0.0).toDouble())),
      highPrices: List<double>.from((json['high'] ?? []).map((e) => (e ?? 0.0).toDouble())),
      lowPrices: List<double>.from((json['low'] ?? []).map((e) => (e ?? 0.0).toDouble())),
      closePrices: List<double>.from((json['close'] ?? []).map((e) => (e ?? 0.0).toDouble())),
      volumeHistory: List<double>.from((json['volume_hist'] ?? []).map((e) => (e ?? 0.0).toDouble())),
      volatility: (json['volatility'] ?? 0.0).toDouble(),
      impliedVolatility: (json['implied_volatility'] ?? 0.0).toDouble(),
      retrievalTime: json['retrieval_time'] ?? DateTime.now().toString(),
      options: json['options'] != null ? OptionsData.fromJson(json['options']) : null,
    );
  }

  /// Converts Stock instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'symbol': symbol,
      'name': name,
      'sector': sector,
      'industry': industry,
      'current_price': currentPrice,
      'market_cap': marketCap,
      'pe_ratio': peRatio,
      'eps': eps,
      'dividend_yield': dividendYield,
      '52_week_high': weekHigh52,
      '52_week_low': weekLow52,
      'volume': volume,
      'avg_volume': avgVolume,
      'dates': dates,
      'open': openPrices,
      'high': highPrices,
      'low': lowPrices,
      'close': closePrices,
      'volume_hist': volumeHistory,
      'volatility': volatility,
      'implied_volatility': impliedVolatility,
      'retrieval_time': retrievalTime,
      'options': options?.toJson(),
    };
  }

  /// Creates a copy of Stock with modified fields
  Stock copyWith({
    String? symbol,
    String? name,
    String? sector,
    String? industry,
    double? currentPrice,
    double? marketCap,
    double? peRatio,
    double? eps,
    double? dividendYield,
    double? weekHigh52,
    double? weekLow52,
    double? volume,
    double? avgVolume,
    List<String>? dates,
    List<double>? openPrices,
    List<double>? highPrices,
    List<double>? lowPrices,
    List<double>? closePrices,
    List<double>? volumeHistory,
    double? volatility,
    double? impliedVolatility,
    String? retrievalTime,
    OptionsData? options,
  }) {
    return Stock(
      symbol: symbol ?? this.symbol,
      name: name ?? this.name,
      sector: sector ?? this.sector,
      industry: industry ?? this.industry,
      currentPrice: currentPrice ?? this.currentPrice,
      marketCap: marketCap ?? this.marketCap,
      peRatio: peRatio ?? this.peRatio,
      eps: eps ?? this.eps,
      dividendYield: dividendYield ?? this.dividendYield,
      weekHigh52: weekHigh52 ?? this.weekHigh52,
      weekLow52: weekLow52 ?? this.weekLow52,
      volume: volume ?? this.volume,
      avgVolume: avgVolume ?? this.avgVolume,
      dates: dates ?? this.dates,
      openPrices: openPrices ?? this.openPrices,
      highPrices: highPrices ?? this.highPrices,
      lowPrices: lowPrices ?? this.lowPrices,
      closePrices: closePrices ?? this.closePrices,
      volumeHistory: volumeHistory ?? this.volumeHistory,
      volatility: volatility ?? this.volatility,
      impliedVolatility: impliedVolatility ?? this.impliedVolatility,
      retrievalTime: retrievalTime ?? this.retrievalTime,
      options: options ?? this.options,
    );
  }

  @override
  List<Object?> get props => [
        symbol,
        name,
        sector,
        industry,
        currentPrice,
        marketCap,
        peRatio,
        eps,
        dividendYield,
        weekHigh52,
        weekLow52,
        volume,
        avgVolume,
        dates,
        openPrices,
        highPrices,
        lowPrices,
        closePrices,
        volumeHistory,
        volatility,
        impliedVolatility,
        retrievalTime,
        options,
      ];
}

/// Represents options data for a stock
class OptionsData extends Equatable {
  final String expiry;
  final List<OptionContract> calls;
  final List<OptionContract> puts;

  const OptionsData({
    required this.expiry,
    required this.calls,
    required this.puts,
  });

  factory OptionsData.fromJson(Map<String, dynamic> json) {
    return OptionsData(
      expiry: json['expiry'] ?? '',
      calls: json['calls'] != null
          ? List<OptionContract>.from(
              json['calls'].map((x) => OptionContract.fromJson(x)))
          : [],
      puts: json['puts'] != null
          ? List<OptionContract>.from(
              json['puts'].map((x) => OptionContract.fromJson(x)))
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'expiry': expiry,
      'calls': calls.map((x) => x.toJson()).toList(),
      'puts': puts.map((x) => x.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => [expiry, calls, puts];
}

/// Represents an options contract
class OptionContract extends Equatable {
  final double strike;
  final double premium;
  final double? delta;
  final double? gamma;
  final double? theta;
  final double? vega;

  const OptionContract({
    required this.strike,
    required this.premium,
    this.delta,
    this.gamma,
    this.theta,
    this.vega,
  });

  factory OptionContract.fromJson(Map<String, dynamic> json) {
    return OptionContract(
      strike: (json['strike'] ?? 0.0).toDouble(),
      premium: (json['premium'] ?? 0.0).toDouble(),
      delta: json['delta'] != null ? (json['delta'] ?? 0.0).toDouble() : null,
      gamma: json['gamma'] != null ? (json['gamma'] ?? 0.0).toDouble() : null,
      theta: json['theta'] != null ? (json['theta'] ?? 0.0).toDouble() : null,
      vega: json['vega'] != null ? (json['vega'] ?? 0.0).toDouble() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'strike': strike,
      'premium': premium,
      'delta': delta,
      'gamma': gamma,
      'theta': theta,
      'vega': vega,
    };
  }

  @override
  List<Object?> get props => [strike, premium, delta, gamma, theta, vega];
}
