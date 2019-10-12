# JOS labs
JOS labs are from mit 6.828 operating system engineering	[link](https://pdos.csail.mit.edu/6.828/2018/)

It is an OS system based on the Unix like system created by MIT for teaching purposes. With the labs, we are going to implement JOS kernel :D



#### Environment

* Ubuntu 16.04

* QEMU(patched)

* JOS



#### Set up

1. ##### Test ur toolchain with the following command.

   Most Linux and Unix systems have already installed the tool chains needed.  Test it to ensure it.

   a.	use objdump to print OS info

   ​	   `objdump -i`

   ​	   Make sure that the second line shows elf32-i386 (Intel 80386)

   b.   `gcc -m32 -print-libgcc-file-name`

   ​		The command should print something like `/usr/lib/gcc/i486-linux-gnu/*version*/libgcc.a` or `/usr/lib/gcc/x86_64-linux-gnu/*version*/32/libgcc.a`

   If it doesn't work, build ur own toolchain following the direction [here](https://pdos.csail.mit.edu/6.828/2018/tools.html)

##### 2.   Download QEMU emulator

​	  [QEMU](http://www.nongnu.org/qemu/) is a modern and fast PC emulator. In order to improve its debugging capacities, mit provides a patched version of QEMU.

​	 Download steps:

​	a. Clone git repository `git clone https://github.com/mit-pdos/6.828-qemu.git qemu`

​	b. download packages

​		ibsdl1.2-dev, libtool-bin, libglib2.0-dev, libz-dev, libpixman-1-dev

​	c. Configure the source code

​		`./configure --disable-kvm --disable-werror --target-list="i386-softmmu x86_64-softmmu"`

​    d. Run `make && make install`



For Mac users, u can find useful info [here](https://pdos.csail.mit.edu/6.828/2018/tools.html)

