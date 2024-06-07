//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2018, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property show_inputs
#include <CustomFunction01.mqh>

int magicNB = 55555;
input double riskPerTrade = 0.02;
int openOrderID;

input int bbPeriod = 50;
input int bandStdEntry = 2;
input int bandStdProfitExit = 1;
input int bandStdLossExit = 6;

int rsiPeriod = 14;
input int rsiLowerLevel = 40;
input int rsiUpperLevel = 60;


int OnInit()
  {
   Alert("");
   Alert("Starting Strategy BB 2Bans MR.");
   return(INIT_SUCCEEDED);
  }

void OnDeinit(const int reason)
  {
   Alert("Stopping Strategy BB 2Bans MR.");
  }

void OnTick()
  {
   Alert("");
   
   //Bands vao lenh
   double bbLowerEntry = iBands(NULL,0,bbPeriod,bandStdEntry,0,PRICE_CLOSE,MODE_LOWER,0);
   double bbUpperEntry = iBands(NULL,0,bbPeriod,bandStdEntry,0,PRICE_CLOSE,MODE_UPPER,0);
   double bbMid = iBands(NULL,0,bbPeriod,bandStdEntry,0,PRICE_CLOSE,0,0);
   
   //Bands thoat lenh
   double bbLowerProfitExit = iBands(NULL,0,bbPeriod,bandStdProfitExit,0,PRICE_CLOSE,MODE_LOWER,0);
   double bbUpperProfitExit = iBands(NULL,0,bbPeriod,bandStdProfitExit,0,PRICE_CLOSE,MODE_UPPER,0);
   
   //Bands dung lo
   double bbLowerLossExit = iBands(NULL,0,bbPeriod,bandStdLossExit,0,PRICE_CLOSE,MODE_LOWER,0);
   double bbUpperLossExit = iBands(NULL,0,bbPeriod,bandStdLossExit,0,PRICE_CLOSE,MODE_UPPER,0);
   
   //Indi RSI giai doan 14
   double rsiValue = iRSI(NULL,0,rsiPeriod,PRICE_CLOSE,0);

   if(!CheckIfOpenOrdersByMagicNB(magicNB)) //if no open orders, try to enter new position
     {
     // Gia vao lenh phai nho hon bbEntry va gia mo cua phai lon hon bbEntry va rsi hien tai phai nho hon 40
      if(Ask < bbLowerEntry && Open[0] > bbLowerEntry && rsiValue < rsiLowerLevel) //buying
        {
         Alert("Price is bellow bbLower and rsiValue is lower than " + rsiLowerLevel+ ", Sending buy order");
         double stopLossPrice = NormalizeDouble(bbLowerLossExit,Digits);
         double takeProfitPrice =NormalizeDouble(bbUpperProfitExit,Digits);
         Alert("Entry Price = " + Ask);
         Alert("Stop Loss Price = " + stopLossPrice);
         Alert("Take Profit Price = " + takeProfitPrice);

         double lotSize = OptimalLotSize(riskPerTrade,Ask,stopLossPrice);

         openOrderID = OrderSend(NULL,OP_BUYLIMIT,lotSize,Ask,10,stopLossPrice,takeProfitPrice,NULL,magicNB);
         if(openOrderID < 0) Alert("Oder rejected. Order error: " + GetLastError());
        }
      else if(Bid > bbUpperEntry && Open[0] < bbUpperEntry && rsiValue > rsiUpperLevel) //shorting
           {
            Alert("Price is above bbUpper and rsiValue is above " + rsiUpperLevel + " Sending short order");
            double stopLossPrice =NormalizeDouble(bbUpperLossExit,Digits);
            double takeProfitPrice = NormalizeDouble(bbUpperProfitExit,Digits);
            Alert("Entry Price = " + Bid);
            Alert("Stop Loss Price = " + stopLossPrice);
            Alert("Take Profit Price = " + takeProfitPrice);

            double lotSize = OptimalLotSize(riskPerTrade,Bid,stopLossPrice);

            openOrderID = OrderSend(NULL,OP_SELLLIMIT,lotSize,Bid,10,stopLossPrice,takeProfitPrice,NULL,magicNB);
            if(openOrderID < 0) Alert("Oder rejected. Order error: " + GetLastError());
           }
     }
   else //else if you already have a position, update orders if need too.
     {

      if(OrderSelect(openOrderID,SELECT_BY_TICKET) == true) // print de kiem tra
        {
            int orderType = OrderType(); // 0 = Long, 1 = Short
            
            double optimalTakeProfit;
            
            if(orderType == 0) //long position
            {
               optimalTakeProfit = NormalizeDouble(bbUpperProfitExit,Digits);
            }
            else //if short
            {
               optimalTakeProfit = NormalizeDouble(bbLowerProfitExit, Digits);
            }
            
            double TP = OrderTakeProfit();
            double TPdistance = MathAbs(TP - optimalTakeProfit);
            if(TP != optimalTakeProfit && TPdistance > 0.0001)
            {
      
               bool Ans = OrderModify(openOrderID,OrderOpenPrice(), OrderStopLoss(),optimalTakeProfit,0);
               
               if(Ans == true)
                 {
                     Print("Order modified : ",openOrderID);
                     return;
                 }else
                 {
                     Print("Unable to modify order: ",openOrderID);
                 }
            }
   
        }
     }
  }
//+------------------------------------------------------------------+
