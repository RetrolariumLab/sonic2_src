Obj3F:
                moveq   #0,d0
                move.b  routine(a0),d0
                move.w  Obj3F_Index(pc,d0.w),d1
                jmp     Obj3F_Index(pc,d1.w)
; ===========================================================================
; off_2A7BE:
Obj3F_Index:    offsetTable
                offsetTableEntry.w Obj3F_Init           ; 0
                offsetTableEntry.w Obj3F_Horizontal     ; 2 - pushes horizontally
                offsetTableEntry.w Obj3F_Vertical       ; 4 - pushes vertically
; ===========================================================================
; loc_2A7C4:
Obj3F_Init:
                addq.b  #2,routine(a0)
                move.l  #Obj3F_MapUnc_2AA12,mappings(a0)
                move.w  #make_art_tile(ArtTile_ArtNem_OOZFanHoriz,3,0),art_tile(a0)
                jsrto   JmpTo48_Adjust2PArtPointer
                ori.b   #1<<render_flags.level_fg,render_flags(a0)
                move.b  #$10,width_pixels(a0)
                move.b  #4,priority(a0)
                tst.b   subtype(a0)
                bpl.s   Obj3F_Horizontal
                addq.b  #2,routine(a0)
                move.l  #Obj3F_MapUnc_2AAC4,mappings(a0)
                bra.w   Obj3F_Vertical
; ===========================================================================
; loc_2A802:
Obj3F_Horizontal:
                btst    #1,subtype(a0)
                bne.s   loc_2A82A
                subq.w  #1,objoff_30(a0)
                bpl.s   loc_2A82A
                move.w  #0,objoff_34(a0)
                move.w  #$78,objoff_30(a0)
                bchg    #0,objoff_32(a0)
                beq.s   loc_2A82A
                move.w  #$B4,objoff_30(a0)

loc_2A82A:
                tst.b   objoff_32(a0)
                beq.w   loc_2A84E
                subq.b  #1,anim_frame_duration(a0)
                bpl.s   BranchTo_JmpTo26_MarkObjGone
                cmpi.w  #$400,objoff_34(a0)
                bhs.s   BranchTo_JmpTo26_MarkObjGone
                addi.w  #$2A,objoff_34(a0)
                move.b  objoff_34(a0),anim_frame_duration(a0)
                bra.s   loc_2A86A
; ===========================================================================

loc_2A84E:
                lea     (MainCharacter).w,a1            ; a1=character
                bsr.w   OozFan_CheckHorizontalWind
                lea     (Sidekick).w,a1                 ; a1=character
                bsr.w   OozFan_CheckHorizontalWind
                subq.b  #1,anim_frame_duration(a0)
                bpl.s   BranchTo_JmpTo26_MarkObjGone
                move.b  #0,anim_frame_duration(a0)

loc_2A86A:
                addq.b  #1,anim_frame(a0)
                cmpi.b  #6,anim_frame(a0)
                blo.s   loc_2A87C
                move.b  #0,anim_frame(a0)

loc_2A87C:
                moveq   #0,d0
                btst    #0,subtype(a0)
                beq.s   loc_2A888
                moveq   #5,d0

loc_2A888:
                add.b   anim_frame(a0),d0
                move.b  d0,mapping_frame(a0)

BranchTo_JmpTo26_MarkObjGone                            ; BranchTo
                jmpto   JmpTo26_MarkObjGone
; ===========================================================================

OozFan_CheckHorizontalWind:
                cmpi.b  #4,routine(a1)
                bhs.s   OozFan_Return
                tst.b   obj_control(a1)
                bne.s   OozFan_Return
                move.w  x_pos(a1),d0
                sub.w   x_pos(a0),d0
                btst    #status.npc.x_flip,status(a0)
                bne.s   loc_2A8B4
                neg.w   d0

loc_2A8B4:
                addi.w  #$50,d0
                cmpi.w  #$F0,d0
                bhs.s   OozFan_Return
                move.w  y_pos(a1),d1
                addi.w  #$60,d1
                sub.w   y_pos(a0),d1
                bcs.s   OozFan_Return
                cmpi.w  #$70,d1
                bhs.s   OozFan_Return
                subi.w  #$50,d0
                bcc.s   loc_2A8DC
                not.w   d0
                add.w   d0,d0

loc_2A8DC:
                addi.w  #$60,d0
                btst    #status.npc.x_flip,status(a0)
                bne.s   loc_2A8EA
                neg.w   d0

loc_2A8EA:
                neg.b   d0
                asr.w   #4,d0
                btst    #0,subtype(a0)
                beq.s   loc_2A8F8
                neg.w   d0

loc_2A8F8:
                add.w   d0,x_pos(a1)

OozFan_Return:
                rts
; ===========================================================================
; loc_2A8FE:
Obj3F_Vertical:
                btst    #1,subtype(a0)
                bne.s   loc_2A926
                subq.w  #1,objoff_30(a0)
                bpl.s   loc_2A926
                move.w  #0,objoff_34(a0)
                move.w  #$78,objoff_30(a0)
                bchg    #0,objoff_32(a0)
                beq.s   loc_2A926
                move.w  #$B4,objoff_30(a0)

loc_2A926:
                tst.b   objoff_32(a0)
                beq.w   loc_2A94A
                subq.b  #1,anim_frame_duration(a0)
                bpl.s   BranchTo2_JmpTo26_MarkObjGone
                cmpi.w  #$400,objoff_34(a0)
                bhs.s   BranchTo2_JmpTo26_MarkObjGone
                addi.w  #$2A,objoff_34(a0)
                move.b  objoff_34(a0),anim_frame_duration(a0)
                bra.s   loc_2A966
; ===========================================================================

loc_2A94A:
                lea     (MainCharacter).w,a1            ; a1=character
                bsr.w   OozFan_ApplyVerticalWind
                lea     (Sidekick).w,a1                 ; a1=character
                bsr.w   OozFan_ApplyVerticalWind
                subq.b  #1,anim_frame_duration(a0)
                bpl.s   BranchTo2_JmpTo26_MarkObjGone
                move.b  #0,anim_frame_duration(a0)

loc_2A966:
                addq.b  #1,anim_frame(a0)
                cmpi.b  #6,anim_frame(a0)
                blo.s   +
                move.b  #0,anim_frame(a0)
+
                moveq   #0,d0
                btst    #0,subtype(a0)
                beq.s   +
                moveq   #5,d0
+
                add.b   anim_frame(a0),d0
                move.b  d0,mapping_frame(a0)

BranchTo2_JmpTo26_MarkObjGone                           ; BranchTo
                jmpto   JmpTo26_MarkObjGone
; ===========================================================================

OozFan_ApplyVerticalWind:
                cmpi.b  #4,routine(a1)
                bhs.s   OozFan_Return_Variant2
                tst.b   obj_control(a1)
                bne.s   OozFan_Return_Variant2
                move.w  x_pos(a1),d0
                sub.w   x_pos(a0),d0
                addi.w  #$40,d0
                cmpi.w  #$80,d0
                bhs.s   OozFan_Return_Variant2
                moveq   #0,d1
                move.b  (Oscillating_Data+$14).w,d1
                add.w   y_pos(a1),d1
                addi.w  #$60,d1
                sub.w   y_pos(a0),d1
                bcs.s   OozFan_Return_Variant2
                cmpi.w  #$90,d1
                bhs.s   OozFan_Return_Variant2
                subi.w  #$60,d1
                bcs.s   +
                not.w   d1
                add.w   d1,d1
+
                addi.w  #$60,d1
                neg.w   d1
                asr.w   #4,d1
                add.w   d1,y_pos(a1)
                bset    #status.player.in_air,status(a1)
                move.w  #0,y_vel(a1)
                move.w  #1,inertia(a1)
                tst.b   flip_angle(a1)
                bne.s   OozFan_Return_Variant2
                move.b  #1,flip_angle(a1)
                move.b  #AniIDSonAni_Walk,anim(a1)
                move.b  #$7F,flips_remaining(a1)
                move.b  #8,flip_speed(a1)

OozFan_Return_Variant2:
                rts
; ===========================================================================
; ---------------------------------------------------------------------------
; sprite mappings
; ---------------------------------------------------------------------------
; sidefacing fan
Obj3F_MapUnc_2AA12:
Map_obj3F_a:    mappingsTable
                mappingsTableEntry.w Map_obj3F_a_0016
                mappingsTableEntry.w Map_obj3F_a_0030
                mappingsTableEntry.w Map_obj3F_a_004A
                mappingsTableEntry.w Map_obj3F_a_0064
                mappingsTableEntry.w Map_obj3F_a_007E
                mappingsTableEntry.w Map_obj3F_a_0098
                mappingsTableEntry.w Map_obj3F_a_007E
                mappingsTableEntry.w Map_obj3F_a_0064
                mappingsTableEntry.w Map_obj3F_a_004A
                mappingsTableEntry.w Map_obj3F_a_0030
                mappingsTableEntry.w Map_obj3F_a_0016

Map_obj3F_a_0016:   spriteHeader
                spritePiece -$C, -$D, 1, 3, 0, 0, 0, 0, 0
                spritePiece -4, -$10, 2, 2, 7, 0, 0, 0, 0
                spritePiece -4, 0, 2, 2, 7, 0, 1, 0, 0
Map_obj3F_a_0016_End

Map_obj3F_a_0030:   spriteHeader
                spritePiece -$C, -$B, 1, 3, 0, 0, 1, 0, 0
                spritePiece -4, -$10, 2, 2, 7, 0, 0, 0, 0
                spritePiece -4, 0, 2, 2, 7, 0, 1, 0, 0
Map_obj3F_a_0030_End

Map_obj3F_a_004A:   spriteHeader
                spritePiece -$C, -$10, 1, 4, 3, 0, 0, 0, 0
                spritePiece -4, -$10, 2, 2, 7, 0, 0, 0, 0
                spritePiece -4, 0, 2, 2, 7, 0, 1, 0, 0
Map_obj3F_a_004A_End

Map_obj3F_a_0064:   spriteHeader
                spritePiece -$C, -$D, 1, 3, 0, 0, 0, 0, 0
                spritePiece -4, -$10, 2, 2, $B, 0, 0, 0, 0
                spritePiece -4, 0, 2, 2, $B, 0, 1, 0, 0
Map_obj3F_a_0064_End

Map_obj3F_a_007E:   spriteHeader
                spritePiece -$C, -$B, 1, 3, 0, 0, 1, 0, 0
                spritePiece -4, -$10, 2, 2, $B, 0, 0, 0, 0
                spritePiece -4, 0, 2, 2, $B, 0, 1, 0, 0
Map_obj3F_a_007E_End

Map_obj3F_a_0098:   spriteHeader
                spritePiece -$C, -$10, 1, 4, 3, 0, 0, 0, 0
                spritePiece -4, -$10, 2, 2, $B, 0, 0, 0, 0
                spritePiece -4, 0, 2, 2, $B, 0, 1, 0, 0
Map_obj3F_a_0098_End

                even
; upfacing fan
Obj3F_MapUnc_2AAC4:
Map_obj3F_b:    mappingsTable
                mappingsTableEntry.w Map_obj3F_b_0016
                mappingsTableEntry.w Map_obj3F_b_0030
                mappingsTableEntry.w Map_obj3F_b_004A
                mappingsTableEntry.w Map_obj3F_b_0064
                mappingsTableEntry.w Map_obj3F_b_007E
                mappingsTableEntry.w Map_obj3F_b_0098
                mappingsTableEntry.w Map_obj3F_b_007E
                mappingsTableEntry.w Map_obj3F_b_0064
                mappingsTableEntry.w Map_obj3F_b_004A
                mappingsTableEntry.w Map_obj3F_b_0030
                mappingsTableEntry.w Map_obj3F_b_0016

Map_obj3F_b_0016:   spriteHeader
                spritePiece -$D, -$C, 3, 1, $F, 0, 0, 0, 0
                spritePiece -$10, -4, 2, 2, $16, 0, 0, 0, 0
                spritePiece 0, -4, 2, 2, $16, 1, 0, 0, 0
Map_obj3F_b_0016_End

Map_obj3F_b_0030:   spriteHeader
                spritePiece -$B, -$C, 3, 1, $F, 1, 0, 0, 0
                spritePiece -$10, -4, 2, 2, $16, 0, 0, 0, 0
                spritePiece 0, -4, 2, 2, $16, 1, 0, 0, 0
Map_obj3F_b_0030_End

Map_obj3F_b_004A:   spriteHeader
                spritePiece -$10, -$C, 4, 1, $12, 0, 0, 0, 0
                spritePiece -$10, -4, 2, 2, $16, 0, 0, 0, 0
                spritePiece 0, -4, 2, 2, $16, 1, 0, 0, 0
Map_obj3F_b_004A_End

Map_obj3F_b_0064:   spriteHeader
                spritePiece -$D, -$C, 3, 1, $F, 0, 0, 0, 0
                spritePiece -$10, -4, 2, 2, $1A, 0, 0, 0, 0
                spritePiece 0, -4, 2, 2, $1A, 1, 0, 0, 0
Map_obj3F_b_0064_End

Map_obj3F_b_007E:   spriteHeader
                spritePiece -$B, -$C, 3, 1, $F, 1, 0, 0, 0
                spritePiece -$10, -4, 2, 2, $1A, 0, 0, 0, 0
                spritePiece 0, -4, 2, 2, $1A, 1, 0, 0, 0
Map_obj3F_b_007E_End

Map_obj3F_b_0098:   spriteHeader
                spritePiece -$10, -$C, 4, 1, $12, 0, 0, 0, 0
                spritePiece -$10, -4, 2, 2, $1A, 0, 0, 0, 0
                spritePiece 0, -4, 2, 2, $1A, 1, 0, 0, 0
Map_obj3F_b_0098_End

                even
; ===========================================================================

                jmpTos  JmpTo26_MarkObjGone,JmpTo48_Adjust2PArtPointer

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 85 - Spring from CNZ that you hold jump on to pull back further
; ---------------------------------------------------------------------------
; Sprite_2AB84:
