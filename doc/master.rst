I2S Master
..........

This module is an I2S master transmitter and receiver in a single thread. It sends and receives samples over a channel transmits/receives audio over I2S. It can send and receive multiple I2S links on separate ports.

As a master it drives the bit clock (BCLK) and LR clock (LRCLK) on output ports. It is clocked by an external master clock (MCLK) on an input port.

Note, the module assumes one LR Clock for input and output data.

module_i2s_master
-----------------

This module is a single thread I2S bus master. It can transmit and receive audio data and drives the word clock and bit clock.

It requires the following resources:

   - 1 thread (MIPS dependant on number of inputs and outputs)

   - 2 clock blocks

   - 1 x 1-bit input port for each I2S input plus 1 for MCLK

   - 1 x 1-bit output port for each I2S output plus 2 for BCLK and WCLK

   - 0.5 kB memory approx


Hardware Requirements
---------------------

This module can be used with any audio DAC/ADC/CODEC that supports the I2S standard.  Please see example applications for recommended evaluation platforms. 


Desciption/Operation
--------------------

The I2S master component runs in a single thread.  On calling the I2S master thread it's first task is to setup the hardware resources into a configuration suitable for I2S operation.

One clock block is clocked from the master clock (MCLK port).  This clock block is then used to clock the BCLK port.

Another clock block is then clocked from this BCLK port.  The LRCLK port and all data ports (both input and output) are then clocked from the BCLK clock-block.

MCLK ----> CB1 
            |
            |
            V
          BCLK Port
            |
            |
            V
           CB2 ---------> LRCLK
            |
            |
            L-----------> Data Port[0..n-1]

Once the ports have been setup the main I2S I/O loop is called.  Firstly this deals with the startup case.


API
===

Symbolic constants
------------------

.. doxygendefine:: I2S_MASTER_NUM_IN

.. doxygendefine:: I2S_MASTER_NUM_OUT

.. doxygendefine:: MCK_BCK_RATIO

Structures
----------

.. doxygenstruct:: i2s_master

Functions
---------

.. doxygenfunction:: i2s_master

Example
=======

This example is designed to run on the XR-USB-AUDIO-2.0-MC board. It takes 3 stereo I2S inputs and sends them out over 4 stereo I2S outputs. I2S_MASTER_NUM_IN and I2S_MASTER_NUM_OUT are defined in the Makefile.

First of all i2s_master should be included and the structure i2s_master defined.

.. literalinclude:: app_xai_i2s_master_demo/src/main.xc
  :start-after: //::declaration
  :end-before: //::

The top level of this example creates the i2s_master on core 1, along with a 1KHz clock to the PLL and occupies the remaining 6 threads with computation.

Core 0 runs the loopback function which reads the I2S inputs from the i2s_master thread over a streaming channel and sends them over a streaming channel back to the i2s_master thread to the I2S outputs.

.. literalinclude:: app_xai_i2s_master_demo/src/main.xc
  :start-after: //::main program
  :end-before: //::
