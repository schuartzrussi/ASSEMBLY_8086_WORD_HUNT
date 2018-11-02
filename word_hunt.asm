;; ============================ ASSEMBLY 8086 WORD HUNT ============================
;; Author: Ruan Schuartz Russi
;; Email: schuartzrussi@gmail.com
;; =================================================================================

data segment
    counter db 0
    column_counter db 0 
    column dw 0
    line dw 0
    number_of_letters dw 0
    search db 20, 22 dup('?')
    pkey db "B$"
    breaklinevar db 13, 10, "$"
    cursor_color dw 00100000B
    area_color db 00110000B
    
    WORD_HUNT 	DB	"ASDFKASJFSKASJDFLKJASKRUEIJDSLFJKLSAJKDSVMNMSDPFKVLSADFDSART"
				DB	"KSAOJFLKASTFLKASAJSDKFJSADKFJKSADJFLKSAJFKLJSALKFJLKASJCFKAA"
				DB	"ASJDFKSADKFASKAREJADSREWUUTJBKNBDKGFPTHHFKSJRKDAJDKSHHAASDBB"
				DB	"JDSAKFJESIURRMLNFSKTYRSIUOVHKLSDFGREUIFSLKGHRESUOHKSDNKLSUAA"
				DB	"RUQLIOEUROIQEWURIODSMSADFJKSDJVXCMJASDKFVSALKFJKLSADNFLKSDUU"
				DB	"ASKCFJKALSDGFLKASDJFLKSAJDFLKASJDKLFJSALIKFJLSDKAJKESASLKAHH"
				DB	"RQWLIRUQWEIADFJHSADJFWARDIFUIWQUERIUEWASDDJSATKLFJRDOKJFSSEE"
				DB	"ASDIFPOASIDMOPSAIDFOPAISDOPFIASOPFISAPODEIOPASDIFOPSAIFOOFHH"
				DB	"ASDNASDKFLSEDKFLASKDFCLSAIDOFRIEJJVDFSAIOOSADIFOSDIOPFISDODD"
				DB	"ASPUFIASPOAFIPAOSDFIPACOCOMPUTERFOPSADIFOPSDIFOPSDAOPFDSATJA"
				DB	"ASDXIEWCPAIEWOIREWOOQIROQWEIROPEWQIRPOWQEOOPREWQORIWQEPOIAEE"
				DB	"ASDFASCJRKASDJFKLASDSEEKDSAJFLKSDAJFASLKCDJFOICSADFDSKSLPDEE"
				DB	"ASDFAIDOISADFISOADILAEDFISAODIFOSADIFSAODPICPVSADIFOPDSAISAA"
				DB	"ASDOSFSADFINVNCXJDFIIEDSNFLSDAFUSADFUSDAIFEISODUFIODSANISDDD"
				DB	"QWEUUSIDWERUIOQWEURZOWEQUIRWEQUIORUQWOEIUANVDMSADFKLSEDALKBB"
				DB	"LSMDEPOOESNVMXNCFDSAKLSEESLAFSHVAFDJNFSYNDSNFSDAYUEQSDSAAMCC"
				DB	"ALSRKLAODKYCASDLIURRWEUIRTRUERIOQEWURIOFDSHFJSADHFJESDADEDAD"
				DB	"VXPMZXEGUOMSZNCVMIEBNOTILISOSDIOFISDAOFIOSADIFODSIFOSDATODVD"
				DB	"QMIERUQIWERUIQWEURIOQWRURIQWUERIUQWEIRUQWIOERUIQWEURIEYUUQAA"
				DB	"IWERQUWIRUQWEIORUQIWOEYUOIQWEUROIQWUEROIUQWOIEWRUIWSDSFSDHJQ",0
ends

stack segment
    dw   128  dup(0)
ends

code segment
start:
    mov ax, data
    mov ds, ax
    mov ax, 0b800h
    mov es, ax
      
SET_BACKGROUND_COLOR:    
    mov cx, 4001
    mov dx, 11111111B
    
    SET_BACKGROUND:
        mov bx, cx 
        mov es:[bx], dx
            
        inc counter
           
        cmp counter, 5
        je ALTERNATE_BACKGROUND_COLOR
        
        cmp cx, 0
        jl DRAW_AREA
            
        dec cx 
           
        loop SET_BACKGROUND
    
            
    ALTERNATE_BACKGROUND_COLOR:
        mov counter, 0
        
        cmp dx, 11111111B
        je cor_2
        mov dx, 11111111B
        jmp SET_BACKGROUND  
        
        cor_2:
            mov dx, 00000000B
            jmp SET_BACKGROUND
            
DRAW_AREA:
    mov column_counter, 0
    mov si, 1200
    mov counter, 0
    mov dl, area_color
    mov cx, 3501
    mov bx, cx

    PAINT_AREA:
        cmp column_counter, 20
        je  DRAW_CURSOR
    
        cmp counter, 0
        je  FIRST_COLUMN
        
        dec si
        
        mov dh, WORD_HUNT[si]
        
        cmp dh, 90
        jg  LETTER_FOUND 
        
        mov dl, area_color
        jmp SHOW_LETTER
        
        LETTER_FOUND:
            inc cx
            mov bx, cx 
            mov es:[bx], dx
            dec cx
            mov dh, WORD_HUNT[si] 
            mov dl, area_color
            sub dh, 26     
            jmp SHOW_LETTER
        
        FIRST_COLUMN:
            mov dh, 0
            mov dl, area_color           
        
        SHOW_LETTER:
            mov bx, cx    
            mov es:[bx], dx 

        CONTINUE:
            dec cx
            inc counter
            cmp counter, 60
            jg NEW_LINE_AREA 
            
            loop PAINT_AREA
            
            NEW_LINE_AREA:
                mov counter, 0
                inc column_counter
                sub cx, 38  
                mov dl, area_color
                loop PAINT_AREA

DRAW_SUCCESS_CURSOR:
    mov cursor_color, 00100000B
    jmp DRAW_AREA 

DRAW_ERROR_CURSOR:
    mov cursor_color, 01000000B
    jmp DRAW_CURSOR    
            
DRAW_CURSOR:
    mov cx, 3775
    mov dx, cursor_color
    
    DRAW_CURSOR_LOOP:
        mov bx, cx
        mov es:[bx], dx 
        
        cmp bx, 3739
        jl SET_CURSOR
        dec cx
        loop DRAW_CURSOR_LOOP                    

SET_CURSOR:
    mov dh, 23
	mov dl, 28
	mov bh, 0
	mov ah, 2
	int 10h
    
    lea dx, search
    mov ah, 0ah
    int 21h
    mov bx, dx
    mov ah, 0
    mov al, ds:[bx+1]
    mov number_of_letters, ax
    add bx, ax
    mov byte ptr [bx+2], '$'
    mov si, 0

    cmp number_of_letters, 4
    jl SEARCH_WORD
    
    cmp search[2], "E"
    jne CHECK_HARD
    cmp search[3], "X"
    jne CHECK_HARD
    cmp search[4], "I"
    jne CHECK_HARD
    cmp search[5], "T"
    jne CHECK_HARD
    jmp FIM
    
CHECK_HARD:
    cmp search[2], "H"
    jne CHECK_EASY
    cmp search[3], "A"
    jne CHECK_EASY
    cmp search[4], "R"
    jne CHECK_EASY
    cmp search[5], "D"
    jne CHECK_EASY
    mov area_color, 11111111B
    jmp DRAW_AREA

CHECK_EASY:
     cmp search[2], "E"
     jne CHECK_RESET
     cmp search[3], "A"
     jne CHECK_RESET
     cmp search[4], "S"
     jne CHECK_RESET
     cmp search[5], "Y"
     jne CHECK_RESET
     mov area_color, 00110000B
     jmp DRAW_AREA
     
CHECK_RESET:
    cmp number_of_letters, 5
    jne SEARCH_WORD
    cmp search[2], "R"
    jne SEARCH_WORD
    cmp search[3], "E"
    jne SEARCH_WORD
    cmp search[4], "S"
    jne SEARCH_WORD
    cmp search[5], "E"
    jne SEARCH_WORD
    cmp search[6], "T"
    jmp RESET_GAME
                 
SEARCH_WORD:
    cmp WORD_HUNT[si], 0
    je DRAW_ERROR_CURSOR
    
    mov al, search[2]
    cmp al, WORD_HUNT[si]
    je FOUND_FIRST_LETTER
    
    inc si
    inc column
    
    cmp column, 60
    je NEW_LINE
    
    jmp SEARCH_WORD
    
NEW_LINE:
    mov column, 0
    inc line
    jmp SEARCH_WORD
    
FOUND_FIRST_LETTER:
    push si

    mov cx, 60
    mov dx, 1
    call RESET
    call SEARCH_COMPLETE_WORD
    pop si
    push si
    mov dx, -1
    call RESET
    call SEARCH_COMPLETE_WORD
    
    mov cx, 1199
    call RESET
    pop si
    push si
    mov dx, 60
    call SEARCH_COMPLETE_WORD
    mov dx, -60
    call RESET 
    pop si
    push si
    call SEARCH_COMPLETE_WORD

    mov cx, 1199
    call RESET
    pop si
    push si
    mov dx, 59
    call SEARCH_COMPLETE_WORD
    mov dx, -59
    call RESET 
    pop si
    push si
    call SEARCH_COMPLETE_WORD
    
    mov cx, 1199
    call RESET
    pop si
    push si
    mov dx, 61
    call SEARCH_COMPLETE_WORD
    mov dx, -61
    call RESET 
    pop si
    push si
    call SEARCH_COMPLETE_WORD
    
    pop si
    inc si
    jmp SEARCH_WORD

SEARCH_COMPLETE_WORD:
    inc di

    cmp di, number_of_letters
    je FOUND_WORD
    
    inc bx
    add si, dx
    
    cmp bx, cx
    jg RETURN
    cmp si, 0
    jl RETURN
    
    mov al, search[bx]
    cmp al, WORD_HUNT[si]
    je SEARCH_COMPLETE_WORD

    ret
    
RETURN:
    ret
    
FOUND_WORD:
    cmp number_of_letters, 0
    je DRAW_SUCCESS_CURSOR
    add WORD_HUNT[si], 26
    sub number_of_letters, 1
    sub si, dx
    jmp FOUND_WORD
    
RESET:
    mov bx, 2
    mov di, 0
    ret
    
RESET_GAME:
    mov si, -1
    LOOP_RESET:
        inc si
        mov ah, WORD_HUNT[si]
        cmp ah, 0
        je DRAW_AREA
        
        cmp ah, 90
        jg RESET_CHAR
        
        jmp LOOP_RESET
        
        RESET_CHAR:
            sub ah, 26
            mov WORD_HUNT[si], ah
            jmp LOOP_RESET            

FIM:
    mov ax, 4c00h
    int 21h    
ends

end start
