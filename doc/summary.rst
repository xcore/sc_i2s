I2S Digital Audio Component
===========================

I2S is a serial link for digital audio. Each I2S link carries 2 audio channels.

The I2S bus has 3 wires:

   - Bit clock or serial clock (BCK)

   - Word clock or word select (WCK)

   - Data

The sc_i2s module can input and output multiple stereo audio streams over I2S. Audio samples are sent and received over a streaming channel.

module_i2s_master
-----------------

This module is a single thread that acts as a master for an I2S bus.


drives the word clock and bit clock of an I2S link. It can transmit and receive audio data.

It requires the following resources:

   - 1 thread (MIPS dependant on number of inputs and outputs)

   - 2 clock blocks

   - 1 input port for each I2S input plus 1 for MCK

   - 1 output port for each I2S output plus 2 for BCK and WCK

   - 0.5 kB memory

module_i2s_slave
----------------

This module is a single thread that can transmit and receive I2S audio data using an external word clock and bit clock.

It requires the following resources:

   - 1 thread (MIPS dependant on number of inputs and outputs)

   - 1 clock block

   - 1 input port for each I2S input plus 2 for BCK and WCK

   - 1 output port for each I2S output

   - 0.5 kB memory

