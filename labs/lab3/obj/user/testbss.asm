
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
  800039:	68 78 0d 80 00       	push   $0x800d78
  80003e:	e8 b5 01 00 00       	call   8001f8 <cprintf>
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
  80008a:	68 c0 0d 80 00       	push   $0x800dc0
  80008f:	e8 64 01 00 00       	call   8001f8 <cprintf>
	bigarray[ARRAYSIZE+1024] = 0;
  800094:	c7 05 20 30 c0 00 00 	movl   $0x0,0xc03020
  80009b:	00 00 00 
	panic("SHOULD HAVE TRAPPED!!!");
  80009e:	83 c4 0c             	add    $0xc,%esp
  8000a1:	68 1f 0e 80 00       	push   $0x800e1f
  8000a6:	6a 1a                	push   $0x1a
  8000a8:	68 10 0e 80 00       	push   $0x800e10
  8000ad:	e8 6c 00 00 00       	call   80011e <_panic>
			panic("bigarray[%d] isn't cleared!\n", i);
  8000b2:	50                   	push   %eax
  8000b3:	68 f3 0d 80 00       	push   $0x800df3
  8000b8:	6a 11                	push   $0x11
  8000ba:	68 10 0e 80 00       	push   $0x800e10
  8000bf:	e8 5a 00 00 00       	call   80011e <_panic>
			panic("bigarray[%d] didn't hold its value!\n", i);
  8000c4:	50                   	push   %eax
  8000c5:	68 98 0d 80 00       	push   $0x800d98
  8000ca:	6a 16                	push   $0x16
  8000cc:	68 10 0e 80 00       	push   $0x800e10
  8000d1:	e8 48 00 00 00       	call   80011e <_panic>

008000d6 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000d6:	55                   	push   %ebp
  8000d7:	89 e5                	mov    %esp,%ebp
  8000d9:	83 ec 08             	sub    $0x8,%esp
  8000dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8000df:	8b 55 0c             	mov    0xc(%ebp),%edx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  8000e2:	c7 05 20 20 c0 00 00 	movl   $0x0,0xc02020
  8000e9:	00 00 00 

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000ec:	85 c0                	test   %eax,%eax
  8000ee:	7e 08                	jle    8000f8 <libmain+0x22>
		binaryname = argv[0];
  8000f0:	8b 0a                	mov    (%edx),%ecx
  8000f2:	89 0d 00 20 80 00    	mov    %ecx,0x802000

	// call user main routine
	umain(argc, argv);
  8000f8:	83 ec 08             	sub    $0x8,%esp
  8000fb:	52                   	push   %edx
  8000fc:	50                   	push   %eax
  8000fd:	e8 31 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800102:	e8 05 00 00 00       	call   80010c <exit>
}
  800107:	83 c4 10             	add    $0x10,%esp
  80010a:	c9                   	leave  
  80010b:	c3                   	ret    

0080010c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80010c:	55                   	push   %ebp
  80010d:	89 e5                	mov    %esp,%ebp
  80010f:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800112:	6a 00                	push   $0x0
  800114:	e8 d5 09 00 00       	call   800aee <sys_env_destroy>
}
  800119:	83 c4 10             	add    $0x10,%esp
  80011c:	c9                   	leave  
  80011d:	c3                   	ret    

0080011e <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80011e:	55                   	push   %ebp
  80011f:	89 e5                	mov    %esp,%ebp
  800121:	56                   	push   %esi
  800122:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800123:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800126:	8b 35 00 20 80 00    	mov    0x802000,%esi
  80012c:	e8 fe 09 00 00       	call   800b2f <sys_getenvid>
  800131:	83 ec 0c             	sub    $0xc,%esp
  800134:	ff 75 0c             	pushl  0xc(%ebp)
  800137:	ff 75 08             	pushl  0x8(%ebp)
  80013a:	56                   	push   %esi
  80013b:	50                   	push   %eax
  80013c:	68 40 0e 80 00       	push   $0x800e40
  800141:	e8 b2 00 00 00       	call   8001f8 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800146:	83 c4 18             	add    $0x18,%esp
  800149:	53                   	push   %ebx
  80014a:	ff 75 10             	pushl  0x10(%ebp)
  80014d:	e8 55 00 00 00       	call   8001a7 <vcprintf>
	cprintf("\n");
  800152:	c7 04 24 0e 0e 80 00 	movl   $0x800e0e,(%esp)
  800159:	e8 9a 00 00 00       	call   8001f8 <cprintf>
  80015e:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800161:	cc                   	int3   
  800162:	eb fd                	jmp    800161 <_panic+0x43>

00800164 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800164:	55                   	push   %ebp
  800165:	89 e5                	mov    %esp,%ebp
  800167:	53                   	push   %ebx
  800168:	83 ec 04             	sub    $0x4,%esp
  80016b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80016e:	8b 13                	mov    (%ebx),%edx
  800170:	8d 42 01             	lea    0x1(%edx),%eax
  800173:	89 03                	mov    %eax,(%ebx)
  800175:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800178:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80017c:	3d ff 00 00 00       	cmp    $0xff,%eax
  800181:	74 08                	je     80018b <putch+0x27>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800183:	ff 43 04             	incl   0x4(%ebx)
}
  800186:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800189:	c9                   	leave  
  80018a:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  80018b:	83 ec 08             	sub    $0x8,%esp
  80018e:	68 ff 00 00 00       	push   $0xff
  800193:	8d 43 08             	lea    0x8(%ebx),%eax
  800196:	50                   	push   %eax
  800197:	e8 15 09 00 00       	call   800ab1 <sys_cputs>
		b->idx = 0;
  80019c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001a2:	83 c4 10             	add    $0x10,%esp
  8001a5:	eb dc                	jmp    800183 <putch+0x1f>

008001a7 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001a7:	55                   	push   %ebp
  8001a8:	89 e5                	mov    %esp,%ebp
  8001aa:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001b0:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001b7:	00 00 00 
	b.cnt = 0;
  8001ba:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001c1:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001c4:	ff 75 0c             	pushl  0xc(%ebp)
  8001c7:	ff 75 08             	pushl  0x8(%ebp)
  8001ca:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001d0:	50                   	push   %eax
  8001d1:	68 64 01 80 00       	push   $0x800164
  8001d6:	e8 0f 01 00 00       	call   8002ea <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001db:	83 c4 08             	add    $0x8,%esp
  8001de:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001e4:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001ea:	50                   	push   %eax
  8001eb:	e8 c1 08 00 00       	call   800ab1 <sys_cputs>

	return b.cnt;
}
  8001f0:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001f6:	c9                   	leave  
  8001f7:	c3                   	ret    

008001f8 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001f8:	55                   	push   %ebp
  8001f9:	89 e5                	mov    %esp,%ebp
  8001fb:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001fe:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800201:	50                   	push   %eax
  800202:	ff 75 08             	pushl  0x8(%ebp)
  800205:	e8 9d ff ff ff       	call   8001a7 <vcprintf>
	va_end(ap);

	return cnt;
}
  80020a:	c9                   	leave  
  80020b:	c3                   	ret    

0080020c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80020c:	55                   	push   %ebp
  80020d:	89 e5                	mov    %esp,%ebp
  80020f:	57                   	push   %edi
  800210:	56                   	push   %esi
  800211:	53                   	push   %ebx
  800212:	83 ec 1c             	sub    $0x1c,%esp
  800215:	89 c7                	mov    %eax,%edi
  800217:	89 d6                	mov    %edx,%esi
  800219:	8b 45 08             	mov    0x8(%ebp),%eax
  80021c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80021f:	89 d1                	mov    %edx,%ecx
  800221:	89 c2                	mov    %eax,%edx
  800223:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800226:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800229:	8b 45 10             	mov    0x10(%ebp),%eax
  80022c:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80022f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800232:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800239:	39 c2                	cmp    %eax,%edx
  80023b:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  80023e:	72 3c                	jb     80027c <printnum+0x70>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800240:	83 ec 0c             	sub    $0xc,%esp
  800243:	ff 75 18             	pushl  0x18(%ebp)
  800246:	4b                   	dec    %ebx
  800247:	53                   	push   %ebx
  800248:	50                   	push   %eax
  800249:	83 ec 08             	sub    $0x8,%esp
  80024c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80024f:	ff 75 e0             	pushl  -0x20(%ebp)
  800252:	ff 75 dc             	pushl  -0x24(%ebp)
  800255:	ff 75 d8             	pushl  -0x28(%ebp)
  800258:	e8 f3 08 00 00       	call   800b50 <__udivdi3>
  80025d:	83 c4 18             	add    $0x18,%esp
  800260:	52                   	push   %edx
  800261:	50                   	push   %eax
  800262:	89 f2                	mov    %esi,%edx
  800264:	89 f8                	mov    %edi,%eax
  800266:	e8 a1 ff ff ff       	call   80020c <printnum>
  80026b:	83 c4 20             	add    $0x20,%esp
  80026e:	eb 11                	jmp    800281 <printnum+0x75>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800270:	83 ec 08             	sub    $0x8,%esp
  800273:	56                   	push   %esi
  800274:	ff 75 18             	pushl  0x18(%ebp)
  800277:	ff d7                	call   *%edi
  800279:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  80027c:	4b                   	dec    %ebx
  80027d:	85 db                	test   %ebx,%ebx
  80027f:	7f ef                	jg     800270 <printnum+0x64>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800281:	83 ec 08             	sub    $0x8,%esp
  800284:	56                   	push   %esi
  800285:	83 ec 04             	sub    $0x4,%esp
  800288:	ff 75 e4             	pushl  -0x1c(%ebp)
  80028b:	ff 75 e0             	pushl  -0x20(%ebp)
  80028e:	ff 75 dc             	pushl  -0x24(%ebp)
  800291:	ff 75 d8             	pushl  -0x28(%ebp)
  800294:	e8 b7 09 00 00       	call   800c50 <__umoddi3>
  800299:	83 c4 14             	add    $0x14,%esp
  80029c:	0f be 80 64 0e 80 00 	movsbl 0x800e64(%eax),%eax
  8002a3:	50                   	push   %eax
  8002a4:	ff d7                	call   *%edi
}
  8002a6:	83 c4 10             	add    $0x10,%esp
  8002a9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002ac:	5b                   	pop    %ebx
  8002ad:	5e                   	pop    %esi
  8002ae:	5f                   	pop    %edi
  8002af:	5d                   	pop    %ebp
  8002b0:	c3                   	ret    

008002b1 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002b1:	55                   	push   %ebp
  8002b2:	89 e5                	mov    %esp,%ebp
  8002b4:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002b7:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8002ba:	8b 10                	mov    (%eax),%edx
  8002bc:	3b 50 04             	cmp    0x4(%eax),%edx
  8002bf:	73 0a                	jae    8002cb <sprintputch+0x1a>
		*b->buf++ = ch;
  8002c1:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002c4:	89 08                	mov    %ecx,(%eax)
  8002c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8002c9:	88 02                	mov    %al,(%edx)
}
  8002cb:	5d                   	pop    %ebp
  8002cc:	c3                   	ret    

008002cd <printfmt>:
{
  8002cd:	55                   	push   %ebp
  8002ce:	89 e5                	mov    %esp,%ebp
  8002d0:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8002d3:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002d6:	50                   	push   %eax
  8002d7:	ff 75 10             	pushl  0x10(%ebp)
  8002da:	ff 75 0c             	pushl  0xc(%ebp)
  8002dd:	ff 75 08             	pushl  0x8(%ebp)
  8002e0:	e8 05 00 00 00       	call   8002ea <vprintfmt>
}
  8002e5:	83 c4 10             	add    $0x10,%esp
  8002e8:	c9                   	leave  
  8002e9:	c3                   	ret    

008002ea <vprintfmt>:
{
  8002ea:	55                   	push   %ebp
  8002eb:	89 e5                	mov    %esp,%ebp
  8002ed:	57                   	push   %edi
  8002ee:	56                   	push   %esi
  8002ef:	53                   	push   %ebx
  8002f0:	83 ec 3c             	sub    $0x3c,%esp
  8002f3:	8b 75 08             	mov    0x8(%ebp),%esi
  8002f6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002f9:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002fc:	e9 5b 03 00 00       	jmp    80065c <vprintfmt+0x372>
		padc = ' ';
  800301:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  800305:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
		precision = -1;
  80030c:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  800313:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		lflag = 0;
  80031a:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80031f:	8d 47 01             	lea    0x1(%edi),%eax
  800322:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800325:	8a 17                	mov    (%edi),%dl
  800327:	8d 42 dd             	lea    -0x23(%edx),%eax
  80032a:	3c 55                	cmp    $0x55,%al
  80032c:	0f 87 ab 03 00 00    	ja     8006dd <vprintfmt+0x3f3>
  800332:	0f b6 c0             	movzbl %al,%eax
  800335:	ff 24 85 f4 0e 80 00 	jmp    *0x800ef4(,%eax,4)
  80033c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  80033f:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  800343:	eb da                	jmp    80031f <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  800345:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800348:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  80034c:	eb d1                	jmp    80031f <vprintfmt+0x35>
  80034e:	0f b6 d2             	movzbl %dl,%edx
  800351:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800354:	b8 00 00 00 00       	mov    $0x0,%eax
  800359:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  80035c:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80035f:	01 c0                	add    %eax,%eax
  800361:	8d 44 02 d0          	lea    -0x30(%edx,%eax,1),%eax
				ch = *fmt;
  800365:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800368:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80036b:	83 f9 09             	cmp    $0x9,%ecx
  80036e:	77 52                	ja     8003c2 <vprintfmt+0xd8>
			for (precision = 0; ; ++fmt) {
  800370:	47                   	inc    %edi
				precision = precision * 10 + ch - '0';
  800371:	eb e9                	jmp    80035c <vprintfmt+0x72>
			precision = va_arg(ap, int);
  800373:	8b 45 14             	mov    0x14(%ebp),%eax
  800376:	8b 00                	mov    (%eax),%eax
  800378:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80037b:	8b 45 14             	mov    0x14(%ebp),%eax
  80037e:	8d 40 04             	lea    0x4(%eax),%eax
  800381:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800384:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800387:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80038b:	79 92                	jns    80031f <vprintfmt+0x35>
				width = precision, precision = -1;
  80038d:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800390:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800393:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  80039a:	eb 83                	jmp    80031f <vprintfmt+0x35>
  80039c:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8003a0:	78 08                	js     8003aa <vprintfmt+0xc0>
		switch (ch = *(unsigned char *) fmt++) {
  8003a2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8003a5:	e9 75 ff ff ff       	jmp    80031f <vprintfmt+0x35>
  8003aa:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  8003b1:	eb ef                	jmp    8003a2 <vprintfmt+0xb8>
		switch (ch = *(unsigned char *) fmt++) {
  8003b3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8003b6:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  8003bd:	e9 5d ff ff ff       	jmp    80031f <vprintfmt+0x35>
  8003c2:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8003c5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003c8:	eb bd                	jmp    800387 <vprintfmt+0x9d>
			lflag++;
  8003ca:	41                   	inc    %ecx
		switch (ch = *(unsigned char *) fmt++) {
  8003cb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8003ce:	e9 4c ff ff ff       	jmp    80031f <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
  8003d3:	8b 45 14             	mov    0x14(%ebp),%eax
  8003d6:	8d 78 04             	lea    0x4(%eax),%edi
  8003d9:	83 ec 08             	sub    $0x8,%esp
  8003dc:	53                   	push   %ebx
  8003dd:	ff 30                	pushl  (%eax)
  8003df:	ff d6                	call   *%esi
			break;
  8003e1:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8003e4:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8003e7:	e9 6d 02 00 00       	jmp    800659 <vprintfmt+0x36f>
			err = va_arg(ap, int);
  8003ec:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ef:	8d 78 04             	lea    0x4(%eax),%edi
  8003f2:	8b 00                	mov    (%eax),%eax
  8003f4:	85 c0                	test   %eax,%eax
  8003f6:	78 2a                	js     800422 <vprintfmt+0x138>
  8003f8:	89 c2                	mov    %eax,%edx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003fa:	83 f8 06             	cmp    $0x6,%eax
  8003fd:	7f 27                	jg     800426 <vprintfmt+0x13c>
  8003ff:	8b 04 85 4c 10 80 00 	mov    0x80104c(,%eax,4),%eax
  800406:	85 c0                	test   %eax,%eax
  800408:	74 1c                	je     800426 <vprintfmt+0x13c>
				printfmt(putch, putdat, "%s", p);
  80040a:	50                   	push   %eax
  80040b:	68 85 0e 80 00       	push   $0x800e85
  800410:	53                   	push   %ebx
  800411:	56                   	push   %esi
  800412:	e8 b6 fe ff ff       	call   8002cd <printfmt>
  800417:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80041a:	89 7d 14             	mov    %edi,0x14(%ebp)
  80041d:	e9 37 02 00 00       	jmp    800659 <vprintfmt+0x36f>
  800422:	f7 d8                	neg    %eax
  800424:	eb d2                	jmp    8003f8 <vprintfmt+0x10e>
				printfmt(putch, putdat, "error %d", err);
  800426:	52                   	push   %edx
  800427:	68 7c 0e 80 00       	push   $0x800e7c
  80042c:	53                   	push   %ebx
  80042d:	56                   	push   %esi
  80042e:	e8 9a fe ff ff       	call   8002cd <printfmt>
  800433:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800436:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800439:	e9 1b 02 00 00       	jmp    800659 <vprintfmt+0x36f>
			if ((p = va_arg(ap, char *)) == NULL)
  80043e:	8b 45 14             	mov    0x14(%ebp),%eax
  800441:	83 c0 04             	add    $0x4,%eax
  800444:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800447:	8b 45 14             	mov    0x14(%ebp),%eax
  80044a:	8b 00                	mov    (%eax),%eax
  80044c:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80044f:	85 c0                	test   %eax,%eax
  800451:	74 19                	je     80046c <vprintfmt+0x182>
			if (width > 0 && padc != '-')
  800453:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800457:	7e 06                	jle    80045f <vprintfmt+0x175>
  800459:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  80045d:	75 16                	jne    800475 <vprintfmt+0x18b>
				for (width -= strnlen(p, precision); width > 0; width--)
  80045f:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800462:	89 c7                	mov    %eax,%edi
  800464:	03 45 d4             	add    -0x2c(%ebp),%eax
  800467:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80046a:	eb 62                	jmp    8004ce <vprintfmt+0x1e4>
				p = "(null)";
  80046c:	c7 45 cc 75 0e 80 00 	movl   $0x800e75,-0x34(%ebp)
  800473:	eb de                	jmp    800453 <vprintfmt+0x169>
				for (width -= strnlen(p, precision); width > 0; width--)
  800475:	83 ec 08             	sub    $0x8,%esp
  800478:	ff 75 d8             	pushl  -0x28(%ebp)
  80047b:	ff 75 cc             	pushl  -0x34(%ebp)
  80047e:	e8 05 03 00 00       	call   800788 <strnlen>
  800483:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800486:	29 c2                	sub    %eax,%edx
  800488:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  80048b:	83 c4 10             	add    $0x10,%esp
  80048e:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  800490:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  800494:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  800497:	eb 0d                	jmp    8004a6 <vprintfmt+0x1bc>
					putch(padc, putdat);
  800499:	83 ec 08             	sub    $0x8,%esp
  80049c:	53                   	push   %ebx
  80049d:	ff 75 d4             	pushl  -0x2c(%ebp)
  8004a0:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8004a2:	4f                   	dec    %edi
  8004a3:	83 c4 10             	add    $0x10,%esp
  8004a6:	85 ff                	test   %edi,%edi
  8004a8:	7f ef                	jg     800499 <vprintfmt+0x1af>
  8004aa:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8004ad:	89 d0                	mov    %edx,%eax
  8004af:	85 d2                	test   %edx,%edx
  8004b1:	78 0a                	js     8004bd <vprintfmt+0x1d3>
  8004b3:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8004b6:	29 c2                	sub    %eax,%edx
  8004b8:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8004bb:	eb a2                	jmp    80045f <vprintfmt+0x175>
  8004bd:	b8 00 00 00 00       	mov    $0x0,%eax
  8004c2:	eb ef                	jmp    8004b3 <vprintfmt+0x1c9>
					putch(ch, putdat);
  8004c4:	83 ec 08             	sub    $0x8,%esp
  8004c7:	53                   	push   %ebx
  8004c8:	52                   	push   %edx
  8004c9:	ff d6                	call   *%esi
  8004cb:	83 c4 10             	add    $0x10,%esp
  8004ce:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  8004d1:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004d3:	47                   	inc    %edi
  8004d4:	8a 47 ff             	mov    -0x1(%edi),%al
  8004d7:	0f be d0             	movsbl %al,%edx
  8004da:	85 d2                	test   %edx,%edx
  8004dc:	74 48                	je     800526 <vprintfmt+0x23c>
  8004de:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004e2:	78 05                	js     8004e9 <vprintfmt+0x1ff>
  8004e4:	ff 4d d8             	decl   -0x28(%ebp)
  8004e7:	78 1e                	js     800507 <vprintfmt+0x21d>
				if (altflag && (ch < ' ' || ch > '~'))
  8004e9:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004ed:	74 d5                	je     8004c4 <vprintfmt+0x1da>
  8004ef:	0f be c0             	movsbl %al,%eax
  8004f2:	83 e8 20             	sub    $0x20,%eax
  8004f5:	83 f8 5e             	cmp    $0x5e,%eax
  8004f8:	76 ca                	jbe    8004c4 <vprintfmt+0x1da>
					putch('?', putdat);
  8004fa:	83 ec 08             	sub    $0x8,%esp
  8004fd:	53                   	push   %ebx
  8004fe:	6a 3f                	push   $0x3f
  800500:	ff d6                	call   *%esi
  800502:	83 c4 10             	add    $0x10,%esp
  800505:	eb c7                	jmp    8004ce <vprintfmt+0x1e4>
  800507:	89 cf                	mov    %ecx,%edi
  800509:	eb 0c                	jmp    800517 <vprintfmt+0x22d>
				putch(' ', putdat);
  80050b:	83 ec 08             	sub    $0x8,%esp
  80050e:	53                   	push   %ebx
  80050f:	6a 20                	push   $0x20
  800511:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800513:	4f                   	dec    %edi
  800514:	83 c4 10             	add    $0x10,%esp
  800517:	85 ff                	test   %edi,%edi
  800519:	7f f0                	jg     80050b <vprintfmt+0x221>
			if ((p = va_arg(ap, char *)) == NULL)
  80051b:	8b 45 c8             	mov    -0x38(%ebp),%eax
  80051e:	89 45 14             	mov    %eax,0x14(%ebp)
  800521:	e9 33 01 00 00       	jmp    800659 <vprintfmt+0x36f>
  800526:	89 cf                	mov    %ecx,%edi
  800528:	eb ed                	jmp    800517 <vprintfmt+0x22d>
	if (lflag >= 2)
  80052a:	83 f9 01             	cmp    $0x1,%ecx
  80052d:	7f 1b                	jg     80054a <vprintfmt+0x260>
	else if (lflag)
  80052f:	85 c9                	test   %ecx,%ecx
  800531:	74 42                	je     800575 <vprintfmt+0x28b>
		return va_arg(*ap, long);
  800533:	8b 45 14             	mov    0x14(%ebp),%eax
  800536:	8b 00                	mov    (%eax),%eax
  800538:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80053b:	99                   	cltd   
  80053c:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80053f:	8b 45 14             	mov    0x14(%ebp),%eax
  800542:	8d 40 04             	lea    0x4(%eax),%eax
  800545:	89 45 14             	mov    %eax,0x14(%ebp)
  800548:	eb 17                	jmp    800561 <vprintfmt+0x277>
		return va_arg(*ap, long long);
  80054a:	8b 45 14             	mov    0x14(%ebp),%eax
  80054d:	8b 50 04             	mov    0x4(%eax),%edx
  800550:	8b 00                	mov    (%eax),%eax
  800552:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800555:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800558:	8b 45 14             	mov    0x14(%ebp),%eax
  80055b:	8d 40 08             	lea    0x8(%eax),%eax
  80055e:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800561:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800564:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800567:	85 c9                	test   %ecx,%ecx
  800569:	78 21                	js     80058c <vprintfmt+0x2a2>
			base = 10;
  80056b:	b8 0a 00 00 00       	mov    $0xa,%eax
  800570:	e9 ca 00 00 00       	jmp    80063f <vprintfmt+0x355>
		return va_arg(*ap, int);
  800575:	8b 45 14             	mov    0x14(%ebp),%eax
  800578:	8b 00                	mov    (%eax),%eax
  80057a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80057d:	99                   	cltd   
  80057e:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800581:	8b 45 14             	mov    0x14(%ebp),%eax
  800584:	8d 40 04             	lea    0x4(%eax),%eax
  800587:	89 45 14             	mov    %eax,0x14(%ebp)
  80058a:	eb d5                	jmp    800561 <vprintfmt+0x277>
				putch('-', putdat);
  80058c:	83 ec 08             	sub    $0x8,%esp
  80058f:	53                   	push   %ebx
  800590:	6a 2d                	push   $0x2d
  800592:	ff d6                	call   *%esi
				num = -(long long) num;
  800594:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800597:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80059a:	f7 da                	neg    %edx
  80059c:	83 d1 00             	adc    $0x0,%ecx
  80059f:	f7 d9                	neg    %ecx
  8005a1:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8005a4:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005a9:	e9 91 00 00 00       	jmp    80063f <vprintfmt+0x355>
	if (lflag >= 2)
  8005ae:	83 f9 01             	cmp    $0x1,%ecx
  8005b1:	7f 1b                	jg     8005ce <vprintfmt+0x2e4>
	else if (lflag)
  8005b3:	85 c9                	test   %ecx,%ecx
  8005b5:	74 2c                	je     8005e3 <vprintfmt+0x2f9>
		return va_arg(*ap, unsigned long);
  8005b7:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ba:	8b 10                	mov    (%eax),%edx
  8005bc:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005c1:	8d 40 04             	lea    0x4(%eax),%eax
  8005c4:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005c7:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  8005cc:	eb 71                	jmp    80063f <vprintfmt+0x355>
		return va_arg(*ap, unsigned long long);
  8005ce:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d1:	8b 10                	mov    (%eax),%edx
  8005d3:	8b 48 04             	mov    0x4(%eax),%ecx
  8005d6:	8d 40 08             	lea    0x8(%eax),%eax
  8005d9:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005dc:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  8005e1:	eb 5c                	jmp    80063f <vprintfmt+0x355>
		return va_arg(*ap, unsigned int);
  8005e3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e6:	8b 10                	mov    (%eax),%edx
  8005e8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005ed:	8d 40 04             	lea    0x4(%eax),%eax
  8005f0:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005f3:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  8005f8:	eb 45                	jmp    80063f <vprintfmt+0x355>
			putch('X', putdat);
  8005fa:	83 ec 08             	sub    $0x8,%esp
  8005fd:	53                   	push   %ebx
  8005fe:	6a 58                	push   $0x58
  800600:	ff d6                	call   *%esi
			putch('X', putdat);
  800602:	83 c4 08             	add    $0x8,%esp
  800605:	53                   	push   %ebx
  800606:	6a 58                	push   $0x58
  800608:	ff d6                	call   *%esi
			putch('X', putdat);
  80060a:	83 c4 08             	add    $0x8,%esp
  80060d:	53                   	push   %ebx
  80060e:	6a 58                	push   $0x58
  800610:	ff d6                	call   *%esi
			break;
  800612:	83 c4 10             	add    $0x10,%esp
  800615:	eb 42                	jmp    800659 <vprintfmt+0x36f>
			putch('0', putdat);
  800617:	83 ec 08             	sub    $0x8,%esp
  80061a:	53                   	push   %ebx
  80061b:	6a 30                	push   $0x30
  80061d:	ff d6                	call   *%esi
			putch('x', putdat);
  80061f:	83 c4 08             	add    $0x8,%esp
  800622:	53                   	push   %ebx
  800623:	6a 78                	push   $0x78
  800625:	ff d6                	call   *%esi
			num = (unsigned long long)
  800627:	8b 45 14             	mov    0x14(%ebp),%eax
  80062a:	8b 10                	mov    (%eax),%edx
  80062c:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800631:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800634:	8d 40 04             	lea    0x4(%eax),%eax
  800637:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80063a:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  80063f:	83 ec 0c             	sub    $0xc,%esp
  800642:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  800646:	57                   	push   %edi
  800647:	ff 75 d4             	pushl  -0x2c(%ebp)
  80064a:	50                   	push   %eax
  80064b:	51                   	push   %ecx
  80064c:	52                   	push   %edx
  80064d:	89 da                	mov    %ebx,%edx
  80064f:	89 f0                	mov    %esi,%eax
  800651:	e8 b6 fb ff ff       	call   80020c <printnum>
			break;
  800656:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  800659:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80065c:	47                   	inc    %edi
  80065d:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800661:	83 f8 25             	cmp    $0x25,%eax
  800664:	0f 84 97 fc ff ff    	je     800301 <vprintfmt+0x17>
			if (ch == '\0')
  80066a:	85 c0                	test   %eax,%eax
  80066c:	0f 84 89 00 00 00    	je     8006fb <vprintfmt+0x411>
			putch(ch, putdat);
  800672:	83 ec 08             	sub    $0x8,%esp
  800675:	53                   	push   %ebx
  800676:	50                   	push   %eax
  800677:	ff d6                	call   *%esi
  800679:	83 c4 10             	add    $0x10,%esp
  80067c:	eb de                	jmp    80065c <vprintfmt+0x372>
	if (lflag >= 2)
  80067e:	83 f9 01             	cmp    $0x1,%ecx
  800681:	7f 1b                	jg     80069e <vprintfmt+0x3b4>
	else if (lflag)
  800683:	85 c9                	test   %ecx,%ecx
  800685:	74 2c                	je     8006b3 <vprintfmt+0x3c9>
		return va_arg(*ap, unsigned long);
  800687:	8b 45 14             	mov    0x14(%ebp),%eax
  80068a:	8b 10                	mov    (%eax),%edx
  80068c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800691:	8d 40 04             	lea    0x4(%eax),%eax
  800694:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800697:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  80069c:	eb a1                	jmp    80063f <vprintfmt+0x355>
		return va_arg(*ap, unsigned long long);
  80069e:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a1:	8b 10                	mov    (%eax),%edx
  8006a3:	8b 48 04             	mov    0x4(%eax),%ecx
  8006a6:	8d 40 08             	lea    0x8(%eax),%eax
  8006a9:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006ac:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  8006b1:	eb 8c                	jmp    80063f <vprintfmt+0x355>
		return va_arg(*ap, unsigned int);
  8006b3:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b6:	8b 10                	mov    (%eax),%edx
  8006b8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006bd:	8d 40 04             	lea    0x4(%eax),%eax
  8006c0:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006c3:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  8006c8:	e9 72 ff ff ff       	jmp    80063f <vprintfmt+0x355>
			putch(ch, putdat);
  8006cd:	83 ec 08             	sub    $0x8,%esp
  8006d0:	53                   	push   %ebx
  8006d1:	6a 25                	push   $0x25
  8006d3:	ff d6                	call   *%esi
			break;
  8006d5:	83 c4 10             	add    $0x10,%esp
  8006d8:	e9 7c ff ff ff       	jmp    800659 <vprintfmt+0x36f>
			putch('%', putdat);
  8006dd:	83 ec 08             	sub    $0x8,%esp
  8006e0:	53                   	push   %ebx
  8006e1:	6a 25                	push   $0x25
  8006e3:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006e5:	83 c4 10             	add    $0x10,%esp
  8006e8:	89 f8                	mov    %edi,%eax
  8006ea:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8006ee:	74 03                	je     8006f3 <vprintfmt+0x409>
  8006f0:	48                   	dec    %eax
  8006f1:	eb f7                	jmp    8006ea <vprintfmt+0x400>
  8006f3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8006f6:	e9 5e ff ff ff       	jmp    800659 <vprintfmt+0x36f>
}
  8006fb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006fe:	5b                   	pop    %ebx
  8006ff:	5e                   	pop    %esi
  800700:	5f                   	pop    %edi
  800701:	5d                   	pop    %ebp
  800702:	c3                   	ret    

00800703 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800703:	55                   	push   %ebp
  800704:	89 e5                	mov    %esp,%ebp
  800706:	83 ec 18             	sub    $0x18,%esp
  800709:	8b 45 08             	mov    0x8(%ebp),%eax
  80070c:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80070f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800712:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800716:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800719:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800720:	85 c0                	test   %eax,%eax
  800722:	74 26                	je     80074a <vsnprintf+0x47>
  800724:	85 d2                	test   %edx,%edx
  800726:	7e 29                	jle    800751 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800728:	ff 75 14             	pushl  0x14(%ebp)
  80072b:	ff 75 10             	pushl  0x10(%ebp)
  80072e:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800731:	50                   	push   %eax
  800732:	68 b1 02 80 00       	push   $0x8002b1
  800737:	e8 ae fb ff ff       	call   8002ea <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80073c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80073f:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800742:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800745:	83 c4 10             	add    $0x10,%esp
}
  800748:	c9                   	leave  
  800749:	c3                   	ret    
		return -E_INVAL;
  80074a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80074f:	eb f7                	jmp    800748 <vsnprintf+0x45>
  800751:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800756:	eb f0                	jmp    800748 <vsnprintf+0x45>

00800758 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800758:	55                   	push   %ebp
  800759:	89 e5                	mov    %esp,%ebp
  80075b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80075e:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800761:	50                   	push   %eax
  800762:	ff 75 10             	pushl  0x10(%ebp)
  800765:	ff 75 0c             	pushl  0xc(%ebp)
  800768:	ff 75 08             	pushl  0x8(%ebp)
  80076b:	e8 93 ff ff ff       	call   800703 <vsnprintf>
	va_end(ap);

	return rc;
}
  800770:	c9                   	leave  
  800771:	c3                   	ret    

00800772 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800772:	55                   	push   %ebp
  800773:	89 e5                	mov    %esp,%ebp
  800775:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800778:	b8 00 00 00 00       	mov    $0x0,%eax
  80077d:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800781:	74 03                	je     800786 <strlen+0x14>
		n++;
  800783:	40                   	inc    %eax
  800784:	eb f7                	jmp    80077d <strlen+0xb>
	return n;
}
  800786:	5d                   	pop    %ebp
  800787:	c3                   	ret    

00800788 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800788:	55                   	push   %ebp
  800789:	89 e5                	mov    %esp,%ebp
  80078b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80078e:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800791:	b8 00 00 00 00       	mov    $0x0,%eax
  800796:	39 d0                	cmp    %edx,%eax
  800798:	74 0b                	je     8007a5 <strnlen+0x1d>
  80079a:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80079e:	74 03                	je     8007a3 <strnlen+0x1b>
		n++;
  8007a0:	40                   	inc    %eax
  8007a1:	eb f3                	jmp    800796 <strnlen+0xe>
  8007a3:	89 c2                	mov    %eax,%edx
	return n;
}
  8007a5:	89 d0                	mov    %edx,%eax
  8007a7:	5d                   	pop    %ebp
  8007a8:	c3                   	ret    

008007a9 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007a9:	55                   	push   %ebp
  8007aa:	89 e5                	mov    %esp,%ebp
  8007ac:	53                   	push   %ebx
  8007ad:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007b0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007b3:	b8 00 00 00 00       	mov    $0x0,%eax
  8007b8:	8a 14 03             	mov    (%ebx,%eax,1),%dl
  8007bb:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8007be:	40                   	inc    %eax
  8007bf:	84 d2                	test   %dl,%dl
  8007c1:	75 f5                	jne    8007b8 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8007c3:	89 c8                	mov    %ecx,%eax
  8007c5:	5b                   	pop    %ebx
  8007c6:	5d                   	pop    %ebp
  8007c7:	c3                   	ret    

008007c8 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007c8:	55                   	push   %ebp
  8007c9:	89 e5                	mov    %esp,%ebp
  8007cb:	53                   	push   %ebx
  8007cc:	83 ec 10             	sub    $0x10,%esp
  8007cf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007d2:	53                   	push   %ebx
  8007d3:	e8 9a ff ff ff       	call   800772 <strlen>
  8007d8:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  8007db:	ff 75 0c             	pushl  0xc(%ebp)
  8007de:	01 d8                	add    %ebx,%eax
  8007e0:	50                   	push   %eax
  8007e1:	e8 c3 ff ff ff       	call   8007a9 <strcpy>
	return dst;
}
  8007e6:	89 d8                	mov    %ebx,%eax
  8007e8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007eb:	c9                   	leave  
  8007ec:	c3                   	ret    

008007ed <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007ed:	55                   	push   %ebp
  8007ee:	89 e5                	mov    %esp,%ebp
  8007f0:	53                   	push   %ebx
  8007f1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007f4:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8007f7:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8007fd:	39 d8                	cmp    %ebx,%eax
  8007ff:	74 0e                	je     80080f <strncpy+0x22>
		*dst++ = *src;
  800801:	40                   	inc    %eax
  800802:	8a 0a                	mov    (%edx),%cl
  800804:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800807:	80 f9 01             	cmp    $0x1,%cl
  80080a:	83 da ff             	sbb    $0xffffffff,%edx
  80080d:	eb ee                	jmp    8007fd <strncpy+0x10>
	}
	return ret;
}
  80080f:	8b 45 08             	mov    0x8(%ebp),%eax
  800812:	5b                   	pop    %ebx
  800813:	5d                   	pop    %ebp
  800814:	c3                   	ret    

00800815 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800815:	55                   	push   %ebp
  800816:	89 e5                	mov    %esp,%ebp
  800818:	56                   	push   %esi
  800819:	53                   	push   %ebx
  80081a:	8b 75 08             	mov    0x8(%ebp),%esi
  80081d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800820:	8b 45 10             	mov    0x10(%ebp),%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800823:	85 c0                	test   %eax,%eax
  800825:	74 22                	je     800849 <strlcpy+0x34>
  800827:	8d 44 06 ff          	lea    -0x1(%esi,%eax,1),%eax
  80082b:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  80082d:	39 c2                	cmp    %eax,%edx
  80082f:	74 0f                	je     800840 <strlcpy+0x2b>
  800831:	8a 19                	mov    (%ecx),%bl
  800833:	84 db                	test   %bl,%bl
  800835:	74 07                	je     80083e <strlcpy+0x29>
			*dst++ = *src++;
  800837:	41                   	inc    %ecx
  800838:	42                   	inc    %edx
  800839:	88 5a ff             	mov    %bl,-0x1(%edx)
  80083c:	eb ef                	jmp    80082d <strlcpy+0x18>
  80083e:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800840:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800843:	29 f0                	sub    %esi,%eax
}
  800845:	5b                   	pop    %ebx
  800846:	5e                   	pop    %esi
  800847:	5d                   	pop    %ebp
  800848:	c3                   	ret    
  800849:	89 f0                	mov    %esi,%eax
  80084b:	eb f6                	jmp    800843 <strlcpy+0x2e>

0080084d <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80084d:	55                   	push   %ebp
  80084e:	89 e5                	mov    %esp,%ebp
  800850:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800853:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800856:	8a 01                	mov    (%ecx),%al
  800858:	84 c0                	test   %al,%al
  80085a:	74 08                	je     800864 <strcmp+0x17>
  80085c:	3a 02                	cmp    (%edx),%al
  80085e:	75 04                	jne    800864 <strcmp+0x17>
		p++, q++;
  800860:	41                   	inc    %ecx
  800861:	42                   	inc    %edx
  800862:	eb f2                	jmp    800856 <strcmp+0x9>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800864:	0f b6 c0             	movzbl %al,%eax
  800867:	0f b6 12             	movzbl (%edx),%edx
  80086a:	29 d0                	sub    %edx,%eax
}
  80086c:	5d                   	pop    %ebp
  80086d:	c3                   	ret    

0080086e <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80086e:	55                   	push   %ebp
  80086f:	89 e5                	mov    %esp,%ebp
  800871:	53                   	push   %ebx
  800872:	8b 45 08             	mov    0x8(%ebp),%eax
  800875:	8b 55 0c             	mov    0xc(%ebp),%edx
  800878:	89 c3                	mov    %eax,%ebx
  80087a:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80087d:	eb 02                	jmp    800881 <strncmp+0x13>
		n--, p++, q++;
  80087f:	40                   	inc    %eax
  800880:	42                   	inc    %edx
	while (n > 0 && *p && *p == *q)
  800881:	39 d8                	cmp    %ebx,%eax
  800883:	74 15                	je     80089a <strncmp+0x2c>
  800885:	8a 08                	mov    (%eax),%cl
  800887:	84 c9                	test   %cl,%cl
  800889:	74 04                	je     80088f <strncmp+0x21>
  80088b:	3a 0a                	cmp    (%edx),%cl
  80088d:	74 f0                	je     80087f <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80088f:	0f b6 00             	movzbl (%eax),%eax
  800892:	0f b6 12             	movzbl (%edx),%edx
  800895:	29 d0                	sub    %edx,%eax
}
  800897:	5b                   	pop    %ebx
  800898:	5d                   	pop    %ebp
  800899:	c3                   	ret    
		return 0;
  80089a:	b8 00 00 00 00       	mov    $0x0,%eax
  80089f:	eb f6                	jmp    800897 <strncmp+0x29>

008008a1 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008a1:	55                   	push   %ebp
  8008a2:	89 e5                	mov    %esp,%ebp
  8008a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a7:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8008aa:	8a 10                	mov    (%eax),%dl
  8008ac:	84 d2                	test   %dl,%dl
  8008ae:	74 07                	je     8008b7 <strchr+0x16>
		if (*s == c)
  8008b0:	38 ca                	cmp    %cl,%dl
  8008b2:	74 08                	je     8008bc <strchr+0x1b>
	for (; *s; s++)
  8008b4:	40                   	inc    %eax
  8008b5:	eb f3                	jmp    8008aa <strchr+0x9>
			return (char *) s;
	return 0;
  8008b7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008bc:	5d                   	pop    %ebp
  8008bd:	c3                   	ret    

008008be <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008be:	55                   	push   %ebp
  8008bf:	89 e5                	mov    %esp,%ebp
  8008c1:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c4:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8008c7:	8a 10                	mov    (%eax),%dl
  8008c9:	84 d2                	test   %dl,%dl
  8008cb:	74 07                	je     8008d4 <strfind+0x16>
		if (*s == c)
  8008cd:	38 ca                	cmp    %cl,%dl
  8008cf:	74 03                	je     8008d4 <strfind+0x16>
	for (; *s; s++)
  8008d1:	40                   	inc    %eax
  8008d2:	eb f3                	jmp    8008c7 <strfind+0x9>
			break;
	return (char *) s;
}
  8008d4:	5d                   	pop    %ebp
  8008d5:	c3                   	ret    

008008d6 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008d6:	55                   	push   %ebp
  8008d7:	89 e5                	mov    %esp,%ebp
  8008d9:	57                   	push   %edi
  8008da:	56                   	push   %esi
  8008db:	53                   	push   %ebx
  8008dc:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008df:	85 c9                	test   %ecx,%ecx
  8008e1:	74 36                	je     800919 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008e3:	89 c8                	mov    %ecx,%eax
  8008e5:	0b 45 08             	or     0x8(%ebp),%eax
  8008e8:	a8 03                	test   $0x3,%al
  8008ea:	75 24                	jne    800910 <memset+0x3a>
		c &= 0xFF;
  8008ec:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008f0:	89 d3                	mov    %edx,%ebx
  8008f2:	c1 e3 08             	shl    $0x8,%ebx
  8008f5:	89 d0                	mov    %edx,%eax
  8008f7:	c1 e0 18             	shl    $0x18,%eax
  8008fa:	89 d6                	mov    %edx,%esi
  8008fc:	c1 e6 10             	shl    $0x10,%esi
  8008ff:	09 f0                	or     %esi,%eax
  800901:	09 d0                	or     %edx,%eax
  800903:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800905:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800908:	8b 7d 08             	mov    0x8(%ebp),%edi
  80090b:	fc                   	cld    
  80090c:	f3 ab                	rep stos %eax,%es:(%edi)
  80090e:	eb 09                	jmp    800919 <memset+0x43>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800910:	8b 7d 08             	mov    0x8(%ebp),%edi
  800913:	8b 45 0c             	mov    0xc(%ebp),%eax
  800916:	fc                   	cld    
  800917:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800919:	8b 45 08             	mov    0x8(%ebp),%eax
  80091c:	5b                   	pop    %ebx
  80091d:	5e                   	pop    %esi
  80091e:	5f                   	pop    %edi
  80091f:	5d                   	pop    %ebp
  800920:	c3                   	ret    

00800921 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800921:	55                   	push   %ebp
  800922:	89 e5                	mov    %esp,%ebp
  800924:	57                   	push   %edi
  800925:	56                   	push   %esi
  800926:	8b 45 08             	mov    0x8(%ebp),%eax
  800929:	8b 75 0c             	mov    0xc(%ebp),%esi
  80092c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80092f:	39 c6                	cmp    %eax,%esi
  800931:	73 30                	jae    800963 <memmove+0x42>
  800933:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800936:	39 c2                	cmp    %eax,%edx
  800938:	76 29                	jbe    800963 <memmove+0x42>
		s += n;
		d += n;
  80093a:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80093d:	89 fe                	mov    %edi,%esi
  80093f:	09 ce                	or     %ecx,%esi
  800941:	09 d6                	or     %edx,%esi
  800943:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800949:	75 0e                	jne    800959 <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  80094b:	83 ef 04             	sub    $0x4,%edi
  80094e:	8d 72 fc             	lea    -0x4(%edx),%esi
  800951:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800954:	fd                   	std    
  800955:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800957:	eb 07                	jmp    800960 <memmove+0x3f>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800959:	4f                   	dec    %edi
  80095a:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  80095d:	fd                   	std    
  80095e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800960:	fc                   	cld    
  800961:	eb 1a                	jmp    80097d <memmove+0x5c>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800963:	89 c2                	mov    %eax,%edx
  800965:	09 ca                	or     %ecx,%edx
  800967:	09 f2                	or     %esi,%edx
  800969:	f6 c2 03             	test   $0x3,%dl
  80096c:	75 0a                	jne    800978 <memmove+0x57>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  80096e:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800971:	89 c7                	mov    %eax,%edi
  800973:	fc                   	cld    
  800974:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800976:	eb 05                	jmp    80097d <memmove+0x5c>
		else
			asm volatile("cld; rep movsb\n"
  800978:	89 c7                	mov    %eax,%edi
  80097a:	fc                   	cld    
  80097b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80097d:	5e                   	pop    %esi
  80097e:	5f                   	pop    %edi
  80097f:	5d                   	pop    %ebp
  800980:	c3                   	ret    

00800981 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800981:	55                   	push   %ebp
  800982:	89 e5                	mov    %esp,%ebp
  800984:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800987:	ff 75 10             	pushl  0x10(%ebp)
  80098a:	ff 75 0c             	pushl  0xc(%ebp)
  80098d:	ff 75 08             	pushl  0x8(%ebp)
  800990:	e8 8c ff ff ff       	call   800921 <memmove>
}
  800995:	c9                   	leave  
  800996:	c3                   	ret    

00800997 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800997:	55                   	push   %ebp
  800998:	89 e5                	mov    %esp,%ebp
  80099a:	56                   	push   %esi
  80099b:	53                   	push   %ebx
  80099c:	8b 45 08             	mov    0x8(%ebp),%eax
  80099f:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009a2:	89 c6                	mov    %eax,%esi
  8009a4:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009a7:	39 f0                	cmp    %esi,%eax
  8009a9:	74 16                	je     8009c1 <memcmp+0x2a>
		if (*s1 != *s2)
  8009ab:	8a 08                	mov    (%eax),%cl
  8009ad:	8a 1a                	mov    (%edx),%bl
  8009af:	38 d9                	cmp    %bl,%cl
  8009b1:	75 04                	jne    8009b7 <memcmp+0x20>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  8009b3:	40                   	inc    %eax
  8009b4:	42                   	inc    %edx
  8009b5:	eb f0                	jmp    8009a7 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  8009b7:	0f b6 c1             	movzbl %cl,%eax
  8009ba:	0f b6 db             	movzbl %bl,%ebx
  8009bd:	29 d8                	sub    %ebx,%eax
  8009bf:	eb 05                	jmp    8009c6 <memcmp+0x2f>
	}

	return 0;
  8009c1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009c6:	5b                   	pop    %ebx
  8009c7:	5e                   	pop    %esi
  8009c8:	5d                   	pop    %ebp
  8009c9:	c3                   	ret    

008009ca <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009ca:	55                   	push   %ebp
  8009cb:	89 e5                	mov    %esp,%ebp
  8009cd:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8009d3:	89 c2                	mov    %eax,%edx
  8009d5:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8009d8:	39 d0                	cmp    %edx,%eax
  8009da:	73 07                	jae    8009e3 <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009dc:	38 08                	cmp    %cl,(%eax)
  8009de:	74 03                	je     8009e3 <memfind+0x19>
	for (; s < ends; s++)
  8009e0:	40                   	inc    %eax
  8009e1:	eb f5                	jmp    8009d8 <memfind+0xe>
			break;
	return (void *) s;
}
  8009e3:	5d                   	pop    %ebp
  8009e4:	c3                   	ret    

008009e5 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009e5:	55                   	push   %ebp
  8009e6:	89 e5                	mov    %esp,%ebp
  8009e8:	57                   	push   %edi
  8009e9:	56                   	push   %esi
  8009ea:	53                   	push   %ebx
  8009eb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009ee:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009f1:	eb 01                	jmp    8009f4 <strtol+0xf>
		s++;
  8009f3:	41                   	inc    %ecx
	while (*s == ' ' || *s == '\t')
  8009f4:	8a 01                	mov    (%ecx),%al
  8009f6:	3c 20                	cmp    $0x20,%al
  8009f8:	74 f9                	je     8009f3 <strtol+0xe>
  8009fa:	3c 09                	cmp    $0x9,%al
  8009fc:	74 f5                	je     8009f3 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  8009fe:	3c 2b                	cmp    $0x2b,%al
  800a00:	74 24                	je     800a26 <strtol+0x41>
		s++;
	else if (*s == '-')
  800a02:	3c 2d                	cmp    $0x2d,%al
  800a04:	74 28                	je     800a2e <strtol+0x49>
	int neg = 0;
  800a06:	bf 00 00 00 00       	mov    $0x0,%edi
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a0b:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a11:	75 09                	jne    800a1c <strtol+0x37>
  800a13:	80 39 30             	cmpb   $0x30,(%ecx)
  800a16:	74 1e                	je     800a36 <strtol+0x51>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a18:	85 db                	test   %ebx,%ebx
  800a1a:	74 36                	je     800a52 <strtol+0x6d>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a1c:	b8 00 00 00 00       	mov    $0x0,%eax
  800a21:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800a24:	eb 45                	jmp    800a6b <strtol+0x86>
		s++;
  800a26:	41                   	inc    %ecx
	int neg = 0;
  800a27:	bf 00 00 00 00       	mov    $0x0,%edi
  800a2c:	eb dd                	jmp    800a0b <strtol+0x26>
		s++, neg = 1;
  800a2e:	41                   	inc    %ecx
  800a2f:	bf 01 00 00 00       	mov    $0x1,%edi
  800a34:	eb d5                	jmp    800a0b <strtol+0x26>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a36:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a3a:	74 0c                	je     800a48 <strtol+0x63>
	else if (base == 0 && s[0] == '0')
  800a3c:	85 db                	test   %ebx,%ebx
  800a3e:	75 dc                	jne    800a1c <strtol+0x37>
		s++, base = 8;
  800a40:	41                   	inc    %ecx
  800a41:	bb 08 00 00 00       	mov    $0x8,%ebx
  800a46:	eb d4                	jmp    800a1c <strtol+0x37>
		s += 2, base = 16;
  800a48:	83 c1 02             	add    $0x2,%ecx
  800a4b:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a50:	eb ca                	jmp    800a1c <strtol+0x37>
		base = 10;
  800a52:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800a57:	eb c3                	jmp    800a1c <strtol+0x37>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800a59:	0f be d2             	movsbl %dl,%edx
  800a5c:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800a5f:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a62:	7d 37                	jge    800a9b <strtol+0xb6>
			break;
		s++, val = (val * base) + dig;
  800a64:	41                   	inc    %ecx
  800a65:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a69:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800a6b:	8a 11                	mov    (%ecx),%dl
  800a6d:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a70:	89 f3                	mov    %esi,%ebx
  800a72:	80 fb 09             	cmp    $0x9,%bl
  800a75:	76 e2                	jbe    800a59 <strtol+0x74>
		else if (*s >= 'a' && *s <= 'z')
  800a77:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a7a:	89 f3                	mov    %esi,%ebx
  800a7c:	80 fb 19             	cmp    $0x19,%bl
  800a7f:	77 08                	ja     800a89 <strtol+0xa4>
			dig = *s - 'a' + 10;
  800a81:	0f be d2             	movsbl %dl,%edx
  800a84:	83 ea 57             	sub    $0x57,%edx
  800a87:	eb d6                	jmp    800a5f <strtol+0x7a>
		else if (*s >= 'A' && *s <= 'Z')
  800a89:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a8c:	89 f3                	mov    %esi,%ebx
  800a8e:	80 fb 19             	cmp    $0x19,%bl
  800a91:	77 08                	ja     800a9b <strtol+0xb6>
			dig = *s - 'A' + 10;
  800a93:	0f be d2             	movsbl %dl,%edx
  800a96:	83 ea 37             	sub    $0x37,%edx
  800a99:	eb c4                	jmp    800a5f <strtol+0x7a>
		// we don't properly detect overflow!
	}

	if (endptr)
  800a9b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a9f:	74 05                	je     800aa6 <strtol+0xc1>
		*endptr = (char *) s;
  800aa1:	8b 75 0c             	mov    0xc(%ebp),%esi
  800aa4:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800aa6:	85 ff                	test   %edi,%edi
  800aa8:	74 02                	je     800aac <strtol+0xc7>
  800aaa:	f7 d8                	neg    %eax
}
  800aac:	5b                   	pop    %ebx
  800aad:	5e                   	pop    %esi
  800aae:	5f                   	pop    %edi
  800aaf:	5d                   	pop    %ebp
  800ab0:	c3                   	ret    

00800ab1 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800ab1:	55                   	push   %ebp
  800ab2:	89 e5                	mov    %esp,%ebp
  800ab4:	57                   	push   %edi
  800ab5:	56                   	push   %esi
  800ab6:	53                   	push   %ebx
	asm volatile("int %1\n"
  800ab7:	b8 00 00 00 00       	mov    $0x0,%eax
  800abc:	8b 55 08             	mov    0x8(%ebp),%edx
  800abf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ac2:	89 c3                	mov    %eax,%ebx
  800ac4:	89 c7                	mov    %eax,%edi
  800ac6:	89 c6                	mov    %eax,%esi
  800ac8:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800aca:	5b                   	pop    %ebx
  800acb:	5e                   	pop    %esi
  800acc:	5f                   	pop    %edi
  800acd:	5d                   	pop    %ebp
  800ace:	c3                   	ret    

00800acf <sys_cgetc>:

int
sys_cgetc(void)
{
  800acf:	55                   	push   %ebp
  800ad0:	89 e5                	mov    %esp,%ebp
  800ad2:	57                   	push   %edi
  800ad3:	56                   	push   %esi
  800ad4:	53                   	push   %ebx
	asm volatile("int %1\n"
  800ad5:	ba 00 00 00 00       	mov    $0x0,%edx
  800ada:	b8 01 00 00 00       	mov    $0x1,%eax
  800adf:	89 d1                	mov    %edx,%ecx
  800ae1:	89 d3                	mov    %edx,%ebx
  800ae3:	89 d7                	mov    %edx,%edi
  800ae5:	89 d6                	mov    %edx,%esi
  800ae7:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800ae9:	5b                   	pop    %ebx
  800aea:	5e                   	pop    %esi
  800aeb:	5f                   	pop    %edi
  800aec:	5d                   	pop    %ebp
  800aed:	c3                   	ret    

00800aee <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800aee:	55                   	push   %ebp
  800aef:	89 e5                	mov    %esp,%ebp
  800af1:	57                   	push   %edi
  800af2:	56                   	push   %esi
  800af3:	53                   	push   %ebx
  800af4:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800af7:	b9 00 00 00 00       	mov    $0x0,%ecx
  800afc:	8b 55 08             	mov    0x8(%ebp),%edx
  800aff:	b8 03 00 00 00       	mov    $0x3,%eax
  800b04:	89 cb                	mov    %ecx,%ebx
  800b06:	89 cf                	mov    %ecx,%edi
  800b08:	89 ce                	mov    %ecx,%esi
  800b0a:	cd 30                	int    $0x30
	if(check && ret > 0)
  800b0c:	85 c0                	test   %eax,%eax
  800b0e:	7f 08                	jg     800b18 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b10:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b13:	5b                   	pop    %ebx
  800b14:	5e                   	pop    %esi
  800b15:	5f                   	pop    %edi
  800b16:	5d                   	pop    %ebp
  800b17:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800b18:	83 ec 0c             	sub    $0xc,%esp
  800b1b:	50                   	push   %eax
  800b1c:	6a 03                	push   $0x3
  800b1e:	68 68 10 80 00       	push   $0x801068
  800b23:	6a 23                	push   $0x23
  800b25:	68 85 10 80 00       	push   $0x801085
  800b2a:	e8 ef f5 ff ff       	call   80011e <_panic>

00800b2f <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b2f:	55                   	push   %ebp
  800b30:	89 e5                	mov    %esp,%ebp
  800b32:	57                   	push   %edi
  800b33:	56                   	push   %esi
  800b34:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b35:	ba 00 00 00 00       	mov    $0x0,%edx
  800b3a:	b8 02 00 00 00       	mov    $0x2,%eax
  800b3f:	89 d1                	mov    %edx,%ecx
  800b41:	89 d3                	mov    %edx,%ebx
  800b43:	89 d7                	mov    %edx,%edi
  800b45:	89 d6                	mov    %edx,%esi
  800b47:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b49:	5b                   	pop    %ebx
  800b4a:	5e                   	pop    %esi
  800b4b:	5f                   	pop    %edi
  800b4c:	5d                   	pop    %ebp
  800b4d:	c3                   	ret    
  800b4e:	66 90                	xchg   %ax,%ax

00800b50 <__udivdi3>:
  800b50:	55                   	push   %ebp
  800b51:	57                   	push   %edi
  800b52:	56                   	push   %esi
  800b53:	53                   	push   %ebx
  800b54:	83 ec 1c             	sub    $0x1c,%esp
  800b57:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800b5b:	8b 74 24 34          	mov    0x34(%esp),%esi
  800b5f:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800b63:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800b67:	85 d2                	test   %edx,%edx
  800b69:	75 19                	jne    800b84 <__udivdi3+0x34>
  800b6b:	39 f7                	cmp    %esi,%edi
  800b6d:	76 45                	jbe    800bb4 <__udivdi3+0x64>
  800b6f:	89 e8                	mov    %ebp,%eax
  800b71:	89 f2                	mov    %esi,%edx
  800b73:	f7 f7                	div    %edi
  800b75:	31 db                	xor    %ebx,%ebx
  800b77:	89 da                	mov    %ebx,%edx
  800b79:	83 c4 1c             	add    $0x1c,%esp
  800b7c:	5b                   	pop    %ebx
  800b7d:	5e                   	pop    %esi
  800b7e:	5f                   	pop    %edi
  800b7f:	5d                   	pop    %ebp
  800b80:	c3                   	ret    
  800b81:	8d 76 00             	lea    0x0(%esi),%esi
  800b84:	39 f2                	cmp    %esi,%edx
  800b86:	76 10                	jbe    800b98 <__udivdi3+0x48>
  800b88:	31 db                	xor    %ebx,%ebx
  800b8a:	31 c0                	xor    %eax,%eax
  800b8c:	89 da                	mov    %ebx,%edx
  800b8e:	83 c4 1c             	add    $0x1c,%esp
  800b91:	5b                   	pop    %ebx
  800b92:	5e                   	pop    %esi
  800b93:	5f                   	pop    %edi
  800b94:	5d                   	pop    %ebp
  800b95:	c3                   	ret    
  800b96:	66 90                	xchg   %ax,%ax
  800b98:	0f bd da             	bsr    %edx,%ebx
  800b9b:	83 f3 1f             	xor    $0x1f,%ebx
  800b9e:	75 3c                	jne    800bdc <__udivdi3+0x8c>
  800ba0:	39 f2                	cmp    %esi,%edx
  800ba2:	72 08                	jb     800bac <__udivdi3+0x5c>
  800ba4:	39 ef                	cmp    %ebp,%edi
  800ba6:	0f 87 9c 00 00 00    	ja     800c48 <__udivdi3+0xf8>
  800bac:	b8 01 00 00 00       	mov    $0x1,%eax
  800bb1:	eb d9                	jmp    800b8c <__udivdi3+0x3c>
  800bb3:	90                   	nop
  800bb4:	89 f9                	mov    %edi,%ecx
  800bb6:	85 ff                	test   %edi,%edi
  800bb8:	75 0b                	jne    800bc5 <__udivdi3+0x75>
  800bba:	b8 01 00 00 00       	mov    $0x1,%eax
  800bbf:	31 d2                	xor    %edx,%edx
  800bc1:	f7 f7                	div    %edi
  800bc3:	89 c1                	mov    %eax,%ecx
  800bc5:	31 d2                	xor    %edx,%edx
  800bc7:	89 f0                	mov    %esi,%eax
  800bc9:	f7 f1                	div    %ecx
  800bcb:	89 c3                	mov    %eax,%ebx
  800bcd:	89 e8                	mov    %ebp,%eax
  800bcf:	f7 f1                	div    %ecx
  800bd1:	89 da                	mov    %ebx,%edx
  800bd3:	83 c4 1c             	add    $0x1c,%esp
  800bd6:	5b                   	pop    %ebx
  800bd7:	5e                   	pop    %esi
  800bd8:	5f                   	pop    %edi
  800bd9:	5d                   	pop    %ebp
  800bda:	c3                   	ret    
  800bdb:	90                   	nop
  800bdc:	b8 20 00 00 00       	mov    $0x20,%eax
  800be1:	29 d8                	sub    %ebx,%eax
  800be3:	88 d9                	mov    %bl,%cl
  800be5:	d3 e2                	shl    %cl,%edx
  800be7:	89 54 24 08          	mov    %edx,0x8(%esp)
  800beb:	89 fa                	mov    %edi,%edx
  800bed:	88 c1                	mov    %al,%cl
  800bef:	d3 ea                	shr    %cl,%edx
  800bf1:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800bf5:	09 d1                	or     %edx,%ecx
  800bf7:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800bfb:	88 d9                	mov    %bl,%cl
  800bfd:	d3 e7                	shl    %cl,%edi
  800bff:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800c03:	89 f7                	mov    %esi,%edi
  800c05:	88 c1                	mov    %al,%cl
  800c07:	d3 ef                	shr    %cl,%edi
  800c09:	88 d9                	mov    %bl,%cl
  800c0b:	d3 e6                	shl    %cl,%esi
  800c0d:	89 ea                	mov    %ebp,%edx
  800c0f:	88 c1                	mov    %al,%cl
  800c11:	d3 ea                	shr    %cl,%edx
  800c13:	09 d6                	or     %edx,%esi
  800c15:	89 f0                	mov    %esi,%eax
  800c17:	89 fa                	mov    %edi,%edx
  800c19:	f7 74 24 08          	divl   0x8(%esp)
  800c1d:	89 d7                	mov    %edx,%edi
  800c1f:	89 c6                	mov    %eax,%esi
  800c21:	f7 64 24 0c          	mull   0xc(%esp)
  800c25:	39 d7                	cmp    %edx,%edi
  800c27:	72 13                	jb     800c3c <__udivdi3+0xec>
  800c29:	74 09                	je     800c34 <__udivdi3+0xe4>
  800c2b:	89 f0                	mov    %esi,%eax
  800c2d:	31 db                	xor    %ebx,%ebx
  800c2f:	e9 58 ff ff ff       	jmp    800b8c <__udivdi3+0x3c>
  800c34:	88 d9                	mov    %bl,%cl
  800c36:	d3 e5                	shl    %cl,%ebp
  800c38:	39 c5                	cmp    %eax,%ebp
  800c3a:	73 ef                	jae    800c2b <__udivdi3+0xdb>
  800c3c:	8d 46 ff             	lea    -0x1(%esi),%eax
  800c3f:	31 db                	xor    %ebx,%ebx
  800c41:	e9 46 ff ff ff       	jmp    800b8c <__udivdi3+0x3c>
  800c46:	66 90                	xchg   %ax,%ax
  800c48:	31 c0                	xor    %eax,%eax
  800c4a:	e9 3d ff ff ff       	jmp    800b8c <__udivdi3+0x3c>
  800c4f:	90                   	nop

00800c50 <__umoddi3>:
  800c50:	55                   	push   %ebp
  800c51:	57                   	push   %edi
  800c52:	56                   	push   %esi
  800c53:	53                   	push   %ebx
  800c54:	83 ec 1c             	sub    $0x1c,%esp
  800c57:	8b 74 24 30          	mov    0x30(%esp),%esi
  800c5b:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800c5f:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800c63:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  800c67:	85 c0                	test   %eax,%eax
  800c69:	75 19                	jne    800c84 <__umoddi3+0x34>
  800c6b:	39 df                	cmp    %ebx,%edi
  800c6d:	76 51                	jbe    800cc0 <__umoddi3+0x70>
  800c6f:	89 f0                	mov    %esi,%eax
  800c71:	89 da                	mov    %ebx,%edx
  800c73:	f7 f7                	div    %edi
  800c75:	89 d0                	mov    %edx,%eax
  800c77:	31 d2                	xor    %edx,%edx
  800c79:	83 c4 1c             	add    $0x1c,%esp
  800c7c:	5b                   	pop    %ebx
  800c7d:	5e                   	pop    %esi
  800c7e:	5f                   	pop    %edi
  800c7f:	5d                   	pop    %ebp
  800c80:	c3                   	ret    
  800c81:	8d 76 00             	lea    0x0(%esi),%esi
  800c84:	89 f2                	mov    %esi,%edx
  800c86:	39 d8                	cmp    %ebx,%eax
  800c88:	76 0e                	jbe    800c98 <__umoddi3+0x48>
  800c8a:	89 f0                	mov    %esi,%eax
  800c8c:	89 da                	mov    %ebx,%edx
  800c8e:	83 c4 1c             	add    $0x1c,%esp
  800c91:	5b                   	pop    %ebx
  800c92:	5e                   	pop    %esi
  800c93:	5f                   	pop    %edi
  800c94:	5d                   	pop    %ebp
  800c95:	c3                   	ret    
  800c96:	66 90                	xchg   %ax,%ax
  800c98:	0f bd e8             	bsr    %eax,%ebp
  800c9b:	83 f5 1f             	xor    $0x1f,%ebp
  800c9e:	75 44                	jne    800ce4 <__umoddi3+0x94>
  800ca0:	39 d8                	cmp    %ebx,%eax
  800ca2:	72 06                	jb     800caa <__umoddi3+0x5a>
  800ca4:	89 d9                	mov    %ebx,%ecx
  800ca6:	39 f7                	cmp    %esi,%edi
  800ca8:	77 08                	ja     800cb2 <__umoddi3+0x62>
  800caa:	29 fe                	sub    %edi,%esi
  800cac:	19 c3                	sbb    %eax,%ebx
  800cae:	89 f2                	mov    %esi,%edx
  800cb0:	89 d9                	mov    %ebx,%ecx
  800cb2:	89 d0                	mov    %edx,%eax
  800cb4:	89 ca                	mov    %ecx,%edx
  800cb6:	83 c4 1c             	add    $0x1c,%esp
  800cb9:	5b                   	pop    %ebx
  800cba:	5e                   	pop    %esi
  800cbb:	5f                   	pop    %edi
  800cbc:	5d                   	pop    %ebp
  800cbd:	c3                   	ret    
  800cbe:	66 90                	xchg   %ax,%ax
  800cc0:	89 fd                	mov    %edi,%ebp
  800cc2:	85 ff                	test   %edi,%edi
  800cc4:	75 0b                	jne    800cd1 <__umoddi3+0x81>
  800cc6:	b8 01 00 00 00       	mov    $0x1,%eax
  800ccb:	31 d2                	xor    %edx,%edx
  800ccd:	f7 f7                	div    %edi
  800ccf:	89 c5                	mov    %eax,%ebp
  800cd1:	89 d8                	mov    %ebx,%eax
  800cd3:	31 d2                	xor    %edx,%edx
  800cd5:	f7 f5                	div    %ebp
  800cd7:	89 f0                	mov    %esi,%eax
  800cd9:	f7 f5                	div    %ebp
  800cdb:	89 d0                	mov    %edx,%eax
  800cdd:	31 d2                	xor    %edx,%edx
  800cdf:	eb 98                	jmp    800c79 <__umoddi3+0x29>
  800ce1:	8d 76 00             	lea    0x0(%esi),%esi
  800ce4:	ba 20 00 00 00       	mov    $0x20,%edx
  800ce9:	29 ea                	sub    %ebp,%edx
  800ceb:	89 e9                	mov    %ebp,%ecx
  800ced:	d3 e0                	shl    %cl,%eax
  800cef:	89 44 24 08          	mov    %eax,0x8(%esp)
  800cf3:	89 f8                	mov    %edi,%eax
  800cf5:	89 54 24 04          	mov    %edx,0x4(%esp)
  800cf9:	88 d1                	mov    %dl,%cl
  800cfb:	d3 e8                	shr    %cl,%eax
  800cfd:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800d01:	09 c1                	or     %eax,%ecx
  800d03:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800d07:	89 e9                	mov    %ebp,%ecx
  800d09:	d3 e7                	shl    %cl,%edi
  800d0b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800d0f:	89 d8                	mov    %ebx,%eax
  800d11:	8b 54 24 04          	mov    0x4(%esp),%edx
  800d15:	88 d1                	mov    %dl,%cl
  800d17:	d3 e8                	shr    %cl,%eax
  800d19:	89 c7                	mov    %eax,%edi
  800d1b:	89 e9                	mov    %ebp,%ecx
  800d1d:	d3 e3                	shl    %cl,%ebx
  800d1f:	89 f0                	mov    %esi,%eax
  800d21:	88 d1                	mov    %dl,%cl
  800d23:	d3 e8                	shr    %cl,%eax
  800d25:	09 d8                	or     %ebx,%eax
  800d27:	89 e9                	mov    %ebp,%ecx
  800d29:	d3 e6                	shl    %cl,%esi
  800d2b:	89 f3                	mov    %esi,%ebx
  800d2d:	89 fa                	mov    %edi,%edx
  800d2f:	f7 74 24 08          	divl   0x8(%esp)
  800d33:	89 d1                	mov    %edx,%ecx
  800d35:	f7 64 24 0c          	mull   0xc(%esp)
  800d39:	89 c6                	mov    %eax,%esi
  800d3b:	89 d7                	mov    %edx,%edi
  800d3d:	39 d1                	cmp    %edx,%ecx
  800d3f:	72 27                	jb     800d68 <__umoddi3+0x118>
  800d41:	74 21                	je     800d64 <__umoddi3+0x114>
  800d43:	89 ca                	mov    %ecx,%edx
  800d45:	29 f3                	sub    %esi,%ebx
  800d47:	19 fa                	sbb    %edi,%edx
  800d49:	89 d0                	mov    %edx,%eax
  800d4b:	8a 4c 24 04          	mov    0x4(%esp),%cl
  800d4f:	d3 e0                	shl    %cl,%eax
  800d51:	89 e9                	mov    %ebp,%ecx
  800d53:	d3 eb                	shr    %cl,%ebx
  800d55:	09 d8                	or     %ebx,%eax
  800d57:	d3 ea                	shr    %cl,%edx
  800d59:	83 c4 1c             	add    $0x1c,%esp
  800d5c:	5b                   	pop    %ebx
  800d5d:	5e                   	pop    %esi
  800d5e:	5f                   	pop    %edi
  800d5f:	5d                   	pop    %ebp
  800d60:	c3                   	ret    
  800d61:	8d 76 00             	lea    0x0(%esi),%esi
  800d64:	39 c3                	cmp    %eax,%ebx
  800d66:	73 db                	jae    800d43 <__umoddi3+0xf3>
  800d68:	2b 44 24 0c          	sub    0xc(%esp),%eax
  800d6c:	1b 54 24 08          	sbb    0x8(%esp),%edx
  800d70:	89 d7                	mov    %edx,%edi
  800d72:	89 c6                	mov    %eax,%esi
  800d74:	eb cd                	jmp    800d43 <__umoddi3+0xf3>
