#include "bootpack.h"

#define FLAGS_OVERRUN 0x0001

void fifo8_init(struct FIFO8 *fifo, int size, unsigned char *buf) {
  fifo->buf = buf;
  fifo->p = 0;
  fifo->q = 0;
  fifo->size = size;
  fifo->free = size;
  fifo->flags = 0;
}

int fifo8_put(struct FIFO8 *fifo, unsigned char data) {
  if (fifo->free == 0) {
    fifo->flags |= FLAGS_OVERRUN;
    return -1;
  } else {
    fifo->buf[fifo->p] = data;

    fifo->p++;

    if (fifo->p == fifo->size) {
      fifo->p = 0;
    }

    fifo->free--;
    return 0;
  }
};

int fifo8_get(struct FIFO8 *fifo) {
  int data;
  if (fifo->size == fifo->free) {
    return -1;
  } else {
    data = fifo->buf[fifo->q];

    fifo->q++;

    if (fifo->q == fifo->size) {
      fifo->q = 0;
    }

    fifo->free++;

    return data;
  }
}

int fifo8_status(struct FIFO8 *fifo) {
  /** FIFOに溜まっているデータの個数を返す */
  return fifo->size - fifo->free;
}

void fifo32_init(struct FIFO32 *fifo, int size, int *buf) {
  fifo->buf = buf;
  fifo->p = 0;
  fifo->q = 0;
  fifo->size = size;
  fifo->free = size;
  fifo->flags = 0;
}

int fifo32_put(struct FIFO32 *fifo, int data) {
  if (fifo->free == 0) {
    fifo->flags |= FLAGS_OVERRUN;
    return -1;
  } else {
    fifo->buf[fifo->p] = data;

    fifo->p++;

    if (fifo->p == fifo->size) {
      fifo->p = 0;
    }

    fifo->free--;
    return 0;
  }
};

int fifo32_get(struct FIFO32 *fifo) {
  int data;
  if (fifo->size == fifo->free) {
    return -1;
  } else {
    data = fifo->buf[fifo->q];

    fifo->q++;

    if (fifo->q == fifo->size) {
      fifo->q = 0;
    }

    fifo->free++;

    return data;
  }
}

int fifo32_status(struct FIFO32 *fifo) {
  /** FIFOに溜まっているデータの個数を返す */
  return fifo->size - fifo->free;
}
