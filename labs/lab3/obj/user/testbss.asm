
obj/user/testbss:     file format elf32-i386


Disassembly of section .text:

00800020 <_start>:
// starts us running when we are initially loaded into a new environment.
.text
.globl _start
_start:
	// See if we were started with arguments on the stack
	cmpl $USTACKTOP, %esp
  800020:	81 fc 00 e0 bf ee    	cmp    $0xeebfe000,%esp
	jne args_exist
  800026:	75 04                	jne    80002c <args_exist>

	// If not, push dummy argc/argv arguments.
	// This happens when we are loaded by the kernel,
	// because the kernel does not know about passing arguments.
	pushl $0
  800028:	6a 00                	push   $0x0
	pushl $0
  80002a:	6a 00                	push   $0x0

0080002c <args_exist>:

args_exist:
	call libmain
  80002c:	e8 a5 00 00 00       	call   8000d6 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

uint32_t bigarray[ARRAYSIZE];

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 14             	sub    $0x14,%esp
	int i;

	cprintf("Making sure bss works right...\n");
  800039:	68 a0 0d 80 00       	push   $0x800da0
  80003e:	e8 de 01 00 00       	call   800221 <cprintf>
  800043:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < ARRAYSIZE; i++)
  800046:	b8 00 00 00 00       	mov    $0x0,%eax
		if (bigarray[i] != 0)
  80004b:	83 3c 85 20 20 80 00 	cmpl   $0x0,0x802020(,%eax,4)
  800052:	00 
  800053:	75 5d                	jne    8000b2 <umain+0x7f>
	for (i = 0; i < ARRAYSIZE; i++)
  800055:	40                   	inc    %eax
  800056:	3d 00 00 10 00       	cmp    $0x100000,%eax
  80005b:	75 ee                	jne    80004b <umain+0x18>
			panic("bigarray[%d] isn't cleared!\n", i);
	for (i = 0; i < ARRAYSIZE; i++)
  80005d:	b8 00 00 00 00       	mov    $0x0,%eax
		bigarray[i] = i;
  800062:	89 04 85 20 20 80 00 	mov    %eax,0x802020(,%eax,4)
	for (i = 0; i < ARRAYSIZE; i++)
  800069:	40                   	inc    %eax
  80006a:	3d 00 00 10 00       	cmp    $0x100000,%eax
  80006f:	75 f1                	jne    800062 <umain+0x2f>
	for (i = 0; i < ARRAYSIZE; i++)
  800071:	b8 00 00 00 00       	mov    $0x0,%eax
		if (bigarray[i] != i)
  800076:	39 04 85 20 20 80 00 	cmp    %eax,0x802020(,%eax,4)
  80007d:	75 45                	jne    8000c4 <umain+0x91>
	for (i = 0; i < ARRAYSIZE; i++)
  80007f:	40                   	inc    %eax
  800080:	3d 00 00 10 00       	cmp    $0x100000,%eax
  800085:	75 ef                	jne    800076 <umain+0x43>
			panic("bigarray[%d] didn't hold its value!\n", i);

	cprintf("Yes, good.  Now doing a wild write off the end...\n");
  800087:	83 ec 0c             	sub    $0xc,%esp
  80008a:	68 e8 0d 80 00       	push   $0x800de8
  80008f:	e8 8d 01 00 00       	call   800221 <cprintf>
	bigarray[ARRAYSIZE+1024] = 0;
  800094:	c7 05 20 30 c0 00 00 	movl   $0x0,0xc03020
  80009b:	00 00 00 
	panic("SHOULD HAVE TRAPPED!!!");
  80009e:	83 c4 0c             	add    $0xc,%esp
  8000a1:	68 47 0e 80 00       	push   $0x800e47
  8000a6:	6a 1a                	push   $0x1a
  8000a8:	68 38 0e 80 00       	push   $0x800e38
  8000ad:	e8 95 00 00 00       	call   800147 <_panic>
			panic("bigarray[%d] isn't cleared!\n", i);
  8000b2:	50                   	push   %eax
  8000b3:	68 1b 0e 80 00       	push   $0x800e1b
  8000b8:	6a 11                	push   $0x11
  8000ba:	68 38 0e 80 00       	push   $0x800e38
  8000bf:	e8 83 00 00 00       	call   800147 <_panic>
			panic("bigarray[%d] didn't hold its value!\n", i);
  8000c4:	50                   	push   %eax
  8000c5:	68 c0 0d 80 00       	push   $0x800dc0
  8000ca:	6a 16                	push   $0x16
  8000cc:	68 38 0e 80 00       	push   $0x800e38
  8000d1:	e8 71 00 00 00       	call   800147 <_panic>

008000d6 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000d6:	55                   	push   %ebp
  8000d7:	89 e5                	mov    %esp,%ebp
  8000d9:	57                   	push   %edi
  8000da:	56                   	push   %esi
  8000db:	53                   	push   %ebx
  8000dc:	83 ec 6c             	sub    $0x6c,%esp
  8000df:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	struct Env curenv = envs[ENVX(sys_getenvid())];
  8000e2:	e8 71 0a 00 00       	call   800b58 <sys_getenvid>
  8000e7:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000ec:	8d 34 00             	lea    (%eax,%eax,1),%esi
  8000ef:	01 c6                	add    %eax,%esi
  8000f1:	c1 e6 05             	shl    $0x5,%esi
  8000f4:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  8000fa:	8d 7d 88             	lea    -0x78(%ebp),%edi
  8000fd:	b9 18 00 00 00       	mov    $0x18,%ecx
  800102:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	thisenv = &curenv;
  800104:	8d 45 88             	lea    -0x78(%ebp),%eax
  800107:	a3 20 20 c0 00       	mov    %eax,0xc02020

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80010c:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800110:	7e 07                	jle    800119 <libmain+0x43>
		binaryname = argv[0];
  800112:	8b 03                	mov    (%ebx),%eax
  800114:	a3 00 20 80 00       	mov    %eax,0x802000
	
	// call user main routine
	umain(argc, argv);
  800119:	83 ec 08             	sub    $0x8,%esp
  80011c:	53                   	push   %ebx
  80011d:	ff 75 08             	pushl  0x8(%ebp)
  800120:	e8 0e ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800125:	e8 0b 00 00 00       	call   800135 <exit>
}
  80012a:	83 c4 10             	add    $0x10,%esp
  80012d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800130:	5b                   	pop    %ebx
  800131:	5e                   	pop    %esi
  800132:	5f                   	pop    %edi
  800133:	5d                   	pop    %ebp
  800134:	c3                   	ret    

00800135 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800135:	55                   	push   %ebp
  800136:	89 e5                	mov    %esp,%ebp
  800138:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  80013b:	6a 00                	push   $0x0
  80013d:	e8 d5 09 00 00       	call   800b17 <sys_env_destroy>
}
  800142:	83 c4 10             	add    $0x10,%esp
  800145:	c9                   	leave  
  800146:	c3                   	ret    

00800147 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800147:	55                   	push   %ebp
  800148:	89 e5                	mov    %esp,%ebp
  80014a:	56                   	push   %esi
  80014b:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80014c:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80014f:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800155:	e8 fe 09 00 00       	call   800b58 <sys_getenvid>
  80015a:	83 ec 0c             	sub    $0xc,%esp
  80015d:	ff 75 0c             	pushl  0xc(%ebp)
  800160:	ff 75 08             	pushl  0x8(%ebp)
  800163:	56                   	push   %esi
  800164:	50                   	push   %eax
  800165:	68 68 0e 80 00       	push   $0x800e68
  80016a:	e8 b2 00 00 00       	call   800221 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80016f:	83 c4 18             	add    $0x18,%esp
  800172:	53                   	push   %ebx
  800173:	ff 75 10             	pushl  0x10(%ebp)
  800176:	e8 55 00 00 00       	call   8001d0 <vcprintf>
	cprintf("\n");
  80017b:	c7 04 24 36 0e 80 00 	movl   $0x800e36,(%esp)
  800182:	e8 9a 00 00 00       	call   800221 <cprintf>
  800187:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80018a:	cc                   	int3   
  80018b:	eb fd                	jmp    80018a <_panic+0x43>

0080018d <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80018d:	55                   	push   %ebp
  80018e:	89 e5                	mov    %esp,%ebp
  800190:	53                   	push   %ebx
  800191:	83 ec 04             	sub    $0x4,%esp
  800194:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800197:	8b 13                	mov    (%ebx),%edx
  800199:	8d 42 01             	lea    0x1(%edx),%eax
  80019c:	89 03                	mov    %eax,(%ebx)
  80019e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001a1:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001a5:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001aa:	74 08                	je     8001b4 <putch+0x27>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8001ac:	ff 43 04             	incl   0x4(%ebx)
}
  8001af:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001b2:	c9                   	leave  
  8001b3:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8001b4:	83 ec 08             	sub    $0x8,%esp
  8001b7:	68 ff 00 00 00       	push   $0xff
  8001bc:	8d 43 08             	lea    0x8(%ebx),%eax
  8001bf:	50                   	push   %eax
  8001c0:	e8 15 09 00 00       	call   800ada <sys_cputs>
		b->idx = 0;
  8001c5:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001cb:	83 c4 10             	add    $0x10,%esp
  8001ce:	eb dc                	jmp    8001ac <putch+0x1f>

008001d0 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001d0:	55                   	push   %ebp
  8001d1:	89 e5                	mov    %esp,%ebp
  8001d3:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001d9:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001e0:	00 00 00 
	b.cnt = 0;
  8001e3:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001ea:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001ed:	ff 75 0c             	pushl  0xc(%ebp)
  8001f0:	ff 75 08             	pushl  0x8(%ebp)
  8001f3:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001f9:	50                   	push   %eax
  8001fa:	68 8d 01 80 00       	push   $0x80018d
  8001ff:	e8 0f 01 00 00       	call   800313 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800204:	83 c4 08             	add    $0x8,%esp
  800207:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80020d:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800213:	50                   	push   %eax
  800214:	e8 c1 08 00 00       	call   800ada <sys_cputs>

	return b.cnt;
}
  800219:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80021f:	c9                   	leave  
  800220:	c3                   	ret    

00800221 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800221:	55                   	push   %ebp
  800222:	89 e5                	mov    %esp,%ebp
  800224:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800227:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80022a:	50                   	push   %eax
  80022b:	ff 75 08             	pushl  0x8(%ebp)
  80022e:	e8 9d ff ff ff       	call   8001d0 <vcprintf>
	va_end(ap);

	return cnt;
}
  800233:	c9                   	leave  
  800234:	c3                   	ret    

00800235 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800235:	55                   	push   %ebp
  800236:	89 e5                	mov    %esp,%ebp
  800238:	57                   	push   %edi
  800239:	56                   	push   %esi
  80023a:	53                   	push   %ebx
  80023b:	83 ec 1c             	sub    $0x1c,%esp
  80023e:	89 c7                	mov    %eax,%edi
  800240:	89 d6                	mov    %edx,%esi
  800242:	8b 45 08             	mov    0x8(%ebp),%eax
  800245:	8b 55 0c             	mov    0xc(%ebp),%edx
  800248:	89 d1                	mov    %edx,%ecx
  80024a:	89 c2                	mov    %eax,%edx
  80024c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80024f:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800252:	8b 45 10             	mov    0x10(%ebp),%eax
  800255:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800258:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80025b:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800262:	39 c2                	cmp    %eax,%edx
  800264:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  800267:	72 3c                	jb     8002a5 <printnum+0x70>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800269:	83 ec 0c             	sub    $0xc,%esp
  80026c:	ff 75 18             	pushl  0x18(%ebp)
  80026f:	4b                   	dec    %ebx
  800270:	53                   	push   %ebx
  800271:	50                   	push   %eax
  800272:	83 ec 08             	sub    $0x8,%esp
  800275:	ff 75 e4             	pushl  -0x1c(%ebp)
  800278:	ff 75 e0             	pushl  -0x20(%ebp)
  80027b:	ff 75 dc             	pushl  -0x24(%ebp)
  80027e:	ff 75 d8             	pushl  -0x28(%ebp)
  800281:	e8 f2 08 00 00       	call   800b78 <__udivdi3>
  800286:	83 c4 18             	add    $0x18,%esp
  800289:	52                   	push   %edx
  80028a:	50                   	push   %eax
  80028b:	89 f2                	mov    %esi,%edx
  80028d:	89 f8                	mov    %edi,%eax
  80028f:	e8 a1 ff ff ff       	call   800235 <printnum>
  800294:	83 c4 20             	add    $0x20,%esp
  800297:	eb 11                	jmp    8002aa <printnum+0x75>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800299:	83 ec 08             	sub    $0x8,%esp
  80029c:	56                   	push   %esi
  80029d:	ff 75 18             	pushl  0x18(%ebp)
  8002a0:	ff d7                	call   *%edi
  8002a2:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8002a5:	4b                   	dec    %ebx
  8002a6:	85 db                	test   %ebx,%ebx
  8002a8:	7f ef                	jg     800299 <printnum+0x64>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002aa:	83 ec 08             	sub    $0x8,%esp
  8002ad:	56                   	push   %esi
  8002ae:	83 ec 04             	sub    $0x4,%esp
  8002b1:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002b4:	ff 75 e0             	pushl  -0x20(%ebp)
  8002b7:	ff 75 dc             	pushl  -0x24(%ebp)
  8002ba:	ff 75 d8             	pushl  -0x28(%ebp)
  8002bd:	e8 b6 09 00 00       	call   800c78 <__umoddi3>
  8002c2:	83 c4 14             	add    $0x14,%esp
  8002c5:	0f be 80 8c 0e 80 00 	movsbl 0x800e8c(%eax),%eax
  8002cc:	50                   	push   %eax
  8002cd:	ff d7                	call   *%edi
}
  8002cf:	83 c4 10             	add    $0x10,%esp
  8002d2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002d5:	5b                   	pop    %ebx
  8002d6:	5e                   	pop    %esi
  8002d7:	5f                   	pop    %edi
  8002d8:	5d                   	pop    %ebp
  8002d9:	c3                   	ret    

008002da <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002da:	55                   	push   %ebp
  8002db:	89 e5                	mov    %esp,%ebp
  8002dd:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002e0:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8002e3:	8b 10                	mov    (%eax),%edx
  8002e5:	3b 50 04             	cmp    0x4(%eax),%edx
  8002e8:	73 0a                	jae    8002f4 <sprintputch+0x1a>
		*b->buf++ = ch;
  8002ea:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002ed:	89 08                	mov    %ecx,(%eax)
  8002ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8002f2:	88 02                	mov    %al,(%edx)
}
  8002f4:	5d                   	pop    %ebp
  8002f5:	c3                   	ret    

008002f6 <printfmt>:
{
  8002f6:	55                   	push   %ebp
  8002f7:	89 e5                	mov    %esp,%ebp
  8002f9:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8002fc:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002ff:	50                   	push   %eax
  800300:	ff 75 10             	pushl  0x10(%ebp)
  800303:	ff 75 0c             	pushl  0xc(%ebp)
  800306:	ff 75 08             	pushl  0x8(%ebp)
  800309:	e8 05 00 00 00       	call   800313 <vprintfmt>
}
  80030e:	83 c4 10             	add    $0x10,%esp
  800311:	c9                   	leave  
  800312:	c3                   	ret    

00800313 <vprintfmt>:
{
  800313:	55                   	push   %ebp
  800314:	89 e5                	mov    %esp,%ebp
  800316:	57                   	push   %edi
  800317:	56                   	push   %esi
  800318:	53                   	push   %ebx
  800319:	83 ec 3c             	sub    $0x3c,%esp
  80031c:	8b 75 08             	mov    0x8(%ebp),%esi
  80031f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800322:	8b 7d 10             	mov    0x10(%ebp),%edi
  800325:	e9 5b 03 00 00       	jmp    800685 <vprintfmt+0x372>
		padc = ' ';
  80032a:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  80032e:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
		precision = -1;
  800335:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  80033c:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		lflag = 0;
  800343:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800348:	8d 47 01             	lea    0x1(%edi),%eax
  80034b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80034e:	8a 17                	mov    (%edi),%dl
  800350:	8d 42 dd             	lea    -0x23(%edx),%eax
  800353:	3c 55                	cmp    $0x55,%al
  800355:	0f 87 ab 03 00 00    	ja     800706 <vprintfmt+0x3f3>
  80035b:	0f b6 c0             	movzbl %al,%eax
  80035e:	ff 24 85 1c 0f 80 00 	jmp    *0x800f1c(,%eax,4)
  800365:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800368:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  80036c:	eb da                	jmp    800348 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  80036e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800371:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  800375:	eb d1                	jmp    800348 <vprintfmt+0x35>
  800377:	0f b6 d2             	movzbl %dl,%edx
  80037a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  80037d:	b8 00 00 00 00       	mov    $0x0,%eax
  800382:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800385:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800388:	01 c0                	add    %eax,%eax
  80038a:	8d 44 02 d0          	lea    -0x30(%edx,%eax,1),%eax
				ch = *fmt;
  80038e:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800391:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800394:	83 f9 09             	cmp    $0x9,%ecx
  800397:	77 52                	ja     8003eb <vprintfmt+0xd8>
			for (precision = 0; ; ++fmt) {
  800399:	47                   	inc    %edi
				precision = precision * 10 + ch - '0';
  80039a:	eb e9                	jmp    800385 <vprintfmt+0x72>
			precision = va_arg(ap, int);
  80039c:	8b 45 14             	mov    0x14(%ebp),%eax
  80039f:	8b 00                	mov    (%eax),%eax
  8003a1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003a4:	8b 45 14             	mov    0x14(%ebp),%eax
  8003a7:	8d 40 04             	lea    0x4(%eax),%eax
  8003aa:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003ad:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8003b0:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8003b4:	79 92                	jns    800348 <vprintfmt+0x35>
				width = precision, precision = -1;
  8003b6:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8003b9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8003bc:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8003c3:	eb 83                	jmp    800348 <vprintfmt+0x35>
  8003c5:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8003c9:	78 08                	js     8003d3 <vprintfmt+0xc0>
		switch (ch = *(unsigned char *) fmt++) {
  8003cb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8003ce:	e9 75 ff ff ff       	jmp    800348 <vprintfmt+0x35>
  8003d3:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  8003da:	eb ef                	jmp    8003cb <vprintfmt+0xb8>
		switch (ch = *(unsigned char *) fmt++) {
  8003dc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8003df:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  8003e6:	e9 5d ff ff ff       	jmp    800348 <vprintfmt+0x35>
  8003eb:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8003ee:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003f1:	eb bd                	jmp    8003b0 <vprintfmt+0x9d>
			lflag++;
  8003f3:	41                   	inc    %ecx
		switch (ch = *(unsigned char *) fmt++) {
  8003f4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8003f7:	e9 4c ff ff ff       	jmp    800348 <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
  8003fc:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ff:	8d 78 04             	lea    0x4(%eax),%edi
  800402:	83 ec 08             	sub    $0x8,%esp
  800405:	53                   	push   %ebx
  800406:	ff 30                	pushl  (%eax)
  800408:	ff d6                	call   *%esi
			break;
  80040a:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  80040d:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800410:	e9 6d 02 00 00       	jmp    800682 <vprintfmt+0x36f>
			err = va_arg(ap, int);
  800415:	8b 45 14             	mov    0x14(%ebp),%eax
  800418:	8d 78 04             	lea    0x4(%eax),%edi
  80041b:	8b 00                	mov    (%eax),%eax
  80041d:	85 c0                	test   %eax,%eax
  80041f:	78 2a                	js     80044b <vprintfmt+0x138>
  800421:	89 c2                	mov    %eax,%edx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800423:	83 f8 06             	cmp    $0x6,%eax
  800426:	7f 27                	jg     80044f <vprintfmt+0x13c>
  800428:	8b 04 85 74 10 80 00 	mov    0x801074(,%eax,4),%eax
  80042f:	85 c0                	test   %eax,%eax
  800431:	74 1c                	je     80044f <vprintfmt+0x13c>
				printfmt(putch, putdat, "%s", p);
  800433:	50                   	push   %eax
  800434:	68 ad 0e 80 00       	push   $0x800ead
  800439:	53                   	push   %ebx
  80043a:	56                   	push   %esi
  80043b:	e8 b6 fe ff ff       	call   8002f6 <printfmt>
  800440:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800443:	89 7d 14             	mov    %edi,0x14(%ebp)
  800446:	e9 37 02 00 00       	jmp    800682 <vprintfmt+0x36f>
  80044b:	f7 d8                	neg    %eax
  80044d:	eb d2                	jmp    800421 <vprintfmt+0x10e>
				printfmt(putch, putdat, "error %d", err);
  80044f:	52                   	push   %edx
  800450:	68 a4 0e 80 00       	push   $0x800ea4
  800455:	53                   	push   %ebx
  800456:	56                   	push   %esi
  800457:	e8 9a fe ff ff       	call   8002f6 <printfmt>
  80045c:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80045f:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800462:	e9 1b 02 00 00       	jmp    800682 <vprintfmt+0x36f>
			if ((p = va_arg(ap, char *)) == NULL)
  800467:	8b 45 14             	mov    0x14(%ebp),%eax
  80046a:	83 c0 04             	add    $0x4,%eax
  80046d:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800470:	8b 45 14             	mov    0x14(%ebp),%eax
  800473:	8b 00                	mov    (%eax),%eax
  800475:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800478:	85 c0                	test   %eax,%eax
  80047a:	74 19                	je     800495 <vprintfmt+0x182>
			if (width > 0 && padc != '-')
  80047c:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800480:	7e 06                	jle    800488 <vprintfmt+0x175>
  800482:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  800486:	75 16                	jne    80049e <vprintfmt+0x18b>
				for (width -= strnlen(p, precision); width > 0; width--)
  800488:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80048b:	89 c7                	mov    %eax,%edi
  80048d:	03 45 d4             	add    -0x2c(%ebp),%eax
  800490:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800493:	eb 62                	jmp    8004f7 <vprintfmt+0x1e4>
				p = "(null)";
  800495:	c7 45 cc 9d 0e 80 00 	movl   $0x800e9d,-0x34(%ebp)
  80049c:	eb de                	jmp    80047c <vprintfmt+0x169>
				for (width -= strnlen(p, precision); width > 0; width--)
  80049e:	83 ec 08             	sub    $0x8,%esp
  8004a1:	ff 75 d8             	pushl  -0x28(%ebp)
  8004a4:	ff 75 cc             	pushl  -0x34(%ebp)
  8004a7:	e8 05 03 00 00       	call   8007b1 <strnlen>
  8004ac:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8004af:	29 c2                	sub    %eax,%edx
  8004b1:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  8004b4:	83 c4 10             	add    $0x10,%esp
  8004b7:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  8004b9:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8004bd:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8004c0:	eb 0d                	jmp    8004cf <vprintfmt+0x1bc>
					putch(padc, putdat);
  8004c2:	83 ec 08             	sub    $0x8,%esp
  8004c5:	53                   	push   %ebx
  8004c6:	ff 75 d4             	pushl  -0x2c(%ebp)
  8004c9:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8004cb:	4f                   	dec    %edi
  8004cc:	83 c4 10             	add    $0x10,%esp
  8004cf:	85 ff                	test   %edi,%edi
  8004d1:	7f ef                	jg     8004c2 <vprintfmt+0x1af>
  8004d3:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8004d6:	89 d0                	mov    %edx,%eax
  8004d8:	85 d2                	test   %edx,%edx
  8004da:	78 0a                	js     8004e6 <vprintfmt+0x1d3>
  8004dc:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8004df:	29 c2                	sub    %eax,%edx
  8004e1:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8004e4:	eb a2                	jmp    800488 <vprintfmt+0x175>
  8004e6:	b8 00 00 00 00       	mov    $0x0,%eax
  8004eb:	eb ef                	jmp    8004dc <vprintfmt+0x1c9>
					putch(ch, putdat);
  8004ed:	83 ec 08             	sub    $0x8,%esp
  8004f0:	53                   	push   %ebx
  8004f1:	52                   	push   %edx
  8004f2:	ff d6                	call   *%esi
  8004f4:	83 c4 10             	add    $0x10,%esp
  8004f7:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  8004fa:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004fc:	47                   	inc    %edi
  8004fd:	8a 47 ff             	mov    -0x1(%edi),%al
  800500:	0f be d0             	movsbl %al,%edx
  800503:	85 d2                	test   %edx,%edx
  800505:	74 48                	je     80054f <vprintfmt+0x23c>
  800507:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80050b:	78 05                	js     800512 <vprintfmt+0x1ff>
  80050d:	ff 4d d8             	decl   -0x28(%ebp)
  800510:	78 1e                	js     800530 <vprintfmt+0x21d>
				if (altflag && (ch < ' ' || ch > '~'))
  800512:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800516:	74 d5                	je     8004ed <vprintfmt+0x1da>
  800518:	0f be c0             	movsbl %al,%eax
  80051b:	83 e8 20             	sub    $0x20,%eax
  80051e:	83 f8 5e             	cmp    $0x5e,%eax
  800521:	76 ca                	jbe    8004ed <vprintfmt+0x1da>
					putch('?', putdat);
  800523:	83 ec 08             	sub    $0x8,%esp
  800526:	53                   	push   %ebx
  800527:	6a 3f                	push   $0x3f
  800529:	ff d6                	call   *%esi
  80052b:	83 c4 10             	add    $0x10,%esp
  80052e:	eb c7                	jmp    8004f7 <vprintfmt+0x1e4>
  800530:	89 cf                	mov    %ecx,%edi
  800532:	eb 0c                	jmp    800540 <vprintfmt+0x22d>
				putch(' ', putdat);
  800534:	83 ec 08             	sub    $0x8,%esp
  800537:	53                   	push   %ebx
  800538:	6a 20                	push   $0x20
  80053a:	ff d6                	call   *%esi
			for (; width > 0; width--)
  80053c:	4f                   	dec    %edi
  80053d:	83 c4 10             	add    $0x10,%esp
  800540:	85 ff                	test   %edi,%edi
  800542:	7f f0                	jg     800534 <vprintfmt+0x221>
			if ((p = va_arg(ap, char *)) == NULL)
  800544:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800547:	89 45 14             	mov    %eax,0x14(%ebp)
  80054a:	e9 33 01 00 00       	jmp    800682 <vprintfmt+0x36f>
  80054f:	89 cf                	mov    %ecx,%edi
  800551:	eb ed                	jmp    800540 <vprintfmt+0x22d>
	if (lflag >= 2)
  800553:	83 f9 01             	cmp    $0x1,%ecx
  800556:	7f 1b                	jg     800573 <vprintfmt+0x260>
	else if (lflag)
  800558:	85 c9                	test   %ecx,%ecx
  80055a:	74 42                	je     80059e <vprintfmt+0x28b>
		return va_arg(*ap, long);
  80055c:	8b 45 14             	mov    0x14(%ebp),%eax
  80055f:	8b 00                	mov    (%eax),%eax
  800561:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800564:	99                   	cltd   
  800565:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800568:	8b 45 14             	mov    0x14(%ebp),%eax
  80056b:	8d 40 04             	lea    0x4(%eax),%eax
  80056e:	89 45 14             	mov    %eax,0x14(%ebp)
  800571:	eb 17                	jmp    80058a <vprintfmt+0x277>
		return va_arg(*ap, long long);
  800573:	8b 45 14             	mov    0x14(%ebp),%eax
  800576:	8b 50 04             	mov    0x4(%eax),%edx
  800579:	8b 00                	mov    (%eax),%eax
  80057b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80057e:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800581:	8b 45 14             	mov    0x14(%ebp),%eax
  800584:	8d 40 08             	lea    0x8(%eax),%eax
  800587:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  80058a:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80058d:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800590:	85 c9                	test   %ecx,%ecx
  800592:	78 21                	js     8005b5 <vprintfmt+0x2a2>
			base = 10;
  800594:	b8 0a 00 00 00       	mov    $0xa,%eax
  800599:	e9 ca 00 00 00       	jmp    800668 <vprintfmt+0x355>
		return va_arg(*ap, int);
  80059e:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a1:	8b 00                	mov    (%eax),%eax
  8005a3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005a6:	99                   	cltd   
  8005a7:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005aa:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ad:	8d 40 04             	lea    0x4(%eax),%eax
  8005b0:	89 45 14             	mov    %eax,0x14(%ebp)
  8005b3:	eb d5                	jmp    80058a <vprintfmt+0x277>
				putch('-', putdat);
  8005b5:	83 ec 08             	sub    $0x8,%esp
  8005b8:	53                   	push   %ebx
  8005b9:	6a 2d                	push   $0x2d
  8005bb:	ff d6                	call   *%esi
				num = -(long long) num;
  8005bd:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005c0:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8005c3:	f7 da                	neg    %edx
  8005c5:	83 d1 00             	adc    $0x0,%ecx
  8005c8:	f7 d9                	neg    %ecx
  8005ca:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8005cd:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005d2:	e9 91 00 00 00       	jmp    800668 <vprintfmt+0x355>
	if (lflag >= 2)
  8005d7:	83 f9 01             	cmp    $0x1,%ecx
  8005da:	7f 1b                	jg     8005f7 <vprintfmt+0x2e4>
	else if (lflag)
  8005dc:	85 c9                	test   %ecx,%ecx
  8005de:	74 2c                	je     80060c <vprintfmt+0x2f9>
		return va_arg(*ap, unsigned long);
  8005e0:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e3:	8b 10                	mov    (%eax),%edx
  8005e5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005ea:	8d 40 04             	lea    0x4(%eax),%eax
  8005ed:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005f0:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  8005f5:	eb 71                	jmp    800668 <vprintfmt+0x355>
		return va_arg(*ap, unsigned long long);
  8005f7:	8b 45 14             	mov    0x14(%ebp),%eax
  8005fa:	8b 10                	mov    (%eax),%edx
  8005fc:	8b 48 04             	mov    0x4(%eax),%ecx
  8005ff:	8d 40 08             	lea    0x8(%eax),%eax
  800602:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800605:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  80060a:	eb 5c                	jmp    800668 <vprintfmt+0x355>
		return va_arg(*ap, unsigned int);
  80060c:	8b 45 14             	mov    0x14(%ebp),%eax
  80060f:	8b 10                	mov    (%eax),%edx
  800611:	b9 00 00 00 00       	mov    $0x0,%ecx
  800616:	8d 40 04             	lea    0x4(%eax),%eax
  800619:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80061c:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  800621:	eb 45                	jmp    800668 <vprintfmt+0x355>
			putch('X', putdat);
  800623:	83 ec 08             	sub    $0x8,%esp
  800626:	53                   	push   %ebx
  800627:	6a 58                	push   $0x58
  800629:	ff d6                	call   *%esi
			putch('X', putdat);
  80062b:	83 c4 08             	add    $0x8,%esp
  80062e:	53                   	push   %ebx
  80062f:	6a 58                	push   $0x58
  800631:	ff d6                	call   *%esi
			putch('X', putdat);
  800633:	83 c4 08             	add    $0x8,%esp
  800636:	53                   	push   %ebx
  800637:	6a 58                	push   $0x58
  800639:	ff d6                	call   *%esi
			break;
  80063b:	83 c4 10             	add    $0x10,%esp
  80063e:	eb 42                	jmp    800682 <vprintfmt+0x36f>
			putch('0', putdat);
  800640:	83 ec 08             	sub    $0x8,%esp
  800643:	53                   	push   %ebx
  800644:	6a 30                	push   $0x30
  800646:	ff d6                	call   *%esi
			putch('x', putdat);
  800648:	83 c4 08             	add    $0x8,%esp
  80064b:	53                   	push   %ebx
  80064c:	6a 78                	push   $0x78
  80064e:	ff d6                	call   *%esi
			num = (unsigned long long)
  800650:	8b 45 14             	mov    0x14(%ebp),%eax
  800653:	8b 10                	mov    (%eax),%edx
  800655:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  80065a:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  80065d:	8d 40 04             	lea    0x4(%eax),%eax
  800660:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800663:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  800668:	83 ec 0c             	sub    $0xc,%esp
  80066b:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  80066f:	57                   	push   %edi
  800670:	ff 75 d4             	pushl  -0x2c(%ebp)
  800673:	50                   	push   %eax
  800674:	51                   	push   %ecx
  800675:	52                   	push   %edx
  800676:	89 da                	mov    %ebx,%edx
  800678:	89 f0                	mov    %esi,%eax
  80067a:	e8 b6 fb ff ff       	call   800235 <printnum>
			break;
  80067f:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  800682:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800685:	47                   	inc    %edi
  800686:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80068a:	83 f8 25             	cmp    $0x25,%eax
  80068d:	0f 84 97 fc ff ff    	je     80032a <vprintfmt+0x17>
			if (ch == '\0')
  800693:	85 c0                	test   %eax,%eax
  800695:	0f 84 89 00 00 00    	je     800724 <vprintfmt+0x411>
			putch(ch, putdat);
  80069b:	83 ec 08             	sub    $0x8,%esp
  80069e:	53                   	push   %ebx
  80069f:	50                   	push   %eax
  8006a0:	ff d6                	call   *%esi
  8006a2:	83 c4 10             	add    $0x10,%esp
  8006a5:	eb de                	jmp    800685 <vprintfmt+0x372>
	if (lflag >= 2)
  8006a7:	83 f9 01             	cmp    $0x1,%ecx
  8006aa:	7f 1b                	jg     8006c7 <vprintfmt+0x3b4>
	else if (lflag)
  8006ac:	85 c9                	test   %ecx,%ecx
  8006ae:	74 2c                	je     8006dc <vprintfmt+0x3c9>
		return va_arg(*ap, unsigned long);
  8006b0:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b3:	8b 10                	mov    (%eax),%edx
  8006b5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006ba:	8d 40 04             	lea    0x4(%eax),%eax
  8006bd:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006c0:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  8006c5:	eb a1                	jmp    800668 <vprintfmt+0x355>
		return va_arg(*ap, unsigned long long);
  8006c7:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ca:	8b 10                	mov    (%eax),%edx
  8006cc:	8b 48 04             	mov    0x4(%eax),%ecx
  8006cf:	8d 40 08             	lea    0x8(%eax),%eax
  8006d2:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006d5:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  8006da:	eb 8c                	jmp    800668 <vprintfmt+0x355>
		return va_arg(*ap, unsigned int);
  8006dc:	8b 45 14             	mov    0x14(%ebp),%eax
  8006df:	8b 10                	mov    (%eax),%edx
  8006e1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006e6:	8d 40 04             	lea    0x4(%eax),%eax
  8006e9:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006ec:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  8006f1:	e9 72 ff ff ff       	jmp    800668 <vprintfmt+0x355>
			putch(ch, putdat);
  8006f6:	83 ec 08             	sub    $0x8,%esp
  8006f9:	53                   	push   %ebx
  8006fa:	6a 25                	push   $0x25
  8006fc:	ff d6                	call   *%esi
			break;
  8006fe:	83 c4 10             	add    $0x10,%esp
  800701:	e9 7c ff ff ff       	jmp    800682 <vprintfmt+0x36f>
			putch('%', putdat);
  800706:	83 ec 08             	sub    $0x8,%esp
  800709:	53                   	push   %ebx
  80070a:	6a 25                	push   $0x25
  80070c:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80070e:	83 c4 10             	add    $0x10,%esp
  800711:	89 f8                	mov    %edi,%eax
  800713:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800717:	74 03                	je     80071c <vprintfmt+0x409>
  800719:	48                   	dec    %eax
  80071a:	eb f7                	jmp    800713 <vprintfmt+0x400>
  80071c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80071f:	e9 5e ff ff ff       	jmp    800682 <vprintfmt+0x36f>
}
  800724:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800727:	5b                   	pop    %ebx
  800728:	5e                   	pop    %esi
  800729:	5f                   	pop    %edi
  80072a:	5d                   	pop    %ebp
  80072b:	c3                   	ret    

0080072c <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80072c:	55                   	push   %ebp
  80072d:	89 e5                	mov    %esp,%ebp
  80072f:	83 ec 18             	sub    $0x18,%esp
  800732:	8b 45 08             	mov    0x8(%ebp),%eax
  800735:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800738:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80073b:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80073f:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800742:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800749:	85 c0                	test   %eax,%eax
  80074b:	74 26                	je     800773 <vsnprintf+0x47>
  80074d:	85 d2                	test   %edx,%edx
  80074f:	7e 29                	jle    80077a <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800751:	ff 75 14             	pushl  0x14(%ebp)
  800754:	ff 75 10             	pushl  0x10(%ebp)
  800757:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80075a:	50                   	push   %eax
  80075b:	68 da 02 80 00       	push   $0x8002da
  800760:	e8 ae fb ff ff       	call   800313 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800765:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800768:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80076b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80076e:	83 c4 10             	add    $0x10,%esp
}
  800771:	c9                   	leave  
  800772:	c3                   	ret    
		return -E_INVAL;
  800773:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800778:	eb f7                	jmp    800771 <vsnprintf+0x45>
  80077a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80077f:	eb f0                	jmp    800771 <vsnprintf+0x45>

00800781 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800781:	55                   	push   %ebp
  800782:	89 e5                	mov    %esp,%ebp
  800784:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800787:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80078a:	50                   	push   %eax
  80078b:	ff 75 10             	pushl  0x10(%ebp)
  80078e:	ff 75 0c             	pushl  0xc(%ebp)
  800791:	ff 75 08             	pushl  0x8(%ebp)
  800794:	e8 93 ff ff ff       	call   80072c <vsnprintf>
	va_end(ap);

	return rc;
}
  800799:	c9                   	leave  
  80079a:	c3                   	ret    

0080079b <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80079b:	55                   	push   %ebp
  80079c:	89 e5                	mov    %esp,%ebp
  80079e:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007a1:	b8 00 00 00 00       	mov    $0x0,%eax
  8007a6:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007aa:	74 03                	je     8007af <strlen+0x14>
		n++;
  8007ac:	40                   	inc    %eax
  8007ad:	eb f7                	jmp    8007a6 <strlen+0xb>
	return n;
}
  8007af:	5d                   	pop    %ebp
  8007b0:	c3                   	ret    

008007b1 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007b1:	55                   	push   %ebp
  8007b2:	89 e5                	mov    %esp,%ebp
  8007b4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007b7:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007ba:	b8 00 00 00 00       	mov    $0x0,%eax
  8007bf:	39 d0                	cmp    %edx,%eax
  8007c1:	74 0b                	je     8007ce <strnlen+0x1d>
  8007c3:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007c7:	74 03                	je     8007cc <strnlen+0x1b>
		n++;
  8007c9:	40                   	inc    %eax
  8007ca:	eb f3                	jmp    8007bf <strnlen+0xe>
  8007cc:	89 c2                	mov    %eax,%edx
	return n;
}
  8007ce:	89 d0                	mov    %edx,%eax
  8007d0:	5d                   	pop    %ebp
  8007d1:	c3                   	ret    

008007d2 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007d2:	55                   	push   %ebp
  8007d3:	89 e5                	mov    %esp,%ebp
  8007d5:	53                   	push   %ebx
  8007d6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007d9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007dc:	b8 00 00 00 00       	mov    $0x0,%eax
  8007e1:	8a 14 03             	mov    (%ebx,%eax,1),%dl
  8007e4:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8007e7:	40                   	inc    %eax
  8007e8:	84 d2                	test   %dl,%dl
  8007ea:	75 f5                	jne    8007e1 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8007ec:	89 c8                	mov    %ecx,%eax
  8007ee:	5b                   	pop    %ebx
  8007ef:	5d                   	pop    %ebp
  8007f0:	c3                   	ret    

008007f1 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007f1:	55                   	push   %ebp
  8007f2:	89 e5                	mov    %esp,%ebp
  8007f4:	53                   	push   %ebx
  8007f5:	83 ec 10             	sub    $0x10,%esp
  8007f8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007fb:	53                   	push   %ebx
  8007fc:	e8 9a ff ff ff       	call   80079b <strlen>
  800801:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800804:	ff 75 0c             	pushl  0xc(%ebp)
  800807:	01 d8                	add    %ebx,%eax
  800809:	50                   	push   %eax
  80080a:	e8 c3 ff ff ff       	call   8007d2 <strcpy>
	return dst;
}
  80080f:	89 d8                	mov    %ebx,%eax
  800811:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800814:	c9                   	leave  
  800815:	c3                   	ret    

00800816 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800816:	55                   	push   %ebp
  800817:	89 e5                	mov    %esp,%ebp
  800819:	53                   	push   %ebx
  80081a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80081d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800820:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800823:	8b 45 08             	mov    0x8(%ebp),%eax
  800826:	39 d8                	cmp    %ebx,%eax
  800828:	74 0e                	je     800838 <strncpy+0x22>
		*dst++ = *src;
  80082a:	40                   	inc    %eax
  80082b:	8a 0a                	mov    (%edx),%cl
  80082d:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800830:	80 f9 01             	cmp    $0x1,%cl
  800833:	83 da ff             	sbb    $0xffffffff,%edx
  800836:	eb ee                	jmp    800826 <strncpy+0x10>
	}
	return ret;
}
  800838:	8b 45 08             	mov    0x8(%ebp),%eax
  80083b:	5b                   	pop    %ebx
  80083c:	5d                   	pop    %ebp
  80083d:	c3                   	ret    

0080083e <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80083e:	55                   	push   %ebp
  80083f:	89 e5                	mov    %esp,%ebp
  800841:	56                   	push   %esi
  800842:	53                   	push   %ebx
  800843:	8b 75 08             	mov    0x8(%ebp),%esi
  800846:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800849:	8b 45 10             	mov    0x10(%ebp),%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80084c:	85 c0                	test   %eax,%eax
  80084e:	74 22                	je     800872 <strlcpy+0x34>
  800850:	8d 44 06 ff          	lea    -0x1(%esi,%eax,1),%eax
  800854:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  800856:	39 c2                	cmp    %eax,%edx
  800858:	74 0f                	je     800869 <strlcpy+0x2b>
  80085a:	8a 19                	mov    (%ecx),%bl
  80085c:	84 db                	test   %bl,%bl
  80085e:	74 07                	je     800867 <strlcpy+0x29>
			*dst++ = *src++;
  800860:	41                   	inc    %ecx
  800861:	42                   	inc    %edx
  800862:	88 5a ff             	mov    %bl,-0x1(%edx)
  800865:	eb ef                	jmp    800856 <strlcpy+0x18>
  800867:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800869:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80086c:	29 f0                	sub    %esi,%eax
}
  80086e:	5b                   	pop    %ebx
  80086f:	5e                   	pop    %esi
  800870:	5d                   	pop    %ebp
  800871:	c3                   	ret    
  800872:	89 f0                	mov    %esi,%eax
  800874:	eb f6                	jmp    80086c <strlcpy+0x2e>

00800876 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800876:	55                   	push   %ebp
  800877:	89 e5                	mov    %esp,%ebp
  800879:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80087c:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80087f:	8a 01                	mov    (%ecx),%al
  800881:	84 c0                	test   %al,%al
  800883:	74 08                	je     80088d <strcmp+0x17>
  800885:	3a 02                	cmp    (%edx),%al
  800887:	75 04                	jne    80088d <strcmp+0x17>
		p++, q++;
  800889:	41                   	inc    %ecx
  80088a:	42                   	inc    %edx
  80088b:	eb f2                	jmp    80087f <strcmp+0x9>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80088d:	0f b6 c0             	movzbl %al,%eax
  800890:	0f b6 12             	movzbl (%edx),%edx
  800893:	29 d0                	sub    %edx,%eax
}
  800895:	5d                   	pop    %ebp
  800896:	c3                   	ret    

00800897 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800897:	55                   	push   %ebp
  800898:	89 e5                	mov    %esp,%ebp
  80089a:	53                   	push   %ebx
  80089b:	8b 45 08             	mov    0x8(%ebp),%eax
  80089e:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008a1:	89 c3                	mov    %eax,%ebx
  8008a3:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008a6:	eb 02                	jmp    8008aa <strncmp+0x13>
		n--, p++, q++;
  8008a8:	40                   	inc    %eax
  8008a9:	42                   	inc    %edx
	while (n > 0 && *p && *p == *q)
  8008aa:	39 d8                	cmp    %ebx,%eax
  8008ac:	74 15                	je     8008c3 <strncmp+0x2c>
  8008ae:	8a 08                	mov    (%eax),%cl
  8008b0:	84 c9                	test   %cl,%cl
  8008b2:	74 04                	je     8008b8 <strncmp+0x21>
  8008b4:	3a 0a                	cmp    (%edx),%cl
  8008b6:	74 f0                	je     8008a8 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008b8:	0f b6 00             	movzbl (%eax),%eax
  8008bb:	0f b6 12             	movzbl (%edx),%edx
  8008be:	29 d0                	sub    %edx,%eax
}
  8008c0:	5b                   	pop    %ebx
  8008c1:	5d                   	pop    %ebp
  8008c2:	c3                   	ret    
		return 0;
  8008c3:	b8 00 00 00 00       	mov    $0x0,%eax
  8008c8:	eb f6                	jmp    8008c0 <strncmp+0x29>

008008ca <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008ca:	55                   	push   %ebp
  8008cb:	89 e5                	mov    %esp,%ebp
  8008cd:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d0:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8008d3:	8a 10                	mov    (%eax),%dl
  8008d5:	84 d2                	test   %dl,%dl
  8008d7:	74 07                	je     8008e0 <strchr+0x16>
		if (*s == c)
  8008d9:	38 ca                	cmp    %cl,%dl
  8008db:	74 08                	je     8008e5 <strchr+0x1b>
	for (; *s; s++)
  8008dd:	40                   	inc    %eax
  8008de:	eb f3                	jmp    8008d3 <strchr+0x9>
			return (char *) s;
	return 0;
  8008e0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008e5:	5d                   	pop    %ebp
  8008e6:	c3                   	ret    

008008e7 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008e7:	55                   	push   %ebp
  8008e8:	89 e5                	mov    %esp,%ebp
  8008ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ed:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8008f0:	8a 10                	mov    (%eax),%dl
  8008f2:	84 d2                	test   %dl,%dl
  8008f4:	74 07                	je     8008fd <strfind+0x16>
		if (*s == c)
  8008f6:	38 ca                	cmp    %cl,%dl
  8008f8:	74 03                	je     8008fd <strfind+0x16>
	for (; *s; s++)
  8008fa:	40                   	inc    %eax
  8008fb:	eb f3                	jmp    8008f0 <strfind+0x9>
			break;
	return (char *) s;
}
  8008fd:	5d                   	pop    %ebp
  8008fe:	c3                   	ret    

008008ff <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008ff:	55                   	push   %ebp
  800900:	89 e5                	mov    %esp,%ebp
  800902:	57                   	push   %edi
  800903:	56                   	push   %esi
  800904:	53                   	push   %ebx
  800905:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800908:	85 c9                	test   %ecx,%ecx
  80090a:	74 36                	je     800942 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80090c:	89 c8                	mov    %ecx,%eax
  80090e:	0b 45 08             	or     0x8(%ebp),%eax
  800911:	a8 03                	test   $0x3,%al
  800913:	75 24                	jne    800939 <memset+0x3a>
		c &= 0xFF;
  800915:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800919:	89 d3                	mov    %edx,%ebx
  80091b:	c1 e3 08             	shl    $0x8,%ebx
  80091e:	89 d0                	mov    %edx,%eax
  800920:	c1 e0 18             	shl    $0x18,%eax
  800923:	89 d6                	mov    %edx,%esi
  800925:	c1 e6 10             	shl    $0x10,%esi
  800928:	09 f0                	or     %esi,%eax
  80092a:	09 d0                	or     %edx,%eax
  80092c:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80092e:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800931:	8b 7d 08             	mov    0x8(%ebp),%edi
  800934:	fc                   	cld    
  800935:	f3 ab                	rep stos %eax,%es:(%edi)
  800937:	eb 09                	jmp    800942 <memset+0x43>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800939:	8b 7d 08             	mov    0x8(%ebp),%edi
  80093c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80093f:	fc                   	cld    
  800940:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800942:	8b 45 08             	mov    0x8(%ebp),%eax
  800945:	5b                   	pop    %ebx
  800946:	5e                   	pop    %esi
  800947:	5f                   	pop    %edi
  800948:	5d                   	pop    %ebp
  800949:	c3                   	ret    

0080094a <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80094a:	55                   	push   %ebp
  80094b:	89 e5                	mov    %esp,%ebp
  80094d:	57                   	push   %edi
  80094e:	56                   	push   %esi
  80094f:	8b 45 08             	mov    0x8(%ebp),%eax
  800952:	8b 75 0c             	mov    0xc(%ebp),%esi
  800955:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800958:	39 c6                	cmp    %eax,%esi
  80095a:	73 30                	jae    80098c <memmove+0x42>
  80095c:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80095f:	39 c2                	cmp    %eax,%edx
  800961:	76 29                	jbe    80098c <memmove+0x42>
		s += n;
		d += n;
  800963:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800966:	89 fe                	mov    %edi,%esi
  800968:	09 ce                	or     %ecx,%esi
  80096a:	09 d6                	or     %edx,%esi
  80096c:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800972:	75 0e                	jne    800982 <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800974:	83 ef 04             	sub    $0x4,%edi
  800977:	8d 72 fc             	lea    -0x4(%edx),%esi
  80097a:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  80097d:	fd                   	std    
  80097e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800980:	eb 07                	jmp    800989 <memmove+0x3f>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800982:	4f                   	dec    %edi
  800983:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800986:	fd                   	std    
  800987:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800989:	fc                   	cld    
  80098a:	eb 1a                	jmp    8009a6 <memmove+0x5c>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80098c:	89 c2                	mov    %eax,%edx
  80098e:	09 ca                	or     %ecx,%edx
  800990:	09 f2                	or     %esi,%edx
  800992:	f6 c2 03             	test   $0x3,%dl
  800995:	75 0a                	jne    8009a1 <memmove+0x57>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800997:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  80099a:	89 c7                	mov    %eax,%edi
  80099c:	fc                   	cld    
  80099d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80099f:	eb 05                	jmp    8009a6 <memmove+0x5c>
		else
			asm volatile("cld; rep movsb\n"
  8009a1:	89 c7                	mov    %eax,%edi
  8009a3:	fc                   	cld    
  8009a4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009a6:	5e                   	pop    %esi
  8009a7:	5f                   	pop    %edi
  8009a8:	5d                   	pop    %ebp
  8009a9:	c3                   	ret    

008009aa <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009aa:	55                   	push   %ebp
  8009ab:	89 e5                	mov    %esp,%ebp
  8009ad:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8009b0:	ff 75 10             	pushl  0x10(%ebp)
  8009b3:	ff 75 0c             	pushl  0xc(%ebp)
  8009b6:	ff 75 08             	pushl  0x8(%ebp)
  8009b9:	e8 8c ff ff ff       	call   80094a <memmove>
}
  8009be:	c9                   	leave  
  8009bf:	c3                   	ret    

008009c0 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009c0:	55                   	push   %ebp
  8009c1:	89 e5                	mov    %esp,%ebp
  8009c3:	56                   	push   %esi
  8009c4:	53                   	push   %ebx
  8009c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009cb:	89 c6                	mov    %eax,%esi
  8009cd:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009d0:	39 f0                	cmp    %esi,%eax
  8009d2:	74 16                	je     8009ea <memcmp+0x2a>
		if (*s1 != *s2)
  8009d4:	8a 08                	mov    (%eax),%cl
  8009d6:	8a 1a                	mov    (%edx),%bl
  8009d8:	38 d9                	cmp    %bl,%cl
  8009da:	75 04                	jne    8009e0 <memcmp+0x20>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  8009dc:	40                   	inc    %eax
  8009dd:	42                   	inc    %edx
  8009de:	eb f0                	jmp    8009d0 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  8009e0:	0f b6 c1             	movzbl %cl,%eax
  8009e3:	0f b6 db             	movzbl %bl,%ebx
  8009e6:	29 d8                	sub    %ebx,%eax
  8009e8:	eb 05                	jmp    8009ef <memcmp+0x2f>
	}

	return 0;
  8009ea:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009ef:	5b                   	pop    %ebx
  8009f0:	5e                   	pop    %esi
  8009f1:	5d                   	pop    %ebp
  8009f2:	c3                   	ret    

008009f3 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009f3:	55                   	push   %ebp
  8009f4:	89 e5                	mov    %esp,%ebp
  8009f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8009fc:	89 c2                	mov    %eax,%edx
  8009fe:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a01:	39 d0                	cmp    %edx,%eax
  800a03:	73 07                	jae    800a0c <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a05:	38 08                	cmp    %cl,(%eax)
  800a07:	74 03                	je     800a0c <memfind+0x19>
	for (; s < ends; s++)
  800a09:	40                   	inc    %eax
  800a0a:	eb f5                	jmp    800a01 <memfind+0xe>
			break;
	return (void *) s;
}
  800a0c:	5d                   	pop    %ebp
  800a0d:	c3                   	ret    

00800a0e <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a0e:	55                   	push   %ebp
  800a0f:	89 e5                	mov    %esp,%ebp
  800a11:	57                   	push   %edi
  800a12:	56                   	push   %esi
  800a13:	53                   	push   %ebx
  800a14:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a17:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a1a:	eb 01                	jmp    800a1d <strtol+0xf>
		s++;
  800a1c:	41                   	inc    %ecx
	while (*s == ' ' || *s == '\t')
  800a1d:	8a 01                	mov    (%ecx),%al
  800a1f:	3c 20                	cmp    $0x20,%al
  800a21:	74 f9                	je     800a1c <strtol+0xe>
  800a23:	3c 09                	cmp    $0x9,%al
  800a25:	74 f5                	je     800a1c <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800a27:	3c 2b                	cmp    $0x2b,%al
  800a29:	74 24                	je     800a4f <strtol+0x41>
		s++;
	else if (*s == '-')
  800a2b:	3c 2d                	cmp    $0x2d,%al
  800a2d:	74 28                	je     800a57 <strtol+0x49>
	int neg = 0;
  800a2f:	bf 00 00 00 00       	mov    $0x0,%edi
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a34:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a3a:	75 09                	jne    800a45 <strtol+0x37>
  800a3c:	80 39 30             	cmpb   $0x30,(%ecx)
  800a3f:	74 1e                	je     800a5f <strtol+0x51>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a41:	85 db                	test   %ebx,%ebx
  800a43:	74 36                	je     800a7b <strtol+0x6d>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a45:	b8 00 00 00 00       	mov    $0x0,%eax
  800a4a:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800a4d:	eb 45                	jmp    800a94 <strtol+0x86>
		s++;
  800a4f:	41                   	inc    %ecx
	int neg = 0;
  800a50:	bf 00 00 00 00       	mov    $0x0,%edi
  800a55:	eb dd                	jmp    800a34 <strtol+0x26>
		s++, neg = 1;
  800a57:	41                   	inc    %ecx
  800a58:	bf 01 00 00 00       	mov    $0x1,%edi
  800a5d:	eb d5                	jmp    800a34 <strtol+0x26>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a5f:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a63:	74 0c                	je     800a71 <strtol+0x63>
	else if (base == 0 && s[0] == '0')
  800a65:	85 db                	test   %ebx,%ebx
  800a67:	75 dc                	jne    800a45 <strtol+0x37>
		s++, base = 8;
  800a69:	41                   	inc    %ecx
  800a6a:	bb 08 00 00 00       	mov    $0x8,%ebx
  800a6f:	eb d4                	jmp    800a45 <strtol+0x37>
		s += 2, base = 16;
  800a71:	83 c1 02             	add    $0x2,%ecx
  800a74:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a79:	eb ca                	jmp    800a45 <strtol+0x37>
		base = 10;
  800a7b:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800a80:	eb c3                	jmp    800a45 <strtol+0x37>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800a82:	0f be d2             	movsbl %dl,%edx
  800a85:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800a88:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a8b:	7d 37                	jge    800ac4 <strtol+0xb6>
			break;
		s++, val = (val * base) + dig;
  800a8d:	41                   	inc    %ecx
  800a8e:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a92:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800a94:	8a 11                	mov    (%ecx),%dl
  800a96:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a99:	89 f3                	mov    %esi,%ebx
  800a9b:	80 fb 09             	cmp    $0x9,%bl
  800a9e:	76 e2                	jbe    800a82 <strtol+0x74>
		else if (*s >= 'a' && *s <= 'z')
  800aa0:	8d 72 9f             	lea    -0x61(%edx),%esi
  800aa3:	89 f3                	mov    %esi,%ebx
  800aa5:	80 fb 19             	cmp    $0x19,%bl
  800aa8:	77 08                	ja     800ab2 <strtol+0xa4>
			dig = *s - 'a' + 10;
  800aaa:	0f be d2             	movsbl %dl,%edx
  800aad:	83 ea 57             	sub    $0x57,%edx
  800ab0:	eb d6                	jmp    800a88 <strtol+0x7a>
		else if (*s >= 'A' && *s <= 'Z')
  800ab2:	8d 72 bf             	lea    -0x41(%edx),%esi
  800ab5:	89 f3                	mov    %esi,%ebx
  800ab7:	80 fb 19             	cmp    $0x19,%bl
  800aba:	77 08                	ja     800ac4 <strtol+0xb6>
			dig = *s - 'A' + 10;
  800abc:	0f be d2             	movsbl %dl,%edx
  800abf:	83 ea 37             	sub    $0x37,%edx
  800ac2:	eb c4                	jmp    800a88 <strtol+0x7a>
		// we don't properly detect overflow!
	}

	if (endptr)
  800ac4:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ac8:	74 05                	je     800acf <strtol+0xc1>
		*endptr = (char *) s;
  800aca:	8b 75 0c             	mov    0xc(%ebp),%esi
  800acd:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800acf:	85 ff                	test   %edi,%edi
  800ad1:	74 02                	je     800ad5 <strtol+0xc7>
  800ad3:	f7 d8                	neg    %eax
}
  800ad5:	5b                   	pop    %ebx
  800ad6:	5e                   	pop    %esi
  800ad7:	5f                   	pop    %edi
  800ad8:	5d                   	pop    %ebp
  800ad9:	c3                   	ret    

00800ada <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800ada:	55                   	push   %ebp
  800adb:	89 e5                	mov    %esp,%ebp
  800add:	57                   	push   %edi
  800ade:	56                   	push   %esi
  800adf:	53                   	push   %ebx
	asm volatile("int %1\n"
  800ae0:	b8 00 00 00 00       	mov    $0x0,%eax
  800ae5:	8b 55 08             	mov    0x8(%ebp),%edx
  800ae8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800aeb:	89 c3                	mov    %eax,%ebx
  800aed:	89 c7                	mov    %eax,%edi
  800aef:	89 c6                	mov    %eax,%esi
  800af1:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800af3:	5b                   	pop    %ebx
  800af4:	5e                   	pop    %esi
  800af5:	5f                   	pop    %edi
  800af6:	5d                   	pop    %ebp
  800af7:	c3                   	ret    

00800af8 <sys_cgetc>:

int
sys_cgetc(void)
{
  800af8:	55                   	push   %ebp
  800af9:	89 e5                	mov    %esp,%ebp
  800afb:	57                   	push   %edi
  800afc:	56                   	push   %esi
  800afd:	53                   	push   %ebx
	asm volatile("int %1\n"
  800afe:	ba 00 00 00 00       	mov    $0x0,%edx
  800b03:	b8 01 00 00 00       	mov    $0x1,%eax
  800b08:	89 d1                	mov    %edx,%ecx
  800b0a:	89 d3                	mov    %edx,%ebx
  800b0c:	89 d7                	mov    %edx,%edi
  800b0e:	89 d6                	mov    %edx,%esi
  800b10:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b12:	5b                   	pop    %ebx
  800b13:	5e                   	pop    %esi
  800b14:	5f                   	pop    %edi
  800b15:	5d                   	pop    %ebp
  800b16:	c3                   	ret    

00800b17 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b17:	55                   	push   %ebp
  800b18:	89 e5                	mov    %esp,%ebp
  800b1a:	57                   	push   %edi
  800b1b:	56                   	push   %esi
  800b1c:	53                   	push   %ebx
  800b1d:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800b20:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b25:	8b 55 08             	mov    0x8(%ebp),%edx
  800b28:	b8 03 00 00 00       	mov    $0x3,%eax
  800b2d:	89 cb                	mov    %ecx,%ebx
  800b2f:	89 cf                	mov    %ecx,%edi
  800b31:	89 ce                	mov    %ecx,%esi
  800b33:	cd 30                	int    $0x30
	if(check && ret > 0)
  800b35:	85 c0                	test   %eax,%eax
  800b37:	7f 08                	jg     800b41 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b39:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b3c:	5b                   	pop    %ebx
  800b3d:	5e                   	pop    %esi
  800b3e:	5f                   	pop    %edi
  800b3f:	5d                   	pop    %ebp
  800b40:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800b41:	83 ec 0c             	sub    $0xc,%esp
  800b44:	50                   	push   %eax
  800b45:	6a 03                	push   $0x3
  800b47:	68 90 10 80 00       	push   $0x801090
  800b4c:	6a 23                	push   $0x23
  800b4e:	68 ad 10 80 00       	push   $0x8010ad
  800b53:	e8 ef f5 ff ff       	call   800147 <_panic>

00800b58 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b58:	55                   	push   %ebp
  800b59:	89 e5                	mov    %esp,%ebp
  800b5b:	57                   	push   %edi
  800b5c:	56                   	push   %esi
  800b5d:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b5e:	ba 00 00 00 00       	mov    $0x0,%edx
  800b63:	b8 02 00 00 00       	mov    $0x2,%eax
  800b68:	89 d1                	mov    %edx,%ecx
  800b6a:	89 d3                	mov    %edx,%ebx
  800b6c:	89 d7                	mov    %edx,%edi
  800b6e:	89 d6                	mov    %edx,%esi
  800b70:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b72:	5b                   	pop    %ebx
  800b73:	5e                   	pop    %esi
  800b74:	5f                   	pop    %edi
  800b75:	5d                   	pop    %ebp
  800b76:	c3                   	ret    
  800b77:	90                   	nop

00800b78 <__udivdi3>:
  800b78:	55                   	push   %ebp
  800b79:	57                   	push   %edi
  800b7a:	56                   	push   %esi
  800b7b:	53                   	push   %ebx
  800b7c:	83 ec 1c             	sub    $0x1c,%esp
  800b7f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800b83:	8b 74 24 34          	mov    0x34(%esp),%esi
  800b87:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800b8b:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800b8f:	85 d2                	test   %edx,%edx
  800b91:	75 19                	jne    800bac <__udivdi3+0x34>
  800b93:	39 f7                	cmp    %esi,%edi
  800b95:	76 45                	jbe    800bdc <__udivdi3+0x64>
  800b97:	89 e8                	mov    %ebp,%eax
  800b99:	89 f2                	mov    %esi,%edx
  800b9b:	f7 f7                	div    %edi
  800b9d:	31 db                	xor    %ebx,%ebx
  800b9f:	89 da                	mov    %ebx,%edx
  800ba1:	83 c4 1c             	add    $0x1c,%esp
  800ba4:	5b                   	pop    %ebx
  800ba5:	5e                   	pop    %esi
  800ba6:	5f                   	pop    %edi
  800ba7:	5d                   	pop    %ebp
  800ba8:	c3                   	ret    
  800ba9:	8d 76 00             	lea    0x0(%esi),%esi
  800bac:	39 f2                	cmp    %esi,%edx
  800bae:	76 10                	jbe    800bc0 <__udivdi3+0x48>
  800bb0:	31 db                	xor    %ebx,%ebx
  800bb2:	31 c0                	xor    %eax,%eax
  800bb4:	89 da                	mov    %ebx,%edx
  800bb6:	83 c4 1c             	add    $0x1c,%esp
  800bb9:	5b                   	pop    %ebx
  800bba:	5e                   	pop    %esi
  800bbb:	5f                   	pop    %edi
  800bbc:	5d                   	pop    %ebp
  800bbd:	c3                   	ret    
  800bbe:	66 90                	xchg   %ax,%ax
  800bc0:	0f bd da             	bsr    %edx,%ebx
  800bc3:	83 f3 1f             	xor    $0x1f,%ebx
  800bc6:	75 3c                	jne    800c04 <__udivdi3+0x8c>
  800bc8:	39 f2                	cmp    %esi,%edx
  800bca:	72 08                	jb     800bd4 <__udivdi3+0x5c>
  800bcc:	39 ef                	cmp    %ebp,%edi
  800bce:	0f 87 9c 00 00 00    	ja     800c70 <__udivdi3+0xf8>
  800bd4:	b8 01 00 00 00       	mov    $0x1,%eax
  800bd9:	eb d9                	jmp    800bb4 <__udivdi3+0x3c>
  800bdb:	90                   	nop
  800bdc:	89 f9                	mov    %edi,%ecx
  800bde:	85 ff                	test   %edi,%edi
  800be0:	75 0b                	jne    800bed <__udivdi3+0x75>
  800be2:	b8 01 00 00 00       	mov    $0x1,%eax
  800be7:	31 d2                	xor    %edx,%edx
  800be9:	f7 f7                	div    %edi
  800beb:	89 c1                	mov    %eax,%ecx
  800bed:	31 d2                	xor    %edx,%edx
  800bef:	89 f0                	mov    %esi,%eax
  800bf1:	f7 f1                	div    %ecx
  800bf3:	89 c3                	mov    %eax,%ebx
  800bf5:	89 e8                	mov    %ebp,%eax
  800bf7:	f7 f1                	div    %ecx
  800bf9:	89 da                	mov    %ebx,%edx
  800bfb:	83 c4 1c             	add    $0x1c,%esp
  800bfe:	5b                   	pop    %ebx
  800bff:	5e                   	pop    %esi
  800c00:	5f                   	pop    %edi
  800c01:	5d                   	pop    %ebp
  800c02:	c3                   	ret    
  800c03:	90                   	nop
  800c04:	b8 20 00 00 00       	mov    $0x20,%eax
  800c09:	29 d8                	sub    %ebx,%eax
  800c0b:	88 d9                	mov    %bl,%cl
  800c0d:	d3 e2                	shl    %cl,%edx
  800c0f:	89 54 24 08          	mov    %edx,0x8(%esp)
  800c13:	89 fa                	mov    %edi,%edx
  800c15:	88 c1                	mov    %al,%cl
  800c17:	d3 ea                	shr    %cl,%edx
  800c19:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800c1d:	09 d1                	or     %edx,%ecx
  800c1f:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800c23:	88 d9                	mov    %bl,%cl
  800c25:	d3 e7                	shl    %cl,%edi
  800c27:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800c2b:	89 f7                	mov    %esi,%edi
  800c2d:	88 c1                	mov    %al,%cl
  800c2f:	d3 ef                	shr    %cl,%edi
  800c31:	88 d9                	mov    %bl,%cl
  800c33:	d3 e6                	shl    %cl,%esi
  800c35:	89 ea                	mov    %ebp,%edx
  800c37:	88 c1                	mov    %al,%cl
  800c39:	d3 ea                	shr    %cl,%edx
  800c3b:	09 d6                	or     %edx,%esi
  800c3d:	89 f0                	mov    %esi,%eax
  800c3f:	89 fa                	mov    %edi,%edx
  800c41:	f7 74 24 08          	divl   0x8(%esp)
  800c45:	89 d7                	mov    %edx,%edi
  800c47:	89 c6                	mov    %eax,%esi
  800c49:	f7 64 24 0c          	mull   0xc(%esp)
  800c4d:	39 d7                	cmp    %edx,%edi
  800c4f:	72 13                	jb     800c64 <__udivdi3+0xec>
  800c51:	74 09                	je     800c5c <__udivdi3+0xe4>
  800c53:	89 f0                	mov    %esi,%eax
  800c55:	31 db                	xor    %ebx,%ebx
  800c57:	e9 58 ff ff ff       	jmp    800bb4 <__udivdi3+0x3c>
  800c5c:	88 d9                	mov    %bl,%cl
  800c5e:	d3 e5                	shl    %cl,%ebp
  800c60:	39 c5                	cmp    %eax,%ebp
  800c62:	73 ef                	jae    800c53 <__udivdi3+0xdb>
  800c64:	8d 46 ff             	lea    -0x1(%esi),%eax
  800c67:	31 db                	xor    %ebx,%ebx
  800c69:	e9 46 ff ff ff       	jmp    800bb4 <__udivdi3+0x3c>
  800c6e:	66 90                	xchg   %ax,%ax
  800c70:	31 c0                	xor    %eax,%eax
  800c72:	e9 3d ff ff ff       	jmp    800bb4 <__udivdi3+0x3c>
  800c77:	90                   	nop

00800c78 <__umoddi3>:
  800c78:	55                   	push   %ebp
  800c79:	57                   	push   %edi
  800c7a:	56                   	push   %esi
  800c7b:	53                   	push   %ebx
  800c7c:	83 ec 1c             	sub    $0x1c,%esp
  800c7f:	8b 74 24 30          	mov    0x30(%esp),%esi
  800c83:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800c87:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800c8b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  800c8f:	85 c0                	test   %eax,%eax
  800c91:	75 19                	jne    800cac <__umoddi3+0x34>
  800c93:	39 df                	cmp    %ebx,%edi
  800c95:	76 51                	jbe    800ce8 <__umoddi3+0x70>
  800c97:	89 f0                	mov    %esi,%eax
  800c99:	89 da                	mov    %ebx,%edx
  800c9b:	f7 f7                	div    %edi
  800c9d:	89 d0                	mov    %edx,%eax
  800c9f:	31 d2                	xor    %edx,%edx
  800ca1:	83 c4 1c             	add    $0x1c,%esp
  800ca4:	5b                   	pop    %ebx
  800ca5:	5e                   	pop    %esi
  800ca6:	5f                   	pop    %edi
  800ca7:	5d                   	pop    %ebp
  800ca8:	c3                   	ret    
  800ca9:	8d 76 00             	lea    0x0(%esi),%esi
  800cac:	89 f2                	mov    %esi,%edx
  800cae:	39 d8                	cmp    %ebx,%eax
  800cb0:	76 0e                	jbe    800cc0 <__umoddi3+0x48>
  800cb2:	89 f0                	mov    %esi,%eax
  800cb4:	89 da                	mov    %ebx,%edx
  800cb6:	83 c4 1c             	add    $0x1c,%esp
  800cb9:	5b                   	pop    %ebx
  800cba:	5e                   	pop    %esi
  800cbb:	5f                   	pop    %edi
  800cbc:	5d                   	pop    %ebp
  800cbd:	c3                   	ret    
  800cbe:	66 90                	xchg   %ax,%ax
  800cc0:	0f bd e8             	bsr    %eax,%ebp
  800cc3:	83 f5 1f             	xor    $0x1f,%ebp
  800cc6:	75 44                	jne    800d0c <__umoddi3+0x94>
  800cc8:	39 d8                	cmp    %ebx,%eax
  800cca:	72 06                	jb     800cd2 <__umoddi3+0x5a>
  800ccc:	89 d9                	mov    %ebx,%ecx
  800cce:	39 f7                	cmp    %esi,%edi
  800cd0:	77 08                	ja     800cda <__umoddi3+0x62>
  800cd2:	29 fe                	sub    %edi,%esi
  800cd4:	19 c3                	sbb    %eax,%ebx
  800cd6:	89 f2                	mov    %esi,%edx
  800cd8:	89 d9                	mov    %ebx,%ecx
  800cda:	89 d0                	mov    %edx,%eax
  800cdc:	89 ca                	mov    %ecx,%edx
  800cde:	83 c4 1c             	add    $0x1c,%esp
  800ce1:	5b                   	pop    %ebx
  800ce2:	5e                   	pop    %esi
  800ce3:	5f                   	pop    %edi
  800ce4:	5d                   	pop    %ebp
  800ce5:	c3                   	ret    
  800ce6:	66 90                	xchg   %ax,%ax
  800ce8:	89 fd                	mov    %edi,%ebp
  800cea:	85 ff                	test   %edi,%edi
  800cec:	75 0b                	jne    800cf9 <__umoddi3+0x81>
  800cee:	b8 01 00 00 00       	mov    $0x1,%eax
  800cf3:	31 d2                	xor    %edx,%edx
  800cf5:	f7 f7                	div    %edi
  800cf7:	89 c5                	mov    %eax,%ebp
  800cf9:	89 d8                	mov    %ebx,%eax
  800cfb:	31 d2                	xor    %edx,%edx
  800cfd:	f7 f5                	div    %ebp
  800cff:	89 f0                	mov    %esi,%eax
  800d01:	f7 f5                	div    %ebp
  800d03:	89 d0                	mov    %edx,%eax
  800d05:	31 d2                	xor    %edx,%edx
  800d07:	eb 98                	jmp    800ca1 <__umoddi3+0x29>
  800d09:	8d 76 00             	lea    0x0(%esi),%esi
  800d0c:	ba 20 00 00 00       	mov    $0x20,%edx
  800d11:	29 ea                	sub    %ebp,%edx
  800d13:	89 e9                	mov    %ebp,%ecx
  800d15:	d3 e0                	shl    %cl,%eax
  800d17:	89 44 24 08          	mov    %eax,0x8(%esp)
  800d1b:	89 f8                	mov    %edi,%eax
  800d1d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800d21:	88 d1                	mov    %dl,%cl
  800d23:	d3 e8                	shr    %cl,%eax
  800d25:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800d29:	09 c1                	or     %eax,%ecx
  800d2b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800d2f:	89 e9                	mov    %ebp,%ecx
  800d31:	d3 e7                	shl    %cl,%edi
  800d33:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800d37:	89 d8                	mov    %ebx,%eax
  800d39:	8b 54 24 04          	mov    0x4(%esp),%edx
  800d3d:	88 d1                	mov    %dl,%cl
  800d3f:	d3 e8                	shr    %cl,%eax
  800d41:	89 c7                	mov    %eax,%edi
  800d43:	89 e9                	mov    %ebp,%ecx
  800d45:	d3 e3                	shl    %cl,%ebx
  800d47:	89 f0                	mov    %esi,%eax
  800d49:	88 d1                	mov    %dl,%cl
  800d4b:	d3 e8                	shr    %cl,%eax
  800d4d:	09 d8                	or     %ebx,%eax
  800d4f:	89 e9                	mov    %ebp,%ecx
  800d51:	d3 e6                	shl    %cl,%esi
  800d53:	89 f3                	mov    %esi,%ebx
  800d55:	89 fa                	mov    %edi,%edx
  800d57:	f7 74 24 08          	divl   0x8(%esp)
  800d5b:	89 d1                	mov    %edx,%ecx
  800d5d:	f7 64 24 0c          	mull   0xc(%esp)
  800d61:	89 c6                	mov    %eax,%esi
  800d63:	89 d7                	mov    %edx,%edi
  800d65:	39 d1                	cmp    %edx,%ecx
  800d67:	72 27                	jb     800d90 <__umoddi3+0x118>
  800d69:	74 21                	je     800d8c <__umoddi3+0x114>
  800d6b:	89 ca                	mov    %ecx,%edx
  800d6d:	29 f3                	sub    %esi,%ebx
  800d6f:	19 fa                	sbb    %edi,%edx
  800d71:	89 d0                	mov    %edx,%eax
  800d73:	8a 4c 24 04          	mov    0x4(%esp),%cl
  800d77:	d3 e0                	shl    %cl,%eax
  800d79:	89 e9                	mov    %ebp,%ecx
  800d7b:	d3 eb                	shr    %cl,%ebx
  800d7d:	09 d8                	or     %ebx,%eax
  800d7f:	d3 ea                	shr    %cl,%edx
  800d81:	83 c4 1c             	add    $0x1c,%esp
  800d84:	5b                   	pop    %ebx
  800d85:	5e                   	pop    %esi
  800d86:	5f                   	pop    %edi
  800d87:	5d                   	pop    %ebp
  800d88:	c3                   	ret    
  800d89:	8d 76 00             	lea    0x0(%esi),%esi
  800d8c:	39 c3                	cmp    %eax,%ebx
  800d8e:	73 db                	jae    800d6b <__umoddi3+0xf3>
  800d90:	2b 44 24 0c          	sub    0xc(%esp),%eax
  800d94:	1b 54 24 08          	sbb    0x8(%esp),%edx
  800d98:	89 d7                	mov    %edx,%edi
  800d9a:	89 c6                	mov    %eax,%esi
  800d9c:	eb cd                	jmp    800d6b <__umoddi3+0xf3>
