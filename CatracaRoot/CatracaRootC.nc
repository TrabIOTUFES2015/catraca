#include "Timer.h"
#include "printf.h"
#include "../Catraca.h"

module CatracaRootC {
  uses {
    interface Boot;
    interface SplitControl as RadioControl;
    interface StdControl as RoutingControl;
    interface AMSend;
    interface Leds;    
    interface RootControl;
    interface Receive;
    interface Timer<TMilli> as TimerEnviarConfiguracao;
    interface Packet;
  }
}
implementation {
  message_t packet;
  bool sendBusy = FALSE;
  bool configuracaoPendente = FALSE;
  



  event void Boot.booted() {
    printf("Iniciado Root....\n");
    printfflush();
    call RadioControl.start();    
  }
  
  event void RadioControl.startDone(error_t err) {    
    if (err != SUCCESS) {
      call RadioControl.start();
    } else {
      call RoutingControl.start();
      call Leds.led0On();
      call RootControl.setRoot();  
      //Agora somente enviar configuracal qnd necessário
      //call TimerEnviarConfiguracao.startPeriodic(5000);      
      
   }
 }

  event void RadioControl.stopDone(error_t err) {}

  
  //Enviar pacote de configuracao
  void sendConfiguracao(DispositivoId dispositivoId) {   
    ConfiguracaoMsg* msg =
      (ConfiguracaoMsg*) call Packet.getPayload(&packet, sizeof(ConfiguracaoMsg));    
    configuracaoPendente = TRUE;             
    msg->dispositivoId = dispositivoId; //Broadcasting por enquanto
    msg->tmpSensor = 2000;
    msg->tipo = CONFIGURACAO;
    

    printf("Tentando enviar pacote de configuracao.... id=%u\n", TOS_NODE_ID);
    
    sendBusy = TRUE;
    call Leds.led0On();
    if (call AMSend.send(AM_BROADCAST_ADDR, &packet, sizeof(ConfiguracaoMsg)) != SUCCESS) {
      call Leds.led0Off();
      call Leds.led1Off();
      printf("Nem enviou\n");
    } else { 
      call Leds.led0Off();
      //sendBusy = TRUE;
      call Leds.led1On();
      printf("Enviou\n");
    }

    printfflush();
  }


  event void TimerEnviarConfiguracao.fired() {    
    // if (!sendBusy)
    //   sendMessage();
    if (!sendBusy){      
      //Se for p/ enviar periodicamente será em broadcast
      sendConfiguracao(-1);
    }
  }


  event void AMSend.sendDone(message_t* m, error_t err) {
    if (err == SUCCESS) { 
      //TODO verificar tipo de pacote p/ setar p/ false apenas bool correto
      configuracaoPendente = FALSE;
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








  //Funcoes de recebimento e tratamento de pacotes

  void tratarPacoteCatraca(CatracaMsg* pkt) {
    //TODO tratar, verificar se é pedido de pacote de configuração
    if (pkt->tipo == REQ_CONF) {
      printf("Pacote catraca - tipo %u -  dispositivoId - %u\n", pkt->tipo, pkt->dispositivoId);
      sendConfiguracao(pkt->dispositivoId);
    }
    
  }

  void tratarPacoteLeitura(LeituraSensorMsg* pkt) {
   
      call Leds.led1On();
      
      printf("Luminosidade do sensor %u é igual a %u\n", pkt->dispositivoId, pkt->luminosidade);    
      
      call Leds.led1Off();

  }

  void tratarPacoteConfiguracao(ConfiguracaoMsg* pkt) {
    //Fazer nada por enquanto
    printf("Pacote de configuração... Root Ignora\n");
  }

  void tratarPacoteDesconhecido(void * pkt) {
    //nada por enquanto
  }
  
  event message_t* Receive.receive(message_t* msg, void* payload, uint8_t len) {

    //Encontrar uma maneira do root não receber o próprio pacote

    printf("Chegou pacote\n");

    switch(len) {

      case sizeof(CatracaMsg):
        tratarPacoteCatraca((CatracaMsg*) payload);
        break;
      case sizeof(LeituraSensorMsg):
        tratarPacoteLeitura((LeituraSensorMsg*) payload);
        break;
      
      //Na teoria root não trata configuracao
      case sizeof(ConfiguracaoMsg):
        tratarPacoteConfiguracao((ConfiguracaoMsg*) payload);
        break;
      
      default:
        tratarPacoteDesconhecido(payload);        
    }


      //call Leds.led1Toggle();        

    
    printfflush();
    return msg;    
  }
}
