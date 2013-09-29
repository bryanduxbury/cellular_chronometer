#include "Charlie.h"

Charlie::Charlie(volatile uint8_t *directionReg1, 
                volatile uint8_t *valueReg1,
                uint8_t startBit1, 
                uint8_t numPins1,
                volatile uint8_t *directionReg2, 
                volatile uint8_t *valueReg2,
                uint8_t startBit2, 
                uint8_t numPins2) 
{
  d1 = directionReg1;
  v1 = valueReg1;

  d2 = directionReg2;
  v2 = valueReg2;

  // compute the number of LEDs we should be driving
  int pinCount = numPins1 + numPins2;
  numLEDs = pinCount * pinCount - pinCount;
  ledDefns = (LedDefn*)malloc(numLEDs * sizeof(LedDefn));

  // init all the duty percents for all our LEDs
  LedDefn *cur = ledDefns;

  // starting from all the lsb pins...
  for (int i = 0; i < numPins1; i++) {
    // ... get each of the other lsb pins...
    for (int j = i+1; j < numPins1; j++) {
      LedDefn defn1;
      defn1.dmask1 = _BV(startBit1+i) | _BV(startBit1+j);
      defn1.vmask1 = _BV(startBit1+i);
      defn1.dmask2 = 0;
      defn1.vmask2 = 0;
      defn1.duty = 0;
      // defn1.pending_duty = 0;
      *cur++ = defn1;

      LedDefn defn2;
      defn2.dmask1 = _BV(startBit1+i) | _BV(startBit1+j);
      defn2.vmask1 = _BV(startBit1+j);
      defn2.dmask2 = 0;
      defn2.vmask2 = 0;
      defn2.duty = 0;
      // defn2.pending_duty = 0;
      *cur++ = defn2;
    }
    // ... and then get all of the msb pins
    for (int j = 0; j < numPins2; j++) {
      LedDefn defn1;
      defn1.dmask1 = _BV(startBit1+i);
      defn1.vmask1 = _BV(startBit1+i);
      defn1.dmask2 = _BV(startBit2+j);
      defn1.vmask2 = 0;
      defn1.duty = 0;
      // defn1.pending_duty = 0;
      *cur++ = defn1;

      LedDefn defn2;
      defn2.dmask1 = _BV(startBit1+i);
      defn2.vmask1 = 0;
      defn2.dmask2 = _BV(startBit2+j);
      defn2.vmask2 = _BV(startBit2+j);
      defn2.duty = 0;
      // defn2.pending_duty = 0;
      *cur++ = defn2;
    }
  }
  // and then for each msb pin...
  for (int i = 0; i < numPins2; i++) {
    // ... get each of the other msb pins
    for (int j = i+1; j < numPins2; j++) {
      LedDefn defn1;
      defn1.dmask1 = 0;
      defn1.vmask1 = 0;
      defn1.dmask2 = _BV(startBit2+i) | _BV(startBit2+j);
      defn1.vmask2 = _BV(startBit2+i);
      defn1.duty = 0;
      // defn1.pending_duty = 0;
      *cur++ = defn1;

      LedDefn defn2;
      defn2.dmask1 = 0;
      defn2.vmask1 = 0;
      defn2.dmask2 = _BV(startBit2+i) | _BV(startBit2+j);
      defn2.vmask2 = _BV(startBit2+j);
      defn2.duty = 0;
      // defn2.pending_duty = 0;
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
    *d1 &= ~currentDefn.dmask1;
    *v1 &= ~currentDefn.vmask1;
    *d2 &= ~currentDefn.dmask2;
    *v2 &= ~currentDefn.vmask2;
  }
  
  // if tickCount reaches 16, it's time to reset tickCount and move on to the next LED
  if (tickCount==4) {
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
    curDuty = currentDefn.duty;
    if (curDuty != 0) {
      *d1 |= currentDefn.dmask1;
      *v1 |= currentDefn.vmask1;
      *d2 |= currentDefn.dmask2;
      *v2 |= currentDefn.vmask2;
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
