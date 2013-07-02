#define STARTPIN 4
#define ENDPIN 9

#include "Charlie.h"
#include "TimerOne.h"
#include "ObjPin.h"

void setup() {
  for (int i = STARTPIN; i <= ENDPIN; i++) {
    pinMode(i, INPUT);
  }
  
  Timer1.initialize(1);
  Timer1.attachInterrupt(tickISR, 1);
  
  pin13.setMode(OUTPUT);
}


uint8_t sinTable[64] = {8, 8, 9, 10, 10, 11, 12, 13, 13, 14, 14, 14, 15, 15, 15, 15, 16, 15, 15, 15, 15, 15, 14, 14, 13, 13, 12, 11, 11, 10, 9, 8, 8, 7, 6, 5, 5, 4, 3, 2, 2, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 2, 2, 3, 4, 4, 5, 6, 7};

//int level = 0;

void loop() { 
  for (int level = 0; level < 64; level++) {
    for (int i = 0; i < 30; i++) {
      plex.setDuty(i, sinTable[(level+i) % 64]); 
    }
    delay(100);
  }
  
//  for (int i = 0; i < 15; i++) {
//    plex.setDuty(2*i, level);
//    plex.setDuty(2*i+1, level);
//    delay(10);
//    plex.setDuty(2*i, 0);
//    plex.setDuty(2*i+1, 0);
//  }
//  
//  for (int i = 15; i >= 0; i--) {
//    plex.setDuty(2*i, level);
//    plex.setDuty(2*i+1, level);
//    delay(10);
//    plex.setDuty(2*i, 0);
//    plex.setDuty(2*i+1, 0);
//  }
//  
//  level += 2;
//  if (level > 16) {
//    level = 1;
//  }
}

void tickISR() {
  PORTB |= 0x20;
  plex.tick();
  PORTB &= ~0x20;
}
