I2S Master Loopback Demonstration Application
=============================================

.. toctree::

app_i2s_master_example_skc_l2 Quick Start Guide
-----------------------------------------------

This application is a simple demonstration that uses the I2S master module to implement a simple loopback in software.

It is designed to run on the XMOS L2 Slicekit Core board (XP-SKC-L2) in conjuction with an Audio Slice board (XS-SK-AUDIO).

The functionality of the program is a follows:

    * Setup the audio hardware on the board as required, this includes
        * Master clock selection, CODEC setup (using module_i2c_master)
    * Provide a digital loopback from all ADC inputs to all DAC outputs (that is, ADC1 -> DAC1)

This application should provide a good basis for anyone looking to implement or prototype DSP style audio processing on an XCore processor.

Hardware Setup
++++++++++++++

To setup the hardware:

    #. Connect the XA-SK-AUDIO slice card to the XP-SKC-L2 Slicekit core board using the connector maked with [TODO INSERT SLOT SYMBOL]. 
    #. Connect the XTAG-2 USB debug adaptor to the XP-SKC-L2 Slicekit core board (via the supplied adaptor board)
    #. Connect the XTAG-2 to host PC (as USB extension cable can be used if desired)
    #. Switch on the power supply to the XP-SKC-L2 Slicekit Core board
    #. Attach an audio source (such as an MP3 player) to input 1/2 via the 3.5mm audio jack.
    #. Attach speakers or headphones to output 1/2 via the 3.5mm audio jack.

.. figure:: images/hw_setup.png
   :width: 300px
   :align: center

   Hardware Setup for XA-SK-AUDIO demo (I2S master)

Import and Build the Application
++++++++++++++++++++++++++++++++

   #. Open xTimeComposer and check that it is operating in online mode. Open the edit perspective (Window->Open Perspective->XMOS Edit).
   #. Locate the ``'Slicekit I2S Master Demo'`` item in the xSOFTip pane on the bottom left of the window and drag it into the Project Explorer window in the xTimeComposer. This will also cause the modules on which this application depends (in this case, module_i2c_master) to be imported as well. 
   #. Click on the app_i2s_master_example_skc_l2 item in the Explorer pane then click on the build icon (hammer) in xTimeComposer. Check the console window to verify that the application has built successfully.

For help in using xTimeComposer, try the xTimeComposer tutorial.

Note that the Developer Column in the xTimeComposer on the right hand side of your screen provides information on the xSOFTip components you are using. Select the module_i2c_master component in the Project Explorer, and you will see its description together with API documentation. Having done this, click the `back` icon until you return to this quickstart guide within the Developer Column.

Run the Application
+++++++++++++++++++

Now that the application has been compiled, the next step is to run it on the Slicekit Core Board using the tools to load the application over JTAG (via the XTAG2 and Xtag Adaptor card) into the xCORE multicore microcontroller.

   #. Click on the ``Run`` icon (the white arrow in the green circle).
   #. The application will now be running and providing a loopback functionality. Listen for the output via headphones or speakers. If the audio source is changed to input 3/4, the output will be available on output 3/4. There is no need to restart the application, just switch the audio connections over.
   #. Terminating the application will cause the loopback to stop.

Next Steps
++++++++++

   #. Examine the code for the processing() fuction, this provides the loopback.  Experiment with modifying the audio signal (such as shifting the samples down to reduce the volume on one channel).
   #. Consider experimenting with adding the audio DSP modules/functions from the xSOFTip library such as the biquad filter and audio loudness components.




