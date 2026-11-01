Obj4B:
                moveq   #0,d0
                move.b  routine(a0),d0
                move.w  Obj4B_Index(pc,d0.w),d1
                jmp     Obj4B_Index(pc,d1.w)
; ===========================================================================
; off_2D076:
Obj4B_Index:    offsetTable
                offsetTableEntry.w Obj4B_Init           ; 0
                offsetTableEntry.w Obj4B_Main           ; 2
                offsetTableEntry.w Obj4B_Flame          ; 4
                offsetTableEntry.w Obj4B_Projectile     ; 6
; ===========================================================================
; loc_2D07E:
Obj4B_Projectile:
                jsrto   JmpTo21_ObjectMove
                lea     (Ani_obj4B).l,a1
                jsrto   JmpTo15_AnimateSprite
                jmpto   JmpTo_MarkObjGone_P1
; ===========================================================================
; loc_2D090:
Obj4B_Flame:
                movea.l Obj4B_parent(a0),a1             ; a1=object
; This check doesn't really work: it's possible for an object to be
; loaded into the parent's slot before this object can check if the
; slot is empty. In fact, it will always be immediately occupied by
; the explosion object. This defect causes the flame to linger for a
; while after the Buzzer is destroyed. A better way to do this check
; would be to check if the ID is equal to 'ObjID_Buzzer'
                tst.b   id(a1)
                beq.w   JmpTo49_DeleteObject            ; branch, if object slot is empty. This check is incomplete and very unreliable; check Obj50_Wing to see how it should be done
                tst.w   Obj4B_turn_delay(a1)
                bmi.s   +                               ; branch, if parent isn't currently turning around
                rts
; ---------------------------------------------------------------------------
+                                                       ; follow parent object
                move.w  x_pos(a1),x_pos(a0)
                move.w  y_pos(a1),y_pos(a0)
                move.b  status(a1),status(a0)
                move.b  render_flags(a1),render_flags(a0)
                lea     (Ani_obj4B).l,a1
                jsrto   JmpTo15_AnimateSprite
                jmpto   JmpTo_MarkObjGone_P1

; ===========================================================================
; loc_2D0C8:
Obj4B_Init:
                move.l  #Obj4B_MapUnc_2D2EA,mappings(a0)
                move.w  #make_art_tile(ArtTile_ArtNem_Buzzer,0,0),art_tile(a0)
                jsrto   JmpTo57_Adjust2PArtPointer
                ori.b   #1<<render_flags.level_fg,render_flags(a0)
                move.b  #$A,collision_flags(a0)
                move.b  #4,priority(a0)
                move.b  #$10,width_pixels(a0)
                move.b  #$10,y_radius(a0)
                move.b  #$18,x_radius(a0)
                move.b  #3,priority(a0)
                addq.b  #2,routine(a0)                  ; => Obj4B_Main

; load exhaust flame object
                jsrto   JmpTo20_AllocateObjectAfterCurrent
                bne.s   +                               ; rts

                _move.b #ObjID_Buzzer,id(a1)            ; load obj4B
                move.b  #4,routine(a1)                  ; => Obj4B_Flame
                move.l  #Obj4B_MapUnc_2D2EA,mappings(a1)
                move.w  #make_art_tile(ArtTile_ArtNem_Buzzer,0,0),art_tile(a1)
                jsrto   JmpTo7_Adjust2PArtPointer2
                move.b  #4,priority(a1)
                move.b  #$10,width_pixels(a1)
                move.b  status(a0),status(a1)
                move.b  render_flags(a0),render_flags(a1)
                move.b  #1,anim(a1)
                move.l  a0,Obj4B_parent(a1)
                move.w  x_pos(a0),x_pos(a1)
                move.w  y_pos(a0),y_pos(a1)
                move.w  #$100,Obj4B_move_timer(a0)
                move.w  #-$100,x_vel(a0)
                btst    #render_flags.x_flip,render_flags(a0)
                beq.s   +                               ; rts
                neg.w   x_vel(a0)
+
                rts
; ===========================================================================
; loc_2D174:
Obj4B_Main:
                moveq   #0,d0
                move.b  routine_secondary(a0),d0
                move.w  Obj4B_Buzzer_States(pc,d0.w),d1
                jsr     Obj4B_Buzzer_States(pc,d1.w)
                lea     (Ani_obj4B).l,a1
                jsrto   JmpTo15_AnimateSprite
                jmpto   JmpTo_MarkObjGone_P1
; ===========================================================================
; off_2D190:
Obj4B_Buzzer_States:    offsetTable
                offsetTableEntry.w Obj4B_Roaming        ; 0
                offsetTableEntry.w Obj4B_Shooting       ; 2
; ===========================================================================
; loc_2D194:
Obj4B_Roaming:
                bsr.w   Obj4B_ChkPlayers
                subq.w  #1,Obj4B_turn_delay(a0)
                move.w  Obj4B_turn_delay(a0),d0
                cmpi.w  #$F,d0
                beq.s   Obj4B_TurnAround
                tst.w   d0
                bpl.s   EnemiesBuzzer_Return
                subq.w  #1,Obj4B_move_timer(a0)
                bgt.w   JmpTo21_ObjectMove
                move.w  #$1E,Obj4B_turn_delay(a0)

EnemiesBuzzer_Return:
                rts
; ---------------------------------------------------------------------------
; loc_2D1BA:
Obj4B_TurnAround:
                sf      Obj4B_shooting_flag(a0)         ; reenable shooting
                neg.w   x_vel(a0)                       ; reverse movement direction
                bchg    #render_flags.x_flip,render_flags(a0)
                bchg    #status.npc.x_flip,status(a0)
                move.w  #$100,Obj4B_move_timer(a0)
                rts

; ===========================================================================
; Start of subroutine Obj4B_ChkPlayers
; sub_2D1D6:
Obj4B_ChkPlayers:
                tst.b   Obj4B_shooting_flag(a0)
                bne.w   EnemiesBuzzer_Return_Variant2   ; branch, if shooting is disabled
                move.w  x_pos(a0),d0
                lea     (MainCharacter).w,a1            ; a1=character
                btst    #0,(Vint_runcount+3).w
                beq.s   +                               ; target Sidekick on uneven frames
                lea     (Sidekick).w,a1                 ; a1=character
+
                sub.w   x_pos(a1),d0                    ; get object's distance to player
                move.w  d0,d1                           ; save value for later
                bpl.s   +                               ; branch, if it was positive
                neg.w   d0                              ; get absolute value
+
; test if player is inside an 8 pixel wide strip
                cmpi.w  #$28,d0
                blt.s   EnemiesBuzzer_Return_Variant2
                cmpi.w  #$30,d0
                bgt.s   EnemiesBuzzer_Return_Variant2

                tst.w   d1                              ; test sign of distance
                bpl.s   Obj4B_PlayerIsLeft              ; branch, if player is left from object
                btst    #render_flags.x_flip,render_flags(a0)
                beq.s   EnemiesBuzzer_Return_Variant2   ; branch, if object is facing right
                bra.s   Obj4B_ReadyToShoot
; ---------------------------------------------------------------------------
; loc_2D216:
Obj4B_PlayerIsLeft:
                btst    #render_flags.x_flip,render_flags(a0)
                bne.s   EnemiesBuzzer_Return_Variant2   ; branch, if object is facing left

; loc_2D21E:
Obj4B_ReadyToShoot:
                st.b    Obj4B_shooting_flag(a0)         ; disable shooting
                addq.b  #2,routine_secondary(a0)        ; => Obj4B_Shooting
                move.b  #3,anim(a0)                     ; play shooting animation
                move.w  #$32,Obj4B_shot_timer(a0)

EnemiesBuzzer_Return_Variant2:
                rts
; End of subroutine Obj4B_ChkPlayers
; ===========================================================================
; loc_2D234:
Obj4B_Shooting:
                move.w  Obj4B_shot_timer(a0),d0         ; get timer value
                subq.w  #1,d0                           ; decrement
                blt.s   Obj4B_DoneShooting              ; branch, if timer has expired
                move.w  d0,Obj4B_shot_timer(a0)         ; update timer value
                cmpi.w  #$14,d0                         ; has timer reached a certain value?
                beq.s   Obj4B_ShootProjectile           ; if yes, branch
                rts
; ---------------------------------------------------------------------------
; loc_2D248:
Obj4B_DoneShooting:
                subq.b  #2,routine_secondary(a0)        ; => Obj4B_Roaming
                rts
; ---------------------------------------------------------------------------
; loc_2D24E
Obj4B_ShootProjectile:
                jsr     (AllocateObjectAfterCurrent).l  ; Find next open object space
                bne.s   +

                _move.b #ObjID_Buzzer,id(a1)            ; load obj4B
                move.b  #6,routine(a1)                  ; => Obj4B_Projectile
                move.l  #Obj4B_MapUnc_2D2EA,mappings(a1)
                move.w  #make_art_tile(ArtTile_ArtNem_Buzzer,0,0),art_tile(a1)
                jsrto   JmpTo7_Adjust2PArtPointer2
                move.b  #4,priority(a1)
                move.b  #$98,collision_flags(a1)
                move.b  #$10,width_pixels(a1)
                move.b  status(a0),status(a1)
                move.b  render_flags(a0),render_flags(a1)
                move.b  #2,anim(a1)
                move.w  x_pos(a0),x_pos(a1)
                move.w  y_pos(a0),y_pos(a1)
                addi.w  #$18,y_pos(a1)                  ; align vertically with stinger
                move.w  #$D,d0                          ; absolute horizontal offset for stinger
                move.w  #$180,y_vel(a1)
                move.w  #-$180,x_vel(a1)
                btst    #render_flags.x_flip,render_flags(a1)  ; is object facing left?
                beq.s   +                               ; if not, branch
                neg.w   x_vel(a1)                       ; move in other direction
                neg.w   d0                              ; make offset negative
+
                add.w   d0,x_pos(a1)                    ; align horizontally with stinger
                rts
; ===========================================================================
; animation script
; off_2D2CE:
Ani_obj4B:      offsetTable
                offsetTableEntry.w EnemiesBuzzer_Animation_Sequence0  ; 0
                offsetTableEntry.w EnemiesBuzzer_Animation_Sequence1  ; 1
                offsetTableEntry.w EnemiesBuzzer_Animation_Sequence2  ; 2
                offsetTableEntry.w EnemiesBuzzer_Animation_Sequence3  ; 3
EnemiesBuzzer_Animation_Sequence0:  dc.b    $0F, $00, $FF
EnemiesBuzzer_Animation_Sequence1:  dc.b    $02, $03, $04, $FF
EnemiesBuzzer_Animation_Sequence2:  dc.b    $03, $05, $06, $FF
EnemiesBuzzer_Animation_Sequence3:  dc.b    $09, $01, $01, $01, $01, $01, $FD, $00
                even
; ----------------------------------------------------------------------------
; sprite mappings -- Buzz Bomber Sprite Table
; ----------------------------------------------------------------------------
; MapUnc_2D2EA: SprTbl_Buzzer:
Obj4B_MapUnc_2D2EA:
Map_obj4B:      mappingsTable
                mappingsTableEntry.w Map_obj4B_000E
                mappingsTableEntry.w Map_obj4B_0020
                mappingsTableEntry.w Map_obj4B_003A
                mappingsTableEntry.w Map_obj4B_0054
                mappingsTableEntry.w Map_obj4B_005E
                mappingsTableEntry.w Map_obj4B_0068
                mappingsTableEntry.w Map_obj4B_0072

Map_obj4B_000E: spriteHeader
                spritePiece -$18, -8, 3, 2, 0, 0, 0, 0, 0
                spritePiece 0, -8, 3, 2, 6, 0, 0, 0, 0
Map_obj4B_000E_End

Map_obj4B_0020: spriteHeader
                spritePiece -$18, -8, 3, 2, 0, 0, 0, 0, 0
                spritePiece 0, -8, 2, 2, $C, 0, 0, 0, 0
                spritePiece 2, 8, 2, 2, $10, 0, 0, 0, 0
Map_obj4B_0020_End

Map_obj4B_003A: spriteHeader
                spritePiece -$18, -8, 3, 2, 0, 0, 0, 0, 0
                spritePiece 0, -8, 2, 2, $C, 0, 0, 0, 0
                spritePiece 2, 8, 2, 2, $14, 0, 0, 0, 0
Map_obj4B_003A_End

Map_obj4B_0054: spriteHeader
                spritePiece 4, -$10, 1, 2, $14, 0, 0, 0, 0
Map_obj4B_0054_End

Map_obj4B_005E: spriteHeader
                spritePiece 4, -$10, 1, 2, $16, 0, 0, 0, 0
Map_obj4B_005E_End

Map_obj4B_0068: spriteHeader
                spritePiece -$C, -8, 1, 2, $18, 0, 0, 0, 0
Map_obj4B_0068_End

Map_obj4B_0072: spriteHeader
                spritePiece -$C, -8, 1, 2, $1A, 0, 0, 0, 0
Map_obj4B_0072_End

                even
; ===========================================================================

                jmpTos0 JmpTo49_DeleteObject,JmpTo20_AllocateObjectAfterCurrent,JmpTo15_AnimateSprite,JmpTo7_Adjust2PArtPointer2,JmpTo_MarkObjGone_P1,JmpTo57_Adjust2PArtPointer,JmpTo21_ObjectMove

; ===========================================================================
; ----------------------------------------------------------------------------
; Object 5C - Masher (jumping piranha fish badnik) from EHZ
; ----------------------------------------------------------------------------
; OST Variables:
Obj5C_initial_y_pos     =       objoff_30               ; word

; Sprite_2D394:
