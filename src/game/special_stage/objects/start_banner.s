Obj5F:
                moveq   #0,d0
                move.b  routine(a0),d0
                move.w  Obj5F_Index(pc,d0.w),d1
                jmp     Obj5F_Index(pc,d1.w)
; ===========================================================================
; off_70FE:
Obj5F_Index:    offsetTable
                offsetTableEntry.w Obj5F_Init           ; 0
                offsetTableEntry.w Obj5F_Main           ; 2
                offsetTableEntry.w loc_71B4             ; 4
                offsetTableEntry.w loc_710A             ; 6
                offsetTableEntry.w StartBanner_Return   ; 8
                offsetTableEntry.w loc_7218             ; $A
; ===========================================================================

loc_710A:
                moveq   #0,d0
                move.b  angle(a0),d0
                bsr.w   CalcSine
                muls.w  objoff_14(a0),d0
                muls.w  objoff_14(a0),d1
                asr.w   #8,d0
                asr.w   #8,d1
                add.w   d1,x_pos(a0)
                add.w   d0,y_pos(a0)
                cmpi.w  #0,x_pos(a0)
                blt.w   JmpTo_DeleteObject
                cmpi.w  #$100,x_pos(a0)
                bgt.w   JmpTo_DeleteObject
                cmpi.w  #0,y_pos(a0)
                blt.w   JmpTo_DeleteObject
                jmpto   JmpTo_DisplaySprite

; ===========================================================================

; loc_714A:
Obj5F_Init:
                tst.b   (SS_2p_Flag).w
                beq.s   +
                move.w  #8,d0
                jsrto   JmpTo_Obj5A_PrintPhrase
+               move.w  #$80,x_pos(a0)
                move.w  #-$40,y_pos(a0)
                move.w  #$100,y_vel(a0)
                move.l  #Obj5F_MapUnc_7240,mappings(a0)
                move.w  #make_art_tile(ArtTile_ArtNem_SpecialStart,0,0),art_tile(a0)
                move.b  #1<<render_flags.level_fg,render_flags(a0)
                move.b  #1,priority(a0)
                move.b  #2,routine(a0)

; loc_718A:
Obj5F_Main:
                jsrto   JmpTo_ObjectMove
                cmpi.w  #$48,y_pos(a0)
                blt.w   JmpTo_DisplaySprite
                move.w  #0,y_vel(a0)
                move.w  #$48,y_pos(a0)
                move.b  #4,routine(a0)
                move.b  #$F,objoff_2A(a0)

                jmpto   JmpTo_DisplaySprite
; ===========================================================================

loc_71B4:
                subi_.b #1,objoff_2A(a0)
                bne.w   JmpTo_DisplaySprite
                moveq   #6,d6

                lea     (Obj5F_MapUnc_7240.frame2).l,a2

                moveq   #2,d3
                move.w  #8,objoff_14(a0)
                move.b  #6,routine(a0)

-               bsr.w   SSAllocateObject
                bne.s   +
                moveq   #0,d0

                move.w  #bytesToLcnt(object_size),d1

-               move.l  (a0,d0.w),(a1,d0.w)
                addq.w  #4,d0
                dbf     d1,-
                if      object_size&3
                move.w  (a0,d0.w),(a1,d0.w)
                endif

                move.b  d3,mapping_frame(a1)
                addq.w  #1,d3
                move.w  #-$28,d2
                move.w  8(a2),d1
                bsr.w   CalcAngle
                move.b  d0,angle(a1)
                lea     $A(a2),a2
+               dbf     d6,--

                move.b  #$A,routine(a0)
                move.w  #$1E,objoff_2A(a0)
                rts
; ===========================================================================

loc_7218:
                subi_.w #1,objoff_2A(a0)
                bpl.s   +++                             ; rts
                tst.b   (SS_2p_Flag).w
                beq.s   +
                move.w  #$A,d0
                jsrto   JmpTo_Obj5A_PrintPhrase
                bra.s   ++
; ===========================================================================
+               jsrto   JmpTo_Obj5A_CreateRingReqMessage

+               st.b    (SpecialStage_Started).w
                jmpto   JmpTo_DeleteObject
; ===========================================================================

+               rts
; ===========================================================================

StartBanner_Return:
                rts
; ===========================================================================
; ----------------------------------------------------------------------------
; sprite mappings
; ----------------------------------------------------------------------------
Obj5F_MapUnc_7240:
.offsets:       mappingsTable
                mappingsTableEntry.w .frame0
                mappingsTableEntry.w .frame1
                mappingsTableEntry.w .frame2
                mappingsTableEntry.w .frame3
                mappingsTableEntry.w .frame4
                mappingsTableEntry.w .frame5
                mappingsTableEntry.w .frame6
                mappingsTableEntry.w .frame7
                mappingsTableEntry.w .frame8

.frame0:        spriteHeader
                spritePiece -$48, 0, 4, 4, 0, 0, 0, 1, 1
                spritePiece -$28, 0, 2, 4, $10, 0, 0, 1, 1
                spritePiece -$18, 0, 2, 4, $18, 0, 0, 1, 1
                spritePiece -8, 0, 2, 4, $20, 0, 0, 1, 1
                spritePiece 8, 0, 2, 4, $28, 0, 0, 1, 1
                spritePiece $18, 0, 2, 4, $18, 0, 0, 1, 1
                spritePiece $28, 0, 4, 4, 0, 1, 0, 1, 1
.frame0_End

.frame2:
.frame1:        spriteHeader
                spritePiece -$48, 0, 4, 4, 0, 0, 0, 1, 1
.frame1_End

.frame3:        spriteHeader
                spritePiece -$28, 0, 2, 4, $10, 0, 0, 1, 1
.frame3_End

.frame4:        spriteHeader
                spritePiece -$18, 0, 2, 4, $18, 0, 0, 1, 1
.frame4_End

.frame5:        spriteHeader
                spritePiece -8, 0, 2, 4, $20, 0, 0, 1, 1
.frame5_End

.frame6:        spriteHeader
                spritePiece 8, 0, 2, 4, $28, 0, 0, 1, 1
.frame6_End

.frame7:        spriteHeader
                spritePiece $18, 0, 2, 4, $18, 0, 0, 1, 1
.frame7_End

.frame8:        spriteHeader
                spritePiece $28, 0, 4, 4, 0, 1, 0, 1, 1
.frame8_End

                even
; -----------------------------------------------------------------------------------
; sprite mappings
; -----------------------------------------------------------------------------------
Obj5F_MapUnc_72D2:
Map_obj5F_b:    mappingsTable
                mappingsTableEntry.w Map_obj5F_b_0016
                mappingsTableEntry.w Map_obj5F_b_0020
                mappingsTableEntry.w Map_obj5F_b_002A
                mappingsTableEntry.w Map_obj5F_b_0034
                mappingsTableEntry.w Map_obj5F_b_003E
                mappingsTableEntry.w Map_obj5F_b_0048
                mappingsTableEntry.w Map_obj5F_b_0052
                mappingsTableEntry.w Map_obj5F_b_005C
                mappingsTableEntry.w Map_obj5F_b_0066
                mappingsTableEntry.w Map_obj5F_b_0070
                mappingsTableEntry.w Map_obj5F_b_007A

Map_obj5F_b_0016:   spriteHeader
                spritePiece -4, -8, 1, 2, $12, 0, 0, 0, 1
Map_obj5F_b_0016_End

Map_obj5F_b_0020:   spriteHeader
                spritePiece -4, -8, 1, 2, $14, 0, 0, 0, 1
Map_obj5F_b_0020_End

Map_obj5F_b_002A:   spriteHeader
                spritePiece -4, -8, 1, 2, $16, 0, 0, 0, 1
Map_obj5F_b_002A_End

Map_obj5F_b_0034:   spriteHeader
                spritePiece -4, -8, 1, 2, $18, 0, 0, 0, 1
Map_obj5F_b_0034_End

Map_obj5F_b_003E:   spriteHeader
                spritePiece -4, -8, 1, 2, $1A, 0, 0, 0, 1
Map_obj5F_b_003E_End

Map_obj5F_b_0048:   spriteHeader
                spritePiece -4, -8, 1, 2, $1C, 0, 0, 0, 1
Map_obj5F_b_0048_End

Map_obj5F_b_0052:   spriteHeader
                spritePiece -4, -8, 1, 2, $1E, 0, 0, 0, 1
Map_obj5F_b_0052_End

Map_obj5F_b_005C:   spriteHeader
                spritePiece -4, -8, 1, 2, $20, 0, 0, 0, 1
Map_obj5F_b_005C_End

Map_obj5F_b_0066:   spriteHeader
                spritePiece -4, -8, 1, 2, $22, 0, 0, 0, 1
Map_obj5F_b_0066_End

Map_obj5F_b_0070:   spriteHeader
                spritePiece -4, -8, 1, 2, $24, 0, 0, 0, 1
Map_obj5F_b_0070_End

Map_obj5F_b_007A:   spriteHeader
                spritePiece -8, -4, 2, 1, $3A, 0, 0, 0, 1
Map_obj5F_b_007A_End

                even
; ===========================================================================
; ----------------------------------------------------------------------------
; Object 87 - Number of rings in Special Stage
; ----------------------------------------------------------------------------
; Sprite_7356:
