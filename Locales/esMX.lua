local L = LibStub("AceLocale-3.0"):NewLocale("DynamicCam", "esMX") if not L then return end


--------------------------------------------------------------------------------
-- General UI Elements
--------------------------------------------------------------------------------
L["Reset"] = "Restablecer"
L["Reset to global default"] = "Usar predeterminado global"
L["(To restore the settings of a specific profile, restore the profile in the \"Profiles\" tab.)"] = "(Para restaurar la configuración de un perfil específico, restaura el perfil en la pestaña «Perfiles».)"
L["Standard Settings"] = "Ajustes Estándar"
L["<standardSettings_desc>"] = "Estos Ajustes Estándar se aplican cuando no hay ninguna situación activa, o cuando la situación activa no tiene ningún Ajuste de Situación que anule los Ajustes Estándar."
L["<standardSettingsOverridden_desc>"] = "Las categorías marcadas en verde están actualmente anuladas por la situación activa. Por lo tanto, no verás ningún efecto al cambiar los Ajustes Estándar de las categorías verdes mientras la situación que las anula esté activa."
L["Currently overridden by the active situation \"%s\"."] = "Actualmente anulado por la situación activa «%s»."
L["Help"] = "Ayuda"
L["WARNING"] = "ADVERTENCIA"
L["Error message:"] = "Mensaje de error:"
L["DynamicCam"] = "DynamicCam"


--------------------------------------------------------------------------------
-- Common Controls (Used Across Multiple Sections)
--------------------------------------------------------------------------------
L["Override Standard Settings"] = "Anular Ajustes Estándar"
L["<overrideStandardToggle_desc>"] = "Al marcar esta casilla, se pueden configurar los ajustes de esta categoría. Estos Ajustes de Situación anulan los Ajustes Estándar en cuanto esta situación se activa. Al desmarcar la casilla, se borran los Ajustes de Situación de esta categoría."
L["Situation Settings"] = "Ajustes de Situación"
L["These Situation Settings override the Standard Settings when the respective situation is active."] = "Estos Ajustes de Situación anulan los Ajustes Estándar cuando la situación respectiva está activa."
L["Enable"] = "Activar"


--------------------------------------------------------------------------------
-- Options - Mouse Zoom
--------------------------------------------------------------------------------
L["Mouse Zoom"] = "Zoom del ratón"
L["Maximum Camera Distance"] = "Distancia máxima de la cámara"
L["How many yards the camera can zoom away from your character."] = "Cuántas yardas puede alejarse la cámara de tu personaje."
L["Camera Zoom Speed"] = "Velocidad de zoom de la cámara"
L["How fast the camera can zoom."] = "Qué tan rápido puede acercarse o alejarse la cámara."
L["Zoom Increments"] = "Incrementos de zoom"
L["How many yards the camera should travel for each \"tick\" of the mouse wheel."] = "Cuántas yardas se debe mover la cámara por cada «tick» de la rueda del ratón."
L["Use Reactive Zoom"] = "Usar zoom reactivo"
L["Quick-Zoom Additional Increments"] = "Incrementos adicionales de zoom rápido"
L["How many yards per mouse wheel \"tick\" should be added when quick-zooming."] = "Cuántas yardas por «tick» de la rueda del ratón deben añadirse al hacer zoom rápido."
L["Quick-Zoom Enter Threshold"] = "Umbral de entrada del zoom rápido"
L["How many yards the \"Reactive Zoom Target\" and the \"Current Zoom Value\" have to be apart to enter quick-zooming."] = "Cuántas yardas deben separar el «objetivo de zoom reactivo» y el «valor de zoom actual» para entrar en el zoom rápido."
L["Maximum Zoom Time"] = "Tiempo máximo de zoom"
L["The maximum time the camera should take to make \"Current Zoom Value\" equal to \"Reactive Zoom Target\"."] = "El tiempo máximo que la cámara debe tardar en hacer que el «valor de zoom actual» sea igual al «objetivo de zoom reactivo»."
L["Toggle Visual Aid"] = "Alternar Ayuda Visual"
L["<reactiveZoom_desc>"] = "With DynamicCam's Reactive Zoom the mouse wheel controls the so called \"Reactive Zoom Target\". Whenever the \"Reactive Zoom Target\" and the \"Current Zoom Value\" are different, DynamicCam changes the \"Current Zoom Value\" until it matches the \"Reactive Zoom Target\" again.\n\nHow fast this zoom change is happening depends on \"Camera Zoom Speed\" and \"Maximum Zoom Time\". If \"Maximum Zoom Time\" is set low, the zoom change will always be executed fast, regardless of the \"Camera Zoom Speed\" setting. To achieve a slower zoom change, you must set \"Maximum Zoom Time\" to a higher value and \"Camera Zoom Speed\" to a lower value.\n\nTo enable faster zooming with faster mouse wheel movement, there is \"Quick-Zoom\": if the \"Reactive Zoom Target\" is further away from the \"Current Zoom Value\" than the \"Quick-Zoom Enter Threshold\", the amount of \"Quick-Zoom Additional Increments\" is added to every mouse wheel tick.\n\nTo get a feeling of how this works, you can toggle the visual aid while finding your ideal settings. You can also freely move this graph by left-clicking and dragging it. A right-click closes it."
L["Enhanced minimal zoom-in"] = "Zoom mínimo mejorado"
L["<enhancedMinZoom_desc>"] = "El zoom reactivo permite acercarse más que el nivel 1. Esto se puede conseguir alejando la rueda del ratón un tick desde la primera persona.\n\nCon el «Zoom mínimo mejorado» forzamos a la cámara a detenerse también en este nivel de zoom mínimo al acercarse, antes de que salte a la primera persona.\n\n|cFFFF0000Activar el «Zoom mínimo mejorado» puede costar hasta un 15% de FPS en situaciones limitadas por la CPU.|r"
L["/reload of the UI required!"] = "¡Se requiere /reload de la interfaz!"


--------------------------------------------------------------------------------
-- Options - Mouse Look
--------------------------------------------------------------------------------
L["Mouse Look"] = "Giro de cámara con ratón"
L["Horizontal Speed"] = "Velocidad horizontal"
L["How much the camera yaws horizontally when in mouse look mode."] = "Cuánto gira la cámara horizontalmente cuando está en modo giro de cámara con ratón."
L["Vertical Speed"] = "Velocidad vertical"
L["How much the camera pitches vertically when in mouse look mode."] = "Cuánto se inclina la cámara verticalmente cuando está en modo giro de cámara con ratón."
L["<mouseLook_desc>"] = "Cuánto se mueve la cámara cuando mueves el ratón en modo «giro de cámara con ratón»; es decir, mientras el botón izquierdo o derecho del ratón está presionado.\n\nEl deslizador «Vel. giro cámara con ratón» de los ajustes de interfaz predeterminados de WoW controla la velocidad horizontal y vertical al mismo tiempo: estableciendo automáticamente la velocidad horizontal a 2 x la velocidad vertical. DynamicCam anula esto y te permite una configuración más personalizada."


--------------------------------------------------------------------------------
-- Options - Horizontal Offset
--------------------------------------------------------------------------------
L["Horizontal Offset"] = "Desplazamiento horizontal"
L["Camera Over Shoulder Offset"] = "Desplazamiento de la cámara por encima del hombro"
L["Positions the camera left or right from your character."] = "Posiciona la cámara a la izquierda o a la derecha de tu personaje."
L["<cameraOverShoulder_desc>"] = "Para que esto surta efecto, DynamicCam desactiva automáticamente y temporalmente el ajuste de Cinetosis de WoW. Así que, si necesitas el ajuste de Cinetosis, no utilices el desplazamiento horizontal en estas situaciones.\n\nCuando seleccionas a tu propio personaje, WoW centra automáticamente la cámara. No hay nada que podamos hacer al respecto. Tampoco podemos hacer nada con los tirones de desplazamiento que puedan ocurrir al colisionar la cámara con una pared. Una solución es usar poco o ningún desplazamiento dentro de los edificios.\n\nAdemás, WoW aplica el desplazamiento de forma extraña dependiendo del modelo de personaje o la montura. Para todos los que prefieran un desplazamiento constante, Ludius está trabajando en otro addon («CameraOverShoulder Fix») para resolver esto."


--------------------------------------------------------------------------------
-- Options - Vertical Pitch
--------------------------------------------------------------------------------
L["Vertical Pitch"] = "Inclinación vertical"
L["Pitch (on ground)"] = "Inclinación (en tierra)"
L["Pitch (flying)"] = "Inclinación (volando)"
L["Down Scale"] = "Factor de reducción"
L["Smart Pivot Cutoff Distance"] = "Distancia límite de pivote inteligente"
L["<pitch_desc>"] = "If the camera is pitched upwards (lower \"Pitch\" value), the \"Down Scale\" setting determines how much this comes into effect while looking at your character from above. Setting \"Down Scale\" to 0 nullifies the effect of an upwards pitch while looking from above. On the contrary, while you are not looking from above or if the camera is pitched downwards (greater \"Pitch\" value), the \"Down Scale\" setting has little to no effect.\n\nThus, you should first find your preferred \"Pitch\" setting while looking at your character from behind. Afterwards, if you have chosen an upwards pitch, find your preferred \"Down Scale\" setting while looking from above.\n\n\nWhen the camera collides with the ground, it normally performs an upwards pitch on the spot of the camera-to-ground collision. An alternative is that the camera moves closer to your character's feet while performing this pitch. The \"Smart Pivot Cutoff Distance\" setting determines the distance that the camera has to be inside of to do the latter. Setting it to 0 never moves the camera closer (WoW's default), whereas setting it to the maximum zoom distance of 39 always moves the camera closer.\n\n"


--------------------------------------------------------------------------------
-- Options - Target Focus
--------------------------------------------------------------------------------
L["Target Focus"] = "Enfoque de objetivo"
L["Enemy Target"] = "Objetivo enemigo"
L["Horizontal Strength"] = "Fuerza horizontal"
L["Vertical Strength"] = "Fuerza vertical"
L["Interaction Target (NPCs)"] = "Objetivo de interacción (PNJ)"
L["<targetFocus_desc>"] = "Si está activado, la cámara intenta automáticamente acercar el objetivo al centro de la pantalla. La fuerza determina la intensidad de este efecto.\n\nSi tanto «Objetivo enemigo» como «Objetivo de interacción» están activados, parece haber un error extraño con este último: al interactuar con un PNJ por primera vez, la cámara se mueve suavemente a su nuevo ángulo como se espera. Pero al salir de la interacción, salta inmediatamente a su ángulo anterior. Si reinicias la interacción, vuelve a saltar bruscamente al nuevo ángulo. Esto se repite cada vez que hablas con un nuevo PNJ: solo la primera transición es suave, todas las siguientes son inmediatas.\nUna solución alternativa, si quieres usar tanto «Objetivo enemigo» como «Objetivo de interacción», es activar «Objetivo enemigo» solo para situaciones de DynamicCam en las que lo necesites y en las que las interacciones con PNJ sean improbables (como en Combate)."


--------------------------------------------------------------------------------
-- Options - Head Tracking
--------------------------------------------------------------------------------
L["Head Tracking"] = "Seguimiento de cabeza"
L["<headTrackingEnable_desc>"] = "(Esto también podría usarse como un valor continuo entre 0 y 1, pero simplemente se multiplica por «Fuerza (de pie)» y «Fuerza (en movimiento)» respectivamente. Por lo tanto, realmente no se necesita otro deslizador.)"
L["Strength (standing)"] = "Fuerza (de pie)"
L["Inertia (standing)"] = "Inercia (de pie)"
L["Strength (moving)"] = "Fuerza (en movimiento)"
L["Inertia (moving)"] = "Inercia (en movimiento)"
L["Inertia (first person)"] = "Inercia (primera persona)"
L["Range Scale"] = "Escala de alcance"
L["Camera distance beyond which head tracking is reduced or disabled. (See explanation below.)"] = "Distancia de la cámara más allá de la cual el seguimiento de cabeza se reduce o desactiva. (Ver explicación abajo.)"
L["(slider value transformed)"] = "(valor del deslizador transformado)"
L["Dead Zone"] = "Zona muerta"
L["Radius of head movement not affecting the camera. (See explanation below.)"] = "Radio del movimiento de la cabeza que no afecta a la cámara. (Ver explicación abajo.)"
L["(slider value devided by 10)"] = "(valor del deslizador dividido por 10)"
L["Requires /reload to come into effect!"] = "¡Requiere /reload para surtir efecto!"
L["<headTracking_desc>"] = "With head tracking enabled the camera follows the movement of your character's head. (While this can be a benefit for immersion, it may also cause nausea if you are prone to motion sickness.)\n\nThe \"Strength\" setting determines the intensity of this effect. Setting it to 0 disables head tracking. The \"Inertia\" setting determines how fast the camera reacts to head movements. Setting it to 0 also disables head tracking. The three cases \"standing\", \"moving\" and \"first person\" can be set up individually. There is no \"Strength\" setting for \"first person\" as it assumes the \"Strength\" settings of \"standing\" and \"moving\" respectively. If you want to enable or disable \"first person\" exclusively, use the \"Inertia\" sliders to disable the unwanted cases.\n\nWith the \"Range Scale\" setting you can set the camera distance beyond which head tracking is reduced or disabled. For example, with the slider set to 30 you will have no head tracking when the camera is more than 30 yards away from your character. However, there is a gradual transition from full head tracking to no head tracking, which starts at one third of the slider value. For example, with the slider value set to 30 you have full head tracking when the camera is closer than 10 yards. Beyond 10 yards, head tracking gradually decreases until it is completely gone beyond 30 yards. Hence, the slider's maximum value is 117 allowing for full head tracking at the maximum camera distance of 39 yards. (Hint: Use DynamicCam's \"Mouse Zoom\" visual aid to track the current camera distance while setting this up.)\n\nThe \"Dead Zone\" setting can be used to ignore smaller head movements. Setting it to 0 has the camera follow every slightest head movement, whereas setting it to a greater value results in it following only greater movements. Notice, that changing this setting only comes into effect after reloading the UI (type /reload into the console)."


--------------------------------------------------------------------------------
-- Situations Tab
--------------------------------------------------------------------------------
L["Situations"] = "Situaciones"
L["Select a situation to setup"] = "Selecciona una situación para configurar"
L["<selectedSituation_desc>"] = "\n|cffffcc00Colour codes:|r\n|cFF808A87- Disabled situation.|r\n- Enabled situation.\n|cFF00FF00- Enabled and currently active situation.|r\n|cFF63B8FF- Enabled situation with fulfilled condition but lower priority than the currently active situation.|r\n|cFFFF6600- Modified stock \"Situation Controls\" (reset recommended).|r\n|cFFEE0000- Erroneous \"Situation Controls\" (fixing required).|r"
L["If this box is checked, DynamicCam will enter the situation \"%s\" whenever its condition is fulfilled and no other situation with higher priority is active."] = "Si esta casilla está marcada, DynamicCam entrará en la situación «%s» siempre que se cumpla su condición y no haya otra situación activa con mayor prioridad."
L["Custom:"] = "Personalizado:"
L["(modified)"] = "(modificado)"
L["Delete custom situation \"%s\".\n|cFFEE0000Attention: There will be no 'Are you sure?' prompt!|r"] = "Eliminar situación personalizada «%s».\n|cFFEE0000Atención: ¡No habrá aviso de «¿Estás seguro?»!|r"
L["Create a new custom situation."] = "Crear una nueva situación personalizada."


--------------------------------------------------------------------------------
-- Situation Actions - General
--------------------------------------------------------------------------------
L["Situation Actions"] = "Acciones de situación"
L["Setup stuff to happen while in a situation or when entering/exiting it."] = "Configura cosas que sucedan mientras estás en una situación o al entrar/salir de ella."
L["Transition Time"] = "Tiempo de transición"
L["Enter Transition Time"] = "Tiempo de transición (Entrada)"
L["The time in seconds for the transition when ENTERING this situation."] = "El tiempo en segundos para la transición al ENTRAR en esta situación."
L["Exit Transition Time"] = "Tiempo de transición (Salida)"
L["The time in seconds for the transition when EXITING this situation."] = "El tiempo en segundos para la transición al SALIR de esta situación."
L["<transitionTime_desc>"] = [[Estos tiempos controlan cuánto tiempo se tarda en cambiar entre situaciones.

Al entrar en una situación, el "Tiempo de transición (Entrada)" se usa para:
  • Transiciones de Zoom (cuando "Zoom/Vista" está activado y NO se restaura un zoom guardado)
  • Rotaciones de cámara (cuando "Rotación" está activado)
    - Para rotación "Continua": tiempo de aceleración hasta la velocidad de rotación
    - Para rotación "Por grados": tiempo para completar la rotación
  • Ocultar la IU (cuando "Ocultar interfaz" está activado)

Al salir de una situación, el "Tiempo de transición (Salida)" se usa para:
  • Restauración de Zoom (al volver a un zoom guardado desde los ajustes de "Restaurar Zoom")
  • Salida de rotación de cámara (cuando "Rotación" está activado)
    - Para rotación "Continua": tiempo de retardo desde la velocidad de rotación hasta detenerse
    - Para rotación "Por grados" con "Rotar atrás": tiempo para rotar hacia atrás
  • Rotar la cámara hacia atrás (cuando "Rotar atrás" está activado)
  • Mostrar la IU (si "Ocultar interfaz" estaba activo)

IMPORTANTE: Al pasar directamente de una situación a otra, el tiempo de entrada de la NUEVA situación tiene prioridad sobre el tiempo de salida de la antigua situación para la mayoría de las funciones. Sin embargo, si se restaura el zoom, se utiliza el tiempo de salida de la ANTIGUA situación. El tiempo de salida también se usa al cambiar a "ninguna situación".

Nota: Si estableces tiempos de transición en el script de entrada con "this.timeToEnter" (ver "Control de situación"), estos anulan los ajustes aquí.]]


--------------------------------------------------------------------------------
-- Situation Actions - Zoom/View
--------------------------------------------------------------------------------
L["Zoom/View"] = "Zoom/Vista"
L["Zoom to a certain zoom level or switch to a saved camera view when entering this situation."] = "Hace zoom a un cierto nivel o cambia a una vista de cámara guardada al entrar en esta situación."
L["Set Zoom or Set View"] = "Establecer zoom o vista"
L["Zoom Type"] = "Tipo de zoom"
L["<viewZoomType_desc>"] = "Establecer zoom: Hace zoom a un nivel dado con opciones avanzadas de tiempo de transición y condiciones.\n\nEstablecer vista: Cambia a una vista de cámara guardada que consiste en un nivel de zoom y ángulo de cámara fijos."
L["Set Zoom"] = "Establecer zoom"
L["Set View"] = "Establecer vista"
L["Set view to saved view:"] = "Establecer vista a vista guardada:"
L["Select the saved view to switch to when entering this situation."] = "Selecciona la vista guardada a la que cambiar al entrar en esta situación."
L["Instant"] = "Instantáneo"
L["Make view transitions instant."] = "Hace que las transiciones de vista sean instantáneas."
L["Restore view when exiting"] = "Restaurar vista al salir"
L["When exiting the situation restore the camera position to what it was at the time of entering the situation."] = "Al salir de la situación, se restaura la posición de la cámara a la que tenía en el momento de entrar en la situación."
L["cameraSmoothNote"] = [[|cFFEE0000Atención:|r Estás usando el «Estilo de seguimiento de cámara» de WoW que pone automáticamente la cámara detrás del jugador. Esto no funciona mientras estás en una vista guardada personalizada. Es posible usar vistas guardadas personalizadas para situaciones en las que no se necesita el seguimiento de cámara (por ej. interacción con PNJ). Pero después de salir de la situación debes volver a una vista estándar no personalizada para que el seguimiento de cámara funcione de nuevo.]]
L["Restore to default view:"] = "Restaurar a vista predeterminada:"
L["<viewRestoreToDefault_desc>"] = [[Selecciona la vista predeterminada a la que volver al salir de esta situación.

Vista 1:   Zoom 0, Inclinación 0
Vista 2:   Zoom 5.5, Inclinación 10
Vista 3:   Zoom 5.5, Inclinación 20
Vista 4:   Zoom 13.8, Inclinación 30
Vista 5:   Zoom 13.8, Inclinación 10]]
L["You are using the same view as saved view and as restore-to-default view. Using a view as restore-to-default view will reset it. Only do this if you really want to use it as a non-customized saved view."] = "Tu vista guardada a establecer es la misma que tu vista predeterminada a restaurar. Si se usa una vista para restaurar a los valores predeterminados, se restablecerá. Haz esto solo si realmente quieres usarla como una vista guardada no personalizada."
L["View %s is used as saved view in the situations:\n%sand as restore-to-default view in the situations:\n%s"] = "La vista %s se usa como vista guardada en las situaciones:\n%sy como vista para restaurar a predeterminado en las situaciones:\n%s"
L["<view_desc>"] = [[WoW permite guardar hasta 5 vistas de cámara personalizadas. La Vista 1 es utilizada por DynamicCam para guardar la posición de la cámara al entrar en una situación, de modo que pueda restaurarse al salir de la situación de nuevo, si marcas la casilla «Restaurar» arriba. Esto es particularmente útil para situaciones cortas como la interacción con PNJ, permitiendo cambiar a una vista mientras se habla con el PNJ y luego volver a lo que era la cámara antes. Por eso la Vista 1 no se puede seleccionar en el menú desplegable de vistas guardadas de arriba.

Las vistas 2, 3, 4 y 5 se pueden usar para guardar posiciones de cámara personalizadas. Para guardar una vista, simplemente pon la cámara en el zoom y ángulo deseados. Luego escribe el siguiente comando en la consola (donde # es el número de vista 2, 3, 4 o 5):

  /saveView #

O abreviado:

  /sv #

Ten en cuenta que las vistas guardadas son almacenadas por WoW. DynamicCam solo almacena qué números de vista usar. Por lo tanto, cuando importas un nuevo perfil de situaciones de DynamicCam con vistas, probablemente tengas que configurar y guardar las vistas apropiadas después.


DynamicCam también proporciona un comando de consola para cambiar a una vista independientemente de entrar o salir de situaciones:

  /setView #

Para hacer la transición de vista instantánea, añade una «i» después del número de vista. Por ej. para cambiar inmediatamente a la Vista guardada 3 escribe:

  /setView 3 i

]]
L["<zoomType_desc>"] = "\nSet: Always set the zoom to this value.\n\nOut: Only set the zoom, if the camera is currently closer than this.\n\nIn: Only set the zoom, if the camera is currently further away than this.\n\nRange: Zoom in, if further away than the given maximum. Zoom out, if closer than the given minimum. Do nothing, if the current zoom is within the [min, max] range."
L["Set"] = "Establecer"
L["Out"] = "Alejar"
L["In"] = "Acercar"
L["Range"] = "Rango"
L["Don't slow"] = "No ralentizar"
L["Zoom transitions may be executed faster (but never slower) than the specified time above, if the \"Camera Zoom Speed\" (see \"Mouse Zoom\" settings) allows."] = "Las transiciones de zoom pueden ejecutarse más rápido (pero nunca más lento) que el tiempo especificado arriba, si la «Velocidad de zoom de la cámara» (ver ajustes de «Zoom del ratón») lo permite."
L["Zoom Value"] = "Valor de zoom"
L["Zoom to this zoom level."] = "Hace zoom a este nivel."
L["Zoom out to this zoom level, if the current zoom level is less than this."] = "Aleja a este nivel, si el nivel actual es menor."
L["Zoom in to this zoom level, if the current zoom level is greater than this."] = "Acerca a este nivel, si el nivel actual es mayor."
L["Zoom Min"] = "Zoom Mín"
L["Zoom Max"] = "Zoom Máx"
L["Restore Zoom"] = "Restaurar zoom"
L["<zoomRestoreSetting_desc>"] = "Cuando sales de una situación (o sales del estado predeterminado de ninguna situación activa), el nivel de zoom actual se guarda temporalmente para que pueda restaurarse una vez que entres en esta situación la próxima vez. Aquí puedes seleccionar cómo se maneja esto.\n\nEste ajuste es global para todas las situaciones."
L["Restore Zoom Mode"] = "Modo de restauración de zoom"
L["<zoomRestoreSettingSelect_desc>"] = "\nNunca: Al entrar en una situación, se aplica el ajuste de zoom real (si lo hay) de la situación entrante. No se tiene en cuenta ningún zoom guardado.\n\nSiempre: Al entrar en una situación, se usa el último zoom guardado de esta situación. Su ajuste real solo se tiene en cuenta al entrar en la situación por primera vez después de iniciar sesión.\n\nAdaptativo: El zoom guardado solo se usa bajo ciertas circunstancias. Por ej. solo cuando vuelves a la misma situación de la que viniste o cuando el zoom guardado cumple los criterios de los ajustes de zoom «Acercar», «Alejar» o «Rango» de la situación."
L["Never"] = "Nunca"
L["Always"] = "Siempre"
L["Adaptive"] = "Adaptativo"
L["<zoom_desc>"] = [[Para determinar el nivel de zoom actual, puedes usar la «Ayuda visual» (activada en los ajustes de «Zoom del ratón» de DynamicCam) o usar el comando de consola:

  /zoomInfo

O abreviado:

  /zi]]


--------------------------------------------------------------------------------
-- Situation Actions - Rotation
--------------------------------------------------------------------------------
L["Rotation"] = "Rotación"
L["Start a camera rotation when this situation is active."] = "Inicia una rotación de cámara cuando esta situación está activa."
L["Rotation Type"] = "Tipo de rotación"
L["<rotationType_desc>"] = "\nContinuamente: La cámara rota horizontalmente todo el tiempo mientras esta situación está activa. Solo aconsejable para situaciones en las que no mueves la cámara con el ratón; por ej. lanzamiento de hechizos de teletransporte, taxi o ausente (AFK). La rotación vertical continua no es posible ya que se detendría en la vista perpendicular desde arriba o desde abajo.\n\nPor grados: Después de entrar en la situación, cambia el giro actual de la cámara (horizontal) y/o la inclinación (vertical) por la cantidad de grados dada."
L["Continuously"] = "Continuamente"
L["By Degrees"] = "Por grados"
L["Rotation Speed"] = "Velocidad de rotación"
L["Speed at which to rotate in degrees per second. You can manually enter values between -900 and 900, if you want to get yourself really dizzy..."] = "Velocidad a la que rotar en grados por segundo. Puedes introducir manualmente valores entre -900 y 900, si quieres marearte de verdad..."
L["Yaw (-Left/Right+)"] = "Giro (-Izquierda/Derecha+)"
L["Degrees to yaw (left or right)."] = "Grados para girar (izquierda o derecha)."
L["Pitch (-Down/Up+)"] = "Inclinación (-Abajo/Arriba+)"
L["Degrees to pitch (up or down). There is no going beyond the perpendicular upwards or downwards view."] = "Grados para inclinar (arriba o abajo). No es posible ir más allá de la vista perpendicular desde arriba o desde abajo."
L["Rotate Back"] = "Rotación de retorno"
L["<rotateBack_desc>"] = "Al salir de la situación, rota hacia atrás la cantidad de grados (módulo 360) rotados desde que se entró en la situación. Esto te lleva efectivamente a la posición de la cámara antes de entrar, a menos que hayas cambiado el ángulo de visión con el ratón entretanto.\n\nSi entras en una nueva situación con un ajuste de rotación propio, se ignora la «Rotación de retorno» de la situación que sale."


--------------------------------------------------------------------------------
-- Situation Actions - Fade Out UI
--------------------------------------------------------------------------------
L["Fade Out UI"] = "Ocultar interfaz"
L["Fade out or hide (parts of) the UI when this situation is active."] = "Desvanece u oculta (partes de) la interfaz cuando esta situación está activa."
L["Adjust to Immersion"] = "Ajustar a Immersion"
L["<adjustToImmersion_desc>"] = "Mucha gente usa el addon Immersion en combinación con DynamicCam. Immersion tiene algunas funciones propias para ocultar la interfaz que entran en juego durante la interacción con PNJ. En ciertas circunstancias, la ocultación de interfaz de DynamicCam anula la de Immersion. Para evitar esto, haz tus ajustes deseados aquí en DynamicCam. Haz clic en este botón para usar los mismos tiempos de aparición y desaparición que Immersion. Para aún más opciones, echa un vistazo al otro addon de Ludius llamado «Immersion ExtraFade»."
L["Hide entire UI"] = "Ocultar toda la interfaz"
L["<hideEntireUI_desc>"] = "There is a difference between a \"hidden\" UI and a \"just faded out\" UI: the faded-out UI elements have an opacity of 0 but can still be interacted with. Since DynamicCam 2.0 we are automatically hiding most UI elements if their opacity is 0. Thus, this option of hiding the entire UI after fade out is more of a relic. A reason to still use it may be to avoid unwanted interactions (e.g. mouse-over tooltips) of UI elements DynamicCam is still not hiding properly.\n\nThe opacity of the hidden UI is of course 0, so you cannot choose a different opacity nor can you keep any UI elements visible (except the FPS indicator).\n\nDuring combat we cannot change the hidden status of protected UI elements. Hence, such elements are always set to \"just faded out\" during combat. Notice that the opacity of the Minimap \"blips\" cannot be reduced. Thus, if you try to hide the Minimap, the \"blips\" are always visible during combat.\n\nWhen you check this box for the currently active situation, it will not be applied at once, because this would also hide this settings frame. You have to enter the situation for it to take effect, which is also possible with the situation \"Enable\" checkbox above.\n\nAlso notice that hiding the entire UI cancels Mailbox or NPC interactions. So do not use it for such situations!"
L["Keep FPS indicator"] = "Mantener indicador FPS"
L["Do not fade out or hide the FPS indicator (the one you typically toggle with Ctrl + R)."] = "No desvanecer ni ocultar el indicador de FPS (el que normalmente alternas con Ctrl + R)."
L["Fade Opacity"] = "Opacidad de desvanecimiento"
L["Fade the UI to this opacity when entering the situation."] = "Desvanece la interfaz a esta opacidad al entrar en la situación."
L["Excluded UI elements"] = "Elementos de interfaz excluidos"
L["Keep Alerts"] = "Mantener alertas"
L["Still show alert popups from completed achievements, Covenant Renown, etc."] = "Seguir mostrando ventanas emergentes de alerta de logros completados, Renombre de Curia, etc."
L["Keep Tooltip"] = "Mantener descripción emergente"
L["Still show the game tooltip, which appears when you hover your mouse cursor over UI or world elements."] = "Seguir mostrando la descripción emergente del juego, que aparece cuando pasas el cursor del ratón sobre elementos de la interfaz o del mundo."
L["Keep Minimap"] = "Mantener minimapa"
L["<keepMinimap_desc>"] = "No desvanecer el minimapa.\n\nTen en cuenta que no podemos reducir la opacidad de los «puntos» en el minimapa. Estos solo pueden ocultarse junto con todo el minimapa, cuando la interfaz se desvanece a 0 de opacidad."
L["Keep Chat Box"] = "Mantener chat"
L["Do not fade out the chat box."] = "No desvanecer el cuadro de chat."
L["Keep Tracking Bar"] = "Mantener barra de experiencia/reputación"
L["Do not fade out the tracking bar (XP, AP, reputation)."] = "No desvanecer la barra de experiencia/reputación (XP, AP, reputación)."
L["Keep Party/Raid"] = "Mantener Grupo/Banda"
L["Do not fade out the Party/Raid frame."] = "No desvanecer el marco de Grupo/Banda."
L["Keep Encounter Frame (Skyriding Vigor)"] = "Mantener marco de encuentro (Vigor de Surcacielos)"
L["Do not fade out the Encounter Frame, which while skyriding is the Vigor display."] = "No desvanecer el marco de encuentro, que mientras usas Surcacielos es la visualización de Vigor."
L["Keep additional frames"] = "Mantener marcos adicionales"
L["<keepCustomFrames_desc>"] = "El cuadro de texto a continuación te permite definir cualquier marco que quieras mantener durante la interacción con PNJ.\n\nUsa el comando de consola /fstack para conocer los nombres de los marcos.\n\nPor ejemplo, es posible que quieras mantener los iconos de beneficios junto al minimapa para poder desmontar durante la interacción con PNJ haciendo clic en el icono apropiado."
L["Custom frames to keep"] = "Marcos personalizados a mantener"
L["Separated by commas."] = "Separados por comas."
L["Emergency Fade In"] = "Aparición de emergencia"
L["Pressing Esc fades the UI back in."] = "Pulsar Esc hace reaparecer la interfaz."
L["<emergencyShow_desc>"] = [[A veces necesitas mostrar la interfaz incluso en situaciones donde normalmente quieres que esté oculta. Las versiones antiguas de DynamicCam establecieron que la interfaz se mostrara siempre que se pulsara la tecla Esc. La desventaja de esto es que la interfaz también se muestra cuando la tecla Esc se usa para otros fines como cerrar ventanas, cancelar lanzamientos de hechizos, etc. Desmarcar la casilla de arriba desactiva esto.

¡Sin embargo, ten en cuenta que puedes quedarte sin acceso a la interfaz de esta manera! Una mejor alternativa a la tecla Esc son los siguientes comandos de consola, que muestran u ocultan la interfaz según los ajustes de «Ocultar interfaz» de la situación actual:

    /showUI
    /hideUI

Para una tecla rápida de aparición conveniente, pon /showUI en una macro y asígnale una tecla en tu archivo «bindings-cache.wtf». Por ej.:

    bind ALT+F11 MACRO Nombre De Tu Macro

Si editar el archivo «bindings-cache.wtf» te echa para atrás, podrías usar un addon de atajos de teclado como «BindPad».

Usar /showUI o /hideUI sin argumentos toma el tiempo de aparición o desaparición de la situación actual. Pero también puedes proporcionar un tiempo de transición diferente. Por ej.:

    /showUI 0

para mostrar la interfaz sin ningún retraso.]]
L["<hideUIHelp_desc>"] = "Mientras configuras tus efectos de desvanecimiento de interfaz deseados, puede ser molesto cuando este marco de ajustes «Interfaz» se desvanece también. Si esta casilla está marcada, no se desvanecerá.\n\nEste ajuste es global para todas las situaciones."
L["Do not fade out this \"Interface\" settings frame."] = "No desvanecer este marco de ajustes «Interfaz»."


--------------------------------------------------------------------------------
-- Situation Controls
--------------------------------------------------------------------------------
L["Situation Controls"] = "Controles de situación"
L["<situationControls_help>"] = "Aquí controlas cuándo está activa una situación. Puede ser necesario conocer la API de la interfaz de WoW. Si estás contento con las situaciones originales de DynamicCam, simplemente ignora esta sección. Pero si quieres crear situaciones personalizadas, puedes consultar las situaciones originales aquí. También puedes modificarlas, pero ten cuidado: tus ajustes modificados persistirán incluso si futuras versiones de DynamicCam introducen actualizaciones importantes.\n\n"
L["Priority"] = "Prioridad"
L["The priority of this situation.\nMust be a number."] = "La prioridad de esta situación.\nDebe ser un número."
L["Restore stock setting"] = "Restaurar ajuste original"
L["Your \"Priority\" deviates from the stock setting for this situation (%s). Click here to restore it."] = "Tu «Prioridad» difiere del ajuste original para esta situación (%s). Haz clic aquí para restaurarla."
L["<priority_desc>"] = "Si se cumplen las condiciones de varias situaciones diferentes de DynamicCam al mismo tiempo, se entra en la situación con la prioridad más alta. Por ejemplo, siempre que se cumple la condición de «Mundo (interiores)», también se cumple la condición de «Mundo». Pero como «Mundo (interiores)» tiene una prioridad más alta que «Mundo», se prioriza. También puedes ver las prioridades de todas las situaciones en el menú desplegable de arriba.\n\n"
L["Events"] = "Eventos"
L["Your \"Events\" deviate from the default for this situation. Click here to restore them."] = "Tus «Eventos» difieren de los originales para esta situación. Haz clic aquí para restaurarlos."
L["<events_desc>"] = [[Aquí defines todos los eventos del juego en los que DynamicCam debe comprobar la condición de esta situación, para entrar o salir de ella si corresponde.

Puedes aprender sobre los eventos del juego usando el Registro de eventos de WoW.
Para abrirlo, escribe esto en la consola:

  /eventtrace

También puedes encontrar una lista de todos los eventos posibles aquí:
https://warcraft.wiki.gg/wiki/Events

]]
L["Initialisation"] = "Inicialización"
L["Initialisation Script"] = "Script de inicialización"
L["Lua code using the WoW UI API."] = "Código Lua usando la API de interfaz de WoW."
L["Your \"Initialisation Script\" deviates from the stock setting for this situation. Click here to restore it."] = "Tu «Script de inicialización» difiere del ajuste original para esta situación. Haz clic aquí para restaurarlo."
L["<initialisation_desc>"] = [[El script de inicialización de una situación se ejecuta una vez cuando se carga DynamicCam (y también cuando se modifica la situación). Normalmente pondrías cosas en él que quieras reutilizar en cualquiera de los otros scripts (condición, entrada, salida). Esto puede hacer que estos otros scripts sean un poco más cortos.

Por ejemplo, el script de inicialización de la situación «Piedra de hogar/Teletransporte» define la tabla «this.spells», que incluye los ID de hechizo de los hechizos de teletransporte. El script de condición puede entonces simplemente acceder a «this.spells» cada vez que se ejecuta.

Como en este ejemplo, puedes compartir cualquier objeto de datos entre los scripts de una situación poniéndolo en la tabla «this».

]]
L["Condition"] = "Condición"
L["Condition Script"] = "Script de condición"
L["Lua code using the WoW UI API.\nShould return \"true\" if and only if the situation should be active."] = "Código Lua usando la API de interfaz de WoW.\nDebe devolver «true» si y solo si la situación debe estar activa."
L["Your \"Condition Script\" deviates from the stock setting for this situation. Click here to restore it."] = "Tu «Script de condición» difiere del ajuste original para esta situación. Haz clic aquí para restaurarlo."
L["<condition_desc>"] = [[El script de condición de una situación se ejecuta cada vez que se activa un evento del juego de esta situación. El script debe devolver «true» si y solo si esta situación debe estar activa.

Por ejemplo, el script de condición de la situación «Ciudad» usa la función de la API de WoW «IsResting()» para comprobar si estás actualmente en una zona de descanso:

  return IsResting()

Del mismo modo, el script de condición de la situación «Ciudad (interiores)» también usa la función de la API de WoW «IsIndoors()» para comprobar si estás en interiores:

  return IsResting() and IsIndoors()

Puedes encontrar una lista de funciones de la API de WoW aquí:
https://warcraft.wiki.gg/wiki/World_of_Warcraft_API

]]
L["Entering"] = "Entrada"
L["On-Enter Script"] = "Script de entrada"
L["Your \"On-Enter Script\" deviates from the stock setting for this situation. Click here to restore it."] = "Tu «Script de entrada» difiere del ajuste original para esta situación. Haz clic aquí para restaurarlo."
L["<executeOnEnter_desc>"] = [[El script de entrada de una situación se ejecuta cada vez que se entra en la situación.

Hasta ahora, el único ejemplo de esto es la situación «Piedra de hogar/Teletransporte» en la que usamos la función de la API de WoW «UnitCastingInfo()» para determinar la duración del lanzamiento del hechizo actual. Luego asignamos esto a las variables «this.timeToEnter» y «this.timeToEnter», de modo que un zoom o rotación (ver «Acciones de situación») pueda durar exactamente tanto como el lanzamiento del hechizo. (No todos los hechizos de teletransporte tienen los mismos tiempos de lanzamiento).

]]
L["Exiting"] = "Salida"
L["On-Exit Script"] = "Script de salida"
L["Your \"On-Exit Script\" deviates from the stock setting for this situation. Click here to restore it."] = "Tu «Script de salida» difiere del ajuste original para esta situación. Haz clic aquí para restaurarlo."
L["Exit Delay"] = "Retraso de salida"
L["Wait for this many seconds before exiting this situation."] = "Esperar esta cantidad de segundos antes de salir de esta situación."
L["Your \"Exit Delay\" deviates from the stock setting for this situation. Click here to restore it."] = "Tu «Retraso de salida» difiere del ajuste original para esta situación. Haz clic aquí para restaurarlo."
L["<executeOnExit_desc>"] = [[El script de salida de una situación se ejecuta cada vez que se sale de la situación. Hasta ahora, ninguna situación utiliza esto.

El retraso determina cuántos segundos esperar antes de salir de la situación. Hasta ahora, el único ejemplo de esto es la situación «Pesca», donde el retraso te da tiempo para volver a lanzar tu caña de pescar sin salir de la situación.

]]
L["Export"] = "Exportar"
L["Coming soon(TM)."] = "Próximamente(TM)."
L["Import"] = "Importar"
L["Restore all stock Situation Controls"] = "Restaurar todos los Controles de situación originales"


--------------------------------------------------------------------------------
-- About / Profiles
--------------------------------------------------------------------------------
L["Hello and welcome to DynamicCam!"] = "¡Hola y bienvenido a DynamicCam!"
L["<welcomeMessage>"] = [[Nos alegra que estés aquí y esperamos que te diviertas con el addon.

DynamicCam (DC) fue iniciado en mayo de 2016 por mpstark cuando los desarrolladores de WoW en Blizzard introdujeron las características experimentales de ActionCam en el juego. El propósito principal de DC ha sido proporcionar una interfaz de usuario para los ajustes de ActionCam. Dentro del juego, ActionCam todavía se designa como «experimental» y no ha habido señales de Blizzard para desarrollarlo más. Hay algunas deficiencias, pero deberíamos estar agradecidos de que ActionCam se dejara en el juego para entusiastas como nosotros. :-) DC no solo te permite cambiar los ajustes de ActionCam, sino tener diferentes ajustes para diferentes situaciones de juego. No relacionado con ActionCam, DC también proporciona características con respecto al zoom de la cámara y el desvanecimiento de la interfaz.

El trabajo de mpstark en DC continuó hasta agosto de 2018. Si bien la mayoría de las características funcionaban bien para una base de usuarios sustancial, mpstark siempre había considerado que DC estaba en estado beta y debido a su decreciente interés en WoW terminó no reanudando su trabajo. En ese momento, Ludius ya había comenzado a hacer ajustes a DC para sí mismo, lo cual fue notado por Weston (alias dernPerkins) quien a principios de 2020 logró ponerse en contacto con mpstark, lo que llevó a Ludius a hacerse cargo del desarrollo. La primera versión no beta 1.0 se lanzó en mayo de 2020 incluyendo los ajustes de Ludius hasta ese punto. Posteriormente, Ludius comenzó a trabajar en una revisión de DC que resultó en el lanzamiento de la versión 2.0 en otoño de 2022.

Cuando mpstark comenzó DC, su enfoque estaba en hacer la mayoría de las personalizaciones en el juego en lugar de tener que cambiar el código fuente. Esto hizo más fácil experimentar, particularmente con las diferentes situaciones de juego. A partir de la versión 2.0, estos ajustes avanzados se han movido a una sección especial llamada «Controles de situación». La mayoría de los usuarios probablemente nunca la necesitarán, pero para los «usuarios avanzados» todavía está disponible. Un riesgo de hacer cambios allí es que los ajustes de usuario guardados siempre anulan los ajustes originales de DC, incluso si las nuevas versiones de DC traen ajustes originales actualizados. Por lo tanto, se muestra una advertencia en la parte superior de esta página siempre que tengas situaciones originales con «Controles de situación» modificados.

Si crees que una de las situaciones originales de DC debería cambiarse, siempre puedes crear una copia de ella con tus cambios. Siéntete libre de exportar esta nueva situación y publicarla en la página de CurseForge de DC. Entonces podemos añadirla como una nueva situación original propia. También eres bienvenido a exportar y publicar tu perfil completo de DC, ya que siempre estamos buscando nuevos preajustes de perfil que permitan a los recién llegados una entrada más fácil a DC. Si encuentras un problema o quieres hacer una sugerencia, simplemente deja una nota en los comentarios de CurseForge o incluso mejor usa los Issues en GitHub. Si quieres contribuir, también siéntete libre de abrir un pull request allí.

Aquí hay algunos comandos de barra prácticos:

    `/dynamiccam` o `/dc` abre este menú.
    `/zoominfo` o `/zi` imprime el nivel de zoom actual.

    `/zoom #1 #2` hace zoom al nivel #1 en #2 segundos.
    `/yaw #1 #2` gira la cámara #1 grados en #2 segundos (#1 negativo para girar a la derecha).
    `/pitch #1 #2` inclina la cámara #1 grados (#1 negativo para inclinar hacia arriba).


]]
L["About"] = "Acerca de"
L["The following game situations have \"Situation Controls\" deviating from DynamicCam's stock settings.\n\n"] = "Las siguientes situaciones de juego tienen «Controles de situación» que difieren de los ajustes originales de DynamicCam.\n\n"
L["<situationControlsWarning>"] = "\nSi haces esto a propósito, está bien. Solo ten en cuenta que cualquier actualización de estos ajustes por parte de los desarrolladores de DynamicCam siempre será anulada por tu versión modificada (posiblemente desactualizada). Puedes consultar la pestaña «Controles de situación» de cada situación para más detalles. Si no eres consciente de ninguna modificación de «Controles de situación» por tu parte y simplemente quieres restaurar los ajustes de control originales para *todas* las situaciones, pulsa este botón:"
L["Profiles"] = "Perfiles"
L["Manage Profiles"] = "Gestionar perfiles"
L["<manageProfilesWarning>"] = "Like many addons, DynamicCam uses the \"AceDB-3.0\" library to manage profiles. What you have to understand is that there is nothing like \"Save Profile\" here. You can only create new profiles and you can copy settings from another profile into the currently active one. Whatever change you make for the currently active profile is immediately saved! There is nothing like \"cancel\" or \"discard changes\". The \"Reset Profile\" button only resets to the global default profile.\n\nSo if you like your DynamicCam settings, you should create another profile into which you copy these settings as a backup. When you don't use this backup profile as your active profile, you can experiment with the settings and return to your original profile at any time by selecting your backup profile in the \"Copy from\" box.\n\nIf you want to switch profiles via macro, you can use the following:\n/run DynamicCam.db:SetProfile(\"Profile name here\")\n\n"
L["Profile presets"] = "Preajustes de perfil"
L["Import / Export"] = "Importar / Exportar"


--------------------------------------------------------------------------------
-- MouseZoom.lua
--------------------------------------------------------------------------------
L["Current\nZoom\nValue"] = "Valor de\nZoom\nActual"
L["Reactive\nZoom\nTarget"] = "Objetivo de\nZoom\nReactivo"
L["Reactive Zoom"] = "Zoom reactivo"
L["This graph helps you to\nunderstand how\nReactive Zoom works."] = "Este gráfico te ayuda\na entender cómo\nfunciona el Zoom Reactivo."


--------------------------------------------------------------------------------
-- ZoomBasedSettings.lua
--------------------------------------------------------------------------------
L["DynamicCam: Zoom-Based Setting"] = "DynamicCam: Ajuste basado en Zoom"
L["CVAR: "] = "CVAR: "
L["Z\no\no\nm"] = "Z\no\no\nm"
L["Value"] = "Valor"
L["Current Zoom:"] = "Zoom actual:"
L["Current Value:"] = "Valor actual:"
L["Left-click: add/drag point | Right-click: remove point"] = "Clic izq: añadir/arrastrar | Clic dcho: quitar punto"
L["Cancel"] = "Cancelar"
L["OK"] = "Aceptar"
L["Close and revert all changes made since opening this editor."] = "Cerrar y revertir todos los cambios realizados."
L["Close and keep all changes."] = "Cerrar y guardar todos los cambios."
L["Zoom-based"] = "Basado en Zoom"
L["Edit Curve"] = "Editar curva"
L["Enable zoom-based curve for this setting.\n\nWhen enabled, the value will change smoothly based on your camera zoom level instead of using a single fixed value. Click the gear icon to edit the curve."] = "Habilitar curva basada en zoom.\n\nCuando está habilitado, el valor cambiará suavemente según el nivel de zoom de la cámara en lugar de usar un valor fijo. Haz clic en el engranaje para editar la curva."
L["Open the curve editor.\n\nAllows you to define exactly how this setting changes as you zoom in and out. You can add control points to create a custom curve."] = "Abrir el editor de curvas.\n\nPermite definir exactamente cómo cambia esta configuración al hacer zoom. Puedes agregar puntos de control para crear una curva personalizada."


--------------------------------------------------------------------------------
-- Core.lua
--------------------------------------------------------------------------------
L["Enter name for custom situation:"] = "Introduce nombre para situación personalizada:"
L["Create"] = "Crear"
L["While you are using horizontal camera offset, DynamicCam prevents CameraKeepCharacterCentered!"] = "¡Mientras usas el desplazamiento de cámara horizontal, DynamicCam impide CameraKeepCharacterCentered!"
L["While you are using horizontal camera offset, DynamicCam prevents CameraReduceUnexpectedMovement!"] = "¡Mientras usas el desplazamiento de cámara horizontal, DynamicCam impide CameraReduceUnexpectedMovement!"
L["While you are using vertical camera pitch, DynamicCam prevents CameraKeepCharacterCentered!"] = "¡Mientras usas la inclinación vertical de cámara, DynamicCam impide CameraKeepCharacterCentered!"


--------------------------------------------------------------------------------
-- CvarMonitor.lua
--------------------------------------------------------------------------------
L["Disabled"] = "Desactivado"
L["Attention"] = "Atención"
L["Your DynamicCam addon lets you adjust horizontal and vertical mouse look speed individually! Just go to the \"Mouse Look\" settings of DynamicCam to make the adjustments there."] = "¡Tu addon DynamicCam te permite ajustar la velocidad de giro de cámara con ratón horizontal y vertical individualmente! Simplemente ve a los ajustes de «Giro de cámara con ratón» de DynamicCam para hacer los ajustes allí."
L["The \"%s\" setting is disabled by DynamicCam, while you are using the horizontal camera over shoulder offset."] = "El ajuste «%s» está desactivado por DynamicCam, mientras usas el desplazamiento de la cámara por encima del hombro horizontal."
L["cameraView=%s prevented by DynamicCam!"] = "¡cameraView=%s impedido por DynamicCam!"


--------------------------------------------------------------------------------
-- DefaultSettings.lua - Situation Names
--------------------------------------------------------------------------------
L["City"] = "Ciudad"
L["City (Indoors)"] = "Ciudad (Interiores)"
L["World"] = "Mundo"
L["World (Indoors)"] = "Mundo (Interiores)"
L["World (Combat)"] = "Mundo (Combate)"
L["Dungeon/Scenario"] = "Mazmorra/Gesta"
L["Dungeon/Scenario (Outdoors)"] = "Mazmorra/Gesta (Exterior)"
L["Dungeon/Scenario (Combat, Boss)"] = "Mazmorra/Gesta (Combate, Jefe)"
L["Dungeon/Scenario (Combat, Trash)"] = "Mazmorra/Gesta (Combate, Basura)"
L["Raid"] = "Banda"
L["Raid (Outdoors)"] = "Banda (Exterior)"
L["Raid (Combat, Boss)"] = "Banda (Combate, Jefe)"
L["Raid (Combat, Trash)"] = "Banda (Combate, Basura)"
L["Arena"] = "Arena"
L["Arena (Combat)"] = "Arena (Combate)"
L["Battleground"] = "Campo de batalla"
L["Battleground (Combat)"] = "Campo de batalla (Combate)"
L["Mounted (any)"] = "Montura (cualquiera)"
L["Mounted (only flying-mount)"] = "Montura (solo voladora)"
L["Mounted (only flying-mount + airborne)"] = "Montura (solo voladora + en el aire)"
L["Mounted (only flying-mount + airborne + Skyriding)"] = "Montura (solo voladora + en el aire + Cielonáutica)"
L["Mounted (only flying-mount + Skyriding)"] = "Montura (solo voladora + Cielonáutica)"
L["Mounted (only airborne)"] = "Montura (solo en el aire)"
L["Mounted (only airborne + Skyriding)"] = "Montura (solo en el aire + Cielonáutica)"
L["Mounted (only Skyriding)"] = "Montura (solo Cielonáutica)"
L["Druid Travel Form"] = "Forma de viaje de druida"
L["Dracthyr Soar"] = "Dracthyr Elevarse"
L["Skyriding Race"] = "Carrera de Cielonáutica"
L["Taxi"] = "Taxi"
L["Vehicle"] = "Vehículo"
L["Hearth/Teleport"] = "Piedra de hogar/Teletransporte"
L["Annoying Spells"] = "Hechizos molestos"
L["NPC Interaction"] = "Interacción con PNJ"
L["Mailbox"] = "Buzón"
L["Fishing"] = "Pesca"
L["Gathering"] = "Recolección"
L["AFK"] = "Ausente (AFK)"
L["Pet Battle"] = "Duelo de mascotas"
L["Professions Frame Open"] = "Ventana de profesión abierta"
