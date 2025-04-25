                "error": str(e)
            }

    def calculate_option_premium(self, spot, strike, volatility, time_to_expiry, option_type):
        """Calculate option premium using Black-Scholes approximation"""
        try:
            # Simple approximation for educational purposes
            # In a real application, use a proper Black-Scholes implementation
            intrinsic = max(0, spot - strike) if option_type == "call" else max(0, strike - spot)
            time_value = spot * volatility * (time_to_expiry ** 0.5)
            premium = intrinsic + time_value
            
            # Adjust based on moneyness
            moneyness = spot / strike
            if option_type == "call":
                if moneyness < 0.95:  # Deep OTM
                    premium *= 0.5
                elif moneyness > 1.05:  # Deep ITM
                    premium *= 0.8
            else:  # Put
                if moneyness > 1.05:  # Deep OTM
                    premium *= 0.5
                elif moneyness < 0.95:  # Deep ITM
                    premium *= 0.8
            
            return premium
        except Exception as e:
            logger.error(f"Error calculating option premium: {str(e)}")
            return 0

class ReportGenerator:
    """Class to generate reports"""

    def __init__(self):
        """Initialize the ReportGenerator"""
        logger.info("ReportGenerator initialized")

    def generate_charts(self, symbol, data, charts_dir):
        """Generate charts for a symbol"""
        # Ensure chart directory exists
        os.makedirs(charts_dir, exist_ok=True)
        
        try:
            # Get price data
            dates = data.get("dates", [])
            close_prices = data.get("close", [])
            
            if not dates or not close_prices or len(dates) != len(close_prices):
                logger.warning(f"Insufficient data for {symbol} charts")
                # Create placeholder charts with error message
                plt.figure(figsize=(10, 6))
                plt.text(0.5, 0.5, f"Insufficient data for {symbol} charts", 
                        horizontalalignment='center', verticalalignment='center')
                plt.savefig(os.path.join(charts_dir, f"{symbol}_price_chart.png"))
                plt.close()
                
                plt.figure(figsize=(10, 6))
                plt.text(0.5, 0.5, f"Insufficient data for {symbol} support/resistance chart", 
                        horizontalalignment='center', verticalalignment='center')
                plt.savefig(os.path.join(charts_dir, f"{symbol}_support_resistance.png"))
                plt.close()
                return
            
            # Convert dates to datetime objects if they're strings
            if isinstance(dates[0], str):
                dates = [datetime.strptime(date, "%Y-%m-%d") for date in dates]
            
            # Create DataFrame
            hist = pd.DataFrame({"Close": close_prices}, index=dates)
            
            # Get support and resistance levels
            support_resistance = data.get("support_resistance", {})
            
            # Generate price chart
            plt.figure(figsize=(10, 6))
            plt.plot(hist.index, hist["Close"])
            plt.title(f"{symbol} Price Chart")
            plt.xlabel("Date")
            plt.ylabel("Price")
            plt.grid(True)
            plt.savefig(os.path.join(charts_dir, f"{symbol}_price_chart.png"))
            plt.close()
            
            # Generate support and resistance chart
            if "support_levels" in support_resistance and "resistance_levels" in support_resistance:
                plt.figure(figsize=(10, 6))
                plt.plot(hist.index, hist["Close"])
                
                # Add support levels
                for level in support_resistance["support_levels"]:
                    plt.axhline(y=level, color='g', linestyle='-', alpha=0.5)
                    plt.text(hist.index[-1], level, f"S: {level:.2f}", verticalalignment='center')
                
                # Add resistance levels
                for level in support_resistance["resistance_levels"]:
                    plt.axhline(y=level, color='r', linestyle='-', alpha=0.5)
                    plt.text(hist.index[-1], level, f"R: {level:.2f}", verticalalignment='center')
                
                plt.title(f"{symbol} Support and Resistance")
                plt.xlabel("Date")