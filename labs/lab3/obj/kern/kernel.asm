
obj/kern/kernel:     file format elf32-i386


Disassembly of section .text:

f0100000 <_start+0xeffffff4>:
.globl		_start
_start = RELOC(entry)

.globl entry
entry:
	movw	$0x1234,0x472			# warm boot
f0100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
f0100006:	00 00                	add    %al,(%eax)
f0100008:	fe 4f 52             	decb   0x52(%edi)
f010000b:	e4                   	.byte 0xe4

f010000c <entry>:
f010000c:	66 c7 05 72 04 00 00 	movw   $0x1234,0x472
f0100013:	34 12 
	# sufficient until we set up our real page table in mem_init
	# in lab 2.

	# Load the physical address of entry_pgdir into cr3.  entry_pgdir
	# is defined in entrypgdir.c.
	movl	$(RELOC(entry_pgdir)), %eax
f0100015:	b8 00 a0 11 00       	mov    $0x11a000,%eax
	movl	%eax, %cr3
f010001a:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl	%cr0, %eax
f010001d:	0f 20 c0             	mov    %cr0,%eax
	orl	$(CR0_PE|CR0_PG|CR0_WP), %eax
f0100020:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl	%eax, %cr0
f0100025:	0f 22 c0             	mov    %eax,%cr0

	# Now paging is enabled, but we're still running at a low EIP
	# (why is this okay?).  Jump up above KERNBASE before entering
	# C code.
	mov	$relocated, %eax
f0100028:	b8 2f 00 10 f0       	mov    $0xf010002f,%eax
	jmp	*%eax
f010002d:	ff e0                	jmp    *%eax

f010002f <relocated>:
relocated:

	# Clear the frame pointer register (EBP)
	# so that once we get into debugging C code,
	# stack backtraces will be terminated properly.
	movl	$0x0,%ebp			# nuke frame pointer
f010002f:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Set the stack pointer
	movl	$(bootstacktop),%esp
f0100034:	bc 00 a0 11 f0       	mov    $0xf011a000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 02 00 00 00       	call   f0100040 <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <i386_init>:
#include <kern/trap.h>


void
i386_init(void)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	83 ec 0c             	sub    $0xc,%esp
	extern char edata[], end[];

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f0100046:	b8 00 1a 1b f0       	mov    $0xf01b1a00,%eax
f010004b:	2d 00 0b 1b f0       	sub    $0xf01b0b00,%eax
f0100050:	50                   	push   %eax
f0100051:	6a 00                	push   $0x0
f0100053:	68 00 0b 1b f0       	push   $0xf01b0b00
f0100058:	e8 24 41 00 00       	call   f0104181 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f010005d:	e8 81 04 00 00       	call   f01004e3 <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f0100062:	83 c4 08             	add    $0x8,%esp
f0100065:	68 ac 1a 00 00       	push   $0x1aac
f010006a:	68 a0 45 10 f0       	push   $0xf01045a0
f010006f:	e8 e1 2e 00 00       	call   f0102f55 <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f0100074:	e8 e7 0e 00 00       	call   f0100f60 <mem_init>

	// Lab 3 user environment initialization functions
	env_init();
f0100079:	e8 e8 28 00 00       	call   f0102966 <env_init>
	trap_init();
f010007e:	e8 48 2f 00 00       	call   f0102fcb <trap_init>

#if defined(TEST)
	// Don't touch -- used by grading script!
	ENV_CREATE(TEST, ENV_TYPE_USER);
f0100083:	83 c4 08             	add    $0x8,%esp
f0100086:	6a 00                	push   $0x0
f0100088:	68 e2 e3 13 f0       	push   $0xf013e3e2
f010008d:	e8 a4 2a 00 00       	call   f0102b36 <env_create>
	// Touch all you want.
	ENV_CREATE(user_hello, ENV_TYPE_USER);
#endif // TEST*

	// We only have one user environment for now, so just run it.
	env_run(&envs[0]);
f0100092:	83 c4 04             	add    $0x4,%esp
f0100095:	ff 35 48 0d 1b f0    	pushl  0xf01b0d48
f010009b:	e8 eb 2d 00 00       	call   f0102e8b <env_run>

f01000a0 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f01000a0:	55                   	push   %ebp
f01000a1:	89 e5                	mov    %esp,%ebp
f01000a3:	56                   	push   %esi
f01000a4:	53                   	push   %ebx
f01000a5:	8b 75 10             	mov    0x10(%ebp),%esi
	va_list ap;

	if (panicstr)
f01000a8:	83 3d 04 1a 1b f0 00 	cmpl   $0x0,0xf01b1a04
f01000af:	74 0f                	je     f01000c0 <_panic+0x20>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f01000b1:	83 ec 0c             	sub    $0xc,%esp
f01000b4:	6a 00                	push   $0x0
f01000b6:	e8 25 06 00 00       	call   f01006e0 <monitor>
f01000bb:	83 c4 10             	add    $0x10,%esp
f01000be:	eb f1                	jmp    f01000b1 <_panic+0x11>
	panicstr = fmt;
f01000c0:	89 35 04 1a 1b f0    	mov    %esi,0xf01b1a04
	asm volatile("cli; cld");
f01000c6:	fa                   	cli    
f01000c7:	fc                   	cld    
	va_start(ap, fmt);
f01000c8:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic at %s:%d: ", file, line);
f01000cb:	83 ec 04             	sub    $0x4,%esp
f01000ce:	ff 75 0c             	pushl  0xc(%ebp)
f01000d1:	ff 75 08             	pushl  0x8(%ebp)
f01000d4:	68 bb 45 10 f0       	push   $0xf01045bb
f01000d9:	e8 77 2e 00 00       	call   f0102f55 <cprintf>
	vcprintf(fmt, ap);
f01000de:	83 c4 08             	add    $0x8,%esp
f01000e1:	53                   	push   %ebx
f01000e2:	56                   	push   %esi
f01000e3:	e8 47 2e 00 00       	call   f0102f2f <vcprintf>
	cprintf("\n");
f01000e8:	c7 04 24 13 4d 10 f0 	movl   $0xf0104d13,(%esp)
f01000ef:	e8 61 2e 00 00       	call   f0102f55 <cprintf>
f01000f4:	83 c4 10             	add    $0x10,%esp
f01000f7:	eb b8                	jmp    f01000b1 <_panic+0x11>

f01000f9 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f01000f9:	55                   	push   %ebp
f01000fa:	89 e5                	mov    %esp,%ebp
f01000fc:	53                   	push   %ebx
f01000fd:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0100100:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f0100103:	ff 75 0c             	pushl  0xc(%ebp)
f0100106:	ff 75 08             	pushl  0x8(%ebp)
f0100109:	68 d3 45 10 f0       	push   $0xf01045d3
f010010e:	e8 42 2e 00 00       	call   f0102f55 <cprintf>
	vcprintf(fmt, ap);
f0100113:	83 c4 08             	add    $0x8,%esp
f0100116:	53                   	push   %ebx
f0100117:	ff 75 10             	pushl  0x10(%ebp)
f010011a:	e8 10 2e 00 00       	call   f0102f2f <vcprintf>
	cprintf("\n");
f010011f:	c7 04 24 13 4d 10 f0 	movl   $0xf0104d13,(%esp)
f0100126:	e8 2a 2e 00 00       	call   f0102f55 <cprintf>
	va_end(ap);
}
f010012b:	83 c4 10             	add    $0x10,%esp
f010012e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100131:	c9                   	leave  
f0100132:	c3                   	ret    

f0100133 <serial_proc_data>:

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100133:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100138:	ec                   	in     (%dx),%al
static bool serial_exists;

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f0100139:	a8 01                	test   $0x1,%al
f010013b:	74 0a                	je     f0100147 <serial_proc_data+0x14>
f010013d:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100142:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f0100143:	0f b6 c0             	movzbl %al,%eax
f0100146:	c3                   	ret    
		return -1;
f0100147:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
f010014c:	c3                   	ret    

f010014d <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f010014d:	55                   	push   %ebp
f010014e:	89 e5                	mov    %esp,%ebp
f0100150:	53                   	push   %ebx
f0100151:	83 ec 04             	sub    $0x4,%esp
f0100154:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f0100156:	ff d3                	call   *%ebx
f0100158:	83 f8 ff             	cmp    $0xffffffff,%eax
f010015b:	74 2d                	je     f010018a <cons_intr+0x3d>
		if (c == 0)
f010015d:	85 c0                	test   %eax,%eax
f010015f:	74 f5                	je     f0100156 <cons_intr+0x9>
			continue;
		cons.buf[cons.wpos++] = c;
f0100161:	8b 0d 24 0d 1b f0    	mov    0xf01b0d24,%ecx
f0100167:	8d 51 01             	lea    0x1(%ecx),%edx
f010016a:	89 15 24 0d 1b f0    	mov    %edx,0xf01b0d24
f0100170:	88 81 20 0b 1b f0    	mov    %al,-0xfe4f4e0(%ecx)
		if (cons.wpos == CONSBUFSIZE)
f0100176:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f010017c:	75 d8                	jne    f0100156 <cons_intr+0x9>
			cons.wpos = 0;
f010017e:	c7 05 24 0d 1b f0 00 	movl   $0x0,0xf01b0d24
f0100185:	00 00 00 
f0100188:	eb cc                	jmp    f0100156 <cons_intr+0x9>
	}
}
f010018a:	83 c4 04             	add    $0x4,%esp
f010018d:	5b                   	pop    %ebx
f010018e:	5d                   	pop    %ebp
f010018f:	c3                   	ret    

f0100190 <kbd_proc_data>:
{
f0100190:	55                   	push   %ebp
f0100191:	89 e5                	mov    %esp,%ebp
f0100193:	53                   	push   %ebx
f0100194:	83 ec 04             	sub    $0x4,%esp
f0100197:	ba 64 00 00 00       	mov    $0x64,%edx
f010019c:	ec                   	in     (%dx),%al
	if ((stat & KBS_DIB) == 0)
f010019d:	a8 01                	test   $0x1,%al
f010019f:	0f 84 e9 00 00 00    	je     f010028e <kbd_proc_data+0xfe>
	if (stat & KBS_TERR)
f01001a5:	a8 20                	test   $0x20,%al
f01001a7:	0f 85 e8 00 00 00    	jne    f0100295 <kbd_proc_data+0x105>
f01001ad:	ba 60 00 00 00       	mov    $0x60,%edx
f01001b2:	ec                   	in     (%dx),%al
f01001b3:	88 c2                	mov    %al,%dl
	if (data == 0xE0) {
f01001b5:	3c e0                	cmp    $0xe0,%al
f01001b7:	74 60                	je     f0100219 <kbd_proc_data+0x89>
	} else if (data & 0x80) {
f01001b9:	84 c0                	test   %al,%al
f01001bb:	78 6f                	js     f010022c <kbd_proc_data+0x9c>
	} else if (shift & E0ESC) {
f01001bd:	8b 0d 00 0b 1b f0    	mov    0xf01b0b00,%ecx
f01001c3:	f6 c1 40             	test   $0x40,%cl
f01001c6:	74 0e                	je     f01001d6 <kbd_proc_data+0x46>
		data |= 0x80;
f01001c8:	83 c8 80             	or     $0xffffff80,%eax
f01001cb:	88 c2                	mov    %al,%dl
		shift &= ~E0ESC;
f01001cd:	83 e1 bf             	and    $0xffffffbf,%ecx
f01001d0:	89 0d 00 0b 1b f0    	mov    %ecx,0xf01b0b00
	shift |= shiftcode[data];
f01001d6:	0f b6 d2             	movzbl %dl,%edx
f01001d9:	0f b6 82 40 47 10 f0 	movzbl -0xfefb8c0(%edx),%eax
f01001e0:	0b 05 00 0b 1b f0    	or     0xf01b0b00,%eax
	shift ^= togglecode[data];
f01001e6:	0f b6 8a 40 46 10 f0 	movzbl -0xfefb9c0(%edx),%ecx
f01001ed:	31 c8                	xor    %ecx,%eax
f01001ef:	a3 00 0b 1b f0       	mov    %eax,0xf01b0b00
	c = charcode[shift & (CTL | SHIFT)][data];
f01001f4:	89 c1                	mov    %eax,%ecx
f01001f6:	83 e1 03             	and    $0x3,%ecx
f01001f9:	8b 0c 8d 20 46 10 f0 	mov    -0xfefb9e0(,%ecx,4),%ecx
f0100200:	8a 14 11             	mov    (%ecx,%edx,1),%dl
f0100203:	0f b6 da             	movzbl %dl,%ebx
	if (shift & CAPSLOCK) {
f0100206:	a8 08                	test   $0x8,%al
f0100208:	74 5c                	je     f0100266 <kbd_proc_data+0xd6>
		if ('a' <= c && c <= 'z')
f010020a:	89 da                	mov    %ebx,%edx
f010020c:	8d 4b 9f             	lea    -0x61(%ebx),%ecx
f010020f:	83 f9 19             	cmp    $0x19,%ecx
f0100212:	77 47                	ja     f010025b <kbd_proc_data+0xcb>
			c += 'A' - 'a';
f0100214:	83 eb 20             	sub    $0x20,%ebx
f0100217:	eb 0c                	jmp    f0100225 <kbd_proc_data+0x95>
		shift |= E0ESC;
f0100219:	83 0d 00 0b 1b f0 40 	orl    $0x40,0xf01b0b00
		return 0;
f0100220:	bb 00 00 00 00       	mov    $0x0,%ebx
}
f0100225:	89 d8                	mov    %ebx,%eax
f0100227:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010022a:	c9                   	leave  
f010022b:	c3                   	ret    
		data = (shift & E0ESC ? data : data & 0x7F);
f010022c:	8b 0d 00 0b 1b f0    	mov    0xf01b0b00,%ecx
f0100232:	f6 c1 40             	test   $0x40,%cl
f0100235:	75 05                	jne    f010023c <kbd_proc_data+0xac>
f0100237:	83 e0 7f             	and    $0x7f,%eax
f010023a:	88 c2                	mov    %al,%dl
		shift &= ~(shiftcode[data] | E0ESC);
f010023c:	0f b6 d2             	movzbl %dl,%edx
f010023f:	8a 82 40 47 10 f0    	mov    -0xfefb8c0(%edx),%al
f0100245:	83 c8 40             	or     $0x40,%eax
f0100248:	0f b6 c0             	movzbl %al,%eax
f010024b:	f7 d0                	not    %eax
f010024d:	21 c8                	and    %ecx,%eax
f010024f:	a3 00 0b 1b f0       	mov    %eax,0xf01b0b00
		return 0;
f0100254:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100259:	eb ca                	jmp    f0100225 <kbd_proc_data+0x95>
		else if ('A' <= c && c <= 'Z')
f010025b:	83 ea 41             	sub    $0x41,%edx
f010025e:	83 fa 19             	cmp    $0x19,%edx
f0100261:	77 03                	ja     f0100266 <kbd_proc_data+0xd6>
			c += 'a' - 'A';
f0100263:	83 c3 20             	add    $0x20,%ebx
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f0100266:	f7 d0                	not    %eax
f0100268:	a8 06                	test   $0x6,%al
f010026a:	75 b9                	jne    f0100225 <kbd_proc_data+0x95>
f010026c:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f0100272:	75 b1                	jne    f0100225 <kbd_proc_data+0x95>
		cprintf("Rebooting!\n");
f0100274:	83 ec 0c             	sub    $0xc,%esp
f0100277:	68 ed 45 10 f0       	push   $0xf01045ed
f010027c:	e8 d4 2c 00 00       	call   f0102f55 <cprintf>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100281:	b0 03                	mov    $0x3,%al
f0100283:	ba 92 00 00 00       	mov    $0x92,%edx
f0100288:	ee                   	out    %al,(%dx)
}
f0100289:	83 c4 10             	add    $0x10,%esp
f010028c:	eb 97                	jmp    f0100225 <kbd_proc_data+0x95>
		return -1;
f010028e:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
f0100293:	eb 90                	jmp    f0100225 <kbd_proc_data+0x95>
		return -1;
f0100295:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
f010029a:	eb 89                	jmp    f0100225 <kbd_proc_data+0x95>

f010029c <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f010029c:	55                   	push   %ebp
f010029d:	89 e5                	mov    %esp,%ebp
f010029f:	57                   	push   %edi
f01002a0:	56                   	push   %esi
f01002a1:	53                   	push   %ebx
f01002a2:	83 ec 1c             	sub    $0x1c,%esp
f01002a5:	89 c1                	mov    %eax,%ecx
	for (i = 0;
f01002a7:	be 01 32 00 00       	mov    $0x3201,%esi
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01002ac:	bf fd 03 00 00       	mov    $0x3fd,%edi
f01002b1:	bb 84 00 00 00       	mov    $0x84,%ebx
f01002b6:	89 fa                	mov    %edi,%edx
f01002b8:	ec                   	in     (%dx),%al
f01002b9:	a8 20                	test   $0x20,%al
f01002bb:	75 0b                	jne    f01002c8 <cons_putc+0x2c>
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f01002bd:	4e                   	dec    %esi
f01002be:	74 08                	je     f01002c8 <cons_putc+0x2c>
f01002c0:	89 da                	mov    %ebx,%edx
f01002c2:	ec                   	in     (%dx),%al
f01002c3:	ec                   	in     (%dx),%al
f01002c4:	ec                   	in     (%dx),%al
f01002c5:	ec                   	in     (%dx),%al
f01002c6:	eb ee                	jmp    f01002b6 <cons_putc+0x1a>
	outb(COM1 + COM_TX, c);
f01002c8:	88 4d e7             	mov    %cl,-0x19(%ebp)
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01002cb:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01002d0:	88 c8                	mov    %cl,%al
f01002d2:	ee                   	out    %al,(%dx)
}
f01002d3:	be 01 32 00 00       	mov    $0x3201,%esi
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01002d8:	bf 79 03 00 00       	mov    $0x379,%edi
f01002dd:	bb 84 00 00 00       	mov    $0x84,%ebx
f01002e2:	89 fa                	mov    %edi,%edx
f01002e4:	ec                   	in     (%dx),%al
	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f01002e5:	84 c0                	test   %al,%al
f01002e7:	78 0b                	js     f01002f4 <cons_putc+0x58>
f01002e9:	4e                   	dec    %esi
f01002ea:	74 08                	je     f01002f4 <cons_putc+0x58>
f01002ec:	89 da                	mov    %ebx,%edx
f01002ee:	ec                   	in     (%dx),%al
f01002ef:	ec                   	in     (%dx),%al
f01002f0:	ec                   	in     (%dx),%al
f01002f1:	ec                   	in     (%dx),%al
f01002f2:	eb ee                	jmp    f01002e2 <cons_putc+0x46>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01002f4:	ba 78 03 00 00       	mov    $0x378,%edx
f01002f9:	8a 45 e7             	mov    -0x19(%ebp),%al
f01002fc:	ee                   	out    %al,(%dx)
f01002fd:	ba 7a 03 00 00       	mov    $0x37a,%edx
f0100302:	b0 0d                	mov    $0xd,%al
f0100304:	ee                   	out    %al,(%dx)
f0100305:	b0 08                	mov    $0x8,%al
f0100307:	ee                   	out    %al,(%dx)
	if (!(c & ~0xFF))
f0100308:	f7 c1 00 ff ff ff    	test   $0xffffff00,%ecx
f010030e:	75 03                	jne    f0100313 <cons_putc+0x77>
		c |= 0x0700;
f0100310:	80 cd 07             	or     $0x7,%ch
	switch (c & 0xff) {
f0100313:	0f b6 c1             	movzbl %cl,%eax
f0100316:	80 f9 0a             	cmp    $0xa,%cl
f0100319:	0f 84 d7 00 00 00    	je     f01003f6 <cons_putc+0x15a>
f010031f:	83 f8 0a             	cmp    $0xa,%eax
f0100322:	7f 46                	jg     f010036a <cons_putc+0xce>
f0100324:	83 f8 08             	cmp    $0x8,%eax
f0100327:	0f 84 a4 00 00 00    	je     f01003d1 <cons_putc+0x135>
f010032d:	83 f8 09             	cmp    $0x9,%eax
f0100330:	0f 85 cd 00 00 00    	jne    f0100403 <cons_putc+0x167>
		cons_putc(' ');
f0100336:	b8 20 00 00 00       	mov    $0x20,%eax
f010033b:	e8 5c ff ff ff       	call   f010029c <cons_putc>
		cons_putc(' ');
f0100340:	b8 20 00 00 00       	mov    $0x20,%eax
f0100345:	e8 52 ff ff ff       	call   f010029c <cons_putc>
		cons_putc(' ');
f010034a:	b8 20 00 00 00       	mov    $0x20,%eax
f010034f:	e8 48 ff ff ff       	call   f010029c <cons_putc>
		cons_putc(' ');
f0100354:	b8 20 00 00 00       	mov    $0x20,%eax
f0100359:	e8 3e ff ff ff       	call   f010029c <cons_putc>
		cons_putc(' ');
f010035e:	b8 20 00 00 00       	mov    $0x20,%eax
f0100363:	e8 34 ff ff ff       	call   f010029c <cons_putc>
		break;
f0100368:	eb 28                	jmp    f0100392 <cons_putc+0xf6>
	switch (c & 0xff) {
f010036a:	83 f8 0d             	cmp    $0xd,%eax
f010036d:	0f 85 90 00 00 00    	jne    f0100403 <cons_putc+0x167>
		crt_pos -= (crt_pos % CRT_COLS);
f0100373:	66 8b 0d 28 0d 1b f0 	mov    0xf01b0d28,%cx
f010037a:	bb 50 00 00 00       	mov    $0x50,%ebx
f010037f:	89 c8                	mov    %ecx,%eax
f0100381:	ba 00 00 00 00       	mov    $0x0,%edx
f0100386:	66 f7 f3             	div    %bx
f0100389:	29 d1                	sub    %edx,%ecx
f010038b:	66 89 0d 28 0d 1b f0 	mov    %cx,0xf01b0d28
	if (crt_pos >= CRT_SIZE) {
f0100392:	66 81 3d 28 0d 1b f0 	cmpw   $0x7cf,0xf01b0d28
f0100399:	cf 07 
f010039b:	0f 87 84 00 00 00    	ja     f0100425 <cons_putc+0x189>
	outb(addr_6845, 14);
f01003a1:	8b 0d 30 0d 1b f0    	mov    0xf01b0d30,%ecx
f01003a7:	b0 0e                	mov    $0xe,%al
f01003a9:	89 ca                	mov    %ecx,%edx
f01003ab:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f01003ac:	8d 59 01             	lea    0x1(%ecx),%ebx
f01003af:	66 a1 28 0d 1b f0    	mov    0xf01b0d28,%ax
f01003b5:	66 c1 e8 08          	shr    $0x8,%ax
f01003b9:	89 da                	mov    %ebx,%edx
f01003bb:	ee                   	out    %al,(%dx)
f01003bc:	b0 0f                	mov    $0xf,%al
f01003be:	89 ca                	mov    %ecx,%edx
f01003c0:	ee                   	out    %al,(%dx)
f01003c1:	a0 28 0d 1b f0       	mov    0xf01b0d28,%al
f01003c6:	89 da                	mov    %ebx,%edx
f01003c8:	ee                   	out    %al,(%dx)
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f01003c9:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01003cc:	5b                   	pop    %ebx
f01003cd:	5e                   	pop    %esi
f01003ce:	5f                   	pop    %edi
f01003cf:	5d                   	pop    %ebp
f01003d0:	c3                   	ret    
		if (crt_pos > 0) {
f01003d1:	66 a1 28 0d 1b f0    	mov    0xf01b0d28,%ax
f01003d7:	66 85 c0             	test   %ax,%ax
f01003da:	74 c5                	je     f01003a1 <cons_putc+0x105>
			crt_pos--;
f01003dc:	48                   	dec    %eax
f01003dd:	66 a3 28 0d 1b f0    	mov    %ax,0xf01b0d28
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f01003e3:	0f b7 d0             	movzwl %ax,%edx
f01003e6:	b1 00                	mov    $0x0,%cl
f01003e8:	83 c9 20             	or     $0x20,%ecx
f01003eb:	a1 2c 0d 1b f0       	mov    0xf01b0d2c,%eax
f01003f0:	66 89 0c 50          	mov    %cx,(%eax,%edx,2)
f01003f4:	eb 9c                	jmp    f0100392 <cons_putc+0xf6>
		crt_pos += CRT_COLS;
f01003f6:	66 83 05 28 0d 1b f0 	addw   $0x50,0xf01b0d28
f01003fd:	50 
f01003fe:	e9 70 ff ff ff       	jmp    f0100373 <cons_putc+0xd7>
		crt_buf[crt_pos++] = c;		/* write the character */
f0100403:	66 a1 28 0d 1b f0    	mov    0xf01b0d28,%ax
f0100409:	8d 50 01             	lea    0x1(%eax),%edx
f010040c:	66 89 15 28 0d 1b f0 	mov    %dx,0xf01b0d28
f0100413:	0f b7 c0             	movzwl %ax,%eax
f0100416:	8b 15 2c 0d 1b f0    	mov    0xf01b0d2c,%edx
f010041c:	66 89 0c 42          	mov    %cx,(%edx,%eax,2)
		break;
f0100420:	e9 6d ff ff ff       	jmp    f0100392 <cons_putc+0xf6>
		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f0100425:	a1 2c 0d 1b f0       	mov    0xf01b0d2c,%eax
f010042a:	83 ec 04             	sub    $0x4,%esp
f010042d:	68 00 0f 00 00       	push   $0xf00
f0100432:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f0100438:	52                   	push   %edx
f0100439:	50                   	push   %eax
f010043a:	e8 8d 3d 00 00       	call   f01041cc <memmove>
			crt_buf[i] = 0x0700 | ' ';
f010043f:	8b 15 2c 0d 1b f0    	mov    0xf01b0d2c,%edx
f0100445:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f010044b:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f0100451:	83 c4 10             	add    $0x10,%esp
f0100454:	66 c7 00 20 07       	movw   $0x720,(%eax)
f0100459:	83 c0 02             	add    $0x2,%eax
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f010045c:	39 d0                	cmp    %edx,%eax
f010045e:	75 f4                	jne    f0100454 <cons_putc+0x1b8>
		crt_pos -= CRT_COLS;
f0100460:	66 83 2d 28 0d 1b f0 	subw   $0x50,0xf01b0d28
f0100467:	50 
f0100468:	e9 34 ff ff ff       	jmp    f01003a1 <cons_putc+0x105>

f010046d <serial_intr>:
	if (serial_exists)
f010046d:	80 3d 34 0d 1b f0 00 	cmpb   $0x0,0xf01b0d34
f0100474:	75 01                	jne    f0100477 <serial_intr+0xa>
f0100476:	c3                   	ret    
{
f0100477:	55                   	push   %ebp
f0100478:	89 e5                	mov    %esp,%ebp
f010047a:	83 ec 08             	sub    $0x8,%esp
		cons_intr(serial_proc_data);
f010047d:	b8 33 01 10 f0       	mov    $0xf0100133,%eax
f0100482:	e8 c6 fc ff ff       	call   f010014d <cons_intr>
}
f0100487:	c9                   	leave  
f0100488:	c3                   	ret    

f0100489 <kbd_intr>:
{
f0100489:	55                   	push   %ebp
f010048a:	89 e5                	mov    %esp,%ebp
f010048c:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f010048f:	b8 90 01 10 f0       	mov    $0xf0100190,%eax
f0100494:	e8 b4 fc ff ff       	call   f010014d <cons_intr>
}
f0100499:	c9                   	leave  
f010049a:	c3                   	ret    

f010049b <cons_getc>:
{
f010049b:	55                   	push   %ebp
f010049c:	89 e5                	mov    %esp,%ebp
f010049e:	83 ec 08             	sub    $0x8,%esp
	serial_intr();
f01004a1:	e8 c7 ff ff ff       	call   f010046d <serial_intr>
	kbd_intr();
f01004a6:	e8 de ff ff ff       	call   f0100489 <kbd_intr>
	if (cons.rpos != cons.wpos) {
f01004ab:	a1 20 0d 1b f0       	mov    0xf01b0d20,%eax
f01004b0:	3b 05 24 0d 1b f0    	cmp    0xf01b0d24,%eax
f01004b6:	74 24                	je     f01004dc <cons_getc+0x41>
		c = cons.buf[cons.rpos++];
f01004b8:	8d 50 01             	lea    0x1(%eax),%edx
f01004bb:	89 15 20 0d 1b f0    	mov    %edx,0xf01b0d20
f01004c1:	0f b6 80 20 0b 1b f0 	movzbl -0xfe4f4e0(%eax),%eax
		if (cons.rpos == CONSBUFSIZE)
f01004c8:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f01004ce:	75 11                	jne    f01004e1 <cons_getc+0x46>
			cons.rpos = 0;
f01004d0:	c7 05 20 0d 1b f0 00 	movl   $0x0,0xf01b0d20
f01004d7:	00 00 00 
f01004da:	eb 05                	jmp    f01004e1 <cons_getc+0x46>
	return 0;
f01004dc:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01004e1:	c9                   	leave  
f01004e2:	c3                   	ret    

f01004e3 <cons_init>:

// initialize the console devices
void
cons_init(void)
{
f01004e3:	55                   	push   %ebp
f01004e4:	89 e5                	mov    %esp,%ebp
f01004e6:	57                   	push   %edi
f01004e7:	56                   	push   %esi
f01004e8:	53                   	push   %ebx
f01004e9:	83 ec 0c             	sub    $0xc,%esp
	was = *cp;
f01004ec:	66 8b 15 00 80 0b f0 	mov    0xf00b8000,%dx
	*cp = (uint16_t) 0xA55A;
f01004f3:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f01004fa:	5a a5 
	if (*cp != 0xA55A) {
f01004fc:	66 a1 00 80 0b f0    	mov    0xf00b8000,%ax
f0100502:	66 3d 5a a5          	cmp    $0xa55a,%ax
f0100506:	0f 84 a2 00 00 00    	je     f01005ae <cons_init+0xcb>
		addr_6845 = MONO_BASE;
f010050c:	c7 05 30 0d 1b f0 b4 	movl   $0x3b4,0xf01b0d30
f0100513:	03 00 00 
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f0100516:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
	outb(addr_6845, 14);
f010051b:	8b 3d 30 0d 1b f0    	mov    0xf01b0d30,%edi
f0100521:	b0 0e                	mov    $0xe,%al
f0100523:	89 fa                	mov    %edi,%edx
f0100525:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f0100526:	8d 4f 01             	lea    0x1(%edi),%ecx
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100529:	89 ca                	mov    %ecx,%edx
f010052b:	ec                   	in     (%dx),%al
f010052c:	0f b6 c0             	movzbl %al,%eax
f010052f:	c1 e0 08             	shl    $0x8,%eax
f0100532:	89 c3                	mov    %eax,%ebx
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100534:	b0 0f                	mov    $0xf,%al
f0100536:	89 fa                	mov    %edi,%edx
f0100538:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100539:	89 ca                	mov    %ecx,%edx
f010053b:	ec                   	in     (%dx),%al
	crt_buf = (uint16_t*) cp;
f010053c:	89 35 2c 0d 1b f0    	mov    %esi,0xf01b0d2c
	pos |= inb(addr_6845 + 1);
f0100542:	0f b6 c0             	movzbl %al,%eax
f0100545:	09 d8                	or     %ebx,%eax
	crt_pos = pos;
f0100547:	66 a3 28 0d 1b f0    	mov    %ax,0xf01b0d28
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010054d:	b1 00                	mov    $0x0,%cl
f010054f:	bb fa 03 00 00       	mov    $0x3fa,%ebx
f0100554:	88 c8                	mov    %cl,%al
f0100556:	89 da                	mov    %ebx,%edx
f0100558:	ee                   	out    %al,(%dx)
f0100559:	bf fb 03 00 00       	mov    $0x3fb,%edi
f010055e:	b0 80                	mov    $0x80,%al
f0100560:	89 fa                	mov    %edi,%edx
f0100562:	ee                   	out    %al,(%dx)
f0100563:	b0 0c                	mov    $0xc,%al
f0100565:	ba f8 03 00 00       	mov    $0x3f8,%edx
f010056a:	ee                   	out    %al,(%dx)
f010056b:	be f9 03 00 00       	mov    $0x3f9,%esi
f0100570:	88 c8                	mov    %cl,%al
f0100572:	89 f2                	mov    %esi,%edx
f0100574:	ee                   	out    %al,(%dx)
f0100575:	b0 03                	mov    $0x3,%al
f0100577:	89 fa                	mov    %edi,%edx
f0100579:	ee                   	out    %al,(%dx)
f010057a:	ba fc 03 00 00       	mov    $0x3fc,%edx
f010057f:	88 c8                	mov    %cl,%al
f0100581:	ee                   	out    %al,(%dx)
f0100582:	b0 01                	mov    $0x1,%al
f0100584:	89 f2                	mov    %esi,%edx
f0100586:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100587:	ba fd 03 00 00       	mov    $0x3fd,%edx
f010058c:	ec                   	in     (%dx),%al
f010058d:	88 c1                	mov    %al,%cl
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f010058f:	3c ff                	cmp    $0xff,%al
f0100591:	0f 95 05 34 0d 1b f0 	setne  0xf01b0d34
f0100598:	89 da                	mov    %ebx,%edx
f010059a:	ec                   	in     (%dx),%al
f010059b:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01005a0:	ec                   	in     (%dx),%al
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f01005a1:	80 f9 ff             	cmp    $0xff,%cl
f01005a4:	74 23                	je     f01005c9 <cons_init+0xe6>
		cprintf("Serial port does not exist!\n");
}
f01005a6:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01005a9:	5b                   	pop    %ebx
f01005aa:	5e                   	pop    %esi
f01005ab:	5f                   	pop    %edi
f01005ac:	5d                   	pop    %ebp
f01005ad:	c3                   	ret    
		*cp = was;
f01005ae:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f01005b5:	c7 05 30 0d 1b f0 d4 	movl   $0x3d4,0xf01b0d30
f01005bc:	03 00 00 
	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f01005bf:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
f01005c4:	e9 52 ff ff ff       	jmp    f010051b <cons_init+0x38>
		cprintf("Serial port does not exist!\n");
f01005c9:	83 ec 0c             	sub    $0xc,%esp
f01005cc:	68 f9 45 10 f0       	push   $0xf01045f9
f01005d1:	e8 7f 29 00 00       	call   f0102f55 <cprintf>
f01005d6:	83 c4 10             	add    $0x10,%esp
}
f01005d9:	eb cb                	jmp    f01005a6 <cons_init+0xc3>

f01005db <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f01005db:	55                   	push   %ebp
f01005dc:	89 e5                	mov    %esp,%ebp
f01005de:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f01005e1:	8b 45 08             	mov    0x8(%ebp),%eax
f01005e4:	e8 b3 fc ff ff       	call   f010029c <cons_putc>
}
f01005e9:	c9                   	leave  
f01005ea:	c3                   	ret    

f01005eb <getchar>:

int
getchar(void)
{
f01005eb:	55                   	push   %ebp
f01005ec:	89 e5                	mov    %esp,%ebp
f01005ee:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f01005f1:	e8 a5 fe ff ff       	call   f010049b <cons_getc>
f01005f6:	85 c0                	test   %eax,%eax
f01005f8:	74 f7                	je     f01005f1 <getchar+0x6>
		/* do nothing */;
	return c;
}
f01005fa:	c9                   	leave  
f01005fb:	c3                   	ret    

f01005fc <iscons>:
int
iscons(int fdnum)
{
	// used by readline
	return 1;
}
f01005fc:	b8 01 00 00 00       	mov    $0x1,%eax
f0100601:	c3                   	ret    

f0100602 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f0100602:	55                   	push   %ebp
f0100603:	89 e5                	mov    %esp,%ebp
f0100605:	83 ec 0c             	sub    $0xc,%esp
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f0100608:	68 40 48 10 f0       	push   $0xf0104840
f010060d:	68 5e 48 10 f0       	push   $0xf010485e
f0100612:	68 63 48 10 f0       	push   $0xf0104863
f0100617:	e8 39 29 00 00       	call   f0102f55 <cprintf>
f010061c:	83 c4 0c             	add    $0xc,%esp
f010061f:	68 cc 48 10 f0       	push   $0xf01048cc
f0100624:	68 6c 48 10 f0       	push   $0xf010486c
f0100629:	68 63 48 10 f0       	push   $0xf0104863
f010062e:	e8 22 29 00 00       	call   f0102f55 <cprintf>
	return 0;
}
f0100633:	b8 00 00 00 00       	mov    $0x0,%eax
f0100638:	c9                   	leave  
f0100639:	c3                   	ret    

f010063a <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f010063a:	55                   	push   %ebp
f010063b:	89 e5                	mov    %esp,%ebp
f010063d:	83 ec 14             	sub    $0x14,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f0100640:	68 75 48 10 f0       	push   $0xf0104875
f0100645:	e8 0b 29 00 00       	call   f0102f55 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f010064a:	83 c4 08             	add    $0x8,%esp
f010064d:	68 0c 00 10 00       	push   $0x10000c
f0100652:	68 f4 48 10 f0       	push   $0xf01048f4
f0100657:	e8 f9 28 00 00       	call   f0102f55 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f010065c:	83 c4 0c             	add    $0xc,%esp
f010065f:	68 0c 00 10 00       	push   $0x10000c
f0100664:	68 0c 00 10 f0       	push   $0xf010000c
f0100669:	68 1c 49 10 f0       	push   $0xf010491c
f010066e:	e8 e2 28 00 00       	call   f0102f55 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f0100673:	83 c4 0c             	add    $0xc,%esp
f0100676:	68 82 45 10 00       	push   $0x104582
f010067b:	68 82 45 10 f0       	push   $0xf0104582
f0100680:	68 40 49 10 f0       	push   $0xf0104940
f0100685:	e8 cb 28 00 00       	call   f0102f55 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f010068a:	83 c4 0c             	add    $0xc,%esp
f010068d:	68 00 0b 1b 00       	push   $0x1b0b00
f0100692:	68 00 0b 1b f0       	push   $0xf01b0b00
f0100697:	68 64 49 10 f0       	push   $0xf0104964
f010069c:	e8 b4 28 00 00       	call   f0102f55 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f01006a1:	83 c4 0c             	add    $0xc,%esp
f01006a4:	68 00 1a 1b 00       	push   $0x1b1a00
f01006a9:	68 00 1a 1b f0       	push   $0xf01b1a00
f01006ae:	68 88 49 10 f0       	push   $0xf0104988
f01006b3:	e8 9d 28 00 00       	call   f0102f55 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
f01006b8:	83 c4 08             	add    $0x8,%esp
		ROUNDUP(end - entry, 1024) / 1024);
f01006bb:	b8 00 1a 1b f0       	mov    $0xf01b1a00,%eax
f01006c0:	2d 0d fc 0f f0       	sub    $0xf00ffc0d,%eax
	cprintf("Kernel executable memory footprint: %dKB\n",
f01006c5:	c1 f8 0a             	sar    $0xa,%eax
f01006c8:	50                   	push   %eax
f01006c9:	68 ac 49 10 f0       	push   $0xf01049ac
f01006ce:	e8 82 28 00 00       	call   f0102f55 <cprintf>
	return 0;
}
f01006d3:	b8 00 00 00 00       	mov    $0x0,%eax
f01006d8:	c9                   	leave  
f01006d9:	c3                   	ret    

f01006da <mon_backtrace>:
int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
	// Your code here.
	return 0;
}
f01006da:	b8 00 00 00 00       	mov    $0x0,%eax
f01006df:	c3                   	ret    

f01006e0 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f01006e0:	55                   	push   %ebp
f01006e1:	89 e5                	mov    %esp,%ebp
f01006e3:	57                   	push   %edi
f01006e4:	56                   	push   %esi
f01006e5:	53                   	push   %ebx
f01006e6:	83 ec 58             	sub    $0x58,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f01006e9:	68 d8 49 10 f0       	push   $0xf01049d8
f01006ee:	e8 62 28 00 00       	call   f0102f55 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f01006f3:	c7 04 24 fc 49 10 f0 	movl   $0xf01049fc,(%esp)
f01006fa:	e8 56 28 00 00       	call   f0102f55 <cprintf>

	if (tf != NULL)
f01006ff:	83 c4 10             	add    $0x10,%esp
f0100702:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f0100706:	0f 84 de 00 00 00    	je     f01007ea <monitor+0x10a>
		print_trapframe(tf);
f010070c:	83 ec 0c             	sub    $0xc,%esp
f010070f:	ff 75 08             	pushl  0x8(%ebp)
f0100712:	e8 80 2c 00 00       	call   f0103397 <print_trapframe>
f0100717:	83 c4 10             	add    $0x10,%esp
f010071a:	e9 cb 00 00 00       	jmp    f01007ea <monitor+0x10a>
		while (*buf && strchr(WHITESPACE, *buf))
f010071f:	83 ec 08             	sub    $0x8,%esp
f0100722:	0f be c0             	movsbl %al,%eax
f0100725:	50                   	push   %eax
f0100726:	68 92 48 10 f0       	push   $0xf0104892
f010072b:	e8 1c 3a 00 00       	call   f010414c <strchr>
f0100730:	83 c4 10             	add    $0x10,%esp
f0100733:	85 c0                	test   %eax,%eax
f0100735:	74 6b                	je     f01007a2 <monitor+0xc2>
			*buf++ = 0;
f0100737:	c6 03 00             	movb   $0x0,(%ebx)
f010073a:	89 f7                	mov    %esi,%edi
f010073c:	8d 5b 01             	lea    0x1(%ebx),%ebx
f010073f:	89 fe                	mov    %edi,%esi
		while (*buf && strchr(WHITESPACE, *buf))
f0100741:	8a 03                	mov    (%ebx),%al
f0100743:	84 c0                	test   %al,%al
f0100745:	75 d8                	jne    f010071f <monitor+0x3f>
	argv[argc] = 0;
f0100747:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f010074e:	00 
	if (argc == 0)
f010074f:	85 f6                	test   %esi,%esi
f0100751:	0f 84 93 00 00 00    	je     f01007ea <monitor+0x10a>
		if (strcmp(argv[0], commands[i].name) == 0)
f0100757:	83 ec 08             	sub    $0x8,%esp
f010075a:	68 5e 48 10 f0       	push   $0xf010485e
f010075f:	ff 75 a8             	pushl  -0x58(%ebp)
f0100762:	e8 91 39 00 00       	call   f01040f8 <strcmp>
f0100767:	83 c4 10             	add    $0x10,%esp
f010076a:	85 c0                	test   %eax,%eax
f010076c:	0f 84 a4 00 00 00    	je     f0100816 <monitor+0x136>
f0100772:	83 ec 08             	sub    $0x8,%esp
f0100775:	68 6c 48 10 f0       	push   $0xf010486c
f010077a:	ff 75 a8             	pushl  -0x58(%ebp)
f010077d:	e8 76 39 00 00       	call   f01040f8 <strcmp>
f0100782:	83 c4 10             	add    $0x10,%esp
f0100785:	85 c0                	test   %eax,%eax
f0100787:	0f 84 84 00 00 00    	je     f0100811 <monitor+0x131>
	cprintf("Unknown command '%s'\n", argv[0]);
f010078d:	83 ec 08             	sub    $0x8,%esp
f0100790:	ff 75 a8             	pushl  -0x58(%ebp)
f0100793:	68 b4 48 10 f0       	push   $0xf01048b4
f0100798:	e8 b8 27 00 00       	call   f0102f55 <cprintf>
	return 0;
f010079d:	83 c4 10             	add    $0x10,%esp
f01007a0:	eb 48                	jmp    f01007ea <monitor+0x10a>
		if (*buf == 0)
f01007a2:	80 3b 00             	cmpb   $0x0,(%ebx)
f01007a5:	74 a0                	je     f0100747 <monitor+0x67>
		if (argc == MAXARGS-1) {
f01007a7:	83 fe 0f             	cmp    $0xf,%esi
f01007aa:	74 2c                	je     f01007d8 <monitor+0xf8>
		argv[argc++] = buf;
f01007ac:	8d 7e 01             	lea    0x1(%esi),%edi
f01007af:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
		while (*buf && !strchr(WHITESPACE, *buf))
f01007b3:	8a 03                	mov    (%ebx),%al
f01007b5:	84 c0                	test   %al,%al
f01007b7:	74 86                	je     f010073f <monitor+0x5f>
f01007b9:	83 ec 08             	sub    $0x8,%esp
f01007bc:	0f be c0             	movsbl %al,%eax
f01007bf:	50                   	push   %eax
f01007c0:	68 92 48 10 f0       	push   $0xf0104892
f01007c5:	e8 82 39 00 00       	call   f010414c <strchr>
f01007ca:	83 c4 10             	add    $0x10,%esp
f01007cd:	85 c0                	test   %eax,%eax
f01007cf:	0f 85 6a ff ff ff    	jne    f010073f <monitor+0x5f>
			buf++;
f01007d5:	43                   	inc    %ebx
f01007d6:	eb db                	jmp    f01007b3 <monitor+0xd3>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f01007d8:	83 ec 08             	sub    $0x8,%esp
f01007db:	6a 10                	push   $0x10
f01007dd:	68 97 48 10 f0       	push   $0xf0104897
f01007e2:	e8 6e 27 00 00       	call   f0102f55 <cprintf>
			return 0;
f01007e7:	83 c4 10             	add    $0x10,%esp

	while (1) {
		buf = readline("K> ");
f01007ea:	83 ec 0c             	sub    $0xc,%esp
f01007ed:	68 8e 48 10 f0       	push   $0xf010488e
f01007f2:	e8 49 37 00 00       	call   f0103f40 <readline>
f01007f7:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f01007f9:	83 c4 10             	add    $0x10,%esp
f01007fc:	85 c0                	test   %eax,%eax
f01007fe:	74 ea                	je     f01007ea <monitor+0x10a>
	argv[argc] = 0;
f0100800:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	argc = 0;
f0100807:	be 00 00 00 00       	mov    $0x0,%esi
f010080c:	e9 30 ff ff ff       	jmp    f0100741 <monitor+0x61>
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f0100811:	b8 01 00 00 00       	mov    $0x1,%eax
			return commands[i].func(argc, argv, tf);
f0100816:	83 ec 04             	sub    $0x4,%esp
f0100819:	8d 14 00             	lea    (%eax,%eax,1),%edx
f010081c:	01 d0                	add    %edx,%eax
f010081e:	ff 75 08             	pushl  0x8(%ebp)
f0100821:	8d 4d a8             	lea    -0x58(%ebp),%ecx
f0100824:	51                   	push   %ecx
f0100825:	56                   	push   %esi
f0100826:	ff 14 85 2c 4a 10 f0 	call   *-0xfefb5d4(,%eax,4)
			if (runcmd(buf, tf) < 0)
f010082d:	83 c4 10             	add    $0x10,%esp
f0100830:	85 c0                	test   %eax,%eax
f0100832:	79 b6                	jns    f01007ea <monitor+0x10a>
				break;
	}
}
f0100834:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100837:	5b                   	pop    %ebx
f0100838:	5e                   	pop    %esi
f0100839:	5f                   	pop    %edi
f010083a:	5d                   	pop    %ebp
f010083b:	c3                   	ret    

f010083c <nvram_read>:
// Detect machine's physical memory setup.
// --------------------------------------------------------------

static int
nvram_read(int r)
{
f010083c:	55                   	push   %ebp
f010083d:	89 e5                	mov    %esp,%ebp
f010083f:	56                   	push   %esi
f0100840:	53                   	push   %ebx
f0100841:	89 c3                	mov    %eax,%ebx
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0100843:	83 ec 0c             	sub    $0xc,%esp
f0100846:	50                   	push   %eax
f0100847:	e8 a2 26 00 00       	call   f0102eee <mc146818_read>
f010084c:	89 c6                	mov    %eax,%esi
f010084e:	43                   	inc    %ebx
f010084f:	89 1c 24             	mov    %ebx,(%esp)
f0100852:	e8 97 26 00 00       	call   f0102eee <mc146818_read>
f0100857:	c1 e0 08             	shl    $0x8,%eax
f010085a:	09 f0                	or     %esi,%eax
}
f010085c:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010085f:	5b                   	pop    %ebx
f0100860:	5e                   	pop    %esi
f0100861:	5d                   	pop    %ebp
f0100862:	c3                   	ret    

f0100863 <boot_alloc>:
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f0100863:	83 3d 38 0d 1b f0 00 	cmpl   $0x0,0xf01b0d38
f010086a:	74 2c                	je     f0100898 <boot_alloc+0x35>
	// Allocate a chunk large enough to hold 'n' bytes, then update
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
	result = nextfree;			// Start address of the allocated contiguous memory block
f010086c:	8b 0d 38 0d 1b f0    	mov    0xf01b0d38,%ecx
	nextfree = ROUNDUP(nextfree + n, PGSIZE);
f0100872:	8d 84 01 ff 0f 00 00 	lea    0xfff(%ecx,%eax,1),%eax
f0100879:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f010087e:	a3 38 0d 1b f0       	mov    %eax,0xf01b0d38
	if ((uint32_t)nextfree - KERNBASE > (npages * PGSIZE))	// The allocated space exceeds total physical memory
f0100883:	05 00 00 00 10       	add    $0x10000000,%eax
f0100888:	8b 15 08 1a 1b f0    	mov    0xf01b1a08,%edx
f010088e:	c1 e2 0c             	shl    $0xc,%edx
f0100891:	39 d0                	cmp    %edx,%eax
f0100893:	77 16                	ja     f01008ab <boot_alloc+0x48>
		panic("Out of memory!");

	return result;
}
f0100895:	89 c8                	mov    %ecx,%eax
f0100897:	c3                   	ret    
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0100898:	ba ff 29 1b f0       	mov    $0xf01b29ff,%edx
f010089d:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01008a3:	89 15 38 0d 1b f0    	mov    %edx,0xf01b0d38
f01008a9:	eb c1                	jmp    f010086c <boot_alloc+0x9>
{
f01008ab:	55                   	push   %ebp
f01008ac:	89 e5                	mov    %esp,%ebp
f01008ae:	83 ec 0c             	sub    $0xc,%esp
		panic("Out of memory!");
f01008b1:	68 3c 4a 10 f0       	push   $0xf0104a3c
f01008b6:	6a 70                	push   $0x70
f01008b8:	68 4b 4a 10 f0       	push   $0xf0104a4b
f01008bd:	e8 de f7 ff ff       	call   f01000a0 <_panic>

f01008c2 <check_va2pa>:
static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
f01008c2:	89 d1                	mov    %edx,%ecx
f01008c4:	c1 e9 16             	shr    $0x16,%ecx
	if (!(*pgdir & PTE_P))
f01008c7:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f01008ca:	a8 01                	test   $0x1,%al
f01008cc:	74 48                	je     f0100916 <check_va2pa+0x54>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f01008ce:	89 c1                	mov    %eax,%ecx
f01008d0:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01008d6:	c1 e8 0c             	shr    $0xc,%eax
f01008d9:	3b 05 08 1a 1b f0    	cmp    0xf01b1a08,%eax
f01008df:	73 1a                	jae    f01008fb <check_va2pa+0x39>
	if (!(p[PTX(va)] & PTE_P))
f01008e1:	c1 ea 0c             	shr    $0xc,%edx
f01008e4:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f01008ea:	8b 84 91 00 00 00 f0 	mov    -0x10000000(%ecx,%edx,4),%eax
f01008f1:	a8 01                	test   $0x1,%al
f01008f3:	74 27                	je     f010091c <check_va2pa+0x5a>
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f01008f5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01008fa:	c3                   	ret    
{
f01008fb:	55                   	push   %ebp
f01008fc:	89 e5                	mov    %esp,%ebp
f01008fe:	83 ec 08             	sub    $0x8,%esp
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100901:	51                   	push   %ecx
f0100902:	68 48 4d 10 f0       	push   $0xf0104d48
f0100907:	68 3a 03 00 00       	push   $0x33a
f010090c:	68 4b 4a 10 f0       	push   $0xf0104a4b
f0100911:	e8 8a f7 ff ff       	call   f01000a0 <_panic>
		return ~0;
f0100916:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010091b:	c3                   	ret    
		return ~0;
f010091c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
f0100921:	c3                   	ret    

f0100922 <check_page_free_list>:
{
f0100922:	55                   	push   %ebp
f0100923:	89 e5                	mov    %esp,%ebp
f0100925:	57                   	push   %edi
f0100926:	56                   	push   %esi
f0100927:	53                   	push   %ebx
f0100928:	83 ec 2c             	sub    $0x2c,%esp
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f010092b:	84 c0                	test   %al,%al
f010092d:	0f 85 4f 02 00 00    	jne    f0100b82 <check_page_free_list+0x260>
	if (!page_free_list)
f0100933:	83 3d 3c 0d 1b f0 00 	cmpl   $0x0,0xf01b0d3c
f010093a:	74 0d                	je     f0100949 <check_page_free_list+0x27>
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f010093c:	be 00 04 00 00       	mov    $0x400,%esi
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100941:	8b 1d 3c 0d 1b f0    	mov    0xf01b0d3c,%ebx
f0100947:	eb 2b                	jmp    f0100974 <check_page_free_list+0x52>
		panic("'page_free_list' is a null pointer!");
f0100949:	83 ec 04             	sub    $0x4,%esp
f010094c:	68 6c 4d 10 f0       	push   $0xf0104d6c
f0100951:	68 76 02 00 00       	push   $0x276
f0100956:	68 4b 4a 10 f0       	push   $0xf0104a4b
f010095b:	e8 40 f7 ff ff       	call   f01000a0 <_panic>
f0100960:	50                   	push   %eax
f0100961:	68 48 4d 10 f0       	push   $0xf0104d48
f0100966:	6a 56                	push   $0x56
f0100968:	68 57 4a 10 f0       	push   $0xf0104a57
f010096d:	e8 2e f7 ff ff       	call   f01000a0 <_panic>
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100972:	8b 1b                	mov    (%ebx),%ebx
f0100974:	85 db                	test   %ebx,%ebx
f0100976:	74 41                	je     f01009b9 <check_page_free_list+0x97>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100978:	89 d8                	mov    %ebx,%eax
f010097a:	2b 05 10 1a 1b f0    	sub    0xf01b1a10,%eax
f0100980:	c1 f8 03             	sar    $0x3,%eax
f0100983:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f0100986:	89 c2                	mov    %eax,%edx
f0100988:	c1 ea 16             	shr    $0x16,%edx
f010098b:	39 f2                	cmp    %esi,%edx
f010098d:	73 e3                	jae    f0100972 <check_page_free_list+0x50>
	if (PGNUM(pa) >= npages)
f010098f:	89 c2                	mov    %eax,%edx
f0100991:	c1 ea 0c             	shr    $0xc,%edx
f0100994:	3b 15 08 1a 1b f0    	cmp    0xf01b1a08,%edx
f010099a:	73 c4                	jae    f0100960 <check_page_free_list+0x3e>
			memset(page2kva(pp), 0x97, 128);
f010099c:	83 ec 04             	sub    $0x4,%esp
f010099f:	68 80 00 00 00       	push   $0x80
f01009a4:	68 97 00 00 00       	push   $0x97
	return (void *)(pa + KERNBASE);
f01009a9:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01009ae:	50                   	push   %eax
f01009af:	e8 cd 37 00 00       	call   f0104181 <memset>
f01009b4:	83 c4 10             	add    $0x10,%esp
f01009b7:	eb b9                	jmp    f0100972 <check_page_free_list+0x50>
	first_free_page = (char *) boot_alloc(0);
f01009b9:	b8 00 00 00 00       	mov    $0x0,%eax
f01009be:	e8 a0 fe ff ff       	call   f0100863 <boot_alloc>
f01009c3:	89 45 cc             	mov    %eax,-0x34(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f01009c6:	8b 15 3c 0d 1b f0    	mov    0xf01b0d3c,%edx
		assert(pp >= pages);
f01009cc:	8b 0d 10 1a 1b f0    	mov    0xf01b1a10,%ecx
		assert(pp < pages + npages);
f01009d2:	a1 08 1a 1b f0       	mov    0xf01b1a08,%eax
f01009d7:	89 45 d0             	mov    %eax,-0x30(%ebp)
f01009da:	8d 3c c1             	lea    (%ecx,%eax,8),%edi
	int nfree_basemem = 0, nfree_extmem = 0;
f01009dd:	be 00 00 00 00       	mov    $0x0,%esi
f01009e2:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f01009e5:	e9 c8 00 00 00       	jmp    f0100ab2 <check_page_free_list+0x190>
		assert(pp >= pages);
f01009ea:	68 65 4a 10 f0       	push   $0xf0104a65
f01009ef:	68 71 4a 10 f0       	push   $0xf0104a71
f01009f4:	68 90 02 00 00       	push   $0x290
f01009f9:	68 4b 4a 10 f0       	push   $0xf0104a4b
f01009fe:	e8 9d f6 ff ff       	call   f01000a0 <_panic>
		assert(pp < pages + npages);
f0100a03:	68 86 4a 10 f0       	push   $0xf0104a86
f0100a08:	68 71 4a 10 f0       	push   $0xf0104a71
f0100a0d:	68 91 02 00 00       	push   $0x291
f0100a12:	68 4b 4a 10 f0       	push   $0xf0104a4b
f0100a17:	e8 84 f6 ff ff       	call   f01000a0 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100a1c:	68 90 4d 10 f0       	push   $0xf0104d90
f0100a21:	68 71 4a 10 f0       	push   $0xf0104a71
f0100a26:	68 92 02 00 00       	push   $0x292
f0100a2b:	68 4b 4a 10 f0       	push   $0xf0104a4b
f0100a30:	e8 6b f6 ff ff       	call   f01000a0 <_panic>
		assert(page2pa(pp) != 0);
f0100a35:	68 9a 4a 10 f0       	push   $0xf0104a9a
f0100a3a:	68 71 4a 10 f0       	push   $0xf0104a71
f0100a3f:	68 95 02 00 00       	push   $0x295
f0100a44:	68 4b 4a 10 f0       	push   $0xf0104a4b
f0100a49:	e8 52 f6 ff ff       	call   f01000a0 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100a4e:	68 ab 4a 10 f0       	push   $0xf0104aab
f0100a53:	68 71 4a 10 f0       	push   $0xf0104a71
f0100a58:	68 96 02 00 00       	push   $0x296
f0100a5d:	68 4b 4a 10 f0       	push   $0xf0104a4b
f0100a62:	e8 39 f6 ff ff       	call   f01000a0 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100a67:	68 c4 4d 10 f0       	push   $0xf0104dc4
f0100a6c:	68 71 4a 10 f0       	push   $0xf0104a71
f0100a71:	68 97 02 00 00       	push   $0x297
f0100a76:	68 4b 4a 10 f0       	push   $0xf0104a4b
f0100a7b:	e8 20 f6 ff ff       	call   f01000a0 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100a80:	68 c4 4a 10 f0       	push   $0xf0104ac4
f0100a85:	68 71 4a 10 f0       	push   $0xf0104a71
f0100a8a:	68 98 02 00 00       	push   $0x298
f0100a8f:	68 4b 4a 10 f0       	push   $0xf0104a4b
f0100a94:	e8 07 f6 ff ff       	call   f01000a0 <_panic>
	if (PGNUM(pa) >= npages)
f0100a99:	89 c3                	mov    %eax,%ebx
f0100a9b:	c1 eb 0c             	shr    $0xc,%ebx
f0100a9e:	39 5d d0             	cmp    %ebx,-0x30(%ebp)
f0100aa1:	76 62                	jbe    f0100b05 <check_page_free_list+0x1e3>
	return (void *)(pa + KERNBASE);
f0100aa3:	2d 00 00 00 10       	sub    $0x10000000,%eax
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100aa8:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f0100aab:	77 6a                	ja     f0100b17 <check_page_free_list+0x1f5>
			++nfree_extmem;
f0100aad:	ff 45 d4             	incl   -0x2c(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100ab0:	8b 12                	mov    (%edx),%edx
f0100ab2:	85 d2                	test   %edx,%edx
f0100ab4:	74 7a                	je     f0100b30 <check_page_free_list+0x20e>
		assert(pp >= pages);
f0100ab6:	39 d1                	cmp    %edx,%ecx
f0100ab8:	0f 87 2c ff ff ff    	ja     f01009ea <check_page_free_list+0xc8>
		assert(pp < pages + npages);
f0100abe:	39 d7                	cmp    %edx,%edi
f0100ac0:	0f 86 3d ff ff ff    	jbe    f0100a03 <check_page_free_list+0xe1>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100ac6:	89 d0                	mov    %edx,%eax
f0100ac8:	29 c8                	sub    %ecx,%eax
f0100aca:	a8 07                	test   $0x7,%al
f0100acc:	0f 85 4a ff ff ff    	jne    f0100a1c <check_page_free_list+0xfa>
	return (pp - pages) << PGSHIFT;
f0100ad2:	c1 f8 03             	sar    $0x3,%eax
		assert(page2pa(pp) != 0);
f0100ad5:	c1 e0 0c             	shl    $0xc,%eax
f0100ad8:	0f 84 57 ff ff ff    	je     f0100a35 <check_page_free_list+0x113>
		assert(page2pa(pp) != IOPHYSMEM);
f0100ade:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100ae3:	0f 84 65 ff ff ff    	je     f0100a4e <check_page_free_list+0x12c>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100ae9:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100aee:	0f 84 73 ff ff ff    	je     f0100a67 <check_page_free_list+0x145>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100af4:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100af9:	74 85                	je     f0100a80 <check_page_free_list+0x15e>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100afb:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0100b00:	77 97                	ja     f0100a99 <check_page_free_list+0x177>
			++nfree_basemem;
f0100b02:	46                   	inc    %esi
f0100b03:	eb ab                	jmp    f0100ab0 <check_page_free_list+0x18e>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100b05:	50                   	push   %eax
f0100b06:	68 48 4d 10 f0       	push   $0xf0104d48
f0100b0b:	6a 56                	push   $0x56
f0100b0d:	68 57 4a 10 f0       	push   $0xf0104a57
f0100b12:	e8 89 f5 ff ff       	call   f01000a0 <_panic>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100b17:	68 e8 4d 10 f0       	push   $0xf0104de8
f0100b1c:	68 71 4a 10 f0       	push   $0xf0104a71
f0100b21:	68 99 02 00 00       	push   $0x299
f0100b26:	68 4b 4a 10 f0       	push   $0xf0104a4b
f0100b2b:	e8 70 f5 ff ff       	call   f01000a0 <_panic>
f0100b30:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
	assert(nfree_basemem > 0);
f0100b33:	85 f6                	test   %esi,%esi
f0100b35:	7e 19                	jle    f0100b50 <check_page_free_list+0x22e>
	assert(nfree_extmem > 0);
f0100b37:	85 db                	test   %ebx,%ebx
f0100b39:	7e 2e                	jle    f0100b69 <check_page_free_list+0x247>
	cprintf("check_page_free_list() succeeded!\n");
f0100b3b:	83 ec 0c             	sub    $0xc,%esp
f0100b3e:	68 30 4e 10 f0       	push   $0xf0104e30
f0100b43:	e8 0d 24 00 00       	call   f0102f55 <cprintf>
}
f0100b48:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100b4b:	5b                   	pop    %ebx
f0100b4c:	5e                   	pop    %esi
f0100b4d:	5f                   	pop    %edi
f0100b4e:	5d                   	pop    %ebp
f0100b4f:	c3                   	ret    
	assert(nfree_basemem > 0);
f0100b50:	68 de 4a 10 f0       	push   $0xf0104ade
f0100b55:	68 71 4a 10 f0       	push   $0xf0104a71
f0100b5a:	68 a1 02 00 00       	push   $0x2a1
f0100b5f:	68 4b 4a 10 f0       	push   $0xf0104a4b
f0100b64:	e8 37 f5 ff ff       	call   f01000a0 <_panic>
	assert(nfree_extmem > 0);
f0100b69:	68 f0 4a 10 f0       	push   $0xf0104af0
f0100b6e:	68 71 4a 10 f0       	push   $0xf0104a71
f0100b73:	68 a2 02 00 00       	push   $0x2a2
f0100b78:	68 4b 4a 10 f0       	push   $0xf0104a4b
f0100b7d:	e8 1e f5 ff ff       	call   f01000a0 <_panic>
	if (!page_free_list)
f0100b82:	a1 3c 0d 1b f0       	mov    0xf01b0d3c,%eax
f0100b87:	85 c0                	test   %eax,%eax
f0100b89:	0f 84 ba fd ff ff    	je     f0100949 <check_page_free_list+0x27>
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f0100b8f:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0100b92:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0100b95:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100b98:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	return (pp - pages) << PGSHIFT;
f0100b9b:	89 c2                	mov    %eax,%edx
f0100b9d:	2b 15 10 1a 1b f0    	sub    0xf01b1a10,%edx
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0100ba3:	f7 c2 00 e0 7f 00    	test   $0x7fe000,%edx
f0100ba9:	0f 95 c2             	setne  %dl
f0100bac:	0f b6 d2             	movzbl %dl,%edx
			*tp[pagetype] = pp;
f0100baf:	8b 4c 95 e0          	mov    -0x20(%ebp,%edx,4),%ecx
f0100bb3:	89 01                	mov    %eax,(%ecx)
			tp[pagetype] = &pp->pp_link;
f0100bb5:	89 44 95 e0          	mov    %eax,-0x20(%ebp,%edx,4)
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100bb9:	8b 00                	mov    (%eax),%eax
f0100bbb:	85 c0                	test   %eax,%eax
f0100bbd:	75 dc                	jne    f0100b9b <check_page_free_list+0x279>
		*tp[1] = 0;
f0100bbf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100bc2:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0100bc8:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100bcb:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100bce:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0100bd0:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100bd3:	a3 3c 0d 1b f0       	mov    %eax,0xf01b0d3c
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100bd8:	be 01 00 00 00       	mov    $0x1,%esi
f0100bdd:	e9 5f fd ff ff       	jmp    f0100941 <check_page_free_list+0x1f>

f0100be2 <page_init>:
{
f0100be2:	55                   	push   %ebp
f0100be3:	89 e5                	mov    %esp,%ebp
f0100be5:	57                   	push   %edi
f0100be6:	56                   	push   %esi
f0100be7:	53                   	push   %ebx
f0100be8:	83 ec 0c             	sub    $0xc,%esp
	for (i = 0; i < npages; i++)
f0100beb:	bb 00 00 00 00       	mov    $0x0,%ebx
		int is_IO_hole = i >= npages_basemem && i <= npages_basemem + npages_IO ;
f0100bf0:	be 01 00 00 00       	mov    $0x1,%esi
	for (i = 0; i < npages; i++)
f0100bf5:	eb 65                	jmp    f0100c5c <page_init+0x7a>
		int is_IO_hole = i >= npages_basemem && i <= npages_basemem + npages_IO ;
f0100bf7:	b9 00 00 00 00       	mov    $0x0,%ecx
		int is_kernel_pgdir = (i >= npages_basemem + npages_IO && i <= npages_basemem + npages_IO + npages_kern);
f0100bfc:	8d 7a 60             	lea    0x60(%edx),%edi
f0100bff:	39 df                	cmp    %ebx,%edi
f0100c01:	76 3a                	jbe    f0100c3d <page_init+0x5b>
		if (i == 0 || is_IO_hole || is_kernel_pgdir) {
f0100c03:	85 db                	test   %ebx,%ebx
f0100c05:	74 48                	je     f0100c4f <page_init+0x6d>
f0100c07:	85 c9                	test   %ecx,%ecx
f0100c09:	75 44                	jne    f0100c4f <page_init+0x6d>
f0100c0b:	8d 04 dd 00 00 00 00 	lea    0x0(,%ebx,8),%eax
			pages[i].pp_ref = 0;
f0100c12:	89 c2                	mov    %eax,%edx
f0100c14:	03 15 10 1a 1b f0    	add    0xf01b1a10,%edx
f0100c1a:	66 c7 42 04 00 00    	movw   $0x0,0x4(%edx)
			pages[i].pp_link = page_free_list;
f0100c20:	8b 0d 3c 0d 1b f0    	mov    0xf01b0d3c,%ecx
f0100c26:	89 0a                	mov    %ecx,(%edx)
			page_free_list = &pages[i];
f0100c28:	03 05 10 1a 1b f0    	add    0xf01b1a10,%eax
f0100c2e:	a3 3c 0d 1b f0       	mov    %eax,0xf01b0d3c
f0100c33:	eb 26                	jmp    f0100c5b <page_init+0x79>
		int is_kernel_pgdir = (i >= npages_basemem + npages_IO && i <= npages_basemem + npages_IO + npages_kern);
f0100c35:	8d 7a 60             	lea    0x60(%edx),%edi
		int is_IO_hole = i >= npages_basemem && i <= npages_basemem + npages_IO ;
f0100c38:	b9 00 00 00 00       	mov    $0x0,%ecx
		int npages_kern = ((uint32_t)boot_alloc(0) - KERNBASE + PGSIZE - 1) / PGSIZE;
f0100c3d:	8d 90 ff 0f 00 10    	lea    0x10000fff(%eax),%edx
f0100c43:	89 d0                	mov    %edx,%eax
f0100c45:	c1 e8 0c             	shr    $0xc,%eax
		int is_kernel_pgdir = (i >= npages_basemem + npages_IO && i <= npages_basemem + npages_IO + npages_kern);
f0100c48:	8d 14 38             	lea    (%eax,%edi,1),%edx
f0100c4b:	39 da                	cmp    %ebx,%edx
f0100c4d:	72 b4                	jb     f0100c03 <page_init+0x21>
			pages[i].pp_ref = 1;
f0100c4f:	a1 10 1a 1b f0       	mov    0xf01b1a10,%eax
f0100c54:	66 c7 44 d8 04 01 00 	movw   $0x1,0x4(%eax,%ebx,8)
	for (i = 0; i < npages; i++)
f0100c5b:	43                   	inc    %ebx
f0100c5c:	39 1d 08 1a 1b f0    	cmp    %ebx,0xf01b1a08
f0100c62:	76 26                	jbe    f0100c8a <page_init+0xa8>
		int npages_kern = ((uint32_t)boot_alloc(0) - KERNBASE + PGSIZE - 1) / PGSIZE;
f0100c64:	b8 00 00 00 00       	mov    $0x0,%eax
f0100c69:	e8 f5 fb ff ff       	call   f0100863 <boot_alloc>
		int is_IO_hole = i >= npages_basemem && i <= npages_basemem + npages_IO ;
f0100c6e:	8b 15 40 0d 1b f0    	mov    0xf01b0d40,%edx
f0100c74:	39 da                	cmp    %ebx,%edx
f0100c76:	0f 87 7b ff ff ff    	ja     f0100bf7 <page_init+0x15>
f0100c7c:	8d 4a 60             	lea    0x60(%edx),%ecx
f0100c7f:	39 d9                	cmp    %ebx,%ecx
f0100c81:	72 b2                	jb     f0100c35 <page_init+0x53>
f0100c83:	89 f1                	mov    %esi,%ecx
f0100c85:	e9 72 ff ff ff       	jmp    f0100bfc <page_init+0x1a>
}
f0100c8a:	83 c4 0c             	add    $0xc,%esp
f0100c8d:	5b                   	pop    %ebx
f0100c8e:	5e                   	pop    %esi
f0100c8f:	5f                   	pop    %edi
f0100c90:	5d                   	pop    %ebp
f0100c91:	c3                   	ret    

f0100c92 <page_alloc>:
{
f0100c92:	55                   	push   %ebp
f0100c93:	89 e5                	mov    %esp,%ebp
f0100c95:	53                   	push   %ebx
f0100c96:	83 ec 04             	sub    $0x4,%esp
	new_page = page_free_list;
f0100c99:	8b 1d 3c 0d 1b f0    	mov    0xf01b0d3c,%ebx
	if (new_page == NULL) {
f0100c9f:	85 db                	test   %ebx,%ebx
f0100ca1:	74 13                	je     f0100cb6 <page_alloc+0x24>
	page_free_list = new_page->pp_link;
f0100ca3:	8b 03                	mov    (%ebx),%eax
f0100ca5:	a3 3c 0d 1b f0       	mov    %eax,0xf01b0d3c
	new_page->pp_link = NULL;
f0100caa:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	if(alloc_flags && ALLOC_ZERO)
f0100cb0:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f0100cb4:	75 07                	jne    f0100cbd <page_alloc+0x2b>
}
f0100cb6:	89 d8                	mov    %ebx,%eax
f0100cb8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100cbb:	c9                   	leave  
f0100cbc:	c3                   	ret    
f0100cbd:	89 d8                	mov    %ebx,%eax
f0100cbf:	2b 05 10 1a 1b f0    	sub    0xf01b1a10,%eax
f0100cc5:	c1 f8 03             	sar    $0x3,%eax
f0100cc8:	89 c2                	mov    %eax,%edx
f0100cca:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0100ccd:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0100cd2:	3b 05 08 1a 1b f0    	cmp    0xf01b1a08,%eax
f0100cd8:	73 1b                	jae    f0100cf5 <page_alloc+0x63>
		memset(page2kva(new_page), '\0', PGSIZE);
f0100cda:	83 ec 04             	sub    $0x4,%esp
f0100cdd:	68 00 10 00 00       	push   $0x1000
f0100ce2:	6a 00                	push   $0x0
	return (void *)(pa + KERNBASE);
f0100ce4:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f0100cea:	52                   	push   %edx
f0100ceb:	e8 91 34 00 00       	call   f0104181 <memset>
f0100cf0:	83 c4 10             	add    $0x10,%esp
f0100cf3:	eb c1                	jmp    f0100cb6 <page_alloc+0x24>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100cf5:	52                   	push   %edx
f0100cf6:	68 48 4d 10 f0       	push   $0xf0104d48
f0100cfb:	6a 56                	push   $0x56
f0100cfd:	68 57 4a 10 f0       	push   $0xf0104a57
f0100d02:	e8 99 f3 ff ff       	call   f01000a0 <_panic>

f0100d07 <page_free>:
{
f0100d07:	55                   	push   %ebp
f0100d08:	89 e5                	mov    %esp,%ebp
f0100d0a:	83 ec 08             	sub    $0x8,%esp
f0100d0d:	8b 45 08             	mov    0x8(%ebp),%eax
	if (pp->pp_ref != 0 || pp->pp_link != NULL) {
f0100d10:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0100d15:	75 14                	jne    f0100d2b <page_free+0x24>
f0100d17:	83 38 00             	cmpl   $0x0,(%eax)
f0100d1a:	75 0f                	jne    f0100d2b <page_free+0x24>
	pp->pp_link = page_free_list;
f0100d1c:	8b 15 3c 0d 1b f0    	mov    0xf01b0d3c,%edx
f0100d22:	89 10                	mov    %edx,(%eax)
	page_free_list = pp;
f0100d24:	a3 3c 0d 1b f0       	mov    %eax,0xf01b0d3c
}
f0100d29:	c9                   	leave  
f0100d2a:	c3                   	ret    
		panic("Cannot free this page!");
f0100d2b:	83 ec 04             	sub    $0x4,%esp
f0100d2e:	68 01 4b 10 f0       	push   $0xf0104b01
f0100d33:	68 68 01 00 00       	push   $0x168
f0100d38:	68 4b 4a 10 f0       	push   $0xf0104a4b
f0100d3d:	e8 5e f3 ff ff       	call   f01000a0 <_panic>

f0100d42 <page_decref>:
{
f0100d42:	55                   	push   %ebp
f0100d43:	89 e5                	mov    %esp,%ebp
f0100d45:	83 ec 08             	sub    $0x8,%esp
f0100d48:	8b 55 08             	mov    0x8(%ebp),%edx
	if (--pp->pp_ref == 0)
f0100d4b:	8b 42 04             	mov    0x4(%edx),%eax
f0100d4e:	48                   	dec    %eax
f0100d4f:	66 89 42 04          	mov    %ax,0x4(%edx)
f0100d53:	66 85 c0             	test   %ax,%ax
f0100d56:	74 02                	je     f0100d5a <page_decref+0x18>
}
f0100d58:	c9                   	leave  
f0100d59:	c3                   	ret    
		page_free(pp);
f0100d5a:	83 ec 0c             	sub    $0xc,%esp
f0100d5d:	52                   	push   %edx
f0100d5e:	e8 a4 ff ff ff       	call   f0100d07 <page_free>
f0100d63:	83 c4 10             	add    $0x10,%esp
}
f0100d66:	eb f0                	jmp    f0100d58 <page_decref+0x16>

f0100d68 <pgdir_walk>:
{
f0100d68:	55                   	push   %ebp
f0100d69:	89 e5                	mov    %esp,%ebp
f0100d6b:	53                   	push   %ebx
f0100d6c:	83 ec 04             	sub    $0x4,%esp
	pde_t *pg_dir_entry = (pde_t *)(pgdir + (unsigned int)PDX(va));
f0100d6f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0100d72:	c1 eb 16             	shr    $0x16,%ebx
f0100d75:	c1 e3 02             	shl    $0x2,%ebx
f0100d78:	03 5d 08             	add    0x8(%ebp),%ebx
	if(!(*pg_dir_entry) & PTE_P) {
f0100d7b:	83 3b 00             	cmpl   $0x0,(%ebx)
f0100d7e:	75 2c                	jne    f0100dac <pgdir_walk+0x44>
		if (create == false)
f0100d80:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0100d84:	74 67                	je     f0100ded <pgdir_walk+0x85>
		new_page = page_alloc(1);
f0100d86:	83 ec 0c             	sub    $0xc,%esp
f0100d89:	6a 01                	push   $0x1
f0100d8b:	e8 02 ff ff ff       	call   f0100c92 <page_alloc>
		if(new_page == NULL)
f0100d90:	83 c4 10             	add    $0x10,%esp
f0100d93:	85 c0                	test   %eax,%eax
f0100d95:	74 3c                	je     f0100dd3 <pgdir_walk+0x6b>
		new_page->pp_ref ++;
f0100d97:	66 ff 40 04          	incw   0x4(%eax)
	return (pp - pages) << PGSHIFT;
f0100d9b:	2b 05 10 1a 1b f0    	sub    0xf01b1a10,%eax
f0100da1:	c1 f8 03             	sar    $0x3,%eax
f0100da4:	c1 e0 0c             	shl    $0xc,%eax
		*pg_dir_entry = ((page2pa(new_page)) | PTE_P | PTE_W | PTE_U);
f0100da7:	83 c8 07             	or     $0x7,%eax
f0100daa:	89 03                	mov    %eax,(%ebx)
	offset = PTX(va);
f0100dac:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100daf:	c1 e8 0c             	shr    $0xc,%eax
f0100db2:	25 ff 03 00 00       	and    $0x3ff,%eax
	page_base = KADDR(PTE_ADDR(*pg_dir_entry));
f0100db7:	8b 13                	mov    (%ebx),%edx
f0100db9:	89 d1                	mov    %edx,%ecx
f0100dbb:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
	if (PGNUM(pa) >= npages)
f0100dc1:	c1 ea 0c             	shr    $0xc,%edx
f0100dc4:	3b 15 08 1a 1b f0    	cmp    0xf01b1a08,%edx
f0100dca:	73 0c                	jae    f0100dd8 <pgdir_walk+0x70>
	return &page_base[offset];
f0100dcc:	8d 84 81 00 00 00 f0 	lea    -0x10000000(%ecx,%eax,4),%eax
}
f0100dd3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100dd6:	c9                   	leave  
f0100dd7:	c3                   	ret    
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100dd8:	51                   	push   %ecx
f0100dd9:	68 48 4d 10 f0       	push   $0xf0104d48
f0100dde:	68 a7 01 00 00       	push   $0x1a7
f0100de3:	68 4b 4a 10 f0       	push   $0xf0104a4b
f0100de8:	e8 b3 f2 ff ff       	call   f01000a0 <_panic>
			return NULL;
f0100ded:	b8 00 00 00 00       	mov    $0x0,%eax
f0100df2:	eb df                	jmp    f0100dd3 <pgdir_walk+0x6b>

f0100df4 <boot_map_region>:
{
f0100df4:	55                   	push   %ebp
f0100df5:	89 e5                	mov    %esp,%ebp
f0100df7:	57                   	push   %edi
f0100df8:	56                   	push   %esi
f0100df9:	53                   	push   %ebx
f0100dfa:	83 ec 1c             	sub    $0x1c,%esp
f0100dfd:	89 c7                	mov    %eax,%edi
	int num_pages = size / PGSIZE;
f0100dff:	c1 e9 0c             	shr    $0xc,%ecx
f0100e02:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
	for(int i = 0; i < num_pages; ++i) {
f0100e05:	89 d3                	mov    %edx,%ebx
f0100e07:	be 00 00 00 00       	mov    $0x0,%esi
		*pt_entry = (pa + i * PGSIZE) | PTE_P | perm;
f0100e0c:	8b 45 08             	mov    0x8(%ebp),%eax
f0100e0f:	29 d0                	sub    %edx,%eax
f0100e11:	89 45 e0             	mov    %eax,-0x20(%ebp)
	for(int i = 0; i < num_pages; ++i) {
f0100e14:	3b 75 e4             	cmp    -0x1c(%ebp),%esi
f0100e17:	7d 27                	jge    f0100e40 <boot_map_region+0x4c>
		pt_entry = pgdir_walk(pgdir, (void *)(va + i * PGSIZE), 1);
f0100e19:	83 ec 04             	sub    $0x4,%esp
f0100e1c:	6a 01                	push   $0x1
f0100e1e:	53                   	push   %ebx
f0100e1f:	57                   	push   %edi
f0100e20:	e8 43 ff ff ff       	call   f0100d68 <pgdir_walk>
f0100e25:	89 c2                	mov    %eax,%edx
		*pt_entry = (pa + i * PGSIZE) | PTE_P | perm;
f0100e27:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100e2a:	01 d8                	add    %ebx,%eax
f0100e2c:	0b 45 0c             	or     0xc(%ebp),%eax
f0100e2f:	83 c8 01             	or     $0x1,%eax
f0100e32:	89 02                	mov    %eax,(%edx)
	for(int i = 0; i < num_pages; ++i) {
f0100e34:	46                   	inc    %esi
f0100e35:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0100e3b:	83 c4 10             	add    $0x10,%esp
f0100e3e:	eb d4                	jmp    f0100e14 <boot_map_region+0x20>
}
f0100e40:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100e43:	5b                   	pop    %ebx
f0100e44:	5e                   	pop    %esi
f0100e45:	5f                   	pop    %edi
f0100e46:	5d                   	pop    %ebp
f0100e47:	c3                   	ret    

f0100e48 <page_lookup>:
{
f0100e48:	55                   	push   %ebp
f0100e49:	89 e5                	mov    %esp,%ebp
f0100e4b:	53                   	push   %ebx
f0100e4c:	83 ec 08             	sub    $0x8,%esp
f0100e4f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	pte_t *pt_entry = pgdir_walk(pgdir, va, false);
f0100e52:	6a 00                	push   $0x0
f0100e54:	ff 75 0c             	pushl  0xc(%ebp)
f0100e57:	ff 75 08             	pushl  0x8(%ebp)
f0100e5a:	e8 09 ff ff ff       	call   f0100d68 <pgdir_walk>
	if(pt_entry == NULL)
f0100e5f:	83 c4 10             	add    $0x10,%esp
f0100e62:	85 c0                	test   %eax,%eax
f0100e64:	74 21                	je     f0100e87 <page_lookup+0x3f>
	if(!(*pt_entry & PTE_P))
f0100e66:	f6 00 01             	testb  $0x1,(%eax)
f0100e69:	74 35                	je     f0100ea0 <page_lookup+0x58>
	if(pte_store != NULL)
f0100e6b:	85 db                	test   %ebx,%ebx
f0100e6d:	74 02                	je     f0100e71 <page_lookup+0x29>
		*pte_store = pt_entry;
f0100e6f:	89 03                	mov    %eax,(%ebx)
f0100e71:	8b 00                	mov    (%eax),%eax
f0100e73:	c1 e8 0c             	shr    $0xc,%eax
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100e76:	39 05 08 1a 1b f0    	cmp    %eax,0xf01b1a08
f0100e7c:	76 0e                	jbe    f0100e8c <page_lookup+0x44>
		panic("pa2page called with invalid pa");
	return &pages[PGNUM(pa)];
f0100e7e:	8b 15 10 1a 1b f0    	mov    0xf01b1a10,%edx
f0100e84:	8d 04 c2             	lea    (%edx,%eax,8),%eax
}
f0100e87:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100e8a:	c9                   	leave  
f0100e8b:	c3                   	ret    
		panic("pa2page called with invalid pa");
f0100e8c:	83 ec 04             	sub    $0x4,%esp
f0100e8f:	68 54 4e 10 f0       	push   $0xf0104e54
f0100e94:	6a 4f                	push   $0x4f
f0100e96:	68 57 4a 10 f0       	push   $0xf0104a57
f0100e9b:	e8 00 f2 ff ff       	call   f01000a0 <_panic>
		return NULL;
f0100ea0:	b8 00 00 00 00       	mov    $0x0,%eax
f0100ea5:	eb e0                	jmp    f0100e87 <page_lookup+0x3f>

f0100ea7 <page_remove>:
{
f0100ea7:	55                   	push   %ebp
f0100ea8:	89 e5                	mov    %esp,%ebp
f0100eaa:	53                   	push   %ebx
f0100eab:	83 ec 18             	sub    $0x18,%esp
f0100eae:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct PageInfo *page = page_lookup(pgdir, va, &pte_store);
f0100eb1:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0100eb4:	50                   	push   %eax
f0100eb5:	53                   	push   %ebx
f0100eb6:	ff 75 08             	pushl  0x8(%ebp)
f0100eb9:	e8 8a ff ff ff       	call   f0100e48 <page_lookup>
	if(page == NULL)
f0100ebe:	83 c4 10             	add    $0x10,%esp
f0100ec1:	85 c0                	test   %eax,%eax
f0100ec3:	74 18                	je     f0100edd <page_remove+0x36>
	page_decref(page);
f0100ec5:	83 ec 0c             	sub    $0xc,%esp
f0100ec8:	50                   	push   %eax
f0100ec9:	e8 74 fe ff ff       	call   f0100d42 <page_decref>
}

static inline void
invlpg(void *addr)
{
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0100ece:	0f 01 3b             	invlpg (%ebx)
	*pte_store = 0;
f0100ed1:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0100ed4:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
f0100eda:	83 c4 10             	add    $0x10,%esp
}
f0100edd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100ee0:	c9                   	leave  
f0100ee1:	c3                   	ret    

f0100ee2 <page_insert>:
{
f0100ee2:	55                   	push   %ebp
f0100ee3:	89 e5                	mov    %esp,%ebp
f0100ee5:	57                   	push   %edi
f0100ee6:	56                   	push   %esi
f0100ee7:	53                   	push   %ebx
f0100ee8:	83 ec 10             	sub    $0x10,%esp
f0100eeb:	8b 7d 08             	mov    0x8(%ebp),%edi
f0100eee:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	pte_t *pt_entry = pgdir_walk(pgdir, (void *)va, 1);
f0100ef1:	6a 01                	push   $0x1
f0100ef3:	ff 75 10             	pushl  0x10(%ebp)
f0100ef6:	57                   	push   %edi
f0100ef7:	e8 6c fe ff ff       	call   f0100d68 <pgdir_walk>
	if (pt_entry == NULL) {
f0100efc:	83 c4 10             	add    $0x10,%esp
f0100eff:	85 c0                	test   %eax,%eax
f0100f01:	74 56                	je     f0100f59 <page_insert+0x77>
f0100f03:	89 c6                	mov    %eax,%esi
	pp->pp_ref++;
f0100f05:	66 ff 43 04          	incw   0x4(%ebx)
	if (*pt_entry & PTE_P)
f0100f09:	f6 00 01             	testb  $0x1,(%eax)
f0100f0c:	75 34                	jne    f0100f42 <page_insert+0x60>
	return (pp - pages) << PGSHIFT;
f0100f0e:	2b 1d 10 1a 1b f0    	sub    0xf01b1a10,%ebx
f0100f14:	c1 fb 03             	sar    $0x3,%ebx
f0100f17:	c1 e3 0c             	shl    $0xc,%ebx
	*pt_entry = page2pa(pp) | perm | PTE_P;
f0100f1a:	0b 5d 14             	or     0x14(%ebp),%ebx
f0100f1d:	83 cb 01             	or     $0x1,%ebx
f0100f20:	89 1e                	mov    %ebx,(%esi)
	pgdir[PDX(va)] |= perm | PTE_P;
f0100f22:	8b 45 10             	mov    0x10(%ebp),%eax
f0100f25:	c1 e8 16             	shr    $0x16,%eax
f0100f28:	8d 14 87             	lea    (%edi,%eax,4),%edx
f0100f2b:	8b 45 14             	mov    0x14(%ebp),%eax
f0100f2e:	0b 02                	or     (%edx),%eax
f0100f30:	83 c8 01             	or     $0x1,%eax
f0100f33:	89 02                	mov    %eax,(%edx)
	return 0;
f0100f35:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100f3a:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100f3d:	5b                   	pop    %ebx
f0100f3e:	5e                   	pop    %esi
f0100f3f:	5f                   	pop    %edi
f0100f40:	5d                   	pop    %ebp
f0100f41:	c3                   	ret    
f0100f42:	8b 45 10             	mov    0x10(%ebp),%eax
f0100f45:	0f 01 38             	invlpg (%eax)
		page_remove(pgdir, va);
f0100f48:	83 ec 08             	sub    $0x8,%esp
f0100f4b:	ff 75 10             	pushl  0x10(%ebp)
f0100f4e:	57                   	push   %edi
f0100f4f:	e8 53 ff ff ff       	call   f0100ea7 <page_remove>
f0100f54:	83 c4 10             	add    $0x10,%esp
f0100f57:	eb b5                	jmp    f0100f0e <page_insert+0x2c>
		return -E_NO_MEM;
f0100f59:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f0100f5e:	eb da                	jmp    f0100f3a <page_insert+0x58>

f0100f60 <mem_init>:
{
f0100f60:	55                   	push   %ebp
f0100f61:	89 e5                	mov    %esp,%ebp
f0100f63:	57                   	push   %edi
f0100f64:	56                   	push   %esi
f0100f65:	53                   	push   %ebx
f0100f66:	83 ec 3c             	sub    $0x3c,%esp
	basemem = nvram_read(NVRAM_BASELO);
f0100f69:	b8 15 00 00 00       	mov    $0x15,%eax
f0100f6e:	e8 c9 f8 ff ff       	call   f010083c <nvram_read>
f0100f73:	89 c3                	mov    %eax,%ebx
	extmem = nvram_read(NVRAM_EXTLO);
f0100f75:	b8 17 00 00 00       	mov    $0x17,%eax
f0100f7a:	e8 bd f8 ff ff       	call   f010083c <nvram_read>
f0100f7f:	89 c6                	mov    %eax,%esi
	ext16mem = nvram_read(NVRAM_EXT16LO) * 64;
f0100f81:	b8 34 00 00 00       	mov    $0x34,%eax
f0100f86:	e8 b1 f8 ff ff       	call   f010083c <nvram_read>
	if (ext16mem)
f0100f8b:	c1 e0 06             	shl    $0x6,%eax
f0100f8e:	0f 84 d9 00 00 00    	je     f010106d <mem_init+0x10d>
		totalmem = 16 * 1024 + ext16mem;
f0100f94:	05 00 40 00 00       	add    $0x4000,%eax
	npages = totalmem / (PGSIZE / 1024);
f0100f99:	89 c2                	mov    %eax,%edx
f0100f9b:	c1 ea 02             	shr    $0x2,%edx
f0100f9e:	89 15 08 1a 1b f0    	mov    %edx,0xf01b1a08
	npages_basemem = basemem / (PGSIZE / 1024);
f0100fa4:	89 da                	mov    %ebx,%edx
f0100fa6:	c1 ea 02             	shr    $0x2,%edx
f0100fa9:	89 15 40 0d 1b f0    	mov    %edx,0xf01b0d40
	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0100faf:	89 c2                	mov    %eax,%edx
f0100fb1:	29 da                	sub    %ebx,%edx
f0100fb3:	52                   	push   %edx
f0100fb4:	53                   	push   %ebx
f0100fb5:	50                   	push   %eax
f0100fb6:	68 74 4e 10 f0       	push   $0xf0104e74
f0100fbb:	e8 95 1f 00 00       	call   f0102f55 <cprintf>
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f0100fc0:	b8 00 10 00 00       	mov    $0x1000,%eax
f0100fc5:	e8 99 f8 ff ff       	call   f0100863 <boot_alloc>
f0100fca:	a3 0c 1a 1b f0       	mov    %eax,0xf01b1a0c
	memset(kern_pgdir, 0, PGSIZE);
f0100fcf:	83 c4 0c             	add    $0xc,%esp
f0100fd2:	68 00 10 00 00       	push   $0x1000
f0100fd7:	6a 00                	push   $0x0
f0100fd9:	50                   	push   %eax
f0100fda:	e8 a2 31 00 00       	call   f0104181 <memset>
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f0100fdf:	a1 0c 1a 1b f0       	mov    0xf01b1a0c,%eax
	if ((uint32_t)kva < KERNBASE)
f0100fe4:	83 c4 10             	add    $0x10,%esp
f0100fe7:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0100fec:	0f 86 91 00 00 00    	jbe    f0101083 <mem_init+0x123>
	return (physaddr_t)kva - KERNBASE;
f0100ff2:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0100ff8:	83 ca 05             	or     $0x5,%edx
f0100ffb:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	pages = boot_alloc(npages * sizeof(struct PageInfo));
f0101001:	a1 08 1a 1b f0       	mov    0xf01b1a08,%eax
f0101006:	c1 e0 03             	shl    $0x3,%eax
f0101009:	e8 55 f8 ff ff       	call   f0100863 <boot_alloc>
f010100e:	a3 10 1a 1b f0       	mov    %eax,0xf01b1a10
	memset(pages, 0, npages * sizeof(struct PageInfo));
f0101013:	83 ec 04             	sub    $0x4,%esp
f0101016:	8b 0d 08 1a 1b f0    	mov    0xf01b1a08,%ecx
f010101c:	8d 14 cd 00 00 00 00 	lea    0x0(,%ecx,8),%edx
f0101023:	52                   	push   %edx
f0101024:	6a 00                	push   $0x0
f0101026:	50                   	push   %eax
f0101027:	e8 55 31 00 00       	call   f0104181 <memset>
	envs = boot_alloc(NENV * sizeof(struct Env));
f010102c:	b8 00 80 01 00       	mov    $0x18000,%eax
f0101031:	e8 2d f8 ff ff       	call   f0100863 <boot_alloc>
f0101036:	a3 48 0d 1b f0       	mov    %eax,0xf01b0d48
	page_init();
f010103b:	e8 a2 fb ff ff       	call   f0100be2 <page_init>
	check_page_free_list(1);
f0101040:	b8 01 00 00 00       	mov    $0x1,%eax
f0101045:	e8 d8 f8 ff ff       	call   f0100922 <check_page_free_list>
	if (!pages)
f010104a:	83 c4 10             	add    $0x10,%esp
f010104d:	83 3d 10 1a 1b f0 00 	cmpl   $0x0,0xf01b1a10
f0101054:	74 42                	je     f0101098 <mem_init+0x138>
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101056:	a1 3c 0d 1b f0       	mov    0xf01b0d3c,%eax
f010105b:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
f0101062:	85 c0                	test   %eax,%eax
f0101064:	74 49                	je     f01010af <mem_init+0x14f>
		++nfree;
f0101066:	ff 45 d4             	incl   -0x2c(%ebp)
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101069:	8b 00                	mov    (%eax),%eax
f010106b:	eb f5                	jmp    f0101062 <mem_init+0x102>
	else if (extmem)
f010106d:	85 f6                	test   %esi,%esi
f010106f:	74 0b                	je     f010107c <mem_init+0x11c>
		totalmem = 1 * 1024 + extmem;
f0101071:	8d 86 00 04 00 00    	lea    0x400(%esi),%eax
f0101077:	e9 1d ff ff ff       	jmp    f0100f99 <mem_init+0x39>
		totalmem = basemem;
f010107c:	89 d8                	mov    %ebx,%eax
f010107e:	e9 16 ff ff ff       	jmp    f0100f99 <mem_init+0x39>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0101083:	50                   	push   %eax
f0101084:	68 b0 4e 10 f0       	push   $0xf0104eb0
f0101089:	68 97 00 00 00       	push   $0x97
f010108e:	68 4b 4a 10 f0       	push   $0xf0104a4b
f0101093:	e8 08 f0 ff ff       	call   f01000a0 <_panic>
		panic("'pages' is a null pointer!");
f0101098:	83 ec 04             	sub    $0x4,%esp
f010109b:	68 18 4b 10 f0       	push   $0xf0104b18
f01010a0:	68 b5 02 00 00       	push   $0x2b5
f01010a5:	68 4b 4a 10 f0       	push   $0xf0104a4b
f01010aa:	e8 f1 ef ff ff       	call   f01000a0 <_panic>
	assert((pp0 = page_alloc(0)));
f01010af:	83 ec 0c             	sub    $0xc,%esp
f01010b2:	6a 00                	push   $0x0
f01010b4:	e8 d9 fb ff ff       	call   f0100c92 <page_alloc>
f01010b9:	89 c3                	mov    %eax,%ebx
f01010bb:	83 c4 10             	add    $0x10,%esp
f01010be:	85 c0                	test   %eax,%eax
f01010c0:	0f 84 0e 02 00 00    	je     f01012d4 <mem_init+0x374>
	assert((pp1 = page_alloc(0)));
f01010c6:	83 ec 0c             	sub    $0xc,%esp
f01010c9:	6a 00                	push   $0x0
f01010cb:	e8 c2 fb ff ff       	call   f0100c92 <page_alloc>
f01010d0:	89 c6                	mov    %eax,%esi
f01010d2:	83 c4 10             	add    $0x10,%esp
f01010d5:	85 c0                	test   %eax,%eax
f01010d7:	0f 84 10 02 00 00    	je     f01012ed <mem_init+0x38d>
	assert((pp2 = page_alloc(0)));
f01010dd:	83 ec 0c             	sub    $0xc,%esp
f01010e0:	6a 00                	push   $0x0
f01010e2:	e8 ab fb ff ff       	call   f0100c92 <page_alloc>
f01010e7:	89 c7                	mov    %eax,%edi
f01010e9:	83 c4 10             	add    $0x10,%esp
f01010ec:	85 c0                	test   %eax,%eax
f01010ee:	0f 84 12 02 00 00    	je     f0101306 <mem_init+0x3a6>
	assert(pp1 && pp1 != pp0);
f01010f4:	39 f3                	cmp    %esi,%ebx
f01010f6:	0f 84 23 02 00 00    	je     f010131f <mem_init+0x3bf>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01010fc:	39 c6                	cmp    %eax,%esi
f01010fe:	0f 84 34 02 00 00    	je     f0101338 <mem_init+0x3d8>
f0101104:	39 c3                	cmp    %eax,%ebx
f0101106:	0f 84 2c 02 00 00    	je     f0101338 <mem_init+0x3d8>
	return (pp - pages) << PGSHIFT;
f010110c:	8b 0d 10 1a 1b f0    	mov    0xf01b1a10,%ecx
	assert(page2pa(pp0) < npages*PGSIZE);
f0101112:	8b 15 08 1a 1b f0    	mov    0xf01b1a08,%edx
f0101118:	c1 e2 0c             	shl    $0xc,%edx
f010111b:	89 d8                	mov    %ebx,%eax
f010111d:	29 c8                	sub    %ecx,%eax
f010111f:	c1 f8 03             	sar    $0x3,%eax
f0101122:	c1 e0 0c             	shl    $0xc,%eax
f0101125:	39 d0                	cmp    %edx,%eax
f0101127:	0f 83 24 02 00 00    	jae    f0101351 <mem_init+0x3f1>
f010112d:	89 f0                	mov    %esi,%eax
f010112f:	29 c8                	sub    %ecx,%eax
f0101131:	c1 f8 03             	sar    $0x3,%eax
f0101134:	c1 e0 0c             	shl    $0xc,%eax
	assert(page2pa(pp1) < npages*PGSIZE);
f0101137:	39 c2                	cmp    %eax,%edx
f0101139:	0f 86 2b 02 00 00    	jbe    f010136a <mem_init+0x40a>
f010113f:	89 f8                	mov    %edi,%eax
f0101141:	29 c8                	sub    %ecx,%eax
f0101143:	c1 f8 03             	sar    $0x3,%eax
f0101146:	c1 e0 0c             	shl    $0xc,%eax
	assert(page2pa(pp2) < npages*PGSIZE);
f0101149:	39 c2                	cmp    %eax,%edx
f010114b:	0f 86 32 02 00 00    	jbe    f0101383 <mem_init+0x423>
	fl = page_free_list;
f0101151:	a1 3c 0d 1b f0       	mov    0xf01b0d3c,%eax
f0101156:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f0101159:	c7 05 3c 0d 1b f0 00 	movl   $0x0,0xf01b0d3c
f0101160:	00 00 00 
	assert(!page_alloc(0));
f0101163:	83 ec 0c             	sub    $0xc,%esp
f0101166:	6a 00                	push   $0x0
f0101168:	e8 25 fb ff ff       	call   f0100c92 <page_alloc>
f010116d:	83 c4 10             	add    $0x10,%esp
f0101170:	85 c0                	test   %eax,%eax
f0101172:	0f 85 24 02 00 00    	jne    f010139c <mem_init+0x43c>
	page_free(pp0);
f0101178:	83 ec 0c             	sub    $0xc,%esp
f010117b:	53                   	push   %ebx
f010117c:	e8 86 fb ff ff       	call   f0100d07 <page_free>
	page_free(pp1);
f0101181:	89 34 24             	mov    %esi,(%esp)
f0101184:	e8 7e fb ff ff       	call   f0100d07 <page_free>
	page_free(pp2);
f0101189:	89 3c 24             	mov    %edi,(%esp)
f010118c:	e8 76 fb ff ff       	call   f0100d07 <page_free>
	assert((pp0 = page_alloc(0)));
f0101191:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101198:	e8 f5 fa ff ff       	call   f0100c92 <page_alloc>
f010119d:	89 c3                	mov    %eax,%ebx
f010119f:	83 c4 10             	add    $0x10,%esp
f01011a2:	85 c0                	test   %eax,%eax
f01011a4:	0f 84 0b 02 00 00    	je     f01013b5 <mem_init+0x455>
	assert((pp1 = page_alloc(0)));
f01011aa:	83 ec 0c             	sub    $0xc,%esp
f01011ad:	6a 00                	push   $0x0
f01011af:	e8 de fa ff ff       	call   f0100c92 <page_alloc>
f01011b4:	89 c6                	mov    %eax,%esi
f01011b6:	83 c4 10             	add    $0x10,%esp
f01011b9:	85 c0                	test   %eax,%eax
f01011bb:	0f 84 0d 02 00 00    	je     f01013ce <mem_init+0x46e>
	assert((pp2 = page_alloc(0)));
f01011c1:	83 ec 0c             	sub    $0xc,%esp
f01011c4:	6a 00                	push   $0x0
f01011c6:	e8 c7 fa ff ff       	call   f0100c92 <page_alloc>
f01011cb:	89 c7                	mov    %eax,%edi
f01011cd:	83 c4 10             	add    $0x10,%esp
f01011d0:	85 c0                	test   %eax,%eax
f01011d2:	0f 84 0f 02 00 00    	je     f01013e7 <mem_init+0x487>
	assert(pp1 && pp1 != pp0);
f01011d8:	39 f3                	cmp    %esi,%ebx
f01011da:	0f 84 20 02 00 00    	je     f0101400 <mem_init+0x4a0>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01011e0:	39 c6                	cmp    %eax,%esi
f01011e2:	0f 84 31 02 00 00    	je     f0101419 <mem_init+0x4b9>
f01011e8:	39 c3                	cmp    %eax,%ebx
f01011ea:	0f 84 29 02 00 00    	je     f0101419 <mem_init+0x4b9>
	assert(!page_alloc(0));
f01011f0:	83 ec 0c             	sub    $0xc,%esp
f01011f3:	6a 00                	push   $0x0
f01011f5:	e8 98 fa ff ff       	call   f0100c92 <page_alloc>
f01011fa:	83 c4 10             	add    $0x10,%esp
f01011fd:	85 c0                	test   %eax,%eax
f01011ff:	0f 85 2d 02 00 00    	jne    f0101432 <mem_init+0x4d2>
f0101205:	89 d8                	mov    %ebx,%eax
f0101207:	2b 05 10 1a 1b f0    	sub    0xf01b1a10,%eax
f010120d:	c1 f8 03             	sar    $0x3,%eax
f0101210:	89 c2                	mov    %eax,%edx
f0101212:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0101215:	25 ff ff 0f 00       	and    $0xfffff,%eax
f010121a:	3b 05 08 1a 1b f0    	cmp    0xf01b1a08,%eax
f0101220:	0f 83 25 02 00 00    	jae    f010144b <mem_init+0x4eb>
	memset(page2kva(pp0), 1, PGSIZE);
f0101226:	83 ec 04             	sub    $0x4,%esp
f0101229:	68 00 10 00 00       	push   $0x1000
f010122e:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f0101230:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f0101236:	52                   	push   %edx
f0101237:	e8 45 2f 00 00       	call   f0104181 <memset>
	page_free(pp0);
f010123c:	89 1c 24             	mov    %ebx,(%esp)
f010123f:	e8 c3 fa ff ff       	call   f0100d07 <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0101244:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f010124b:	e8 42 fa ff ff       	call   f0100c92 <page_alloc>
f0101250:	83 c4 10             	add    $0x10,%esp
f0101253:	85 c0                	test   %eax,%eax
f0101255:	0f 84 02 02 00 00    	je     f010145d <mem_init+0x4fd>
	assert(pp && pp0 == pp);
f010125b:	39 c3                	cmp    %eax,%ebx
f010125d:	0f 85 13 02 00 00    	jne    f0101476 <mem_init+0x516>
	return (pp - pages) << PGSHIFT;
f0101263:	2b 05 10 1a 1b f0    	sub    0xf01b1a10,%eax
f0101269:	c1 f8 03             	sar    $0x3,%eax
f010126c:	89 c2                	mov    %eax,%edx
f010126e:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0101271:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0101276:	3b 05 08 1a 1b f0    	cmp    0xf01b1a08,%eax
f010127c:	0f 83 0d 02 00 00    	jae    f010148f <mem_init+0x52f>
	return (void *)(pa + KERNBASE);
f0101282:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
f0101288:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
		assert(c[i] == 0);
f010128e:	80 38 00             	cmpb   $0x0,(%eax)
f0101291:	0f 85 0a 02 00 00    	jne    f01014a1 <mem_init+0x541>
f0101297:	40                   	inc    %eax
	for (i = 0; i < PGSIZE; i++)
f0101298:	39 d0                	cmp    %edx,%eax
f010129a:	75 f2                	jne    f010128e <mem_init+0x32e>
	page_free_list = fl;
f010129c:	8b 45 d0             	mov    -0x30(%ebp),%eax
f010129f:	a3 3c 0d 1b f0       	mov    %eax,0xf01b0d3c
	page_free(pp0);
f01012a4:	83 ec 0c             	sub    $0xc,%esp
f01012a7:	53                   	push   %ebx
f01012a8:	e8 5a fa ff ff       	call   f0100d07 <page_free>
	page_free(pp1);
f01012ad:	89 34 24             	mov    %esi,(%esp)
f01012b0:	e8 52 fa ff ff       	call   f0100d07 <page_free>
	page_free(pp2);
f01012b5:	89 3c 24             	mov    %edi,(%esp)
f01012b8:	e8 4a fa ff ff       	call   f0100d07 <page_free>
	for (pp = page_free_list; pp; pp = pp->pp_link)
f01012bd:	a1 3c 0d 1b f0       	mov    0xf01b0d3c,%eax
f01012c2:	83 c4 10             	add    $0x10,%esp
f01012c5:	85 c0                	test   %eax,%eax
f01012c7:	0f 84 ed 01 00 00    	je     f01014ba <mem_init+0x55a>
		--nfree;
f01012cd:	ff 4d d4             	decl   -0x2c(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link)
f01012d0:	8b 00                	mov    (%eax),%eax
f01012d2:	eb f1                	jmp    f01012c5 <mem_init+0x365>
	assert((pp0 = page_alloc(0)));
f01012d4:	68 33 4b 10 f0       	push   $0xf0104b33
f01012d9:	68 71 4a 10 f0       	push   $0xf0104a71
f01012de:	68 bd 02 00 00       	push   $0x2bd
f01012e3:	68 4b 4a 10 f0       	push   $0xf0104a4b
f01012e8:	e8 b3 ed ff ff       	call   f01000a0 <_panic>
	assert((pp1 = page_alloc(0)));
f01012ed:	68 49 4b 10 f0       	push   $0xf0104b49
f01012f2:	68 71 4a 10 f0       	push   $0xf0104a71
f01012f7:	68 be 02 00 00       	push   $0x2be
f01012fc:	68 4b 4a 10 f0       	push   $0xf0104a4b
f0101301:	e8 9a ed ff ff       	call   f01000a0 <_panic>
	assert((pp2 = page_alloc(0)));
f0101306:	68 5f 4b 10 f0       	push   $0xf0104b5f
f010130b:	68 71 4a 10 f0       	push   $0xf0104a71
f0101310:	68 bf 02 00 00       	push   $0x2bf
f0101315:	68 4b 4a 10 f0       	push   $0xf0104a4b
f010131a:	e8 81 ed ff ff       	call   f01000a0 <_panic>
	assert(pp1 && pp1 != pp0);
f010131f:	68 75 4b 10 f0       	push   $0xf0104b75
f0101324:	68 71 4a 10 f0       	push   $0xf0104a71
f0101329:	68 c2 02 00 00       	push   $0x2c2
f010132e:	68 4b 4a 10 f0       	push   $0xf0104a4b
f0101333:	e8 68 ed ff ff       	call   f01000a0 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101338:	68 d4 4e 10 f0       	push   $0xf0104ed4
f010133d:	68 71 4a 10 f0       	push   $0xf0104a71
f0101342:	68 c3 02 00 00       	push   $0x2c3
f0101347:	68 4b 4a 10 f0       	push   $0xf0104a4b
f010134c:	e8 4f ed ff ff       	call   f01000a0 <_panic>
	assert(page2pa(pp0) < npages*PGSIZE);
f0101351:	68 87 4b 10 f0       	push   $0xf0104b87
f0101356:	68 71 4a 10 f0       	push   $0xf0104a71
f010135b:	68 c4 02 00 00       	push   $0x2c4
f0101360:	68 4b 4a 10 f0       	push   $0xf0104a4b
f0101365:	e8 36 ed ff ff       	call   f01000a0 <_panic>
	assert(page2pa(pp1) < npages*PGSIZE);
f010136a:	68 a4 4b 10 f0       	push   $0xf0104ba4
f010136f:	68 71 4a 10 f0       	push   $0xf0104a71
f0101374:	68 c5 02 00 00       	push   $0x2c5
f0101379:	68 4b 4a 10 f0       	push   $0xf0104a4b
f010137e:	e8 1d ed ff ff       	call   f01000a0 <_panic>
	assert(page2pa(pp2) < npages*PGSIZE);
f0101383:	68 c1 4b 10 f0       	push   $0xf0104bc1
f0101388:	68 71 4a 10 f0       	push   $0xf0104a71
f010138d:	68 c6 02 00 00       	push   $0x2c6
f0101392:	68 4b 4a 10 f0       	push   $0xf0104a4b
f0101397:	e8 04 ed ff ff       	call   f01000a0 <_panic>
	assert(!page_alloc(0));
f010139c:	68 de 4b 10 f0       	push   $0xf0104bde
f01013a1:	68 71 4a 10 f0       	push   $0xf0104a71
f01013a6:	68 cd 02 00 00       	push   $0x2cd
f01013ab:	68 4b 4a 10 f0       	push   $0xf0104a4b
f01013b0:	e8 eb ec ff ff       	call   f01000a0 <_panic>
	assert((pp0 = page_alloc(0)));
f01013b5:	68 33 4b 10 f0       	push   $0xf0104b33
f01013ba:	68 71 4a 10 f0       	push   $0xf0104a71
f01013bf:	68 d4 02 00 00       	push   $0x2d4
f01013c4:	68 4b 4a 10 f0       	push   $0xf0104a4b
f01013c9:	e8 d2 ec ff ff       	call   f01000a0 <_panic>
	assert((pp1 = page_alloc(0)));
f01013ce:	68 49 4b 10 f0       	push   $0xf0104b49
f01013d3:	68 71 4a 10 f0       	push   $0xf0104a71
f01013d8:	68 d5 02 00 00       	push   $0x2d5
f01013dd:	68 4b 4a 10 f0       	push   $0xf0104a4b
f01013e2:	e8 b9 ec ff ff       	call   f01000a0 <_panic>
	assert((pp2 = page_alloc(0)));
f01013e7:	68 5f 4b 10 f0       	push   $0xf0104b5f
f01013ec:	68 71 4a 10 f0       	push   $0xf0104a71
f01013f1:	68 d6 02 00 00       	push   $0x2d6
f01013f6:	68 4b 4a 10 f0       	push   $0xf0104a4b
f01013fb:	e8 a0 ec ff ff       	call   f01000a0 <_panic>
	assert(pp1 && pp1 != pp0);
f0101400:	68 75 4b 10 f0       	push   $0xf0104b75
f0101405:	68 71 4a 10 f0       	push   $0xf0104a71
f010140a:	68 d8 02 00 00       	push   $0x2d8
f010140f:	68 4b 4a 10 f0       	push   $0xf0104a4b
f0101414:	e8 87 ec ff ff       	call   f01000a0 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101419:	68 d4 4e 10 f0       	push   $0xf0104ed4
f010141e:	68 71 4a 10 f0       	push   $0xf0104a71
f0101423:	68 d9 02 00 00       	push   $0x2d9
f0101428:	68 4b 4a 10 f0       	push   $0xf0104a4b
f010142d:	e8 6e ec ff ff       	call   f01000a0 <_panic>
	assert(!page_alloc(0));
f0101432:	68 de 4b 10 f0       	push   $0xf0104bde
f0101437:	68 71 4a 10 f0       	push   $0xf0104a71
f010143c:	68 da 02 00 00       	push   $0x2da
f0101441:	68 4b 4a 10 f0       	push   $0xf0104a4b
f0101446:	e8 55 ec ff ff       	call   f01000a0 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010144b:	52                   	push   %edx
f010144c:	68 48 4d 10 f0       	push   $0xf0104d48
f0101451:	6a 56                	push   $0x56
f0101453:	68 57 4a 10 f0       	push   $0xf0104a57
f0101458:	e8 43 ec ff ff       	call   f01000a0 <_panic>
	assert((pp = page_alloc(ALLOC_ZERO)));
f010145d:	68 ed 4b 10 f0       	push   $0xf0104bed
f0101462:	68 71 4a 10 f0       	push   $0xf0104a71
f0101467:	68 df 02 00 00       	push   $0x2df
f010146c:	68 4b 4a 10 f0       	push   $0xf0104a4b
f0101471:	e8 2a ec ff ff       	call   f01000a0 <_panic>
	assert(pp && pp0 == pp);
f0101476:	68 0b 4c 10 f0       	push   $0xf0104c0b
f010147b:	68 71 4a 10 f0       	push   $0xf0104a71
f0101480:	68 e0 02 00 00       	push   $0x2e0
f0101485:	68 4b 4a 10 f0       	push   $0xf0104a4b
f010148a:	e8 11 ec ff ff       	call   f01000a0 <_panic>
f010148f:	52                   	push   %edx
f0101490:	68 48 4d 10 f0       	push   $0xf0104d48
f0101495:	6a 56                	push   $0x56
f0101497:	68 57 4a 10 f0       	push   $0xf0104a57
f010149c:	e8 ff eb ff ff       	call   f01000a0 <_panic>
		assert(c[i] == 0);
f01014a1:	68 1b 4c 10 f0       	push   $0xf0104c1b
f01014a6:	68 71 4a 10 f0       	push   $0xf0104a71
f01014ab:	68 e3 02 00 00       	push   $0x2e3
f01014b0:	68 4b 4a 10 f0       	push   $0xf0104a4b
f01014b5:	e8 e6 eb ff ff       	call   f01000a0 <_panic>
	assert(nfree == 0);
f01014ba:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f01014be:	0f 85 d6 07 00 00    	jne    f0101c9a <mem_init+0xd3a>
	cprintf("check_page_alloc() succeeded!\n");
f01014c4:	83 ec 0c             	sub    $0xc,%esp
f01014c7:	68 f4 4e 10 f0       	push   $0xf0104ef4
f01014cc:	e8 84 1a 00 00       	call   f0102f55 <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01014d1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01014d8:	e8 b5 f7 ff ff       	call   f0100c92 <page_alloc>
f01014dd:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01014e0:	83 c4 10             	add    $0x10,%esp
f01014e3:	85 c0                	test   %eax,%eax
f01014e5:	0f 84 c8 07 00 00    	je     f0101cb3 <mem_init+0xd53>
	assert((pp1 = page_alloc(0)));
f01014eb:	83 ec 0c             	sub    $0xc,%esp
f01014ee:	6a 00                	push   $0x0
f01014f0:	e8 9d f7 ff ff       	call   f0100c92 <page_alloc>
f01014f5:	89 c6                	mov    %eax,%esi
f01014f7:	83 c4 10             	add    $0x10,%esp
f01014fa:	85 c0                	test   %eax,%eax
f01014fc:	0f 84 ca 07 00 00    	je     f0101ccc <mem_init+0xd6c>
	assert((pp2 = page_alloc(0)));
f0101502:	83 ec 0c             	sub    $0xc,%esp
f0101505:	6a 00                	push   $0x0
f0101507:	e8 86 f7 ff ff       	call   f0100c92 <page_alloc>
f010150c:	89 c3                	mov    %eax,%ebx
f010150e:	83 c4 10             	add    $0x10,%esp
f0101511:	85 c0                	test   %eax,%eax
f0101513:	0f 84 cc 07 00 00    	je     f0101ce5 <mem_init+0xd85>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101519:	39 75 d4             	cmp    %esi,-0x2c(%ebp)
f010151c:	0f 84 dc 07 00 00    	je     f0101cfe <mem_init+0xd9e>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101522:	39 c6                	cmp    %eax,%esi
f0101524:	0f 84 ed 07 00 00    	je     f0101d17 <mem_init+0xdb7>
f010152a:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f010152d:	0f 84 e4 07 00 00    	je     f0101d17 <mem_init+0xdb7>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101533:	a1 3c 0d 1b f0       	mov    0xf01b0d3c,%eax
f0101538:	89 45 cc             	mov    %eax,-0x34(%ebp)
	page_free_list = 0;
f010153b:	c7 05 3c 0d 1b f0 00 	movl   $0x0,0xf01b0d3c
f0101542:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101545:	83 ec 0c             	sub    $0xc,%esp
f0101548:	6a 00                	push   $0x0
f010154a:	e8 43 f7 ff ff       	call   f0100c92 <page_alloc>
f010154f:	83 c4 10             	add    $0x10,%esp
f0101552:	85 c0                	test   %eax,%eax
f0101554:	0f 85 d6 07 00 00    	jne    f0101d30 <mem_init+0xdd0>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f010155a:	83 ec 04             	sub    $0x4,%esp
f010155d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101560:	50                   	push   %eax
f0101561:	6a 00                	push   $0x0
f0101563:	ff 35 0c 1a 1b f0    	pushl  0xf01b1a0c
f0101569:	e8 da f8 ff ff       	call   f0100e48 <page_lookup>
f010156e:	83 c4 10             	add    $0x10,%esp
f0101571:	85 c0                	test   %eax,%eax
f0101573:	0f 85 d0 07 00 00    	jne    f0101d49 <mem_init+0xde9>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0101579:	6a 02                	push   $0x2
f010157b:	6a 00                	push   $0x0
f010157d:	56                   	push   %esi
f010157e:	ff 35 0c 1a 1b f0    	pushl  0xf01b1a0c
f0101584:	e8 59 f9 ff ff       	call   f0100ee2 <page_insert>
f0101589:	83 c4 10             	add    $0x10,%esp
f010158c:	85 c0                	test   %eax,%eax
f010158e:	0f 89 ce 07 00 00    	jns    f0101d62 <mem_init+0xe02>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f0101594:	83 ec 0c             	sub    $0xc,%esp
f0101597:	ff 75 d4             	pushl  -0x2c(%ebp)
f010159a:	e8 68 f7 ff ff       	call   f0100d07 <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f010159f:	6a 02                	push   $0x2
f01015a1:	6a 00                	push   $0x0
f01015a3:	56                   	push   %esi
f01015a4:	ff 35 0c 1a 1b f0    	pushl  0xf01b1a0c
f01015aa:	e8 33 f9 ff ff       	call   f0100ee2 <page_insert>
f01015af:	83 c4 20             	add    $0x20,%esp
f01015b2:	85 c0                	test   %eax,%eax
f01015b4:	0f 85 c1 07 00 00    	jne    f0101d7b <mem_init+0xe1b>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01015ba:	8b 3d 0c 1a 1b f0    	mov    0xf01b1a0c,%edi
	return (pp - pages) << PGSHIFT;
f01015c0:	8b 0d 10 1a 1b f0    	mov    0xf01b1a10,%ecx
f01015c6:	89 4d d0             	mov    %ecx,-0x30(%ebp)
f01015c9:	8b 17                	mov    (%edi),%edx
f01015cb:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01015d1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01015d4:	29 c8                	sub    %ecx,%eax
f01015d6:	c1 f8 03             	sar    $0x3,%eax
f01015d9:	c1 e0 0c             	shl    $0xc,%eax
f01015dc:	39 c2                	cmp    %eax,%edx
f01015de:	0f 85 b0 07 00 00    	jne    f0101d94 <mem_init+0xe34>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f01015e4:	ba 00 00 00 00       	mov    $0x0,%edx
f01015e9:	89 f8                	mov    %edi,%eax
f01015eb:	e8 d2 f2 ff ff       	call   f01008c2 <check_va2pa>
f01015f0:	89 c2                	mov    %eax,%edx
f01015f2:	89 f0                	mov    %esi,%eax
f01015f4:	2b 45 d0             	sub    -0x30(%ebp),%eax
f01015f7:	c1 f8 03             	sar    $0x3,%eax
f01015fa:	c1 e0 0c             	shl    $0xc,%eax
f01015fd:	39 c2                	cmp    %eax,%edx
f01015ff:	0f 85 a8 07 00 00    	jne    f0101dad <mem_init+0xe4d>
	assert(pp1->pp_ref == 1);
f0101605:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f010160a:	0f 85 b6 07 00 00    	jne    f0101dc6 <mem_init+0xe66>
	assert(pp0->pp_ref == 1);
f0101610:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101613:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101618:	0f 85 c1 07 00 00    	jne    f0101ddf <mem_init+0xe7f>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f010161e:	6a 02                	push   $0x2
f0101620:	68 00 10 00 00       	push   $0x1000
f0101625:	53                   	push   %ebx
f0101626:	57                   	push   %edi
f0101627:	e8 b6 f8 ff ff       	call   f0100ee2 <page_insert>
f010162c:	83 c4 10             	add    $0x10,%esp
f010162f:	85 c0                	test   %eax,%eax
f0101631:	0f 85 c1 07 00 00    	jne    f0101df8 <mem_init+0xe98>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101637:	ba 00 10 00 00       	mov    $0x1000,%edx
f010163c:	a1 0c 1a 1b f0       	mov    0xf01b1a0c,%eax
f0101641:	e8 7c f2 ff ff       	call   f01008c2 <check_va2pa>
f0101646:	89 c2                	mov    %eax,%edx
f0101648:	89 d8                	mov    %ebx,%eax
f010164a:	2b 05 10 1a 1b f0    	sub    0xf01b1a10,%eax
f0101650:	c1 f8 03             	sar    $0x3,%eax
f0101653:	c1 e0 0c             	shl    $0xc,%eax
f0101656:	39 c2                	cmp    %eax,%edx
f0101658:	0f 85 b3 07 00 00    	jne    f0101e11 <mem_init+0xeb1>
	assert(pp2->pp_ref == 1);
f010165e:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101663:	0f 85 c1 07 00 00    	jne    f0101e2a <mem_init+0xeca>
	// should be no free memory
	assert(!page_alloc(0));
f0101669:	83 ec 0c             	sub    $0xc,%esp
f010166c:	6a 00                	push   $0x0
f010166e:	e8 1f f6 ff ff       	call   f0100c92 <page_alloc>
f0101673:	83 c4 10             	add    $0x10,%esp
f0101676:	85 c0                	test   %eax,%eax
f0101678:	0f 85 c5 07 00 00    	jne    f0101e43 <mem_init+0xee3>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f010167e:	6a 02                	push   $0x2
f0101680:	68 00 10 00 00       	push   $0x1000
f0101685:	53                   	push   %ebx
f0101686:	ff 35 0c 1a 1b f0    	pushl  0xf01b1a0c
f010168c:	e8 51 f8 ff ff       	call   f0100ee2 <page_insert>
f0101691:	83 c4 10             	add    $0x10,%esp
f0101694:	85 c0                	test   %eax,%eax
f0101696:	0f 85 c0 07 00 00    	jne    f0101e5c <mem_init+0xefc>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f010169c:	ba 00 10 00 00       	mov    $0x1000,%edx
f01016a1:	a1 0c 1a 1b f0       	mov    0xf01b1a0c,%eax
f01016a6:	e8 17 f2 ff ff       	call   f01008c2 <check_va2pa>
f01016ab:	89 c2                	mov    %eax,%edx
f01016ad:	89 d8                	mov    %ebx,%eax
f01016af:	2b 05 10 1a 1b f0    	sub    0xf01b1a10,%eax
f01016b5:	c1 f8 03             	sar    $0x3,%eax
f01016b8:	c1 e0 0c             	shl    $0xc,%eax
f01016bb:	39 c2                	cmp    %eax,%edx
f01016bd:	0f 85 b2 07 00 00    	jne    f0101e75 <mem_init+0xf15>
	assert(pp2->pp_ref == 1);
f01016c3:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f01016c8:	0f 85 c0 07 00 00    	jne    f0101e8e <mem_init+0xf2e>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f01016ce:	83 ec 0c             	sub    $0xc,%esp
f01016d1:	6a 00                	push   $0x0
f01016d3:	e8 ba f5 ff ff       	call   f0100c92 <page_alloc>
f01016d8:	83 c4 10             	add    $0x10,%esp
f01016db:	85 c0                	test   %eax,%eax
f01016dd:	0f 85 c4 07 00 00    	jne    f0101ea7 <mem_init+0xf47>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f01016e3:	8b 0d 0c 1a 1b f0    	mov    0xf01b1a0c,%ecx
f01016e9:	8b 01                	mov    (%ecx),%eax
f01016eb:	89 c2                	mov    %eax,%edx
f01016ed:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
	if (PGNUM(pa) >= npages)
f01016f3:	c1 e8 0c             	shr    $0xc,%eax
f01016f6:	3b 05 08 1a 1b f0    	cmp    0xf01b1a08,%eax
f01016fc:	0f 83 be 07 00 00    	jae    f0101ec0 <mem_init+0xf60>
	return (void *)(pa + KERNBASE);
f0101702:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f0101708:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f010170b:	83 ec 04             	sub    $0x4,%esp
f010170e:	6a 00                	push   $0x0
f0101710:	68 00 10 00 00       	push   $0x1000
f0101715:	51                   	push   %ecx
f0101716:	e8 4d f6 ff ff       	call   f0100d68 <pgdir_walk>
f010171b:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f010171e:	8d 51 04             	lea    0x4(%ecx),%edx
f0101721:	83 c4 10             	add    $0x10,%esp
f0101724:	39 c2                	cmp    %eax,%edx
f0101726:	0f 85 a9 07 00 00    	jne    f0101ed5 <mem_init+0xf75>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f010172c:	6a 06                	push   $0x6
f010172e:	68 00 10 00 00       	push   $0x1000
f0101733:	53                   	push   %ebx
f0101734:	ff 35 0c 1a 1b f0    	pushl  0xf01b1a0c
f010173a:	e8 a3 f7 ff ff       	call   f0100ee2 <page_insert>
f010173f:	83 c4 10             	add    $0x10,%esp
f0101742:	85 c0                	test   %eax,%eax
f0101744:	0f 85 a4 07 00 00    	jne    f0101eee <mem_init+0xf8e>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f010174a:	8b 3d 0c 1a 1b f0    	mov    0xf01b1a0c,%edi
f0101750:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101755:	89 f8                	mov    %edi,%eax
f0101757:	e8 66 f1 ff ff       	call   f01008c2 <check_va2pa>
f010175c:	89 c2                	mov    %eax,%edx
	return (pp - pages) << PGSHIFT;
f010175e:	89 d8                	mov    %ebx,%eax
f0101760:	2b 05 10 1a 1b f0    	sub    0xf01b1a10,%eax
f0101766:	c1 f8 03             	sar    $0x3,%eax
f0101769:	c1 e0 0c             	shl    $0xc,%eax
f010176c:	39 c2                	cmp    %eax,%edx
f010176e:	0f 85 93 07 00 00    	jne    f0101f07 <mem_init+0xfa7>
	assert(pp2->pp_ref == 1);
f0101774:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101779:	0f 85 a1 07 00 00    	jne    f0101f20 <mem_init+0xfc0>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f010177f:	83 ec 04             	sub    $0x4,%esp
f0101782:	6a 00                	push   $0x0
f0101784:	68 00 10 00 00       	push   $0x1000
f0101789:	57                   	push   %edi
f010178a:	e8 d9 f5 ff ff       	call   f0100d68 <pgdir_walk>
f010178f:	83 c4 10             	add    $0x10,%esp
f0101792:	f6 00 04             	testb  $0x4,(%eax)
f0101795:	0f 84 9e 07 00 00    	je     f0101f39 <mem_init+0xfd9>
	assert(kern_pgdir[0] & PTE_U);
f010179b:	a1 0c 1a 1b f0       	mov    0xf01b1a0c,%eax
f01017a0:	f6 00 04             	testb  $0x4,(%eax)
f01017a3:	0f 84 a9 07 00 00    	je     f0101f52 <mem_init+0xff2>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f01017a9:	6a 02                	push   $0x2
f01017ab:	68 00 10 00 00       	push   $0x1000
f01017b0:	53                   	push   %ebx
f01017b1:	50                   	push   %eax
f01017b2:	e8 2b f7 ff ff       	call   f0100ee2 <page_insert>
f01017b7:	83 c4 10             	add    $0x10,%esp
f01017ba:	85 c0                	test   %eax,%eax
f01017bc:	0f 85 a9 07 00 00    	jne    f0101f6b <mem_init+0x100b>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f01017c2:	83 ec 04             	sub    $0x4,%esp
f01017c5:	6a 00                	push   $0x0
f01017c7:	68 00 10 00 00       	push   $0x1000
f01017cc:	ff 35 0c 1a 1b f0    	pushl  0xf01b1a0c
f01017d2:	e8 91 f5 ff ff       	call   f0100d68 <pgdir_walk>
f01017d7:	83 c4 10             	add    $0x10,%esp
f01017da:	f6 00 02             	testb  $0x2,(%eax)
f01017dd:	0f 84 a1 07 00 00    	je     f0101f84 <mem_init+0x1024>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f01017e3:	83 ec 04             	sub    $0x4,%esp
f01017e6:	6a 00                	push   $0x0
f01017e8:	68 00 10 00 00       	push   $0x1000
f01017ed:	ff 35 0c 1a 1b f0    	pushl  0xf01b1a0c
f01017f3:	e8 70 f5 ff ff       	call   f0100d68 <pgdir_walk>
f01017f8:	83 c4 10             	add    $0x10,%esp
f01017fb:	f6 00 04             	testb  $0x4,(%eax)
f01017fe:	0f 85 99 07 00 00    	jne    f0101f9d <mem_init+0x103d>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0101804:	6a 02                	push   $0x2
f0101806:	68 00 00 40 00       	push   $0x400000
f010180b:	ff 75 d4             	pushl  -0x2c(%ebp)
f010180e:	ff 35 0c 1a 1b f0    	pushl  0xf01b1a0c
f0101814:	e8 c9 f6 ff ff       	call   f0100ee2 <page_insert>
f0101819:	83 c4 10             	add    $0x10,%esp
f010181c:	85 c0                	test   %eax,%eax
f010181e:	0f 89 92 07 00 00    	jns    f0101fb6 <mem_init+0x1056>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0101824:	6a 02                	push   $0x2
f0101826:	68 00 10 00 00       	push   $0x1000
f010182b:	56                   	push   %esi
f010182c:	ff 35 0c 1a 1b f0    	pushl  0xf01b1a0c
f0101832:	e8 ab f6 ff ff       	call   f0100ee2 <page_insert>
f0101837:	83 c4 10             	add    $0x10,%esp
f010183a:	85 c0                	test   %eax,%eax
f010183c:	0f 85 8d 07 00 00    	jne    f0101fcf <mem_init+0x106f>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101842:	83 ec 04             	sub    $0x4,%esp
f0101845:	6a 00                	push   $0x0
f0101847:	68 00 10 00 00       	push   $0x1000
f010184c:	ff 35 0c 1a 1b f0    	pushl  0xf01b1a0c
f0101852:	e8 11 f5 ff ff       	call   f0100d68 <pgdir_walk>
f0101857:	83 c4 10             	add    $0x10,%esp
f010185a:	f6 00 04             	testb  $0x4,(%eax)
f010185d:	0f 85 85 07 00 00    	jne    f0101fe8 <mem_init+0x1088>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0101863:	a1 0c 1a 1b f0       	mov    0xf01b1a0c,%eax
f0101868:	89 45 d0             	mov    %eax,-0x30(%ebp)
f010186b:	ba 00 00 00 00       	mov    $0x0,%edx
f0101870:	e8 4d f0 ff ff       	call   f01008c2 <check_va2pa>
f0101875:	89 f7                	mov    %esi,%edi
f0101877:	2b 3d 10 1a 1b f0    	sub    0xf01b1a10,%edi
f010187d:	c1 ff 03             	sar    $0x3,%edi
f0101880:	c1 e7 0c             	shl    $0xc,%edi
f0101883:	39 f8                	cmp    %edi,%eax
f0101885:	0f 85 76 07 00 00    	jne    f0102001 <mem_init+0x10a1>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f010188b:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101890:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101893:	e8 2a f0 ff ff       	call   f01008c2 <check_va2pa>
f0101898:	39 c7                	cmp    %eax,%edi
f010189a:	0f 85 7a 07 00 00    	jne    f010201a <mem_init+0x10ba>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f01018a0:	66 83 7e 04 02       	cmpw   $0x2,0x4(%esi)
f01018a5:	0f 85 88 07 00 00    	jne    f0102033 <mem_init+0x10d3>
	assert(pp2->pp_ref == 0);
f01018ab:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f01018b0:	0f 85 96 07 00 00    	jne    f010204c <mem_init+0x10ec>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f01018b6:	83 ec 0c             	sub    $0xc,%esp
f01018b9:	6a 00                	push   $0x0
f01018bb:	e8 d2 f3 ff ff       	call   f0100c92 <page_alloc>
f01018c0:	83 c4 10             	add    $0x10,%esp
f01018c3:	85 c0                	test   %eax,%eax
f01018c5:	0f 84 9a 07 00 00    	je     f0102065 <mem_init+0x1105>
f01018cb:	39 c3                	cmp    %eax,%ebx
f01018cd:	0f 85 92 07 00 00    	jne    f0102065 <mem_init+0x1105>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f01018d3:	83 ec 08             	sub    $0x8,%esp
f01018d6:	6a 00                	push   $0x0
f01018d8:	ff 35 0c 1a 1b f0    	pushl  0xf01b1a0c
f01018de:	e8 c4 f5 ff ff       	call   f0100ea7 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f01018e3:	8b 3d 0c 1a 1b f0    	mov    0xf01b1a0c,%edi
f01018e9:	ba 00 00 00 00       	mov    $0x0,%edx
f01018ee:	89 f8                	mov    %edi,%eax
f01018f0:	e8 cd ef ff ff       	call   f01008c2 <check_va2pa>
f01018f5:	83 c4 10             	add    $0x10,%esp
f01018f8:	83 f8 ff             	cmp    $0xffffffff,%eax
f01018fb:	0f 85 7d 07 00 00    	jne    f010207e <mem_init+0x111e>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101901:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101906:	89 f8                	mov    %edi,%eax
f0101908:	e8 b5 ef ff ff       	call   f01008c2 <check_va2pa>
f010190d:	89 c2                	mov    %eax,%edx
f010190f:	89 f0                	mov    %esi,%eax
f0101911:	2b 05 10 1a 1b f0    	sub    0xf01b1a10,%eax
f0101917:	c1 f8 03             	sar    $0x3,%eax
f010191a:	c1 e0 0c             	shl    $0xc,%eax
f010191d:	39 c2                	cmp    %eax,%edx
f010191f:	0f 85 72 07 00 00    	jne    f0102097 <mem_init+0x1137>
	assert(pp1->pp_ref == 1);
f0101925:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f010192a:	0f 85 80 07 00 00    	jne    f01020b0 <mem_init+0x1150>
	assert(pp2->pp_ref == 0);
f0101930:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101935:	0f 85 8e 07 00 00    	jne    f01020c9 <mem_init+0x1169>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f010193b:	6a 00                	push   $0x0
f010193d:	68 00 10 00 00       	push   $0x1000
f0101942:	56                   	push   %esi
f0101943:	57                   	push   %edi
f0101944:	e8 99 f5 ff ff       	call   f0100ee2 <page_insert>
f0101949:	83 c4 10             	add    $0x10,%esp
f010194c:	85 c0                	test   %eax,%eax
f010194e:	0f 85 8e 07 00 00    	jne    f01020e2 <mem_init+0x1182>
	assert(pp1->pp_ref);
f0101954:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101959:	0f 84 9c 07 00 00    	je     f01020fb <mem_init+0x119b>
	assert(pp1->pp_link == NULL);
f010195f:	83 3e 00             	cmpl   $0x0,(%esi)
f0101962:	0f 85 ac 07 00 00    	jne    f0102114 <mem_init+0x11b4>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f0101968:	83 ec 08             	sub    $0x8,%esp
f010196b:	68 00 10 00 00       	push   $0x1000
f0101970:	ff 35 0c 1a 1b f0    	pushl  0xf01b1a0c
f0101976:	e8 2c f5 ff ff       	call   f0100ea7 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f010197b:	8b 3d 0c 1a 1b f0    	mov    0xf01b1a0c,%edi
f0101981:	ba 00 00 00 00       	mov    $0x0,%edx
f0101986:	89 f8                	mov    %edi,%eax
f0101988:	e8 35 ef ff ff       	call   f01008c2 <check_va2pa>
f010198d:	83 c4 10             	add    $0x10,%esp
f0101990:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101993:	0f 85 94 07 00 00    	jne    f010212d <mem_init+0x11cd>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0101999:	ba 00 10 00 00       	mov    $0x1000,%edx
f010199e:	89 f8                	mov    %edi,%eax
f01019a0:	e8 1d ef ff ff       	call   f01008c2 <check_va2pa>
f01019a5:	83 f8 ff             	cmp    $0xffffffff,%eax
f01019a8:	0f 85 98 07 00 00    	jne    f0102146 <mem_init+0x11e6>
	assert(pp1->pp_ref == 0);
f01019ae:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f01019b3:	0f 85 a6 07 00 00    	jne    f010215f <mem_init+0x11ff>
	assert(pp2->pp_ref == 0);
f01019b9:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f01019be:	0f 85 b4 07 00 00    	jne    f0102178 <mem_init+0x1218>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f01019c4:	83 ec 0c             	sub    $0xc,%esp
f01019c7:	6a 00                	push   $0x0
f01019c9:	e8 c4 f2 ff ff       	call   f0100c92 <page_alloc>
f01019ce:	83 c4 10             	add    $0x10,%esp
f01019d1:	85 c0                	test   %eax,%eax
f01019d3:	0f 84 b8 07 00 00    	je     f0102191 <mem_init+0x1231>
f01019d9:	39 c6                	cmp    %eax,%esi
f01019db:	0f 85 b0 07 00 00    	jne    f0102191 <mem_init+0x1231>

	// should be no free memory
	assert(!page_alloc(0));
f01019e1:	83 ec 0c             	sub    $0xc,%esp
f01019e4:	6a 00                	push   $0x0
f01019e6:	e8 a7 f2 ff ff       	call   f0100c92 <page_alloc>
f01019eb:	83 c4 10             	add    $0x10,%esp
f01019ee:	85 c0                	test   %eax,%eax
f01019f0:	0f 85 b4 07 00 00    	jne    f01021aa <mem_init+0x124a>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01019f6:	8b 0d 0c 1a 1b f0    	mov    0xf01b1a0c,%ecx
f01019fc:	8b 11                	mov    (%ecx),%edx
f01019fe:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101a04:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101a07:	2b 05 10 1a 1b f0    	sub    0xf01b1a10,%eax
f0101a0d:	c1 f8 03             	sar    $0x3,%eax
f0101a10:	c1 e0 0c             	shl    $0xc,%eax
f0101a13:	39 c2                	cmp    %eax,%edx
f0101a15:	0f 85 a8 07 00 00    	jne    f01021c3 <mem_init+0x1263>
	kern_pgdir[0] = 0;
f0101a1b:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0101a21:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101a24:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101a29:	0f 85 ad 07 00 00    	jne    f01021dc <mem_init+0x127c>
	pp0->pp_ref = 0;
f0101a2f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101a32:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f0101a38:	83 ec 0c             	sub    $0xc,%esp
f0101a3b:	50                   	push   %eax
f0101a3c:	e8 c6 f2 ff ff       	call   f0100d07 <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f0101a41:	83 c4 0c             	add    $0xc,%esp
f0101a44:	6a 01                	push   $0x1
f0101a46:	68 00 10 40 00       	push   $0x401000
f0101a4b:	ff 35 0c 1a 1b f0    	pushl  0xf01b1a0c
f0101a51:	e8 12 f3 ff ff       	call   f0100d68 <pgdir_walk>
f0101a56:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f0101a59:	8b 0d 0c 1a 1b f0    	mov    0xf01b1a0c,%ecx
f0101a5f:	8b 51 04             	mov    0x4(%ecx),%edx
f0101a62:	89 d7                	mov    %edx,%edi
f0101a64:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
f0101a6a:	89 7d d0             	mov    %edi,-0x30(%ebp)
	if (PGNUM(pa) >= npages)
f0101a6d:	8b 3d 08 1a 1b f0    	mov    0xf01b1a08,%edi
f0101a73:	c1 ea 0c             	shr    $0xc,%edx
f0101a76:	83 c4 10             	add    $0x10,%esp
f0101a79:	39 fa                	cmp    %edi,%edx
f0101a7b:	0f 83 74 07 00 00    	jae    f01021f5 <mem_init+0x1295>
	assert(ptep == ptep1 + PTX(va));
f0101a81:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0101a84:	81 ea fc ff ff 0f    	sub    $0xffffffc,%edx
f0101a8a:	39 d0                	cmp    %edx,%eax
f0101a8c:	0f 85 7a 07 00 00    	jne    f010220c <mem_init+0x12ac>
	kern_pgdir[PDX(va)] = 0;
f0101a92:	c7 41 04 00 00 00 00 	movl   $0x0,0x4(%ecx)
	pp0->pp_ref = 0;
f0101a99:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101a9c:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
	return (pp - pages) << PGSHIFT;
f0101aa2:	2b 05 10 1a 1b f0    	sub    0xf01b1a10,%eax
f0101aa8:	c1 f8 03             	sar    $0x3,%eax
f0101aab:	89 c2                	mov    %eax,%edx
f0101aad:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0101ab0:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0101ab5:	39 c7                	cmp    %eax,%edi
f0101ab7:	0f 86 68 07 00 00    	jbe    f0102225 <mem_init+0x12c5>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f0101abd:	83 ec 04             	sub    $0x4,%esp
f0101ac0:	68 00 10 00 00       	push   $0x1000
f0101ac5:	68 ff 00 00 00       	push   $0xff
	return (void *)(pa + KERNBASE);
f0101aca:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f0101ad0:	52                   	push   %edx
f0101ad1:	e8 ab 26 00 00       	call   f0104181 <memset>
	page_free(pp0);
f0101ad6:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0101ad9:	89 3c 24             	mov    %edi,(%esp)
f0101adc:	e8 26 f2 ff ff       	call   f0100d07 <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f0101ae1:	83 c4 0c             	add    $0xc,%esp
f0101ae4:	6a 01                	push   $0x1
f0101ae6:	6a 00                	push   $0x0
f0101ae8:	ff 35 0c 1a 1b f0    	pushl  0xf01b1a0c
f0101aee:	e8 75 f2 ff ff       	call   f0100d68 <pgdir_walk>
	return (pp - pages) << PGSHIFT;
f0101af3:	89 f8                	mov    %edi,%eax
f0101af5:	2b 05 10 1a 1b f0    	sub    0xf01b1a10,%eax
f0101afb:	c1 f8 03             	sar    $0x3,%eax
f0101afe:	89 c2                	mov    %eax,%edx
f0101b00:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0101b03:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0101b08:	83 c4 10             	add    $0x10,%esp
f0101b0b:	3b 05 08 1a 1b f0    	cmp    0xf01b1a08,%eax
f0101b11:	0f 83 20 07 00 00    	jae    f0102237 <mem_init+0x12d7>
	return (void *)(pa + KERNBASE);
f0101b17:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f0101b1d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0101b20:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0101b26:	8b 38                	mov    (%eax),%edi
f0101b28:	83 e7 01             	and    $0x1,%edi
f0101b2b:	0f 85 18 07 00 00    	jne    f0102249 <mem_init+0x12e9>
f0101b31:	83 c0 04             	add    $0x4,%eax
	for(i=0; i<NPTENTRIES; i++)
f0101b34:	39 d0                	cmp    %edx,%eax
f0101b36:	75 ee                	jne    f0101b26 <mem_init+0xbc6>
	kern_pgdir[0] = 0;
f0101b38:	a1 0c 1a 1b f0       	mov    0xf01b1a0c,%eax
f0101b3d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f0101b43:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101b46:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// give free list back
	page_free_list = fl;
f0101b4c:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0101b4f:	89 0d 3c 0d 1b f0    	mov    %ecx,0xf01b0d3c

	// free the pages we took
	page_free(pp0);
f0101b55:	83 ec 0c             	sub    $0xc,%esp
f0101b58:	50                   	push   %eax
f0101b59:	e8 a9 f1 ff ff       	call   f0100d07 <page_free>
	page_free(pp1);
f0101b5e:	89 34 24             	mov    %esi,(%esp)
f0101b61:	e8 a1 f1 ff ff       	call   f0100d07 <page_free>
	page_free(pp2);
f0101b66:	89 1c 24             	mov    %ebx,(%esp)
f0101b69:	e8 99 f1 ff ff       	call   f0100d07 <page_free>

	cprintf("check_page() succeeded!\n");
f0101b6e:	c7 04 24 fc 4c 10 f0 	movl   $0xf0104cfc,(%esp)
f0101b75:	e8 db 13 00 00       	call   f0102f55 <cprintf>
	boot_map_region(kern_pgdir, UPAGES, PTSIZE, PADDR((void *)pages), PTE_U | PTE_P);
f0101b7a:	a1 10 1a 1b f0       	mov    0xf01b1a10,%eax
	if ((uint32_t)kva < KERNBASE)
f0101b7f:	83 c4 10             	add    $0x10,%esp
f0101b82:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101b87:	0f 86 d5 06 00 00    	jbe    f0102262 <mem_init+0x1302>
f0101b8d:	83 ec 08             	sub    $0x8,%esp
f0101b90:	6a 05                	push   $0x5
	return (physaddr_t)kva - KERNBASE;
f0101b92:	05 00 00 00 10       	add    $0x10000000,%eax
f0101b97:	50                   	push   %eax
f0101b98:	b9 00 00 40 00       	mov    $0x400000,%ecx
f0101b9d:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f0101ba2:	a1 0c 1a 1b f0       	mov    0xf01b1a0c,%eax
f0101ba7:	e8 48 f2 ff ff       	call   f0100df4 <boot_map_region>
	boot_map_region(kern_pgdir, UENVS, PTSIZE, PADDR((void *)envs), PTE_U | PTE_P);
f0101bac:	a1 48 0d 1b f0       	mov    0xf01b0d48,%eax
	if ((uint32_t)kva < KERNBASE)
f0101bb1:	83 c4 10             	add    $0x10,%esp
f0101bb4:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101bb9:	0f 86 b8 06 00 00    	jbe    f0102277 <mem_init+0x1317>
f0101bbf:	83 ec 08             	sub    $0x8,%esp
f0101bc2:	6a 05                	push   $0x5
	return (physaddr_t)kva - KERNBASE;
f0101bc4:	05 00 00 00 10       	add    $0x10000000,%eax
f0101bc9:	50                   	push   %eax
f0101bca:	b9 00 00 40 00       	mov    $0x400000,%ecx
f0101bcf:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f0101bd4:	a1 0c 1a 1b f0       	mov    0xf01b1a0c,%eax
f0101bd9:	e8 16 f2 ff ff       	call   f0100df4 <boot_map_region>
	if ((uint32_t)kva < KERNBASE)
f0101bde:	83 c4 10             	add    $0x10,%esp
f0101be1:	b8 00 20 11 f0       	mov    $0xf0112000,%eax
f0101be6:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101beb:	0f 86 9b 06 00 00    	jbe    f010228c <mem_init+0x132c>
	boot_map_region(kern_pgdir, KSTACKTOP - KSTKSIZE, KSTKSIZE, PADDR((void *)(bootstack)), PTE_P | PTE_W);
f0101bf1:	83 ec 08             	sub    $0x8,%esp
f0101bf4:	6a 03                	push   $0x3
f0101bf6:	68 00 20 11 00       	push   $0x112000
f0101bfb:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0101c00:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f0101c05:	a1 0c 1a 1b f0       	mov    0xf01b1a0c,%eax
f0101c0a:	e8 e5 f1 ff ff       	call   f0100df4 <boot_map_region>
	boot_map_region(kern_pgdir, KERNBASE, (1ULL << 32) - KERNBASE, PADDR((void *)KERNBASE), PTE_P | PTE_W);
f0101c0f:	83 c4 08             	add    $0x8,%esp
f0101c12:	6a 03                	push   $0x3
f0101c14:	6a 00                	push   $0x0
f0101c16:	b9 00 00 00 10       	mov    $0x10000000,%ecx
f0101c1b:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f0101c20:	a1 0c 1a 1b f0       	mov    0xf01b1a0c,%eax
f0101c25:	e8 ca f1 ff ff       	call   f0100df4 <boot_map_region>
	pgdir = kern_pgdir;
f0101c2a:	a1 0c 1a 1b f0       	mov    0xf01b1a0c,%eax
f0101c2f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f0101c32:	a1 08 1a 1b f0       	mov    0xf01b1a08,%eax
f0101c37:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f0101c3a:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
f0101c41:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0101c46:	89 45 d0             	mov    %eax,-0x30(%ebp)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0101c49:	8b 35 10 1a 1b f0    	mov    0xf01b1a10,%esi
f0101c4f:	89 75 cc             	mov    %esi,-0x34(%ebp)
	return (physaddr_t)kva - KERNBASE;
f0101c52:	8d 86 00 00 00 10    	lea    0x10000000(%esi),%eax
f0101c58:	89 45 c8             	mov    %eax,-0x38(%ebp)
	for (i = 0; i < n; i += PGSIZE)
f0101c5b:	83 c4 10             	add    $0x10,%esp
f0101c5e:	89 fb                	mov    %edi,%ebx
f0101c60:	39 5d d0             	cmp    %ebx,-0x30(%ebp)
f0101c63:	0f 86 66 06 00 00    	jbe    f01022cf <mem_init+0x136f>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0101c69:	8d 93 00 00 00 ef    	lea    -0x11000000(%ebx),%edx
f0101c6f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101c72:	e8 4b ec ff ff       	call   f01008c2 <check_va2pa>
	if ((uint32_t)kva < KERNBASE)
f0101c77:	81 7d cc ff ff ff ef 	cmpl   $0xefffffff,-0x34(%ebp)
f0101c7e:	0f 86 1d 06 00 00    	jbe    f01022a1 <mem_init+0x1341>
f0101c84:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0101c87:	8d 14 0b             	lea    (%ebx,%ecx,1),%edx
f0101c8a:	39 d0                	cmp    %edx,%eax
f0101c8c:	0f 85 24 06 00 00    	jne    f01022b6 <mem_init+0x1356>
	for (i = 0; i < n; i += PGSIZE)
f0101c92:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0101c98:	eb c6                	jmp    f0101c60 <mem_init+0xd00>
	assert(nfree == 0);
f0101c9a:	68 25 4c 10 f0       	push   $0xf0104c25
f0101c9f:	68 71 4a 10 f0       	push   $0xf0104a71
f0101ca4:	68 f0 02 00 00       	push   $0x2f0
f0101ca9:	68 4b 4a 10 f0       	push   $0xf0104a4b
f0101cae:	e8 ed e3 ff ff       	call   f01000a0 <_panic>
	assert((pp0 = page_alloc(0)));
f0101cb3:	68 33 4b 10 f0       	push   $0xf0104b33
f0101cb8:	68 71 4a 10 f0       	push   $0xf0104a71
f0101cbd:	68 4e 03 00 00       	push   $0x34e
f0101cc2:	68 4b 4a 10 f0       	push   $0xf0104a4b
f0101cc7:	e8 d4 e3 ff ff       	call   f01000a0 <_panic>
	assert((pp1 = page_alloc(0)));
f0101ccc:	68 49 4b 10 f0       	push   $0xf0104b49
f0101cd1:	68 71 4a 10 f0       	push   $0xf0104a71
f0101cd6:	68 4f 03 00 00       	push   $0x34f
f0101cdb:	68 4b 4a 10 f0       	push   $0xf0104a4b
f0101ce0:	e8 bb e3 ff ff       	call   f01000a0 <_panic>
	assert((pp2 = page_alloc(0)));
f0101ce5:	68 5f 4b 10 f0       	push   $0xf0104b5f
f0101cea:	68 71 4a 10 f0       	push   $0xf0104a71
f0101cef:	68 50 03 00 00       	push   $0x350
f0101cf4:	68 4b 4a 10 f0       	push   $0xf0104a4b
f0101cf9:	e8 a2 e3 ff ff       	call   f01000a0 <_panic>
	assert(pp1 && pp1 != pp0);
f0101cfe:	68 75 4b 10 f0       	push   $0xf0104b75
f0101d03:	68 71 4a 10 f0       	push   $0xf0104a71
f0101d08:	68 53 03 00 00       	push   $0x353
f0101d0d:	68 4b 4a 10 f0       	push   $0xf0104a4b
f0101d12:	e8 89 e3 ff ff       	call   f01000a0 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101d17:	68 d4 4e 10 f0       	push   $0xf0104ed4
f0101d1c:	68 71 4a 10 f0       	push   $0xf0104a71
f0101d21:	68 54 03 00 00       	push   $0x354
f0101d26:	68 4b 4a 10 f0       	push   $0xf0104a4b
f0101d2b:	e8 70 e3 ff ff       	call   f01000a0 <_panic>
	assert(!page_alloc(0));
f0101d30:	68 de 4b 10 f0       	push   $0xf0104bde
f0101d35:	68 71 4a 10 f0       	push   $0xf0104a71
f0101d3a:	68 5b 03 00 00       	push   $0x35b
f0101d3f:	68 4b 4a 10 f0       	push   $0xf0104a4b
f0101d44:	e8 57 e3 ff ff       	call   f01000a0 <_panic>
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0101d49:	68 14 4f 10 f0       	push   $0xf0104f14
f0101d4e:	68 71 4a 10 f0       	push   $0xf0104a71
f0101d53:	68 5e 03 00 00       	push   $0x35e
f0101d58:	68 4b 4a 10 f0       	push   $0xf0104a4b
f0101d5d:	e8 3e e3 ff ff       	call   f01000a0 <_panic>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0101d62:	68 4c 4f 10 f0       	push   $0xf0104f4c
f0101d67:	68 71 4a 10 f0       	push   $0xf0104a71
f0101d6c:	68 61 03 00 00       	push   $0x361
f0101d71:	68 4b 4a 10 f0       	push   $0xf0104a4b
f0101d76:	e8 25 e3 ff ff       	call   f01000a0 <_panic>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0101d7b:	68 7c 4f 10 f0       	push   $0xf0104f7c
f0101d80:	68 71 4a 10 f0       	push   $0xf0104a71
f0101d85:	68 65 03 00 00       	push   $0x365
f0101d8a:	68 4b 4a 10 f0       	push   $0xf0104a4b
f0101d8f:	e8 0c e3 ff ff       	call   f01000a0 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101d94:	68 ac 4f 10 f0       	push   $0xf0104fac
f0101d99:	68 71 4a 10 f0       	push   $0xf0104a71
f0101d9e:	68 66 03 00 00       	push   $0x366
f0101da3:	68 4b 4a 10 f0       	push   $0xf0104a4b
f0101da8:	e8 f3 e2 ff ff       	call   f01000a0 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0101dad:	68 d4 4f 10 f0       	push   $0xf0104fd4
f0101db2:	68 71 4a 10 f0       	push   $0xf0104a71
f0101db7:	68 67 03 00 00       	push   $0x367
f0101dbc:	68 4b 4a 10 f0       	push   $0xf0104a4b
f0101dc1:	e8 da e2 ff ff       	call   f01000a0 <_panic>
	assert(pp1->pp_ref == 1);
f0101dc6:	68 30 4c 10 f0       	push   $0xf0104c30
f0101dcb:	68 71 4a 10 f0       	push   $0xf0104a71
f0101dd0:	68 68 03 00 00       	push   $0x368
f0101dd5:	68 4b 4a 10 f0       	push   $0xf0104a4b
f0101dda:	e8 c1 e2 ff ff       	call   f01000a0 <_panic>
	assert(pp0->pp_ref == 1);
f0101ddf:	68 41 4c 10 f0       	push   $0xf0104c41
f0101de4:	68 71 4a 10 f0       	push   $0xf0104a71
f0101de9:	68 69 03 00 00       	push   $0x369
f0101dee:	68 4b 4a 10 f0       	push   $0xf0104a4b
f0101df3:	e8 a8 e2 ff ff       	call   f01000a0 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101df8:	68 04 50 10 f0       	push   $0xf0105004
f0101dfd:	68 71 4a 10 f0       	push   $0xf0104a71
f0101e02:	68 6c 03 00 00       	push   $0x36c
f0101e07:	68 4b 4a 10 f0       	push   $0xf0104a4b
f0101e0c:	e8 8f e2 ff ff       	call   f01000a0 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101e11:	68 40 50 10 f0       	push   $0xf0105040
f0101e16:	68 71 4a 10 f0       	push   $0xf0104a71
f0101e1b:	68 6d 03 00 00       	push   $0x36d
f0101e20:	68 4b 4a 10 f0       	push   $0xf0104a4b
f0101e25:	e8 76 e2 ff ff       	call   f01000a0 <_panic>
	assert(pp2->pp_ref == 1);
f0101e2a:	68 52 4c 10 f0       	push   $0xf0104c52
f0101e2f:	68 71 4a 10 f0       	push   $0xf0104a71
f0101e34:	68 6e 03 00 00       	push   $0x36e
f0101e39:	68 4b 4a 10 f0       	push   $0xf0104a4b
f0101e3e:	e8 5d e2 ff ff       	call   f01000a0 <_panic>
	assert(!page_alloc(0));
f0101e43:	68 de 4b 10 f0       	push   $0xf0104bde
f0101e48:	68 71 4a 10 f0       	push   $0xf0104a71
f0101e4d:	68 70 03 00 00       	push   $0x370
f0101e52:	68 4b 4a 10 f0       	push   $0xf0104a4b
f0101e57:	e8 44 e2 ff ff       	call   f01000a0 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101e5c:	68 04 50 10 f0       	push   $0xf0105004
f0101e61:	68 71 4a 10 f0       	push   $0xf0104a71
f0101e66:	68 73 03 00 00       	push   $0x373
f0101e6b:	68 4b 4a 10 f0       	push   $0xf0104a4b
f0101e70:	e8 2b e2 ff ff       	call   f01000a0 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101e75:	68 40 50 10 f0       	push   $0xf0105040
f0101e7a:	68 71 4a 10 f0       	push   $0xf0104a71
f0101e7f:	68 74 03 00 00       	push   $0x374
f0101e84:	68 4b 4a 10 f0       	push   $0xf0104a4b
f0101e89:	e8 12 e2 ff ff       	call   f01000a0 <_panic>
	assert(pp2->pp_ref == 1);
f0101e8e:	68 52 4c 10 f0       	push   $0xf0104c52
f0101e93:	68 71 4a 10 f0       	push   $0xf0104a71
f0101e98:	68 75 03 00 00       	push   $0x375
f0101e9d:	68 4b 4a 10 f0       	push   $0xf0104a4b
f0101ea2:	e8 f9 e1 ff ff       	call   f01000a0 <_panic>
	assert(!page_alloc(0));
f0101ea7:	68 de 4b 10 f0       	push   $0xf0104bde
f0101eac:	68 71 4a 10 f0       	push   $0xf0104a71
f0101eb1:	68 79 03 00 00       	push   $0x379
f0101eb6:	68 4b 4a 10 f0       	push   $0xf0104a4b
f0101ebb:	e8 e0 e1 ff ff       	call   f01000a0 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101ec0:	52                   	push   %edx
f0101ec1:	68 48 4d 10 f0       	push   $0xf0104d48
f0101ec6:	68 7c 03 00 00       	push   $0x37c
f0101ecb:	68 4b 4a 10 f0       	push   $0xf0104a4b
f0101ed0:	e8 cb e1 ff ff       	call   f01000a0 <_panic>
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0101ed5:	68 70 50 10 f0       	push   $0xf0105070
f0101eda:	68 71 4a 10 f0       	push   $0xf0104a71
f0101edf:	68 7d 03 00 00       	push   $0x37d
f0101ee4:	68 4b 4a 10 f0       	push   $0xf0104a4b
f0101ee9:	e8 b2 e1 ff ff       	call   f01000a0 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0101eee:	68 b0 50 10 f0       	push   $0xf01050b0
f0101ef3:	68 71 4a 10 f0       	push   $0xf0104a71
f0101ef8:	68 80 03 00 00       	push   $0x380
f0101efd:	68 4b 4a 10 f0       	push   $0xf0104a4b
f0101f02:	e8 99 e1 ff ff       	call   f01000a0 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101f07:	68 40 50 10 f0       	push   $0xf0105040
f0101f0c:	68 71 4a 10 f0       	push   $0xf0104a71
f0101f11:	68 81 03 00 00       	push   $0x381
f0101f16:	68 4b 4a 10 f0       	push   $0xf0104a4b
f0101f1b:	e8 80 e1 ff ff       	call   f01000a0 <_panic>
	assert(pp2->pp_ref == 1);
f0101f20:	68 52 4c 10 f0       	push   $0xf0104c52
f0101f25:	68 71 4a 10 f0       	push   $0xf0104a71
f0101f2a:	68 82 03 00 00       	push   $0x382
f0101f2f:	68 4b 4a 10 f0       	push   $0xf0104a4b
f0101f34:	e8 67 e1 ff ff       	call   f01000a0 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0101f39:	68 f0 50 10 f0       	push   $0xf01050f0
f0101f3e:	68 71 4a 10 f0       	push   $0xf0104a71
f0101f43:	68 83 03 00 00       	push   $0x383
f0101f48:	68 4b 4a 10 f0       	push   $0xf0104a4b
f0101f4d:	e8 4e e1 ff ff       	call   f01000a0 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f0101f52:	68 63 4c 10 f0       	push   $0xf0104c63
f0101f57:	68 71 4a 10 f0       	push   $0xf0104a71
f0101f5c:	68 84 03 00 00       	push   $0x384
f0101f61:	68 4b 4a 10 f0       	push   $0xf0104a4b
f0101f66:	e8 35 e1 ff ff       	call   f01000a0 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101f6b:	68 04 50 10 f0       	push   $0xf0105004
f0101f70:	68 71 4a 10 f0       	push   $0xf0104a71
f0101f75:	68 87 03 00 00       	push   $0x387
f0101f7a:	68 4b 4a 10 f0       	push   $0xf0104a4b
f0101f7f:	e8 1c e1 ff ff       	call   f01000a0 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0101f84:	68 24 51 10 f0       	push   $0xf0105124
f0101f89:	68 71 4a 10 f0       	push   $0xf0104a71
f0101f8e:	68 88 03 00 00       	push   $0x388
f0101f93:	68 4b 4a 10 f0       	push   $0xf0104a4b
f0101f98:	e8 03 e1 ff ff       	call   f01000a0 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101f9d:	68 58 51 10 f0       	push   $0xf0105158
f0101fa2:	68 71 4a 10 f0       	push   $0xf0104a71
f0101fa7:	68 89 03 00 00       	push   $0x389
f0101fac:	68 4b 4a 10 f0       	push   $0xf0104a4b
f0101fb1:	e8 ea e0 ff ff       	call   f01000a0 <_panic>
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0101fb6:	68 90 51 10 f0       	push   $0xf0105190
f0101fbb:	68 71 4a 10 f0       	push   $0xf0104a71
f0101fc0:	68 8c 03 00 00       	push   $0x38c
f0101fc5:	68 4b 4a 10 f0       	push   $0xf0104a4b
f0101fca:	e8 d1 e0 ff ff       	call   f01000a0 <_panic>
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0101fcf:	68 c8 51 10 f0       	push   $0xf01051c8
f0101fd4:	68 71 4a 10 f0       	push   $0xf0104a71
f0101fd9:	68 8f 03 00 00       	push   $0x38f
f0101fde:	68 4b 4a 10 f0       	push   $0xf0104a4b
f0101fe3:	e8 b8 e0 ff ff       	call   f01000a0 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101fe8:	68 58 51 10 f0       	push   $0xf0105158
f0101fed:	68 71 4a 10 f0       	push   $0xf0104a71
f0101ff2:	68 90 03 00 00       	push   $0x390
f0101ff7:	68 4b 4a 10 f0       	push   $0xf0104a4b
f0101ffc:	e8 9f e0 ff ff       	call   f01000a0 <_panic>
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0102001:	68 04 52 10 f0       	push   $0xf0105204
f0102006:	68 71 4a 10 f0       	push   $0xf0104a71
f010200b:	68 93 03 00 00       	push   $0x393
f0102010:	68 4b 4a 10 f0       	push   $0xf0104a4b
f0102015:	e8 86 e0 ff ff       	call   f01000a0 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f010201a:	68 30 52 10 f0       	push   $0xf0105230
f010201f:	68 71 4a 10 f0       	push   $0xf0104a71
f0102024:	68 94 03 00 00       	push   $0x394
f0102029:	68 4b 4a 10 f0       	push   $0xf0104a4b
f010202e:	e8 6d e0 ff ff       	call   f01000a0 <_panic>
	assert(pp1->pp_ref == 2);
f0102033:	68 79 4c 10 f0       	push   $0xf0104c79
f0102038:	68 71 4a 10 f0       	push   $0xf0104a71
f010203d:	68 96 03 00 00       	push   $0x396
f0102042:	68 4b 4a 10 f0       	push   $0xf0104a4b
f0102047:	e8 54 e0 ff ff       	call   f01000a0 <_panic>
	assert(pp2->pp_ref == 0);
f010204c:	68 8a 4c 10 f0       	push   $0xf0104c8a
f0102051:	68 71 4a 10 f0       	push   $0xf0104a71
f0102056:	68 97 03 00 00       	push   $0x397
f010205b:	68 4b 4a 10 f0       	push   $0xf0104a4b
f0102060:	e8 3b e0 ff ff       	call   f01000a0 <_panic>
	assert((pp = page_alloc(0)) && pp == pp2);
f0102065:	68 60 52 10 f0       	push   $0xf0105260
f010206a:	68 71 4a 10 f0       	push   $0xf0104a71
f010206f:	68 9a 03 00 00       	push   $0x39a
f0102074:	68 4b 4a 10 f0       	push   $0xf0104a4b
f0102079:	e8 22 e0 ff ff       	call   f01000a0 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f010207e:	68 84 52 10 f0       	push   $0xf0105284
f0102083:	68 71 4a 10 f0       	push   $0xf0104a71
f0102088:	68 9e 03 00 00       	push   $0x39e
f010208d:	68 4b 4a 10 f0       	push   $0xf0104a4b
f0102092:	e8 09 e0 ff ff       	call   f01000a0 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102097:	68 30 52 10 f0       	push   $0xf0105230
f010209c:	68 71 4a 10 f0       	push   $0xf0104a71
f01020a1:	68 9f 03 00 00       	push   $0x39f
f01020a6:	68 4b 4a 10 f0       	push   $0xf0104a4b
f01020ab:	e8 f0 df ff ff       	call   f01000a0 <_panic>
	assert(pp1->pp_ref == 1);
f01020b0:	68 30 4c 10 f0       	push   $0xf0104c30
f01020b5:	68 71 4a 10 f0       	push   $0xf0104a71
f01020ba:	68 a0 03 00 00       	push   $0x3a0
f01020bf:	68 4b 4a 10 f0       	push   $0xf0104a4b
f01020c4:	e8 d7 df ff ff       	call   f01000a0 <_panic>
	assert(pp2->pp_ref == 0);
f01020c9:	68 8a 4c 10 f0       	push   $0xf0104c8a
f01020ce:	68 71 4a 10 f0       	push   $0xf0104a71
f01020d3:	68 a1 03 00 00       	push   $0x3a1
f01020d8:	68 4b 4a 10 f0       	push   $0xf0104a4b
f01020dd:	e8 be df ff ff       	call   f01000a0 <_panic>
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f01020e2:	68 a8 52 10 f0       	push   $0xf01052a8
f01020e7:	68 71 4a 10 f0       	push   $0xf0104a71
f01020ec:	68 a4 03 00 00       	push   $0x3a4
f01020f1:	68 4b 4a 10 f0       	push   $0xf0104a4b
f01020f6:	e8 a5 df ff ff       	call   f01000a0 <_panic>
	assert(pp1->pp_ref);
f01020fb:	68 9b 4c 10 f0       	push   $0xf0104c9b
f0102100:	68 71 4a 10 f0       	push   $0xf0104a71
f0102105:	68 a5 03 00 00       	push   $0x3a5
f010210a:	68 4b 4a 10 f0       	push   $0xf0104a4b
f010210f:	e8 8c df ff ff       	call   f01000a0 <_panic>
	assert(pp1->pp_link == NULL);
f0102114:	68 a7 4c 10 f0       	push   $0xf0104ca7
f0102119:	68 71 4a 10 f0       	push   $0xf0104a71
f010211e:	68 a6 03 00 00       	push   $0x3a6
f0102123:	68 4b 4a 10 f0       	push   $0xf0104a4b
f0102128:	e8 73 df ff ff       	call   f01000a0 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f010212d:	68 84 52 10 f0       	push   $0xf0105284
f0102132:	68 71 4a 10 f0       	push   $0xf0104a71
f0102137:	68 aa 03 00 00       	push   $0x3aa
f010213c:	68 4b 4a 10 f0       	push   $0xf0104a4b
f0102141:	e8 5a df ff ff       	call   f01000a0 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0102146:	68 e0 52 10 f0       	push   $0xf01052e0
f010214b:	68 71 4a 10 f0       	push   $0xf0104a71
f0102150:	68 ab 03 00 00       	push   $0x3ab
f0102155:	68 4b 4a 10 f0       	push   $0xf0104a4b
f010215a:	e8 41 df ff ff       	call   f01000a0 <_panic>
	assert(pp1->pp_ref == 0);
f010215f:	68 bc 4c 10 f0       	push   $0xf0104cbc
f0102164:	68 71 4a 10 f0       	push   $0xf0104a71
f0102169:	68 ac 03 00 00       	push   $0x3ac
f010216e:	68 4b 4a 10 f0       	push   $0xf0104a4b
f0102173:	e8 28 df ff ff       	call   f01000a0 <_panic>
	assert(pp2->pp_ref == 0);
f0102178:	68 8a 4c 10 f0       	push   $0xf0104c8a
f010217d:	68 71 4a 10 f0       	push   $0xf0104a71
f0102182:	68 ad 03 00 00       	push   $0x3ad
f0102187:	68 4b 4a 10 f0       	push   $0xf0104a4b
f010218c:	e8 0f df ff ff       	call   f01000a0 <_panic>
	assert((pp = page_alloc(0)) && pp == pp1);
f0102191:	68 08 53 10 f0       	push   $0xf0105308
f0102196:	68 71 4a 10 f0       	push   $0xf0104a71
f010219b:	68 b0 03 00 00       	push   $0x3b0
f01021a0:	68 4b 4a 10 f0       	push   $0xf0104a4b
f01021a5:	e8 f6 de ff ff       	call   f01000a0 <_panic>
	assert(!page_alloc(0));
f01021aa:	68 de 4b 10 f0       	push   $0xf0104bde
f01021af:	68 71 4a 10 f0       	push   $0xf0104a71
f01021b4:	68 b3 03 00 00       	push   $0x3b3
f01021b9:	68 4b 4a 10 f0       	push   $0xf0104a4b
f01021be:	e8 dd de ff ff       	call   f01000a0 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01021c3:	68 ac 4f 10 f0       	push   $0xf0104fac
f01021c8:	68 71 4a 10 f0       	push   $0xf0104a71
f01021cd:	68 b6 03 00 00       	push   $0x3b6
f01021d2:	68 4b 4a 10 f0       	push   $0xf0104a4b
f01021d7:	e8 c4 de ff ff       	call   f01000a0 <_panic>
	assert(pp0->pp_ref == 1);
f01021dc:	68 41 4c 10 f0       	push   $0xf0104c41
f01021e1:	68 71 4a 10 f0       	push   $0xf0104a71
f01021e6:	68 b8 03 00 00       	push   $0x3b8
f01021eb:	68 4b 4a 10 f0       	push   $0xf0104a4b
f01021f0:	e8 ab de ff ff       	call   f01000a0 <_panic>
f01021f5:	ff 75 d0             	pushl  -0x30(%ebp)
f01021f8:	68 48 4d 10 f0       	push   $0xf0104d48
f01021fd:	68 bf 03 00 00       	push   $0x3bf
f0102202:	68 4b 4a 10 f0       	push   $0xf0104a4b
f0102207:	e8 94 de ff ff       	call   f01000a0 <_panic>
	assert(ptep == ptep1 + PTX(va));
f010220c:	68 cd 4c 10 f0       	push   $0xf0104ccd
f0102211:	68 71 4a 10 f0       	push   $0xf0104a71
f0102216:	68 c0 03 00 00       	push   $0x3c0
f010221b:	68 4b 4a 10 f0       	push   $0xf0104a4b
f0102220:	e8 7b de ff ff       	call   f01000a0 <_panic>
f0102225:	52                   	push   %edx
f0102226:	68 48 4d 10 f0       	push   $0xf0104d48
f010222b:	6a 56                	push   $0x56
f010222d:	68 57 4a 10 f0       	push   $0xf0104a57
f0102232:	e8 69 de ff ff       	call   f01000a0 <_panic>
f0102237:	52                   	push   %edx
f0102238:	68 48 4d 10 f0       	push   $0xf0104d48
f010223d:	6a 56                	push   $0x56
f010223f:	68 57 4a 10 f0       	push   $0xf0104a57
f0102244:	e8 57 de ff ff       	call   f01000a0 <_panic>
		assert((ptep[i] & PTE_P) == 0);
f0102249:	68 e5 4c 10 f0       	push   $0xf0104ce5
f010224e:	68 71 4a 10 f0       	push   $0xf0104a71
f0102253:	68 ca 03 00 00       	push   $0x3ca
f0102258:	68 4b 4a 10 f0       	push   $0xf0104a4b
f010225d:	e8 3e de ff ff       	call   f01000a0 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102262:	50                   	push   %eax
f0102263:	68 b0 4e 10 f0       	push   $0xf0104eb0
f0102268:	68 c0 00 00 00       	push   $0xc0
f010226d:	68 4b 4a 10 f0       	push   $0xf0104a4b
f0102272:	e8 29 de ff ff       	call   f01000a0 <_panic>
f0102277:	50                   	push   %eax
f0102278:	68 b0 4e 10 f0       	push   $0xf0104eb0
f010227d:	68 c9 00 00 00       	push   $0xc9
f0102282:	68 4b 4a 10 f0       	push   $0xf0104a4b
f0102287:	e8 14 de ff ff       	call   f01000a0 <_panic>
f010228c:	50                   	push   %eax
f010228d:	68 b0 4e 10 f0       	push   $0xf0104eb0
f0102292:	68 d6 00 00 00       	push   $0xd6
f0102297:	68 4b 4a 10 f0       	push   $0xf0104a4b
f010229c:	e8 ff dd ff ff       	call   f01000a0 <_panic>
f01022a1:	56                   	push   %esi
f01022a2:	68 b0 4e 10 f0       	push   $0xf0104eb0
f01022a7:	68 08 03 00 00       	push   $0x308
f01022ac:	68 4b 4a 10 f0       	push   $0xf0104a4b
f01022b1:	e8 ea dd ff ff       	call   f01000a0 <_panic>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f01022b6:	68 2c 53 10 f0       	push   $0xf010532c
f01022bb:	68 71 4a 10 f0       	push   $0xf0104a71
f01022c0:	68 08 03 00 00       	push   $0x308
f01022c5:	68 4b 4a 10 f0       	push   $0xf0104a4b
f01022ca:	e8 d1 dd ff ff       	call   f01000a0 <_panic>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f01022cf:	a1 48 0d 1b f0       	mov    0xf01b0d48,%eax
f01022d4:	89 45 cc             	mov    %eax,-0x34(%ebp)
	if ((uint32_t)kva < KERNBASE)
f01022d7:	89 45 d0             	mov    %eax,-0x30(%ebp)
f01022da:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
f01022df:	8d b0 00 00 40 21    	lea    0x21400000(%eax),%esi
f01022e5:	89 da                	mov    %ebx,%edx
f01022e7:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01022ea:	e8 d3 e5 ff ff       	call   f01008c2 <check_va2pa>
f01022ef:	81 7d d0 ff ff ff ef 	cmpl   $0xefffffff,-0x30(%ebp)
f01022f6:	76 3b                	jbe    f0102333 <mem_init+0x13d3>
f01022f8:	8d 14 1e             	lea    (%esi,%ebx,1),%edx
f01022fb:	39 c2                	cmp    %eax,%edx
f01022fd:	75 4b                	jne    f010234a <mem_init+0x13ea>
f01022ff:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	for (i = 0; i < n; i += PGSIZE)
f0102305:	81 fb 00 80 c1 ee    	cmp    $0xeec18000,%ebx
f010230b:	75 d8                	jne    f01022e5 <mem_init+0x1385>
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f010230d:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f0102310:	c1 e6 0c             	shl    $0xc,%esi
f0102313:	89 fb                	mov    %edi,%ebx
f0102315:	39 f3                	cmp    %esi,%ebx
f0102317:	73 63                	jae    f010237c <mem_init+0x141c>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0102319:	8d 93 00 00 00 f0    	lea    -0x10000000(%ebx),%edx
f010231f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102322:	e8 9b e5 ff ff       	call   f01008c2 <check_va2pa>
f0102327:	39 c3                	cmp    %eax,%ebx
f0102329:	75 38                	jne    f0102363 <mem_init+0x1403>
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f010232b:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102331:	eb e2                	jmp    f0102315 <mem_init+0x13b5>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102333:	ff 75 cc             	pushl  -0x34(%ebp)
f0102336:	68 b0 4e 10 f0       	push   $0xf0104eb0
f010233b:	68 0d 03 00 00       	push   $0x30d
f0102340:	68 4b 4a 10 f0       	push   $0xf0104a4b
f0102345:	e8 56 dd ff ff       	call   f01000a0 <_panic>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f010234a:	68 60 53 10 f0       	push   $0xf0105360
f010234f:	68 71 4a 10 f0       	push   $0xf0104a71
f0102354:	68 0d 03 00 00       	push   $0x30d
f0102359:	68 4b 4a 10 f0       	push   $0xf0104a4b
f010235e:	e8 3d dd ff ff       	call   f01000a0 <_panic>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0102363:	68 94 53 10 f0       	push   $0xf0105394
f0102368:	68 71 4a 10 f0       	push   $0xf0104a71
f010236d:	68 11 03 00 00       	push   $0x311
f0102372:	68 4b 4a 10 f0       	push   $0xf0104a4b
f0102377:	e8 24 dd ff ff       	call   f01000a0 <_panic>
f010237c:	bb 00 80 ff ef       	mov    $0xefff8000,%ebx
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f0102381:	b8 00 20 11 f0       	mov    $0xf0112000,%eax
f0102386:	8d b0 00 80 00 20    	lea    0x20008000(%eax),%esi
f010238c:	89 da                	mov    %ebx,%edx
f010238e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102391:	e8 2c e5 ff ff       	call   f01008c2 <check_va2pa>
f0102396:	89 c2                	mov    %eax,%edx
f0102398:	8d 04 1e             	lea    (%esi,%ebx,1),%eax
f010239b:	39 c2                	cmp    %eax,%edx
f010239d:	75 25                	jne    f01023c4 <mem_init+0x1464>
f010239f:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
f01023a5:	81 fb 00 00 00 f0    	cmp    $0xf0000000,%ebx
f01023ab:	75 df                	jne    f010238c <mem_init+0x142c>
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f01023ad:	ba 00 00 c0 ef       	mov    $0xefc00000,%edx
f01023b2:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01023b5:	e8 08 e5 ff ff       	call   f01008c2 <check_va2pa>
f01023ba:	83 f8 ff             	cmp    $0xffffffff,%eax
f01023bd:	75 1e                	jne    f01023dd <mem_init+0x147d>
f01023bf:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01023c2:	eb 5d                	jmp    f0102421 <mem_init+0x14c1>
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f01023c4:	68 bc 53 10 f0       	push   $0xf01053bc
f01023c9:	68 71 4a 10 f0       	push   $0xf0104a71
f01023ce:	68 15 03 00 00       	push   $0x315
f01023d3:	68 4b 4a 10 f0       	push   $0xf0104a4b
f01023d8:	e8 c3 dc ff ff       	call   f01000a0 <_panic>
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f01023dd:	68 04 54 10 f0       	push   $0xf0105404
f01023e2:	68 71 4a 10 f0       	push   $0xf0104a71
f01023e7:	68 16 03 00 00       	push   $0x316
f01023ec:	68 4b 4a 10 f0       	push   $0xf0104a4b
f01023f1:	e8 aa dc ff ff       	call   f01000a0 <_panic>
		switch (i) {
f01023f6:	81 ff bf 03 00 00    	cmp    $0x3bf,%edi
f01023fc:	75 23                	jne    f0102421 <mem_init+0x14c1>
			assert(pgdir[i] & PTE_P);
f01023fe:	f6 04 b8 01          	testb  $0x1,(%eax,%edi,4)
f0102402:	74 44                	je     f0102448 <mem_init+0x14e8>
	for (i = 0; i < NPDENTRIES; i++) {
f0102404:	47                   	inc    %edi
f0102405:	81 ff ff 03 00 00    	cmp    $0x3ff,%edi
f010240b:	0f 87 8f 00 00 00    	ja     f01024a0 <mem_init+0x1540>
		switch (i) {
f0102411:	81 ff bd 03 00 00    	cmp    $0x3bd,%edi
f0102417:	77 dd                	ja     f01023f6 <mem_init+0x1496>
f0102419:	81 ff ba 03 00 00    	cmp    $0x3ba,%edi
f010241f:	77 dd                	ja     f01023fe <mem_init+0x149e>
			if (i >= PDX(KERNBASE)) {
f0102421:	81 ff bf 03 00 00    	cmp    $0x3bf,%edi
f0102427:	77 38                	ja     f0102461 <mem_init+0x1501>
				assert(pgdir[i] == 0);
f0102429:	83 3c b8 00          	cmpl   $0x0,(%eax,%edi,4)
f010242d:	74 d5                	je     f0102404 <mem_init+0x14a4>
f010242f:	68 37 4d 10 f0       	push   $0xf0104d37
f0102434:	68 71 4a 10 f0       	push   $0xf0104a71
f0102439:	68 26 03 00 00       	push   $0x326
f010243e:	68 4b 4a 10 f0       	push   $0xf0104a4b
f0102443:	e8 58 dc ff ff       	call   f01000a0 <_panic>
			assert(pgdir[i] & PTE_P);
f0102448:	68 15 4d 10 f0       	push   $0xf0104d15
f010244d:	68 71 4a 10 f0       	push   $0xf0104a71
f0102452:	68 1f 03 00 00       	push   $0x31f
f0102457:	68 4b 4a 10 f0       	push   $0xf0104a4b
f010245c:	e8 3f dc ff ff       	call   f01000a0 <_panic>
				assert(pgdir[i] & PTE_P);
f0102461:	8b 14 b8             	mov    (%eax,%edi,4),%edx
f0102464:	f6 c2 01             	test   $0x1,%dl
f0102467:	74 1e                	je     f0102487 <mem_init+0x1527>
				assert(pgdir[i] & PTE_W);
f0102469:	f6 c2 02             	test   $0x2,%dl
f010246c:	75 96                	jne    f0102404 <mem_init+0x14a4>
f010246e:	68 26 4d 10 f0       	push   $0xf0104d26
f0102473:	68 71 4a 10 f0       	push   $0xf0104a71
f0102478:	68 24 03 00 00       	push   $0x324
f010247d:	68 4b 4a 10 f0       	push   $0xf0104a4b
f0102482:	e8 19 dc ff ff       	call   f01000a0 <_panic>
				assert(pgdir[i] & PTE_P);
f0102487:	68 15 4d 10 f0       	push   $0xf0104d15
f010248c:	68 71 4a 10 f0       	push   $0xf0104a71
f0102491:	68 23 03 00 00       	push   $0x323
f0102496:	68 4b 4a 10 f0       	push   $0xf0104a4b
f010249b:	e8 00 dc ff ff       	call   f01000a0 <_panic>
	cprintf("check_kern_pgdir() succeeded!\n");
f01024a0:	83 ec 0c             	sub    $0xc,%esp
f01024a3:	68 34 54 10 f0       	push   $0xf0105434
f01024a8:	e8 a8 0a 00 00       	call   f0102f55 <cprintf>
	lcr3(PADDR(kern_pgdir));
f01024ad:	a1 0c 1a 1b f0       	mov    0xf01b1a0c,%eax
	if ((uint32_t)kva < KERNBASE)
f01024b2:	83 c4 10             	add    $0x10,%esp
f01024b5:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01024ba:	0f 86 06 02 00 00    	jbe    f01026c6 <mem_init+0x1766>
	return (physaddr_t)kva - KERNBASE;
f01024c0:	05 00 00 00 10       	add    $0x10000000,%eax
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f01024c5:	0f 22 d8             	mov    %eax,%cr3
	check_page_free_list(0);
f01024c8:	b8 00 00 00 00       	mov    $0x0,%eax
f01024cd:	e8 50 e4 ff ff       	call   f0100922 <check_page_free_list>
	asm volatile("movl %%cr0,%0" : "=r" (val));
f01024d2:	0f 20 c0             	mov    %cr0,%eax
	cr0 &= ~(CR0_TS|CR0_EM);
f01024d5:	83 e0 f3             	and    $0xfffffff3,%eax
f01024d8:	0d 23 00 05 80       	or     $0x80050023,%eax
	asm volatile("movl %0,%%cr0" : : "r" (val));
f01024dd:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01024e0:	83 ec 0c             	sub    $0xc,%esp
f01024e3:	6a 00                	push   $0x0
f01024e5:	e8 a8 e7 ff ff       	call   f0100c92 <page_alloc>
f01024ea:	89 c3                	mov    %eax,%ebx
f01024ec:	83 c4 10             	add    $0x10,%esp
f01024ef:	85 c0                	test   %eax,%eax
f01024f1:	0f 84 e4 01 00 00    	je     f01026db <mem_init+0x177b>
	assert((pp1 = page_alloc(0)));
f01024f7:	83 ec 0c             	sub    $0xc,%esp
f01024fa:	6a 00                	push   $0x0
f01024fc:	e8 91 e7 ff ff       	call   f0100c92 <page_alloc>
f0102501:	89 c7                	mov    %eax,%edi
f0102503:	83 c4 10             	add    $0x10,%esp
f0102506:	85 c0                	test   %eax,%eax
f0102508:	0f 84 e6 01 00 00    	je     f01026f4 <mem_init+0x1794>
	assert((pp2 = page_alloc(0)));
f010250e:	83 ec 0c             	sub    $0xc,%esp
f0102511:	6a 00                	push   $0x0
f0102513:	e8 7a e7 ff ff       	call   f0100c92 <page_alloc>
f0102518:	89 c6                	mov    %eax,%esi
f010251a:	83 c4 10             	add    $0x10,%esp
f010251d:	85 c0                	test   %eax,%eax
f010251f:	0f 84 e8 01 00 00    	je     f010270d <mem_init+0x17ad>
	page_free(pp0);
f0102525:	83 ec 0c             	sub    $0xc,%esp
f0102528:	53                   	push   %ebx
f0102529:	e8 d9 e7 ff ff       	call   f0100d07 <page_free>
	return (pp - pages) << PGSHIFT;
f010252e:	89 f8                	mov    %edi,%eax
f0102530:	2b 05 10 1a 1b f0    	sub    0xf01b1a10,%eax
f0102536:	c1 f8 03             	sar    $0x3,%eax
f0102539:	89 c2                	mov    %eax,%edx
f010253b:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f010253e:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0102543:	83 c4 10             	add    $0x10,%esp
f0102546:	3b 05 08 1a 1b f0    	cmp    0xf01b1a08,%eax
f010254c:	0f 83 d4 01 00 00    	jae    f0102726 <mem_init+0x17c6>
	memset(page2kva(pp1), 1, PGSIZE);
f0102552:	83 ec 04             	sub    $0x4,%esp
f0102555:	68 00 10 00 00       	push   $0x1000
f010255a:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f010255c:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f0102562:	52                   	push   %edx
f0102563:	e8 19 1c 00 00       	call   f0104181 <memset>
	return (pp - pages) << PGSHIFT;
f0102568:	89 f0                	mov    %esi,%eax
f010256a:	2b 05 10 1a 1b f0    	sub    0xf01b1a10,%eax
f0102570:	c1 f8 03             	sar    $0x3,%eax
f0102573:	89 c2                	mov    %eax,%edx
f0102575:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0102578:	25 ff ff 0f 00       	and    $0xfffff,%eax
f010257d:	83 c4 10             	add    $0x10,%esp
f0102580:	3b 05 08 1a 1b f0    	cmp    0xf01b1a08,%eax
f0102586:	0f 83 ac 01 00 00    	jae    f0102738 <mem_init+0x17d8>
	memset(page2kva(pp2), 2, PGSIZE);
f010258c:	83 ec 04             	sub    $0x4,%esp
f010258f:	68 00 10 00 00       	push   $0x1000
f0102594:	6a 02                	push   $0x2
	return (void *)(pa + KERNBASE);
f0102596:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f010259c:	52                   	push   %edx
f010259d:	e8 df 1b 00 00       	call   f0104181 <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f01025a2:	6a 02                	push   $0x2
f01025a4:	68 00 10 00 00       	push   $0x1000
f01025a9:	57                   	push   %edi
f01025aa:	ff 35 0c 1a 1b f0    	pushl  0xf01b1a0c
f01025b0:	e8 2d e9 ff ff       	call   f0100ee2 <page_insert>
	assert(pp1->pp_ref == 1);
f01025b5:	83 c4 20             	add    $0x20,%esp
f01025b8:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f01025bd:	0f 85 87 01 00 00    	jne    f010274a <mem_init+0x17ea>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f01025c3:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f01025ca:	01 01 01 
f01025cd:	0f 85 90 01 00 00    	jne    f0102763 <mem_init+0x1803>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f01025d3:	6a 02                	push   $0x2
f01025d5:	68 00 10 00 00       	push   $0x1000
f01025da:	56                   	push   %esi
f01025db:	ff 35 0c 1a 1b f0    	pushl  0xf01b1a0c
f01025e1:	e8 fc e8 ff ff       	call   f0100ee2 <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f01025e6:	83 c4 10             	add    $0x10,%esp
f01025e9:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f01025f0:	02 02 02 
f01025f3:	0f 85 83 01 00 00    	jne    f010277c <mem_init+0x181c>
	assert(pp2->pp_ref == 1);
f01025f9:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f01025fe:	0f 85 91 01 00 00    	jne    f0102795 <mem_init+0x1835>
	assert(pp1->pp_ref == 0);
f0102604:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0102609:	0f 85 9f 01 00 00    	jne    f01027ae <mem_init+0x184e>
	*(uint32_t *)PGSIZE = 0x03030303U;
f010260f:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f0102616:	03 03 03 
	return (pp - pages) << PGSHIFT;
f0102619:	89 f0                	mov    %esi,%eax
f010261b:	2b 05 10 1a 1b f0    	sub    0xf01b1a10,%eax
f0102621:	c1 f8 03             	sar    $0x3,%eax
f0102624:	89 c2                	mov    %eax,%edx
f0102626:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0102629:	25 ff ff 0f 00       	and    $0xfffff,%eax
f010262e:	3b 05 08 1a 1b f0    	cmp    0xf01b1a08,%eax
f0102634:	0f 83 8d 01 00 00    	jae    f01027c7 <mem_init+0x1867>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f010263a:	81 ba 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%edx)
f0102641:	03 03 03 
f0102644:	0f 85 8f 01 00 00    	jne    f01027d9 <mem_init+0x1879>
	page_remove(kern_pgdir, (void*) PGSIZE);
f010264a:	83 ec 08             	sub    $0x8,%esp
f010264d:	68 00 10 00 00       	push   $0x1000
f0102652:	ff 35 0c 1a 1b f0    	pushl  0xf01b1a0c
f0102658:	e8 4a e8 ff ff       	call   f0100ea7 <page_remove>
	assert(pp2->pp_ref == 0);
f010265d:	83 c4 10             	add    $0x10,%esp
f0102660:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102665:	0f 85 87 01 00 00    	jne    f01027f2 <mem_init+0x1892>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f010266b:	8b 0d 0c 1a 1b f0    	mov    0xf01b1a0c,%ecx
f0102671:	8b 11                	mov    (%ecx),%edx
f0102673:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
	return (pp - pages) << PGSHIFT;
f0102679:	89 d8                	mov    %ebx,%eax
f010267b:	2b 05 10 1a 1b f0    	sub    0xf01b1a10,%eax
f0102681:	c1 f8 03             	sar    $0x3,%eax
f0102684:	c1 e0 0c             	shl    $0xc,%eax
f0102687:	39 c2                	cmp    %eax,%edx
f0102689:	0f 85 7c 01 00 00    	jne    f010280b <mem_init+0x18ab>
	kern_pgdir[0] = 0;
f010268f:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0102695:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f010269a:	0f 85 84 01 00 00    	jne    f0102824 <mem_init+0x18c4>
	pp0->pp_ref = 0;
f01026a0:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)

	// free the pages we took
	page_free(pp0);
f01026a6:	83 ec 0c             	sub    $0xc,%esp
f01026a9:	53                   	push   %ebx
f01026aa:	e8 58 e6 ff ff       	call   f0100d07 <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f01026af:	c7 04 24 c8 54 10 f0 	movl   $0xf01054c8,(%esp)
f01026b6:	e8 9a 08 00 00       	call   f0102f55 <cprintf>
}
f01026bb:	83 c4 10             	add    $0x10,%esp
f01026be:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01026c1:	5b                   	pop    %ebx
f01026c2:	5e                   	pop    %esi
f01026c3:	5f                   	pop    %edi
f01026c4:	5d                   	pop    %ebp
f01026c5:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01026c6:	50                   	push   %eax
f01026c7:	68 b0 4e 10 f0       	push   $0xf0104eb0
f01026cc:	68 ec 00 00 00       	push   $0xec
f01026d1:	68 4b 4a 10 f0       	push   $0xf0104a4b
f01026d6:	e8 c5 d9 ff ff       	call   f01000a0 <_panic>
	assert((pp0 = page_alloc(0)));
f01026db:	68 33 4b 10 f0       	push   $0xf0104b33
f01026e0:	68 71 4a 10 f0       	push   $0xf0104a71
f01026e5:	68 e5 03 00 00       	push   $0x3e5
f01026ea:	68 4b 4a 10 f0       	push   $0xf0104a4b
f01026ef:	e8 ac d9 ff ff       	call   f01000a0 <_panic>
	assert((pp1 = page_alloc(0)));
f01026f4:	68 49 4b 10 f0       	push   $0xf0104b49
f01026f9:	68 71 4a 10 f0       	push   $0xf0104a71
f01026fe:	68 e6 03 00 00       	push   $0x3e6
f0102703:	68 4b 4a 10 f0       	push   $0xf0104a4b
f0102708:	e8 93 d9 ff ff       	call   f01000a0 <_panic>
	assert((pp2 = page_alloc(0)));
f010270d:	68 5f 4b 10 f0       	push   $0xf0104b5f
f0102712:	68 71 4a 10 f0       	push   $0xf0104a71
f0102717:	68 e7 03 00 00       	push   $0x3e7
f010271c:	68 4b 4a 10 f0       	push   $0xf0104a4b
f0102721:	e8 7a d9 ff ff       	call   f01000a0 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102726:	52                   	push   %edx
f0102727:	68 48 4d 10 f0       	push   $0xf0104d48
f010272c:	6a 56                	push   $0x56
f010272e:	68 57 4a 10 f0       	push   $0xf0104a57
f0102733:	e8 68 d9 ff ff       	call   f01000a0 <_panic>
f0102738:	52                   	push   %edx
f0102739:	68 48 4d 10 f0       	push   $0xf0104d48
f010273e:	6a 56                	push   $0x56
f0102740:	68 57 4a 10 f0       	push   $0xf0104a57
f0102745:	e8 56 d9 ff ff       	call   f01000a0 <_panic>
	assert(pp1->pp_ref == 1);
f010274a:	68 30 4c 10 f0       	push   $0xf0104c30
f010274f:	68 71 4a 10 f0       	push   $0xf0104a71
f0102754:	68 ec 03 00 00       	push   $0x3ec
f0102759:	68 4b 4a 10 f0       	push   $0xf0104a4b
f010275e:	e8 3d d9 ff ff       	call   f01000a0 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102763:	68 54 54 10 f0       	push   $0xf0105454
f0102768:	68 71 4a 10 f0       	push   $0xf0104a71
f010276d:	68 ed 03 00 00       	push   $0x3ed
f0102772:	68 4b 4a 10 f0       	push   $0xf0104a4b
f0102777:	e8 24 d9 ff ff       	call   f01000a0 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f010277c:	68 78 54 10 f0       	push   $0xf0105478
f0102781:	68 71 4a 10 f0       	push   $0xf0104a71
f0102786:	68 ef 03 00 00       	push   $0x3ef
f010278b:	68 4b 4a 10 f0       	push   $0xf0104a4b
f0102790:	e8 0b d9 ff ff       	call   f01000a0 <_panic>
	assert(pp2->pp_ref == 1);
f0102795:	68 52 4c 10 f0       	push   $0xf0104c52
f010279a:	68 71 4a 10 f0       	push   $0xf0104a71
f010279f:	68 f0 03 00 00       	push   $0x3f0
f01027a4:	68 4b 4a 10 f0       	push   $0xf0104a4b
f01027a9:	e8 f2 d8 ff ff       	call   f01000a0 <_panic>
	assert(pp1->pp_ref == 0);
f01027ae:	68 bc 4c 10 f0       	push   $0xf0104cbc
f01027b3:	68 71 4a 10 f0       	push   $0xf0104a71
f01027b8:	68 f1 03 00 00       	push   $0x3f1
f01027bd:	68 4b 4a 10 f0       	push   $0xf0104a4b
f01027c2:	e8 d9 d8 ff ff       	call   f01000a0 <_panic>
f01027c7:	52                   	push   %edx
f01027c8:	68 48 4d 10 f0       	push   $0xf0104d48
f01027cd:	6a 56                	push   $0x56
f01027cf:	68 57 4a 10 f0       	push   $0xf0104a57
f01027d4:	e8 c7 d8 ff ff       	call   f01000a0 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f01027d9:	68 9c 54 10 f0       	push   $0xf010549c
f01027de:	68 71 4a 10 f0       	push   $0xf0104a71
f01027e3:	68 f3 03 00 00       	push   $0x3f3
f01027e8:	68 4b 4a 10 f0       	push   $0xf0104a4b
f01027ed:	e8 ae d8 ff ff       	call   f01000a0 <_panic>
	assert(pp2->pp_ref == 0);
f01027f2:	68 8a 4c 10 f0       	push   $0xf0104c8a
f01027f7:	68 71 4a 10 f0       	push   $0xf0104a71
f01027fc:	68 f5 03 00 00       	push   $0x3f5
f0102801:	68 4b 4a 10 f0       	push   $0xf0104a4b
f0102806:	e8 95 d8 ff ff       	call   f01000a0 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f010280b:	68 ac 4f 10 f0       	push   $0xf0104fac
f0102810:	68 71 4a 10 f0       	push   $0xf0104a71
f0102815:	68 f8 03 00 00       	push   $0x3f8
f010281a:	68 4b 4a 10 f0       	push   $0xf0104a4b
f010281f:	e8 7c d8 ff ff       	call   f01000a0 <_panic>
	assert(pp0->pp_ref == 1);
f0102824:	68 41 4c 10 f0       	push   $0xf0104c41
f0102829:	68 71 4a 10 f0       	push   $0xf0104a71
f010282e:	68 fa 03 00 00       	push   $0x3fa
f0102833:	68 4b 4a 10 f0       	push   $0xf0104a4b
f0102838:	e8 63 d8 ff ff       	call   f01000a0 <_panic>

f010283d <tlb_invalidate>:
{
f010283d:	55                   	push   %ebp
f010283e:	89 e5                	mov    %esp,%ebp
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0102840:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102843:	0f 01 38             	invlpg (%eax)
}
f0102846:	5d                   	pop    %ebp
f0102847:	c3                   	ret    

f0102848 <user_mem_check>:
}
f0102848:	b8 00 00 00 00       	mov    $0x0,%eax
f010284d:	c3                   	ret    

f010284e <user_mem_assert>:
}
f010284e:	c3                   	ret    

f010284f <region_alloc>:
// Pages should be writable by user and kernel.
// Panic if any allocation attempt fails.
//
static void
region_alloc(struct Env * e, void *va, size_t len)
{
f010284f:	55                   	push   %ebp
f0102850:	89 e5                	mov    %esp,%ebp
f0102852:	57                   	push   %edi
f0102853:	56                   	push   %esi
f0102854:	53                   	push   %ebx
f0102855:	83 ec 0c             	sub    $0xc,%esp
f0102858:	89 c7                	mov    %eax,%edi
	//
	// Hint: It is easier to use region_alloc if the caller can pass
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
	char *start_address = ROUNDDOWN(va, PGSIZE);
f010285a:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0102860:	89 d3                	mov    %edx,%ebx
	char *end_address = ROUNDUP(len, PGSIZE) + start_address;
f0102862:	81 c1 ff 0f 00 00    	add    $0xfff,%ecx
f0102868:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f010286e:	8d 34 0a             	lea    (%edx,%ecx,1),%esi
	char *current_address = start_address;
	struct PageInfo *p;

	while (current_address < end_address)
f0102871:	39 f3                	cmp    %esi,%ebx
f0102873:	73 3f                	jae    f01028b4 <region_alloc+0x65>
	{
		if (!(p = page_alloc(0)))
f0102875:	83 ec 0c             	sub    $0xc,%esp
f0102878:	6a 00                	push   $0x0
f010287a:	e8 13 e4 ff ff       	call   f0100c92 <page_alloc>
f010287f:	83 c4 10             	add    $0x10,%esp
f0102882:	85 c0                	test   %eax,%eax
f0102884:	74 17                	je     f010289d <region_alloc+0x4e>
			panic("Region Allocation for env %d failed", e->env_id);
		page_insert(e->env_pgdir, p, current_address, PTE_U | PTE_W);
f0102886:	6a 06                	push   $0x6
f0102888:	53                   	push   %ebx
f0102889:	50                   	push   %eax
f010288a:	ff 77 5c             	pushl  0x5c(%edi)
f010288d:	e8 50 e6 ff ff       	call   f0100ee2 <page_insert>
		current_address += PGSIZE;
f0102892:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102898:	83 c4 10             	add    $0x10,%esp
f010289b:	eb d4                	jmp    f0102871 <region_alloc+0x22>
			panic("Region Allocation for env %d failed", e->env_id);
f010289d:	ff 77 48             	pushl  0x48(%edi)
f01028a0:	68 f4 54 10 f0       	push   $0xf01054f4
f01028a5:	68 24 01 00 00       	push   $0x124
f01028aa:	68 4e 55 10 f0       	push   $0xf010554e
f01028af:	e8 ec d7 ff ff       	call   f01000a0 <_panic>
	}
}
f01028b4:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01028b7:	5b                   	pop    %ebx
f01028b8:	5e                   	pop    %esi
f01028b9:	5f                   	pop    %edi
f01028ba:	5d                   	pop    %ebp
f01028bb:	c3                   	ret    

f01028bc <envid2env>:
{
f01028bc:	55                   	push   %ebp
f01028bd:	89 e5                	mov    %esp,%ebp
f01028bf:	53                   	push   %ebx
f01028c0:	8b 45 08             	mov    0x8(%ebp),%eax
f01028c3:	8b 4d 10             	mov    0x10(%ebp),%ecx
	if (envid == 0) {
f01028c6:	85 c0                	test   %eax,%eax
f01028c8:	74 43                	je     f010290d <envid2env+0x51>
	e = &envs[ENVX(envid)];
f01028ca:	89 c3                	mov    %eax,%ebx
f01028cc:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
f01028d2:	8d 14 1b             	lea    (%ebx,%ebx,1),%edx
f01028d5:	01 da                	add    %ebx,%edx
f01028d7:	c1 e2 05             	shl    $0x5,%edx
f01028da:	03 15 48 0d 1b f0    	add    0xf01b0d48,%edx
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f01028e0:	83 7a 54 00          	cmpl   $0x0,0x54(%edx)
f01028e4:	74 34                	je     f010291a <envid2env+0x5e>
f01028e6:	39 42 48             	cmp    %eax,0x48(%edx)
f01028e9:	75 2f                	jne    f010291a <envid2env+0x5e>
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f01028eb:	84 c9                	test   %cl,%cl
f01028ed:	74 11                	je     f0102900 <envid2env+0x44>
f01028ef:	a1 44 0d 1b f0       	mov    0xf01b0d44,%eax
f01028f4:	39 d0                	cmp    %edx,%eax
f01028f6:	74 08                	je     f0102900 <envid2env+0x44>
f01028f8:	8b 40 48             	mov    0x48(%eax),%eax
f01028fb:	39 42 4c             	cmp    %eax,0x4c(%edx)
f01028fe:	75 2a                	jne    f010292a <envid2env+0x6e>
	*env_store = e;
f0102900:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102903:	89 10                	mov    %edx,(%eax)
	return 0;
f0102905:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010290a:	5b                   	pop    %ebx
f010290b:	5d                   	pop    %ebp
f010290c:	c3                   	ret    
		*env_store = curenv;
f010290d:	8b 15 44 0d 1b f0    	mov    0xf01b0d44,%edx
f0102913:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0102916:	89 11                	mov    %edx,(%ecx)
		return 0;
f0102918:	eb f0                	jmp    f010290a <envid2env+0x4e>
		*env_store = 0;
f010291a:	8b 45 0c             	mov    0xc(%ebp),%eax
f010291d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f0102923:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0102928:	eb e0                	jmp    f010290a <envid2env+0x4e>
		*env_store = 0;
f010292a:	8b 45 0c             	mov    0xc(%ebp),%eax
f010292d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f0102933:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0102938:	eb d0                	jmp    f010290a <envid2env+0x4e>

f010293a <env_init_percpu>:
	asm volatile("lgdt (%0)" : : "r" (p));
f010293a:	b8 00 c3 11 f0       	mov    $0xf011c300,%eax
f010293f:	0f 01 10             	lgdtl  (%eax)
	asm volatile("movw %%ax,%%gs" : : "a" (GD_UD|3));
f0102942:	b8 23 00 00 00       	mov    $0x23,%eax
f0102947:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" : : "a" (GD_UD|3));
f0102949:	8e e0                	mov    %eax,%fs
	asm volatile("movw %%ax,%%es" : : "a" (GD_KD));
f010294b:	b8 10 00 00 00       	mov    $0x10,%eax
f0102950:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" : : "a" (GD_KD));
f0102952:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" : : "a" (GD_KD));
f0102954:	8e d0                	mov    %eax,%ss
	asm volatile("ljmp %0,$1f\n 1:\n" : : "i"  (GD_KT));
f0102956:	ea 5d 29 10 f0 08 00 	ljmp   $0x8,$0xf010295d
	asm volatile("lldt %0" : : "r" (sel));
f010295d:	b8 00 00 00 00       	mov    $0x0,%eax
f0102962:	0f 00 d0             	lldt   %ax
}
f0102965:	c3                   	ret    

f0102966 <env_init>:
{
f0102966:	55                   	push   %ebp
f0102967:	89 e5                	mov    %esp,%ebp
f0102969:	56                   	push   %esi
f010296a:	53                   	push   %ebx
		envs[i].env_id = 0;
f010296b:	8b 35 48 0d 1b f0    	mov    0xf01b0d48,%esi
f0102971:	8d 86 a0 7f 01 00    	lea    0x17fa0(%esi),%eax
f0102977:	89 f3                	mov    %esi,%ebx
f0102979:	ba 00 00 00 00       	mov    $0x0,%edx
f010297e:	89 d1                	mov    %edx,%ecx
f0102980:	89 c2                	mov    %eax,%edx
f0102982:	c7 40 48 00 00 00 00 	movl   $0x0,0x48(%eax)
		envs[i].env_link = env_free_list;
f0102989:	89 48 44             	mov    %ecx,0x44(%eax)
f010298c:	83 e8 60             	sub    $0x60,%eax
	for(int i = NENV - 1; i >= 0; --i) {
f010298f:	39 da                	cmp    %ebx,%edx
f0102991:	75 eb                	jne    f010297e <env_init+0x18>
f0102993:	89 35 4c 0d 1b f0    	mov    %esi,0xf01b0d4c
	env_init_percpu();
f0102999:	e8 9c ff ff ff       	call   f010293a <env_init_percpu>
}
f010299e:	5b                   	pop    %ebx
f010299f:	5e                   	pop    %esi
f01029a0:	5d                   	pop    %ebp
f01029a1:	c3                   	ret    

f01029a2 <env_alloc>:
{
f01029a2:	55                   	push   %ebp
f01029a3:	89 e5                	mov    %esp,%ebp
f01029a5:	56                   	push   %esi
f01029a6:	53                   	push   %ebx
	if (!(e = env_free_list))
f01029a7:	8b 1d 4c 0d 1b f0    	mov    0xf01b0d4c,%ebx
f01029ad:	85 db                	test   %ebx,%ebx
f01029af:	0f 84 73 01 00 00    	je     f0102b28 <env_alloc+0x186>
	if (!(p = page_alloc(ALLOC_ZERO)))
f01029b5:	83 ec 0c             	sub    $0xc,%esp
f01029b8:	6a 01                	push   $0x1
f01029ba:	e8 d3 e2 ff ff       	call   f0100c92 <page_alloc>
f01029bf:	83 c4 10             	add    $0x10,%esp
f01029c2:	85 c0                	test   %eax,%eax
f01029c4:	0f 84 65 01 00 00    	je     f0102b2f <env_alloc+0x18d>
	p->pp_ref++;
f01029ca:	66 ff 40 04          	incw   0x4(%eax)
	return (pp - pages) << PGSHIFT;
f01029ce:	2b 05 10 1a 1b f0    	sub    0xf01b1a10,%eax
f01029d4:	c1 f8 03             	sar    $0x3,%eax
f01029d7:	89 c2                	mov    %eax,%edx
f01029d9:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f01029dc:	25 ff ff 0f 00       	and    $0xfffff,%eax
f01029e1:	3b 05 08 1a 1b f0    	cmp    0xf01b1a08,%eax
f01029e7:	0f 83 03 01 00 00    	jae    f0102af0 <env_alloc+0x14e>
	return (void *)(pa + KERNBASE);
f01029ed:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	e->env_pgdir = (pde_t *)page2kva(p);
f01029f3:	89 43 5c             	mov    %eax,0x5c(%ebx)
	memcpy(e->env_pgdir, kern_pgdir, PGSIZE);
f01029f6:	83 ec 04             	sub    $0x4,%esp
f01029f9:	68 00 10 00 00       	push   $0x1000
f01029fe:	ff 35 0c 1a 1b f0    	pushl  0xf01b1a0c
f0102a04:	50                   	push   %eax
f0102a05:	e8 22 18 00 00       	call   f010422c <memcpy>
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f0102a0a:	8b 43 5c             	mov    0x5c(%ebx),%eax
	if ((uint32_t)kva < KERNBASE)
f0102a0d:	83 c4 10             	add    $0x10,%esp
f0102a10:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102a15:	0f 86 e7 00 00 00    	jbe    f0102b02 <env_alloc+0x160>
	return (physaddr_t)kva - KERNBASE;
f0102a1b:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0102a21:	83 ca 05             	or     $0x5,%edx
f0102a24:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f0102a2a:	8b 43 48             	mov    0x48(%ebx),%eax
f0102a2d:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0) // Don't create a negative env_id.
f0102a32:	25 00 fc ff ff       	and    $0xfffffc00,%eax
f0102a37:	89 c2                	mov    %eax,%edx
f0102a39:	0f 8e d8 00 00 00    	jle    f0102b17 <env_alloc+0x175>
	e->env_id = generation | (e - envs);
f0102a3f:	89 d8                	mov    %ebx,%eax
f0102a41:	2b 05 48 0d 1b f0    	sub    0xf01b0d48,%eax
f0102a47:	c1 f8 05             	sar    $0x5,%eax
f0102a4a:	89 c1                	mov    %eax,%ecx
f0102a4c:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0102a4f:	8d 04 81             	lea    (%ecx,%eax,4),%eax
f0102a52:	8d 04 81             	lea    (%ecx,%eax,4),%eax
f0102a55:	89 c6                	mov    %eax,%esi
f0102a57:	c1 e6 08             	shl    $0x8,%esi
f0102a5a:	01 f0                	add    %esi,%eax
f0102a5c:	89 c6                	mov    %eax,%esi
f0102a5e:	c1 e6 10             	shl    $0x10,%esi
f0102a61:	01 f0                	add    %esi,%eax
f0102a63:	01 c0                	add    %eax,%eax
f0102a65:	01 c8                	add    %ecx,%eax
f0102a67:	09 d0                	or     %edx,%eax
f0102a69:	89 43 48             	mov    %eax,0x48(%ebx)
	e->env_parent_id = parent_id;
f0102a6c:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102a6f:	89 43 4c             	mov    %eax,0x4c(%ebx)
	e->env_type = ENV_TYPE_USER;
f0102a72:	c7 43 50 00 00 00 00 	movl   $0x0,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f0102a79:	c7 43 54 02 00 00 00 	movl   $0x2,0x54(%ebx)
	e->env_runs = 0;
f0102a80:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f0102a87:	83 ec 04             	sub    $0x4,%esp
f0102a8a:	6a 44                	push   $0x44
f0102a8c:	6a 00                	push   $0x0
f0102a8e:	53                   	push   %ebx
f0102a8f:	e8 ed 16 00 00       	call   f0104181 <memset>
	e->env_tf.tf_ds = GD_UD | 3;
f0102a94:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f0102a9a:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f0102aa0:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f0102aa6:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f0102aad:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)
	env_free_list = e->env_link;
f0102ab3:	8b 43 44             	mov    0x44(%ebx),%eax
f0102ab6:	a3 4c 0d 1b f0       	mov    %eax,0xf01b0d4c
	*newenv_store = e;
f0102abb:	8b 45 08             	mov    0x8(%ebp),%eax
f0102abe:	89 18                	mov    %ebx,(%eax)
	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0102ac0:	8b 53 48             	mov    0x48(%ebx),%edx
f0102ac3:	a1 44 0d 1b f0       	mov    0xf01b0d44,%eax
f0102ac8:	83 c4 10             	add    $0x10,%esp
f0102acb:	85 c0                	test   %eax,%eax
f0102acd:	74 52                	je     f0102b21 <env_alloc+0x17f>
f0102acf:	8b 40 48             	mov    0x48(%eax),%eax
f0102ad2:	83 ec 04             	sub    $0x4,%esp
f0102ad5:	52                   	push   %edx
f0102ad6:	50                   	push   %eax
f0102ad7:	68 59 55 10 f0       	push   $0xf0105559
f0102adc:	e8 74 04 00 00       	call   f0102f55 <cprintf>
	return 0;
f0102ae1:	83 c4 10             	add    $0x10,%esp
f0102ae4:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0102ae9:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0102aec:	5b                   	pop    %ebx
f0102aed:	5e                   	pop    %esi
f0102aee:	5d                   	pop    %ebp
f0102aef:	c3                   	ret    
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102af0:	52                   	push   %edx
f0102af1:	68 48 4d 10 f0       	push   $0xf0104d48
f0102af6:	6a 56                	push   $0x56
f0102af8:	68 57 4a 10 f0       	push   $0xf0104a57
f0102afd:	e8 9e d5 ff ff       	call   f01000a0 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102b02:	50                   	push   %eax
f0102b03:	68 b0 4e 10 f0       	push   $0xf0104eb0
f0102b08:	68 c7 00 00 00       	push   $0xc7
f0102b0d:	68 4e 55 10 f0       	push   $0xf010554e
f0102b12:	e8 89 d5 ff ff       	call   f01000a0 <_panic>
		generation = 1 << ENVGENSHIFT;
f0102b17:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102b1c:	e9 1e ff ff ff       	jmp    f0102a3f <env_alloc+0x9d>
	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0102b21:	b8 00 00 00 00       	mov    $0x0,%eax
f0102b26:	eb aa                	jmp    f0102ad2 <env_alloc+0x130>
		return -E_NO_FREE_ENV;
f0102b28:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f0102b2d:	eb ba                	jmp    f0102ae9 <env_alloc+0x147>
		return -E_NO_MEM;
f0102b2f:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f0102b34:	eb b3                	jmp    f0102ae9 <env_alloc+0x147>

f0102b36 <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, enum EnvType type)
{
f0102b36:	55                   	push   %ebp
f0102b37:	89 e5                	mov    %esp,%ebp
f0102b39:	57                   	push   %edi
f0102b3a:	56                   	push   %esi
f0102b3b:	53                   	push   %ebx
f0102b3c:	83 ec 34             	sub    $0x34,%esp
f0102b3f:	8b 7d 08             	mov    0x8(%ebp),%edi
	// LAB 3: Your code here.
	struct Env *env;
	int result;

	// Allocates a new env with env_alloc
	result = env_alloc(&env, 0);
f0102b42:	6a 00                	push   $0x0
f0102b44:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0102b47:	50                   	push   %eax
f0102b48:	e8 55 fe ff ff       	call   f01029a2 <env_alloc>
	if (result == -E_NO_FREE_ENV)
f0102b4d:	83 c4 10             	add    $0x10,%esp
f0102b50:	83 f8 fb             	cmp    $0xfffffffb,%eax
f0102b53:	74 42                	je     f0102b97 <env_create+0x61>
		panic("env_alloc: %e", result);

	if (result == -E_NO_MEM)
f0102b55:	83 f8 fc             	cmp    $0xfffffffc,%eax
f0102b58:	74 53                	je     f0102bad <env_create+0x77>
		panic("env_alloc: %e", result);

	env->env_parent_id = 0;
f0102b5a:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0102b5d:	c7 46 4c 00 00 00 00 	movl   $0x0,0x4c(%esi)
	env->env_type = type;
f0102b64:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102b67:	89 46 50             	mov    %eax,0x50(%esi)
	if (ELFHDR->e_magic != ELF_MAGIC)
f0102b6a:	81 3f 7f 45 4c 46    	cmpl   $0x464c457f,(%edi)
f0102b70:	75 51                	jne    f0102bc3 <env_create+0x8d>
	ph = (struct Proghdr *)((uint8_t *)ELFHDR + ELFHDR->e_phoff);
f0102b72:	89 fb                	mov    %edi,%ebx
f0102b74:	03 5f 1c             	add    0x1c(%edi),%ebx
	eph = ph + ELFHDR->e_phnum;
f0102b77:	0f b7 47 2c          	movzwl 0x2c(%edi),%eax
f0102b7b:	c1 e0 05             	shl    $0x5,%eax
f0102b7e:	01 d8                	add    %ebx,%eax
f0102b80:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	lcr3(PADDR(e->env_pgdir));
f0102b83:	8b 46 5c             	mov    0x5c(%esi),%eax
	if ((uint32_t)kva < KERNBASE)
f0102b86:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102b8b:	76 4d                	jbe    f0102bda <env_create+0xa4>
	return (physaddr_t)kva - KERNBASE;
f0102b8d:	05 00 00 00 10       	add    $0x10000000,%eax
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0102b92:	0f 22 d8             	mov    %eax,%cr3
}
f0102b95:	eb 5b                	jmp    f0102bf2 <env_create+0xbc>
		panic("env_alloc: %e", result);
f0102b97:	6a fb                	push   $0xfffffffb
f0102b99:	68 6e 55 10 f0       	push   $0xf010556e
f0102b9e:	68 93 01 00 00       	push   $0x193
f0102ba3:	68 4e 55 10 f0       	push   $0xf010554e
f0102ba8:	e8 f3 d4 ff ff       	call   f01000a0 <_panic>
		panic("env_alloc: %e", result);
f0102bad:	6a fc                	push   $0xfffffffc
f0102baf:	68 6e 55 10 f0       	push   $0xf010556e
f0102bb4:	68 96 01 00 00       	push   $0x196
f0102bb9:	68 4e 55 10 f0       	push   $0xf010554e
f0102bbe:	e8 dd d4 ff ff       	call   f01000a0 <_panic>
		panic("It is not a ELF format file!");
f0102bc3:	83 ec 04             	sub    $0x4,%esp
f0102bc6:	68 7c 55 10 f0       	push   $0xf010557c
f0102bcb:	68 65 01 00 00       	push   $0x165
f0102bd0:	68 4e 55 10 f0       	push   $0xf010554e
f0102bd5:	e8 c6 d4 ff ff       	call   f01000a0 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102bda:	50                   	push   %eax
f0102bdb:	68 b0 4e 10 f0       	push   $0xf0104eb0
f0102be0:	68 6c 01 00 00       	push   $0x16c
f0102be5:	68 4e 55 10 f0       	push   $0xf010554e
f0102bea:	e8 b1 d4 ff ff       	call   f01000a0 <_panic>
	for (; ph < eph; ph++)
f0102bef:	83 c3 20             	add    $0x20,%ebx
f0102bf2:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f0102bf5:	76 3b                	jbe    f0102c32 <env_create+0xfc>
		if (ph->p_type != ELF_PROG_LOAD)
f0102bf7:	83 3b 01             	cmpl   $0x1,(%ebx)
f0102bfa:	75 f3                	jne    f0102bef <env_create+0xb9>
		region_alloc(e, (void *)ph->p_va, ph->p_memsz);
f0102bfc:	8b 4b 14             	mov    0x14(%ebx),%ecx
f0102bff:	8b 53 08             	mov    0x8(%ebx),%edx
f0102c02:	89 f0                	mov    %esi,%eax
f0102c04:	e8 46 fc ff ff       	call   f010284f <region_alloc>
		memset((void *)ph->p_va, 0, ph->p_memsz);
f0102c09:	83 ec 04             	sub    $0x4,%esp
f0102c0c:	ff 73 14             	pushl  0x14(%ebx)
f0102c0f:	6a 00                	push   $0x0
f0102c11:	ff 73 08             	pushl  0x8(%ebx)
f0102c14:	e8 68 15 00 00       	call   f0104181 <memset>
		memcpy((void *)ph->p_va, binary + ph->p_offset, ph->p_filesz);
f0102c19:	83 c4 0c             	add    $0xc,%esp
f0102c1c:	ff 73 10             	pushl  0x10(%ebx)
f0102c1f:	89 f8                	mov    %edi,%eax
f0102c21:	03 43 04             	add    0x4(%ebx),%eax
f0102c24:	50                   	push   %eax
f0102c25:	ff 73 08             	pushl  0x8(%ebx)
f0102c28:	e8 ff 15 00 00       	call   f010422c <memcpy>
f0102c2d:	83 c4 10             	add    $0x10,%esp
f0102c30:	eb bd                	jmp    f0102bef <env_create+0xb9>
	e->env_tf.tf_eip = ELFHDR->e_entry;
f0102c32:	8b 47 18             	mov    0x18(%edi),%eax
f0102c35:	89 46 30             	mov    %eax,0x30(%esi)
	lcr3(PADDR(kern_pgdir));
f0102c38:	a1 0c 1a 1b f0       	mov    0xf01b1a0c,%eax
	if ((uint32_t)kva < KERNBASE)
f0102c3d:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102c42:	76 21                	jbe    f0102c65 <env_create+0x12f>
	return (physaddr_t)kva - KERNBASE;
f0102c44:	05 00 00 00 10       	add    $0x10000000,%eax
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0102c49:	0f 22 d8             	mov    %eax,%cr3
	region_alloc(e, (void *)USTACKTOP - PGSIZE, PGSIZE);
f0102c4c:	b9 00 10 00 00       	mov    $0x1000,%ecx
f0102c51:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f0102c56:	89 f0                	mov    %esi,%eax
f0102c58:	e8 f2 fb ff ff       	call   f010284f <region_alloc>

	//Loads the named elf binary into it with load_icode
	load_icode(env, binary);
}
f0102c5d:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102c60:	5b                   	pop    %ebx
f0102c61:	5e                   	pop    %esi
f0102c62:	5f                   	pop    %edi
f0102c63:	5d                   	pop    %ebp
f0102c64:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102c65:	50                   	push   %eax
f0102c66:	68 b0 4e 10 f0       	push   $0xf0104eb0
f0102c6b:	68 7e 01 00 00       	push   $0x17e
f0102c70:	68 4e 55 10 f0       	push   $0xf010554e
f0102c75:	e8 26 d4 ff ff       	call   f01000a0 <_panic>

f0102c7a <env_free>:
//
// Frees env e and all memory it uses.
//
void
	env_free(struct Env * e)
{
f0102c7a:	55                   	push   %ebp
f0102c7b:	89 e5                	mov    %esp,%ebp
f0102c7d:	57                   	push   %edi
f0102c7e:	56                   	push   %esi
f0102c7f:	53                   	push   %ebx
f0102c80:	83 ec 1c             	sub    $0x1c,%esp
f0102c83:	8b 7d 08             	mov    0x8(%ebp),%edi
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f0102c86:	8b 15 44 0d 1b f0    	mov    0xf01b0d44,%edx
f0102c8c:	39 fa                	cmp    %edi,%edx
f0102c8e:	74 28                	je     f0102cb8 <env_free+0x3e>
		lcr3(PADDR(kern_pgdir));

	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0102c90:	8b 4f 48             	mov    0x48(%edi),%ecx
f0102c93:	85 d2                	test   %edx,%edx
f0102c95:	74 4f                	je     f0102ce6 <env_free+0x6c>
f0102c97:	8b 42 48             	mov    0x48(%edx),%eax
f0102c9a:	83 ec 04             	sub    $0x4,%esp
f0102c9d:	51                   	push   %ecx
f0102c9e:	50                   	push   %eax
f0102c9f:	68 99 55 10 f0       	push   $0xf0105599
f0102ca4:	e8 ac 02 00 00       	call   f0102f55 <cprintf>
f0102ca9:	83 c4 10             	add    $0x10,%esp
f0102cac:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f0102cb3:	e9 b3 00 00 00       	jmp    f0102d6b <env_free+0xf1>
		lcr3(PADDR(kern_pgdir));
f0102cb8:	a1 0c 1a 1b f0       	mov    0xf01b1a0c,%eax
	if ((uint32_t)kva < KERNBASE)
f0102cbd:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102cc2:	76 0d                	jbe    f0102cd1 <env_free+0x57>
	return (physaddr_t)kva - KERNBASE;
f0102cc4:	05 00 00 00 10       	add    $0x10000000,%eax
f0102cc9:	0f 22 d8             	mov    %eax,%cr3
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0102ccc:	8b 4f 48             	mov    0x48(%edi),%ecx
f0102ccf:	eb c6                	jmp    f0102c97 <env_free+0x1d>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102cd1:	50                   	push   %eax
f0102cd2:	68 b0 4e 10 f0       	push   $0xf0104eb0
f0102cd7:	68 ad 01 00 00       	push   $0x1ad
f0102cdc:	68 4e 55 10 f0       	push   $0xf010554e
f0102ce1:	e8 ba d3 ff ff       	call   f01000a0 <_panic>
f0102ce6:	b8 00 00 00 00       	mov    $0x0,%eax
f0102ceb:	eb ad                	jmp    f0102c9a <env_free+0x20>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102ced:	56                   	push   %esi
f0102cee:	68 48 4d 10 f0       	push   $0xf0104d48
f0102cf3:	68 bd 01 00 00       	push   $0x1bd
f0102cf8:	68 4e 55 10 f0       	push   $0xf010554e
f0102cfd:	e8 9e d3 ff ff       	call   f01000a0 <_panic>

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++)
		{
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0102d02:	83 ec 08             	sub    $0x8,%esp
f0102d05:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0102d08:	09 d8                	or     %ebx,%eax
f0102d0a:	50                   	push   %eax
f0102d0b:	ff 77 5c             	pushl  0x5c(%edi)
f0102d0e:	e8 94 e1 ff ff       	call   f0100ea7 <page_remove>
f0102d13:	83 c4 10             	add    $0x10,%esp
f0102d16:	83 c6 04             	add    $0x4,%esi
f0102d19:	81 c3 00 10 00 00    	add    $0x1000,%ebx
		for (pteno = 0; pteno <= PTX(~0); pteno++)
f0102d1f:	81 fb 00 00 40 00    	cmp    $0x400000,%ebx
f0102d25:	74 07                	je     f0102d2e <env_free+0xb4>
			if (pt[pteno] & PTE_P)
f0102d27:	f6 06 01             	testb  $0x1,(%esi)
f0102d2a:	74 ea                	je     f0102d16 <env_free+0x9c>
f0102d2c:	eb d4                	jmp    f0102d02 <env_free+0x88>
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f0102d2e:	8b 47 5c             	mov    0x5c(%edi),%eax
f0102d31:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0102d34:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
	if (PGNUM(pa) >= npages)
f0102d3b:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0102d3e:	3b 05 08 1a 1b f0    	cmp    0xf01b1a08,%eax
f0102d44:	73 65                	jae    f0102dab <env_free+0x131>
		page_decref(pa2page(pa));
f0102d46:	83 ec 0c             	sub    $0xc,%esp
	return &pages[PGNUM(pa)];
f0102d49:	a1 10 1a 1b f0       	mov    0xf01b1a10,%eax
f0102d4e:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0102d51:	8d 04 d0             	lea    (%eax,%edx,8),%eax
f0102d54:	50                   	push   %eax
f0102d55:	e8 e8 df ff ff       	call   f0100d42 <page_decref>
f0102d5a:	83 c4 10             	add    $0x10,%esp
f0102d5d:	83 45 e0 04          	addl   $0x4,-0x20(%ebp)
f0102d61:	8b 45 e0             	mov    -0x20(%ebp),%eax
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++)
f0102d64:	3d ec 0e 00 00       	cmp    $0xeec,%eax
f0102d69:	74 54                	je     f0102dbf <env_free+0x145>
		if (!(e->env_pgdir[pdeno] & PTE_P))
f0102d6b:	8b 47 5c             	mov    0x5c(%edi),%eax
f0102d6e:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0102d71:	8b 04 08             	mov    (%eax,%ecx,1),%eax
f0102d74:	a8 01                	test   $0x1,%al
f0102d76:	74 e5                	je     f0102d5d <env_free+0xe3>
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f0102d78:	89 c6                	mov    %eax,%esi
f0102d7a:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
	if (PGNUM(pa) >= npages)
f0102d80:	c1 e8 0c             	shr    $0xc,%eax
f0102d83:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0102d86:	39 05 08 1a 1b f0    	cmp    %eax,0xf01b1a08
f0102d8c:	0f 86 5b ff ff ff    	jbe    f0102ced <env_free+0x73>
	return (void *)(pa + KERNBASE);
f0102d92:	81 ee 00 00 00 10    	sub    $0x10000000,%esi
f0102d98:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0102d9b:	c1 e0 14             	shl    $0x14,%eax
f0102d9e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0102da1:	bb 00 00 00 00       	mov    $0x0,%ebx
f0102da6:	e9 7c ff ff ff       	jmp    f0102d27 <env_free+0xad>
		panic("pa2page called with invalid pa");
f0102dab:	83 ec 04             	sub    $0x4,%esp
f0102dae:	68 54 4e 10 f0       	push   $0xf0104e54
f0102db3:	6a 4f                	push   $0x4f
f0102db5:	68 57 4a 10 f0       	push   $0xf0104a57
f0102dba:	e8 e1 d2 ff ff       	call   f01000a0 <_panic>
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f0102dbf:	8b 47 5c             	mov    0x5c(%edi),%eax
	if ((uint32_t)kva < KERNBASE)
f0102dc2:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102dc7:	76 49                	jbe    f0102e12 <env_free+0x198>
	e->env_pgdir = 0;
f0102dc9:	c7 47 5c 00 00 00 00 	movl   $0x0,0x5c(%edi)
	return (physaddr_t)kva - KERNBASE;
f0102dd0:	05 00 00 00 10       	add    $0x10000000,%eax
	if (PGNUM(pa) >= npages)
f0102dd5:	c1 e8 0c             	shr    $0xc,%eax
f0102dd8:	3b 05 08 1a 1b f0    	cmp    0xf01b1a08,%eax
f0102dde:	73 47                	jae    f0102e27 <env_free+0x1ad>
	page_decref(pa2page(pa));
f0102de0:	83 ec 0c             	sub    $0xc,%esp
	return &pages[PGNUM(pa)];
f0102de3:	8b 15 10 1a 1b f0    	mov    0xf01b1a10,%edx
f0102de9:	8d 04 c2             	lea    (%edx,%eax,8),%eax
f0102dec:	50                   	push   %eax
f0102ded:	e8 50 df ff ff       	call   f0100d42 <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f0102df2:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	e->env_link = env_free_list;
f0102df9:	a1 4c 0d 1b f0       	mov    0xf01b0d4c,%eax
f0102dfe:	89 47 44             	mov    %eax,0x44(%edi)
	env_free_list = e;
f0102e01:	89 3d 4c 0d 1b f0    	mov    %edi,0xf01b0d4c
}
f0102e07:	83 c4 10             	add    $0x10,%esp
f0102e0a:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102e0d:	5b                   	pop    %ebx
f0102e0e:	5e                   	pop    %esi
f0102e0f:	5f                   	pop    %edi
f0102e10:	5d                   	pop    %ebp
f0102e11:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102e12:	50                   	push   %eax
f0102e13:	68 b0 4e 10 f0       	push   $0xf0104eb0
f0102e18:	68 cc 01 00 00       	push   $0x1cc
f0102e1d:	68 4e 55 10 f0       	push   $0xf010554e
f0102e22:	e8 79 d2 ff ff       	call   f01000a0 <_panic>
		panic("pa2page called with invalid pa");
f0102e27:	83 ec 04             	sub    $0x4,%esp
f0102e2a:	68 54 4e 10 f0       	push   $0xf0104e54
f0102e2f:	6a 4f                	push   $0x4f
f0102e31:	68 57 4a 10 f0       	push   $0xf0104a57
f0102e36:	e8 65 d2 ff ff       	call   f01000a0 <_panic>

f0102e3b <env_destroy>:
//
// Frees environment e.
//
void
	env_destroy(struct Env * e)
{
f0102e3b:	55                   	push   %ebp
f0102e3c:	89 e5                	mov    %esp,%ebp
f0102e3e:	83 ec 14             	sub    $0x14,%esp
	env_free(e);
f0102e41:	ff 75 08             	pushl  0x8(%ebp)
f0102e44:	e8 31 fe ff ff       	call   f0102c7a <env_free>

	cprintf("Destroyed the only environment - nothing more to do!\n");
f0102e49:	c7 04 24 18 55 10 f0 	movl   $0xf0105518,(%esp)
f0102e50:	e8 00 01 00 00       	call   f0102f55 <cprintf>
f0102e55:	83 c4 10             	add    $0x10,%esp
	while (1)
		monitor(NULL);
f0102e58:	83 ec 0c             	sub    $0xc,%esp
f0102e5b:	6a 00                	push   $0x0
f0102e5d:	e8 7e d8 ff ff       	call   f01006e0 <monitor>
f0102e62:	83 c4 10             	add    $0x10,%esp
f0102e65:	eb f1                	jmp    f0102e58 <env_destroy+0x1d>

f0102e67 <env_pop_tf>:
//
// This function does not return.
//
void
	env_pop_tf(struct Trapframe * tf)
{
f0102e67:	55                   	push   %ebp
f0102e68:	89 e5                	mov    %esp,%ebp
f0102e6a:	83 ec 0c             	sub    $0xc,%esp
	asm volatile(
f0102e6d:	8b 65 08             	mov    0x8(%ebp),%esp
f0102e70:	61                   	popa   
f0102e71:	07                   	pop    %es
f0102e72:	1f                   	pop    %ds
f0102e73:	83 c4 08             	add    $0x8,%esp
f0102e76:	cf                   	iret   
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret\n"
		:
		: "g"(tf)
		: "memory");
	panic("iret failed"); /* mostly to placate the compiler */
f0102e77:	68 af 55 10 f0       	push   $0xf01055af
f0102e7c:	68 f6 01 00 00       	push   $0x1f6
f0102e81:	68 4e 55 10 f0       	push   $0xf010554e
f0102e86:	e8 15 d2 ff ff       	call   f01000a0 <_panic>

f0102e8b <env_run>:
//
// This function does not return.
//
void
	env_run(struct Env * e)
{
f0102e8b:	55                   	push   %ebp
f0102e8c:	89 e5                	mov    %esp,%ebp
f0102e8e:	83 ec 08             	sub    $0x8,%esp
f0102e91:	8b 45 08             	mov    0x8(%ebp),%eax

	// LAB 3: Your code here.
	// Set the current environment(if any) back to ENV_RUNNABLE if it is ENV_RUNNING

	
	if (curenv != NULL && curenv->env_status == ENV_RUNNING)
f0102e94:	8b 15 44 0d 1b f0    	mov    0xf01b0d44,%edx
f0102e9a:	85 d2                	test   %edx,%edx
f0102e9c:	74 06                	je     f0102ea4 <env_run+0x19>
f0102e9e:	83 7a 54 03          	cmpl   $0x3,0x54(%edx)
f0102ea2:	74 2c                	je     f0102ed0 <env_run+0x45>
		curenv->env_type = ENV_RUNNABLE;

	// Set 'curenv' to the new environment
	curenv = e;
f0102ea4:	a3 44 0d 1b f0       	mov    %eax,0xf01b0d44

	// Set its status to ENV_RUNNING,
	curenv->env_type = ENV_RUNNING;
f0102ea9:	c7 40 50 03 00 00 00 	movl   $0x3,0x50(%eax)

	// Update its 'env_runs' counter
	curenv->env_runs++;
f0102eb0:	ff 40 58             	incl   0x58(%eax)

	// Use lcr3() to switch to its address space
	lcr3(PADDR(e->env_pgdir));
f0102eb3:	8b 50 5c             	mov    0x5c(%eax),%edx
	if ((uint32_t)kva < KERNBASE)
f0102eb6:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0102ebc:	76 1b                	jbe    f0102ed9 <env_run+0x4e>
	return (physaddr_t)kva - KERNBASE;
f0102ebe:	81 c2 00 00 00 10    	add    $0x10000000,%edx
f0102ec4:	0f 22 da             	mov    %edx,%cr3

	// Use env_pop_tf() to restore the environment's
	//	   registers and drop into user mode in the
	//	   environment.
	env_pop_tf(&e->env_tf);
f0102ec7:	83 ec 0c             	sub    $0xc,%esp
f0102eca:	50                   	push   %eax
f0102ecb:	e8 97 ff ff ff       	call   f0102e67 <env_pop_tf>
		curenv->env_type = ENV_RUNNABLE;
f0102ed0:	c7 42 50 02 00 00 00 	movl   $0x2,0x50(%edx)
f0102ed7:	eb cb                	jmp    f0102ea4 <env_run+0x19>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102ed9:	52                   	push   %edx
f0102eda:	68 b0 4e 10 f0       	push   $0xf0104eb0
f0102edf:	68 24 02 00 00       	push   $0x224
f0102ee4:	68 4e 55 10 f0       	push   $0xf010554e
f0102ee9:	e8 b2 d1 ff ff       	call   f01000a0 <_panic>

f0102eee <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0102eee:	55                   	push   %ebp
f0102eef:	89 e5                	mov    %esp,%ebp
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0102ef1:	8b 45 08             	mov    0x8(%ebp),%eax
f0102ef4:	ba 70 00 00 00       	mov    $0x70,%edx
f0102ef9:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0102efa:	ba 71 00 00 00       	mov    $0x71,%edx
f0102eff:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0102f00:	0f b6 c0             	movzbl %al,%eax
}
f0102f03:	5d                   	pop    %ebp
f0102f04:	c3                   	ret    

f0102f05 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0102f05:	55                   	push   %ebp
f0102f06:	89 e5                	mov    %esp,%ebp
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0102f08:	8b 45 08             	mov    0x8(%ebp),%eax
f0102f0b:	ba 70 00 00 00       	mov    $0x70,%edx
f0102f10:	ee                   	out    %al,(%dx)
f0102f11:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102f14:	ba 71 00 00 00       	mov    $0x71,%edx
f0102f19:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0102f1a:	5d                   	pop    %ebp
f0102f1b:	c3                   	ret    

f0102f1c <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0102f1c:	55                   	push   %ebp
f0102f1d:	89 e5                	mov    %esp,%ebp
f0102f1f:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f0102f22:	ff 75 08             	pushl  0x8(%ebp)
f0102f25:	e8 b1 d6 ff ff       	call   f01005db <cputchar>
	*cnt++;
}
f0102f2a:	83 c4 10             	add    $0x10,%esp
f0102f2d:	c9                   	leave  
f0102f2e:	c3                   	ret    

f0102f2f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0102f2f:	55                   	push   %ebp
f0102f30:	89 e5                	mov    %esp,%ebp
f0102f32:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f0102f35:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0102f3c:	ff 75 0c             	pushl  0xc(%ebp)
f0102f3f:	ff 75 08             	pushl  0x8(%ebp)
f0102f42:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0102f45:	50                   	push   %eax
f0102f46:	68 1c 2f 10 f0       	push   $0xf0102f1c
f0102f4b:	e8 68 0b 00 00       	call   f0103ab8 <vprintfmt>
	return cnt;
}
f0102f50:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0102f53:	c9                   	leave  
f0102f54:	c3                   	ret    

f0102f55 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0102f55:	55                   	push   %ebp
f0102f56:	89 e5                	mov    %esp,%ebp
f0102f58:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0102f5b:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0102f5e:	50                   	push   %eax
f0102f5f:	ff 75 08             	pushl  0x8(%ebp)
f0102f62:	e8 c8 ff ff ff       	call   f0102f2f <vcprintf>
	va_end(ap);

	return cnt;
}
f0102f67:	c9                   	leave  
f0102f68:	c3                   	ret    

f0102f69 <trap_init_percpu>:
void
trap_init_percpu(void)
{
	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
	ts.ts_esp0 = KSTACKTOP;
f0102f69:	b8 80 15 1b f0       	mov    $0xf01b1580,%eax
f0102f6e:	c7 05 84 15 1b f0 00 	movl   $0xf0000000,0xf01b1584
f0102f75:	00 00 f0 
	ts.ts_ss0 = GD_KD;
f0102f78:	66 c7 05 88 15 1b f0 	movw   $0x10,0xf01b1588
f0102f7f:	10 00 
	ts.ts_iomb = sizeof(struct Taskstate);
f0102f81:	66 c7 05 e6 15 1b f0 	movw   $0x68,0xf01b15e6
f0102f88:	68 00 

	// Initialize the TSS slot of the gdt.
	gdt[GD_TSS0 >> 3] = SEG16(STS_T32A, (uint32_t) (&ts),
f0102f8a:	66 c7 05 48 c3 11 f0 	movw   $0x67,0xf011c348
f0102f91:	67 00 
f0102f93:	66 a3 4a c3 11 f0    	mov    %ax,0xf011c34a
f0102f99:	89 c2                	mov    %eax,%edx
f0102f9b:	c1 ea 10             	shr    $0x10,%edx
f0102f9e:	88 15 4c c3 11 f0    	mov    %dl,0xf011c34c
f0102fa4:	c6 05 4e c3 11 f0 40 	movb   $0x40,0xf011c34e
f0102fab:	c1 e8 18             	shr    $0x18,%eax
f0102fae:	a2 4f c3 11 f0       	mov    %al,0xf011c34f
					sizeof(struct Taskstate) - 1, 0);
	gdt[GD_TSS0 >> 3].sd_s = 0;
f0102fb3:	c6 05 4d c3 11 f0 89 	movb   $0x89,0xf011c34d
	asm volatile("ltr %0" : : "r" (sel));
f0102fba:	b8 28 00 00 00       	mov    $0x28,%eax
f0102fbf:	0f 00 d8             	ltr    %ax
	asm volatile("lidt (%0)" : : "r" (p));
f0102fc2:	b8 50 c3 11 f0       	mov    $0xf011c350,%eax
f0102fc7:	0f 01 18             	lidtl  (%eax)
	// bottom three bits are special; we leave them 0)
	ltr(GD_TSS0);

	// Load the IDT
	lidt(&idt_pd);
}
f0102fca:	c3                   	ret    

f0102fcb <trap_init>:
{
f0102fcb:	55                   	push   %ebp
f0102fcc:	89 e5                	mov    %esp,%ebp
f0102fce:	83 ec 08             	sub    $0x8,%esp
	SETGATE(idt[T_DIVIDE], 0, GD_KT, t_divide, 0);
f0102fd1:	b8 6c 36 10 f0       	mov    $0xf010366c,%eax
f0102fd6:	66 a3 60 0d 1b f0    	mov    %ax,0xf01b0d60
f0102fdc:	66 c7 05 62 0d 1b f0 	movw   $0x8,0xf01b0d62
f0102fe3:	08 00 
f0102fe5:	c6 05 64 0d 1b f0 00 	movb   $0x0,0xf01b0d64
f0102fec:	c6 05 65 0d 1b f0 8e 	movb   $0x8e,0xf01b0d65
f0102ff3:	c1 e8 10             	shr    $0x10,%eax
f0102ff6:	66 a3 66 0d 1b f0    	mov    %ax,0xf01b0d66
	SETGATE(idt[T_DEBUG], 0, GD_KT, t_debug, 0);
f0102ffc:	b8 72 36 10 f0       	mov    $0xf0103672,%eax
f0103001:	66 a3 68 0d 1b f0    	mov    %ax,0xf01b0d68
f0103007:	66 c7 05 6a 0d 1b f0 	movw   $0x8,0xf01b0d6a
f010300e:	08 00 
f0103010:	c6 05 6c 0d 1b f0 00 	movb   $0x0,0xf01b0d6c
f0103017:	c6 05 6d 0d 1b f0 8e 	movb   $0x8e,0xf01b0d6d
f010301e:	c1 e8 10             	shr    $0x10,%eax
f0103021:	66 a3 6e 0d 1b f0    	mov    %ax,0xf01b0d6e
	SETGATE(idt[T_NMI], 0, GD_KT, t_nmi, 0);
f0103027:	b8 78 36 10 f0       	mov    $0xf0103678,%eax
f010302c:	66 a3 70 0d 1b f0    	mov    %ax,0xf01b0d70
f0103032:	66 c7 05 72 0d 1b f0 	movw   $0x8,0xf01b0d72
f0103039:	08 00 
f010303b:	c6 05 74 0d 1b f0 00 	movb   $0x0,0xf01b0d74
f0103042:	c6 05 75 0d 1b f0 8e 	movb   $0x8e,0xf01b0d75
f0103049:	c1 e8 10             	shr    $0x10,%eax
f010304c:	66 a3 76 0d 1b f0    	mov    %ax,0xf01b0d76
	SETGATE(idt[T_BRKPT], 1, GD_KT, t_brkpt, 0);
f0103052:	b8 7e 36 10 f0       	mov    $0xf010367e,%eax
f0103057:	66 a3 78 0d 1b f0    	mov    %ax,0xf01b0d78
f010305d:	66 c7 05 7a 0d 1b f0 	movw   $0x8,0xf01b0d7a
f0103064:	08 00 
f0103066:	c6 05 7c 0d 1b f0 00 	movb   $0x0,0xf01b0d7c
f010306d:	c6 05 7d 0d 1b f0 8f 	movb   $0x8f,0xf01b0d7d
f0103074:	c1 e8 10             	shr    $0x10,%eax
f0103077:	66 a3 7e 0d 1b f0    	mov    %ax,0xf01b0d7e
	SETGATE(idt[T_OFLOW], 1, GD_KT, t_oflow, 0);
f010307d:	b8 84 36 10 f0       	mov    $0xf0103684,%eax
f0103082:	66 a3 80 0d 1b f0    	mov    %ax,0xf01b0d80
f0103088:	66 c7 05 82 0d 1b f0 	movw   $0x8,0xf01b0d82
f010308f:	08 00 
f0103091:	c6 05 84 0d 1b f0 00 	movb   $0x0,0xf01b0d84
f0103098:	c6 05 85 0d 1b f0 8f 	movb   $0x8f,0xf01b0d85
f010309f:	c1 e8 10             	shr    $0x10,%eax
f01030a2:	66 a3 86 0d 1b f0    	mov    %ax,0xf01b0d86
	SETGATE(idt[T_BOUND], 0, GD_KT, t_bound, 0);
f01030a8:	b8 8a 36 10 f0       	mov    $0xf010368a,%eax
f01030ad:	66 a3 88 0d 1b f0    	mov    %ax,0xf01b0d88
f01030b3:	66 c7 05 8a 0d 1b f0 	movw   $0x8,0xf01b0d8a
f01030ba:	08 00 
f01030bc:	c6 05 8c 0d 1b f0 00 	movb   $0x0,0xf01b0d8c
f01030c3:	c6 05 8d 0d 1b f0 8e 	movb   $0x8e,0xf01b0d8d
f01030ca:	c1 e8 10             	shr    $0x10,%eax
f01030cd:	66 a3 8e 0d 1b f0    	mov    %ax,0xf01b0d8e
	SETGATE(idt[T_ILLOP], 0, GD_KT, t_illop, 0);
f01030d3:	b8 90 36 10 f0       	mov    $0xf0103690,%eax
f01030d8:	66 a3 90 0d 1b f0    	mov    %ax,0xf01b0d90
f01030de:	66 c7 05 92 0d 1b f0 	movw   $0x8,0xf01b0d92
f01030e5:	08 00 
f01030e7:	c6 05 94 0d 1b f0 00 	movb   $0x0,0xf01b0d94
f01030ee:	c6 05 95 0d 1b f0 8e 	movb   $0x8e,0xf01b0d95
f01030f5:	c1 e8 10             	shr    $0x10,%eax
f01030f8:	66 a3 96 0d 1b f0    	mov    %ax,0xf01b0d96
	SETGATE(idt[T_DEVICE], 0, GD_KT, t_device, 0);
f01030fe:	b8 96 36 10 f0       	mov    $0xf0103696,%eax
f0103103:	66 a3 98 0d 1b f0    	mov    %ax,0xf01b0d98
f0103109:	66 c7 05 9a 0d 1b f0 	movw   $0x8,0xf01b0d9a
f0103110:	08 00 
f0103112:	c6 05 9c 0d 1b f0 00 	movb   $0x0,0xf01b0d9c
f0103119:	c6 05 9d 0d 1b f0 8e 	movb   $0x8e,0xf01b0d9d
f0103120:	c1 e8 10             	shr    $0x10,%eax
f0103123:	66 a3 9e 0d 1b f0    	mov    %ax,0xf01b0d9e
	SETGATE(idt[T_DBLFLT], 0, GD_KT, t_dblflt, 0);
f0103129:	b8 9c 36 10 f0       	mov    $0xf010369c,%eax
f010312e:	66 a3 a0 0d 1b f0    	mov    %ax,0xf01b0da0
f0103134:	66 c7 05 a2 0d 1b f0 	movw   $0x8,0xf01b0da2
f010313b:	08 00 
f010313d:	c6 05 a4 0d 1b f0 00 	movb   $0x0,0xf01b0da4
f0103144:	c6 05 a5 0d 1b f0 8e 	movb   $0x8e,0xf01b0da5
f010314b:	c1 e8 10             	shr    $0x10,%eax
f010314e:	66 a3 a6 0d 1b f0    	mov    %ax,0xf01b0da6
	SETGATE(idt[T_TSS], 0, GD_KT, t_tss, 0);
f0103154:	b8 a0 36 10 f0       	mov    $0xf01036a0,%eax
f0103159:	66 a3 b0 0d 1b f0    	mov    %ax,0xf01b0db0
f010315f:	66 c7 05 b2 0d 1b f0 	movw   $0x8,0xf01b0db2
f0103166:	08 00 
f0103168:	c6 05 b4 0d 1b f0 00 	movb   $0x0,0xf01b0db4
f010316f:	c6 05 b5 0d 1b f0 8e 	movb   $0x8e,0xf01b0db5
f0103176:	c1 e8 10             	shr    $0x10,%eax
f0103179:	66 a3 b6 0d 1b f0    	mov    %ax,0xf01b0db6
	SETGATE(idt[T_SEGNP], 0, GD_KT, t_segnp, 0);
f010317f:	b8 a4 36 10 f0       	mov    $0xf01036a4,%eax
f0103184:	66 a3 b8 0d 1b f0    	mov    %ax,0xf01b0db8
f010318a:	66 c7 05 ba 0d 1b f0 	movw   $0x8,0xf01b0dba
f0103191:	08 00 
f0103193:	c6 05 bc 0d 1b f0 00 	movb   $0x0,0xf01b0dbc
f010319a:	c6 05 bd 0d 1b f0 8e 	movb   $0x8e,0xf01b0dbd
f01031a1:	c1 e8 10             	shr    $0x10,%eax
f01031a4:	66 a3 be 0d 1b f0    	mov    %ax,0xf01b0dbe
	SETGATE(idt[T_STACK], 0, GD_KT, t_stack, 0);
f01031aa:	b8 a8 36 10 f0       	mov    $0xf01036a8,%eax
f01031af:	66 a3 c0 0d 1b f0    	mov    %ax,0xf01b0dc0
f01031b5:	66 c7 05 c2 0d 1b f0 	movw   $0x8,0xf01b0dc2
f01031bc:	08 00 
f01031be:	c6 05 c4 0d 1b f0 00 	movb   $0x0,0xf01b0dc4
f01031c5:	c6 05 c5 0d 1b f0 8e 	movb   $0x8e,0xf01b0dc5
f01031cc:	c1 e8 10             	shr    $0x10,%eax
f01031cf:	66 a3 c6 0d 1b f0    	mov    %ax,0xf01b0dc6
	SETGATE(idt[T_GPFLT], 0, GD_KT, t_gpflt, 0);
f01031d5:	b8 ac 36 10 f0       	mov    $0xf01036ac,%eax
f01031da:	66 a3 c8 0d 1b f0    	mov    %ax,0xf01b0dc8
f01031e0:	66 c7 05 ca 0d 1b f0 	movw   $0x8,0xf01b0dca
f01031e7:	08 00 
f01031e9:	c6 05 cc 0d 1b f0 00 	movb   $0x0,0xf01b0dcc
f01031f0:	c6 05 cd 0d 1b f0 8e 	movb   $0x8e,0xf01b0dcd
f01031f7:	c1 e8 10             	shr    $0x10,%eax
f01031fa:	66 a3 ce 0d 1b f0    	mov    %ax,0xf01b0dce
	SETGATE(idt[T_PGFLT], 0, GD_KT, t_pgflt, 0);
f0103200:	b8 b0 36 10 f0       	mov    $0xf01036b0,%eax
f0103205:	66 a3 d0 0d 1b f0    	mov    %ax,0xf01b0dd0
f010320b:	66 c7 05 d2 0d 1b f0 	movw   $0x8,0xf01b0dd2
f0103212:	08 00 
f0103214:	c6 05 d4 0d 1b f0 00 	movb   $0x0,0xf01b0dd4
f010321b:	c6 05 d5 0d 1b f0 8e 	movb   $0x8e,0xf01b0dd5
f0103222:	c1 e8 10             	shr    $0x10,%eax
f0103225:	66 a3 d6 0d 1b f0    	mov    %ax,0xf01b0dd6
	SETGATE(idt[T_FPERR], 0, GD_KT, t_fperr, 0);
f010322b:	b8 b4 36 10 f0       	mov    $0xf01036b4,%eax
f0103230:	66 a3 e0 0d 1b f0    	mov    %ax,0xf01b0de0
f0103236:	66 c7 05 e2 0d 1b f0 	movw   $0x8,0xf01b0de2
f010323d:	08 00 
f010323f:	c6 05 e4 0d 1b f0 00 	movb   $0x0,0xf01b0de4
f0103246:	c6 05 e5 0d 1b f0 8e 	movb   $0x8e,0xf01b0de5
f010324d:	c1 e8 10             	shr    $0x10,%eax
f0103250:	66 a3 e6 0d 1b f0    	mov    %ax,0xf01b0de6
	SETGATE(idt[T_ALIGN], 0, GD_KT, t_align, 0);
f0103256:	b8 ba 36 10 f0       	mov    $0xf01036ba,%eax
f010325b:	66 a3 e8 0d 1b f0    	mov    %ax,0xf01b0de8
f0103261:	66 c7 05 ea 0d 1b f0 	movw   $0x8,0xf01b0dea
f0103268:	08 00 
f010326a:	c6 05 ec 0d 1b f0 00 	movb   $0x0,0xf01b0dec
f0103271:	c6 05 ed 0d 1b f0 8e 	movb   $0x8e,0xf01b0ded
f0103278:	c1 e8 10             	shr    $0x10,%eax
f010327b:	66 a3 ee 0d 1b f0    	mov    %ax,0xf01b0dee
	SETGATE(idt[T_MCHK], 0, GD_KT, t_mchk, 0);
f0103281:	b8 be 36 10 f0       	mov    $0xf01036be,%eax
f0103286:	66 a3 f0 0d 1b f0    	mov    %ax,0xf01b0df0
f010328c:	66 c7 05 f2 0d 1b f0 	movw   $0x8,0xf01b0df2
f0103293:	08 00 
f0103295:	c6 05 f4 0d 1b f0 00 	movb   $0x0,0xf01b0df4
f010329c:	c6 05 f5 0d 1b f0 8e 	movb   $0x8e,0xf01b0df5
f01032a3:	c1 e8 10             	shr    $0x10,%eax
f01032a6:	66 a3 f6 0d 1b f0    	mov    %ax,0xf01b0df6
	SETGATE(idt[T_SIMDERR], 0, GD_KT, t_simderr, 0);
f01032ac:	b8 c4 36 10 f0       	mov    $0xf01036c4,%eax
f01032b1:	66 a3 f8 0d 1b f0    	mov    %ax,0xf01b0df8
f01032b7:	66 c7 05 fa 0d 1b f0 	movw   $0x8,0xf01b0dfa
f01032be:	08 00 
f01032c0:	c6 05 fc 0d 1b f0 00 	movb   $0x0,0xf01b0dfc
f01032c7:	c6 05 fd 0d 1b f0 8e 	movb   $0x8e,0xf01b0dfd
f01032ce:	c1 e8 10             	shr    $0x10,%eax
f01032d1:	66 a3 fe 0d 1b f0    	mov    %ax,0xf01b0dfe
	SETGATE(idt[T_SYSCALL], 1, GD_KT, t_syscall, 3);
f01032d7:	b8 ca 36 10 f0       	mov    $0xf01036ca,%eax
f01032dc:	66 a3 e0 0e 1b f0    	mov    %ax,0xf01b0ee0
f01032e2:	66 c7 05 e2 0e 1b f0 	movw   $0x8,0xf01b0ee2
f01032e9:	08 00 
f01032eb:	c6 05 e4 0e 1b f0 00 	movb   $0x0,0xf01b0ee4
f01032f2:	c6 05 e5 0e 1b f0 ef 	movb   $0xef,0xf01b0ee5
f01032f9:	c1 e8 10             	shr    $0x10,%eax
f01032fc:	66 a3 e6 0e 1b f0    	mov    %ax,0xf01b0ee6
	trap_init_percpu();
f0103302:	e8 62 fc ff ff       	call   f0102f69 <trap_init_percpu>
}
f0103307:	c9                   	leave  
f0103308:	c3                   	ret    

f0103309 <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f0103309:	55                   	push   %ebp
f010330a:	89 e5                	mov    %esp,%ebp
f010330c:	53                   	push   %ebx
f010330d:	83 ec 0c             	sub    $0xc,%esp
f0103310:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f0103313:	ff 33                	pushl  (%ebx)
f0103315:	68 bb 55 10 f0       	push   $0xf01055bb
f010331a:	e8 36 fc ff ff       	call   f0102f55 <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f010331f:	83 c4 08             	add    $0x8,%esp
f0103322:	ff 73 04             	pushl  0x4(%ebx)
f0103325:	68 ca 55 10 f0       	push   $0xf01055ca
f010332a:	e8 26 fc ff ff       	call   f0102f55 <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f010332f:	83 c4 08             	add    $0x8,%esp
f0103332:	ff 73 08             	pushl  0x8(%ebx)
f0103335:	68 d9 55 10 f0       	push   $0xf01055d9
f010333a:	e8 16 fc ff ff       	call   f0102f55 <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f010333f:	83 c4 08             	add    $0x8,%esp
f0103342:	ff 73 0c             	pushl  0xc(%ebx)
f0103345:	68 e8 55 10 f0       	push   $0xf01055e8
f010334a:	e8 06 fc ff ff       	call   f0102f55 <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f010334f:	83 c4 08             	add    $0x8,%esp
f0103352:	ff 73 10             	pushl  0x10(%ebx)
f0103355:	68 f7 55 10 f0       	push   $0xf01055f7
f010335a:	e8 f6 fb ff ff       	call   f0102f55 <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f010335f:	83 c4 08             	add    $0x8,%esp
f0103362:	ff 73 14             	pushl  0x14(%ebx)
f0103365:	68 06 56 10 f0       	push   $0xf0105606
f010336a:	e8 e6 fb ff ff       	call   f0102f55 <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f010336f:	83 c4 08             	add    $0x8,%esp
f0103372:	ff 73 18             	pushl  0x18(%ebx)
f0103375:	68 15 56 10 f0       	push   $0xf0105615
f010337a:	e8 d6 fb ff ff       	call   f0102f55 <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f010337f:	83 c4 08             	add    $0x8,%esp
f0103382:	ff 73 1c             	pushl  0x1c(%ebx)
f0103385:	68 24 56 10 f0       	push   $0xf0105624
f010338a:	e8 c6 fb ff ff       	call   f0102f55 <cprintf>
}
f010338f:	83 c4 10             	add    $0x10,%esp
f0103392:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103395:	c9                   	leave  
f0103396:	c3                   	ret    

f0103397 <print_trapframe>:
{
f0103397:	55                   	push   %ebp
f0103398:	89 e5                	mov    %esp,%ebp
f010339a:	53                   	push   %ebx
f010339b:	83 ec 0c             	sub    $0xc,%esp
f010339e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p\n", tf);
f01033a1:	53                   	push   %ebx
f01033a2:	68 5a 57 10 f0       	push   $0xf010575a
f01033a7:	e8 a9 fb ff ff       	call   f0102f55 <cprintf>
	print_regs(&tf->tf_regs);
f01033ac:	89 1c 24             	mov    %ebx,(%esp)
f01033af:	e8 55 ff ff ff       	call   f0103309 <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f01033b4:	83 c4 08             	add    $0x8,%esp
f01033b7:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f01033bb:	50                   	push   %eax
f01033bc:	68 75 56 10 f0       	push   $0xf0105675
f01033c1:	e8 8f fb ff ff       	call   f0102f55 <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f01033c6:	83 c4 08             	add    $0x8,%esp
f01033c9:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f01033cd:	50                   	push   %eax
f01033ce:	68 88 56 10 f0       	push   $0xf0105688
f01033d3:	e8 7d fb ff ff       	call   f0102f55 <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f01033d8:	8b 43 28             	mov    0x28(%ebx),%eax
	if (trapno < ARRAY_SIZE(excnames))
f01033db:	83 c4 10             	add    $0x10,%esp
f01033de:	83 f8 13             	cmp    $0x13,%eax
f01033e1:	0f 86 c3 00 00 00    	jbe    f01034aa <print_trapframe+0x113>
	if (trapno == T_SYSCALL)
f01033e7:	83 f8 30             	cmp    $0x30,%eax
f01033ea:	0f 84 c6 00 00 00    	je     f01034b6 <print_trapframe+0x11f>
	return "(unknown trap)";
f01033f0:	ba 33 56 10 f0       	mov    $0xf0105633,%edx
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f01033f5:	83 ec 04             	sub    $0x4,%esp
f01033f8:	52                   	push   %edx
f01033f9:	50                   	push   %eax
f01033fa:	68 9b 56 10 f0       	push   $0xf010569b
f01033ff:	e8 51 fb ff ff       	call   f0102f55 <cprintf>
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f0103404:	83 c4 10             	add    $0x10,%esp
f0103407:	39 1d 60 15 1b f0    	cmp    %ebx,0xf01b1560
f010340d:	0f 84 ad 00 00 00    	je     f01034c0 <print_trapframe+0x129>
	cprintf("  err  0x%08x", tf->tf_err);
f0103413:	83 ec 08             	sub    $0x8,%esp
f0103416:	ff 73 2c             	pushl  0x2c(%ebx)
f0103419:	68 bc 56 10 f0       	push   $0xf01056bc
f010341e:	e8 32 fb ff ff       	call   f0102f55 <cprintf>
	if (tf->tf_trapno == T_PGFLT)
f0103423:	83 c4 10             	add    $0x10,%esp
f0103426:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f010342a:	0f 85 d1 00 00 00    	jne    f0103501 <print_trapframe+0x16a>
			tf->tf_err & 1 ? "protection" : "not-present");
f0103430:	8b 43 2c             	mov    0x2c(%ebx),%eax
		cprintf(" [%s, %s, %s]\n",
f0103433:	a8 01                	test   $0x1,%al
f0103435:	0f 85 a8 00 00 00    	jne    f01034e3 <print_trapframe+0x14c>
f010343b:	b9 59 56 10 f0       	mov    $0xf0105659,%ecx
f0103440:	a8 02                	test   $0x2,%al
f0103442:	0f 85 a5 00 00 00    	jne    f01034ed <print_trapframe+0x156>
f0103448:	ba 6b 56 10 f0       	mov    $0xf010566b,%edx
f010344d:	a8 04                	test   $0x4,%al
f010344f:	0f 85 a2 00 00 00    	jne    f01034f7 <print_trapframe+0x160>
f0103455:	b8 85 57 10 f0       	mov    $0xf0105785,%eax
f010345a:	51                   	push   %ecx
f010345b:	52                   	push   %edx
f010345c:	50                   	push   %eax
f010345d:	68 ca 56 10 f0       	push   $0xf01056ca
f0103462:	e8 ee fa ff ff       	call   f0102f55 <cprintf>
f0103467:	83 c4 10             	add    $0x10,%esp
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f010346a:	83 ec 08             	sub    $0x8,%esp
f010346d:	ff 73 30             	pushl  0x30(%ebx)
f0103470:	68 d9 56 10 f0       	push   $0xf01056d9
f0103475:	e8 db fa ff ff       	call   f0102f55 <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f010347a:	83 c4 08             	add    $0x8,%esp
f010347d:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f0103481:	50                   	push   %eax
f0103482:	68 e8 56 10 f0       	push   $0xf01056e8
f0103487:	e8 c9 fa ff ff       	call   f0102f55 <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f010348c:	83 c4 08             	add    $0x8,%esp
f010348f:	ff 73 38             	pushl  0x38(%ebx)
f0103492:	68 fb 56 10 f0       	push   $0xf01056fb
f0103497:	e8 b9 fa ff ff       	call   f0102f55 <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f010349c:	83 c4 10             	add    $0x10,%esp
f010349f:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f01034a3:	75 71                	jne    f0103516 <print_trapframe+0x17f>
}
f01034a5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01034a8:	c9                   	leave  
f01034a9:	c3                   	ret    
		return excnames[trapno];
f01034aa:	8b 14 85 20 59 10 f0 	mov    -0xfefa6e0(,%eax,4),%edx
f01034b1:	e9 3f ff ff ff       	jmp    f01033f5 <print_trapframe+0x5e>
		return "System call";
f01034b6:	ba 42 56 10 f0       	mov    $0xf0105642,%edx
f01034bb:	e9 35 ff ff ff       	jmp    f01033f5 <print_trapframe+0x5e>
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f01034c0:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f01034c4:	0f 85 49 ff ff ff    	jne    f0103413 <print_trapframe+0x7c>
	asm volatile("movl %%cr2,%0" : "=r" (val));
f01034ca:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f01034cd:	83 ec 08             	sub    $0x8,%esp
f01034d0:	50                   	push   %eax
f01034d1:	68 ad 56 10 f0       	push   $0xf01056ad
f01034d6:	e8 7a fa ff ff       	call   f0102f55 <cprintf>
f01034db:	83 c4 10             	add    $0x10,%esp
f01034de:	e9 30 ff ff ff       	jmp    f0103413 <print_trapframe+0x7c>
		cprintf(" [%s, %s, %s]\n",
f01034e3:	b9 4e 56 10 f0       	mov    $0xf010564e,%ecx
f01034e8:	e9 53 ff ff ff       	jmp    f0103440 <print_trapframe+0xa9>
f01034ed:	ba 65 56 10 f0       	mov    $0xf0105665,%edx
f01034f2:	e9 56 ff ff ff       	jmp    f010344d <print_trapframe+0xb6>
f01034f7:	b8 70 56 10 f0       	mov    $0xf0105670,%eax
f01034fc:	e9 59 ff ff ff       	jmp    f010345a <print_trapframe+0xc3>
		cprintf("\n");
f0103501:	83 ec 0c             	sub    $0xc,%esp
f0103504:	68 13 4d 10 f0       	push   $0xf0104d13
f0103509:	e8 47 fa ff ff       	call   f0102f55 <cprintf>
f010350e:	83 c4 10             	add    $0x10,%esp
f0103511:	e9 54 ff ff ff       	jmp    f010346a <print_trapframe+0xd3>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f0103516:	83 ec 08             	sub    $0x8,%esp
f0103519:	ff 73 3c             	pushl  0x3c(%ebx)
f010351c:	68 0a 57 10 f0       	push   $0xf010570a
f0103521:	e8 2f fa ff ff       	call   f0102f55 <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f0103526:	83 c4 08             	add    $0x8,%esp
f0103529:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f010352d:	50                   	push   %eax
f010352e:	68 19 57 10 f0       	push   $0xf0105719
f0103533:	e8 1d fa ff ff       	call   f0102f55 <cprintf>
f0103538:	83 c4 10             	add    $0x10,%esp
}
f010353b:	e9 65 ff ff ff       	jmp    f01034a5 <print_trapframe+0x10e>

f0103540 <trap>:
	}
}

void
trap(struct Trapframe *tf)
{
f0103540:	55                   	push   %ebp
f0103541:	89 e5                	mov    %esp,%ebp
f0103543:	57                   	push   %edi
f0103544:	56                   	push   %esi
f0103545:	8b 75 08             	mov    0x8(%ebp),%esi
	// The environment may have set DF and some versions
	// of GCC rely on DF being clear
	asm volatile("cld" ::: "cc");
f0103548:	fc                   	cld    

static inline uint32_t
read_eflags(void)
{
	uint32_t eflags;
	asm volatile("pushfl; popl %0" : "=r" (eflags));
f0103549:	9c                   	pushf  
f010354a:	58                   	pop    %eax

	// Check that interrupts are disabled.  If this assertion
	// fails, DO NOT be tempted to fix it by inserting a "cli" in
	// the interrupt path.
	assert(!(read_eflags() & FL_IF));
f010354b:	f6 c4 02             	test   $0x2,%ah
f010354e:	74 19                	je     f0103569 <trap+0x29>
f0103550:	68 2c 57 10 f0       	push   $0xf010572c
f0103555:	68 71 4a 10 f0       	push   $0xf0104a71
f010355a:	68 d1 00 00 00       	push   $0xd1
f010355f:	68 45 57 10 f0       	push   $0xf0105745
f0103564:	e8 37 cb ff ff       	call   f01000a0 <_panic>

	cprintf("Incoming TRAP frame at %p\n", tf);
f0103569:	83 ec 08             	sub    $0x8,%esp
f010356c:	56                   	push   %esi
f010356d:	68 51 57 10 f0       	push   $0xf0105751
f0103572:	e8 de f9 ff ff       	call   f0102f55 <cprintf>

	if ((tf->tf_cs & 3) == 3) {
f0103577:	66 8b 46 34          	mov    0x34(%esi),%ax
f010357b:	83 e0 03             	and    $0x3,%eax
f010357e:	83 c4 10             	add    $0x10,%esp
f0103581:	66 83 f8 03          	cmp    $0x3,%ax
f0103585:	75 18                	jne    f010359f <trap+0x5f>
		// Trapped from user mode.
		assert(curenv);
f0103587:	a1 44 0d 1b f0       	mov    0xf01b0d44,%eax
f010358c:	85 c0                	test   %eax,%eax
f010358e:	74 61                	je     f01035f1 <trap+0xb1>

		// Copy trap frame (which is currently on the stack)
		// into 'curenv->env_tf', so that running the environment
		// will restart at the trap point.
		curenv->env_tf = *tf;
f0103590:	b9 11 00 00 00       	mov    $0x11,%ecx
f0103595:	89 c7                	mov    %eax,%edi
f0103597:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		// The trapframe on the stack should be ignored from here on.
		tf = &curenv->env_tf;
f0103599:	8b 35 44 0d 1b f0    	mov    0xf01b0d44,%esi
	}

	// Record that tf is the last real trapframe so
	// print_trapframe can print some additional information.
	last_tf = tf;
f010359f:	89 35 60 15 1b f0    	mov    %esi,0xf01b1560
	print_trapframe(tf);
f01035a5:	83 ec 0c             	sub    $0xc,%esp
f01035a8:	56                   	push   %esi
f01035a9:	e8 e9 fd ff ff       	call   f0103397 <print_trapframe>
	if (tf->tf_cs == GD_KT)
f01035ae:	83 c4 10             	add    $0x10,%esp
f01035b1:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f01035b6:	74 52                	je     f010360a <trap+0xca>
		env_destroy(curenv);
f01035b8:	83 ec 0c             	sub    $0xc,%esp
f01035bb:	ff 35 44 0d 1b f0    	pushl  0xf01b0d44
f01035c1:	e8 75 f8 ff ff       	call   f0102e3b <env_destroy>

	// Dispatch based on what type of trap occurred
	trap_dispatch(tf);

	// Return to the current environment, which should be running.
	assert(curenv && curenv->env_status == ENV_RUNNING);
f01035c6:	a1 44 0d 1b f0       	mov    0xf01b0d44,%eax
f01035cb:	83 c4 10             	add    $0x10,%esp
f01035ce:	85 c0                	test   %eax,%eax
f01035d0:	74 06                	je     f01035d8 <trap+0x98>
f01035d2:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f01035d6:	74 49                	je     f0103621 <trap+0xe1>
f01035d8:	68 d0 58 10 f0       	push   $0xf01058d0
f01035dd:	68 71 4a 10 f0       	push   $0xf0104a71
f01035e2:	68 e9 00 00 00       	push   $0xe9
f01035e7:	68 45 57 10 f0       	push   $0xf0105745
f01035ec:	e8 af ca ff ff       	call   f01000a0 <_panic>
		assert(curenv);
f01035f1:	68 6c 57 10 f0       	push   $0xf010576c
f01035f6:	68 71 4a 10 f0       	push   $0xf0104a71
f01035fb:	68 d7 00 00 00       	push   $0xd7
f0103600:	68 45 57 10 f0       	push   $0xf0105745
f0103605:	e8 96 ca ff ff       	call   f01000a0 <_panic>
		panic("unhandled trap in kernel");
f010360a:	83 ec 04             	sub    $0x4,%esp
f010360d:	68 73 57 10 f0       	push   $0xf0105773
f0103612:	68 c0 00 00 00       	push   $0xc0
f0103617:	68 45 57 10 f0       	push   $0xf0105745
f010361c:	e8 7f ca ff ff       	call   f01000a0 <_panic>
	env_run(curenv);
f0103621:	83 ec 0c             	sub    $0xc,%esp
f0103624:	50                   	push   %eax
f0103625:	e8 61 f8 ff ff       	call   f0102e8b <env_run>

f010362a <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f010362a:	55                   	push   %ebp
f010362b:	89 e5                	mov    %esp,%ebp
f010362d:	53                   	push   %ebx
f010362e:	83 ec 04             	sub    $0x4,%esp
f0103631:	8b 5d 08             	mov    0x8(%ebp),%ebx
	asm volatile("movl %%cr2,%0" : "=r" (val));
f0103634:	0f 20 d0             	mov    %cr2,%eax

	// We've already handled kernel-mode exceptions, so if we get here,
	// the page fault happened in user mode.

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0103637:	ff 73 30             	pushl  0x30(%ebx)
f010363a:	50                   	push   %eax
f010363b:	a1 44 0d 1b f0       	mov    0xf01b0d44,%eax
f0103640:	ff 70 48             	pushl  0x48(%eax)
f0103643:	68 fc 58 10 f0       	push   $0xf01058fc
f0103648:	e8 08 f9 ff ff       	call   f0102f55 <cprintf>
		curenv->env_id, fault_va, tf->tf_eip);
	print_trapframe(tf);
f010364d:	89 1c 24             	mov    %ebx,(%esp)
f0103650:	e8 42 fd ff ff       	call   f0103397 <print_trapframe>
	env_destroy(curenv);
f0103655:	83 c4 04             	add    $0x4,%esp
f0103658:	ff 35 44 0d 1b f0    	pushl  0xf01b0d44
f010365e:	e8 d8 f7 ff ff       	call   f0102e3b <env_destroy>
}
f0103663:	83 c4 10             	add    $0x10,%esp
f0103666:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103669:	c9                   	leave  
f010366a:	c3                   	ret    
f010366b:	90                   	nop

f010366c <t_divide>:
.text

/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */
TRAPHANDLER_NOEC(t_divide, T_DIVIDE);	// 0  divide error
f010366c:	6a 00                	push   $0x0
f010366e:	6a 00                	push   $0x0
f0103670:	eb 5e                	jmp    f01036d0 <_alltraps>

f0103672 <t_debug>:
TRAPHANDLER_NOEC(t_debug,  T_DEBUG);	// 1  debug exception
f0103672:	6a 00                	push   $0x0
f0103674:	6a 01                	push   $0x1
f0103676:	eb 58                	jmp    f01036d0 <_alltraps>

f0103678 <t_nmi>:
TRAPHANDLER_NOEC(t_nmi, T_NMI);			// 2  non-maskable interrupt
f0103678:	6a 00                	push   $0x0
f010367a:	6a 02                	push   $0x2
f010367c:	eb 52                	jmp    f01036d0 <_alltraps>

f010367e <t_brkpt>:
TRAPHANDLER_NOEC(t_brkpt, T_BRKPT);		// 3  breakpoint
f010367e:	6a 00                	push   $0x0
f0103680:	6a 03                	push   $0x3
f0103682:	eb 4c                	jmp    f01036d0 <_alltraps>

f0103684 <t_oflow>:
TRAPHANDLER_NOEC(t_oflow, T_OFLOW);		// 4  overflow
f0103684:	6a 00                	push   $0x0
f0103686:	6a 04                	push   $0x4
f0103688:	eb 46                	jmp    f01036d0 <_alltraps>

f010368a <t_bound>:
TRAPHANDLER_NOEC(t_bound, T_BOUND);		// 5  bounds check	
f010368a:	6a 00                	push   $0x0
f010368c:	6a 05                	push   $0x5
f010368e:	eb 40                	jmp    f01036d0 <_alltraps>

f0103690 <t_illop>:
TRAPHANDLER_NOEC(t_illop, T_ILLOP);		// 6  illegal opcode
f0103690:	6a 00                	push   $0x0
f0103692:	6a 06                	push   $0x6
f0103694:	eb 3a                	jmp    f01036d0 <_alltraps>

f0103696 <t_device>:
TRAPHANDLER_NOEC(t_device, T_DEVICE);	// 7  device not available
f0103696:	6a 00                	push   $0x0
f0103698:	6a 07                	push   $0x7
f010369a:	eb 34                	jmp    f01036d0 <_alltraps>

f010369c <t_dblflt>:

TRAPHANDLER(t_dblflt, T_DBLFLT);		// 8  double fault
f010369c:	6a 08                	push   $0x8
f010369e:	eb 30                	jmp    f01036d0 <_alltraps>

f01036a0 <t_tss>:
TRAPHANDLER(t_tss, T_TSS);				// 10 invalid task switch segment
f01036a0:	6a 0a                	push   $0xa
f01036a2:	eb 2c                	jmp    f01036d0 <_alltraps>

f01036a4 <t_segnp>:
TRAPHANDLER(t_segnp, T_SEGNP);			// 11 segment not present
f01036a4:	6a 0b                	push   $0xb
f01036a6:	eb 28                	jmp    f01036d0 <_alltraps>

f01036a8 <t_stack>:
TRAPHANDLER(t_stack, T_STACK);			// 12 stack exception
f01036a8:	6a 0c                	push   $0xc
f01036aa:	eb 24                	jmp    f01036d0 <_alltraps>

f01036ac <t_gpflt>:
TRAPHANDLER(t_gpflt, T_GPFLT);			// 13 general protection fault
f01036ac:	6a 0d                	push   $0xd
f01036ae:	eb 20                	jmp    f01036d0 <_alltraps>

f01036b0 <t_pgflt>:
TRAPHANDLER(t_pgflt, T_PGFLT);			// 14 page fault
f01036b0:	6a 0e                	push   $0xe
f01036b2:	eb 1c                	jmp    f01036d0 <_alltraps>

f01036b4 <t_fperr>:

TRAPHANDLER_NOEC(t_fperr, T_FPERR);		// 16 floating point error
f01036b4:	6a 00                	push   $0x0
f01036b6:	6a 10                	push   $0x10
f01036b8:	eb 16                	jmp    f01036d0 <_alltraps>

f01036ba <t_align>:

TRAPHANDLER(t_align, T_ALIGN);			// 17 aligment check
f01036ba:	6a 11                	push   $0x11
f01036bc:	eb 12                	jmp    f01036d0 <_alltraps>

f01036be <t_mchk>:

TRAPHANDLER_NOEC(t_mchk, T_MCHK);		// 18 machine check
f01036be:	6a 00                	push   $0x0
f01036c0:	6a 12                	push   $0x12
f01036c2:	eb 0c                	jmp    f01036d0 <_alltraps>

f01036c4 <t_simderr>:
TRAPHANDLER_NOEC(t_simderr, T_SIMDERR);	// 19 SIMD floating point error
f01036c4:	6a 00                	push   $0x0
f01036c6:	6a 13                	push   $0x13
f01036c8:	eb 06                	jmp    f01036d0 <_alltraps>

f01036ca <t_syscall>:
TRAPHANDLER_NOEC(t_syscall, T_SYSCALL);	// 19 SIMD floating point error
f01036ca:	6a 00                	push   $0x0
f01036cc:	6a 30                	push   $0x30
f01036ce:	eb 00                	jmp    f01036d0 <_alltraps>

f01036d0 <_alltraps>:
// 	call trap


_alltraps:
	// 1. push values to make the stack look like a struct Trapframe
    pushl %ds
f01036d0:	1e                   	push   %ds
    pushl %es
f01036d1:	06                   	push   %es
    pushal
f01036d2:	60                   	pusha  
	
	pushl %esp
f01036d3:	54                   	push   %esp

    movw $GD_KD, %ax
f01036d4:	66 b8 10 00          	mov    $0x10,%ax
    movw %ax, %ds
f01036d8:	8e d8                	mov    %eax,%ds
    movw %ax, %es
f01036da:	8e c0                	mov    %eax,%es
f01036dc:	e8 5f fe ff ff       	call   f0103540 <trap>

f01036e1 <syscall>:
}

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f01036e1:	55                   	push   %ebp
f01036e2:	89 e5                	mov    %esp,%ebp
f01036e4:	83 ec 0c             	sub    $0xc,%esp
	// Call the function corresponding to the 'syscallno' parameter.
	// Return any appropriate return value.
	// LAB 3: Your code here.

	panic("syscall not implemented");
f01036e7:	68 70 59 10 f0       	push   $0xf0105970
f01036ec:	6a 49                	push   $0x49
f01036ee:	68 88 59 10 f0       	push   $0xf0105988
f01036f3:	e8 a8 c9 ff ff       	call   f01000a0 <_panic>

f01036f8 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f01036f8:	55                   	push   %ebp
f01036f9:	89 e5                	mov    %esp,%ebp
f01036fb:	57                   	push   %edi
f01036fc:	56                   	push   %esi
f01036fd:	53                   	push   %ebx
f01036fe:	83 ec 14             	sub    $0x14,%esp
f0103701:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0103704:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0103707:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f010370a:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f010370d:	8b 1a                	mov    (%edx),%ebx
f010370f:	8b 39                	mov    (%ecx),%edi
f0103711:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f0103718:	eb 27                	jmp    f0103741 <stab_binsearch+0x49>

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f010371a:	8b 5d ec             	mov    -0x14(%ebp),%ebx
f010371d:	43                   	inc    %ebx
			continue;
f010371e:	eb 21                	jmp    f0103741 <stab_binsearch+0x49>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0103720:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0103723:	01 c2                	add    %eax,%edx
f0103725:	8b 4d f0             	mov    -0x10(%ebp),%ecx
f0103728:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f010372c:	3b 55 0c             	cmp    0xc(%ebp),%edx
f010372f:	73 44                	jae    f0103775 <stab_binsearch+0x7d>
			*region_left = m;
f0103731:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0103734:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f0103736:	8b 5d ec             	mov    -0x14(%ebp),%ebx
f0103739:	43                   	inc    %ebx
		any_matches = 1;
f010373a:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
	while (l <= r) {
f0103741:	39 fb                	cmp    %edi,%ebx
f0103743:	7f 59                	jg     f010379e <stab_binsearch+0xa6>
		int true_m = (l + r) / 2, m = true_m;
f0103745:	8d 14 3b             	lea    (%ebx,%edi,1),%edx
f0103748:	89 d0                	mov    %edx,%eax
f010374a:	c1 e8 1f             	shr    $0x1f,%eax
f010374d:	01 d0                	add    %edx,%eax
f010374f:	89 c1                	mov    %eax,%ecx
f0103751:	d1 f9                	sar    %ecx
f0103753:	89 4d ec             	mov    %ecx,-0x14(%ebp)
f0103756:	83 e0 fe             	and    $0xfffffffe,%eax
f0103759:	01 c8                	add    %ecx,%eax
f010375b:	8b 55 f0             	mov    -0x10(%ebp),%edx
f010375e:	8d 14 82             	lea    (%edx,%eax,4),%edx
f0103761:	89 c8                	mov    %ecx,%eax
		while (m >= l && stabs[m].n_type != type)
f0103763:	39 c3                	cmp    %eax,%ebx
f0103765:	7f b3                	jg     f010371a <stab_binsearch+0x22>
f0103767:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f010376b:	83 ea 0c             	sub    $0xc,%edx
f010376e:	39 f1                	cmp    %esi,%ecx
f0103770:	74 ae                	je     f0103720 <stab_binsearch+0x28>
			m--;
f0103772:	48                   	dec    %eax
f0103773:	eb ee                	jmp    f0103763 <stab_binsearch+0x6b>
		} else if (stabs[m].n_value > addr) {
f0103775:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0103778:	76 11                	jbe    f010378b <stab_binsearch+0x93>
			*region_right = m - 1;
f010377a:	8d 78 ff             	lea    -0x1(%eax),%edi
f010377d:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103780:	89 38                	mov    %edi,(%eax)
		any_matches = 1;
f0103782:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0103789:	eb b6                	jmp    f0103741 <stab_binsearch+0x49>
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f010378b:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f010378e:	89 03                	mov    %eax,(%ebx)
			l = m;
			addr++;
f0103790:	ff 45 0c             	incl   0xc(%ebp)
f0103793:	89 c3                	mov    %eax,%ebx
		any_matches = 1;
f0103795:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f010379c:	eb a3                	jmp    f0103741 <stab_binsearch+0x49>
		}
	}

	if (!any_matches)
f010379e:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f01037a2:	75 13                	jne    f01037b7 <stab_binsearch+0xbf>
		*region_right = *region_left - 1;
f01037a4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01037a7:	8b 00                	mov    (%eax),%eax
f01037a9:	48                   	dec    %eax
f01037aa:	8b 7d e0             	mov    -0x20(%ebp),%edi
f01037ad:	89 07                	mov    %eax,(%edi)
		     l > *region_left && stabs[l].n_type != type;
		     l--)
			/* do nothing */;
		*region_left = l;
	}
}
f01037af:	83 c4 14             	add    $0x14,%esp
f01037b2:	5b                   	pop    %ebx
f01037b3:	5e                   	pop    %esi
f01037b4:	5f                   	pop    %edi
f01037b5:	5d                   	pop    %ebp
f01037b6:	c3                   	ret    
		for (l = *region_right;
f01037b7:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01037ba:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f01037bc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01037bf:	8b 0f                	mov    (%edi),%ecx
f01037c1:	8d 14 00             	lea    (%eax,%eax,1),%edx
f01037c4:	01 c2                	add    %eax,%edx
f01037c6:	8b 7d f0             	mov    -0x10(%ebp),%edi
f01037c9:	8d 14 97             	lea    (%edi,%edx,4),%edx
		for (l = *region_right;
f01037cc:	eb 01                	jmp    f01037cf <stab_binsearch+0xd7>
		     l--)
f01037ce:	48                   	dec    %eax
		for (l = *region_right;
f01037cf:	39 c1                	cmp    %eax,%ecx
f01037d1:	7d 0b                	jge    f01037de <stab_binsearch+0xe6>
		     l > *region_left && stabs[l].n_type != type;
f01037d3:	0f b6 5a 04          	movzbl 0x4(%edx),%ebx
f01037d7:	83 ea 0c             	sub    $0xc,%edx
f01037da:	39 f3                	cmp    %esi,%ebx
f01037dc:	75 f0                	jne    f01037ce <stab_binsearch+0xd6>
		*region_left = l;
f01037de:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01037e1:	89 07                	mov    %eax,(%edi)
}
f01037e3:	eb ca                	jmp    f01037af <stab_binsearch+0xb7>

f01037e5 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f01037e5:	55                   	push   %ebp
f01037e6:	89 e5                	mov    %esp,%ebp
f01037e8:	57                   	push   %edi
f01037e9:	56                   	push   %esi
f01037ea:	53                   	push   %ebx
f01037eb:	83 ec 2c             	sub    $0x2c,%esp
f01037ee:	8b 7d 08             	mov    0x8(%ebp),%edi
f01037f1:	8b 75 0c             	mov    0xc(%ebp),%esi
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f01037f4:	c7 06 97 59 10 f0    	movl   $0xf0105997,(%esi)
	info->eip_line = 0;
f01037fa:	c7 46 04 00 00 00 00 	movl   $0x0,0x4(%esi)
	info->eip_fn_name = "<unknown>";
f0103801:	c7 46 08 97 59 10 f0 	movl   $0xf0105997,0x8(%esi)
	info->eip_fn_namelen = 9;
f0103808:	c7 46 0c 09 00 00 00 	movl   $0x9,0xc(%esi)
	info->eip_fn_addr = addr;
f010380f:	89 7e 10             	mov    %edi,0x10(%esi)
	info->eip_fn_narg = 0;
f0103812:	c7 46 14 00 00 00 00 	movl   $0x0,0x14(%esi)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0103819:	81 ff ff ff 7f ef    	cmp    $0xef7fffff,%edi
f010381f:	0f 87 fb 00 00 00    	ja     f0103920 <debuginfo_eip+0x13b>

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.

		stabs = usd->stabs;
f0103825:	a1 00 00 20 00       	mov    0x200000,%eax
f010382a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		stab_end = usd->stab_end;
f010382d:	a1 04 00 20 00       	mov    0x200004,%eax
		stabstr = usd->stabstr;
f0103832:	8b 1d 08 00 20 00    	mov    0x200008,%ebx
f0103838:	89 5d cc             	mov    %ebx,-0x34(%ebp)
		stabstr_end = usd->stabstr_end;
f010383b:	8b 1d 0c 00 20 00    	mov    0x20000c,%ebx
f0103841:	89 5d d0             	mov    %ebx,-0x30(%ebp)
		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0103844:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0103847:	39 4d cc             	cmp    %ecx,-0x34(%ebp)
f010384a:	0f 83 61 01 00 00    	jae    f01039b1 <debuginfo_eip+0x1cc>
f0103850:	80 79 ff 00          	cmpb   $0x0,-0x1(%ecx)
f0103854:	0f 85 5e 01 00 00    	jne    f01039b8 <debuginfo_eip+0x1d3>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f010385a:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0103861:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0103864:	29 d8                	sub    %ebx,%eax
f0103866:	89 c2                	mov    %eax,%edx
f0103868:	c1 fa 02             	sar    $0x2,%edx
f010386b:	83 e0 fc             	and    $0xfffffffc,%eax
f010386e:	01 d0                	add    %edx,%eax
f0103870:	8d 04 82             	lea    (%edx,%eax,4),%eax
f0103873:	8d 04 82             	lea    (%edx,%eax,4),%eax
f0103876:	89 c1                	mov    %eax,%ecx
f0103878:	c1 e1 08             	shl    $0x8,%ecx
f010387b:	01 c8                	add    %ecx,%eax
f010387d:	89 c1                	mov    %eax,%ecx
f010387f:	c1 e1 10             	shl    $0x10,%ecx
f0103882:	01 c8                	add    %ecx,%eax
f0103884:	01 c0                	add    %eax,%eax
f0103886:	8d 44 02 ff          	lea    -0x1(%edx,%eax,1),%eax
f010388a:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f010388d:	57                   	push   %edi
f010388e:	6a 64                	push   $0x64
f0103890:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0103893:	89 c1                	mov    %eax,%ecx
f0103895:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0103898:	89 d8                	mov    %ebx,%eax
f010389a:	e8 59 fe ff ff       	call   f01036f8 <stab_binsearch>
	if (lfile == 0)
f010389f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01038a2:	83 c4 08             	add    $0x8,%esp
f01038a5:	85 c0                	test   %eax,%eax
f01038a7:	0f 84 12 01 00 00    	je     f01039bf <debuginfo_eip+0x1da>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f01038ad:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f01038b0:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01038b3:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f01038b6:	57                   	push   %edi
f01038b7:	6a 24                	push   $0x24
f01038b9:	8d 45 d8             	lea    -0x28(%ebp),%eax
f01038bc:	89 c1                	mov    %eax,%ecx
f01038be:	8d 55 dc             	lea    -0x24(%ebp),%edx
f01038c1:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
f01038c4:	89 d8                	mov    %ebx,%eax
f01038c6:	e8 2d fe ff ff       	call   f01036f8 <stab_binsearch>

	if (lfun <= rfun) {
f01038cb:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f01038ce:	83 c4 08             	add    $0x8,%esp
f01038d1:	3b 5d d8             	cmp    -0x28(%ebp),%ebx
f01038d4:	7f 69                	jg     f010393f <debuginfo_eip+0x15a>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f01038d6:	8d 04 1b             	lea    (%ebx,%ebx,1),%eax
f01038d9:	01 d8                	add    %ebx,%eax
f01038db:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f01038de:	8d 14 87             	lea    (%edi,%eax,4),%edx
f01038e1:	8b 02                	mov    (%edx),%eax
f01038e3:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f01038e6:	8b 7d cc             	mov    -0x34(%ebp),%edi
f01038e9:	29 f9                	sub    %edi,%ecx
f01038eb:	39 c8                	cmp    %ecx,%eax
f01038ed:	73 05                	jae    f01038f4 <debuginfo_eip+0x10f>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f01038ef:	01 f8                	add    %edi,%eax
f01038f1:	89 46 08             	mov    %eax,0x8(%esi)
		info->eip_fn_addr = stabs[lfun].n_value;
f01038f4:	8b 42 08             	mov    0x8(%edx),%eax
f01038f7:	89 46 10             	mov    %eax,0x10(%esi)
		info->eip_fn_addr = addr;
		lline = lfile;
		rline = rfile;
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f01038fa:	83 ec 08             	sub    $0x8,%esp
f01038fd:	6a 3a                	push   $0x3a
f01038ff:	ff 76 08             	pushl  0x8(%esi)
f0103902:	e8 62 08 00 00       	call   f0104169 <strfind>
f0103907:	2b 46 08             	sub    0x8(%esi),%eax
f010390a:	89 46 0c             	mov    %eax,0xc(%esi)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f010390d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0103910:	8d 04 1b             	lea    (%ebx,%ebx,1),%eax
f0103913:	01 d8                	add    %ebx,%eax
f0103915:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0103918:	8d 04 81             	lea    (%ecx,%eax,4),%eax
f010391b:	83 c4 10             	add    $0x10,%esp
f010391e:	eb 2b                	jmp    f010394b <debuginfo_eip+0x166>
		stabstr_end = __STABSTR_END__;
f0103920:	c7 45 d0 8f 15 11 f0 	movl   $0xf011158f,-0x30(%ebp)
		stabstr = __STABSTR_BEGIN__;
f0103927:	c7 45 cc fd ea 10 f0 	movl   $0xf010eafd,-0x34(%ebp)
		stab_end = __STAB_END__;
f010392e:	b8 fc ea 10 f0       	mov    $0xf010eafc,%eax
		stabs = __STAB_BEGIN__;
f0103933:	c7 45 d4 b0 5b 10 f0 	movl   $0xf0105bb0,-0x2c(%ebp)
f010393a:	e9 05 ff ff ff       	jmp    f0103844 <debuginfo_eip+0x5f>
		info->eip_fn_addr = addr;
f010393f:	89 7e 10             	mov    %edi,0x10(%esi)
		lline = lfile;
f0103942:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0103945:	eb b3                	jmp    f01038fa <debuginfo_eip+0x115>
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f0103947:	4b                   	dec    %ebx
f0103948:	83 e8 0c             	sub    $0xc,%eax
	while (lline >= lfile
f010394b:	39 df                	cmp    %ebx,%edi
f010394d:	7f 30                	jg     f010397f <debuginfo_eip+0x19a>
	       && stabs[lline].n_type != N_SOL
f010394f:	8a 50 04             	mov    0x4(%eax),%dl
f0103952:	80 fa 84             	cmp    $0x84,%dl
f0103955:	74 0b                	je     f0103962 <debuginfo_eip+0x17d>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0103957:	80 fa 64             	cmp    $0x64,%dl
f010395a:	75 eb                	jne    f0103947 <debuginfo_eip+0x162>
f010395c:	83 78 08 00          	cmpl   $0x0,0x8(%eax)
f0103960:	74 e5                	je     f0103947 <debuginfo_eip+0x162>
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0103962:	8d 04 1b             	lea    (%ebx,%ebx,1),%eax
f0103965:	01 c3                	add    %eax,%ebx
f0103967:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010396a:	8b 14 98             	mov    (%eax,%ebx,4),%edx
f010396d:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0103970:	8b 7d cc             	mov    -0x34(%ebp),%edi
f0103973:	29 f8                	sub    %edi,%eax
f0103975:	39 c2                	cmp    %eax,%edx
f0103977:	73 06                	jae    f010397f <debuginfo_eip+0x19a>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0103979:	89 f8                	mov    %edi,%eax
f010397b:	01 d0                	add    %edx,%eax
f010397d:	89 06                	mov    %eax,(%esi)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f010397f:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0103982:	8b 4d d8             	mov    -0x28(%ebp),%ecx
f0103985:	39 c8                	cmp    %ecx,%eax
f0103987:	7d 3d                	jge    f01039c6 <debuginfo_eip+0x1e1>
		for (lline = lfun + 1;
f0103989:	8d 50 01             	lea    0x1(%eax),%edx
f010398c:	8d 1c 00             	lea    (%eax,%eax,1),%ebx
f010398f:	01 d8                	add    %ebx,%eax
f0103991:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0103994:	8d 04 87             	lea    (%edi,%eax,4),%eax
f0103997:	eb 04                	jmp    f010399d <debuginfo_eip+0x1b8>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f0103999:	ff 46 14             	incl   0x14(%esi)
		     lline++)
f010399c:	42                   	inc    %edx
		for (lline = lfun + 1;
f010399d:	39 d1                	cmp    %edx,%ecx
f010399f:	74 32                	je     f01039d3 <debuginfo_eip+0x1ee>
f01039a1:	83 c0 0c             	add    $0xc,%eax
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f01039a4:	80 78 04 a0          	cmpb   $0xa0,0x4(%eax)
f01039a8:	74 ef                	je     f0103999 <debuginfo_eip+0x1b4>

	return 0;
f01039aa:	b8 00 00 00 00       	mov    $0x0,%eax
f01039af:	eb 1a                	jmp    f01039cb <debuginfo_eip+0x1e6>
		return -1;
f01039b1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01039b6:	eb 13                	jmp    f01039cb <debuginfo_eip+0x1e6>
f01039b8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01039bd:	eb 0c                	jmp    f01039cb <debuginfo_eip+0x1e6>
		return -1;
f01039bf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01039c4:	eb 05                	jmp    f01039cb <debuginfo_eip+0x1e6>
	return 0;
f01039c6:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01039cb:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01039ce:	5b                   	pop    %ebx
f01039cf:	5e                   	pop    %esi
f01039d0:	5f                   	pop    %edi
f01039d1:	5d                   	pop    %ebp
f01039d2:	c3                   	ret    
	return 0;
f01039d3:	b8 00 00 00 00       	mov    $0x0,%eax
f01039d8:	eb f1                	jmp    f01039cb <debuginfo_eip+0x1e6>

f01039da <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f01039da:	55                   	push   %ebp
f01039db:	89 e5                	mov    %esp,%ebp
f01039dd:	57                   	push   %edi
f01039de:	56                   	push   %esi
f01039df:	53                   	push   %ebx
f01039e0:	83 ec 1c             	sub    $0x1c,%esp
f01039e3:	89 c7                	mov    %eax,%edi
f01039e5:	89 d6                	mov    %edx,%esi
f01039e7:	8b 45 08             	mov    0x8(%ebp),%eax
f01039ea:	8b 55 0c             	mov    0xc(%ebp),%edx
f01039ed:	89 d1                	mov    %edx,%ecx
f01039ef:	89 c2                	mov    %eax,%edx
f01039f1:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01039f4:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f01039f7:	8b 45 10             	mov    0x10(%ebp),%eax
f01039fa:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f01039fd:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0103a00:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f0103a07:	39 c2                	cmp    %eax,%edx
f0103a09:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
f0103a0c:	72 3c                	jb     f0103a4a <printnum+0x70>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0103a0e:	83 ec 0c             	sub    $0xc,%esp
f0103a11:	ff 75 18             	pushl  0x18(%ebp)
f0103a14:	4b                   	dec    %ebx
f0103a15:	53                   	push   %ebx
f0103a16:	50                   	push   %eax
f0103a17:	83 ec 08             	sub    $0x8,%esp
f0103a1a:	ff 75 e4             	pushl  -0x1c(%ebp)
f0103a1d:	ff 75 e0             	pushl  -0x20(%ebp)
f0103a20:	ff 75 dc             	pushl  -0x24(%ebp)
f0103a23:	ff 75 d8             	pushl  -0x28(%ebp)
f0103a26:	e8 31 09 00 00       	call   f010435c <__udivdi3>
f0103a2b:	83 c4 18             	add    $0x18,%esp
f0103a2e:	52                   	push   %edx
f0103a2f:	50                   	push   %eax
f0103a30:	89 f2                	mov    %esi,%edx
f0103a32:	89 f8                	mov    %edi,%eax
f0103a34:	e8 a1 ff ff ff       	call   f01039da <printnum>
f0103a39:	83 c4 20             	add    $0x20,%esp
f0103a3c:	eb 11                	jmp    f0103a4f <printnum+0x75>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0103a3e:	83 ec 08             	sub    $0x8,%esp
f0103a41:	56                   	push   %esi
f0103a42:	ff 75 18             	pushl  0x18(%ebp)
f0103a45:	ff d7                	call   *%edi
f0103a47:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
f0103a4a:	4b                   	dec    %ebx
f0103a4b:	85 db                	test   %ebx,%ebx
f0103a4d:	7f ef                	jg     f0103a3e <printnum+0x64>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0103a4f:	83 ec 08             	sub    $0x8,%esp
f0103a52:	56                   	push   %esi
f0103a53:	83 ec 04             	sub    $0x4,%esp
f0103a56:	ff 75 e4             	pushl  -0x1c(%ebp)
f0103a59:	ff 75 e0             	pushl  -0x20(%ebp)
f0103a5c:	ff 75 dc             	pushl  -0x24(%ebp)
f0103a5f:	ff 75 d8             	pushl  -0x28(%ebp)
f0103a62:	e8 f5 09 00 00       	call   f010445c <__umoddi3>
f0103a67:	83 c4 14             	add    $0x14,%esp
f0103a6a:	0f be 80 a1 59 10 f0 	movsbl -0xfefa65f(%eax),%eax
f0103a71:	50                   	push   %eax
f0103a72:	ff d7                	call   *%edi
}
f0103a74:	83 c4 10             	add    $0x10,%esp
f0103a77:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103a7a:	5b                   	pop    %ebx
f0103a7b:	5e                   	pop    %esi
f0103a7c:	5f                   	pop    %edi
f0103a7d:	5d                   	pop    %ebp
f0103a7e:	c3                   	ret    

f0103a7f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0103a7f:	55                   	push   %ebp
f0103a80:	89 e5                	mov    %esp,%ebp
f0103a82:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0103a85:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
f0103a88:	8b 10                	mov    (%eax),%edx
f0103a8a:	3b 50 04             	cmp    0x4(%eax),%edx
f0103a8d:	73 0a                	jae    f0103a99 <sprintputch+0x1a>
		*b->buf++ = ch;
f0103a8f:	8d 4a 01             	lea    0x1(%edx),%ecx
f0103a92:	89 08                	mov    %ecx,(%eax)
f0103a94:	8b 45 08             	mov    0x8(%ebp),%eax
f0103a97:	88 02                	mov    %al,(%edx)
}
f0103a99:	5d                   	pop    %ebp
f0103a9a:	c3                   	ret    

f0103a9b <printfmt>:
{
f0103a9b:	55                   	push   %ebp
f0103a9c:	89 e5                	mov    %esp,%ebp
f0103a9e:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
f0103aa1:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0103aa4:	50                   	push   %eax
f0103aa5:	ff 75 10             	pushl  0x10(%ebp)
f0103aa8:	ff 75 0c             	pushl  0xc(%ebp)
f0103aab:	ff 75 08             	pushl  0x8(%ebp)
f0103aae:	e8 05 00 00 00       	call   f0103ab8 <vprintfmt>
}
f0103ab3:	83 c4 10             	add    $0x10,%esp
f0103ab6:	c9                   	leave  
f0103ab7:	c3                   	ret    

f0103ab8 <vprintfmt>:
{
f0103ab8:	55                   	push   %ebp
f0103ab9:	89 e5                	mov    %esp,%ebp
f0103abb:	57                   	push   %edi
f0103abc:	56                   	push   %esi
f0103abd:	53                   	push   %ebx
f0103abe:	83 ec 3c             	sub    $0x3c,%esp
f0103ac1:	8b 75 08             	mov    0x8(%ebp),%esi
f0103ac4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0103ac7:	8b 7d 10             	mov    0x10(%ebp),%edi
f0103aca:	e9 5b 03 00 00       	jmp    f0103e2a <vprintfmt+0x372>
		padc = ' ';
f0103acf:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
f0103ad3:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
		precision = -1;
f0103ada:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
f0103ae1:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		lflag = 0;
f0103ae8:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
f0103aed:	8d 47 01             	lea    0x1(%edi),%eax
f0103af0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0103af3:	8a 17                	mov    (%edi),%dl
f0103af5:	8d 42 dd             	lea    -0x23(%edx),%eax
f0103af8:	3c 55                	cmp    $0x55,%al
f0103afa:	0f 87 ab 03 00 00    	ja     f0103eab <vprintfmt+0x3f3>
f0103b00:	0f b6 c0             	movzbl %al,%eax
f0103b03:	ff 24 85 2c 5a 10 f0 	jmp    *-0xfefa5d4(,%eax,4)
f0103b0a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
f0103b0d:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
f0103b11:	eb da                	jmp    f0103aed <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
f0103b13:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0103b16:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
f0103b1a:	eb d1                	jmp    f0103aed <vprintfmt+0x35>
f0103b1c:	0f b6 d2             	movzbl %dl,%edx
f0103b1f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
f0103b22:	b8 00 00 00 00       	mov    $0x0,%eax
f0103b27:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
f0103b2a:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0103b2d:	01 c0                	add    %eax,%eax
f0103b2f:	8d 44 02 d0          	lea    -0x30(%edx,%eax,1),%eax
				ch = *fmt;
f0103b33:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
f0103b36:	8d 4a d0             	lea    -0x30(%edx),%ecx
f0103b39:	83 f9 09             	cmp    $0x9,%ecx
f0103b3c:	77 52                	ja     f0103b90 <vprintfmt+0xd8>
			for (precision = 0; ; ++fmt) {
f0103b3e:	47                   	inc    %edi
				precision = precision * 10 + ch - '0';
f0103b3f:	eb e9                	jmp    f0103b2a <vprintfmt+0x72>
			precision = va_arg(ap, int);
f0103b41:	8b 45 14             	mov    0x14(%ebp),%eax
f0103b44:	8b 00                	mov    (%eax),%eax
f0103b46:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0103b49:	8b 45 14             	mov    0x14(%ebp),%eax
f0103b4c:	8d 40 04             	lea    0x4(%eax),%eax
f0103b4f:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0103b52:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
f0103b55:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f0103b59:	79 92                	jns    f0103aed <vprintfmt+0x35>
				width = precision, precision = -1;
f0103b5b:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0103b5e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0103b61:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
f0103b68:	eb 83                	jmp    f0103aed <vprintfmt+0x35>
f0103b6a:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f0103b6e:	78 08                	js     f0103b78 <vprintfmt+0xc0>
		switch (ch = *(unsigned char *) fmt++) {
f0103b70:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
f0103b73:	e9 75 ff ff ff       	jmp    f0103aed <vprintfmt+0x35>
f0103b78:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
f0103b7f:	eb ef                	jmp    f0103b70 <vprintfmt+0xb8>
		switch (ch = *(unsigned char *) fmt++) {
f0103b81:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
f0103b84:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
f0103b8b:	e9 5d ff ff ff       	jmp    f0103aed <vprintfmt+0x35>
f0103b90:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0103b93:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0103b96:	eb bd                	jmp    f0103b55 <vprintfmt+0x9d>
			lflag++;
f0103b98:	41                   	inc    %ecx
		switch (ch = *(unsigned char *) fmt++) {
f0103b99:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
f0103b9c:	e9 4c ff ff ff       	jmp    f0103aed <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
f0103ba1:	8b 45 14             	mov    0x14(%ebp),%eax
f0103ba4:	8d 78 04             	lea    0x4(%eax),%edi
f0103ba7:	83 ec 08             	sub    $0x8,%esp
f0103baa:	53                   	push   %ebx
f0103bab:	ff 30                	pushl  (%eax)
f0103bad:	ff d6                	call   *%esi
			break;
f0103baf:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
f0103bb2:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
f0103bb5:	e9 6d 02 00 00       	jmp    f0103e27 <vprintfmt+0x36f>
			err = va_arg(ap, int);
f0103bba:	8b 45 14             	mov    0x14(%ebp),%eax
f0103bbd:	8d 78 04             	lea    0x4(%eax),%edi
f0103bc0:	8b 00                	mov    (%eax),%eax
f0103bc2:	85 c0                	test   %eax,%eax
f0103bc4:	78 2a                	js     f0103bf0 <vprintfmt+0x138>
f0103bc6:	89 c2                	mov    %eax,%edx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0103bc8:	83 f8 06             	cmp    $0x6,%eax
f0103bcb:	7f 27                	jg     f0103bf4 <vprintfmt+0x13c>
f0103bcd:	8b 04 85 84 5b 10 f0 	mov    -0xfefa47c(,%eax,4),%eax
f0103bd4:	85 c0                	test   %eax,%eax
f0103bd6:	74 1c                	je     f0103bf4 <vprintfmt+0x13c>
				printfmt(putch, putdat, "%s", p);
f0103bd8:	50                   	push   %eax
f0103bd9:	68 83 4a 10 f0       	push   $0xf0104a83
f0103bde:	53                   	push   %ebx
f0103bdf:	56                   	push   %esi
f0103be0:	e8 b6 fe ff ff       	call   f0103a9b <printfmt>
f0103be5:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f0103be8:	89 7d 14             	mov    %edi,0x14(%ebp)
f0103beb:	e9 37 02 00 00       	jmp    f0103e27 <vprintfmt+0x36f>
f0103bf0:	f7 d8                	neg    %eax
f0103bf2:	eb d2                	jmp    f0103bc6 <vprintfmt+0x10e>
				printfmt(putch, putdat, "error %d", err);
f0103bf4:	52                   	push   %edx
f0103bf5:	68 b9 59 10 f0       	push   $0xf01059b9
f0103bfa:	53                   	push   %ebx
f0103bfb:	56                   	push   %esi
f0103bfc:	e8 9a fe ff ff       	call   f0103a9b <printfmt>
f0103c01:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f0103c04:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
f0103c07:	e9 1b 02 00 00       	jmp    f0103e27 <vprintfmt+0x36f>
			if ((p = va_arg(ap, char *)) == NULL)
f0103c0c:	8b 45 14             	mov    0x14(%ebp),%eax
f0103c0f:	83 c0 04             	add    $0x4,%eax
f0103c12:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0103c15:	8b 45 14             	mov    0x14(%ebp),%eax
f0103c18:	8b 00                	mov    (%eax),%eax
f0103c1a:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0103c1d:	85 c0                	test   %eax,%eax
f0103c1f:	74 19                	je     f0103c3a <vprintfmt+0x182>
			if (width > 0 && padc != '-')
f0103c21:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f0103c25:	7e 06                	jle    f0103c2d <vprintfmt+0x175>
f0103c27:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
f0103c2b:	75 16                	jne    f0103c43 <vprintfmt+0x18b>
				for (width -= strnlen(p, precision); width > 0; width--)
f0103c2d:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0103c30:	89 c7                	mov    %eax,%edi
f0103c32:	03 45 d4             	add    -0x2c(%ebp),%eax
f0103c35:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0103c38:	eb 62                	jmp    f0103c9c <vprintfmt+0x1e4>
				p = "(null)";
f0103c3a:	c7 45 cc b2 59 10 f0 	movl   $0xf01059b2,-0x34(%ebp)
f0103c41:	eb de                	jmp    f0103c21 <vprintfmt+0x169>
				for (width -= strnlen(p, precision); width > 0; width--)
f0103c43:	83 ec 08             	sub    $0x8,%esp
f0103c46:	ff 75 d8             	pushl  -0x28(%ebp)
f0103c49:	ff 75 cc             	pushl  -0x34(%ebp)
f0103c4c:	e8 e2 03 00 00       	call   f0104033 <strnlen>
f0103c51:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0103c54:	29 c2                	sub    %eax,%edx
f0103c56:	89 55 c4             	mov    %edx,-0x3c(%ebp)
f0103c59:	83 c4 10             	add    $0x10,%esp
f0103c5c:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
f0103c5e:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
f0103c62:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
f0103c65:	eb 0d                	jmp    f0103c74 <vprintfmt+0x1bc>
					putch(padc, putdat);
f0103c67:	83 ec 08             	sub    $0x8,%esp
f0103c6a:	53                   	push   %ebx
f0103c6b:	ff 75 d4             	pushl  -0x2c(%ebp)
f0103c6e:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
f0103c70:	4f                   	dec    %edi
f0103c71:	83 c4 10             	add    $0x10,%esp
f0103c74:	85 ff                	test   %edi,%edi
f0103c76:	7f ef                	jg     f0103c67 <vprintfmt+0x1af>
f0103c78:	8b 55 c4             	mov    -0x3c(%ebp),%edx
f0103c7b:	89 d0                	mov    %edx,%eax
f0103c7d:	85 d2                	test   %edx,%edx
f0103c7f:	78 0a                	js     f0103c8b <vprintfmt+0x1d3>
f0103c81:	8b 55 c4             	mov    -0x3c(%ebp),%edx
f0103c84:	29 c2                	sub    %eax,%edx
f0103c86:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f0103c89:	eb a2                	jmp    f0103c2d <vprintfmt+0x175>
f0103c8b:	b8 00 00 00 00       	mov    $0x0,%eax
f0103c90:	eb ef                	jmp    f0103c81 <vprintfmt+0x1c9>
					putch(ch, putdat);
f0103c92:	83 ec 08             	sub    $0x8,%esp
f0103c95:	53                   	push   %ebx
f0103c96:	52                   	push   %edx
f0103c97:	ff d6                	call   *%esi
f0103c99:	83 c4 10             	add    $0x10,%esp
f0103c9c:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0103c9f:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0103ca1:	47                   	inc    %edi
f0103ca2:	8a 47 ff             	mov    -0x1(%edi),%al
f0103ca5:	0f be d0             	movsbl %al,%edx
f0103ca8:	85 d2                	test   %edx,%edx
f0103caa:	74 48                	je     f0103cf4 <vprintfmt+0x23c>
f0103cac:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0103cb0:	78 05                	js     f0103cb7 <vprintfmt+0x1ff>
f0103cb2:	ff 4d d8             	decl   -0x28(%ebp)
f0103cb5:	78 1e                	js     f0103cd5 <vprintfmt+0x21d>
				if (altflag && (ch < ' ' || ch > '~'))
f0103cb7:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0103cbb:	74 d5                	je     f0103c92 <vprintfmt+0x1da>
f0103cbd:	0f be c0             	movsbl %al,%eax
f0103cc0:	83 e8 20             	sub    $0x20,%eax
f0103cc3:	83 f8 5e             	cmp    $0x5e,%eax
f0103cc6:	76 ca                	jbe    f0103c92 <vprintfmt+0x1da>
					putch('?', putdat);
f0103cc8:	83 ec 08             	sub    $0x8,%esp
f0103ccb:	53                   	push   %ebx
f0103ccc:	6a 3f                	push   $0x3f
f0103cce:	ff d6                	call   *%esi
f0103cd0:	83 c4 10             	add    $0x10,%esp
f0103cd3:	eb c7                	jmp    f0103c9c <vprintfmt+0x1e4>
f0103cd5:	89 cf                	mov    %ecx,%edi
f0103cd7:	eb 0c                	jmp    f0103ce5 <vprintfmt+0x22d>
				putch(' ', putdat);
f0103cd9:	83 ec 08             	sub    $0x8,%esp
f0103cdc:	53                   	push   %ebx
f0103cdd:	6a 20                	push   $0x20
f0103cdf:	ff d6                	call   *%esi
			for (; width > 0; width--)
f0103ce1:	4f                   	dec    %edi
f0103ce2:	83 c4 10             	add    $0x10,%esp
f0103ce5:	85 ff                	test   %edi,%edi
f0103ce7:	7f f0                	jg     f0103cd9 <vprintfmt+0x221>
			if ((p = va_arg(ap, char *)) == NULL)
f0103ce9:	8b 45 c8             	mov    -0x38(%ebp),%eax
f0103cec:	89 45 14             	mov    %eax,0x14(%ebp)
f0103cef:	e9 33 01 00 00       	jmp    f0103e27 <vprintfmt+0x36f>
f0103cf4:	89 cf                	mov    %ecx,%edi
f0103cf6:	eb ed                	jmp    f0103ce5 <vprintfmt+0x22d>
	if (lflag >= 2)
f0103cf8:	83 f9 01             	cmp    $0x1,%ecx
f0103cfb:	7f 1b                	jg     f0103d18 <vprintfmt+0x260>
	else if (lflag)
f0103cfd:	85 c9                	test   %ecx,%ecx
f0103cff:	74 42                	je     f0103d43 <vprintfmt+0x28b>
		return va_arg(*ap, long);
f0103d01:	8b 45 14             	mov    0x14(%ebp),%eax
f0103d04:	8b 00                	mov    (%eax),%eax
f0103d06:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0103d09:	99                   	cltd   
f0103d0a:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0103d0d:	8b 45 14             	mov    0x14(%ebp),%eax
f0103d10:	8d 40 04             	lea    0x4(%eax),%eax
f0103d13:	89 45 14             	mov    %eax,0x14(%ebp)
f0103d16:	eb 17                	jmp    f0103d2f <vprintfmt+0x277>
		return va_arg(*ap, long long);
f0103d18:	8b 45 14             	mov    0x14(%ebp),%eax
f0103d1b:	8b 50 04             	mov    0x4(%eax),%edx
f0103d1e:	8b 00                	mov    (%eax),%eax
f0103d20:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0103d23:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0103d26:	8b 45 14             	mov    0x14(%ebp),%eax
f0103d29:	8d 40 08             	lea    0x8(%eax),%eax
f0103d2c:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
f0103d2f:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0103d32:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f0103d35:	85 c9                	test   %ecx,%ecx
f0103d37:	78 21                	js     f0103d5a <vprintfmt+0x2a2>
			base = 10;
f0103d39:	b8 0a 00 00 00       	mov    $0xa,%eax
f0103d3e:	e9 ca 00 00 00       	jmp    f0103e0d <vprintfmt+0x355>
		return va_arg(*ap, int);
f0103d43:	8b 45 14             	mov    0x14(%ebp),%eax
f0103d46:	8b 00                	mov    (%eax),%eax
f0103d48:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0103d4b:	99                   	cltd   
f0103d4c:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0103d4f:	8b 45 14             	mov    0x14(%ebp),%eax
f0103d52:	8d 40 04             	lea    0x4(%eax),%eax
f0103d55:	89 45 14             	mov    %eax,0x14(%ebp)
f0103d58:	eb d5                	jmp    f0103d2f <vprintfmt+0x277>
				putch('-', putdat);
f0103d5a:	83 ec 08             	sub    $0x8,%esp
f0103d5d:	53                   	push   %ebx
f0103d5e:	6a 2d                	push   $0x2d
f0103d60:	ff d6                	call   *%esi
				num = -(long long) num;
f0103d62:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0103d65:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f0103d68:	f7 da                	neg    %edx
f0103d6a:	83 d1 00             	adc    $0x0,%ecx
f0103d6d:	f7 d9                	neg    %ecx
f0103d6f:	83 c4 10             	add    $0x10,%esp
			base = 10;
f0103d72:	b8 0a 00 00 00       	mov    $0xa,%eax
f0103d77:	e9 91 00 00 00       	jmp    f0103e0d <vprintfmt+0x355>
	if (lflag >= 2)
f0103d7c:	83 f9 01             	cmp    $0x1,%ecx
f0103d7f:	7f 1b                	jg     f0103d9c <vprintfmt+0x2e4>
	else if (lflag)
f0103d81:	85 c9                	test   %ecx,%ecx
f0103d83:	74 2c                	je     f0103db1 <vprintfmt+0x2f9>
		return va_arg(*ap, unsigned long);
f0103d85:	8b 45 14             	mov    0x14(%ebp),%eax
f0103d88:	8b 10                	mov    (%eax),%edx
f0103d8a:	b9 00 00 00 00       	mov    $0x0,%ecx
f0103d8f:	8d 40 04             	lea    0x4(%eax),%eax
f0103d92:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0103d95:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
f0103d9a:	eb 71                	jmp    f0103e0d <vprintfmt+0x355>
		return va_arg(*ap, unsigned long long);
f0103d9c:	8b 45 14             	mov    0x14(%ebp),%eax
f0103d9f:	8b 10                	mov    (%eax),%edx
f0103da1:	8b 48 04             	mov    0x4(%eax),%ecx
f0103da4:	8d 40 08             	lea    0x8(%eax),%eax
f0103da7:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0103daa:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
f0103daf:	eb 5c                	jmp    f0103e0d <vprintfmt+0x355>
		return va_arg(*ap, unsigned int);
f0103db1:	8b 45 14             	mov    0x14(%ebp),%eax
f0103db4:	8b 10                	mov    (%eax),%edx
f0103db6:	b9 00 00 00 00       	mov    $0x0,%ecx
f0103dbb:	8d 40 04             	lea    0x4(%eax),%eax
f0103dbe:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0103dc1:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
f0103dc6:	eb 45                	jmp    f0103e0d <vprintfmt+0x355>
			putch('X', putdat);
f0103dc8:	83 ec 08             	sub    $0x8,%esp
f0103dcb:	53                   	push   %ebx
f0103dcc:	6a 58                	push   $0x58
f0103dce:	ff d6                	call   *%esi
			putch('X', putdat);
f0103dd0:	83 c4 08             	add    $0x8,%esp
f0103dd3:	53                   	push   %ebx
f0103dd4:	6a 58                	push   $0x58
f0103dd6:	ff d6                	call   *%esi
			putch('X', putdat);
f0103dd8:	83 c4 08             	add    $0x8,%esp
f0103ddb:	53                   	push   %ebx
f0103ddc:	6a 58                	push   $0x58
f0103dde:	ff d6                	call   *%esi
			break;
f0103de0:	83 c4 10             	add    $0x10,%esp
f0103de3:	eb 42                	jmp    f0103e27 <vprintfmt+0x36f>
			putch('0', putdat);
f0103de5:	83 ec 08             	sub    $0x8,%esp
f0103de8:	53                   	push   %ebx
f0103de9:	6a 30                	push   $0x30
f0103deb:	ff d6                	call   *%esi
			putch('x', putdat);
f0103ded:	83 c4 08             	add    $0x8,%esp
f0103df0:	53                   	push   %ebx
f0103df1:	6a 78                	push   $0x78
f0103df3:	ff d6                	call   *%esi
			num = (unsigned long long)
f0103df5:	8b 45 14             	mov    0x14(%ebp),%eax
f0103df8:	8b 10                	mov    (%eax),%edx
f0103dfa:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
f0103dff:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
f0103e02:	8d 40 04             	lea    0x4(%eax),%eax
f0103e05:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0103e08:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
f0103e0d:	83 ec 0c             	sub    $0xc,%esp
f0103e10:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
f0103e14:	57                   	push   %edi
f0103e15:	ff 75 d4             	pushl  -0x2c(%ebp)
f0103e18:	50                   	push   %eax
f0103e19:	51                   	push   %ecx
f0103e1a:	52                   	push   %edx
f0103e1b:	89 da                	mov    %ebx,%edx
f0103e1d:	89 f0                	mov    %esi,%eax
f0103e1f:	e8 b6 fb ff ff       	call   f01039da <printnum>
			break;
f0103e24:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
f0103e27:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0103e2a:	47                   	inc    %edi
f0103e2b:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0103e2f:	83 f8 25             	cmp    $0x25,%eax
f0103e32:	0f 84 97 fc ff ff    	je     f0103acf <vprintfmt+0x17>
			if (ch == '\0')
f0103e38:	85 c0                	test   %eax,%eax
f0103e3a:	0f 84 89 00 00 00    	je     f0103ec9 <vprintfmt+0x411>
			putch(ch, putdat);
f0103e40:	83 ec 08             	sub    $0x8,%esp
f0103e43:	53                   	push   %ebx
f0103e44:	50                   	push   %eax
f0103e45:	ff d6                	call   *%esi
f0103e47:	83 c4 10             	add    $0x10,%esp
f0103e4a:	eb de                	jmp    f0103e2a <vprintfmt+0x372>
	if (lflag >= 2)
f0103e4c:	83 f9 01             	cmp    $0x1,%ecx
f0103e4f:	7f 1b                	jg     f0103e6c <vprintfmt+0x3b4>
	else if (lflag)
f0103e51:	85 c9                	test   %ecx,%ecx
f0103e53:	74 2c                	je     f0103e81 <vprintfmt+0x3c9>
		return va_arg(*ap, unsigned long);
f0103e55:	8b 45 14             	mov    0x14(%ebp),%eax
f0103e58:	8b 10                	mov    (%eax),%edx
f0103e5a:	b9 00 00 00 00       	mov    $0x0,%ecx
f0103e5f:	8d 40 04             	lea    0x4(%eax),%eax
f0103e62:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0103e65:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
f0103e6a:	eb a1                	jmp    f0103e0d <vprintfmt+0x355>
		return va_arg(*ap, unsigned long long);
f0103e6c:	8b 45 14             	mov    0x14(%ebp),%eax
f0103e6f:	8b 10                	mov    (%eax),%edx
f0103e71:	8b 48 04             	mov    0x4(%eax),%ecx
f0103e74:	8d 40 08             	lea    0x8(%eax),%eax
f0103e77:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0103e7a:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
f0103e7f:	eb 8c                	jmp    f0103e0d <vprintfmt+0x355>
		return va_arg(*ap, unsigned int);
f0103e81:	8b 45 14             	mov    0x14(%ebp),%eax
f0103e84:	8b 10                	mov    (%eax),%edx
f0103e86:	b9 00 00 00 00       	mov    $0x0,%ecx
f0103e8b:	8d 40 04             	lea    0x4(%eax),%eax
f0103e8e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0103e91:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
f0103e96:	e9 72 ff ff ff       	jmp    f0103e0d <vprintfmt+0x355>
			putch(ch, putdat);
f0103e9b:	83 ec 08             	sub    $0x8,%esp
f0103e9e:	53                   	push   %ebx
f0103e9f:	6a 25                	push   $0x25
f0103ea1:	ff d6                	call   *%esi
			break;
f0103ea3:	83 c4 10             	add    $0x10,%esp
f0103ea6:	e9 7c ff ff ff       	jmp    f0103e27 <vprintfmt+0x36f>
			putch('%', putdat);
f0103eab:	83 ec 08             	sub    $0x8,%esp
f0103eae:	53                   	push   %ebx
f0103eaf:	6a 25                	push   $0x25
f0103eb1:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f0103eb3:	83 c4 10             	add    $0x10,%esp
f0103eb6:	89 f8                	mov    %edi,%eax
f0103eb8:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
f0103ebc:	74 03                	je     f0103ec1 <vprintfmt+0x409>
f0103ebe:	48                   	dec    %eax
f0103ebf:	eb f7                	jmp    f0103eb8 <vprintfmt+0x400>
f0103ec1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0103ec4:	e9 5e ff ff ff       	jmp    f0103e27 <vprintfmt+0x36f>
}
f0103ec9:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103ecc:	5b                   	pop    %ebx
f0103ecd:	5e                   	pop    %esi
f0103ece:	5f                   	pop    %edi
f0103ecf:	5d                   	pop    %ebp
f0103ed0:	c3                   	ret    

f0103ed1 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0103ed1:	55                   	push   %ebp
f0103ed2:	89 e5                	mov    %esp,%ebp
f0103ed4:	83 ec 18             	sub    $0x18,%esp
f0103ed7:	8b 45 08             	mov    0x8(%ebp),%eax
f0103eda:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0103edd:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0103ee0:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0103ee4:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0103ee7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0103eee:	85 c0                	test   %eax,%eax
f0103ef0:	74 26                	je     f0103f18 <vsnprintf+0x47>
f0103ef2:	85 d2                	test   %edx,%edx
f0103ef4:	7e 29                	jle    f0103f1f <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0103ef6:	ff 75 14             	pushl  0x14(%ebp)
f0103ef9:	ff 75 10             	pushl  0x10(%ebp)
f0103efc:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0103eff:	50                   	push   %eax
f0103f00:	68 7f 3a 10 f0       	push   $0xf0103a7f
f0103f05:	e8 ae fb ff ff       	call   f0103ab8 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0103f0a:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0103f0d:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0103f10:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103f13:	83 c4 10             	add    $0x10,%esp
}
f0103f16:	c9                   	leave  
f0103f17:	c3                   	ret    
		return -E_INVAL;
f0103f18:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0103f1d:	eb f7                	jmp    f0103f16 <vsnprintf+0x45>
f0103f1f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0103f24:	eb f0                	jmp    f0103f16 <vsnprintf+0x45>

f0103f26 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0103f26:	55                   	push   %ebp
f0103f27:	89 e5                	mov    %esp,%ebp
f0103f29:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0103f2c:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0103f2f:	50                   	push   %eax
f0103f30:	ff 75 10             	pushl  0x10(%ebp)
f0103f33:	ff 75 0c             	pushl  0xc(%ebp)
f0103f36:	ff 75 08             	pushl  0x8(%ebp)
f0103f39:	e8 93 ff ff ff       	call   f0103ed1 <vsnprintf>
	va_end(ap);

	return rc;
}
f0103f3e:	c9                   	leave  
f0103f3f:	c3                   	ret    

f0103f40 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0103f40:	55                   	push   %ebp
f0103f41:	89 e5                	mov    %esp,%ebp
f0103f43:	57                   	push   %edi
f0103f44:	56                   	push   %esi
f0103f45:	53                   	push   %ebx
f0103f46:	83 ec 0c             	sub    $0xc,%esp
f0103f49:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f0103f4c:	85 c0                	test   %eax,%eax
f0103f4e:	74 11                	je     f0103f61 <readline+0x21>
		cprintf("%s", prompt);
f0103f50:	83 ec 08             	sub    $0x8,%esp
f0103f53:	50                   	push   %eax
f0103f54:	68 83 4a 10 f0       	push   $0xf0104a83
f0103f59:	e8 f7 ef ff ff       	call   f0102f55 <cprintf>
f0103f5e:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f0103f61:	83 ec 0c             	sub    $0xc,%esp
f0103f64:	6a 00                	push   $0x0
f0103f66:	e8 91 c6 ff ff       	call   f01005fc <iscons>
f0103f6b:	89 c7                	mov    %eax,%edi
f0103f6d:	83 c4 10             	add    $0x10,%esp
	i = 0;
f0103f70:	be 00 00 00 00       	mov    $0x0,%esi
f0103f75:	eb 75                	jmp    f0103fec <readline+0xac>
	while (1) {
		c = getchar();
		if (c < 0) {
			cprintf("read error: %e\n", c);
f0103f77:	83 ec 08             	sub    $0x8,%esp
f0103f7a:	50                   	push   %eax
f0103f7b:	68 a0 5b 10 f0       	push   $0xf0105ba0
f0103f80:	e8 d0 ef ff ff       	call   f0102f55 <cprintf>
			return NULL;
f0103f85:	83 c4 10             	add    $0x10,%esp
f0103f88:	b8 00 00 00 00       	mov    $0x0,%eax
				cputchar('\n');
			buf[i] = 0;
			return buf;
		}
	}
}
f0103f8d:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103f90:	5b                   	pop    %ebx
f0103f91:	5e                   	pop    %esi
f0103f92:	5f                   	pop    %edi
f0103f93:	5d                   	pop    %ebp
f0103f94:	c3                   	ret    
				cputchar('\b');
f0103f95:	83 ec 0c             	sub    $0xc,%esp
f0103f98:	6a 08                	push   $0x8
f0103f9a:	e8 3c c6 ff ff       	call   f01005db <cputchar>
f0103f9f:	83 c4 10             	add    $0x10,%esp
f0103fa2:	eb 47                	jmp    f0103feb <readline+0xab>
				cputchar(c);
f0103fa4:	83 ec 0c             	sub    $0xc,%esp
f0103fa7:	53                   	push   %ebx
f0103fa8:	e8 2e c6 ff ff       	call   f01005db <cputchar>
f0103fad:	83 c4 10             	add    $0x10,%esp
f0103fb0:	eb 60                	jmp    f0104012 <readline+0xd2>
		} else if (c == '\n' || c == '\r') {
f0103fb2:	83 f8 0a             	cmp    $0xa,%eax
f0103fb5:	74 05                	je     f0103fbc <readline+0x7c>
f0103fb7:	83 f8 0d             	cmp    $0xd,%eax
f0103fba:	75 30                	jne    f0103fec <readline+0xac>
			if (echoing)
f0103fbc:	85 ff                	test   %edi,%edi
f0103fbe:	75 0e                	jne    f0103fce <readline+0x8e>
			buf[i] = 0;
f0103fc0:	c6 86 00 16 1b f0 00 	movb   $0x0,-0xfe4ea00(%esi)
			return buf;
f0103fc7:	b8 00 16 1b f0       	mov    $0xf01b1600,%eax
f0103fcc:	eb bf                	jmp    f0103f8d <readline+0x4d>
				cputchar('\n');
f0103fce:	83 ec 0c             	sub    $0xc,%esp
f0103fd1:	6a 0a                	push   $0xa
f0103fd3:	e8 03 c6 ff ff       	call   f01005db <cputchar>
f0103fd8:	83 c4 10             	add    $0x10,%esp
f0103fdb:	eb e3                	jmp    f0103fc0 <readline+0x80>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0103fdd:	85 f6                	test   %esi,%esi
f0103fdf:	7f 06                	jg     f0103fe7 <readline+0xa7>
f0103fe1:	eb 23                	jmp    f0104006 <readline+0xc6>
f0103fe3:	85 f6                	test   %esi,%esi
f0103fe5:	7e 05                	jle    f0103fec <readline+0xac>
			if (echoing)
f0103fe7:	85 ff                	test   %edi,%edi
f0103fe9:	75 aa                	jne    f0103f95 <readline+0x55>
			i--;
f0103feb:	4e                   	dec    %esi
		c = getchar();
f0103fec:	e8 fa c5 ff ff       	call   f01005eb <getchar>
f0103ff1:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f0103ff3:	85 c0                	test   %eax,%eax
f0103ff5:	78 80                	js     f0103f77 <readline+0x37>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0103ff7:	83 f8 08             	cmp    $0x8,%eax
f0103ffa:	74 e7                	je     f0103fe3 <readline+0xa3>
f0103ffc:	83 f8 7f             	cmp    $0x7f,%eax
f0103fff:	74 dc                	je     f0103fdd <readline+0x9d>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0104001:	83 f8 1f             	cmp    $0x1f,%eax
f0104004:	7e ac                	jle    f0103fb2 <readline+0x72>
f0104006:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f010400c:	7f de                	jg     f0103fec <readline+0xac>
			if (echoing)
f010400e:	85 ff                	test   %edi,%edi
f0104010:	75 92                	jne    f0103fa4 <readline+0x64>
			buf[i++] = c;
f0104012:	88 9e 00 16 1b f0    	mov    %bl,-0xfe4ea00(%esi)
f0104018:	8d 76 01             	lea    0x1(%esi),%esi
f010401b:	eb cf                	jmp    f0103fec <readline+0xac>

f010401d <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f010401d:	55                   	push   %ebp
f010401e:	89 e5                	mov    %esp,%ebp
f0104020:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0104023:	b8 00 00 00 00       	mov    $0x0,%eax
f0104028:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f010402c:	74 03                	je     f0104031 <strlen+0x14>
		n++;
f010402e:	40                   	inc    %eax
f010402f:	eb f7                	jmp    f0104028 <strlen+0xb>
	return n;
}
f0104031:	5d                   	pop    %ebp
f0104032:	c3                   	ret    

f0104033 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0104033:	55                   	push   %ebp
f0104034:	89 e5                	mov    %esp,%ebp
f0104036:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0104039:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f010403c:	b8 00 00 00 00       	mov    $0x0,%eax
f0104041:	39 d0                	cmp    %edx,%eax
f0104043:	74 0b                	je     f0104050 <strnlen+0x1d>
f0104045:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f0104049:	74 03                	je     f010404e <strnlen+0x1b>
		n++;
f010404b:	40                   	inc    %eax
f010404c:	eb f3                	jmp    f0104041 <strnlen+0xe>
f010404e:	89 c2                	mov    %eax,%edx
	return n;
}
f0104050:	89 d0                	mov    %edx,%eax
f0104052:	5d                   	pop    %ebp
f0104053:	c3                   	ret    

f0104054 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0104054:	55                   	push   %ebp
f0104055:	89 e5                	mov    %esp,%ebp
f0104057:	53                   	push   %ebx
f0104058:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010405b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f010405e:	b8 00 00 00 00       	mov    $0x0,%eax
f0104063:	8a 14 03             	mov    (%ebx,%eax,1),%dl
f0104066:	88 14 01             	mov    %dl,(%ecx,%eax,1)
f0104069:	40                   	inc    %eax
f010406a:	84 d2                	test   %dl,%dl
f010406c:	75 f5                	jne    f0104063 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
f010406e:	89 c8                	mov    %ecx,%eax
f0104070:	5b                   	pop    %ebx
f0104071:	5d                   	pop    %ebp
f0104072:	c3                   	ret    

f0104073 <strcat>:

char *
strcat(char *dst, const char *src)
{
f0104073:	55                   	push   %ebp
f0104074:	89 e5                	mov    %esp,%ebp
f0104076:	53                   	push   %ebx
f0104077:	83 ec 10             	sub    $0x10,%esp
f010407a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f010407d:	53                   	push   %ebx
f010407e:	e8 9a ff ff ff       	call   f010401d <strlen>
f0104083:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
f0104086:	ff 75 0c             	pushl  0xc(%ebp)
f0104089:	01 d8                	add    %ebx,%eax
f010408b:	50                   	push   %eax
f010408c:	e8 c3 ff ff ff       	call   f0104054 <strcpy>
	return dst;
}
f0104091:	89 d8                	mov    %ebx,%eax
f0104093:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0104096:	c9                   	leave  
f0104097:	c3                   	ret    

f0104098 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0104098:	55                   	push   %ebp
f0104099:	89 e5                	mov    %esp,%ebp
f010409b:	53                   	push   %ebx
f010409c:	8b 55 0c             	mov    0xc(%ebp),%edx
f010409f:	8b 5d 08             	mov    0x8(%ebp),%ebx
f01040a2:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f01040a5:	8b 45 08             	mov    0x8(%ebp),%eax
f01040a8:	39 d8                	cmp    %ebx,%eax
f01040aa:	74 0e                	je     f01040ba <strncpy+0x22>
		*dst++ = *src;
f01040ac:	40                   	inc    %eax
f01040ad:	8a 0a                	mov    (%edx),%cl
f01040af:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f01040b2:	80 f9 01             	cmp    $0x1,%cl
f01040b5:	83 da ff             	sbb    $0xffffffff,%edx
f01040b8:	eb ee                	jmp    f01040a8 <strncpy+0x10>
	}
	return ret;
}
f01040ba:	8b 45 08             	mov    0x8(%ebp),%eax
f01040bd:	5b                   	pop    %ebx
f01040be:	5d                   	pop    %ebp
f01040bf:	c3                   	ret    

f01040c0 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f01040c0:	55                   	push   %ebp
f01040c1:	89 e5                	mov    %esp,%ebp
f01040c3:	56                   	push   %esi
f01040c4:	53                   	push   %ebx
f01040c5:	8b 75 08             	mov    0x8(%ebp),%esi
f01040c8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01040cb:	8b 45 10             	mov    0x10(%ebp),%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f01040ce:	85 c0                	test   %eax,%eax
f01040d0:	74 22                	je     f01040f4 <strlcpy+0x34>
f01040d2:	8d 44 06 ff          	lea    -0x1(%esi,%eax,1),%eax
f01040d6:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
f01040d8:	39 c2                	cmp    %eax,%edx
f01040da:	74 0f                	je     f01040eb <strlcpy+0x2b>
f01040dc:	8a 19                	mov    (%ecx),%bl
f01040de:	84 db                	test   %bl,%bl
f01040e0:	74 07                	je     f01040e9 <strlcpy+0x29>
			*dst++ = *src++;
f01040e2:	41                   	inc    %ecx
f01040e3:	42                   	inc    %edx
f01040e4:	88 5a ff             	mov    %bl,-0x1(%edx)
f01040e7:	eb ef                	jmp    f01040d8 <strlcpy+0x18>
f01040e9:	89 d0                	mov    %edx,%eax
		*dst = '\0';
f01040eb:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f01040ee:	29 f0                	sub    %esi,%eax
}
f01040f0:	5b                   	pop    %ebx
f01040f1:	5e                   	pop    %esi
f01040f2:	5d                   	pop    %ebp
f01040f3:	c3                   	ret    
f01040f4:	89 f0                	mov    %esi,%eax
f01040f6:	eb f6                	jmp    f01040ee <strlcpy+0x2e>

f01040f8 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f01040f8:	55                   	push   %ebp
f01040f9:	89 e5                	mov    %esp,%ebp
f01040fb:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01040fe:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0104101:	8a 01                	mov    (%ecx),%al
f0104103:	84 c0                	test   %al,%al
f0104105:	74 08                	je     f010410f <strcmp+0x17>
f0104107:	3a 02                	cmp    (%edx),%al
f0104109:	75 04                	jne    f010410f <strcmp+0x17>
		p++, q++;
f010410b:	41                   	inc    %ecx
f010410c:	42                   	inc    %edx
f010410d:	eb f2                	jmp    f0104101 <strcmp+0x9>
	return (int) ((unsigned char) *p - (unsigned char) *q);
f010410f:	0f b6 c0             	movzbl %al,%eax
f0104112:	0f b6 12             	movzbl (%edx),%edx
f0104115:	29 d0                	sub    %edx,%eax
}
f0104117:	5d                   	pop    %ebp
f0104118:	c3                   	ret    

f0104119 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0104119:	55                   	push   %ebp
f010411a:	89 e5                	mov    %esp,%ebp
f010411c:	53                   	push   %ebx
f010411d:	8b 45 08             	mov    0x8(%ebp),%eax
f0104120:	8b 55 0c             	mov    0xc(%ebp),%edx
f0104123:	89 c3                	mov    %eax,%ebx
f0104125:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f0104128:	eb 02                	jmp    f010412c <strncmp+0x13>
		n--, p++, q++;
f010412a:	40                   	inc    %eax
f010412b:	42                   	inc    %edx
	while (n > 0 && *p && *p == *q)
f010412c:	39 d8                	cmp    %ebx,%eax
f010412e:	74 15                	je     f0104145 <strncmp+0x2c>
f0104130:	8a 08                	mov    (%eax),%cl
f0104132:	84 c9                	test   %cl,%cl
f0104134:	74 04                	je     f010413a <strncmp+0x21>
f0104136:	3a 0a                	cmp    (%edx),%cl
f0104138:	74 f0                	je     f010412a <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f010413a:	0f b6 00             	movzbl (%eax),%eax
f010413d:	0f b6 12             	movzbl (%edx),%edx
f0104140:	29 d0                	sub    %edx,%eax
}
f0104142:	5b                   	pop    %ebx
f0104143:	5d                   	pop    %ebp
f0104144:	c3                   	ret    
		return 0;
f0104145:	b8 00 00 00 00       	mov    $0x0,%eax
f010414a:	eb f6                	jmp    f0104142 <strncmp+0x29>

f010414c <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f010414c:	55                   	push   %ebp
f010414d:	89 e5                	mov    %esp,%ebp
f010414f:	8b 45 08             	mov    0x8(%ebp),%eax
f0104152:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
f0104155:	8a 10                	mov    (%eax),%dl
f0104157:	84 d2                	test   %dl,%dl
f0104159:	74 07                	je     f0104162 <strchr+0x16>
		if (*s == c)
f010415b:	38 ca                	cmp    %cl,%dl
f010415d:	74 08                	je     f0104167 <strchr+0x1b>
	for (; *s; s++)
f010415f:	40                   	inc    %eax
f0104160:	eb f3                	jmp    f0104155 <strchr+0x9>
			return (char *) s;
	return 0;
f0104162:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0104167:	5d                   	pop    %ebp
f0104168:	c3                   	ret    

f0104169 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0104169:	55                   	push   %ebp
f010416a:	89 e5                	mov    %esp,%ebp
f010416c:	8b 45 08             	mov    0x8(%ebp),%eax
f010416f:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
f0104172:	8a 10                	mov    (%eax),%dl
f0104174:	84 d2                	test   %dl,%dl
f0104176:	74 07                	je     f010417f <strfind+0x16>
		if (*s == c)
f0104178:	38 ca                	cmp    %cl,%dl
f010417a:	74 03                	je     f010417f <strfind+0x16>
	for (; *s; s++)
f010417c:	40                   	inc    %eax
f010417d:	eb f3                	jmp    f0104172 <strfind+0x9>
			break;
	return (char *) s;
}
f010417f:	5d                   	pop    %ebp
f0104180:	c3                   	ret    

f0104181 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0104181:	55                   	push   %ebp
f0104182:	89 e5                	mov    %esp,%ebp
f0104184:	57                   	push   %edi
f0104185:	56                   	push   %esi
f0104186:	53                   	push   %ebx
f0104187:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f010418a:	85 c9                	test   %ecx,%ecx
f010418c:	74 36                	je     f01041c4 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f010418e:	89 c8                	mov    %ecx,%eax
f0104190:	0b 45 08             	or     0x8(%ebp),%eax
f0104193:	a8 03                	test   $0x3,%al
f0104195:	75 24                	jne    f01041bb <memset+0x3a>
		c &= 0xFF;
f0104197:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f010419b:	89 d3                	mov    %edx,%ebx
f010419d:	c1 e3 08             	shl    $0x8,%ebx
f01041a0:	89 d0                	mov    %edx,%eax
f01041a2:	c1 e0 18             	shl    $0x18,%eax
f01041a5:	89 d6                	mov    %edx,%esi
f01041a7:	c1 e6 10             	shl    $0x10,%esi
f01041aa:	09 f0                	or     %esi,%eax
f01041ac:	09 d0                	or     %edx,%eax
f01041ae:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f01041b0:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
f01041b3:	8b 7d 08             	mov    0x8(%ebp),%edi
f01041b6:	fc                   	cld    
f01041b7:	f3 ab                	rep stos %eax,%es:(%edi)
f01041b9:	eb 09                	jmp    f01041c4 <memset+0x43>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f01041bb:	8b 7d 08             	mov    0x8(%ebp),%edi
f01041be:	8b 45 0c             	mov    0xc(%ebp),%eax
f01041c1:	fc                   	cld    
f01041c2:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f01041c4:	8b 45 08             	mov    0x8(%ebp),%eax
f01041c7:	5b                   	pop    %ebx
f01041c8:	5e                   	pop    %esi
f01041c9:	5f                   	pop    %edi
f01041ca:	5d                   	pop    %ebp
f01041cb:	c3                   	ret    

f01041cc <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f01041cc:	55                   	push   %ebp
f01041cd:	89 e5                	mov    %esp,%ebp
f01041cf:	57                   	push   %edi
f01041d0:	56                   	push   %esi
f01041d1:	8b 45 08             	mov    0x8(%ebp),%eax
f01041d4:	8b 75 0c             	mov    0xc(%ebp),%esi
f01041d7:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f01041da:	39 c6                	cmp    %eax,%esi
f01041dc:	73 30                	jae    f010420e <memmove+0x42>
f01041de:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f01041e1:	39 c2                	cmp    %eax,%edx
f01041e3:	76 29                	jbe    f010420e <memmove+0x42>
		s += n;
		d += n;
f01041e5:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01041e8:	89 fe                	mov    %edi,%esi
f01041ea:	09 ce                	or     %ecx,%esi
f01041ec:	09 d6                	or     %edx,%esi
f01041ee:	f7 c6 03 00 00 00    	test   $0x3,%esi
f01041f4:	75 0e                	jne    f0104204 <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f01041f6:	83 ef 04             	sub    $0x4,%edi
f01041f9:	8d 72 fc             	lea    -0x4(%edx),%esi
f01041fc:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
f01041ff:	fd                   	std    
f0104200:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0104202:	eb 07                	jmp    f010420b <memmove+0x3f>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f0104204:	4f                   	dec    %edi
f0104205:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
f0104208:	fd                   	std    
f0104209:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f010420b:	fc                   	cld    
f010420c:	eb 1a                	jmp    f0104228 <memmove+0x5c>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f010420e:	89 c2                	mov    %eax,%edx
f0104210:	09 ca                	or     %ecx,%edx
f0104212:	09 f2                	or     %esi,%edx
f0104214:	f6 c2 03             	test   $0x3,%dl
f0104217:	75 0a                	jne    f0104223 <memmove+0x57>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f0104219:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
f010421c:	89 c7                	mov    %eax,%edi
f010421e:	fc                   	cld    
f010421f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0104221:	eb 05                	jmp    f0104228 <memmove+0x5c>
		else
			asm volatile("cld; rep movsb\n"
f0104223:	89 c7                	mov    %eax,%edi
f0104225:	fc                   	cld    
f0104226:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0104228:	5e                   	pop    %esi
f0104229:	5f                   	pop    %edi
f010422a:	5d                   	pop    %ebp
f010422b:	c3                   	ret    

f010422c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f010422c:	55                   	push   %ebp
f010422d:	89 e5                	mov    %esp,%ebp
f010422f:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f0104232:	ff 75 10             	pushl  0x10(%ebp)
f0104235:	ff 75 0c             	pushl  0xc(%ebp)
f0104238:	ff 75 08             	pushl  0x8(%ebp)
f010423b:	e8 8c ff ff ff       	call   f01041cc <memmove>
}
f0104240:	c9                   	leave  
f0104241:	c3                   	ret    

f0104242 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0104242:	55                   	push   %ebp
f0104243:	89 e5                	mov    %esp,%ebp
f0104245:	56                   	push   %esi
f0104246:	53                   	push   %ebx
f0104247:	8b 45 08             	mov    0x8(%ebp),%eax
f010424a:	8b 55 0c             	mov    0xc(%ebp),%edx
f010424d:	89 c6                	mov    %eax,%esi
f010424f:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0104252:	39 f0                	cmp    %esi,%eax
f0104254:	74 16                	je     f010426c <memcmp+0x2a>
		if (*s1 != *s2)
f0104256:	8a 08                	mov    (%eax),%cl
f0104258:	8a 1a                	mov    (%edx),%bl
f010425a:	38 d9                	cmp    %bl,%cl
f010425c:	75 04                	jne    f0104262 <memcmp+0x20>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
f010425e:	40                   	inc    %eax
f010425f:	42                   	inc    %edx
f0104260:	eb f0                	jmp    f0104252 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
f0104262:	0f b6 c1             	movzbl %cl,%eax
f0104265:	0f b6 db             	movzbl %bl,%ebx
f0104268:	29 d8                	sub    %ebx,%eax
f010426a:	eb 05                	jmp    f0104271 <memcmp+0x2f>
	}

	return 0;
f010426c:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0104271:	5b                   	pop    %ebx
f0104272:	5e                   	pop    %esi
f0104273:	5d                   	pop    %ebp
f0104274:	c3                   	ret    

f0104275 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0104275:	55                   	push   %ebp
f0104276:	89 e5                	mov    %esp,%ebp
f0104278:	8b 45 08             	mov    0x8(%ebp),%eax
f010427b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f010427e:	89 c2                	mov    %eax,%edx
f0104280:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f0104283:	39 d0                	cmp    %edx,%eax
f0104285:	73 07                	jae    f010428e <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
f0104287:	38 08                	cmp    %cl,(%eax)
f0104289:	74 03                	je     f010428e <memfind+0x19>
	for (; s < ends; s++)
f010428b:	40                   	inc    %eax
f010428c:	eb f5                	jmp    f0104283 <memfind+0xe>
			break;
	return (void *) s;
}
f010428e:	5d                   	pop    %ebp
f010428f:	c3                   	ret    

f0104290 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0104290:	55                   	push   %ebp
f0104291:	89 e5                	mov    %esp,%ebp
f0104293:	57                   	push   %edi
f0104294:	56                   	push   %esi
f0104295:	53                   	push   %ebx
f0104296:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0104299:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f010429c:	eb 01                	jmp    f010429f <strtol+0xf>
		s++;
f010429e:	41                   	inc    %ecx
	while (*s == ' ' || *s == '\t')
f010429f:	8a 01                	mov    (%ecx),%al
f01042a1:	3c 20                	cmp    $0x20,%al
f01042a3:	74 f9                	je     f010429e <strtol+0xe>
f01042a5:	3c 09                	cmp    $0x9,%al
f01042a7:	74 f5                	je     f010429e <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
f01042a9:	3c 2b                	cmp    $0x2b,%al
f01042ab:	74 24                	je     f01042d1 <strtol+0x41>
		s++;
	else if (*s == '-')
f01042ad:	3c 2d                	cmp    $0x2d,%al
f01042af:	74 28                	je     f01042d9 <strtol+0x49>
	int neg = 0;
f01042b1:	bf 00 00 00 00       	mov    $0x0,%edi
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f01042b6:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f01042bc:	75 09                	jne    f01042c7 <strtol+0x37>
f01042be:	80 39 30             	cmpb   $0x30,(%ecx)
f01042c1:	74 1e                	je     f01042e1 <strtol+0x51>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f01042c3:	85 db                	test   %ebx,%ebx
f01042c5:	74 36                	je     f01042fd <strtol+0x6d>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f01042c7:	b8 00 00 00 00       	mov    $0x0,%eax
f01042cc:	89 5d 10             	mov    %ebx,0x10(%ebp)
f01042cf:	eb 45                	jmp    f0104316 <strtol+0x86>
		s++;
f01042d1:	41                   	inc    %ecx
	int neg = 0;
f01042d2:	bf 00 00 00 00       	mov    $0x0,%edi
f01042d7:	eb dd                	jmp    f01042b6 <strtol+0x26>
		s++, neg = 1;
f01042d9:	41                   	inc    %ecx
f01042da:	bf 01 00 00 00       	mov    $0x1,%edi
f01042df:	eb d5                	jmp    f01042b6 <strtol+0x26>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f01042e1:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f01042e5:	74 0c                	je     f01042f3 <strtol+0x63>
	else if (base == 0 && s[0] == '0')
f01042e7:	85 db                	test   %ebx,%ebx
f01042e9:	75 dc                	jne    f01042c7 <strtol+0x37>
		s++, base = 8;
f01042eb:	41                   	inc    %ecx
f01042ec:	bb 08 00 00 00       	mov    $0x8,%ebx
f01042f1:	eb d4                	jmp    f01042c7 <strtol+0x37>
		s += 2, base = 16;
f01042f3:	83 c1 02             	add    $0x2,%ecx
f01042f6:	bb 10 00 00 00       	mov    $0x10,%ebx
f01042fb:	eb ca                	jmp    f01042c7 <strtol+0x37>
		base = 10;
f01042fd:	bb 0a 00 00 00       	mov    $0xa,%ebx
f0104302:	eb c3                	jmp    f01042c7 <strtol+0x37>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
f0104304:	0f be d2             	movsbl %dl,%edx
f0104307:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f010430a:	3b 55 10             	cmp    0x10(%ebp),%edx
f010430d:	7d 37                	jge    f0104346 <strtol+0xb6>
			break;
		s++, val = (val * base) + dig;
f010430f:	41                   	inc    %ecx
f0104310:	0f af 45 10          	imul   0x10(%ebp),%eax
f0104314:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
f0104316:	8a 11                	mov    (%ecx),%dl
f0104318:	8d 72 d0             	lea    -0x30(%edx),%esi
f010431b:	89 f3                	mov    %esi,%ebx
f010431d:	80 fb 09             	cmp    $0x9,%bl
f0104320:	76 e2                	jbe    f0104304 <strtol+0x74>
		else if (*s >= 'a' && *s <= 'z')
f0104322:	8d 72 9f             	lea    -0x61(%edx),%esi
f0104325:	89 f3                	mov    %esi,%ebx
f0104327:	80 fb 19             	cmp    $0x19,%bl
f010432a:	77 08                	ja     f0104334 <strtol+0xa4>
			dig = *s - 'a' + 10;
f010432c:	0f be d2             	movsbl %dl,%edx
f010432f:	83 ea 57             	sub    $0x57,%edx
f0104332:	eb d6                	jmp    f010430a <strtol+0x7a>
		else if (*s >= 'A' && *s <= 'Z')
f0104334:	8d 72 bf             	lea    -0x41(%edx),%esi
f0104337:	89 f3                	mov    %esi,%ebx
f0104339:	80 fb 19             	cmp    $0x19,%bl
f010433c:	77 08                	ja     f0104346 <strtol+0xb6>
			dig = *s - 'A' + 10;
f010433e:	0f be d2             	movsbl %dl,%edx
f0104341:	83 ea 37             	sub    $0x37,%edx
f0104344:	eb c4                	jmp    f010430a <strtol+0x7a>
		// we don't properly detect overflow!
	}

	if (endptr)
f0104346:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f010434a:	74 05                	je     f0104351 <strtol+0xc1>
		*endptr = (char *) s;
f010434c:	8b 75 0c             	mov    0xc(%ebp),%esi
f010434f:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
f0104351:	85 ff                	test   %edi,%edi
f0104353:	74 02                	je     f0104357 <strtol+0xc7>
f0104355:	f7 d8                	neg    %eax
}
f0104357:	5b                   	pop    %ebx
f0104358:	5e                   	pop    %esi
f0104359:	5f                   	pop    %edi
f010435a:	5d                   	pop    %ebp
f010435b:	c3                   	ret    

f010435c <__udivdi3>:
f010435c:	55                   	push   %ebp
f010435d:	57                   	push   %edi
f010435e:	56                   	push   %esi
f010435f:	53                   	push   %ebx
f0104360:	83 ec 1c             	sub    $0x1c,%esp
f0104363:	8b 6c 24 30          	mov    0x30(%esp),%ebp
f0104367:	8b 74 24 34          	mov    0x34(%esp),%esi
f010436b:	8b 7c 24 38          	mov    0x38(%esp),%edi
f010436f:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f0104373:	85 d2                	test   %edx,%edx
f0104375:	75 19                	jne    f0104390 <__udivdi3+0x34>
f0104377:	39 f7                	cmp    %esi,%edi
f0104379:	76 45                	jbe    f01043c0 <__udivdi3+0x64>
f010437b:	89 e8                	mov    %ebp,%eax
f010437d:	89 f2                	mov    %esi,%edx
f010437f:	f7 f7                	div    %edi
f0104381:	31 db                	xor    %ebx,%ebx
f0104383:	89 da                	mov    %ebx,%edx
f0104385:	83 c4 1c             	add    $0x1c,%esp
f0104388:	5b                   	pop    %ebx
f0104389:	5e                   	pop    %esi
f010438a:	5f                   	pop    %edi
f010438b:	5d                   	pop    %ebp
f010438c:	c3                   	ret    
f010438d:	8d 76 00             	lea    0x0(%esi),%esi
f0104390:	39 f2                	cmp    %esi,%edx
f0104392:	76 10                	jbe    f01043a4 <__udivdi3+0x48>
f0104394:	31 db                	xor    %ebx,%ebx
f0104396:	31 c0                	xor    %eax,%eax
f0104398:	89 da                	mov    %ebx,%edx
f010439a:	83 c4 1c             	add    $0x1c,%esp
f010439d:	5b                   	pop    %ebx
f010439e:	5e                   	pop    %esi
f010439f:	5f                   	pop    %edi
f01043a0:	5d                   	pop    %ebp
f01043a1:	c3                   	ret    
f01043a2:	66 90                	xchg   %ax,%ax
f01043a4:	0f bd da             	bsr    %edx,%ebx
f01043a7:	83 f3 1f             	xor    $0x1f,%ebx
f01043aa:	75 3c                	jne    f01043e8 <__udivdi3+0x8c>
f01043ac:	39 f2                	cmp    %esi,%edx
f01043ae:	72 08                	jb     f01043b8 <__udivdi3+0x5c>
f01043b0:	39 ef                	cmp    %ebp,%edi
f01043b2:	0f 87 9c 00 00 00    	ja     f0104454 <__udivdi3+0xf8>
f01043b8:	b8 01 00 00 00       	mov    $0x1,%eax
f01043bd:	eb d9                	jmp    f0104398 <__udivdi3+0x3c>
f01043bf:	90                   	nop
f01043c0:	89 f9                	mov    %edi,%ecx
f01043c2:	85 ff                	test   %edi,%edi
f01043c4:	75 0b                	jne    f01043d1 <__udivdi3+0x75>
f01043c6:	b8 01 00 00 00       	mov    $0x1,%eax
f01043cb:	31 d2                	xor    %edx,%edx
f01043cd:	f7 f7                	div    %edi
f01043cf:	89 c1                	mov    %eax,%ecx
f01043d1:	31 d2                	xor    %edx,%edx
f01043d3:	89 f0                	mov    %esi,%eax
f01043d5:	f7 f1                	div    %ecx
f01043d7:	89 c3                	mov    %eax,%ebx
f01043d9:	89 e8                	mov    %ebp,%eax
f01043db:	f7 f1                	div    %ecx
f01043dd:	89 da                	mov    %ebx,%edx
f01043df:	83 c4 1c             	add    $0x1c,%esp
f01043e2:	5b                   	pop    %ebx
f01043e3:	5e                   	pop    %esi
f01043e4:	5f                   	pop    %edi
f01043e5:	5d                   	pop    %ebp
f01043e6:	c3                   	ret    
f01043e7:	90                   	nop
f01043e8:	b8 20 00 00 00       	mov    $0x20,%eax
f01043ed:	29 d8                	sub    %ebx,%eax
f01043ef:	88 d9                	mov    %bl,%cl
f01043f1:	d3 e2                	shl    %cl,%edx
f01043f3:	89 54 24 08          	mov    %edx,0x8(%esp)
f01043f7:	89 fa                	mov    %edi,%edx
f01043f9:	88 c1                	mov    %al,%cl
f01043fb:	d3 ea                	shr    %cl,%edx
f01043fd:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f0104401:	09 d1                	or     %edx,%ecx
f0104403:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0104407:	88 d9                	mov    %bl,%cl
f0104409:	d3 e7                	shl    %cl,%edi
f010440b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f010440f:	89 f7                	mov    %esi,%edi
f0104411:	88 c1                	mov    %al,%cl
f0104413:	d3 ef                	shr    %cl,%edi
f0104415:	88 d9                	mov    %bl,%cl
f0104417:	d3 e6                	shl    %cl,%esi
f0104419:	89 ea                	mov    %ebp,%edx
f010441b:	88 c1                	mov    %al,%cl
f010441d:	d3 ea                	shr    %cl,%edx
f010441f:	09 d6                	or     %edx,%esi
f0104421:	89 f0                	mov    %esi,%eax
f0104423:	89 fa                	mov    %edi,%edx
f0104425:	f7 74 24 08          	divl   0x8(%esp)
f0104429:	89 d7                	mov    %edx,%edi
f010442b:	89 c6                	mov    %eax,%esi
f010442d:	f7 64 24 0c          	mull   0xc(%esp)
f0104431:	39 d7                	cmp    %edx,%edi
f0104433:	72 13                	jb     f0104448 <__udivdi3+0xec>
f0104435:	74 09                	je     f0104440 <__udivdi3+0xe4>
f0104437:	89 f0                	mov    %esi,%eax
f0104439:	31 db                	xor    %ebx,%ebx
f010443b:	e9 58 ff ff ff       	jmp    f0104398 <__udivdi3+0x3c>
f0104440:	88 d9                	mov    %bl,%cl
f0104442:	d3 e5                	shl    %cl,%ebp
f0104444:	39 c5                	cmp    %eax,%ebp
f0104446:	73 ef                	jae    f0104437 <__udivdi3+0xdb>
f0104448:	8d 46 ff             	lea    -0x1(%esi),%eax
f010444b:	31 db                	xor    %ebx,%ebx
f010444d:	e9 46 ff ff ff       	jmp    f0104398 <__udivdi3+0x3c>
f0104452:	66 90                	xchg   %ax,%ax
f0104454:	31 c0                	xor    %eax,%eax
f0104456:	e9 3d ff ff ff       	jmp    f0104398 <__udivdi3+0x3c>
f010445b:	90                   	nop

f010445c <__umoddi3>:
f010445c:	55                   	push   %ebp
f010445d:	57                   	push   %edi
f010445e:	56                   	push   %esi
f010445f:	53                   	push   %ebx
f0104460:	83 ec 1c             	sub    $0x1c,%esp
f0104463:	8b 74 24 30          	mov    0x30(%esp),%esi
f0104467:	8b 5c 24 34          	mov    0x34(%esp),%ebx
f010446b:	8b 7c 24 38          	mov    0x38(%esp),%edi
f010446f:	8b 44 24 3c          	mov    0x3c(%esp),%eax
f0104473:	85 c0                	test   %eax,%eax
f0104475:	75 19                	jne    f0104490 <__umoddi3+0x34>
f0104477:	39 df                	cmp    %ebx,%edi
f0104479:	76 51                	jbe    f01044cc <__umoddi3+0x70>
f010447b:	89 f0                	mov    %esi,%eax
f010447d:	89 da                	mov    %ebx,%edx
f010447f:	f7 f7                	div    %edi
f0104481:	89 d0                	mov    %edx,%eax
f0104483:	31 d2                	xor    %edx,%edx
f0104485:	83 c4 1c             	add    $0x1c,%esp
f0104488:	5b                   	pop    %ebx
f0104489:	5e                   	pop    %esi
f010448a:	5f                   	pop    %edi
f010448b:	5d                   	pop    %ebp
f010448c:	c3                   	ret    
f010448d:	8d 76 00             	lea    0x0(%esi),%esi
f0104490:	89 f2                	mov    %esi,%edx
f0104492:	39 d8                	cmp    %ebx,%eax
f0104494:	76 0e                	jbe    f01044a4 <__umoddi3+0x48>
f0104496:	89 f0                	mov    %esi,%eax
f0104498:	89 da                	mov    %ebx,%edx
f010449a:	83 c4 1c             	add    $0x1c,%esp
f010449d:	5b                   	pop    %ebx
f010449e:	5e                   	pop    %esi
f010449f:	5f                   	pop    %edi
f01044a0:	5d                   	pop    %ebp
f01044a1:	c3                   	ret    
f01044a2:	66 90                	xchg   %ax,%ax
f01044a4:	0f bd e8             	bsr    %eax,%ebp
f01044a7:	83 f5 1f             	xor    $0x1f,%ebp
f01044aa:	75 44                	jne    f01044f0 <__umoddi3+0x94>
f01044ac:	39 d8                	cmp    %ebx,%eax
f01044ae:	72 06                	jb     f01044b6 <__umoddi3+0x5a>
f01044b0:	89 d9                	mov    %ebx,%ecx
f01044b2:	39 f7                	cmp    %esi,%edi
f01044b4:	77 08                	ja     f01044be <__umoddi3+0x62>
f01044b6:	29 fe                	sub    %edi,%esi
f01044b8:	19 c3                	sbb    %eax,%ebx
f01044ba:	89 f2                	mov    %esi,%edx
f01044bc:	89 d9                	mov    %ebx,%ecx
f01044be:	89 d0                	mov    %edx,%eax
f01044c0:	89 ca                	mov    %ecx,%edx
f01044c2:	83 c4 1c             	add    $0x1c,%esp
f01044c5:	5b                   	pop    %ebx
f01044c6:	5e                   	pop    %esi
f01044c7:	5f                   	pop    %edi
f01044c8:	5d                   	pop    %ebp
f01044c9:	c3                   	ret    
f01044ca:	66 90                	xchg   %ax,%ax
f01044cc:	89 fd                	mov    %edi,%ebp
f01044ce:	85 ff                	test   %edi,%edi
f01044d0:	75 0b                	jne    f01044dd <__umoddi3+0x81>
f01044d2:	b8 01 00 00 00       	mov    $0x1,%eax
f01044d7:	31 d2                	xor    %edx,%edx
f01044d9:	f7 f7                	div    %edi
f01044db:	89 c5                	mov    %eax,%ebp
f01044dd:	89 d8                	mov    %ebx,%eax
f01044df:	31 d2                	xor    %edx,%edx
f01044e1:	f7 f5                	div    %ebp
f01044e3:	89 f0                	mov    %esi,%eax
f01044e5:	f7 f5                	div    %ebp
f01044e7:	89 d0                	mov    %edx,%eax
f01044e9:	31 d2                	xor    %edx,%edx
f01044eb:	eb 98                	jmp    f0104485 <__umoddi3+0x29>
f01044ed:	8d 76 00             	lea    0x0(%esi),%esi
f01044f0:	ba 20 00 00 00       	mov    $0x20,%edx
f01044f5:	29 ea                	sub    %ebp,%edx
f01044f7:	89 e9                	mov    %ebp,%ecx
f01044f9:	d3 e0                	shl    %cl,%eax
f01044fb:	89 44 24 08          	mov    %eax,0x8(%esp)
f01044ff:	89 f8                	mov    %edi,%eax
f0104501:	89 54 24 04          	mov    %edx,0x4(%esp)
f0104505:	88 d1                	mov    %dl,%cl
f0104507:	d3 e8                	shr    %cl,%eax
f0104509:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f010450d:	09 c1                	or     %eax,%ecx
f010450f:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0104513:	89 e9                	mov    %ebp,%ecx
f0104515:	d3 e7                	shl    %cl,%edi
f0104517:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f010451b:	89 d8                	mov    %ebx,%eax
f010451d:	8b 54 24 04          	mov    0x4(%esp),%edx
f0104521:	88 d1                	mov    %dl,%cl
f0104523:	d3 e8                	shr    %cl,%eax
f0104525:	89 c7                	mov    %eax,%edi
f0104527:	89 e9                	mov    %ebp,%ecx
f0104529:	d3 e3                	shl    %cl,%ebx
f010452b:	89 f0                	mov    %esi,%eax
f010452d:	88 d1                	mov    %dl,%cl
f010452f:	d3 e8                	shr    %cl,%eax
f0104531:	09 d8                	or     %ebx,%eax
f0104533:	89 e9                	mov    %ebp,%ecx
f0104535:	d3 e6                	shl    %cl,%esi
f0104537:	89 f3                	mov    %esi,%ebx
f0104539:	89 fa                	mov    %edi,%edx
f010453b:	f7 74 24 08          	divl   0x8(%esp)
f010453f:	89 d1                	mov    %edx,%ecx
f0104541:	f7 64 24 0c          	mull   0xc(%esp)
f0104545:	89 c6                	mov    %eax,%esi
f0104547:	89 d7                	mov    %edx,%edi
f0104549:	39 d1                	cmp    %edx,%ecx
f010454b:	72 27                	jb     f0104574 <__umoddi3+0x118>
f010454d:	74 21                	je     f0104570 <__umoddi3+0x114>
f010454f:	89 ca                	mov    %ecx,%edx
f0104551:	29 f3                	sub    %esi,%ebx
f0104553:	19 fa                	sbb    %edi,%edx
f0104555:	89 d0                	mov    %edx,%eax
f0104557:	8a 4c 24 04          	mov    0x4(%esp),%cl
f010455b:	d3 e0                	shl    %cl,%eax
f010455d:	89 e9                	mov    %ebp,%ecx
f010455f:	d3 eb                	shr    %cl,%ebx
f0104561:	09 d8                	or     %ebx,%eax
f0104563:	d3 ea                	shr    %cl,%edx
f0104565:	83 c4 1c             	add    $0x1c,%esp
f0104568:	5b                   	pop    %ebx
f0104569:	5e                   	pop    %esi
f010456a:	5f                   	pop    %edi
f010456b:	5d                   	pop    %ebp
f010456c:	c3                   	ret    
f010456d:	8d 76 00             	lea    0x0(%esi),%esi
f0104570:	39 c3                	cmp    %eax,%ebx
f0104572:	73 db                	jae    f010454f <__umoddi3+0xf3>
f0104574:	2b 44 24 0c          	sub    0xc(%esp),%eax
f0104578:	1b 54 24 08          	sbb    0x8(%esp),%edx
f010457c:	89 d7                	mov    %edx,%edi
f010457e:	89 c6                	mov    %eax,%esi
f0104580:	eb cd                	jmp    f010454f <__umoddi3+0xf3>
