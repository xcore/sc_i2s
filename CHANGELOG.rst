sc_i2s Change Log
=================

1.5.0
------
    - RESOLVED:   ADC samples over the channel interface were misaligned.  Instead of the
                  expected left/right channel sequence: (l1, r1) ... (l2, r2) ... (l3, r3)
                  the following order was returned:(r1, l2) ... (r2, l3) ... (r3, l4)
                  This was resolved by by rotating the main loop such that the port I/O 
                  syncs with the channel I/O.
1.4.3
-----
    - Dependancy update only

1.4.2
-----
    - Dependancy update only
   
1.4.1
-----
    - More documentation and code updates following review 

1.4.0
-----
    - Updates to components and documents for slicekit and xSOFTip
