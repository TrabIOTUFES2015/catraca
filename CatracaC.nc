#include "Timer.h"
#include "printf.h"
#include "Catraca.h"

module CatracaC {
  uses {
    interface Boot;
    interface SplitControl as RadioControl;
    interface StdControl as RoutingControl;
    interface Send;
    interface Leds;
    interface Timer<TMilli> as TimerLuz;
    // interface RootControl;
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
  uint16_t valorLuminancia = 890;
  bool transferirSempre = FALSE;




  event void Boot.booted() {
    printf("Iniciado....%u\n", ++counter);
    printfflush();
    call RadioControl.start();
    //call TimerLuz.startPeriodic(2000); 
    printf("Aguardando Pacote de Configuracao....\n");  

  }

  void sendReqConf() {    
    CatracaMsg* msg =
      (CatracaMsg*)call Send.getPayload(&packet, sizeof(CatracaMsg));
    msg->dispositivoId = TOS_NODE_ID;
    msg->tipo = REQ_CONF;
    printf("Tentando enviar pacote de configuracao.... id=%u\n", TOS_NODE_ID);
    call Leds.led0On();
    sendBusy = TRUE;
    if (call Send.send(&packet, sizeof(CatracaMsg)) != SUCCESS) {
      call Leds.led0Off();
      call Leds.led1Off();
      printf("Nem enviou\n");
      sendReqConf();
    } else { 
      call Leds.led0Off();      
      call Leds.led1On();
      printf("Enviou\n");
    }

    printfflush();
  }
  
  event void RadioControl.startDone(error_t err) {    
    if (err != SUCCESS) {
      call RadioControl.start();    
    } else {
      call RoutingControl.start();      
      sendReqConf();
   }
 }

  event void RadioControl.stopDone(error_t err) {}

  void sendMessage() {    
    // CatracaMsg* msg =
    //   (CatracaMsg*)call Send.getPayload(&packet, sizeof(CatracaMsg));
    // msg->leitura.dispositivoId = TOS_NODE_ID;
    // msg->leitura.luminosidade = ultima_leitura;
    // printf("Tentando enviar pacote.... id=%u\n", TOS_NODE_ID);
    // call Leds.led0On();
    // if (call Send.send(&packet, sizeof(CatracaMsg)) != SUCCESS) {
    //   call Leds.led0Off();
    //   call Leds.led1Off();
    //   printf("Nem enviou\n");
    // } else { 
    //   call Leds.led0Off();
    //   sendBusy = TRUE;
    //   call Leds.led1On();
    //   printf("Enviou\n");
    // }

    // printfflush();
  }


  void sendLeitura(uint16_t valor) {    
    LeituraSensorMsg* msg =
      (LeituraSensorMsg*)call Send.getPayload(&packet, sizeof(LeituraSensorMsg));
    msg->dispositivoId = TOS_NODE_ID;
    msg->luminosidade = ultima_leitura;
    msg->tipo = LEITURA;
    printf("Tentando enviar pacote.... id=%u\n", TOS_NODE_ID);
    call Leds.led0On();
    sendBusy = TRUE;
    if (call Send.send(&packet, sizeof(LeituraSensorMsg)) != SUCCESS) {
      call Leds.led0Off();
      call Leds.led1Off();
      printf("Nem enviou\n");
    } else { 
      call Leds.led0Off();      
      call Leds.led1On();
      printf("Enviou\n");
    }

    printfflush();
  }


  event void TimerLuz.fired() {    
    // if (!sendBusy)
    //   sendMessage();

    printf("Iniciando leitura...\n");

    call SensorDeLuz.read();

    printfflush();
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
  
  




   //Funcoes de recebimento e tratamento de pacotes
  void tratarPacoteCatraca(CatracaMsg* pkt) {
    //TODO tratar, verificar se é pedido de pacote de configuração
    printf("Pacote catraca - tipo %u -  dispositivoId - %u\n", pkt->tipo, pkt->dispositivoId);
  }

  void tratarPacoteLeitura(LeituraSensorMsg* pkt) {
   
      call Leds.led1On();
      
      printf("Luminosidade do sensor %u é igual a %u\n", pkt->dispositivoId, pkt->luminosidade);    
      
      call Leds.led1Off();

  }

  void tratarPacoteConfiguracao(ConfiguracaoMsg* pkt) {

    printf("Pacote de configuracao chegou... tmpSensor %u %u", pkt->tipo, pkt->dispositivoId);

    if (pkt->tipo == CONFIGURACAO && pkt->dispositivoId == TOS_NODE_ID) {
      printf("Pacote de configuracao chegou... tmpSensor=%u\n", pkt->tmpSensor);
      configurado = FALSE;

      valorLuminancia = pkt->valorLuminancia;

      //(Re)configurando  tempo de leitura do sensor
      call TimerLuz.stop();
      //Reiniciar o tempo de leitura com base no parâmetro passado
      call TimerLuz.startPeriodic(pkt->tmpSensor);     

      configurado = TRUE;
    }

  }

  void tratarPacoteDesconhecido(void * pkt) {
    //nada por enquanto
  }


  event message_t* Receive.receive(message_t* msg, void* payload, uint8_t len) {

    printf("Iniciando recebimento de pacote\n");

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
      if (data < valorLuminancia) {
        call Leds.led2On();
        if (configurado && !sendBusy) {
          sendLeitura(data);
        }

      } else {
        call Leds.led2Off();
        if (transferirSempre && !sendBusy)
          sendLeitura(data);
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
