#define NEW_PRINTF_SEMANTICS
#include "printf.h"

configuration CatracaAppC {}
implementation {
  components CatracaC, MainC, LedsC, ActiveMessageC;
  components CollectionC as Collector;
  components new CollectionSenderC(0xee);
  components new TimerMilliC();

  components PrintfC;
  components SerialStartC;

  components new PhotoC() as SensorDeLuz;



  CatracaC.Boot -> MainC;
  CatracaC.RadioControl -> ActiveMessageC;
  CatracaC.RoutingControl -> Collector;
  CatracaC.Leds -> LedsC;
  CatracaC.Timer -> TimerMilliC;
  CatracaC.Send -> CollectionSenderC;
  CatracaC.RootControl -> Collector;
  CatracaC.Receive -> Collector.Receive[0xee];

  CatracaC.SensorDeLuz -> SensorDeLuz;



}
