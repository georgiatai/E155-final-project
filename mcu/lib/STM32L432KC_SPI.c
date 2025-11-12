// STM32L432KC_SPI.c
// Julia Gong
// 10/12/2025
// this file initiates the functions for SPI communication

#include "STM32L432KC.h"

void initSPI(int br, int cpol, int cpha) {
  // full duplex communication is configured at default
  // turn on clock for SPI
  RCC->APB2ENR |= RCC_APB2ENR_SPI1EN;

  // set pins
  pinMode(SPI_CIPO, GPIO_ALT); 
  pinMode(SPI_COPI, GPIO_ALT);
  pinMode(SPI_CS, GPIO_OUTPUT);
  pinMode(SPI_CLK, GPIO_ALT);

  // setting up alternative GPIO modes
  GPIOB->AFR[0] |= _VAL2FLD(GPIO_AFRL_AFSEL3, 5);
  GPIOB->AFR[0] |= _VAL2FLD(GPIO_AFRL_AFSEL4, 5);
  GPIOB->AFR[0] |= _VAL2FLD(GPIO_AFRL_AFSEL5, 5);

  digitalWrite(SPI_CS, PIO_LOW); // cs is active high

  SPI1->CR1 = 0;

  // in CR1
  // set serial clock baud rate
  SPI1->CR1 |= _VAL2FLD(SPI_CR1_BR, br); 

  // configure CPOL and CPHA
  SPI1->CR1 |= _VAL2FLD(SPI_CR1_CPOL, cpol); // polarity
  SPI1->CR1 |= _VAL2FLD(SPI_CR1_CPHA, cpha); // phase

  // configure MSTR bit
  SPI1->CR1 |= _VAL2FLD(SPI_CR1_MSTR, 1);

  // in CR2
  // configure DS[3:0] to select data length for transfer
  SPI1->CR2 |= _VAL2FLD(SPI_CR2_DS, 0x7);

  // configure SSOE
  SPI1->CR2 |= _VAL2FLD(SPI_CR2_SSOE, 1); // SPi interface cannot work with multiple controllers

  // configure FRXTH bit
  SPI1->CR2 |= _VAL2FLD(SPI_CR2_FRXTH, 1); // RXNE event generated if FIFO level is >= 1/4 (8 bit)
  
  // configure SPI enable after setting up all SPI
  SPI1->CR1 |= _VAL2FLD(SPI_CR1_SPE, 1);
}

char spiSendReceive(char send) {
  // wait until the transmit buffer to be empty
  while (!(SPI1->SR & SPI_SR_TXE)); // TXE = 1, indicates transmit buffer empty

  // write data to be transmitted to SPI data register
  *(volatile char *)(&SPI1->DR) = send; // writes 8 bit into the address of DR register (dereferences a pointer)
  
  // wait until receiver buffer is full
  while(!(SPI1->SR & SPI_SR_RXNE)); // RXNE = 1, indicates receiver buffer not empty

  // returns value
  return (volatile char)SPI1->DR;

}