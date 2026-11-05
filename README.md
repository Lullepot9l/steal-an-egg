# Steal an Egg

Protótipo multiplayer para Roblox com compra, renda passiva e roubo de ovos.

## Jeito fácil: abrir direto

1. Baixe `StealAnEgg.rbxlx`.
2. Dê dois cliques no arquivo ou use **File > Open from File** no Roblox Studio.
3. Aperte **Play**.

Para recriar o arquivo após mudar os scripts, execute `node tools/build-place.mjs`.

## Desenvolvimento com Rojo

1. Instale o [Rojo](https://rojo.space/) e o plugin do Rojo no Roblox Studio.
2. Na pasta do projeto, execute `rojo serve`.
3. Abra um lugar vazio no Studio, conecte o plugin em `localhost:34872` e sincronize.
4. Use **Test > Start** com dois ou mais jogadores para testar o roubo.

O mapa é criado automaticamente pelo servidor. Para testar salvamento no Studio, publique a experiência e habilite **Game Settings > Security > Enable Studio Access to API Services**.

## Estrutura

- `src/shared/Config.lua`: preços, renda, cores e limites.
- `src/server/GameServer.server.lua`: mapa, bases, compra, roubo, renda e DataStore.
- `src/client/GameClient.client.lua`: HUD e instruções.
