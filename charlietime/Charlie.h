#ifndef __CHARLIE_H__
#define __CHARLIE_H__

#include "Arduino.h"
//#include "ObjPin.h"


class Charlie {
 public:
  Charlie(volatile uint8_t *directionReg, volatile uint8_t *valueReg, uint8_t startBit, uint8_t numPins);
  void setDuty(int highPin, int lowPin, uint8_t duty);
  void setDuty(int ledNum, uint8_t duty);
  void clear();

  void tick();
  
 private:
  struct LedDefn {
//    int highPin;
//    int lowPin;
    uint8_t dmask;
    uint8_t vmask;
    volatile uint8_t duty;
    volatile uint8_t pending_duty;
  };

  volatile uint8_t *d;
  volatile uint8_t *v;

  volatile uint8_t curDuty;

  uint8_t tickCount;
  uint8_t curLED;

  LedDefn* ledDefns;
  uint8_t numLEDs;
};



#endif
