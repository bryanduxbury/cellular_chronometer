#include "Charlie.h"

Charlie::Charlie(volatile uint8_t *directionReg, volatile uint8_t *valueReg, uint8_t startBit, uint8_t pinCount) {
  d = directionReg;
  v = valueReg;
  
  // compute the number of LEDs we should be driving
  numLEDs = pinCount * pinCount - pinCount;
  ledDefns = (LedDefn*)malloc(numLEDs * sizeof(LedDefn));
  
  // init all the duty percents for all our LEDs
  LedDefn *cur = ledDefns;
  for (int i = 0; i < pinCount; i++) {
    for (int j = i+1; j < pinCount; j++) {
      LedDefn defn1;
      defn1.dmask = _BV(startBit+i) | _BV(startBit+j);
      defn1.vmask = _BV(startBit+i);
      defn1.duty = 0;
      defn1.pending_duty = 0;
      *cur++ = defn1;

      LedDefn defn2;
      defn2.dmask = _BV(startBit+i) | _BV(startBit+j);
      defn2.vmask = _BV(startBit+j);
      defn2.duty = 0;
      defn2.pending_duty = 0;
      *cur++ = defn2;
    }
  } 
}

void Charlie::tick() {
  // increment the tick count
  tickCount++;

  // check if the current LED has reached the limit of it's duty cycle
  LedDefn currentDefn = ledDefns[curLED];
  if (curDuty == tickCount) {
    *d &= ~currentDefn.dmask;
    *v &= ~currentDefn.vmask;
  }
  
  // if tickCount reaches 16, it's time to reset tickCount and move on to the next LED
  if (tickCount==16) {
    tickCount = 0;

    // wrap around from end to beginning if necessary
    curLED++;
    if (curLED == numLEDs) {
      curLED = 0;
    }
    
    // turn on the next LED unless its duty is 0
    currentDefn = ledDefns[curLED];
    // copy the target duty into the current duty. this prevents a race condition that can cause 
    // an LED not to be turned off when the duty is set to a number lower than the tickCount 
    // while the LED is currently lit.
//    memcpy(&currentDefn.duty, &currentDefn.pending_duty, 1);
    curDuty = currentDefn.duty;
    if (curDuty != 0) {
      *d |= currentDefn.dmask;
      *v |= currentDefn.vmask;
    }
  }
  

}

//void Charlie::setDuty(int highPin, int lowPin, uint8_t duty) {
//  LedDefn *cur = ledDefns;
//  for(int i = 0; i < numLEDs; i++, cur++) {
//    if (cur->highPin->pin == highPin && cur->lowPin->pin == lowPin) {
//      cur->duty = duty;
//      return;
//    }
//  }
//  // error case, really should do something...
//}

void Charlie::setDuty(int ledNum, uint8_t duty) {
//  ledDefns[ledNum].pending_duty = duty;
  ledDefns[ledNum].duty = duty;
}

void Charlie::clear() {
  for (int i = 0; i < numLEDs; i++) {
    ledDefns[i].duty = 0;
  }
}
