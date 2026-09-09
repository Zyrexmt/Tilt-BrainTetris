# Tilt BrainTetris 🔄

Aplicativo mobile desenvolvido em Flutter como projeto teste da modalidade **#08 – Desenvolvimento de Aplicativos Móveis** (WorldSkills — Seletiva Estadual do Paraná), Módulo A1.

## 📱 Sobre o projeto

O BrainTetris é uma adaptação do clássico jogo Tetris, com cadastro de nome do jogador, ranking local de pontuações e uma mecânica de jogo baseada em movimentação de peças em um grid 6x10.

Esta é a versão que segue **fielmente a especificação original da prova**, com controle das peças por **inclinação física do dispositivo**, utilizando os sensores de acelerômetro e/ou giroscópio.

## 🎮 Controles

| Ação | Comando |
|---|---|
| Mover peça para a esquerda | Inclinar o dispositivo para a esquerda |
| Mover peça para a direita | Inclinar o dispositivo para a direita |
| Acelerar a queda da peça | Inclinar o dispositivo para frente |

- A cada inclinação detectada, a peça se move uma posição (grid) no sentido correspondente.
- A peça desce uma posição a cada 0.5s (tick padrão).
- Com o dispositivo inclinado para frente, a queda passa a ocorrer a cada 0.1s.
- Rotação de peças **não é exigida** pela especificação original e não está implementada nesta versão.

## 🖥️ Telas

- **Splash** — logo centralizada, barra/indicador de carregamento, 3s de exibição, navegação automática
- **Inicial** — campo para nome do jogador, botões "Iniciar" e "Ranking", validação de campo obrigatório
- **Ranking** — lista de pontuações ordenada de forma decrescente, armazenamento local, rolagem vertical
- **Jogo** — contagem regressiva de 3s, grid 6x10, queda automática de peças, controle por inclinação (acelerômetro/giroscópio), pontuação em tempo real, botão "Encerrar"

## 🎨 Paleta de cores

| Cor | Hex |
|---|---|
| Fundo claro | `#F7F7F7` |
| Fundo secundário | `#EDEDED` |
| Azul claro | `#AED6F1` |
| Verde água | `#A2DED0` |
| Texto/escuro | `#333333` |

## ⚙️ Tecnologias

- Flutter
- Sensores de movimento (acelerômetro/giroscópio)
- Armazenamento local (ranking persistido no dispositivo)

## 📦 Requisitos técnicos atendidos

- Orientação fixa em modo retrato (Portrait)
- Telas em tela cheia (fullscreen), sem ícones padrão do sistema
- Funcionamento 100% offline
- Sem rolagem horizontal em nenhuma tela
- Build final gerado em formato APK

## ▶️ Como executar

```bash
flutter pub get
flutter run
```

> Requer teste em dispositivo físico ou emulador com simulação de sensores, já que o controle depende de acelerômetro/giroscópio.

## 📝 Entrega

Desenvolvimento versionado via Git, com commits organizados por funcionalidade/tela conforme boas práticas de versionamento.
