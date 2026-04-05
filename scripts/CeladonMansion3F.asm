CeladonMansion3F_Script:
	call EnableAutoTextBoxDrawing
	ld hl, CeladonMansion3TrainerHeaders
	ld de, CeladonMansion3F_ScriptPointers
	ld a, [wCeladonMansion3FCurScript]
	call ExecuteCurMapScriptInTable
	ld [wCeladonMansion3FCurScript], a
	ret

CeladonMansion3FResetScripts:
	xor a
	ld [wJoyIgnore], a
	ld [wCeladonMansion3FCurScript], a
	ret

CeladonMansion3F_ScriptPointers:
	def_script_pointers
	dw_const CeladonMansion3FDefaultScript,  SCRIPT_CELADONMANSION3F_DEFAULT
	dw_const CeladonMansion3FLilyPostBattle, SCRIPT_CELADONMANSION3F_LILY_POST_BATTLE

CeladonMansion3FDefaultScript:
	ret

CeladonMansion3FLilyPostBattle:
	ld a, [wIsInBattle]
	cp $ff
	jp z, CeladonMansion3FResetScripts
	
	; Set victory flag and reset script state FIRST to prevent loops
	SetEvent EVENT_BEAT_LILY
	xor a
	ld [wCeladonMansion3FCurScript], a
	ld [wCurMapScript], a
	
	ld a, PAD_CTRL_PAD
	ld [wJoyIgnore], a
	ld a, TEXT_CELADONMANSION3F_LILY_POST_BATTLE
	ldh [hTextID], a
	call DisplayTextID
	
	xor a
	ld [wJoyIgnore], a
	ret

CeladonMansion3F_TextPointers:
	def_text_pointers
	dw_const CeladonMansion3FProgrammerText,     TEXT_CELADONMANSION3F_PROGRAMMER
	dw_const CeladonMansion3FGraphicArtistText,  TEXT_CELADONMANSION3F_GRAPHIC_ARTIST
	dw_const CeladonMansion3FWriterText,         TEXT_CELADONMANSION3F_WRITER
	dw_const CeladonMansion3FGameDesignerText,   TEXT_CELADONMANSION3F_GAME_DESIGNER
	dw_const CeladonMansion3FLilyText,           TEXT_CELADONMANSION3F_LILY
	dw_const CeladonMansion3FLilyPostBattleText, TEXT_CELADONMANSION3F_LILY_POST_BATTLE
	dw_const CeladonMansion3FGameProgramPCText,  TEXT_CELADONMANSION3F_GAME_PROGRAM_PC
	dw_const CeladonMansion3FPlayingGamePCText,  TEXT_CELADONMANSION3F_PLAYING_GAME_PC
	dw_const CeladonMansion3FGameScriptPCText,   TEXT_CELADONMANSION3F_GAME_SCRIPT_PC
	dw_const CeladonMansion3FDevRoomSignText,    TEXT_CELADONMANSION3F_DEV_ROOM_SIGN

CeladonMansion3TrainerHeaders:
	def_trainers
CeladonMansion3TrainerHeader0:
	trainer EVENT_BEAT_LILY, 0, LilyChallengeBattleText, LilyDefeatedText, LilyPostBattleText
	db -1 ; end

CeladonMansion3FProgrammerText:
	text_far _CeladonMansion3FProgrammerText
	text_end

CeladonMansion3FGraphicArtistText:
	text_far _CeladonMansion3FGraphicArtistText
	text_end

CeladonMansion3FWriterText:
	text_far _CeladonMansion3FWriterText
	text_end

CeladonMansion3FGameDesignerText:
	text_asm
	ld hl, wPokedexOwned
	ld b, wPokedexOwnedEnd - wPokedexOwned
	call CountSetBits
	ld a, [wNumSetBits]
	jr nc, .completed_dex
	ld hl, .Text
	jr .done
.completed_dex
	ld hl, .CompletedDexText
.done
	call PrintText
	jp TextScriptEnd

.Text:
	text_far _CeladonMansion3FGameDesignerText
	text_end

.CompletedDexText:
	text_far _CeladonMansion3FGameDesignerCompletedDexText
	text_promptbutton
	text_asm
	callfar DisplayDiploma
	ld a, TRUE
	ld [wDoNotWaitForButtonPressAfterDisplayingText], a
	jp TextScriptEnd

CeladonMansion3FLilyText:
	text_asm
	CheckEvent EVENT_BEAT_LILY
	jr nz, .alreadyBeat
	ld hl, .AskBattleText
	call PrintText
	call YesNoChoice
	ld a, [wCurrentMenuItem]
	and a
	jr nz, .declined

	ld hl, LilyChallengeBattleText
	call PrintText
	ld hl, wStatusFlags3
	set BIT_TALKED_TO_TRAINER, [hl]
	set BIT_PRINT_END_BATTLE_TEXT, [hl]
	ld hl, LilyDefeatedText
	ld de, LilyDefeatedText
	call SaveEndBattleTextPointers
	ld a, OPP_LILY
	ld [wEngagedTrainerClass], a
	ld a, 1
	ld [wEngagedTrainerSet], a
	ldh a, [hSpriteIndex]
	ld [wSpriteIndex], a
	call InitBattleEnemyParameters
	ld a, SCRIPT_CELADONMANSION3F_LILY_POST_BATTLE
	ld [wCeladonMansion3FCurScript], a
	jp .text_script_end

.declined
	ld hl, .DeclinedText
	call PrintText
	jr .text_script_end

.alreadyBeat
	ld hl, LilyPostBattleText
	call PrintText
.text_script_end
	jp TextScriptEnd

.AskBattleText:
	text_far _LilyBeforeBattleText
	text_end

.DeclinedText:
	text_far _LilyRefusedBattleText
	text_end

CeladonMansion3FLilyPostBattleText:
	text_asm
	ld hl, LilyPostBattleText
	call PrintText
	call GBFadeOutToBlack
	ld a, TOGGLE_CELADON_MANSION_3F_LILY
	ld [wToggleableObjectIndex], a
	predef HideObject
	call UpdateSprites
	call Delay3
	call GBFadeInFromBlack
	jp TextScriptEnd

LilyPostBattleText:
	text_far _LilyPostBattleText
	text_end

LilyChallengeBattleText:
	text_far _LilyChallengeBattleText
	text_end

LilyDefeatedText:
	text_far _LilyDefeatedText
	text_end

CeladonMansion3FGameProgramPCText:
	text_far _CeladonMansion3FGameProgramPCText
	text_end

CeladonMansion3FPlayingGamePCText:
	text_far _CeladonMansion3FPlayingGamePCText
	text_end

CeladonMansion3FGameScriptPCText:
	text_far _CeladonMansion3FGameScriptPCText
	text_end

CeladonMansion3FDevRoomSignText:
	text_far _CeladonMansion3FDevRoomSignText
	text_end