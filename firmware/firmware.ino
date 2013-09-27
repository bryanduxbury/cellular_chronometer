#include "Charlie.h"
#include "TimerOne.h"
#include "states.h"
#include "life.h"

Charlie plex(&DDRD, &PORTD, 0, 8, &DDRC, &PORTC, 0, 4);

// index of the minute we want to display
volatile uint16_t currentMinute = 0;
// number of microseconds elapsed since our last minute switch
volatile uint32_t elapsedMicros = 0;

// the current state of all the cells displayed
uint8_t currentDisplay[16] = {119, 119, 59, 13, 160, 181, 67, 180, 8, 49, 152, 207, 113, 215, 18, 2};
uint8_t tempDisplay[16] = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};

void setup() {
  Timer1.initialize(1);
  Timer1.attachInterrupt(tickISR, 1);

  pinMode(9, INPUT);
  digitalWrite(9, HIGH);

  // testLeds();
}

// void testLeds() {
//   for (int y = 0; y < NUM_ROWS; y++) {
//     for (int x = 0; x < NUM_COLS; x++) {
//       plex.setDuty(XY2ORD(x, y), 8);
//     }
//     delay(500);
//     for (int x = 0; x < NUM_COLS; x++) {
//       plex.setDuty(XY2ORD(x, y), 0);
//     }
//   }
// }

void loop() {
  // plex.clear();
  // memset(tempDisplay, 0, sizeof(currentDisplay));
  // set(tempDisplay, XY2ORD(10, 2));
  // uint8_t living_count = living_neighbors(tempDisplay, 10, 2);
  // for (int i = 0; i < living_count; i++) {
  //   set(tempDisplay, i);
  // }
  // 
  // if (test(tempDisplay, XY2ORD(10,2))) {
  //   set(tempDisplay, XY2ORD(0,1));
  // }
  // 
  // // if (test(tempDisplay, 0)) {
  // //   set(tempDisplay, 1);
  // // }
  // // set(tempDisplay, 8);
  // // set(tempDisplay, 16);
  // // set(tempDisplay, 32);
  // // set(tempDisplay, 64);
  // setDisplay(tempDisplay, 8);
  // 
  // delay(25000);

  plex.clear();
  setDisplay(currentDisplay, 8);
  
  while(true) {
    if (digitalRead(9) == LOW) {
      memset(tempDisplay, 0, sizeof(currentDisplay));
      next_generation(currentDisplay, tempDisplay);
      memcpy(currentDisplay, tempDisplay, sizeof(currentDisplay));
      delay(1000);
      break;
    }
    delay(10);
  }

  // for (int duty = 0; duty <= 8; duty ++) {
  //   for (int x = 0; x < NUM_COLS; x++) {
  //     for (int y = 0; y < NUM_ROWS; y++) {
  //       plex.setDuty(XY2ORD(x,y), duty);
  //     }
  //   }
  //   delay(125);
  // }
  // for (int duty = 7; duty >= 0; duty --) {
  //   for (int x = 0; x < NUM_COLS; x++) {
  //     for (int y = 0; y < NUM_ROWS; y++) {
  //       plex.setDuty(XY2ORD(x,y), duty);
  //     }
  //   }
  //   delay(125);
  // }
  
  // plex.tick();
  // pinMode(0, OUTPUT);
  // pinMode(1, OUTPUT);
  // digitalWrite(1, LOW);
  // digitalWrite(0, HIGH);
  // delay(1000);
  // digitalWrite(0, LOW);
  // delay(1000);
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

void setDisplay(uint8_t* state, uint8_t duty) {
  for (int y = 0; y < NUM_ROWS; y++) {
    for (int x = 0; x < NUM_COLS; x++) {
      if (test(state, x + y * NUM_COLS)) {
        plex.setDuty(XY2ORD(x, y), duty);
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
