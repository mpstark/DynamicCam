local L = LibStub("AceLocale-3.0"):NewLocale("DynamicCam", "ruRU") if not L then return end


--------------------------------------------------------------------------------
-- General UI Elements
--------------------------------------------------------------------------------
L["Reset"] = "Сброс"
L["Reset to global default"] = "Сбросить на глобальные настройки по умолчанию"
L["(To restore the settings of a specific profile, restore the profile in the \"Profiles\" tab.)"] = "(Чтобы восстановить настройки конкретного профиля, восстановите профиль во вкладке \\\"Профили\\\".)"
L["Standard Settings"] = "Стандартные настройки"
L["<standardSettings_desc>"] = "Эти стандартные настройки применяются, когда ни одна ситуация не активна или когда активная ситуация не имеет настроек, переопределяющих стандартные."
L["<standardSettingsOverridden_desc>"] = "Категории, отмеченные зелёным, в настоящее время переопределяются активной ситуацией. Поэтому изменение стандартных настроек зелёных категорий не будет иметь эффекта, пока активна переопределяющая ситуация."
L["Currently overridden by the active situation \"%s\"."] = "В настоящее время переопределяется активной ситуацией \\\"%s\\\"."
L["Help"] = "Помощь"
L["WARNING"] = "ПРЕДУПРЕЖДЕНИЕ"
L["Error message:"] = "Сообщение об ошибке:"
L["DynamicCam"] = "DynamicCam"


--------------------------------------------------------------------------------
-- Common Controls (Used Across Multiple Sections)
--------------------------------------------------------------------------------
L["Override Standard Settings"] = "Переопределить стандартные настройки"
L["<overrideStandardToggle_desc>"] = "Установка этого флажка позволяет определять настройки в этой категории, которые переопределяют стандартные настройки, когда эта ситуация активна. Снятие флажка удаляет настройки ситуации для этой категории."
L["Situation Settings"] = "Настройки ситуации"
L["These Situation Settings override the Standard Settings when the respective situation is active."] = "Эти настройки ситуации переопределяют стандартные настройки, когда соответствующая ситуация активна."
L["Enable"] = "Включить"


--------------------------------------------------------------------------------
-- Options - Mouse Zoom
--------------------------------------------------------------------------------
L["Mouse Zoom"] = "Зум мышью"
L["Maximum Camera Distance"] = "Максимальное расстояние камеры"
L["How many yards the camera can zoom away from your character."] = "На сколько ярдов камера может отдаляться от вашего персонажа."
L["Camera Zoom Speed"] = "Скорость зума камеры"
L["How fast the camera can zoom."] = "Как быстро камера может изменять масштаб."
L["Zoom Increments"] = "Шаги зума"
L["How many yards the camera should travel for each \"tick\" of the mouse wheel."] = "На сколько ярдов камера должна перемещаться за каждый \\\"тик\\\" колеса мыши."
L["Use Reactive Zoom"] = "Использовать реактивный зум"
L["Quick-Zoom Additional Increments"] = "Дополнительные шаги быстрого зума"
L["How many yards per mouse wheel \"tick\" should be added when quick-zooming."] = "Сколько ярдов за тик колеса мыши добавляется при быстром зуме."
L["Quick-Zoom Enter Threshold"] = "Порог входа в быстрый зум"
L["How many yards the \"Reactive Zoom Target\" and the \"Current Zoom Value\" have to be apart to enter quick-zooming."] = "На сколько ярдов \\\"Цель реактивного зума\\\" и \\\"Фактическое значение зума\\\" должны различаться для входа в быстрый зум."
L["Maximum Zoom Time"] = "Максимальное время зума"
L["The maximum time the camera should take to make \"Current Zoom Value\" equal to \"Reactive Zoom Target\"."] = "Максимальное время, за которое камера должна сделать \\\"Текущее значение зума\\\" равным \\\"Цели реактивного зума\\\"."
L["Toggle Visual Aid"] = "Переключить визуальную помощь"
L["<reactiveZoom_desc>"] = "With DynamicCam's Reactive Zoom the mouse wheel controls the so called \"Reactive Zoom Target\". Whenever the \"Reactive Zoom Target\" and the \"Current Zoom Value\" are different, DynamicCam changes the \"Current Zoom Value\" until it matches the \"Reactive Zoom Target\" again.\n\nHow fast this zoom change is happening depends on \"Camera Zoom Speed\" and \"Maximum Zoom Time\". If \"Maximum Zoom Time\" is set low, the zoom change will always be executed fast, regardless of the \"Camera Zoom Speed\" setting. To achieve a slower zoom change, you must set \"Maximum Zoom Time\" to a higher value and \"Camera Zoom Speed\" to a lower value.\n\nTo enable faster zooming with faster mouse wheel movement, there is \"Quick-Zoom\": if the \"Reactive Zoom Target\" is further away from the \"Current Zoom Value\" than the \"Quick-Zoom Enter Threshold\", the amount of \"Quick-Zoom Additional Increments\" is added to every mouse wheel tick.\n\nTo get a feeling of how this works, you can toggle the visual aid while finding your ideal settings. You can also freely move this graph by left-clicking and dragging it. A right-click closes it."
L["Enhanced minimal zoom-in"] = "Улучшенный минимальный зум"
L["<enhancedMinZoom_desc>"] = "Реактивный зум позволяет увеличивать масштаб ближе, чем уровень 1. Это достигается путём отдаления на один тик колеса мыши от вида от первого лица.\n\nС включённым \\\"Улучшенным минимальным зумом\\\" камера также останавливается на этом минимальном уровне зума при увеличении, прежде чем перейти в вид от первого лица.\n\n|cFFFF0000Включение \\\"Улучшенного минимального зума\\\" может снизить FPS до 15% в ситуациях, ограниченных производительностью процессора.|r"
L["/reload of the UI required!"] = "Требуется перезагрузка интерфейса!"


--------------------------------------------------------------------------------
-- Options - Mouse Look
--------------------------------------------------------------------------------
L["Mouse Look"] = "Поворот камеры"
L["Horizontal Speed"] = "Горизонтальная скорость"
L["How much the camera yaws horizontally when in mouse look mode."] = "Как сильно камера поворачивается по горизонтали в режиме поворота камеры."
L["Vertical Speed"] = "Вертикальная скорость"
L["How much the camera pitches vertically when in mouse look mode."] = "Как сильно камера наклоняется по вертикали в режиме поворота камеры."
L["<mouseLook_desc>"] = "Как сильно камера движется, когда вы двигаете мышь в режиме «поворота камеры»; т.е. когда нажата левая или правая кнопка мыши.\n\nПолзунок «Скорость поворота» в стандартных настройках интерфейса WoW управляет горизонтальной и вертикальной скоростью одновременно: автоматически устанавливая горизонтальную скорость в 2 раза выше вертикальной. DynamicCam переопределяет это и позволяет вам выполнить более точную настройку."


--------------------------------------------------------------------------------
-- Options - Horizontal Offset
--------------------------------------------------------------------------------
L["Horizontal Offset"] = "Горизонтальное смещение"
L["Camera Over Shoulder Offset"] = "Смещение камеры от плеча"
L["Positions the camera left or right from your character."] = "Располагает камеру слева или справа от вашего персонажа."
L["<cameraOverShoulder_desc>"] = "Для вступления этого в силу DynamicCam автоматически временно отключает настройку Укачивание WoW. Поэтому, если вам нужна настройка Укачивание, не используйте горизонтальное смещение в этих ситуациях.\n\nКогда вы выбираете в цель своего персонажа, WoW автоматически центрирует камеру. Мы ничего не можем с этим поделать. Мы также не можем ничего поделать с рывками смещения, которые могут возникнуть при столкновении камеры со стеной. Обходной путь — использовать минимальное смещение или не использовать его вообще внутри зданий.\n\nКроме того, WoW странно применяет смещение по-разному в зависимости от модели персонажа или средства передвижения. Для всех, кто предпочитает постоянное смещение, Ludius работает над другим аддоном («CameraOverShoulder Fix»), чтобы решить эту проблему."


--------------------------------------------------------------------------------
-- Options - Vertical Pitch
--------------------------------------------------------------------------------
L["Vertical Pitch"] = "Вертикальный наклон"
L["Pitch (on ground)"] = "Наклон (на земле)"
L["Pitch (flying)"] = "Наклон (в полёте)"
L["Down Scale"] = "Уменьшение масштаба"
L["Smart Pivot Cutoff Distance"] = "Умная дистанция отключения поворота"
L["<pitch_desc>"] = "If the camera is pitched upwards (lower \"Pitch\" value), the \"Down Scale\" setting determines how much this comes into effect while looking at your character from above. Setting \"Down Scale\" to 0 nullifies the effect of an upwards pitch while looking from above. On the contrary, while you are not looking from above or if the camera is pitched downwards (greater \"Pitch\" value), the \"Down Scale\" setting has little to no effect.\n\nThus, you should first find your preferred \"Pitch\" setting while looking at your character from behind. Afterwards, if you have chosen an upwards pitch, find your preferred \"Down Scale\" setting while looking from above.\n\n\nWhen the camera collides with the ground, it normally performs an upwards pitch on the spot of the camera-to-ground collision. An alternative is that the camera moves closer to your character's feet while performing this pitch. The \"Smart Pivot Cutoff Distance\" setting determines the distance that the camera has to be inside of to do the latter. Setting it to 0 never moves the camera closer (WoW's default), whereas setting it to the maximum zoom distance of 39 always moves the camera closer.\n\n"


--------------------------------------------------------------------------------
-- Options - Target Focus
--------------------------------------------------------------------------------
L["Target Focus"] = "Фокус на цели"
L["Enemy Target"] = "Вражеская цель"
L["Horizontal Strength"] = "Горизонтальная интенсивность"
L["Vertical Strength"] = "Вертикальная интенсивность"
L["Interaction Target (NPCs)"] = "Цель взаимодействия (НПС)"
L["<targetFocus_desc>"] = "Если включено, камера автоматически пытается приблизить цель к центру экрана. Интенсивность определяет силу этого эффекта.\n\nЕсли включены и \\\"Вражеская цель\\\", и \\\"Цель взаимодействия\\\", с последним возникает странный баг: при первом взаимодействии с НПС камера плавно перемещается к новому углу, как ожидалось. Но при выходе из взаимодействия она мгновенно возвращается к предыдущему углу. При повторном взаимодействии она снова мгновенно переходит к новому углу. Это повторяется при каждом взаимодействии с новым НПС: только первый переход плавный, все последующие — мгновенные.\nОбходной путь, если вы хотите использовать оба фокуса, — активировать \\\"Вражеская цель\\\" только для ситуаций DynamicCam, где он нужен и где взаимодействие с НПС маловероятно (например, в бою)."


--------------------------------------------------------------------------------
-- Options - Head Tracking
--------------------------------------------------------------------------------
L["Head Tracking"] = "Отслеживание головы"
L["<headTrackingEnable_desc>"] = "(Это также можно использовать как непрерывное значение от 0 до 1, но оно просто умножается на «Интенсивность (стоя)» и «Интенсивность (в движении)» соответственно. Поэтому нет необходимости в дополнительном ползунке.)"
L["Strength (standing)"] = "Интенсивность (стоя)"
L["Inertia (standing)"] = "Инерция (стоя)"
L["Strength (moving)"] = "Интенсивность (в движении)"
L["Inertia (moving)"] = "Инерция (в движении)"
L["Inertia (first person)"] = "Инерция (от первого лица)"
L["Range Scale"] = "Масштаб дальности"
L["Camera distance beyond which head tracking is reduced or disabled. (See explanation below.)"] = "Расстояние камеры, за которым отслеживание головы уменьшается или отключается. (См. объяснение ниже.)"
L["(slider value transformed)"] = "(значение ползунка преобразовано)"
L["Dead Zone"] = "Мёртвая зона"
L["Radius of head movement not affecting the camera. (See explanation below.)"] = "Радиус движения головы, не влияющий на камеру. (См. объяснение ниже.)"
L["(slider value devided by 10)"] = "(значение ползунка, делённое на 10)"
L["Requires /reload to come into effect!"] = "Требуется перезагрузка интерфейса для вступления в силу!"
L["<headTracking_desc>"] = "With head tracking enabled the camera follows the movement of your character's head. (While this can be a benefit for immersion, it may also cause nausea if you are prone to motion sickness.)\n\nThe \"Strength\" setting determines the intensity of this effect. Setting it to 0 disables head tracking. The \"Inertia\" setting determines how fast the camera reacts to head movements. Setting it to 0 also disables head tracking. The three cases \"standing\", \"moving\" and \"first person\" can be set up individually. There is no \"Strength\" setting for \"first person\" as it assumes the \"Strength\" settings of \"standing\" and \"moving\" respectively. If you want to enable or disable \"first person\" exclusively, use the \"Inertia\" sliders to disable the unwanted cases.\n\nWith the \"Range Scale\" setting you can set the camera distance beyond which head tracking is reduced or disabled. For example, with the slider set to 30 you will have no head tracking when the camera is more than 30 yards away from your character. However, there is a gradual transition from full head tracking to no head tracking, which starts at one third of the slider value. For example, with the slider value set to 30 you have full head tracking when the camera is closer than 10 yards. Beyond 10 yards, head tracking gradually decreases until it is completely gone beyond 30 yards. Hence, the slider's maximum value is 117 allowing for full head tracking at the maximum camera distance of 39 yards. (Hint: Use DynamicCam's \"Mouse Zoom\" visual aid to track the current camera distance while setting this up.)\n\nThe \"Dead Zone\" setting can be used to ignore smaller head movements. Setting it to 0 has the camera follow every slightest head movement, whereas setting it to a greater value results in it following only greater movements. Notice, that changing this setting only comes into effect after reloading the UI (type /reload into the console)."


--------------------------------------------------------------------------------
-- Situations Tab
--------------------------------------------------------------------------------
L["Situations"] = "Ситуации"
L["Select a situation to setup"] = "Выберите ситуацию для настройки"
L["<selectedSituation_desc>"] = "\n|cffffcc00Colour codes:|r\n|cFF808A87- Disabled situation.|r\n- Enabled situation.\n|cFF00FF00- Enabled and currently active situation.|r\n|cFF63B8FF- Enabled situation with fulfilled condition but lower priority than the currently active situation.|r\n|cFFFF6600- Modified stock \"Situation Controls\" (reset recommended).|r\n|cFFEE0000- Erroneous \"Situation Controls\" (fixing required).|r"
L["If this box is checked, DynamicCam will enter the situation \"%s\" whenever its condition is fulfilled and no other situation with higher priority is active."] = "Если этот флажок установлен, DynamicCam войдёт в ситуацию «%s», когда её условие выполнено и нет других активных ситуаций с более высоким приоритетом."
L["Custom:"] = "Пользовательские:"
L["(modified)"] = "(изменено)"
L["Delete custom situation \"%s\".\n|cFFEE0000Attention: There will be no 'Are you sure?' prompt!|r"] = "Удалить пользовательскую ситуацию «%s».\n|cFFEE0000Внимание: Без запроса «Вы уверены?»!|r"
L["Create a new custom situation."] = "Создать новую пользовательскую ситуацию."


--------------------------------------------------------------------------------
-- Situation Actions - General
--------------------------------------------------------------------------------
L["Situation Actions"] = "Действия ситуации"
L["Setup stuff to happen while in a situation or when entering/exiting it."] = "Настроить действия, выполняющиеся во время ситуации или при входе/выходе из неё."
L["Transition Time"] = "Время перехода"
L["Enter Transition Time"] = "Время перехода (Вход)"
L["The time in seconds for the transition when ENTERING this situation."] = "Время в секундах для перехода при ВХОДЕ в эту ситуацию."
L["Exit Transition Time"] = "Время перехода (Выход)"
L["The time in seconds for the transition when EXITING this situation."] = "Время в секундах для перехода при ВЫХОДЕ из этой ситуации."
L["<transitionTime_desc>"] = [[Эти значения времени перехода управляют длительностью переключения между ситуациями.

При входе в ситуацию «Время перехода (Вход)» используется для:
  • Переходов масштаба (если включено «Масштаб/Вид» и НЕ восстанавливается сохраненный масштаб)
  • Вращения камеры (если включено «Вращение»)
    - Для «Непрерывного» вращения: время разгона до скорости вращения
    - Для вращения «По градусам»: время завершения вращения
  • Скрытия интерфейса (если включено «Скрыть интерфейс»)

При выходе из ситуации «Время перехода (Выход)» используется для:
  • Восстановления масштаба (при возврате к сохраненному масштабу из настроек «Восстановить масштаб»)
  • Выхода из вращения камеры (если включено «Вращение»)
    - Для «Непрерывного» вращения: время замедления от скорости вращения до остановки
    - Для вращения «По градусам» с «Вращать обратно»: время обратного вращения
  • Вращения камеры обратно (если включено «Вращать обратно»)
  • Показа интерфейса (если было активно «Скрыть интерфейс»)

ВАЖНО: При переходе непосредственно от одной ситуации к другой время входа НОВОЙ ситуации имеет приоритет над временем выхода старой ситуации для большинства функций. Однако, если восстанавливается масштаб, используется время выхода СТАРОЙ ситуации.

Примечание: Если вы зададите время перехода в сценарии входа с помощью «this.timeToEnter», эти настройки будут переопределены.]]


--------------------------------------------------------------------------------
-- Situation Actions - Zoom/View
--------------------------------------------------------------------------------
L["Zoom/View"] = "Зум/Вид"
L["Zoom to a certain zoom level or switch to a saved camera view when entering this situation."] = "Установить определённый уровень зума или переключиться на сохранённый вид камеры при входе в эту ситуацию."
L["Set Zoom or Set View"] = "Установить зум или вид"
L["Zoom Type"] = "Тип зума"
L["<viewZoomType_desc>"] = "Установить зум: Перейти к заданному уровню зума с расширенными параметрами времени перехода и условий зума.\n\nУстановить вид: Переключиться на сохранённый вид камеры, включающий фиксированный уровень зума и угол камеры."
L["Set Zoom"] = "Установить зум"
L["Set View"] = "Установить вид"
L["Set view to saved view:"] = "Установить вид на сохранённый вид:"
L["Select the saved view to switch to when entering this situation."] = "Выберите сохранённый вид для переключения при входе в эту ситуацию."
L["Instant"] = "Мгновенно"
L["Make view transitions instant."] = "Сделать переходы вида мгновенными."
L["Restore view when exiting"] = "Восстановить вид при выходе"
L["When exiting the situation restore the camera position to what it was at the time of entering the situation."] = "При выходе из ситуации восстановить положение камеры, которое было на момент входа в ситуацию."
L["cameraSmoothNote"] = [[|cFFEE0000Внимание:|r Вы используете настройку «Следование камеры» WoW, которая автоматически размещает камеру за игроком. Это не работает, если вы используете настроенный сохранённый вид. Можно использовать настроенные виды для ситуаций, где следование камеры не требуется (например, взаимодействие с НПС). Но после выхода из ситуации нужно вернуться к ненастроенному виду по умолчанию, чтобы следование камеры снова работало.]]
L["Restore to default view:"] = "Восстановить вид по умолчанию:"
L["<viewRestoreToDefault_desc>"] = [[Выберите вид по умолчанию для возврата при выходе из этой ситуации.

Вид 1:   Зум 0, Наклон 0
Вид 2:   Зум 5.5, Наклон 10
Вид 3:   Зум 5.5, Наклон 20
Вид 4:   Зум 13.8, Наклон 30
Вид 5:   Зум 13.8, Наклон 10]]
L["You are using the same view as saved view and as restore-to-default view. Using a view as restore-to-default view will reset it. Only do this if you really want to use it as a non-customized saved view."] = "Ваш сохранённый вид для установки совпадает с видом для восстановления по умолчанию. Использование вида для восстановления по умолчанию сбросит его. Делайте это, только если действительно хотите использовать его как ненастроенный сохранённый вид."
L["View %s is used as saved view in the situations:\n%sand as restore-to-default view in the situations:\n%s"] = "Вид %s используется как сохранённый вид в ситуациях:\n%sи как вид для восстановления по умолчанию в ситуациях:\n%s"
L["<view_desc>"] = [[WoW позволяет сохранять до 5 пользовательских видов камеры. Вид 1 используется DynamicCam для сохранения положения камеры при входе в ситуацию, чтобы его можно было восстановить при выходе из ситуации, если установлен флажок «Восстановить» выше. Это особенно удобно для краткосрочных ситуаций, таких как взаимодействие с НПС, позволяя переключаться на один вид во время разговора с НПС и затем возвращаться к предыдущему положению камеры. Поэтому Вид 1 нельзя выбрать в выпадающем меню сохранённых видов выше.

Виды 2, 3, 4 и 5 могут использоваться для сохранения пользовательских положений камеры. Чтобы сохранить вид, просто установите камеру на желаемый зум и угол. Затем введите следующую команду в консоль (где # — номер вида 2, 3, 4 или 5):

  /saveView #

Или короче:

  /sv #

Обратите внимание, что сохранённые виды хранятся в WoW. DynamicCam только сохраняет, какие номера видов использовать. Поэтому при импорте нового профиля ситуаций DynamicCam с видами, вам, вероятно, придётся установить и сохранить соответствующие виды после этого.


DynamicCam также предоставляет консольную команду для переключения на вид независимо от входа или выхода из ситуаций:

  /setView #

Чтобы сделать переход вида мгновенным, добавьте «i» после номера вида. Например, чтобы мгновенно переключиться на сохранённый Вид 3, введите:

  /setView 3 i

]]
L["<zoomType_desc>"] = "\nSet: Always set the zoom to this value.\n\nOut: Only set the zoom, if the camera is currently closer than this.\n\nIn: Only set the zoom, if the camera is currently further away than this.\n\nRange: Zoom in, if further away than the given maximum. Zoom out, if closer than the given minimum. Do nothing, if the current zoom is within the [min, max] range."
L["Set"] = "Установить"
L["Out"] = "Наружу"
L["In"] = "Внутрь"
L["Range"] = "Диапазон"
L["Don't slow"] = "Не замедлять"
L["Zoom transitions may be executed faster (but never slower) than the specified time above, if the \"Camera Zoom Speed\" (see \"Mouse Zoom\" settings) allows."] = "Переходы зума могут выполняться быстрее (но никогда медленнее), чем указано выше, если это позволяет «Скорость зума камеры» (см. настройки «Зум мышью»)."
L["Zoom Value"] = "Значение зума"
L["Zoom to this zoom level."] = "Установить этот уровень зума."
L["Zoom out to this zoom level, if the current zoom level is less than this."] = "Уменьшить зум до этого уровня, если текущий уровень зума меньше этого."
L["Zoom in to this zoom level, if the current zoom level is greater than this."] = "Увеличить зум до этого уровня, если текущий уровень зума больше этого."
L["Zoom Min"] = "Минимальный зум"
L["Zoom Max"] = "Максимальный зум"
L["Restore Zoom"] = "Восстановить зум"
L["<zoomRestoreSetting_desc>"] = "Когда вы выходите из ситуации (или из состояния, когда ни одна ситуация не активна), текущий уровень зума временно сохраняется, чтобы его можно было восстановить при следующем входе в эту ситуацию. Здесь вы можете выбрать, как это обрабатывается.\n\nЭта настройка глобальна для всех ситуаций."
L["Restore Zoom Mode"] = "Режим восстановления зума"
L["<zoomRestoreSettingSelect_desc>"] = "\nНикогда: При входе в ситуацию применяется фактическая настройка зума (если есть) входящей ситуации. Сохранённый зум не учитывается.\n\nВсегда: При входе в ситуацию используется последний сохранённый зум этой ситуации. Фактическая настройка учитывается только при первом входе в ситуацию после входа в игру.\n\nАдаптивный: Сохранённый зум используется только при определённых обстоятельствах. Например, только при возвращении в ту же ситуацию, из которой вы вышли, или если сохранённый зум соответствует критериям настроек зума «внутрь», «наружу» или «диапазон» ситуации."
L["Never"] = "Никогда"
L["Always"] = "Всегда"
L["Adaptive"] = "Адаптивный"
L["<zoom_desc>"] = [[Чтобы определить текущий уровень зума, вы можете использовать «Визуальную помощь» (переключается в настройках DynamicCam «Зум мышью») или консольную команду:

  /zoomInfo

Или короче:

  /zi]]


--------------------------------------------------------------------------------
-- Situation Actions - Rotation
--------------------------------------------------------------------------------
L["Rotation"] = "Вращение"
L["Start a camera rotation when this situation is active."] = "Начать вращение камеры, когда эта ситуация активна."
L["Rotation Type"] = "Тип вращения"
L["<rotationType_desc>"] = "\nНепрерывно: Камера вращается по горизонтали всё время, пока эта ситуация активна. Рекомендуется только для ситуаций, в которых вы не перемещаете камеру мышью; например, произнесение заклинаний телепорта, такси или АФК. Непрерывное вертикальное вращение невозможно, так как оно останавливается, когда достигается перпендикулярный вид сверху или снизу.\n\nПо градусам: После входа в ситуацию изменяется текущее рыскание камеры (по горизонтали) и/или наклон (по вертикали) на заданное количество градусов."
L["Continuously"] = "Непрерывно"
L["By Degrees"] = "По градусам"
L["Rotation Speed"] = "Скорость вращения"
L["Speed at which to rotate in degrees per second. You can manually enter values between -900 and 900, if you want to get yourself really dizzy..."] = "Скорость вращения в градусах в секунду. Вы можете вручную ввести значения от -900 до 900, если хотите действительно закружить голову..."
L["Yaw (-Left/Right+)"] = "Рыскание (-Влево/Вправо+)"
L["Degrees to yaw (left or right)."] = "Градусы рыскания (влево или вправо)."
L["Pitch (-Down/Up+)"] = "Наклон (-Вниз/Вверх+)"
L["Degrees to pitch (up or down). There is no going beyond the perpendicular upwards or downwards view."] = "Градусы наклона (вверх или вниз). Нельзя выйти за пределы перпендикулярного вида сверху или снизу."
L["Rotate Back"] = "Вращение назад"
L["<rotateBack_desc>"] = "При выходе из ситуации повернуть камеру назад на количество градусов (по модулю 360), на которое она повернулась с момента входа в ситуацию. Это эффективно возвращает вас к положению камеры до входа, если вы не изменяли угол обзора мышью.\n\nЕсли вы входите в новую ситуацию с собственной настройкой вращения, «Вращение назад» выходящей ситуации игнорируется."


--------------------------------------------------------------------------------
-- Situation Actions - Fade Out UI
--------------------------------------------------------------------------------
L["Fade Out UI"] = "Затемнение интерфейса"
L["Fade out or hide (parts of) the UI when this situation is active."] = "Затемнить или скрыть (части) интерфейса, когда эта ситуация активна."
L["Adjust to Immersion"] = "Настройка под Immersion"
L["<adjustToImmersion_desc>"] = "Многие используют аддон Immersion вместе с DynamicCam. Immersion имеет собственные функции скрытия интерфейса, которые активируются во время взаимодействия с НПС. В некоторых случаях скрытие интерфейса DynamicCam переопределяет Immersion. Чтобы этого избежать, настройте желаемые параметры здесь в DynamicCam. Нажмите эту кнопку, чтобы использовать те же времена затухания и появления, что и в Immersion. Для ещё большего количества опций ознакомьтесь с другим аддоном Ludius — «Immersion ExtraFade»."
L["Hide entire UI"] = "Скрыть весь интерфейс"
L["<hideEntireUI_desc>"] = "There is a difference between a \"hidden\" UI and a \"just faded out\" UI: the faded-out UI elements have an opacity of 0 but can still be interacted with. Since DynamicCam 2.0 we are automatically hiding most UI elements if their opacity is 0. Thus, this option of hiding the entire UI after fade out is more of a relic. A reason to still use it may be to avoid unwanted interactions (e.g. mouse-over tooltips) of UI elements DynamicCam is still not hiding properly.\n\nThe opacity of the hidden UI is of course 0, so you cannot choose a different opacity nor can you keep any UI elements visible (except the FPS indicator).\n\nDuring combat we cannot change the hidden status of protected UI elements. Hence, such elements are always set to \"just faded out\" during combat. Notice that the opacity of the Minimap \"blips\" cannot be reduced. Thus, if you try to hide the Minimap, the \"blips\" are always visible during combat.\n\nWhen you check this box for the currently active situation, it will not be applied at once, because this would also hide this settings frame. You have to enter the situation for it to take effect, which is also possible with the situation \"Enable\" checkbox above.\n\nAlso notice that hiding the entire UI cancels Mailbox or NPC interactions. So do not use it for such situations!"
L["Keep FPS indicator"] = "Сохранить индикатор FPS"
L["Do not fade out or hide the FPS indicator (the one you typically toggle with Ctrl + R)."] = "Не затемнять и не скрывать индикатор FPS (тот, который обычно переключается с помощью Ctrl + R)."
L["Fade Opacity"] = "Прозрачность затухания"
L["Fade the UI to this opacity when entering the situation."] = "Затемнить интерфейс до этой прозрачности при входе в ситуацию."
L["Excluded UI elements"] = "Исключённые элементы интерфейса"
L["Keep Alerts"] = "Сохранить уведомления"
L["Still show alert popups from completed achievements, Covenant Renown, etc."] = "Продолжать показывать всплывающие уведомления о завершённых достижениях, известности ковенанта и т.д."
L["Keep Tooltip"] = "Сохранить подсказку"
L["Still show the game tooltip, which appears when you hover your mouse cursor over UI or world elements."] = "Продолжать показывать игровую подсказку, которая появляется при наведении курсора мыши на элементы интерфейса или мира."
L["Keep Minimap"] = "Сохранить миникарту"
L["<keepMinimap_desc>"] = "Не затемнять миникарту.\n\nОбратите внимание, что мы не можем уменьшить прозрачность «блипов» на миникарте. Они могут быть скрыты только вместе со всей миникартой, когда интерфейс затемнён до 0 прозрачности."
L["Keep Chat Box"] = "Сохранить окно чата"
L["Do not fade out the chat box."] = "Не затемнять окно чата."
L["Keep Tracking Bar"] = "Сохранить индикатор опыта/репутации"
L["Do not fade out the tracking bar (XP, AP, reputation)."] = "Не затемнять индикатор опыта/репутации (опыт, артефактная сила, репутация)."
L["Keep Party/Raid"] = "Сохранить группу/рейд"
L["Do not fade out the Party/Raid frame."] = "Не затемнять рамку группы/рейда."
L["Keep Encounter Frame (Skyriding Vigor)"] = "Сохранить рамку встречи (Энергия Небесной езды)"
L["Do not fade out the Encounter Frame, which while skyriding is the Vigor display."] = "Не затемнять рамку встречи, которая во время Небесной езды отображает энергию."
L["Keep additional frames"] = "Сохранить дополнительные рамки"
L["<keepCustomFrames_desc>"] = "Текстовое поле ниже позволяет указать любые рамки, которые вы хотите сохранить во время взаимодействия с НПС.\n\nИспользуйте консольную команду /fstack, чтобы узнать названия рамок.\n\nНапример, вы можете захотеть сохранить иконки баффов рядом с миникартой, чтобы иметь возможность спешиться во время взаимодействия с НПС, нажав соответствующую иконку."
L["Custom frames to keep"] = "Пользовательские рамки для сохранения"
L["Separated by commas."] = "Разделены запятыми."
L["Emergency Fade In"] = "Экстренное появление"
L["Pressing Esc fades the UI back in."] = "Нажатие Esc возвращает интерфейс."
L["<emergencyShow_desc>"] = [[Иногда нужно показать интерфейс даже в ситуациях, где вы обычно хотите, чтобы он был скрыт. В старых версиях DynamicCam интерфейс показывался при нажатии клавиши Esc. Недостаток в том, что интерфейс также показывается, когда Esc используется для других целей, таких как закрытие окон, отмена произнесения заклинаний и т.д. Снятие флажка выше отключает это.

Однако обратите внимание, что таким образом вы можете заблокировать себе доступ к интерфейсу! Лучшая альтернатива клавише Esc — следующие консольные команды, которые показывают или скрывают интерфейс в соответствии с настройками «Затемнения интерфейса» текущей ситуации:

    /showUI
    /hideUI

Для удобной горячей клавиши появления интерфейса поместите /showUI в макрос и назначьте клавишу в файле «bindings-cache.wtf». Например:

    bind ALT+F11 MACRO Имя вашего макроса

Если редактирование файла «bindings-cache.wtf» вас отпугивает, вы можете использовать аддон для привязки клавиш, например «BindPad».

Использование /showUI или /hideUI без аргументов учитывает время затухания или появления текущей ситуации. Но вы также можете указать другое время перехода. Например:

    /showUI 0

чтобы показать интерфейс без задержки.]]
L["<hideUIHelp_desc>"] = "При настройке желаемых эффектов затемнения интерфейса может быть раздражающим, когда эта рамка настроек «Интерфейс» тоже затемняется. Если установлен этот флажок, она не будет затемняться.\n\nЭта настройка глобальна для всех ситуаций."
L["Do not fade out this \"Interface\" settings frame."] = "Не затемнять эту рамку настроек «Интерфейс»."


--------------------------------------------------------------------------------
-- Situation Controls
--------------------------------------------------------------------------------
L["Situation Controls"] = "Управление ситуацией"
L["<situationControls_help>"] = "Здесь вы контролируете, когда ситуация активна. Могут потребоваться знания API интерфейса WoW. Если вы довольны оригинальными ситуациями DynamicCam, просто проигнорируйте этот раздел. Но если вы хотите создать собственные ситуации, вы можете ознакомиться с оригинальными ситуациями здесь. Вы также можете изменить их, но будьте осторожны: ваши изменённые настройки сохранятся, даже если будущие версии DynamicCam представят важные обновления.\n\n"
L["Priority"] = "Приоритет"
L["The priority of this situation.\nMust be a number."] = "Приоритет этой ситуации.\nДолжен быть числом."
L["Restore stock setting"] = "Восстановить оригинальную настройку"
L["Your \"Priority\" deviates from the stock setting for this situation (%s). Click here to restore it."] = "Ваш «Приоритет» отличается от оригинальной настройки для этой ситуации (%s). Нажмите здесь, чтобы восстановить его."
L["<priority_desc>"] = "Если условия нескольких разных ситуаций DynamicCam выполняются одновременно, активируется ситуация с наивысшим приоритетом. Например, когда выполняется условие «Мир (в помещении)», условие «Мир» также выполняется. Но так как «Мир (в помещении)» имеет более высокий приоритет, чем «Мир», ей отдаётся предпочтение. Вы также можете увидеть приоритеты всех ситуаций в выпадающем меню выше.\n\n"
L["Events"] = "События"
L["Your \"Events\" deviate from the default for this situation. Click here to restore them."] = "Ваши «События» отличаются от оригинальных для этой ситуации. Нажмите здесь, чтобы восстановить их."
L["<events_desc>"] = [[Здесь вы определяете все игровые события, при которых DynamicCam должен проверять условие этой ситуации, чтобы войти или выйти из неё, если это применимо.

Вы можете узнать об игровых событиях, используя Журнал события WoW.
Чтобы открыть его, введите это в консоль:

  /eventtrace

Список всех возможных событий также можно найти здесь:
https://warcraft.wiki.gg/wiki/Events

]]
L["Initialisation"] = "Инициализация"
L["Initialisation Script"] = "Скрипт инициализации"
L["Lua code using the WoW UI API."] = "Код Lua, использующий API интерфейса WoW."
L["Your \"Initialisation Script\" deviates from the stock setting for this situation. Click here to restore it."] = "Ваш «Скрипт инициализации» отличается от оригинальной настройки для этой ситуации. Нажмите здесь, чтобы восстановить его."
L["<initialisation_desc>"] = [[Скрипт инициализации ситуации запускается один раз при загрузке DynamicCam (а также при изменении ситуации). Обычно вы помещаете в него вещи, которые хотите повторно использовать в любом из других скриптов (условие, вход, выход). Это может сделать эти другие скрипты немного короче.

Например, скрипт инициализации ситуации «Камень/Телепорт» определяет таблицу «this.spells», которая включает ID заклинаний телепортации. Скрипт условия затем может просто обращаться к «this.spells» каждый раз при выполнении.

Как и в этом примере, вы можете передавать любой объект данных между скриптами ситуации, помещая его в таблицу «this».

]]
L["Condition"] = "Условие"
L["Condition Script"] = "Скрипт условия"
L["Lua code using the WoW UI API.\nShould return \"true\" if and only if the situation should be active."] = "Код Lua, использующий API интерфейса WoW.\nДолжен возвращать «true» тогда и только тогда, когда ситуация должна быть активна."
L["Your \"Condition Script\" deviates from the stock setting for this situation. Click here to restore it."] = "Ваш «Скрипт условия» отличается от оригинальной настройки для этой ситуации. Нажмите здесь, чтобы восстановить его."
L["<condition_desc>"] = [[Скрипт условия ситуации запускается каждый раз при срабатывании игрового события этой ситуации. Скрипт должен возвращать «true» тогда и только тогда, когда эта ситуация должна быть активна.

Например, скрипт условия ситуации «Город» использует функцию API WoW «IsResting()», чтобы проверить, находитесь ли вы в зоне отдыха:

  return IsResting()

Аналогично, скрипт условия ситуации «Город (в помещении)» также использует функцию API WoW «IsIndoors()», чтобы проверить, находитесь ли вы в помещении:

  return IsResting() and IsIndoors()

Список функций API WoW можно найти здесь:
https://warcraft.wiki.gg/wiki/World_of_Warcraft_API

]]
L["Entering"] = "Вход"
L["On-Enter Script"] = "Скрипт входа"
L["Your \"On-Enter Script\" deviates from the stock setting for this situation. Click here to restore it."] = "Ваш «Скрипт входа» отличается от оригинальной настройки для этой ситуации. Нажмите здесь, чтобы восстановить его."
L["<executeOnEnter_desc>"] = [[Скрипт входа ситуации запускается каждый раз при входе в ситуацию.

Пока что единственный пример этого — ситуация «Камень/Телепорт», в которой мы используем функцию API WoW «UnitCastingInfo()» для определения длительности произнесения текущего заклинания. Затем мы присваиваем это переменным «this.timeToEnter» и «this.timeToEnter», чтобы зум или вращение (см. «Действия ситуации») могли длиться ровно столько же, сколько произнесение заклинания. (Не все заклинания телепортации имеют одинаковое время произнесения.)

]]
L["Exiting"] = "Выход"
L["On-Exit Script"] = "Скрипт выхода"
L["Your \"On-Exit Script\" deviates from the stock setting for this situation. Click here to restore it."] = "Ваш «Скрипт выхода» отличается от оригинальной настройки для этой ситуации. Нажмите здесь, чтобы восстановить его."
L["Exit Delay"] = "Задержка выхода"
L["Wait for this many seconds before exiting this situation."] = "Подождите столько секунд перед выходом из этой ситуации."
L["Your \"Exit Delay\" deviates from the stock setting for this situation. Click here to restore it."] = "Ваша «Задержка выхода» отличается от оригинальной настройки для этой ситуации. Нажмите здесь, чтобы восстановить её."
L["<executeOnExit_desc>"] = [[Скрипт выхода ситуации запускается каждый раз при выходе из ситуации. Пока что ни одна ситуация не использует это.

Задержка определяет, сколько секунд ждать перед выходом из ситуации. Пока что единственный пример этого — ситуация «Рыбалка», где задержка даёт вам время заново забросить удочку, не выходя из ситуации.

]]
L["Export"] = "Экспорт"
L["Coming soon(TM)."] = "Скоро(TM)."
L["Import"] = "Импорт"
L["Restore all stock Situation Controls"] = "Восстановить все оригинальные Управления ситуацией"


--------------------------------------------------------------------------------
-- About / Profiles
--------------------------------------------------------------------------------
L["Hello and welcome to DynamicCam!"] = "Привет и добро пожаловать в DynamicCam!"
L["<welcomeMessage>"] = [[Мы рады, что вы здесь, и надеемся, что вам понравится этот аддон.

DynamicCam (DC) был запущен в мае 2016 года mpstark, когда разработчики WoW из Blizzard внедрили в игру экспериментальные функции ActionCam. Основной целью DC было предоставление пользовательского интерфейса для настроек ActionCam. В игре ActionCam всё ещё обозначена как «экспериментальная», и со стороны Blizzard не было никаких признаков её дальнейшей разработки. Есть некоторые недостатки, но мы должны быть благодарны, что ActionCam оставили в игре для таких энтузиастов, как мы. :-) DC не просто позволяет изменять настройки ActionCam, но и иметь разные настройки для различных игровых ситуаций. Помимо ActionCam, DC также предоставляет функции, касающиеся зума камеры и затемнения интерфейса.

Работа mpstark над DC продолжалась до августа 2018 года. Хотя большинство функций работали хорошо для значительной базы пользователей, mpstark всегда считал DC находящимся в стадии бета-версии, и из-за ослабевающего интереса к WoW он в итоге не возобновил свою работу. В то время Ludius уже начал вносить изменения в DC для себя, что заметил Weston (он же dernPerkins), который в начале 2020 года сумел связаться с mpstark, что привело к тому, что Ludius взял на себя разработку. Первая не-бета версия 1.0 была выпущена в мае 2020 года, включая изменения Ludius на тот момент. Впоследствии Ludius начал работу над переработкой DC, в результате чего осенью 2022 года была выпущена версия 2.0.

Когда mpstark начинал DC, его целью было сделать большинство настроек внутриигровыми, чтобы не приходилось менять исходный код. Это упростило эксперименты, особенно с различными игровыми ситуациями. Начиная с версии 2.0, эти расширенные настройки были перемещены в специальный раздел под названием «Управление ситуацией». Большинству пользователей он, вероятно, никогда не понадобится, но для «продвинутых пользователей» он всё ещё доступен. Опасность внесения изменений там заключается в том, что сохранённые пользовательские настройки всегда переопределяют оригинальные настройки DC, даже если новые версии DC приносят обновлённые оригинальные настройки. Поэтому в верхней части этой страницы отображается предупреждение, если у вас есть оригинальные ситуации с изменённым «Управлением ситуацией».

Если вы считаете, что одну из оригинальных ситуаций DC следует изменить, вы всегда можете создать её копию со своими изменениями. Не стесняйтесь экспортировать эту новую ситуацию и публиковать её на странице DC на CurseForge. Мы можем добавить её как новую собственную оригинальную ситуацию. Вы также можете экспортировать и публиковать свой полный профиль DC, так как мы всегда ищем новые пресеты профилей, которые облегчат новичкам знакомство с DC. Если вы нашли проблему или хотите внести предложение, просто оставьте комментарий на CurseForge или, ещё лучше, используйте Issues на GitHub. Если вы хотите внести свой вклад, не стесняйтесь открывать там пулл-реквест.

Вот несколько удобных слеш-команд:

    `/dynamiccam` или `/dc` открывает это меню.
    `/zoominfo` или `/zi` выводит текущий уровень зума.

    `/zoom #1 #2` приближает к уровню зума #1 за #2 секунды.
    `/yaw #1 #2` поворачивает камеру на #1 градусов за #2 секунды (отрицательное #1 для поворота вправо).
    `/pitch #1 #2` наклоняет камеру на #1 градусов (отрицательное #1 для наклона вверх).


]]
L["About"] = "О программе"
L["The following game situations have \"Situation Controls\" deviating from DynamicCam's stock settings.\n\n"] = "Следующие игровые ситуации имеют «Управление ситуацией», отличающееся от оригинальных настроек DynamicCam.\n\n"
L["<situationControlsWarning>"] = "\nЕсли вы делаете это намеренно, всё в порядке. Просто имейте в виду, что любые обновления этих настроек разработчиками DynamicCam всегда будут переопределены вашей изменённой (возможно, устаревшей) версией. Вы можете проверить вкладку «Управление ситуацией» каждой ситуации для подробностей. Если вы не знаете о каких-либо изменениях «Управления ситуацией» с вашей стороны и просто хотите восстановить оригинальные настройки управления для *всех* ситуаций, нажмите эту кнопку:"
L["Profiles"] = "Профили"
L["Manage Profiles"] = "Управление профилями"
L["<manageProfilesWarning>"] = "Like many addons, DynamicCam uses the \"AceDB-3.0\" library to manage profiles. What you have to understand is that there is nothing like \"Save Profile\" here. You can only create new profiles and you can copy settings from another profile into the currently active one. Whatever change you make for the currently active profile is immediately saved! There is nothing like \"cancel\" or \"discard changes\". The \"Reset Profile\" button only resets to the global default profile.\n\nSo if you like your DynamicCam settings, you should create another profile into which you copy these settings as a backup. When you don't use this backup profile as your active profile, you can experiment with the settings and return to your original profile at any time by selecting your backup profile in the \"Copy from\" box.\n\nIf you want to switch profiles via macro, you can use the following:\n/run DynamicCam.db:SetProfile(\"Profile name here\")\n\n"
L["Profile presets"] = "Пресеты профиля"
L["Import / Export"] = "Импорт / Экспорт"


--------------------------------------------------------------------------------
-- MouseZoom.lua
--------------------------------------------------------------------------------
L["Current\nZoom\nValue"] = "Текущее\nЗначение\nЗума"
L["Reactive\nZoom\nTarget"] = "Цель\nРеактивного\nЗума"
L["Reactive Zoom"] = "Реактивный масштаб"
L["This graph helps you to\nunderstand how\nReactive Zoom works."] = "Этот график помогает\nпонять, как работает\nРеактивный масштаб."


--------------------------------------------------------------------------------
-- ZoomBasedSettings.lua
--------------------------------------------------------------------------------
L["DynamicCam: Zoom-Based Setting"] = "DynamicCam: Настройка от масштаба"
L["CVAR: "] = "CVAR: "
L["Z\no\no\nm"] = "Z\no\no\nm"
L["Value"] = "Значение"
L["Current Zoom:"] = "Тек. масштаб:"
L["Current Value:"] = "Тек. значение:"
L["Left-click: add/drag point | Right-click: remove point"] = "ЛКМ: добавить/перетащить | ПКМ: удалить точку"
L["Cancel"] = "Отмена"
L["OK"] = "ОК"
L["Close and revert all changes made since opening this editor."] = "Закрыть и отменить все изменения."
L["Close and keep all changes."] = "Закрыть и сохранить все изменения."
L["Zoom-based"] = "От масштаба"
L["Edit Curve"] = "Изм. кривую"
L["Enable zoom-based curve for this setting.\n\nWhen enabled, the value will change smoothly based on your camera zoom level instead of using a single fixed value. Click the gear icon to edit the curve."] = "Включить кривую, зависящую от масштаба.\n\nЕсли включено, значение будет плавно меняться в зависимости от уровня масштабирования камеры. Нажмите на шестеренку для редактирования кривой."
L["Open the curve editor.\n\nAllows you to define exactly how this setting changes as you zoom in and out. You can add control points to create a custom curve."] = "Открыть редактор кривых.\n\nПозволяет точно определить, как этот параметр изменяется при масштабировании. Вы можете добавлять контрольные точки для создания пользовательской кривой."


--------------------------------------------------------------------------------
-- Core.lua
--------------------------------------------------------------------------------
L["Enter name for custom situation:"] = "Введите имя для своей ситуации:"
L["Create"] = "Создать"
L["While you are using horizontal camera offset, DynamicCam prevents CameraKeepCharacterCentered!"] = "Пока вы используете горизонтальное смещение камеры, DynamicCam предотвращает CameraKeepCharacterCentered!"
L["While you are using horizontal camera offset, DynamicCam prevents CameraReduceUnexpectedMovement!"] = "Пока вы используете горизонтальное смещение камеры, DynamicCam предотвращает CameraReduceUnexpectedMovement!"
L["While you are using vertical camera pitch, DynamicCam prevents CameraKeepCharacterCentered!"] = "Пока вы используете вертикальный наклон камеры, DynamicCam предотвращает CameraKeepCharacterCentered!"


--------------------------------------------------------------------------------
-- CvarMonitor.lua
--------------------------------------------------------------------------------
L["Disabled"] = "Отключено"
L["Attention"] = "Внимание"
L["Your DynamicCam addon lets you adjust horizontal and vertical mouse look speed individually! Just go to the \"Mouse Look\" settings of DynamicCam to make the adjustments there."] = "Ваш аддон DynamicCam позволяет настраивать горизонтальную и вертикальную скорость поворота камеры отдельно! Просто перейдите в настройки «Поворот камеры» DynamicCam, чтобы сделать настройки там."
L["The \"%s\" setting is disabled by DynamicCam, while you are using the horizontal camera over shoulder offset."] = "Настройка «%s» отключена DynamicCam, пока вы используете горизонтальное смещение камеры от плеча."
L["cameraView=%s prevented by DynamicCam!"] = "cameraView=%s предотвращено DynamicCam!"


--------------------------------------------------------------------------------
-- DefaultSettings.lua - Situation Names
--------------------------------------------------------------------------------
L["City"] = "Город"
L["City (Indoors)"] = "Город (в помещении)"
L["World"] = "Мир"
L["World (Indoors)"] = "Мир (в помещении)"
L["World (Combat)"] = "Мир (Бой)"
L["Dungeon/Scenario"] = "Подземелье/Сценарий"
L["Dungeon/Scenario (Outdoors)"] = "Подземелье/Сценарий (Снаружи)"
L["Dungeon/Scenario (Combat, Boss)"] = "Подземелье/Сценарий (Бой, Босс)"
L["Dungeon/Scenario (Combat, Trash)"] = "Подземелье/Сценарий (Бой, Треш)"
L["Raid"] = "Рейд"
L["Raid (Outdoors)"] = "Рейд (Снаружи)"
L["Raid (Combat, Boss)"] = "Рейд (Бой, Босс)"
L["Raid (Combat, Trash)"] = "Рейд (Бой, Треш)"
L["Arena"] = "Арена"
L["Arena (Combat)"] = "Арена (Бой)"
L["Battleground"] = "Поле боя"
L["Battleground (Combat)"] = "Поле боя (Бой)"
L["Mounted (any)"] = "На маунте (любой)"
L["Mounted (only flying-mount)"] = "На маунте (только летающий)"
L["Mounted (only flying-mount + airborne)"] = "На маунте (только летающий + в воздухе)"
L["Mounted (only flying-mount + airborne + Skyriding)"] = "На маунте (только летающий + в воздухе + Высший пилотаж)"
L["Mounted (only flying-mount + Skyriding)"] = "На маунте (только летающий + Высший пилотаж)"
L["Mounted (only airborne)"] = "На маунте (только в воздухе)"
L["Mounted (only airborne + Skyriding)"] = "На маунте (только в воздухе + Высший пилотаж)"
L["Mounted (only Skyriding)"] = "На маунте (только Высший пилотаж)"
L["Druid Travel Form"] = "Походный облик друида"
L["Dracthyr Soar"] = "Драктир Парение"
L["Skyriding Race"] = "Гонка Высшего пилотажа"
L["Taxi"] = "Такси"
L["Vehicle"] = "Транспорт"
L["Hearth/Teleport"] = "Камень/Телепорт"
L["Annoying Spells"] = "Раздражающие заклинания"
L["NPC Interaction"] = "Взаимодействие с НПС"
L["Mailbox"] = "Почтовый ящик"
L["Fishing"] = "Рыбалка"
L["Gathering"] = "Сбор"
L["AFK"] = "АФК"
L["Pet Battle"] = "Битва питомцев"
L["Professions Frame Open"] = "Окно профессии открыто"
