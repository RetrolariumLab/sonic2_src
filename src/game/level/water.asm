UpdateWaterSurface:
                tst.b   (Water_flag).w
                beq.s   ++                              ; rts
                move.w  (Camera_X_pos).w,d1
                btst    #0,(Level_frame_counter+1).w
                beq.s   +
                addi.w  #$20,d1
+                                                       ; match obj x-position to screen position
                move.w  d1,d0
                addi.w  #$60,d0
                move.w  d0,(WaterSurface1+x_pos).w
                addi.w  #$120,d1
                move.w  d1,(WaterSurface2+x_pos).w
+
                rts
; End of function UpdateWaterSurface

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; ---------------------------------------------------------------------------
; Subroutine to do special water effects
; ---------------------------------------------------------------------------
; sub_450E: ; LZWaterEffects:
WaterEffects:
                tst.b   (Water_flag).w                  ; does level have water?
                beq.s   NonWaterEffects                 ; if not, branch
                tst.b   (Deform_lock).w
                bne.s   MoveWater
                cmpi.b  #6,(MainCharacter+routine).w    ; is player dead?
                bhs.s   MoveWater                       ; if yes, branch
                bsr.w   DynamicWater
; loc_4526: ; LZMoveWater:
MoveWater:
                clr.b   (Water_fullscreen_flag).w
                moveq   #0,d0
                cmpi.b  #aquatic_ruin_zone,(Current_Zone).w  ; is level ARZ?
                beq.s   +                               ; if yes, branch
                move.b  (Oscillating_Data).w,d0
                lsr.w   #1,d0
+
                add.w   (Water_Level_2).w,d0
                move.w  d0,(Water_Level_1).w
; calculate distance between water surface and top of screen
                move.w  (Water_Level_1).w,d0
                sub.w   (Camera_Y_pos).w,d0
                bhs.s   +
                tst.w   d0
                bpl.s   +
                move.b  #screen_height-1,(Hint_counter_reserve+1).w  ; H-INT every 224th scanline
                move.b  #1,(Water_fullscreen_flag).w
+
                cmpi.w  #screen_height-1,d0
                blo.s   +
                move.w  #screen_height-1,d0
+
                move.b  d0,(Hint_counter_reserve+1).w   ; H-INT every d0 scanlines
; loc_456A:
NonWaterEffects:
                cmpi.b  #oil_ocean_zone,(Current_Zone).w  ; is the level OOZ?
                bne.s   +                               ; if not, branch
                bsr.w   OilSlides                       ; call oil slide routine
+
                cmpi.b  #wing_fortress_zone,(Current_Zone).w  ; is the level WFZ?
                bne.s   +                               ; if not, branch
                bsr.w   WindTunnel                      ; call wind and block break routine
+
                rts
; End of function WaterEffects

; ===========================================================================
; word_4584:
WaterHeight:
                dc.w    $600, $600                      ; HPZ
                dc.w    $600, $600
                dc.w    $600, $600                      ; OOZ
                dc.w    $600, $600                      ; MCZ
                dc.w    $600, $600                      ; CNZ
                dc.w    $600, $710                      ; CPZ
                dc.w    $600, $600                      ; DEZ
                dc.w    $410, $510                      ; ARZ

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; sub_45A4: ; LZDynamicWater:
DynamicWater:
                moveq   #0,d0
                move.w  (Current_ZoneAndAct).w,d0
                subi.w  #hidden_palace_zone_act_1,d0
                ror.b   #1,d0
                lsr.w   #6,d0
                andi.w  #$FFFE,d0
                move.w  Dynamic_water_routine_table(pc,d0.w),d0
                jsr     Dynamic_water_routine_table(pc,d0.w)
                moveq   #0,d1
                move.b  (Water_on).w,d1
                move.w  (Water_Level_3).w,d0
                sub.w   (Water_Level_2).w,d0
                beq.s   ++                              ; rts
                bcc.s   +
                neg.w   d1
+
                add.w   d1,(Water_Level_2).w
+
                rts
; End of function DynamicWater

; ===========================================================================
; off_45D8:
Dynamic_water_routine_table:    offsetTable
; HPZ
                offsetTableEntry.w DynamicWaterNull     ; Act 1
                offsetTableEntry.w DynamicWaterNull     ; Act 2
; Zone 9
                offsetTableEntry.w DynamicWaterNull     ; Act 1
                offsetTableEntry.w DynamicWaterNull     ; Act 2
; OOZ
                offsetTableEntry.w DynamicWaterNull     ; Act 1
                offsetTableEntry.w DynamicWaterNull     ; Act 2
; MCZ
                offsetTableEntry.w DynamicWaterNull     ; Act 1
                offsetTableEntry.w DynamicWaterNull     ; Act 2
; CNZ
                offsetTableEntry.w DynamicWaterNull     ; Act 1
                offsetTableEntry.w DynamicWaterNull     ; Act 2
; CPZ
                offsetTableEntry.w DynamicWaterNull     ; Act 1
                offsetTableEntry.w DynamicWaterCPZ2     ; Act 2
; DEZ
                offsetTableEntry.w DynamicWaterNull     ; Act 1
                offsetTableEntry.w DynamicWaterNull     ; Act 2
; ARZ
                offsetTableEntry.w DynamicWaterNull     ; Act 1
                offsetTableEntry.w DynamicWaterNull     ; Act 2
; ===========================================================================
; return_45F8:
DynamicWaterNull:
                rts
; ===========================================================================
; loc_45FA:
DynamicWaterCPZ2:
                cmpi.w  #$1DE0,(Camera_X_pos).w
                blo.s   +                               ; rts
                move.w  #$510,(Water_Level_3).w
+               rts

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||
; Equates:
windtunnel_min_x_pos    =       0
windtunnel_max_x_pos    =       4
windtunnel_min_y_pos    =       2
windtunnel_max_y_pos    =       6

; sub_460A:
