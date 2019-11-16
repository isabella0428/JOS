
obj/user/hello:     file format elf32-i386


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
  80002c:	e8 2d 00 00 00       	call   80005e <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
// hello, world
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 14             	sub    $0x14,%esp
	cprintf("hello, world\n");
  800039:	68 00 0d 80 00       	push   $0x800d00
  80003e:	e8 f7 00 00 00       	call   80013a <cprintf>
	cprintf("i am environment %08x\n", thisenv->env_id);
  800043:	a1 04 10 80 00       	mov    0x801004,%eax
  800048:	8b 40 48             	mov    0x48(%eax),%eax
  80004b:	83 c4 08             	add    $0x8,%esp
  80004e:	50                   	push   %eax
  80004f:	68 0e 0d 80 00       	push   $0x800d0e
  800054:	e8 e1 00 00 00       	call   80013a <cprintf>
}
  800059:	83 c4 10             	add    $0x10,%esp
  80005c:	c9                   	leave  
  80005d:	c3                   	ret    

0080005e <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80005e:	55                   	push   %ebp
  80005f:	89 e5                	mov    %esp,%ebp
  800061:	83 ec 08             	sub    $0x8,%esp
  800064:	8b 45 08             	mov    0x8(%ebp),%eax
  800067:	8b 55 0c             	mov    0xc(%ebp),%edx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  80006a:	c7 05 04 10 80 00 00 	movl   $0x0,0x801004
  800071:	00 00 00 

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800074:	85 c0                	test   %eax,%eax
  800076:	7e 08                	jle    800080 <libmain+0x22>
		binaryname = argv[0];
  800078:	8b 0a                	mov    (%edx),%ecx
  80007a:	89 0d 00 10 80 00    	mov    %ecx,0x801000

	// call user main routine
	umain(argc, argv);
  800080:	83 ec 08             	sub    $0x8,%esp
  800083:	52                   	push   %edx
  800084:	50                   	push   %eax
  800085:	e8 a9 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80008a:	e8 05 00 00 00       	call   800094 <exit>
}
  80008f:	83 c4 10             	add    $0x10,%esp
  800092:	c9                   	leave  
  800093:	c3                   	ret    

00800094 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800094:	55                   	push   %ebp
  800095:	89 e5                	mov    %esp,%ebp
  800097:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  80009a:	6a 00                	push   $0x0
  80009c:	e8 8f 09 00 00       	call   800a30 <sys_env_destroy>
}
  8000a1:	83 c4 10             	add    $0x10,%esp
  8000a4:	c9                   	leave  
  8000a5:	c3                   	ret    

008000a6 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000a6:	55                   	push   %ebp
  8000a7:	89 e5                	mov    %esp,%ebp
  8000a9:	53                   	push   %ebx
  8000aa:	83 ec 04             	sub    $0x4,%esp
  8000ad:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000b0:	8b 13                	mov    (%ebx),%edx
  8000b2:	8d 42 01             	lea    0x1(%edx),%eax
  8000b5:	89 03                	mov    %eax,(%ebx)
  8000b7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000ba:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000be:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000c3:	74 08                	je     8000cd <putch+0x27>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8000c5:	ff 43 04             	incl   0x4(%ebx)
}
  8000c8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000cb:	c9                   	leave  
  8000cc:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8000cd:	83 ec 08             	sub    $0x8,%esp
  8000d0:	68 ff 00 00 00       	push   $0xff
  8000d5:	8d 43 08             	lea    0x8(%ebx),%eax
  8000d8:	50                   	push   %eax
  8000d9:	e8 15 09 00 00       	call   8009f3 <sys_cputs>
		b->idx = 0;
  8000de:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8000e4:	83 c4 10             	add    $0x10,%esp
  8000e7:	eb dc                	jmp    8000c5 <putch+0x1f>

008000e9 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8000e9:	55                   	push   %ebp
  8000ea:	89 e5                	mov    %esp,%ebp
  8000ec:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8000f2:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8000f9:	00 00 00 
	b.cnt = 0;
  8000fc:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800103:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800106:	ff 75 0c             	pushl  0xc(%ebp)
  800109:	ff 75 08             	pushl  0x8(%ebp)
  80010c:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800112:	50                   	push   %eax
  800113:	68 a6 00 80 00       	push   $0x8000a6
  800118:	e8 0f 01 00 00       	call   80022c <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80011d:	83 c4 08             	add    $0x8,%esp
  800120:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800126:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80012c:	50                   	push   %eax
  80012d:	e8 c1 08 00 00       	call   8009f3 <sys_cputs>

	return b.cnt;
}
  800132:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800138:	c9                   	leave  
  800139:	c3                   	ret    

0080013a <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80013a:	55                   	push   %ebp
  80013b:	89 e5                	mov    %esp,%ebp
  80013d:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800140:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800143:	50                   	push   %eax
  800144:	ff 75 08             	pushl  0x8(%ebp)
  800147:	e8 9d ff ff ff       	call   8000e9 <vcprintf>
	va_end(ap);

	return cnt;
}
  80014c:	c9                   	leave  
  80014d:	c3                   	ret    

0080014e <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80014e:	55                   	push   %ebp
  80014f:	89 e5                	mov    %esp,%ebp
  800151:	57                   	push   %edi
  800152:	56                   	push   %esi
  800153:	53                   	push   %ebx
  800154:	83 ec 1c             	sub    $0x1c,%esp
  800157:	89 c7                	mov    %eax,%edi
  800159:	89 d6                	mov    %edx,%esi
  80015b:	8b 45 08             	mov    0x8(%ebp),%eax
  80015e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800161:	89 d1                	mov    %edx,%ecx
  800163:	89 c2                	mov    %eax,%edx
  800165:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800168:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80016b:	8b 45 10             	mov    0x10(%ebp),%eax
  80016e:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800171:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800174:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80017b:	39 c2                	cmp    %eax,%edx
  80017d:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  800180:	72 3c                	jb     8001be <printnum+0x70>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800182:	83 ec 0c             	sub    $0xc,%esp
  800185:	ff 75 18             	pushl  0x18(%ebp)
  800188:	4b                   	dec    %ebx
  800189:	53                   	push   %ebx
  80018a:	50                   	push   %eax
  80018b:	83 ec 08             	sub    $0x8,%esp
  80018e:	ff 75 e4             	pushl  -0x1c(%ebp)
  800191:	ff 75 e0             	pushl  -0x20(%ebp)
  800194:	ff 75 dc             	pushl  -0x24(%ebp)
  800197:	ff 75 d8             	pushl  -0x28(%ebp)
  80019a:	e8 39 09 00 00       	call   800ad8 <__udivdi3>
  80019f:	83 c4 18             	add    $0x18,%esp
  8001a2:	52                   	push   %edx
  8001a3:	50                   	push   %eax
  8001a4:	89 f2                	mov    %esi,%edx
  8001a6:	89 f8                	mov    %edi,%eax
  8001a8:	e8 a1 ff ff ff       	call   80014e <printnum>
  8001ad:	83 c4 20             	add    $0x20,%esp
  8001b0:	eb 11                	jmp    8001c3 <printnum+0x75>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001b2:	83 ec 08             	sub    $0x8,%esp
  8001b5:	56                   	push   %esi
  8001b6:	ff 75 18             	pushl  0x18(%ebp)
  8001b9:	ff d7                	call   *%edi
  8001bb:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8001be:	4b                   	dec    %ebx
  8001bf:	85 db                	test   %ebx,%ebx
  8001c1:	7f ef                	jg     8001b2 <printnum+0x64>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8001c3:	83 ec 08             	sub    $0x8,%esp
  8001c6:	56                   	push   %esi
  8001c7:	83 ec 04             	sub    $0x4,%esp
  8001ca:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001cd:	ff 75 e0             	pushl  -0x20(%ebp)
  8001d0:	ff 75 dc             	pushl  -0x24(%ebp)
  8001d3:	ff 75 d8             	pushl  -0x28(%ebp)
  8001d6:	e8 fd 09 00 00       	call   800bd8 <__umoddi3>
  8001db:	83 c4 14             	add    $0x14,%esp
  8001de:	0f be 80 2f 0d 80 00 	movsbl 0x800d2f(%eax),%eax
  8001e5:	50                   	push   %eax
  8001e6:	ff d7                	call   *%edi
}
  8001e8:	83 c4 10             	add    $0x10,%esp
  8001eb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001ee:	5b                   	pop    %ebx
  8001ef:	5e                   	pop    %esi
  8001f0:	5f                   	pop    %edi
  8001f1:	5d                   	pop    %ebp
  8001f2:	c3                   	ret    

008001f3 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8001f3:	55                   	push   %ebp
  8001f4:	89 e5                	mov    %esp,%ebp
  8001f6:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8001f9:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8001fc:	8b 10                	mov    (%eax),%edx
  8001fe:	3b 50 04             	cmp    0x4(%eax),%edx
  800201:	73 0a                	jae    80020d <sprintputch+0x1a>
		*b->buf++ = ch;
  800203:	8d 4a 01             	lea    0x1(%edx),%ecx
  800206:	89 08                	mov    %ecx,(%eax)
  800208:	8b 45 08             	mov    0x8(%ebp),%eax
  80020b:	88 02                	mov    %al,(%edx)
}
  80020d:	5d                   	pop    %ebp
  80020e:	c3                   	ret    

0080020f <printfmt>:
{
  80020f:	55                   	push   %ebp
  800210:	89 e5                	mov    %esp,%ebp
  800212:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800215:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800218:	50                   	push   %eax
  800219:	ff 75 10             	pushl  0x10(%ebp)
  80021c:	ff 75 0c             	pushl  0xc(%ebp)
  80021f:	ff 75 08             	pushl  0x8(%ebp)
  800222:	e8 05 00 00 00       	call   80022c <vprintfmt>
}
  800227:	83 c4 10             	add    $0x10,%esp
  80022a:	c9                   	leave  
  80022b:	c3                   	ret    

0080022c <vprintfmt>:
{
  80022c:	55                   	push   %ebp
  80022d:	89 e5                	mov    %esp,%ebp
  80022f:	57                   	push   %edi
  800230:	56                   	push   %esi
  800231:	53                   	push   %ebx
  800232:	83 ec 3c             	sub    $0x3c,%esp
  800235:	8b 75 08             	mov    0x8(%ebp),%esi
  800238:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80023b:	8b 7d 10             	mov    0x10(%ebp),%edi
  80023e:	e9 5b 03 00 00       	jmp    80059e <vprintfmt+0x372>
		padc = ' ';
  800243:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  800247:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
		precision = -1;
  80024e:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  800255:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		lflag = 0;
  80025c:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800261:	8d 47 01             	lea    0x1(%edi),%eax
  800264:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800267:	8a 17                	mov    (%edi),%dl
  800269:	8d 42 dd             	lea    -0x23(%edx),%eax
  80026c:	3c 55                	cmp    $0x55,%al
  80026e:	0f 87 ab 03 00 00    	ja     80061f <vprintfmt+0x3f3>
  800274:	0f b6 c0             	movzbl %al,%eax
  800277:	ff 24 85 bc 0d 80 00 	jmp    *0x800dbc(,%eax,4)
  80027e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800281:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  800285:	eb da                	jmp    800261 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  800287:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80028a:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  80028e:	eb d1                	jmp    800261 <vprintfmt+0x35>
  800290:	0f b6 d2             	movzbl %dl,%edx
  800293:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800296:	b8 00 00 00 00       	mov    $0x0,%eax
  80029b:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  80029e:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8002a1:	01 c0                	add    %eax,%eax
  8002a3:	8d 44 02 d0          	lea    -0x30(%edx,%eax,1),%eax
				ch = *fmt;
  8002a7:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8002aa:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8002ad:	83 f9 09             	cmp    $0x9,%ecx
  8002b0:	77 52                	ja     800304 <vprintfmt+0xd8>
			for (precision = 0; ; ++fmt) {
  8002b2:	47                   	inc    %edi
				precision = precision * 10 + ch - '0';
  8002b3:	eb e9                	jmp    80029e <vprintfmt+0x72>
			precision = va_arg(ap, int);
  8002b5:	8b 45 14             	mov    0x14(%ebp),%eax
  8002b8:	8b 00                	mov    (%eax),%eax
  8002ba:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002bd:	8b 45 14             	mov    0x14(%ebp),%eax
  8002c0:	8d 40 04             	lea    0x4(%eax),%eax
  8002c3:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8002c6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8002c9:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8002cd:	79 92                	jns    800261 <vprintfmt+0x35>
				width = precision, precision = -1;
  8002cf:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8002d2:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8002d5:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8002dc:	eb 83                	jmp    800261 <vprintfmt+0x35>
  8002de:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8002e2:	78 08                	js     8002ec <vprintfmt+0xc0>
		switch (ch = *(unsigned char *) fmt++) {
  8002e4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8002e7:	e9 75 ff ff ff       	jmp    800261 <vprintfmt+0x35>
  8002ec:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  8002f3:	eb ef                	jmp    8002e4 <vprintfmt+0xb8>
		switch (ch = *(unsigned char *) fmt++) {
  8002f5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8002f8:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  8002ff:	e9 5d ff ff ff       	jmp    800261 <vprintfmt+0x35>
  800304:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800307:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80030a:	eb bd                	jmp    8002c9 <vprintfmt+0x9d>
			lflag++;
  80030c:	41                   	inc    %ecx
		switch (ch = *(unsigned char *) fmt++) {
  80030d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800310:	e9 4c ff ff ff       	jmp    800261 <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
  800315:	8b 45 14             	mov    0x14(%ebp),%eax
  800318:	8d 78 04             	lea    0x4(%eax),%edi
  80031b:	83 ec 08             	sub    $0x8,%esp
  80031e:	53                   	push   %ebx
  80031f:	ff 30                	pushl  (%eax)
  800321:	ff d6                	call   *%esi
			break;
  800323:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800326:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800329:	e9 6d 02 00 00       	jmp    80059b <vprintfmt+0x36f>
			err = va_arg(ap, int);
  80032e:	8b 45 14             	mov    0x14(%ebp),%eax
  800331:	8d 78 04             	lea    0x4(%eax),%edi
  800334:	8b 00                	mov    (%eax),%eax
  800336:	85 c0                	test   %eax,%eax
  800338:	78 2a                	js     800364 <vprintfmt+0x138>
  80033a:	89 c2                	mov    %eax,%edx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80033c:	83 f8 06             	cmp    $0x6,%eax
  80033f:	7f 27                	jg     800368 <vprintfmt+0x13c>
  800341:	8b 04 85 14 0f 80 00 	mov    0x800f14(,%eax,4),%eax
  800348:	85 c0                	test   %eax,%eax
  80034a:	74 1c                	je     800368 <vprintfmt+0x13c>
				printfmt(putch, putdat, "%s", p);
  80034c:	50                   	push   %eax
  80034d:	68 50 0d 80 00       	push   $0x800d50
  800352:	53                   	push   %ebx
  800353:	56                   	push   %esi
  800354:	e8 b6 fe ff ff       	call   80020f <printfmt>
  800359:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80035c:	89 7d 14             	mov    %edi,0x14(%ebp)
  80035f:	e9 37 02 00 00       	jmp    80059b <vprintfmt+0x36f>
  800364:	f7 d8                	neg    %eax
  800366:	eb d2                	jmp    80033a <vprintfmt+0x10e>
				printfmt(putch, putdat, "error %d", err);
  800368:	52                   	push   %edx
  800369:	68 47 0d 80 00       	push   $0x800d47
  80036e:	53                   	push   %ebx
  80036f:	56                   	push   %esi
  800370:	e8 9a fe ff ff       	call   80020f <printfmt>
  800375:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800378:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  80037b:	e9 1b 02 00 00       	jmp    80059b <vprintfmt+0x36f>
			if ((p = va_arg(ap, char *)) == NULL)
  800380:	8b 45 14             	mov    0x14(%ebp),%eax
  800383:	83 c0 04             	add    $0x4,%eax
  800386:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800389:	8b 45 14             	mov    0x14(%ebp),%eax
  80038c:	8b 00                	mov    (%eax),%eax
  80038e:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800391:	85 c0                	test   %eax,%eax
  800393:	74 19                	je     8003ae <vprintfmt+0x182>
			if (width > 0 && padc != '-')
  800395:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800399:	7e 06                	jle    8003a1 <vprintfmt+0x175>
  80039b:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  80039f:	75 16                	jne    8003b7 <vprintfmt+0x18b>
				for (width -= strnlen(p, precision); width > 0; width--)
  8003a1:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8003a4:	89 c7                	mov    %eax,%edi
  8003a6:	03 45 d4             	add    -0x2c(%ebp),%eax
  8003a9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8003ac:	eb 62                	jmp    800410 <vprintfmt+0x1e4>
				p = "(null)";
  8003ae:	c7 45 cc 40 0d 80 00 	movl   $0x800d40,-0x34(%ebp)
  8003b5:	eb de                	jmp    800395 <vprintfmt+0x169>
				for (width -= strnlen(p, precision); width > 0; width--)
  8003b7:	83 ec 08             	sub    $0x8,%esp
  8003ba:	ff 75 d8             	pushl  -0x28(%ebp)
  8003bd:	ff 75 cc             	pushl  -0x34(%ebp)
  8003c0:	e8 05 03 00 00       	call   8006ca <strnlen>
  8003c5:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8003c8:	29 c2                	sub    %eax,%edx
  8003ca:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  8003cd:	83 c4 10             	add    $0x10,%esp
  8003d0:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  8003d2:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8003d6:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8003d9:	eb 0d                	jmp    8003e8 <vprintfmt+0x1bc>
					putch(padc, putdat);
  8003db:	83 ec 08             	sub    $0x8,%esp
  8003de:	53                   	push   %ebx
  8003df:	ff 75 d4             	pushl  -0x2c(%ebp)
  8003e2:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8003e4:	4f                   	dec    %edi
  8003e5:	83 c4 10             	add    $0x10,%esp
  8003e8:	85 ff                	test   %edi,%edi
  8003ea:	7f ef                	jg     8003db <vprintfmt+0x1af>
  8003ec:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8003ef:	89 d0                	mov    %edx,%eax
  8003f1:	85 d2                	test   %edx,%edx
  8003f3:	78 0a                	js     8003ff <vprintfmt+0x1d3>
  8003f5:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8003f8:	29 c2                	sub    %eax,%edx
  8003fa:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8003fd:	eb a2                	jmp    8003a1 <vprintfmt+0x175>
  8003ff:	b8 00 00 00 00       	mov    $0x0,%eax
  800404:	eb ef                	jmp    8003f5 <vprintfmt+0x1c9>
					putch(ch, putdat);
  800406:	83 ec 08             	sub    $0x8,%esp
  800409:	53                   	push   %ebx
  80040a:	52                   	push   %edx
  80040b:	ff d6                	call   *%esi
  80040d:	83 c4 10             	add    $0x10,%esp
  800410:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  800413:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800415:	47                   	inc    %edi
  800416:	8a 47 ff             	mov    -0x1(%edi),%al
  800419:	0f be d0             	movsbl %al,%edx
  80041c:	85 d2                	test   %edx,%edx
  80041e:	74 48                	je     800468 <vprintfmt+0x23c>
  800420:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800424:	78 05                	js     80042b <vprintfmt+0x1ff>
  800426:	ff 4d d8             	decl   -0x28(%ebp)
  800429:	78 1e                	js     800449 <vprintfmt+0x21d>
				if (altflag && (ch < ' ' || ch > '~'))
  80042b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80042f:	74 d5                	je     800406 <vprintfmt+0x1da>
  800431:	0f be c0             	movsbl %al,%eax
  800434:	83 e8 20             	sub    $0x20,%eax
  800437:	83 f8 5e             	cmp    $0x5e,%eax
  80043a:	76 ca                	jbe    800406 <vprintfmt+0x1da>
					putch('?', putdat);
  80043c:	83 ec 08             	sub    $0x8,%esp
  80043f:	53                   	push   %ebx
  800440:	6a 3f                	push   $0x3f
  800442:	ff d6                	call   *%esi
  800444:	83 c4 10             	add    $0x10,%esp
  800447:	eb c7                	jmp    800410 <vprintfmt+0x1e4>
  800449:	89 cf                	mov    %ecx,%edi
  80044b:	eb 0c                	jmp    800459 <vprintfmt+0x22d>
				putch(' ', putdat);
  80044d:	83 ec 08             	sub    $0x8,%esp
  800450:	53                   	push   %ebx
  800451:	6a 20                	push   $0x20
  800453:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800455:	4f                   	dec    %edi
  800456:	83 c4 10             	add    $0x10,%esp
  800459:	85 ff                	test   %edi,%edi
  80045b:	7f f0                	jg     80044d <vprintfmt+0x221>
			if ((p = va_arg(ap, char *)) == NULL)
  80045d:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800460:	89 45 14             	mov    %eax,0x14(%ebp)
  800463:	e9 33 01 00 00       	jmp    80059b <vprintfmt+0x36f>
  800468:	89 cf                	mov    %ecx,%edi
  80046a:	eb ed                	jmp    800459 <vprintfmt+0x22d>
	if (lflag >= 2)
  80046c:	83 f9 01             	cmp    $0x1,%ecx
  80046f:	7f 1b                	jg     80048c <vprintfmt+0x260>
	else if (lflag)
  800471:	85 c9                	test   %ecx,%ecx
  800473:	74 42                	je     8004b7 <vprintfmt+0x28b>
		return va_arg(*ap, long);
  800475:	8b 45 14             	mov    0x14(%ebp),%eax
  800478:	8b 00                	mov    (%eax),%eax
  80047a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80047d:	99                   	cltd   
  80047e:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800481:	8b 45 14             	mov    0x14(%ebp),%eax
  800484:	8d 40 04             	lea    0x4(%eax),%eax
  800487:	89 45 14             	mov    %eax,0x14(%ebp)
  80048a:	eb 17                	jmp    8004a3 <vprintfmt+0x277>
		return va_arg(*ap, long long);
  80048c:	8b 45 14             	mov    0x14(%ebp),%eax
  80048f:	8b 50 04             	mov    0x4(%eax),%edx
  800492:	8b 00                	mov    (%eax),%eax
  800494:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800497:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80049a:	8b 45 14             	mov    0x14(%ebp),%eax
  80049d:	8d 40 08             	lea    0x8(%eax),%eax
  8004a0:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  8004a3:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8004a6:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8004a9:	85 c9                	test   %ecx,%ecx
  8004ab:	78 21                	js     8004ce <vprintfmt+0x2a2>
			base = 10;
  8004ad:	b8 0a 00 00 00       	mov    $0xa,%eax
  8004b2:	e9 ca 00 00 00       	jmp    800581 <vprintfmt+0x355>
		return va_arg(*ap, int);
  8004b7:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ba:	8b 00                	mov    (%eax),%eax
  8004bc:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004bf:	99                   	cltd   
  8004c0:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8004c3:	8b 45 14             	mov    0x14(%ebp),%eax
  8004c6:	8d 40 04             	lea    0x4(%eax),%eax
  8004c9:	89 45 14             	mov    %eax,0x14(%ebp)
  8004cc:	eb d5                	jmp    8004a3 <vprintfmt+0x277>
				putch('-', putdat);
  8004ce:	83 ec 08             	sub    $0x8,%esp
  8004d1:	53                   	push   %ebx
  8004d2:	6a 2d                	push   $0x2d
  8004d4:	ff d6                	call   *%esi
				num = -(long long) num;
  8004d6:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8004d9:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8004dc:	f7 da                	neg    %edx
  8004de:	83 d1 00             	adc    $0x0,%ecx
  8004e1:	f7 d9                	neg    %ecx
  8004e3:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8004e6:	b8 0a 00 00 00       	mov    $0xa,%eax
  8004eb:	e9 91 00 00 00       	jmp    800581 <vprintfmt+0x355>
	if (lflag >= 2)
  8004f0:	83 f9 01             	cmp    $0x1,%ecx
  8004f3:	7f 1b                	jg     800510 <vprintfmt+0x2e4>
	else if (lflag)
  8004f5:	85 c9                	test   %ecx,%ecx
  8004f7:	74 2c                	je     800525 <vprintfmt+0x2f9>
		return va_arg(*ap, unsigned long);
  8004f9:	8b 45 14             	mov    0x14(%ebp),%eax
  8004fc:	8b 10                	mov    (%eax),%edx
  8004fe:	b9 00 00 00 00       	mov    $0x0,%ecx
  800503:	8d 40 04             	lea    0x4(%eax),%eax
  800506:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800509:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  80050e:	eb 71                	jmp    800581 <vprintfmt+0x355>
		return va_arg(*ap, unsigned long long);
  800510:	8b 45 14             	mov    0x14(%ebp),%eax
  800513:	8b 10                	mov    (%eax),%edx
  800515:	8b 48 04             	mov    0x4(%eax),%ecx
  800518:	8d 40 08             	lea    0x8(%eax),%eax
  80051b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80051e:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  800523:	eb 5c                	jmp    800581 <vprintfmt+0x355>
		return va_arg(*ap, unsigned int);
  800525:	8b 45 14             	mov    0x14(%ebp),%eax
  800528:	8b 10                	mov    (%eax),%edx
  80052a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80052f:	8d 40 04             	lea    0x4(%eax),%eax
  800532:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800535:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  80053a:	eb 45                	jmp    800581 <vprintfmt+0x355>
			putch('X', putdat);
  80053c:	83 ec 08             	sub    $0x8,%esp
  80053f:	53                   	push   %ebx
  800540:	6a 58                	push   $0x58
  800542:	ff d6                	call   *%esi
			putch('X', putdat);
  800544:	83 c4 08             	add    $0x8,%esp
  800547:	53                   	push   %ebx
  800548:	6a 58                	push   $0x58
  80054a:	ff d6                	call   *%esi
			putch('X', putdat);
  80054c:	83 c4 08             	add    $0x8,%esp
  80054f:	53                   	push   %ebx
  800550:	6a 58                	push   $0x58
  800552:	ff d6                	call   *%esi
			break;
  800554:	83 c4 10             	add    $0x10,%esp
  800557:	eb 42                	jmp    80059b <vprintfmt+0x36f>
			putch('0', putdat);
  800559:	83 ec 08             	sub    $0x8,%esp
  80055c:	53                   	push   %ebx
  80055d:	6a 30                	push   $0x30
  80055f:	ff d6                	call   *%esi
			putch('x', putdat);
  800561:	83 c4 08             	add    $0x8,%esp
  800564:	53                   	push   %ebx
  800565:	6a 78                	push   $0x78
  800567:	ff d6                	call   *%esi
			num = (unsigned long long)
  800569:	8b 45 14             	mov    0x14(%ebp),%eax
  80056c:	8b 10                	mov    (%eax),%edx
  80056e:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800573:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800576:	8d 40 04             	lea    0x4(%eax),%eax
  800579:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80057c:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  800581:	83 ec 0c             	sub    $0xc,%esp
  800584:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  800588:	57                   	push   %edi
  800589:	ff 75 d4             	pushl  -0x2c(%ebp)
  80058c:	50                   	push   %eax
  80058d:	51                   	push   %ecx
  80058e:	52                   	push   %edx
  80058f:	89 da                	mov    %ebx,%edx
  800591:	89 f0                	mov    %esi,%eax
  800593:	e8 b6 fb ff ff       	call   80014e <printnum>
			break;
  800598:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  80059b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80059e:	47                   	inc    %edi
  80059f:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8005a3:	83 f8 25             	cmp    $0x25,%eax
  8005a6:	0f 84 97 fc ff ff    	je     800243 <vprintfmt+0x17>
			if (ch == '\0')
  8005ac:	85 c0                	test   %eax,%eax
  8005ae:	0f 84 89 00 00 00    	je     80063d <vprintfmt+0x411>
			putch(ch, putdat);
  8005b4:	83 ec 08             	sub    $0x8,%esp
  8005b7:	53                   	push   %ebx
  8005b8:	50                   	push   %eax
  8005b9:	ff d6                	call   *%esi
  8005bb:	83 c4 10             	add    $0x10,%esp
  8005be:	eb de                	jmp    80059e <vprintfmt+0x372>
	if (lflag >= 2)
  8005c0:	83 f9 01             	cmp    $0x1,%ecx
  8005c3:	7f 1b                	jg     8005e0 <vprintfmt+0x3b4>
	else if (lflag)
  8005c5:	85 c9                	test   %ecx,%ecx
  8005c7:	74 2c                	je     8005f5 <vprintfmt+0x3c9>
		return va_arg(*ap, unsigned long);
  8005c9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005cc:	8b 10                	mov    (%eax),%edx
  8005ce:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005d3:	8d 40 04             	lea    0x4(%eax),%eax
  8005d6:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8005d9:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  8005de:	eb a1                	jmp    800581 <vprintfmt+0x355>
		return va_arg(*ap, unsigned long long);
  8005e0:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e3:	8b 10                	mov    (%eax),%edx
  8005e5:	8b 48 04             	mov    0x4(%eax),%ecx
  8005e8:	8d 40 08             	lea    0x8(%eax),%eax
  8005eb:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8005ee:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  8005f3:	eb 8c                	jmp    800581 <vprintfmt+0x355>
		return va_arg(*ap, unsigned int);
  8005f5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f8:	8b 10                	mov    (%eax),%edx
  8005fa:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005ff:	8d 40 04             	lea    0x4(%eax),%eax
  800602:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800605:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  80060a:	e9 72 ff ff ff       	jmp    800581 <vprintfmt+0x355>
			putch(ch, putdat);
  80060f:	83 ec 08             	sub    $0x8,%esp
  800612:	53                   	push   %ebx
  800613:	6a 25                	push   $0x25
  800615:	ff d6                	call   *%esi
			break;
  800617:	83 c4 10             	add    $0x10,%esp
  80061a:	e9 7c ff ff ff       	jmp    80059b <vprintfmt+0x36f>
			putch('%', putdat);
  80061f:	83 ec 08             	sub    $0x8,%esp
  800622:	53                   	push   %ebx
  800623:	6a 25                	push   $0x25
  800625:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800627:	83 c4 10             	add    $0x10,%esp
  80062a:	89 f8                	mov    %edi,%eax
  80062c:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800630:	74 03                	je     800635 <vprintfmt+0x409>
  800632:	48                   	dec    %eax
  800633:	eb f7                	jmp    80062c <vprintfmt+0x400>
  800635:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800638:	e9 5e ff ff ff       	jmp    80059b <vprintfmt+0x36f>
}
  80063d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800640:	5b                   	pop    %ebx
  800641:	5e                   	pop    %esi
  800642:	5f                   	pop    %edi
  800643:	5d                   	pop    %ebp
  800644:	c3                   	ret    

00800645 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800645:	55                   	push   %ebp
  800646:	89 e5                	mov    %esp,%ebp
  800648:	83 ec 18             	sub    $0x18,%esp
  80064b:	8b 45 08             	mov    0x8(%ebp),%eax
  80064e:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800651:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800654:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800658:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80065b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800662:	85 c0                	test   %eax,%eax
  800664:	74 26                	je     80068c <vsnprintf+0x47>
  800666:	85 d2                	test   %edx,%edx
  800668:	7e 29                	jle    800693 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80066a:	ff 75 14             	pushl  0x14(%ebp)
  80066d:	ff 75 10             	pushl  0x10(%ebp)
  800670:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800673:	50                   	push   %eax
  800674:	68 f3 01 80 00       	push   $0x8001f3
  800679:	e8 ae fb ff ff       	call   80022c <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80067e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800681:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800684:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800687:	83 c4 10             	add    $0x10,%esp
}
  80068a:	c9                   	leave  
  80068b:	c3                   	ret    
		return -E_INVAL;
  80068c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800691:	eb f7                	jmp    80068a <vsnprintf+0x45>
  800693:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800698:	eb f0                	jmp    80068a <vsnprintf+0x45>

0080069a <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80069a:	55                   	push   %ebp
  80069b:	89 e5                	mov    %esp,%ebp
  80069d:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006a0:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006a3:	50                   	push   %eax
  8006a4:	ff 75 10             	pushl  0x10(%ebp)
  8006a7:	ff 75 0c             	pushl  0xc(%ebp)
  8006aa:	ff 75 08             	pushl  0x8(%ebp)
  8006ad:	e8 93 ff ff ff       	call   800645 <vsnprintf>
	va_end(ap);

	return rc;
}
  8006b2:	c9                   	leave  
  8006b3:	c3                   	ret    

008006b4 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006b4:	55                   	push   %ebp
  8006b5:	89 e5                	mov    %esp,%ebp
  8006b7:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006ba:	b8 00 00 00 00       	mov    $0x0,%eax
  8006bf:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8006c3:	74 03                	je     8006c8 <strlen+0x14>
		n++;
  8006c5:	40                   	inc    %eax
  8006c6:	eb f7                	jmp    8006bf <strlen+0xb>
	return n;
}
  8006c8:	5d                   	pop    %ebp
  8006c9:	c3                   	ret    

008006ca <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8006ca:	55                   	push   %ebp
  8006cb:	89 e5                	mov    %esp,%ebp
  8006cd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006d0:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006d3:	b8 00 00 00 00       	mov    $0x0,%eax
  8006d8:	39 d0                	cmp    %edx,%eax
  8006da:	74 0b                	je     8006e7 <strnlen+0x1d>
  8006dc:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8006e0:	74 03                	je     8006e5 <strnlen+0x1b>
		n++;
  8006e2:	40                   	inc    %eax
  8006e3:	eb f3                	jmp    8006d8 <strnlen+0xe>
  8006e5:	89 c2                	mov    %eax,%edx
	return n;
}
  8006e7:	89 d0                	mov    %edx,%eax
  8006e9:	5d                   	pop    %ebp
  8006ea:	c3                   	ret    

008006eb <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8006eb:	55                   	push   %ebp
  8006ec:	89 e5                	mov    %esp,%ebp
  8006ee:	53                   	push   %ebx
  8006ef:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006f2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8006f5:	b8 00 00 00 00       	mov    $0x0,%eax
  8006fa:	8a 14 03             	mov    (%ebx,%eax,1),%dl
  8006fd:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800700:	40                   	inc    %eax
  800701:	84 d2                	test   %dl,%dl
  800703:	75 f5                	jne    8006fa <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800705:	89 c8                	mov    %ecx,%eax
  800707:	5b                   	pop    %ebx
  800708:	5d                   	pop    %ebp
  800709:	c3                   	ret    

0080070a <strcat>:

char *
strcat(char *dst, const char *src)
{
  80070a:	55                   	push   %ebp
  80070b:	89 e5                	mov    %esp,%ebp
  80070d:	53                   	push   %ebx
  80070e:	83 ec 10             	sub    $0x10,%esp
  800711:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800714:	53                   	push   %ebx
  800715:	e8 9a ff ff ff       	call   8006b4 <strlen>
  80071a:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  80071d:	ff 75 0c             	pushl  0xc(%ebp)
  800720:	01 d8                	add    %ebx,%eax
  800722:	50                   	push   %eax
  800723:	e8 c3 ff ff ff       	call   8006eb <strcpy>
	return dst;
}
  800728:	89 d8                	mov    %ebx,%eax
  80072a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80072d:	c9                   	leave  
  80072e:	c3                   	ret    

0080072f <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80072f:	55                   	push   %ebp
  800730:	89 e5                	mov    %esp,%ebp
  800732:	53                   	push   %ebx
  800733:	8b 55 0c             	mov    0xc(%ebp),%edx
  800736:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800739:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80073c:	8b 45 08             	mov    0x8(%ebp),%eax
  80073f:	39 d8                	cmp    %ebx,%eax
  800741:	74 0e                	je     800751 <strncpy+0x22>
		*dst++ = *src;
  800743:	40                   	inc    %eax
  800744:	8a 0a                	mov    (%edx),%cl
  800746:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800749:	80 f9 01             	cmp    $0x1,%cl
  80074c:	83 da ff             	sbb    $0xffffffff,%edx
  80074f:	eb ee                	jmp    80073f <strncpy+0x10>
	}
	return ret;
}
  800751:	8b 45 08             	mov    0x8(%ebp),%eax
  800754:	5b                   	pop    %ebx
  800755:	5d                   	pop    %ebp
  800756:	c3                   	ret    

00800757 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800757:	55                   	push   %ebp
  800758:	89 e5                	mov    %esp,%ebp
  80075a:	56                   	push   %esi
  80075b:	53                   	push   %ebx
  80075c:	8b 75 08             	mov    0x8(%ebp),%esi
  80075f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800762:	8b 45 10             	mov    0x10(%ebp),%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800765:	85 c0                	test   %eax,%eax
  800767:	74 22                	je     80078b <strlcpy+0x34>
  800769:	8d 44 06 ff          	lea    -0x1(%esi,%eax,1),%eax
  80076d:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  80076f:	39 c2                	cmp    %eax,%edx
  800771:	74 0f                	je     800782 <strlcpy+0x2b>
  800773:	8a 19                	mov    (%ecx),%bl
  800775:	84 db                	test   %bl,%bl
  800777:	74 07                	je     800780 <strlcpy+0x29>
			*dst++ = *src++;
  800779:	41                   	inc    %ecx
  80077a:	42                   	inc    %edx
  80077b:	88 5a ff             	mov    %bl,-0x1(%edx)
  80077e:	eb ef                	jmp    80076f <strlcpy+0x18>
  800780:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800782:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800785:	29 f0                	sub    %esi,%eax
}
  800787:	5b                   	pop    %ebx
  800788:	5e                   	pop    %esi
  800789:	5d                   	pop    %ebp
  80078a:	c3                   	ret    
  80078b:	89 f0                	mov    %esi,%eax
  80078d:	eb f6                	jmp    800785 <strlcpy+0x2e>

0080078f <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80078f:	55                   	push   %ebp
  800790:	89 e5                	mov    %esp,%ebp
  800792:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800795:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800798:	8a 01                	mov    (%ecx),%al
  80079a:	84 c0                	test   %al,%al
  80079c:	74 08                	je     8007a6 <strcmp+0x17>
  80079e:	3a 02                	cmp    (%edx),%al
  8007a0:	75 04                	jne    8007a6 <strcmp+0x17>
		p++, q++;
  8007a2:	41                   	inc    %ecx
  8007a3:	42                   	inc    %edx
  8007a4:	eb f2                	jmp    800798 <strcmp+0x9>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007a6:	0f b6 c0             	movzbl %al,%eax
  8007a9:	0f b6 12             	movzbl (%edx),%edx
  8007ac:	29 d0                	sub    %edx,%eax
}
  8007ae:	5d                   	pop    %ebp
  8007af:	c3                   	ret    

008007b0 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8007b0:	55                   	push   %ebp
  8007b1:	89 e5                	mov    %esp,%ebp
  8007b3:	53                   	push   %ebx
  8007b4:	8b 45 08             	mov    0x8(%ebp),%eax
  8007b7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007ba:	89 c3                	mov    %eax,%ebx
  8007bc:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8007bf:	eb 02                	jmp    8007c3 <strncmp+0x13>
		n--, p++, q++;
  8007c1:	40                   	inc    %eax
  8007c2:	42                   	inc    %edx
	while (n > 0 && *p && *p == *q)
  8007c3:	39 d8                	cmp    %ebx,%eax
  8007c5:	74 15                	je     8007dc <strncmp+0x2c>
  8007c7:	8a 08                	mov    (%eax),%cl
  8007c9:	84 c9                	test   %cl,%cl
  8007cb:	74 04                	je     8007d1 <strncmp+0x21>
  8007cd:	3a 0a                	cmp    (%edx),%cl
  8007cf:	74 f0                	je     8007c1 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8007d1:	0f b6 00             	movzbl (%eax),%eax
  8007d4:	0f b6 12             	movzbl (%edx),%edx
  8007d7:	29 d0                	sub    %edx,%eax
}
  8007d9:	5b                   	pop    %ebx
  8007da:	5d                   	pop    %ebp
  8007db:	c3                   	ret    
		return 0;
  8007dc:	b8 00 00 00 00       	mov    $0x0,%eax
  8007e1:	eb f6                	jmp    8007d9 <strncmp+0x29>

008007e3 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8007e3:	55                   	push   %ebp
  8007e4:	89 e5                	mov    %esp,%ebp
  8007e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8007e9:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8007ec:	8a 10                	mov    (%eax),%dl
  8007ee:	84 d2                	test   %dl,%dl
  8007f0:	74 07                	je     8007f9 <strchr+0x16>
		if (*s == c)
  8007f2:	38 ca                	cmp    %cl,%dl
  8007f4:	74 08                	je     8007fe <strchr+0x1b>
	for (; *s; s++)
  8007f6:	40                   	inc    %eax
  8007f7:	eb f3                	jmp    8007ec <strchr+0x9>
			return (char *) s;
	return 0;
  8007f9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007fe:	5d                   	pop    %ebp
  8007ff:	c3                   	ret    

00800800 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800800:	55                   	push   %ebp
  800801:	89 e5                	mov    %esp,%ebp
  800803:	8b 45 08             	mov    0x8(%ebp),%eax
  800806:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800809:	8a 10                	mov    (%eax),%dl
  80080b:	84 d2                	test   %dl,%dl
  80080d:	74 07                	je     800816 <strfind+0x16>
		if (*s == c)
  80080f:	38 ca                	cmp    %cl,%dl
  800811:	74 03                	je     800816 <strfind+0x16>
	for (; *s; s++)
  800813:	40                   	inc    %eax
  800814:	eb f3                	jmp    800809 <strfind+0x9>
			break;
	return (char *) s;
}
  800816:	5d                   	pop    %ebp
  800817:	c3                   	ret    

00800818 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800818:	55                   	push   %ebp
  800819:	89 e5                	mov    %esp,%ebp
  80081b:	57                   	push   %edi
  80081c:	56                   	push   %esi
  80081d:	53                   	push   %ebx
  80081e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800821:	85 c9                	test   %ecx,%ecx
  800823:	74 36                	je     80085b <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800825:	89 c8                	mov    %ecx,%eax
  800827:	0b 45 08             	or     0x8(%ebp),%eax
  80082a:	a8 03                	test   $0x3,%al
  80082c:	75 24                	jne    800852 <memset+0x3a>
		c &= 0xFF;
  80082e:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800832:	89 d3                	mov    %edx,%ebx
  800834:	c1 e3 08             	shl    $0x8,%ebx
  800837:	89 d0                	mov    %edx,%eax
  800839:	c1 e0 18             	shl    $0x18,%eax
  80083c:	89 d6                	mov    %edx,%esi
  80083e:	c1 e6 10             	shl    $0x10,%esi
  800841:	09 f0                	or     %esi,%eax
  800843:	09 d0                	or     %edx,%eax
  800845:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800847:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  80084a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80084d:	fc                   	cld    
  80084e:	f3 ab                	rep stos %eax,%es:(%edi)
  800850:	eb 09                	jmp    80085b <memset+0x43>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800852:	8b 7d 08             	mov    0x8(%ebp),%edi
  800855:	8b 45 0c             	mov    0xc(%ebp),%eax
  800858:	fc                   	cld    
  800859:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80085b:	8b 45 08             	mov    0x8(%ebp),%eax
  80085e:	5b                   	pop    %ebx
  80085f:	5e                   	pop    %esi
  800860:	5f                   	pop    %edi
  800861:	5d                   	pop    %ebp
  800862:	c3                   	ret    

00800863 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800863:	55                   	push   %ebp
  800864:	89 e5                	mov    %esp,%ebp
  800866:	57                   	push   %edi
  800867:	56                   	push   %esi
  800868:	8b 45 08             	mov    0x8(%ebp),%eax
  80086b:	8b 75 0c             	mov    0xc(%ebp),%esi
  80086e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800871:	39 c6                	cmp    %eax,%esi
  800873:	73 30                	jae    8008a5 <memmove+0x42>
  800875:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800878:	39 c2                	cmp    %eax,%edx
  80087a:	76 29                	jbe    8008a5 <memmove+0x42>
		s += n;
		d += n;
  80087c:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80087f:	89 fe                	mov    %edi,%esi
  800881:	09 ce                	or     %ecx,%esi
  800883:	09 d6                	or     %edx,%esi
  800885:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80088b:	75 0e                	jne    80089b <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  80088d:	83 ef 04             	sub    $0x4,%edi
  800890:	8d 72 fc             	lea    -0x4(%edx),%esi
  800893:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800896:	fd                   	std    
  800897:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800899:	eb 07                	jmp    8008a2 <memmove+0x3f>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80089b:	4f                   	dec    %edi
  80089c:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  80089f:	fd                   	std    
  8008a0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8008a2:	fc                   	cld    
  8008a3:	eb 1a                	jmp    8008bf <memmove+0x5c>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008a5:	89 c2                	mov    %eax,%edx
  8008a7:	09 ca                	or     %ecx,%edx
  8008a9:	09 f2                	or     %esi,%edx
  8008ab:	f6 c2 03             	test   $0x3,%dl
  8008ae:	75 0a                	jne    8008ba <memmove+0x57>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8008b0:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  8008b3:	89 c7                	mov    %eax,%edi
  8008b5:	fc                   	cld    
  8008b6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008b8:	eb 05                	jmp    8008bf <memmove+0x5c>
		else
			asm volatile("cld; rep movsb\n"
  8008ba:	89 c7                	mov    %eax,%edi
  8008bc:	fc                   	cld    
  8008bd:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8008bf:	5e                   	pop    %esi
  8008c0:	5f                   	pop    %edi
  8008c1:	5d                   	pop    %ebp
  8008c2:	c3                   	ret    

008008c3 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8008c3:	55                   	push   %ebp
  8008c4:	89 e5                	mov    %esp,%ebp
  8008c6:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8008c9:	ff 75 10             	pushl  0x10(%ebp)
  8008cc:	ff 75 0c             	pushl  0xc(%ebp)
  8008cf:	ff 75 08             	pushl  0x8(%ebp)
  8008d2:	e8 8c ff ff ff       	call   800863 <memmove>
}
  8008d7:	c9                   	leave  
  8008d8:	c3                   	ret    

008008d9 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8008d9:	55                   	push   %ebp
  8008da:	89 e5                	mov    %esp,%ebp
  8008dc:	56                   	push   %esi
  8008dd:	53                   	push   %ebx
  8008de:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008e4:	89 c6                	mov    %eax,%esi
  8008e6:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8008e9:	39 f0                	cmp    %esi,%eax
  8008eb:	74 16                	je     800903 <memcmp+0x2a>
		if (*s1 != *s2)
  8008ed:	8a 08                	mov    (%eax),%cl
  8008ef:	8a 1a                	mov    (%edx),%bl
  8008f1:	38 d9                	cmp    %bl,%cl
  8008f3:	75 04                	jne    8008f9 <memcmp+0x20>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  8008f5:	40                   	inc    %eax
  8008f6:	42                   	inc    %edx
  8008f7:	eb f0                	jmp    8008e9 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  8008f9:	0f b6 c1             	movzbl %cl,%eax
  8008fc:	0f b6 db             	movzbl %bl,%ebx
  8008ff:	29 d8                	sub    %ebx,%eax
  800901:	eb 05                	jmp    800908 <memcmp+0x2f>
	}

	return 0;
  800903:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800908:	5b                   	pop    %ebx
  800909:	5e                   	pop    %esi
  80090a:	5d                   	pop    %ebp
  80090b:	c3                   	ret    

0080090c <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80090c:	55                   	push   %ebp
  80090d:	89 e5                	mov    %esp,%ebp
  80090f:	8b 45 08             	mov    0x8(%ebp),%eax
  800912:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800915:	89 c2                	mov    %eax,%edx
  800917:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  80091a:	39 d0                	cmp    %edx,%eax
  80091c:	73 07                	jae    800925 <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
  80091e:	38 08                	cmp    %cl,(%eax)
  800920:	74 03                	je     800925 <memfind+0x19>
	for (; s < ends; s++)
  800922:	40                   	inc    %eax
  800923:	eb f5                	jmp    80091a <memfind+0xe>
			break;
	return (void *) s;
}
  800925:	5d                   	pop    %ebp
  800926:	c3                   	ret    

00800927 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800927:	55                   	push   %ebp
  800928:	89 e5                	mov    %esp,%ebp
  80092a:	57                   	push   %edi
  80092b:	56                   	push   %esi
  80092c:	53                   	push   %ebx
  80092d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800930:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800933:	eb 01                	jmp    800936 <strtol+0xf>
		s++;
  800935:	41                   	inc    %ecx
	while (*s == ' ' || *s == '\t')
  800936:	8a 01                	mov    (%ecx),%al
  800938:	3c 20                	cmp    $0x20,%al
  80093a:	74 f9                	je     800935 <strtol+0xe>
  80093c:	3c 09                	cmp    $0x9,%al
  80093e:	74 f5                	je     800935 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800940:	3c 2b                	cmp    $0x2b,%al
  800942:	74 24                	je     800968 <strtol+0x41>
		s++;
	else if (*s == '-')
  800944:	3c 2d                	cmp    $0x2d,%al
  800946:	74 28                	je     800970 <strtol+0x49>
	int neg = 0;
  800948:	bf 00 00 00 00       	mov    $0x0,%edi
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80094d:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800953:	75 09                	jne    80095e <strtol+0x37>
  800955:	80 39 30             	cmpb   $0x30,(%ecx)
  800958:	74 1e                	je     800978 <strtol+0x51>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  80095a:	85 db                	test   %ebx,%ebx
  80095c:	74 36                	je     800994 <strtol+0x6d>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  80095e:	b8 00 00 00 00       	mov    $0x0,%eax
  800963:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800966:	eb 45                	jmp    8009ad <strtol+0x86>
		s++;
  800968:	41                   	inc    %ecx
	int neg = 0;
  800969:	bf 00 00 00 00       	mov    $0x0,%edi
  80096e:	eb dd                	jmp    80094d <strtol+0x26>
		s++, neg = 1;
  800970:	41                   	inc    %ecx
  800971:	bf 01 00 00 00       	mov    $0x1,%edi
  800976:	eb d5                	jmp    80094d <strtol+0x26>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800978:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  80097c:	74 0c                	je     80098a <strtol+0x63>
	else if (base == 0 && s[0] == '0')
  80097e:	85 db                	test   %ebx,%ebx
  800980:	75 dc                	jne    80095e <strtol+0x37>
		s++, base = 8;
  800982:	41                   	inc    %ecx
  800983:	bb 08 00 00 00       	mov    $0x8,%ebx
  800988:	eb d4                	jmp    80095e <strtol+0x37>
		s += 2, base = 16;
  80098a:	83 c1 02             	add    $0x2,%ecx
  80098d:	bb 10 00 00 00       	mov    $0x10,%ebx
  800992:	eb ca                	jmp    80095e <strtol+0x37>
		base = 10;
  800994:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800999:	eb c3                	jmp    80095e <strtol+0x37>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  80099b:	0f be d2             	movsbl %dl,%edx
  80099e:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  8009a1:	3b 55 10             	cmp    0x10(%ebp),%edx
  8009a4:	7d 37                	jge    8009dd <strtol+0xb6>
			break;
		s++, val = (val * base) + dig;
  8009a6:	41                   	inc    %ecx
  8009a7:	0f af 45 10          	imul   0x10(%ebp),%eax
  8009ab:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  8009ad:	8a 11                	mov    (%ecx),%dl
  8009af:	8d 72 d0             	lea    -0x30(%edx),%esi
  8009b2:	89 f3                	mov    %esi,%ebx
  8009b4:	80 fb 09             	cmp    $0x9,%bl
  8009b7:	76 e2                	jbe    80099b <strtol+0x74>
		else if (*s >= 'a' && *s <= 'z')
  8009b9:	8d 72 9f             	lea    -0x61(%edx),%esi
  8009bc:	89 f3                	mov    %esi,%ebx
  8009be:	80 fb 19             	cmp    $0x19,%bl
  8009c1:	77 08                	ja     8009cb <strtol+0xa4>
			dig = *s - 'a' + 10;
  8009c3:	0f be d2             	movsbl %dl,%edx
  8009c6:	83 ea 57             	sub    $0x57,%edx
  8009c9:	eb d6                	jmp    8009a1 <strtol+0x7a>
		else if (*s >= 'A' && *s <= 'Z')
  8009cb:	8d 72 bf             	lea    -0x41(%edx),%esi
  8009ce:	89 f3                	mov    %esi,%ebx
  8009d0:	80 fb 19             	cmp    $0x19,%bl
  8009d3:	77 08                	ja     8009dd <strtol+0xb6>
			dig = *s - 'A' + 10;
  8009d5:	0f be d2             	movsbl %dl,%edx
  8009d8:	83 ea 37             	sub    $0x37,%edx
  8009db:	eb c4                	jmp    8009a1 <strtol+0x7a>
		// we don't properly detect overflow!
	}

	if (endptr)
  8009dd:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8009e1:	74 05                	je     8009e8 <strtol+0xc1>
		*endptr = (char *) s;
  8009e3:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009e6:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  8009e8:	85 ff                	test   %edi,%edi
  8009ea:	74 02                	je     8009ee <strtol+0xc7>
  8009ec:	f7 d8                	neg    %eax
}
  8009ee:	5b                   	pop    %ebx
  8009ef:	5e                   	pop    %esi
  8009f0:	5f                   	pop    %edi
  8009f1:	5d                   	pop    %ebp
  8009f2:	c3                   	ret    

008009f3 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8009f3:	55                   	push   %ebp
  8009f4:	89 e5                	mov    %esp,%ebp
  8009f6:	57                   	push   %edi
  8009f7:	56                   	push   %esi
  8009f8:	53                   	push   %ebx
	asm volatile("int %1\n"
  8009f9:	b8 00 00 00 00       	mov    $0x0,%eax
  8009fe:	8b 55 08             	mov    0x8(%ebp),%edx
  800a01:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a04:	89 c3                	mov    %eax,%ebx
  800a06:	89 c7                	mov    %eax,%edi
  800a08:	89 c6                	mov    %eax,%esi
  800a0a:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a0c:	5b                   	pop    %ebx
  800a0d:	5e                   	pop    %esi
  800a0e:	5f                   	pop    %edi
  800a0f:	5d                   	pop    %ebp
  800a10:	c3                   	ret    

00800a11 <sys_cgetc>:

int
sys_cgetc(void)
{
  800a11:	55                   	push   %ebp
  800a12:	89 e5                	mov    %esp,%ebp
  800a14:	57                   	push   %edi
  800a15:	56                   	push   %esi
  800a16:	53                   	push   %ebx
	asm volatile("int %1\n"
  800a17:	ba 00 00 00 00       	mov    $0x0,%edx
  800a1c:	b8 01 00 00 00       	mov    $0x1,%eax
  800a21:	89 d1                	mov    %edx,%ecx
  800a23:	89 d3                	mov    %edx,%ebx
  800a25:	89 d7                	mov    %edx,%edi
  800a27:	89 d6                	mov    %edx,%esi
  800a29:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800a2b:	5b                   	pop    %ebx
  800a2c:	5e                   	pop    %esi
  800a2d:	5f                   	pop    %edi
  800a2e:	5d                   	pop    %ebp
  800a2f:	c3                   	ret    

00800a30 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800a30:	55                   	push   %ebp
  800a31:	89 e5                	mov    %esp,%ebp
  800a33:	57                   	push   %edi
  800a34:	56                   	push   %esi
  800a35:	53                   	push   %ebx
  800a36:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800a39:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a3e:	8b 55 08             	mov    0x8(%ebp),%edx
  800a41:	b8 03 00 00 00       	mov    $0x3,%eax
  800a46:	89 cb                	mov    %ecx,%ebx
  800a48:	89 cf                	mov    %ecx,%edi
  800a4a:	89 ce                	mov    %ecx,%esi
  800a4c:	cd 30                	int    $0x30
	if(check && ret > 0)
  800a4e:	85 c0                	test   %eax,%eax
  800a50:	7f 08                	jg     800a5a <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800a52:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a55:	5b                   	pop    %ebx
  800a56:	5e                   	pop    %esi
  800a57:	5f                   	pop    %edi
  800a58:	5d                   	pop    %ebp
  800a59:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800a5a:	83 ec 0c             	sub    $0xc,%esp
  800a5d:	50                   	push   %eax
  800a5e:	6a 03                	push   $0x3
  800a60:	68 30 0f 80 00       	push   $0x800f30
  800a65:	6a 23                	push   $0x23
  800a67:	68 4d 0f 80 00       	push   $0x800f4d
  800a6c:	e8 1f 00 00 00       	call   800a90 <_panic>

00800a71 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800a71:	55                   	push   %ebp
  800a72:	89 e5                	mov    %esp,%ebp
  800a74:	57                   	push   %edi
  800a75:	56                   	push   %esi
  800a76:	53                   	push   %ebx
	asm volatile("int %1\n"
  800a77:	ba 00 00 00 00       	mov    $0x0,%edx
  800a7c:	b8 02 00 00 00       	mov    $0x2,%eax
  800a81:	89 d1                	mov    %edx,%ecx
  800a83:	89 d3                	mov    %edx,%ebx
  800a85:	89 d7                	mov    %edx,%edi
  800a87:	89 d6                	mov    %edx,%esi
  800a89:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800a8b:	5b                   	pop    %ebx
  800a8c:	5e                   	pop    %esi
  800a8d:	5f                   	pop    %edi
  800a8e:	5d                   	pop    %ebp
  800a8f:	c3                   	ret    

00800a90 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800a90:	55                   	push   %ebp
  800a91:	89 e5                	mov    %esp,%ebp
  800a93:	56                   	push   %esi
  800a94:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800a95:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800a98:	8b 35 00 10 80 00    	mov    0x801000,%esi
  800a9e:	e8 ce ff ff ff       	call   800a71 <sys_getenvid>
  800aa3:	83 ec 0c             	sub    $0xc,%esp
  800aa6:	ff 75 0c             	pushl  0xc(%ebp)
  800aa9:	ff 75 08             	pushl  0x8(%ebp)
  800aac:	56                   	push   %esi
  800aad:	50                   	push   %eax
  800aae:	68 5c 0f 80 00       	push   $0x800f5c
  800ab3:	e8 82 f6 ff ff       	call   80013a <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800ab8:	83 c4 18             	add    $0x18,%esp
  800abb:	53                   	push   %ebx
  800abc:	ff 75 10             	pushl  0x10(%ebp)
  800abf:	e8 25 f6 ff ff       	call   8000e9 <vcprintf>
	cprintf("\n");
  800ac4:	c7 04 24 0c 0d 80 00 	movl   $0x800d0c,(%esp)
  800acb:	e8 6a f6 ff ff       	call   80013a <cprintf>
  800ad0:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800ad3:	cc                   	int3   
  800ad4:	eb fd                	jmp    800ad3 <_panic+0x43>
  800ad6:	66 90                	xchg   %ax,%ax

00800ad8 <__udivdi3>:
  800ad8:	55                   	push   %ebp
  800ad9:	57                   	push   %edi
  800ada:	56                   	push   %esi
  800adb:	53                   	push   %ebx
  800adc:	83 ec 1c             	sub    $0x1c,%esp
  800adf:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800ae3:	8b 74 24 34          	mov    0x34(%esp),%esi
  800ae7:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800aeb:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800aef:	85 d2                	test   %edx,%edx
  800af1:	75 19                	jne    800b0c <__udivdi3+0x34>
  800af3:	39 f7                	cmp    %esi,%edi
  800af5:	76 45                	jbe    800b3c <__udivdi3+0x64>
  800af7:	89 e8                	mov    %ebp,%eax
  800af9:	89 f2                	mov    %esi,%edx
  800afb:	f7 f7                	div    %edi
  800afd:	31 db                	xor    %ebx,%ebx
  800aff:	89 da                	mov    %ebx,%edx
  800b01:	83 c4 1c             	add    $0x1c,%esp
  800b04:	5b                   	pop    %ebx
  800b05:	5e                   	pop    %esi
  800b06:	5f                   	pop    %edi
  800b07:	5d                   	pop    %ebp
  800b08:	c3                   	ret    
  800b09:	8d 76 00             	lea    0x0(%esi),%esi
  800b0c:	39 f2                	cmp    %esi,%edx
  800b0e:	76 10                	jbe    800b20 <__udivdi3+0x48>
  800b10:	31 db                	xor    %ebx,%ebx
  800b12:	31 c0                	xor    %eax,%eax
  800b14:	89 da                	mov    %ebx,%edx
  800b16:	83 c4 1c             	add    $0x1c,%esp
  800b19:	5b                   	pop    %ebx
  800b1a:	5e                   	pop    %esi
  800b1b:	5f                   	pop    %edi
  800b1c:	5d                   	pop    %ebp
  800b1d:	c3                   	ret    
  800b1e:	66 90                	xchg   %ax,%ax
  800b20:	0f bd da             	bsr    %edx,%ebx
  800b23:	83 f3 1f             	xor    $0x1f,%ebx
  800b26:	75 3c                	jne    800b64 <__udivdi3+0x8c>
  800b28:	39 f2                	cmp    %esi,%edx
  800b2a:	72 08                	jb     800b34 <__udivdi3+0x5c>
  800b2c:	39 ef                	cmp    %ebp,%edi
  800b2e:	0f 87 9c 00 00 00    	ja     800bd0 <__udivdi3+0xf8>
  800b34:	b8 01 00 00 00       	mov    $0x1,%eax
  800b39:	eb d9                	jmp    800b14 <__udivdi3+0x3c>
  800b3b:	90                   	nop
  800b3c:	89 f9                	mov    %edi,%ecx
  800b3e:	85 ff                	test   %edi,%edi
  800b40:	75 0b                	jne    800b4d <__udivdi3+0x75>
  800b42:	b8 01 00 00 00       	mov    $0x1,%eax
  800b47:	31 d2                	xor    %edx,%edx
  800b49:	f7 f7                	div    %edi
  800b4b:	89 c1                	mov    %eax,%ecx
  800b4d:	31 d2                	xor    %edx,%edx
  800b4f:	89 f0                	mov    %esi,%eax
  800b51:	f7 f1                	div    %ecx
  800b53:	89 c3                	mov    %eax,%ebx
  800b55:	89 e8                	mov    %ebp,%eax
  800b57:	f7 f1                	div    %ecx
  800b59:	89 da                	mov    %ebx,%edx
  800b5b:	83 c4 1c             	add    $0x1c,%esp
  800b5e:	5b                   	pop    %ebx
  800b5f:	5e                   	pop    %esi
  800b60:	5f                   	pop    %edi
  800b61:	5d                   	pop    %ebp
  800b62:	c3                   	ret    
  800b63:	90                   	nop
  800b64:	b8 20 00 00 00       	mov    $0x20,%eax
  800b69:	29 d8                	sub    %ebx,%eax
  800b6b:	88 d9                	mov    %bl,%cl
  800b6d:	d3 e2                	shl    %cl,%edx
  800b6f:	89 54 24 08          	mov    %edx,0x8(%esp)
  800b73:	89 fa                	mov    %edi,%edx
  800b75:	88 c1                	mov    %al,%cl
  800b77:	d3 ea                	shr    %cl,%edx
  800b79:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800b7d:	09 d1                	or     %edx,%ecx
  800b7f:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800b83:	88 d9                	mov    %bl,%cl
  800b85:	d3 e7                	shl    %cl,%edi
  800b87:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800b8b:	89 f7                	mov    %esi,%edi
  800b8d:	88 c1                	mov    %al,%cl
  800b8f:	d3 ef                	shr    %cl,%edi
  800b91:	88 d9                	mov    %bl,%cl
  800b93:	d3 e6                	shl    %cl,%esi
  800b95:	89 ea                	mov    %ebp,%edx
  800b97:	88 c1                	mov    %al,%cl
  800b99:	d3 ea                	shr    %cl,%edx
  800b9b:	09 d6                	or     %edx,%esi
  800b9d:	89 f0                	mov    %esi,%eax
  800b9f:	89 fa                	mov    %edi,%edx
  800ba1:	f7 74 24 08          	divl   0x8(%esp)
  800ba5:	89 d7                	mov    %edx,%edi
  800ba7:	89 c6                	mov    %eax,%esi
  800ba9:	f7 64 24 0c          	mull   0xc(%esp)
  800bad:	39 d7                	cmp    %edx,%edi
  800baf:	72 13                	jb     800bc4 <__udivdi3+0xec>
  800bb1:	74 09                	je     800bbc <__udivdi3+0xe4>
  800bb3:	89 f0                	mov    %esi,%eax
  800bb5:	31 db                	xor    %ebx,%ebx
  800bb7:	e9 58 ff ff ff       	jmp    800b14 <__udivdi3+0x3c>
  800bbc:	88 d9                	mov    %bl,%cl
  800bbe:	d3 e5                	shl    %cl,%ebp
  800bc0:	39 c5                	cmp    %eax,%ebp
  800bc2:	73 ef                	jae    800bb3 <__udivdi3+0xdb>
  800bc4:	8d 46 ff             	lea    -0x1(%esi),%eax
  800bc7:	31 db                	xor    %ebx,%ebx
  800bc9:	e9 46 ff ff ff       	jmp    800b14 <__udivdi3+0x3c>
  800bce:	66 90                	xchg   %ax,%ax
  800bd0:	31 c0                	xor    %eax,%eax
  800bd2:	e9 3d ff ff ff       	jmp    800b14 <__udivdi3+0x3c>
  800bd7:	90                   	nop

00800bd8 <__umoddi3>:
  800bd8:	55                   	push   %ebp
  800bd9:	57                   	push   %edi
  800bda:	56                   	push   %esi
  800bdb:	53                   	push   %ebx
  800bdc:	83 ec 1c             	sub    $0x1c,%esp
  800bdf:	8b 74 24 30          	mov    0x30(%esp),%esi
  800be3:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800be7:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800beb:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  800bef:	85 c0                	test   %eax,%eax
  800bf1:	75 19                	jne    800c0c <__umoddi3+0x34>
  800bf3:	39 df                	cmp    %ebx,%edi
  800bf5:	76 51                	jbe    800c48 <__umoddi3+0x70>
  800bf7:	89 f0                	mov    %esi,%eax
  800bf9:	89 da                	mov    %ebx,%edx
  800bfb:	f7 f7                	div    %edi
  800bfd:	89 d0                	mov    %edx,%eax
  800bff:	31 d2                	xor    %edx,%edx
  800c01:	83 c4 1c             	add    $0x1c,%esp
  800c04:	5b                   	pop    %ebx
  800c05:	5e                   	pop    %esi
  800c06:	5f                   	pop    %edi
  800c07:	5d                   	pop    %ebp
  800c08:	c3                   	ret    
  800c09:	8d 76 00             	lea    0x0(%esi),%esi
  800c0c:	89 f2                	mov    %esi,%edx
  800c0e:	39 d8                	cmp    %ebx,%eax
  800c10:	76 0e                	jbe    800c20 <__umoddi3+0x48>
  800c12:	89 f0                	mov    %esi,%eax
  800c14:	89 da                	mov    %ebx,%edx
  800c16:	83 c4 1c             	add    $0x1c,%esp
  800c19:	5b                   	pop    %ebx
  800c1a:	5e                   	pop    %esi
  800c1b:	5f                   	pop    %edi
  800c1c:	5d                   	pop    %ebp
  800c1d:	c3                   	ret    
  800c1e:	66 90                	xchg   %ax,%ax
  800c20:	0f bd e8             	bsr    %eax,%ebp
  800c23:	83 f5 1f             	xor    $0x1f,%ebp
  800c26:	75 44                	jne    800c6c <__umoddi3+0x94>
  800c28:	39 d8                	cmp    %ebx,%eax
  800c2a:	72 06                	jb     800c32 <__umoddi3+0x5a>
  800c2c:	89 d9                	mov    %ebx,%ecx
  800c2e:	39 f7                	cmp    %esi,%edi
  800c30:	77 08                	ja     800c3a <__umoddi3+0x62>
  800c32:	29 fe                	sub    %edi,%esi
  800c34:	19 c3                	sbb    %eax,%ebx
  800c36:	89 f2                	mov    %esi,%edx
  800c38:	89 d9                	mov    %ebx,%ecx
  800c3a:	89 d0                	mov    %edx,%eax
  800c3c:	89 ca                	mov    %ecx,%edx
  800c3e:	83 c4 1c             	add    $0x1c,%esp
  800c41:	5b                   	pop    %ebx
  800c42:	5e                   	pop    %esi
  800c43:	5f                   	pop    %edi
  800c44:	5d                   	pop    %ebp
  800c45:	c3                   	ret    
  800c46:	66 90                	xchg   %ax,%ax
  800c48:	89 fd                	mov    %edi,%ebp
  800c4a:	85 ff                	test   %edi,%edi
  800c4c:	75 0b                	jne    800c59 <__umoddi3+0x81>
  800c4e:	b8 01 00 00 00       	mov    $0x1,%eax
  800c53:	31 d2                	xor    %edx,%edx
  800c55:	f7 f7                	div    %edi
  800c57:	89 c5                	mov    %eax,%ebp
  800c59:	89 d8                	mov    %ebx,%eax
  800c5b:	31 d2                	xor    %edx,%edx
  800c5d:	f7 f5                	div    %ebp
  800c5f:	89 f0                	mov    %esi,%eax
  800c61:	f7 f5                	div    %ebp
  800c63:	89 d0                	mov    %edx,%eax
  800c65:	31 d2                	xor    %edx,%edx
  800c67:	eb 98                	jmp    800c01 <__umoddi3+0x29>
  800c69:	8d 76 00             	lea    0x0(%esi),%esi
  800c6c:	ba 20 00 00 00       	mov    $0x20,%edx
  800c71:	29 ea                	sub    %ebp,%edx
  800c73:	89 e9                	mov    %ebp,%ecx
  800c75:	d3 e0                	shl    %cl,%eax
  800c77:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c7b:	89 f8                	mov    %edi,%eax
  800c7d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800c81:	88 d1                	mov    %dl,%cl
  800c83:	d3 e8                	shr    %cl,%eax
  800c85:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800c89:	09 c1                	or     %eax,%ecx
  800c8b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800c8f:	89 e9                	mov    %ebp,%ecx
  800c91:	d3 e7                	shl    %cl,%edi
  800c93:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800c97:	89 d8                	mov    %ebx,%eax
  800c99:	8b 54 24 04          	mov    0x4(%esp),%edx
  800c9d:	88 d1                	mov    %dl,%cl
  800c9f:	d3 e8                	shr    %cl,%eax
  800ca1:	89 c7                	mov    %eax,%edi
  800ca3:	89 e9                	mov    %ebp,%ecx
  800ca5:	d3 e3                	shl    %cl,%ebx
  800ca7:	89 f0                	mov    %esi,%eax
  800ca9:	88 d1                	mov    %dl,%cl
  800cab:	d3 e8                	shr    %cl,%eax
  800cad:	09 d8                	or     %ebx,%eax
  800caf:	89 e9                	mov    %ebp,%ecx
  800cb1:	d3 e6                	shl    %cl,%esi
  800cb3:	89 f3                	mov    %esi,%ebx
  800cb5:	89 fa                	mov    %edi,%edx
  800cb7:	f7 74 24 08          	divl   0x8(%esp)
  800cbb:	89 d1                	mov    %edx,%ecx
  800cbd:	f7 64 24 0c          	mull   0xc(%esp)
  800cc1:	89 c6                	mov    %eax,%esi
  800cc3:	89 d7                	mov    %edx,%edi
  800cc5:	39 d1                	cmp    %edx,%ecx
  800cc7:	72 27                	jb     800cf0 <__umoddi3+0x118>
  800cc9:	74 21                	je     800cec <__umoddi3+0x114>
  800ccb:	89 ca                	mov    %ecx,%edx
  800ccd:	29 f3                	sub    %esi,%ebx
  800ccf:	19 fa                	sbb    %edi,%edx
  800cd1:	89 d0                	mov    %edx,%eax
  800cd3:	8a 4c 24 04          	mov    0x4(%esp),%cl
  800cd7:	d3 e0                	shl    %cl,%eax
  800cd9:	89 e9                	mov    %ebp,%ecx
  800cdb:	d3 eb                	shr    %cl,%ebx
  800cdd:	09 d8                	or     %ebx,%eax
  800cdf:	d3 ea                	shr    %cl,%edx
  800ce1:	83 c4 1c             	add    $0x1c,%esp
  800ce4:	5b                   	pop    %ebx
  800ce5:	5e                   	pop    %esi
  800ce6:	5f                   	pop    %edi
  800ce7:	5d                   	pop    %ebp
  800ce8:	c3                   	ret    
  800ce9:	8d 76 00             	lea    0x0(%esi),%esi
  800cec:	39 c3                	cmp    %eax,%ebx
  800cee:	73 db                	jae    800ccb <__umoddi3+0xf3>
  800cf0:	2b 44 24 0c          	sub    0xc(%esp),%eax
  800cf4:	1b 54 24 08          	sbb    0x8(%esp),%edx
  800cf8:	89 d7                	mov    %edx,%edi
  800cfa:	89 c6                	mov    %eax,%esi
  800cfc:	eb cd                	jmp    800ccb <__umoddi3+0xf3>
