Sonic_CheckSpindash:
                tst.b   spindash_flag(a0)
                bne.s   Sonic_UpdateSpindash
                cmpi.b  #AniIDSonAni_Duck,anim(a0)
                bne.s   GamePlayerSonicSpindashAndSlopes_Return
                move.b  (Ctrl_1_Press_Logical).w,d0
                andi.b  #button_B_mask|button_C_mask|button_A_mask,d0
                beq.w   GamePlayerSonicSpindashAndSlopes_Return
                move.b  #AniIDSonAni_Spindash,anim(a0)
                move.w  #SndID_SpindashRev,d0
                jsr     (PlaySound).l
                addq.l  #4,sp
                move.b  #1,spindash_flag(a0)
                move.w  #0,spindash_counter(a0)
                cmpi.b  #12,air_left(a0)                ; if he's drowning, branch to not make dust
                blo.s   +
                move.b  #2,(Sonic_Dust+anim).w
+
                bsr.w   Sonic_LevelBound
                bsr.w   AnglePos

GamePlayerSonicSpindashAndSlopes_Return:
                rts
; End of subroutine Sonic_CheckSpindash

; ---------------------------------------------------------------------------
; Subrouting to update an already-charging spindash
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; loc_1AC8E:
Sonic_UpdateSpindash:
                move.b  (Ctrl_1_Held_Logical).w,d0
                btst    #button_down,d0
                bne.w   Sonic_ChargingSpindash

; unleash the charged spindash and start rolling quickly:
                move.b  #$E,y_radius(a0)
                move.b  #7,x_radius(a0)
                move.b  #AniIDSonAni_Roll,anim(a0)
                addq.w  #5,y_pos(a0)                    ; add the difference between Sonic's rolling and standing heights
                move.b  #0,spindash_flag(a0)
                moveq   #0,d0
                move.b  spindash_counter(a0),d0
                add.w   d0,d0
                move.w  SpindashSpeeds(pc,d0.w),inertia(a0)
                tst.b   (Super_Sonic_flag).w
                beq.s   +
                move.w  SpindashSpeedsSuper(pc,d0.w),inertia(a0)
+
; Determine how long to lag the camera for
; Notably, the faster Sonic goes, the less the camera lags
; This is seemingly to prevent Sonic from going off-screen
                move.w  inertia(a0),d0
                subi.w  #$800,d0                        ; $800 is the lowest spin dash speed
                add.w   d0,d0
                andi.w  #$1F00,d0                       ; This line is not necessary, as none of the removed bits are ever set in the first place
                neg.w   d0
                addi.w  #$2000,d0
                move.w  d0,(Horiz_scroll_delay_val).w

                btst    #status.player.x_flip,status(a0)
                beq.s   +
                neg.w   inertia(a0)
+
                bset    #status.player.rolling,status(a0)
                move.b  #0,(Sonic_Dust+anim).w
                move.w  #SndID_SpindashRelease,d0       ; spindash zoom sound
                jsr     (PlaySound).l
                bra.s   Obj01_Spindash_ResetScr
; ===========================================================================
; word_1AD0C:
SpindashSpeeds:
                dc.w    $800                            ; 0
                dc.w    $880                            ; 1
                dc.w    $900                            ; 2
                dc.w    $980                            ; 3
                dc.w    $A00                            ; 4
                dc.w    $A80                            ; 5
                dc.w    $B00                            ; 6
                dc.w    $B80                            ; 7
                dc.w    $C00                            ; 8
; word_1AD1E:
SpindashSpeedsSuper:
                dc.w    $B00                            ; 0
                dc.w    $B80                            ; 1
                dc.w    $C00                            ; 2
                dc.w    $C80                            ; 3
                dc.w    $D00                            ; 4
                dc.w    $D80                            ; 5
                dc.w    $E00                            ; 6
                dc.w    $E80                            ; 7
                dc.w    $F00                            ; 8
; ===========================================================================
; loc_1AD30:
Sonic_ChargingSpindash:                                 ; If still charging the dash
                tst.w   spindash_counter(a0)
                beq.s   +
                move.w  spindash_counter(a0),d0
                lsr.w   #5,d0
                sub.w   d0,spindash_counter(a0)
                bcc.s   +
                move.w  #0,spindash_counter(a0)
+
                move.b  (Ctrl_1_Press_Logical).w,d0
                andi.b  #button_B_mask|button_C_mask|button_A_mask,d0
                beq.w   Obj01_Spindash_ResetScr
                move.w  #(AniIDSonAni_Spindash<<8)|(AniIDSonAni_Walk<<0),anim(a0)
                move.w  #SndID_SpindashRev,d0
                jsr     (PlaySound).l
                addi.w  #$200,spindash_counter(a0)
                cmpi.w  #$800,spindash_counter(a0)
                blo.s   Obj01_Spindash_ResetScr
                move.w  #$800,spindash_counter(a0)

; loc_1AD78:
Obj01_Spindash_ResetScr:
                addq.l  #4,sp
                cmpi.w  #(screen_height/2)-16,(Camera_Y_pos_bias).w
                beq.s   loc_1AD8C
                bhs.s   +
                addq.w  #4,(Camera_Y_pos_bias).w
+               subq.w  #2,(Camera_Y_pos_bias).w

loc_1AD8C:
                bsr.w   Sonic_LevelBound
                bsr.w   AnglePos
                rts
; End of subroutine Sonic_UpdateSpindash

; ---------------------------------------------------------------------------
; Subroutine to slow Sonic walking up a slope
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; loc_1AD96:
Sonic_SlopeResist:
                move.b  angle(a0),d0
                addi.b  #$60,d0
                cmpi.b  #$C0,d0
                bhs.s   GamePlayerSonicSpindashAndSlopes_Return_Variant2
                move.b  angle(a0),d0
                jsr     (CalcSine).l
                muls.w  #$20,d0
                asr.l   #8,d0
                tst.w   inertia(a0)
                beq.s   GamePlayerSonicSpindashAndSlopes_Return_Variant2
                bmi.s   loc_1ADC6
                tst.w   d0
                beq.s   +
                add.w   d0,inertia(a0)                  ; change Sonic's $14
+
                rts
; ---------------------------------------------------------------------------

loc_1ADC6:
                add.w   d0,inertia(a0)

GamePlayerSonicSpindashAndSlopes_Return_Variant2:
                rts
; End of subroutine Sonic_SlopeResist

; ---------------------------------------------------------------------------
; Subroutine to push Sonic down a slope while he's rolling
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; loc_1ADCC:
Sonic_RollRepel:
                move.b  angle(a0),d0
                addi.b  #$60,d0
                cmpi.b  #$C0,d0
                bhs.s   GamePlayerSonicSpindashAndSlopes_Return_Variant3
                move.b  angle(a0),d0
                jsr     (CalcSine).l
                muls.w  #$50,d0
                asr.l   #8,d0
                tst.w   inertia(a0)
                bmi.s   loc_1ADFC
                tst.w   d0
                bpl.s   loc_1ADF6
                asr.l   #2,d0

loc_1ADF6:
                add.w   d0,inertia(a0)
                rts
; ===========================================================================

loc_1ADFC:
                tst.w   d0
                bmi.s   loc_1AE02
                asr.l   #2,d0

loc_1AE02:
                add.w   d0,inertia(a0)

GamePlayerSonicSpindashAndSlopes_Return_Variant3:
                rts
; End of function Sonic_RollRepel

; ---------------------------------------------------------------------------
; Subroutine to push Sonic down a slope
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; loc_1AE08:
Sonic_SlopeRepel:
                nop
                tst.b   stick_to_convex(a0)
                bne.s   GamePlayerSonicSpindashAndSlopes_Return_Variant4
                tst.w   move_lock(a0)
                bne.s   loc_1AE44
                move.b  angle(a0),d0
                addi.b  #$20,d0
                andi.b  #$C0,d0
                beq.s   GamePlayerSonicSpindashAndSlopes_Return_Variant4
                mvabs.w inertia(a0),d0
                cmpi.w  #$280,d0
                bhs.s   GamePlayerSonicSpindashAndSlopes_Return_Variant4
                clr.w   inertia(a0)
                bset    #status.player.in_air,status(a0)
                move.w  #$1E,move_lock(a0)

GamePlayerSonicSpindashAndSlopes_Return_Variant4:
                rts
; ===========================================================================

loc_1AE44:
                subq.w  #1,move_lock(a0)
                rts
; End of function Sonic_SlopeRepel

; ---------------------------------------------------------------------------
; Subroutine to return Sonic's angle to 0 as he jumps
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; loc_1AE4A:
Sonic_JumpAngle:
                move.b  angle(a0),d0                    ; get Sonic's angle
                beq.s   Sonic_JumpFlip                  ; if already 0, branch
                bpl.s   loc_1AE5A                       ; if higher than 0, branch

                addq.b  #2,d0                           ; increase angle
                bcc.s   BranchTo_Sonic_JumpAngleSet
                moveq   #0,d0

BranchTo_Sonic_JumpAngleSet                             ; BranchTo
                bra.s   Sonic_JumpAngleSet
; ===========================================================================

loc_1AE5A:
                subq.b  #2,d0                           ; decrease angle
                bcc.s   Sonic_JumpAngleSet
                moveq   #0,d0

; loc_1AE60:
Sonic_JumpAngleSet:
                move.b  d0,angle(a0)
; End of function Sonic_JumpAngle
; continue straight to Sonic_JumpFlip

; ---------------------------------------------------------------------------
; Updates Sonic's secondary angle if he's tumbling
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; loc_1AE64:
Sonic_JumpFlip:
                move.b  flip_angle(a0),d0
                beq.s   GamePlayerSonicSpindashAndSlopes_Return_Variant5
                tst.w   inertia(a0)
                bmi.s   Sonic_JumpLeftFlip
; loc_1AE70:
Sonic_JumpRightFlip:
                move.b  flip_speed(a0),d1
                add.b   d1,d0
                bcc.s   BranchTo_Sonic_JumpFlipSet
                subq.b  #1,flips_remaining(a0)
                bcc.s   BranchTo_Sonic_JumpFlipSet
                move.b  #0,flips_remaining(a0)
                moveq   #0,d0

BranchTo_Sonic_JumpFlipSet                              ; BranchTo
                bra.s   Sonic_JumpFlipSet
; ===========================================================================
; loc_1AE88:
Sonic_JumpLeftFlip:
                tst.b   flip_turned(a0)
                bne.s   Sonic_JumpRightFlip
                move.b  flip_speed(a0),d1
                sub.b   d1,d0
                bcc.s   Sonic_JumpFlipSet
                subq.b  #1,flips_remaining(a0)
                bcc.s   Sonic_JumpFlipSet
                move.b  #0,flips_remaining(a0)
                moveq   #0,d0
; loc_1AEA4:
Sonic_JumpFlipSet:
                move.b  d0,flip_angle(a0)

GamePlayerSonicSpindashAndSlopes_Return_Variant5:
                rts
; End of function Sonic_JumpFlip

; ---------------------------------------------------------------------------
; Subroutine for Sonic to interact with the floor and walls when he's in the air
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; loc_1AEAA: Sonic_Floor:
