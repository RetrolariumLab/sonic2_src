Obj29:
                moveq   #0,d0
                move.b  routine(a0),d0
                move.w  Obj29_Index(pc,d0.w),d1
                jmp     Obj29_Index(pc,d1.w)
; ===========================================================================
; off_11DD4:
Obj29_Index:    offsetTable
                offsetTableEntry.w Obj29_Init           ; 0
                offsetTableEntry.w Obj29_Main           ; 2
; ===========================================================================

Obj29_Init:
                addq.b  #2,routine(a0)
                move.l  #Obj29_MapUnc_11ED0,mappings(a0)
                move.w  #make_art_tile(ArtTile_ArtNem_Numbers,0,1),art_tile(a0)
                bsr.w   Adjust2PArtPointer
                move.b  #1<<render_flags.level_fg,render_flags(a0)
                move.b  #1,priority(a0)
                move.b  #8,width_pixels(a0)
                move.w  #-$300,y_vel(a0)                ; set initial speed (upwards)

Obj29_Main:
                tst.w   y_vel(a0)                       ; test speed
                bpl.w   DeleteObject                    ; if it's positive (>= 0), delete the object
                bsr.w   ObjectMove                      ; move the points
                addi.w  #$18,y_vel(a0)                  ; slow down
                bra.w   DisplaySprite
; ===========================================================================
; -------------------------------------------------------------------------------
; sprite mappings
; -------------------------------------------------------------------------------
Obj28_MapUnc_11E1C: include "src/game/objects/items/animals/mappings.s"
; -------------------------------------------------------------------------------
; sprite mappings
; -------------------------------------------------------------------------------
Obj29_MapUnc_11ED0:
Map_obj29:      mappingsTable
                mappingsTableEntry.w Map_obj29_000E
                mappingsTableEntry.w Map_obj29_0018
                mappingsTableEntry.w Map_obj29_0022
                mappingsTableEntry.w Map_obj29_002C
                mappingsTableEntry.w Map_obj29_003E
                mappingsTableEntry.w Map_obj29_0048
                mappingsTableEntry.w Map_obj29_005A

Map_obj29_000E: spriteHeader
                spritePiece -8, -8, 2, 2, 2, 0, 0, 0, 0
Map_obj29_000E_End

Map_obj29_0018: spriteHeader
                spritePiece -8, -8, 2, 2, 6, 0, 0, 0, 0
Map_obj29_0018_End

Map_obj29_0022: spriteHeader
                spritePiece -8, -8, 2, 2, $A, 0, 0, 0, 0
Map_obj29_0022_End

Map_obj29_002C: spriteHeader
                spritePiece -8, -8, 1, 2, 0, 0, 0, 0, 0
                spritePiece 0, -8, 2, 2, $E, 0, 0, 0, 0
Map_obj29_002C_End

Map_obj29_003E: spriteHeader
                spritePiece -4, -8, 1, 2, 0, 0, 0, 0, 0
Map_obj29_003E_End

Map_obj29_0048: spriteHeader
                spritePiece -$10, -8, 2, 2, 2, 0, 0, 0, 0
                spritePiece 0, -8, 2, 2, $E, 0, 0, 0, 0
Map_obj29_0048_End

Map_obj29_005A: spriteHeader
                spritePiece -$10, -8, 2, 2, $A, 0, 0, 0, 0
                spritePiece 0, -8, 2, 2, $E, 0, 0, 0, 0
Map_obj29_005A_End

                even

                jmpTos  JmpTo_RandomNumber

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 25 - A ring (usually only placed through placement mode)
; ---------------------------------------------------------------------------
; OST Variables:
ring_base_x_pos     =       objoff_32                   ; x-position of primary ring (leftover from Sonic 1)

; Sprite_11F44: Obj_Ring:
