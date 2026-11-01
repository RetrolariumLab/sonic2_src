Obj0B:
                moveq   #0,d0
                move.b  routine(a0),d0
                move.w  Obj0B_Index(pc,d0.w),d1
                jmp     Obj0B_Index(pc,d1.w)
; ===========================================================================
; off_200AA:
Obj0B_Index:    offsetTable
                offsetTableEntry.w Obj0B_Init           ; 0
                offsetTableEntry.w loc_20104            ; 2
                offsetTableEntry.w loc_20112            ; 4
; ===========================================================================

obj0B_duration_current  =       objoff_30
obj0B_duration_initial  =       objoff_32
obj0B_delay             =       objoff_36

; loc_200B0:
Obj0B_Init:
                addq.b  #2,routine(a0)
                move.l  #Obj0B_MapUnc_201A0,mappings(a0)
                move.w  #make_art_tile(ArtTile_ArtNem_CPZAnimatedBits,3,1),art_tile(a0)
                jsrto   JmpTo8_Adjust2PArtPointer
                ori.b   #1<<render_flags.level_fg,render_flags(a0)
                move.b  #$10,width_pixels(a0)
                move.b  #4,priority(a0)
                moveq   #0,d0
                move.b  subtype(a0),d0
                andi.w  #$F0,d0
                addi.w  #$10,d0
                move.w  d0,d1
                subq.w  #1,d0
                move.w  d0,obj0B_duration_current(a0)
                move.w  d0,obj0B_duration_initial(a0)
                moveq   #0,d0
                move.b  subtype(a0),d0
                andi.w  #$F,d0
                addq.w  #1,d0
                lsl.w   #4,d0
                move.b  d0,obj0B_delay(a0)

loc_20104:
                move.b  (Vint_runcount+3).w,d0
                add.b   obj0B_delay(a0),d0
                bne.s   loc_2013C
                addq.b  #2,routine(a0)

loc_20112:
                subq.w  #1,obj0B_duration_current(a0)
                bpl.s   loc_20130
                move.w  #$7F,obj0B_duration_current(a0)
                tst.b   anim(a0)
                beq.s   +
                move.w  obj0B_duration_initial(a0),obj0B_duration_current(a0)
+
                bchg    #0,anim(a0)

loc_20130:
                lea     (Ani_obj0B).l,a1
                jsr     (AnimateSprite).l

loc_2013C:
                tst.b   mapping_frame(a0)
                bne.s   +
                moveq   #0,d1
                move.b  width_pixels(a0),d1
                moveq   #$11,d3
                move.w  x_pos(a0),d4
                bsr.w   PlatformObject
                jmpto   JmpTo3_MarkObjGone
; ---------------------------------------------------------------------------
+
                move.b  status(a0),d0
                andi.b  #standing_mask,d0
                beq.s   BranchTo_JmpTo3_MarkObjGone
                bclr    #p1_standing_bit,status(a0)
                beq.s   +
                bclr    #status.player.on_object,(MainCharacter+status).w
                bset    #status.player.in_air,(MainCharacter+status).w
+
                bclr    #p2_standing_bit,status(a0)
                beq.s   BranchTo_JmpTo3_MarkObjGone
                bclr    #status.player.on_object,(Sidekick+status).w
                bset    #status.player.in_air,(Sidekick+status).w

BranchTo_JmpTo3_MarkObjGone                             ; BranchTo
                jmpto   JmpTo3_MarkObjGone
; ===========================================================================
; animation script
; off_2018C:
Ani_obj0B:      offsetTable
                offsetTableEntry.w CpzPipe_Animation_Sequence0  ; 0
                offsetTableEntry.w CpzPipe_Animation_Sequence1  ; 1
CpzPipe_Animation_Sequence0:
                dc.b    7,  0,  1,  2,  3,  4,$FE,  1
CpzPipe_Animation_Sequence1:
                dc.b    7,  4,  3,  2,  1,  0,$FE,  1
                even
; -------------------------------------------------------------------------------
; sprite mappings
; -------------------------------------------------------------------------------
Obj0B_MapUnc_201A0:
Map_obj0B:      mappingsTable
                mappingsTableEntry.w Map_obj0B_000A
                mappingsTableEntry.w Map_obj0B_001C
                mappingsTableEntry.w Map_obj0B_002E
                mappingsTableEntry.w Map_obj0B_0040
                mappingsTableEntry.w Map_obj0B_0052

Map_obj0B_000A: spriteHeader
                spritePiece -$10, -$10, 4, 1, 0, 0, 0, 0, 0
                spritePiece -$10, -8, 4, 3, $24, 0, 0, 0, 0
Map_obj0B_000A_End

Map_obj0B_001C: spriteHeader
                spritePiece -$10, -$18, 4, 4, 4, 0, 0, 0, 0
                spritePiece -$10, -8, 4, 3, $24, 0, 0, 0, 0
Map_obj0B_001C_End

Map_obj0B_002E: spriteHeader
                spritePiece -$10, -$C, 4, 4, $14, 0, 0, 0, 0
                spritePiece -$10, -8, 4, 3, $24, 0, 0, 0, 0
Map_obj0B_002E_End

Map_obj0B_0040: spriteHeader
                spritePiece -$10, 0, 4, 4, 4, 0, 1, 0, 0
                spritePiece -$10, -8, 4, 3, $24, 0, 0, 0, 0
Map_obj0B_0040_End

Map_obj0B_0052: spriteHeader
                spritePiece -$10, $10, 4, 1, 0, 0, 1, 0, 0
                spritePiece -$10, -8, 4, 3, $24, 0, 0, 0, 0
Map_obj0B_0052_End

                even
; ===========================================================================

                jmpTos  JmpTo3_MarkObjGone,JmpTo8_Adjust2PArtPointer

; ===========================================================================
; ----------------------------------------------------------------------------
; Object 0C - Small floating platform (unused)
; (used in CPZ in the Nick Arcade prototype)
; ----------------------------------------------------------------------------
; Sprite_20210:
