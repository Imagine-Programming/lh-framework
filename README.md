lh-framework
============

A framework of MX LH modules for networking, data processing, api integration and more.

The following modules are currently implemented:

Crypto
------
* crypto.cipher.hide-mem (memory obfuscation)
* crypto.util.isaac (pseudo-random number generator, cryptographic) 
* crypto.checksum.crc32 (CRC32 using either a pre-calculated table or your own table)

Utilities
---------
* util.rgba (RGB and RGBA calculations, working with hexadecimal colors and negation) 

Networking
----------
* networking.resolve (Resolve hostnames and IP addresses, both IPv4 and IPv6 supported)

IMXLH Version
-------------
This code requires **[Imagine MemoryEx LH Compiler 1.2] [1]** or any version greater than that.  
Aside from that, **[MemoryEx 2.2] [2]** or greater is required to be able to load the produced LH modules.

Compile
-------
Compilation is easy, just run build.bat. When you want to add more modules to this framework,  
simply add each source to the makefile.lhm and make sure they build in build/lh-framework/lh/*.

If you don't do this, the updatemain tool will not generate an index of those modules and the  
CRC32 fingerprint required in main.lh will be lost.



  [1]: http://www.memoryex.net/imxlh.html        "IMXLH"
  [2]: http://www.memoryex.net/mx.html        "MX"