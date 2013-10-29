#ifndef __CHARLIE_H__
#define __CHARLIE_H__

#include "Arduino.h"

#define DUTY_MAX 8

class Charlie {
 public:
  Charlie(volatile uint8_t *directionReg1, volatile uint8_t *valueReg1,
          uint8_t startBit1, uint8_t numPins1,
          volatile uint8_t *directionReg2, volatile uint8_t *valueReg2,
          uint8_t startBit2, uint8_t numPins2);

  void setDuty(int highPin, int lowPin, uint8_t duty);
  void setDuty(int ledNum, uint8_t duty);
  void clear();

  void tick();

 private:
  struct LedDefn {
    uint8_t dmask1;
    uint8_t vmask1;
    uint8_t dmask2;
    uint8_t vmask2;
    volatile uint8_t duty;
    // volatile uint8_t pending_duty;
  };

  volatile uint8_t *d1;
  volatile uint8_t *v1;
  volatile uint8_t *d2;
  volatile uint8_t *v2;

  volatile uint8_t curDuty;

  uint8_t tickCount;
  uint8_t curLED;

  LedDefn* ledDefns;
  uint8_t numLEDs;
};

#endif
