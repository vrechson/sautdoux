; Definitions.inc 
;
; is an include for our game where I define all the information TYPES
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Point Struct
POINT STRUCT
	X BYTE ?
	Y BYTE ?
POINT ENDS

; Player Struct
PLAYER STRUCT
	pos POINT <>
	height BYTE 4
	_width BYTE 7
PLAYER ENDS

; Misc Struct
ENVIRONMENT STRUCT
	time SBYTE 120
	score BYTE 0
	onMove BYTE 0
	seesawState BYTE 0
ENVIRONMENT ENDS

; Objects Struct
ARTEFACT STRUCT
	pos POINT <>    ;
	height BYTE 5   ;
	_width BYTE 10  ;
	color DWORD lightGreen
	bonus SBYTE 0   ;
	score SBYTE 3  ;
	hidden BYTE 1
	orien BYTE ?    ;
ARTEFACT ENDS
 
;
; Seesaw States Definition
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
.data
; owl
PlayerSkin \
		BYTE " /\_/\", 0
		BYTE "((@v@))", 0
		BYTE "():::()", 0
		BYTE " VV-VV", 0
PlayerLen = 4

; Seesaw
SeesawFirstState \	
		BYTE "                                                            ___________________________", 0
		BYTE "                                                            ===========================", 0
		BYTE "                          __________________________________", 0
		BYTE "                          ==================================", 0
		BYTE "__________________________                #", 0
		BYTE "==========================               ###", 0
		BYTE "                                       #######", 0

SeesawSecondState \
		BYTE " ", 0
		BYTE " ", 0
		BYTE "______________________________________________________________________________________", 0
		BYTE "======================================================================================", 0
		BYTE "                                          #", 0
		BYTE "                                         ###", 0
		BYTE "                                       #######", 0

SeesawThirdState \	
		BYTE "__________________________", 0
		BYTE "==========================", 0
		BYTE "                          __________________________________", 0
		BYTE "                          ==================================", 0
		BYTE "                                          #                 __________________________", 0
		BYTE "                                         ###                ==========================", 0
		BYTE "                                       #######", 0
SeesawLen = 7

; Logo
Logo \
BYTE " _______  _______  __   __  _______    ______   _______  __   __  __   __ ", 0
BYTE "|       ||   _   ||  | |  ||       |  |      | |       ||  | |  ||  |_|  |", 0
BYTE "|  _____||  |_|  ||  | |  ||_     _|  |  _    ||   _   ||  | |  ||       |", 0
BYTE "| |_____ |       ||  |_|  |  |   |    | | |   ||  | |  ||  |_|  ||       |", 0
BYTE "|_____  ||       ||       |  |   |    | |_|   ||  |_|  ||       | |     | ", 0
BYTE " _____| ||   _   ||       |  |   |    |       ||       ||       ||   _   |", 0
BYTE "|_______||__| |__||_______|  |___|    |______| |_______||_______||__| |__|", 0

LogoLen = 7

; Media

gameSoundtrack	     	BYTE "assets/background.wav", 0
_filename				DWORD 00020001h

; Numbers
Number \
		BYTE " ___   ", 0
		BYTE "|   |  ", 0
		BYTE "| | |  ", 0
		BYTE "|___|  ", 0
  
		BYTE " ___   ", 0   
		BYTE "|_  |  ", 0  
		BYTE " _| |_ ", 0 
		BYTE "|_____|", 0

		BYTE " ___   ", 0
		BYTE "|_  |  ", 0
		BYTE "|  _|  ", 0
		BYTE "|___|  ", 0

		BYTE " ___   ", 0 
		BYTE "|_  |  ", 0
		BYTE "|_  |  ", 0
		BYTE "|___|  ", 0

		BYTE " ___   ", 0
		BYTE "| | |  ", 0
		BYTE "|_  |  ", 0
		BYTE "  |_|  ", 0
             
		BYTE " ___   ", 0    
		BYTE "|  _|  ", 0
		BYTE "|_  |  ", 0
		BYTE "|___|  ", 0
	
		BYTE " ___   ", 0  
		BYTE "|  _|  ", 0 
		BYTE "| . |  ", 0
		BYTE "|___|  ", 0

		BYTE " ___   ", 0   
		BYTE "|_  |  ", 0  
		BYTE "  | |  ", 0 
		BYTE "  |_|  ", 0 

		BYTE " ___   ", 0     
		BYTE "| . |  ", 0  
		BYTE "| . |  ", 0  
		BYTE "|___|  ", 0 

		BYTE " ___   ", 0  
		BYTE "| . |  ", 0 
		BYTE "|_  |  ", 0 
		BYTE "|___|  ", 0  

NumberLen = 4

; Artefacts
Donut \
		BYTE "   ____", 0
		BYTE ".'` __ `'.", 0
		BYTE "|  '--'  |", 0
		BYTE "\`------`/", 0
		BYTE " `------`", 0
DonutLen = 5

Glass \
		BYTE "         ____", 0
    	BYTE "/\     .'   /\", 0
        BYTE "|K----;    |  |", 0
     	BYTE "\/     '.___\/", 0
GlassLen = 4

Over \
BYTE " __   __  _______  __   __    ______   ___   ______   ___ ", 0
BYTE "|  | |  ||       ||  | |  |  |      | |   | |      | |   |", 0
BYTE "|  |_|  ||   _   ||  | |  |  |  _    ||   | |  _    ||___|", 0
BYTE "|       ||  | |  ||  |_|  |  | | |   ||   | | | |   | ___ ", 0
BYTE "|_     _||  |_|  ||       |  | |_|   ||   | | |_|   ||   |", 0
BYTE "  |   |  |       ||       |  |       ||   | |       ||___|", 0 
BYTE "  |___|  |_______||_______|  |______| |___| |______|      ", 0 

OverLen = 7

Score \
BYTE " _______  _______  ___   __    _  _______  _______ ", 0 
BYTE "|       ||       ||   | |  |  | ||       ||       |", 0 
BYTE "|    _  ||   _   ||   | |   |_| ||_     _||  _____|", 0 
BYTE "|   |_| ||  | |  ||   | |       |  |   |  | |_____ ", 0 
BYTE "|    ___||  |_|  ||   | |  _    |  |   |  |_____  | ___ ", 0 
BYTE "|   |    |       ||   | | | |   |  |   |   _____| ||   |", 0 
BYTE "|___|    |_______||___| |_|  |__|  |___|  |_______||___|", 0 

ScoreLen = 7


colorsIrvine DWORD lightGreen, lightRed, lightBlue, yellow, lightCyan