// Julia Gong
// 9/27/25
// initializing timer for MCU
// STM32L432KC_TIM6.c

#include "STM32L432KC_TIM6.h"
#include "STM32L432KC_RCC.h"

void init_delay() {
// enable clock for timer
    RCC->APB1ENR1 |= (1 << 4);
// set up prescalar value, setting clock to 1kz
    TIM6->PSC = 39999;
// set update generation to reinitialize counter
    TIM6->EGR |= (1 << 0);
// turn on auto-preload enable (TIMx_ARR register is buffered)
    TIM6->CR1 |= (1 << 7);
// turn on counter enable
    TIM6->CR1 |= (1 << 0);

}


void delay(int ms) {
if (ms == 0) return;
    TIM6->ARR = ms * 2  - 1 ;
// set update generation to reinitialize counter
    TIM6->EGR |= (1 << 0);
// set UIF to 0
    TIM6->SR &= ~(1 << 0);
// turn on counter enable
    TIM6->CR1 |= (1 << 0);
// reset counter
    TIM6->CNT = 0;
// wait for max counter value (UIF = 1)
    while ((TIM6->SR & 1) == 0);

    TIM6->CR1 &= ~(1 << 0);
}
