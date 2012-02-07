I2S Master
''''''''''

This module is an I2S master transmitter and receiver in a single thread. It sends and receives samples over a pair of chanends and transmits audio over I2S. It can send and receive multiple I2S links on separate ports.

As a master it drives the bit clock (BCK) and word clock (WCK) on output ports. It is clocked by an external master clock (MCK) on an input port.

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

.. literalinclude:: app_xai_i2s_master_demo/src/xdk_xai_test.xc
  :start-after: //::declaration
  :end-before: //::

The top level of this example creates the i2s_master on core 1, along with a 1KHz clock to the PLL and occupies the remaining 6 threads with computation.

Core 0 runs the loopback function which reads the I2S inputs from the i2s_master thread over a streaming channel and sends them over a streaming channel back to the i2s_master thread to the I2S outputs.

.. literalinclude:: app_xai_i2s_master_demo/src/xdk_xai_test.xc
  :start-after: //::main program
  :end-before: //::
