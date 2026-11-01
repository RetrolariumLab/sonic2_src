ObjDC:
                moveq   #0,d0
                move.b  routine(a0),d0
                move.w  ObjDC_Index(pc,d0.w),d1
                jmp     ObjDC_Index(pc,d1.w)
; ===========================================================================
; off_125F4:
ObjDC_Index:    offsetTable
                offsetTableEntry.w ObjDC_Main           ; 0
                offsetTableEntry.w ObjDC_Animate        ; 2
                offsetTableEntry.w ObjDC_Delete         ; 4
; ===========================================================================
; loc_125FA:
ObjDC_Main:
                moveq   #0,d1
                move.w  casino_prize_machine_x_pos(a0),d1
                swap    d1
                move.l  casino_prize_x_pos(a0),d0
                sub.l   d1,d0
                asr.l   #4,d0
                sub.l   d0,casino_prize_x_pos(a0)
                move.w  casino_prize_x_pos(a0),x_pos(a0)
                moveq   #0,d1
                move.w  casino_prize_machine_y_pos(a0),d1
                swap    d1
                move.l  casino_prize_y_pos(a0),d0
                sub.l   d1,d0
                asr.l   #4,d0
                sub.l   d0,casino_prize_y_pos(a0)
                move.w  casino_prize_y_pos(a0),y_pos(a0)
                lea     Ani_objDC(pc),a1
                bsr.w   AnimateSprite
                subq.w  #1,casino_prize_display_delay(a0)
                bne.w   DisplaySprite
                movea.l objoff_2A(a0),a1
                subq.w  #1,(a1)
                bsr.w   CollectRing
                addi_.b #2,routine(a0)
; loc_1264E:
ObjDC_Animate:
                lea     Ani_Ring(pc),a1
                bsr.w   AnimateSprite
                bra.w   DisplaySprite
; ===========================================================================
; BranchTo8_DeleteObject
ObjDC_Delete:
                bra.w   DeleteObject
; ===========================================================================
; animation script
; byte_1265E
Ani_objDC:      offsetTable
                offsetTableEntry.w +                    ; 0
+               dc.b    1,  0,  1,  2,  3,$FF
                even
; ===========================================================================

                jmpTos  JmpTo4_CalcSine

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 26 - Monitor
;
; The power-ups themselves are handled by the next object. This just does the
; monitor collision and graphics
; ---------------------------------------------------------------------------
; Sprite_12974: Obj_Monitor:
