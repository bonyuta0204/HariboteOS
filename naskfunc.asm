; naskfunc
; TAB = 4

[BITS 32]

; オブジェクトファイルのための情報


GLOBAL io_hlt
GLOBAL write_mem8

[SECTION .text]
io_hlt:
  HTL
  RET

write_mem8:
  MOV ECX,[ESP+4]
  MOV AL,[ESP+8]
  MOV [ECX],AL
  RET

