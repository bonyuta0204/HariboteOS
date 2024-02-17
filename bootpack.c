#include "bootpack.h"

extern struct FIFO8 keyinfo;

void HariMain(void) {
  struct BOOTINFO *binfo;

  char *vram;
  int xsize, ysize;
  char s[40], mcursor[256], keybuf[32];
  int mx, my, i;

  fifo8_init(&keyinfo, 32, keybuf);

  binfo = (struct BOOTINFO *)0x0ff0;

  init_gdtidt();
  init_pic();
  io_sti(); /* IDT/PICの初期化が終わったのでCPUの割り込み禁止を解除 */

  init_screen8(binfo->vram, binfo->scrnx, binfo->scrny);

  mx = (binfo->scrnx - 16) / 2; /* 画面中央になるように座標計算 */
  my = (binfo->scrny - 28 - 16) / 2;
  init_mouse_cursor8(mcursor, COL8_008484);
  putblock8_8(binfo->vram, binfo->scrnx, 16, 16, mx, my, mcursor, 16);
  sprintf(s, "(%d, %d)", mx, my);
  putfonts8_asc(binfo->vram, binfo->scrnx, 0, 0, COL8_FFFFFF, s);

  io_out8(PIC0_IMR, 0xf9); /* PIC1とキーボードを許可(11111001) */
  io_out8(PIC1_IMR, 0xef); /* マウスを許可(11101111) */

  for (;;) {
    io_cli();

    if (fifo8_status(&keyinfo) == 0) {
      io_stihlt();
    } else {
      i = fifo8_get(&keyinfo);

      io_sti();
      sprintf(s, "%d", i);
      boxfill8(binfo->vram, binfo->scrnx, COL8_008484, 0, 16, 15, 31);
      putfonts8_asc(binfo->vram, binfo->scrnx, 0, 16, COL8_FFFFFF, s);
    }
  }
}
