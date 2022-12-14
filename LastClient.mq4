#property copyright "Copyright 2022, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#include "..\\Include\\Telegram.mqh"
#include "..\\Include\\TradeObserverV2.mqh"

#include "..\\Libraries\\LastClientLib.mq4"

CTradeObserverV2 *Observer;
static bool onTrade;
int switchBot = 2;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CMyBot: public CCustomBot
  {
private:
   string            m_button[1];

public:
   void              CMyBot();
   void              ProcessMessages();
   string            GetKeyboard_1();
   string            GetKeyboard_2();
  };

CMyBot bot;
int getme_result;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
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
void OnDeinit(const int reason)
  {
   delete Observer;
//--- destroy timer
   EventKillTimer();

   ObjectsDeleteAll();
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
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
   if(bot.Name()==botName)
     {
      Comment("Server is connected");
     }
   bot.GetUpdates();
//--- reading messages

//--- processing messages
   bot.ProcessMessages();
//---{ insert your code here }

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTrade()
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
//|                                                                  |
//+------------------------------------------------------------------+
void CMyBot::CMyBot()
  {
   m_button[0] = "چه خبر؟";
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string CMyBot::GetKeyboard_1()
  {
   string result = "[[\""+m_button[0]+"\"]]";
   return result;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CMyBot::ProcessMessages(void)
  {
   for(int i=0; i<m_chats.Total(); i++)
     {
      CCustomChat *chat=m_chats.GetNodeAtIndex(i);
      //--- if the message is not processed
      if(!chat.m_new_one.done)
        {
         chat.m_new_one.done=true;
         string text=chat.m_new_one.message_text;
         if(chat.m_id == StringToInteger(chatID))
           {
            if(text=="/start")
              {
               SendMessage(chat.m_id,
                           "سلام، \nمن خشـــایار بـــاتــــــ هســـتم، روبات و مشاور معاملاتی شما. هروقت که تمایل داشتید از جزئیات سود و ضرر من روی حسابتون مطلع بشید، دکمه  << چه خبر؟ >>  رو لمس کنید.",
                           bot.ReplyKeyboardMarkup(GetKeyboard_1(),
                                                   false,
                                                   true));
              }
            if(text == m_button[0])
              {
               SendMessage(StringToInteger(chatID),info(),NULL);
              }
           }
         if(chat.m_id == gpId)
           {
            if(keyWord(text)== " Buy_")
              {
               Sleep(500);
               if(open_buy("XAUUSD",2301))
                 {
                  ObjectsDeleteAll();
                 }
              }
            if(keyWord(text)== " Sell_")
              {
               Sleep(500);
               if(open_sell("XAUUSD",0901))
                 {
                  ObjectsDeleteAll();
                 }
              }
            if(keyWord(text)== " Buy_80")
              {
               Sleep(500);
               if(open_buy_80("XAUUSD",2302))
                 {
                  ObjectsDeleteAll();
                 }
              }
            if(keyWord(text)== " Sell_80")
              {
               Sleep(500);
               if(open_sell_80("XAUUSD",0902))
                 {
                  ObjectsDeleteAll();
                 }
              }
            if(keyWord(text)== " close")
              {
               close(0901);
               close(2301);
               close(0902);
               close(2302);
               ObjectsDeleteAll();
              }
            if(keyWord(text)== " jooon mikhaaam")
              {
               SendMessage(gpId, monthlyReport()+ "\n \n" +
                           "\n" + AccountName());
              }
           }
        }
     }
  }
//+------------------------------------------------------------------+
