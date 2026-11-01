ObjC7_TargettingSensor:
                moveq   #0,d0
                move.b  routine_secondary(a0),d0
                move.w  off_3DD5E(pc,d0.w),d1
                jmp     off_3DD5E(pc,d1.w)
; ===========================================================================
off_3DD5E:      offsetTable
                offsetTableEntry.w loc_3DD64            ; 0
                offsetTableEntry.w loc_3DDA6            ; 2
                offsetTableEntry.w loc_3DE3C            ; 4
; ===========================================================================

loc_3DD64:
                addq.b  #2,routine_secondary(a0)
                move.b  #$10,mapping_frame(a0)
                ori.w   #high_priority,art_tile(a0)
                move.b  #1,priority(a0)
                move.w  #$A0,objoff_2A(a0)
                lea     (MainCharacter).w,a1            ; a1=character
                move.w  x_pos(a1),x_pos(a0)
                move.w  y_pos(a1),y_pos(a0)
                move.w  x_vel(a1),objoff_30(a0)
                move.w  y_vel(a1),objoff_32(a0)
                move.w  #$18,angle(a0)
                jmpto   JmpTo45_DisplaySprite
; ===========================================================================

loc_3DDA6:
                subq.w  #1,objoff_2A(a0)
                bmi.s   loc_3DE0A
                lea     next_object(a0),a1              ; a1=object
                movea.l a1,a2
                move.w  -(a1),y_vel(a0)
                move.w  -(a1),x_vel(a0)

                moveq   #2,d6
-               move.l  -(a1),-(a2)
                dbf     d6,-

                lea     (MainCharacter).w,a2            ; a2=character
                move.w  x_vel(a2),d0
                bne.s   +
                move.w  x_pos(a2),x_pos(a0)
+
                move.w  d0,(a1)+
                move.w  y_vel(a2),d0
                bne.s   +
                move.w  y_pos(a2),y_pos(a0)
+
                move.w  d0,(a1)+
                jsrto   JmpTo26_ObjectMove
                lea     (Ani_objC7_c).l,a1
                jsrto   JmpTo25_AnimateSprite
                subq.b  #1,angle(a0)
                bpl.s   +
                subq.b  #1,objoff_27(a0)
                move.b  objoff_27(a0),angle(a0)
                moveq   #signextendB(SndID_Beep),d0
                jsrto   JmpTo12_PlaySound
+
                jmpto   JmpTo45_DisplaySprite
; ===========================================================================

loc_3DE0A:
                addq.b  #2,routine_secondary(a0)
                move.w  #$40,objoff_2A(a0)
                move.b  #4,angle(a0)
                lea     (MainCharacter).w,a1            ; a1=character
                move.w  x_pos(a1),x_pos(a0)
                move.w  y_pos(a1),y_pos(a0)
                lea     (ChildObjC7_TargettingLock).l,a2
                bsr.w   LoadChildObject
                clr.w   x_vel(a0)
                jmpto   JmpTo45_DisplaySprite
; ===========================================================================

loc_3DE3C:
                subq.w  #1,objoff_2A(a0)
                bmi.s   loc_3DE62
                lea     (Ani_objC7_c).l,a1
                jsrto   JmpTo25_AnimateSprite
                subq.b  #1,angle(a0)
                bpl.s   +
                move.b  #4,angle(a0)
                moveq   #signextendB(SndID_Beep),d0
                jsrto   JmpTo12_PlaySound
+
                jmpto   JmpTo45_DisplaySprite
; ===========================================================================

loc_3DE62:
                movea.w objoff_2C(a0),a1                ; a1=object
                move.w  x_pos(a0),objoff_28(a1)
                jmpto   JmpTo65_DeleteObject
; ===========================================================================
; loc_3DE70
ObjC7_TargettingLock:
                moveq   #0,d0
                move.b  routine_secondary(a0),d0
                move.w  off_3DE7E(pc,d0.w),d1
                jmp     off_3DE7E(pc,d1.w)
; ===========================================================================
off_3DE7E:      offsetTable
                offsetTableEntry.w loc_3DE82            ; 0
                offsetTableEntry.w loc_3DEA2            ; 2
; ===========================================================================

loc_3DE82:
                addq.b  #2,routine_secondary(a0)
                move.b  #$14,mapping_frame(a0)
                move.b  #1,priority(a0)
                ori.w   #high_priority,art_tile(a0)
                move.w  #4,objoff_2A(a0)
                jmpto   JmpTo45_DisplaySprite
; ===========================================================================

loc_3DEA2:
                movea.w objoff_2C(a0),a1                ; a1=object
                tst.b   (a1)
                beq.w   JmpTo65_DeleteObject
                subq.w  #1,objoff_2A(a0)
                bne.s   +
                move.w  #4,objoff_2A(a0)
                bchg    #palette_bit_0,art_tile(a0)
+
                jmpto   JmpTo45_DisplaySprite
; ===========================================================================
; loc_3DEC2
ObjC7_EggmanBomb:
                moveq   #0,d0
                move.b  routine_secondary(a0),d0
                move.w  off_3DED0(pc,d0.w),d1
                jmp     off_3DED0(pc,d1.w)
; ===========================================================================
off_3DED0:      offsetTable
                offsetTableEntry.w loc_3DED8
                offsetTableEntry.w loc_3DF04
                offsetTableEntry.w loc_3DF36
                offsetTableEntry.w loc_3DF80
; ===========================================================================

loc_3DED8:
                addq.b  #2,routine_secondary(a0)
                move.b  #$E,mapping_frame(a0)
                move.b  #$89,collision_flags(a0)
                move.b  #5,priority(a0)
                move.b  #$C,width_pixels(a0)
                lea     byte_3DF00(pc),a1
                bsr.w   DeathEggRobot_PositionFromParent
                jmpto   JmpTo45_DisplaySprite
; ===========================================================================
byte_3DF00:
                dc.w    $38
                dc.w    -$14
; ===========================================================================

loc_3DF04:
                movea.w objoff_2C(a0),a1                ; a1=object
                btst    #status.npc.no_balancing,status(a1)
                bne.s   loc_3DF4C
                jsrto   JmpTo8_ObjectMoveAndFall
                move.w  y_pos(a0),d0
                cmpi.w  #$170,d0
                bhs.s   +
                jmpto   JmpTo45_DisplaySprite
; ===========================================================================
+
                addq.b  #2,routine_secondary(a0)
                move.w  #$170,y_pos(a0)
                move.w  #$40,objoff_2A(a0)
                jmpto   JmpTo45_DisplaySprite
; ===========================================================================

loc_3DF36:
                movea.w objoff_2C(a0),a1                ; a1=object
                btst    #status.npc.no_balancing,status(a1)
                bne.s   loc_3DF4C
                subq.w  #1,objoff_2A(a0)
                bmi.s   loc_3DF4C
                jmpto   JmpTo45_DisplaySprite
; ===========================================================================

loc_3DF4C:
                move.b  #6,routine_secondary(a0)
                move.l  #Obj58_MapUnc_2D50A,mappings(a0)
                move.w  #make_art_tile(ArtTile_ArtNem_FieryExplosion,0,0),art_tile(a0)
                move.b  #1,priority(a0)
                move.b  #7,anim_frame_duration(a0)
                move.b  #0,mapping_frame(a0)
                move.w  #SndID_BossExplosion,d0
                jsr     (PlaySound).l
                jmpto   JmpTo45_DisplaySprite
; ===========================================================================

loc_3DF80:
                subq.b  #1,anim_frame_duration(a0)
                bpl.s   +
                move.b  #7,anim_frame_duration(a0)
                addq.b  #1,mapping_frame(a0)
                cmpi.b  #5,mapping_frame(a0)
                blo.s   +
                clr.b   collision_flags(a0)
                cmpi.b  #7,mapping_frame(a0)
                beq.w   JmpTo65_DeleteObject
+
                jmpto   JmpTo45_DisplaySprite
; ===========================================================================
; loc_3DFAA
ObjC7_FallingPieces:
                subq.w  #1,objoff_2A(a0)
                bmi.w   JmpTo65_DeleteObject
                jsrto   JmpTo8_ObjectMoveAndFall
                jmpto   JmpTo45_DisplaySprite
; ===========================================================================

DeathEggRobot_SpawnRandomExplosion:
                jsr     (AllocateObject).l
                bne.s   +                               ; rts
                _move.b #ObjID_BossExplosion,id(a1)     ; load obj
                move.w  x_pos(a0),x_pos(a1)
                move.w  y_pos(a0),y_pos(a1)
                jsr     (RandomNumber).l
                move.w  d0,d1
                moveq   #0,d1
                move.b  d0,d1
                lsr.b   #2,d1
                subi.w  #$30,d1
                add.w   d1,x_pos(a1)
                lsr.w   #8,d0
                lsr.b   #2,d0
                subi.w  #$30,d0
                add.w   d0,y_pos(a1)
+
                rts
; ===========================================================================
; loc_3DFF8
ObjC7_CheckHit:
                tst.b   collision_property(a0)
                beq.s   ObjC7_Beaten
                tst.b   objoff_2A(a0)
                bne.s   ObjC7_Flashing
                tst.b   collision_flags(a0)
                beq.s   +
                movea.w objoff_36(a0),a1                ; a1=object
                tst.b   collision_flags(a1)
                bne.s   +++                             ; rts
                clr.b   collision_flags(a0)
                subq.b  #1,collision_property(a0)
                beq.s   ObjC7_Beaten
+
                move.b  #60,objoff_2A(a0)
                move.w  #SndID_BossHit,d0
                jsr     (PlaySound).l
; loc_3E02E
ObjC7_Flashing:
                lea     (Normal_palette_line2+2).w,a1
                moveq   #0,d0
                tst.w   (a1)
                bne.s   +
                move.w  #$EEE,d0
+
                move.w  d0,(a1)
                subq.b  #1,objoff_2A(a0)
                bne.s   +
                clr.w   (Normal_palette_line2+2).w
                move.b  #$16,collision_flags(a0)
                movea.w objoff_36(a0),a1                ; a1=object
                move.b  #$2A,collision_flags(a1)
+
                rts
; ===========================================================================
; loc_3E05A
ObjC7_Beaten:
                moveq   #100,d0
                bsr.w   AddPoints
                clr.b   anim_frame_duration(a0)
                move.b  #$E,routine_secondary(a0)
                bset    #status.npc.no_balancing,status(a0)
                clr.b   anim(a0)
                clr.b   collision_flags(a0)
                clr.w   x_vel(a0)
                clr.w   y_vel(a0)
                bsr.w   ObjC7_RemoveCollision
                bsr.w   ObjC7_Break
                movea.w objoff_38(a0),a1                ; a1=object
                jsrto   JmpTo6_DeleteObject2
                addq.w  #4,sp
                rts
; ===========================================================================
; loc_3E094
ObjC7_Break:
                lea     (ObjC7_BreakOffsets).l,a1
                lea     ObjC7_BreakSpeeds(pc),a2
                moveq   #0,d0
                moveq   #ObjC7_BreakOffsets_End-ObjC7_BreakOffsets-1,d6

-               move.b  (a1)+,d0
                movea.w (a0,d0.w),a3                    ; a3=object
                move.b  #$1E,routine(a3)
                clr.b   routine_secondary(a3)
                move.w  #$80,objoff_2A(a3)
                move.w  (a2)+,x_vel(a3)
                move.w  (a2)+,y_vel(a3)
                dbf     d6,-
                rts
; ===========================================================================
; word_3E0C6
ObjC7_BreakSpeeds:
                dc.w    $200,-$400
                dc.w    -$100,-$100                     ; 2
                dc.w    $300,-$300                      ; 4
                dc.w    -$100,-$400                     ; 6
                dc.w    $180,-$200                      ; 8
                dc.w    -$200,-$300                     ; 10
                dc.w    0,-$400                         ; 12
                dc.w    $100,-$300                      ; 14
ObjC7_BreakSpeeds_End
; byte_3E0E6
ObjC7_BreakOffsets:
                dc.b    objoff_2C
                dc.b    objoff_2E                       ; 1
                dc.b    objoff_30                       ; 2
                dc.b    objoff_32                       ; 3
                dc.b    objoff_34                       ; 4
                dc.b    objoff_3A                       ; 5
                dc.b    objoff_3C                       ; 6
                dc.b    objoff_3E                       ; 7
ObjC7_BreakOffsets_End
                even
; ===========================================================================
; loc_3E0EE
