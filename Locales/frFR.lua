local L = LibStub("AceLocale-3.0"):NewLocale("DynamicCam", "frFR")
if not L then return end

-- Options
L["Reset"] = "Réinitialiser"
L["Reset to global default"] = "Utiliser la valeur par défaut globale "
L["(To restore the settings of a specific profile, restore the profile in the \"Profiles\" tab.)"] = "(Pour restaurer les paramètres d'un profil spécifique, restaurez le profil dans l'onglet « Profils ».)"
L["Currently overridden by the active situation \"%s\"."] = "Actuellement ignoré par la situation active « %s »."
L["Override Standard Settings"] = "Ignorer les Paramètres Standard"
L["<overrideStandardToggle_desc>"] = "Cocher cette case vous permet de configurer les paramètres de cette catégorie. Ces Paramètres de Situation remplacent alors les Paramètres Standard dès que cette situation est active. Décocher la case efface les Paramètres de Situation de cette catégorie."
L["Standard Settings"] = "Paramètres Standard"
L["Situation Settings"] = "Paramètres de Situation"
L["<standardSettings_desc>"] = "Ces Paramètres Standard sont appliqués quand aucune situation n'est active ou quand la situation active n'a pas de Paramètres de Situation configurés pour remplacer les Paramètres Standard."
L["<standardSettingsOverridden_desc>"] = "Les catégories marquées en vert sont actuellement ignorées par la situation active. Vous ne verrez donc aucun effet si vous modifiez les Paramètres Standard des catégories vertes tant que la situation qui les remplace est active."
L["These Situation Settings override the Standard Settings when the respective situation is active."] = "Ces Paramètres de Situation remplacent les Paramètres Standard lorsque la situation correspondante est active."
L["Mouse Zoom"] = "Zoom Souris"
L["Maximum Camera Distance"] = "Distance maximale de la caméra"
L["How many yards the camera can zoom away from your character."] = "Jusqu'à combien de verges la caméra peut-elle s'éloigner de votre personnage."
L["Camera Zoom Speed"] = "Vitesse de zoom de la caméra"
L["How fast the camera can zoom."] = "À quelle vitesse la caméra peut être zoomée."
L["Zoom Increments"] = "Paliers de zoom"
L["How many yards the camera should travel for each \"tick\" of the mouse wheel."] = "Combien de verges la caméra devrait-elle parcourir à chaque « cran » de la molette de la souris."
L["Use Reactive Zoom"] = "Utiliser le zoom réactif"
L["Quick-Zoom Additional Increments"] = "Quick-Zoom incréments supplémentaires"
L["How many yards per mouse wheel \"tick\" should be added when quick-zooming."] = "Combien de verges par « cran » de la molette de la souris doivent être ajoutées lors d'un zoom rapide."
L["Quick-Zoom Enter Threshold"] = "Seuil d'entrée du zoom rapide"
L["How many yards the \"Reactive Zoom Target\" and the \"Current Zoom Value\" have to be apart to enter quick-zooming."] = "Combien de verges doivent séparer la « cible de zoom réactif » et la « valeur de zoom actuelle » pour activer le zoom rapide."
L["Maximum Zoom Time"] = "Temps de zoom maximal"
L["The maximum time the camera should take to make \"Current Zoom Value\" equal to \"Reactive Zoom Target\"."] = "Le temps maximum que la caméra devrait mettre pour que la « valeur de zoom actuelle » soit égale à la « cible de zoom réactif »."
L["Help"] = "Aide"
L["Toggle Visual Aid"] = "Afficher/Masquer l'aide visuelle"
L["<reactiveZoom_desc>"] = "Avec le Zoom Réactif de DynamicCam, la molette de la souris contrôle ce qu'on appelle la « Cible de Zoom Réactif ». Chaque fois que la « Cible de Zoom Réactif » et la « Valeur de Zoom Actuelle » sont différentes, DynamicCam modifie la « Valeur de Zoom Actuelle » jusqu'à ce qu'elle corresponde à nouveau à la « Cible de Zoom Réactif ».\n\nLa vitesse à laquelle ce changement de zoom se produit dépend de la « Vitesse de zoom de la caméra » et du « Temps de zoom maximal ». Si le « Temps de zoom maximal » est réglé sur une valeur basse, le changement de zoom sera toujours exécuté rapidement, quel que soit le réglage de la « Vitesse de zoom de la caméra ». Pour obtenir un changement de zoom plus lent, vous devez régler le « Temps de zoom maximal » sur une valeur plus élevée et la « Vitesse de zoom de la caméra » sur une valeur plus basse.\n\nPour permettre un zoom plus rapide avec un mouvement plus rapide de la molette de la souris, il y a le « Zoom Rapide » : si la « Cible de Zoom Réactif » est plus éloignée de la « Valeur de Zoom Actuelle » que le « Seuil d'entrée du zoom rapide », la quantité d'« Incréments supplémentaires de zoom rapide » est ajoutée à chaque cran de la molette de la souris.\n\nPour avoir une idée de son fonctionnement, vous pouvez activer l'aide visuelle tout en trouvant vos paramètres idéaux. Vous pouvez également déplacer librement ce graphique en cliquant gauche et en le faisant glisser. Un clic droit le ferme."
L["Enhanced minimal zoom-in"] = "Zoom minimal amélioré"
L["<enhancedMinZoom_desc>"] = "Le zoom réactif permet de zoomer plus près que le niveau 1. Vous pouvez y parvenir en dézoomant d'un cran de molette depuis la vue à la première personne.\n\nAvec le « Zoom minimal amélioré », nous forçons également la caméra à s'arrêter à ce niveau de zoom minimal lors du zoom avant, avant qu'elle ne passe en vue à la première personne.\n\n|cFFFF0000L'activation du « Zoom minimal amélioré » peut coûter jusqu'à 15% de FPS dans les situations limitées par le processeur.|r"
L["/reload of the UI required!"] = "Un /reload de l'interface est requis !"
L["Mouse Look"] = "Vision à la souris"
L["Horizontal Speed"] = "Vitesse horizontale"
L["How much the camera yaws horizontally when in mouse look mode."] = "De combien la caméra pivote horizontalement en mode vision à la souris."
L["Vertical Speed"] = "Vitesse verticale"
L["How much the camera pitches vertically when in mouse look mode."] = "De combien la caméra s'incline verticalement en mode vision à la souris."
L["<mouseLook_desc>"] = "De combien la caméra bouge quand vous bougez la souris en mode « vision à la souris » ; c.-à-d. pendant que le bouton gauche ou droit de la souris est enfoncé.\n\nLe curseur « Vitesse de vision à la souris » des paramètres d'interface par défaut de WoW contrôle la vitesse horizontale et verticale en même temps : réglant automatiquement la vitesse horizontale à 2 x la vitesse verticale. DynamicCam remplace cela et vous permet une configuration plus personnalisée."
L["Horizontal Offset"] = "Décalage horizontal"
L["Camera Over Shoulder Offset"] = "Décalage de la caméra au-dessus de l'épaule"
L["Positions the camera left or right from your character."] = "Positionne la caméra à gauche ou à droite de votre personnage."
L["<cameraOverShoulder_desc>"] = "Pour que cela prenne effet, DynamicCam désactive automatiquement et temporairement le réglage de la Cinétose de WoW. Par conséquent, si vous avez besoin du réglage de la Cinétose, n'utilisez pas le décalage horizontal dans ces situations.\n\nLorsque vous ciblez votre propre personnage, WoW centre automatiquement la caméra. Nous ne pouvons rien y faire. Nous ne pouvons rien faire non plus concernant les à-coups de décalage qui peuvent survenir lors de collisions entre la caméra et un mur. Une solution consiste à utiliser un décalage faible ou nul à l'intérieur des bâtiments.\n\nDe plus, WoW applique étrangement le décalage différemment selon le modèle du personnage ou la monture. Pour ceux qui préfèrent un décalage constant, Ludius travaille sur un autre addon (« CameraOverShoulder Fix ») pour résoudre ce problème."
L["Adjust shoulder offset according to zoom level"] = "Ajuster le décalage en fonction du niveau de zoom"
L["Enable"] = "Activer"
L["and"] = "et"
L["No offset when below this zoom level:"] = "Pas de décalage en dessous de ce niveau de zoom :"
L["When the camera is closer than this zoom level, the offset has reached zero."] = "Lorsque la caméra est plus proche que ce niveau de zoom, le décalage a atteint zéro."
L["Real offset when above this zoom level:"] = "Décalage complet au-dessus de ce niveau de zoom :"
L["When the camera is further away than this zoom level, the offset has reached its set value."] = "Lorsque la caméra est plus éloignée que ce niveau de zoom, le décalage a atteint sa valeur définie."
L["<shoulderOffsetZoom_desc>"] = "Fait passer progressivement le décalage au-dessus de l'épaule à zéro lors du zoom avant. Les deux curseurs définissent entre quels niveaux de zoom cette transition a lieu. Ce paramètre est global et non spécifique à une situation."
L["Vertical Pitch"] = "Inclinaison verticale"
L["Pitch (on ground)"] = "Inclinaison (au sol)"
L["Pitch (flying)"] = "Inclinaison (en vol)"
L["Down Scale"] = "Facteur de réduction"
L["Smart Pivot Cutoff Distance"] = "Distance de coupure du pivot intelligent"
L["<pitch_desc>"] = "Si la caméra est inclinée vers le haut (valeur d'« Inclinaison » plus basse), le « Facteur de réduction » détermine l'ampleur de cet effet lorsque vous regardez votre personnage d'en haut. Réglez le « Facteur de réduction » à 0 pour annuler l'effet d'une inclinaison vers le haut lorsque vous regardez d'en haut. À l'inverse, le « Facteur de réduction » n'a que peu ou pas d'effet lorsque vous ne regardez pas d'en haut ou si la caméra est inclinée vers le bas (valeur d'« Inclinaison » plus élevée).\n\nVous devriez donc d'abord trouver votre réglage d'« Inclinaison » préféré en regardant votre personnage par derrière. Après avoir opté pour une inclinaison vers le haut, trouvez ensuite votre réglage de « Facteur de réduction » préféré en regardant d'en haut.\n\n\nLorsque la caméra entre en collision avec le sol, elle effectue normalement une inclinaison vers le haut au point de collision caméra-sol. Une alternative est que la caméra se rapproche des pieds de votre personnage tout en effectuant cette inclinaison. La « Distance de coupure du pivot intelligent » détermine la distance à laquelle la caméra doit se trouver par rapport à votre personnage pour que cela se produise. À une valeur de 0, la caméra ne se rapproche jamais (par défaut dans WoW). En revanche, à la valeur maximale de 39, elle le fait toujours.\n\n"
L["Target Focus"] = "Focus de cible"
L["Enemy Target"] = "Cible ennemie"
L["Horizontal Strength"] = "Force horizontale"
L["Vertical Strength"] = "Force verticale"
L["Interaction Target (NPCs)"] = "Cible d'interaction (PNJ)"
L["<targetFocus_desc>"] = "Si activé, la caméra tente automatiquement de rapprocher la cible du centre de l'écran. La force détermine l'intensité de cet effet.\n\nSi « Cible ennemie » et « Cible d'interaction » sont toutes deux activées, il semble y avoir un bug étrange avec cette dernière : lors de la première interaction avec un PNJ, la caméra se déplace en douceur vers son nouvel angle comme prévu. Mais lorsque vous quittez l'interaction, elle revient instantanément à son angle précédent. Si vous relancez l'interaction, elle saute à nouveau brutalement vers le nouvel angle. Ceci est reproductible à chaque conversation avec un nouveau PNJ : seule la première transition est fluide, toutes les suivantes sont immédiates.\nUne solution de contournement, si vous souhaitez utiliser à la fois « Cible ennemie » et « Cible d'interaction », consiste à n'activer « Cible ennemie » que pour les situations DynamicCam dans lesquelles vous en avez besoin et où les interactions avec des PNJ sont peu probables (comme en Combat)."
L["Head Tracking"] = "Suivi de la tête"
L["<headTrackingEnable_desc>"] = "(Ceci pourrait aussi être utilisé comme une valeur continue entre 0 et 1, mais elle est simplement multipliée par « Force (debout) » et « Force (en mouvement) » respectivement. Il n'y a donc pas vraiment besoin d'un autre curseur.)"
L["Strength (standing)"] = "Force (debout)"
L["Inertia (standing)"] = "Inertie (debout)"
L["Strength (moving)"] = "Force (en mouvement)"
L["Inertia (moving)"] = "Inertie (en mouvement)"
L["Inertia (first person)"] = "Inertie (première personne)"
L["Range Scale"] = "Échelle de portée"
L["Camera distance beyond which head tracking is reduced or disabled. (See explanation below.)"] = "Distance de la caméra au-delà de laquelle le suivi de la tête est réduit ou désactivé. (Voir explication ci-dessous.)"
L["(slider value transformed)"] = "(valeur du curseur transformée)"
L["Dead Zone"] = "Zone morte"
L["Radius of head movement not affecting the camera. (See explanation below.)"] = "Rayon du mouvement de la tête n'affectant pas la caméra. (Voir explication ci-dessous.)"
L["(slider value devided by 10)"] = "(valeur du curseur divisée par 10)"
L["Requires /reload to come into effect!"] = "Nécessite un /reload pour prendre effet !"
L["<headTracking_desc>"] = "Lorsque le suivi de la tête est activé, la caméra suit le mouvement de la tête de votre personnage. (Bien que cela puisse favoriser l'immersion, cela peut aussi provoquer des nausées si vous êtes sujet à la cinétose.)\n\nLe réglage « Force » détermine l'intensité de cet effet. Une valeur de 0 désactive le suivi de la tête. Le réglage « Inertie » détermine la rapidité avec laquelle la caméra réagit aux mouvements de la tête. Une valeur de 0 désactive également le suivi de la tête. Les trois cas « debout », « en mouvement » et « première personne » peuvent être configurés individuellement. Il n'y a pas de réglage de « Force » pour la « première personne » car elle reprend les réglages de « Force » de « debout » et « en mouvement » respectivement. Si vous souhaitez activer ou désactiver uniquement la « première personne », utilisez les curseurs « Inertie » pour désactiver les cas indésirables.\n\nAvec le réglage « Échelle de portée », vous pouvez définir la distance de la caméra au-delà de laquelle le suivi de la tête est réduit ou désactivé. Par exemple, si le curseur est réglé sur 30, vous n'aurez plus de suivi de la tête lorsque la caméra est à plus de 30 mètres de votre personnage. Il y a cependant une transition progressive d'un suivi complet à aucun suivi, qui commence à un tiers de la valeur du curseur. Par exemple, si la valeur est réglée sur 30, vous avez un suivi complet lorsque la caméra est à moins de 10 mètres. Au-delà de 10 mètres, le suivi de la tête diminue progressivement jusqu'à disparaître complètement au-delà de 30 mètres. Par conséquent, la valeur maximale de 117 permet un suivi complet à la distance maximale de la caméra de 39 mètres. (Astuce : utilisez l'aide visuelle de DynamicCam pour « Zoom Souris » afin de connaître la distance actuelle de la caméra pendant le réglage.)\n\nLe réglage « Zone morte » peut être utilisé pour ignorer les petits mouvements de la tête. Une valeur de 0 permet à la caméra de suivre le moindre mouvement de tête, tandis qu'une valeur plus élevée fait qu'elle ne suit que les mouvements plus importants. Notez qu'une modification de ce réglage ne prend effet qu'après le rechargement de l'interface (tapez /reload dans la console)."
L["Situations"] = "Situations"
L["Select a situation to setup"] = "Sélectionnez une situation à configurer"
L["<selectedSituation_desc>"] = "\n|cffffcc00Codes couleurs :|r\n|cFF808A87- Situation désactivée.|r\n- Situation activée.\n|cFF00FF00- Situation activée et actuellement active.|r\n|cFF63B8FF- Situation activée avec condition remplie mais priorité inférieure à la situation actuellement active.|r\n|cFFFF6600- « Contrôle de situation » d'origine modifié (réinitialisation recommandée).|r\n|cFFEE0000- « Contrôle de situation » erroné (correction requise).|r"
L["If this box is checked, DynamicCam will enter the situation \"%s\" whenever its condition is fulfilled and no other situation with higher priority is active."] = "Si cette case est cochée, DynamicCam entrera dans la situation « %s » chaque fois que sa condition est remplie et qu'aucune autre situation avec une priorité plus élevée n'est active."
L["Custom:"] = "Personnalisé :"
L["(modified)"] = "(modifié)"
L["Delete custom situation \"%s\".\n|cFFEE0000Attention: There will be no 'Are you sure?' prompt!|r"] = "Supprimer la situation personnalisée « %s ».\n|cFFEE0000Attention : il n'y aura pas d'invite « Êtes-vous sûr ? » !|r"
L["Create a new custom situation."] = "Créer une nouvelle situation personnalisée."
L["Situation Actions"] = "Actions de situation"
L["Setup stuff to happen while in a situation or when entering/exiting it."] = "Configurer ce qui doit se passer pendant une situation ou lors de l'entrée/sortie de celle-ci."
L["Zoom/View"] = "Zoom/Vue"
L["Zoom to a certain zoom level or switch to a saved camera view when entering this situation."] = "Zoomer à un certain niveau ou passer à une vue de caméra enregistrée lors de l'entrée dans cette situation."
L["Set Zoom or Set View"] = "Définir le zoom ou la vue"
L["Zoom Type"] = "Type de zoom"
L["<viewZoomType_desc>"] = "Définir le zoom : Zoome à un niveau donné avec des options avancées de temps de transition et de conditions.\n\nDéfinir la vue : Bascule sur une vue de caméra enregistrée composée d'un niveau de zoom et d'un angle fixes."
L["Set Zoom"] = "Définir le zoom"
L["Set View"] = "Définir la vue"
L["Set view to saved view:"] = "Définir la vue sur la vue enregistrée :"
L["Select the saved view to switch to when entering this situation."] = "Sélectionnez la vue enregistrée vers laquelle basculer lors de l'entrée dans cette situation."
L["Instant"] = "Instantané"
L["Make view transitions instant."] = "Rendre les transitions de vue instantanées."
L["Restore view when exiting"] = "Restaurer la vue en quittant"
L["When exiting the situation restore the camera position to what it was at the time of entering the situation."] = "En quittant la situation, la position de la caméra est restaurée à ce qu'elle était au moment de l'entrée dans la situation."
L["cameraSmoothNote"] = [[|cFFEE0000Attention :|r Vous utilisez le « Style de poursuite caméra » de WoW qui place automatiquement la caméra derrière le joueur. Cela ne fonctionne pas lorsque vous êtes dans une vue enregistrée personnalisée. Il est possible d'utiliser des vues enregistrées personnalisées pour des situations où la poursuite caméra n'est pas nécessaire (par ex. interaction avec PNJ). Mais après avoir quitté la situation, vous devez revenir à une vue standard non personnalisée pour que la poursuite caméra fonctionne à nouveau.]]
L["Restore to default view:"] = "Restaurer la vue par défaut :"
L["<viewRestoreToDefault_desc>"] = [[Sélectionnez la vue par défaut vers laquelle revenir en quittant cette situation.

Vue 1 :   Zoom 0, Inclinaison 0
Vue 2 :   Zoom 5.5, Inclinaison 10
Vue 3 :   Zoom 5.5, Inclinaison 20
Vue 4 :   Zoom 13.8, Inclinaison 30
Vue 5 :   Zoom 13.8, Inclinaison 10]]
L["WARNING"] = "ATTENTION"
L["You are using the same view as saved view and as restore-to-default view. Using a view as restore-to-default view will reset it. Only do this if you really want to use it as a non-customized saved view."] = "Votre vue enregistrée à définir est la même que votre vue par défaut à restaurer. Si une vue est utilisée pour restaurer les paramètres par défaut, elle sera réinitialisée. Ne faites cela que si vous voulez vraiment l'utiliser comme une vue enregistrée non personnalisée."
L["View %s is used as saved view in the situations:\n%sand as restore-to-default view in the situations:\n%s"] = "La vue %s est utilisée comme vue enregistrée dans les situations :\n%set comme vue à restaurer par défaut dans les situations :\n%s"
L["<view_desc>"] = [[WoW permet d'enregistrer jusqu'à 5 vues de caméra personnalisées. La vue 1 est utilisée par DynamicCam pour enregistrer la position de la caméra lors de l'entrée dans une situation, afin qu'elle puisse être restaurée lors de la sortie, si vous cochez la case « Restaurer » ci-dessus. C'est particulièrement utile pour les situations courtes comme l'interaction avec un PNJ, permettant de passer à une vue pendant le dialogue et de revenir ensuite à la position précédente. C'est pourquoi la vue 1 ne peut pas être sélectionnée dans le menu déroulant des vues enregistrées ci-dessus.

Les vues 2, 3, 4 et 5 peuvent être utilisées pour enregistrer des positions de caméra personnalisées. Pour enregistrer une vue, amenez simplement la caméra au zoom et à l'angle souhaités. Tapez ensuite la commande suivante dans la console (où # est le numéro de vue 2, 3, 4 ou 5) :

  /saveView #

Ou en abrégé :

  /sv #

Notez que les vues enregistrées sont stockées par WoW. DynamicCam ne stocke que les numéros de vue à utiliser. Ainsi, lorsque vous importez un nouveau profil de situations DynamicCam avec des vues, vous devrez probablement définir et enregistrer les vues appropriées par la suite.


DynamicCam fournit également une commande console pour passer à une vue indépendamment de l'entrée ou de la sortie de situations :

  /setView #

Pour rendre la transition de vue instantanée, ajoutez un « i » après le numéro de vue. Par exemple, pour passer immédiatement à la vue enregistrée 3, tapez :

  /setView 3 i

]]
L["Zoom Transition Time"] = "Temps de transition du zoom"
L["<transitionTime_desc>"] = "Le temps en secondes qu'il faut pour passer à la nouvelle valeur de zoom.\n\nSi réglé plus bas que possible, la transition sera aussi rapide que la vitesse de zoom actuelle de la caméra le permet (réglable dans les paramètres « Zoom Souris » de DynamicCam).\n\nSi une situation assigne la variable « this.transitionTime » dans son script d'entrée (voir « Contrôle de situation »), le réglage ici est ignoré. Cela est fait par exemple dans la situation « Pierre de foyer/Téléportation » pour permettre un temps de transition correspondant à la durée de l'incantation du sort."
L["<zoomType_desc>"] = "\nDéfinir : Définit toujours le zoom à cette valeur.\n\nReculer : Définit le zoom seulement si la caméra est actuellement plus proche que cette valeur.\n\nAvancer : Définit le zoom seulement si la caméra est actuellement plus éloignée que cette valeur.\n\nPlage : Zoome avant si plus loin que le maximum donné. Zoome arrière si plus près que le minimum donné. Ne fait rien si le zoom actuel est dans la plage [min, max]."
L["Set"] = "Définir"
L["Out"] = "Reculer"
L["In"] = "Avancer"
L["Range"] = "Plage"
L["Don't slow"] = "Ne pas ralentir"
L["Zoom transitions may be executed faster (but never slower) than the specified time above, if the \"Camera Zoom Speed\" (see \"Mouse Zoom\" settings) allows."] = "Les transitions de zoom peuvent être exécutées plus rapidement (mais jamais plus lentement) que le temps spécifié ci-dessus, si la « Vitesse de zoom de la caméra » (voir paramètres « Zoom Souris ») le permet."
L["Zoom Value"] = "Valeur de zoom"
L["Zoom to this zoom level."] = "Zoome à ce niveau de zoom."
L["Zoom out to this zoom level, if the current zoom level is less than this."] = "Zoome arrière à ce niveau, si le niveau actuel est inférieur."
L["Zoom in to this zoom level, if the current zoom level is greater than this."] = "Zoome avant à ce niveau, si le niveau actuel est supérieur."
L["Zoom Min"] = "Zoom Min"
L["Zoom Max"] = "Zoom Max"
L["Restore Zoom"] = "Restaurer le zoom"
L["<zoomRestoreSetting_desc>"] = "Lorsque vous quittez une situation (ou quittez l'état par défaut où aucune situation n'est active), le niveau de zoom actuel est temporairement enregistré afin de pouvoir être restauré la prochaine fois que vous entrerez dans cette situation. Ici, vous pouvez choisir comment cela est géré.\n\nCe réglage est global pour toutes les situations."
L["Restore Zoom Mode"] = "Mode de restauration du zoom"
L["<zoomRestoreSettingSelect_desc>"] = "\nJamais : En entrant dans une situation, le réglage de zoom réel (s'il y en a un) de la situation entrante est appliqué. Aucun zoom enregistré n'est pris en compte.\n\nToujours : En entrant dans une situation, le dernier zoom enregistré de cette situation est utilisé. Son réglage réel n'est pris en compte que lors de la première entrée dans la situation après la connexion.\n\nAdaptatif : Le zoom enregistré n'est utilisé que dans certaines circonstances. Par exemple, uniquement lorsque vous revenez à la même situation d'où vous venez, ou lorsque le zoom enregistré remplit les critères des réglages de zoom « Avancer », « Reculer » ou « Plage » de la situation."
L["Never"] = "Jamais"
L["Always"] = "Toujours"
L["Adaptive"] = "Adaptatif"
L["<zoom_desc>"] = [[Pour déterminer le niveau de zoom actuel, vous pouvez soit utiliser l'« Aide visuelle » (activable dans les paramètres « Zoom Souris » de DynamicCam), soit utiliser la commande console :

  /zoomInfo

Ou en abrégé :

  /zi]]
L["Rotation"] = "Rotation"
L["Start a camera rotation when this situation is active."] = "Lance une rotation de la caméra lorsque cette situation est active."
L["Rotation Type"] = "Type de rotation"
L["<rotationType_desc>"] = "\nEn continu : La caméra tourne horizontalement en permanence tant que cette situation est active. Conseillé uniquement pour les situations où vous ne déplacez pas la caméra avec la souris ; par ex. incantation de téléportation, taxi ou ABS. Une rotation verticale continue n'est pas possible car elle s'arrêterait à la vue perpendiculaire d'en haut ou d'en bas.\n\nPar degrés : Après être entré dans la situation, modifie le pivotement (horizontal) et/ou l'inclinaison (verticale) actuel(le) de la caméra du nombre de degrés indiqué."
L["Continuously"] = "En continu"
L["By Degrees"] = "Par degrés"
L["Acceleration Time"] = "Temps d'accélération"
L["Rotation Time"] = "Temps de rotation"
L["<accelerationTime_desc>"] = "Si vous définissez un temps supérieur à 0 ici, la rotation continue ne démarrera pas immédiatement à pleine vitesse mais prendra ce temps pour accélérer. (Seulement perceptible pour des vitesses de rotation relativement élevées.)"
L["<rotationTime_desc>"] = "Combien de temps cela doit prendre pour adopter le nouvel angle de caméra. Si une valeur trop petite est donnée ici, la caméra pourrait tourner trop loin, car nous ne vérifions qu'une fois par image rendue si l'angle désiré est atteint.\n\nSi une situation assigne la variable « this.rotationTime » dans son script d'entrée (voir « Contrôle de situation »), le réglage ici est ignoré. Cela est fait par exemple dans la situation « Pierre de foyer/Téléportation » pour permettre un temps de rotation correspondant à la durée de l'incantation du sort."
L["Rotation Speed"] = "Vitesse de rotation"
L["Speed at which to rotate in degrees per second. You can manually enter values between -900 and 900, if you want to get yourself really dizzy..."] = "Vitesse de rotation en degrés par seconde. Vous pouvez entrer manuellement des valeurs entre -900 et 900, si vous voulez vraiment vous donner le tournis..."
L["Yaw (-Left/Right+)"] = "Pivotement (-Gauche/Droite+)"
L["Degrees to yaw (left or right)."] = "Degrés de pivotement (gauche ou droite)."
L["Pitch (-Down/Up+)"] = "Inclinaison (-Bas/Haut+)"
L["Degrees to pitch (up or down). There is no going beyond the perpendicular upwards or downwards view."] = "Degrés d'inclinaison (haut ou bas). Il n'est pas possible d'aller au-delà de la vue perpendiculaire d'en haut ou d'en bas."
L["Rotate Back"] = "Rotation inverse"
L["<rotateBack_desc>"] = "En quittant la situation, fait tourner la caméra en sens inverse du nombre de degrés (modulo 360) tournés depuis l'entrée dans la situation. Cela vous ramène effectivement à la position de la caméra avant l'entrée, à moins que vous n'ayez modifié l'angle de vue avec votre souris entre-temps.\n\nSi vous entrez dans une nouvelle situation avec son propre réglage de rotation, la « Rotation inverse » de la situation sortante est ignorée."
L["Rotate Back Time"] = "Temps de rotation inverse"
L["<rotateBackTime_desc>"] = "Le temps nécessaire pour la rotation inverse. Si une valeur trop petite est donnée ici, la caméra pourrait tourner trop loin, car nous ne vérifions qu'une fois par image rendue si l'angle désiré est atteint."
L["Fade Out UI"] = "Masquer l'interface"
L["Fade out or hide (parts of) the UI when this situation is active."] = "Estompe ou masque (des parties de) l'interface lorsque cette situation est active."
L["Adjust to Immersion"] = "Ajuster à Immersion"
L["<adjustToImmersion_desc>"] = "Beaucoup de gens utilisent l'addon Immersion en combinaison avec DynamicCam. Immersion possède ses propres fonctionnalités de masquage d'interface qui entrent en jeu lors des interactions avec les PNJ. Dans certaines circonstances, le masquage d'interface de DynamicCam l'emporte sur celui d'Immersion. Pour éviter cela, effectuez vos réglages souhaités ici dans DynamicCam. Cliquez sur ce bouton pour utiliser les mêmes temps d'apparition et de disparition qu'Immersion. Pour encore plus d'options, jetez un œil à l'autre addon de Ludius appelé « Immersion ExtraFade »."
L["Fade Out Time"] = "Temps de disparition"
L["Seconds it takes to fade out the UI when entering the situation."] = "Secondes nécessaires pour estomper l'interface lors de l'entrée dans la situation."
L["Fade In Time"] = "Temps d'apparition"
L["<fadeInTime_desc>"] = "Secondes nécessaires pour réafficher l'interface en quittant la situation.\n\nLorsque vous passez d'une situation à une autre et que les deux masquent l'interface, le temps de disparition de la situation entrante est utilisé pour la transition."
L["Hide entire UI"] = "Masquer toute l'interface"
L["<hideEntireUI_desc>"] = "Il y a une différence entre une interface « masquée » et une interface « juste estompée » : les éléments d'interface estompés ont une opacité de 0 mais on peut toujours interagir avec eux. Depuis DynamicCam 2.0, nous masquons automatiquement la plupart des éléments d'interface si leur opacité est de 0. Ainsi, cette option de masquer toute l'interface après disparition est plutôt un vestige. Une raison de l'utiliser encore pourrait être d'éviter des interactions indésirables (par ex. infobulles au survol) d'éléments d'interface que DynamicCam ne masque pas encore correctement.\n\nL'opacité de l'interface masquée est bien sûr de 0, vous ne pouvez donc pas choisir une opacité différente ni garder d'éléments d'interface visibles (sauf l'indicateur IPS).\n\nPendant le combat, nous ne pouvons pas modifier le statut masqué des éléments d'interface protégés. Par conséquent, ces éléments sont toujours « juste estompés » pendant le combat. Notez que l'opacité des « points » sur la mini-carte ne peut pas être réduite. Ainsi, si vous essayez de masquer la mini-carte, les « points » sont toujours visibles pendant le combat.\n\nSi vous cochez cette case pour la situation actuellement active, elle ne sera pas appliquée immédiatement, car cela masquerait également cette fenêtre de réglages. Vous devez entrer dans la situation pour que cela prenne effet, ce qui est également possible avec la case à cocher « Activer » de la situation ci-dessus.\n\nNotez également que masquer toute l'interface annule les interactions avec la boîte aux lettres ou les PNJ. Ne l'utilisez donc pas pour de telles situations !"
L["Keep FPS indicator"] = "Garder l'indicateur IPS"
L["Do not fade out or hide the FPS indicator (the one you typically toggle with Ctrl + R)."] = "Ne pas estomper ou masquer l'indicateur IPS (celui que vous basculez généralement avec Ctrl + R)."
L["Fade Opacity"] = "Opacité de disparition"
L["Fade the UI to this opacity when entering the situation."] = "Estompe l'interface à cette opacité lors de l'entrée dans la situation."
L["Excluded UI elements"] = "Éléments d'interface exclus"
L["Keep Alerts"] = "Garder les alertes"
L["Still show alert popups from completed achievements, Covenant Renown, etc."] = "Affiche toujours les popups d'alerte des hauts-faits accomplis, du renom de congrégation, etc."
L["Keep Tooltip"] = "Garder l'infobulle"
L["Still show the game tooltip, which appears when you hover your mouse cursor over UI or world elements."] = "Affiche toujours l'infobulle du jeu, qui apparaît lorsque vous survolez avec votre curseur des éléments de l'interface ou du monde."
L["Keep Minimap"] = "Garder la mini-carte"
L["<keepMinimap_desc>"] = "Ne pas estomper la mini-carte.\n\nNotez que nous ne pouvons pas réduire l'opacité des « points » sur la mini-carte. Ceux-ci ne peuvent être masqués qu'avec l'ensemble de la mini-carte, lorsque l'interface est estompée à 0 opacité."
L["Keep Chat Box"] = "Garder la fenêtre de discussion"
L["Do not fade out the chat box."] = "Ne pas estomper la fenêtre de discussion."
L["Keep Tracking Bar"] = "Garder la barre d'expérience/réputation"
L["Do not fade out the tracking bar (XP, AP, reputation)."] = "Ne pas estomper la barre d'expérience/réputation (XP, AP, réputation)."
L["Keep Party/Raid"] = "Garder Groupe/Raid"
L["Do not fade out the Party/Raid frame."] = "Ne pas estomper le cadre de Groupe/Raid."
L["Keep Encounter Frame (Skyriding Vigor)"] = "Garder le cadre de rencontre (Vigueur du Vol dynamique)"
L["Do not fade out the Encounter Frame, which while skyriding is the Vigor display."] = "Ne pas estomper le cadre de rencontre, qui est l'affichage de la Vigueur pendant le Vol dynamique."
L["Keep additional frames"] = "Garder des cadres supplémentaires"
L["<keepCustomFrames_desc>"] = "La zone de texte ci-dessous vous permet de définir tout cadre que vous souhaitez garder pendant l'interaction avec un PNJ.\n\nUtilisez la commande console /fstack pour connaître les noms des cadres.\n\nPar exemple, vous voudrez peut-être garder les icônes d'améliorations à côté de la mini-carte pour pouvoir descendre de monture pendant l'interaction avec un PNJ en cliquant sur l'icône appropriée."
L["Custom frames to keep"] = "Cadres personnalisés à garder"
L["Separated by commas."] = "Séparés par des virgules."
L["Emergency Fade In"] = "Réapparition d'urgence"
L["Pressing Esc fades the UI back in."] = "Appuyer sur Échap réaffiche l'interface."
L["<emergencyShow_desc>"] = [[Parfois, vous devez afficher l'interface même dans des situations où vous voulez normalement qu'elle soit masquée. Les anciennes versions de DynamicCam avaient établi que l'interface s'affichait chaque fois que la touche Échap était pressée. L'inconvénient est que l'interface s'affiche également lorsque la touche Échap est utilisée à d'autres fins comme fermer des fenêtres, annuler des incantations, etc. Décocher la case ci-dessus désactive cela.

Notez cependant que vous pouvez vous verrouiller hors de l'interface de cette façon ! Une meilleure alternative à la touche Échap sont les commandes console suivantes, qui affichent ou masquent l'interface selon les paramètres « Masquer l'interface » de la situation actuelle :

    /showUI
    /hideUI

Pour un raccourci clavier pratique, mettez /showUI dans une macro et assignez-lui une touche dans votre fichier « bindings-cache.wtf ». Par ex. :

    bind ALT+F11 MACRO Nom De Votre Macro

Si l'édition du fichier « bindings-cache.wtf » vous rebute, vous pouvez utiliser un addon de raccourcis comme « BindPad ».

Utiliser /showUI ou /hideUI sans aucun argument prend le temps d'apparition ou de disparition de la situation actuelle. Mais vous pouvez aussi fournir un temps de transition différent. Par ex. :

    /showUI 0

pour afficher l'interface sans aucun délai.]]
L["<hideUIHelp_desc>"] = "Pendant que vous configurez vos effets de masquage d'interface souhaités, il peut être ennuyeux que ce cadre de réglages « Interface » disparaisse également. Si cette case est cochée, il ne sera pas estompé.\n\nCe réglage est global pour toutes les situations."
L["Do not fade out this \"Interface\" settings frame."] = "Ne pas estomper ce cadre de réglages « Interface »."
L["Situation Controls"] = "Contrôles de situation"
L["<situationControls_help>"] = "C'est ici que vous contrôlez quand une situation est active. Une connaissance de l'API de l'interface WoW peut être requise. Si vous êtes satisfait des situations d'origine de DynamicCam, ignorez simplement cette section. Mais si vous souhaitez créer des situations personnalisées, vous pouvez consulter les situations d'origine ici. Vous pouvez également les modifier, mais attention : vos paramètres modifiés persisteront même si les futures versions de DynamicCam introduisent des mises à jour importantes.\n\n"
L["Priority"] = "Priorité"
L["The priority of this situation.\nMust be a number."] = "La priorité de cette situation.\nDoit être un nombre."
L["Restore stock setting"] = "Restaurer le réglage d'origine"
L["Your \"Priority\" deviates from the stock setting for this situation (%s). Click here to restore it."] = "Votre « Priorité » diffère du réglage d'origine pour cette situation (%s). Cliquez ici pour la restaurer."
L["<priority_desc>"] = "Si les conditions de plusieurs situations DynamicCam différentes sont remplies en même temps, la situation avec la priorité la plus élevée est activée. Par exemple, chaque fois que la condition de « Monde (intérieur) » est remplie, la condition de « Monde » est également remplie. Mais comme « Monde (intérieur) » a une priorité plus élevée que « Monde », elle est priorisée. Vous pouvez également voir les priorités de toutes les situations dans le menu déroulant ci-dessus.\n\n"
L["Error message:"] = "Message d'erreur :"
L["Events"] = "Évènements"
L["Separated by commas."] = "Séparés par des virgules."
L["Your \"Events\" deviate from the default for this situation. Click here to restore them."] = "Vos « Évènements » diffèrent du réglage d'origine pour cette situation. Cliquez ici pour les restaurer."
L["<events_desc>"] = [[Ici, vous définissez tous les évènements en jeu sur lesquels DynamicCam doit vérifier la condition de cette situation, pour y entrer ou en sortir le cas échéant.

Vous pouvez en apprendre davantage sur les évènements en jeu en utilisant le Journal d’évènements de WoW.
Pour l'ouvrir, tapez ceci dans la console :

  /eventtrace

Une liste de tous les évènements possibles peut également être trouvée ici :
https://warcraft.wiki.gg/wiki/Events

]]
L["Initialisation"] = "Initialisation"
L["Initialisation Script"] = "Script d'initialisation"
L["Lua code using the WoW UI API."] = "Code Lua utilisant l'API de l'interface WoW."
L["Your \"Initialisation Script\" deviates from the stock setting for this situation. Click here to restore it."] = "Votre « Script d'initialisation » diffère du réglage d'origine pour cette situation. Cliquez ici pour le restaurer."
L["<initialisation_desc>"] = [[Le script d'initialisation d'une situation est exécuté une fois lors du chargement de DynamicCam (et également lorsque la situation est modifiée). Vous y mettriez généralement des éléments que vous souhaitez réutiliser dans l'un des autres scripts (condition, entrée, sortie). Cela peut rendre ces autres scripts un peu plus courts.

Par exemple, le script d'initialisation de la situation « Pierre de foyer/Téléportation » définit la table « this.spells », qui inclut les ID de sort des sorts de téléportation. Le script de condition peut alors simplement accéder à « this.spells » à chaque fois qu'il est exécuté.

Comme dans cet exemple, vous pouvez partager n'importe quel objet de données entre les scripts d'une situation en le plaçant dans la table « this ».

]]
L["Condition"] = "Condition"
L["Condition Script"] = "Script de condition"
L["Lua code using the WoW UI API.\nShould return \"true\" if and only if the situation should be active."] = "Code Lua utilisant l'API de l'interface WoW.\nDoit retourner « true » si et seulement si la situation doit être active."
L["Your \"Condition Script\" deviates from the stock setting for this situation. Click here to restore it."] = "Votre « Script de condition » diffère du réglage d'origine pour cette situation. Cliquez ici pour le restaurer."
L["<condition_desc>"] = [[Le script de condition d'une situation est exécuté chaque fois qu'un évènement en jeu de cette situation est déclenché. Le script doit retourner « true » si et seulement si cette situation doit être active.

Par exemple, le script de condition de la situation « Ville » utilise la fonction API WoW « IsResting() » pour vérifier si vous êtes actuellement dans une zone de repos :

  return IsResting()

De même, le script de condition de la situation « Ville (intérieur) » utilise également la fonction API WoW « IsIndoors() » pour vérifier si vous êtes à l'intérieur :

  return IsResting() and IsIndoors()

Une liste des fonctions API WoW peut être trouvée ici :
https://warcraft.wiki.gg/wiki/World_of_Warcraft_API

]]
L["Entering"] = "Entrée"
L["On-Enter Script"] = "Script d'entrée"
L["Your \"On-Enter Script\" deviates from the stock setting for this situation. Click here to restore it."] = "Votre « Script d'entrée » diffère du réglage d'origine pour cette situation. Cliquez ici pour le restaurer."
L["<executeOnEnter_desc>"] = [[Le script d'entrée d'une situation est exécuté chaque fois que l'on entre dans la situation.

Jusqu'à présent, le seul exemple pour cela est la situation « Pierre de foyer/Téléportation » dans laquelle nous utilisons la fonction API WoW « UnitCastingInfo() » pour déterminer la durée d'incantation du sort actuel. Nous assignons ensuite cela aux variables « this.transitionTime » et « this.rotationTime », de sorte qu'un zoom ou une rotation (voir « Actions de situation ») puisse prendre exactement aussi longtemps que l'incantation du sort. (Tous les sorts de téléportation n'ont pas les mêmes temps d'incantation.)

]]
L["Exiting"] = "Sortie"
L["On-Exit Script"] = "Script de sortie"
L["Your \"On-Exit Script\" deviates from the stock setting for this situation. Click here to restore it."] = "Votre « Script de sortie » diffère du réglage d'origine pour cette situation. Cliquez ici pour le restaurer."
L["Exit Delay"] = "Délai de sortie"
L["Wait for this many seconds before exiting this situation."] = "Attendre ce nombre de secondes avant de quitter cette situation."
L["Your \"Exit Delay\" deviates from the stock setting for this situation. Click here to restore it."] = "Votre « Délai de sortie » diffère du réglage d'origine pour cette situation. Cliquez ici pour le restaurer."
L["<executeOnExit_desc>"] = [[Le script de sortie d'une situation est exécuté chaque fois que l'on quitte la situation. Jusqu'à présent, aucune situation n'utilise cela.

Le délai détermine combien de secondes attendre avant de quitter la situation. Jusqu'à présent, le seul exemple pour cela est la situation « Pêche », où le délai vous donne le temps de relancer votre ligne sans quitter la situation.

]]
L["Export"] = "Exporter"
L["Coming soon(TM)."] = "Bientôt(TM)."
L["Import"] = "Importer"
L["<welcomeMessage>"] = [[Nous sommes ravis que vous soyez ici et nous espérons que vous aurez du plaisir avec l'addon.

DynamicCam (DC) a été lancé en mai 2016 par mpstark lorsque les développeurs WoW de Blizzard ont introduit les fonctionnalités expérimentales ActionCam dans le jeu. Le but principal de DC a été de fournir une interface utilisateur pour les paramètres de l'ActionCam. Dans le jeu, l'ActionCam est toujours désignée comme « expérimentale » et il n'y a eu aucun signe de Blizzard pour la développer davantage. Il y a quelques lacunes, mais nous devrions être reconnaissants que l'ActionCam ait été laissée dans le jeu pour les passionnés comme nous. :-) DC ne vous permet pas seulement de changer les paramètres de l'ActionCam mais d'avoir différents paramètres pour différentes situations de jeu. Non lié à l'ActionCam, DC fournit également des fonctionnalités concernant le zoom de la caméra et la disparition de l'interface.

Le travail de mpstark sur DC a continué jusqu'en août 2018. Bien que la plupart des fonctionnalités fonctionnaient bien pour une base d'utilisateurs substantielle, mpstark a toujours considéré DC comme étant en état bêta et en raison de son intérêt décroissant pour WoW, il a fini par ne pas reprendre son travail. À cette époque, Ludius avait déjà commencé à faire des ajustements à DC pour lui-même, ce qui a été remarqué par Weston (alias dernPerkins) qui au début de 2020 a réussi à entrer en contact avec mpstark, menant Ludius à reprendre le développement. La première version non-bêta 1.0 a été publiée en mai 2020 incluant les ajustements de Ludius jusqu'à ce point. Par la suite, Ludius a commencé à travailler sur une refonte de DC résultant en la version 2.0 publiée à l'automne 2022.

Lorsque mpstark a commencé DC, son objectif était de faire la plupart des personnalisations en jeu au lieu d'avoir à changer le code source. Cela a rendu plus facile l'expérimentation, en particulier avec les différentes situations de jeu. À partir de la version 2.0, ces paramètres avancés ont été déplacés vers une section spéciale appelée « Contrôles de situation ». La plupart des utilisateurs n'en auront probablement jamais besoin, mais pour les « utilisateurs avancés », elle est toujours disponible. Un risque de faire des changements là-bas est que les paramètres utilisateur enregistrés remplacent toujours les paramètres d'origine de DC, même si de nouvelles versions de DC apportent des paramètres d'origine mis à jour. Par conséquent, un avertissement est affiché en haut de cette page chaque fois que vous avez des situations d'origine avec des « Contrôles de situation » modifiés.

Si vous pensez qu'une des situations d'origine de DC devrait être changée, vous pouvez toujours en créer une copie avec vos modifications. N'hésitez pas à exporter cette nouvelle situation et à la poster sur la page CurseForge de DC. Nous pourrions alors l'ajouter comme une nouvelle situation d'origine à part entière. Vous êtes également les bienvenus pour exporter et poster votre profil DC entier, car nous sommes toujours à la recherche de nouveaux préréglages de profil qui permettent aux nouveaux venus une entrée plus facile dans DC. Si vous trouvez un problème ou voulez faire une suggestion, laissez juste une note dans les commentaires CurseForge ou encore mieux utilisez les Issues sur GitHub. Si vous souhaitez contribuer, n'hésitez pas aussi à ouvrir une pull request là-bas.

Voici quelques commandes slash pratiques :

    `/dynamiccam` ou `/dc` ouvre ce menu.
    `/zoominfo` ou `/zi` affiche le niveau de zoom actuel.

    `/zoom #1 #2` zoome au niveau #1 en #2 secondes.
    `/yaw #1 #2` fait pivoter la caméra de #1 degrés en #2 secondes (#1 négatif pour pivoter à droite).
    `/pitch #1 #2` incline la caméra de #1 degrés (#1 négatif pour incliner vers le haut).


]]
L["About"] = "À propos"
L["The following game situations have \"Situation Controls\" deviating from DynamicCam's stock settings.\n\n"] = "Les situations de jeu suivantes ont des « Contrôles de situation » différant des paramètres d'origine de DynamicCam.\n\n"
L["<situationControlsWarning>"] = "\nSi vous faites cela exprès, c'est très bien. Soyez juste conscient que toute mise à jour de ces paramètres par les développeurs de DynamicCam sera toujours remplacée par votre version modifiée (possiblement obsolète). Vous pouvez vérifier l'onglet « Contrôles de situation » de chaque situation pour les détails. Si vous n'êtes pas au courant de modifications des « Contrôles de situation » de votre part et voulez simplement restaurer les paramètres de contrôle d'origine pour *toutes* les situations, cliquez sur ce bouton :"
L["Restore all stock Situation Controls"] = "Restaurer tous les Contrôles de situation d'origine"
L["Hello and welcome to DynamicCam!"] = "Bonjour et bienvenue sur DynamicCam !"
L["Profiles"] = "Profils"
L["Manage Profiles"] = "Gérer les profils"
L["<manageProfilesWarning>"] = "Comme beaucoup d'addons, DynamicCam utilise la bibliothèque « AceDB-3.0 » pour gérer les profils. Ce que vous devez comprendre, c'est qu'il n'y a rien comme « Enregistrer le profil » ici. Vous pouvez seulement créer de nouveaux profils et vous pouvez copier les paramètres d'un autre profil dans celui actuellement actif. Quel que soit le changement que vous faites pour le profil actuellement actif, il est immédiatement enregistré ! Il n'y a rien comme « annuler » ou « ignorer les modifications ». Le bouton « Réinitialiser le profil » réinitialise seulement au profil par défaut global.\n\nDonc, si vous aimez vos paramètres DynamicCam, vous devriez créer un autre profil dans lequel vous copiez ces paramètres comme sauvegarde. Lorsque vous n'utilisez pas ce profil de sauvegarde comme votre profil actif, vous pouvez expérimenter avec les paramètres et revenir à votre profil original à tout moment en sélectionnant votre profil de sauvegarde dans la boîte « Copier de ».\n\nSi vous voulez changer de profil via macro, vous pouvez utiliser ce qui suit :\n/run DynamicCam.db:SetProfile(\"Nom du profil ici\")\n\n"
L["Profile presets"] = "Préréglages de profil"
L["Import / Export"] = "Importer / Exporter"
L["DynamicCam"] = "DynamicCam"
L["Disabled"] = "Désactivé"
L["Your DynamicCam addon lets you adjust horizontal and vertical mouse look speed individually! Just go to the \"Mouse Look\" settings of DynamicCam to make the adjustments there."] = "Votre addon DynamicCam vous permet d'ajuster la vitesse de vision à la souris horizontale et verticale individuellement ! Allez simplement dans les paramètres « Vision à la souris » de DynamicCam pour y faire les ajustements."
L["Attention"] = "Attention"
L["The \"%s\" setting is disabled by DynamicCam, while you are using the horizontal camera over shoulder offset."] = "Le paramètre « %s » est désactivé par DynamicCam, pendant que vous utilisez le décalage horizontal de la caméra au-dessus de l'épaule."
L["While you are using horizontal camera offset, DynamicCam prevents CameraKeepCharacterCentered!"] = "Pendant que vous utilisez le décalage horizontal de caméra, DynamicCam empêche CameraKeepCharacterCentered !"
L["While you are using horizontal camera offset, DynamicCam prevents CameraReduceUnexpectedMovement!"] = "Pendant que vous utilisez le décalage horizontal de caméra, DynamicCam empêche CameraReduceUnexpectedMovement !"
L["While you are using vertical camera pitch, DynamicCam prevents CameraKeepCharacterCentered!"] = "Pendant que vous utilisez l'inclinaison verticale de caméra, DynamicCam empêche CameraKeepCharacterCentered !"
L["cameraView=%s prevented by DynamicCam!"] = "cameraView=%s empêché par DynamicCam !"

-- MouseZoom
L["Current\nZoom\nValue"] = "Valeur de\nZoom\nActuelle"
L["Reactive\nZoom\nTarget"] = "Cible de\nZoom\nRéactif"

-- Core
L["Enter name for custom situation:"] = "Entrez le nom pour la situation personnalisée :"
L["Create"] = "Créer"
L["Cancel"] = "Annuler"

-- DefaultSettings
L["City"] = "Ville"
L["City (Indoors)"] = "Ville (Intérieur)"
L["World"] = "Monde"
L["World (Indoors)"] = "Monde (Intérieur)"
L["World (Combat)"] = "Monde (Combat)"
L["Dungeon/Scenario"] = "Donjon/Scénario"
L["Dungeon/Scenario (Outdoors)"] = "Donjon/Scénario (Extérieur)"
L["Dungeon/Scenario (Combat, Boss)"] = "Donjon/Scénario (Combat, Boss)"
L["Dungeon/Scenario (Combat, Trash)"] = "Donjon/Scénario (Combat, Trash)"
L["Raid"] = "Raid"
L["Raid (Outdoors)"] = "Raid (Extérieur)"
L["Raid (Combat, Boss)"] = "Raid (Combat, Boss)"
L["Raid (Combat, Trash)"] = "Raid (Combat, Trash)"
L["Arena"] = "Arène"
L["Arena (Combat)"] = "Arène (Combat)"
L["Battleground"] = "Champ de bataille"
L["Battleground (Combat)"] = "Champ de bataille (Combat)"
L["Mounted (any)"] = "Monture (toute)"
L["Mounted (only flying-mount)"] = "Monture (volante uniquement)"
L["Mounted (only flying-mount + airborne)"] = "Monture (volante uniquement + en l'air)"
L["Mounted (only flying-mount + airborne + Skyriding)"] = "Monture (volante uniquement + en l'air + vol dynamique)"
L["Mounted (only flying-mount + Skyriding)"] = "Monture (volante uniquement + vol dynamique)"
L["Mounted (only airborne)"] = "Monture (en l'air uniquement)"
L["Mounted (only airborne + Skyriding)"] = "Monture (en l'air uniquement + vol dynamique)"
L["Mounted (only Skyriding)"] = "Monture (vol dynamique uniquement)"
L["Druid Travel Form"] = "Forme de voyage druide"
L["Dracthyr Soar"] = "Dracthyr Envol"
L["Skyriding Race"] = "Course de vol dynamique"
L["Taxi"] = "Taxi"
L["Vehicle"] = "Véhicule"
L["Hearth/Teleport"] = "Pierre de foyer/Téléportation"
L["Annoying Spells"] = "Sorts ennuyeux"
L["NPC Interaction"] = "Interaction PNJ"
L["Mailbox"] = "Boîte aux lettres"
L["Fishing"] = "Pêche"
L["Gathering"] = "Récolte"
L["AFK"] = "ABS"
L["Pet Battle"] = "Mascotte"
L["Professions Frame Open"] = "Fenêtre de métier ouverte"
