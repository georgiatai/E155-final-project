// Julia Gong
// 9/27/25
// TIMER header file to access TIM6
// STM32L432KC_TIM6.h

#include <stdint.h>
#include <math.h>

#ifndef STM32L4_TIM6_H
#define STM32L4_TIM6_H

#define __IO volatile

#define TIM6_BASE (0x40001000UL)

typedef struct{
  __IO uint32_t CR1; // 0x00
  __IO uint32_t CR2; // 0x04
  uint32_t RES1;      // 0x08
  __IO uint32_t DIER; // 0x0C
  __IO uint32_t SR; // 0x10
  __IO uint32_t EGR; // 0x14
  uint32_t RES2;    // 0x18
  uint32_t RES3;    // 0x1C
  uint32_t RES4;    // 0x20
  __IO uint32_t CNT; // 0x24
  __IO uint32_t PSC; //0x28
  __IO uint32_t ARR; // 0x2C
} TIM6_ad;

#define TIM6 ((TIM6_ad *)TIM6_BASE)

// delays
void init_delay(void);
void delay(int ms);

#endif