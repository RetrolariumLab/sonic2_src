Obj17:
                moveq   #0,d0
                move.b  routine(a0),d0
                move.w  Obj17_Index(pc,d0.w),d1
                jmp     Obj17_Index(pc,d1.w)
; ===========================================================================
; off_1031E:
Obj17_Index:    offsetTable
                offsetTableEntry.w Obj17_Init           ; 0
                offsetTableEntry.w Obj17_Main           ; 2
                offsetTableEntry.w Obj17_Display        ; 4
; ===========================================================================
; loc_10324: Obj17_Main:
Obj17_Init:
                addq.b  #2,routine(a0)
                move.l  #Obj17_MapUnc_10452,mappings(a0)
                move.w  #make_art_tile(ArtTile_ArtNem_GHZ_Spiked_Log,2,0),art_tile(a0)
                bsr.w   Adjust2PArtPointer
                move.b  #1<<render_flags.level_fg,render_flags(a0)
                move.b  #3,priority(a0)
                move.b  #8,width_pixels(a0)
                move.w  y_pos(a0),d2
                move.w  x_pos(a0),d3
                _move.b id(a0),d4
                lea     subtype(a0),a2                  ; move helix length to a2
                moveq   #0,d1
                move.b  (a2),d1                         ; move a2 to d1
                move.b  #0,(a2)+
                move.w  d1,d0
                lsr.w   #1,d0
                lsl.w   #4,d0
                sub.w   d0,d3
                subq.b  #2,d1
                bcs.s   Obj17_Main
                moveq   #0,d6
; loc_10372:
Obj17_MakeHelix:
                bsr.w   AllocateObjectAfterCurrent
                bne.s   Obj17_Main
                addq.b  #1,subtype(a0)
                if      object_size<>$40
                moveq   #0,d5                           ; Clear the high word for the coming division
                endif
                move.w  a1,d5
                subi.w  #Object_RAM,d5
                if      object_size=$40
                lsr.w   #object_size_bits,d5
                else
                divu.w  #object_size,d5
                endif
                andi.w  #$7F,d5
                move.b  d5,(a2)+
                move.b  #4,routine(a1)
                _move.b d4,id(a1)                       ; load obj17
                move.w  d2,y_pos(a1)
                move.w  d3,x_pos(a1)
                move.l  mappings(a0),mappings(a1)
                move.w  #make_art_tile(ArtTile_ArtNem_GHZ_Spiked_Log,2,0),art_tile(a1)
                bsr.w   Adjust2PArtPointer2
                move.b  #1<<render_flags.level_fg,render_flags(a1)
                move.b  #3,priority(a1)
                move.b  #8,width_pixels(a1)
                move.b  d6,objoff_3E(a1)
                addq.b  #1,d6
                andi.b  #7,d6
                addi.w  #$10,d3
                cmp.w   x_pos(a0),d3
                bne.s   +
                move.b  d6,objoff_3E(a0)
                addq.b  #1,d6
                andi.b  #7,d6
                addi.w  #$10,d3
                addq.b  #1,subtype(a0)
+               dbf     d1,Obj17_MakeHelix              ; repeat d1 times (helix length)

; loc_103E8: Obj17_Action:
Obj17_Main:
                bsr.w   Obj17_RotateSpike
                move.w  x_pos(a0),d0
                andi.w  #$FF80,d0
                sub.w   (Camera_X_pos_coarse).w,d0
                cmpi.w  #$280,d0
                bhi.w   Obj17_DelAll
                bra.w   DisplaySprite
; ===========================================================================
; loc_10404:
Obj17_DelAll:
                moveq   #0,d2
                lea     subtype(a0),a2                  ; move helix length to a2
                move.b  (a2)+,d2                        ; move a2 to d2
                subq.b  #2,d2
                bcs.s   BranchTo2_DeleteObject
; loc_10410:
Obj17_DelLoop:
                moveq   #0,d0
                move.b  (a2)+,d0
                if      object_size=$40
                lsl.w   #object_size_bits,d0
                else
                mulu.w  #object_size,d0
                endif
                addi.l  #Object_RAM,d0
                movea.l d0,a1                           ; a1=object
                bsr.w   DeleteObject2                   ; delete object
                dbf     d2,Obj17_DelLoop                ; repeat d2 times (helix length)
; loc_10426:
BranchTo2_DeleteObject                                  ; BranchTo
                bra.w   DeleteObject

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; sub_1042A:
Obj17_RotateSpike:
                move.b  (Logspike_anim_frame).w,d0
                move.b  #0,collision_flags(a0)          ; make object harmless
                add.b   objoff_3E(a0),d0
                andi.b  #7,d0
                move.b  d0,mapping_frame(a0)            ; change current frame
                bne.s   +                               ; rts
                move.b  #%10000100,collision_flags(a0)  ; make object harmful
+
                rts
; End of function Obj17_RotateSpike

; ===========================================================================
; loc_1044A:
Obj17_Display:
                bsr.w   Obj17_RotateSpike
                bra.w   DisplaySprite
; ===========================================================================
; -----------------------------------------------------------------------------
; sprite mappings - helix of spikes on a pole (GHZ) (unused)
; -----------------------------------------------------------------------------
Obj17_MapUnc_10452:
Map_obj17:      mappingsTable
                mappingsTableEntry.w Map_obj17_0010
                mappingsTableEntry.w Map_obj17_001A
                mappingsTableEntry.w Map_obj17_0024
                mappingsTableEntry.w Map_obj17_002E
                mappingsTableEntry.w Map_obj17_0038
                mappingsTableEntry.w Map_obj17_0042
                mappingsTableEntry.w Map_obj17_0056
                mappingsTableEntry.w Map_obj17_004C

Map_obj17_0010: spriteHeader
                spritePiece -4, -$10, 1, 2, 0, 0, 0, 0, 0
Map_obj17_0010_End

Map_obj17_001A: spriteHeader
                spritePiece -8, -$B, 2, 2, 2, 0, 0, 0, 0
Map_obj17_001A_End

Map_obj17_0024: spriteHeader
                spritePiece -8, -8, 2, 2, 6, 0, 0, 0, 0
Map_obj17_0024_End

Map_obj17_002E: spriteHeader
                spritePiece -8, -5, 2, 2, $A, 0, 0, 0, 0
Map_obj17_002E_End

Map_obj17_0038: spriteHeader
                spritePiece -4, 0, 1, 2, $E, 0, 0, 0, 0
Map_obj17_0038_End

Map_obj17_0042: spriteHeader
                spritePiece -3, 4, 1, 1, $10, 0, 0, 0, 0
Map_obj17_0042_End

Map_obj17_004C: spriteHeader
                spritePiece -3, -$C, 1, 1, $11, 0, 0, 0, 0
Map_obj17_004C_End

Map_obj17_0056: spriteHeader
Map_obj17_0056_End

                even
; ===========================================================================

                jmpTos                                  ; Empty

; ----------------------------------------------------------------------------
; Object 18 - Stationary floating platform from ARZ, EHZ and HTZ
; ----------------------------------------------------------------------------
; subtype bits: sffftttt
; t = platform behavior (see Obj18_Behaviours)
; f = sprite frame and width (indexes Obj18_InitData)
; s = solidity type ; 0 = top solid, 1 = full solid
; ----------------------------------------------------------------------------
; s and f bits are filtered out after initialization so t bits can be used
; as a secondary routine counter
; ----------------------------------------------------------------------------
obj18_y_actual  =       objoff_2C                       ; word ; unmodified y-position
obj18_x_origin  =       objoff_32                       ; word ; center point of movement
obj18_y_origin  =       objoff_34                       ; word ; ''
obj18_y_offset  =       objoff_38                       ; byte ; adjustment for sag
obj18_delay     =       objoff_3A                       ; word ; fall or rise timer

; Sprite_104AC:
