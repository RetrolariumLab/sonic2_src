Obj5E:
                move.b  routine(a0),d0
                bne.w   JmpTo_DisplaySprite
                move.l  #Obj5E_MapUnc_7070,mappings(a0)
                move.w  #make_art_tile(ArtTile_ArtNem_SpecialHUD,0,0),art_tile(a0)
                move.b  #1<<render_flags.level_fg,render_flags(a0)
; Multi-sprite objects cannot use the 'priority' SST as it is
; overwritten by 'sub3_y_pos'
                move.b  #0,priority(a0)
                move.b  #1,routine(a0)
                bset    #render_flags.multi_sprite,render_flags(a0)
                moveq   #0,d1
                tst.b   (SS_2p_Flag).w
                beq.s   +
                addq.w  #6,d1
                tst.b   (Graphics_Flags).w
                bpl.s   ++
                addq.w  #1,d1
                bra.s   ++
; ---------------------------------------------------------------------------
+               move.w  (Player_mode).w,d1
                andi.w  #3,d1
                tst.b   (Graphics_Flags).w
                bpl.s   +
                addq.w  #3,d1                           ; set special stage Tails name to "TAILS" instead of MILES
+
                add.w   d1,d1
                moveq   #0,d2
                moveq   #0,d3
                lea     (SSHUDLayout).l,a1
                lea     subspr_data(a0),a2
                adda.w  (a1,d1.w),a1
                move.b  (a1)+,d3
                move.b  d3,mainspr_childsprites(a0)
                subq.w  #1,d3
                moveq   #0,d0
                move.b  (a1)+,d0

-               move.w  d0,(a2,d2.w)
                move.b  (a1)+,sub2_mapframe-sub2_x_pos(a2,d2.w)  ; sub2_mapframe
                addq.w  #next_subspr,d2
                dbf     d3,-

                rts
; ===========================================================================
; off_7042:
SSHUDLayout:    offsetTable
                offsetTableEntry.w SSHUD_SonicMilesTotal  ; 0
                offsetTableEntry.w SSHUD_Sonic          ; 1
                offsetTableEntry.w SSHUD_Miles          ; 2
                offsetTableEntry.w SSHUD_SonicTailsTotal  ; 3
                offsetTableEntry.w SSHUD_Sonic_2        ; 4
                offsetTableEntry.w SSHUD_Tails          ; 5
                offsetTableEntry.w SSHUD_SonicMiles     ; 6
                offsetTableEntry.w SSHUD_SonicTails     ; 7

; byte_7052:
SSHUD_SonicMilesTotal:
                dc.b    3                               ; Sprite count
                dc.b    $80                             ; X-pos
                dc.b    0,  1,  3                       ; Sprite 1 frame, Sprite 2 frame, etc
; byte_7057:
SSHUD_Sonic:
                dc.b    1
                dc.b    $D4
                dc.b    0
; byte_705A:
SSHUD_Miles:
                dc.b    1
                dc.b    $38
                dc.b    1

; byte_705D:
SSHUD_SonicTailsTotal:
                dc.b    3
                dc.b    $80
                dc.b    0,  2,  3
; byte_7062:
SSHUD_Sonic_2:
                dc.b    1
                dc.b    $D4
                dc.b    0
; byte_7065:
SSHUD_Tails:
                dc.b    1
                dc.b    $38
                dc.b    2

; 2 player
; byte_7068:
SSHUD_SonicMiles:
                dc.b    2
                dc.b    $80
                dc.b    0,  1
; byte_706C:
SSHUD_SonicTails:
                dc.b    2
                dc.b    $80
                dc.b    0,  2
; -----------------------------------------------------------------------------------
; sprite mappings
; -----------------------------------------------------------------------------------
Obj5E_MapUnc_7070:
Map_obj5E:      mappingsTable
                mappingsTableEntry.w Map_obj5E_0008
                mappingsTableEntry.w Map_obj5E_002A
                mappingsTableEntry.w Map_obj5E_004C
                mappingsTableEntry.w Map_obj5E_006E

Map_obj5E_0008: spriteHeader
                spritePiece -$60, $10, 4, 1, 0, 0, 0, 1, 1
                spritePiece -$40, $10, 1, 1, 4, 0, 0, 1, 1
                spritePiece -$68, $18, 4, 2, $A, 0, 0, 2, 1
                spritePiece -$48, $18, 1, 2, $3C, 0, 0, 2, 1
Map_obj5E_0008_End

Map_obj5E_002A: spriteHeader
                spritePiece $38, $10, 4, 1, 5, 0, 0, 2, 1
                spritePiece $58, $10, 1, 1, 9, 0, 0, 2, 1
                spritePiece $30, $18, 4, 2, $A, 0, 0, 2, 1
                spritePiece $50, $18, 1, 2, $3C, 0, 0, 2, 1
Map_obj5E_002A_End

Map_obj5E_004C: spriteHeader
                spritePiece $38, $10, 4, 1, $5AA, 0, 0, 2, 1
                spritePiece $58, $10, 1, 1, $5AE, 0, 0, 2, 1
                spritePiece $30, $18, 4, 2, $A, 0, 0, 2, 1
                spritePiece $50, $18, 1, 2, $3C, 0, 0, 2, 1
Map_obj5E_004C_End

Map_obj5E_006E: spriteHeader
                spritePiece -$14, $10, 4, 4, $26, 0, 0, 2, 1
                spritePiece $C, $10, 1, 4, $36, 0, 0, 2, 1
Map_obj5E_006E_End

                even
; ===========================================================================
; ----------------------------------------------------------------------------
; Object 5F - Start banner/"Ending controller" from Special Stage
; ----------------------------------------------------------------------------
; Sprite_70F0:
