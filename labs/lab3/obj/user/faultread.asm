
obj/user/faultread:     file format elf32-i386


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
  80002c:	e8 1d 00 00 00       	call   80004e <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	cprintf("I read %08x from location 0!\n", *(unsigned*)0);
  800039:	ff 35 00 00 00 00    	pushl  0x0
  80003f:	68 18 0d 80 00       	push   $0x800d18
  800044:	e8 0a 01 00 00       	call   800153 <cprintf>
}
  800049:	83 c4 10             	add    $0x10,%esp
  80004c:	c9                   	leave  
  80004d:	c3                   	ret    

0080004e <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80004e:	55                   	push   %ebp
  80004f:	89 e5                	mov    %esp,%ebp
  800051:	57                   	push   %edi
  800052:	56                   	push   %esi
  800053:	53                   	push   %ebx
  800054:	83 ec 6c             	sub    $0x6c,%esp
  800057:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	struct Env curenv = envs[ENVX(sys_getenvid())];
  80005a:	e8 2b 0a 00 00       	call   800a8a <sys_getenvid>
  80005f:	25 ff 03 00 00       	and    $0x3ff,%eax
  800064:	8d 34 00             	lea    (%eax,%eax,1),%esi
  800067:	01 c6                	add    %eax,%esi
  800069:	c1 e6 05             	shl    $0x5,%esi
  80006c:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  800072:	8d 7d 88             	lea    -0x78(%ebp),%edi
  800075:	b9 18 00 00 00       	mov    $0x18,%ecx
  80007a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	thisenv = &curenv;
  80007c:	8d 45 88             	lea    -0x78(%ebp),%eax
  80007f:	a3 04 10 80 00       	mov    %eax,0x801004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800084:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800088:	7e 07                	jle    800091 <libmain+0x43>
		binaryname = argv[0];
  80008a:	8b 03                	mov    (%ebx),%eax
  80008c:	a3 00 10 80 00       	mov    %eax,0x801000
	
	// call user main routine
	umain(argc, argv);
  800091:	83 ec 08             	sub    $0x8,%esp
  800094:	53                   	push   %ebx
  800095:	ff 75 08             	pushl  0x8(%ebp)
  800098:	e8 96 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80009d:	e8 0b 00 00 00       	call   8000ad <exit>
}
  8000a2:	83 c4 10             	add    $0x10,%esp
  8000a5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000a8:	5b                   	pop    %ebx
  8000a9:	5e                   	pop    %esi
  8000aa:	5f                   	pop    %edi
  8000ab:	5d                   	pop    %ebp
  8000ac:	c3                   	ret    

008000ad <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000ad:	55                   	push   %ebp
  8000ae:	89 e5                	mov    %esp,%ebp
  8000b0:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8000b3:	6a 00                	push   $0x0
  8000b5:	e8 8f 09 00 00       	call   800a49 <sys_env_destroy>
}
  8000ba:	83 c4 10             	add    $0x10,%esp
  8000bd:	c9                   	leave  
  8000be:	c3                   	ret    

008000bf <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000bf:	55                   	push   %ebp
  8000c0:	89 e5                	mov    %esp,%ebp
  8000c2:	53                   	push   %ebx
  8000c3:	83 ec 04             	sub    $0x4,%esp
  8000c6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000c9:	8b 13                	mov    (%ebx),%edx
  8000cb:	8d 42 01             	lea    0x1(%edx),%eax
  8000ce:	89 03                	mov    %eax,(%ebx)
  8000d0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000d3:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000d7:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000dc:	74 08                	je     8000e6 <putch+0x27>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8000de:	ff 43 04             	incl   0x4(%ebx)
}
  8000e1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000e4:	c9                   	leave  
  8000e5:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8000e6:	83 ec 08             	sub    $0x8,%esp
  8000e9:	68 ff 00 00 00       	push   $0xff
  8000ee:	8d 43 08             	lea    0x8(%ebx),%eax
  8000f1:	50                   	push   %eax
  8000f2:	e8 15 09 00 00       	call   800a0c <sys_cputs>
		b->idx = 0;
  8000f7:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8000fd:	83 c4 10             	add    $0x10,%esp
  800100:	eb dc                	jmp    8000de <putch+0x1f>

00800102 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800102:	55                   	push   %ebp
  800103:	89 e5                	mov    %esp,%ebp
  800105:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80010b:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800112:	00 00 00 
	b.cnt = 0;
  800115:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80011c:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80011f:	ff 75 0c             	pushl  0xc(%ebp)
  800122:	ff 75 08             	pushl  0x8(%ebp)
  800125:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80012b:	50                   	push   %eax
  80012c:	68 bf 00 80 00       	push   $0x8000bf
  800131:	e8 0f 01 00 00       	call   800245 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800136:	83 c4 08             	add    $0x8,%esp
  800139:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80013f:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800145:	50                   	push   %eax
  800146:	e8 c1 08 00 00       	call   800a0c <sys_cputs>

	return b.cnt;
}
  80014b:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800151:	c9                   	leave  
  800152:	c3                   	ret    

00800153 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800153:	55                   	push   %ebp
  800154:	89 e5                	mov    %esp,%ebp
  800156:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800159:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80015c:	50                   	push   %eax
  80015d:	ff 75 08             	pushl  0x8(%ebp)
  800160:	e8 9d ff ff ff       	call   800102 <vcprintf>
	va_end(ap);

	return cnt;
}
  800165:	c9                   	leave  
  800166:	c3                   	ret    

00800167 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800167:	55                   	push   %ebp
  800168:	89 e5                	mov    %esp,%ebp
  80016a:	57                   	push   %edi
  80016b:	56                   	push   %esi
  80016c:	53                   	push   %ebx
  80016d:	83 ec 1c             	sub    $0x1c,%esp
  800170:	89 c7                	mov    %eax,%edi
  800172:	89 d6                	mov    %edx,%esi
  800174:	8b 45 08             	mov    0x8(%ebp),%eax
  800177:	8b 55 0c             	mov    0xc(%ebp),%edx
  80017a:	89 d1                	mov    %edx,%ecx
  80017c:	89 c2                	mov    %eax,%edx
  80017e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800181:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800184:	8b 45 10             	mov    0x10(%ebp),%eax
  800187:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80018a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80018d:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800194:	39 c2                	cmp    %eax,%edx
  800196:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  800199:	72 3c                	jb     8001d7 <printnum+0x70>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80019b:	83 ec 0c             	sub    $0xc,%esp
  80019e:	ff 75 18             	pushl  0x18(%ebp)
  8001a1:	4b                   	dec    %ebx
  8001a2:	53                   	push   %ebx
  8001a3:	50                   	push   %eax
  8001a4:	83 ec 08             	sub    $0x8,%esp
  8001a7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001aa:	ff 75 e0             	pushl  -0x20(%ebp)
  8001ad:	ff 75 dc             	pushl  -0x24(%ebp)
  8001b0:	ff 75 d8             	pushl  -0x28(%ebp)
  8001b3:	e8 38 09 00 00       	call   800af0 <__udivdi3>
  8001b8:	83 c4 18             	add    $0x18,%esp
  8001bb:	52                   	push   %edx
  8001bc:	50                   	push   %eax
  8001bd:	89 f2                	mov    %esi,%edx
  8001bf:	89 f8                	mov    %edi,%eax
  8001c1:	e8 a1 ff ff ff       	call   800167 <printnum>
  8001c6:	83 c4 20             	add    $0x20,%esp
  8001c9:	eb 11                	jmp    8001dc <printnum+0x75>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001cb:	83 ec 08             	sub    $0x8,%esp
  8001ce:	56                   	push   %esi
  8001cf:	ff 75 18             	pushl  0x18(%ebp)
  8001d2:	ff d7                	call   *%edi
  8001d4:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8001d7:	4b                   	dec    %ebx
  8001d8:	85 db                	test   %ebx,%ebx
  8001da:	7f ef                	jg     8001cb <printnum+0x64>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8001dc:	83 ec 08             	sub    $0x8,%esp
  8001df:	56                   	push   %esi
  8001e0:	83 ec 04             	sub    $0x4,%esp
  8001e3:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001e6:	ff 75 e0             	pushl  -0x20(%ebp)
  8001e9:	ff 75 dc             	pushl  -0x24(%ebp)
  8001ec:	ff 75 d8             	pushl  -0x28(%ebp)
  8001ef:	e8 fc 09 00 00       	call   800bf0 <__umoddi3>
  8001f4:	83 c4 14             	add    $0x14,%esp
  8001f7:	0f be 80 40 0d 80 00 	movsbl 0x800d40(%eax),%eax
  8001fe:	50                   	push   %eax
  8001ff:	ff d7                	call   *%edi
}
  800201:	83 c4 10             	add    $0x10,%esp
  800204:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800207:	5b                   	pop    %ebx
  800208:	5e                   	pop    %esi
  800209:	5f                   	pop    %edi
  80020a:	5d                   	pop    %ebp
  80020b:	c3                   	ret    

0080020c <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80020c:	55                   	push   %ebp
  80020d:	89 e5                	mov    %esp,%ebp
  80020f:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800212:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800215:	8b 10                	mov    (%eax),%edx
  800217:	3b 50 04             	cmp    0x4(%eax),%edx
  80021a:	73 0a                	jae    800226 <sprintputch+0x1a>
		*b->buf++ = ch;
  80021c:	8d 4a 01             	lea    0x1(%edx),%ecx
  80021f:	89 08                	mov    %ecx,(%eax)
  800221:	8b 45 08             	mov    0x8(%ebp),%eax
  800224:	88 02                	mov    %al,(%edx)
}
  800226:	5d                   	pop    %ebp
  800227:	c3                   	ret    

00800228 <printfmt>:
{
  800228:	55                   	push   %ebp
  800229:	89 e5                	mov    %esp,%ebp
  80022b:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  80022e:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800231:	50                   	push   %eax
  800232:	ff 75 10             	pushl  0x10(%ebp)
  800235:	ff 75 0c             	pushl  0xc(%ebp)
  800238:	ff 75 08             	pushl  0x8(%ebp)
  80023b:	e8 05 00 00 00       	call   800245 <vprintfmt>
}
  800240:	83 c4 10             	add    $0x10,%esp
  800243:	c9                   	leave  
  800244:	c3                   	ret    

00800245 <vprintfmt>:
{
  800245:	55                   	push   %ebp
  800246:	89 e5                	mov    %esp,%ebp
  800248:	57                   	push   %edi
  800249:	56                   	push   %esi
  80024a:	53                   	push   %ebx
  80024b:	83 ec 3c             	sub    $0x3c,%esp
  80024e:	8b 75 08             	mov    0x8(%ebp),%esi
  800251:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800254:	8b 7d 10             	mov    0x10(%ebp),%edi
  800257:	e9 5b 03 00 00       	jmp    8005b7 <vprintfmt+0x372>
		padc = ' ';
  80025c:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  800260:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
		precision = -1;
  800267:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  80026e:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		lflag = 0;
  800275:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80027a:	8d 47 01             	lea    0x1(%edi),%eax
  80027d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800280:	8a 17                	mov    (%edi),%dl
  800282:	8d 42 dd             	lea    -0x23(%edx),%eax
  800285:	3c 55                	cmp    $0x55,%al
  800287:	0f 87 ab 03 00 00    	ja     800638 <vprintfmt+0x3f3>
  80028d:	0f b6 c0             	movzbl %al,%eax
  800290:	ff 24 85 d0 0d 80 00 	jmp    *0x800dd0(,%eax,4)
  800297:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  80029a:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  80029e:	eb da                	jmp    80027a <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  8002a0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8002a3:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  8002a7:	eb d1                	jmp    80027a <vprintfmt+0x35>
  8002a9:	0f b6 d2             	movzbl %dl,%edx
  8002ac:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  8002af:	b8 00 00 00 00       	mov    $0x0,%eax
  8002b4:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  8002b7:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8002ba:	01 c0                	add    %eax,%eax
  8002bc:	8d 44 02 d0          	lea    -0x30(%edx,%eax,1),%eax
				ch = *fmt;
  8002c0:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8002c3:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8002c6:	83 f9 09             	cmp    $0x9,%ecx
  8002c9:	77 52                	ja     80031d <vprintfmt+0xd8>
			for (precision = 0; ; ++fmt) {
  8002cb:	47                   	inc    %edi
				precision = precision * 10 + ch - '0';
  8002cc:	eb e9                	jmp    8002b7 <vprintfmt+0x72>
			precision = va_arg(ap, int);
  8002ce:	8b 45 14             	mov    0x14(%ebp),%eax
  8002d1:	8b 00                	mov    (%eax),%eax
  8002d3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002d6:	8b 45 14             	mov    0x14(%ebp),%eax
  8002d9:	8d 40 04             	lea    0x4(%eax),%eax
  8002dc:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8002df:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8002e2:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8002e6:	79 92                	jns    80027a <vprintfmt+0x35>
				width = precision, precision = -1;
  8002e8:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8002eb:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8002ee:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8002f5:	eb 83                	jmp    80027a <vprintfmt+0x35>
  8002f7:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8002fb:	78 08                	js     800305 <vprintfmt+0xc0>
		switch (ch = *(unsigned char *) fmt++) {
  8002fd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800300:	e9 75 ff ff ff       	jmp    80027a <vprintfmt+0x35>
  800305:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  80030c:	eb ef                	jmp    8002fd <vprintfmt+0xb8>
		switch (ch = *(unsigned char *) fmt++) {
  80030e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800311:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  800318:	e9 5d ff ff ff       	jmp    80027a <vprintfmt+0x35>
  80031d:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800320:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800323:	eb bd                	jmp    8002e2 <vprintfmt+0x9d>
			lflag++;
  800325:	41                   	inc    %ecx
		switch (ch = *(unsigned char *) fmt++) {
  800326:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800329:	e9 4c ff ff ff       	jmp    80027a <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
  80032e:	8b 45 14             	mov    0x14(%ebp),%eax
  800331:	8d 78 04             	lea    0x4(%eax),%edi
  800334:	83 ec 08             	sub    $0x8,%esp
  800337:	53                   	push   %ebx
  800338:	ff 30                	pushl  (%eax)
  80033a:	ff d6                	call   *%esi
			break;
  80033c:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  80033f:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800342:	e9 6d 02 00 00       	jmp    8005b4 <vprintfmt+0x36f>
			err = va_arg(ap, int);
  800347:	8b 45 14             	mov    0x14(%ebp),%eax
  80034a:	8d 78 04             	lea    0x4(%eax),%edi
  80034d:	8b 00                	mov    (%eax),%eax
  80034f:	85 c0                	test   %eax,%eax
  800351:	78 2a                	js     80037d <vprintfmt+0x138>
  800353:	89 c2                	mov    %eax,%edx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800355:	83 f8 06             	cmp    $0x6,%eax
  800358:	7f 27                	jg     800381 <vprintfmt+0x13c>
  80035a:	8b 04 85 28 0f 80 00 	mov    0x800f28(,%eax,4),%eax
  800361:	85 c0                	test   %eax,%eax
  800363:	74 1c                	je     800381 <vprintfmt+0x13c>
				printfmt(putch, putdat, "%s", p);
  800365:	50                   	push   %eax
  800366:	68 61 0d 80 00       	push   $0x800d61
  80036b:	53                   	push   %ebx
  80036c:	56                   	push   %esi
  80036d:	e8 b6 fe ff ff       	call   800228 <printfmt>
  800372:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800375:	89 7d 14             	mov    %edi,0x14(%ebp)
  800378:	e9 37 02 00 00       	jmp    8005b4 <vprintfmt+0x36f>
  80037d:	f7 d8                	neg    %eax
  80037f:	eb d2                	jmp    800353 <vprintfmt+0x10e>
				printfmt(putch, putdat, "error %d", err);
  800381:	52                   	push   %edx
  800382:	68 58 0d 80 00       	push   $0x800d58
  800387:	53                   	push   %ebx
  800388:	56                   	push   %esi
  800389:	e8 9a fe ff ff       	call   800228 <printfmt>
  80038e:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800391:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800394:	e9 1b 02 00 00       	jmp    8005b4 <vprintfmt+0x36f>
			if ((p = va_arg(ap, char *)) == NULL)
  800399:	8b 45 14             	mov    0x14(%ebp),%eax
  80039c:	83 c0 04             	add    $0x4,%eax
  80039f:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8003a2:	8b 45 14             	mov    0x14(%ebp),%eax
  8003a5:	8b 00                	mov    (%eax),%eax
  8003a7:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8003aa:	85 c0                	test   %eax,%eax
  8003ac:	74 19                	je     8003c7 <vprintfmt+0x182>
			if (width > 0 && padc != '-')
  8003ae:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8003b2:	7e 06                	jle    8003ba <vprintfmt+0x175>
  8003b4:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  8003b8:	75 16                	jne    8003d0 <vprintfmt+0x18b>
				for (width -= strnlen(p, precision); width > 0; width--)
  8003ba:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8003bd:	89 c7                	mov    %eax,%edi
  8003bf:	03 45 d4             	add    -0x2c(%ebp),%eax
  8003c2:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8003c5:	eb 62                	jmp    800429 <vprintfmt+0x1e4>
				p = "(null)";
  8003c7:	c7 45 cc 51 0d 80 00 	movl   $0x800d51,-0x34(%ebp)
  8003ce:	eb de                	jmp    8003ae <vprintfmt+0x169>
				for (width -= strnlen(p, precision); width > 0; width--)
  8003d0:	83 ec 08             	sub    $0x8,%esp
  8003d3:	ff 75 d8             	pushl  -0x28(%ebp)
  8003d6:	ff 75 cc             	pushl  -0x34(%ebp)
  8003d9:	e8 05 03 00 00       	call   8006e3 <strnlen>
  8003de:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8003e1:	29 c2                	sub    %eax,%edx
  8003e3:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  8003e6:	83 c4 10             	add    $0x10,%esp
  8003e9:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  8003eb:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8003ef:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8003f2:	eb 0d                	jmp    800401 <vprintfmt+0x1bc>
					putch(padc, putdat);
  8003f4:	83 ec 08             	sub    $0x8,%esp
  8003f7:	53                   	push   %ebx
  8003f8:	ff 75 d4             	pushl  -0x2c(%ebp)
  8003fb:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8003fd:	4f                   	dec    %edi
  8003fe:	83 c4 10             	add    $0x10,%esp
  800401:	85 ff                	test   %edi,%edi
  800403:	7f ef                	jg     8003f4 <vprintfmt+0x1af>
  800405:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800408:	89 d0                	mov    %edx,%eax
  80040a:	85 d2                	test   %edx,%edx
  80040c:	78 0a                	js     800418 <vprintfmt+0x1d3>
  80040e:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800411:	29 c2                	sub    %eax,%edx
  800413:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800416:	eb a2                	jmp    8003ba <vprintfmt+0x175>
  800418:	b8 00 00 00 00       	mov    $0x0,%eax
  80041d:	eb ef                	jmp    80040e <vprintfmt+0x1c9>
					putch(ch, putdat);
  80041f:	83 ec 08             	sub    $0x8,%esp
  800422:	53                   	push   %ebx
  800423:	52                   	push   %edx
  800424:	ff d6                	call   *%esi
  800426:	83 c4 10             	add    $0x10,%esp
  800429:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  80042c:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80042e:	47                   	inc    %edi
  80042f:	8a 47 ff             	mov    -0x1(%edi),%al
  800432:	0f be d0             	movsbl %al,%edx
  800435:	85 d2                	test   %edx,%edx
  800437:	74 48                	je     800481 <vprintfmt+0x23c>
  800439:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80043d:	78 05                	js     800444 <vprintfmt+0x1ff>
  80043f:	ff 4d d8             	decl   -0x28(%ebp)
  800442:	78 1e                	js     800462 <vprintfmt+0x21d>
				if (altflag && (ch < ' ' || ch > '~'))
  800444:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800448:	74 d5                	je     80041f <vprintfmt+0x1da>
  80044a:	0f be c0             	movsbl %al,%eax
  80044d:	83 e8 20             	sub    $0x20,%eax
  800450:	83 f8 5e             	cmp    $0x5e,%eax
  800453:	76 ca                	jbe    80041f <vprintfmt+0x1da>
					putch('?', putdat);
  800455:	83 ec 08             	sub    $0x8,%esp
  800458:	53                   	push   %ebx
  800459:	6a 3f                	push   $0x3f
  80045b:	ff d6                	call   *%esi
  80045d:	83 c4 10             	add    $0x10,%esp
  800460:	eb c7                	jmp    800429 <vprintfmt+0x1e4>
  800462:	89 cf                	mov    %ecx,%edi
  800464:	eb 0c                	jmp    800472 <vprintfmt+0x22d>
				putch(' ', putdat);
  800466:	83 ec 08             	sub    $0x8,%esp
  800469:	53                   	push   %ebx
  80046a:	6a 20                	push   $0x20
  80046c:	ff d6                	call   *%esi
			for (; width > 0; width--)
  80046e:	4f                   	dec    %edi
  80046f:	83 c4 10             	add    $0x10,%esp
  800472:	85 ff                	test   %edi,%edi
  800474:	7f f0                	jg     800466 <vprintfmt+0x221>
			if ((p = va_arg(ap, char *)) == NULL)
  800476:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800479:	89 45 14             	mov    %eax,0x14(%ebp)
  80047c:	e9 33 01 00 00       	jmp    8005b4 <vprintfmt+0x36f>
  800481:	89 cf                	mov    %ecx,%edi
  800483:	eb ed                	jmp    800472 <vprintfmt+0x22d>
	if (lflag >= 2)
  800485:	83 f9 01             	cmp    $0x1,%ecx
  800488:	7f 1b                	jg     8004a5 <vprintfmt+0x260>
	else if (lflag)
  80048a:	85 c9                	test   %ecx,%ecx
  80048c:	74 42                	je     8004d0 <vprintfmt+0x28b>
		return va_arg(*ap, long);
  80048e:	8b 45 14             	mov    0x14(%ebp),%eax
  800491:	8b 00                	mov    (%eax),%eax
  800493:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800496:	99                   	cltd   
  800497:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80049a:	8b 45 14             	mov    0x14(%ebp),%eax
  80049d:	8d 40 04             	lea    0x4(%eax),%eax
  8004a0:	89 45 14             	mov    %eax,0x14(%ebp)
  8004a3:	eb 17                	jmp    8004bc <vprintfmt+0x277>
		return va_arg(*ap, long long);
  8004a5:	8b 45 14             	mov    0x14(%ebp),%eax
  8004a8:	8b 50 04             	mov    0x4(%eax),%edx
  8004ab:	8b 00                	mov    (%eax),%eax
  8004ad:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004b0:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8004b3:	8b 45 14             	mov    0x14(%ebp),%eax
  8004b6:	8d 40 08             	lea    0x8(%eax),%eax
  8004b9:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  8004bc:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8004bf:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8004c2:	85 c9                	test   %ecx,%ecx
  8004c4:	78 21                	js     8004e7 <vprintfmt+0x2a2>
			base = 10;
  8004c6:	b8 0a 00 00 00       	mov    $0xa,%eax
  8004cb:	e9 ca 00 00 00       	jmp    80059a <vprintfmt+0x355>
		return va_arg(*ap, int);
  8004d0:	8b 45 14             	mov    0x14(%ebp),%eax
  8004d3:	8b 00                	mov    (%eax),%eax
  8004d5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004d8:	99                   	cltd   
  8004d9:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8004dc:	8b 45 14             	mov    0x14(%ebp),%eax
  8004df:	8d 40 04             	lea    0x4(%eax),%eax
  8004e2:	89 45 14             	mov    %eax,0x14(%ebp)
  8004e5:	eb d5                	jmp    8004bc <vprintfmt+0x277>
				putch('-', putdat);
  8004e7:	83 ec 08             	sub    $0x8,%esp
  8004ea:	53                   	push   %ebx
  8004eb:	6a 2d                	push   $0x2d
  8004ed:	ff d6                	call   *%esi
				num = -(long long) num;
  8004ef:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8004f2:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8004f5:	f7 da                	neg    %edx
  8004f7:	83 d1 00             	adc    $0x0,%ecx
  8004fa:	f7 d9                	neg    %ecx
  8004fc:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8004ff:	b8 0a 00 00 00       	mov    $0xa,%eax
  800504:	e9 91 00 00 00       	jmp    80059a <vprintfmt+0x355>
	if (lflag >= 2)
  800509:	83 f9 01             	cmp    $0x1,%ecx
  80050c:	7f 1b                	jg     800529 <vprintfmt+0x2e4>
	else if (lflag)
  80050e:	85 c9                	test   %ecx,%ecx
  800510:	74 2c                	je     80053e <vprintfmt+0x2f9>
		return va_arg(*ap, unsigned long);
  800512:	8b 45 14             	mov    0x14(%ebp),%eax
  800515:	8b 10                	mov    (%eax),%edx
  800517:	b9 00 00 00 00       	mov    $0x0,%ecx
  80051c:	8d 40 04             	lea    0x4(%eax),%eax
  80051f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800522:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  800527:	eb 71                	jmp    80059a <vprintfmt+0x355>
		return va_arg(*ap, unsigned long long);
  800529:	8b 45 14             	mov    0x14(%ebp),%eax
  80052c:	8b 10                	mov    (%eax),%edx
  80052e:	8b 48 04             	mov    0x4(%eax),%ecx
  800531:	8d 40 08             	lea    0x8(%eax),%eax
  800534:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800537:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  80053c:	eb 5c                	jmp    80059a <vprintfmt+0x355>
		return va_arg(*ap, unsigned int);
  80053e:	8b 45 14             	mov    0x14(%ebp),%eax
  800541:	8b 10                	mov    (%eax),%edx
  800543:	b9 00 00 00 00       	mov    $0x0,%ecx
  800548:	8d 40 04             	lea    0x4(%eax),%eax
  80054b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80054e:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  800553:	eb 45                	jmp    80059a <vprintfmt+0x355>
			putch('X', putdat);
  800555:	83 ec 08             	sub    $0x8,%esp
  800558:	53                   	push   %ebx
  800559:	6a 58                	push   $0x58
  80055b:	ff d6                	call   *%esi
			putch('X', putdat);
  80055d:	83 c4 08             	add    $0x8,%esp
  800560:	53                   	push   %ebx
  800561:	6a 58                	push   $0x58
  800563:	ff d6                	call   *%esi
			putch('X', putdat);
  800565:	83 c4 08             	add    $0x8,%esp
  800568:	53                   	push   %ebx
  800569:	6a 58                	push   $0x58
  80056b:	ff d6                	call   *%esi
			break;
  80056d:	83 c4 10             	add    $0x10,%esp
  800570:	eb 42                	jmp    8005b4 <vprintfmt+0x36f>
			putch('0', putdat);
  800572:	83 ec 08             	sub    $0x8,%esp
  800575:	53                   	push   %ebx
  800576:	6a 30                	push   $0x30
  800578:	ff d6                	call   *%esi
			putch('x', putdat);
  80057a:	83 c4 08             	add    $0x8,%esp
  80057d:	53                   	push   %ebx
  80057e:	6a 78                	push   $0x78
  800580:	ff d6                	call   *%esi
			num = (unsigned long long)
  800582:	8b 45 14             	mov    0x14(%ebp),%eax
  800585:	8b 10                	mov    (%eax),%edx
  800587:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  80058c:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  80058f:	8d 40 04             	lea    0x4(%eax),%eax
  800592:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800595:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  80059a:	83 ec 0c             	sub    $0xc,%esp
  80059d:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  8005a1:	57                   	push   %edi
  8005a2:	ff 75 d4             	pushl  -0x2c(%ebp)
  8005a5:	50                   	push   %eax
  8005a6:	51                   	push   %ecx
  8005a7:	52                   	push   %edx
  8005a8:	89 da                	mov    %ebx,%edx
  8005aa:	89 f0                	mov    %esi,%eax
  8005ac:	e8 b6 fb ff ff       	call   800167 <printnum>
			break;
  8005b1:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  8005b4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8005b7:	47                   	inc    %edi
  8005b8:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8005bc:	83 f8 25             	cmp    $0x25,%eax
  8005bf:	0f 84 97 fc ff ff    	je     80025c <vprintfmt+0x17>
			if (ch == '\0')
  8005c5:	85 c0                	test   %eax,%eax
  8005c7:	0f 84 89 00 00 00    	je     800656 <vprintfmt+0x411>
			putch(ch, putdat);
  8005cd:	83 ec 08             	sub    $0x8,%esp
  8005d0:	53                   	push   %ebx
  8005d1:	50                   	push   %eax
  8005d2:	ff d6                	call   *%esi
  8005d4:	83 c4 10             	add    $0x10,%esp
  8005d7:	eb de                	jmp    8005b7 <vprintfmt+0x372>
	if (lflag >= 2)
  8005d9:	83 f9 01             	cmp    $0x1,%ecx
  8005dc:	7f 1b                	jg     8005f9 <vprintfmt+0x3b4>
	else if (lflag)
  8005de:	85 c9                	test   %ecx,%ecx
  8005e0:	74 2c                	je     80060e <vprintfmt+0x3c9>
		return va_arg(*ap, unsigned long);
  8005e2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e5:	8b 10                	mov    (%eax),%edx
  8005e7:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005ec:	8d 40 04             	lea    0x4(%eax),%eax
  8005ef:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8005f2:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  8005f7:	eb a1                	jmp    80059a <vprintfmt+0x355>
		return va_arg(*ap, unsigned long long);
  8005f9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005fc:	8b 10                	mov    (%eax),%edx
  8005fe:	8b 48 04             	mov    0x4(%eax),%ecx
  800601:	8d 40 08             	lea    0x8(%eax),%eax
  800604:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800607:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  80060c:	eb 8c                	jmp    80059a <vprintfmt+0x355>
		return va_arg(*ap, unsigned int);
  80060e:	8b 45 14             	mov    0x14(%ebp),%eax
  800611:	8b 10                	mov    (%eax),%edx
  800613:	b9 00 00 00 00       	mov    $0x0,%ecx
  800618:	8d 40 04             	lea    0x4(%eax),%eax
  80061b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80061e:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  800623:	e9 72 ff ff ff       	jmp    80059a <vprintfmt+0x355>
			putch(ch, putdat);
  800628:	83 ec 08             	sub    $0x8,%esp
  80062b:	53                   	push   %ebx
  80062c:	6a 25                	push   $0x25
  80062e:	ff d6                	call   *%esi
			break;
  800630:	83 c4 10             	add    $0x10,%esp
  800633:	e9 7c ff ff ff       	jmp    8005b4 <vprintfmt+0x36f>
			putch('%', putdat);
  800638:	83 ec 08             	sub    $0x8,%esp
  80063b:	53                   	push   %ebx
  80063c:	6a 25                	push   $0x25
  80063e:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800640:	83 c4 10             	add    $0x10,%esp
  800643:	89 f8                	mov    %edi,%eax
  800645:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800649:	74 03                	je     80064e <vprintfmt+0x409>
  80064b:	48                   	dec    %eax
  80064c:	eb f7                	jmp    800645 <vprintfmt+0x400>
  80064e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800651:	e9 5e ff ff ff       	jmp    8005b4 <vprintfmt+0x36f>
}
  800656:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800659:	5b                   	pop    %ebx
  80065a:	5e                   	pop    %esi
  80065b:	5f                   	pop    %edi
  80065c:	5d                   	pop    %ebp
  80065d:	c3                   	ret    

0080065e <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80065e:	55                   	push   %ebp
  80065f:	89 e5                	mov    %esp,%ebp
  800661:	83 ec 18             	sub    $0x18,%esp
  800664:	8b 45 08             	mov    0x8(%ebp),%eax
  800667:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80066a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80066d:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800671:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800674:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80067b:	85 c0                	test   %eax,%eax
  80067d:	74 26                	je     8006a5 <vsnprintf+0x47>
  80067f:	85 d2                	test   %edx,%edx
  800681:	7e 29                	jle    8006ac <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800683:	ff 75 14             	pushl  0x14(%ebp)
  800686:	ff 75 10             	pushl  0x10(%ebp)
  800689:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80068c:	50                   	push   %eax
  80068d:	68 0c 02 80 00       	push   $0x80020c
  800692:	e8 ae fb ff ff       	call   800245 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800697:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80069a:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80069d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006a0:	83 c4 10             	add    $0x10,%esp
}
  8006a3:	c9                   	leave  
  8006a4:	c3                   	ret    
		return -E_INVAL;
  8006a5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8006aa:	eb f7                	jmp    8006a3 <vsnprintf+0x45>
  8006ac:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8006b1:	eb f0                	jmp    8006a3 <vsnprintf+0x45>

008006b3 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006b3:	55                   	push   %ebp
  8006b4:	89 e5                	mov    %esp,%ebp
  8006b6:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006b9:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006bc:	50                   	push   %eax
  8006bd:	ff 75 10             	pushl  0x10(%ebp)
  8006c0:	ff 75 0c             	pushl  0xc(%ebp)
  8006c3:	ff 75 08             	pushl  0x8(%ebp)
  8006c6:	e8 93 ff ff ff       	call   80065e <vsnprintf>
	va_end(ap);

	return rc;
}
  8006cb:	c9                   	leave  
  8006cc:	c3                   	ret    

008006cd <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006cd:	55                   	push   %ebp
  8006ce:	89 e5                	mov    %esp,%ebp
  8006d0:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006d3:	b8 00 00 00 00       	mov    $0x0,%eax
  8006d8:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8006dc:	74 03                	je     8006e1 <strlen+0x14>
		n++;
  8006de:	40                   	inc    %eax
  8006df:	eb f7                	jmp    8006d8 <strlen+0xb>
	return n;
}
  8006e1:	5d                   	pop    %ebp
  8006e2:	c3                   	ret    

008006e3 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8006e3:	55                   	push   %ebp
  8006e4:	89 e5                	mov    %esp,%ebp
  8006e6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006e9:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006ec:	b8 00 00 00 00       	mov    $0x0,%eax
  8006f1:	39 d0                	cmp    %edx,%eax
  8006f3:	74 0b                	je     800700 <strnlen+0x1d>
  8006f5:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8006f9:	74 03                	je     8006fe <strnlen+0x1b>
		n++;
  8006fb:	40                   	inc    %eax
  8006fc:	eb f3                	jmp    8006f1 <strnlen+0xe>
  8006fe:	89 c2                	mov    %eax,%edx
	return n;
}
  800700:	89 d0                	mov    %edx,%eax
  800702:	5d                   	pop    %ebp
  800703:	c3                   	ret    

00800704 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800704:	55                   	push   %ebp
  800705:	89 e5                	mov    %esp,%ebp
  800707:	53                   	push   %ebx
  800708:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80070b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80070e:	b8 00 00 00 00       	mov    $0x0,%eax
  800713:	8a 14 03             	mov    (%ebx,%eax,1),%dl
  800716:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800719:	40                   	inc    %eax
  80071a:	84 d2                	test   %dl,%dl
  80071c:	75 f5                	jne    800713 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  80071e:	89 c8                	mov    %ecx,%eax
  800720:	5b                   	pop    %ebx
  800721:	5d                   	pop    %ebp
  800722:	c3                   	ret    

00800723 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800723:	55                   	push   %ebp
  800724:	89 e5                	mov    %esp,%ebp
  800726:	53                   	push   %ebx
  800727:	83 ec 10             	sub    $0x10,%esp
  80072a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80072d:	53                   	push   %ebx
  80072e:	e8 9a ff ff ff       	call   8006cd <strlen>
  800733:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800736:	ff 75 0c             	pushl  0xc(%ebp)
  800739:	01 d8                	add    %ebx,%eax
  80073b:	50                   	push   %eax
  80073c:	e8 c3 ff ff ff       	call   800704 <strcpy>
	return dst;
}
  800741:	89 d8                	mov    %ebx,%eax
  800743:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800746:	c9                   	leave  
  800747:	c3                   	ret    

00800748 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800748:	55                   	push   %ebp
  800749:	89 e5                	mov    %esp,%ebp
  80074b:	53                   	push   %ebx
  80074c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80074f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800752:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800755:	8b 45 08             	mov    0x8(%ebp),%eax
  800758:	39 d8                	cmp    %ebx,%eax
  80075a:	74 0e                	je     80076a <strncpy+0x22>
		*dst++ = *src;
  80075c:	40                   	inc    %eax
  80075d:	8a 0a                	mov    (%edx),%cl
  80075f:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800762:	80 f9 01             	cmp    $0x1,%cl
  800765:	83 da ff             	sbb    $0xffffffff,%edx
  800768:	eb ee                	jmp    800758 <strncpy+0x10>
	}
	return ret;
}
  80076a:	8b 45 08             	mov    0x8(%ebp),%eax
  80076d:	5b                   	pop    %ebx
  80076e:	5d                   	pop    %ebp
  80076f:	c3                   	ret    

00800770 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800770:	55                   	push   %ebp
  800771:	89 e5                	mov    %esp,%ebp
  800773:	56                   	push   %esi
  800774:	53                   	push   %ebx
  800775:	8b 75 08             	mov    0x8(%ebp),%esi
  800778:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80077b:	8b 45 10             	mov    0x10(%ebp),%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80077e:	85 c0                	test   %eax,%eax
  800780:	74 22                	je     8007a4 <strlcpy+0x34>
  800782:	8d 44 06 ff          	lea    -0x1(%esi,%eax,1),%eax
  800786:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  800788:	39 c2                	cmp    %eax,%edx
  80078a:	74 0f                	je     80079b <strlcpy+0x2b>
  80078c:	8a 19                	mov    (%ecx),%bl
  80078e:	84 db                	test   %bl,%bl
  800790:	74 07                	je     800799 <strlcpy+0x29>
			*dst++ = *src++;
  800792:	41                   	inc    %ecx
  800793:	42                   	inc    %edx
  800794:	88 5a ff             	mov    %bl,-0x1(%edx)
  800797:	eb ef                	jmp    800788 <strlcpy+0x18>
  800799:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  80079b:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80079e:	29 f0                	sub    %esi,%eax
}
  8007a0:	5b                   	pop    %ebx
  8007a1:	5e                   	pop    %esi
  8007a2:	5d                   	pop    %ebp
  8007a3:	c3                   	ret    
  8007a4:	89 f0                	mov    %esi,%eax
  8007a6:	eb f6                	jmp    80079e <strlcpy+0x2e>

008007a8 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007a8:	55                   	push   %ebp
  8007a9:	89 e5                	mov    %esp,%ebp
  8007ab:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007ae:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007b1:	8a 01                	mov    (%ecx),%al
  8007b3:	84 c0                	test   %al,%al
  8007b5:	74 08                	je     8007bf <strcmp+0x17>
  8007b7:	3a 02                	cmp    (%edx),%al
  8007b9:	75 04                	jne    8007bf <strcmp+0x17>
		p++, q++;
  8007bb:	41                   	inc    %ecx
  8007bc:	42                   	inc    %edx
  8007bd:	eb f2                	jmp    8007b1 <strcmp+0x9>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007bf:	0f b6 c0             	movzbl %al,%eax
  8007c2:	0f b6 12             	movzbl (%edx),%edx
  8007c5:	29 d0                	sub    %edx,%eax
}
  8007c7:	5d                   	pop    %ebp
  8007c8:	c3                   	ret    

008007c9 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8007c9:	55                   	push   %ebp
  8007ca:	89 e5                	mov    %esp,%ebp
  8007cc:	53                   	push   %ebx
  8007cd:	8b 45 08             	mov    0x8(%ebp),%eax
  8007d0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007d3:	89 c3                	mov    %eax,%ebx
  8007d5:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8007d8:	eb 02                	jmp    8007dc <strncmp+0x13>
		n--, p++, q++;
  8007da:	40                   	inc    %eax
  8007db:	42                   	inc    %edx
	while (n > 0 && *p && *p == *q)
  8007dc:	39 d8                	cmp    %ebx,%eax
  8007de:	74 15                	je     8007f5 <strncmp+0x2c>
  8007e0:	8a 08                	mov    (%eax),%cl
  8007e2:	84 c9                	test   %cl,%cl
  8007e4:	74 04                	je     8007ea <strncmp+0x21>
  8007e6:	3a 0a                	cmp    (%edx),%cl
  8007e8:	74 f0                	je     8007da <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8007ea:	0f b6 00             	movzbl (%eax),%eax
  8007ed:	0f b6 12             	movzbl (%edx),%edx
  8007f0:	29 d0                	sub    %edx,%eax
}
  8007f2:	5b                   	pop    %ebx
  8007f3:	5d                   	pop    %ebp
  8007f4:	c3                   	ret    
		return 0;
  8007f5:	b8 00 00 00 00       	mov    $0x0,%eax
  8007fa:	eb f6                	jmp    8007f2 <strncmp+0x29>

008007fc <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8007fc:	55                   	push   %ebp
  8007fd:	89 e5                	mov    %esp,%ebp
  8007ff:	8b 45 08             	mov    0x8(%ebp),%eax
  800802:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800805:	8a 10                	mov    (%eax),%dl
  800807:	84 d2                	test   %dl,%dl
  800809:	74 07                	je     800812 <strchr+0x16>
		if (*s == c)
  80080b:	38 ca                	cmp    %cl,%dl
  80080d:	74 08                	je     800817 <strchr+0x1b>
	for (; *s; s++)
  80080f:	40                   	inc    %eax
  800810:	eb f3                	jmp    800805 <strchr+0x9>
			return (char *) s;
	return 0;
  800812:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800817:	5d                   	pop    %ebp
  800818:	c3                   	ret    

00800819 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800819:	55                   	push   %ebp
  80081a:	89 e5                	mov    %esp,%ebp
  80081c:	8b 45 08             	mov    0x8(%ebp),%eax
  80081f:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800822:	8a 10                	mov    (%eax),%dl
  800824:	84 d2                	test   %dl,%dl
  800826:	74 07                	je     80082f <strfind+0x16>
		if (*s == c)
  800828:	38 ca                	cmp    %cl,%dl
  80082a:	74 03                	je     80082f <strfind+0x16>
	for (; *s; s++)
  80082c:	40                   	inc    %eax
  80082d:	eb f3                	jmp    800822 <strfind+0x9>
			break;
	return (char *) s;
}
  80082f:	5d                   	pop    %ebp
  800830:	c3                   	ret    

00800831 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800831:	55                   	push   %ebp
  800832:	89 e5                	mov    %esp,%ebp
  800834:	57                   	push   %edi
  800835:	56                   	push   %esi
  800836:	53                   	push   %ebx
  800837:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80083a:	85 c9                	test   %ecx,%ecx
  80083c:	74 36                	je     800874 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80083e:	89 c8                	mov    %ecx,%eax
  800840:	0b 45 08             	or     0x8(%ebp),%eax
  800843:	a8 03                	test   $0x3,%al
  800845:	75 24                	jne    80086b <memset+0x3a>
		c &= 0xFF;
  800847:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80084b:	89 d3                	mov    %edx,%ebx
  80084d:	c1 e3 08             	shl    $0x8,%ebx
  800850:	89 d0                	mov    %edx,%eax
  800852:	c1 e0 18             	shl    $0x18,%eax
  800855:	89 d6                	mov    %edx,%esi
  800857:	c1 e6 10             	shl    $0x10,%esi
  80085a:	09 f0                	or     %esi,%eax
  80085c:	09 d0                	or     %edx,%eax
  80085e:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800860:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800863:	8b 7d 08             	mov    0x8(%ebp),%edi
  800866:	fc                   	cld    
  800867:	f3 ab                	rep stos %eax,%es:(%edi)
  800869:	eb 09                	jmp    800874 <memset+0x43>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80086b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80086e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800871:	fc                   	cld    
  800872:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800874:	8b 45 08             	mov    0x8(%ebp),%eax
  800877:	5b                   	pop    %ebx
  800878:	5e                   	pop    %esi
  800879:	5f                   	pop    %edi
  80087a:	5d                   	pop    %ebp
  80087b:	c3                   	ret    

0080087c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80087c:	55                   	push   %ebp
  80087d:	89 e5                	mov    %esp,%ebp
  80087f:	57                   	push   %edi
  800880:	56                   	push   %esi
  800881:	8b 45 08             	mov    0x8(%ebp),%eax
  800884:	8b 75 0c             	mov    0xc(%ebp),%esi
  800887:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80088a:	39 c6                	cmp    %eax,%esi
  80088c:	73 30                	jae    8008be <memmove+0x42>
  80088e:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800891:	39 c2                	cmp    %eax,%edx
  800893:	76 29                	jbe    8008be <memmove+0x42>
		s += n;
		d += n;
  800895:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800898:	89 fe                	mov    %edi,%esi
  80089a:	09 ce                	or     %ecx,%esi
  80089c:	09 d6                	or     %edx,%esi
  80089e:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008a4:	75 0e                	jne    8008b4 <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8008a6:	83 ef 04             	sub    $0x4,%edi
  8008a9:	8d 72 fc             	lea    -0x4(%edx),%esi
  8008ac:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  8008af:	fd                   	std    
  8008b0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008b2:	eb 07                	jmp    8008bb <memmove+0x3f>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8008b4:	4f                   	dec    %edi
  8008b5:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  8008b8:	fd                   	std    
  8008b9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8008bb:	fc                   	cld    
  8008bc:	eb 1a                	jmp    8008d8 <memmove+0x5c>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008be:	89 c2                	mov    %eax,%edx
  8008c0:	09 ca                	or     %ecx,%edx
  8008c2:	09 f2                	or     %esi,%edx
  8008c4:	f6 c2 03             	test   $0x3,%dl
  8008c7:	75 0a                	jne    8008d3 <memmove+0x57>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8008c9:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  8008cc:	89 c7                	mov    %eax,%edi
  8008ce:	fc                   	cld    
  8008cf:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008d1:	eb 05                	jmp    8008d8 <memmove+0x5c>
		else
			asm volatile("cld; rep movsb\n"
  8008d3:	89 c7                	mov    %eax,%edi
  8008d5:	fc                   	cld    
  8008d6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8008d8:	5e                   	pop    %esi
  8008d9:	5f                   	pop    %edi
  8008da:	5d                   	pop    %ebp
  8008db:	c3                   	ret    

008008dc <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8008dc:	55                   	push   %ebp
  8008dd:	89 e5                	mov    %esp,%ebp
  8008df:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8008e2:	ff 75 10             	pushl  0x10(%ebp)
  8008e5:	ff 75 0c             	pushl  0xc(%ebp)
  8008e8:	ff 75 08             	pushl  0x8(%ebp)
  8008eb:	e8 8c ff ff ff       	call   80087c <memmove>
}
  8008f0:	c9                   	leave  
  8008f1:	c3                   	ret    

008008f2 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8008f2:	55                   	push   %ebp
  8008f3:	89 e5                	mov    %esp,%ebp
  8008f5:	56                   	push   %esi
  8008f6:	53                   	push   %ebx
  8008f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8008fa:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008fd:	89 c6                	mov    %eax,%esi
  8008ff:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800902:	39 f0                	cmp    %esi,%eax
  800904:	74 16                	je     80091c <memcmp+0x2a>
		if (*s1 != *s2)
  800906:	8a 08                	mov    (%eax),%cl
  800908:	8a 1a                	mov    (%edx),%bl
  80090a:	38 d9                	cmp    %bl,%cl
  80090c:	75 04                	jne    800912 <memcmp+0x20>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  80090e:	40                   	inc    %eax
  80090f:	42                   	inc    %edx
  800910:	eb f0                	jmp    800902 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800912:	0f b6 c1             	movzbl %cl,%eax
  800915:	0f b6 db             	movzbl %bl,%ebx
  800918:	29 d8                	sub    %ebx,%eax
  80091a:	eb 05                	jmp    800921 <memcmp+0x2f>
	}

	return 0;
  80091c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800921:	5b                   	pop    %ebx
  800922:	5e                   	pop    %esi
  800923:	5d                   	pop    %ebp
  800924:	c3                   	ret    

00800925 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800925:	55                   	push   %ebp
  800926:	89 e5                	mov    %esp,%ebp
  800928:	8b 45 08             	mov    0x8(%ebp),%eax
  80092b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  80092e:	89 c2                	mov    %eax,%edx
  800930:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800933:	39 d0                	cmp    %edx,%eax
  800935:	73 07                	jae    80093e <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
  800937:	38 08                	cmp    %cl,(%eax)
  800939:	74 03                	je     80093e <memfind+0x19>
	for (; s < ends; s++)
  80093b:	40                   	inc    %eax
  80093c:	eb f5                	jmp    800933 <memfind+0xe>
			break;
	return (void *) s;
}
  80093e:	5d                   	pop    %ebp
  80093f:	c3                   	ret    

00800940 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800940:	55                   	push   %ebp
  800941:	89 e5                	mov    %esp,%ebp
  800943:	57                   	push   %edi
  800944:	56                   	push   %esi
  800945:	53                   	push   %ebx
  800946:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800949:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80094c:	eb 01                	jmp    80094f <strtol+0xf>
		s++;
  80094e:	41                   	inc    %ecx
	while (*s == ' ' || *s == '\t')
  80094f:	8a 01                	mov    (%ecx),%al
  800951:	3c 20                	cmp    $0x20,%al
  800953:	74 f9                	je     80094e <strtol+0xe>
  800955:	3c 09                	cmp    $0x9,%al
  800957:	74 f5                	je     80094e <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800959:	3c 2b                	cmp    $0x2b,%al
  80095b:	74 24                	je     800981 <strtol+0x41>
		s++;
	else if (*s == '-')
  80095d:	3c 2d                	cmp    $0x2d,%al
  80095f:	74 28                	je     800989 <strtol+0x49>
	int neg = 0;
  800961:	bf 00 00 00 00       	mov    $0x0,%edi
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800966:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  80096c:	75 09                	jne    800977 <strtol+0x37>
  80096e:	80 39 30             	cmpb   $0x30,(%ecx)
  800971:	74 1e                	je     800991 <strtol+0x51>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800973:	85 db                	test   %ebx,%ebx
  800975:	74 36                	je     8009ad <strtol+0x6d>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800977:	b8 00 00 00 00       	mov    $0x0,%eax
  80097c:	89 5d 10             	mov    %ebx,0x10(%ebp)
  80097f:	eb 45                	jmp    8009c6 <strtol+0x86>
		s++;
  800981:	41                   	inc    %ecx
	int neg = 0;
  800982:	bf 00 00 00 00       	mov    $0x0,%edi
  800987:	eb dd                	jmp    800966 <strtol+0x26>
		s++, neg = 1;
  800989:	41                   	inc    %ecx
  80098a:	bf 01 00 00 00       	mov    $0x1,%edi
  80098f:	eb d5                	jmp    800966 <strtol+0x26>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800991:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800995:	74 0c                	je     8009a3 <strtol+0x63>
	else if (base == 0 && s[0] == '0')
  800997:	85 db                	test   %ebx,%ebx
  800999:	75 dc                	jne    800977 <strtol+0x37>
		s++, base = 8;
  80099b:	41                   	inc    %ecx
  80099c:	bb 08 00 00 00       	mov    $0x8,%ebx
  8009a1:	eb d4                	jmp    800977 <strtol+0x37>
		s += 2, base = 16;
  8009a3:	83 c1 02             	add    $0x2,%ecx
  8009a6:	bb 10 00 00 00       	mov    $0x10,%ebx
  8009ab:	eb ca                	jmp    800977 <strtol+0x37>
		base = 10;
  8009ad:	bb 0a 00 00 00       	mov    $0xa,%ebx
  8009b2:	eb c3                	jmp    800977 <strtol+0x37>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  8009b4:	0f be d2             	movsbl %dl,%edx
  8009b7:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  8009ba:	3b 55 10             	cmp    0x10(%ebp),%edx
  8009bd:	7d 37                	jge    8009f6 <strtol+0xb6>
			break;
		s++, val = (val * base) + dig;
  8009bf:	41                   	inc    %ecx
  8009c0:	0f af 45 10          	imul   0x10(%ebp),%eax
  8009c4:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  8009c6:	8a 11                	mov    (%ecx),%dl
  8009c8:	8d 72 d0             	lea    -0x30(%edx),%esi
  8009cb:	89 f3                	mov    %esi,%ebx
  8009cd:	80 fb 09             	cmp    $0x9,%bl
  8009d0:	76 e2                	jbe    8009b4 <strtol+0x74>
		else if (*s >= 'a' && *s <= 'z')
  8009d2:	8d 72 9f             	lea    -0x61(%edx),%esi
  8009d5:	89 f3                	mov    %esi,%ebx
  8009d7:	80 fb 19             	cmp    $0x19,%bl
  8009da:	77 08                	ja     8009e4 <strtol+0xa4>
			dig = *s - 'a' + 10;
  8009dc:	0f be d2             	movsbl %dl,%edx
  8009df:	83 ea 57             	sub    $0x57,%edx
  8009e2:	eb d6                	jmp    8009ba <strtol+0x7a>
		else if (*s >= 'A' && *s <= 'Z')
  8009e4:	8d 72 bf             	lea    -0x41(%edx),%esi
  8009e7:	89 f3                	mov    %esi,%ebx
  8009e9:	80 fb 19             	cmp    $0x19,%bl
  8009ec:	77 08                	ja     8009f6 <strtol+0xb6>
			dig = *s - 'A' + 10;
  8009ee:	0f be d2             	movsbl %dl,%edx
  8009f1:	83 ea 37             	sub    $0x37,%edx
  8009f4:	eb c4                	jmp    8009ba <strtol+0x7a>
		// we don't properly detect overflow!
	}

	if (endptr)
  8009f6:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8009fa:	74 05                	je     800a01 <strtol+0xc1>
		*endptr = (char *) s;
  8009fc:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009ff:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800a01:	85 ff                	test   %edi,%edi
  800a03:	74 02                	je     800a07 <strtol+0xc7>
  800a05:	f7 d8                	neg    %eax
}
  800a07:	5b                   	pop    %ebx
  800a08:	5e                   	pop    %esi
  800a09:	5f                   	pop    %edi
  800a0a:	5d                   	pop    %ebp
  800a0b:	c3                   	ret    

00800a0c <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a0c:	55                   	push   %ebp
  800a0d:	89 e5                	mov    %esp,%ebp
  800a0f:	57                   	push   %edi
  800a10:	56                   	push   %esi
  800a11:	53                   	push   %ebx
	asm volatile("int %1\n"
  800a12:	b8 00 00 00 00       	mov    $0x0,%eax
  800a17:	8b 55 08             	mov    0x8(%ebp),%edx
  800a1a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a1d:	89 c3                	mov    %eax,%ebx
  800a1f:	89 c7                	mov    %eax,%edi
  800a21:	89 c6                	mov    %eax,%esi
  800a23:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a25:	5b                   	pop    %ebx
  800a26:	5e                   	pop    %esi
  800a27:	5f                   	pop    %edi
  800a28:	5d                   	pop    %ebp
  800a29:	c3                   	ret    

00800a2a <sys_cgetc>:

int
sys_cgetc(void)
{
  800a2a:	55                   	push   %ebp
  800a2b:	89 e5                	mov    %esp,%ebp
  800a2d:	57                   	push   %edi
  800a2e:	56                   	push   %esi
  800a2f:	53                   	push   %ebx
	asm volatile("int %1\n"
  800a30:	ba 00 00 00 00       	mov    $0x0,%edx
  800a35:	b8 01 00 00 00       	mov    $0x1,%eax
  800a3a:	89 d1                	mov    %edx,%ecx
  800a3c:	89 d3                	mov    %edx,%ebx
  800a3e:	89 d7                	mov    %edx,%edi
  800a40:	89 d6                	mov    %edx,%esi
  800a42:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800a44:	5b                   	pop    %ebx
  800a45:	5e                   	pop    %esi
  800a46:	5f                   	pop    %edi
  800a47:	5d                   	pop    %ebp
  800a48:	c3                   	ret    

00800a49 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800a49:	55                   	push   %ebp
  800a4a:	89 e5                	mov    %esp,%ebp
  800a4c:	57                   	push   %edi
  800a4d:	56                   	push   %esi
  800a4e:	53                   	push   %ebx
  800a4f:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800a52:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a57:	8b 55 08             	mov    0x8(%ebp),%edx
  800a5a:	b8 03 00 00 00       	mov    $0x3,%eax
  800a5f:	89 cb                	mov    %ecx,%ebx
  800a61:	89 cf                	mov    %ecx,%edi
  800a63:	89 ce                	mov    %ecx,%esi
  800a65:	cd 30                	int    $0x30
	if(check && ret > 0)
  800a67:	85 c0                	test   %eax,%eax
  800a69:	7f 08                	jg     800a73 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800a6b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a6e:	5b                   	pop    %ebx
  800a6f:	5e                   	pop    %esi
  800a70:	5f                   	pop    %edi
  800a71:	5d                   	pop    %ebp
  800a72:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800a73:	83 ec 0c             	sub    $0xc,%esp
  800a76:	50                   	push   %eax
  800a77:	6a 03                	push   $0x3
  800a79:	68 44 0f 80 00       	push   $0x800f44
  800a7e:	6a 23                	push   $0x23
  800a80:	68 61 0f 80 00       	push   $0x800f61
  800a85:	e8 1f 00 00 00       	call   800aa9 <_panic>

00800a8a <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800a8a:	55                   	push   %ebp
  800a8b:	89 e5                	mov    %esp,%ebp
  800a8d:	57                   	push   %edi
  800a8e:	56                   	push   %esi
  800a8f:	53                   	push   %ebx
	asm volatile("int %1\n"
  800a90:	ba 00 00 00 00       	mov    $0x0,%edx
  800a95:	b8 02 00 00 00       	mov    $0x2,%eax
  800a9a:	89 d1                	mov    %edx,%ecx
  800a9c:	89 d3                	mov    %edx,%ebx
  800a9e:	89 d7                	mov    %edx,%edi
  800aa0:	89 d6                	mov    %edx,%esi
  800aa2:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800aa4:	5b                   	pop    %ebx
  800aa5:	5e                   	pop    %esi
  800aa6:	5f                   	pop    %edi
  800aa7:	5d                   	pop    %ebp
  800aa8:	c3                   	ret    

00800aa9 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800aa9:	55                   	push   %ebp
  800aaa:	89 e5                	mov    %esp,%ebp
  800aac:	56                   	push   %esi
  800aad:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800aae:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800ab1:	8b 35 00 10 80 00    	mov    0x801000,%esi
  800ab7:	e8 ce ff ff ff       	call   800a8a <sys_getenvid>
  800abc:	83 ec 0c             	sub    $0xc,%esp
  800abf:	ff 75 0c             	pushl  0xc(%ebp)
  800ac2:	ff 75 08             	pushl  0x8(%ebp)
  800ac5:	56                   	push   %esi
  800ac6:	50                   	push   %eax
  800ac7:	68 70 0f 80 00       	push   $0x800f70
  800acc:	e8 82 f6 ff ff       	call   800153 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800ad1:	83 c4 18             	add    $0x18,%esp
  800ad4:	53                   	push   %ebx
  800ad5:	ff 75 10             	pushl  0x10(%ebp)
  800ad8:	e8 25 f6 ff ff       	call   800102 <vcprintf>
	cprintf("\n");
  800add:	c7 04 24 34 0d 80 00 	movl   $0x800d34,(%esp)
  800ae4:	e8 6a f6 ff ff       	call   800153 <cprintf>
  800ae9:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800aec:	cc                   	int3   
  800aed:	eb fd                	jmp    800aec <_panic+0x43>
  800aef:	90                   	nop

00800af0 <__udivdi3>:
  800af0:	55                   	push   %ebp
  800af1:	57                   	push   %edi
  800af2:	56                   	push   %esi
  800af3:	53                   	push   %ebx
  800af4:	83 ec 1c             	sub    $0x1c,%esp
  800af7:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800afb:	8b 74 24 34          	mov    0x34(%esp),%esi
  800aff:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800b03:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800b07:	85 d2                	test   %edx,%edx
  800b09:	75 19                	jne    800b24 <__udivdi3+0x34>
  800b0b:	39 f7                	cmp    %esi,%edi
  800b0d:	76 45                	jbe    800b54 <__udivdi3+0x64>
  800b0f:	89 e8                	mov    %ebp,%eax
  800b11:	89 f2                	mov    %esi,%edx
  800b13:	f7 f7                	div    %edi
  800b15:	31 db                	xor    %ebx,%ebx
  800b17:	89 da                	mov    %ebx,%edx
  800b19:	83 c4 1c             	add    $0x1c,%esp
  800b1c:	5b                   	pop    %ebx
  800b1d:	5e                   	pop    %esi
  800b1e:	5f                   	pop    %edi
  800b1f:	5d                   	pop    %ebp
  800b20:	c3                   	ret    
  800b21:	8d 76 00             	lea    0x0(%esi),%esi
  800b24:	39 f2                	cmp    %esi,%edx
  800b26:	76 10                	jbe    800b38 <__udivdi3+0x48>
  800b28:	31 db                	xor    %ebx,%ebx
  800b2a:	31 c0                	xor    %eax,%eax
  800b2c:	89 da                	mov    %ebx,%edx
  800b2e:	83 c4 1c             	add    $0x1c,%esp
  800b31:	5b                   	pop    %ebx
  800b32:	5e                   	pop    %esi
  800b33:	5f                   	pop    %edi
  800b34:	5d                   	pop    %ebp
  800b35:	c3                   	ret    
  800b36:	66 90                	xchg   %ax,%ax
  800b38:	0f bd da             	bsr    %edx,%ebx
  800b3b:	83 f3 1f             	xor    $0x1f,%ebx
  800b3e:	75 3c                	jne    800b7c <__udivdi3+0x8c>
  800b40:	39 f2                	cmp    %esi,%edx
  800b42:	72 08                	jb     800b4c <__udivdi3+0x5c>
  800b44:	39 ef                	cmp    %ebp,%edi
  800b46:	0f 87 9c 00 00 00    	ja     800be8 <__udivdi3+0xf8>
  800b4c:	b8 01 00 00 00       	mov    $0x1,%eax
  800b51:	eb d9                	jmp    800b2c <__udivdi3+0x3c>
  800b53:	90                   	nop
  800b54:	89 f9                	mov    %edi,%ecx
  800b56:	85 ff                	test   %edi,%edi
  800b58:	75 0b                	jne    800b65 <__udivdi3+0x75>
  800b5a:	b8 01 00 00 00       	mov    $0x1,%eax
  800b5f:	31 d2                	xor    %edx,%edx
  800b61:	f7 f7                	div    %edi
  800b63:	89 c1                	mov    %eax,%ecx
  800b65:	31 d2                	xor    %edx,%edx
  800b67:	89 f0                	mov    %esi,%eax
  800b69:	f7 f1                	div    %ecx
  800b6b:	89 c3                	mov    %eax,%ebx
  800b6d:	89 e8                	mov    %ebp,%eax
  800b6f:	f7 f1                	div    %ecx
  800b71:	89 da                	mov    %ebx,%edx
  800b73:	83 c4 1c             	add    $0x1c,%esp
  800b76:	5b                   	pop    %ebx
  800b77:	5e                   	pop    %esi
  800b78:	5f                   	pop    %edi
  800b79:	5d                   	pop    %ebp
  800b7a:	c3                   	ret    
  800b7b:	90                   	nop
  800b7c:	b8 20 00 00 00       	mov    $0x20,%eax
  800b81:	29 d8                	sub    %ebx,%eax
  800b83:	88 d9                	mov    %bl,%cl
  800b85:	d3 e2                	shl    %cl,%edx
  800b87:	89 54 24 08          	mov    %edx,0x8(%esp)
  800b8b:	89 fa                	mov    %edi,%edx
  800b8d:	88 c1                	mov    %al,%cl
  800b8f:	d3 ea                	shr    %cl,%edx
  800b91:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800b95:	09 d1                	or     %edx,%ecx
  800b97:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800b9b:	88 d9                	mov    %bl,%cl
  800b9d:	d3 e7                	shl    %cl,%edi
  800b9f:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800ba3:	89 f7                	mov    %esi,%edi
  800ba5:	88 c1                	mov    %al,%cl
  800ba7:	d3 ef                	shr    %cl,%edi
  800ba9:	88 d9                	mov    %bl,%cl
  800bab:	d3 e6                	shl    %cl,%esi
  800bad:	89 ea                	mov    %ebp,%edx
  800baf:	88 c1                	mov    %al,%cl
  800bb1:	d3 ea                	shr    %cl,%edx
  800bb3:	09 d6                	or     %edx,%esi
  800bb5:	89 f0                	mov    %esi,%eax
  800bb7:	89 fa                	mov    %edi,%edx
  800bb9:	f7 74 24 08          	divl   0x8(%esp)
  800bbd:	89 d7                	mov    %edx,%edi
  800bbf:	89 c6                	mov    %eax,%esi
  800bc1:	f7 64 24 0c          	mull   0xc(%esp)
  800bc5:	39 d7                	cmp    %edx,%edi
  800bc7:	72 13                	jb     800bdc <__udivdi3+0xec>
  800bc9:	74 09                	je     800bd4 <__udivdi3+0xe4>
  800bcb:	89 f0                	mov    %esi,%eax
  800bcd:	31 db                	xor    %ebx,%ebx
  800bcf:	e9 58 ff ff ff       	jmp    800b2c <__udivdi3+0x3c>
  800bd4:	88 d9                	mov    %bl,%cl
  800bd6:	d3 e5                	shl    %cl,%ebp
  800bd8:	39 c5                	cmp    %eax,%ebp
  800bda:	73 ef                	jae    800bcb <__udivdi3+0xdb>
  800bdc:	8d 46 ff             	lea    -0x1(%esi),%eax
  800bdf:	31 db                	xor    %ebx,%ebx
  800be1:	e9 46 ff ff ff       	jmp    800b2c <__udivdi3+0x3c>
  800be6:	66 90                	xchg   %ax,%ax
  800be8:	31 c0                	xor    %eax,%eax
  800bea:	e9 3d ff ff ff       	jmp    800b2c <__udivdi3+0x3c>
  800bef:	90                   	nop

00800bf0 <__umoddi3>:
  800bf0:	55                   	push   %ebp
  800bf1:	57                   	push   %edi
  800bf2:	56                   	push   %esi
  800bf3:	53                   	push   %ebx
  800bf4:	83 ec 1c             	sub    $0x1c,%esp
  800bf7:	8b 74 24 30          	mov    0x30(%esp),%esi
  800bfb:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800bff:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800c03:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  800c07:	85 c0                	test   %eax,%eax
  800c09:	75 19                	jne    800c24 <__umoddi3+0x34>
  800c0b:	39 df                	cmp    %ebx,%edi
  800c0d:	76 51                	jbe    800c60 <__umoddi3+0x70>
  800c0f:	89 f0                	mov    %esi,%eax
  800c11:	89 da                	mov    %ebx,%edx
  800c13:	f7 f7                	div    %edi
  800c15:	89 d0                	mov    %edx,%eax
  800c17:	31 d2                	xor    %edx,%edx
  800c19:	83 c4 1c             	add    $0x1c,%esp
  800c1c:	5b                   	pop    %ebx
  800c1d:	5e                   	pop    %esi
  800c1e:	5f                   	pop    %edi
  800c1f:	5d                   	pop    %ebp
  800c20:	c3                   	ret    
  800c21:	8d 76 00             	lea    0x0(%esi),%esi
  800c24:	89 f2                	mov    %esi,%edx
  800c26:	39 d8                	cmp    %ebx,%eax
  800c28:	76 0e                	jbe    800c38 <__umoddi3+0x48>
  800c2a:	89 f0                	mov    %esi,%eax
  800c2c:	89 da                	mov    %ebx,%edx
  800c2e:	83 c4 1c             	add    $0x1c,%esp
  800c31:	5b                   	pop    %ebx
  800c32:	5e                   	pop    %esi
  800c33:	5f                   	pop    %edi
  800c34:	5d                   	pop    %ebp
  800c35:	c3                   	ret    
  800c36:	66 90                	xchg   %ax,%ax
  800c38:	0f bd e8             	bsr    %eax,%ebp
  800c3b:	83 f5 1f             	xor    $0x1f,%ebp
  800c3e:	75 44                	jne    800c84 <__umoddi3+0x94>
  800c40:	39 d8                	cmp    %ebx,%eax
  800c42:	72 06                	jb     800c4a <__umoddi3+0x5a>
  800c44:	89 d9                	mov    %ebx,%ecx
  800c46:	39 f7                	cmp    %esi,%edi
  800c48:	77 08                	ja     800c52 <__umoddi3+0x62>
  800c4a:	29 fe                	sub    %edi,%esi
  800c4c:	19 c3                	sbb    %eax,%ebx
  800c4e:	89 f2                	mov    %esi,%edx
  800c50:	89 d9                	mov    %ebx,%ecx
  800c52:	89 d0                	mov    %edx,%eax
  800c54:	89 ca                	mov    %ecx,%edx
  800c56:	83 c4 1c             	add    $0x1c,%esp
  800c59:	5b                   	pop    %ebx
  800c5a:	5e                   	pop    %esi
  800c5b:	5f                   	pop    %edi
  800c5c:	5d                   	pop    %ebp
  800c5d:	c3                   	ret    
  800c5e:	66 90                	xchg   %ax,%ax
  800c60:	89 fd                	mov    %edi,%ebp
  800c62:	85 ff                	test   %edi,%edi
  800c64:	75 0b                	jne    800c71 <__umoddi3+0x81>
  800c66:	b8 01 00 00 00       	mov    $0x1,%eax
  800c6b:	31 d2                	xor    %edx,%edx
  800c6d:	f7 f7                	div    %edi
  800c6f:	89 c5                	mov    %eax,%ebp
  800c71:	89 d8                	mov    %ebx,%eax
  800c73:	31 d2                	xor    %edx,%edx
  800c75:	f7 f5                	div    %ebp
  800c77:	89 f0                	mov    %esi,%eax
  800c79:	f7 f5                	div    %ebp
  800c7b:	89 d0                	mov    %edx,%eax
  800c7d:	31 d2                	xor    %edx,%edx
  800c7f:	eb 98                	jmp    800c19 <__umoddi3+0x29>
  800c81:	8d 76 00             	lea    0x0(%esi),%esi
  800c84:	ba 20 00 00 00       	mov    $0x20,%edx
  800c89:	29 ea                	sub    %ebp,%edx
  800c8b:	89 e9                	mov    %ebp,%ecx
  800c8d:	d3 e0                	shl    %cl,%eax
  800c8f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c93:	89 f8                	mov    %edi,%eax
  800c95:	89 54 24 04          	mov    %edx,0x4(%esp)
  800c99:	88 d1                	mov    %dl,%cl
  800c9b:	d3 e8                	shr    %cl,%eax
  800c9d:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800ca1:	09 c1                	or     %eax,%ecx
  800ca3:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800ca7:	89 e9                	mov    %ebp,%ecx
  800ca9:	d3 e7                	shl    %cl,%edi
  800cab:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800caf:	89 d8                	mov    %ebx,%eax
  800cb1:	8b 54 24 04          	mov    0x4(%esp),%edx
  800cb5:	88 d1                	mov    %dl,%cl
  800cb7:	d3 e8                	shr    %cl,%eax
  800cb9:	89 c7                	mov    %eax,%edi
  800cbb:	89 e9                	mov    %ebp,%ecx
  800cbd:	d3 e3                	shl    %cl,%ebx
  800cbf:	89 f0                	mov    %esi,%eax
  800cc1:	88 d1                	mov    %dl,%cl
  800cc3:	d3 e8                	shr    %cl,%eax
  800cc5:	09 d8                	or     %ebx,%eax
  800cc7:	89 e9                	mov    %ebp,%ecx
  800cc9:	d3 e6                	shl    %cl,%esi
  800ccb:	89 f3                	mov    %esi,%ebx
  800ccd:	89 fa                	mov    %edi,%edx
  800ccf:	f7 74 24 08          	divl   0x8(%esp)
  800cd3:	89 d1                	mov    %edx,%ecx
  800cd5:	f7 64 24 0c          	mull   0xc(%esp)
  800cd9:	89 c6                	mov    %eax,%esi
  800cdb:	89 d7                	mov    %edx,%edi
  800cdd:	39 d1                	cmp    %edx,%ecx
  800cdf:	72 27                	jb     800d08 <__umoddi3+0x118>
  800ce1:	74 21                	je     800d04 <__umoddi3+0x114>
  800ce3:	89 ca                	mov    %ecx,%edx
  800ce5:	29 f3                	sub    %esi,%ebx
  800ce7:	19 fa                	sbb    %edi,%edx
  800ce9:	89 d0                	mov    %edx,%eax
  800ceb:	8a 4c 24 04          	mov    0x4(%esp),%cl
  800cef:	d3 e0                	shl    %cl,%eax
  800cf1:	89 e9                	mov    %ebp,%ecx
  800cf3:	d3 eb                	shr    %cl,%ebx
  800cf5:	09 d8                	or     %ebx,%eax
  800cf7:	d3 ea                	shr    %cl,%edx
  800cf9:	83 c4 1c             	add    $0x1c,%esp
  800cfc:	5b                   	pop    %ebx
  800cfd:	5e                   	pop    %esi
  800cfe:	5f                   	pop    %edi
  800cff:	5d                   	pop    %ebp
  800d00:	c3                   	ret    
  800d01:	8d 76 00             	lea    0x0(%esi),%esi
  800d04:	39 c3                	cmp    %eax,%ebx
  800d06:	73 db                	jae    800ce3 <__umoddi3+0xf3>
  800d08:	2b 44 24 0c          	sub    0xc(%esp),%eax
  800d0c:	1b 54 24 08          	sbb    0x8(%esp),%edx
  800d10:	89 d7                	mov    %edx,%edi
  800d12:	89 c6                	mov    %eax,%esi
  800d14:	eb cd                	jmp    800ce3 <__umoddi3+0xf3>
