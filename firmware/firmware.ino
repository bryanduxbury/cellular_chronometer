#include "Charlie.h"
#include "TimerOne.h"
#include "life.h"
#include <avr/pgmspace.h>
#include "initial_states.h"


#define TICK_USEC 10
#define USEC_IN_A_MINUTE 60000000

#define XY2LED(x, y) ((x) + (y) * (25))

Charlie plex(&DDRD, &PORTD, 0, 8, &DDRC, &PORTC, 0, 4);

// index of the minute we want to display
volatile uint16_t currentMinute = 0;
// number of microseconds elapsed since our last minute switch
volatile uint32_t elapsedMicros = 0;

// the current state of all the cells displayed
uint8_t display1[27] = {0};
uint8_t display2[27] = {0};

uint8_t *front;
uint8_t *back;

void setup() {
  Timer1.initialize(TICK_USEC);
  Timer1.attachInterrupt(tickISR, TICK_USEC);

  pinMode(9, INPUT);
  digitalWrite(9, HIGH);

  pinMode(10, INPUT);
  digitalWrite(10, HIGH);

  front = display1;
  back = display2;

  loadInitialState(front, 0);
  fadeIn(front, 1000);
}

void loadInitialState(uint8_t* buffer, uint16_t idx) {
  memcpy_PF(buffer + 1, (uint8_t*) initialStates + idx * NUM_ROWS, NUM_ROWS);
  center(buffer);
}

void center(uint8_t* rows) {
  for (int i = 0; i < NUM_ROWS + 2; i++) {
    rows[i] = rows[i] << 1;
  }
}

// lights up each row of the display briefly
void testLeds() {
  for (int y = 0; y < NUM_COLS; y++) {
    for (int x = 0; x < NUM_ROWS; x++) {
      plex.setDuty(XY2LED(x, y), 4);
    }
    delay(100);
    for (int x = 0; x < NUM_ROWS; x++) {
      plex.setDuty(XY2LED(x, y), 0);
    }
  }
}

// memcpy from PROGMEM to RAM
void memcpy_PF(uint8_t *dest, uint8_t *pgmSrc, uint8_t count) {
  for (int i = 0; i < count; i++) {
    dest[i] = pgm_read_byte(pgmSrc++);
  }
}

void loop() {
  // testWithButtonsLoop();
  advanceTheClockLoop();
}

void testWithButtonsLoop() {
  while(true) {
    if (digitalRead(9) == LOW) {
      next_generation8(front, back);
      crossFade(front, back, 1000);

      uint8_t *temp = back;
      back = front;
      front = temp;
      delay(10);
      break;
    } else if (digitalRead(10) == LOW) {
      currentMinute++;
      if (currentMinute == NUM_STATES) {
        currentMinute = 0;
      }

      fadeOut(front, 1000);
      loadInitialState(front, currentMinute);
      fadeIn(front, 1000);

      while (digitalRead(10) == LOW) {
        delay(10);
      }

      break;
    }
    delay(100);
  }
}

void advanceTheClockLoop() {
  // which minute is *this loop* displaying right now? we'll use this to detect
  // when the minute rolls over so we can fade out and load the next minute
  uint16_t currentMinuteDisplayed = 0;

  // note that all the delaying in this loop comes from the crossFade and 
  // fadeIn/fadeOut calls.
  while (true) {
    if (currentMinuteDisplayed == currentMinute) {
      next_generation8(front, back);
      crossFade(front, back, 1000);
      delay(2000);
      uint8_t *temp = back;
      back = front;
      front = temp;
    } else {
      fadeOut(front, 1000);
      currentMinuteDisplayed = currentMinute;
      loadInitialState(front, currentMinute);
      fadeIn(front, 1000);
    }
  }
}

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
      }
    }
  }
}

void tickISR() {
  // keep track of our time base
  elapsedMicros += TICK_USEC;
  // roll over at 1 minute
  if (elapsedMicros == USEC_IN_A_MINUTE) {
    currentMinute++;
    elapsedMicros = 0;
    // roll over after we run out of states
    if (currentMinute == NUM_STATES) {
      currentMinute = 0;
    }
  }

  plex.tick();
}
