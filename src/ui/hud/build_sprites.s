BuildHUD:
                tst.w   (Ring_count).w
                beq.s   ++                              ; blink ring count if it's 0
                moveq   #0,d1
                btst    #3,(Level_frame_counter+1).w
                bne.s   +                               ; only blink on certain frames
                cmpi.b  #9,(Timer_minute).w             ; should the minutes counter blink?
                bne.s   +                               ; if not, branch
                addq.w  #2,d1                           ; set mapping frame time counter blink
+
                bra.s   ++
+
                moveq   #0,d1
                btst    #3,(Level_frame_counter+1).w
                bne.s   +                               ; only blink on certain frames
                addq.w  #1,d1                           ; set mapping frame for ring count blink
                cmpi.b  #9,(Timer_minute).w
                bne.s   +
                addq.w  #2,d1                           ; set mapping frame for double blink
+
                move.w  #spriteScreenPositionX(16),d3   ; set X pos
                move.w  #spriteScreenPositionYCentered(24),d2  ; set Y pos
                lea     (HUD_MapUnc_40A9A).l,a1
                movea.w #make_art_tile(ArtTile_ArtNem_HUD,0,1),a3  ; set art tile and flags
                add.w   d1,d1
                adda.w  (a1,d1.w),a1
                move.w  (a1)+,d1
                subq.w  #1,d1
                bmi.s   +
                jsrto   JmpTo_DrawSprite_Loop           ; draw frame
+
                rts
; End of function BuildHUD

; ===========================================================================

BuildHUD_P1:
                tst.w   (Ring_count).w
                beq.s   BuildHUD_P1_NoRings
                moveq   #0,d1
                btst    #3,(Level_frame_counter+1).w
                bne.s   +
                cmpi.b  #9,(Timer_minute).w
                bne.s   +
                addq.w  #2,d1                           ; make TIME flash
+
                bra.s   BuildHUD_P1_Continued
; ===========================================================================
; loc_40876:
BuildHUD_P1_NoRings:
                moveq   #0,d1
                btst    #3,(Level_frame_counter+1).w
                bne.s   BuildHUD_P1_Continued
                addq.w  #1,d1                           ; make RINGS flash
                cmpi.b  #9,(Timer_minute).w
                bne.s   BuildHUD_P1_Continued
                addq.w  #2,d1                           ; make TIME flash
; loc_4088C:
BuildHUD_P1_Continued:
                move.w  #spriteScreenPositionX(16),d3
                move.w  #spriteScreenPositionY2P(screen_height/2+24),d2
                lea     (HUD_MapUnc_40BEA).l,a1
                movea.w #make_art_tile_2p(ArtTile_Art_HUD_Text_2P,0,1),a3
                add.w   d1,d1
                adda.w  (a1,d1.w),a1
                move.w  (a1)+,d1
                subq.w  #1,d1
                jsrto   JmpTo_DrawSprite_2P_Loop
                move.w  #spriteScreenPositionX(56),d3
                move.w  #spriteScreenPositionY2P(screen_height/2-104),d2
                movea.w #make_art_tile_2p(ArtTile_Art_HUD_Numbers_2P,0,1),a3
                moveq   #0,d7
                move.b  (Timer_minute).w,d7
                bsr.w   Hud2P_DrawOneDigit
                bsr.w   Hud2P_DrawTimerSeparator
                moveq   #0,d7
                move.b  (Timer_second).w,d7
                bsr.w   Hud2P_DrawTwoDigits
                move.w  #spriteScreenPositionX(64),d3
                move.w  #spriteScreenPositionY2P(screen_height/2-88),d2
                movea.w #make_art_tile_2p(ArtTile_Art_HUD_Numbers_2P,0,1),a3
                moveq   #0,d7
                move.w  (Ring_count).w,d7
                bsr.w   Hud2P_DrawThreeDigits
                tst.b   (Update_HUD_timer_2P).w
                bne.s   +
                tst.b   (Update_HUD_timer).w
                beq.s   +
                move.w  #spriteScreenPositionX(144),d3
                move.w  #spriteScreenPositionY2P(screen_height/2+72),d2
                movea.w #make_art_tile_2p(ArtTile_Art_HUD_Numbers_2P,0,1),a3
                moveq   #0,d7
                move.b  (Loser_Time_Left).w,d7
                bsr.w   Hud2P_DrawTwoDigits
+
                moveq   #4,d1
                move.w  #spriteScreenPositionX(16),d3
                move.w  #spriteScreenPositionY2P(screen_height/2+24),d2
                lea     (HUD_MapUnc_40BEA).l,a1
                movea.w #make_art_tile_2p(ArtTile_Art_HUD_Text_2P,0,1),a3
                add.w   d1,d1
                adda.w  (a1,d1.w),a1
                move.w  (a1)+,d1
                subq.w  #1,d1
                jsrto   JmpTo_DrawSprite_2P_Loop
                moveq   #0,d4
                rts

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

Hud2P_DrawOneDigit:

                lea     (Hud_1).l,a4
                moveq   #Hud_1.loop_counter,d6
                bra.s   Hud2P_DrawDigitLoop
; ===========================================================================

Hud2P_DrawTwoDigits:

                lea     (Hud_10).l,a4
                moveq   #Hud_10.loop_counter,d6

Hud2P_DrawDigitLoop:

                moveq   #0,d1
                move.l  (a4)+,d4

Hud2P_SubtractDigitDivisor:
                sub.l   d4,d7
                bcs.s   Hud2P_EmitDigit
                addq.w  #1,d1
                bra.s   Hud2P_SubtractDigitDivisor
; ===========================================================================

Hud2P_EmitDigit:
                add.l   d4,d7
                lea     (HUD_MapUnc_40C82).l,a1
                add.w   d1,d1
                adda.w  (a1,d1.w),a1
                move.w  (a1)+,d1
                subq.w  #1,d1
                jsrto   JmpTo_DrawSprite_2P_Loop
                addq.w  #8,d3
                dbf     d6,Hud2P_DrawDigitLoop
                rts
; End of function Hud2P_DrawOneDigit

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

Hud2P_DrawTimerSeparator:

                moveq   #$A,d1
                lea     (HUD_MapUnc_40C82).l,a1
                add.w   d1,d1
                adda.w  (a1,d1.w),a1
                move.w  (a1)+,d1
                subq.w  #1,d1
                jsrto   JmpTo_DrawSprite_2P_Loop
                addq.w  #8,d3
                rts
; End of function Hud2P_DrawTimerSeparator

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

Hud2P_DrawThreeDigits:

                lea     (Hud_100).l,a4
                moveq   #Hud_100.loop_counter,d6

Hud2P_DrawPaddedDigitLoop:
                moveq   #0,d1
                move.l  (a4)+,d4

Hud2P_SubtractPaddedDivisor:
                sub.l   d4,d7
                bcs.s   Hud2P_CheckLeadingDigit
                addq.w  #1,d1
                bra.s   Hud2P_SubtractPaddedDivisor
; ===========================================================================

Hud2P_CheckLeadingDigit:
                add.l   d4,d7
                tst.w   d6
                beq.s   Hud2P_EmitSignificantDigit
                tst.w   d1
                beq.s   Hud2P_CheckDigitVisibility
                bset    #$1F,d6

Hud2P_CheckDigitVisibility:
                tst.l   d6
                bpl.s   Hud2P_AdvancePaddedDigit

Hud2P_EmitSignificantDigit:
                lea     (HUD_MapUnc_40C82).l,a1
                add.w   d1,d1
                adda.w  (a1,d1.w),a1
                move.w  (a1)+,d1
                subq.w  #1,d1
                jsrto   JmpTo_DrawSprite_2P_Loop

Hud2P_AdvancePaddedDigit:
                addq.w  #8,d3
                dbf     d6,Hud2P_DrawPaddedDigitLoop
                rts
; End of function Hud2P_DrawThreeDigits

; ===========================================================================

BuildHUD_P2:
                tst.w   (Ring_count_2P).w
                beq.s   BuildHUD_P2_NoRings
                moveq   #0,d1
                btst    #3,(Level_frame_counter+1).w
                bne.s   +
                cmpi.b  #9,(Timer_minute_2P).w
                bne.s   +
                addq.w  #2,d1
+
                bra.s   BuildHUD_P2_Continued
; ===========================================================================
; loc_409E2:
BuildHUD_P2_NoRings:
                moveq   #0,d1
                btst    #3,(Level_frame_counter+1).w
                bne.s   BuildHUD_P2_Continued
                addq.w  #1,d1
                cmpi.b  #9,(Timer_minute_2P).w
                bne.s   BuildHUD_P2_Continued
                addq.w  #2,d1
; loc_409F8:
BuildHUD_P2_Continued:
                move.w  #spriteScreenPositionX(16),d3
                move.w  #spriteScreenPositionY2P(screen_height/2+24)+screen_height,d2
                lea     (HUD_MapUnc_40BEA).l,a1
                movea.w #make_art_tile_2p(ArtTile_Art_HUD_Text_2P,0,1),a3
                add.w   d1,d1
                adda.w  (a1,d1.w),a1
                move.w  (a1)+,d1
                subq.w  #1,d1
                jsrto   JmpTo_DrawSprite_2P_Loop
                move.w  #spriteScreenPositionX(56),d3
                move.w  #spriteScreenPositionY2P(screen_height/2-104)+screen_height,d2
                movea.w #make_art_tile_2p(ArtTile_Art_HUD_Numbers_2P,0,1),a3
                moveq   #0,d7
                move.b  (Timer_minute_2P).w,d7
                bsr.w   Hud2P_DrawOneDigit
                bsr.w   Hud2P_DrawTimerSeparator
                moveq   #0,d7
                move.b  (Timer_second_2P).w,d7
                bsr.w   Hud2P_DrawTwoDigits
                move.w  #spriteScreenPositionX(64),d3
                move.w  #spriteScreenPositionY2P(screen_height/2-88)+screen_height,d2
                movea.w #make_art_tile_2p(ArtTile_Art_HUD_Numbers_2P,0,1),a3
                moveq   #0,d7
                move.w  (Ring_count_2P).w,d7
                bsr.w   Hud2P_DrawThreeDigits
                tst.b   (Update_HUD_timer).w
                bne.s   +
                tst.b   (Update_HUD_timer_2P).w
                beq.s   +
                move.w  #spriteScreenPositionX(144),d3
                move.w  #spriteScreenPositionY2P(screen_height/2+72)+screen_height,d2
                movea.w #make_art_tile_2p(ArtTile_Art_HUD_Numbers_2P,0,1),a3
                moveq   #0,d7
                move.b  (Loser_Time_Left).w,d7
                bsr.w   Hud2P_DrawTwoDigits
+
                moveq   #5,d1
                move.w  #spriteScreenPositionX(16),d3
                move.w  #spriteScreenPositionY2P(screen_height/2+24)+screen_height,d2
                lea     (HUD_MapUnc_40BEA).l,a1
                movea.w #make_art_tile_2p(ArtTile_ArtNem_Powerups,0,1),a3
                add.w   d1,d1
                adda.w  (a1,d1.w),a1
                move.w  (a1)+,d1
                subq.w  #1,d1
                jsrto   JmpTo_DrawSprite_2P_Loop
                moveq   #0,d4
                rts
; ===========================================================================

; sprite mappings for the HUD
; uses the art in VRAM from $D940 - $FC00
HUD_MapUnc_40A9A:   include "src/ui/hud/data/mappings_a.s"

HUD_MapUnc_40BEA:   include "src/ui/hud/data/mappings_b.s"

HUD_MapUnc_40C82:   include "src/ui/hud/data/mappings_c.s"

; ---------------------------------------------------------------------------
; Add points subroutine
; subroutine to add to Player 1's score
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; sub_40D06:
