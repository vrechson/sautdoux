; Main.asm
;
; @authors: Matheus Vrech Silveira Lima && Gabrielle Scaranello Faria
; @RA's: 727349 && 743540
;
;  Ideal console dimensions to play: 120x30
;
;
; is the main file of the game and is important to operate the main loop and the game structure
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;
; Includes
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
INCLUDE lib\Irvine\Irvine32.inc
INCLUDE lib\winmm\winmm.inc
INCLUDELIB lib\winmm\winmm.lib
INCLUDE includes\Utils.inc
INCLUDE includes\Definitions.inc

;
; Prototypes
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
borderGame PROTO _delay: BYTE, color: DWORD
gameMenu PROTO
drawFixedEnvironment PROTO
drawParameters PROTO
drawDynamicElements PROTO
drawNumber PROTO, first: BYTE, second: BYTE, third: BYTE, begin: PTR POINT, color: DWORD
updatePlayers PROTO
updateConfig PROTO
updateObjects PROTO
optimizedClean PROTO
checkColision PROTO, _player: PTR PLAYER
showScore PROTO
;
; Data Section
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
.data
; display messages
startMessage BYTE "Press any key to start.", 0
startoverMessage BYTE "Press any key to start over.", 0
nothingMessage BYTE "                       ", 0
timeMessage BYTE "Time:", 0
scoreMessage BYTE "Score: ", 0
titleMessage BYTE "Saut Doux", 0
;;; game parameters and configuration
borderChar BYTE "#"
cursorPos POINT <5, 5>
auxPos POINT <0, 0>

; enviromental definitions
config ENVIRONMENT <>

; players
player1 PLAYER <<28, 23>>
player2 PLAYER <<88, 1>>

; artefacts
objArr ARTEFACT 2 DUP(<>)
glassObj ARTEFACT <>


; Time control
firstTime DWORD ?
CurrTime DWORD ?

; Frame Rate
frames = 60
frameRate = 100000 / 60

;
; Code Section
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
.code

;
; Main Procedure
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
main PROC
		call winSetup

		; Set Console title
        INVOKE SetConsoleTitle, OFFSET titleMessage
STARTOVER::
		call gameMenu
		call Randomize

		mov config.score, 0 ; Initial score
		mov config.time, 120 ; Game time

		INVOKE clear, OFFSET auxPos, OFFSET cursorPos, 1
		INVOKE borderGame, 0, magenta

		; Get current time
		call GetMseconds
		mov firstTime, eax

		;;; MAIN LOOP STARTS OVER HERE
		INVOKE PlaySound, OFFSET gameSoundtrack, NULL, _filename
		
AGAIN:
		; Get current time after each loop
		call GetMseconds
		mov currTime, eax

		; How many time?
		mov ebx, currTime
		sub ebx, firstTime

		; One second!
		cmp ebx, 1000
		jb CONTINUE
		sub config.time, 1
		call GetMseconds
		mov firstTime, eax

CONTINUE:
		cmp config.time, 0
		jna _OVER
		INVOKE optimizedClean
		INVOKE updateConfig
		INVOKE updatePlayers
		INVOKE updateObjects
		INVOKE drawFixedEnvironment
		INVOKE drawParameters
		INVOKE drawDynamicElements
		INVOKE checkColision, ADDR Player1
		INVOKE checkColision, ADDR Player2

		;call GetMseconds
		;sub eax, currTime
		;cmp eax, frameRate
		;jnb AGAIN
		;sub eax, frameRate
		INVOKE Sleep, 500
		jmp AGAIN

_OVER:
		; Clear the display
		INVOKE clear, OFFSET auxPos, OFFSET cursorPos, 0
		INVOKE showScore

		Exit
main ENDP

;
; Procedures
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; borderGame is the procedure responsible to load the game border in a loading style menu.
borderGame PROC USES eax, _delay: BYTE, color: DWORD

		; Which color this time?
		mov eax, color
		call SetTextColor

		; Right-to-Left
		INVOKE drawLine, OFFSET auxPos, OFFSET cursorPos, borderChar, 119, 0, _delay
		; Top-to-Bottom
		INVOKE drawLine, OFFSET auxPos, OFFSET cursorPos, borderChar, 29, 1, _delay
		; Left-to-Right
		INVOKE drawLine, OFFSET auxPos, OFFSET cursorPos, borderChar, 0, 0, _delay
		; Bottom-to-Top
		INVOKE drawLine, OFFSET auxPos, OFFSET cursorPos, borderChar, 0, 1, _delay

		; Return default colors
		mov eax, lightGray
		call SetTextColor

		ret
borderGame ENDP

; gameMenu is the procedure responsible for display the inicial game menu
gameMenu PROC
		INVOKE PlaySound, OFFSET gameSoundtrack, NULL, _filename

		INVOKE setCursor, 25, 10, OFFSET cursorPos
		INVOKE drawData, OFFSET Logo, OFFSET cursorPos, LogoLen

		INVOKE borderGame, 10, magenta
		xor ecx, ecx
		mov ecx, 3

		INVOKE clear, OFFSET auxPos, OFFSET cursorPos, 0		

HOLLYWOOD:
		sub ecx, 1
		push ecx

		; Special effects :D
		INVOKE setCursor, 49, 15, OFFSET cursorPos
		mov edx, OFFSET nothingMessage
		call WriteString
		INVOKE Sleep, 600

		; Display the message
		INVOKE setCursor, 49, 15, OFFSET cursorPos
		mov edx, OFFSET startMessage
		call WriteString
		INVOKE Sleep, 600

		pop ecx
		cmp ecx, 0
		jne HOLLYWOOD
		; Pause the program
		call ReadChar

		mov auxPos.Y, 0
		mov auxPos.X, 0

		; Clean the display
		INVOKE clear, OFFSET auxPos, OFFSET cursorPos, 0
		INVOKE setCursor, 49, 15, OFFSET cursorPos
		mov edx, OFFSET nothingMessage
		call WriteString
		
		INVOKE setCursor, 25, 10, OFFSET cursorPos
		INVOKE drawData, OFFSET Logo, OFFSET cursorPos, LogoLen

		; Loading message
		INVOKE borderGame, 10, magenta
		INVOKE Sleep, 300

		ret
gameMenu ENDP

drawFixedEnvironment PROC
		; Change the support color
		mov eax, brown
		call SetTextColor

		; Draw left support
		INVOKE setCursor, 1, 5, OFFSET cursorPos
		INVOKE drawLine, OFFSET cursorPos, OFFSET cursorPos, borderChar, 45, 0, 0
		INVOKE setCursor, 1, 6, OFFSET cursorPos
		INVOKE drawLine, OFFSET cursorPos, OFFSET cursorPos, borderChar, 45, 0, 0

		; Draw Right support
		INVOKE setCursor, 118, 5, OFFSET cursorPos
		INVOKE drawLine, OFFSET cursorPos, OFFSET cursorPos, borderChar, 74, 0, 0
		INVOKE setCursor, 118, 6, OFFSET cursorPos
		INVOKE drawLine, OFFSET cursorPos, OFFSET cursorPos, borderChar, 74, 0, 0

		; Back console color to white.
		mov eax, lightGray
		call SetTextColor

		ret
drawFixedEnvironment ENDP

drawParameters PROC

		; Draw Seesaw		
		INVOKE setCursor, 17, 22, OFFSET cursorPos
		
		; But which state?
		cmp config.SeesawState, 1
		jb FirstState
		ja ThirdState
		INVOKE drawData, OFFSET SeesawSecondState, OFFSET cursorPos, SeesawLen
		jmp CONTINUE
FirstState:
		INVOKE drawData, OFFSET SeesawFirstState, OFFSET cursorPos, SeesawLen
		jmp CONTINUE
ThirdState:
		INVOKE drawData, OFFSET SeesawThirdState, OFFSET cursorPos, SeesawLen
CONTINUE:

		; Draw Score
		INVOKE setCursor, 56, 1, OFFSET cursorPos
		mov edx, OFFSET scoreMessage
		call WriteString
		INVOKE setCursor, 64, 1, OFFSET cursorPos
		xor eax, eax
		mov al, config.score
		call WriteDec

		; Draw Time
		INVOKE setCursor, 58, 3, OFFSET cursorPos
		mov edx, OFFSET timeMessage
		call WriteString

		ret
drawParameters ENDP


drawDynamicElements PROC

		; Draw artefacts
		xor edx, edx
		mov edi, 0
		
		;cmp edi, LENGTHOF objArr
NEXTOBJ:
		cmp edi, SIZEOF objArr
		ja _END
		cmp (ARTEFACT PTR objArr[edi]).hidden, 1
		je HIDEDONUT
		mov dh, (ARTEFACT PTR objArr[edi]).pos.X
		mov dl, (ARTEFACT PTR objArr[edi]).pos.Y

		mov eax, (ARTEFACT PTR objArr[edi]).color
		call SetTextColor

		INVOKE setCursor, dh, dl, OFFSET cursorPos
		INVOKE drawData, OFFSET Donut, OFFSET cursorPos, DonutLen
		
HIDEDONUT:
		add edi, TYPE ARTEFACT
		jmp NEXTOBJ

_END:

		; Draw Player 1
		mov eax, magenta
		call SetTextColor
		INVOKE setCursor, player1.pos.X, player1.pos.y, OFFSET cursorPos
		INVOKE drawData, OFFSET PlayerSkin, OFFSET cursorPos, PlayerLen

		; Draw Player 2
		mov eax, cyan
		call SetTextColor
		INVOKE setCursor, player2.pos.X, player2.pos.y, OFFSET cursorPos
		INVOKE drawData, OFFSET PlayerSkin, OFFSET cursorPos, PlayerLen

		ret
drawDynamicElements ENDP

drawNumber PROC, first: BYTE, second: BYTE, third: BYTE, begin: PTR POINT, color: DWORD
		mov edi, begin
		xor ebx, ebx

		; Color
		mov eax, color
		call SetTextColor

		; First digit
		xor ecx, ecx
		xor eax, eax
		mov cl, 0
AGAIN:
		cmp first, cl
		jne _ADD
		je CONTINUE
_ADD:
		add cl, 1
		jmp AGAIN

CONTINUE:
		mov al, cl
		mov cl, 8
		mul cl
		mov cl, NumberLen
		mul cl
		mov edx, OFFSET Number
		add edx, eax

		;mov eax, Numberlen
		mov bh, (POINT PTR [edi]).X
		mov bl, (POINT PTR [edi]).Y

		INVOKE setCursor, bh, bl, OFFSET cursorPos
		INVOKE drawData, edx, OFFSET cursorPos, NumberLen

		; Second Digit
		xor ecx, ecx
		xor eax, eax
		mov cl, 0
AGAIN2:
		cmp second, cl
		jne _ADD2
		je CONTINUE2
_ADD2:
		add cl, 1
		jmp AGAIN2

CONTINUE2:
		mov al, cl
		mov cl, 8
		mul cl
		mov cl, NumberLen
		mul cl
		mov edx, OFFSET Number
		add edx, eax
		;mov eax, Numberlen
		INVOKE setCursor, bh, bl, OFFSET cursorPos
		INVOKE moveCursor, 7, 0, OFFSET cursorPos
		INVOKE drawData, edx, OFFSET cursorPos, NumberLen

		; Third
		xor ecx, ecx
		xor eax, eax
		mov cl, 0
AGAIN3:
		cmp third, cl
		jne _ADD3
		je CONTINUE3
_ADD3:
		add cl, 1
		jmp AGAIN3

CONTINUE3:
		mov al, cl
		mov cl, 8
		mul cl
		mov cl, NumberLen
		mul cl
		mov edx, OFFSET Number
		add edx, eax
		;mov eax, Numberlen

		INVOKE setCursor, bh, bl, OFFSET cursorPos
		INVOKE moveCursor, 14, 0, OFFSET cursorPos
		INVOKE drawData, edx, OFFSET cursorPos, NumberLen

		ret
drawNumber ENDP

updatePlayers PROC
		cmp config.onMove, 1
		ja INVERSE
		jb KEYCHECK
		sub player1.pos.Y, 2
		add player2.pos.y, 2
		cmp config.SeesawState, 2
		je CONTINUE1
		add config.SeesawState, 1

CONTINUE1:
		cmp player1.pos.Y, 2 
		ja _END
		mov config.onMove, 0
		jmp _END

INVERSE:
		add player1.pos.Y, 2
		sub player2.pos.y, 2
		cmp config.SeesawState, 0
		je CONTINUE2
		sub config.SeesawState, 1

CONTINUE2:
		cmp player2.pos.Y, 2
		ja _END
		mov config.onMove, 0
		jmp _END

KEYCHECK:
		call ReadKey
		je _END
		cmp al, 32 ; Check if Space was pressed
		jne _END
		cmp player1.pos.Y, 1
		jne TEST2
		mov config.onMove, 2
		jmp _END
TEST2:
		cmp player2.pos.Y, 1
		jne _END
		mov config.onMove, 1
		jmp _END
_END:

		ret
updatePlayers ENDP

updateConfig PROC
		xor ebx, ebx
		xor ecx, ecx
		xor eax, eax
		
		mov bl, config.time
		mov al, bl
		cbw
		mov cl, 100 
		idiv cl ; ah = 23; al = 1
		mov ch, al
		mov al, ah
		mov cl, 10
		cbw
		idiv cl ; ah = 3, al = 2
		mov bl, al
		mov bh, ah

		; Set time position
		mov auxPos.X, 50
		mov auxPos.Y, 4
		 
		INVOKE drawNumber, ch, bl, bh, OFFSET auxPos, cyan

		ret

updateConfig ENDP

updateObjects PROC

		; Hidden objects need a setup!
		xor eax, eax
		xor ecx, ecx

		mov edi, 0
_LOOP:
		cmp edi, SIZEOF objArr
		ja _END
		cmp (ARTEFACT PTR objArr[edi]).hidden, 0
		je NOSETUP
		mov eax, 15
		call RandomRange
		cmp al, 14
		jne NEXT
		mov (ARTEFACT PTR objArr[edi]).hidden, 0
		mov eax, 19
		call RandomRange
		add eax, 2
		mov (ARTEFACT PTR objArr[edi]).pos.Y, al
		mov eax, 2
		call RandomRange
		mov eax, 8
		call RandomRange
		add eax, 1
		mov (ARTEFACT PTR objArr[edi]).color, eax

		mov eax, 2
		call RandomRange
		mov (ARTEFACT PTR objArr[edi]).orien, al
		cmp eax, 1
		je RIGHTSETUP
		mov (ARTEFACT PTR objArr[edi]).pos.X, 108
		jmp NEXT
RIGHTSETUP:
		mov (ARTEFACT PTR objArr[edi]).pos.X, 2
		jmp NEXT


NOSETUP:
		cmp (ARTEFACT PTR objArr[edi]).orien, 1
		je TOTHERIGHT
		sub (ARTEFACT PTR objArr[edi]).pos.X, 6
		cmp (ARTEFACT PTR objArr[edi]).pos.X, 3
		jna HIDEDONUT
		jmp NEXT

TOTHERIGHT:
		add (ARTEFACT PTR objArr[edi]).pos.X, 6
		cmp (ARTEFACT PTR objArr[edi]).pos.X, 108
		jnb HIDEDONUT
		jmp NEXT
HIDEDONUT:
		mov (ARTEFACT PTR objArr[edi]).hidden, 1

NEXT:
		add edi, TYPE ARTEFACT
		jmp _LOOP

_END:
		ret
updateObjects ENDP

optimizedClean PROC

		; Clean Player1
		xor ecx, ecx
		xor ebx, ebx
		mov ch, player1.pos.X
		mov cl, player1.pos.Y
		mov auxPos.X, ch
		mov bh, ch
		add bh, player1._width
		mov auxPos.Y, cl
		mov bl, cl
		add bl, PlayerLen
		
		INVOKE drawRetangle, OFFSET auxPos, OFFSET cursorPos, bh, bl, " ", 0

		; Clean Player2
		mov ch, player2.pos.X
		mov cl, player2.pos.Y
		mov auxPos.X, ch
		mov bh, ch
		add bh, player2._width
		mov auxPos.Y, cl
		mov bl, cl
		add bl, PlayerLen
		
		INVOKE drawRetangle, OFFSET auxPos, OFFSET cursorPos, bh, bl, " ", 0
		
		; Clean Object
		xor edi, edi
_LOOP:
		cmp edi, SIZEOF objArr
		ja _NEXT
		cmp (ARTEFACT PTR objArr[edi]).hidden, 0
		jne _NOPE
		mov bh, (ARTEFACT PTR objArr[edi]).pos.X 
		mov bl, (ARTEFACT PTR objArr[edi]).pos.Y 
		mov auxPos.X, bh
		add bh, (ARTEFACT PTR objArr[edi])._width
		mov auxPos.Y, bl
		add bl, (ARTEFACT PTR objArr[edi]).height

		INVOKE drawRetangle, OFFSET auxPos, OFFSET cursorPos, bh, bl, " ", 0
_NOPE:
		add edi, TYPE ARTEFACT
		jmp _LOOP
_NEXT:
		xor edi, edi
		; Clean Seeasaw
		cmp config.SeesawState, 1
		jb CONDITION1
		ja CONDITION2
		jmp CLEANSEESAW

CONDITION1:
		cmp config.onMove, 1
		je CLEANSEESAW
		jmp _END

CONDITION2:
		cmp config.onMove, 2
		je CLEANSEESAW
		jmp _END

CLEANSEESAW:
		mov auxPos.X, 17
		mov auxPos.Y, 22
		INVOKE drawRetangle, OFFSET auxPos, OFFSET cursorPos, 104, 29, " ", 0
_END:
		ret
optimizedClean ENDP

checkColision PROC, _player: PTR PLAYER
		xor ebx, ebx
		xor ecx, ecx
		xor edx, edx
		xor edi, edi

		mov ebx, _player
		; Get user cordinates
		mov ch, (PLAYER PTR [ebx]).pos.X
		mov cl, (PLAYER PTR [ebx]).pos.Y

		; Iterate over each element
_LOOP:
		cmp edi, SIZEOF objArr
		ja _END
		cmp (ARTEFACT PTR objArr[edi]).hidden, 1
		je CONTINUE
		mov ah, (ARTEFACT PTR objArr[edi]).pos.X
		mov al, (ARTEFACT PTR objArr[edi]).pos.Y
		cmp ah, ch
		jb MIDDLEFT
		add ch, (PLAYER PTR [ebx])._width
		cmp ah, ch
		jb CHECKHEIGHT
		jmp CONTINUE

MIDDLEFT:
		add ah, (ARTEFACT PTR objArr[edi])._width
		cmp ah, ch
		ja CHECKHEIGHT
		jmp CONTINUE

CHECKHEIGHT:
		; Get user cordinates
		mov ch, (PLAYER PTR [ebx]).pos.X
		mov cl, (PLAYER PTR [ebx]).pos.Y

		cmp al, cl
		ja MIDDLEBOTTOM
		add al, (ARTEFACT PTR objArr[edi]).height
		cmp al, cl
		ja CRASH
		jmp CONTINUE

MIDDLEBOTTOM:
		push ecx
		add cl, (PLAYER PTR [ebx]).height
		cmp al, cl
		pop ecx
		jb CRASH
		jmp CONTINUE

CRASH:
		xor edx, edx
		mov dl, (ARTEFACT PTR objArr[edi]).score
		add config.score, dl
		mov (ARTEFACT PTR objArr[edi]).hidden, 1
		mov dh, (ARTEFACT PTR objArr[edi]).pos.X 
		mov dl, (ARTEFACT PTR objArr[edi]).pos.Y
		mov auxPos.X, dh
		mov auxPos.Y, dl
		push edx
		add dh, (ARTEFACT PTR objArr[edi])._width
		add dl, (ARTEFACT PTR objArr[edi]).height
		INVOKE drawRetangle, OFFSET auxPos, OFFSET cursorPos, dh, dl, " ", 0
		pop edx

CONTINUE:
		add edi, TYPE ARTEFACT
		jmp _LOOP

_END:
		ret

checkColision ENDP

showScore PROC

		INVOKE PlaySound, OFFSET gameSoundtrack, NULL, _filename
		INVOKE clear, OFFSET auxPos, OFFSET cursorPos, 0
		INVOKE setCursor, 10, 5, OFFSET cursorPos
		INVOKE drawData, OFFSET Over, OFFSET cursorPos, OverLen
		INVOKE setCursor, 10, 15, OFFSET cursorPos
		INVOKE drawData, OFFSET Score, OFFSET cursorPos, ScoreLen

		; Show score as numbers
		mov bl, config.score
		mov al, bl
		cbw
		mov cl, 100 
		idiv cl ; ah = 23; al = 1
		mov ch, al
		mov al, ah
		mov cl, 10
		cbw
		idiv cl ; ah = 3, al = 2
		mov bl, al
		mov bh, ah

		; Set time position
		mov auxPos.X, 80
		mov auxPos.Y, 6
		 
		INVOKE drawNumber, ch, bl, bh, OFFSET auxPos, yellow
		
		; Start over
		INVOKE setCursor, 45, 25, OFFSET cursorPos
		mov eax, gray
		call SetTextColor
		mov edx, OFFSET startMessage
		call WriteString

		call ReadChar
		INVOKE clear, OFFSET auxPos, OFFSET cursorPos, 1
		INVOKE setCursor, 0, 0, OFFSET cursorPos
		jmp STARTOVER
showScore ENDP

END main