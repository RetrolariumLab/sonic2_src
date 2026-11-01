BossSpecificCollision:
                cmpi.b  #$F,d0
                bne.s   +                               ; rts
                moveq   #0,d0
                move.b  (Current_Boss_ID).w,d0
                beq.s   +                               ; rts
                subq.w  #1,d0
                add.w   d0,d0
                move.w  BossCollision_Index(pc,d0.w),d0
                jmp     BossCollision_Index(pc,d0.w)
; ===========================================================================
+               rts
; ===========================================================================
; off_3FA48:
BossCollision_Index:offsetTable                         ; jump depending on boss ID
                offsetTableEntry.w BossCollision_EHZ_CPZ
                offsetTableEntry.w BossCollision_EHZ_CPZ
                offsetTableEntry.w BossCollision_HTZ
                offsetTableEntry.w BossCollision_ARZ
                offsetTableEntry.w BossCollision_MCZ
                offsetTableEntry.w BossCollision_CNZ
                offsetTableEntry.w BossCollision_MTZ
                offsetTableEntry.w BossCollision_OOZ
                offsetTableEntry.w CollisionBossResponse_Return
; ===========================================================================
; loc_3FA5A:
BossCollision_EHZ_CPZ:
                move.b  collision_flags(a1),d0

CollisionBossResponse_Return:
                rts
; ===========================================================================
; loc_3FA60:
BossCollision_HTZ:
                tst.b   (Boss_CollisionRoutine).w
                bne.s   +
                rts
; ---------------------------------------------------------------------------
+
                move.w  d7,-(sp)
                moveq   #0,d1
                move.b  objoff_15(a1),d1
                subq.b  #2,d1
                cmpi.b  #7,d1
                bgt.s   loc_3FAA8
                move.w  d1,d7
                add.w   d7,d7
                move.w  x_pos(a1),d0
                btst    #render_flags.x_flip,render_flags(a1)
                beq.s   loc_3FA8E
                add.w   word_3FAB0(pc,d7.w),d0
                bra.s   loc_3FA92
; ===========================================================================

loc_3FA8E:
                sub.w   word_3FAB0(pc,d7.w),d0

loc_3FA92:
                move.b  byte_3FAC0(pc,d1.w),d1
                ori.l   #$40000,d1
                move.w  y_pos(a1),d7
                subi.w  #$1C,d7
                bsr.w   Boss_DoCollision

loc_3FAA8:
                move.w  (sp)+,d7
                move.b  collision_flags(a1),d0
                rts
; ===========================================================================
word_3FAB0:
                dc.w    $1C
                dc.w    $20                             ; 1
                dc.w    $28                             ; 2
                dc.w    $34                             ; 3
                dc.w    $3C                             ; 4
                dc.w    $44                             ; 5
                dc.w    $60                             ; 6
                dc.w    $70                             ; 7
byte_3FAC0:
                dc.b    4
                dc.b    4                               ; 1
                dc.b    8                               ; 2
                dc.b    $C                              ; 3
                dc.b    $14                             ; 4
                dc.b    $1C                             ; 5
                dc.b    $24                             ; 6
                dc.b    8                               ; 7
                even
; ===========================================================================
; loc_3FAC8:
BossCollision_ARZ:
                move.w  d7,-(sp)
                move.w  x_pos(a1),d0
                move.w  y_pos(a1),d7
                tst.b   (Boss_CollisionRoutine).w
                beq.s   ++
                addi_.w #4,d7
                subi.w  #$50,d0
                btst    #render_flags.x_flip,render_flags(a1)
                beq.s   +
                addi.w  #$A0,d0
+
                move.l  #$140010,d1
                bsr.w   Boss_DoCollision
+
                move.w  (sp)+,d7
                move.b  collision_flags(a1),d0
                rts
; ===========================================================================
; loc_3FAFE:
BossCollision_MCZ:
                sf      boss_hurt_sonic(a1)
                cmpi.b  #1,(Boss_CollisionRoutine).w
                blt.s   BossCollision_MCZ2
; Boss_CollisionRoutine = 1, i.e. diggers pointing to the side
                move.w  d7,-(sp)
                move.w  x_pos(a1),d0
                move.w  y_pos(a1),d7
                addi_.w #4,d7
                subi.w  #$30,d0
                btst    #render_flags.x_flip,render_flags(a1)  ; left or right?
                beq.s   +
                addi.w  #$60,d0                         ; x+$30, otherwise x-$30
+
                move.l  #$40004,d1                      ; heigth 4, width 4
                bsr.w   Boss_DoCollision
                move.w  (sp)+,d7
                move.b  collision_flags(a1),d0
                cmpi.w  #$78,invulnerable_time(a0)
                bne.s   +                               ; rts
                st.b    boss_hurt_sonic(a1)             ; Sonic has just been hurt flag
+
                rts
; ===========================================================================
; Boss_CollisionRoutine = 0, i.e. diggers pointing towards top
; loc_3FB46:
BossCollision_MCZ2:
                move.w  d7,-(sp)
                movea.w #$14,a5
                movea.w #0,a4

-               move.w  x_pos(a1),d0
                move.w  y_pos(a1),d7
                subi.w  #$20,d7
                add.w   a5,d0                           ; first check x+$14, second x-$14
                move.l  #$100004,d1                     ; heigth $10, width 4
                bsr.w   Boss_DoCollision
                movea.w #-$14,a5
                adda_.w #1,a4
                cmpa.w  #1,a4
                beq.s   -                               ; jump back once for second check
                move.w  (sp)+,d7
                move.b  collision_flags(a1),d0
                cmpi.w  #$78,invulnerable_time(a0)
                bne.s   +                               ; rts
                st.b    boss_hurt_sonic(a1)             ; Sonic has just been hurt flag
+
                rts
; ===========================================================================
; loc_3FB8A:
BossCollision_CNZ:
                tst.b   (Boss_CollisionRoutine).w
                beq.s   ++
                move.w  d7,-(sp)
                move.w  x_pos(a1),d0
                move.w  y_pos(a1),d7
                addi.w  #$28,d7
                move.l  #$80010,d1
                cmpi.b  #1,(Boss_CollisionRoutine).w
                beq.s   +
                move.w  #$20,d1
                subi_.w #8,d7
                addi_.w #4,d0
+
                bsr.w   Boss_DoCollision
                move.w  (sp)+,d7
+
                move.b  collision_flags(a1),d0
                rts
; ===========================================================================
; loc_3FBC4:
BossCollision_MTZ:
                move.b  collision_flags(a1),d0
                rts
; ===========================================================================
; loc_3FBCA:
BossCollision_OOZ:
                cmpi.b  #1,(Boss_CollisionRoutine).w
                blt.s   loc_3FC46
                beq.s   loc_3FC1C
                move.w  d7,-(sp)
                move.w  x_pos(a1),d0
                move.w  y_pos(a1),d7
                moveq   #0,d1
                move.b  mainspr_mapframe(a1),d1
                subq.b  #2,d1
                add.w   d1,d1
                btst    #render_flags.x_flip,render_flags(a1)
                beq.s   loc_3FBF6
                add.w   word_3FC10(pc,d1.w),d0
                bra.s   loc_3FBFA
; ===========================================================================

loc_3FBF6:
                sub.w   word_3FC10(pc,d1.w),d0

loc_3FBFA:
                sub.w   word_3FC10+2(pc,d1.w),d7
                move.l  #$60008,d1
                bsr.w   Boss_DoCollision
                move.w  (sp)+,d7
                move.w  #0,d0
                rts
; ===========================================================================
word_3FC10:
                dc.w    $14,    0
                dc.w    $10,  $10
                dc.w    $10, -$10
; ===========================================================================

loc_3FC1C:
                move.w  d7,-(sp)
                move.w  x_pos(a1),d0
                move.w  y_pos(a1),d7
                moveq   #$10,d1
                btst    #render_flags.x_flip,render_flags(a1)
                beq.s   +
                neg.w   d1
+
                sub.w   d1,d0
                move.l  #$8000C,d1
                bsr.w   BossCollision_BounceOnOverlap
                move.w  (sp)+,d7
                move.b  #0,d0
                rts
; ===========================================================================

loc_3FC46:
                move.b  collision_flags(a1),d0
                rts
; ===========================================================================
; loc_3FC4C:
; d7 = y_boss, d3 = y_Sonic, d1 (high word) = height
; d0 = x_boss, d2 = x_Sonic, d1 (low word)  = width
Boss_DoCollision:
                sub.w   d1,d0
                sub.w   d2,d0
                bcc.s   loc_3FC5A
                add.w   d1,d1
                add.w   d1,d0
                bcs.s   loc_3FC5E

CollisionBossResponse_Return_Variant2:
                rts
; ===========================================================================

loc_3FC5A:
                cmp.w   d4,d0
                bhi.s   CollisionBossResponse_Return_Variant2

loc_3FC5E:
                swap    d1
                sub.w   d1,d7
                sub.w   d3,d7
                bcc.s   loc_3FC70
                add.w   d1,d1
                add.w   d1,d7
                bcs.w   Touch_ChkHurt
                bra.s   CollisionBossResponse_Return_Variant2
; ===========================================================================

loc_3FC70:
                cmp.w   d5,d7
                bhi.w   CollisionBossResponse_Return_Variant2
                bra.w   Touch_ChkHurt
; ===========================================================================

BossCollision_BounceOnOverlap:
                sub.w   d1,d0
                sub.w   d2,d0
                bcc.s   loc_3FC88
                add.w   d1,d1
                add.w   d1,d0
                bcs.s   loc_3FC8C

CollisionBossResponse_Return_Variant3:
                rts
; ===========================================================================

loc_3FC88:
                cmp.w   d4,d0
                bhi.s   CollisionBossResponse_Return_Variant3

loc_3FC8C:
                swap    d1
                sub.w   d1,d7
                sub.w   d3,d7
                bcc.s   loc_3FC9E
                add.w   d1,d1
                add.w   d1,d7
                bcs.w   loc_3FCA4
                bra.s   CollisionBossResponse_Return_Variant3
; ===========================================================================

loc_3FC9E:
                cmp.w   d5,d7
                bhi.w   CollisionBossResponse_Return_Variant3

loc_3FCA4:
                neg.w   x_vel(a0)
                neg.w   y_vel(a0)
                rts
; ===========================================================================

                jmpTos  JmpTo_Sonic_ResetOnFloor_Part2,JmpTo_Check_CNZ_bumpers,JmpTo_Touch_Rings

; ===========================================================================
; loc_3FCC4:
