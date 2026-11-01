Obj48:
                moveq   #0,d0
                move.b  routine(a0),d0
                move.w  Obj48_Index(pc,d0.w),d1
                jsr     Obj48_Index(pc,d1.w)
                move.b  objoff_2C(a0),d0
                add.b   objoff_36(a0),d0
                beq.w   JmpTo14_MarkObjGone
                jmpto   JmpTo15_DisplaySprite

; ===========================================================================
; off_25262:
Obj48_Index:    offsetTable
                offsetTableEntry.w Obj48_Init           ; 0
                offsetTableEntry.w Obj48_Main           ; 2
; ===========================================================================
obj48_render_flags  function xFlip,yFlip,1<<render_flags.level_fg|xFlip<<render_flags.x_flip|yFlip<<render_flags.y_flip

; byte_25266:
Obj48_Properties:
; render_flags                      objoff_3F
                dc.b    obj48_render_flags(FALSE,FALSE), 0  ; 0
                dc.b    obj48_render_flags(FALSE, TRUE), 7  ; 2
                dc.b    obj48_render_flags( TRUE, TRUE), 0  ; 4
                dc.b    obj48_render_flags( TRUE,FALSE), 7  ; 6
                dc.b    obj48_render_flags( TRUE,FALSE), 0  ; 8
                dc.b    obj48_render_flags(FALSE,FALSE), 7  ; 10
                dc.b    obj48_render_flags(FALSE, TRUE), 0  ; 12
                dc.b    obj48_render_flags( TRUE, TRUE), 7  ; 14
; ===========================================================================
; loc_25276:
Obj48_Init:
                addq.b  #2,routine(a0)
                move.l  #Obj48_MapUnc_254FE,mappings(a0)
                move.w  #make_art_tile(ArtTile_ArtNem_LaunchBall,3,0),art_tile(a0)
                jsrto   JmpTo23_Adjust2PArtPointer
                move.b  subtype(a0),d0
                andi.w  #$F,d0
                btst    #status.npc.x_flip,status(a0)
                beq.s   +
                addq.w  #4,d0
+
                add.w   d0,d0
                move.b  Obj48_Properties(pc,d0.w),render_flags(a0)
                move.b  Obj48_Properties+1(pc,d0.w),objoff_3F(a0)
                beq.s   +
                move.b  #1,objoff_3E(a0)
+
                move.b  objoff_3F(a0),mapping_frame(a0)
                move.b  #$28,width_pixels(a0)
                move.b  #1,priority(a0)
; loc_252C6:
Obj48_Main:
                lea     (MainCharacter).w,a1            ; a1=character
                lea     objoff_2C(a0),a4
                moveq   #objoff_2C,d2
                bsr.s   OozCannon_DispatchPlayerState
                lea     (Sidekick).w,a1                 ; a1=character
                lea     objoff_36(a0),a4
                moveq   #objoff_36,d2

OozCannon_DispatchPlayerState:
                moveq   #0,d0
                move.b  (a4),d0
                move.w  Obj48_Modes(pc,d0.w),d0
                jmp     Obj48_Modes(pc,d0.w)
; ===========================================================================
; off_252E8:
Obj48_Modes:    offsetTable
                offsetTableEntry.w loc_252F0            ; 0
                offsetTableEntry.w loc_253C6            ; 2
                offsetTableEntry.w loc_25474            ; 4
                offsetTableEntry.w loc_254F2            ; 6
; ===========================================================================

loc_252F0:
                tst.w   (Debug_placement_mode).w
                bne.w   OozCannon_Return
                move.w  x_pos(a1),d0
                sub.w   x_pos(a0),d0
                addi.w  #$10,d0
                cmpi.w  #$20,d0
                bhs.w   OozCannon_Return
                move.w  y_pos(a1),d1
                sub.w   y_pos(a0),d1
                addi.w  #$10,d1
                cmpi.w  #$20,d1
                bhs.w   OozCannon_Return
                cmpa.w  #Sidekick,a1
                bne.s   +
                cmpi.w  #4,(Tails_CPU_routine).w        ; TailsCPU_Flying
                beq.w   OozCannon_Return
+
                cmpi.b  #6,routine(a1)
                bhs.w   OozCannon_Return
                tst.w   (Debug_placement_mode).w
                bne.w   OozCannon_Return
                btst    #status.player.on_object,status(a1)
                beq.s   +
                moveq   #0,d0
                move.b  interact(a1),d0
                if      object_size=$40
                lsl.w   #object_size_bits,d0
                else
                mulu.w  #object_size,d0
                endif
                addi.l  #Object_RAM,d0
                movea.l d0,a3                           ; a3=object
                move.b  #0,(a3,d2.w)
+
                if      object_size<>$40
                moveq   #0,d0                           ; Clear the high word for the coming division
                endif
                move.w  a0,d0
                subi.w  #Object_RAM,d0
                if      object_size=$40
                lsr.w   #object_size_bits,d0
                else
                divu.w  #object_size,d0
                endif
                andi.w  #$7F,d0
                move.b  d0,interact(a1)
                addq.b  #2,(a4)
                move.w  x_pos(a0),x_pos(a1)
                move.w  y_pos(a0),y_pos(a1)
                move.b  #$81,obj_control(a1)
                move.b  #2,anim(a1)
                move.w  #$1000,inertia(a1)
                move.w  #0,x_vel(a1)
                move.w  #0,y_vel(a1)
                bclr    #status.npc.p1_pushing,status(a0)
                bclr    #status.player.pushing,status(a1)
                bset    #status.player.in_air,status(a1)
                bset    #status.player.on_object,status(a1)
                move.b  objoff_3F(a0),mapping_frame(a0)
                move.w  #SndID_Roll,d0
                jsr     (PlaySound).l

OozCannon_Return:
                rts
; ===========================================================================

loc_253C6:
                tst.b   objoff_3E(a0)
                bne.s   loc_253EE
                cmpi.b  #7,mapping_frame(a0)
                beq.s   loc_25408
                subq.w  #1,anim_frame_duration(a0)
                bpl.s   OozCannon_Return_Variant2
                move.w  #7,anim_frame_duration(a0)
                addq.b  #1,mapping_frame(a0)
                cmpi.b  #7,mapping_frame(a0)
                beq.s   loc_25408

OozCannon_Return_Variant2:
                rts
; ===========================================================================

loc_253EE:
                tst.b   mapping_frame(a0)
                beq.s   loc_25408
                subq.w  #1,anim_frame_duration(a0)
                bpl.s   OozCannon_Return_Variant2
                move.w  #7,anim_frame_duration(a0)
                subq.b  #1,mapping_frame(a0)
                beq.s   loc_25408
                rts
; ===========================================================================

loc_25408:
                addq.b  #2,(a4)
                move.b  subtype(a0),d0
                addq.b  #1,d0
                btst    #status.npc.x_flip,status(a0)
                beq.s   +
                subq.b  #2,d0
+
                andi.w  #3,d0
                add.w   d0,d0
                add.w   d0,d0
                move.w  word_25464(pc,d0.w),x_vel(a1)
                move.w  word_25464+2(pc,d0.w),y_vel(a1)
                move.w  #3,anim_frame_duration(a0)
                tst.b   subtype(a0)
                bpl.s   OozCannon_Return_Variant3
                move.b  #0,obj_control(a1)
                bset    #status.player.in_air,status(a1)
                bclr    #status.player.on_object,status(a1)
                move.b  #0,jumping(a1)
                move.b  #2,routine(a1)
                move.b  #6,(a4)
                move.w  #7,objoff_3C(a0)

OozCannon_Return_Variant3:
                rts
; ===========================================================================
word_25464:
                dc.w    0,-$1000
                dc.w    $1000,     0                    ; 2
                dc.w    0, $1000                        ; 4
                dc.w    -$1000,     0                   ; 6
; ===========================================================================

loc_25474:
                _btst   #render_flags.on_screen,render_flags(a1)
                _bne.s  loc_25492
                move.b  #0,obj_control(a1)
                bset    #status.player.in_air,status(a1)
                bclr    #status.player.on_object,status(a1)
                move.b  #0,(a4)
                rts
; ===========================================================================

loc_25492:
                cmpi.b  #2,objoff_2C(a0)
                beq.s   Obj48_MoveCharacter
                cmpi.b  #2,objoff_36(a0)
                beq.s   Obj48_MoveCharacter
                subq.w  #1,anim_frame_duration(a0)
                bpl.s   Obj48_MoveCharacter
                move.w  #1,anim_frame_duration(a0)
                tst.b   objoff_3E(a0)
                beq.s   loc_254C2
                cmpi.b  #7,mapping_frame(a0)
                beq.s   Obj48_MoveCharacter
                addq.b  #1,mapping_frame(a0)
                bra.s   Obj48_MoveCharacter
; ===========================================================================

loc_254C2:
                tst.b   mapping_frame(a0)
                beq.s   Obj48_MoveCharacter
                subq.b  #1,mapping_frame(a0)

; update the position of Sonic/Tails between launchers
; loc_254CC:
Obj48_MoveCharacter:
                move.l  x_pos(a1),d2
                move.l  y_pos(a1),d3
                move.w  x_vel(a1),d0
                ext.l   d0
                asl.l   #8,d0
                add.l   d0,d2
                move.w  y_vel(a1),d0
                ext.l   d0
                asl.l   #8,d0
                add.l   d0,d3
                move.l  d2,x_pos(a1)
                move.l  d3,y_pos(a1)
                rts
; ===========================================================================

loc_254F2:
                subq.w  #1,objoff_3C(a0)
                bpl.s   +                               ; rts
                move.b  #0,(a4)
+
                rts
; ===========================================================================
; ---------------------------------------------------------------------------
; sprite mappings
; ---------------------------------------------------------------------------
Obj48_MapUnc_254FE:
Map_obj48:      mappingsTable
                mappingsTableEntry.w Map_obj48_0010
                mappingsTableEntry.w Map_obj48_0052
                mappingsTableEntry.w Map_obj48_0084
                mappingsTableEntry.w Map_obj48_00A6
                mappingsTableEntry.w Map_obj48_00C8
                mappingsTableEntry.w Map_obj48_00EA
                mappingsTableEntry.w Map_obj48_010C
                mappingsTableEntry.w Map_obj48_013E

Map_obj48_0010: spriteHeader
                spritePiece -$10, -$28, 2, 1, 0, 0, 0, 0, 0
                spritePiece 0, -$28, 2, 1, 0, 1, 0, 0, 0
                spritePiece -$10, -$20, 2, 1, 2, 0, 0, 0, 0
                spritePiece 0, -$20, 2, 1, 2, 1, 0, 0, 0
                spritePiece -$18, -$18, 3, 3, $11, 0, 0, 0, 0
                spritePiece 0, -$18, 3, 3, $11, 1, 0, 0, 0
                spritePiece -$18, 0, 3, 3, 8, 0, 1, 0, 0
                spritePiece 0, 0, 3, 3, 8, 1, 1, 0, 0
Map_obj48_0010_End

Map_obj48_0052: spriteHeader
                spritePiece -$10, -$20, 2, 1, 0, 0, 0, 0, 0
                spritePiece 0, -$20, 2, 1, 0, 1, 0, 0, 0
                spritePiece -$18, -$18, 3, 3, $11, 0, 0, 0, 0
                spritePiece 0, -$18, 3, 3, $11, 1, 0, 0, 0
                spritePiece -$18, 0, 3, 3, 8, 0, 1, 0, 0
                spritePiece 0, 0, 3, 3, 8, 1, 1, 0, 0
Map_obj48_0052_End

Map_obj48_0084: spriteHeader
                spritePiece -$18, -$18, 3, 3, $11, 0, 0, 0, 0
                spritePiece 0, -$18, 3, 3, $11, 1, 0, 0, 0
                spritePiece -$18, 0, 3, 3, 8, 0, 1, 0, 0
                spritePiece 0, 0, 3, 3, 8, 1, 1, 0, 0
Map_obj48_0084_End

Map_obj48_00A6: spriteHeader
                spritePiece -$18, -$18, 3, 3, $1A, 0, 0, 0, 0
                spritePiece 0, -$18, 3, 3, $23, 1, 1, 0, 0
                spritePiece -$18, 0, 3, 3, $23, 0, 0, 0, 0
                spritePiece 0, 0, 3, 3, $1A, 1, 1, 0, 0
Map_obj48_00A6_End

Map_obj48_00C8: spriteHeader
                spritePiece -$18, -$18, 3, 3, $23, 0, 1, 0, 0
                spritePiece 0, -$18, 3, 3, $1A, 1, 0, 0, 0
                spritePiece -$18, 0, 3, 3, $1A, 0, 1, 0, 0
                spritePiece 0, 0, 3, 3, $23, 1, 0, 0, 0
Map_obj48_00C8_End

Map_obj48_00EA: spriteHeader
                spritePiece -$18, -$18, 3, 3, 8, 0, 0, 0, 0
                spritePiece 0, -$18, 3, 3, $2C, 0, 1, 0, 0
                spritePiece -$18, 0, 3, 3, 8, 0, 1, 0, 0
                spritePiece 0, 0, 3, 3, $2C, 0, 0, 0, 0
Map_obj48_00EA_End

Map_obj48_010C: spriteHeader
                spritePiece -$18, -$18, 3, 3, 8, 0, 0, 0, 0
                spritePiece 0, -$18, 3, 3, $2C, 0, 1, 0, 0
                spritePiece -$18, 0, 3, 3, 8, 0, 1, 0, 0
                spritePiece 0, 0, 3, 3, $2C, 0, 0, 0, 0
                spritePiece $18, -$10, 1, 2, 6, 0, 0, 0, 0
                spritePiece $18, 0, 1, 2, 6, 0, 1, 0, 0
Map_obj48_010C_End

Map_obj48_013E: spriteHeader
                spritePiece -$18, -$18, 3, 3, 8, 0, 0, 0, 0
                spritePiece 0, -$18, 3, 3, $2C, 0, 1, 0, 0
                spritePiece -$18, 0, 3, 3, 8, 0, 1, 0, 0
                spritePiece 0, 0, 3, 3, $2C, 0, 0, 0, 0
                spritePiece $18, -$10, 1, 2, 4, 0, 0, 0, 0
                spritePiece $18, 0, 1, 2, 4, 0, 1, 0, 0
                spritePiece $20, -$10, 1, 2, 6, 0, 0, 0, 0
                spritePiece $20, 0, 1, 2, 6, 0, 1, 0, 0
Map_obj48_013E_End

                even
; ===========================================================================

                jmpTos  JmpTo15_DisplaySprite,JmpTo14_MarkObjGone,JmpTo23_Adjust2PArtPointer

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 22 - Arrow shooter from ARZ
; ---------------------------------------------------------------------------
; Sprite_25694:
