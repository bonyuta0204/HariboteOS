; naskfunc
; TAB = 4

[BITS 32]

; オブジェクトファイルのための情報


GLOBAL io_hlt

[SECTION .text]
io_hlt:
  HTL
  RET

