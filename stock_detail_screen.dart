import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:stock_options_analyzer/data/models/stock.dart';
import 'package:stock_options_analyzer/data/models/technical_analysis.dart';
import 'package:stock_options_analyzer/data/models/support_resistance.dart';
import 'package:stock_options_analyzer/data/models/options.dart';
import 'package:stock_options_analyzer/data/services/yahoo_finance_service.dart';
import 'package:stock_options_analyzer/domain/services/technical_analysis_service.dart';
import 'package:stock_options_analyzer/domain/services/support_resistance_service.dart';
import 'package:stock_options_analyzer/domain/services/options_analysis_service.dart';
import 'package:stock_options_analyzer/presentation/widgets/price_chart.dart';
import 'package:stock_options_analyzer/presentation/widgets/support_resistance_chart.dart';
import 'package:stock_options_analyzer/presentation/widgets/technical_indicators_card.dart';
import 'package:stock_options_analyzer/presentation/widgets/options_recommendation_card.dart';

class StockDetailScreen extends StatefulWidget {
  final String symbol;
  
  const StockDetailScreen({super.key, required this.symbol});
  
  @override
  State<StockDetailScreen> createState() => _StockDetailScreenState();
}

class _StockDetailScreenState extends State<StockDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  bool _isLoading = true;
  String _errorMessage = '';
  
  Stock? _stock;
  TechnicalAnalysis? _technicalAnalysis;
  SupportResistance? _supportResistance;
  OptionsAnalysis? _optionsAnalysis;
  MultipleExpiryRecommendations? _multipleExpiryRecommendations;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadStockData();
  }
  
  Future<void> _loadStockData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    
    try {
      // Get services from dependency injection
      final yahooFinanceService = GetIt.instance<YahooFinanceService>();
      final technicalAnalysisService = GetIt.instance<TechnicalAnalysisService>();
      final supportResistanceService = GetIt.instance<SupportResistanceService>();
      final optionsAnalysisService = GetIt.instance<OptionsAnalysisService>();
      
      // Fetch stock data
      final stock = await yahooFinanceService.getStockData(widget.symbol);
      
      // Analyze technical indicators
      final technicalAnalysis = technicalAnalysisService.analyzeTechnicalIndicators(stock);
      
      // Analyze support and resistance levels
      final supportResistance = supportResistanceService.analyzeSupportResistance(stock);
      
      // Analyze options
      final optionsAnalysis = optionsAnalysisService.analyzeOptions(
        stock, 
        supportResistance, 
        technicalAnalysis.technicalOutlook
      );
      
      // Generate multiple expiry recommendations
      final multipleExpiryRecommendations = optionsAnalysisService.generateMultipleExpiryRecommendations(
        stock, 
        supportResistance, 
        technicalAnalysis.technicalOutlook
      );
      
      // Update state with results
      setState(() {
        _stock = stock;
        _technicalAnalysis = technicalAnalysis;
        _supportResistance = supportResistance;
        _optionsAnalysis = optionsAnalysis;
        _multipleExpiryRecommendations = multipleExpiryRecommendations;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading data: $e';
        _isLoading = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.symbol),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadStockData,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Technical'),
            Tab(text: 'Support/Resistance'),
            Tab(text: 'Options'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage))
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildOverviewTab(),
                    _buildTechnicalTab(),
                    _buildSupportResistanceTab(),
                    _buildOptionsTab(),
                  ],
                ),
    );
  }
  
  Widget _buildOverviewTab() {
    if (_stock == null) {
      return const Center(child: Text('No data available'));
    }
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _stock!.name,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\$${_stock!.currentPrice.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow('Sector', _stock!.sector),
                  _buildInfoRow('Industry', _stock!.industry),
                  _buildInfoRow('Market Cap', '\$${(_stock!.marketCap / 1000000000).toStringAsFixed(2)}B'),
                  _buildInfoRow('P/E Ratio', _stock!.peRatio.toStringAsFixed(2)),
                  _buildInfoRow('EPS', '\$${_stock!.eps.toStringAsFixed(2)}'),
                  _buildInfoRow('Dividend Yield', '${(_stock!.dividendYield * 100).toStringAsFixed(2)}%'),
                  _buildInfoRow('52-Week High', '\$${_stock!.weekHigh52.toStringAsFixed(2)}'),
                  _buildInfoRow('52-Week Low', '\$${_stock!.weekLow52.toStringAsFixed(2)}'),
                  _buildInfoRow('Volume', _stock!.volume.toInt().toString()),
                  _buildInfoRow('Avg Volume', _stock!.avgVolume.toInt().toString()),
                  _buildInfoRow('Volatility', '${(_stock!.volatility * 100).toStringAsFixed(2)}%'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (_technicalAnalysis != null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Technical Outlook',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _technicalAnalysis!.technicalOutlook,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _getTechnicalOutlookColor(_technicalAnalysis!.technicalOutlook),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 16),
          if (_stock != null && _stock!.closePrices.isNotEmpty)
            SizedBox(
              height: 300,
              child: PriceChart(
                prices: _stock!.closePrices,
                dates: _stock!.dates,
                symbol: _stock!.symbol,
              ),
            ),
        ],
      ),
    );
  }
  
  Widget _buildTechnicalTab() {
    if (_technicalAnalysis == null) {
      return const Center(child: Text('No technical analysis data available'));
    }
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TechnicalIndicatorsCard(technicalAnalysis: _technicalAnalysis!),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Moving Averages',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  _buildIndicatorRow(
                    'SMA 50',
                    '\$${_technicalAnalysis!.sma50.toStringAsFixed(2)}',
                    _technicalAnalysis!.sma50 > _technicalAnalysis!.currentPrice ? Colors.red : Colors.green,
                  ),
                  _buildIndicatorRow(
                    'SMA 200',
                    '\$${_technicalAnalysis!.sma200.toStringAsFixed(2)}',
                    _technicalAnalysis!.sma200 > _technicalAnalysis!.currentPrice ? Colors.red : Colors.green,
                  ),
                  _buildIndicatorRow(
                    'Price vs SMA 50',
                    _technicalAnalysis!.currentPrice > _technicalAnalysis!.sma50 ? 'Above' : 'Below',
                    _technicalAnalysis!.currentPrice > _technicalAnalysis!.sma50 ? Colors.green : Colors.red,
                  ),
                  _buildIndicatorRow(
                    'Price vs SMA 200',
                    _technicalAnalysis!.currentPrice > _technicalAnalysis!.sma200 ? 'Above' : 'Below',
                    _technicalAnalysis!.currentPrice > _technicalAnalysis!.sma200 ? Colors.green : Colors.red,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Momentum Indicators',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  _buildIndicatorRow(
                    'RSI (14)',
                    _technicalAnalysis!.rsi.toStringAsFixed(2),
                    _getRsiColor(_technicalAnalysis!.rsi),
                  ),
                  _buildIndicatorRow(
                    'MACD',
                    _technicalAnalysis!.macd.toStringAsFixed(2),
                    _technicalAnalysis!.macd > _technicalAnalysis!.macdSignal ? Colors.green : Colors.red,
                  ),
                  _buildIndicatorRow(
                    'MACD Signal',
                    _technicalAnalysis!.macdSignal.toStringAsFixed(2),
                    Colors.blue,
                  ),
                  _buildIndicatorRow(
                    'MACD Histogram',
                    _technicalAnalysis!.macdHistogram.toStringAsFixed(2),
                    _technicalAnalysis!.macdHistogram > 0 ? Colors.green : Colors.red,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSupportResistanceTab() {
    if (_supportResistance == null) {
      return const Center(child: Text('No support/resistance data available'));
    }
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_stock != null && _stock!.closePrices.isNotEmpty)
            SizedBox(
              height: 300,
              child: SupportResistanceChart(
                prices: _stock!.closePrices,
                dates: _stock!.dates,
                supportLevels: _supportResistance!.supportLevels,
                resistanceLevels: _supportResistance!.resistanceLevels,
                currentPrice: _supportResistance!.currentPrice,
                symbol: _stock!.symbol,
              ),
            ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Resistance Levels',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  ..._supportResistance!.resistanceLevels.map((level) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('R${_supportResistance!.resistanceLevels.indexOf(level) + 1}'),
                        Text(
                          '\$${level.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  )).toList(),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Support Levels',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  ..._supportResistance!.supportLevels.map((level) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('S${_supportResistance!.supportLevels.indexOf(level) + 1}'),
                        Text(
                          '\$${level.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  )).toList(),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Day Trader Recommendation',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  _buildSignalIndicator(_supportResistance!.dayTraderRecommendation.signal),
                  const SizedBox(height: 16),
                  _buildInfoRow('Signal', _supportResistance!.dayTraderRecommendation.signal),
                  _buildInfoRow('Confidence', _supportResistance!.dayTraderRecommendation.confidence),
                  _buildInfoRow('Entry', '\$${_supportResistance!.dayTraderRecommendation.entry.toStringAsFixed(2)}'),
                  _buildInfoRow('Stop Loss', '\$${_supportResistance!.dayTraderRecommendation.stopLoss.toStringAsFixed(2)}'),

(Content truncated due to size limit. Use line ranges to read in chunks)