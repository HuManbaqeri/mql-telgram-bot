#property copyright "Copyright 2022, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#include "..\\Include\\Telegram.mqh"
#include "..\\Include\\TradeObserverV2.mqh"
#include "..\\Libraries\\baqerri_bot_Libb.mq4"

CTradeObserverV2 *Observer;
static bool onTrade;

class CMyBot: public CCustomBot
  {
public:
   void              ProcessMessages(void)
     {
      for(int i=0; i<m_chats.Total(); i++)
        {
         CCustomChat *chat=m_chats.GetNodeAtIndex(i);
         //--- if the message is not processed
         if(!chat.m_new_one.done)
           {
            chat.m_new_one.done=true;
            string text=chat.m_new_one.message_text;
            if(chat.m_id == StringToInteger("-667374489"))
              {
               if(keyWord(text)== " Buy_")
                 {
                  Sleep(500);
                  if(open_buy("XAUUSD",2301))
                    {
                     sendSignal();
                     SendSignalScreenShot(chat.m_id, NULL, PERIOD_H1, 800, 600, TRUE,InpToken);
                     ObjectsDeleteAll();
                    }
                 }
               if(keyWord(text)== " Sell_")
                 {
                  Sleep(500);
                  if(open_sell("XAUUSD",0901))
                    {
                     sendSignal();
                     SendSignalScreenShot(chat.m_id, NULL, PERIOD_H1, 800, 600, TRUE,InpToken);
                     ObjectsDeleteAll();
                    }
                 }
               if(keyWord(text)== " Buy_80")
                 {
                  Sleep(500);
                  if(open_buy_80("XAUUSD",2302))
                    {
                     sendSignal();
                     SendSignalScreenShot(chat.m_id, NULL, PERIOD_H1, 800, 600, TRUE,InpToken);
                     ObjectsDeleteAll();
                    }
                 }
               if(keyWord(text)== " Sell_80")
                 {
                  Sleep(500);
                  if(open_sell_80("XAUUSD",0902))
                    {
                     sendSignal();
                     SendSignalScreenShot(chat.m_id, NULL, PERIOD_H1, 800, 600, TRUE,InpToken);
                     ObjectsDeleteAll();
                    }
                 }
               if(keyWord(text)== " close")
                 {
                  close(0901);
                  close(2301);
                  close(0902);
                  close(2302);
                  sendReport();
                  SendReportScreenShot(chat.m_id, NULL, PERIOD_H1, 800, 600, TRUE,InpToken);
                  ObjectsDeleteAll();
                 }
               if(keyWord(text)== " report")
                 {
                  sendReport();
                  SendReportScreenShot(chat.m_id, NULL, PERIOD_H1, 800, 600, TRUE,InpToken);
                  ObjectsDeleteAll();
                 }
               if(keyWord(text)== " scr")
                 {
                  SendAdminScreenShot(chat.m_id, NULL, PERIOD_H1, 800, 600, TRUE,InpToken);
                 }
              }
           }
         else
           {
            if(onTrade)
              {
               sendReport();
               SendReportScreenShot(chat.m_id, NULL, PERIOD_H1, 800, 600, TRUE,InpToken);
               ObjectsDeleteAll();
               onTrade = false;
              }
           }
        }
     }
  };

CMyBot            bot;

int               getme_result;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int               OnInit()
  {
   ObjectsDeleteAll();
   Observer = new CTradeObserverV2(OnTrade);
   bot.Token(InpToken);
   getme_result = bot.GetMe();
//--- create timer
   EventSetTimer(5);

//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void              OnDeinit(const int reason)
  {
   delete Observer;
//--- destroy timer
   EventKillTimer();

   ObjectsDeleteAll();
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void              OnTick()
  {
  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void              OnTimer()
  {
//---
   Observer.StartScan();


//--- show error message end exit
   if(getme_result!=0)
     {
      Comment("Error: ",GetErrorDescription(getme_result));
      return;
     }
//--- show bot name
   if(bot.Name()== "MT4_socket_bot")
     {
      Comment("Server is connected");
     }
   bot.GetUpdates();

//--- processing messages
   bot.ProcessMessages();
 
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void              OnTrade()
  {
   SChangeLine changes[];
   Observer.GetChanges(changes);

   for(int i=0; i<ArraySize(changes); i++)
     {
      if(changes[i].changeType == CHANGE_TYPE_CLOSED)
        {
         onTrade = true;
        }
      else
         break;
     }
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
