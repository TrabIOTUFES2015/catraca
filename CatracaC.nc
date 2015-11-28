#include "Timer.h"
#include "printf.h"

module CatracaC {
  uses {
    interface Boot;
    interface SplitControl as RadioControl;
    interface StdControl as RoutingControl;
    interface Send;
    interface Leds;
    interface Timer<TMilli> as TimerLuz;
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

  
  typedef nx_struct CatracaMsg {
    //TipoPacote tipo, configuracao, reconfiguracao e luminosidade
    //TipoPacote tipo;
    nx_uint16_t dispositivoId;
    nx_uint16_t luminosidade;
    //void* payloadCatraca;

  } CatracaMsg;

  /*Fim de dtos de protocolo*/



  event void Boot.booted() {
    printf("Iniciado....%u\n", ++counter);
    printfflush();
    call RadioControl.start();
    if (TOS_NODE_ID != 1) {
      call TimerLuz.startPeriodic(2000);      
    }

  }
  
  event void RadioControl.startDone(error_t err) {    
    if (err != SUCCESS) {
      call RadioControl.start();
    } else {
      call RoutingControl.start();
      if (TOS_NODE_ID == 1){ 
       call Leds.led0On();
       call RootControl.setRoot();        
      } 
      // else {
      //  call Timer.startPeriodic(5000);
      // }
   }
 }

  event void RadioControl.stopDone(error_t err) {}

  void sendMessage() {    
    CatracaMsg* msg =
      (CatracaMsg*)call Send.getPayload(&packet, sizeof(CatracaMsg));
    msg->dispositivoId = TOS_NODE_ID;
    msg->luminosidade = ultima_leitura;
    printf("Tentando enviar pacote.... id=%u\n", TOS_NODE_ID);
    call Leds.led0On();
    if (call Send.send(&packet, sizeof(CatracaMsg)) != SUCCESS) {
      call Leds.led0Off();
      call Leds.led1Off();
      printf("Nem enviou\n");
    } else { 
      call Leds.led0Off();
      sendBusy = TRUE;
      call Leds.led1On();
      printf("Enviou\n");
    }

    printfflush();
  }
  event void TimerLuz.fired() {    
    // if (!sendBusy)
    //   sendMessage();

    call SensorDeLuz.read();
  }
  
  event void Send.sendDone(message_t* m, error_t err) {
    if (err == SUCCESS) { 
      call Leds.led0On();
      call Leds.led1On();      
      printf("Envio Terminou com sucesso\n");
    } else {
      call Leds.led1On();      
      printf("Envio Terminou com falha\n");
    }
    call Leds.led0On();
    call Leds.led0Off();
    call Leds.led1Off();
    sendBusy = FALSE;    
  }
  
  event message_t* Receive.receive(message_t* msg, void* payload, uint8_t len) {

    printf("Iniciando recebimento de pacote\n");

    if (len == sizeof(CatracaMsg)) {

      CatracaMsg* pkt = (CatracaMsg*) payload;        
      call Leds.led1On();
      
      printf("Luminosida do sensor %u é igual a %u\n", pkt->dispositivoId, pkt->luminosidade);    
      
      call Leds.led1Off();
    }
      //call Leds.led1Toggle();        

    printf("Terminando recebimento de pacote\n");
    printfflush();
    return msg;

    
  }



  /*Leitura do sensor*/
  event void SensorDeLuz.readDone(error_t result, uint16_t data) {    
    if (result == SUCCESS){      
      printf("%u\n",data);
      printfflush();
      ultima_leitura = data;
      if (data > 600) {
        call Leds.led2On();
        if (!sendBusy) {
          sendMessage();
        }

      } else {
        call Leds.led2Off();
      }

    }

    // if (data > 10) {
    //   call Leds.led0On();
    // } else {
    //   call Leds.led0Off();
    // }

    // if (data > 100) {
    //   call Leds.led1On();
    // } else {
    //   call Leds.led1Off();
    // }

    
  }

}
