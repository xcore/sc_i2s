I2S Digital Audio Component
===========================

I2S is a serial link for digital audio.

The sc_i2s module can input and output multiple stereo audio streams over I2S. Audio samples are sent and received over a streaming channel.

module_i2s_master
-----------------
This module is a single thread that drives the word clock and bit clock of an I2C link. It can transmit and receive audio data.

It requires the following resources:

   - 2 clock blocks

   - 1 input port for each I2S input plus 1 for MCK

   - 1 output port for each I2S output plus 2 for BCK and WCK

+---------------------------+------------------------------------+------------------------+
| Functionality provided    | Resources required                 | Status                 |
+----------+----------------+------------+--------+--------------+                        |
| Channels | Sample Rate    | 1-bit port | Memory | Thread rate  |                        |
+==========+================+============+========+==============+========================+
| 2        | up to 192 kHz  | ?          | 0.5 KB | 50 MIPS      | Implemented and tested |
+----------+----------------+------------+--------+--------------+------------------------+

module_i2s_slave
----------------
This module is a single thread that can transmit and receive I2S audio data using an external word clock and bit clock.

It requires the following resources:

   - 1 clock block

   - 1 input port for each I2S input plus 2 for BCK and WCK

   - 1 output port for each I2S output

+---------------------------+------------------------------------+------------------------+
| Functionality provided    | Resources required                 | Status                 |
+----------+----------------+------------+--------+--------------+                        |
| Channels | Sample Rate    | 1-bit port | Memory | Thread rate  |                        |
+==========+================+============+========+==============+========================+
| 2        | up to 192 kHz  | ?          | 0.5 KB | 50 MIPS      | Implemented and tested |
+----------+----------------+------------+--------+--------------+------------------------+
