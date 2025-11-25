local L = LibStub("AceLocale-3.0"):NewLocale("DynamicCam", "itIT")
if not L then return end

-- Options
L["Reset"] = "Ripristina"
L["Reset to global default"] = "Usa predefinito globale"
L["(To restore the settings of a specific profile, restore the profile in the \"Profiles\" tab.)"] = "(Per ripristinare le impostazioni di un profilo specifico, ripristina il profilo nella scheda « Profili ».)"
L["Currently overridden by the active situation \"%s\"."] = "Attualmente ignorato dalla situazione attiva « %s »."
L["Override Standard Settings"] = "Sovrascrivi Impostazioni Standard"
L["<overrideStandardToggle_desc>"] = "Selezionando questa casella potrete configurare le impostazioni di questa categoria. Queste Impostazioni della Situazione sovrascrivono quindi le Impostazioni Standard non appena questa situazione è attiva. Deselezionare la casella cancellerà le Impostazioni della Situazione per questa categoria."
L["Standard Settings"] = "Impostazioni Standard"
L["Situation Settings"] = "Impostazioni della Situazione"
L["<standardSettings_desc>"] = "Queste Impostazioni Standard vengono applicate quando non c'è nessuna situazione attiva o quando la situazione attiva non ha Impostazioni della Situazione configurate per sovrascrivere le Impostazioni Standard."
L["<standardSettingsOverridden_desc>"] = "Le categorie contrassegnate in verde sono attualmente sovrascritte dalla situazione attiva. Di conseguenza, non vedrete alcun effetto dalla modifica delle Impostazioni Standard delle categorie verdi finché la situazione che le sovrascrive è attiva."
L["These Situation Settings override the Standard Settings when the respective situation is active."] = "Queste Impostazioni della Situazione sovrascrivono le Impostazioni Standard quando la situazione corrispondente è attiva."
L["Mouse Zoom"] = "Zoom del mouse"
L["Maximum Camera Distance"] = "Distanza massima della telecamera"
L["How many yards the camera can zoom away from your character."] = "Di quanti metri la telecamera può allontanarsi dal tuo personaggio."
L["Camera Zoom Speed"] = "Velocità dello zoom della telecamera"
L["How fast the camera can zoom."] = "Quanto velocemente la telecamera può zoomare."
L["Zoom Increments"] = "Incrementi dello zoom"
L["How many yards the camera should travel for each \"tick\" of the mouse wheel."] = "Quanti metri la telecamera deve percorrere per ogni « scatto » della rotella del mouse."
L["Use Reactive Zoom"] = "Usa zoom reattivo"
L["Quick-Zoom Additional Increments"] = "Quick-Zoom incrementi aggiuntivi"
L["How many yards per mouse wheel \"tick\" should be added when quick-zooming."] = "Quanti metri per « scatto » della rotella del mouse devono essere aggiunti durante lo zoom rapido."
L["Quick-Zoom Enter Threshold"] = "Soglia di attivazione dello zoom rapido"
L["How many yards the \"Reactive Zoom Target\" and the \"Current Zoom Value\" have to be apart to enter quick-zooming."] = "Quanti metri devono separare il « bersaglio di zoom reattivo » e il « valore di zoom attuale » per entrare in modalità zoom rapido."
L["Maximum Zoom Time"] = "Tempo massimo di zoom"
L["The maximum time the camera should take to make \"Current Zoom Value\" equal to \"Reactive Zoom Target\"."] = "Il tempo massimo che la telecamera dovrebbe impiegare per rendere il « valore di zoom attuale » uguale al « bersaglio di zoom reattivo »."
L["Help"] = "Aiuto"
L["Toggle Visual Aid"] = "Attiva/Disattiva Aiuto Visivo"
L["<reactiveZoom_desc>"] = "Con lo Zoom Reattivo di DynamicCam, la rotellina del mouse controlla il cosiddetto « Bersaglio Zoom Reattivo ». Ogni volta che il « Bersaglio Zoom Reattivo » e il « Valore Zoom Attuale » sono diversi, DynamicCam cambia il « Valore Zoom Attuale » finché non corrisponde di nuovo al « Bersaglio Zoom Reattivo ».\n\nLa velocità con cui avviene questo cambiamento di zoom dipende dalla « Velocità dello zoom della telecamera » e dal « Tempo massimo di zoom ». Se il « Tempo massimo di zoom » è impostato su un valore basso, il cambiamento di zoom sarà sempre eseguito rapidamente, indipendentemente dall'impostazione « Velocità dello zoom della telecamera ». Per ottenere un cambiamento di zoom più lento, è necessario impostare il « Tempo massimo di zoom » su un valore più alto e la « Velocità dello zoom della telecamera » su un valore più basso.\n\nPer abilitare uno zoom più veloce con un movimento più rapido della rotellina del mouse, c'è il « Quick-Zoom »: se il « Bersaglio Zoom Reattivo » è più lontano dal « Valore Zoom Attuale » rispetto alla « Soglia di attivazione dello zoom rapido », la quantità di « Incrementi aggiuntivi Quick-Zoom » viene aggiunta ad ogni scatto della rotellina del mouse.\n\nPer farsi un'idea di come funziona, è possibile attivare l'aiuto visivo mentre si trovano le impostazioni ideali. È inoltre possibile spostare liberamente questo grafico facendo clic sinistro e trascinandolo. Un clic destro lo chiude."
L["Enhanced minimal zoom-in"] = "Zoom minimo migliorato"
L["<enhancedMinZoom_desc>"] = "Lo zoom reattivo consente di avvicinarsi più del livello 1. È possibile ottenere ciò allontanando la visuale di uno scatto della rotellina del mouse dalla prima persona.\n\nCon lo « Zoom minimo migliorato » forziamo la telecamera a fermarsi anche a questo livello minimo di zoom durante l'avvicinamento, prima che scatti in prima persona.\n\n|cFFFF0000L'attivazione dello « Zoom minimo migliorato » può costare fino al 15% di FPS in situazioni limitate dalla CPU.|r"
L["/reload of the UI required!"] = "È richiesto un /reload dell'interfaccia!"
L["Mouse Look"] = "Visuale col mouse"
L["Horizontal Speed"] = "Velocità orizzontale"
L["How much the camera yaws horizontally when in mouse look mode."] = "Di quanto imbardata la telecamera orizzontalmente in modalità visuale col mouse."
L["Vertical Speed"] = "Velocità verticale"
L["How much the camera pitches vertically when in mouse look mode."] = "Di quanto si inclina la telecamera verticalmente in modalità visuale col mouse."
L["<mouseLook_desc>"] = "Di quanto si muove la telecamera quando muovi il mouse in modalità « visuale col mouse »; cioè mentre il tasto sinistro o destro del mouse è premuto.\n\nIl cursore « Visuale col mouse » delle impostazioni dell'interfaccia predefinite di WoW controlla la velocità orizzontale e verticale allo stesso tempo: impostando automaticamente la velocità orizzontale a 2 x la velocità verticale. DynamicCam sovrascrive questo e ti consente una configurazione più personalizzata."
L["Horizontal Offset"] = "Scostamento orizzontale"
L["Camera Over Shoulder Offset"] = "Scostamento della telecamera sopra la spalla"
L["Positions the camera left or right from your character."] = "Posiziona la telecamera a sinistra o a destra dal tuo personaggio."
L["<cameraOverShoulder_desc>"] = "Affinché ciò abbia effetto, DynamicCam disattiva automaticamente e temporaneamente l'impostazione di WoW per la Chinetosi. Quindi, se avete bisogno dell'impostazione Chinetosi, non utilizzate lo scostamento orizzontale in queste situazioni.\n\nQuando selezionate il vostro personaggio, WoW centra automaticamente la telecamera. Non c'è nulla che possiamo fare al riguardo. Inoltre, non possiamo fare nulla per gli scostamenti a scatti che possono verificarsi in caso di collisioni tra telecamera e parete. Un rimedio è quello di utilizzare uno scostamento minimo o nullo all'interno degli edifici.\n\nInoltre, stranamente WoW applica lo scostamento in modo diverso a seconda del modello del personaggio o della cavalcatura. Per tutti coloro che preferiscono uno scostamento costante, Ludius sta lavorando a un altro addon („CameraOverShoulder Fix“), per risolvere questo problema."
L["Adjust shoulder offset according to zoom level"] = "Regola lo scostamento in base al livello di zoom"
L["Enable"] = "Attiva"
L["and"] = "e"
L["No offset when below this zoom level:"] = "Nessuno scostamento sotto questo livello di zoom:"
L["When the camera is closer than this zoom level, the offset has reached zero."] = "Quando la telecamera è più vicina di questo livello di zoom, lo scostamento è zero."
L["Real offset when above this zoom level:"] = "Scostamento completo sopra questo livello di zoom:"
L["When the camera is further away than this zoom level, the offset has reached its set value."] = "Quando la telecamera è più lontana di questo livello di zoom, lo scostamento ha raggiunto il suo valore impostato."
L["<shoulderOffsetZoom_desc>"] = "Fa in modo che lo scostamento sopra la spalla passi gradualmente a zero durante lo zoom avanti. I due cursori definiscono tra quali livelli di zoom avviene questa transizione. Questa impostazione è globale e non specifica per situazione."
L["Vertical Pitch"] = "Inclinazione verticale"
L["Pitch (on ground)"] = "Inclinazione (a terra)"
L["Pitch (flying)"] = "Inclinazione (in volo)"
L["Down Scale"] = "Fattore di riduzione"
L["Smart Pivot Cutoff Distance"] = "Distanza limite perno intelligente"
L["<pitch_desc>"] = "Se la telecamera è inclinata verso l'alto (valore di « Inclinazione » più basso), il « Fattore di riduzione » determina quanto questo entri in vigore guardando il proprio personaggio dall'alto. Impostare il « Fattore di riduzione » su 0 annulla l'effetto di un'inclinazione verso l'alto guardando dall'alto. Al contrario, il « Fattore di riduzione » ha poco o nessun effetto quando non si guarda dall'alto o se la telecamera è inclinata verso il basso (valore di « Inclinazione » più alto).\n\nSi dovrebbe quindi prima trovare l'impostazione preferita di « Inclinazione » guardando il proprio personaggio da dietro. Dopo aver optato per un'inclinazione verso l'alto, trovare l'impostazione preferita di « Fattore di riduzione » guardando dall'alto.\n\n\nQuando la telecamera entra in collisione con il suolo, normalmente esegue un'inclinazione verso l'alto nel punto di collisione telecamera-suolo. Un'alternativa è che la telecamera si avvicini ai piedi del proprio personaggio mentre esegue questa inclinazione. La « Distanza limite perno intelligente » determina la distanza entro cui la telecamera deve trovarsi rispetto al proprio personaggio affinché ciò accada. Con un valore di 0, la telecamera non si avvicina mai (predefinito di WoW). Al valore massimo di 39, invece, lo fa sempre.\n\n"
L["Target Focus"] = "Focus bersaglio"
L["Enemy Target"] = "Bersaglio nemico"
L["Horizontal Strength"] = "Forza orizzontale"
L["Vertical Strength"] = "Forza verticale"
L["Interaction Target (NPCs)"] = "Bersaglio interazione (PNG)"
L["<targetFocus_desc>"] = "Se abilitato, la telecamera tenta automaticamente di portare il bersaglio più vicino al centro dello schermo. La forza determina l'intensità di questo effetto.\n\nSe sia « Bersaglio nemico » che « Bersaglio interazione » sono abilitati, sembra esserci uno strano bug con quest'ultimo: quando si interagisce con un PNG per la prima volta, la telecamera si sposta dolcemente verso la sua nuova angolazione come previsto. Ma quando si esce dall'interazione, scatta immediatamente alla sua angolazione precedente. Se si riavvia l'interazione, scatta di nuovo bruscamente alla nuova angolazione. Questo è ripetibile ogni volta che si parla con un nuovo PNG: solo la prima transizione è fluida, tutte le successive sono immediate.\nUna soluzione alternativa, se si desidera utilizzare sia « Bersaglio nemico » che « Bersaglio interazione », è attivare « Bersaglio nemico » solo per le situazioni DynamicCam in cui è necessario e in cui le interazioni con i PNG sono improbabili (come in Combattimento)."
L["Head Tracking"] = "Tracciamento testa"
L["<headTrackingEnable_desc>"] = "(Questo potrebbe anche essere usato come valore continuo tra 0 e 1, ma viene semplicemente moltiplicato per « Forza (in piedi) » e « Forza (in movimento) » rispettivamente. Quindi non c'è davvero bisogno di un altro cursore.)"
L["Strength (standing)"] = "Forza (in piedi)"
L["Inertia (standing)"] = "Inerzia (in piedi)"
L["Strength (moving)"] = "Forza (in movimento)"
L["Inertia (moving)"] = "Inerzia (in movimento)"
L["Inertia (first person)"] = "Inerzia (prima persona)"
L["Range Scale"] = "Scala di portata"
L["Camera distance beyond which head tracking is reduced or disabled. (See explanation below.)"] = "Distanza della telecamera oltre la quale il tracciamento della testa è ridotto o disabilitato. (Vedi spiegazione sotto.)"
L["(slider value transformed)"] = "(valore cursore trasformato)"
L["Dead Zone"] = "Zona morta"
L["Radius of head movement not affecting the camera. (See explanation below.)"] = "Raggio del movimento della testa che non influenza la telecamera. (Vedi spiegazione sotto.)"
L["(slider value devided by 10)"] = "(valore cursore diviso per 10)"
L["Requires /reload to come into effect!"] = "Richiede /reload per avere effetto!"
L["<headTracking_desc>"] = "Con il tracciamento della testa abilitato, la telecamera segue il movimento della testa del tuo personaggio. (Sebbene questo possa essere un vantaggio per l'immersione, può anche causare nausea se sei soggetto a chinetosi.)\n\nL'impostazione « Forza » determina l'intensità di questo effetto. Un valore di 0 disabilita il tracciamento della testa. L'impostazione « Inerzia » determina quanto velocemente la telecamera reagisce ai movimenti della testa. Un valore di 0 disabilita anche il tracciamento della testa. I tre casi « in piedi », « in movimento » e « prima persona » possono essere configurati individualmente. Non c'è un'impostazione « Forza » per « prima persona » poiché assume rispettivamente le impostazioni « Forza » di « in piedi » e « in movimento ». Se vuoi attivare o disattivare esclusivamente la « prima persona », usa i cursori « Inerzia » per disabilitare i casi indesiderati.\n\nCon l'impostazione « Scala di portata » puoi impostare la distanza della telecamera oltre la quale il tracciamento della testa è ridotto o disabilitato. Ad esempio, con il cursore impostato su 30 non avrai alcun tracciamento della testa quando la telecamera è a più di 30 metri dal tuo personaggio. Tuttavia, c'è una transizione graduale dal tracciamento completo a nessun tracciamento, che inizia a un terzo del valore del cursore. Ad esempio, se il valore è impostato su 30, hai il tracciamento completo quando la telecamera è più vicina di 10 metri. Oltre i 10 metri, il tracciamento della testa diminuisce gradualmente finché non scompare completamente oltre i 30 metri. Pertanto, il valore massimo di 117 consente un tracciamento completo alla massima distanza della telecamera di 39 metri. (Suggerimento: usa l'aiuto visivo di DynamicCam per « Zoom del mouse » per conoscere la distanza attuale della telecamera durante l'impostazione.)\n\nL'impostazione « Zona morta » può essere utilizzata per ignorare i movimenti della testa più piccoli. Un valore di 0 fa sì che la telecamera segua ogni minimo movimento della testa, mentre un valore maggiore fa sì che segua solo movimenti più ampi. Nota che la modifica di questa impostazione ha effetto solo dopo aver ricaricato l'interfaccia (digita /reload nella console)."
L["Situations"] = "Situazioni"
L["Select a situation to setup"] = "Seleziona una situazione da configurare"
L["<selectedSituation_desc>"] = "\n|cffffcc00Codici colore:|r\n|cFF808A87- Situazione disabilitata.|r\n- Situazione abilitata.\n|cFF00FF00- Situazione abilitata e attualmente attiva.|r\n|cFF63B8FF- Situazione abilitata con condizione soddisfatta ma priorità inferiore rispetto alla situazione attualmente attiva.|r\n|cFFFF6600- « Controlli situazione » originali modificati (ripristino consigliato).|r\n|cFFEE0000- « Controlli situazione » errati (correzione richiesta).|r"
L["If this box is checked, DynamicCam will enter the situation \"%s\" whenever its condition is fulfilled and no other situation with higher priority is active."] = "Se questa casella è selezionata, DynamicCam entrerà nella situazione « %s » ogni volta che la sua condizione è soddisfatta e nessun'altra situazione con priorità più alta è attiva."
L["Custom:"] = "Personalizzata:"
L["(modified)"] = "(modificata)"
L["Delete custom situation \"%s\".\n|cFFEE0000Attention: There will be no 'Are you sure?' prompt!|r"] = "Elimina situazione personalizzata « %s ».\n|cFFEE0000Attenzione: Non ci sarà alcun avviso « Sei sicuro? »!|r"
L["Create a new custom situation."] = "Crea una nuova situazione personalizzata."
L["Situation Actions"] = "Azioni situazione"
L["Setup stuff to happen while in a situation or when entering/exiting it."] = "Configura ciò che deve accadere mentre si è in una situazione o quando si entra/esce da essa."
L["Zoom/View"] = "Zoom/Vista"
L["Zoom to a certain zoom level or switch to a saved camera view when entering this situation."] = "Zooma a un certo livello o passa a una vista telecamera salvata quando si entra in questa situazione."
L["Set Zoom or Set View"] = "Imposta Zoom o Vista"
L["Zoom Type"] = "Tipo Zoom"
L["<viewZoomType_desc>"] = "Imposta Zoom: Zooma a un dato livello con opzioni avanzate di tempo di transizione e condizioni.\n\nImposta Vista: Passa a una vista telecamera salvata composta da un livello di zoom e un'angolazione fissi."
L["Set Zoom"] = "Imposta Zoom"
L["Set View"] = "Imposta Vista"
L["Set view to saved view:"] = "Imposta vista su vista salvata:"
L["Select the saved view to switch to when entering this situation."] = "Seleziona la vista salvata a cui passare quando si entra in questa situazione."
L["Instant"] = "Istantaneo"
L["Make view transitions instant."] = "Rendi le transizioni della vista istantanee."
L["Restore view when exiting"] = "Ripristina vista all'uscita"
L["When exiting the situation restore the camera position to what it was at the time of entering the situation."] = "Quando si esce dalla situazione, la posizione della telecamera viene ripristinata a quella che era al momento dell'ingresso nella situazione."
L["cameraSmoothNote"] = [[|cFFEE0000Attenzione:|r Stai usando lo « Stile di inseguimento visuale » di WoW che posiziona automaticamente la telecamera dietro il giocatore. Questo non funziona mentre sei in una vista salvata personalizzata. È possibile usare viste salvate personalizzate per situazioni in cui l'inseguimento non è necessario (es. interazione con PNG). Ma dopo essere usciti dalla situazione devi tornare a una vista standard non personalizzata affinché l'inseguimento funzioni di nuovo.]]
L["Restore to default view:"] = "Ripristina vista predefinita:"
L["<viewRestoreToDefault_desc>"] = [[Seleziona la vista predefinita a cui tornare quando si esce da questa situazione.

Vista 1:   Zoom 0, Inclinazione 0
Vista 2:   Zoom 5.5, Inclinazione 10
Vista 3:   Zoom 5.5, Inclinazione 20
Vista 4:   Zoom 13.8, Inclinazione 30
Vista 5:   Zoom 13.8, Inclinazione 10]]
L["WARNING"] = "ATTENZIONE"
L["You are using the same view as saved view and as restore-to-default view. Using a view as restore-to-default view will reset it. Only do this if you really want to use it as a non-customized saved view."] = "La tua vista salvata da impostare è la stessa della tua vista predefinita da ripristinare. Se una vista viene usata per il ripristino alle impostazioni predefinite, verrà reimpostata. Fallo solo se vuoi davvero usarla come vista salvata non personalizzata."
L["View %s is used as saved view in the situations:\n%sand as restore-to-default view in the situations:\n%s"] = "La vista %s è usata come vista salvata nelle situazioni:\n%se come vista da ripristinare a predefinito nelle situazioni:\n%s"
L["<view_desc>"] = [[WoW consente di salvare fino a 5 viste telecamera personalizzate. La Vista 1 è usata da DynamicCam per salvare la posizione della telecamera quando si entra in una situazione, in modo che possa essere ripristinata all'uscita, se selezioni la casella « Ripristina » sopra. Questo è particolarmente utile per situazioni brevi come l'interazione con PNG, permettendo di passare a una vista mentre si parla con il PNG e poi tornare a com'era la telecamera prima. Ecco perché la Vista 1 non può essere selezionata nel menu a tendina delle viste salvate sopra.

Le Viste 2, 3, 4 e 5 possono essere usate per salvare posizioni personalizzate. Per salvare una vista, porta semplicemente la telecamera allo zoom e all'angolazione desiderati. Poi digita il seguente comando nella console (dove # è il numero della vista 2, 3, 4 o 5):

  /saveView #

O in breve:

  /sv #

Nota che le viste salvate sono memorizzate da WoW. DynamicCam memorizza solo quali numeri di vista usare. Quindi, quando importi un nuovo profilo di situazioni DynamicCam con viste, probabilmente dovrai impostare e salvare le viste appropriate dopo.


DynamicCam fornisce anche un comando console per passare a una vista indipendentemente dall'entrata o uscita dalle situazioni:

  /setView #

Per rendere la transizione della vista istantanea, aggiungi una « i » dopo il numero della vista. Es. per passare immediatamente alla Vista salvata 3 digita:

  /setView 3 i

]]
L["Zoom Transition Time"] = "Tempo transizione zoom"
L["<transitionTime_desc>"] = "Il tempo in secondi che impiega per passare al nuovo valore di zoom.\n\nSe impostato più basso del possibile, la transizione sarà veloce quanto consente la velocità di zoom attuale (regolabile nelle impostazioni « Zoom del mouse » di DynamicCam).\n\nSe una situazione assegna la variabile « this.transitionTime » nel suo script di ingresso (vedi « Controlli situazione »), l'impostazione qui viene sovrascritta. Questo viene fatto es. nella situazione « Pietra del Ritorno/Teletrasporto » per consentire un tempo di transizione per la durata del lancio dell'incantesimo."
L["<zoomType_desc>"] = "\nImposta: Imposta sempre lo zoom a questo valore.\n\nIndietro: Imposta lo zoom solo se la telecamera è attualmente più vicina di questo.\n\nAvanti: Imposta lo zoom solo se la telecamera è attualmente più lontana di questo.\n\nIntervallo: Zooma avanti se più lontano del massimo dato. Zooma indietro se più vicino del minimo dato. Non fa nulla se lo zoom attuale è nell'intervallo [min, max]."
L["Set"] = "Imposta"
L["Out"] = "Indietro"
L["In"] = "Avanti"
L["Range"] = "Intervallo"
L["Don't slow"] = "Non rallentare"
L["Zoom transitions may be executed faster (but never slower) than the specified time above, if the \"Camera Zoom Speed\" (see \"Mouse Zoom\" settings) allows."] = "Le transizioni di zoom possono essere eseguite più velocemente (ma mai più lentamente) del tempo specificato sopra, se la « Velocità zoom telecamera » (vedi impostazioni « Zoom del mouse ») lo consente."
L["Zoom Value"] = "Valore zoom"
L["Zoom to this zoom level."] = "Zooma a questo livello."
L["Zoom out to this zoom level, if the current zoom level is less than this."] = "Zooma indietro a questo livello, se il livello attuale è inferiore."
L["Zoom in to this zoom level, if the current zoom level is greater than this."] = "Zooma avanti a questo livello, se il livello attuale è superiore."
L["Zoom Min"] = "Zoom Min"
L["Zoom Max"] = "Zoom Max"
L["Restore Zoom"] = "Ripristina zoom"
L["<zoomRestoreSetting_desc>"] = "Quando esci da una situazione (o esci dallo stato predefinito di nessuna situazione attiva), il livello di zoom attuale viene temporaneamente salvato, in modo che possa essere ripristinato una volta rientrati in questa situazione la volta successiva. Qui puoi selezionare come viene gestito.\n\nQuesta impostazione è globale per tutte le situazioni."
L["Restore Zoom Mode"] = "Modalità ripristino zoom"
L["<zoomRestoreSettingSelect_desc>"] = "\nMai: Quando si entra in una situazione, viene applicata l'impostazione di zoom reale (se presente) della situazione in ingresso. Nessuno zoom salvato viene preso in considerazione.\n\nSempre: Quando si entra in una situazione, viene usato l'ultimo zoom salvato di questa situazione. La sua impostazione reale viene presa in considerazione solo quando si entra nella situazione per la prima volta dopo il login.\n\nAdattivo: Lo zoom salvato viene usato solo in determinate circostanze. Es. solo quando si torna alla stessa situazione da cui si proveniva o quando lo zoom salvato soddisfa i criteri delle impostazioni di zoom « Avanti », « Indietro » o « Intervallo » della situazione."
L["Never"] = "Mai"
L["Always"] = "Sempre"
L["Adaptive"] = "Adattivo"
L["<zoom_desc>"] = [[Per determinare il livello di zoom attuale, puoi usare l'« Aiuto visivo » (attivabile nelle impostazioni « Zoom del mouse » di DynamicCam) o usare il comando console:

  /zoomInfo

O in breve:

  /zi]]
L["Rotation"] = "Rotazione"
L["Start a camera rotation when this situation is active."] = "Avvia una rotazione della telecamera quando questa situazione è attiva."
L["Rotation Type"] = "Tipo rotazione"
L["<rotationType_desc>"] = "\nContinuamente: La telecamera ruota orizzontalmente tutto il tempo mentre questa situazione è attiva. Consigliabile solo per situazioni in cui non muovi la telecamera con il mouse; es. lancio incantesimi di teletrasporto, taxi o assentarsi (AFK). La rotazione verticale continua non è possibile in quanto si fermerebbe alla vista perpendicolare dall'alto o dal basso.\n\nPer gradi: Dopo essere entrati nella situazione, cambia l'imbardata (orizzontale) e/o l'inclinazione (verticale) della telecamera attuale della quantità di gradi indicata."
L["Continuously"] = "Continuamente"
L["By Degrees"] = "Per gradi"
L["Acceleration Time"] = "Tempo di accelerazione"
L["Rotation Time"] = "Tempo di rotazione"
L["<accelerationTime_desc>"] = "Se imposti un tempo maggiore di 0 qui, la rotazione continua non inizierà immediatamente alla massima velocità ma impiegherà quel tempo per accelerare. (Percettibile solo per velocità di rotazione relativamente elevate.)"
L["<rotationTime_desc>"] = "Quanto tempo dovrebbe impiegare per assumere la nuova angolazione della telecamera. Se viene dato un valore troppo piccolo qui, la telecamera potrebbe ruotare troppo, perché controlliamo solo una volta per fotogramma renderizzato se l'angolazione desiderata è raggiunta.\n\nSe una situazione assegna la variabile « this.rotationTime » nel suo script di ingresso (vedi « Controlli situazione »), l'impostazione qui viene sovrascritta. Questo viene fatto es. nella situazione « Pietra del Ritorno/Teletrasporto » per consentire un tempo di rotazione per la durata del lancio dell'incantesimo."
L["Rotation Speed"] = "Velocità di rotazione"
L["Speed at which to rotate in degrees per second. You can manually enter values between -900 and 900, if you want to get yourself really dizzy..."] = "Velocità a cui ruotare in gradi al secondo. Puoi inserire manualmente valori tra -900 e 900, se vuoi davvero farti girare la testa..."
L["Yaw (-Left/Right+)"] = "Imbardata (-Sinistra/Destra+)"
L["Degrees to yaw (left or right)."] = "Gradi di imbardata (sinistra o destra)."
L["Pitch (-Down/Up+)"] = "Inclinazione (-Giù/Su+)"
L["Degrees to pitch (up or down). There is no going beyond the perpendicular upwards or downwards view."] = "Gradi di inclinazione (su o giù). Non è possibile andare oltre la vista perpendicolare dall'alto o dal basso."
L["Rotate Back"] = "Rotazione inversa"
L["<rotateBack_desc>"] = "Quando si esce dalla situazione, ruota indietro della quantità di gradi (modulo 360) ruotati dall'ingresso nella situazione. Questo ti riporta effettivamente alla posizione della telecamera pre-ingresso, a meno che tu non abbia nel frattempo cambiato l'angolo di vista con il mouse.\n\nSe stai entrando in una nuova situazione con una propria impostazione di rotazione, la « Rotazione inversa » della situazione in uscita viene ignorata."
L["Rotate Back Time"] = "Tempo rotazione inversa"
L["<rotateBackTime_desc>"] = "Il tempo necessario per ruotare indietro. Se viene dato un valore troppo piccolo qui, la telecamera potrebbe ruotare troppo, perché controlliamo solo una volta per fotogramma renderizzato se l'angolazione desiderata è raggiunta."
L["Fade Out UI"] = "Dissolvenza interfaccia"
L["Fade out or hide (parts of) the UI when this situation is active."] = "Dissolvi o nascondi (parti del) l'interfaccia quando questa situazione è attiva."
L["Adjust to Immersion"] = "Adatta a Immersion"
L["<adjustToImmersion_desc>"] = "Molte persone usano l'addon Immersion in combinazione con DynamicCam. Immersion ha alcune funzionalità proprie per nascondere l'interfaccia che entrano in gioco durante l'interazione con i PNG. In determinate circostanze, la dissolvenza dell'interfaccia di DynamicCam prevale su quella di Immersion. Per evitare ciò, effettua le impostazioni desiderate qui in DynamicCam. Fai clic su questo pulsante per utilizzare gli stessi tempi di dissolvenza in entrata e in uscita di Immersion. Per ancora più opzioni, dai un'occhiata all'altro addon di Ludius chiamato « Immersion ExtraFade »."
L["Fade Out Time"] = "Tempo dissolvenza in uscita"
L["Seconds it takes to fade out the UI when entering the situation."] = "Secondi necessari per dissolvere l'interfaccia quando si entra nella situazione."
L["Fade In Time"] = "Tempo dissolvenza in entrata"
L["<fadeInTime_desc>"] = "Secondi necessari per far riapparire l'interfaccia quando si esce dalla situazione.\n\nQuando passi da una situazione all'altra, entrambe con l'interfaccia nascosta, viene utilizzato il tempo di dissolvenza in uscita della situazione in ingresso per la transizione."
L["Hide entire UI"] = "Nascondi intera interfaccia"
L["<hideEntireUI_desc>"] = "C'è una differenza tra un'interfaccia « nascosta » e una « solo dissolta »: gli elementi dell'interfaccia dissolti hanno un'opacità di 0 ma possono ancora essere interagiti. Da DynamicCam 2.0 nascondiamo automaticamente la maggior parte degli elementi dell'interfaccia se la loro opacità è 0. Pertanto, questa opzione di nascondere l'intera interfaccia dopo la dissolvenza è più una reliquia. Un motivo per usarla ancora potrebbe essere quello di evitare interazioni indesiderate (es. tooltip al passaggio del mouse) di elementi dell'interfaccia che DynamicCam non nasconde ancora correttamente.\n\nL'opacità dell'interfaccia nascosta è ovviamente 0, quindi non puoi scegliere un'opacità diversa né mantenere visibili elementi dell'interfaccia (tranne l'indicatore FPS).\n\nDurante il combattimento non possiamo modificare lo stato nascosto degli elementi dell'interfaccia protetti. Pertanto, tali elementi sono sempre « solo dissolti » durante il combattimento. Nota che l'opacità dei « punti » sulla minimappa non può essere ridotta. Quindi, se provi a nascondere la minimappa, i « punti » sono sempre visibili durante il combattimento.\n\nQuando selezioni questa casella per la situazione attualmente attiva, non verrà applicata subito, perché ciò nasconderebbe anche questa finestra delle impostazioni. Devi entrare nella situazione affinché abbia effetto, il che è possibile anche con la casella di controllo della situazione « Attiva » sopra.\n\nNota anche che nascondere l'intera interfaccia annulla le interazioni con la cassetta delle lettere o i PNG. Quindi non usarlo per tali situazioni!"
L["Keep FPS indicator"] = "Mantieni indicatore FPS"
L["Do not fade out or hide the FPS indicator (the one you typically toggle with Ctrl + R)."] = "Non dissolvere o nascondere l'indicatore FPS (quello che di solito attivi/disattivi con Ctrl + R)."
L["Fade Opacity"] = "Opacità dissolvenza"
L["Fade the UI to this opacity when entering the situation."] = "Dissolvi l'interfaccia a questa opacità quando entri nella situazione."
L["Excluded UI elements"] = "Elementi interfaccia esclusi"
L["Keep Alerts"] = "Mantieni avvisi"
L["Still show alert popups from completed achievements, Covenant Renown, etc."] = "Mostra ancora i popup di avviso per imprese completate, Fama della Congrega, ecc."
L["Keep Tooltip"] = "Mantieni tooltip"
L["Still show the game tooltip, which appears when you hover your mouse cursor over UI or world elements."] = "Mostra ancora il tooltip di gioco, che appare quando passi il cursore del mouse su elementi dell'interfaccia o del mondo."
L["Keep Minimap"] = "Mantieni minimappa"
L["<keepMinimap_desc>"] = "Non dissolvere la minimappa.\n\nNota che non possiamo ridurre l'opacità dei « punti » sulla minimappa. Questi possono essere nascosti solo insieme all'intera minimappa, quando l'interfaccia viene dissolta a 0 opacità."
L["Keep Chat Box"] = "Mantieni riquadro chat"
L["Do not fade out the chat box."] = "Non dissolvere il riquadro della chat."
L["Keep Tracking Bar"] = "Mantieni barra esperienza/reputazione"
L["Do not fade out the tracking bar (XP, AP, reputation)."] = "Non dissolvere la barra esperienza/reputazione (PE, Potere Artefatto, reputazione)."
L["Keep Party/Raid"] = "Mantieni Gruppo/Incursione"
L["Do not fade out the Party/Raid frame."] = "Non dissolvere il riquadro Gruppo/Incursione."
L["Keep Encounter Frame (Skyriding Vigor)"] = "Mantieni riquadro incontro (Vigore Volo Dinamico)"
L["Do not fade out the Encounter Frame, which while skyriding is the Vigor display."] = "Non dissolvere il riquadro incontro, che durante il Volo Dinamico è la visualizzazione del Vigore."
L["Keep additional frames"] = "Mantieni riquadri aggiuntivi"
L["<keepCustomFrames_desc>"] = "La casella di testo qui sotto ti consente di definire qualsiasi riquadro (frame) che desideri mantenere durante l'interazione con i PNG.\n\nUsa il comando console /fstack per conoscere i nomi dei riquadri.\n\nAd esempio, potresti voler mantenere le icone dei benefici accanto alla minimappa per poter smontare durante l'interazione con i PNG facendo clic sull'icona appropriata."
L["Custom frames to keep"] = "Riquadri personalizzati da mantenere"
L["Separated by commas."] = "Separati da virgole."
L["Emergency Fade In"] = "Riapparizione di emergenza"
L["Pressing Esc fades the UI back in."] = "Premendo Esc l'interfaccia riappare."
L["<emergencyShow_desc>"] = [[A volte è necessario mostrare l'interfaccia anche in situazioni in cui normalmente si desidera che sia nascosta. Le versioni precedenti di DynamicCam stabilivano che l'interfaccia venisse mostrata ogni volta che veniva premuto il tasto Esc. Lo svantaggio è che l'interfaccia viene mostrata anche quando il tasto Esc viene utilizzato per altri scopi come chiudere finestre, annullare il lancio di incantesimi ecc. Deselezionare la casella sopra disabilita questo.

Nota tuttavia che puoi bloccarti fuori dall'interfaccia in questo modo! Un'alternativa migliore al tasto Esc sono i seguenti comandi console, che mostrano o nascondono l'interfaccia in base alle impostazioni « Dissolvenza interfaccia » della situazione corrente:

    /showUI
    /hideUI

Per un comodo tasto di scelta rapida per la riapparizione, metti /showUI in una macro e assegnale un tasto nel tuo file « bindings-cache.wtf ». Es.:

    bind ALT+F11 MACRO Nome Tua Macro

Se modificare il file « bindings-cache.wtf » ti scoraggia, potresti usare un addon per i tasti di scelta rapida come « BindPad ».

Usare /showUI o /hideUI senza argomenti prende il tempo di dissolvenza in entrata o in uscita della situazione corrente. Ma puoi anche fornire un tempo di transizione diverso. Es.:

    /showUI 0

per mostrare l'interfaccia senza alcun ritardo.]]
L["<hideUIHelp_desc>"] = "Mentre imposti gli effetti di dissolvenza dell'interfaccia desiderati, può essere fastidioso quando anche questa finestra delle impostazioni « Interfaccia » si dissolve. Se questa casella è selezionata, non verrà dissolta.\n\nQuesta impostazione è globale per tutte le situazioni."
L["Do not fade out this \"Interface\" settings frame."] = "Non dissolvere questa finestra delle impostazioni « Interfaccia »."
L["Situation Controls"] = "Controlli situazione"
L["<situationControls_help>"] = "Qui controlli quando una situazione è attiva. Potrebbe essere richiesta la conoscenza dell'API dell'interfaccia WoW. Se sei soddisfatto delle situazioni originali di DynamicCam, ignora semplicemente questa sezione. Ma se vuoi creare situazioni personalizzate, puoi controllare le situazioni originali qui. Puoi anche modificarle, ma attenzione: le tue impostazioni modificate persisteranno anche se le versioni future di DynamicCam introdurranno aggiornamenti importanti.\n\n"
L["Priority"] = "Priorità"
L["The priority of this situation.\nMust be a number."] = "La priorità di questa situazione.\nDeve essere un numero."
L["Restore stock setting"] = "Ripristina impostazione originale"
L["Your \"Priority\" deviates from the stock setting for this situation (%s). Click here to restore it."] = "La tua « Priorità » devia dall'impostazione originale per questa situazione (%s). Clicca qui per ripristinarla."
L["<priority_desc>"] = "Se le condizioni di diverse situazioni DynamicCam sono soddisfatte contemporaneamente, si entra nella situazione con la priorità più alta. Ad esempio, ogni volta che la condizione di « Mondo (interni) » è soddisfatta, anche la condizione di « Mondo » è soddisfatta. Ma poiché « Mondo (interni) » ha una priorità più alta di « Mondo », viene data la priorità. Puoi anche vedere le priorità di tutte le situazioni nel menu a discesa sopra.\n\n"
L["Error message:"] = "Messaggio di errore:"
L["Events"] = "Eventi"
L["Separated by commas."] = "Separati da virgole."
L["Your \"Events\" deviate from the default for this situation. Click here to restore them."] = "I tuoi « Eventi » deviano da quelli originali per questa situazione. Clicca qui per ripristinarli."
L["<events_desc>"] = [[Qui definisci tutti gli eventi di gioco in base ai quali DynamicCam dovrebbe controllare la condizione di questa situazione, per entrarvi o uscirne se applicabile.

Puoi saperne di più sugli eventi di gioco usando il Registro evento di WoW.
Per aprirlo, digita questo nella console:

  /eventtrace

Un elenco di tutti i possibili eventi può essere trovato anche qui:
https://warcraft.wiki.gg/wiki/Events

]]
L["Initialisation"] = "Inizializzazione"
L["Initialisation Script"] = "Script di inizializzazione"
L["Lua code using the WoW UI API."] = "Codice Lua che utilizza l'API dell'interfaccia WoW."
L["Your \"Initialisation Script\" deviates from the stock setting for this situation. Click here to restore it."] = "Il tuo « Script di inizializzazione » devia dall'impostazione originale per questa situazione. Clicca qui per ripristinarlo."
L["<initialisation_desc>"] = [[Lo script di inizializzazione di una situazione viene eseguito una volta quando DynamicCam viene caricato (e anche quando la situazione viene modificata). Di solito ci metteresti cose che vuoi riutilizzare in uno qualsiasi degli altri script (condizione, entrata, uscita). Questo può rendere questi altri script un po' più corti.

Ad esempio, lo script di inizializzazione della situazione « Pietra del Ritorno/Teletrasporto » definisce la tabella « this.spells », che include gli ID incantesimo degli incantesimi di teletrasporto. Lo script di condizione può quindi semplicemente accedere a « this.spells » ogni volta che viene eseguito.

Come in questo esempio, puoi condividere qualsiasi oggetto dati tra gli script di una situazione inserendolo nella tabella « this ».

]]
L["Condition"] = "Condizione"
L["Condition Script"] = "Script condizione"
L["Lua code using the WoW UI API.\nShould return \"true\" if and only if the situation should be active."] = "Codice Lua che utilizza l'API dell'interfaccia WoW.\nDovrebbe restituire « true » se e solo se la situazione deve essere attiva."
L["Your \"Condition Script\" deviates from the stock setting for this situation. Click here to restore it."] = "Il tuo « Script condizione » devia dall'impostazione originale per questa situazione. Clicca qui per ripristinarlo."
L["<condition_desc>"] = [[Lo script condizione di una situazione viene eseguito ogni volta che viene attivato un evento di gioco di questa situazione. Lo script dovrebbe restituire « true » se e solo se questa situazione deve essere attiva.

Ad esempio, lo script condizione della situazione « Città » utilizza la funzione API WoW « IsResting() » per verificare se ti trovi attualmente in una zona di riposo:

  return IsResting()

Allo stesso modo, lo script condizione della situazione « Città (interni) » utilizza anche la funzione API WoW « IsIndoors() » per verificare se sei al chiuso:

  return IsResting() and IsIndoors()

Un elenco delle funzioni API WoW può essere trovato qui:
https://warcraft.wiki.gg/wiki/World_of_Warcraft_API

]]
L["Entering"] = "Ingresso"
L["On-Enter Script"] = "Script di ingresso"
L["Your \"On-Enter Script\" deviates from the stock setting for this situation. Click here to restore it."] = "Il tuo « Script di ingresso » devia dall'impostazione originale per questa situazione. Clicca qui per ripristinarlo."
L["<executeOnEnter_desc>"] = [[Lo script di ingresso di una situazione viene eseguito ogni volta che si entra nella situazione.

Finora, l'unico esempio per questo è la situazione « Pietra del Ritorno/Teletrasporto » in cui utilizziamo la funzione API WoW « UnitCastingInfo() » per determinare la durata del lancio dell'incantesimo corrente. Assegniamo quindi questo alle variabili « this.transitionTime » e « this.rotationTime », in modo che uno zoom o una rotazione (vedi « Azioni situazione ») possa durare esattamente quanto il lancio dell'incantesimo. (Non tutti gli incantesimi di teletrasporto hanno gli stessi tempi di lancio.)

]]
L["Exiting"] = "Uscita"
L["On-Exit Script"] = "Script di uscita"
L["Your \"On-Exit Script\" deviates from the stock setting for this situation. Click here to restore it."] = "Il tuo « Script di uscita » devia dall'impostazione originale per questa situazione. Clicca qui per ripristinarlo."
L["Exit Delay"] = "Ritardo uscita"
L["Wait for this many seconds before exiting this situation."] = "Attendi questo numero di secondi prima di uscire da questa situazione."
L["Your \"Exit Delay\" deviates from the stock setting for this situation. Click here to restore it."] = "Il tuo « Ritardo uscita » devia dall'impostazione originale per questa situazione. Clicca qui per ripristinarlo."
L["<executeOnExit_desc>"] = [[Lo script di uscita di una situazione viene eseguito ogni volta che si esce dalla situazione. Finora, nessuna situazione lo sta utilizzando.

Il ritardo determina quanti secondi attendere prima di uscire dalla situazione. Finora, l'unico esempio per questo è la situazione « Pesca », dove il ritardo ti dà il tempo di lanciare nuovamente la tua canna da pesca senza uscire dalla situazione.

]]
L["Export"] = "Esporta"
L["Coming soon(TM)."] = "Prossimamente(TM)."
L["Import"] = "Importa"
L["<welcomeMessage>"] = [[Siamo felici che tu sia qui e speriamo che ti diverta con l'addon.

DynamicCam (DC) è stato avviato nel maggio 2016 da mpstark quando gli sviluppatori di WoW di Blizzard hanno introdotto nel gioco le funzionalità sperimentali ActionCam. Lo scopo principale di DC è stato quello di fornire un'interfaccia utente per le impostazioni di ActionCam. All'interno del gioco, ActionCam è ancora designata come "sperimentale" e non c'è stato alcun segnale da parte di Blizzard di svilupparla ulteriormente. Ci sono alcune carenze, ma dovremmo essere grati che ActionCam sia stata lasciata nel gioco per gli appassionati come noi. :-) DC non ti consente solo di modificare le impostazioni di ActionCam, ma di avere impostazioni diverse per diverse situazioni di gioco. Non correlato ad ActionCam, DC fornisce anche funzionalità relative allo zoom della telecamera e alla dissolvenza dell'interfaccia utente.

Il lavoro di mpstark su DC è continuato fino all'agosto 2018. Sebbene la maggior parte delle funzionalità funzionasse bene per una base di utenti sostanziale, mpstark aveva sempre considerato DC in stato beta e, a causa del suo calo di interesse per WoW, finì per non riprendere il suo lavoro. A quel tempo, Ludius aveva già iniziato ad apportare modifiche a DC per se stesso, cosa notata da Weston (alias dernPerkins) che all'inizio del 2020 riuscì a mettersi in contatto con mpstark portando Ludius a rilevare lo sviluppo. La prima versione non beta 1.0 è stata rilasciata nel maggio 2020 includendo le modifiche di Ludius fino a quel momento. Successivamente, Ludius ha iniziato a lavorare su una revisione di DC che ha portato al rilascio della versione 2.0 nell'autunno 2022.

Quando mpstark ha avviato DC, il suo obiettivo era quello di effettuare la maggior parte delle personalizzazioni nel gioco invece di dover modificare il codice sorgente. Ciò ha reso più facile sperimentare, in particolare con le diverse situazioni di gioco. Dalla versione 2.0 in poi, queste impostazioni avanzate sono state spostate in una sezione speciale chiamata "Controlli situazione". La maggior parte degli utenti probabilmente non ne avrà mai bisogno, ma per gli "utenti esperti" è ancora disponibile. Un rischio nell'apportare modifiche lì è che le impostazioni utente salvate sovrascrivono sempre le impostazioni originali di DC, anche se le nuove versioni di DC portano impostazioni originali aggiornate. Quindi, viene visualizzato un avviso nella parte superiore di questa pagina ogni volta che si hanno situazioni originali con "Controlli situazione" modificati.

Se pensi che una delle situazioni originali di DC debba essere modificata, puoi sempre crearne una copia con le tue modifiche. Sentiti libero di esportare questa nuova situazione e pubblicarla sulla pagina CurseForge di DC. Potremmo quindi aggiungerla come nuova situazione originale a sé stante. Sei anche il benvenuto a esportare e pubblicare il tuo intero profilo DC, poiché siamo sempre alla ricerca di nuovi preset di profili che consentano ai nuovi arrivati un ingresso più facile in DC. Se trovi un problema o vuoi dare un suggerimento, lascia semplicemente una nota nei commenti di CurseForge o, ancora meglio, usa le Issues su GitHub. Se vuoi contribuire, sentiti libero di aprire una pull request anche lì.

Ecco alcuni comandi slash utili:

    `/dynamiccam` o `/dc` apre questo menu.
    `/zoominfo` o `/zi` stampa il livello di zoom corrente.

    `/zoom #1 #2` zoome al livello #1 in #2 secondi.
    `/yaw #1 #2` imbardata la telecamera di #1 gradi in #2 secondi (#1 negativo per imbardata a destra).
    `/pitch #1 #2` inclina la telecamera di #1 gradi (#1 negativo per inclinare verso l'alto).


]]
L["About"] = "Info"
L["The following game situations have \"Situation Controls\" deviating from DynamicCam's stock settings.\n\n"] = "Le seguenti situazioni di gioco hanno \"Controlli situazione\" che si discostano dalle impostazioni originali di DynamicCam.\n\n"
L["<situationControlsWarning>"] = "\nSe lo stai facendo di proposito, va bene. Tieni presente che eventuali aggiornamenti a queste impostazioni da parte degli sviluppatori di DynamicCam saranno sempre sovrascritti dalla tua versione modificata (e forse obsoleta). Puoi controllare la scheda \"Controlli situazione\" di ogni situazione per i dettagli. Se non sei a conoscenza di modifiche ai \"Controlli situazione\" da parte tua e vuoi semplicemente ripristinare le impostazioni di controllo originali per *tutte* le situazioni, premi questo pulsante:"
L["Restore all stock Situation Controls"] = "Ripristina tutti i Controlli situazione originali"
L["Hello and welcome to DynamicCam!"] = "Ciao e benvenuto in DynamicCam!"
L["Profiles"] = "Profili"
L["Manage Profiles"] = "Gestisci profili"
L["<manageProfilesWarning>"] = "Come molti addon, DynamicCam utilizza la libreria \"AceDB-3.0\" per gestire i profili. Quello che devi capire è che non c'è nulla come \"Salva profilo\" qui. Solo puoi creare nuovi profili e puoi copiare le impostazioni da un altro profilo in quello attualmente attivo. Qualsiasi modifica tu faccia per il profilo attualmente attivo viene salvata immediatamente! Non c'è nulla come \"annulla\" o \"ignora modifiche\". Il pulsante \"Reimposta profilo\" reimposta solo al profilo predefinito globale.\n\nQuindi, se ti piacciono le tue impostazioni di DynamicCam, dovresti creare un altro profilo in cui copiare queste impostazioni come backup. Quando non usi questo profilo di backup come tuo profilo attivo, puoi sperimentare con le impostazioni e tornare al tuo profilo originale in qualsiasi momento selezionando il tuo profilo di backup nella casella \"Copia da\".\n\nSe vuoi cambiare profilo tramite macro, puoi usare quanto segue:\n/run DynamicCam.db:SetProfile(\"Nome profilo qui\")\n\n"
L["Profile presets"] = "Preset profilo"
L["Import / Export"] = "Importa / Esporta"
L["DynamicCam"] = "DynamicCam"
L["Disabled"] = "Disabilitato"
L["Your DynamicCam addon lets you adjust horizontal and vertical mouse look speed individually! Just go to the \"Mouse Look\" settings of DynamicCam to make the adjustments there."] = "Il tuo addon DynamicCam ti consente di regolare la velocità di visuale col mouse orizzontale e verticale individualmente! Vai semplicemente alle impostazioni \"Visuale col mouse\" di DynamicCam per effettuare le regolazioni lì."
L["Attention"] = "Attenzione"
L["The \"%s\" setting is disabled by DynamicCam, while you are using the horizontal camera over shoulder offset."] = "L'impostazione \"%s\" è disabilitata da DynamicCam, mentre stai usando lo scostamento della telecamera sopra la spalla orizzontale."
L["While you are using horizontal camera offset, DynamicCam prevents CameraKeepCharacterCentered!"] = "Mentre stai usando l'offset orizzontale della telecamera, DynamicCam impedisce CameraKeepCharacterCentered!"
L["While you are using horizontal camera offset, DynamicCam prevents CameraReduceUnexpectedMovement!"] = "Mentre stai usando l'offset orizzontale della telecamera, DynamicCam impedisce CameraReduceUnexpectedMovement!"
L["While you are using vertical camera pitch, DynamicCam prevents CameraKeepCharacterCentered!"] = "Mentre stai usando l'inclinazione verticale della telecamera, DynamicCam impedisce CameraKeepCharacterCentered!"
L["cameraView=%s prevented by DynamicCam!"] = "cameraView=%s impedito da DynamicCam!"

-- MouseZoom
L["Current\nZoom\nValue"] = "Valore di\nZoom\nAttuale"
L["Reactive\nZoom\nTarget"] = "Bersaglio di\nZoom\nReattivo"

-- Core
L["Enter name for custom situation:"] = "Inserisci nome per situazione personalizzata:"
L["Create"] = "Crea"
L["Cancel"] = "Annulla"

-- DefaultSettings
L["City"] = "Città"
L["City (Indoors)"] = "Città (Interni)"
L["World"] = "Mondo"
L["World (Indoors)"] = "Mondo (Interni)"
L["World (Combat)"] = "Mondo (Combattimento)"
L["Dungeon/Scenario"] = "Spedizione/Scenario"
L["Dungeon/Scenario (Outdoors)"] = "Spedizione/Scenario (Esterni)"
L["Dungeon/Scenario (Combat, Boss)"] = "Spedizione/Scenario (Combattimento, Boss)"
L["Dungeon/Scenario (Combat, Trash)"] = "Spedizione/Scenario (Combattimento, Trash)"
L["Raid"] = "Incursione"
L["Raid (Outdoors)"] = "Incursione (Esterni)"
L["Raid (Combat, Boss)"] = "Incursione (Combattimento, Boss)"
L["Raid (Combat, Trash)"] = "Incursione (Combattimento, Trash)"
L["Arena"] = "Arena"
L["Arena (Combat)"] = "Arena (Combattimento)"
L["Battleground"] = "Campo di battaglia"
L["Battleground (Combat)"] = "Campo di battaglia (Combattimento)"
L["Mounted (any)"] = "Cavalcatura (qualsiasi)"
L["Mounted (only flying-mount)"] = "Cavalcatura (solo volante)"
L["Mounted (only flying-mount + airborne)"] = "Cavalcatura (solo volante + in volo)"
L["Mounted (only flying-mount + airborne + Skyriding)"] = "Cavalcatura (solo volante + in volo + Volo Dinamico)"
L["Mounted (only flying-mount + Skyriding)"] = "Cavalcatura (solo volante + Volo Dinamico)"
L["Mounted (only airborne)"] = "Cavalcatura (solo in volo)"
L["Mounted (only airborne + Skyriding)"] = "Cavalcatura (solo in volo + Volo Dinamico)"
L["Mounted (only Skyriding)"] = "Cavalcatura (solo Volo Dinamico)"
L["Druid Travel Form"] = "Forma di Viaggio Druido"
L["Dracthyr Soar"] = "Dracthyr Volteggio"
L["Skyriding Race"] = "Gara di Volo Dinamico"
L["Taxi"] = "Taxi"
L["Vehicle"] = "Veicolo"
L["Hearth/Teleport"] = "Pietra del Ritorno/Teletrasporto"
L["Annoying Spells"] = "Incantesimi fastidiosi"
L["NPC Interaction"] = "Interazione PNG"
L["Mailbox"] = "Cassetta delle lettere"
L["Fishing"] = "Pesca"
L["Gathering"] = "Raccolta"
L["AFK"] = "Assente (AFK)"
L["Pet Battle"] = "Scontro tra mascotte"
L["Professions Frame Open"] = "Finestra professioni aperta"
