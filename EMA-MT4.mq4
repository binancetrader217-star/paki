//+------------------------------------------------------------------+
//|                                           EMA-MT4.mq4 |
//|                                           https://t.me/kendricpoweb |
//|                                           https://t.me/kendrickpoweb|
//+------------------------------------------------------------------+
#property copyright "https://t.me/kendrickpoweb  3.5.2025"
#property link      "https://t.me/kendrickpoweb"
#property version   "1.00"
#property strict
#property description "  kendrickpoweb 2.5.2025"


string EA;
string  EA1                             =  "EMA-MT4 ";  //  Comment To Dispaly In Order
extern int     magic                    =  7676791;                //  Magic Number
extern double  lot_initial              =  0.01;                   //  Lot Started
extern double  multiplier               =  2.0;                    //  Multiplier  
extern int     takeprofit               =  20;                     //  TakeProfit (Pips)
extern int     distance_pips            =  10;                     //  Distance Open Position (Pips)
int     maxlayer                        =  10;                    //  Max Layer Martingale
extern bool    display_info             =  true;                   //  Show Info On Chart

double lotsbuy[];
double lotssell[];

string buy = " buy ";
string sell= " sell ";



//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- create timer
      
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- destroy timer
ObjectsDeleteAll();
      
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
setup();
   
  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Tester function                                                  |
//+------------------------------------------------------------------+
double OnTester()
  {
//---
   double ret=0.0;
//---

//---
   return(ret);
  }
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
//---
   
  }
//+------------------------------------------------------------------+
double stoplvl()
{
double value    =  0;
double value1   =  MarketInfo(Symbol(),MODE_STOPLEVEL);
double value2   =  MarketInfo(Symbol(),MODE_FREEZELEVEL); 

if (value1  >  value2)  value   =  value1;
else 
if (value1  <  value2)  value   =  value2;

return(value*Point);
}// end stplvl
//+------------------------------------------------------------------+
int dec(){   int decimal;   if (Digits==3|| Digits==5) decimal=10;   else  decimal=1;   return(decimal);}
//+------------------------------------------------------------------+
double ask()
{
RefreshRates();
return(NormalizeDouble(MarketInfo(Symbol(),MODE_ASK),Digits));
}//
//--------------------------------------------------------------------+
double bid()
{
RefreshRates();
return(NormalizeDouble(MarketInfo(Symbol(),MODE_BID),Digits));
}//

//+------------------------------------------------------------------+
double minlot()
{return(MarketInfo(Symbol(),MODE_MINLOT));}
//+------------------------------------------------------------------+
double maxlot()
{return(MarketInfo(Symbol(),MODE_MAXLOT));}
//+------------------------------------------------------------------+

void openorder( int type, double Lot,double price,double SLvalue, double TPvalue, color kolor)
{ 
if (Lot  < minlot()) Print( " periksa saiz lot = ", DoubleToStr(Lot,2)," kecik.. minimum lot broker= ", minlot());
if (Lot  > maxlot()) Print( " periksa saiz lot = ", DoubleToStr(Lot,2)," besar.. maximum lot broker= ", maxlot());

bool order  =  OrderSend(Symbol() ,type ,Lot ,price ,3*dec() ,SLvalue ,TPvalue ,EA ,magic ,0 ,kolor);
if  (!order)   Print(Symbol()  ,",  Orderticket = ",OrderTicket(),", type= ",type,", ERROR=", GetLastError());
}// end
//--------------------------------------------------------------------+

int counter(int type, int magicnumber)
{
int count  =  0;
for (int x=0;x<OrdersTotal();x++)
   { 
     if(OrderSelect        (x,SELECT_BY_POS,MODE_TRADES) )
     if (OrderSymbol()     != Symbol())      continue;
     if( OrderMagicNumber()!= magicnumber)   continue;
     if (OrderType()       != type)          continue;
         count++;
   }// for loop
return(count);
}// end
//--------------------------------------------------------------------+
void array_resize()
{
   int reserved   =  200;
   int max        =  maxlayer ;
   ArrayResize(lotsbuy ,max,reserved);
   ArrayResize(lotssell,max,reserved);
   
}// end
//--------------------------------------------------------------------+

void initialize_lotbuy()
{
lotsbuy[0]= lot_initial;
for(int x=1; x<maxlayer ; x++)
   {
    lotsbuy[x]   =  lotsbuy[x-1]*multiplier;   
   } // for loop
for(int x=0; x<maxlayer ; x++)
      lotsbuy[x]  =  NormalizeDouble(lotsbuy[x],2);

}// end
//+------------------------------------------------------------------+

void initialize_lotsell()
{
lotssell[0]= lot_initial;
for(int x=1; x<maxlayer; x++)
   {
    lotssell[x]   =  lotssell[x-1]*multiplier;   
   } // for loop
for(int x=0; x<maxlayer ; x++)
      lotssell[x]  =  NormalizeDouble(lotssell[x],2);

}// end
//+------------------------------------------------------------------+

double latest_openprice(int type)
{
double value=0;
int ticket  =  get_latest_ticket(type);
if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES))
   value= OrderOpenPrice();

return(value);


}// end
//--------------------------------------------------------------------+


double nextlayer_pricebuy()
{
double value  =  latest_openprice(OP_BUY)  - dist();
return(nl(value));
}// end
//+------------------------------------------------------------------+

double nextlayer_pricesell()
{
double value  =  latest_openprice(OP_SELL)  + dist();
return(nl(value));
}// end
//+------------------------------------------------------------------+

double dist()
{return(distance_pips *dec() *Point);}

//+------------------------------------------------------------------+
double nl(double value)
{return(NormalizeDouble(value,Digits));}// end
//+------------------------------------------------------------------+

int get_latest_ticket(int type)
{
int ticket   =  0;
for (int x=0;x<OrdersTotal();x++)
     {
     if(OrderSelect           (x,SELECT_BY_POS,MODE_TRADES))
     if(OrderSymbol()         !=  Symbol())            continue;
     if(OrderMagicNumber()    !=  magic)               continue; 
     if(OrderType()           !=  type)                continue;
     if(OrderTicket()         >   ticket || ticket == 0 )
                     ticket   =   OrderTicket();
     }// for loop  

return(ticket);
}// end
//--------------------------------------------------------------------+
double tp_buy()
{
double value   =  latest_openprice(OP_BUY) + takeprofit * dec()* Point;
if (takeprofit < stoplvl())
   value = 0;
return(nl(value));
}//
//+------------------------------------------------------------------+

double tp_sell()
{
double value   =  latest_openprice(OP_SELL) - takeprofit * dec()* Point;
if (takeprofit < stoplvl())
   value = 0;
return(nl(value));
}//
//+------------------------------------------------------------------+

void put_tp(double tp_cal)
{

double tp = nl(tp_cal);

for(int x=0; x<OrdersTotal(); x++)
   {
   RefreshRates();

   if(OrderSelect          (x,SELECT_BY_POS,MODE_TRADES))
   if(OrderSymbol()        == Symbol())
   if(OrderMagicNumber()   == magic   )
   //if(takeprofit           >  stoplvl())
      {
      //------------------------------------------------
      if(OrderType()  ==    OP_BUY)
      if(tp           >     0)
      if(tp           !=    OrderTakeProfit())
      if(tp           >     ask()   +  stoplvl())
      
               {
               bool modify =     OrderModify(OrderTicket(),OrderOpenPrice(),OrderStopLoss(),tp,0,clrNONE);
               if (!modify)      Print("tp= ",tp,",  modify error trade. error= ", GetLastError());
               }

      //------------------------------------------------
      if(OrderType()  ==    OP_SELL)
      if(tp           >     0)
      if(tp           !=    OrderTakeProfit())
      if(tp           <     bid()  -  stoplvl())
               {
               bool modify =     OrderModify(OrderTicket(),OrderOpenPrice(),OrderStopLoss(),tp,0,clrNONE);
               if (!modify)      Print(OrderTicket(),"  tp_sell= ",tp,"    modify error sell trade. error= ", GetLastError());
               }
      }// if select
   }// for loop
}// end

//--------------------------------------------------------------------+
string floating(int type)
{
double floating  =  0;
for (int x=0;x<OrdersTotal();x++)
   { 
     if(OrderSelect        (x,SELECT_BY_POS,MODE_TRADES) )
     if (OrderSymbol()     != Symbol())      continue;
     if( OrderMagicNumber()!= magic)         continue;
     if (OrderType()       != type)          continue;
         floating += OrderProfit();
   }// for loop
return(DoubleToStr(floating,2));
}// end
//+------------------------------------------------------------------+



void setup()
{
array_resize();
initialize_lotbuy();
initialize_lotsell();

//-- initial simultaneous orders 
if (counter(OP_BUY,magic)==0)
   {
   EA=EA1+buy+IntegerToString(counter(OP_BUY,magic));
   openorder(OP_BUY, lot_initial,ask(),0,0,clrBlue);
   }
   
if (counter(OP_SELL,magic)==0)
   {   
   EA=EA1+sell+IntegerToString(counter(OP_SELL,magic));
   openorder(OP_SELL,lot_initial,bid(),0,0,clrRed);
   }



//--layering sell martingale orders
if (counter(OP_SELL,magic)  >  0) 
if (counter(OP_SELL,magic)  <  maxlayer)
if (bid()                  >= nextlayer_pricesell())
   {
   EA=EA1+sell+IntegerToString(counter(OP_SELL,magic));
   openorder(OP_SELL,lotssell[counter(OP_SELL,magic)],bid(),0,0,clrRed);
   }
   
   
  
//--layering buy martingale orders
if (counter(OP_BUY,magic)  >  0) 
if (counter(OP_BUY,magic)  <  maxlayer)
if (ask()                  <= nextlayer_pricebuy())
   {
   EA=EA1+buy+IntegerToString(counter(OP_BUY,magic));
   openorder(OP_BUY,lotsbuy[counter(OP_BUY,magic)],ask(),0,0,clrBlue);
   }
  
   
//-- put tp 
if (counter(OP_BUY,magic)>0)
   put_tp(tp_buy());
if (counter(OP_SELL,magic)>0)
   put_tp(tp_sell());
   
if(display_info)   
 display();
 
else {ObjectsDeleteAll(0,OBJ_RECTANGLE_LABEL); ObjectsDeleteAll(0,OBJ_LABEL);}
}// end

//--------------------------------------------------------------------+

void display()
{
Comment("");
rec_label("pak",120,40,clrSeaGreen);
text("paktex",114,50,EA1, clrYellow);
text("buy",114,70,"BUY: ", clrYellow);text("countbuy",60,70,IntegerToString(counter(OP_BUY,magic)), clrYellow);
text("sell",114,90,"SELL: ", clrYellow);text("countsell",60,90,IntegerToString(counter(OP_SELL,magic)), clrYellow);
text("fbuy",114,110,"FL.BUY:  ", clrYellow);text("flbuy",60,110,floating(OP_BUY), clrYellow);
text("fsell",114,130,"FL.SELL:  ", clrYellow);text("flsell",60,130,floating(OP_SELL), clrYellow);

}// end

//--------------------------------------------------------------------+

void rec_label(string name, int xD,int yD,color warna)
{
  //ObjectDelete(name);
  ObjectCreate(0,name,OBJ_RECTANGLE_LABEL,0,0,0);
  ObjectSetInteger(0,name,OBJPROP_XDISTANCE,xD);
  ObjectSetInteger(0,name,OBJPROP_YDISTANCE,yD);
  ObjectSetInteger(0,name,OBJPROP_XSIZE,120);
  ObjectSetInteger(0,name,OBJPROP_YSIZE,120);
  ObjectSetInteger(0,name,OBJPROP_BGCOLOR,warna);
  ObjectSetInteger(0,name,OBJPROP_BORDER_TYPE,STYLE_SOLID);
  ObjectSetInteger(0,name,OBJPROP_CORNER,CORNER_RIGHT_UPPER);
  ObjectSetInteger(0,name,OBJPROP_COLOR,clrSilver);
  ObjectSetInteger(0,name,OBJPROP_STYLE,BORDER_SUNKEN);
  ObjectSetInteger(0,name,OBJPROP_WIDTH,5);
  ObjectSetInteger(0,name,OBJPROP_BACK,true);
  ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
  ObjectSetInteger(0,name,OBJPROP_SELECTED,false);
  ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);
}
//+------------------------------------------------------------------+
void text(string name2, int xDtext, int yDtext,string text, color kolor)
{
  ObjectDelete(name2);
  ObjectCreate(0,name2,OBJ_LABEL,0,0,0);
  ObjectSetInteger(0,name2,OBJPROP_XDISTANCE,xDtext);
  ObjectSetInteger(0,name2,OBJPROP_YDISTANCE,yDtext);
  ObjectSetInteger(0,name2,OBJPROP_CORNER,CORNER_RIGHT_UPPER);
  ObjectSetString(0,name2,OBJPROP_TEXT,text);
  ObjectSetString(0,name2,OBJPROP_FONT,"Arial");
  ObjectSetInteger(0,name2,OBJPROP_FONTSIZE,10);
  ObjectSetInteger(0,name2,OBJPROP_COLOR,kolor);
  ObjectSetInteger(0,name2,OBJPROP_BACK,false);
  ObjectSetInteger(0,name2,OBJPROP_SELECTABLE,false);
  ObjectSetInteger(0,name2,OBJPROP_SELECTED,false);
  ObjectSetInteger(0,name2,OBJPROP_HIDDEN,true); 
  

}// end text
//+------------------------------------------------------------------+










