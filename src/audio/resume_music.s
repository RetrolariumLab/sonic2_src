ResumeMusic:
                cmpi.b  #12,air_left(a1)
                bhi.s   ResumeMusic_Done                ; branch if countdown hasn't started yet

                cmpa.w  #MainCharacter,a1
                bne.s   ResumeMusic_Done                ; branch if it isn't player 1

                move.w  (Level_Music).w,d0              ; prepare to play current level's music

                btst    #status_secondary.invincible,status_secondary(a1)
                beq.s   +                               ; branch if Sonic is not invincible
                move.w  #MusID_Invincible,d0            ; prepare to play invincibility music
+
                tst.b   (Super_Sonic_flag).w
                beq.w   +                               ; branch if it isn't Super Sonic
                move.w  #MusID_SuperSonic,d0            ; prepare to play Super Sonic music
+
                tst.b   (Current_Boss_ID).w
                beq.s   +                               ; branch if not in a boss fight
                move.w  #MusID_Boss,d0                  ; prepare to play boss music
+
                jsr     (PlayMusic).l
; return_1D858:
ResumeMusic_Done:
                move.b  #30,air_left(a1)                ; reset air to full
                rts

; ===========================================================================
; animation script for the bubbles
; off_1D860:
Ani_obj0A:      offsetTable
                offsetTableEntry.w AudioResumeMusic_Animation_Sequence0           ; 0
                offsetTableEntry.w AudioResumeMusic_Animation_Sequence1           ; 1
                offsetTableEntry.w AudioResumeMusic_Animation_Sequence2           ; 2
                offsetTableEntry.w AudioResumeMusic_Animation_Sequence3           ; 3
                offsetTableEntry.w AudioResumeMusic_Animation_Sequence4           ; 4
                offsetTableEntry.w AudioResumeMusic_Animation_Sequence5           ; 5
                offsetTableEntry.w AudioResumeMusic_Animation_Sequence6           ; 6
                offsetTableEntry.w AudioResumeMusic_Animation_Sequence7           ; 7
                offsetTableEntry.w AudioResumeMusic_Animation_Sequence8           ; 8
                offsetTableEntry.w AudioResumeMusic_Animation_Sequence9           ; 9
                offsetTableEntry.w AudioResumeMusic_Animation_Sequence10           ; $A
                offsetTableEntry.w AudioResumeMusic_Animation_Sequence11           ; $B
                offsetTableEntry.w AudioResumeMusic_Animation_Sequence12           ; $C
                offsetTableEntry.w AudioResumeMusic_Animation_Sequence13           ; $D
                offsetTableEntry.w AudioResumeMusic_Animation_Sequence14           ; $E
AudioResumeMusic_Animation_Sequence0:     dc.b    5,  0,  1,  2,  3,  4,  8,  8,$FC
AudioResumeMusic_Animation_Sequence1:     dc.b    5,  0,  1,  2,  3,  4,  9,  9,$FC
AudioResumeMusic_Animation_Sequence2:     dc.b    5,  0,  1,  2,  3,  4, $A, $A,$FC
AudioResumeMusic_Animation_Sequence3:     dc.b    5,  0,  1,  2,  3,  4, $B, $B,$FC
AudioResumeMusic_Animation_Sequence4:     dc.b    5,  0,  1,  2,  3,  4, $C, $C,$FC
AudioResumeMusic_Animation_Sequence5:     dc.b    5,  0,  1,  2,  3,  4, $D, $D,$FC
AudioResumeMusic_Animation_Sequence6:     dc.b    $E,  0,  1,  2,$FC
AudioResumeMusic_Animation_Sequence7:     dc.b    7,$10,  8,$10,  8,$10,  8,$FC
AudioResumeMusic_Animation_Sequence8:     dc.b    7,$10,  9,$10,  9,$10,  9,$FC
AudioResumeMusic_Animation_Sequence9:     dc.b    7,$10, $A,$10, $A,$10, $A,$FC
AudioResumeMusic_Animation_Sequence10:     dc.b    7,$10, $B,$10, $B,$10, $B,$FC
AudioResumeMusic_Animation_Sequence11:     dc.b    7,$10, $C,$10, $C,$10, $C,$FC
AudioResumeMusic_Animation_Sequence12:     dc.b    7,$10, $D,$10, $D,$10, $D,$FC
AudioResumeMusic_Animation_Sequence13:     dc.b    $E,$FC
AudioResumeMusic_Animation_Sequence14:     dc.b    $E,  1,  2,  3,  4,$FC
                even

; ===========================================================================
; ----------------------------------------------------------------------------
; Object 38 - Shield
; ----------------------------------------------------------------------------
; Sprite_1D8F2:
