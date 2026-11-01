Obj31:
                moveq   #0,d0
                move.b  routine(a0),d0
                move.w  Obj31_Index(pc,d0.w),d1
                jmp     Obj31_Index(pc,d1.w)
; ===========================================================================
; off_20DFA: Obj31_States:
Obj31_Index:    offsetTable
                offsetTableEntry.w Obj31_Init           ; 0
                offsetTableEntry.w Obj31_Main           ; 2
; ---------------------------------------------------------------------------
; byte_20DFE:
Obj31_CollisionFlagsBySubtype:
                dc.b    $96                             ; 0
                dc.b    $94                             ; 1
                dc.b    $95                             ; 2
                even
; ===========================================================================
; loc_20E02:
Obj31_Init:
                addq.b  #2,routine(a0)                  ; => Obj31_Main
                moveq   #0,d0
                move.b  subtype(a0),d0
                move.b  Obj31_CollisionFlagsBySubtype(pc,d0.w),collision_flags(a0)
; This dumb code is a workaround for the bug below
                move.l  #Obj31_MapUnc_20E6C,mappings(a0)
                tst.w   (Debug_placement_mode).w
                beq.s   +
                move.l  #Obj31_MapUnc_20E74,mappings(a0)
+
                move.w  #make_art_tile(ArtTile_ArtNem_Powerups,0,1),art_tile(a0)
; The high bit of 'render_flags' should not be set here: this causes
; this object to become visible when the player dies, because of how
; 'RunObjectsWhenPlayerIsDead' works
                move.b  #1<<render_flags.on_screen|1<<render_flags.level_fg,render_flags(a0)
                move.b  #$80,width_pixels(a0)
                move.b  #4,priority(a0)
                move.b  subtype(a0),mapping_frame(a0)

; loc_20E46:
Obj31_Main:
                tst.w   (Two_player_mode).w
                bne.s   +
                move.w  x_pos(a0),d0
                andi.w  #$FF80,d0
                sub.w   (Camera_X_pos_coarse).w,d0
                cmpi.w  #$280,d0
                bhi.w   JmpTo18_DeleteObject
+
                tst.w   (Debug_placement_mode).w
                beq.s   +                               ; rts
                jsrto   JmpTo10_DisplaySprite
+
                rts

; ===========================================================================
; -------------------------------------------------------------------------------
; sprite non-mappings
; -------------------------------------------------------------------------------
Obj31_MapUnc_20E6C:
Map_obj31_a:    mappingsTable
                mappingsTableEntry.w Map_obj31_a_0006
                mappingsTableEntry.w Map_obj31_a_0006
                mappingsTableEntry.w Map_obj31_a_0006

Map_obj31_a_0006:   spriteHeader
Map_obj31_a_0006_End

                even
; -------------------------------------------------------------------------------
; sprite mappings
; -------------------------------------------------------------------------------
Obj31_MapUnc_20E74:
Map_obj31_b:    mappingsTable
                mappingsTableEntry.w Map_obj31_b_0006
                mappingsTableEntry.w Map_obj31_b_0028
                mappingsTableEntry.w Map_obj31_b_004A

Map_obj31_b_0006:   spriteHeader
                spritePiece -$20, -$20, 2, 2, $34, 0, 0, 0, 0
                spritePiece $10, -$20, 2, 2, $34, 0, 0, 0, 0
                spritePiece -$20, $10, 2, 2, $34, 0, 0, 0, 0
                spritePiece $10, $10, 2, 2, $34, 0, 0, 0, 0
Map_obj31_b_0006_End

Map_obj31_b_0028:   spriteHeader
                spritePiece -$40, -$20, 2, 2, $34, 0, 0, 0, 0
                spritePiece $30, -$20, 2, 2, $34, 0, 0, 0, 0
                spritePiece -$40, $10, 2, 2, $34, 0, 0, 0, 0
                spritePiece $30, $10, 2, 2, $34, 0, 0, 0, 0
Map_obj31_b_0028_End

Map_obj31_b_004A:   spriteHeader
                spritePiece -$80, -$20, 2, 2, $34, 0, 0, 0, 0
                spritePiece $70, -$20, 2, 2, $34, 0, 0, 0, 0
                spritePiece -$80, $10, 2, 2, $34, 0, 0, 0, 0
                spritePiece $70, $10, 2, 2, $34, 0, 0, 0, 0
Map_obj31_b_004A_End

                even
; ===========================================================================

; ----------------------------------------------------------------------------
; Object 74 - Invisible solid block
; ----------------------------------------------------------------------------
; Sprite_20EE0:
