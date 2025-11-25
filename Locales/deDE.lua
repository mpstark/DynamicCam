local L = LibStub("AceLocale-3.0"):NewLocale("DynamicCam", "deDE")
if not L then return end

-- Options
L["Reset"] = "Reset"
L["Reset to global default"] = "Globalen Standard verwenden"
L["(To restore the settings of a specific profile, restore the profile in the \"Profiles\" tab.)"] = "(Um die Einstellungen eines bestimmten Profils zurückzusetzen, verwendet den „Profile“-Tab.)"
L["Currently overridden by the active situation \"%s\"."] = "Momentan überschrieben durch die aktive Situation „%s“."
L["Override Standard Settings"] = "Standard-Einstellungen überschreiben"
L["<overrideStandardToggle_desc>"] = "Durch Aktivieren dieser Box könnt ihr die Einstellungen dieser Kategorie konfigurieren. Diese Situations-Einstellungen überschreiben dann die Standard-Einstellungen, sobald diese Situation aktiv ist. Deaktivieren der Box löscht die Situations-Einstellungen dieser Kategorie."
L["Standard Settings"] = "Standard-Einstellungen"
L["Situation Settings"] = "Situations-Einstellungen"
L["<standardSettings_desc>"] = "Diese Standard-Einstellungen werden verwendet, wenn entweder keine Situation aktiv ist oder die aktive Situation keine Situations-Einstellungen eingerichtet hat, die die Standard-Einstellungen überschreiben."
L["<standardSettingsOverridden_desc>"] = "Grün markierten Kategorien werden momentan durch die aktive Situation überschrieben. Änderungen der Standard-Einstellungen haben somit keinen sichtbaren Effekt, solange die überschreibende Situation aktiv ist."
L["These Situation Settings override the Standard Settings when the respective situation is active."] = "Diese Situations-Einstellungen überschreiben die Standard-Einstellungen, wenn die entsprechende Situation aktiv ist."
L["Mouse Zoom"] = "Maus-Zoom"
L["Maximum Camera Distance"] = "Maximale Kameradistanz"
L["How many yards the camera can zoom away from your character."] = "So viele Yards kann die Kamera von eurem Charakter wegzoomen."
L["Camera Zoom Speed"] = "Kamera-Zoom-Geschwindigkeit"
L["How fast the camera can zoom."] = "So schnell kann gezoomt werden."
L["Zoom Increments"] = "Zoom Schrittgröße"
L["How many yards the camera should travel for each \"tick\" of the mouse wheel."] = "So viele Yards bewegt sich die Kamera per „Tick“ des Mausrads."
L["Use Reactive Zoom"] = "Reaktiv-Zoomen verwenden"
L["Quick-Zoom Additional Increments"] = "Quick-Zoom extra Zoomschritte"
L["How many yards per mouse wheel \"tick\" should be added when quick-zooming."] = "So viele Yards per Mausrad „Tick“ werden beim Quick-Zoom addiert."
L["Quick-Zoom Enter Threshold"] = "Quick-Zoom Eintrittsgrenze"
L["How many yards the \"Reactive Zoom Target\" and the \"Current Zoom Value\" have to be apart to enter quick-zooming."] = "So viele Yards müssen zwischen „Reaktiv-Zoom-Ziel“ und „Momentanem Zoom-Wert“ liegen, um Quick-Zoom zu aktivieren."
L["Maximum Zoom Time"] = "Maximale Zoom-Zeit"
L["The maximum time the camera should take to make \"Current Zoom Value\" equal to \"Reactive Zoom Target\"."] = "Die maximale Zeit, die die Kamera brauchen sollte, um den „Momentanen Zoom-Wert“ an das „Reaktiv-Zoom-Ziel“ anzugleichen."
L["Help"] = "Hilfe"
L["Toggle Visual Aid"] = "Hilfsvisualisierung ein-/ausblenden"
L["<reactiveZoom_desc>"] = "Unter Verwendung von DynamicCam's Reaktiv-Zoom kontrolliert das Mausrad das sogenannte „Reaktiv-Zoom-Ziel“. Immer wenn das „Reaktiv-Zoom-Ziel“ sich vom „Momentanen Zoom-Wert“ unterscheidet, verändert DynamicCam den „Momentanen Zoom-Wert“, bis er wieder mit dem „Reaktiv-Zoom-Ziel“ übereinstimmt.\n\nWie schnell diese Zoom-Änderung geschieht, hängt von der „Kamera-Zoom-Geschwindigkeit“ und der „Maximalen Zoom-Zeit“ ab. Wenn die „Maximale Zoom-Zeit“ niedrig eingestellt ist, wird die Zoom-Änderung immer schnell ausgeführt, unabhängig von der „Kamera-Zoom-Geschwindigkeit“. Um eine langsamere Zoom-Änderung zu erreichen, muss die „Maximale Zoom-Zeit“ auf einen höheren Wert und die „Kamera-Zoom-Geschwindigkeit“ auf einen niedrigeren Wert eingestellt werden.\n\nUm schnelleres Zoomen bei schnellerer Mausradbewegung zu ermöglichen, gibt es den „Quick-Zoom“: Wenn das „Reaktiv-Zoom-Ziel“ weiter vom „Momentanen Zoom-Wert“ entfernt ist als die „Quick-Zoom Eintrittsgrenze“, wird der Betrag der „Quick-Zoom extra Zoomschritte“ zu jedem Mausrad-Tick hinzugefügt.\n\nUm ein Gefühl dafür zu bekommen, wie das funktioniert, kann eine visuelle Hilfe eingeblendet werden, um die idealen Einstellungen zu finden. Dieses Diagramm kann durch Linksklicken und Ziehen frei bewegt werden. Ein Rechtsklick schließt es."
L["Enhanced minimal zoom-in"] = "Verbesserter Minimal-Zoom"
L["<enhancedMinZoom_desc>"] = "Mit Reaktiv-Zoom ist es möglich, noch näher als Zoom-Level 1 heranzuzoomen. Um das zu erreichen, muss man aus der Egoperspektive einen Mausrad-Tick herauszoomen.\n\nMit „Verbessertem Minimal-Zoom“ zwingen wir die Kamera, beim Hineinzoomen ebenfalls auf dieser minimalen Zoomstufe anzuhalten, bevor sie in die Egoperspektive springt.\n\n|cFFFF0000Die Aktivierung von „Verbesserter Minimal-Zoom“ kann in CPU-limitierten Situationen bis zu 15% FPS kosten.|r"
L["/reload of the UI required!"] = "Ein /reload der UI ist erforderlich!"
L["Mouse Look"] = "Maussicht"
L["Horizontal Speed"] = "Horizontale Geschwindigkeit"
L["How much the camera yaws horizontally when in mouse look mode."] = "Wie stark die Kamera horizontal schwenkt, wenn sich die Kamera im Maussicht-Modus befindet."
L["Vertical Speed"] = "Vertikale Geschwindigkeit"
L["How much the camera pitches vertically when in mouse look mode."] = "Wie stark die Kamera vertikal neigt, wenn sich die Kamera im Maussicht-Modus befindet."
L["<mouseLook_desc>"] = "Wie stark sich die Kamera bewegt, wenn ihr die Maus im „Maussicht“-Modus bewegt; d.h. während die linke oder rechte Maustaste gedrückt ist.\n\nDer Schieberegler „Mausblick-Geschwindigkeit“ in den Standard-Einstellungen von WoW steuert horizontale und vertikale Geschwindigkeit gleichzeitig, indem er die horizontale Geschwindigkeit automatisch auf das 2-fache der vertikalen Geschwindigkeit festlegt. DynamicCam überschreibt dies und ermöglicht euch eine individuellere Einstellung."
L["Horizontal Offset"] = "Horizontaler Versatz"
L["Camera Over Shoulder Offset"] = "Kamera-Über-Schulter-Versatz"
L["Positions the camera left or right from your character."] = "Positioniert die Kamera links oder rechts von eurem Charakter."
L["<cameraOverShoulder_desc>"] = "Damit dies wirksam wird, deaktiviert DynamicCam die WoW-Einstellung für Bewegungskrankheit automatisch vorübergehend. Wenn ihr also die Bewegungskrankheit-Einstellung benötigt, solltet ihr den horizontalen Versatz in diesen Situationen nicht verwenden.\n\nWenn ihr euren eigenen Charakter anvisiert, zentriert WoW die Kamera automatisch. Dagegen können wir nichts unternehmen. Wir können auch nichts gegen Versatz-Ruckler tun, die bei Kamera-Wand-Kollisionen auftreten können. Eine Abhilfe ist, innerhalb von Gebäuden wenig bis keinen Versatz zu verwenden.\n\nAußerdem wendet WoW den Versatz seltsamerweise je nach Charakter-Modell oder Reittier unterschiedlich an. Für alle, die einen permanenten Versatz bevorzugen, arbeitet Ludius an einem weiteren Addon („CameraOverShoulder Fix“), um dies zu beheben."
L["Adjust shoulder offset according to zoom level"] = "Versatz an Zoom-Level anpassen"
L["Enable"] = "Aktivieren"
L["and"] = "und"
L["No offset when below this zoom level:"] = "Kein Versatz unterhalb dieses Zoom-Levels:"
L["When the camera is closer than this zoom level, the offset has reached zero."] = "Ist die Kamera näher als dieser Zoom-Level, ist der Versatz Null."
L["Real offset when above this zoom level:"] = "Voller Versatz oberhalb dieses Zoom-Levels:"
L["When the camera is further away than this zoom level, the offset has reached its set value."] = "Ist die Kamera weiter entfernt als dieser Zoom-Level, hat der Versatz seinen eingestellten Wert erreicht."
L["<shoulderOffsetZoom_desc>"] = "Der Versatz wird beim Hineinzoomen schrittweise auf Null reduziert. Die beiden Schieberegler bestimmen, zwischen welchen Zoom-Levels dieser Übergang stattfindet. Diese Einstellung ist global und nicht situationsabhängig."
L["Vertical Pitch"] = "Vertikale Neigung"
L["Pitch (on ground)"] = "Neigung (am Boden)"
L["Pitch (flying)"] = "Neigung (fliegend)"
L["Down Scale"] = "Reduktionsfaktor"
L["Smart Pivot Cutoff Distance"] = "Intelligenter Schwenk-Grenzabstand"
L["<pitch_desc>"] = "Wenn die Kamera nach oben geneigt ist (niedrigerer Wert bei „Neigung“), bestimmt der „Reduktionsfaktor“, wie stark dies bei der Betrachtung eures Charakters von oben zum Tragen kommt. Setzt den „Reduktionsfaktor“ auf 0, um den Effekt einer Aufwärtsneigung beim Blick von oben aufzuheben. Im Gegensatz dazu hat der „Reduktionsfaktor“ wenig bis keinen Einfluss, wenn ihr nicht von oben schaut oder die Kamera nach unten geneigt ist (höherer Wert bei „Neigung“).\n\nIhr solltet also zuerst eure bevorzugte Einstellung für „Neigung“ finden, während ihr euren Charakter von hinten betrachtet. Nachdem ihr euch für eine Aufwärtsneigung entschieden habt, findet anschließend euren bevorzugten „Reduktionsfaktor“-Wert, während ihr von oben schaut.\n\n\nWenn die Kamera mit dem Boden kollidiert, führt sie normalerweise eine Aufwärtsneigung an der Stelle der Kamera-Boden-Kollision durch. Eine Alternative ist, dass sich die Kamera näher an die Füße eures Charakters heranbewegt, während sie diese Neigung durchführt. Der „Intelligente Schwenk-Grenzabstand“ bestimmt die Distanz, innerhalb derer sich die Kamera zu eurem Charakter befinden muss, damit dies passiert. Bei einem Wert von 0 bewegt sich die Kamera nie näher (WoW-Standard). Beim maximalen Wert von 39 hingegen tut sie es immer.\n\n"
L["Target Focus"] = "Ziel-Fokus"
L["Enemy Target"] = "Feindliches Ziel"
L["Horizontal Strength"] = "Horizontale Stärke"
L["Vertical Strength"] = "Vertikale Stärke"
L["Interaction Target (NPCs)"] = "Interaktions-Ziel (NPCs)"
L["<targetFocus_desc>"] = "Wenn aktiviert, versucht die Kamera automatisch, das Ziel näher in die Bildschirmmitte zu rücken. Die Stärke bestimmt die Intensität dieses Effekts.\n\nWenn sowohl „Feindliches Ziel“ als auch „Interaktions-Ziel“ aktiviert sind, scheint es bei Letzterem einen seltsamen Fehler zu geben: Bei der ersten Interaktion mit einem NPC bewegt sich die Kamera wie erwartet sanft in ihren neuen Winkel. Wenn ihr die Interaktion jedoch beendet, springt sie sofort in ihren vorherigen Winkel zurück. Startet ihr die Interaktion erneut, springt sie wieder hart in den neuen Winkel. Dies ist bei jedem Gespräch mit einem neuen NPC reproduzierbar: Nur der erste Übergang ist sanft, alle folgenden geschehen sofort.\nEine Übergangslösung, falls ihr sowohl „Feindliches Ziel“ als auch „Interaktions-Ziel“ verwenden möchtet, besteht darin, „Feindliches Ziel“ nur für DynamicCam-Situationen zu aktivieren, in denen ihr es benötigt und in denen NPC-Interaktionen unwahrscheinlich sind (wie im Kampf)."
L["Head Tracking"] = "Kopfverfolgung"
L["<headTrackingEnable_desc>"] = "(Dies könnte auch als kontinuierlicher Wert zwischen 0 und 1 verwendet werden, wird aber nur mit „Stärke (stehend)“ bzw. „Stärke (bewegend)“ multipliziert. Ein weiterer Schieberegler ist also nicht wirklich nötig.)"
L["Strength (standing)"] = "Stärke (stehend)"
L["Inertia (standing)"] = "Trägheit (stehend)"
L["Strength (moving)"] = "Stärke (bewegend)"
L["Inertia (moving)"] = "Trägheit (bewegend)"
L["Inertia (first person)"] = "Trägheit (Egoperspektive)"
L["Range Scale"] = "Reichweitenskalierung"
L["Camera distance beyond which head tracking is reduced or disabled. (See explanation below.)"] = "Kameradistanz, ab der die Kopfverfolgung reduziert oder deaktiviert wird. (Siehe Erklärung unten.)"
L["(slider value transformed)"] = "(Schiebereglerwert transformiert)"
L["Dead Zone"] = "Totzone"
L["Radius of head movement not affecting the camera. (See explanation below.)"] = "Radius der Kopfbewegung, der die Kamera nicht beeinflusst. (Siehe Erklärung unten.)"
L["(slider value devided by 10)"] = "(Schiebereglerwert geteilt durch 10)"
L["Requires /reload to come into effect!"] = "Erfordert ein /reload, um wirksam zu werden!"
L["<headTracking_desc>"] = "Wenn die Kopfverfolgung aktiviert ist, folgt die Kamera der Bewegung des Kopfes eures Charakters. (Dies kann zwar der Immersion dienen, aber auch Übelkeit verursachen, wenn ihr anfällig für Bewegungskrankheit seid.)\n\nDie Einstellung „Stärke“ bestimmt die Intensität dieses Effekts. Ein Wert von 0 deaktiviert die Kopfverfolgung. Die Einstellung „Trägheit“ bestimmt, wie schnell die Kamera auf Kopfbewegungen reagiert. Ein Wert von 0 deaktiviert ebenfalls die Kopfverfolgung. Die drei Fälle „stehend“, „bewegend“ und „Egoperspektive“ können individuell eingestellt werden. Für die „Egoperspektive“ gibt es keine „Stärke“-Einstellung, da sie die „Stärke“-Einstellungen von „stehend“ bzw. „bewegend“ übernimmt. Wenn ihr lediglich die „Egoperspektive“ aktivieren oder deaktivieren wollt, nutzt die „Trägheit“-Schieberegler, um die unerwünschten Fälle zu deaktivieren.\n\nMit der Einstellung „Reichweitenskalierung“ könnt ihr die Kameradistanz festlegen, ab der die Kopfverfolgung reduziert oder deaktiviert wird. Wenn der Schieberegler beispielsweise auf 30 eingestellt ist, habt ihr keine Kopfverfolgung mehr, wenn die Kamera mehr als 30 Yards von eurem Charakter entfernt ist. Es gibt jedoch einen stufenweisen Übergang von voller Kopfverfolgung zu keiner Kopfverfolgung, der bei einem Drittel des Schiebereglerwertes beginnt. Ist der Wert beispielsweise auf 30 eingestellt, habt ihr volle Kopfverfolgung, wenn die Kamera näher als 10 Yards ist. Ab 10 Yards nimmt die Kopfverfolgung allmählich ab, bis sie ab 30 Yards vollständig deaktiviert ist. Daher ermöglicht der Maximalwert von 117 eine volle Kopfverfolgung bei der maximalen Kameradistanz von 39 Yards. (Hinweis: Nutzt DynamicCam's visuelle Hilfe für „Maus-Zoom“, um die aktuelle Kameradistanz während der Einstellung zu erfahren.)\n\nDie Einstellung „Totzone“ kann verwendet werden, um kleinere Kopfbewegungen zu ignorieren. Ein Wert von 0 lässt die Kamera jeder noch so kleinen Kopfbewegung folgen, während ein höherer Wert dazu führt, dass sie nur größeren Bewegungen folgt. Beachtet, dass eine Änderung dieser Einstellung erst nach dem Neuladen des Interfaces (gebt /reload in die Konsole ein) wirksam wird."
L["Situations"] = "Situationen"
L["Select a situation to setup"] = "Wählt eine Situation zum Einrichten aus"
L["<selectedSituation_desc>"] = "\n|cffffcc00Farbcodes:|r\n|cFF808A87- Deaktivierte Situation.|r\n- Aktivierte Situation.\n|cFF00FF00- Aktivierte und momentan aktive Situation.|r\n|cFF63B8FF- Aktivierte Situation mit erfüllter Bedingung, aber niedrigerer Priorität als die momentan aktive Situation.|r\n|cFFFF6600- Modifizierte Original-„Situations-Steuerung“ (Zurücksetzen empfohlen).|r\n|cFFEE0000- Fehlerhafte „Situations-Steuerung“ (Korrektur erforderlich).|r"
L["If this box is checked, DynamicCam will enter the situation \"%s\" whenever its condition is fulfilled and no other situation with higher priority is active."] = "Wenn dieses Feld aktiviert ist, wechselt DynamicCam in die Situation „%s“, wann immer ihre Bedingung erfüllt ist und keine andere Situation mit höherer Priorität aktiv ist."
L["Custom:"] = "Eigene:"
L["(modified)"] = "(modifiziert)"
L["Delete custom situation \"%s\".\n|cFFEE0000Attention: There will be no 'Are you sure?' prompt!|r"] = "Löscht die eigene Situation „%s“.\n|cFFEE0000Achtung: Es gibt keine „Seid ihr sicher?“-Abfrage!|r"
L["Create a new custom situation."] = "Erstellt eine neue eigene Situation."
L["Situation Actions"] = "Situations-Aktionen"
L["Setup stuff to happen while in a situation or when entering/exiting it."] = "Richtet Dinge ein, die passieren sollen, während ihr euch in einer Situation befindet oder wenn ihr sie betretet/verlasst."
L["Zoom/View"] = "Zoom/Ansicht"
L["Zoom to a certain zoom level or switch to a saved camera view when entering this situation."] = "Zoomt auf einen bestimmten Zoom-Level oder wechselt zu einer gespeicherten Kamera-Ansicht, wenn diese Situation betreten wird."
L["Set Zoom or Set View"] = "Zoom oder Ansicht setzen"
L["Zoom Type"] = "Zoom-Typ"
L["<viewZoomType_desc>"] = "Zoom setzen: Zoomt auf einen gegebenen Zoom-Level mit erweiterten Optionen für Übergangszeit und Zoom-Bedingungen.\n\nAnsicht setzen: Wechselt zu einer gespeicherten Kamera-Ansicht, die aus einem festen Zoom-Level und einem Kamerawinkel besteht."
L["Set Zoom"] = "Zoom setzen"
L["Set View"] = "Ansicht setzen"
L["Set view to saved view:"] = "Ansicht auf gespeicherte Ansicht setzen:"
L["Select the saved view to switch to when entering this situation."] = "Wählt die gespeicherte Ansicht aus, zu der gewechselt werden soll, wenn diese Situation betreten wird."
L["Instant"] = "Sofort"
L["Make view transitions instant."] = "Macht Ansichtswechsel sofortig."
L["Restore view when exiting"] = "Ansicht beim Verlassen wiederherstellen"
L["When exiting the situation restore the camera position to what it was at the time of entering the situation."] = "Wenn die Situation verlassen wird, wird die Kameraposition wiederhergestellt, die zum Zeitpunkt des Betretens der Situation aktiv war."
L["cameraSmoothNote"] = [[|cFFEE0000Achtung:|r Ihr verwendet WoWs „Kamera-Verfolgungsstil“, der die Kamera automatisch hinter den Spieler setzt. Dies funktioniert nicht, während ihr euch in einer angepassten gespeicherten Ansicht befindet. Es ist möglich, angepasste gespeicherte Ansichten für Situationen zu verwenden, in denen Kameraverfolgung nicht benötigt wird (z. B. NPC-Interaktion). Aber nach dem Verlassen der Situation müsst ihr zu einer nicht-angepassten Standard-Ansicht zurückkehren, damit die Kameraverfolgung wieder funktioniert.]]
L["Restore to default view:"] = "Standard-Ansicht wiederherstellen:"
L["<viewRestoreToDefault_desc>"] = [[Wählt die Standard-Ansicht aus, zu der beim Verlassen dieser Situation zurückgekehrt werden soll.

Ansicht 1:   Zoom 0, Neigung 0
Ansicht 2:   Zoom 5.5, Neigung 10
Ansicht 3:   Zoom 5.5, Neigung 20
Ansicht 4:   Zoom 13.8, Neigung 30
Ansicht 5:   Zoom 13.8, Neigung 10]]
L["WARNING"] = "WARNUNG"
L["You are using the same view as saved view and as restore-to-default view. Using a view as restore-to-default view will reset it. Only do this if you really want to use it as a non-customized saved view."] = "Eure zu setzende gespeicherte Ansicht ist die gleiche wie Eure wiederherzustellende Standard-Ansict. Wenn eine Ansicht zum Zurücksetzen auf Standard verwendet wird, wird diese Ansicht dabei zurückgesetzt. Tut dies nur, wenn ihr sie wirklich als eine nicht-angepasste gespeicherte Ansicht verwenden wollt."
L["View %s is used as saved view in the situations:\n%sand as restore-to-default view in the situations:\n%s"] = "Ansicht %s wird als gespeicherte Ansicht verwendet in den Situationen:\n%sund als Ansicht zum Zurücksetzen auf Standard in den Situationen:\n%s"
L["<view_desc>"] = [[WoW erlaubt das Speichern von bis zu 5 benutzerdefinierten Kamera-Ansichten. Ansicht 1 wird von DynamicCam verwendet, um die Kameraposition beim Betreten einer Situation zu speichern, damit sie beim Verlassen der Situation wiederhergestellt werden kann, wenn ihr das Kontrollkästchen „Wiederherstellen“ oben aktiviert. Dies ist besonders nützlich für kurze Situationen wie NPC-Interaktion, da es ermöglicht, während des Gesprächs mit dem NPC zu einer Ansicht zu wechseln und danach wieder zu der Kameraposition zurückzukehren, die vorher aktiv war. Deshalb kann Ansicht 1 im obigen Dropdown-Menü der gespeicherten Ansichten nicht ausgewählt werden.

Ansichten 2, 3, 4 und 5 können verwendet werden, um benutzerdefinierte Kamerapositionen zu speichern. Um eine Ansicht zu speichern, bringt die Kamera einfach in den gewünschten Zoom und Winkel. Gebt dann den folgenden Befehl in die Konsole ein (wobei # die Ansichtsnummer 2, 3, 4 oder 5 ist):

  /saveView #

Oder kurz:

  /sv #

Beachtet, dass die gespeicherten Ansichten von WoW gespeichert werden. DynamicCam speichert nur, welche Ansichtsnummern verwendet werden sollen. Wenn ihr also ein neues DynamicCam-Situationsprofil mit Ansichten importiert, müsst ihr wahrscheinlich danach die entsprechenden Ansichten einstellen und speichern.


DynamicCam bietet auch einen Konsolenbefehl, um unabhängig vom Betreten oder Verlassen von Situationen zu einer Ansicht zu wechseln:

  /setView #

Um den Ansichtswechsel sofortig zu machen, fügt ein „i“ nach der Ansichtsnummer hinzu. Z. B. um sofort zur gespeicherten Ansicht 3 zu wechseln, gebt ein:

  /setView 3 i

]]
L["Zoom Transition Time"] = "Zoom-Übergangszeit"
L["<transitionTime_desc>"] = "Die Zeit in Sekunden, die es dauert, um zum neuen Zoom-Wert überzugehen.\n\nWenn niedriger eingestellt als möglich, wird der Übergang so schnell sein, wie es die aktuelle Kamera-Zoom-Geschwindigkeit erlaubt (einstellbar in den DynamicCam „Maus-Zoom“-Einstellungen).\n\nWenn eine Situation die Variable „this.transitionTime“ in ihrem Eintritts-Skript zuweist (siehe „Situations-Steuerung“), wird die Einstellung hier überschrieben. Dies wird z. B. in der „Ruhestein/Teleport“-Situation getan, um eine Übergangszeit für die Dauer des Zauberwirkens zu ermöglichen."
L["<zoomType_desc>"] = "\nSetzen: Setzt den Zoom immer auf diesen Wert.\n\nRaus: Setzt den Zoom nur, wenn die Kamera aktuell näher als dieser Wert ist.\n\nRein: Setzt den Zoom nur, wenn die Kamera aktuell weiter entfernt als dieser Wert ist.\n\nBereich: Zoomt rein, wenn weiter entfernt als das gegebene Maximum. Zoomt raus, wenn näher als das gegebene Minimum. Tut nichts, wenn der aktuelle Zoom innerhalb des [Min, Max]-Bereichs liegt."
L["Set"] = "Setzen"
L["Out"] = "Raus"
L["In"] = "Rein"
L["Range"] = "Bereich"
L["Don't slow"] = "Nicht verlangsamen"
L["Zoom transitions may be executed faster (but never slower) than the specified time above, if the \"Camera Zoom Speed\" (see \"Mouse Zoom\" settings) allows."] = "Zoom-Übergänge können schneller (aber niemals langsamer) ausgeführt werden als die oben angegebene Zeit, wenn die „Kamera-Zoom-Geschwindigkeit“ (siehe „Maus-Zoom“-Einstellungen) dies erlaubt."
L["Zoom Value"] = "Zoom-Wert"
L["Zoom to this zoom level."] = "Zoomt auf diesen Zoom-Level."
L["Zoom out to this zoom level, if the current zoom level is less than this."] = "Zoomt raus auf diesen Zoom-Level, wenn der aktuelle Zoom-Level kleiner als dieser ist."
L["Zoom in to this zoom level, if the current zoom level is greater than this."] = "Zoomt rein auf diesen Zoom-Level, wenn der aktuelle Zoom-Level größer als dieser ist."
L["Zoom Min"] = "Zoom Min"
L["Zoom Max"] = "Zoom Max"
L["Restore Zoom"] = "Zoom wiederherstellen"
L["<zoomRestoreSetting_desc>"] = "Wenn ihr eine Situation verlasst (oder den Standardzustand verlasst, in dem keine Situation aktiv ist), wird der aktuelle Zoom-Level vorübergehend gespeichert, damit er wiederhergestellt werden kann, sobald ihr diese Situation das nächste Mal betretet. Hier könnt ihr auswählen, wie dies gehandhabt wird.\n\nDiese Einstellung gilt global für alle Situationen."
L["Restore Zoom Mode"] = "Zoom-Wiederherstellungsmodus"
L["<zoomRestoreSettingSelect_desc>"] = "\nNiemals: Beim Betreten einer Situation wird die tatsächliche Zoom-Einstellung (falls vorhanden) der eintretenden Situation angewendet. Kein gespeicherter Zoom wird berücksichtigt.\n\nImmer: Beim Betreten einer Situation wird der zuletzt gespeicherte Zoom dieser Situation verwendet. Ihre tatsächliche Einstellung wird nur berücksichtigt, wenn die Situation zum ersten Mal nach dem Login betreten wird.\n\nAdaptiv: Der gespeicherte Zoom wird nur unter bestimmten Umständen verwendet. Z.B. nur, wenn ihr in dieselbe Situation zurückkehrt, aus der ihr gekommen seid, oder wenn der gespeicherte Zoom die Kriterien der „Rein“-, „Raus“- oder „Bereich“-Zoom-Einstellungen der Situation erfüllt."
L["Never"] = "Niemals"
L["Always"] = "Immer"
L["Adaptive"] = "Adaptiv"
L["<zoom_desc>"] = [[Um den aktuellen Zoom-Level zu bestimmen, könnt ihr entweder die „Visuelle Hilfe“ verwenden (umschaltbar in DynamicCams „Maus-Zoom“-Einstellungen) oder den Konsolenbefehl verwenden:

  /zoomInfo

Oder kurz:

  /zi]]
L["Rotation"] = "Rotation"
L["Start a camera rotation when this situation is active."] = "Startet eine Kamerarotation, wenn diese Situation aktiv ist."
L["Rotation Type"] = "Rotationstyp"
L["<rotationType_desc>"] = "\nKontinuierlich: Die Kamera rotiert dauerhaft horizontal, während diese Situation aktiv ist. Nur ratsam für Situationen, in denen ihr die Kamera nicht mit der Maus bewegt; z. B. Teleport-Zauberwirken, Taxi oder AFK. Eine kontinuierliche vertikale Rotation ist nicht möglich, da sie bei der senkrechten Ansicht nach oben oder unten stoppen würde.\n\nNach Grad: Ändert nach dem Betreten der Situation den aktuellen Kameraschwenk (horizontal) und/oder die Neigung (vertikal) um die angegebene Gradzahl."
L["Continuously"] = "Kontinuierlich"
L["By Degrees"] = "Nach Grad"
L["Acceleration Time"] = "Beschleunigungszeit"
L["Rotation Time"] = "Rotationszeit"
L["<accelerationTime_desc>"] = "Wenn ihr hier eine Zeit größer als 0 einstellt, startet die kontinuierliche Rotation nicht sofort mit voller Geschwindigkeit, sondern benötigt diese Zeit zum Beschleunigen. (Nur bei relativ hohen Rotationsgeschwindigkeiten bemerkbar.)"
L["<rotationTime_desc>"] = "Wie lange es dauern soll, den neuen Kamerawinkel einzunehmen. Wenn hier ein zu kleiner Wert eingegeben wird, könnte die Kamera zu weit rotieren, da wir nur einmal pro gerendertem Frame prüfen, ob der gewünschte Winkel erreicht ist.\n\nWenn eine Situation die Variable „this.rotationTime“ in ihrem Eintritts-Skript zuweist (siehe „Situations-Steuerung“), wird die Einstellung hier überschrieben. Dies wird z. B. in der „Ruhestein/Teleport“-Situation getan, um eine Rotationszeit für die Dauer des Zauberwirkens zu ermöglichen."
L["Rotation Speed"] = "Rotationsgeschwindigkeit"
L["Speed at which to rotate in degrees per second. You can manually enter values between -900 and 900, if you want to get yourself really dizzy..."] = "Geschwindigkeit, mit der in Grad pro Sekunde rotiert wird. Ihr könnt manuell Werte zwischen -900 und 900 eingeben, wenn ihr euch wirklich schwindelig machen wollt..."
L["Yaw (-Left/Right+)"] = "Schwenken (-Links/Rechts+)"
L["Degrees to yaw (left or right)."] = "Grad zum Schwenken (links oder rechts)."
L["Pitch (-Down/Up+)"] = "Neigung (-Runter/Hoch+)"
L["Degrees to pitch (up or down). There is no going beyond the perpendicular upwards or downwards view."] = "Grad zum Neigen (hoch oder runter). Es geht nicht über die senkrechte Ansicht von oben oder unten hinaus."
L["Rotate Back"] = "Zurückrotieren"
L["<rotateBack_desc>"] = "Beim Verlassen der Situation rotiert die Kamera um die Anzahl der Grade (modulo 360) zurück, die seit dem Betreten der Situation rotiert wurden. Dies bringt euch effektiv zur Kameraposition vor dem Betreten zurück, es sei denn, ihr habt zwischendurch den Blickwinkel mit der Maus geändert.\n\nWenn ihr eine neue Situation mit einer eigenen Rotationseinstellung betretet, wird das „Zurückrotieren“ der verlassenden Situation ignoriert."
L["Rotate Back Time"] = "Rückrotationszeit"
L["<rotateBackTime_desc>"] = "Die Zeit, die das Zurückrotieren benötigt. Wenn hier ein zu kleiner Wert eingegeben wird, könnte die Kamera zu weit rotieren, da wir nur einmal pro gerendertem Frame prüfen, ob der gewünschte Winkel erreicht ist."
L["Fade Out UI"] = "Interface ausblenden"
L["Fade out or hide (parts of) the UI when this situation is active."] = "Blendet (Teile) des Interfaces aus oder versteckt sie, wenn diese Situation aktiv ist."
L["Adjust to Immersion"] = "An Immersion anpassen"
L["<adjustToImmersion_desc>"] = "Viele Leute nutzen das Addon Immersion in Kombination mit DynamicCam. Immersion hat eigene Funktionen zum Ausblenden des Interfaces, die während der NPC-Interaktion aktiv werden. Unter bestimmten Umständen überschreibt DynamicCams Interface-Ausblenden das von Immersion. Um dies zu verhindern, nehmt eure gewünschten Einstellungen hier in DynamicCam vor. Klickt auf diesen Button, um dieselben Ein- und Ausblendzeiten wie Immersion zu verwenden. Für noch mehr Optionen schaut euch Ludius' anderes Addon namens „Immersion ExtraFade“ an."
L["Fade Out Time"] = "Ausblendzeit"
L["Seconds it takes to fade out the UI when entering the situation."] = "Sekunden, die es dauert, um das Interface beim Betreten der Situation auszublenden."
L["Fade In Time"] = "Einblendzeit"
L["<fadeInTime_desc>"] = "Sekunden, die es dauert, um das Interface beim Verlassen der Situation wieder einzublenden.\n\nWenn ihr zwischen Situationen wechselt, die beide das Interface ausblenden, wird für den Übergang die Ausblendzeit der eintretenden Situation verwendet."
L["Hide entire UI"] = "Gesamtes Interface verstecken"
L["<hideEntireUI_desc>"] = "Es gibt einen Unterschied zwischen einem „versteckten“ Interface und einem „nur ausgeblendeten“ Interface: Die ausgeblendeten Interface-Elemente haben eine Deckkraft von 0, können aber immer noch interagiert werden. Seit DynamicCam 2.0 verstecken wir automatisch die meisten Interface-Elemente, wenn ihre Deckkraft 0 ist. Daher ist diese Option, das gesamte Interface nach dem Ausblenden zu verstecken, eher ein Relikt. Ein Grund, sie dennoch zu nutzen, könnte sein, unerwünschte Interaktionen (z.B. Mouseover-Tooltips) von Interface-Elementen zu vermeiden, die DynamicCam noch nicht richtig versteckt.\n\nDie Deckkraft des versteckten Interfaces ist natürlich 0, daher könnt ihr keine andere Deckkraft wählen oder irgendwelche Interface-Elemente sichtbar halten (außer dem FPS-Indikator).\n\nWährend des Kampfes können wir den Versteckt-Status von geschützten Interface-Elementen nicht ändern. Daher sind solche Elemente während des Kampfes immer „nur ausgeblendet“. Beachtet, dass die Deckkraft der „Punkte“ auf der Minimap nicht reduziert werden kann. Wenn ihr also versucht, die Minimap zu verstecken, sind die „Punkte“ während des Kampfes immer sichtbar.\n\nWenn ihr dieses Kontrollkästchen für die momentan aktive Situation aktiviert, wird es nicht sofort angewendet, da dies auch dieses Einstellungsfenster verstecken würde. Ihr müsst die Situation betreten, damit es wirksam wird, was auch mit dem Situations-Kontrollkästchen „Aktivieren“ oben möglich ist.\n\nBeachtet außerdem, dass das Verstecken des gesamten Interfaces Interaktionen mit Briefkästen oder NPCs abbricht. Verwendet es also nicht für solche Situationen!"
L["Keep FPS indicator"] = "FPS-Indikator behalten"
L["Do not fade out or hide the FPS indicator (the one you typically toggle with Ctrl + R)."] = "Den FPS-Indikator (der typischerweise mit Strg + R ein- und ausgeblendet wird) nicht ausblenden oder verstecken."
L["Fade Opacity"] = "Ausblend-Deckkraft"
L["Fade the UI to this opacity when entering the situation."] = "Blendet das Interface beim Betreten der Situation auf diese Deckkraft aus."
L["Excluded UI elements"] = "Ausgenommene UI-Elemente"
L["Keep Alerts"] = "Warnungen behalten"
L["Still show alert popups from completed achievements, Covenant Renown, etc."] = "Zeigt weiterhin Warnmeldungen von abgeschlossenen Erfolgen, Pakt-Ruhm usw. an."
L["Keep Tooltip"] = "Tooltip behalten"
L["Still show the game tooltip, which appears when you hover your mouse cursor over UI or world elements."] = "Zeigt weiterhin den Spiel-Tooltip an, der erscheint, wenn ihr euren Mauszeiger über Interface- oder Weltelemente bewegt."
L["Keep Minimap"] = "Minimap behalten"
L["<keepMinimap_desc>"] = "Die Minimap nicht ausblenden.\n\nBeachtet, dass wir die Deckkraft der „Punkte“ auf der Minimap nicht reduzieren können. Diese können nur zusammen mit der gesamten Minimap versteckt werden, wenn das Interface auf 0 Deckkraft ausgeblendet wird."
L["Keep Chat Box"] = "Chat-Fenster behalten"
L["Do not fade out the chat box."] = "Das Chat-Fenster nicht ausblenden."
L["Keep Tracking Bar"] = "Leiste für Erfahrung/Ruf behalten"
L["Do not fade out the tracking bar (XP, AP, reputation)."] = "Die Leiste für Erfahrung/Ruf (XP, AP, Ruf) nicht ausblenden."
L["Keep Party/Raid"] = "Gruppe/Schlachtzug behalten"
L["Do not fade out the Party/Raid frame."] = "Den Gruppen-/Schlachtzugsrahmen nicht ausblenden."
L["Keep Encounter Frame (Skyriding Vigor)"] = "Begegnungsrahmen (Himmelsreiten-Elan) behalten"
L["Do not fade out the Encounter Frame, which while skyriding is the Vigor display."] = "Den Begegnungsrahmen nicht ausblenden, der beim Himmelsreiten die Elan-Anzeige ist."
L["Keep additional frames"] = "Zusätzliche Fenster behalten"
L["<keepCustomFrames_desc>"] = "Das Textfeld unten erlaubt es euch, jedes Fenster zu definieren, das ihr während der NPC-Interaktion behalten wollt.\n\nVerwendet den Konsolenbefehl /fstack, um die Namen von Fenstern (frames) zu erfahren.\n\nZum Beispiel möchtet ihr vielleicht die Buff-Symbole neben der Minimap behalten, um während der NPC-Interaktion durch Klicken auf das entsprechende Symbol absteigen zu können."
L["Custom frames to keep"] = "Eigene uu behaltende Fenster"
L["Separated by commas."] = "Durch Kommas getrennt."
L["Emergency Fade In"] = "Notfall-Einblenden"
L["Pressing Esc fades the UI back in."] = "Drücken von Esc blendet das Interface wieder ein."
L["<emergencyShow_desc>"] = [[Manchmal müsst ihr das Interface auch in Situationen anzeigen, in denen ihr es normalerweise versteckt haben wollt. Ältere Versionen von DynamicCam haben etabliert, dass das Interface angezeigt wird, wann immer die Esc-Taste gedrückt wird. Der Nachteil dabei ist, dass das Interface auch angezeigt wird, wenn die Esc-Taste für andere Zwecke wie das Schließen von Fenstern, das Abbrechen von Zaubern usw. verwendet wird. Das Deaktivieren des obigen Kontrollkästchens schaltet dies aus.

Beachtet jedoch, dass ihr euch auf diese Weise aus dem Interface ausschließen könnt! Eine bessere Alternative zur Esc-Taste sind die folgenden Konsolenbefehle, die das Interface entsprechend den Einstellungen „Interface ausblenden“ der aktuellen Situation anzeigen oder verstecken:

    /showUI
    /hideUI

Für einen bequemen Einblend-Hotkey, packt /showUI in ein Makro und weist ihm in eurer „bindings-cache.wtf“-Datei eine Taste zu. Z.B.:

    bind ALT+F11 MACRO Euer Makro Name

Wenn euch das Bearbeiten der „bindings-cache.wtf“-Datei abschreckt, könntet ihr ein Keybind-Addon wie „BindPad“ verwenden.

Die Verwendung von /showUI oder /hideUI ohne Argumente übernimmt die Einblend- oder Ausblendzeit der aktuellen Situation. Aber ihr könnt auch eine andere Übergangszeit angeben. Z.B.:

    /showUI 0

um das Interface ohne Verzögerung anzuzeigen.]]
L["<hideUIHelp_desc>"] = "Während ihr eure gewünschten Interface-Ausblend-Effekte einrichtet, kann es nervig sein, wenn dieses „Interface“-Einstellungsfenster ebenfalls ausgeblendet wird. Wenn dieses Feld aktiviert ist, wird es nicht ausgeblendet.\n\nDiese Einstellung gilt global für alle Situationen."
L["Do not fade out this \"Interface\" settings frame."] = "Dieses „Interface“-Einstellungsfenster nicht ausblenden."
L["Situation Controls"] = "Situations-Steuerung"
L["<situationControls_help>"] = "Hier steuert ihr, wann eine Situation aktiv ist. Kenntnisse der WoW-UI-API können erforderlich sein. Wenn ihr mit den Original-Situationen von DynamicCam zufrieden seid, ignoriert diesen Abschnitt einfach. Aber wenn ihr eigene Situationen erstellen möchtet, könnt ihr hier die Original-Situationen einsehen. Ihr könnt sie auch modifizieren, aber Vorsicht: Eure geänderten Einstellungen bleiben bestehen, selbst wenn zukünftige Versionen von DynamicCam wichtige Updates einführen.\n\n"
L["Priority"] = "Priorität"
L["The priority of this situation.\nMust be a number."] = "Die Priorität dieser Situation.\nMuss eine Zahl sein."
L["Restore stock setting"] = "Original-Einstellung wiederherstellen"
L["Your \"Priority\" deviates from the stock setting for this situation (%s). Click here to restore it."] = "Eure „Priorität“ weicht von der Original-Einstellung für diese Situation (%s) ab. Klickt hier, um sie wiederherzustellen."
L["<priority_desc>"] = "Wenn die Bedingungen mehrerer verschiedener DynamicCam-Situationen gleichzeitig erfüllt sind, wird die Situation mit der höchsten Priorität betreten. Zum Beispiel: Wann immer die Bedingung von „Welt (in Gebäuden)“ erfüllt ist, ist auch die Bedingung von „Welt“ erfüllt. Aber da „Welt (in Gebäuden)“ eine höhere Priorität als „Welt“ hat, wird sie bevorzugt. Ihr könnt die Prioritäten aller Situationen auch im obigen Dropdown-Menü sehen.\n\n"
L["Error message:"] = "Fehlermeldung:"
L["Events"] = "Ereignisse"
L["Separated by commas."] = "Durch Kommas getrennt."
L["Your \"Events\" deviate from the default for this situation. Click here to restore them."] = "Eure „Ereignisse“ weichen vom Original für diese Situation ab. Klickt hier, um sie wiederherzustellen."
L["<events_desc>"] = [[Hier definiert ihr alle Ereignisse im Spiel, bei denen DynamicCam die Bedingung dieser Situation prüfen soll, um sie gegebenenfalls zu betreten oder zu verlassen.

Ihr könnt mehr über Ereignisse im Spiel erfahren, indem ihr das Ereignisprotokoll von WoW nutzt.
Um es zu öffnen, gebt dies in die Konsole ein:

  /eventtrace

Eine Liste aller möglichen Ereignisse findet ihr auch hier:
https://warcraft.wiki.gg/wiki/Events

]]
L["Initialisation"] = "Initialisierung"
L["Initialisation Script"] = "Initialisierungs-Skript"
L["Lua code using the WoW UI API."] = "Lua-Code, der die WoW-UI-API verwendet."
L["Your \"Initialisation Script\" deviates from the stock setting for this situation. Click here to restore it."] = "Euer „Initialisierungs-Skript“ weicht von der Original-Einstellung für diese Situation ab. Klickt hier, um es wiederherzustellen."
L["<initialisation_desc>"] = [[Das Initialisierungs-Skript einer Situation wird einmal ausgeführt, wenn DynamicCam geladen wird (und auch, wenn die Situation modifiziert wird). Ihr würdet typischerweise Dinge dort hineinpacken, die ihr in einem der anderen Skripte (Bedingung, Eintreten, Verlassen) wiederverwenden wollt. Dies kann diese anderen Skripte etwas kürzer machen.

Zum Beispiel definiert das Initialisierungs-Skript der „Ruhestein/Teleport“-Situation die Tabelle „this.spells“, welche die Zauber-IDs von Teleport-Zaubern enthält. Das Bedingungs-Skript kann dann bei jeder Ausführung einfach auf „this.spells“ zugreifen.

Wie in diesem Beispiel könnt ihr jedes Datenobjekt zwischen den Skripten einer Situation teilen, indem ihr es in die „this“-Tabelle packt.

]]
L["Condition"] = "Bedingung"
L["Condition Script"] = "Bedingungs-Skript"
L["Lua code using the WoW UI API.\nShould return \"true\" if and only if the situation should be active."] = "Lua-Code, der die WoW-UI-API verwendet.\nSollte „true“ zurückgeben, wenn (und nur wenn) die Situation aktiv sein soll."
L["Your \"Condition Script\" deviates from the stock setting for this situation. Click here to restore it."] = "Euer „Bedingungs-Skript“ weicht von der Original-Einstellung für diese Situation ab. Klickt hier, um es wiederherzustellen."
L["<condition_desc>"] = [[Das Bedingungs-Skript einer Situation wird jedes Mal ausgeführt, wenn ein Ereignis dieser Situation im Spiel ausgelöst wird. Das Skript sollte „true“ zurückgeben, wenn (und nur wenn) diese Situation aktiv sein soll.

Zum Beispiel verwendet das Bedingungs-Skript der „Stadt“-Situation die WoW-API-Funktion „IsResting()“, um zu prüfen, ob ihr euch gerade in einem Erholungsbereich befindet:

  return IsResting()

Ebenso verwendet das Bedingungs-Skript der „Stadt (in Gebäuden)“-Situation die WoW-API-Funktion „IsIndoors()“, um zusätzlich zu prüfen, ob ihr euch in einem Gebäude befindet:

  return IsResting() and IsIndoors()

Eine Liste der WoW-API-Funktionen findet ihr hier:
https://warcraft.wiki.gg/wiki/World_of_Warcraft_API

]]
L["Entering"] = "Eintreten"
L["On-Enter Script"] = "Eintritts-Skript"
L["Your \"On-Enter Script\" deviates from the stock setting for this situation. Click here to restore it."] = "Euer „Eintritts-Skript“ weicht von der Original-Einstellung für diese Situation ab. Klickt hier, um es wiederherzustellen."
L["<executeOnEnter_desc>"] = [[Das Eintritts-Skript einer Situation wird jedes Mal ausgeführt, wenn die Situation betreten wird.

Bisher ist das einzige Beispiel hierfür die „Ruhestein/Teleport“-Situation, in der wir die WoW-API-Funktion „UnitCastingInfo()“ verwenden, um die Zauberdauer des aktuellen Zaubers zu bestimmen. Wir weisen dies dann den Variablen „this.transitionTime“ und „this.rotationTime“ zu, sodass ein Zoom oder eine Rotation (siehe „Situations-Aktionen“) exakt so lange dauern kann wie das Wirken des Zaubers. (Nicht alle Teleport-Zauber haben dieselbe Zauberdauer.)

]]
L["Exiting"] = "Verlassen"
L["On-Exit Script"] = "Austritts-Skript"
L["Your \"On-Exit Script\" deviates from the stock setting for this situation. Click here to restore it."] = "Euer „Austritts-Skript“ weicht von der Original-Einstellung für diese Situation ab. Klickt hier, um es wiederherzustellen."
L["Exit Delay"] = "Austritts-Verzögerung"
L["Wait for this many seconds before exiting this situation."] = "Wartet so viele Sekunden, bevor diese Situation verlassen wird."
L["Your \"Exit Delay\" deviates from the stock setting for this situation. Click here to restore it."] = "Eure „Austritts-Verzögerung“ weicht von der Original-Einstellung für diese Situation ab. Klickt hier, um sie wiederherzustellen."
L["<executeOnExit_desc>"] = [[Das Austritts-Skript einer Situation wird jedes Mal ausgeführt, wenn die Situation verlassen wird. Bisher nutzt dies keine Situation.

Die Verzögerung bestimmt, wie viele Sekunden gewartet werden soll, bevor die Situation verlassen wird. Das bisher einzige Beispiel hierfür ist die „Angeln“-Situation, wo die Verzögerung euch Zeit gibt, eure Angelrute erneut auszuwerfen, ohne die Situation zu verlassen.

]]
L["Export"] = "Exportieren"
L["Coming soon(TM)."] = "Demnächst(TM)."
L["Import"] = "Importieren"
L["<welcomeMessage>"] = [[Wir freuen uns, dass ihr hier seid, und hoffen, dass ihr Spaß mit dem Addon habt.

DynamicCam (DC) wurde im Mai 2016 von mpstark gestartet, als die WoW-Entwickler bei Blizzard die experimentellen ActionCam-Funktionen ins Spiel einführten. Der Hauptzweck von DC war es, eine Benutzeroberfläche für die ActionCam-Einstellungen bereitzustellen. Im Spiel ist die ActionCam immer noch als „experimentell“ gekennzeichnet, und es gab keine Anzeichen von Blizzard, sie weiterzuentwickeln. Es gibt einige Unzulänglichkeiten, aber wir sollten dankbar sein, dass die ActionCam für Enthusiasten wie uns im Spiel belassen wurde. :-) DC erlaubt es euch nicht nur, die ActionCam-Einstellungen zu ändern, sondern auch unterschiedliche Einstellungen für verschiedene Spielsituationen zu haben. Unabhängig von der ActionCam bietet DC auch Funktionen bezüglich Kamerazoom und Ausblenden des Interfaces.

Die Arbeit von mpstark an DC ging bis August 2018. Während die meisten Funktionen für eine beträchtliche Nutzerbasis gut funktionierten, betrachtete mpstark DC immer als im Beta-Status, und aufgrund seines schwindenden Interesses an WoW nahm er seine Arbeit nicht wieder auf. Zu dieser Zeit hatte Ludius bereits begonnen, Anpassungen an DC für sich selbst vorzunehmen, was von Weston (aka dernPerkins) bemerkt wurde, der Anfang 2020 Kontakt zu mpstark herstellte, was dazu führte, dass Ludius die Entwicklung übernahm. Die erste Nicht-Beta-Version 1.0 wurde im Mai 2020 veröffentlicht und enthielt Ludius' Anpassungen bis zu diesem Zeitpunkt. Danach begann Ludius mit einer Überarbeitung von DC, was zur Veröffentlichung von Version 2.0 im Herbst 2022 führte.

Als mpstark DC startete, lag sein Fokus darauf, die meisten Anpassungen im Spiel vorzunehmen, anstatt den Quellcode ändern zu müssen. Dies machte es einfacher, insbesondere mit den verschiedenen Spielsituationen zu experimentieren. Ab Version 2.0 wurden diese erweiterten Einstellungen in einen speziellen Bereich namens „Situations-Steuerung“ verschoben. Die meisten Benutzer werden ihn wahrscheinlich nie benötigen, aber für „Power-User“ ist er weiterhin verfügbar. Eine Gefahr bei Änderungen dort ist, dass gespeicherte Benutzereinstellungen immer die Original-Einstellungen von DC überschreiben, selbst wenn neue Versionen von DC aktualisierte Original-Einstellungen mitbringen. Daher wird oben auf dieser Seite eine Warnung angezeigt, wann immer ihr Original-Situationen mit modifizierter „Situations-Steuerung“ habt.

Wenn ihr denkt, dass eine von DCs Original-Situationen geändert werden sollte, könnt ihr immer eine Kopie davon mit euren Änderungen erstellen. Fühlt euch frei, diese neue Situation zu exportieren und auf der CurseForge-Seite von DC zu posten. Wir können sie dann als eigene neue Original-Situation hinzufügen. Ihr seid auch willkommen, euer gesamtes DC-Profil zu exportieren und zu posten, da wir immer auf der Suche nach neuen Profil-Voreinstellungen sind, die Neulingen einen einfacheren Einstieg in DC ermöglichen. Wenn ihr ein Problem findet oder einen Vorschlag machen wollt, hinterlasst einfach eine Notiz in den CurseForge-Kommentaren oder, noch besser, nutzt die Issues auf GitHub. Wenn ihr etwas beitragen möchtet, könnt ihr dort auch gerne einen Pull Request öffnen.

Hier sind einige praktische Slash-Befehle:

    `/dynamiccam` oder `/dc` öffnet dieses Menü.
    `/zoominfo` oder `/zi` gibt die aktuelle Zoomstufe aus.

    `/zoom #1 #2` zoomt auf Stufe #1 in #2 Sekunden.
    `/yaw #1 #2` schwenkt die Kamera um #1 Grad in #2 Sekunden (negatives #1 zum Schwenken nach rechts).
    `/pitch #1 #2` neigt die Kamera um #1 Grad (negatives #1 zum Neigen nach oben).


]]
L["About"] = "Über"
L["The following game situations have \"Situation Controls\" deviating from DynamicCam's stock settings.\n\n"] = "Die folgenden Spielsituationen haben eine „Situations-Steuerung“, die von den Original-Einstellungen von DynamicCam abweicht.\n\n"
L["<situationControlsWarning>"] = "\nWenn ihr dies absichtlich tut, ist es in Ordnung. Seid euch nur bewusst, dass alle Updates dieser Einstellungen durch die DynamicCam-Entwickler immer von eurer modifizierten (möglicherweise veralteten) Version überschrieben werden. Ihr könnt den Reiter „Situations-Steuerung“ jeder Situation für Details prüfen. Wenn ihr euch keiner Änderungen der „Situations-Steuerung“ eurerseits bewusst seid und einfach die Original-Steuerungseinstellungen für *alle* Situationen wiederherstellen wollt, klickt diesen Button:"
L["Restore all stock Situation Controls"] = "Alle Original-Situations-Steuerungen wiederherstellen"
L["Hello and welcome to DynamicCam!"] = "Hallo und willkommen bei DynamicCam!"
L["Profiles"] = "Profile"
L["Manage Profiles"] = "Profile verwalten"
L["<manageProfilesWarning>"] = "Wie viele Addons verwendet DynamicCam die „AceDB-3.0“-Bibliothek zur Verwaltung von Profilen. Was ihr verstehen müsst, ist, dass es hier kein „Profil speichern“ oder ähnliches gibt. Ihr könnt nur neue Profile erstellen und Einstellungen von einem anderen Profil in das aktuell aktive kopieren. Welche Änderung ihr auch immer für das aktuell aktive Profil vornehmt, wird sofort gespeichert! Es gibt kein „Abbrechen“ oder „Änderungen verwerfen“. Der Button „Profil zurücksetzen“ setzt nur auf das globale Standardprofil zurück.\n\nWenn ihr also eure DynamicCam-Einstellungen mögt, solltet ihr ein weiteres Profil erstellen, in das ihr diese Einstellungen als Backup kopiert. Wenn ihr dieses Backup-Profil nicht als euer aktives Profil verwendet, könnt ihr mit den Einstellungen experimentieren und jederzeit zu eurem ursprünglichen Profil zurückkehren, indem ihr euer Backup-Profil in der Box „Kopieren von“ auswählt.\n\nWenn ihr Profile per Makro wechseln wollt, könnt ihr Folgendes verwenden:\n/run DynamicCam.db:SetProfile(\"Profilname hier\")\n\n"
L["Profile presets"] = "Profil-Voreinstellungen"
L["Import / Export"] = "Import / Export"
L["DynamicCam"] = "DynamicCam"
L["Disabled"] = "Deaktiviert"
L["Your DynamicCam addon lets you adjust horizontal and vertical mouse look speed individually! Just go to the \"Mouse Look\" settings of DynamicCam to make the adjustments there."] = "Euer DynamicCam-Addon lässt euch die horizontale und vertikale Maussichttempo individuell anpassen! Geht einfach zu den „Maussicht“-Einstellungen von DynamicCam, um die Anpassungen dort vorzunehmen."
L["Attention"] = "Achtung"
L["The \"%s\" setting is disabled by DynamicCam, while you are using the horizontal camera over shoulder offset."] = "Die Einstellung „%s“ ist durch DynamicCam deaktiviert, während ihr den horizontalen Kamera-Über-Schulter-Versatz verwendet."
L["While you are using horizontal camera offset, DynamicCam prevents CameraKeepCharacterCentered!"] = "Während ihr den horizontalen Kameraversatz verwendet, verhindert DynamicCam CameraKeepCharacterCentered!"
L["While you are using horizontal camera offset, DynamicCam prevents CameraReduceUnexpectedMovement!"] = "Während ihr den horizontalen Kameraversatz verwendet, verhindert DynamicCam CameraReduceUnexpectedMovement!"
L["While you are using vertical camera pitch, DynamicCam prevents CameraKeepCharacterCentered!"] = "Während ihr die vertikale Kameraneigung verwendet, verhindert DynamicCam CameraKeepCharacterCentered!"
L["cameraView=%s prevented by DynamicCam!"] = "cameraView=%s durch DynamicCam verhindert!"

-- MouseZoom
L["Current\nZoom\nValue"] = "Momentaner\nZoom-\nWert"
L["Reactive\nZoom\nTarget"] = "Reaktiv-\nZoom-\nZiel"

-- Core
L["Enter name for custom situation:"] = "Namen für eigene Situation eingeben:"
L["Create"] = "Erstellen"
L["Cancel"] = "Abbrechen"

-- DefaultSettings
L["City"] = "Stadt"
L["City (Indoors)"] = "Stadt (in Gebäuden)"
L["World"] = "Welt"
L["World (Indoors)"] = "Welt (in Gebäuden)"
L["World (Combat)"] = "Welt (Kampf)"
L["Dungeon/Scenario"] = "Instanz/Szenario"
L["Dungeon/Scenario (Outdoors)"] = "Instanz/Szenario (Außenbereich)"
L["Dungeon/Scenario (Combat, Boss)"] = "Instanz/Szenario (Kampf, Boss)"
L["Dungeon/Scenario (Combat, Trash)"] = "Instanz/Szenario (Kampf, Trash)"
L["Raid"] = "Schlachtzug"
L["Raid (Outdoors)"] = "Schlachtzug (Außenbereich)"
L["Raid (Combat, Boss)"] = "Schlachtzug (Kampf, Boss)"
L["Raid (Combat, Trash)"] = "Schlachtzug (Kampf, Trash)"
L["Arena"] = "Arena"
L["Arena (Combat)"] = "Arena (Kampf)"
L["Battleground"] = "Schlachtfeld"
L["Battleground (Combat)"] = "Schlachtfeld (Kampf)"
L["Mounted (any)"] = "Reittier (beliebig)"
L["Mounted (only flying-mount)"] = "Reittier (nur Flugreittier)"
L["Mounted (only flying-mount + airborne)"] = "Reittier (nur Flugreittier + in der Luft)"
L["Mounted (only flying-mount + airborne + Skyriding)"] = "Reittier (nur Flugreittier + in der Luft + Himmelsreiten)"
L["Mounted (only flying-mount + Skyriding)"] = "Reittier (nur Flugreittier + Himmelsreiten)"
L["Mounted (only airborne)"] = "Reittier (nur in der Luft)"
L["Mounted (only airborne + Skyriding)"] = "Reittier (nur in der Luft + Himmelsreiten)"
L["Mounted (only Skyriding)"] = "Reittier (nur Himmelsreiten)"
L["Druid Travel Form"] = "Druide Reisegestalt"
L["Dracthyr Soar"] = "Dracthyr Segeln"
L["Skyriding Race"] = "Himmelsreiten-Rennen"
L["Taxi"] = "Taxi"
L["Vehicle"] = "Fahrzeug"
L["Hearth/Teleport"] = "Ruhestein/Teleport"
L["Annoying Spells"] = "Nervige Zauber"
L["NPC Interaction"] = "NPC-Interaktion"
L["Mailbox"] = "Briefkasten"
L["Fishing"] = "Angeln"
L["Gathering"] = "Sammeln"
L["AFK"] = "AFK"
L["Pet Battle"] = "Haustierkampf"
L["Professions Frame Open"] = "Berufsfenster offen"
