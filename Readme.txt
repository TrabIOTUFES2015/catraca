A idéia do projeto é construir uma catraca utilizando os sensores de luz do telosb, um iris ligado ao PC e canhões de laser que ficariam apontados para o sensor de luz.
Ao haver interrupção em um deles (queda do valor de luminescência), o mesmo deverá enviar ao módulo ligado ao pc a informação de interrupção de luz junto com o valor de luz que está lendo.

O módulo iris por sua vez deverá possuir uma aplicação que fará o processamento (para justificar ainda mais a sua existência, pois a máquina em que o mesmo estivesse ligado 
poderia também fazer tal processamento), armazenando o esta informação e ficar aguardando pelo sinal do outro. 

Logo desta forma poderia-se inferir qual o sentido em que a pessoa caminhou.

Políticas de garantia de entrega de pacote por parte do sensor. O mesmo sempre deve tentar entregar a sua ultima leitura. Possível melhoria seria entregar as ultimas 10 com horário anotado.

Políticas de configuração: O iris que terá o módulo de configuração e processamento, deverá enviar pacote de configuração, tais módulos deverão receber estes pacotes e atualizarem seus parâmetros.

Parâmetros a serem configurados:

* Se o sensor de luz deve estar sensoriando ou desligado.

* Taxa de leitura do sensor, afim de se economizar bateria.


Melhorias
* Identificação do seu sensor (Possível melhoria seria o sensor telosb, encontrar o outro mais próximo de si. Dae então ele enviaria para o coordenador (IRIS), quem deverá ser par na catraca. Isto no caso de haver mais catracas, tornando o escalar).

* Dissemination. No caso ainda no quesito escalabilidade, poderiamos monitorar todas as porta de uma casa por exemplo, simplesmente um sensor repassando mensagens utilizando-se os diversos nós existentes na rede de sensores dentro da casa.

