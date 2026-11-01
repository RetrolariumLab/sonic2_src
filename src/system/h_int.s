H_Int:
                tst.w   (Hint_flag).w
                beq.w   H_Int_Done
                tst.w   (Two_player_mode).w
                beq.w   PalToCRAM
                move.w  #0,(Hint_flag).w
                move.l  a5,-(sp)
                move.l  d0,-(sp)

-               move.w  (VDP_control_port).l,d0         ; loop start: Wait until we're in the H-blank region
                andi.w  #4,d0
                beq.s   -                               ; loop end

                move.w  (VDP_Reg1_val).w,d0
                andi.b  #$BF,d0
                move.w  d0,(VDP_control_port).l         ; Display disable

                move.w  #$8200|(VRAM_Plane_A_Name_Table_2P/$400),(VDP_control_port).l  ; PNT A base: $A000

; Update V-Scroll
                move.l  #vdpComm($0000,VSRAM,WRITE),(VDP_control_port).l
                move.l  (Vscroll_Factor_P2_HInt).w,(VDP_data_port).l

                stopZ80
                dma68kToVDP Sprite_Table_P2,VRAM_Sprite_Attribute_Table,VRAM_Sprite_Attribute_Table_Size,VRAM
                startZ80

-               move.w  (VDP_control_port).l,d0         ; loop start: Wait until we're in the H-blank region
                andi.w  #4,d0
                beq.s   -                               ; loop end

                move.w  (VDP_Reg1_val).w,d0
                ori.b   #$40,d0
                move.w  d0,(VDP_control_port).l         ; Display enable
                move.l  (sp)+,d0
                movea.l (sp)+,a5

H_Int_Done:
                rte

; >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; game code

; ---------------------------------------------------------------------------
; loc_1000:
