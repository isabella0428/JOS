
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
f0100015:	b8 00 b0 11 00       	mov    $0x11b000,%eax
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
f0100034:	bc 00 b0 11 f0       	mov    $0xf011b000,%esp

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
f0100046:	b8 00 2a 1b f0       	mov    $0xf01b2a00,%eax
f010004b:	2d 00 1b 1b f0       	sub    $0xf01b1b00,%eax
f0100050:	50                   	push   %eax
f0100051:	6a 00                	push   $0x0
f0100053:	68 00 1b 1b f0       	push   $0xf01b1b00
f0100058:	e8 17 45 00 00       	call   f0104574 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f010005d:	e8 81 04 00 00       	call   f01004e3 <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f0100062:	83 c4 08             	add    $0x8,%esp
f0100065:	68 ac 1a 00 00       	push   $0x1aac
f010006a:	68 80 49 10 f0       	push   $0xf0104980
f010006f:	e8 a8 30 00 00       	call   f010311c <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f0100074:	e8 c5 0f 00 00       	call   f010103e <mem_init>

	// Lab 3 user environment initialization functions
	env_init();
f0100079:	e8 af 2a 00 00       	call   f0102b2d <env_init>
	trap_init();
f010007e:	e8 0f 31 00 00       	call   f0103192 <trap_init>

#if defined(TEST)
	// Don't touch -- used by grading script!
	ENV_CREATE(TEST, ENV_TYPE_USER);
f0100083:	83 c4 08             	add    $0x8,%esp
f0100086:	6a 00                	push   $0x0
f0100088:	68 e2 f3 13 f0       	push   $0xf013f3e2
f010008d:	e8 6b 2c 00 00       	call   f0102cfd <env_create>
	// Touch all you want.
	ENV_CREATE(user_testbss, ENV_TYPE_USER);
#endif // TEST*

	// We only have one user environment for now, so just run it.
	env_run(&envs[0]);
f0100092:	83 c4 04             	add    $0x4,%esp
f0100095:	ff 35 4c 1d 1b f0    	pushl  0xf01b1d4c
f010009b:	e8 b2 2f 00 00       	call   f0103052 <env_run>

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
f01000a8:	83 3d 04 2a 1b f0 00 	cmpl   $0x0,0xf01b2a04
f01000af:	74 0f                	je     f01000c0 <_panic+0x20>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f01000b1:	83 ec 0c             	sub    $0xc,%esp
f01000b4:	6a 00                	push   $0x0
f01000b6:	e8 13 07 00 00       	call   f01007ce <monitor>
f01000bb:	83 c4 10             	add    $0x10,%esp
f01000be:	eb f1                	jmp    f01000b1 <_panic+0x11>
	panicstr = fmt;
f01000c0:	89 35 04 2a 1b f0    	mov    %esi,0xf01b2a04
	asm volatile("cli; cld");
f01000c6:	fa                   	cli    
f01000c7:	fc                   	cld    
	va_start(ap, fmt);
f01000c8:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic at %s:%d: ", file, line);
f01000cb:	83 ec 04             	sub    $0x4,%esp
f01000ce:	ff 75 0c             	pushl  0xc(%ebp)
f01000d1:	ff 75 08             	pushl  0x8(%ebp)
f01000d4:	68 9b 49 10 f0       	push   $0xf010499b
f01000d9:	e8 3e 30 00 00       	call   f010311c <cprintf>
	vcprintf(fmt, ap);
f01000de:	83 c4 08             	add    $0x8,%esp
f01000e1:	53                   	push   %ebx
f01000e2:	56                   	push   %esi
f01000e3:	e8 0e 30 00 00       	call   f01030f6 <vcprintf>
	cprintf("\n");
f01000e8:	c7 04 24 db 51 10 f0 	movl   $0xf01051db,(%esp)
f01000ef:	e8 28 30 00 00       	call   f010311c <cprintf>
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
f0100109:	68 b3 49 10 f0       	push   $0xf01049b3
f010010e:	e8 09 30 00 00       	call   f010311c <cprintf>
	vcprintf(fmt, ap);
f0100113:	83 c4 08             	add    $0x8,%esp
f0100116:	53                   	push   %ebx
f0100117:	ff 75 10             	pushl  0x10(%ebp)
f010011a:	e8 d7 2f 00 00       	call   f01030f6 <vcprintf>
	cprintf("\n");
f010011f:	c7 04 24 db 51 10 f0 	movl   $0xf01051db,(%esp)
f0100126:	e8 f1 2f 00 00       	call   f010311c <cprintf>
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
f0100161:	8b 0d 24 1d 1b f0    	mov    0xf01b1d24,%ecx
f0100167:	8d 51 01             	lea    0x1(%ecx),%edx
f010016a:	89 15 24 1d 1b f0    	mov    %edx,0xf01b1d24
f0100170:	88 81 20 1b 1b f0    	mov    %al,-0xfe4e4e0(%ecx)
		if (cons.wpos == CONSBUFSIZE)
f0100176:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f010017c:	75 d8                	jne    f0100156 <cons_intr+0x9>
			cons.wpos = 0;
f010017e:	c7 05 24 1d 1b f0 00 	movl   $0x0,0xf01b1d24
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
f01001bd:	8b 0d 00 1b 1b f0    	mov    0xf01b1b00,%ecx
f01001c3:	f6 c1 40             	test   $0x40,%cl
f01001c6:	74 0e                	je     f01001d6 <kbd_proc_data+0x46>
		data |= 0x80;
f01001c8:	83 c8 80             	or     $0xffffff80,%eax
f01001cb:	88 c2                	mov    %al,%dl
		shift &= ~E0ESC;
f01001cd:	83 e1 bf             	and    $0xffffffbf,%ecx
f01001d0:	89 0d 00 1b 1b f0    	mov    %ecx,0xf01b1b00
	shift |= shiftcode[data];
f01001d6:	0f b6 d2             	movzbl %dl,%edx
f01001d9:	0f b6 82 20 4b 10 f0 	movzbl -0xfefb4e0(%edx),%eax
f01001e0:	0b 05 00 1b 1b f0    	or     0xf01b1b00,%eax
	shift ^= togglecode[data];
f01001e6:	0f b6 8a 20 4a 10 f0 	movzbl -0xfefb5e0(%edx),%ecx
f01001ed:	31 c8                	xor    %ecx,%eax
f01001ef:	a3 00 1b 1b f0       	mov    %eax,0xf01b1b00
	c = charcode[shift & (CTL | SHIFT)][data];
f01001f4:	89 c1                	mov    %eax,%ecx
f01001f6:	83 e1 03             	and    $0x3,%ecx
f01001f9:	8b 0c 8d 00 4a 10 f0 	mov    -0xfefb600(,%ecx,4),%ecx
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
f0100219:	83 0d 00 1b 1b f0 40 	orl    $0x40,0xf01b1b00
		return 0;
f0100220:	bb 00 00 00 00       	mov    $0x0,%ebx
}
f0100225:	89 d8                	mov    %ebx,%eax
f0100227:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010022a:	c9                   	leave  
f010022b:	c3                   	ret    
		data = (shift & E0ESC ? data : data & 0x7F);
f010022c:	8b 0d 00 1b 1b f0    	mov    0xf01b1b00,%ecx
f0100232:	f6 c1 40             	test   $0x40,%cl
f0100235:	75 05                	jne    f010023c <kbd_proc_data+0xac>
f0100237:	83 e0 7f             	and    $0x7f,%eax
f010023a:	88 c2                	mov    %al,%dl
		shift &= ~(shiftcode[data] | E0ESC);
f010023c:	0f b6 d2             	movzbl %dl,%edx
f010023f:	8a 82 20 4b 10 f0    	mov    -0xfefb4e0(%edx),%al
f0100245:	83 c8 40             	or     $0x40,%eax
f0100248:	0f b6 c0             	movzbl %al,%eax
f010024b:	f7 d0                	not    %eax
f010024d:	21 c8                	and    %ecx,%eax
f010024f:	a3 00 1b 1b f0       	mov    %eax,0xf01b1b00
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
f0100277:	68 cd 49 10 f0       	push   $0xf01049cd
f010027c:	e8 9b 2e 00 00       	call   f010311c <cprintf>
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
f0100373:	66 8b 0d 28 1d 1b f0 	mov    0xf01b1d28,%cx
f010037a:	bb 50 00 00 00       	mov    $0x50,%ebx
f010037f:	89 c8                	mov    %ecx,%eax
f0100381:	ba 00 00 00 00       	mov    $0x0,%edx
f0100386:	66 f7 f3             	div    %bx
f0100389:	29 d1                	sub    %edx,%ecx
f010038b:	66 89 0d 28 1d 1b f0 	mov    %cx,0xf01b1d28
	if (crt_pos >= CRT_SIZE) {
f0100392:	66 81 3d 28 1d 1b f0 	cmpw   $0x7cf,0xf01b1d28
f0100399:	cf 07 
f010039b:	0f 87 84 00 00 00    	ja     f0100425 <cons_putc+0x189>
	outb(addr_6845, 14);
f01003a1:	8b 0d 30 1d 1b f0    	mov    0xf01b1d30,%ecx
f01003a7:	b0 0e                	mov    $0xe,%al
f01003a9:	89 ca                	mov    %ecx,%edx
f01003ab:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f01003ac:	8d 59 01             	lea    0x1(%ecx),%ebx
f01003af:	66 a1 28 1d 1b f0    	mov    0xf01b1d28,%ax
f01003b5:	66 c1 e8 08          	shr    $0x8,%ax
f01003b9:	89 da                	mov    %ebx,%edx
f01003bb:	ee                   	out    %al,(%dx)
f01003bc:	b0 0f                	mov    $0xf,%al
f01003be:	89 ca                	mov    %ecx,%edx
f01003c0:	ee                   	out    %al,(%dx)
f01003c1:	a0 28 1d 1b f0       	mov    0xf01b1d28,%al
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
f01003d1:	66 a1 28 1d 1b f0    	mov    0xf01b1d28,%ax
f01003d7:	66 85 c0             	test   %ax,%ax
f01003da:	74 c5                	je     f01003a1 <cons_putc+0x105>
			crt_pos--;
f01003dc:	48                   	dec    %eax
f01003dd:	66 a3 28 1d 1b f0    	mov    %ax,0xf01b1d28
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f01003e3:	0f b7 d0             	movzwl %ax,%edx
f01003e6:	b1 00                	mov    $0x0,%cl
f01003e8:	83 c9 20             	or     $0x20,%ecx
f01003eb:	a1 2c 1d 1b f0       	mov    0xf01b1d2c,%eax
f01003f0:	66 89 0c 50          	mov    %cx,(%eax,%edx,2)
f01003f4:	eb 9c                	jmp    f0100392 <cons_putc+0xf6>
		crt_pos += CRT_COLS;
f01003f6:	66 83 05 28 1d 1b f0 	addw   $0x50,0xf01b1d28
f01003fd:	50 
f01003fe:	e9 70 ff ff ff       	jmp    f0100373 <cons_putc+0xd7>
		crt_buf[crt_pos++] = c;		/* write the character */
f0100403:	66 a1 28 1d 1b f0    	mov    0xf01b1d28,%ax
f0100409:	8d 50 01             	lea    0x1(%eax),%edx
f010040c:	66 89 15 28 1d 1b f0 	mov    %dx,0xf01b1d28
f0100413:	0f b7 c0             	movzwl %ax,%eax
f0100416:	8b 15 2c 1d 1b f0    	mov    0xf01b1d2c,%edx
f010041c:	66 89 0c 42          	mov    %cx,(%edx,%eax,2)
		break;
f0100420:	e9 6d ff ff ff       	jmp    f0100392 <cons_putc+0xf6>
		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f0100425:	a1 2c 1d 1b f0       	mov    0xf01b1d2c,%eax
f010042a:	83 ec 04             	sub    $0x4,%esp
f010042d:	68 00 0f 00 00       	push   $0xf00
f0100432:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f0100438:	52                   	push   %edx
f0100439:	50                   	push   %eax
f010043a:	e8 80 41 00 00       	call   f01045bf <memmove>
			crt_buf[i] = 0x0700 | ' ';
f010043f:	8b 15 2c 1d 1b f0    	mov    0xf01b1d2c,%edx
f0100445:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f010044b:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f0100451:	83 c4 10             	add    $0x10,%esp
f0100454:	66 c7 00 20 07       	movw   $0x720,(%eax)
f0100459:	83 c0 02             	add    $0x2,%eax
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f010045c:	39 d0                	cmp    %edx,%eax
f010045e:	75 f4                	jne    f0100454 <cons_putc+0x1b8>
		crt_pos -= CRT_COLS;
f0100460:	66 83 2d 28 1d 1b f0 	subw   $0x50,0xf01b1d28
f0100467:	50 
f0100468:	e9 34 ff ff ff       	jmp    f01003a1 <cons_putc+0x105>

f010046d <serial_intr>:
	if (serial_exists)
f010046d:	80 3d 34 1d 1b f0 00 	cmpb   $0x0,0xf01b1d34
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
f01004ab:	a1 20 1d 1b f0       	mov    0xf01b1d20,%eax
f01004b0:	3b 05 24 1d 1b f0    	cmp    0xf01b1d24,%eax
f01004b6:	74 24                	je     f01004dc <cons_getc+0x41>
		c = cons.buf[cons.rpos++];
f01004b8:	8d 50 01             	lea    0x1(%eax),%edx
f01004bb:	89 15 20 1d 1b f0    	mov    %edx,0xf01b1d20
f01004c1:	0f b6 80 20 1b 1b f0 	movzbl -0xfe4e4e0(%eax),%eax
		if (cons.rpos == CONSBUFSIZE)
f01004c8:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f01004ce:	75 11                	jne    f01004e1 <cons_getc+0x46>
			cons.rpos = 0;
f01004d0:	c7 05 20 1d 1b f0 00 	movl   $0x0,0xf01b1d20
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
f010050c:	c7 05 30 1d 1b f0 b4 	movl   $0x3b4,0xf01b1d30
f0100513:	03 00 00 
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f0100516:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
	outb(addr_6845, 14);
f010051b:	8b 3d 30 1d 1b f0    	mov    0xf01b1d30,%edi
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
f010053c:	89 35 2c 1d 1b f0    	mov    %esi,0xf01b1d2c
	pos |= inb(addr_6845 + 1);
f0100542:	0f b6 c0             	movzbl %al,%eax
f0100545:	09 d8                	or     %ebx,%eax
	crt_pos = pos;
f0100547:	66 a3 28 1d 1b f0    	mov    %ax,0xf01b1d28
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
f0100591:	0f 95 05 34 1d 1b f0 	setne  0xf01b1d34
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
f01005b5:	c7 05 30 1d 1b f0 d4 	movl   $0x3d4,0xf01b1d30
f01005bc:	03 00 00 
	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f01005bf:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
f01005c4:	e9 52 ff ff ff       	jmp    f010051b <cons_init+0x38>
		cprintf("Serial port does not exist!\n");
f01005c9:	83 ec 0c             	sub    $0xc,%esp
f01005cc:	68 d9 49 10 f0       	push   $0xf01049d9
f01005d1:	e8 46 2b 00 00       	call   f010311c <cprintf>
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
f0100608:	68 20 4c 10 f0       	push   $0xf0104c20
f010060d:	68 3e 4c 10 f0       	push   $0xf0104c3e
f0100612:	68 43 4c 10 f0       	push   $0xf0104c43
f0100617:	e8 00 2b 00 00       	call   f010311c <cprintf>
f010061c:	83 c4 0c             	add    $0xc,%esp
f010061f:	68 f4 4c 10 f0       	push   $0xf0104cf4
f0100624:	68 4c 4c 10 f0       	push   $0xf0104c4c
f0100629:	68 43 4c 10 f0       	push   $0xf0104c43
f010062e:	e8 e9 2a 00 00       	call   f010311c <cprintf>
f0100633:	83 c4 0c             	add    $0xc,%esp
f0100636:	68 1c 4d 10 f0       	push   $0xf0104d1c
f010063b:	68 55 4c 10 f0       	push   $0xf0104c55
f0100640:	68 43 4c 10 f0       	push   $0xf0104c43
f0100645:	e8 d2 2a 00 00       	call   f010311c <cprintf>
	return 0;
}
f010064a:	b8 00 00 00 00       	mov    $0x0,%eax
f010064f:	c9                   	leave  
f0100650:	c3                   	ret    

f0100651 <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f0100651:	55                   	push   %ebp
f0100652:	89 e5                	mov    %esp,%ebp
f0100654:	83 ec 14             	sub    $0x14,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f0100657:	68 5f 4c 10 f0       	push   $0xf0104c5f
f010065c:	e8 bb 2a 00 00       	call   f010311c <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f0100661:	83 c4 08             	add    $0x8,%esp
f0100664:	68 0c 00 10 00       	push   $0x10000c
f0100669:	68 a0 4d 10 f0       	push   $0xf0104da0
f010066e:	e8 a9 2a 00 00       	call   f010311c <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f0100673:	83 c4 0c             	add    $0xc,%esp
f0100676:	68 0c 00 10 00       	push   $0x10000c
f010067b:	68 0c 00 10 f0       	push   $0xf010000c
f0100680:	68 c8 4d 10 f0       	push   $0xf0104dc8
f0100685:	e8 92 2a 00 00       	call   f010311c <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f010068a:	83 c4 0c             	add    $0xc,%esp
f010068d:	68 76 49 10 00       	push   $0x104976
f0100692:	68 76 49 10 f0       	push   $0xf0104976
f0100697:	68 ec 4d 10 f0       	push   $0xf0104dec
f010069c:	e8 7b 2a 00 00       	call   f010311c <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f01006a1:	83 c4 0c             	add    $0xc,%esp
f01006a4:	68 00 1b 1b 00       	push   $0x1b1b00
f01006a9:	68 00 1b 1b f0       	push   $0xf01b1b00
f01006ae:	68 10 4e 10 f0       	push   $0xf0104e10
f01006b3:	e8 64 2a 00 00       	call   f010311c <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f01006b8:	83 c4 0c             	add    $0xc,%esp
f01006bb:	68 00 2a 1b 00       	push   $0x1b2a00
f01006c0:	68 00 2a 1b f0       	push   $0xf01b2a00
f01006c5:	68 34 4e 10 f0       	push   $0xf0104e34
f01006ca:	e8 4d 2a 00 00       	call   f010311c <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
f01006cf:	83 c4 08             	add    $0x8,%esp
		ROUNDUP(end - entry, 1024) / 1024);
f01006d2:	b8 00 2a 1b f0       	mov    $0xf01b2a00,%eax
f01006d7:	2d 0d fc 0f f0       	sub    $0xf00ffc0d,%eax
	cprintf("Kernel executable memory footprint: %dKB\n",
f01006dc:	c1 f8 0a             	sar    $0xa,%eax
f01006df:	50                   	push   %eax
f01006e0:	68 58 4e 10 f0       	push   $0xf0104e58
f01006e5:	e8 32 2a 00 00       	call   f010311c <cprintf>
	return 0;
}
f01006ea:	b8 00 00 00 00       	mov    $0x0,%eax
f01006ef:	c9                   	leave  
f01006f0:	c3                   	ret    

f01006f1 <mon_backtrace>:

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f01006f1:	55                   	push   %ebp
f01006f2:	89 e5                	mov    %esp,%ebp
f01006f4:	57                   	push   %edi
f01006f5:	56                   	push   %esi
f01006f6:	53                   	push   %ebx
f01006f7:	83 ec 48             	sub    $0x48,%esp
	// Your code here.
	uint32_t arg, apm, temp, ebp, eip, esp;

	cprintf("Stack backtrace:\n");
f01006fa:	68 78 4c 10 f0       	push   $0xf0104c78
f01006ff:	e8 18 2a 00 00       	call   f010311c <cprintf>

static inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f0100704:	89 ee                	mov    %ebp,%esi
	//get saved %ebp
	ebp = read_ebp();
	//debug info
	struct Eipdebuginfo info;

	while (ebp != 0)
f0100706:	83 c4 10             	add    $0x10,%esp
f0100709:	eb 40                	jmp    f010074b <mon_backtrace+0x5a>

		cprintf("  %s:%u: ", info.eip_file, info.eip_line);
		//print the limit length file name
		for (int i = 0; i < info.eip_fn_namelen; ++i)
		{
			cprintf("%c", info.eip_fn_name[i]);
f010070b:	83 ec 08             	sub    $0x8,%esp
f010070e:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100711:	0f be 04 18          	movsbl (%eax,%ebx,1),%eax
f0100715:	50                   	push   %eax
f0100716:	68 af 4c 10 f0       	push   $0xf0104caf
f010071b:	e8 fc 29 00 00       	call   f010311c <cprintf>
		for (int i = 0; i < info.eip_fn_namelen; ++i)
f0100720:	43                   	inc    %ebx
f0100721:	83 c4 10             	add    $0x10,%esp
f0100724:	39 5d dc             	cmp    %ebx,-0x24(%ebp)
f0100727:	7f e2                	jg     f010070b <mon_backtrace+0x1a>
		}
		cprintf("+%d", eip - info.eip_fn_addr);
f0100729:	83 ec 08             	sub    $0x8,%esp
f010072c:	2b 7d e0             	sub    -0x20(%ebp),%edi
f010072f:	57                   	push   %edi
f0100730:	68 b2 4c 10 f0       	push   $0xf0104cb2
f0100735:	e8 e2 29 00 00       	call   f010311c <cprintf>
		cprintf("\n");
f010073a:	c7 04 24 db 51 10 f0 	movl   $0xf01051db,(%esp)
f0100741:	e8 d6 29 00 00       	call   f010311c <cprintf>
		//Trace back to caller function's %ebp
		ebp = *((uint32_t *)ebp);
f0100746:	8b 36                	mov    (%esi),%esi
f0100748:	83 c4 10             	add    $0x10,%esp
	while (ebp != 0)
f010074b:	85 f6                	test   %esi,%esi
f010074d:	74 72                	je     f01007c1 <mon_backtrace+0xd0>
		eip = *((uint32_t *)ebp + 1);
f010074f:	8b 7e 04             	mov    0x4(%esi),%edi
		cprintf(" ebp %x eip %x args ", ebp, eip);
f0100752:	83 ec 04             	sub    $0x4,%esp
f0100755:	57                   	push   %edi
f0100756:	56                   	push   %esi
f0100757:	68 8a 4c 10 f0       	push   $0xf0104c8a
f010075c:	e8 bb 29 00 00       	call   f010311c <cprintf>
f0100761:	8d 5e 08             	lea    0x8(%esi),%ebx
f0100764:	8d 46 1c             	lea    0x1c(%esi),%eax
f0100767:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f010076a:	83 c4 10             	add    $0x10,%esp
			cprintf("%08x ", arg);
f010076d:	83 ec 08             	sub    $0x8,%esp
f0100770:	ff 33                	pushl  (%ebx)
f0100772:	68 9f 4c 10 f0       	push   $0xf0104c9f
f0100777:	e8 a0 29 00 00       	call   f010311c <cprintf>
f010077c:	83 c3 04             	add    $0x4,%ebx
		for (int offset = 2; offset <= 6; offset++)
f010077f:	83 c4 10             	add    $0x10,%esp
f0100782:	3b 5d c4             	cmp    -0x3c(%ebp),%ebx
f0100785:	75 e6                	jne    f010076d <mon_backtrace+0x7c>
		cprintf("\n");
f0100787:	83 ec 0c             	sub    $0xc,%esp
f010078a:	68 db 51 10 f0       	push   $0xf01051db
f010078f:	e8 88 29 00 00       	call   f010311c <cprintf>
		debuginfo_eip(eip, &info);
f0100794:	83 c4 08             	add    $0x8,%esp
f0100797:	8d 45 d0             	lea    -0x30(%ebp),%eax
f010079a:	50                   	push   %eax
f010079b:	57                   	push   %edi
f010079c:	e8 3f 33 00 00       	call   f0103ae0 <debuginfo_eip>
		cprintf("  %s:%u: ", info.eip_file, info.eip_line);
f01007a1:	83 c4 0c             	add    $0xc,%esp
f01007a4:	ff 75 d4             	pushl  -0x2c(%ebp)
f01007a7:	ff 75 d0             	pushl  -0x30(%ebp)
f01007aa:	68 a5 4c 10 f0       	push   $0xf0104ca5
f01007af:	e8 68 29 00 00       	call   f010311c <cprintf>
		for (int i = 0; i < info.eip_fn_namelen; ++i)
f01007b4:	83 c4 10             	add    $0x10,%esp
f01007b7:	bb 00 00 00 00       	mov    $0x0,%ebx
f01007bc:	e9 63 ff ff ff       	jmp    f0100724 <mon_backtrace+0x33>
	}
	return 0;
}
f01007c1:	b8 00 00 00 00       	mov    $0x0,%eax
f01007c6:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01007c9:	5b                   	pop    %ebx
f01007ca:	5e                   	pop    %esi
f01007cb:	5f                   	pop    %edi
f01007cc:	5d                   	pop    %ebp
f01007cd:	c3                   	ret    

f01007ce <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f01007ce:	55                   	push   %ebp
f01007cf:	89 e5                	mov    %esp,%ebp
f01007d1:	57                   	push   %edi
f01007d2:	56                   	push   %esi
f01007d3:	53                   	push   %ebx
f01007d4:	83 ec 58             	sub    $0x58,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f01007d7:	68 84 4e 10 f0       	push   $0xf0104e84
f01007dc:	e8 3b 29 00 00       	call   f010311c <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f01007e1:	c7 04 24 a8 4e 10 f0 	movl   $0xf0104ea8,(%esp)
f01007e8:	e8 2f 29 00 00       	call   f010311c <cprintf>

	if (tf != NULL)
f01007ed:	83 c4 10             	add    $0x10,%esp
f01007f0:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f01007f4:	0f 84 d3 00 00 00    	je     f01008cd <monitor+0xff>
		print_trapframe(tf);
f01007fa:	83 ec 0c             	sub    $0xc,%esp
f01007fd:	ff 75 08             	pushl  0x8(%ebp)
f0100800:	e8 59 2d 00 00       	call   f010355e <print_trapframe>
f0100805:	83 c4 10             	add    $0x10,%esp
f0100808:	e9 c0 00 00 00       	jmp    f01008cd <monitor+0xff>
		while (*buf && strchr(WHITESPACE, *buf))
f010080d:	83 ec 08             	sub    $0x8,%esp
f0100810:	0f be c0             	movsbl %al,%eax
f0100813:	50                   	push   %eax
f0100814:	68 ba 4c 10 f0       	push   $0xf0104cba
f0100819:	e8 21 3d 00 00       	call   f010453f <strchr>
f010081e:	83 c4 10             	add    $0x10,%esp
f0100821:	85 c0                	test   %eax,%eax
f0100823:	74 60                	je     f0100885 <monitor+0xb7>
			*buf++ = 0;
f0100825:	c6 03 00             	movb   $0x0,(%ebx)
f0100828:	89 f7                	mov    %esi,%edi
f010082a:	8d 5b 01             	lea    0x1(%ebx),%ebx
f010082d:	89 fe                	mov    %edi,%esi
		while (*buf && strchr(WHITESPACE, *buf))
f010082f:	8a 03                	mov    (%ebx),%al
f0100831:	84 c0                	test   %al,%al
f0100833:	75 d8                	jne    f010080d <monitor+0x3f>
	argv[argc] = 0;
f0100835:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f010083c:	00 
	if (argc == 0)
f010083d:	85 f6                	test   %esi,%esi
f010083f:	0f 84 88 00 00 00    	je     f01008cd <monitor+0xff>
f0100845:	bf e0 4e 10 f0       	mov    $0xf0104ee0,%edi
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f010084a:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (strcmp(argv[0], commands[i].name) == 0)
f010084f:	83 ec 08             	sub    $0x8,%esp
f0100852:	ff 37                	pushl  (%edi)
f0100854:	ff 75 a8             	pushl  -0x58(%ebp)
f0100857:	e8 8f 3c 00 00       	call   f01044eb <strcmp>
f010085c:	83 c4 10             	add    $0x10,%esp
f010085f:	85 c0                	test   %eax,%eax
f0100861:	0f 84 8d 00 00 00    	je     f01008f4 <monitor+0x126>
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f0100867:	43                   	inc    %ebx
f0100868:	83 c7 0c             	add    $0xc,%edi
f010086b:	83 fb 03             	cmp    $0x3,%ebx
f010086e:	75 df                	jne    f010084f <monitor+0x81>
	cprintf("Unknown command '%s'\n", argv[0]);
f0100870:	83 ec 08             	sub    $0x8,%esp
f0100873:	ff 75 a8             	pushl  -0x58(%ebp)
f0100876:	68 dc 4c 10 f0       	push   $0xf0104cdc
f010087b:	e8 9c 28 00 00       	call   f010311c <cprintf>
	return 0;
f0100880:	83 c4 10             	add    $0x10,%esp
f0100883:	eb 48                	jmp    f01008cd <monitor+0xff>
		if (*buf == 0)
f0100885:	80 3b 00             	cmpb   $0x0,(%ebx)
f0100888:	74 ab                	je     f0100835 <monitor+0x67>
		if (argc == MAXARGS-1) {
f010088a:	83 fe 0f             	cmp    $0xf,%esi
f010088d:	74 2c                	je     f01008bb <monitor+0xed>
		argv[argc++] = buf;
f010088f:	8d 7e 01             	lea    0x1(%esi),%edi
f0100892:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
		while (*buf && !strchr(WHITESPACE, *buf))
f0100896:	8a 03                	mov    (%ebx),%al
f0100898:	84 c0                	test   %al,%al
f010089a:	74 91                	je     f010082d <monitor+0x5f>
f010089c:	83 ec 08             	sub    $0x8,%esp
f010089f:	0f be c0             	movsbl %al,%eax
f01008a2:	50                   	push   %eax
f01008a3:	68 ba 4c 10 f0       	push   $0xf0104cba
f01008a8:	e8 92 3c 00 00       	call   f010453f <strchr>
f01008ad:	83 c4 10             	add    $0x10,%esp
f01008b0:	85 c0                	test   %eax,%eax
f01008b2:	0f 85 75 ff ff ff    	jne    f010082d <monitor+0x5f>
			buf++;
f01008b8:	43                   	inc    %ebx
f01008b9:	eb db                	jmp    f0100896 <monitor+0xc8>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f01008bb:	83 ec 08             	sub    $0x8,%esp
f01008be:	6a 10                	push   $0x10
f01008c0:	68 bf 4c 10 f0       	push   $0xf0104cbf
f01008c5:	e8 52 28 00 00       	call   f010311c <cprintf>
			return 0;
f01008ca:	83 c4 10             	add    $0x10,%esp

	while (1) {
		buf = readline("K> ");
f01008cd:	83 ec 0c             	sub    $0xc,%esp
f01008d0:	68 b6 4c 10 f0       	push   $0xf0104cb6
f01008d5:	e8 59 3a 00 00       	call   f0104333 <readline>
f01008da:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f01008dc:	83 c4 10             	add    $0x10,%esp
f01008df:	85 c0                	test   %eax,%eax
f01008e1:	74 ea                	je     f01008cd <monitor+0xff>
	argv[argc] = 0;
f01008e3:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	argc = 0;
f01008ea:	be 00 00 00 00       	mov    $0x0,%esi
f01008ef:	e9 3b ff ff ff       	jmp    f010082f <monitor+0x61>
			return commands[i].func(argc, argv, tf);
f01008f4:	83 ec 04             	sub    $0x4,%esp
f01008f7:	8d 04 1b             	lea    (%ebx,%ebx,1),%eax
f01008fa:	01 c3                	add    %eax,%ebx
f01008fc:	ff 75 08             	pushl  0x8(%ebp)
f01008ff:	8d 45 a8             	lea    -0x58(%ebp),%eax
f0100902:	50                   	push   %eax
f0100903:	56                   	push   %esi
f0100904:	ff 14 9d e8 4e 10 f0 	call   *-0xfefb118(,%ebx,4)
			if (runcmd(buf, tf) < 0)
f010090b:	83 c4 10             	add    $0x10,%esp
f010090e:	85 c0                	test   %eax,%eax
f0100910:	79 bb                	jns    f01008cd <monitor+0xff>
				break;
	}
}
f0100912:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100915:	5b                   	pop    %ebx
f0100916:	5e                   	pop    %esi
f0100917:	5f                   	pop    %edi
f0100918:	5d                   	pop    %ebp
f0100919:	c3                   	ret    

f010091a <nvram_read>:
// Detect machine's physical memory setup.
// --------------------------------------------------------------

static int
nvram_read(int r)
{
f010091a:	55                   	push   %ebp
f010091b:	89 e5                	mov    %esp,%ebp
f010091d:	56                   	push   %esi
f010091e:	53                   	push   %ebx
f010091f:	89 c3                	mov    %eax,%ebx
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0100921:	83 ec 0c             	sub    $0xc,%esp
f0100924:	50                   	push   %eax
f0100925:	e8 8b 27 00 00       	call   f01030b5 <mc146818_read>
f010092a:	89 c6                	mov    %eax,%esi
f010092c:	43                   	inc    %ebx
f010092d:	89 1c 24             	mov    %ebx,(%esp)
f0100930:	e8 80 27 00 00       	call   f01030b5 <mc146818_read>
f0100935:	c1 e0 08             	shl    $0x8,%eax
f0100938:	09 f0                	or     %esi,%eax
}
f010093a:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010093d:	5b                   	pop    %ebx
f010093e:	5e                   	pop    %esi
f010093f:	5d                   	pop    %ebp
f0100940:	c3                   	ret    

f0100941 <boot_alloc>:
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f0100941:	83 3d 38 1d 1b f0 00 	cmpl   $0x0,0xf01b1d38
f0100948:	74 2c                	je     f0100976 <boot_alloc+0x35>
	// Allocate a chunk large enough to hold 'n' bytes, then update
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
	result = nextfree;			// Start address of the allocated contiguous memory block
f010094a:	8b 0d 38 1d 1b f0    	mov    0xf01b1d38,%ecx
	nextfree = ROUNDUP(nextfree + n, PGSIZE);
f0100950:	8d 84 01 ff 0f 00 00 	lea    0xfff(%ecx,%eax,1),%eax
f0100957:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f010095c:	a3 38 1d 1b f0       	mov    %eax,0xf01b1d38
	if ((uint32_t)nextfree - KERNBASE > (npages * PGSIZE))	// The allocated space exceeds total physical memory
f0100961:	05 00 00 00 10       	add    $0x10000000,%eax
f0100966:	8b 15 08 2a 1b f0    	mov    0xf01b2a08,%edx
f010096c:	c1 e2 0c             	shl    $0xc,%edx
f010096f:	39 d0                	cmp    %edx,%eax
f0100971:	77 16                	ja     f0100989 <boot_alloc+0x48>
		panic("Out of memory!");

	return result;
}
f0100973:	89 c8                	mov    %ecx,%eax
f0100975:	c3                   	ret    
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0100976:	ba ff 39 1b f0       	mov    $0xf01b39ff,%edx
f010097b:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100981:	89 15 38 1d 1b f0    	mov    %edx,0xf01b1d38
f0100987:	eb c1                	jmp    f010094a <boot_alloc+0x9>
{
f0100989:	55                   	push   %ebp
f010098a:	89 e5                	mov    %esp,%ebp
f010098c:	83 ec 0c             	sub    $0xc,%esp
		panic("Out of memory!");
f010098f:	68 04 4f 10 f0       	push   $0xf0104f04
f0100994:	6a 70                	push   $0x70
f0100996:	68 13 4f 10 f0       	push   $0xf0104f13
f010099b:	e8 00 f7 ff ff       	call   f01000a0 <_panic>

f01009a0 <check_va2pa>:
static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
f01009a0:	89 d1                	mov    %edx,%ecx
f01009a2:	c1 e9 16             	shr    $0x16,%ecx
	if (!(*pgdir & PTE_P))
f01009a5:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f01009a8:	a8 01                	test   $0x1,%al
f01009aa:	74 48                	je     f01009f4 <check_va2pa+0x54>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f01009ac:	89 c1                	mov    %eax,%ecx
f01009ae:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01009b4:	c1 e8 0c             	shr    $0xc,%eax
f01009b7:	3b 05 08 2a 1b f0    	cmp    0xf01b2a08,%eax
f01009bd:	73 1a                	jae    f01009d9 <check_va2pa+0x39>
	if (!(p[PTX(va)] & PTE_P))
f01009bf:	c1 ea 0c             	shr    $0xc,%edx
f01009c2:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f01009c8:	8b 84 91 00 00 00 f0 	mov    -0x10000000(%ecx,%edx,4),%eax
f01009cf:	a8 01                	test   $0x1,%al
f01009d1:	74 27                	je     f01009fa <check_va2pa+0x5a>
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f01009d3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01009d8:	c3                   	ret    
{
f01009d9:	55                   	push   %ebp
f01009da:	89 e5                	mov    %esp,%ebp
f01009dc:	83 ec 08             	sub    $0x8,%esp
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01009df:	51                   	push   %ecx
f01009e0:	68 10 52 10 f0       	push   $0xf0105210
f01009e5:	68 51 03 00 00       	push   $0x351
f01009ea:	68 13 4f 10 f0       	push   $0xf0104f13
f01009ef:	e8 ac f6 ff ff       	call   f01000a0 <_panic>
		return ~0;
f01009f4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01009f9:	c3                   	ret    
		return ~0;
f01009fa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
f01009ff:	c3                   	ret    

f0100a00 <check_page_free_list>:
{
f0100a00:	55                   	push   %ebp
f0100a01:	89 e5                	mov    %esp,%ebp
f0100a03:	57                   	push   %edi
f0100a04:	56                   	push   %esi
f0100a05:	53                   	push   %ebx
f0100a06:	83 ec 2c             	sub    $0x2c,%esp
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100a09:	84 c0                	test   %al,%al
f0100a0b:	0f 85 4f 02 00 00    	jne    f0100c60 <check_page_free_list+0x260>
	if (!page_free_list)
f0100a11:	83 3d 40 1d 1b f0 00 	cmpl   $0x0,0xf01b1d40
f0100a18:	74 0d                	je     f0100a27 <check_page_free_list+0x27>
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100a1a:	be 00 04 00 00       	mov    $0x400,%esi
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100a1f:	8b 1d 40 1d 1b f0    	mov    0xf01b1d40,%ebx
f0100a25:	eb 2b                	jmp    f0100a52 <check_page_free_list+0x52>
		panic("'page_free_list' is a null pointer!");
f0100a27:	83 ec 04             	sub    $0x4,%esp
f0100a2a:	68 34 52 10 f0       	push   $0xf0105234
f0100a2f:	68 8d 02 00 00       	push   $0x28d
f0100a34:	68 13 4f 10 f0       	push   $0xf0104f13
f0100a39:	e8 62 f6 ff ff       	call   f01000a0 <_panic>
f0100a3e:	50                   	push   %eax
f0100a3f:	68 10 52 10 f0       	push   $0xf0105210
f0100a44:	6a 56                	push   $0x56
f0100a46:	68 1f 4f 10 f0       	push   $0xf0104f1f
f0100a4b:	e8 50 f6 ff ff       	call   f01000a0 <_panic>
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100a50:	8b 1b                	mov    (%ebx),%ebx
f0100a52:	85 db                	test   %ebx,%ebx
f0100a54:	74 41                	je     f0100a97 <check_page_free_list+0x97>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100a56:	89 d8                	mov    %ebx,%eax
f0100a58:	2b 05 10 2a 1b f0    	sub    0xf01b2a10,%eax
f0100a5e:	c1 f8 03             	sar    $0x3,%eax
f0100a61:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f0100a64:	89 c2                	mov    %eax,%edx
f0100a66:	c1 ea 16             	shr    $0x16,%edx
f0100a69:	39 f2                	cmp    %esi,%edx
f0100a6b:	73 e3                	jae    f0100a50 <check_page_free_list+0x50>
	if (PGNUM(pa) >= npages)
f0100a6d:	89 c2                	mov    %eax,%edx
f0100a6f:	c1 ea 0c             	shr    $0xc,%edx
f0100a72:	3b 15 08 2a 1b f0    	cmp    0xf01b2a08,%edx
f0100a78:	73 c4                	jae    f0100a3e <check_page_free_list+0x3e>
			memset(page2kva(pp), 0x97, 128);
f0100a7a:	83 ec 04             	sub    $0x4,%esp
f0100a7d:	68 80 00 00 00       	push   $0x80
f0100a82:	68 97 00 00 00       	push   $0x97
	return (void *)(pa + KERNBASE);
f0100a87:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100a8c:	50                   	push   %eax
f0100a8d:	e8 e2 3a 00 00       	call   f0104574 <memset>
f0100a92:	83 c4 10             	add    $0x10,%esp
f0100a95:	eb b9                	jmp    f0100a50 <check_page_free_list+0x50>
	first_free_page = (char *) boot_alloc(0);
f0100a97:	b8 00 00 00 00       	mov    $0x0,%eax
f0100a9c:	e8 a0 fe ff ff       	call   f0100941 <boot_alloc>
f0100aa1:	89 45 cc             	mov    %eax,-0x34(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100aa4:	8b 15 40 1d 1b f0    	mov    0xf01b1d40,%edx
		assert(pp >= pages);
f0100aaa:	8b 0d 10 2a 1b f0    	mov    0xf01b2a10,%ecx
		assert(pp < pages + npages);
f0100ab0:	a1 08 2a 1b f0       	mov    0xf01b2a08,%eax
f0100ab5:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0100ab8:	8d 3c c1             	lea    (%ecx,%eax,8),%edi
	int nfree_basemem = 0, nfree_extmem = 0;
f0100abb:	be 00 00 00 00       	mov    $0x0,%esi
f0100ac0:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100ac3:	e9 c8 00 00 00       	jmp    f0100b90 <check_page_free_list+0x190>
		assert(pp >= pages);
f0100ac8:	68 2d 4f 10 f0       	push   $0xf0104f2d
f0100acd:	68 39 4f 10 f0       	push   $0xf0104f39
f0100ad2:	68 a7 02 00 00       	push   $0x2a7
f0100ad7:	68 13 4f 10 f0       	push   $0xf0104f13
f0100adc:	e8 bf f5 ff ff       	call   f01000a0 <_panic>
		assert(pp < pages + npages);
f0100ae1:	68 4e 4f 10 f0       	push   $0xf0104f4e
f0100ae6:	68 39 4f 10 f0       	push   $0xf0104f39
f0100aeb:	68 a8 02 00 00       	push   $0x2a8
f0100af0:	68 13 4f 10 f0       	push   $0xf0104f13
f0100af5:	e8 a6 f5 ff ff       	call   f01000a0 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100afa:	68 58 52 10 f0       	push   $0xf0105258
f0100aff:	68 39 4f 10 f0       	push   $0xf0104f39
f0100b04:	68 a9 02 00 00       	push   $0x2a9
f0100b09:	68 13 4f 10 f0       	push   $0xf0104f13
f0100b0e:	e8 8d f5 ff ff       	call   f01000a0 <_panic>
		assert(page2pa(pp) != 0);
f0100b13:	68 62 4f 10 f0       	push   $0xf0104f62
f0100b18:	68 39 4f 10 f0       	push   $0xf0104f39
f0100b1d:	68 ac 02 00 00       	push   $0x2ac
f0100b22:	68 13 4f 10 f0       	push   $0xf0104f13
f0100b27:	e8 74 f5 ff ff       	call   f01000a0 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100b2c:	68 73 4f 10 f0       	push   $0xf0104f73
f0100b31:	68 39 4f 10 f0       	push   $0xf0104f39
f0100b36:	68 ad 02 00 00       	push   $0x2ad
f0100b3b:	68 13 4f 10 f0       	push   $0xf0104f13
f0100b40:	e8 5b f5 ff ff       	call   f01000a0 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100b45:	68 8c 52 10 f0       	push   $0xf010528c
f0100b4a:	68 39 4f 10 f0       	push   $0xf0104f39
f0100b4f:	68 ae 02 00 00       	push   $0x2ae
f0100b54:	68 13 4f 10 f0       	push   $0xf0104f13
f0100b59:	e8 42 f5 ff ff       	call   f01000a0 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100b5e:	68 8c 4f 10 f0       	push   $0xf0104f8c
f0100b63:	68 39 4f 10 f0       	push   $0xf0104f39
f0100b68:	68 af 02 00 00       	push   $0x2af
f0100b6d:	68 13 4f 10 f0       	push   $0xf0104f13
f0100b72:	e8 29 f5 ff ff       	call   f01000a0 <_panic>
	if (PGNUM(pa) >= npages)
f0100b77:	89 c3                	mov    %eax,%ebx
f0100b79:	c1 eb 0c             	shr    $0xc,%ebx
f0100b7c:	39 5d d0             	cmp    %ebx,-0x30(%ebp)
f0100b7f:	76 62                	jbe    f0100be3 <check_page_free_list+0x1e3>
	return (void *)(pa + KERNBASE);
f0100b81:	2d 00 00 00 10       	sub    $0x10000000,%eax
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100b86:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f0100b89:	77 6a                	ja     f0100bf5 <check_page_free_list+0x1f5>
			++nfree_extmem;
f0100b8b:	ff 45 d4             	incl   -0x2c(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100b8e:	8b 12                	mov    (%edx),%edx
f0100b90:	85 d2                	test   %edx,%edx
f0100b92:	74 7a                	je     f0100c0e <check_page_free_list+0x20e>
		assert(pp >= pages);
f0100b94:	39 d1                	cmp    %edx,%ecx
f0100b96:	0f 87 2c ff ff ff    	ja     f0100ac8 <check_page_free_list+0xc8>
		assert(pp < pages + npages);
f0100b9c:	39 d7                	cmp    %edx,%edi
f0100b9e:	0f 86 3d ff ff ff    	jbe    f0100ae1 <check_page_free_list+0xe1>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100ba4:	89 d0                	mov    %edx,%eax
f0100ba6:	29 c8                	sub    %ecx,%eax
f0100ba8:	a8 07                	test   $0x7,%al
f0100baa:	0f 85 4a ff ff ff    	jne    f0100afa <check_page_free_list+0xfa>
	return (pp - pages) << PGSHIFT;
f0100bb0:	c1 f8 03             	sar    $0x3,%eax
		assert(page2pa(pp) != 0);
f0100bb3:	c1 e0 0c             	shl    $0xc,%eax
f0100bb6:	0f 84 57 ff ff ff    	je     f0100b13 <check_page_free_list+0x113>
		assert(page2pa(pp) != IOPHYSMEM);
f0100bbc:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100bc1:	0f 84 65 ff ff ff    	je     f0100b2c <check_page_free_list+0x12c>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100bc7:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100bcc:	0f 84 73 ff ff ff    	je     f0100b45 <check_page_free_list+0x145>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100bd2:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100bd7:	74 85                	je     f0100b5e <check_page_free_list+0x15e>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100bd9:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0100bde:	77 97                	ja     f0100b77 <check_page_free_list+0x177>
			++nfree_basemem;
f0100be0:	46                   	inc    %esi
f0100be1:	eb ab                	jmp    f0100b8e <check_page_free_list+0x18e>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100be3:	50                   	push   %eax
f0100be4:	68 10 52 10 f0       	push   $0xf0105210
f0100be9:	6a 56                	push   $0x56
f0100beb:	68 1f 4f 10 f0       	push   $0xf0104f1f
f0100bf0:	e8 ab f4 ff ff       	call   f01000a0 <_panic>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100bf5:	68 b0 52 10 f0       	push   $0xf01052b0
f0100bfa:	68 39 4f 10 f0       	push   $0xf0104f39
f0100bff:	68 b0 02 00 00       	push   $0x2b0
f0100c04:	68 13 4f 10 f0       	push   $0xf0104f13
f0100c09:	e8 92 f4 ff ff       	call   f01000a0 <_panic>
f0100c0e:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
	assert(nfree_basemem > 0);
f0100c11:	85 f6                	test   %esi,%esi
f0100c13:	7e 19                	jle    f0100c2e <check_page_free_list+0x22e>
	assert(nfree_extmem > 0);
f0100c15:	85 db                	test   %ebx,%ebx
f0100c17:	7e 2e                	jle    f0100c47 <check_page_free_list+0x247>
	cprintf("check_page_free_list() succeeded!\n");
f0100c19:	83 ec 0c             	sub    $0xc,%esp
f0100c1c:	68 f8 52 10 f0       	push   $0xf01052f8
f0100c21:	e8 f6 24 00 00       	call   f010311c <cprintf>
}
f0100c26:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100c29:	5b                   	pop    %ebx
f0100c2a:	5e                   	pop    %esi
f0100c2b:	5f                   	pop    %edi
f0100c2c:	5d                   	pop    %ebp
f0100c2d:	c3                   	ret    
	assert(nfree_basemem > 0);
f0100c2e:	68 a6 4f 10 f0       	push   $0xf0104fa6
f0100c33:	68 39 4f 10 f0       	push   $0xf0104f39
f0100c38:	68 b8 02 00 00       	push   $0x2b8
f0100c3d:	68 13 4f 10 f0       	push   $0xf0104f13
f0100c42:	e8 59 f4 ff ff       	call   f01000a0 <_panic>
	assert(nfree_extmem > 0);
f0100c47:	68 b8 4f 10 f0       	push   $0xf0104fb8
f0100c4c:	68 39 4f 10 f0       	push   $0xf0104f39
f0100c51:	68 b9 02 00 00       	push   $0x2b9
f0100c56:	68 13 4f 10 f0       	push   $0xf0104f13
f0100c5b:	e8 40 f4 ff ff       	call   f01000a0 <_panic>
	if (!page_free_list)
f0100c60:	a1 40 1d 1b f0       	mov    0xf01b1d40,%eax
f0100c65:	85 c0                	test   %eax,%eax
f0100c67:	0f 84 ba fd ff ff    	je     f0100a27 <check_page_free_list+0x27>
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f0100c6d:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0100c70:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0100c73:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100c76:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	return (pp - pages) << PGSHIFT;
f0100c79:	89 c2                	mov    %eax,%edx
f0100c7b:	2b 15 10 2a 1b f0    	sub    0xf01b2a10,%edx
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0100c81:	f7 c2 00 e0 7f 00    	test   $0x7fe000,%edx
f0100c87:	0f 95 c2             	setne  %dl
f0100c8a:	0f b6 d2             	movzbl %dl,%edx
			*tp[pagetype] = pp;
f0100c8d:	8b 4c 95 e0          	mov    -0x20(%ebp,%edx,4),%ecx
f0100c91:	89 01                	mov    %eax,(%ecx)
			tp[pagetype] = &pp->pp_link;
f0100c93:	89 44 95 e0          	mov    %eax,-0x20(%ebp,%edx,4)
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100c97:	8b 00                	mov    (%eax),%eax
f0100c99:	85 c0                	test   %eax,%eax
f0100c9b:	75 dc                	jne    f0100c79 <check_page_free_list+0x279>
		*tp[1] = 0;
f0100c9d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100ca0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0100ca6:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100ca9:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100cac:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0100cae:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100cb1:	a3 40 1d 1b f0       	mov    %eax,0xf01b1d40
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100cb6:	be 01 00 00 00       	mov    $0x1,%esi
f0100cbb:	e9 5f fd ff ff       	jmp    f0100a1f <check_page_free_list+0x1f>

f0100cc0 <page_init>:
{
f0100cc0:	55                   	push   %ebp
f0100cc1:	89 e5                	mov    %esp,%ebp
f0100cc3:	57                   	push   %edi
f0100cc4:	56                   	push   %esi
f0100cc5:	53                   	push   %ebx
f0100cc6:	83 ec 0c             	sub    $0xc,%esp
	for (i = 0; i < npages; i++)
f0100cc9:	bb 00 00 00 00       	mov    $0x0,%ebx
		int is_IO_hole = i >= npages_basemem && i <= npages_basemem + npages_IO ;
f0100cce:	be 01 00 00 00       	mov    $0x1,%esi
	for (i = 0; i < npages; i++)
f0100cd3:	eb 65                	jmp    f0100d3a <page_init+0x7a>
		int is_IO_hole = i >= npages_basemem && i <= npages_basemem + npages_IO ;
f0100cd5:	b9 00 00 00 00       	mov    $0x0,%ecx
		int is_kernel_pgdir = (i >= npages_basemem + npages_IO && i <= npages_basemem + npages_IO + npages_kern);
f0100cda:	8d 7a 60             	lea    0x60(%edx),%edi
f0100cdd:	39 df                	cmp    %ebx,%edi
f0100cdf:	76 3a                	jbe    f0100d1b <page_init+0x5b>
		if (i == 0 || is_IO_hole || is_kernel_pgdir) {
f0100ce1:	85 db                	test   %ebx,%ebx
f0100ce3:	74 48                	je     f0100d2d <page_init+0x6d>
f0100ce5:	85 c9                	test   %ecx,%ecx
f0100ce7:	75 44                	jne    f0100d2d <page_init+0x6d>
f0100ce9:	8d 04 dd 00 00 00 00 	lea    0x0(,%ebx,8),%eax
			pages[i].pp_ref = 0;
f0100cf0:	89 c2                	mov    %eax,%edx
f0100cf2:	03 15 10 2a 1b f0    	add    0xf01b2a10,%edx
f0100cf8:	66 c7 42 04 00 00    	movw   $0x0,0x4(%edx)
			pages[i].pp_link = page_free_list;
f0100cfe:	8b 0d 40 1d 1b f0    	mov    0xf01b1d40,%ecx
f0100d04:	89 0a                	mov    %ecx,(%edx)
			page_free_list = &pages[i];
f0100d06:	03 05 10 2a 1b f0    	add    0xf01b2a10,%eax
f0100d0c:	a3 40 1d 1b f0       	mov    %eax,0xf01b1d40
f0100d11:	eb 26                	jmp    f0100d39 <page_init+0x79>
		int is_kernel_pgdir = (i >= npages_basemem + npages_IO && i <= npages_basemem + npages_IO + npages_kern);
f0100d13:	8d 7a 60             	lea    0x60(%edx),%edi
		int is_IO_hole = i >= npages_basemem && i <= npages_basemem + npages_IO ;
f0100d16:	b9 00 00 00 00       	mov    $0x0,%ecx
		int npages_kern = ((uint32_t)boot_alloc(0) - KERNBASE + PGSIZE - 1) / PGSIZE;
f0100d1b:	8d 90 ff 0f 00 10    	lea    0x10000fff(%eax),%edx
f0100d21:	89 d0                	mov    %edx,%eax
f0100d23:	c1 e8 0c             	shr    $0xc,%eax
		int is_kernel_pgdir = (i >= npages_basemem + npages_IO && i <= npages_basemem + npages_IO + npages_kern);
f0100d26:	8d 14 38             	lea    (%eax,%edi,1),%edx
f0100d29:	39 da                	cmp    %ebx,%edx
f0100d2b:	72 b4                	jb     f0100ce1 <page_init+0x21>
			pages[i].pp_ref = 1;
f0100d2d:	a1 10 2a 1b f0       	mov    0xf01b2a10,%eax
f0100d32:	66 c7 44 d8 04 01 00 	movw   $0x1,0x4(%eax,%ebx,8)
	for (i = 0; i < npages; i++)
f0100d39:	43                   	inc    %ebx
f0100d3a:	39 1d 08 2a 1b f0    	cmp    %ebx,0xf01b2a08
f0100d40:	76 26                	jbe    f0100d68 <page_init+0xa8>
		int npages_kern = ((uint32_t)boot_alloc(0) - KERNBASE + PGSIZE - 1) / PGSIZE;
f0100d42:	b8 00 00 00 00       	mov    $0x0,%eax
f0100d47:	e8 f5 fb ff ff       	call   f0100941 <boot_alloc>
		int is_IO_hole = i >= npages_basemem && i <= npages_basemem + npages_IO ;
f0100d4c:	8b 15 44 1d 1b f0    	mov    0xf01b1d44,%edx
f0100d52:	39 da                	cmp    %ebx,%edx
f0100d54:	0f 87 7b ff ff ff    	ja     f0100cd5 <page_init+0x15>
f0100d5a:	8d 4a 60             	lea    0x60(%edx),%ecx
f0100d5d:	39 d9                	cmp    %ebx,%ecx
f0100d5f:	72 b2                	jb     f0100d13 <page_init+0x53>
f0100d61:	89 f1                	mov    %esi,%ecx
f0100d63:	e9 72 ff ff ff       	jmp    f0100cda <page_init+0x1a>
}
f0100d68:	83 c4 0c             	add    $0xc,%esp
f0100d6b:	5b                   	pop    %ebx
f0100d6c:	5e                   	pop    %esi
f0100d6d:	5f                   	pop    %edi
f0100d6e:	5d                   	pop    %ebp
f0100d6f:	c3                   	ret    

f0100d70 <page_alloc>:
{
f0100d70:	55                   	push   %ebp
f0100d71:	89 e5                	mov    %esp,%ebp
f0100d73:	53                   	push   %ebx
f0100d74:	83 ec 04             	sub    $0x4,%esp
	new_page = page_free_list;
f0100d77:	8b 1d 40 1d 1b f0    	mov    0xf01b1d40,%ebx
	if (new_page == NULL) {
f0100d7d:	85 db                	test   %ebx,%ebx
f0100d7f:	74 13                	je     f0100d94 <page_alloc+0x24>
	page_free_list = new_page->pp_link;
f0100d81:	8b 03                	mov    (%ebx),%eax
f0100d83:	a3 40 1d 1b f0       	mov    %eax,0xf01b1d40
	new_page->pp_link = NULL;
f0100d88:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	if(alloc_flags && ALLOC_ZERO)
f0100d8e:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f0100d92:	75 07                	jne    f0100d9b <page_alloc+0x2b>
}
f0100d94:	89 d8                	mov    %ebx,%eax
f0100d96:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100d99:	c9                   	leave  
f0100d9a:	c3                   	ret    
f0100d9b:	89 d8                	mov    %ebx,%eax
f0100d9d:	2b 05 10 2a 1b f0    	sub    0xf01b2a10,%eax
f0100da3:	c1 f8 03             	sar    $0x3,%eax
f0100da6:	89 c2                	mov    %eax,%edx
f0100da8:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0100dab:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0100db0:	3b 05 08 2a 1b f0    	cmp    0xf01b2a08,%eax
f0100db6:	73 1b                	jae    f0100dd3 <page_alloc+0x63>
		memset(page2kva(new_page), '\0', PGSIZE);
f0100db8:	83 ec 04             	sub    $0x4,%esp
f0100dbb:	68 00 10 00 00       	push   $0x1000
f0100dc0:	6a 00                	push   $0x0
	return (void *)(pa + KERNBASE);
f0100dc2:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f0100dc8:	52                   	push   %edx
f0100dc9:	e8 a6 37 00 00       	call   f0104574 <memset>
f0100dce:	83 c4 10             	add    $0x10,%esp
f0100dd1:	eb c1                	jmp    f0100d94 <page_alloc+0x24>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100dd3:	52                   	push   %edx
f0100dd4:	68 10 52 10 f0       	push   $0xf0105210
f0100dd9:	6a 56                	push   $0x56
f0100ddb:	68 1f 4f 10 f0       	push   $0xf0104f1f
f0100de0:	e8 bb f2 ff ff       	call   f01000a0 <_panic>

f0100de5 <page_free>:
{
f0100de5:	55                   	push   %ebp
f0100de6:	89 e5                	mov    %esp,%ebp
f0100de8:	83 ec 08             	sub    $0x8,%esp
f0100deb:	8b 45 08             	mov    0x8(%ebp),%eax
	if (pp->pp_ref != 0 || pp->pp_link != NULL) {
f0100dee:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0100df3:	75 14                	jne    f0100e09 <page_free+0x24>
f0100df5:	83 38 00             	cmpl   $0x0,(%eax)
f0100df8:	75 0f                	jne    f0100e09 <page_free+0x24>
	pp->pp_link = page_free_list;
f0100dfa:	8b 15 40 1d 1b f0    	mov    0xf01b1d40,%edx
f0100e00:	89 10                	mov    %edx,(%eax)
	page_free_list = pp;
f0100e02:	a3 40 1d 1b f0       	mov    %eax,0xf01b1d40
}
f0100e07:	c9                   	leave  
f0100e08:	c3                   	ret    
		panic("Cannot free this page!");
f0100e09:	83 ec 04             	sub    $0x4,%esp
f0100e0c:	68 c9 4f 10 f0       	push   $0xf0104fc9
f0100e11:	68 68 01 00 00       	push   $0x168
f0100e16:	68 13 4f 10 f0       	push   $0xf0104f13
f0100e1b:	e8 80 f2 ff ff       	call   f01000a0 <_panic>

f0100e20 <page_decref>:
{
f0100e20:	55                   	push   %ebp
f0100e21:	89 e5                	mov    %esp,%ebp
f0100e23:	83 ec 08             	sub    $0x8,%esp
f0100e26:	8b 55 08             	mov    0x8(%ebp),%edx
	if (--pp->pp_ref == 0)
f0100e29:	8b 42 04             	mov    0x4(%edx),%eax
f0100e2c:	48                   	dec    %eax
f0100e2d:	66 89 42 04          	mov    %ax,0x4(%edx)
f0100e31:	66 85 c0             	test   %ax,%ax
f0100e34:	74 02                	je     f0100e38 <page_decref+0x18>
}
f0100e36:	c9                   	leave  
f0100e37:	c3                   	ret    
		page_free(pp);
f0100e38:	83 ec 0c             	sub    $0xc,%esp
f0100e3b:	52                   	push   %edx
f0100e3c:	e8 a4 ff ff ff       	call   f0100de5 <page_free>
f0100e41:	83 c4 10             	add    $0x10,%esp
}
f0100e44:	eb f0                	jmp    f0100e36 <page_decref+0x16>

f0100e46 <pgdir_walk>:
{
f0100e46:	55                   	push   %ebp
f0100e47:	89 e5                	mov    %esp,%ebp
f0100e49:	53                   	push   %ebx
f0100e4a:	83 ec 04             	sub    $0x4,%esp
	pde_t *pg_dir_entry = (pde_t *)(pgdir + (unsigned int)PDX(va));
f0100e4d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0100e50:	c1 eb 16             	shr    $0x16,%ebx
f0100e53:	c1 e3 02             	shl    $0x2,%ebx
f0100e56:	03 5d 08             	add    0x8(%ebp),%ebx
	if(!(*pg_dir_entry) & PTE_P) {
f0100e59:	83 3b 00             	cmpl   $0x0,(%ebx)
f0100e5c:	75 2c                	jne    f0100e8a <pgdir_walk+0x44>
		if (create == false)
f0100e5e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0100e62:	74 67                	je     f0100ecb <pgdir_walk+0x85>
		new_page = page_alloc(1);
f0100e64:	83 ec 0c             	sub    $0xc,%esp
f0100e67:	6a 01                	push   $0x1
f0100e69:	e8 02 ff ff ff       	call   f0100d70 <page_alloc>
		if(new_page == NULL)
f0100e6e:	83 c4 10             	add    $0x10,%esp
f0100e71:	85 c0                	test   %eax,%eax
f0100e73:	74 3c                	je     f0100eb1 <pgdir_walk+0x6b>
		new_page->pp_ref ++;
f0100e75:	66 ff 40 04          	incw   0x4(%eax)
	return (pp - pages) << PGSHIFT;
f0100e79:	2b 05 10 2a 1b f0    	sub    0xf01b2a10,%eax
f0100e7f:	c1 f8 03             	sar    $0x3,%eax
f0100e82:	c1 e0 0c             	shl    $0xc,%eax
		*pg_dir_entry = ((page2pa(new_page)) | PTE_P | PTE_W | PTE_U);
f0100e85:	83 c8 07             	or     $0x7,%eax
f0100e88:	89 03                	mov    %eax,(%ebx)
	offset = PTX(va);
f0100e8a:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100e8d:	c1 e8 0c             	shr    $0xc,%eax
f0100e90:	25 ff 03 00 00       	and    $0x3ff,%eax
	page_base = KADDR(PTE_ADDR(*pg_dir_entry));
f0100e95:	8b 13                	mov    (%ebx),%edx
f0100e97:	89 d1                	mov    %edx,%ecx
f0100e99:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
	if (PGNUM(pa) >= npages)
f0100e9f:	c1 ea 0c             	shr    $0xc,%edx
f0100ea2:	3b 15 08 2a 1b f0    	cmp    0xf01b2a08,%edx
f0100ea8:	73 0c                	jae    f0100eb6 <pgdir_walk+0x70>
	return &page_base[offset];
f0100eaa:	8d 84 81 00 00 00 f0 	lea    -0x10000000(%ecx,%eax,4),%eax
}
f0100eb1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100eb4:	c9                   	leave  
f0100eb5:	c3                   	ret    
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100eb6:	51                   	push   %ecx
f0100eb7:	68 10 52 10 f0       	push   $0xf0105210
f0100ebc:	68 a7 01 00 00       	push   $0x1a7
f0100ec1:	68 13 4f 10 f0       	push   $0xf0104f13
f0100ec6:	e8 d5 f1 ff ff       	call   f01000a0 <_panic>
			return NULL;
f0100ecb:	b8 00 00 00 00       	mov    $0x0,%eax
f0100ed0:	eb df                	jmp    f0100eb1 <pgdir_walk+0x6b>

f0100ed2 <boot_map_region>:
{
f0100ed2:	55                   	push   %ebp
f0100ed3:	89 e5                	mov    %esp,%ebp
f0100ed5:	57                   	push   %edi
f0100ed6:	56                   	push   %esi
f0100ed7:	53                   	push   %ebx
f0100ed8:	83 ec 1c             	sub    $0x1c,%esp
f0100edb:	89 c7                	mov    %eax,%edi
	int num_pages = size / PGSIZE;
f0100edd:	c1 e9 0c             	shr    $0xc,%ecx
f0100ee0:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
	for(int i = 0; i < num_pages; ++i) {
f0100ee3:	89 d3                	mov    %edx,%ebx
f0100ee5:	be 00 00 00 00       	mov    $0x0,%esi
		*pt_entry = (pa + i * PGSIZE) | PTE_P | perm;
f0100eea:	8b 45 08             	mov    0x8(%ebp),%eax
f0100eed:	29 d0                	sub    %edx,%eax
f0100eef:	89 45 e0             	mov    %eax,-0x20(%ebp)
	for(int i = 0; i < num_pages; ++i) {
f0100ef2:	3b 75 e4             	cmp    -0x1c(%ebp),%esi
f0100ef5:	7d 27                	jge    f0100f1e <boot_map_region+0x4c>
		pt_entry = pgdir_walk(pgdir, (void *)(va + i * PGSIZE), 1);
f0100ef7:	83 ec 04             	sub    $0x4,%esp
f0100efa:	6a 01                	push   $0x1
f0100efc:	53                   	push   %ebx
f0100efd:	57                   	push   %edi
f0100efe:	e8 43 ff ff ff       	call   f0100e46 <pgdir_walk>
f0100f03:	89 c2                	mov    %eax,%edx
		*pt_entry = (pa + i * PGSIZE) | PTE_P | perm;
f0100f05:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100f08:	01 d8                	add    %ebx,%eax
f0100f0a:	0b 45 0c             	or     0xc(%ebp),%eax
f0100f0d:	83 c8 01             	or     $0x1,%eax
f0100f10:	89 02                	mov    %eax,(%edx)
	for(int i = 0; i < num_pages; ++i) {
f0100f12:	46                   	inc    %esi
f0100f13:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0100f19:	83 c4 10             	add    $0x10,%esp
f0100f1c:	eb d4                	jmp    f0100ef2 <boot_map_region+0x20>
}
f0100f1e:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100f21:	5b                   	pop    %ebx
f0100f22:	5e                   	pop    %esi
f0100f23:	5f                   	pop    %edi
f0100f24:	5d                   	pop    %ebp
f0100f25:	c3                   	ret    

f0100f26 <page_lookup>:
{
f0100f26:	55                   	push   %ebp
f0100f27:	89 e5                	mov    %esp,%ebp
f0100f29:	53                   	push   %ebx
f0100f2a:	83 ec 08             	sub    $0x8,%esp
f0100f2d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	pte_t *pt_entry = pgdir_walk(pgdir, va, false);
f0100f30:	6a 00                	push   $0x0
f0100f32:	ff 75 0c             	pushl  0xc(%ebp)
f0100f35:	ff 75 08             	pushl  0x8(%ebp)
f0100f38:	e8 09 ff ff ff       	call   f0100e46 <pgdir_walk>
	if(pt_entry == NULL)
f0100f3d:	83 c4 10             	add    $0x10,%esp
f0100f40:	85 c0                	test   %eax,%eax
f0100f42:	74 21                	je     f0100f65 <page_lookup+0x3f>
	if(!(*pt_entry & PTE_P))
f0100f44:	f6 00 01             	testb  $0x1,(%eax)
f0100f47:	74 35                	je     f0100f7e <page_lookup+0x58>
	if(pte_store != NULL)
f0100f49:	85 db                	test   %ebx,%ebx
f0100f4b:	74 02                	je     f0100f4f <page_lookup+0x29>
		*pte_store = pt_entry;
f0100f4d:	89 03                	mov    %eax,(%ebx)
f0100f4f:	8b 00                	mov    (%eax),%eax
f0100f51:	c1 e8 0c             	shr    $0xc,%eax
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100f54:	39 05 08 2a 1b f0    	cmp    %eax,0xf01b2a08
f0100f5a:	76 0e                	jbe    f0100f6a <page_lookup+0x44>
		panic("pa2page called with invalid pa");
	return &pages[PGNUM(pa)];
f0100f5c:	8b 15 10 2a 1b f0    	mov    0xf01b2a10,%edx
f0100f62:	8d 04 c2             	lea    (%edx,%eax,8),%eax
}
f0100f65:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100f68:	c9                   	leave  
f0100f69:	c3                   	ret    
		panic("pa2page called with invalid pa");
f0100f6a:	83 ec 04             	sub    $0x4,%esp
f0100f6d:	68 1c 53 10 f0       	push   $0xf010531c
f0100f72:	6a 4f                	push   $0x4f
f0100f74:	68 1f 4f 10 f0       	push   $0xf0104f1f
f0100f79:	e8 22 f1 ff ff       	call   f01000a0 <_panic>
		return NULL;
f0100f7e:	b8 00 00 00 00       	mov    $0x0,%eax
f0100f83:	eb e0                	jmp    f0100f65 <page_lookup+0x3f>

f0100f85 <page_remove>:
{
f0100f85:	55                   	push   %ebp
f0100f86:	89 e5                	mov    %esp,%ebp
f0100f88:	53                   	push   %ebx
f0100f89:	83 ec 18             	sub    $0x18,%esp
f0100f8c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct PageInfo *page = page_lookup(pgdir, va, &pte_store);
f0100f8f:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0100f92:	50                   	push   %eax
f0100f93:	53                   	push   %ebx
f0100f94:	ff 75 08             	pushl  0x8(%ebp)
f0100f97:	e8 8a ff ff ff       	call   f0100f26 <page_lookup>
	if(page == NULL)
f0100f9c:	83 c4 10             	add    $0x10,%esp
f0100f9f:	85 c0                	test   %eax,%eax
f0100fa1:	74 18                	je     f0100fbb <page_remove+0x36>
	page_decref(page);
f0100fa3:	83 ec 0c             	sub    $0xc,%esp
f0100fa6:	50                   	push   %eax
f0100fa7:	e8 74 fe ff ff       	call   f0100e20 <page_decref>
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0100fac:	0f 01 3b             	invlpg (%ebx)
	*pte_store = 0;
f0100faf:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0100fb2:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
f0100fb8:	83 c4 10             	add    $0x10,%esp
}
f0100fbb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100fbe:	c9                   	leave  
f0100fbf:	c3                   	ret    

f0100fc0 <page_insert>:
{
f0100fc0:	55                   	push   %ebp
f0100fc1:	89 e5                	mov    %esp,%ebp
f0100fc3:	57                   	push   %edi
f0100fc4:	56                   	push   %esi
f0100fc5:	53                   	push   %ebx
f0100fc6:	83 ec 10             	sub    $0x10,%esp
f0100fc9:	8b 7d 08             	mov    0x8(%ebp),%edi
f0100fcc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	pte_t *pt_entry = pgdir_walk(pgdir, (void *)va, 1);
f0100fcf:	6a 01                	push   $0x1
f0100fd1:	ff 75 10             	pushl  0x10(%ebp)
f0100fd4:	57                   	push   %edi
f0100fd5:	e8 6c fe ff ff       	call   f0100e46 <pgdir_walk>
	if (pt_entry == NULL) {
f0100fda:	83 c4 10             	add    $0x10,%esp
f0100fdd:	85 c0                	test   %eax,%eax
f0100fdf:	74 56                	je     f0101037 <page_insert+0x77>
f0100fe1:	89 c6                	mov    %eax,%esi
	pp->pp_ref++;
f0100fe3:	66 ff 43 04          	incw   0x4(%ebx)
	if (*pt_entry & PTE_P)
f0100fe7:	f6 00 01             	testb  $0x1,(%eax)
f0100fea:	75 34                	jne    f0101020 <page_insert+0x60>
	return (pp - pages) << PGSHIFT;
f0100fec:	2b 1d 10 2a 1b f0    	sub    0xf01b2a10,%ebx
f0100ff2:	c1 fb 03             	sar    $0x3,%ebx
f0100ff5:	c1 e3 0c             	shl    $0xc,%ebx
	*pt_entry = page2pa(pp) | perm | PTE_P;
f0100ff8:	0b 5d 14             	or     0x14(%ebp),%ebx
f0100ffb:	83 cb 01             	or     $0x1,%ebx
f0100ffe:	89 1e                	mov    %ebx,(%esi)
	pgdir[PDX(va)] |= perm | PTE_P;
f0101000:	8b 45 10             	mov    0x10(%ebp),%eax
f0101003:	c1 e8 16             	shr    $0x16,%eax
f0101006:	8d 14 87             	lea    (%edi,%eax,4),%edx
f0101009:	8b 45 14             	mov    0x14(%ebp),%eax
f010100c:	0b 02                	or     (%edx),%eax
f010100e:	83 c8 01             	or     $0x1,%eax
f0101011:	89 02                	mov    %eax,(%edx)
	return 0;
f0101013:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0101018:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010101b:	5b                   	pop    %ebx
f010101c:	5e                   	pop    %esi
f010101d:	5f                   	pop    %edi
f010101e:	5d                   	pop    %ebp
f010101f:	c3                   	ret    
f0101020:	8b 45 10             	mov    0x10(%ebp),%eax
f0101023:	0f 01 38             	invlpg (%eax)
		page_remove(pgdir, va);
f0101026:	83 ec 08             	sub    $0x8,%esp
f0101029:	ff 75 10             	pushl  0x10(%ebp)
f010102c:	57                   	push   %edi
f010102d:	e8 53 ff ff ff       	call   f0100f85 <page_remove>
f0101032:	83 c4 10             	add    $0x10,%esp
f0101035:	eb b5                	jmp    f0100fec <page_insert+0x2c>
		return -E_NO_MEM;
f0101037:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f010103c:	eb da                	jmp    f0101018 <page_insert+0x58>

f010103e <mem_init>:
{
f010103e:	55                   	push   %ebp
f010103f:	89 e5                	mov    %esp,%ebp
f0101041:	57                   	push   %edi
f0101042:	56                   	push   %esi
f0101043:	53                   	push   %ebx
f0101044:	83 ec 3c             	sub    $0x3c,%esp
	basemem = nvram_read(NVRAM_BASELO);
f0101047:	b8 15 00 00 00       	mov    $0x15,%eax
f010104c:	e8 c9 f8 ff ff       	call   f010091a <nvram_read>
f0101051:	89 c3                	mov    %eax,%ebx
	extmem = nvram_read(NVRAM_EXTLO);
f0101053:	b8 17 00 00 00       	mov    $0x17,%eax
f0101058:	e8 bd f8 ff ff       	call   f010091a <nvram_read>
f010105d:	89 c6                	mov    %eax,%esi
	ext16mem = nvram_read(NVRAM_EXT16LO) * 64;
f010105f:	b8 34 00 00 00       	mov    $0x34,%eax
f0101064:	e8 b1 f8 ff ff       	call   f010091a <nvram_read>
	if (ext16mem)
f0101069:	c1 e0 06             	shl    $0x6,%eax
f010106c:	0f 84 d9 00 00 00    	je     f010114b <mem_init+0x10d>
		totalmem = 16 * 1024 + ext16mem;
f0101072:	05 00 40 00 00       	add    $0x4000,%eax
	npages = totalmem / (PGSIZE / 1024);
f0101077:	89 c2                	mov    %eax,%edx
f0101079:	c1 ea 02             	shr    $0x2,%edx
f010107c:	89 15 08 2a 1b f0    	mov    %edx,0xf01b2a08
	npages_basemem = basemem / (PGSIZE / 1024);
f0101082:	89 da                	mov    %ebx,%edx
f0101084:	c1 ea 02             	shr    $0x2,%edx
f0101087:	89 15 44 1d 1b f0    	mov    %edx,0xf01b1d44
	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f010108d:	89 c2                	mov    %eax,%edx
f010108f:	29 da                	sub    %ebx,%edx
f0101091:	52                   	push   %edx
f0101092:	53                   	push   %ebx
f0101093:	50                   	push   %eax
f0101094:	68 3c 53 10 f0       	push   $0xf010533c
f0101099:	e8 7e 20 00 00       	call   f010311c <cprintf>
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f010109e:	b8 00 10 00 00       	mov    $0x1000,%eax
f01010a3:	e8 99 f8 ff ff       	call   f0100941 <boot_alloc>
f01010a8:	a3 0c 2a 1b f0       	mov    %eax,0xf01b2a0c
	memset(kern_pgdir, 0, PGSIZE);
f01010ad:	83 c4 0c             	add    $0xc,%esp
f01010b0:	68 00 10 00 00       	push   $0x1000
f01010b5:	6a 00                	push   $0x0
f01010b7:	50                   	push   %eax
f01010b8:	e8 b7 34 00 00       	call   f0104574 <memset>
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f01010bd:	a1 0c 2a 1b f0       	mov    0xf01b2a0c,%eax
	if ((uint32_t)kva < KERNBASE)
f01010c2:	83 c4 10             	add    $0x10,%esp
f01010c5:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01010ca:	0f 86 91 00 00 00    	jbe    f0101161 <mem_init+0x123>
	return (physaddr_t)kva - KERNBASE;
f01010d0:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f01010d6:	83 ca 05             	or     $0x5,%edx
f01010d9:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	pages = boot_alloc(npages * sizeof(struct PageInfo));
f01010df:	a1 08 2a 1b f0       	mov    0xf01b2a08,%eax
f01010e4:	c1 e0 03             	shl    $0x3,%eax
f01010e7:	e8 55 f8 ff ff       	call   f0100941 <boot_alloc>
f01010ec:	a3 10 2a 1b f0       	mov    %eax,0xf01b2a10
	memset(pages, 0, npages * sizeof(struct PageInfo));
f01010f1:	83 ec 04             	sub    $0x4,%esp
f01010f4:	8b 0d 08 2a 1b f0    	mov    0xf01b2a08,%ecx
f01010fa:	8d 14 cd 00 00 00 00 	lea    0x0(,%ecx,8),%edx
f0101101:	52                   	push   %edx
f0101102:	6a 00                	push   $0x0
f0101104:	50                   	push   %eax
f0101105:	e8 6a 34 00 00       	call   f0104574 <memset>
	envs = boot_alloc(NENV * sizeof(struct Env));
f010110a:	b8 00 80 01 00       	mov    $0x18000,%eax
f010110f:	e8 2d f8 ff ff       	call   f0100941 <boot_alloc>
f0101114:	a3 4c 1d 1b f0       	mov    %eax,0xf01b1d4c
	page_init();
f0101119:	e8 a2 fb ff ff       	call   f0100cc0 <page_init>
	check_page_free_list(1);
f010111e:	b8 01 00 00 00       	mov    $0x1,%eax
f0101123:	e8 d8 f8 ff ff       	call   f0100a00 <check_page_free_list>
	if (!pages)
f0101128:	83 c4 10             	add    $0x10,%esp
f010112b:	83 3d 10 2a 1b f0 00 	cmpl   $0x0,0xf01b2a10
f0101132:	74 42                	je     f0101176 <mem_init+0x138>
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101134:	a1 40 1d 1b f0       	mov    0xf01b1d40,%eax
f0101139:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
f0101140:	85 c0                	test   %eax,%eax
f0101142:	74 49                	je     f010118d <mem_init+0x14f>
		++nfree;
f0101144:	ff 45 d4             	incl   -0x2c(%ebp)
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101147:	8b 00                	mov    (%eax),%eax
f0101149:	eb f5                	jmp    f0101140 <mem_init+0x102>
	else if (extmem)
f010114b:	85 f6                	test   %esi,%esi
f010114d:	74 0b                	je     f010115a <mem_init+0x11c>
		totalmem = 1 * 1024 + extmem;
f010114f:	8d 86 00 04 00 00    	lea    0x400(%esi),%eax
f0101155:	e9 1d ff ff ff       	jmp    f0101077 <mem_init+0x39>
		totalmem = basemem;
f010115a:	89 d8                	mov    %ebx,%eax
f010115c:	e9 16 ff ff ff       	jmp    f0101077 <mem_init+0x39>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0101161:	50                   	push   %eax
f0101162:	68 78 53 10 f0       	push   $0xf0105378
f0101167:	68 97 00 00 00       	push   $0x97
f010116c:	68 13 4f 10 f0       	push   $0xf0104f13
f0101171:	e8 2a ef ff ff       	call   f01000a0 <_panic>
		panic("'pages' is a null pointer!");
f0101176:	83 ec 04             	sub    $0x4,%esp
f0101179:	68 e0 4f 10 f0       	push   $0xf0104fe0
f010117e:	68 cc 02 00 00       	push   $0x2cc
f0101183:	68 13 4f 10 f0       	push   $0xf0104f13
f0101188:	e8 13 ef ff ff       	call   f01000a0 <_panic>
	assert((pp0 = page_alloc(0)));
f010118d:	83 ec 0c             	sub    $0xc,%esp
f0101190:	6a 00                	push   $0x0
f0101192:	e8 d9 fb ff ff       	call   f0100d70 <page_alloc>
f0101197:	89 c3                	mov    %eax,%ebx
f0101199:	83 c4 10             	add    $0x10,%esp
f010119c:	85 c0                	test   %eax,%eax
f010119e:	0f 84 0e 02 00 00    	je     f01013b2 <mem_init+0x374>
	assert((pp1 = page_alloc(0)));
f01011a4:	83 ec 0c             	sub    $0xc,%esp
f01011a7:	6a 00                	push   $0x0
f01011a9:	e8 c2 fb ff ff       	call   f0100d70 <page_alloc>
f01011ae:	89 c6                	mov    %eax,%esi
f01011b0:	83 c4 10             	add    $0x10,%esp
f01011b3:	85 c0                	test   %eax,%eax
f01011b5:	0f 84 10 02 00 00    	je     f01013cb <mem_init+0x38d>
	assert((pp2 = page_alloc(0)));
f01011bb:	83 ec 0c             	sub    $0xc,%esp
f01011be:	6a 00                	push   $0x0
f01011c0:	e8 ab fb ff ff       	call   f0100d70 <page_alloc>
f01011c5:	89 c7                	mov    %eax,%edi
f01011c7:	83 c4 10             	add    $0x10,%esp
f01011ca:	85 c0                	test   %eax,%eax
f01011cc:	0f 84 12 02 00 00    	je     f01013e4 <mem_init+0x3a6>
	assert(pp1 && pp1 != pp0);
f01011d2:	39 f3                	cmp    %esi,%ebx
f01011d4:	0f 84 23 02 00 00    	je     f01013fd <mem_init+0x3bf>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01011da:	39 c6                	cmp    %eax,%esi
f01011dc:	0f 84 34 02 00 00    	je     f0101416 <mem_init+0x3d8>
f01011e2:	39 c3                	cmp    %eax,%ebx
f01011e4:	0f 84 2c 02 00 00    	je     f0101416 <mem_init+0x3d8>
	return (pp - pages) << PGSHIFT;
f01011ea:	8b 0d 10 2a 1b f0    	mov    0xf01b2a10,%ecx
	assert(page2pa(pp0) < npages*PGSIZE);
f01011f0:	8b 15 08 2a 1b f0    	mov    0xf01b2a08,%edx
f01011f6:	c1 e2 0c             	shl    $0xc,%edx
f01011f9:	89 d8                	mov    %ebx,%eax
f01011fb:	29 c8                	sub    %ecx,%eax
f01011fd:	c1 f8 03             	sar    $0x3,%eax
f0101200:	c1 e0 0c             	shl    $0xc,%eax
f0101203:	39 d0                	cmp    %edx,%eax
f0101205:	0f 83 24 02 00 00    	jae    f010142f <mem_init+0x3f1>
f010120b:	89 f0                	mov    %esi,%eax
f010120d:	29 c8                	sub    %ecx,%eax
f010120f:	c1 f8 03             	sar    $0x3,%eax
f0101212:	c1 e0 0c             	shl    $0xc,%eax
	assert(page2pa(pp1) < npages*PGSIZE);
f0101215:	39 c2                	cmp    %eax,%edx
f0101217:	0f 86 2b 02 00 00    	jbe    f0101448 <mem_init+0x40a>
f010121d:	89 f8                	mov    %edi,%eax
f010121f:	29 c8                	sub    %ecx,%eax
f0101221:	c1 f8 03             	sar    $0x3,%eax
f0101224:	c1 e0 0c             	shl    $0xc,%eax
	assert(page2pa(pp2) < npages*PGSIZE);
f0101227:	39 c2                	cmp    %eax,%edx
f0101229:	0f 86 32 02 00 00    	jbe    f0101461 <mem_init+0x423>
	fl = page_free_list;
f010122f:	a1 40 1d 1b f0       	mov    0xf01b1d40,%eax
f0101234:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f0101237:	c7 05 40 1d 1b f0 00 	movl   $0x0,0xf01b1d40
f010123e:	00 00 00 
	assert(!page_alloc(0));
f0101241:	83 ec 0c             	sub    $0xc,%esp
f0101244:	6a 00                	push   $0x0
f0101246:	e8 25 fb ff ff       	call   f0100d70 <page_alloc>
f010124b:	83 c4 10             	add    $0x10,%esp
f010124e:	85 c0                	test   %eax,%eax
f0101250:	0f 85 24 02 00 00    	jne    f010147a <mem_init+0x43c>
	page_free(pp0);
f0101256:	83 ec 0c             	sub    $0xc,%esp
f0101259:	53                   	push   %ebx
f010125a:	e8 86 fb ff ff       	call   f0100de5 <page_free>
	page_free(pp1);
f010125f:	89 34 24             	mov    %esi,(%esp)
f0101262:	e8 7e fb ff ff       	call   f0100de5 <page_free>
	page_free(pp2);
f0101267:	89 3c 24             	mov    %edi,(%esp)
f010126a:	e8 76 fb ff ff       	call   f0100de5 <page_free>
	assert((pp0 = page_alloc(0)));
f010126f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101276:	e8 f5 fa ff ff       	call   f0100d70 <page_alloc>
f010127b:	89 c3                	mov    %eax,%ebx
f010127d:	83 c4 10             	add    $0x10,%esp
f0101280:	85 c0                	test   %eax,%eax
f0101282:	0f 84 0b 02 00 00    	je     f0101493 <mem_init+0x455>
	assert((pp1 = page_alloc(0)));
f0101288:	83 ec 0c             	sub    $0xc,%esp
f010128b:	6a 00                	push   $0x0
f010128d:	e8 de fa ff ff       	call   f0100d70 <page_alloc>
f0101292:	89 c6                	mov    %eax,%esi
f0101294:	83 c4 10             	add    $0x10,%esp
f0101297:	85 c0                	test   %eax,%eax
f0101299:	0f 84 0d 02 00 00    	je     f01014ac <mem_init+0x46e>
	assert((pp2 = page_alloc(0)));
f010129f:	83 ec 0c             	sub    $0xc,%esp
f01012a2:	6a 00                	push   $0x0
f01012a4:	e8 c7 fa ff ff       	call   f0100d70 <page_alloc>
f01012a9:	89 c7                	mov    %eax,%edi
f01012ab:	83 c4 10             	add    $0x10,%esp
f01012ae:	85 c0                	test   %eax,%eax
f01012b0:	0f 84 0f 02 00 00    	je     f01014c5 <mem_init+0x487>
	assert(pp1 && pp1 != pp0);
f01012b6:	39 f3                	cmp    %esi,%ebx
f01012b8:	0f 84 20 02 00 00    	je     f01014de <mem_init+0x4a0>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01012be:	39 c6                	cmp    %eax,%esi
f01012c0:	0f 84 31 02 00 00    	je     f01014f7 <mem_init+0x4b9>
f01012c6:	39 c3                	cmp    %eax,%ebx
f01012c8:	0f 84 29 02 00 00    	je     f01014f7 <mem_init+0x4b9>
	assert(!page_alloc(0));
f01012ce:	83 ec 0c             	sub    $0xc,%esp
f01012d1:	6a 00                	push   $0x0
f01012d3:	e8 98 fa ff ff       	call   f0100d70 <page_alloc>
f01012d8:	83 c4 10             	add    $0x10,%esp
f01012db:	85 c0                	test   %eax,%eax
f01012dd:	0f 85 2d 02 00 00    	jne    f0101510 <mem_init+0x4d2>
f01012e3:	89 d8                	mov    %ebx,%eax
f01012e5:	2b 05 10 2a 1b f0    	sub    0xf01b2a10,%eax
f01012eb:	c1 f8 03             	sar    $0x3,%eax
f01012ee:	89 c2                	mov    %eax,%edx
f01012f0:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f01012f3:	25 ff ff 0f 00       	and    $0xfffff,%eax
f01012f8:	3b 05 08 2a 1b f0    	cmp    0xf01b2a08,%eax
f01012fe:	0f 83 25 02 00 00    	jae    f0101529 <mem_init+0x4eb>
	memset(page2kva(pp0), 1, PGSIZE);
f0101304:	83 ec 04             	sub    $0x4,%esp
f0101307:	68 00 10 00 00       	push   $0x1000
f010130c:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f010130e:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f0101314:	52                   	push   %edx
f0101315:	e8 5a 32 00 00       	call   f0104574 <memset>
	page_free(pp0);
f010131a:	89 1c 24             	mov    %ebx,(%esp)
f010131d:	e8 c3 fa ff ff       	call   f0100de5 <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0101322:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0101329:	e8 42 fa ff ff       	call   f0100d70 <page_alloc>
f010132e:	83 c4 10             	add    $0x10,%esp
f0101331:	85 c0                	test   %eax,%eax
f0101333:	0f 84 02 02 00 00    	je     f010153b <mem_init+0x4fd>
	assert(pp && pp0 == pp);
f0101339:	39 c3                	cmp    %eax,%ebx
f010133b:	0f 85 13 02 00 00    	jne    f0101554 <mem_init+0x516>
	return (pp - pages) << PGSHIFT;
f0101341:	2b 05 10 2a 1b f0    	sub    0xf01b2a10,%eax
f0101347:	c1 f8 03             	sar    $0x3,%eax
f010134a:	89 c2                	mov    %eax,%edx
f010134c:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f010134f:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0101354:	3b 05 08 2a 1b f0    	cmp    0xf01b2a08,%eax
f010135a:	0f 83 0d 02 00 00    	jae    f010156d <mem_init+0x52f>
	return (void *)(pa + KERNBASE);
f0101360:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
f0101366:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
		assert(c[i] == 0);
f010136c:	80 38 00             	cmpb   $0x0,(%eax)
f010136f:	0f 85 0a 02 00 00    	jne    f010157f <mem_init+0x541>
f0101375:	40                   	inc    %eax
	for (i = 0; i < PGSIZE; i++)
f0101376:	39 d0                	cmp    %edx,%eax
f0101378:	75 f2                	jne    f010136c <mem_init+0x32e>
	page_free_list = fl;
f010137a:	8b 45 d0             	mov    -0x30(%ebp),%eax
f010137d:	a3 40 1d 1b f0       	mov    %eax,0xf01b1d40
	page_free(pp0);
f0101382:	83 ec 0c             	sub    $0xc,%esp
f0101385:	53                   	push   %ebx
f0101386:	e8 5a fa ff ff       	call   f0100de5 <page_free>
	page_free(pp1);
f010138b:	89 34 24             	mov    %esi,(%esp)
f010138e:	e8 52 fa ff ff       	call   f0100de5 <page_free>
	page_free(pp2);
f0101393:	89 3c 24             	mov    %edi,(%esp)
f0101396:	e8 4a fa ff ff       	call   f0100de5 <page_free>
	for (pp = page_free_list; pp; pp = pp->pp_link)
f010139b:	a1 40 1d 1b f0       	mov    0xf01b1d40,%eax
f01013a0:	83 c4 10             	add    $0x10,%esp
f01013a3:	85 c0                	test   %eax,%eax
f01013a5:	0f 84 ed 01 00 00    	je     f0101598 <mem_init+0x55a>
		--nfree;
f01013ab:	ff 4d d4             	decl   -0x2c(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link)
f01013ae:	8b 00                	mov    (%eax),%eax
f01013b0:	eb f1                	jmp    f01013a3 <mem_init+0x365>
	assert((pp0 = page_alloc(0)));
f01013b2:	68 fb 4f 10 f0       	push   $0xf0104ffb
f01013b7:	68 39 4f 10 f0       	push   $0xf0104f39
f01013bc:	68 d4 02 00 00       	push   $0x2d4
f01013c1:	68 13 4f 10 f0       	push   $0xf0104f13
f01013c6:	e8 d5 ec ff ff       	call   f01000a0 <_panic>
	assert((pp1 = page_alloc(0)));
f01013cb:	68 11 50 10 f0       	push   $0xf0105011
f01013d0:	68 39 4f 10 f0       	push   $0xf0104f39
f01013d5:	68 d5 02 00 00       	push   $0x2d5
f01013da:	68 13 4f 10 f0       	push   $0xf0104f13
f01013df:	e8 bc ec ff ff       	call   f01000a0 <_panic>
	assert((pp2 = page_alloc(0)));
f01013e4:	68 27 50 10 f0       	push   $0xf0105027
f01013e9:	68 39 4f 10 f0       	push   $0xf0104f39
f01013ee:	68 d6 02 00 00       	push   $0x2d6
f01013f3:	68 13 4f 10 f0       	push   $0xf0104f13
f01013f8:	e8 a3 ec ff ff       	call   f01000a0 <_panic>
	assert(pp1 && pp1 != pp0);
f01013fd:	68 3d 50 10 f0       	push   $0xf010503d
f0101402:	68 39 4f 10 f0       	push   $0xf0104f39
f0101407:	68 d9 02 00 00       	push   $0x2d9
f010140c:	68 13 4f 10 f0       	push   $0xf0104f13
f0101411:	e8 8a ec ff ff       	call   f01000a0 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101416:	68 9c 53 10 f0       	push   $0xf010539c
f010141b:	68 39 4f 10 f0       	push   $0xf0104f39
f0101420:	68 da 02 00 00       	push   $0x2da
f0101425:	68 13 4f 10 f0       	push   $0xf0104f13
f010142a:	e8 71 ec ff ff       	call   f01000a0 <_panic>
	assert(page2pa(pp0) < npages*PGSIZE);
f010142f:	68 4f 50 10 f0       	push   $0xf010504f
f0101434:	68 39 4f 10 f0       	push   $0xf0104f39
f0101439:	68 db 02 00 00       	push   $0x2db
f010143e:	68 13 4f 10 f0       	push   $0xf0104f13
f0101443:	e8 58 ec ff ff       	call   f01000a0 <_panic>
	assert(page2pa(pp1) < npages*PGSIZE);
f0101448:	68 6c 50 10 f0       	push   $0xf010506c
f010144d:	68 39 4f 10 f0       	push   $0xf0104f39
f0101452:	68 dc 02 00 00       	push   $0x2dc
f0101457:	68 13 4f 10 f0       	push   $0xf0104f13
f010145c:	e8 3f ec ff ff       	call   f01000a0 <_panic>
	assert(page2pa(pp2) < npages*PGSIZE);
f0101461:	68 89 50 10 f0       	push   $0xf0105089
f0101466:	68 39 4f 10 f0       	push   $0xf0104f39
f010146b:	68 dd 02 00 00       	push   $0x2dd
f0101470:	68 13 4f 10 f0       	push   $0xf0104f13
f0101475:	e8 26 ec ff ff       	call   f01000a0 <_panic>
	assert(!page_alloc(0));
f010147a:	68 a6 50 10 f0       	push   $0xf01050a6
f010147f:	68 39 4f 10 f0       	push   $0xf0104f39
f0101484:	68 e4 02 00 00       	push   $0x2e4
f0101489:	68 13 4f 10 f0       	push   $0xf0104f13
f010148e:	e8 0d ec ff ff       	call   f01000a0 <_panic>
	assert((pp0 = page_alloc(0)));
f0101493:	68 fb 4f 10 f0       	push   $0xf0104ffb
f0101498:	68 39 4f 10 f0       	push   $0xf0104f39
f010149d:	68 eb 02 00 00       	push   $0x2eb
f01014a2:	68 13 4f 10 f0       	push   $0xf0104f13
f01014a7:	e8 f4 eb ff ff       	call   f01000a0 <_panic>
	assert((pp1 = page_alloc(0)));
f01014ac:	68 11 50 10 f0       	push   $0xf0105011
f01014b1:	68 39 4f 10 f0       	push   $0xf0104f39
f01014b6:	68 ec 02 00 00       	push   $0x2ec
f01014bb:	68 13 4f 10 f0       	push   $0xf0104f13
f01014c0:	e8 db eb ff ff       	call   f01000a0 <_panic>
	assert((pp2 = page_alloc(0)));
f01014c5:	68 27 50 10 f0       	push   $0xf0105027
f01014ca:	68 39 4f 10 f0       	push   $0xf0104f39
f01014cf:	68 ed 02 00 00       	push   $0x2ed
f01014d4:	68 13 4f 10 f0       	push   $0xf0104f13
f01014d9:	e8 c2 eb ff ff       	call   f01000a0 <_panic>
	assert(pp1 && pp1 != pp0);
f01014de:	68 3d 50 10 f0       	push   $0xf010503d
f01014e3:	68 39 4f 10 f0       	push   $0xf0104f39
f01014e8:	68 ef 02 00 00       	push   $0x2ef
f01014ed:	68 13 4f 10 f0       	push   $0xf0104f13
f01014f2:	e8 a9 eb ff ff       	call   f01000a0 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01014f7:	68 9c 53 10 f0       	push   $0xf010539c
f01014fc:	68 39 4f 10 f0       	push   $0xf0104f39
f0101501:	68 f0 02 00 00       	push   $0x2f0
f0101506:	68 13 4f 10 f0       	push   $0xf0104f13
f010150b:	e8 90 eb ff ff       	call   f01000a0 <_panic>
	assert(!page_alloc(0));
f0101510:	68 a6 50 10 f0       	push   $0xf01050a6
f0101515:	68 39 4f 10 f0       	push   $0xf0104f39
f010151a:	68 f1 02 00 00       	push   $0x2f1
f010151f:	68 13 4f 10 f0       	push   $0xf0104f13
f0101524:	e8 77 eb ff ff       	call   f01000a0 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101529:	52                   	push   %edx
f010152a:	68 10 52 10 f0       	push   $0xf0105210
f010152f:	6a 56                	push   $0x56
f0101531:	68 1f 4f 10 f0       	push   $0xf0104f1f
f0101536:	e8 65 eb ff ff       	call   f01000a0 <_panic>
	assert((pp = page_alloc(ALLOC_ZERO)));
f010153b:	68 b5 50 10 f0       	push   $0xf01050b5
f0101540:	68 39 4f 10 f0       	push   $0xf0104f39
f0101545:	68 f6 02 00 00       	push   $0x2f6
f010154a:	68 13 4f 10 f0       	push   $0xf0104f13
f010154f:	e8 4c eb ff ff       	call   f01000a0 <_panic>
	assert(pp && pp0 == pp);
f0101554:	68 d3 50 10 f0       	push   $0xf01050d3
f0101559:	68 39 4f 10 f0       	push   $0xf0104f39
f010155e:	68 f7 02 00 00       	push   $0x2f7
f0101563:	68 13 4f 10 f0       	push   $0xf0104f13
f0101568:	e8 33 eb ff ff       	call   f01000a0 <_panic>
f010156d:	52                   	push   %edx
f010156e:	68 10 52 10 f0       	push   $0xf0105210
f0101573:	6a 56                	push   $0x56
f0101575:	68 1f 4f 10 f0       	push   $0xf0104f1f
f010157a:	e8 21 eb ff ff       	call   f01000a0 <_panic>
		assert(c[i] == 0);
f010157f:	68 e3 50 10 f0       	push   $0xf01050e3
f0101584:	68 39 4f 10 f0       	push   $0xf0104f39
f0101589:	68 fa 02 00 00       	push   $0x2fa
f010158e:	68 13 4f 10 f0       	push   $0xf0104f13
f0101593:	e8 08 eb ff ff       	call   f01000a0 <_panic>
	assert(nfree == 0);
f0101598:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f010159c:	0f 85 d6 07 00 00    	jne    f0101d78 <mem_init+0xd3a>
	cprintf("check_page_alloc() succeeded!\n");
f01015a2:	83 ec 0c             	sub    $0xc,%esp
f01015a5:	68 bc 53 10 f0       	push   $0xf01053bc
f01015aa:	e8 6d 1b 00 00       	call   f010311c <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01015af:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01015b6:	e8 b5 f7 ff ff       	call   f0100d70 <page_alloc>
f01015bb:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01015be:	83 c4 10             	add    $0x10,%esp
f01015c1:	85 c0                	test   %eax,%eax
f01015c3:	0f 84 c8 07 00 00    	je     f0101d91 <mem_init+0xd53>
	assert((pp1 = page_alloc(0)));
f01015c9:	83 ec 0c             	sub    $0xc,%esp
f01015cc:	6a 00                	push   $0x0
f01015ce:	e8 9d f7 ff ff       	call   f0100d70 <page_alloc>
f01015d3:	89 c6                	mov    %eax,%esi
f01015d5:	83 c4 10             	add    $0x10,%esp
f01015d8:	85 c0                	test   %eax,%eax
f01015da:	0f 84 ca 07 00 00    	je     f0101daa <mem_init+0xd6c>
	assert((pp2 = page_alloc(0)));
f01015e0:	83 ec 0c             	sub    $0xc,%esp
f01015e3:	6a 00                	push   $0x0
f01015e5:	e8 86 f7 ff ff       	call   f0100d70 <page_alloc>
f01015ea:	89 c3                	mov    %eax,%ebx
f01015ec:	83 c4 10             	add    $0x10,%esp
f01015ef:	85 c0                	test   %eax,%eax
f01015f1:	0f 84 cc 07 00 00    	je     f0101dc3 <mem_init+0xd85>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f01015f7:	39 75 d4             	cmp    %esi,-0x2c(%ebp)
f01015fa:	0f 84 dc 07 00 00    	je     f0101ddc <mem_init+0xd9e>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101600:	39 c6                	cmp    %eax,%esi
f0101602:	0f 84 ed 07 00 00    	je     f0101df5 <mem_init+0xdb7>
f0101608:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f010160b:	0f 84 e4 07 00 00    	je     f0101df5 <mem_init+0xdb7>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101611:	a1 40 1d 1b f0       	mov    0xf01b1d40,%eax
f0101616:	89 45 cc             	mov    %eax,-0x34(%ebp)
	page_free_list = 0;
f0101619:	c7 05 40 1d 1b f0 00 	movl   $0x0,0xf01b1d40
f0101620:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101623:	83 ec 0c             	sub    $0xc,%esp
f0101626:	6a 00                	push   $0x0
f0101628:	e8 43 f7 ff ff       	call   f0100d70 <page_alloc>
f010162d:	83 c4 10             	add    $0x10,%esp
f0101630:	85 c0                	test   %eax,%eax
f0101632:	0f 85 d6 07 00 00    	jne    f0101e0e <mem_init+0xdd0>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0101638:	83 ec 04             	sub    $0x4,%esp
f010163b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010163e:	50                   	push   %eax
f010163f:	6a 00                	push   $0x0
f0101641:	ff 35 0c 2a 1b f0    	pushl  0xf01b2a0c
f0101647:	e8 da f8 ff ff       	call   f0100f26 <page_lookup>
f010164c:	83 c4 10             	add    $0x10,%esp
f010164f:	85 c0                	test   %eax,%eax
f0101651:	0f 85 d0 07 00 00    	jne    f0101e27 <mem_init+0xde9>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0101657:	6a 02                	push   $0x2
f0101659:	6a 00                	push   $0x0
f010165b:	56                   	push   %esi
f010165c:	ff 35 0c 2a 1b f0    	pushl  0xf01b2a0c
f0101662:	e8 59 f9 ff ff       	call   f0100fc0 <page_insert>
f0101667:	83 c4 10             	add    $0x10,%esp
f010166a:	85 c0                	test   %eax,%eax
f010166c:	0f 89 ce 07 00 00    	jns    f0101e40 <mem_init+0xe02>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f0101672:	83 ec 0c             	sub    $0xc,%esp
f0101675:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101678:	e8 68 f7 ff ff       	call   f0100de5 <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f010167d:	6a 02                	push   $0x2
f010167f:	6a 00                	push   $0x0
f0101681:	56                   	push   %esi
f0101682:	ff 35 0c 2a 1b f0    	pushl  0xf01b2a0c
f0101688:	e8 33 f9 ff ff       	call   f0100fc0 <page_insert>
f010168d:	83 c4 20             	add    $0x20,%esp
f0101690:	85 c0                	test   %eax,%eax
f0101692:	0f 85 c1 07 00 00    	jne    f0101e59 <mem_init+0xe1b>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101698:	8b 3d 0c 2a 1b f0    	mov    0xf01b2a0c,%edi
	return (pp - pages) << PGSHIFT;
f010169e:	8b 0d 10 2a 1b f0    	mov    0xf01b2a10,%ecx
f01016a4:	89 4d d0             	mov    %ecx,-0x30(%ebp)
f01016a7:	8b 17                	mov    (%edi),%edx
f01016a9:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01016af:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01016b2:	29 c8                	sub    %ecx,%eax
f01016b4:	c1 f8 03             	sar    $0x3,%eax
f01016b7:	c1 e0 0c             	shl    $0xc,%eax
f01016ba:	39 c2                	cmp    %eax,%edx
f01016bc:	0f 85 b0 07 00 00    	jne    f0101e72 <mem_init+0xe34>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f01016c2:	ba 00 00 00 00       	mov    $0x0,%edx
f01016c7:	89 f8                	mov    %edi,%eax
f01016c9:	e8 d2 f2 ff ff       	call   f01009a0 <check_va2pa>
f01016ce:	89 c2                	mov    %eax,%edx
f01016d0:	89 f0                	mov    %esi,%eax
f01016d2:	2b 45 d0             	sub    -0x30(%ebp),%eax
f01016d5:	c1 f8 03             	sar    $0x3,%eax
f01016d8:	c1 e0 0c             	shl    $0xc,%eax
f01016db:	39 c2                	cmp    %eax,%edx
f01016dd:	0f 85 a8 07 00 00    	jne    f0101e8b <mem_init+0xe4d>
	assert(pp1->pp_ref == 1);
f01016e3:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f01016e8:	0f 85 b6 07 00 00    	jne    f0101ea4 <mem_init+0xe66>
	assert(pp0->pp_ref == 1);
f01016ee:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01016f1:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f01016f6:	0f 85 c1 07 00 00    	jne    f0101ebd <mem_init+0xe7f>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f01016fc:	6a 02                	push   $0x2
f01016fe:	68 00 10 00 00       	push   $0x1000
f0101703:	53                   	push   %ebx
f0101704:	57                   	push   %edi
f0101705:	e8 b6 f8 ff ff       	call   f0100fc0 <page_insert>
f010170a:	83 c4 10             	add    $0x10,%esp
f010170d:	85 c0                	test   %eax,%eax
f010170f:	0f 85 c1 07 00 00    	jne    f0101ed6 <mem_init+0xe98>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101715:	ba 00 10 00 00       	mov    $0x1000,%edx
f010171a:	a1 0c 2a 1b f0       	mov    0xf01b2a0c,%eax
f010171f:	e8 7c f2 ff ff       	call   f01009a0 <check_va2pa>
f0101724:	89 c2                	mov    %eax,%edx
f0101726:	89 d8                	mov    %ebx,%eax
f0101728:	2b 05 10 2a 1b f0    	sub    0xf01b2a10,%eax
f010172e:	c1 f8 03             	sar    $0x3,%eax
f0101731:	c1 e0 0c             	shl    $0xc,%eax
f0101734:	39 c2                	cmp    %eax,%edx
f0101736:	0f 85 b3 07 00 00    	jne    f0101eef <mem_init+0xeb1>
	assert(pp2->pp_ref == 1);
f010173c:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101741:	0f 85 c1 07 00 00    	jne    f0101f08 <mem_init+0xeca>
	// should be no free memory
	assert(!page_alloc(0));
f0101747:	83 ec 0c             	sub    $0xc,%esp
f010174a:	6a 00                	push   $0x0
f010174c:	e8 1f f6 ff ff       	call   f0100d70 <page_alloc>
f0101751:	83 c4 10             	add    $0x10,%esp
f0101754:	85 c0                	test   %eax,%eax
f0101756:	0f 85 c5 07 00 00    	jne    f0101f21 <mem_init+0xee3>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f010175c:	6a 02                	push   $0x2
f010175e:	68 00 10 00 00       	push   $0x1000
f0101763:	53                   	push   %ebx
f0101764:	ff 35 0c 2a 1b f0    	pushl  0xf01b2a0c
f010176a:	e8 51 f8 ff ff       	call   f0100fc0 <page_insert>
f010176f:	83 c4 10             	add    $0x10,%esp
f0101772:	85 c0                	test   %eax,%eax
f0101774:	0f 85 c0 07 00 00    	jne    f0101f3a <mem_init+0xefc>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f010177a:	ba 00 10 00 00       	mov    $0x1000,%edx
f010177f:	a1 0c 2a 1b f0       	mov    0xf01b2a0c,%eax
f0101784:	e8 17 f2 ff ff       	call   f01009a0 <check_va2pa>
f0101789:	89 c2                	mov    %eax,%edx
f010178b:	89 d8                	mov    %ebx,%eax
f010178d:	2b 05 10 2a 1b f0    	sub    0xf01b2a10,%eax
f0101793:	c1 f8 03             	sar    $0x3,%eax
f0101796:	c1 e0 0c             	shl    $0xc,%eax
f0101799:	39 c2                	cmp    %eax,%edx
f010179b:	0f 85 b2 07 00 00    	jne    f0101f53 <mem_init+0xf15>
	assert(pp2->pp_ref == 1);
f01017a1:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f01017a6:	0f 85 c0 07 00 00    	jne    f0101f6c <mem_init+0xf2e>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f01017ac:	83 ec 0c             	sub    $0xc,%esp
f01017af:	6a 00                	push   $0x0
f01017b1:	e8 ba f5 ff ff       	call   f0100d70 <page_alloc>
f01017b6:	83 c4 10             	add    $0x10,%esp
f01017b9:	85 c0                	test   %eax,%eax
f01017bb:	0f 85 c4 07 00 00    	jne    f0101f85 <mem_init+0xf47>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f01017c1:	8b 0d 0c 2a 1b f0    	mov    0xf01b2a0c,%ecx
f01017c7:	8b 01                	mov    (%ecx),%eax
f01017c9:	89 c2                	mov    %eax,%edx
f01017cb:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
	if (PGNUM(pa) >= npages)
f01017d1:	c1 e8 0c             	shr    $0xc,%eax
f01017d4:	3b 05 08 2a 1b f0    	cmp    0xf01b2a08,%eax
f01017da:	0f 83 be 07 00 00    	jae    f0101f9e <mem_init+0xf60>
	return (void *)(pa + KERNBASE);
f01017e0:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f01017e6:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f01017e9:	83 ec 04             	sub    $0x4,%esp
f01017ec:	6a 00                	push   $0x0
f01017ee:	68 00 10 00 00       	push   $0x1000
f01017f3:	51                   	push   %ecx
f01017f4:	e8 4d f6 ff ff       	call   f0100e46 <pgdir_walk>
f01017f9:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f01017fc:	8d 51 04             	lea    0x4(%ecx),%edx
f01017ff:	83 c4 10             	add    $0x10,%esp
f0101802:	39 c2                	cmp    %eax,%edx
f0101804:	0f 85 a9 07 00 00    	jne    f0101fb3 <mem_init+0xf75>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f010180a:	6a 06                	push   $0x6
f010180c:	68 00 10 00 00       	push   $0x1000
f0101811:	53                   	push   %ebx
f0101812:	ff 35 0c 2a 1b f0    	pushl  0xf01b2a0c
f0101818:	e8 a3 f7 ff ff       	call   f0100fc0 <page_insert>
f010181d:	83 c4 10             	add    $0x10,%esp
f0101820:	85 c0                	test   %eax,%eax
f0101822:	0f 85 a4 07 00 00    	jne    f0101fcc <mem_init+0xf8e>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101828:	8b 3d 0c 2a 1b f0    	mov    0xf01b2a0c,%edi
f010182e:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101833:	89 f8                	mov    %edi,%eax
f0101835:	e8 66 f1 ff ff       	call   f01009a0 <check_va2pa>
f010183a:	89 c2                	mov    %eax,%edx
	return (pp - pages) << PGSHIFT;
f010183c:	89 d8                	mov    %ebx,%eax
f010183e:	2b 05 10 2a 1b f0    	sub    0xf01b2a10,%eax
f0101844:	c1 f8 03             	sar    $0x3,%eax
f0101847:	c1 e0 0c             	shl    $0xc,%eax
f010184a:	39 c2                	cmp    %eax,%edx
f010184c:	0f 85 93 07 00 00    	jne    f0101fe5 <mem_init+0xfa7>
	assert(pp2->pp_ref == 1);
f0101852:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101857:	0f 85 a1 07 00 00    	jne    f0101ffe <mem_init+0xfc0>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f010185d:	83 ec 04             	sub    $0x4,%esp
f0101860:	6a 00                	push   $0x0
f0101862:	68 00 10 00 00       	push   $0x1000
f0101867:	57                   	push   %edi
f0101868:	e8 d9 f5 ff ff       	call   f0100e46 <pgdir_walk>
f010186d:	83 c4 10             	add    $0x10,%esp
f0101870:	f6 00 04             	testb  $0x4,(%eax)
f0101873:	0f 84 9e 07 00 00    	je     f0102017 <mem_init+0xfd9>
	assert(kern_pgdir[0] & PTE_U);
f0101879:	a1 0c 2a 1b f0       	mov    0xf01b2a0c,%eax
f010187e:	f6 00 04             	testb  $0x4,(%eax)
f0101881:	0f 84 a9 07 00 00    	je     f0102030 <mem_init+0xff2>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101887:	6a 02                	push   $0x2
f0101889:	68 00 10 00 00       	push   $0x1000
f010188e:	53                   	push   %ebx
f010188f:	50                   	push   %eax
f0101890:	e8 2b f7 ff ff       	call   f0100fc0 <page_insert>
f0101895:	83 c4 10             	add    $0x10,%esp
f0101898:	85 c0                	test   %eax,%eax
f010189a:	0f 85 a9 07 00 00    	jne    f0102049 <mem_init+0x100b>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f01018a0:	83 ec 04             	sub    $0x4,%esp
f01018a3:	6a 00                	push   $0x0
f01018a5:	68 00 10 00 00       	push   $0x1000
f01018aa:	ff 35 0c 2a 1b f0    	pushl  0xf01b2a0c
f01018b0:	e8 91 f5 ff ff       	call   f0100e46 <pgdir_walk>
f01018b5:	83 c4 10             	add    $0x10,%esp
f01018b8:	f6 00 02             	testb  $0x2,(%eax)
f01018bb:	0f 84 a1 07 00 00    	je     f0102062 <mem_init+0x1024>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f01018c1:	83 ec 04             	sub    $0x4,%esp
f01018c4:	6a 00                	push   $0x0
f01018c6:	68 00 10 00 00       	push   $0x1000
f01018cb:	ff 35 0c 2a 1b f0    	pushl  0xf01b2a0c
f01018d1:	e8 70 f5 ff ff       	call   f0100e46 <pgdir_walk>
f01018d6:	83 c4 10             	add    $0x10,%esp
f01018d9:	f6 00 04             	testb  $0x4,(%eax)
f01018dc:	0f 85 99 07 00 00    	jne    f010207b <mem_init+0x103d>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f01018e2:	6a 02                	push   $0x2
f01018e4:	68 00 00 40 00       	push   $0x400000
f01018e9:	ff 75 d4             	pushl  -0x2c(%ebp)
f01018ec:	ff 35 0c 2a 1b f0    	pushl  0xf01b2a0c
f01018f2:	e8 c9 f6 ff ff       	call   f0100fc0 <page_insert>
f01018f7:	83 c4 10             	add    $0x10,%esp
f01018fa:	85 c0                	test   %eax,%eax
f01018fc:	0f 89 92 07 00 00    	jns    f0102094 <mem_init+0x1056>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0101902:	6a 02                	push   $0x2
f0101904:	68 00 10 00 00       	push   $0x1000
f0101909:	56                   	push   %esi
f010190a:	ff 35 0c 2a 1b f0    	pushl  0xf01b2a0c
f0101910:	e8 ab f6 ff ff       	call   f0100fc0 <page_insert>
f0101915:	83 c4 10             	add    $0x10,%esp
f0101918:	85 c0                	test   %eax,%eax
f010191a:	0f 85 8d 07 00 00    	jne    f01020ad <mem_init+0x106f>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101920:	83 ec 04             	sub    $0x4,%esp
f0101923:	6a 00                	push   $0x0
f0101925:	68 00 10 00 00       	push   $0x1000
f010192a:	ff 35 0c 2a 1b f0    	pushl  0xf01b2a0c
f0101930:	e8 11 f5 ff ff       	call   f0100e46 <pgdir_walk>
f0101935:	83 c4 10             	add    $0x10,%esp
f0101938:	f6 00 04             	testb  $0x4,(%eax)
f010193b:	0f 85 85 07 00 00    	jne    f01020c6 <mem_init+0x1088>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0101941:	a1 0c 2a 1b f0       	mov    0xf01b2a0c,%eax
f0101946:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101949:	ba 00 00 00 00       	mov    $0x0,%edx
f010194e:	e8 4d f0 ff ff       	call   f01009a0 <check_va2pa>
f0101953:	89 f7                	mov    %esi,%edi
f0101955:	2b 3d 10 2a 1b f0    	sub    0xf01b2a10,%edi
f010195b:	c1 ff 03             	sar    $0x3,%edi
f010195e:	c1 e7 0c             	shl    $0xc,%edi
f0101961:	39 f8                	cmp    %edi,%eax
f0101963:	0f 85 76 07 00 00    	jne    f01020df <mem_init+0x10a1>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101969:	ba 00 10 00 00       	mov    $0x1000,%edx
f010196e:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101971:	e8 2a f0 ff ff       	call   f01009a0 <check_va2pa>
f0101976:	39 c7                	cmp    %eax,%edi
f0101978:	0f 85 7a 07 00 00    	jne    f01020f8 <mem_init+0x10ba>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f010197e:	66 83 7e 04 02       	cmpw   $0x2,0x4(%esi)
f0101983:	0f 85 88 07 00 00    	jne    f0102111 <mem_init+0x10d3>
	assert(pp2->pp_ref == 0);
f0101989:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f010198e:	0f 85 96 07 00 00    	jne    f010212a <mem_init+0x10ec>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f0101994:	83 ec 0c             	sub    $0xc,%esp
f0101997:	6a 00                	push   $0x0
f0101999:	e8 d2 f3 ff ff       	call   f0100d70 <page_alloc>
f010199e:	83 c4 10             	add    $0x10,%esp
f01019a1:	85 c0                	test   %eax,%eax
f01019a3:	0f 84 9a 07 00 00    	je     f0102143 <mem_init+0x1105>
f01019a9:	39 c3                	cmp    %eax,%ebx
f01019ab:	0f 85 92 07 00 00    	jne    f0102143 <mem_init+0x1105>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f01019b1:	83 ec 08             	sub    $0x8,%esp
f01019b4:	6a 00                	push   $0x0
f01019b6:	ff 35 0c 2a 1b f0    	pushl  0xf01b2a0c
f01019bc:	e8 c4 f5 ff ff       	call   f0100f85 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f01019c1:	8b 3d 0c 2a 1b f0    	mov    0xf01b2a0c,%edi
f01019c7:	ba 00 00 00 00       	mov    $0x0,%edx
f01019cc:	89 f8                	mov    %edi,%eax
f01019ce:	e8 cd ef ff ff       	call   f01009a0 <check_va2pa>
f01019d3:	83 c4 10             	add    $0x10,%esp
f01019d6:	83 f8 ff             	cmp    $0xffffffff,%eax
f01019d9:	0f 85 7d 07 00 00    	jne    f010215c <mem_init+0x111e>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f01019df:	ba 00 10 00 00       	mov    $0x1000,%edx
f01019e4:	89 f8                	mov    %edi,%eax
f01019e6:	e8 b5 ef ff ff       	call   f01009a0 <check_va2pa>
f01019eb:	89 c2                	mov    %eax,%edx
f01019ed:	89 f0                	mov    %esi,%eax
f01019ef:	2b 05 10 2a 1b f0    	sub    0xf01b2a10,%eax
f01019f5:	c1 f8 03             	sar    $0x3,%eax
f01019f8:	c1 e0 0c             	shl    $0xc,%eax
f01019fb:	39 c2                	cmp    %eax,%edx
f01019fd:	0f 85 72 07 00 00    	jne    f0102175 <mem_init+0x1137>
	assert(pp1->pp_ref == 1);
f0101a03:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101a08:	0f 85 80 07 00 00    	jne    f010218e <mem_init+0x1150>
	assert(pp2->pp_ref == 0);
f0101a0e:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101a13:	0f 85 8e 07 00 00    	jne    f01021a7 <mem_init+0x1169>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f0101a19:	6a 00                	push   $0x0
f0101a1b:	68 00 10 00 00       	push   $0x1000
f0101a20:	56                   	push   %esi
f0101a21:	57                   	push   %edi
f0101a22:	e8 99 f5 ff ff       	call   f0100fc0 <page_insert>
f0101a27:	83 c4 10             	add    $0x10,%esp
f0101a2a:	85 c0                	test   %eax,%eax
f0101a2c:	0f 85 8e 07 00 00    	jne    f01021c0 <mem_init+0x1182>
	assert(pp1->pp_ref);
f0101a32:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101a37:	0f 84 9c 07 00 00    	je     f01021d9 <mem_init+0x119b>
	assert(pp1->pp_link == NULL);
f0101a3d:	83 3e 00             	cmpl   $0x0,(%esi)
f0101a40:	0f 85 ac 07 00 00    	jne    f01021f2 <mem_init+0x11b4>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f0101a46:	83 ec 08             	sub    $0x8,%esp
f0101a49:	68 00 10 00 00       	push   $0x1000
f0101a4e:	ff 35 0c 2a 1b f0    	pushl  0xf01b2a0c
f0101a54:	e8 2c f5 ff ff       	call   f0100f85 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101a59:	8b 3d 0c 2a 1b f0    	mov    0xf01b2a0c,%edi
f0101a5f:	ba 00 00 00 00       	mov    $0x0,%edx
f0101a64:	89 f8                	mov    %edi,%eax
f0101a66:	e8 35 ef ff ff       	call   f01009a0 <check_va2pa>
f0101a6b:	83 c4 10             	add    $0x10,%esp
f0101a6e:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101a71:	0f 85 94 07 00 00    	jne    f010220b <mem_init+0x11cd>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0101a77:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101a7c:	89 f8                	mov    %edi,%eax
f0101a7e:	e8 1d ef ff ff       	call   f01009a0 <check_va2pa>
f0101a83:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101a86:	0f 85 98 07 00 00    	jne    f0102224 <mem_init+0x11e6>
	assert(pp1->pp_ref == 0);
f0101a8c:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101a91:	0f 85 a6 07 00 00    	jne    f010223d <mem_init+0x11ff>
	assert(pp2->pp_ref == 0);
f0101a97:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101a9c:	0f 85 b4 07 00 00    	jne    f0102256 <mem_init+0x1218>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f0101aa2:	83 ec 0c             	sub    $0xc,%esp
f0101aa5:	6a 00                	push   $0x0
f0101aa7:	e8 c4 f2 ff ff       	call   f0100d70 <page_alloc>
f0101aac:	83 c4 10             	add    $0x10,%esp
f0101aaf:	85 c0                	test   %eax,%eax
f0101ab1:	0f 84 b8 07 00 00    	je     f010226f <mem_init+0x1231>
f0101ab7:	39 c6                	cmp    %eax,%esi
f0101ab9:	0f 85 b0 07 00 00    	jne    f010226f <mem_init+0x1231>

	// should be no free memory
	assert(!page_alloc(0));
f0101abf:	83 ec 0c             	sub    $0xc,%esp
f0101ac2:	6a 00                	push   $0x0
f0101ac4:	e8 a7 f2 ff ff       	call   f0100d70 <page_alloc>
f0101ac9:	83 c4 10             	add    $0x10,%esp
f0101acc:	85 c0                	test   %eax,%eax
f0101ace:	0f 85 b4 07 00 00    	jne    f0102288 <mem_init+0x124a>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101ad4:	8b 0d 0c 2a 1b f0    	mov    0xf01b2a0c,%ecx
f0101ada:	8b 11                	mov    (%ecx),%edx
f0101adc:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101ae2:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101ae5:	2b 05 10 2a 1b f0    	sub    0xf01b2a10,%eax
f0101aeb:	c1 f8 03             	sar    $0x3,%eax
f0101aee:	c1 e0 0c             	shl    $0xc,%eax
f0101af1:	39 c2                	cmp    %eax,%edx
f0101af3:	0f 85 a8 07 00 00    	jne    f01022a1 <mem_init+0x1263>
	kern_pgdir[0] = 0;
f0101af9:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0101aff:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101b02:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101b07:	0f 85 ad 07 00 00    	jne    f01022ba <mem_init+0x127c>
	pp0->pp_ref = 0;
f0101b0d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101b10:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f0101b16:	83 ec 0c             	sub    $0xc,%esp
f0101b19:	50                   	push   %eax
f0101b1a:	e8 c6 f2 ff ff       	call   f0100de5 <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f0101b1f:	83 c4 0c             	add    $0xc,%esp
f0101b22:	6a 01                	push   $0x1
f0101b24:	68 00 10 40 00       	push   $0x401000
f0101b29:	ff 35 0c 2a 1b f0    	pushl  0xf01b2a0c
f0101b2f:	e8 12 f3 ff ff       	call   f0100e46 <pgdir_walk>
f0101b34:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f0101b37:	8b 0d 0c 2a 1b f0    	mov    0xf01b2a0c,%ecx
f0101b3d:	8b 51 04             	mov    0x4(%ecx),%edx
f0101b40:	89 d7                	mov    %edx,%edi
f0101b42:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
f0101b48:	89 7d d0             	mov    %edi,-0x30(%ebp)
	if (PGNUM(pa) >= npages)
f0101b4b:	8b 3d 08 2a 1b f0    	mov    0xf01b2a08,%edi
f0101b51:	c1 ea 0c             	shr    $0xc,%edx
f0101b54:	83 c4 10             	add    $0x10,%esp
f0101b57:	39 fa                	cmp    %edi,%edx
f0101b59:	0f 83 74 07 00 00    	jae    f01022d3 <mem_init+0x1295>
	assert(ptep == ptep1 + PTX(va));
f0101b5f:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0101b62:	81 ea fc ff ff 0f    	sub    $0xffffffc,%edx
f0101b68:	39 d0                	cmp    %edx,%eax
f0101b6a:	0f 85 7a 07 00 00    	jne    f01022ea <mem_init+0x12ac>
	kern_pgdir[PDX(va)] = 0;
f0101b70:	c7 41 04 00 00 00 00 	movl   $0x0,0x4(%ecx)
	pp0->pp_ref = 0;
f0101b77:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101b7a:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
	return (pp - pages) << PGSHIFT;
f0101b80:	2b 05 10 2a 1b f0    	sub    0xf01b2a10,%eax
f0101b86:	c1 f8 03             	sar    $0x3,%eax
f0101b89:	89 c2                	mov    %eax,%edx
f0101b8b:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0101b8e:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0101b93:	39 c7                	cmp    %eax,%edi
f0101b95:	0f 86 68 07 00 00    	jbe    f0102303 <mem_init+0x12c5>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f0101b9b:	83 ec 04             	sub    $0x4,%esp
f0101b9e:	68 00 10 00 00       	push   $0x1000
f0101ba3:	68 ff 00 00 00       	push   $0xff
	return (void *)(pa + KERNBASE);
f0101ba8:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f0101bae:	52                   	push   %edx
f0101baf:	e8 c0 29 00 00       	call   f0104574 <memset>
	page_free(pp0);
f0101bb4:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0101bb7:	89 3c 24             	mov    %edi,(%esp)
f0101bba:	e8 26 f2 ff ff       	call   f0100de5 <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f0101bbf:	83 c4 0c             	add    $0xc,%esp
f0101bc2:	6a 01                	push   $0x1
f0101bc4:	6a 00                	push   $0x0
f0101bc6:	ff 35 0c 2a 1b f0    	pushl  0xf01b2a0c
f0101bcc:	e8 75 f2 ff ff       	call   f0100e46 <pgdir_walk>
	return (pp - pages) << PGSHIFT;
f0101bd1:	89 f8                	mov    %edi,%eax
f0101bd3:	2b 05 10 2a 1b f0    	sub    0xf01b2a10,%eax
f0101bd9:	c1 f8 03             	sar    $0x3,%eax
f0101bdc:	89 c2                	mov    %eax,%edx
f0101bde:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0101be1:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0101be6:	83 c4 10             	add    $0x10,%esp
f0101be9:	3b 05 08 2a 1b f0    	cmp    0xf01b2a08,%eax
f0101bef:	0f 83 20 07 00 00    	jae    f0102315 <mem_init+0x12d7>
	return (void *)(pa + KERNBASE);
f0101bf5:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f0101bfb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0101bfe:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0101c04:	8b 38                	mov    (%eax),%edi
f0101c06:	83 e7 01             	and    $0x1,%edi
f0101c09:	0f 85 18 07 00 00    	jne    f0102327 <mem_init+0x12e9>
f0101c0f:	83 c0 04             	add    $0x4,%eax
	for(i=0; i<NPTENTRIES; i++)
f0101c12:	39 d0                	cmp    %edx,%eax
f0101c14:	75 ee                	jne    f0101c04 <mem_init+0xbc6>
	kern_pgdir[0] = 0;
f0101c16:	a1 0c 2a 1b f0       	mov    0xf01b2a0c,%eax
f0101c1b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f0101c21:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101c24:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// give free list back
	page_free_list = fl;
f0101c2a:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0101c2d:	89 0d 40 1d 1b f0    	mov    %ecx,0xf01b1d40

	// free the pages we took
	page_free(pp0);
f0101c33:	83 ec 0c             	sub    $0xc,%esp
f0101c36:	50                   	push   %eax
f0101c37:	e8 a9 f1 ff ff       	call   f0100de5 <page_free>
	page_free(pp1);
f0101c3c:	89 34 24             	mov    %esi,(%esp)
f0101c3f:	e8 a1 f1 ff ff       	call   f0100de5 <page_free>
	page_free(pp2);
f0101c44:	89 1c 24             	mov    %ebx,(%esp)
f0101c47:	e8 99 f1 ff ff       	call   f0100de5 <page_free>

	cprintf("check_page() succeeded!\n");
f0101c4c:	c7 04 24 c4 51 10 f0 	movl   $0xf01051c4,(%esp)
f0101c53:	e8 c4 14 00 00       	call   f010311c <cprintf>
	boot_map_region(kern_pgdir, UPAGES, PTSIZE, PADDR((void *)pages), PTE_U | PTE_P);
f0101c58:	a1 10 2a 1b f0       	mov    0xf01b2a10,%eax
	if ((uint32_t)kva < KERNBASE)
f0101c5d:	83 c4 10             	add    $0x10,%esp
f0101c60:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101c65:	0f 86 d5 06 00 00    	jbe    f0102340 <mem_init+0x1302>
f0101c6b:	83 ec 08             	sub    $0x8,%esp
f0101c6e:	6a 05                	push   $0x5
	return (physaddr_t)kva - KERNBASE;
f0101c70:	05 00 00 00 10       	add    $0x10000000,%eax
f0101c75:	50                   	push   %eax
f0101c76:	b9 00 00 40 00       	mov    $0x400000,%ecx
f0101c7b:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f0101c80:	a1 0c 2a 1b f0       	mov    0xf01b2a0c,%eax
f0101c85:	e8 48 f2 ff ff       	call   f0100ed2 <boot_map_region>
	boot_map_region(kern_pgdir, UENVS, PTSIZE, PADDR((void *)envs), PTE_U | PTE_P);
f0101c8a:	a1 4c 1d 1b f0       	mov    0xf01b1d4c,%eax
	if ((uint32_t)kva < KERNBASE)
f0101c8f:	83 c4 10             	add    $0x10,%esp
f0101c92:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101c97:	0f 86 b8 06 00 00    	jbe    f0102355 <mem_init+0x1317>
f0101c9d:	83 ec 08             	sub    $0x8,%esp
f0101ca0:	6a 05                	push   $0x5
	return (physaddr_t)kva - KERNBASE;
f0101ca2:	05 00 00 00 10       	add    $0x10000000,%eax
f0101ca7:	50                   	push   %eax
f0101ca8:	b9 00 00 40 00       	mov    $0x400000,%ecx
f0101cad:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f0101cb2:	a1 0c 2a 1b f0       	mov    0xf01b2a0c,%eax
f0101cb7:	e8 16 f2 ff ff       	call   f0100ed2 <boot_map_region>
	if ((uint32_t)kva < KERNBASE)
f0101cbc:	83 c4 10             	add    $0x10,%esp
f0101cbf:	b8 00 30 11 f0       	mov    $0xf0113000,%eax
f0101cc4:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101cc9:	0f 86 9b 06 00 00    	jbe    f010236a <mem_init+0x132c>
	boot_map_region(kern_pgdir, KSTACKTOP - KSTKSIZE, KSTKSIZE, PADDR((void *)(bootstack)), PTE_P | PTE_W);
f0101ccf:	83 ec 08             	sub    $0x8,%esp
f0101cd2:	6a 03                	push   $0x3
f0101cd4:	68 00 30 11 00       	push   $0x113000
f0101cd9:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0101cde:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f0101ce3:	a1 0c 2a 1b f0       	mov    0xf01b2a0c,%eax
f0101ce8:	e8 e5 f1 ff ff       	call   f0100ed2 <boot_map_region>
	boot_map_region(kern_pgdir, KERNBASE, (1ULL << 32) - KERNBASE, PADDR((void *)KERNBASE), PTE_P | PTE_W);
f0101ced:	83 c4 08             	add    $0x8,%esp
f0101cf0:	6a 03                	push   $0x3
f0101cf2:	6a 00                	push   $0x0
f0101cf4:	b9 00 00 00 10       	mov    $0x10000000,%ecx
f0101cf9:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f0101cfe:	a1 0c 2a 1b f0       	mov    0xf01b2a0c,%eax
f0101d03:	e8 ca f1 ff ff       	call   f0100ed2 <boot_map_region>
	pgdir = kern_pgdir;
f0101d08:	a1 0c 2a 1b f0       	mov    0xf01b2a0c,%eax
f0101d0d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f0101d10:	a1 08 2a 1b f0       	mov    0xf01b2a08,%eax
f0101d15:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f0101d18:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
f0101d1f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0101d24:	89 45 d0             	mov    %eax,-0x30(%ebp)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0101d27:	8b 35 10 2a 1b f0    	mov    0xf01b2a10,%esi
f0101d2d:	89 75 cc             	mov    %esi,-0x34(%ebp)
	return (physaddr_t)kva - KERNBASE;
f0101d30:	8d 86 00 00 00 10    	lea    0x10000000(%esi),%eax
f0101d36:	89 45 c8             	mov    %eax,-0x38(%ebp)
	for (i = 0; i < n; i += PGSIZE)
f0101d39:	83 c4 10             	add    $0x10,%esp
f0101d3c:	89 fb                	mov    %edi,%ebx
f0101d3e:	39 5d d0             	cmp    %ebx,-0x30(%ebp)
f0101d41:	0f 86 66 06 00 00    	jbe    f01023ad <mem_init+0x136f>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0101d47:	8d 93 00 00 00 ef    	lea    -0x11000000(%ebx),%edx
f0101d4d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101d50:	e8 4b ec ff ff       	call   f01009a0 <check_va2pa>
	if ((uint32_t)kva < KERNBASE)
f0101d55:	81 7d cc ff ff ff ef 	cmpl   $0xefffffff,-0x34(%ebp)
f0101d5c:	0f 86 1d 06 00 00    	jbe    f010237f <mem_init+0x1341>
f0101d62:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0101d65:	8d 14 0b             	lea    (%ebx,%ecx,1),%edx
f0101d68:	39 d0                	cmp    %edx,%eax
f0101d6a:	0f 85 24 06 00 00    	jne    f0102394 <mem_init+0x1356>
	for (i = 0; i < n; i += PGSIZE)
f0101d70:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0101d76:	eb c6                	jmp    f0101d3e <mem_init+0xd00>
	assert(nfree == 0);
f0101d78:	68 ed 50 10 f0       	push   $0xf01050ed
f0101d7d:	68 39 4f 10 f0       	push   $0xf0104f39
f0101d82:	68 07 03 00 00       	push   $0x307
f0101d87:	68 13 4f 10 f0       	push   $0xf0104f13
f0101d8c:	e8 0f e3 ff ff       	call   f01000a0 <_panic>
	assert((pp0 = page_alloc(0)));
f0101d91:	68 fb 4f 10 f0       	push   $0xf0104ffb
f0101d96:	68 39 4f 10 f0       	push   $0xf0104f39
f0101d9b:	68 65 03 00 00       	push   $0x365
f0101da0:	68 13 4f 10 f0       	push   $0xf0104f13
f0101da5:	e8 f6 e2 ff ff       	call   f01000a0 <_panic>
	assert((pp1 = page_alloc(0)));
f0101daa:	68 11 50 10 f0       	push   $0xf0105011
f0101daf:	68 39 4f 10 f0       	push   $0xf0104f39
f0101db4:	68 66 03 00 00       	push   $0x366
f0101db9:	68 13 4f 10 f0       	push   $0xf0104f13
f0101dbe:	e8 dd e2 ff ff       	call   f01000a0 <_panic>
	assert((pp2 = page_alloc(0)));
f0101dc3:	68 27 50 10 f0       	push   $0xf0105027
f0101dc8:	68 39 4f 10 f0       	push   $0xf0104f39
f0101dcd:	68 67 03 00 00       	push   $0x367
f0101dd2:	68 13 4f 10 f0       	push   $0xf0104f13
f0101dd7:	e8 c4 e2 ff ff       	call   f01000a0 <_panic>
	assert(pp1 && pp1 != pp0);
f0101ddc:	68 3d 50 10 f0       	push   $0xf010503d
f0101de1:	68 39 4f 10 f0       	push   $0xf0104f39
f0101de6:	68 6a 03 00 00       	push   $0x36a
f0101deb:	68 13 4f 10 f0       	push   $0xf0104f13
f0101df0:	e8 ab e2 ff ff       	call   f01000a0 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101df5:	68 9c 53 10 f0       	push   $0xf010539c
f0101dfa:	68 39 4f 10 f0       	push   $0xf0104f39
f0101dff:	68 6b 03 00 00       	push   $0x36b
f0101e04:	68 13 4f 10 f0       	push   $0xf0104f13
f0101e09:	e8 92 e2 ff ff       	call   f01000a0 <_panic>
	assert(!page_alloc(0));
f0101e0e:	68 a6 50 10 f0       	push   $0xf01050a6
f0101e13:	68 39 4f 10 f0       	push   $0xf0104f39
f0101e18:	68 72 03 00 00       	push   $0x372
f0101e1d:	68 13 4f 10 f0       	push   $0xf0104f13
f0101e22:	e8 79 e2 ff ff       	call   f01000a0 <_panic>
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0101e27:	68 dc 53 10 f0       	push   $0xf01053dc
f0101e2c:	68 39 4f 10 f0       	push   $0xf0104f39
f0101e31:	68 75 03 00 00       	push   $0x375
f0101e36:	68 13 4f 10 f0       	push   $0xf0104f13
f0101e3b:	e8 60 e2 ff ff       	call   f01000a0 <_panic>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0101e40:	68 14 54 10 f0       	push   $0xf0105414
f0101e45:	68 39 4f 10 f0       	push   $0xf0104f39
f0101e4a:	68 78 03 00 00       	push   $0x378
f0101e4f:	68 13 4f 10 f0       	push   $0xf0104f13
f0101e54:	e8 47 e2 ff ff       	call   f01000a0 <_panic>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0101e59:	68 44 54 10 f0       	push   $0xf0105444
f0101e5e:	68 39 4f 10 f0       	push   $0xf0104f39
f0101e63:	68 7c 03 00 00       	push   $0x37c
f0101e68:	68 13 4f 10 f0       	push   $0xf0104f13
f0101e6d:	e8 2e e2 ff ff       	call   f01000a0 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101e72:	68 74 54 10 f0       	push   $0xf0105474
f0101e77:	68 39 4f 10 f0       	push   $0xf0104f39
f0101e7c:	68 7d 03 00 00       	push   $0x37d
f0101e81:	68 13 4f 10 f0       	push   $0xf0104f13
f0101e86:	e8 15 e2 ff ff       	call   f01000a0 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0101e8b:	68 9c 54 10 f0       	push   $0xf010549c
f0101e90:	68 39 4f 10 f0       	push   $0xf0104f39
f0101e95:	68 7e 03 00 00       	push   $0x37e
f0101e9a:	68 13 4f 10 f0       	push   $0xf0104f13
f0101e9f:	e8 fc e1 ff ff       	call   f01000a0 <_panic>
	assert(pp1->pp_ref == 1);
f0101ea4:	68 f8 50 10 f0       	push   $0xf01050f8
f0101ea9:	68 39 4f 10 f0       	push   $0xf0104f39
f0101eae:	68 7f 03 00 00       	push   $0x37f
f0101eb3:	68 13 4f 10 f0       	push   $0xf0104f13
f0101eb8:	e8 e3 e1 ff ff       	call   f01000a0 <_panic>
	assert(pp0->pp_ref == 1);
f0101ebd:	68 09 51 10 f0       	push   $0xf0105109
f0101ec2:	68 39 4f 10 f0       	push   $0xf0104f39
f0101ec7:	68 80 03 00 00       	push   $0x380
f0101ecc:	68 13 4f 10 f0       	push   $0xf0104f13
f0101ed1:	e8 ca e1 ff ff       	call   f01000a0 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101ed6:	68 cc 54 10 f0       	push   $0xf01054cc
f0101edb:	68 39 4f 10 f0       	push   $0xf0104f39
f0101ee0:	68 83 03 00 00       	push   $0x383
f0101ee5:	68 13 4f 10 f0       	push   $0xf0104f13
f0101eea:	e8 b1 e1 ff ff       	call   f01000a0 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101eef:	68 08 55 10 f0       	push   $0xf0105508
f0101ef4:	68 39 4f 10 f0       	push   $0xf0104f39
f0101ef9:	68 84 03 00 00       	push   $0x384
f0101efe:	68 13 4f 10 f0       	push   $0xf0104f13
f0101f03:	e8 98 e1 ff ff       	call   f01000a0 <_panic>
	assert(pp2->pp_ref == 1);
f0101f08:	68 1a 51 10 f0       	push   $0xf010511a
f0101f0d:	68 39 4f 10 f0       	push   $0xf0104f39
f0101f12:	68 85 03 00 00       	push   $0x385
f0101f17:	68 13 4f 10 f0       	push   $0xf0104f13
f0101f1c:	e8 7f e1 ff ff       	call   f01000a0 <_panic>
	assert(!page_alloc(0));
f0101f21:	68 a6 50 10 f0       	push   $0xf01050a6
f0101f26:	68 39 4f 10 f0       	push   $0xf0104f39
f0101f2b:	68 87 03 00 00       	push   $0x387
f0101f30:	68 13 4f 10 f0       	push   $0xf0104f13
f0101f35:	e8 66 e1 ff ff       	call   f01000a0 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101f3a:	68 cc 54 10 f0       	push   $0xf01054cc
f0101f3f:	68 39 4f 10 f0       	push   $0xf0104f39
f0101f44:	68 8a 03 00 00       	push   $0x38a
f0101f49:	68 13 4f 10 f0       	push   $0xf0104f13
f0101f4e:	e8 4d e1 ff ff       	call   f01000a0 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101f53:	68 08 55 10 f0       	push   $0xf0105508
f0101f58:	68 39 4f 10 f0       	push   $0xf0104f39
f0101f5d:	68 8b 03 00 00       	push   $0x38b
f0101f62:	68 13 4f 10 f0       	push   $0xf0104f13
f0101f67:	e8 34 e1 ff ff       	call   f01000a0 <_panic>
	assert(pp2->pp_ref == 1);
f0101f6c:	68 1a 51 10 f0       	push   $0xf010511a
f0101f71:	68 39 4f 10 f0       	push   $0xf0104f39
f0101f76:	68 8c 03 00 00       	push   $0x38c
f0101f7b:	68 13 4f 10 f0       	push   $0xf0104f13
f0101f80:	e8 1b e1 ff ff       	call   f01000a0 <_panic>
	assert(!page_alloc(0));
f0101f85:	68 a6 50 10 f0       	push   $0xf01050a6
f0101f8a:	68 39 4f 10 f0       	push   $0xf0104f39
f0101f8f:	68 90 03 00 00       	push   $0x390
f0101f94:	68 13 4f 10 f0       	push   $0xf0104f13
f0101f99:	e8 02 e1 ff ff       	call   f01000a0 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101f9e:	52                   	push   %edx
f0101f9f:	68 10 52 10 f0       	push   $0xf0105210
f0101fa4:	68 93 03 00 00       	push   $0x393
f0101fa9:	68 13 4f 10 f0       	push   $0xf0104f13
f0101fae:	e8 ed e0 ff ff       	call   f01000a0 <_panic>
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0101fb3:	68 38 55 10 f0       	push   $0xf0105538
f0101fb8:	68 39 4f 10 f0       	push   $0xf0104f39
f0101fbd:	68 94 03 00 00       	push   $0x394
f0101fc2:	68 13 4f 10 f0       	push   $0xf0104f13
f0101fc7:	e8 d4 e0 ff ff       	call   f01000a0 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0101fcc:	68 78 55 10 f0       	push   $0xf0105578
f0101fd1:	68 39 4f 10 f0       	push   $0xf0104f39
f0101fd6:	68 97 03 00 00       	push   $0x397
f0101fdb:	68 13 4f 10 f0       	push   $0xf0104f13
f0101fe0:	e8 bb e0 ff ff       	call   f01000a0 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101fe5:	68 08 55 10 f0       	push   $0xf0105508
f0101fea:	68 39 4f 10 f0       	push   $0xf0104f39
f0101fef:	68 98 03 00 00       	push   $0x398
f0101ff4:	68 13 4f 10 f0       	push   $0xf0104f13
f0101ff9:	e8 a2 e0 ff ff       	call   f01000a0 <_panic>
	assert(pp2->pp_ref == 1);
f0101ffe:	68 1a 51 10 f0       	push   $0xf010511a
f0102003:	68 39 4f 10 f0       	push   $0xf0104f39
f0102008:	68 99 03 00 00       	push   $0x399
f010200d:	68 13 4f 10 f0       	push   $0xf0104f13
f0102012:	e8 89 e0 ff ff       	call   f01000a0 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0102017:	68 b8 55 10 f0       	push   $0xf01055b8
f010201c:	68 39 4f 10 f0       	push   $0xf0104f39
f0102021:	68 9a 03 00 00       	push   $0x39a
f0102026:	68 13 4f 10 f0       	push   $0xf0104f13
f010202b:	e8 70 e0 ff ff       	call   f01000a0 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f0102030:	68 2b 51 10 f0       	push   $0xf010512b
f0102035:	68 39 4f 10 f0       	push   $0xf0104f39
f010203a:	68 9b 03 00 00       	push   $0x39b
f010203f:	68 13 4f 10 f0       	push   $0xf0104f13
f0102044:	e8 57 e0 ff ff       	call   f01000a0 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0102049:	68 cc 54 10 f0       	push   $0xf01054cc
f010204e:	68 39 4f 10 f0       	push   $0xf0104f39
f0102053:	68 9e 03 00 00       	push   $0x39e
f0102058:	68 13 4f 10 f0       	push   $0xf0104f13
f010205d:	e8 3e e0 ff ff       	call   f01000a0 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0102062:	68 ec 55 10 f0       	push   $0xf01055ec
f0102067:	68 39 4f 10 f0       	push   $0xf0104f39
f010206c:	68 9f 03 00 00       	push   $0x39f
f0102071:	68 13 4f 10 f0       	push   $0xf0104f13
f0102076:	e8 25 e0 ff ff       	call   f01000a0 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f010207b:	68 20 56 10 f0       	push   $0xf0105620
f0102080:	68 39 4f 10 f0       	push   $0xf0104f39
f0102085:	68 a0 03 00 00       	push   $0x3a0
f010208a:	68 13 4f 10 f0       	push   $0xf0104f13
f010208f:	e8 0c e0 ff ff       	call   f01000a0 <_panic>
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0102094:	68 58 56 10 f0       	push   $0xf0105658
f0102099:	68 39 4f 10 f0       	push   $0xf0104f39
f010209e:	68 a3 03 00 00       	push   $0x3a3
f01020a3:	68 13 4f 10 f0       	push   $0xf0104f13
f01020a8:	e8 f3 df ff ff       	call   f01000a0 <_panic>
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f01020ad:	68 90 56 10 f0       	push   $0xf0105690
f01020b2:	68 39 4f 10 f0       	push   $0xf0104f39
f01020b7:	68 a6 03 00 00       	push   $0x3a6
f01020bc:	68 13 4f 10 f0       	push   $0xf0104f13
f01020c1:	e8 da df ff ff       	call   f01000a0 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f01020c6:	68 20 56 10 f0       	push   $0xf0105620
f01020cb:	68 39 4f 10 f0       	push   $0xf0104f39
f01020d0:	68 a7 03 00 00       	push   $0x3a7
f01020d5:	68 13 4f 10 f0       	push   $0xf0104f13
f01020da:	e8 c1 df ff ff       	call   f01000a0 <_panic>
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f01020df:	68 cc 56 10 f0       	push   $0xf01056cc
f01020e4:	68 39 4f 10 f0       	push   $0xf0104f39
f01020e9:	68 aa 03 00 00       	push   $0x3aa
f01020ee:	68 13 4f 10 f0       	push   $0xf0104f13
f01020f3:	e8 a8 df ff ff       	call   f01000a0 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f01020f8:	68 f8 56 10 f0       	push   $0xf01056f8
f01020fd:	68 39 4f 10 f0       	push   $0xf0104f39
f0102102:	68 ab 03 00 00       	push   $0x3ab
f0102107:	68 13 4f 10 f0       	push   $0xf0104f13
f010210c:	e8 8f df ff ff       	call   f01000a0 <_panic>
	assert(pp1->pp_ref == 2);
f0102111:	68 41 51 10 f0       	push   $0xf0105141
f0102116:	68 39 4f 10 f0       	push   $0xf0104f39
f010211b:	68 ad 03 00 00       	push   $0x3ad
f0102120:	68 13 4f 10 f0       	push   $0xf0104f13
f0102125:	e8 76 df ff ff       	call   f01000a0 <_panic>
	assert(pp2->pp_ref == 0);
f010212a:	68 52 51 10 f0       	push   $0xf0105152
f010212f:	68 39 4f 10 f0       	push   $0xf0104f39
f0102134:	68 ae 03 00 00       	push   $0x3ae
f0102139:	68 13 4f 10 f0       	push   $0xf0104f13
f010213e:	e8 5d df ff ff       	call   f01000a0 <_panic>
	assert((pp = page_alloc(0)) && pp == pp2);
f0102143:	68 28 57 10 f0       	push   $0xf0105728
f0102148:	68 39 4f 10 f0       	push   $0xf0104f39
f010214d:	68 b1 03 00 00       	push   $0x3b1
f0102152:	68 13 4f 10 f0       	push   $0xf0104f13
f0102157:	e8 44 df ff ff       	call   f01000a0 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f010215c:	68 4c 57 10 f0       	push   $0xf010574c
f0102161:	68 39 4f 10 f0       	push   $0xf0104f39
f0102166:	68 b5 03 00 00       	push   $0x3b5
f010216b:	68 13 4f 10 f0       	push   $0xf0104f13
f0102170:	e8 2b df ff ff       	call   f01000a0 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102175:	68 f8 56 10 f0       	push   $0xf01056f8
f010217a:	68 39 4f 10 f0       	push   $0xf0104f39
f010217f:	68 b6 03 00 00       	push   $0x3b6
f0102184:	68 13 4f 10 f0       	push   $0xf0104f13
f0102189:	e8 12 df ff ff       	call   f01000a0 <_panic>
	assert(pp1->pp_ref == 1);
f010218e:	68 f8 50 10 f0       	push   $0xf01050f8
f0102193:	68 39 4f 10 f0       	push   $0xf0104f39
f0102198:	68 b7 03 00 00       	push   $0x3b7
f010219d:	68 13 4f 10 f0       	push   $0xf0104f13
f01021a2:	e8 f9 de ff ff       	call   f01000a0 <_panic>
	assert(pp2->pp_ref == 0);
f01021a7:	68 52 51 10 f0       	push   $0xf0105152
f01021ac:	68 39 4f 10 f0       	push   $0xf0104f39
f01021b1:	68 b8 03 00 00       	push   $0x3b8
f01021b6:	68 13 4f 10 f0       	push   $0xf0104f13
f01021bb:	e8 e0 de ff ff       	call   f01000a0 <_panic>
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f01021c0:	68 70 57 10 f0       	push   $0xf0105770
f01021c5:	68 39 4f 10 f0       	push   $0xf0104f39
f01021ca:	68 bb 03 00 00       	push   $0x3bb
f01021cf:	68 13 4f 10 f0       	push   $0xf0104f13
f01021d4:	e8 c7 de ff ff       	call   f01000a0 <_panic>
	assert(pp1->pp_ref);
f01021d9:	68 63 51 10 f0       	push   $0xf0105163
f01021de:	68 39 4f 10 f0       	push   $0xf0104f39
f01021e3:	68 bc 03 00 00       	push   $0x3bc
f01021e8:	68 13 4f 10 f0       	push   $0xf0104f13
f01021ed:	e8 ae de ff ff       	call   f01000a0 <_panic>
	assert(pp1->pp_link == NULL);
f01021f2:	68 6f 51 10 f0       	push   $0xf010516f
f01021f7:	68 39 4f 10 f0       	push   $0xf0104f39
f01021fc:	68 bd 03 00 00       	push   $0x3bd
f0102201:	68 13 4f 10 f0       	push   $0xf0104f13
f0102206:	e8 95 de ff ff       	call   f01000a0 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f010220b:	68 4c 57 10 f0       	push   $0xf010574c
f0102210:	68 39 4f 10 f0       	push   $0xf0104f39
f0102215:	68 c1 03 00 00       	push   $0x3c1
f010221a:	68 13 4f 10 f0       	push   $0xf0104f13
f010221f:	e8 7c de ff ff       	call   f01000a0 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0102224:	68 a8 57 10 f0       	push   $0xf01057a8
f0102229:	68 39 4f 10 f0       	push   $0xf0104f39
f010222e:	68 c2 03 00 00       	push   $0x3c2
f0102233:	68 13 4f 10 f0       	push   $0xf0104f13
f0102238:	e8 63 de ff ff       	call   f01000a0 <_panic>
	assert(pp1->pp_ref == 0);
f010223d:	68 84 51 10 f0       	push   $0xf0105184
f0102242:	68 39 4f 10 f0       	push   $0xf0104f39
f0102247:	68 c3 03 00 00       	push   $0x3c3
f010224c:	68 13 4f 10 f0       	push   $0xf0104f13
f0102251:	e8 4a de ff ff       	call   f01000a0 <_panic>
	assert(pp2->pp_ref == 0);
f0102256:	68 52 51 10 f0       	push   $0xf0105152
f010225b:	68 39 4f 10 f0       	push   $0xf0104f39
f0102260:	68 c4 03 00 00       	push   $0x3c4
f0102265:	68 13 4f 10 f0       	push   $0xf0104f13
f010226a:	e8 31 de ff ff       	call   f01000a0 <_panic>
	assert((pp = page_alloc(0)) && pp == pp1);
f010226f:	68 d0 57 10 f0       	push   $0xf01057d0
f0102274:	68 39 4f 10 f0       	push   $0xf0104f39
f0102279:	68 c7 03 00 00       	push   $0x3c7
f010227e:	68 13 4f 10 f0       	push   $0xf0104f13
f0102283:	e8 18 de ff ff       	call   f01000a0 <_panic>
	assert(!page_alloc(0));
f0102288:	68 a6 50 10 f0       	push   $0xf01050a6
f010228d:	68 39 4f 10 f0       	push   $0xf0104f39
f0102292:	68 ca 03 00 00       	push   $0x3ca
f0102297:	68 13 4f 10 f0       	push   $0xf0104f13
f010229c:	e8 ff dd ff ff       	call   f01000a0 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01022a1:	68 74 54 10 f0       	push   $0xf0105474
f01022a6:	68 39 4f 10 f0       	push   $0xf0104f39
f01022ab:	68 cd 03 00 00       	push   $0x3cd
f01022b0:	68 13 4f 10 f0       	push   $0xf0104f13
f01022b5:	e8 e6 dd ff ff       	call   f01000a0 <_panic>
	assert(pp0->pp_ref == 1);
f01022ba:	68 09 51 10 f0       	push   $0xf0105109
f01022bf:	68 39 4f 10 f0       	push   $0xf0104f39
f01022c4:	68 cf 03 00 00       	push   $0x3cf
f01022c9:	68 13 4f 10 f0       	push   $0xf0104f13
f01022ce:	e8 cd dd ff ff       	call   f01000a0 <_panic>
f01022d3:	ff 75 d0             	pushl  -0x30(%ebp)
f01022d6:	68 10 52 10 f0       	push   $0xf0105210
f01022db:	68 d6 03 00 00       	push   $0x3d6
f01022e0:	68 13 4f 10 f0       	push   $0xf0104f13
f01022e5:	e8 b6 dd ff ff       	call   f01000a0 <_panic>
	assert(ptep == ptep1 + PTX(va));
f01022ea:	68 95 51 10 f0       	push   $0xf0105195
f01022ef:	68 39 4f 10 f0       	push   $0xf0104f39
f01022f4:	68 d7 03 00 00       	push   $0x3d7
f01022f9:	68 13 4f 10 f0       	push   $0xf0104f13
f01022fe:	e8 9d dd ff ff       	call   f01000a0 <_panic>
f0102303:	52                   	push   %edx
f0102304:	68 10 52 10 f0       	push   $0xf0105210
f0102309:	6a 56                	push   $0x56
f010230b:	68 1f 4f 10 f0       	push   $0xf0104f1f
f0102310:	e8 8b dd ff ff       	call   f01000a0 <_panic>
f0102315:	52                   	push   %edx
f0102316:	68 10 52 10 f0       	push   $0xf0105210
f010231b:	6a 56                	push   $0x56
f010231d:	68 1f 4f 10 f0       	push   $0xf0104f1f
f0102322:	e8 79 dd ff ff       	call   f01000a0 <_panic>
		assert((ptep[i] & PTE_P) == 0);
f0102327:	68 ad 51 10 f0       	push   $0xf01051ad
f010232c:	68 39 4f 10 f0       	push   $0xf0104f39
f0102331:	68 e1 03 00 00       	push   $0x3e1
f0102336:	68 13 4f 10 f0       	push   $0xf0104f13
f010233b:	e8 60 dd ff ff       	call   f01000a0 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102340:	50                   	push   %eax
f0102341:	68 78 53 10 f0       	push   $0xf0105378
f0102346:	68 c0 00 00 00       	push   $0xc0
f010234b:	68 13 4f 10 f0       	push   $0xf0104f13
f0102350:	e8 4b dd ff ff       	call   f01000a0 <_panic>
f0102355:	50                   	push   %eax
f0102356:	68 78 53 10 f0       	push   $0xf0105378
f010235b:	68 c9 00 00 00       	push   $0xc9
f0102360:	68 13 4f 10 f0       	push   $0xf0104f13
f0102365:	e8 36 dd ff ff       	call   f01000a0 <_panic>
f010236a:	50                   	push   %eax
f010236b:	68 78 53 10 f0       	push   $0xf0105378
f0102370:	68 d6 00 00 00       	push   $0xd6
f0102375:	68 13 4f 10 f0       	push   $0xf0104f13
f010237a:	e8 21 dd ff ff       	call   f01000a0 <_panic>
f010237f:	56                   	push   %esi
f0102380:	68 78 53 10 f0       	push   $0xf0105378
f0102385:	68 1f 03 00 00       	push   $0x31f
f010238a:	68 13 4f 10 f0       	push   $0xf0104f13
f010238f:	e8 0c dd ff ff       	call   f01000a0 <_panic>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102394:	68 f4 57 10 f0       	push   $0xf01057f4
f0102399:	68 39 4f 10 f0       	push   $0xf0104f39
f010239e:	68 1f 03 00 00       	push   $0x31f
f01023a3:	68 13 4f 10 f0       	push   $0xf0104f13
f01023a8:	e8 f3 dc ff ff       	call   f01000a0 <_panic>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f01023ad:	a1 4c 1d 1b f0       	mov    0xf01b1d4c,%eax
f01023b2:	89 45 cc             	mov    %eax,-0x34(%ebp)
	if ((uint32_t)kva < KERNBASE)
f01023b5:	89 45 d0             	mov    %eax,-0x30(%ebp)
f01023b8:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
f01023bd:	8d b0 00 00 40 21    	lea    0x21400000(%eax),%esi
f01023c3:	89 da                	mov    %ebx,%edx
f01023c5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01023c8:	e8 d3 e5 ff ff       	call   f01009a0 <check_va2pa>
f01023cd:	81 7d d0 ff ff ff ef 	cmpl   $0xefffffff,-0x30(%ebp)
f01023d4:	76 3b                	jbe    f0102411 <mem_init+0x13d3>
f01023d6:	8d 14 1e             	lea    (%esi,%ebx,1),%edx
f01023d9:	39 c2                	cmp    %eax,%edx
f01023db:	75 4b                	jne    f0102428 <mem_init+0x13ea>
f01023dd:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	for (i = 0; i < n; i += PGSIZE)
f01023e3:	81 fb 00 80 c1 ee    	cmp    $0xeec18000,%ebx
f01023e9:	75 d8                	jne    f01023c3 <mem_init+0x1385>
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f01023eb:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f01023ee:	c1 e6 0c             	shl    $0xc,%esi
f01023f1:	89 fb                	mov    %edi,%ebx
f01023f3:	39 f3                	cmp    %esi,%ebx
f01023f5:	73 63                	jae    f010245a <mem_init+0x141c>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f01023f7:	8d 93 00 00 00 f0    	lea    -0x10000000(%ebx),%edx
f01023fd:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102400:	e8 9b e5 ff ff       	call   f01009a0 <check_va2pa>
f0102405:	39 c3                	cmp    %eax,%ebx
f0102407:	75 38                	jne    f0102441 <mem_init+0x1403>
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102409:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f010240f:	eb e2                	jmp    f01023f3 <mem_init+0x13b5>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102411:	ff 75 cc             	pushl  -0x34(%ebp)
f0102414:	68 78 53 10 f0       	push   $0xf0105378
f0102419:	68 24 03 00 00       	push   $0x324
f010241e:	68 13 4f 10 f0       	push   $0xf0104f13
f0102423:	e8 78 dc ff ff       	call   f01000a0 <_panic>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f0102428:	68 28 58 10 f0       	push   $0xf0105828
f010242d:	68 39 4f 10 f0       	push   $0xf0104f39
f0102432:	68 24 03 00 00       	push   $0x324
f0102437:	68 13 4f 10 f0       	push   $0xf0104f13
f010243c:	e8 5f dc ff ff       	call   f01000a0 <_panic>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0102441:	68 5c 58 10 f0       	push   $0xf010585c
f0102446:	68 39 4f 10 f0       	push   $0xf0104f39
f010244b:	68 28 03 00 00       	push   $0x328
f0102450:	68 13 4f 10 f0       	push   $0xf0104f13
f0102455:	e8 46 dc ff ff       	call   f01000a0 <_panic>
f010245a:	bb 00 80 ff ef       	mov    $0xefff8000,%ebx
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f010245f:	b8 00 30 11 f0       	mov    $0xf0113000,%eax
f0102464:	8d b0 00 80 00 20    	lea    0x20008000(%eax),%esi
f010246a:	89 da                	mov    %ebx,%edx
f010246c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010246f:	e8 2c e5 ff ff       	call   f01009a0 <check_va2pa>
f0102474:	89 c2                	mov    %eax,%edx
f0102476:	8d 04 1e             	lea    (%esi,%ebx,1),%eax
f0102479:	39 c2                	cmp    %eax,%edx
f010247b:	75 25                	jne    f01024a2 <mem_init+0x1464>
f010247d:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
f0102483:	81 fb 00 00 00 f0    	cmp    $0xf0000000,%ebx
f0102489:	75 df                	jne    f010246a <mem_init+0x142c>
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f010248b:	ba 00 00 c0 ef       	mov    $0xefc00000,%edx
f0102490:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102493:	e8 08 e5 ff ff       	call   f01009a0 <check_va2pa>
f0102498:	83 f8 ff             	cmp    $0xffffffff,%eax
f010249b:	75 1e                	jne    f01024bb <mem_init+0x147d>
f010249d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01024a0:	eb 5d                	jmp    f01024ff <mem_init+0x14c1>
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f01024a2:	68 84 58 10 f0       	push   $0xf0105884
f01024a7:	68 39 4f 10 f0       	push   $0xf0104f39
f01024ac:	68 2c 03 00 00       	push   $0x32c
f01024b1:	68 13 4f 10 f0       	push   $0xf0104f13
f01024b6:	e8 e5 db ff ff       	call   f01000a0 <_panic>
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f01024bb:	68 cc 58 10 f0       	push   $0xf01058cc
f01024c0:	68 39 4f 10 f0       	push   $0xf0104f39
f01024c5:	68 2d 03 00 00       	push   $0x32d
f01024ca:	68 13 4f 10 f0       	push   $0xf0104f13
f01024cf:	e8 cc db ff ff       	call   f01000a0 <_panic>
		switch (i) {
f01024d4:	81 ff bf 03 00 00    	cmp    $0x3bf,%edi
f01024da:	75 23                	jne    f01024ff <mem_init+0x14c1>
			assert(pgdir[i] & PTE_P);
f01024dc:	f6 04 b8 01          	testb  $0x1,(%eax,%edi,4)
f01024e0:	74 44                	je     f0102526 <mem_init+0x14e8>
	for (i = 0; i < NPDENTRIES; i++) {
f01024e2:	47                   	inc    %edi
f01024e3:	81 ff ff 03 00 00    	cmp    $0x3ff,%edi
f01024e9:	0f 87 8f 00 00 00    	ja     f010257e <mem_init+0x1540>
		switch (i) {
f01024ef:	81 ff bd 03 00 00    	cmp    $0x3bd,%edi
f01024f5:	77 dd                	ja     f01024d4 <mem_init+0x1496>
f01024f7:	81 ff ba 03 00 00    	cmp    $0x3ba,%edi
f01024fd:	77 dd                	ja     f01024dc <mem_init+0x149e>
			if (i >= PDX(KERNBASE)) {
f01024ff:	81 ff bf 03 00 00    	cmp    $0x3bf,%edi
f0102505:	77 38                	ja     f010253f <mem_init+0x1501>
				assert(pgdir[i] == 0);
f0102507:	83 3c b8 00          	cmpl   $0x0,(%eax,%edi,4)
f010250b:	74 d5                	je     f01024e2 <mem_init+0x14a4>
f010250d:	68 ff 51 10 f0       	push   $0xf01051ff
f0102512:	68 39 4f 10 f0       	push   $0xf0104f39
f0102517:	68 3d 03 00 00       	push   $0x33d
f010251c:	68 13 4f 10 f0       	push   $0xf0104f13
f0102521:	e8 7a db ff ff       	call   f01000a0 <_panic>
			assert(pgdir[i] & PTE_P);
f0102526:	68 dd 51 10 f0       	push   $0xf01051dd
f010252b:	68 39 4f 10 f0       	push   $0xf0104f39
f0102530:	68 36 03 00 00       	push   $0x336
f0102535:	68 13 4f 10 f0       	push   $0xf0104f13
f010253a:	e8 61 db ff ff       	call   f01000a0 <_panic>
				assert(pgdir[i] & PTE_P);
f010253f:	8b 14 b8             	mov    (%eax,%edi,4),%edx
f0102542:	f6 c2 01             	test   $0x1,%dl
f0102545:	74 1e                	je     f0102565 <mem_init+0x1527>
				assert(pgdir[i] & PTE_W);
f0102547:	f6 c2 02             	test   $0x2,%dl
f010254a:	75 96                	jne    f01024e2 <mem_init+0x14a4>
f010254c:	68 ee 51 10 f0       	push   $0xf01051ee
f0102551:	68 39 4f 10 f0       	push   $0xf0104f39
f0102556:	68 3b 03 00 00       	push   $0x33b
f010255b:	68 13 4f 10 f0       	push   $0xf0104f13
f0102560:	e8 3b db ff ff       	call   f01000a0 <_panic>
				assert(pgdir[i] & PTE_P);
f0102565:	68 dd 51 10 f0       	push   $0xf01051dd
f010256a:	68 39 4f 10 f0       	push   $0xf0104f39
f010256f:	68 3a 03 00 00       	push   $0x33a
f0102574:	68 13 4f 10 f0       	push   $0xf0104f13
f0102579:	e8 22 db ff ff       	call   f01000a0 <_panic>
	cprintf("check_kern_pgdir() succeeded!\n");
f010257e:	83 ec 0c             	sub    $0xc,%esp
f0102581:	68 fc 58 10 f0       	push   $0xf01058fc
f0102586:	e8 91 0b 00 00       	call   f010311c <cprintf>
	lcr3(PADDR(kern_pgdir));
f010258b:	a1 0c 2a 1b f0       	mov    0xf01b2a0c,%eax
	if ((uint32_t)kva < KERNBASE)
f0102590:	83 c4 10             	add    $0x10,%esp
f0102593:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102598:	0f 86 06 02 00 00    	jbe    f01027a4 <mem_init+0x1766>
	return (physaddr_t)kva - KERNBASE;
f010259e:	05 00 00 00 10       	add    $0x10000000,%eax
	asm volatile("movl %0,%%cr3" : : "r" (val));
f01025a3:	0f 22 d8             	mov    %eax,%cr3
	check_page_free_list(0);
f01025a6:	b8 00 00 00 00       	mov    $0x0,%eax
f01025ab:	e8 50 e4 ff ff       	call   f0100a00 <check_page_free_list>
	asm volatile("movl %%cr0,%0" : "=r" (val));
f01025b0:	0f 20 c0             	mov    %cr0,%eax
	cr0 &= ~(CR0_TS|CR0_EM);
f01025b3:	83 e0 f3             	and    $0xfffffff3,%eax
f01025b6:	0d 23 00 05 80       	or     $0x80050023,%eax
	asm volatile("movl %0,%%cr0" : : "r" (val));
f01025bb:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01025be:	83 ec 0c             	sub    $0xc,%esp
f01025c1:	6a 00                	push   $0x0
f01025c3:	e8 a8 e7 ff ff       	call   f0100d70 <page_alloc>
f01025c8:	89 c3                	mov    %eax,%ebx
f01025ca:	83 c4 10             	add    $0x10,%esp
f01025cd:	85 c0                	test   %eax,%eax
f01025cf:	0f 84 e4 01 00 00    	je     f01027b9 <mem_init+0x177b>
	assert((pp1 = page_alloc(0)));
f01025d5:	83 ec 0c             	sub    $0xc,%esp
f01025d8:	6a 00                	push   $0x0
f01025da:	e8 91 e7 ff ff       	call   f0100d70 <page_alloc>
f01025df:	89 c7                	mov    %eax,%edi
f01025e1:	83 c4 10             	add    $0x10,%esp
f01025e4:	85 c0                	test   %eax,%eax
f01025e6:	0f 84 e6 01 00 00    	je     f01027d2 <mem_init+0x1794>
	assert((pp2 = page_alloc(0)));
f01025ec:	83 ec 0c             	sub    $0xc,%esp
f01025ef:	6a 00                	push   $0x0
f01025f1:	e8 7a e7 ff ff       	call   f0100d70 <page_alloc>
f01025f6:	89 c6                	mov    %eax,%esi
f01025f8:	83 c4 10             	add    $0x10,%esp
f01025fb:	85 c0                	test   %eax,%eax
f01025fd:	0f 84 e8 01 00 00    	je     f01027eb <mem_init+0x17ad>
	page_free(pp0);
f0102603:	83 ec 0c             	sub    $0xc,%esp
f0102606:	53                   	push   %ebx
f0102607:	e8 d9 e7 ff ff       	call   f0100de5 <page_free>
	return (pp - pages) << PGSHIFT;
f010260c:	89 f8                	mov    %edi,%eax
f010260e:	2b 05 10 2a 1b f0    	sub    0xf01b2a10,%eax
f0102614:	c1 f8 03             	sar    $0x3,%eax
f0102617:	89 c2                	mov    %eax,%edx
f0102619:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f010261c:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0102621:	83 c4 10             	add    $0x10,%esp
f0102624:	3b 05 08 2a 1b f0    	cmp    0xf01b2a08,%eax
f010262a:	0f 83 d4 01 00 00    	jae    f0102804 <mem_init+0x17c6>
	memset(page2kva(pp1), 1, PGSIZE);
f0102630:	83 ec 04             	sub    $0x4,%esp
f0102633:	68 00 10 00 00       	push   $0x1000
f0102638:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f010263a:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f0102640:	52                   	push   %edx
f0102641:	e8 2e 1f 00 00       	call   f0104574 <memset>
	return (pp - pages) << PGSHIFT;
f0102646:	89 f0                	mov    %esi,%eax
f0102648:	2b 05 10 2a 1b f0    	sub    0xf01b2a10,%eax
f010264e:	c1 f8 03             	sar    $0x3,%eax
f0102651:	89 c2                	mov    %eax,%edx
f0102653:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0102656:	25 ff ff 0f 00       	and    $0xfffff,%eax
f010265b:	83 c4 10             	add    $0x10,%esp
f010265e:	3b 05 08 2a 1b f0    	cmp    0xf01b2a08,%eax
f0102664:	0f 83 ac 01 00 00    	jae    f0102816 <mem_init+0x17d8>
	memset(page2kva(pp2), 2, PGSIZE);
f010266a:	83 ec 04             	sub    $0x4,%esp
f010266d:	68 00 10 00 00       	push   $0x1000
f0102672:	6a 02                	push   $0x2
	return (void *)(pa + KERNBASE);
f0102674:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f010267a:	52                   	push   %edx
f010267b:	e8 f4 1e 00 00       	call   f0104574 <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f0102680:	6a 02                	push   $0x2
f0102682:	68 00 10 00 00       	push   $0x1000
f0102687:	57                   	push   %edi
f0102688:	ff 35 0c 2a 1b f0    	pushl  0xf01b2a0c
f010268e:	e8 2d e9 ff ff       	call   f0100fc0 <page_insert>
	assert(pp1->pp_ref == 1);
f0102693:	83 c4 20             	add    $0x20,%esp
f0102696:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f010269b:	0f 85 87 01 00 00    	jne    f0102828 <mem_init+0x17ea>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f01026a1:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f01026a8:	01 01 01 
f01026ab:	0f 85 90 01 00 00    	jne    f0102841 <mem_init+0x1803>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f01026b1:	6a 02                	push   $0x2
f01026b3:	68 00 10 00 00       	push   $0x1000
f01026b8:	56                   	push   %esi
f01026b9:	ff 35 0c 2a 1b f0    	pushl  0xf01b2a0c
f01026bf:	e8 fc e8 ff ff       	call   f0100fc0 <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f01026c4:	83 c4 10             	add    $0x10,%esp
f01026c7:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f01026ce:	02 02 02 
f01026d1:	0f 85 83 01 00 00    	jne    f010285a <mem_init+0x181c>
	assert(pp2->pp_ref == 1);
f01026d7:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f01026dc:	0f 85 91 01 00 00    	jne    f0102873 <mem_init+0x1835>
	assert(pp1->pp_ref == 0);
f01026e2:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f01026e7:	0f 85 9f 01 00 00    	jne    f010288c <mem_init+0x184e>
	*(uint32_t *)PGSIZE = 0x03030303U;
f01026ed:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f01026f4:	03 03 03 
	return (pp - pages) << PGSHIFT;
f01026f7:	89 f0                	mov    %esi,%eax
f01026f9:	2b 05 10 2a 1b f0    	sub    0xf01b2a10,%eax
f01026ff:	c1 f8 03             	sar    $0x3,%eax
f0102702:	89 c2                	mov    %eax,%edx
f0102704:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0102707:	25 ff ff 0f 00       	and    $0xfffff,%eax
f010270c:	3b 05 08 2a 1b f0    	cmp    0xf01b2a08,%eax
f0102712:	0f 83 8d 01 00 00    	jae    f01028a5 <mem_init+0x1867>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102718:	81 ba 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%edx)
f010271f:	03 03 03 
f0102722:	0f 85 8f 01 00 00    	jne    f01028b7 <mem_init+0x1879>
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102728:	83 ec 08             	sub    $0x8,%esp
f010272b:	68 00 10 00 00       	push   $0x1000
f0102730:	ff 35 0c 2a 1b f0    	pushl  0xf01b2a0c
f0102736:	e8 4a e8 ff ff       	call   f0100f85 <page_remove>
	assert(pp2->pp_ref == 0);
f010273b:	83 c4 10             	add    $0x10,%esp
f010273e:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102743:	0f 85 87 01 00 00    	jne    f01028d0 <mem_init+0x1892>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102749:	8b 0d 0c 2a 1b f0    	mov    0xf01b2a0c,%ecx
f010274f:	8b 11                	mov    (%ecx),%edx
f0102751:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
	return (pp - pages) << PGSHIFT;
f0102757:	89 d8                	mov    %ebx,%eax
f0102759:	2b 05 10 2a 1b f0    	sub    0xf01b2a10,%eax
f010275f:	c1 f8 03             	sar    $0x3,%eax
f0102762:	c1 e0 0c             	shl    $0xc,%eax
f0102765:	39 c2                	cmp    %eax,%edx
f0102767:	0f 85 7c 01 00 00    	jne    f01028e9 <mem_init+0x18ab>
	kern_pgdir[0] = 0;
f010276d:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0102773:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102778:	0f 85 84 01 00 00    	jne    f0102902 <mem_init+0x18c4>
	pp0->pp_ref = 0;
f010277e:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)

	// free the pages we took
	page_free(pp0);
f0102784:	83 ec 0c             	sub    $0xc,%esp
f0102787:	53                   	push   %ebx
f0102788:	e8 58 e6 ff ff       	call   f0100de5 <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f010278d:	c7 04 24 90 59 10 f0 	movl   $0xf0105990,(%esp)
f0102794:	e8 83 09 00 00       	call   f010311c <cprintf>
}
f0102799:	83 c4 10             	add    $0x10,%esp
f010279c:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010279f:	5b                   	pop    %ebx
f01027a0:	5e                   	pop    %esi
f01027a1:	5f                   	pop    %edi
f01027a2:	5d                   	pop    %ebp
f01027a3:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01027a4:	50                   	push   %eax
f01027a5:	68 78 53 10 f0       	push   $0xf0105378
f01027aa:	68 ec 00 00 00       	push   $0xec
f01027af:	68 13 4f 10 f0       	push   $0xf0104f13
f01027b4:	e8 e7 d8 ff ff       	call   f01000a0 <_panic>
	assert((pp0 = page_alloc(0)));
f01027b9:	68 fb 4f 10 f0       	push   $0xf0104ffb
f01027be:	68 39 4f 10 f0       	push   $0xf0104f39
f01027c3:	68 fc 03 00 00       	push   $0x3fc
f01027c8:	68 13 4f 10 f0       	push   $0xf0104f13
f01027cd:	e8 ce d8 ff ff       	call   f01000a0 <_panic>
	assert((pp1 = page_alloc(0)));
f01027d2:	68 11 50 10 f0       	push   $0xf0105011
f01027d7:	68 39 4f 10 f0       	push   $0xf0104f39
f01027dc:	68 fd 03 00 00       	push   $0x3fd
f01027e1:	68 13 4f 10 f0       	push   $0xf0104f13
f01027e6:	e8 b5 d8 ff ff       	call   f01000a0 <_panic>
	assert((pp2 = page_alloc(0)));
f01027eb:	68 27 50 10 f0       	push   $0xf0105027
f01027f0:	68 39 4f 10 f0       	push   $0xf0104f39
f01027f5:	68 fe 03 00 00       	push   $0x3fe
f01027fa:	68 13 4f 10 f0       	push   $0xf0104f13
f01027ff:	e8 9c d8 ff ff       	call   f01000a0 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102804:	52                   	push   %edx
f0102805:	68 10 52 10 f0       	push   $0xf0105210
f010280a:	6a 56                	push   $0x56
f010280c:	68 1f 4f 10 f0       	push   $0xf0104f1f
f0102811:	e8 8a d8 ff ff       	call   f01000a0 <_panic>
f0102816:	52                   	push   %edx
f0102817:	68 10 52 10 f0       	push   $0xf0105210
f010281c:	6a 56                	push   $0x56
f010281e:	68 1f 4f 10 f0       	push   $0xf0104f1f
f0102823:	e8 78 d8 ff ff       	call   f01000a0 <_panic>
	assert(pp1->pp_ref == 1);
f0102828:	68 f8 50 10 f0       	push   $0xf01050f8
f010282d:	68 39 4f 10 f0       	push   $0xf0104f39
f0102832:	68 03 04 00 00       	push   $0x403
f0102837:	68 13 4f 10 f0       	push   $0xf0104f13
f010283c:	e8 5f d8 ff ff       	call   f01000a0 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102841:	68 1c 59 10 f0       	push   $0xf010591c
f0102846:	68 39 4f 10 f0       	push   $0xf0104f39
f010284b:	68 04 04 00 00       	push   $0x404
f0102850:	68 13 4f 10 f0       	push   $0xf0104f13
f0102855:	e8 46 d8 ff ff       	call   f01000a0 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f010285a:	68 40 59 10 f0       	push   $0xf0105940
f010285f:	68 39 4f 10 f0       	push   $0xf0104f39
f0102864:	68 06 04 00 00       	push   $0x406
f0102869:	68 13 4f 10 f0       	push   $0xf0104f13
f010286e:	e8 2d d8 ff ff       	call   f01000a0 <_panic>
	assert(pp2->pp_ref == 1);
f0102873:	68 1a 51 10 f0       	push   $0xf010511a
f0102878:	68 39 4f 10 f0       	push   $0xf0104f39
f010287d:	68 07 04 00 00       	push   $0x407
f0102882:	68 13 4f 10 f0       	push   $0xf0104f13
f0102887:	e8 14 d8 ff ff       	call   f01000a0 <_panic>
	assert(pp1->pp_ref == 0);
f010288c:	68 84 51 10 f0       	push   $0xf0105184
f0102891:	68 39 4f 10 f0       	push   $0xf0104f39
f0102896:	68 08 04 00 00       	push   $0x408
f010289b:	68 13 4f 10 f0       	push   $0xf0104f13
f01028a0:	e8 fb d7 ff ff       	call   f01000a0 <_panic>
f01028a5:	52                   	push   %edx
f01028a6:	68 10 52 10 f0       	push   $0xf0105210
f01028ab:	6a 56                	push   $0x56
f01028ad:	68 1f 4f 10 f0       	push   $0xf0104f1f
f01028b2:	e8 e9 d7 ff ff       	call   f01000a0 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f01028b7:	68 64 59 10 f0       	push   $0xf0105964
f01028bc:	68 39 4f 10 f0       	push   $0xf0104f39
f01028c1:	68 0a 04 00 00       	push   $0x40a
f01028c6:	68 13 4f 10 f0       	push   $0xf0104f13
f01028cb:	e8 d0 d7 ff ff       	call   f01000a0 <_panic>
	assert(pp2->pp_ref == 0);
f01028d0:	68 52 51 10 f0       	push   $0xf0105152
f01028d5:	68 39 4f 10 f0       	push   $0xf0104f39
f01028da:	68 0c 04 00 00       	push   $0x40c
f01028df:	68 13 4f 10 f0       	push   $0xf0104f13
f01028e4:	e8 b7 d7 ff ff       	call   f01000a0 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01028e9:	68 74 54 10 f0       	push   $0xf0105474
f01028ee:	68 39 4f 10 f0       	push   $0xf0104f39
f01028f3:	68 0f 04 00 00       	push   $0x40f
f01028f8:	68 13 4f 10 f0       	push   $0xf0104f13
f01028fd:	e8 9e d7 ff ff       	call   f01000a0 <_panic>
	assert(pp0->pp_ref == 1);
f0102902:	68 09 51 10 f0       	push   $0xf0105109
f0102907:	68 39 4f 10 f0       	push   $0xf0104f39
f010290c:	68 11 04 00 00       	push   $0x411
f0102911:	68 13 4f 10 f0       	push   $0xf0104f13
f0102916:	e8 85 d7 ff ff       	call   f01000a0 <_panic>

f010291b <tlb_invalidate>:
{
f010291b:	55                   	push   %ebp
f010291c:	89 e5                	mov    %esp,%ebp
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f010291e:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102921:	0f 01 38             	invlpg (%eax)
}
f0102924:	5d                   	pop    %ebp
f0102925:	c3                   	ret    

f0102926 <user_mem_check>:
{
f0102926:	55                   	push   %ebp
f0102927:	89 e5                	mov    %esp,%ebp
f0102929:	57                   	push   %edi
f010292a:	56                   	push   %esi
f010292b:	53                   	push   %ebx
f010292c:	83 ec 1c             	sub    $0x1c,%esp
	const char* start_addr = ROUNDDOWN(va, PGSIZE);
f010292f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0102932:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
f0102938:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
	const char* end_addr = ROUNDUP(va + len, PGSIZE);
f010293b:	8b 7d 0c             	mov    0xc(%ebp),%edi
f010293e:	03 7d 10             	add    0x10(%ebp),%edi
f0102941:	8d b7 ff 0f 00 00    	lea    0xfff(%edi),%esi
f0102947:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
	for(const char* addr = start_addr; addr < end_addr; addr += PGSIZE) {
f010294d:	39 f3                	cmp    %esi,%ebx
f010294f:	73 72                	jae    f01029c3 <user_mem_check+0x9d>
		pte_t* pg_entry = pgdir_walk(curenv->env_pgdir, addr, 0);
f0102951:	83 ec 04             	sub    $0x4,%esp
f0102954:	6a 00                	push   $0x0
f0102956:	53                   	push   %ebx
f0102957:	a1 48 1d 1b f0       	mov    0xf01b1d48,%eax
f010295c:	ff 70 5c             	pushl  0x5c(%eax)
f010295f:	e8 e2 e4 ff ff       	call   f0100e46 <pgdir_walk>
		if ((pg_entry != NULL) && (addr <= (const char *)ULIM) && ((*pg_entry & perm) == perm))
f0102964:	83 c4 10             	add    $0x10,%esp
f0102967:	85 c0                	test   %eax,%eax
f0102969:	74 12                	je     f010297d <user_mem_check+0x57>
f010296b:	81 fb 00 00 80 ef    	cmp    $0xef800000,%ebx
f0102971:	77 0a                	ja     f010297d <user_mem_check+0x57>
f0102973:	8b 55 14             	mov    0x14(%ebp),%edx
f0102976:	23 10                	and    (%eax),%edx
f0102978:	39 55 14             	cmp    %edx,0x14(%ebp)
f010297b:	74 22                	je     f010299f <user_mem_check+0x79>
		if(addr == start_addr) {
f010297d:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f0102980:	74 25                	je     f01029a7 <user_mem_check+0x81>
		else if (addr + PGSIZE == end_addr) {
f0102982:	8d 83 00 10 00 00    	lea    0x1000(%ebx),%eax
f0102988:	39 c6                	cmp    %eax,%esi
f010298a:	74 2a                	je     f01029b6 <user_mem_check+0x90>
		user_mem_check_addr = (uintptr_t)addr;
f010298c:	89 1d 3c 1d 1b f0    	mov    %ebx,0xf01b1d3c
		return -E_FAULT;
f0102992:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
}
f0102997:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010299a:	5b                   	pop    %ebx
f010299b:	5e                   	pop    %esi
f010299c:	5f                   	pop    %edi
f010299d:	5d                   	pop    %ebp
f010299e:	c3                   	ret    
	for(const char* addr = start_addr; addr < end_addr; addr += PGSIZE) {
f010299f:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01029a5:	eb a6                	jmp    f010294d <user_mem_check+0x27>
			user_mem_check_addr = (uintptr_t)va;
f01029a7:	8b 45 0c             	mov    0xc(%ebp),%eax
f01029aa:	a3 3c 1d 1b f0       	mov    %eax,0xf01b1d3c
		return -E_FAULT;
f01029af:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f01029b4:	eb e1                	jmp    f0102997 <user_mem_check+0x71>
			user_mem_check_addr = (uintptr_t)(va + len);
f01029b6:	89 3d 3c 1d 1b f0    	mov    %edi,0xf01b1d3c
		return -E_FAULT;
f01029bc:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f01029c1:	eb d4                	jmp    f0102997 <user_mem_check+0x71>
	return 0;
f01029c3:	b8 00 00 00 00       	mov    $0x0,%eax
f01029c8:	eb cd                	jmp    f0102997 <user_mem_check+0x71>

f01029ca <user_mem_assert>:
{
f01029ca:	55                   	push   %ebp
f01029cb:	89 e5                	mov    %esp,%ebp
f01029cd:	53                   	push   %ebx
f01029ce:	83 ec 04             	sub    $0x4,%esp
f01029d1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
f01029d4:	8b 45 14             	mov    0x14(%ebp),%eax
f01029d7:	83 c8 04             	or     $0x4,%eax
f01029da:	50                   	push   %eax
f01029db:	ff 75 10             	pushl  0x10(%ebp)
f01029de:	ff 75 0c             	pushl  0xc(%ebp)
f01029e1:	53                   	push   %ebx
f01029e2:	e8 3f ff ff ff       	call   f0102926 <user_mem_check>
f01029e7:	83 c4 10             	add    $0x10,%esp
f01029ea:	85 c0                	test   %eax,%eax
f01029ec:	78 05                	js     f01029f3 <user_mem_assert+0x29>
}
f01029ee:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01029f1:	c9                   	leave  
f01029f2:	c3                   	ret    
		cprintf("[%08x] user_mem_check assertion failure for "
f01029f3:	83 ec 04             	sub    $0x4,%esp
f01029f6:	ff 35 3c 1d 1b f0    	pushl  0xf01b1d3c
f01029fc:	ff 73 48             	pushl  0x48(%ebx)
f01029ff:	68 bc 59 10 f0       	push   $0xf01059bc
f0102a04:	e8 13 07 00 00       	call   f010311c <cprintf>
		env_destroy(env);	// may not return
f0102a09:	89 1c 24             	mov    %ebx,(%esp)
f0102a0c:	e8 f1 05 00 00       	call   f0103002 <env_destroy>
f0102a11:	83 c4 10             	add    $0x10,%esp
}
f0102a14:	eb d8                	jmp    f01029ee <user_mem_assert+0x24>

f0102a16 <region_alloc>:
// Pages should be writable by user and kernel.
// Panic if any allocation attempt fails.
//
static void
region_alloc(struct Env * e, void *va, size_t len)
{
f0102a16:	55                   	push   %ebp
f0102a17:	89 e5                	mov    %esp,%ebp
f0102a19:	57                   	push   %edi
f0102a1a:	56                   	push   %esi
f0102a1b:	53                   	push   %ebx
f0102a1c:	83 ec 0c             	sub    $0xc,%esp
f0102a1f:	89 c7                	mov    %eax,%edi
	//
	// Hint: It is easier to use region_alloc if the caller can pass
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
	char *start_address = ROUNDDOWN(va, PGSIZE);
f0102a21:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0102a27:	89 d3                	mov    %edx,%ebx
	char *end_address = ROUNDUP(len, PGSIZE) + start_address;
f0102a29:	81 c1 ff 0f 00 00    	add    $0xfff,%ecx
f0102a2f:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f0102a35:	8d 34 0a             	lea    (%edx,%ecx,1),%esi
	char *current_address = start_address;
	struct PageInfo *p;

	while (current_address < end_address)
f0102a38:	39 f3                	cmp    %esi,%ebx
f0102a3a:	73 3f                	jae    f0102a7b <region_alloc+0x65>
	{
		if (!(p = page_alloc(0)))
f0102a3c:	83 ec 0c             	sub    $0xc,%esp
f0102a3f:	6a 00                	push   $0x0
f0102a41:	e8 2a e3 ff ff       	call   f0100d70 <page_alloc>
f0102a46:	83 c4 10             	add    $0x10,%esp
f0102a49:	85 c0                	test   %eax,%eax
f0102a4b:	74 17                	je     f0102a64 <region_alloc+0x4e>
			panic("Region Allocation for env %d failed", e->env_id);
		page_insert(e->env_pgdir, p, current_address, PTE_U | PTE_W);
f0102a4d:	6a 06                	push   $0x6
f0102a4f:	53                   	push   %ebx
f0102a50:	50                   	push   %eax
f0102a51:	ff 77 5c             	pushl  0x5c(%edi)
f0102a54:	e8 67 e5 ff ff       	call   f0100fc0 <page_insert>
		current_address += PGSIZE;
f0102a59:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102a5f:	83 c4 10             	add    $0x10,%esp
f0102a62:	eb d4                	jmp    f0102a38 <region_alloc+0x22>
			panic("Region Allocation for env %d failed", e->env_id);
f0102a64:	ff 77 48             	pushl  0x48(%edi)
f0102a67:	68 f4 59 10 f0       	push   $0xf01059f4
f0102a6c:	68 24 01 00 00       	push   $0x124
f0102a71:	68 4e 5a 10 f0       	push   $0xf0105a4e
f0102a76:	e8 25 d6 ff ff       	call   f01000a0 <_panic>
	}
}
f0102a7b:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102a7e:	5b                   	pop    %ebx
f0102a7f:	5e                   	pop    %esi
f0102a80:	5f                   	pop    %edi
f0102a81:	5d                   	pop    %ebp
f0102a82:	c3                   	ret    

f0102a83 <envid2env>:
{
f0102a83:	55                   	push   %ebp
f0102a84:	89 e5                	mov    %esp,%ebp
f0102a86:	53                   	push   %ebx
f0102a87:	8b 45 08             	mov    0x8(%ebp),%eax
f0102a8a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	if (envid == 0) {
f0102a8d:	85 c0                	test   %eax,%eax
f0102a8f:	74 43                	je     f0102ad4 <envid2env+0x51>
	e = &envs[ENVX(envid)];
f0102a91:	89 c3                	mov    %eax,%ebx
f0102a93:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
f0102a99:	8d 14 1b             	lea    (%ebx,%ebx,1),%edx
f0102a9c:	01 da                	add    %ebx,%edx
f0102a9e:	c1 e2 05             	shl    $0x5,%edx
f0102aa1:	03 15 4c 1d 1b f0    	add    0xf01b1d4c,%edx
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f0102aa7:	83 7a 54 00          	cmpl   $0x0,0x54(%edx)
f0102aab:	74 34                	je     f0102ae1 <envid2env+0x5e>
f0102aad:	39 42 48             	cmp    %eax,0x48(%edx)
f0102ab0:	75 2f                	jne    f0102ae1 <envid2env+0x5e>
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f0102ab2:	84 c9                	test   %cl,%cl
f0102ab4:	74 11                	je     f0102ac7 <envid2env+0x44>
f0102ab6:	a1 48 1d 1b f0       	mov    0xf01b1d48,%eax
f0102abb:	39 d0                	cmp    %edx,%eax
f0102abd:	74 08                	je     f0102ac7 <envid2env+0x44>
f0102abf:	8b 40 48             	mov    0x48(%eax),%eax
f0102ac2:	39 42 4c             	cmp    %eax,0x4c(%edx)
f0102ac5:	75 2a                	jne    f0102af1 <envid2env+0x6e>
	*env_store = e;
f0102ac7:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102aca:	89 10                	mov    %edx,(%eax)
	return 0;
f0102acc:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0102ad1:	5b                   	pop    %ebx
f0102ad2:	5d                   	pop    %ebp
f0102ad3:	c3                   	ret    
		*env_store = curenv;
f0102ad4:	8b 15 48 1d 1b f0    	mov    0xf01b1d48,%edx
f0102ada:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0102add:	89 11                	mov    %edx,(%ecx)
		return 0;
f0102adf:	eb f0                	jmp    f0102ad1 <envid2env+0x4e>
		*env_store = 0;
f0102ae1:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102ae4:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f0102aea:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0102aef:	eb e0                	jmp    f0102ad1 <envid2env+0x4e>
		*env_store = 0;
f0102af1:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102af4:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f0102afa:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0102aff:	eb d0                	jmp    f0102ad1 <envid2env+0x4e>

f0102b01 <env_init_percpu>:
	asm volatile("lgdt (%0)" : : "r" (p));
f0102b01:	b8 00 d3 11 f0       	mov    $0xf011d300,%eax
f0102b06:	0f 01 10             	lgdtl  (%eax)
	asm volatile("movw %%ax,%%gs" : : "a" (GD_UD|3));
f0102b09:	b8 23 00 00 00       	mov    $0x23,%eax
f0102b0e:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" : : "a" (GD_UD|3));
f0102b10:	8e e0                	mov    %eax,%fs
	asm volatile("movw %%ax,%%es" : : "a" (GD_KD));
f0102b12:	b8 10 00 00 00       	mov    $0x10,%eax
f0102b17:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" : : "a" (GD_KD));
f0102b19:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" : : "a" (GD_KD));
f0102b1b:	8e d0                	mov    %eax,%ss
	asm volatile("ljmp %0,$1f\n 1:\n" : : "i"  (GD_KT));
f0102b1d:	ea 24 2b 10 f0 08 00 	ljmp   $0x8,$0xf0102b24
	asm volatile("lldt %0" : : "r" (sel));
f0102b24:	b8 00 00 00 00       	mov    $0x0,%eax
f0102b29:	0f 00 d0             	lldt   %ax
}
f0102b2c:	c3                   	ret    

f0102b2d <env_init>:
{
f0102b2d:	55                   	push   %ebp
f0102b2e:	89 e5                	mov    %esp,%ebp
f0102b30:	56                   	push   %esi
f0102b31:	53                   	push   %ebx
		envs[i].env_id = 0;
f0102b32:	8b 35 4c 1d 1b f0    	mov    0xf01b1d4c,%esi
f0102b38:	8d 86 a0 7f 01 00    	lea    0x17fa0(%esi),%eax
f0102b3e:	89 f3                	mov    %esi,%ebx
f0102b40:	ba 00 00 00 00       	mov    $0x0,%edx
f0102b45:	89 d1                	mov    %edx,%ecx
f0102b47:	89 c2                	mov    %eax,%edx
f0102b49:	c7 40 48 00 00 00 00 	movl   $0x0,0x48(%eax)
		envs[i].env_link = env_free_list;
f0102b50:	89 48 44             	mov    %ecx,0x44(%eax)
f0102b53:	83 e8 60             	sub    $0x60,%eax
	for(int i = NENV - 1; i >= 0; --i) {
f0102b56:	39 da                	cmp    %ebx,%edx
f0102b58:	75 eb                	jne    f0102b45 <env_init+0x18>
f0102b5a:	89 35 50 1d 1b f0    	mov    %esi,0xf01b1d50
	env_init_percpu();
f0102b60:	e8 9c ff ff ff       	call   f0102b01 <env_init_percpu>
}
f0102b65:	5b                   	pop    %ebx
f0102b66:	5e                   	pop    %esi
f0102b67:	5d                   	pop    %ebp
f0102b68:	c3                   	ret    

f0102b69 <env_alloc>:
{
f0102b69:	55                   	push   %ebp
f0102b6a:	89 e5                	mov    %esp,%ebp
f0102b6c:	56                   	push   %esi
f0102b6d:	53                   	push   %ebx
	if (!(e = env_free_list))
f0102b6e:	8b 1d 50 1d 1b f0    	mov    0xf01b1d50,%ebx
f0102b74:	85 db                	test   %ebx,%ebx
f0102b76:	0f 84 73 01 00 00    	je     f0102cef <env_alloc+0x186>
	if (!(p = page_alloc(ALLOC_ZERO)))
f0102b7c:	83 ec 0c             	sub    $0xc,%esp
f0102b7f:	6a 01                	push   $0x1
f0102b81:	e8 ea e1 ff ff       	call   f0100d70 <page_alloc>
f0102b86:	83 c4 10             	add    $0x10,%esp
f0102b89:	85 c0                	test   %eax,%eax
f0102b8b:	0f 84 65 01 00 00    	je     f0102cf6 <env_alloc+0x18d>
	p->pp_ref++;
f0102b91:	66 ff 40 04          	incw   0x4(%eax)
	return (pp - pages) << PGSHIFT;
f0102b95:	2b 05 10 2a 1b f0    	sub    0xf01b2a10,%eax
f0102b9b:	c1 f8 03             	sar    $0x3,%eax
f0102b9e:	89 c2                	mov    %eax,%edx
f0102ba0:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0102ba3:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0102ba8:	3b 05 08 2a 1b f0    	cmp    0xf01b2a08,%eax
f0102bae:	0f 83 03 01 00 00    	jae    f0102cb7 <env_alloc+0x14e>
	return (void *)(pa + KERNBASE);
f0102bb4:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	e->env_pgdir = (pde_t *)page2kva(p);
f0102bba:	89 43 5c             	mov    %eax,0x5c(%ebx)
	memcpy(e->env_pgdir, kern_pgdir, PGSIZE);
f0102bbd:	83 ec 04             	sub    $0x4,%esp
f0102bc0:	68 00 10 00 00       	push   $0x1000
f0102bc5:	ff 35 0c 2a 1b f0    	pushl  0xf01b2a0c
f0102bcb:	50                   	push   %eax
f0102bcc:	e8 4e 1a 00 00       	call   f010461f <memcpy>
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f0102bd1:	8b 43 5c             	mov    0x5c(%ebx),%eax
	if ((uint32_t)kva < KERNBASE)
f0102bd4:	83 c4 10             	add    $0x10,%esp
f0102bd7:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102bdc:	0f 86 e7 00 00 00    	jbe    f0102cc9 <env_alloc+0x160>
	return (physaddr_t)kva - KERNBASE;
f0102be2:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0102be8:	83 ca 05             	or     $0x5,%edx
f0102beb:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f0102bf1:	8b 43 48             	mov    0x48(%ebx),%eax
f0102bf4:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0) // Don't create a negative env_id.
f0102bf9:	25 00 fc ff ff       	and    $0xfffffc00,%eax
f0102bfe:	89 c2                	mov    %eax,%edx
f0102c00:	0f 8e d8 00 00 00    	jle    f0102cde <env_alloc+0x175>
	e->env_id = generation | (e - envs);
f0102c06:	89 d8                	mov    %ebx,%eax
f0102c08:	2b 05 4c 1d 1b f0    	sub    0xf01b1d4c,%eax
f0102c0e:	c1 f8 05             	sar    $0x5,%eax
f0102c11:	89 c1                	mov    %eax,%ecx
f0102c13:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0102c16:	8d 04 81             	lea    (%ecx,%eax,4),%eax
f0102c19:	8d 04 81             	lea    (%ecx,%eax,4),%eax
f0102c1c:	89 c6                	mov    %eax,%esi
f0102c1e:	c1 e6 08             	shl    $0x8,%esi
f0102c21:	01 f0                	add    %esi,%eax
f0102c23:	89 c6                	mov    %eax,%esi
f0102c25:	c1 e6 10             	shl    $0x10,%esi
f0102c28:	01 f0                	add    %esi,%eax
f0102c2a:	01 c0                	add    %eax,%eax
f0102c2c:	01 c8                	add    %ecx,%eax
f0102c2e:	09 d0                	or     %edx,%eax
f0102c30:	89 43 48             	mov    %eax,0x48(%ebx)
	e->env_parent_id = parent_id;
f0102c33:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102c36:	89 43 4c             	mov    %eax,0x4c(%ebx)
	e->env_type = ENV_TYPE_USER;
f0102c39:	c7 43 50 00 00 00 00 	movl   $0x0,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f0102c40:	c7 43 54 02 00 00 00 	movl   $0x2,0x54(%ebx)
	e->env_runs = 0;
f0102c47:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f0102c4e:	83 ec 04             	sub    $0x4,%esp
f0102c51:	6a 44                	push   $0x44
f0102c53:	6a 00                	push   $0x0
f0102c55:	53                   	push   %ebx
f0102c56:	e8 19 19 00 00       	call   f0104574 <memset>
	e->env_tf.tf_ds = GD_UD | 3;
f0102c5b:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f0102c61:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f0102c67:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f0102c6d:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f0102c74:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)
	env_free_list = e->env_link;
f0102c7a:	8b 43 44             	mov    0x44(%ebx),%eax
f0102c7d:	a3 50 1d 1b f0       	mov    %eax,0xf01b1d50
	*newenv_store = e;
f0102c82:	8b 45 08             	mov    0x8(%ebp),%eax
f0102c85:	89 18                	mov    %ebx,(%eax)
	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0102c87:	8b 53 48             	mov    0x48(%ebx),%edx
f0102c8a:	a1 48 1d 1b f0       	mov    0xf01b1d48,%eax
f0102c8f:	83 c4 10             	add    $0x10,%esp
f0102c92:	85 c0                	test   %eax,%eax
f0102c94:	74 52                	je     f0102ce8 <env_alloc+0x17f>
f0102c96:	8b 40 48             	mov    0x48(%eax),%eax
f0102c99:	83 ec 04             	sub    $0x4,%esp
f0102c9c:	52                   	push   %edx
f0102c9d:	50                   	push   %eax
f0102c9e:	68 59 5a 10 f0       	push   $0xf0105a59
f0102ca3:	e8 74 04 00 00       	call   f010311c <cprintf>
	return 0;
f0102ca8:	83 c4 10             	add    $0x10,%esp
f0102cab:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0102cb0:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0102cb3:	5b                   	pop    %ebx
f0102cb4:	5e                   	pop    %esi
f0102cb5:	5d                   	pop    %ebp
f0102cb6:	c3                   	ret    
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102cb7:	52                   	push   %edx
f0102cb8:	68 10 52 10 f0       	push   $0xf0105210
f0102cbd:	6a 56                	push   $0x56
f0102cbf:	68 1f 4f 10 f0       	push   $0xf0104f1f
f0102cc4:	e8 d7 d3 ff ff       	call   f01000a0 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102cc9:	50                   	push   %eax
f0102cca:	68 78 53 10 f0       	push   $0xf0105378
f0102ccf:	68 c7 00 00 00       	push   $0xc7
f0102cd4:	68 4e 5a 10 f0       	push   $0xf0105a4e
f0102cd9:	e8 c2 d3 ff ff       	call   f01000a0 <_panic>
		generation = 1 << ENVGENSHIFT;
f0102cde:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102ce3:	e9 1e ff ff ff       	jmp    f0102c06 <env_alloc+0x9d>
	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0102ce8:	b8 00 00 00 00       	mov    $0x0,%eax
f0102ced:	eb aa                	jmp    f0102c99 <env_alloc+0x130>
		return -E_NO_FREE_ENV;
f0102cef:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f0102cf4:	eb ba                	jmp    f0102cb0 <env_alloc+0x147>
		return -E_NO_MEM;
f0102cf6:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f0102cfb:	eb b3                	jmp    f0102cb0 <env_alloc+0x147>

f0102cfd <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, enum EnvType type)
{
f0102cfd:	55                   	push   %ebp
f0102cfe:	89 e5                	mov    %esp,%ebp
f0102d00:	57                   	push   %edi
f0102d01:	56                   	push   %esi
f0102d02:	53                   	push   %ebx
f0102d03:	83 ec 34             	sub    $0x34,%esp
f0102d06:	8b 7d 08             	mov    0x8(%ebp),%edi
	// LAB 3: Your code here.
	struct Env *env;
	int result;

	// Allocates a new env with env_alloc
	result = env_alloc(&env, 0);
f0102d09:	6a 00                	push   $0x0
f0102d0b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0102d0e:	50                   	push   %eax
f0102d0f:	e8 55 fe ff ff       	call   f0102b69 <env_alloc>
	if (result == -E_NO_FREE_ENV)
f0102d14:	83 c4 10             	add    $0x10,%esp
f0102d17:	83 f8 fb             	cmp    $0xfffffffb,%eax
f0102d1a:	74 42                	je     f0102d5e <env_create+0x61>
		panic("env_alloc: %e", result);

	if (result == -E_NO_MEM)
f0102d1c:	83 f8 fc             	cmp    $0xfffffffc,%eax
f0102d1f:	74 53                	je     f0102d74 <env_create+0x77>
		panic("env_alloc: %e", result);

	env->env_parent_id = 0;
f0102d21:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0102d24:	c7 46 4c 00 00 00 00 	movl   $0x0,0x4c(%esi)
	env->env_type = type;
f0102d2b:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102d2e:	89 46 50             	mov    %eax,0x50(%esi)
	if (ELFHDR->e_magic != ELF_MAGIC)
f0102d31:	81 3f 7f 45 4c 46    	cmpl   $0x464c457f,(%edi)
f0102d37:	75 51                	jne    f0102d8a <env_create+0x8d>
	ph = (struct Proghdr *)((uint8_t *)ELFHDR + ELFHDR->e_phoff);
f0102d39:	89 fb                	mov    %edi,%ebx
f0102d3b:	03 5f 1c             	add    0x1c(%edi),%ebx
	eph = ph + ELFHDR->e_phnum;
f0102d3e:	0f b7 47 2c          	movzwl 0x2c(%edi),%eax
f0102d42:	c1 e0 05             	shl    $0x5,%eax
f0102d45:	01 d8                	add    %ebx,%eax
f0102d47:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	lcr3(PADDR(e->env_pgdir));
f0102d4a:	8b 46 5c             	mov    0x5c(%esi),%eax
	if ((uint32_t)kva < KERNBASE)
f0102d4d:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102d52:	76 4d                	jbe    f0102da1 <env_create+0xa4>
	return (physaddr_t)kva - KERNBASE;
f0102d54:	05 00 00 00 10       	add    $0x10000000,%eax
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0102d59:	0f 22 d8             	mov    %eax,%cr3
}
f0102d5c:	eb 5b                	jmp    f0102db9 <env_create+0xbc>
		panic("env_alloc: %e", result);
f0102d5e:	6a fb                	push   $0xfffffffb
f0102d60:	68 6e 5a 10 f0       	push   $0xf0105a6e
f0102d65:	68 93 01 00 00       	push   $0x193
f0102d6a:	68 4e 5a 10 f0       	push   $0xf0105a4e
f0102d6f:	e8 2c d3 ff ff       	call   f01000a0 <_panic>
		panic("env_alloc: %e", result);
f0102d74:	6a fc                	push   $0xfffffffc
f0102d76:	68 6e 5a 10 f0       	push   $0xf0105a6e
f0102d7b:	68 96 01 00 00       	push   $0x196
f0102d80:	68 4e 5a 10 f0       	push   $0xf0105a4e
f0102d85:	e8 16 d3 ff ff       	call   f01000a0 <_panic>
		panic("It is not a ELF format file!");
f0102d8a:	83 ec 04             	sub    $0x4,%esp
f0102d8d:	68 7c 5a 10 f0       	push   $0xf0105a7c
f0102d92:	68 65 01 00 00       	push   $0x165
f0102d97:	68 4e 5a 10 f0       	push   $0xf0105a4e
f0102d9c:	e8 ff d2 ff ff       	call   f01000a0 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102da1:	50                   	push   %eax
f0102da2:	68 78 53 10 f0       	push   $0xf0105378
f0102da7:	68 6c 01 00 00       	push   $0x16c
f0102dac:	68 4e 5a 10 f0       	push   $0xf0105a4e
f0102db1:	e8 ea d2 ff ff       	call   f01000a0 <_panic>
	for (; ph < eph; ph++)
f0102db6:	83 c3 20             	add    $0x20,%ebx
f0102db9:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f0102dbc:	76 3b                	jbe    f0102df9 <env_create+0xfc>
		if (ph->p_type != ELF_PROG_LOAD)
f0102dbe:	83 3b 01             	cmpl   $0x1,(%ebx)
f0102dc1:	75 f3                	jne    f0102db6 <env_create+0xb9>
		region_alloc(e, (void *)ph->p_va, ph->p_memsz);
f0102dc3:	8b 4b 14             	mov    0x14(%ebx),%ecx
f0102dc6:	8b 53 08             	mov    0x8(%ebx),%edx
f0102dc9:	89 f0                	mov    %esi,%eax
f0102dcb:	e8 46 fc ff ff       	call   f0102a16 <region_alloc>
		memset((void *)ph->p_va, 0, ph->p_memsz);
f0102dd0:	83 ec 04             	sub    $0x4,%esp
f0102dd3:	ff 73 14             	pushl  0x14(%ebx)
f0102dd6:	6a 00                	push   $0x0
f0102dd8:	ff 73 08             	pushl  0x8(%ebx)
f0102ddb:	e8 94 17 00 00       	call   f0104574 <memset>
		memcpy((void *)ph->p_va, binary + ph->p_offset, ph->p_filesz);
f0102de0:	83 c4 0c             	add    $0xc,%esp
f0102de3:	ff 73 10             	pushl  0x10(%ebx)
f0102de6:	89 f8                	mov    %edi,%eax
f0102de8:	03 43 04             	add    0x4(%ebx),%eax
f0102deb:	50                   	push   %eax
f0102dec:	ff 73 08             	pushl  0x8(%ebx)
f0102def:	e8 2b 18 00 00       	call   f010461f <memcpy>
f0102df4:	83 c4 10             	add    $0x10,%esp
f0102df7:	eb bd                	jmp    f0102db6 <env_create+0xb9>
	e->env_tf.tf_eip = ELFHDR->e_entry;
f0102df9:	8b 47 18             	mov    0x18(%edi),%eax
f0102dfc:	89 46 30             	mov    %eax,0x30(%esi)
	lcr3(PADDR(kern_pgdir));
f0102dff:	a1 0c 2a 1b f0       	mov    0xf01b2a0c,%eax
	if ((uint32_t)kva < KERNBASE)
f0102e04:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102e09:	76 21                	jbe    f0102e2c <env_create+0x12f>
	return (physaddr_t)kva - KERNBASE;
f0102e0b:	05 00 00 00 10       	add    $0x10000000,%eax
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0102e10:	0f 22 d8             	mov    %eax,%cr3
	region_alloc(e, (void *)USTACKTOP - PGSIZE, PGSIZE);
f0102e13:	b9 00 10 00 00       	mov    $0x1000,%ecx
f0102e18:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f0102e1d:	89 f0                	mov    %esi,%eax
f0102e1f:	e8 f2 fb ff ff       	call   f0102a16 <region_alloc>

	//Loads the named elf binary into it with load_icode
	load_icode(env, binary);
}
f0102e24:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102e27:	5b                   	pop    %ebx
f0102e28:	5e                   	pop    %esi
f0102e29:	5f                   	pop    %edi
f0102e2a:	5d                   	pop    %ebp
f0102e2b:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102e2c:	50                   	push   %eax
f0102e2d:	68 78 53 10 f0       	push   $0xf0105378
f0102e32:	68 7e 01 00 00       	push   $0x17e
f0102e37:	68 4e 5a 10 f0       	push   $0xf0105a4e
f0102e3c:	e8 5f d2 ff ff       	call   f01000a0 <_panic>

f0102e41 <env_free>:
//
// Frees env e and all memory it uses.
//
void
	env_free(struct Env * e)
{
f0102e41:	55                   	push   %ebp
f0102e42:	89 e5                	mov    %esp,%ebp
f0102e44:	57                   	push   %edi
f0102e45:	56                   	push   %esi
f0102e46:	53                   	push   %ebx
f0102e47:	83 ec 1c             	sub    $0x1c,%esp
f0102e4a:	8b 7d 08             	mov    0x8(%ebp),%edi
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f0102e4d:	8b 15 48 1d 1b f0    	mov    0xf01b1d48,%edx
f0102e53:	39 fa                	cmp    %edi,%edx
f0102e55:	74 28                	je     f0102e7f <env_free+0x3e>
		lcr3(PADDR(kern_pgdir));

	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0102e57:	8b 4f 48             	mov    0x48(%edi),%ecx
f0102e5a:	85 d2                	test   %edx,%edx
f0102e5c:	74 4f                	je     f0102ead <env_free+0x6c>
f0102e5e:	8b 42 48             	mov    0x48(%edx),%eax
f0102e61:	83 ec 04             	sub    $0x4,%esp
f0102e64:	51                   	push   %ecx
f0102e65:	50                   	push   %eax
f0102e66:	68 99 5a 10 f0       	push   $0xf0105a99
f0102e6b:	e8 ac 02 00 00       	call   f010311c <cprintf>
f0102e70:	83 c4 10             	add    $0x10,%esp
f0102e73:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f0102e7a:	e9 b3 00 00 00       	jmp    f0102f32 <env_free+0xf1>
		lcr3(PADDR(kern_pgdir));
f0102e7f:	a1 0c 2a 1b f0       	mov    0xf01b2a0c,%eax
	if ((uint32_t)kva < KERNBASE)
f0102e84:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102e89:	76 0d                	jbe    f0102e98 <env_free+0x57>
	return (physaddr_t)kva - KERNBASE;
f0102e8b:	05 00 00 00 10       	add    $0x10000000,%eax
f0102e90:	0f 22 d8             	mov    %eax,%cr3
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0102e93:	8b 4f 48             	mov    0x48(%edi),%ecx
f0102e96:	eb c6                	jmp    f0102e5e <env_free+0x1d>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102e98:	50                   	push   %eax
f0102e99:	68 78 53 10 f0       	push   $0xf0105378
f0102e9e:	68 ad 01 00 00       	push   $0x1ad
f0102ea3:	68 4e 5a 10 f0       	push   $0xf0105a4e
f0102ea8:	e8 f3 d1 ff ff       	call   f01000a0 <_panic>
f0102ead:	b8 00 00 00 00       	mov    $0x0,%eax
f0102eb2:	eb ad                	jmp    f0102e61 <env_free+0x20>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102eb4:	56                   	push   %esi
f0102eb5:	68 10 52 10 f0       	push   $0xf0105210
f0102eba:	68 bd 01 00 00       	push   $0x1bd
f0102ebf:	68 4e 5a 10 f0       	push   $0xf0105a4e
f0102ec4:	e8 d7 d1 ff ff       	call   f01000a0 <_panic>

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++)
		{
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0102ec9:	83 ec 08             	sub    $0x8,%esp
f0102ecc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0102ecf:	09 d8                	or     %ebx,%eax
f0102ed1:	50                   	push   %eax
f0102ed2:	ff 77 5c             	pushl  0x5c(%edi)
f0102ed5:	e8 ab e0 ff ff       	call   f0100f85 <page_remove>
f0102eda:	83 c4 10             	add    $0x10,%esp
f0102edd:	83 c6 04             	add    $0x4,%esi
f0102ee0:	81 c3 00 10 00 00    	add    $0x1000,%ebx
		for (pteno = 0; pteno <= PTX(~0); pteno++)
f0102ee6:	81 fb 00 00 40 00    	cmp    $0x400000,%ebx
f0102eec:	74 07                	je     f0102ef5 <env_free+0xb4>
			if (pt[pteno] & PTE_P)
f0102eee:	f6 06 01             	testb  $0x1,(%esi)
f0102ef1:	74 ea                	je     f0102edd <env_free+0x9c>
f0102ef3:	eb d4                	jmp    f0102ec9 <env_free+0x88>
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f0102ef5:	8b 47 5c             	mov    0x5c(%edi),%eax
f0102ef8:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0102efb:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
	if (PGNUM(pa) >= npages)
f0102f02:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0102f05:	3b 05 08 2a 1b f0    	cmp    0xf01b2a08,%eax
f0102f0b:	73 65                	jae    f0102f72 <env_free+0x131>
		page_decref(pa2page(pa));
f0102f0d:	83 ec 0c             	sub    $0xc,%esp
	return &pages[PGNUM(pa)];
f0102f10:	a1 10 2a 1b f0       	mov    0xf01b2a10,%eax
f0102f15:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0102f18:	8d 04 d0             	lea    (%eax,%edx,8),%eax
f0102f1b:	50                   	push   %eax
f0102f1c:	e8 ff de ff ff       	call   f0100e20 <page_decref>
f0102f21:	83 c4 10             	add    $0x10,%esp
f0102f24:	83 45 e0 04          	addl   $0x4,-0x20(%ebp)
f0102f28:	8b 45 e0             	mov    -0x20(%ebp),%eax
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++)
f0102f2b:	3d ec 0e 00 00       	cmp    $0xeec,%eax
f0102f30:	74 54                	je     f0102f86 <env_free+0x145>
		if (!(e->env_pgdir[pdeno] & PTE_P))
f0102f32:	8b 47 5c             	mov    0x5c(%edi),%eax
f0102f35:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0102f38:	8b 04 08             	mov    (%eax,%ecx,1),%eax
f0102f3b:	a8 01                	test   $0x1,%al
f0102f3d:	74 e5                	je     f0102f24 <env_free+0xe3>
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f0102f3f:	89 c6                	mov    %eax,%esi
f0102f41:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
	if (PGNUM(pa) >= npages)
f0102f47:	c1 e8 0c             	shr    $0xc,%eax
f0102f4a:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0102f4d:	39 05 08 2a 1b f0    	cmp    %eax,0xf01b2a08
f0102f53:	0f 86 5b ff ff ff    	jbe    f0102eb4 <env_free+0x73>
	return (void *)(pa + KERNBASE);
f0102f59:	81 ee 00 00 00 10    	sub    $0x10000000,%esi
f0102f5f:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0102f62:	c1 e0 14             	shl    $0x14,%eax
f0102f65:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0102f68:	bb 00 00 00 00       	mov    $0x0,%ebx
f0102f6d:	e9 7c ff ff ff       	jmp    f0102eee <env_free+0xad>
		panic("pa2page called with invalid pa");
f0102f72:	83 ec 04             	sub    $0x4,%esp
f0102f75:	68 1c 53 10 f0       	push   $0xf010531c
f0102f7a:	6a 4f                	push   $0x4f
f0102f7c:	68 1f 4f 10 f0       	push   $0xf0104f1f
f0102f81:	e8 1a d1 ff ff       	call   f01000a0 <_panic>
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f0102f86:	8b 47 5c             	mov    0x5c(%edi),%eax
	if ((uint32_t)kva < KERNBASE)
f0102f89:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102f8e:	76 49                	jbe    f0102fd9 <env_free+0x198>
	e->env_pgdir = 0;
f0102f90:	c7 47 5c 00 00 00 00 	movl   $0x0,0x5c(%edi)
	return (physaddr_t)kva - KERNBASE;
f0102f97:	05 00 00 00 10       	add    $0x10000000,%eax
	if (PGNUM(pa) >= npages)
f0102f9c:	c1 e8 0c             	shr    $0xc,%eax
f0102f9f:	3b 05 08 2a 1b f0    	cmp    0xf01b2a08,%eax
f0102fa5:	73 47                	jae    f0102fee <env_free+0x1ad>
	page_decref(pa2page(pa));
f0102fa7:	83 ec 0c             	sub    $0xc,%esp
	return &pages[PGNUM(pa)];
f0102faa:	8b 15 10 2a 1b f0    	mov    0xf01b2a10,%edx
f0102fb0:	8d 04 c2             	lea    (%edx,%eax,8),%eax
f0102fb3:	50                   	push   %eax
f0102fb4:	e8 67 de ff ff       	call   f0100e20 <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f0102fb9:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	e->env_link = env_free_list;
f0102fc0:	a1 50 1d 1b f0       	mov    0xf01b1d50,%eax
f0102fc5:	89 47 44             	mov    %eax,0x44(%edi)
	env_free_list = e;
f0102fc8:	89 3d 50 1d 1b f0    	mov    %edi,0xf01b1d50
}
f0102fce:	83 c4 10             	add    $0x10,%esp
f0102fd1:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102fd4:	5b                   	pop    %ebx
f0102fd5:	5e                   	pop    %esi
f0102fd6:	5f                   	pop    %edi
f0102fd7:	5d                   	pop    %ebp
f0102fd8:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102fd9:	50                   	push   %eax
f0102fda:	68 78 53 10 f0       	push   $0xf0105378
f0102fdf:	68 cc 01 00 00       	push   $0x1cc
f0102fe4:	68 4e 5a 10 f0       	push   $0xf0105a4e
f0102fe9:	e8 b2 d0 ff ff       	call   f01000a0 <_panic>
		panic("pa2page called with invalid pa");
f0102fee:	83 ec 04             	sub    $0x4,%esp
f0102ff1:	68 1c 53 10 f0       	push   $0xf010531c
f0102ff6:	6a 4f                	push   $0x4f
f0102ff8:	68 1f 4f 10 f0       	push   $0xf0104f1f
f0102ffd:	e8 9e d0 ff ff       	call   f01000a0 <_panic>

f0103002 <env_destroy>:
//
// Frees environment e.
//
void
	env_destroy(struct Env * e)
{
f0103002:	55                   	push   %ebp
f0103003:	89 e5                	mov    %esp,%ebp
f0103005:	83 ec 14             	sub    $0x14,%esp
	env_free(e);
f0103008:	ff 75 08             	pushl  0x8(%ebp)
f010300b:	e8 31 fe ff ff       	call   f0102e41 <env_free>

	cprintf("Destroyed the only environment - nothing more to do!\n");
f0103010:	c7 04 24 18 5a 10 f0 	movl   $0xf0105a18,(%esp)
f0103017:	e8 00 01 00 00       	call   f010311c <cprintf>
f010301c:	83 c4 10             	add    $0x10,%esp
	while (1)
		monitor(NULL);
f010301f:	83 ec 0c             	sub    $0xc,%esp
f0103022:	6a 00                	push   $0x0
f0103024:	e8 a5 d7 ff ff       	call   f01007ce <monitor>
f0103029:	83 c4 10             	add    $0x10,%esp
f010302c:	eb f1                	jmp    f010301f <env_destroy+0x1d>

f010302e <env_pop_tf>:
//
// This function does not return.
//
void
	env_pop_tf(struct Trapframe * tf)
{
f010302e:	55                   	push   %ebp
f010302f:	89 e5                	mov    %esp,%ebp
f0103031:	83 ec 0c             	sub    $0xc,%esp
	asm volatile(
f0103034:	8b 65 08             	mov    0x8(%ebp),%esp
f0103037:	61                   	popa   
f0103038:	07                   	pop    %es
f0103039:	1f                   	pop    %ds
f010303a:	83 c4 08             	add    $0x8,%esp
f010303d:	cf                   	iret   
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret\n"
		:
		: "g"(tf)
		: "memory");
	panic("iret failed"); /* mostly to placate the compiler */
f010303e:	68 af 5a 10 f0       	push   $0xf0105aaf
f0103043:	68 f6 01 00 00       	push   $0x1f6
f0103048:	68 4e 5a 10 f0       	push   $0xf0105a4e
f010304d:	e8 4e d0 ff ff       	call   f01000a0 <_panic>

f0103052 <env_run>:
//
// This function does not return.
//
void
	env_run(struct Env * e)
{
f0103052:	55                   	push   %ebp
f0103053:	89 e5                	mov    %esp,%ebp
f0103055:	83 ec 08             	sub    $0x8,%esp
f0103058:	8b 45 08             	mov    0x8(%ebp),%eax
	//	e->env_tf to sensible values.

	// LAB 3: Your code here.
	// Set the current environment(if any) back to ENV_RUNNABLE if it is ENV_RUNNING
	
	if (curenv != NULL && curenv->env_status == ENV_RUNNING)
f010305b:	8b 15 48 1d 1b f0    	mov    0xf01b1d48,%edx
f0103061:	85 d2                	test   %edx,%edx
f0103063:	74 06                	je     f010306b <env_run+0x19>
f0103065:	83 7a 54 03          	cmpl   $0x3,0x54(%edx)
f0103069:	74 2c                	je     f0103097 <env_run+0x45>
		curenv->env_type = ENV_RUNNABLE;

	// Set 'curenv' to the new environment
	curenv = e;
f010306b:	a3 48 1d 1b f0       	mov    %eax,0xf01b1d48

	// Set its status to ENV_RUNNING,
	curenv->env_status = ENV_RUNNING;
f0103070:	c7 40 54 03 00 00 00 	movl   $0x3,0x54(%eax)

	// Update its 'env_runs' counter
	curenv->env_runs++;
f0103077:	ff 40 58             	incl   0x58(%eax)

	// Use lcr3() to switch to its address space
	lcr3(PADDR(curenv->env_pgdir));
f010307a:	8b 50 5c             	mov    0x5c(%eax),%edx
	if ((uint32_t)kva < KERNBASE)
f010307d:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0103083:	76 1b                	jbe    f01030a0 <env_run+0x4e>
	return (physaddr_t)kva - KERNBASE;
f0103085:	81 c2 00 00 00 10    	add    $0x10000000,%edx
f010308b:	0f 22 da             	mov    %edx,%cr3

	// Use env_pop_tf() to restore the environment's
	//	   registers and drop into user mode in the
	//	   environment.

	env_pop_tf(&curenv->env_tf);
f010308e:	83 ec 0c             	sub    $0xc,%esp
f0103091:	50                   	push   %eax
f0103092:	e8 97 ff ff ff       	call   f010302e <env_pop_tf>
		curenv->env_type = ENV_RUNNABLE;
f0103097:	c7 42 50 02 00 00 00 	movl   $0x2,0x50(%edx)
f010309e:	eb cb                	jmp    f010306b <env_run+0x19>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01030a0:	52                   	push   %edx
f01030a1:	68 78 53 10 f0       	push   $0xf0105378
f01030a6:	68 23 02 00 00       	push   $0x223
f01030ab:	68 4e 5a 10 f0       	push   $0xf0105a4e
f01030b0:	e8 eb cf ff ff       	call   f01000a0 <_panic>

f01030b5 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f01030b5:	55                   	push   %ebp
f01030b6:	89 e5                	mov    %esp,%ebp
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01030b8:	8b 45 08             	mov    0x8(%ebp),%eax
f01030bb:	ba 70 00 00 00       	mov    $0x70,%edx
f01030c0:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01030c1:	ba 71 00 00 00       	mov    $0x71,%edx
f01030c6:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f01030c7:	0f b6 c0             	movzbl %al,%eax
}
f01030ca:	5d                   	pop    %ebp
f01030cb:	c3                   	ret    

f01030cc <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f01030cc:	55                   	push   %ebp
f01030cd:	89 e5                	mov    %esp,%ebp
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01030cf:	8b 45 08             	mov    0x8(%ebp),%eax
f01030d2:	ba 70 00 00 00       	mov    $0x70,%edx
f01030d7:	ee                   	out    %al,(%dx)
f01030d8:	8b 45 0c             	mov    0xc(%ebp),%eax
f01030db:	ba 71 00 00 00       	mov    $0x71,%edx
f01030e0:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f01030e1:	5d                   	pop    %ebp
f01030e2:	c3                   	ret    

f01030e3 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f01030e3:	55                   	push   %ebp
f01030e4:	89 e5                	mov    %esp,%ebp
f01030e6:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f01030e9:	ff 75 08             	pushl  0x8(%ebp)
f01030ec:	e8 ea d4 ff ff       	call   f01005db <cputchar>
	*cnt++;
}
f01030f1:	83 c4 10             	add    $0x10,%esp
f01030f4:	c9                   	leave  
f01030f5:	c3                   	ret    

f01030f6 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f01030f6:	55                   	push   %ebp
f01030f7:	89 e5                	mov    %esp,%ebp
f01030f9:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f01030fc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0103103:	ff 75 0c             	pushl  0xc(%ebp)
f0103106:	ff 75 08             	pushl  0x8(%ebp)
f0103109:	8d 45 f4             	lea    -0xc(%ebp),%eax
f010310c:	50                   	push   %eax
f010310d:	68 e3 30 10 f0       	push   $0xf01030e3
f0103112:	e8 94 0d 00 00       	call   f0103eab <vprintfmt>
	return cnt;
}
f0103117:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010311a:	c9                   	leave  
f010311b:	c3                   	ret    

f010311c <cprintf>:

int
cprintf(const char *fmt, ...)
{
f010311c:	55                   	push   %ebp
f010311d:	89 e5                	mov    %esp,%ebp
f010311f:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0103122:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0103125:	50                   	push   %eax
f0103126:	ff 75 08             	pushl  0x8(%ebp)
f0103129:	e8 c8 ff ff ff       	call   f01030f6 <vcprintf>
	va_end(ap);

	return cnt;
}
f010312e:	c9                   	leave  
f010312f:	c3                   	ret    

f0103130 <trap_init_percpu>:
void
trap_init_percpu(void)
{
	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
	ts.ts_esp0 = KSTACKTOP;
f0103130:	b8 80 25 1b f0       	mov    $0xf01b2580,%eax
f0103135:	c7 05 84 25 1b f0 00 	movl   $0xf0000000,0xf01b2584
f010313c:	00 00 f0 
	ts.ts_ss0 = GD_KD;
f010313f:	66 c7 05 88 25 1b f0 	movw   $0x10,0xf01b2588
f0103146:	10 00 
	ts.ts_iomb = sizeof(struct Taskstate);
f0103148:	66 c7 05 e6 25 1b f0 	movw   $0x68,0xf01b25e6
f010314f:	68 00 

	// Initialize the TSS slot of the gdt.
	gdt[GD_TSS0 >> 3] = SEG16(STS_T32A, (uint32_t) (&ts),
f0103151:	66 c7 05 48 d3 11 f0 	movw   $0x67,0xf011d348
f0103158:	67 00 
f010315a:	66 a3 4a d3 11 f0    	mov    %ax,0xf011d34a
f0103160:	89 c2                	mov    %eax,%edx
f0103162:	c1 ea 10             	shr    $0x10,%edx
f0103165:	88 15 4c d3 11 f0    	mov    %dl,0xf011d34c
f010316b:	c6 05 4e d3 11 f0 40 	movb   $0x40,0xf011d34e
f0103172:	c1 e8 18             	shr    $0x18,%eax
f0103175:	a2 4f d3 11 f0       	mov    %al,0xf011d34f
					sizeof(struct Taskstate) - 1, 0);
	gdt[GD_TSS0 >> 3].sd_s = 0;
f010317a:	c6 05 4d d3 11 f0 89 	movb   $0x89,0xf011d34d
	asm volatile("ltr %0" : : "r" (sel));
f0103181:	b8 28 00 00 00       	mov    $0x28,%eax
f0103186:	0f 00 d8             	ltr    %ax
	asm volatile("lidt (%0)" : : "r" (p));
f0103189:	b8 50 d3 11 f0       	mov    $0xf011d350,%eax
f010318e:	0f 01 18             	lidtl  (%eax)
	// bottom three bits are special; we leave them 0)
	ltr(GD_TSS0);

	// Load the IDT
	lidt(&idt_pd);
}
f0103191:	c3                   	ret    

f0103192 <trap_init>:
{
f0103192:	55                   	push   %ebp
f0103193:	89 e5                	mov    %esp,%ebp
f0103195:	83 ec 08             	sub    $0x8,%esp
	SETGATE(idt[T_DIVIDE], 0, GD_KT, t_divide, 0);
f0103198:	b8 b2 38 10 f0       	mov    $0xf01038b2,%eax
f010319d:	66 a3 60 1d 1b f0    	mov    %ax,0xf01b1d60
f01031a3:	66 c7 05 62 1d 1b f0 	movw   $0x8,0xf01b1d62
f01031aa:	08 00 
f01031ac:	c6 05 64 1d 1b f0 00 	movb   $0x0,0xf01b1d64
f01031b3:	c6 05 65 1d 1b f0 8e 	movb   $0x8e,0xf01b1d65
f01031ba:	c1 e8 10             	shr    $0x10,%eax
f01031bd:	66 a3 66 1d 1b f0    	mov    %ax,0xf01b1d66
	SETGATE(idt[T_DEBUG], 0, GD_KT, t_debug, 0);
f01031c3:	b8 b8 38 10 f0       	mov    $0xf01038b8,%eax
f01031c8:	66 a3 68 1d 1b f0    	mov    %ax,0xf01b1d68
f01031ce:	66 c7 05 6a 1d 1b f0 	movw   $0x8,0xf01b1d6a
f01031d5:	08 00 
f01031d7:	c6 05 6c 1d 1b f0 00 	movb   $0x0,0xf01b1d6c
f01031de:	c6 05 6d 1d 1b f0 8e 	movb   $0x8e,0xf01b1d6d
f01031e5:	c1 e8 10             	shr    $0x10,%eax
f01031e8:	66 a3 6e 1d 1b f0    	mov    %ax,0xf01b1d6e
	SETGATE(idt[T_NMI], 0, GD_KT, t_nmi, 0);
f01031ee:	b8 be 38 10 f0       	mov    $0xf01038be,%eax
f01031f3:	66 a3 70 1d 1b f0    	mov    %ax,0xf01b1d70
f01031f9:	66 c7 05 72 1d 1b f0 	movw   $0x8,0xf01b1d72
f0103200:	08 00 
f0103202:	c6 05 74 1d 1b f0 00 	movb   $0x0,0xf01b1d74
f0103209:	c6 05 75 1d 1b f0 8e 	movb   $0x8e,0xf01b1d75
f0103210:	c1 e8 10             	shr    $0x10,%eax
f0103213:	66 a3 76 1d 1b f0    	mov    %ax,0xf01b1d76
	SETGATE(idt[T_BRKPT], 1, GD_KT, t_brkpt, 3);
f0103219:	b8 c4 38 10 f0       	mov    $0xf01038c4,%eax
f010321e:	66 a3 78 1d 1b f0    	mov    %ax,0xf01b1d78
f0103224:	66 c7 05 7a 1d 1b f0 	movw   $0x8,0xf01b1d7a
f010322b:	08 00 
f010322d:	c6 05 7c 1d 1b f0 00 	movb   $0x0,0xf01b1d7c
f0103234:	c6 05 7d 1d 1b f0 ef 	movb   $0xef,0xf01b1d7d
f010323b:	c1 e8 10             	shr    $0x10,%eax
f010323e:	66 a3 7e 1d 1b f0    	mov    %ax,0xf01b1d7e
	SETGATE(idt[T_OFLOW], 1, GD_KT, t_oflow, 0);
f0103244:	b8 ca 38 10 f0       	mov    $0xf01038ca,%eax
f0103249:	66 a3 80 1d 1b f0    	mov    %ax,0xf01b1d80
f010324f:	66 c7 05 82 1d 1b f0 	movw   $0x8,0xf01b1d82
f0103256:	08 00 
f0103258:	c6 05 84 1d 1b f0 00 	movb   $0x0,0xf01b1d84
f010325f:	c6 05 85 1d 1b f0 8f 	movb   $0x8f,0xf01b1d85
f0103266:	c1 e8 10             	shr    $0x10,%eax
f0103269:	66 a3 86 1d 1b f0    	mov    %ax,0xf01b1d86
	SETGATE(idt[T_BOUND], 0, GD_KT, t_bound, 0);
f010326f:	b8 d0 38 10 f0       	mov    $0xf01038d0,%eax
f0103274:	66 a3 88 1d 1b f0    	mov    %ax,0xf01b1d88
f010327a:	66 c7 05 8a 1d 1b f0 	movw   $0x8,0xf01b1d8a
f0103281:	08 00 
f0103283:	c6 05 8c 1d 1b f0 00 	movb   $0x0,0xf01b1d8c
f010328a:	c6 05 8d 1d 1b f0 8e 	movb   $0x8e,0xf01b1d8d
f0103291:	c1 e8 10             	shr    $0x10,%eax
f0103294:	66 a3 8e 1d 1b f0    	mov    %ax,0xf01b1d8e
	SETGATE(idt[T_ILLOP], 0, GD_KT, t_illop, 0);
f010329a:	b8 d6 38 10 f0       	mov    $0xf01038d6,%eax
f010329f:	66 a3 90 1d 1b f0    	mov    %ax,0xf01b1d90
f01032a5:	66 c7 05 92 1d 1b f0 	movw   $0x8,0xf01b1d92
f01032ac:	08 00 
f01032ae:	c6 05 94 1d 1b f0 00 	movb   $0x0,0xf01b1d94
f01032b5:	c6 05 95 1d 1b f0 8e 	movb   $0x8e,0xf01b1d95
f01032bc:	c1 e8 10             	shr    $0x10,%eax
f01032bf:	66 a3 96 1d 1b f0    	mov    %ax,0xf01b1d96
	SETGATE(idt[T_DEVICE], 0, GD_KT, t_device, 0);
f01032c5:	b8 dc 38 10 f0       	mov    $0xf01038dc,%eax
f01032ca:	66 a3 98 1d 1b f0    	mov    %ax,0xf01b1d98
f01032d0:	66 c7 05 9a 1d 1b f0 	movw   $0x8,0xf01b1d9a
f01032d7:	08 00 
f01032d9:	c6 05 9c 1d 1b f0 00 	movb   $0x0,0xf01b1d9c
f01032e0:	c6 05 9d 1d 1b f0 8e 	movb   $0x8e,0xf01b1d9d
f01032e7:	c1 e8 10             	shr    $0x10,%eax
f01032ea:	66 a3 9e 1d 1b f0    	mov    %ax,0xf01b1d9e
	SETGATE(idt[T_DBLFLT], 0, GD_KT, t_dblflt, 0);
f01032f0:	b8 e2 38 10 f0       	mov    $0xf01038e2,%eax
f01032f5:	66 a3 a0 1d 1b f0    	mov    %ax,0xf01b1da0
f01032fb:	66 c7 05 a2 1d 1b f0 	movw   $0x8,0xf01b1da2
f0103302:	08 00 
f0103304:	c6 05 a4 1d 1b f0 00 	movb   $0x0,0xf01b1da4
f010330b:	c6 05 a5 1d 1b f0 8e 	movb   $0x8e,0xf01b1da5
f0103312:	c1 e8 10             	shr    $0x10,%eax
f0103315:	66 a3 a6 1d 1b f0    	mov    %ax,0xf01b1da6
	SETGATE(idt[T_TSS], 0, GD_KT, t_tss, 0);
f010331b:	b8 e6 38 10 f0       	mov    $0xf01038e6,%eax
f0103320:	66 a3 b0 1d 1b f0    	mov    %ax,0xf01b1db0
f0103326:	66 c7 05 b2 1d 1b f0 	movw   $0x8,0xf01b1db2
f010332d:	08 00 
f010332f:	c6 05 b4 1d 1b f0 00 	movb   $0x0,0xf01b1db4
f0103336:	c6 05 b5 1d 1b f0 8e 	movb   $0x8e,0xf01b1db5
f010333d:	c1 e8 10             	shr    $0x10,%eax
f0103340:	66 a3 b6 1d 1b f0    	mov    %ax,0xf01b1db6
	SETGATE(idt[T_SEGNP], 0, GD_KT, t_segnp, 0);
f0103346:	b8 ea 38 10 f0       	mov    $0xf01038ea,%eax
f010334b:	66 a3 b8 1d 1b f0    	mov    %ax,0xf01b1db8
f0103351:	66 c7 05 ba 1d 1b f0 	movw   $0x8,0xf01b1dba
f0103358:	08 00 
f010335a:	c6 05 bc 1d 1b f0 00 	movb   $0x0,0xf01b1dbc
f0103361:	c6 05 bd 1d 1b f0 8e 	movb   $0x8e,0xf01b1dbd
f0103368:	c1 e8 10             	shr    $0x10,%eax
f010336b:	66 a3 be 1d 1b f0    	mov    %ax,0xf01b1dbe
	SETGATE(idt[T_STACK], 0, GD_KT, t_stack, 0);
f0103371:	b8 ee 38 10 f0       	mov    $0xf01038ee,%eax
f0103376:	66 a3 c0 1d 1b f0    	mov    %ax,0xf01b1dc0
f010337c:	66 c7 05 c2 1d 1b f0 	movw   $0x8,0xf01b1dc2
f0103383:	08 00 
f0103385:	c6 05 c4 1d 1b f0 00 	movb   $0x0,0xf01b1dc4
f010338c:	c6 05 c5 1d 1b f0 8e 	movb   $0x8e,0xf01b1dc5
f0103393:	c1 e8 10             	shr    $0x10,%eax
f0103396:	66 a3 c6 1d 1b f0    	mov    %ax,0xf01b1dc6
	SETGATE(idt[T_GPFLT], 0, GD_KT, t_gpflt, 0);
f010339c:	b8 f2 38 10 f0       	mov    $0xf01038f2,%eax
f01033a1:	66 a3 c8 1d 1b f0    	mov    %ax,0xf01b1dc8
f01033a7:	66 c7 05 ca 1d 1b f0 	movw   $0x8,0xf01b1dca
f01033ae:	08 00 
f01033b0:	c6 05 cc 1d 1b f0 00 	movb   $0x0,0xf01b1dcc
f01033b7:	c6 05 cd 1d 1b f0 8e 	movb   $0x8e,0xf01b1dcd
f01033be:	c1 e8 10             	shr    $0x10,%eax
f01033c1:	66 a3 ce 1d 1b f0    	mov    %ax,0xf01b1dce
	SETGATE(idt[T_PGFLT], 0, GD_KT, t_pgflt, 0);
f01033c7:	b8 f6 38 10 f0       	mov    $0xf01038f6,%eax
f01033cc:	66 a3 d0 1d 1b f0    	mov    %ax,0xf01b1dd0
f01033d2:	66 c7 05 d2 1d 1b f0 	movw   $0x8,0xf01b1dd2
f01033d9:	08 00 
f01033db:	c6 05 d4 1d 1b f0 00 	movb   $0x0,0xf01b1dd4
f01033e2:	c6 05 d5 1d 1b f0 8e 	movb   $0x8e,0xf01b1dd5
f01033e9:	c1 e8 10             	shr    $0x10,%eax
f01033ec:	66 a3 d6 1d 1b f0    	mov    %ax,0xf01b1dd6
	SETGATE(idt[T_FPERR], 0, GD_KT, t_fperr, 0);
f01033f2:	b8 fa 38 10 f0       	mov    $0xf01038fa,%eax
f01033f7:	66 a3 e0 1d 1b f0    	mov    %ax,0xf01b1de0
f01033fd:	66 c7 05 e2 1d 1b f0 	movw   $0x8,0xf01b1de2
f0103404:	08 00 
f0103406:	c6 05 e4 1d 1b f0 00 	movb   $0x0,0xf01b1de4
f010340d:	c6 05 e5 1d 1b f0 8e 	movb   $0x8e,0xf01b1de5
f0103414:	c1 e8 10             	shr    $0x10,%eax
f0103417:	66 a3 e6 1d 1b f0    	mov    %ax,0xf01b1de6
	SETGATE(idt[T_ALIGN], 0, GD_KT, t_align, 0);
f010341d:	b8 00 39 10 f0       	mov    $0xf0103900,%eax
f0103422:	66 a3 e8 1d 1b f0    	mov    %ax,0xf01b1de8
f0103428:	66 c7 05 ea 1d 1b f0 	movw   $0x8,0xf01b1dea
f010342f:	08 00 
f0103431:	c6 05 ec 1d 1b f0 00 	movb   $0x0,0xf01b1dec
f0103438:	c6 05 ed 1d 1b f0 8e 	movb   $0x8e,0xf01b1ded
f010343f:	c1 e8 10             	shr    $0x10,%eax
f0103442:	66 a3 ee 1d 1b f0    	mov    %ax,0xf01b1dee
	SETGATE(idt[T_MCHK], 0, GD_KT, t_mchk, 0);
f0103448:	b8 04 39 10 f0       	mov    $0xf0103904,%eax
f010344d:	66 a3 f0 1d 1b f0    	mov    %ax,0xf01b1df0
f0103453:	66 c7 05 f2 1d 1b f0 	movw   $0x8,0xf01b1df2
f010345a:	08 00 
f010345c:	c6 05 f4 1d 1b f0 00 	movb   $0x0,0xf01b1df4
f0103463:	c6 05 f5 1d 1b f0 8e 	movb   $0x8e,0xf01b1df5
f010346a:	c1 e8 10             	shr    $0x10,%eax
f010346d:	66 a3 f6 1d 1b f0    	mov    %ax,0xf01b1df6
	SETGATE(idt[T_SIMDERR], 0, GD_KT, t_simderr, 0);
f0103473:	b8 0a 39 10 f0       	mov    $0xf010390a,%eax
f0103478:	66 a3 f8 1d 1b f0    	mov    %ax,0xf01b1df8
f010347e:	66 c7 05 fa 1d 1b f0 	movw   $0x8,0xf01b1dfa
f0103485:	08 00 
f0103487:	c6 05 fc 1d 1b f0 00 	movb   $0x0,0xf01b1dfc
f010348e:	c6 05 fd 1d 1b f0 8e 	movb   $0x8e,0xf01b1dfd
f0103495:	c1 e8 10             	shr    $0x10,%eax
f0103498:	66 a3 fe 1d 1b f0    	mov    %ax,0xf01b1dfe
	SETGATE(idt[T_SYSCALL], 1, GD_KT, t_syscall, 3);
f010349e:	b8 10 39 10 f0       	mov    $0xf0103910,%eax
f01034a3:	66 a3 e0 1e 1b f0    	mov    %ax,0xf01b1ee0
f01034a9:	66 c7 05 e2 1e 1b f0 	movw   $0x8,0xf01b1ee2
f01034b0:	08 00 
f01034b2:	c6 05 e4 1e 1b f0 00 	movb   $0x0,0xf01b1ee4
f01034b9:	c6 05 e5 1e 1b f0 ef 	movb   $0xef,0xf01b1ee5
f01034c0:	c1 e8 10             	shr    $0x10,%eax
f01034c3:	66 a3 e6 1e 1b f0    	mov    %ax,0xf01b1ee6
	trap_init_percpu();
f01034c9:	e8 62 fc ff ff       	call   f0103130 <trap_init_percpu>
}
f01034ce:	c9                   	leave  
f01034cf:	c3                   	ret    

f01034d0 <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f01034d0:	55                   	push   %ebp
f01034d1:	89 e5                	mov    %esp,%ebp
f01034d3:	53                   	push   %ebx
f01034d4:	83 ec 0c             	sub    $0xc,%esp
f01034d7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f01034da:	ff 33                	pushl  (%ebx)
f01034dc:	68 bb 5a 10 f0       	push   $0xf0105abb
f01034e1:	e8 36 fc ff ff       	call   f010311c <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f01034e6:	83 c4 08             	add    $0x8,%esp
f01034e9:	ff 73 04             	pushl  0x4(%ebx)
f01034ec:	68 ca 5a 10 f0       	push   $0xf0105aca
f01034f1:	e8 26 fc ff ff       	call   f010311c <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f01034f6:	83 c4 08             	add    $0x8,%esp
f01034f9:	ff 73 08             	pushl  0x8(%ebx)
f01034fc:	68 d9 5a 10 f0       	push   $0xf0105ad9
f0103501:	e8 16 fc ff ff       	call   f010311c <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f0103506:	83 c4 08             	add    $0x8,%esp
f0103509:	ff 73 0c             	pushl  0xc(%ebx)
f010350c:	68 e8 5a 10 f0       	push   $0xf0105ae8
f0103511:	e8 06 fc ff ff       	call   f010311c <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f0103516:	83 c4 08             	add    $0x8,%esp
f0103519:	ff 73 10             	pushl  0x10(%ebx)
f010351c:	68 f7 5a 10 f0       	push   $0xf0105af7
f0103521:	e8 f6 fb ff ff       	call   f010311c <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f0103526:	83 c4 08             	add    $0x8,%esp
f0103529:	ff 73 14             	pushl  0x14(%ebx)
f010352c:	68 06 5b 10 f0       	push   $0xf0105b06
f0103531:	e8 e6 fb ff ff       	call   f010311c <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f0103536:	83 c4 08             	add    $0x8,%esp
f0103539:	ff 73 18             	pushl  0x18(%ebx)
f010353c:	68 15 5b 10 f0       	push   $0xf0105b15
f0103541:	e8 d6 fb ff ff       	call   f010311c <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f0103546:	83 c4 08             	add    $0x8,%esp
f0103549:	ff 73 1c             	pushl  0x1c(%ebx)
f010354c:	68 24 5b 10 f0       	push   $0xf0105b24
f0103551:	e8 c6 fb ff ff       	call   f010311c <cprintf>
}
f0103556:	83 c4 10             	add    $0x10,%esp
f0103559:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010355c:	c9                   	leave  
f010355d:	c3                   	ret    

f010355e <print_trapframe>:
{
f010355e:	55                   	push   %ebp
f010355f:	89 e5                	mov    %esp,%ebp
f0103561:	53                   	push   %ebx
f0103562:	83 ec 0c             	sub    $0xc,%esp
f0103565:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p\n", tf);
f0103568:	53                   	push   %ebx
f0103569:	68 6d 5c 10 f0       	push   $0xf0105c6d
f010356e:	e8 a9 fb ff ff       	call   f010311c <cprintf>
	print_regs(&tf->tf_regs);
f0103573:	89 1c 24             	mov    %ebx,(%esp)
f0103576:	e8 55 ff ff ff       	call   f01034d0 <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f010357b:	83 c4 08             	add    $0x8,%esp
f010357e:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f0103582:	50                   	push   %eax
f0103583:	68 75 5b 10 f0       	push   $0xf0105b75
f0103588:	e8 8f fb ff ff       	call   f010311c <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f010358d:	83 c4 08             	add    $0x8,%esp
f0103590:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f0103594:	50                   	push   %eax
f0103595:	68 88 5b 10 f0       	push   $0xf0105b88
f010359a:	e8 7d fb ff ff       	call   f010311c <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f010359f:	8b 43 28             	mov    0x28(%ebx),%eax
	if (trapno < ARRAY_SIZE(excnames))
f01035a2:	83 c4 10             	add    $0x10,%esp
f01035a5:	83 f8 13             	cmp    $0x13,%eax
f01035a8:	0f 86 c3 00 00 00    	jbe    f0103671 <print_trapframe+0x113>
	if (trapno == T_SYSCALL)
f01035ae:	83 f8 30             	cmp    $0x30,%eax
f01035b1:	0f 84 c6 00 00 00    	je     f010367d <print_trapframe+0x11f>
	return "(unknown trap)";
f01035b7:	ba 33 5b 10 f0       	mov    $0xf0105b33,%edx
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f01035bc:	83 ec 04             	sub    $0x4,%esp
f01035bf:	52                   	push   %edx
f01035c0:	50                   	push   %eax
f01035c1:	68 9b 5b 10 f0       	push   $0xf0105b9b
f01035c6:	e8 51 fb ff ff       	call   f010311c <cprintf>
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f01035cb:	83 c4 10             	add    $0x10,%esp
f01035ce:	39 1d 60 25 1b f0    	cmp    %ebx,0xf01b2560
f01035d4:	0f 84 ad 00 00 00    	je     f0103687 <print_trapframe+0x129>
	cprintf("  err  0x%08x", tf->tf_err);
f01035da:	83 ec 08             	sub    $0x8,%esp
f01035dd:	ff 73 2c             	pushl  0x2c(%ebx)
f01035e0:	68 bc 5b 10 f0       	push   $0xf0105bbc
f01035e5:	e8 32 fb ff ff       	call   f010311c <cprintf>
	if (tf->tf_trapno == T_PGFLT)
f01035ea:	83 c4 10             	add    $0x10,%esp
f01035ed:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f01035f1:	0f 85 d1 00 00 00    	jne    f01036c8 <print_trapframe+0x16a>
			tf->tf_err & 1 ? "protection" : "not-present");
f01035f7:	8b 43 2c             	mov    0x2c(%ebx),%eax
		cprintf(" [%s, %s, %s]\n",
f01035fa:	a8 01                	test   $0x1,%al
f01035fc:	0f 85 a8 00 00 00    	jne    f01036aa <print_trapframe+0x14c>
f0103602:	b9 59 5b 10 f0       	mov    $0xf0105b59,%ecx
f0103607:	a8 02                	test   $0x2,%al
f0103609:	0f 85 a5 00 00 00    	jne    f01036b4 <print_trapframe+0x156>
f010360f:	ba 6b 5b 10 f0       	mov    $0xf0105b6b,%edx
f0103614:	a8 04                	test   $0x4,%al
f0103616:	0f 85 a2 00 00 00    	jne    f01036be <print_trapframe+0x160>
f010361c:	b8 98 5c 10 f0       	mov    $0xf0105c98,%eax
f0103621:	51                   	push   %ecx
f0103622:	52                   	push   %edx
f0103623:	50                   	push   %eax
f0103624:	68 ca 5b 10 f0       	push   $0xf0105bca
f0103629:	e8 ee fa ff ff       	call   f010311c <cprintf>
f010362e:	83 c4 10             	add    $0x10,%esp
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f0103631:	83 ec 08             	sub    $0x8,%esp
f0103634:	ff 73 30             	pushl  0x30(%ebx)
f0103637:	68 d9 5b 10 f0       	push   $0xf0105bd9
f010363c:	e8 db fa ff ff       	call   f010311c <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f0103641:	83 c4 08             	add    $0x8,%esp
f0103644:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f0103648:	50                   	push   %eax
f0103649:	68 e8 5b 10 f0       	push   $0xf0105be8
f010364e:	e8 c9 fa ff ff       	call   f010311c <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f0103653:	83 c4 08             	add    $0x8,%esp
f0103656:	ff 73 38             	pushl  0x38(%ebx)
f0103659:	68 fb 5b 10 f0       	push   $0xf0105bfb
f010365e:	e8 b9 fa ff ff       	call   f010311c <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f0103663:	83 c4 10             	add    $0x10,%esp
f0103666:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f010366a:	75 71                	jne    f01036dd <print_trapframe+0x17f>
}
f010366c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010366f:	c9                   	leave  
f0103670:	c3                   	ret    
		return excnames[trapno];
f0103671:	8b 14 85 40 5e 10 f0 	mov    -0xfefa1c0(,%eax,4),%edx
f0103678:	e9 3f ff ff ff       	jmp    f01035bc <print_trapframe+0x5e>
		return "System call";
f010367d:	ba 42 5b 10 f0       	mov    $0xf0105b42,%edx
f0103682:	e9 35 ff ff ff       	jmp    f01035bc <print_trapframe+0x5e>
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f0103687:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f010368b:	0f 85 49 ff ff ff    	jne    f01035da <print_trapframe+0x7c>
	asm volatile("movl %%cr2,%0" : "=r" (val));
f0103691:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f0103694:	83 ec 08             	sub    $0x8,%esp
f0103697:	50                   	push   %eax
f0103698:	68 ad 5b 10 f0       	push   $0xf0105bad
f010369d:	e8 7a fa ff ff       	call   f010311c <cprintf>
f01036a2:	83 c4 10             	add    $0x10,%esp
f01036a5:	e9 30 ff ff ff       	jmp    f01035da <print_trapframe+0x7c>
		cprintf(" [%s, %s, %s]\n",
f01036aa:	b9 4e 5b 10 f0       	mov    $0xf0105b4e,%ecx
f01036af:	e9 53 ff ff ff       	jmp    f0103607 <print_trapframe+0xa9>
f01036b4:	ba 65 5b 10 f0       	mov    $0xf0105b65,%edx
f01036b9:	e9 56 ff ff ff       	jmp    f0103614 <print_trapframe+0xb6>
f01036be:	b8 70 5b 10 f0       	mov    $0xf0105b70,%eax
f01036c3:	e9 59 ff ff ff       	jmp    f0103621 <print_trapframe+0xc3>
		cprintf("\n");
f01036c8:	83 ec 0c             	sub    $0xc,%esp
f01036cb:	68 db 51 10 f0       	push   $0xf01051db
f01036d0:	e8 47 fa ff ff       	call   f010311c <cprintf>
f01036d5:	83 c4 10             	add    $0x10,%esp
f01036d8:	e9 54 ff ff ff       	jmp    f0103631 <print_trapframe+0xd3>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f01036dd:	83 ec 08             	sub    $0x8,%esp
f01036e0:	ff 73 3c             	pushl  0x3c(%ebx)
f01036e3:	68 0a 5c 10 f0       	push   $0xf0105c0a
f01036e8:	e8 2f fa ff ff       	call   f010311c <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f01036ed:	83 c4 08             	add    $0x8,%esp
f01036f0:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f01036f4:	50                   	push   %eax
f01036f5:	68 19 5c 10 f0       	push   $0xf0105c19
f01036fa:	e8 1d fa ff ff       	call   f010311c <cprintf>
f01036ff:	83 c4 10             	add    $0x10,%esp
}
f0103702:	e9 65 ff ff ff       	jmp    f010366c <print_trapframe+0x10e>

f0103707 <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f0103707:	55                   	push   %ebp
f0103708:	89 e5                	mov    %esp,%ebp
f010370a:	53                   	push   %ebx
f010370b:	83 ec 04             	sub    $0x4,%esp
f010370e:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0103711:	0f 20 d0             	mov    %cr2,%eax
	fault_va = rcr2();

	// Handle kernel-mode page faults.

	// LAB 3: Your code here.
	if (tf->tf_cs == GD_KT) {
f0103714:	66 83 7b 34 08       	cmpw   $0x8,0x34(%ebx)
f0103719:	74 34                	je     f010374f <page_fault_handler+0x48>

	// We've already handled kernel-mode exceptions, so if we get here,
	// the page fault happened in user mode.

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f010371b:	ff 73 30             	pushl  0x30(%ebx)
f010371e:	50                   	push   %eax
f010371f:	a1 48 1d 1b f0       	mov    0xf01b1d48,%eax
f0103724:	ff 70 48             	pushl  0x48(%eax)
f0103727:	68 e4 5d 10 f0       	push   $0xf0105de4
f010372c:	e8 eb f9 ff ff       	call   f010311c <cprintf>
		curenv->env_id, fault_va, tf->tf_eip);
	print_trapframe(tf);
f0103731:	89 1c 24             	mov    %ebx,(%esp)
f0103734:	e8 25 fe ff ff       	call   f010355e <print_trapframe>
	env_destroy(curenv);
f0103739:	83 c4 04             	add    $0x4,%esp
f010373c:	ff 35 48 1d 1b f0    	pushl  0xf01b1d48
f0103742:	e8 bb f8 ff ff       	call   f0103002 <env_destroy>
}
f0103747:	83 c4 10             	add    $0x10,%esp
f010374a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010374d:	c9                   	leave  
f010374e:	c3                   	ret    
		panic("Kernel Page Fault!");
f010374f:	83 ec 04             	sub    $0x4,%esp
f0103752:	68 2c 5c 10 f0       	push   $0xf0105c2c
f0103757:	68 13 01 00 00       	push   $0x113
f010375c:	68 3f 5c 10 f0       	push   $0xf0105c3f
f0103761:	e8 3a c9 ff ff       	call   f01000a0 <_panic>

f0103766 <trap>:
{
f0103766:	55                   	push   %ebp
f0103767:	89 e5                	mov    %esp,%ebp
f0103769:	57                   	push   %edi
f010376a:	56                   	push   %esi
f010376b:	8b 75 08             	mov    0x8(%ebp),%esi
	asm volatile("cld" ::: "cc");
f010376e:	fc                   	cld    
	asm volatile("pushfl; popl %0" : "=r" (eflags));
f010376f:	9c                   	pushf  
f0103770:	58                   	pop    %eax
	assert(!(read_eflags() & FL_IF));
f0103771:	f6 c4 02             	test   $0x2,%ah
f0103774:	74 19                	je     f010378f <trap+0x29>
f0103776:	68 4b 5c 10 f0       	push   $0xf0105c4b
f010377b:	68 39 4f 10 f0       	push   $0xf0104f39
f0103780:	68 ea 00 00 00       	push   $0xea
f0103785:	68 3f 5c 10 f0       	push   $0xf0105c3f
f010378a:	e8 11 c9 ff ff       	call   f01000a0 <_panic>
	cprintf("Incoming TRAP frame at %p\n", tf);
f010378f:	83 ec 08             	sub    $0x8,%esp
f0103792:	56                   	push   %esi
f0103793:	68 64 5c 10 f0       	push   $0xf0105c64
f0103798:	e8 7f f9 ff ff       	call   f010311c <cprintf>
	if ((tf->tf_cs & 3) == 3) {
f010379d:	66 8b 46 34          	mov    0x34(%esi),%ax
f01037a1:	83 e0 03             	and    $0x3,%eax
f01037a4:	83 c4 10             	add    $0x10,%esp
f01037a7:	66 83 f8 03          	cmp    $0x3,%ax
f01037ab:	75 18                	jne    f01037c5 <trap+0x5f>
		assert(curenv);
f01037ad:	a1 48 1d 1b f0       	mov    0xf01b1d48,%eax
f01037b2:	85 c0                	test   %eax,%eax
f01037b4:	74 5a                	je     f0103810 <trap+0xaa>
		curenv->env_tf = *tf;
f01037b6:	b9 11 00 00 00       	mov    $0x11,%ecx
f01037bb:	89 c7                	mov    %eax,%edi
f01037bd:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		tf = &curenv->env_tf;
f01037bf:	8b 35 48 1d 1b f0    	mov    0xf01b1d48,%esi
	last_tf = tf;
f01037c5:	89 35 60 25 1b f0    	mov    %esi,0xf01b2560
	print_trapframe(tf);
f01037cb:	83 ec 0c             	sub    $0xc,%esp
f01037ce:	56                   	push   %esi
f01037cf:	e8 8a fd ff ff       	call   f010355e <print_trapframe>
	if (tf->tf_trapno == T_PGFLT) {
f01037d4:	8b 46 28             	mov    0x28(%esi),%eax
f01037d7:	83 c4 10             	add    $0x10,%esp
f01037da:	83 f8 0e             	cmp    $0xe,%eax
f01037dd:	74 4a                	je     f0103829 <trap+0xc3>
	if(tf->tf_trapno == T_BRKPT) {
f01037df:	83 f8 03             	cmp    $0x3,%eax
f01037e2:	74 53                	je     f0103837 <trap+0xd1>
	if(tf->tf_trapno == T_SYSCALL) {
f01037e4:	83 f8 30             	cmp    $0x30,%eax
f01037e7:	75 5c                	jne    f0103845 <trap+0xdf>
		struct PushRegs regs = tf->tf_regs;
f01037e9:	8b 46 1c             	mov    0x1c(%esi),%eax
		if (regs.reg_eax >= NSYSCALLS)
f01037ec:	83 f8 03             	cmp    $0x3,%eax
f01037ef:	77 78                	ja     f0103869 <trap+0x103>
		result = syscall(regs.reg_eax, regs.reg_edx, regs.reg_ecx,
f01037f1:	83 ec 08             	sub    $0x8,%esp
f01037f4:	ff 76 04             	pushl  0x4(%esi)
f01037f7:	ff 36                	pushl  (%esi)
f01037f9:	ff 76 10             	pushl  0x10(%esi)
f01037fc:	ff 76 18             	pushl  0x18(%esi)
f01037ff:	ff 76 14             	pushl  0x14(%esi)
f0103802:	50                   	push   %eax
f0103803:	e8 1f 01 00 00       	call   f0103927 <syscall>
		(tf->tf_regs).reg_eax = result;
f0103808:	89 46 1c             	mov    %eax,0x1c(%esi)
		return;
f010380b:	83 c4 20             	add    $0x20,%esp
f010380e:	eb 59                	jmp    f0103869 <trap+0x103>
		assert(curenv);
f0103810:	68 7f 5c 10 f0       	push   $0xf0105c7f
f0103815:	68 39 4f 10 f0       	push   $0xf0104f39
f010381a:	68 f0 00 00 00       	push   $0xf0
f010381f:	68 3f 5c 10 f0       	push   $0xf0105c3f
f0103824:	e8 77 c8 ff ff       	call   f01000a0 <_panic>
		page_fault_handler(tf);
f0103829:	83 ec 0c             	sub    $0xc,%esp
f010382c:	56                   	push   %esi
f010382d:	e8 d5 fe ff ff       	call   f0103707 <page_fault_handler>
		return;
f0103832:	83 c4 10             	add    $0x10,%esp
f0103835:	eb 32                	jmp    f0103869 <trap+0x103>
		monitor(tf);
f0103837:	83 ec 0c             	sub    $0xc,%esp
f010383a:	56                   	push   %esi
f010383b:	e8 8e cf ff ff       	call   f01007ce <monitor>
		return;
f0103840:	83 c4 10             	add    $0x10,%esp
f0103843:	eb 24                	jmp    f0103869 <trap+0x103>
	print_trapframe(tf);
f0103845:	83 ec 0c             	sub    $0xc,%esp
f0103848:	56                   	push   %esi
f0103849:	e8 10 fd ff ff       	call   f010355e <print_trapframe>
	if (tf->tf_cs == GD_KT)
f010384e:	83 c4 10             	add    $0x10,%esp
f0103851:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f0103856:	74 39                	je     f0103891 <trap+0x12b>
		env_destroy(curenv);
f0103858:	83 ec 0c             	sub    $0xc,%esp
f010385b:	ff 35 48 1d 1b f0    	pushl  0xf01b1d48
f0103861:	e8 9c f7 ff ff       	call   f0103002 <env_destroy>
		return;
f0103866:	83 c4 10             	add    $0x10,%esp
	assert(curenv && curenv->env_status == ENV_RUNNING);
f0103869:	a1 48 1d 1b f0       	mov    0xf01b1d48,%eax
f010386e:	85 c0                	test   %eax,%eax
f0103870:	74 06                	je     f0103878 <trap+0x112>
f0103872:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0103876:	74 30                	je     f01038a8 <trap+0x142>
f0103878:	68 08 5e 10 f0       	push   $0xf0105e08
f010387d:	68 39 4f 10 f0       	push   $0xf0104f39
f0103882:	68 02 01 00 00       	push   $0x102
f0103887:	68 3f 5c 10 f0       	push   $0xf0105c3f
f010388c:	e8 0f c8 ff ff       	call   f01000a0 <_panic>
		panic("unhandled trap in kernel");
f0103891:	83 ec 04             	sub    $0x4,%esp
f0103894:	68 86 5c 10 f0       	push   $0xf0105c86
f0103899:	68 d9 00 00 00       	push   $0xd9
f010389e:	68 3f 5c 10 f0       	push   $0xf0105c3f
f01038a3:	e8 f8 c7 ff ff       	call   f01000a0 <_panic>
	env_run(curenv);
f01038a8:	83 ec 0c             	sub    $0xc,%esp
f01038ab:	50                   	push   %eax
f01038ac:	e8 a1 f7 ff ff       	call   f0103052 <env_run>
f01038b1:	90                   	nop

f01038b2 <t_divide>:
.text

/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */
TRAPHANDLER_NOEC(t_divide, T_DIVIDE);	// 0  divide error
f01038b2:	6a 00                	push   $0x0
f01038b4:	6a 00                	push   $0x0
f01038b6:	eb 5e                	jmp    f0103916 <_alltraps>

f01038b8 <t_debug>:
TRAPHANDLER_NOEC(t_debug,  T_DEBUG);	// 1  debug exception
f01038b8:	6a 00                	push   $0x0
f01038ba:	6a 01                	push   $0x1
f01038bc:	eb 58                	jmp    f0103916 <_alltraps>

f01038be <t_nmi>:
TRAPHANDLER_NOEC(t_nmi, T_NMI);			// 2  non-maskable interrupt
f01038be:	6a 00                	push   $0x0
f01038c0:	6a 02                	push   $0x2
f01038c2:	eb 52                	jmp    f0103916 <_alltraps>

f01038c4 <t_brkpt>:
TRAPHANDLER_NOEC(t_brkpt, T_BRKPT);		// 3  breakpoint
f01038c4:	6a 00                	push   $0x0
f01038c6:	6a 03                	push   $0x3
f01038c8:	eb 4c                	jmp    f0103916 <_alltraps>

f01038ca <t_oflow>:
TRAPHANDLER_NOEC(t_oflow, T_OFLOW);		// 4  overflow
f01038ca:	6a 00                	push   $0x0
f01038cc:	6a 04                	push   $0x4
f01038ce:	eb 46                	jmp    f0103916 <_alltraps>

f01038d0 <t_bound>:
TRAPHANDLER_NOEC(t_bound, T_BOUND);		// 5  bounds check	
f01038d0:	6a 00                	push   $0x0
f01038d2:	6a 05                	push   $0x5
f01038d4:	eb 40                	jmp    f0103916 <_alltraps>

f01038d6 <t_illop>:
TRAPHANDLER_NOEC(t_illop, T_ILLOP);		// 6  illegal opcode
f01038d6:	6a 00                	push   $0x0
f01038d8:	6a 06                	push   $0x6
f01038da:	eb 3a                	jmp    f0103916 <_alltraps>

f01038dc <t_device>:
TRAPHANDLER_NOEC(t_device, T_DEVICE);	// 7  device not available
f01038dc:	6a 00                	push   $0x0
f01038de:	6a 07                	push   $0x7
f01038e0:	eb 34                	jmp    f0103916 <_alltraps>

f01038e2 <t_dblflt>:

TRAPHANDLER(t_dblflt, T_DBLFLT);		// 8  double fault
f01038e2:	6a 08                	push   $0x8
f01038e4:	eb 30                	jmp    f0103916 <_alltraps>

f01038e6 <t_tss>:
TRAPHANDLER(t_tss, T_TSS);				// 10 invalid task switch segment
f01038e6:	6a 0a                	push   $0xa
f01038e8:	eb 2c                	jmp    f0103916 <_alltraps>

f01038ea <t_segnp>:
TRAPHANDLER(t_segnp, T_SEGNP);			// 11 segment not present
f01038ea:	6a 0b                	push   $0xb
f01038ec:	eb 28                	jmp    f0103916 <_alltraps>

f01038ee <t_stack>:
TRAPHANDLER(t_stack, T_STACK);			// 12 stack exception
f01038ee:	6a 0c                	push   $0xc
f01038f0:	eb 24                	jmp    f0103916 <_alltraps>

f01038f2 <t_gpflt>:
TRAPHANDLER(t_gpflt, T_GPFLT);			// 13 general protection fault
f01038f2:	6a 0d                	push   $0xd
f01038f4:	eb 20                	jmp    f0103916 <_alltraps>

f01038f6 <t_pgflt>:
TRAPHANDLER(t_pgflt, T_PGFLT);			// 14 page fault
f01038f6:	6a 0e                	push   $0xe
f01038f8:	eb 1c                	jmp    f0103916 <_alltraps>

f01038fa <t_fperr>:

TRAPHANDLER_NOEC(t_fperr, T_FPERR);		// 16 floating point error
f01038fa:	6a 00                	push   $0x0
f01038fc:	6a 10                	push   $0x10
f01038fe:	eb 16                	jmp    f0103916 <_alltraps>

f0103900 <t_align>:

TRAPHANDLER(t_align, T_ALIGN);			// 17 aligment check
f0103900:	6a 11                	push   $0x11
f0103902:	eb 12                	jmp    f0103916 <_alltraps>

f0103904 <t_mchk>:

TRAPHANDLER_NOEC(t_mchk, T_MCHK);		// 18 machine check
f0103904:	6a 00                	push   $0x0
f0103906:	6a 12                	push   $0x12
f0103908:	eb 0c                	jmp    f0103916 <_alltraps>

f010390a <t_simderr>:
TRAPHANDLER_NOEC(t_simderr, T_SIMDERR);	// 19 SIMD floating point error
f010390a:	6a 00                	push   $0x0
f010390c:	6a 13                	push   $0x13
f010390e:	eb 06                	jmp    f0103916 <_alltraps>

f0103910 <t_syscall>:
TRAPHANDLER_NOEC(t_syscall, T_SYSCALL);	// 48 SIMD floating point error
f0103910:	6a 00                	push   $0x0
f0103912:	6a 30                	push   $0x30
f0103914:	eb 00                	jmp    f0103916 <_alltraps>

f0103916 <_alltraps>:

 
/* Lab 3: Your code here for _alltraps */
_alltraps:
	// 1. push values to make the stack look like a struct Trapframe
    pushl %ds
f0103916:	1e                   	push   %ds
    pushl %es
f0103917:	06                   	push   %es
    pushal
f0103918:	60                   	pusha  

	// 2. load GD_KD into %ds and %es
    movw $GD_KD, %ax
f0103919:	66 b8 10 00          	mov    $0x10,%ax
    movw %ax, %ds
f010391d:	8e d8                	mov    %eax,%ds
    movw %ax, %es
f010391f:	8e c0                	mov    %eax,%es

	// 3. pushl %esp to pass a pointer to the Trapframe as an argument to trap()
	pushl %esp
f0103921:	54                   	push   %esp

	// 4. call trap
f0103922:	e8 3f fe ff ff       	call   f0103766 <trap>

f0103927 <syscall>:
}

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f0103927:	55                   	push   %ebp
f0103928:	89 e5                	mov    %esp,%ebp
f010392a:	83 ec 18             	sub    $0x18,%esp
f010392d:	8b 45 08             	mov    0x8(%ebp),%eax
	// Call the function corresponding to the 'syscallno' parameter.
	// Return any appropriate return value.
	// LAB 3: Your code here.

	// panic("syscall not implemented");
	switch (syscallno) {
f0103930:	83 f8 02             	cmp    $0x2,%eax
f0103933:	0f 84 9b 00 00 00    	je     f01039d4 <syscall+0xad>
f0103939:	83 f8 02             	cmp    $0x2,%eax
f010393c:	77 0b                	ja     f0103949 <syscall+0x22>
f010393e:	85 c0                	test   %eax,%eax
f0103940:	74 62                	je     f01039a4 <syscall+0x7d>
	return cons_getc();
f0103942:	e8 54 cb ff ff       	call   f010049b <cons_getc>
			// Check whether parameters are valid
			user_mem_assert(curenv, (void *)a1, (size_t)a2, PTE_P);
			sys_cputs((const char*)a1, (size_t)a2);
			return 0;
		case SYS_cgetc:
			return sys_cgetc();
f0103947:	eb 59                	jmp    f01039a2 <syscall+0x7b>
	switch (syscallno) {
f0103949:	83 f8 03             	cmp    $0x3,%eax
f010394c:	75 4f                	jne    f010399d <syscall+0x76>
	if ((r = envid2env(envid, &e, 1)) < 0)
f010394e:	83 ec 04             	sub    $0x4,%esp
f0103951:	6a 01                	push   $0x1
f0103953:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0103956:	50                   	push   %eax
f0103957:	ff 75 0c             	pushl  0xc(%ebp)
f010395a:	e8 24 f1 ff ff       	call   f0102a83 <envid2env>
f010395f:	83 c4 10             	add    $0x10,%esp
f0103962:	85 c0                	test   %eax,%eax
f0103964:	78 30                	js     f0103996 <syscall+0x6f>
	if (e == curenv)
f0103966:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0103969:	a1 48 1d 1b f0       	mov    0xf01b1d48,%eax
f010396e:	39 c2                	cmp    %eax,%edx
f0103970:	74 6c                	je     f01039de <syscall+0xb7>
		cprintf("[%08x] destroying %08x\n", curenv->env_id, e->env_id);
f0103972:	83 ec 04             	sub    $0x4,%esp
f0103975:	ff 72 48             	pushl  0x48(%edx)
f0103978:	ff 70 48             	pushl  0x48(%eax)
f010397b:	68 b0 5e 10 f0       	push   $0xf0105eb0
f0103980:	e8 97 f7 ff ff       	call   f010311c <cprintf>
f0103985:	83 c4 10             	add    $0x10,%esp
	env_destroy(e);
f0103988:	83 ec 0c             	sub    $0xc,%esp
f010398b:	ff 75 f4             	pushl  -0xc(%ebp)
f010398e:	e8 6f f6 ff ff       	call   f0103002 <env_destroy>
	return 0;
f0103993:	83 c4 10             	add    $0x10,%esp
			return sys_getenvid();
		case SYS_env_destroy:
			// Check whether parameters are valid
			// user_mem_assert(curenv, (void *)a1, (size_t)PGSIZE, PTE_U);
			sys_env_destroy((envid_t)a1);
			return 0;
f0103996:	b8 00 00 00 00       	mov    $0x0,%eax
f010399b:	eb 05                	jmp    f01039a2 <syscall+0x7b>
	switch (syscallno) {
f010399d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		default:
			return -E_INVAL;
	}
}
f01039a2:	c9                   	leave  
f01039a3:	c3                   	ret    
			user_mem_assert(curenv, (void *)a1, (size_t)a2, PTE_P);
f01039a4:	6a 01                	push   $0x1
f01039a6:	ff 75 10             	pushl  0x10(%ebp)
f01039a9:	ff 75 0c             	pushl  0xc(%ebp)
f01039ac:	ff 35 48 1d 1b f0    	pushl  0xf01b1d48
f01039b2:	e8 13 f0 ff ff       	call   f01029ca <user_mem_assert>
	cprintf("%.*s", len, s);
f01039b7:	83 c4 0c             	add    $0xc,%esp
f01039ba:	ff 75 0c             	pushl  0xc(%ebp)
f01039bd:	ff 75 10             	pushl  0x10(%ebp)
f01039c0:	68 90 5e 10 f0       	push   $0xf0105e90
f01039c5:	e8 52 f7 ff ff       	call   f010311c <cprintf>
}
f01039ca:	83 c4 10             	add    $0x10,%esp
			return 0;
f01039cd:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01039d2:	eb ce                	jmp    f01039a2 <syscall+0x7b>
	return curenv->env_id;
f01039d4:	a1 48 1d 1b f0       	mov    0xf01b1d48,%eax
f01039d9:	8b 40 48             	mov    0x48(%eax),%eax
			return sys_getenvid();
f01039dc:	eb c4                	jmp    f01039a2 <syscall+0x7b>
		cprintf("[%08x] exiting gracefully\n", curenv->env_id);
f01039de:	83 ec 08             	sub    $0x8,%esp
f01039e1:	ff 70 48             	pushl  0x48(%eax)
f01039e4:	68 95 5e 10 f0       	push   $0xf0105e95
f01039e9:	e8 2e f7 ff ff       	call   f010311c <cprintf>
f01039ee:	83 c4 10             	add    $0x10,%esp
f01039f1:	eb 95                	jmp    f0103988 <syscall+0x61>

f01039f3 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f01039f3:	55                   	push   %ebp
f01039f4:	89 e5                	mov    %esp,%ebp
f01039f6:	57                   	push   %edi
f01039f7:	56                   	push   %esi
f01039f8:	53                   	push   %ebx
f01039f9:	83 ec 14             	sub    $0x14,%esp
f01039fc:	89 45 f0             	mov    %eax,-0x10(%ebp)
f01039ff:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0103a02:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0103a05:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f0103a08:	8b 1a                	mov    (%edx),%ebx
f0103a0a:	8b 39                	mov    (%ecx),%edi
f0103a0c:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f0103a13:	eb 27                	jmp    f0103a3c <stab_binsearch+0x49>

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0103a15:	8b 5d ec             	mov    -0x14(%ebp),%ebx
f0103a18:	43                   	inc    %ebx
			continue;
f0103a19:	eb 21                	jmp    f0103a3c <stab_binsearch+0x49>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0103a1b:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0103a1e:	01 c2                	add    %eax,%edx
f0103a20:	8b 4d f0             	mov    -0x10(%ebp),%ecx
f0103a23:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0103a27:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0103a2a:	73 44                	jae    f0103a70 <stab_binsearch+0x7d>
			*region_left = m;
f0103a2c:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0103a2f:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f0103a31:	8b 5d ec             	mov    -0x14(%ebp),%ebx
f0103a34:	43                   	inc    %ebx
		any_matches = 1;
f0103a35:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
	while (l <= r) {
f0103a3c:	39 fb                	cmp    %edi,%ebx
f0103a3e:	7f 59                	jg     f0103a99 <stab_binsearch+0xa6>
		int true_m = (l + r) / 2, m = true_m;
f0103a40:	8d 14 3b             	lea    (%ebx,%edi,1),%edx
f0103a43:	89 d0                	mov    %edx,%eax
f0103a45:	c1 e8 1f             	shr    $0x1f,%eax
f0103a48:	01 d0                	add    %edx,%eax
f0103a4a:	89 c1                	mov    %eax,%ecx
f0103a4c:	d1 f9                	sar    %ecx
f0103a4e:	89 4d ec             	mov    %ecx,-0x14(%ebp)
f0103a51:	83 e0 fe             	and    $0xfffffffe,%eax
f0103a54:	01 c8                	add    %ecx,%eax
f0103a56:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0103a59:	8d 14 82             	lea    (%edx,%eax,4),%edx
f0103a5c:	89 c8                	mov    %ecx,%eax
		while (m >= l && stabs[m].n_type != type)
f0103a5e:	39 c3                	cmp    %eax,%ebx
f0103a60:	7f b3                	jg     f0103a15 <stab_binsearch+0x22>
f0103a62:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0103a66:	83 ea 0c             	sub    $0xc,%edx
f0103a69:	39 f1                	cmp    %esi,%ecx
f0103a6b:	74 ae                	je     f0103a1b <stab_binsearch+0x28>
			m--;
f0103a6d:	48                   	dec    %eax
f0103a6e:	eb ee                	jmp    f0103a5e <stab_binsearch+0x6b>
		} else if (stabs[m].n_value > addr) {
f0103a70:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0103a73:	76 11                	jbe    f0103a86 <stab_binsearch+0x93>
			*region_right = m - 1;
f0103a75:	8d 78 ff             	lea    -0x1(%eax),%edi
f0103a78:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103a7b:	89 38                	mov    %edi,(%eax)
		any_matches = 1;
f0103a7d:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0103a84:	eb b6                	jmp    f0103a3c <stab_binsearch+0x49>
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0103a86:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0103a89:	89 03                	mov    %eax,(%ebx)
			l = m;
			addr++;
f0103a8b:	ff 45 0c             	incl   0xc(%ebp)
f0103a8e:	89 c3                	mov    %eax,%ebx
		any_matches = 1;
f0103a90:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0103a97:	eb a3                	jmp    f0103a3c <stab_binsearch+0x49>
		}
	}

	if (!any_matches)
f0103a99:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0103a9d:	75 13                	jne    f0103ab2 <stab_binsearch+0xbf>
		*region_right = *region_left - 1;
f0103a9f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103aa2:	8b 00                	mov    (%eax),%eax
f0103aa4:	48                   	dec    %eax
f0103aa5:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0103aa8:	89 07                	mov    %eax,(%edi)
		     l > *region_left && stabs[l].n_type != type;
		     l--)
			/* do nothing */;
		*region_left = l;
	}
}
f0103aaa:	83 c4 14             	add    $0x14,%esp
f0103aad:	5b                   	pop    %ebx
f0103aae:	5e                   	pop    %esi
f0103aaf:	5f                   	pop    %edi
f0103ab0:	5d                   	pop    %ebp
f0103ab1:	c3                   	ret    
		for (l = *region_right;
f0103ab2:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103ab5:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0103ab7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0103aba:	8b 0f                	mov    (%edi),%ecx
f0103abc:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0103abf:	01 c2                	add    %eax,%edx
f0103ac1:	8b 7d f0             	mov    -0x10(%ebp),%edi
f0103ac4:	8d 14 97             	lea    (%edi,%edx,4),%edx
		for (l = *region_right;
f0103ac7:	eb 01                	jmp    f0103aca <stab_binsearch+0xd7>
		     l--)
f0103ac9:	48                   	dec    %eax
		for (l = *region_right;
f0103aca:	39 c1                	cmp    %eax,%ecx
f0103acc:	7d 0b                	jge    f0103ad9 <stab_binsearch+0xe6>
		     l > *region_left && stabs[l].n_type != type;
f0103ace:	0f b6 5a 04          	movzbl 0x4(%edx),%ebx
f0103ad2:	83 ea 0c             	sub    $0xc,%edx
f0103ad5:	39 f3                	cmp    %esi,%ebx
f0103ad7:	75 f0                	jne    f0103ac9 <stab_binsearch+0xd6>
		*region_left = l;
f0103ad9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0103adc:	89 07                	mov    %eax,(%edi)
}
f0103ade:	eb ca                	jmp    f0103aaa <stab_binsearch+0xb7>

f0103ae0 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0103ae0:	55                   	push   %ebp
f0103ae1:	89 e5                	mov    %esp,%ebp
f0103ae3:	57                   	push   %edi
f0103ae4:	56                   	push   %esi
f0103ae5:	53                   	push   %ebx
f0103ae6:	83 ec 3c             	sub    $0x3c,%esp
f0103ae9:	8b 7d 0c             	mov    0xc(%ebp),%edi
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0103aec:	c7 07 c8 5e 10 f0    	movl   $0xf0105ec8,(%edi)
	info->eip_line = 0;
f0103af2:	c7 47 04 00 00 00 00 	movl   $0x0,0x4(%edi)
	info->eip_fn_name = "<unknown>";
f0103af9:	c7 47 08 c8 5e 10 f0 	movl   $0xf0105ec8,0x8(%edi)
	info->eip_fn_namelen = 9;
f0103b00:	c7 47 0c 09 00 00 00 	movl   $0x9,0xc(%edi)
	info->eip_fn_addr = addr;
f0103b07:	8b 45 08             	mov    0x8(%ebp),%eax
f0103b0a:	89 47 10             	mov    %eax,0x10(%edi)
	info->eip_fn_narg = 0;
f0103b0d:	c7 47 14 00 00 00 00 	movl   $0x0,0x14(%edi)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0103b14:	3d ff ff 7f ef       	cmp    $0xef7fffff,%eax
f0103b19:	0f 86 49 01 00 00    	jbe    f0103c68 <debuginfo_eip+0x188>
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
f0103b1f:	c7 45 bc 48 22 11 f0 	movl   $0xf0112248,-0x44(%ebp)
		stabstr = __STABSTR_BEGIN__;
f0103b26:	c7 45 b8 05 f7 10 f0 	movl   $0xf010f705,-0x48(%ebp)
		stab_end = __STAB_END__;
f0103b2d:	bb 04 f7 10 f0       	mov    $0xf010f704,%ebx
		stabs = __STAB_BEGIN__;
f0103b32:	c7 45 c0 e0 60 10 f0 	movl   $0xf01060e0,-0x40(%ebp)
			user_mem_check(curenv, (void *)st, sizeof(struct Stab), PTE_U);
		}
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0103b39:	8b 75 bc             	mov    -0x44(%ebp),%esi
f0103b3c:	39 75 b8             	cmp    %esi,-0x48(%ebp)
f0103b3f:	0f 83 5f 02 00 00    	jae    f0103da4 <debuginfo_eip+0x2c4>
f0103b45:	80 7e ff 00          	cmpb   $0x0,-0x1(%esi)
f0103b49:	0f 85 5c 02 00 00    	jne    f0103dab <debuginfo_eip+0x2cb>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0103b4f:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0103b56:	8b 75 c0             	mov    -0x40(%ebp),%esi
f0103b59:	29 f3                	sub    %esi,%ebx
f0103b5b:	89 d8                	mov    %ebx,%eax
f0103b5d:	c1 f8 02             	sar    $0x2,%eax
f0103b60:	83 e3 fc             	and    $0xfffffffc,%ebx
f0103b63:	01 c3                	add    %eax,%ebx
f0103b65:	8d 14 98             	lea    (%eax,%ebx,4),%edx
f0103b68:	8d 14 90             	lea    (%eax,%edx,4),%edx
f0103b6b:	89 d1                	mov    %edx,%ecx
f0103b6d:	c1 e1 08             	shl    $0x8,%ecx
f0103b70:	01 ca                	add    %ecx,%edx
f0103b72:	89 d1                	mov    %edx,%ecx
f0103b74:	c1 e1 10             	shl    $0x10,%ecx
f0103b77:	01 ca                	add    %ecx,%edx
f0103b79:	01 d2                	add    %edx,%edx
f0103b7b:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
f0103b7f:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0103b82:	83 ec 08             	sub    $0x8,%esp
f0103b85:	ff 75 08             	pushl  0x8(%ebp)
f0103b88:	6a 64                	push   $0x64
f0103b8a:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0103b8d:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0103b90:	89 f0                	mov    %esi,%eax
f0103b92:	e8 5c fe ff ff       	call   f01039f3 <stab_binsearch>
	if (lfile == 0)
f0103b97:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103b9a:	83 c4 10             	add    $0x10,%esp
f0103b9d:	85 c0                	test   %eax,%eax
f0103b9f:	0f 84 0d 02 00 00    	je     f0103db2 <debuginfo_eip+0x2d2>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0103ba5:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0103ba8:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103bab:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0103bae:	83 ec 08             	sub    $0x8,%esp
f0103bb1:	ff 75 08             	pushl  0x8(%ebp)
f0103bb4:	6a 24                	push   $0x24
f0103bb6:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0103bb9:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0103bbc:	89 f0                	mov    %esi,%eax
f0103bbe:	e8 30 fe ff ff       	call   f01039f3 <stab_binsearch>

	if (lfun <= rfun) {
f0103bc3:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0103bc6:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0103bc9:	83 c4 10             	add    $0x10,%esp
f0103bcc:	39 d0                	cmp    %edx,%eax
f0103bce:	0f 8f 27 01 00 00    	jg     f0103cfb <debuginfo_eip+0x21b>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0103bd4:	8d 0c 00             	lea    (%eax,%eax,1),%ecx
f0103bd7:	01 c1                	add    %eax,%ecx
f0103bd9:	8d 1c 8e             	lea    (%esi,%ecx,4),%ebx
f0103bdc:	8b 0b                	mov    (%ebx),%ecx
f0103bde:	8b 75 bc             	mov    -0x44(%ebp),%esi
f0103be1:	2b 75 b8             	sub    -0x48(%ebp),%esi
f0103be4:	39 f1                	cmp    %esi,%ecx
f0103be6:	73 06                	jae    f0103bee <debuginfo_eip+0x10e>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0103be8:	03 4d b8             	add    -0x48(%ebp),%ecx
f0103beb:	89 4f 08             	mov    %ecx,0x8(%edi)
		info->eip_fn_addr = stabs[lfun].n_value;
f0103bee:	8b 4b 08             	mov    0x8(%ebx),%ecx
f0103bf1:	89 4f 10             	mov    %ecx,0x10(%edi)
		addr -= info->eip_fn_addr;
f0103bf4:	29 4d 08             	sub    %ecx,0x8(%ebp)
		// Search within the function definition for the line number.
		lline = lfun;
f0103bf7:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0103bfa:	89 55 d0             	mov    %edx,-0x30(%ebp)
		info->eip_fn_addr = addr;
		lline = lfile;
		rline = rfile;
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0103bfd:	83 ec 08             	sub    $0x8,%esp
f0103c00:	6a 3a                	push   $0x3a
f0103c02:	ff 77 08             	pushl  0x8(%edi)
f0103c05:	e8 52 09 00 00       	call   f010455c <strfind>
f0103c0a:	2b 47 08             	sub    0x8(%edi),%eax
f0103c0d:	89 47 0c             	mov    %eax,0xc(%edi)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0103c10:	83 c4 08             	add    $0x8,%esp
f0103c13:	ff 75 08             	pushl  0x8(%ebp)
f0103c16:	6a 44                	push   $0x44
f0103c18:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0103c1b:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0103c1e:	8b 5d c0             	mov    -0x40(%ebp),%ebx
f0103c21:	89 d8                	mov    %ebx,%eax
f0103c23:	e8 cb fd ff ff       	call   f01039f3 <stab_binsearch>
	if (lline <= rline)
f0103c28:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0103c2b:	83 c4 10             	add    $0x10,%esp
f0103c2e:	3b 55 d0             	cmp    -0x30(%ebp),%edx
f0103c31:	7f 19                	jg     f0103c4c <debuginfo_eip+0x16c>
	{
		// stabs[lline] points to the line
		// in the string table, but check bounds just in case.
		if (stabs[lline].n_strx < stabstr_end - stabstr)
f0103c33:	8d 04 12             	lea    (%edx,%edx,1),%eax
f0103c36:	01 d0                	add    %edx,%eax
f0103c38:	8d 04 83             	lea    (%ebx,%eax,4),%eax
f0103c3b:	8b 4d bc             	mov    -0x44(%ebp),%ecx
f0103c3e:	2b 4d b8             	sub    -0x48(%ebp),%ecx
f0103c41:	39 08                	cmp    %ecx,(%eax)
f0103c43:	73 07                	jae    f0103c4c <debuginfo_eip+0x16c>
			info->eip_line = stabs[lline].n_desc;
f0103c45:	0f b7 40 06          	movzwl 0x6(%eax),%eax
f0103c49:	89 47 04             	mov    %eax,0x4(%edi)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0103c4c:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0103c4f:	89 d0                	mov    %edx,%eax
f0103c51:	8d 0c 12             	lea    (%edx,%edx,1),%ecx
f0103c54:	01 ca                	add    %ecx,%edx
f0103c56:	8b 5d c0             	mov    -0x40(%ebp),%ebx
f0103c59:	8d 14 93             	lea    (%ebx,%edx,4),%edx
f0103c5c:	c6 45 c7 00          	movb   $0x0,-0x39(%ebp)
f0103c60:	89 7d 0c             	mov    %edi,0xc(%ebp)
f0103c63:	e9 b2 00 00 00       	jmp    f0103d1a <debuginfo_eip+0x23a>
		stabs = usd->stabs;
f0103c68:	8b 35 00 00 20 00    	mov    0x200000,%esi
f0103c6e:	89 75 c0             	mov    %esi,-0x40(%ebp)
		stab_end = usd->stab_end;
f0103c71:	8b 1d 04 00 20 00    	mov    0x200004,%ebx
		stabstr = usd->stabstr;
f0103c77:	8b 0d 08 00 20 00    	mov    0x200008,%ecx
f0103c7d:	89 4d b8             	mov    %ecx,-0x48(%ebp)
		stabstr_end = usd->stabstr_end;
f0103c80:	a1 0c 00 20 00       	mov    0x20000c,%eax
f0103c85:	89 45 bc             	mov    %eax,-0x44(%ebp)
		user_mem_check(curenv, usd, stab_end - stabs, PTE_U);
f0103c88:	6a 04                	push   $0x4
f0103c8a:	89 da                	mov    %ebx,%edx
f0103c8c:	29 f2                	sub    %esi,%edx
f0103c8e:	89 d0                	mov    %edx,%eax
f0103c90:	c1 fa 02             	sar    $0x2,%edx
f0103c93:	83 e0 fc             	and    $0xfffffffc,%eax
f0103c96:	01 d0                	add    %edx,%eax
f0103c98:	8d 04 82             	lea    (%edx,%eax,4),%eax
f0103c9b:	8d 04 82             	lea    (%edx,%eax,4),%eax
f0103c9e:	89 c1                	mov    %eax,%ecx
f0103ca0:	c1 e1 08             	shl    $0x8,%ecx
f0103ca3:	01 c8                	add    %ecx,%eax
f0103ca5:	89 c1                	mov    %eax,%ecx
f0103ca7:	c1 e1 10             	shl    $0x10,%ecx
f0103caa:	01 c8                	add    %ecx,%eax
f0103cac:	01 c0                	add    %eax,%eax
f0103cae:	01 c2                	add    %eax,%edx
f0103cb0:	52                   	push   %edx
f0103cb1:	68 00 00 20 00       	push   $0x200000
f0103cb6:	ff 35 48 1d 1b f0    	pushl  0xf01b1d48
f0103cbc:	e8 65 ec ff ff       	call   f0102926 <user_mem_check>
		user_mem_check(curenv, stabstr, stabstr_end - stabstr, PTE_U);
f0103cc1:	6a 04                	push   $0x4
f0103cc3:	8b 45 bc             	mov    -0x44(%ebp),%eax
f0103cc6:	8b 4d b8             	mov    -0x48(%ebp),%ecx
f0103cc9:	29 c8                	sub    %ecx,%eax
f0103ccb:	50                   	push   %eax
f0103ccc:	51                   	push   %ecx
f0103ccd:	ff 35 48 1d 1b f0    	pushl  0xf01b1d48
f0103cd3:	e8 4e ec ff ff       	call   f0102926 <user_mem_check>
		for(struct Stab* st = (struct Stab*)stabs; st <= stab_end; ++st) {
f0103cd8:	83 c4 20             	add    $0x20,%esp
f0103cdb:	39 de                	cmp    %ebx,%esi
f0103cdd:	0f 87 56 fe ff ff    	ja     f0103b39 <debuginfo_eip+0x59>
			user_mem_check(curenv, (void *)st, sizeof(struct Stab), PTE_U);
f0103ce3:	6a 04                	push   $0x4
f0103ce5:	6a 0c                	push   $0xc
f0103ce7:	56                   	push   %esi
f0103ce8:	ff 35 48 1d 1b f0    	pushl  0xf01b1d48
f0103cee:	e8 33 ec ff ff       	call   f0102926 <user_mem_check>
		for(struct Stab* st = (struct Stab*)stabs; st <= stab_end; ++st) {
f0103cf3:	83 c6 0c             	add    $0xc,%esi
f0103cf6:	83 c4 10             	add    $0x10,%esp
f0103cf9:	eb e0                	jmp    f0103cdb <debuginfo_eip+0x1fb>
		info->eip_fn_addr = addr;
f0103cfb:	8b 45 08             	mov    0x8(%ebp),%eax
f0103cfe:	89 47 10             	mov    %eax,0x10(%edi)
		lline = lfile;
f0103d01:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103d04:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0103d07:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103d0a:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0103d0d:	e9 eb fe ff ff       	jmp    f0103bfd <debuginfo_eip+0x11d>
f0103d12:	48                   	dec    %eax
f0103d13:	83 ea 0c             	sub    $0xc,%edx
	while (lline >= lfile
f0103d16:	c6 45 c7 01          	movb   $0x1,-0x39(%ebp)
f0103d1a:	39 c6                	cmp    %eax,%esi
f0103d1c:	7f 4c                	jg     f0103d6a <debuginfo_eip+0x28a>
	       && stabs[lline].n_type != N_SOL
f0103d1e:	8a 4a 04             	mov    0x4(%edx),%cl
f0103d21:	80 f9 84             	cmp    $0x84,%cl
f0103d24:	74 19                	je     f0103d3f <debuginfo_eip+0x25f>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0103d26:	80 f9 64             	cmp    $0x64,%cl
f0103d29:	75 e7                	jne    f0103d12 <debuginfo_eip+0x232>
f0103d2b:	83 7a 08 00          	cmpl   $0x0,0x8(%edx)
f0103d2f:	74 e1                	je     f0103d12 <debuginfo_eip+0x232>
f0103d31:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0103d34:	80 7d c7 00          	cmpb   $0x0,-0x39(%ebp)
f0103d38:	74 11                	je     f0103d4b <debuginfo_eip+0x26b>
f0103d3a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0103d3d:	eb 0c                	jmp    f0103d4b <debuginfo_eip+0x26b>
f0103d3f:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0103d42:	80 7d c7 00          	cmpb   $0x0,-0x39(%ebp)
f0103d46:	74 03                	je     f0103d4b <debuginfo_eip+0x26b>
f0103d48:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0103d4b:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0103d4e:	01 d0                	add    %edx,%eax
f0103d50:	8b 5d c0             	mov    -0x40(%ebp),%ebx
f0103d53:	8b 14 83             	mov    (%ebx,%eax,4),%edx
f0103d56:	8b 45 bc             	mov    -0x44(%ebp),%eax
f0103d59:	8b 5d b8             	mov    -0x48(%ebp),%ebx
f0103d5c:	29 d8                	sub    %ebx,%eax
f0103d5e:	39 c2                	cmp    %eax,%edx
f0103d60:	73 0b                	jae    f0103d6d <debuginfo_eip+0x28d>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0103d62:	89 d8                	mov    %ebx,%eax
f0103d64:	01 d0                	add    %edx,%eax
f0103d66:	89 07                	mov    %eax,(%edi)
f0103d68:	eb 03                	jmp    f0103d6d <debuginfo_eip+0x28d>
f0103d6a:	8b 7d 0c             	mov    0xc(%ebp),%edi


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0103d6d:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103d70:	8b 5d d8             	mov    -0x28(%ebp),%ebx
f0103d73:	39 da                	cmp    %ebx,%edx
f0103d75:	7d 42                	jge    f0103db9 <debuginfo_eip+0x2d9>
		for (lline = lfun + 1;
f0103d77:	42                   	inc    %edx
f0103d78:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f0103d7b:	89 d0                	mov    %edx,%eax
f0103d7d:	8d 0c 12             	lea    (%edx,%edx,1),%ecx
f0103d80:	01 ca                	add    %ecx,%edx
f0103d82:	8b 75 c0             	mov    -0x40(%ebp),%esi
f0103d85:	8d 14 96             	lea    (%esi,%edx,4),%edx
f0103d88:	eb 03                	jmp    f0103d8d <debuginfo_eip+0x2ad>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f0103d8a:	ff 47 14             	incl   0x14(%edi)
		for (lline = lfun + 1;
f0103d8d:	39 c3                	cmp    %eax,%ebx
f0103d8f:	7e 35                	jle    f0103dc6 <debuginfo_eip+0x2e6>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0103d91:	8a 4a 04             	mov    0x4(%edx),%cl
f0103d94:	40                   	inc    %eax
f0103d95:	83 c2 0c             	add    $0xc,%edx
f0103d98:	80 f9 a0             	cmp    $0xa0,%cl
f0103d9b:	74 ed                	je     f0103d8a <debuginfo_eip+0x2aa>

	return 0;
f0103d9d:	b8 00 00 00 00       	mov    $0x0,%eax
f0103da2:	eb 1a                	jmp    f0103dbe <debuginfo_eip+0x2de>
		return -1;
f0103da4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103da9:	eb 13                	jmp    f0103dbe <debuginfo_eip+0x2de>
f0103dab:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103db0:	eb 0c                	jmp    f0103dbe <debuginfo_eip+0x2de>
		return -1;
f0103db2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103db7:	eb 05                	jmp    f0103dbe <debuginfo_eip+0x2de>
	return 0;
f0103db9:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103dbe:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103dc1:	5b                   	pop    %ebx
f0103dc2:	5e                   	pop    %esi
f0103dc3:	5f                   	pop    %edi
f0103dc4:	5d                   	pop    %ebp
f0103dc5:	c3                   	ret    
	return 0;
f0103dc6:	b8 00 00 00 00       	mov    $0x0,%eax
f0103dcb:	eb f1                	jmp    f0103dbe <debuginfo_eip+0x2de>

f0103dcd <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0103dcd:	55                   	push   %ebp
f0103dce:	89 e5                	mov    %esp,%ebp
f0103dd0:	57                   	push   %edi
f0103dd1:	56                   	push   %esi
f0103dd2:	53                   	push   %ebx
f0103dd3:	83 ec 1c             	sub    $0x1c,%esp
f0103dd6:	89 c7                	mov    %eax,%edi
f0103dd8:	89 d6                	mov    %edx,%esi
f0103dda:	8b 45 08             	mov    0x8(%ebp),%eax
f0103ddd:	8b 55 0c             	mov    0xc(%ebp),%edx
f0103de0:	89 d1                	mov    %edx,%ecx
f0103de2:	89 c2                	mov    %eax,%edx
f0103de4:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0103de7:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0103dea:	8b 45 10             	mov    0x10(%ebp),%eax
f0103ded:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0103df0:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0103df3:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f0103dfa:	39 c2                	cmp    %eax,%edx
f0103dfc:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
f0103dff:	72 3c                	jb     f0103e3d <printnum+0x70>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0103e01:	83 ec 0c             	sub    $0xc,%esp
f0103e04:	ff 75 18             	pushl  0x18(%ebp)
f0103e07:	4b                   	dec    %ebx
f0103e08:	53                   	push   %ebx
f0103e09:	50                   	push   %eax
f0103e0a:	83 ec 08             	sub    $0x8,%esp
f0103e0d:	ff 75 e4             	pushl  -0x1c(%ebp)
f0103e10:	ff 75 e0             	pushl  -0x20(%ebp)
f0103e13:	ff 75 dc             	pushl  -0x24(%ebp)
f0103e16:	ff 75 d8             	pushl  -0x28(%ebp)
f0103e19:	e8 32 09 00 00       	call   f0104750 <__udivdi3>
f0103e1e:	83 c4 18             	add    $0x18,%esp
f0103e21:	52                   	push   %edx
f0103e22:	50                   	push   %eax
f0103e23:	89 f2                	mov    %esi,%edx
f0103e25:	89 f8                	mov    %edi,%eax
f0103e27:	e8 a1 ff ff ff       	call   f0103dcd <printnum>
f0103e2c:	83 c4 20             	add    $0x20,%esp
f0103e2f:	eb 11                	jmp    f0103e42 <printnum+0x75>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0103e31:	83 ec 08             	sub    $0x8,%esp
f0103e34:	56                   	push   %esi
f0103e35:	ff 75 18             	pushl  0x18(%ebp)
f0103e38:	ff d7                	call   *%edi
f0103e3a:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
f0103e3d:	4b                   	dec    %ebx
f0103e3e:	85 db                	test   %ebx,%ebx
f0103e40:	7f ef                	jg     f0103e31 <printnum+0x64>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0103e42:	83 ec 08             	sub    $0x8,%esp
f0103e45:	56                   	push   %esi
f0103e46:	83 ec 04             	sub    $0x4,%esp
f0103e49:	ff 75 e4             	pushl  -0x1c(%ebp)
f0103e4c:	ff 75 e0             	pushl  -0x20(%ebp)
f0103e4f:	ff 75 dc             	pushl  -0x24(%ebp)
f0103e52:	ff 75 d8             	pushl  -0x28(%ebp)
f0103e55:	e8 f6 09 00 00       	call   f0104850 <__umoddi3>
f0103e5a:	83 c4 14             	add    $0x14,%esp
f0103e5d:	0f be 80 d2 5e 10 f0 	movsbl -0xfefa12e(%eax),%eax
f0103e64:	50                   	push   %eax
f0103e65:	ff d7                	call   *%edi
}
f0103e67:	83 c4 10             	add    $0x10,%esp
f0103e6a:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103e6d:	5b                   	pop    %ebx
f0103e6e:	5e                   	pop    %esi
f0103e6f:	5f                   	pop    %edi
f0103e70:	5d                   	pop    %ebp
f0103e71:	c3                   	ret    

f0103e72 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0103e72:	55                   	push   %ebp
f0103e73:	89 e5                	mov    %esp,%ebp
f0103e75:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0103e78:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
f0103e7b:	8b 10                	mov    (%eax),%edx
f0103e7d:	3b 50 04             	cmp    0x4(%eax),%edx
f0103e80:	73 0a                	jae    f0103e8c <sprintputch+0x1a>
		*b->buf++ = ch;
f0103e82:	8d 4a 01             	lea    0x1(%edx),%ecx
f0103e85:	89 08                	mov    %ecx,(%eax)
f0103e87:	8b 45 08             	mov    0x8(%ebp),%eax
f0103e8a:	88 02                	mov    %al,(%edx)
}
f0103e8c:	5d                   	pop    %ebp
f0103e8d:	c3                   	ret    

f0103e8e <printfmt>:
{
f0103e8e:	55                   	push   %ebp
f0103e8f:	89 e5                	mov    %esp,%ebp
f0103e91:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
f0103e94:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0103e97:	50                   	push   %eax
f0103e98:	ff 75 10             	pushl  0x10(%ebp)
f0103e9b:	ff 75 0c             	pushl  0xc(%ebp)
f0103e9e:	ff 75 08             	pushl  0x8(%ebp)
f0103ea1:	e8 05 00 00 00       	call   f0103eab <vprintfmt>
}
f0103ea6:	83 c4 10             	add    $0x10,%esp
f0103ea9:	c9                   	leave  
f0103eaa:	c3                   	ret    

f0103eab <vprintfmt>:
{
f0103eab:	55                   	push   %ebp
f0103eac:	89 e5                	mov    %esp,%ebp
f0103eae:	57                   	push   %edi
f0103eaf:	56                   	push   %esi
f0103eb0:	53                   	push   %ebx
f0103eb1:	83 ec 3c             	sub    $0x3c,%esp
f0103eb4:	8b 75 08             	mov    0x8(%ebp),%esi
f0103eb7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0103eba:	8b 7d 10             	mov    0x10(%ebp),%edi
f0103ebd:	e9 5b 03 00 00       	jmp    f010421d <vprintfmt+0x372>
		padc = ' ';
f0103ec2:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
f0103ec6:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
		precision = -1;
f0103ecd:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
f0103ed4:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		lflag = 0;
f0103edb:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
f0103ee0:	8d 47 01             	lea    0x1(%edi),%eax
f0103ee3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0103ee6:	8a 17                	mov    (%edi),%dl
f0103ee8:	8d 42 dd             	lea    -0x23(%edx),%eax
f0103eeb:	3c 55                	cmp    $0x55,%al
f0103eed:	0f 87 ab 03 00 00    	ja     f010429e <vprintfmt+0x3f3>
f0103ef3:	0f b6 c0             	movzbl %al,%eax
f0103ef6:	ff 24 85 5c 5f 10 f0 	jmp    *-0xfefa0a4(,%eax,4)
f0103efd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
f0103f00:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
f0103f04:	eb da                	jmp    f0103ee0 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
f0103f06:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0103f09:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
f0103f0d:	eb d1                	jmp    f0103ee0 <vprintfmt+0x35>
f0103f0f:	0f b6 d2             	movzbl %dl,%edx
f0103f12:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
f0103f15:	b8 00 00 00 00       	mov    $0x0,%eax
f0103f1a:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
f0103f1d:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0103f20:	01 c0                	add    %eax,%eax
f0103f22:	8d 44 02 d0          	lea    -0x30(%edx,%eax,1),%eax
				ch = *fmt;
f0103f26:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
f0103f29:	8d 4a d0             	lea    -0x30(%edx),%ecx
f0103f2c:	83 f9 09             	cmp    $0x9,%ecx
f0103f2f:	77 52                	ja     f0103f83 <vprintfmt+0xd8>
			for (precision = 0; ; ++fmt) {
f0103f31:	47                   	inc    %edi
				precision = precision * 10 + ch - '0';
f0103f32:	eb e9                	jmp    f0103f1d <vprintfmt+0x72>
			precision = va_arg(ap, int);
f0103f34:	8b 45 14             	mov    0x14(%ebp),%eax
f0103f37:	8b 00                	mov    (%eax),%eax
f0103f39:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0103f3c:	8b 45 14             	mov    0x14(%ebp),%eax
f0103f3f:	8d 40 04             	lea    0x4(%eax),%eax
f0103f42:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0103f45:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
f0103f48:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f0103f4c:	79 92                	jns    f0103ee0 <vprintfmt+0x35>
				width = precision, precision = -1;
f0103f4e:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0103f51:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0103f54:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
f0103f5b:	eb 83                	jmp    f0103ee0 <vprintfmt+0x35>
f0103f5d:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f0103f61:	78 08                	js     f0103f6b <vprintfmt+0xc0>
		switch (ch = *(unsigned char *) fmt++) {
f0103f63:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
f0103f66:	e9 75 ff ff ff       	jmp    f0103ee0 <vprintfmt+0x35>
f0103f6b:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
f0103f72:	eb ef                	jmp    f0103f63 <vprintfmt+0xb8>
		switch (ch = *(unsigned char *) fmt++) {
f0103f74:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
f0103f77:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
f0103f7e:	e9 5d ff ff ff       	jmp    f0103ee0 <vprintfmt+0x35>
f0103f83:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0103f86:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0103f89:	eb bd                	jmp    f0103f48 <vprintfmt+0x9d>
			lflag++;
f0103f8b:	41                   	inc    %ecx
		switch (ch = *(unsigned char *) fmt++) {
f0103f8c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
f0103f8f:	e9 4c ff ff ff       	jmp    f0103ee0 <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
f0103f94:	8b 45 14             	mov    0x14(%ebp),%eax
f0103f97:	8d 78 04             	lea    0x4(%eax),%edi
f0103f9a:	83 ec 08             	sub    $0x8,%esp
f0103f9d:	53                   	push   %ebx
f0103f9e:	ff 30                	pushl  (%eax)
f0103fa0:	ff d6                	call   *%esi
			break;
f0103fa2:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
f0103fa5:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
f0103fa8:	e9 6d 02 00 00       	jmp    f010421a <vprintfmt+0x36f>
			err = va_arg(ap, int);
f0103fad:	8b 45 14             	mov    0x14(%ebp),%eax
f0103fb0:	8d 78 04             	lea    0x4(%eax),%edi
f0103fb3:	8b 00                	mov    (%eax),%eax
f0103fb5:	85 c0                	test   %eax,%eax
f0103fb7:	78 2a                	js     f0103fe3 <vprintfmt+0x138>
f0103fb9:	89 c2                	mov    %eax,%edx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0103fbb:	83 f8 06             	cmp    $0x6,%eax
f0103fbe:	7f 27                	jg     f0103fe7 <vprintfmt+0x13c>
f0103fc0:	8b 04 85 b4 60 10 f0 	mov    -0xfef9f4c(,%eax,4),%eax
f0103fc7:	85 c0                	test   %eax,%eax
f0103fc9:	74 1c                	je     f0103fe7 <vprintfmt+0x13c>
				printfmt(putch, putdat, "%s", p);
f0103fcb:	50                   	push   %eax
f0103fcc:	68 4b 4f 10 f0       	push   $0xf0104f4b
f0103fd1:	53                   	push   %ebx
f0103fd2:	56                   	push   %esi
f0103fd3:	e8 b6 fe ff ff       	call   f0103e8e <printfmt>
f0103fd8:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f0103fdb:	89 7d 14             	mov    %edi,0x14(%ebp)
f0103fde:	e9 37 02 00 00       	jmp    f010421a <vprintfmt+0x36f>
f0103fe3:	f7 d8                	neg    %eax
f0103fe5:	eb d2                	jmp    f0103fb9 <vprintfmt+0x10e>
				printfmt(putch, putdat, "error %d", err);
f0103fe7:	52                   	push   %edx
f0103fe8:	68 ea 5e 10 f0       	push   $0xf0105eea
f0103fed:	53                   	push   %ebx
f0103fee:	56                   	push   %esi
f0103fef:	e8 9a fe ff ff       	call   f0103e8e <printfmt>
f0103ff4:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f0103ff7:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
f0103ffa:	e9 1b 02 00 00       	jmp    f010421a <vprintfmt+0x36f>
			if ((p = va_arg(ap, char *)) == NULL)
f0103fff:	8b 45 14             	mov    0x14(%ebp),%eax
f0104002:	83 c0 04             	add    $0x4,%eax
f0104005:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0104008:	8b 45 14             	mov    0x14(%ebp),%eax
f010400b:	8b 00                	mov    (%eax),%eax
f010400d:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0104010:	85 c0                	test   %eax,%eax
f0104012:	74 19                	je     f010402d <vprintfmt+0x182>
			if (width > 0 && padc != '-')
f0104014:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f0104018:	7e 06                	jle    f0104020 <vprintfmt+0x175>
f010401a:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
f010401e:	75 16                	jne    f0104036 <vprintfmt+0x18b>
				for (width -= strnlen(p, precision); width > 0; width--)
f0104020:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0104023:	89 c7                	mov    %eax,%edi
f0104025:	03 45 d4             	add    -0x2c(%ebp),%eax
f0104028:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010402b:	eb 62                	jmp    f010408f <vprintfmt+0x1e4>
				p = "(null)";
f010402d:	c7 45 cc e3 5e 10 f0 	movl   $0xf0105ee3,-0x34(%ebp)
f0104034:	eb de                	jmp    f0104014 <vprintfmt+0x169>
				for (width -= strnlen(p, precision); width > 0; width--)
f0104036:	83 ec 08             	sub    $0x8,%esp
f0104039:	ff 75 d8             	pushl  -0x28(%ebp)
f010403c:	ff 75 cc             	pushl  -0x34(%ebp)
f010403f:	e8 e2 03 00 00       	call   f0104426 <strnlen>
f0104044:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0104047:	29 c2                	sub    %eax,%edx
f0104049:	89 55 c4             	mov    %edx,-0x3c(%ebp)
f010404c:	83 c4 10             	add    $0x10,%esp
f010404f:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
f0104051:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
f0104055:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
f0104058:	eb 0d                	jmp    f0104067 <vprintfmt+0x1bc>
					putch(padc, putdat);
f010405a:	83 ec 08             	sub    $0x8,%esp
f010405d:	53                   	push   %ebx
f010405e:	ff 75 d4             	pushl  -0x2c(%ebp)
f0104061:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
f0104063:	4f                   	dec    %edi
f0104064:	83 c4 10             	add    $0x10,%esp
f0104067:	85 ff                	test   %edi,%edi
f0104069:	7f ef                	jg     f010405a <vprintfmt+0x1af>
f010406b:	8b 55 c4             	mov    -0x3c(%ebp),%edx
f010406e:	89 d0                	mov    %edx,%eax
f0104070:	85 d2                	test   %edx,%edx
f0104072:	78 0a                	js     f010407e <vprintfmt+0x1d3>
f0104074:	8b 55 c4             	mov    -0x3c(%ebp),%edx
f0104077:	29 c2                	sub    %eax,%edx
f0104079:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f010407c:	eb a2                	jmp    f0104020 <vprintfmt+0x175>
f010407e:	b8 00 00 00 00       	mov    $0x0,%eax
f0104083:	eb ef                	jmp    f0104074 <vprintfmt+0x1c9>
					putch(ch, putdat);
f0104085:	83 ec 08             	sub    $0x8,%esp
f0104088:	53                   	push   %ebx
f0104089:	52                   	push   %edx
f010408a:	ff d6                	call   *%esi
f010408c:	83 c4 10             	add    $0x10,%esp
f010408f:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0104092:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0104094:	47                   	inc    %edi
f0104095:	8a 47 ff             	mov    -0x1(%edi),%al
f0104098:	0f be d0             	movsbl %al,%edx
f010409b:	85 d2                	test   %edx,%edx
f010409d:	74 48                	je     f01040e7 <vprintfmt+0x23c>
f010409f:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f01040a3:	78 05                	js     f01040aa <vprintfmt+0x1ff>
f01040a5:	ff 4d d8             	decl   -0x28(%ebp)
f01040a8:	78 1e                	js     f01040c8 <vprintfmt+0x21d>
				if (altflag && (ch < ' ' || ch > '~'))
f01040aa:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f01040ae:	74 d5                	je     f0104085 <vprintfmt+0x1da>
f01040b0:	0f be c0             	movsbl %al,%eax
f01040b3:	83 e8 20             	sub    $0x20,%eax
f01040b6:	83 f8 5e             	cmp    $0x5e,%eax
f01040b9:	76 ca                	jbe    f0104085 <vprintfmt+0x1da>
					putch('?', putdat);
f01040bb:	83 ec 08             	sub    $0x8,%esp
f01040be:	53                   	push   %ebx
f01040bf:	6a 3f                	push   $0x3f
f01040c1:	ff d6                	call   *%esi
f01040c3:	83 c4 10             	add    $0x10,%esp
f01040c6:	eb c7                	jmp    f010408f <vprintfmt+0x1e4>
f01040c8:	89 cf                	mov    %ecx,%edi
f01040ca:	eb 0c                	jmp    f01040d8 <vprintfmt+0x22d>
				putch(' ', putdat);
f01040cc:	83 ec 08             	sub    $0x8,%esp
f01040cf:	53                   	push   %ebx
f01040d0:	6a 20                	push   $0x20
f01040d2:	ff d6                	call   *%esi
			for (; width > 0; width--)
f01040d4:	4f                   	dec    %edi
f01040d5:	83 c4 10             	add    $0x10,%esp
f01040d8:	85 ff                	test   %edi,%edi
f01040da:	7f f0                	jg     f01040cc <vprintfmt+0x221>
			if ((p = va_arg(ap, char *)) == NULL)
f01040dc:	8b 45 c8             	mov    -0x38(%ebp),%eax
f01040df:	89 45 14             	mov    %eax,0x14(%ebp)
f01040e2:	e9 33 01 00 00       	jmp    f010421a <vprintfmt+0x36f>
f01040e7:	89 cf                	mov    %ecx,%edi
f01040e9:	eb ed                	jmp    f01040d8 <vprintfmt+0x22d>
	if (lflag >= 2)
f01040eb:	83 f9 01             	cmp    $0x1,%ecx
f01040ee:	7f 1b                	jg     f010410b <vprintfmt+0x260>
	else if (lflag)
f01040f0:	85 c9                	test   %ecx,%ecx
f01040f2:	74 42                	je     f0104136 <vprintfmt+0x28b>
		return va_arg(*ap, long);
f01040f4:	8b 45 14             	mov    0x14(%ebp),%eax
f01040f7:	8b 00                	mov    (%eax),%eax
f01040f9:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01040fc:	99                   	cltd   
f01040fd:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0104100:	8b 45 14             	mov    0x14(%ebp),%eax
f0104103:	8d 40 04             	lea    0x4(%eax),%eax
f0104106:	89 45 14             	mov    %eax,0x14(%ebp)
f0104109:	eb 17                	jmp    f0104122 <vprintfmt+0x277>
		return va_arg(*ap, long long);
f010410b:	8b 45 14             	mov    0x14(%ebp),%eax
f010410e:	8b 50 04             	mov    0x4(%eax),%edx
f0104111:	8b 00                	mov    (%eax),%eax
f0104113:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104116:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0104119:	8b 45 14             	mov    0x14(%ebp),%eax
f010411c:	8d 40 08             	lea    0x8(%eax),%eax
f010411f:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
f0104122:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0104125:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f0104128:	85 c9                	test   %ecx,%ecx
f010412a:	78 21                	js     f010414d <vprintfmt+0x2a2>
			base = 10;
f010412c:	b8 0a 00 00 00       	mov    $0xa,%eax
f0104131:	e9 ca 00 00 00       	jmp    f0104200 <vprintfmt+0x355>
		return va_arg(*ap, int);
f0104136:	8b 45 14             	mov    0x14(%ebp),%eax
f0104139:	8b 00                	mov    (%eax),%eax
f010413b:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010413e:	99                   	cltd   
f010413f:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0104142:	8b 45 14             	mov    0x14(%ebp),%eax
f0104145:	8d 40 04             	lea    0x4(%eax),%eax
f0104148:	89 45 14             	mov    %eax,0x14(%ebp)
f010414b:	eb d5                	jmp    f0104122 <vprintfmt+0x277>
				putch('-', putdat);
f010414d:	83 ec 08             	sub    $0x8,%esp
f0104150:	53                   	push   %ebx
f0104151:	6a 2d                	push   $0x2d
f0104153:	ff d6                	call   *%esi
				num = -(long long) num;
f0104155:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0104158:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f010415b:	f7 da                	neg    %edx
f010415d:	83 d1 00             	adc    $0x0,%ecx
f0104160:	f7 d9                	neg    %ecx
f0104162:	83 c4 10             	add    $0x10,%esp
			base = 10;
f0104165:	b8 0a 00 00 00       	mov    $0xa,%eax
f010416a:	e9 91 00 00 00       	jmp    f0104200 <vprintfmt+0x355>
	if (lflag >= 2)
f010416f:	83 f9 01             	cmp    $0x1,%ecx
f0104172:	7f 1b                	jg     f010418f <vprintfmt+0x2e4>
	else if (lflag)
f0104174:	85 c9                	test   %ecx,%ecx
f0104176:	74 2c                	je     f01041a4 <vprintfmt+0x2f9>
		return va_arg(*ap, unsigned long);
f0104178:	8b 45 14             	mov    0x14(%ebp),%eax
f010417b:	8b 10                	mov    (%eax),%edx
f010417d:	b9 00 00 00 00       	mov    $0x0,%ecx
f0104182:	8d 40 04             	lea    0x4(%eax),%eax
f0104185:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0104188:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
f010418d:	eb 71                	jmp    f0104200 <vprintfmt+0x355>
		return va_arg(*ap, unsigned long long);
f010418f:	8b 45 14             	mov    0x14(%ebp),%eax
f0104192:	8b 10                	mov    (%eax),%edx
f0104194:	8b 48 04             	mov    0x4(%eax),%ecx
f0104197:	8d 40 08             	lea    0x8(%eax),%eax
f010419a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f010419d:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
f01041a2:	eb 5c                	jmp    f0104200 <vprintfmt+0x355>
		return va_arg(*ap, unsigned int);
f01041a4:	8b 45 14             	mov    0x14(%ebp),%eax
f01041a7:	8b 10                	mov    (%eax),%edx
f01041a9:	b9 00 00 00 00       	mov    $0x0,%ecx
f01041ae:	8d 40 04             	lea    0x4(%eax),%eax
f01041b1:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f01041b4:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
f01041b9:	eb 45                	jmp    f0104200 <vprintfmt+0x355>
			putch('X', putdat);
f01041bb:	83 ec 08             	sub    $0x8,%esp
f01041be:	53                   	push   %ebx
f01041bf:	6a 58                	push   $0x58
f01041c1:	ff d6                	call   *%esi
			putch('X', putdat);
f01041c3:	83 c4 08             	add    $0x8,%esp
f01041c6:	53                   	push   %ebx
f01041c7:	6a 58                	push   $0x58
f01041c9:	ff d6                	call   *%esi
			putch('X', putdat);
f01041cb:	83 c4 08             	add    $0x8,%esp
f01041ce:	53                   	push   %ebx
f01041cf:	6a 58                	push   $0x58
f01041d1:	ff d6                	call   *%esi
			break;
f01041d3:	83 c4 10             	add    $0x10,%esp
f01041d6:	eb 42                	jmp    f010421a <vprintfmt+0x36f>
			putch('0', putdat);
f01041d8:	83 ec 08             	sub    $0x8,%esp
f01041db:	53                   	push   %ebx
f01041dc:	6a 30                	push   $0x30
f01041de:	ff d6                	call   *%esi
			putch('x', putdat);
f01041e0:	83 c4 08             	add    $0x8,%esp
f01041e3:	53                   	push   %ebx
f01041e4:	6a 78                	push   $0x78
f01041e6:	ff d6                	call   *%esi
			num = (unsigned long long)
f01041e8:	8b 45 14             	mov    0x14(%ebp),%eax
f01041eb:	8b 10                	mov    (%eax),%edx
f01041ed:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
f01041f2:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
f01041f5:	8d 40 04             	lea    0x4(%eax),%eax
f01041f8:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f01041fb:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
f0104200:	83 ec 0c             	sub    $0xc,%esp
f0104203:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
f0104207:	57                   	push   %edi
f0104208:	ff 75 d4             	pushl  -0x2c(%ebp)
f010420b:	50                   	push   %eax
f010420c:	51                   	push   %ecx
f010420d:	52                   	push   %edx
f010420e:	89 da                	mov    %ebx,%edx
f0104210:	89 f0                	mov    %esi,%eax
f0104212:	e8 b6 fb ff ff       	call   f0103dcd <printnum>
			break;
f0104217:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
f010421a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
f010421d:	47                   	inc    %edi
f010421e:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0104222:	83 f8 25             	cmp    $0x25,%eax
f0104225:	0f 84 97 fc ff ff    	je     f0103ec2 <vprintfmt+0x17>
			if (ch == '\0')
f010422b:	85 c0                	test   %eax,%eax
f010422d:	0f 84 89 00 00 00    	je     f01042bc <vprintfmt+0x411>
			putch(ch, putdat);
f0104233:	83 ec 08             	sub    $0x8,%esp
f0104236:	53                   	push   %ebx
f0104237:	50                   	push   %eax
f0104238:	ff d6                	call   *%esi
f010423a:	83 c4 10             	add    $0x10,%esp
f010423d:	eb de                	jmp    f010421d <vprintfmt+0x372>
	if (lflag >= 2)
f010423f:	83 f9 01             	cmp    $0x1,%ecx
f0104242:	7f 1b                	jg     f010425f <vprintfmt+0x3b4>
	else if (lflag)
f0104244:	85 c9                	test   %ecx,%ecx
f0104246:	74 2c                	je     f0104274 <vprintfmt+0x3c9>
		return va_arg(*ap, unsigned long);
f0104248:	8b 45 14             	mov    0x14(%ebp),%eax
f010424b:	8b 10                	mov    (%eax),%edx
f010424d:	b9 00 00 00 00       	mov    $0x0,%ecx
f0104252:	8d 40 04             	lea    0x4(%eax),%eax
f0104255:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0104258:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
f010425d:	eb a1                	jmp    f0104200 <vprintfmt+0x355>
		return va_arg(*ap, unsigned long long);
f010425f:	8b 45 14             	mov    0x14(%ebp),%eax
f0104262:	8b 10                	mov    (%eax),%edx
f0104264:	8b 48 04             	mov    0x4(%eax),%ecx
f0104267:	8d 40 08             	lea    0x8(%eax),%eax
f010426a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f010426d:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
f0104272:	eb 8c                	jmp    f0104200 <vprintfmt+0x355>
		return va_arg(*ap, unsigned int);
f0104274:	8b 45 14             	mov    0x14(%ebp),%eax
f0104277:	8b 10                	mov    (%eax),%edx
f0104279:	b9 00 00 00 00       	mov    $0x0,%ecx
f010427e:	8d 40 04             	lea    0x4(%eax),%eax
f0104281:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0104284:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
f0104289:	e9 72 ff ff ff       	jmp    f0104200 <vprintfmt+0x355>
			putch(ch, putdat);
f010428e:	83 ec 08             	sub    $0x8,%esp
f0104291:	53                   	push   %ebx
f0104292:	6a 25                	push   $0x25
f0104294:	ff d6                	call   *%esi
			break;
f0104296:	83 c4 10             	add    $0x10,%esp
f0104299:	e9 7c ff ff ff       	jmp    f010421a <vprintfmt+0x36f>
			putch('%', putdat);
f010429e:	83 ec 08             	sub    $0x8,%esp
f01042a1:	53                   	push   %ebx
f01042a2:	6a 25                	push   $0x25
f01042a4:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f01042a6:	83 c4 10             	add    $0x10,%esp
f01042a9:	89 f8                	mov    %edi,%eax
f01042ab:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
f01042af:	74 03                	je     f01042b4 <vprintfmt+0x409>
f01042b1:	48                   	dec    %eax
f01042b2:	eb f7                	jmp    f01042ab <vprintfmt+0x400>
f01042b4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01042b7:	e9 5e ff ff ff       	jmp    f010421a <vprintfmt+0x36f>
}
f01042bc:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01042bf:	5b                   	pop    %ebx
f01042c0:	5e                   	pop    %esi
f01042c1:	5f                   	pop    %edi
f01042c2:	5d                   	pop    %ebp
f01042c3:	c3                   	ret    

f01042c4 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f01042c4:	55                   	push   %ebp
f01042c5:	89 e5                	mov    %esp,%ebp
f01042c7:	83 ec 18             	sub    $0x18,%esp
f01042ca:	8b 45 08             	mov    0x8(%ebp),%eax
f01042cd:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f01042d0:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01042d3:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f01042d7:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f01042da:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f01042e1:	85 c0                	test   %eax,%eax
f01042e3:	74 26                	je     f010430b <vsnprintf+0x47>
f01042e5:	85 d2                	test   %edx,%edx
f01042e7:	7e 29                	jle    f0104312 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f01042e9:	ff 75 14             	pushl  0x14(%ebp)
f01042ec:	ff 75 10             	pushl  0x10(%ebp)
f01042ef:	8d 45 ec             	lea    -0x14(%ebp),%eax
f01042f2:	50                   	push   %eax
f01042f3:	68 72 3e 10 f0       	push   $0xf0103e72
f01042f8:	e8 ae fb ff ff       	call   f0103eab <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f01042fd:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0104300:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0104303:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104306:	83 c4 10             	add    $0x10,%esp
}
f0104309:	c9                   	leave  
f010430a:	c3                   	ret    
		return -E_INVAL;
f010430b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104310:	eb f7                	jmp    f0104309 <vsnprintf+0x45>
f0104312:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104317:	eb f0                	jmp    f0104309 <vsnprintf+0x45>

f0104319 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0104319:	55                   	push   %ebp
f010431a:	89 e5                	mov    %esp,%ebp
f010431c:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f010431f:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0104322:	50                   	push   %eax
f0104323:	ff 75 10             	pushl  0x10(%ebp)
f0104326:	ff 75 0c             	pushl  0xc(%ebp)
f0104329:	ff 75 08             	pushl  0x8(%ebp)
f010432c:	e8 93 ff ff ff       	call   f01042c4 <vsnprintf>
	va_end(ap);

	return rc;
}
f0104331:	c9                   	leave  
f0104332:	c3                   	ret    

f0104333 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0104333:	55                   	push   %ebp
f0104334:	89 e5                	mov    %esp,%ebp
f0104336:	57                   	push   %edi
f0104337:	56                   	push   %esi
f0104338:	53                   	push   %ebx
f0104339:	83 ec 0c             	sub    $0xc,%esp
f010433c:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f010433f:	85 c0                	test   %eax,%eax
f0104341:	74 11                	je     f0104354 <readline+0x21>
		cprintf("%s", prompt);
f0104343:	83 ec 08             	sub    $0x8,%esp
f0104346:	50                   	push   %eax
f0104347:	68 4b 4f 10 f0       	push   $0xf0104f4b
f010434c:	e8 cb ed ff ff       	call   f010311c <cprintf>
f0104351:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f0104354:	83 ec 0c             	sub    $0xc,%esp
f0104357:	6a 00                	push   $0x0
f0104359:	e8 9e c2 ff ff       	call   f01005fc <iscons>
f010435e:	89 c7                	mov    %eax,%edi
f0104360:	83 c4 10             	add    $0x10,%esp
	i = 0;
f0104363:	be 00 00 00 00       	mov    $0x0,%esi
f0104368:	eb 75                	jmp    f01043df <readline+0xac>
	while (1) {
		c = getchar();
		if (c < 0) {
			cprintf("read error: %e\n", c);
f010436a:	83 ec 08             	sub    $0x8,%esp
f010436d:	50                   	push   %eax
f010436e:	68 d0 60 10 f0       	push   $0xf01060d0
f0104373:	e8 a4 ed ff ff       	call   f010311c <cprintf>
			return NULL;
f0104378:	83 c4 10             	add    $0x10,%esp
f010437b:	b8 00 00 00 00       	mov    $0x0,%eax
				cputchar('\n');
			buf[i] = 0;
			return buf;
		}
	}
}
f0104380:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104383:	5b                   	pop    %ebx
f0104384:	5e                   	pop    %esi
f0104385:	5f                   	pop    %edi
f0104386:	5d                   	pop    %ebp
f0104387:	c3                   	ret    
				cputchar('\b');
f0104388:	83 ec 0c             	sub    $0xc,%esp
f010438b:	6a 08                	push   $0x8
f010438d:	e8 49 c2 ff ff       	call   f01005db <cputchar>
f0104392:	83 c4 10             	add    $0x10,%esp
f0104395:	eb 47                	jmp    f01043de <readline+0xab>
				cputchar(c);
f0104397:	83 ec 0c             	sub    $0xc,%esp
f010439a:	53                   	push   %ebx
f010439b:	e8 3b c2 ff ff       	call   f01005db <cputchar>
f01043a0:	83 c4 10             	add    $0x10,%esp
f01043a3:	eb 60                	jmp    f0104405 <readline+0xd2>
		} else if (c == '\n' || c == '\r') {
f01043a5:	83 f8 0a             	cmp    $0xa,%eax
f01043a8:	74 05                	je     f01043af <readline+0x7c>
f01043aa:	83 f8 0d             	cmp    $0xd,%eax
f01043ad:	75 30                	jne    f01043df <readline+0xac>
			if (echoing)
f01043af:	85 ff                	test   %edi,%edi
f01043b1:	75 0e                	jne    f01043c1 <readline+0x8e>
			buf[i] = 0;
f01043b3:	c6 86 00 26 1b f0 00 	movb   $0x0,-0xfe4da00(%esi)
			return buf;
f01043ba:	b8 00 26 1b f0       	mov    $0xf01b2600,%eax
f01043bf:	eb bf                	jmp    f0104380 <readline+0x4d>
				cputchar('\n');
f01043c1:	83 ec 0c             	sub    $0xc,%esp
f01043c4:	6a 0a                	push   $0xa
f01043c6:	e8 10 c2 ff ff       	call   f01005db <cputchar>
f01043cb:	83 c4 10             	add    $0x10,%esp
f01043ce:	eb e3                	jmp    f01043b3 <readline+0x80>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f01043d0:	85 f6                	test   %esi,%esi
f01043d2:	7f 06                	jg     f01043da <readline+0xa7>
f01043d4:	eb 23                	jmp    f01043f9 <readline+0xc6>
f01043d6:	85 f6                	test   %esi,%esi
f01043d8:	7e 05                	jle    f01043df <readline+0xac>
			if (echoing)
f01043da:	85 ff                	test   %edi,%edi
f01043dc:	75 aa                	jne    f0104388 <readline+0x55>
			i--;
f01043de:	4e                   	dec    %esi
		c = getchar();
f01043df:	e8 07 c2 ff ff       	call   f01005eb <getchar>
f01043e4:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f01043e6:	85 c0                	test   %eax,%eax
f01043e8:	78 80                	js     f010436a <readline+0x37>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f01043ea:	83 f8 08             	cmp    $0x8,%eax
f01043ed:	74 e7                	je     f01043d6 <readline+0xa3>
f01043ef:	83 f8 7f             	cmp    $0x7f,%eax
f01043f2:	74 dc                	je     f01043d0 <readline+0x9d>
		} else if (c >= ' ' && i < BUFLEN-1) {
f01043f4:	83 f8 1f             	cmp    $0x1f,%eax
f01043f7:	7e ac                	jle    f01043a5 <readline+0x72>
f01043f9:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f01043ff:	7f de                	jg     f01043df <readline+0xac>
			if (echoing)
f0104401:	85 ff                	test   %edi,%edi
f0104403:	75 92                	jne    f0104397 <readline+0x64>
			buf[i++] = c;
f0104405:	88 9e 00 26 1b f0    	mov    %bl,-0xfe4da00(%esi)
f010440b:	8d 76 01             	lea    0x1(%esi),%esi
f010440e:	eb cf                	jmp    f01043df <readline+0xac>

f0104410 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0104410:	55                   	push   %ebp
f0104411:	89 e5                	mov    %esp,%ebp
f0104413:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0104416:	b8 00 00 00 00       	mov    $0x0,%eax
f010441b:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f010441f:	74 03                	je     f0104424 <strlen+0x14>
		n++;
f0104421:	40                   	inc    %eax
f0104422:	eb f7                	jmp    f010441b <strlen+0xb>
	return n;
}
f0104424:	5d                   	pop    %ebp
f0104425:	c3                   	ret    

f0104426 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0104426:	55                   	push   %ebp
f0104427:	89 e5                	mov    %esp,%ebp
f0104429:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010442c:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f010442f:	b8 00 00 00 00       	mov    $0x0,%eax
f0104434:	39 d0                	cmp    %edx,%eax
f0104436:	74 0b                	je     f0104443 <strnlen+0x1d>
f0104438:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f010443c:	74 03                	je     f0104441 <strnlen+0x1b>
		n++;
f010443e:	40                   	inc    %eax
f010443f:	eb f3                	jmp    f0104434 <strnlen+0xe>
f0104441:	89 c2                	mov    %eax,%edx
	return n;
}
f0104443:	89 d0                	mov    %edx,%eax
f0104445:	5d                   	pop    %ebp
f0104446:	c3                   	ret    

f0104447 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0104447:	55                   	push   %ebp
f0104448:	89 e5                	mov    %esp,%ebp
f010444a:	53                   	push   %ebx
f010444b:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010444e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0104451:	b8 00 00 00 00       	mov    $0x0,%eax
f0104456:	8a 14 03             	mov    (%ebx,%eax,1),%dl
f0104459:	88 14 01             	mov    %dl,(%ecx,%eax,1)
f010445c:	40                   	inc    %eax
f010445d:	84 d2                	test   %dl,%dl
f010445f:	75 f5                	jne    f0104456 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
f0104461:	89 c8                	mov    %ecx,%eax
f0104463:	5b                   	pop    %ebx
f0104464:	5d                   	pop    %ebp
f0104465:	c3                   	ret    

f0104466 <strcat>:

char *
strcat(char *dst, const char *src)
{
f0104466:	55                   	push   %ebp
f0104467:	89 e5                	mov    %esp,%ebp
f0104469:	53                   	push   %ebx
f010446a:	83 ec 10             	sub    $0x10,%esp
f010446d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0104470:	53                   	push   %ebx
f0104471:	e8 9a ff ff ff       	call   f0104410 <strlen>
f0104476:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
f0104479:	ff 75 0c             	pushl  0xc(%ebp)
f010447c:	01 d8                	add    %ebx,%eax
f010447e:	50                   	push   %eax
f010447f:	e8 c3 ff ff ff       	call   f0104447 <strcpy>
	return dst;
}
f0104484:	89 d8                	mov    %ebx,%eax
f0104486:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0104489:	c9                   	leave  
f010448a:	c3                   	ret    

f010448b <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f010448b:	55                   	push   %ebp
f010448c:	89 e5                	mov    %esp,%ebp
f010448e:	53                   	push   %ebx
f010448f:	8b 55 0c             	mov    0xc(%ebp),%edx
f0104492:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0104495:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0104498:	8b 45 08             	mov    0x8(%ebp),%eax
f010449b:	39 d8                	cmp    %ebx,%eax
f010449d:	74 0e                	je     f01044ad <strncpy+0x22>
		*dst++ = *src;
f010449f:	40                   	inc    %eax
f01044a0:	8a 0a                	mov    (%edx),%cl
f01044a2:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f01044a5:	80 f9 01             	cmp    $0x1,%cl
f01044a8:	83 da ff             	sbb    $0xffffffff,%edx
f01044ab:	eb ee                	jmp    f010449b <strncpy+0x10>
	}
	return ret;
}
f01044ad:	8b 45 08             	mov    0x8(%ebp),%eax
f01044b0:	5b                   	pop    %ebx
f01044b1:	5d                   	pop    %ebp
f01044b2:	c3                   	ret    

f01044b3 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f01044b3:	55                   	push   %ebp
f01044b4:	89 e5                	mov    %esp,%ebp
f01044b6:	56                   	push   %esi
f01044b7:	53                   	push   %ebx
f01044b8:	8b 75 08             	mov    0x8(%ebp),%esi
f01044bb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01044be:	8b 45 10             	mov    0x10(%ebp),%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f01044c1:	85 c0                	test   %eax,%eax
f01044c3:	74 22                	je     f01044e7 <strlcpy+0x34>
f01044c5:	8d 44 06 ff          	lea    -0x1(%esi,%eax,1),%eax
f01044c9:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
f01044cb:	39 c2                	cmp    %eax,%edx
f01044cd:	74 0f                	je     f01044de <strlcpy+0x2b>
f01044cf:	8a 19                	mov    (%ecx),%bl
f01044d1:	84 db                	test   %bl,%bl
f01044d3:	74 07                	je     f01044dc <strlcpy+0x29>
			*dst++ = *src++;
f01044d5:	41                   	inc    %ecx
f01044d6:	42                   	inc    %edx
f01044d7:	88 5a ff             	mov    %bl,-0x1(%edx)
f01044da:	eb ef                	jmp    f01044cb <strlcpy+0x18>
f01044dc:	89 d0                	mov    %edx,%eax
		*dst = '\0';
f01044de:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f01044e1:	29 f0                	sub    %esi,%eax
}
f01044e3:	5b                   	pop    %ebx
f01044e4:	5e                   	pop    %esi
f01044e5:	5d                   	pop    %ebp
f01044e6:	c3                   	ret    
f01044e7:	89 f0                	mov    %esi,%eax
f01044e9:	eb f6                	jmp    f01044e1 <strlcpy+0x2e>

f01044eb <strcmp>:

int
strcmp(const char *p, const char *q)
{
f01044eb:	55                   	push   %ebp
f01044ec:	89 e5                	mov    %esp,%ebp
f01044ee:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01044f1:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f01044f4:	8a 01                	mov    (%ecx),%al
f01044f6:	84 c0                	test   %al,%al
f01044f8:	74 08                	je     f0104502 <strcmp+0x17>
f01044fa:	3a 02                	cmp    (%edx),%al
f01044fc:	75 04                	jne    f0104502 <strcmp+0x17>
		p++, q++;
f01044fe:	41                   	inc    %ecx
f01044ff:	42                   	inc    %edx
f0104500:	eb f2                	jmp    f01044f4 <strcmp+0x9>
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0104502:	0f b6 c0             	movzbl %al,%eax
f0104505:	0f b6 12             	movzbl (%edx),%edx
f0104508:	29 d0                	sub    %edx,%eax
}
f010450a:	5d                   	pop    %ebp
f010450b:	c3                   	ret    

f010450c <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f010450c:	55                   	push   %ebp
f010450d:	89 e5                	mov    %esp,%ebp
f010450f:	53                   	push   %ebx
f0104510:	8b 45 08             	mov    0x8(%ebp),%eax
f0104513:	8b 55 0c             	mov    0xc(%ebp),%edx
f0104516:	89 c3                	mov    %eax,%ebx
f0104518:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f010451b:	eb 02                	jmp    f010451f <strncmp+0x13>
		n--, p++, q++;
f010451d:	40                   	inc    %eax
f010451e:	42                   	inc    %edx
	while (n > 0 && *p && *p == *q)
f010451f:	39 d8                	cmp    %ebx,%eax
f0104521:	74 15                	je     f0104538 <strncmp+0x2c>
f0104523:	8a 08                	mov    (%eax),%cl
f0104525:	84 c9                	test   %cl,%cl
f0104527:	74 04                	je     f010452d <strncmp+0x21>
f0104529:	3a 0a                	cmp    (%edx),%cl
f010452b:	74 f0                	je     f010451d <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f010452d:	0f b6 00             	movzbl (%eax),%eax
f0104530:	0f b6 12             	movzbl (%edx),%edx
f0104533:	29 d0                	sub    %edx,%eax
}
f0104535:	5b                   	pop    %ebx
f0104536:	5d                   	pop    %ebp
f0104537:	c3                   	ret    
		return 0;
f0104538:	b8 00 00 00 00       	mov    $0x0,%eax
f010453d:	eb f6                	jmp    f0104535 <strncmp+0x29>

f010453f <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f010453f:	55                   	push   %ebp
f0104540:	89 e5                	mov    %esp,%ebp
f0104542:	8b 45 08             	mov    0x8(%ebp),%eax
f0104545:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
f0104548:	8a 10                	mov    (%eax),%dl
f010454a:	84 d2                	test   %dl,%dl
f010454c:	74 07                	je     f0104555 <strchr+0x16>
		if (*s == c)
f010454e:	38 ca                	cmp    %cl,%dl
f0104550:	74 08                	je     f010455a <strchr+0x1b>
	for (; *s; s++)
f0104552:	40                   	inc    %eax
f0104553:	eb f3                	jmp    f0104548 <strchr+0x9>
			return (char *) s;
	return 0;
f0104555:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010455a:	5d                   	pop    %ebp
f010455b:	c3                   	ret    

f010455c <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f010455c:	55                   	push   %ebp
f010455d:	89 e5                	mov    %esp,%ebp
f010455f:	8b 45 08             	mov    0x8(%ebp),%eax
f0104562:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
f0104565:	8a 10                	mov    (%eax),%dl
f0104567:	84 d2                	test   %dl,%dl
f0104569:	74 07                	je     f0104572 <strfind+0x16>
		if (*s == c)
f010456b:	38 ca                	cmp    %cl,%dl
f010456d:	74 03                	je     f0104572 <strfind+0x16>
	for (; *s; s++)
f010456f:	40                   	inc    %eax
f0104570:	eb f3                	jmp    f0104565 <strfind+0x9>
			break;
	return (char *) s;
}
f0104572:	5d                   	pop    %ebp
f0104573:	c3                   	ret    

f0104574 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0104574:	55                   	push   %ebp
f0104575:	89 e5                	mov    %esp,%ebp
f0104577:	57                   	push   %edi
f0104578:	56                   	push   %esi
f0104579:	53                   	push   %ebx
f010457a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f010457d:	85 c9                	test   %ecx,%ecx
f010457f:	74 36                	je     f01045b7 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0104581:	89 c8                	mov    %ecx,%eax
f0104583:	0b 45 08             	or     0x8(%ebp),%eax
f0104586:	a8 03                	test   $0x3,%al
f0104588:	75 24                	jne    f01045ae <memset+0x3a>
		c &= 0xFF;
f010458a:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f010458e:	89 d3                	mov    %edx,%ebx
f0104590:	c1 e3 08             	shl    $0x8,%ebx
f0104593:	89 d0                	mov    %edx,%eax
f0104595:	c1 e0 18             	shl    $0x18,%eax
f0104598:	89 d6                	mov    %edx,%esi
f010459a:	c1 e6 10             	shl    $0x10,%esi
f010459d:	09 f0                	or     %esi,%eax
f010459f:	09 d0                	or     %edx,%eax
f01045a1:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f01045a3:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
f01045a6:	8b 7d 08             	mov    0x8(%ebp),%edi
f01045a9:	fc                   	cld    
f01045aa:	f3 ab                	rep stos %eax,%es:(%edi)
f01045ac:	eb 09                	jmp    f01045b7 <memset+0x43>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f01045ae:	8b 7d 08             	mov    0x8(%ebp),%edi
f01045b1:	8b 45 0c             	mov    0xc(%ebp),%eax
f01045b4:	fc                   	cld    
f01045b5:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f01045b7:	8b 45 08             	mov    0x8(%ebp),%eax
f01045ba:	5b                   	pop    %ebx
f01045bb:	5e                   	pop    %esi
f01045bc:	5f                   	pop    %edi
f01045bd:	5d                   	pop    %ebp
f01045be:	c3                   	ret    

f01045bf <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f01045bf:	55                   	push   %ebp
f01045c0:	89 e5                	mov    %esp,%ebp
f01045c2:	57                   	push   %edi
f01045c3:	56                   	push   %esi
f01045c4:	8b 45 08             	mov    0x8(%ebp),%eax
f01045c7:	8b 75 0c             	mov    0xc(%ebp),%esi
f01045ca:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f01045cd:	39 c6                	cmp    %eax,%esi
f01045cf:	73 30                	jae    f0104601 <memmove+0x42>
f01045d1:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f01045d4:	39 c2                	cmp    %eax,%edx
f01045d6:	76 29                	jbe    f0104601 <memmove+0x42>
		s += n;
		d += n;
f01045d8:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01045db:	89 fe                	mov    %edi,%esi
f01045dd:	09 ce                	or     %ecx,%esi
f01045df:	09 d6                	or     %edx,%esi
f01045e1:	f7 c6 03 00 00 00    	test   $0x3,%esi
f01045e7:	75 0e                	jne    f01045f7 <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f01045e9:	83 ef 04             	sub    $0x4,%edi
f01045ec:	8d 72 fc             	lea    -0x4(%edx),%esi
f01045ef:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
f01045f2:	fd                   	std    
f01045f3:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01045f5:	eb 07                	jmp    f01045fe <memmove+0x3f>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f01045f7:	4f                   	dec    %edi
f01045f8:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
f01045fb:	fd                   	std    
f01045fc:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f01045fe:	fc                   	cld    
f01045ff:	eb 1a                	jmp    f010461b <memmove+0x5c>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0104601:	89 c2                	mov    %eax,%edx
f0104603:	09 ca                	or     %ecx,%edx
f0104605:	09 f2                	or     %esi,%edx
f0104607:	f6 c2 03             	test   $0x3,%dl
f010460a:	75 0a                	jne    f0104616 <memmove+0x57>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f010460c:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
f010460f:	89 c7                	mov    %eax,%edi
f0104611:	fc                   	cld    
f0104612:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0104614:	eb 05                	jmp    f010461b <memmove+0x5c>
		else
			asm volatile("cld; rep movsb\n"
f0104616:	89 c7                	mov    %eax,%edi
f0104618:	fc                   	cld    
f0104619:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f010461b:	5e                   	pop    %esi
f010461c:	5f                   	pop    %edi
f010461d:	5d                   	pop    %ebp
f010461e:	c3                   	ret    

f010461f <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f010461f:	55                   	push   %ebp
f0104620:	89 e5                	mov    %esp,%ebp
f0104622:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f0104625:	ff 75 10             	pushl  0x10(%ebp)
f0104628:	ff 75 0c             	pushl  0xc(%ebp)
f010462b:	ff 75 08             	pushl  0x8(%ebp)
f010462e:	e8 8c ff ff ff       	call   f01045bf <memmove>
}
f0104633:	c9                   	leave  
f0104634:	c3                   	ret    

f0104635 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0104635:	55                   	push   %ebp
f0104636:	89 e5                	mov    %esp,%ebp
f0104638:	56                   	push   %esi
f0104639:	53                   	push   %ebx
f010463a:	8b 45 08             	mov    0x8(%ebp),%eax
f010463d:	8b 55 0c             	mov    0xc(%ebp),%edx
f0104640:	89 c6                	mov    %eax,%esi
f0104642:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0104645:	39 f0                	cmp    %esi,%eax
f0104647:	74 16                	je     f010465f <memcmp+0x2a>
		if (*s1 != *s2)
f0104649:	8a 08                	mov    (%eax),%cl
f010464b:	8a 1a                	mov    (%edx),%bl
f010464d:	38 d9                	cmp    %bl,%cl
f010464f:	75 04                	jne    f0104655 <memcmp+0x20>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
f0104651:	40                   	inc    %eax
f0104652:	42                   	inc    %edx
f0104653:	eb f0                	jmp    f0104645 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
f0104655:	0f b6 c1             	movzbl %cl,%eax
f0104658:	0f b6 db             	movzbl %bl,%ebx
f010465b:	29 d8                	sub    %ebx,%eax
f010465d:	eb 05                	jmp    f0104664 <memcmp+0x2f>
	}

	return 0;
f010465f:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0104664:	5b                   	pop    %ebx
f0104665:	5e                   	pop    %esi
f0104666:	5d                   	pop    %ebp
f0104667:	c3                   	ret    

f0104668 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0104668:	55                   	push   %ebp
f0104669:	89 e5                	mov    %esp,%ebp
f010466b:	8b 45 08             	mov    0x8(%ebp),%eax
f010466e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f0104671:	89 c2                	mov    %eax,%edx
f0104673:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f0104676:	39 d0                	cmp    %edx,%eax
f0104678:	73 07                	jae    f0104681 <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
f010467a:	38 08                	cmp    %cl,(%eax)
f010467c:	74 03                	je     f0104681 <memfind+0x19>
	for (; s < ends; s++)
f010467e:	40                   	inc    %eax
f010467f:	eb f5                	jmp    f0104676 <memfind+0xe>
			break;
	return (void *) s;
}
f0104681:	5d                   	pop    %ebp
f0104682:	c3                   	ret    

f0104683 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0104683:	55                   	push   %ebp
f0104684:	89 e5                	mov    %esp,%ebp
f0104686:	57                   	push   %edi
f0104687:	56                   	push   %esi
f0104688:	53                   	push   %ebx
f0104689:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010468c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f010468f:	eb 01                	jmp    f0104692 <strtol+0xf>
		s++;
f0104691:	41                   	inc    %ecx
	while (*s == ' ' || *s == '\t')
f0104692:	8a 01                	mov    (%ecx),%al
f0104694:	3c 20                	cmp    $0x20,%al
f0104696:	74 f9                	je     f0104691 <strtol+0xe>
f0104698:	3c 09                	cmp    $0x9,%al
f010469a:	74 f5                	je     f0104691 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
f010469c:	3c 2b                	cmp    $0x2b,%al
f010469e:	74 24                	je     f01046c4 <strtol+0x41>
		s++;
	else if (*s == '-')
f01046a0:	3c 2d                	cmp    $0x2d,%al
f01046a2:	74 28                	je     f01046cc <strtol+0x49>
	int neg = 0;
f01046a4:	bf 00 00 00 00       	mov    $0x0,%edi
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f01046a9:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f01046af:	75 09                	jne    f01046ba <strtol+0x37>
f01046b1:	80 39 30             	cmpb   $0x30,(%ecx)
f01046b4:	74 1e                	je     f01046d4 <strtol+0x51>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f01046b6:	85 db                	test   %ebx,%ebx
f01046b8:	74 36                	je     f01046f0 <strtol+0x6d>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f01046ba:	b8 00 00 00 00       	mov    $0x0,%eax
f01046bf:	89 5d 10             	mov    %ebx,0x10(%ebp)
f01046c2:	eb 45                	jmp    f0104709 <strtol+0x86>
		s++;
f01046c4:	41                   	inc    %ecx
	int neg = 0;
f01046c5:	bf 00 00 00 00       	mov    $0x0,%edi
f01046ca:	eb dd                	jmp    f01046a9 <strtol+0x26>
		s++, neg = 1;
f01046cc:	41                   	inc    %ecx
f01046cd:	bf 01 00 00 00       	mov    $0x1,%edi
f01046d2:	eb d5                	jmp    f01046a9 <strtol+0x26>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f01046d4:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f01046d8:	74 0c                	je     f01046e6 <strtol+0x63>
	else if (base == 0 && s[0] == '0')
f01046da:	85 db                	test   %ebx,%ebx
f01046dc:	75 dc                	jne    f01046ba <strtol+0x37>
		s++, base = 8;
f01046de:	41                   	inc    %ecx
f01046df:	bb 08 00 00 00       	mov    $0x8,%ebx
f01046e4:	eb d4                	jmp    f01046ba <strtol+0x37>
		s += 2, base = 16;
f01046e6:	83 c1 02             	add    $0x2,%ecx
f01046e9:	bb 10 00 00 00       	mov    $0x10,%ebx
f01046ee:	eb ca                	jmp    f01046ba <strtol+0x37>
		base = 10;
f01046f0:	bb 0a 00 00 00       	mov    $0xa,%ebx
f01046f5:	eb c3                	jmp    f01046ba <strtol+0x37>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
f01046f7:	0f be d2             	movsbl %dl,%edx
f01046fa:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f01046fd:	3b 55 10             	cmp    0x10(%ebp),%edx
f0104700:	7d 37                	jge    f0104739 <strtol+0xb6>
			break;
		s++, val = (val * base) + dig;
f0104702:	41                   	inc    %ecx
f0104703:	0f af 45 10          	imul   0x10(%ebp),%eax
f0104707:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
f0104709:	8a 11                	mov    (%ecx),%dl
f010470b:	8d 72 d0             	lea    -0x30(%edx),%esi
f010470e:	89 f3                	mov    %esi,%ebx
f0104710:	80 fb 09             	cmp    $0x9,%bl
f0104713:	76 e2                	jbe    f01046f7 <strtol+0x74>
		else if (*s >= 'a' && *s <= 'z')
f0104715:	8d 72 9f             	lea    -0x61(%edx),%esi
f0104718:	89 f3                	mov    %esi,%ebx
f010471a:	80 fb 19             	cmp    $0x19,%bl
f010471d:	77 08                	ja     f0104727 <strtol+0xa4>
			dig = *s - 'a' + 10;
f010471f:	0f be d2             	movsbl %dl,%edx
f0104722:	83 ea 57             	sub    $0x57,%edx
f0104725:	eb d6                	jmp    f01046fd <strtol+0x7a>
		else if (*s >= 'A' && *s <= 'Z')
f0104727:	8d 72 bf             	lea    -0x41(%edx),%esi
f010472a:	89 f3                	mov    %esi,%ebx
f010472c:	80 fb 19             	cmp    $0x19,%bl
f010472f:	77 08                	ja     f0104739 <strtol+0xb6>
			dig = *s - 'A' + 10;
f0104731:	0f be d2             	movsbl %dl,%edx
f0104734:	83 ea 37             	sub    $0x37,%edx
f0104737:	eb c4                	jmp    f01046fd <strtol+0x7a>
		// we don't properly detect overflow!
	}

	if (endptr)
f0104739:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f010473d:	74 05                	je     f0104744 <strtol+0xc1>
		*endptr = (char *) s;
f010473f:	8b 75 0c             	mov    0xc(%ebp),%esi
f0104742:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
f0104744:	85 ff                	test   %edi,%edi
f0104746:	74 02                	je     f010474a <strtol+0xc7>
f0104748:	f7 d8                	neg    %eax
}
f010474a:	5b                   	pop    %ebx
f010474b:	5e                   	pop    %esi
f010474c:	5f                   	pop    %edi
f010474d:	5d                   	pop    %ebp
f010474e:	c3                   	ret    
f010474f:	90                   	nop

f0104750 <__udivdi3>:
f0104750:	55                   	push   %ebp
f0104751:	57                   	push   %edi
f0104752:	56                   	push   %esi
f0104753:	53                   	push   %ebx
f0104754:	83 ec 1c             	sub    $0x1c,%esp
f0104757:	8b 6c 24 30          	mov    0x30(%esp),%ebp
f010475b:	8b 74 24 34          	mov    0x34(%esp),%esi
f010475f:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0104763:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f0104767:	85 d2                	test   %edx,%edx
f0104769:	75 19                	jne    f0104784 <__udivdi3+0x34>
f010476b:	39 f7                	cmp    %esi,%edi
f010476d:	76 45                	jbe    f01047b4 <__udivdi3+0x64>
f010476f:	89 e8                	mov    %ebp,%eax
f0104771:	89 f2                	mov    %esi,%edx
f0104773:	f7 f7                	div    %edi
f0104775:	31 db                	xor    %ebx,%ebx
f0104777:	89 da                	mov    %ebx,%edx
f0104779:	83 c4 1c             	add    $0x1c,%esp
f010477c:	5b                   	pop    %ebx
f010477d:	5e                   	pop    %esi
f010477e:	5f                   	pop    %edi
f010477f:	5d                   	pop    %ebp
f0104780:	c3                   	ret    
f0104781:	8d 76 00             	lea    0x0(%esi),%esi
f0104784:	39 f2                	cmp    %esi,%edx
f0104786:	76 10                	jbe    f0104798 <__udivdi3+0x48>
f0104788:	31 db                	xor    %ebx,%ebx
f010478a:	31 c0                	xor    %eax,%eax
f010478c:	89 da                	mov    %ebx,%edx
f010478e:	83 c4 1c             	add    $0x1c,%esp
f0104791:	5b                   	pop    %ebx
f0104792:	5e                   	pop    %esi
f0104793:	5f                   	pop    %edi
f0104794:	5d                   	pop    %ebp
f0104795:	c3                   	ret    
f0104796:	66 90                	xchg   %ax,%ax
f0104798:	0f bd da             	bsr    %edx,%ebx
f010479b:	83 f3 1f             	xor    $0x1f,%ebx
f010479e:	75 3c                	jne    f01047dc <__udivdi3+0x8c>
f01047a0:	39 f2                	cmp    %esi,%edx
f01047a2:	72 08                	jb     f01047ac <__udivdi3+0x5c>
f01047a4:	39 ef                	cmp    %ebp,%edi
f01047a6:	0f 87 9c 00 00 00    	ja     f0104848 <__udivdi3+0xf8>
f01047ac:	b8 01 00 00 00       	mov    $0x1,%eax
f01047b1:	eb d9                	jmp    f010478c <__udivdi3+0x3c>
f01047b3:	90                   	nop
f01047b4:	89 f9                	mov    %edi,%ecx
f01047b6:	85 ff                	test   %edi,%edi
f01047b8:	75 0b                	jne    f01047c5 <__udivdi3+0x75>
f01047ba:	b8 01 00 00 00       	mov    $0x1,%eax
f01047bf:	31 d2                	xor    %edx,%edx
f01047c1:	f7 f7                	div    %edi
f01047c3:	89 c1                	mov    %eax,%ecx
f01047c5:	31 d2                	xor    %edx,%edx
f01047c7:	89 f0                	mov    %esi,%eax
f01047c9:	f7 f1                	div    %ecx
f01047cb:	89 c3                	mov    %eax,%ebx
f01047cd:	89 e8                	mov    %ebp,%eax
f01047cf:	f7 f1                	div    %ecx
f01047d1:	89 da                	mov    %ebx,%edx
f01047d3:	83 c4 1c             	add    $0x1c,%esp
f01047d6:	5b                   	pop    %ebx
f01047d7:	5e                   	pop    %esi
f01047d8:	5f                   	pop    %edi
f01047d9:	5d                   	pop    %ebp
f01047da:	c3                   	ret    
f01047db:	90                   	nop
f01047dc:	b8 20 00 00 00       	mov    $0x20,%eax
f01047e1:	29 d8                	sub    %ebx,%eax
f01047e3:	88 d9                	mov    %bl,%cl
f01047e5:	d3 e2                	shl    %cl,%edx
f01047e7:	89 54 24 08          	mov    %edx,0x8(%esp)
f01047eb:	89 fa                	mov    %edi,%edx
f01047ed:	88 c1                	mov    %al,%cl
f01047ef:	d3 ea                	shr    %cl,%edx
f01047f1:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f01047f5:	09 d1                	or     %edx,%ecx
f01047f7:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01047fb:	88 d9                	mov    %bl,%cl
f01047fd:	d3 e7                	shl    %cl,%edi
f01047ff:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0104803:	89 f7                	mov    %esi,%edi
f0104805:	88 c1                	mov    %al,%cl
f0104807:	d3 ef                	shr    %cl,%edi
f0104809:	88 d9                	mov    %bl,%cl
f010480b:	d3 e6                	shl    %cl,%esi
f010480d:	89 ea                	mov    %ebp,%edx
f010480f:	88 c1                	mov    %al,%cl
f0104811:	d3 ea                	shr    %cl,%edx
f0104813:	09 d6                	or     %edx,%esi
f0104815:	89 f0                	mov    %esi,%eax
f0104817:	89 fa                	mov    %edi,%edx
f0104819:	f7 74 24 08          	divl   0x8(%esp)
f010481d:	89 d7                	mov    %edx,%edi
f010481f:	89 c6                	mov    %eax,%esi
f0104821:	f7 64 24 0c          	mull   0xc(%esp)
f0104825:	39 d7                	cmp    %edx,%edi
f0104827:	72 13                	jb     f010483c <__udivdi3+0xec>
f0104829:	74 09                	je     f0104834 <__udivdi3+0xe4>
f010482b:	89 f0                	mov    %esi,%eax
f010482d:	31 db                	xor    %ebx,%ebx
f010482f:	e9 58 ff ff ff       	jmp    f010478c <__udivdi3+0x3c>
f0104834:	88 d9                	mov    %bl,%cl
f0104836:	d3 e5                	shl    %cl,%ebp
f0104838:	39 c5                	cmp    %eax,%ebp
f010483a:	73 ef                	jae    f010482b <__udivdi3+0xdb>
f010483c:	8d 46 ff             	lea    -0x1(%esi),%eax
f010483f:	31 db                	xor    %ebx,%ebx
f0104841:	e9 46 ff ff ff       	jmp    f010478c <__udivdi3+0x3c>
f0104846:	66 90                	xchg   %ax,%ax
f0104848:	31 c0                	xor    %eax,%eax
f010484a:	e9 3d ff ff ff       	jmp    f010478c <__udivdi3+0x3c>
f010484f:	90                   	nop

f0104850 <__umoddi3>:
f0104850:	55                   	push   %ebp
f0104851:	57                   	push   %edi
f0104852:	56                   	push   %esi
f0104853:	53                   	push   %ebx
f0104854:	83 ec 1c             	sub    $0x1c,%esp
f0104857:	8b 74 24 30          	mov    0x30(%esp),%esi
f010485b:	8b 5c 24 34          	mov    0x34(%esp),%ebx
f010485f:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0104863:	8b 44 24 3c          	mov    0x3c(%esp),%eax
f0104867:	85 c0                	test   %eax,%eax
f0104869:	75 19                	jne    f0104884 <__umoddi3+0x34>
f010486b:	39 df                	cmp    %ebx,%edi
f010486d:	76 51                	jbe    f01048c0 <__umoddi3+0x70>
f010486f:	89 f0                	mov    %esi,%eax
f0104871:	89 da                	mov    %ebx,%edx
f0104873:	f7 f7                	div    %edi
f0104875:	89 d0                	mov    %edx,%eax
f0104877:	31 d2                	xor    %edx,%edx
f0104879:	83 c4 1c             	add    $0x1c,%esp
f010487c:	5b                   	pop    %ebx
f010487d:	5e                   	pop    %esi
f010487e:	5f                   	pop    %edi
f010487f:	5d                   	pop    %ebp
f0104880:	c3                   	ret    
f0104881:	8d 76 00             	lea    0x0(%esi),%esi
f0104884:	89 f2                	mov    %esi,%edx
f0104886:	39 d8                	cmp    %ebx,%eax
f0104888:	76 0e                	jbe    f0104898 <__umoddi3+0x48>
f010488a:	89 f0                	mov    %esi,%eax
f010488c:	89 da                	mov    %ebx,%edx
f010488e:	83 c4 1c             	add    $0x1c,%esp
f0104891:	5b                   	pop    %ebx
f0104892:	5e                   	pop    %esi
f0104893:	5f                   	pop    %edi
f0104894:	5d                   	pop    %ebp
f0104895:	c3                   	ret    
f0104896:	66 90                	xchg   %ax,%ax
f0104898:	0f bd e8             	bsr    %eax,%ebp
f010489b:	83 f5 1f             	xor    $0x1f,%ebp
f010489e:	75 44                	jne    f01048e4 <__umoddi3+0x94>
f01048a0:	39 d8                	cmp    %ebx,%eax
f01048a2:	72 06                	jb     f01048aa <__umoddi3+0x5a>
f01048a4:	89 d9                	mov    %ebx,%ecx
f01048a6:	39 f7                	cmp    %esi,%edi
f01048a8:	77 08                	ja     f01048b2 <__umoddi3+0x62>
f01048aa:	29 fe                	sub    %edi,%esi
f01048ac:	19 c3                	sbb    %eax,%ebx
f01048ae:	89 f2                	mov    %esi,%edx
f01048b0:	89 d9                	mov    %ebx,%ecx
f01048b2:	89 d0                	mov    %edx,%eax
f01048b4:	89 ca                	mov    %ecx,%edx
f01048b6:	83 c4 1c             	add    $0x1c,%esp
f01048b9:	5b                   	pop    %ebx
f01048ba:	5e                   	pop    %esi
f01048bb:	5f                   	pop    %edi
f01048bc:	5d                   	pop    %ebp
f01048bd:	c3                   	ret    
f01048be:	66 90                	xchg   %ax,%ax
f01048c0:	89 fd                	mov    %edi,%ebp
f01048c2:	85 ff                	test   %edi,%edi
f01048c4:	75 0b                	jne    f01048d1 <__umoddi3+0x81>
f01048c6:	b8 01 00 00 00       	mov    $0x1,%eax
f01048cb:	31 d2                	xor    %edx,%edx
f01048cd:	f7 f7                	div    %edi
f01048cf:	89 c5                	mov    %eax,%ebp
f01048d1:	89 d8                	mov    %ebx,%eax
f01048d3:	31 d2                	xor    %edx,%edx
f01048d5:	f7 f5                	div    %ebp
f01048d7:	89 f0                	mov    %esi,%eax
f01048d9:	f7 f5                	div    %ebp
f01048db:	89 d0                	mov    %edx,%eax
f01048dd:	31 d2                	xor    %edx,%edx
f01048df:	eb 98                	jmp    f0104879 <__umoddi3+0x29>
f01048e1:	8d 76 00             	lea    0x0(%esi),%esi
f01048e4:	ba 20 00 00 00       	mov    $0x20,%edx
f01048e9:	29 ea                	sub    %ebp,%edx
f01048eb:	89 e9                	mov    %ebp,%ecx
f01048ed:	d3 e0                	shl    %cl,%eax
f01048ef:	89 44 24 08          	mov    %eax,0x8(%esp)
f01048f3:	89 f8                	mov    %edi,%eax
f01048f5:	89 54 24 04          	mov    %edx,0x4(%esp)
f01048f9:	88 d1                	mov    %dl,%cl
f01048fb:	d3 e8                	shr    %cl,%eax
f01048fd:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f0104901:	09 c1                	or     %eax,%ecx
f0104903:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0104907:	89 e9                	mov    %ebp,%ecx
f0104909:	d3 e7                	shl    %cl,%edi
f010490b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f010490f:	89 d8                	mov    %ebx,%eax
f0104911:	8b 54 24 04          	mov    0x4(%esp),%edx
f0104915:	88 d1                	mov    %dl,%cl
f0104917:	d3 e8                	shr    %cl,%eax
f0104919:	89 c7                	mov    %eax,%edi
f010491b:	89 e9                	mov    %ebp,%ecx
f010491d:	d3 e3                	shl    %cl,%ebx
f010491f:	89 f0                	mov    %esi,%eax
f0104921:	88 d1                	mov    %dl,%cl
f0104923:	d3 e8                	shr    %cl,%eax
f0104925:	09 d8                	or     %ebx,%eax
f0104927:	89 e9                	mov    %ebp,%ecx
f0104929:	d3 e6                	shl    %cl,%esi
f010492b:	89 f3                	mov    %esi,%ebx
f010492d:	89 fa                	mov    %edi,%edx
f010492f:	f7 74 24 08          	divl   0x8(%esp)
f0104933:	89 d1                	mov    %edx,%ecx
f0104935:	f7 64 24 0c          	mull   0xc(%esp)
f0104939:	89 c6                	mov    %eax,%esi
f010493b:	89 d7                	mov    %edx,%edi
f010493d:	39 d1                	cmp    %edx,%ecx
f010493f:	72 27                	jb     f0104968 <__umoddi3+0x118>
f0104941:	74 21                	je     f0104964 <__umoddi3+0x114>
f0104943:	89 ca                	mov    %ecx,%edx
f0104945:	29 f3                	sub    %esi,%ebx
f0104947:	19 fa                	sbb    %edi,%edx
f0104949:	89 d0                	mov    %edx,%eax
f010494b:	8a 4c 24 04          	mov    0x4(%esp),%cl
f010494f:	d3 e0                	shl    %cl,%eax
f0104951:	89 e9                	mov    %ebp,%ecx
f0104953:	d3 eb                	shr    %cl,%ebx
f0104955:	09 d8                	or     %ebx,%eax
f0104957:	d3 ea                	shr    %cl,%edx
f0104959:	83 c4 1c             	add    $0x1c,%esp
f010495c:	5b                   	pop    %ebx
f010495d:	5e                   	pop    %esi
f010495e:	5f                   	pop    %edi
f010495f:	5d                   	pop    %ebp
f0104960:	c3                   	ret    
f0104961:	8d 76 00             	lea    0x0(%esi),%esi
f0104964:	39 c3                	cmp    %eax,%ebx
f0104966:	73 db                	jae    f0104943 <__umoddi3+0xf3>
f0104968:	2b 44 24 0c          	sub    0xc(%esp),%eax
f010496c:	1b 54 24 08          	sbb    0x8(%esp),%edx
f0104970:	89 d7                	mov    %edx,%edi
f0104972:	89 c6                	mov    %eax,%esi
f0104974:	eb cd                	jmp    f0104943 <__umoddi3+0xf3>
