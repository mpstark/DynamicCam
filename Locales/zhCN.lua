local L = LibStub("AceLocale-3.0"):NewLocale("DynamicCam", "zhCN")
if not L then return end

-- Options
L["Reset"] = "重置"
L["Reset to global default:"] = "重置为全局默认值："
L["(To restore the settings of a specific profile, restore the profile in the \"Profiles\" tab.)"] = "（要恢复为特定配置文件的设置，请在“配置文件”标签页中选择该配置文件后操作。）"
L["Currently overridden by the active situation \""] = "当前设置为情境： \""
L["Override Standard Settings"] = "覆盖标准情境"
L["<overrideStandardToggle_desc>"] = "勾选这个复选框，允许你在激活当前情境时，覆盖标准情境。取消勾选将删除此类型的情境设置。"
L["Custom:"] = "自定义："
L["(modified)"] = "(已修改)"
L["Priority:"] = "优先级："
L["Standard Settings"] = "标准设置"
L["Situation Settings"] = "情境设置"
L["<standardSettings_desc>"] = "当没有任何情境处于激活状态，或者激活的情境没有设置覆盖标准设置的情境设置时，将应用这些标准设置。"
L["<standardSettingsOverridden_desc>"] = "绿色的类型表示目前被激活的情境覆盖。因此，在覆盖情境激活时，绿色类型的标准设置不会生效。"
L["These Situation Settings can override the Standard Settings when the respective situation is active."] = "当相应的情境激活时，这些情境设置将覆盖标准设置。"
L["Mouse Zoom"] = "鼠标缩放"
L["Maximum Camera Distance"] = "最大镜头距离"
L["How many yards the camera can zoom away from your character."] = "镜头镜头可以从你的角色拉远多少码的距离。"
L["Camera Zoom Speed"] = "镜头缩放速度"
L["How fast the camera can zoom."] = "镜头镜头缩放的速度。"
L["Zoom Increments"] = "镜头缩放增量"
L["How many yards the camera should travel for each \"tick\" of the mouse wheel."] = "每次鼠标滚轮镜头应该移动多少码。"
L["Use Reactive Zoom"] = "使用响应缩放"
L["Quick-Zoom Additional Increments"] = "快速缩放额外增量"
L["How many yards per mouse wheel tick should be added when quick-zooming."] = "当快速缩放时，每次鼠标滚轮滚动应该增加多少码。"
L["Quick-Zoom Enter Threshold"] = "快速缩放阈值"
L["How many yards the \"Reactive Zoom Target\" and the \"Actual Zoom Value\" have to be apart to enter quick-zooming."] = "\"响应缩放目标\"与\"实际缩放值\"之间至少需要多少码的距离，才能触发快速缩放功能。"
L["Maximum Zoom Time"] = "最大缩放时间"
L["The maximum time the camera should take to make \"Actual Zoom Value\" equal to \"Reactive Zoom Target\"."] = "镜头会在这个时间内将\"实际缩放值\"调整到\"响应缩放目标\"。"
L["Help"] = "帮助"
L["Toggle Visual Aid"] = "视觉辅助开关"
L["<reactiveZoom_desc>"] = "使用 DynamicCam 的响应缩放功能，鼠标滚轮控制\"响应缩放目标\"。每当\"响应缩放目标\"与\"实际缩放值\"不同时，DynamicCam 会改变\"实际缩放值\"，直到他再次与\"响应缩放目标\"相同。\n\n这种缩放变化的速度取决于\"镜头缩放速度\"和 \"最大缩放时间\"。如果\"最大缩放时间\"设置的比较短，无论\"镜头缩放速度\"如何设置，缩放总会很快执行。要实现舒缓的缩放变化，你必须将\"最大缩放时间\"设置得更长，同时把\"镜头缩放速度\"设置为较低的值。\n\n为了实现随着鼠标滚轮快速滚动更快地缩放镜头，请使用\"快速缩放功能\"：如果\"响应缩放目标\"与\"实际缩放值\"的偏差超过了\"快速缩放阈值\"，每次鼠标滚轮的滚动都会增加\"快速缩放额外增量\"。\n\n为了感受这些功能是如何工作的，你可以在寻找合适设置的同时，开启视觉辅助。你也可以通过左键拖弋操作来自动移动这个图表。右键点击可以关闭它。"
L["Enhanced minimal zoom-in"] = "强化最小视角"
L["<enhancedMinZoom_desc>"] = "响应缩放允许你把镜头放大到比最近还近。你可以通过在第一人称视角时再次滚动鼠标实现这一点。\n\n启用\"强化最小视角\"后，我们会强制镜头在放大时也停留在这个视角上，而不是立即切换回第一人称视角。你也可以把此理解为\"狙击模式\"。\n\n|cFFFF0000启用\"强化最小视角\"可能会在CPU受限的情境下导致帧率下降15%。|r"
L["/reload of the UI required!"] = "需要使用 /reload 重载界面！"
L["Mouse Look"] = "鼠标视角"
L["Horizontal Speed"] = "水平速度"
L["How much the camera yaws horizontally when in mouse look mode."] = "在鼠标视角模式下，镜头的水平移动速度是多少。"
L["Vertical Speed"] = "垂直速度"
L["How much the camera pitches vertically when in mouse look mode."] = "鼠标视角模式下，镜头的垂直移动速度是多少。"
L["<mouseLook_desc>"] = "当你在\"鼠标视角\"模式下移动鼠标时，镜头移动的幅度。\n\n在《魔兽世界》的默认界面设置中，\"鼠标视角移动速度\"滑块同时控制水平和垂直速度，并且自动将水平速度设置为垂直速度的2倍。DynamicCam 覆盖了这一设置，允许你进行更加个性化的设置。"
L["Horizontal Offset"] = "水平偏移"
L["Camera Over Shoulder Offset"] = "越肩视角偏移"
L["Positions the camera left or right from your character."] = "调整镜头在角色左侧或者右侧的位置。"
L["<cameraOverShoulder_desc>"] = "要使这个设置生效，DynamicCam 会自动临时禁用游戏中的晕动症设置。因此，如果你需要使用晕动症设置，请不要使用水平偏移。\n\n当你选中自己的角色时，《魔兽世界》会自动切换到偏移量为0。我们无法对此进行更改。我们也无法解决镜头和墙壁发生碰撞时可能出现的偏移抖动问题。一个可能的解决方法是在室内时使用很小或不使用偏移。\n\n此外，《魔兽世界》会根据玩家模型或坐骑不同，奇怪地应用不同的偏移量。如果你希望有一个恒定的偏移量，Ludius（插件开发者）正在开发另一个插件 CameraOverShoulder 来解决这个问题。"
L["Adjust shoulder offset according to zoom level"] = "根据缩放调整越肩偏移"
L["Enable"] = "启用"
L["Reset to global defaults:"] = "重置为全局默认值："
L["and"] = "和"
L["(To restore the settings of a specific profile, restore the profile in the \"Profiles\" tab.)"] = "（要恢复特定配置文件的设置，请在“配置文件”标签中恢复该配置文件。）"
L["No offset when below this zoom level:"] = "当缩放级别低于此值时无偏移："
L["When the camera is closer than this zoom level, the offset has reached zero."] = "当镜头比此缩放级别更近时，偏移量已达到零。"
L["Real offset when above this zoom level:"] = "当缩放级别高于此值时的真实偏移："
L["When the camera is further away than this zoom level, the offset has reached its set value."] = "当镜头比此缩放级别更远时，偏移量已达到其设定值。"
L["<shoulderOffsetZoom_desc>"] = "在缩放时使肩部偏移量逐渐过渡到零。两个滑块定义了此过渡发生的缩放级别范围。此设置是全局的，不特定于情境。"
L["Vertical Pitch"] = "垂直俯仰"
L["Pitch (on ground)"] = "俯仰（在地面上）"
L["Pitch (flying)"] = "俯仰（飞行中）"
L["Down Scale"] = "向下缩放"
L["Smart Pivot Cutoff Distance"] = "智能转动停止距离"
L["<pitch_desc>"] = "如果镜头向上俯仰（“俯仰”值较低），“向下缩放”设置决定了在从上方看角色时这种效果的影响程度。将“向下缩放”设置为0可以抵消从上方看时向上俯仰的效果。相反，当你不是从上方看，或者如果镜头向下俯仰（“俯仰”值较大）时，“向下缩放”设置几乎没有效果。\n\n因此，你应该首先找到从背后看你角色时喜欢的“俯仰”设置。之后，如果你选择了向上俯仰，从上方看时找到你喜欢“向下缩放”设置。\n\n当镜头与地面碰撞时，它通常会在镜头到地面碰撞点进行向上俯仰。另一种选择是镜头在执行这种俯仰时更靠近角色的脚。“智能转动截止距离”设置决定了镜头必须在多远的距离内才能执行后者。将其设置为0则从不移动镜头（WoW的默认设置），而将其设置为最大缩放距离39则总是移动镜头。\n\n"
L["Target Focus"] = "目标焦点"
L["Enemy Target"] = "敌方目标"
L["Horizontal Strength"] = "水平强度"
L["Vertical Strength"] = "垂直强度"
L["Interaction Target (NPCs)"] = "交互目标（NPC）"
L["<targetFocus_desc>"] = "如果启用，镜头会自动尝试将目标拉近屏幕中心。强度决定了这种效果的强度。\n\n如果“敌方目标焦点”和“交互目标焦点”都启用，后者似乎有一个奇怪的错误：当首次与NPC交互时，镜头会像预期的那样平滑移动到新角度。但是当你退出交互时，它会立即跳转到之前的角度。然后当你再次开始交互时，它再次跳转到新角度。这在与新NPC交谈时是可重复的：只有第一次过渡是平滑的，所有后续的都是立即的。\n如果你想要同时使用“敌方目标焦点”和“交互目标焦点”，一个变通方法是只在需要它且不太可能发生NPC交互的DynamicCam情境下激活“敌方目标焦点”（比如战斗）。"
L["Head Tracking"] = "头部追踪"
L["<headTrackingEnable_desc>"] = "（这也可以作为一个0到1之间的连续值，但它只是分别乘以站立强度和移动强度。所以真的不需要另一个滑块。）"
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
L["(slider value devided by 10)"] = "（滑块值 / 10）"
L["Requires /reload to come into effect!"] = "需要/reload才能生效！"
L["<headTracking_desc>"] = "启用头部追踪后，镜头会跟随角色头部的移动。（虽然这可能有助于沉浸感，但如果你对晕动症敏感，也可能导致恶心。）\n\n“强度”设置决定了这种效果的强度。将其设置为0可以禁用头部追踪。“惯性”设置决定了镜头对头部移动的反应速度。将其设置为0也可以禁用头部追踪。“站立”、“移动”和“第一人称”三种情境可以单独设置。“第一人称”没有“强度”设置，因为它分别假设“站立”和“移动”的“强度”设置。如果你想单独启用或禁用“第一人称”，请使用“惯性”滑块来禁用不需要的情境。\n\n“范围缩放”设置可以设置超过此镜头距离时减少或禁用头部追踪。例如，将滑块设置为30，当镜头距离角色超过30码时，将没有头部追踪。但是，从完全头部追踪到没有头部追踪有一个逐渐过渡，从滑块值的三分之一开始。例如，将滑块值设置为30，当镜头距离小于10码时，有完全头部追踪。超过10码时，头部追踪逐渐减少，直到在30码外完全消失。因此，滑块的最大值是117，允许在最大镜头距离39码时有完全头部追踪。（提示：使用我们的“鼠标缩放”视觉辅助工具在设置时检查当前镜头距离。）\n\n“死区”设置可以用来忽略较小的头部移动。将其设置为0可以让镜头跟随每一个微小的头部移动，而将其设置为更大的值则只跟随较大的移动。请注意，更改此设置只有在重新加载UI（在控制台中输入/reload）后才生效。"
L["Situations"] = "情境"
L["Select a situation to setup"] = "选择一个情境来设置"
L["<selectedSituation_desc>"] = "\n|cffffcc00颜色代码：|r\n|cFF808A87- 禁用的情境。|r\n- 启用的情境。\n|cFF00FF00- 启用且当前激活的情境。|r\n|cFF63B8FF- 启用且条件满足但优先级低于当前激活情境的情境。|r\n|cFFFF6600- 修改过的预设“情境控制”（建议重置）。|r\n|cFFEE0000- 错误的“情境控制”（需要更改）。|r"
L["If this box is checked, DynamicCam will enter the situation \""] = "如果勾选此框，DynamicCam 将进入情境 \""
L["\" whenever its condition is fulfilled and no other situation with higher priority is active."] = "\" 只要其条件满足，并且没有其他优先级更高的情境处于激活状态。"
L["Delete custom situation \""] = "删除自定义情境 \"" 
L["\".\n(There will be no 'Are you sure?' prompt!)"] = "\"。\n（不会有'你确定吗？'的提示！）"
L["Create a new custom situation."] = "创建一个新的自定义情境。"
L["Situation Actions"] = "情境指令"
L["Setup stuff to happen while in a situation or when entering/exiting it."] = "设置在情境中或进入/退出时要执行的操作。"
L["Zoom/View"] = "缩放/视角"
L["Zoom to a certain zoom level or switch to a saved camera view when entering this situation."] = "在进入这个情境时，调整到特定的缩放级别或切换到保存的镜头视角。"
L["Reset to global defaults!\n(To restore the settings of a specific profile, restore the profile in the \"Profiles\" tab.)"] = "重置为全局默认值！\n（要恢复特定配置文件的设置，请在“配置文件”选项卡中恢复配置文件。）"
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
L["cameraSmoothNote"] = [[|cFFEE0000注意：|r 您正在使用WoW的“镜头跟随风格”，它会自动将镜头放置在玩家后面。这在您处于自定义视角时不起作用。您可以在不需要镜头跟随的情境中使用自定义保存视角（例如，NPC互动）。但在退出情境后，您必须返回到非自定义的默认视角，以便再次使镜头跟随工作。]]
L["Restore to default view:"] = "恢复为默认视角："
L["<viewRestoreToDefault_desc>"] = [[选择退出此情境时返回的默认视角。

视角1：缩放0，俯仰0
视角2：缩放5.5，俯仰10
视角3：缩放5.5，俯仰20
视角4：缩放13.8，俯仰30
视角5：缩放13.8，俯仰10]]
L["WARNING"] = "警告"
L["You are using the same view as saved view and as restore-to-default view. Using a view as restore-to-default view will reset it. Only do this if you really want to use it as a non-customized saved view."] = "您正在使用相同的视角作为保存视角和恢复为默认视角。用作恢复为默认视角将会重置它。只有在您确实想将其用作非自定义保存视角时才这样做。"
L["is used as saved view in the situations:"] = "在以下情境中被用作保存视角："
L["and as restore-to-default view in the situations:"] = "并且在以下情境中被用作默认视角："
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
L["Zoom out to this zoom level, if the current zoom level is less than this."] = "如果当前缩放级别小于此值，则缩小到这个缩放级别。"
L["Zoom Max"] = "最大缩放"
L["Zoom in to this zoom level, if the current zoom level is greater than this."] = "如果当前缩放级别大于此值，则放大到这个缩放级别。"
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
L["Reset to global defaults!\n(To restore the settings of a specific profile, restore the profile in the \"Profiles\" tab.)"] = "重置为全局默认值！\n（要恢复特定配置文件的设置，请在“配置文件”选项卡中恢复配置文件。）"
L["Rotation Type"] = "转动方式"
L["<rotationType_desc>"] = "\n持续转动：当此情境激活时，镜头会持续水平转动。这只建议用于不使用鼠标移动摄像机的情况；例如，传送法术施放、飞行或离开。无法持续垂直转动，因为它会在向上或向下垂直视角时停止。\n\n按度数转动：进入情境后，根据给定的度数改变当前摄像机的水平偏转（yaw）和/或垂直俯仰（pitch）。"
L["Continuously"] = "持续转动"
L["By Degrees"] = "按角度转动"
L["Acceleration Time"] = "加速时间"
L["Rotation Time"] = "转动时间"
L["<accelerationTime_desc>"] = "如果您在这里设置的时间大于0，持续转动不会立即以全速开始，而是会花费这段时间来加速。（只有在相对较高的转动速度下才会明显感知。）"
L["<rotationTime_desc>"] = "需要多长时间来调整到新的摄像机角度。如果这里给出的值太小，摄像机可能会转动过头，因为我们每渲染一帧时只检查一次是否达到了期望的角度。\n\n如果某个情境在其进入脚本中分配了变量“this.rotationTime”（参见“情境控制”），这里的设置将被覆盖。例如，在“炉石/传送”情境中这样做，以便为施法时间内塞入一个转动时间。"
L["Rotation Speed"] = "转动速度"
L["Speed at which to rotate in degrees per second. You can manually enter values between -900 and 900, if you want to get yourself really dizzy..."] = "每秒转动的度数。如果您想让自己真的头晕目眩，可以手动输入-900到900之间的值..."
L["Yaw (-Left/Right+)"] = "偏转（-左/右+）"
L["Degrees to yaw (left or right)."] = "偏转的度数（左或右）。"
L["Pitch (-Down/Up+)"] = "俯仰（-下/上+）"
L["Degrees to pitch (up or down). There is no going beyond the perpendicular upwards or downwards view."] = "俯仰的度数（上或下）。无法超过向上或向下的垂直视角。"
L["Rotate Back"] = "转动返回"
L["<rotateBack_desc>"] = "退出情境时，按进入情境后转动的度数（360）反向转动。这实际上会将您带回进入前的摄像机位置，除非您在此过程中用鼠标改变了视角。\n\n如果您正在进入一个自带转动设置的新情境，那么退出情境的“转动返回”将被忽略。"
L["Rotate Back Time"] = "转动返回时间"
L["<rotateBackTime_desc>"] = "转动返回所需的时间。如果这里给出的值太小，摄像机可能会转动过头，因为我们每渲染一帧时只检查一次是否达到了期望的角度。"
L["Fade Out UI"] = "渐隐界面"
L["Fade out or hide (parts of) the UI when this situation is active."] = "当此情境激活时，渐隐或隐藏（部分）用户界面。"
L["Reset to global defaults!\n(To restore the settings of a specific profile, restore the profile in the \"Profiles\" tab.)"] = "重置为全局默认值！\n（要恢复特定配置文件的设置，请在“配置文件”选项卡中恢复配置文件。）"
L["Adjust to Immersion"] = "调整以适应沉浸"
L["<adjustToImmersion_desc>"] = "许多人将Immersion插件与DynamicCam结合使用。Immersion在NPC互动期间有一些自己的隐藏UI特性。在某些情况下，DynamicCam的隐藏界面会覆盖Immersion的设置。为了防止这种情况，您可以在DynamicCam中进行所需的设置。点击此按钮使用与Immersion相同的渐显和渐隐时间。想要更多选项，请查看Ludius的另一个插件“Immersion ExtraFade”。"
L["Fade Out Time"] = "渐隐时间"
L["Seconds it takes to fade out the UI when entering the situation."] = "进入情境时，界面渐隐所需的秒数。"
L["Fade In Time"] = "渐显时间"
L["<fadeInTime_desc>"] = "退出情境时，UI渐隐所需的秒数。\n\n当您在进入另一个情境的同时退出一个情境时，进入情境的渐隐时间将用于过渡。"
L["Hide entire UI"] = "隐藏整个界面"
L["<hideEntireUI_desc>"] = "“隐藏”的界面和“只是渐隐”的界面之间有区别：“渐隐”的界面元素的不透明度为0，但仍然可以与之交互。从DynamicCam 2.0开始，如果界面元素的不透明度为0，我们会自动隐藏大多数界面元素。因此，渐隐后隐藏整个界面的选项更像是一个遗留物。仍然使用它的原因可能是为了避免不希望的交互（例如鼠标悬停提示）DynamicCam仍然没有正确隐藏的界面元素。\n\n隐藏界面的不透明度当然是0，所以你不能选择不同的不透明度，也不能保留任何界面元素可见（除了FPS指示器）。\n\n在战斗中我们不能改变受保护的界面元素的隐藏状态。"
L["Keep FPS indicator"] = "保留FPS指示器"
L["Do not fade out or hide the FPS indicator (the one you typically toggle with Ctrl + R)."] = "不要渐隐或隐藏FPS指示器（通常用 Ctrl+R 切换的那个）。"
L["Fade Opacity"] = "渐隐不透明度"
L["Fade the UI to this opacity when entering the situation."] = "进入情境时将用户界面渐隐到这种不透明度。"
L["Excluded UI elements"] = "排除的用户界面元素"
L["Keep Alerts"] = "保留警告"
L["Still show alert popups from completed achievements, Covenant Renown, etc."] = "仍然显示来自完成成就、盟约声望等的警告弹出窗口。"
L["Keep Tooltip"] = "保留提示"
L["Still show the game tooltip, which appears when you hover your mouse cursor over UI or world elements."] = "仍然显示游戏提示，当你将鼠标光标悬停在用户界面或世界元素上时出现。"
L["Keep Minimap"] = "保留小地图"
L["<keepMinimap_desc>"] = "不要渐隐小地图。\n\n请注意，我们不能减少小地图上“光点”的不透明度。当用户界面渐隐到0不透明度时，这些只能与整个小地图一起隐藏。"
L["Keep Chat Box"] = "保留聊天框"
L["Do not fade out the chat box."] = "不要渐隐聊天框。"
L["Keep Tracking Bar"] = "保留追踪条"
L["Do not fade out the tracking bar (XP, AP, reputation)."] = "不要渐隐追踪条（经验值、能力点、声望）。"
L["Keep Party/Raid"] = "保留小队/团队框架"
L["Do not fade out the Party/Raid frame."] = "不要渐隐小队/团队框架"
L["Keep Encounter Frame (Dragonriding Vigor)"] = "保留遭遇框架（驭空术条）"
L["Do not fade out the Encounter Frame, which while dragonriding is the Vigor display."] = "不要渐隐遭遇框架，在驭空术时是能量显示。"
L["Keep additional frames"] = "保留额外框架"
L["<keepCustomFrames_desc>"] = "下面的文本框允许你定义在NPC交互期间想要保留的任何框架。\n\n使用控制台命令/fstack来了解框架的名称。\n\n例如，你可能想要保留小地图旁边的增益图标，以便在NPC交互期间通过点击适当的图标来取消骑乘。"
L["Custom frames to keep"] = "自定义保留框架"
L["Separated by commas."] = "用逗号分隔。"
L["Emergency Fade In"] = "紧急渐显"
L["Pressing Esc fades the UI back in."] = "按下Esc键将用户界面渐显回来。"
L["<emergencyShow_desc>"] = [[有时你可能希望在常态隐藏界面的情况下显示界面。在旧版本的 DynamicCam 中有个规则，允许你在按下ESC键时显示界面。但这样做有个缺点，当ESC键用于其他作用，比如关闭窗口、取消施法等时，界面也会显示。取消勾选上面的复选框可以禁用此功能。

但请注意，这样可能会导致无法访问界面！ESC键更好的替代方案是使用以下的控制台命令，它们会根据当前设置的“渐隐界面”设置显示或隐藏界面：

    /showUI
    /hideUI

为了更加快捷的实现渐隐界面，将 /showUI 放入宏命令中，并在"bindings-cache.wtf"文件中为其分配一个按键。例如：

    bind ALT+F11 MACRO 你的宏名称

如果你不想编辑"bindings-cache.wtf"文件，可以使用类似"BindPad"这样的按键绑定插件。

使用 /showUI 或者 /hideUI 而不带任何参数将采用当前情境的渐显和渐隐时间。但你也可以使用参数提供不同的过渡时间。例如：

    /showUI 0

来实现立即显示界面，没有任何延迟。]]
L["<hideUIHelp_desc>"] = "在设置你期望的界面渐隐效果时，如果这个“界面”设置框也一起渐隐，可能会很烦人。如果选中这个框，它将不会被渐隐。\n\n此设置适用于所有情况。"
L["Do not fade out this \"Interface\" settings frame."] = "不要渐隐这个“界面”设置框。"
L["Situation Controls"] = "情境控制"
L["<situationControls_help>"] = "在这里，你控制何时激活一个情境。可能需要了解WoW UI API。如果你对DynamicCam的默认情况感到满意，只需忽略此部分。但如果你想创建自定义情况，可以在这里检查默认情境。你也可以修改它们，但请注意：即使DynamicCam的未来版本引入了重要更新，你更改的设置也会保留。\n\n"
L["Priority"] = "优先级"
L["The priority of this situation.\nMust be a number."] = "此情境的优先级。\n必须是一个数字。"
L["Restore stock setting"] = "恢复默认设置"
L["Your \"Priority\" deviates from the stock setting for this situation ("] = "你的“优先级”与此情境的默认设置不符（"
L["). Click here to restore it."] = "）。点击这里恢复它。"
L["<priority_desc>"] = "如果多个不同的DynamicCam情境的条件同时满足，将进入优先级最高的情境。例如，每当“世界室内”的条件满足时，“世界”的条件也会满足。但由于“世界室内”的优先级高于“世界”，因此会优先选择。你还可以在上方的下拉菜单中看到所有情境的优先级。\n\n"
L["Error message:"] = "错误信息："
L["Events"] = "事件"
L["Separated by commas."] = "用逗号分隔。"
L["Your \"Events\" deviate from the default for this situation. Click here to restore them."] = "你的“事件”与此情境的默认设置不同。点击这里恢复它们。"
L["<events_desc>"] = [[在这里，你可以定义所有游戏中的事件，DynamicCam应该检查这些事件的条件，以确定是否进入或退出当前情境。

你可以通过WoW的事件日志了解游戏中的事件。
要打开它，请在控制台中输入以下命令：

  /eventtrace

所有可能的事件列表也可以在这里找到：
https://warcraft.wiki.gg/wiki/Events

]]
L["Initialisation"] = "初始化"
L["Initialisation Script"] = "初始化脚本"
L["Lua code using the WoW UI API."] = "使用WoW UI API的Lua代码。"
L["Your \"Initialisation Script\" deviates from the stock setting for this situation. Click here to restore it."] = "你的“初始化脚本”与此情境的默认设置不同。点击这里恢复它。"
L["<initialisation_desc>"] = [[一个情境的初始化脚本在 DynamicCam 加载时（以及情境被修改时）运行一次。你通常会在其中放入你希望在其他任何脚本（条件、进入、退出）中应用的内容。这可以使这些脚本更短一些。

例如，“炉石/传送”情境的初始化脚本定义了表格“this.spells”，其中包含了传送法术的法术ID。然后，条件脚本每次执行时都可以简单地访问“this.spells”。

像这个例子一样，你可以通过将数据对象放入“this”表格中，在情境的脚本之间共享任何数据对象。

]]
L["Condition"] = "条件"
L["Condition Script"] = "条件脚本"
L["Lua code using the WoW UI API.\nShould return \"true\" if and only if the situation should be active."] = "使用WoW UI API的Lua代码。\n只有在情境应该激活时才返回“true”。"
L["Your \"Condition Script\" deviates from the stock setting for this situation. Click here to restore it."] = "你的“条件脚本”与此情境的默认设置不同。点击这里恢复它。"
L["<condition_desc>"] = [[条件脚本在每次触发此情境的游戏内事件时运行。如果且仅当此情境应该处于活动状态时，脚本应返回“true”。

例如，“城市”情境的条件脚本使用WoW API函数“IsResting()”来检查你是否目前在休息区域：

  return IsResting()

同样，“城市-室内”情境的条件脚本也使用WoW API函数“IsIndoors()”来检查你是否在室内：

  return IsResting() and IsIndoors()

可以在此处找到WoW API函数的列表：
https://warcraft.wiki.gg/wiki/World_of_Warcraft_API

]]
L["Entering"] = "进入时"
L["On-Enter Script"] = "进入时脚本"
L["Your \"On-Enter Script\" deviates from the stock setting for this situation. Click here to restore it."] = "你的“进入时脚本”与此情境的默认设置不同。点击此处恢复默认设置。"
L["<executeOnEnter_desc>"] = [[情境带有的进入时脚本在每次进入该情境时执行。

这方面的例子是“炉石/传送”情境，我们使用WoW API函数"UnitCastingInfo()"来确定当前施法的持续时间。然后我们将这个值赋给变量"this.transitionTime"和"this.rotationTime"，这样缩放或转动（见“情境指令”）可以精确地与施法时间一样长。（不是所有传送法术的施法时间都相同。）

]]
L["Exiting"] = "退出时"
L["On-Exit Script"] = "退出时脚本"
L["Your \"On-Exit Script\" deviates from the stock setting for this situation. Click here to restore it."] = "你的“退出时脚本”与此情境的默认设置不同。点击此处恢复默认设置。"
L["Exit Delay"] = "退出延迟"
L["Wait for this many seconds before exiting this situation."] = "在退出此情境前等待多少秒。"
L["Your \"Exit Delay\" deviates from the stock setting for this situation. Click here to restore it."] = "你的“退出延迟”与此情境的默认设置不同。点击此处恢复默认设置。"
L["<executeOnEnter_desc>"] = [[情境带有的退出时脚本在每次退出该情境时运行。到目前为止，还没有情境使用这个功能。

延迟决定了在退出情境前需要等待多少秒。目前，唯一的例子是“钓鱼”情境，其中的延迟给你时间重新抛出鱼竿，而不会退出该情境。

]]
L["Export"] = "导出"
L["Coming soon(TM)."] = "即将推出。"
L["Import"] = "导入"
L["<welcomeMessage>"] = [[我们很高兴你来到这里，并希望你能享受这个插件带来的乐趣。

DynamicCam（DC）由mpstark于2016年5月开始开发，当时暴雪的魔兽世界开发团队引入了实验性的ActionCam功能。DC的主要目的是为用户提供ActionCam设置的用户界面。在游戏内，ActionCam仍被标记为“实验性”，并且没有迹象表明暴雪会进一步开发它。 虽然存在一些不足，但我们应该感激ActionCam被保留在游戏中，让我们这些爱好者能够使用。:-) DC不仅允许你更改ActionCam设置，还能够根据不同的游戏情况设置不同的设置。与ActionCam无关，DC还提供了关于镜头缩放和界面渐隐的功能。

mpstark对DC的工作一直持续到2018年8月。虽然大多数功能对大量用户都运作良好，但mpstark一直认为DC处于测试阶段，由于他对WoW的兴趣逐渐减退，最终没有恢复工作。那时，Ludius已经开始为自己调整DC，这被Weston（aka dernPerkins）注意到，他在2020年初设法联系到mpstark，牵头让Ludius接管了开发工作。第一个非测试版本1.0于2020年5月发布，包括了Ludius到那时为止的调整。之后，Ludius开始对DC进行大修，使得2.0版本在2022年秋季发布。

在mpstark初始开发DC时，他的重点是使大多数自定义设置都能在游戏内完成，而不需要更改源代码。这使得在不同的游戏情境下进行实验变得更加容易。从2.0版本开始，这些高级设置已经被移到一个名为“情境控制”的特殊部分。大多数用户可能永远也不需要它，但对于“高级用户”来说，它仍然可用。在那里进行更改的风险是，保存的用户设置总是覆盖DC的默认设置，即使新版本的DC带来了更新的默认设置。因此，每当你激活的情境有修改过的“情境控制”时，本页面顶部会显示一个警告。

如果你认为DC的某个默认情境应该被修改，你可以随时创建一个带有你个人色彩的副本。欢迎导出这个新情境并在DC的curseforge页面上发布。我们可能会将其添加为一个新的默认情境。你也可以导出并发布你的整个DC配置文件，因为我们总是在寻找新的配置预设，这可以让新用户更容易地开始使用DC。如果你发现问题或想要提出建议，请在curseforge评论中留言，当然更好的是使用GitHub上的Issues。如果你想贡献代码，也欢迎在那里打开一个拉取请求。

以下是一些方便的命令：

    `/dynamiccam` 或 `/dc` 打开这个页面。
    `/zoominfo` 或 `/zi` 输出当前的缩放级别。

    `/zoom #1 #2` 在 #2 秒内缩放到 #1 缩放级别。
    `/yaw #1 #2` 在 #2 秒内使镜头偏转 #1 度（负 #1 偏航到右边）。
    `/pitch #1 #2` 使镜头俯仰 #1 度（负 #1 向上俯仰）。


]]
L["About"] = "关于"
L["The following game situations have \"Situation Controls\" deviating from DynamicCam's stock settings.\n\n"] = "以下游戏情境的“情境控制”与DynamicCam的默认设置不同。\n\n"
L["<situationControlsWarning>"] = "\n如果你是刻意为之的，那没有问题。只是要注意，DynamicCam开发者对这些设置的任何更新总是会被你修改过的（可能过时的）版本覆盖。你可以查看每种情境的“情境控制”标签以获取详细信息。如果你没有意识到任何来自你的“情境控制”修改，并且只是想恢复所有情境的默认控制设置，请点击这个按钮："
L["Restore all stock Situation Controls"] = "恢复所有默认情境控制"
L["Hello and welcome to DynamicCam!"] = "你好，欢迎来到DynamicCam！"
L["Profiles"] = "配置文件"
L["Manage Profiles"] = "管理配置文件"
L["<manageProfilesWarning>"] = "像许多插件一样，DynamicCam使用“AceDB-3.0”库来管理配置文件。你需要明白的是，这里没有“保存配置文件”这样的操作。你只能创建新的配置文件，并且你可以从另一个配置文件复制设置到当前激活的配置文件中。你对当前激活的配置文件所做的任何更改都会立即保存！这里没有“取消”或“放弃更改”的操作。“重置配置文件”按钮只会重置为全局默认配置文件。\n\n所以如果你喜欢你的DynamicCam设置，你应该创建另一个配置文件，并将这些设置复制进去作为备份。当你不使用这个备份配置文件作为你的激活配置文件时，你可以随意尝试更改设置，并随时通过在“从...复制”框中选择你的备份配置文件来恢复到你原来的配置文件。\n\n如果你想通过宏来切换配置文件，你可以使用以下代码：\n/run DynamicCam.db:SetProfile(\"配置文件名\")\n\n"
L["Profile presets"] = "预设配置文件"
L["Import / Export"] = "导入/导出"
L["DynamicCam"] = "DynamicCam"
L["Disabled"] = "禁用"
L["Your DynamicCam addon lets you adjust horizontal and vertical mouse look speed individually! Just go to the \"Mouse Look\" settings of DynamicCam to make the adjustments there."] = "你的DynamicCam插件允许你单独调整水平和垂直鼠标视角速度！只需前往DynamicCam的“鼠标视角”设置中进行调整。"
L["Attention"] = "注意"
L["The \""] = "这个\""
L["\" setting is disabled by DynamicCam, while you are using the horizontal camera over shoulder offset."] = "\"设置被DynamicCam禁用，当你使用水平镜头肩部偏移时。"
L["While you are using horizontal camera offset, DynamicCam prevents CameraKeepCharacterCentered!"] = "当你使用水平镜头偏移时，DynamicCam会阻止CameraKeepCharacterCentered起效！"
L["While you are using vertical camera pitch, DynamicCam prevents CameraKeepCharacterCentered!"] = "当你使用垂直镜头俯仰时，DynamicCam会阻止CameraKeepCharacterCentered起效！"
L["While you are using horizontal camera offset, DynamicCam prevents CameraReduceUnexpectedMovement!"] = "当你使用水平镜头偏移时，DynamicCam会阻止CameraReduceUnexpectedMovement起效！"
L["While you are using vertical camera pitch, DynamicCam prevents CameraKeepCharacterCentered!"] = "当你使用镜头垂直俯仰时，DynamicCam会阻止“保持角色居中”功能！"
L["cameraView ="] = "镜头视角 ="
L["prevented by DynamicCam!"] = "被DynamicCam阻止！"

-- MouseZoom
L["Actual\nZoom\nValue"] = "实际\n缩放值"
L["Reactive\nZoom\nTarget"] = "响应\n缩放目标"

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
L["Dungeon/Scenerio"] = "地下城/场景战役"
L["Dungeon/Scenerio (Outdoors)"] = "地下城/场景战役（户外）"
L["Dungeon/Scenerio (Combat, Boss)"] = "地下城/场景战役（战斗，首领）"
L["Dungeon/Scenerio (Combat, Trash)"] = "地下城/场景战役（战斗，小怪）"
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
L["Dracthyr Soar"] = "驭龙术"
L["Skyriding Race"] = "驭空竞速"
L["Taxi"] = "出租车（飞行点交通）"
L["Vehicle"] = "载具"
L["Hearth/Teleport"] = "炉石/传送"
L["Annoying Spells"] = "烦人的技能"
L["NPC Interaction"] = "与NPC互动"
L["Mailbox"] = "邮箱"
L["Fishing"] = "钓鱼"
L["Gathering"] = "采集"
L["AFK"] = "暂离"
L["Pet Battle"] = "宠物对战"
L["Professions Frame Open"] = "Professions Frame Open"
