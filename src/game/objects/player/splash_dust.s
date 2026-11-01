Obj08:
                moveq   #0,d0
                move.b  routine(a0),d0
                move.w  Obj08_Index(pc,d0.w),d1
                jmp     Obj08_Index(pc,d1.w)
; ===========================================================================
; off_1DD2E:
Obj08_Index:    offsetTable
                offsetTableEntry.w Obj08_Init           ; 0
                offsetTableEntry.w Obj08_Main           ; 2
                offsetTableEntry.w BranchTo16_DeleteObject  ; 4
                offsetTableEntry.w Obj08_CheckSkid      ; 6
; ===========================================================================
; loc_1DD36:
Obj08_Init:
                addq.b  #2,routine(a0)
                move.l  #Obj08_MapUnc_1DF5E,mappings(a0)
                ori.b   #1<<render_flags.level_fg,render_flags(a0)
                move.b  #1,priority(a0)
                move.b  #$10,width_pixels(a0)
                move.w  #make_art_tile(ArtTile_ArtNem_SonicDust,0,0),art_tile(a0)
                move.w  #MainCharacter,parent(a0)
                move.w  #tiles_to_bytes(ArtTile_ArtNem_SonicDust),obj08_vram_address(a0)
                cmpa.w  #Sonic_Dust,a0
                beq.s   +
                move.b  #1,obj08_belongs_to_tails(a0)
                cmpi.w  #2,(Player_mode).w
                beq.s   +
                move.w  #make_art_tile(ArtTile_ArtNem_TailsDust,0,0),art_tile(a0)
                move.w  #Sidekick,parent(a0)
                move.w  #tiles_to_bytes(ArtTile_ArtNem_TailsDust),obj08_vram_address(a0)
+
                bsr.w   Adjust2PArtPointer

; loc_1DD90:
Obj08_Main:
                movea.w parent(a0),a2                   ; a2=character
                moveq   #0,d0
                move.b  anim(a0),d0                     ; use current animation as a secondary routine counter
                add.w   d0,d0
                move.w  Obj08_DisplayModes(pc,d0.w),d1
                jmp     Obj08_DisplayModes(pc,d1.w)
; ===========================================================================
; off_1DDA4:
Obj08_DisplayModes: offsetTable
                offsetTableEntry.w Obj08_Display        ; 0
                offsetTableEntry.w Obj08_MdSplash       ; 2
                offsetTableEntry.w Obj08_MdSpindashDust  ; 4
                offsetTableEntry.w Obj08_MdSkidDust     ; 6
; ===========================================================================
; loc_1DDAC:
Obj08_MdSplash:
                move.w  (Water_Level_1).w,y_pos(a0)
                tst.b   prev_anim(a0)
                bne.s   Obj08_Display
                move.w  x_pos(a2),x_pos(a0)
                move.b  #0,status(a0)
                andi.w  #drawing_mask,art_tile(a0)
                bra.s   Obj08_Display
; ===========================================================================
; loc_1DDCC:
Obj08_MdSpindashDust:
                cmpi.b  #12,air_left(a2)
                blo.s   Obj08_ResetDisplayMode
                cmpi.b  #4,routine(a2)
                bhs.s   Obj08_ResetDisplayMode
                tst.b   spindash_flag(a2)
                beq.s   Obj08_ResetDisplayMode
                move.w  x_pos(a2),x_pos(a0)
                move.w  y_pos(a2),y_pos(a0)
                move.b  status(a2),status(a0)
                andi.b  #1<<status.npc.x_flip,status(a0)
                tst.b   obj08_belongs_to_tails(a0)
                beq.s   +
                subi_.w #4,y_pos(a0)                    ; Tails is shorter than Sonic
+
                tst.b   prev_anim(a0)
                bne.s   Obj08_Display
                andi.w  #drawing_mask,art_tile(a0)
                tst.w   art_tile(a2)
                bpl.s   Obj08_Display
                ori.w   #high_priority,art_tile(a0)
                bra.s   Obj08_Display
; ===========================================================================
; loc_1DE20:
Obj08_MdSkidDust:
                cmpi.b  #12,air_left(a2)
                blo.s   Obj08_ResetDisplayMode

; loc_1DE28:
Obj08_Display:
                lea     (Ani_obj08).l,a1
                jsr     (AnimateSprite).l
                bsr.w   Obj08_LoadDustOrSplashArt
                jmp     (DisplaySprite).l
; ===========================================================================
; loc_1DE3E:
Obj08_ResetDisplayMode:
                move.b  #0,anim(a0)
                rts
; ===========================================================================

BranchTo16_DeleteObject                                 ; BranchTo
                bra.w   DeleteObject
; ===========================================================================
; loc_1DE4A:
Obj08_CheckSkid:
                movea.w parent(a0),a2                   ; a2=character
                cmpi.b  #AniIDSonAni_Stop,anim(a2)      ; SonAni_Stop
                beq.s   Obj08_SkidDust
                move.b  #2,routine(a0)
                move.b  #0,obj08_dust_timer(a0)
                rts
; ===========================================================================
; loc_1DE64:
Obj08_SkidDust:
                subq.b  #1,obj08_dust_timer(a0)
                bpl.s   loc_1DEE0
                move.b  #3,obj08_dust_timer(a0)
                bsr.w   AllocateObject
                bne.s   loc_1DEE0
                _move.b id(a0),id(a1)                   ; load obj08
                move.w  x_pos(a2),x_pos(a1)
                move.w  y_pos(a2),y_pos(a1)
                addi.w  #$10,y_pos(a1)
                tst.b   obj08_belongs_to_tails(a0)
                beq.s   +
                subi_.w #4,y_pos(a1)                    ; Tails is shorter than Sonic
+
                move.b  #0,status(a1)
                move.b  #3,anim(a1)
                addq.b  #2,routine(a1)
                move.l  mappings(a0),mappings(a1)
                move.b  render_flags(a0),render_flags(a1)
                move.b  #1,priority(a1)
                move.b  #4,width_pixels(a1)
                move.w  art_tile(a0),art_tile(a1)
                move.w  parent(a0),parent(a1)
                andi.w  #drawing_mask,art_tile(a1)
                tst.w   art_tile(a2)
                bpl.s   loc_1DEE0
                ori.w   #high_priority,art_tile(a1)

loc_1DEE0:
                bsr.s   Obj08_LoadDustOrSplashArt
                rts
; ===========================================================================
; loc_1DEE4:
Obj08_LoadDustOrSplashArt:
                moveq   #0,d0
                move.b  mapping_frame(a0),d0
                cmp.b   obj08_previous_frame(a0),d0
                beq.s   PlayerSplashDust_Return
                move.b  d0,obj08_previous_frame(a0)
                lea     (Obj08_MapRUnc_1E074).l,a2
                add.w   d0,d0
                adda.w  (a2,d0.w),a2
                move.w  (a2)+,d5
                subq.w  #1,d5
                bmi.s   PlayerSplashDust_Return
                move.w  obj08_vram_address(a0),d4

-               moveq   #0,d1
                move.w  (a2)+,d1
                move.w  d1,d3
                lsr.w   #8,d3
                andi.w  #$F0,d3
                addi.w  #$10,d3
                andi.w  #$FFF,d1
                lsl.l   #5,d1
                addi.l  #ArtUnc_SplashAndDust,d1
                move.w  d4,d2
                add.w   d3,d4
                add.w   d3,d4
                jsr     (QueueDMATransfer).l
                dbf     d5,-

PlayerSplashDust_Return:
                rts
; ===========================================================================
; animation script
; off_1DF38:
Ani_obj08:      offsetTable
                offsetTableEntry.w Obj08Ani_Null        ; 0
                offsetTableEntry.w Obj08Ani_Splash      ; 1
                offsetTableEntry.w Obj08Ani_Dash        ; 2
                offsetTableEntry.w Obj08Ani_Skid        ; 3
Obj08Ani_Null:          dc.b    $1F,  0,$FF
Obj08Ani_Splash:dc.b    3,      1,  2,  3,  4,  5,  6,  7,  8,  9,$FD,  0
Obj08Ani_Dash:          dc.b    1, $A, $B, $C, $D, $E, $F,$10,$FF
Obj08Ani_Skid:          dc.b    3,$11,$12,$13,$14,$FC
                even
; -------------------------------------------------------------------------------
; sprite mappings
; -------------------------------------------------------------------------------
Obj08_MapUnc_1DF5E:
Map_obj08:      mappingsTable
                mappingsTableEntry.w Map_obj08_002C
                mappingsTableEntry.w Map_obj08_002E
                mappingsTableEntry.w Map_obj08_0038
                mappingsTableEntry.w Map_obj08_0042
                mappingsTableEntry.w Map_obj08_004C
                mappingsTableEntry.w Map_obj08_0056
                mappingsTableEntry.w Map_obj08_0060
                mappingsTableEntry.w Map_obj08_006A
                mappingsTableEntry.w Map_obj08_0074
                mappingsTableEntry.w Map_obj08_007E
                mappingsTableEntry.w Map_obj08_0088
                mappingsTableEntry.w Map_obj08_0092
                mappingsTableEntry.w Map_obj08_009C
                mappingsTableEntry.w Map_obj08_00A6
                mappingsTableEntry.w Map_obj08_00B8
                mappingsTableEntry.w Map_obj08_00CA
                mappingsTableEntry.w Map_obj08_00DC
                mappingsTableEntry.w Map_obj08_00EE
                mappingsTableEntry.w Map_obj08_00F8
                mappingsTableEntry.w Map_obj08_0102
                mappingsTableEntry.w Map_obj08_010C
                mappingsTableEntry.w Map_obj08_002C

Map_obj08_002C: spriteHeader
Map_obj08_002C_End

Map_obj08_002E: spriteHeader
                spritePiece -$10, -$E, 4, 2, 0, 0, 0, 0, 0
Map_obj08_002E_End

Map_obj08_0038: spriteHeader
                spritePiece -$10, -$1E, 4, 4, 0, 0, 0, 0, 0
Map_obj08_0038_End

Map_obj08_0042: spriteHeader
                spritePiece -$10, -$1E, 4, 4, 0, 0, 0, 0, 0
Map_obj08_0042_End

Map_obj08_004C: spriteHeader
                spritePiece -$10, -$1E, 4, 4, 0, 0, 0, 0, 0
Map_obj08_004C_End

Map_obj08_0056: spriteHeader
                spritePiece -$10, -$1E, 4, 4, 0, 0, 0, 0, 0
Map_obj08_0056_End

Map_obj08_0060: spriteHeader
                spritePiece -$10, -$1E, 4, 4, 0, 0, 0, 0, 0
Map_obj08_0060_End

Map_obj08_006A: spriteHeader
                spritePiece -$10, -$E, 4, 2, 0, 0, 0, 0, 0
Map_obj08_006A_End

Map_obj08_0074: spriteHeader
                spritePiece -$10, -$E, 4, 2, 0, 0, 0, 0, 0
Map_obj08_0074_End

Map_obj08_007E: spriteHeader
                spritePiece -$10, -$E, 4, 2, 0, 0, 0, 0, 0
Map_obj08_007E_End

Map_obj08_0088: spriteHeader
                spritePiece -$20, 4, 4, 2, 0, 0, 0, 0, 0
Map_obj08_0088_End

Map_obj08_0092: spriteHeader
                spritePiece -$20, 4, 4, 2, 0, 0, 0, 0, 0
Map_obj08_0092_End

Map_obj08_009C: spriteHeader
                spritePiece -$20, 4, 4, 2, 0, 0, 0, 0, 0
Map_obj08_009C_End

Map_obj08_00A6: spriteHeader
                spritePiece -$18, -$C, 1, 2, 0, 0, 0, 0, 0
                spritePiece -$20, 4, 4, 2, 2, 0, 0, 0, 0
Map_obj08_00A6_End

Map_obj08_00B8: spriteHeader
                spritePiece -$18, -$C, 2, 2, 0, 0, 0, 0, 0
                spritePiece -$20, 4, 4, 2, 4, 0, 0, 0, 0
Map_obj08_00B8_End

Map_obj08_00CA: spriteHeader
                spritePiece -$20, -$C, 3, 2, 0, 0, 0, 0, 0
                spritePiece -$20, 4, 4, 2, 6, 0, 0, 0, 0
Map_obj08_00CA_End

Map_obj08_00DC: spriteHeader
                spritePiece -$20, -$C, 3, 2, 0, 0, 0, 0, 0
                spritePiece -$20, 4, 4, 2, 6, 0, 0, 0, 0
Map_obj08_00DC_End

Map_obj08_00EE: spriteHeader
                spritePiece -8, -8, 2, 2, 0, 0, 0, 0, 0
Map_obj08_00EE_End

Map_obj08_00F8: spriteHeader
                spritePiece -8, -8, 2, 2, 4, 0, 0, 0, 0
Map_obj08_00F8_End

Map_obj08_0102: spriteHeader
                spritePiece -8, -8, 2, 2, 8, 0, 0, 0, 0
Map_obj08_0102_End

Map_obj08_010C: spriteHeader
                spritePiece -8, -8, 2, 2, $C, 0, 0, 0, 0
Map_obj08_010C_End

                even
; -------------------------------------------------------------------------------
; dynamic pattern loading cues
; -------------------------------------------------------------------------------
Obj08_MapRUnc_1E074:
DPLC_obj08:     mappingsTable
                mappingsTableEntry.w DPLC_obj08_002C
                mappingsTableEntry.w DPLC_obj08_002E
                mappingsTableEntry.w DPLC_obj08_0032
                mappingsTableEntry.w DPLC_obj08_0036
                mappingsTableEntry.w DPLC_obj08_003A
                mappingsTableEntry.w DPLC_obj08_003E
                mappingsTableEntry.w DPLC_obj08_0042
                mappingsTableEntry.w DPLC_obj08_0046
                mappingsTableEntry.w DPLC_obj08_004A
                mappingsTableEntry.w DPLC_obj08_004E
                mappingsTableEntry.w DPLC_obj08_0052
                mappingsTableEntry.w DPLC_obj08_0056
                mappingsTableEntry.w DPLC_obj08_005A
                mappingsTableEntry.w DPLC_obj08_005E
                mappingsTableEntry.w DPLC_obj08_0064
                mappingsTableEntry.w DPLC_obj08_006A
                mappingsTableEntry.w DPLC_obj08_0070
                mappingsTableEntry.w DPLC_obj08_0076
                mappingsTableEntry.w DPLC_obj08_0076
                mappingsTableEntry.w DPLC_obj08_0076
                mappingsTableEntry.w DPLC_obj08_0076
                mappingsTableEntry.w DPLC_obj08_0078

DPLC_obj08_002C:    dplcHeader
DPLC_obj08_002C_End

DPLC_obj08_002E:    dplcHeader
                dplcEntry 8, 0
DPLC_obj08_002E_End

DPLC_obj08_0032:    dplcHeader
                dplcEntry $10, 8
DPLC_obj08_0032_End

DPLC_obj08_0036:    dplcHeader
                dplcEntry $10, $18
DPLC_obj08_0036_End

DPLC_obj08_003A:    dplcHeader
                dplcEntry $10, $28
DPLC_obj08_003A_End

DPLC_obj08_003E:    dplcHeader
                dplcEntry $10, $38
DPLC_obj08_003E_End

DPLC_obj08_0042:    dplcHeader
                dplcEntry $10, $48
DPLC_obj08_0042_End

DPLC_obj08_0046:    dplcHeader
                dplcEntry 8, $58
DPLC_obj08_0046_End

DPLC_obj08_004A:    dplcHeader
                dplcEntry 8, $60
DPLC_obj08_004A_End

DPLC_obj08_004E:    dplcHeader
                dplcEntry 8, $68
DPLC_obj08_004E_End

DPLC_obj08_0052:    dplcHeader
                dplcEntry 8, $70
DPLC_obj08_0052_End

DPLC_obj08_0056:    dplcHeader
                dplcEntry 8, $78
DPLC_obj08_0056_End

DPLC_obj08_005A:    dplcHeader
                dplcEntry 8, $80
DPLC_obj08_005A_End

DPLC_obj08_005E:    dplcHeader
                dplcEntry 2, $88
                dplcEntry 8, $8A
DPLC_obj08_005E_End

DPLC_obj08_0064:    dplcHeader
                dplcEntry 4, $92
                dplcEntry 8, $96
DPLC_obj08_0064_End

DPLC_obj08_006A:    dplcHeader
                dplcEntry 6, $9E
                dplcEntry 8, $A4
DPLC_obj08_006A_End

DPLC_obj08_0070:    dplcHeader
                dplcEntry 6, $AC
                dplcEntry 8, $B2
DPLC_obj08_0070_End

DPLC_obj08_0076:    dplcHeader
DPLC_obj08_0076_End

DPLC_obj08_0078:    dplcHeader
                dplcEntry $10, $BA
DPLC_obj08_0078_End

                even
; ===========================================================================
; ----------------------------------------------------------------------------
; Object 7E - Super Sonic's stars
; ----------------------------------------------------------------------------
; Sprite_1E0F0:
