Obj8A:                                                  ; (screen-space obj)
                moveq   #0,d0
                move.b  routine(a0),d0
                move.w  Obj8A_Index(pc,d0.w),d1
                jmp     Obj8A_Index(pc,d1.w)
; ===========================================================================
; off_3EAD6:
Obj8A_Index:    offsetTable
                offsetTableEntry.w Obj8A_Init
                offsetTableEntry.w Obj8A_Display
; ===========================================================================
; loc_3EADA:
Obj8A_Init:
                addq.b  #2,routine(a0)
                move.w  #spriteScreenPositionXCentered(0),x_pixel(a0)
                move.w  #spriteScreenPositionYCentered(0),y_pixel(a0)
                move.l  #Obj8A_MapUnc_3EB4E,mappings(a0)
                move.w  #make_art_tile($05A0,0,0),art_tile(a0)
                jsrto   JmpTo65_Adjust2PArtPointer
                move.w  (Ending_demo_number).w,d0
                move.b  d0,mapping_frame(a0)
                move.b  #0,render_flags(a0)
                move.b  #0,priority(a0)
                cmpi.b  #GameModeID_TitleScreen,(Game_Mode).w  ; title screen??
                bne.s   Obj8A_Display                   ; if not, branch
                move.w  #make_art_tile($0300,0,0),art_tile(a0)
                jsrto   JmpTo65_Adjust2PArtPointer
                move.b  #$A,mapping_frame(a0)
                tst.b   (S1_hidden_credits_flag).w
                beq.s   Obj8A_Display
                cmpi.b  #button_down_mask|button_B_mask|button_C_mask|button_A_mask,(Ctrl_1_Held).w
                bne.s   Obj8A_Display
                move.w  #$EEE,(Target_palette_line3).w
                move.w  #$880,(Target_palette_line3+2).w
                jmp     (DeleteObject).l
; ===========================================================================
; JmpTo46_DisplaySprite
Obj8A_Display:
                jmp     (DisplaySprite).l
; ===========================================================================
; ----------------------------------------------------------------------------
; sprite mappings (unused?)
; ----------------------------------------------------------------------------
Obj8A_MapUnc_3EB4E:
Map_obj8A:      mappingsTable
                mappingsTableEntry.w Map_obj8A_0016
                mappingsTableEntry.w Map_obj8A_0088
                mappingsTableEntry.w Map_obj8A_010A
                mappingsTableEntry.w Map_obj8A_015C
                mappingsTableEntry.w Map_obj8A_021E
                mappingsTableEntry.w Map_obj8A_02C0
                mappingsTableEntry.w Map_obj8A_0392
                mappingsTableEntry.w Map_obj8A_044C
                mappingsTableEntry.w Map_obj8A_0546
                mappingsTableEntry.w Map_obj8A_05C0
                mappingsTableEntry.w Map_obj8A_0602

Map_obj8A_0016: spriteHeader
                spritePiece -$78, -8, 2, 2, $2E, 0, 0, 0, 0
                spritePiece -$68, -8, 2, 2, $26, 0, 0, 0, 0
                spritePiece -$58, -8, 2, 2, $1A, 0, 0, 0, 0
                spritePiece -$48, -8, 1, 2, $46, 0, 0, 0, 0
                spritePiece -$40, -8, 2, 2, $1E, 0, 0, 0, 0
                spritePiece -$28, -8, 2, 2, $3E, 0, 0, 0, 0
                spritePiece -$18, -8, 2, 2, $E, 0, 0, 0, 0
                spritePiece -8, -8, 2, 2, 4, 0, 0, 0, 0
                spritePiece 8, -8, 3, 2, 8, 0, 0, 0, 0
                spritePiece $28, -8, 2, 2, $2E, 0, 0, 0, 0
                spritePiece $38, -8, 2, 2, $3E, 0, 0, 0, 0
                spritePiece $48, -8, 2, 2, 4, 0, 0, 0, 0
                spritePiece $58, -8, 2, 2, $5C, 0, 0, 0, 0
                spritePiece $68, -8, 2, 2, $5C, 0, 0, 0, 0
Map_obj8A_0016_End

Map_obj8A_0088: spriteHeader
                spritePiece -$80, -$28, 2, 2, 0, 0, 0, 0, 0
                spritePiece -$70, -$28, 2, 2, 4, 0, 0, 0, 0
                spritePiece -$60, -$28, 3, 2, 8, 0, 0, 0, 0
                spritePiece -$4C, -$28, 2, 2, $E, 0, 0, 0, 0
                spritePiece -$30, -$28, 2, 2, $12, 0, 0, 0, 0
                spritePiece -$20, -$28, 2, 2, $16, 0, 0, 0, 0
                spritePiece -$10, -$28, 2, 2, 4, 0, 0, 0, 0
                spritePiece 0, -$28, 2, 2, $1A, 0, 0, 0, 0
                spritePiece -$38, 8, 2, 2, $1E, 0, 0, 0, 0
                spritePiece -$28, 8, 2, 2, 4, 0, 0, 0, 0
                spritePiece -$18, 8, 2, 2, $22, 0, 0, 0, 0
                spritePiece -8, 8, 2, 2, $26, 0, 0, 0, 0
                spritePiece 8, 8, 2, 2, $16, 0, 0, 0, 0
                spritePiece $20, 8, 2, 2, $2A, 0, 0, 0, 0
                spritePiece $30, 8, 2, 2, 4, 0, 0, 0, 0
                spritePiece $44, 8, 2, 2, $2E, 0, 0, 0, 0
Map_obj8A_0088_End

Map_obj8A_010A: spriteHeader
                spritePiece -$80, -$28, 2, 2, $12, 0, 0, 0, 0
                spritePiece -$70, -$28, 2, 2, $22, 0, 0, 0, 0
                spritePiece -$60, -$28, 2, 2, $26, 0, 0, 0, 0
                spritePiece -$50, -$28, 2, 2, 0, 0, 0, 0, 0
                spritePiece -$40, -$28, 2, 2, $22, 0, 0, 0, 0
                spritePiece -$30, -$28, 2, 2, 4, 0, 0, 0, 0
                spritePiece -$20, -$28, 3, 2, 8, 0, 0, 0, 0
                spritePiece -$18, 8, 2, 2, $2A, 0, 0, 0, 0
                spritePiece -8, 8, 2, 2, $32, 0, 0, 0, 0
                spritePiece 8, 8, 2, 2, $36, 0, 0, 0, 0
Map_obj8A_010A_End

Map_obj8A_015C: spriteHeader
                spritePiece -$78, -$28, 2, 2, $1E, 0, 0, 0, 0
                spritePiece -$68, -$28, 2, 2, $3A, 0, 0, 0, 0
                spritePiece -$58, -$28, 2, 2, 4, 0, 0, 0, 0
                spritePiece -$48, -$28, 2, 2, $22, 0, 0, 0, 0
                spritePiece -$38, -$28, 2, 2, 4, 0, 0, 0, 0
                spritePiece -$28, -$28, 2, 2, $1E, 0, 0, 0, 0
                spritePiece -$18, -$28, 2, 2, $3E, 0, 0, 0, 0
                spritePiece -8, -$28, 2, 2, $E, 0, 0, 0, 0
                spritePiece 8, -$28, 2, 2, $22, 0, 0, 0, 0
                spritePiece $20, -$28, 2, 2, $42, 0, 0, 0, 0
                spritePiece $30, -$28, 2, 2, $E, 0, 0, 0, 0
                spritePiece $40, -$28, 2, 2, $2E, 0, 0, 0, 0
                spritePiece $50, -$28, 1, 2, $46, 0, 0, 0, 0
                spritePiece $58, -$28, 2, 2, 0, 0, 0, 0, 0
                spritePiece $68, -$28, 2, 2, $1A, 0, 0, 0, 0
                spritePiece -$40, 8, 2, 2, $48, 0, 0, 0, 0
                spritePiece -$30, 8, 1, 2, $46, 0, 0, 0, 0
                spritePiece -$28, 8, 2, 2, 0, 0, 0, 0, 0
                spritePiece -$18, 8, 1, 2, $46, 0, 0, 0, 0
                spritePiece -$10, 8, 2, 2, $2E, 0, 0, 0, 0
                spritePiece 0, 8, 2, 2, $16, 0, 0, 0, 0
                spritePiece $10, 8, 2, 2, 4, 0, 0, 0, 0
                spritePiece $20, 8, 2, 2, $1A, 0, 0, 0, 0
                spritePiece $30, 8, 2, 2, $42, 0, 0, 0, 0
Map_obj8A_015C_End

Map_obj8A_021E: spriteHeader
                spritePiece -$60, -$30, 2, 2, $42, 0, 0, 0, 0
                spritePiece -$50, -$30, 2, 2, $E, 0, 0, 0, 0
                spritePiece -$40, -$30, 2, 2, $2E, 0, 0, 0, 0
                spritePiece -$30, -$30, 1, 2, $46, 0, 0, 0, 0
                spritePiece -$28, -$30, 2, 2, 0, 0, 0, 0, 0
                spritePiece -$18, -$30, 2, 2, $1A, 0, 0, 0, 0
                spritePiece -$18, 0, 2, 2, $4C, 0, 0, 0, 0
                spritePiece -8, 0, 1, 2, $46, 0, 0, 0, 0
                spritePiece 4, 0, 2, 2, $1A, 0, 0, 0, 0
                spritePiece $14, 0, 2, 2, $2A, 0, 0, 0, 0
                spritePiece $24, 0, 2, 2, 4, 0, 0, 0, 0
                spritePiece -$30, $20, 2, 2, $12, 0, 0, 0, 0
                spritePiece -$20, $20, 2, 2, $3A, 0, 0, 0, 0
                spritePiece -$10, $20, 2, 2, $E, 0, 0, 0, 0
                spritePiece 0, $20, 2, 2, $1A, 0, 0, 0, 0
                spritePiece $10, $20, 1, 2, $46, 0, 0, 0, 0
                spritePiece $18, $20, 2, 2, $50, 0, 0, 0, 0
                spritePiece $30, $20, 2, 2, $22, 0, 0, 0, 0
                spritePiece $40, $20, 1, 2, $46, 0, 0, 0, 0
                spritePiece $48, $20, 2, 2, $E, 0, 0, 0, 0
Map_obj8A_021E_End

Map_obj8A_02C0: spriteHeader
                spritePiece -$68, -$28, 2, 2, $2E, 0, 0, 0, 0
                spritePiece -$58, -$28, 2, 2, $26, 0, 0, 0, 0
                spritePiece -$48, -$28, 2, 2, $32, 0, 0, 0, 0
                spritePiece -$38, -$28, 2, 2, $1A, 0, 0, 0, 0
                spritePiece -$28, -$28, 2, 2, $54, 0, 0, 0, 0
                spritePiece -8, -$28, 2, 2, $12, 0, 0, 0, 0
                spritePiece 8, -$28, 2, 2, $22, 0, 0, 0, 0
                spritePiece $18, -$28, 2, 2, $26, 0, 0, 0, 0
                spritePiece $28, -$28, 2, 2, $42, 0, 0, 0, 0
                spritePiece $38, -$28, 2, 2, $32, 0, 0, 0, 0
                spritePiece $48, -$28, 2, 2, $1E, 0, 0, 0, 0
                spritePiece $58, -$28, 2, 2, $E, 0, 0, 0, 0
                spritePiece -$78, 8, 3, 2, 8, 0, 0, 0, 0
                spritePiece -$64, 8, 2, 2, 4, 0, 0, 0, 0
                spritePiece -$54, 8, 2, 2, $2E, 0, 0, 0, 0
                spritePiece -$44, 8, 2, 2, 4, 0, 0, 0, 0
                spritePiece -$34, 8, 2, 2, $3E, 0, 0, 0, 0
                spritePiece -$24, 8, 2, 2, $26, 0, 0, 0, 0
                spritePiece -8, 8, 2, 2, $1A, 0, 0, 0, 0
                spritePiece 8, 8, 2, 2, 4, 0, 0, 0, 0
                spritePiece $18, 8, 2, 2, $58, 0, 0, 0, 0
                spritePiece $28, 8, 2, 2, 4, 0, 0, 0, 0
                spritePiece $38, 8, 3, 2, 8, 0, 0, 0, 0
                spritePiece $4C, 8, 2, 2, $32, 0, 0, 0, 0
                spritePiece $5C, 8, 2, 2, $22, 0, 0, 0, 0
                spritePiece $6C, 8, 2, 2, 4, 0, 0, 0, 0
Map_obj8A_02C0_End

Map_obj8A_0392: spriteHeader
                spritePiece -$68, -$30, 2, 2, $2E, 0, 0, 0, 0
                spritePiece -$58, -$30, 2, 2, $26, 0, 0, 0, 0
                spritePiece -$48, -$30, 2, 2, $32, 0, 0, 0, 0
                spritePiece -$38, -$30, 2, 2, $1A, 0, 0, 0, 0
                spritePiece -$28, -$30, 2, 2, $54, 0, 0, 0, 0
                spritePiece -8, -$30, 2, 2, $12, 0, 0, 0, 0
                spritePiece 8, -$30, 2, 2, $22, 0, 0, 0, 0
                spritePiece $18, -$30, 2, 2, $26, 0, 0, 0, 0
                spritePiece $28, -$30, 2, 2, 0, 0, 0, 0, 0
                spritePiece $38, -$30, 2, 2, $22, 0, 0, 0, 0
                spritePiece $48, -$30, 2, 2, 4, 0, 0, 0, 0
                spritePiece $58, -$30, 3, 2, 8, 0, 0, 0, 0
                spritePiece -$30, 0, 2, 2, $4C, 0, 0, 0, 0
                spritePiece -$20, 0, 1, 2, $46, 0, 0, 0, 0
                spritePiece -$18, 0, 3, 2, 8, 0, 0, 0, 0
                spritePiece -4, 0, 1, 2, $46, 0, 0, 0, 0
                spritePiece 4, 0, 2, 2, $3E, 0, 0, 0, 0
                spritePiece $14, 0, 2, 2, 4, 0, 0, 0, 0
                spritePiece -$30, $20, 3, 2, 8, 0, 0, 0, 0
                spritePiece -$1C, $20, 2, 2, 4, 0, 0, 0, 0
                spritePiece -$C, $20, 2, 2, $1E, 0, 0, 0, 0
                spritePiece 4, $20, 2, 2, $58, 0, 0, 0, 0
                spritePiece $14, $20, 2, 2, $2A, 0, 0, 0, 0
Map_obj8A_0392_End

Map_obj8A_044C: spriteHeader
                spritePiece -$80, -$28, 2, 2, $2E, 0, 0, 0, 0
                spritePiece -$70, -$28, 2, 2, $12, 0, 0, 0, 0
                spritePiece -$60, -$28, 2, 2, $E, 0, 0, 0, 0
                spritePiece -$50, -$28, 2, 2, $1E, 0, 0, 0, 0
                spritePiece -$40, -$28, 1, 2, $46, 0, 0, 0, 0
                spritePiece -$38, -$28, 2, 2, 4, 0, 0, 0, 0
                spritePiece -$28, -$28, 2, 2, $16, 0, 0, 0, 0
                spritePiece -8, -$28, 2, 2, $3E, 0, 0, 0, 0
                spritePiece 8, -$28, 2, 2, $3A, 0, 0, 0, 0
                spritePiece $18, -$28, 2, 2, 4, 0, 0, 0, 0
                spritePiece $28, -$28, 2, 2, $1A, 0, 0, 0, 0
                spritePiece $38, -$28, 2, 2, $58, 0, 0, 0, 0
                spritePiece $48, -$28, 2, 2, $2E, 0, 0, 0, 0
                spritePiece -$50, 0, 2, 2, $5C, 0, 0, 0, 0
                spritePiece -$40, 0, 2, 2, $32, 0, 0, 0, 0
                spritePiece -$30, 0, 2, 2, $4C, 0, 0, 0, 0
                spritePiece -$20, 0, 1, 2, $46, 0, 0, 0, 0
                spritePiece -$18, 0, 2, 2, $26, 0, 0, 0, 0
                spritePiece 0, 0, 3, 2, 8, 0, 0, 0, 0
                spritePiece $14, 0, 1, 2, $46, 0, 0, 0, 0
                spritePiece $1C, 0, 2, 2, $1A, 0, 0, 0, 0
                spritePiece $2C, 0, 2, 2, $E, 0, 0, 0, 0
                spritePiece $3C, 0, 2, 2, 0, 0, 0, 0, 0
                spritePiece $4C, 0, 1, 2, $46, 0, 0, 0, 0
                spritePiece $54, 0, 2, 2, $2E, 0, 0, 0, 0
                spritePiece $64, 0, 2, 2, $3A, 0, 0, 0, 0
                spritePiece $74, 0, 1, 2, $46, 0, 0, 0, 0
                spritePiece -8, $20, 2, 2, $12, 0, 0, 0, 0
                spritePiece 8, $20, 2, 2, 4, 0, 0, 0, 0
                spritePiece $18, $20, 2, 2, $12, 0, 0, 0, 0
                spritePiece $28, $20, 2, 2, 4, 0, 0, 0, 0
Map_obj8A_044C_End

Map_obj8A_0546: spriteHeader
                spritePiece -$80, -8, 2, 2, $12, 0, 0, 0, 0
                spritePiece -$70, -8, 2, 2, $22, 0, 0, 0, 0
                spritePiece -$60, -8, 2, 2, $E, 0, 0, 0, 0
                spritePiece -$50, -8, 2, 2, $2E, 0, 0, 0, 0
                spritePiece -$40, -8, 2, 2, $E, 0, 0, 0, 0
                spritePiece -$30, -8, 2, 2, $1A, 0, 0, 0, 0
                spritePiece -$20, -8, 2, 2, $3E, 0, 0, 0, 0
                spritePiece -$10, -8, 2, 2, $E, 0, 0, 0, 0
                spritePiece 0, -8, 2, 2, $42, 0, 0, 0, 0
                spritePiece $18, -8, 2, 2, $48, 0, 0, 0, 0
                spritePiece $28, -8, 2, 2, $2A, 0, 0, 0, 0
                spritePiece $40, -8, 2, 2, $2E, 0, 0, 0, 0
                spritePiece $50, -8, 2, 2, $E, 0, 0, 0, 0
                spritePiece $60, -8, 2, 2, 0, 0, 0, 0, 0
                spritePiece $70, -8, 2, 2, 4, 0, 0, 0, 0
Map_obj8A_0546_End

Map_obj8A_05C0: spriteHeader
                spritePiece -$40, $30, 2, 2, $3E, 0, 0, 0, 0
                spritePiece -$30, $30, 2, 2, $22, 0, 0, 0, 0
                spritePiece -$20, $30, 2, 2, $2A, 0, 0, 0, 0
                spritePiece -8, $30, 2, 2, 4, 0, 0, 0, 0
                spritePiece 8, $30, 2, 2, 0, 0, 0, 0, 0
                spritePiece $18, $30, 2, 2, 4, 0, 0, 0, 0
                spritePiece $28, $30, 1, 2, $46, 0, 0, 0, 0
                spritePiece $30, $30, 2, 2, $1A, 0, 0, 0, 0
Map_obj8A_05C0_End

Map_obj8A_0602: spriteHeader
                spritePiece -$4C, -$18, 2, 2, $2E, 0, 0, 0, 0
                spritePiece -$3C, -$18, 2, 2, $26, 0, 0, 0, 0
                spritePiece -$2C, -$18, 2, 2, $1A, 0, 0, 0, 0
                spritePiece -$1C, -$18, 1, 2, $46, 0, 0, 0, 0
                spritePiece -$14, -$18, 2, 2, $1E, 0, 0, 0, 0
                spritePiece 4, -$18, 2, 2, $3E, 0, 0, 0, 0
                spritePiece $14, -$18, 2, 2, $E, 0, 0, 0, 0
                spritePiece $24, -$18, 2, 2, 4, 0, 0, 0, 0
                spritePiece $34, -$18, 3, 2, 8, 0, 0, 0, 0
                spritePiece -$40, 0, 2, 2, $12, 0, 0, 0, 0
                spritePiece -$30, 0, 2, 2, $22, 0, 0, 0, 0
                spritePiece -$20, 0, 2, 2, $E, 0, 0, 0, 0
                spritePiece -$10, 0, 2, 2, $2E, 0, 0, 0, 0
                spritePiece 0, 0, 2, 2, $E, 0, 0, 0, 0
                spritePiece $10, 0, 2, 2, $1A, 0, 0, 0, 0
                spritePiece $20, 0, 2, 2, $3E, 0, 0, 0, 0
                spritePiece $30, 0, 2, 2, $2E, 0, 0, 0, 0
Map_obj8A_0602_End

                even
; ===========================================================================

                jmpTos  JmpTo65_Adjust2PArtPointer

; ===========================================================================
; ----------------------------------------------------------------------------
; Object 3E - Egg prison
; ----------------------------------------------------------------------------
; Sprite_3F1E4:
