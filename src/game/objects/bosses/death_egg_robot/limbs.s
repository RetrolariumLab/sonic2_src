ObjC7_Shoulder:
                moveq   #0,d0
                move.b  routine_secondary(a0),d0
                move.w  off_3DA34(pc,d0.w),d1
                jsr     off_3DA34(pc,d1.w)
                lea     byte_3DA38(pc),a1
                bsr.w   DeathEggRobot_PositionFromParent
                tst.b   id(a0)
                beq.w   EnemiesTurtloid_Return_Variant3
                jmpto   JmpTo45_DisplaySprite
; ===========================================================================
off_3DA34:      offsetTable
                offsetTableEntry.w loc_3DA3C            ; 0
                offsetTableEntry.w DeathEggRobotBossLimbs_Return         ; 2
; ===========================================================================
byte_3DA38:
                dc.w    $C
                dc.w    -$14
; ===========================================================================

loc_3DA3C:
                addq.b  #2,routine_secondary(a0)
                move.b  #4,mapping_frame(a0)
                rts
; ===========================================================================

DeathEggRobotBossLimbs_Return:
                rts
; ===========================================================================
; loc_3DA4A
ObjC7_FrontLowerLeg:
                moveq   #0,d0
                move.b  routine_secondary(a0),d0
                move.w  off_3DA62(pc,d0.w),d1
                jsr     off_3DA62(pc,d1.w)
                tst.b   id(a0)
                beq.w   EnemiesTurtloid_Return_Variant3
                jmpto   JmpTo45_DisplaySprite
; ===========================================================================
off_3DA62:      offsetTable
                offsetTableEntry.w loc_3DA66            ; 0
                offsetTableEntry.w DeathEggRobotBossLimbs_Return_Variant2         ; 2
; ===========================================================================

loc_3DA66:
                addq.b  #2,routine_secondary(a0)
                move.b  #$B,mapping_frame(a0)
                rts
; ===========================================================================

DeathEggRobotBossLimbs_Return_Variant2:
                rts
; ===========================================================================
; loc_3DA74
ObjC7_FrontForearm:
                moveq   #0,d0
                move.b  routine_secondary(a0),d0
                move.w  off_3DA96(pc,d0.w),d1
                jsr     off_3DA96(pc,d1.w)
                tst.b   id(a0)
                beq.w   EnemiesTurtloid_Return_Variant3
                btst    #status.npc.p2_pushing,status(a0)
                bne.w   EnemiesTurtloid_Return_Variant3
                jmpto   JmpTo45_DisplaySprite
; ===========================================================================
off_3DA96:      offsetTable
                offsetTableEntry.w loc_3DAA0            ; 0
                offsetTableEntry.w loc_3DAAC            ; 2
                offsetTableEntry.w loc_3DACC            ; 4
                offsetTableEntry.w loc_3DB32            ; 6
                offsetTableEntry.w loc_3DB5A            ; 8
; ===========================================================================

loc_3DAA0:
                addq.b  #2,routine_secondary(a0)
                move.b  #6,mapping_frame(a0)
                rts
; ===========================================================================

loc_3DAAC:
                movea.w objoff_2C(a0),a1                ; a1=object
                bclr    #status.npc.p2_standing,status(a1)
                bne.s   +
                rts
; ---------------------------------------------------------------------------
+
                addq.b  #2,routine_secondary(a0)
                move.w  #$10,objoff_2A(a0)
                move.w  y_pos(a0),objoff_2E(a0)
                rts
; ===========================================================================

loc_3DACC:
                subq.w  #1,objoff_2A(a0)
                bmi.s   +
                addi.w  #$20,y_vel(a0)
                jmpto   JmpTo26_ObjectMove
; ---------------------------------------------------------------------------
+
                addq.b  #2,routine_secondary(a0)
                move.w  #$20,objoff_2A(a0)
                bsr.w   Obj_GetOrientationToPlayer
                abs.w   d2
                cmpi.w  #$100,d2
                blo.s   +
                move.w  #$FF,d2
+
                andi.w  #$C0,d2
                lsr.w   #5,d2
                move.w  word_3DB2A(pc,d2.w),d2
                tst.w   d1
                bne.s   +
                neg.w   d2
+
                move.w  d2,y_vel(a0)
                move.w  #$800,d2
                movea.w objoff_2C(a0),a1                ; a1=object
                btst    #render_flags.x_flip,render_flags(a0)
                bne.s   +
                neg.w   d2
+
                move.w  d2,x_vel(a0)
                moveq   #signextendB(SndID_SpindashRelease),d0
                jmpto   JmpTo12_PlaySound
; ===========================================================================
word_3DB2A:
                dc.w    $200
                dc.w    $100                            ; 1
                dc.w    $80                             ; 2
                dc.w    0                               ; 3
; ===========================================================================

loc_3DB32:
                subq.w  #1,objoff_2A(a0)
                bmi.s   +
                jmpto   JmpTo26_ObjectMove
; ---------------------------------------------------------------------------
+
                addq.b  #2,routine_secondary(a0)
                neg.w   x_vel(a0)
                move.w  #$20,objoff_2A(a0)
                move.w  objoff_2E(a0),d0
                sub.w   y_pos(a0),d0
                asl.w   #3,d0
                move.w  d0,y_vel(a0)
                rts
; ===========================================================================

loc_3DB5A:
                subq.w  #1,objoff_2A(a0)
                bmi.s   +
                jmpto   JmpTo26_ObjectMove
; ---------------------------------------------------------------------------
+
                move.b  #2,routine_secondary(a0)
                clr.w   x_vel(a0)
                clr.w   y_vel(a0)
                rts
; ===========================================================================
; loc_3DB74
ObjC7_Arm:
                moveq   #0,d0
                move.b  routine_secondary(a0),d0
                move.w  off_3DB8C(pc,d0.w),d1
                jsr     off_3DB8C(pc,d1.w)
                tst.b   id(a0)
                beq.w   EnemiesTurtloid_Return_Variant3
                jmpto   JmpTo45_DisplaySprite
; ===========================================================================
off_3DB8C:      offsetTable
                offsetTableEntry.w loc_3DB90            ; 0
                offsetTableEntry.w DeathEggRobotBossLimbs_Return_Variant3         ; 2
; ===========================================================================

loc_3DB90:
                addq.b  #2,routine_secondary(a0)
                move.b  #5,mapping_frame(a0)
                rts
; ===========================================================================

DeathEggRobotBossLimbs_Return_Variant3:
                rts
; ===========================================================================
; loc_3DB9E
ObjC7_FrontThigh:
                moveq   #0,d0
                move.b  routine_secondary(a0),d0
                move.w  off_3DBB6(pc,d0.w),d1
                jsr     off_3DBB6(pc,d1.w)
                tst.b   id(a0)
                beq.w   EnemiesTurtloid_Return_Variant3
                jmpto   JmpTo45_DisplaySprite
; ===========================================================================
off_3DBB6:      offsetTable
                offsetTableEntry.w loc_3DBBA            ; 0
                offsetTableEntry.w DeathEggRobotBossLimbs_Return_Variant4         ; 2
; ===========================================================================

loc_3DBBA:
                addq.b  #2,routine_secondary(a0)
                move.b  #$A,mapping_frame(a0)
                rts
; ===========================================================================

DeathEggRobotBossLimbs_Return_Variant4:
                rts
; ===========================================================================
; loc_3DBC8
ObjC7_Head:
                moveq   #0,d0
                move.b  routine_secondary(a0),d0
                move.w  off_3DBE8(pc,d0.w),d1
                jsr     off_3DBE8(pc,d1.w)
                lea     byte_3DBF2(pc),a1
                bsr.w   DeathEggRobot_PositionFromParent
                tst.b   id(a0)
                beq.w   EnemiesTurtloid_Return_Variant3
                jmpto   JmpTo45_DisplaySprite
; ===========================================================================
off_3DBE8:      offsetTable
                offsetTableEntry.w loc_3DBF6            ; 0
                offsetTableEntry.w loc_3DC02            ; 2
                offsetTableEntry.w loc_3DC1C            ; 4
                offsetTableEntry.w loc_3DC2A            ; 6
                offsetTableEntry.w loc_3DC46            ; 8
; ===========================================================================
byte_3DBF2:
                dc.w    0
                dc.w    -$34
; ===========================================================================

loc_3DBF6:
                addq.b  #2,routine_secondary(a0)
                move.b  #$15,mapping_frame(a0)
                rts
; ===========================================================================

loc_3DC02:
                movea.w (DEZ_Eggman).w,a1
                btst    #status.npc.p1_standing,status(a1)
                bne.s   +
                rts
; ---------------------------------------------------------------------------
+
                addq.b  #2,routine_secondary(a0)
                move.w  #$40,objoff_2A(a0)
                rts
; ===========================================================================

loc_3DC1C:
                lea     (Ani_objC7_a).l,a1
                jsrto   JmpTo25_AnimateSprite
                jmpto   JmpTo45_DisplaySprite
; ===========================================================================

loc_3DC2A:
                subq.w  #1,objoff_2A(a0)
                bmi.s   +
                jmpto   JmpTo45_DisplaySprite
; ---------------------------------------------------------------------------
+
                addq.b  #2,routine_secondary(a0)
                movea.w objoff_2C(a0),a1                ; a1=object
                bset    #status.npc.misc,status(a1)
                jmpto   JmpTo45_DisplaySprite
; ===========================================================================

loc_3DC46:
                move.b  #-1,collision_property(a0)
                jmpto   JmpTo45_DisplaySprite
; ===========================================================================
; loc_3DC50
ObjC7_Jet:
                moveq   #0,d0
                move.b  routine_secondary(a0),d0
                move.w  off_3DC66(pc,d0.w),d1
                jsr     off_3DC66(pc,d1.w)
                lea     byte_3DC70(pc),a1
                bra.w   DeathEggRobot_PositionFromParent
; ===========================================================================
off_3DC66:      offsetTable
                offsetTableEntry.w loc_3DC74
                offsetTableEntry.w loc_3DC80
                offsetTableEntry.w loc_3DC86
                offsetTableEntry.w loc_3DC94
                offsetTableEntry.w loc_3DC80
; ===========================================================================
byte_3DC70:
                dc.w    $38
                dc.w    $18
; ===========================================================================

loc_3DC74:
                addq.b  #2,routine_secondary(a0)
                move.b  #$C,mapping_frame(a0)
                rts
; ===========================================================================

loc_3DC80:
                move.b  #3,anim(a0)

loc_3DC86:
                lea     (Ani_objC7_b).l,a1
                jsrto   JmpTo25_AnimateSprite
                jmpto   JmpTo45_DisplaySprite
; ===========================================================================

loc_3DC94:
                move.b  #1,anim(a0)
                bra.s   loc_3DC86
; ===========================================================================
; loc_3DC9C
ObjC7_BackLowerLeg:
                moveq   #0,d0
                move.b  routine_secondary(a0),d0
                move.w  off_3DCB4(pc,d0.w),d1
                jsr     off_3DCB4(pc,d1.w)
                tst.b   id(a0)
                beq.w   EnemiesTurtloid_Return_Variant3
                jmpto   JmpTo45_DisplaySprite
; ===========================================================================
off_3DCB4:      offsetTable
                offsetTableEntry.w loc_3DCB8            ; 0
                offsetTableEntry.w DeathEggRobotBossLimbs_Return_Variant5         ; 2
; ===========================================================================

loc_3DCB8:
                addq.b  #2,routine_secondary(a0)
                move.b  #$B,mapping_frame(a0)
                move.b  #5,priority(a0)
                rts
; ===========================================================================

DeathEggRobotBossLimbs_Return_Variant5:
                rts
; ===========================================================================
; loc_3DCCC
ObjC7_BackForearm:
                moveq   #0,d0
                move.b  routine_secondary(a0),d0
                move.w  off_3DCE4(pc,d0.w),d1
                jsr     off_3DCE4(pc,d1.w)
                tst.b   id(a0)
                beq.w   EnemiesTurtloid_Return_Variant3
                jmpto   JmpTo45_DisplaySprite
; ===========================================================================
off_3DCE4:      offsetTable
                offsetTableEntry.w loc_3DCEE            ; 0
                offsetTableEntry.w loc_3DD00            ; 2
                offsetTableEntry.w loc_3DACC            ; 4
                offsetTableEntry.w loc_3DB32            ; 6
                offsetTableEntry.w loc_3DB5A            ; 8
; ===========================================================================

loc_3DCEE:
                addq.b  #2,routine_secondary(a0)
                move.b  #6,mapping_frame(a0)
                move.b  #5,priority(a0)
                rts
; ===========================================================================

loc_3DD00:
                movea.w objoff_2C(a0),a1                ; a1=object
                bclr    #status.npc.p1_pushing,status(a1)
                bne.s   +
                rts
; ---------------------------------------------------------------------------
+
                addq.b  #2,routine_secondary(a0)
                move.w  #$10,objoff_2A(a0)
                move.w  y_pos(a0),objoff_2E(a0)
                rts
; ===========================================================================
; loc_3DD20
ObjC7_BackThigh:
                moveq   #0,d0
                move.b  routine_secondary(a0),d0
                move.w  off_3DD38(pc,d0.w),d1
                jsr     off_3DD38(pc,d1.w)
                tst.b   id(a0)
                beq.w   EnemiesTurtloid_Return_Variant3
                jmpto   JmpTo45_DisplaySprite
; ===========================================================================
off_3DD38:      offsetTable
                offsetTableEntry.w loc_3DD3C            ; 0
                offsetTableEntry.w DeathEggRobotBossLimbs_Return_Variant6         ; 2
; ===========================================================================

loc_3DD3C:
                addq.b  #2,routine_secondary(a0)
                move.b  #$A,mapping_frame(a0)
                move.b  #5,priority(a0)
                rts
; ===========================================================================

DeathEggRobotBossLimbs_Return_Variant6:
                rts
; ===========================================================================
; loc_3DD50
