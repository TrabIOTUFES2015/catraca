#define NEW_PRINTF_SEMANTICS
#include "printf.h"
#include "Catraca.h"

configuration CatracaAppC {}
implementation {
  components CatracaC, MainC, LedsC, ActiveMessageC;
  
  components new TimerMilliC() as TimerLuz;
  
  //Usando api easycollection, porém não conseguir fazer end point escuta
  components CollectionC as Collector;
  components new CollectionSenderC(0xee);

  //Usando rádio comum
  //components new AMSenderC(AM_RADIO_CATRACA_MSG) as AMSender;
  components new AMReceiverC(AM_RADIO_CATRACA_MSG);

  

  components PrintfC;
  components SerialStartC;

  components new PhotoC() as SensorDeLuz; //Para o MDA100
  //components new HamamatsuS1087ParC() as SensorDeLuz; //Para o telosb



  CatracaC.Boot -> MainC;
  CatracaC.RadioControl -> ActiveMessageC;
  

  CatracaC.Leds -> LedsC;
  CatracaC.TimerLuz -> TimerLuz;
  
  CatracaC.Receive -> AMReceiverC;
  //CatracaC.Send -> AMSender;


  //Usando api easy collection
  CatracaC.Send -> CollectionSenderC;
  //CatracaC.Receive -> Collector.Receive[0xee];
  CatracaC.RoutingControl -> Collector;

  CatracaC.SensorDeLuz -> SensorDeLuz;



}
