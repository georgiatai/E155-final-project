#include "STM32L432KC_ADC.h"

void initADC(void) {
    // Enable GPIOA clock (for analog input)
    RCC->AHB2ENR |= RCC_AHB2ENR_GPIOAEN;

    // TODO: choose pin and modify
    // Set PA0 to analog mode
    GPIOA->MODER |= GPIO_MODER_MODE0; // 11: analog mode
    GPIOA->PUPDR &= ~GPIO_PUPDR_PUPD0; // no pull-up/down

    // Enable ADC clock
    RCC->AHB2ENR |= RCC_AHB2ENR_ADCEN;

    // Ensure ADC is disabled before configuration
    if (ADC1->CR & ADC_CR_ADEN) {
        ADC1->CR |= ADC_CR_ADDIS;
        while (ADC1->CR & ADC_CR_ADEN);
    }

    // Configure ADC
    ADC1->CFGR = 0; // single conversion, right alignment

    // Select channel 5 (PA0)
    ADC1->SQR1 = (5 << ADC_SQR1_SQ1_Pos);

    // Enable ADC voltage regulator
    ADC1->CR |= ADC_CR_ADVREGEN_0;

    // Calibrate ADC
    ADC1->CR |= ADC_CR_ADCAL;
    while (ADC1->CR & ADC_CR_ADCAL);

    // Enable ADC
    ADC1->ISR |= ADC_ISR_ADRDY;
    ADC1->CR |= ADC_CR_ADEN;
    while (!(ADC1->ISR & ADC_ISR_ADRDY));
}

uint16_t readADC(void) {
    ADC1->CR |= ADC_CR_ADSTART; // start conversion
    while (!(ADC1->ISR & ADC_ISR_EOC)); // wait until done
    return (uint16_t)ADC1->DR; // return 12-bit result
}
