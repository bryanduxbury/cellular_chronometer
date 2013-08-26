#include "Charlie.h"
#include "TimerOne.h"
#include "states.h"
#include "life.h"

Charlie plex(&PORTC, &DDRC, 0, 8, &PORTD, &DDRD, 0, 4);

// index of the minute we want to display
volatile uint16_t currentMinute = 0;
// number of microseconds elapsed since our last minute switch
volatile uint32_t elapsedMicros = 0;

// the current state of all the cells displayed
uint64_t displayLow;
uint64_t displayHigh;

void setup() {
  Timer1.initialize(1);
  Timer1.attachInterrupt(tickISR, 1);

  testLeds();
}

void testLeds() {
  for (int y = 0; y < NUM_ROWS; y++) {
    for (int x = 0; x < NUM_COLS; x++) {
      plex.setDuty(XY2ORD(x, y), 16);
    }
    delay(200);
    for (int x = 0; x < NUM_COLS; x++) {
      plex.setDuty(XY2ORD(x, y), 0);
    }
  }
}

void loop() { 
  uint16_t thisMinute = 0;

  uint32_t startMillis = 0;
  boolean passedTarget = false;

  while (true) {
    if (thisMinute == currentMinute) {
      // standard sequence, move forward
      if ((millis() - startMillis) % 1000 == 0) {
        uint64_t newLow, newHigh;
        next_generation(displayLow, displayHigh, &newLow, &newHigh);
        displayLow = newLow;
        displayHigh = newHigh;
        if (displayLow == targetLow[thisMinute] && displayHigh == targetHigh[thisMinute]) {
          passedTarget = true;
        }
      }

      // copy display low and high to the actual charlieplex
      plex.clear();
      setDisplay(displayLow, displayHigh, 8);
      if (passedTarget) {
        setDisplay(targetLow[thisMinute], targetHigh[thisMinute], 16);
      }
    } else {
      // blank and startover sequence
      thisMinute = currentMinute;
      passedTarget = false;

      startMillis = millis();

      plex.clear();
      delay(250);

      displayLow = initialLow[thisMinute];
      displayHigh = initialHigh[thisMinute];
      setDisplay(displayLow, displayHigh, 8);
    }
  }
}

void setDisplay(uint64_t lowbits, uint64_t highbits, uint8_t duty) {
  int counter = 0;
  uint64_t cur = lowbits;
  for (int y = 0; y < NUM_ROWS; y++) {
    for (int x = 0; x < NUM_COLS; x++) {
      if (cur & (1 << counter)) {
        plex.setDuty(XY2ORD(x, y), duty);
      }
      counter++;
      if (counter == 64) {
        counter = 0;
        cur = highbits;
      }
    }
  }
}

void tickISR() {
  // keep track of our time base
  elapsedMicros++;
  // roll over at 1 minute
  if (elapsedMicros == 60000000) {
    currentMinute++;
    elapsedMicros = 0;
    // roll over after 720 minutes
    if (currentMinute == 720) {
      currentMinute = 0;
    }
  }
  
  //  PORTB |= 0x20;
  plex.tick();
  //  PORTB &= ~0x20;
}
