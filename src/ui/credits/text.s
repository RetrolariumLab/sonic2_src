Credits_IntroTextLayout:    creditsPtrs CreditsText_SONIC_Variant2,textLoc($0F,$09), CreditsText_AND_Variant2,textLoc($11,$0C), \
                CreditsText_MILESTAILSPROWER,textLoc($03,$0F), CreditsText_IN,textLoc($12,$12)

; credits screen pointer table
Credits_PageLayouts:
                dc.l    CreditsPage_Title, CreditsPage_ExecutiveProducer, CreditsPage_Producer, CreditsPage_Director  ; 3
                dc.l    CreditsPage_ChiefProgrammer, CreditsPage_GamePlanner, CreditsPage_CharacterDesign, CreditsPage_AssistantProgrammers  ; 7
                dc.l    CreditsPage_ObjectPlacement, CreditsPage_SpecialStagePlacement, CreditsPage_ZoneArtists, CreditsPage_SpecialStageArtists  ; 11
                dc.l    CreditsPage_MusicComposer, CreditsPage_SoundProgrammer, CreditsPage_SoundAssistants, CreditsPage_ProjectAssistants  ; 15
                dc.l    CreditsPage_Manual, CreditsPage_ExecutiveSupporters, CreditsPage_SpecialThanksA, CreditsPage_SpecialThanksB  ; 19
                dc.l    CreditsPage_PresentedBy, -1     ; 21

; credits text pointers for each screen of credits
vram_pnt                            :=      VRAM_Plane_A_Name_Table
CreditsPage_Title:                  creditsPtrs CreditsText_SONIC,textLoc($0E,$0B), CreditsText_2,textLoc($18,$0B), CreditsText_CASTOFCHARACTERS,textLoc($02,$0F)
CreditsPage_ExecutiveProducer:      creditsPtrs CreditsText_EXECUTIVE,textLoc($03,$0B), CreditsText_PRODUCER,textLoc($16,$0B), CreditsText_HAYAONAKAYAMA,textLoc($06,$0F)
CreditsPage_Producer:               creditsPtrs CreditsText_PRODUCER,textLoc($0C,$0B), CreditsText_SHINOBUTOYODA,textLoc($07,$0F)
CreditsPage_Director:               creditsPtrs CreditsText_DIRECTOR,textLoc($0C,$0B), CreditsText_MASAHARUYOSHII,textLoc($06,$0F)
CreditsPage_ChiefProgrammer:        creditsPtrs CreditsText_CHIEFPROGRAMMER,textLoc($05,$0B), CreditsText_YUJINAKAYU2,textLoc($07,$0F)
CreditsPage_GamePlanner:            creditsPtrs CreditsText_GAMEPLANNER,textLoc($08,$0A), CreditsText_HIROKAZUYASUHARA,textLoc($04,$0E), CreditsText_CAROLYAS,textLoc($0A,$10)
CreditsPage_CharacterDesign:        creditsPtrs CreditsText_CHARACTERDESIGN,textLoc($04,$08), CreditsText_AND,textLoc($11,$0A), CreditsText_CHIEFARTIST,textLoc($09,$0C), CreditsText_YASUSHIYAMAGUCHI,textLoc($04,$10), CreditsText_JUDYTOTOYA,textLoc($08,$12)
CreditsPage_AssistantProgrammers:   creditsPtrs CreditsText_ASSISTANT,textLoc($0B,$09), CreditsText_PROGRAMMERS,textLoc($09,$0B), CreditsText_BILLWILLIS,textLoc($0A,$0F), CreditsText_MASANOBUYAMAMOTO,textLoc($03,$11)
CreditsPage_ObjectPlacement:        creditsPtrs CreditsText_OBJECTPLACEMENT,textLoc($04,$09), CreditsText_HIROKAZUYASUHARA,textLoc($04,$0D), CreditsText_TAKAHIROANTO,textLoc($07,$0F), CreditsText_YUTAKASUGANO,textLoc($07,$11)
CreditsPage_SpecialStagePlacement:  creditsPtrs CreditsText_SPECIALSTAGE,textLoc($08,$0A), CreditsText_OBJECTPLACEMENT,textLoc($04,$0C), CreditsText_YUTAKASUGANO,textLoc($07,$10)
CreditsPage_ZoneArtists:            creditsPtrs CreditsText_ZONEARTISTS,textLoc($09,$06), CreditsText_YASUSHIYAMAGUCHI,textLoc($04,$0A), CreditsText_CRAIGSTITT,textLoc($0A,$0C), CreditsText_BRENDAROSS,textLoc($09,$0E), CreditsText_JINAISHIWATARI,textLoc($07,$10), CreditsText_TOMPAYNE,textLoc($0B,$12), CreditsText_PHENIXRIE,textLoc($0B,$14)
CreditsPage_SpecialStageArtists:    creditsPtrs CreditsText_SPECIALSTAGE,textLoc($09,$09), CreditsText_ARTANDCG,textLoc($0A,$0B), CreditsText_TIMSKELLY,textLoc($0B,$0F), CreditsText_PETERMORAWIEC,textLoc($07,$11)
CreditsPage_MusicComposer:          creditsPtrs CreditsText_MUSICCOMPOSER,textLoc($06,$09), CreditsText_MASATONAKAMURA,textLoc($05,$0D), CreditsText_1992,textLoc($03,$0F), CreditsText_DREAMSCOMETRUE,textLoc($04,$11)
CreditsPage_SoundProgrammer:        creditsPtrs CreditsText_SOUNDPROGRAMMER,textLoc($04,$0B), CreditsText_TOMOYUKISHIMADA,textLoc($05,$0F)
CreditsPage_SoundAssistants:        creditsPtrs CreditsText_SOUNDASSISTANTS,textLoc($04,$05), CreditsText_MACKY,textLoc($0F,$09), CreditsText_JIMITA,textLoc($0F,$0B), CreditsText_MILPO,textLoc($0F,$0D), CreditsText_IPPO,textLoc($10,$0F), CreditsText_SO,textLoc($11,$11), CreditsText_OYZ,textLoc($11,$13), CreditsText_NGEE,textLoc($0F,$15)
CreditsPage_ProjectAssistants:      creditsPtrs CreditsText_PROJECTASSISTANTS,textLoc($03,$08), CreditsText_SYUICHIKATAGI,textLoc($08,$0C), CreditsText_TAKAHIROHAMANO,textLoc($06,$0E), CreditsText_YOSHIKIOOKA,textLoc($09,$10), CreditsText_STEVEWOITA,textLoc($0A,$12)
CreditsPage_Manual:                 creditsPtrs CreditsText_GAMEMANUAL,textLoc($09,$0A), CreditsText_YOUICHITAKAHASHI,textLoc($05,$0E), CreditsText_CAROLANNHANSHAW,textLoc($03,$10)
CreditsPage_ExecutiveSupporters:    creditsPtrs CreditsText_EXECUTIVE,textLoc($0B,$06), CreditsText_SUPPORTERS,textLoc($0A,$08), CreditsText_DAIZABUROUSAKURAI,textLoc($03,$0C), CreditsText_HISASHISUZUKI,textLoc($07,$0E), CreditsText_Kalinske,textLoc($05,$10), CreditsText_FUJIOMINEGISHI,textLoc($07,$12), CreditsText_TAKAHARUUTSUNOMIYA,textLoc($02,$14)
CreditsPage_SpecialThanksA:         creditsPtrs CreditsText_SPECIALTHANKS,textLoc($06,$06), CreditsText_TO,textLoc($12,$08), CreditsText_CINDYCLAVERAN,textLoc($06,$0C), CreditsText_FRANCETANTIADO,textLoc($05,$0E), CreditsText_DAISUKESAITO,textLoc($08,$10), CreditsText_KUNITAKEAOKI,textLoc($08,$12), CreditsText_TSUNEKOAOKI,textLoc($09,$14)
CreditsPage_SpecialThanksB:         creditsPtrs CreditsText_SPECIALTHANKS,textLoc($06,$06), CreditsText_TO,textLoc($12,$08), CreditsText_DEBORAHMCCRACKEN,textLoc($03,$0C), CreditsText_TATSUOYAMADA,textLoc($07,$0E), CreditsText_RICKMACARAEG,textLoc($07,$10), CreditsText_LOCKYP,textLoc($0D,$12), CreditsText_MASAAKIKAWAMURA,textLoc($04,$14)
CreditsPage_PresentedBy:            creditsPtrs CreditsText_PRESENTED,textLoc($0B,$09), CreditsText_BY,textLoc($12,$0D), CreditsText_SEGA,textLoc($10,$11)

; temporarily remap characters to credit text format
; let's encode 2-wide characters like Aa, Bb, Cc, etc. and hide it with a macro
                charset '@',"\x3B\2\4\6\8\xA\xC\xE\x10\x12\x13\x15\x17\x19\x1B\x1D\x1F\x21\x23\x25\x27\x29\x2B\x2D\x2F\x31\x33"
                charset 'a',"\3\5\7\9\xB\xD\xF\x11\x12\x14\x16\x18\x1A\x1C\x1E\x20\x22\x24\x26\x28\x2A\x2C\x2E\x30\x32\x34"
                charset '!',"\x3D\x39\x3F\x36"
                charset '\H',"\x39\x37\x38"
                charset '9',"\x3E\x40\x41"
                charset '1',"\x3C\x35"
                charset '.',"\x3A"
                charset ' ',0

; macro for defining credit text in conjunction with the remapped character set
vram_src        :=      ArtTile_ArtNem_CreditText_CredScr
creditText      macro   pal,ss
                        if      ((vram_src & $FF) <> $0) && ((vram_src & $FF) <> $1)
                        fatal   "The low byte of vram_src was $\{vram_src & $FF}, but it must be $00 or $01."
                        endif
                        dc.b    (make_art_tile(vram_src,pal,0) & $FF00) >> 8
                        irpc    char,ss
                        dc.b    "char"
                        switch  "char"
                        case    "I"
                        case    "1"
                        dc.b    "!"
                        case    "2"
                        dc.b    "$"
                        case    "9"
                        dc.b    "#"
                        elsecase
l               :=      lowstring("char")
                        if      l<>"char"
                        dc.b    l
                        endif
                        endcase
                    endm
                    dc.b    -1
                endm

; credits text data (palette index followed by a string)
vram_src                        :=      ArtTile_ArtNem_CreditText_CredScr
CreditsText_EXECUTIVE:          creditText 1,"EXECUTIVE"
CreditsText_PRODUCER:           creditText 1,"PRODUCER"
CreditsText_HAYAONAKAYAMA:      creditText 0,"HAYAO  NAKAYAMA"
CreditsText_SHINOBUTOYODA:      creditText 0,"SHINOBU  TOYODA"
CreditsText_DIRECTOR:           creditText 1,"DIRECTOR"
CreditsText_MASAHARUYOSHII:     creditText 0,"MASAHARU  YOSHII"
CreditsText_CHIEFPROGRAMMER:    creditText 1,"CHIEF  PROGRAMMER"
CreditsText_YUJINAKAYU2:        creditText 0,"YUJI  NAKA (YU2)"
CreditsText_GAMEPLANNER:        creditText 1,"GAME  PLANNER"
CreditsText_HIROKAZUYASUHARA:   creditText 0,"HIROKAZU  YASUHARA"
CreditsText_CAROLYAS:           creditText 0,"(CAROL  YAS)"
CreditsText_CHARACTERDESIGN:    creditText 1,"CHARACTER  DESIGN"
CreditsText_AND:                creditText 1,"AND"
CreditsText_CHIEFARTIST:        creditText 1,"CHIEF  ARTIST"
CreditsText_YASUSHIYAMAGUCHI:   creditText 0,"YASUSHI  YAMAGUCHI"
CreditsText_JUDYTOTOYA:         creditText 0,"(JUDY  TOTOYA)"
CreditsText_ASSISTANT:          creditText 1,"ASSISTANT"
CreditsText_PROGRAMMERS:        creditText 1,"PROGRAMMERS"
CreditsText_BILLWILLIS:         creditText 0,"BILL  WILLIS"
CreditsText_MASANOBUYAMAMOTO:   creditText 0,"MASANOBU  YAMAMOTO"
CreditsText_OBJECTPLACEMENT:    creditText 1,"OBJECT  PLACEMENT"
CreditsText_TAKAHIROANTO:       creditText 0,"TAKAHIRO  ANTO"
CreditsText_YUTAKASUGANO:       creditText 0,"YUTAKA  SUGANO"
CreditsText_SPECIALSTAGE:       creditText 1,"SPECIALSTAGE"
CreditsText_CAROLANNHANSHAW:    creditText 0,"CAROL  ANN  HANSHAW"
CreditsText_ZONEARTISTS:        creditText 1,"ZONE  ARTISTS"
CreditsText_CRAIGSTITT:         creditText 0,"CRAIG  STITT"
CreditsText_BRENDAROSS:         creditText 0,"BRENDA  ROSS"
CreditsText_JINAISHIWATARI:     creditText 0,"JINA  ISHIWATARI"
CreditsText_TOMPAYNE:           creditText 0,"TOM  PAYNE"
CreditsText_PHENIXRIE:          creditText 0,"PHENIX  RIE"
CreditsText_ARTANDCG:           creditText 1,"ART  AND  CG"
CreditsText_TIMSKELLY:          creditText 0,"TIM  SKELLY"
CreditsText_PETERMORAWIEC:      creditText 0,"PETER  MORAWIEC"
CreditsText_MUSICCOMPOSER:      creditText 1,"MUSIC  COMPOSER"
CreditsText_MASATONAKAMURA:     creditText 0,"MASATO  NAKAMURA"
CreditsText_1992:               creditText 0,"( @1992"
CreditsText_DREAMSCOMETRUE:     creditText 0,"DREAMS  COME  TRUE)"
CreditsText_SOUNDPROGRAMMER:    creditText 1,"SOUND  PROGRAMMER"
CreditsText_TOMOYUKISHIMADA:    creditText 0,"TOMOYUKI  SHIMADA"
CreditsText_SOUNDASSISTANTS:    creditText 1,"SOUND  ASSISTANTS"
CreditsText_MACKY:              creditText 0,"MACKY"
CreditsText_JIMITA:             creditText 0,"JIMITA"
CreditsText_MILPO:              creditText 0,"MILPO"
CreditsText_IPPO:               creditText 0,"IPPO"
CreditsText_SO:                 creditText 0,"S.O"
CreditsText_OYZ:                creditText 0,"OYZ"
CreditsText_NGEE:               creditText 0,"N.GEE"
CreditsText_PROJECTASSISTANTS:  creditText 1,"PROJECT  ASSISTANTS"
CreditsText_SYUICHIKATAGI:      creditText 0,"SYUICHI  KATAGI"
CreditsText_TAKAHIROHAMANO:     creditText 0,"TAKAHIRO  HAMANO"
CreditsText_YOSHIKIOOKA:        creditText 0,"YOSHIKI  OOKA"
CreditsText_STEVEWOITA:         creditText 0,"STEVE  WOITA"
CreditsText_GAMEMANUAL:         creditText 1,"GAME  MANUAL"
CreditsText_YOUICHITAKAHASHI:   creditText 0,"YOUICHI  TAKAHASHI"
CreditsText_SUPPORTERS:         creditText 1,"SUPPORTERS"
CreditsText_DAIZABUROUSAKURAI:  creditText 0,"DAIZABUROU  SAKURAI"
CreditsText_HISASHISUZUKI:      creditText 0,"HISASHI  SUZUKI"
                if      gameRevision=0
CreditsText_Kalinske:   creditText 0,"TOHMAS  KALINSKE"  ; typo
                else
CreditsText_Kalinske:   creditText 0,"THOMAS  KALINSKE"
                endif
CreditsText_FUJIOMINEGISHI:     creditText 0,"FUJIO  MINEGISHI"
CreditsText_TAKAHARUUTSUNOMIYA: creditText 0,"TAKAHARU UTSUNOMIYA"
CreditsText_SPECIALTHANKS:      creditText 1,"SPECIAL  THANKS"
CreditsText_TO:                 creditText 1,"TO"
CreditsText_CINDYCLAVERAN:      creditText 0,"CINDY  CLAVERAN"
CreditsText_DEBORAHMCCRACKEN:   creditText 0,"DEBORAH  MCCRACKEN"
CreditsText_TATSUOYAMADA:       creditText 0,"TATSUO  YAMADA"
CreditsText_DAISUKESAITO:       creditText 0,"DAISUKE  SAITO"
CreditsText_KUNITAKEAOKI:       creditText 0,"KUNITAKE  AOKI"
CreditsText_TSUNEKOAOKI:        creditText 0,"TSUNEKO  AOKI"
CreditsText_MASAAKIKAWAMURA:    creditText 0,"MASAAKI  KAWAMURA"
CreditsText_SONIC:              creditText 0,"SONIC"
CreditsText_2:                  creditText 1,"2"
CreditsText_CASTOFCHARACTERS:   creditText 0,"CAST  OF  CHARACTERS"
CreditsText_PRESENTED:          creditText 0,"PRESENTED"
CreditsText_BY:                 creditText 0,"BY"
CreditsText_SEGA:               creditText 0,"SEGA"
CreditsText_FRANCETANTIADO:     creditText 0,"FRANCE  TANTIADO"
CreditsText_RICKMACARAEG:       creditText 0,"RICK  MACARAEG"
CreditsText_LOCKYP:             creditText 0,"LOCKY  P"

                charset                                 ; have to revert character set before changing again

; temporarily remap characters to intro text format
                charset '@',"\x3A\1\3\5\7\9\xB\xD\xF\x11\x12\x14\x16\x18\x1A\x1C\x1E\x20\x22\x24\x26\x28\x2A\x2C\x2E\x30\x32"
                charset 'a',"\2\4\6\8\xA\xC\xE\x10\x11\x13\x15\x17\x19\x1B\x1D\x1F\x21\x23\x25\x27\x29\x2B\x2D\x2F\x31\x33"
                charset '!',"\x3C\x38\x3E\x35"
                charset '\H',"\x38\x36\x37"
                charset '9',"\x3D\x3F\x40"
                charset '1',"\x3B\x34"
                charset '.',"\x39"
                charset ' ',0

; intro text
vram_src                        :=      ArtTile_ArtNem_CreditText
CreditsText_IN:                 creditText 0,"IN"
CreditsText_AND_Variant2:       creditText 0,"AND"
CreditsText_MILESTAILSPROWER:   creditText 0,"MILES 'TAILS' PROWER"
CreditsText_SONIC_Variant2:     creditText 0,"SONIC"

                charset                                 ; revert character set

                even

; -------------------------------------------------------------------------------
; Nemesis compressed art
; 64 blocks
; Standard font used in credits
; -------------------------------------------------------------------------------
; ArtNem_BD26:
ArtNem_CreditText:  BINCLUDE "data/art/nemesis/Credit Text.nem"
                even
; ===========================================================================

                jmpTos  JmpTo5_DisplaySprite,JmpTo3_DeleteObject,JmpTo2_PlaySound,JmpTo_ObjB2_Animate_Pilot,JmpTo_AnimateSprite,JmpTo_NemDec,JmpTo_EniDec,JmpTo_ClearScreen,JmpTo2_PlayMusic,JmpTo_LoadChildObject,JmpTo2_PlaneMapToVRAM_H40,JmpTo2_ObjectMove,JmpTo_PalCycle_Load,JmpTo_LoadSubObject_Part3

; ---------------------------------------------------------------------------
; Subroutine to load level boundaries and start locations
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; sub_BFBC:
