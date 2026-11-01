Obj77:
                moveq   #0,d0
                move.b  routine(a0),d0
                move.w  Obj77_Index(pc,d0.w),d1
                jmp     Obj77_Index(pc,d1.w)
; ===========================================================================
; off_28F96:
Obj77_Index:    offsetTable
                offsetTableEntry.w Obj77_Init           ; 0
                offsetTableEntry.w Obj77_Main           ; 2
; ===========================================================================
; loc_28F9A:
Obj77_Init:
                addq.b  #2,routine(a0)
                move.l  #Obj77_MapUnc_29064,mappings(a0)
                move.w  #make_art_tile(ArtTile_ArtNem_MCZGateLog,3,0),art_tile(a0)
                jsrto   JmpTo40_Adjust2PArtPointer
                ori.b   #1<<render_flags.level_fg,render_flags(a0)
                move.b  #$80,width_pixels(a0)
; loc_28FBC:
Obj77_Main:
                tst.b   objoff_34(a0)
                bne.s   +
                lea     (ButtonVine_Trigger).w,a2
                moveq   #0,d0
                move.b  subtype(a0),d0
                btst    #0,(a2,d0.w)
                beq.s   +
                move.b  #1,objoff_34(a0)
                bchg    #0,anim(a0)
                _btst   #render_flags.on_screen,render_flags(a0)
                _beq.s  +
                move.w  #SndID_DoorSlam,d0
                jsr     (PlaySound).l
+
                lea     (Ani_obj77).l,a1
                jsr     (AnimateSprite).l
                tst.b   mapping_frame(a0)
                bne.s   Obj77_DropCharacters
                move.w  #$4B,d1
                move.w  #8,d2
                move.w  d2,d3
                addq.w  #1,d3
                move.w  x_pos(a0),d4
                jsrto   JmpTo20_SolidObject
                jmpto   JmpTo23_MarkObjGone
; ===========================================================================

; Check if the characters are standing on it. If a character is standing on the
; bridge, the "standing on object" flag is cleared so that it falls

; loc_2901A:
Obj77_DropCharacters:
                move.b  status(a0),d0
                andi.b  #standing_mask,d0
                beq.s   +++
                move.b  d0,d1
                andi.b  #p1_standing,d0
                beq.s   +
                lea     (MainCharacter).w,a1            ; a1=character
                bclr    #status.player.on_object,status(a1)
+
                andi.b  #p2_standing,d1
                beq.s   +
                lea     (Sidekick).w,a1                 ; a1=character
                bclr    #status.player.on_object,status(a1)
+
                andi.b  #~standing_mask,status(a0)
+
                jmpto   JmpTo23_MarkObjGone
; ===========================================================================
; ---------------------------------------------------------------------------
; animation script
; ---------------------------------------------------------------------------
; off_29050:
Ani_obj77:      offsetTable
                offsetTableEntry.w Ani_obj77_Close      ; 0
                offsetTableEntry.w Ani_obj77_Open       ; 1
; byte_29054:
Ani_obj77_Close:
                dc.b    3,  4,  3,  2,  1,  0,$FE,  1
; byte_2905C:
Ani_obj77_Open:
                dc.b    3,  0,  1,  2,  3,  4,$FE,  1
                even
; ---------------------------------------------------------------------------
; sprite mappings
; ---------------------------------------------------------------------------
Obj77_MapUnc_29064:
Map_obj77:      mappingsTable
                mappingsTableEntry.w Map_obj77_000A
                mappingsTableEntry.w Map_obj77_004C
                mappingsTableEntry.w Map_obj77_008E
                mappingsTableEntry.w Map_obj77_00D0
                mappingsTableEntry.w Map_obj77_0112

Map_obj77_000A: spriteHeader
                spritePiece -$40, -8, 2, 2, 0, 0, 0, 0, 0
                spritePiece -$30, -8, 2, 2, 0, 0, 0, 0, 0
                spritePiece -$20, -8, 2, 2, 0, 0, 0, 0, 0
                spritePiece -$10, -8, 2, 2, 0, 0, 0, 0, 0
                spritePiece 0, -8, 2, 2, 0, 0, 0, 0, 0
                spritePiece $10, -8, 2, 2, 0, 0, 0, 0, 0
                spritePiece $20, -8, 2, 2, 0, 0, 0, 0, 0
                spritePiece $30, -8, 2, 2, 0, 0, 0, 0, 0
Map_obj77_000A_End

Map_obj77_004C: spriteHeader
                spritePiece -$40, -8, 2, 2, 0, 0, 0, 0, 0
                spritePiece -$32, -2, 2, 2, 0, 0, 0, 0, 0
                spritePiece -$23, 4, 2, 2, 0, 0, 0, 0, 0
                spritePiece -$14, $A, 2, 2, 0, 0, 0, 0, 0
                spritePiece 4, $A, 2, 2, 0, 0, 0, 0, 0
                spritePiece $13, 4, 2, 2, 0, 0, 0, 0, 0
                spritePiece $22, -2, 2, 2, 0, 0, 0, 0, 0
                spritePiece $30, -8, 2, 2, 0, 0, 0, 0, 0
Map_obj77_004C_End

Map_obj77_008E: spriteHeader
                spritePiece -$40, -8, 2, 2, 0, 0, 0, 0, 0
                spritePiece -$35, 3, 2, 2, 0, 0, 0, 0, 0
                spritePiece -$2A, $E, 2, 2, 0, 0, 0, 0, 0
                spritePiece -$1F, $19, 2, 2, 0, 0, 0, 0, 0
                spritePiece $F, $19, 2, 2, 0, 0, 0, 0, 0
                spritePiece $1A, $E, 2, 2, 0, 0, 0, 0, 0
                spritePiece $25, 3, 2, 2, 0, 0, 0, 0, 0
                spritePiece $30, -8, 2, 2, 0, 0, 0, 0, 0
Map_obj77_008E_End

Map_obj77_00D0: spriteHeader
                spritePiece -$40, -8, 2, 2, 0, 0, 0, 0, 0
                spritePiece -$3A, 6, 2, 2, 0, 0, 0, 0, 0
                spritePiece -$34, $15, 2, 2, 0, 0, 0, 0, 0
                spritePiece -$2E, $24, 2, 2, 0, 0, 0, 0, 0
                spritePiece $1E, $24, 2, 2, 0, 0, 0, 0, 0
                spritePiece $24, $15, 2, 2, 0, 0, 0, 0, 0
                spritePiece $2A, 6, 2, 2, 0, 0, 0, 0, 0
                spritePiece $30, -8, 2, 2, 0, 0, 0, 0, 0
Map_obj77_00D0_End

Map_obj77_0112: spriteHeader
                spritePiece -$40, -8, 2, 2, 0, 0, 0, 0, 0
                spritePiece -$40, 8, 2, 2, 0, 0, 0, 0, 0
                spritePiece -$40, $18, 2, 2, 0, 0, 0, 0, 0
                spritePiece -$40, $28, 2, 2, 0, 0, 0, 0, 0
                spritePiece $30, -8, 2, 2, 0, 0, 0, 0, 0
                spritePiece $30, 8, 2, 2, 0, 0, 0, 0, 0
                spritePiece $30, $18, 2, 2, 0, 0, 0, 0, 0
                spritePiece $30, $28, 2, 2, 0, 0, 0, 0, 0
Map_obj77_0112_End

                even
; ===========================================================================

                jmpTos  JmpTo23_MarkObjGone,JmpTo40_Adjust2PArtPointer,JmpTo20_SolidObject

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 78 - Stairs from CPZ that move down to open the way
; ---------------------------------------------------------------------------
; Sprite_291CC:
