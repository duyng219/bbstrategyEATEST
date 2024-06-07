//+------------------------------------------------------------------+
//|                                             CustomFunction01.mqh |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property strict
//+------------------------------------------------------------------+
//| defines                                                          |
//+------------------------------------------------------------------+
// #define MacrosHello   "Hello, world!"
// #define MacrosYear    2010
//+------------------------------------------------------------------+
//| DLL imports                                                      |
//+------------------------------------------------------------------+
// #import "user32.dll"
//   int      SendMessageA(int hWnd,int Msg,int wParam,int lParam);
// #import "my_expert.dll"
//   int      ExpertRecalculate(int wParam,int lParam);
// #import
//+------------------------------------------------------------------+
//| EX5 imports                                                      |
//+------------------------------------------------------------------+
// #import "stdlib.ex5"
//   string ErrorDescription(int error_code);
// #import
//+------------------------------------------------------------------+

void PrintOutAccountInfo(){
	double accBalance = AccountBalance();
	Alert("");
	Alert("Your Account Balance is: $" + accBalance);
	Alert("Your stop loss percentage is: 2%");
	Alert("Your max loss in dollar value: $" + (0.02 * accBalance));
}

double GetPipValueFromDigits()
{
   if(_Digits >= 4)
   {
      return 0.0001;
   } else
   {
      return 0.01;
   }
}

double CalculateTakeProfit(bool isLong, double entryPrice, int pips)
  {
	  double takeProfit;
	  if(isLong)
	  {
		  takeProfit = entryPrice + pips * GetPipValue();
	  } else
	  {
		  takeProfit = entryPrice - pips * GetPipValue();
	  }
	  return takeProfit;
  }
  
  double CalculateStopLoss(bool isLong, double entryPrice, int pips)
  {
	  double stopLoss;
	  if(isLong)
	  {
		  stopLoss = entryPrice - pips * GetPipValue();
	  } else
	  {
		  stopLoss = entryPrice + pips * GetPipValue();
	  }
	  return stopLoss;
  }
  
  double GetPipValue()
{
   if(_Digits >= 4)
   {
      return 0.0001;
   } else
   {
      return 0.01;
   }
}

bool IsTradingAllowed()
{
   if(!IsTradeAllowed())
   {
      Alert("Expert Advisor is NOT Allowed to Trade. Check AutoTrading");
      return false;
   }
   
   if(!IsTradeAllowed(Symbol(), TimeCurrent()))
   {
      Alert("Trading NOT Allowed for specific Symbol and Time");
      return false;
   }
   
   return true;
}

double OptimalLotSize(double maxRiskPrc, int maxLossInPips)
  {

//Tính dừng lổ bằng $
   double accEquity = AccountEquity();
   Alert("accEquity: " + accEquity);

   double lotSize = MarketInfo(NULL,MODE_LOTSIZE);
   Alert("lotSize: " + lotSize);

   double tickValue = MarketInfo(NULL,MODE_TICKVALUE);
   if(Digits <= 3)
   {
      tickValue = tickValue / 100;
   }
   Alert("tickValue: " + tickValue);

   double maxLossDollar = accEquity * maxRiskPrc;
   Alert("maxLossDollar: " + maxLossDollar);

   double maxLossInQuoteCurr = maxLossDollar / tickValue;
   Alert("maxLossInQuoteCurr: " + maxLossInQuoteCurr);

//Tính khối lượng vị thế
   double optimalLotsize = NormalizeDouble(maxLossInQuoteCurr / (maxLossInPips * GetPipValue()) / lotSize,2);
   Alert("optimalLotsize: " + optimalLotsize);
    
    return optimalLotsize;
  }
  
  double OptimalLotSize(double maxRiskPrc, double entryPrice, double stopLoss)
  {
   int maxLossInPips = MathAbs(entryPrice - stopLoss)/GetPipValue();
   return OptimalLotSize(maxRiskPrc,maxLossInPips);
  }
  
bool CheckIfOpenOrdersByMagicNB(int magicNB)
{
   int orderTotal = OrdersTotal();
   
   for(int i = 0; i < orderTotal; i++)
   {
      if(OrderSelect(i,SELECT_BY_POS) == true)
      {
         if(OrderMagicNumber() == magicNB)
         {
            return true;
         } 
      }
   }
   return false;
}
