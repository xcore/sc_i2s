I2S Digital Audio Master Component
==================================

I2S Overview
------------

I2S (also known as IIS, Inter-IC Sound or Integrated Interchip Sound) is a serial bus interface for digital audio transport.

The bus consists of atleast three lines: 

   * Bit clock - also known as serial clock or (SCLK)
   * Word clock - also known as word select line or Left/Right clock (LRCLK)
   * At least one multiplexed data line

Each I2S data line carries 2 audio channels (left and right). Additional data lines(in either direction) can be added for more audio channels.

Additionally a Master Clock line is used (typically 128, 256 or 512 x LRCLK.

A typical usage for this is transport of PCM audio samples to/from an external DAC/ADC or CODEC.

Module Features
---------------

   * Implements a "master" (where the XMOS chip provides LRCLK and BCLK to the CODEC). A "slave" version  (where the CODEC provides LRCLK and BCLK to the XMOS chip) modes will be added soon.
   * Input and output multiple stereo audio streams on multiple ports at sample frequencies up to 192 KHz
   * Audio samples are sent to and received from the client via a streaming channel


Resource Requirements
----------------------

This module is a single logical core I2S bus master. It can transmit and receive audio data and drives the word clock and bit clock.

It requires the following resources:

   - 1 logical core (MIPS dependant on number of inputs and outputs)
   - 2 clock blocks
   - 1 x 1-bit input port for each I2S input plus 1 for MCLK
   - 1 x 1-bit output port for each I2S output plus 2 for BCLK and WCLK
   - approx 0.5 kB memory 

Performance
+++++++++++

The performance the module can achieve depends on the number on the number of channels served, the sample frequency desired and the master clock frequency (or divide) used. 

Currently the component is expected to achieve 10 channels input and output at 192kHz (based on a 512*48000Hz master clock)
