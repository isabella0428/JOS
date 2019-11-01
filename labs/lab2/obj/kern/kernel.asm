
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
f0100015:	b8 00 60 11 00       	mov    $0x116000,%eax
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
f0100034:	bc 00 60 11 f0       	mov    $0xf0116000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 02 00 00 00       	call   f0100040 <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <i386_init>:
#include <kern/kclock.h>


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
f0100046:	b8 60 89 11 f0       	mov    $0xf0118960,%eax
f010004b:	2d 00 83 11 f0       	sub    $0xf0118300,%eax
f0100050:	50                   	push   %eax
f0100051:	6a 00                	push   $0x0
f0100053:	68 00 83 11 f0       	push   $0xf0118300
f0100058:	e8 ef 31 00 00       	call   f010324c <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f010005d:	e8 6c 04 00 00       	call   f01004ce <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f0100062:	83 c4 08             	add    $0x8,%esp
f0100065:	68 ac 1a 00 00       	push   $0x1aac
f010006a:	68 60 36 10 f0       	push   $0xf0103660
f010006f:	e8 48 27 00 00       	call   f01027bc <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f0100074:	e8 ba 0e 00 00       	call   f0100f33 <mem_init>
f0100079:	83 c4 10             	add    $0x10,%esp

	// Drop into the kernel monitor.
	while (1)
		monitor(NULL);
f010007c:	83 ec 0c             	sub    $0xc,%esp
f010007f:	6a 00                	push   $0x0
f0100081:	e8 45 06 00 00       	call   f01006cb <monitor>
f0100086:	83 c4 10             	add    $0x10,%esp
f0100089:	eb f1                	jmp    f010007c <i386_init+0x3c>

f010008b <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f010008b:	55                   	push   %ebp
f010008c:	89 e5                	mov    %esp,%ebp
f010008e:	56                   	push   %esi
f010008f:	53                   	push   %ebx
f0100090:	8b 75 10             	mov    0x10(%ebp),%esi
	va_list ap;

	if (panicstr)
f0100093:	83 3d 64 89 11 f0 00 	cmpl   $0x0,0xf0118964
f010009a:	74 0f                	je     f01000ab <_panic+0x20>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f010009c:	83 ec 0c             	sub    $0xc,%esp
f010009f:	6a 00                	push   $0x0
f01000a1:	e8 25 06 00 00       	call   f01006cb <monitor>
f01000a6:	83 c4 10             	add    $0x10,%esp
f01000a9:	eb f1                	jmp    f010009c <_panic+0x11>
	panicstr = fmt;
f01000ab:	89 35 64 89 11 f0    	mov    %esi,0xf0118964
	asm volatile("cli; cld");
f01000b1:	fa                   	cli    
f01000b2:	fc                   	cld    
	va_start(ap, fmt);
f01000b3:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic at %s:%d: ", file, line);
f01000b6:	83 ec 04             	sub    $0x4,%esp
f01000b9:	ff 75 0c             	pushl  0xc(%ebp)
f01000bc:	ff 75 08             	pushl  0x8(%ebp)
f01000bf:	68 7b 36 10 f0       	push   $0xf010367b
f01000c4:	e8 f3 26 00 00       	call   f01027bc <cprintf>
	vcprintf(fmt, ap);
f01000c9:	83 c4 08             	add    $0x8,%esp
f01000cc:	53                   	push   %ebx
f01000cd:	56                   	push   %esi
f01000ce:	e8 c3 26 00 00       	call   f0102796 <vcprintf>
	cprintf("\n");
f01000d3:	c7 04 24 d3 3d 10 f0 	movl   $0xf0103dd3,(%esp)
f01000da:	e8 dd 26 00 00       	call   f01027bc <cprintf>
f01000df:	83 c4 10             	add    $0x10,%esp
f01000e2:	eb b8                	jmp    f010009c <_panic+0x11>

f01000e4 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f01000e4:	55                   	push   %ebp
f01000e5:	89 e5                	mov    %esp,%ebp
f01000e7:	53                   	push   %ebx
f01000e8:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f01000eb:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f01000ee:	ff 75 0c             	pushl  0xc(%ebp)
f01000f1:	ff 75 08             	pushl  0x8(%ebp)
f01000f4:	68 93 36 10 f0       	push   $0xf0103693
f01000f9:	e8 be 26 00 00       	call   f01027bc <cprintf>
	vcprintf(fmt, ap);
f01000fe:	83 c4 08             	add    $0x8,%esp
f0100101:	53                   	push   %ebx
f0100102:	ff 75 10             	pushl  0x10(%ebp)
f0100105:	e8 8c 26 00 00       	call   f0102796 <vcprintf>
	cprintf("\n");
f010010a:	c7 04 24 d3 3d 10 f0 	movl   $0xf0103dd3,(%esp)
f0100111:	e8 a6 26 00 00       	call   f01027bc <cprintf>
	va_end(ap);
}
f0100116:	83 c4 10             	add    $0x10,%esp
f0100119:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010011c:	c9                   	leave  
f010011d:	c3                   	ret    

f010011e <serial_proc_data>:

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010011e:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100123:	ec                   	in     (%dx),%al
static bool serial_exists;

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f0100124:	a8 01                	test   $0x1,%al
f0100126:	74 0a                	je     f0100132 <serial_proc_data+0x14>
f0100128:	ba f8 03 00 00       	mov    $0x3f8,%edx
f010012d:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f010012e:	0f b6 c0             	movzbl %al,%eax
f0100131:	c3                   	ret    
		return -1;
f0100132:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
f0100137:	c3                   	ret    

f0100138 <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f0100138:	55                   	push   %ebp
f0100139:	89 e5                	mov    %esp,%ebp
f010013b:	53                   	push   %ebx
f010013c:	83 ec 04             	sub    $0x4,%esp
f010013f:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f0100141:	ff d3                	call   *%ebx
f0100143:	83 f8 ff             	cmp    $0xffffffff,%eax
f0100146:	74 2d                	je     f0100175 <cons_intr+0x3d>
		if (c == 0)
f0100148:	85 c0                	test   %eax,%eax
f010014a:	74 f5                	je     f0100141 <cons_intr+0x9>
			continue;
		cons.buf[cons.wpos++] = c;
f010014c:	8b 0d 24 85 11 f0    	mov    0xf0118524,%ecx
f0100152:	8d 51 01             	lea    0x1(%ecx),%edx
f0100155:	89 15 24 85 11 f0    	mov    %edx,0xf0118524
f010015b:	88 81 20 83 11 f0    	mov    %al,-0xfee7ce0(%ecx)
		if (cons.wpos == CONSBUFSIZE)
f0100161:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f0100167:	75 d8                	jne    f0100141 <cons_intr+0x9>
			cons.wpos = 0;
f0100169:	c7 05 24 85 11 f0 00 	movl   $0x0,0xf0118524
f0100170:	00 00 00 
f0100173:	eb cc                	jmp    f0100141 <cons_intr+0x9>
	}
}
f0100175:	83 c4 04             	add    $0x4,%esp
f0100178:	5b                   	pop    %ebx
f0100179:	5d                   	pop    %ebp
f010017a:	c3                   	ret    

f010017b <kbd_proc_data>:
{
f010017b:	55                   	push   %ebp
f010017c:	89 e5                	mov    %esp,%ebp
f010017e:	53                   	push   %ebx
f010017f:	83 ec 04             	sub    $0x4,%esp
f0100182:	ba 64 00 00 00       	mov    $0x64,%edx
f0100187:	ec                   	in     (%dx),%al
	if ((stat & KBS_DIB) == 0)
f0100188:	a8 01                	test   $0x1,%al
f010018a:	0f 84 e9 00 00 00    	je     f0100279 <kbd_proc_data+0xfe>
	if (stat & KBS_TERR)
f0100190:	a8 20                	test   $0x20,%al
f0100192:	0f 85 e8 00 00 00    	jne    f0100280 <kbd_proc_data+0x105>
f0100198:	ba 60 00 00 00       	mov    $0x60,%edx
f010019d:	ec                   	in     (%dx),%al
f010019e:	88 c2                	mov    %al,%dl
	if (data == 0xE0) {
f01001a0:	3c e0                	cmp    $0xe0,%al
f01001a2:	74 60                	je     f0100204 <kbd_proc_data+0x89>
	} else if (data & 0x80) {
f01001a4:	84 c0                	test   %al,%al
f01001a6:	78 6f                	js     f0100217 <kbd_proc_data+0x9c>
	} else if (shift & E0ESC) {
f01001a8:	8b 0d 00 83 11 f0    	mov    0xf0118300,%ecx
f01001ae:	f6 c1 40             	test   $0x40,%cl
f01001b1:	74 0e                	je     f01001c1 <kbd_proc_data+0x46>
		data |= 0x80;
f01001b3:	83 c8 80             	or     $0xffffff80,%eax
f01001b6:	88 c2                	mov    %al,%dl
		shift &= ~E0ESC;
f01001b8:	83 e1 bf             	and    $0xffffffbf,%ecx
f01001bb:	89 0d 00 83 11 f0    	mov    %ecx,0xf0118300
	shift |= shiftcode[data];
f01001c1:	0f b6 d2             	movzbl %dl,%edx
f01001c4:	0f b6 82 00 38 10 f0 	movzbl -0xfefc800(%edx),%eax
f01001cb:	0b 05 00 83 11 f0    	or     0xf0118300,%eax
	shift ^= togglecode[data];
f01001d1:	0f b6 8a 00 37 10 f0 	movzbl -0xfefc900(%edx),%ecx
f01001d8:	31 c8                	xor    %ecx,%eax
f01001da:	a3 00 83 11 f0       	mov    %eax,0xf0118300
	c = charcode[shift & (CTL | SHIFT)][data];
f01001df:	89 c1                	mov    %eax,%ecx
f01001e1:	83 e1 03             	and    $0x3,%ecx
f01001e4:	8b 0c 8d e0 36 10 f0 	mov    -0xfefc920(,%ecx,4),%ecx
f01001eb:	8a 14 11             	mov    (%ecx,%edx,1),%dl
f01001ee:	0f b6 da             	movzbl %dl,%ebx
	if (shift & CAPSLOCK) {
f01001f1:	a8 08                	test   $0x8,%al
f01001f3:	74 5c                	je     f0100251 <kbd_proc_data+0xd6>
		if ('a' <= c && c <= 'z')
f01001f5:	89 da                	mov    %ebx,%edx
f01001f7:	8d 4b 9f             	lea    -0x61(%ebx),%ecx
f01001fa:	83 f9 19             	cmp    $0x19,%ecx
f01001fd:	77 47                	ja     f0100246 <kbd_proc_data+0xcb>
			c += 'A' - 'a';
f01001ff:	83 eb 20             	sub    $0x20,%ebx
f0100202:	eb 0c                	jmp    f0100210 <kbd_proc_data+0x95>
		shift |= E0ESC;
f0100204:	83 0d 00 83 11 f0 40 	orl    $0x40,0xf0118300
		return 0;
f010020b:	bb 00 00 00 00       	mov    $0x0,%ebx
}
f0100210:	89 d8                	mov    %ebx,%eax
f0100212:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100215:	c9                   	leave  
f0100216:	c3                   	ret    
		data = (shift & E0ESC ? data : data & 0x7F);
f0100217:	8b 0d 00 83 11 f0    	mov    0xf0118300,%ecx
f010021d:	f6 c1 40             	test   $0x40,%cl
f0100220:	75 05                	jne    f0100227 <kbd_proc_data+0xac>
f0100222:	83 e0 7f             	and    $0x7f,%eax
f0100225:	88 c2                	mov    %al,%dl
		shift &= ~(shiftcode[data] | E0ESC);
f0100227:	0f b6 d2             	movzbl %dl,%edx
f010022a:	8a 82 00 38 10 f0    	mov    -0xfefc800(%edx),%al
f0100230:	83 c8 40             	or     $0x40,%eax
f0100233:	0f b6 c0             	movzbl %al,%eax
f0100236:	f7 d0                	not    %eax
f0100238:	21 c8                	and    %ecx,%eax
f010023a:	a3 00 83 11 f0       	mov    %eax,0xf0118300
		return 0;
f010023f:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100244:	eb ca                	jmp    f0100210 <kbd_proc_data+0x95>
		else if ('A' <= c && c <= 'Z')
f0100246:	83 ea 41             	sub    $0x41,%edx
f0100249:	83 fa 19             	cmp    $0x19,%edx
f010024c:	77 03                	ja     f0100251 <kbd_proc_data+0xd6>
			c += 'a' - 'A';
f010024e:	83 c3 20             	add    $0x20,%ebx
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f0100251:	f7 d0                	not    %eax
f0100253:	a8 06                	test   $0x6,%al
f0100255:	75 b9                	jne    f0100210 <kbd_proc_data+0x95>
f0100257:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f010025d:	75 b1                	jne    f0100210 <kbd_proc_data+0x95>
		cprintf("Rebooting!\n");
f010025f:	83 ec 0c             	sub    $0xc,%esp
f0100262:	68 ad 36 10 f0       	push   $0xf01036ad
f0100267:	e8 50 25 00 00       	call   f01027bc <cprintf>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010026c:	b0 03                	mov    $0x3,%al
f010026e:	ba 92 00 00 00       	mov    $0x92,%edx
f0100273:	ee                   	out    %al,(%dx)
}
f0100274:	83 c4 10             	add    $0x10,%esp
f0100277:	eb 97                	jmp    f0100210 <kbd_proc_data+0x95>
		return -1;
f0100279:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
f010027e:	eb 90                	jmp    f0100210 <kbd_proc_data+0x95>
		return -1;
f0100280:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
f0100285:	eb 89                	jmp    f0100210 <kbd_proc_data+0x95>

f0100287 <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f0100287:	55                   	push   %ebp
f0100288:	89 e5                	mov    %esp,%ebp
f010028a:	57                   	push   %edi
f010028b:	56                   	push   %esi
f010028c:	53                   	push   %ebx
f010028d:	83 ec 1c             	sub    $0x1c,%esp
f0100290:	89 c1                	mov    %eax,%ecx
	for (i = 0;
f0100292:	be 01 32 00 00       	mov    $0x3201,%esi
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100297:	bf fd 03 00 00       	mov    $0x3fd,%edi
f010029c:	bb 84 00 00 00       	mov    $0x84,%ebx
f01002a1:	89 fa                	mov    %edi,%edx
f01002a3:	ec                   	in     (%dx),%al
f01002a4:	a8 20                	test   $0x20,%al
f01002a6:	75 0b                	jne    f01002b3 <cons_putc+0x2c>
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f01002a8:	4e                   	dec    %esi
f01002a9:	74 08                	je     f01002b3 <cons_putc+0x2c>
f01002ab:	89 da                	mov    %ebx,%edx
f01002ad:	ec                   	in     (%dx),%al
f01002ae:	ec                   	in     (%dx),%al
f01002af:	ec                   	in     (%dx),%al
f01002b0:	ec                   	in     (%dx),%al
f01002b1:	eb ee                	jmp    f01002a1 <cons_putc+0x1a>
	outb(COM1 + COM_TX, c);
f01002b3:	88 4d e7             	mov    %cl,-0x19(%ebp)
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01002b6:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01002bb:	88 c8                	mov    %cl,%al
f01002bd:	ee                   	out    %al,(%dx)
}
f01002be:	be 01 32 00 00       	mov    $0x3201,%esi
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01002c3:	bf 79 03 00 00       	mov    $0x379,%edi
f01002c8:	bb 84 00 00 00       	mov    $0x84,%ebx
f01002cd:	89 fa                	mov    %edi,%edx
f01002cf:	ec                   	in     (%dx),%al
	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f01002d0:	84 c0                	test   %al,%al
f01002d2:	78 0b                	js     f01002df <cons_putc+0x58>
f01002d4:	4e                   	dec    %esi
f01002d5:	74 08                	je     f01002df <cons_putc+0x58>
f01002d7:	89 da                	mov    %ebx,%edx
f01002d9:	ec                   	in     (%dx),%al
f01002da:	ec                   	in     (%dx),%al
f01002db:	ec                   	in     (%dx),%al
f01002dc:	ec                   	in     (%dx),%al
f01002dd:	eb ee                	jmp    f01002cd <cons_putc+0x46>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01002df:	ba 78 03 00 00       	mov    $0x378,%edx
f01002e4:	8a 45 e7             	mov    -0x19(%ebp),%al
f01002e7:	ee                   	out    %al,(%dx)
f01002e8:	ba 7a 03 00 00       	mov    $0x37a,%edx
f01002ed:	b0 0d                	mov    $0xd,%al
f01002ef:	ee                   	out    %al,(%dx)
f01002f0:	b0 08                	mov    $0x8,%al
f01002f2:	ee                   	out    %al,(%dx)
	if (!(c & ~0xFF))
f01002f3:	f7 c1 00 ff ff ff    	test   $0xffffff00,%ecx
f01002f9:	75 03                	jne    f01002fe <cons_putc+0x77>
		c |= 0x0700;
f01002fb:	80 cd 07             	or     $0x7,%ch
	switch (c & 0xff) {
f01002fe:	0f b6 c1             	movzbl %cl,%eax
f0100301:	80 f9 0a             	cmp    $0xa,%cl
f0100304:	0f 84 d7 00 00 00    	je     f01003e1 <cons_putc+0x15a>
f010030a:	83 f8 0a             	cmp    $0xa,%eax
f010030d:	7f 46                	jg     f0100355 <cons_putc+0xce>
f010030f:	83 f8 08             	cmp    $0x8,%eax
f0100312:	0f 84 a4 00 00 00    	je     f01003bc <cons_putc+0x135>
f0100318:	83 f8 09             	cmp    $0x9,%eax
f010031b:	0f 85 cd 00 00 00    	jne    f01003ee <cons_putc+0x167>
		cons_putc(' ');
f0100321:	b8 20 00 00 00       	mov    $0x20,%eax
f0100326:	e8 5c ff ff ff       	call   f0100287 <cons_putc>
		cons_putc(' ');
f010032b:	b8 20 00 00 00       	mov    $0x20,%eax
f0100330:	e8 52 ff ff ff       	call   f0100287 <cons_putc>
		cons_putc(' ');
f0100335:	b8 20 00 00 00       	mov    $0x20,%eax
f010033a:	e8 48 ff ff ff       	call   f0100287 <cons_putc>
		cons_putc(' ');
f010033f:	b8 20 00 00 00       	mov    $0x20,%eax
f0100344:	e8 3e ff ff ff       	call   f0100287 <cons_putc>
		cons_putc(' ');
f0100349:	b8 20 00 00 00       	mov    $0x20,%eax
f010034e:	e8 34 ff ff ff       	call   f0100287 <cons_putc>
		break;
f0100353:	eb 28                	jmp    f010037d <cons_putc+0xf6>
	switch (c & 0xff) {
f0100355:	83 f8 0d             	cmp    $0xd,%eax
f0100358:	0f 85 90 00 00 00    	jne    f01003ee <cons_putc+0x167>
		crt_pos -= (crt_pos % CRT_COLS);
f010035e:	66 8b 0d 28 85 11 f0 	mov    0xf0118528,%cx
f0100365:	bb 50 00 00 00       	mov    $0x50,%ebx
f010036a:	89 c8                	mov    %ecx,%eax
f010036c:	ba 00 00 00 00       	mov    $0x0,%edx
f0100371:	66 f7 f3             	div    %bx
f0100374:	29 d1                	sub    %edx,%ecx
f0100376:	66 89 0d 28 85 11 f0 	mov    %cx,0xf0118528
	if (crt_pos >= CRT_SIZE) {
f010037d:	66 81 3d 28 85 11 f0 	cmpw   $0x7cf,0xf0118528
f0100384:	cf 07 
f0100386:	0f 87 84 00 00 00    	ja     f0100410 <cons_putc+0x189>
	outb(addr_6845, 14);
f010038c:	8b 0d 30 85 11 f0    	mov    0xf0118530,%ecx
f0100392:	b0 0e                	mov    $0xe,%al
f0100394:	89 ca                	mov    %ecx,%edx
f0100396:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f0100397:	8d 59 01             	lea    0x1(%ecx),%ebx
f010039a:	66 a1 28 85 11 f0    	mov    0xf0118528,%ax
f01003a0:	66 c1 e8 08          	shr    $0x8,%ax
f01003a4:	89 da                	mov    %ebx,%edx
f01003a6:	ee                   	out    %al,(%dx)
f01003a7:	b0 0f                	mov    $0xf,%al
f01003a9:	89 ca                	mov    %ecx,%edx
f01003ab:	ee                   	out    %al,(%dx)
f01003ac:	a0 28 85 11 f0       	mov    0xf0118528,%al
f01003b1:	89 da                	mov    %ebx,%edx
f01003b3:	ee                   	out    %al,(%dx)
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f01003b4:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01003b7:	5b                   	pop    %ebx
f01003b8:	5e                   	pop    %esi
f01003b9:	5f                   	pop    %edi
f01003ba:	5d                   	pop    %ebp
f01003bb:	c3                   	ret    
		if (crt_pos > 0) {
f01003bc:	66 a1 28 85 11 f0    	mov    0xf0118528,%ax
f01003c2:	66 85 c0             	test   %ax,%ax
f01003c5:	74 c5                	je     f010038c <cons_putc+0x105>
			crt_pos--;
f01003c7:	48                   	dec    %eax
f01003c8:	66 a3 28 85 11 f0    	mov    %ax,0xf0118528
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f01003ce:	0f b7 d0             	movzwl %ax,%edx
f01003d1:	b1 00                	mov    $0x0,%cl
f01003d3:	83 c9 20             	or     $0x20,%ecx
f01003d6:	a1 2c 85 11 f0       	mov    0xf011852c,%eax
f01003db:	66 89 0c 50          	mov    %cx,(%eax,%edx,2)
f01003df:	eb 9c                	jmp    f010037d <cons_putc+0xf6>
		crt_pos += CRT_COLS;
f01003e1:	66 83 05 28 85 11 f0 	addw   $0x50,0xf0118528
f01003e8:	50 
f01003e9:	e9 70 ff ff ff       	jmp    f010035e <cons_putc+0xd7>
		crt_buf[crt_pos++] = c;		/* write the character */
f01003ee:	66 a1 28 85 11 f0    	mov    0xf0118528,%ax
f01003f4:	8d 50 01             	lea    0x1(%eax),%edx
f01003f7:	66 89 15 28 85 11 f0 	mov    %dx,0xf0118528
f01003fe:	0f b7 c0             	movzwl %ax,%eax
f0100401:	8b 15 2c 85 11 f0    	mov    0xf011852c,%edx
f0100407:	66 89 0c 42          	mov    %cx,(%edx,%eax,2)
		break;
f010040b:	e9 6d ff ff ff       	jmp    f010037d <cons_putc+0xf6>
		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f0100410:	a1 2c 85 11 f0       	mov    0xf011852c,%eax
f0100415:	83 ec 04             	sub    $0x4,%esp
f0100418:	68 00 0f 00 00       	push   $0xf00
f010041d:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f0100423:	52                   	push   %edx
f0100424:	50                   	push   %eax
f0100425:	e8 6d 2e 00 00       	call   f0103297 <memmove>
			crt_buf[i] = 0x0700 | ' ';
f010042a:	8b 15 2c 85 11 f0    	mov    0xf011852c,%edx
f0100430:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f0100436:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f010043c:	83 c4 10             	add    $0x10,%esp
f010043f:	66 c7 00 20 07       	movw   $0x720,(%eax)
f0100444:	83 c0 02             	add    $0x2,%eax
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f0100447:	39 d0                	cmp    %edx,%eax
f0100449:	75 f4                	jne    f010043f <cons_putc+0x1b8>
		crt_pos -= CRT_COLS;
f010044b:	66 83 2d 28 85 11 f0 	subw   $0x50,0xf0118528
f0100452:	50 
f0100453:	e9 34 ff ff ff       	jmp    f010038c <cons_putc+0x105>

f0100458 <serial_intr>:
	if (serial_exists)
f0100458:	80 3d 34 85 11 f0 00 	cmpb   $0x0,0xf0118534
f010045f:	75 01                	jne    f0100462 <serial_intr+0xa>
f0100461:	c3                   	ret    
{
f0100462:	55                   	push   %ebp
f0100463:	89 e5                	mov    %esp,%ebp
f0100465:	83 ec 08             	sub    $0x8,%esp
		cons_intr(serial_proc_data);
f0100468:	b8 1e 01 10 f0       	mov    $0xf010011e,%eax
f010046d:	e8 c6 fc ff ff       	call   f0100138 <cons_intr>
}
f0100472:	c9                   	leave  
f0100473:	c3                   	ret    

f0100474 <kbd_intr>:
{
f0100474:	55                   	push   %ebp
f0100475:	89 e5                	mov    %esp,%ebp
f0100477:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f010047a:	b8 7b 01 10 f0       	mov    $0xf010017b,%eax
f010047f:	e8 b4 fc ff ff       	call   f0100138 <cons_intr>
}
f0100484:	c9                   	leave  
f0100485:	c3                   	ret    

f0100486 <cons_getc>:
{
f0100486:	55                   	push   %ebp
f0100487:	89 e5                	mov    %esp,%ebp
f0100489:	83 ec 08             	sub    $0x8,%esp
	serial_intr();
f010048c:	e8 c7 ff ff ff       	call   f0100458 <serial_intr>
	kbd_intr();
f0100491:	e8 de ff ff ff       	call   f0100474 <kbd_intr>
	if (cons.rpos != cons.wpos) {
f0100496:	a1 20 85 11 f0       	mov    0xf0118520,%eax
f010049b:	3b 05 24 85 11 f0    	cmp    0xf0118524,%eax
f01004a1:	74 24                	je     f01004c7 <cons_getc+0x41>
		c = cons.buf[cons.rpos++];
f01004a3:	8d 50 01             	lea    0x1(%eax),%edx
f01004a6:	89 15 20 85 11 f0    	mov    %edx,0xf0118520
f01004ac:	0f b6 80 20 83 11 f0 	movzbl -0xfee7ce0(%eax),%eax
		if (cons.rpos == CONSBUFSIZE)
f01004b3:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f01004b9:	75 11                	jne    f01004cc <cons_getc+0x46>
			cons.rpos = 0;
f01004bb:	c7 05 20 85 11 f0 00 	movl   $0x0,0xf0118520
f01004c2:	00 00 00 
f01004c5:	eb 05                	jmp    f01004cc <cons_getc+0x46>
	return 0;
f01004c7:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01004cc:	c9                   	leave  
f01004cd:	c3                   	ret    

f01004ce <cons_init>:

// initialize the console devices
void
cons_init(void)
{
f01004ce:	55                   	push   %ebp
f01004cf:	89 e5                	mov    %esp,%ebp
f01004d1:	57                   	push   %edi
f01004d2:	56                   	push   %esi
f01004d3:	53                   	push   %ebx
f01004d4:	83 ec 0c             	sub    $0xc,%esp
	was = *cp;
f01004d7:	66 8b 15 00 80 0b f0 	mov    0xf00b8000,%dx
	*cp = (uint16_t) 0xA55A;
f01004de:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f01004e5:	5a a5 
	if (*cp != 0xA55A) {
f01004e7:	66 a1 00 80 0b f0    	mov    0xf00b8000,%ax
f01004ed:	66 3d 5a a5          	cmp    $0xa55a,%ax
f01004f1:	0f 84 a2 00 00 00    	je     f0100599 <cons_init+0xcb>
		addr_6845 = MONO_BASE;
f01004f7:	c7 05 30 85 11 f0 b4 	movl   $0x3b4,0xf0118530
f01004fe:	03 00 00 
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f0100501:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
	outb(addr_6845, 14);
f0100506:	8b 3d 30 85 11 f0    	mov    0xf0118530,%edi
f010050c:	b0 0e                	mov    $0xe,%al
f010050e:	89 fa                	mov    %edi,%edx
f0100510:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f0100511:	8d 4f 01             	lea    0x1(%edi),%ecx
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100514:	89 ca                	mov    %ecx,%edx
f0100516:	ec                   	in     (%dx),%al
f0100517:	0f b6 c0             	movzbl %al,%eax
f010051a:	c1 e0 08             	shl    $0x8,%eax
f010051d:	89 c3                	mov    %eax,%ebx
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010051f:	b0 0f                	mov    $0xf,%al
f0100521:	89 fa                	mov    %edi,%edx
f0100523:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100524:	89 ca                	mov    %ecx,%edx
f0100526:	ec                   	in     (%dx),%al
	crt_buf = (uint16_t*) cp;
f0100527:	89 35 2c 85 11 f0    	mov    %esi,0xf011852c
	pos |= inb(addr_6845 + 1);
f010052d:	0f b6 c0             	movzbl %al,%eax
f0100530:	09 d8                	or     %ebx,%eax
	crt_pos = pos;
f0100532:	66 a3 28 85 11 f0    	mov    %ax,0xf0118528
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100538:	b1 00                	mov    $0x0,%cl
f010053a:	bb fa 03 00 00       	mov    $0x3fa,%ebx
f010053f:	88 c8                	mov    %cl,%al
f0100541:	89 da                	mov    %ebx,%edx
f0100543:	ee                   	out    %al,(%dx)
f0100544:	bf fb 03 00 00       	mov    $0x3fb,%edi
f0100549:	b0 80                	mov    $0x80,%al
f010054b:	89 fa                	mov    %edi,%edx
f010054d:	ee                   	out    %al,(%dx)
f010054e:	b0 0c                	mov    $0xc,%al
f0100550:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100555:	ee                   	out    %al,(%dx)
f0100556:	be f9 03 00 00       	mov    $0x3f9,%esi
f010055b:	88 c8                	mov    %cl,%al
f010055d:	89 f2                	mov    %esi,%edx
f010055f:	ee                   	out    %al,(%dx)
f0100560:	b0 03                	mov    $0x3,%al
f0100562:	89 fa                	mov    %edi,%edx
f0100564:	ee                   	out    %al,(%dx)
f0100565:	ba fc 03 00 00       	mov    $0x3fc,%edx
f010056a:	88 c8                	mov    %cl,%al
f010056c:	ee                   	out    %al,(%dx)
f010056d:	b0 01                	mov    $0x1,%al
f010056f:	89 f2                	mov    %esi,%edx
f0100571:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100572:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100577:	ec                   	in     (%dx),%al
f0100578:	88 c1                	mov    %al,%cl
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f010057a:	3c ff                	cmp    $0xff,%al
f010057c:	0f 95 05 34 85 11 f0 	setne  0xf0118534
f0100583:	89 da                	mov    %ebx,%edx
f0100585:	ec                   	in     (%dx),%al
f0100586:	ba f8 03 00 00       	mov    $0x3f8,%edx
f010058b:	ec                   	in     (%dx),%al
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f010058c:	80 f9 ff             	cmp    $0xff,%cl
f010058f:	74 23                	je     f01005b4 <cons_init+0xe6>
		cprintf("Serial port does not exist!\n");
}
f0100591:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100594:	5b                   	pop    %ebx
f0100595:	5e                   	pop    %esi
f0100596:	5f                   	pop    %edi
f0100597:	5d                   	pop    %ebp
f0100598:	c3                   	ret    
		*cp = was;
f0100599:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f01005a0:	c7 05 30 85 11 f0 d4 	movl   $0x3d4,0xf0118530
f01005a7:	03 00 00 
	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f01005aa:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
f01005af:	e9 52 ff ff ff       	jmp    f0100506 <cons_init+0x38>
		cprintf("Serial port does not exist!\n");
f01005b4:	83 ec 0c             	sub    $0xc,%esp
f01005b7:	68 b9 36 10 f0       	push   $0xf01036b9
f01005bc:	e8 fb 21 00 00       	call   f01027bc <cprintf>
f01005c1:	83 c4 10             	add    $0x10,%esp
}
f01005c4:	eb cb                	jmp    f0100591 <cons_init+0xc3>

f01005c6 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f01005c6:	55                   	push   %ebp
f01005c7:	89 e5                	mov    %esp,%ebp
f01005c9:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f01005cc:	8b 45 08             	mov    0x8(%ebp),%eax
f01005cf:	e8 b3 fc ff ff       	call   f0100287 <cons_putc>
}
f01005d4:	c9                   	leave  
f01005d5:	c3                   	ret    

f01005d6 <getchar>:

int
getchar(void)
{
f01005d6:	55                   	push   %ebp
f01005d7:	89 e5                	mov    %esp,%ebp
f01005d9:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f01005dc:	e8 a5 fe ff ff       	call   f0100486 <cons_getc>
f01005e1:	85 c0                	test   %eax,%eax
f01005e3:	74 f7                	je     f01005dc <getchar+0x6>
		/* do nothing */;
	return c;
}
f01005e5:	c9                   	leave  
f01005e6:	c3                   	ret    

f01005e7 <iscons>:
int
iscons(int fdnum)
{
	// used by readline
	return 1;
}
f01005e7:	b8 01 00 00 00       	mov    $0x1,%eax
f01005ec:	c3                   	ret    

f01005ed <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f01005ed:	55                   	push   %ebp
f01005ee:	89 e5                	mov    %esp,%ebp
f01005f0:	83 ec 0c             	sub    $0xc,%esp
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f01005f3:	68 00 39 10 f0       	push   $0xf0103900
f01005f8:	68 1e 39 10 f0       	push   $0xf010391e
f01005fd:	68 23 39 10 f0       	push   $0xf0103923
f0100602:	e8 b5 21 00 00       	call   f01027bc <cprintf>
f0100607:	83 c4 0c             	add    $0xc,%esp
f010060a:	68 8c 39 10 f0       	push   $0xf010398c
f010060f:	68 2c 39 10 f0       	push   $0xf010392c
f0100614:	68 23 39 10 f0       	push   $0xf0103923
f0100619:	e8 9e 21 00 00       	call   f01027bc <cprintf>
	return 0;
}
f010061e:	b8 00 00 00 00       	mov    $0x0,%eax
f0100623:	c9                   	leave  
f0100624:	c3                   	ret    

f0100625 <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f0100625:	55                   	push   %ebp
f0100626:	89 e5                	mov    %esp,%ebp
f0100628:	83 ec 14             	sub    $0x14,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f010062b:	68 35 39 10 f0       	push   $0xf0103935
f0100630:	e8 87 21 00 00       	call   f01027bc <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f0100635:	83 c4 08             	add    $0x8,%esp
f0100638:	68 0c 00 10 00       	push   $0x10000c
f010063d:	68 b4 39 10 f0       	push   $0xf01039b4
f0100642:	e8 75 21 00 00       	call   f01027bc <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f0100647:	83 c4 0c             	add    $0xc,%esp
f010064a:	68 0c 00 10 00       	push   $0x10000c
f010064f:	68 0c 00 10 f0       	push   $0xf010000c
f0100654:	68 dc 39 10 f0       	push   $0xf01039dc
f0100659:	e8 5e 21 00 00       	call   f01027bc <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f010065e:	83 c4 0c             	add    $0xc,%esp
f0100661:	68 4e 36 10 00       	push   $0x10364e
f0100666:	68 4e 36 10 f0       	push   $0xf010364e
f010066b:	68 00 3a 10 f0       	push   $0xf0103a00
f0100670:	e8 47 21 00 00       	call   f01027bc <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f0100675:	83 c4 0c             	add    $0xc,%esp
f0100678:	68 00 83 11 00       	push   $0x118300
f010067d:	68 00 83 11 f0       	push   $0xf0118300
f0100682:	68 24 3a 10 f0       	push   $0xf0103a24
f0100687:	e8 30 21 00 00       	call   f01027bc <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f010068c:	83 c4 0c             	add    $0xc,%esp
f010068f:	68 60 89 11 00       	push   $0x118960
f0100694:	68 60 89 11 f0       	push   $0xf0118960
f0100699:	68 48 3a 10 f0       	push   $0xf0103a48
f010069e:	e8 19 21 00 00       	call   f01027bc <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
f01006a3:	83 c4 08             	add    $0x8,%esp
		ROUNDUP(end - entry, 1024) / 1024);
f01006a6:	b8 60 89 11 f0       	mov    $0xf0118960,%eax
f01006ab:	2d 0d fc 0f f0       	sub    $0xf00ffc0d,%eax
	cprintf("Kernel executable memory footprint: %dKB\n",
f01006b0:	c1 f8 0a             	sar    $0xa,%eax
f01006b3:	50                   	push   %eax
f01006b4:	68 6c 3a 10 f0       	push   $0xf0103a6c
f01006b9:	e8 fe 20 00 00       	call   f01027bc <cprintf>
	return 0;
}
f01006be:	b8 00 00 00 00       	mov    $0x0,%eax
f01006c3:	c9                   	leave  
f01006c4:	c3                   	ret    

f01006c5 <mon_backtrace>:
int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
	// Your code here.
	return 0;
}
f01006c5:	b8 00 00 00 00       	mov    $0x0,%eax
f01006ca:	c3                   	ret    

f01006cb <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f01006cb:	55                   	push   %ebp
f01006cc:	89 e5                	mov    %esp,%ebp
f01006ce:	57                   	push   %edi
f01006cf:	56                   	push   %esi
f01006d0:	53                   	push   %ebx
f01006d1:	83 ec 58             	sub    $0x58,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f01006d4:	68 98 3a 10 f0       	push   $0xf0103a98
f01006d9:	e8 de 20 00 00       	call   f01027bc <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f01006de:	c7 04 24 bc 3a 10 f0 	movl   $0xf0103abc,(%esp)
f01006e5:	e8 d2 20 00 00       	call   f01027bc <cprintf>
f01006ea:	83 c4 10             	add    $0x10,%esp
f01006ed:	e9 cb 00 00 00       	jmp    f01007bd <monitor+0xf2>
		while (*buf && strchr(WHITESPACE, *buf))
f01006f2:	83 ec 08             	sub    $0x8,%esp
f01006f5:	0f be c0             	movsbl %al,%eax
f01006f8:	50                   	push   %eax
f01006f9:	68 52 39 10 f0       	push   $0xf0103952
f01006fe:	e8 14 2b 00 00       	call   f0103217 <strchr>
f0100703:	83 c4 10             	add    $0x10,%esp
f0100706:	85 c0                	test   %eax,%eax
f0100708:	74 6b                	je     f0100775 <monitor+0xaa>
			*buf++ = 0;
f010070a:	c6 03 00             	movb   $0x0,(%ebx)
f010070d:	89 f7                	mov    %esi,%edi
f010070f:	8d 5b 01             	lea    0x1(%ebx),%ebx
f0100712:	89 fe                	mov    %edi,%esi
		while (*buf && strchr(WHITESPACE, *buf))
f0100714:	8a 03                	mov    (%ebx),%al
f0100716:	84 c0                	test   %al,%al
f0100718:	75 d8                	jne    f01006f2 <monitor+0x27>
	argv[argc] = 0;
f010071a:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f0100721:	00 
	if (argc == 0)
f0100722:	85 f6                	test   %esi,%esi
f0100724:	0f 84 93 00 00 00    	je     f01007bd <monitor+0xf2>
		if (strcmp(argv[0], commands[i].name) == 0)
f010072a:	83 ec 08             	sub    $0x8,%esp
f010072d:	68 1e 39 10 f0       	push   $0xf010391e
f0100732:	ff 75 a8             	pushl  -0x58(%ebp)
f0100735:	e8 89 2a 00 00       	call   f01031c3 <strcmp>
f010073a:	83 c4 10             	add    $0x10,%esp
f010073d:	85 c0                	test   %eax,%eax
f010073f:	0f 84 a4 00 00 00    	je     f01007e9 <monitor+0x11e>
f0100745:	83 ec 08             	sub    $0x8,%esp
f0100748:	68 2c 39 10 f0       	push   $0xf010392c
f010074d:	ff 75 a8             	pushl  -0x58(%ebp)
f0100750:	e8 6e 2a 00 00       	call   f01031c3 <strcmp>
f0100755:	83 c4 10             	add    $0x10,%esp
f0100758:	85 c0                	test   %eax,%eax
f010075a:	0f 84 84 00 00 00    	je     f01007e4 <monitor+0x119>
	cprintf("Unknown command '%s'\n", argv[0]);
f0100760:	83 ec 08             	sub    $0x8,%esp
f0100763:	ff 75 a8             	pushl  -0x58(%ebp)
f0100766:	68 74 39 10 f0       	push   $0xf0103974
f010076b:	e8 4c 20 00 00       	call   f01027bc <cprintf>
	return 0;
f0100770:	83 c4 10             	add    $0x10,%esp
f0100773:	eb 48                	jmp    f01007bd <monitor+0xf2>
		if (*buf == 0)
f0100775:	80 3b 00             	cmpb   $0x0,(%ebx)
f0100778:	74 a0                	je     f010071a <monitor+0x4f>
		if (argc == MAXARGS-1) {
f010077a:	83 fe 0f             	cmp    $0xf,%esi
f010077d:	74 2c                	je     f01007ab <monitor+0xe0>
		argv[argc++] = buf;
f010077f:	8d 7e 01             	lea    0x1(%esi),%edi
f0100782:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
		while (*buf && !strchr(WHITESPACE, *buf))
f0100786:	8a 03                	mov    (%ebx),%al
f0100788:	84 c0                	test   %al,%al
f010078a:	74 86                	je     f0100712 <monitor+0x47>
f010078c:	83 ec 08             	sub    $0x8,%esp
f010078f:	0f be c0             	movsbl %al,%eax
f0100792:	50                   	push   %eax
f0100793:	68 52 39 10 f0       	push   $0xf0103952
f0100798:	e8 7a 2a 00 00       	call   f0103217 <strchr>
f010079d:	83 c4 10             	add    $0x10,%esp
f01007a0:	85 c0                	test   %eax,%eax
f01007a2:	0f 85 6a ff ff ff    	jne    f0100712 <monitor+0x47>
			buf++;
f01007a8:	43                   	inc    %ebx
f01007a9:	eb db                	jmp    f0100786 <monitor+0xbb>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f01007ab:	83 ec 08             	sub    $0x8,%esp
f01007ae:	6a 10                	push   $0x10
f01007b0:	68 57 39 10 f0       	push   $0xf0103957
f01007b5:	e8 02 20 00 00       	call   f01027bc <cprintf>
			return 0;
f01007ba:	83 c4 10             	add    $0x10,%esp


	while (1) {
		buf = readline("K> ");
f01007bd:	83 ec 0c             	sub    $0xc,%esp
f01007c0:	68 4e 39 10 f0       	push   $0xf010394e
f01007c5:	e8 41 28 00 00       	call   f010300b <readline>
f01007ca:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f01007cc:	83 c4 10             	add    $0x10,%esp
f01007cf:	85 c0                	test   %eax,%eax
f01007d1:	74 ea                	je     f01007bd <monitor+0xf2>
	argv[argc] = 0;
f01007d3:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	argc = 0;
f01007da:	be 00 00 00 00       	mov    $0x0,%esi
f01007df:	e9 30 ff ff ff       	jmp    f0100714 <monitor+0x49>
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f01007e4:	b8 01 00 00 00       	mov    $0x1,%eax
			return commands[i].func(argc, argv, tf);
f01007e9:	83 ec 04             	sub    $0x4,%esp
f01007ec:	8d 14 00             	lea    (%eax,%eax,1),%edx
f01007ef:	01 d0                	add    %edx,%eax
f01007f1:	ff 75 08             	pushl  0x8(%ebp)
f01007f4:	8d 4d a8             	lea    -0x58(%ebp),%ecx
f01007f7:	51                   	push   %ecx
f01007f8:	56                   	push   %esi
f01007f9:	ff 14 85 ec 3a 10 f0 	call   *-0xfefc514(,%eax,4)
			if (runcmd(buf, tf) < 0)
f0100800:	83 c4 10             	add    $0x10,%esp
f0100803:	85 c0                	test   %eax,%eax
f0100805:	79 b6                	jns    f01007bd <monitor+0xf2>
				break;
	}
}
f0100807:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010080a:	5b                   	pop    %ebx
f010080b:	5e                   	pop    %esi
f010080c:	5f                   	pop    %edi
f010080d:	5d                   	pop    %ebp
f010080e:	c3                   	ret    

f010080f <nvram_read>:
// Detect machine's physical memory setup.
// --------------------------------------------------------------

static int
nvram_read(int r)
{
f010080f:	55                   	push   %ebp
f0100810:	89 e5                	mov    %esp,%ebp
f0100812:	56                   	push   %esi
f0100813:	53                   	push   %ebx
f0100814:	89 c3                	mov    %eax,%ebx
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0100816:	83 ec 0c             	sub    $0xc,%esp
f0100819:	50                   	push   %eax
f010081a:	e8 36 1f 00 00       	call   f0102755 <mc146818_read>
f010081f:	89 c6                	mov    %eax,%esi
f0100821:	43                   	inc    %ebx
f0100822:	89 1c 24             	mov    %ebx,(%esp)
f0100825:	e8 2b 1f 00 00       	call   f0102755 <mc146818_read>
f010082a:	c1 e0 08             	shl    $0x8,%eax
f010082d:	09 f0                	or     %esi,%eax
}
f010082f:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100832:	5b                   	pop    %ebx
f0100833:	5e                   	pop    %esi
f0100834:	5d                   	pop    %ebp
f0100835:	c3                   	ret    

f0100836 <boot_alloc>:
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f0100836:	83 3d 38 85 11 f0 00 	cmpl   $0x0,0xf0118538
f010083d:	74 2c                	je     f010086b <boot_alloc+0x35>
	// Allocate a chunk large enough to hold 'n' bytes, then update
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
	result = nextfree;			// Start address of the allocated contiguous memory block
f010083f:	8b 0d 38 85 11 f0    	mov    0xf0118538,%ecx
	nextfree = ROUNDUP(nextfree + n, PGSIZE);
f0100845:	8d 84 01 ff 0f 00 00 	lea    0xfff(%ecx,%eax,1),%eax
f010084c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100851:	a3 38 85 11 f0       	mov    %eax,0xf0118538
	if ((uint32_t)nextfree - KERNBASE > (npages * PGSIZE))	// The allocated space exceeds total physical memory
f0100856:	05 00 00 00 10       	add    $0x10000000,%eax
f010085b:	8b 15 68 89 11 f0    	mov    0xf0118968,%edx
f0100861:	c1 e2 0c             	shl    $0xc,%edx
f0100864:	39 d0                	cmp    %edx,%eax
f0100866:	77 16                	ja     f010087e <boot_alloc+0x48>
		panic("Out of memory!");

	return result;
}
f0100868:	89 c8                	mov    %ecx,%eax
f010086a:	c3                   	ret    
		nextfree = ROUNDUP((char *) end, PGSIZE);
f010086b:	ba 5f 99 11 f0       	mov    $0xf011995f,%edx
f0100870:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100876:	89 15 38 85 11 f0    	mov    %edx,0xf0118538
f010087c:	eb c1                	jmp    f010083f <boot_alloc+0x9>
{
f010087e:	55                   	push   %ebp
f010087f:	89 e5                	mov    %esp,%ebp
f0100881:	83 ec 0c             	sub    $0xc,%esp
		panic("Out of memory!");
f0100884:	68 fc 3a 10 f0       	push   $0xf0103afc
f0100889:	6a 6f                	push   $0x6f
f010088b:	68 0b 3b 10 f0       	push   $0xf0103b0b
f0100890:	e8 f6 f7 ff ff       	call   f010008b <_panic>

f0100895 <check_va2pa>:
static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
f0100895:	89 d1                	mov    %edx,%ecx
f0100897:	c1 e9 16             	shr    $0x16,%ecx
	if (!(*pgdir & PTE_P))
f010089a:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f010089d:	a8 01                	test   $0x1,%al
f010089f:	74 48                	je     f01008e9 <check_va2pa+0x54>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f01008a1:	89 c1                	mov    %eax,%ecx
f01008a3:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01008a9:	c1 e8 0c             	shr    $0xc,%eax
f01008ac:	3b 05 68 89 11 f0    	cmp    0xf0118968,%eax
f01008b2:	73 1a                	jae    f01008ce <check_va2pa+0x39>
	if (!(p[PTX(va)] & PTE_P))
f01008b4:	c1 ea 0c             	shr    $0xc,%edx
f01008b7:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f01008bd:	8b 84 91 00 00 00 f0 	mov    -0x10000000(%ecx,%edx,4),%eax
f01008c4:	a8 01                	test   $0x1,%al
f01008c6:	74 27                	je     f01008ef <check_va2pa+0x5a>
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f01008c8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01008cd:	c3                   	ret    
{
f01008ce:	55                   	push   %ebp
f01008cf:	89 e5                	mov    %esp,%ebp
f01008d1:	83 ec 08             	sub    $0x8,%esp
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01008d4:	51                   	push   %ecx
f01008d5:	68 08 3e 10 f0       	push   $0xf0103e08
f01008da:	68 f8 02 00 00       	push   $0x2f8
f01008df:	68 0b 3b 10 f0       	push   $0xf0103b0b
f01008e4:	e8 a2 f7 ff ff       	call   f010008b <_panic>
		return ~0;
f01008e9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01008ee:	c3                   	ret    
		return ~0;
f01008ef:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
f01008f4:	c3                   	ret    

f01008f5 <check_page_free_list>:
{
f01008f5:	55                   	push   %ebp
f01008f6:	89 e5                	mov    %esp,%ebp
f01008f8:	57                   	push   %edi
f01008f9:	56                   	push   %esi
f01008fa:	53                   	push   %ebx
f01008fb:	83 ec 2c             	sub    $0x2c,%esp
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f01008fe:	84 c0                	test   %al,%al
f0100900:	0f 85 4f 02 00 00    	jne    f0100b55 <check_page_free_list+0x260>
	if (!page_free_list)
f0100906:	83 3d 3c 85 11 f0 00 	cmpl   $0x0,0xf011853c
f010090d:	74 0d                	je     f010091c <check_page_free_list+0x27>
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f010090f:	be 00 04 00 00       	mov    $0x400,%esi
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100914:	8b 1d 3c 85 11 f0    	mov    0xf011853c,%ebx
f010091a:	eb 2b                	jmp    f0100947 <check_page_free_list+0x52>
		panic("'page_free_list' is a null pointer!");
f010091c:	83 ec 04             	sub    $0x4,%esp
f010091f:	68 2c 3e 10 f0       	push   $0xf0103e2c
f0100924:	68 39 02 00 00       	push   $0x239
f0100929:	68 0b 3b 10 f0       	push   $0xf0103b0b
f010092e:	e8 58 f7 ff ff       	call   f010008b <_panic>
f0100933:	50                   	push   %eax
f0100934:	68 08 3e 10 f0       	push   $0xf0103e08
f0100939:	6a 52                	push   $0x52
f010093b:	68 17 3b 10 f0       	push   $0xf0103b17
f0100940:	e8 46 f7 ff ff       	call   f010008b <_panic>
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100945:	8b 1b                	mov    (%ebx),%ebx
f0100947:	85 db                	test   %ebx,%ebx
f0100949:	74 41                	je     f010098c <check_page_free_list+0x97>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010094b:	89 d8                	mov    %ebx,%eax
f010094d:	2b 05 70 89 11 f0    	sub    0xf0118970,%eax
f0100953:	c1 f8 03             	sar    $0x3,%eax
f0100956:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f0100959:	89 c2                	mov    %eax,%edx
f010095b:	c1 ea 16             	shr    $0x16,%edx
f010095e:	39 f2                	cmp    %esi,%edx
f0100960:	73 e3                	jae    f0100945 <check_page_free_list+0x50>
	if (PGNUM(pa) >= npages)
f0100962:	89 c2                	mov    %eax,%edx
f0100964:	c1 ea 0c             	shr    $0xc,%edx
f0100967:	3b 15 68 89 11 f0    	cmp    0xf0118968,%edx
f010096d:	73 c4                	jae    f0100933 <check_page_free_list+0x3e>
			memset(page2kva(pp), 0x97, 128);
f010096f:	83 ec 04             	sub    $0x4,%esp
f0100972:	68 80 00 00 00       	push   $0x80
f0100977:	68 97 00 00 00       	push   $0x97
	return (void *)(pa + KERNBASE);
f010097c:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100981:	50                   	push   %eax
f0100982:	e8 c5 28 00 00       	call   f010324c <memset>
f0100987:	83 c4 10             	add    $0x10,%esp
f010098a:	eb b9                	jmp    f0100945 <check_page_free_list+0x50>
	first_free_page = (char *) boot_alloc(0);
f010098c:	b8 00 00 00 00       	mov    $0x0,%eax
f0100991:	e8 a0 fe ff ff       	call   f0100836 <boot_alloc>
f0100996:	89 45 cc             	mov    %eax,-0x34(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100999:	8b 15 3c 85 11 f0    	mov    0xf011853c,%edx
		assert(pp >= pages);
f010099f:	8b 0d 70 89 11 f0    	mov    0xf0118970,%ecx
		assert(pp < pages + npages);
f01009a5:	a1 68 89 11 f0       	mov    0xf0118968,%eax
f01009aa:	89 45 d0             	mov    %eax,-0x30(%ebp)
f01009ad:	8d 3c c1             	lea    (%ecx,%eax,8),%edi
	int nfree_basemem = 0, nfree_extmem = 0;
f01009b0:	be 00 00 00 00       	mov    $0x0,%esi
f01009b5:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f01009b8:	e9 c8 00 00 00       	jmp    f0100a85 <check_page_free_list+0x190>
		assert(pp >= pages);
f01009bd:	68 25 3b 10 f0       	push   $0xf0103b25
f01009c2:	68 31 3b 10 f0       	push   $0xf0103b31
f01009c7:	68 53 02 00 00       	push   $0x253
f01009cc:	68 0b 3b 10 f0       	push   $0xf0103b0b
f01009d1:	e8 b5 f6 ff ff       	call   f010008b <_panic>
		assert(pp < pages + npages);
f01009d6:	68 46 3b 10 f0       	push   $0xf0103b46
f01009db:	68 31 3b 10 f0       	push   $0xf0103b31
f01009e0:	68 54 02 00 00       	push   $0x254
f01009e5:	68 0b 3b 10 f0       	push   $0xf0103b0b
f01009ea:	e8 9c f6 ff ff       	call   f010008b <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f01009ef:	68 50 3e 10 f0       	push   $0xf0103e50
f01009f4:	68 31 3b 10 f0       	push   $0xf0103b31
f01009f9:	68 55 02 00 00       	push   $0x255
f01009fe:	68 0b 3b 10 f0       	push   $0xf0103b0b
f0100a03:	e8 83 f6 ff ff       	call   f010008b <_panic>
		assert(page2pa(pp) != 0);
f0100a08:	68 5a 3b 10 f0       	push   $0xf0103b5a
f0100a0d:	68 31 3b 10 f0       	push   $0xf0103b31
f0100a12:	68 58 02 00 00       	push   $0x258
f0100a17:	68 0b 3b 10 f0       	push   $0xf0103b0b
f0100a1c:	e8 6a f6 ff ff       	call   f010008b <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100a21:	68 6b 3b 10 f0       	push   $0xf0103b6b
f0100a26:	68 31 3b 10 f0       	push   $0xf0103b31
f0100a2b:	68 59 02 00 00       	push   $0x259
f0100a30:	68 0b 3b 10 f0       	push   $0xf0103b0b
f0100a35:	e8 51 f6 ff ff       	call   f010008b <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100a3a:	68 84 3e 10 f0       	push   $0xf0103e84
f0100a3f:	68 31 3b 10 f0       	push   $0xf0103b31
f0100a44:	68 5a 02 00 00       	push   $0x25a
f0100a49:	68 0b 3b 10 f0       	push   $0xf0103b0b
f0100a4e:	e8 38 f6 ff ff       	call   f010008b <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100a53:	68 84 3b 10 f0       	push   $0xf0103b84
f0100a58:	68 31 3b 10 f0       	push   $0xf0103b31
f0100a5d:	68 5b 02 00 00       	push   $0x25b
f0100a62:	68 0b 3b 10 f0       	push   $0xf0103b0b
f0100a67:	e8 1f f6 ff ff       	call   f010008b <_panic>
	if (PGNUM(pa) >= npages)
f0100a6c:	89 c3                	mov    %eax,%ebx
f0100a6e:	c1 eb 0c             	shr    $0xc,%ebx
f0100a71:	39 5d d0             	cmp    %ebx,-0x30(%ebp)
f0100a74:	76 62                	jbe    f0100ad8 <check_page_free_list+0x1e3>
	return (void *)(pa + KERNBASE);
f0100a76:	2d 00 00 00 10       	sub    $0x10000000,%eax
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100a7b:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f0100a7e:	77 6a                	ja     f0100aea <check_page_free_list+0x1f5>
			++nfree_extmem;
f0100a80:	ff 45 d4             	incl   -0x2c(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100a83:	8b 12                	mov    (%edx),%edx
f0100a85:	85 d2                	test   %edx,%edx
f0100a87:	74 7a                	je     f0100b03 <check_page_free_list+0x20e>
		assert(pp >= pages);
f0100a89:	39 d1                	cmp    %edx,%ecx
f0100a8b:	0f 87 2c ff ff ff    	ja     f01009bd <check_page_free_list+0xc8>
		assert(pp < pages + npages);
f0100a91:	39 d7                	cmp    %edx,%edi
f0100a93:	0f 86 3d ff ff ff    	jbe    f01009d6 <check_page_free_list+0xe1>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100a99:	89 d0                	mov    %edx,%eax
f0100a9b:	29 c8                	sub    %ecx,%eax
f0100a9d:	a8 07                	test   $0x7,%al
f0100a9f:	0f 85 4a ff ff ff    	jne    f01009ef <check_page_free_list+0xfa>
	return (pp - pages) << PGSHIFT;
f0100aa5:	c1 f8 03             	sar    $0x3,%eax
		assert(page2pa(pp) != 0);
f0100aa8:	c1 e0 0c             	shl    $0xc,%eax
f0100aab:	0f 84 57 ff ff ff    	je     f0100a08 <check_page_free_list+0x113>
		assert(page2pa(pp) != IOPHYSMEM);
f0100ab1:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100ab6:	0f 84 65 ff ff ff    	je     f0100a21 <check_page_free_list+0x12c>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100abc:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100ac1:	0f 84 73 ff ff ff    	je     f0100a3a <check_page_free_list+0x145>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100ac7:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100acc:	74 85                	je     f0100a53 <check_page_free_list+0x15e>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100ace:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0100ad3:	77 97                	ja     f0100a6c <check_page_free_list+0x177>
			++nfree_basemem;
f0100ad5:	46                   	inc    %esi
f0100ad6:	eb ab                	jmp    f0100a83 <check_page_free_list+0x18e>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100ad8:	50                   	push   %eax
f0100ad9:	68 08 3e 10 f0       	push   $0xf0103e08
f0100ade:	6a 52                	push   $0x52
f0100ae0:	68 17 3b 10 f0       	push   $0xf0103b17
f0100ae5:	e8 a1 f5 ff ff       	call   f010008b <_panic>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100aea:	68 a8 3e 10 f0       	push   $0xf0103ea8
f0100aef:	68 31 3b 10 f0       	push   $0xf0103b31
f0100af4:	68 5c 02 00 00       	push   $0x25c
f0100af9:	68 0b 3b 10 f0       	push   $0xf0103b0b
f0100afe:	e8 88 f5 ff ff       	call   f010008b <_panic>
f0100b03:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
	assert(nfree_basemem > 0);
f0100b06:	85 f6                	test   %esi,%esi
f0100b08:	7e 19                	jle    f0100b23 <check_page_free_list+0x22e>
	assert(nfree_extmem > 0);
f0100b0a:	85 db                	test   %ebx,%ebx
f0100b0c:	7e 2e                	jle    f0100b3c <check_page_free_list+0x247>
	cprintf("check_page_free_list() succeeded!\n");
f0100b0e:	83 ec 0c             	sub    $0xc,%esp
f0100b11:	68 f0 3e 10 f0       	push   $0xf0103ef0
f0100b16:	e8 a1 1c 00 00       	call   f01027bc <cprintf>
}
f0100b1b:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100b1e:	5b                   	pop    %ebx
f0100b1f:	5e                   	pop    %esi
f0100b20:	5f                   	pop    %edi
f0100b21:	5d                   	pop    %ebp
f0100b22:	c3                   	ret    
	assert(nfree_basemem > 0);
f0100b23:	68 9e 3b 10 f0       	push   $0xf0103b9e
f0100b28:	68 31 3b 10 f0       	push   $0xf0103b31
f0100b2d:	68 64 02 00 00       	push   $0x264
f0100b32:	68 0b 3b 10 f0       	push   $0xf0103b0b
f0100b37:	e8 4f f5 ff ff       	call   f010008b <_panic>
	assert(nfree_extmem > 0);
f0100b3c:	68 b0 3b 10 f0       	push   $0xf0103bb0
f0100b41:	68 31 3b 10 f0       	push   $0xf0103b31
f0100b46:	68 65 02 00 00       	push   $0x265
f0100b4b:	68 0b 3b 10 f0       	push   $0xf0103b0b
f0100b50:	e8 36 f5 ff ff       	call   f010008b <_panic>
	if (!page_free_list)
f0100b55:	a1 3c 85 11 f0       	mov    0xf011853c,%eax
f0100b5a:	85 c0                	test   %eax,%eax
f0100b5c:	0f 84 ba fd ff ff    	je     f010091c <check_page_free_list+0x27>
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f0100b62:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0100b65:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0100b68:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100b6b:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	return (pp - pages) << PGSHIFT;
f0100b6e:	89 c2                	mov    %eax,%edx
f0100b70:	2b 15 70 89 11 f0    	sub    0xf0118970,%edx
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0100b76:	f7 c2 00 e0 7f 00    	test   $0x7fe000,%edx
f0100b7c:	0f 95 c2             	setne  %dl
f0100b7f:	0f b6 d2             	movzbl %dl,%edx
			*tp[pagetype] = pp;
f0100b82:	8b 4c 95 e0          	mov    -0x20(%ebp,%edx,4),%ecx
f0100b86:	89 01                	mov    %eax,(%ecx)
			tp[pagetype] = &pp->pp_link;
f0100b88:	89 44 95 e0          	mov    %eax,-0x20(%ebp,%edx,4)
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100b8c:	8b 00                	mov    (%eax),%eax
f0100b8e:	85 c0                	test   %eax,%eax
f0100b90:	75 dc                	jne    f0100b6e <check_page_free_list+0x279>
		*tp[1] = 0;
f0100b92:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100b95:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0100b9b:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100b9e:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100ba1:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0100ba3:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100ba6:	a3 3c 85 11 f0       	mov    %eax,0xf011853c
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100bab:	be 01 00 00 00       	mov    $0x1,%esi
f0100bb0:	e9 5f fd ff ff       	jmp    f0100914 <check_page_free_list+0x1f>

f0100bb5 <page_init>:
{
f0100bb5:	55                   	push   %ebp
f0100bb6:	89 e5                	mov    %esp,%ebp
f0100bb8:	57                   	push   %edi
f0100bb9:	56                   	push   %esi
f0100bba:	53                   	push   %ebx
f0100bbb:	83 ec 0c             	sub    $0xc,%esp
	for (i = 0; i < npages; i++)
f0100bbe:	bb 00 00 00 00       	mov    $0x0,%ebx
		int is_IO_hole = i >= npages_basemem && i <= npages_basemem + npages_IO ;
f0100bc3:	be 01 00 00 00       	mov    $0x1,%esi
	for (i = 0; i < npages; i++)
f0100bc8:	eb 65                	jmp    f0100c2f <page_init+0x7a>
		int is_IO_hole = i >= npages_basemem && i <= npages_basemem + npages_IO ;
f0100bca:	b9 00 00 00 00       	mov    $0x0,%ecx
		int is_kernel_pgdir = (i >= npages_basemem + npages_IO && i <= npages_basemem + npages_IO + npages_kern);
f0100bcf:	8d 7a 60             	lea    0x60(%edx),%edi
f0100bd2:	39 df                	cmp    %ebx,%edi
f0100bd4:	76 3a                	jbe    f0100c10 <page_init+0x5b>
		if (i == 0 || is_IO_hole || is_kernel_pgdir) {
f0100bd6:	85 db                	test   %ebx,%ebx
f0100bd8:	74 48                	je     f0100c22 <page_init+0x6d>
f0100bda:	85 c9                	test   %ecx,%ecx
f0100bdc:	75 44                	jne    f0100c22 <page_init+0x6d>
f0100bde:	8d 04 dd 00 00 00 00 	lea    0x0(,%ebx,8),%eax
			pages[i].pp_ref = 0;
f0100be5:	89 c2                	mov    %eax,%edx
f0100be7:	03 15 70 89 11 f0    	add    0xf0118970,%edx
f0100bed:	66 c7 42 04 00 00    	movw   $0x0,0x4(%edx)
			pages[i].pp_link = page_free_list;
f0100bf3:	8b 0d 3c 85 11 f0    	mov    0xf011853c,%ecx
f0100bf9:	89 0a                	mov    %ecx,(%edx)
			page_free_list = &pages[i];
f0100bfb:	03 05 70 89 11 f0    	add    0xf0118970,%eax
f0100c01:	a3 3c 85 11 f0       	mov    %eax,0xf011853c
f0100c06:	eb 26                	jmp    f0100c2e <page_init+0x79>
		int is_kernel_pgdir = (i >= npages_basemem + npages_IO && i <= npages_basemem + npages_IO + npages_kern);
f0100c08:	8d 7a 60             	lea    0x60(%edx),%edi
		int is_IO_hole = i >= npages_basemem && i <= npages_basemem + npages_IO ;
f0100c0b:	b9 00 00 00 00       	mov    $0x0,%ecx
		int npages_kern = ((uint32_t)boot_alloc(0) - KERNBASE + PGSIZE - 1) / PGSIZE;
f0100c10:	8d 90 ff 0f 00 10    	lea    0x10000fff(%eax),%edx
f0100c16:	89 d0                	mov    %edx,%eax
f0100c18:	c1 e8 0c             	shr    $0xc,%eax
		int is_kernel_pgdir = (i >= npages_basemem + npages_IO && i <= npages_basemem + npages_IO + npages_kern);
f0100c1b:	8d 14 38             	lea    (%eax,%edi,1),%edx
f0100c1e:	39 da                	cmp    %ebx,%edx
f0100c20:	72 b4                	jb     f0100bd6 <page_init+0x21>
			pages[i].pp_ref = 1;
f0100c22:	a1 70 89 11 f0       	mov    0xf0118970,%eax
f0100c27:	66 c7 44 d8 04 01 00 	movw   $0x1,0x4(%eax,%ebx,8)
	for (i = 0; i < npages; i++)
f0100c2e:	43                   	inc    %ebx
f0100c2f:	39 1d 68 89 11 f0    	cmp    %ebx,0xf0118968
f0100c35:	76 26                	jbe    f0100c5d <page_init+0xa8>
		int npages_kern = ((uint32_t)boot_alloc(0) - KERNBASE + PGSIZE - 1) / PGSIZE;
f0100c37:	b8 00 00 00 00       	mov    $0x0,%eax
f0100c3c:	e8 f5 fb ff ff       	call   f0100836 <boot_alloc>
		int is_IO_hole = i >= npages_basemem && i <= npages_basemem + npages_IO ;
f0100c41:	8b 15 40 85 11 f0    	mov    0xf0118540,%edx
f0100c47:	39 da                	cmp    %ebx,%edx
f0100c49:	0f 87 7b ff ff ff    	ja     f0100bca <page_init+0x15>
f0100c4f:	8d 4a 60             	lea    0x60(%edx),%ecx
f0100c52:	39 d9                	cmp    %ebx,%ecx
f0100c54:	72 b2                	jb     f0100c08 <page_init+0x53>
f0100c56:	89 f1                	mov    %esi,%ecx
f0100c58:	e9 72 ff ff ff       	jmp    f0100bcf <page_init+0x1a>
}
f0100c5d:	83 c4 0c             	add    $0xc,%esp
f0100c60:	5b                   	pop    %ebx
f0100c61:	5e                   	pop    %esi
f0100c62:	5f                   	pop    %edi
f0100c63:	5d                   	pop    %ebp
f0100c64:	c3                   	ret    

f0100c65 <page_alloc>:
{
f0100c65:	55                   	push   %ebp
f0100c66:	89 e5                	mov    %esp,%ebp
f0100c68:	53                   	push   %ebx
f0100c69:	83 ec 04             	sub    $0x4,%esp
	new_page = page_free_list;
f0100c6c:	8b 1d 3c 85 11 f0    	mov    0xf011853c,%ebx
	if (new_page == NULL) {
f0100c72:	85 db                	test   %ebx,%ebx
f0100c74:	74 13                	je     f0100c89 <page_alloc+0x24>
	page_free_list = new_page->pp_link;
f0100c76:	8b 03                	mov    (%ebx),%eax
f0100c78:	a3 3c 85 11 f0       	mov    %eax,0xf011853c
	new_page->pp_link = NULL;
f0100c7d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	if(alloc_flags && ALLOC_ZERO)
f0100c83:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f0100c87:	75 07                	jne    f0100c90 <page_alloc+0x2b>
}
f0100c89:	89 d8                	mov    %ebx,%eax
f0100c8b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100c8e:	c9                   	leave  
f0100c8f:	c3                   	ret    
f0100c90:	89 d8                	mov    %ebx,%eax
f0100c92:	2b 05 70 89 11 f0    	sub    0xf0118970,%eax
f0100c98:	c1 f8 03             	sar    $0x3,%eax
f0100c9b:	89 c2                	mov    %eax,%edx
f0100c9d:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0100ca0:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0100ca5:	3b 05 68 89 11 f0    	cmp    0xf0118968,%eax
f0100cab:	73 1b                	jae    f0100cc8 <page_alloc+0x63>
		memset(page2kva(new_page), '\0', PGSIZE);
f0100cad:	83 ec 04             	sub    $0x4,%esp
f0100cb0:	68 00 10 00 00       	push   $0x1000
f0100cb5:	6a 00                	push   $0x0
	return (void *)(pa + KERNBASE);
f0100cb7:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f0100cbd:	52                   	push   %edx
f0100cbe:	e8 89 25 00 00       	call   f010324c <memset>
f0100cc3:	83 c4 10             	add    $0x10,%esp
f0100cc6:	eb c1                	jmp    f0100c89 <page_alloc+0x24>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100cc8:	52                   	push   %edx
f0100cc9:	68 08 3e 10 f0       	push   $0xf0103e08
f0100cce:	6a 52                	push   $0x52
f0100cd0:	68 17 3b 10 f0       	push   $0xf0103b17
f0100cd5:	e8 b1 f3 ff ff       	call   f010008b <_panic>

f0100cda <page_free>:
{
f0100cda:	55                   	push   %ebp
f0100cdb:	89 e5                	mov    %esp,%ebp
f0100cdd:	83 ec 08             	sub    $0x8,%esp
f0100ce0:	8b 45 08             	mov    0x8(%ebp),%eax
	if (pp->pp_ref != 0 || pp->pp_link != NULL) {
f0100ce3:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0100ce8:	75 14                	jne    f0100cfe <page_free+0x24>
f0100cea:	83 38 00             	cmpl   $0x0,(%eax)
f0100ced:	75 0f                	jne    f0100cfe <page_free+0x24>
	pp->pp_link = page_free_list;
f0100cef:	8b 15 3c 85 11 f0    	mov    0xf011853c,%edx
f0100cf5:	89 10                	mov    %edx,(%eax)
	page_free_list = pp;
f0100cf7:	a3 3c 85 11 f0       	mov    %eax,0xf011853c
}
f0100cfc:	c9                   	leave  
f0100cfd:	c3                   	ret    
		panic("Cannot free this page!");
f0100cfe:	83 ec 04             	sub    $0x4,%esp
f0100d01:	68 c1 3b 10 f0       	push   $0xf0103bc1
f0100d06:	68 58 01 00 00       	push   $0x158
f0100d0b:	68 0b 3b 10 f0       	push   $0xf0103b0b
f0100d10:	e8 76 f3 ff ff       	call   f010008b <_panic>

f0100d15 <page_decref>:
{
f0100d15:	55                   	push   %ebp
f0100d16:	89 e5                	mov    %esp,%ebp
f0100d18:	83 ec 08             	sub    $0x8,%esp
f0100d1b:	8b 55 08             	mov    0x8(%ebp),%edx
	if (--pp->pp_ref == 0)
f0100d1e:	8b 42 04             	mov    0x4(%edx),%eax
f0100d21:	48                   	dec    %eax
f0100d22:	66 89 42 04          	mov    %ax,0x4(%edx)
f0100d26:	66 85 c0             	test   %ax,%ax
f0100d29:	74 02                	je     f0100d2d <page_decref+0x18>
}
f0100d2b:	c9                   	leave  
f0100d2c:	c3                   	ret    
		page_free(pp);
f0100d2d:	83 ec 0c             	sub    $0xc,%esp
f0100d30:	52                   	push   %edx
f0100d31:	e8 a4 ff ff ff       	call   f0100cda <page_free>
f0100d36:	83 c4 10             	add    $0x10,%esp
}
f0100d39:	eb f0                	jmp    f0100d2b <page_decref+0x16>

f0100d3b <pgdir_walk>:
{
f0100d3b:	55                   	push   %ebp
f0100d3c:	89 e5                	mov    %esp,%ebp
f0100d3e:	53                   	push   %ebx
f0100d3f:	83 ec 04             	sub    $0x4,%esp
	pde_t *pg_dir_entry = (pde_t *)(pgdir + (unsigned int)PDX(va));
f0100d42:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0100d45:	c1 eb 16             	shr    $0x16,%ebx
f0100d48:	c1 e3 02             	shl    $0x2,%ebx
f0100d4b:	03 5d 08             	add    0x8(%ebp),%ebx
	if(!(*pg_dir_entry) & PTE_P) {
f0100d4e:	83 3b 00             	cmpl   $0x0,(%ebx)
f0100d51:	75 2c                	jne    f0100d7f <pgdir_walk+0x44>
		if (create == false)
f0100d53:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0100d57:	74 67                	je     f0100dc0 <pgdir_walk+0x85>
		new_page = page_alloc(1);
f0100d59:	83 ec 0c             	sub    $0xc,%esp
f0100d5c:	6a 01                	push   $0x1
f0100d5e:	e8 02 ff ff ff       	call   f0100c65 <page_alloc>
		if(new_page == NULL)
f0100d63:	83 c4 10             	add    $0x10,%esp
f0100d66:	85 c0                	test   %eax,%eax
f0100d68:	74 3c                	je     f0100da6 <pgdir_walk+0x6b>
		new_page->pp_ref ++;
f0100d6a:	66 ff 40 04          	incw   0x4(%eax)
	return (pp - pages) << PGSHIFT;
f0100d6e:	2b 05 70 89 11 f0    	sub    0xf0118970,%eax
f0100d74:	c1 f8 03             	sar    $0x3,%eax
f0100d77:	c1 e0 0c             	shl    $0xc,%eax
		*pg_dir_entry = ((page2pa(new_page)) | PTE_P | PTE_W | PTE_U);
f0100d7a:	83 c8 07             	or     $0x7,%eax
f0100d7d:	89 03                	mov    %eax,(%ebx)
	offset = PTX(va);
f0100d7f:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100d82:	c1 e8 0c             	shr    $0xc,%eax
f0100d85:	25 ff 03 00 00       	and    $0x3ff,%eax
	page_base = KADDR(PTE_ADDR(*pg_dir_entry));
f0100d8a:	8b 13                	mov    (%ebx),%edx
f0100d8c:	89 d1                	mov    %edx,%ecx
f0100d8e:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
	if (PGNUM(pa) >= npages)
f0100d94:	c1 ea 0c             	shr    $0xc,%edx
f0100d97:	3b 15 68 89 11 f0    	cmp    0xf0118968,%edx
f0100d9d:	73 0c                	jae    f0100dab <pgdir_walk+0x70>
	return &page_base[offset];
f0100d9f:	8d 84 81 00 00 00 f0 	lea    -0x10000000(%ecx,%eax,4),%eax
}
f0100da6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100da9:	c9                   	leave  
f0100daa:	c3                   	ret    
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100dab:	51                   	push   %ecx
f0100dac:	68 08 3e 10 f0       	push   $0xf0103e08
f0100db1:	68 97 01 00 00       	push   $0x197
f0100db6:	68 0b 3b 10 f0       	push   $0xf0103b0b
f0100dbb:	e8 cb f2 ff ff       	call   f010008b <_panic>
			return NULL;
f0100dc0:	b8 00 00 00 00       	mov    $0x0,%eax
f0100dc5:	eb df                	jmp    f0100da6 <pgdir_walk+0x6b>

f0100dc7 <boot_map_region>:
{
f0100dc7:	55                   	push   %ebp
f0100dc8:	89 e5                	mov    %esp,%ebp
f0100dca:	57                   	push   %edi
f0100dcb:	56                   	push   %esi
f0100dcc:	53                   	push   %ebx
f0100dcd:	83 ec 1c             	sub    $0x1c,%esp
f0100dd0:	89 c7                	mov    %eax,%edi
	int num_pages = size / PGSIZE;
f0100dd2:	c1 e9 0c             	shr    $0xc,%ecx
f0100dd5:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
	for(int i = 0; i < num_pages; ++i) {
f0100dd8:	89 d3                	mov    %edx,%ebx
f0100dda:	be 00 00 00 00       	mov    $0x0,%esi
		*pt_entry = (pa + i * PGSIZE) | PTE_P | perm;
f0100ddf:	8b 45 08             	mov    0x8(%ebp),%eax
f0100de2:	29 d0                	sub    %edx,%eax
f0100de4:	89 45 e0             	mov    %eax,-0x20(%ebp)
	for(int i = 0; i < num_pages; ++i) {
f0100de7:	3b 75 e4             	cmp    -0x1c(%ebp),%esi
f0100dea:	7d 27                	jge    f0100e13 <boot_map_region+0x4c>
		pt_entry = pgdir_walk(pgdir, (void *)(va + i * PGSIZE), 1);
f0100dec:	83 ec 04             	sub    $0x4,%esp
f0100def:	6a 01                	push   $0x1
f0100df1:	53                   	push   %ebx
f0100df2:	57                   	push   %edi
f0100df3:	e8 43 ff ff ff       	call   f0100d3b <pgdir_walk>
f0100df8:	89 c2                	mov    %eax,%edx
		*pt_entry = (pa + i * PGSIZE) | PTE_P | perm;
f0100dfa:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100dfd:	01 d8                	add    %ebx,%eax
f0100dff:	0b 45 0c             	or     0xc(%ebp),%eax
f0100e02:	83 c8 01             	or     $0x1,%eax
f0100e05:	89 02                	mov    %eax,(%edx)
	for(int i = 0; i < num_pages; ++i) {
f0100e07:	46                   	inc    %esi
f0100e08:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0100e0e:	83 c4 10             	add    $0x10,%esp
f0100e11:	eb d4                	jmp    f0100de7 <boot_map_region+0x20>
}
f0100e13:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100e16:	5b                   	pop    %ebx
f0100e17:	5e                   	pop    %esi
f0100e18:	5f                   	pop    %edi
f0100e19:	5d                   	pop    %ebp
f0100e1a:	c3                   	ret    

f0100e1b <page_lookup>:
{
f0100e1b:	55                   	push   %ebp
f0100e1c:	89 e5                	mov    %esp,%ebp
f0100e1e:	53                   	push   %ebx
f0100e1f:	83 ec 08             	sub    $0x8,%esp
f0100e22:	8b 5d 10             	mov    0x10(%ebp),%ebx
	pte_t *pt_entry = pgdir_walk(pgdir, va, false);
f0100e25:	6a 00                	push   $0x0
f0100e27:	ff 75 0c             	pushl  0xc(%ebp)
f0100e2a:	ff 75 08             	pushl  0x8(%ebp)
f0100e2d:	e8 09 ff ff ff       	call   f0100d3b <pgdir_walk>
	if(pt_entry == NULL)
f0100e32:	83 c4 10             	add    $0x10,%esp
f0100e35:	85 c0                	test   %eax,%eax
f0100e37:	74 21                	je     f0100e5a <page_lookup+0x3f>
	if(!(*pt_entry & PTE_P))
f0100e39:	f6 00 01             	testb  $0x1,(%eax)
f0100e3c:	74 35                	je     f0100e73 <page_lookup+0x58>
	if(pte_store != NULL)
f0100e3e:	85 db                	test   %ebx,%ebx
f0100e40:	74 02                	je     f0100e44 <page_lookup+0x29>
		*pte_store = pt_entry;
f0100e42:	89 03                	mov    %eax,(%ebx)
f0100e44:	8b 00                	mov    (%eax),%eax
f0100e46:	c1 e8 0c             	shr    $0xc,%eax
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100e49:	39 05 68 89 11 f0    	cmp    %eax,0xf0118968
f0100e4f:	76 0e                	jbe    f0100e5f <page_lookup+0x44>
		panic("pa2page called with invalid pa");
	return &pages[PGNUM(pa)];
f0100e51:	8b 15 70 89 11 f0    	mov    0xf0118970,%edx
f0100e57:	8d 04 c2             	lea    (%edx,%eax,8),%eax
}
f0100e5a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100e5d:	c9                   	leave  
f0100e5e:	c3                   	ret    
		panic("pa2page called with invalid pa");
f0100e5f:	83 ec 04             	sub    $0x4,%esp
f0100e62:	68 14 3f 10 f0       	push   $0xf0103f14
f0100e67:	6a 4b                	push   $0x4b
f0100e69:	68 17 3b 10 f0       	push   $0xf0103b17
f0100e6e:	e8 18 f2 ff ff       	call   f010008b <_panic>
		return NULL;
f0100e73:	b8 00 00 00 00       	mov    $0x0,%eax
f0100e78:	eb e0                	jmp    f0100e5a <page_lookup+0x3f>

f0100e7a <page_remove>:
{
f0100e7a:	55                   	push   %ebp
f0100e7b:	89 e5                	mov    %esp,%ebp
f0100e7d:	53                   	push   %ebx
f0100e7e:	83 ec 18             	sub    $0x18,%esp
f0100e81:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct PageInfo *page = page_lookup(pgdir, va, &pte_store);
f0100e84:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0100e87:	50                   	push   %eax
f0100e88:	53                   	push   %ebx
f0100e89:	ff 75 08             	pushl  0x8(%ebp)
f0100e8c:	e8 8a ff ff ff       	call   f0100e1b <page_lookup>
	if(page == NULL)
f0100e91:	83 c4 10             	add    $0x10,%esp
f0100e94:	85 c0                	test   %eax,%eax
f0100e96:	74 18                	je     f0100eb0 <page_remove+0x36>
	page_decref(page);
f0100e98:	83 ec 0c             	sub    $0xc,%esp
f0100e9b:	50                   	push   %eax
f0100e9c:	e8 74 fe ff ff       	call   f0100d15 <page_decref>
}

static inline void
invlpg(void *addr)
{
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0100ea1:	0f 01 3b             	invlpg (%ebx)
	*pte_store = 0;
f0100ea4:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0100ea7:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
f0100ead:	83 c4 10             	add    $0x10,%esp
}
f0100eb0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100eb3:	c9                   	leave  
f0100eb4:	c3                   	ret    

f0100eb5 <page_insert>:
{
f0100eb5:	55                   	push   %ebp
f0100eb6:	89 e5                	mov    %esp,%ebp
f0100eb8:	57                   	push   %edi
f0100eb9:	56                   	push   %esi
f0100eba:	53                   	push   %ebx
f0100ebb:	83 ec 10             	sub    $0x10,%esp
f0100ebe:	8b 7d 08             	mov    0x8(%ebp),%edi
f0100ec1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	pte_t *pt_entry = pgdir_walk(pgdir, (void *)va, 1);
f0100ec4:	6a 01                	push   $0x1
f0100ec6:	ff 75 10             	pushl  0x10(%ebp)
f0100ec9:	57                   	push   %edi
f0100eca:	e8 6c fe ff ff       	call   f0100d3b <pgdir_walk>
	if (pt_entry == NULL) {
f0100ecf:	83 c4 10             	add    $0x10,%esp
f0100ed2:	85 c0                	test   %eax,%eax
f0100ed4:	74 56                	je     f0100f2c <page_insert+0x77>
f0100ed6:	89 c6                	mov    %eax,%esi
	pp->pp_ref++;
f0100ed8:	66 ff 43 04          	incw   0x4(%ebx)
	if (*pt_entry & PTE_P)
f0100edc:	f6 00 01             	testb  $0x1,(%eax)
f0100edf:	75 34                	jne    f0100f15 <page_insert+0x60>
	return (pp - pages) << PGSHIFT;
f0100ee1:	2b 1d 70 89 11 f0    	sub    0xf0118970,%ebx
f0100ee7:	c1 fb 03             	sar    $0x3,%ebx
f0100eea:	c1 e3 0c             	shl    $0xc,%ebx
	*pt_entry = page2pa(pp) | perm | PTE_P;
f0100eed:	0b 5d 14             	or     0x14(%ebp),%ebx
f0100ef0:	83 cb 01             	or     $0x1,%ebx
f0100ef3:	89 1e                	mov    %ebx,(%esi)
	pgdir[PDX(va)] |= perm | PTE_P;
f0100ef5:	8b 45 10             	mov    0x10(%ebp),%eax
f0100ef8:	c1 e8 16             	shr    $0x16,%eax
f0100efb:	8d 14 87             	lea    (%edi,%eax,4),%edx
f0100efe:	8b 45 14             	mov    0x14(%ebp),%eax
f0100f01:	0b 02                	or     (%edx),%eax
f0100f03:	83 c8 01             	or     $0x1,%eax
f0100f06:	89 02                	mov    %eax,(%edx)
	return 0;
f0100f08:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100f0d:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100f10:	5b                   	pop    %ebx
f0100f11:	5e                   	pop    %esi
f0100f12:	5f                   	pop    %edi
f0100f13:	5d                   	pop    %ebp
f0100f14:	c3                   	ret    
f0100f15:	8b 45 10             	mov    0x10(%ebp),%eax
f0100f18:	0f 01 38             	invlpg (%eax)
		page_remove(pgdir, va);
f0100f1b:	83 ec 08             	sub    $0x8,%esp
f0100f1e:	ff 75 10             	pushl  0x10(%ebp)
f0100f21:	57                   	push   %edi
f0100f22:	e8 53 ff ff ff       	call   f0100e7a <page_remove>
f0100f27:	83 c4 10             	add    $0x10,%esp
f0100f2a:	eb b5                	jmp    f0100ee1 <page_insert+0x2c>
		return -E_NO_MEM;
f0100f2c:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f0100f31:	eb da                	jmp    f0100f0d <page_insert+0x58>

f0100f33 <mem_init>:
{
f0100f33:	55                   	push   %ebp
f0100f34:	89 e5                	mov    %esp,%ebp
f0100f36:	57                   	push   %edi
f0100f37:	56                   	push   %esi
f0100f38:	53                   	push   %ebx
f0100f39:	83 ec 3c             	sub    $0x3c,%esp
	basemem = nvram_read(NVRAM_BASELO);
f0100f3c:	b8 15 00 00 00       	mov    $0x15,%eax
f0100f41:	e8 c9 f8 ff ff       	call   f010080f <nvram_read>
f0100f46:	89 c3                	mov    %eax,%ebx
	extmem = nvram_read(NVRAM_EXTLO);
f0100f48:	b8 17 00 00 00       	mov    $0x17,%eax
f0100f4d:	e8 bd f8 ff ff       	call   f010080f <nvram_read>
f0100f52:	89 c6                	mov    %eax,%esi
	ext16mem = nvram_read(NVRAM_EXT16LO) * 64;
f0100f54:	b8 34 00 00 00       	mov    $0x34,%eax
f0100f59:	e8 b1 f8 ff ff       	call   f010080f <nvram_read>
	if (ext16mem)
f0100f5e:	c1 e0 06             	shl    $0x6,%eax
f0100f61:	0f 84 ca 00 00 00    	je     f0101031 <mem_init+0xfe>
		totalmem = 16 * 1024 + ext16mem;
f0100f67:	05 00 40 00 00       	add    $0x4000,%eax
	npages = totalmem / (PGSIZE / 1024);
f0100f6c:	89 c2                	mov    %eax,%edx
f0100f6e:	c1 ea 02             	shr    $0x2,%edx
f0100f71:	89 15 68 89 11 f0    	mov    %edx,0xf0118968
	npages_basemem = basemem / (PGSIZE / 1024);
f0100f77:	89 da                	mov    %ebx,%edx
f0100f79:	c1 ea 02             	shr    $0x2,%edx
f0100f7c:	89 15 40 85 11 f0    	mov    %edx,0xf0118540
	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0100f82:	89 c2                	mov    %eax,%edx
f0100f84:	29 da                	sub    %ebx,%edx
f0100f86:	52                   	push   %edx
f0100f87:	53                   	push   %ebx
f0100f88:	50                   	push   %eax
f0100f89:	68 34 3f 10 f0       	push   $0xf0103f34
f0100f8e:	e8 29 18 00 00       	call   f01027bc <cprintf>
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f0100f93:	b8 00 10 00 00       	mov    $0x1000,%eax
f0100f98:	e8 99 f8 ff ff       	call   f0100836 <boot_alloc>
f0100f9d:	a3 6c 89 11 f0       	mov    %eax,0xf011896c
	memset(kern_pgdir, 0, PGSIZE);
f0100fa2:	83 c4 0c             	add    $0xc,%esp
f0100fa5:	68 00 10 00 00       	push   $0x1000
f0100faa:	6a 00                	push   $0x0
f0100fac:	50                   	push   %eax
f0100fad:	e8 9a 22 00 00       	call   f010324c <memset>
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f0100fb2:	a1 6c 89 11 f0       	mov    0xf011896c,%eax
	if ((uint32_t)kva < KERNBASE)
f0100fb7:	83 c4 10             	add    $0x10,%esp
f0100fba:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0100fbf:	0f 86 82 00 00 00    	jbe    f0101047 <mem_init+0x114>
	return (physaddr_t)kva - KERNBASE;
f0100fc5:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0100fcb:	83 ca 05             	or     $0x5,%edx
f0100fce:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	pages = boot_alloc(npages * sizeof(struct PageInfo *));
f0100fd4:	a1 68 89 11 f0       	mov    0xf0118968,%eax
f0100fd9:	c1 e0 02             	shl    $0x2,%eax
f0100fdc:	e8 55 f8 ff ff       	call   f0100836 <boot_alloc>
f0100fe1:	a3 70 89 11 f0       	mov    %eax,0xf0118970
	memset(pages, 0, npages * sizeof(struct PageInfo *));
f0100fe6:	83 ec 04             	sub    $0x4,%esp
f0100fe9:	8b 0d 68 89 11 f0    	mov    0xf0118968,%ecx
f0100fef:	8d 14 8d 00 00 00 00 	lea    0x0(,%ecx,4),%edx
f0100ff6:	52                   	push   %edx
f0100ff7:	6a 00                	push   $0x0
f0100ff9:	50                   	push   %eax
f0100ffa:	e8 4d 22 00 00       	call   f010324c <memset>
	page_init();
f0100fff:	e8 b1 fb ff ff       	call   f0100bb5 <page_init>
	check_page_free_list(1);
f0101004:	b8 01 00 00 00       	mov    $0x1,%eax
f0101009:	e8 e7 f8 ff ff       	call   f01008f5 <check_page_free_list>
	if (!pages)
f010100e:	83 c4 10             	add    $0x10,%esp
f0101011:	83 3d 70 89 11 f0 00 	cmpl   $0x0,0xf0118970
f0101018:	74 42                	je     f010105c <mem_init+0x129>
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f010101a:	a1 3c 85 11 f0       	mov    0xf011853c,%eax
f010101f:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
f0101026:	85 c0                	test   %eax,%eax
f0101028:	74 49                	je     f0101073 <mem_init+0x140>
		++nfree;
f010102a:	ff 45 d4             	incl   -0x2c(%ebp)
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f010102d:	8b 00                	mov    (%eax),%eax
f010102f:	eb f5                	jmp    f0101026 <mem_init+0xf3>
	else if (extmem)
f0101031:	85 f6                	test   %esi,%esi
f0101033:	74 0b                	je     f0101040 <mem_init+0x10d>
		totalmem = 1 * 1024 + extmem;
f0101035:	8d 86 00 04 00 00    	lea    0x400(%esi),%eax
f010103b:	e9 2c ff ff ff       	jmp    f0100f6c <mem_init+0x39>
		totalmem = basemem;
f0101040:	89 d8                	mov    %ebx,%eax
f0101042:	e9 25 ff ff ff       	jmp    f0100f6c <mem_init+0x39>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0101047:	50                   	push   %eax
f0101048:	68 70 3f 10 f0       	push   $0xf0103f70
f010104d:	68 96 00 00 00       	push   $0x96
f0101052:	68 0b 3b 10 f0       	push   $0xf0103b0b
f0101057:	e8 2f f0 ff ff       	call   f010008b <_panic>
		panic("'pages' is a null pointer!");
f010105c:	83 ec 04             	sub    $0x4,%esp
f010105f:	68 d8 3b 10 f0       	push   $0xf0103bd8
f0101064:	68 78 02 00 00       	push   $0x278
f0101069:	68 0b 3b 10 f0       	push   $0xf0103b0b
f010106e:	e8 18 f0 ff ff       	call   f010008b <_panic>
	assert((pp0 = page_alloc(0)));
f0101073:	83 ec 0c             	sub    $0xc,%esp
f0101076:	6a 00                	push   $0x0
f0101078:	e8 e8 fb ff ff       	call   f0100c65 <page_alloc>
f010107d:	89 c3                	mov    %eax,%ebx
f010107f:	83 c4 10             	add    $0x10,%esp
f0101082:	85 c0                	test   %eax,%eax
f0101084:	0f 84 0e 02 00 00    	je     f0101298 <mem_init+0x365>
	assert((pp1 = page_alloc(0)));
f010108a:	83 ec 0c             	sub    $0xc,%esp
f010108d:	6a 00                	push   $0x0
f010108f:	e8 d1 fb ff ff       	call   f0100c65 <page_alloc>
f0101094:	89 c6                	mov    %eax,%esi
f0101096:	83 c4 10             	add    $0x10,%esp
f0101099:	85 c0                	test   %eax,%eax
f010109b:	0f 84 10 02 00 00    	je     f01012b1 <mem_init+0x37e>
	assert((pp2 = page_alloc(0)));
f01010a1:	83 ec 0c             	sub    $0xc,%esp
f01010a4:	6a 00                	push   $0x0
f01010a6:	e8 ba fb ff ff       	call   f0100c65 <page_alloc>
f01010ab:	89 c7                	mov    %eax,%edi
f01010ad:	83 c4 10             	add    $0x10,%esp
f01010b0:	85 c0                	test   %eax,%eax
f01010b2:	0f 84 12 02 00 00    	je     f01012ca <mem_init+0x397>
	assert(pp1 && pp1 != pp0);
f01010b8:	39 f3                	cmp    %esi,%ebx
f01010ba:	0f 84 23 02 00 00    	je     f01012e3 <mem_init+0x3b0>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01010c0:	39 c6                	cmp    %eax,%esi
f01010c2:	0f 84 34 02 00 00    	je     f01012fc <mem_init+0x3c9>
f01010c8:	39 c3                	cmp    %eax,%ebx
f01010ca:	0f 84 2c 02 00 00    	je     f01012fc <mem_init+0x3c9>
	return (pp - pages) << PGSHIFT;
f01010d0:	8b 0d 70 89 11 f0    	mov    0xf0118970,%ecx
	assert(page2pa(pp0) < npages*PGSIZE);
f01010d6:	8b 15 68 89 11 f0    	mov    0xf0118968,%edx
f01010dc:	c1 e2 0c             	shl    $0xc,%edx
f01010df:	89 d8                	mov    %ebx,%eax
f01010e1:	29 c8                	sub    %ecx,%eax
f01010e3:	c1 f8 03             	sar    $0x3,%eax
f01010e6:	c1 e0 0c             	shl    $0xc,%eax
f01010e9:	39 d0                	cmp    %edx,%eax
f01010eb:	0f 83 24 02 00 00    	jae    f0101315 <mem_init+0x3e2>
f01010f1:	89 f0                	mov    %esi,%eax
f01010f3:	29 c8                	sub    %ecx,%eax
f01010f5:	c1 f8 03             	sar    $0x3,%eax
f01010f8:	c1 e0 0c             	shl    $0xc,%eax
	assert(page2pa(pp1) < npages*PGSIZE);
f01010fb:	39 c2                	cmp    %eax,%edx
f01010fd:	0f 86 2b 02 00 00    	jbe    f010132e <mem_init+0x3fb>
f0101103:	89 f8                	mov    %edi,%eax
f0101105:	29 c8                	sub    %ecx,%eax
f0101107:	c1 f8 03             	sar    $0x3,%eax
f010110a:	c1 e0 0c             	shl    $0xc,%eax
	assert(page2pa(pp2) < npages*PGSIZE);
f010110d:	39 c2                	cmp    %eax,%edx
f010110f:	0f 86 32 02 00 00    	jbe    f0101347 <mem_init+0x414>
	fl = page_free_list;
f0101115:	a1 3c 85 11 f0       	mov    0xf011853c,%eax
f010111a:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f010111d:	c7 05 3c 85 11 f0 00 	movl   $0x0,0xf011853c
f0101124:	00 00 00 
	assert(!page_alloc(0));
f0101127:	83 ec 0c             	sub    $0xc,%esp
f010112a:	6a 00                	push   $0x0
f010112c:	e8 34 fb ff ff       	call   f0100c65 <page_alloc>
f0101131:	83 c4 10             	add    $0x10,%esp
f0101134:	85 c0                	test   %eax,%eax
f0101136:	0f 85 24 02 00 00    	jne    f0101360 <mem_init+0x42d>
	page_free(pp0);
f010113c:	83 ec 0c             	sub    $0xc,%esp
f010113f:	53                   	push   %ebx
f0101140:	e8 95 fb ff ff       	call   f0100cda <page_free>
	page_free(pp1);
f0101145:	89 34 24             	mov    %esi,(%esp)
f0101148:	e8 8d fb ff ff       	call   f0100cda <page_free>
	page_free(pp2);
f010114d:	89 3c 24             	mov    %edi,(%esp)
f0101150:	e8 85 fb ff ff       	call   f0100cda <page_free>
	assert((pp0 = page_alloc(0)));
f0101155:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010115c:	e8 04 fb ff ff       	call   f0100c65 <page_alloc>
f0101161:	89 c3                	mov    %eax,%ebx
f0101163:	83 c4 10             	add    $0x10,%esp
f0101166:	85 c0                	test   %eax,%eax
f0101168:	0f 84 0b 02 00 00    	je     f0101379 <mem_init+0x446>
	assert((pp1 = page_alloc(0)));
f010116e:	83 ec 0c             	sub    $0xc,%esp
f0101171:	6a 00                	push   $0x0
f0101173:	e8 ed fa ff ff       	call   f0100c65 <page_alloc>
f0101178:	89 c6                	mov    %eax,%esi
f010117a:	83 c4 10             	add    $0x10,%esp
f010117d:	85 c0                	test   %eax,%eax
f010117f:	0f 84 0d 02 00 00    	je     f0101392 <mem_init+0x45f>
	assert((pp2 = page_alloc(0)));
f0101185:	83 ec 0c             	sub    $0xc,%esp
f0101188:	6a 00                	push   $0x0
f010118a:	e8 d6 fa ff ff       	call   f0100c65 <page_alloc>
f010118f:	89 c7                	mov    %eax,%edi
f0101191:	83 c4 10             	add    $0x10,%esp
f0101194:	85 c0                	test   %eax,%eax
f0101196:	0f 84 0f 02 00 00    	je     f01013ab <mem_init+0x478>
	assert(pp1 && pp1 != pp0);
f010119c:	39 f3                	cmp    %esi,%ebx
f010119e:	0f 84 20 02 00 00    	je     f01013c4 <mem_init+0x491>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01011a4:	39 c6                	cmp    %eax,%esi
f01011a6:	0f 84 31 02 00 00    	je     f01013dd <mem_init+0x4aa>
f01011ac:	39 c3                	cmp    %eax,%ebx
f01011ae:	0f 84 29 02 00 00    	je     f01013dd <mem_init+0x4aa>
	assert(!page_alloc(0));
f01011b4:	83 ec 0c             	sub    $0xc,%esp
f01011b7:	6a 00                	push   $0x0
f01011b9:	e8 a7 fa ff ff       	call   f0100c65 <page_alloc>
f01011be:	83 c4 10             	add    $0x10,%esp
f01011c1:	85 c0                	test   %eax,%eax
f01011c3:	0f 85 2d 02 00 00    	jne    f01013f6 <mem_init+0x4c3>
f01011c9:	89 d8                	mov    %ebx,%eax
f01011cb:	2b 05 70 89 11 f0    	sub    0xf0118970,%eax
f01011d1:	c1 f8 03             	sar    $0x3,%eax
f01011d4:	89 c2                	mov    %eax,%edx
f01011d6:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f01011d9:	25 ff ff 0f 00       	and    $0xfffff,%eax
f01011de:	3b 05 68 89 11 f0    	cmp    0xf0118968,%eax
f01011e4:	0f 83 25 02 00 00    	jae    f010140f <mem_init+0x4dc>
	memset(page2kva(pp0), 1, PGSIZE);
f01011ea:	83 ec 04             	sub    $0x4,%esp
f01011ed:	68 00 10 00 00       	push   $0x1000
f01011f2:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f01011f4:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f01011fa:	52                   	push   %edx
f01011fb:	e8 4c 20 00 00       	call   f010324c <memset>
	page_free(pp0);
f0101200:	89 1c 24             	mov    %ebx,(%esp)
f0101203:	e8 d2 fa ff ff       	call   f0100cda <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0101208:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f010120f:	e8 51 fa ff ff       	call   f0100c65 <page_alloc>
f0101214:	83 c4 10             	add    $0x10,%esp
f0101217:	85 c0                	test   %eax,%eax
f0101219:	0f 84 02 02 00 00    	je     f0101421 <mem_init+0x4ee>
	assert(pp && pp0 == pp);
f010121f:	39 c3                	cmp    %eax,%ebx
f0101221:	0f 85 13 02 00 00    	jne    f010143a <mem_init+0x507>
	return (pp - pages) << PGSHIFT;
f0101227:	2b 05 70 89 11 f0    	sub    0xf0118970,%eax
f010122d:	c1 f8 03             	sar    $0x3,%eax
f0101230:	89 c2                	mov    %eax,%edx
f0101232:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0101235:	25 ff ff 0f 00       	and    $0xfffff,%eax
f010123a:	3b 05 68 89 11 f0    	cmp    0xf0118968,%eax
f0101240:	0f 83 0d 02 00 00    	jae    f0101453 <mem_init+0x520>
	return (void *)(pa + KERNBASE);
f0101246:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
f010124c:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
		assert(c[i] == 0);
f0101252:	80 38 00             	cmpb   $0x0,(%eax)
f0101255:	0f 85 0a 02 00 00    	jne    f0101465 <mem_init+0x532>
f010125b:	40                   	inc    %eax
	for (i = 0; i < PGSIZE; i++)
f010125c:	39 d0                	cmp    %edx,%eax
f010125e:	75 f2                	jne    f0101252 <mem_init+0x31f>
	page_free_list = fl;
f0101260:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101263:	a3 3c 85 11 f0       	mov    %eax,0xf011853c
	page_free(pp0);
f0101268:	83 ec 0c             	sub    $0xc,%esp
f010126b:	53                   	push   %ebx
f010126c:	e8 69 fa ff ff       	call   f0100cda <page_free>
	page_free(pp1);
f0101271:	89 34 24             	mov    %esi,(%esp)
f0101274:	e8 61 fa ff ff       	call   f0100cda <page_free>
	page_free(pp2);
f0101279:	89 3c 24             	mov    %edi,(%esp)
f010127c:	e8 59 fa ff ff       	call   f0100cda <page_free>
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101281:	a1 3c 85 11 f0       	mov    0xf011853c,%eax
f0101286:	83 c4 10             	add    $0x10,%esp
f0101289:	85 c0                	test   %eax,%eax
f010128b:	0f 84 ed 01 00 00    	je     f010147e <mem_init+0x54b>
		--nfree;
f0101291:	ff 4d d4             	decl   -0x2c(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101294:	8b 00                	mov    (%eax),%eax
f0101296:	eb f1                	jmp    f0101289 <mem_init+0x356>
	assert((pp0 = page_alloc(0)));
f0101298:	68 f3 3b 10 f0       	push   $0xf0103bf3
f010129d:	68 31 3b 10 f0       	push   $0xf0103b31
f01012a2:	68 80 02 00 00       	push   $0x280
f01012a7:	68 0b 3b 10 f0       	push   $0xf0103b0b
f01012ac:	e8 da ed ff ff       	call   f010008b <_panic>
	assert((pp1 = page_alloc(0)));
f01012b1:	68 09 3c 10 f0       	push   $0xf0103c09
f01012b6:	68 31 3b 10 f0       	push   $0xf0103b31
f01012bb:	68 81 02 00 00       	push   $0x281
f01012c0:	68 0b 3b 10 f0       	push   $0xf0103b0b
f01012c5:	e8 c1 ed ff ff       	call   f010008b <_panic>
	assert((pp2 = page_alloc(0)));
f01012ca:	68 1f 3c 10 f0       	push   $0xf0103c1f
f01012cf:	68 31 3b 10 f0       	push   $0xf0103b31
f01012d4:	68 82 02 00 00       	push   $0x282
f01012d9:	68 0b 3b 10 f0       	push   $0xf0103b0b
f01012de:	e8 a8 ed ff ff       	call   f010008b <_panic>
	assert(pp1 && pp1 != pp0);
f01012e3:	68 35 3c 10 f0       	push   $0xf0103c35
f01012e8:	68 31 3b 10 f0       	push   $0xf0103b31
f01012ed:	68 85 02 00 00       	push   $0x285
f01012f2:	68 0b 3b 10 f0       	push   $0xf0103b0b
f01012f7:	e8 8f ed ff ff       	call   f010008b <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01012fc:	68 94 3f 10 f0       	push   $0xf0103f94
f0101301:	68 31 3b 10 f0       	push   $0xf0103b31
f0101306:	68 86 02 00 00       	push   $0x286
f010130b:	68 0b 3b 10 f0       	push   $0xf0103b0b
f0101310:	e8 76 ed ff ff       	call   f010008b <_panic>
	assert(page2pa(pp0) < npages*PGSIZE);
f0101315:	68 47 3c 10 f0       	push   $0xf0103c47
f010131a:	68 31 3b 10 f0       	push   $0xf0103b31
f010131f:	68 87 02 00 00       	push   $0x287
f0101324:	68 0b 3b 10 f0       	push   $0xf0103b0b
f0101329:	e8 5d ed ff ff       	call   f010008b <_panic>
	assert(page2pa(pp1) < npages*PGSIZE);
f010132e:	68 64 3c 10 f0       	push   $0xf0103c64
f0101333:	68 31 3b 10 f0       	push   $0xf0103b31
f0101338:	68 88 02 00 00       	push   $0x288
f010133d:	68 0b 3b 10 f0       	push   $0xf0103b0b
f0101342:	e8 44 ed ff ff       	call   f010008b <_panic>
	assert(page2pa(pp2) < npages*PGSIZE);
f0101347:	68 81 3c 10 f0       	push   $0xf0103c81
f010134c:	68 31 3b 10 f0       	push   $0xf0103b31
f0101351:	68 89 02 00 00       	push   $0x289
f0101356:	68 0b 3b 10 f0       	push   $0xf0103b0b
f010135b:	e8 2b ed ff ff       	call   f010008b <_panic>
	assert(!page_alloc(0));
f0101360:	68 9e 3c 10 f0       	push   $0xf0103c9e
f0101365:	68 31 3b 10 f0       	push   $0xf0103b31
f010136a:	68 90 02 00 00       	push   $0x290
f010136f:	68 0b 3b 10 f0       	push   $0xf0103b0b
f0101374:	e8 12 ed ff ff       	call   f010008b <_panic>
	assert((pp0 = page_alloc(0)));
f0101379:	68 f3 3b 10 f0       	push   $0xf0103bf3
f010137e:	68 31 3b 10 f0       	push   $0xf0103b31
f0101383:	68 97 02 00 00       	push   $0x297
f0101388:	68 0b 3b 10 f0       	push   $0xf0103b0b
f010138d:	e8 f9 ec ff ff       	call   f010008b <_panic>
	assert((pp1 = page_alloc(0)));
f0101392:	68 09 3c 10 f0       	push   $0xf0103c09
f0101397:	68 31 3b 10 f0       	push   $0xf0103b31
f010139c:	68 98 02 00 00       	push   $0x298
f01013a1:	68 0b 3b 10 f0       	push   $0xf0103b0b
f01013a6:	e8 e0 ec ff ff       	call   f010008b <_panic>
	assert((pp2 = page_alloc(0)));
f01013ab:	68 1f 3c 10 f0       	push   $0xf0103c1f
f01013b0:	68 31 3b 10 f0       	push   $0xf0103b31
f01013b5:	68 99 02 00 00       	push   $0x299
f01013ba:	68 0b 3b 10 f0       	push   $0xf0103b0b
f01013bf:	e8 c7 ec ff ff       	call   f010008b <_panic>
	assert(pp1 && pp1 != pp0);
f01013c4:	68 35 3c 10 f0       	push   $0xf0103c35
f01013c9:	68 31 3b 10 f0       	push   $0xf0103b31
f01013ce:	68 9b 02 00 00       	push   $0x29b
f01013d3:	68 0b 3b 10 f0       	push   $0xf0103b0b
f01013d8:	e8 ae ec ff ff       	call   f010008b <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01013dd:	68 94 3f 10 f0       	push   $0xf0103f94
f01013e2:	68 31 3b 10 f0       	push   $0xf0103b31
f01013e7:	68 9c 02 00 00       	push   $0x29c
f01013ec:	68 0b 3b 10 f0       	push   $0xf0103b0b
f01013f1:	e8 95 ec ff ff       	call   f010008b <_panic>
	assert(!page_alloc(0));
f01013f6:	68 9e 3c 10 f0       	push   $0xf0103c9e
f01013fb:	68 31 3b 10 f0       	push   $0xf0103b31
f0101400:	68 9d 02 00 00       	push   $0x29d
f0101405:	68 0b 3b 10 f0       	push   $0xf0103b0b
f010140a:	e8 7c ec ff ff       	call   f010008b <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010140f:	52                   	push   %edx
f0101410:	68 08 3e 10 f0       	push   $0xf0103e08
f0101415:	6a 52                	push   $0x52
f0101417:	68 17 3b 10 f0       	push   $0xf0103b17
f010141c:	e8 6a ec ff ff       	call   f010008b <_panic>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0101421:	68 ad 3c 10 f0       	push   $0xf0103cad
f0101426:	68 31 3b 10 f0       	push   $0xf0103b31
f010142b:	68 a2 02 00 00       	push   $0x2a2
f0101430:	68 0b 3b 10 f0       	push   $0xf0103b0b
f0101435:	e8 51 ec ff ff       	call   f010008b <_panic>
	assert(pp && pp0 == pp);
f010143a:	68 cb 3c 10 f0       	push   $0xf0103ccb
f010143f:	68 31 3b 10 f0       	push   $0xf0103b31
f0101444:	68 a3 02 00 00       	push   $0x2a3
f0101449:	68 0b 3b 10 f0       	push   $0xf0103b0b
f010144e:	e8 38 ec ff ff       	call   f010008b <_panic>
f0101453:	52                   	push   %edx
f0101454:	68 08 3e 10 f0       	push   $0xf0103e08
f0101459:	6a 52                	push   $0x52
f010145b:	68 17 3b 10 f0       	push   $0xf0103b17
f0101460:	e8 26 ec ff ff       	call   f010008b <_panic>
		assert(c[i] == 0);
f0101465:	68 db 3c 10 f0       	push   $0xf0103cdb
f010146a:	68 31 3b 10 f0       	push   $0xf0103b31
f010146f:	68 a6 02 00 00       	push   $0x2a6
f0101474:	68 0b 3b 10 f0       	push   $0xf0103b0b
f0101479:	e8 0d ec ff ff       	call   f010008b <_panic>
	assert(nfree == 0);
f010147e:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f0101482:	0f 85 a3 07 00 00    	jne    f0101c2b <mem_init+0xcf8>
	cprintf("check_page_alloc() succeeded!\n");
f0101488:	83 ec 0c             	sub    $0xc,%esp
f010148b:	68 b4 3f 10 f0       	push   $0xf0103fb4
f0101490:	e8 27 13 00 00       	call   f01027bc <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101495:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010149c:	e8 c4 f7 ff ff       	call   f0100c65 <page_alloc>
f01014a1:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01014a4:	83 c4 10             	add    $0x10,%esp
f01014a7:	85 c0                	test   %eax,%eax
f01014a9:	0f 84 95 07 00 00    	je     f0101c44 <mem_init+0xd11>
	assert((pp1 = page_alloc(0)));
f01014af:	83 ec 0c             	sub    $0xc,%esp
f01014b2:	6a 00                	push   $0x0
f01014b4:	e8 ac f7 ff ff       	call   f0100c65 <page_alloc>
f01014b9:	89 c6                	mov    %eax,%esi
f01014bb:	83 c4 10             	add    $0x10,%esp
f01014be:	85 c0                	test   %eax,%eax
f01014c0:	0f 84 97 07 00 00    	je     f0101c5d <mem_init+0xd2a>
	assert((pp2 = page_alloc(0)));
f01014c6:	83 ec 0c             	sub    $0xc,%esp
f01014c9:	6a 00                	push   $0x0
f01014cb:	e8 95 f7 ff ff       	call   f0100c65 <page_alloc>
f01014d0:	89 c3                	mov    %eax,%ebx
f01014d2:	83 c4 10             	add    $0x10,%esp
f01014d5:	85 c0                	test   %eax,%eax
f01014d7:	0f 84 99 07 00 00    	je     f0101c76 <mem_init+0xd43>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f01014dd:	39 75 d4             	cmp    %esi,-0x2c(%ebp)
f01014e0:	0f 84 a9 07 00 00    	je     f0101c8f <mem_init+0xd5c>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01014e6:	39 c6                	cmp    %eax,%esi
f01014e8:	0f 84 ba 07 00 00    	je     f0101ca8 <mem_init+0xd75>
f01014ee:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f01014f1:	0f 84 b1 07 00 00    	je     f0101ca8 <mem_init+0xd75>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f01014f7:	a1 3c 85 11 f0       	mov    0xf011853c,%eax
f01014fc:	89 45 cc             	mov    %eax,-0x34(%ebp)
	page_free_list = 0;
f01014ff:	c7 05 3c 85 11 f0 00 	movl   $0x0,0xf011853c
f0101506:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101509:	83 ec 0c             	sub    $0xc,%esp
f010150c:	6a 00                	push   $0x0
f010150e:	e8 52 f7 ff ff       	call   f0100c65 <page_alloc>
f0101513:	83 c4 10             	add    $0x10,%esp
f0101516:	85 c0                	test   %eax,%eax
f0101518:	0f 85 a3 07 00 00    	jne    f0101cc1 <mem_init+0xd8e>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f010151e:	83 ec 04             	sub    $0x4,%esp
f0101521:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101524:	50                   	push   %eax
f0101525:	6a 00                	push   $0x0
f0101527:	ff 35 6c 89 11 f0    	pushl  0xf011896c
f010152d:	e8 e9 f8 ff ff       	call   f0100e1b <page_lookup>
f0101532:	83 c4 10             	add    $0x10,%esp
f0101535:	85 c0                	test   %eax,%eax
f0101537:	0f 85 9d 07 00 00    	jne    f0101cda <mem_init+0xda7>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f010153d:	6a 02                	push   $0x2
f010153f:	6a 00                	push   $0x0
f0101541:	56                   	push   %esi
f0101542:	ff 35 6c 89 11 f0    	pushl  0xf011896c
f0101548:	e8 68 f9 ff ff       	call   f0100eb5 <page_insert>
f010154d:	83 c4 10             	add    $0x10,%esp
f0101550:	85 c0                	test   %eax,%eax
f0101552:	0f 89 9b 07 00 00    	jns    f0101cf3 <mem_init+0xdc0>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f0101558:	83 ec 0c             	sub    $0xc,%esp
f010155b:	ff 75 d4             	pushl  -0x2c(%ebp)
f010155e:	e8 77 f7 ff ff       	call   f0100cda <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0101563:	6a 02                	push   $0x2
f0101565:	6a 00                	push   $0x0
f0101567:	56                   	push   %esi
f0101568:	ff 35 6c 89 11 f0    	pushl  0xf011896c
f010156e:	e8 42 f9 ff ff       	call   f0100eb5 <page_insert>
f0101573:	83 c4 20             	add    $0x20,%esp
f0101576:	85 c0                	test   %eax,%eax
f0101578:	0f 85 8e 07 00 00    	jne    f0101d0c <mem_init+0xdd9>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f010157e:	8b 3d 6c 89 11 f0    	mov    0xf011896c,%edi
	return (pp - pages) << PGSHIFT;
f0101584:	8b 0d 70 89 11 f0    	mov    0xf0118970,%ecx
f010158a:	89 4d d0             	mov    %ecx,-0x30(%ebp)
f010158d:	8b 17                	mov    (%edi),%edx
f010158f:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101595:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101598:	29 c8                	sub    %ecx,%eax
f010159a:	c1 f8 03             	sar    $0x3,%eax
f010159d:	c1 e0 0c             	shl    $0xc,%eax
f01015a0:	39 c2                	cmp    %eax,%edx
f01015a2:	0f 85 7d 07 00 00    	jne    f0101d25 <mem_init+0xdf2>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f01015a8:	ba 00 00 00 00       	mov    $0x0,%edx
f01015ad:	89 f8                	mov    %edi,%eax
f01015af:	e8 e1 f2 ff ff       	call   f0100895 <check_va2pa>
f01015b4:	89 c2                	mov    %eax,%edx
f01015b6:	89 f0                	mov    %esi,%eax
f01015b8:	2b 45 d0             	sub    -0x30(%ebp),%eax
f01015bb:	c1 f8 03             	sar    $0x3,%eax
f01015be:	c1 e0 0c             	shl    $0xc,%eax
f01015c1:	39 c2                	cmp    %eax,%edx
f01015c3:	0f 85 75 07 00 00    	jne    f0101d3e <mem_init+0xe0b>
	assert(pp1->pp_ref == 1);
f01015c9:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f01015ce:	0f 85 83 07 00 00    	jne    f0101d57 <mem_init+0xe24>
	assert(pp0->pp_ref == 1);
f01015d4:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01015d7:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f01015dc:	0f 85 8e 07 00 00    	jne    f0101d70 <mem_init+0xe3d>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f01015e2:	6a 02                	push   $0x2
f01015e4:	68 00 10 00 00       	push   $0x1000
f01015e9:	53                   	push   %ebx
f01015ea:	57                   	push   %edi
f01015eb:	e8 c5 f8 ff ff       	call   f0100eb5 <page_insert>
f01015f0:	83 c4 10             	add    $0x10,%esp
f01015f3:	85 c0                	test   %eax,%eax
f01015f5:	0f 85 8e 07 00 00    	jne    f0101d89 <mem_init+0xe56>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01015fb:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101600:	a1 6c 89 11 f0       	mov    0xf011896c,%eax
f0101605:	e8 8b f2 ff ff       	call   f0100895 <check_va2pa>
f010160a:	89 c2                	mov    %eax,%edx
f010160c:	89 d8                	mov    %ebx,%eax
f010160e:	2b 05 70 89 11 f0    	sub    0xf0118970,%eax
f0101614:	c1 f8 03             	sar    $0x3,%eax
f0101617:	c1 e0 0c             	shl    $0xc,%eax
f010161a:	39 c2                	cmp    %eax,%edx
f010161c:	0f 85 80 07 00 00    	jne    f0101da2 <mem_init+0xe6f>
	assert(pp2->pp_ref == 1);
f0101622:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101627:	0f 85 8e 07 00 00    	jne    f0101dbb <mem_init+0xe88>
	// should be no free memory
	assert(!page_alloc(0));
f010162d:	83 ec 0c             	sub    $0xc,%esp
f0101630:	6a 00                	push   $0x0
f0101632:	e8 2e f6 ff ff       	call   f0100c65 <page_alloc>
f0101637:	83 c4 10             	add    $0x10,%esp
f010163a:	85 c0                	test   %eax,%eax
f010163c:	0f 85 92 07 00 00    	jne    f0101dd4 <mem_init+0xea1>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101642:	6a 02                	push   $0x2
f0101644:	68 00 10 00 00       	push   $0x1000
f0101649:	53                   	push   %ebx
f010164a:	ff 35 6c 89 11 f0    	pushl  0xf011896c
f0101650:	e8 60 f8 ff ff       	call   f0100eb5 <page_insert>
f0101655:	83 c4 10             	add    $0x10,%esp
f0101658:	85 c0                	test   %eax,%eax
f010165a:	0f 85 8d 07 00 00    	jne    f0101ded <mem_init+0xeba>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101660:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101665:	a1 6c 89 11 f0       	mov    0xf011896c,%eax
f010166a:	e8 26 f2 ff ff       	call   f0100895 <check_va2pa>
f010166f:	89 c2                	mov    %eax,%edx
f0101671:	89 d8                	mov    %ebx,%eax
f0101673:	2b 05 70 89 11 f0    	sub    0xf0118970,%eax
f0101679:	c1 f8 03             	sar    $0x3,%eax
f010167c:	c1 e0 0c             	shl    $0xc,%eax
f010167f:	39 c2                	cmp    %eax,%edx
f0101681:	0f 85 7f 07 00 00    	jne    f0101e06 <mem_init+0xed3>
	assert(pp2->pp_ref == 1);
f0101687:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f010168c:	0f 85 8d 07 00 00    	jne    f0101e1f <mem_init+0xeec>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0101692:	83 ec 0c             	sub    $0xc,%esp
f0101695:	6a 00                	push   $0x0
f0101697:	e8 c9 f5 ff ff       	call   f0100c65 <page_alloc>
f010169c:	83 c4 10             	add    $0x10,%esp
f010169f:	85 c0                	test   %eax,%eax
f01016a1:	0f 85 91 07 00 00    	jne    f0101e38 <mem_init+0xf05>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f01016a7:	8b 0d 6c 89 11 f0    	mov    0xf011896c,%ecx
f01016ad:	8b 01                	mov    (%ecx),%eax
f01016af:	89 c2                	mov    %eax,%edx
f01016b1:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
	if (PGNUM(pa) >= npages)
f01016b7:	c1 e8 0c             	shr    $0xc,%eax
f01016ba:	3b 05 68 89 11 f0    	cmp    0xf0118968,%eax
f01016c0:	0f 83 8b 07 00 00    	jae    f0101e51 <mem_init+0xf1e>
	return (void *)(pa + KERNBASE);
f01016c6:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f01016cc:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f01016cf:	83 ec 04             	sub    $0x4,%esp
f01016d2:	6a 00                	push   $0x0
f01016d4:	68 00 10 00 00       	push   $0x1000
f01016d9:	51                   	push   %ecx
f01016da:	e8 5c f6 ff ff       	call   f0100d3b <pgdir_walk>
f01016df:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f01016e2:	8d 51 04             	lea    0x4(%ecx),%edx
f01016e5:	83 c4 10             	add    $0x10,%esp
f01016e8:	39 c2                	cmp    %eax,%edx
f01016ea:	0f 85 76 07 00 00    	jne    f0101e66 <mem_init+0xf33>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f01016f0:	6a 06                	push   $0x6
f01016f2:	68 00 10 00 00       	push   $0x1000
f01016f7:	53                   	push   %ebx
f01016f8:	ff 35 6c 89 11 f0    	pushl  0xf011896c
f01016fe:	e8 b2 f7 ff ff       	call   f0100eb5 <page_insert>
f0101703:	83 c4 10             	add    $0x10,%esp
f0101706:	85 c0                	test   %eax,%eax
f0101708:	0f 85 71 07 00 00    	jne    f0101e7f <mem_init+0xf4c>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f010170e:	8b 3d 6c 89 11 f0    	mov    0xf011896c,%edi
f0101714:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101719:	89 f8                	mov    %edi,%eax
f010171b:	e8 75 f1 ff ff       	call   f0100895 <check_va2pa>
f0101720:	89 c2                	mov    %eax,%edx
	return (pp - pages) << PGSHIFT;
f0101722:	89 d8                	mov    %ebx,%eax
f0101724:	2b 05 70 89 11 f0    	sub    0xf0118970,%eax
f010172a:	c1 f8 03             	sar    $0x3,%eax
f010172d:	c1 e0 0c             	shl    $0xc,%eax
f0101730:	39 c2                	cmp    %eax,%edx
f0101732:	0f 85 60 07 00 00    	jne    f0101e98 <mem_init+0xf65>
	assert(pp2->pp_ref == 1);
f0101738:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f010173d:	0f 85 6e 07 00 00    	jne    f0101eb1 <mem_init+0xf7e>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0101743:	83 ec 04             	sub    $0x4,%esp
f0101746:	6a 00                	push   $0x0
f0101748:	68 00 10 00 00       	push   $0x1000
f010174d:	57                   	push   %edi
f010174e:	e8 e8 f5 ff ff       	call   f0100d3b <pgdir_walk>
f0101753:	83 c4 10             	add    $0x10,%esp
f0101756:	f6 00 04             	testb  $0x4,(%eax)
f0101759:	0f 84 6b 07 00 00    	je     f0101eca <mem_init+0xf97>
	assert(kern_pgdir[0] & PTE_U);
f010175f:	a1 6c 89 11 f0       	mov    0xf011896c,%eax
f0101764:	f6 00 04             	testb  $0x4,(%eax)
f0101767:	0f 84 76 07 00 00    	je     f0101ee3 <mem_init+0xfb0>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f010176d:	6a 02                	push   $0x2
f010176f:	68 00 10 00 00       	push   $0x1000
f0101774:	53                   	push   %ebx
f0101775:	50                   	push   %eax
f0101776:	e8 3a f7 ff ff       	call   f0100eb5 <page_insert>
f010177b:	83 c4 10             	add    $0x10,%esp
f010177e:	85 c0                	test   %eax,%eax
f0101780:	0f 85 76 07 00 00    	jne    f0101efc <mem_init+0xfc9>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0101786:	83 ec 04             	sub    $0x4,%esp
f0101789:	6a 00                	push   $0x0
f010178b:	68 00 10 00 00       	push   $0x1000
f0101790:	ff 35 6c 89 11 f0    	pushl  0xf011896c
f0101796:	e8 a0 f5 ff ff       	call   f0100d3b <pgdir_walk>
f010179b:	83 c4 10             	add    $0x10,%esp
f010179e:	f6 00 02             	testb  $0x2,(%eax)
f01017a1:	0f 84 6e 07 00 00    	je     f0101f15 <mem_init+0xfe2>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f01017a7:	83 ec 04             	sub    $0x4,%esp
f01017aa:	6a 00                	push   $0x0
f01017ac:	68 00 10 00 00       	push   $0x1000
f01017b1:	ff 35 6c 89 11 f0    	pushl  0xf011896c
f01017b7:	e8 7f f5 ff ff       	call   f0100d3b <pgdir_walk>
f01017bc:	83 c4 10             	add    $0x10,%esp
f01017bf:	f6 00 04             	testb  $0x4,(%eax)
f01017c2:	0f 85 66 07 00 00    	jne    f0101f2e <mem_init+0xffb>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f01017c8:	6a 02                	push   $0x2
f01017ca:	68 00 00 40 00       	push   $0x400000
f01017cf:	ff 75 d4             	pushl  -0x2c(%ebp)
f01017d2:	ff 35 6c 89 11 f0    	pushl  0xf011896c
f01017d8:	e8 d8 f6 ff ff       	call   f0100eb5 <page_insert>
f01017dd:	83 c4 10             	add    $0x10,%esp
f01017e0:	85 c0                	test   %eax,%eax
f01017e2:	0f 89 5f 07 00 00    	jns    f0101f47 <mem_init+0x1014>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f01017e8:	6a 02                	push   $0x2
f01017ea:	68 00 10 00 00       	push   $0x1000
f01017ef:	56                   	push   %esi
f01017f0:	ff 35 6c 89 11 f0    	pushl  0xf011896c
f01017f6:	e8 ba f6 ff ff       	call   f0100eb5 <page_insert>
f01017fb:	83 c4 10             	add    $0x10,%esp
f01017fe:	85 c0                	test   %eax,%eax
f0101800:	0f 85 5a 07 00 00    	jne    f0101f60 <mem_init+0x102d>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101806:	83 ec 04             	sub    $0x4,%esp
f0101809:	6a 00                	push   $0x0
f010180b:	68 00 10 00 00       	push   $0x1000
f0101810:	ff 35 6c 89 11 f0    	pushl  0xf011896c
f0101816:	e8 20 f5 ff ff       	call   f0100d3b <pgdir_walk>
f010181b:	83 c4 10             	add    $0x10,%esp
f010181e:	f6 00 04             	testb  $0x4,(%eax)
f0101821:	0f 85 52 07 00 00    	jne    f0101f79 <mem_init+0x1046>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0101827:	a1 6c 89 11 f0       	mov    0xf011896c,%eax
f010182c:	89 45 d0             	mov    %eax,-0x30(%ebp)
f010182f:	ba 00 00 00 00       	mov    $0x0,%edx
f0101834:	e8 5c f0 ff ff       	call   f0100895 <check_va2pa>
f0101839:	89 f7                	mov    %esi,%edi
f010183b:	2b 3d 70 89 11 f0    	sub    0xf0118970,%edi
f0101841:	c1 ff 03             	sar    $0x3,%edi
f0101844:	c1 e7 0c             	shl    $0xc,%edi
f0101847:	39 f8                	cmp    %edi,%eax
f0101849:	0f 85 43 07 00 00    	jne    f0101f92 <mem_init+0x105f>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f010184f:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101854:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101857:	e8 39 f0 ff ff       	call   f0100895 <check_va2pa>
f010185c:	39 c7                	cmp    %eax,%edi
f010185e:	0f 85 47 07 00 00    	jne    f0101fab <mem_init+0x1078>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0101864:	66 83 7e 04 02       	cmpw   $0x2,0x4(%esi)
f0101869:	0f 85 55 07 00 00    	jne    f0101fc4 <mem_init+0x1091>
	assert(pp2->pp_ref == 0);
f010186f:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101874:	0f 85 63 07 00 00    	jne    f0101fdd <mem_init+0x10aa>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f010187a:	83 ec 0c             	sub    $0xc,%esp
f010187d:	6a 00                	push   $0x0
f010187f:	e8 e1 f3 ff ff       	call   f0100c65 <page_alloc>
f0101884:	83 c4 10             	add    $0x10,%esp
f0101887:	85 c0                	test   %eax,%eax
f0101889:	0f 84 67 07 00 00    	je     f0101ff6 <mem_init+0x10c3>
f010188f:	39 c3                	cmp    %eax,%ebx
f0101891:	0f 85 5f 07 00 00    	jne    f0101ff6 <mem_init+0x10c3>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f0101897:	83 ec 08             	sub    $0x8,%esp
f010189a:	6a 00                	push   $0x0
f010189c:	ff 35 6c 89 11 f0    	pushl  0xf011896c
f01018a2:	e8 d3 f5 ff ff       	call   f0100e7a <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f01018a7:	8b 3d 6c 89 11 f0    	mov    0xf011896c,%edi
f01018ad:	ba 00 00 00 00       	mov    $0x0,%edx
f01018b2:	89 f8                	mov    %edi,%eax
f01018b4:	e8 dc ef ff ff       	call   f0100895 <check_va2pa>
f01018b9:	83 c4 10             	add    $0x10,%esp
f01018bc:	83 f8 ff             	cmp    $0xffffffff,%eax
f01018bf:	0f 85 4a 07 00 00    	jne    f010200f <mem_init+0x10dc>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f01018c5:	ba 00 10 00 00       	mov    $0x1000,%edx
f01018ca:	89 f8                	mov    %edi,%eax
f01018cc:	e8 c4 ef ff ff       	call   f0100895 <check_va2pa>
f01018d1:	89 c2                	mov    %eax,%edx
f01018d3:	89 f0                	mov    %esi,%eax
f01018d5:	2b 05 70 89 11 f0    	sub    0xf0118970,%eax
f01018db:	c1 f8 03             	sar    $0x3,%eax
f01018de:	c1 e0 0c             	shl    $0xc,%eax
f01018e1:	39 c2                	cmp    %eax,%edx
f01018e3:	0f 85 3f 07 00 00    	jne    f0102028 <mem_init+0x10f5>
	assert(pp1->pp_ref == 1);
f01018e9:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f01018ee:	0f 85 4d 07 00 00    	jne    f0102041 <mem_init+0x110e>
	assert(pp2->pp_ref == 0);
f01018f4:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f01018f9:	0f 85 5b 07 00 00    	jne    f010205a <mem_init+0x1127>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f01018ff:	6a 00                	push   $0x0
f0101901:	68 00 10 00 00       	push   $0x1000
f0101906:	56                   	push   %esi
f0101907:	57                   	push   %edi
f0101908:	e8 a8 f5 ff ff       	call   f0100eb5 <page_insert>
f010190d:	83 c4 10             	add    $0x10,%esp
f0101910:	85 c0                	test   %eax,%eax
f0101912:	0f 85 5b 07 00 00    	jne    f0102073 <mem_init+0x1140>
	assert(pp1->pp_ref);
f0101918:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f010191d:	0f 84 69 07 00 00    	je     f010208c <mem_init+0x1159>
	assert(pp1->pp_link == NULL);
f0101923:	83 3e 00             	cmpl   $0x0,(%esi)
f0101926:	0f 85 79 07 00 00    	jne    f01020a5 <mem_init+0x1172>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f010192c:	83 ec 08             	sub    $0x8,%esp
f010192f:	68 00 10 00 00       	push   $0x1000
f0101934:	ff 35 6c 89 11 f0    	pushl  0xf011896c
f010193a:	e8 3b f5 ff ff       	call   f0100e7a <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f010193f:	8b 3d 6c 89 11 f0    	mov    0xf011896c,%edi
f0101945:	ba 00 00 00 00       	mov    $0x0,%edx
f010194a:	89 f8                	mov    %edi,%eax
f010194c:	e8 44 ef ff ff       	call   f0100895 <check_va2pa>
f0101951:	83 c4 10             	add    $0x10,%esp
f0101954:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101957:	0f 85 61 07 00 00    	jne    f01020be <mem_init+0x118b>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f010195d:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101962:	89 f8                	mov    %edi,%eax
f0101964:	e8 2c ef ff ff       	call   f0100895 <check_va2pa>
f0101969:	83 f8 ff             	cmp    $0xffffffff,%eax
f010196c:	0f 85 65 07 00 00    	jne    f01020d7 <mem_init+0x11a4>
	assert(pp1->pp_ref == 0);
f0101972:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101977:	0f 85 73 07 00 00    	jne    f01020f0 <mem_init+0x11bd>
	assert(pp2->pp_ref == 0);
f010197d:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101982:	0f 85 81 07 00 00    	jne    f0102109 <mem_init+0x11d6>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f0101988:	83 ec 0c             	sub    $0xc,%esp
f010198b:	6a 00                	push   $0x0
f010198d:	e8 d3 f2 ff ff       	call   f0100c65 <page_alloc>
f0101992:	83 c4 10             	add    $0x10,%esp
f0101995:	85 c0                	test   %eax,%eax
f0101997:	0f 84 85 07 00 00    	je     f0102122 <mem_init+0x11ef>
f010199d:	39 c6                	cmp    %eax,%esi
f010199f:	0f 85 7d 07 00 00    	jne    f0102122 <mem_init+0x11ef>

	// should be no free memory
	assert(!page_alloc(0));
f01019a5:	83 ec 0c             	sub    $0xc,%esp
f01019a8:	6a 00                	push   $0x0
f01019aa:	e8 b6 f2 ff ff       	call   f0100c65 <page_alloc>
f01019af:	83 c4 10             	add    $0x10,%esp
f01019b2:	85 c0                	test   %eax,%eax
f01019b4:	0f 85 81 07 00 00    	jne    f010213b <mem_init+0x1208>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01019ba:	8b 0d 6c 89 11 f0    	mov    0xf011896c,%ecx
f01019c0:	8b 11                	mov    (%ecx),%edx
f01019c2:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01019c8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01019cb:	2b 05 70 89 11 f0    	sub    0xf0118970,%eax
f01019d1:	c1 f8 03             	sar    $0x3,%eax
f01019d4:	c1 e0 0c             	shl    $0xc,%eax
f01019d7:	39 c2                	cmp    %eax,%edx
f01019d9:	0f 85 75 07 00 00    	jne    f0102154 <mem_init+0x1221>
	kern_pgdir[0] = 0;
f01019df:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f01019e5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01019e8:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f01019ed:	0f 85 7a 07 00 00    	jne    f010216d <mem_init+0x123a>
	pp0->pp_ref = 0;
f01019f3:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01019f6:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f01019fc:	83 ec 0c             	sub    $0xc,%esp
f01019ff:	50                   	push   %eax
f0101a00:	e8 d5 f2 ff ff       	call   f0100cda <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f0101a05:	83 c4 0c             	add    $0xc,%esp
f0101a08:	6a 01                	push   $0x1
f0101a0a:	68 00 10 40 00       	push   $0x401000
f0101a0f:	ff 35 6c 89 11 f0    	pushl  0xf011896c
f0101a15:	e8 21 f3 ff ff       	call   f0100d3b <pgdir_walk>
f0101a1a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f0101a1d:	8b 0d 6c 89 11 f0    	mov    0xf011896c,%ecx
f0101a23:	8b 51 04             	mov    0x4(%ecx),%edx
f0101a26:	89 d7                	mov    %edx,%edi
f0101a28:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
f0101a2e:	89 7d d0             	mov    %edi,-0x30(%ebp)
	if (PGNUM(pa) >= npages)
f0101a31:	8b 3d 68 89 11 f0    	mov    0xf0118968,%edi
f0101a37:	c1 ea 0c             	shr    $0xc,%edx
f0101a3a:	83 c4 10             	add    $0x10,%esp
f0101a3d:	39 fa                	cmp    %edi,%edx
f0101a3f:	0f 83 41 07 00 00    	jae    f0102186 <mem_init+0x1253>
	assert(ptep == ptep1 + PTX(va));
f0101a45:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0101a48:	81 ea fc ff ff 0f    	sub    $0xffffffc,%edx
f0101a4e:	39 d0                	cmp    %edx,%eax
f0101a50:	0f 85 47 07 00 00    	jne    f010219d <mem_init+0x126a>
	kern_pgdir[PDX(va)] = 0;
f0101a56:	c7 41 04 00 00 00 00 	movl   $0x0,0x4(%ecx)
	pp0->pp_ref = 0;
f0101a5d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101a60:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
	return (pp - pages) << PGSHIFT;
f0101a66:	2b 05 70 89 11 f0    	sub    0xf0118970,%eax
f0101a6c:	c1 f8 03             	sar    $0x3,%eax
f0101a6f:	89 c2                	mov    %eax,%edx
f0101a71:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0101a74:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0101a79:	39 c7                	cmp    %eax,%edi
f0101a7b:	0f 86 35 07 00 00    	jbe    f01021b6 <mem_init+0x1283>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f0101a81:	83 ec 04             	sub    $0x4,%esp
f0101a84:	68 00 10 00 00       	push   $0x1000
f0101a89:	68 ff 00 00 00       	push   $0xff
	return (void *)(pa + KERNBASE);
f0101a8e:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f0101a94:	52                   	push   %edx
f0101a95:	e8 b2 17 00 00       	call   f010324c <memset>
	page_free(pp0);
f0101a9a:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0101a9d:	89 3c 24             	mov    %edi,(%esp)
f0101aa0:	e8 35 f2 ff ff       	call   f0100cda <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f0101aa5:	83 c4 0c             	add    $0xc,%esp
f0101aa8:	6a 01                	push   $0x1
f0101aaa:	6a 00                	push   $0x0
f0101aac:	ff 35 6c 89 11 f0    	pushl  0xf011896c
f0101ab2:	e8 84 f2 ff ff       	call   f0100d3b <pgdir_walk>
	return (pp - pages) << PGSHIFT;
f0101ab7:	89 f8                	mov    %edi,%eax
f0101ab9:	2b 05 70 89 11 f0    	sub    0xf0118970,%eax
f0101abf:	c1 f8 03             	sar    $0x3,%eax
f0101ac2:	89 c2                	mov    %eax,%edx
f0101ac4:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0101ac7:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0101acc:	83 c4 10             	add    $0x10,%esp
f0101acf:	3b 05 68 89 11 f0    	cmp    0xf0118968,%eax
f0101ad5:	0f 83 ed 06 00 00    	jae    f01021c8 <mem_init+0x1295>
	return (void *)(pa + KERNBASE);
f0101adb:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f0101ae1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0101ae4:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0101aea:	8b 38                	mov    (%eax),%edi
f0101aec:	83 e7 01             	and    $0x1,%edi
f0101aef:	0f 85 e5 06 00 00    	jne    f01021da <mem_init+0x12a7>
f0101af5:	83 c0 04             	add    $0x4,%eax
	for(i=0; i<NPTENTRIES; i++)
f0101af8:	39 d0                	cmp    %edx,%eax
f0101afa:	75 ee                	jne    f0101aea <mem_init+0xbb7>
	kern_pgdir[0] = 0;
f0101afc:	a1 6c 89 11 f0       	mov    0xf011896c,%eax
f0101b01:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f0101b07:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101b0a:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// give free list back
	page_free_list = fl;
f0101b10:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0101b13:	89 0d 3c 85 11 f0    	mov    %ecx,0xf011853c

	// free the pages we took
	page_free(pp0);
f0101b19:	83 ec 0c             	sub    $0xc,%esp
f0101b1c:	50                   	push   %eax
f0101b1d:	e8 b8 f1 ff ff       	call   f0100cda <page_free>
	page_free(pp1);
f0101b22:	89 34 24             	mov    %esi,(%esp)
f0101b25:	e8 b0 f1 ff ff       	call   f0100cda <page_free>
	page_free(pp2);
f0101b2a:	89 1c 24             	mov    %ebx,(%esp)
f0101b2d:	e8 a8 f1 ff ff       	call   f0100cda <page_free>

	cprintf("check_page() succeeded!\n");
f0101b32:	c7 04 24 bc 3d 10 f0 	movl   $0xf0103dbc,(%esp)
f0101b39:	e8 7e 0c 00 00       	call   f01027bc <cprintf>
	boot_map_region(kern_pgdir, UPAGES, PTSIZE, PADDR((void *)pages), PTE_U | PTE_P);
f0101b3e:	a1 70 89 11 f0       	mov    0xf0118970,%eax
	if ((uint32_t)kva < KERNBASE)
f0101b43:	83 c4 10             	add    $0x10,%esp
f0101b46:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101b4b:	0f 86 a2 06 00 00    	jbe    f01021f3 <mem_init+0x12c0>
f0101b51:	83 ec 08             	sub    $0x8,%esp
f0101b54:	6a 05                	push   $0x5
	return (physaddr_t)kva - KERNBASE;
f0101b56:	05 00 00 00 10       	add    $0x10000000,%eax
f0101b5b:	50                   	push   %eax
f0101b5c:	b9 00 00 40 00       	mov    $0x400000,%ecx
f0101b61:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f0101b66:	a1 6c 89 11 f0       	mov    0xf011896c,%eax
f0101b6b:	e8 57 f2 ff ff       	call   f0100dc7 <boot_map_region>
	if ((uint32_t)kva < KERNBASE)
f0101b70:	83 c4 10             	add    $0x10,%esp
f0101b73:	b8 00 e0 10 f0       	mov    $0xf010e000,%eax
f0101b78:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101b7d:	0f 86 85 06 00 00    	jbe    f0102208 <mem_init+0x12d5>
	boot_map_region(kern_pgdir, KSTACKTOP - KSTKSIZE, KSTKSIZE, PADDR((void *)(bootstack)), PTE_P | PTE_W);
f0101b83:	83 ec 08             	sub    $0x8,%esp
f0101b86:	6a 03                	push   $0x3
f0101b88:	68 00 e0 10 00       	push   $0x10e000
f0101b8d:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0101b92:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f0101b97:	a1 6c 89 11 f0       	mov    0xf011896c,%eax
f0101b9c:	e8 26 f2 ff ff       	call   f0100dc7 <boot_map_region>
	boot_map_region(kern_pgdir, KERNBASE, (1ULL << 32) - KERNBASE, PADDR((void *)KERNBASE), PTE_P | PTE_W);
f0101ba1:	83 c4 08             	add    $0x8,%esp
f0101ba4:	6a 03                	push   $0x3
f0101ba6:	6a 00                	push   $0x0
f0101ba8:	b9 00 00 00 10       	mov    $0x10000000,%ecx
f0101bad:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f0101bb2:	a1 6c 89 11 f0       	mov    0xf011896c,%eax
f0101bb7:	e8 0b f2 ff ff       	call   f0100dc7 <boot_map_region>
	pgdir = kern_pgdir;
f0101bbc:	a1 6c 89 11 f0       	mov    0xf011896c,%eax
f0101bc1:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f0101bc4:	8b 35 68 89 11 f0    	mov    0xf0118968,%esi
f0101bca:	8d 04 f5 ff 0f 00 00 	lea    0xfff(,%esi,8),%eax
f0101bd1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0101bd6:	89 45 d0             	mov    %eax,-0x30(%ebp)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0101bd9:	a1 70 89 11 f0       	mov    0xf0118970,%eax
f0101bde:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f0101be1:	89 45 cc             	mov    %eax,-0x34(%ebp)
	return (physaddr_t)kva - KERNBASE;
f0101be4:	05 00 00 00 10       	add    $0x10000000,%eax
f0101be9:	89 45 c8             	mov    %eax,-0x38(%ebp)
	for (i = 0; i < n; i += PGSIZE)
f0101bec:	83 c4 10             	add    $0x10,%esp
f0101bef:	89 fb                	mov    %edi,%ebx
f0101bf1:	39 5d d0             	cmp    %ebx,-0x30(%ebp)
f0101bf4:	0f 86 53 06 00 00    	jbe    f010224d <mem_init+0x131a>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0101bfa:	8d 93 00 00 00 ef    	lea    -0x11000000(%ebx),%edx
f0101c00:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101c03:	e8 8d ec ff ff       	call   f0100895 <check_va2pa>
	if ((uint32_t)kva < KERNBASE)
f0101c08:	81 7d cc ff ff ff ef 	cmpl   $0xefffffff,-0x34(%ebp)
f0101c0f:	0f 86 08 06 00 00    	jbe    f010221d <mem_init+0x12ea>
f0101c15:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0101c18:	8d 14 0b             	lea    (%ebx,%ecx,1),%edx
f0101c1b:	39 c2                	cmp    %eax,%edx
f0101c1d:	0f 85 11 06 00 00    	jne    f0102234 <mem_init+0x1301>
	for (i = 0; i < n; i += PGSIZE)
f0101c23:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0101c29:	eb c6                	jmp    f0101bf1 <mem_init+0xcbe>
	assert(nfree == 0);
f0101c2b:	68 e5 3c 10 f0       	push   $0xf0103ce5
f0101c30:	68 31 3b 10 f0       	push   $0xf0103b31
f0101c35:	68 b3 02 00 00       	push   $0x2b3
f0101c3a:	68 0b 3b 10 f0       	push   $0xf0103b0b
f0101c3f:	e8 47 e4 ff ff       	call   f010008b <_panic>
	assert((pp0 = page_alloc(0)));
f0101c44:	68 f3 3b 10 f0       	push   $0xf0103bf3
f0101c49:	68 31 3b 10 f0       	push   $0xf0103b31
f0101c4e:	68 0c 03 00 00       	push   $0x30c
f0101c53:	68 0b 3b 10 f0       	push   $0xf0103b0b
f0101c58:	e8 2e e4 ff ff       	call   f010008b <_panic>
	assert((pp1 = page_alloc(0)));
f0101c5d:	68 09 3c 10 f0       	push   $0xf0103c09
f0101c62:	68 31 3b 10 f0       	push   $0xf0103b31
f0101c67:	68 0d 03 00 00       	push   $0x30d
f0101c6c:	68 0b 3b 10 f0       	push   $0xf0103b0b
f0101c71:	e8 15 e4 ff ff       	call   f010008b <_panic>
	assert((pp2 = page_alloc(0)));
f0101c76:	68 1f 3c 10 f0       	push   $0xf0103c1f
f0101c7b:	68 31 3b 10 f0       	push   $0xf0103b31
f0101c80:	68 0e 03 00 00       	push   $0x30e
f0101c85:	68 0b 3b 10 f0       	push   $0xf0103b0b
f0101c8a:	e8 fc e3 ff ff       	call   f010008b <_panic>
	assert(pp1 && pp1 != pp0);
f0101c8f:	68 35 3c 10 f0       	push   $0xf0103c35
f0101c94:	68 31 3b 10 f0       	push   $0xf0103b31
f0101c99:	68 11 03 00 00       	push   $0x311
f0101c9e:	68 0b 3b 10 f0       	push   $0xf0103b0b
f0101ca3:	e8 e3 e3 ff ff       	call   f010008b <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101ca8:	68 94 3f 10 f0       	push   $0xf0103f94
f0101cad:	68 31 3b 10 f0       	push   $0xf0103b31
f0101cb2:	68 12 03 00 00       	push   $0x312
f0101cb7:	68 0b 3b 10 f0       	push   $0xf0103b0b
f0101cbc:	e8 ca e3 ff ff       	call   f010008b <_panic>
	assert(!page_alloc(0));
f0101cc1:	68 9e 3c 10 f0       	push   $0xf0103c9e
f0101cc6:	68 31 3b 10 f0       	push   $0xf0103b31
f0101ccb:	68 19 03 00 00       	push   $0x319
f0101cd0:	68 0b 3b 10 f0       	push   $0xf0103b0b
f0101cd5:	e8 b1 e3 ff ff       	call   f010008b <_panic>
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0101cda:	68 d4 3f 10 f0       	push   $0xf0103fd4
f0101cdf:	68 31 3b 10 f0       	push   $0xf0103b31
f0101ce4:	68 1c 03 00 00       	push   $0x31c
f0101ce9:	68 0b 3b 10 f0       	push   $0xf0103b0b
f0101cee:	e8 98 e3 ff ff       	call   f010008b <_panic>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0101cf3:	68 0c 40 10 f0       	push   $0xf010400c
f0101cf8:	68 31 3b 10 f0       	push   $0xf0103b31
f0101cfd:	68 1f 03 00 00       	push   $0x31f
f0101d02:	68 0b 3b 10 f0       	push   $0xf0103b0b
f0101d07:	e8 7f e3 ff ff       	call   f010008b <_panic>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0101d0c:	68 3c 40 10 f0       	push   $0xf010403c
f0101d11:	68 31 3b 10 f0       	push   $0xf0103b31
f0101d16:	68 23 03 00 00       	push   $0x323
f0101d1b:	68 0b 3b 10 f0       	push   $0xf0103b0b
f0101d20:	e8 66 e3 ff ff       	call   f010008b <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101d25:	68 6c 40 10 f0       	push   $0xf010406c
f0101d2a:	68 31 3b 10 f0       	push   $0xf0103b31
f0101d2f:	68 24 03 00 00       	push   $0x324
f0101d34:	68 0b 3b 10 f0       	push   $0xf0103b0b
f0101d39:	e8 4d e3 ff ff       	call   f010008b <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0101d3e:	68 94 40 10 f0       	push   $0xf0104094
f0101d43:	68 31 3b 10 f0       	push   $0xf0103b31
f0101d48:	68 25 03 00 00       	push   $0x325
f0101d4d:	68 0b 3b 10 f0       	push   $0xf0103b0b
f0101d52:	e8 34 e3 ff ff       	call   f010008b <_panic>
	assert(pp1->pp_ref == 1);
f0101d57:	68 f0 3c 10 f0       	push   $0xf0103cf0
f0101d5c:	68 31 3b 10 f0       	push   $0xf0103b31
f0101d61:	68 26 03 00 00       	push   $0x326
f0101d66:	68 0b 3b 10 f0       	push   $0xf0103b0b
f0101d6b:	e8 1b e3 ff ff       	call   f010008b <_panic>
	assert(pp0->pp_ref == 1);
f0101d70:	68 01 3d 10 f0       	push   $0xf0103d01
f0101d75:	68 31 3b 10 f0       	push   $0xf0103b31
f0101d7a:	68 27 03 00 00       	push   $0x327
f0101d7f:	68 0b 3b 10 f0       	push   $0xf0103b0b
f0101d84:	e8 02 e3 ff ff       	call   f010008b <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101d89:	68 c4 40 10 f0       	push   $0xf01040c4
f0101d8e:	68 31 3b 10 f0       	push   $0xf0103b31
f0101d93:	68 2a 03 00 00       	push   $0x32a
f0101d98:	68 0b 3b 10 f0       	push   $0xf0103b0b
f0101d9d:	e8 e9 e2 ff ff       	call   f010008b <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101da2:	68 00 41 10 f0       	push   $0xf0104100
f0101da7:	68 31 3b 10 f0       	push   $0xf0103b31
f0101dac:	68 2b 03 00 00       	push   $0x32b
f0101db1:	68 0b 3b 10 f0       	push   $0xf0103b0b
f0101db6:	e8 d0 e2 ff ff       	call   f010008b <_panic>
	assert(pp2->pp_ref == 1);
f0101dbb:	68 12 3d 10 f0       	push   $0xf0103d12
f0101dc0:	68 31 3b 10 f0       	push   $0xf0103b31
f0101dc5:	68 2c 03 00 00       	push   $0x32c
f0101dca:	68 0b 3b 10 f0       	push   $0xf0103b0b
f0101dcf:	e8 b7 e2 ff ff       	call   f010008b <_panic>
	assert(!page_alloc(0));
f0101dd4:	68 9e 3c 10 f0       	push   $0xf0103c9e
f0101dd9:	68 31 3b 10 f0       	push   $0xf0103b31
f0101dde:	68 2e 03 00 00       	push   $0x32e
f0101de3:	68 0b 3b 10 f0       	push   $0xf0103b0b
f0101de8:	e8 9e e2 ff ff       	call   f010008b <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101ded:	68 c4 40 10 f0       	push   $0xf01040c4
f0101df2:	68 31 3b 10 f0       	push   $0xf0103b31
f0101df7:	68 31 03 00 00       	push   $0x331
f0101dfc:	68 0b 3b 10 f0       	push   $0xf0103b0b
f0101e01:	e8 85 e2 ff ff       	call   f010008b <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101e06:	68 00 41 10 f0       	push   $0xf0104100
f0101e0b:	68 31 3b 10 f0       	push   $0xf0103b31
f0101e10:	68 32 03 00 00       	push   $0x332
f0101e15:	68 0b 3b 10 f0       	push   $0xf0103b0b
f0101e1a:	e8 6c e2 ff ff       	call   f010008b <_panic>
	assert(pp2->pp_ref == 1);
f0101e1f:	68 12 3d 10 f0       	push   $0xf0103d12
f0101e24:	68 31 3b 10 f0       	push   $0xf0103b31
f0101e29:	68 33 03 00 00       	push   $0x333
f0101e2e:	68 0b 3b 10 f0       	push   $0xf0103b0b
f0101e33:	e8 53 e2 ff ff       	call   f010008b <_panic>
	assert(!page_alloc(0));
f0101e38:	68 9e 3c 10 f0       	push   $0xf0103c9e
f0101e3d:	68 31 3b 10 f0       	push   $0xf0103b31
f0101e42:	68 37 03 00 00       	push   $0x337
f0101e47:	68 0b 3b 10 f0       	push   $0xf0103b0b
f0101e4c:	e8 3a e2 ff ff       	call   f010008b <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101e51:	52                   	push   %edx
f0101e52:	68 08 3e 10 f0       	push   $0xf0103e08
f0101e57:	68 3a 03 00 00       	push   $0x33a
f0101e5c:	68 0b 3b 10 f0       	push   $0xf0103b0b
f0101e61:	e8 25 e2 ff ff       	call   f010008b <_panic>
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0101e66:	68 30 41 10 f0       	push   $0xf0104130
f0101e6b:	68 31 3b 10 f0       	push   $0xf0103b31
f0101e70:	68 3b 03 00 00       	push   $0x33b
f0101e75:	68 0b 3b 10 f0       	push   $0xf0103b0b
f0101e7a:	e8 0c e2 ff ff       	call   f010008b <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0101e7f:	68 70 41 10 f0       	push   $0xf0104170
f0101e84:	68 31 3b 10 f0       	push   $0xf0103b31
f0101e89:	68 3e 03 00 00       	push   $0x33e
f0101e8e:	68 0b 3b 10 f0       	push   $0xf0103b0b
f0101e93:	e8 f3 e1 ff ff       	call   f010008b <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101e98:	68 00 41 10 f0       	push   $0xf0104100
f0101e9d:	68 31 3b 10 f0       	push   $0xf0103b31
f0101ea2:	68 3f 03 00 00       	push   $0x33f
f0101ea7:	68 0b 3b 10 f0       	push   $0xf0103b0b
f0101eac:	e8 da e1 ff ff       	call   f010008b <_panic>
	assert(pp2->pp_ref == 1);
f0101eb1:	68 12 3d 10 f0       	push   $0xf0103d12
f0101eb6:	68 31 3b 10 f0       	push   $0xf0103b31
f0101ebb:	68 40 03 00 00       	push   $0x340
f0101ec0:	68 0b 3b 10 f0       	push   $0xf0103b0b
f0101ec5:	e8 c1 e1 ff ff       	call   f010008b <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0101eca:	68 b0 41 10 f0       	push   $0xf01041b0
f0101ecf:	68 31 3b 10 f0       	push   $0xf0103b31
f0101ed4:	68 41 03 00 00       	push   $0x341
f0101ed9:	68 0b 3b 10 f0       	push   $0xf0103b0b
f0101ede:	e8 a8 e1 ff ff       	call   f010008b <_panic>
	assert(kern_pgdir[0] & PTE_U);
f0101ee3:	68 23 3d 10 f0       	push   $0xf0103d23
f0101ee8:	68 31 3b 10 f0       	push   $0xf0103b31
f0101eed:	68 42 03 00 00       	push   $0x342
f0101ef2:	68 0b 3b 10 f0       	push   $0xf0103b0b
f0101ef7:	e8 8f e1 ff ff       	call   f010008b <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101efc:	68 c4 40 10 f0       	push   $0xf01040c4
f0101f01:	68 31 3b 10 f0       	push   $0xf0103b31
f0101f06:	68 45 03 00 00       	push   $0x345
f0101f0b:	68 0b 3b 10 f0       	push   $0xf0103b0b
f0101f10:	e8 76 e1 ff ff       	call   f010008b <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0101f15:	68 e4 41 10 f0       	push   $0xf01041e4
f0101f1a:	68 31 3b 10 f0       	push   $0xf0103b31
f0101f1f:	68 46 03 00 00       	push   $0x346
f0101f24:	68 0b 3b 10 f0       	push   $0xf0103b0b
f0101f29:	e8 5d e1 ff ff       	call   f010008b <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101f2e:	68 18 42 10 f0       	push   $0xf0104218
f0101f33:	68 31 3b 10 f0       	push   $0xf0103b31
f0101f38:	68 47 03 00 00       	push   $0x347
f0101f3d:	68 0b 3b 10 f0       	push   $0xf0103b0b
f0101f42:	e8 44 e1 ff ff       	call   f010008b <_panic>
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0101f47:	68 50 42 10 f0       	push   $0xf0104250
f0101f4c:	68 31 3b 10 f0       	push   $0xf0103b31
f0101f51:	68 4a 03 00 00       	push   $0x34a
f0101f56:	68 0b 3b 10 f0       	push   $0xf0103b0b
f0101f5b:	e8 2b e1 ff ff       	call   f010008b <_panic>
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0101f60:	68 88 42 10 f0       	push   $0xf0104288
f0101f65:	68 31 3b 10 f0       	push   $0xf0103b31
f0101f6a:	68 4d 03 00 00       	push   $0x34d
f0101f6f:	68 0b 3b 10 f0       	push   $0xf0103b0b
f0101f74:	e8 12 e1 ff ff       	call   f010008b <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101f79:	68 18 42 10 f0       	push   $0xf0104218
f0101f7e:	68 31 3b 10 f0       	push   $0xf0103b31
f0101f83:	68 4e 03 00 00       	push   $0x34e
f0101f88:	68 0b 3b 10 f0       	push   $0xf0103b0b
f0101f8d:	e8 f9 e0 ff ff       	call   f010008b <_panic>
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0101f92:	68 c4 42 10 f0       	push   $0xf01042c4
f0101f97:	68 31 3b 10 f0       	push   $0xf0103b31
f0101f9c:	68 51 03 00 00       	push   $0x351
f0101fa1:	68 0b 3b 10 f0       	push   $0xf0103b0b
f0101fa6:	e8 e0 e0 ff ff       	call   f010008b <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101fab:	68 f0 42 10 f0       	push   $0xf01042f0
f0101fb0:	68 31 3b 10 f0       	push   $0xf0103b31
f0101fb5:	68 52 03 00 00       	push   $0x352
f0101fba:	68 0b 3b 10 f0       	push   $0xf0103b0b
f0101fbf:	e8 c7 e0 ff ff       	call   f010008b <_panic>
	assert(pp1->pp_ref == 2);
f0101fc4:	68 39 3d 10 f0       	push   $0xf0103d39
f0101fc9:	68 31 3b 10 f0       	push   $0xf0103b31
f0101fce:	68 54 03 00 00       	push   $0x354
f0101fd3:	68 0b 3b 10 f0       	push   $0xf0103b0b
f0101fd8:	e8 ae e0 ff ff       	call   f010008b <_panic>
	assert(pp2->pp_ref == 0);
f0101fdd:	68 4a 3d 10 f0       	push   $0xf0103d4a
f0101fe2:	68 31 3b 10 f0       	push   $0xf0103b31
f0101fe7:	68 55 03 00 00       	push   $0x355
f0101fec:	68 0b 3b 10 f0       	push   $0xf0103b0b
f0101ff1:	e8 95 e0 ff ff       	call   f010008b <_panic>
	assert((pp = page_alloc(0)) && pp == pp2);
f0101ff6:	68 20 43 10 f0       	push   $0xf0104320
f0101ffb:	68 31 3b 10 f0       	push   $0xf0103b31
f0102000:	68 58 03 00 00       	push   $0x358
f0102005:	68 0b 3b 10 f0       	push   $0xf0103b0b
f010200a:	e8 7c e0 ff ff       	call   f010008b <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f010200f:	68 44 43 10 f0       	push   $0xf0104344
f0102014:	68 31 3b 10 f0       	push   $0xf0103b31
f0102019:	68 5c 03 00 00       	push   $0x35c
f010201e:	68 0b 3b 10 f0       	push   $0xf0103b0b
f0102023:	e8 63 e0 ff ff       	call   f010008b <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102028:	68 f0 42 10 f0       	push   $0xf01042f0
f010202d:	68 31 3b 10 f0       	push   $0xf0103b31
f0102032:	68 5d 03 00 00       	push   $0x35d
f0102037:	68 0b 3b 10 f0       	push   $0xf0103b0b
f010203c:	e8 4a e0 ff ff       	call   f010008b <_panic>
	assert(pp1->pp_ref == 1);
f0102041:	68 f0 3c 10 f0       	push   $0xf0103cf0
f0102046:	68 31 3b 10 f0       	push   $0xf0103b31
f010204b:	68 5e 03 00 00       	push   $0x35e
f0102050:	68 0b 3b 10 f0       	push   $0xf0103b0b
f0102055:	e8 31 e0 ff ff       	call   f010008b <_panic>
	assert(pp2->pp_ref == 0);
f010205a:	68 4a 3d 10 f0       	push   $0xf0103d4a
f010205f:	68 31 3b 10 f0       	push   $0xf0103b31
f0102064:	68 5f 03 00 00       	push   $0x35f
f0102069:	68 0b 3b 10 f0       	push   $0xf0103b0b
f010206e:	e8 18 e0 ff ff       	call   f010008b <_panic>
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f0102073:	68 68 43 10 f0       	push   $0xf0104368
f0102078:	68 31 3b 10 f0       	push   $0xf0103b31
f010207d:	68 62 03 00 00       	push   $0x362
f0102082:	68 0b 3b 10 f0       	push   $0xf0103b0b
f0102087:	e8 ff df ff ff       	call   f010008b <_panic>
	assert(pp1->pp_ref);
f010208c:	68 5b 3d 10 f0       	push   $0xf0103d5b
f0102091:	68 31 3b 10 f0       	push   $0xf0103b31
f0102096:	68 63 03 00 00       	push   $0x363
f010209b:	68 0b 3b 10 f0       	push   $0xf0103b0b
f01020a0:	e8 e6 df ff ff       	call   f010008b <_panic>
	assert(pp1->pp_link == NULL);
f01020a5:	68 67 3d 10 f0       	push   $0xf0103d67
f01020aa:	68 31 3b 10 f0       	push   $0xf0103b31
f01020af:	68 64 03 00 00       	push   $0x364
f01020b4:	68 0b 3b 10 f0       	push   $0xf0103b0b
f01020b9:	e8 cd df ff ff       	call   f010008b <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f01020be:	68 44 43 10 f0       	push   $0xf0104344
f01020c3:	68 31 3b 10 f0       	push   $0xf0103b31
f01020c8:	68 68 03 00 00       	push   $0x368
f01020cd:	68 0b 3b 10 f0       	push   $0xf0103b0b
f01020d2:	e8 b4 df ff ff       	call   f010008b <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f01020d7:	68 a0 43 10 f0       	push   $0xf01043a0
f01020dc:	68 31 3b 10 f0       	push   $0xf0103b31
f01020e1:	68 69 03 00 00       	push   $0x369
f01020e6:	68 0b 3b 10 f0       	push   $0xf0103b0b
f01020eb:	e8 9b df ff ff       	call   f010008b <_panic>
	assert(pp1->pp_ref == 0);
f01020f0:	68 7c 3d 10 f0       	push   $0xf0103d7c
f01020f5:	68 31 3b 10 f0       	push   $0xf0103b31
f01020fa:	68 6a 03 00 00       	push   $0x36a
f01020ff:	68 0b 3b 10 f0       	push   $0xf0103b0b
f0102104:	e8 82 df ff ff       	call   f010008b <_panic>
	assert(pp2->pp_ref == 0);
f0102109:	68 4a 3d 10 f0       	push   $0xf0103d4a
f010210e:	68 31 3b 10 f0       	push   $0xf0103b31
f0102113:	68 6b 03 00 00       	push   $0x36b
f0102118:	68 0b 3b 10 f0       	push   $0xf0103b0b
f010211d:	e8 69 df ff ff       	call   f010008b <_panic>
	assert((pp = page_alloc(0)) && pp == pp1);
f0102122:	68 c8 43 10 f0       	push   $0xf01043c8
f0102127:	68 31 3b 10 f0       	push   $0xf0103b31
f010212c:	68 6e 03 00 00       	push   $0x36e
f0102131:	68 0b 3b 10 f0       	push   $0xf0103b0b
f0102136:	e8 50 df ff ff       	call   f010008b <_panic>
	assert(!page_alloc(0));
f010213b:	68 9e 3c 10 f0       	push   $0xf0103c9e
f0102140:	68 31 3b 10 f0       	push   $0xf0103b31
f0102145:	68 71 03 00 00       	push   $0x371
f010214a:	68 0b 3b 10 f0       	push   $0xf0103b0b
f010214f:	e8 37 df ff ff       	call   f010008b <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102154:	68 6c 40 10 f0       	push   $0xf010406c
f0102159:	68 31 3b 10 f0       	push   $0xf0103b31
f010215e:	68 74 03 00 00       	push   $0x374
f0102163:	68 0b 3b 10 f0       	push   $0xf0103b0b
f0102168:	e8 1e df ff ff       	call   f010008b <_panic>
	assert(pp0->pp_ref == 1);
f010216d:	68 01 3d 10 f0       	push   $0xf0103d01
f0102172:	68 31 3b 10 f0       	push   $0xf0103b31
f0102177:	68 76 03 00 00       	push   $0x376
f010217c:	68 0b 3b 10 f0       	push   $0xf0103b0b
f0102181:	e8 05 df ff ff       	call   f010008b <_panic>
f0102186:	ff 75 d0             	pushl  -0x30(%ebp)
f0102189:	68 08 3e 10 f0       	push   $0xf0103e08
f010218e:	68 7d 03 00 00       	push   $0x37d
f0102193:	68 0b 3b 10 f0       	push   $0xf0103b0b
f0102198:	e8 ee de ff ff       	call   f010008b <_panic>
	assert(ptep == ptep1 + PTX(va));
f010219d:	68 8d 3d 10 f0       	push   $0xf0103d8d
f01021a2:	68 31 3b 10 f0       	push   $0xf0103b31
f01021a7:	68 7e 03 00 00       	push   $0x37e
f01021ac:	68 0b 3b 10 f0       	push   $0xf0103b0b
f01021b1:	e8 d5 de ff ff       	call   f010008b <_panic>
f01021b6:	52                   	push   %edx
f01021b7:	68 08 3e 10 f0       	push   $0xf0103e08
f01021bc:	6a 52                	push   $0x52
f01021be:	68 17 3b 10 f0       	push   $0xf0103b17
f01021c3:	e8 c3 de ff ff       	call   f010008b <_panic>
f01021c8:	52                   	push   %edx
f01021c9:	68 08 3e 10 f0       	push   $0xf0103e08
f01021ce:	6a 52                	push   $0x52
f01021d0:	68 17 3b 10 f0       	push   $0xf0103b17
f01021d5:	e8 b1 de ff ff       	call   f010008b <_panic>
		assert((ptep[i] & PTE_P) == 0);
f01021da:	68 a5 3d 10 f0       	push   $0xf0103da5
f01021df:	68 31 3b 10 f0       	push   $0xf0103b31
f01021e4:	68 88 03 00 00       	push   $0x388
f01021e9:	68 0b 3b 10 f0       	push   $0xf0103b0b
f01021ee:	e8 98 de ff ff       	call   f010008b <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01021f3:	50                   	push   %eax
f01021f4:	68 70 3f 10 f0       	push   $0xf0103f70
f01021f9:	68 b9 00 00 00       	push   $0xb9
f01021fe:	68 0b 3b 10 f0       	push   $0xf0103b0b
f0102203:	e8 83 de ff ff       	call   f010008b <_panic>
f0102208:	50                   	push   %eax
f0102209:	68 70 3f 10 f0       	push   $0xf0103f70
f010220e:	68 c6 00 00 00       	push   $0xc6
f0102213:	68 0b 3b 10 f0       	push   $0xf0103b0b
f0102218:	e8 6e de ff ff       	call   f010008b <_panic>
f010221d:	ff 75 c4             	pushl  -0x3c(%ebp)
f0102220:	68 70 3f 10 f0       	push   $0xf0103f70
f0102225:	68 cb 02 00 00       	push   $0x2cb
f010222a:	68 0b 3b 10 f0       	push   $0xf0103b0b
f010222f:	e8 57 de ff ff       	call   f010008b <_panic>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102234:	68 ec 43 10 f0       	push   $0xf01043ec
f0102239:	68 31 3b 10 f0       	push   $0xf0103b31
f010223e:	68 cb 02 00 00       	push   $0x2cb
f0102243:	68 0b 3b 10 f0       	push   $0xf0103b0b
f0102248:	e8 3e de ff ff       	call   f010008b <_panic>
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f010224d:	c1 e6 0c             	shl    $0xc,%esi
f0102250:	89 fb                	mov    %edi,%ebx
f0102252:	39 f3                	cmp    %esi,%ebx
f0102254:	73 33                	jae    f0102289 <mem_init+0x1356>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0102256:	8d 93 00 00 00 f0    	lea    -0x10000000(%ebx),%edx
f010225c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010225f:	e8 31 e6 ff ff       	call   f0100895 <check_va2pa>
f0102264:	39 c3                	cmp    %eax,%ebx
f0102266:	75 08                	jne    f0102270 <mem_init+0x133d>
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102268:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f010226e:	eb e2                	jmp    f0102252 <mem_init+0x131f>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0102270:	68 20 44 10 f0       	push   $0xf0104420
f0102275:	68 31 3b 10 f0       	push   $0xf0103b31
f010227a:	68 d0 02 00 00       	push   $0x2d0
f010227f:	68 0b 3b 10 f0       	push   $0xf0103b0b
f0102284:	e8 02 de ff ff       	call   f010008b <_panic>
f0102289:	bb 00 80 ff ef       	mov    $0xefff8000,%ebx
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f010228e:	b8 00 e0 10 f0       	mov    $0xf010e000,%eax
f0102293:	8d b0 00 80 00 20    	lea    0x20008000(%eax),%esi
f0102299:	89 da                	mov    %ebx,%edx
f010229b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010229e:	e8 f2 e5 ff ff       	call   f0100895 <check_va2pa>
f01022a3:	89 c2                	mov    %eax,%edx
f01022a5:	8d 04 1e             	lea    (%esi,%ebx,1),%eax
f01022a8:	39 c2                	cmp    %eax,%edx
f01022aa:	75 25                	jne    f01022d1 <mem_init+0x139e>
f01022ac:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
f01022b2:	81 fb 00 00 00 f0    	cmp    $0xf0000000,%ebx
f01022b8:	75 df                	jne    f0102299 <mem_init+0x1366>
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f01022ba:	ba 00 00 c0 ef       	mov    $0xefc00000,%edx
f01022bf:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01022c2:	e8 ce e5 ff ff       	call   f0100895 <check_va2pa>
f01022c7:	83 f8 ff             	cmp    $0xffffffff,%eax
f01022ca:	75 1e                	jne    f01022ea <mem_init+0x13b7>
f01022cc:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01022cf:	eb 5d                	jmp    f010232e <mem_init+0x13fb>
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f01022d1:	68 48 44 10 f0       	push   $0xf0104448
f01022d6:	68 31 3b 10 f0       	push   $0xf0103b31
f01022db:	68 d4 02 00 00       	push   $0x2d4
f01022e0:	68 0b 3b 10 f0       	push   $0xf0103b0b
f01022e5:	e8 a1 dd ff ff       	call   f010008b <_panic>
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f01022ea:	68 90 44 10 f0       	push   $0xf0104490
f01022ef:	68 31 3b 10 f0       	push   $0xf0103b31
f01022f4:	68 d5 02 00 00       	push   $0x2d5
f01022f9:	68 0b 3b 10 f0       	push   $0xf0103b0b
f01022fe:	e8 88 dd ff ff       	call   f010008b <_panic>
		switch (i) {
f0102303:	81 ff bf 03 00 00    	cmp    $0x3bf,%edi
f0102309:	75 23                	jne    f010232e <mem_init+0x13fb>
			assert(pgdir[i] & PTE_P);
f010230b:	f6 04 b8 01          	testb  $0x1,(%eax,%edi,4)
f010230f:	74 44                	je     f0102355 <mem_init+0x1422>
	for (i = 0; i < NPDENTRIES; i++) {
f0102311:	47                   	inc    %edi
f0102312:	81 ff ff 03 00 00    	cmp    $0x3ff,%edi
f0102318:	0f 87 8f 00 00 00    	ja     f01023ad <mem_init+0x147a>
		switch (i) {
f010231e:	81 ff bd 03 00 00    	cmp    $0x3bd,%edi
f0102324:	77 dd                	ja     f0102303 <mem_init+0x13d0>
f0102326:	81 ff bb 03 00 00    	cmp    $0x3bb,%edi
f010232c:	77 dd                	ja     f010230b <mem_init+0x13d8>
			if (i >= PDX(KERNBASE)) {
f010232e:	81 ff bf 03 00 00    	cmp    $0x3bf,%edi
f0102334:	77 38                	ja     f010236e <mem_init+0x143b>
				assert(pgdir[i] == 0);
f0102336:	83 3c b8 00          	cmpl   $0x0,(%eax,%edi,4)
f010233a:	74 d5                	je     f0102311 <mem_init+0x13de>
f010233c:	68 f7 3d 10 f0       	push   $0xf0103df7
f0102341:	68 31 3b 10 f0       	push   $0xf0103b31
f0102346:	68 e4 02 00 00       	push   $0x2e4
f010234b:	68 0b 3b 10 f0       	push   $0xf0103b0b
f0102350:	e8 36 dd ff ff       	call   f010008b <_panic>
			assert(pgdir[i] & PTE_P);
f0102355:	68 d5 3d 10 f0       	push   $0xf0103dd5
f010235a:	68 31 3b 10 f0       	push   $0xf0103b31
f010235f:	68 dd 02 00 00       	push   $0x2dd
f0102364:	68 0b 3b 10 f0       	push   $0xf0103b0b
f0102369:	e8 1d dd ff ff       	call   f010008b <_panic>
				assert(pgdir[i] & PTE_P);
f010236e:	8b 14 b8             	mov    (%eax,%edi,4),%edx
f0102371:	f6 c2 01             	test   $0x1,%dl
f0102374:	74 1e                	je     f0102394 <mem_init+0x1461>
				assert(pgdir[i] & PTE_W);
f0102376:	f6 c2 02             	test   $0x2,%dl
f0102379:	75 96                	jne    f0102311 <mem_init+0x13de>
f010237b:	68 e6 3d 10 f0       	push   $0xf0103de6
f0102380:	68 31 3b 10 f0       	push   $0xf0103b31
f0102385:	68 e2 02 00 00       	push   $0x2e2
f010238a:	68 0b 3b 10 f0       	push   $0xf0103b0b
f010238f:	e8 f7 dc ff ff       	call   f010008b <_panic>
				assert(pgdir[i] & PTE_P);
f0102394:	68 d5 3d 10 f0       	push   $0xf0103dd5
f0102399:	68 31 3b 10 f0       	push   $0xf0103b31
f010239e:	68 e1 02 00 00       	push   $0x2e1
f01023a3:	68 0b 3b 10 f0       	push   $0xf0103b0b
f01023a8:	e8 de dc ff ff       	call   f010008b <_panic>
	cprintf("check_kern_pgdir() succeeded!\n");
f01023ad:	83 ec 0c             	sub    $0xc,%esp
f01023b0:	68 c0 44 10 f0       	push   $0xf01044c0
f01023b5:	e8 02 04 00 00       	call   f01027bc <cprintf>
	lcr3(PADDR(kern_pgdir));
f01023ba:	a1 6c 89 11 f0       	mov    0xf011896c,%eax
	if ((uint32_t)kva < KERNBASE)
f01023bf:	83 c4 10             	add    $0x10,%esp
f01023c2:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01023c7:	0f 86 06 02 00 00    	jbe    f01025d3 <mem_init+0x16a0>
	return (physaddr_t)kva - KERNBASE;
f01023cd:	05 00 00 00 10       	add    $0x10000000,%eax
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f01023d2:	0f 22 d8             	mov    %eax,%cr3
	check_page_free_list(0);
f01023d5:	b8 00 00 00 00       	mov    $0x0,%eax
f01023da:	e8 16 e5 ff ff       	call   f01008f5 <check_page_free_list>
	asm volatile("movl %%cr0,%0" : "=r" (val));
f01023df:	0f 20 c0             	mov    %cr0,%eax
	cr0 &= ~(CR0_TS|CR0_EM);
f01023e2:	83 e0 f3             	and    $0xfffffff3,%eax
f01023e5:	0d 23 00 05 80       	or     $0x80050023,%eax
	asm volatile("movl %0,%%cr0" : : "r" (val));
f01023ea:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01023ed:	83 ec 0c             	sub    $0xc,%esp
f01023f0:	6a 00                	push   $0x0
f01023f2:	e8 6e e8 ff ff       	call   f0100c65 <page_alloc>
f01023f7:	89 c6                	mov    %eax,%esi
f01023f9:	83 c4 10             	add    $0x10,%esp
f01023fc:	85 c0                	test   %eax,%eax
f01023fe:	0f 84 e4 01 00 00    	je     f01025e8 <mem_init+0x16b5>
	assert((pp1 = page_alloc(0)));
f0102404:	83 ec 0c             	sub    $0xc,%esp
f0102407:	6a 00                	push   $0x0
f0102409:	e8 57 e8 ff ff       	call   f0100c65 <page_alloc>
f010240e:	89 c7                	mov    %eax,%edi
f0102410:	83 c4 10             	add    $0x10,%esp
f0102413:	85 c0                	test   %eax,%eax
f0102415:	0f 84 e6 01 00 00    	je     f0102601 <mem_init+0x16ce>
	assert((pp2 = page_alloc(0)));
f010241b:	83 ec 0c             	sub    $0xc,%esp
f010241e:	6a 00                	push   $0x0
f0102420:	e8 40 e8 ff ff       	call   f0100c65 <page_alloc>
f0102425:	89 c3                	mov    %eax,%ebx
f0102427:	83 c4 10             	add    $0x10,%esp
f010242a:	85 c0                	test   %eax,%eax
f010242c:	0f 84 e8 01 00 00    	je     f010261a <mem_init+0x16e7>
	page_free(pp0);
f0102432:	83 ec 0c             	sub    $0xc,%esp
f0102435:	56                   	push   %esi
f0102436:	e8 9f e8 ff ff       	call   f0100cda <page_free>
	return (pp - pages) << PGSHIFT;
f010243b:	89 f8                	mov    %edi,%eax
f010243d:	2b 05 70 89 11 f0    	sub    0xf0118970,%eax
f0102443:	c1 f8 03             	sar    $0x3,%eax
f0102446:	89 c2                	mov    %eax,%edx
f0102448:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f010244b:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0102450:	83 c4 10             	add    $0x10,%esp
f0102453:	3b 05 68 89 11 f0    	cmp    0xf0118968,%eax
f0102459:	0f 83 d4 01 00 00    	jae    f0102633 <mem_init+0x1700>
	memset(page2kva(pp1), 1, PGSIZE);
f010245f:	83 ec 04             	sub    $0x4,%esp
f0102462:	68 00 10 00 00       	push   $0x1000
f0102467:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f0102469:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f010246f:	52                   	push   %edx
f0102470:	e8 d7 0d 00 00       	call   f010324c <memset>
	return (pp - pages) << PGSHIFT;
f0102475:	89 d8                	mov    %ebx,%eax
f0102477:	2b 05 70 89 11 f0    	sub    0xf0118970,%eax
f010247d:	c1 f8 03             	sar    $0x3,%eax
f0102480:	89 c2                	mov    %eax,%edx
f0102482:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0102485:	25 ff ff 0f 00       	and    $0xfffff,%eax
f010248a:	83 c4 10             	add    $0x10,%esp
f010248d:	3b 05 68 89 11 f0    	cmp    0xf0118968,%eax
f0102493:	0f 83 ac 01 00 00    	jae    f0102645 <mem_init+0x1712>
	memset(page2kva(pp2), 2, PGSIZE);
f0102499:	83 ec 04             	sub    $0x4,%esp
f010249c:	68 00 10 00 00       	push   $0x1000
f01024a1:	6a 02                	push   $0x2
	return (void *)(pa + KERNBASE);
f01024a3:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f01024a9:	52                   	push   %edx
f01024aa:	e8 9d 0d 00 00       	call   f010324c <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f01024af:	6a 02                	push   $0x2
f01024b1:	68 00 10 00 00       	push   $0x1000
f01024b6:	57                   	push   %edi
f01024b7:	ff 35 6c 89 11 f0    	pushl  0xf011896c
f01024bd:	e8 f3 e9 ff ff       	call   f0100eb5 <page_insert>
	assert(pp1->pp_ref == 1);
f01024c2:	83 c4 20             	add    $0x20,%esp
f01024c5:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f01024ca:	0f 85 87 01 00 00    	jne    f0102657 <mem_init+0x1724>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f01024d0:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f01024d7:	01 01 01 
f01024da:	0f 85 90 01 00 00    	jne    f0102670 <mem_init+0x173d>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f01024e0:	6a 02                	push   $0x2
f01024e2:	68 00 10 00 00       	push   $0x1000
f01024e7:	53                   	push   %ebx
f01024e8:	ff 35 6c 89 11 f0    	pushl  0xf011896c
f01024ee:	e8 c2 e9 ff ff       	call   f0100eb5 <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f01024f3:	83 c4 10             	add    $0x10,%esp
f01024f6:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f01024fd:	02 02 02 
f0102500:	0f 85 83 01 00 00    	jne    f0102689 <mem_init+0x1756>
	assert(pp2->pp_ref == 1);
f0102506:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f010250b:	0f 85 91 01 00 00    	jne    f01026a2 <mem_init+0x176f>
	assert(pp1->pp_ref == 0);
f0102511:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0102516:	0f 85 9f 01 00 00    	jne    f01026bb <mem_init+0x1788>
	*(uint32_t *)PGSIZE = 0x03030303U;
f010251c:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f0102523:	03 03 03 
	return (pp - pages) << PGSHIFT;
f0102526:	89 d8                	mov    %ebx,%eax
f0102528:	2b 05 70 89 11 f0    	sub    0xf0118970,%eax
f010252e:	c1 f8 03             	sar    $0x3,%eax
f0102531:	89 c2                	mov    %eax,%edx
f0102533:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0102536:	25 ff ff 0f 00       	and    $0xfffff,%eax
f010253b:	3b 05 68 89 11 f0    	cmp    0xf0118968,%eax
f0102541:	0f 83 8d 01 00 00    	jae    f01026d4 <mem_init+0x17a1>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102547:	81 ba 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%edx)
f010254e:	03 03 03 
f0102551:	0f 85 8f 01 00 00    	jne    f01026e6 <mem_init+0x17b3>
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102557:	83 ec 08             	sub    $0x8,%esp
f010255a:	68 00 10 00 00       	push   $0x1000
f010255f:	ff 35 6c 89 11 f0    	pushl  0xf011896c
f0102565:	e8 10 e9 ff ff       	call   f0100e7a <page_remove>
	assert(pp2->pp_ref == 0);
f010256a:	83 c4 10             	add    $0x10,%esp
f010256d:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102572:	0f 85 87 01 00 00    	jne    f01026ff <mem_init+0x17cc>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102578:	8b 0d 6c 89 11 f0    	mov    0xf011896c,%ecx
f010257e:	8b 11                	mov    (%ecx),%edx
f0102580:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
	return (pp - pages) << PGSHIFT;
f0102586:	89 f0                	mov    %esi,%eax
f0102588:	2b 05 70 89 11 f0    	sub    0xf0118970,%eax
f010258e:	c1 f8 03             	sar    $0x3,%eax
f0102591:	c1 e0 0c             	shl    $0xc,%eax
f0102594:	39 c2                	cmp    %eax,%edx
f0102596:	0f 85 7c 01 00 00    	jne    f0102718 <mem_init+0x17e5>
	kern_pgdir[0] = 0;
f010259c:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f01025a2:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f01025a7:	0f 85 84 01 00 00    	jne    f0102731 <mem_init+0x17fe>
	pp0->pp_ref = 0;
f01025ad:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// free the pages we took
	page_free(pp0);
f01025b3:	83 ec 0c             	sub    $0xc,%esp
f01025b6:	56                   	push   %esi
f01025b7:	e8 1e e7 ff ff       	call   f0100cda <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f01025bc:	c7 04 24 54 45 10 f0 	movl   $0xf0104554,(%esp)
f01025c3:	e8 f4 01 00 00       	call   f01027bc <cprintf>
}
f01025c8:	83 c4 10             	add    $0x10,%esp
f01025cb:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01025ce:	5b                   	pop    %ebx
f01025cf:	5e                   	pop    %esi
f01025d0:	5f                   	pop    %edi
f01025d1:	5d                   	pop    %ebp
f01025d2:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01025d3:	50                   	push   %eax
f01025d4:	68 70 3f 10 f0       	push   $0xf0103f70
f01025d9:	68 dc 00 00 00       	push   $0xdc
f01025de:	68 0b 3b 10 f0       	push   $0xf0103b0b
f01025e3:	e8 a3 da ff ff       	call   f010008b <_panic>
	assert((pp0 = page_alloc(0)));
f01025e8:	68 f3 3b 10 f0       	push   $0xf0103bf3
f01025ed:	68 31 3b 10 f0       	push   $0xf0103b31
f01025f2:	68 a3 03 00 00       	push   $0x3a3
f01025f7:	68 0b 3b 10 f0       	push   $0xf0103b0b
f01025fc:	e8 8a da ff ff       	call   f010008b <_panic>
	assert((pp1 = page_alloc(0)));
f0102601:	68 09 3c 10 f0       	push   $0xf0103c09
f0102606:	68 31 3b 10 f0       	push   $0xf0103b31
f010260b:	68 a4 03 00 00       	push   $0x3a4
f0102610:	68 0b 3b 10 f0       	push   $0xf0103b0b
f0102615:	e8 71 da ff ff       	call   f010008b <_panic>
	assert((pp2 = page_alloc(0)));
f010261a:	68 1f 3c 10 f0       	push   $0xf0103c1f
f010261f:	68 31 3b 10 f0       	push   $0xf0103b31
f0102624:	68 a5 03 00 00       	push   $0x3a5
f0102629:	68 0b 3b 10 f0       	push   $0xf0103b0b
f010262e:	e8 58 da ff ff       	call   f010008b <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102633:	52                   	push   %edx
f0102634:	68 08 3e 10 f0       	push   $0xf0103e08
f0102639:	6a 52                	push   $0x52
f010263b:	68 17 3b 10 f0       	push   $0xf0103b17
f0102640:	e8 46 da ff ff       	call   f010008b <_panic>
f0102645:	52                   	push   %edx
f0102646:	68 08 3e 10 f0       	push   $0xf0103e08
f010264b:	6a 52                	push   $0x52
f010264d:	68 17 3b 10 f0       	push   $0xf0103b17
f0102652:	e8 34 da ff ff       	call   f010008b <_panic>
	assert(pp1->pp_ref == 1);
f0102657:	68 f0 3c 10 f0       	push   $0xf0103cf0
f010265c:	68 31 3b 10 f0       	push   $0xf0103b31
f0102661:	68 aa 03 00 00       	push   $0x3aa
f0102666:	68 0b 3b 10 f0       	push   $0xf0103b0b
f010266b:	e8 1b da ff ff       	call   f010008b <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102670:	68 e0 44 10 f0       	push   $0xf01044e0
f0102675:	68 31 3b 10 f0       	push   $0xf0103b31
f010267a:	68 ab 03 00 00       	push   $0x3ab
f010267f:	68 0b 3b 10 f0       	push   $0xf0103b0b
f0102684:	e8 02 da ff ff       	call   f010008b <_panic>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102689:	68 04 45 10 f0       	push   $0xf0104504
f010268e:	68 31 3b 10 f0       	push   $0xf0103b31
f0102693:	68 ad 03 00 00       	push   $0x3ad
f0102698:	68 0b 3b 10 f0       	push   $0xf0103b0b
f010269d:	e8 e9 d9 ff ff       	call   f010008b <_panic>
	assert(pp2->pp_ref == 1);
f01026a2:	68 12 3d 10 f0       	push   $0xf0103d12
f01026a7:	68 31 3b 10 f0       	push   $0xf0103b31
f01026ac:	68 ae 03 00 00       	push   $0x3ae
f01026b1:	68 0b 3b 10 f0       	push   $0xf0103b0b
f01026b6:	e8 d0 d9 ff ff       	call   f010008b <_panic>
	assert(pp1->pp_ref == 0);
f01026bb:	68 7c 3d 10 f0       	push   $0xf0103d7c
f01026c0:	68 31 3b 10 f0       	push   $0xf0103b31
f01026c5:	68 af 03 00 00       	push   $0x3af
f01026ca:	68 0b 3b 10 f0       	push   $0xf0103b0b
f01026cf:	e8 b7 d9 ff ff       	call   f010008b <_panic>
f01026d4:	52                   	push   %edx
f01026d5:	68 08 3e 10 f0       	push   $0xf0103e08
f01026da:	6a 52                	push   $0x52
f01026dc:	68 17 3b 10 f0       	push   $0xf0103b17
f01026e1:	e8 a5 d9 ff ff       	call   f010008b <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f01026e6:	68 28 45 10 f0       	push   $0xf0104528
f01026eb:	68 31 3b 10 f0       	push   $0xf0103b31
f01026f0:	68 b1 03 00 00       	push   $0x3b1
f01026f5:	68 0b 3b 10 f0       	push   $0xf0103b0b
f01026fa:	e8 8c d9 ff ff       	call   f010008b <_panic>
	assert(pp2->pp_ref == 0);
f01026ff:	68 4a 3d 10 f0       	push   $0xf0103d4a
f0102704:	68 31 3b 10 f0       	push   $0xf0103b31
f0102709:	68 b3 03 00 00       	push   $0x3b3
f010270e:	68 0b 3b 10 f0       	push   $0xf0103b0b
f0102713:	e8 73 d9 ff ff       	call   f010008b <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102718:	68 6c 40 10 f0       	push   $0xf010406c
f010271d:	68 31 3b 10 f0       	push   $0xf0103b31
f0102722:	68 b6 03 00 00       	push   $0x3b6
f0102727:	68 0b 3b 10 f0       	push   $0xf0103b0b
f010272c:	e8 5a d9 ff ff       	call   f010008b <_panic>
	assert(pp0->pp_ref == 1);
f0102731:	68 01 3d 10 f0       	push   $0xf0103d01
f0102736:	68 31 3b 10 f0       	push   $0xf0103b31
f010273b:	68 b8 03 00 00       	push   $0x3b8
f0102740:	68 0b 3b 10 f0       	push   $0xf0103b0b
f0102745:	e8 41 d9 ff ff       	call   f010008b <_panic>

f010274a <tlb_invalidate>:
{
f010274a:	55                   	push   %ebp
f010274b:	89 e5                	mov    %esp,%ebp
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f010274d:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102750:	0f 01 38             	invlpg (%eax)
}
f0102753:	5d                   	pop    %ebp
f0102754:	c3                   	ret    

f0102755 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0102755:	55                   	push   %ebp
f0102756:	89 e5                	mov    %esp,%ebp
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0102758:	8b 45 08             	mov    0x8(%ebp),%eax
f010275b:	ba 70 00 00 00       	mov    $0x70,%edx
f0102760:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0102761:	ba 71 00 00 00       	mov    $0x71,%edx
f0102766:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0102767:	0f b6 c0             	movzbl %al,%eax
}
f010276a:	5d                   	pop    %ebp
f010276b:	c3                   	ret    

f010276c <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f010276c:	55                   	push   %ebp
f010276d:	89 e5                	mov    %esp,%ebp
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010276f:	8b 45 08             	mov    0x8(%ebp),%eax
f0102772:	ba 70 00 00 00       	mov    $0x70,%edx
f0102777:	ee                   	out    %al,(%dx)
f0102778:	8b 45 0c             	mov    0xc(%ebp),%eax
f010277b:	ba 71 00 00 00       	mov    $0x71,%edx
f0102780:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0102781:	5d                   	pop    %ebp
f0102782:	c3                   	ret    

f0102783 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0102783:	55                   	push   %ebp
f0102784:	89 e5                	mov    %esp,%ebp
f0102786:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f0102789:	ff 75 08             	pushl  0x8(%ebp)
f010278c:	e8 35 de ff ff       	call   f01005c6 <cputchar>
	*cnt++;
}
f0102791:	83 c4 10             	add    $0x10,%esp
f0102794:	c9                   	leave  
f0102795:	c3                   	ret    

f0102796 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0102796:	55                   	push   %ebp
f0102797:	89 e5                	mov    %esp,%ebp
f0102799:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f010279c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f01027a3:	ff 75 0c             	pushl  0xc(%ebp)
f01027a6:	ff 75 08             	pushl  0x8(%ebp)
f01027a9:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01027ac:	50                   	push   %eax
f01027ad:	68 83 27 10 f0       	push   $0xf0102783
f01027b2:	e8 cc 03 00 00       	call   f0102b83 <vprintfmt>
	return cnt;
}
f01027b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01027ba:	c9                   	leave  
f01027bb:	c3                   	ret    

f01027bc <cprintf>:

int
cprintf(const char *fmt, ...)
{
f01027bc:	55                   	push   %ebp
f01027bd:	89 e5                	mov    %esp,%ebp
f01027bf:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f01027c2:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f01027c5:	50                   	push   %eax
f01027c6:	ff 75 08             	pushl  0x8(%ebp)
f01027c9:	e8 c8 ff ff ff       	call   f0102796 <vcprintf>
	va_end(ap);

	return cnt;
}
f01027ce:	c9                   	leave  
f01027cf:	c3                   	ret    

f01027d0 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f01027d0:	55                   	push   %ebp
f01027d1:	89 e5                	mov    %esp,%ebp
f01027d3:	57                   	push   %edi
f01027d4:	56                   	push   %esi
f01027d5:	53                   	push   %ebx
f01027d6:	83 ec 14             	sub    $0x14,%esp
f01027d9:	89 45 f0             	mov    %eax,-0x10(%ebp)
f01027dc:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f01027df:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f01027e2:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f01027e5:	8b 1a                	mov    (%edx),%ebx
f01027e7:	8b 39                	mov    (%ecx),%edi
f01027e9:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f01027f0:	eb 27                	jmp    f0102819 <stab_binsearch+0x49>

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f01027f2:	8b 5d ec             	mov    -0x14(%ebp),%ebx
f01027f5:	43                   	inc    %ebx
			continue;
f01027f6:	eb 21                	jmp    f0102819 <stab_binsearch+0x49>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f01027f8:	8d 14 00             	lea    (%eax,%eax,1),%edx
f01027fb:	01 c2                	add    %eax,%edx
f01027fd:	8b 4d f0             	mov    -0x10(%ebp),%ecx
f0102800:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0102804:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0102807:	73 44                	jae    f010284d <stab_binsearch+0x7d>
			*region_left = m;
f0102809:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f010280c:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f010280e:	8b 5d ec             	mov    -0x14(%ebp),%ebx
f0102811:	43                   	inc    %ebx
		any_matches = 1;
f0102812:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
	while (l <= r) {
f0102819:	39 fb                	cmp    %edi,%ebx
f010281b:	7f 59                	jg     f0102876 <stab_binsearch+0xa6>
		int true_m = (l + r) / 2, m = true_m;
f010281d:	8d 14 3b             	lea    (%ebx,%edi,1),%edx
f0102820:	89 d0                	mov    %edx,%eax
f0102822:	c1 e8 1f             	shr    $0x1f,%eax
f0102825:	01 d0                	add    %edx,%eax
f0102827:	89 c1                	mov    %eax,%ecx
f0102829:	d1 f9                	sar    %ecx
f010282b:	89 4d ec             	mov    %ecx,-0x14(%ebp)
f010282e:	83 e0 fe             	and    $0xfffffffe,%eax
f0102831:	01 c8                	add    %ecx,%eax
f0102833:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0102836:	8d 14 82             	lea    (%edx,%eax,4),%edx
f0102839:	89 c8                	mov    %ecx,%eax
		while (m >= l && stabs[m].n_type != type)
f010283b:	39 c3                	cmp    %eax,%ebx
f010283d:	7f b3                	jg     f01027f2 <stab_binsearch+0x22>
f010283f:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0102843:	83 ea 0c             	sub    $0xc,%edx
f0102846:	39 f1                	cmp    %esi,%ecx
f0102848:	74 ae                	je     f01027f8 <stab_binsearch+0x28>
			m--;
f010284a:	48                   	dec    %eax
f010284b:	eb ee                	jmp    f010283b <stab_binsearch+0x6b>
		} else if (stabs[m].n_value > addr) {
f010284d:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0102850:	76 11                	jbe    f0102863 <stab_binsearch+0x93>
			*region_right = m - 1;
f0102852:	8d 78 ff             	lea    -0x1(%eax),%edi
f0102855:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0102858:	89 38                	mov    %edi,(%eax)
		any_matches = 1;
f010285a:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0102861:	eb b6                	jmp    f0102819 <stab_binsearch+0x49>
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0102863:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0102866:	89 03                	mov    %eax,(%ebx)
			l = m;
			addr++;
f0102868:	ff 45 0c             	incl   0xc(%ebp)
f010286b:	89 c3                	mov    %eax,%ebx
		any_matches = 1;
f010286d:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0102874:	eb a3                	jmp    f0102819 <stab_binsearch+0x49>
		}
	}

	if (!any_matches)
f0102876:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f010287a:	75 13                	jne    f010288f <stab_binsearch+0xbf>
		*region_right = *region_left - 1;
f010287c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010287f:	8b 00                	mov    (%eax),%eax
f0102881:	48                   	dec    %eax
f0102882:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0102885:	89 07                	mov    %eax,(%edi)
		     l > *region_left && stabs[l].n_type != type;
		     l--)
			/* do nothing */;
		*region_left = l;
	}
}
f0102887:	83 c4 14             	add    $0x14,%esp
f010288a:	5b                   	pop    %ebx
f010288b:	5e                   	pop    %esi
f010288c:	5f                   	pop    %edi
f010288d:	5d                   	pop    %ebp
f010288e:	c3                   	ret    
		for (l = *region_right;
f010288f:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0102892:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0102894:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0102897:	8b 0f                	mov    (%edi),%ecx
f0102899:	8d 14 00             	lea    (%eax,%eax,1),%edx
f010289c:	01 c2                	add    %eax,%edx
f010289e:	8b 7d f0             	mov    -0x10(%ebp),%edi
f01028a1:	8d 14 97             	lea    (%edi,%edx,4),%edx
		for (l = *region_right;
f01028a4:	eb 01                	jmp    f01028a7 <stab_binsearch+0xd7>
		     l--)
f01028a6:	48                   	dec    %eax
		for (l = *region_right;
f01028a7:	39 c1                	cmp    %eax,%ecx
f01028a9:	7d 0b                	jge    f01028b6 <stab_binsearch+0xe6>
		     l > *region_left && stabs[l].n_type != type;
f01028ab:	0f b6 5a 04          	movzbl 0x4(%edx),%ebx
f01028af:	83 ea 0c             	sub    $0xc,%edx
f01028b2:	39 f3                	cmp    %esi,%ebx
f01028b4:	75 f0                	jne    f01028a6 <stab_binsearch+0xd6>
		*region_left = l;
f01028b6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01028b9:	89 07                	mov    %eax,(%edi)
}
f01028bb:	eb ca                	jmp    f0102887 <stab_binsearch+0xb7>

f01028bd <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f01028bd:	55                   	push   %ebp
f01028be:	89 e5                	mov    %esp,%ebp
f01028c0:	57                   	push   %edi
f01028c1:	56                   	push   %esi
f01028c2:	53                   	push   %ebx
f01028c3:	83 ec 1c             	sub    $0x1c,%esp
f01028c6:	8b 7d 08             	mov    0x8(%ebp),%edi
f01028c9:	8b 75 0c             	mov    0xc(%ebp),%esi
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f01028cc:	c7 06 80 45 10 f0    	movl   $0xf0104580,(%esi)
	info->eip_line = 0;
f01028d2:	c7 46 04 00 00 00 00 	movl   $0x0,0x4(%esi)
	info->eip_fn_name = "<unknown>";
f01028d9:	c7 46 08 80 45 10 f0 	movl   $0xf0104580,0x8(%esi)
	info->eip_fn_namelen = 9;
f01028e0:	c7 46 0c 09 00 00 00 	movl   $0x9,0xc(%esi)
	info->eip_fn_addr = addr;
f01028e7:	89 7e 10             	mov    %edi,0x10(%esi)
	info->eip_fn_narg = 0;
f01028ea:	c7 46 14 00 00 00 00 	movl   $0x0,0x14(%esi)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f01028f1:	81 ff ff ff 7f ef    	cmp    $0xef7fffff,%edi
f01028f7:	0f 86 fb 00 00 00    	jbe    f01029f8 <debuginfo_eip+0x13b>
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f01028fd:	b8 f2 d4 10 f0       	mov    $0xf010d4f2,%eax
f0102902:	3d d9 b6 10 f0       	cmp    $0xf010b6d9,%eax
f0102907:	0f 86 6f 01 00 00    	jbe    f0102a7c <debuginfo_eip+0x1bf>
f010290d:	80 3d f1 d4 10 f0 00 	cmpb   $0x0,0xf010d4f1
f0102914:	0f 85 69 01 00 00    	jne    f0102a83 <debuginfo_eip+0x1c6>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f010291a:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0102921:	b8 d8 b6 10 f0       	mov    $0xf010b6d8,%eax
f0102926:	2d b4 47 10 f0       	sub    $0xf01047b4,%eax
f010292b:	89 c2                	mov    %eax,%edx
f010292d:	c1 fa 02             	sar    $0x2,%edx
f0102930:	83 e0 fc             	and    $0xfffffffc,%eax
f0102933:	01 d0                	add    %edx,%eax
f0102935:	8d 04 82             	lea    (%edx,%eax,4),%eax
f0102938:	8d 04 82             	lea    (%edx,%eax,4),%eax
f010293b:	89 c1                	mov    %eax,%ecx
f010293d:	c1 e1 08             	shl    $0x8,%ecx
f0102940:	01 c8                	add    %ecx,%eax
f0102942:	89 c1                	mov    %eax,%ecx
f0102944:	c1 e1 10             	shl    $0x10,%ecx
f0102947:	01 c8                	add    %ecx,%eax
f0102949:	01 c0                	add    %eax,%eax
f010294b:	8d 44 02 ff          	lea    -0x1(%edx,%eax,1),%eax
f010294f:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0102952:	83 ec 08             	sub    $0x8,%esp
f0102955:	57                   	push   %edi
f0102956:	6a 64                	push   $0x64
f0102958:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f010295b:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f010295e:	b8 b4 47 10 f0       	mov    $0xf01047b4,%eax
f0102963:	e8 68 fe ff ff       	call   f01027d0 <stab_binsearch>
	if (lfile == 0)
f0102968:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010296b:	83 c4 10             	add    $0x10,%esp
f010296e:	85 c0                	test   %eax,%eax
f0102970:	0f 84 14 01 00 00    	je     f0102a8a <debuginfo_eip+0x1cd>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0102976:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0102979:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010297c:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f010297f:	83 ec 08             	sub    $0x8,%esp
f0102982:	57                   	push   %edi
f0102983:	6a 24                	push   $0x24
f0102985:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0102988:	8d 55 dc             	lea    -0x24(%ebp),%edx
f010298b:	b8 b4 47 10 f0       	mov    $0xf01047b4,%eax
f0102990:	e8 3b fe ff ff       	call   f01027d0 <stab_binsearch>

	if (lfun <= rfun) {
f0102995:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0102998:	83 c4 10             	add    $0x10,%esp
f010299b:	3b 5d d8             	cmp    -0x28(%ebp),%ebx
f010299e:	7f 6c                	jg     f0102a0c <debuginfo_eip+0x14f>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f01029a0:	8d 04 1b             	lea    (%ebx,%ebx,1),%eax
f01029a3:	01 d8                	add    %ebx,%eax
f01029a5:	c1 e0 02             	shl    $0x2,%eax
f01029a8:	8d 90 b4 47 10 f0    	lea    -0xfefb84c(%eax),%edx
f01029ae:	8b 88 b4 47 10 f0    	mov    -0xfefb84c(%eax),%ecx
f01029b4:	b8 f2 d4 10 f0       	mov    $0xf010d4f2,%eax
f01029b9:	2d d9 b6 10 f0       	sub    $0xf010b6d9,%eax
f01029be:	39 c1                	cmp    %eax,%ecx
f01029c0:	73 09                	jae    f01029cb <debuginfo_eip+0x10e>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f01029c2:	81 c1 d9 b6 10 f0    	add    $0xf010b6d9,%ecx
f01029c8:	89 4e 08             	mov    %ecx,0x8(%esi)
		info->eip_fn_addr = stabs[lfun].n_value;
f01029cb:	8b 42 08             	mov    0x8(%edx),%eax
f01029ce:	89 46 10             	mov    %eax,0x10(%esi)
		info->eip_fn_addr = addr;
		lline = lfile;
		rline = rfile;
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f01029d1:	83 ec 08             	sub    $0x8,%esp
f01029d4:	6a 3a                	push   $0x3a
f01029d6:	ff 76 08             	pushl  0x8(%esi)
f01029d9:	e8 56 08 00 00       	call   f0103234 <strfind>
f01029de:	2b 46 08             	sub    0x8(%esi),%eax
f01029e1:	89 46 0c             	mov    %eax,0xc(%esi)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f01029e4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01029e7:	8d 04 1b             	lea    (%ebx,%ebx,1),%eax
f01029ea:	01 d8                	add    %ebx,%eax
f01029ec:	8d 04 85 b4 47 10 f0 	lea    -0xfefb84c(,%eax,4),%eax
f01029f3:	83 c4 10             	add    $0x10,%esp
f01029f6:	eb 20                	jmp    f0102a18 <debuginfo_eip+0x15b>
  	        panic("User address");
f01029f8:	83 ec 04             	sub    $0x4,%esp
f01029fb:	68 8a 45 10 f0       	push   $0xf010458a
f0102a00:	6a 7f                	push   $0x7f
f0102a02:	68 97 45 10 f0       	push   $0xf0104597
f0102a07:	e8 7f d6 ff ff       	call   f010008b <_panic>
		info->eip_fn_addr = addr;
f0102a0c:	89 7e 10             	mov    %edi,0x10(%esi)
		lline = lfile;
f0102a0f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0102a12:	eb bd                	jmp    f01029d1 <debuginfo_eip+0x114>
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f0102a14:	4b                   	dec    %ebx
f0102a15:	83 e8 0c             	sub    $0xc,%eax
	while (lline >= lfile
f0102a18:	39 df                	cmp    %ebx,%edi
f0102a1a:	7f 35                	jg     f0102a51 <debuginfo_eip+0x194>
	       && stabs[lline].n_type != N_SOL
f0102a1c:	8a 50 04             	mov    0x4(%eax),%dl
f0102a1f:	80 fa 84             	cmp    $0x84,%dl
f0102a22:	74 0b                	je     f0102a2f <debuginfo_eip+0x172>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0102a24:	80 fa 64             	cmp    $0x64,%dl
f0102a27:	75 eb                	jne    f0102a14 <debuginfo_eip+0x157>
f0102a29:	83 78 08 00          	cmpl   $0x0,0x8(%eax)
f0102a2d:	74 e5                	je     f0102a14 <debuginfo_eip+0x157>
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0102a2f:	8d 04 1b             	lea    (%ebx,%ebx,1),%eax
f0102a32:	01 c3                	add    %eax,%ebx
f0102a34:	8b 14 9d b4 47 10 f0 	mov    -0xfefb84c(,%ebx,4),%edx
f0102a3b:	b8 f2 d4 10 f0       	mov    $0xf010d4f2,%eax
f0102a40:	2d d9 b6 10 f0       	sub    $0xf010b6d9,%eax
f0102a45:	39 c2                	cmp    %eax,%edx
f0102a47:	73 08                	jae    f0102a51 <debuginfo_eip+0x194>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0102a49:	81 c2 d9 b6 10 f0    	add    $0xf010b6d9,%edx
f0102a4f:	89 16                	mov    %edx,(%esi)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0102a51:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0102a54:	8b 4d d8             	mov    -0x28(%ebp),%ecx
f0102a57:	39 c8                	cmp    %ecx,%eax
f0102a59:	7d 36                	jge    f0102a91 <debuginfo_eip+0x1d4>
		for (lline = lfun + 1;
f0102a5b:	40                   	inc    %eax
f0102a5c:	eb 04                	jmp    f0102a62 <debuginfo_eip+0x1a5>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f0102a5e:	ff 46 14             	incl   0x14(%esi)
		     lline++)
f0102a61:	40                   	inc    %eax
		for (lline = lfun + 1;
f0102a62:	39 c1                	cmp    %eax,%ecx
f0102a64:	74 38                	je     f0102a9e <debuginfo_eip+0x1e1>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0102a66:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0102a69:	01 c2                	add    %eax,%edx
f0102a6b:	80 3c 95 b8 47 10 f0 	cmpb   $0xa0,-0xfefb848(,%edx,4)
f0102a72:	a0 
f0102a73:	74 e9                	je     f0102a5e <debuginfo_eip+0x1a1>

	return 0;
f0102a75:	b8 00 00 00 00       	mov    $0x0,%eax
f0102a7a:	eb 1a                	jmp    f0102a96 <debuginfo_eip+0x1d9>
		return -1;
f0102a7c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0102a81:	eb 13                	jmp    f0102a96 <debuginfo_eip+0x1d9>
f0102a83:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0102a88:	eb 0c                	jmp    f0102a96 <debuginfo_eip+0x1d9>
		return -1;
f0102a8a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0102a8f:	eb 05                	jmp    f0102a96 <debuginfo_eip+0x1d9>
	return 0;
f0102a91:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0102a96:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102a99:	5b                   	pop    %ebx
f0102a9a:	5e                   	pop    %esi
f0102a9b:	5f                   	pop    %edi
f0102a9c:	5d                   	pop    %ebp
f0102a9d:	c3                   	ret    
	return 0;
f0102a9e:	b8 00 00 00 00       	mov    $0x0,%eax
f0102aa3:	eb f1                	jmp    f0102a96 <debuginfo_eip+0x1d9>

f0102aa5 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0102aa5:	55                   	push   %ebp
f0102aa6:	89 e5                	mov    %esp,%ebp
f0102aa8:	57                   	push   %edi
f0102aa9:	56                   	push   %esi
f0102aaa:	53                   	push   %ebx
f0102aab:	83 ec 1c             	sub    $0x1c,%esp
f0102aae:	89 c7                	mov    %eax,%edi
f0102ab0:	89 d6                	mov    %edx,%esi
f0102ab2:	8b 45 08             	mov    0x8(%ebp),%eax
f0102ab5:	8b 55 0c             	mov    0xc(%ebp),%edx
f0102ab8:	89 d1                	mov    %edx,%ecx
f0102aba:	89 c2                	mov    %eax,%edx
f0102abc:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0102abf:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0102ac2:	8b 45 10             	mov    0x10(%ebp),%eax
f0102ac5:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0102ac8:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0102acb:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f0102ad2:	39 c2                	cmp    %eax,%edx
f0102ad4:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
f0102ad7:	72 3c                	jb     f0102b15 <printnum+0x70>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0102ad9:	83 ec 0c             	sub    $0xc,%esp
f0102adc:	ff 75 18             	pushl  0x18(%ebp)
f0102adf:	4b                   	dec    %ebx
f0102ae0:	53                   	push   %ebx
f0102ae1:	50                   	push   %eax
f0102ae2:	83 ec 08             	sub    $0x8,%esp
f0102ae5:	ff 75 e4             	pushl  -0x1c(%ebp)
f0102ae8:	ff 75 e0             	pushl  -0x20(%ebp)
f0102aeb:	ff 75 dc             	pushl  -0x24(%ebp)
f0102aee:	ff 75 d8             	pushl  -0x28(%ebp)
f0102af1:	e8 32 09 00 00       	call   f0103428 <__udivdi3>
f0102af6:	83 c4 18             	add    $0x18,%esp
f0102af9:	52                   	push   %edx
f0102afa:	50                   	push   %eax
f0102afb:	89 f2                	mov    %esi,%edx
f0102afd:	89 f8                	mov    %edi,%eax
f0102aff:	e8 a1 ff ff ff       	call   f0102aa5 <printnum>
f0102b04:	83 c4 20             	add    $0x20,%esp
f0102b07:	eb 11                	jmp    f0102b1a <printnum+0x75>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0102b09:	83 ec 08             	sub    $0x8,%esp
f0102b0c:	56                   	push   %esi
f0102b0d:	ff 75 18             	pushl  0x18(%ebp)
f0102b10:	ff d7                	call   *%edi
f0102b12:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
f0102b15:	4b                   	dec    %ebx
f0102b16:	85 db                	test   %ebx,%ebx
f0102b18:	7f ef                	jg     f0102b09 <printnum+0x64>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0102b1a:	83 ec 08             	sub    $0x8,%esp
f0102b1d:	56                   	push   %esi
f0102b1e:	83 ec 04             	sub    $0x4,%esp
f0102b21:	ff 75 e4             	pushl  -0x1c(%ebp)
f0102b24:	ff 75 e0             	pushl  -0x20(%ebp)
f0102b27:	ff 75 dc             	pushl  -0x24(%ebp)
f0102b2a:	ff 75 d8             	pushl  -0x28(%ebp)
f0102b2d:	e8 f6 09 00 00       	call   f0103528 <__umoddi3>
f0102b32:	83 c4 14             	add    $0x14,%esp
f0102b35:	0f be 80 a5 45 10 f0 	movsbl -0xfefba5b(%eax),%eax
f0102b3c:	50                   	push   %eax
f0102b3d:	ff d7                	call   *%edi
}
f0102b3f:	83 c4 10             	add    $0x10,%esp
f0102b42:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102b45:	5b                   	pop    %ebx
f0102b46:	5e                   	pop    %esi
f0102b47:	5f                   	pop    %edi
f0102b48:	5d                   	pop    %ebp
f0102b49:	c3                   	ret    

f0102b4a <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0102b4a:	55                   	push   %ebp
f0102b4b:	89 e5                	mov    %esp,%ebp
f0102b4d:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0102b50:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
f0102b53:	8b 10                	mov    (%eax),%edx
f0102b55:	3b 50 04             	cmp    0x4(%eax),%edx
f0102b58:	73 0a                	jae    f0102b64 <sprintputch+0x1a>
		*b->buf++ = ch;
f0102b5a:	8d 4a 01             	lea    0x1(%edx),%ecx
f0102b5d:	89 08                	mov    %ecx,(%eax)
f0102b5f:	8b 45 08             	mov    0x8(%ebp),%eax
f0102b62:	88 02                	mov    %al,(%edx)
}
f0102b64:	5d                   	pop    %ebp
f0102b65:	c3                   	ret    

f0102b66 <printfmt>:
{
f0102b66:	55                   	push   %ebp
f0102b67:	89 e5                	mov    %esp,%ebp
f0102b69:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
f0102b6c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0102b6f:	50                   	push   %eax
f0102b70:	ff 75 10             	pushl  0x10(%ebp)
f0102b73:	ff 75 0c             	pushl  0xc(%ebp)
f0102b76:	ff 75 08             	pushl  0x8(%ebp)
f0102b79:	e8 05 00 00 00       	call   f0102b83 <vprintfmt>
}
f0102b7e:	83 c4 10             	add    $0x10,%esp
f0102b81:	c9                   	leave  
f0102b82:	c3                   	ret    

f0102b83 <vprintfmt>:
{
f0102b83:	55                   	push   %ebp
f0102b84:	89 e5                	mov    %esp,%ebp
f0102b86:	57                   	push   %edi
f0102b87:	56                   	push   %esi
f0102b88:	53                   	push   %ebx
f0102b89:	83 ec 3c             	sub    $0x3c,%esp
f0102b8c:	8b 75 08             	mov    0x8(%ebp),%esi
f0102b8f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0102b92:	8b 7d 10             	mov    0x10(%ebp),%edi
f0102b95:	e9 5b 03 00 00       	jmp    f0102ef5 <vprintfmt+0x372>
		padc = ' ';
f0102b9a:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
f0102b9e:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
		precision = -1;
f0102ba5:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
f0102bac:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		lflag = 0;
f0102bb3:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
f0102bb8:	8d 47 01             	lea    0x1(%edi),%eax
f0102bbb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0102bbe:	8a 17                	mov    (%edi),%dl
f0102bc0:	8d 42 dd             	lea    -0x23(%edx),%eax
f0102bc3:	3c 55                	cmp    $0x55,%al
f0102bc5:	0f 87 ab 03 00 00    	ja     f0102f76 <vprintfmt+0x3f3>
f0102bcb:	0f b6 c0             	movzbl %al,%eax
f0102bce:	ff 24 85 30 46 10 f0 	jmp    *-0xfefb9d0(,%eax,4)
f0102bd5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
f0102bd8:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
f0102bdc:	eb da                	jmp    f0102bb8 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
f0102bde:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0102be1:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
f0102be5:	eb d1                	jmp    f0102bb8 <vprintfmt+0x35>
f0102be7:	0f b6 d2             	movzbl %dl,%edx
f0102bea:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
f0102bed:	b8 00 00 00 00       	mov    $0x0,%eax
f0102bf2:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
f0102bf5:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0102bf8:	01 c0                	add    %eax,%eax
f0102bfa:	8d 44 02 d0          	lea    -0x30(%edx,%eax,1),%eax
				ch = *fmt;
f0102bfe:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
f0102c01:	8d 4a d0             	lea    -0x30(%edx),%ecx
f0102c04:	83 f9 09             	cmp    $0x9,%ecx
f0102c07:	77 52                	ja     f0102c5b <vprintfmt+0xd8>
			for (precision = 0; ; ++fmt) {
f0102c09:	47                   	inc    %edi
				precision = precision * 10 + ch - '0';
f0102c0a:	eb e9                	jmp    f0102bf5 <vprintfmt+0x72>
			precision = va_arg(ap, int);
f0102c0c:	8b 45 14             	mov    0x14(%ebp),%eax
f0102c0f:	8b 00                	mov    (%eax),%eax
f0102c11:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0102c14:	8b 45 14             	mov    0x14(%ebp),%eax
f0102c17:	8d 40 04             	lea    0x4(%eax),%eax
f0102c1a:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0102c1d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
f0102c20:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f0102c24:	79 92                	jns    f0102bb8 <vprintfmt+0x35>
				width = precision, precision = -1;
f0102c26:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0102c29:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102c2c:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
f0102c33:	eb 83                	jmp    f0102bb8 <vprintfmt+0x35>
f0102c35:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f0102c39:	78 08                	js     f0102c43 <vprintfmt+0xc0>
		switch (ch = *(unsigned char *) fmt++) {
f0102c3b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
f0102c3e:	e9 75 ff ff ff       	jmp    f0102bb8 <vprintfmt+0x35>
f0102c43:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
f0102c4a:	eb ef                	jmp    f0102c3b <vprintfmt+0xb8>
		switch (ch = *(unsigned char *) fmt++) {
f0102c4c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
f0102c4f:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
f0102c56:	e9 5d ff ff ff       	jmp    f0102bb8 <vprintfmt+0x35>
f0102c5b:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0102c5e:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0102c61:	eb bd                	jmp    f0102c20 <vprintfmt+0x9d>
			lflag++;
f0102c63:	41                   	inc    %ecx
		switch (ch = *(unsigned char *) fmt++) {
f0102c64:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
f0102c67:	e9 4c ff ff ff       	jmp    f0102bb8 <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
f0102c6c:	8b 45 14             	mov    0x14(%ebp),%eax
f0102c6f:	8d 78 04             	lea    0x4(%eax),%edi
f0102c72:	83 ec 08             	sub    $0x8,%esp
f0102c75:	53                   	push   %ebx
f0102c76:	ff 30                	pushl  (%eax)
f0102c78:	ff d6                	call   *%esi
			break;
f0102c7a:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
f0102c7d:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
f0102c80:	e9 6d 02 00 00       	jmp    f0102ef2 <vprintfmt+0x36f>
			err = va_arg(ap, int);
f0102c85:	8b 45 14             	mov    0x14(%ebp),%eax
f0102c88:	8d 78 04             	lea    0x4(%eax),%edi
f0102c8b:	8b 00                	mov    (%eax),%eax
f0102c8d:	85 c0                	test   %eax,%eax
f0102c8f:	78 2a                	js     f0102cbb <vprintfmt+0x138>
f0102c91:	89 c2                	mov    %eax,%edx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0102c93:	83 f8 06             	cmp    $0x6,%eax
f0102c96:	7f 27                	jg     f0102cbf <vprintfmt+0x13c>
f0102c98:	8b 04 85 88 47 10 f0 	mov    -0xfefb878(,%eax,4),%eax
f0102c9f:	85 c0                	test   %eax,%eax
f0102ca1:	74 1c                	je     f0102cbf <vprintfmt+0x13c>
				printfmt(putch, putdat, "%s", p);
f0102ca3:	50                   	push   %eax
f0102ca4:	68 43 3b 10 f0       	push   $0xf0103b43
f0102ca9:	53                   	push   %ebx
f0102caa:	56                   	push   %esi
f0102cab:	e8 b6 fe ff ff       	call   f0102b66 <printfmt>
f0102cb0:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f0102cb3:	89 7d 14             	mov    %edi,0x14(%ebp)
f0102cb6:	e9 37 02 00 00       	jmp    f0102ef2 <vprintfmt+0x36f>
f0102cbb:	f7 d8                	neg    %eax
f0102cbd:	eb d2                	jmp    f0102c91 <vprintfmt+0x10e>
				printfmt(putch, putdat, "error %d", err);
f0102cbf:	52                   	push   %edx
f0102cc0:	68 bd 45 10 f0       	push   $0xf01045bd
f0102cc5:	53                   	push   %ebx
f0102cc6:	56                   	push   %esi
f0102cc7:	e8 9a fe ff ff       	call   f0102b66 <printfmt>
f0102ccc:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f0102ccf:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
f0102cd2:	e9 1b 02 00 00       	jmp    f0102ef2 <vprintfmt+0x36f>
			if ((p = va_arg(ap, char *)) == NULL)
f0102cd7:	8b 45 14             	mov    0x14(%ebp),%eax
f0102cda:	83 c0 04             	add    $0x4,%eax
f0102cdd:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0102ce0:	8b 45 14             	mov    0x14(%ebp),%eax
f0102ce3:	8b 00                	mov    (%eax),%eax
f0102ce5:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0102ce8:	85 c0                	test   %eax,%eax
f0102cea:	74 19                	je     f0102d05 <vprintfmt+0x182>
			if (width > 0 && padc != '-')
f0102cec:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f0102cf0:	7e 06                	jle    f0102cf8 <vprintfmt+0x175>
f0102cf2:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
f0102cf6:	75 16                	jne    f0102d0e <vprintfmt+0x18b>
				for (width -= strnlen(p, precision); width > 0; width--)
f0102cf8:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0102cfb:	89 c7                	mov    %eax,%edi
f0102cfd:	03 45 d4             	add    -0x2c(%ebp),%eax
f0102d00:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102d03:	eb 62                	jmp    f0102d67 <vprintfmt+0x1e4>
				p = "(null)";
f0102d05:	c7 45 cc b6 45 10 f0 	movl   $0xf01045b6,-0x34(%ebp)
f0102d0c:	eb de                	jmp    f0102cec <vprintfmt+0x169>
				for (width -= strnlen(p, precision); width > 0; width--)
f0102d0e:	83 ec 08             	sub    $0x8,%esp
f0102d11:	ff 75 d8             	pushl  -0x28(%ebp)
f0102d14:	ff 75 cc             	pushl  -0x34(%ebp)
f0102d17:	e8 e2 03 00 00       	call   f01030fe <strnlen>
f0102d1c:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0102d1f:	29 c2                	sub    %eax,%edx
f0102d21:	89 55 c4             	mov    %edx,-0x3c(%ebp)
f0102d24:	83 c4 10             	add    $0x10,%esp
f0102d27:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
f0102d29:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
f0102d2d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
f0102d30:	eb 0d                	jmp    f0102d3f <vprintfmt+0x1bc>
					putch(padc, putdat);
f0102d32:	83 ec 08             	sub    $0x8,%esp
f0102d35:	53                   	push   %ebx
f0102d36:	ff 75 d4             	pushl  -0x2c(%ebp)
f0102d39:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
f0102d3b:	4f                   	dec    %edi
f0102d3c:	83 c4 10             	add    $0x10,%esp
f0102d3f:	85 ff                	test   %edi,%edi
f0102d41:	7f ef                	jg     f0102d32 <vprintfmt+0x1af>
f0102d43:	8b 55 c4             	mov    -0x3c(%ebp),%edx
f0102d46:	89 d0                	mov    %edx,%eax
f0102d48:	85 d2                	test   %edx,%edx
f0102d4a:	78 0a                	js     f0102d56 <vprintfmt+0x1d3>
f0102d4c:	8b 55 c4             	mov    -0x3c(%ebp),%edx
f0102d4f:	29 c2                	sub    %eax,%edx
f0102d51:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f0102d54:	eb a2                	jmp    f0102cf8 <vprintfmt+0x175>
f0102d56:	b8 00 00 00 00       	mov    $0x0,%eax
f0102d5b:	eb ef                	jmp    f0102d4c <vprintfmt+0x1c9>
					putch(ch, putdat);
f0102d5d:	83 ec 08             	sub    $0x8,%esp
f0102d60:	53                   	push   %ebx
f0102d61:	52                   	push   %edx
f0102d62:	ff d6                	call   *%esi
f0102d64:	83 c4 10             	add    $0x10,%esp
f0102d67:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0102d6a:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0102d6c:	47                   	inc    %edi
f0102d6d:	8a 47 ff             	mov    -0x1(%edi),%al
f0102d70:	0f be d0             	movsbl %al,%edx
f0102d73:	85 d2                	test   %edx,%edx
f0102d75:	74 48                	je     f0102dbf <vprintfmt+0x23c>
f0102d77:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0102d7b:	78 05                	js     f0102d82 <vprintfmt+0x1ff>
f0102d7d:	ff 4d d8             	decl   -0x28(%ebp)
f0102d80:	78 1e                	js     f0102da0 <vprintfmt+0x21d>
				if (altflag && (ch < ' ' || ch > '~'))
f0102d82:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0102d86:	74 d5                	je     f0102d5d <vprintfmt+0x1da>
f0102d88:	0f be c0             	movsbl %al,%eax
f0102d8b:	83 e8 20             	sub    $0x20,%eax
f0102d8e:	83 f8 5e             	cmp    $0x5e,%eax
f0102d91:	76 ca                	jbe    f0102d5d <vprintfmt+0x1da>
					putch('?', putdat);
f0102d93:	83 ec 08             	sub    $0x8,%esp
f0102d96:	53                   	push   %ebx
f0102d97:	6a 3f                	push   $0x3f
f0102d99:	ff d6                	call   *%esi
f0102d9b:	83 c4 10             	add    $0x10,%esp
f0102d9e:	eb c7                	jmp    f0102d67 <vprintfmt+0x1e4>
f0102da0:	89 cf                	mov    %ecx,%edi
f0102da2:	eb 0c                	jmp    f0102db0 <vprintfmt+0x22d>
				putch(' ', putdat);
f0102da4:	83 ec 08             	sub    $0x8,%esp
f0102da7:	53                   	push   %ebx
f0102da8:	6a 20                	push   $0x20
f0102daa:	ff d6                	call   *%esi
			for (; width > 0; width--)
f0102dac:	4f                   	dec    %edi
f0102dad:	83 c4 10             	add    $0x10,%esp
f0102db0:	85 ff                	test   %edi,%edi
f0102db2:	7f f0                	jg     f0102da4 <vprintfmt+0x221>
			if ((p = va_arg(ap, char *)) == NULL)
f0102db4:	8b 45 c8             	mov    -0x38(%ebp),%eax
f0102db7:	89 45 14             	mov    %eax,0x14(%ebp)
f0102dba:	e9 33 01 00 00       	jmp    f0102ef2 <vprintfmt+0x36f>
f0102dbf:	89 cf                	mov    %ecx,%edi
f0102dc1:	eb ed                	jmp    f0102db0 <vprintfmt+0x22d>
	if (lflag >= 2)
f0102dc3:	83 f9 01             	cmp    $0x1,%ecx
f0102dc6:	7f 1b                	jg     f0102de3 <vprintfmt+0x260>
	else if (lflag)
f0102dc8:	85 c9                	test   %ecx,%ecx
f0102dca:	74 42                	je     f0102e0e <vprintfmt+0x28b>
		return va_arg(*ap, long);
f0102dcc:	8b 45 14             	mov    0x14(%ebp),%eax
f0102dcf:	8b 00                	mov    (%eax),%eax
f0102dd1:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0102dd4:	99                   	cltd   
f0102dd5:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0102dd8:	8b 45 14             	mov    0x14(%ebp),%eax
f0102ddb:	8d 40 04             	lea    0x4(%eax),%eax
f0102dde:	89 45 14             	mov    %eax,0x14(%ebp)
f0102de1:	eb 17                	jmp    f0102dfa <vprintfmt+0x277>
		return va_arg(*ap, long long);
f0102de3:	8b 45 14             	mov    0x14(%ebp),%eax
f0102de6:	8b 50 04             	mov    0x4(%eax),%edx
f0102de9:	8b 00                	mov    (%eax),%eax
f0102deb:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0102dee:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0102df1:	8b 45 14             	mov    0x14(%ebp),%eax
f0102df4:	8d 40 08             	lea    0x8(%eax),%eax
f0102df7:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
f0102dfa:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0102dfd:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f0102e00:	85 c9                	test   %ecx,%ecx
f0102e02:	78 21                	js     f0102e25 <vprintfmt+0x2a2>
			base = 10;
f0102e04:	b8 0a 00 00 00       	mov    $0xa,%eax
f0102e09:	e9 ca 00 00 00       	jmp    f0102ed8 <vprintfmt+0x355>
		return va_arg(*ap, int);
f0102e0e:	8b 45 14             	mov    0x14(%ebp),%eax
f0102e11:	8b 00                	mov    (%eax),%eax
f0102e13:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0102e16:	99                   	cltd   
f0102e17:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0102e1a:	8b 45 14             	mov    0x14(%ebp),%eax
f0102e1d:	8d 40 04             	lea    0x4(%eax),%eax
f0102e20:	89 45 14             	mov    %eax,0x14(%ebp)
f0102e23:	eb d5                	jmp    f0102dfa <vprintfmt+0x277>
				putch('-', putdat);
f0102e25:	83 ec 08             	sub    $0x8,%esp
f0102e28:	53                   	push   %ebx
f0102e29:	6a 2d                	push   $0x2d
f0102e2b:	ff d6                	call   *%esi
				num = -(long long) num;
f0102e2d:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0102e30:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f0102e33:	f7 da                	neg    %edx
f0102e35:	83 d1 00             	adc    $0x0,%ecx
f0102e38:	f7 d9                	neg    %ecx
f0102e3a:	83 c4 10             	add    $0x10,%esp
			base = 10;
f0102e3d:	b8 0a 00 00 00       	mov    $0xa,%eax
f0102e42:	e9 91 00 00 00       	jmp    f0102ed8 <vprintfmt+0x355>
	if (lflag >= 2)
f0102e47:	83 f9 01             	cmp    $0x1,%ecx
f0102e4a:	7f 1b                	jg     f0102e67 <vprintfmt+0x2e4>
	else if (lflag)
f0102e4c:	85 c9                	test   %ecx,%ecx
f0102e4e:	74 2c                	je     f0102e7c <vprintfmt+0x2f9>
		return va_arg(*ap, unsigned long);
f0102e50:	8b 45 14             	mov    0x14(%ebp),%eax
f0102e53:	8b 10                	mov    (%eax),%edx
f0102e55:	b9 00 00 00 00       	mov    $0x0,%ecx
f0102e5a:	8d 40 04             	lea    0x4(%eax),%eax
f0102e5d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0102e60:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
f0102e65:	eb 71                	jmp    f0102ed8 <vprintfmt+0x355>
		return va_arg(*ap, unsigned long long);
f0102e67:	8b 45 14             	mov    0x14(%ebp),%eax
f0102e6a:	8b 10                	mov    (%eax),%edx
f0102e6c:	8b 48 04             	mov    0x4(%eax),%ecx
f0102e6f:	8d 40 08             	lea    0x8(%eax),%eax
f0102e72:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0102e75:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
f0102e7a:	eb 5c                	jmp    f0102ed8 <vprintfmt+0x355>
		return va_arg(*ap, unsigned int);
f0102e7c:	8b 45 14             	mov    0x14(%ebp),%eax
f0102e7f:	8b 10                	mov    (%eax),%edx
f0102e81:	b9 00 00 00 00       	mov    $0x0,%ecx
f0102e86:	8d 40 04             	lea    0x4(%eax),%eax
f0102e89:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0102e8c:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
f0102e91:	eb 45                	jmp    f0102ed8 <vprintfmt+0x355>
			putch('X', putdat);
f0102e93:	83 ec 08             	sub    $0x8,%esp
f0102e96:	53                   	push   %ebx
f0102e97:	6a 58                	push   $0x58
f0102e99:	ff d6                	call   *%esi
			putch('X', putdat);
f0102e9b:	83 c4 08             	add    $0x8,%esp
f0102e9e:	53                   	push   %ebx
f0102e9f:	6a 58                	push   $0x58
f0102ea1:	ff d6                	call   *%esi
			putch('X', putdat);
f0102ea3:	83 c4 08             	add    $0x8,%esp
f0102ea6:	53                   	push   %ebx
f0102ea7:	6a 58                	push   $0x58
f0102ea9:	ff d6                	call   *%esi
			break;
f0102eab:	83 c4 10             	add    $0x10,%esp
f0102eae:	eb 42                	jmp    f0102ef2 <vprintfmt+0x36f>
			putch('0', putdat);
f0102eb0:	83 ec 08             	sub    $0x8,%esp
f0102eb3:	53                   	push   %ebx
f0102eb4:	6a 30                	push   $0x30
f0102eb6:	ff d6                	call   *%esi
			putch('x', putdat);
f0102eb8:	83 c4 08             	add    $0x8,%esp
f0102ebb:	53                   	push   %ebx
f0102ebc:	6a 78                	push   $0x78
f0102ebe:	ff d6                	call   *%esi
			num = (unsigned long long)
f0102ec0:	8b 45 14             	mov    0x14(%ebp),%eax
f0102ec3:	8b 10                	mov    (%eax),%edx
f0102ec5:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
f0102eca:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
f0102ecd:	8d 40 04             	lea    0x4(%eax),%eax
f0102ed0:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0102ed3:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
f0102ed8:	83 ec 0c             	sub    $0xc,%esp
f0102edb:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
f0102edf:	57                   	push   %edi
f0102ee0:	ff 75 d4             	pushl  -0x2c(%ebp)
f0102ee3:	50                   	push   %eax
f0102ee4:	51                   	push   %ecx
f0102ee5:	52                   	push   %edx
f0102ee6:	89 da                	mov    %ebx,%edx
f0102ee8:	89 f0                	mov    %esi,%eax
f0102eea:	e8 b6 fb ff ff       	call   f0102aa5 <printnum>
			break;
f0102eef:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
f0102ef2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0102ef5:	47                   	inc    %edi
f0102ef6:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0102efa:	83 f8 25             	cmp    $0x25,%eax
f0102efd:	0f 84 97 fc ff ff    	je     f0102b9a <vprintfmt+0x17>
			if (ch == '\0')
f0102f03:	85 c0                	test   %eax,%eax
f0102f05:	0f 84 89 00 00 00    	je     f0102f94 <vprintfmt+0x411>
			putch(ch, putdat);
f0102f0b:	83 ec 08             	sub    $0x8,%esp
f0102f0e:	53                   	push   %ebx
f0102f0f:	50                   	push   %eax
f0102f10:	ff d6                	call   *%esi
f0102f12:	83 c4 10             	add    $0x10,%esp
f0102f15:	eb de                	jmp    f0102ef5 <vprintfmt+0x372>
	if (lflag >= 2)
f0102f17:	83 f9 01             	cmp    $0x1,%ecx
f0102f1a:	7f 1b                	jg     f0102f37 <vprintfmt+0x3b4>
	else if (lflag)
f0102f1c:	85 c9                	test   %ecx,%ecx
f0102f1e:	74 2c                	je     f0102f4c <vprintfmt+0x3c9>
		return va_arg(*ap, unsigned long);
f0102f20:	8b 45 14             	mov    0x14(%ebp),%eax
f0102f23:	8b 10                	mov    (%eax),%edx
f0102f25:	b9 00 00 00 00       	mov    $0x0,%ecx
f0102f2a:	8d 40 04             	lea    0x4(%eax),%eax
f0102f2d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0102f30:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
f0102f35:	eb a1                	jmp    f0102ed8 <vprintfmt+0x355>
		return va_arg(*ap, unsigned long long);
f0102f37:	8b 45 14             	mov    0x14(%ebp),%eax
f0102f3a:	8b 10                	mov    (%eax),%edx
f0102f3c:	8b 48 04             	mov    0x4(%eax),%ecx
f0102f3f:	8d 40 08             	lea    0x8(%eax),%eax
f0102f42:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0102f45:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
f0102f4a:	eb 8c                	jmp    f0102ed8 <vprintfmt+0x355>
		return va_arg(*ap, unsigned int);
f0102f4c:	8b 45 14             	mov    0x14(%ebp),%eax
f0102f4f:	8b 10                	mov    (%eax),%edx
f0102f51:	b9 00 00 00 00       	mov    $0x0,%ecx
f0102f56:	8d 40 04             	lea    0x4(%eax),%eax
f0102f59:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0102f5c:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
f0102f61:	e9 72 ff ff ff       	jmp    f0102ed8 <vprintfmt+0x355>
			putch(ch, putdat);
f0102f66:	83 ec 08             	sub    $0x8,%esp
f0102f69:	53                   	push   %ebx
f0102f6a:	6a 25                	push   $0x25
f0102f6c:	ff d6                	call   *%esi
			break;
f0102f6e:	83 c4 10             	add    $0x10,%esp
f0102f71:	e9 7c ff ff ff       	jmp    f0102ef2 <vprintfmt+0x36f>
			putch('%', putdat);
f0102f76:	83 ec 08             	sub    $0x8,%esp
f0102f79:	53                   	push   %ebx
f0102f7a:	6a 25                	push   $0x25
f0102f7c:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f0102f7e:	83 c4 10             	add    $0x10,%esp
f0102f81:	89 f8                	mov    %edi,%eax
f0102f83:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
f0102f87:	74 03                	je     f0102f8c <vprintfmt+0x409>
f0102f89:	48                   	dec    %eax
f0102f8a:	eb f7                	jmp    f0102f83 <vprintfmt+0x400>
f0102f8c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0102f8f:	e9 5e ff ff ff       	jmp    f0102ef2 <vprintfmt+0x36f>
}
f0102f94:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102f97:	5b                   	pop    %ebx
f0102f98:	5e                   	pop    %esi
f0102f99:	5f                   	pop    %edi
f0102f9a:	5d                   	pop    %ebp
f0102f9b:	c3                   	ret    

f0102f9c <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0102f9c:	55                   	push   %ebp
f0102f9d:	89 e5                	mov    %esp,%ebp
f0102f9f:	83 ec 18             	sub    $0x18,%esp
f0102fa2:	8b 45 08             	mov    0x8(%ebp),%eax
f0102fa5:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0102fa8:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0102fab:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0102faf:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0102fb2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0102fb9:	85 c0                	test   %eax,%eax
f0102fbb:	74 26                	je     f0102fe3 <vsnprintf+0x47>
f0102fbd:	85 d2                	test   %edx,%edx
f0102fbf:	7e 29                	jle    f0102fea <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0102fc1:	ff 75 14             	pushl  0x14(%ebp)
f0102fc4:	ff 75 10             	pushl  0x10(%ebp)
f0102fc7:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0102fca:	50                   	push   %eax
f0102fcb:	68 4a 2b 10 f0       	push   $0xf0102b4a
f0102fd0:	e8 ae fb ff ff       	call   f0102b83 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0102fd5:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0102fd8:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0102fdb:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0102fde:	83 c4 10             	add    $0x10,%esp
}
f0102fe1:	c9                   	leave  
f0102fe2:	c3                   	ret    
		return -E_INVAL;
f0102fe3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0102fe8:	eb f7                	jmp    f0102fe1 <vsnprintf+0x45>
f0102fea:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0102fef:	eb f0                	jmp    f0102fe1 <vsnprintf+0x45>

f0102ff1 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0102ff1:	55                   	push   %ebp
f0102ff2:	89 e5                	mov    %esp,%ebp
f0102ff4:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0102ff7:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0102ffa:	50                   	push   %eax
f0102ffb:	ff 75 10             	pushl  0x10(%ebp)
f0102ffe:	ff 75 0c             	pushl  0xc(%ebp)
f0103001:	ff 75 08             	pushl  0x8(%ebp)
f0103004:	e8 93 ff ff ff       	call   f0102f9c <vsnprintf>
	va_end(ap);

	return rc;
}
f0103009:	c9                   	leave  
f010300a:	c3                   	ret    

f010300b <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f010300b:	55                   	push   %ebp
f010300c:	89 e5                	mov    %esp,%ebp
f010300e:	57                   	push   %edi
f010300f:	56                   	push   %esi
f0103010:	53                   	push   %ebx
f0103011:	83 ec 0c             	sub    $0xc,%esp
f0103014:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f0103017:	85 c0                	test   %eax,%eax
f0103019:	74 11                	je     f010302c <readline+0x21>
		cprintf("%s", prompt);
f010301b:	83 ec 08             	sub    $0x8,%esp
f010301e:	50                   	push   %eax
f010301f:	68 43 3b 10 f0       	push   $0xf0103b43
f0103024:	e8 93 f7 ff ff       	call   f01027bc <cprintf>
f0103029:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f010302c:	83 ec 0c             	sub    $0xc,%esp
f010302f:	6a 00                	push   $0x0
f0103031:	e8 b1 d5 ff ff       	call   f01005e7 <iscons>
f0103036:	89 c7                	mov    %eax,%edi
f0103038:	83 c4 10             	add    $0x10,%esp
	i = 0;
f010303b:	be 00 00 00 00       	mov    $0x0,%esi
f0103040:	eb 75                	jmp    f01030b7 <readline+0xac>
	while (1) {
		c = getchar();
		if (c < 0) {
			cprintf("read error: %e\n", c);
f0103042:	83 ec 08             	sub    $0x8,%esp
f0103045:	50                   	push   %eax
f0103046:	68 a4 47 10 f0       	push   $0xf01047a4
f010304b:	e8 6c f7 ff ff       	call   f01027bc <cprintf>
			return NULL;
f0103050:	83 c4 10             	add    $0x10,%esp
f0103053:	b8 00 00 00 00       	mov    $0x0,%eax
				cputchar('\n');
			buf[i] = 0;
			return buf;
		}
	}
}
f0103058:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010305b:	5b                   	pop    %ebx
f010305c:	5e                   	pop    %esi
f010305d:	5f                   	pop    %edi
f010305e:	5d                   	pop    %ebp
f010305f:	c3                   	ret    
				cputchar('\b');
f0103060:	83 ec 0c             	sub    $0xc,%esp
f0103063:	6a 08                	push   $0x8
f0103065:	e8 5c d5 ff ff       	call   f01005c6 <cputchar>
f010306a:	83 c4 10             	add    $0x10,%esp
f010306d:	eb 47                	jmp    f01030b6 <readline+0xab>
				cputchar(c);
f010306f:	83 ec 0c             	sub    $0xc,%esp
f0103072:	53                   	push   %ebx
f0103073:	e8 4e d5 ff ff       	call   f01005c6 <cputchar>
f0103078:	83 c4 10             	add    $0x10,%esp
f010307b:	eb 60                	jmp    f01030dd <readline+0xd2>
		} else if (c == '\n' || c == '\r') {
f010307d:	83 f8 0a             	cmp    $0xa,%eax
f0103080:	74 05                	je     f0103087 <readline+0x7c>
f0103082:	83 f8 0d             	cmp    $0xd,%eax
f0103085:	75 30                	jne    f01030b7 <readline+0xac>
			if (echoing)
f0103087:	85 ff                	test   %edi,%edi
f0103089:	75 0e                	jne    f0103099 <readline+0x8e>
			buf[i] = 0;
f010308b:	c6 86 60 85 11 f0 00 	movb   $0x0,-0xfee7aa0(%esi)
			return buf;
f0103092:	b8 60 85 11 f0       	mov    $0xf0118560,%eax
f0103097:	eb bf                	jmp    f0103058 <readline+0x4d>
				cputchar('\n');
f0103099:	83 ec 0c             	sub    $0xc,%esp
f010309c:	6a 0a                	push   $0xa
f010309e:	e8 23 d5 ff ff       	call   f01005c6 <cputchar>
f01030a3:	83 c4 10             	add    $0x10,%esp
f01030a6:	eb e3                	jmp    f010308b <readline+0x80>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f01030a8:	85 f6                	test   %esi,%esi
f01030aa:	7f 06                	jg     f01030b2 <readline+0xa7>
f01030ac:	eb 23                	jmp    f01030d1 <readline+0xc6>
f01030ae:	85 f6                	test   %esi,%esi
f01030b0:	7e 05                	jle    f01030b7 <readline+0xac>
			if (echoing)
f01030b2:	85 ff                	test   %edi,%edi
f01030b4:	75 aa                	jne    f0103060 <readline+0x55>
			i--;
f01030b6:	4e                   	dec    %esi
		c = getchar();
f01030b7:	e8 1a d5 ff ff       	call   f01005d6 <getchar>
f01030bc:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f01030be:	85 c0                	test   %eax,%eax
f01030c0:	78 80                	js     f0103042 <readline+0x37>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f01030c2:	83 f8 08             	cmp    $0x8,%eax
f01030c5:	74 e7                	je     f01030ae <readline+0xa3>
f01030c7:	83 f8 7f             	cmp    $0x7f,%eax
f01030ca:	74 dc                	je     f01030a8 <readline+0x9d>
		} else if (c >= ' ' && i < BUFLEN-1) {
f01030cc:	83 f8 1f             	cmp    $0x1f,%eax
f01030cf:	7e ac                	jle    f010307d <readline+0x72>
f01030d1:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f01030d7:	7f de                	jg     f01030b7 <readline+0xac>
			if (echoing)
f01030d9:	85 ff                	test   %edi,%edi
f01030db:	75 92                	jne    f010306f <readline+0x64>
			buf[i++] = c;
f01030dd:	88 9e 60 85 11 f0    	mov    %bl,-0xfee7aa0(%esi)
f01030e3:	8d 76 01             	lea    0x1(%esi),%esi
f01030e6:	eb cf                	jmp    f01030b7 <readline+0xac>

f01030e8 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f01030e8:	55                   	push   %ebp
f01030e9:	89 e5                	mov    %esp,%ebp
f01030eb:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f01030ee:	b8 00 00 00 00       	mov    $0x0,%eax
f01030f3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f01030f7:	74 03                	je     f01030fc <strlen+0x14>
		n++;
f01030f9:	40                   	inc    %eax
f01030fa:	eb f7                	jmp    f01030f3 <strlen+0xb>
	return n;
}
f01030fc:	5d                   	pop    %ebp
f01030fd:	c3                   	ret    

f01030fe <strnlen>:

int
strnlen(const char *s, size_t size)
{
f01030fe:	55                   	push   %ebp
f01030ff:	89 e5                	mov    %esp,%ebp
f0103101:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0103104:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0103107:	b8 00 00 00 00       	mov    $0x0,%eax
f010310c:	39 d0                	cmp    %edx,%eax
f010310e:	74 0b                	je     f010311b <strnlen+0x1d>
f0103110:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f0103114:	74 03                	je     f0103119 <strnlen+0x1b>
		n++;
f0103116:	40                   	inc    %eax
f0103117:	eb f3                	jmp    f010310c <strnlen+0xe>
f0103119:	89 c2                	mov    %eax,%edx
	return n;
}
f010311b:	89 d0                	mov    %edx,%eax
f010311d:	5d                   	pop    %ebp
f010311e:	c3                   	ret    

f010311f <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f010311f:	55                   	push   %ebp
f0103120:	89 e5                	mov    %esp,%ebp
f0103122:	53                   	push   %ebx
f0103123:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0103126:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0103129:	b8 00 00 00 00       	mov    $0x0,%eax
f010312e:	8a 14 03             	mov    (%ebx,%eax,1),%dl
f0103131:	88 14 01             	mov    %dl,(%ecx,%eax,1)
f0103134:	40                   	inc    %eax
f0103135:	84 d2                	test   %dl,%dl
f0103137:	75 f5                	jne    f010312e <strcpy+0xf>
		/* do nothing */;
	return ret;
}
f0103139:	89 c8                	mov    %ecx,%eax
f010313b:	5b                   	pop    %ebx
f010313c:	5d                   	pop    %ebp
f010313d:	c3                   	ret    

f010313e <strcat>:

char *
strcat(char *dst, const char *src)
{
f010313e:	55                   	push   %ebp
f010313f:	89 e5                	mov    %esp,%ebp
f0103141:	53                   	push   %ebx
f0103142:	83 ec 10             	sub    $0x10,%esp
f0103145:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0103148:	53                   	push   %ebx
f0103149:	e8 9a ff ff ff       	call   f01030e8 <strlen>
f010314e:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
f0103151:	ff 75 0c             	pushl  0xc(%ebp)
f0103154:	01 d8                	add    %ebx,%eax
f0103156:	50                   	push   %eax
f0103157:	e8 c3 ff ff ff       	call   f010311f <strcpy>
	return dst;
}
f010315c:	89 d8                	mov    %ebx,%eax
f010315e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103161:	c9                   	leave  
f0103162:	c3                   	ret    

f0103163 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0103163:	55                   	push   %ebp
f0103164:	89 e5                	mov    %esp,%ebp
f0103166:	53                   	push   %ebx
f0103167:	8b 55 0c             	mov    0xc(%ebp),%edx
f010316a:	8b 5d 08             	mov    0x8(%ebp),%ebx
f010316d:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0103170:	8b 45 08             	mov    0x8(%ebp),%eax
f0103173:	39 d8                	cmp    %ebx,%eax
f0103175:	74 0e                	je     f0103185 <strncpy+0x22>
		*dst++ = *src;
f0103177:	40                   	inc    %eax
f0103178:	8a 0a                	mov    (%edx),%cl
f010317a:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f010317d:	80 f9 01             	cmp    $0x1,%cl
f0103180:	83 da ff             	sbb    $0xffffffff,%edx
f0103183:	eb ee                	jmp    f0103173 <strncpy+0x10>
	}
	return ret;
}
f0103185:	8b 45 08             	mov    0x8(%ebp),%eax
f0103188:	5b                   	pop    %ebx
f0103189:	5d                   	pop    %ebp
f010318a:	c3                   	ret    

f010318b <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f010318b:	55                   	push   %ebp
f010318c:	89 e5                	mov    %esp,%ebp
f010318e:	56                   	push   %esi
f010318f:	53                   	push   %ebx
f0103190:	8b 75 08             	mov    0x8(%ebp),%esi
f0103193:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0103196:	8b 45 10             	mov    0x10(%ebp),%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0103199:	85 c0                	test   %eax,%eax
f010319b:	74 22                	je     f01031bf <strlcpy+0x34>
f010319d:	8d 44 06 ff          	lea    -0x1(%esi,%eax,1),%eax
f01031a1:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
f01031a3:	39 c2                	cmp    %eax,%edx
f01031a5:	74 0f                	je     f01031b6 <strlcpy+0x2b>
f01031a7:	8a 19                	mov    (%ecx),%bl
f01031a9:	84 db                	test   %bl,%bl
f01031ab:	74 07                	je     f01031b4 <strlcpy+0x29>
			*dst++ = *src++;
f01031ad:	41                   	inc    %ecx
f01031ae:	42                   	inc    %edx
f01031af:	88 5a ff             	mov    %bl,-0x1(%edx)
f01031b2:	eb ef                	jmp    f01031a3 <strlcpy+0x18>
f01031b4:	89 d0                	mov    %edx,%eax
		*dst = '\0';
f01031b6:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f01031b9:	29 f0                	sub    %esi,%eax
}
f01031bb:	5b                   	pop    %ebx
f01031bc:	5e                   	pop    %esi
f01031bd:	5d                   	pop    %ebp
f01031be:	c3                   	ret    
f01031bf:	89 f0                	mov    %esi,%eax
f01031c1:	eb f6                	jmp    f01031b9 <strlcpy+0x2e>

f01031c3 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f01031c3:	55                   	push   %ebp
f01031c4:	89 e5                	mov    %esp,%ebp
f01031c6:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01031c9:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f01031cc:	8a 01                	mov    (%ecx),%al
f01031ce:	84 c0                	test   %al,%al
f01031d0:	74 08                	je     f01031da <strcmp+0x17>
f01031d2:	3a 02                	cmp    (%edx),%al
f01031d4:	75 04                	jne    f01031da <strcmp+0x17>
		p++, q++;
f01031d6:	41                   	inc    %ecx
f01031d7:	42                   	inc    %edx
f01031d8:	eb f2                	jmp    f01031cc <strcmp+0x9>
	return (int) ((unsigned char) *p - (unsigned char) *q);
f01031da:	0f b6 c0             	movzbl %al,%eax
f01031dd:	0f b6 12             	movzbl (%edx),%edx
f01031e0:	29 d0                	sub    %edx,%eax
}
f01031e2:	5d                   	pop    %ebp
f01031e3:	c3                   	ret    

f01031e4 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f01031e4:	55                   	push   %ebp
f01031e5:	89 e5                	mov    %esp,%ebp
f01031e7:	53                   	push   %ebx
f01031e8:	8b 45 08             	mov    0x8(%ebp),%eax
f01031eb:	8b 55 0c             	mov    0xc(%ebp),%edx
f01031ee:	89 c3                	mov    %eax,%ebx
f01031f0:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f01031f3:	eb 02                	jmp    f01031f7 <strncmp+0x13>
		n--, p++, q++;
f01031f5:	40                   	inc    %eax
f01031f6:	42                   	inc    %edx
	while (n > 0 && *p && *p == *q)
f01031f7:	39 d8                	cmp    %ebx,%eax
f01031f9:	74 15                	je     f0103210 <strncmp+0x2c>
f01031fb:	8a 08                	mov    (%eax),%cl
f01031fd:	84 c9                	test   %cl,%cl
f01031ff:	74 04                	je     f0103205 <strncmp+0x21>
f0103201:	3a 0a                	cmp    (%edx),%cl
f0103203:	74 f0                	je     f01031f5 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0103205:	0f b6 00             	movzbl (%eax),%eax
f0103208:	0f b6 12             	movzbl (%edx),%edx
f010320b:	29 d0                	sub    %edx,%eax
}
f010320d:	5b                   	pop    %ebx
f010320e:	5d                   	pop    %ebp
f010320f:	c3                   	ret    
		return 0;
f0103210:	b8 00 00 00 00       	mov    $0x0,%eax
f0103215:	eb f6                	jmp    f010320d <strncmp+0x29>

f0103217 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0103217:	55                   	push   %ebp
f0103218:	89 e5                	mov    %esp,%ebp
f010321a:	8b 45 08             	mov    0x8(%ebp),%eax
f010321d:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
f0103220:	8a 10                	mov    (%eax),%dl
f0103222:	84 d2                	test   %dl,%dl
f0103224:	74 07                	je     f010322d <strchr+0x16>
		if (*s == c)
f0103226:	38 ca                	cmp    %cl,%dl
f0103228:	74 08                	je     f0103232 <strchr+0x1b>
	for (; *s; s++)
f010322a:	40                   	inc    %eax
f010322b:	eb f3                	jmp    f0103220 <strchr+0x9>
			return (char *) s;
	return 0;
f010322d:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103232:	5d                   	pop    %ebp
f0103233:	c3                   	ret    

f0103234 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0103234:	55                   	push   %ebp
f0103235:	89 e5                	mov    %esp,%ebp
f0103237:	8b 45 08             	mov    0x8(%ebp),%eax
f010323a:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
f010323d:	8a 10                	mov    (%eax),%dl
f010323f:	84 d2                	test   %dl,%dl
f0103241:	74 07                	je     f010324a <strfind+0x16>
		if (*s == c)
f0103243:	38 ca                	cmp    %cl,%dl
f0103245:	74 03                	je     f010324a <strfind+0x16>
	for (; *s; s++)
f0103247:	40                   	inc    %eax
f0103248:	eb f3                	jmp    f010323d <strfind+0x9>
			break;
	return (char *) s;
}
f010324a:	5d                   	pop    %ebp
f010324b:	c3                   	ret    

f010324c <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f010324c:	55                   	push   %ebp
f010324d:	89 e5                	mov    %esp,%ebp
f010324f:	57                   	push   %edi
f0103250:	56                   	push   %esi
f0103251:	53                   	push   %ebx
f0103252:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0103255:	85 c9                	test   %ecx,%ecx
f0103257:	74 36                	je     f010328f <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0103259:	89 c8                	mov    %ecx,%eax
f010325b:	0b 45 08             	or     0x8(%ebp),%eax
f010325e:	a8 03                	test   $0x3,%al
f0103260:	75 24                	jne    f0103286 <memset+0x3a>
		c &= 0xFF;
f0103262:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0103266:	89 d3                	mov    %edx,%ebx
f0103268:	c1 e3 08             	shl    $0x8,%ebx
f010326b:	89 d0                	mov    %edx,%eax
f010326d:	c1 e0 18             	shl    $0x18,%eax
f0103270:	89 d6                	mov    %edx,%esi
f0103272:	c1 e6 10             	shl    $0x10,%esi
f0103275:	09 f0                	or     %esi,%eax
f0103277:	09 d0                	or     %edx,%eax
f0103279:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f010327b:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
f010327e:	8b 7d 08             	mov    0x8(%ebp),%edi
f0103281:	fc                   	cld    
f0103282:	f3 ab                	rep stos %eax,%es:(%edi)
f0103284:	eb 09                	jmp    f010328f <memset+0x43>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0103286:	8b 7d 08             	mov    0x8(%ebp),%edi
f0103289:	8b 45 0c             	mov    0xc(%ebp),%eax
f010328c:	fc                   	cld    
f010328d:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f010328f:	8b 45 08             	mov    0x8(%ebp),%eax
f0103292:	5b                   	pop    %ebx
f0103293:	5e                   	pop    %esi
f0103294:	5f                   	pop    %edi
f0103295:	5d                   	pop    %ebp
f0103296:	c3                   	ret    

f0103297 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0103297:	55                   	push   %ebp
f0103298:	89 e5                	mov    %esp,%ebp
f010329a:	57                   	push   %edi
f010329b:	56                   	push   %esi
f010329c:	8b 45 08             	mov    0x8(%ebp),%eax
f010329f:	8b 75 0c             	mov    0xc(%ebp),%esi
f01032a2:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f01032a5:	39 c6                	cmp    %eax,%esi
f01032a7:	73 30                	jae    f01032d9 <memmove+0x42>
f01032a9:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f01032ac:	39 c2                	cmp    %eax,%edx
f01032ae:	76 29                	jbe    f01032d9 <memmove+0x42>
		s += n;
		d += n;
f01032b0:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01032b3:	89 fe                	mov    %edi,%esi
f01032b5:	09 ce                	or     %ecx,%esi
f01032b7:	09 d6                	or     %edx,%esi
f01032b9:	f7 c6 03 00 00 00    	test   $0x3,%esi
f01032bf:	75 0e                	jne    f01032cf <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f01032c1:	83 ef 04             	sub    $0x4,%edi
f01032c4:	8d 72 fc             	lea    -0x4(%edx),%esi
f01032c7:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
f01032ca:	fd                   	std    
f01032cb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01032cd:	eb 07                	jmp    f01032d6 <memmove+0x3f>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f01032cf:	4f                   	dec    %edi
f01032d0:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
f01032d3:	fd                   	std    
f01032d4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f01032d6:	fc                   	cld    
f01032d7:	eb 1a                	jmp    f01032f3 <memmove+0x5c>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01032d9:	89 c2                	mov    %eax,%edx
f01032db:	09 ca                	or     %ecx,%edx
f01032dd:	09 f2                	or     %esi,%edx
f01032df:	f6 c2 03             	test   $0x3,%dl
f01032e2:	75 0a                	jne    f01032ee <memmove+0x57>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f01032e4:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
f01032e7:	89 c7                	mov    %eax,%edi
f01032e9:	fc                   	cld    
f01032ea:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01032ec:	eb 05                	jmp    f01032f3 <memmove+0x5c>
		else
			asm volatile("cld; rep movsb\n"
f01032ee:	89 c7                	mov    %eax,%edi
f01032f0:	fc                   	cld    
f01032f1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f01032f3:	5e                   	pop    %esi
f01032f4:	5f                   	pop    %edi
f01032f5:	5d                   	pop    %ebp
f01032f6:	c3                   	ret    

f01032f7 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f01032f7:	55                   	push   %ebp
f01032f8:	89 e5                	mov    %esp,%ebp
f01032fa:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f01032fd:	ff 75 10             	pushl  0x10(%ebp)
f0103300:	ff 75 0c             	pushl  0xc(%ebp)
f0103303:	ff 75 08             	pushl  0x8(%ebp)
f0103306:	e8 8c ff ff ff       	call   f0103297 <memmove>
}
f010330b:	c9                   	leave  
f010330c:	c3                   	ret    

f010330d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f010330d:	55                   	push   %ebp
f010330e:	89 e5                	mov    %esp,%ebp
f0103310:	56                   	push   %esi
f0103311:	53                   	push   %ebx
f0103312:	8b 45 08             	mov    0x8(%ebp),%eax
f0103315:	8b 55 0c             	mov    0xc(%ebp),%edx
f0103318:	89 c6                	mov    %eax,%esi
f010331a:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f010331d:	39 f0                	cmp    %esi,%eax
f010331f:	74 16                	je     f0103337 <memcmp+0x2a>
		if (*s1 != *s2)
f0103321:	8a 08                	mov    (%eax),%cl
f0103323:	8a 1a                	mov    (%edx),%bl
f0103325:	38 d9                	cmp    %bl,%cl
f0103327:	75 04                	jne    f010332d <memcmp+0x20>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
f0103329:	40                   	inc    %eax
f010332a:	42                   	inc    %edx
f010332b:	eb f0                	jmp    f010331d <memcmp+0x10>
			return (int) *s1 - (int) *s2;
f010332d:	0f b6 c1             	movzbl %cl,%eax
f0103330:	0f b6 db             	movzbl %bl,%ebx
f0103333:	29 d8                	sub    %ebx,%eax
f0103335:	eb 05                	jmp    f010333c <memcmp+0x2f>
	}

	return 0;
f0103337:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010333c:	5b                   	pop    %ebx
f010333d:	5e                   	pop    %esi
f010333e:	5d                   	pop    %ebp
f010333f:	c3                   	ret    

f0103340 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0103340:	55                   	push   %ebp
f0103341:	89 e5                	mov    %esp,%ebp
f0103343:	8b 45 08             	mov    0x8(%ebp),%eax
f0103346:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f0103349:	89 c2                	mov    %eax,%edx
f010334b:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f010334e:	39 d0                	cmp    %edx,%eax
f0103350:	73 07                	jae    f0103359 <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
f0103352:	38 08                	cmp    %cl,(%eax)
f0103354:	74 03                	je     f0103359 <memfind+0x19>
	for (; s < ends; s++)
f0103356:	40                   	inc    %eax
f0103357:	eb f5                	jmp    f010334e <memfind+0xe>
			break;
	return (void *) s;
}
f0103359:	5d                   	pop    %ebp
f010335a:	c3                   	ret    

f010335b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f010335b:	55                   	push   %ebp
f010335c:	89 e5                	mov    %esp,%ebp
f010335e:	57                   	push   %edi
f010335f:	56                   	push   %esi
f0103360:	53                   	push   %ebx
f0103361:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0103364:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0103367:	eb 01                	jmp    f010336a <strtol+0xf>
		s++;
f0103369:	41                   	inc    %ecx
	while (*s == ' ' || *s == '\t')
f010336a:	8a 01                	mov    (%ecx),%al
f010336c:	3c 20                	cmp    $0x20,%al
f010336e:	74 f9                	je     f0103369 <strtol+0xe>
f0103370:	3c 09                	cmp    $0x9,%al
f0103372:	74 f5                	je     f0103369 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
f0103374:	3c 2b                	cmp    $0x2b,%al
f0103376:	74 24                	je     f010339c <strtol+0x41>
		s++;
	else if (*s == '-')
f0103378:	3c 2d                	cmp    $0x2d,%al
f010337a:	74 28                	je     f01033a4 <strtol+0x49>
	int neg = 0;
f010337c:	bf 00 00 00 00       	mov    $0x0,%edi
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0103381:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f0103387:	75 09                	jne    f0103392 <strtol+0x37>
f0103389:	80 39 30             	cmpb   $0x30,(%ecx)
f010338c:	74 1e                	je     f01033ac <strtol+0x51>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f010338e:	85 db                	test   %ebx,%ebx
f0103390:	74 36                	je     f01033c8 <strtol+0x6d>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0103392:	b8 00 00 00 00       	mov    $0x0,%eax
f0103397:	89 5d 10             	mov    %ebx,0x10(%ebp)
f010339a:	eb 45                	jmp    f01033e1 <strtol+0x86>
		s++;
f010339c:	41                   	inc    %ecx
	int neg = 0;
f010339d:	bf 00 00 00 00       	mov    $0x0,%edi
f01033a2:	eb dd                	jmp    f0103381 <strtol+0x26>
		s++, neg = 1;
f01033a4:	41                   	inc    %ecx
f01033a5:	bf 01 00 00 00       	mov    $0x1,%edi
f01033aa:	eb d5                	jmp    f0103381 <strtol+0x26>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f01033ac:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f01033b0:	74 0c                	je     f01033be <strtol+0x63>
	else if (base == 0 && s[0] == '0')
f01033b2:	85 db                	test   %ebx,%ebx
f01033b4:	75 dc                	jne    f0103392 <strtol+0x37>
		s++, base = 8;
f01033b6:	41                   	inc    %ecx
f01033b7:	bb 08 00 00 00       	mov    $0x8,%ebx
f01033bc:	eb d4                	jmp    f0103392 <strtol+0x37>
		s += 2, base = 16;
f01033be:	83 c1 02             	add    $0x2,%ecx
f01033c1:	bb 10 00 00 00       	mov    $0x10,%ebx
f01033c6:	eb ca                	jmp    f0103392 <strtol+0x37>
		base = 10;
f01033c8:	bb 0a 00 00 00       	mov    $0xa,%ebx
f01033cd:	eb c3                	jmp    f0103392 <strtol+0x37>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
f01033cf:	0f be d2             	movsbl %dl,%edx
f01033d2:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f01033d5:	3b 55 10             	cmp    0x10(%ebp),%edx
f01033d8:	7d 37                	jge    f0103411 <strtol+0xb6>
			break;
		s++, val = (val * base) + dig;
f01033da:	41                   	inc    %ecx
f01033db:	0f af 45 10          	imul   0x10(%ebp),%eax
f01033df:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
f01033e1:	8a 11                	mov    (%ecx),%dl
f01033e3:	8d 72 d0             	lea    -0x30(%edx),%esi
f01033e6:	89 f3                	mov    %esi,%ebx
f01033e8:	80 fb 09             	cmp    $0x9,%bl
f01033eb:	76 e2                	jbe    f01033cf <strtol+0x74>
		else if (*s >= 'a' && *s <= 'z')
f01033ed:	8d 72 9f             	lea    -0x61(%edx),%esi
f01033f0:	89 f3                	mov    %esi,%ebx
f01033f2:	80 fb 19             	cmp    $0x19,%bl
f01033f5:	77 08                	ja     f01033ff <strtol+0xa4>
			dig = *s - 'a' + 10;
f01033f7:	0f be d2             	movsbl %dl,%edx
f01033fa:	83 ea 57             	sub    $0x57,%edx
f01033fd:	eb d6                	jmp    f01033d5 <strtol+0x7a>
		else if (*s >= 'A' && *s <= 'Z')
f01033ff:	8d 72 bf             	lea    -0x41(%edx),%esi
f0103402:	89 f3                	mov    %esi,%ebx
f0103404:	80 fb 19             	cmp    $0x19,%bl
f0103407:	77 08                	ja     f0103411 <strtol+0xb6>
			dig = *s - 'A' + 10;
f0103409:	0f be d2             	movsbl %dl,%edx
f010340c:	83 ea 37             	sub    $0x37,%edx
f010340f:	eb c4                	jmp    f01033d5 <strtol+0x7a>
		// we don't properly detect overflow!
	}

	if (endptr)
f0103411:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0103415:	74 05                	je     f010341c <strtol+0xc1>
		*endptr = (char *) s;
f0103417:	8b 75 0c             	mov    0xc(%ebp),%esi
f010341a:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
f010341c:	85 ff                	test   %edi,%edi
f010341e:	74 02                	je     f0103422 <strtol+0xc7>
f0103420:	f7 d8                	neg    %eax
}
f0103422:	5b                   	pop    %ebx
f0103423:	5e                   	pop    %esi
f0103424:	5f                   	pop    %edi
f0103425:	5d                   	pop    %ebp
f0103426:	c3                   	ret    
f0103427:	90                   	nop

f0103428 <__udivdi3>:
f0103428:	55                   	push   %ebp
f0103429:	57                   	push   %edi
f010342a:	56                   	push   %esi
f010342b:	53                   	push   %ebx
f010342c:	83 ec 1c             	sub    $0x1c,%esp
f010342f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
f0103433:	8b 74 24 34          	mov    0x34(%esp),%esi
f0103437:	8b 7c 24 38          	mov    0x38(%esp),%edi
f010343b:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f010343f:	85 d2                	test   %edx,%edx
f0103441:	75 19                	jne    f010345c <__udivdi3+0x34>
f0103443:	39 f7                	cmp    %esi,%edi
f0103445:	76 45                	jbe    f010348c <__udivdi3+0x64>
f0103447:	89 e8                	mov    %ebp,%eax
f0103449:	89 f2                	mov    %esi,%edx
f010344b:	f7 f7                	div    %edi
f010344d:	31 db                	xor    %ebx,%ebx
f010344f:	89 da                	mov    %ebx,%edx
f0103451:	83 c4 1c             	add    $0x1c,%esp
f0103454:	5b                   	pop    %ebx
f0103455:	5e                   	pop    %esi
f0103456:	5f                   	pop    %edi
f0103457:	5d                   	pop    %ebp
f0103458:	c3                   	ret    
f0103459:	8d 76 00             	lea    0x0(%esi),%esi
f010345c:	39 f2                	cmp    %esi,%edx
f010345e:	76 10                	jbe    f0103470 <__udivdi3+0x48>
f0103460:	31 db                	xor    %ebx,%ebx
f0103462:	31 c0                	xor    %eax,%eax
f0103464:	89 da                	mov    %ebx,%edx
f0103466:	83 c4 1c             	add    $0x1c,%esp
f0103469:	5b                   	pop    %ebx
f010346a:	5e                   	pop    %esi
f010346b:	5f                   	pop    %edi
f010346c:	5d                   	pop    %ebp
f010346d:	c3                   	ret    
f010346e:	66 90                	xchg   %ax,%ax
f0103470:	0f bd da             	bsr    %edx,%ebx
f0103473:	83 f3 1f             	xor    $0x1f,%ebx
f0103476:	75 3c                	jne    f01034b4 <__udivdi3+0x8c>
f0103478:	39 f2                	cmp    %esi,%edx
f010347a:	72 08                	jb     f0103484 <__udivdi3+0x5c>
f010347c:	39 ef                	cmp    %ebp,%edi
f010347e:	0f 87 9c 00 00 00    	ja     f0103520 <__udivdi3+0xf8>
f0103484:	b8 01 00 00 00       	mov    $0x1,%eax
f0103489:	eb d9                	jmp    f0103464 <__udivdi3+0x3c>
f010348b:	90                   	nop
f010348c:	89 f9                	mov    %edi,%ecx
f010348e:	85 ff                	test   %edi,%edi
f0103490:	75 0b                	jne    f010349d <__udivdi3+0x75>
f0103492:	b8 01 00 00 00       	mov    $0x1,%eax
f0103497:	31 d2                	xor    %edx,%edx
f0103499:	f7 f7                	div    %edi
f010349b:	89 c1                	mov    %eax,%ecx
f010349d:	31 d2                	xor    %edx,%edx
f010349f:	89 f0                	mov    %esi,%eax
f01034a1:	f7 f1                	div    %ecx
f01034a3:	89 c3                	mov    %eax,%ebx
f01034a5:	89 e8                	mov    %ebp,%eax
f01034a7:	f7 f1                	div    %ecx
f01034a9:	89 da                	mov    %ebx,%edx
f01034ab:	83 c4 1c             	add    $0x1c,%esp
f01034ae:	5b                   	pop    %ebx
f01034af:	5e                   	pop    %esi
f01034b0:	5f                   	pop    %edi
f01034b1:	5d                   	pop    %ebp
f01034b2:	c3                   	ret    
f01034b3:	90                   	nop
f01034b4:	b8 20 00 00 00       	mov    $0x20,%eax
f01034b9:	29 d8                	sub    %ebx,%eax
f01034bb:	88 d9                	mov    %bl,%cl
f01034bd:	d3 e2                	shl    %cl,%edx
f01034bf:	89 54 24 08          	mov    %edx,0x8(%esp)
f01034c3:	89 fa                	mov    %edi,%edx
f01034c5:	88 c1                	mov    %al,%cl
f01034c7:	d3 ea                	shr    %cl,%edx
f01034c9:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f01034cd:	09 d1                	or     %edx,%ecx
f01034cf:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01034d3:	88 d9                	mov    %bl,%cl
f01034d5:	d3 e7                	shl    %cl,%edi
f01034d7:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f01034db:	89 f7                	mov    %esi,%edi
f01034dd:	88 c1                	mov    %al,%cl
f01034df:	d3 ef                	shr    %cl,%edi
f01034e1:	88 d9                	mov    %bl,%cl
f01034e3:	d3 e6                	shl    %cl,%esi
f01034e5:	89 ea                	mov    %ebp,%edx
f01034e7:	88 c1                	mov    %al,%cl
f01034e9:	d3 ea                	shr    %cl,%edx
f01034eb:	09 d6                	or     %edx,%esi
f01034ed:	89 f0                	mov    %esi,%eax
f01034ef:	89 fa                	mov    %edi,%edx
f01034f1:	f7 74 24 08          	divl   0x8(%esp)
f01034f5:	89 d7                	mov    %edx,%edi
f01034f7:	89 c6                	mov    %eax,%esi
f01034f9:	f7 64 24 0c          	mull   0xc(%esp)
f01034fd:	39 d7                	cmp    %edx,%edi
f01034ff:	72 13                	jb     f0103514 <__udivdi3+0xec>
f0103501:	74 09                	je     f010350c <__udivdi3+0xe4>
f0103503:	89 f0                	mov    %esi,%eax
f0103505:	31 db                	xor    %ebx,%ebx
f0103507:	e9 58 ff ff ff       	jmp    f0103464 <__udivdi3+0x3c>
f010350c:	88 d9                	mov    %bl,%cl
f010350e:	d3 e5                	shl    %cl,%ebp
f0103510:	39 c5                	cmp    %eax,%ebp
f0103512:	73 ef                	jae    f0103503 <__udivdi3+0xdb>
f0103514:	8d 46 ff             	lea    -0x1(%esi),%eax
f0103517:	31 db                	xor    %ebx,%ebx
f0103519:	e9 46 ff ff ff       	jmp    f0103464 <__udivdi3+0x3c>
f010351e:	66 90                	xchg   %ax,%ax
f0103520:	31 c0                	xor    %eax,%eax
f0103522:	e9 3d ff ff ff       	jmp    f0103464 <__udivdi3+0x3c>
f0103527:	90                   	nop

f0103528 <__umoddi3>:
f0103528:	55                   	push   %ebp
f0103529:	57                   	push   %edi
f010352a:	56                   	push   %esi
f010352b:	53                   	push   %ebx
f010352c:	83 ec 1c             	sub    $0x1c,%esp
f010352f:	8b 74 24 30          	mov    0x30(%esp),%esi
f0103533:	8b 5c 24 34          	mov    0x34(%esp),%ebx
f0103537:	8b 7c 24 38          	mov    0x38(%esp),%edi
f010353b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
f010353f:	85 c0                	test   %eax,%eax
f0103541:	75 19                	jne    f010355c <__umoddi3+0x34>
f0103543:	39 df                	cmp    %ebx,%edi
f0103545:	76 51                	jbe    f0103598 <__umoddi3+0x70>
f0103547:	89 f0                	mov    %esi,%eax
f0103549:	89 da                	mov    %ebx,%edx
f010354b:	f7 f7                	div    %edi
f010354d:	89 d0                	mov    %edx,%eax
f010354f:	31 d2                	xor    %edx,%edx
f0103551:	83 c4 1c             	add    $0x1c,%esp
f0103554:	5b                   	pop    %ebx
f0103555:	5e                   	pop    %esi
f0103556:	5f                   	pop    %edi
f0103557:	5d                   	pop    %ebp
f0103558:	c3                   	ret    
f0103559:	8d 76 00             	lea    0x0(%esi),%esi
f010355c:	89 f2                	mov    %esi,%edx
f010355e:	39 d8                	cmp    %ebx,%eax
f0103560:	76 0e                	jbe    f0103570 <__umoddi3+0x48>
f0103562:	89 f0                	mov    %esi,%eax
f0103564:	89 da                	mov    %ebx,%edx
f0103566:	83 c4 1c             	add    $0x1c,%esp
f0103569:	5b                   	pop    %ebx
f010356a:	5e                   	pop    %esi
f010356b:	5f                   	pop    %edi
f010356c:	5d                   	pop    %ebp
f010356d:	c3                   	ret    
f010356e:	66 90                	xchg   %ax,%ax
f0103570:	0f bd e8             	bsr    %eax,%ebp
f0103573:	83 f5 1f             	xor    $0x1f,%ebp
f0103576:	75 44                	jne    f01035bc <__umoddi3+0x94>
f0103578:	39 d8                	cmp    %ebx,%eax
f010357a:	72 06                	jb     f0103582 <__umoddi3+0x5a>
f010357c:	89 d9                	mov    %ebx,%ecx
f010357e:	39 f7                	cmp    %esi,%edi
f0103580:	77 08                	ja     f010358a <__umoddi3+0x62>
f0103582:	29 fe                	sub    %edi,%esi
f0103584:	19 c3                	sbb    %eax,%ebx
f0103586:	89 f2                	mov    %esi,%edx
f0103588:	89 d9                	mov    %ebx,%ecx
f010358a:	89 d0                	mov    %edx,%eax
f010358c:	89 ca                	mov    %ecx,%edx
f010358e:	83 c4 1c             	add    $0x1c,%esp
f0103591:	5b                   	pop    %ebx
f0103592:	5e                   	pop    %esi
f0103593:	5f                   	pop    %edi
f0103594:	5d                   	pop    %ebp
f0103595:	c3                   	ret    
f0103596:	66 90                	xchg   %ax,%ax
f0103598:	89 fd                	mov    %edi,%ebp
f010359a:	85 ff                	test   %edi,%edi
f010359c:	75 0b                	jne    f01035a9 <__umoddi3+0x81>
f010359e:	b8 01 00 00 00       	mov    $0x1,%eax
f01035a3:	31 d2                	xor    %edx,%edx
f01035a5:	f7 f7                	div    %edi
f01035a7:	89 c5                	mov    %eax,%ebp
f01035a9:	89 d8                	mov    %ebx,%eax
f01035ab:	31 d2                	xor    %edx,%edx
f01035ad:	f7 f5                	div    %ebp
f01035af:	89 f0                	mov    %esi,%eax
f01035b1:	f7 f5                	div    %ebp
f01035b3:	89 d0                	mov    %edx,%eax
f01035b5:	31 d2                	xor    %edx,%edx
f01035b7:	eb 98                	jmp    f0103551 <__umoddi3+0x29>
f01035b9:	8d 76 00             	lea    0x0(%esi),%esi
f01035bc:	ba 20 00 00 00       	mov    $0x20,%edx
f01035c1:	29 ea                	sub    %ebp,%edx
f01035c3:	89 e9                	mov    %ebp,%ecx
f01035c5:	d3 e0                	shl    %cl,%eax
f01035c7:	89 44 24 08          	mov    %eax,0x8(%esp)
f01035cb:	89 f8                	mov    %edi,%eax
f01035cd:	89 54 24 04          	mov    %edx,0x4(%esp)
f01035d1:	88 d1                	mov    %dl,%cl
f01035d3:	d3 e8                	shr    %cl,%eax
f01035d5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f01035d9:	09 c1                	or     %eax,%ecx
f01035db:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01035df:	89 e9                	mov    %ebp,%ecx
f01035e1:	d3 e7                	shl    %cl,%edi
f01035e3:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f01035e7:	89 d8                	mov    %ebx,%eax
f01035e9:	8b 54 24 04          	mov    0x4(%esp),%edx
f01035ed:	88 d1                	mov    %dl,%cl
f01035ef:	d3 e8                	shr    %cl,%eax
f01035f1:	89 c7                	mov    %eax,%edi
f01035f3:	89 e9                	mov    %ebp,%ecx
f01035f5:	d3 e3                	shl    %cl,%ebx
f01035f7:	89 f0                	mov    %esi,%eax
f01035f9:	88 d1                	mov    %dl,%cl
f01035fb:	d3 e8                	shr    %cl,%eax
f01035fd:	09 d8                	or     %ebx,%eax
f01035ff:	89 e9                	mov    %ebp,%ecx
f0103601:	d3 e6                	shl    %cl,%esi
f0103603:	89 f3                	mov    %esi,%ebx
f0103605:	89 fa                	mov    %edi,%edx
f0103607:	f7 74 24 08          	divl   0x8(%esp)
f010360b:	89 d1                	mov    %edx,%ecx
f010360d:	f7 64 24 0c          	mull   0xc(%esp)
f0103611:	89 c6                	mov    %eax,%esi
f0103613:	89 d7                	mov    %edx,%edi
f0103615:	39 d1                	cmp    %edx,%ecx
f0103617:	72 27                	jb     f0103640 <__umoddi3+0x118>
f0103619:	74 21                	je     f010363c <__umoddi3+0x114>
f010361b:	89 ca                	mov    %ecx,%edx
f010361d:	29 f3                	sub    %esi,%ebx
f010361f:	19 fa                	sbb    %edi,%edx
f0103621:	89 d0                	mov    %edx,%eax
f0103623:	8a 4c 24 04          	mov    0x4(%esp),%cl
f0103627:	d3 e0                	shl    %cl,%eax
f0103629:	89 e9                	mov    %ebp,%ecx
f010362b:	d3 eb                	shr    %cl,%ebx
f010362d:	09 d8                	or     %ebx,%eax
f010362f:	d3 ea                	shr    %cl,%edx
f0103631:	83 c4 1c             	add    $0x1c,%esp
f0103634:	5b                   	pop    %ebx
f0103635:	5e                   	pop    %esi
f0103636:	5f                   	pop    %edi
f0103637:	5d                   	pop    %ebp
f0103638:	c3                   	ret    
f0103639:	8d 76 00             	lea    0x0(%esi),%esi
f010363c:	39 c3                	cmp    %eax,%ebx
f010363e:	73 db                	jae    f010361b <__umoddi3+0xf3>
f0103640:	2b 44 24 0c          	sub    0xc(%esp),%eax
f0103644:	1b 54 24 08          	sbb    0x8(%esp),%edx
f0103648:	89 d7                	mov    %edx,%edi
f010364a:	89 c6                	mov    %eax,%esi
f010364c:	eb cd                	jmp    f010361b <__umoddi3+0xf3>
