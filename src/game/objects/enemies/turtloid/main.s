Obj9A:
                moveq   #0,d0
                move.b  routine(a0),d0
                move.w  Obj9A_Index(pc,d0.w),d1
                jmp     Obj9A_Index(pc,d1.w)
; ===========================================================================
; off_37944:
Obj9A_Index:    offsetTable
                offsetTableEntry.w Obj9A_Init           ; 0
                offsetTableEntry.w Obj9A_Main           ; 2
; ===========================================================================
; loc_37948:
Obj9A_Init:
                bsr.w   LoadSubObject
                move.w  #-$80,x_vel(a0)
                bsr.w   Turtloid_CreateRider
                lea     (Ani_obj9A).l,a1
                move.l  a1,objoff_2E(a0)
                bra.w   loc_37ABE
; ===========================================================================
; loc_37964:
Obj9A_Main:
                moveq   #0,d0
                move.b  routine_secondary(a0),d0
                move.w  off_3797A(pc,d0.w),d1
                jsr     off_3797A(pc,d1.w)
                bsr.w   Turtloid_MoveAsPlatform
                bra.w   Obj_DeleteBehindScreen
; ===========================================================================
off_3797A:      offsetTable
                offsetTableEntry.w loc_379A0            ; 0
                offsetTableEntry.w loc_379CA            ; 2
                offsetTableEntry.w loc_379EA            ; 4
                offsetTableEntry.w EnemiesTurtloid_Return_Variant2         ; 6
; ===========================================================================

Turtloid_MoveAsPlatform:
                move.w  x_pos(a0),-(sp)
                jsrto   JmpTo26_ObjectMove
                bsr.w   Object_ApplyTornadoSceneMotion
                move.w  #$18,d1
                move.w  #8,d2
                move.w  #$E,d3
                move.w  (sp)+,d4
                jmpto   JmpTo9_PlatformObject
; ===========================================================================

loc_379A0:
                bsr.w   Obj_GetOrientationToPlayer
                tst.w   d0
                bmi.w   EnemiesTurtloid_Return_Variant3
                cmpi.w  #$80,d2
                bhs.w   EnemiesTurtloid_Return_Variant3
                addq.b  #2,routine_secondary(a0)
                move.w  #0,x_vel(a0)
                move.b  #4,objoff_2A(a0)
                move.b  #1,mapping_frame(a0)
                rts
; ===========================================================================

loc_379CA:
                subq.b  #1,objoff_2A(a0)
                bpl.w   EnemiesTurtloid_Return_Variant3
                addq.b  #2,routine_secondary(a0)
                move.b  #8,objoff_2A(a0)
                movea.w objoff_2C(a0),a1                ; a1=object
                move.b  #3,mapping_frame(a1)
                bra.w   loc_37AF2
; ===========================================================================

loc_379EA:
                subq.b  #1,objoff_2A(a0)
                bpl.s   EnemiesTurtloid_Return
                addq.b  #2,routine_secondary(a0)
                move.w  #-$80,x_vel(a0)
                clr.b   mapping_frame(a0)
                movea.w objoff_2C(a0),a1                ; a1=object

EnemiesTurtloid_Return:
                rts
; ===========================================================================

EnemiesTurtloid_Return_Variant2:
                rts
; ===========================================================================
; ----------------------------------------------------------------------------
; Object 9B - Turtloid rider from Sky Chase Zone
; ----------------------------------------------------------------------------
; Sprite_37A06:
Obj9B:
                moveq   #0,d0
                move.b  routine(a0),d0
                move.w  Obj9B_Index(pc,d0.w),d1
                jmp     Obj9B_Index(pc,d1.w)
; ===========================================================================
; off_37A14:
Obj9B_Index:    offsetTable
                offsetTableEntry.w Obj9B_Init           ; 0
                offsetTableEntry.w Obj9B_Main           ; 2
; ===========================================================================
; BranchTo_LoadSubObject
Obj9B_Init:
                bra.w   LoadSubObject
; ===========================================================================
; loc_37A1C:
Obj9B_Main:
                movea.w objoff_2C(a0),a1                ; a1=object
                lea     word_37A2C(pc),a2
                bsr.w   Turtloid_ApplyRelativePosition
                bra.w   Obj_DeleteBehindScreen
; ===========================================================================
word_37A2C:
                dc.w    4                               ; 0
                dc.w    -$18                            ; 1
; ===========================================================================

Turtloid_ApplyRelativePosition:
                move.l  x_pos(a1),x_pos(a0)
                move.l  y_pos(a1),y_pos(a0)
                move.w  (a2)+,d0
                add.w   d0,x_pos(a0)
                move.w  (a2)+,d0
                add.w   d0,y_pos(a0)

EnemiesTurtloid_Return_Variant3:
                rts
; ===========================================================================

Turtloid_CreateRider:
                jsrto   JmpTo25_AllocateObjectAfterCurrent
                bne.s   EnemiesTurtloid_Return_Variant4
                _move.b #ObjID_TurtloidRider,id(a1)     ; load obj9B
                move.b  #2,mapping_frame(a1)
                move.b  #$18,subtype(a1)                ; <== Obj9B_SubObjData
                move.w  a0,objoff_2C(a1)
                move.w  a1,objoff_2C(a0)
                move.w  x_pos(a0),x_pos(a1)
                addq.w  #4,x_pos(a1)
                move.w  y_pos(a0),y_pos(a1)
                subi.w  #$18,y_pos(a1)

EnemiesTurtloid_Return_Variant4:
                rts
; ===========================================================================
; ----------------------------------------------------------------------------
; Object 9C - Balkiry's jet from Sky Chase Zone
; ----------------------------------------------------------------------------
; Sprite_37A82:
