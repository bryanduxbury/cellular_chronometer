#include "Charlie.h"
#include "TimerOne.h"
// #include "states.cpp"
#include "life.h"
#include <avr/pgmspace.h>

uint32_t initialStates[] PROGMEM = {
  41348846, 62234636, 8673824, 7595532, 4348654,
  42397422, 54894604, 53762592, 24372748, 43145966
};


Charlie plex(&DDRD, &PORTD, 0, 8, &DDRC, &PORTC, 0, 4);

// index of the minute we want to display
volatile uint16_t currentMinute = 0;
// number of microseconds elapsed since our last minute switch
volatile uint32_t elapsedMicros = 0;

// the current state of all the cells displayed
uint32_t display1[7] = {0};
uint32_t display2[7] = {0};

uint32_t *front;
uint32_t *back;


void setup() {
  Timer1.initialize(1);
  Timer1.attachInterrupt(tickISR, 1);

  pinMode(9, INPUT);
  digitalWrite(9, HIGH);

  pinMode(10, INPUT);
  digitalWrite(10, HIGH);

  // testLeds();
  front = display1;
  back = display2;
  memcpy_PF32(front+1, initialStates, 5);
}

void testLeds() {
  for (int y = 0; y < NUM_ROWS; y++) {
    for (int x = 0; x < NUM_COLS; x++) {
      plex.setDuty(XY2ORD(x, y), 8);
    }
    delay(500);
    for (int x = 0; x < NUM_COLS; x++) {
      plex.setDuty(XY2ORD(x, y), 0);
    }
  }
}

void memcpy_PF(uint8_t *dest, uint8_t *pgmSrc, uint8_t count) {
  for (int i = 0; i < count; i++) {
    dest[i] = pgm_read_byte(pgmSrc++);
  }
}

void memcpy_PF32(uint32_t *dest, uint32_t *pgmSrc, uint8_t count) {
  for (int i = 0; i < count; i++) {
    dest[i] = (uint32_t) pgm_read_dword(pgmSrc++);
  }
}

void loop() {
  plex.clear();
  setDisplay(front, 4);
  
  while(true) {
    if (digitalRead(9) == LOW) {
      memset(back, 0, sizeof(display1));
      next_generation32(front, back);
      uint32_t *temp = back;
      back = front;
      front = temp;
      delay(100);
      break;
    } else if (digitalRead(10) == LOW) {
      currentMinute++;
      if (currentMinute == 2) {
        currentMinute = 0;
      }
      memcpy_PF32(front+1, initialStates + currentMinute * 5, 5);
      delay(100);
      break;
    }
    delay(10);
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

void setDisplay(uint32_t* state, uint8_t duty) {
  for (int y = 1; y <= NUM_ROWS; y++) {
    for (int x = 1; x <= NUM_COLS; x++) {
      if (test32(state, y, x)) {
        plex.setDuty(XY2ORD(x-1, y-1), duty);
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
