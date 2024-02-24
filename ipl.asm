; haribote-ipl
; TAB=4

CYLS	EQU		10				; どこまで読み込むか

		ORG		0x7c00			; このプログラムがどこに読み込まれるのか

; 以下は標準的なFAT12フォーマットフロッピーディスクのための記述

		JMP		entry
		DB		0x90
		DB		"HARIBOTE"		;BS_OEMName ブートセクタの名前を自由に書いてよい（8バイト）
		DW		512				; BPB_BytsPerSec 1セクタの大きさ（512にしなければいけない）
		DB		1		  		; BPB_SecPerClus クラスタの大きさ（1セクタにしなければいけない）
		DW		32				; BPB_RsvdSecCnt FATがどこから始まるか（普通は1セクタ目からにする）
		DB		2				  ; BPB_NumFATs FATの個数（2にしなければいけない）
		DW		0 				; BPB_RootEntCnt ルートディレクトリ領域の大きさ（普通は224エントリにする）
		DW		0	    		; BPB_TotSec16 このドライブの大きさ（2880セクタにしなければいけない）
		DB		0xf0			; BPB_Media メディアのタイプ（0xf0にしなければいけない）
		DW		0				  ; BPB_FATSz16 FAT領域の長さ（9セクタにしなければいけない）
		DW		18				; BPB_SecPerTrk 1トラックにいくつのセクタがあるか（18にしなければいけない）
		DW		2				  ; BPB_NumHeads ヘッドの数（2にしなければいけない）
		DD		0				  ; BPB_HiddSec パーティションを使ってないのでここは必ず0
		DD		2880			; BPB_TotSec32 このドライブ大きさをもう一度書く
    DD    512       ; BPB_FATSz32
    DW    0         ; BPB_ExtFlags
    DW    0         ; BPB_FSVer
    DD    2         ; BPB_RootClus
    DW    1         ; BPB_FSInfo
    DW    6         ; BPB_BkBootSec
    TIMES	12 DB 0		; BPB_Reserved
    DB    1         ; BS_DrvNum
    DB    1         ; BS_Reserved1
    DB    1         ; BS_BootSig
    DD    1         ; BS_VolID
    DB    "AAAAAAAAAAA" ; BS_VolLab
    DB    "FAT32   "; BS_FilSysType
		;RESB	18				; とりあえず18バイトあけておく
		TIMES	18 DB 0		; NASMでは警告が出るので修正

; プログラム本体

entry:
		MOV		AX,0			; レジスタ初期化
		MOV		SS,AX
		MOV		SP,0x7c00
		MOV		DS,AX

; ディスクを読む

		MOV		AX,0x0820
		MOV		ES,AX
		MOV		CH,0			; シリンダ0
		MOV		DH,0			; ヘッド0
		MOV		CL,2			; セクタ2
readloop:
		MOV		SI,0			; 失敗回数を数えるレジスタ
retry:
		MOV		AH,0x02			; AH=0x02 : ディスク読み込み
		MOV		AL,1			; 1セクタ
		MOV		BX,0
		MOV		DL,0x00			; Aドライブ
		INT		0x13			; ディスクBIOS呼び出し
		JNC		next			; エラーがおきなければnextへ
		ADD		SI,1			; SIに1を足す
		CMP		SI,5			; SIと5を比較
		JAE		error			; SI >= 5 だったらerrorへ
		MOV		AH,0x00
		MOV		DL,0x00			; Aドライブ
		INT		0x13			; ドライブのリセット
		JMP		retry
next:
		MOV		AX,ES			; アドレスを0x200進める
		ADD		AX,0x0020
		MOV		ES,AX			; ADD ES,0x020 という命令がないのでこうしている
		ADD		CL,1			; CLに1を足す
		CMP		CL,18			; CLと18を比較
		JBE		readloop		; CL <= 18 だったらreadloopへ
		MOV		CL,1
		ADD		DH,1
		CMP		DH,2
		JB		readloop		; DH < 2 だったらreadloopへ
		MOV		DH,0
		ADD		CH,1
		CMP		CH,CYLS
		JB		readloop		; CH < CYLS だったらreadloopへ

; 読み終わったのでharibote.sysを実行だ！

		MOV		[0x0ff0],CH		; IPLがどこまで読んだのかをメモ
		JMP		0xc200

error:
		MOV		SI,msg
putloop:
		MOV		AL,[SI]
		ADD		SI,1			; SIに1を足す
		CMP		AL,0
		JE		fin
		MOV		AH,0x0e			; 一文字表示ファンクション
		MOV		BX,15			; カラーコード
		INT		0x10			; ビデオBIOS呼び出し
		JMP		putloop
fin:
		HLT						; 何かあるまでCPUを停止させる
		JMP		fin				; 無限ループ
msg:
		DB		0x0a, 0x0a		; 改行を2つ
		DB		"load error"
		DB		0x0a			; 改行
		DB		0

		;RESB	0x7dfe-$		; 0x7dfeまでを0x00で埋める命令
		TIMES	0x1fe-($-$$) DB 0	;NASM用に修正 $から$-$$に、RESBからTIMES DB0へ

		DB		0x55, 0xaa
