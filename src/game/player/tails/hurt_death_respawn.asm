Obj02_Hurt:
                jsr     (ObjectMove).l
                addi.w  #$30,y_vel(a0)
                btst    #status.player.underwater,status(a0)
                beq.s   +
                subi.w  #$20,y_vel(a0)
+
                cmpi.w  #-$100,(Camera_Min_Y_pos).w
                bne.s   +
                andi.w  #$7FF,y_pos(a0)
+
                bsr.w   Tails_HurtStop
                bsr.w   Tails_LevelBound
                bsr.w   Tails_RecordPos
                bsr.w   Tails_Animate
                bsr.w   LoadTailsDynPLC
                jmp     (DisplaySprite).l
; ===========================================================================
; loc_1CC08:
Tails_HurtStop:
                move.w  (Tails_Max_Y_pos).w,d0
                addi.w  #screen_height,d0
                cmp.w   y_pos(a0),d0
                blt.w   JmpTo2_KillCharacter
                bsr.w   Tails_DoLevelCollision
                btst    #status.player.in_air,status(a0)
                bne.s   GamePlayerTailsHurtDeathRespawn_Return
                moveq   #0,d0
                move.w  d0,y_vel(a0)
                move.w  d0,x_vel(a0)
                move.w  d0,inertia(a0)
                move.b  d0,obj_control(a0)
                move.b  #AniIDSonAni_Walk,anim(a0)
                move.b  #2,routine(a0)                  ; => Obj02_Control
                move.w  #$78,invulnerable_time(a0)
                move.b  #0,spindash_flag(a0)

GamePlayerTailsHurtDeathRespawn_Return:
                rts
; ===========================================================================

; ---------------------------------------------------------------------------
; Tails when he dies
;
; ---------------------------------------------------------------------------

; loc_1CC50:
Obj02_Dead:
                bsr.w   Obj02_CheckGameOver
                jsr     (ObjectMoveAndFall).l
                bsr.w   Tails_RecordPos
                bsr.w   Tails_Animate
                bsr.w   LoadTailsDynPLC
                jmp     (DisplaySprite).l

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; loc_1CC6C:
Obj02_CheckGameOver:
                cmpi.w  #2,(Player_mode).w              ; is it a Tails Alone game?
                beq.w   CheckGameOver                   ; if yes, branch... goodness, code reuse
                move.b  #1,(Scroll_lock_P2).w
                move.b  #0,spindash_flag(a0)
                move.w  (Tails_Max_Y_pos).w,d0
                addi.w  #$100,d0
                cmp.w   y_pos(a0),d0
                bge.w   GamePlayerTailsHurtDeathRespawn_Return_Variant2
                move.b  #2,routine(a0)
                tst.w   (Two_player_mode).w
                bne.s   Obj02_CheckGameOver_2Pmode
                bra.w   TailsCPU_Despawn
; ---------------------------------------------------------------------------
; loc_1CCA2:
Obj02_CheckGameOver_2Pmode:
                addq.b  #1,(Update_HUD_lives_2P).w
                subq.b  #1,(Life_count_2P).w
                bne.s   Obj02_ResetLevel
                move.w  #0,restart_countdown(a0)
                move.b  #ObjID_GameOver,(GameOver_GameText+id).w  ; load Obj39
                move.b  #ObjID_GameOver,(GameOver_OverText+id).w  ; load Obj39
                move.b  #1,(GameOver_OverText+mapping_frame).w
                move.w  a0,(GameOver_GameText+parent).w
                clr.b   (Time_Over_flag_2P).w
; loc_1CCCC:
Obj02_Finished:
                clr.b   (Update_HUD_timer).w
                clr.b   (Update_HUD_timer_2P).w
                move.b  #8,routine(a0)
                move.w  #MusID_GameOver,d0
                jsr     (PlayMusic).l
                moveq   #PLCID_GameOver,d0
                jmp     (LoadPLC).l
; End of function Obj02_CheckGameOver

; ===========================================================================
; ---------------------------------------------------------------------------
; Tails when the level is restarted
; ---------------------------------------------------------------------------
; loc_1CCEC:
Obj02_ResetLevel:
                tst.b   (Time_Over_flag).w

                if      gameRevision=0
                bne.s   Obj02_ResetLevel_Part3
                else
                beq.s   Obj02_ResetLevel_Part2
                tst.b   (Time_Over_flag_2P).w
                beq.s   Obj02_ResetLevel_Part3
                move.w  #0,restart_countdown(a0)
                clr.b   (Update_HUD_timer).w
                clr.b   (Update_HUD_timer_2P).w
                move.b  #8,routine(a0)
                rts
                endif

; ---------------------------------------------------------------------------
Obj02_ResetLevel_Part2:
                tst.b   (Time_Over_flag_2P).w
                beq.s   Obj02_ResetLevel_Part3
                move.w  #0,restart_countdown(a0)
                move.b  #ObjID_TimeOver,(TimeOver_TimeText+id).w  ; load Obj39
                move.b  #ObjID_TimeOver,(TimeOver_OverText+id).w  ; load Obj39
                move.b  #2,(TimeOver_TimeText+mapping_frame).w
                move.b  #3,(TimeOver_OverText+mapping_frame).w
                move.w  a0,(TimeOver_TimeText+parent).w
                bra.s   Obj02_Finished
; ---------------------------------------------------------------------------
Obj02_ResetLevel_Part3:
                move.b  #0,(Scroll_lock_P2).w
                move.b  #$A,routine(a0)                 ; => Obj02_Respawning
                move.w  (Saved_x_pos_2P).w,x_pos(a0)
                move.w  (Saved_y_pos_2P).w,y_pos(a0)
                move.w  (Saved_art_tile_2P).w,art_tile(a0)
                move.w  (Saved_Solid_bits_2P).w,top_solid_bit(a0)
                clr.w   (Ring_count_2P).w
                clr.b   (Extra_life_flags_2P).w
                move.b  #0,obj_control(a0)
                move.b  #5,anim(a0)
                move.w  #0,x_vel(a0)
                move.w  #0,y_vel(a0)
                move.w  #0,inertia(a0)
                move.b  #1<<status.player.in_air,status(a0)
                move.w  #0,move_lock(a0)

GamePlayerTailsHurtDeathRespawn_Return_Variant2:
                rts
; ===========================================================================
; ---------------------------------------------------------------------------
; Tails when he's offscreen and waiting for the level to restart
; ---------------------------------------------------------------------------
; loc_1CD90:
Obj02_Gone:
                tst.w   restart_countdown(a0)
                beq.s   +
                subq.w  #1,restart_countdown(a0)
                bne.s   +
                move.w  #1,(Level_Inactive_flag).w
+
                rts
; ===========================================================================
; ---------------------------------------------------------------------------
; Tails when he's waiting for the camera to scroll back to where he respawned
; ---------------------------------------------------------------------------
; loc_1CDA4:
Obj02_Respawning:
                tst.w   (Camera_X_pos_diff_P2).w
                bne.s   +
                tst.w   (Camera_Y_pos_diff_P2).w
                bne.s   +
                move.b  #2,routine(a0)
+
                bsr.w   Tails_Animate
                bsr.w   LoadTailsDynPLC
                jmp     (DisplaySprite).l
; ===========================================================================

; ---------------------------------------------------------------------------
; Subroutine to animate Tails' sprites
; See also: AnimateSprite and Sonic_Animate
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; loc_1CDC4:
