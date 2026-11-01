BuildSprites_2P:
                lea     (Sprite_Table).w,a2
                moveq   #2,d5
                moveq   #0,d4
                move.l  #$1D80F01,(a2)+                 ; mask all sprites
                move.l  #1,(a2)+
                move.l  #$1D80F02,(a2)+                 ; from 216px to 248px
                move.l  #0,(a2)+
                tst.b   (Level_started_flag).w
                beq.s   +
                jsrto   JmpTo_BuildHUD_P1
                bsr.w   BuildRings_P1
+
                lea     (Object_Display_Lists).w,a4
                moveq   #total_object_display_lists-1,d7
; loc_16982:
BuildSprites_P1_LevelLoop:
                move.w  (a4),d0                         ; does this priority level have any objects?
                beq.w   BuildSprites_P1_NextLevel       ; if not, check next one
                move.w  d0,-(sp)
                moveq   #2,d6
; loc_1698C:
BuildSprites_P1_ObjLoop:
                movea.w (a4,d6.w),a0                    ; a0=object

; These is a sanity check, to detect invalid objects which should not
; have been queued for display. S3K gets rid of this, since it
; should not be needed and it just slows this code down
                tst.b   id(a0)
                beq.w   BuildSprites_P1_NextObj

                andi.b  #~(1<<render_flags.on_screen)&$FF,render_flags(a0)
                move.b  render_flags(a0),d0
                move.b  d0,d4
                btst    #render_flags.multi_sprite,d0
                bne.w   BuildSprites_P1_MultiDraw
                andi.w  #1<<render_flags.level_fg|1<<render_flags.level_bg,d0
                beq.s   BuildSprites_P1_ScreenSpaceObj
                lea     (Camera_X_pos).w,a1
                moveq   #0,d0
                move.b  width_pixels(a0),d0
                move.w  x_pos(a0),d3
                sub.w   (a1),d3
                move.w  d3,d1
                add.w   d0,d1
                bmi.w   BuildSprites_P1_NextObj
                move.w  d3,d1
                sub.w   d0,d1
                cmpi.w  #screen_width,d1
                bge.s   BuildSprites_P1_NextObj
                addi.w  #spriteScreenPositionX(0),d3
                btst    #render_flags.explicit_height,d4
                beq.s   BuildSprites_P1_ApproxYCheck
                moveq   #0,d0
                move.b  y_radius(a0),d0
                move.w  y_pos(a0),d2
                sub.w   4(a1),d2
                move.w  d2,d1
                add.w   d0,d1
                bmi.s   BuildSprites_P1_NextObj
                move.w  d2,d1
                sub.w   d0,d1
                cmpi.w  #screen_height,d1
                bge.s   BuildSprites_P1_NextObj
                addi.w  #spriteScreenPositionY2P(0),d2
                bra.s   BuildSprites_P1_DrawSprite
; ===========================================================================
; loc_16A00:
BuildSprites_P1_ScreenSpaceObj:
                move.w  y_pixel(a0),d2
                move.w  x_pixel(a0),d3
                addi.w  #spriteScreenPositionY2P(0)-spriteScreenPositionY(0),d2  ; Rebase from 1p to 2p coordinate space
                bra.s   BuildSprites_P1_DrawSprite
; ===========================================================================
; loc_16A0E:
BuildSprites_P1_ApproxYCheck:
                move.w  y_pos(a0),d2
                sub.w   4(a1),d2
                addi.w  #spriteScreenPositionY(0),d2
                cmpi.w  #spriteScreenPositionY(0-32),d2
                blo.s   BuildSprites_P1_NextObj
                cmpi.w  #spriteScreenPositionY(screen_height+32),d2
                bhs.s   BuildSprites_P1_NextObj
                addi.w  #spriteScreenPositionY2P(0)-spriteScreenPositionY(0),d2  ; Rebase from 1p to 2p coordinate space
; loc_16A2A:
BuildSprites_P1_DrawSprite:
                movea.l mappings(a0),a1
                moveq   #0,d1
                btst    #render_flags.static_mappings,d4
                bne.s   +
                move.b  mapping_frame(a0),d1
                add.w   d1,d1
                adda.w  (a1,d1.w),a1
                move.w  (a1)+,d1
                subq.w  #1,d1
                bmi.s   ++
+
                bsr.w   DrawSprite_2P
+
                ori.b   #1<<render_flags.on_screen,render_flags(a0)
; loc_16A50:
BuildSprites_P1_NextObj:
                addq.w  #2,d6
                subq.w  #2,(sp)
                bne.w   BuildSprites_P1_ObjLoop
                addq.w  #2,sp
; loc_16A5A:
BuildSprites_P1_NextLevel:
                lea     object_display_list_size(a4),a4
                dbf     d7,BuildSprites_P1_LevelLoop
                move.b  d5,(Sprite_count).w
; Terminate the sprite list
; If the sprite list is full, then set the link field of the last
; entry to 0. Otherwise, push the next sprite offscreen and set its
; link field to 0. You might be thinking why this doesn't just do the
; first one no matter what. Well, think about what if the sprite list
; was empty: then it would access data before the start of the list
                cmpi.b  #80,d5
                bhs.s   +
                move.l  #0,(a2)
                bra.s   BuildSprites_P2
+
                move.b  #0,-5(a2)

; build sprites for player 2

; loc_16A7A:
BuildSprites_P2:
                tst.w   (Hint_flag).w                   ; has H-int occured yet?
                bne.s   BuildSprites_P2                 ; if not, wait
                lea     (Sprite_Table_P2).w,a2
                moveq   #0,d5
                moveq   #0,d4
                tst.b   (Level_started_flag).w
                beq.s   +
                jsrto   JmpTo_BuildHUD_P2
                bsr.w   BuildRings_P2
+
                lea     (Object_Display_Lists).w,a4
                moveq   #total_object_display_lists-1,d7
; loc_16A9C:
BuildSprites_P2_LevelLoop:
                move.w  (a4),d0
                beq.w   BuildSprites_P2_NextLevel
                move.w  d0,-(sp)
                moveq   #2,d6
; loc_16AA6:
BuildSprites_P2_ObjLoop:
                movea.w (a4,d6.w),a0                    ; a0=object

; These is a sanity check, to detect invalid objects which should not
; have been queued for display. S3K gets rid of this, since it
; should not be needed and it just slows this code down
                tst.b   id(a0)
                beq.w   BuildSprites_P2_NextObj

                move.b  render_flags(a0),d0
                move.b  d0,d4
                btst    #render_flags.multi_sprite,d0
                bne.w   BuildSprites_P2_MultiDraw
                andi.w  #1<<render_flags.level_fg|1<<render_flags.level_bg,d0
                beq.s   BuildSprites_P2_ScreenSpaceObj
                lea     (Camera_X_pos_P2).w,a1
                moveq   #0,d0
                move.b  width_pixels(a0),d0
                move.w  x_pos(a0),d3
                sub.w   (a1),d3
                move.w  d3,d1
                add.w   d0,d1
                bmi.w   BuildSprites_P2_NextObj
                move.w  d3,d1
                sub.w   d0,d1
                cmpi.w  #screen_width,d1
                bge.s   BuildSprites_P2_NextObj
                addi.w  #spriteScreenPositionX(0),d3
                btst    #render_flags.explicit_height,d4
                beq.s   BuildSprites_P2_ApproxYCheck
                moveq   #0,d0
                move.b  y_radius(a0),d0
                move.w  y_pos(a0),d2
                sub.w   4(a1),d2
                move.w  d2,d1
                add.w   d0,d1
                bmi.s   BuildSprites_P2_NextObj
                move.w  d2,d1
                sub.w   d0,d1
                cmpi.w  #screen_height,d1
                bge.s   BuildSprites_P2_NextObj
                addi.w  #spriteScreenPositionY2P(screen_height),d2
                bra.s   BuildSprites_P2_DrawSprite
; ===========================================================================
; loc_16B14:
BuildSprites_P2_ScreenSpaceObj:
                move.w  y_pixel(a0),d2
                move.w  x_pixel(a0),d3
                addi.w  #spriteScreenPositionY2P(screen_height)-spriteScreenPositionY(0),d2  ; Rebase from 1p to 2p coordinate space
                bra.s   BuildSprites_P2_DrawSprite
; ===========================================================================
; loc_16B22:
BuildSprites_P2_ApproxYCheck:
                move.w  y_pos(a0),d2
                sub.w   4(a1),d2
                addi.w  #spriteScreenPositionY(0),d2
                cmpi.w  #spriteScreenPositionY(0-32),d2
                blo.s   BuildSprites_P2_NextObj
                cmpi.w  #spriteScreenPositionY(screen_height+32),d2
                bhs.s   BuildSprites_P2_NextObj
                addi.w  #spriteScreenPositionY2P(screen_height)-spriteScreenPositionY(0),d2  ; Rebase from 1p to 2p coordinate space
; loc_16B3E:
BuildSprites_P2_DrawSprite:
                movea.l mappings(a0),a1
                moveq   #0,d1
                btst    #render_flags.static_mappings,d4
                bne.s   +
                move.b  mapping_frame(a0),d1
                add.w   d1,d1
                adda.w  (a1,d1.w),a1
                move.w  (a1)+,d1
                subq.w  #1,d1
                bmi.s   ++
+
                bsr.w   DrawSprite_2P
+
                ori.b   #1<<render_flags.on_screen,render_flags(a0)
; loc_16B64:
BuildSprites_P2_NextObj:
                addq.w  #2,d6
                subq.w  #2,(sp)
                bne.w   BuildSprites_P2_ObjLoop
                addq.w  #2,sp
                tst.b   (Teleport_flag).w
                bne.s   BuildSprites_P2_NextLevel
                move.w  #0,(a4)
; loc_16B78:
BuildSprites_P2_NextLevel:
                lea     object_display_list_size(a4),a4
                dbf     d7,BuildSprites_P2_LevelLoop

                move.b  d5,(Sprite_count).w
; Terminate the sprite list
; If the sprite list is full, then set the link field of the last
; entry to 0. Otherwise, push the next sprite offscreen and set its
; link field to 0. You might be thinking why this doesn't just do the
; first one no matter what. Well, think about what if the sprite list
; was empty: then it would access data before the start of the list
                cmpi.b  #80,d5
                beq.s   +
                move.l  #0,(a2)
                rts
+
                move.b  #0,-5(a2)
                rts
; ===========================================================================
; loc_16B9A:
BuildSprites_P1_MultiDraw:
                move.l  a4,-(sp)
                lea     (Camera_X_pos).w,a4
                movea.w art_tile(a0),a3
                movea.l mappings(a0),a5
                moveq   #0,d0
                move.b  mainspr_width(a0),d0
                move.w  x_pos(a0),d3
                sub.w   (a4),d3
                move.w  d3,d1
                add.w   d0,d1
                bmi.w   BuildSprites_P1_MultiDraw_NextObj
                move.w  d3,d1
                sub.w   d0,d1
                cmpi.w  #screen_width,d1
                bge.w   BuildSprites_P1_MultiDraw_NextObj
                addi.w  #spriteScreenPositionX(0),d3
                btst    #4,d4
                beq.s   +
                moveq   #0,d0
                move.b  mainspr_height(a0),d0
                move.w  y_pos(a0),d2
                sub.w   4(a4),d2
                move.w  d2,d1
                add.w   d0,d1
                bmi.w   BuildSprites_P1_MultiDraw_NextObj
                move.w  d2,d1
                sub.w   d0,d1
                cmpi.w  #screen_height,d1
                bge.w   BuildSprites_P1_MultiDraw_NextObj
                addi.w  #spriteScreenPositionY2P(0),d2
                bra.s   ++
+
                move.w  y_pos(a0),d2
                sub.w   4(a4),d2
                addi.w  #spriteScreenPositionY(0),d2
                cmpi.w  #spriteScreenPositionY(0-32),d2
                blo.s   BuildSprites_P1_MultiDraw_NextObj
                cmpi.w  #spriteScreenPositionY(screen_height+32),d2
                bhs.s   BuildSprites_P1_MultiDraw_NextObj
                addi.w  #spriteScreenPositionY2P(0)-spriteScreenPositionY(0),d2  ; Rebase from 1p to 2p coordinate space
+
                moveq   #0,d1
                move.b  mainspr_mapframe(a0),d1
                beq.s   +
                add.w   d1,d1
                movea.l a5,a1
                adda.w  (a1,d1.w),a1
                move.w  (a1)+,d1
                subq.w  #1,d1
                bmi.s   +
                move.w  d4,-(sp)
                bsr.w   ChkDrawSprite_2P
                move.w  (sp)+,d4
+
                ori.b   #1<<render_flags.on_screen,render_flags(a0)
                lea     subspr_data(a0),a6
                moveq   #0,d0
                move.b  mainspr_childsprites(a0),d0
                subq.w  #1,d0
                bcs.s   BuildSprites_P1_MultiDraw_NextObj

-               swap    d0
                move.w  (a6)+,d3
                sub.w   (a4),d3
                addi.w  #spriteScreenPositionX(0),d3
                move.w  (a6)+,d2
                sub.w   4(a4),d2
                addi.w  #spriteScreenPositionY2P(0),d2
                addq.w  #1,a6
                moveq   #0,d1
                move.b  (a6)+,d1
                add.w   d1,d1
                movea.l a5,a1
                adda.w  (a1,d1.w),a1
                move.w  (a1)+,d1
                subq.w  #1,d1
                bmi.s   +
                move.w  d4,-(sp)
                bsr.w   ChkDrawSprite_2P
                move.w  (sp)+,d4
+
                swap    d0
                dbf     d0,-
; loc_16C7E:
BuildSprites_P1_MultiDraw_NextObj:
                movea.l (sp)+,a4
                bra.w   BuildSprites_P1_NextObj
; ===========================================================================
; loc_16C84:
BuildSprites_P2_MultiDraw:
                move.l  a4,-(sp)
                lea     (Camera_X_pos_P2).w,a4
                movea.w art_tile(a0),a3
                movea.l mappings(a0),a5
                moveq   #0,d0
                move.b  mainspr_width(a0),d0
                move.w  x_pos(a0),d3
                sub.w   (a4),d3
                move.w  d3,d1
                add.w   d0,d1
                bmi.w   BuildSprites_P2_MultiDraw_NextObj
                move.w  d3,d1
                sub.w   d0,d1
                cmpi.w  #screen_width,d1
                bge.w   BuildSprites_P2_MultiDraw_NextObj
                addi.w  #spriteScreenPositionX(0),d3
                btst    #4,d4
                beq.s   +
                moveq   #0,d0
                move.b  mainspr_height(a0),d0
                move.w  y_pos(a0),d2
                sub.w   4(a4),d2
                move.w  d2,d1
                add.w   d0,d1
                bmi.w   BuildSprites_P2_MultiDraw_NextObj
                move.w  d2,d1
                sub.w   d0,d1
                cmpi.w  #screen_height,d1
                bge.w   BuildSprites_P2_MultiDraw_NextObj
                addi.w  #spriteScreenPositionY2P(screen_height),d2
                bra.s   ++
+
                move.w  y_pos(a0),d2
                sub.w   4(a4),d2
                addi.w  #spriteScreenPositionY(0),d2
                cmpi.w  #spriteScreenPositionY(0-32),d2
                blo.s   BuildSprites_P2_MultiDraw_NextObj
                cmpi.w  #spriteScreenPositionY(screen_height+32),d2
                bhs.s   BuildSprites_P2_MultiDraw_NextObj
                addi.w  #spriteScreenPositionY2P(screen_height)-spriteScreenPositionY(0),d2  ; Rebase from 1p to 2p coordinate space
+
                moveq   #0,d1
                move.b  mainspr_mapframe(a0),d1
                beq.s   +
                add.w   d1,d1
                movea.l a5,a1
                adda.w  (a1,d1.w),a1
                move.w  (a1)+,d1
                subq.w  #1,d1
                bmi.s   +
                move.w  d4,-(sp)
                bsr.w   ChkDrawSprite_2P
                move.w  (sp)+,d4
+
                ori.b   #1<<render_flags.on_screen,render_flags(a0)
                lea     subspr_data(a0),a6
                moveq   #0,d0
                move.b  mainspr_childsprites(a0),d0
                subq.w  #1,d0
                bcs.s   BuildSprites_P2_MultiDraw_NextObj

-               swap    d0
                move.w  (a6)+,d3
                sub.w   (a4),d3
                addi.w  #spriteScreenPositionX(0),d3
                move.w  (a6)+,d2
                sub.w   4(a4),d2
                addi.w  #spriteScreenPositionY2P(screen_height),d2
                addq.w  #1,a6
                moveq   #0,d1
                move.b  (a6)+,d1
                add.w   d1,d1
                movea.l a5,a1
                adda.w  (a1,d1.w),a1
                move.w  (a1)+,d1
                subq.w  #1,d1
                bmi.s   +
                move.w  d4,-(sp)
                bsr.w   ChkDrawSprite_2P
                move.w  (sp)+,d4
+
                swap    d0
                dbf     d0,-
; loc_16D68:
BuildSprites_P2_MultiDraw_NextObj:
                movea.l (sp)+,a4
                bra.w   BuildSprites_P2_NextObj

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; adjust art pointer of object at a0 for 2-player mode
; sub_16D6E:
Adjust2PArtPointer:
                tst.w   (Two_player_mode).w
                beq.s   .return
                move.w  art_tile(a0),d0
                andi.w  #tile_mask,d0
                lsr.w   #1,d0
                andi.w  #nontile_mask,art_tile(a0)
                add.w   d0,art_tile(a0)

.return:
                rts
; End of function Adjust2PArtPointer

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; adjust art pointer of object at a1 for 2-player mode
; sub_16D8A:
Adjust2PArtPointer2:
                tst.w   (Two_player_mode).w
                beq.s   .return
                move.w  art_tile(a1),d0
                andi.w  #tile_mask,d0
                lsr.w   #1,d0
                andi.w  #nontile_mask,art_tile(a1)
                add.w   d0,art_tile(a1)

.return:
                rts
; End of function Adjust2PArtPointer2

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; This check has been moved, so it is redundant
; See the bugfix under 'DrawSprite_Loop'
; sub_16DA6:
