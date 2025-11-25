local L = LibStub("AceLocale-3.0"):NewLocale("DynamicCam", "enUS", true)


-- Options
L["Reset"] = "Reset"
L["Reset to global default"] = "Reset to global default"
L["(To restore the settings of a specific profile, restore the profile in the \"Profiles\" tab.)"] = "(To restore the settings of a specific profile, restore the profile in the \"Profiles\" tab.)"
L["Currently overridden by the active situation \"%s\"."] = "Currently overridden by the active situation \"%s\"."
L["Override Standard Settings"] = "Override Standard Settings"
L["<overrideStandardToggle_desc>"] = "Checking this box allows you to define settings in this category that override the Standard Settings whenever this situation is active. Unchecking erases the Situation Settings for this category."
L["Standard Settings"] = "Standard Settings"
L["Situation Settings"] = "Situation Settings"
L["<standardSettings_desc>"] = "These Standard Settings are applied when either no situation is active or when the active situation has no Situation Settings set up overriding the Standard Settings."
L["<standardSettingsOverridden_desc>"] = "Categories marked in green are currently overridden by the active situation. You will thus not see any effect of changing the Standard Settings of green categories while the overriding situation is active."
L["These Situation Settings override the Standard Settings when the respective situation is active."] = "These Situation Settings override the Standard Settings when the respective situation is active."
L["Mouse Zoom"] = "Mouse Zoom"
L["Maximum Camera Distance"] = "Maximum Camera Distance"
L["How many yards the camera can zoom away from your character."] = "How many yards the camera can zoom away from your character."
L["Camera Zoom Speed"] = "Camera Zoom Speed"
L["How fast the camera can zoom."] = "How fast the camera can zoom."
L["Zoom Increments"] = "Zoom Increments"
L["How many yards the camera should travel for each \"tick\" of the mouse wheel."] = "How many yards the camera should travel for each \"tick\" of the mouse wheel."
L["Use Reactive Zoom"] = "Use Reactive Zoom"
L["Quick-Zoom Additional Increments"] = "Quick-Zoom Additional Increments"
L["How many yards per mouse wheel \"tick\" should be added when quick-zooming."] = "How many yards per mouse wheel \"tick\" should be added when quick-zooming."
L["Quick-Zoom Enter Threshold"] = "Quick-Zoom Enter Threshold"
L["How many yards the \"Reactive Zoom Target\" and the \"Current Zoom Value\" have to be apart to enter quick-zooming."] = "How many yards the \"Reactive Zoom Target\" and the \"Current Zoom Value\" have to be apart to enter quick-zooming."
L["Maximum Zoom Time"] = "Maximum Zoom Time"
L["The maximum time the camera should take to make \"Current Zoom Value\" equal to \"Reactive Zoom Target\"."] = "The maximum time the camera should take to make \"Current Zoom Value\" equal to \"Reactive Zoom Target\"."
L["Help"] = "Help"
L["Toggle Visual Aid"] = "Toggle Visual Aid"
L["<reactiveZoom_desc>"] = "With DynamicCam's Reactive Zoom the mouse wheel controls the so called \"Reactive Zoom Target\". Whenever the \"Reactive Zoom Target\" and the \"Current Zoom Value\" are different, DynamicCam changes the \"Current Zoom Value\" until it matches the \"Reactive Zoom Target\" again.\n\nHow fast this zoom change is happening depends on \"Camera Zoom Speed\" and \"Maximum Zoom Time\". If \"Maximum Zoom Time\" is set low, the zoom change will always be executed fast, regardless of the \"Camera Zoom Speed\" setting. To achieve a slower zoom change, you must set \"Maximum Zoom Time\" to a higher value and \"Camera Zoom Speed\" to a lower value.\n\nTo enable faster zooming with faster mouse wheel movement, there is \"Quick-Zoom\": if the \"Reactive Zoom Target\" is further away from the \"Current Zoom Value\" than the \"Quick-Zoom Enter Threshold\", the amount of \"Quick-Zoom Additional Increments\" is added to every mouse wheel tick.\n\nTo get a feeling of how this works, you can toggle the visual aid while finding your ideal settings. You can also freely move this graph by left-clicking and dragging it. A right-click closes it."
L["Enhanced minimal zoom-in"] = "Enhanced minimal zoom-in"
L["<enhancedMinZoom_desc>"] = "Reactive zoom makes it possible to zoom-in closer than level 1. You can achieve this by zooming out one mouse wheel tick from first person.\n\nWith \"Enhanced minimal zoom-in\" we force the camera to also stop at this minimal zoom level when zooming in, before it would snap into first person.\n\n|cFFFF0000Enabling \"Enhanced minimal zoom-in\" may cost up to 15% FPS when in CPU limited situations.|r"
L["/reload of the UI required!"] = "/reload of the UI required!"
L["Mouse Look"] = "Mouse Look"
L["Horizontal Speed"] = "Horizontal Speed"
L["How much the camera yaws horizontally when in mouse look mode."] = "How much the camera yaws horizontally when in mouse look mode."
L["Vertical Speed"] = "Vertical Speed"
L["How much the camera pitches vertically when in mouse look mode."] = "How much the camera pitches vertically when in mouse look mode."
L["<mouseLook_desc>"] = "How much the camera moves when you move the mouse in \"mouse look\" mode; i.e. while the left or right mouse button is pressed.\n\nThe \"Mouse Look Speed\" slider of WoW's default interface settings controls horizontal and vertical speed at the same time: automatically setting horizontal speed to 2 x vertical speed. DynamicCam overrides this and allows you a more customized setup."
L["Horizontal Offset"] = "Horizontal Offset"
L["Camera Over Shoulder Offset"] = "Camera Over Shoulder Offset"
L["Positions the camera left or right from your character."] = "Positions the camera left or right from your character."
L["<cameraOverShoulder_desc>"] = "For this to come into effect, DynamicCam automatically temporarily disables WoW's motion sickness setting. So if you need the Motion Sickness setting, do not use the horizontal offset in these situations.\n\nWhen you are selecting your own character, WoW automatically switches to an offset of zero. There is nothing we can do about this. We also cannot do anything about offset jerks that may occur upon camera-to-wall collisions. A workaround is to use little to no offset while indoors.\n\nFurthermore, WoW strangely applies the offest differntly depending on player model or mount. If you prefer a constant offset, Ludius is working on another addon (CameraOverShoulder Fix) to resolve this."
L["Adjust shoulder offset according to zoom level"] = "Adjust shoulder offset according to zoom level"
L["Enable"] = "Enable"
L["and"] = "and"
L["No offset when below this zoom level:"] = "No offset when below this zoom level:"
L["When the camera is closer than this zoom level, the offset has reached zero."] = "When the camera is closer than this zoom level, the offset has reached zero."
L["Real offset when above this zoom level:"] = "Real offset when above this zoom level:"
L["When the camera is further away than this zoom level, the offset has reached its set value."] = "When the camera is further away than this zoom level, the offset has reached its set value."
L["<shoulderOffsetZoom_desc>"] = "Make the shoulder offset gradually transition to zero while zooming in. The two sliders define between what zoom levels this transition takes place. This setting is global and not situation-specific."
L["Vertical Pitch"] = "Vertical Pitch"
L["Pitch (on ground)"] = "Pitch (on ground)"
L["Pitch (flying)"] = "Pitch (flying)"
L["Down Scale"] = "Down Scale"
L["Smart Pivot Cutoff Distance"] = "Smart Pivot Cutoff Distance"
L["<pitch_desc>"] = "If the camera is pitched upwards (lower \"Pitch\" value), the \"Down Scale\" setting determines how much this comes into effect while looking at your character from above. Setting \"Down Scale\" to 0 nullifies the effect of an upwards pitch while looking from above. On the contrary, while you are not looking from above or if the camera is pitched downwards (greater \"Pitch\" value), the \"Down Scale\" setting has little to no effect.\n\nThus, you should first find your preferred \"Pitch\" setting while looking at your character from behind. Afterwards, if you have chosen an upwards pitch, find your preferred \"Down Scale\" setting while looking from above.\n\n\nWhen the camera collides with the ground, it normally performs an upwards pitch on the spot of the camera-to-ground collision. An alternative is that the camera moves closer to your character's feet while performing this pitch. The \"Smart Pivot Cutoff Distance\" setting determines the distance that the camera has to be inside of to do the latter. Setting it to 0 never moves the camera closer (WoW's default), whereas setting it to the maximum zoom distance of 39 always moves the camera closer.\n\n"
L["Target Focus"] = "Target Focus"
L["Enemy Target"] = "Enemy Target"
L["Horizontal Strength"] = "Horizontal Strength"
L["Vertical Strength"] = "Vertical Strength"
L["Interaction Target (NPCs)"] = "Interaction Target (NPCs)"
L["<targetFocus_desc>"] = "If enabled, the camera automatically tries to bring the target closer to the center of the screen. The strength determines the intensity of this effect.\n\nIf \"Enemy Target Focus\" and \"Interaction Target Focus\" are both enabled, there seems to be a strange bug with the latter: When interacting with an NPC for the first time, the camera smoothly moves to its new angle as expected. But when you exit the interaction, it snaps immediately into its previous angle. When you then start the interaction again, it snaps again to the new angle. This is repeatable whenever talking to a new NPCs: only the first transition is smooth, all following are immediate.\nA workaround, if you want to use both \"Enemy Target Focus\" and \"Interaction Target Focus\", is to only activate \"Enemy Target Focus\" for DynamicCam situations in which you need it and in which NPC interactions are unlikely (like Combat)."
L["Head Tracking"] = "Head Tracking"
L["<headTrackingEnable_desc>"] = "(This could also be used as a continuous value between 0 and 1, but it is just multiplied with \"Strength (standing)\" and \"Strength (moving)\" respectively. So there is really no need for another slider.)"
L["Strength (standing)"] = "Strength (standing)"
L["Inertia (standing)"] = "Inertia (standing)"
L["Strength (moving)"] = "Strength (moving)"
L["Inertia (moving)"] = "Inertia (moving)"
L["Inertia (first person)"] = "Inertia (first person)"
L["Range Scale"] = "Range Scale"
L["Camera distance beyond which head tracking is reduced or disabled. (See explanation below.)"] = "Camera distance beyond which head tracking is reduced or disabled. (See explanation below.)"
L["(slider value transformed)"] = "(slider value transformed)"
L["Dead Zone"] = "Dead Zone"
L["Radius of head movement not affecting the camera. (See explanation below.)"] = "Radius of head movement not affecting the camera. (See explanation below.)"
L["(slider value devided by 10)"] = "(slider value devided by 10)"
L["Requires /reload to come into effect!"] = "Requires /reload to come into effect!"
L["<headTracking_desc>"] = "With head tracking enabled the camera follows the movement of your character's head. (While this can be a benefit for immersion, it may also cause nausea if you are prone to motion sickness.)\n\nThe \"Strength\" setting determines the intensity of this effect. Setting it to 0 disables head tracking. The \"Inertia\" setting determines how fast the camera reacts to head movements. Setting it to 0 also disables head tracking. The three cases \"standing\", \"moving\" and \"first person\" can be set up individually. There is no \"Strength\" setting for \"first person\" as it assumes the \"Strength\" settings of \"standing\" and \"moving\" respectively. If you want to enable or disable \"first person\" exclusively, use the \"Inertia\" sliders to disable the unwanted cases.\n\nWith the \"Range Scale\" setting you can set the camera distance beyond which head tracking is reduced or disabled. For example, with the slider set to 30 you will have no head tracking when the camera is more than 30 yards away from your character. However, there is a gradual transition from full head tracking to no head tracking, which starts at one third of the slider value. For example, with the slider value set to 30 you have full head tracking when the camera is closer than 10 yards. Beyond 10 yards, head tracking gradually decreases until it is completely gone beyond 30 yards. Hence, the slider's maximum value is 117 allowing for full head tracking at the maximum camera distance of 39 yards. (Hint: Use DynamicCam's \"Mouse Zoom\" visual aid to track the current camera distance while setting this up.)\n\nThe \"Dead Zone\" setting can be used to ignore smaller head movements. Setting it to 0 has the camera follow every slightest head movement, whereas setting it to a greater value results in it following only greater movements. Notice, that changing this setting only comes into effect after reloading the UI (type /reload into the console)."
L["Situations"] = "Situations"
L["Select a situation to setup"] = "Select a situation to setup"
L["<selectedSituation_desc>"] = "\n|cffffcc00Colour codes:|r\n|cFF808A87- Disabled situation.|r\n- Enabled situation.\n|cFF00FF00- Enabled and currently active situation.|r\n|cFF63B8FF- Enabled situation with fulfilled condition but lower priority than the currently active situation.|r\n|cFFFF6600- Modified stock \"Situation Controls\" (reset recommended).|r\n|cFFEE0000- Erroneous \"Situation Controls\" (fixing required).|r"
L["If this box is checked, DynamicCam will enter the situation \"%s\" whenever its condition is fulfilled and no other situation with higher priority is active."] = "If this box is checked, DynamicCam will enter the situation \"%s\" whenever its condition is fulfilled and no other situation with higher priority is active."
L["Custom:"] = "Custom:"
L["(modified)"] = "(modified)"
L["Delete custom situation \"%s\".\n|cFFEE0000Attention: There will be no 'Are you sure?' prompt!|r"] = "Delete custom situation \"%s\".\n|cFFEE0000Attention: There will be no 'Are you sure?' prompt!|r"
L["Create a new custom situation."] = "Create a new custom situation."
L["Situation Actions"] = "Situation Actions"
L["Setup stuff to happen while in a situation or when entering/exiting it."] = "Setup stuff to happen while in a situation or when entering/exiting it."
L["Zoom/View"] = "Zoom/View"
L["Zoom to a certain zoom level or switch to a saved camera view when entering this situation."] = "Zoom to a certain zoom level or switch to a saved camera view when entering this situation."
L["Set Zoom or Set View"] = "Set Zoom or Set View"
L["Zoom Type"] = "Zoom Type"
L["<viewZoomType_desc>"] = "Set Zoom: Zoom to a given zoom level with advanced options of transition time and zoom conditions.\n\nSet View: Switch to a saved camera view consisting of a fix zoom level and camera angle."
L["Set Zoom"] = "Set Zoom"
L["Set View"] = "Set View"
L["Set view to saved view:"] = "Set view to saved view:"
L["Select the saved view to switch to when entering this situation."] = "Select the saved view to switch to when entering this situation."
L["Instant"] = "Instant"
L["Make view transitions instant."] = "Make view transitions instant."
L["Restore view when exiting"] = "Restore view when exiting"
L["When exiting the situation restore the camera position to what it was at the time of entering the situation."] = "When exiting the situation restore the camera position to what it was at the time of entering the situation."
L["cameraSmoothNote"] = [[|cFFEE0000Attention:|r You are using WoW's "Camera Following Styles" that automatically put the camera behind the player. This does not work while you are in a customized saved view. It is possible to use customized saved views for situations in which camera following is not needed (e.g. NPC interaction). But after exiting the situation you have to return to a non-customized default view in order to make the camera following work again.]]
L["Restore to default view:"] = "Restore to default view:"
L["<viewRestoreToDefault_desc>"] = [[Select the default view to return to when exiting this situation.

View 1:   Zoom 0, Pitch 0
View 2:   Zoom 5.5, Pitch 10
View 3:   Zoom 5.5, Pitch 20
View 4:   Zoom 13.8, Pitch 30
View 5:   Zoom 13.8, Pitch 10]]
L["WARNING"] = "WARNING"
L["You are using the same view as saved view and as restore-to-default view. Using a view as restore-to-default view will reset it. Only do this if you really want to use it as a non-customized saved view."] = "You are using the same view as saved view and as restore-to-default view. Using a view as restore-to-default view will reset it. Only do this if you really want to use it as a non-customized saved view."
L["View %s is used as saved view in the situations:\n%sand as restore-to-default view in the situations:\n%s"] = "View %s is used as saved view in the situations:\n%sand as restore-to-default view in the situations:\n%s"
L["<view_desc>"] = [[WoW allows to save up to 5 custom camera views. View 1 is used by DynamicCam to save the camera position when entering a situation, such that it can be restored upon exiting the situation again, if you check the "Restore" box above. This is particularly nice for short situations like NPC interaction, allowing to switch to one view while talking to the NPC and afterwards back to what the camera was before. This is why View 1 cannot be selected in the above drop down menu of saved views.

Views 2, 3, 4 and 5 can be used to save a custom camera positions. To save a view, simply bring the camera into the desired zoom and angle. Then type the following command into the console (with # being the view number 2, 3, 4 or 5):

  /saveView #

Or for short:

  /sv #

Notice that the saved views are stored by WoW. DynamicCam only stores which view numbers to use. Thus, when you import a new DynamicCam situation profile with views, you probably have to set and save the appropriate views afterwards.


DynamicCam also provides a console command to switch to a view irrespective of entering or exiting situations:

  /setView #

To make the view transition instant, add an "i" after the view number. E.g. to immediately switch to the saved View 3 enter:

  /setView 3 i

]]
L["Zoom Transition Time"] = "Zoom Transition Time"
L["<transitionTime_desc>"] = "The time in seconds it takes to transition to the new zoom value.\n\nIf set lower than possible, the transition will be as fast as the current camera zoom speed allows (adjustable in the DynamicCam \"Mouse Zoom\" settings).\n\nIf a situation assigns the variable \"this.transitionTime\" in its on-enter script (see \"Situation Controls\"), the setting here is overriden. This is done e.g. in the \"Hearth/Teleport\" situation to allow a transition time for the duration of the spell cast."
L["<zoomType_desc>"] = "\nSet: Always set the zoom to this value.\n\nOut: Only set the zoom, if the camera is currently closer than this.\n\nIn: Only set the zoom, if the camera is currently further away than this.\n\nRange: Zoom in, if further away than the given maximum. Zoom out, if closer than the given minimum. Do nothing, if the current zoom is within the [min, max] range."
L["Set"] = "Set"
L["Out"] = "Out"
L["In"] = "In"
L["Range"] = "Range"
L["Don't slow"] = "Don't slow"
L["Zoom transitions may be executed faster (but never slower) than the specified time above, if the \"Camera Zoom Speed\" (see \"Mouse Zoom\" settings) allows."] = "Zoom transitions may be executed faster (but never slower) than the specified time above, if the \"Camera Zoom Speed\" (see \"Mouse Zoom\" settings) allows."
L["Zoom Value"] = "Zoom Value"
L["Zoom to this zoom level."] = "Zoom to this zoom level."
L["Zoom out to this zoom level, if the current zoom level is less than this."] = "Zoom out to this zoom level, if the current zoom level is less than this."
L["Zoom in to this zoom level, if the current zoom level is greater than this."] = "Zoom in to this zoom level, if the current zoom level is greater than this."
L["Zoom Min"] = "Zoom Min"
L["Zoom Max"] = "Zoom Max"
L["Restore Zoom"] = "Restore Zoom"
L["<zoomRestoreSetting_desc>"] = "When you exit a situation (or exit the default of no situation being active), the current zoom level is temporarily saved, such that it could be restored once you enter this situation the next time. Here you can select how this is handled.\n\nThis setting is global for all situations."
L["Restore Zoom Mode"] = "Restore Zoom Mode"
L["<zoomRestoreSettingSelect_desc>"] = "\nNever: When entering a situation, the actual zoom setting (if any) of the entering situation is applied. No saved zoom is taken into account.\n\nAlways: When entering a situation, the last saved zoom of this situation is used. Its actual setting is only taken into account when entering the situation for the first time after login.\n\nAdaptive: The saved zoom is only used under certain circumstances. E.g. only when returning to the same situation you came from or when the saved zoom fulfills the criteria of the situation's \"in\", \"out\" or \"range\" zoom settings."
L["Never"] = "Never"
L["Always"] = "Always"
L["Adaptive"] = "Adaptive"
L["<zoom_desc>"] = [[To determine the current zoom level, you can either use the "Visual Aid" (toggled in DynamicCam's "Mouse Zoom" settings) or use the console command:

  /zoomInfo

Or for short:

  /zi]]
L["Rotation"] = "Rotation"
L["Start a camera rotation when this situation is active."] = "Start a camera rotation when this situation is active."
L["Rotation Type"] = "Rotation Type"
L["<rotationType_desc>"] = "\nContinuously: The camera is rotating horizontally all the time while this situation is active. Only advisable for situations in which you are not mouse-moving the camera; e.g. teleport spell casting, taxi or AFK. Continuous vertical rotation is not possible as it would stop at the perpendicular upwards or downwards view.\n\nBy Degrees: After entering the situation, change the current camera yaw (horizontal) and/or pitch (vertical) by the given amount of degrees."
L["Continuously"] = "Continuously"
L["By Degrees"] = "By Degrees"
L["Acceleration Time"] = "Acceleration Time"
L["Rotation Time"] = "Rotation Time"
L["<accelerationTime_desc>"] = "If you set a time greater than 0 here, the continuous rotation will not immediately start at its full rotation speed but will take that amount of time to accelerate. (Only noticeable for relatively high rotation speeds.)"
L["<rotationTime_desc>"] = "How long it should take to assume the new camera angle. If a too small value is given here, the camera might rotate too far, because we only check once per rendered frame if the desired angle is reached.\n\nIf a situation assigns the variable \"this.rotationTime\" in its on-enter script (see \"Situation Controls\"), the setting here is overriden. This is done e.g. in the \"Hearth/Teleport\" situation to allow a rotation time for the duration of the spell cast."
L["Rotation Speed"] = "Rotation Speed"
L["Speed at which to rotate in degrees per second. You can manually enter values between -900 and 900, if you want to get yourself really dizzy..."] = "Speed at which to rotate in degrees per second. You can manually enter values between -900 and 900, if you want to get yourself really dizzy..."
L["Yaw (-Left/Right+)"] = "Yaw (-Left/Right+)"
L["Degrees to yaw (left or right)."] = "Degrees to yaw (left or right)."
L["Pitch (-Down/Up+)"] = "Pitch (-Down/Up+)"
L["Degrees to pitch (up or down). There is no going beyond the perpendicular upwards or downwards view."] = "Degrees to pitch (up or down). There is no going beyond the perpendicular upwards or downwards view."
L["Rotate Back"] = "Rotate Back"
L["<rotateBack_desc>"] = "When exiting the situation, rotate back by the amount of degrees (modulo 360) rotated since entering the situation. This effectively brings you to the pre-entering camera position, unless you have in between changed the view angle with your mouse.\n\nIf you are entering a new situation with a rotation setting of its own, the \"rotate back\" of the exiting situation is ignored."
L["Rotate Back Time"] = "Rotate Back Time"
L["<rotateBackTime_desc>"] = "The time it takes to rotate back. If a too small value is given here, the camera might rotate too far, because we only check once per rendered frame if the desired angle is reached."
L["Fade Out UI"] = "Fade Out UI"
L["Fade out or hide (parts of) the UI when this situation is active."] = "Fade out or hide (parts of) the UI when this situation is active."
L["Adjust to Immersion"] = "Adjust to Immersion"
L["<adjustToImmersion_desc>"] = "Many people use the Addon Immersion in combination with DynamicCam. Immersion has some hide UI features of its own which come into effect during NPC interaction. Under certain circumstances, DynamicCam's hide UI overrides that of Immersion. To prevent this, make your desired setting here in DynamicCam. Click this button to use the same fade-in and fade-out times as Immersion. For even more options, check out Ludius's other addon called \"Immersion ExtraFade\"."
L["Fade Out Time"] = "Fade Out Time"
L["Seconds it takes to fade out the UI when entering the situation."] = "Seconds it takes to fade out the UI when entering the situation."
L["Fade In Time"] = "Fade In Time"
L["<fadeInTime_desc>"] = "Seconds it takes to fade the UI back in when exiting the situation.\n\nWhen you transition between two situations, both of which have UI hiding enabled, the fade out time of the entering situation is used for the transition."
L["Hide entire UI"] = "Hide entire UI"
L["<hideEntireUI_desc>"] = "There is a difference between a \"hidden\" UI and a \"just faded out\" UI: the faded-out UI elements have an opacity of 0 but can still be interacted with. Since DynamicCam 2.0 we are automatically hiding most UI elements if their opacity is 0. Thus, this option of hiding the entire UI after fade out is more of a relic. A reason to still use it may be to avoid unwanted interactions (e.g. mouse-over tooltips) of UI elements DynamicCam is still not hiding properly.\n\nThe opacity of the hidden UI is of course 0, so you cannot choose a different opacity nor can you keep any UI elements visible (except the FPS indicator).\n\nDuring combat we cannot change the hidden status of protected UI elements. Hence, such elements are always set to \"just faded out\" during combat. Notice that the opacity of the Minimap \"blips\" cannot be reduced. Thus, if you try to hide the Minimap, the \"blips\" are always visible during combat.\n\nWhen you check this box for the currently active situation, it will not be applied at once, because this would also hide this settings frame. You have to enter the situation for it to take effect, which is also possible with the situation \"Enable\" checkbox above.\n\nAlso notice that hiding the entire UI cancels Mailbox or NPC interactions. So do not use it for such situations!"
L["Keep FPS indicator"] = "Keep FPS indicator"
L["Do not fade out or hide the FPS indicator (the one you typically toggle with Ctrl + R)."] = "Do not fade out or hide the FPS indicator (the one you typically toggle with Ctrl + R)."
L["Fade Opacity"] = "Fade Opacity"
L["Fade the UI to this opacity when entering the situation."] = "Fade the UI to this opacity when entering the situation."
L["Excluded UI elements"] = "Excluded UI elements"
L["Keep Alerts"] = "Keep Alerts"
L["Still show alert popups from completed achievements, Covenant Renown, etc."] = "Still show alert popups from completed achievements, Covenant Renown, etc."
L["Keep Tooltip"] = "Keep Tooltip"
L["Still show the game tooltip, which appears when you hover your mouse cursor over UI or world elements."] = "Still show the game tooltip, which appears when you hover your mouse cursor over UI or world elements."
L["Keep Minimap"] = "Keep Minimap"
L["<keepMinimap_desc>"] = "Do not fade out the Minimap.\n\nNotice that we cannot reduce the opacity of the \"blips\" on the Minimap. These can only be hidden together with the whole Minimap, when the UI is faded to 0 opacity."
L["Keep Chat Box"] = "Keep Chat Box"
L["Do not fade out the chat box."] = "Do not fade out the chat box."
L["Keep Tracking Bar"] = "Keep Tracking Bar"
L["Do not fade out the tracking bar (XP, AP, reputation)."] = "Do not fade out the tracking bar (XP, AP, reputation)."
L["Keep Party/Raid"] = "Keep Party/Raid"
L["Do not fade out the Party/Raid frame."] = "Do not fade out the Party/Raid frame."
L["Keep Encounter Frame (Skyriding Vigor)"] = "Keep Encounter Frame (Skyriding Vigor)"
L["Do not fade out the Encounter Frame, which while skyriding is the Vigor display."] = "Do not fade out the Encounter Frame, which while skyriding is the Vigor display."
L["Keep additional frames"] = "Keep additional frames"
L["<keepCustomFrames_desc>"] = "The text box below allows you to define any frame you want to keep during NPC interaction.\n\nUse the console command /fstack to learn the names of frames.\n\nFor example, you may want to keep the buff icons next to the Minimap to be able to dismount during NPC interaction by clicking the appropriate icon."
L["Custom frames to keep"] = "Custom frames to keep"
L["Separated by commas."] = "Separated by commas."
L["Emergency Fade In"] = "Emergency Fade In"
L["Pressing Esc fades the UI back in."] = "Pressing Esc fades the UI back in."
L["<emergencyShow_desc>"] = [[Sometimes you need to show the UI even in situations where you normaly want it hidden. Older versions of DynamicCam established that the UI is shown whenever the Esc key is pressed. The downside of this is that the UI is also shown when the Esc key is used for other purposes like closing windows, cancelling spell casting etc. Unchecking the above checkbox disables this.

Notice however that you can lock yourself out of the UI this way! A better alternative to the Esc key are the following console commands, which show or hide the UI according to the current situation's "Fade Out UI" settings:

    /showUI
    /hideUI

For a convenient fade-in hotkey, put /showUI into a macro and assign a key to it in your "bindings-cache.wtf" file. E.g.:

    bind ALT+F11 MACRO Your Macro Name

If editing the "bindings-cache.wtf" file puts you off, you could use a keybind addon like "BindPad".

Using /showUI or /hideUI without any arguments takes the current situation's fade in or fade out time. But you can also provide a different transition time. E.g.:

    /showUI 0

to show the UI without any delay.]]
L["<hideUIHelp_desc>"] = "While setting up your desired UI fade effects, it can be annoying when this \"Interface\" settings frame fades out as well. If this box is checked, it will not be faded out.\n\nThis setting is global for all situations."
L["Do not fade out this \"Interface\" settings frame."] = "Do not fade out this \"Interface\" settings frame."
L["Situation Controls"] = "Situation Controls"
L["<situationControls_help>"] = "Here you control when a situation is active. Knowledge of the WoW UI API may be required. If you are happy with the stock situations of DynamicCam, just ignore this section. But if you want to create custom situations, you can check the stock situations here. You can also modify them, but beware: your changed settings will persist even if future versions of DynamicCam introduce important updates.\n\n"
L["Priority"] = "Priority"
L["The priority of this situation.\nMust be a number."] = "The priority of this situation.\nMust be a number."
L["Restore stock setting"] = "Restore stock setting"
L["Your \"Priority\" deviates from the stock setting for this situation (%s). Click here to restore it."] = "Your \"Priority\" deviates from the stock setting for this situation (%s). Click here to restore it."
L["<priority_desc>"] = "If the conditions of several different DynamicCam situations are fulfilled at the same time, the situation with the highest priority is entered. For example, whenever the condition of \"World Indoors\" is fulfilled, the condition of \"World\" is fulfilled as well. But as \"World Indoor\" has a higher priority than \"World\", it is prioritised. You can also see the priorities of all situations in the drop down menu above.\n\n"
L["Error message:"] = "Error message:"
L["Events"] = "Events"
L["Separated by commas."] = "Separated by commas."
L["Your \"Events\" deviate from the default for this situation. Click here to restore them."] = "Your \"Events\" deviate from the default for this situation. Click here to restore them."
L["<events_desc>"] = [[Here you define all the in-game events upon which DynamicCam should check the condition of this situation, to enter or exit it if applicable.

You can learn about in-game events using WoW's Event Log.
To open it, type this into the console:

  /eventtrace

A list of all possible events can also be found here:
https://warcraft.wiki.gg/wiki/Events

]]
L["Initialisation"] = "Initialisation"
L["Initialisation Script"] = "Initialisation Script"
L["Lua code using the WoW UI API."] = "Lua code using the WoW UI API."
L["Your \"Initialisation Script\" deviates from the stock setting for this situation. Click here to restore it."] = "Your \"Initialisation Script\" deviates from the stock setting for this situation. Click here to restore it."
L["<initialisation_desc>"] = [[The initialisation script of a situation is run once when DynamicCam is loaded (and also when the situation is modified). You would typically put stuff into it which you want to reuse in any of the other scripts (condition, on-enter, on-exit). This can make these other scripts a bit shorter.

For example, the initialisation script of the "Hearth/Teleport" situation defines the table "this.spells", which includes the spell IDs of teleport spells. The condition script can then simply access "this.spells" every time it is executed.

Like in this example, you can share any data object between the scripts of a situation by putting it into the "this" table.

]]
L["Condition"] = "Condition"
L["Condition Script"] = "Condition Script"
L["Lua code using the WoW UI API.\nShould return \"true\" if and only if the situation should be active."] = "Lua code using the WoW UI API.\nShould return \"true\" if and only if the situation should be active."
L["Your \"Condition Script\" deviates from the stock setting for this situation. Click here to restore it."] = "Your \"Condition Script\" deviates from the stock setting for this situation. Click here to restore it."
L["<condition_desc>"] = [[The condition script of a situation is run every time an in-game event of this situation is triggered. The script should return "true" if and only if this situation should be active.

For example, the condition script of the "City" situation uses the WoW API function "IsResting()" to check if you are currently in a resting zone:

  return IsResting()

Likewise, the condition script of the "City - Indoors" situation also uses the WoW API function "IsIndoors()" to also check if you are indoors:

  return IsResting() and IsIndoors()

A list of WoW API functions can be found here:
https://warcraft.wiki.gg/wiki/World_of_Warcraft_API

]]
L["Entering"] = "Entering"
L["On-Enter Script"] = "On-Enter Script"
L["Your \"On-Enter Script\" deviates from the stock setting for this situation. Click here to restore it."] = "Your \"On-Enter Script\" deviates from the stock setting for this situation. Click here to restore it."
L["<executeOnEnter_desc>"] = [[The on-enter script of a situation is run every time the situation is entered.

So far, the only example for this is the "Hearth/Teleport" situation in which we use the WoW API function "UnitCastingInfo()" to determine the cast duration of the current spell. We then assign this to the variables "this.transitionTime" and "this.rotationTime", such that a zoom or rotation (see "Situation Actions") can take exactly as long as the spell cast. (Not all teleport spells have the same cast times.)

]]
L["Exiting"] = "Exiting"
L["On-Exit Script"] = "On-Exit Script"
L["Your \"On-Exit Script\" deviates from the stock setting for this situation. Click here to restore it."] = "Your \"On-Exit Script\" deviates from the stock setting for this situation. Click here to restore it."
L["Exit Delay"] = "Exit Delay"
L["Wait for this many seconds before exiting this situation."] = "Wait for this many seconds before exiting this situation."
L["Your \"Exit Delay\" deviates from the stock setting for this situation. Click here to restore it."] = "Your \"Exit Delay\" deviates from the stock setting for this situation. Click here to restore it."
L["<executeOnExit_desc>"] = [[The on-exit script of a situation is run every time the situation is exited. So far, no situation is using this.

The delay determines how many seconds to wait before exiting the situation. So far, the only example for this is the "Fishing" situation, where the delay gives you time to re-cast your fishing rod without exiting the situation.

]]
L["Export"] = "Export"
L["Coming soon(TM)."] = "Coming soon(TM)."
L["Import"] = "Import"
L["<welcomeMessage>"] = [[We're glad that you're here and we hope that you have fun with the addon.

DynamicCam (DC) was started in May 2016 by mpstark when the WoW devs at Blizzard introduced the experimental ActionCam features into the game. The main purpose of DC has been to provide a user interface for the ActionCam settings. Within the game, the ActionCam is still designated as "experimental" and there has been no sign from Blizzard to develop it further. There are some shortcomings, but we should be thankful that ActionCam was left in the game for enthusiast like us to use. :-) DC does not just allow you to change the ActionCam settings but to have different settings for different game situations. Not related to ActionCam, DC also provides features regarding camera zoom and UI fade-out.

The work of mpstark on DC continued until August 2018. While most features worked well for a substantial user base, mpstark had always considered DC to be in beta state and due to his waning investment in WoW he ended up not resuming his work. At that time, Ludius had already begun making adjustments to DC for himself, which was noticed by Weston (aka dernPerkins) who in early 2020 managed to get in touch with mpstark leading to Ludius taking over the development. The first non-beta version 1.0 was released in May 2020 including Ludius's adjustments up to that point. Afterwards, Ludius began to work on an overhaul of DC resulting in version 2.0 being released in Autum 2022.

When mpstark started DC, his focus was on making most customisations in-game instead of having to change the source code. This made it easier to experiment particularly with the different game situations. From version 2.0 on, these advanced settings have been moved to a special section called "Situation Controls". Most users will probably never need it, but for "power users" it is still available. A hazard of making changes there is that saved user settings always override DC's stock settings, even if new versions of DC bring updated stock settings. Hence, a warning is displayed at the top of this page whenever you have stock situations with modified "Situation Controls".

If you think one of DC's stock situations should be changed, you can always create a copy of it with your changes. Feel free to export this new situation and post it on DC's curseforge page. We may then add it as a new stock situtation of its own. You are also welcome to export and post your entire DC profile, as we are always looking for new profile presets which allow newcomers an easier entry to DC. If you find a problem or want to make a suggestion, just leave a note in the curseforge comments or even better use the Issues on GitHub. If you'd like to contribute, also feel free to open a pull request there.

Here are some handy slash commands:

    `/dynamiccam` or `/dc` opens this menu.
    `/zoominfo` or `/zi` prints out the current zoom level.

    `/zoom #1 #2` zooms to zoom level #1 in #2 seconds.
    `/yaw #1 #2` yaws the camera by #1 degrees in #2 seconds (negative #1 to yaw right).
    `/pitch #1 #2` pitches the camera by #1 degrees (negative #1 to pitch up).


]]
L["About"] = "About"
L["The following game situations have \"Situation Controls\" deviating from DynamicCam's stock settings.\n\n"] = "The following game situations have \"Situation Controls\" deviating from DynamicCam's stock settings.\n\n"
L["<situationControlsWarning>"] = "\nIf you are doing this on purpose, it is fine. Just be aware that any updates to these settings by the DynamicCam developers will always be overridden by your modified (possibly outdated) version. You can check the \"Situation Controls\" tab of each situation for details. If you are not aware of any \"Situation Controls\" modifications from your side and simply want to restore the stock control settings for *all* situations, hit this button:"
L["Restore all stock Situation Controls"] = "Restore all stock Situation Controls"
L["Hello and welcome to DynamicCam!"] = "Hello and welcome to DynamicCam!"
L["Profiles"] = "Profiles"
L["Manage Profiles"] = "Manage Profiles"
L["<manageProfilesWarning>"] = "Like many addons, DynamicCam uses the \"AceDB-3.0\" library to manage profiles. What you have to understand is that there is nothing like \"Save Profile\" here. You can only create new profiles and you can copy settings from another profile into the currently active one. Whatever change you make for the currently active profile is immediately saved! There is nothing like \"cancel\" or \"discard changes\". The \"Reset Profile\" button only resets to the global default profile.\n\nSo if you like your DynamicCam settings, you should create another profile into which you copy these settings as a backup. When you don't use this backup profile as your active profile, you can experiment with the settings and return to your original profile at any time by selecting your backup profile in the \"Copy from\" box.\n\nIf you want to switch profiles via macro, you can use the following:\n/run DynamicCam.db:SetProfile(\"Profile name here\")\n\n"
L["Profile presets"] = "Profile presets"
L["Import / Export"] = "Import / Export"
L["DynamicCam"] = "DynamicCam"
L["Disabled"] = "Disabled"
L["Your DynamicCam addon lets you adjust horizontal and vertical mouse look speed individually! Just go to the \"Mouse Look\" settings of DynamicCam to make the adjustments there."] = "Your DynamicCam addon lets you adjust horizontal and vertical mouse look speed individually! Just go to the \"Mouse Look\" settings of DynamicCam to make the adjustments there."
L["Attention"] = "Attention"
L["The \"%s\" setting is disabled by DynamicCam, while you are using the horizontal camera over shoulder offset."] = "The \"%s\" setting is disabled by DynamicCam, while you are using the horizontal camera over shoulder offset."
L["While you are using horizontal camera offset, DynamicCam prevents CameraKeepCharacterCentered!"] = "While you are using horizontal camera offset, DynamicCam prevents CameraKeepCharacterCentered!"
L["While you are using horizontal camera offset, DynamicCam prevents CameraReduceUnexpectedMovement!"] = "While you are using horizontal camera offset, DynamicCam prevents CameraReduceUnexpectedMovement!"
L["While you are using vertical camera pitch, DynamicCam prevents CameraKeepCharacterCentered!"] = "While you are using vertical camera pitch, DynamicCam prevents CameraKeepCharacterCentered!"
L["cameraView=%s prevented by DynamicCam!"] = "cameraView=%s prevented by DynamicCam!"

-- MouseZoom
L["Current\nZoom\nValue"] = "Current\nZoom\nValue"
L["Reactive\nZoom\nTarget"] = "Reactive\nZoom\nTarget"

-- Core
L["Enter name for custom situation:"] = "Enter name for custom situation:"
L["Create"] = "Create"
L["Cancel"] = "Cancel"

-- DefaultSettings
L["City"] = "City"
L["City (Indoors)"] = "City (Indoors)"
L["World"] = "World"
L["World (Indoors)"] = "World (Indoors)"
L["World (Combat)"] = "World (Combat)"
L["Dungeon/Scenario"] = "Dungeon/Scenario"
L["Dungeon/Scenario (Outdoors)"] = "Dungeon/Scenario (Outdoors)"
L["Dungeon/Scenario (Combat, Boss)"] = "Dungeon/Scenario (Combat, Boss)"
L["Dungeon/Scenario (Combat, Trash)"] = "Dungeon/Scenario (Combat, Trash)"
L["Raid"] = "Raid"
L["Raid (Outdoors)"] = "Raid (Outdoors)"
L["Raid (Combat, Boss)"] = "Raid (Combat, Boss)"
L["Raid (Combat, Trash)"] = "Raid (Combat, Trash)"
L["Arena"] = "Arena"
L["Arena (Combat)"] = "Arena (Combat)"
L["Battleground"] = "Battleground"
L["Battleground (Combat)"] = "Battleground (Combat)"
L["Mounted (any)"] = "Mounted (any)"
L["Mounted (only flying-mount)"] = "Mounted (only flying-mount)"
L["Mounted (only flying-mount + airborne)"] = "Mounted (only flying-mount + airborne)"
L["Mounted (only flying-mount + airborne + Skyriding)"] = "Mounted (only flying-mount + airborne + Skyriding)"
L["Mounted (only flying-mount + Skyriding)"] = "Mounted (only flying-mount + Skyriding)"
L["Mounted (only airborne)"] = "Mounted (only airborne)"
L["Mounted (only airborne + Skyriding)"] = "Mounted (only airborne + Skyriding)"
L["Mounted (only Skyriding)"] = "Mounted (only Skyriding)"
L["Druid Travel Form"] = "Druid Travel Form"
L["Dracthyr Soar"] = "Dracthyr Soar"
L["Skyriding Race"] = "Skyriding Race"
L["Taxi"] = "Taxi"
L["Vehicle"] = "Vehicle"
L["Hearth/Teleport"] = "Hearth/Teleport"
L["Annoying Spells"] = "Annoying Spells"
L["NPC Interaction"] = "NPC Interaction"
L["Mailbox"] = "Mailbox"
L["Fishing"] = "Fishing"
L["Gathering"] = "Gathering"
L["AFK"] = "AFK"
L["Pet Battle"] = "Pet Battle"
L["Professions Frame Open"] = "Professions Frame Open"
