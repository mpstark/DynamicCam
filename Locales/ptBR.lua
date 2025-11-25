local L = LibStub("AceLocale-3.0"):NewLocale("DynamicCam", "ptBR")
if not L then return end

-- Options
L["Reset"] = "Redefinir"
L["Reset to global default"] = "Usar padrão global"
L["(To restore the settings of a specific profile, restore the profile in the \"Profiles\" tab.)"] = "(Para restaurar as configurações de um perfil específico, restaure o perfil na aba \"Perfis\".)"
L["Currently overridden by the active situation \"%s\"."] = "Atualmente substituído pela situação ativa \"%s\"."
L["Override Standard Settings"] = "Sobrescrever Configurações Base"
L["<overrideStandardToggle_desc>"] = "Marcar esta caixa permite que você configure as configurações desta categoria. Estas Configurações de Situação sobrescrevem as Configurações Base assim que esta situação estiver ativa. Desmarcar a caixa apaga as Configurações de Situação para esta categoria."
L["Standard Settings"] = "Configurações Base"
L["Situation Settings"] = "Configurações de Situação"
L["<standardSettings_desc>"] = "Estas Configurações Base são aplicadas quando nenhuma situação está ativa ou quando a situação ativa não tem Configurações de Situação definidas que sobrescrevam as Configurações Base."
L["<standardSettingsOverridden_desc>"] = "Categorias marcadas em verde estão atualmente substituídas pela situação ativa. Portanto, você não verá nenhum efeito ao alterar as Configurações Base de categorias verdes enquanto a situação de substituição estiver ativa."
L["These Situation Settings override the Standard Settings when the respective situation is active."] = "Estas Configurações de Situação sobrescrevem as Configurações Base quando a respectiva situação está ativa."
L["Mouse Zoom"] = "Zoom do mouse"
L["Maximum Camera Distance"] = "Distância máxima da câmera"
L["How many yards the camera can zoom away from your character."] = "Quantas jardas a câmera pode se afastar do seu personagem."
L["Camera Zoom Speed"] = "Velocidade do zoom da câmera"
L["How fast the camera can zoom."] = "Quão rápido a câmera pode dar zoom."
L["Zoom Increments"] = "Incrementos do zoom"
L["How many yards the camera should travel for each \"tick\" of the mouse wheel."] = "Quantas jardas a câmera deve viajar a cada \"tick\" da roda do mouse."
L["Use Reactive Zoom"] = "Usar Zoom Reativo"
L["Quick-Zoom Additional Increments"] = "Incrementos Adicionais do Quick-Zoom"
L["How many yards per mouse wheel \"tick\" should be added when quick-zooming."] = "Quantas jardas por \"tick\" da roda do mouse devem ser adicionadas ao usar quick-zoom."
L["Quick-Zoom Enter Threshold"] = "Limiar de Entrada do Quick-Zoom"
L["How many yards the \"Reactive Zoom Target\" and the \"Current Zoom Value\" have to be apart to enter quick-zooming."] = "Quantas jardas o \"Alvo de Zoom Reativo\" e o \"Valor de Zoom Atual\" precisam estar separados para entrar no quick-zoom."
L["Maximum Zoom Time"] = "Tempo Máximo do Zoom"
L["The maximum time the camera should take to make \"Current Zoom Value\" equal to \"Reactive Zoom Target\"."] = "O tempo máximo que a câmera deve levar para fazer o \"Valor de Zoom Atual\" ser igual ao \"Alvo de Zoom Reativo\"."
L["Help"] = "Ajuda"
L["Toggle Visual Aid"] = "Alternar Auxílio Visual"
L["<reactiveZoom_desc>"] = "Com o Zoom Reativo do DynamicCam, a roda do mouse controla o chamado \"Alvo de Zoom Reativo\". Sempre que o \"Alvo de Zoom Reativo\" e o \"Valor de Zoom Atual\" são diferentes, o DynamicCam altera o \"Valor de Zoom Atual\" até que ele corresponda novamente ao \"Alvo de Zoom Reativo\".\n\nA rapidez com que essa mudança de zoom ocorre depende da \"Velocidade do zoom da câmera\" e do \"Tempo Máximo do Zoom\". Se o \"Tempo Máximo do Zoom\" estiver baixo, a mudança de zoom sempre será executada rapidamente, independentemente da configuração da \"Velocidade do zoom da câmera\". Para obter uma mudança de zoom mais lenta, você deve definir o \"Tempo Máximo do Zoom\" para um valor mais alto e a \"Velocidade do zoom da câmera\" para um valor mais baixo.\n\nPara permitir um zoom mais rápido com um movimento mais rápido da roda do mouse, existe o \"Quick-Zoom\": se o \"Alvo de Zoom Reativo\" estiver mais distante do \"Valor de Zoom Atual\" do que o \"Limiar de Entrada do Quick-Zoom\", a quantidade de \"Incrementos Adicionais do Quick-Zoom\" é adicionada a cada tick da roda do mouse.\n\nPara ter uma ideia de como isso funciona, você pode alternar o auxílio visual enquanto encontra suas configurações ideais. Você também pode mover livremente este gráfico clicando com o botão esquerdo e arrastando-o. Um clique com o botão direito o fecha."
L["Enhanced minimal zoom-in"] = "Zoom mínimo aprimorado"
L["<enhancedMinZoom_desc>"] = "O zoom reativo torna possível aproximar mais do que o nível 1. Você pode conseguir isso afastando a roda do mouse um tick a partir da primeira pessoa.\n\nCom o \"Zoom mínimo aprimorado\", forçamos a câmera a parar também neste nível mínimo de zoom ao aproximar, antes que ela salte para a primeira pessoa.\n\n|cFFFF0000Ativar o \"Zoom mínimo aprimorado\" pode custar até 15% de FPS em situações limitadas pela CPU.|r"
L["/reload of the UI required!"] = "É necessário /reload da interface!"
L["Mouse Look"] = "Giro do mouse"
L["Horizontal Speed"] = "Velocidade Horizontal"
L["How much the camera yaws horizontally when in mouse look mode."] = "Quanto a câmera gira horizontalmente quando no modo giro do mouse."
L["Vertical Speed"] = "Velocidade Vertical"
L["How much the camera pitches vertically when in mouse look mode."] = "Quanto a câmera inclina verticalmente quando no modo giro do mouse."
L["<mouseLook_desc>"] = "Quanto a câmera se move quando você move o mouse no modo \"giro do mouse\"; ou seja, enquanto o botão esquerdo ou direito do mouse está pressionado.\n\nO controle deslizante \"Giro do mouse\" das configurações de interface padrão do WoW controla a velocidade horizontal e vertical ao mesmo tempo: definindo automaticamente a velocidade horizontal para 2 x a velocidade vertical. O DynamicCam substitui isso e permite uma configuração mais personalizada."
L["Horizontal Offset"] = "Deslocamento Horizontal"
L["Camera Over Shoulder Offset"] = "Deslocamento da Câmera Acima do Ombro"
L["Positions the camera left or right from your character."] = "Posiciona a câmera à esquerda ou à direita do seu personagem."
L["<cameraOverShoulder_desc>"] = "Para que isso entre em vigor, DynamicCam desativa automaticamente e temporariamente a configuração de Vertigem de movimento do WoW. Portanto, se você precisar da configuração de Vertigem de movimento, não use o deslocamento horizontal nestas situações.\n\nQuando você seleciona seu próprio personagem, o WoW centraliza a câmera automaticamente. Não há nada que possamos fazer a respeito. Também não podemos fazer nada sobre solavancos de deslocamento que podem ocorrer em colisões da câmera com a parede. Uma solução é usar pouco ou nenhum deslocamento dentro de edifícios.\n\nAlém disso, o WoW estranhamente aplica o deslocamento de forma diferente dependendo do modelo do personagem ou da montaria. Para todos que preferem um deslocamento permanente, Ludius está trabalhando em outro addon («CameraOverShoulder Fix») para resolver isso."
L["Adjust shoulder offset according to zoom level"] = "Ajustar deslocamento de acordo com o nível de zoom"
L["Enable"] = "Ativar"
L["and"] = "e"
L["No offset when below this zoom level:"] = "Sem deslocamento abaixo deste nível de zoom:"
L["When the camera is closer than this zoom level, the offset has reached zero."] = "Quando a câmera está mais próxima do que este nível de zoom, o deslocamento é zero."
L["Real offset when above this zoom level:"] = "Deslocamento total acima deste nível de zoom:"
L["When the camera is further away than this zoom level, the offset has reached its set value."] = "Quando a câmera está mais distante do que este nível de zoom, o deslocamento atingiu o valor definido."
L["<shoulderOffsetZoom_desc>"] = "Faz com que o deslocamento acima do ombro transicione gradualmente para zero ao aproximar o zoom. Os dois controles deslizantes definem entre quais níveis de zoom essa transição ocorre. Esta configuração é global e não específica à situação."
L["Vertical Pitch"] = "Inclinação vertical"
L["Pitch (on ground)"] = "Inclinação (no solo)"
L["Pitch (flying)"] = "Inclinação (voando)"
L["Down Scale"] = "Fator de Redução"
L["Smart Pivot Cutoff Distance"] = "Distância Limite do Pivô Inteligente"
L["<pitch_desc>"] = "Se a câmera estiver inclinada para cima (valor de \"Inclinação\" mais baixo), o \"Fator de Redução\" determina o quanto isso afeta ao olhar para o seu personagem de cima. Definir o \"Fator de Redução\" como 0 anula o efeito de uma inclinação para cima ao olhar de cima. Pelo contrário, o \"Fator de Redução\" tem pouco ou nenhum efeito quando você não está olhando de cima ou se a câmera está inclinada para baixo (valor de \"Inclinação\" mais alto).\n\nPortanto, você deve primeiro encontrar sua configuração preferida de \"Inclinação\" olhando para o seu personagem por trás. Depois de optar por uma inclinação para cima, encontre sua configuração preferida de \"Fator de Redução\" olhando de cima.\n\n\nQuando a câmera colide com o chão, ela normalmente realiza uma inclinação para cima no local da colisão câmera-solo. Uma alternativa é a câmera se mover para mais perto dos pés do seu personagem enquanto realiza essa inclinação. A \"Distância Limite do Pivô Inteligente\" determina a distância que a câmera precisa estar do seu personagem para que isso aconteça. Com um valor de 0, a câmera nunca se aproxima (padrão do WoW). No entanto, no valor máximo de 39, ela sempre o faz.\n\n"
L["Target Focus"] = "Foco no Alvo"
L["Enemy Target"] = "Alvo Inimigo"
L["Horizontal Strength"] = "Força Horizontal"
L["Vertical Strength"] = "Força Vertical"
L["Interaction Target (NPCs)"] = "Alvo de Interação (NPCs)"
L["<targetFocus_desc>"] = "Se ativado, a câmera tenta automaticamente trazer o alvo para mais perto do centro da tela. A força determina a intensidade desse efeito.\n\nSe \"Alvo Inimigo\" e \"Alvo de Interação\" estiverem ambos ativados, parece haver um bug estranho com o último: ao interagir com um NPC pela primeira vez, a câmera se move suavemente para seu novo ângulo conforme o esperado. Mas quando você sai da interação, ela salta imediatamente para o ângulo anterior. Se você iniciar a interação novamente, ela salta bruscamente para o novo ângulo. Isso é repetível sempre que se fala com um novo NPC: apenas a primeira transição é suave, todas as seguintes são imediatas.\nUma solução alternativa, se você quiser usar tanto \"Alvo Inimigo\" quanto \"Alvo de Interação\", é ativar \"Alvo Inimigo\" apenas para situações do DynamicCam nas quais você precisa dele e nas quais interações com NPCs são improváveis (como em Combate)."
L["Head Tracking"] = "Rastreamento de Cabeça"
L["<headTrackingEnable_desc>"] = "(Isso também poderia ser usado como um valor contínuo entre 0 e 1, mas é apenas multiplicado por \"Força (parado)\" e \"Força (movendo)\" respectivamente. Portanto, não há realmente necessidade de outro controle deslizante.)"
L["Strength (standing)"] = "Força (parado)"
L["Inertia (standing)"] = "Inércia (parado)"
L["Strength (moving)"] = "Força (movendo)"
L["Inertia (moving)"] = "Inércia (movendo)"
L["Inertia (first person)"] = "Inércia (primeira pessoa)"
L["Range Scale"] = "Escala de Alcance"
L["Camera distance beyond which head tracking is reduced or disabled. (See explanation below.)"] = "Distância da câmera além da qual o rastreamento de cabeça é reduzido ou desativado. (Veja explicação abaixo.)"
L["(slider value transformed)"] = "(valor do controle deslizante transformado)"
L["Dead Zone"] = "Zona Morta"
L["Radius of head movement not affecting the camera. (See explanation below.)"] = "Raio do movimento da cabeça que não afeta a câmera. (Veja explicação abaixo.)"
L["(slider value devided by 10)"] = "(valor do controle deslizante dividido por 10)"
L["Requires /reload to come into effect!"] = "Requer /reload para entrar em vigor!"
L["<headTracking_desc>"] = "Com o rastreamento de cabeça ativado, a câmera segue o movimento da cabeça do seu personagem. (Embora isso possa ser um benefício para a imersão, também pode causar náusea se você for propenso a vertigem de movimento.)\n\nA configuração \"Força\" determina a intensidade desse efeito. Um valor de 0 desativa o rastreamento de cabeça. A configuração \"Inércia\" determina o quão rápido a câmera reage aos movimentos da cabeça. Um valor de 0 também desativa o rastreamento de cabeça. Os três casos \"parado\", \"movendo\" e \"primeira pessoa\" podem ser configurados individualmente. Não há configuração de \"Força\" para \"primeira pessoa\", pois ela assume as configurações de \"Força\" de \"parado\" e \"movendo\", respectivamente. Se você quiser ativar ou desativar apenas a \"primeira pessoa\", use os controles deslizantes de \"Inércia\" para desativar os casos indesejados.\n\nCom a configuração \"Escala de Alcance\", você pode definir a distância da câmera além da qual o rastreamento de cabeça é reduzido ou desativado. Por exemplo, com o controle deslizante definido em 30, você não terá rastreamento de cabeça quando a câmera estiver a mais de 30 jardas do seu personagem. No entanto, há uma transição gradual de rastreamento total para nenhum rastreamento, que começa em um terço do valor do controle deslizante. Por exemplo, se o valor estiver definido em 30, você terá rastreamento total quando a câmera estiver a menos de 10 jardas. Além de 10 jardas, o rastreamento de cabeça diminui gradualmente até desaparecer completamente além de 30 jardas. Portanto, o valor máximo de 117 permite rastreamento total na distância máxima da câmera de 39 jardas. (Dica: Use o auxílio visual do DynamicCam para \"Zoom do mouse\" para saber a distância atual da câmera durante a configuração.)\n\nA configuração \"Zona Morta\" pode ser usada para ignorar movimentos menores da cabeça. Um valor de 0 faz com que a câmera siga cada movimento mínimo da cabeça, enquanto um valor maior faz com que ela siga apenas movimentos maiores. Observe que a alteração desta configuração só entra em vigor após recarregar a interface (digite /reload no console)."
L["Situations"] = "Situações"
L["Select a situation to setup"] = "Selecione uma situação para configurar"
L["<selectedSituation_desc>"] = "\n|cffffcc00Códigos de cores:|r\n|cFF808A87- Situação desativada.|r\n- Situação ativada.\n|cFF00FF00- Situação ativada e atualmente ativa.|r\n|cFF63B8FF- Situação ativada com condição atendida, mas prioridade menor que a situação atualmente ativa.|r\n|cFFFF6600- \"Controles de Situação\" originais modificados (redefinição recomendada).|r\n|cFFEE0000- \"Controles de Situação\" errôneos (correção necessária).|r"
L["If this box is checked, DynamicCam will enter the situation \"%s\" whenever its condition is fulfilled and no other situation with higher priority is active."] = "Se esta caixa estiver marcada, o DynamicCam entrará na situação \"%s\" sempre que sua condição for atendida e nenhuma outra situação com maior prioridade estiver ativa."
L["Custom:"] = "Personalizada:"
L["(modified)"] = "(modificada)"
L["Delete custom situation \"%s\".\n|cFFEE0000Attention: There will be no 'Are you sure?' prompt!|r"] = "Excluir situação personalizada \"%s\".\n|cFFEE0000Atenção: Não haverá aviso de \"Tem certeza?\"!|r"
L["Create a new custom situation."] = "Criar uma nova situação personalizada."
L["Situation Actions"] = "Ações da Situação"
L["Setup stuff to happen while in a situation or when entering/exiting it."] = "Configurar coisas para acontecer enquanto estiver em uma situação ou ao entrar/sair dela."
L["Zoom/View"] = "Zoom/Visão"
L["Zoom to a certain zoom level or switch to a saved camera view when entering this situation."] = "Dar zoom para um certo nível ou mudar para uma visão de câmera salva ao entrar nesta situação."
L["Set Zoom or Set View"] = "Definir Zoom ou Visão"
L["Zoom Type"] = "Tipo de Zoom"
L["<viewZoomType_desc>"] = "Definir Zoom: Dar zoom para um nível dado com opções avançadas de tempo de transição e condições.\n\nDefinir Visão: Mudar para uma visão de câmera salva que consiste em um nível de zoom e ângulo fixos."
L["Set Zoom"] = "Definir Zoom"
L["Set View"] = "Definir Visão"
L["Set view to saved view:"] = "Definir visão para visão salva:"
L["Select the saved view to switch to when entering this situation."] = "Selecione a visão salva para mudar ao entrar nesta situação."
L["Instant"] = "Instantâneo"
L["Make view transitions instant."] = "Tornar as transições de visão instantâneas."
L["Restore view when exiting"] = "Restaurar visão ao sair"
L["When exiting the situation restore the camera position to what it was at the time of entering the situation."] = "Ao sair da situação, a posição da câmera é restaurada para o que era no momento de entrar na situação."
L["cameraSmoothNote"] = [[|cFFEE0000Atenção:|r Você está usando o "Estilo de acompanhamento da câmera" do WoW que coloca automaticamente a câmera atrás do jogador. Isso não funciona enquanto você está em uma visão salva personalizada. É possível usar visões salvas personalizadas para situações em que o acompanhamento não é necessário (ex: interação com NPC). Mas depois de sair da situação você deve retornar a uma visão padrão não personalizada para que o acompanhamento da câmera funcione novamente.]]
L["Restore to default view:"] = "Restaurar para visão padrão:"
L["<viewRestoreToDefault_desc>"] = [[Selecione a visão padrão para retornar ao sair desta situação.

Visão 1:   Zoom 0, Inclinação 0
Visão 2:   Zoom 5.5, Inclinação 10
Visão 3:   Zoom 5.5, Inclinação 20
Visão 4:   Zoom 13.8, Inclinação 30
Visão 5:   Zoom 13.8, Inclinação 10]]
L["WARNING"] = "AVISO"
L["You are using the same view as saved view and as restore-to-default view. Using a view as restore-to-default view will reset it. Only do this if you really want to use it as a non-customized saved view."] = "Sua visão salva a ser definida é a mesma que sua visão padrão a ser restaurada. Se uma visão for usada para restaurar ao padrão, ela será redefinida. Faça isso apenas se você realmente quiser usá-la como uma visão salva não personalizada."
L["View %s is used as saved view in the situations:\n%sand as restore-to-default view in the situations:\n%s"] = "A visão %s é usada como visão salva nas situações:\n%se como visão para restaurar ao padrão nas situações:\n%s"
L["<view_desc>"] = [[O WoW permite salvar até 5 visões de câmera personalizadas. A Visão 1 é usada pelo DynamicCam para salvar a posição da câmera ao entrar em uma situação, para que possa ser restaurada ao sair da situação, se você marcar a caixa "Restaurar" acima. Isso é particularmente útil para situações curtas como interação com NPC, permitindo mudar para uma visão enquanto fala com o NPC e depois voltar para como a câmera estava antes. É por isso que a Visão 1 não pode ser selecionada no menu suspenso de visões salvas acima.

As Visões 2, 3, 4 e 5 podem ser usadas para salvar posições de câmera personalizadas. Para salvar uma visão, simplesmente coloque a câmera no zoom e ângulo desejados. Em seguida, digite o seguinte comando no console (onde # é o número da visão 2, 3, 4 ou 5):

  /saveView #

Ou abreviado:

  /sv #

Note que as visões salvas são armazenadas pelo WoW. O DynamicCam armazena apenas quais números de visão usar. Portanto, quando você importa um novo perfil de situações do DynamicCam com visões, você provavelmente terá que configurar e salvar as visões apropriadas depois.


O DynamicCam também fornece um comando de console para mudar para uma visão independentemente de entrar ou sair de situações:

  /setView #

Para tornar a transição de visão instantânea, adicione um "i" após o número da visão. Ex: para mudar imediatamente para a Visão salva 3 digite:

  /setView 3 i

]]
L["Zoom Transition Time"] = "Tempo de Transição de Zoom"
L["<transitionTime_desc>"] = "O tempo em segundos que leva para transicionar para o novo valor de zoom.\n\nSe definido mais baixo do que o possível, a transição será tão rápida quanto a velocidade de zoom atual da câmera permitir (ajustável nas configurações de \"Zoom do mouse\" do DynamicCam).\n\nSe uma situação atribuir a variável \"this.transitionTime\" em seu script de entrada (veja \"Controles de Situação\"), a configuração aqui é substituída. Isso é feito ex. na situação \"Pedra de Regresso/Teletransporte\" para permitir um tempo de transição pela duração do lançamento do feitiço."
L["<zoomType_desc>"] = "\nDefinir: Sempre define o zoom para este valor.\n\nAfastar: Apenas define o zoom se a câmera estiver atualmente mais próxima do que isso.\n\nAproximar: Apenas define o zoom se a câmera estiver atualmente mais distante do que isso.\n\nIntervalo: Aproxima se mais distante que o máximo dado. Afasta se mais próximo que o mínimo dado. Não faz nada se o zoom atual estiver dentro do intervalo [min, max]."
L["Set"] = "Definir"
L["Out"] = "Afastar"
L["In"] = "Aproximar"
L["Range"] = "Intervalo"
L["Don't slow"] = "Não desacelerar"
L["Zoom transitions may be executed faster (but never slower) than the specified time above, if the \"Camera Zoom Speed\" (see \"Mouse Zoom\" settings) allows."] = "As transições de zoom podem ser executadas mais rápido (mas nunca mais devagar) do que o tempo especificado acima, se a \"Velocidade de zoom da câmera\" (veja configurações de \"Zoom do mouse\") permitir."
L["Zoom Value"] = "Valor de Zoom"
L["Zoom to this zoom level."] = "Dar zoom para este nível."
L["Zoom out to this zoom level, if the current zoom level is less than this."] = "Afastar para este nível, se o nível atual for menor."
L["Zoom in to this zoom level, if the current zoom level is greater than this."] = "Aproximar para este nível, se o nível atual for maior."
L["Zoom Min"] = "Zoom Mín"
L["Zoom Max"] = "Zoom Máx"
L["Restore Zoom"] = "Restaurar Zoom"
L["<zoomRestoreSetting_desc>"] = "Quando você sai de uma situação (ou sai do estado padrão de nenhuma situação ativa), o nível de zoom atual é salvo temporariamente, para que possa ser restaurado assim que você entrar nesta situação na próxima vez. Aqui você pode selecionar como isso é tratado.\n\nEsta configuração é global para todas as situações."
L["Restore Zoom Mode"] = "Modo de Restauração de Zoom"
L["<zoomRestoreSettingSelect_desc>"] = "\nNunca: Ao entrar em uma situação, a configuração de zoom real (se houver) da situação de entrada é aplicada. Nenhum zoom salvo é levado em conta.\n\nSempre: Ao entrar em uma situação, o último zoom salvo desta situação é usado. Sua configuração real só é levada em conta ao entrar na situação pela primeira vez após o login.\n\nAdaptável: O zoom salvo é usado apenas sob certas circunstâncias. Ex: apenas ao retornar para a mesma situação de onde você veio ou quando o zoom salvo cumpre os critérios das configurações de zoom \"Aproximar\", \"Afastar\" ou \"Intervalo\" da situação."
L["Never"] = "Nunca"
L["Always"] = "Sempre"
L["Adaptive"] = "Adaptável"
L["<zoom_desc>"] = [[Para determinar o nível de zoom atual, você pode usar o "Auxílio Visual" (alternado nas configurações de "Zoom do mouse" do DynamicCam) ou usar o comando do console:

  /zoomInfo

Ou abreviado:

  /zi]]
L["Rotation"] = "Rotação"
L["Start a camera rotation when this situation is active."] = "Iniciar uma rotação de câmera quando esta situação estiver ativa."
L["Rotation Type"] = "Tipo de Rotação"
L["<rotationType_desc>"] = "\nContinuamente: A câmera gira horizontalmente o tempo todo enquanto esta situação está ativa. Aconselhável apenas para situações em que você não está movendo a câmera com o mouse; ex: lançamento de feitiço de teletransporte, táxi ou ausente (AFK). A rotação vertical contínua não é possível, pois pararia na visão perpendicular de cima ou de baixo.\n\nPor Graus: Após entrar na situação, altere a guinada (horizontal) e/ou inclinação (vertical) atual da câmera pela quantidade de graus dada."
L["Continuously"] = "Continuamente"
L["By Degrees"] = "Por Graus"
L["Acceleration Time"] = "Tempo de Aceleração"
L["Rotation Time"] = "Tempo de Rotação"
L["<accelerationTime_desc>"] = "Se você definir um tempo maior que 0 aqui, a rotação contínua não começará imediatamente em sua velocidade total, mas levará esse tempo para acelerar. (Perceptível apenas para velocidades de rotação relativamente altas.)"
L["<rotationTime_desc>"] = "Quanto tempo deve levar para assumir o novo ângulo da câmera. Se um valor muito pequeno for fornecido aqui, a câmera pode girar demais, porque verificamos apenas uma vez por quadro renderizado se o ângulo desejado foi alcançado.\n\nSe uma situação atribuir a variável \"this.rotationTime\" em seu script de entrada (veja \"Controles de Situação\"), a configuração aqui é substituída. Isso é feito ex. na situação \"Pedra de Regresso/Teletransporte\" para permitir um tempo de rotação pela duração do lançamento do feitiço."
L["Rotation Speed"] = "Velocidade de Rotação"
L["Speed at which to rotate in degrees per second. You can manually enter values between -900 and 900, if you want to get yourself really dizzy..."] = "Velocidade na qual girar em graus por segundo. Você pode inserir manualmente valores entre -900 e 900, se quiser ficar realmente tonto..."
L["Yaw (-Left/Right+)"] = "Guinada (-Esquerda/Direita+)"
L["Degrees to yaw (left or right)."] = "Graus para guinar (esquerda ou direita)."
L["Pitch (-Down/Up+)"] = "Inclinação (-Baixo/Cima+)"
L["Degrees to pitch (up or down). There is no going beyond the perpendicular upwards or downwards view."] = "Graus para inclinar (cima ou baixo). Não há como ir além da visão perpendicular de cima ou de baixo."
L["Rotate Back"] = "Rotação de Retorno"
L["<rotateBack_desc>"] = "Ao sair da situação, gire de volta pela quantidade de graus (módulo 360) girados desde a entrada na situação. Isso efetivamente traz você para a posição da câmera antes da entrada, a menos que você tenha alterado o ângulo de visão com o mouse nesse meio tempo.\n\nSe você estiver entrando em uma nova situação com uma configuração de rotação própria, a \"Rotação de Retorno\" da situação de saída é ignorada."
L["Rotate Back Time"] = "Tempo de Rotação de Retorno"
L["<rotateBackTime_desc>"] = "O tempo que leva para girar de volta. Se um valor muito pequeno for fornecido aqui, a câmera pode girar demais, porque verificamos apenas uma vez por quadro renderizado se o ângulo desejado foi alcançado."
L["Fade Out UI"] = "Ocultar Interface"
L["Fade out or hide (parts of) the UI when this situation is active."] = "Desvanece ou oculta (partes da) interface quando esta situação está ativa."
L["Adjust to Immersion"] = "Ajustar para Immersion"
L["<adjustToImmersion_desc>"] = "Muitas pessoas usam o addon Immersion em combinação com o DynamicCam. O Immersion tem alguns recursos próprios de ocultar a interface que entram em vigor durante a interação com NPCs. Sob certas circunstâncias, a ocultação de interface do DynamicCam substitui a do Immersion. Para evitar isso, faça as configurações desejadas aqui no DynamicCam. Clique neste botão para usar os mesmos tempos de aparecimento e desaparecimento do Immersion. Para ainda mais opções, confira o outro addon do Ludius chamado \"Immersion ExtraFade\"."
L["Fade Out Time"] = "Tempo de Desaparecimento"
L["Seconds it takes to fade out the UI when entering the situation."] = "Segundos que leva para a interface desaparecer ao entrar na situação."
L["Fade In Time"] = "Tempo de Aparecimento"
L["<fadeInTime_desc>"] = "Segundos que leva para a interface reaparecer ao sair da situação.\n\nQuando você transita entre duas situações que ocultam a interface, o tempo de desaparecimento da situação de entrada é usado para a transição."
L["Hide entire UI"] = "Ocultar toda a interface"
L["<hideEntireUI_desc>"] = "Há uma diferença entre uma interface \"oculta\" e uma \"apenas desvanecida\": os elementos da interface desvanecidos têm uma opacidade de 0, mas ainda podem ser interagidos. Desde o DynamicCam 2.0, ocultamos automaticamente a maioria dos elementos da interface se sua opacidade for 0. Portanto, esta opção de ocultar toda a interface após o desvanecimento é mais uma relíquia. Um motivo para ainda usá-la pode ser evitar interações indesejadas (ex: dicas de ferramenta ao passar o mouse) de elementos da interface que o DynamicCam ainda não oculta corretamente.\n\nA opacidade da interface oculta é, obviamente, 0, então você não pode escolher uma opacidade diferente nem manter quaisquer elementos da interface visíveis (exceto o indicador de FPS).\n\nDurante o combate, não podemos alterar o status oculto de elementos protegidos da interface. Portanto, tais elementos são sempre \"apenas desvanecidos\" durante o combate. Observe que a opacidade dos \"pontos\" no minimapa não pode ser reduzida. Assim, se você tentar ocultar o minimapa, os \"pontos\" estarão sempre visíveis durante o combate.\n\nQuando você marca esta caixa para a situação atualmente ativa, ela não será aplicada de uma vez, porque isso também ocultaria este quadro de configurações. Você tem que entrar na situação para que entre em vigor, o que também é possível com a caixa de seleção \"Ativar\" da situação acima.\n\nObserve também que ocultar toda a interface cancela interações com a Caixa de Correio ou NPCs. Portanto, não use isso para tais situações!"
L["Keep FPS indicator"] = "Manter indicador de FPS"
L["Do not fade out or hide the FPS indicator (the one you typically toggle with Ctrl + R)."] = "Não desvanecer ou ocultar o indicador de FPS (aquele que você normalmente alterna com Ctrl + R)."
L["Fade Opacity"] = "Opacidade do Desvanecimento"
L["Fade the UI to this opacity when entering the situation."] = "Desvanece a interface para esta opacidade ao entrar na situação."
L["Excluded UI elements"] = "Elementos da interface excluídos"
L["Keep Alerts"] = "Manter Alertas"
L["Still show alert popups from completed achievements, Covenant Renown, etc."] = "Ainda mostrar pop-ups de alerta de conquistas concluídas, Renome do Pacto, etc."
L["Keep Tooltip"] = "Manter Dica de Ferramenta"
L["Still show the game tooltip, which appears when you hover your mouse cursor over UI or world elements."] = "Ainda mostrar a dica de ferramenta do jogo, que aparece quando você passa o cursor do mouse sobre elementos da interface ou do mundo."
L["Keep Minimap"] = "Manter Minimapa"
L["<keepMinimap_desc>"] = "Não desvanecer o minimapa.\n\nObserve que não podemos reduzir a opacidade dos \"pontos\" no minimapa. Estes só podem ser ocultos juntamente com todo o minimapa, quando a interface é desvanecida para 0 de opacidade."
L["Keep Chat Box"] = "Manter Caixa de Chat"
L["Do not fade out the chat box."] = "Não desvanecer a caixa de chat."
L["Keep Tracking Bar"] = "Manter barra de experiência/reputação"
L["Do not fade out the tracking bar (XP, AP, reputation)."] = "Não desvanecer a barra de experiência/reputação (XP, AP, reputação)."
L["Keep Party/Raid"] = "Manter Grupo/Raide"
L["Do not fade out the Party/Raid frame."] = "Não desvanecer o quadro de Grupo/Raide."
L["Keep Encounter Frame (Skyriding Vigor)"] = "Manter Quadro de Encontro (Vigor de Voar nos Céus)"
L["Do not fade out the Encounter Frame, which while skyriding is the Vigor display."] = "Não desvanecer o Quadro de Encontro, que enquanto voa nos céus é a exibição de Vigor."
L["Keep additional frames"] = "Manter quadros adicionais"
L["<keepCustomFrames_desc>"] = "A caixa de texto abaixo permite definir qualquer quadro que você queira manter durante a interação com NPCs.\n\nUse o comando do console /fstack para saber os nomes dos quadros.\n\nPor exemplo, você pode querer manter os ícones de buffs ao lado do minimapa para poder desmontar durante a interação com NPCs clicando no ícone apropriado."
L["Custom frames to keep"] = "Quadros personalizados para manter"
L["Separated by commas."] = "Separados por vírgulas."
L["Emergency Fade In"] = "Reaparecimento de Emergência"
L["Pressing Esc fades the UI back in."] = "Pressionar Esc faz a interface reaparecer."
L["<emergencyShow_desc>"] = [[Às vezes você precisa mostrar a interface mesmo em situações onde normalmente deseja que ela esteja oculta. Versões antigas do DynamicCam estabeleceram que a interface é mostrada sempre que a tecla Esc é pressionada. A desvantagem disso é que a interface também é mostrada quando a tecla Esc é usada para outros fins, como fechar janelas, cancelar lançamento de feitiços, etc. Desmarcar a caixa acima desativa isso.

Observe, no entanto, que você pode ficar trancado fora da interface dessa maneira! Uma alternativa melhor à tecla Esc são os seguintes comandos de console, que mostram ou ocultam a interface de acordo com as configurações de "Ocultar Interface" da situação atual:

    /showUI
    /hideUI

Para uma tecla de atalho de reaparecimento conveniente, coloque /showUI em uma macro e atribua uma tecla a ela em seu arquivo "bindings-cache.wtf". Ex:

    bind ALT+F11 MACRO Nome Da Sua Macro

Se editar o arquivo "bindings-cache.wtf" o assusta, você pode usar um addon de atalhos como o "BindPad".

Usar /showUI ou /hideUI sem argumentos assume o tempo de aparecimento ou desaparecimento da situação atual. Mas você também pode fornecer um tempo de transição diferente. Ex:

    /showUI 0

para mostrar a interface sem qualquer atraso.]]
L["<hideUIHelp_desc>"] = "Ao configurar seus efeitos de desvanecimento de interface desejados, pode ser irritante quando este quadro de configurações de \"Interface\" também desaparece. Se esta caixa estiver marcada, ele não será desvanecido.\n\nEsta configuração é global para todas as situações."
L["Do not fade out this \"Interface\" settings frame."] = "Não desvanecer este quadro de configurações de \"Interface\"."
L["Situation Controls"] = "Controles de Situação"
L["<situationControls_help>"] = "Aqui você controla quando uma situação está ativa. Conhecimento da API da interface do WoW pode ser necessário. Se você está feliz com as situações originais do DynamicCam, apenas ignore esta seção. Mas se você quiser criar situações personalizadas, pode verificar as situações originais aqui. Você também pode modificá-las, mas cuidado: suas configurações alteradas persistirão mesmo se versões futuras do DynamicCam introduzirem atualizações importantes.\n\n"
L["Priority"] = "Prioridade"
L["The priority of this situation.\nMust be a number."] = "A prioridade desta situação.\nDeve ser um número."
L["Restore stock setting"] = "Restaurar configuração original"
L["Your \"Priority\" deviates from the stock setting for this situation (%s). Click here to restore it."] = "Sua \"Prioridade\" desvia da configuração original para esta situação (%s). Clique aqui para restaurá-la."
L["<priority_desc>"] = "Se as condições de várias situações diferentes do DynamicCam forem atendidas ao mesmo tempo, a situação com a maior prioridade é inserida. Por exemplo, sempre que a condição de \"Mundo (Interiores)\" for atendida, a condição de \"Mundo\" também é atendida. Mas como \"Mundo (Interiores)\" tem uma prioridade maior que \"Mundo\", ela é priorizada. Você também pode ver as prioridades de todas as situações no menu suspenso acima.\n\n"
L["Error message:"] = "Mensagem de erro:"
L["Events"] = "Eventos"
L["Separated by commas."] = "Separados por vírgulas."
L["Your \"Events\" deviate from the default for this situation. Click here to restore them."] = "Seus \"Eventos\" desviam do original para esta situação. Clique aqui para restaurá-los."
L["<events_desc>"] = [[Aqui você define todos os eventos do jogo nos quais o DynamicCam deve verificar a condição desta situação, para entrar ou sair dela, se aplicável.

Você pode aprender sobre eventos do jogo usando o Registro de Evento do WoW.
Para abri-lo, digite isto no console:

  /eventtrace

Uma lista de todos os eventos possíveis também pode ser encontrada aqui:
https://warcraft.wiki.gg/wiki/Events

]]
L["Initialisation"] = "Inicialização"
L["Initialisation Script"] = "Script de Inicialização"
L["Lua code using the WoW UI API."] = "Código Lua usando a API da interface do WoW."
L["Your \"Initialisation Script\" deviates from the stock setting for this situation. Click here to restore it."] = "Seu \"Script de Inicialização\" desvia da configuração original para esta situação. Clique aqui para restaurá-lo."
L["<initialisation_desc>"] = [[O script de inicialização de uma situação é executado uma vez quando o DynamicCam é carregado (e também quando a situação é modificada). Você normalmente colocaria coisas nele que deseja reutilizar em qualquer um dos outros scripts (condição, entrada, saída). Isso pode tornar esses outros scripts um pouco mais curtos.

Por exemplo, o script de inicialização da situação \"Pedra de Regresso/Teletransporte\" define a tabela \"this.spells\", que inclui os IDs de feitiço dos feitiços de teletransporte. O script de condição pode então simplesmente acessar \"this.spells\" toda vez que for executado.

Como neste exemplo, você pode compartilhar qualquer objeto de dados entre os scripts de uma situação colocando-o na tabela \"this\".

]]
L["Condition"] = "Condição"
L["Condition Script"] = "Script de Condição"
L["Lua code using the WoW UI API.\nShould return \"true\" if and only if the situation should be active."] = "Código Lua usando a API da interface do WoW.\nDeve retornar \"true\" se e somente se a situação deve estar ativa."
L["Your \"Condition Script\" deviates from the stock setting for this situation. Click here to restore it."] = "Seu \"Script de Condição\" desvia da configuração original para esta situação. Clique aqui para restaurá-lo."
L["<condition_desc>"] = [[O script de condição de uma situação é executado toda vez que um evento do jogo desta situação é acionado. O script deve retornar \"true\" se e somente se esta situação deve estar ativa.

Por exemplo, o script de condição da situação \"Cidade\" usa a função da API do WoW \"IsResting()\" para verificar se você está atualmente em uma zona de descanso:

  return IsResting()

Da mesma forma, o script de condição da situação \"Cidade (Interiores)\" também usa a função da API do WoW \"IsIndoors()\" para verificar se você está em interiores:

  return IsResting() and IsIndoors()

Uma lista de funções da API do WoW pode ser encontrada aqui:
https://warcraft.wiki.gg/wiki/World_of_Warcraft_API

]]
L["Entering"] = "Entrando"
L["On-Enter Script"] = "Script de Entrada"
L["Your \"On-Enter Script\" deviates from the stock setting for this situation. Click here to restore it."] = "Seu \"Script de Entrada\" desvia da configuração original para esta situação. Clique aqui para restaurá-lo."
L["<executeOnEnter_desc>"] = [[O script de entrada de uma situação é executado toda vez que a situação é inserida.

Até agora, o único exemplo para isso é a situação \"Pedra de Regresso/Teletransporte\", na qual usamos a função da API do WoW \"UnitCastingInfo()\" para determinar a duração do lançamento do feitiço atual. Em seguida, atribuímos isso às variáveis \"this.transitionTime\" e \"this.rotationTime\", de modo que um zoom ou rotação (veja \"Ações da Situação\") possa levar exatamente o tempo do lançamento do feitiço. (Nem todos os feitiços de teletransporte têm os mesmos tempos de lançamento.)

]]
L["Exiting"] = "Saindo"
L["On-Exit Script"] = "Script de Saída"
L["Your \"On-Exit Script\" deviates from the stock setting for this situation. Click here to restore it."] = "Seu \"Script de Saída\" desvia da configuração original para esta situação. Clique aqui para restaurá-lo."
L["Exit Delay"] = "Atraso de Saída"
L["Wait for this many seconds before exiting this situation."] = "Aguarde esse número de segundos antes de sair desta situação."
L["Your \"Exit Delay\" deviates from the stock setting for this situation. Click here to restore it."] = "Seu \"Atraso de Saída\" desvia da configuração original para esta situação. Clique aqui para restaurá-lo."
L["<executeOnExit_desc>"] = [[O script de saída de uma situação é executado toda vez que a situação é encerrada. Até agora, nenhuma situação está usando isso.

O atraso determina quantos segundos esperar antes de sair da situação. Até agora, o único exemplo para isso é a situação "Pesca", onde o atraso lhe dá tempo para lançar novamente sua vara de pescar sem sair da situação.

]]
L["Export"] = "Exportar"
L["Coming soon(TM)."] = "Em breve(TM)."
L["Import"] = "Importar"
L["<welcomeMessage>"] = [[Estamos felizes que você esteja aqui e esperamos que você se divirta com o addon.

DynamicCam (DC) foi iniciado em maio de 2016 por mpstark quando os desenvolvedores do WoW na Blizzard introduziram os recursos experimentais da ActionCam no jogo. O objetivo principal do DC tem sido fornecer uma interface de usuário para as configurações da ActionCam. Dentro do jogo, a ActionCam ainda é designada como "experimental" e não houve nenhum sinal da Blizzard para desenvolvê-la ainda mais. Existem algumas deficiências, mas devemos ser gratos que a ActionCam foi deixada no jogo para entusiastas como nós. :-) O DC não permite apenas alterar as configurações da ActionCam, mas ter configurações diferentes para diferentes situações de jogo. Não relacionado à ActionCam, o DC também fornece recursos referentes ao zoom da câmera e desaparecimento da interface.

O trabalho de mpstark no DC continuou até agosto de 2018. Enquanto a maioria dos recursos funcionava bem para uma base de usuários substancial, mpstark sempre considerou o DC em estado beta e devido ao seu interesse decrescente no WoW ele acabou não retomando seu trabalho. Naquela época, Ludius já havia começado a fazer ajustes no DC para si mesmo, o que foi notado por Weston (também conhecido como dernPerkins) que no início de 2020 conseguiu entrar em contato com mpstark, levando Ludius a assumir o desenvolvimento. A primeira versão não beta 1.0 foi lançada em maio de 2020 incluindo os ajustes de Ludius até aquele ponto. Depois disso, Ludius começou a trabalhar em uma revisão do DC resultando na versão 2.0 sendo lançada no outono de 2022.

Quando mpstark iniciou o DC, seu foco era fazer a maioria das personalizações no jogo em vez de ter que alterar o código-fonte. Isso tornou mais fácil experimentar, particularmente com as diferentes situações de jogo. A partir da versão 2.0, essas configurações avançadas foram movidas para uma seção especial chamada "Controles de Situação". A maioria dos usuários provavelmente nunca precisará disso, mas para "usuários avançados" ainda está disponível. Um risco de fazer alterações lá é que as configurações de usuário salvas sempre substituem as configurações originais do DC, mesmo que novas versões do DC tragam configurações originais atualizadas. Portanto, um aviso é exibido no topo desta página sempre que você tiver situações originais com "Controles de Situação" modificados.

Se você acha que uma das situações originais do DC deve ser alterada, você sempre pode criar uma cópia dela com suas alterações. Sinta-se à vontade para exportar esta nova situação e publicá-la na página do CurseForge do DC. Podemos então adicioná-la como uma nova situação original própria. Você também é bem-vindo para exportar e publicar todo o seu perfil do DC, pois estamos sempre procurando novas predefinições de perfil que permitam aos recém-chegados uma entrada mais fácil no DC. Se você encontrar um problema ou quiser fazer uma sugestão, basta deixar uma nota nos comentários do CurseForge ou, melhor ainda, usar os Issues no GitHub. Se você quiser contribuir, sinta-se à vontade para abrir um pull request lá também.

Aqui estão alguns comandos de barra úteis:

    `/dynamiccam` ou `/dc` abre este menu.
    `/zoominfo` ou `/zi` imprime o nível de zoom atual.

    `/zoom #1 #2` aproxima para o nível de zoom #1 em #2 segundos.
    `/yaw #1 #2` gira a câmera em #1 graus em #2 segundos (#1 negativo para girar à direita).
    `/pitch #1 #2` inclina a câmera em #1 graus (#1 negativo para inclinar para cima).


]]
L["About"] = "Sobre"
L["The following game situations have \"Situation Controls\" deviating from DynamicCam's stock settings.\n\n"] = "As seguintes situações de jogo têm \"Controles de Situação\" desviando das configurações originais do DynamicCam.\n\n"
L["<situationControlsWarning>"] = "\nSe você está fazendo isso de propósito, tudo bem. Apenas esteja ciente de que quaisquer atualizações nessas configurações pelos desenvolvedores do DynamicCam sempre serão substituídas pela sua versão modificada (possivelmente desatualizada). Você pode verificar a aba \"Controles de Situação\" de cada situação para detalhes. Se você não está ciente de quaisquer modificações de \"Controles de Situação\" de sua parte e simplesmente deseja restaurar as configurações de controle originais para *todas* as situações, clique neste botão:"
L["Restore all stock Situation Controls"] = "Restaurar todos os Controles de Situação originais"
L["Hello and welcome to DynamicCam!"] = "Olá e bem-vindo ao DynamicCam!"
L["Profiles"] = "Perfis"
L["Manage Profiles"] = "Gerenciar Perfis"
L["<manageProfilesWarning>"] = "Como muitos addons, o DynamicCam usa a biblioteca \"AceDB-3.0\" para gerenciar perfis. O que você tem que entender é que não existe nada como \"Salvar Perfil\" aqui. Você só pode criar novos perfis e pode copiar configurações de outro perfil para o atualmente ativo. Qualquer alteração que você fizer para o perfil atualmente ativo é salva imediatamente! Não existe nada como \"cancelar\" ou \"descartar alterações\". O botão \"Redefinir Perfil\" redefine apenas para o perfil padrão global.\n\nEntão, se você gosta das suas configurações do DynamicCam, você deve criar outro perfil no qual você copia essas configurações como um backup. Quando você não usa este perfil de backup como seu perfil ativo, você pode experimentar com as configurações e retornar ao seu perfil original a qualquer momento selecionando seu perfil de backup na caixa \"Copiar de\".\n\nSe você quiser trocar de perfil via macro, você pode usar o seguinte:\n/run DynamicCam.db:SetProfile(\"Nome do perfil aqui\")\n\n"
L["Profile presets"] = "Predefinições de perfil"
L["Import / Export"] = "Importar / Exportar"
L["DynamicCam"] = "DynamicCam"
L["Disabled"] = "Desativado"
L["Your DynamicCam addon lets you adjust horizontal and vertical mouse look speed individually! Just go to the \"Mouse Look\" settings of DynamicCam to make the adjustments there."] = "Seu addon DynamicCam permite ajustar a velocidade do giro do mouse horizontal e vertical individualmente! Basta ir às configurações de \"Giro do mouse\" do DynamicCam para fazer os ajustes lá."
L["Attention"] = "Atenção"
L["The \"%s\" setting is disabled by DynamicCam, while you are using the horizontal camera over shoulder offset."] = "A configuração \"%s\" está desativada pelo DynamicCam, enquanto você está usando o Deslocamento da Câmera Acima do Ombro horizontal."
L["While you are using horizontal camera offset, DynamicCam prevents CameraKeepCharacterCentered!"] = "Enquanto você está usando o deslocamento horizontal da câmera, o DynamicCam impede CameraKeepCharacterCentered!"
L["While you are using horizontal camera offset, DynamicCam prevents CameraReduceUnexpectedMovement!"] = "Enquanto você está usando o deslocamento horizontal da câmera, o DynamicCam impede CameraReduceUnexpectedMovement!"
L["While you are using vertical camera pitch, DynamicCam prevents CameraKeepCharacterCentered!"] = "Enquanto você está usando a inclinação vertical da câmera, o DynamicCam impede CameraKeepCharacterCentered!"
L["cameraView=%s prevented by DynamicCam!"] = "cameraView=%s impedido pelo DynamicCam!"

-- MouseZoom
L["Current\nZoom\nValue"] = "Valor de\nZoom\nAtual"
L["Reactive\nZoom\nTarget"] = "Alvo de\nZoom\nReativo"

-- Core
L["Enter name for custom situation:"] = "Digite o nome para a situação personalizada:"
L["Create"] = "Criar"
L["Cancel"] = "Cancelar"

-- DefaultSettings
L["City"] = "Cidade"
L["City (Indoors)"] = "Cidade (Interiores)"
L["World"] = "Mundo"
L["World (Indoors)"] = "Mundo (Interiores)"
L["World (Combat)"] = "Mundo (Combate)"
L["Dungeon/Scenario"] = "Masmorra/Cenário"
L["Dungeon/Scenario (Outdoors)"] = "Masmorra/Cenário (Ao ar livre)"
L["Dungeon/Scenario (Combat, Boss)"] = "Masmorra/Cenário (Combate, Chefe)"
L["Dungeon/Scenario (Combat, Trash)"] = "Masmorra/Cenário (Combate, Lixo)"
L["Raid"] = "Raide"
L["Raid (Outdoors)"] = "Raide (Ao ar livre)"
L["Raid (Combat, Boss)"] = "Raide (Combate, Chefe)"
L["Raid (Combat, Trash)"] = "Raide (Combate, Lixo)"
L["Arena"] = "Arena"
L["Arena (Combat)"] = "Arena (Combate)"
L["Battleground"] = "Campo de Batalha"
L["Battleground (Combat)"] = "Campo de Batalha (Combate)"
L["Mounted (any)"] = "Montaria (qualquer)"
L["Mounted (only flying-mount)"] = "Montaria (apenas montaria voadora)"
L["Mounted (only flying-mount + airborne)"] = "Montaria (apenas montaria voadora + no ar)"
L["Mounted (only flying-mount + airborne + Skyriding)"] = "Montaria (apenas montaria voadora + no ar + pilotagem aérea)"
L["Mounted (only flying-mount + Skyriding)"] = "Montaria (apenas montaria voadora + pilotagem aérea)"
L["Mounted (only airborne)"] = "Montaria (apenas no ar)"
L["Mounted (only airborne + Skyriding)"] = "Montaria (apenas no ar + pilotagem aérea)"
L["Mounted (only Skyriding)"] = "Montaria (apenas pilotagem aérea)"
L["Druid Travel Form"] = "Forma de Viagem de Druida"
L["Dracthyr Soar"] = "Dracthyr Voar Alto"
L["Skyriding Race"] = "Corrida de pilotagem aérea"
L["Taxi"] = "Táxi"
L["Vehicle"] = "Veículo"
L["Hearth/Teleport"] = "Pedra de Regresso/Teletransporte"
L["Annoying Spells"] = "Feitiços Irritantes"
L["NPC Interaction"] = "Interação com NPC"
L["Mailbox"] = "Caixa de Correio"
L["Fishing"] = "Pesca"
L["Gathering"] = "Coleta"
L["AFK"] = "Ausente (AFK)"
L["Pet Battle"] = "Batalha de Mascote"
L["Professions Frame Open"] = "Janela de Profissões Aberta"
