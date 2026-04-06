PlayBattleMusic::
	xor a
	ld [wMusicFade], a
	ld [wLowHealthAlarm], a
	dec a ; SFX_STOP_ALL_MUSIC
;	ld [wNewSoundID], a
	call PlaySound
	call DelayFrame
	ld c, 0 ; BANK(Music_GymLeaderBattle)

	ld a, [wGymLeaderNo]
	and a
	jr nz, .gymLeader

	ld a, [wCurOpponent]
	cp OPP_ID_OFFSET
	jr c, .wildBattle

	cp OPP_LORELEI
	jr z, .gymLeader
	cp OPP_BRUNO
	jr z, .gymLeader
	cp OPP_AGATHA
	jr z, .gymLeader
	cp OPP_LANCE
	jr z, .gymLeader

	cp OPP_RIVAL3
	jr z, .finalBattle
	cp OPP_LILY
	ld a, MUSIC_TRAINER_BATTLE
	jr nz, .playSong

.finalBattle
	ld a, MUSIC_FINAL_BATTLE
	jr .playSong

.gymLeader
	ld a, MUSIC_GYM_LEADER_BATTLE
	jr .playSong

.wildBattle
	ld a, MUSIC_WILD_BATTLE

.playSong
	jp PlayMusic