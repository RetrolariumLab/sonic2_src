Sonic_DoLevelCollision:
                move.l  #Primary_Collision,(Collision_addr).w
                cmpi.b  #$C,top_solid_bit(a0)
                beq.s   +
                move.l  #Secondary_Collision,(Collision_addr).w
+
                move.b  lrb_solid_bit(a0),d5
                move.w  x_vel(a0),d1
                move.w  y_vel(a0),d2
                jsr     (CalcAngle).l
                subi.b  #$20,d0
                andi.b  #$C0,d0
                cmpi.b  #$40,d0
                beq.w   Sonic_HitLeftWall
                cmpi.b  #$80,d0
                beq.w   Sonic_HitCeilingAndWalls
                cmpi.b  #$C0,d0
                beq.w   Sonic_HitRightWall
                bsr.w   CheckLeftWallDist
                tst.w   d1
                bpl.s   +
                sub.w   d1,x_pos(a0)
                move.w  #0,x_vel(a0)                    ; stop Sonic since he hit a wall
+
                bsr.w   CheckRightWallDist
                tst.w   d1
                bpl.s   +
                add.w   d1,x_pos(a0)
                move.w  #0,x_vel(a0)                    ; stop Sonic since he hit a wall
+
                bsr.w   Sonic_CheckFloor
                tst.w   d1
                bpl.s   GamePlayerSonicAirCollision_Return
                move.b  y_vel(a0),d2
                addq.b  #8,d2
                neg.b   d2
                cmp.b   d2,d1
                bge.s   +
                cmp.b   d2,d0
                blt.s   GamePlayerSonicAirCollision_Return
+
                add.w   d1,y_pos(a0)
                move.b  d3,angle(a0)
                bsr.w   Sonic_ResetOnFloor
                move.b  d3,d0
                addi.b  #$20,d0
                andi.b  #$40,d0
                bne.s   loc_1AF68
                move.b  d3,d0
                addi.b  #$10,d0
                andi.b  #$20,d0
                beq.s   loc_1AF5A
                asr     y_vel(a0)
                bra.s   loc_1AF7C
; ===========================================================================

loc_1AF5A:
                move.w  #0,y_vel(a0)
                move.w  x_vel(a0),inertia(a0)
                rts
; ===========================================================================

loc_1AF68:
                move.w  #0,x_vel(a0)                    ; stop Sonic since he hit a wall
                cmpi.w  #$FC0,y_vel(a0)
                ble.s   loc_1AF7C
                move.w  #$FC0,y_vel(a0)

loc_1AF7C:
                move.w  y_vel(a0),inertia(a0)
                tst.b   d3
                bpl.s   GamePlayerSonicAirCollision_Return
                neg.w   inertia(a0)

GamePlayerSonicAirCollision_Return:
                rts
; ===========================================================================
; loc_1AF8C:
Sonic_HitLeftWall:
                bsr.w   CheckLeftWallDist
                tst.w   d1
                bpl.s   Sonic_HitCeiling                ; branch if distance is positive (not inside wall)
                sub.w   d1,x_pos(a0)
                move.w  #0,x_vel(a0)                    ; stop Sonic since he hit a wall
                move.w  y_vel(a0),inertia(a0)
                rts
; ===========================================================================
; loc_1AFA6:
Sonic_HitCeiling:
                bsr.w   Sonic_CheckCeiling
                tst.w   d1
                bpl.s   Sonic_HitFloor                  ; branch if distance is positive (not inside ceiling)
                sub.w   d1,y_pos(a0)
                tst.w   y_vel(a0)
                bpl.s   SonicAirCollision_Return_Variant2
                move.w  #0,y_vel(a0)                    ; stop Sonic in y since he hit a ceiling

SonicAirCollision_Return_Variant2:
                rts
; ===========================================================================
; loc_1AFC0:
Sonic_HitFloor:
                tst.w   y_vel(a0)
                bmi.s   SonicAirCollision_Return_Variant3
                bsr.w   Sonic_CheckFloor
                tst.w   d1
                bpl.s   SonicAirCollision_Return_Variant3
                add.w   d1,y_pos(a0)
                move.b  d3,angle(a0)
                bsr.w   Sonic_ResetOnFloor
                move.w  #0,y_vel(a0)
                move.w  x_vel(a0),inertia(a0)

SonicAirCollision_Return_Variant3:
                rts
; ===========================================================================
; loc_1AFE8:
Sonic_HitCeilingAndWalls:
                bsr.w   CheckLeftWallDist
                tst.w   d1
                bpl.s   +
                sub.w   d1,x_pos(a0)
                move.w  #0,x_vel(a0)                    ; stop Sonic since he hit a wall
+
                bsr.w   CheckRightWallDist
                tst.w   d1
                bpl.s   +
                add.w   d1,x_pos(a0)
                move.w  #0,x_vel(a0)                    ; stop Sonic since he hit a wall
+
                bsr.w   Sonic_CheckCeiling
                tst.w   d1
                bpl.s   SonicAirCollision_Return_Variant4
                sub.w   d1,y_pos(a0)
                move.b  d3,d0
                addi.b  #$20,d0
                andi.b  #$40,d0
                bne.s   loc_1B02C
                move.w  #0,y_vel(a0)                    ; stop Sonic in y since he hit a ceiling
                rts
; ===========================================================================

loc_1B02C:
                move.b  d3,angle(a0)
                bsr.w   Sonic_ResetOnFloor
                move.w  y_vel(a0),inertia(a0)
                tst.b   d3
                bpl.s   SonicAirCollision_Return_Variant4
                neg.w   inertia(a0)

SonicAirCollision_Return_Variant4:
                rts
; ===========================================================================
; loc_1B044:
Sonic_HitRightWall:
                bsr.w   CheckRightWallDist
                tst.w   d1
                bpl.s   Sonic_HitCeiling2
                add.w   d1,x_pos(a0)
                move.w  #0,x_vel(a0)                    ; stop Sonic since he hit a wall
                move.w  y_vel(a0),inertia(a0)
                rts
; ===========================================================================
; identical to Sonic_HitCeiling
; loc_1B05E:
Sonic_HitCeiling2:
                bsr.w   Sonic_CheckCeiling
                tst.w   d1
                bpl.s   Sonic_HitFloor2
                sub.w   d1,y_pos(a0)
                tst.w   y_vel(a0)
                bpl.s   SonicAirCollision_Return_Variant5
                move.w  #0,y_vel(a0)                    ; stop Sonic in y since he hit a ceiling

SonicAirCollision_Return_Variant5:
                rts
; ===========================================================================
; identical to Sonic_HitFloor
; loc_1B078:
Sonic_HitFloor2:
                tst.w   y_vel(a0)
                bmi.s   SonicAirCollision_Return_Variant6
                bsr.w   Sonic_CheckFloor
                tst.w   d1
                bpl.s   SonicAirCollision_Return_Variant6
                add.w   d1,y_pos(a0)
                move.b  d3,angle(a0)
                bsr.w   Sonic_ResetOnFloor
                move.w  #0,y_vel(a0)
                move.w  x_vel(a0),inertia(a0)

SonicAirCollision_Return_Variant6:
                rts
; End of function Sonic_DoLevelCollision

; ---------------------------------------------------------------------------
; Subroutine to reset Sonic's mode when he lands on the floor
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; loc_1B0A0:
Sonic_ResetOnFloor:
                tst.b   pinball_mode(a0)
                bne.s   Sonic_ResetOnFloor_Part3
                move.b  #AniIDSonAni_Walk,anim(a0)
; loc_1B0AC:
Sonic_ResetOnFloor_Part2:
; some routines outside of Tails' code can call Sonic_ResetOnFloor_Part2
; when they mean to call Tails_ResetOnFloor_Part2, so fix that here
                _cmpi.b #ObjID_Sonic,id(a0)             ; is this object ID Sonic (obj01)?
                bne.w   Tails_ResetOnFloor_Part2        ; if not, branch to the Tails version of this code

                btst    #status.player.rolling,status(a0)
                beq.s   Sonic_ResetOnFloor_Part3
                bclr    #status.player.rolling,status(a0)
                move.b  #$13,y_radius(a0)               ; this increases Sonic's collision height to standing
                move.b  #9,x_radius(a0)
                move.b  #AniIDSonAni_Walk,anim(a0)      ; use running/walking/standing animation
                subq.w  #5,y_pos(a0)                    ; move Sonic up 5 pixels so the increased height doesn't push him into the ground
; loc_1B0DA:
Sonic_ResetOnFloor_Part3:
                bclr    #status.player.in_air,status(a0)
                bclr    #status.player.pushing,status(a0)
                bclr    #status.player.rolljumping,status(a0)
                move.b  #0,jumping(a0)
                move.w  #0,(Chain_Bonus_counter).w
                move.b  #0,flip_angle(a0)
                move.b  #0,flip_turned(a0)
                move.b  #0,flips_remaining(a0)
                move.w  #0,(Sonic_Look_delay_counter).w
                cmpi.b  #AniIDSonAni_Hang2,anim(a0)
                bne.s   SonicAirCollision_Return_Variant7
                move.b  #AniIDSonAni_Walk,anim(a0)

SonicAirCollision_Return_Variant7:
                rts

; ===========================================================================
; ---------------------------------------------------------------------------
; Sonic when he gets hurt
; ---------------------------------------------------------------------------
; loc_1B120: Obj_01_Sub_4:
