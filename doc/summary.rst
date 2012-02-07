I2S Digital Audio Component
===========================

I2S is a serial link for digital audio. The I2S bus has 3 lines:

   - Bit clock or serial clock (BCK)

   - Word clock or word select (WCK)

   - Data

Each I2S data line carries 2 audio channels. Additional data lines can be added for more audio channels.

The sc_i2s module can input and output multiple stereo audio streams on multiple ports. Audio samples are sent and received on a streaming channel.

module_i2s_master
-----------------

This module is a single thread I2S bus master. It can transmit and receive audio data and drives the word clock and bit clock.

It requires the following resources:

   - 1 thread (MIPS dependant on number of inputs and outputs)

   - 2 clock blocks

   - 1 input port for each I2S input plus 1 for MCK

   - 1 output port for each I2S output plus 2 for BCK and WCK

   - 0.5 kB memory

module_i2s_slave
----------------

This module is a single thread I2S bus slave. It can transmit and receive audio data from an external word clock and bit clock.

It requires the following resources:

   - 1 thread (MIPS dependant on number of inputs and outputs)

   - 1 clock block

   - 1 input port for each I2S input plus 2 for BCK and WCK

   - 1 output port for each I2S output

   - 0.5 kB memory

