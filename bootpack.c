
void io_hlt(void);

void sprintf(char *str, char *fmt, ...);
void init_screen(char *vram, int xsize, int ysize);
void init_mouse_cursor8(char *mouse, char bc);
void putfonts8_asc(char *vram, int xsize, int x, int y, char c,
                   unsigned char *s);
void putblock8_8(char *vram, int vxsize, int pxsize, int pysize, int px0,
                 int py0, char *buf, int bxsize);

void init_gdtidt(void);

#define COL8_000000 0
#define COL8_FF0000 1
#define COL8_00FF00 2
#define COL8_FFFF00 3
#define COL8_0000FF 4
#define COL8_FF00FF 5
#define COL8_00FFFF 6
#define COL8_FFFFFF 7
#define COL8_C6C6C6 8
#define COL8_840000 9
#define COL8_008400 10
#define COL8_848400 11
#define COL8_000084 12
#define COL8_840084 13
#define COL8_008484 14
#define COL8_848484 15

struct BOOTINFO {
  char cyls, leds, vmode, reserve;
  short scrnx, scrny;
  char *vram;
};

void HariMain(void) {
  struct BOOTINFO *binfo;

  char *vram;
  int xsize, ysize;
  char s[40], mcursor[256];
  int mx, my;

  binfo = (struct BOOTINFO *)0x0ff0;

	init_gdtidt();
  init_screen(binfo->vram, binfo->scrnx, binfo->scrny);

  mx = (binfo->scrnx - 16) / 2; /* 画面中央になるように座標計算 */
  my = (binfo->scrny - 28 - 16) / 2;
  init_mouse_cursor8(mcursor, COL8_008484);
  putblock8_8(binfo->vram, binfo->scrnx, 16, 16, mx, my, mcursor, 16);
  sprintf(s, "(%d, %d)", mx, my);
  putfonts8_asc(binfo->vram, binfo->scrnx, 0, 0, COL8_FFFFFF, s);

  for (;;) {
    io_hlt();
  }
}
