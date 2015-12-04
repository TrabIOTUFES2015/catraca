/**TODO Tentar colocar os DTO pertecentes ao protocolo aqui.
Ex: A estrutura de dados utilizado para informar a configuração 
A estrutura de dados de envio dos sensores telosb
**/

  /* Abaixo structs do protocolo firmado */
  /*Definição de DTOs e payload*/
//Não funcionou trafegar enum mesmo após o cast
  // typedef enum TipoPacote {   
  //   PEDIR_CONFIGURACAO = (nx_uint8_t) 1, //Verificar se é necessário, pois se o pacote não for broadcast não será desnecessário, configuracao serve tanto p/ o root qnt p/ um endpoint 
  //   CONFIGURACAO, 
  //   LUMINOSIDADE
  // } TipoPacote;

  // typedef nx_struct PedidoConfiguracao { 

  // } PedidoConfiguracao;

  // Dado monitorado pelos sensores

#ifndef _CATRACAH

#define _CATRACAH


#define TipoPacote nx_uint8_t

//Dá para endereçar 256 dispositivos
#define DispositivoId nx_uint8_t

#define CONFIGURACAO 1
#define REQ_CONF 2
#define LEITURA 3

#define nx_bool nx_uint8_t



//Msg para 
  typedef nx_struct LeituraSensorMsg { 
  	TipoPacote tipo;
    DispositivoId dispositivoId;
    nx_uint16_t luminosidade;    
  } LeituraSensorMsg;

//Msg para ACKs e outros fins
  typedef nx_struct CatracaMsg {
    //TipoPacote tipo, configuracao, reconfiguracao e luminosidade
    TipoPacote tipo;
    DispositivoId dispositivoId;
    //PayloadCatraca payloadCatraca; //não consegui usar void*, logo õ tamanho não é variável
  } CatracaMsg;

  typedef nx_struct ConfiguracaoMsg {
  	//TODO verificar possibilidade de uso de typeof
  	TipoPacote tipo; // campo necessario apenas devido a tamanhos coincidentes 
  	DispositivoId dispositivoId;
  	nx_uint16_t tmpSensor; //Intervalo de monitoramento em millis
  	nx_uint16_t valorLuminancia;
    nx_uint16_t tmpAck; //Intervalo de pacote ack em millis    
    nx_bool transferirSempre;


  } ConfiguracaoMsg;

  CatracaMsg* contruirPacote(void* catracaPayloadAddress);

  enum {
  	AM_RADIO_CATRACA_MSG = 7,  	
  };

#endif

  /*Fim de dtos de protocolo*/