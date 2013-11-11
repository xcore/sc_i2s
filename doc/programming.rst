Programming guide
-----------------

The I2S master component runs in a single logical core.  This logical core takes the following parameters (see API for details):

    #. A structure containing the required hardware resources (i.e. clock-blocks and ports)
    #. A streaming channel end for communcation of data to/from the I2S logical core
    #. A master clock to bit clock divide value (typically 2, 4 or 8)

Typically the devide value passed into the function is 2, 4 or 8.  This can be calculated as follows:

divide = MCLK Frequency / (Sample Frequency * 64)

For example for a MCLK frequency of 24.576MHz and desired sample freqency of 48kHz::

    24.576 / (48000 * 64) = 8 

And for 96kHz::

    24.576 / (96000 * 64) = 4

If required, the function get_mclk_bclk_div() returns this value given a sample freqency and master clock frequency.

On calling the I2S master logical core it's first task is to setup the hardware resources into a configuration suitable for I2S operation. The data, LRCLK and BCLK are single bit ports setup as "buffered" ports with a transfer width of 32. This means that every input/output operation causes 32 bits of data to be transferred.

One clock block is clocked from the master clock (MCLK port).  This clock block is then used to clock the BCLK port.

Another clock block is then clocked from this BCLK port.  The LRCLK port and all data ports (both input and output) are then clocked from the BCLK clock-block::

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

Once the ports have been setup the main I2S I/O loop is called:

   #. The startup case is handled by setting up timed input/outputs on all of the data ports and the LRCLK port.  These define when the next input/output will happen.
   #. BCLK is then driven in order to clock out/in these inputs/outputs.
   #. Audio data is then sent/received over the channel, data will be left aligned in all cases.
   #. The "left" audio data is then output and input to/from the data-ports, 0 is then output to the LRCLK port.  
   #. The BCLK port is then driven with 32 clocks in order to clock out the output data and LRCLK and clock in the next input audio data samples.
   #. The process is then repeated for "right" audio samples with the LRCLK output being of the value 0xffffffff (i.e. 32 clocks of 1).


Usage Example
-------------

The ``I2S Master sliceKIT Loopback Demo`` example application implements a audio basic loopback on all channels (ADC to DAC).  This includes a main.xc with the call to I2S master, the loopback code and so on. These include board-support resources and functionalilty such as XN files, CODEC configuration, clocking configuration, port defines etc and a Makefile.

.. literalinclude:: module_i2s_master_example/main.xc
  :start-after: //::main program
  :end-before: //::

The function main() runs two logical cores, one which calls functions to setup the audio hardware on the board then finally the i2s_master() function.  The other calls a simple processing function.  This function simply inputs ADC data from the streaming channel and loops sends it back as ADC data over the streaming channel for all channels. In this case audio_hw_init() initilises the I2C bus, and audio_hw_config() configures clocking and CODEC via I2C.

main.xc includes the file app_global which includes build parameters for the specific app such as master clock freqencies, sample rate etc.

The app_* folders contain implementations of audio_hw_init() and audio_hw_config().  In all cases i2s_master.h should be included and the structure i2s_master defined.

.. literalinclude:: app_i2s_master_example_skc_l2/src/ports.h
  :start-after: //::declaration
  :end-before: //::



