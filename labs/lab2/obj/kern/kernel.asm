
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
f0100058:	e8 06 31 00 00       	call   f0103163 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f010005d:	e8 6c 04 00 00       	call   f01004ce <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f0100062:	83 c4 08             	add    $0x8,%esp
f0100065:	68 ac 1a 00 00       	push   $0x1aac
f010006a:	68 80 35 10 f0       	push   $0xf0103580
f010006f:	e8 5f 26 00 00       	call   f01026d3 <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f0100074:	e8 66 0e 00 00       	call   f0100edf <mem_init>
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
f01000bf:	68 9b 35 10 f0       	push   $0xf010359b
f01000c4:	e8 0a 26 00 00       	call   f01026d3 <cprintf>
	vcprintf(fmt, ap);
f01000c9:	83 c4 08             	add    $0x8,%esp
f01000cc:	53                   	push   %ebx
f01000cd:	56                   	push   %esi
f01000ce:	e8 da 25 00 00       	call   f01026ad <vcprintf>
	cprintf("\n");
f01000d3:	c7 04 24 f3 3c 10 f0 	movl   $0xf0103cf3,(%esp)
f01000da:	e8 f4 25 00 00       	call   f01026d3 <cprintf>
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
f01000f4:	68 b3 35 10 f0       	push   $0xf01035b3
f01000f9:	e8 d5 25 00 00       	call   f01026d3 <cprintf>
	vcprintf(fmt, ap);
f01000fe:	83 c4 08             	add    $0x8,%esp
f0100101:	53                   	push   %ebx
f0100102:	ff 75 10             	pushl  0x10(%ebp)
f0100105:	e8 a3 25 00 00       	call   f01026ad <vcprintf>
	cprintf("\n");
f010010a:	c7 04 24 f3 3c 10 f0 	movl   $0xf0103cf3,(%esp)
f0100111:	e8 bd 25 00 00       	call   f01026d3 <cprintf>
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
f01001c4:	0f b6 82 20 37 10 f0 	movzbl -0xfefc8e0(%edx),%eax
f01001cb:	0b 05 00 83 11 f0    	or     0xf0118300,%eax
	shift ^= togglecode[data];
f01001d1:	0f b6 8a 20 36 10 f0 	movzbl -0xfefc9e0(%edx),%ecx
f01001d8:	31 c8                	xor    %ecx,%eax
f01001da:	a3 00 83 11 f0       	mov    %eax,0xf0118300
	c = charcode[shift & (CTL | SHIFT)][data];
f01001df:	89 c1                	mov    %eax,%ecx
f01001e1:	83 e1 03             	and    $0x3,%ecx
f01001e4:	8b 0c 8d 00 36 10 f0 	mov    -0xfefca00(,%ecx,4),%ecx
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
f010022a:	8a 82 20 37 10 f0    	mov    -0xfefc8e0(%edx),%al
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
f0100262:	68 cd 35 10 f0       	push   $0xf01035cd
f0100267:	e8 67 24 00 00       	call   f01026d3 <cprintf>
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
f0100425:	e8 84 2d 00 00       	call   f01031ae <memmove>
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
f01005b7:	68 d9 35 10 f0       	push   $0xf01035d9
f01005bc:	e8 12 21 00 00       	call   f01026d3 <cprintf>
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
f01005f3:	68 20 38 10 f0       	push   $0xf0103820
f01005f8:	68 3e 38 10 f0       	push   $0xf010383e
f01005fd:	68 43 38 10 f0       	push   $0xf0103843
f0100602:	e8 cc 20 00 00       	call   f01026d3 <cprintf>
f0100607:	83 c4 0c             	add    $0xc,%esp
f010060a:	68 ac 38 10 f0       	push   $0xf01038ac
f010060f:	68 4c 38 10 f0       	push   $0xf010384c
f0100614:	68 43 38 10 f0       	push   $0xf0103843
f0100619:	e8 b5 20 00 00       	call   f01026d3 <cprintf>
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
f010062b:	68 55 38 10 f0       	push   $0xf0103855
f0100630:	e8 9e 20 00 00       	call   f01026d3 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f0100635:	83 c4 08             	add    $0x8,%esp
f0100638:	68 0c 00 10 00       	push   $0x10000c
f010063d:	68 d4 38 10 f0       	push   $0xf01038d4
f0100642:	e8 8c 20 00 00       	call   f01026d3 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f0100647:	83 c4 0c             	add    $0xc,%esp
f010064a:	68 0c 00 10 00       	push   $0x10000c
f010064f:	68 0c 00 10 f0       	push   $0xf010000c
f0100654:	68 fc 38 10 f0       	push   $0xf01038fc
f0100659:	e8 75 20 00 00       	call   f01026d3 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f010065e:	83 c4 0c             	add    $0xc,%esp
f0100661:	68 66 35 10 00       	push   $0x103566
f0100666:	68 66 35 10 f0       	push   $0xf0103566
f010066b:	68 20 39 10 f0       	push   $0xf0103920
f0100670:	e8 5e 20 00 00       	call   f01026d3 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f0100675:	83 c4 0c             	add    $0xc,%esp
f0100678:	68 00 83 11 00       	push   $0x118300
f010067d:	68 00 83 11 f0       	push   $0xf0118300
f0100682:	68 44 39 10 f0       	push   $0xf0103944
f0100687:	e8 47 20 00 00       	call   f01026d3 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f010068c:	83 c4 0c             	add    $0xc,%esp
f010068f:	68 60 89 11 00       	push   $0x118960
f0100694:	68 60 89 11 f0       	push   $0xf0118960
f0100699:	68 68 39 10 f0       	push   $0xf0103968
f010069e:	e8 30 20 00 00       	call   f01026d3 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
f01006a3:	83 c4 08             	add    $0x8,%esp
		ROUNDUP(end - entry, 1024) / 1024);
f01006a6:	b8 60 89 11 f0       	mov    $0xf0118960,%eax
f01006ab:	2d 0d fc 0f f0       	sub    $0xf00ffc0d,%eax
	cprintf("Kernel executable memory footprint: %dKB\n",
f01006b0:	c1 f8 0a             	sar    $0xa,%eax
f01006b3:	50                   	push   %eax
f01006b4:	68 8c 39 10 f0       	push   $0xf010398c
f01006b9:	e8 15 20 00 00       	call   f01026d3 <cprintf>
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
f01006d4:	68 b8 39 10 f0       	push   $0xf01039b8
f01006d9:	e8 f5 1f 00 00       	call   f01026d3 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f01006de:	c7 04 24 dc 39 10 f0 	movl   $0xf01039dc,(%esp)
f01006e5:	e8 e9 1f 00 00       	call   f01026d3 <cprintf>
f01006ea:	83 c4 10             	add    $0x10,%esp
f01006ed:	e9 cb 00 00 00       	jmp    f01007bd <monitor+0xf2>
		while (*buf && strchr(WHITESPACE, *buf))
f01006f2:	83 ec 08             	sub    $0x8,%esp
f01006f5:	0f be c0             	movsbl %al,%eax
f01006f8:	50                   	push   %eax
f01006f9:	68 72 38 10 f0       	push   $0xf0103872
f01006fe:	e8 2b 2a 00 00       	call   f010312e <strchr>
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
f010072d:	68 3e 38 10 f0       	push   $0xf010383e
f0100732:	ff 75 a8             	pushl  -0x58(%ebp)
f0100735:	e8 a0 29 00 00       	call   f01030da <strcmp>
f010073a:	83 c4 10             	add    $0x10,%esp
f010073d:	85 c0                	test   %eax,%eax
f010073f:	0f 84 a4 00 00 00    	je     f01007e9 <monitor+0x11e>
f0100745:	83 ec 08             	sub    $0x8,%esp
f0100748:	68 4c 38 10 f0       	push   $0xf010384c
f010074d:	ff 75 a8             	pushl  -0x58(%ebp)
f0100750:	e8 85 29 00 00       	call   f01030da <strcmp>
f0100755:	83 c4 10             	add    $0x10,%esp
f0100758:	85 c0                	test   %eax,%eax
f010075a:	0f 84 84 00 00 00    	je     f01007e4 <monitor+0x119>
	cprintf("Unknown command '%s'\n", argv[0]);
f0100760:	83 ec 08             	sub    $0x8,%esp
f0100763:	ff 75 a8             	pushl  -0x58(%ebp)
f0100766:	68 94 38 10 f0       	push   $0xf0103894
f010076b:	e8 63 1f 00 00       	call   f01026d3 <cprintf>
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
f0100793:	68 72 38 10 f0       	push   $0xf0103872
f0100798:	e8 91 29 00 00       	call   f010312e <strchr>
f010079d:	83 c4 10             	add    $0x10,%esp
f01007a0:	85 c0                	test   %eax,%eax
f01007a2:	0f 85 6a ff ff ff    	jne    f0100712 <monitor+0x47>
			buf++;
f01007a8:	43                   	inc    %ebx
f01007a9:	eb db                	jmp    f0100786 <monitor+0xbb>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f01007ab:	83 ec 08             	sub    $0x8,%esp
f01007ae:	6a 10                	push   $0x10
f01007b0:	68 77 38 10 f0       	push   $0xf0103877
f01007b5:	e8 19 1f 00 00       	call   f01026d3 <cprintf>
			return 0;
f01007ba:	83 c4 10             	add    $0x10,%esp


	while (1) {
		buf = readline("K> ");
f01007bd:	83 ec 0c             	sub    $0xc,%esp
f01007c0:	68 6e 38 10 f0       	push   $0xf010386e
f01007c5:	e8 58 27 00 00       	call   f0102f22 <readline>
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
f01007f9:	ff 14 85 0c 3a 10 f0 	call   *-0xfefc5f4(,%eax,4)
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
f010081a:	e8 4d 1e 00 00       	call   f010266c <mc146818_read>
f010081f:	89 c6                	mov    %eax,%esi
f0100821:	43                   	inc    %ebx
f0100822:	89 1c 24             	mov    %ebx,(%esp)
f0100825:	e8 42 1e 00 00       	call   f010266c <mc146818_read>
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
f0100884:	68 1c 3a 10 f0       	push   $0xf0103a1c
f0100889:	6a 6f                	push   $0x6f
f010088b:	68 2b 3a 10 f0       	push   $0xf0103a2b
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
f01008d5:	68 28 3d 10 f0       	push   $0xf0103d28
f01008da:	68 f4 02 00 00       	push   $0x2f4
f01008df:	68 2b 3a 10 f0       	push   $0xf0103a2b
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
f010091f:	68 4c 3d 10 f0       	push   $0xf0103d4c
f0100924:	68 35 02 00 00       	push   $0x235
f0100929:	68 2b 3a 10 f0       	push   $0xf0103a2b
f010092e:	e8 58 f7 ff ff       	call   f010008b <_panic>
f0100933:	50                   	push   %eax
f0100934:	68 28 3d 10 f0       	push   $0xf0103d28
f0100939:	6a 52                	push   $0x52
f010093b:	68 37 3a 10 f0       	push   $0xf0103a37
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
f0100982:	e8 dc 27 00 00       	call   f0103163 <memset>
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
f01009bd:	68 45 3a 10 f0       	push   $0xf0103a45
f01009c2:	68 51 3a 10 f0       	push   $0xf0103a51
f01009c7:	68 4f 02 00 00       	push   $0x24f
f01009cc:	68 2b 3a 10 f0       	push   $0xf0103a2b
f01009d1:	e8 b5 f6 ff ff       	call   f010008b <_panic>
		assert(pp < pages + npages);
f01009d6:	68 66 3a 10 f0       	push   $0xf0103a66
f01009db:	68 51 3a 10 f0       	push   $0xf0103a51
f01009e0:	68 50 02 00 00       	push   $0x250
f01009e5:	68 2b 3a 10 f0       	push   $0xf0103a2b
f01009ea:	e8 9c f6 ff ff       	call   f010008b <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f01009ef:	68 70 3d 10 f0       	push   $0xf0103d70
f01009f4:	68 51 3a 10 f0       	push   $0xf0103a51
f01009f9:	68 51 02 00 00       	push   $0x251
f01009fe:	68 2b 3a 10 f0       	push   $0xf0103a2b
f0100a03:	e8 83 f6 ff ff       	call   f010008b <_panic>
		assert(page2pa(pp) != 0);
f0100a08:	68 7a 3a 10 f0       	push   $0xf0103a7a
f0100a0d:	68 51 3a 10 f0       	push   $0xf0103a51
f0100a12:	68 54 02 00 00       	push   $0x254
f0100a17:	68 2b 3a 10 f0       	push   $0xf0103a2b
f0100a1c:	e8 6a f6 ff ff       	call   f010008b <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100a21:	68 8b 3a 10 f0       	push   $0xf0103a8b
f0100a26:	68 51 3a 10 f0       	push   $0xf0103a51
f0100a2b:	68 55 02 00 00       	push   $0x255
f0100a30:	68 2b 3a 10 f0       	push   $0xf0103a2b
f0100a35:	e8 51 f6 ff ff       	call   f010008b <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100a3a:	68 a4 3d 10 f0       	push   $0xf0103da4
f0100a3f:	68 51 3a 10 f0       	push   $0xf0103a51
f0100a44:	68 56 02 00 00       	push   $0x256
f0100a49:	68 2b 3a 10 f0       	push   $0xf0103a2b
f0100a4e:	e8 38 f6 ff ff       	call   f010008b <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100a53:	68 a4 3a 10 f0       	push   $0xf0103aa4
f0100a58:	68 51 3a 10 f0       	push   $0xf0103a51
f0100a5d:	68 57 02 00 00       	push   $0x257
f0100a62:	68 2b 3a 10 f0       	push   $0xf0103a2b
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
f0100ad9:	68 28 3d 10 f0       	push   $0xf0103d28
f0100ade:	6a 52                	push   $0x52
f0100ae0:	68 37 3a 10 f0       	push   $0xf0103a37
f0100ae5:	e8 a1 f5 ff ff       	call   f010008b <_panic>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100aea:	68 c8 3d 10 f0       	push   $0xf0103dc8
f0100aef:	68 51 3a 10 f0       	push   $0xf0103a51
f0100af4:	68 58 02 00 00       	push   $0x258
f0100af9:	68 2b 3a 10 f0       	push   $0xf0103a2b
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
f0100b11:	68 10 3e 10 f0       	push   $0xf0103e10
f0100b16:	e8 b8 1b 00 00       	call   f01026d3 <cprintf>
}
f0100b1b:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100b1e:	5b                   	pop    %ebx
f0100b1f:	5e                   	pop    %esi
f0100b20:	5f                   	pop    %edi
f0100b21:	5d                   	pop    %ebp
f0100b22:	c3                   	ret    
	assert(nfree_basemem > 0);
f0100b23:	68 be 3a 10 f0       	push   $0xf0103abe
f0100b28:	68 51 3a 10 f0       	push   $0xf0103a51
f0100b2d:	68 60 02 00 00       	push   $0x260
f0100b32:	68 2b 3a 10 f0       	push   $0xf0103a2b
f0100b37:	e8 4f f5 ff ff       	call   f010008b <_panic>
	assert(nfree_extmem > 0);
f0100b3c:	68 d0 3a 10 f0       	push   $0xf0103ad0
f0100b41:	68 51 3a 10 f0       	push   $0xf0103a51
f0100b46:	68 61 02 00 00       	push   $0x261
f0100b4b:	68 2b 3a 10 f0       	push   $0xf0103a2b
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
f0100cbe:	e8 a0 24 00 00       	call   f0103163 <memset>
f0100cc3:	83 c4 10             	add    $0x10,%esp
f0100cc6:	eb c1                	jmp    f0100c89 <page_alloc+0x24>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100cc8:	52                   	push   %edx
f0100cc9:	68 28 3d 10 f0       	push   $0xf0103d28
f0100cce:	6a 52                	push   $0x52
f0100cd0:	68 37 3a 10 f0       	push   $0xf0103a37
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
f0100d01:	68 e1 3a 10 f0       	push   $0xf0103ae1
f0100d06:	68 54 01 00 00       	push   $0x154
f0100d0b:	68 2b 3a 10 f0       	push   $0xf0103a2b
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
f0100dac:	68 28 3d 10 f0       	push   $0xf0103d28
f0100db1:	68 93 01 00 00       	push   $0x193
f0100db6:	68 2b 3a 10 f0       	push   $0xf0103a2b
f0100dbb:	e8 cb f2 ff ff       	call   f010008b <_panic>
			return NULL;
f0100dc0:	b8 00 00 00 00       	mov    $0x0,%eax
f0100dc5:	eb df                	jmp    f0100da6 <pgdir_walk+0x6b>

f0100dc7 <page_lookup>:
{
f0100dc7:	55                   	push   %ebp
f0100dc8:	89 e5                	mov    %esp,%ebp
f0100dca:	53                   	push   %ebx
f0100dcb:	83 ec 08             	sub    $0x8,%esp
f0100dce:	8b 5d 10             	mov    0x10(%ebp),%ebx
	pte_t *pt_entry = pgdir_walk(pgdir, va, false);
f0100dd1:	6a 00                	push   $0x0
f0100dd3:	ff 75 0c             	pushl  0xc(%ebp)
f0100dd6:	ff 75 08             	pushl  0x8(%ebp)
f0100dd9:	e8 5d ff ff ff       	call   f0100d3b <pgdir_walk>
	if(pt_entry == NULL)
f0100dde:	83 c4 10             	add    $0x10,%esp
f0100de1:	85 c0                	test   %eax,%eax
f0100de3:	74 21                	je     f0100e06 <page_lookup+0x3f>
	if(!(*pt_entry & PTE_P))
f0100de5:	f6 00 01             	testb  $0x1,(%eax)
f0100de8:	74 35                	je     f0100e1f <page_lookup+0x58>
	if(pte_store != NULL)
f0100dea:	85 db                	test   %ebx,%ebx
f0100dec:	74 02                	je     f0100df0 <page_lookup+0x29>
		*pte_store = pt_entry;
f0100dee:	89 03                	mov    %eax,(%ebx)
f0100df0:	8b 00                	mov    (%eax),%eax
f0100df2:	c1 e8 0c             	shr    $0xc,%eax
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100df5:	39 05 68 89 11 f0    	cmp    %eax,0xf0118968
f0100dfb:	76 0e                	jbe    f0100e0b <page_lookup+0x44>
		panic("pa2page called with invalid pa");
	return &pages[PGNUM(pa)];
f0100dfd:	8b 15 70 89 11 f0    	mov    0xf0118970,%edx
f0100e03:	8d 04 c2             	lea    (%edx,%eax,8),%eax
}
f0100e06:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100e09:	c9                   	leave  
f0100e0a:	c3                   	ret    
		panic("pa2page called with invalid pa");
f0100e0b:	83 ec 04             	sub    $0x4,%esp
f0100e0e:	68 34 3e 10 f0       	push   $0xf0103e34
f0100e13:	6a 4b                	push   $0x4b
f0100e15:	68 37 3a 10 f0       	push   $0xf0103a37
f0100e1a:	e8 6c f2 ff ff       	call   f010008b <_panic>
		return NULL;
f0100e1f:	b8 00 00 00 00       	mov    $0x0,%eax
f0100e24:	eb e0                	jmp    f0100e06 <page_lookup+0x3f>

f0100e26 <page_remove>:
{
f0100e26:	55                   	push   %ebp
f0100e27:	89 e5                	mov    %esp,%ebp
f0100e29:	53                   	push   %ebx
f0100e2a:	83 ec 18             	sub    $0x18,%esp
f0100e2d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct PageInfo *page = page_lookup(pgdir, va, &pte_store);
f0100e30:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0100e33:	50                   	push   %eax
f0100e34:	53                   	push   %ebx
f0100e35:	ff 75 08             	pushl  0x8(%ebp)
f0100e38:	e8 8a ff ff ff       	call   f0100dc7 <page_lookup>
	if(page == NULL)
f0100e3d:	83 c4 10             	add    $0x10,%esp
f0100e40:	85 c0                	test   %eax,%eax
f0100e42:	74 18                	je     f0100e5c <page_remove+0x36>
	page_decref(page);
f0100e44:	83 ec 0c             	sub    $0xc,%esp
f0100e47:	50                   	push   %eax
f0100e48:	e8 c8 fe ff ff       	call   f0100d15 <page_decref>
}

static inline void
invlpg(void *addr)
{
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0100e4d:	0f 01 3b             	invlpg (%ebx)
	*pte_store = 0;
f0100e50:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0100e53:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
f0100e59:	83 c4 10             	add    $0x10,%esp
}
f0100e5c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100e5f:	c9                   	leave  
f0100e60:	c3                   	ret    

f0100e61 <page_insert>:
{
f0100e61:	55                   	push   %ebp
f0100e62:	89 e5                	mov    %esp,%ebp
f0100e64:	57                   	push   %edi
f0100e65:	56                   	push   %esi
f0100e66:	53                   	push   %ebx
f0100e67:	83 ec 10             	sub    $0x10,%esp
f0100e6a:	8b 7d 08             	mov    0x8(%ebp),%edi
f0100e6d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	pte_t *pt_entry = pgdir_walk(pgdir, (void *)va, 1);
f0100e70:	6a 01                	push   $0x1
f0100e72:	ff 75 10             	pushl  0x10(%ebp)
f0100e75:	57                   	push   %edi
f0100e76:	e8 c0 fe ff ff       	call   f0100d3b <pgdir_walk>
	if (pt_entry == NULL) {
f0100e7b:	83 c4 10             	add    $0x10,%esp
f0100e7e:	85 c0                	test   %eax,%eax
f0100e80:	74 56                	je     f0100ed8 <page_insert+0x77>
f0100e82:	89 c6                	mov    %eax,%esi
	pp->pp_ref++;
f0100e84:	66 ff 43 04          	incw   0x4(%ebx)
	if (*pt_entry & PTE_P)
f0100e88:	f6 00 01             	testb  $0x1,(%eax)
f0100e8b:	75 34                	jne    f0100ec1 <page_insert+0x60>
	return (pp - pages) << PGSHIFT;
f0100e8d:	2b 1d 70 89 11 f0    	sub    0xf0118970,%ebx
f0100e93:	c1 fb 03             	sar    $0x3,%ebx
f0100e96:	c1 e3 0c             	shl    $0xc,%ebx
	*pt_entry = page2pa(pp) | perm | PTE_P;
f0100e99:	0b 5d 14             	or     0x14(%ebp),%ebx
f0100e9c:	83 cb 01             	or     $0x1,%ebx
f0100e9f:	89 1e                	mov    %ebx,(%esi)
	pgdir[PDX(va)] |= perm | PTE_P;
f0100ea1:	8b 45 10             	mov    0x10(%ebp),%eax
f0100ea4:	c1 e8 16             	shr    $0x16,%eax
f0100ea7:	8d 14 87             	lea    (%edi,%eax,4),%edx
f0100eaa:	8b 45 14             	mov    0x14(%ebp),%eax
f0100ead:	0b 02                	or     (%edx),%eax
f0100eaf:	83 c8 01             	or     $0x1,%eax
f0100eb2:	89 02                	mov    %eax,(%edx)
	return 0;
f0100eb4:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100eb9:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100ebc:	5b                   	pop    %ebx
f0100ebd:	5e                   	pop    %esi
f0100ebe:	5f                   	pop    %edi
f0100ebf:	5d                   	pop    %ebp
f0100ec0:	c3                   	ret    
f0100ec1:	8b 45 10             	mov    0x10(%ebp),%eax
f0100ec4:	0f 01 38             	invlpg (%eax)
		page_remove(pgdir, va);
f0100ec7:	83 ec 08             	sub    $0x8,%esp
f0100eca:	ff 75 10             	pushl  0x10(%ebp)
f0100ecd:	57                   	push   %edi
f0100ece:	e8 53 ff ff ff       	call   f0100e26 <page_remove>
f0100ed3:	83 c4 10             	add    $0x10,%esp
f0100ed6:	eb b5                	jmp    f0100e8d <page_insert+0x2c>
		return -E_NO_MEM;
f0100ed8:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f0100edd:	eb da                	jmp    f0100eb9 <page_insert+0x58>

f0100edf <mem_init>:
{
f0100edf:	55                   	push   %ebp
f0100ee0:	89 e5                	mov    %esp,%ebp
f0100ee2:	57                   	push   %edi
f0100ee3:	56                   	push   %esi
f0100ee4:	53                   	push   %ebx
f0100ee5:	83 ec 3c             	sub    $0x3c,%esp
	basemem = nvram_read(NVRAM_BASELO);
f0100ee8:	b8 15 00 00 00       	mov    $0x15,%eax
f0100eed:	e8 1d f9 ff ff       	call   f010080f <nvram_read>
f0100ef2:	89 c3                	mov    %eax,%ebx
	extmem = nvram_read(NVRAM_EXTLO);
f0100ef4:	b8 17 00 00 00       	mov    $0x17,%eax
f0100ef9:	e8 11 f9 ff ff       	call   f010080f <nvram_read>
f0100efe:	89 c6                	mov    %eax,%esi
	ext16mem = nvram_read(NVRAM_EXT16LO) * 64;
f0100f00:	b8 34 00 00 00       	mov    $0x34,%eax
f0100f05:	e8 05 f9 ff ff       	call   f010080f <nvram_read>
	if (ext16mem)
f0100f0a:	c1 e0 06             	shl    $0x6,%eax
f0100f0d:	0f 84 ca 00 00 00    	je     f0100fdd <mem_init+0xfe>
		totalmem = 16 * 1024 + ext16mem;
f0100f13:	05 00 40 00 00       	add    $0x4000,%eax
	npages = totalmem / (PGSIZE / 1024);
f0100f18:	89 c2                	mov    %eax,%edx
f0100f1a:	c1 ea 02             	shr    $0x2,%edx
f0100f1d:	89 15 68 89 11 f0    	mov    %edx,0xf0118968
	npages_basemem = basemem / (PGSIZE / 1024);
f0100f23:	89 da                	mov    %ebx,%edx
f0100f25:	c1 ea 02             	shr    $0x2,%edx
f0100f28:	89 15 40 85 11 f0    	mov    %edx,0xf0118540
	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0100f2e:	89 c2                	mov    %eax,%edx
f0100f30:	29 da                	sub    %ebx,%edx
f0100f32:	52                   	push   %edx
f0100f33:	53                   	push   %ebx
f0100f34:	50                   	push   %eax
f0100f35:	68 54 3e 10 f0       	push   $0xf0103e54
f0100f3a:	e8 94 17 00 00       	call   f01026d3 <cprintf>
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f0100f3f:	b8 00 10 00 00       	mov    $0x1000,%eax
f0100f44:	e8 ed f8 ff ff       	call   f0100836 <boot_alloc>
f0100f49:	a3 6c 89 11 f0       	mov    %eax,0xf011896c
	memset(kern_pgdir, 0, PGSIZE);
f0100f4e:	83 c4 0c             	add    $0xc,%esp
f0100f51:	68 00 10 00 00       	push   $0x1000
f0100f56:	6a 00                	push   $0x0
f0100f58:	50                   	push   %eax
f0100f59:	e8 05 22 00 00       	call   f0103163 <memset>
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f0100f5e:	a1 6c 89 11 f0       	mov    0xf011896c,%eax
	if ((uint32_t)kva < KERNBASE)
f0100f63:	83 c4 10             	add    $0x10,%esp
f0100f66:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0100f6b:	0f 86 82 00 00 00    	jbe    f0100ff3 <mem_init+0x114>
	return (physaddr_t)kva - KERNBASE;
f0100f71:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0100f77:	83 ca 05             	or     $0x5,%edx
f0100f7a:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	pages = boot_alloc(npages * sizeof(struct PageInfo *));
f0100f80:	a1 68 89 11 f0       	mov    0xf0118968,%eax
f0100f85:	c1 e0 02             	shl    $0x2,%eax
f0100f88:	e8 a9 f8 ff ff       	call   f0100836 <boot_alloc>
f0100f8d:	a3 70 89 11 f0       	mov    %eax,0xf0118970
	memset(pages, 0, npages * sizeof(struct PageInfo *));
f0100f92:	83 ec 04             	sub    $0x4,%esp
f0100f95:	8b 0d 68 89 11 f0    	mov    0xf0118968,%ecx
f0100f9b:	8d 14 8d 00 00 00 00 	lea    0x0(,%ecx,4),%edx
f0100fa2:	52                   	push   %edx
f0100fa3:	6a 00                	push   $0x0
f0100fa5:	50                   	push   %eax
f0100fa6:	e8 b8 21 00 00       	call   f0103163 <memset>
	page_init();
f0100fab:	e8 05 fc ff ff       	call   f0100bb5 <page_init>
	check_page_free_list(1);
f0100fb0:	b8 01 00 00 00       	mov    $0x1,%eax
f0100fb5:	e8 3b f9 ff ff       	call   f01008f5 <check_page_free_list>
	if (!pages)
f0100fba:	83 c4 10             	add    $0x10,%esp
f0100fbd:	83 3d 70 89 11 f0 00 	cmpl   $0x0,0xf0118970
f0100fc4:	74 42                	je     f0101008 <mem_init+0x129>
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0100fc6:	a1 3c 85 11 f0       	mov    0xf011853c,%eax
f0100fcb:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
f0100fd2:	85 c0                	test   %eax,%eax
f0100fd4:	74 49                	je     f010101f <mem_init+0x140>
		++nfree;
f0100fd6:	ff 45 d4             	incl   -0x2c(%ebp)
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0100fd9:	8b 00                	mov    (%eax),%eax
f0100fdb:	eb f5                	jmp    f0100fd2 <mem_init+0xf3>
	else if (extmem)
f0100fdd:	85 f6                	test   %esi,%esi
f0100fdf:	74 0b                	je     f0100fec <mem_init+0x10d>
		totalmem = 1 * 1024 + extmem;
f0100fe1:	8d 86 00 04 00 00    	lea    0x400(%esi),%eax
f0100fe7:	e9 2c ff ff ff       	jmp    f0100f18 <mem_init+0x39>
		totalmem = basemem;
f0100fec:	89 d8                	mov    %ebx,%eax
f0100fee:	e9 25 ff ff ff       	jmp    f0100f18 <mem_init+0x39>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100ff3:	50                   	push   %eax
f0100ff4:	68 90 3e 10 f0       	push   $0xf0103e90
f0100ff9:	68 95 00 00 00       	push   $0x95
f0100ffe:	68 2b 3a 10 f0       	push   $0xf0103a2b
f0101003:	e8 83 f0 ff ff       	call   f010008b <_panic>
		panic("'pages' is a null pointer!");
f0101008:	83 ec 04             	sub    $0x4,%esp
f010100b:	68 f8 3a 10 f0       	push   $0xf0103af8
f0101010:	68 74 02 00 00       	push   $0x274
f0101015:	68 2b 3a 10 f0       	push   $0xf0103a2b
f010101a:	e8 6c f0 ff ff       	call   f010008b <_panic>
	assert((pp0 = page_alloc(0)));
f010101f:	83 ec 0c             	sub    $0xc,%esp
f0101022:	6a 00                	push   $0x0
f0101024:	e8 3c fc ff ff       	call   f0100c65 <page_alloc>
f0101029:	89 c3                	mov    %eax,%ebx
f010102b:	83 c4 10             	add    $0x10,%esp
f010102e:	85 c0                	test   %eax,%eax
f0101030:	0f 84 0e 02 00 00    	je     f0101244 <mem_init+0x365>
	assert((pp1 = page_alloc(0)));
f0101036:	83 ec 0c             	sub    $0xc,%esp
f0101039:	6a 00                	push   $0x0
f010103b:	e8 25 fc ff ff       	call   f0100c65 <page_alloc>
f0101040:	89 c6                	mov    %eax,%esi
f0101042:	83 c4 10             	add    $0x10,%esp
f0101045:	85 c0                	test   %eax,%eax
f0101047:	0f 84 10 02 00 00    	je     f010125d <mem_init+0x37e>
	assert((pp2 = page_alloc(0)));
f010104d:	83 ec 0c             	sub    $0xc,%esp
f0101050:	6a 00                	push   $0x0
f0101052:	e8 0e fc ff ff       	call   f0100c65 <page_alloc>
f0101057:	89 c7                	mov    %eax,%edi
f0101059:	83 c4 10             	add    $0x10,%esp
f010105c:	85 c0                	test   %eax,%eax
f010105e:	0f 84 12 02 00 00    	je     f0101276 <mem_init+0x397>
	assert(pp1 && pp1 != pp0);
f0101064:	39 f3                	cmp    %esi,%ebx
f0101066:	0f 84 23 02 00 00    	je     f010128f <mem_init+0x3b0>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f010106c:	39 c6                	cmp    %eax,%esi
f010106e:	0f 84 34 02 00 00    	je     f01012a8 <mem_init+0x3c9>
f0101074:	39 c3                	cmp    %eax,%ebx
f0101076:	0f 84 2c 02 00 00    	je     f01012a8 <mem_init+0x3c9>
	return (pp - pages) << PGSHIFT;
f010107c:	8b 0d 70 89 11 f0    	mov    0xf0118970,%ecx
	assert(page2pa(pp0) < npages*PGSIZE);
f0101082:	8b 15 68 89 11 f0    	mov    0xf0118968,%edx
f0101088:	c1 e2 0c             	shl    $0xc,%edx
f010108b:	89 d8                	mov    %ebx,%eax
f010108d:	29 c8                	sub    %ecx,%eax
f010108f:	c1 f8 03             	sar    $0x3,%eax
f0101092:	c1 e0 0c             	shl    $0xc,%eax
f0101095:	39 d0                	cmp    %edx,%eax
f0101097:	0f 83 24 02 00 00    	jae    f01012c1 <mem_init+0x3e2>
f010109d:	89 f0                	mov    %esi,%eax
f010109f:	29 c8                	sub    %ecx,%eax
f01010a1:	c1 f8 03             	sar    $0x3,%eax
f01010a4:	c1 e0 0c             	shl    $0xc,%eax
	assert(page2pa(pp1) < npages*PGSIZE);
f01010a7:	39 c2                	cmp    %eax,%edx
f01010a9:	0f 86 2b 02 00 00    	jbe    f01012da <mem_init+0x3fb>
f01010af:	89 f8                	mov    %edi,%eax
f01010b1:	29 c8                	sub    %ecx,%eax
f01010b3:	c1 f8 03             	sar    $0x3,%eax
f01010b6:	c1 e0 0c             	shl    $0xc,%eax
	assert(page2pa(pp2) < npages*PGSIZE);
f01010b9:	39 c2                	cmp    %eax,%edx
f01010bb:	0f 86 32 02 00 00    	jbe    f01012f3 <mem_init+0x414>
	fl = page_free_list;
f01010c1:	a1 3c 85 11 f0       	mov    0xf011853c,%eax
f01010c6:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f01010c9:	c7 05 3c 85 11 f0 00 	movl   $0x0,0xf011853c
f01010d0:	00 00 00 
	assert(!page_alloc(0));
f01010d3:	83 ec 0c             	sub    $0xc,%esp
f01010d6:	6a 00                	push   $0x0
f01010d8:	e8 88 fb ff ff       	call   f0100c65 <page_alloc>
f01010dd:	83 c4 10             	add    $0x10,%esp
f01010e0:	85 c0                	test   %eax,%eax
f01010e2:	0f 85 24 02 00 00    	jne    f010130c <mem_init+0x42d>
	page_free(pp0);
f01010e8:	83 ec 0c             	sub    $0xc,%esp
f01010eb:	53                   	push   %ebx
f01010ec:	e8 e9 fb ff ff       	call   f0100cda <page_free>
	page_free(pp1);
f01010f1:	89 34 24             	mov    %esi,(%esp)
f01010f4:	e8 e1 fb ff ff       	call   f0100cda <page_free>
	page_free(pp2);
f01010f9:	89 3c 24             	mov    %edi,(%esp)
f01010fc:	e8 d9 fb ff ff       	call   f0100cda <page_free>
	assert((pp0 = page_alloc(0)));
f0101101:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101108:	e8 58 fb ff ff       	call   f0100c65 <page_alloc>
f010110d:	89 c3                	mov    %eax,%ebx
f010110f:	83 c4 10             	add    $0x10,%esp
f0101112:	85 c0                	test   %eax,%eax
f0101114:	0f 84 0b 02 00 00    	je     f0101325 <mem_init+0x446>
	assert((pp1 = page_alloc(0)));
f010111a:	83 ec 0c             	sub    $0xc,%esp
f010111d:	6a 00                	push   $0x0
f010111f:	e8 41 fb ff ff       	call   f0100c65 <page_alloc>
f0101124:	89 c6                	mov    %eax,%esi
f0101126:	83 c4 10             	add    $0x10,%esp
f0101129:	85 c0                	test   %eax,%eax
f010112b:	0f 84 0d 02 00 00    	je     f010133e <mem_init+0x45f>
	assert((pp2 = page_alloc(0)));
f0101131:	83 ec 0c             	sub    $0xc,%esp
f0101134:	6a 00                	push   $0x0
f0101136:	e8 2a fb ff ff       	call   f0100c65 <page_alloc>
f010113b:	89 c7                	mov    %eax,%edi
f010113d:	83 c4 10             	add    $0x10,%esp
f0101140:	85 c0                	test   %eax,%eax
f0101142:	0f 84 0f 02 00 00    	je     f0101357 <mem_init+0x478>
	assert(pp1 && pp1 != pp0);
f0101148:	39 f3                	cmp    %esi,%ebx
f010114a:	0f 84 20 02 00 00    	je     f0101370 <mem_init+0x491>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101150:	39 c6                	cmp    %eax,%esi
f0101152:	0f 84 31 02 00 00    	je     f0101389 <mem_init+0x4aa>
f0101158:	39 c3                	cmp    %eax,%ebx
f010115a:	0f 84 29 02 00 00    	je     f0101389 <mem_init+0x4aa>
	assert(!page_alloc(0));
f0101160:	83 ec 0c             	sub    $0xc,%esp
f0101163:	6a 00                	push   $0x0
f0101165:	e8 fb fa ff ff       	call   f0100c65 <page_alloc>
f010116a:	83 c4 10             	add    $0x10,%esp
f010116d:	85 c0                	test   %eax,%eax
f010116f:	0f 85 2d 02 00 00    	jne    f01013a2 <mem_init+0x4c3>
f0101175:	89 d8                	mov    %ebx,%eax
f0101177:	2b 05 70 89 11 f0    	sub    0xf0118970,%eax
f010117d:	c1 f8 03             	sar    $0x3,%eax
f0101180:	89 c2                	mov    %eax,%edx
f0101182:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0101185:	25 ff ff 0f 00       	and    $0xfffff,%eax
f010118a:	3b 05 68 89 11 f0    	cmp    0xf0118968,%eax
f0101190:	0f 83 25 02 00 00    	jae    f01013bb <mem_init+0x4dc>
	memset(page2kva(pp0), 1, PGSIZE);
f0101196:	83 ec 04             	sub    $0x4,%esp
f0101199:	68 00 10 00 00       	push   $0x1000
f010119e:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f01011a0:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f01011a6:	52                   	push   %edx
f01011a7:	e8 b7 1f 00 00       	call   f0103163 <memset>
	page_free(pp0);
f01011ac:	89 1c 24             	mov    %ebx,(%esp)
f01011af:	e8 26 fb ff ff       	call   f0100cda <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f01011b4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f01011bb:	e8 a5 fa ff ff       	call   f0100c65 <page_alloc>
f01011c0:	83 c4 10             	add    $0x10,%esp
f01011c3:	85 c0                	test   %eax,%eax
f01011c5:	0f 84 02 02 00 00    	je     f01013cd <mem_init+0x4ee>
	assert(pp && pp0 == pp);
f01011cb:	39 c3                	cmp    %eax,%ebx
f01011cd:	0f 85 13 02 00 00    	jne    f01013e6 <mem_init+0x507>
	return (pp - pages) << PGSHIFT;
f01011d3:	2b 05 70 89 11 f0    	sub    0xf0118970,%eax
f01011d9:	c1 f8 03             	sar    $0x3,%eax
f01011dc:	89 c2                	mov    %eax,%edx
f01011de:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f01011e1:	25 ff ff 0f 00       	and    $0xfffff,%eax
f01011e6:	3b 05 68 89 11 f0    	cmp    0xf0118968,%eax
f01011ec:	0f 83 0d 02 00 00    	jae    f01013ff <mem_init+0x520>
	return (void *)(pa + KERNBASE);
f01011f2:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
f01011f8:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
		assert(c[i] == 0);
f01011fe:	80 38 00             	cmpb   $0x0,(%eax)
f0101201:	0f 85 0a 02 00 00    	jne    f0101411 <mem_init+0x532>
f0101207:	40                   	inc    %eax
	for (i = 0; i < PGSIZE; i++)
f0101208:	39 d0                	cmp    %edx,%eax
f010120a:	75 f2                	jne    f01011fe <mem_init+0x31f>
	page_free_list = fl;
f010120c:	8b 45 d0             	mov    -0x30(%ebp),%eax
f010120f:	a3 3c 85 11 f0       	mov    %eax,0xf011853c
	page_free(pp0);
f0101214:	83 ec 0c             	sub    $0xc,%esp
f0101217:	53                   	push   %ebx
f0101218:	e8 bd fa ff ff       	call   f0100cda <page_free>
	page_free(pp1);
f010121d:	89 34 24             	mov    %esi,(%esp)
f0101220:	e8 b5 fa ff ff       	call   f0100cda <page_free>
	page_free(pp2);
f0101225:	89 3c 24             	mov    %edi,(%esp)
f0101228:	e8 ad fa ff ff       	call   f0100cda <page_free>
	for (pp = page_free_list; pp; pp = pp->pp_link)
f010122d:	a1 3c 85 11 f0       	mov    0xf011853c,%eax
f0101232:	83 c4 10             	add    $0x10,%esp
f0101235:	85 c0                	test   %eax,%eax
f0101237:	0f 84 ed 01 00 00    	je     f010142a <mem_init+0x54b>
		--nfree;
f010123d:	ff 4d d4             	decl   -0x2c(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101240:	8b 00                	mov    (%eax),%eax
f0101242:	eb f1                	jmp    f0101235 <mem_init+0x356>
	assert((pp0 = page_alloc(0)));
f0101244:	68 13 3b 10 f0       	push   $0xf0103b13
f0101249:	68 51 3a 10 f0       	push   $0xf0103a51
f010124e:	68 7c 02 00 00       	push   $0x27c
f0101253:	68 2b 3a 10 f0       	push   $0xf0103a2b
f0101258:	e8 2e ee ff ff       	call   f010008b <_panic>
	assert((pp1 = page_alloc(0)));
f010125d:	68 29 3b 10 f0       	push   $0xf0103b29
f0101262:	68 51 3a 10 f0       	push   $0xf0103a51
f0101267:	68 7d 02 00 00       	push   $0x27d
f010126c:	68 2b 3a 10 f0       	push   $0xf0103a2b
f0101271:	e8 15 ee ff ff       	call   f010008b <_panic>
	assert((pp2 = page_alloc(0)));
f0101276:	68 3f 3b 10 f0       	push   $0xf0103b3f
f010127b:	68 51 3a 10 f0       	push   $0xf0103a51
f0101280:	68 7e 02 00 00       	push   $0x27e
f0101285:	68 2b 3a 10 f0       	push   $0xf0103a2b
f010128a:	e8 fc ed ff ff       	call   f010008b <_panic>
	assert(pp1 && pp1 != pp0);
f010128f:	68 55 3b 10 f0       	push   $0xf0103b55
f0101294:	68 51 3a 10 f0       	push   $0xf0103a51
f0101299:	68 81 02 00 00       	push   $0x281
f010129e:	68 2b 3a 10 f0       	push   $0xf0103a2b
f01012a3:	e8 e3 ed ff ff       	call   f010008b <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01012a8:	68 b4 3e 10 f0       	push   $0xf0103eb4
f01012ad:	68 51 3a 10 f0       	push   $0xf0103a51
f01012b2:	68 82 02 00 00       	push   $0x282
f01012b7:	68 2b 3a 10 f0       	push   $0xf0103a2b
f01012bc:	e8 ca ed ff ff       	call   f010008b <_panic>
	assert(page2pa(pp0) < npages*PGSIZE);
f01012c1:	68 67 3b 10 f0       	push   $0xf0103b67
f01012c6:	68 51 3a 10 f0       	push   $0xf0103a51
f01012cb:	68 83 02 00 00       	push   $0x283
f01012d0:	68 2b 3a 10 f0       	push   $0xf0103a2b
f01012d5:	e8 b1 ed ff ff       	call   f010008b <_panic>
	assert(page2pa(pp1) < npages*PGSIZE);
f01012da:	68 84 3b 10 f0       	push   $0xf0103b84
f01012df:	68 51 3a 10 f0       	push   $0xf0103a51
f01012e4:	68 84 02 00 00       	push   $0x284
f01012e9:	68 2b 3a 10 f0       	push   $0xf0103a2b
f01012ee:	e8 98 ed ff ff       	call   f010008b <_panic>
	assert(page2pa(pp2) < npages*PGSIZE);
f01012f3:	68 a1 3b 10 f0       	push   $0xf0103ba1
f01012f8:	68 51 3a 10 f0       	push   $0xf0103a51
f01012fd:	68 85 02 00 00       	push   $0x285
f0101302:	68 2b 3a 10 f0       	push   $0xf0103a2b
f0101307:	e8 7f ed ff ff       	call   f010008b <_panic>
	assert(!page_alloc(0));
f010130c:	68 be 3b 10 f0       	push   $0xf0103bbe
f0101311:	68 51 3a 10 f0       	push   $0xf0103a51
f0101316:	68 8c 02 00 00       	push   $0x28c
f010131b:	68 2b 3a 10 f0       	push   $0xf0103a2b
f0101320:	e8 66 ed ff ff       	call   f010008b <_panic>
	assert((pp0 = page_alloc(0)));
f0101325:	68 13 3b 10 f0       	push   $0xf0103b13
f010132a:	68 51 3a 10 f0       	push   $0xf0103a51
f010132f:	68 93 02 00 00       	push   $0x293
f0101334:	68 2b 3a 10 f0       	push   $0xf0103a2b
f0101339:	e8 4d ed ff ff       	call   f010008b <_panic>
	assert((pp1 = page_alloc(0)));
f010133e:	68 29 3b 10 f0       	push   $0xf0103b29
f0101343:	68 51 3a 10 f0       	push   $0xf0103a51
f0101348:	68 94 02 00 00       	push   $0x294
f010134d:	68 2b 3a 10 f0       	push   $0xf0103a2b
f0101352:	e8 34 ed ff ff       	call   f010008b <_panic>
	assert((pp2 = page_alloc(0)));
f0101357:	68 3f 3b 10 f0       	push   $0xf0103b3f
f010135c:	68 51 3a 10 f0       	push   $0xf0103a51
f0101361:	68 95 02 00 00       	push   $0x295
f0101366:	68 2b 3a 10 f0       	push   $0xf0103a2b
f010136b:	e8 1b ed ff ff       	call   f010008b <_panic>
	assert(pp1 && pp1 != pp0);
f0101370:	68 55 3b 10 f0       	push   $0xf0103b55
f0101375:	68 51 3a 10 f0       	push   $0xf0103a51
f010137a:	68 97 02 00 00       	push   $0x297
f010137f:	68 2b 3a 10 f0       	push   $0xf0103a2b
f0101384:	e8 02 ed ff ff       	call   f010008b <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101389:	68 b4 3e 10 f0       	push   $0xf0103eb4
f010138e:	68 51 3a 10 f0       	push   $0xf0103a51
f0101393:	68 98 02 00 00       	push   $0x298
f0101398:	68 2b 3a 10 f0       	push   $0xf0103a2b
f010139d:	e8 e9 ec ff ff       	call   f010008b <_panic>
	assert(!page_alloc(0));
f01013a2:	68 be 3b 10 f0       	push   $0xf0103bbe
f01013a7:	68 51 3a 10 f0       	push   $0xf0103a51
f01013ac:	68 99 02 00 00       	push   $0x299
f01013b1:	68 2b 3a 10 f0       	push   $0xf0103a2b
f01013b6:	e8 d0 ec ff ff       	call   f010008b <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01013bb:	52                   	push   %edx
f01013bc:	68 28 3d 10 f0       	push   $0xf0103d28
f01013c1:	6a 52                	push   $0x52
f01013c3:	68 37 3a 10 f0       	push   $0xf0103a37
f01013c8:	e8 be ec ff ff       	call   f010008b <_panic>
	assert((pp = page_alloc(ALLOC_ZERO)));
f01013cd:	68 cd 3b 10 f0       	push   $0xf0103bcd
f01013d2:	68 51 3a 10 f0       	push   $0xf0103a51
f01013d7:	68 9e 02 00 00       	push   $0x29e
f01013dc:	68 2b 3a 10 f0       	push   $0xf0103a2b
f01013e1:	e8 a5 ec ff ff       	call   f010008b <_panic>
	assert(pp && pp0 == pp);
f01013e6:	68 eb 3b 10 f0       	push   $0xf0103beb
f01013eb:	68 51 3a 10 f0       	push   $0xf0103a51
f01013f0:	68 9f 02 00 00       	push   $0x29f
f01013f5:	68 2b 3a 10 f0       	push   $0xf0103a2b
f01013fa:	e8 8c ec ff ff       	call   f010008b <_panic>
f01013ff:	52                   	push   %edx
f0101400:	68 28 3d 10 f0       	push   $0xf0103d28
f0101405:	6a 52                	push   $0x52
f0101407:	68 37 3a 10 f0       	push   $0xf0103a37
f010140c:	e8 7a ec ff ff       	call   f010008b <_panic>
		assert(c[i] == 0);
f0101411:	68 fb 3b 10 f0       	push   $0xf0103bfb
f0101416:	68 51 3a 10 f0       	push   $0xf0103a51
f010141b:	68 a2 02 00 00       	push   $0x2a2
f0101420:	68 2b 3a 10 f0       	push   $0xf0103a2b
f0101425:	e8 61 ec ff ff       	call   f010008b <_panic>
	assert(nfree == 0);
f010142a:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f010142e:	0f 85 f0 06 00 00    	jne    f0101b24 <mem_init+0xc45>
	cprintf("check_page_alloc() succeeded!\n");
f0101434:	83 ec 0c             	sub    $0xc,%esp
f0101437:	68 d4 3e 10 f0       	push   $0xf0103ed4
f010143c:	e8 92 12 00 00       	call   f01026d3 <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101441:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101448:	e8 18 f8 ff ff       	call   f0100c65 <page_alloc>
f010144d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101450:	83 c4 10             	add    $0x10,%esp
f0101453:	85 c0                	test   %eax,%eax
f0101455:	0f 84 e2 06 00 00    	je     f0101b3d <mem_init+0xc5e>
	assert((pp1 = page_alloc(0)));
f010145b:	83 ec 0c             	sub    $0xc,%esp
f010145e:	6a 00                	push   $0x0
f0101460:	e8 00 f8 ff ff       	call   f0100c65 <page_alloc>
f0101465:	89 c6                	mov    %eax,%esi
f0101467:	83 c4 10             	add    $0x10,%esp
f010146a:	85 c0                	test   %eax,%eax
f010146c:	0f 84 e4 06 00 00    	je     f0101b56 <mem_init+0xc77>
	assert((pp2 = page_alloc(0)));
f0101472:	83 ec 0c             	sub    $0xc,%esp
f0101475:	6a 00                	push   $0x0
f0101477:	e8 e9 f7 ff ff       	call   f0100c65 <page_alloc>
f010147c:	89 c3                	mov    %eax,%ebx
f010147e:	83 c4 10             	add    $0x10,%esp
f0101481:	85 c0                	test   %eax,%eax
f0101483:	0f 84 e6 06 00 00    	je     f0101b6f <mem_init+0xc90>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101489:	39 75 d4             	cmp    %esi,-0x2c(%ebp)
f010148c:	0f 84 f6 06 00 00    	je     f0101b88 <mem_init+0xca9>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101492:	39 c6                	cmp    %eax,%esi
f0101494:	0f 84 07 07 00 00    	je     f0101ba1 <mem_init+0xcc2>
f010149a:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f010149d:	0f 84 fe 06 00 00    	je     f0101ba1 <mem_init+0xcc2>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f01014a3:	a1 3c 85 11 f0       	mov    0xf011853c,%eax
f01014a8:	89 45 cc             	mov    %eax,-0x34(%ebp)
	page_free_list = 0;
f01014ab:	c7 05 3c 85 11 f0 00 	movl   $0x0,0xf011853c
f01014b2:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f01014b5:	83 ec 0c             	sub    $0xc,%esp
f01014b8:	6a 00                	push   $0x0
f01014ba:	e8 a6 f7 ff ff       	call   f0100c65 <page_alloc>
f01014bf:	83 c4 10             	add    $0x10,%esp
f01014c2:	85 c0                	test   %eax,%eax
f01014c4:	0f 85 f0 06 00 00    	jne    f0101bba <mem_init+0xcdb>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f01014ca:	83 ec 04             	sub    $0x4,%esp
f01014cd:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01014d0:	50                   	push   %eax
f01014d1:	6a 00                	push   $0x0
f01014d3:	ff 35 6c 89 11 f0    	pushl  0xf011896c
f01014d9:	e8 e9 f8 ff ff       	call   f0100dc7 <page_lookup>
f01014de:	83 c4 10             	add    $0x10,%esp
f01014e1:	85 c0                	test   %eax,%eax
f01014e3:	0f 85 ea 06 00 00    	jne    f0101bd3 <mem_init+0xcf4>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f01014e9:	6a 02                	push   $0x2
f01014eb:	6a 00                	push   $0x0
f01014ed:	56                   	push   %esi
f01014ee:	ff 35 6c 89 11 f0    	pushl  0xf011896c
f01014f4:	e8 68 f9 ff ff       	call   f0100e61 <page_insert>
f01014f9:	83 c4 10             	add    $0x10,%esp
f01014fc:	85 c0                	test   %eax,%eax
f01014fe:	0f 89 e8 06 00 00    	jns    f0101bec <mem_init+0xd0d>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f0101504:	83 ec 0c             	sub    $0xc,%esp
f0101507:	ff 75 d4             	pushl  -0x2c(%ebp)
f010150a:	e8 cb f7 ff ff       	call   f0100cda <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f010150f:	6a 02                	push   $0x2
f0101511:	6a 00                	push   $0x0
f0101513:	56                   	push   %esi
f0101514:	ff 35 6c 89 11 f0    	pushl  0xf011896c
f010151a:	e8 42 f9 ff ff       	call   f0100e61 <page_insert>
f010151f:	83 c4 20             	add    $0x20,%esp
f0101522:	85 c0                	test   %eax,%eax
f0101524:	0f 85 db 06 00 00    	jne    f0101c05 <mem_init+0xd26>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f010152a:	8b 3d 6c 89 11 f0    	mov    0xf011896c,%edi
	return (pp - pages) << PGSHIFT;
f0101530:	8b 0d 70 89 11 f0    	mov    0xf0118970,%ecx
f0101536:	89 4d d0             	mov    %ecx,-0x30(%ebp)
f0101539:	8b 17                	mov    (%edi),%edx
f010153b:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101541:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101544:	29 c8                	sub    %ecx,%eax
f0101546:	c1 f8 03             	sar    $0x3,%eax
f0101549:	c1 e0 0c             	shl    $0xc,%eax
f010154c:	39 c2                	cmp    %eax,%edx
f010154e:	0f 85 ca 06 00 00    	jne    f0101c1e <mem_init+0xd3f>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0101554:	ba 00 00 00 00       	mov    $0x0,%edx
f0101559:	89 f8                	mov    %edi,%eax
f010155b:	e8 35 f3 ff ff       	call   f0100895 <check_va2pa>
f0101560:	89 c2                	mov    %eax,%edx
f0101562:	89 f0                	mov    %esi,%eax
f0101564:	2b 45 d0             	sub    -0x30(%ebp),%eax
f0101567:	c1 f8 03             	sar    $0x3,%eax
f010156a:	c1 e0 0c             	shl    $0xc,%eax
f010156d:	39 c2                	cmp    %eax,%edx
f010156f:	0f 85 c2 06 00 00    	jne    f0101c37 <mem_init+0xd58>
	assert(pp1->pp_ref == 1);
f0101575:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f010157a:	0f 85 d0 06 00 00    	jne    f0101c50 <mem_init+0xd71>
	assert(pp0->pp_ref == 1);
f0101580:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101583:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101588:	0f 85 db 06 00 00    	jne    f0101c69 <mem_init+0xd8a>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f010158e:	6a 02                	push   $0x2
f0101590:	68 00 10 00 00       	push   $0x1000
f0101595:	53                   	push   %ebx
f0101596:	57                   	push   %edi
f0101597:	e8 c5 f8 ff ff       	call   f0100e61 <page_insert>
f010159c:	83 c4 10             	add    $0x10,%esp
f010159f:	85 c0                	test   %eax,%eax
f01015a1:	0f 85 db 06 00 00    	jne    f0101c82 <mem_init+0xda3>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01015a7:	ba 00 10 00 00       	mov    $0x1000,%edx
f01015ac:	a1 6c 89 11 f0       	mov    0xf011896c,%eax
f01015b1:	e8 df f2 ff ff       	call   f0100895 <check_va2pa>
f01015b6:	89 c2                	mov    %eax,%edx
f01015b8:	89 d8                	mov    %ebx,%eax
f01015ba:	2b 05 70 89 11 f0    	sub    0xf0118970,%eax
f01015c0:	c1 f8 03             	sar    $0x3,%eax
f01015c3:	c1 e0 0c             	shl    $0xc,%eax
f01015c6:	39 c2                	cmp    %eax,%edx
f01015c8:	0f 85 cd 06 00 00    	jne    f0101c9b <mem_init+0xdbc>
	assert(pp2->pp_ref == 1);
f01015ce:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f01015d3:	0f 85 db 06 00 00    	jne    f0101cb4 <mem_init+0xdd5>
	// should be no free memory
	assert(!page_alloc(0));
f01015d9:	83 ec 0c             	sub    $0xc,%esp
f01015dc:	6a 00                	push   $0x0
f01015de:	e8 82 f6 ff ff       	call   f0100c65 <page_alloc>
f01015e3:	83 c4 10             	add    $0x10,%esp
f01015e6:	85 c0                	test   %eax,%eax
f01015e8:	0f 85 df 06 00 00    	jne    f0101ccd <mem_init+0xdee>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f01015ee:	6a 02                	push   $0x2
f01015f0:	68 00 10 00 00       	push   $0x1000
f01015f5:	53                   	push   %ebx
f01015f6:	ff 35 6c 89 11 f0    	pushl  0xf011896c
f01015fc:	e8 60 f8 ff ff       	call   f0100e61 <page_insert>
f0101601:	83 c4 10             	add    $0x10,%esp
f0101604:	85 c0                	test   %eax,%eax
f0101606:	0f 85 da 06 00 00    	jne    f0101ce6 <mem_init+0xe07>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f010160c:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101611:	a1 6c 89 11 f0       	mov    0xf011896c,%eax
f0101616:	e8 7a f2 ff ff       	call   f0100895 <check_va2pa>
f010161b:	89 c2                	mov    %eax,%edx
f010161d:	89 d8                	mov    %ebx,%eax
f010161f:	2b 05 70 89 11 f0    	sub    0xf0118970,%eax
f0101625:	c1 f8 03             	sar    $0x3,%eax
f0101628:	c1 e0 0c             	shl    $0xc,%eax
f010162b:	39 c2                	cmp    %eax,%edx
f010162d:	0f 85 cc 06 00 00    	jne    f0101cff <mem_init+0xe20>
	assert(pp2->pp_ref == 1);
f0101633:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101638:	0f 85 da 06 00 00    	jne    f0101d18 <mem_init+0xe39>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f010163e:	83 ec 0c             	sub    $0xc,%esp
f0101641:	6a 00                	push   $0x0
f0101643:	e8 1d f6 ff ff       	call   f0100c65 <page_alloc>
f0101648:	83 c4 10             	add    $0x10,%esp
f010164b:	85 c0                	test   %eax,%eax
f010164d:	0f 85 de 06 00 00    	jne    f0101d31 <mem_init+0xe52>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101653:	8b 0d 6c 89 11 f0    	mov    0xf011896c,%ecx
f0101659:	8b 01                	mov    (%ecx),%eax
f010165b:	89 c2                	mov    %eax,%edx
f010165d:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
	if (PGNUM(pa) >= npages)
f0101663:	c1 e8 0c             	shr    $0xc,%eax
f0101666:	3b 05 68 89 11 f0    	cmp    0xf0118968,%eax
f010166c:	0f 83 d8 06 00 00    	jae    f0101d4a <mem_init+0xe6b>
	return (void *)(pa + KERNBASE);
f0101672:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f0101678:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f010167b:	83 ec 04             	sub    $0x4,%esp
f010167e:	6a 00                	push   $0x0
f0101680:	68 00 10 00 00       	push   $0x1000
f0101685:	51                   	push   %ecx
f0101686:	e8 b0 f6 ff ff       	call   f0100d3b <pgdir_walk>
f010168b:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f010168e:	8d 51 04             	lea    0x4(%ecx),%edx
f0101691:	83 c4 10             	add    $0x10,%esp
f0101694:	39 c2                	cmp    %eax,%edx
f0101696:	0f 85 c3 06 00 00    	jne    f0101d5f <mem_init+0xe80>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f010169c:	6a 06                	push   $0x6
f010169e:	68 00 10 00 00       	push   $0x1000
f01016a3:	53                   	push   %ebx
f01016a4:	ff 35 6c 89 11 f0    	pushl  0xf011896c
f01016aa:	e8 b2 f7 ff ff       	call   f0100e61 <page_insert>
f01016af:	83 c4 10             	add    $0x10,%esp
f01016b2:	85 c0                	test   %eax,%eax
f01016b4:	0f 85 be 06 00 00    	jne    f0101d78 <mem_init+0xe99>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01016ba:	8b 3d 6c 89 11 f0    	mov    0xf011896c,%edi
f01016c0:	ba 00 10 00 00       	mov    $0x1000,%edx
f01016c5:	89 f8                	mov    %edi,%eax
f01016c7:	e8 c9 f1 ff ff       	call   f0100895 <check_va2pa>
f01016cc:	89 c2                	mov    %eax,%edx
	return (pp - pages) << PGSHIFT;
f01016ce:	89 d8                	mov    %ebx,%eax
f01016d0:	2b 05 70 89 11 f0    	sub    0xf0118970,%eax
f01016d6:	c1 f8 03             	sar    $0x3,%eax
f01016d9:	c1 e0 0c             	shl    $0xc,%eax
f01016dc:	39 c2                	cmp    %eax,%edx
f01016de:	0f 85 ad 06 00 00    	jne    f0101d91 <mem_init+0xeb2>
	assert(pp2->pp_ref == 1);
f01016e4:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f01016e9:	0f 85 bb 06 00 00    	jne    f0101daa <mem_init+0xecb>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f01016ef:	83 ec 04             	sub    $0x4,%esp
f01016f2:	6a 00                	push   $0x0
f01016f4:	68 00 10 00 00       	push   $0x1000
f01016f9:	57                   	push   %edi
f01016fa:	e8 3c f6 ff ff       	call   f0100d3b <pgdir_walk>
f01016ff:	83 c4 10             	add    $0x10,%esp
f0101702:	f6 00 04             	testb  $0x4,(%eax)
f0101705:	0f 84 b8 06 00 00    	je     f0101dc3 <mem_init+0xee4>
	assert(kern_pgdir[0] & PTE_U);
f010170b:	a1 6c 89 11 f0       	mov    0xf011896c,%eax
f0101710:	f6 00 04             	testb  $0x4,(%eax)
f0101713:	0f 84 c3 06 00 00    	je     f0101ddc <mem_init+0xefd>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101719:	6a 02                	push   $0x2
f010171b:	68 00 10 00 00       	push   $0x1000
f0101720:	53                   	push   %ebx
f0101721:	50                   	push   %eax
f0101722:	e8 3a f7 ff ff       	call   f0100e61 <page_insert>
f0101727:	83 c4 10             	add    $0x10,%esp
f010172a:	85 c0                	test   %eax,%eax
f010172c:	0f 85 c3 06 00 00    	jne    f0101df5 <mem_init+0xf16>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0101732:	83 ec 04             	sub    $0x4,%esp
f0101735:	6a 00                	push   $0x0
f0101737:	68 00 10 00 00       	push   $0x1000
f010173c:	ff 35 6c 89 11 f0    	pushl  0xf011896c
f0101742:	e8 f4 f5 ff ff       	call   f0100d3b <pgdir_walk>
f0101747:	83 c4 10             	add    $0x10,%esp
f010174a:	f6 00 02             	testb  $0x2,(%eax)
f010174d:	0f 84 bb 06 00 00    	je     f0101e0e <mem_init+0xf2f>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101753:	83 ec 04             	sub    $0x4,%esp
f0101756:	6a 00                	push   $0x0
f0101758:	68 00 10 00 00       	push   $0x1000
f010175d:	ff 35 6c 89 11 f0    	pushl  0xf011896c
f0101763:	e8 d3 f5 ff ff       	call   f0100d3b <pgdir_walk>
f0101768:	83 c4 10             	add    $0x10,%esp
f010176b:	f6 00 04             	testb  $0x4,(%eax)
f010176e:	0f 85 b3 06 00 00    	jne    f0101e27 <mem_init+0xf48>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0101774:	6a 02                	push   $0x2
f0101776:	68 00 00 40 00       	push   $0x400000
f010177b:	ff 75 d4             	pushl  -0x2c(%ebp)
f010177e:	ff 35 6c 89 11 f0    	pushl  0xf011896c
f0101784:	e8 d8 f6 ff ff       	call   f0100e61 <page_insert>
f0101789:	83 c4 10             	add    $0x10,%esp
f010178c:	85 c0                	test   %eax,%eax
f010178e:	0f 89 ac 06 00 00    	jns    f0101e40 <mem_init+0xf61>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0101794:	6a 02                	push   $0x2
f0101796:	68 00 10 00 00       	push   $0x1000
f010179b:	56                   	push   %esi
f010179c:	ff 35 6c 89 11 f0    	pushl  0xf011896c
f01017a2:	e8 ba f6 ff ff       	call   f0100e61 <page_insert>
f01017a7:	83 c4 10             	add    $0x10,%esp
f01017aa:	85 c0                	test   %eax,%eax
f01017ac:	0f 85 a7 06 00 00    	jne    f0101e59 <mem_init+0xf7a>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f01017b2:	83 ec 04             	sub    $0x4,%esp
f01017b5:	6a 00                	push   $0x0
f01017b7:	68 00 10 00 00       	push   $0x1000
f01017bc:	ff 35 6c 89 11 f0    	pushl  0xf011896c
f01017c2:	e8 74 f5 ff ff       	call   f0100d3b <pgdir_walk>
f01017c7:	83 c4 10             	add    $0x10,%esp
f01017ca:	f6 00 04             	testb  $0x4,(%eax)
f01017cd:	0f 85 9f 06 00 00    	jne    f0101e72 <mem_init+0xf93>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f01017d3:	a1 6c 89 11 f0       	mov    0xf011896c,%eax
f01017d8:	89 45 d0             	mov    %eax,-0x30(%ebp)
f01017db:	ba 00 00 00 00       	mov    $0x0,%edx
f01017e0:	e8 b0 f0 ff ff       	call   f0100895 <check_va2pa>
f01017e5:	89 f7                	mov    %esi,%edi
f01017e7:	2b 3d 70 89 11 f0    	sub    0xf0118970,%edi
f01017ed:	c1 ff 03             	sar    $0x3,%edi
f01017f0:	c1 e7 0c             	shl    $0xc,%edi
f01017f3:	39 f8                	cmp    %edi,%eax
f01017f5:	0f 85 90 06 00 00    	jne    f0101e8b <mem_init+0xfac>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f01017fb:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101800:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101803:	e8 8d f0 ff ff       	call   f0100895 <check_va2pa>
f0101808:	39 c7                	cmp    %eax,%edi
f010180a:	0f 85 94 06 00 00    	jne    f0101ea4 <mem_init+0xfc5>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0101810:	66 83 7e 04 02       	cmpw   $0x2,0x4(%esi)
f0101815:	0f 85 a2 06 00 00    	jne    f0101ebd <mem_init+0xfde>
	assert(pp2->pp_ref == 0);
f010181b:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101820:	0f 85 b0 06 00 00    	jne    f0101ed6 <mem_init+0xff7>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f0101826:	83 ec 0c             	sub    $0xc,%esp
f0101829:	6a 00                	push   $0x0
f010182b:	e8 35 f4 ff ff       	call   f0100c65 <page_alloc>
f0101830:	83 c4 10             	add    $0x10,%esp
f0101833:	85 c0                	test   %eax,%eax
f0101835:	0f 84 b4 06 00 00    	je     f0101eef <mem_init+0x1010>
f010183b:	39 c3                	cmp    %eax,%ebx
f010183d:	0f 85 ac 06 00 00    	jne    f0101eef <mem_init+0x1010>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f0101843:	83 ec 08             	sub    $0x8,%esp
f0101846:	6a 00                	push   $0x0
f0101848:	ff 35 6c 89 11 f0    	pushl  0xf011896c
f010184e:	e8 d3 f5 ff ff       	call   f0100e26 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101853:	8b 3d 6c 89 11 f0    	mov    0xf011896c,%edi
f0101859:	ba 00 00 00 00       	mov    $0x0,%edx
f010185e:	89 f8                	mov    %edi,%eax
f0101860:	e8 30 f0 ff ff       	call   f0100895 <check_va2pa>
f0101865:	83 c4 10             	add    $0x10,%esp
f0101868:	83 f8 ff             	cmp    $0xffffffff,%eax
f010186b:	0f 85 97 06 00 00    	jne    f0101f08 <mem_init+0x1029>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101871:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101876:	89 f8                	mov    %edi,%eax
f0101878:	e8 18 f0 ff ff       	call   f0100895 <check_va2pa>
f010187d:	89 c2                	mov    %eax,%edx
f010187f:	89 f0                	mov    %esi,%eax
f0101881:	2b 05 70 89 11 f0    	sub    0xf0118970,%eax
f0101887:	c1 f8 03             	sar    $0x3,%eax
f010188a:	c1 e0 0c             	shl    $0xc,%eax
f010188d:	39 c2                	cmp    %eax,%edx
f010188f:	0f 85 8c 06 00 00    	jne    f0101f21 <mem_init+0x1042>
	assert(pp1->pp_ref == 1);
f0101895:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f010189a:	0f 85 9a 06 00 00    	jne    f0101f3a <mem_init+0x105b>
	assert(pp2->pp_ref == 0);
f01018a0:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f01018a5:	0f 85 a8 06 00 00    	jne    f0101f53 <mem_init+0x1074>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f01018ab:	6a 00                	push   $0x0
f01018ad:	68 00 10 00 00       	push   $0x1000
f01018b2:	56                   	push   %esi
f01018b3:	57                   	push   %edi
f01018b4:	e8 a8 f5 ff ff       	call   f0100e61 <page_insert>
f01018b9:	83 c4 10             	add    $0x10,%esp
f01018bc:	85 c0                	test   %eax,%eax
f01018be:	0f 85 a8 06 00 00    	jne    f0101f6c <mem_init+0x108d>
	assert(pp1->pp_ref);
f01018c4:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f01018c9:	0f 84 b6 06 00 00    	je     f0101f85 <mem_init+0x10a6>
	assert(pp1->pp_link == NULL);
f01018cf:	83 3e 00             	cmpl   $0x0,(%esi)
f01018d2:	0f 85 c6 06 00 00    	jne    f0101f9e <mem_init+0x10bf>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f01018d8:	83 ec 08             	sub    $0x8,%esp
f01018db:	68 00 10 00 00       	push   $0x1000
f01018e0:	ff 35 6c 89 11 f0    	pushl  0xf011896c
f01018e6:	e8 3b f5 ff ff       	call   f0100e26 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f01018eb:	8b 3d 6c 89 11 f0    	mov    0xf011896c,%edi
f01018f1:	ba 00 00 00 00       	mov    $0x0,%edx
f01018f6:	89 f8                	mov    %edi,%eax
f01018f8:	e8 98 ef ff ff       	call   f0100895 <check_va2pa>
f01018fd:	83 c4 10             	add    $0x10,%esp
f0101900:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101903:	0f 85 ae 06 00 00    	jne    f0101fb7 <mem_init+0x10d8>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0101909:	ba 00 10 00 00       	mov    $0x1000,%edx
f010190e:	89 f8                	mov    %edi,%eax
f0101910:	e8 80 ef ff ff       	call   f0100895 <check_va2pa>
f0101915:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101918:	0f 85 b2 06 00 00    	jne    f0101fd0 <mem_init+0x10f1>
	assert(pp1->pp_ref == 0);
f010191e:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101923:	0f 85 c0 06 00 00    	jne    f0101fe9 <mem_init+0x110a>
	assert(pp2->pp_ref == 0);
f0101929:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f010192e:	0f 85 ce 06 00 00    	jne    f0102002 <mem_init+0x1123>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f0101934:	83 ec 0c             	sub    $0xc,%esp
f0101937:	6a 00                	push   $0x0
f0101939:	e8 27 f3 ff ff       	call   f0100c65 <page_alloc>
f010193e:	83 c4 10             	add    $0x10,%esp
f0101941:	85 c0                	test   %eax,%eax
f0101943:	0f 84 d2 06 00 00    	je     f010201b <mem_init+0x113c>
f0101949:	39 c6                	cmp    %eax,%esi
f010194b:	0f 85 ca 06 00 00    	jne    f010201b <mem_init+0x113c>

	// should be no free memory
	assert(!page_alloc(0));
f0101951:	83 ec 0c             	sub    $0xc,%esp
f0101954:	6a 00                	push   $0x0
f0101956:	e8 0a f3 ff ff       	call   f0100c65 <page_alloc>
f010195b:	83 c4 10             	add    $0x10,%esp
f010195e:	85 c0                	test   %eax,%eax
f0101960:	0f 85 ce 06 00 00    	jne    f0102034 <mem_init+0x1155>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101966:	8b 0d 6c 89 11 f0    	mov    0xf011896c,%ecx
f010196c:	8b 11                	mov    (%ecx),%edx
f010196e:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101974:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101977:	2b 05 70 89 11 f0    	sub    0xf0118970,%eax
f010197d:	c1 f8 03             	sar    $0x3,%eax
f0101980:	c1 e0 0c             	shl    $0xc,%eax
f0101983:	39 c2                	cmp    %eax,%edx
f0101985:	0f 85 c2 06 00 00    	jne    f010204d <mem_init+0x116e>
	kern_pgdir[0] = 0;
f010198b:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0101991:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101994:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101999:	0f 85 c7 06 00 00    	jne    f0102066 <mem_init+0x1187>
	pp0->pp_ref = 0;
f010199f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01019a2:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f01019a8:	83 ec 0c             	sub    $0xc,%esp
f01019ab:	50                   	push   %eax
f01019ac:	e8 29 f3 ff ff       	call   f0100cda <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f01019b1:	83 c4 0c             	add    $0xc,%esp
f01019b4:	6a 01                	push   $0x1
f01019b6:	68 00 10 40 00       	push   $0x401000
f01019bb:	ff 35 6c 89 11 f0    	pushl  0xf011896c
f01019c1:	e8 75 f3 ff ff       	call   f0100d3b <pgdir_walk>
f01019c6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f01019c9:	8b 0d 6c 89 11 f0    	mov    0xf011896c,%ecx
f01019cf:	8b 51 04             	mov    0x4(%ecx),%edx
f01019d2:	89 d7                	mov    %edx,%edi
f01019d4:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
f01019da:	89 7d d0             	mov    %edi,-0x30(%ebp)
	if (PGNUM(pa) >= npages)
f01019dd:	8b 3d 68 89 11 f0    	mov    0xf0118968,%edi
f01019e3:	c1 ea 0c             	shr    $0xc,%edx
f01019e6:	83 c4 10             	add    $0x10,%esp
f01019e9:	39 fa                	cmp    %edi,%edx
f01019eb:	0f 83 8e 06 00 00    	jae    f010207f <mem_init+0x11a0>
	assert(ptep == ptep1 + PTX(va));
f01019f1:	8b 55 d0             	mov    -0x30(%ebp),%edx
f01019f4:	81 ea fc ff ff 0f    	sub    $0xffffffc,%edx
f01019fa:	39 d0                	cmp    %edx,%eax
f01019fc:	0f 85 94 06 00 00    	jne    f0102096 <mem_init+0x11b7>
	kern_pgdir[PDX(va)] = 0;
f0101a02:	c7 41 04 00 00 00 00 	movl   $0x0,0x4(%ecx)
	pp0->pp_ref = 0;
f0101a09:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101a0c:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
	return (pp - pages) << PGSHIFT;
f0101a12:	2b 05 70 89 11 f0    	sub    0xf0118970,%eax
f0101a18:	c1 f8 03             	sar    $0x3,%eax
f0101a1b:	89 c2                	mov    %eax,%edx
f0101a1d:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0101a20:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0101a25:	39 c7                	cmp    %eax,%edi
f0101a27:	0f 86 82 06 00 00    	jbe    f01020af <mem_init+0x11d0>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f0101a2d:	83 ec 04             	sub    $0x4,%esp
f0101a30:	68 00 10 00 00       	push   $0x1000
f0101a35:	68 ff 00 00 00       	push   $0xff
	return (void *)(pa + KERNBASE);
f0101a3a:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f0101a40:	52                   	push   %edx
f0101a41:	e8 1d 17 00 00       	call   f0103163 <memset>
	page_free(pp0);
f0101a46:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0101a49:	89 3c 24             	mov    %edi,(%esp)
f0101a4c:	e8 89 f2 ff ff       	call   f0100cda <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f0101a51:	83 c4 0c             	add    $0xc,%esp
f0101a54:	6a 01                	push   $0x1
f0101a56:	6a 00                	push   $0x0
f0101a58:	ff 35 6c 89 11 f0    	pushl  0xf011896c
f0101a5e:	e8 d8 f2 ff ff       	call   f0100d3b <pgdir_walk>
	return (pp - pages) << PGSHIFT;
f0101a63:	89 f8                	mov    %edi,%eax
f0101a65:	2b 05 70 89 11 f0    	sub    0xf0118970,%eax
f0101a6b:	c1 f8 03             	sar    $0x3,%eax
f0101a6e:	89 c2                	mov    %eax,%edx
f0101a70:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0101a73:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0101a78:	83 c4 10             	add    $0x10,%esp
f0101a7b:	3b 05 68 89 11 f0    	cmp    0xf0118968,%eax
f0101a81:	0f 83 3a 06 00 00    	jae    f01020c1 <mem_init+0x11e2>
	return (void *)(pa + KERNBASE);
f0101a87:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f0101a8d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0101a90:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0101a96:	8b 38                	mov    (%eax),%edi
f0101a98:	83 e7 01             	and    $0x1,%edi
f0101a9b:	0f 85 32 06 00 00    	jne    f01020d3 <mem_init+0x11f4>
f0101aa1:	83 c0 04             	add    $0x4,%eax
	for(i=0; i<NPTENTRIES; i++)
f0101aa4:	39 d0                	cmp    %edx,%eax
f0101aa6:	75 ee                	jne    f0101a96 <mem_init+0xbb7>
	kern_pgdir[0] = 0;
f0101aa8:	a1 6c 89 11 f0       	mov    0xf011896c,%eax
f0101aad:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f0101ab3:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101ab6:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// give free list back
	page_free_list = fl;
f0101abc:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0101abf:	89 0d 3c 85 11 f0    	mov    %ecx,0xf011853c

	// free the pages we took
	page_free(pp0);
f0101ac5:	83 ec 0c             	sub    $0xc,%esp
f0101ac8:	50                   	push   %eax
f0101ac9:	e8 0c f2 ff ff       	call   f0100cda <page_free>
	page_free(pp1);
f0101ace:	89 34 24             	mov    %esi,(%esp)
f0101ad1:	e8 04 f2 ff ff       	call   f0100cda <page_free>
	page_free(pp2);
f0101ad6:	89 1c 24             	mov    %ebx,(%esp)
f0101ad9:	e8 fc f1 ff ff       	call   f0100cda <page_free>

	cprintf("check_page() succeeded!\n");
f0101ade:	c7 04 24 dc 3c 10 f0 	movl   $0xf0103cdc,(%esp)
f0101ae5:	e8 e9 0b 00 00       	call   f01026d3 <cprintf>
	pgdir = kern_pgdir;
f0101aea:	a1 6c 89 11 f0       	mov    0xf011896c,%eax
f0101aef:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f0101af2:	8b 35 68 89 11 f0    	mov    0xf0118968,%esi
f0101af8:	8d 04 f5 ff 0f 00 00 	lea    0xfff(,%esi,8),%eax
f0101aff:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0101b04:	89 45 d0             	mov    %eax,-0x30(%ebp)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0101b07:	a1 70 89 11 f0       	mov    0xf0118970,%eax
f0101b0c:	89 45 c4             	mov    %eax,-0x3c(%ebp)
	if ((uint32_t)kva < KERNBASE)
f0101b0f:	89 45 cc             	mov    %eax,-0x34(%ebp)
	return (physaddr_t)kva - KERNBASE;
f0101b12:	05 00 00 00 10       	add    $0x10000000,%eax
f0101b17:	89 45 c8             	mov    %eax,-0x38(%ebp)
	for (i = 0; i < n; i += PGSIZE)
f0101b1a:	83 c4 10             	add    $0x10,%esp
f0101b1d:	89 fb                	mov    %edi,%ebx
f0101b1f:	e9 e5 05 00 00       	jmp    f0102109 <mem_init+0x122a>
	assert(nfree == 0);
f0101b24:	68 05 3c 10 f0       	push   $0xf0103c05
f0101b29:	68 51 3a 10 f0       	push   $0xf0103a51
f0101b2e:	68 af 02 00 00       	push   $0x2af
f0101b33:	68 2b 3a 10 f0       	push   $0xf0103a2b
f0101b38:	e8 4e e5 ff ff       	call   f010008b <_panic>
	assert((pp0 = page_alloc(0)));
f0101b3d:	68 13 3b 10 f0       	push   $0xf0103b13
f0101b42:	68 51 3a 10 f0       	push   $0xf0103a51
f0101b47:	68 08 03 00 00       	push   $0x308
f0101b4c:	68 2b 3a 10 f0       	push   $0xf0103a2b
f0101b51:	e8 35 e5 ff ff       	call   f010008b <_panic>
	assert((pp1 = page_alloc(0)));
f0101b56:	68 29 3b 10 f0       	push   $0xf0103b29
f0101b5b:	68 51 3a 10 f0       	push   $0xf0103a51
f0101b60:	68 09 03 00 00       	push   $0x309
f0101b65:	68 2b 3a 10 f0       	push   $0xf0103a2b
f0101b6a:	e8 1c e5 ff ff       	call   f010008b <_panic>
	assert((pp2 = page_alloc(0)));
f0101b6f:	68 3f 3b 10 f0       	push   $0xf0103b3f
f0101b74:	68 51 3a 10 f0       	push   $0xf0103a51
f0101b79:	68 0a 03 00 00       	push   $0x30a
f0101b7e:	68 2b 3a 10 f0       	push   $0xf0103a2b
f0101b83:	e8 03 e5 ff ff       	call   f010008b <_panic>
	assert(pp1 && pp1 != pp0);
f0101b88:	68 55 3b 10 f0       	push   $0xf0103b55
f0101b8d:	68 51 3a 10 f0       	push   $0xf0103a51
f0101b92:	68 0d 03 00 00       	push   $0x30d
f0101b97:	68 2b 3a 10 f0       	push   $0xf0103a2b
f0101b9c:	e8 ea e4 ff ff       	call   f010008b <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101ba1:	68 b4 3e 10 f0       	push   $0xf0103eb4
f0101ba6:	68 51 3a 10 f0       	push   $0xf0103a51
f0101bab:	68 0e 03 00 00       	push   $0x30e
f0101bb0:	68 2b 3a 10 f0       	push   $0xf0103a2b
f0101bb5:	e8 d1 e4 ff ff       	call   f010008b <_panic>
	assert(!page_alloc(0));
f0101bba:	68 be 3b 10 f0       	push   $0xf0103bbe
f0101bbf:	68 51 3a 10 f0       	push   $0xf0103a51
f0101bc4:	68 15 03 00 00       	push   $0x315
f0101bc9:	68 2b 3a 10 f0       	push   $0xf0103a2b
f0101bce:	e8 b8 e4 ff ff       	call   f010008b <_panic>
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0101bd3:	68 f4 3e 10 f0       	push   $0xf0103ef4
f0101bd8:	68 51 3a 10 f0       	push   $0xf0103a51
f0101bdd:	68 18 03 00 00       	push   $0x318
f0101be2:	68 2b 3a 10 f0       	push   $0xf0103a2b
f0101be7:	e8 9f e4 ff ff       	call   f010008b <_panic>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0101bec:	68 2c 3f 10 f0       	push   $0xf0103f2c
f0101bf1:	68 51 3a 10 f0       	push   $0xf0103a51
f0101bf6:	68 1b 03 00 00       	push   $0x31b
f0101bfb:	68 2b 3a 10 f0       	push   $0xf0103a2b
f0101c00:	e8 86 e4 ff ff       	call   f010008b <_panic>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0101c05:	68 5c 3f 10 f0       	push   $0xf0103f5c
f0101c0a:	68 51 3a 10 f0       	push   $0xf0103a51
f0101c0f:	68 1f 03 00 00       	push   $0x31f
f0101c14:	68 2b 3a 10 f0       	push   $0xf0103a2b
f0101c19:	e8 6d e4 ff ff       	call   f010008b <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101c1e:	68 8c 3f 10 f0       	push   $0xf0103f8c
f0101c23:	68 51 3a 10 f0       	push   $0xf0103a51
f0101c28:	68 20 03 00 00       	push   $0x320
f0101c2d:	68 2b 3a 10 f0       	push   $0xf0103a2b
f0101c32:	e8 54 e4 ff ff       	call   f010008b <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0101c37:	68 b4 3f 10 f0       	push   $0xf0103fb4
f0101c3c:	68 51 3a 10 f0       	push   $0xf0103a51
f0101c41:	68 21 03 00 00       	push   $0x321
f0101c46:	68 2b 3a 10 f0       	push   $0xf0103a2b
f0101c4b:	e8 3b e4 ff ff       	call   f010008b <_panic>
	assert(pp1->pp_ref == 1);
f0101c50:	68 10 3c 10 f0       	push   $0xf0103c10
f0101c55:	68 51 3a 10 f0       	push   $0xf0103a51
f0101c5a:	68 22 03 00 00       	push   $0x322
f0101c5f:	68 2b 3a 10 f0       	push   $0xf0103a2b
f0101c64:	e8 22 e4 ff ff       	call   f010008b <_panic>
	assert(pp0->pp_ref == 1);
f0101c69:	68 21 3c 10 f0       	push   $0xf0103c21
f0101c6e:	68 51 3a 10 f0       	push   $0xf0103a51
f0101c73:	68 23 03 00 00       	push   $0x323
f0101c78:	68 2b 3a 10 f0       	push   $0xf0103a2b
f0101c7d:	e8 09 e4 ff ff       	call   f010008b <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101c82:	68 e4 3f 10 f0       	push   $0xf0103fe4
f0101c87:	68 51 3a 10 f0       	push   $0xf0103a51
f0101c8c:	68 26 03 00 00       	push   $0x326
f0101c91:	68 2b 3a 10 f0       	push   $0xf0103a2b
f0101c96:	e8 f0 e3 ff ff       	call   f010008b <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101c9b:	68 20 40 10 f0       	push   $0xf0104020
f0101ca0:	68 51 3a 10 f0       	push   $0xf0103a51
f0101ca5:	68 27 03 00 00       	push   $0x327
f0101caa:	68 2b 3a 10 f0       	push   $0xf0103a2b
f0101caf:	e8 d7 e3 ff ff       	call   f010008b <_panic>
	assert(pp2->pp_ref == 1);
f0101cb4:	68 32 3c 10 f0       	push   $0xf0103c32
f0101cb9:	68 51 3a 10 f0       	push   $0xf0103a51
f0101cbe:	68 28 03 00 00       	push   $0x328
f0101cc3:	68 2b 3a 10 f0       	push   $0xf0103a2b
f0101cc8:	e8 be e3 ff ff       	call   f010008b <_panic>
	assert(!page_alloc(0));
f0101ccd:	68 be 3b 10 f0       	push   $0xf0103bbe
f0101cd2:	68 51 3a 10 f0       	push   $0xf0103a51
f0101cd7:	68 2a 03 00 00       	push   $0x32a
f0101cdc:	68 2b 3a 10 f0       	push   $0xf0103a2b
f0101ce1:	e8 a5 e3 ff ff       	call   f010008b <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101ce6:	68 e4 3f 10 f0       	push   $0xf0103fe4
f0101ceb:	68 51 3a 10 f0       	push   $0xf0103a51
f0101cf0:	68 2d 03 00 00       	push   $0x32d
f0101cf5:	68 2b 3a 10 f0       	push   $0xf0103a2b
f0101cfa:	e8 8c e3 ff ff       	call   f010008b <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101cff:	68 20 40 10 f0       	push   $0xf0104020
f0101d04:	68 51 3a 10 f0       	push   $0xf0103a51
f0101d09:	68 2e 03 00 00       	push   $0x32e
f0101d0e:	68 2b 3a 10 f0       	push   $0xf0103a2b
f0101d13:	e8 73 e3 ff ff       	call   f010008b <_panic>
	assert(pp2->pp_ref == 1);
f0101d18:	68 32 3c 10 f0       	push   $0xf0103c32
f0101d1d:	68 51 3a 10 f0       	push   $0xf0103a51
f0101d22:	68 2f 03 00 00       	push   $0x32f
f0101d27:	68 2b 3a 10 f0       	push   $0xf0103a2b
f0101d2c:	e8 5a e3 ff ff       	call   f010008b <_panic>
	assert(!page_alloc(0));
f0101d31:	68 be 3b 10 f0       	push   $0xf0103bbe
f0101d36:	68 51 3a 10 f0       	push   $0xf0103a51
f0101d3b:	68 33 03 00 00       	push   $0x333
f0101d40:	68 2b 3a 10 f0       	push   $0xf0103a2b
f0101d45:	e8 41 e3 ff ff       	call   f010008b <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101d4a:	52                   	push   %edx
f0101d4b:	68 28 3d 10 f0       	push   $0xf0103d28
f0101d50:	68 36 03 00 00       	push   $0x336
f0101d55:	68 2b 3a 10 f0       	push   $0xf0103a2b
f0101d5a:	e8 2c e3 ff ff       	call   f010008b <_panic>
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0101d5f:	68 50 40 10 f0       	push   $0xf0104050
f0101d64:	68 51 3a 10 f0       	push   $0xf0103a51
f0101d69:	68 37 03 00 00       	push   $0x337
f0101d6e:	68 2b 3a 10 f0       	push   $0xf0103a2b
f0101d73:	e8 13 e3 ff ff       	call   f010008b <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0101d78:	68 90 40 10 f0       	push   $0xf0104090
f0101d7d:	68 51 3a 10 f0       	push   $0xf0103a51
f0101d82:	68 3a 03 00 00       	push   $0x33a
f0101d87:	68 2b 3a 10 f0       	push   $0xf0103a2b
f0101d8c:	e8 fa e2 ff ff       	call   f010008b <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101d91:	68 20 40 10 f0       	push   $0xf0104020
f0101d96:	68 51 3a 10 f0       	push   $0xf0103a51
f0101d9b:	68 3b 03 00 00       	push   $0x33b
f0101da0:	68 2b 3a 10 f0       	push   $0xf0103a2b
f0101da5:	e8 e1 e2 ff ff       	call   f010008b <_panic>
	assert(pp2->pp_ref == 1);
f0101daa:	68 32 3c 10 f0       	push   $0xf0103c32
f0101daf:	68 51 3a 10 f0       	push   $0xf0103a51
f0101db4:	68 3c 03 00 00       	push   $0x33c
f0101db9:	68 2b 3a 10 f0       	push   $0xf0103a2b
f0101dbe:	e8 c8 e2 ff ff       	call   f010008b <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0101dc3:	68 d0 40 10 f0       	push   $0xf01040d0
f0101dc8:	68 51 3a 10 f0       	push   $0xf0103a51
f0101dcd:	68 3d 03 00 00       	push   $0x33d
f0101dd2:	68 2b 3a 10 f0       	push   $0xf0103a2b
f0101dd7:	e8 af e2 ff ff       	call   f010008b <_panic>
	assert(kern_pgdir[0] & PTE_U);
f0101ddc:	68 43 3c 10 f0       	push   $0xf0103c43
f0101de1:	68 51 3a 10 f0       	push   $0xf0103a51
f0101de6:	68 3e 03 00 00       	push   $0x33e
f0101deb:	68 2b 3a 10 f0       	push   $0xf0103a2b
f0101df0:	e8 96 e2 ff ff       	call   f010008b <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101df5:	68 e4 3f 10 f0       	push   $0xf0103fe4
f0101dfa:	68 51 3a 10 f0       	push   $0xf0103a51
f0101dff:	68 41 03 00 00       	push   $0x341
f0101e04:	68 2b 3a 10 f0       	push   $0xf0103a2b
f0101e09:	e8 7d e2 ff ff       	call   f010008b <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0101e0e:	68 04 41 10 f0       	push   $0xf0104104
f0101e13:	68 51 3a 10 f0       	push   $0xf0103a51
f0101e18:	68 42 03 00 00       	push   $0x342
f0101e1d:	68 2b 3a 10 f0       	push   $0xf0103a2b
f0101e22:	e8 64 e2 ff ff       	call   f010008b <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101e27:	68 38 41 10 f0       	push   $0xf0104138
f0101e2c:	68 51 3a 10 f0       	push   $0xf0103a51
f0101e31:	68 43 03 00 00       	push   $0x343
f0101e36:	68 2b 3a 10 f0       	push   $0xf0103a2b
f0101e3b:	e8 4b e2 ff ff       	call   f010008b <_panic>
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0101e40:	68 70 41 10 f0       	push   $0xf0104170
f0101e45:	68 51 3a 10 f0       	push   $0xf0103a51
f0101e4a:	68 46 03 00 00       	push   $0x346
f0101e4f:	68 2b 3a 10 f0       	push   $0xf0103a2b
f0101e54:	e8 32 e2 ff ff       	call   f010008b <_panic>
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0101e59:	68 a8 41 10 f0       	push   $0xf01041a8
f0101e5e:	68 51 3a 10 f0       	push   $0xf0103a51
f0101e63:	68 49 03 00 00       	push   $0x349
f0101e68:	68 2b 3a 10 f0       	push   $0xf0103a2b
f0101e6d:	e8 19 e2 ff ff       	call   f010008b <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101e72:	68 38 41 10 f0       	push   $0xf0104138
f0101e77:	68 51 3a 10 f0       	push   $0xf0103a51
f0101e7c:	68 4a 03 00 00       	push   $0x34a
f0101e81:	68 2b 3a 10 f0       	push   $0xf0103a2b
f0101e86:	e8 00 e2 ff ff       	call   f010008b <_panic>
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0101e8b:	68 e4 41 10 f0       	push   $0xf01041e4
f0101e90:	68 51 3a 10 f0       	push   $0xf0103a51
f0101e95:	68 4d 03 00 00       	push   $0x34d
f0101e9a:	68 2b 3a 10 f0       	push   $0xf0103a2b
f0101e9f:	e8 e7 e1 ff ff       	call   f010008b <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101ea4:	68 10 42 10 f0       	push   $0xf0104210
f0101ea9:	68 51 3a 10 f0       	push   $0xf0103a51
f0101eae:	68 4e 03 00 00       	push   $0x34e
f0101eb3:	68 2b 3a 10 f0       	push   $0xf0103a2b
f0101eb8:	e8 ce e1 ff ff       	call   f010008b <_panic>
	assert(pp1->pp_ref == 2);
f0101ebd:	68 59 3c 10 f0       	push   $0xf0103c59
f0101ec2:	68 51 3a 10 f0       	push   $0xf0103a51
f0101ec7:	68 50 03 00 00       	push   $0x350
f0101ecc:	68 2b 3a 10 f0       	push   $0xf0103a2b
f0101ed1:	e8 b5 e1 ff ff       	call   f010008b <_panic>
	assert(pp2->pp_ref == 0);
f0101ed6:	68 6a 3c 10 f0       	push   $0xf0103c6a
f0101edb:	68 51 3a 10 f0       	push   $0xf0103a51
f0101ee0:	68 51 03 00 00       	push   $0x351
f0101ee5:	68 2b 3a 10 f0       	push   $0xf0103a2b
f0101eea:	e8 9c e1 ff ff       	call   f010008b <_panic>
	assert((pp = page_alloc(0)) && pp == pp2);
f0101eef:	68 40 42 10 f0       	push   $0xf0104240
f0101ef4:	68 51 3a 10 f0       	push   $0xf0103a51
f0101ef9:	68 54 03 00 00       	push   $0x354
f0101efe:	68 2b 3a 10 f0       	push   $0xf0103a2b
f0101f03:	e8 83 e1 ff ff       	call   f010008b <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101f08:	68 64 42 10 f0       	push   $0xf0104264
f0101f0d:	68 51 3a 10 f0       	push   $0xf0103a51
f0101f12:	68 58 03 00 00       	push   $0x358
f0101f17:	68 2b 3a 10 f0       	push   $0xf0103a2b
f0101f1c:	e8 6a e1 ff ff       	call   f010008b <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101f21:	68 10 42 10 f0       	push   $0xf0104210
f0101f26:	68 51 3a 10 f0       	push   $0xf0103a51
f0101f2b:	68 59 03 00 00       	push   $0x359
f0101f30:	68 2b 3a 10 f0       	push   $0xf0103a2b
f0101f35:	e8 51 e1 ff ff       	call   f010008b <_panic>
	assert(pp1->pp_ref == 1);
f0101f3a:	68 10 3c 10 f0       	push   $0xf0103c10
f0101f3f:	68 51 3a 10 f0       	push   $0xf0103a51
f0101f44:	68 5a 03 00 00       	push   $0x35a
f0101f49:	68 2b 3a 10 f0       	push   $0xf0103a2b
f0101f4e:	e8 38 e1 ff ff       	call   f010008b <_panic>
	assert(pp2->pp_ref == 0);
f0101f53:	68 6a 3c 10 f0       	push   $0xf0103c6a
f0101f58:	68 51 3a 10 f0       	push   $0xf0103a51
f0101f5d:	68 5b 03 00 00       	push   $0x35b
f0101f62:	68 2b 3a 10 f0       	push   $0xf0103a2b
f0101f67:	e8 1f e1 ff ff       	call   f010008b <_panic>
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f0101f6c:	68 88 42 10 f0       	push   $0xf0104288
f0101f71:	68 51 3a 10 f0       	push   $0xf0103a51
f0101f76:	68 5e 03 00 00       	push   $0x35e
f0101f7b:	68 2b 3a 10 f0       	push   $0xf0103a2b
f0101f80:	e8 06 e1 ff ff       	call   f010008b <_panic>
	assert(pp1->pp_ref);
f0101f85:	68 7b 3c 10 f0       	push   $0xf0103c7b
f0101f8a:	68 51 3a 10 f0       	push   $0xf0103a51
f0101f8f:	68 5f 03 00 00       	push   $0x35f
f0101f94:	68 2b 3a 10 f0       	push   $0xf0103a2b
f0101f99:	e8 ed e0 ff ff       	call   f010008b <_panic>
	assert(pp1->pp_link == NULL);
f0101f9e:	68 87 3c 10 f0       	push   $0xf0103c87
f0101fa3:	68 51 3a 10 f0       	push   $0xf0103a51
f0101fa8:	68 60 03 00 00       	push   $0x360
f0101fad:	68 2b 3a 10 f0       	push   $0xf0103a2b
f0101fb2:	e8 d4 e0 ff ff       	call   f010008b <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101fb7:	68 64 42 10 f0       	push   $0xf0104264
f0101fbc:	68 51 3a 10 f0       	push   $0xf0103a51
f0101fc1:	68 64 03 00 00       	push   $0x364
f0101fc6:	68 2b 3a 10 f0       	push   $0xf0103a2b
f0101fcb:	e8 bb e0 ff ff       	call   f010008b <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0101fd0:	68 c0 42 10 f0       	push   $0xf01042c0
f0101fd5:	68 51 3a 10 f0       	push   $0xf0103a51
f0101fda:	68 65 03 00 00       	push   $0x365
f0101fdf:	68 2b 3a 10 f0       	push   $0xf0103a2b
f0101fe4:	e8 a2 e0 ff ff       	call   f010008b <_panic>
	assert(pp1->pp_ref == 0);
f0101fe9:	68 9c 3c 10 f0       	push   $0xf0103c9c
f0101fee:	68 51 3a 10 f0       	push   $0xf0103a51
f0101ff3:	68 66 03 00 00       	push   $0x366
f0101ff8:	68 2b 3a 10 f0       	push   $0xf0103a2b
f0101ffd:	e8 89 e0 ff ff       	call   f010008b <_panic>
	assert(pp2->pp_ref == 0);
f0102002:	68 6a 3c 10 f0       	push   $0xf0103c6a
f0102007:	68 51 3a 10 f0       	push   $0xf0103a51
f010200c:	68 67 03 00 00       	push   $0x367
f0102011:	68 2b 3a 10 f0       	push   $0xf0103a2b
f0102016:	e8 70 e0 ff ff       	call   f010008b <_panic>
	assert((pp = page_alloc(0)) && pp == pp1);
f010201b:	68 e8 42 10 f0       	push   $0xf01042e8
f0102020:	68 51 3a 10 f0       	push   $0xf0103a51
f0102025:	68 6a 03 00 00       	push   $0x36a
f010202a:	68 2b 3a 10 f0       	push   $0xf0103a2b
f010202f:	e8 57 e0 ff ff       	call   f010008b <_panic>
	assert(!page_alloc(0));
f0102034:	68 be 3b 10 f0       	push   $0xf0103bbe
f0102039:	68 51 3a 10 f0       	push   $0xf0103a51
f010203e:	68 6d 03 00 00       	push   $0x36d
f0102043:	68 2b 3a 10 f0       	push   $0xf0103a2b
f0102048:	e8 3e e0 ff ff       	call   f010008b <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f010204d:	68 8c 3f 10 f0       	push   $0xf0103f8c
f0102052:	68 51 3a 10 f0       	push   $0xf0103a51
f0102057:	68 70 03 00 00       	push   $0x370
f010205c:	68 2b 3a 10 f0       	push   $0xf0103a2b
f0102061:	e8 25 e0 ff ff       	call   f010008b <_panic>
	assert(pp0->pp_ref == 1);
f0102066:	68 21 3c 10 f0       	push   $0xf0103c21
f010206b:	68 51 3a 10 f0       	push   $0xf0103a51
f0102070:	68 72 03 00 00       	push   $0x372
f0102075:	68 2b 3a 10 f0       	push   $0xf0103a2b
f010207a:	e8 0c e0 ff ff       	call   f010008b <_panic>
f010207f:	ff 75 d0             	pushl  -0x30(%ebp)
f0102082:	68 28 3d 10 f0       	push   $0xf0103d28
f0102087:	68 79 03 00 00       	push   $0x379
f010208c:	68 2b 3a 10 f0       	push   $0xf0103a2b
f0102091:	e8 f5 df ff ff       	call   f010008b <_panic>
	assert(ptep == ptep1 + PTX(va));
f0102096:	68 ad 3c 10 f0       	push   $0xf0103cad
f010209b:	68 51 3a 10 f0       	push   $0xf0103a51
f01020a0:	68 7a 03 00 00       	push   $0x37a
f01020a5:	68 2b 3a 10 f0       	push   $0xf0103a2b
f01020aa:	e8 dc df ff ff       	call   f010008b <_panic>
f01020af:	52                   	push   %edx
f01020b0:	68 28 3d 10 f0       	push   $0xf0103d28
f01020b5:	6a 52                	push   $0x52
f01020b7:	68 37 3a 10 f0       	push   $0xf0103a37
f01020bc:	e8 ca df ff ff       	call   f010008b <_panic>
f01020c1:	52                   	push   %edx
f01020c2:	68 28 3d 10 f0       	push   $0xf0103d28
f01020c7:	6a 52                	push   $0x52
f01020c9:	68 37 3a 10 f0       	push   $0xf0103a37
f01020ce:	e8 b8 df ff ff       	call   f010008b <_panic>
		assert((ptep[i] & PTE_P) == 0);
f01020d3:	68 c5 3c 10 f0       	push   $0xf0103cc5
f01020d8:	68 51 3a 10 f0       	push   $0xf0103a51
f01020dd:	68 84 03 00 00       	push   $0x384
f01020e2:	68 2b 3a 10 f0       	push   $0xf0103a2b
f01020e7:	e8 9f df ff ff       	call   f010008b <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01020ec:	ff 75 c4             	pushl  -0x3c(%ebp)
f01020ef:	68 90 3e 10 f0       	push   $0xf0103e90
f01020f4:	68 c7 02 00 00       	push   $0x2c7
f01020f9:	68 2b 3a 10 f0       	push   $0xf0103a2b
f01020fe:	e8 88 df ff ff       	call   f010008b <_panic>
	for (i = 0; i < n; i += PGSIZE)
f0102103:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102109:	39 5d d0             	cmp    %ebx,-0x30(%ebp)
f010210c:	76 3a                	jbe    f0102148 <mem_init+0x1269>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f010210e:	8d 93 00 00 00 ef    	lea    -0x11000000(%ebx),%edx
f0102114:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102117:	e8 79 e7 ff ff       	call   f0100895 <check_va2pa>
	if ((uint32_t)kva < KERNBASE)
f010211c:	81 7d cc ff ff ff ef 	cmpl   $0xefffffff,-0x34(%ebp)
f0102123:	76 c7                	jbe    f01020ec <mem_init+0x120d>
f0102125:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0102128:	8d 14 0b             	lea    (%ebx,%ecx,1),%edx
f010212b:	39 c2                	cmp    %eax,%edx
f010212d:	74 d4                	je     f0102103 <mem_init+0x1224>
f010212f:	68 0c 43 10 f0       	push   $0xf010430c
f0102134:	68 51 3a 10 f0       	push   $0xf0103a51
f0102139:	68 c7 02 00 00       	push   $0x2c7
f010213e:	68 2b 3a 10 f0       	push   $0xf0103a2b
f0102143:	e8 43 df ff ff       	call   f010008b <_panic>
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102148:	c1 e6 0c             	shl    $0xc,%esi
f010214b:	89 fb                	mov    %edi,%ebx
f010214d:	eb 06                	jmp    f0102155 <mem_init+0x1276>
f010214f:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102155:	39 f3                	cmp    %esi,%ebx
f0102157:	73 2b                	jae    f0102184 <mem_init+0x12a5>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0102159:	8d 93 00 00 00 f0    	lea    -0x10000000(%ebx),%edx
f010215f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102162:	e8 2e e7 ff ff       	call   f0100895 <check_va2pa>
f0102167:	39 c3                	cmp    %eax,%ebx
f0102169:	74 e4                	je     f010214f <mem_init+0x1270>
f010216b:	68 40 43 10 f0       	push   $0xf0104340
f0102170:	68 51 3a 10 f0       	push   $0xf0103a51
f0102175:	68 cc 02 00 00       	push   $0x2cc
f010217a:	68 2b 3a 10 f0       	push   $0xf0103a2b
f010217f:	e8 07 df ff ff       	call   f010008b <_panic>
f0102184:	bb 00 80 ff ef       	mov    $0xefff8000,%ebx
f0102189:	be 00 e0 10 f0       	mov    $0xf010e000,%esi
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f010218e:	89 da                	mov    %ebx,%edx
f0102190:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102193:	e8 fd e6 ff ff       	call   f0100895 <check_va2pa>
f0102198:	81 fe ff ff ff ef    	cmp    $0xefffffff,%esi
f010219e:	76 2f                	jbe    f01021cf <mem_init+0x12f0>
f01021a0:	8d 93 00 60 11 10    	lea    0x10116000(%ebx),%edx
f01021a6:	39 d0                	cmp    %edx,%eax
f01021a8:	75 3e                	jne    f01021e8 <mem_init+0x1309>
f01021aa:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
f01021b0:	81 fb 00 00 00 f0    	cmp    $0xf0000000,%ebx
f01021b6:	75 d6                	jne    f010218e <mem_init+0x12af>
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f01021b8:	ba 00 00 c0 ef       	mov    $0xefc00000,%edx
f01021bd:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01021c0:	e8 d0 e6 ff ff       	call   f0100895 <check_va2pa>
f01021c5:	83 f8 ff             	cmp    $0xffffffff,%eax
f01021c8:	75 37                	jne    f0102201 <mem_init+0x1322>
f01021ca:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01021cd:	eb 76                	jmp    f0102245 <mem_init+0x1366>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01021cf:	68 00 e0 10 f0       	push   $0xf010e000
f01021d4:	68 90 3e 10 f0       	push   $0xf0103e90
f01021d9:	68 d0 02 00 00       	push   $0x2d0
f01021de:	68 2b 3a 10 f0       	push   $0xf0103a2b
f01021e3:	e8 a3 de ff ff       	call   f010008b <_panic>
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f01021e8:	68 68 43 10 f0       	push   $0xf0104368
f01021ed:	68 51 3a 10 f0       	push   $0xf0103a51
f01021f2:	68 d0 02 00 00       	push   $0x2d0
f01021f7:	68 2b 3a 10 f0       	push   $0xf0103a2b
f01021fc:	e8 8a de ff ff       	call   f010008b <_panic>
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f0102201:	68 b0 43 10 f0       	push   $0xf01043b0
f0102206:	68 51 3a 10 f0       	push   $0xf0103a51
f010220b:	68 d1 02 00 00       	push   $0x2d1
f0102210:	68 2b 3a 10 f0       	push   $0xf0103a2b
f0102215:	e8 71 de ff ff       	call   f010008b <_panic>
		switch (i) {
f010221a:	81 ff bf 03 00 00    	cmp    $0x3bf,%edi
f0102220:	75 23                	jne    f0102245 <mem_init+0x1366>
			assert(pgdir[i] & PTE_P);
f0102222:	f6 04 b8 01          	testb  $0x1,(%eax,%edi,4)
f0102226:	74 44                	je     f010226c <mem_init+0x138d>
	for (i = 0; i < NPDENTRIES; i++) {
f0102228:	47                   	inc    %edi
f0102229:	81 ff ff 03 00 00    	cmp    $0x3ff,%edi
f010222f:	0f 87 8f 00 00 00    	ja     f01022c4 <mem_init+0x13e5>
		switch (i) {
f0102235:	81 ff bd 03 00 00    	cmp    $0x3bd,%edi
f010223b:	77 dd                	ja     f010221a <mem_init+0x133b>
f010223d:	81 ff bb 03 00 00    	cmp    $0x3bb,%edi
f0102243:	77 dd                	ja     f0102222 <mem_init+0x1343>
			if (i >= PDX(KERNBASE)) {
f0102245:	81 ff bf 03 00 00    	cmp    $0x3bf,%edi
f010224b:	77 38                	ja     f0102285 <mem_init+0x13a6>
				assert(pgdir[i] == 0);
f010224d:	83 3c b8 00          	cmpl   $0x0,(%eax,%edi,4)
f0102251:	74 d5                	je     f0102228 <mem_init+0x1349>
f0102253:	68 17 3d 10 f0       	push   $0xf0103d17
f0102258:	68 51 3a 10 f0       	push   $0xf0103a51
f010225d:	68 e0 02 00 00       	push   $0x2e0
f0102262:	68 2b 3a 10 f0       	push   $0xf0103a2b
f0102267:	e8 1f de ff ff       	call   f010008b <_panic>
			assert(pgdir[i] & PTE_P);
f010226c:	68 f5 3c 10 f0       	push   $0xf0103cf5
f0102271:	68 51 3a 10 f0       	push   $0xf0103a51
f0102276:	68 d9 02 00 00       	push   $0x2d9
f010227b:	68 2b 3a 10 f0       	push   $0xf0103a2b
f0102280:	e8 06 de ff ff       	call   f010008b <_panic>
				assert(pgdir[i] & PTE_P);
f0102285:	8b 14 b8             	mov    (%eax,%edi,4),%edx
f0102288:	f6 c2 01             	test   $0x1,%dl
f010228b:	74 1e                	je     f01022ab <mem_init+0x13cc>
				assert(pgdir[i] & PTE_W);
f010228d:	f6 c2 02             	test   $0x2,%dl
f0102290:	75 96                	jne    f0102228 <mem_init+0x1349>
f0102292:	68 06 3d 10 f0       	push   $0xf0103d06
f0102297:	68 51 3a 10 f0       	push   $0xf0103a51
f010229c:	68 de 02 00 00       	push   $0x2de
f01022a1:	68 2b 3a 10 f0       	push   $0xf0103a2b
f01022a6:	e8 e0 dd ff ff       	call   f010008b <_panic>
				assert(pgdir[i] & PTE_P);
f01022ab:	68 f5 3c 10 f0       	push   $0xf0103cf5
f01022b0:	68 51 3a 10 f0       	push   $0xf0103a51
f01022b5:	68 dd 02 00 00       	push   $0x2dd
f01022ba:	68 2b 3a 10 f0       	push   $0xf0103a2b
f01022bf:	e8 c7 dd ff ff       	call   f010008b <_panic>
	cprintf("check_kern_pgdir() succeeded!\n");
f01022c4:	83 ec 0c             	sub    $0xc,%esp
f01022c7:	68 e0 43 10 f0       	push   $0xf01043e0
f01022cc:	e8 02 04 00 00       	call   f01026d3 <cprintf>
	lcr3(PADDR(kern_pgdir));
f01022d1:	a1 6c 89 11 f0       	mov    0xf011896c,%eax
	if ((uint32_t)kva < KERNBASE)
f01022d6:	83 c4 10             	add    $0x10,%esp
f01022d9:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01022de:	0f 86 06 02 00 00    	jbe    f01024ea <mem_init+0x160b>
	return (physaddr_t)kva - KERNBASE;
f01022e4:	05 00 00 00 10       	add    $0x10000000,%eax
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f01022e9:	0f 22 d8             	mov    %eax,%cr3
	check_page_free_list(0);
f01022ec:	b8 00 00 00 00       	mov    $0x0,%eax
f01022f1:	e8 ff e5 ff ff       	call   f01008f5 <check_page_free_list>
	asm volatile("movl %%cr0,%0" : "=r" (val));
f01022f6:	0f 20 c0             	mov    %cr0,%eax
	cr0 &= ~(CR0_TS|CR0_EM);
f01022f9:	83 e0 f3             	and    $0xfffffff3,%eax
f01022fc:	0d 23 00 05 80       	or     $0x80050023,%eax
	asm volatile("movl %0,%%cr0" : : "r" (val));
f0102301:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0102304:	83 ec 0c             	sub    $0xc,%esp
f0102307:	6a 00                	push   $0x0
f0102309:	e8 57 e9 ff ff       	call   f0100c65 <page_alloc>
f010230e:	89 c6                	mov    %eax,%esi
f0102310:	83 c4 10             	add    $0x10,%esp
f0102313:	85 c0                	test   %eax,%eax
f0102315:	0f 84 e4 01 00 00    	je     f01024ff <mem_init+0x1620>
	assert((pp1 = page_alloc(0)));
f010231b:	83 ec 0c             	sub    $0xc,%esp
f010231e:	6a 00                	push   $0x0
f0102320:	e8 40 e9 ff ff       	call   f0100c65 <page_alloc>
f0102325:	89 c7                	mov    %eax,%edi
f0102327:	83 c4 10             	add    $0x10,%esp
f010232a:	85 c0                	test   %eax,%eax
f010232c:	0f 84 e6 01 00 00    	je     f0102518 <mem_init+0x1639>
	assert((pp2 = page_alloc(0)));
f0102332:	83 ec 0c             	sub    $0xc,%esp
f0102335:	6a 00                	push   $0x0
f0102337:	e8 29 e9 ff ff       	call   f0100c65 <page_alloc>
f010233c:	89 c3                	mov    %eax,%ebx
f010233e:	83 c4 10             	add    $0x10,%esp
f0102341:	85 c0                	test   %eax,%eax
f0102343:	0f 84 e8 01 00 00    	je     f0102531 <mem_init+0x1652>
	page_free(pp0);
f0102349:	83 ec 0c             	sub    $0xc,%esp
f010234c:	56                   	push   %esi
f010234d:	e8 88 e9 ff ff       	call   f0100cda <page_free>
	return (pp - pages) << PGSHIFT;
f0102352:	89 f8                	mov    %edi,%eax
f0102354:	2b 05 70 89 11 f0    	sub    0xf0118970,%eax
f010235a:	c1 f8 03             	sar    $0x3,%eax
f010235d:	89 c2                	mov    %eax,%edx
f010235f:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0102362:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0102367:	83 c4 10             	add    $0x10,%esp
f010236a:	3b 05 68 89 11 f0    	cmp    0xf0118968,%eax
f0102370:	0f 83 d4 01 00 00    	jae    f010254a <mem_init+0x166b>
	memset(page2kva(pp1), 1, PGSIZE);
f0102376:	83 ec 04             	sub    $0x4,%esp
f0102379:	68 00 10 00 00       	push   $0x1000
f010237e:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f0102380:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f0102386:	52                   	push   %edx
f0102387:	e8 d7 0d 00 00       	call   f0103163 <memset>
	return (pp - pages) << PGSHIFT;
f010238c:	89 d8                	mov    %ebx,%eax
f010238e:	2b 05 70 89 11 f0    	sub    0xf0118970,%eax
f0102394:	c1 f8 03             	sar    $0x3,%eax
f0102397:	89 c2                	mov    %eax,%edx
f0102399:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f010239c:	25 ff ff 0f 00       	and    $0xfffff,%eax
f01023a1:	83 c4 10             	add    $0x10,%esp
f01023a4:	3b 05 68 89 11 f0    	cmp    0xf0118968,%eax
f01023aa:	0f 83 ac 01 00 00    	jae    f010255c <mem_init+0x167d>
	memset(page2kva(pp2), 2, PGSIZE);
f01023b0:	83 ec 04             	sub    $0x4,%esp
f01023b3:	68 00 10 00 00       	push   $0x1000
f01023b8:	6a 02                	push   $0x2
	return (void *)(pa + KERNBASE);
f01023ba:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f01023c0:	52                   	push   %edx
f01023c1:	e8 9d 0d 00 00       	call   f0103163 <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f01023c6:	6a 02                	push   $0x2
f01023c8:	68 00 10 00 00       	push   $0x1000
f01023cd:	57                   	push   %edi
f01023ce:	ff 35 6c 89 11 f0    	pushl  0xf011896c
f01023d4:	e8 88 ea ff ff       	call   f0100e61 <page_insert>
	assert(pp1->pp_ref == 1);
f01023d9:	83 c4 20             	add    $0x20,%esp
f01023dc:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f01023e1:	0f 85 87 01 00 00    	jne    f010256e <mem_init+0x168f>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f01023e7:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f01023ee:	01 01 01 
f01023f1:	0f 85 90 01 00 00    	jne    f0102587 <mem_init+0x16a8>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f01023f7:	6a 02                	push   $0x2
f01023f9:	68 00 10 00 00       	push   $0x1000
f01023fe:	53                   	push   %ebx
f01023ff:	ff 35 6c 89 11 f0    	pushl  0xf011896c
f0102405:	e8 57 ea ff ff       	call   f0100e61 <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f010240a:	83 c4 10             	add    $0x10,%esp
f010240d:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f0102414:	02 02 02 
f0102417:	0f 85 83 01 00 00    	jne    f01025a0 <mem_init+0x16c1>
	assert(pp2->pp_ref == 1);
f010241d:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102422:	0f 85 91 01 00 00    	jne    f01025b9 <mem_init+0x16da>
	assert(pp1->pp_ref == 0);
f0102428:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f010242d:	0f 85 9f 01 00 00    	jne    f01025d2 <mem_init+0x16f3>
	*(uint32_t *)PGSIZE = 0x03030303U;
f0102433:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f010243a:	03 03 03 
	return (pp - pages) << PGSHIFT;
f010243d:	89 d8                	mov    %ebx,%eax
f010243f:	2b 05 70 89 11 f0    	sub    0xf0118970,%eax
f0102445:	c1 f8 03             	sar    $0x3,%eax
f0102448:	89 c2                	mov    %eax,%edx
f010244a:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f010244d:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0102452:	3b 05 68 89 11 f0    	cmp    0xf0118968,%eax
f0102458:	0f 83 8d 01 00 00    	jae    f01025eb <mem_init+0x170c>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f010245e:	81 ba 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%edx)
f0102465:	03 03 03 
f0102468:	0f 85 8f 01 00 00    	jne    f01025fd <mem_init+0x171e>
	page_remove(kern_pgdir, (void*) PGSIZE);
f010246e:	83 ec 08             	sub    $0x8,%esp
f0102471:	68 00 10 00 00       	push   $0x1000
f0102476:	ff 35 6c 89 11 f0    	pushl  0xf011896c
f010247c:	e8 a5 e9 ff ff       	call   f0100e26 <page_remove>
	assert(pp2->pp_ref == 0);
f0102481:	83 c4 10             	add    $0x10,%esp
f0102484:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102489:	0f 85 87 01 00 00    	jne    f0102616 <mem_init+0x1737>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f010248f:	8b 0d 6c 89 11 f0    	mov    0xf011896c,%ecx
f0102495:	8b 11                	mov    (%ecx),%edx
f0102497:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
	return (pp - pages) << PGSHIFT;
f010249d:	89 f0                	mov    %esi,%eax
f010249f:	2b 05 70 89 11 f0    	sub    0xf0118970,%eax
f01024a5:	c1 f8 03             	sar    $0x3,%eax
f01024a8:	c1 e0 0c             	shl    $0xc,%eax
f01024ab:	39 c2                	cmp    %eax,%edx
f01024ad:	0f 85 7c 01 00 00    	jne    f010262f <mem_init+0x1750>
	kern_pgdir[0] = 0;
f01024b3:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f01024b9:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f01024be:	0f 85 84 01 00 00    	jne    f0102648 <mem_init+0x1769>
	pp0->pp_ref = 0;
f01024c4:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// free the pages we took
	page_free(pp0);
f01024ca:	83 ec 0c             	sub    $0xc,%esp
f01024cd:	56                   	push   %esi
f01024ce:	e8 07 e8 ff ff       	call   f0100cda <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f01024d3:	c7 04 24 74 44 10 f0 	movl   $0xf0104474,(%esp)
f01024da:	e8 f4 01 00 00       	call   f01026d3 <cprintf>
}
f01024df:	83 c4 10             	add    $0x10,%esp
f01024e2:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01024e5:	5b                   	pop    %ebx
f01024e6:	5e                   	pop    %esi
f01024e7:	5f                   	pop    %edi
f01024e8:	5d                   	pop    %ebp
f01024e9:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01024ea:	50                   	push   %eax
f01024eb:	68 90 3e 10 f0       	push   $0xf0103e90
f01024f0:	68 d8 00 00 00       	push   $0xd8
f01024f5:	68 2b 3a 10 f0       	push   $0xf0103a2b
f01024fa:	e8 8c db ff ff       	call   f010008b <_panic>
	assert((pp0 = page_alloc(0)));
f01024ff:	68 13 3b 10 f0       	push   $0xf0103b13
f0102504:	68 51 3a 10 f0       	push   $0xf0103a51
f0102509:	68 9f 03 00 00       	push   $0x39f
f010250e:	68 2b 3a 10 f0       	push   $0xf0103a2b
f0102513:	e8 73 db ff ff       	call   f010008b <_panic>
	assert((pp1 = page_alloc(0)));
f0102518:	68 29 3b 10 f0       	push   $0xf0103b29
f010251d:	68 51 3a 10 f0       	push   $0xf0103a51
f0102522:	68 a0 03 00 00       	push   $0x3a0
f0102527:	68 2b 3a 10 f0       	push   $0xf0103a2b
f010252c:	e8 5a db ff ff       	call   f010008b <_panic>
	assert((pp2 = page_alloc(0)));
f0102531:	68 3f 3b 10 f0       	push   $0xf0103b3f
f0102536:	68 51 3a 10 f0       	push   $0xf0103a51
f010253b:	68 a1 03 00 00       	push   $0x3a1
f0102540:	68 2b 3a 10 f0       	push   $0xf0103a2b
f0102545:	e8 41 db ff ff       	call   f010008b <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010254a:	52                   	push   %edx
f010254b:	68 28 3d 10 f0       	push   $0xf0103d28
f0102550:	6a 52                	push   $0x52
f0102552:	68 37 3a 10 f0       	push   $0xf0103a37
f0102557:	e8 2f db ff ff       	call   f010008b <_panic>
f010255c:	52                   	push   %edx
f010255d:	68 28 3d 10 f0       	push   $0xf0103d28
f0102562:	6a 52                	push   $0x52
f0102564:	68 37 3a 10 f0       	push   $0xf0103a37
f0102569:	e8 1d db ff ff       	call   f010008b <_panic>
	assert(pp1->pp_ref == 1);
f010256e:	68 10 3c 10 f0       	push   $0xf0103c10
f0102573:	68 51 3a 10 f0       	push   $0xf0103a51
f0102578:	68 a6 03 00 00       	push   $0x3a6
f010257d:	68 2b 3a 10 f0       	push   $0xf0103a2b
f0102582:	e8 04 db ff ff       	call   f010008b <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102587:	68 00 44 10 f0       	push   $0xf0104400
f010258c:	68 51 3a 10 f0       	push   $0xf0103a51
f0102591:	68 a7 03 00 00       	push   $0x3a7
f0102596:	68 2b 3a 10 f0       	push   $0xf0103a2b
f010259b:	e8 eb da ff ff       	call   f010008b <_panic>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f01025a0:	68 24 44 10 f0       	push   $0xf0104424
f01025a5:	68 51 3a 10 f0       	push   $0xf0103a51
f01025aa:	68 a9 03 00 00       	push   $0x3a9
f01025af:	68 2b 3a 10 f0       	push   $0xf0103a2b
f01025b4:	e8 d2 da ff ff       	call   f010008b <_panic>
	assert(pp2->pp_ref == 1);
f01025b9:	68 32 3c 10 f0       	push   $0xf0103c32
f01025be:	68 51 3a 10 f0       	push   $0xf0103a51
f01025c3:	68 aa 03 00 00       	push   $0x3aa
f01025c8:	68 2b 3a 10 f0       	push   $0xf0103a2b
f01025cd:	e8 b9 da ff ff       	call   f010008b <_panic>
	assert(pp1->pp_ref == 0);
f01025d2:	68 9c 3c 10 f0       	push   $0xf0103c9c
f01025d7:	68 51 3a 10 f0       	push   $0xf0103a51
f01025dc:	68 ab 03 00 00       	push   $0x3ab
f01025e1:	68 2b 3a 10 f0       	push   $0xf0103a2b
f01025e6:	e8 a0 da ff ff       	call   f010008b <_panic>
f01025eb:	52                   	push   %edx
f01025ec:	68 28 3d 10 f0       	push   $0xf0103d28
f01025f1:	6a 52                	push   $0x52
f01025f3:	68 37 3a 10 f0       	push   $0xf0103a37
f01025f8:	e8 8e da ff ff       	call   f010008b <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f01025fd:	68 48 44 10 f0       	push   $0xf0104448
f0102602:	68 51 3a 10 f0       	push   $0xf0103a51
f0102607:	68 ad 03 00 00       	push   $0x3ad
f010260c:	68 2b 3a 10 f0       	push   $0xf0103a2b
f0102611:	e8 75 da ff ff       	call   f010008b <_panic>
	assert(pp2->pp_ref == 0);
f0102616:	68 6a 3c 10 f0       	push   $0xf0103c6a
f010261b:	68 51 3a 10 f0       	push   $0xf0103a51
f0102620:	68 af 03 00 00       	push   $0x3af
f0102625:	68 2b 3a 10 f0       	push   $0xf0103a2b
f010262a:	e8 5c da ff ff       	call   f010008b <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f010262f:	68 8c 3f 10 f0       	push   $0xf0103f8c
f0102634:	68 51 3a 10 f0       	push   $0xf0103a51
f0102639:	68 b2 03 00 00       	push   $0x3b2
f010263e:	68 2b 3a 10 f0       	push   $0xf0103a2b
f0102643:	e8 43 da ff ff       	call   f010008b <_panic>
	assert(pp0->pp_ref == 1);
f0102648:	68 21 3c 10 f0       	push   $0xf0103c21
f010264d:	68 51 3a 10 f0       	push   $0xf0103a51
f0102652:	68 b4 03 00 00       	push   $0x3b4
f0102657:	68 2b 3a 10 f0       	push   $0xf0103a2b
f010265c:	e8 2a da ff ff       	call   f010008b <_panic>

f0102661 <tlb_invalidate>:
{
f0102661:	55                   	push   %ebp
f0102662:	89 e5                	mov    %esp,%ebp
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0102664:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102667:	0f 01 38             	invlpg (%eax)
}
f010266a:	5d                   	pop    %ebp
f010266b:	c3                   	ret    

f010266c <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f010266c:	55                   	push   %ebp
f010266d:	89 e5                	mov    %esp,%ebp
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010266f:	8b 45 08             	mov    0x8(%ebp),%eax
f0102672:	ba 70 00 00 00       	mov    $0x70,%edx
f0102677:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0102678:	ba 71 00 00 00       	mov    $0x71,%edx
f010267d:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f010267e:	0f b6 c0             	movzbl %al,%eax
}
f0102681:	5d                   	pop    %ebp
f0102682:	c3                   	ret    

f0102683 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0102683:	55                   	push   %ebp
f0102684:	89 e5                	mov    %esp,%ebp
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0102686:	8b 45 08             	mov    0x8(%ebp),%eax
f0102689:	ba 70 00 00 00       	mov    $0x70,%edx
f010268e:	ee                   	out    %al,(%dx)
f010268f:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102692:	ba 71 00 00 00       	mov    $0x71,%edx
f0102697:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0102698:	5d                   	pop    %ebp
f0102699:	c3                   	ret    

f010269a <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f010269a:	55                   	push   %ebp
f010269b:	89 e5                	mov    %esp,%ebp
f010269d:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f01026a0:	ff 75 08             	pushl  0x8(%ebp)
f01026a3:	e8 1e df ff ff       	call   f01005c6 <cputchar>
	*cnt++;
}
f01026a8:	83 c4 10             	add    $0x10,%esp
f01026ab:	c9                   	leave  
f01026ac:	c3                   	ret    

f01026ad <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f01026ad:	55                   	push   %ebp
f01026ae:	89 e5                	mov    %esp,%ebp
f01026b0:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f01026b3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f01026ba:	ff 75 0c             	pushl  0xc(%ebp)
f01026bd:	ff 75 08             	pushl  0x8(%ebp)
f01026c0:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01026c3:	50                   	push   %eax
f01026c4:	68 9a 26 10 f0       	push   $0xf010269a
f01026c9:	e8 cc 03 00 00       	call   f0102a9a <vprintfmt>
	return cnt;
}
f01026ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01026d1:	c9                   	leave  
f01026d2:	c3                   	ret    

f01026d3 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f01026d3:	55                   	push   %ebp
f01026d4:	89 e5                	mov    %esp,%ebp
f01026d6:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f01026d9:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f01026dc:	50                   	push   %eax
f01026dd:	ff 75 08             	pushl  0x8(%ebp)
f01026e0:	e8 c8 ff ff ff       	call   f01026ad <vcprintf>
	va_end(ap);

	return cnt;
}
f01026e5:	c9                   	leave  
f01026e6:	c3                   	ret    

f01026e7 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f01026e7:	55                   	push   %ebp
f01026e8:	89 e5                	mov    %esp,%ebp
f01026ea:	57                   	push   %edi
f01026eb:	56                   	push   %esi
f01026ec:	53                   	push   %ebx
f01026ed:	83 ec 14             	sub    $0x14,%esp
f01026f0:	89 45 f0             	mov    %eax,-0x10(%ebp)
f01026f3:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f01026f6:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f01026f9:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f01026fc:	8b 1a                	mov    (%edx),%ebx
f01026fe:	8b 39                	mov    (%ecx),%edi
f0102700:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f0102707:	eb 27                	jmp    f0102730 <stab_binsearch+0x49>

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0102709:	8b 5d ec             	mov    -0x14(%ebp),%ebx
f010270c:	43                   	inc    %ebx
			continue;
f010270d:	eb 21                	jmp    f0102730 <stab_binsearch+0x49>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f010270f:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0102712:	01 c2                	add    %eax,%edx
f0102714:	8b 4d f0             	mov    -0x10(%ebp),%ecx
f0102717:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f010271b:	3b 55 0c             	cmp    0xc(%ebp),%edx
f010271e:	73 44                	jae    f0102764 <stab_binsearch+0x7d>
			*region_left = m;
f0102720:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0102723:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f0102725:	8b 5d ec             	mov    -0x14(%ebp),%ebx
f0102728:	43                   	inc    %ebx
		any_matches = 1;
f0102729:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
	while (l <= r) {
f0102730:	39 fb                	cmp    %edi,%ebx
f0102732:	7f 59                	jg     f010278d <stab_binsearch+0xa6>
		int true_m = (l + r) / 2, m = true_m;
f0102734:	8d 14 3b             	lea    (%ebx,%edi,1),%edx
f0102737:	89 d0                	mov    %edx,%eax
f0102739:	c1 e8 1f             	shr    $0x1f,%eax
f010273c:	01 d0                	add    %edx,%eax
f010273e:	89 c1                	mov    %eax,%ecx
f0102740:	d1 f9                	sar    %ecx
f0102742:	89 4d ec             	mov    %ecx,-0x14(%ebp)
f0102745:	83 e0 fe             	and    $0xfffffffe,%eax
f0102748:	01 c8                	add    %ecx,%eax
f010274a:	8b 55 f0             	mov    -0x10(%ebp),%edx
f010274d:	8d 14 82             	lea    (%edx,%eax,4),%edx
f0102750:	89 c8                	mov    %ecx,%eax
		while (m >= l && stabs[m].n_type != type)
f0102752:	39 c3                	cmp    %eax,%ebx
f0102754:	7f b3                	jg     f0102709 <stab_binsearch+0x22>
f0102756:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f010275a:	83 ea 0c             	sub    $0xc,%edx
f010275d:	39 f1                	cmp    %esi,%ecx
f010275f:	74 ae                	je     f010270f <stab_binsearch+0x28>
			m--;
f0102761:	48                   	dec    %eax
f0102762:	eb ee                	jmp    f0102752 <stab_binsearch+0x6b>
		} else if (stabs[m].n_value > addr) {
f0102764:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0102767:	76 11                	jbe    f010277a <stab_binsearch+0x93>
			*region_right = m - 1;
f0102769:	8d 78 ff             	lea    -0x1(%eax),%edi
f010276c:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010276f:	89 38                	mov    %edi,(%eax)
		any_matches = 1;
f0102771:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0102778:	eb b6                	jmp    f0102730 <stab_binsearch+0x49>
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f010277a:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f010277d:	89 03                	mov    %eax,(%ebx)
			l = m;
			addr++;
f010277f:	ff 45 0c             	incl   0xc(%ebp)
f0102782:	89 c3                	mov    %eax,%ebx
		any_matches = 1;
f0102784:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f010278b:	eb a3                	jmp    f0102730 <stab_binsearch+0x49>
		}
	}

	if (!any_matches)
f010278d:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0102791:	75 13                	jne    f01027a6 <stab_binsearch+0xbf>
		*region_right = *region_left - 1;
f0102793:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0102796:	8b 00                	mov    (%eax),%eax
f0102798:	48                   	dec    %eax
f0102799:	8b 7d e0             	mov    -0x20(%ebp),%edi
f010279c:	89 07                	mov    %eax,(%edi)
		     l > *region_left && stabs[l].n_type != type;
		     l--)
			/* do nothing */;
		*region_left = l;
	}
}
f010279e:	83 c4 14             	add    $0x14,%esp
f01027a1:	5b                   	pop    %ebx
f01027a2:	5e                   	pop    %esi
f01027a3:	5f                   	pop    %edi
f01027a4:	5d                   	pop    %ebp
f01027a5:	c3                   	ret    
		for (l = *region_right;
f01027a6:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01027a9:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f01027ab:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01027ae:	8b 0f                	mov    (%edi),%ecx
f01027b0:	8d 14 00             	lea    (%eax,%eax,1),%edx
f01027b3:	01 c2                	add    %eax,%edx
f01027b5:	8b 7d f0             	mov    -0x10(%ebp),%edi
f01027b8:	8d 14 97             	lea    (%edi,%edx,4),%edx
		for (l = *region_right;
f01027bb:	eb 01                	jmp    f01027be <stab_binsearch+0xd7>
		     l--)
f01027bd:	48                   	dec    %eax
		for (l = *region_right;
f01027be:	39 c1                	cmp    %eax,%ecx
f01027c0:	7d 0b                	jge    f01027cd <stab_binsearch+0xe6>
		     l > *region_left && stabs[l].n_type != type;
f01027c2:	0f b6 5a 04          	movzbl 0x4(%edx),%ebx
f01027c6:	83 ea 0c             	sub    $0xc,%edx
f01027c9:	39 f3                	cmp    %esi,%ebx
f01027cb:	75 f0                	jne    f01027bd <stab_binsearch+0xd6>
		*region_left = l;
f01027cd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01027d0:	89 07                	mov    %eax,(%edi)
}
f01027d2:	eb ca                	jmp    f010279e <stab_binsearch+0xb7>

f01027d4 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f01027d4:	55                   	push   %ebp
f01027d5:	89 e5                	mov    %esp,%ebp
f01027d7:	57                   	push   %edi
f01027d8:	56                   	push   %esi
f01027d9:	53                   	push   %ebx
f01027da:	83 ec 1c             	sub    $0x1c,%esp
f01027dd:	8b 7d 08             	mov    0x8(%ebp),%edi
f01027e0:	8b 75 0c             	mov    0xc(%ebp),%esi
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f01027e3:	c7 06 a0 44 10 f0    	movl   $0xf01044a0,(%esi)
	info->eip_line = 0;
f01027e9:	c7 46 04 00 00 00 00 	movl   $0x0,0x4(%esi)
	info->eip_fn_name = "<unknown>";
f01027f0:	c7 46 08 a0 44 10 f0 	movl   $0xf01044a0,0x8(%esi)
	info->eip_fn_namelen = 9;
f01027f7:	c7 46 0c 09 00 00 00 	movl   $0x9,0xc(%esi)
	info->eip_fn_addr = addr;
f01027fe:	89 7e 10             	mov    %edi,0x10(%esi)
	info->eip_fn_narg = 0;
f0102801:	c7 46 14 00 00 00 00 	movl   $0x0,0x14(%esi)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0102808:	81 ff ff ff 7f ef    	cmp    $0xef7fffff,%edi
f010280e:	0f 86 fb 00 00 00    	jbe    f010290f <debuginfo_eip+0x13b>
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0102814:	b8 b4 d2 10 f0       	mov    $0xf010d2b4,%eax
f0102819:	3d d9 b4 10 f0       	cmp    $0xf010b4d9,%eax
f010281e:	0f 86 6f 01 00 00    	jbe    f0102993 <debuginfo_eip+0x1bf>
f0102824:	80 3d b3 d2 10 f0 00 	cmpb   $0x0,0xf010d2b3
f010282b:	0f 85 69 01 00 00    	jne    f010299a <debuginfo_eip+0x1c6>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0102831:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0102838:	b8 d8 b4 10 f0       	mov    $0xf010b4d8,%eax
f010283d:	2d d4 46 10 f0       	sub    $0xf01046d4,%eax
f0102842:	89 c2                	mov    %eax,%edx
f0102844:	c1 fa 02             	sar    $0x2,%edx
f0102847:	83 e0 fc             	and    $0xfffffffc,%eax
f010284a:	01 d0                	add    %edx,%eax
f010284c:	8d 04 82             	lea    (%edx,%eax,4),%eax
f010284f:	8d 04 82             	lea    (%edx,%eax,4),%eax
f0102852:	89 c1                	mov    %eax,%ecx
f0102854:	c1 e1 08             	shl    $0x8,%ecx
f0102857:	01 c8                	add    %ecx,%eax
f0102859:	89 c1                	mov    %eax,%ecx
f010285b:	c1 e1 10             	shl    $0x10,%ecx
f010285e:	01 c8                	add    %ecx,%eax
f0102860:	01 c0                	add    %eax,%eax
f0102862:	8d 44 02 ff          	lea    -0x1(%edx,%eax,1),%eax
f0102866:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0102869:	83 ec 08             	sub    $0x8,%esp
f010286c:	57                   	push   %edi
f010286d:	6a 64                	push   $0x64
f010286f:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0102872:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0102875:	b8 d4 46 10 f0       	mov    $0xf01046d4,%eax
f010287a:	e8 68 fe ff ff       	call   f01026e7 <stab_binsearch>
	if (lfile == 0)
f010287f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0102882:	83 c4 10             	add    $0x10,%esp
f0102885:	85 c0                	test   %eax,%eax
f0102887:	0f 84 14 01 00 00    	je     f01029a1 <debuginfo_eip+0x1cd>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f010288d:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0102890:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0102893:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0102896:	83 ec 08             	sub    $0x8,%esp
f0102899:	57                   	push   %edi
f010289a:	6a 24                	push   $0x24
f010289c:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f010289f:	8d 55 dc             	lea    -0x24(%ebp),%edx
f01028a2:	b8 d4 46 10 f0       	mov    $0xf01046d4,%eax
f01028a7:	e8 3b fe ff ff       	call   f01026e7 <stab_binsearch>

	if (lfun <= rfun) {
f01028ac:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f01028af:	83 c4 10             	add    $0x10,%esp
f01028b2:	3b 5d d8             	cmp    -0x28(%ebp),%ebx
f01028b5:	7f 6c                	jg     f0102923 <debuginfo_eip+0x14f>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f01028b7:	8d 04 1b             	lea    (%ebx,%ebx,1),%eax
f01028ba:	01 d8                	add    %ebx,%eax
f01028bc:	c1 e0 02             	shl    $0x2,%eax
f01028bf:	8d 90 d4 46 10 f0    	lea    -0xfefb92c(%eax),%edx
f01028c5:	8b 88 d4 46 10 f0    	mov    -0xfefb92c(%eax),%ecx
f01028cb:	b8 b4 d2 10 f0       	mov    $0xf010d2b4,%eax
f01028d0:	2d d9 b4 10 f0       	sub    $0xf010b4d9,%eax
f01028d5:	39 c1                	cmp    %eax,%ecx
f01028d7:	73 09                	jae    f01028e2 <debuginfo_eip+0x10e>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f01028d9:	81 c1 d9 b4 10 f0    	add    $0xf010b4d9,%ecx
f01028df:	89 4e 08             	mov    %ecx,0x8(%esi)
		info->eip_fn_addr = stabs[lfun].n_value;
f01028e2:	8b 42 08             	mov    0x8(%edx),%eax
f01028e5:	89 46 10             	mov    %eax,0x10(%esi)
		info->eip_fn_addr = addr;
		lline = lfile;
		rline = rfile;
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f01028e8:	83 ec 08             	sub    $0x8,%esp
f01028eb:	6a 3a                	push   $0x3a
f01028ed:	ff 76 08             	pushl  0x8(%esi)
f01028f0:	e8 56 08 00 00       	call   f010314b <strfind>
f01028f5:	2b 46 08             	sub    0x8(%esi),%eax
f01028f8:	89 46 0c             	mov    %eax,0xc(%esi)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f01028fb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01028fe:	8d 04 1b             	lea    (%ebx,%ebx,1),%eax
f0102901:	01 d8                	add    %ebx,%eax
f0102903:	8d 04 85 d4 46 10 f0 	lea    -0xfefb92c(,%eax,4),%eax
f010290a:	83 c4 10             	add    $0x10,%esp
f010290d:	eb 20                	jmp    f010292f <debuginfo_eip+0x15b>
  	        panic("User address");
f010290f:	83 ec 04             	sub    $0x4,%esp
f0102912:	68 aa 44 10 f0       	push   $0xf01044aa
f0102917:	6a 7f                	push   $0x7f
f0102919:	68 b7 44 10 f0       	push   $0xf01044b7
f010291e:	e8 68 d7 ff ff       	call   f010008b <_panic>
		info->eip_fn_addr = addr;
f0102923:	89 7e 10             	mov    %edi,0x10(%esi)
		lline = lfile;
f0102926:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0102929:	eb bd                	jmp    f01028e8 <debuginfo_eip+0x114>
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f010292b:	4b                   	dec    %ebx
f010292c:	83 e8 0c             	sub    $0xc,%eax
	while (lline >= lfile
f010292f:	39 df                	cmp    %ebx,%edi
f0102931:	7f 35                	jg     f0102968 <debuginfo_eip+0x194>
	       && stabs[lline].n_type != N_SOL
f0102933:	8a 50 04             	mov    0x4(%eax),%dl
f0102936:	80 fa 84             	cmp    $0x84,%dl
f0102939:	74 0b                	je     f0102946 <debuginfo_eip+0x172>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f010293b:	80 fa 64             	cmp    $0x64,%dl
f010293e:	75 eb                	jne    f010292b <debuginfo_eip+0x157>
f0102940:	83 78 08 00          	cmpl   $0x0,0x8(%eax)
f0102944:	74 e5                	je     f010292b <debuginfo_eip+0x157>
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0102946:	8d 04 1b             	lea    (%ebx,%ebx,1),%eax
f0102949:	01 c3                	add    %eax,%ebx
f010294b:	8b 14 9d d4 46 10 f0 	mov    -0xfefb92c(,%ebx,4),%edx
f0102952:	b8 b4 d2 10 f0       	mov    $0xf010d2b4,%eax
f0102957:	2d d9 b4 10 f0       	sub    $0xf010b4d9,%eax
f010295c:	39 c2                	cmp    %eax,%edx
f010295e:	73 08                	jae    f0102968 <debuginfo_eip+0x194>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0102960:	81 c2 d9 b4 10 f0    	add    $0xf010b4d9,%edx
f0102966:	89 16                	mov    %edx,(%esi)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0102968:	8b 45 dc             	mov    -0x24(%ebp),%eax
f010296b:	8b 4d d8             	mov    -0x28(%ebp),%ecx
f010296e:	39 c8                	cmp    %ecx,%eax
f0102970:	7d 36                	jge    f01029a8 <debuginfo_eip+0x1d4>
		for (lline = lfun + 1;
f0102972:	40                   	inc    %eax
f0102973:	eb 04                	jmp    f0102979 <debuginfo_eip+0x1a5>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f0102975:	ff 46 14             	incl   0x14(%esi)
		     lline++)
f0102978:	40                   	inc    %eax
		for (lline = lfun + 1;
f0102979:	39 c1                	cmp    %eax,%ecx
f010297b:	74 38                	je     f01029b5 <debuginfo_eip+0x1e1>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f010297d:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0102980:	01 c2                	add    %eax,%edx
f0102982:	80 3c 95 d8 46 10 f0 	cmpb   $0xa0,-0xfefb928(,%edx,4)
f0102989:	a0 
f010298a:	74 e9                	je     f0102975 <debuginfo_eip+0x1a1>

	return 0;
f010298c:	b8 00 00 00 00       	mov    $0x0,%eax
f0102991:	eb 1a                	jmp    f01029ad <debuginfo_eip+0x1d9>
		return -1;
f0102993:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0102998:	eb 13                	jmp    f01029ad <debuginfo_eip+0x1d9>
f010299a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010299f:	eb 0c                	jmp    f01029ad <debuginfo_eip+0x1d9>
		return -1;
f01029a1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01029a6:	eb 05                	jmp    f01029ad <debuginfo_eip+0x1d9>
	return 0;
f01029a8:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01029ad:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01029b0:	5b                   	pop    %ebx
f01029b1:	5e                   	pop    %esi
f01029b2:	5f                   	pop    %edi
f01029b3:	5d                   	pop    %ebp
f01029b4:	c3                   	ret    
	return 0;
f01029b5:	b8 00 00 00 00       	mov    $0x0,%eax
f01029ba:	eb f1                	jmp    f01029ad <debuginfo_eip+0x1d9>

f01029bc <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f01029bc:	55                   	push   %ebp
f01029bd:	89 e5                	mov    %esp,%ebp
f01029bf:	57                   	push   %edi
f01029c0:	56                   	push   %esi
f01029c1:	53                   	push   %ebx
f01029c2:	83 ec 1c             	sub    $0x1c,%esp
f01029c5:	89 c7                	mov    %eax,%edi
f01029c7:	89 d6                	mov    %edx,%esi
f01029c9:	8b 45 08             	mov    0x8(%ebp),%eax
f01029cc:	8b 55 0c             	mov    0xc(%ebp),%edx
f01029cf:	89 d1                	mov    %edx,%ecx
f01029d1:	89 c2                	mov    %eax,%edx
f01029d3:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01029d6:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f01029d9:	8b 45 10             	mov    0x10(%ebp),%eax
f01029dc:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f01029df:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01029e2:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f01029e9:	39 c2                	cmp    %eax,%edx
f01029eb:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
f01029ee:	72 3c                	jb     f0102a2c <printnum+0x70>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f01029f0:	83 ec 0c             	sub    $0xc,%esp
f01029f3:	ff 75 18             	pushl  0x18(%ebp)
f01029f6:	4b                   	dec    %ebx
f01029f7:	53                   	push   %ebx
f01029f8:	50                   	push   %eax
f01029f9:	83 ec 08             	sub    $0x8,%esp
f01029fc:	ff 75 e4             	pushl  -0x1c(%ebp)
f01029ff:	ff 75 e0             	pushl  -0x20(%ebp)
f0102a02:	ff 75 dc             	pushl  -0x24(%ebp)
f0102a05:	ff 75 d8             	pushl  -0x28(%ebp)
f0102a08:	e8 33 09 00 00       	call   f0103340 <__udivdi3>
f0102a0d:	83 c4 18             	add    $0x18,%esp
f0102a10:	52                   	push   %edx
f0102a11:	50                   	push   %eax
f0102a12:	89 f2                	mov    %esi,%edx
f0102a14:	89 f8                	mov    %edi,%eax
f0102a16:	e8 a1 ff ff ff       	call   f01029bc <printnum>
f0102a1b:	83 c4 20             	add    $0x20,%esp
f0102a1e:	eb 11                	jmp    f0102a31 <printnum+0x75>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0102a20:	83 ec 08             	sub    $0x8,%esp
f0102a23:	56                   	push   %esi
f0102a24:	ff 75 18             	pushl  0x18(%ebp)
f0102a27:	ff d7                	call   *%edi
f0102a29:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
f0102a2c:	4b                   	dec    %ebx
f0102a2d:	85 db                	test   %ebx,%ebx
f0102a2f:	7f ef                	jg     f0102a20 <printnum+0x64>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0102a31:	83 ec 08             	sub    $0x8,%esp
f0102a34:	56                   	push   %esi
f0102a35:	83 ec 04             	sub    $0x4,%esp
f0102a38:	ff 75 e4             	pushl  -0x1c(%ebp)
f0102a3b:	ff 75 e0             	pushl  -0x20(%ebp)
f0102a3e:	ff 75 dc             	pushl  -0x24(%ebp)
f0102a41:	ff 75 d8             	pushl  -0x28(%ebp)
f0102a44:	e8 f7 09 00 00       	call   f0103440 <__umoddi3>
f0102a49:	83 c4 14             	add    $0x14,%esp
f0102a4c:	0f be 80 c5 44 10 f0 	movsbl -0xfefbb3b(%eax),%eax
f0102a53:	50                   	push   %eax
f0102a54:	ff d7                	call   *%edi
}
f0102a56:	83 c4 10             	add    $0x10,%esp
f0102a59:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102a5c:	5b                   	pop    %ebx
f0102a5d:	5e                   	pop    %esi
f0102a5e:	5f                   	pop    %edi
f0102a5f:	5d                   	pop    %ebp
f0102a60:	c3                   	ret    

f0102a61 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0102a61:	55                   	push   %ebp
f0102a62:	89 e5                	mov    %esp,%ebp
f0102a64:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0102a67:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
f0102a6a:	8b 10                	mov    (%eax),%edx
f0102a6c:	3b 50 04             	cmp    0x4(%eax),%edx
f0102a6f:	73 0a                	jae    f0102a7b <sprintputch+0x1a>
		*b->buf++ = ch;
f0102a71:	8d 4a 01             	lea    0x1(%edx),%ecx
f0102a74:	89 08                	mov    %ecx,(%eax)
f0102a76:	8b 45 08             	mov    0x8(%ebp),%eax
f0102a79:	88 02                	mov    %al,(%edx)
}
f0102a7b:	5d                   	pop    %ebp
f0102a7c:	c3                   	ret    

f0102a7d <printfmt>:
{
f0102a7d:	55                   	push   %ebp
f0102a7e:	89 e5                	mov    %esp,%ebp
f0102a80:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
f0102a83:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0102a86:	50                   	push   %eax
f0102a87:	ff 75 10             	pushl  0x10(%ebp)
f0102a8a:	ff 75 0c             	pushl  0xc(%ebp)
f0102a8d:	ff 75 08             	pushl  0x8(%ebp)
f0102a90:	e8 05 00 00 00       	call   f0102a9a <vprintfmt>
}
f0102a95:	83 c4 10             	add    $0x10,%esp
f0102a98:	c9                   	leave  
f0102a99:	c3                   	ret    

f0102a9a <vprintfmt>:
{
f0102a9a:	55                   	push   %ebp
f0102a9b:	89 e5                	mov    %esp,%ebp
f0102a9d:	57                   	push   %edi
f0102a9e:	56                   	push   %esi
f0102a9f:	53                   	push   %ebx
f0102aa0:	83 ec 3c             	sub    $0x3c,%esp
f0102aa3:	8b 75 08             	mov    0x8(%ebp),%esi
f0102aa6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0102aa9:	8b 7d 10             	mov    0x10(%ebp),%edi
f0102aac:	e9 5b 03 00 00       	jmp    f0102e0c <vprintfmt+0x372>
		padc = ' ';
f0102ab1:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
f0102ab5:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
		precision = -1;
f0102abc:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
f0102ac3:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		lflag = 0;
f0102aca:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
f0102acf:	8d 47 01             	lea    0x1(%edi),%eax
f0102ad2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0102ad5:	8a 17                	mov    (%edi),%dl
f0102ad7:	8d 42 dd             	lea    -0x23(%edx),%eax
f0102ada:	3c 55                	cmp    $0x55,%al
f0102adc:	0f 87 ab 03 00 00    	ja     f0102e8d <vprintfmt+0x3f3>
f0102ae2:	0f b6 c0             	movzbl %al,%eax
f0102ae5:	ff 24 85 50 45 10 f0 	jmp    *-0xfefbab0(,%eax,4)
f0102aec:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
f0102aef:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
f0102af3:	eb da                	jmp    f0102acf <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
f0102af5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0102af8:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
f0102afc:	eb d1                	jmp    f0102acf <vprintfmt+0x35>
f0102afe:	0f b6 d2             	movzbl %dl,%edx
f0102b01:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
f0102b04:	b8 00 00 00 00       	mov    $0x0,%eax
f0102b09:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
f0102b0c:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0102b0f:	01 c0                	add    %eax,%eax
f0102b11:	8d 44 02 d0          	lea    -0x30(%edx,%eax,1),%eax
				ch = *fmt;
f0102b15:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
f0102b18:	8d 4a d0             	lea    -0x30(%edx),%ecx
f0102b1b:	83 f9 09             	cmp    $0x9,%ecx
f0102b1e:	77 52                	ja     f0102b72 <vprintfmt+0xd8>
			for (precision = 0; ; ++fmt) {
f0102b20:	47                   	inc    %edi
				precision = precision * 10 + ch - '0';
f0102b21:	eb e9                	jmp    f0102b0c <vprintfmt+0x72>
			precision = va_arg(ap, int);
f0102b23:	8b 45 14             	mov    0x14(%ebp),%eax
f0102b26:	8b 00                	mov    (%eax),%eax
f0102b28:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0102b2b:	8b 45 14             	mov    0x14(%ebp),%eax
f0102b2e:	8d 40 04             	lea    0x4(%eax),%eax
f0102b31:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0102b34:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
f0102b37:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f0102b3b:	79 92                	jns    f0102acf <vprintfmt+0x35>
				width = precision, precision = -1;
f0102b3d:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0102b40:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102b43:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
f0102b4a:	eb 83                	jmp    f0102acf <vprintfmt+0x35>
f0102b4c:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f0102b50:	78 08                	js     f0102b5a <vprintfmt+0xc0>
		switch (ch = *(unsigned char *) fmt++) {
f0102b52:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
f0102b55:	e9 75 ff ff ff       	jmp    f0102acf <vprintfmt+0x35>
f0102b5a:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
f0102b61:	eb ef                	jmp    f0102b52 <vprintfmt+0xb8>
		switch (ch = *(unsigned char *) fmt++) {
f0102b63:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
f0102b66:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
f0102b6d:	e9 5d ff ff ff       	jmp    f0102acf <vprintfmt+0x35>
f0102b72:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0102b75:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0102b78:	eb bd                	jmp    f0102b37 <vprintfmt+0x9d>
			lflag++;
f0102b7a:	41                   	inc    %ecx
		switch (ch = *(unsigned char *) fmt++) {
f0102b7b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
f0102b7e:	e9 4c ff ff ff       	jmp    f0102acf <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
f0102b83:	8b 45 14             	mov    0x14(%ebp),%eax
f0102b86:	8d 78 04             	lea    0x4(%eax),%edi
f0102b89:	83 ec 08             	sub    $0x8,%esp
f0102b8c:	53                   	push   %ebx
f0102b8d:	ff 30                	pushl  (%eax)
f0102b8f:	ff d6                	call   *%esi
			break;
f0102b91:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
f0102b94:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
f0102b97:	e9 6d 02 00 00       	jmp    f0102e09 <vprintfmt+0x36f>
			err = va_arg(ap, int);
f0102b9c:	8b 45 14             	mov    0x14(%ebp),%eax
f0102b9f:	8d 78 04             	lea    0x4(%eax),%edi
f0102ba2:	8b 00                	mov    (%eax),%eax
f0102ba4:	85 c0                	test   %eax,%eax
f0102ba6:	78 2a                	js     f0102bd2 <vprintfmt+0x138>
f0102ba8:	89 c2                	mov    %eax,%edx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0102baa:	83 f8 06             	cmp    $0x6,%eax
f0102bad:	7f 27                	jg     f0102bd6 <vprintfmt+0x13c>
f0102baf:	8b 04 85 a8 46 10 f0 	mov    -0xfefb958(,%eax,4),%eax
f0102bb6:	85 c0                	test   %eax,%eax
f0102bb8:	74 1c                	je     f0102bd6 <vprintfmt+0x13c>
				printfmt(putch, putdat, "%s", p);
f0102bba:	50                   	push   %eax
f0102bbb:	68 63 3a 10 f0       	push   $0xf0103a63
f0102bc0:	53                   	push   %ebx
f0102bc1:	56                   	push   %esi
f0102bc2:	e8 b6 fe ff ff       	call   f0102a7d <printfmt>
f0102bc7:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f0102bca:	89 7d 14             	mov    %edi,0x14(%ebp)
f0102bcd:	e9 37 02 00 00       	jmp    f0102e09 <vprintfmt+0x36f>
f0102bd2:	f7 d8                	neg    %eax
f0102bd4:	eb d2                	jmp    f0102ba8 <vprintfmt+0x10e>
				printfmt(putch, putdat, "error %d", err);
f0102bd6:	52                   	push   %edx
f0102bd7:	68 dd 44 10 f0       	push   $0xf01044dd
f0102bdc:	53                   	push   %ebx
f0102bdd:	56                   	push   %esi
f0102bde:	e8 9a fe ff ff       	call   f0102a7d <printfmt>
f0102be3:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f0102be6:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
f0102be9:	e9 1b 02 00 00       	jmp    f0102e09 <vprintfmt+0x36f>
			if ((p = va_arg(ap, char *)) == NULL)
f0102bee:	8b 45 14             	mov    0x14(%ebp),%eax
f0102bf1:	83 c0 04             	add    $0x4,%eax
f0102bf4:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0102bf7:	8b 45 14             	mov    0x14(%ebp),%eax
f0102bfa:	8b 00                	mov    (%eax),%eax
f0102bfc:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0102bff:	85 c0                	test   %eax,%eax
f0102c01:	74 19                	je     f0102c1c <vprintfmt+0x182>
			if (width > 0 && padc != '-')
f0102c03:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f0102c07:	7e 06                	jle    f0102c0f <vprintfmt+0x175>
f0102c09:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
f0102c0d:	75 16                	jne    f0102c25 <vprintfmt+0x18b>
				for (width -= strnlen(p, precision); width > 0; width--)
f0102c0f:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0102c12:	89 c7                	mov    %eax,%edi
f0102c14:	03 45 d4             	add    -0x2c(%ebp),%eax
f0102c17:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102c1a:	eb 62                	jmp    f0102c7e <vprintfmt+0x1e4>
				p = "(null)";
f0102c1c:	c7 45 cc d6 44 10 f0 	movl   $0xf01044d6,-0x34(%ebp)
f0102c23:	eb de                	jmp    f0102c03 <vprintfmt+0x169>
				for (width -= strnlen(p, precision); width > 0; width--)
f0102c25:	83 ec 08             	sub    $0x8,%esp
f0102c28:	ff 75 d8             	pushl  -0x28(%ebp)
f0102c2b:	ff 75 cc             	pushl  -0x34(%ebp)
f0102c2e:	e8 e2 03 00 00       	call   f0103015 <strnlen>
f0102c33:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0102c36:	29 c2                	sub    %eax,%edx
f0102c38:	89 55 c4             	mov    %edx,-0x3c(%ebp)
f0102c3b:	83 c4 10             	add    $0x10,%esp
f0102c3e:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
f0102c40:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
f0102c44:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
f0102c47:	eb 0d                	jmp    f0102c56 <vprintfmt+0x1bc>
					putch(padc, putdat);
f0102c49:	83 ec 08             	sub    $0x8,%esp
f0102c4c:	53                   	push   %ebx
f0102c4d:	ff 75 d4             	pushl  -0x2c(%ebp)
f0102c50:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
f0102c52:	4f                   	dec    %edi
f0102c53:	83 c4 10             	add    $0x10,%esp
f0102c56:	85 ff                	test   %edi,%edi
f0102c58:	7f ef                	jg     f0102c49 <vprintfmt+0x1af>
f0102c5a:	8b 55 c4             	mov    -0x3c(%ebp),%edx
f0102c5d:	89 d0                	mov    %edx,%eax
f0102c5f:	85 d2                	test   %edx,%edx
f0102c61:	78 0a                	js     f0102c6d <vprintfmt+0x1d3>
f0102c63:	8b 55 c4             	mov    -0x3c(%ebp),%edx
f0102c66:	29 c2                	sub    %eax,%edx
f0102c68:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f0102c6b:	eb a2                	jmp    f0102c0f <vprintfmt+0x175>
f0102c6d:	b8 00 00 00 00       	mov    $0x0,%eax
f0102c72:	eb ef                	jmp    f0102c63 <vprintfmt+0x1c9>
					putch(ch, putdat);
f0102c74:	83 ec 08             	sub    $0x8,%esp
f0102c77:	53                   	push   %ebx
f0102c78:	52                   	push   %edx
f0102c79:	ff d6                	call   *%esi
f0102c7b:	83 c4 10             	add    $0x10,%esp
f0102c7e:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0102c81:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0102c83:	47                   	inc    %edi
f0102c84:	8a 47 ff             	mov    -0x1(%edi),%al
f0102c87:	0f be d0             	movsbl %al,%edx
f0102c8a:	85 d2                	test   %edx,%edx
f0102c8c:	74 48                	je     f0102cd6 <vprintfmt+0x23c>
f0102c8e:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0102c92:	78 05                	js     f0102c99 <vprintfmt+0x1ff>
f0102c94:	ff 4d d8             	decl   -0x28(%ebp)
f0102c97:	78 1e                	js     f0102cb7 <vprintfmt+0x21d>
				if (altflag && (ch < ' ' || ch > '~'))
f0102c99:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0102c9d:	74 d5                	je     f0102c74 <vprintfmt+0x1da>
f0102c9f:	0f be c0             	movsbl %al,%eax
f0102ca2:	83 e8 20             	sub    $0x20,%eax
f0102ca5:	83 f8 5e             	cmp    $0x5e,%eax
f0102ca8:	76 ca                	jbe    f0102c74 <vprintfmt+0x1da>
					putch('?', putdat);
f0102caa:	83 ec 08             	sub    $0x8,%esp
f0102cad:	53                   	push   %ebx
f0102cae:	6a 3f                	push   $0x3f
f0102cb0:	ff d6                	call   *%esi
f0102cb2:	83 c4 10             	add    $0x10,%esp
f0102cb5:	eb c7                	jmp    f0102c7e <vprintfmt+0x1e4>
f0102cb7:	89 cf                	mov    %ecx,%edi
f0102cb9:	eb 0c                	jmp    f0102cc7 <vprintfmt+0x22d>
				putch(' ', putdat);
f0102cbb:	83 ec 08             	sub    $0x8,%esp
f0102cbe:	53                   	push   %ebx
f0102cbf:	6a 20                	push   $0x20
f0102cc1:	ff d6                	call   *%esi
			for (; width > 0; width--)
f0102cc3:	4f                   	dec    %edi
f0102cc4:	83 c4 10             	add    $0x10,%esp
f0102cc7:	85 ff                	test   %edi,%edi
f0102cc9:	7f f0                	jg     f0102cbb <vprintfmt+0x221>
			if ((p = va_arg(ap, char *)) == NULL)
f0102ccb:	8b 45 c8             	mov    -0x38(%ebp),%eax
f0102cce:	89 45 14             	mov    %eax,0x14(%ebp)
f0102cd1:	e9 33 01 00 00       	jmp    f0102e09 <vprintfmt+0x36f>
f0102cd6:	89 cf                	mov    %ecx,%edi
f0102cd8:	eb ed                	jmp    f0102cc7 <vprintfmt+0x22d>
	if (lflag >= 2)
f0102cda:	83 f9 01             	cmp    $0x1,%ecx
f0102cdd:	7f 1b                	jg     f0102cfa <vprintfmt+0x260>
	else if (lflag)
f0102cdf:	85 c9                	test   %ecx,%ecx
f0102ce1:	74 42                	je     f0102d25 <vprintfmt+0x28b>
		return va_arg(*ap, long);
f0102ce3:	8b 45 14             	mov    0x14(%ebp),%eax
f0102ce6:	8b 00                	mov    (%eax),%eax
f0102ce8:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0102ceb:	99                   	cltd   
f0102cec:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0102cef:	8b 45 14             	mov    0x14(%ebp),%eax
f0102cf2:	8d 40 04             	lea    0x4(%eax),%eax
f0102cf5:	89 45 14             	mov    %eax,0x14(%ebp)
f0102cf8:	eb 17                	jmp    f0102d11 <vprintfmt+0x277>
		return va_arg(*ap, long long);
f0102cfa:	8b 45 14             	mov    0x14(%ebp),%eax
f0102cfd:	8b 50 04             	mov    0x4(%eax),%edx
f0102d00:	8b 00                	mov    (%eax),%eax
f0102d02:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0102d05:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0102d08:	8b 45 14             	mov    0x14(%ebp),%eax
f0102d0b:	8d 40 08             	lea    0x8(%eax),%eax
f0102d0e:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
f0102d11:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0102d14:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f0102d17:	85 c9                	test   %ecx,%ecx
f0102d19:	78 21                	js     f0102d3c <vprintfmt+0x2a2>
			base = 10;
f0102d1b:	b8 0a 00 00 00       	mov    $0xa,%eax
f0102d20:	e9 ca 00 00 00       	jmp    f0102def <vprintfmt+0x355>
		return va_arg(*ap, int);
f0102d25:	8b 45 14             	mov    0x14(%ebp),%eax
f0102d28:	8b 00                	mov    (%eax),%eax
f0102d2a:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0102d2d:	99                   	cltd   
f0102d2e:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0102d31:	8b 45 14             	mov    0x14(%ebp),%eax
f0102d34:	8d 40 04             	lea    0x4(%eax),%eax
f0102d37:	89 45 14             	mov    %eax,0x14(%ebp)
f0102d3a:	eb d5                	jmp    f0102d11 <vprintfmt+0x277>
				putch('-', putdat);
f0102d3c:	83 ec 08             	sub    $0x8,%esp
f0102d3f:	53                   	push   %ebx
f0102d40:	6a 2d                	push   $0x2d
f0102d42:	ff d6                	call   *%esi
				num = -(long long) num;
f0102d44:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0102d47:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f0102d4a:	f7 da                	neg    %edx
f0102d4c:	83 d1 00             	adc    $0x0,%ecx
f0102d4f:	f7 d9                	neg    %ecx
f0102d51:	83 c4 10             	add    $0x10,%esp
			base = 10;
f0102d54:	b8 0a 00 00 00       	mov    $0xa,%eax
f0102d59:	e9 91 00 00 00       	jmp    f0102def <vprintfmt+0x355>
	if (lflag >= 2)
f0102d5e:	83 f9 01             	cmp    $0x1,%ecx
f0102d61:	7f 1b                	jg     f0102d7e <vprintfmt+0x2e4>
	else if (lflag)
f0102d63:	85 c9                	test   %ecx,%ecx
f0102d65:	74 2c                	je     f0102d93 <vprintfmt+0x2f9>
		return va_arg(*ap, unsigned long);
f0102d67:	8b 45 14             	mov    0x14(%ebp),%eax
f0102d6a:	8b 10                	mov    (%eax),%edx
f0102d6c:	b9 00 00 00 00       	mov    $0x0,%ecx
f0102d71:	8d 40 04             	lea    0x4(%eax),%eax
f0102d74:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0102d77:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
f0102d7c:	eb 71                	jmp    f0102def <vprintfmt+0x355>
		return va_arg(*ap, unsigned long long);
f0102d7e:	8b 45 14             	mov    0x14(%ebp),%eax
f0102d81:	8b 10                	mov    (%eax),%edx
f0102d83:	8b 48 04             	mov    0x4(%eax),%ecx
f0102d86:	8d 40 08             	lea    0x8(%eax),%eax
f0102d89:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0102d8c:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
f0102d91:	eb 5c                	jmp    f0102def <vprintfmt+0x355>
		return va_arg(*ap, unsigned int);
f0102d93:	8b 45 14             	mov    0x14(%ebp),%eax
f0102d96:	8b 10                	mov    (%eax),%edx
f0102d98:	b9 00 00 00 00       	mov    $0x0,%ecx
f0102d9d:	8d 40 04             	lea    0x4(%eax),%eax
f0102da0:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0102da3:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
f0102da8:	eb 45                	jmp    f0102def <vprintfmt+0x355>
			putch('X', putdat);
f0102daa:	83 ec 08             	sub    $0x8,%esp
f0102dad:	53                   	push   %ebx
f0102dae:	6a 58                	push   $0x58
f0102db0:	ff d6                	call   *%esi
			putch('X', putdat);
f0102db2:	83 c4 08             	add    $0x8,%esp
f0102db5:	53                   	push   %ebx
f0102db6:	6a 58                	push   $0x58
f0102db8:	ff d6                	call   *%esi
			putch('X', putdat);
f0102dba:	83 c4 08             	add    $0x8,%esp
f0102dbd:	53                   	push   %ebx
f0102dbe:	6a 58                	push   $0x58
f0102dc0:	ff d6                	call   *%esi
			break;
f0102dc2:	83 c4 10             	add    $0x10,%esp
f0102dc5:	eb 42                	jmp    f0102e09 <vprintfmt+0x36f>
			putch('0', putdat);
f0102dc7:	83 ec 08             	sub    $0x8,%esp
f0102dca:	53                   	push   %ebx
f0102dcb:	6a 30                	push   $0x30
f0102dcd:	ff d6                	call   *%esi
			putch('x', putdat);
f0102dcf:	83 c4 08             	add    $0x8,%esp
f0102dd2:	53                   	push   %ebx
f0102dd3:	6a 78                	push   $0x78
f0102dd5:	ff d6                	call   *%esi
			num = (unsigned long long)
f0102dd7:	8b 45 14             	mov    0x14(%ebp),%eax
f0102dda:	8b 10                	mov    (%eax),%edx
f0102ddc:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
f0102de1:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
f0102de4:	8d 40 04             	lea    0x4(%eax),%eax
f0102de7:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0102dea:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
f0102def:	83 ec 0c             	sub    $0xc,%esp
f0102df2:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
f0102df6:	57                   	push   %edi
f0102df7:	ff 75 d4             	pushl  -0x2c(%ebp)
f0102dfa:	50                   	push   %eax
f0102dfb:	51                   	push   %ecx
f0102dfc:	52                   	push   %edx
f0102dfd:	89 da                	mov    %ebx,%edx
f0102dff:	89 f0                	mov    %esi,%eax
f0102e01:	e8 b6 fb ff ff       	call   f01029bc <printnum>
			break;
f0102e06:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
f0102e09:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0102e0c:	47                   	inc    %edi
f0102e0d:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0102e11:	83 f8 25             	cmp    $0x25,%eax
f0102e14:	0f 84 97 fc ff ff    	je     f0102ab1 <vprintfmt+0x17>
			if (ch == '\0')
f0102e1a:	85 c0                	test   %eax,%eax
f0102e1c:	0f 84 89 00 00 00    	je     f0102eab <vprintfmt+0x411>
			putch(ch, putdat);
f0102e22:	83 ec 08             	sub    $0x8,%esp
f0102e25:	53                   	push   %ebx
f0102e26:	50                   	push   %eax
f0102e27:	ff d6                	call   *%esi
f0102e29:	83 c4 10             	add    $0x10,%esp
f0102e2c:	eb de                	jmp    f0102e0c <vprintfmt+0x372>
	if (lflag >= 2)
f0102e2e:	83 f9 01             	cmp    $0x1,%ecx
f0102e31:	7f 1b                	jg     f0102e4e <vprintfmt+0x3b4>
	else if (lflag)
f0102e33:	85 c9                	test   %ecx,%ecx
f0102e35:	74 2c                	je     f0102e63 <vprintfmt+0x3c9>
		return va_arg(*ap, unsigned long);
f0102e37:	8b 45 14             	mov    0x14(%ebp),%eax
f0102e3a:	8b 10                	mov    (%eax),%edx
f0102e3c:	b9 00 00 00 00       	mov    $0x0,%ecx
f0102e41:	8d 40 04             	lea    0x4(%eax),%eax
f0102e44:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0102e47:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
f0102e4c:	eb a1                	jmp    f0102def <vprintfmt+0x355>
		return va_arg(*ap, unsigned long long);
f0102e4e:	8b 45 14             	mov    0x14(%ebp),%eax
f0102e51:	8b 10                	mov    (%eax),%edx
f0102e53:	8b 48 04             	mov    0x4(%eax),%ecx
f0102e56:	8d 40 08             	lea    0x8(%eax),%eax
f0102e59:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0102e5c:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
f0102e61:	eb 8c                	jmp    f0102def <vprintfmt+0x355>
		return va_arg(*ap, unsigned int);
f0102e63:	8b 45 14             	mov    0x14(%ebp),%eax
f0102e66:	8b 10                	mov    (%eax),%edx
f0102e68:	b9 00 00 00 00       	mov    $0x0,%ecx
f0102e6d:	8d 40 04             	lea    0x4(%eax),%eax
f0102e70:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0102e73:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
f0102e78:	e9 72 ff ff ff       	jmp    f0102def <vprintfmt+0x355>
			putch(ch, putdat);
f0102e7d:	83 ec 08             	sub    $0x8,%esp
f0102e80:	53                   	push   %ebx
f0102e81:	6a 25                	push   $0x25
f0102e83:	ff d6                	call   *%esi
			break;
f0102e85:	83 c4 10             	add    $0x10,%esp
f0102e88:	e9 7c ff ff ff       	jmp    f0102e09 <vprintfmt+0x36f>
			putch('%', putdat);
f0102e8d:	83 ec 08             	sub    $0x8,%esp
f0102e90:	53                   	push   %ebx
f0102e91:	6a 25                	push   $0x25
f0102e93:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f0102e95:	83 c4 10             	add    $0x10,%esp
f0102e98:	89 f8                	mov    %edi,%eax
f0102e9a:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
f0102e9e:	74 03                	je     f0102ea3 <vprintfmt+0x409>
f0102ea0:	48                   	dec    %eax
f0102ea1:	eb f7                	jmp    f0102e9a <vprintfmt+0x400>
f0102ea3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0102ea6:	e9 5e ff ff ff       	jmp    f0102e09 <vprintfmt+0x36f>
}
f0102eab:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102eae:	5b                   	pop    %ebx
f0102eaf:	5e                   	pop    %esi
f0102eb0:	5f                   	pop    %edi
f0102eb1:	5d                   	pop    %ebp
f0102eb2:	c3                   	ret    

f0102eb3 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0102eb3:	55                   	push   %ebp
f0102eb4:	89 e5                	mov    %esp,%ebp
f0102eb6:	83 ec 18             	sub    $0x18,%esp
f0102eb9:	8b 45 08             	mov    0x8(%ebp),%eax
f0102ebc:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0102ebf:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0102ec2:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0102ec6:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0102ec9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0102ed0:	85 c0                	test   %eax,%eax
f0102ed2:	74 26                	je     f0102efa <vsnprintf+0x47>
f0102ed4:	85 d2                	test   %edx,%edx
f0102ed6:	7e 29                	jle    f0102f01 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0102ed8:	ff 75 14             	pushl  0x14(%ebp)
f0102edb:	ff 75 10             	pushl  0x10(%ebp)
f0102ede:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0102ee1:	50                   	push   %eax
f0102ee2:	68 61 2a 10 f0       	push   $0xf0102a61
f0102ee7:	e8 ae fb ff ff       	call   f0102a9a <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0102eec:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0102eef:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0102ef2:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0102ef5:	83 c4 10             	add    $0x10,%esp
}
f0102ef8:	c9                   	leave  
f0102ef9:	c3                   	ret    
		return -E_INVAL;
f0102efa:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0102eff:	eb f7                	jmp    f0102ef8 <vsnprintf+0x45>
f0102f01:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0102f06:	eb f0                	jmp    f0102ef8 <vsnprintf+0x45>

f0102f08 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0102f08:	55                   	push   %ebp
f0102f09:	89 e5                	mov    %esp,%ebp
f0102f0b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0102f0e:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0102f11:	50                   	push   %eax
f0102f12:	ff 75 10             	pushl  0x10(%ebp)
f0102f15:	ff 75 0c             	pushl  0xc(%ebp)
f0102f18:	ff 75 08             	pushl  0x8(%ebp)
f0102f1b:	e8 93 ff ff ff       	call   f0102eb3 <vsnprintf>
	va_end(ap);

	return rc;
}
f0102f20:	c9                   	leave  
f0102f21:	c3                   	ret    

f0102f22 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0102f22:	55                   	push   %ebp
f0102f23:	89 e5                	mov    %esp,%ebp
f0102f25:	57                   	push   %edi
f0102f26:	56                   	push   %esi
f0102f27:	53                   	push   %ebx
f0102f28:	83 ec 0c             	sub    $0xc,%esp
f0102f2b:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f0102f2e:	85 c0                	test   %eax,%eax
f0102f30:	74 11                	je     f0102f43 <readline+0x21>
		cprintf("%s", prompt);
f0102f32:	83 ec 08             	sub    $0x8,%esp
f0102f35:	50                   	push   %eax
f0102f36:	68 63 3a 10 f0       	push   $0xf0103a63
f0102f3b:	e8 93 f7 ff ff       	call   f01026d3 <cprintf>
f0102f40:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f0102f43:	83 ec 0c             	sub    $0xc,%esp
f0102f46:	6a 00                	push   $0x0
f0102f48:	e8 9a d6 ff ff       	call   f01005e7 <iscons>
f0102f4d:	89 c7                	mov    %eax,%edi
f0102f4f:	83 c4 10             	add    $0x10,%esp
	i = 0;
f0102f52:	be 00 00 00 00       	mov    $0x0,%esi
f0102f57:	eb 75                	jmp    f0102fce <readline+0xac>
	while (1) {
		c = getchar();
		if (c < 0) {
			cprintf("read error: %e\n", c);
f0102f59:	83 ec 08             	sub    $0x8,%esp
f0102f5c:	50                   	push   %eax
f0102f5d:	68 c4 46 10 f0       	push   $0xf01046c4
f0102f62:	e8 6c f7 ff ff       	call   f01026d3 <cprintf>
			return NULL;
f0102f67:	83 c4 10             	add    $0x10,%esp
f0102f6a:	b8 00 00 00 00       	mov    $0x0,%eax
				cputchar('\n');
			buf[i] = 0;
			return buf;
		}
	}
}
f0102f6f:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102f72:	5b                   	pop    %ebx
f0102f73:	5e                   	pop    %esi
f0102f74:	5f                   	pop    %edi
f0102f75:	5d                   	pop    %ebp
f0102f76:	c3                   	ret    
				cputchar('\b');
f0102f77:	83 ec 0c             	sub    $0xc,%esp
f0102f7a:	6a 08                	push   $0x8
f0102f7c:	e8 45 d6 ff ff       	call   f01005c6 <cputchar>
f0102f81:	83 c4 10             	add    $0x10,%esp
f0102f84:	eb 47                	jmp    f0102fcd <readline+0xab>
				cputchar(c);
f0102f86:	83 ec 0c             	sub    $0xc,%esp
f0102f89:	53                   	push   %ebx
f0102f8a:	e8 37 d6 ff ff       	call   f01005c6 <cputchar>
f0102f8f:	83 c4 10             	add    $0x10,%esp
f0102f92:	eb 60                	jmp    f0102ff4 <readline+0xd2>
		} else if (c == '\n' || c == '\r') {
f0102f94:	83 f8 0a             	cmp    $0xa,%eax
f0102f97:	74 05                	je     f0102f9e <readline+0x7c>
f0102f99:	83 f8 0d             	cmp    $0xd,%eax
f0102f9c:	75 30                	jne    f0102fce <readline+0xac>
			if (echoing)
f0102f9e:	85 ff                	test   %edi,%edi
f0102fa0:	75 0e                	jne    f0102fb0 <readline+0x8e>
			buf[i] = 0;
f0102fa2:	c6 86 60 85 11 f0 00 	movb   $0x0,-0xfee7aa0(%esi)
			return buf;
f0102fa9:	b8 60 85 11 f0       	mov    $0xf0118560,%eax
f0102fae:	eb bf                	jmp    f0102f6f <readline+0x4d>
				cputchar('\n');
f0102fb0:	83 ec 0c             	sub    $0xc,%esp
f0102fb3:	6a 0a                	push   $0xa
f0102fb5:	e8 0c d6 ff ff       	call   f01005c6 <cputchar>
f0102fba:	83 c4 10             	add    $0x10,%esp
f0102fbd:	eb e3                	jmp    f0102fa2 <readline+0x80>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0102fbf:	85 f6                	test   %esi,%esi
f0102fc1:	7f 06                	jg     f0102fc9 <readline+0xa7>
f0102fc3:	eb 23                	jmp    f0102fe8 <readline+0xc6>
f0102fc5:	85 f6                	test   %esi,%esi
f0102fc7:	7e 05                	jle    f0102fce <readline+0xac>
			if (echoing)
f0102fc9:	85 ff                	test   %edi,%edi
f0102fcb:	75 aa                	jne    f0102f77 <readline+0x55>
			i--;
f0102fcd:	4e                   	dec    %esi
		c = getchar();
f0102fce:	e8 03 d6 ff ff       	call   f01005d6 <getchar>
f0102fd3:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f0102fd5:	85 c0                	test   %eax,%eax
f0102fd7:	78 80                	js     f0102f59 <readline+0x37>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0102fd9:	83 f8 08             	cmp    $0x8,%eax
f0102fdc:	74 e7                	je     f0102fc5 <readline+0xa3>
f0102fde:	83 f8 7f             	cmp    $0x7f,%eax
f0102fe1:	74 dc                	je     f0102fbf <readline+0x9d>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0102fe3:	83 f8 1f             	cmp    $0x1f,%eax
f0102fe6:	7e ac                	jle    f0102f94 <readline+0x72>
f0102fe8:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0102fee:	7f de                	jg     f0102fce <readline+0xac>
			if (echoing)
f0102ff0:	85 ff                	test   %edi,%edi
f0102ff2:	75 92                	jne    f0102f86 <readline+0x64>
			buf[i++] = c;
f0102ff4:	88 9e 60 85 11 f0    	mov    %bl,-0xfee7aa0(%esi)
f0102ffa:	8d 76 01             	lea    0x1(%esi),%esi
f0102ffd:	eb cf                	jmp    f0102fce <readline+0xac>

f0102fff <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0102fff:	55                   	push   %ebp
f0103000:	89 e5                	mov    %esp,%ebp
f0103002:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0103005:	b8 00 00 00 00       	mov    $0x0,%eax
f010300a:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f010300e:	74 03                	je     f0103013 <strlen+0x14>
		n++;
f0103010:	40                   	inc    %eax
f0103011:	eb f7                	jmp    f010300a <strlen+0xb>
	return n;
}
f0103013:	5d                   	pop    %ebp
f0103014:	c3                   	ret    

f0103015 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0103015:	55                   	push   %ebp
f0103016:	89 e5                	mov    %esp,%ebp
f0103018:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010301b:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f010301e:	b8 00 00 00 00       	mov    $0x0,%eax
f0103023:	39 d0                	cmp    %edx,%eax
f0103025:	74 0b                	je     f0103032 <strnlen+0x1d>
f0103027:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f010302b:	74 03                	je     f0103030 <strnlen+0x1b>
		n++;
f010302d:	40                   	inc    %eax
f010302e:	eb f3                	jmp    f0103023 <strnlen+0xe>
f0103030:	89 c2                	mov    %eax,%edx
	return n;
}
f0103032:	89 d0                	mov    %edx,%eax
f0103034:	5d                   	pop    %ebp
f0103035:	c3                   	ret    

f0103036 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0103036:	55                   	push   %ebp
f0103037:	89 e5                	mov    %esp,%ebp
f0103039:	53                   	push   %ebx
f010303a:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010303d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0103040:	b8 00 00 00 00       	mov    $0x0,%eax
f0103045:	8a 14 03             	mov    (%ebx,%eax,1),%dl
f0103048:	88 14 01             	mov    %dl,(%ecx,%eax,1)
f010304b:	40                   	inc    %eax
f010304c:	84 d2                	test   %dl,%dl
f010304e:	75 f5                	jne    f0103045 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
f0103050:	89 c8                	mov    %ecx,%eax
f0103052:	5b                   	pop    %ebx
f0103053:	5d                   	pop    %ebp
f0103054:	c3                   	ret    

f0103055 <strcat>:

char *
strcat(char *dst, const char *src)
{
f0103055:	55                   	push   %ebp
f0103056:	89 e5                	mov    %esp,%ebp
f0103058:	53                   	push   %ebx
f0103059:	83 ec 10             	sub    $0x10,%esp
f010305c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f010305f:	53                   	push   %ebx
f0103060:	e8 9a ff ff ff       	call   f0102fff <strlen>
f0103065:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
f0103068:	ff 75 0c             	pushl  0xc(%ebp)
f010306b:	01 d8                	add    %ebx,%eax
f010306d:	50                   	push   %eax
f010306e:	e8 c3 ff ff ff       	call   f0103036 <strcpy>
	return dst;
}
f0103073:	89 d8                	mov    %ebx,%eax
f0103075:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103078:	c9                   	leave  
f0103079:	c3                   	ret    

f010307a <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f010307a:	55                   	push   %ebp
f010307b:	89 e5                	mov    %esp,%ebp
f010307d:	53                   	push   %ebx
f010307e:	8b 55 0c             	mov    0xc(%ebp),%edx
f0103081:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0103084:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0103087:	8b 45 08             	mov    0x8(%ebp),%eax
f010308a:	39 d8                	cmp    %ebx,%eax
f010308c:	74 0e                	je     f010309c <strncpy+0x22>
		*dst++ = *src;
f010308e:	40                   	inc    %eax
f010308f:	8a 0a                	mov    (%edx),%cl
f0103091:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0103094:	80 f9 01             	cmp    $0x1,%cl
f0103097:	83 da ff             	sbb    $0xffffffff,%edx
f010309a:	eb ee                	jmp    f010308a <strncpy+0x10>
	}
	return ret;
}
f010309c:	8b 45 08             	mov    0x8(%ebp),%eax
f010309f:	5b                   	pop    %ebx
f01030a0:	5d                   	pop    %ebp
f01030a1:	c3                   	ret    

f01030a2 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f01030a2:	55                   	push   %ebp
f01030a3:	89 e5                	mov    %esp,%ebp
f01030a5:	56                   	push   %esi
f01030a6:	53                   	push   %ebx
f01030a7:	8b 75 08             	mov    0x8(%ebp),%esi
f01030aa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01030ad:	8b 45 10             	mov    0x10(%ebp),%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f01030b0:	85 c0                	test   %eax,%eax
f01030b2:	74 22                	je     f01030d6 <strlcpy+0x34>
f01030b4:	8d 44 06 ff          	lea    -0x1(%esi,%eax,1),%eax
f01030b8:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
f01030ba:	39 c2                	cmp    %eax,%edx
f01030bc:	74 0f                	je     f01030cd <strlcpy+0x2b>
f01030be:	8a 19                	mov    (%ecx),%bl
f01030c0:	84 db                	test   %bl,%bl
f01030c2:	74 07                	je     f01030cb <strlcpy+0x29>
			*dst++ = *src++;
f01030c4:	41                   	inc    %ecx
f01030c5:	42                   	inc    %edx
f01030c6:	88 5a ff             	mov    %bl,-0x1(%edx)
f01030c9:	eb ef                	jmp    f01030ba <strlcpy+0x18>
f01030cb:	89 d0                	mov    %edx,%eax
		*dst = '\0';
f01030cd:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f01030d0:	29 f0                	sub    %esi,%eax
}
f01030d2:	5b                   	pop    %ebx
f01030d3:	5e                   	pop    %esi
f01030d4:	5d                   	pop    %ebp
f01030d5:	c3                   	ret    
f01030d6:	89 f0                	mov    %esi,%eax
f01030d8:	eb f6                	jmp    f01030d0 <strlcpy+0x2e>

f01030da <strcmp>:

int
strcmp(const char *p, const char *q)
{
f01030da:	55                   	push   %ebp
f01030db:	89 e5                	mov    %esp,%ebp
f01030dd:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01030e0:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f01030e3:	8a 01                	mov    (%ecx),%al
f01030e5:	84 c0                	test   %al,%al
f01030e7:	74 08                	je     f01030f1 <strcmp+0x17>
f01030e9:	3a 02                	cmp    (%edx),%al
f01030eb:	75 04                	jne    f01030f1 <strcmp+0x17>
		p++, q++;
f01030ed:	41                   	inc    %ecx
f01030ee:	42                   	inc    %edx
f01030ef:	eb f2                	jmp    f01030e3 <strcmp+0x9>
	return (int) ((unsigned char) *p - (unsigned char) *q);
f01030f1:	0f b6 c0             	movzbl %al,%eax
f01030f4:	0f b6 12             	movzbl (%edx),%edx
f01030f7:	29 d0                	sub    %edx,%eax
}
f01030f9:	5d                   	pop    %ebp
f01030fa:	c3                   	ret    

f01030fb <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f01030fb:	55                   	push   %ebp
f01030fc:	89 e5                	mov    %esp,%ebp
f01030fe:	53                   	push   %ebx
f01030ff:	8b 45 08             	mov    0x8(%ebp),%eax
f0103102:	8b 55 0c             	mov    0xc(%ebp),%edx
f0103105:	89 c3                	mov    %eax,%ebx
f0103107:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f010310a:	eb 02                	jmp    f010310e <strncmp+0x13>
		n--, p++, q++;
f010310c:	40                   	inc    %eax
f010310d:	42                   	inc    %edx
	while (n > 0 && *p && *p == *q)
f010310e:	39 d8                	cmp    %ebx,%eax
f0103110:	74 15                	je     f0103127 <strncmp+0x2c>
f0103112:	8a 08                	mov    (%eax),%cl
f0103114:	84 c9                	test   %cl,%cl
f0103116:	74 04                	je     f010311c <strncmp+0x21>
f0103118:	3a 0a                	cmp    (%edx),%cl
f010311a:	74 f0                	je     f010310c <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f010311c:	0f b6 00             	movzbl (%eax),%eax
f010311f:	0f b6 12             	movzbl (%edx),%edx
f0103122:	29 d0                	sub    %edx,%eax
}
f0103124:	5b                   	pop    %ebx
f0103125:	5d                   	pop    %ebp
f0103126:	c3                   	ret    
		return 0;
f0103127:	b8 00 00 00 00       	mov    $0x0,%eax
f010312c:	eb f6                	jmp    f0103124 <strncmp+0x29>

f010312e <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f010312e:	55                   	push   %ebp
f010312f:	89 e5                	mov    %esp,%ebp
f0103131:	8b 45 08             	mov    0x8(%ebp),%eax
f0103134:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
f0103137:	8a 10                	mov    (%eax),%dl
f0103139:	84 d2                	test   %dl,%dl
f010313b:	74 07                	je     f0103144 <strchr+0x16>
		if (*s == c)
f010313d:	38 ca                	cmp    %cl,%dl
f010313f:	74 08                	je     f0103149 <strchr+0x1b>
	for (; *s; s++)
f0103141:	40                   	inc    %eax
f0103142:	eb f3                	jmp    f0103137 <strchr+0x9>
			return (char *) s;
	return 0;
f0103144:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103149:	5d                   	pop    %ebp
f010314a:	c3                   	ret    

f010314b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f010314b:	55                   	push   %ebp
f010314c:	89 e5                	mov    %esp,%ebp
f010314e:	8b 45 08             	mov    0x8(%ebp),%eax
f0103151:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
f0103154:	8a 10                	mov    (%eax),%dl
f0103156:	84 d2                	test   %dl,%dl
f0103158:	74 07                	je     f0103161 <strfind+0x16>
		if (*s == c)
f010315a:	38 ca                	cmp    %cl,%dl
f010315c:	74 03                	je     f0103161 <strfind+0x16>
	for (; *s; s++)
f010315e:	40                   	inc    %eax
f010315f:	eb f3                	jmp    f0103154 <strfind+0x9>
			break;
	return (char *) s;
}
f0103161:	5d                   	pop    %ebp
f0103162:	c3                   	ret    

f0103163 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0103163:	55                   	push   %ebp
f0103164:	89 e5                	mov    %esp,%ebp
f0103166:	57                   	push   %edi
f0103167:	56                   	push   %esi
f0103168:	53                   	push   %ebx
f0103169:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f010316c:	85 c9                	test   %ecx,%ecx
f010316e:	74 36                	je     f01031a6 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0103170:	89 c8                	mov    %ecx,%eax
f0103172:	0b 45 08             	or     0x8(%ebp),%eax
f0103175:	a8 03                	test   $0x3,%al
f0103177:	75 24                	jne    f010319d <memset+0x3a>
		c &= 0xFF;
f0103179:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f010317d:	89 d3                	mov    %edx,%ebx
f010317f:	c1 e3 08             	shl    $0x8,%ebx
f0103182:	89 d0                	mov    %edx,%eax
f0103184:	c1 e0 18             	shl    $0x18,%eax
f0103187:	89 d6                	mov    %edx,%esi
f0103189:	c1 e6 10             	shl    $0x10,%esi
f010318c:	09 f0                	or     %esi,%eax
f010318e:	09 d0                	or     %edx,%eax
f0103190:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f0103192:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
f0103195:	8b 7d 08             	mov    0x8(%ebp),%edi
f0103198:	fc                   	cld    
f0103199:	f3 ab                	rep stos %eax,%es:(%edi)
f010319b:	eb 09                	jmp    f01031a6 <memset+0x43>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f010319d:	8b 7d 08             	mov    0x8(%ebp),%edi
f01031a0:	8b 45 0c             	mov    0xc(%ebp),%eax
f01031a3:	fc                   	cld    
f01031a4:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f01031a6:	8b 45 08             	mov    0x8(%ebp),%eax
f01031a9:	5b                   	pop    %ebx
f01031aa:	5e                   	pop    %esi
f01031ab:	5f                   	pop    %edi
f01031ac:	5d                   	pop    %ebp
f01031ad:	c3                   	ret    

f01031ae <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f01031ae:	55                   	push   %ebp
f01031af:	89 e5                	mov    %esp,%ebp
f01031b1:	57                   	push   %edi
f01031b2:	56                   	push   %esi
f01031b3:	8b 45 08             	mov    0x8(%ebp),%eax
f01031b6:	8b 75 0c             	mov    0xc(%ebp),%esi
f01031b9:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f01031bc:	39 c6                	cmp    %eax,%esi
f01031be:	73 30                	jae    f01031f0 <memmove+0x42>
f01031c0:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f01031c3:	39 c2                	cmp    %eax,%edx
f01031c5:	76 29                	jbe    f01031f0 <memmove+0x42>
		s += n;
		d += n;
f01031c7:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01031ca:	89 fe                	mov    %edi,%esi
f01031cc:	09 ce                	or     %ecx,%esi
f01031ce:	09 d6                	or     %edx,%esi
f01031d0:	f7 c6 03 00 00 00    	test   $0x3,%esi
f01031d6:	75 0e                	jne    f01031e6 <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f01031d8:	83 ef 04             	sub    $0x4,%edi
f01031db:	8d 72 fc             	lea    -0x4(%edx),%esi
f01031de:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
f01031e1:	fd                   	std    
f01031e2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01031e4:	eb 07                	jmp    f01031ed <memmove+0x3f>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f01031e6:	4f                   	dec    %edi
f01031e7:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
f01031ea:	fd                   	std    
f01031eb:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f01031ed:	fc                   	cld    
f01031ee:	eb 1a                	jmp    f010320a <memmove+0x5c>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01031f0:	89 c2                	mov    %eax,%edx
f01031f2:	09 ca                	or     %ecx,%edx
f01031f4:	09 f2                	or     %esi,%edx
f01031f6:	f6 c2 03             	test   $0x3,%dl
f01031f9:	75 0a                	jne    f0103205 <memmove+0x57>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f01031fb:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
f01031fe:	89 c7                	mov    %eax,%edi
f0103200:	fc                   	cld    
f0103201:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0103203:	eb 05                	jmp    f010320a <memmove+0x5c>
		else
			asm volatile("cld; rep movsb\n"
f0103205:	89 c7                	mov    %eax,%edi
f0103207:	fc                   	cld    
f0103208:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f010320a:	5e                   	pop    %esi
f010320b:	5f                   	pop    %edi
f010320c:	5d                   	pop    %ebp
f010320d:	c3                   	ret    

f010320e <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f010320e:	55                   	push   %ebp
f010320f:	89 e5                	mov    %esp,%ebp
f0103211:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f0103214:	ff 75 10             	pushl  0x10(%ebp)
f0103217:	ff 75 0c             	pushl  0xc(%ebp)
f010321a:	ff 75 08             	pushl  0x8(%ebp)
f010321d:	e8 8c ff ff ff       	call   f01031ae <memmove>
}
f0103222:	c9                   	leave  
f0103223:	c3                   	ret    

f0103224 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0103224:	55                   	push   %ebp
f0103225:	89 e5                	mov    %esp,%ebp
f0103227:	56                   	push   %esi
f0103228:	53                   	push   %ebx
f0103229:	8b 45 08             	mov    0x8(%ebp),%eax
f010322c:	8b 55 0c             	mov    0xc(%ebp),%edx
f010322f:	89 c6                	mov    %eax,%esi
f0103231:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0103234:	39 f0                	cmp    %esi,%eax
f0103236:	74 16                	je     f010324e <memcmp+0x2a>
		if (*s1 != *s2)
f0103238:	8a 08                	mov    (%eax),%cl
f010323a:	8a 1a                	mov    (%edx),%bl
f010323c:	38 d9                	cmp    %bl,%cl
f010323e:	75 04                	jne    f0103244 <memcmp+0x20>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
f0103240:	40                   	inc    %eax
f0103241:	42                   	inc    %edx
f0103242:	eb f0                	jmp    f0103234 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
f0103244:	0f b6 c1             	movzbl %cl,%eax
f0103247:	0f b6 db             	movzbl %bl,%ebx
f010324a:	29 d8                	sub    %ebx,%eax
f010324c:	eb 05                	jmp    f0103253 <memcmp+0x2f>
	}

	return 0;
f010324e:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103253:	5b                   	pop    %ebx
f0103254:	5e                   	pop    %esi
f0103255:	5d                   	pop    %ebp
f0103256:	c3                   	ret    

f0103257 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0103257:	55                   	push   %ebp
f0103258:	89 e5                	mov    %esp,%ebp
f010325a:	8b 45 08             	mov    0x8(%ebp),%eax
f010325d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f0103260:	89 c2                	mov    %eax,%edx
f0103262:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f0103265:	39 d0                	cmp    %edx,%eax
f0103267:	73 07                	jae    f0103270 <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
f0103269:	38 08                	cmp    %cl,(%eax)
f010326b:	74 03                	je     f0103270 <memfind+0x19>
	for (; s < ends; s++)
f010326d:	40                   	inc    %eax
f010326e:	eb f5                	jmp    f0103265 <memfind+0xe>
			break;
	return (void *) s;
}
f0103270:	5d                   	pop    %ebp
f0103271:	c3                   	ret    

f0103272 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0103272:	55                   	push   %ebp
f0103273:	89 e5                	mov    %esp,%ebp
f0103275:	57                   	push   %edi
f0103276:	56                   	push   %esi
f0103277:	53                   	push   %ebx
f0103278:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010327b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f010327e:	eb 01                	jmp    f0103281 <strtol+0xf>
		s++;
f0103280:	41                   	inc    %ecx
	while (*s == ' ' || *s == '\t')
f0103281:	8a 01                	mov    (%ecx),%al
f0103283:	3c 20                	cmp    $0x20,%al
f0103285:	74 f9                	je     f0103280 <strtol+0xe>
f0103287:	3c 09                	cmp    $0x9,%al
f0103289:	74 f5                	je     f0103280 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
f010328b:	3c 2b                	cmp    $0x2b,%al
f010328d:	74 24                	je     f01032b3 <strtol+0x41>
		s++;
	else if (*s == '-')
f010328f:	3c 2d                	cmp    $0x2d,%al
f0103291:	74 28                	je     f01032bb <strtol+0x49>
	int neg = 0;
f0103293:	bf 00 00 00 00       	mov    $0x0,%edi
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0103298:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f010329e:	75 09                	jne    f01032a9 <strtol+0x37>
f01032a0:	80 39 30             	cmpb   $0x30,(%ecx)
f01032a3:	74 1e                	je     f01032c3 <strtol+0x51>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f01032a5:	85 db                	test   %ebx,%ebx
f01032a7:	74 36                	je     f01032df <strtol+0x6d>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f01032a9:	b8 00 00 00 00       	mov    $0x0,%eax
f01032ae:	89 5d 10             	mov    %ebx,0x10(%ebp)
f01032b1:	eb 45                	jmp    f01032f8 <strtol+0x86>
		s++;
f01032b3:	41                   	inc    %ecx
	int neg = 0;
f01032b4:	bf 00 00 00 00       	mov    $0x0,%edi
f01032b9:	eb dd                	jmp    f0103298 <strtol+0x26>
		s++, neg = 1;
f01032bb:	41                   	inc    %ecx
f01032bc:	bf 01 00 00 00       	mov    $0x1,%edi
f01032c1:	eb d5                	jmp    f0103298 <strtol+0x26>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f01032c3:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f01032c7:	74 0c                	je     f01032d5 <strtol+0x63>
	else if (base == 0 && s[0] == '0')
f01032c9:	85 db                	test   %ebx,%ebx
f01032cb:	75 dc                	jne    f01032a9 <strtol+0x37>
		s++, base = 8;
f01032cd:	41                   	inc    %ecx
f01032ce:	bb 08 00 00 00       	mov    $0x8,%ebx
f01032d3:	eb d4                	jmp    f01032a9 <strtol+0x37>
		s += 2, base = 16;
f01032d5:	83 c1 02             	add    $0x2,%ecx
f01032d8:	bb 10 00 00 00       	mov    $0x10,%ebx
f01032dd:	eb ca                	jmp    f01032a9 <strtol+0x37>
		base = 10;
f01032df:	bb 0a 00 00 00       	mov    $0xa,%ebx
f01032e4:	eb c3                	jmp    f01032a9 <strtol+0x37>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
f01032e6:	0f be d2             	movsbl %dl,%edx
f01032e9:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f01032ec:	3b 55 10             	cmp    0x10(%ebp),%edx
f01032ef:	7d 37                	jge    f0103328 <strtol+0xb6>
			break;
		s++, val = (val * base) + dig;
f01032f1:	41                   	inc    %ecx
f01032f2:	0f af 45 10          	imul   0x10(%ebp),%eax
f01032f6:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
f01032f8:	8a 11                	mov    (%ecx),%dl
f01032fa:	8d 72 d0             	lea    -0x30(%edx),%esi
f01032fd:	89 f3                	mov    %esi,%ebx
f01032ff:	80 fb 09             	cmp    $0x9,%bl
f0103302:	76 e2                	jbe    f01032e6 <strtol+0x74>
		else if (*s >= 'a' && *s <= 'z')
f0103304:	8d 72 9f             	lea    -0x61(%edx),%esi
f0103307:	89 f3                	mov    %esi,%ebx
f0103309:	80 fb 19             	cmp    $0x19,%bl
f010330c:	77 08                	ja     f0103316 <strtol+0xa4>
			dig = *s - 'a' + 10;
f010330e:	0f be d2             	movsbl %dl,%edx
f0103311:	83 ea 57             	sub    $0x57,%edx
f0103314:	eb d6                	jmp    f01032ec <strtol+0x7a>
		else if (*s >= 'A' && *s <= 'Z')
f0103316:	8d 72 bf             	lea    -0x41(%edx),%esi
f0103319:	89 f3                	mov    %esi,%ebx
f010331b:	80 fb 19             	cmp    $0x19,%bl
f010331e:	77 08                	ja     f0103328 <strtol+0xb6>
			dig = *s - 'A' + 10;
f0103320:	0f be d2             	movsbl %dl,%edx
f0103323:	83 ea 37             	sub    $0x37,%edx
f0103326:	eb c4                	jmp    f01032ec <strtol+0x7a>
		// we don't properly detect overflow!
	}

	if (endptr)
f0103328:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f010332c:	74 05                	je     f0103333 <strtol+0xc1>
		*endptr = (char *) s;
f010332e:	8b 75 0c             	mov    0xc(%ebp),%esi
f0103331:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
f0103333:	85 ff                	test   %edi,%edi
f0103335:	74 02                	je     f0103339 <strtol+0xc7>
f0103337:	f7 d8                	neg    %eax
}
f0103339:	5b                   	pop    %ebx
f010333a:	5e                   	pop    %esi
f010333b:	5f                   	pop    %edi
f010333c:	5d                   	pop    %ebp
f010333d:	c3                   	ret    
f010333e:	66 90                	xchg   %ax,%ax

f0103340 <__udivdi3>:
f0103340:	55                   	push   %ebp
f0103341:	57                   	push   %edi
f0103342:	56                   	push   %esi
f0103343:	53                   	push   %ebx
f0103344:	83 ec 1c             	sub    $0x1c,%esp
f0103347:	8b 6c 24 30          	mov    0x30(%esp),%ebp
f010334b:	8b 74 24 34          	mov    0x34(%esp),%esi
f010334f:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0103353:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f0103357:	85 d2                	test   %edx,%edx
f0103359:	75 19                	jne    f0103374 <__udivdi3+0x34>
f010335b:	39 f7                	cmp    %esi,%edi
f010335d:	76 45                	jbe    f01033a4 <__udivdi3+0x64>
f010335f:	89 e8                	mov    %ebp,%eax
f0103361:	89 f2                	mov    %esi,%edx
f0103363:	f7 f7                	div    %edi
f0103365:	31 db                	xor    %ebx,%ebx
f0103367:	89 da                	mov    %ebx,%edx
f0103369:	83 c4 1c             	add    $0x1c,%esp
f010336c:	5b                   	pop    %ebx
f010336d:	5e                   	pop    %esi
f010336e:	5f                   	pop    %edi
f010336f:	5d                   	pop    %ebp
f0103370:	c3                   	ret    
f0103371:	8d 76 00             	lea    0x0(%esi),%esi
f0103374:	39 f2                	cmp    %esi,%edx
f0103376:	76 10                	jbe    f0103388 <__udivdi3+0x48>
f0103378:	31 db                	xor    %ebx,%ebx
f010337a:	31 c0                	xor    %eax,%eax
f010337c:	89 da                	mov    %ebx,%edx
f010337e:	83 c4 1c             	add    $0x1c,%esp
f0103381:	5b                   	pop    %ebx
f0103382:	5e                   	pop    %esi
f0103383:	5f                   	pop    %edi
f0103384:	5d                   	pop    %ebp
f0103385:	c3                   	ret    
f0103386:	66 90                	xchg   %ax,%ax
f0103388:	0f bd da             	bsr    %edx,%ebx
f010338b:	83 f3 1f             	xor    $0x1f,%ebx
f010338e:	75 3c                	jne    f01033cc <__udivdi3+0x8c>
f0103390:	39 f2                	cmp    %esi,%edx
f0103392:	72 08                	jb     f010339c <__udivdi3+0x5c>
f0103394:	39 ef                	cmp    %ebp,%edi
f0103396:	0f 87 9c 00 00 00    	ja     f0103438 <__udivdi3+0xf8>
f010339c:	b8 01 00 00 00       	mov    $0x1,%eax
f01033a1:	eb d9                	jmp    f010337c <__udivdi3+0x3c>
f01033a3:	90                   	nop
f01033a4:	89 f9                	mov    %edi,%ecx
f01033a6:	85 ff                	test   %edi,%edi
f01033a8:	75 0b                	jne    f01033b5 <__udivdi3+0x75>
f01033aa:	b8 01 00 00 00       	mov    $0x1,%eax
f01033af:	31 d2                	xor    %edx,%edx
f01033b1:	f7 f7                	div    %edi
f01033b3:	89 c1                	mov    %eax,%ecx
f01033b5:	31 d2                	xor    %edx,%edx
f01033b7:	89 f0                	mov    %esi,%eax
f01033b9:	f7 f1                	div    %ecx
f01033bb:	89 c3                	mov    %eax,%ebx
f01033bd:	89 e8                	mov    %ebp,%eax
f01033bf:	f7 f1                	div    %ecx
f01033c1:	89 da                	mov    %ebx,%edx
f01033c3:	83 c4 1c             	add    $0x1c,%esp
f01033c6:	5b                   	pop    %ebx
f01033c7:	5e                   	pop    %esi
f01033c8:	5f                   	pop    %edi
f01033c9:	5d                   	pop    %ebp
f01033ca:	c3                   	ret    
f01033cb:	90                   	nop
f01033cc:	b8 20 00 00 00       	mov    $0x20,%eax
f01033d1:	29 d8                	sub    %ebx,%eax
f01033d3:	88 d9                	mov    %bl,%cl
f01033d5:	d3 e2                	shl    %cl,%edx
f01033d7:	89 54 24 08          	mov    %edx,0x8(%esp)
f01033db:	89 fa                	mov    %edi,%edx
f01033dd:	88 c1                	mov    %al,%cl
f01033df:	d3 ea                	shr    %cl,%edx
f01033e1:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f01033e5:	09 d1                	or     %edx,%ecx
f01033e7:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01033eb:	88 d9                	mov    %bl,%cl
f01033ed:	d3 e7                	shl    %cl,%edi
f01033ef:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f01033f3:	89 f7                	mov    %esi,%edi
f01033f5:	88 c1                	mov    %al,%cl
f01033f7:	d3 ef                	shr    %cl,%edi
f01033f9:	88 d9                	mov    %bl,%cl
f01033fb:	d3 e6                	shl    %cl,%esi
f01033fd:	89 ea                	mov    %ebp,%edx
f01033ff:	88 c1                	mov    %al,%cl
f0103401:	d3 ea                	shr    %cl,%edx
f0103403:	09 d6                	or     %edx,%esi
f0103405:	89 f0                	mov    %esi,%eax
f0103407:	89 fa                	mov    %edi,%edx
f0103409:	f7 74 24 08          	divl   0x8(%esp)
f010340d:	89 d7                	mov    %edx,%edi
f010340f:	89 c6                	mov    %eax,%esi
f0103411:	f7 64 24 0c          	mull   0xc(%esp)
f0103415:	39 d7                	cmp    %edx,%edi
f0103417:	72 13                	jb     f010342c <__udivdi3+0xec>
f0103419:	74 09                	je     f0103424 <__udivdi3+0xe4>
f010341b:	89 f0                	mov    %esi,%eax
f010341d:	31 db                	xor    %ebx,%ebx
f010341f:	e9 58 ff ff ff       	jmp    f010337c <__udivdi3+0x3c>
f0103424:	88 d9                	mov    %bl,%cl
f0103426:	d3 e5                	shl    %cl,%ebp
f0103428:	39 c5                	cmp    %eax,%ebp
f010342a:	73 ef                	jae    f010341b <__udivdi3+0xdb>
f010342c:	8d 46 ff             	lea    -0x1(%esi),%eax
f010342f:	31 db                	xor    %ebx,%ebx
f0103431:	e9 46 ff ff ff       	jmp    f010337c <__udivdi3+0x3c>
f0103436:	66 90                	xchg   %ax,%ax
f0103438:	31 c0                	xor    %eax,%eax
f010343a:	e9 3d ff ff ff       	jmp    f010337c <__udivdi3+0x3c>
f010343f:	90                   	nop

f0103440 <__umoddi3>:
f0103440:	55                   	push   %ebp
f0103441:	57                   	push   %edi
f0103442:	56                   	push   %esi
f0103443:	53                   	push   %ebx
f0103444:	83 ec 1c             	sub    $0x1c,%esp
f0103447:	8b 74 24 30          	mov    0x30(%esp),%esi
f010344b:	8b 5c 24 34          	mov    0x34(%esp),%ebx
f010344f:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0103453:	8b 44 24 3c          	mov    0x3c(%esp),%eax
f0103457:	85 c0                	test   %eax,%eax
f0103459:	75 19                	jne    f0103474 <__umoddi3+0x34>
f010345b:	39 df                	cmp    %ebx,%edi
f010345d:	76 51                	jbe    f01034b0 <__umoddi3+0x70>
f010345f:	89 f0                	mov    %esi,%eax
f0103461:	89 da                	mov    %ebx,%edx
f0103463:	f7 f7                	div    %edi
f0103465:	89 d0                	mov    %edx,%eax
f0103467:	31 d2                	xor    %edx,%edx
f0103469:	83 c4 1c             	add    $0x1c,%esp
f010346c:	5b                   	pop    %ebx
f010346d:	5e                   	pop    %esi
f010346e:	5f                   	pop    %edi
f010346f:	5d                   	pop    %ebp
f0103470:	c3                   	ret    
f0103471:	8d 76 00             	lea    0x0(%esi),%esi
f0103474:	89 f2                	mov    %esi,%edx
f0103476:	39 d8                	cmp    %ebx,%eax
f0103478:	76 0e                	jbe    f0103488 <__umoddi3+0x48>
f010347a:	89 f0                	mov    %esi,%eax
f010347c:	89 da                	mov    %ebx,%edx
f010347e:	83 c4 1c             	add    $0x1c,%esp
f0103481:	5b                   	pop    %ebx
f0103482:	5e                   	pop    %esi
f0103483:	5f                   	pop    %edi
f0103484:	5d                   	pop    %ebp
f0103485:	c3                   	ret    
f0103486:	66 90                	xchg   %ax,%ax
f0103488:	0f bd e8             	bsr    %eax,%ebp
f010348b:	83 f5 1f             	xor    $0x1f,%ebp
f010348e:	75 44                	jne    f01034d4 <__umoddi3+0x94>
f0103490:	39 d8                	cmp    %ebx,%eax
f0103492:	72 06                	jb     f010349a <__umoddi3+0x5a>
f0103494:	89 d9                	mov    %ebx,%ecx
f0103496:	39 f7                	cmp    %esi,%edi
f0103498:	77 08                	ja     f01034a2 <__umoddi3+0x62>
f010349a:	29 fe                	sub    %edi,%esi
f010349c:	19 c3                	sbb    %eax,%ebx
f010349e:	89 f2                	mov    %esi,%edx
f01034a0:	89 d9                	mov    %ebx,%ecx
f01034a2:	89 d0                	mov    %edx,%eax
f01034a4:	89 ca                	mov    %ecx,%edx
f01034a6:	83 c4 1c             	add    $0x1c,%esp
f01034a9:	5b                   	pop    %ebx
f01034aa:	5e                   	pop    %esi
f01034ab:	5f                   	pop    %edi
f01034ac:	5d                   	pop    %ebp
f01034ad:	c3                   	ret    
f01034ae:	66 90                	xchg   %ax,%ax
f01034b0:	89 fd                	mov    %edi,%ebp
f01034b2:	85 ff                	test   %edi,%edi
f01034b4:	75 0b                	jne    f01034c1 <__umoddi3+0x81>
f01034b6:	b8 01 00 00 00       	mov    $0x1,%eax
f01034bb:	31 d2                	xor    %edx,%edx
f01034bd:	f7 f7                	div    %edi
f01034bf:	89 c5                	mov    %eax,%ebp
f01034c1:	89 d8                	mov    %ebx,%eax
f01034c3:	31 d2                	xor    %edx,%edx
f01034c5:	f7 f5                	div    %ebp
f01034c7:	89 f0                	mov    %esi,%eax
f01034c9:	f7 f5                	div    %ebp
f01034cb:	89 d0                	mov    %edx,%eax
f01034cd:	31 d2                	xor    %edx,%edx
f01034cf:	eb 98                	jmp    f0103469 <__umoddi3+0x29>
f01034d1:	8d 76 00             	lea    0x0(%esi),%esi
f01034d4:	ba 20 00 00 00       	mov    $0x20,%edx
f01034d9:	29 ea                	sub    %ebp,%edx
f01034db:	89 e9                	mov    %ebp,%ecx
f01034dd:	d3 e0                	shl    %cl,%eax
f01034df:	89 44 24 08          	mov    %eax,0x8(%esp)
f01034e3:	89 f8                	mov    %edi,%eax
f01034e5:	89 54 24 04          	mov    %edx,0x4(%esp)
f01034e9:	88 d1                	mov    %dl,%cl
f01034eb:	d3 e8                	shr    %cl,%eax
f01034ed:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f01034f1:	09 c1                	or     %eax,%ecx
f01034f3:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01034f7:	89 e9                	mov    %ebp,%ecx
f01034f9:	d3 e7                	shl    %cl,%edi
f01034fb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f01034ff:	89 d8                	mov    %ebx,%eax
f0103501:	8b 54 24 04          	mov    0x4(%esp),%edx
f0103505:	88 d1                	mov    %dl,%cl
f0103507:	d3 e8                	shr    %cl,%eax
f0103509:	89 c7                	mov    %eax,%edi
f010350b:	89 e9                	mov    %ebp,%ecx
f010350d:	d3 e3                	shl    %cl,%ebx
f010350f:	89 f0                	mov    %esi,%eax
f0103511:	88 d1                	mov    %dl,%cl
f0103513:	d3 e8                	shr    %cl,%eax
f0103515:	09 d8                	or     %ebx,%eax
f0103517:	89 e9                	mov    %ebp,%ecx
f0103519:	d3 e6                	shl    %cl,%esi
f010351b:	89 f3                	mov    %esi,%ebx
f010351d:	89 fa                	mov    %edi,%edx
f010351f:	f7 74 24 08          	divl   0x8(%esp)
f0103523:	89 d1                	mov    %edx,%ecx
f0103525:	f7 64 24 0c          	mull   0xc(%esp)
f0103529:	89 c6                	mov    %eax,%esi
f010352b:	89 d7                	mov    %edx,%edi
f010352d:	39 d1                	cmp    %edx,%ecx
f010352f:	72 27                	jb     f0103558 <__umoddi3+0x118>
f0103531:	74 21                	je     f0103554 <__umoddi3+0x114>
f0103533:	89 ca                	mov    %ecx,%edx
f0103535:	29 f3                	sub    %esi,%ebx
f0103537:	19 fa                	sbb    %edi,%edx
f0103539:	89 d0                	mov    %edx,%eax
f010353b:	8a 4c 24 04          	mov    0x4(%esp),%cl
f010353f:	d3 e0                	shl    %cl,%eax
f0103541:	89 e9                	mov    %ebp,%ecx
f0103543:	d3 eb                	shr    %cl,%ebx
f0103545:	09 d8                	or     %ebx,%eax
f0103547:	d3 ea                	shr    %cl,%edx
f0103549:	83 c4 1c             	add    $0x1c,%esp
f010354c:	5b                   	pop    %ebx
f010354d:	5e                   	pop    %esi
f010354e:	5f                   	pop    %edi
f010354f:	5d                   	pop    %ebp
f0103550:	c3                   	ret    
f0103551:	8d 76 00             	lea    0x0(%esi),%esi
f0103554:	39 c3                	cmp    %eax,%ebx
f0103556:	73 db                	jae    f0103533 <__umoddi3+0xf3>
f0103558:	2b 44 24 0c          	sub    0xc(%esp),%eax
f010355c:	1b 54 24 08          	sbb    0x8(%esp),%edx
f0103560:	89 d7                	mov    %edx,%edi
f0103562:	89 c6                	mov    %eax,%esi
f0103564:	eb cd                	jmp    f0103533 <__umoddi3+0xf3>
