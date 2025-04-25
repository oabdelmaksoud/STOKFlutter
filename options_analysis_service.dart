import 'package:stock_options_analyzer/data/models/options.dart';
import 'package:stock_options_analyzer/data/models/stock.dart';
import 'package:stock_options_analyzer/data/models/support_resistance.dart';

/// Service for analyzing options contracts
class OptionsAnalysisService {
  /// Analyze options contracts for a stock
  OptionsAnalysis analyzeOptions(
    Stock stock,
    SupportResistance supportResistance,
    String technicalOutlook,
  ) {
    try {
      final currentPrice = stock.currentPrice;
      final volatility = stock.impliedVolatility > 0 
          ? stock.impliedVolatility 
          : stock.volatility > 0 
              ? stock.volatility 
              : 0.3; // Default if both are zero
      
      final supportLevels = supportResistance.supportLevels;
      final resistanceLevels = supportResistance.resistanceLevels;
      
      // Check if we have options data from Yahoo Finance
      final optionsData = stock.options;
      List<OptionRecommendation> recommendedOptions = [];
      
      if (technicalOutlook.contains('Bullish')) {
        // Recommend call options
        // Find strikes near resistance levels
        for (final resistance in resistanceLevels) {
          if (optionsData != null && optionsData.calls.isNotEmpty) {
            // Find closest strike to resistance
            OptionContract? bestOption;
            double closestDistance = double.infinity;
            
            for (final call in optionsData.calls) {
              final distance = (call.strike - resistance).abs();
              if (distance < closestDistance) {
                closestDistance = distance;
                bestOption = call;
              }
            }
            
            if (bestOption != null) {
              // Calculate risk/reward
              final premium = bestOption.premium;
              final potentialProfit = resistance * 1.05 - bestOption.strike;
              final ratio = premium > 0 ? potentialProfit / premium : 0;
              
              recommendedOptions.add(OptionRecommendation(
                type: 'CALL',
                strike: bestOption.strike,
                expiry: optionsData.expiry,
                premium: bestOption.premium,
                delta: bestOption.delta,
                gamma: bestOption.gamma,
                theta: bestOption.theta,
                vega: bestOption.vega,
                riskReward: ratio,
                confidence: technicalOutlook.contains('Strongly') ? 'High' : 'Medium',
              ));
            }
          } else {
            // Generate synthetic option recommendation
            final strike = resistance;
            final timeToExpiry = 7 / 365.0; // 1 week
            final premium = _calculateOptionPremium(
              currentPrice, 
              strike, 
              volatility, 
              timeToExpiry, 
              'call'
            );
            
            final potentialProfit = resistance * 1.05 - strike;
            final ratio = premium > 0 ? potentialProfit / premium : 0;
            
            recommendedOptions.add(OptionRecommendation(
              type: 'CALL',
              strike: strike,
              expiry: _getExpiryDateString(7), // 1 week
              premium: premium,
              riskReward: ratio,
              confidence: technicalOutlook.contains('Strongly') ? 'High' : 'Medium',
            ));
          }
        }
      } else if (technicalOutlook.contains('Bearish')) {
        // Recommend put options
        // Find strikes near support levels
        for (final support in supportLevels) {
          if (optionsData != null && optionsData.puts.isNotEmpty) {
            // Find closest strike to support
            OptionContract? bestOption;
            double closestDistance = double.infinity;
            
            for (final put in optionsData.puts) {
              final distance = (put.strike - support).abs();
              if (distance < closestDistance) {
                closestDistance = distance;
                bestOption = put;
              }
            }
            
            if (bestOption != null) {
              // Calculate risk/reward
              final premium = bestOption.premium;
              final potentialProfit = bestOption.strike - support * 0.95;
              final ratio = premium > 0 ? potentialProfit / premium : 0;
              
              recommendedOptions.add(OptionRecommendation(
                type: 'PUT',
                strike: bestOption.strike,
                expiry: optionsData.expiry,
                premium: bestOption.premium,
                delta: bestOption.delta,
                gamma: bestOption.gamma,
                theta: bestOption.theta,
                vega: bestOption.vega,
                riskReward: ratio,
                confidence: technicalOutlook.contains('Strongly') ? 'High' : 'Medium',
              ));
            }
          } else {
            // Generate synthetic option recommendation
            final strike = support;
            final timeToExpiry = 7 / 365.0; // 1 week
            final premium = _calculateOptionPremium(
              currentPrice, 
              strike, 
              volatility, 
              timeToExpiry, 
              'put'
            );
            
            final potentialProfit = strike - support * 0.95;
            final ratio = premium > 0 ? potentialProfit / premium : 0;
            
            recommendedOptions.add(OptionRecommendation(
              type: 'PUT',
              strike: strike,
              expiry: _getExpiryDateString(7), // 1 week
              premium: premium,
              riskReward: ratio,
              confidence: technicalOutlook.contains('Strongly') ? 'High' : 'Medium',
            ));
          }
        }
      } else {
        // Neutral outlook - recommend iron condor or strangle
        if (supportLevels.isNotEmpty && resistanceLevels.isNotEmpty) {
          final support = supportLevels.first;
          final resistance = resistanceLevels.first;
          
          if (optionsData != null && 
              optionsData.calls.isNotEmpty && 
              optionsData.puts.isNotEmpty) {
            // Find closest strikes
            OptionContract? bestCall;
            OptionContract? bestPut;
            double closestCallDistance = double.infinity;
            double closestPutDistance = double.infinity;
            
            for (final call in optionsData.calls) {
              final distance = (call.strike - resistance).abs();
              if (distance < closestCallDistance) {
                closestCallDistance = distance;
                bestCall = call;
              }
            }
            
            for (final put in optionsData.puts) {
              final distance = (put.strike - support).abs();
              if (distance < closestPutDistance) {
                closestPutDistance = distance;
                bestPut = put;
              }
            }
            
            if (bestCall != null && bestPut != null) {
              // Calculate risk/reward for strangle
              final totalPremium = bestCall.premium + bestPut.premium;
              final potentialProfit = (resistance * 1.05 - bestCall.strike)
                  .abs()
                  .max((bestPut.strike - support * 0.95).abs());
              final ratio = totalPremium > 0 ? potentialProfit / totalPremium : 0;
              
              recommendedOptions.add(OptionRecommendation(
                type: 'STRANGLE',
                strike: 0.0, // Not applicable for strangle
                expiry: optionsData.expiry,
                premium: 0.0, // Not applicable for strangle
                callStrike: bestCall.strike,
                putStrike: bestPut.strike,
                callPremium: bestCall.premium,
                putPremium: bestPut.premium,
                totalPremium: totalPremium,
                riskReward: ratio,
                confidence: 'Medium',
              ));
            }
          } else {
            // Generate synthetic strangle recommendation
            final callStrike = resistance;
            final putStrike = support;
            final timeToExpiry = 7 / 365.0; // 1 week
            
            final callPremium = _calculateOptionPremium(
              currentPrice, 
              callStrike, 
              volatility, 
              timeToExpiry, 
              'call'
            );
            
            final putPremium = _calculateOptionPremium(
              currentPrice, 
              putStrike, 
              volatility, 
              timeToExpiry, 
              'put'
            );
            
            final totalPremium = callPremium + putPremium;
            final potentialProfit = (resistance * 1.05 - callStrike)
                .abs()
                .max((putStrike - support * 0.95).abs());
            final ratio = totalPremium > 0 ? potentialProfit / totalPremium : 0;
            
            recommendedOptions.add(OptionRecommendation(
              type: 'STRANGLE',
              strike: 0.0, // Not applicable for strangle
              expiry: _getExpiryDateString(7), // 1 week
              premium: 0.0, // Not applicable for strangle
              callStrike: callStrike,
              putStrike: putStrike,
              callPremium: callPremium,
              putPremium: putPremium,
              totalPremium: totalPremium,
              riskReward: ratio,
              confidence: 'Medium',
            ));
          }
        }
      }
      
      return OptionsAnalysis(
        symbol: stock.symbol,
        date: DateTime.now().toIso8601String().split('T')[0],
        currentPrice: currentPrice,
        volatility: volatility,
        technicalOutlook: technicalOutlook,
        recommendedOptions: recommendedOptions,
      );
    } catch (e) {
      print('Error analyzing options: $e');
      return OptionsAnalysis(
        symbol: stock.symbol,
        date: DateTime.now().toIso8601String().split('T')[0],
        currentPrice: stock.currentPrice,
        volatility: stock.volatility,
        technicalOutlook: technicalOutlook,
        recommendedOptions: [],
      );
    }
  }
  
  /// Generate multiple expiry recommendations
  MultipleExpiryRecommendations generateMultipleExpiryRecommendations(
    Stock stock,
    SupportResistance supportResistance,
    String technicalOutlook,
  ) {
    try {
      final currentPrice = stock.currentPrice;
      final volatility = stock.impliedVolatility > 0 
          ? stock.impliedVolatility 
          : stock.volatility > 0 
              ? stock.volatility 
              : 0.3; // Default if both are zero
      
      // Calculate expiry dates
      final oneWeekExpiry = _getExpiryDateString(7);
      final twoWeekExpiry = _getExpiryDateString(14);
      final monthlyExpiry = _getExpiryDateString(30);
      
      // Calculate expected moves based on volatility
      final oneWeekMove = currentPrice * volatility * (7/365).sqrt();
      final twoWeekMove = currentPrice * volatility * (14/365).sqrt();
      final monthlyMove = currentPrice * volatility * (30/365).sqrt();
      
      // Generate recommendations based on technical outlook
      final oneWeekExpiryRecommendations = <OptionRecommendation>[];
      final twoWeekExpiryRecommendations = <OptionRecommendation>[];
      final monthlyExpiryRecommendations = <OptionRecommendation>[];
      
      if (technicalOutlook.contains('Bullish')) {
        // One week expiry
        final callStrike = (currentPrice * 1.01).roundToDouble(); // Slightly OTM
        final callPremium = _calculateOptionPremium(
          currentPrice, 
          callStrike, 
          volatility, 
          7/365, 
          'call'
        );
        
        oneWeekExpiryRecommendations.add(OptionRecommendation(
          type: 'CALL',
          strike: callStrike,
          expiry: oneWeekExpiry,
          premium: callPremium,
          riskReward: callPremium > 0 ? oneWeekMove / callPremium : 0,
          confidence: technicalOutlook.contains('Strongly') ? 'High' : 'Medium',
        ));
        
        // Two week expiry
        final twoWeekCallStrike = (currentPrice * 1.02).roundToDouble(); // Slightly more OTM
        final twoWeekCallPremium = _calculateOptionPremium(
          currentPrice, 
          twoWeekCallStrike, 
          volatility, 
          14/365, 
          'call'
        );
        
        twoWeekExpiryRecommendations.add(OptionRecommendation(
          type: 'CALL',
          strike: twoWeekCallStrike,
          expiry: twoWeekExpiry,
          premium: twoWeekCallPremium,
          riskReward: twoWeekCallPremium > 0 ? twoWeekMove / twoWeekCallPremium : 0,
          confidence: technicalOutlook.contains('Strongly') ? 'High' : 'Medium',
        ));
        
        // Monthly expiry
        final monthlyCallStrike = (currentPrice * 1.05).roundToDouble(); // More OTM for longer expiry
        final monthlyCallPremium = _calculateOptionPremium(
          currentPrice, 
          monthlyCallStrike, 
          volatility, 
          30/365, 
          'call'
        );
        
        monthlyExpiryRecommendations.add(OptionRecommendation(
          type: 'CALL',
          strike: monthlyCallStrike,
          expiry: monthlyExpiry,
          premium: monthlyCallPremium,
          riskReward: monthlyCallPremium > 0 ? monthlyMove / monthlyCallPremium : 0,
          confidence: technicalOutlook.contains('Strongly') ? 'High' : 'Medium',
        ));
      } else if (technicalOutlook.contains('Bearish')) {
        // One week expiry
        final putStrike = (currentPrice * 0.99).roundToDouble(); // Slightly OTM
        final putPremium = _calculateOptionPremium(
          currentPrice, 
          putStrike, 
          volatility, 
          7/365, 
          'put'
        );
        
        oneWeekExpiryRecommendations.add(OptionRecommendation(
          type: 'PUT',
          strike: putStrike,
          expiry: oneWeekExpiry,
          premium: putPremium,
          riskReward: putPremium > 0 ? oneWeekMove / putPremium : 0,
          confidence: technicalOutlook.contains('Strongly') ? 'High' : 'Medium',
        ));
        
        // Two week expiry
        final twoWeekPutStrike = (currentPrice * 0.98).roundToDouble(); // Slightly more OTM
        final twoWeekPutPremium = _calculateOptionPremium(
          currentPrice, 
          twoWeekPutStrike, 
          volatility, 
          14/365, 
          'put'
        );
        
        twoWeekExpiryRecommendations.add(OptionRecommendation(
          type: 'PUT',
          strike: twoWeekPutStrike,
          expiry: twoWeekExpiry,
          premium: twoWeekPutPremium,
          riskReward: twoWeekPutPremium > 0 ? twoWeekMove / twoWeekPutPremium : 0,
          confidence: technicalOutlook.contains('Strongly') ? 'High' : 'Medium',
        ));
        
        // Monthly expiry
        final monthlyPutStrike = (currentPrice * 0.95).roundToDouble(); // More OTM for longer expiry
        final monthlyPutPremium = _calculateOptionPremium(
          currentPrice, 
          monthlyPutStrike, 
          volatility, 
          30/365, 
          'put'
        );
        
        monthlyExpiryRecommendations.add(OptionRecommendation(
          type: 'PUT',
          strike: monthlyPutStrike,
          expiry: monthlyExpiry,
          premium: monthlyPutPremium,
          riskReward: monthlyPutPremium > 0 ? monthlyMove / monthlyPutPremium : 0,
          confidence: technicalOutlook.contains('Strongly') ? 'High' : 'Medium',
        ));
      } else {
        // Neutral outlook - recommend iron condors or strangles
        // One week expiry
        final callStrike = (currentPrice * 1.02).roundToDouble();
        final putStrike = (currentPrice * 0.98).roundToDouble();
        
        final callPremium = _calculateOptionPremium(
          currentPrice, 
          callStrike, 
          volati
(Content truncated due to size limit. Use line ranges to read in chunks)