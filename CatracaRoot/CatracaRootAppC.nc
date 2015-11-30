#define NEW_PRINTF_SEMANTICS
#include "printf.h"
#include "../Catraca.h"
configuration CatracaRootAppC {}
implementation {
  components CatracaRootC, MainC, LedsC, ActiveMessageC;

   //Usando api easycollection, porém não conseguir fazer end point escuta
  components CollectionC as Collector;
  components new CollectionSenderC(0xee);

  //Usando rádio comum
  components new AMSenderC(AM_RADIO_CATRACA_MSG);
  //components new AMReceiverC(AM_RADIO_CATRACA_MSG);


  components new TimerMilliC() as TimerEnviarConfiguracao;

  
  components PrintfC;
  components SerialStartC;

  CatracaRootC.Boot -> MainC;
  CatracaRootC.AMSend -> AMSenderC;
  CatracaRootC.RadioControl -> ActiveMessageC;
  CatracaRootC.RoutingControl -> Collector;
  CatracaRootC.Leds -> LedsC;
  //CatracaRootC.Send -> CollectionSenderC;  
  CatracaRootC.Packet -> AMSenderC;
  CatracaRootC.RootControl -> Collector;
  CatracaRootC.Receive -> Collector.Receive[0xee];
  CatracaRootC.TimerEnviarConfiguracao -> TimerEnviarConfiguracao;



  


}
