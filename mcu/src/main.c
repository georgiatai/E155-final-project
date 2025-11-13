// main.c file for mcu communication

#include "STM32L432KC.h"


#define LED_PIN PA6  // On-board LED (for debug)
#define ADC_PIN PA0  // Analog input pin

int main(void) {
    // Enable GPIOA clock
    RCC->AHB2ENR |= RCC_AHB2ENR_GPIOAEN;
    RCC->AHB2ENR |= RCC_AHB2ENR_GPIOBEN;

    // Configure LED pin as output
    pinMode(LED_PIN, GPIO_OUTPUT);

    // Initialize Peripherals
    //initSPI(0b010, 0, 0);  // BR=0b010, CPOL=0, CPHA=0
    printf("hi");
    initADC();
    printf("ADC init done");

    while (1) {
        printf("Turning on pin");
        digitalWrite(LED_PIN, 1);
        uint16_t adcValue = readADC();
        printf("adc val: %d", adcValue);

        // Split 16-bit ADC value into two bytes
        uint8_t highByte = (adcValue >> 8) & 0xFF;
        uint8_t lowByte = adcValue & 0xFF;

        digitalWrite(LED_PIN, highByte);
        for (volatile int i = 0; i < 20000; i++);
        digitalWrite(LED_PIN, lowByte);
        for (volatile int i = 0; i < 20000; i++);


        //digitalWrite(SPI_CS, PIO_LOW); // Select FPGA (active low)
        //spiSendReceive(highByte);
        //spiSendReceive(lowByte);
        //digitalWrite(SPI_CS, PIO_HIGH); // Deselect FPGA

        //// Debug blink
        //digitalWrite(LED_PIN, PIO_HIGH);
        //for (volatile int i = 0; i < 20000; i++);
        //digitalWrite(LED_PIN, PIO_LOW);
        //for (volatile int i = 0; i < 20000; i++);
    }
}
