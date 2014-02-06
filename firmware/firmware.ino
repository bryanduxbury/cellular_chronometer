#include "Charlie.h"
#include "TimerOne.h"
#include "life.h"
#include <avr/pgmspace.h>
#include "initial_states.h"
#include "glyphs.h"

// control pins
#define UP_SW 9
#define DOWN_SW 10

// for the time base
#define TICK_USEC 10

#define XY2LED(x, y) ((x) + (y) * (25))

Charlie plex(&DDRD, &PORTD, 0, 8, &DDRC, &PORTC, 0, 4, 125);

// index of the minute we want to display
volatile uint16_t currentMinute = 0;

// the current state of all the cells displayed
uint8_t display1[27] = {0};
uint8_t display2[27] = {0};

uint8_t *front;
uint8_t *back;

void setup() {
  Timer1.initialize(TICK_USEC);
  Timer1.attachInterrupt(tickISR, TICK_USEC);

  pinMode(UP_SW, INPUT);
  digitalWrite(UP_SW, HIGH);

  pinMode(DOWN_SW, INPUT);
  digitalWrite(DOWN_SW, HIGH);

  front = display1;
  back = display2;

  loadInitialState(front, 0);
  fadeIn(front, 1000);
}

void loadInitialState(uint8_t* buffer, uint16_t idx) {
  memcpy_PF(buffer + 1, initialStates + idx * NUM_ROWS, NUM_ROWS);
  center(buffer);
}

// convenience function for shifting all the elements in the row vector up a bit,
// used to prepare to make the rows toroidal
void center(uint8_t* rows) {
  for (int i = 0; i < NUM_ROWS + 2; i++) {
    rows[i] = rows[i] << 1;
  }
}

// memcpy from PROGMEM to RAM
void memcpy_PF(uint8_t *dest, uint8_t *pgmSrc, uint8_t count) {
  for (int i = 0; i < count; i++) {
    dest[i] = pgm_read_byte(pgmSrc++);
  }
}

void loop() {
  advanceTheClockLoop();
}

void advanceTheClockLoop() {
  // which minute is *this loop* displaying right now? we'll use this to detect
  // when the minute rolls over so we can fade out and load the next minute
  uint16_t currentMinuteDisplayed = 0;

  uint32_t lastMillis = millis();

  // note that all the delaying in this loop comes from the crossFade and 
  // fadeIn/fadeOut calls.
  while (true) {
    // check if 60000 ms have elapsed, and it's time to advance the minute
    uint32_t now = millis();
    if (now - lastMillis >= 60000) {
      currentMinute++;
      if (currentMinute == NUM_STATES) {
        currentMinute = 0;
      }
      // note, we move forward my 60000 ms, not by setting last to now, since 
      // we want a fixed 60000 ms change, not 60000 ms from right now.
      lastMillis += 60000;
    }

    // first, see if someone is trying to adjust our time.
    if (digitalRead(UP_SW) == LOW) {
      seekUp();
    } else if (digitalRead(DOWN_SW) == LOW) {
      seekDown();
    }

    if (currentMinuteDisplayed == currentMinute) {
      // get the successor to this generation
      next_generation8(front, back);
      // cross fade from this generation to the next one
      crossFade(front, back, 1000);
      // hold the display steady for a bit
      delay(2000);

      // swap the front and back buffers for the next go around
      uint8_t *temp = back;
      back = front;
      front = temp;
    } else {
      // fade the current grid to black
      fadeOut(front, 1000);
      // load the next minute
      currentMinuteDisplayed = currentMinute;
      loadInitialState(front, currentMinute);
      // fade in the new current
      fadeIn(front, 1000);
    }
  }
}

// user pressed the "time up" switch. go forward in time until the user is
// satisfied.
void seekUp() {
  uint16_t minute = currentMinute;

  // the first 10 minutes forward go at slightly faster than 1 min/sec.
  // after the first 10, we switch into fast mode and go 20 min/sec.
  // note that the counter (i) is not used for loop termination.
  for (int i = 0; digitalRead(UP_SW) == LOW; i++) {
    minute++;
    if (minute == NUM_STATES) {
      minute = 0;
    }
    fastDisplayMinute(front, minute);
    // variable delay
    delay(i < 10 ? 750 : 50);
  }

  // user has released the button. get back into normal operation mode.
  currentMinute = minute;
}

// user pressed the "time down" switch. go backward in time until the user is
// satisfied.
void seekDown() {
  uint16_t minute = currentMinute;

  // the first 10 minutes forward go at slightly faster than 1 min/sec.
  // after the first 10, we switch into fast mode and go 20 min/sec.
  // note that the counter (i) is not used for loop termination.
  for (int i = 0; digitalRead(DOWN_SW) == LOW; i++) {
    if (minute == 0) {
      minute = NUM_STATES;
    }
    minute--;
    fastDisplayMinute(front, minute);
    // variable delay
    delay(i < 10 ? 750 : 50);
  }

  // user has released the button. get back into normal operation mode.
  currentMinute = minute;
}

// display effects

void fadeOut(uint8_t* current, int duration) {
  for (uint8_t level = 0; level <= DUTY_MAX; level++) {
    for (int y = 1; y <= NUM_ROWS; y++) {
      for (int x = 1; x <= NUM_COLS; x++) {
        if (test8(current, y, x)) {
          plex.setDuty(XY2LED(y-1, x-1), DUTY_MAX - level);
        }
      }
    }
    delay(duration / DUTY_MAX);
  }
}

void fadeIn(uint8_t* current, int duration) {
  for (uint8_t level = 0; level <= DUTY_MAX; level++) {
    for (int y = 1; y <= NUM_ROWS; y++) {
      for (int x = 1; x <= NUM_COLS; x++) {
        if (test8(current, y, x)) {
          plex.setDuty(XY2LED(y-1, x-1), level);
        }
      }
    }
    delay(duration / DUTY_MAX);
  }
}

void crossFade(uint8_t* current, uint8_t* next, int duration) {
  for (uint8_t level = 0; level <= DUTY_MAX; level++) {
    for (int y = 1; y <= NUM_ROWS; y++) {
      for (int x = 1; x <= NUM_COLS; x++) {
        bool cur = test8(current, y, x);
        bool nxt = test8(next, y, x);
        if (cur != nxt) {
          if (cur) {
            // this cell died. fade it out.
            plex.setDuty(XY2LED(y-1, x-1), DUTY_MAX - level);
          } else {
            // this cell was born. fade it in.
            plex.setDuty(XY2LED(y-1, x-1), level);
          }
        }
      }
    }
    // fade in/out spans 2 seconds. each level step should take 2s / N steps time.
    delay(duration / DUTY_MAX);
  }
}

// the display's xy is transposed with respect to the actual grid
void setDisplay(uint8_t* state, uint8_t duty) {
  // don't care about the first and last rows, since they're just toroidal 
  // aliases
  for (int y = 1; y <= NUM_ROWS; y++) {
    // don't care about the first and last columns, since they're just toroidal
    // aliases
    for (int x = 1; x <= NUM_COLS; x++) {
      if (test8(state, y, x)) {
        // note that we actually transpose x and y here
        // and also translate the coordinates down one to account for the 
        // aliases
        plex.setDuty(XY2LED(y-1, x-1), duty);
      } else {
        plex.setDuty(XY2LED(y-1, x-1), 0);
      }
    }
  }
}

void fastDisplayMinute(uint8_t* buffer, uint16_t idx) {
  memset(buffer, 0, 27);
  int hour = (idx / 60) + 1;
  int minute = idx % 60;

  memcpy_PF(buffer + 3, digitGlyphs + 3 * (hour / 10), 3);
  memcpy_PF(buffer + 8, digitGlyphs + 3 * (hour % 10), 3);

  buffer[13] = 10;

  memcpy_PF(buffer + 16, digitGlyphs + 3 * (minute / 10), 3);
  memcpy_PF(buffer + 21, digitGlyphs + 3 * (minute % 10), 3);

  center(buffer);
  setDisplay(buffer, DUTY_MAX);
}

void tickISR() {
  plex.tick();
}
