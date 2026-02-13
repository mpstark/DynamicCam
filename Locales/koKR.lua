local L = LibStub("AceLocale-3.0"):NewLocale("DynamicCam", "koKR") if not L then return end


--------------------------------------------------------------------------------
-- General UI Elements
--------------------------------------------------------------------------------
L["Reset"] = "초기화"
L["Reset to global default"] = "전역 기본값 사용"
L["(To restore the settings of a specific profile, restore the profile in the \"Profiles\" tab.)"] = "(특정 프로필의 설정을 복원하려면 \\\"프로필\\\" 탭에서 프로필을 복원하십시오.)"
L["Standard Settings"] = "기본 설정"
L["<standardSettings_desc>"] = "이러한 기본 설정은 활성화된 상황이 없거나 활성화된 상황에 기본 설정을 덮어쓰도록 설정된 상황 설정이 없을 때 적용됩니다."
L["<standardSettingsOverridden_desc>"] = "녹색으로 표시된 범주는 현재 활성 상황에 의해 재정의됩니다. 따라서 재정의하는 상황이 활성화된 동안에는 녹색 범주의 기본 설정을 변경해도 효과가 나타나지 않습니다."
L["Currently overridden by the active situation \"%s\"."] = "현재 활성 상황에 의해 재정의됨 \\\"%s\\\"."
L["Help"] = "도움말"
L["WARNING"] = "경고"
L["Error message:"] = "오류 메시지:"
L["DynamicCam"] = "DynamicCam"


--------------------------------------------------------------------------------
-- Common Controls (Used Across Multiple Sections)
--------------------------------------------------------------------------------
L["Override Standard Settings"] = "기본 설정 덮어쓰기"
L["<overrideStandardToggle_desc>"] = "이 상자를 선택하면 이 범주의 설정을 구성할 수 있습니다. 이 상황 설정은 이 상황이 활성화되는 즉시 기본 설정을 덮어씁니다. 이 상자를 선택 취소하면 이 범주의 상황 설정이 삭제됩니다."
L["Situation Settings"] = "상황 설정"
L["These Situation Settings override the Standard Settings when the respective situation is active."] = "해당 상황이 활성화되면 이 상황 설정은 기본 설정을 덮어씁니다."
L["Enable"] = "활성화"


--------------------------------------------------------------------------------
-- Options - Mouse Zoom
--------------------------------------------------------------------------------
L["Mouse Zoom"] = "마우스 줌"
L["Maximum Camera Distance"] = "최대 카메라 거리"
L["How many yards the camera can zoom away from your character."] = "카메라가 캐릭터로부터 얼마나 멀리 줌아웃할 수 있는지."
L["Camera Zoom Speed"] = "카메라 줌 속도"
L["How fast the camera can zoom."] = "카메라가 얼마나 빨리 줌할 수 있는지."
L["Zoom Increments"] = "줌 증분"
L["How many yards the camera should travel for each \"tick\" of the mouse wheel."] = "마우스 휠의 각 \\\"틱\\\"마다 카메라가 이동해야 하는 야드 수."
L["Use Reactive Zoom"] = "반응형 줌 사용"
L["Quick-Zoom Additional Increments"] = "빠른 줌 추가 증분"
L["How many yards per mouse wheel \"tick\" should be added when quick-zooming."] = "마우스 휠의 각 \\\"틱\\\"마다 추가되어야 하는 야드 수."
L["Quick-Zoom Enter Threshold"] = "빠른 줌 진입 임계값"
L["How many yards the \"Reactive Zoom Target\" and the \"Current Zoom Value\" have to be apart to enter quick-zooming."] = "빠른 줌에 진입하려면 \\\"반응형 줌 목표\\\"와 \\\"현재 줌 값\\\"이 얼마나 떨어져 있어야 하는가."
L["Maximum Zoom Time"] = "최대 줌 시간"
L["The maximum time the camera should take to make \"Current Zoom Value\" equal to \"Reactive Zoom Target\"."] = "카메라가 \\\"현재 줌 값\\\"을 \\\"반응형 줌 목표\\\"와 동일하게 만드는 데 걸리는 최대 시간."
L["Toggle Visual Aid"] = "시각 보조 기능 켜기/끄기"
L["<reactiveZoom_desc>"] = "With DynamicCam's Reactive Zoom the mouse wheel controls the so called \"Reactive Zoom Target\". Whenever the \"Reactive Zoom Target\" and the \"Current Zoom Value\" are different, DynamicCam changes the \"Current Zoom Value\" until it matches the \"Reactive Zoom Target\" again.\n\nHow fast this zoom change is happening depends on \"Camera Zoom Speed\" and \"Maximum Zoom Time\". If \"Maximum Zoom Time\" is set low, the zoom change will always be executed fast, regardless of the \"Camera Zoom Speed\" setting. To achieve a slower zoom change, you must set \"Maximum Zoom Time\" to a higher value and \"Camera Zoom Speed\" to a lower value.\n\nTo enable faster zooming with faster mouse wheel movement, there is \"Quick-Zoom\": if the \"Reactive Zoom Target\" is further away from the \"Current Zoom Value\" than the \"Quick-Zoom Enter Threshold\", the amount of \"Quick-Zoom Additional Increments\" is added to every mouse wheel tick.\n\nTo get a feeling of how this works, you can toggle the visual aid while finding your ideal settings. You can also freely move this graph by left-clicking and dragging it. A right-click closes it."
L["Enhanced minimal zoom-in"] = "향상된 최소 줌인"
L["<enhancedMinZoom_desc>"] = "반응형 줌은 레벨 1보다 더 가깝게 줌인할 수 있게 해줍니다. 1인칭 시점에서 마우스 휠 틱 하나만큼 줌아웃하면 이를 달성할 수 있습니다.\n\n\\\"향상된 최소 줌인\\\"을 사용하면 줌인할 때 카메라가 1인칭 시점으로 바로 전환되기 전에 이 최소 줌 레벨에서도 멈추도록 강제합니다.\n\n|cFFFF0000CPU 제한 상황에서 \\\"향상된 최소 줌인\\\"을 활성화하면 최대 15%의 FPS 비용이 발생할 수 있습니다.|r"
L["/reload of the UI required!"] = "UI를 /reload해야 합니다!"


--------------------------------------------------------------------------------
-- Options - Mouse Look
--------------------------------------------------------------------------------
L["Mouse Look"] = "마우스 시점"
L["Horizontal Speed"] = "수평 속도"
L["How much the camera yaws horizontally when in mouse look mode."] = "마우스 시점 모드일 때 카메라가 수평으로 얼마나 회전하는지 설정합니다."
L["Vertical Speed"] = "수직 속도"
L["How much the camera pitches vertically when in mouse look mode."] = "마우스 시점 모드일 때 카메라가 수직으로 얼마나 기울어지는지 설정합니다."
L["<mouseLook_desc>"] = "\\\"마우스 시점\\\" 모드에서 마우스를 움직일 때(즉, 마우스 왼쪽 또는 오른쪽 버튼을 누른 상태) 카메라가 얼마나 움직이는지 설정합니다.\n\nWoW 기본 인터페이스 설정의 \\\"마우스 시점 속도\\\" 슬라이더는 수평 및 수직 속도를 동시에 제어하여 자동으로 수평 속도를 수직 속도의 2배로 설정합니다. DynamicCam은 이를 덮어쓰고 더 사용자 정의된 설정을 허용합니다."


--------------------------------------------------------------------------------
-- Options - Horizontal Offset
--------------------------------------------------------------------------------
L["Horizontal Offset"] = "수평 오프셋"
L["Camera Over Shoulder Offset"] = "카메라 어깨 위 시점 오프셋"
L["Positions the camera left or right from your character."] = "카메라를 캐릭터의 왼쪽 또는 오른쪽에 배치합니다."
L["<cameraOverShoulder_desc>"] = "이 설정이 적용되려면, DynamicCam이 WoW의 멀미 방지 설정을 자동으로 임시 비활성화합니다. 따라서 멀미 방지 설정이 필요하다면, 이 상황에서 수평 오프셋을 사용하지 마십시오.\n\n자신의 캐릭터를 대상으로 지정하면, WoW는 자동으로 카메라를 중앙에 배치합니다. 이에 대해 저희가 할 수 있는 것은 없습니다. 또한 카메라가 벽과 충돌할 때 발생할 수 있는 오프셋 급변 현상에 대해서도 저희가 할 수 있는 것은 없습니다. 건물 내부에서는 오프셋을 거의 사용하지 않거나 사용하지 않는 것이 해결책이 될 수 있습니다.\n\n게다가 WoW는 플레이어 모델이나 탈것에 따라 오프셋을 이상하게 다르게 적용합니다. 영구적인 오프셋을 선호하는 모든 분들을 위해, Ludius가 이 문제를 해결하기 위해 다른 애드온(«CameraOverShoulder Fix»)을 개발 중입니다."


--------------------------------------------------------------------------------
-- Options - Vertical Pitch
--------------------------------------------------------------------------------
L["Vertical Pitch"] = "수직 기울기"
L["Pitch (on ground)"] = "기울기 (지상)"
L["Pitch (flying)"] = "기울기 (비행)"
L["Down Scale"] = "하향 축소"
L["Smart Pivot Cutoff Distance"] = "스마트 피벗 전환 거리"
L["<pitch_desc>"] = "If the camera is pitched upwards (lower \"Pitch\" value), the \"Down Scale\" setting determines how much this comes into effect while looking at your character from above. Setting \"Down Scale\" to 0 nullifies the effect of an upwards pitch while looking from above. On the contrary, while you are not looking from above or if the camera is pitched downwards (greater \"Pitch\" value), the \"Down Scale\" setting has little to no effect.\n\nThus, you should first find your preferred \"Pitch\" setting while looking at your character from behind. Afterwards, if you have chosen an upwards pitch, find your preferred \"Down Scale\" setting while looking from above.\n\n\nWhen the camera collides with the ground, it normally performs an upwards pitch on the spot of the camera-to-ground collision. An alternative is that the camera moves closer to your character's feet while performing this pitch. The \"Smart Pivot Cutoff Distance\" setting determines the distance that the camera has to be inside of to do the latter. Setting it to 0 never moves the camera closer (WoW's default), whereas setting it to the maximum zoom distance of 39 always moves the camera closer.\n\n"


--------------------------------------------------------------------------------
-- Options - Target Focus
--------------------------------------------------------------------------------
L["Target Focus"] = "대상 주시"
L["Enemy Target"] = "적 대상"
L["Horizontal Strength"] = "수평 강도"
L["Vertical Strength"] = "수직 강도"
L["Interaction Target (NPCs)"] = "상호작용 대상 (NPC)"
L["<targetFocus_desc>"] = "활성화되면 카메라가 자동으로 대상을 화면 중앙에 더 가깝게 가져오려고 시도합니다. 강도는 이 효과의 세기를 결정합니다.\n\n\\\"적 대상\\\"과 \\\"상호작용 대상\\\"이 모두 활성화되어 있으면 후자에 이상한 버그가 있는 것 같습니다. NPC와 처음 상호작용할 때 카메라는 예상대로 새로운 각도로 부드럽게 이동합니다. 그러나 상호작용을 종료하면 즉시 이전 각도로 돌아갑니다. 상호작용을 다시 시작하면 다시 새로운 각도로 뚝 끊기며 이동합니다. 이는 새로운 NPC와 대화할 때마다 반복됩니다. 첫 번째 전환만 부드럽고 그 이후의 모든 전환은 즉각적입니다.\n\\\"적 대상\\\"과 \\\"상호작용 대상\\\"을 모두 사용하려는 경우의 해결책은, NPC 상호작용이 거의 없는 DynamicCam 상황(예: 전투)에서만 \\\"적 대상\\\"을 활성화하는 것입니다."


--------------------------------------------------------------------------------
-- Options - Head Tracking
--------------------------------------------------------------------------------
L["Head Tracking"] = "머리 추적"
L["<headTrackingEnable_desc>"] = "(이것은 0과 1 사이의 연속적인 값으로 사용될 수도 있지만, 각각 \\\"강도 (서 있을 때)\\\"와 \\\"강도 (움직일 때)\\\"에 곱해질 뿐입니다. 따라서 다른 슬라이더가 굳이 필요하지 않습니다.)"
L["Strength (standing)"] = "강도 (서 있을 때)"
L["Inertia (standing)"] = "관성 (서 있을 때)"
L["Strength (moving)"] = "강도 (움직일 때)"
L["Inertia (moving)"] = "관성 (움직일 때)"
L["Inertia (first person)"] = "관성 (1인칭 시점)"
L["Range Scale"] = "범위 배율"
L["Camera distance beyond which head tracking is reduced or disabled. (See explanation below.)"] = "머리 추적이 감소하거나 비활성화되는 카메라 거리입니다. (아래 설명 참조)"
L["(slider value transformed)"] = "(슬라이더 값 변환됨)"
L["Dead Zone"] = "데드존"
L["Radius of head movement not affecting the camera. (See explanation below.)"] = "카메라에 영향을 미치지 않는 머리 움직임의 반경입니다. (아래 설명 참조)"
L["(slider value devided by 10)"] = "(슬라이더 값을 10으로 나눔)"
L["Requires /reload to come into effect!"] = "적용하려면 /reload가 필요합니다!"
L["<headTracking_desc>"] = "With head tracking enabled the camera follows the movement of your character's head. (While this can be a benefit for immersion, it may also cause nausea if you are prone to motion sickness.)\n\nThe \"Strength\" setting determines the intensity of this effect. Setting it to 0 disables head tracking. The \"Inertia\" setting determines how fast the camera reacts to head movements. Setting it to 0 also disables head tracking. The three cases \"standing\", \"moving\" and \"first person\" can be set up individually. There is no \"Strength\" setting for \"first person\" as it assumes the \"Strength\" settings of \"standing\" and \"moving\" respectively. If you want to enable or disable \"first person\" exclusively, use the \"Inertia\" sliders to disable the unwanted cases.\n\nWith the \"Range Scale\" setting you can set the camera distance beyond which head tracking is reduced or disabled. For example, with the slider set to 30 you will have no head tracking when the camera is more than 30 yards away from your character. However, there is a gradual transition from full head tracking to no head tracking, which starts at one third of the slider value. For example, with the slider value set to 30 you have full head tracking when the camera is closer than 10 yards. Beyond 10 yards, head tracking gradually decreases until it is completely gone beyond 30 yards. Hence, the slider's maximum value is 117 allowing for full head tracking at the maximum camera distance of 39 yards. (Hint: Use DynamicCam's \"Mouse Zoom\" visual aid to track the current camera distance while setting this up.)\n\nThe \"Dead Zone\" setting can be used to ignore smaller head movements. Setting it to 0 has the camera follow every slightest head movement, whereas setting it to a greater value results in it following only greater movements. Notice, that changing this setting only comes into effect after reloading the UI (type /reload into the console)."


--------------------------------------------------------------------------------
-- Situations Tab
--------------------------------------------------------------------------------
L["Situations"] = "상황"
L["Select a situation to setup"] = "설정할 상황 선택"
L["<selectedSituation_desc>"] = "\n|cffffcc00Colour codes:|r\n|cFF808A87- Disabled situation.|r\n- Enabled situation.\n|cFF00FF00- Enabled and currently active situation.|r\n|cFF63B8FF- Enabled situation with fulfilled condition but lower priority than the currently active situation.|r\n|cFFFF6600- Modified stock \"Situation Controls\" (reset recommended).|r\n|cFFEE0000- Erroneous \"Situation Controls\" (fixing required).|r"
L["If this box is checked, DynamicCam will enter the situation \"%s\" whenever its condition is fulfilled and no other situation with higher priority is active."] = "이 상자가 선택되어 있으면, 조건이 충족되고 우선 순위가 더 높은 다른 상황이 활성 상태가 아닐 때마다 DynamicCam이 \\\"%s\\\" 상황으로 진입합니다."
L["Custom:"] = "사용자 지정:"
L["(modified)"] = "(수정됨)"
L["Delete custom situation \"%s\".\n|cFFEE0000Attention: There will be no 'Are you sure?' prompt!|r"] = "사용자 지정 상황 \\\"%s\\\" 삭제.\n|cFFEE0000주의: '정말 삭제하시겠습니까?' 메시지가 표시되지 않습니다!|r"
L["Create a new custom situation."] = "새 사용자 지정 상황 만들기."


--------------------------------------------------------------------------------
-- Situation Actions - General
--------------------------------------------------------------------------------
L["Situation Actions"] = "상황 동작"
L["Setup stuff to happen while in a situation or when entering/exiting it."] = "상황에 있는 동안이나 상황에 진입/종료할 때 발생할 작업을 설정합니다."
L["Transition Time"] = "전환 시간"
L["Enter Transition Time"] = "진입 전환 시간"
L["The time in seconds for the transition when ENTERING this situation."] = "이 상황에 진입할 때 전환에 걸리는 시간(초)입니다."
L["Exit Transition Time"] = "종료 전환 시간"
L["The time in seconds for the transition when EXITING this situation."] = "이 상황에서 나갈 때 전환에 걸리는 시간(초)입니다."
L["<transitionTime_desc>"] = [[이 전환 시간은 상황 간의 전환이 얼마나 오래 걸리는지를 제어합니다.

상황에 진입할 때 "진입 전환 시간"은 다음 용도로 사용됩니다:
  • 줌 전환 ("줌/시점"이 활성화되어 있고 저장된 줌을 복원하지 않을 때)
  • 카메라 회전 ("회전"이 활성화된 경우)
    - "연속" 회전의 경우: 회전 속도까지 가속하는 시간
    - "각도" 회전의 경우: 회전을 완료하는 시간
  • UI 숨기기 ("인터페이스 숨기기"가 활성화된 경우)

상황을 나갈 때 "종료 전환 시간"은 다음 용도로 사용됩니다:
  • 줌 복원 ("줌 복원" 설정에서 저장된 줌으로 돌아갈 때)
  • 카메라 회전 종료 ("회전"이 활성화된 경우)
    - "연속" 회전의 경우: 회전 속도에서 정지까지 감속 시간
    - "되돌리기"가 있는 "각도" 회전의 경우: 되돌리는 시간
  • 카메라 되돌리기 ("되돌리기"가 활성화된 경우)
  • UI 표시 ("인터페이스 숨기기"가 활성화된 경우)

중요: 한 상황에서 다른 상황으로 직접 전환할 때, 대부분의 기능에 대해 새 상황의 진입 시간이 이전 상황의 종료 시간보다 우선합니다. 그러나 줌이 복원되는 경우에는 대신 이전 상황의 종료 시간이 사용됩니다.

참고: 진입 스크립트에서 "this.timeToEnter"로 전환 시간을 설정하면 여기의 설정보다 우선합니다.]]


--------------------------------------------------------------------------------
-- Situation Actions - Zoom/View
--------------------------------------------------------------------------------
L["Zoom/View"] = "줌/시점"
L["Zoom to a certain zoom level or switch to a saved camera view when entering this situation."] = "이 상황에 진입할 때 특정 줌 레벨로 줌하거나 저장된 카메라 시점으로 전환합니다."
L["Set Zoom or Set View"] = "줌 설정 또는 시점 설정"
L["Zoom Type"] = "줌 유형"
L["<viewZoomType_desc>"] = "줌 설정: 전환 시간 및 줌 조건에 대한 고급 옵션과 함께 지정된 줌 레벨로 줌합니다.\n\n시점 설정: 고정된 줌 레벨과 카메라 각도로 구성된 저장된 카메라 시점으로 전환합니다."
L["Set Zoom"] = "줌 설정"
L["Set View"] = "시점 설정"
L["Set view to saved view:"] = "저장된 시점으로 시점 설정:"
L["Select the saved view to switch to when entering this situation."] = "이 상황에 진입할 때 전환할 저장된 시점을 선택하십시오."
L["Instant"] = "즉시"
L["Make view transitions instant."] = "시점 전환을 즉시 실행합니다."
L["Restore view when exiting"] = "종료 시 시점 복원"
L["When exiting the situation restore the camera position to what it was at the time of entering the situation."] = "상황을 종료할 때 카메라 위치를 상황에 진입했던 시점의 상태로 복원합니다."
L["cameraSmoothNote"] = [[|cFFEE0000주의:|r 카메라를 플레이어 뒤에 자동으로 배치하는 WoW의 "시점 전환 방식"을 사용하고 있습니다. 이는 사용자 지정 저장된 시점에 있는 동안에는 작동하지 않습니다. 카메라 추적이 필요하지 않은 상황(예: NPC 상호작용)에는 사용자 지정 저장된 시점을 사용할 수 있습니다. 하지만 상황을 종료한 후에는 카메라 추적이 다시 작동하도록 비사용자 지정 기본 시점으로 돌아가야 합니다.]]
L["Restore to default view:"] = "기본 시점으로 복원:"
L["<viewRestoreToDefault_desc>"] = [[이 상황을 종료할 때 돌아갈 기본 시점을 선택하십시오.

시점 1:   줌 0, 기울기 0
시점 2:   줌 5.5, 기울기 10
시점 3:   줌 5.5, 기울기 20
시점 4:   줌 13.8, 기울기 30
시점 5:   줌 13.8, 기울기 10]]
L["You are using the same view as saved view and as restore-to-default view. Using a view as restore-to-default view will reset it. Only do this if you really want to use it as a non-customized saved view."] = "설정하려는 저장된 시점과 복원하려는 기본 시점이 동일합니다. 시점을 기본값으로 복원하는 데 사용하면 해당 시점이 초기화됩니다. 비사용자 지정 저장된 시점으로 정말 사용하려는 경우에만 이 작업을 수행하십시오."
L["View %s is used as saved view in the situations:\n%sand as restore-to-default view in the situations:\n%s"] = "시점 %s(은)는 다음 상황에서 저장된 시점으로 사용됩니다:\n%s그리고 다음 상황에서 기본값으로 복원 시점으로 사용됩니다:\n%s"
L["<view_desc>"] = [[WoW는 최대 5개의 사용자 지정 카메라 시점을 저장할 수 있습니다. 시점 1은 DynamicCam에서 상황에 진입할 때 카메라 위치를 저장하는 데 사용되므로, 위의 "복원" 상자를 선택하면 상황을 다시 종료할 때 복원될 수 있습니다. 이는 NPC 상호작용과 같은 짧은 상황에 특히 유용하며, NPC와 대화하는 동안 한 시점으로 전환했다가 나중에 카메라가 이전에 있던 상태로 돌아갈 수 있게 해줍니다. 따라서 위의 저장된 시점 드롭다운 메뉴에서 시점 1을 선택할 수 없습니다.

시점 2, 3, 4, 5는 사용자 지정 카메라 위치를 저장하는 데 사용할 수 있습니다. 시점을 저장하려면 카메라를 원하는 줌과 각도로 가져오기만 하면 됩니다. 그런 다음 콘솔에 다음 명령을 입력하십시오(#은 시점 번호 2, 3, 4 또는 5):

  /saveView #

또는 줄여서:

  /sv #

저장된 시점은 WoW에 저장됩니다. DynamicCam은 사용할 시점 번호만 저장합니다. 따라서 시점이 포함된 새 DynamicCam 상황 프로필을 가져올 때 나중에 적절한 시점을 설정하고 저장해야 할 것입니다.


DynamicCam은 상황 진입 또는 종료와 관계없이 시점으로 전환할 수 있는 콘솔 명령도 제공합니다:

  /setView #

시점 전환을 즉시 실행하려면 시점 번호 뒤에 "i"를 추가하십시오. 예: 저장된 시점 3으로 즉시 전환하려면 다음을 입력하십시오:

  /setView 3 i

]]
L["<zoomType_desc>"] = "\nSet: Always set the zoom to this value.\n\nOut: Only set the zoom, if the camera is currently closer than this.\n\nIn: Only set the zoom, if the camera is currently further away than this.\n\nRange: Zoom in, if further away than the given maximum. Zoom out, if closer than the given minimum. Do nothing, if the current zoom is within the [min, max] range."
L["Set"] = "설정"
L["Out"] = "줌 아웃"
L["In"] = "줌 인"
L["Range"] = "범위"
L["Don't slow"] = "느리게 하지 않음"
L["Zoom transitions may be executed faster (but never slower) than the specified time above, if the \"Camera Zoom Speed\" (see \"Mouse Zoom\" settings) allows."] = " \\\"카메라 줌 속도\\\"( \\\"마우스 줌\\\" 설정 참조)가 허용하는 경우 줌 전환이 위에 지정된 시간보다 더 빠르게(절대 더 느리게는 아님) 실행될 수 있습니다."
L["Zoom Value"] = "줌 값"
L["Zoom to this zoom level."] = "이 줌 레벨로 줌합니다."
L["Zoom out to this zoom level, if the current zoom level is less than this."] = "현재 줌 레벨이 이보다 작으면 이 줌 레벨로 줌 아웃합니다."
L["Zoom in to this zoom level, if the current zoom level is greater than this."] = "현재 줌 레벨이 이보다 크면 이 줌 레벨로 줌 인합니다."
L["Zoom Min"] = "최소 줌"
L["Zoom Max"] = "최대 줌"
L["Restore Zoom"] = "줌 복원"
L["<zoomRestoreSetting_desc>"] = "상황을 종료하거나(또는 활성 상황이 없는 기본 상태를 종료하거나) 현재 줌 레벨이 임시로 저장되어 다음 번에 이 상황에 진입할 때 복원될 수 있습니다. 여기서 이것이 처리되는 방식을 선택할 수 있습니다.\n\n이 설정은 모든 상황에 대해 전역적입니다."
L["Restore Zoom Mode"] = "줌 복원 모드"
L["<zoomRestoreSettingSelect_desc>"] = "\n안 함: 상황에 진입할 때 진입 상황의 실제 줌 설정(있는 경우)이 적용됩니다. 저장된 줌은 고려되지 않습니다.\n\n항상: 상황에 진입할 때 이 상황의 마지막으로 저장된 줌이 사용됩니다. 실제 설정은 로그인 후 처음 상황에 진입할 때만 고려됩니다.\n\n적응형: 저장된 줌은 특정 상황에서만 사용됩니다. 예: 왔던 것과 동일한 상황으로 돌아갈 때나 저장된 줌이 상황의 \\\"줌 인\\\", \\\"줌 아웃\\\" 또는 \\\"범위\\\" 줌 설정 기준을 충족할 때만 사용됩니다."
L["Never"] = "안 함"
L["Always"] = "항상"
L["Adaptive"] = "적응형"
L["<zoom_desc>"] = [[현재 줌 레벨을 확인하려면 "시각 보조"(DynamicCam의 "마우스 줌" 설정에서 켜기/끄기)를 사용하거나 콘솔 명령을 사용할 수 있습니다:

  /zoomInfo

또는 줄여서:

  /zi]]


--------------------------------------------------------------------------------
-- Situation Actions - Rotation
--------------------------------------------------------------------------------
L["Rotation"] = "회전"
L["Start a camera rotation when this situation is active."] = "이 상황이 활성 상태일 때 카메라 회전을 시작합니다."
L["Rotation Type"] = "회전 유형"
L["<rotationType_desc>"] = "\n지속적: 이 상황이 활성 상태인 동안 카메라가 수평으로 계속 회전합니다. 마우스로 카메라를 이동하지 않는 상황(예: 순간이동 주문 시전, 택시 또는 자리 비움)에만 권장됩니다. 지속적인 수직 회전은 위나 아래에서 보는 수직 시점에서 멈추기 때문에 불가능합니다.\n\n각도별: 상황에 진입한 후, 현재 카메라 요(수평) 및/또는 피치(수직)를 주어진 각도만큼 변경합니다."
L["Continuously"] = "지속적"
L["By Degrees"] = "각도별"
L["Rotation Speed"] = "회전 속도"
L["Speed at which to rotate in degrees per second. You can manually enter values between -900 and 900, if you want to get yourself really dizzy..."] = "초당 각도로 회전하는 속도입니다. 정말 어지러움을 느끼고 싶다면 -900에서 900 사이의 값을 수동으로 입력할 수 있습니다..."
L["Yaw (-Left/Right+)"] = "요 (-왼쪽/오른쪽+)"
L["Degrees to yaw (left or right)."] = "요 각도 (왼쪽 또는 오른쪽)."
L["Pitch (-Down/Up+)"] = "피치 (-아래/위+)"
L["Degrees to pitch (up or down). There is no going beyond the perpendicular upwards or downwards view."] = "피치 각도 (위 또는 아래). 위나 아래에서 보는 수직 시점을 넘어갈 수는 없습니다."
L["Rotate Back"] = "회전 복귀"
L["<rotateBack_desc>"] = "상황을 종료할 때, 상황에 진입한 이후 회전한 각도(모듈로 360)만큼 뒤로 회전합니다. 그 사이에 마우스로 시야각을 변경하지 않았다면, 사실상 진입 전의 카메라 위치로 되돌아갑니다.\n\n자체 회전 설정이 있는 새로운 상황에 진입하는 경우, 종료되는 상황의 \\\"회전 복귀\\\"는 무시됩니다."


--------------------------------------------------------------------------------
-- Situation Actions - Fade Out UI
--------------------------------------------------------------------------------
L["Fade Out UI"] = "인터페이스 숨기기"
L["Fade out or hide (parts of) the UI when this situation is active."] = "이 상황이 활성 상태일 때 UI의 (일부분을) 흐리게 하거나 숨깁니다."
L["Adjust to Immersion"] = "Immersion에 맞추기"
L["<adjustToImmersion_desc>"] = "많은 사람들이 DynamicCam과 함께 Immersion 애드온을 사용합니다. Immersion에는 NPC 상호작용 중에 적용되는 자체 UI 숨기기 기능이 있습니다. 특정 상황에서는 DynamicCam의 UI 숨기기 기능이 Immersion의 기능을 덮어씁니다. 이를 방지하려면 여기 DynamicCam에서 원하는 설정을 지정하십시오. 이 버튼을 클릭하면 Immersion과 동일한 페이드 인 및 페이드 아웃 시간을 사용합니다. 더 많은 옵션을 보려면 Ludius의 다른 애드온인 \\\"Immersion ExtraFade\\\"를 확인하십시오."
L["Hide entire UI"] = "전체 UI 숨기기"
L["<hideEntireUI_desc>"] = "There is a difference between a \"hidden\" UI and a \"just faded out\" UI: the faded-out UI elements have an opacity of 0 but can still be interacted with. Since DynamicCam 2.0 we are automatically hiding most UI elements if their opacity is 0. Thus, this option of hiding the entire UI after fade out is more of a relic. A reason to still use it may be to avoid unwanted interactions (e.g. mouse-over tooltips) of UI elements DynamicCam is still not hiding properly.\n\nThe opacity of the hidden UI is of course 0, so you cannot choose a different opacity nor can you keep any UI elements visible (except the FPS indicator).\n\nDuring combat we cannot change the hidden status of protected UI elements. Hence, such elements are always set to \"just faded out\" during combat. Notice that the opacity of the Minimap \"blips\" cannot be reduced. Thus, if you try to hide the Minimap, the \"blips\" are always visible during combat.\n\nWhen you check this box for the currently active situation, it will not be applied at once, because this would also hide this settings frame. You have to enter the situation for it to take effect, which is also possible with the situation \"Enable\" checkbox above.\n\nAlso notice that hiding the entire UI cancels Mailbox or NPC interactions. So do not use it for such situations!"
L["Keep FPS indicator"] = "FPS 표시기 유지"
L["Do not fade out or hide the FPS indicator (the one you typically toggle with Ctrl + R)."] = "FPS 표시기(일반적으로 Ctrl + R로 전환하는 것)를 흐리게 하거나 숨기지 않습니다."
L["Fade Opacity"] = "숨기기 불투명도"
L["Fade the UI to this opacity when entering the situation."] = "상황에 진입할 때 UI를 이 불투명도로 흐리게 합니다."
L["Excluded UI elements"] = "제외된 UI 요소"
L["Keep Alerts"] = "알림 유지"
L["Still show alert popups from completed achievements, Covenant Renown, etc."] = "완료된 업적, 성약의 단 영예 등의 알림 팝업을 여전히 표시합니다."
L["Keep Tooltip"] = "툴팁 유지"
L["Still show the game tooltip, which appears when you hover your mouse cursor over UI or world elements."] = "UI 또는 월드 요소 위로 마우스 커서를 가져갈 때 나타나는 게임 툴팁을 여전히 표시합니다."
L["Keep Minimap"] = "미니맵 유지"
L["<keepMinimap_desc>"] = "미니맵을 흐리게 하지 않습니다.\n\n미니맵의 \\\"점\\\"의 불투명도는 줄일 수 없습니다. 이들은 UI가 불투명도 0으로 흐려질 때 전체 미니맵과 함께만 숨길 수 있습니다."
L["Keep Chat Box"] = "대화창 유지"
L["Do not fade out the chat box."] = "대화창을 흐리게 하지 않습니다."
L["Keep Tracking Bar"] = "경험치/평판 막대 유지"
L["Do not fade out the tracking bar (XP, AP, reputation)."] = "경험치/평판 막대(경험치, 유물력, 평판)를 흐리게 하지 않습니다."
L["Keep Party/Raid"] = "파티/공격대 유지"
L["Do not fade out the Party/Raid frame."] = "파티/공격대 프레임을 흐리게 하지 않습니다."
L["Keep Encounter Frame (Skyriding Vigor)"] = "우두머리 프레임 유지 (하늘비행 활력)"
L["Do not fade out the Encounter Frame, which while skyriding is the Vigor display."] = "하늘비행 중에는 활력 표시인 우두머리 프레임을 흐리게 하지 않습니다."
L["Keep additional frames"] = "추가 프레임 유지"
L["<keepCustomFrames_desc>"] = "아래 텍스트 상자를 사용하면 NPC 상호작용 중에 유지하려는 프레임을 정의할 수 있습니다.\n\n프레임 이름을 알아보려면 콘솔 명령 /fstack을 사용하십시오.\n\n예를 들어, 해당 아이콘을 클릭하여 NPC 상호작용 중에 탈것에서 내릴 수 있도록 미니맵 옆의 버프 아이콘을 유지하고 싶을 수 있습니다."
L["Custom frames to keep"] = "유지할 사용자 지정 프레임"
L["Separated by commas."] = "쉼표로 구분합니다."
L["Emergency Fade In"] = "비상 보이기"
L["Pressing Esc fades the UI back in."] = "Esc 키를 누르면 UI가 다시 나타납니다."
L["<emergencyShow_desc>"] = [[때로는 일반적으로 숨겨지기를 원하는 상황에서도 UI를 표시해야 할 때가 있습니다. DynamicCam의 이전 버전에서는 Esc 키를 누를 때마다 UI가 표시되도록 설정했습니다. 단점은 창 닫기, 주문 시전 취소 등 다른 목적으로 Esc 키를 사용할 때도 UI가 표시된다는 것입니다. 위의 확인란을 선택 취소하면 이 기능이 비활성화됩니다.

하지만 이 방식으로 UI에 접근할 수 없게 될 수도 있습니다! Esc 키에 대한 더 나은 대안은 현재 상황의 \"인터페이스 숨기기\" 설정에 따라 UI를 표시하거나 숨기는 다음 콘솔 명령입니다:

    /showUI
    /hideUI

편리한 보이기 단축키를 위해 매크로에 /showUI를 넣고 \"bindings-cache.wtf\" 파일에서 키를 할당하십시오. 예:

    bind ALT+F11 MACRO 매크로 이름

\"bindings-cache.wtf\" 파일을 편집하는 것이 부담스럽다면 \"BindPad\"와 같은 단축키 애드온을 사용할 수 있습니다.

인수 없이 /showUI 또는 /hideUI를 사용하면 현재 상황의 보이기 또는 숨기기 시간이 적용됩니다. 하지만 다른 전환 시간을 제공할 수도 있습니다. 예:

    /showUI 0

지연 없이 UI를 표시합니다.]]
L["<hideUIHelp_desc>"] = "원하는 UI 숨기기 효과를 설정하는 동안 이 \\\"인터페이스\\\" 설정 프레임도 흐려지면 성가실 수 있습니다. 이 상자가 선택되어 있으면 흐려지지 않습니다.\n\n이 설정은 모든 상황에 대해 전역적입니다."
L["Do not fade out this \"Interface\" settings frame."] = "이 \\\"인터페이스\\\" 설정 프레임을 흐리게 하지 않습니다."


--------------------------------------------------------------------------------
-- Situation Controls
--------------------------------------------------------------------------------
L["Situation Controls"] = "상황 제어"
L["<situationControls_help>"] = "여기서 상황이 활성화되는 시기를 제어합니다. WoW UI API에 대한 지식이 필요할 수 있습니다. DynamicCam의 원본 상황에 만족한다면 이 섹션을 무시하십시오. 그러나 사용자 지정 상황을 만들고 싶다면 여기서 원본 상황을 확인할 수 있습니다. 수정할 수도 있지만 주의하십시오. 변경된 설정은 향후 버전의 DynamicCam에서 중요한 업데이트를 도입하더라도 유지됩니다.\n\n"
L["Priority"] = "우선 순위"
L["The priority of this situation.\nMust be a number."] = "이 상황의 우선 순위입니다.\n숫자여야 합니다."
L["Restore stock setting"] = "원본 설정 복원"
L["Your \"Priority\" deviates from the stock setting for this situation (%s). Click here to restore it."] = "사용자의 \\\"우선 순위\\\"가 이 상황(%s)에 대한 원본 설정과 다릅니다. 복원하려면 여기를 클릭하십시오."
L["<priority_desc>"] = "여러 다른 DynamicCam 상황의 조건이 동시에 충족되면 가장 높은 우선 순위를 가진 상황이 진입됩니다. 예를 들어 \\\"전드 (실내)\\\"의 조건이 충족될 때마다 \\\"월드\\\"의 조건도 충족됩니다. 그러나 \\\"월드 (실내)\\\"가 \\\"월드\\\"보다 우선 순위가 높기 때문에 우선시됩니다. 위의 드롭다운 메뉴에서 모든 상황의 우선 순위를 확인할 수도 있습니다.\n\n"
L["Events"] = "일정"
L["Your \"Events\" deviate from the default for this situation. Click here to restore them."] = "사용자의 \\\"일정\\\"이 이 상황에 대한 원본과 다릅니다. 복원하려면 여기를 클릭하십시오."
L["<events_desc>"] = [[여기서 해당되는 경우 진입하거나 종료하기 위해 DynamicCam이 이 상황의 조건을 확인해야 하는 모든 게임 내 일정을 정의합니다.

WoW의 이벤트 기록을 사용하여 게임 내 일정에 대해 알아볼 수 있습니다.
열려면 콘솔에 다음을 입력하십시오:

  /eventtrace

모든 가능한 일정 목록은 여기에서도 찾을 수 있습니다:
https://warcraft.wiki.gg/wiki/Events

]]
L["Initialisation"] = "초기화"
L["Initialisation Script"] = "초기화 스크립트"
L["Lua code using the WoW UI API."] = "WoW UI API를 사용하는 Lua 코드."
L["Your \"Initialisation Script\" deviates from the stock setting for this situation. Click here to restore it."] = "사용자의 \\\"초기화 스크립트\\\"가 이 상황에 대한 원본 설정과 다릅니다. 복원하려면 여기를 클릭하십시오."
L["<initialisation_desc>"] = [[상황의 초기화 스크립트는 DynamicCam이 로드될 때(그리고 상황이 수정될 때) 한 번 실행됩니다. 일반적으로 다른 스크립트(조건, 진입 시, 종료 시)에서 재사용하려는 내용을 여기에 넣습니다. 이렇게 하면 다른 스크립트를 조금 더 짧게 만들 수 있습니다.

예를 들어 \"귀환석/순간이동\" 상황의 초기화 스크립트는 순간이동 주문의 주문 ID를 포함하는 테이블 \"this.spells\"를 정의합니다. 그러면 조건 스크립트는 실행될 때마다 \"this.spells\"에 간단히 액세스할 수 있습니다.

이 예와 같이 \"this\" 테이블에 넣어 상황의 스크립트 간에 데이터 개체를 공유할 수 있습니다.

]]
L["Condition"] = "조건"
L["Condition Script"] = "조건 스크립트"
L["Lua code using the WoW UI API.\nShould return \"true\" if and only if the situation should be active."] = "WoW UI API를 사용하는 Lua 코드.\n상황이 활성화되어야 하는 경우에만 \\\"true\\\"를 반환해야 합니다."
L["Your \"Condition Script\" deviates from the stock setting for this situation. Click here to restore it."] = "사용자의 \\\"조건 스크립트\\\"가 이 상황에 대한 원본 설정과 다릅니다. 복원하려면 여기를 클릭하십시오."
L["<condition_desc>"] = [[상황의 조건 스크립트는 이 상황의 게임 내 일정이 트리거될 때마다 실행됩니다. 스크립트는 이 상황이 활성화되어야 하는 경우에만 \"true\"를 반환해야 합니다.

예를 들어 \"도시\" 상황의 조건 스크립트는 WoW API 함수 \"IsResting()\"을 사용하여 현재 휴식 지역에 있는지 확인합니다:

  return IsResting()

마찬가지로 \"도시 (실내)\" 상황의 조건 스크립트도 WoW API 함수 \"IsIndoors()\"를 사용하여 실내에 있는지 확인합니다:

  return IsResting() and IsIndoors()

WoW API 함수 목록은 여기에서 찾을 수 있습니다:
https://warcraft.wiki.gg/wiki/World_of_Warcraft_API

]]
L["Entering"] = "진입"
L["On-Enter Script"] = "진입 시 스크립트"
L["Your \"On-Enter Script\" deviates from the stock setting for this situation. Click here to restore it."] = "사용자의 \\\"진입 시 스크립트\\\"가 이 상황에 대한 원본 설정과 다릅니다. 복원하려면 여기를 클릭하십시오."
L["<executeOnEnter_desc>"] = [[상황의 진입 시 스크립트는 상황에 진입할 때마다 실행됩니다.

지금까지 이에 대한 유일한 예는 \"귀환석/순간이동\" 상황으로, WoW API 함수 \"UnitCastingInfo()\"를 사용하여 현재 주문의 시전 시간을 결정합니다. 그런 다음 이를 변수 \"this.timeToEnter\" 및 \"this.timeToEnter\"에 할당하여 줌 또는 회전(\"상황 동작\" 참조)이 주문 시전만큼 정확하게 걸리도록 할 수 있습니다. (모든 순간이동 주문의 시전 시간이 같은 것은 아닙니다.)

]]
L["Exiting"] = "종료"
L["On-Exit Script"] = "종료 시 스크립트"
L["Your \"On-Exit Script\" deviates from the stock setting for this situation. Click here to restore it."] = "사용자의 \\\"종료 시 스크립트\\\"가 이 상황에 대한 원본 설정과 다릅니다. 복원하려면 여기를 클릭하십시오."
L["Exit Delay"] = "종료 지연"
L["Wait for this many seconds before exiting this situation."] = "이 상황을 종료하기 전에 이 시간(초) 동안 기다립니다."
L["Your \"Exit Delay\" deviates from the stock setting for this situation. Click here to restore it."] = "사용자의 \\\"종료 지연\\\"이 이 상황에 대한 원본 설정과 다릅니다. 복원하려면 여기를 클릭하십시오."
L["<executeOnExit_desc>"] = [[상황의 종료 시 스크립트는 상황을 종료할 때마다 실행됩니다. 지금까지 이를 사용하는 상황은 없습니다.

지연은 상황을 종료하기 전에 기다릴 초 수를 결정합니다. 지금까지 이에 대한 유일한 예는 "낚시" 상황으로, 지연 시간 동안 상황을 종료하지 않고 낚싯대를 다시 던질 수 있습니다.

]]
L["Export"] = "내보내기"
L["Coming soon(TM)."] = "곧 출시(TM)."
L["Import"] = "가져오기"
L["Restore all stock Situation Controls"] = "모든 원본 상황 제어 복원"


--------------------------------------------------------------------------------
-- About / Profiles
--------------------------------------------------------------------------------
L["Hello and welcome to DynamicCam!"] = "안녕하세요, DynamicCam에 오신 것을 환영합니다!"
L["<welcomeMessage>"] = [[여기에 오신 것을 기쁘게 생각하며 애드온과 함께 즐거운 시간을 보내시길 바랍니다.

DynamicCam(DC)은 블리자드의 WoW 개발자가 실험적인 ActionCam 기능을 게임에 도입한 2016년 5월 mpstark에 의해 시작되었습니다. DC의 주요 목적은 ActionCam 설정에 대한 사용자 인터페이스를 제공하는 것이었습니다. 게임 내에서 ActionCam은 여전히 "실험적"으로 지정되어 있으며 블리자드에서 더 개발하겠다는 징후는 없습니다. 몇 가지 단점이 있지만 ActionCam이 우리와 같은 애호가들을 위해 게임에 남겨진 것에 감사해야 합니다. :-) DC를 사용하면 ActionCam 설정을 변경할 수 있을 뿐만 아니라 다양한 게임 상황에 대해 다른 설정을 가질 수 있습니다. ActionCam과 관련 없이 DC는 카메라 줌 및 UI 페이드 아웃에 관한 기능도 제공합니다.

DC에 대한 mpstark의 작업은 2018년 8월까지 계속되었습니다. 대부분의 기능이 상당수의 사용자 기반에서 잘 작동했지만, mpstark는 항상 DC를 베타 상태로 간주했으며 WoW에 대한 관심이 줄어들어 작업을 재개하지 않게 되었습니다. 그 당시 Ludius는 이미 자신을 위해 DC를 조정하기 시작했으며, 이는 2020년 초 mpstark와 연락하는 데 성공한 Weston(일명 dernPerkins)에 의해 주목을 받아 Ludius가 개발을 인수하게 되었습니다. 최초의 비베타 버전 1.0은 2020년 5월에 출시되었으며 그 시점까지 Ludius의 조정 사항이 포함되었습니다. 그 후 Ludius는 DC의 정밀 검사 작업을 시작하여 2022년 가을에 버전 2.0이 출시되었습니다.

mpstark가 DC를 시작했을 때 그의 초점은 소스 코드를 변경할 필요 없이 대부분의 사용자 지정을 게임 내에서 수행하는 것이었습니다. 이를 통해 특히 다양한 게임 상황을 더 쉽게 실험할 수 있었습니다. 버전 2.0부터 이러한 고급 설정은 "상황 제어"라는 특수 섹션으로 이동되었습니다. 대부분의 사용자는 아마도 필요하지 않겠지만 "고급 사용자"를 위해 여전히 사용할 수 있습니다. 거기서 변경하는 것의 위험은 새로운 버전의 DC가 업데이트된 원본 설정을 가져오더라도 저장된 사용자 설정이 항상 DC의 원본 설정을 덮어쓴다는 것입니다. 따라서 수정된 "상황 제어"가 있는 원본 상황이 있을 때마다 이 페이지 상단에 경고가 표시됩니다.

DC의 원본 상황 중 하나를 변경해야 한다고 생각되면 언제든지 변경 사항으로 사본을 만들 수 있습니다. 이 새로운 상황을 내보내고 DC의 CurseForge 페이지에 게시해 주십시오. 그런 다음 자체적인 새로운 원본 상황으로 추가할 수 있습니다. 또한 DC 프로필 전체를 내보내고 게시하는 것도 환영합니다. 신규 사용자가 DC에 더 쉽게 진입할 수 있도록 하는 새로운 프로필 사전 설정을 항상 찾고 있기 때문입니다. 문제를 발견하거나 제안을 하고 싶다면 CurseForge 댓글에 메모를 남기거나 GitHub의 Issues를 사용하는 것이 더 좋습니다. 기여하고 싶다면 거기에서 풀 리퀘스트를 여는 것도 환영합니다.

다음은 몇 가지 유용한 슬래시 명령어입니다.

    `/dynamiccam` 또는 `/dc` 이 메뉴를 엽니다.
    `/zoominfo` 또는 `/zi` 현재 줌 레벨을 출력합니다.

    `/zoom #1 #2` #2초 동안 줌 레벨 #1로 줌합니다.
    `/yaw #1 #2` #2초 동안 카메라를 #1도 회전합니다(#1이 음수이면 오른쪽으로 회전).
    `/pitch #1 #2` 카메라를 #1도 피치합니다(#1이 음수이면 위로 피치).


]]
L["About"] = "정보"
L["The following game situations have \"Situation Controls\" deviating from DynamicCam's stock settings.\n\n"] = "다음 게임 상황에는 DynamicCam의 원본 설정과 다른 \\\"상황 제어\\\"가 있습니다.\n\n"
L["<situationControlsWarning>"] = "\n의도적으로 이렇게 하는 경우 괜찮습니다. DynamicCam 개발자의 이러한 설정 업데이트는 항상 수정된(아마도 오래된) 버전에 의해 덮어쓰여진다는 점을 유의하십시오. 자세한 내용은 각 상황의 \\\"상황 제어\\\" 탭을 확인할 수 있습니다. 귀하 측의 \\\"상황 제어\\\" 수정 사항을 알지 못하고 단순히 *모든* 상황에 대한 원본 제어 설정을 복원하려면 다음 버튼을 누르십시오."
L["Profiles"] = "프로필"
L["Manage Profiles"] = "프로필 관리"
L["<manageProfilesWarning>"] = "Like many addons, DynamicCam uses the \"AceDB-3.0\" library to manage profiles. What you have to understand is that there is nothing like \"Save Profile\" here. You can only create new profiles and you can copy settings from another profile into the currently active one. Whatever change you make for the currently active profile is immediately saved! There is nothing like \"cancel\" or \"discard changes\". The \"Reset Profile\" button only resets to the global default profile.\n\nSo if you like your DynamicCam settings, you should create another profile into which you copy these settings as a backup. When you don't use this backup profile as your active profile, you can experiment with the settings and return to your original profile at any time by selecting your backup profile in the \"Copy from\" box.\n\nIf you want to switch profiles via macro, you can use the following:\n/run DynamicCam.db:SetProfile(\"Profile name here\")\n\n"
L["Profile presets"] = "프로필 사전 설정"
L["Import / Export"] = "가져오기 / 내보내기"


--------------------------------------------------------------------------------
-- MouseZoom.lua
--------------------------------------------------------------------------------
L["Current\nZoom\nValue"] = "현재\n줌\n값"
L["Reactive\nZoom\nTarget"] = "반응형\n줌\n목표"
L["Reactive Zoom"] = "반응형 줌"
L["This graph helps you to\nunderstand how\nReactive Zoom works."] = "이 그래프는 반응형 줌이\n어떻게 작동하는지 이해하는 데\n도움이 됩니다."


--------------------------------------------------------------------------------
-- ZoomBasedSettings.lua
--------------------------------------------------------------------------------
L["DynamicCam: Zoom-Based Setting"] = "DynamicCam: 줌 기반 설정"
L["CVAR: "] = "CVAR: "
L["Z\no\no\nm"] = "줌"
L["Value"] = "값"
L["Current Zoom:"] = "현재 줌:"
L["Current Value:"] = "현재 값:"
L["Left-click: add/drag point | Right-click: remove point"] = "좌클릭: 점 추가/드래그 | 우클릭: 점 제거"
L["Cancel"] = "취소"
L["OK"] = "확인"
L["Close and revert all changes made since opening this editor."] = "닫고 이 에디터를 연 이후의 모든 변경 사항을 되돌립니다."
L["Close and keep all changes."] = "닫고 모든 변경 사항을 유지합니다."
L["Zoom-based"] = "줌 기반"
L["Edit Curve"] = "곡선 편집"
L["Enable zoom-based curve for this setting.\n\nWhen enabled, the value will change smoothly based on your camera zoom level instead of using a single fixed value. Click the gear icon to edit the curve."] = "이 설정에 대해 줌 기반 곡선을 활성화합니다.\n\n활성화하면 단일 고정 값을 사용하는 대신 카메라 줌 레벨에 따라 값이 부드럽게 변경됩니다. 기어 아이콘을 클릭하여 곡선을 편집하세요."
L["Open the curve editor.\n\nAllows you to define exactly how this setting changes as you zoom in and out. You can add control points to create a custom curve."] = "곡선 에디터를 엽니다.\n\n줌 인/아웃에 따라 이 설정이 어떻게 변하는지 정확하게 정의할 수 있습니다. 제어점을 추가하여 사용자 지정 곡선을 만들 수 있습니다."


--------------------------------------------------------------------------------
-- Core.lua
--------------------------------------------------------------------------------
L["Enter name for custom situation:"] = "사용자 지정 상황의 이름 입력:"
L["Create"] = "생성"
L["While you are using horizontal camera offset, DynamicCam prevents CameraKeepCharacterCentered!"] = "수평 카메라 오프셋을 사용하는 동안 DynamicCam이 CameraKeepCharacterCentered를 방지합니다!"
L["While you are using horizontal camera offset, DynamicCam prevents CameraReduceUnexpectedMovement!"] = "수평 카메라 오프셋을 사용하는 동안 DynamicCam이 CameraReduceUnexpectedMovement를 방지합니다!"
L["While you are using vertical camera pitch, DynamicCam prevents CameraKeepCharacterCentered!"] = "수직 카메라 피치를 사용하는 동안 DynamicCam이 CameraKeepCharacterCentered를 방지합니다!"


--------------------------------------------------------------------------------
-- CvarMonitor.lua
--------------------------------------------------------------------------------
L["Disabled"] = "비활성화됨"
L["Attention"] = "주의"
L["Your DynamicCam addon lets you adjust horizontal and vertical mouse look speed individually! Just go to the \"Mouse Look\" settings of DynamicCam to make the adjustments there."] = "DynamicCam 애드온을 사용하면 수평 및 수직 마우스 시점 속도를 개별적으로 조정할 수 있습니다! DynamicCam의 \\\"마우스 시점\\\" 설정으로 이동하여 조정하십시오."
L["The \"%s\" setting is disabled by DynamicCam, while you are using the horizontal camera over shoulder offset."] = "수평 카메라 어깨 위 시점 오프셋을 사용하는 동안 DynamicCam에 의해 \\\"%s\\\" 설정이 비활성화됩니다."
L["cameraView=%s prevented by DynamicCam!"] = "DynamicCam에 의해 cameraView=%s 방지됨!"


--------------------------------------------------------------------------------
-- DefaultSettings.lua - Situation Names
--------------------------------------------------------------------------------
L["City"] = "도시"
L["City (Indoors)"] = "도시 (실내)"
L["World"] = "월드"
L["World (Indoors)"] = "월드 (실내)"
L["World (Combat)"] = "월드 (전투)"
L["Dungeon/Scenario"] = "던전/시나리오"
L["Dungeon/Scenario (Outdoors)"] = "던전/시나리오 (야외)"
L["Dungeon/Scenario (Combat, Boss)"] = "던전/시나리오 (전투, 우두머리)"
L["Dungeon/Scenario (Combat, Trash)"] = "던전/시나리오 (전투, 일반)"
L["Raid"] = "공격대"
L["Raid (Outdoors)"] = "공격대 (야외)"
L["Raid (Combat, Boss)"] = "공격대 (전투, 우두머리)"
L["Raid (Combat, Trash)"] = "공격대 (전투, 일반)"
L["Arena"] = "투기장"
L["Arena (Combat)"] = "투기장 (전투)"
L["Battleground"] = "전장"
L["Battleground (Combat)"] = "전장 (전투)"
L["Mounted (any)"] = "탈것 (모두)"
L["Mounted (only flying-mount)"] = "탈것 (비행 탈것만)"
L["Mounted (only flying-mount + airborne)"] = "탈것 (비행 탈것만 + 공중)"
L["Mounted (only flying-mount + airborne + Skyriding)"] = "탈것 (비행 탈것만 + 공중 + 하늘비행)"
L["Mounted (only flying-mount + Skyriding)"] = "탈것 (비행 탈것만 + 하늘비행)"
L["Mounted (only airborne)"] = "탈것 (공중만)"
L["Mounted (only airborne + Skyriding)"] = "탈것 (공중만 + 하늘비행)"
L["Mounted (only Skyriding)"] = "탈것 (하늘비행만)"
L["Druid Travel Form"] = "드루이드 여행 변신"
L["Dracthyr Soar"] = "드랙티르 비상"
L["Skyriding Race"] = "하늘비행 경주"
L["Taxi"] = "택시"
L["Vehicle"] = "차량"
L["Hearth/Teleport"] = "귀환석/순간이동"
L["Annoying Spells"] = "성가신 주문"
L["NPC Interaction"] = "NPC 상호작용"
L["Mailbox"] = "우편함"
L["Fishing"] = "낚시"
L["Gathering"] = "채집"
L["AFK"] = "자리 비움"
L["Pet Battle"] = "애완동물 대전"
L["Professions Frame Open"] = "전문 기술 창 열림"
