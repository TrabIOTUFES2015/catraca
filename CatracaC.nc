#include "Timer.h"
#include "printf.h"

module CatracaC {
  uses {
    interface Boot;
    interface SplitControl as RadioControl;
    interface StdControl as RoutingControl;
    interface Send;
    interface Leds;
    interface Timer<TMilli>;
    interface RootControl;
    interface Receive;

    interface Read<uint16_t> as SensorDeLuz;
  }
}
implementation {
  message_t packet;
  bool sendBusy = FALSE;
  bool configurado = FALSE;
  uint16_t counter = 0;
  uint16_t ultima_leitura = 0;

  /* Abaixo structs do protocolo firmado */
  typedef enum tipo_pacote {
    CONFIGURACAO, 
    DADO_LUZ
  } TipoPacote;

  typedef nx_struct CatracaMsg {
    //TipoPacote tipo;
    nx_uint16_t data;
  } CatracaMsg;

  event void Boot.booted() {
    //call RadioControl.start();
    call Timer.startPeriodic(2000);
  }
  
  event void RadioControl.startDone(error_t err) {    
    if (err != SUCCESS)
      call RadioControl.start();
    else {
      call RoutingControl.start();
      if (TOS_NODE_ID == 1){ 
	call RootControl.setRoot();        
      }
      else
	call Timer.startPeriodic(5000);
    }
  }

  event void RadioControl.stopDone(error_t err) {}

  void sendMessage() {
    CatracaMsg* msg =
      (CatracaMsg*)call Send.getPayload(&packet, sizeof(CatracaMsg));
    msg->data = TOS_NODE_ID;
    
    if (call Send.send(&packet, sizeof(CatracaMsg)) != SUCCESS) 
      call Leds.led0On();
    else{ 
      sendBusy = TRUE;
      call Leds.led1On();
    }
  }
  event void Timer.fired() {    
    // if (!sendBusy)
    //   sendMessage();

    call SensorDeLuz.read();
  }
  
  event void Send.sendDone(message_t* m, error_t err) {
    if (err == SUCCESS) { 
      call Leds.led0On();
      call Leds.led2Off();
    } else {
      call Leds.led2On();
    }
    sendBusy = FALSE;
    call Leds.led1Off();
  }
  
  event message_t* Receive.receive(message_t* msg, void* payload, uint8_t len) {
    CatracaMsg* pkt = (CatracaMsg*)payload;        
    printf("%u\n", pkt->data);    
    printfflush();
    call Leds.led1Toggle();        
    return msg;
  }



  /*Leitura do sensor*/
  event void SensorDeLuz.readDone(error_t result, uint16_t data) {    
    if (result == SUCCESS){      
      printf("%u\n",data);
      printfflush();
    }

    if (data > 10) {
      call Leds.led0On();
    } else {
      call Leds.led0Off();
    }

    if (data > 100) {
      call Leds.led1On();
    } else {
      call Leds.led1Off();
    }

    if (data > 1000) {
      call Leds.led2On();
    } else {
      call Leds.led2Off();
    }

  }

}
