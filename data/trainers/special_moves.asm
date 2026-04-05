; unique moves for gym leaders
; this is not automatic! you have to write the index you want to [wLoneAttackNo]
; first. e.g., erika's script writes 4 to [wLoneAttackNo] to get mega drain,
; the fourth entry in the list.
LoneMoves:
	; pokemon index, move to give nth pokemon
	db 1, ROCK_THROW
	db 1, BUBBLEBEAM
	db 2, THUNDERBOLT
	db 2, MEGA_DRAIN
	db 3, SLUDGE
	db 3, PSYBEAM
	db 3, FLAMETHROWER
	db 4, EARTHQUAKE

; unique moves for elite 4
; all trainers in this class are given this move automatically
; (unrelated to LoneMoves)
TeamMoves:
	; trainer, move
	db LORELEI, ICE_BEAM
	db BRUNO,   EARTHQUAKE
	db AGATHA,  SHADOW_BALL
	db LANCE,   DRAGON_PULSE
	db -1 ; end
