local L = LibStub("AceLocale-3.0"):NewLocale("DynamicCam", "zhCN")
if not L then return end

-- Options
L["Reset"] = "重置"
L["Reset to global default"] = "重置为全局默认值"
L["(To restore the settings of a specific profile, restore the profile in the \"Profiles\" tab.)"] = "（要恢复特定配置文件的设置，请在“配置文件”标签中恢复该配置文件。）"
L["Currently overridden by the active situation \"%s\"."] = "当前被活动情境覆盖: \"%s\"."
L["Override Standard Settings"] = "覆盖标准情境"
L["<overrideStandardToggle_desc>"] = "勾选这个复选框，允许你在激活当前情境时，覆盖标准情境。取消勾选将删除此类型的情境设置。"
L["Standard Settings"] = "标准设置"
L["Situation Settings"] = "情境设置"
L["<standardSettings_desc>"] = "当没有任何情境处于激活状态，或者激活的情境没有设置覆盖标准设置的情境设置时，将应用这些标准设置。"
L["<standardSettingsOverridden_desc>"] = "绿色的类型表示目前被激活的情境覆盖。因此，在覆盖情境激活时，绿色类型的标准设置不会生效。"
L["These Situation Settings override the Standard Settings when the respective situation is active."] = "当相应的情境激活时，这些情境设置将覆盖标准设置。"
L["Mouse Zoom"] = "鼠标缩放"
L["Maximum Camera Distance"] = "最大镜头距离"
L["How many yards the camera can zoom away from your character."] = "镜头镜头可以从你的角色拉远多少码的距离。"
L["Camera Zoom Speed"] = "镜头缩放速度"
L["How fast the camera can zoom."] = "镜头镜头缩放的速度。"
L["Zoom Increments"] = "镜头缩放增量"
L["How many yards the camera should travel for each \"tick\" of the mouse wheel."] = "每次鼠标滚轮镜头应该移动多少码。"
L["Use Reactive Zoom"] = "使用响应缩放"
L["Quick-Zoom Additional Increments"] = "快速缩放额外增量"
L["How many yards per mouse wheel \"tick\" should be added when quick-zooming."] = "当快速缩放时，每次鼠标滚轮滚动应该增加多少码。"
L["Quick-Zoom Enter Threshold"] = "快速缩放阈值"
L["How many yards the \"Reactive Zoom Target\" and the \"Current Zoom Value\" have to be apart to enter quick-zooming."] = "\"响应缩放目标\"与\"实际缩放值\"之间至少需要多少码的距离，才能触发快速缩放功能。"
L["Maximum Zoom Time"] = "最大缩放时间"
L["The maximum time the camera should take to make \"Current Zoom Value\" equal to \"Reactive Zoom Target\"."] = "镜头会在这个时间内将\"当前缩放值\"调整到\"响应缩放目标\"。"
L["Help"] = "帮助"
L["Toggle Visual Aid"] = "视觉辅助开关"
L["<reactiveZoom_desc>"] = "使用 DynamicCam 的响应缩放功能，鼠标滚轮控制\"响应缩放目标\"。每当\"响应缩放目标\"与\"实际缩放值\"不同时，DynamicCam 会改变\"实际缩放值\"，直到他再次与\"响应缩放目标\"相同。\n\n这种缩放变化的速度取决于\"镜头缩放速度\"和 \"最大缩放时间\"。如果\"最大缩放时间\"设置的比较短，无论\"镜头缩放速度\"如何设置，缩放总会很快执行。要实现舒缓的缩放变化，你必须将\"最大缩放时间\"设置得更长，同时把\"镜头缩放速度\"设置为较低的值。\n\n为了实现随着鼠标滚轮快速滚动更快地缩放镜头，请使用\"快速缩放功能\"：如果\"响应缩放目标\"与\"实际缩放值\"的偏差超过了\"快速缩放阈值\"，每次鼠标滚轮的滚动都会增加\"快速缩放额外增量\"。\n\n为了感受这些功能是如何工作的，你可以在寻找合适设置的同时，开启视觉辅助。你也可以通过左键拖弋操作来自动移动这个图表。右键点击可以关闭它。"
L["Enhanced minimal zoom-in"] = "强化最小视角"
L["<enhancedMinZoom_desc>"] = "响应缩放允许你把镜头放大到比最近还近。你可以通过在第一人称视角时再次滚动鼠标实现这一点。\n\n启用\"强化最小视角\"后，我们会强制镜头在放大时也停留在这个视角上，而不是立即切换回第一人称视角。你也可以把此理解为\"狙击模式\"。\n\n|cFFFF0000启用\"强化最小视角\"可能会在CPU受限的情境下导致帧率下降15%。|r"
L["/reload of the UI required!"] = "需要使用 /reload 重载界面！"
L["Mouse Look"] = "鼠标观察"
L["Horizontal Speed"] = "水平速度"
L["How much the camera yaws horizontally when in mouse look mode."] = "当处于鼠标观察模式时，镜头水平偏转的程度。"
L["Vertical Speed"] = "垂直速度"
L["How much the camera pitches vertically when in mouse look mode."] = "当处于鼠标观察模式时，镜头垂直俯仰的程度。"
L["<mouseLook_desc>"] = "当您在“鼠标观察”模式下移动鼠标时（即按下鼠标左键或右键时），镜头移动的程度。\n\nWoW 默认界面设置中的“鼠标观察速度”滑块同时控制水平和垂直速度：自动将水平速度设置为垂直速度的 2 倍。DynamicCam 覆盖此设置，并允许您进行更加个性化的设置。"
L["Horizontal Offset"] = "水平偏移"
L["Camera Over Shoulder Offset"] = "镜头肩部偏移"
L["Positions the camera left or right from your character."] = "将镜头置于你角色的左侧或右侧。"
L["<cameraOverShoulder_desc>"] = "为使此功能生效，DynamicCam 会自动暂时禁用 WoW 的「动态眩晕」设置。因此，如果你需要「动态眩晕」设置，请不要在这些情境下使用水平偏移。\n\n当你选择你自己的角色时，WoW 会自动居中镜头。对此我们无能为力。对于镜头与墙壁碰撞时可能发生的偏移抽搐，我们也无能为力。一种解决方法是在建筑物内部使用极少或不使用偏移。\n\n此外，WoW 会根据角色模型或坐骑的不同，奇怪地应用不同的偏移。对于所有偏爱永久偏移的人，Ludius 正在开发另一个插件（“CameraOverShoulder Fix”）来解决这个问题。"
L["Adjust shoulder offset according to zoom level"] = "根据缩放级别调整偏移"
L["Enable"] = "启用"
L["and"] = "和"
L["No offset when below this zoom level:"] = "低于此缩放级别时无偏移:"
L["When the camera is closer than this zoom level, the offset has reached zero."] = "当镜头比此缩放级别更近时，偏移量已达到零。"
L["Real offset when above this zoom level:"] = "高于此缩放级别时的实际偏移:"
L["When the camera is further away than this zoom level, the offset has reached its set value."] = "当镜头比此缩放级别更远时，偏移量已达到其设定值。"
L["<shoulderOffsetZoom_desc>"] = "使肩部偏移在放大时逐渐过渡到零。两个滑块定义了此过渡发生的缩放级别范围。此设置为全局设置，不针对特定情境。"
L["Vertical Pitch"] = "垂直俯仰"
L["Pitch (on ground)"] = "俯仰 (地面)"
L["Pitch (flying)"] = "俯仰 (飞行)"
L["Down Scale"] = "俯视缩放"
L["Smart Pivot Cutoff Distance"] = "智能转轴截止距离"
L["<pitch_desc>"] = "如果镜头向上倾斜（较低的“俯仰”值），“俯视缩放”设置决定了从上方看向您角色时，这种倾斜生效的程度。将“俯视缩放”设置为 0 会使从上方看时向上倾斜的效果无效。相反，当您不是从上方看，或者镜头向下倾斜时（较高的“俯仰”值），“俯视缩放”设置几乎没有影响。\n\n因此，您应该首先在从背后看向您角色时，找到您偏好的“俯仰”设置。在您选择了向上倾斜后，接着在从上方看时找到您偏好的“俯视缩放”设置。\n\n\n当镜头与地面碰撞时，它通常会在镜头与地面的碰撞点执行向上倾斜。另一种选择是，在执行此倾斜的同时，镜头会向您角色的脚部靠近。“智能转轴截止距离”决定了镜头必须处于离您角色多近的距离内，才会发生这种情况。当值为 0 时，镜头永远不会靠近（WoW默认）。然而，当值为最大值 39 时，它总是会靠近。\n\n"
L["Target Focus"] = "目标焦点"
L["Enemy Target"] = "敌方目标"
L["Horizontal Strength"] = "水平强度"
L["Vertical Strength"] = "垂直强度"
L["Interaction Target (NPCs)"] = "交互目标 (NPC)"
L["<targetFocus_desc>"] = "如果启用，镜头会自动尝试将目标拉近屏幕中心。强度决定了这种效果的强度。\n\n如果“敌方目标”和“交互目标”都启用，后者似乎有一个奇怪的错误：当首次与 NPC 交互时，镜头会像预期的那样平滑移动到新角度。但是当您退出交互时，它会立即跳转到之前的角度。然后当您再次开始交互时，它再次跳转到新角度。这在与新 NPC 交谈时是可重复的：只有第一次过渡是平滑的，所有后续的都是立即的。\n如果您想要同时使用“敌方目标”和“交互目标”，一个变通方法是只在需要它且不太可能发生 NPC 交互的 DynamicCam 情境下激活“敌方目标”（比如战斗）。"
L["Head Tracking"] = "头部追踪"
L["<headTrackingEnable_desc>"] = "（这也可以作为一个 0 到 1 之间的连续值，但它只是分别乘以“强度（站立）”和“强度（移动）”。所以真的不需要另一个滑块。）"
L["Strength (standing)"] = "强度（站立）"
L["Inertia (standing)"] = "惯性（站立）"
L["Strength (moving)"] = "强度（移动）"
L["Inertia (moving)"] = "惯性（移动）"
L["Inertia (first person)"] = "惯性（第一人称）"
L["Range Scale"] = "范围缩放"
L["Camera distance beyond which head tracking is reduced or disabled. (See explanation below.)"] = "超过此镜头距离时减少或禁用头部追踪。（见下文解释。）"
L["(slider value transformed)"] = "（滑块值转换）"
L["Dead Zone"] = "死区"
L["Radius of head movement not affecting the camera. (See explanation below.)"] = "头部移动不影响镜头的半径。（见下文解释。）"
L["(slider value devided by 10)"] = "（滑块值除以 10）"
L["Requires /reload to come into effect!"] = "需要 /reload 才能生效！"
L["<headTracking_desc>"] = "启用头部追踪后，镜头会跟随您角色头部的移动。（虽然这可能有助于沉浸感，但如果您对“动态眩晕”敏感，也可能导致恶心。）\n\n“强度”设置决定了这种效果的强度。将其设置为 0 可以禁用头部追踪。“惯性”设置决定了镜头对头部移动的反应速度。将其设置为 0 也会禁用头部追踪。“站立”、“移动”和“第一人称”三种情况可以单独设置。“第一人称”没有“强度”设置，因为它分别沿用“站立”和“移动”的“强度”设置。如果您想单独激活或禁用“第一人称”，请使用“惯性”滑块来禁用不需要的情况。\n\n使用“范围缩放”设置，您可以设定超过此镜头距离时减少或禁用头部追踪。例如，如果滑块设置为 30，当镜头距离您角色超过 30 码时，将没有头部追踪。但是，从完全头部追踪到无头部追踪有一个逐渐过渡的过程，从滑块值的三分之一开始。例如，如果值设置为 30，当镜头距离小于 10 码时，有完全的头部追踪。从 10 码开始，头部追踪逐渐减少，直到从 30 码开始完全禁用。因此，最大值 117 允许在最大镜头距离 39 码时进行完全头部追踪。（提示：使用 DynamicCam 的“鼠标缩放”视觉辅助工具在设置期间了解当前镜头距离。）\n\n“死区”设置可以用来忽略较小的头部移动。将其设置为 0 可以让镜头跟随每一个微小的头部移动，而将其设置为更大的值则只跟随较大的移动。请注意，更改此设置只有在重新加载界面（在控制台中输入 /reload）后才生效。"
L["Situations"] = "情境"
L["Select a situation to setup"] = "选择一个情境来设置"
L["<selectedSituation_desc>"] = "\n|cffffcc00颜色代码：|r\n|cFF808A87- 禁用的情境。|r\n- 启用的情境。\n|cFF00FF00- 启用且当前激活的情境。|r\n|cFF63B8FF- 启用且条件满足但优先级低于当前激活情境的情境。|r\n|cFFFF6600- 修改过的原始“情境控制”（建议重置）。|r\n|cFFEE0000- 错误的“情境控制”（需要修正）。|r"
L["If this box is checked, DynamicCam will enter the situation \"%s\" whenever its condition is fulfilled and no other situation with higher priority is active."] = "如果勾选此框，只要其条件满足且没有其他更高优先级的活跃情境，DynamicCam 将进入情境“%s”。"
L["Custom:"] = "自定义："
L["(modified)"] = "(已修改)"
L["Delete custom situation \"%s\".\n|cFFEE0000Attention: There will be no 'Are you sure?' prompt!|r"] = "删除自定义情境“%s”。\n|cFFEE0000注意：不会有“你确定吗？”的提示！|r"
L["Create a new custom situation."] = "创建一个新的自定义情境。"
L["Situation Actions"] = "情境指令"
L["Setup stuff to happen while in a situation or when entering/exiting it."] = "设置在情境中或进入/退出时要执行的操作。"
L["Zoom/View"] = "缩放/视角"
L["Zoom to a certain zoom level or switch to a saved camera view when entering this situation."] = "在进入这个情境时，调整到特定的缩放级别或切换到保存的镜头视角。"
L["Set Zoom or Set View"] = "设置缩放或设置视角"
L["Zoom Type"] = "缩放模式"
L["<viewZoomType_desc>"] = "设置缩放：调整到给定的缩放级别，并有过渡时间和缩放条件的高级选项。\n\n设置视角：切换到包含固定缩放级别和镜头角度的保存的镜头视角。"
L["Set Zoom"] = "设置缩放"
L["Set View"] = "设置视角"
L["Set view to saved view:"] = "设置视角为保存视角："
L["Select the saved view to switch to when entering this situation."] = "选择进入此情境时要切换的保存视角。"
L["Instant"] = "立即"
L["Make view transitions instant."] = "使视角转换立即发生。"
L["Restore view when exiting"] = "退出时恢复视角"
L["When exiting the situation restore the camera position to what it was at the time of entering the situation."] = "退出情境时，将镜头恢复到进入情境时的位置。"
L["cameraSmoothNote"] = [[|cFFEE0000注意：|r 您正在使用WoW的“镜头跟随模式”，它会自动将镜头放置在玩家后面。这在您处于自定义保存视角时不起作用。您可以在不需要镜头跟随的情境中使用自定义保存视角（例如，NPC互动）。但在退出情境后，您必须返回到非自定义的默认视角，以便再次使镜头跟随工作。]]
L["Restore to default view:"] = "恢复为默认视角："
L["<viewRestoreToDefault_desc>"] = [[选择退出此情境时返回的默认视角。

视角1：缩放0，俯仰0
视角2：缩放5.5，俯仰10
视角3：缩放5.5，俯仰20
视角4：缩放13.8，俯仰30
视角5：缩放13.8，俯仰10]]
L["WARNING"] = "警告"
L["You are using the same view as saved view and as restore-to-default view. Using a view as restore-to-default view will reset it. Only do this if you really want to use it as a non-customized saved view."] = "您要设置的保存视角与要恢复的默认视角相同。如果一个视角被用作恢复到默认，它将被重置。只有在您确实想将其用作非自定义保存视角时才这样做。"
L["View %s is used as saved view in the situations:\n%sand as restore-to-default view in the situations:\n%s"] = "视角 %s 在以下情境中被用作保存视角：\n%s并且在以下情境中被用作恢复默认视角：\n%s"
L["<view_desc>"] = [[魔兽世界允许保存最多5个自定义镜头视角。视角1由DynamicCam使用，用于保存进入情境时的镜头位置，以便在退出情境时可以恢复，如果您在上面勾选了“恢复”。这对于短暂的情境（如与NPC互动）特别有用，允许在与NPC对话时切换到一个视角，然后回到镜头之前的位置。这就是为什么视角1不能在上述保存视角的下拉菜单中选择。

视角2、3、4和5可以用来保存自定义的镜头位置。要保存一个视角，只需将镜头调整到所需的缩放和角度。然后在控制台中输入以下命令（其中#是编号2、3、4或5）：

  /saveView #

或简写为：

  /sv #

请注意，保存的视角由魔兽世界存储。DynamicCam只存储使用哪些视角编号。因此，当您导入新的DynamicCam情境配置文件和视角时，您可能需要在之后设置并保存相应的视角。


DynamicCam还提供了一个控制台命令，用于无论进入还是退出情境都切换到视角：

  /setView #

要使视角转换立即发生，请在视角编号后添加一个“i”。例如，要立即切换到保存的视角3，请输入：

  /setView 3 i

]]
L["Zoom Transition Time"] = "缩放过渡时间"
L["<transitionTime_desc>"] = "过渡到新缩放值所需的时间（以秒为单位）。\n\n如果设置的值低于可能的最低值，过渡速度将尽可能快，以当前镜头缩放速度为准（可在DynamicCam的“鼠标缩放”设置中调整）。\n\n如果某个情境在其进入脚本中分配了变量“this.transitionTime”（参见“情境控制”），这里的设置将被覆盖。例如，在“炉石/传送”情境中这样做，以便为施法持续时间允许一个过渡时间。"
L["<zoomType_desc>"] = "\n设置：始终将缩放设置为此值。\n\n拉远：仅当镜头当前比此值更近时，才设置缩放。\n\n推近：仅当镜头当前比此值更远时，才设置缩放。\n\n范围：如果比给定的最大值更远，则放大；如果比给定的最小值更近，则缩小。如果当前缩放在[min, max]范围内，则不执行任何操作。"
L["Set"] = "设置"
L["Out"] = "拉远"
L["In"] = "推近"
L["Range"] = "范围"
L["Don't slow"] = "不要减速"
L["Zoom transitions may be executed faster (but never slower) than the specified time above, if the \"Camera Zoom Speed\" (see \"Mouse Zoom\" settings) allows."] = "如果“镜头缩放速度”（参见“鼠标缩放”设置）允许，缩放过渡可能会比上述指定时间更快（但不会减速）。"
L["Zoom Value"] = "缩放值"
L["Zoom to this zoom level."] = "缩放到这个缩放级别。"
L["Zoom out to this zoom level, if the current zoom level is less than this."] = "如果当前缩放级别小于此值，则缩小到这个缩放级别。"
L["Zoom in to this zoom level, if the current zoom level is greater than this."] = "如果当前缩放级别大于此值，则放大到这个缩放级别。"
L["Zoom Min"] = "最小缩放"
L["Zoom Max"] = "最大缩放"
L["Restore Zoom"] = "恢复缩放"
L["<zoomRestoreSetting_desc>"] = "当您退出一个情境（或退出没有活跃情境的默认状态）时，当前的缩放级别会被临时保存，以便下次进入此情境时可以恢复。在这里，您可以选择如何处理。\n\n此设置对所有情境都是全局的。"
L["Restore Zoom Mode"] = "恢复缩放模式"
L["<zoomRestoreSettingSelect_desc>"] = "\n从不：进入情境时，应用进入情境的实际缩放设置（如果有）。不考虑保存的缩放。\n\n总是：进入情境时，使用此情境上次保存的缩放。其实际设置仅在登录后首次进入情境时考虑。\n\n自适应：仅在某些情况下使用保存的缩放。例如，只有当返回到您来自的相同情境，或者保存的缩放满足情境的“推近”、“拉远”或“范围”缩放设置的标准时。"
L["Never"] = "从不"
L["Always"] = "总是"
L["Adaptive"] = "自适应"
L["<zoom_desc>"] = [[要确定当前的缩放级别，您可以使用“视觉辅助”（在DynamicCam的“鼠标缩放”设置中切换）或使用控制台命令：

  /zoomInfo

或者简写为：

  /zi]]
L["Rotation"] = "转动"
L["Start a camera rotation when this situation is active."] = "当此情境激活时开始镜头转动。"
L["Rotation Type"] = "转动方式"
L["<rotationType_desc>"] = "\n持续转动：当此情境激活时，镜头会持续水平转动。这只建议用于不使用鼠标移动摄像机的情况；例如，传送法术施放、飞行或暂离。无法持续垂直转动，因为它会在达到垂直俯视或仰视视角时停止。\n\n按度数转动：进入情境后，根据给定的度数改变当前摄像机的水平偏转（yaw）和/或垂直俯仰（pitch）。"
L["Continuously"] = "持续转动"
L["By Degrees"] = "按角度转动"
L["Acceleration Time"] = "加速时间"
L["Rotation Time"] = "转动时间"
L["<accelerationTime_desc>"] = "如果您在这里设置的时间大于 0，持续转动不会立即以全速开始，而是会花费这段时间来加速。（只有在相对较高的转动速度下才会明显感知。）"
L["<rotationTime_desc>"] = "需要多长时间来调整到新的摄像机角度。如果这里给出的值太小，摄像机可能会转动过头，因为我们每渲染一帧时只检查一次是否达到了期望的角度。\n\n如果某个情境在其进入脚本中分配了变量“this.rotationTime”（参见“情境控制”），这里的设置将被覆盖。例如，在“炉石/传送”情境中这样做，以便为施法时间内塞入一个转动时间。"
L["Rotation Speed"] = "转动速度"
L["Speed at which to rotate in degrees per second. You can manually enter values between -900 and 900, if you want to get yourself really dizzy..."] = "每秒转动的度数。如果您想让自己真的头晕目眩，可以手动输入 -900 到 900 之间的值..."
L["Yaw (-Left/Right+)"] = "偏转（-左/右+）"
L["Degrees to yaw (left or right)."] = "偏转的度数（左或右）。"
L["Pitch (-Down/Up+)"] = "俯仰（-下/上+）"
L["Degrees to pitch (up or down). There is no going beyond the perpendicular upwards or downwards view."] = "俯仰的度数（上或下）。无法超过垂直俯视或仰视视角。"
L["Rotate Back"] = "转动返回"
L["<rotateBack_desc>"] = "退出情境时，按进入情境后转动的度数（360）反向转动。这实际上会将您带回进入前的摄像机位置，除非您在此过程中用鼠标改变了视角。\n\n如果您正在进入一个自带转动设置的新情境，那么退出情境的“转动返回”将被忽略。"
L["Rotate Back Time"] = "转动返回时间"
L["<rotateBackTime_desc>"] = "转动返回所需的时间。如果这里给出的值太小，摄像机可能会转动过头，因为我们每渲染一帧时只检查一次是否达到了期望的角度。"
L["Fade Out UI"] = "渐隐界面"
L["Fade out or hide (parts of) the UI when this situation is active."] = "当此情境激活时，渐隐或隐藏（部分）用户界面。"
L["Adjust to Immersion"] = "调整以适应沉浸"
L["<adjustToImmersion_desc>"] = "许多人将 Immersion 插件与 DynamicCam 结合使用。Immersion 在 NPC 互动期间有一些自己的隐藏 UI 特性。在某些情况下，DynamicCam 的隐藏界面会覆盖 Immersion 的设置。为了防止这种情况，您可以在 DynamicCam 中进行所需的设置。点击此按钮使用与 Immersion 相同的渐显和渐隐时间。想要更多选项，请查看 Ludius 的另一个插件“Immersion ExtraFade”。"
L["Fade Out Time"] = "渐隐时间"
L["Seconds it takes to fade out the UI when entering the situation."] = "进入情境时，界面渐隐所需的秒数。"
L["Fade In Time"] = "渐显时间"
L["<fadeInTime_desc>"] = "退出情境时，UI 渐显所需的秒数。\n\n当您在两个都启用了 UI 隐藏的情境之间切换时，将使用进入情境的渐隐时间进行过渡。"
L["Hide entire UI"] = "隐藏整个界面"
L["<hideEntireUI_desc>"] = "“隐藏”的界面和“只是渐隐”的界面之间有区别：“渐隐”的界面元素的不透明度为 0，但仍然可以与之交互。从 DynamicCam 2.0 开始，如果界面元素的不透明度为 0，我们会自动隐藏大多数界面元素。因此，渐隐后隐藏整个界面的选项更像是一个遗留物。仍然使用它的原因可能是为了避免不希望的交互（例如鼠标悬停提示）DynamicCam 仍然没有正确隐藏的界面元素。\n\n隐藏界面的不透明度当然是 0，所以您不能选择不同的不透明度，也不能保留任何界面元素可见（除了 FPS 指示器）。\n\n在战斗中我们不能改变受保护的界面元素的隐藏状态。因此，此类元素在战斗中始终只是“渐隐”。请注意，小地图上“光点”的不透明度无法降低。因此，如果您尝试隐藏小地图，在战斗中“光点”始终可见。\n\n如果您为当前激活的情境选中此框，它不会立即生效，因为这也会隐藏这个设置框。您必须进入情境才能使其生效，这也可以通过上面的情境“启用”复选框来实现。\n\n另请注意，隐藏整个界面会取消与邮箱或 NPC 的交互。所以不要在这些情境下使用它！"
L["Keep FPS indicator"] = "保留 FPS 指示器"
L["Do not fade out or hide the FPS indicator (the one you typically toggle with Ctrl + R)."] = "不要渐隐或隐藏 FPS 指示器（通常用 Ctrl+R 切换的那个）。"
L["Fade Opacity"] = "渐隐不透明度"
L["Fade the UI to this opacity when entering the situation."] = "进入情境时将用户界面渐隐到这种不透明度。"
L["Excluded UI elements"] = "排除的用户界面元素"
L["Keep Alerts"] = "保留警告"
L["Still show alert popups from completed achievements, Covenant Renown, etc."] = "仍然显示来自完成成就、盟约声望等的警告弹出窗口。"
L["Keep Tooltip"] = "保留提示"
L["Still show the game tooltip, which appears when you hover your mouse cursor over UI or world elements."] = "仍然显示游戏提示，当您将鼠标光标悬停在用户界面或世界元素上时出现。"
L["Keep Minimap"] = "保留小地图"
L["<keepMinimap_desc>"] = "不要渐隐小地图。\n\n请注意，我们不能减少小地图上“光点”的不透明度。当用户界面渐隐到 0 不透明度时，这些只能与整个小地图一起隐藏。"
L["Keep Chat Box"] = "保留聊天框"
L["Do not fade out the chat box."] = "不要渐隐聊天框。"
L["Keep Tracking Bar"] = "保留经验/声望栏"
L["Do not fade out the tracking bar (XP, AP, reputation)."] = "不要渐隐经验/声望栏（经验值、能力点、声望）。"
L["Keep Party/Raid"] = "保留小队/团队框架"
L["Do not fade out the Party/Raid frame."] = "不要渐隐小队/团队框架"
L["Keep Encounter Frame (Skyriding Vigor)"] = "保留遭遇框架（驭空术精力）"
L["Do not fade out the Encounter Frame, which while skyriding is the Vigor display."] = "不要渐隐遭遇框架，在驭空术时是精力显示。"
L["Keep additional frames"] = "保留额外框架"
L["<keepCustomFrames_desc>"] = "下面的文本框允许您定义在 NPC 交互期间想要保留的任何框架。\n\n使用控制台命令 /fstack 来了解框架的名称。\n\n例如，您可能想要保留小地图旁边的增益图标，以便在 NPC 交互期间通过点击适当的图标来取消骑乘。"
L["Custom frames to keep"] = "自定义保留框架"
L["Separated by commas."] = "用逗号分隔。"
L["Emergency Fade In"] = "紧急渐显"
L["Pressing Esc fades the UI back in."] = "按下 Esc 键将用户界面渐显回来。"
L["<emergencyShow_desc>"] = [[有时您可能希望在常态隐藏界面的情况下显示界面。在旧版本的 DynamicCam 中有个规则，允许您在按下 Esc 键时显示界面。但这样做有个缺点，当 Esc 键用于其他作用，比如关闭窗口、取消施法等时，界面也会显示。取消勾选上面的复选框可以禁用此功能。

但请注意，这样可能会导致无法访问界面！Esc 键更好的替代方案是使用以下的控制台命令，它们会根据当前设置的“渐隐界面”设置显示或隐藏界面：

    /showUI
    /hideUI

为了更加快捷的实现渐隐界面，将 /showUI 放入宏命令中，并在 "bindings-cache.wtf" 文件中为其分配一个按键。例如：

    bind ALT+F11 MACRO 您的宏名称

如果您不想编辑 "bindings-cache.wtf" 文件，可以使用类似 "BindPad" 这样的按键绑定插件。

使用 /showUI 或者 /hideUI 而不带任何参数将采用当前情境的渐显和渐隐时间。但您也可以使用参数提供不同的过渡时间。例如：

    /showUI 0

来实现立即显示界面，没有任何延迟。]]
L["<hideUIHelp_desc>"] = "在设置您期望的界面渐隐效果时，如果这个“界面”设置框也一起渐隐，可能会很烦人。如果选中这个框，它将不会被渐隐。\n\n此设置适用于所有情况。"
L["Do not fade out this \"Interface\" settings frame."] = "不要渐隐这个“界面”设置框。"
L["Situation Controls"] = "情境控制"
L["<situationControls_help>"] = "在这里控制情境何时激活。可能需要 WoW UI API 的知识。如果您对 DynamicCam 的原始情境感到满意，请直接忽略此部分。但如果您想创建自定义情境，可以在这里查看原始情境。您也可以修改它们，但请注意：即使 DynamicCam 的未来版本引入了重要更新，您更改的设置也会保留。\n\n"
L["Priority"] = "优先级"
L["The priority of this situation.\nMust be a number."] = "此情境的优先级。\n必须是数字。"
L["Restore stock setting"] = "恢复原始设置"
L["Your \"Priority\" deviates from the stock setting for this situation (%s). Click here to restore it."] = "您的“优先级”偏离了此情境（%s）的原始设置。点击此处恢复。"
L["<priority_desc>"] = "如果同时满足多个不同 DynamicCam 情境的条件，则进入优先级最高的情境。例如，只要满足“世界（室内）”的条件，也就满足了“世界”的条件。但由于“世界（室内）”的优先级高于“世界”，因此会优先考虑它。您也可以在上面的下拉菜单中查看所有情境的优先级。\n\n"
L["Error message:"] = "错误信息："
L["Events"] = "事件"
L["Separated by commas."] = "用逗号分隔。"
L["Your \"Events\" deviate from the default for this situation. Click here to restore them."] = "您的“事件”偏离了此情境的原始设置。点击此处恢复。"
L["<events_desc>"] = [[在这里定义 DynamicCam 应该检查此情境条件的所有游戏内事件，以便在适用的情况下进入或退出它。

您可以使用 WoW 的事件记录来了解游戏内事件。
要打开它，请在控制台中输入：

  /eventtrace

所有可能事件的列表也可以在这里找到：
https://warcraft.wiki.gg/wiki/Events

]]
L["Initialisation"] = "初始化"
L["Initialisation Script"] = "初始化脚本"
L["Lua code using the WoW UI API."] = "使用 WoW UI API 的 Lua 代码。"
L["Your \"Initialisation Script\" deviates from the stock setting for this situation. Click here to restore it."] = "您的“初始化脚本”偏离了此情境的原始设置。点击此处恢复。"
L["<initialisation_desc>"] = [[情境的初始化脚本在加载 DynamicCam 时运行一次（以及在修改情境时）。通常，您会将要在其他任何脚本（条件、进入、退出）中重用的内容放入其中。这可以使这些其他脚本稍微简短一些。

例如，“炉石/传送”情境的初始化脚本定义了表“this.spells”，其中包括传送法术的法术 ID。条件脚本随后可以在每次执行时简单地访问“this.spells”。

就像在这个例子中一样，您可以通过将其放入“this”表中来在情境的脚本之间共享任何数据对象。

]]
L["Condition"] = "条件"
L["Condition Script"] = "条件脚本"
L["Lua code using the WoW UI API.\nShould return \"true\" if and only if the situation should be active."] = "使用 WoW UI API 的 Lua 代码。\n当且仅当情境应处于活动状态时，应返回“true”。"
L["Your \"Condition Script\" deviates from the stock setting for this situation. Click here to restore it."] = "您的“条件脚本”偏离了此情境的原始设置。点击此处恢复。"
L["<condition_desc>"] = [[情境的条件脚本在每次触发此情境的游戏内事件时运行。当且仅当此情境应处于活动状态时，脚本应返回“true”。

例如，“城市”情境的条件脚本使用 WoW API 函数“IsResting()”来检查您当前是否在休息区：

  return IsResting()

同样，“城市（室内）”情境的条件脚本也使用 WoW API 函数“IsIndoors()”来检查您是否在室内：

  return IsResting() and IsIndoors()

可以在这里找到 WoW API 函数列表：
https://warcraft.wiki.gg/wiki/World_of_Warcraft_API

]]
L["Entering"] = "进入"
L["On-Enter Script"] = "进入脚本"
L["Your \"On-Enter Script\" deviates from the stock setting for this situation. Click here to restore it."] = "您的“进入脚本”偏离了此情境的原始设置。点击此处恢复。"
L["<executeOnEnter_desc>"] = [[情境的进入脚本在每次进入情境时运行。

到目前为止，唯一的例子是“炉石/传送”情境，其中我们使用 WoW API 函数“UnitCastingInfo()”来确定当前法术的施法持续时间。然后我们将其分配给变量“this.transitionTime”和“this.rotationTime”，以便缩放或旋转（参见“情境指令”）可以正好持续法术施法的时间。（并非所有传送法术都有相同的施法时间。）

]]
L["Exiting"] = "退出"
L["On-Exit Script"] = "退出脚本"
L["Your \"On-Exit Script\" deviates from the stock setting for this situation. Click here to restore it."] = "您的“退出脚本”偏离了此情境的原始设置。点击此处恢复。"
L["Exit Delay"] = "退出延迟"
L["Wait for this many seconds before exiting this situation."] = "在退出此情境之前等待这么多秒。"
L["Your \"Exit Delay\" deviates from the stock setting for this situation. Click here to restore it."] = "您的“退出延迟”偏离了此情境的原始设置。点击此处恢复。"
L["<executeOnExit_desc>"] = [[情境的退出脚本在每次退出情境时运行。到目前为止，还没有情境使用此功能。

延迟决定了退出情境前等待的秒数。到目前为止，唯一的例子是“钓鱼”情境，延迟让您有时间重新抛竿而不会退出情境。

]]
L["Export"] = "导出"
L["Coming soon(TM)."] = "即将推出(TM)。"
L["Import"] = "导入"
L["<welcomeMessage>"] = [[我们很高兴您在这里，希望您能在这个插件中获得乐趣。

DynamicCam (DC) 由 mpstark 于 2016 年 5 月启动，当时暴雪的 WoW 开发人员在游戏中引入了实验性的 ActionCam 功能。DC 的主要目的是为 ActionCam 设置提供一个用户界面。在游戏中，ActionCam 仍被指定为“实验性”，暴雪也没有进一步开发它的迹象。虽然有一些缺陷，但我们应该感谢 ActionCam 被保留在游戏中供像我们这样的爱好者使用。 :-) DC 不仅允许您更改 ActionCam 设置，还可以针对不同的游戏情境使用不同的设置。与 ActionCam 无关，DC 还提供有关镜头缩放和界面渐隐的功能。

mpstark 在 DC 上的工作持续到 2018 年 8 月。虽然大多数功能对于大量用户群来说运作良好，但 mpstark 一直认为 DC 处于测试阶段，由于他对 WoW 的兴趣减弱，他最终没有恢复工作。当时，Ludius 已经开始为自己对 DC 进行调整，这被 Weston (又名 dernPerkins) 注意到，他在 2020 年初设法与 mpstark 取得了联系，导致 Ludius 接管了开发工作。第一个非测试版本 1.0 于 2020 年 5 月发布，包括 Ludius 到那时为止的调整。随后，Ludius 开始着手对 DC 进行全面改进，并在 2022 年秋季发布了 2.0 版本。

当 mpstark 启动 DC 时，他的重点是在游戏内进行大多数自定义，而不必更改源代码。这使得实验变得更容易，特别是针对不同的游戏情境。从 2.0 版本开始，这些高级设置已移至名为“情境控制”的特殊部分。大多数用户可能永远不需要它，但对于“高级用户”，它仍然可用。在那里进行更改的一个风险是，保存的用户设置总是会覆盖 DC 的原始设置，即使 DC 的新版本带来了更新的原始设置。因此，每当您有修改了“情境控制”的原始情境时，此页面顶部都会显示警告。

如果您认为 DC 的某个原始情境应该更改，您总是可以创建一个包含您更改的副本。请随时导出这个新情境并将其发布在 DC 的 CurseForge 页面上。然后我们可能会将其添加为自己的新原始情境。我们也欢迎您导出并发布您的整个 DC 配置文件，因为我们要寻找新的配置文件预设，以便让新用户更容易上手 DC。如果您发现问题或想提出建议，只需在 CurseForge 评论中留言，或者更好的是使用 GitHub 上的 Issues。如果您想做出贡献，也欢迎在那裡提交 pull request。

这是一些方便的斜杠命令：

    `/dynamiccam` 或 `/dc` 打开此菜单。
    `/zoominfo` 或 `/zi` 打印当前的缩放级别。

    `/zoom #1 #2` 在 #2 秒内缩放到缩放级别 #1。
    `/yaw #1 #2` 在 #2 秒内将镜头水平偏转 #1 度（负 #1 为向右偏转）。
    `/pitch #1 #2` 将镜头俯仰 #1 度（负 #1 为向上俯仰）。


]]
L["About"] = "关于"
L["The following game situations have \"Situation Controls\" deviating from DynamicCam's stock settings.\n\n"] = "以下游戏情境的“情境控制”偏离了 DynamicCam 的原始设置。\n\n"
L["<situationControlsWarning>"] = "\n如果您是有意为之，那没关系。请注意，DynamicCam 开发人员对这些设置的任何更新都将始终被您的修改版（可能已过时）覆盖。您可以查看每个情境的“情境控制”标签以获取详细信息。如果您不知道自己方面有任何“情境控制”修改，并且只想恢复*所有*情境的原始控制设置，请点击此按钮："
L["Restore all stock Situation Controls"] = "恢复所有原始情境控制"
L["Hello and welcome to DynamicCam!"] = "您好，欢迎使用 DynamicCam！"
L["Profiles"] = "配置文件"
L["Manage Profiles"] = "管理配置文件"
L["<manageProfilesWarning>"] = "像许多插件一样，DynamicCam 使用“AceDB-3.0”库来管理配置文件。您必须理解的是，这里没有“保存配置文件”之类的东西。您只能创建新配置文件，并且可以将设置从另一个配置文件复制到当前激活的配置文件中。无论您对当前激活的配置文件进行什么更改，都会立即保存！没有“取消”或“放弃更改”之类的东西。“重置配置文件”按钮仅重置为全局默认配置文件。\n\n因此，如果您喜欢您的 DynamicCam 设置，您应该创建另一个配置文件，将这些设置复制进去作为备份。当您不使用此备份配置文件作为活动配置文件时，您可以试验设置，并通过在“复制自”框中选择您的备份配置文件，随时返回到您的原始配置文件。\n\n如果您想通过宏切换配置文件，可以使用以下命令：\n/run DynamicCam.db:SetProfile(\"此处填写配置文件名称\")\n\n"
L["Profile presets"] = "配置文件预设"
L["Import / Export"] = "导入 / 导出"
L["DynamicCam"] = "DynamicCam"
L["Disabled"] = "已禁用"
L["Your DynamicCam addon lets you adjust horizontal and vertical mouse look speed individually! Just go to the \"Mouse Look\" settings of DynamicCam to make the adjustments there."] = "您的 DynamicCam 插件允许您分别调整水平和垂直鼠标观察速度！只需转到 DynamicCam 的“鼠标观察”设置即可在那里进行调整。"
L["Attention"] = "注意"
L["The \"%s\" setting is disabled by DynamicCam, while you are using the horizontal camera over shoulder offset."] = "DynamicCam 禁用了“%s”设置，因为您正在使用水平镜头肩部偏移。"
L["While you are using horizontal camera offset, DynamicCam prevents CameraKeepCharacterCentered!"] = "当您使用水平镜头偏移时，DynamicCam 会阻止 CameraKeepCharacterCentered！"
L["While you are using horizontal camera offset, DynamicCam prevents CameraReduceUnexpectedMovement!"] = "当您使用水平镜头偏移时，DynamicCam 会阻止 CameraReduceUnexpectedMovement！"
L["While you are using vertical camera pitch, DynamicCam prevents CameraKeepCharacterCentered!"] = "当您使用垂直镜头俯仰时，DynamicCam 会阻止 CameraKeepCharacterCentered！"
L["cameraView=%s prevented by DynamicCam!"] = "cameraView=%s 被 DynamicCam 阻止！"

-- MouseZoom
L["Current\nZoom\nValue"] = "当前\n缩放\n值"
L["Reactive\nZoom\nTarget"] = "响应\n缩放\n目标"

-- Core
L["Enter name for custom situation:"] = "输入自定义情境的名称："
L["Create"] = "创建"
L["Cancel"] = "取消"

-- DefaultSettings
L["City"] = "城市"
L["City (Indoors)"] = "城市（室内）"
L["World"] = "世界"
L["World (Indoors)"] = "世界（室内）"
L["World (Combat)"] = "世界（战斗）"
L["Dungeon/Scenario"] = "地下城/场景战役"
L["Dungeon/Scenario (Outdoors)"] = "地下城/场景战役（户外）"
L["Dungeon/Scenario (Combat, Boss)"] = "地下城/场景战役（战斗，首领）"
L["Dungeon/Scenario (Combat, Trash)"] = "地下城/场景战役（战斗，小怪）"
L["Raid"] = "团队副本"
L["Raid (Outdoors)"] = "团队副本（户外）"
L["Raid (Combat, Boss)"] = "团队副本（战斗，首领）"
L["Raid (Combat, Trash)"] = "团队副本（战斗，小怪）"
L["Arena"] = "竞技场"
L["Arena (Combat)"] = "竞技场（战斗）"
L["Battleground"] = "战场"
L["Battleground (Combat)"] = "战场（战斗）"
L["Mounted (any)"] = "骑乘（任意）"
L["Mounted (only flying-mount)"] = "骑乘（仅限飞行坐骑）"
L["Mounted (only flying-mount + airborne)"] = "骑乘（仅限飞行坐骑 + 空中）"
L["Mounted (only flying-mount + airborne + Skyriding)"] = "骑乘（仅限飞行坐骑 + 空中 + 驭空术）"
L["Mounted (only flying-mount + Skyriding)"] = "骑乘（仅限飞行坐骑 + 驭空术）"
L["Mounted (only airborne)"] = "骑乘（仅限空中）"
L["Mounted (only airborne + Skyriding)"] = "骑乘（仅限空中 + 驭空术）"
L["Mounted (only Skyriding)"] = "骑乘（仅限驭空术）"
L["Druid Travel Form"] = "德鲁伊旅行形态"
L["Dracthyr Soar"] = "龙希尔翱翔"
L["Skyriding Race"] = "驭空术竞速"
L["Taxi"] = "飞行路线"
L["Vehicle"] = "载具"
L["Hearth/Teleport"] = "炉石/传送"
L["Annoying Spells"] = "恼人的法术"
L["NPC Interaction"] = "NPC 互动"
L["Mailbox"] = "邮箱"
L["Fishing"] = "钓鱼"
L["Gathering"] = "采集"
L["AFK"] = "暂离"
L["Pet Battle"] = "宠物对战"
L["Professions Frame Open"] = "专业窗口打开"
