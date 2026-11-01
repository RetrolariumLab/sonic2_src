Obj0F:
                moveq   #0,d0
                move.b  routine(a0),d0
                move.w  Obj0F_Index(pc,d0.w),d1
                jsr     Obj0F_Index(pc,d1.w)
                bra.w   DisplaySprite
; ===========================================================================
; off_13612: Obj0F_States:
Obj0F_Index:    offsetTable
                offsetTableEntry.w Obj0F_Init           ; 0
                offsetTableEntry.w Obj0F_Main           ; 2
; ===========================================================================
; loc_13616:
Obj0F_Init:
                addq.b  #2,routine(a0)                  ; => Obj0F_Main
                move.w  #spriteScreenPositionXCentered(8),x_pixel(a0)
                move.w  #spriteScreenPositionYCentered(92),y_pixel(a0)
                move.l  #Obj0F_MapUnc_13B70,mappings(a0)
                move.w  #make_art_tile(ArtTile_VRAM_Start,0,0),art_tile(a0)
                bsr.w   Adjust2PArtPointer
                andi.b  #1,(Title_screen_option).w
                move.b  (Title_screen_option).w,mapping_frame(a0)

; loc_13644:
Obj0F_Main:
                moveq   #0,d2
                move.b  (Title_screen_option).w,d2
                move.b  (Ctrl_1_Press).w,d0
                or.b    (Ctrl_2_Press).w,d0
                btst    #button_up,d0
                beq.s   +
                subq.b  #1,d2
                bcc.s   +
                move.b  #2,d2
+
                btst    #button_down,d0
                beq.s   +
                addq.b  #1,d2
                cmpi.b  #3,d2
                blo.s   +
                moveq   #0,d2
+
                move.b  d2,mapping_frame(a0)
                move.b  d2,(Title_screen_option).w
                andi.b  #button_up_mask|button_down_mask,d0
                beq.s   +                               ; rts
                moveq   #signextendB(SndID_Blip),d0     ; selection blip sound
                jsrto   JmpTo4_PlaySound
+
                rts
; ===========================================================================
; animation script
; off_13686:
Ani_obj0E:      offsetTable
                offsetTableEntry.w Ani_obj0E_Sonic      ; 0
                offsetTableEntry.w Ani_obj0E_Tails      ; 1
                offsetTableEntry.w Ani_obj0E_FlashingStar  ; 2
                offsetTableEntry.w Ani_obj0E_FallingStar  ; 3
; byte_1368E:
Ani_obj0E_Sonic:
                dc.b    1
                dc.b    5
                dc.b    6
                dc.b    7
; This appears to be a leftover prototype frame: it's a duplicate of
; frame $12, except Sonic is missing his right arm. The old frame
; being here in this animation script causes Sonic to appear with
; both of his arms missing for a single frame
                dc.b    8
                dc.b    $FA
                even
; byte_13694:
Ani_obj0E_Tails:
                dc.b    1
                dc.b    0
                dc.b    1
                dc.b    2
                dc.b    3
                dc.b    4
                dc.b    $FA
                even
; byte_1369C:
Ani_obj0E_FlashingStar:
                dc.b    1
                dc.b    $C
                dc.b    $D
                dc.b    $E
                dc.b    $D
                dc.b    $C
                dc.b    $FA
                even
; byte_136A4:
Ani_obj0E_FallingStar:
                dc.b    3
                dc.b    $C
                dc.b    $F
                dc.b    $FF
                even
; -----------------------------------------------------------------------------
; Sprite Mappings - Flashing stars from intro (Obj0E)
; -----------------------------------------------------------------------------
Obj0E_MapUnc_136A8: include "src/ui/objects/title/animations/data/mappings.s"
; -----------------------------------------------------------------------------
; sprite mappings
; -----------------------------------------------------------------------------
Obj0F_MapUnc_13B70: include "src/ui/objects/title/menu/data/mappings.s"

                jmpTos0 JmpTo4_PlaySound,JmpTo4_PlayMusic

; ===========================================================================
; ----------------------------------------------------------------------------
; Object 34 - level title card (screen with red, yellow, and blue)
; ----------------------------------------------------------------------------
titlecard_x_target      =       objoff_30               ; the X position the object will reach
titlecard_x_source      =       objoff_32               ; the X position the object starts from and will end at
titlecard_location      =       objoff_34               ; point up to which titlecard is drawn
titlecard_vram_dest     =       objoff_36               ; target of VRAM write
titlecard_vram_dest_2P  =       objoff_38               ; target of VRAM write
titlecard_split_point   =       objoff_3A               ; point to split drawing for yellow and red portions
titlecard_leaveflag     =       objoff_3E               ; whether or not titlecard is leaving screen
; Sprite_13C48:
