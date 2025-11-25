local L = LibStub("AceLocale-3.0"):NewLocale("DynamicCam", "zhTW")
if not L then return end

-- Options
L["Reset"] = "重置"
L["Reset to global default"] = "重置為全域預設值"
L["(To restore the settings of a specific profile, restore the profile in the \"Profiles\" tab.)"] = "（要恢復特定設定檔的設置，請在“設定檔”標籤中恢復該設定檔。）"
L["Currently overridden by the active situation \"%s\"."] = "当前被活动情境覆盖: \"%s\"."
L["Override Standard Settings"] = "覆蓋標準情境"
L["<overrideStandardToggle_desc>"] = "勾選這個核取方塊，允許你在啟動當前情境時，覆蓋標準情境。取消勾選將刪除此類型的情境設置。"
L["Standard Settings"] = "標準設定"
L["Situation Settings"] = "情境設定"
L["<standardSettings_desc>"] = "當沒有任何情境處於啟動狀態，或者啟動的情境沒有設置覆蓋標準設定的情境設置時，將應用這些標準設定。"
L["<standardSettingsOverridden_desc>"] = "綠色的類型表示目前被啟動的情境覆蓋。因此，在覆蓋情境啟動時，綠色類型的標準設定不會生效。"
L["These Situation Settings override the Standard Settings when the respective situation is active."] = "當相應的情境啟動時，這些情境設置將覆蓋標準設定。"
L["Mouse Zoom"] = "滑鼠縮放"
L["Maximum Camera Distance"] = "最大鏡頭距離"
L["How many yards the camera can zoom away from your character."] = "鏡頭鏡頭可以從你的角色拉遠多少碼的距離。"
L["Camera Zoom Speed"] = "鏡頭縮放速度"
L["How fast the camera can zoom."] = "鏡頭鏡頭縮放的速度。"
L["Zoom Increments"] = "鏡頭縮放增量"
L["How many yards the camera should travel for each \"tick\" of the mouse wheel."] = "每次滑鼠滾輪鏡頭應該移動多少碼。"
L["Use Reactive Zoom"] = "使用回應縮放"
L["Quick-Zoom Additional Increments"] = "快速縮放額外增量"
L["How many yards per mouse wheel \"tick\" should be added when quick-zooming."] = "當快速縮放時，每次滑鼠滾輪滾動應該增加多少碼。"
L["Quick-Zoom Enter Threshold"] = "快速縮放閾值"
L["How many yards the \"Reactive Zoom Target\" and the \"Current Zoom Value\" have to be apart to enter quick-zooming."] = "\"響應縮放目標\"與\"實際縮放值\"之間至少需要多少碼的距離，才能觸發快速縮放功能。"
L["Maximum Zoom Time"] = "最大縮放時間"
L["The maximum time the camera should take to make \"Current Zoom Value\" equal to \"Reactive Zoom Target\"."] = "鏡頭會在這個時間內將\"當前縮放值\"調整到\"響應縮放目標\"。"
L["Help"] = "幫助"
L["Toggle Visual Aid"] = "視覺輔助開關"
L["<reactiveZoom_desc>"] = "使用 DynamicCam 的響應縮放功能，滑鼠滾輪控制\"響應縮放目標\"。每當\"響應縮放目標\"與\"實際縮放值\"不同時，DynamicCam 會改變\"實際縮放值\"，直到他再次與\"響應縮放目標\"相同。\n\n這種縮放變化的速度取決於\"鏡頭縮放速度\"和 \"最大縮放時間\"。如果\"最大縮放時間\"設置的比較短，無論\"鏡頭縮放速度\"如何設置，縮放總會很快執行。要實現舒緩的縮放變化，你必須將\"最大縮放時間\"設置得更長，同時把\"鏡頭縮放速度\"設置為較低的值。\n\n為了實現隨著滑鼠滾輪快速滾動更快地縮放鏡頭，請使用\"快速縮放功能\"：如果\"響應縮放目標\"與\"實際縮放值\"的偏差超過了\"快速縮放閾值\"，每次滑鼠滾輪的滾動都會增加\"快速縮放額外增量\"。\n\n為了感受這些功能是如何工作的，你可以在尋找合適設置的同時，開啟視覺輔助。你也可以通過左鍵拖弋操作來自動移動這個圖表。右鍵點擊可以關閉它。"
L["Enhanced minimal zoom-in"] = "強化最小視角"
L["<enhancedMinZoom_desc>"] = "回應縮放允許你把鏡頭放大到比最近還近。你可以通過在第一人稱視角時再次滾動滑鼠實現這一點。\n\n啟用\"強化最小視角\"後，我們會強制鏡頭在放大時也停留在這個視角上，而不是立即切換回第一人稱視角。你也可以把此理解為\"狙擊模式\"。\n\n|cFFFF0000啟用\"強化最小視角\"可能會在CPU受限的情境下導致幀率下降15%。|r"
L["/reload of the UI required!"] = "需要使用 /reload 重載介面！"
L["Mouse Look"] = "滑鼠觀察"
L["Horizontal Speed"] = "水平速度"
L["How much the camera yaws horizontally when in mouse look mode."] = "當處於滑鼠觀察模式時，鏡頭水準偏轉的程度。"
L["Vertical Speed"] = "垂直速度"
L["How much the camera pitches vertically when in mouse look mode."] = "當處於滑鼠觀察模式時，鏡頭垂直俯仰的程度。"
L["<mouseLook_desc>"] = "當您在「滑鼠觀察」模式下移動滑鼠時（即按下滑鼠左鍵或右鍵時），鏡頭移動的程度。\n\nWoW 預設介面設置中的「滑鼠觀察速度」滑桿同時控制水準和垂直速度：自動將水準速度設置為垂直速度的 2 倍。DynamicCam 覆蓋此設置，並允許您進行更加個性化的設置。"
L["Horizontal Offset"] = "水平偏移"
L["Camera Over Shoulder Offset"] = "鏡頭肩部偏移"
L["Positions the camera left or right from your character."] = "將鏡頭置於你角色的左側或右側。"
L["<cameraOverShoulder_desc>"] = "為使此功能生效，DynamicCam 會自動暫時禁用 WoW 的「畫面暈眩」設置。因此，如果你需要「畫面暈眩」設置，請不要在這些情境下使用水平偏移。\n\n當你選擇你自己的角色時，WoW 會自動居中鏡頭。對此我們無能為力。對於鏡頭與牆壁碰撞時可能發生的偏移抽搐，我們也無能為力。一種解決方法是在建築物內部使用極少或不使用偏移。\n\n此外，WoW 會根據角色模型或坐騎的不同，奇怪地應用不同的偏移。對於所有偏愛永久偏移的人，Ludius 正在開發另一個插件（「CameraOverShoulder Fix」）來解決這個問題。"
L["Adjust shoulder offset according to zoom level"] = "根據縮放級別調整偏移"
L["Enable"] = "啟用"
L["and"] = "和"
L["No offset when below this zoom level:"] = "當縮放級別低於此值時無偏移："
L["When the camera is closer than this zoom level, the offset has reached zero."] = "當鏡頭比此縮放級別更近時，偏移量已達到零。"
L["Real offset when above this zoom level:"] = "當縮放級別高於此值時的真實偏移："
L["When the camera is further away than this zoom level, the offset has reached its set value."] = "當鏡頭比此縮放級別更遠時，偏移量已達到其設定值。"
L["<shoulderOffsetZoom_desc>"] = "在縮放時使肩部偏移量逐漸過渡到零。兩個滑塊定義了此過渡發生的縮放級別範圍。此設置是全域的，不特定於情境。"
L["Vertical Pitch"] = "垂直俯仰"
L["Pitch (on ground)"] = "俯仰 (地面)"
L["Pitch (flying)"] = "俯仰 (飛行)"
L["Down Scale"] = "俯視縮放"
L["Smart Pivot Cutoff Distance"] = "智能轉軸截止距離"
L["<pitch_desc>"] = "如果鏡頭向上傾斜（較低的「俯仰」值），「俯視縮放」設置決定了從上方看向您角色時，這種傾斜生效的程度。將「俯視縮放」設置為 0 會使從上方看時向上傾斜的效果無效。相反，當您不是從上方看，或者鏡頭向下傾斜時（較高的「俯仰」值），「俯視縮放」設置幾乎沒有影響。\n\n因此，您應該首先在從背後看向您角色時，找到您偏好的「俯仰」設置。在您選擇了向上傾斜後，接著在從上方看時找到您偏好的「俯視縮放」設置。\n\n\n當鏡頭與地面碰撞時，它通常會在鏡頭與地面的碰撞點執行向上傾斜。另一種選擇是，在執行此傾斜的同時，鏡頭會向您角色的腳部靠近。「智能轉軸截止距離」決定了鏡頭必須處於離您角色多近的距離內，才会发生这种情况。當值為 0 時，鏡頭永遠不會靠近（WoW預設）。然而，当值為最大值 39 時，它總是會靠近。\n\n"
L["Target Focus"] = "目標焦點"
L["Enemy Target"] = "敵方目標"
L["Horizontal Strength"] = "水平強度"
L["Vertical Strength"] = "垂直強度"
L["Interaction Target (NPCs)"] = "交互目標 (NPC)"
L["<targetFocus_desc>"] = "如果啟用，鏡頭會自動嘗試將目標拉近螢幕中心。強度決定了這種效果的強度。\n\n如果「敵方目標」和「交互目標」都啟用，後者似乎有一個奇怪的錯誤：當首次與 NPC 交互時，鏡頭會像預期的那樣平滑移動到新角度。但是當您退出交互時，它會立即跳轉到之前的角度。然後當您再次開始交互時，它再次跳轉到新角度。這在與新 NPC 交談時是可重複的：只有第一次過渡是平滑的，所有後續的都是立即的。\n如果您想要同時使用「敵方目標」和「交互目標」，一個變通方法是只在需要它且不太可能發生 NPC 交互的 DynamicCam 情境下啟動「敵方目標」（比如戰鬥）。"
L["Head Tracking"] = "頭部追蹤"
L["<headTrackingEnable_desc>"] = "（這也可以作為一個 0 到 1 之間的連續值，但它只是分別乘以「強度（站立）」和「強度（移動）」。所以真的不需要另一個滑塊。）"
L["Strength (standing)"] = "強度（站立）"
L["Inertia (standing)"] = "慣性（站立）"
L["Strength (moving)"] = "強度（移動）"
L["Inertia (moving)"] = "慣性（移動）"
L["Inertia (first person)"] = "慣性（第一人稱）"
L["Range Scale"] = "範圍縮放"
L["Camera distance beyond which head tracking is reduced or disabled. (See explanation below.)"] = "超過此鏡頭距離時減少或禁用頭部追蹤。（見下文解釋。）"
L["(slider value transformed)"] = "（滑塊值轉換）"
L["Dead Zone"] = "死區"
L["Radius of head movement not affecting the camera. (See explanation below.)"] = "頭部移動不影響鏡頭的半徑。（見下文解釋。）"
L["(slider value devided by 10)"] = "（滑塊值除以 10）"
L["Requires /reload to come into effect!"] = "需要 /reload 才能生效！"
L["<headTracking_desc>"] = "啟用頭部追蹤後，鏡頭會跟隨您角色頭部的移動。（雖然這可能有助於沉浸感，但如果您對「畫面暈眩」敏感，也可能導致噁心。）\n\n「強度」設置決定了這種效果的強度。將其設置為 0 可以禁用頭部追蹤。「慣性」設置決定了鏡頭對頭部移動的反應速度。將其設置為 0 也會禁用頭部追蹤。「站立」、「移動」和「第一人稱」三種情況可以單獨設置。「第一人稱」沒有「強度」設置，因為它分別沿用「站立」和「移動」的「強度」設置。如果您想單獨激活或禁用「第一人稱」，請使用「慣性」滑塊來禁用不需要的情況。\n\n使用「範圍縮放」設置，您可以設定超過此鏡頭距離時減少或禁用頭部追蹤。例如，如果滑塊設置為 30，當鏡頭距離您角色超過 30 碼時，將沒有頭部追蹤。但是，從完全頭部追蹤到無頭部追蹤有一個逐漸過渡的過程，從滑塊值的三分之一開始。例如，如果值設置為 30，當鏡頭距離小於 10 碼時，有完全的頭部追蹤。從 10 碼開始，頭部追蹤逐漸減少，直到從 30 碼開始完全禁用。因此，最大值 117 允許在最大鏡頭距離 39 碼時進行完全頭部追蹤。（提示：使用 DynamicCam 的「滑鼠縮放」視覺輔助工具在設置期間了解當前鏡頭距離。）\n\n「死區」設置可以用來忽略較小的頭部移動。將其設置為 0 可以讓鏡頭跟隨每一個微小的頭部移動，而將其設置為更大的值則只跟隨較大的移動。請注意，更改此設置只有在重新載入介面（在控制台中輸入 /reload）後才生效。"
L["Situations"] = "情境"
L["Select a situation to setup"] = "選擇一個情境來設置"
L["<selectedSituation_desc>"] = "\n|cffffcc00顏色代碼：|r\n|cFF808A87- 禁用的情境。|r\n- 啟用的情境。\n|cFF00FF00- 啟用且當前啟動的情境。|r\n|cFF63B8FF- 啟用且條件滿足但優先順序低於當前啟動情境的情境。|r\n|cFFFF6600- 修改過的原始「情境控制」（建議重置）。|r\n|cFFEE0000- 錯誤的「情境控制」（需要修正）。|r"
L["If this box is checked, DynamicCam will enter the situation \"%s\" whenever its condition is fulfilled and no other situation with higher priority is active."] = "如果選取此方塊，只要其條件滿足且沒有其他更高優先順序的活躍情境，DynamicCam 將進入情境「%s」。"
L["Custom:"] = "自訂："
L["(modified)"] = "(已修改)"
L["Delete custom situation \"%s\".\n|cFFEE0000Attention: There will be no 'Are you sure?' prompt!|r"] = "刪除自訂情境「%s」。\n|cFFEE0000注意：不會有「你確定嗎？」的提示！|r"
L["Create a new custom situation."] = "創建一個新的自訂情境。"
L["Situation Actions"] = "情境指令"
L["Setup stuff to happen while in a situation or when entering/exiting it."] = "設置在情境中或進入/退出時要執行的操作。"
L["Zoom/View"] = "縮放/視角"
L["Zoom to a certain zoom level or switch to a saved camera view when entering this situation."] = "在進入這個情境時，調整到特定的縮放級別或切換到保存的鏡頭視角。"
L["Set Zoom or Set View"] = "設置縮放或設置視角"
L["Zoom Type"] = "縮放模式"
L["<viewZoomType_desc>"] = "設置縮放：調整到給定的縮放級別，並有過渡時間和縮放條件的高級選項。\n\n設置視角：切換到包含固定縮放級別和鏡頭角度的保存的鏡頭視角。"
L["Set Zoom"] = "設置縮放"
L["Set View"] = "設置視角"
L["Set view to saved view:"] = "設置視角為保存視角："
L["Select the saved view to switch to when entering this situation."] = "選擇進入此情境時要切換的保存視角。"
L["Instant"] = "立即"
L["Make view transitions instant."] = "使視角轉換立即發生。"
L["Restore view when exiting"] = "退出時恢復視角"
L["When exiting the situation restore the camera position to what it was at the time of entering the situation."] = "退出情境時，將鏡頭恢復到進入情境時的位置。"
L["cameraSmoothNote"] = [[|cFFEE0000注意：|r 您正在使用WoW的「鏡頭跟隨模式」，它會自動將鏡頭放置在玩家後面。這在您處於自訂保存視角時不起作用。您可以在不需要鏡頭跟隨的情境中使用自訂保存視角（例如，NPC互動）。但在退出情境後，您必須返回到非自訂的預設視角，以便再次使鏡頭跟隨工作。]]
L["Restore to default view:"] = "恢復為預設視角："
L["<viewRestoreToDefault_desc>"] = [[選擇退出此情境時返回的預設視角。

視角1：縮放0，俯仰0
視角2：縮放5.5，俯仰10
視角3：縮放5.5，俯仰20
視角4：縮放13.8，俯仰30
視角5：縮放13.8，俯仰10]]
L["WARNING"] = "警告"
L["You are using the same view as saved view and as restore-to-default view. Using a view as restore-to-default view will reset it. Only do this if you really want to use it as a non-customized saved view."] = "您要設置的保存視角與要恢復的預設視角相同。如果一個視角被用作恢復到預設，它將被重置。只有在您確實想將其用作非自訂保存視角時才這樣做。"
L["View %s is used as saved view in the situations:\n%sand as restore-to-default view in the situations:\n%s"] = "視角 %s 在以下情境中被用作保存視角：\n%s並且在以下情境中被用作恢復預設視角：\n%s"
L["<view_desc>"] = [[魔獸世界允許保存最多5個自訂鏡頭視角。視角1由DynamicCam使用，用於保存進入情境時的鏡頭位置，以便在退出情境時可以恢復，如果您在上面勾選了「恢復」。這對於短暫的情境（如與NPC互動）特別有用，允許在與NPC對話時切換到一個視角，然後回到鏡頭之前的位置。這就是為什麼視角1不能在上述保存視角的下拉式功能表中選擇。

視角2、3、4和5可以用來保存自訂的鏡頭位置。要保存一個視角，只需將鏡頭調整到所需的縮放和角度。然後在控制台中輸入以下命令（其中#是編號2、3、4或5）：

  /saveView #

或簡寫為：

  /sv #

請注意，保存的視角由魔獸世界存儲。DynamicCam只存儲使用哪些視角編號。因此，當您導入新的DynamicCam情境設定檔和視角時，您可能需要在之後設置並保存相應的視角。


DynamicCam還提供了一個控制台命令，用於無論進入還是退出情境都切換到視角：

  /setView #

要使視角轉換立即發生，請在視角編號後添加一個「i」。例如，要立即切換到保存的視角3，請輸入：

  /setView 3 i

]]
L["Zoom Transition Time"] = "縮放過渡時間"
L["<transitionTime_desc>"] = "過渡到新縮放值所需的時間（以秒為單位）。\n\n如果設置的值低於可能的最低值，過渡速度將盡可能快，以當前鏡頭縮放速度為准（可在DynamicCam的「滑鼠縮放」設置中調整）。\n\n如果某個情境在其進入腳本中分配了變數「this.transitionTime」（參見「情境控制」），這裡的設置將被覆蓋。例如，在「爐石/傳送」情境中這樣做，以便為施法持續時間允許一個過渡時間。"
L["<zoomType_desc>"] = "\n設置：始終將縮放設置為此值。\n\n拉遠：僅當鏡頭當前比此值更近時，才設置縮放。\n\n推近：僅當鏡頭當前比此值更遠時，才設置縮放。\n\n範圍：如果比給定的最大值更遠，則放大；如果比給定的最小值更近，則縮小。如果當前縮放在[min, max]範圍內，則不執行任何操作。"
L["Set"] = "設置"
L["Out"] = "拉遠"
L["In"] = "推近"
L["Range"] = "範圍"
L["Don't slow"] = "不要減速"
L["Zoom transitions may be executed faster (but never slower) than the specified time above, if the \"Camera Zoom Speed\" (see \"Mouse Zoom\" settings) allows."] = "如果「鏡頭縮放速度」（參見「滑鼠縮放」設置）允許，縮放過渡可能會比上述指定時間更快（但不會減速）。"
L["Zoom Value"] = "縮放值"
L["Zoom to this zoom level."] = "縮放到這個縮放級別。"
L["Zoom out to this zoom level, if the current zoom level is less than this."] = "如果當前縮放級別小於此值，則縮小到這個縮放級別。"
L["Zoom in to this zoom level, if the current zoom level is greater than this."] = "如果當前縮放級別大於此值，則放大到這個縮放級別。"
L["Zoom Min"] = "最小縮放"
L["Zoom Max"] = "最大縮放"
L["Restore Zoom"] = "恢復縮放"
L["<zoomRestoreSetting_desc>"] = "當您退出一個情境（或退出沒有活躍情境的預設狀態）時，當前的縮放級別會被臨時保存，以便下次進入此情境時可以恢復。在這裡，您可以選擇如何處理。\n\n此設置對所有情境都是全域的。"
L["Restore Zoom Mode"] = "恢復縮放模式"
L["<zoomRestoreSettingSelect_desc>"] = "\n從不：進入情境時，應用進入情境的實際縮放設置（如果有）。不考慮保存的縮放。\n\n總是：進入情境時，使用此情境上次保存的縮放。其實際設置僅在登錄後首次進入情境時考慮。\n\n自我調整：僅在某些情況下使用保存的縮放。例如，只有當返回到您來自的相同情境，或者保存的縮放滿足情境的「推近」、「拉遠」或「範圍」縮放設置的標準時。"
L["Never"] = "從不"
L["Always"] = "總是"
L["Adaptive"] = "自我調整"
L["<zoom_desc>"] = [[要確定當前的縮放級別，您可以使用「視覺輔助」（在DynamicCam的「滑鼠縮放」設置中切換）或使用控制台命令：

  /zoomInfo

或者簡寫為：

  /zi]]
L["Rotation"] = "轉動"
L["Start a camera rotation when this situation is active."] = "當此情境啟動時開始鏡頭轉動。"
L["Rotation Type"] = "轉動方式"
L["<rotationType_desc>"] = "\n持續轉動：當此情境啟動時，鏡頭會持續水平轉動。這只建議用於不使用滑鼠移動攝像機的情況；例如，傳送法術施放、飛行或暫離。無法持續垂直轉動，因為它會在達到垂直俯視或仰視視角時停止。\n\n按度數轉動：進入情境後，根據給定的度數改變當前攝像機的水平偏轉（yaw）和/或垂直俯仰（pitch）。"
L["Continuously"] = "持續轉動"
L["By Degrees"] = "按角度轉動"
L["Acceleration Time"] = "加速時間"
L["Rotation Time"] = "轉動時間"
L["<accelerationTime_desc>"] = "如果您在這裡設置的時間大於 0，持續轉動不會立即以全速開始，而是會花費這段時間來加速。（只有在相對較高的轉動速度下才會明顯感知。）"
L["<rotationTime_desc>"] = "需要多長時間來調整到新的攝像機角度。如果這裡給出的值太小，攝像機可能會轉動過頭，因為我們每渲染一幀時只檢查一次是否達到了期望的角度。\n\n如果某個情境在其進入腳本中分配了變數「this.rotationTime」（參見「情境控制」），這裡的設置將被覆蓋。例如，在「爐石/傳送」情境中這樣做，以便為施法時間內塞入一個轉動時間。"
L["Rotation Speed"] = "轉動速度"
L["Speed at which to rotate in degrees per second. You can manually enter values between -900 and 900, if you want to get yourself really dizzy..."] = "每秒轉動的度數。如果您想讓自己真的頭暈目眩，可以手動輸入 -900 到 900 之間的值..."
L["Yaw (-Left/Right+)"] = "偏轉（-左/右+）"
L["Degrees to yaw (left or right)."] = "偏轉的度數（左或右）。"
L["Pitch (-Down/Up+)"] = "俯仰（-下/上+）"
L["Degrees to pitch (up or down). There is no going beyond the perpendicular upwards or downwards view."] = "俯仰的度數（上或下）。無法超過垂直俯視或仰視視角。"
L["Rotate Back"] = "轉動返回"
L["<rotateBack_desc>"] = "退出情境時，按進入情境後轉動的度數（360）反向轉動。這實際上會將您帶回進入前的攝像機位置，除非您在此過程中用滑鼠改變了視角。\n\n如果您正在進入一個自帶轉動設置的新情境，那麼退出情境的「轉動返回」將被忽略。"
L["Rotate Back Time"] = "轉動返回時間"
L["<rotateBackTime_desc>"] = "轉動返回所需的時間。如果這裡給出的值太小，攝像機可能會轉動過頭，因為我們每渲染一幀時只檢查一次是否達到了期望的角度。"
L["Fade Out UI"] = "漸隱介面"
L["Fade out or hide (parts of) the UI when this situation is active."] = "當此情境啟動時，漸隱或隱藏（部分）使用者介面。"
L["Adjust to Immersion"] = "調整以適應沉浸"
L["<adjustToImmersion_desc>"] = "許多人將 Immersion 外掛程式與 DynamicCam 結合使用。Immersion 在 NPC 互動期間有一些自己的隱藏 UI 特性。在某些情況下，DynamicCam 的隱藏介面會覆蓋 Immersion 的設置。為了防止這種情況，您可以在 DynamicCam 中進行所需的設置。點擊此按鈕使用與 Immersion 相同的漸顯和漸隱時間。想要更多選項，請查看 Ludius 的另一個外掛程式「Immersion ExtraFade」。"
L["Fade Out Time"] = "漸隱時間"
L["Seconds it takes to fade out the UI when entering the situation."] = "進入情境時，介面漸隱所需的秒數。"
L["Fade In Time"] = "漸顯時間"
L["<fadeInTime_desc>"] = "退出情境時，UI 漸顯所需的秒數。\n\n當您在兩個都啟用了 UI 隱藏的情境之間切換時，將使用進入情境的漸隱時間進行過渡。"
L["Hide entire UI"] = "隱藏整個介面"
L["<hideEntireUI_desc>"] = "「隱藏」的介面和「只是漸隱」的介面之間有區別：「漸隱」的介面元素的不透明度為 0，但仍然可以與之交互。從 DynamicCam 2.0 開始，如果介面元素的不透明度為 0，我們會自動隱藏大多數介面元素。因此，漸隱後隱藏整個介面的選項更像是一個遺留物。仍然使用它的原因可能是為了避免不希望的交互（例如滑鼠懸停提示）DynamicCam 仍然沒有正確隱藏的介面元素。\n\n隱藏介面的不透明度當然是 0，所以您不能選擇不同的不透明度，也不能保留任何介面元素可見（除了 FPS 指示器）。\n\n在戰鬥中我們不能改變受保護的介面元素的隱藏狀態。因此，此類元素在戰鬥中始終只是「漸隱」。請注意，小地圖上「光點」的不透明度無法降低。因此，如果您嘗試隱藏小地圖，在戰鬥中「光點」始終可見。\n\n如果您為當前啟動的情境選中此框，它不會立即生效，因為這也會隱藏這個設置框。您必須進入情境才能使其生效，這也可以通過上面的情境「啟用」核取方塊來實現。\n\n另請注意，隱藏整個介面會取消與郵箱或 NPC 的交互。所以不要在這些情境下使用它！"
L["Keep FPS indicator"] = "保留 FPS 指示器"
L["Do not fade out or hide the FPS indicator (the one you typically toggle with Ctrl + R)."] = "不要漸隱或隱藏 FPS 指示器（通常用 Ctrl+R 切換的那個）。"
L["Fade Opacity"] = "漸隱不透明度"
L["Fade the UI to this opacity when entering the situation."] = "進入情境時將使用者介面漸隱到這種不透明度。"
L["Excluded UI elements"] = "排除的使用者介面元素"
L["Keep Alerts"] = "保留警告"
L["Still show alert popups from completed achievements, Covenant Renown, etc."] = "仍然顯示來自完成成就、盟約聲望等的警告快顯視窗。"
L["Keep Tooltip"] = "保留提示"
L["Still show the game tooltip, which appears when you hover your mouse cursor over UI or world elements."] = "仍然顯示遊戲提示，當您將滑鼠游標懸停在使用者介面或世界元素上時出現。"
L["Keep Minimap"] = "保留小地圖"
L["<keepMinimap_desc>"] = "不要漸隱小地圖。\n\n請注意，我們不能減少小地圖上「光點」的不透明度。當使用者介面漸隱到 0 不透明度時，這些只能與整個小地圖一起隱藏。"
L["Keep Chat Box"] = "保留聊天框"
L["Do not fade out the chat box."] = "不要漸隱聊天框。"
L["Keep Tracking Bar"] = "保留經驗值/聲望條"
L["Do not fade out the tracking bar (XP, AP, reputation)."] = "不要漸隱經驗值/聲望條（經驗值、能力點、聲望）。"
L["Keep Party/Raid"] = "保留小隊/團隊框架"
L["Do not fade out the Party/Raid frame."] = "不要漸隱小隊/團隊框架"
L["Keep Encounter Frame (Skyriding Vigor)"] = "保留遭遇框架（馭空術精力）"
L["Do not fade out the Encounter Frame, which while skyriding is the Vigor display."] = "不要漸隱遭遇框架，在馭空術時是精力顯示。"
L["Keep additional frames"] = "保留額外框架"
L["<keepCustomFrames_desc>"] = "下面的文字方塊允許您定義在 NPC 交互期間想要保留的任何框架。\n\n使用控制台命令 /fstack 來瞭解框架的名稱。\n\n例如，您可能想要保留小地圖旁邊的增益圖示，以便在 NPC 交互期間通過點擊適當的圖示來取消騎乘。"
L["Custom frames to keep"] = "自訂保留框架"
L["Separated by commas."] = "用逗號分隔。"
L["Emergency Fade In"] = "緊急漸顯"
L["Pressing Esc fades the UI back in."] = "按下 Esc 鍵將使用者介面漸顯回來。"
L["<emergencyShow_desc>"] = [[有時您可能希望在常態隱藏介面的情況下顯示介面。在舊版本的 DynamicCam 中有個規則，允許您在按下 Esc 鍵時顯示介面。但這樣做有個缺點，當 Esc 鍵用於其他作用，比如關閉視窗、取消施法等時，介面也會顯示。取消勾選上面的核取方塊可以禁用此功能。

但請注意，這樣可能會導致無法訪問介面！Esc 鍵更好的替代方案是使用以下的控制台命令，它們會根據當前設置的「漸隱介面」設置顯示或隱藏介面：

    /showUI
    /hideUI

為了更加快捷的實現漸隱介面，將 /showUI 放入巨集命令中，並在 "bindings-cache.wtf" 檔中為其分配一個按鍵。例如：

    bind ALT+F11 MACRO 您的宏名稱

如果您不想編輯 "bindings-cache.wtf" 檔，可以使用類似 "BindPad" 這樣的按鍵綁定外掛程式。

使用 /showUI 或者 /hideUI 而不帶任何參數將採用當前情境的漸顯和漸隱時間。但您也可以使用參數提供不同的過渡時間。例如：

    /showUI 0

來實現立即顯示介面，沒有任何延遲。]]
L["<hideUIHelp_desc>"] = "在設置您期望的介面漸隱效果時，如果這個「介面」設置框也一起漸隱，可能會很煩人。如果選中這個框，它將不會被漸隱。\n\n此設置適用於所有情況。"
L["Do not fade out this \"Interface\" settings frame."] = "不要漸隱這個「介面」設置框。"
L["Situation Controls"] = "情境控制"
L["<situationControls_help>"] = "在這裡控制情境何時啟動。可能需要 WoW UI API 的知識。如果您對 DynamicCam 的原始情境感到滿意，請直接忽略此部分。但如果您想創建自訂情境，可以在這裡查看原始情境。您也可以修改它們，但請注意：即使 DynamicCam 的未來版本引入了重要更新，您更改的設置也會保留。\n\n"
L["Priority"] = "優先順序"
L["The priority of this situation.\nMust be a number."] = "此情境的優先順序。\n必須是數字。"
L["Restore stock setting"] = "恢復原始設置"
L["Your \"Priority\" deviates from the stock setting for this situation (%s). Click here to restore it."] = "您的「優先順序」偏離了此情境（%s）的原始設置。點擊此處恢復。"
L["<priority_desc>"] = "如果同時滿足多個不同 DynamicCam 情境的條件，則進入優先順序最高的情境。例如，只要滿足「世界（室內）」的條件，也就滿足了「世界」的條件。但由於「世界（室內）」的優先順序高於「世界」，因此會優先考慮它。您也可以在上面的下拉式功能表中查看所有情境的優先順序。\n\n"
L["Error message:"] = "錯誤訊息："
L["Events"] = "活動"
L["Separated by commas."] = "用逗號分隔。"
L["Your \"Events\" deviate from the default for this situation. Click here to restore them."] = "您的「活動」偏離了此情境的原始設置。點擊此處恢復。"
L["<events_desc>"] = [[在這裡定義 DynamicCam 應該檢查此情境條件的所有遊戲內活動，以便在適用的情況下進入或退出它。

您可以使用 WoW 的事件紀錄來瞭解遊戲內活動。
要打開它，請在控制台中輸入：

  /eventtrace

所有可能活動的列表也可以在這裡找到：
https://warcraft.wiki.gg/wiki/Events

]]
L["Initialisation"] = "初始化"
L["Initialisation Script"] = "初始化腳本"
L["Lua code using the WoW UI API."] = "使用 WoW UI API 的 Lua 代碼。"
L["Your \"Initialisation Script\" deviates from the stock setting for this situation. Click here to restore it."] = "您的「初始化腳本」偏離了此情境的原始設置。點擊此處恢復。"
L["<initialisation_desc>"] = [[情境的初始化腳本在載入 DynamicCam 時運行一次（以及在修改情境時）。通常，您會將要在其他任何腳本（條件、進入、退出）中重用的內容放入其中。這可以使這些其他腳本稍微簡短一些。

例如，「爐石/傳送」情境的初始化腳本定義了表「this.spells」，其中包括傳送法術的法術 ID。條件腳本隨後可以在每次執行時簡單地訪問「this.spells」。

就像在這個例子中一樣，您可以通過將其放入「this」表中來在情境的腳本之間共用任何資料物件。

]]
L["Condition"] = "條件"
L["Condition Script"] = "條件腳本"
L["Lua code using the WoW UI API.\nShould return \"true\" if and only if the situation should be active."] = "使用 WoW UI API 的 Lua 代碼。\n當且僅當情境應處於啟動狀態時，應返回「true」。"
L["Your \"Condition Script\" deviates from the stock setting for this situation. Click here to restore it."] = "您的「條件腳本」偏離了此情境的原始設置。點擊此處恢復。"
L["<condition_desc>"] = [[情境的條件腳本在每次觸發此情境的遊戲內活動時運行。當且僅當此情境應處於啟動狀態時，腳本應返回「true」。

例如，「城市」情境的條件腳本使用 WoW API 函數「IsResting()」來檢查您當前是否在休息區：

  return IsResting()

同樣，「城市（室內）」情境的條件腳本也使用 WoW API 函數「IsIndoors()」來檢查您是否在室內：

  return IsResting() and IsIndoors()

可以在這裡找到 WoW API 函數列表：
https://warcraft.wiki.gg/wiki/World_of_Warcraft_API

]]
L["Entering"] = "進入"
L["On-Enter Script"] = "進入腳本"
L["Your \"On-Enter Script\" deviates from the stock setting for this situation. Click here to restore it."] = "您的「進入腳本」偏離了此情境的原始設置。點擊此處恢復。"
L["<executeOnEnter_desc>"] = [[情境的進入腳本在每次進入情境時運行。

到目前為止，唯一的例子是「爐石/傳送」情境，其中我們使用 WoW API 函數「UnitCastingInfo()」來確定當前法術的施法持續時間。然後我們將其分配給變數「this.transitionTime」和「this.rotationTime」，以便縮放或旋轉（參見「情境指令」）可以正好持續法術施法的時間。（並非所有傳送法術都有相同的施法時間。）

]]
L["Exiting"] = "退出"
L["On-Exit Script"] = "退出腳本"
L["Your \"On-Exit Script\" deviates from the stock setting for this situation. Click here to restore it."] = "您的「退出腳本」偏離了此情境的原始設置。點擊此處恢復。"
L["Exit Delay"] = "退出延遲"
L["Wait for this many seconds before exiting this situation."] = "在退出此情境之前等待這麼多秒。"
L["Your \"Exit Delay\" deviates from the stock setting for this situation. Click here to restore it."] = "您的「退出延遲」偏離了此情境的原始設置。點擊此處恢復。"
L["<executeOnExit_desc>"] = [[情境的退出腳本在每次退出情境時運行。到目前為止，還沒有情境使用此功能。

延遲決定了退出情境前等待的秒數。到目前為止，唯一的例子是「釣魚」情境，延遲讓您有時間重新拋竿而不會退出情境。

]]
L["Export"] = "匯出"
L["Coming soon(TM)."] = "即將推出(TM)。"
L["Import"] = "匯入"
L["<welcomeMessage>"] = [[我們很高興您在這裡，希望您能在這個外掛程式中獲得樂趣。

DynamicCam (DC) 由 mpstark 於 2016 年 5 月啟動，當時暴雪的 WoW 開發人員在遊戲中引入了實驗性的 ActionCam 功能。DC 的主要目的是為 ActionCam 設置提供一個使用者介面。在遊戲中，ActionCam 仍被指定為「實驗性」，暴雪也沒有進一步開發它的跡象。雖然有一些缺陷，但我們應該感謝 ActionCam 被保留在遊戲中供像我們這樣的愛好者使用。:-) DC 不僅允許您更改 ActionCam 設置，還可以針對不同的遊戲情境使用不同的設置。與 ActionCam 無關，DC 還提供有關鏡頭縮放和介面漸隱的功能。

mpstark 在 DC 上的工作持續到 2018 年 8 月。雖然大多數功能對於大量使用者群來說運作良好，但 mpstark 一直認為 DC 處於測試階段，由於他對 WoW 的興趣減弱，他最終沒有恢復工作。當時，Ludius 已經開始為自己對 DC 進行調整，這被 Weston (又名 dernPerkins) 注意到，他在 2020 年初設法與 mpstark 取得了聯繫，導致 Ludius 接管了開發工作。第一個非測試版本 1.0 於 2020 年 5 月發佈，包括 Ludius 到那時為止的調整。隨後，Ludius 開始著手對 DC 進行全面改進，並在 2022 年秋季發佈了 2.0 版本。

當 mpstark 啟動 DC 時，他的重點是在遊戲內進行大多數自訂，而不必更改原始程式碼。這使得實驗變得更容易，特別是針對不同的遊戲情境。從 2.0 版本開始，這些高級設置已移至名為「情境控制」的特殊部分。大多數使用者可能永遠不需要它，但對於「高級使用者」，它仍然可用。在那裡進行更改的一個風險是，保存的使用者設置總是會覆蓋 DC 的原始設置，即使 DC 的新版本帶來了更新的原始設置。因此，每當您有修改了「情境控制」的原始情境時，此頁面頂部都會顯示警告。

如果您認為 DC 的某個原始情境應該更改，您總是可創建一個包含您更改的副本。請隨時匯出這個新情境並將其發佈在 DC 的 CurseForge 頁面上。然後我們可能會將其添加為自己的新原始情境。我們也歡迎您匯出並發佈您的整個 DC 設定檔，因為我們要尋找新的設定檔預設，以便讓新使用者更容易上手 DC。如果您發現問題或想提出建議，只需在 CurseForge 評論中留言，或者更好的是使用 GitHub 上的 Issues。如果您想做出貢獻，也歡迎在那裡提交 pull request。

這是一些方便的斜線指令：

    `/dynamiccam` 或 `/dc` 打開此功能表。
    `/zoominfo` 或 `/zi` 列印當前的縮放級別。

    `/zoom #1 #2` 在 #2 秒內縮放到縮放級別 #1。
    `/yaw #1 #2` 在 #2 秒內將鏡頭水準偏轉 #1 度（負 #1 為向右偏轉）。
    `/pitch #1 #2` 將鏡頭俯仰 #1 度（負 #1 為向上俯仰）。


]]
L["About"] = "關於"
L["The following game situations have \"Situation Controls\" deviating from DynamicCam's stock settings.\n\n"] = "以下遊戲情境的「情境控制」偏離了 DynamicCam 的原始設置。\n\n"
L["<situationControlsWarning>"] = "\n如果您是有意為之，那沒關係。請注意，DynamicCam 開發人員對這些設置的任何更新都將始終被您的修改版（可能已過時）覆蓋。您可以查看每個情境的「情境控制」標籤以獲取詳細資訊。如果您不知道自己方面有任何「情境控制」修改，並且只想恢復*所有*情境的原始控制設置，請點擊此按鈕："
L["Restore all stock Situation Controls"] = "恢復所有原始情境控制"
L["Hello and welcome to DynamicCam!"] = "您好，歡迎使用 DynamicCam！"
L["Profiles"] = "設定檔"
L["Manage Profiles"] = "管理設定檔"
L["<manageProfilesWarning>"] = "像許多外掛程式一樣，DynamicCam 使用「AceDB-3.0」庫來管理設定檔。您必須理解的是，這裡沒有「保存設定檔」之類的東西。您只能創建新設定檔，並且可以將設置從另一個設定檔複製到當前啟動的設定檔中。無論您對當前啟動的設定檔進行什麼更改，都會立即保存！沒有「取消」或「放棄更改」之類的東西。「重置設定檔」按鈕僅重置為全域預設設定檔。\n\n因此，如果您喜歡您的 DynamicCam 設置，您應該創建另一個設定檔，將這些設置複製進去作為備份。當您不使用此備份設定檔作為活動設定檔時，您可以試驗設置，並通過在「複製自」框中選擇您的備份設定檔，隨時返回到您的原始設定檔。\n\n如果您想通過巨集切換設定檔，可以使用以下命令：\n/run DynamicCam.db:SetProfile(\"此處填寫設定檔名稱\")\n\n"
L["Profile presets"] = "設定檔預設"
L["Import / Export"] = "匯入 / 匯出"
L["DynamicCam"] = "DynamicCam"
L["Disabled"] = "已禁用"
L["Your DynamicCam addon lets you adjust horizontal and vertical mouse look speed individually! Just go to the \"Mouse Look\" settings of DynamicCam to make the adjustments there."] = "您的 DynamicCam 外掛程式允許您分別調整水準和垂直滑鼠觀察速度！只需轉到 DynamicCam 的「滑鼠觀察」設置即可在那裡進行調整。"
L["Attention"] = "注意"
L["The \"%s\" setting is disabled by DynamicCam, while you are using the horizontal camera over shoulder offset."] = "DynamicCam 禁用了「%s」設置，因為您正在使用水準鏡頭肩部偏移。"
L["While you are using horizontal camera offset, DynamicCam prevents CameraKeepCharacterCentered!"] = "當您使用水準鏡頭偏移時，DynamicCam 會阻止 CameraKeepCharacterCentered！"
L["While you are using horizontal camera offset, DynamicCam prevents CameraReduceUnexpectedMovement!"] = "當您使用水準鏡頭偏移時，DynamicCam 會阻止 CameraReduceUnexpectedMovement！"
L["While you are using vertical camera pitch, DynamicCam prevents CameraKeepCharacterCentered!"] = "當您使用垂直鏡頭俯仰時，DynamicCam 會阻止 CameraKeepCharacterCentered！"
L["cameraView=%s prevented by DynamicCam!"] = "cameraView=%s 被 DynamicCam 阻止！"

-- MouseZoom
L["Current\nZoom\nValue"] = "當前\n縮放\n值"
L["Reactive\nZoom\nTarget"] = "響應\n縮放\n目標"

-- Core
L["Enter name for custom situation:"] = "輸入自訂情境的名稱："
L["Create"] = "創建"
L["Cancel"] = "取消"

-- DefaultSettings
L["City"] = "城市"
L["City (Indoors)"] = "城市（室內）"
L["World"] = "世界"
L["World (Indoors)"] = "世界（室內）"
L["World (Combat)"] = "世界（戰鬥）"
L["Dungeon/Scenario"] = "地下城/場景戰役"
L["Dungeon/Scenario (Outdoors)"] = "地下城/場景戰役（戶外）"
L["Dungeon/Scenario (Combat, Boss)"] = "地下城/場景戰役（戰鬥，首領）"
L["Dungeon/Scenario (Combat, Trash)"] = "地下城/場景戰役（戰鬥，小怪）"
L["Raid"] = "團隊副本"
L["Raid (Outdoors)"] = "團隊副本（戶外）"
L["Raid (Combat, Boss)"] = "團隊副本（戰鬥，首領）"
L["Raid (Combat, Trash)"] = "團隊副本（戰鬥，小怪）"
L["Arena"] = "競技場"
L["Arena (Combat)"] = "競技場（戰鬥）"
L["Battleground"] = "戰場"
L["Battleground (Combat)"] = "戰場（戰鬥）"
L["Mounted (any)"] = "騎乘（任意）"
L["Mounted (only flying-mount)"] = "騎乘（僅限飛行坐騎）"
L["Mounted (only flying-mount + airborne)"] = "騎乘（僅限飛行坐騎 + 空中）"
L["Mounted (only flying-mount + airborne + Skyriding)"] = "騎乘（僅限飛行坐騎 + 空中 + 天空騎術）"
L["Mounted (only flying-mount + Skyriding)"] = "騎乘（僅限飛行坐騎 + 天空騎術）"
L["Mounted (only airborne)"] = "騎乘（僅限空中）"
L["Mounted (only airborne + Skyriding)"] = "騎乘（僅限空中 + 天空騎術）"
L["Mounted (only Skyriding)"] = "騎乘（僅限天空騎術）"
L["Druid Travel Form"] = "德魯伊旅行形態"
L["Dracthyr Soar"] = "半龍人飛騰"
L["Skyriding Race"] = "天空騎術競速"
L["Taxi"] = "飛行路線"
L["Vehicle"] = "載具"
L["Hearth/Teleport"] = "爐石/傳送"
L["Annoying Spells"] = "惱人的法術"
L["NPC Interaction"] = "NPC 互動"
L["Mailbox"] = "郵箱"
L["Fishing"] = "釣魚"
L["Gathering"] = "採集"
L["AFK"] = "暫離"
L["Pet Battle"] = "寵物對戰"
L["Professions Frame Open"] = "專業視窗打開"
