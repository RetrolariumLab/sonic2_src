Obj01:
; a0=character
                tst.w   (Debug_placement_mode).w        ; is debug mode being used?
                beq.s   Obj01_Normal                    ; if not, branch
                jmp     (DebugMode).l
; ---------------------------------------------------------------------------
; loc_19F5C:
Obj01_Normal:
                moveq   #0,d0
                move.b  routine(a0),d0
                move.w  Obj01_Index(pc,d0.w),d1
                jmp     Obj01_Index(pc,d1.w)
; ===========================================================================
; off_19F6A: Obj01_States:
Obj01_Index:    offsetTable
                offsetTableEntry.w Obj01_Init           ; 0 - object init
                offsetTableEntry.w Obj01_Control        ; 2 - main mode
                offsetTableEntry.w Obj01_Hurt           ; 4 - while being knocked back from damage
                offsetTableEntry.w Obj01_Dead           ; 6 - while dying and falling off screen
                offsetTableEntry.w Obj01_Gone           ; 8 - after dying and waiting for the level to restart
                offsetTableEntry.w Obj01_Respawning     ; $A - while waiting for the camera to scroll to the respawn point
; ===========================================================================
; loc_19F76: Obj_01_Sub_0: Obj01_Main:
Obj01_Init:
                addq.b  #2,routine(a0)                  ; => Obj01_Control
                move.b  #$13,y_radius(a0)               ; this sets Sonic's collision height (2*pixels)
                move.b  #9,x_radius(a0)                 ; this sets Sonic's Collision width (2*pixels)
                move.l  #MapUnc_Sonic,mappings(a0)      ; load Sonic's mappings
                move.b  #2,priority(a0)                 ; set sprite priority
                move.b  #$18,width_pixels(a0)           ; set render width
                move.b  #1<<render_flags.level_fg,render_flags(a0)  ; set to playfield-positioned mode
                move.w  #$600,(Sonic_top_speed).w       ; set Sonic's top speed
                move.w  #$C,(Sonic_acceleration).w      ; set Sonic's acceleration
                move.w  #$80,(Sonic_deceleration).w     ; set Sonic's deceleration
                tst.b   (Last_star_pole_hit).w          ; is Sonic starting at a checkpoint?
                bne.s   Obj01_Init_Continued            ; if so, branch
                move.w  #make_art_tile(ArtTile_ArtUnc_Sonic,0,0),art_tile(a0)  ; load Sonic's art
                bsr.w   Adjust2PArtPointer              ; adjust Sonic's art pointer if in 2-player mode
                move.b  #$C,top_solid_bit(a0)
                move.b  #$D,lrb_solid_bit(a0)
                move.w  x_pos(a0),(Saved_x_pos).w
                move.w  y_pos(a0),(Saved_y_pos).w
                move.w  art_tile(a0),(Saved_art_tile).w
                move.w  top_solid_bit(a0),(Saved_Solid_bits).w

Obj01_Init_Continued:
                move.b  #0,flips_remaining(a0)          ; reset flips
                move.b  #4,flip_speed(a0)               ; reset flip speed(?)
                move.b  #0,(Super_Sonic_flag).w         ; reset Super Sonic flag
                move.b  #30,air_left(a0)                ; reset air count
                subi.w  #$20,x_pos(a0)
                addi_.w #4,y_pos(a0)
                move.w  #0,(Sonic_Pos_Record_Index).w

                move.w  #$3F,d2
-               bsr.w   Sonic_RecordPos
                subq.w  #4,a1
                move.l  #0,(a1)
                dbf     d2,-

                addi.w  #$20,x_pos(a0)
                subi_.w #4,y_pos(a0)

; ---------------------------------------------------------------------------
; Normal state for Sonic
; ---------------------------------------------------------------------------
; loc_1A030: Obj_01_Sub_2:
Obj01_Control:
                tst.w   (Debug_mode_flag).w             ; is debug cheat enabled?
                beq.s   +                               ; if not, branch
                btst    #button_B,(Ctrl_1_Press).w      ; is button B pressed?
                beq.s   +                               ; if not, branch
                move.w  #1,(Debug_placement_mode).w     ; change Sonic into a ring/item
                clr.b   (Control_Locked).w              ; unlock control
                rts
; -----------------------------------------------------------------------
+               tst.b   (Control_Locked).w              ; are controls locked?
                bne.s   +                               ; if yes, branch
                move.w  (Ctrl_1).w,(Ctrl_1_Logical).w   ; copy new held buttons, to enable joypad control
+
                btst    #0,obj_control(a0)              ; is Sonic interacting with another object that holds him in place or controls his movement somehow?
                bne.s   +                               ; if yes, branch to skip Sonic's control
                moveq   #0,d0
                move.b  status(a0),d0
                andi.w  #1<<status.player.in_air|1<<status.player.rolling,d0  ; %0000 %0110
                move.w  Obj01_Modes(pc,d0.w),d1
                jsr     Obj01_Modes(pc,d1.w)            ; run Sonic's movement control code
+
                cmpi.w  #-$100,(Camera_Min_Y_pos).w     ; is vertical wrapping enabled?
                bne.s   +                               ; if not, branch
                andi.w  #$7FF,y_pos(a0)                 ; perform wrapping of Sonic's y position
+
                bsr.s   Sonic_Display                   ; display Sonic sprite and handle power-up expiration
                bsr.w   Sonic_Super                     ; handle Sonic in his Super form
                bsr.w   Sonic_RecordPos                 ; record Sonic's previous position for invincibility stars and Tails
                bsr.w   Sonic_Water                     ; handle Sonic while underwater
                move.b  (Primary_Angle).w,next_tilt(a0)  ; update front collision hot spot
                move.b  (Secondary_Angle).w,tilt(a0)    ; update rear collision hot spot
                tst.b   (WindTunnel_flag).w             ; is Sonic in a wind tunnel?
                beq.s   +                               ; if not, branch
                tst.b   anim(a0)                        ; is current animation null/id_Walk?
                bne.s   +                               ; if not, branch
                move.b  prev_anim(a0),anim(a0)          ; make sure Sonic is in the correct animation while in a wind tunnel
+
                bsr.w   Sonic_Animate                   ; run Sonic's animation scripts
                tst.b   obj_control(a0)                 ; is object interactions ignore flag set?
                bmi.s   +                               ; if yes, branch
                jsr     (TouchResponse).l               ; handle object interactions with Sonic
+
                bra.w   LoadSonicDynPLC                 ; update Sonic's graphics if necessary

; ===========================================================================
; secondary states under state Obj01_Control
; off_1A0BE:
Obj01_Modes:    offsetTable
                offsetTableEntry.w Obj01_MdNormal_Checks  ; 0 - not airborne or rolling
                offsetTableEntry.w Obj01_MdAir          ; 2 - airborne
                offsetTableEntry.w Obj01_MdRoll         ; 4 - rolling
                offsetTableEntry.w Obj01_MdJump         ; 6 - jumping
; ===========================================================================

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; loc_1A0C6:
Sonic_Display:
                move.w  invulnerable_time(a0),d0        ; get Sonic's remaining invulnerability frames after getting hurt
                beq.s   Obj01_Display                   ; if there are none, branch
                subq.w  #1,invulnerable_time(a0)        ; decrease invulnerability frames
                lsr.w   #3,d0                           ; check every 3 or 4 frames
                bcc.s   Obj01_ChkInvin                  ; don't render Sonic's sprite
; loc_1A0D4:
Obj01_Display:
                jsr     (DisplaySprite).l               ; display Sonic sprite normally
; loc_1A0DA:
Obj01_ChkInvin:
                btst    #status_secondary.invincible,status_secondary(a0)  ; is Sonic invincible?
                beq.s   Obj01_ChkShoes                  ; if not, branch
                tst.w   invincibility_time(a0)          ; is there time remaining for invincibility?
                beq.s   Obj01_ChkShoes                  ; if not, branch
                subq.w  #1,invincibility_time(a0)       ; subtract 1 from time
                bne.s   Obj01_ChkShoes                  ; if time remains, branch
                tst.b   (Current_Boss_ID).w             ; is a boss fight active?
                bne.s   Obj01_RmvInvin                  ; if yes, branch
                cmpi.b  #12,air_left(a0)                ; is drowning countdown active?
                blo.s   Obj01_RmvInvin                  ; if yes, branch
                move.w  (Level_Music).w,d0              ; load normal level music
                jsr     (PlayMusic).l                   ; play normal level music
; loc_1A106:
Obj01_RmvInvin:
                bclr    #status_secondary.invincible,status_secondary(a0)  ; remove invincibility
; loc_1A10C:
Obj01_ChkShoes:
                btst    #status_secondary.speed_shoes,status_secondary(a0)  ; does Sonic have speed shoes?
                beq.s   Obj01_ExitChk                   ; if not, branch
                tst.w   speedshoes_time(a0)             ; is there time remaining for speed shoes?
                beq.s   Obj01_ExitChk                   ; if not, branch
                subq.w  #1,speedshoes_time(a0)          ; subtract 1 from time
                bne.s   Obj01_ExitChk                   ; if time remains, branch
                move.w  #$600,(Sonic_top_speed).w       ; restore Sonic's default top speed
                move.w  #$C,(Sonic_acceleration).w      ; restore Sonic's default acceleration
                move.w  #$80,(Sonic_deceleration).w     ; restore Sonic's default deceleration
                tst.b   (Super_Sonic_flag).w            ; is Sonic in his Super form?
                beq.s   Obj01_RmvSpeed                  ; if not, branch
                move.w  #$A00,(Sonic_top_speed).w       ; restore Super Sonic's top speed
                move.w  #$30,(Sonic_acceleration).w     ; restore Super Sonic's acceleration
                move.w  #$100,(Sonic_deceleration).w    ; restore Super Sonic's deceleration
; loc_1A14A:
Obj01_RmvSpeed:
                bclr    #status_secondary.speed_shoes,status_secondary(a0)  ; remove speed shoes
                move.w  #MusID_SlowDown,d0              ; Slow down tempo
                jmp     (PlayMusic).l                   ; play music at normal speed
; ---------------------------------------------------------------------------
; return_1A15A:
Obj01_ExitChk:
                rts                                     ; return
; End of subroutine Sonic_Display

; ---------------------------------------------------------------------------
; Subroutine to record Sonic's previous positions for invincibility stars
; and input/status flags for Tails' AI to follow
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; loc_1A15C:
Sonic_RecordPos:
                move.w  (Sonic_Pos_Record_Index).w,d0   ; get current index for the tracking array
                lea     (Sonic_Pos_Record_Buf).w,a1     ; load tracking array
                lea     (a1,d0.w),a1                    ; set pointer to current index
                move.w  x_pos(a0),(a1)+                 ; store Sonic's current X-position
                move.w  y_pos(a0),(a1)+                 ; store Sonic's current Y-position
                addq.b  #4,(Sonic_Pos_Record_Index+1).w  ; advance to next tracking pointer (this is a byte, so it wraps from $FC back to $00)

                lea     (Sonic_Stat_Record_Buf).w,a1
                lea     (a1,d0.w),a1
                move.w  (Ctrl_1_Logical).w,(a1)+
                move.w  status(a0),(a1)+                ; Copies `status` AND the byte after it

                rts
; End of subroutine Sonic_RecordPos

; ---------------------------------------------------------------------------
; Subroutine for Sonic when he's underwater
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

obj0a_character     =       objoff_3C

; loc_1A186:
Sonic_Water:
                tst.b   (Water_flag).w                  ; does level have water?
                bne.s   Obj01_InWater                   ; if yes, branch

GamePlayerSonicControl_Return:
                rts
; ---------------------------------------------------------------------------
; loc_1A18E:
Obj01_InWater:
                move.w  (Water_Level_1).w,d0
                cmp.w   y_pos(a0),d0                    ; is Sonic above the water?
                bge.s   Obj01_OutWater                  ; if yes, branch

                bset    #status.player.underwater,status(a0)  ; set underwater flag
                bne.s   GamePlayerSonicControl_Return                    ; if already underwater, branch

                movea.l a0,a1
                bsr.w   ResumeMusic                     ; replenish air (music won't resume here, we've only just entered water...)
                move.b  #ObjID_SmallBubbles,(Sonic_BreathingBubbles+id).w  ; load Obj0A (Sonic's breathing bubbles) at $FFFFD080
                move.b  #$81,(Sonic_BreathingBubbles+subtype).w  ; prepare subtype so it sets itself to Drown_Countdown
                move.l  a0,(Sonic_BreathingBubbles+obj0a_character).w
                move.w  #$300,(Sonic_top_speed).w       ; change Sonic's top speed
                move.w  #6,(Sonic_acceleration).w       ; change Sonic's acceleration
                move.w  #$40,(Sonic_deceleration).w     ; change Sonic's deceleration
                tst.b   (Super_Sonic_flag).w            ; is Sonic in his Super form?
                beq.s   +                               ; if not, branch
                move.w  #$500,(Sonic_top_speed).w       ; change Super Sonic's top speed
                move.w  #$18,(Sonic_acceleration).w     ; change Super Sonic's acceleration
                move.w  #$80,(Sonic_deceleration).w     ; change Super Sonic's deceleration
+
                asr.w   x_vel(a0)                       ; half X-speed when entering water
                asr.w   y_vel(a0)                       ; divide Y-speed by 4 when entering water
                asr.w   y_vel(a0)                       ; (memory operands can only be shifted one bit at a time)
                beq.s   GamePlayerSonicControl_Return                    ; if Sonic's new Y-speed is 0, don't load splash object
                move.w  #(1<<8)|(0<<0),(Sonic_Dust+anim).w  ; load splash animation from Obj08
                move.w  #SndID_Splash,d0                ; load splash sound
                jmp     (PlaySound).l                   ; play splash sound
; ---------------------------------------------------------------------------
; loc_1A1FE:
Obj01_OutWater:
                bclr    #status.player.underwater,status(a0)  ; unset underwater flag
                beq.s   GamePlayerSonicControl_Return                    ; if already above water, branch

                movea.l a0,a1
                bsr.w   ResumeMusic                     ; replenish air and resume music if necessary
                move.w  #$600,(Sonic_top_speed).w       ; restore Sonic's default top speed
                move.w  #$C,(Sonic_acceleration).w      ; restore Sonic's default acceleration
                move.w  #$80,(Sonic_deceleration).w     ; restore Sonic's default deceleration
                tst.b   (Super_Sonic_flag).w            ; is Sonic in his Super form?
                beq.s   +                               ; if not, branch
                move.w  #$A00,(Sonic_top_speed).w       ; restore Super Sonic's top speed
                move.w  #$30,(Sonic_acceleration).w     ; restore Super Sonic's acceleration
                move.w  #$100,(Sonic_deceleration).w    ; restore Super Sonic's deceleration
+
                cmpi.b  #4,routine(a0)                  ; is Sonic falling back from getting hurt?
                beq.s   +                               ; if yes, branch
                asl     y_vel(a0)                       ; double Y-speed while exiting water
+
                tst.w   y_vel(a0)                       ; test Sonic's Y-speed
                beq.w   GamePlayerSonicControl_Return                    ; branch if 0
                move.w  #(1<<8)|(0<<0),(Sonic_Dust+anim).w  ; load splash animation from Obj08
                movea.l a0,a1
                bsr.w   ResumeMusic                     ; (why is this repeated?)
                cmpi.w  #-$1000,y_vel(a0)               ; is Sonic's new Y-speed too fast?
                bgt.s   +                               ; if not, branch
                move.w  #-$1000,y_vel(a0)               ; limit upward Y-speed
+
                move.w  #SndID_Splash,d0                ; load splash sound
                jmp     (PlaySound).l                   ; play splash sound
; End of subroutine Sonic_Water

; ===========================================================================
; ---------------------------------------------------------------------------
; Start of subroutine Obj01_MdNormal
; Called if Sonic is neither airborne nor rolling this frame
; ---------------------------------------------------------------------------
; loc_1A26E:
Obj01_MdNormal_Checks:
; If Sonic has been waiting for a while, and is tapping his foot
; impatiently, then make him blink once the player starts moving
; again. Likewise, if he's been waiting for so long that he's laying
; down, then make him play an animation of standing up
                move.b  (Ctrl_1_Press_Logical).w,d0     ; load currently pressed buttons
                andi.b  #button_B_mask|button_C_mask|button_A_mask,d0  ; is A, B, or C pressed?
                bne.s   Obj01_MdNormal                  ; if yes, branch
                cmpi.b  #AniIDSonAni_Blink,anim(a0)     ; is Sonic's animation "Blink"?
                beq.s   Obj01_MdNormal_Skip             ; if yes, branch
                cmpi.b  #AniIDSonAni_GetUp,anim(a0)     ; is Sonic's animation "GetUp"?
                beq.s   Obj01_MdNormal_Skip             ; if yes, branch
                cmpi.b  #AniIDSonAni_Wait,anim(a0)      ; is Sonic's animation "Wait"?
                bne.s   Obj01_MdNormal                  ; if not, branch
                cmpi.b  #$1E,anim_frame(a0)             ; is the animation frame $1E or higher?
                blo.s   Obj01_MdNormal                  ; if not, branch
                move.b  (Ctrl_1_Held_Logical).w,d0      ; load currently held buttons
                andi.b  #button_up_mask|button_down_mask|button_left_mask|button_right_mask|button_B_mask|button_C_mask|button_A_mask,d0  ; are the D-Pad or face buttons being held?
                beq.s   Obj01_MdNormal_Skip             ; if not, branch
                move.b  #AniIDSonAni_Blink,anim(a0)     ; set Sonic's animation to "Blink"
                cmpi.b  #$AC,anim_frame(a0)             ; is the animation frame $AC or higher?
                blo.s   Obj01_MdNormal_Skip             ; if not, branch
                move.b  #AniIDSonAni_GetUp,anim(a0)     ; set Sonic's animation to "GetUp"
                bra.s   Obj01_MdNormal_Skip             ; skip normal checks (beware the fixBugs below)
; ---------------------------------------------------------------------------
; loc_1A2B8:
Obj01_MdNormal:
                bsr.w   Sonic_CheckSpindash             ; check for spindash
                bsr.w   Sonic_Jump                      ; check for jumping
                bsr.w   Sonic_SlopeResist               ; handle resistance from running up slopes
                bsr.w   Sonic_Move                      ; handle Sonic's left/right movement
                bsr.w   Sonic_Roll                      ; check for rolling

                bsr.w   Sonic_LevelBound                ; keep Sonic within level bounds and handle bottomless pits
                jsr     (ObjectMove).l                  ; update Sonic's position based on his current velocities
                bsr.w   AnglePos                        ; update Sonic's current angle as he walks along the floor
                bsr.w   Sonic_SlopeRepel                ; handle Sonic detaching from walls if not fast enough

; return_1A2DE:
Obj01_MdNormal_Skip:
                rts
; End of subroutine Obj01_MdNormal
; ===========================================================================
; Start of subroutine Obj01_MdAir
; Called if Sonic is airborne, but not in a ball (thus, probably not jumping)
; loc_1A2E0: Obj01_MdJump
Obj01_MdAir:
                bsr.w   Sonic_JumpHeight                ; handle Sonic's jump height based on whether the jump button is still held
                bsr.w   Sonic_ChgJumpDir                ; handle midair direction adjustments while jumping
                bsr.w   Sonic_LevelBound                ; keep Sonic within level bounds and handle bottomless pits
                jsr     (ObjectMoveAndFall).l           ; apply gravity and update Sonic's position based on his current velocities
                btst    #status.player.underwater,status(a0)  ; is Sonic underwater?
                beq.s   +                               ; if not, branch
                subi.w  #$28,y_vel(a0)                  ; reduce gravity by $28 ($38-$28=$10)
+
                bsr.w   Sonic_JumpAngle                 ; steadily return Sonic's angle while jumping to 0
                bsr.w   Sonic_DoLevelCollision          ; handle collision with level while airborne
                rts
; End of subroutine Obj01_MdAir
; ===========================================================================
; Start of subroutine Obj01_MdRoll
; Called if Sonic is in a ball, but not airborne (thus, probably rolling)
; loc_1A30A:
Obj01_MdRoll:
                tst.b   pinball_mode(a0)                ; is Sonic in pinball mode?
                bne.s   +                               ; if yes, branch
                bsr.w   Sonic_Jump                      ; check for jumping
+
                bsr.w   Sonic_RollRepel                 ; handle resistance from rolling up slopes
                bsr.w   Sonic_RollSpeed                 ; update speed as Sonic rolls
                bsr.w   Sonic_LevelBound                ; keep Sonic within level bounds and handle bottomless pits
                jsr     (ObjectMove).l                  ; update Sonic's position based on his current velocities
                bsr.w   AnglePos                        ; update Sonic's current angle as he walks along the floor
                bsr.w   Sonic_SlopeRepel                ; handle Sonic detaching from walls if not fast enough
                rts
; End of subroutine Obj01_MdRoll
; ===========================================================================
; Start of subroutine Obj01_MdJump
; Called if Sonic is in a ball and airborne (he could be jumping but not necessarily)
; Notes: This is identical to Obj01_MdAir, at least at this outer level
; Why they gave it a separate copy of the code, I don't know
; loc_1A330: Obj01_MdJump2:
Obj01_MdJump:
                bsr.w   Sonic_JumpHeight                ; handle Sonic's jump height based on whether the jump button is still held
                bsr.w   Sonic_ChgJumpDir                ; handle midair direction adjustments while jumping
                bsr.w   Sonic_LevelBound                ; keep Sonic within level bounds and handle bottomless pits
                jsr     (ObjectMoveAndFall).l           ; apply gravity and update Sonic's position based on his current velocities
                btst    #status.player.underwater,status(a0)  ; is Sonic underwater?
                beq.s   +                               ; if not, branch
                subi.w  #$28,y_vel(a0)                  ; reduce gravity by $28 ($38-$28=$10)
+
                bsr.w   Sonic_JumpAngle                 ; steadily return Sonic's angle while jumping to 0
                bsr.w   Sonic_DoLevelCollision          ; handle collision with level while airborne
                rts
; End of subroutine Obj01_MdJump

; ---------------------------------------------------------------------------
; Subroutine to make Sonic walk/run
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; loc_1A35A:
