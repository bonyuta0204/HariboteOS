#include "bootpack.h"

#define PIT_CTRL 0x0043
#define PIT_CNT0 0x0040

#define TIMER_FLAG_ALLOC 1
#define TIMER_FLAG_USING 2

struct TIMERCTL timerctl;
struct FIFO32 timerfifo;

void init_pit(void) {
  io_out8(PIT_CTRL, 0x34);
  io_out8(PIT_CNT0, 0x9c);
  io_out8(PIT_CNT0, 0x2e);
  timerctl.count = 0;
  timerctl.next = 0xffffffff;

  for (int i = 0; i < MAX_TIMER; i++) {
    timerctl.timer[i].flags = 0; /** 未使用 */
  };
  return;
}

struct TIMER *timer_alloc(void) {
  for (int i = 0; i < MAX_TIMER; i++) {
    if (timerctl.timer[i].flags == 0) {
      timerctl.timer[i].flags = TIMER_FLAG_ALLOC;
      return &timerctl.timer[i];
    }
  }
  return 0;
}

void timer_free(struct TIMER *timer) {
  timer->flags = 0;
  return;
}

void timer_init(struct TIMER *timer, struct FIFO32 *fifo, unsigned char data) {
  timer->fifo = fifo;
  timer->data = data;
  return;
}

void timer_settime(struct TIMER *timer, unsigned int timeout) {
  timer->timeout = timeout + timerctl.count;
  timer->flags = TIMER_FLAG_USING;

  if (timerctl.next > timer->timeout) {
    /** 次回の更新 */
    timerctl.next = timer->timeout;
  }
  return;
}

void inthandler20(int *esp) {
  /** タイマー割り込み */
  io_out8(PIC0_OCW2, 0x60); /* IRQ-00受付完了をPICに通知 */
  timerctl.count++;

  if (timerctl.next > timerctl.count) {
    return;
  }

  timerctl.next = 0xffffffff;

  for (int i = 0; i < MAX_TIMER; i++) {
    struct TIMER *timer = &timerctl.timer[i];
    if (timer->flags == TIMER_FLAG_USING) {

      /** タイマーが終了 */
      if (timer->timeout <= timerctl.count) {
        timer->flags = TIMER_FLAG_ALLOC;
        fifo32_put(timer->fifo, timer->data);
      } else {
        if (timerctl.next > timer->timeout) {
          timerctl.next = timer->timeout;
        }
      }
    }
  }

  return;
}
