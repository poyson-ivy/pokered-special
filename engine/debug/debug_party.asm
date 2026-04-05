SetDebugNewGameParty: ; unreferenced except in _DEBUG
	ld de, DebugNewGameParty
.loop
	ld a, [de]
	cp -1
	ret z
	ld [wCurPartySpecies], a
	inc de
	ld a, [de]
	ld [wCurEnemyLevel], a
	inc de
	call AddPartyMon
	jr .loop

DebugNewGameParty: ; unreferenced except in _DEBUG
	; Exeggutor is the only debug party member shared with Red, Green, and Japanese Blue.
	; "Tsunekazu Ishihara: Exeggutor is my favorite. That's because I was
	; always using this character while I was debugging the program."
	; From https://web.archive.org/web/20000607152840/http://pocket.ign.com/news/14973.html
	db ZAPDOS, 100
	db SCIZOR, 100
	db MEWTWO, 100
	db DRAGONITE, 100
	db GYARADOS, 100
	db VENUSAUR, 100
	db -1 ; end

PrepareNewGameDebug: ; dummy except in _DEBUG
IF DEF(_DEBUG)
	xor a ; PLAYER_PARTY_DATA
	ld [wMonDataLocation], a

	; Fly anywhere.
	dec a ; $ff (all bits)
	ld [wTownVisitedFlag], a
	ld [wTownVisitedFlag + 1], a

	; Get all badges except Earth Badge.
	ld a, ~(1 << BIT_EARTHBADGE)
	ld [wObtainedBadges], a

	call SetDebugNewGameParty

	ld hl, wPartyMon1Moves
	ld a, THUNDERSHOCK
	ld [hli], a
	ld a, THUNDERBOLT
	ld [hli], a
	ld a, THUNDER
	ld [hli], a
	ld a, FLY
	ld [hl], a

	ld hl, wPartyMon2Moves
	ld a, XSCISSOR
	ld [hli], a
	ld a, SLASH
	ld [hli], a
	ld a, WING_ATTACK
	ld [hli], a
	ld a, SWORDS_DANCE
	ld [hl], a

	ld hl, wPartyMon3Moves
	ld a, PSYBEAM
	ld [hli], a
	ld a, PSYCHIC_M
	ld [hli], a
	ld a, SHADOW_BALL
	ld [hli], a
	ld a, BODY_SLAM
	ld [hl], a

	ld hl, wPartyMon4Moves
	ld a, DRAGON_PULSE
	ld [hli], a
	ld a, THUNDERBOLT
	ld [hli], a
	ld a, ICE_BEAM
	ld [hli], a
	ld a, STRENGTH
	ld [hl], a

	ld hl, wPartyMon5Moves
	ld a, SURF
	ld [hli], a
	ld a, DRAGON_PULSE
	ld [hli], a
	ld a, BITE
	ld [hli], a
	ld a, ICE_BEAM
	ld [hl], a

	ld hl, wPartyMon6Moves
	ld a, RAZOR_LEAF
	ld [hli], a
	ld a, MEGA_DRAIN
	ld [hli], a
	ld a, CUT
	ld [hli], a
	ld a, SLEEP_POWDER
	ld [hl], a

	; Get some debug items.
	ld hl, wNumBagItems
	ld de, DebugNewGameItemsList
.items_loop
	ld a, [de]
	cp -1
	jr z, .items_end
	ld [wCurItem], a
	inc de
	ld a, [de]
	inc de
	ld [wItemQuantity], a
	call AddItemToInventory
	jr .items_loop
.items_end

	; Complete the Pokédex.
	ld hl, wPokedexOwned
	call DebugSetPokedexEntries
	ld hl, wPokedexSeen
	call DebugSetPokedexEntries
	SetEvent EVENT_GOT_POKEDEX

	; Rival chose Squirtle,
	; Player chose Charmander.
	ld hl, wRivalStarter
	ASSERT wRivalStarter + 2 == wPlayerStarter
	ld a, STARTER2
	ld [hli], a
	inc hl
	ld a, STARTER1
	ld [hl], a

	ret

DebugSetPokedexEntries:
	ld b, wPokedexOwnedEnd - wPokedexOwned - 1
	ld a, %11111111
.loop
	ld [hli], a
	dec b
	jr nz, .loop
	ld [hl], %01111111
	ret

DebugNewGameItemsList:
	db BICYCLE, 1
	db FULL_RESTORE, 99
	db MAX_REVIVE, 99
	db MAX_ELIXER, 99
	db FULL_HEAL, 99
	db ESCAPE_ROPE, 99
	db RARE_CANDY, 99
	db MASTER_BALL, 99
	db TOWN_MAP, 1
	db SECRET_KEY, 1
	db CARD_KEY, 1
	db S_S_TICKET, 1
	db LIFT_KEY, 1
	db -1 ; end

DebugUnusedList: ; unreferenced
	db -1 ; end
ELSE
	ret
ENDC
