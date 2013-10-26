#include "Charlie.h"
#include "TimerOne.h"
#include "life.h"
#include <avr/pgmspace.h>
#include "initial_states.h"

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
  Timer1.initialize(10);
  Timer1.attachInterrupt(tickISR, 10);

  pinMode(9, INPUT);
  digitalWrite(9, HIGH);

  pinMode(10, INPUT);
  digitalWrite(10, HIGH);

  // testLeds();
  front = display1;
  back = display2;

  loadInitialState(front, 0);
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
  plex.clear();
  setDisplay(front, 4);

  while(true) {
    if (digitalRead(9) == LOW) {
      next_generation8(front, back);
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

      while (digitalRead(10) == LOW) {
        delay(10);
      }
      loadInitialState(front, currentMinute);
      break;
    }
    delay(100);
  }

  // uint16_t thisMinute = 0;
  // 
  // uint32_t startMillis = 0;
  // boolean passedTarget = false;
  // 
  // while (true) {
  //   if (thisMinute == currentMinute) {
  //     // standard sequence, move forward
  //     if ((millis() - startMillis) % 1000 == 0) {
  //       uint64_t newLow, newHigh;
  //       next_generation(displayLow, displayHigh, &newLow, &newHigh);
  //       displayLow = newLow;
  //       displayHigh = newHigh;
  //       if (displayLow == targetLow[thisMinute] && displayHigh == targetHigh[thisMinute]) {
  //         passedTarget = true;
  //       }
  //     }
  // 
  //     // copy display low and high to the actual charlieplex
  //     plex.clear();
  //     setDisplay(displayLow, displayHigh, 8);
  //     if (passedTarget) {
  //       setDisplay(targetLow[thisMinute], targetHigh[thisMinute], 16);
  //     }
  //   } else {
  //     // blank and startover sequence
  //     thisMinute = currentMinute;
  //     passedTarget = false;
  // 
  //     startMillis = millis();
  // 
  //     plex.clear();
  //     delay(250);
  // 
  //     displayLow = initialLow[thisMinute];
  //     displayHigh = initialHigh[thisMinute];
  //     setDisplay(displayLow, displayHigh, 8);
  //   }
  // }
}

// the display's xy is transposed with respect to the actual grid
void setDisplay(uint8_t* state, uint8_t duty) {
  // don't care about the first and last rows, since they're just toroidal 
  // aliases
  for (int y = 1; y <= NUM_ROWS; y++) {
    // don't care about the first and last columns, since thye're just toroidal
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
  // elapsedMicros++;
  // // roll over at 1 minute
  // if (elapsedMicros == 60000000) {
  //   currentMinute++;
  //   elapsedMicros = 0;
  //   // roll over after 720 minutes
  //   if (currentMinute == 720) {
  //     currentMinute = 0;
  //   }
  // }
  
  // DDRD |= _BV(3);
  // PORTD |= _BV(0);
  // 
  // DDRD &= ~_BV(3);
  // PORTD &= ~_BV(1);
  
  //  PORTB |= 0x20;
  plex.tick();
  //  PORTB &= ~0x20;
}
