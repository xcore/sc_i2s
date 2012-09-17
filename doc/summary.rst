I2S Digital Audio Component
===========================

Summary
......

I2S (also known as IIS, Inter-IC Sound or Integrated Interchip Sound) is a serial bus interface for digital audio transport.

The bus consists of atleast three lines: 

   - Bit clock - also known as serial clock or (SCLK)

   - Word clock - also known as word select line or Left/Right clock (LRCLK)

   - Atleast one multiplexed data line

Each I2S data line carries 2 audio channels (left and right). Additional data lines(in either direction) can be added for more audio channels.

Additionally a Master Clock line is used (typically 128, 256 or 512 x LRCLK

A typical usage for this is transport of PCM audio samples to/from an external DAC/ADC or CODEC.

The sc_i2s repo contains modules for both "master" (where the XMOS chip provides LRCLK and BCLK to the CODEC) and "slave" (where the CODEC provides LRCLK and BCLK to the XMOS chip) modes.

The sc_i2s modules can input and output multiple stereo audio streams on multiple ports. Audio samples are sent and received on a streaming channel.



