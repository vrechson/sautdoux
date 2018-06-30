; Utils.inc 
;
; is an include for our game where I define procedures that will simplify the game develop and promove code reuse
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
.data
; Windows API
outHandle DWORD ?
cursorInfo CONSOLE_CURSOR_INFO <>

currColor DWORD white


.code

; winSetup - setup the windows screen to start the game properly
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
winSetup PROC USES eax
        call Clrscr				; Just this time!!

        ; Hide the cursor (we won't use it in this game)
        INVOKE GetStdHandle, STD_OUTPUT_HANDLE
        mov outHandle, eax
        INVOKE GetConsoleCursorInfo, outHandle, ADDR cursorInfo
        mov cursorInfo.bVisible, FALSE
        INVOKE SetConsoleCursorInfo, outHandle, ADDR cursorInfo

        ; Generate a new seed for our game :)
        call Randomize

        ret
winSetup ENDP

; setCursor - set a new cursor position
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
setCursor PROC USES edx esi, col: BYTE, row: BYTE, currPos: PTR POINT
        mov esi, currPos
        mov dl, col
        mov (POINT PTR [esi]).X, dl
        mov dh, row
        mov (POINT PTR [esi]).Y, dh
        call Gotoxy
        ret
setCursor ENDP

; moveCursor - move the current cursor position by a offset
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
moveCursor PROC USES edx esi, col: SBYTE, row: SBYTE, currPos: PTR POINT
        mov esi, currPos
        mov dl, col
        mov dh, row
        add dl, (POINT PTR [esi]).X
        add dh, (POINT PTR [esi]).Y
        INVOKE setCursor, dl, dh, currPos
        ret
moveCursor ENDP

; drawLine - draw a vertical or horizontal line on the screen
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
drawLine PROC USES eax esi edx, begin: PTR POINT, currPos: PTR POINT, _char: BYTE, _offset: BYTE, orient: BYTE, _delay: BYTE
       
        xor eax, eax ; clean eax
        mov esi, begin ; get begin values
        mov dh, (POINT PTR [esi]).X
        mov dl, (POINT PTR [esi]).Y 
        push edx
        INVOKE setCursor, dh, dl, currPos ; put the cursor in the first point
        pop edx
        cmp orient, 0
        je HORIZONTAL
        cmp _offset, dl
        je _END ; where i'm?
        ja VPOSITIVE_OFFSET
        sub (POINT PTR [esi]).Y, 1
        jmp CONTINUE   

VPOSITIVE_OFFSET:
        add (POINT PTR [esi]).Y, 1
        jmp CONTINUE

HORIZONTAL:
        cmp _offset, dh
        je _END ; where i'm?
        jg HPOSITIVE_OFFSET
        sub (POINT PTR [esi]).X, 1
        jmp CONTINUE   

HPOSITIVE_OFFSET:
        add (POINT PTR [esi]).X, 1


CONTINUE:
        mov al, _char
        call WriteChar
        INVOKE Sleep, _delay
        INVOKE drawLine, begin, currPos, _char, _offset, orient, _delay

_END:
        ret
drawLine ENDP

; drawRectangle - draw a rectangle on the screen, important to clean game regions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
drawRetangle PROC USES esi ecx, begin: PTR POINT, currPos: PTR POINT, col: BYTE, row: BYTE, _char: BYTE, _delay: BYTE
        xor ecx, ecx
        mov esi, begin
        mov ch, (POINT PTR [esi]).X
        mov cl, (POINT PTR [esi]).Y
DO:
        cmp cl, row
        je _END
        pushfd
        push ecx
        INVOKE drawLine, begin, currPos, _char, col, 0, _delay
        pop ecx
        mov (POINT PTR [esi]).X, ch
        popfd
        ja DECREASE
        add cl, 1
        mov (POINT PTR [esi]).Y, cl
        jmp DO     
DECREASE:
        sub cl, 1
        mov (POINT PTR [esi]).Y, cl
        jmp DO    
        
_END:
        ret
drawRetangle ENDP

; clean - clean the windows screen
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
clear PROC USES esi, currPos: PTR POINT, cleanPos: PTR POINT, keepBorder: BYTE
        mov esi, cleanPos
        mov edi, currPos
        ; Put the cursor in the begining
        mov (POINT PTR [esi]).X, 0
        mov (POINT PTR [esi]).Y, 0

        cmp keepBorder, 0
        jne KEEP
        ; Clean everything
        INVOKE drawRetangle, cleanPos, currPos, 120, 30, " ", 0
        jmp CONTINUE
KEEP:
        add (POINT PTR [esi]).X, 1
        add (POINT PTR [esi]).Y, 1
        INVOKE drawRetangle, cleanPos, currPos, 119, 28, " ", 0
        
CONTINUE:
        ; Back to the first position
	mov (POINT PTR [esi]).X, 0
	mov (POINT PTR [esi]).Y, 0
	mov (POINT PTR [edi]).X, 0
        mov (POINT PTR [edi]).Y, 0

        ret
clear ENDP

; drawData - draw in console something allocated in data section segment
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
drawData PROC USES ebx ecx esi edx, _addr: PTR BYTE, currPos: PTR POINT, len: BYTE
        xor ecx, ecx
        xor ebx, ebx

        ; Cursor Setup
        mov esi, currPos
        mov ch, (POINT PTR [esi]).X
        mov cl, (POINT PTR [esi]).Y
        push ecx
        mov edx, _addr
PRINT_LINE:
        pop ecx

        ; Retrieve cursor position
        INVOKE setCursor, ch, cl, currPos
        mov (POINT PTR [esi]).X, ch
        inc cl
        mov (POINT PTR [esi]).Y, cl
        push ecx

        ; Draw line
        call WriteString

        ; Add an offset to the next line
        call StrLength
        add edx, eax
        inc edx
        inc ebx
        cmp bl, len
        jb PRINT_LINE

        ; Pop ecx again
        pop ecx
        ret
drawData ENDP

; drawTime - draw the time in console
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
