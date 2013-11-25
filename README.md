lh-framework
============

A framework of MX LH modules for networking, data processing, api integration and more.

The following modules are currently implemented:

Crypto
------
* crypto.cipher.hide-mem (memory obfuscation)
* crypto.util.isaac (pseudo-random number generator, cryptographic) 
* crypto.checksum.crc32 (CRC32 using either a pre-calculated table or your own table)
* crypto.checksum.crc64 (CRC64 using either a pre-calculated table or your own table)
* crypto.hash.md5 (Fast MD5 module)
* crypto.hash.md5_slow (Slower but smaller MD5 module)
* crypto.hash.murmur-hash3 (MurmurHash3 algorithm)

Utilities
---------
* util.rgba (RGB and RGBA calculations, working with hexadecimal colors and negation) 
* util.bit (32-bit calculations, such as shifts, logical ops, rotates, bounds and addition/subtractions) 

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

Compile Memory Libraries
------------------------
The LH framework comes with the source code for the used memory libraries, such as ISAAC and 
libmd5. We have developed these libraries based on existing code, or solely based on the 
published algorithm. All these sources fall under the MIT license, however are public 
domain code.

Compile these libraries using VC++ 2013.


  [1]: http://www.memoryex.net/imxlh.html        "IMXLH"
  [2]: http://www.memoryex.net/mx.html        "MX"