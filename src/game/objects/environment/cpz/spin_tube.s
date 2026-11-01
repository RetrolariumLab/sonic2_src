Obj1E:
                moveq   #0,d0
                move.b  routine(a0),d0
                move.w  Obj1E_Index(pc,d0.w),d1
                jsr     Obj1E_Index(pc,d1.w)
                move.b  objoff_2C(a0),d0
                add.b   objoff_36(a0),d0
                beq.w   JmpTo_MarkObjGone3
                rts

; ===========================================================================
; JmpTbl_225B8: Obj1E_States:
Obj1E_Index:    offsetTable
                offsetTableEntry.w Obj1E_Init           ; 0
                offsetTableEntry.w Obj1E_Main           ; 2
; ===========================================================================
word_225BC:
                dc.w    $A0                             ; 0
                dc.w    $100                            ; 2
                dc.w    $120                            ; 4
; ===========================================================================
; loc_225C2: LoadSubtype_1E:
Obj1E_Init:
                addq.b  #2,routine(a0)
                move.b  subtype(a0),d0
                add.w   d0,d0
                andi.w  #6,d0
                move.w  word_225BC(pc,d0.w),objoff_2A(a0)
; loc_225D6:
Obj1E_Main:
                lea     (MainCharacter).w,a1            ; a1=character
                lea     objoff_2C(a0),a4
                bsr.s   +
                lea     (Sidekick).w,a1                 ; a1=character
                lea     objoff_36(a0),a4
+
                moveq   #0,d0
                move.b  (a4),d0
                move.w  Obj1E_Modes(pc,d0.w),d0
                jmp     Obj1E_Modes(pc,d0.w)
; ===========================================================================
; off_225F4:
Obj1E_Modes:    offsetTable
                offsetTableEntry.w loc_225FC            ; 0
                offsetTableEntry.w loc_2271A            ; 2
                offsetTableEntry.w loc_227FE            ; 4
                offsetTableEntry.w loc_2286A            ; 6
; ===========================================================================

loc_225FC:
                tst.w   (Debug_placement_mode).w
                bne.w   CpzSpinTube_Return
                move.w  objoff_2A(a0),d2
                move.w  x_pos(a1),d0
                sub.w   x_pos(a0),d0
                cmp.w   d2,d0
                bhs.w   CpzSpinTube_Return
                move.w  y_pos(a1),d1
                sub.w   y_pos(a0),d1
                cmpi.w  #$80,d1
                bhs.w   CpzSpinTube_Return
                cmpi.b  #$20,anim(a1)
                beq.w   CpzSpinTube_Return

                moveq   #0,d3
                cmpi.w  #$A0,d2
                beq.s   +
                moveq   #8,d3
                cmpi.w  #$120,d2
                beq.s   +
                moveq   #4,d3
                neg.w   d0
                addi.w  #$100,d0
+
                cmpi.w  #$80,d0
                blo.s   loc_2267E
                moveq   #0,d2
                move.b  subtype(a0),d0
                lsr.w   #2,d0
                andi.w  #$F,d0
                move.b  byte_2266E(pc,d0.w),d2
                cmpi.b  #2,d2
                bne.s   loc_22688
                move.b  (Timer_second).w,d2
                andi.b  #1,d2
                bra.s   loc_22688
; ===========================================================================
byte_2266E:
                dc.b    2
                dc.b    2                               ; 1
                dc.b    2                               ; 2
                dc.b    2                               ; 3
                dc.b    2                               ; 4
                dc.b    2                               ; 5
                dc.b    2                               ; 6
                dc.b    2                               ; 7
                dc.b    2                               ; 8
                dc.b    2                               ; 9
                dc.b    0                               ; 10
                dc.b    2                               ; 11
                dc.b    0                               ; 12
                dc.b    1                               ; 13
                dc.b    2                               ; 14
                dc.b    1                               ; 15
                even
; ===========================================================================

loc_2267E:
                moveq   #2,d2
                cmpi.w  #$40,d1
                bhs.s   loc_22688
                moveq   #3,d2

loc_22688:
                move.b  d2,1(a4)
                add.w   d3,d2
                add.w   d2,d2
                andi.w  #$1E,d2
                lea     CpzSpinTube_TubePaths(pc),a2
                adda.w  (a2,d2.w),a2
                move.w  (a2)+,4(a4)
                subq.w  #4,4(a4)
                move.w  (a2)+,d4
                add.w   x_pos(a0),d4
                move.w  d4,x_pos(a1)
                move.w  (a2)+,d5
                add.w   y_pos(a0),d5
                move.w  d5,y_pos(a1)
                move.l  a2,6(a4)
                move.w  (a2)+,d4
                add.w   x_pos(a0),d4
                move.w  (a2)+,d5
                add.w   y_pos(a0),d5
                addq.b  #2,(a4)
                move.b  #$81,obj_control(a1)
                move.b  #AniIDSonAni_Roll,anim(a1)
                move.w  #$800,inertia(a1)
                move.w  #0,x_vel(a1)
                move.w  #0,y_vel(a1)
                bclr    #status.npc.p1_pushing,status(a0)
                bclr    #status.player.pushing,status(a1)
                bset    #status.player.in_air,status(a1)
                move.b  #0,jumping(a1)
                bclr    #high_priority_bit,art_tile(a1)
                move.w  #$800,d2
                bsr.w   CpzTube_CalculateSegmentVelocity
                move.w  #SndID_Roll,d0
                jsr     (PlaySound).l

CpzSpinTube_Return:
                rts
; ===========================================================================

loc_2271A:
                subq.b  #1,2(a4)
                bpl.s   Obj1E_MoveCharacter
                movea.l 6(a4),a2
                move.w  (a2)+,d4
                add.w   x_pos(a0),d4
                move.w  d4,x_pos(a1)
                move.w  (a2)+,d5
                add.w   y_pos(a0),d5
                move.w  d5,y_pos(a1)
                tst.b   1(a4)
                bpl.s   +
                subq.w  #8,a2
+
                move.l  a2,6(a4)
                subq.w  #4,4(a4)
                beq.s   loc_22784
                move.w  (a2)+,d4
                add.w   x_pos(a0),d4
                move.w  (a2)+,d5
                add.w   y_pos(a0),d5
                move.w  #$800,d2
                bra.w   CpzTube_CalculateSegmentVelocity
; ===========================================================================
; update the position of Sonic/Tails in the CPZ tube
; loc_2275E:
Obj1E_MoveCharacter:
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

loc_22784:
                cmpi.b  #4,1(a4)
                bhs.s   loc_227A6
                move.b  subtype(a0),d0
                andi.w  #$FC,d0
                add.b   1(a4),d0
                move.b  #4,1(a4)
                move.b  byte_227BE(pc,d0.w),d0
                bne.w   loc_22892

loc_227A6:
                andi.w  #$7FF,y_pos(a1)
                move.b  #6,(a4)
                clr.b   obj_control(a1)
                move.w  #SndID_SpindashRelease,d0
                jmp     (PlaySound).l
; ===========================================================================
byte_227BE:
                dc.b    2,  1,  0,  0
                dc.b    -1,  3,  0,  0
                dc.b    4, -2,  0,  0
                dc.b    -3, -4,  0,  0
                dc.b    -5, -5,  0,  0
                dc.b    7,  6,  0,  0
                dc.b    -7, -6,  0,  0
                dc.b    8,  9,  0,  0
                dc.b    -8, -9,  0,  0
                dc.b    11, 10,  0,  0
                dc.b    12,  0,  0,  0
                dc.b    -11,-10,  0,  0
                dc.b    -12,  0,  0,  0
                dc.b    0, 13,  0,  0
                dc.b    -13, 14,  0,  0
                dc.b    0,-14,  0,  0
; ===========================================================================

loc_227FE:
                subq.b  #1,2(a4)
                bpl.s   Obj1E_MoveCharacter_2
                movea.l 6(a4),a2
                move.w  (a2)+,d4
                move.w  d4,x_pos(a1)
                move.w  (a2)+,d5
                move.w  d5,y_pos(a1)
                tst.b   1(a4)
                bpl.s   loc_2281C
                subq.w  #8,a2

loc_2281C:
                move.l  a2,6(a4)
                subq.w  #4,4(a4)
                beq.s   loc_22858
                move.w  (a2)+,d4
                move.w  (a2)+,d5
                move.w  #$800,d2
                bra.w   CpzTube_CalculateSegmentVelocity
; ===========================================================================
; update the position of Sonic/Tails in the CPZ tube
; loc_22832:
Obj1E_MoveCharacter_2:
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

loc_22858:
                andi.w  #$7FF,y_pos(a1)
                clr.b   (a4)
                move.w  #SndID_SpindashRelease,d0
                jmp     (PlaySound).l
; ===========================================================================

loc_2286A:
                move.w  objoff_2A(a0),d2
                move.w  x_pos(a1),d0
                sub.w   x_pos(a0),d0
                cmp.w   d2,d0
                bhs.w   loc_2288E
                move.w  y_pos(a1),d1
                sub.w   y_pos(a0),d1
                cmpi.w  #$80,d1
                bhs.w   loc_2288E
                rts
; ===========================================================================

loc_2288E:
                clr.b   (a4)
                rts
; ===========================================================================

loc_22892:
                bpl.s   loc_228C4
                neg.b   d0
                move.b  #-4,1(a4)
                add.w   d0,d0
                lea     (CpzSpinTube_TubePaths_Variant2).l,a2
                adda.w  (a2,d0.w),a2
                move.w  (a2)+,d0
                subq.w  #4,d0
                move.w  d0,4(a4)
                lea     (a2,d0.w),a2
                move.w  (a2)+,d4
                move.w  d4,x_pos(a1)
                move.w  (a2)+,d5
                move.w  d5,y_pos(a1)
                subq.w  #8,a2
                bra.s   loc_228E4
; ===========================================================================

loc_228C4:
                add.w   d0,d0
                lea     (CpzSpinTube_TubePaths_Variant2).l,a2
                adda.w  (a2,d0.w),a2
                move.w  (a2)+,4(a4)
                subq.w  #4,4(a4)
                move.w  (a2)+,d4
                move.w  d4,x_pos(a1)
                move.w  (a2)+,d5
                move.w  d5,y_pos(a1)

loc_228E4:
                move.l  a2,6(a4)
                move.w  (a2)+,d4
                move.w  (a2)+,d5
                move.w  #$800,d2
                bsr.w   CpzTube_CalculateSegmentVelocity
                move.w  #SndID_Roll,d0
                jsr     (PlaySound).l
                addq.b  #2,(a4)
                rts
; ===========================================================================

CpzTube_CalculateSegmentVelocity:
                moveq   #0,d0
                move.w  d2,d3
                move.w  d4,d0
                sub.w   x_pos(a1),d0
                bge.s   +
                neg.w   d0
                neg.w   d2
+
                moveq   #0,d1
                move.w  d5,d1
                sub.w   y_pos(a1),d1
                bge.s   +
                neg.w   d1
                neg.w   d3
+
                cmp.w   d0,d1
                blo.s   loc_22952
                moveq   #0,d1
                move.w  d5,d1
                sub.w   y_pos(a1),d1
                swap    d1
                divs.w  d3,d1
                moveq   #0,d0
                move.w  d4,d0
                sub.w   x_pos(a1),d0
                beq.s   +
                swap    d0
                divs.w  d1,d0
+
                move.w  d0,x_vel(a1)
                move.w  d3,y_vel(a1)
                abs.w   d1
                move.w  d1,2(a4)
                rts
; ===========================================================================

loc_22952:
                moveq   #0,d0
                move.w  d4,d0
                sub.w   x_pos(a1),d0
                swap    d0
                divs.w  d2,d0
                moveq   #0,d1
                move.w  d5,d1
                sub.w   y_pos(a1),d1
                beq.s   +
                swap    d1
                divs.w  d0,d1
+
                move.w  d1,y_vel(a1)
                move.w  d2,x_vel(a1)
                abs.w   d0
                move.w  d0,2(a4)
                rts
; ===========================================================================
obj1E67Size     macro   {INTLABEL}
__LABEL__       label   *
                    dc.w    __LABEL___End-__LABEL__-2
                endm
; ---------------------------------------------------------------------------
; spin tube data - entry/exit
; ---------------------------------------------------------------------------
; CpzSpinTube_TubePaths:
CpzSpinTube_TubePaths:  offsetTable
                offsetTableEntry.w CpzSpinTube_TubePaths_Path0
                offsetTableEntry.w CpzSpinTube_TubePaths_Path1
                offsetTableEntry.w CpzSpinTube_TubePaths_Path2
                offsetTableEntry.w CpzSpinTube_TubePaths_Path3
                offsetTableEntry.w CpzSpinTube_TubePaths_Path4
                offsetTableEntry.w CpzSpinTube_TubePaths_Path5
                offsetTableEntry.w CpzSpinTube_TubePaths_Path6
                offsetTableEntry.w CpzSpinTube_TubePaths_Path7
                offsetTableEntry.w CpzSpinTube_TubePaths_Path8
                offsetTableEntry.w CpzSpinTube_TubePaths_Path9
                offsetTableEntry.w CpzSpinTube_TubePaths_Path10
                offsetTableEntry.w CpzSpinTube_TubePaths_Path11

CpzSpinTube_TubePaths_Path0:    obj1E67Size
                dc.w    $90, $10
                dc.w    $90, $70
                dc.w    $40, $70
                dc.w    $35, $6F
                dc.w    $28, $6A
                dc.w    $1E, $62
                dc.w    $15, $58
                dc.w    $11, $4A
                dc.w    $10, $40
                dc.w    $11, $35
                dc.w    $15, $27
                dc.w    $1E, $1E
                dc.w    $28, $15
                dc.w    $35, $11
                dc.w    $40, $10
                dc.w    $50, $10
                dc.w    $5E, $12
                dc.w    $68, $18
                dc.w    $6D, $24
                dc.w    $70, $30
                dc.w    $6D, $3D
                dc.w    $68, $48
                dc.w    $5E, $4E
                dc.w    $50, $50
                dc.w    $30, $50
                dc.w    $22, $52
                dc.w    $17, $5A
                dc.w    $11, $63
                dc.w    $10, $70
CpzSpinTube_TubePaths_Path0_End

CpzSpinTube_TubePaths_Path1:    obj1E67Size
                dc.w    $90, $10
                dc.w    $90, $70
                dc.w    $40, $70
                dc.w    $2E, $6E
                dc.w    $1D, $62
                dc.w    $13, $53
                dc.w    $10, $40
                dc.w    $13, $2D
                dc.w    $1D, $1E
                dc.w    $2E, $13
                dc.w    $40, $10
                dc.w    $58, $10
                dc.w    $64, $14
                dc.w    $6C, $1A
                dc.w    $70, $28
                dc.w    $6C, $36
                dc.w    $64, $3C
                dc.w    $58, $40
                dc.w    $4B, $3D
                dc.w    $40, $38
                dc.w    $36, $32
                dc.w    $28, $30
                dc.w    $10, $30
CpzSpinTube_TubePaths_Path1_End

CpzSpinTube_TubePaths_Path2:    obj1E67Size
                dc.w    $10, $70
                dc.w    $11, $63
                dc.w    $17, $5A
                dc.w    $22, $52
                dc.w    $30, $50
                dc.w    $50, $50
                dc.w    $5E, $4E
                dc.w    $68, $48
                dc.w    $6D, $3D
                dc.w    $70, $30
                dc.w    $6D, $24
                dc.w    $68, $18
                dc.w    $5E, $12
                dc.w    $50, $10
                dc.w    $40, $10
                dc.w    $35, $11
                dc.w    $28, $15
                dc.w    $1E, $1E
                dc.w    $15, $27
                dc.w    $11, $35
                dc.w    $10, $40
                dc.w    $11, $4A
                dc.w    $15, $58
                dc.w    $1E, $62
                dc.w    $28, $6A
                dc.w    $35, $6F
                dc.w    $40, $70
                dc.w    $90, $70
                dc.w    $90, $10
CpzSpinTube_TubePaths_Path2_End

CpzSpinTube_TubePaths_Path3:    obj1E67Size
                dc.w    $10, $30
                dc.w    $28, $30
                dc.w    $36, $32
                dc.w    $40, $38
                dc.w    $4B, $3D
                dc.w    $58, $40
                dc.w    $64, $3C
                dc.w    $6C, $36
                dc.w    $70, $28
                dc.w    $6C, $1A
                dc.w    $64, $14
                dc.w    $58, $10
                dc.w    $40, $10
                dc.w    $2E, $13
                dc.w    $1D, $1E
                dc.w    $13, $2D
                dc.w    $10, $40
                dc.w    $13, $53
                dc.w    $1D, $62
                dc.w    $2E, $6E
                dc.w    $40, $70
                dc.w    $90, $70
                dc.w    $90, $10
CpzSpinTube_TubePaths_Path3_End

CpzSpinTube_TubePaths_Path4:    obj1E67Size
                dc.w    $10, $10
                dc.w    $10, $70
                dc.w    $C0, $70
                dc.w    $CA, $6F
                dc.w    $D4, $6C
                dc.w    $DB, $68
                dc.w    $E3, $62
                dc.w    $E8, $5A
                dc.w    $ED, $52
                dc.w    $EF, $48
                dc.w    $F0, $40
                dc.w    $EF, $36
                dc.w    $ED, $2E
                dc.w    $E8, $26
                dc.w    $E3, $1E
                dc.w    $DB, $17
                dc.w    $D4, $14
                dc.w    $CA, $12
                dc.w    $C0, $10
                dc.w    $B7, $11
                dc.w    $AF, $12
                dc.w    $A6, $17
                dc.w    $9E, $1E
                dc.w    $97, $26
                dc.w    $93, $2E
                dc.w    $91, $36
                dc.w    $90, $40
                dc.w    $90, $70
CpzSpinTube_TubePaths_Path4_End

CpzSpinTube_TubePaths_Path5:    obj1E67Size
                dc.w    $10, $10
                dc.w    $10, $70
                dc.w    $C0, $70
                dc.w    $D2, $6E
                dc.w    $E3, $62
                dc.w    $ED, $53
                dc.w    $F0, $40
                dc.w    $ED, $2D
                dc.w    $E3, $1E
                dc.w    $D2, $13
                dc.w    $C0, $10
                dc.w    $A8, $10
                dc.w    $9C, $14
                dc.w    $94, $1A
                dc.w    $90, $28
                dc.w    $94, $36
                dc.w    $9C, $3C
                dc.w    $A8, $40
                dc.w    $B5, $3D
                dc.w    $C0, $38
                dc.w    $CA, $32
                dc.w    $D8, $30
                dc.w    $F0, $30
CpzSpinTube_TubePaths_Path5_End

CpzSpinTube_TubePaths_Path6:    obj1E67Size
                dc.w    $90, $70
                dc.w    $90, $40
                dc.w    $91, $36
                dc.w    $93, $2E
                dc.w    $97, $26
                dc.w    $9E, $1E
                dc.w    $A6, $17
                dc.w    $AF, $12
                dc.w    $B7, $11
                dc.w    $C0, $10
                dc.w    $CA, $12
                dc.w    $D4, $14
                dc.w    $DB, $17
                dc.w    $E3, $1E
                dc.w    $E8, $26
                dc.w    $ED, $2E
                dc.w    $EF, $36
                dc.w    $F0, $40
                dc.w    $EF, $48
                dc.w    $ED, $52
                dc.w    $E8, $5A
                dc.w    $E3, $62
                dc.w    $DB, $68
                dc.w    $D4, $6C
                dc.w    $CA, $6F
                dc.w    $C0, $70
                dc.w    $10, $70
                dc.w    $10, $10
CpzSpinTube_TubePaths_Path6_End

CpzSpinTube_TubePaths_Path7:    obj1E67Size
                dc.w    $F0, $30
                dc.w    $D8, $30
                dc.w    $CA, $32
                dc.w    $C0, $38
                dc.w    $B5, $3D
                dc.w    $A8, $40
                dc.w    $9C, $3C
                dc.w    $94, $36
                dc.w    $90, $28
                dc.w    $94, $1A
                dc.w    $9C, $14
                dc.w    $A8, $10
                dc.w    $C0, $10
                dc.w    $D2, $13
                dc.w    $E3, $1E
                dc.w    $ED, $2D
                dc.w    $F0, $40
                dc.w    $ED, $53
                dc.w    $E3, $62
                dc.w    $D2, $6E
                dc.w    $C0, $70
                dc.w    $10, $70
                dc.w    $10, $10
CpzSpinTube_TubePaths_Path7_End

CpzSpinTube_TubePaths_Path8:    obj1E67Size
                dc.w    $110, $10
                dc.w    $110, $70
                dc.w    $40, $70
                dc.w    $35, $6F
                dc.w    $28, $6A
                dc.w    $1E, $62
                dc.w    $15, $58
                dc.w    $11, $4A
                dc.w    $10, $40
                dc.w    $11, $35
                dc.w    $15, $27
                dc.w    $1E, $1E
                dc.w    $28, $15
                dc.w    $35, $11
                dc.w    $40, $10
                dc.w    $50, $10
                dc.w    $5E, $12
                dc.w    $68, $18
                dc.w    $6D, $24
                dc.w    $70, $30
                dc.w    $6D, $3D
                dc.w    $68, $48
                dc.w    $5E, $4E
                dc.w    $50, $50
                dc.w    $30, $50
                dc.w    $22, $52
                dc.w    $17, $5A
                dc.w    $11, $63
                dc.w    $10, $70
CpzSpinTube_TubePaths_Path8_End

CpzSpinTube_TubePaths_Path9:    obj1E67Size
                dc.w    $110, $10
                dc.w    $110, $70
                dc.w    $40, $70
                dc.w    $2E, $6E
                dc.w    $1D, $62
                dc.w    $13, $53
                dc.w    $10, $40
                dc.w    $13, $2D
                dc.w    $1D, $1E
                dc.w    $2E, $13
                dc.w    $40, $10
                dc.w    $58, $10
                dc.w    $64, $14
                dc.w    $6C, $1A
                dc.w    $70, $28
                dc.w    $6C, $36
                dc.w    $64, $3C
                dc.w    $58, $40
                dc.w    $4B, $3D
                dc.w    $40, $38
                dc.w    $36, $32
                dc.w    $28, $30
                dc.w    $10, $30
CpzSpinTube_TubePaths_Path9_End

CpzSpinTube_TubePaths_Path10:   obj1E67Size
                dc.w    $10, $70
                dc.w    $11, $63
                dc.w    $17, $5A
                dc.w    $22, $52
                dc.w    $30, $50
                dc.w    $50, $50
                dc.w    $5E, $4E
                dc.w    $68, $48
                dc.w    $6D, $3D
                dc.w    $70, $30
                dc.w    $6D, $24
                dc.w    $68, $18
                dc.w    $5E, $12
                dc.w    $50, $10
                dc.w    $40, $10
                dc.w    $35, $11
                dc.w    $28, $15
                dc.w    $1E, $1E
                dc.w    $15, $27
                dc.w    $11, $35
                dc.w    $10, $40
                dc.w    $11, $4A
                dc.w    $15, $58
                dc.w    $1E, $62
                dc.w    $28, $6A
                dc.w    $35, $6F
                dc.w    $40, $70
                dc.w    $110, $70
                dc.w    $110, $10
CpzSpinTube_TubePaths_Path10_End

CpzSpinTube_TubePaths_Path11:   obj1E67Size
                dc.w    $10, $30
                dc.w    $28, $30
                dc.w    $36, $32
                dc.w    $40, $38
                dc.w    $4B, $3D
                dc.w    $58, $40
                dc.w    $64, $3C
                dc.w    $6C, $36
                dc.w    $70, $28
                dc.w    $6C, $1A
                dc.w    $64, $14
                dc.w    $58, $10
                dc.w    $40, $10
                dc.w    $2E, $13
                dc.w    $1D, $1E
                dc.w    $13, $2D
                dc.w    $10, $40
                dc.w    $13, $53
                dc.w    $1D, $62
                dc.w    $2E, $6E
                dc.w    $40, $70
                dc.w    $110, $70
                dc.w    $110, $10
CpzSpinTube_TubePaths_Path11_End
; ---------------------------------------------------------------------------
; spin tube data - main tube
; ---------------------------------------------------------------------------
; CpzSpinTube_TubePaths_Variant2:
CpzSpinTube_TubePaths_Variant2: offsetTable
                offsetTableEntry.w CpzSpinTube_TubePaths_Path0_Variant2
                offsetTableEntry.w CpzSpinTube_TubePaths_Path0_Variant2
                offsetTableEntry.w CpzSpinTube_TubePaths_Path2_Variant2
                offsetTableEntry.w CpzSpinTube_TubePaths_Path3_Variant2
                offsetTableEntry.w CpzSpinTube_TubePaths_Path4_Variant2
                offsetTableEntry.w CpzSpinTube_TubePaths_Path5_Variant2
                offsetTableEntry.w CpzSpinTube_TubePaths_Path6_Variant2
                offsetTableEntry.w CpzSpinTube_TubePaths_Path7_Variant2
                offsetTableEntry.w CpzSpinTube_TubePaths_Path8_Variant2
                offsetTableEntry.w CpzSpinTube_TubePaths_Path9_Variant2
                offsetTableEntry.w CpzSpinTube_TubePaths_Path10_Variant2
                offsetTableEntry.w CpzSpinTube_TubePaths_Path11_Variant2
                offsetTableEntry.w CpzSpinTube_TubePaths_Path12
                offsetTableEntry.w CpzSpinTube_TubePaths_Path13
                offsetTableEntry.w CpzSpinTube_TubePaths_Path14

CpzSpinTube_TubePaths_Path0_Variant2:   obj1E67Size
                dc.w    $790, $3B0
                dc.w    $710, $3B0
                dc.w    $710, $6B0
                dc.w    $A90, $6B0
                dc.w    $A90, $670
CpzSpinTube_TubePaths_Path0_Variant2_End

CpzSpinTube_TubePaths_Path2_Variant2:   obj1E67Size
                dc.w    $790, $3F0
                dc.w    $790, $4B0
                dc.w    $A00, $4B0
                dc.w    $C10, $4B0
                dc.w    $C10, $330
                dc.w    $D90, $330
                dc.w    $D90, $1B0
                dc.w    $F10, $1B0
                dc.w    $F10, $2B0
                dc.w    $F90, $2B0
CpzSpinTube_TubePaths_Path2_Variant2_End

CpzSpinTube_TubePaths_Path3_Variant2:   obj1E67Size
                dc.w    $AF0, $630
                dc.w    $E90, $630
                dc.w    $E90, $6B0
                dc.w    $F90, $6B0
                dc.w    $F90, $670
CpzSpinTube_TubePaths_Path3_Variant2_End

CpzSpinTube_TubePaths_Path4_Variant2:   obj1E67Size
                dc.w    $F90, $2F0
                dc.w    $F90, $4B0
                dc.w    $F10, $4B0
                dc.w    $F10, $630
                dc.w    $F90, $630
CpzSpinTube_TubePaths_Path4_Variant2_End

CpzSpinTube_TubePaths_Path5_Variant2:   obj1E67Size
                dc.w    $1410, $530
                dc.w    $1190, $530
                dc.w    $1190, $6B0
                dc.w    $1410, $6B0
                dc.w    $1410, $570
CpzSpinTube_TubePaths_Path5_Variant2_End

CpzSpinTube_TubePaths_Path6_Variant2:   obj1E67Size
                dc.w    $1AF0, $530
                dc.w    $1B90, $530
                dc.w    $1B90, $330
                dc.w    $1E10, $330
CpzSpinTube_TubePaths_Path6_Variant2_End

CpzSpinTube_TubePaths_Path7_Variant2:   obj1E67Size
                dc.w    $1A90, $570
                dc.w    $1A90, $5B0
                dc.w    $1C10, $5B0
                dc.w    $1C10, $430
                dc.w    $1E10, $430
                dc.w    $1E10, $370
CpzSpinTube_TubePaths_Path7_Variant2_End

CpzSpinTube_TubePaths_Path8_Variant2:   obj1E67Size
                dc.w    $2490, $370
                dc.w    $2490, $3D0
                dc.w    $2390, $3D0
                dc.w    $2390, $5D0
                dc.w    $2510, $5D0
                dc.w    $2510, $570
CpzSpinTube_TubePaths_Path8_Variant2_End

CpzSpinTube_TubePaths_Path9_Variant2:   obj1E67Size
                dc.w    $24F0, $330
                dc.w    $2590, $330
                dc.w    $2590, $530
                dc.w    $2570, $530
CpzSpinTube_TubePaths_Path9_Variant2_End

CpzSpinTube_TubePaths_Path10_Variant2:  obj1E67Size
                dc.w    $310, $330
                dc.w    $290, $330
                dc.w    $290, $230
                dc.w    $490, $230
CpzSpinTube_TubePaths_Path10_Variant2_End

CpzSpinTube_TubePaths_Path11_Variant2:  obj1E67Size
                dc.w    $310, $370
                dc.w    $310, $3B0
                dc.w    $410, $3B0
                dc.w    $410, $2B0
                dc.w    $490, $2B0
                dc.w    $490, $270
CpzSpinTube_TubePaths_Path11_Variant2_End

CpzSpinTube_TubePaths_Path12:   obj1E67Size
                dc.w    $490, $6F0
                dc.w    $490, $730
                dc.w    $690, $730
                dc.w    $890, $730
                dc.w    $890, $6F0
CpzSpinTube_TubePaths_Path12_End

CpzSpinTube_TubePaths_Path13:   obj1E67Size
                dc.w    $BF0, $330
                dc.w    $D90, $330
                dc.w    $D90, $2F0
CpzSpinTube_TubePaths_Path13_End

CpzSpinTube_TubePaths_Path14:   obj1E67Size
                dc.w    $D90, $2B0
                dc.w    $C90, $2B0
                dc.w    $C90, $B0
                dc.w    $E80, $B0
                dc.w    $1110, $B0
                dc.w    $1110, $230
                dc.w    $10F0, $230
CpzSpinTube_TubePaths_Path14_End
; ===========================================================================

                jmpTos  JmpTo_MarkObjGone3

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 20 - Lava bubble from Hill Top Zone (boss weapon)
; ---------------------------------------------------------------------------
; Sprite_22FF8:
