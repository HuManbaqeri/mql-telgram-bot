#property copyright "Copyright 2020, BAMBOO Group."
#property version "1.00"
#property strict

input double lotsize1 = 0.00003;

const string allowed_broker = "";
const long allowed_accounts[] = {};

int password_status = -1;

int OnInit()
{
   string broker = AccountInfoString(ACCOUNT_COMPANY);
   long account = AccountInfoInteger(ACCOUNT_LOGIN);

   Print("The name of the broker = %s", broker);
   Print("Account number =  %d", account);

   if (broker == allowed_broker)
      for (int i = 0; i < ArraySize(allowed_accounts); i++)
         if (account == allowed_accounts[i])
         {
            password_status = 1;
            Print("EA account verified");
            break;
         }
   if (password_status == -1)
      Print("EA is not allowed to run on this account.");

   //---
   return (0);
   return (INIT_SUCCEEDED);
}
void OnDeinit(const int reason)
{
   //---
}
void OnTick()
{

   // شرايط ورود به بازار و مديريت پوزيشن

   // if(CLOSE()=="CLOSE BUYS")  close(0901); if(CLOSE()=="CLOSE SELLS")  close(2301);
   double lots1 = (AccountBalance() * 0.00006);

   if (Volume[0] <= 1)
   {
      if (SIGNAL() == "M5BUY")
      {
         int ticketSELL03 = OrderSend(Symbol(), OP_SELL, lots1, Bid, 5, 0, 0, "ARCHER  TEAM", 0901, 0, clrRed);
         close(2301);
      }
      if (SIGNAL() == "M5SELL")
      {
         int ticketBUY03 = OrderSend(Symbol(), OP_BUY, lots1, Ask, 5, 0, 0, "ARCHER  TEAM", 2301, 0, clrBlue);
         close(0901);
      }
      else
         Alert("DONT TRADE");
   }
}
string SIGNAL()
{
   if (iADX(NULL, PERIOD_H4, 8, PRICE_CLOSE, MODE_PLUSDI, 1) < iADX(NULL, PERIOD_H4, 8, PRICE_CLOSE, MODE_MINUSDI, 1) &&
       iADX(NULL, PERIOD_H4, 8, PRICE_CLOSE, MODE_MAIN, 2) > 60 &&
       iADX(NULL, PERIOD_H4, 8, PRICE_CLOSE, MODE_MAIN, 1) < 60)
      return ("M5BUY");
   if (iADX(NULL, PERIOD_H4, 8, PRICE_CLOSE, MODE_PLUSDI, 1) > iADX(NULL, PERIOD_H4, 8, PRICE_CLOSE, MODE_MINUSDI, 1) &&
       iADX(NULL, PERIOD_H4, 8, PRICE_CLOSE, MODE_MAIN, 2) > 60 &&
       iADX(NULL, PERIOD_H4, 8, PRICE_CLOSE, MODE_MAIN, 1) < 60)
      return ("M5SELL");
   else
      return ("NO SIGNAL");
}
string TREND()
{
   if (iMA(NULL, PERIOD_D1, 2, 0, MODE_EMA, PRICE_MEDIAN, 1) > iMA(NULL, PERIOD_D1, 15, 0, MODE_EMA, PRICE_HIGH, 1))
      return ("M5BULLISH");
   if (iMA(NULL, PERIOD_D1, 2, 0, MODE_EMA, PRICE_MEDIAN, 1) < iMA(NULL, PERIOD_D1, 15, 0, MODE_EMA, PRICE_LOW, 1))
      return ("M5BEARISH");
   else
      return ("NO TREND");
}
string FILTERRANGE()
{
   if (iADX(NULL, PERIOD_H4, 8, PRICE_CLOSE, MODE_PLUSDI, 1) < 30 && iADX(NULL, PERIOD_H4, 8, PRICE_CLOSE, MODE_MINUSDI, 1) < 30 &&
       iADX(NULL, PERIOD_H4, 8, PRICE_CLOSE, MODE_MAIN, 1) < 30)
      return ("DONT TRADE");
   else
      return ("TRADE");
}
string CLOSE()
{
   if (iMA(NULL, PERIOD_D1, 2, 0, MODE_EMA, PRICE_MEDIAN, 2) >= iMA(NULL, PERIOD_D1, 15, 0, MODE_EMA, PRICE_HIGH, 2) &&
       iMA(NULL, PERIOD_D1, 2, 0, MODE_EMA, PRICE_MEDIAN, 1) < iMA(NULL, PERIOD_D1, 15, 0, MODE_EMA, PRICE_HIGH, 1))
      return ("CLOSE BUYS");
   if (iMA(NULL, PERIOD_D1, 2, 0, MODE_EMA, PRICE_MEDIAN, 2) <= iMA(NULL, PERIOD_D1, 15, 0, MODE_EMA, PRICE_LOW, 2) &&
       iMA(NULL, PERIOD_D1, 2, 0, MODE_EMA, PRICE_MEDIAN, 1) > iMA(NULL, PERIOD_D1, 15, 0, MODE_EMA, PRICE_LOW, 1))
      return ("CLOSE SELLS");
   else
      return ("NOTING");
}
int Orders()
{
   int num = 0;
   for (int i = OrdersTotal() - 1; i >= 0; i--)
   {
      if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
      {
         if (OrderMagicNumber() == 2301 || OrderMagicNumber() == 0901)
            num++;
      }
   }
   return (num);
}
void close(int Magic)
{
   for (int i = OrdersTotal() - 1; i >= 0; i--)
   {
      if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
      {
         if (OrderMagicNumber() == Magic)
            bool yccb = OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), 5, clrGreen);
      }
   }
}
bool hourfilter()
{
   if (Hour() > 6 && Hour() < 22)
      return (true);
   else
      return (false);
}
//+------------------------------------------------------------------+
//| Tester function                                                  |
//+------------------------------------------------------------------+
double OnTester()
{
   //---
   double ret = 0.0;
   //---

   //---
   return (ret);
}
//+------------------------------------------------------------------+
void Trail()
{
   for (int i = OrdersTotal() - 1; i >= 0; i--)
   {
      if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
      {
         if ((Bid - OrderOpenPrice()) > 600 * Point)
         {
            if (OrderStopLoss() < (Bid - 600 * Point))
            {
               bool ordermb = OrderModify(OrderTicket(), OrderOpenPrice(), Bid - 600 * Point, OrderTakeProfit(), 0, clrYellow);
               Sleep(200);
            }
         }

         if ((OrderOpenPrice() - Ask) > 600 * Point)
         {
            if (OrderStopLoss() > (Ask + 600 * Point))
            {
               bool orderms = OrderModify(OrderTicket(), OrderOpenPrice(), Ask + 600 * Point, OrderTakeProfit(), 0, clrYellow);
               Sleep(200);
            }
         }
      }
   }
}