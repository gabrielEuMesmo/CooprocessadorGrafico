# CoProcessador Gráfico

O seguinte CoProcessador Gráfico foi desenvolvido inspirado na arquitetura de consoles de 16 bits, possuindo três motores gráficos que trabalham em conjunto:
- Motor de background: responsável por apresentar uma camada de background na saída de vídeo, com 256 padrões diferentes disponíveis, permitir que cada tile seja alterado individualmente, além do deslocamento de cada camada de tile para as 4 direções;
- Motor de sprites: permite a inserção de, no máximo, 32 sprites de 16x16 pixels ao mesmo tempo na tela, com configuração de prioridade entre eles, deslocamento dos sprites pela tela para as 4 direções, espelhamento na horizontal e na vertical e definição de transparência;
- Rasterizador de polígonos: permite a inserção de até 4 polígonos de 3 ou 4 lados na tela, dadas quaisquer 3 ou 4 coordenadas (x,y), com a possibilidade de escolha da cor. 

O projeto foi criado para ser utilizado na plataforma de desenvolvimento De1-SoC, descrito totalmente na linguagem de descrição de hardware Verilog, através do ambiente de desenvolvimento Quartus Prime. Por fim, a saída de vídeo do projeto foi integrada a um monitor VGA (Video Graphics Array) conectado à placa.

# Manual do Sistema

Este projeto marca a primeira fase de um problema que tem como objetivo final o desenvolvimento de um console digital que deverá executar um jogo programado em linguagem C, exibido em um monitor VGA, no qual o jogador utilizará teclado e mouse conectados à placa DE1-SoC para interagir com as mecânicas do jogo final.

## Requisitos do problema

Foi requisitado pelo problema uma resolução lógica interna do cenários de 320x240 pixels, com duplicação pelo hardware para gerar o sinal da interface VGA operando em 640x480 pixels a 60Hz. Já para a geração de imagem, foi requisitada a criação de três motores com processamento visual contínuo: o motor de background, o motor de sprites e um rasterizador de polígonos. O motor de background precisa gerenciar um tile map de 40x30 posições com blocos de 8x8 pixels e pelo menos 256  padrões disponíveis, permitindo o deslocamento horizontal e vertical da câmera. O motor de sprites deve possuir uma memória ROM com os diferentes sprites armazenados, podendo processar até 32 sprites de 16x16 pixels simultâneos na tela, além de tratar características específicas dos sprites como posição, espelhamento, prioridade e visibilidade. E o rasterizador de polígonos deve desenhar triângulos e retângulos preenchidos, utilizando aritmética para a sua construção.

Por fim, para a apresentação dos motores na tela, foi requerido a implementação de uma “unidade de controle” responsável por combinar as informações de background, dos sprites e dos polígonos a cada pixel desenhado. Esse controlador seria responsável por aplicar as regras de transparência, lidar com as sobreposições utilizando pelo menos três níveis de prioridade e, por fim, converter o índice gráfico de 8 bits em um sinal RGB através de uma paleta de cores programável com 256 entradas.

### 

## Arquitetura e Fluxo de Dados

A arquitetura do coprocessador adota o modelo de FrameBuffer interno de 320 × 240 pixels, desacoplando a renderização gráfica da geração contínua do sinal VGA. A organização estrutural dos blocos funcionais são ilustradas no diagrama de blocos abaixo:

![Diagrama](/images/diagrama-de-alto-nivel.jpeg)

### Entradas e saídas

- Entradas:
  - `CLOCK_50`: sinal de clock principal da placa operando a 50 MHz, multiplicado para 100 MHz via PLL para o circuito interno e dividido para 25 MHz para sincronismo da temporização VGA;
  - `KEY[0]`: botão de reset geral síncrono do sistema, ativo em nível lógico baixo;
  - `KEY[1]`: botão de alternância do modo de operação principal (execução livre, configuração de background, polígonos ou sprites);
  - `KEY[2]`: botão de avanço dos subestados de parametrização;
  - `KEY[3]`: botão de ação, responsável por disparar o pulso que confirma e grava os parâmetros nos registradores;
  - `SW[9:0]`: barramento de chaves seletoras para inserção manual de coordenadas (X, Y), identificadores de tiles e sprites, flags de visibilidade e valores de cor.

- Saídas:
  - `VGA_R[7:0]`, `VGA_G[7:0]`, `VGA_B[7:0]`: barramentos de cor digital de 8 bits direcionados ao conversor digital-analógico da placa;
  - `VGA_HS` e `VGA_VS`: pulsos de sincronismo horizontal e vertical enviados ao monitor VGA;
  - `VGA_CLK`: sinal de clock de pixel de 25 MHz enviado ao conversor de vídeo;
  - `VGA_BLANK_N`: sinal de supressão ativo em nível baixo, que desliga a saída de cor analógica durante os períodos fora da área visível;
  - `LEDR[1:0]`: leds indicadores do modo de operação ativo no controlador (`LED_Modo`);
  - `LEDR[3:2]`: leds indicadores do subestado atual de configuração (`LED_SubEstado`).


### Fluxo de Operação e Dados 

- O bloco `controlador_MEF` decodifica as chaves (SW) e botões (KEY) de entrada, repassando coordenadas, cores e identificadores para os registradores dos motores gráficos e atualizando os LEDs de estado;
- Sincronizada pelo sinal `vsync`, a máquina de estados finita `MEF_geral_layer` autoriza a gravação das camadas no FrameBuffer em ordem de prioridade (background, polígonos e sprites) através do `MUX Final`. Pixels de cor zero têm a escrita desabilitada para garantir a transparência;
-  O controlador de vídeo lê a memória a 25 MHz, ampliando a imagem por escala 2×2 para gerar a saída física de 640 × 480 a 60 Hz nos canais RGB e sinais de sincronismo (H-Sync e V-Sync).

Essa abordagem no fluxo de dados soluciona o problema ao transferir todo o custo de rasterização e temporização para o hardware da FPGA, exigindo apenas atualizações pontuais de parâmetros pelo processador.

## Blocos Funcionais

A arquitetura do coprocessador gráfico foi organizada de maneira modular, separando a lógica de controle, o fluxo de dados e o processamento de vídeo, garantindo a possibilidade de expansão. O projeto está dividido nos seguintes blocos principais:

### Unidade de Controle (`controlador_MEF`)

Funciona como o mediador da interação com o usuário, traduzindo as ações manuais na placa em comandos para o hardware.

- Recebe o clock 100 MHz do sistema, o sinal de reset geral e as entradas físicas da placa (botões `KEY` e chaves seletoras `SW`);
- A máquina de estados usa `KEY[1]` para escolher qual motor configurar e `KEY[2]` para navegar pelas etapas de ajuste. Ao pressionar o botão (`KEY[3]`), o bloco captura o valor binário presente nas chaves `SW` e gera um pulso de escrita direcionado aos registradores do motor selecionado;
- A partir dessas entradas, a MEF manda sinais para os LEDs da placa (`LEDR[3:0]`) indicando o modo e o subestado atuais (a fim de manter o usuário ciente de qual informação está inserindo), além de barramentos individuais de dados e coordenadas para cada motor gráfico.

### Gerenciador de Camadas (`MEF_geral_layer`) e Multiplexador (`MUX_Final`)

São os responsáveis por definir quem desenha, em que momento e qual camada fica por cima.

- Recebe o pulso de retorno vertical `vsync` vindo do driver VGA, os avisos de término de cada camada (`doneBg`, `donePol`, `doneSprt`) e os dados de cor com seus endereços calculados pelos motores;
- Para evitar que a tela seja alterada no meio da varredura visível, essa máquina de estados aguarda o monitor terminar o quadro ativo (`vsync`). A partir daí, autoriza o desenho em uma ordem pré setada de profundidade: primeiro o fundo, depois os polígonos e, por último, os sprites. O `MUX Final` chaveia o barramento para o motor que está ativo no momento e só ativa a gravação na memória (`wren`) se o pixel não for nulo, garantindo a transparência das camadas sobrepostas;
- O gerenciador de camadas leva os pulsos de habilitação para cada motor (`enableBg`, `enablePol`, `enableSprt`) e o barramento final de escrita direcionado à memória de vídeo, para permitir o desenho na tela VGA.

### Motor de Background(`motorBack_Ground`)

Responsável por montar o cenário de fundo da tela utilizando um mapa de blocos (tile map) e permitindo o efeito de rolagem da câmera.

- Recebe o sinal permitindo que desenhe `enableBg`, as coordenadas de rolagem da tela(scroll em X e Y) e os dados de alteração de tiles enviados pelo controlador;
- Varre linearmente as 76.800 posições da grade da tela. Em cada ponto, soma os deslocamentos de scroll para saber qual quadrante da matriz de 40 × 30 blocos está visível. Em seguida, busca o padrão de 8 × 8 pixels desse bloco na memória interna e extrai a cor exata daquele ponto;
- Gera como saída os dados de cor e o endereço para preencher a base do FrameBuffer e o pulso `doneBg` assim que concluir a varredura de toda a tela.

### Rasterizador de Polígonos (`motorPol` e `poligono_gerador`)

Calcula e preenche triângulos e quadriláteros através de circuitos aritméticos.

- Recebe o sinal de ativação `enablePol`, as coordenadas dos vértices inseridas pelo usuário, o valor da cor e a flag indicando o formato da figura;
- Então, testa os pixels da tela aplicando equações lineares de aresta. Utilizando operações matemáticas com sinal, o circuito avalia de que lado de cada aresta o ponto se encontra. Se o ponto estiver situado na área interna delimitada por todas as retas do polígono, a cor configurada é atribuída, caso contrário, gera cor transparente;
- Por fim, retorna os dados de cor e os endereços de memória dos pontos que compõem o polígono e o pulso `donePol` quando finaliza os testes geométricos. 

### Motor de Sprites (`motorSprites_Blitter`)

Encarregado dos sprites móveis na tela, sobrepondo os sprites salvos na memória com base em uma tabela de propriedades. Os sprite são representados por um banco de registradores, onde cada sprite é um registrador de 32 bits e cada registrador é numerado de 0 a 63, com o registrador 0 possuindo a maior prioridade, e o registrador 63 possuindo a menor prioridade.

- Recebe o sinal de início `enableSprt` e os dados de configuração de cada objeto (posição X, Y, identificador do padrão, visibilidade e flags de espelhamento);
- Então, percorre sequencialmente a tabela de atributos dos 32 sprites. Para cada sprite visível, o circuito estampa o bloco de 16 × 16 pixels calculando a posição de cada pixel na tela. Caso o usuário tenha ativado o espelhamento horizontal ou vertical, o hardware inverte a leitura das linhas ou colunas diretamente ao consultar a ROM;
- Por fim, gera como saída o fluxo de coordenadas e cores dos sprites para gravação na memória e o pulso `doneSprt` ao terminar de processar todas as entradas da tabela.

### FrameBuffer e Controlador VGA (`resolucao_logica` e `vga_driver`)

Armazena o resultado final do processamento e cuida de toda a temporização necessária para exibir a imagem no monitor.

- Recebe como entradas, na porta de gravação, os dados gerados pelos motores a 100 MHz; na porta de leitura, o clock de pixel de 25 MHz exigido pelo padrão de vídeo;
- A memória `RAMVIDEO`(implementada em blocos M10K) funciona com portas independentes, permitindo que a escrita das camadas ocorra sem interromper a exibição contínua. O bloco de resolução lógica lê os dados da grade de 320 × 240 e duplica as linhas e colunas (escala 2×2) para preencher a janela padrão de 640 × 480 a 60 Hz. Ao mesmo tempo, os contadores de sincronismo mantêm o feixe analógico perfeitamente alinhado;
- Gera como saídas os dados de cor analógica nos canais `VGA_R`, `VGA_G` e `VGA_B`, os pulsos de sincronismo `VGA_HS` e `VGA_VS`, o sinal de supressão `VGA_BLANK_N` e a realimentação do `vsync` para sincronizar o próximo ciclo de renderização.

# Manual do Usuário

## Requisitos:

- Placa de desenvolvimento DE1-SoC;
- Monitor compatível e cabo VGA conectados à placa;
- Computador com o software Quartus Prime instalado para interpretação e compilação do código Verilog.

## Instalação e configuração inicial do projeto:

- Faça o download de todo o conteúdo do repositório;
- Abra o software Quartus Prime, abra um projeto com o arquivo `CoprocessadorGrafico.qsf`;
- Verifique se a pinagem na placa DE1-SoC já está atribuída automaticamente;
- Defina o módulo `DE1_SOC_golden_top.v` como top-level;
- Caso faça alguma alteração no código e deseje recompilar, utilize a ferramenta Compile Design no Quartus.

## Programação na placa:

- Conecte a placa DE1-SoC no computador via USB;
- Conecte o monitor VGA à placa;
- No Quartus Prime, abra a ferramenta Programmer, clique em Add File, vá até a pasta do projeto e selecione arquivo compilado `CoprocessadorGrafico.sof`;
- Verifique se a placa foi reconhecida no Hardware Setup e clique em Start para transferir o código para a placa.
  
## Operação do CoProcessador e demonstração no monitor VGA:

- Para resetar o sistema, pressione `KEY[0]`;
- Para escolher qual modo entre background, polígonos ou sprites quer configurar, pressione `KEY[1]`.


| LEDS [0] e [1] | MODO |
|:--------------:|:----:|
| 00 | IDLE |
| 01 | Background |
| 10 |  Polígonos |
| 11 | Sprites |


- Para escolher qual subestado alterar, pressione `KEY[2]`dependendo do modo selecionado:
- No modo background,  o subestado 0 é a inserção da coordenada X, o subestado 1 é a inserção da coordenada Y, o subestado 2 é a inserção do padrão de desenho do tile e confirmar no botão e ação `KEY[3]`, e no subestado 3 é possível movimentar o tile apartir das chaves `SW[1:0]`; 
- No modo polígonos, o subestado 0 é o de seleção, para escolher qual dos 4 polígonos será editado e qual dos 4 pontos possíveis será inserida em seguida, o subestado 1 é a inserção da coordenada X, o subestado 3 é a inserção da coordenada Y, e o subestado 4 é o de configuração visual, para definir a cor, a visibilidade e o formato do polígono;
- No modo sprites, o subestado 0 é para a inserção da camada do sprite, os subestados 1 e 2 são para a inserção das coordenadas X e Y, respectivamente, e o subestado 3 é para a seleção da visibilidade e espelhamento do sprite.
- Para definir os valores dos parâmetros, ajuste as chaves `SW[9:0] da seguinte maneira:
	- No modo de background, utilize `SW[5:0]` no subestado de coordenada X para inserir a posição horizontal do tile (0 a 39), utilize `SW[4:0]` no subestado de coordenada Y para a posição vertical (0 a 29), utilize `SW[7:0]` no subestado de cor para definir o índice do padrão (0 a 255) e utilize `SW[1:0]`no subestado de movimentação para movimentar o background verticalmente ou horizontalmente;
	- No modo de polígonos, use `SW[1:0]` no subestado de seleção para escolher qual dos 4 polígonos alterar e o conjunto de chaves `SW[2:3]` para selecionar qual vértice atualizar, use `SW[8:0]` no subestado de coordenada X para definir a posição X na tela (0 a 319), use `SW[7:0]` no subestado da coordenada Y para definir a posição Y na tela (0 a 239), e use `SW[7:0]` para a cor, e as chaves isoladas `SW[8]` e `SW[9]` para ativar as visibilidade e o formato (triângulo ou polígono de 4 lados) respectivamente no subestado de configuração visual.
	- No modo de sprites, utilize `SW[5:0]` no subestado de índice para selecionar qual dos 64 sprites será configurado, utilize `SW[5:0]` no subestado de inserção da coordenada X e `SW[4:0]` no subestado de inserção da camada Y, e as chaves `SW[6]` para alterar a visibilidade, `SW[7]`para espelhamento no eixo Y e `SW[8]`para espelhamento do eixo X.
- Para gravar as alterações na tela, pressione o botão de ação KEY[3] para confirmar os valores inseridos nas chaves SW e atualizar a imagem projetada no monitor. 

# Referências 

Código do diagrama gerado no Gemini: https://gemini.google.com/

Diagrama montado no Mermaid AI a partir do código gerado: https://mermaid.ai/

Manual da placa (DE1-SoC) e do dispositivo Cyclone V pode ser consultados na página de [Recursos do LTEC3 - LEDS] https://sites.google.com/uefs.br/ltec3-leds/recursos


