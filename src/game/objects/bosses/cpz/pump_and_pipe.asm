Obj5D_FallingParts:
                cmpi.b  #-7,Obj5D_timer(a0)
                beq.s   +
                subi_.b #1,Obj5D_timer(a0)
                bgt.w   JmpTo34_DisplaySprite
                bsr.w   Obj5D_Main_Explode2
                move.b  #-7,Obj5D_timer(a0)
                move.w  #$1E,Obj5D_timer2(a0)
+
                subq.w  #1,Obj5D_timer2(a0)
                bpl.w   JmpTo34_DisplaySprite
                move.w  x_vel(a0),d0
                add.w   d0,x_pos(a0)
                move.l  y_pos(a0),d3
                move.w  y_vel(a0),d0
                addi.w  #$38,y_vel(a0)
                ext.l   d0
                asl.l   #8,d0
                add.l   d0,d3
                move.l  d3,y_pos(a0)
                cmpi.l  #$5800000,d3
                bhs.w   JmpTo51_DeleteObject
                jmpto   JmpTo35_MarkObjGone
; ===========================================================================

Obj5D_Pump:
                btst    #status.npc.no_balancing,status(a0)
                bne.s   .bossDefeated

                movea.l Obj5D_parent(a0),a1             ; a1=object
                move.l  x_pos(a1),x_pos(a0)
                move.l  y_pos(a1),y_pos(a0)
                move.b  render_flags(a1),render_flags(a0)
                move.b  status(a1),status(a0)
                movea.l #Ani_Obj5D_Dripper,a1
                jsr     (AnimateSprite).l
                jmp     (DisplaySprite).l
; ---------------------------------------------------------------------------

.bossDefeated:
; Split this object into three pieces which each separately fall
; apart from the boss
                moveq   #$22,d3                         ; Start with sprite $22
                move.b  #$78,Obj5D_timer(a0)
                movea.l Obj5D_parent(a0),a1             ; a1=object
                move.w  x_pos(a1),x_pos(a0)
                move.w  y_pos(a1),y_pos(a0)
                move.b  d3,mapping_frame(a0)
                move.b  #$14,routine(a0)                ; => Obj5D_FallingParts
                jsr     (RandomNumber).l
                asr.w   #8,d0
                asr.w   #6,d0
                move.w  d0,x_vel(a0)
                move.w  #-$380,y_vel(a0)

                moveq   #2-1,d2                         ; Create two more objects
                addq.w  #1,d3

-
                jsr     (AllocateObject).l
                bne.w   JmpTo51_DeleteObject
                _move.b #ObjID_CPZBoss,id(a1)           ; load obj5D
                move.l  #Obj5D_MapUnc_2EADC,mappings(a1)
                move.b  d3,mapping_frame(a1)
                move.b  #$14,routine(a1)                ; => Obj5D_FallingParts
                move.w  #make_art_tile(ArtTile_ArtNem_CPZBoss,1,0),art_tile(a1)
                move.b  #1<<render_flags.level_fg,render_flags(a1)
                move.b  #$20,width_pixels(a1)
                move.b  #2,priority(a1)
                move.w  x_pos(a0),x_pos(a1)
                move.w  y_pos(a0),y_pos(a1)
                move.b  status(a0),status(a1)
                move.b  render_flags(a0),render_flags(a1)
                jsr     (RandomNumber).l
                asr.w   #8,d0
                asr.w   #6,d0
                move.w  d0,x_vel(a1)
                move.w  #-$380,y_vel(a1)
                swap    d0
                addi.b  #$1E,d0
                andi.w  #$7F,d0
                move.b  d0,Obj5D_timer(a1)
                addq.w  #1,d3                           ; Next sprite
                dbf     d2,-
; This function fails to display the current object, causing the top
; piece of the Chemical Plant Zone boss to disappear for one frame when
; the boss is defeated
                rts
; ===========================================================================
; Object to control the pipe's actions before pumping starts

Obj5D_Pipe:
                moveq   #0,d0
                move.b  routine_secondary(a0),d0
                move.w  Obj5D_Pipe_Index(pc,d0.w),d1
                jmp     Obj5D_Pipe_Index(pc,d1.w)
; ===========================================================================
Obj5D_Pipe_Index:   offsetTable
                offsetTableEntry.w Obj5D_Pipe_Wait      ; 0
                offsetTableEntry.w Obj5D_Pipe_Extend    ; 2
; ===========================================================================
; wait for main vehicle's action 0
; Obj5D_Pipe_0:
Obj5D_Pipe_Wait:
; Bit 0 of `Obj5D_status2` is set when the boss has reached its
; destination and is ready to begin filling its tank
                movea.l Obj5D_parent(a0),a1             ; parent = main vehicle ; a1=object
                btst    #0,Obj5D_status2(a1)            ; parent's action 0?
                bne.s   +                               ; if yes, branch
; else, do nothing
                rts
; ---------------------------------------------------------------------------
+
                move.w  x_pos(a1),x_pos(a0)
                move.w  y_pos(a1),y_pos(a0)
                addi.w  #$18,y_pos(a0)
; See the below bugfix
                move.w  #$C,Obj5D_pipe_segments(a0)
                addq.b  #2,routine_secondary(a0)        ; => Obj5D_Pipe_Extend
                movea.l a0,a1
                bra.s   Obj5D_Pipe_Extend_Part2         ; skip initial loading setup
; ===========================================================================
; load pipe segments, first object controls rest of pipe
; objects not loaded in a loop => one segment loaded per frame
; pipe extends gradually
; Obj5D_Pipe_2_Load:
Obj5D_Pipe_Extend:
; This code allocates one more object than necessary, leaving a
; partially initialised object in memory
                jsr     (AllocateObjectAfterCurrent).l
                beq.s   +
                rts
; ---------------------------------------------------------------------------
+
                move.l  a0,Obj5D_parent(a1)
; Obj5D_Pipe_2_Load_Part2:
Obj5D_Pipe_Extend_Part2:
                subq.w  #1,Obj5D_pipe_segments(a0)      ; is pipe fully extended?
                blt.s   Obj5D_Pipe_Extend_End           ; if yes, branch

                _move.b #ObjID_CPZBoss,id(a1)           ; load obj5D
                move.l  #Obj5D_MapUnc_2EADC,mappings(a1)
                move.w  #make_art_tile(ArtTile_ArtNem_CPZBoss,1,0),art_tile(a1)
                move.b  #1<<render_flags.level_fg,render_flags(a1)
                move.b  #$20,width_pixels(a1)
                move.b  #5,priority(a1)
                move.w  x_pos(a0),x_pos(a1)
                move.w  y_pos(a0),y_pos(a1)

; calculate y position for current pipe segment
                move.w  Obj5D_pipe_segments(a0),d0
                subi.w  #$C-1,d0                        ; $B = maximum number of pipe segments -1, result is always negative or zero
                neg.w   d0                              ; positive value needed
                lsl.w   #3,d0                           ; multiply with 8
                move.w  d0,Obj5D_y_pos_next(a1)
                add.w   d0,y_pos(a1)
                move.b  #1,anim(a1)
                cmpi.b  #2,routine_secondary(a1)
                beq.w   Obj5D_PipeSegment               ; only true for the first object
                move.b  #$E,routine(a1)                 ; => Obj5D_PipeSegment
                bra.w   Obj5D_PipeSegment
; ===========================================================================
; once all pipe segments have been loaded, switch to pumping routine
; Obj5D_Pipe_2_Load_End:
Obj5D_Pipe_Extend_End:
                move.b  #0,routine_secondary(a0)        ; => Obj5D_Pipe_Pump_0
                move.b  #6,routine(a0)                  ; => Obj5D_Pipe_Pump
                bra.w   Obj5D_PipeSegment
; ===========================================================================
; Object to control the pipe's actions while pumping

Obj5D_Pipe_Pump:
                moveq   #0,d0
                move.b  routine_secondary(a0),d0
                move.w  Obj5D_Pipe_Pump_Index(pc,d0.w),d1
                jmp     Obj5D_Pipe_Pump_Index(pc,d1.w)
; ===========================================================================
Obj5D_Pipe_Pump_Index:  offsetTable
                offsetTableEntry.w Obj5D_Pipe_Pump_0    ; 0
                offsetTableEntry.w Obj5D_Pipe_Pump_2    ; 2
                offsetTableEntry.w Obj5D_Pipe_Pump_4    ; 4
; ===========================================================================
; prepares for pumping animation

Obj5D_Pipe_Pump_0:
                jsr     (AllocateObjectAfterCurrent).l
                bne.w   Obj5D_PipeSegment
                move.b  #$E,routine(a0)                 ; => Obj5D_PipeSegment ; temporarily turn control object into a pipe segment
                move.b  #6,routine(a1)                  ; => Obj5D_Pipe_Pump
                move.b  #2,routine_secondary(a1)        ; => Obj5D_Pipe_Pump_2
                _move.b #ObjID_CPZBoss,id(a1)           ; load obj5D
                move.l  #Obj5D_MapUnc_2EADC,mappings(a1)
                move.w  #make_art_tile(ArtTile_ArtNem_CPZBoss,1,0),art_tile(a1)
                move.b  #1<<render_flags.level_fg,render_flags(a1)
                move.b  #$20,width_pixels(a1)
                move.b  #4,priority(a1)
                move.b  #2,Obj5D_timer3(a1)
                move.w  x_pos(a0),x_pos(a1)
                move.w  y_pos(a0),y_pos(a1)

; starting position for pumping animation
                move.w  #$B*8,d0
                move.b  d0,Obj5D_y_offset(a1)
                add.w   d0,y_pos(a1)
                move.b  #2,anim(a1)
                move.l  a0,Obj5D_parent(a1)             ; address of control object
                move.b  #$12,Obj5D_timer(a1)

                jsr     (AllocateObjectAfterCurrent).l
                bne.s   BranchTo_Obj5D_PipeSegment
                _move.b #ObjID_CPZBoss,id(a1)           ; load obj5D
                move.b  #$A,routine(a1)                 ; => Obj5D_Dripper
                move.l  Obj5D_parent(a0),Obj5D_parent(a1)

BranchTo_Obj5D_PipeSegment                              ; BranchTo
                bra.w   Obj5D_PipeSegment
; ===========================================================================
; do pumping animation

Obj5D_Pipe_Pump_2:
                movea.l Obj5D_parent(a0),a1             ; parent = pipe segment (control object) ; a1=object
                movea.l Obj5D_parent(a1),a2             ; parent = main vehicle ; a2=object
                btst    #status.npc.no_balancing,status(a2)  ; has boss been defeated?
                bne.w   JmpTo51_DeleteObject            ; if yes, branch
                move.w  x_pos(a1),x_pos(a0)
                move.w  y_pos(a1),y_pos(a0)

                subi_.b #1,Obj5D_timer(a0)              ; animation timer
                bne.s   Obj5D_Pipe_Pump_2_End
; when timer reaches zero
                move.b  #$12,Obj5D_timer(a0)            ; reset animation timer
                subi_.b #8,Obj5D_y_offset(a0)           ; move one segment up
                bgt.s   Obj5D_Pipe_Pump_2_End
                bmi.s   +                               ; pumping sequence is over when y offset becomes negative

; one final delay when last segment is reached
                move.b  #3,anim(a0)
                move.b  #$C,Obj5D_timer(a0)
                bra.s   Obj5D_Pipe_Pump_2_End
; ---------------------------------------------------------------------------
+                                                       ; when pumping sequence is over
                move.b  #6,Obj5D_timer(a0)
                move.b  #4,routine_secondary(a0)        ; => Obj5D_Pipe_Pump_4
                rts
; ---------------------------------------------------------------------------

Obj5D_Pipe_Pump_2_End:
; set y position based on y offset
                moveq   #0,d0
                move.b  Obj5D_y_offset(a0),d0
                add.w   d0,y_pos(a0)
                lea     (Ani_Obj5D_Dripper).l,a1
                jsr     (AnimateSprite).l
                jmp     (DisplaySprite).l
; ===========================================================================

Obj5D_Pipe_Pump_4:
                subi_.b #1,Obj5D_timer(a0)              ; wait a few frames
                beq.s   +
                rts
; ---------------------------------------------------------------------------
+
                subq.b  #1,Obj5D_timer3(a0)
                beq.s   +
                move.b  #2,anim(a0)
                move.b  #$12,Obj5D_timer(a0)
                move.b  #2,routine_secondary(a0)        ; => Obj5D_Pipe_Pump_2
                move.b  #$B*8,Obj5D_y_offset(a0)
+
; set control object's routine
                movea.l Obj5D_parent(a0),a1             ; parent = pipe segment (control object) ; a1=object
                move.b  #8,routine(a1)                  ; => Obj5D_Pipe_Retract
                move.b  #$B*8,Obj5D_y_offset(a1)
                jmpto   JmpTo51_DeleteObject
; ===========================================================================
; Object to control the pipe's actions after pumping is finished

Obj5D_Pipe_Retract:
                tst.b   Obj5D_flag(a0)                  ; is flag set?
                bne.s   loc_2DFEE                       ; if yes, branch

                moveq   #0,d0
                move.b  Obj5D_y_offset(a0),d0
                add.w   y_pos(a0),d0                    ; get y pos of current pipe segment
; This checks the entirety of the 'normal' object pool, even
; though it only really has to search the dynamic object pool
                lea     (Object_RAM).w,a1               ; a1=object
                moveq   #(Object_RAM_End-Object_RAM)/object_size-1,d1

Obj5D_Pipe_Retract_Loop:
                cmp.w   y_pos(a1),d0                    ; compare object's y position with current y offset
                beq.s   Obj5D_Pipe_Retract_ChkID        ; if they match, branch
                lea     next_object(a1),a1              ; a1=object
                dbf     d1,Obj5D_Pipe_Retract_Loop      ; continue as long as there are object slots left
                bra.s   Obj5D_PipeSegment
; ===========================================================================

loc_2DFD8:
                st.b    Obj5D_flag(a0)
                bra.s   Obj5D_PipeSegment
; ===========================================================================

Obj5D_Pipe_Retract_ChkID:
; 'd7' should not be used here. This causes the 'RunObjects' routine
; to either run too few objects or too many objects, causing all
; sorts of errors
                moveq   #0,d7
                move.b  #ObjID_CPZBoss,d7
                cmp.b   id(a1),d7                       ; is object a subtype of the CPZ Boss?
                beq.s   loc_2DFF0                       ; if yes, branch
                dbf     d1,Obj5D_Pipe_Retract_Loop
                bra.s   Obj5D_PipeSegment
; ===========================================================================

loc_2DFEE:
                movea.l a0,a1

loc_2DFF0:
                bset    #status.npc.no_balancing,status(a1)  ; mark segment for deletion
                subi_.b #8,Obj5D_y_offset(a0)           ; position of next segment up
                beq.s   loc_2DFD8

Obj5D_PipeSegment:
                movea.l Obj5D_parent(a0),a1             ; a1=object
                movea.l Obj5D_parent(a1),a2             ; a2=object
                btst    #status.npc.no_balancing,status(a2)  ; has boss been defeated?
                bne.s   Obj5D_PipeSegment_End           ; if yes, branch

                move.w  x_pos(a1),x_pos(a0)
                move.w  y_pos(a1),y_pos(a0)
                cmpi.b  #4,routine_secondary(a0)
                bne.s   +
                addi.w  #$18,y_pos(a0)
+
                btst    #status.npc.no_balancing,status(a0)  ; is object marked for deletion?
                bne.s   BranchTo_JmpTo51_DeleteObject   ; if yes, branch
                move.w  Obj5D_y_pos_next(a0),d0
                add.w   d0,y_pos(a0)
                lea     (Ani_Obj5D_Dripper).l,a1
                jsr     (AnimateSprite).l
                jmp     (DisplaySprite).l
; ===========================================================================

BranchTo_JmpTo51_DeleteObject                           ; BranchTo
                jmpto   JmpTo51_DeleteObject
; ===========================================================================

Obj5D_PipeSegment_End:
                move.b  #$14,routine(a0)                ; => Obj5D_FallingParts
                jsr     (RandomNumber).l
                asr.w   #8,d0
                asr.w   #6,d0
                move.w  d0,x_vel(a0)
                move.w  #-$380,y_vel(a0)
                swap    d0
                addi.b  #$1E,d0
                andi.w  #$7F,d0
                move.b  d0,Obj5D_timer(a0)
; If the Chemical Plant Zone boss is defeated while its pipe is
; extending, then an incorrect sprite will appear at the boss's rear
; as it explodes
; Pipe segments are supposed to use sprite frame 1, but the
; AnimateSprite function must be called for that to happen. When the
; boss is defeated, the segment will switch from calling
; Obj5D_PipeSegment to Obj5D_PipeSegment_End, which does not call
; AnimateSprite
; This means that if the boss were to be defeated right as a pipe
; segment spawns, then it will never call AnimateSprite, causing it to
; display sprite frame 0 instead of 1
; To fix this bug, Obj5D_PipeSegment_End should be made to call
; AnimateSprite
                jmpto   JmpTo34_DisplaySprite
; ===========================================================================
