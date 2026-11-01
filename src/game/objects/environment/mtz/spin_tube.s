Obj67:
                moveq   #0,d0
                move.b  routine(a0),d0
                move.w  Obj67_Index(pc,d0.w),d1
                jsr     Obj67_Index(pc,d1.w)
                move.b  objoff_2C(a0),d0
                add.b   objoff_36(a0),d0
                beq.w   JmpTo4_MarkObjGone3
                lea     (Ani_obj67).l,a1
                jsrto   JmpTo7_AnimateSprite
                jmpto   JmpTo19_DisplaySprite

; ===========================================================================
; off_27184:
Obj67_Index:    offsetTable
                offsetTableEntry.w Obj67_Init           ; 0
                offsetTableEntry.w Obj67_Main           ; 2
; ===========================================================================
; loc_27188:
Obj67_Init:
                addq.b  #2,routine(a0)
                move.l  #Obj67_MapUnc_27548,mappings(a0)
                move.w  #make_art_tile(ArtTile_ArtNem_MtzSpinTubeFlash,3,0),art_tile(a0)
                ori.b   #1<<render_flags.level_fg,render_flags(a0)
                move.b  #$10,width_pixels(a0)
                move.b  #5,priority(a0)
; loc_271AC:
Obj67_Main:
                lea     (MainCharacter).w,a1            ; a1=character
                lea     objoff_2C(a0),a4
                bsr.s   MtzTube_DispatchTransitState
                lea     (Sidekick).w,a1                 ; a1=character
                lea     objoff_36(a0),a4

MtzTube_DispatchTransitState:
                moveq   #0,d0
                move.b  (a4),d0
                move.w  off_271CA(pc,d0.w),d0
                jmp     off_271CA(pc,d0.w)
; ===========================================================================
off_271CA:      offsetTable
                offsetTableEntry.w loc_271D0            ; 0
                offsetTableEntry.w loc_27260            ; 2
                offsetTableEntry.w loc_27294            ; 4
; ===========================================================================

loc_271D0:
                tst.w   (Debug_placement_mode).w
                bne.w   MtzSpinTube_Return
                move.w  x_pos(a1),d0
                sub.w   x_pos(a0),d0
                addq.w  #3,d0
                btst    #status.npc.x_flip,status(a0)
                beq.s   +
                addi.w  #$A,d0
+
                cmpi.w  #$10,d0
                bhs.s   MtzSpinTube_Return
                move.w  y_pos(a1),d1
                sub.w   y_pos(a0),d1
                addi.w  #$20,d1
                cmpi.w  #$40,d1
                bhs.s   MtzSpinTube_Return
                tst.b   obj_control(a1)
                bne.s   MtzSpinTube_Return
                addq.b  #2,(a4)
                move.b  #$81,obj_control(a1)
                move.b  #AniIDSonAni_Roll,anim(a1)
                move.w  #$800,inertia(a1)
                move.w  #0,x_vel(a1)
                move.w  #0,y_vel(a1)
                bclr    #status.npc.p1_pushing,status(a0)
                bclr    #status.player.pushing,status(a1)
                bset    #status.player.in_air,status(a1)
                move.w  x_pos(a0),x_pos(a1)
                move.w  y_pos(a0),y_pos(a1)
                clr.b   1(a4)
                move.w  #SndID_Roll,d0
                jsr     (PlaySound).l
                move.w  #(1<<8)|(0<<0),anim(a0)

MtzSpinTube_Return:
                rts
; ===========================================================================

loc_27260:
                move.b  1(a4),d0
                addq.b  #2,1(a4)
                jsr     (CalcSine).l
                asr.w   #5,d0
                move.w  y_pos(a0),d2
                sub.w   d0,d2
                move.w  d2,y_pos(a1)
                cmpi.b  #$80,1(a4)
                bne.s   +
                bsr.w   MtzTube_InitializePathPosition
                addq.b  #2,(a4)
                move.w  #SndID_SpindashRelease,d0
                jsr     (PlaySound).l
+
                rts
; ===========================================================================

loc_27294:
                subq.b  #1,2(a4)
                bpl.s   Obj67_MoveCharacter
                movea.l 6(a4),a2
                move.w  (a2)+,d4
                move.w  d4,x_pos(a1)
                move.w  (a2)+,d5
                move.w  d5,y_pos(a1)
                tst.b   subtype(a0)
                bpl.s   +
                subq.w  #8,a2
+
                move.l  a2,6(a4)
                subq.w  #4,4(a4)
                beq.s   loc_272EE
                move.w  (a2)+,d4
                move.w  (a2)+,d5
                move.w  #$1000,d2
                bra.w   loc_27374
; ===========================================================================
; update the position of Sonic/Tails in the MTZ tube
; loc_272C8:
Obj67_MoveCharacter:
                move.l  x_pos(a1),d2
                move.l  y_pos(a1),d3
                move.w  x_vel(a1),d0
                ext.l   d0
                asl.l   #8,d0
                add.l   d0,d2
                move.w  y_vel(a1),d0
                ext.l   d0
                asl.l   #8,d0
                add.l   d0,d3
                move.l  d2,x_pos(a1)
                move.l  d3,y_pos(a1)
                rts
; ===========================================================================

loc_272EE:
                andi.w  #$7FF,y_pos(a1)
                clr.b   (a4)
                clr.b   obj_control(a1)
                btst    #4,subtype(a0)
                bne.s   +
                move.w  #0,x_vel(a1)
                move.w  #0,y_vel(a1)
+
                rts
; ===========================================================================

MtzTube_InitializePathPosition:
                move.b  subtype(a0),d0
                bpl.s   loc_27344
                neg.b   d0
                andi.w  #$F,d0
                add.w   d0,d0
                lea     (MtzSpinTube_TubePaths).l,a2
                adda.w  (a2,d0.w),a2
                move.w  (a2)+,d0
                subq.w  #4,d0
                move.w  d0,4(a4)
                lea     (a2,d0.w),a2
                move.w  (a2)+,d4
                move.w  d4,x_pos(a1)
                move.w  (a2)+,d5
                move.w  d5,y_pos(a1)
                subq.w  #8,a2
                bra.s   loc_27368
; ===========================================================================

loc_27344:
                andi.w  #$F,d0
                add.w   d0,d0
                lea     (MtzSpinTube_TubePaths).l,a2
                adda.w  (a2,d0.w),a2
                move.w  (a2)+,4(a4)
                subq.w  #4,4(a4)
                move.w  (a2)+,d4
                move.w  d4,x_pos(a1)
                move.w  (a2)+,d5
                move.w  d5,y_pos(a1)

loc_27368:
                move.l  a2,6(a4)
                move.w  (a2)+,d4
                move.w  (a2)+,d5
                move.w  #$1000,d2

loc_27374:
                moveq   #0,d0
                move.w  d2,d3
                move.w  d4,d0
                sub.w   x_pos(a1),d0
                bge.s   loc_27384
                neg.w   d0
                neg.w   d2

loc_27384:
                moveq   #0,d1
                move.w  d5,d1
                sub.w   y_pos(a1),d1
                bge.s   loc_27392
                neg.w   d1
                neg.w   d3

loc_27392:
                cmp.w   d0,d1
                blo.s   loc_273C4
                moveq   #0,d1
                move.w  d5,d1
                sub.w   y_pos(a1),d1
                swap    d1
                divs.w  d3,d1
                moveq   #0,d0
                move.w  d4,d0
                sub.w   x_pos(a1),d0
                beq.s   loc_273B0
                swap    d0
                divs.w  d1,d0

loc_273B0:
                move.w  d0,x_vel(a1)
                move.w  d3,y_vel(a1)
                abs.w   d1
                move.w  d1,2(a4)
                rts
; ===========================================================================

loc_273C4:
                moveq   #0,d0
                move.w  d4,d0
                sub.w   x_pos(a1),d0
                swap    d0
                divs.w  d2,d0
                moveq   #0,d1
                move.w  d5,d1
                sub.w   y_pos(a1),d1
                beq.s   loc_273DE
                swap    d1
                divs.w  d0,d1

loc_273DE:
                move.w  d1,y_vel(a1)
                move.w  d2,x_vel(a1)
                abs.w   d0
                move.w  d0,2(a4)
                rts
; ===========================================================================
; MTZ tube position data
; MtzSpinTube_TubePaths:
MtzSpinTube_TubePaths:  offsetTable
                offsetTableEntry.w MtzSpinTube_TubePaths_Path0  ; 0
                offsetTableEntry.w MtzSpinTube_TubePaths_Path1  ; 1
                offsetTableEntry.w MtzSpinTube_TubePaths_Path2  ; 2
                offsetTableEntry.w MtzSpinTube_TubePaths_Path3  ; 3
                offsetTableEntry.w MtzSpinTube_TubePaths_Path4  ; 4
                offsetTableEntry.w MtzSpinTube_TubePaths_Path5  ; 5
                offsetTableEntry.w MtzSpinTube_TubePaths_Path6  ; 6
                offsetTableEntry.w MtzSpinTube_TubePaths_Path7  ; 7
                offsetTableEntry.w MtzSpinTube_TubePaths_Path8  ; 8
                offsetTableEntry.w MtzSpinTube_TubePaths_Path9  ; 9
                offsetTableEntry.w MtzSpinTube_TubePaths_Path10  ; $A
                offsetTableEntry.w MtzSpinTube_TubePaths_Path11  ; $B
                offsetTableEntry.w MtzSpinTube_TubePaths_Path12  ; $C

MtzSpinTube_TubePaths_Path0:    obj1E67Size
                dc.w    $7A8, $270
                dc.w    $750, $270
                dc.w    $740, $280
                dc.w    $740, $3E0
                dc.w    $750, $3F0
                dc.w    $7A8, $3F0
MtzSpinTube_TubePaths_Path0_End

MtzSpinTube_TubePaths_Path1:    obj1E67Size
                dc.w    $C58, $5F0
                dc.w    $E28, $5F0
MtzSpinTube_TubePaths_Path1_End

MtzSpinTube_TubePaths_Path2:    obj1E67Size
                dc.w    $1828, $6B0
                dc.w    $17D0, $6B0
                dc.w    $17C0, $6C0
                dc.w    $17C0, $7E0
                dc.w    $17B0, $7F0
                dc.w    $1758, $7F0
MtzSpinTube_TubePaths_Path2_End

MtzSpinTube_TubePaths_Path3:    obj1E67Size
                dc.w    $5D8, $370
                dc.w    $780, $370
MtzSpinTube_TubePaths_Path3_End

MtzSpinTube_TubePaths_Path4:    obj1E67Size
                dc.w    $5D8, $5F0
                dc.w    $700, $5F0
MtzSpinTube_TubePaths_Path4_End

MtzSpinTube_TubePaths_Path5:    obj1E67Size
                dc.w    $BD8, $1F0
                dc.w    $C30, $1F0
                dc.w    $C40, $1E0
                dc.w    $C40, $C0
                dc.w    $C50, $B0
                dc.w    $CA8, $B0
MtzSpinTube_TubePaths_Path5_End

MtzSpinTube_TubePaths_Path6:    obj1E67Size
                dc.w    $1728, $330
                dc.w    $15D0, $330
                dc.w    $15C0, $320
                dc.w    $15C0, $240
                dc.w    $15D0, $230
                dc.w    $1628, $230
MtzSpinTube_TubePaths_Path6_End

MtzSpinTube_TubePaths_Path7:    obj1E67Size
                dc.w    $6D8, $1F0
                dc.w    $730, $1F0
                dc.w    $740, $1E0
                dc.w    $740, $100
                dc.w    $750, $F0
                dc.w    $7A8, $F0
MtzSpinTube_TubePaths_Path7_End

MtzSpinTube_TubePaths_Path8:    obj1E67Size
                dc.w    $7D8, $330
                dc.w    $828, $330
                dc.w    $840, $340
                dc.w    $840, $458
                dc.w    $828, $470
                dc.w    $7D8, $470
MtzSpinTube_TubePaths_Path8_End

MtzSpinTube_TubePaths_Path9:    obj1E67Size
                dc.w    $FD8, $3B0
                dc.w    $1028, $3B0
                dc.w    $1040, $398
                dc.w    $1040, $2C4
                dc.w    $1058, $2B0
                dc.w    $10A8, $2B0
MtzSpinTube_TubePaths_Path9_End

MtzSpinTube_TubePaths_Path10:   obj1E67Size
                dc.w    $FD8, $4B0
                dc.w    $1028, $4B0
                dc.w    $1040, $4C0
                dc.w    $1040, $5D8
                dc.w    $1058, $5F0
                dc.w    $10A8, $5F0
MtzSpinTube_TubePaths_Path10_End

MtzSpinTube_TubePaths_Path11:   obj1E67Size
                dc.w    $2058, $430
                dc.w    $20A8, $430
                dc.w    $20C0, $418
                dc.w    $20C0, $2C0
                dc.w    $20D0, $2B0
                dc.w    $2128, $2B0
MtzSpinTube_TubePaths_Path11_End

MtzSpinTube_TubePaths_Path12:   obj1E67Size
                dc.w    $2328, $5B0
                dc.w    $22D0, $5B0
                dc.w    $22C0, $5A0
                dc.w    $22C0, $4C0
                dc.w    $22D0, $4B0
                dc.w    $2328, $4B0
MtzSpinTube_TubePaths_Path12_End
; animation script
; byte_2752E:
Ani_obj67:      offsetTable
                offsetTableEntry.w MtzSpinTube_Animation_Sequence0  ; 0
                offsetTableEntry.w MtzSpinTube_Animation_Sequence1  ; 1
MtzSpinTube_Animation_Sequence0:
                dc.b    $1F,  0,$FF
MtzSpinTube_Animation_Sequence1:
                dc.b    1,  1,  0,  0,  0,  0,  0,  1,  0,  0,  0,  1,  0,  0,  1,  0,$FE,  2
                even
; ---------------------------------------------------------------------------
; sprite mappings
; ---------------------------------------------------------------------------
Obj67_MapUnc_27548:
Map_obj67:      mappingsTable
                mappingsTableEntry.w Map_obj67_0004
                mappingsTableEntry.w Map_obj67_0006

Map_obj67_0004: spriteHeader
Map_obj67_0004_End

Map_obj67_0006: spriteHeader
                spritePiece -$14, -$20, 2, 2, 0, 0, 0, 0, 0
                spritePiece -8, -$20, 2, 2, 0, 0, 0, 0, 0
                spritePiece -$14, -$10, 2, 2, 0, 0, 0, 0, 0
                spritePiece -8, -$10, 2, 2, 0, 0, 0, 0, 0
                spritePiece -$14, 0, 2, 2, 0, 0, 0, 0, 0
                spritePiece -8, 0, 2, 2, 0, 0, 0, 0, 0
Map_obj67_0006_End

                even
; ===========================================================================

                jmpTos  JmpTo19_DisplaySprite,JmpTo7_AnimateSprite,JmpTo4_MarkObjGone3

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 68 - Block with a spike that comes out of each side sequentially from MTZ
; ---------------------------------------------------------------------------
spikearoundblock_initial_x_pos  =       objoff_30
spikearoundblock_initial_y_pos  =       objoff_32
spikearoundblock_offset         =       objoff_34       ; offset from the center
spikearoundblock_position       =       objoff_36       ; 0 = retracted or expanding, 1 = expanded or retracting
spikearoundblock_waiting        =       objoff_38       ; 0 = moving, 1 = waiting
; Sprite_27594:
