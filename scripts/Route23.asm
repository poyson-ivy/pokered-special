Route23_Script:
	call Route23SetVictoryRoadBoulders
	call EnableAutoTextBoxDrawing
	ld hl, Route23_ScriptPointers
	ld a, [wRoute23CurScript]
	jp CallFunctionInTable

Route23SetVictoryRoadBoulders:
	ld hl, wCurrentMapScriptFlags
	bit BIT_CUR_MAP_LOADED_2, [hl]
	res BIT_CUR_MAP_LOADED_2, [hl]
	ret z
	ResetEvents EVENT_VICTORY_ROAD_2_BOULDER_ON_SWITCH1, EVENT_VICTORY_ROAD_2_BOULDER_ON_SWITCH2
	ResetEvents EVENT_VICTORY_ROAD_3_BOULDER_ON_SWITCH1, EVENT_VICTORY_ROAD_3_BOULDER_ON_SWITCH2
	ld a, TOGGLE_VICTORY_ROAD_3F_BOULDER
	ld [wToggleableObjectIndex], a
	predef ShowObject
	ld a, TOGGLE_VICTORY_ROAD_2F_BOULDER
	ld [wToggleableObjectIndex], a
	predef_jump HideObject

Route23_ScriptPointers:
	def_script_pointers
	dw_const Route23DefaultScript,        SCRIPT_ROUTE23_DEFAULT
	dw_const Route23PlayerMovingScript,   SCRIPT_ROUTE23_PLAYER_MOVING
	dw_const Route23ResetToDefaultScript, SCRIPT_ROUTE23_RESET_TO_DEFAULT

Route23DefaultScript:
	ld a, [wYCoord]
	cp 35 ; Only check for the EarthBadge guard's Y-coordinate
	ret nz
	ld a, [wXCoord]
	cp 14
	ret nc
	
	ld a, 1 ; Assuming the Earthbadge guard is sprite index 1
	ldh [hSpriteIndex], a
	ld a, 6 ; EarthBadge is badge index 6 relative to Cascade (0)
	ld [wWhichBadge], a
	ld b, FLAG_TEST
	ld c, EVENT_PASSED_EARTHBADGE_CHECK
	ld hl, wEventFlags
	predef FlagActionPredef
	ld a, c
	and a
	ret nz
	call Route23CopyBadgeTextScript
	call DisplayTextID
	xor a
	ldh [hJoyHeld], a
	ret

Route23CopyBadgeTextScript:
	ld hl, EarthBadgeText
	ld de, wNameBuffer
.copyTextLoop
	ld a, [hli]
	ld [de], a
	inc de
	cp '@'
	jr nz, .copyTextLoop
	ret

EarthBadgeText:
	db "EARTHBADGE@"

Route23MovePlayerDownScript:
	ld a, $1
	ld [wSimulatedJoypadStatesIndex], a
	ld a, PAD_DOWN
	ld [wSimulatedJoypadStatesEnd], a
	xor a
	ld [wSpritePlayerStateData1FacingDirection], a
	ld [wJoyIgnore], a
	jp StartSimulatingJoypadStates

Route23PlayerMovingScript:
	ld a, [wSimulatedJoypadStatesIndex]
	and a
	ret nz
Route23ResetToDefaultScript:
	ld a, SCRIPT_ROUTE23_DEFAULT
	ld [wRoute23CurScript], a
	ret

Route23_TextPointers:
	def_text_pointers
	dw_const Route23Guard1Text,              TEXT_ROUTE23_GUARD1
	dw_const Route23VictoryRoadGateSignText, TEXT_ROUTE23_VICTORY_ROAD_GATE_SIGN

Route23Guard1Text:
	text_asm
	ld a, 6 ; EarthBadge index
	call Route23CheckForBadgeScript
	jp TextScriptEnd

Route23CheckForBadgeScript:
	ld [wWhichBadge], a
	call Route23CopyBadgeTextScript
	ld a, [wWhichBadge]
	inc a
	ld c, a
	ld b, FLAG_TEST
	ld hl, wObtainedBadges
	predef FlagActionPredef
	ld a, c
	and a
	jr nz, .have_badge
	ld hl, Route23YouDontHaveTheBadgeYetText
	call PrintText
	call Route23MovePlayerDownScript
	ld a, SCRIPT_ROUTE23_PLAYER_MOVING
	ld [wRoute23CurScript], a
	ret
.have_badge
	ld hl, Route23OhThatIsTheBadgeText
	call PrintText
	ld b, FLAG_SET
	ld c, EVENT_PASSED_EARTHBADGE_CHECK
	ld hl, wEventFlags
	predef FlagActionPredef
	ld a, SCRIPT_ROUTE23_RESET_TO_DEFAULT
	ld [wRoute23CurScript], a
	ret

Route23YouDontHaveTheBadgeYetText:
	text_far _Route23YouDontHaveTheBadgeYetText
	text_asm
	ld a, SFX_DENIED
	call PlaySoundWaitForCurrent
	call WaitForSoundToFinish
	jp TextScriptEnd

Route23OhThatIsTheBadgeText:
	text_far _Route23OhThatIsTheBadgeText
	sound_get_item_1
	text_far _Route23GoRightAheadText
	text_end

Route23VictoryRoadGateSignText:
	text_far _Route23VictoryRoadGateSignText
	text_end