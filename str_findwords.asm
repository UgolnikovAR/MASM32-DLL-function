.586P
.MODEL FLAT, STDCALL
;-----------------------------
PUBLIC str_findwords	; void str_findwords(pbase:dd, pcurr:dd, size:dd, destynation:dd)
;-----------------------------
_DATA SEGMENT

	destynation dd 0 ;������� � ������-����������
	
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
	mov BYTE ptr[EDI], 32			; ���������� ������ ������ ����� ������ ��� ������
;-------------------------------------
GrandLoop:;���� ������ ����� ��������� 
          ;���������� �������, ���� �� NUL
	cmp  BYTE ptr[EAX], 0	;��������� �������, ���� ������ ������ �������� ������ - '0'(NUL)
	JE   _END
	mov  ECX, 0				;ECX - ������� ���������� �������� � ����� �������� ������
;---------------------------------------
SubLoop:;���� ���������� ����� ��������� 
		;������� ���������� �������� ���� �� ������
		;��� �� NUL
	cmp  BYTE ptr[EAX], 32
	JE	 Next1
	cmp  BYTE ptr[EAX], 0
	JE	 Next1
	inc  EAX
	inc  ECX
	JMP  SubLoop
;---------------------------------------
Next1:;���� � ������ ������� ������
	  ;� ������� ������� ����� size,
	cmp  BYTE ptr[EAX], 32
	JNE  Next2
	cmp  ECX, EBX
	JNE  Next2
	;--------------- ;����� �������� ��� ����� � ������ ������
	push EDI
	push EAX
	push ESI
	CALL str_wordcpy
	inc  EAX		 ;������� � ���������� �������
	add  EDI, EBX	 ;����������� destynation �� size ��������
	mov  ESI, EAX	 ;���������� ������� pbase (������ �����)
	JMP  GrandLoop
;---------------------------------------
Next2:;���� � ������ ������� ������
	  ;� ������� ������� �� ����� size,
	cmp BYTE ptr[EAX], 32
	JNE Next3
	cmp ECX, EBX
	JE  Next3
	;--------------- ;�����
	inc  EAX		 ;������� � ���������� �������
	mov  ESI, EAX	 ;���������� ������� pbase (������ �����)
	JMP  GrandLoop
;---------------------------------------
Next3:;1)���� ������ NUL
	  ;2)� ������� ������� ����� size, ����� �������� ��� ����� � ������ ������
	cmp  EAX, 0		;1-� �������
	JNE  GrandLoop
	;-------------
	cmp  ECX, EBX	;2-� �������
	JNE  GrandLoop
	;-------------
	push EDI
	push EAX
	push ESI
	CALL str_wordcpy
	add  EDI, EBX	 ;����������� destynation �� size ��������
	JMP  GrandLoop
;---------------------------------------
_END:
	pop ECX
	pop EDI
	pop EBX
	pop EAX
	pop ESI
	
	add DWORD ptr[EBP+8], 8
	mov EAX, DWORD ptr[EBP+8] ;������� ��������� �� destynation ������ � EAX (�� ��� ������)
	
	mov ESP, EBP
	pop EBP
	
	RET 16
str_findwords ENDP
;------------------------------------------------------------------------------

str_wordcpy PROC
	push  EBP	;���������� ��������� � �����
	mov   EBP, ESP
	push  ESI
	push  EDI
	push  EAX
	push  ECX
	;------------------------
	;�������� ���������� ������� �� ����� � ��������
	mov   ESI, DWORD ptr[EBP+ 8]    ;pbase
	mov   EAX, DWORD ptr[EBP+12]    ;pcurr
	mov   EDI, DWORD ptr[EBP+16] 	;destynation
	mov   ECX, 0					;CL,  tmp_EDX
;-------------------------------------------------------------------
	cmp   destynation, 0 ;���� �������� destynation ����������, ����� ��������� ��� � EDI ������ ���������
	JE	  go_throw
	mov   EDI, destynation
go_throw:
;-------------------------------------------------------------------
	;�������� ���������� ������� �������
	;(���� ����, �� ������ ���� �������� ������ � ����� ����. ������)
	mov   CL, BYTE ptr[EDI]
	cmp   CL, 0
	JNE	  body_0
	mov   BYTE ptr[EDI], 32
	inc   EDI
body_0:;���� ����� ����������� �����
	cmp   ESI, EAX
	JNE	  copy_byte
	;���������� ���������
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
	pop  ECX		;�������������� ��������� �� �����
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