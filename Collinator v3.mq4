//+------------------------------------------------------------------+
//|                                                Collinator v3.mq4 |
//|                                          Copyright 2023,JBlanked |
//|                                         https://www.jblanked.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023,JBlanked"
#property link      "https://www.jblanked.com"
#property strict
#property description "NY bell strategy"

#include <CustomFunctionsFix.mqh>

input    string         orderSettings     = "======= TRADE SETTINGS ======";   //--------------------------->
input    bool           reverseOrder      = false;// Reverse setup? (Sell + buy limit)
input    bool           useTrend          = false; // Trade off of 8:30am candle?
input    bool           usematrend        = false; // Trade off Moving average?

input    string         orderSeting       = "======= MOVING AVERAGE SETTINGS ======";  //--------------------------->
input    bool           useMA             = false; // Above MA buys, Below Ma sells?
input    bool           useMAs            = false; // Above MA sells, Below Ma buys?
input    int            maperiod          = 160; // MA period

input    string         orderSeng         = "======= ORDER SETTINGS ======";  //--------------------------->
input    double         stoploss          = 80; // Stop Loss
input    double         takeprofit        = 500; // Take Profit
input    bool           usepercentrisk    = true; // Use risk per trade?
input    double         percentrisk       = 0.50; // Percent risk
input    bool           uselotsize        = false; // Use lot size?
input    double         lotsizee          = 0.10; // Lot size

input    string         orderSetting      = "======= SELL LIMIT SETTINGS ======";   //--------------------------->
input    bool           allowSells        = true; // Allow sells?
input    double         entrySells        = 140; // Sell at X pips from buy order
input    double         stoplossSells     = 35; // Stop Loss
input    double         takeprofitSells   = 500; // Take Profit
input    bool           usepercentrisk2   = true; // Use risk per trade?
input    double         percentrisk2      = 0.50; // Percent risk
input    bool           uselotsize2       = false; // Use lot size?
input    double         lotsizee2         = 0.10; // Lot size
input    int            martinTimer       = 20; // Sell limit expiry


input    string         BreakEvenSettings = "--------TAKE PARTIAL SETTINGS-------";  //--------------------------->
input    bool           UseBreakEvenStop  = true;  //Use take partials?
input    double         BEclosePercent    = 50.0;   //Close how much percent?
input    double         breakstart        = 100; // Take partials after how many pips in profit (1)
input    double         breakstart2       = 250; // Take partials after how many pips in profit (2)
input    double         breakstart3       = 350; // Take partials after how many pips in profit (3)
input    double         breakstart4       = 450; // Take partials after how many pips in profit (4)

input    double         breakstop         = 20; // Move stop loss in profit X pips  

input    string         BkEvnSettings     = "======= MARTINGALE SETTINGS =======";  //--------------------------->
input    bool           useMartingale     = false; // Use martingale?
input    double         martinPips        = 78; // Pips in between martingales
input    double         martinMULTI       = 5; // Martingale multiplier


string         timeSettings      = "======= TIME SETTINGS ======";  //--------------------
bool           UseTimer          = true;    // Custom trading hours (true/false)
string         StartTime1        = "16:30";  //1 Trading start time (hh:mm)
string         StopTime1         = "16:30";  //1 Trading stop time (hh:mm)


input    string         orderSettins      = "======= OTHER SETTINGS ======";    //---------------
input    string         orderComments     = "v3"; // Order Comment
input    int            magicnumb         = 810929; // Magic Number



string masterComment = "Collinator ";
string orderComment = masterComment + orderComments;
int magicnumber1 = magicnumb + 1;


int orderID;
int orderID2;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---

JBlankedInitVIP(magicnumb,810929,"Collinator v3");


JBlankedBranding("Collinator v3",magicnumb,string(expiryDateVIP));
   
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
JBlankedDeinit();

   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---

if(useMartingale) { martingale(_Symbol,magicnumb,OrderStopLoss(),martinMULTI,martinPips); }
if(useMartingale) { martingale(_Symbol,magicnumber1,OrderStopLoss(),martinMULTI,martinPips); }

//////////////////// Start Take Partials Tempalte

if(UseBreakEvenStop)DoBreak2(magicnumb,breakstart,BEclosePercent,breakstop,breakstart2,breakstart3,breakstart4);
if(UseBreakEvenStop)DoBreak2(magicnumber1,breakstart,BEclosePercent,breakstop,breakstart2,breakstart3,breakstart4);


//////////////////// End Take Partials Tempalte




double stoplossprice = NormalizeDouble(MarketInfo(_Symbol,MODE_ASK) - stoploss * GetPipValue(),Digits);
double takeprofitprice = NormalizeDouble(MarketInfo(_Symbol,MODE_ASK) + takeprofit * GetPipValue(),Digits);
double entryprice = MarketInfo(_Symbol,MODE_ASK);

double entrypriceSells = NormalizeDouble(MarketInfo(_Symbol,MODE_BID) + entrySells * GetPipValue(),Digits);

double stoplossprice2 = NormalizeDouble(entrypriceSells + stoplossSells * GetPipValue(),Digits);
double takeprofitprice2 = NormalizeDouble(entrypriceSells - takeprofitSells * GetPipValue(),Digits);





double stoplosspricea = NormalizeDouble(MarketInfo(_Symbol,MODE_BID) + stoploss * GetPipValue(),Digits);
double takeprofitpricea = NormalizeDouble(MarketInfo(_Symbol,MODE_BID) - takeprofit * GetPipValue(),Digits);
double entrypricea = MarketInfo(_Symbol,MODE_BID);

double entrypriceSellsa = NormalizeDouble(MarketInfo(_Symbol,MODE_ASK) - entrySells * GetPipValue(),Digits);

double stoplossprice2a = NormalizeDouble(entrypriceSells - stoplossSells * GetPipValue(),Digits);
double takeprofitprice2a = NormalizeDouble(entrypriceSells + takeprofitSells * GetPipValue(),Digits);


double eight30NewsCandleStart = iOpen(_Symbol,30,2);
double eight30NewsCandleStop = iClose(_Symbol,30,2);

double currentMA = iMA(_Symbol,0,maperiod,0,MODE_SMA,PRICE_CLOSE,0);



if((useTrend && eight30NewsCandleStart < eight30NewsCandleStop) || !useTrend)
{

if(((usematrend) && (useMA && !useMAs && Ask > maperiod)) || !usematrend)
{
if(!reverseOrder)
{
if(!CheckIfOpenOrdersByMagicNB(magicnumb,orderComment) && allowTime(UseTimer,StartTime1,StopTime1))
{
orderID = OrderSend(_Symbol,OP_BUY,GetRisk(usepercentrisk,uselotsize,percentrisk,stoploss,lotsizee),entryprice,10,stoplossprice,takeprofitprice,orderComment,magicnumb);  
}
   
   
 
if(!CheckIfOpenOrdersByMagicNB(magicnumber1,orderComment) && (allowSells == true)  && allowTime(UseTimer,StartTime1,StopTime1))
{
orderID2 = OrderSend(_Symbol,OP_SELLLIMIT,GetRisk(usepercentrisk2,uselotsize2,percentrisk2,stoplossSells,lotsizee2),entrypriceSells,10,stoplossprice2,takeprofitprice2,orderComment,magicnumber1,int(TimeCurrent()+ martinTimer * 60)); 
}
}  


if(reverseOrder)
{
if(!CheckIfOpenOrdersByMagicNB(magicnumb,orderComment) && allowTime(UseTimer,StartTime1,StopTime1))
{
orderID = OrderSend(_Symbol,OP_SELL,GetRisk(usepercentrisk,uselotsize,percentrisk,stoploss,lotsizee),entrypricea,10,stoplosspricea,takeprofitpricea,orderComment,magicnumb);  
}
   
    
if(!CheckIfOpenOrdersByMagicNB(magicnumber1,orderComment) && (allowSells == true)  && allowTime(UseTimer,StartTime1,StopTime1))
{
orderID2 = OrderSend(_Symbol,OP_BUYLIMIT,GetRisk(usepercentrisk2,uselotsize2,percentrisk2,stoplossSells,lotsizee2),entrypriceSellsa,10,stoplossprice2a,takeprofitprice2a,orderComment,magicnumber1,int(TimeCurrent()+ martinTimer * 60));   
}
}   
} 
}








if((useTrend && eight30NewsCandleStart > eight30NewsCandleStop) || !useTrend)
{
if(((usematrend) && (useMAs && !useMA && Ask > maperiod)) || !usematrend)
{

if(reverseOrder)
{
if(!CheckIfOpenOrdersByMagicNB(magicnumb,orderComment) && allowTime(UseTimer,StartTime1,StopTime1))
{
orderID = OrderSend(_Symbol,OP_BUY,GetRisk(usepercentrisk,uselotsize,percentrisk,stoploss,lotsizee),entryprice,10,stoplossprice,takeprofitprice,orderComment,magicnumb);  
}
   
   
 
if(!CheckIfOpenOrdersByMagicNB(magicnumber1,orderComment) && (allowSells == true)  && allowTime(UseTimer,StartTime1,StopTime1))
{
orderID2 = OrderSend(_Symbol,OP_SELLLIMIT,GetRisk(usepercentrisk2,uselotsize2,percentrisk2,stoplossSells,lotsizee2),entrypriceSells,10,stoplossprice2,takeprofitprice2,orderComment,magicnumber1,int(TimeCurrent()+ martinTimer * 60)); 
}
}  


if(!reverseOrder)
{
if(!CheckIfOpenOrdersByMagicNB(magicnumb,orderComment) && allowTime(UseTimer,StartTime1,StopTime1))
{
orderID = OrderSend(_Symbol,OP_SELL,GetRisk(usepercentrisk,uselotsize,percentrisk,stoploss,lotsizee),entrypricea,10,stoplosspricea,takeprofitpricea,orderComment,magicnumb);  
}
   
    
if(!CheckIfOpenOrdersByMagicNB(magicnumber1,orderComment) && (allowSells == true)  && allowTime(UseTimer,StartTime1,StopTime1))
{
orderID2 = OrderSend(_Symbol,OP_BUYLIMIT,GetRisk(usepercentrisk2,uselotsize2,percentrisk2,stoplossSells,lotsizee2),entrypriceSellsa,10,stoplossprice2a,takeprofitprice2a,orderComment,magicnumber1,int(TimeCurrent()+ martinTimer * 60));   
}
}   
} 
}





  
}  
//+------------------------------------------------------------------+


