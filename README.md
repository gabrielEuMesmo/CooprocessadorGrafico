# CoProcessador Gráfico

O seguinte CoProcessador Gráfico foi desenvolvido inspirado na arquitetura de consoles de 16 bits, possuindo três motores gráficos que trabalham em conjunto:
- Motor de background: responsável por apresentar uma camada de background na saída de vídeo, com 256 padrões diferentes disponíveis, permitir que cada tile seja alterado individualmente, além do deslocamento de cada camada de tile para as 4 direções;
- Motor de sprites: permite a inserção de, no máximo, 32 sprites de 16x16 pixels ao mesmo tempo na tela, com configuração de prioridade entre eles, deslocamento dos sprites pela tela para as 4 direções, espelhamento na horizontal e na vertical e definição de transparência;
- Rasterizador de polígonos: permite a inserção de um polígono 3 ou 4 lados na tela, dadas quaisquer 3 ou 4 coordenadas (x,y) diferentes, com a possibilidade de escolha da cor. 

O projeto foi criado para ser utilizado na plataforma de desenvolvimento De1-SoC, descrito totalmente na linguagem de descrição de hardware Verilog, através do ambiente de desenvolvimento Quartus Prime. Por fim, a saída de vídeo do projeto foi integrada a um monitor VGA (Video Graphics Array) conectado à placa.

# Manual do Sistema

Este projeto marca a primeira fase de um problema que tem como objetivo final o desenvolvimento de um console digital que deverá executar um jogo programado em linguagem C, exibido em um monitor VGA, no qual o jogador utilizará teclado e mouse conectados à placa DE1-SoC para interagir com as mecânicas do jogo final.

## Requisitos do problema

Foi requisitado pelo problema uma resolução lógica interna do cenários de 320x240 pixels, com duplicação pelo hardware para gerar o sinal da interface VGA operando em 640x480 pixels a 60Hz. Já para a geração de imagem, foi requisitado a criação de três motores com processamento visual contínuo: o motor de background, o motor de sprites e um rasterizador de polígonos. O motor de background 

# Manual do Usuário

## Requisitos:

- Placa de desenvolvimento DE1-SoC;
- Monitor compatível e cabo VGA conectados à placa;
- Computador com o software Quartus Prime instalado para interpretação e compilação do código Verilog.

## Instalação e configuração inicial do projeto:

- Faça o download de todo o conteúdo do repositório;
- Abra o software Quartus Prime, crie um novo projeto e abra o arquivo `CoprocessadorGrafico.qsf`;
- Verifique se a pinagem na placa DE1-SoC já está atribuida automaticamente;
- Defina o módulo `DE1_SOC_golden_top.v` como top-level;
- Caso faça alguma alteração no código e deseje recompilar, utilize a ferramenta Compile Design no Quartus.

## Programação na placa:

- Conecte a placa DE1-SoC no computador via USB;
- Conecte o monitor VGA à placa;
- No Quartus Prime, abra a ferramenta Programmer, clique em Add File, vá até a pasta do projeto e e selecione arquivo compilado `CoprocessadorGrafico.sof`;
- Verifique se a placa foi reconhecida no Hardware Setup e clique em Start para transferir o código para a placa.
  
## Operação do CoProcessador e demonstração no monitor VGA

