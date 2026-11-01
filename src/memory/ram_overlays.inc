; RAM variables - SEGA screen
                phase   Object_RAM                      ; Move back to the object RAM
    ; Unused slot
                ds.b    object_size
SegaScreenObject:                                       ; Sega screen
                ds.b    object_size
SegaHideTM:                                             ; Object that hides TM symbol on JP region
                ds.b    object_size
                if      * > Object_RAM_End
                fatal   "Sega screen objects exceed size of object RAM buffer."
                endif
                dephase

; RAM variables - Title screen
                phase   Object_RAM                      ; Move back to the object RAM
    ; Unused slot
                ds.b    object_size
IntroSonic:                                             ; stars on the title screen
                ds.b    object_size
IntroTails:
                ds.b    object_size
IntroFlashingStar:
TitleScreenPaletteChanger:
                ds.b    object_size
TitleScreenPaletteChanger3:
                ds.b    object_size
IntroEmblemTop:
                ds.b    object_size
IntroMaskingSprite:
                ds.b    object_size
IntroSonicHand:
                ds.b    object_size
IntroTailsHand:
                ds.b    object_size
TitleScreenPaletteChanger2:
                ds.b    object_size

                ds.b    6*object_size

TitleScreenMenu:
                ds.b    object_size
IntroFallingStar:
                ds.b    object_size
                if      * > Object_RAM_End
                fatal   "Title screen objects exceed size of object RAM buffer."
                endif
                dephase

; RAM variables - Special stage
                phase   RAM_Start                       ; Move back to start of RAM
SSRAM_ArtNem_SpecialSonicAndTails:
                ds.b    tiles_to_bytes($353)            ; $353 art blocks
SSRAM_MiscKoz_SpecialPerspective:
                ds.b    $1AFC
SSRAM_MiscNem_SpecialLevelLayout:
                ds.b    $180
                ds.b    $9C                             ; padding
SSRAM_MiscKoz_SpecialObjectLocations:
                ds.b    $1AE0
                dephase

                phase   Object_RAM                      ; Move back to the object RAM
                ds.b    object_size
                ds.b    object_size
SpecialStageHUD:                                        ; HUD in the special stage
                ds.b    object_size
SpecialStageStartBanner:
                ds.b    object_size
SpecialStageNumberOfRings:
                ds.b    object_size
SpecialStageShadow_Sonic:
                ds.b    object_size
SpecialStageShadow_Tails:
                ds.b    object_size
SpecialStageTails_Tails:
                ds.b    object_size
SS_Dynamic_Object_RAM:
                ds.b    $18*object_size
SpecialStageResults:
                ds.b    object_size
                ds.b    $C*object_size
SpecialStageResults2:
                ds.b    object_size
                ds.b    $51*object_size
SS_Dynamic_Object_RAM_End:
                if      * > Object_RAM_End
                fatal   "Special stage objects go past end of object RAM buffer."
                endif
                dephase

                phase   (SS_Shared_RAM)
    ; The special stage mode also uses the rest of the RAM for
    ; different purposes
PNT_Buffer:             ds.b    $700
PNT_Buffer_End:
SS_Horiz_Scroll_Buf_2:  HorizontalScrollBuffer

SSTrack_mappings_bitflags:          ds.l    1
SSTrack_mappings_uncompressed:      ds.l    1
SSTrack_anim:                       ds.b    1
SSTrack_last_anim_frame:            ds.b    1
SpecialStage_CurrentSegment:        ds.b    1
SSTrack_anim_frame:                 ds.b    1
SS_Alternate_PNT:                   ds.b    1
SSTrack_drawing_index:              ds.b    1
SSTrack_Orientation:                ds.b    1
SS_Alternate_HorizScroll_Buf:       ds.b    1
SSTrack_mapping_frame:              ds.b    1
SS_Last_Alternate_HorizScroll_Buf:  ds.b    1
SS_New_Speed_Factor:                ds.l    1
SS_Cur_Speed_Factor:                ds.l    1
                ds.b    5
SSTrack_duration_timer: ds.b    1
                ds.b    1
SS_player_anim_frame_timer: ds.b    1
SpecialStage_LastSegment:   ds.b    1
SpecialStage_Started:       ds.b    1
                ds.b    4
SSTrack_last_mappings_copy: ds.l    1
SSTrack_last_mappings:      ds.l    1
                ds.b    4
SSTrack_LastVScroll:    ds.w    1
                ds.b    3
SSTrack_last_mapping_frame: ds.b    1
SSTrack_mappings_RLE:       ds.l    1
SSDrawRegBuffer:            ds.w    6
SSDrawRegBuffer_End
                ds.b    2
SpecialStage_LastSegment2:  ds.b    1
SS_unk_DB4D:                ds.b    1                   ; written but never read
                ds.b    $14
SS_Ctrl_Record_Buf:
                ds.w    $10
SS_Ctrl_Record_Buf_End
SS_CurrentPerspective:          ds.l    1
SS_Check_Rings_flag:            ds.b    1
SS_Pause_Only_flag:             ds.b    1
SS_CurrentLevelObjectLocations: ds.l    1
SS_Ring_Requirement:            ds.w    1
SS_CurrentLevelLayout:          ds.l    1
                ds.b    1
SS_2P_BCD_Score:    ds.b    1
                ds.b    1
SS_NoCheckpoint_flag:   ds.b    1
                ds.b    2
SS_Checkpoint_Rainbow_flag: ds.b    1
SS_Rainbow_palette:         ds.b    1
SS_Perfect_rings_left:      ds.w    1
                ds.b    2
SS_Star_color_1:            ds.b    1
SS_Star_color_2:            ds.b    1
SS_NoCheckpointMsg_flag:    ds.b    1
                ds.b    1
SS_NoRingsTogoLifetime: ds.w    1
SS_RingsToGoBCD:        ds.w    1
SS_HideRingsToGo:       ds.b    1
SS_TriggerRingsToGo:    ds.b    1
                ds.b    $58                             ; unused

                if      * > SS_Shared_RAM_End
                fatal   "Special stage variables exceed size of shared RAM."
                endif
                dephase

                phase   Horiz_Scroll_Buf                ; Still in SS RAM
SS_Horiz_Scroll_Buf_1:  HorizontalScrollBuffer
                dephase

                phase   Boss_variables                  ; Still in SS RAM
                ds.b    4                               ; unused
SS_Offset_X:            ds.w    1
SS_Offset_Y:            ds.w    1
SS_Swap_Positions_Flag: ds.b    1

                if      * > Boss_variables_end
                fatal   "Special stage variables exceed size of boss variables."
                endif
                dephase

; RAM variables - Continue screen
                phase   Object_RAM                      ; Move back to the object RAM
    ; These two object slots are presumably used by Sonic and Tails
                ds.b    object_size
                ds.b    object_size
ContinueText:                                           ; "CONTINUE" on the Continue screen
                ds.b    object_size
ContinueIcons:                                          ; The icons in the Continue screen
                ds.b    $D*object_size
                if      * > Object_RAM_End
                fatal   "Continue screen objects exceed size of object RAM buffer."
                endif
                dephase

; RAM variables - 2P VS results screen
                phase   Object_RAM                      ; Move back to the object RAM
VSResults_HUD:                                          ; Blinking text at the bottom of the screen
                ds.b    object_size
                if      * > Object_RAM_End
                fatal   "2P VS results screen objects exceed size of object RAM buffer."
                endif
                dephase

; RAM variables - Menu screens
                phase   Object_RAM                      ; Move back to the object RAM
    ; No objects are loaded in the menu screens
                if      * > Object_RAM_End
                fatal   "Menu screen objects exceed size of object RAM buffer."
                endif
                dephase

; RAM variables - Ending sequence
                phase   Object_RAM
    ; These two object slots are presumably used by Sonic and Tails
                ds.b    object_size
                ds.b    object_size
Tails_Tails_Cutscene:                                   ; Tails' tails on the cut scene
                ds.b    object_size
EndSeqPaletteChanger:
                ds.b    object_size
CutScene:
                ds.b    object_size

                if      * > Object_RAM_End
                fatal   "Ending sequence objects exceed size of object RAM buffer."
                endif
                dephase                                 ; Stop pretending

                !org    0                               ; Reset the program counter
