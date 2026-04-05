LancesRoom_Script:
	call LanceShowOrHideEntranceBlocks
	call EnableAutoTextBoxDrawing
	ld hl, LancesRoomTrainerHeaders
	ld de, LancesRoom_ScriptPointers
	ld a, [wLancesRoomCurScript]
	call ExecuteCurMapScriptInTable
	ld [wLancesRoomCurScript], a
	ret

LanceShowOrHideEntranceBlocks:
	ld hl, wCurrentMapScriptFlags
	bit BIT_CUR_MAP_LOADED_1, [hl]
	res BIT_CUR_MAP_LOADED_1, [hl]
	ret z
	CheckEvent EVENT_LANCES_ROOM_LOCK_DOOR
	jr nz, .closeEntrance
	; open entrance
	ld a, $31
	ld b, $32
	jp .setEntranceBlocks
.closeEntrance
	ld a, $72
	ld b, $73
.setEntranceBlocks
; Replaces the tile blocks so the player can't leave.
	push bc
	ld [wNewTileBlockID], a
	lb bc, 6, 2
	call .SetEntranceBlock
	pop bc
	ld a, b
	ld [wNewTileBlockID], a
	lb bc, 6, 3
.SetEntranceBlock:
	predef_jump ReplaceTileBlock

ResetLanceScript:
	xor a ; SCRIPT_LANCESROOM_DEFAULT
	ld [wLancesRoomCurScript], a
	ret

LancesRoom_ScriptPointers:
	def_script_pointers
	dw_const LancesRoomDefaultScript,               SCRIPT_LANCESROOM_DEFAULT
	dw_const DisplayEnemyTrainerTextAndStartBattle, SCRIPT_LANCESROOM_LANCE_START_BATTLE
	dw_const LancesRoomLanceEndBattleScript,        SCRIPT_LANCESROOM_LANCE_END_BATTLE
	dw_const LancesRoomPlayerIsMovingScript,        SCRIPT_LANCESROOM_PLAYER_IS_MOVING
	dw_const LancesRoomNoopScript,                  SCRIPT_LANCESROOM_NOOP

LancesRoomNoopScript:
	ret

LancesRoomDefaultScript:
	CheckEvent EVENT_BEAT_LANCE
	ret nz
	ld hl, LanceTriggerMovementCoords
	call ArePlayerCoordsInArray
	jp nc, CheckFightingMapTrainers
	xor a
	ldh [hJoyHeld], a
	ld a, [wCoordIndex]
	cp $3  ; Is player standing next to Lance's sprite?
	jr nc, .notStandingNextToLance
	ld a, TEXT_LANCESROOM_LANCE
	ldh [hTextID], a
	jp DisplayTextID
.notStandingNextToLance
	cp $5  ; Is player standing on the entrance staircase?
	jr z, WalkToLance
	CheckAndSetEvent EVENT_LANCES_ROOM_LOCK_DOOR
	ret nz
	ld hl, wCurrentMapScriptFlags
	set BIT_CUR_MAP_LOADED_1, [hl]
	ld a, SFX_GO_INSIDE
	call PlaySound
	jp LanceShowOrHideEntranceBlocks

LanceTriggerMovementCoords:
	dbmapcoord  5,  1
	dbmapcoord  6,  2
	dbmapcoord  5, 11
	dbmapcoord  6, 11
	dbmapcoord 24, 16
	db -1 ; end

LancesRoomLanceEndBattleScript:
	call EndTrainerBattle
	ld a, [wIsInBattle]
	cp $ff
	jp z, ResetLanceScript
	ld a, TEXT_LANCESROOM_LANCE
	ldh [hTextID], a
	call DisplayTextID
	; MUST advance to NOOP here to prevent the infinite text/battle loop!
	ld a, SCRIPT_LANCESROOM_NOOP
	ld [wLancesRoomCurScript], a
	ret

WalkToLance:
; Moves the player down the hallway to Lance's room.
	ld a, PAD_BUTTONS | PAD_CTRL_PAD
	ld [wJoyIgnore], a
	ld hl, wSimulatedJoypadStatesEnd
	ld de, WalkToLance_RLEList
	call DecodeRLEList
	dec a
	ld [wSimulatedJoypadStatesIndex], a
	call StartSimulatingJoypadStates
	ld a, SCRIPT_LANCESROOM_PLAYER_IS_MOVING
	ld [wLancesRoomCurScript], a
	ld [wCurMapScript], a
	ret

WalkToLance_RLEList:
	db PAD_UP, 12
	db PAD_LEFT, 12
	db PAD_DOWN, 7
	db PAD_LEFT, 6
	db -1 ; end

LancesRoomPlayerIsMovingScript:
	ld a, [wSimulatedJoypadStatesIndex]
	and a
	ret nz
	call Delay3
	xor a ; SCRIPT_LANCESROOM_DEFAULT
	ld [wJoyIgnore], a
	ld [wLancesRoomCurScript], a
	ld [wCurMapScript], a
	ret

LancesRoom_TextPointers:
	def_text_pointers
	dw_const LancesRoomLanceText, TEXT_LANCESROOM_LANCE

LancesRoomTrainerHeaders:
	def_trainers
LancesRoomTrainerHeader0:
	trainer EVENT_BEAT_LANCES_ROOM_TRAINER_0,       0, LancesRoomLanceBeforeBattleText, LancesRoomLanceEndBattleText, LancesRoomLanceAfterBattleText
LancesRoomTrainerHeader1:
	; Using the + 1 math satisfies the trainer macro's sequential bit assertion 
	; and automatically assigns Team 2 because it's the second header!
	trainer (EVENT_BEAT_LANCES_ROOM_TRAINER_0 + 1), 0, LancesRoomLanceRematchBeforeBattleText, LancesRoomLanceRematchEndBattleText, LancesRoomLanceRematchAfterBattleText
	db -1 ; end

LancesRoomLanceText:
	text_asm
	CheckEvent EVENT_PLAYER_IS_CHAMPION
	jr nz, .rematch
	; Normal encounter
	ld hl, LancesRoomTrainerHeader0
	call TalkToTrainer
	jp TextScriptEnd
.rematch
	; TalkToTrainer automatically handles roster queues, text states, and loop prevention
	ld hl, LancesRoomTrainerHeader1
	call TalkToTrainer
	
	; Force the battle engine to use the rematch roster
	; (TalkToTrainer pulls the default roster from map objects)
	CheckEvent EVENT_BEAT_LANCE
	jr nz, .skipRosterOverride
	ld a, 2 ; Roster 2
	ld [wTrainerNo], a
.skipRosterOverride

	jp TextScriptEnd

LancesRoomLanceBeforeBattleText:
	text_far _LancesRoomLanceBeforeBattleText
	text_end

LancesRoomLanceEndBattleText:
	text_far _LancesRoomLanceEndBattleText
	text_end

LancesRoomLanceAfterBattleText:
	text_far _LancesRoomLanceAfterBattleText
	text_asm
	SetEvent EVENT_BEAT_LANCE
	jp TextScriptEnd

LancesRoomLanceRematchBeforeBattleText:
	text_far _LancesRoomLanceRematchBeforeBattleText
	text_end

LancesRoomLanceRematchEndBattleText:
	text_far _LancesRoomLanceRematchEndBattleText
	text_end

LancesRoomLanceRematchAfterBattleText:
	text_far _LancesRoomLanceRematchAfterBattleText
	text_asm
	SetEvent EVENT_BEAT_LANCE
	jp TextScriptEnd