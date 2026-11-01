Obj5D_Dripper:
                btst    #status.npc.no_balancing,status(a0)
                bne.w   JmpTo51_DeleteObject
                moveq   #0,d0
                move.b  routine_secondary(a0),d0
                move.w  Obj5D_Dripper_States(pc,d0.w),d1
                jmp     Obj5D_Dripper_States(pc,d1.w)
; ===========================================================================
Obj5D_Dripper_States:   offsetTable
                offsetTableEntry.w Obj5D_Dripper_0      ; 0
                offsetTableEntry.w Obj5D_Dripper_2      ; 2
                offsetTableEntry.w Obj5D_Dripper_4      ; 4
; ===========================================================================

Obj5D_Dripper_0:
                addq.b  #2,routine_secondary(a0)        ; => Obj5D_Dripper_2
                _move.b #ObjID_CPZBoss,id(a0)           ; load 0bj5D
                move.l  #Obj5D_MapUnc_2EADC,mappings(a0)
                move.w  #make_art_tile(ArtTile_ArtNem_CPZBoss,3,0),art_tile(a0)
                move.b  #1<<render_flags.level_fg,render_flags(a0)
                move.b  #$20,width_pixels(a0)
                move.b  #4,priority(a0)
                movea.l Obj5D_parent(a0),a1             ; a1=object
                move.w  x_pos(a1),x_pos(a0)
                move.w  y_pos(a1),y_pos(a0)
                move.b  #$F,Obj5D_timer(a0)
                move.b  #4,anim(a0)

Obj5D_Dripper_2:
                subq.b  #1,Obj5D_timer(a0)
                bne.s   +
                move.b  #5,anim(a0)
                move.b  #4,Obj5D_timer(a0)
                addq.b  #2,routine_secondary(a0)
                subi.w  #$24,y_pos(a0)
                subi_.w #2,x_pos(a0)
                rts
; ---------------------------------------------------------------------------
+
                movea.l Obj5D_parent(a0),a1             ; a1=object
                move.w  x_pos(a1),x_pos(a0)
                move.w  y_pos(a1),y_pos(a0)
                move.b  status(a1),status(a0)
                move.b  render_flags(a1),render_flags(a0)
                lea     (Ani_Obj5D_Dripper).l,a1
                jsr     (AnimateSprite).l
                jmp     (DisplaySprite).l
; ===========================================================================

Obj5D_Dripper_4:
                subq.b  #1,Obj5D_timer(a0)
                bne.s   +
                move.b  #0,routine_secondary(a0)
                movea.l Obj5D_parent(a0),a1             ; a1=object
                bset    #1,Obj5D_status2(a1)
                addq.b  #1,Obj5D_timer4(a0)
                cmpi.b  #$C,Obj5D_timer4(a0)
                bge.w   JmpTo51_DeleteObject
                rts
; ---------------------------------------------------------------------------
+
                movea.l Obj5D_parent(a0),a1             ; a1=object
                move.w  x_pos(a1),x_pos(a0)
                move.w  y_pos(a1),y_pos(a0)
                subi.w  #$24,y_pos(a0)
                subi_.w #2,x_pos(a0)
                btst    #render_flags.x_flip,render_flags(a0)
                beq.s   +
                addi_.w #4,x_pos(a0)
+
                lea     (Ani_Obj5D_Dripper).l,a1
                jsr     (AnimateSprite).l
                jmp     (DisplaySprite).l
; ===========================================================================

Obj5D_Container:
                moveq   #0,d0
                move.b  routine_secondary(a0),d0
                move.w  Obj5D_Container_States(pc,d0.w),d1
                jmp     Obj5D_Container_States(pc,d1.w)
; ===========================================================================
Obj5D_Container_States: offsetTable
                offsetTableEntry.w Obj5D_Container_Init  ; 0
                offsetTableEntry.w Obj5D_Container_Main  ; 2
                offsetTableEntry.w Obj5D_Container_Floor  ; 4
                offsetTableEntry.w Obj5D_Container_Extend  ; 6
                offsetTableEntry.w Obj5D_Container_Floor2  ; 8
                offsetTableEntry.w Obj5D_Container_FallOff  ; A
; ===========================================================================

Obj5D_Container_Init:
                movea.l Obj5D_parent(a0),a1             ; a1=object
                btst    #7,Obj5D_status2(a1)
                bne.s   +
                bset    #7,Obj5D_status2(a1)
                jsr     (AllocateObjectAfterCurrent).l
                bne.s   +
                _move.b #ObjID_CPZBoss,id(a1)           ; load obj5D
                move.l  a0,Obj5D_parent(a1)
                move.l  #Obj5D_MapUnc_2EADC,mappings(a1)
                move.w  #make_art_tile(ArtTile_ArtNem_CPZBoss,1,0),art_tile(a1)
                move.b  #1<<render_flags.level_fg,render_flags(a1)
                move.b  #$20,width_pixels(a1)
                move.b  #4,priority(a1)
                move.l  x_pos(a0),x_pos(a1)
                move.l  y_pos(a0),y_pos(a1)
                move.b  #$10,routine(a1)
                move.b  #4,routine_secondary(a1)        ; => Obj5D_Container_Floor
                move.b  #9,anim(a1)
+
                jsr     (AllocateObjectAfterCurrent).l
                bne.s   +
                _move.b #ObjID_CPZBoss,id(a1)           ; load obj5D
                move.l  a0,Obj5D_parent(a1)
                move.l  #Obj5D_MapUnc_2EADC,mappings(a1)
                move.w  #make_art_tile(ArtTile_ArtNem_CPZBoss,3,0),art_tile(a1)
                move.b  #1<<render_flags.level_fg,render_flags(a1)
                move.b  #$20,width_pixels(a1)
                move.b  #4,priority(a1)
                move.l  x_pos(a0),x_pos(a1)
                move.l  y_pos(a0),y_pos(a1)
                addi.b  #$10,routine(a1)
                move.b  #6,routine_secondary(a1)        ; => Obj5D_Container_Extend
+
                addq.b  #2,routine_secondary(a0)        ; => Obj5D_Container_Main

Obj5D_Container_Main:
                movea.l Obj5D_parent(a0),a1             ; a1=object
                move.w  x_pos(a1),x_pos(a0)
                move.w  y_pos(a1),y_pos(a0)
                subi.w  #$38,y_pos(a0)
                btst    #status.npc.no_balancing,status(a0)
                bne.s   loc_2E2E0
                btst    #2,Obj5D_status2(a1)
                beq.s   +
                bsr.w   CpzBoss_UpdatePipeRelease
                bsr.w   CpzBoss_CheckContainerRelease
                bra.s   loc_2E2AC
; ---------------------------------------------------------------------------
+
                btst    #5,Obj5D_status2(a1)
                beq.s   loc_2E2AC
                subq.w  #1,Obj5D_timer2(a0)
                bne.s   loc_2E2AC
                bclr    #5,Obj5D_status2(a1)
                bset    #3,Obj5D_status2(a1)
                bset    #4,Obj5D_status2(a1)

loc_2E2AC:
                movea.l Obj5D_parent(a0),a1             ; a1=object
                move.b  status(a1),status(a0)
                move.b  render_flags(a1),render_flags(a0)
                move.w  Obj5D_x_vel(a0),d0
                btst    #render_flags.x_flip,render_flags(a0)
                beq.s   +
                neg.w   d0
+
                add.w   d0,x_pos(a0)
                lea     (Ani_Obj5D_Dripper).l,a1
                jsr     (AnimateSprite).l
                jmp     (DisplaySprite).l
; ===========================================================================

loc_2E2E0:
                move.b  #$A,routine_secondary(a0)
                bra.s   loc_2E2AC
; ===========================================================================

Obj5D_Container_FallOff:
                move.l  d7,-(sp)
                move.b  #$1E,Obj5D_timer(a0)
                movea.l Obj5D_parent(a0),a1             ; a1=object
                move.w  x_pos(a1),x_pos(a0)
                move.w  y_pos(a1),y_pos(a0)
                subi.w  #$38,y_pos(a0)
                move.w  Obj5D_x_vel(a0),d0
                btst    #render_flags.x_flip,render_flags(a0)
                beq.s   +
                neg.w   d0
+
                add.w   d0,x_pos(a0)
                move.b  #$20,mapping_frame(a0)
                move.b  #$14,routine(a0)                ; => Obj5D_FallingParts
                jsr     (RandomNumber).l
                asr.w   #8,d0
                asr.w   #6,d0
                move.w  d0,x_vel(a0)
                move.w  #-$380,y_vel(a0)
                moveq   #0,d7
                move.w  Obj5D_x_vel(a0),d0
                addi.w  #$18,d0
                bge.s   loc_2E356
                addi.w  #$18,d0
                bge.s   loc_2E354
                addi.w  #$18,d0
                bge.s   loc_2E352
                addq.w  #1,d7

loc_2E352:
                addq.w  #1,d7

loc_2E354:
                addq.w  #1,d7

loc_2E356:
                subq.w  #1,d7
                bmi.w   loc_2E3E6

CpzBossContainer_CountedLoopD7:
                jsr     (AllocateObject).l
                bne.w   JmpTo51_DeleteObject
                _move.b #ObjID_CPZBoss,id(a1)           ; load obj5D
                move.l  #Obj5D_MapUnc_2EADC,mappings(a1)
                move.b  #$21,mapping_frame(a1)
                move.b  #$14,routine(a1)                ; => Obj5D_FallingParts
                move.w  #make_art_tile(ArtTile_ArtNem_CPZBoss,1,0),art_tile(a1)
                move.b  render_flags(a0),render_flags(a1)
                move.b  #$20,width_pixels(a1)
                move.b  #2,priority(a1)
                move.w  x_pos(a0),x_pos(a1)
                move.w  y_pos(a0),y_pos(a1)
                addi_.w #8,y_pos(a1)
                move.w  d7,d2
                add.w   d2,d2
                move.w  word_2E3EC(pc,d2.w),d3
                btst    #render_flags.x_flip,render_flags(a0)
                beq.s   +
                neg.w   d3
+
                add.w   d3,x_pos(a1)
                jsr     (RandomNumber).l
                asr.w   #8,d0
                asr.w   #6,d0
                move.w  d0,x_vel(a1)
                move.w  #-$380,y_vel(a1)
                swap    d0
                addi.b  #$1E,d0
                andi.w  #$7F,d0
                move.b  d0,Obj5D_timer(a1)
                dbf     d7,CpzBossContainer_CountedLoopD7

loc_2E3E6:
                move.l  (sp)+,d7
                jmpto   JmpTo34_DisplaySprite
; ===========================================================================
word_2E3EC:
                dc.w    $18
                dc.w    $30                             ; 1
                dc.w    $48                             ; 2
; ===========================================================================

CpzBoss_CheckContainerRelease:
                btst    #3,Obj5D_status2(a1)
                bne.w   CpzBossContainer_Return
                btst    #4,Obj5D_status2(a1)
                bne.w   CpzBossContainer_Return
                cmpi.w  #-$14,Obj5D_x_vel(a0)
                blt.s   +
                btst    #1,Obj5D_status(a1)
                beq.w   CpzBossContainer_Return
                bclr    #1,Obj5D_status(a1)
                bset    #2,Obj5D_status(a1)
                bra.s   loc_2E464
; ---------------------------------------------------------------------------
+
                cmpi.w  #-$40,Obj5D_x_vel(a0)
                bge.w   CpzBossContainer_Return
                move.w  (MainCharacter+x_pos).w,d1
                subi_.w #8,d1
                btst    #render_flags.x_flip,render_flags(a0)
                beq.s   +
                add.w   Obj5D_x_vel(a0),d1
                sub.w   x_pos(a0),d1
                bgt.w   CpzBossContainer_Return
                cmpi.w  #-$18,d1
                bge.s   loc_2E464
                rts
; ---------------------------------------------------------------------------
+
                sub.w   Obj5D_x_vel(a0),d1
                sub.w   x_pos(a0),d1
                blt.s   CpzBossContainer_Return
                cmpi.w  #$18,d1
                bgt.s   CpzBossContainer_Return

loc_2E464:
                bset    #5,Obj5D_status2(a1)
                bclr    #2,Obj5D_status2(a1)
                move.w  #$12,Obj5D_timer2(a0)
                jsr     (AllocateObjectAfterCurrent).l
                bne.s   CpzBossContainer_Return
                _move.b #ObjID_CPZBoss,id(a1)           ; load obj5D
                move.l  a0,Obj5D_parent(a1)
                move.b  #$10,routine(a1)                ; => Obj5D_Container
                move.b  #8,routine_secondary(a1)        ; => Obj5D_Container_Floor2
                move.l  #Obj5D_MapUnc_2EADC,mappings(a1)
                move.w  #make_art_tile(ArtTile_ArtNem_CPZBoss,1,0),art_tile(a1)
                move.b  #1<<render_flags.level_fg,render_flags(a1)
                move.b  #$20,width_pixels(a1)
                move.b  #5,priority(a1)
                move.l  x_pos(a0),x_pos(a1)
                move.l  y_pos(a0),y_pos(a1)
                move.b  #$B,anim(a1)
                move.w  #$24,Obj5D_timer2(a1)

CpzBossContainer_Return:
                rts
; ===========================================================================

CpzBoss_UpdatePipeRelease:
                moveq   #1,d0
                btst    #4,Obj5D_status2(a1)
                bne.s   +
                moveq   #-1,d0
+
                cmpi.w  #-$10,Obj5D_x_vel(a0)
                bne.s   loc_2E552
                bclr    #4,Obj5D_status2(a1)
                beq.s   loc_2E552
                bclr    #2,Obj5D_status2(a1)
                clr.b   routine_secondary(a0)
                movea.l a1,a2
                jsr     (AllocateObjectAfterCurrent).l
                bne.s   CpzBossContainer_Return_Variant2
                _move.b #ObjID_CPZBoss,id(a1)           ; load obj5D
                move.l  Obj5D_parent(a0),Obj5D_parent(a1)
                move.l  #Obj5D_MapUnc_2EADC,mappings(a1)
                move.w  #make_art_tile(ArtTile_ArtNem_CPZBoss,1,0),art_tile(a1)
                move.b  #1<<render_flags.level_fg,render_flags(a1)
                move.b  #$20,width_pixels(a1)
                move.b  #4,priority(a1)
                move.l  x_pos(a0),x_pos(a1)
                move.l  y_pos(a0),y_pos(a1)
                move.b  #4,routine(a1)                  ; => Obj5D_Pipe
                move.b  #0,routine_secondary(a0)
                bra.s   CpzBossContainer_Return_Variant2
; ===========================================================================
; Some mysterious dead code
                move.b  #$A,routine(a1)                 ; => Obj5D_Dripper
                move.l  Obj5D_parent(a0),Obj5D_parent(a1)

CpzBossContainer_Return_Variant2:
                rts
; ===========================================================================

loc_2E552:
                move.w  Obj5D_x_vel(a0),d1
                cmpi.w  #-$28,d1
                bge.s   loc_2E59C
                cmpi.w  #-$40,d1
                bge.s   loc_2E594
                move.b  #8,anim(a0)
                cmpi.w  #-$58,d1
                blt.s   loc_2E57E
                bgt.s   loc_2E578
                btst    #4,Obj5D_status2(a1)
                beq.s   CpzBossContainer_Return_Variant3

loc_2E578:
                add.w   d0,Obj5D_x_vel(a0)

CpzBossContainer_Return_Variant3:
                rts
; ===========================================================================

loc_2E57E:
                move.w  #-$58,Obj5D_x_vel(a0)
                btst    #render_flags.x_flip,render_flags(a0)
                beq.s   loc_2E578
                move.w  #$58,Obj5D_x_vel(a0)
                bra.s   loc_2E578
; ===========================================================================

loc_2E594:
                move.b  #7,anim(a0)
                bra.s   loc_2E578
; ===========================================================================

loc_2E59C:
                move.b  #6,anim(a0)
                bra.s   loc_2E578
; ===========================================================================

Obj5D_Container_Extend:
                btst    #status.npc.no_balancing,status(a0)
                bne.w   JmpTo51_DeleteObject
                movea.l Obj5D_parent(a0),a1             ; a1=object
                move.l  Obj5D_parent(a1),d0
                beq.w   JmpTo51_DeleteObject
                movea.l d0,a1                           ; a1=object
                bclr    #3,Obj5D_status2(a1)
                beq.s   +
                move.b  #$C,routine(a0)
                move.b  #0,routine_secondary(a0)
                move.b  #$87,collision_flags(a0)
                bra.s   Obj5D_Container_Floor_End
; ----------------------------------------------------------------------------
+
                bclr    #1,Obj5D_status2(a1)
                bne.s   +
                tst.b   anim(a0)
                bne.s   Obj5D_Container_Floor_End
                rts
; ---------------------------------------------------------------------------
+
                tst.b   anim(a0)
                bne.s   +
                move.b  #$B,anim(a0)
+
                addi_.b #1,anim(a0)
                cmpi.b  #$17,anim(a0)
                blt.s   Obj5D_Container_Floor_End
                bclr    #0,Obj5D_status2(a1)
                bset    #2,Obj5D_status2(a1)
                bra.s   Obj5D_Container_Floor_End
; ===========================================================================

Obj5D_Container_Floor:
                btst    #status.npc.no_balancing,status(a0)
                bne.w   JmpTo51_DeleteObject
                movea.l Obj5D_parent(a0),a1             ; a1=object
                movea.l Obj5D_parent(a1),a1
                btst    #5,Obj5D_status2(a1)
                beq.s   Obj5D_Container_Floor_End
                cmpi.b  #9,anim(a0)
                bne.s   Obj5D_Container_Floor_End
                move.b  #$A,anim(a0)

Obj5D_Container_Floor_End:
                movea.l Obj5D_parent(a0),a1             ; a1=object
                move.w  x_pos(a1),x_pos(a0)
                move.w  y_pos(a1),y_pos(a0)
                move.b  render_flags(a1),render_flags(a0)
                move.b  status(a1),status(a0)
                lea     (Ani_Obj5D_Dripper).l,a1
                jsr     (AnimateSprite).l
                jmp     (DisplaySprite).l
; ===========================================================================

Obj5D_Container_Floor2:
                btst    #status.npc.no_balancing,status(a0)
                bne.w   JmpTo51_DeleteObject
                subq.w  #1,Obj5D_timer2(a0)
                beq.w   JmpTo51_DeleteObject
                bra.s   Obj5D_Container_Floor_End
; ===========================================================================
