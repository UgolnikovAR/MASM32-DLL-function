.586P
.MODEL FLAT, STDCALL
;-----------------------------
PUBLIC str_findwords	; void str_findwords(pbase:dd, pcurr:dd, size:dd, destynation:dd)
;-----------------------------
_DATA SEGMENT

	destynation dd 0 ;позиция в строке-назначении
	
_DATA ENDS

_TEXT SEGMENT

DLLENTRY proc
;[EBP+16] reserved
;[EBP+12] reason
;[EBP+ 8] hInstDLL
    push EBP
    mov EBP, ESP
    mov EAX, -1
    ret 12
DLLENTRY endp



str_findwords PROC EXPORT
	push EBP
	mov  EBP, ESP
	push ESI
	push EAX
	push EBX
	push EDI
	push ECX
	;---------------------------------
	mov  EDI,  DWORD ptr[EBP+ 8]	;destynation
	mov  ESI,  DWORD ptr[EBP+12]	;pbase
	mov  EBX,  DWORD ptr[EBP+16]	;size
	mov	 EAX,  ESI					;pcurr
	add  EDI,  8
	mov  ECX,  0					;counter
	;---------------------------------
	mov BYTE ptr[EDI], 32			; установить первый символ новой строки как пробел
;-------------------------------------
GrandLoop:;тело общего цикла процедуры 
          ;Перебирать символы, пока не NUL
	cmp  BYTE ptr[EAX], 0	;завершить функцию, если первый символ исходной строки - '0'(NUL)
	JE   _END
	mov  ECX, 0				;ECX - счетчик количества символов в слове исходной строки
;---------------------------------------
SubLoop:;тело вложенного цикла процедуры 
		;считаем количество символов пока не пробел
		;или не NUL
	cmp  BYTE ptr[EAX], 32
	JE	 Next1
	cmp  BYTE ptr[EAX], 0
	JE	 Next1
	inc  EAX
	inc  ECX
	JMP  SubLoop
;---------------------------------------
Next1:;Если в строке нашелся пробел
	  ;и счетчик размера равен size,
	cmp  BYTE ptr[EAX], 32
	JNE  Next2
	cmp  ECX, EBX
	JNE  Next2
	;--------------- ;тогда копируем это слово в другую строку
	push EDI
	push EAX
	push ESI
	CALL str_wordcpy
	inc  EAX		 ;переход к следующему символу
	add  EDI, EBX	 ;перемещение destynation на size символов
	mov  ESI, EAX	 ;перемещаем позицию pbase (начала слова)
	JMP  GrandLoop
;---------------------------------------
Next2:;Если в строке нашелся пробел
	  ;и счетчик размера не равен size,
	cmp BYTE ptr[EAX], 32
	JNE Next3
	cmp ECX, EBX
	JE  Next3
	;--------------- ;тогда
	inc  EAX		 ;переход к следующему символу
	mov  ESI, EAX	 ;перемещаем позицию pbase (начала слова)
	JMP  GrandLoop
;---------------------------------------
Next3:;1)Если символ NUL
	  ;2)и счетчик размера равен size, тогда копируем это слово в другую строку
	cmp  EAX, 0		;1-е условие
	JNE  GrandLoop
	;-------------
	cmp  ECX, EBX	;2-е условие
	JNE  GrandLoop
	;-------------
	push EDI
	push EAX
	push ESI
	CALL str_wordcpy
	add  EDI, EBX	 ;перемещение destynation на size символов
	JMP  GrandLoop
;---------------------------------------
_END:
	pop ECX
	pop EDI
	pop EBX
	pop EAX
	pop ESI
	
	add DWORD ptr[EBP+8], 8
	mov EAX, DWORD ptr[EBP+8] ;возврат указателя на destynation строку в EAX (во вне короче)
	
	mov ESP, EBP
	pop EBP
	
	RET 16
str_findwords ENDP
;------------------------------------------------------------------------------

str_wordcpy PROC
	push  EBP	;сохранение регистров в стеке
	mov   EBP, ESP
	push  ESI
	push  EDI
	push  EAX
	push  ECX
	;------------------------
	;загрузка параметров функции из стека в регистры
	mov   ESI, DWORD ptr[EBP+ 8]    ;pbase
	mov   EAX, DWORD ptr[EBP+12]    ;pcurr
	mov   EDI, DWORD ptr[EBP+16] 	;destynation
	mov   ECX, 0					;CL,  tmp_EDX
;-------------------------------------------------------------------
	cmp   destynation, 0 ;если значение destynation изменялось, тогда загрузить его в EDI вместо параметра
	JE	  go_throw
	mov   EDI, destynation
go_throw:
;-------------------------------------------------------------------
	;проверка ненулевого первого символа
	;(если ноль, то вместо него ставится пробел и тогда след. символ)
	mov   CL, BYTE ptr[EDI]
	cmp   CL, 0
	JNE	  body_0
	mov   BYTE ptr[EDI], 32
	inc   EDI
body_0:;тело цикла копирования слова
	cmp   ESI, EAX
	JNE	  copy_byte
	;завершение процедуры
	mov   BYTE ptr[EDI], 0
	JMP	  _EXIT
	
;--------------------------------------------
copy_byte:
	mov   CL, BYTE ptr[ESI]
	mov   BYTE ptr[EDI], CL
	inc   ESI
	inc   EDI
	JMP   body_0

;--------------------------------------------

_EXIT:
	mov  DWORD ptr[destynation], EDI
	pop  ECX		;восстановление регистров из стека
	pop  EAX
	pop  EDI
	pop  ESI
	mov  ESP, EBP
	pop  EBP
	
	RET 12
str_wordcpy endp
_TEXT ENDS
END
END DLLENTRY