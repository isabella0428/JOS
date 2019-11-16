
obj/user/faultreadkernel:     file format elf32-i386


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
	cprintf("I read %08x from location 0xf0100000!\n", *(unsigned*)0xf0100000);
  800039:	ff 35 00 00 10 f0    	pushl  0xf0100000
  80003f:	68 f0 0c 80 00       	push   $0x800cf0
  800044:	e8 e1 00 00 00       	call   80012a <cprintf>
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
  800051:	83 ec 08             	sub    $0x8,%esp
  800054:	8b 45 08             	mov    0x8(%ebp),%eax
  800057:	8b 55 0c             	mov    0xc(%ebp),%edx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  80005a:	c7 05 04 10 80 00 00 	movl   $0x0,0x801004
  800061:	00 00 00 

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800064:	85 c0                	test   %eax,%eax
  800066:	7e 08                	jle    800070 <libmain+0x22>
		binaryname = argv[0];
  800068:	8b 0a                	mov    (%edx),%ecx
  80006a:	89 0d 00 10 80 00    	mov    %ecx,0x801000

	// call user main routine
	umain(argc, argv);
  800070:	83 ec 08             	sub    $0x8,%esp
  800073:	52                   	push   %edx
  800074:	50                   	push   %eax
  800075:	e8 b9 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80007a:	e8 05 00 00 00       	call   800084 <exit>
}
  80007f:	83 c4 10             	add    $0x10,%esp
  800082:	c9                   	leave  
  800083:	c3                   	ret    

00800084 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800084:	55                   	push   %ebp
  800085:	89 e5                	mov    %esp,%ebp
  800087:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  80008a:	6a 00                	push   $0x0
  80008c:	e8 8f 09 00 00       	call   800a20 <sys_env_destroy>
}
  800091:	83 c4 10             	add    $0x10,%esp
  800094:	c9                   	leave  
  800095:	c3                   	ret    

00800096 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800096:	55                   	push   %ebp
  800097:	89 e5                	mov    %esp,%ebp
  800099:	53                   	push   %ebx
  80009a:	83 ec 04             	sub    $0x4,%esp
  80009d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000a0:	8b 13                	mov    (%ebx),%edx
  8000a2:	8d 42 01             	lea    0x1(%edx),%eax
  8000a5:	89 03                	mov    %eax,(%ebx)
  8000a7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000aa:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000ae:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000b3:	74 08                	je     8000bd <putch+0x27>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8000b5:	ff 43 04             	incl   0x4(%ebx)
}
  8000b8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000bb:	c9                   	leave  
  8000bc:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8000bd:	83 ec 08             	sub    $0x8,%esp
  8000c0:	68 ff 00 00 00       	push   $0xff
  8000c5:	8d 43 08             	lea    0x8(%ebx),%eax
  8000c8:	50                   	push   %eax
  8000c9:	e8 15 09 00 00       	call   8009e3 <sys_cputs>
		b->idx = 0;
  8000ce:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8000d4:	83 c4 10             	add    $0x10,%esp
  8000d7:	eb dc                	jmp    8000b5 <putch+0x1f>

008000d9 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8000d9:	55                   	push   %ebp
  8000da:	89 e5                	mov    %esp,%ebp
  8000dc:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8000e2:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8000e9:	00 00 00 
	b.cnt = 0;
  8000ec:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8000f3:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8000f6:	ff 75 0c             	pushl  0xc(%ebp)
  8000f9:	ff 75 08             	pushl  0x8(%ebp)
  8000fc:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800102:	50                   	push   %eax
  800103:	68 96 00 80 00       	push   $0x800096
  800108:	e8 0f 01 00 00       	call   80021c <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80010d:	83 c4 08             	add    $0x8,%esp
  800110:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800116:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80011c:	50                   	push   %eax
  80011d:	e8 c1 08 00 00       	call   8009e3 <sys_cputs>

	return b.cnt;
}
  800122:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800128:	c9                   	leave  
  800129:	c3                   	ret    

0080012a <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80012a:	55                   	push   %ebp
  80012b:	89 e5                	mov    %esp,%ebp
  80012d:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800130:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800133:	50                   	push   %eax
  800134:	ff 75 08             	pushl  0x8(%ebp)
  800137:	e8 9d ff ff ff       	call   8000d9 <vcprintf>
	va_end(ap);

	return cnt;
}
  80013c:	c9                   	leave  
  80013d:	c3                   	ret    

0080013e <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80013e:	55                   	push   %ebp
  80013f:	89 e5                	mov    %esp,%ebp
  800141:	57                   	push   %edi
  800142:	56                   	push   %esi
  800143:	53                   	push   %ebx
  800144:	83 ec 1c             	sub    $0x1c,%esp
  800147:	89 c7                	mov    %eax,%edi
  800149:	89 d6                	mov    %edx,%esi
  80014b:	8b 45 08             	mov    0x8(%ebp),%eax
  80014e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800151:	89 d1                	mov    %edx,%ecx
  800153:	89 c2                	mov    %eax,%edx
  800155:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800158:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80015b:	8b 45 10             	mov    0x10(%ebp),%eax
  80015e:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800161:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800164:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80016b:	39 c2                	cmp    %eax,%edx
  80016d:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  800170:	72 3c                	jb     8001ae <printnum+0x70>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800172:	83 ec 0c             	sub    $0xc,%esp
  800175:	ff 75 18             	pushl  0x18(%ebp)
  800178:	4b                   	dec    %ebx
  800179:	53                   	push   %ebx
  80017a:	50                   	push   %eax
  80017b:	83 ec 08             	sub    $0x8,%esp
  80017e:	ff 75 e4             	pushl  -0x1c(%ebp)
  800181:	ff 75 e0             	pushl  -0x20(%ebp)
  800184:	ff 75 dc             	pushl  -0x24(%ebp)
  800187:	ff 75 d8             	pushl  -0x28(%ebp)
  80018a:	e8 39 09 00 00       	call   800ac8 <__udivdi3>
  80018f:	83 c4 18             	add    $0x18,%esp
  800192:	52                   	push   %edx
  800193:	50                   	push   %eax
  800194:	89 f2                	mov    %esi,%edx
  800196:	89 f8                	mov    %edi,%eax
  800198:	e8 a1 ff ff ff       	call   80013e <printnum>
  80019d:	83 c4 20             	add    $0x20,%esp
  8001a0:	eb 11                	jmp    8001b3 <printnum+0x75>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001a2:	83 ec 08             	sub    $0x8,%esp
  8001a5:	56                   	push   %esi
  8001a6:	ff 75 18             	pushl  0x18(%ebp)
  8001a9:	ff d7                	call   *%edi
  8001ab:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8001ae:	4b                   	dec    %ebx
  8001af:	85 db                	test   %ebx,%ebx
  8001b1:	7f ef                	jg     8001a2 <printnum+0x64>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8001b3:	83 ec 08             	sub    $0x8,%esp
  8001b6:	56                   	push   %esi
  8001b7:	83 ec 04             	sub    $0x4,%esp
  8001ba:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001bd:	ff 75 e0             	pushl  -0x20(%ebp)
  8001c0:	ff 75 dc             	pushl  -0x24(%ebp)
  8001c3:	ff 75 d8             	pushl  -0x28(%ebp)
  8001c6:	e8 fd 09 00 00       	call   800bc8 <__umoddi3>
  8001cb:	83 c4 14             	add    $0x14,%esp
  8001ce:	0f be 80 21 0d 80 00 	movsbl 0x800d21(%eax),%eax
  8001d5:	50                   	push   %eax
  8001d6:	ff d7                	call   *%edi
}
  8001d8:	83 c4 10             	add    $0x10,%esp
  8001db:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001de:	5b                   	pop    %ebx
  8001df:	5e                   	pop    %esi
  8001e0:	5f                   	pop    %edi
  8001e1:	5d                   	pop    %ebp
  8001e2:	c3                   	ret    

008001e3 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8001e3:	55                   	push   %ebp
  8001e4:	89 e5                	mov    %esp,%ebp
  8001e6:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8001e9:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8001ec:	8b 10                	mov    (%eax),%edx
  8001ee:	3b 50 04             	cmp    0x4(%eax),%edx
  8001f1:	73 0a                	jae    8001fd <sprintputch+0x1a>
		*b->buf++ = ch;
  8001f3:	8d 4a 01             	lea    0x1(%edx),%ecx
  8001f6:	89 08                	mov    %ecx,(%eax)
  8001f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8001fb:	88 02                	mov    %al,(%edx)
}
  8001fd:	5d                   	pop    %ebp
  8001fe:	c3                   	ret    

008001ff <printfmt>:
{
  8001ff:	55                   	push   %ebp
  800200:	89 e5                	mov    %esp,%ebp
  800202:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800205:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800208:	50                   	push   %eax
  800209:	ff 75 10             	pushl  0x10(%ebp)
  80020c:	ff 75 0c             	pushl  0xc(%ebp)
  80020f:	ff 75 08             	pushl  0x8(%ebp)
  800212:	e8 05 00 00 00       	call   80021c <vprintfmt>
}
  800217:	83 c4 10             	add    $0x10,%esp
  80021a:	c9                   	leave  
  80021b:	c3                   	ret    

0080021c <vprintfmt>:
{
  80021c:	55                   	push   %ebp
  80021d:	89 e5                	mov    %esp,%ebp
  80021f:	57                   	push   %edi
  800220:	56                   	push   %esi
  800221:	53                   	push   %ebx
  800222:	83 ec 3c             	sub    $0x3c,%esp
  800225:	8b 75 08             	mov    0x8(%ebp),%esi
  800228:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80022b:	8b 7d 10             	mov    0x10(%ebp),%edi
  80022e:	e9 5b 03 00 00       	jmp    80058e <vprintfmt+0x372>
		padc = ' ';
  800233:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  800237:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
		precision = -1;
  80023e:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  800245:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		lflag = 0;
  80024c:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800251:	8d 47 01             	lea    0x1(%edi),%eax
  800254:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800257:	8a 17                	mov    (%edi),%dl
  800259:	8d 42 dd             	lea    -0x23(%edx),%eax
  80025c:	3c 55                	cmp    $0x55,%al
  80025e:	0f 87 ab 03 00 00    	ja     80060f <vprintfmt+0x3f3>
  800264:	0f b6 c0             	movzbl %al,%eax
  800267:	ff 24 85 b0 0d 80 00 	jmp    *0x800db0(,%eax,4)
  80026e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800271:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  800275:	eb da                	jmp    800251 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  800277:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80027a:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  80027e:	eb d1                	jmp    800251 <vprintfmt+0x35>
  800280:	0f b6 d2             	movzbl %dl,%edx
  800283:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800286:	b8 00 00 00 00       	mov    $0x0,%eax
  80028b:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  80028e:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800291:	01 c0                	add    %eax,%eax
  800293:	8d 44 02 d0          	lea    -0x30(%edx,%eax,1),%eax
				ch = *fmt;
  800297:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  80029a:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80029d:	83 f9 09             	cmp    $0x9,%ecx
  8002a0:	77 52                	ja     8002f4 <vprintfmt+0xd8>
			for (precision = 0; ; ++fmt) {
  8002a2:	47                   	inc    %edi
				precision = precision * 10 + ch - '0';
  8002a3:	eb e9                	jmp    80028e <vprintfmt+0x72>
			precision = va_arg(ap, int);
  8002a5:	8b 45 14             	mov    0x14(%ebp),%eax
  8002a8:	8b 00                	mov    (%eax),%eax
  8002aa:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002ad:	8b 45 14             	mov    0x14(%ebp),%eax
  8002b0:	8d 40 04             	lea    0x4(%eax),%eax
  8002b3:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8002b6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8002b9:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8002bd:	79 92                	jns    800251 <vprintfmt+0x35>
				width = precision, precision = -1;
  8002bf:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8002c2:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8002c5:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8002cc:	eb 83                	jmp    800251 <vprintfmt+0x35>
  8002ce:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8002d2:	78 08                	js     8002dc <vprintfmt+0xc0>
		switch (ch = *(unsigned char *) fmt++) {
  8002d4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8002d7:	e9 75 ff ff ff       	jmp    800251 <vprintfmt+0x35>
  8002dc:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  8002e3:	eb ef                	jmp    8002d4 <vprintfmt+0xb8>
		switch (ch = *(unsigned char *) fmt++) {
  8002e5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8002e8:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  8002ef:	e9 5d ff ff ff       	jmp    800251 <vprintfmt+0x35>
  8002f4:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8002f7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002fa:	eb bd                	jmp    8002b9 <vprintfmt+0x9d>
			lflag++;
  8002fc:	41                   	inc    %ecx
		switch (ch = *(unsigned char *) fmt++) {
  8002fd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800300:	e9 4c ff ff ff       	jmp    800251 <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
  800305:	8b 45 14             	mov    0x14(%ebp),%eax
  800308:	8d 78 04             	lea    0x4(%eax),%edi
  80030b:	83 ec 08             	sub    $0x8,%esp
  80030e:	53                   	push   %ebx
  80030f:	ff 30                	pushl  (%eax)
  800311:	ff d6                	call   *%esi
			break;
  800313:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800316:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800319:	e9 6d 02 00 00       	jmp    80058b <vprintfmt+0x36f>
			err = va_arg(ap, int);
  80031e:	8b 45 14             	mov    0x14(%ebp),%eax
  800321:	8d 78 04             	lea    0x4(%eax),%edi
  800324:	8b 00                	mov    (%eax),%eax
  800326:	85 c0                	test   %eax,%eax
  800328:	78 2a                	js     800354 <vprintfmt+0x138>
  80032a:	89 c2                	mov    %eax,%edx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80032c:	83 f8 06             	cmp    $0x6,%eax
  80032f:	7f 27                	jg     800358 <vprintfmt+0x13c>
  800331:	8b 04 85 08 0f 80 00 	mov    0x800f08(,%eax,4),%eax
  800338:	85 c0                	test   %eax,%eax
  80033a:	74 1c                	je     800358 <vprintfmt+0x13c>
				printfmt(putch, putdat, "%s", p);
  80033c:	50                   	push   %eax
  80033d:	68 42 0d 80 00       	push   $0x800d42
  800342:	53                   	push   %ebx
  800343:	56                   	push   %esi
  800344:	e8 b6 fe ff ff       	call   8001ff <printfmt>
  800349:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80034c:	89 7d 14             	mov    %edi,0x14(%ebp)
  80034f:	e9 37 02 00 00       	jmp    80058b <vprintfmt+0x36f>
  800354:	f7 d8                	neg    %eax
  800356:	eb d2                	jmp    80032a <vprintfmt+0x10e>
				printfmt(putch, putdat, "error %d", err);
  800358:	52                   	push   %edx
  800359:	68 39 0d 80 00       	push   $0x800d39
  80035e:	53                   	push   %ebx
  80035f:	56                   	push   %esi
  800360:	e8 9a fe ff ff       	call   8001ff <printfmt>
  800365:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800368:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  80036b:	e9 1b 02 00 00       	jmp    80058b <vprintfmt+0x36f>
			if ((p = va_arg(ap, char *)) == NULL)
  800370:	8b 45 14             	mov    0x14(%ebp),%eax
  800373:	83 c0 04             	add    $0x4,%eax
  800376:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800379:	8b 45 14             	mov    0x14(%ebp),%eax
  80037c:	8b 00                	mov    (%eax),%eax
  80037e:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800381:	85 c0                	test   %eax,%eax
  800383:	74 19                	je     80039e <vprintfmt+0x182>
			if (width > 0 && padc != '-')
  800385:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800389:	7e 06                	jle    800391 <vprintfmt+0x175>
  80038b:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  80038f:	75 16                	jne    8003a7 <vprintfmt+0x18b>
				for (width -= strnlen(p, precision); width > 0; width--)
  800391:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800394:	89 c7                	mov    %eax,%edi
  800396:	03 45 d4             	add    -0x2c(%ebp),%eax
  800399:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80039c:	eb 62                	jmp    800400 <vprintfmt+0x1e4>
				p = "(null)";
  80039e:	c7 45 cc 32 0d 80 00 	movl   $0x800d32,-0x34(%ebp)
  8003a5:	eb de                	jmp    800385 <vprintfmt+0x169>
				for (width -= strnlen(p, precision); width > 0; width--)
  8003a7:	83 ec 08             	sub    $0x8,%esp
  8003aa:	ff 75 d8             	pushl  -0x28(%ebp)
  8003ad:	ff 75 cc             	pushl  -0x34(%ebp)
  8003b0:	e8 05 03 00 00       	call   8006ba <strnlen>
  8003b5:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8003b8:	29 c2                	sub    %eax,%edx
  8003ba:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  8003bd:	83 c4 10             	add    $0x10,%esp
  8003c0:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  8003c2:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8003c6:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8003c9:	eb 0d                	jmp    8003d8 <vprintfmt+0x1bc>
					putch(padc, putdat);
  8003cb:	83 ec 08             	sub    $0x8,%esp
  8003ce:	53                   	push   %ebx
  8003cf:	ff 75 d4             	pushl  -0x2c(%ebp)
  8003d2:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8003d4:	4f                   	dec    %edi
  8003d5:	83 c4 10             	add    $0x10,%esp
  8003d8:	85 ff                	test   %edi,%edi
  8003da:	7f ef                	jg     8003cb <vprintfmt+0x1af>
  8003dc:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8003df:	89 d0                	mov    %edx,%eax
  8003e1:	85 d2                	test   %edx,%edx
  8003e3:	78 0a                	js     8003ef <vprintfmt+0x1d3>
  8003e5:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8003e8:	29 c2                	sub    %eax,%edx
  8003ea:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8003ed:	eb a2                	jmp    800391 <vprintfmt+0x175>
  8003ef:	b8 00 00 00 00       	mov    $0x0,%eax
  8003f4:	eb ef                	jmp    8003e5 <vprintfmt+0x1c9>
					putch(ch, putdat);
  8003f6:	83 ec 08             	sub    $0x8,%esp
  8003f9:	53                   	push   %ebx
  8003fa:	52                   	push   %edx
  8003fb:	ff d6                	call   *%esi
  8003fd:	83 c4 10             	add    $0x10,%esp
  800400:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  800403:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800405:	47                   	inc    %edi
  800406:	8a 47 ff             	mov    -0x1(%edi),%al
  800409:	0f be d0             	movsbl %al,%edx
  80040c:	85 d2                	test   %edx,%edx
  80040e:	74 48                	je     800458 <vprintfmt+0x23c>
  800410:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800414:	78 05                	js     80041b <vprintfmt+0x1ff>
  800416:	ff 4d d8             	decl   -0x28(%ebp)
  800419:	78 1e                	js     800439 <vprintfmt+0x21d>
				if (altflag && (ch < ' ' || ch > '~'))
  80041b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80041f:	74 d5                	je     8003f6 <vprintfmt+0x1da>
  800421:	0f be c0             	movsbl %al,%eax
  800424:	83 e8 20             	sub    $0x20,%eax
  800427:	83 f8 5e             	cmp    $0x5e,%eax
  80042a:	76 ca                	jbe    8003f6 <vprintfmt+0x1da>
					putch('?', putdat);
  80042c:	83 ec 08             	sub    $0x8,%esp
  80042f:	53                   	push   %ebx
  800430:	6a 3f                	push   $0x3f
  800432:	ff d6                	call   *%esi
  800434:	83 c4 10             	add    $0x10,%esp
  800437:	eb c7                	jmp    800400 <vprintfmt+0x1e4>
  800439:	89 cf                	mov    %ecx,%edi
  80043b:	eb 0c                	jmp    800449 <vprintfmt+0x22d>
				putch(' ', putdat);
  80043d:	83 ec 08             	sub    $0x8,%esp
  800440:	53                   	push   %ebx
  800441:	6a 20                	push   $0x20
  800443:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800445:	4f                   	dec    %edi
  800446:	83 c4 10             	add    $0x10,%esp
  800449:	85 ff                	test   %edi,%edi
  80044b:	7f f0                	jg     80043d <vprintfmt+0x221>
			if ((p = va_arg(ap, char *)) == NULL)
  80044d:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800450:	89 45 14             	mov    %eax,0x14(%ebp)
  800453:	e9 33 01 00 00       	jmp    80058b <vprintfmt+0x36f>
  800458:	89 cf                	mov    %ecx,%edi
  80045a:	eb ed                	jmp    800449 <vprintfmt+0x22d>
	if (lflag >= 2)
  80045c:	83 f9 01             	cmp    $0x1,%ecx
  80045f:	7f 1b                	jg     80047c <vprintfmt+0x260>
	else if (lflag)
  800461:	85 c9                	test   %ecx,%ecx
  800463:	74 42                	je     8004a7 <vprintfmt+0x28b>
		return va_arg(*ap, long);
  800465:	8b 45 14             	mov    0x14(%ebp),%eax
  800468:	8b 00                	mov    (%eax),%eax
  80046a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80046d:	99                   	cltd   
  80046e:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800471:	8b 45 14             	mov    0x14(%ebp),%eax
  800474:	8d 40 04             	lea    0x4(%eax),%eax
  800477:	89 45 14             	mov    %eax,0x14(%ebp)
  80047a:	eb 17                	jmp    800493 <vprintfmt+0x277>
		return va_arg(*ap, long long);
  80047c:	8b 45 14             	mov    0x14(%ebp),%eax
  80047f:	8b 50 04             	mov    0x4(%eax),%edx
  800482:	8b 00                	mov    (%eax),%eax
  800484:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800487:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80048a:	8b 45 14             	mov    0x14(%ebp),%eax
  80048d:	8d 40 08             	lea    0x8(%eax),%eax
  800490:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800493:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800496:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800499:	85 c9                	test   %ecx,%ecx
  80049b:	78 21                	js     8004be <vprintfmt+0x2a2>
			base = 10;
  80049d:	b8 0a 00 00 00       	mov    $0xa,%eax
  8004a2:	e9 ca 00 00 00       	jmp    800571 <vprintfmt+0x355>
		return va_arg(*ap, int);
  8004a7:	8b 45 14             	mov    0x14(%ebp),%eax
  8004aa:	8b 00                	mov    (%eax),%eax
  8004ac:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004af:	99                   	cltd   
  8004b0:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8004b3:	8b 45 14             	mov    0x14(%ebp),%eax
  8004b6:	8d 40 04             	lea    0x4(%eax),%eax
  8004b9:	89 45 14             	mov    %eax,0x14(%ebp)
  8004bc:	eb d5                	jmp    800493 <vprintfmt+0x277>
				putch('-', putdat);
  8004be:	83 ec 08             	sub    $0x8,%esp
  8004c1:	53                   	push   %ebx
  8004c2:	6a 2d                	push   $0x2d
  8004c4:	ff d6                	call   *%esi
				num = -(long long) num;
  8004c6:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8004c9:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8004cc:	f7 da                	neg    %edx
  8004ce:	83 d1 00             	adc    $0x0,%ecx
  8004d1:	f7 d9                	neg    %ecx
  8004d3:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8004d6:	b8 0a 00 00 00       	mov    $0xa,%eax
  8004db:	e9 91 00 00 00       	jmp    800571 <vprintfmt+0x355>
	if (lflag >= 2)
  8004e0:	83 f9 01             	cmp    $0x1,%ecx
  8004e3:	7f 1b                	jg     800500 <vprintfmt+0x2e4>
	else if (lflag)
  8004e5:	85 c9                	test   %ecx,%ecx
  8004e7:	74 2c                	je     800515 <vprintfmt+0x2f9>
		return va_arg(*ap, unsigned long);
  8004e9:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ec:	8b 10                	mov    (%eax),%edx
  8004ee:	b9 00 00 00 00       	mov    $0x0,%ecx
  8004f3:	8d 40 04             	lea    0x4(%eax),%eax
  8004f6:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8004f9:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  8004fe:	eb 71                	jmp    800571 <vprintfmt+0x355>
		return va_arg(*ap, unsigned long long);
  800500:	8b 45 14             	mov    0x14(%ebp),%eax
  800503:	8b 10                	mov    (%eax),%edx
  800505:	8b 48 04             	mov    0x4(%eax),%ecx
  800508:	8d 40 08             	lea    0x8(%eax),%eax
  80050b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80050e:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  800513:	eb 5c                	jmp    800571 <vprintfmt+0x355>
		return va_arg(*ap, unsigned int);
  800515:	8b 45 14             	mov    0x14(%ebp),%eax
  800518:	8b 10                	mov    (%eax),%edx
  80051a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80051f:	8d 40 04             	lea    0x4(%eax),%eax
  800522:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800525:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  80052a:	eb 45                	jmp    800571 <vprintfmt+0x355>
			putch('X', putdat);
  80052c:	83 ec 08             	sub    $0x8,%esp
  80052f:	53                   	push   %ebx
  800530:	6a 58                	push   $0x58
  800532:	ff d6                	call   *%esi
			putch('X', putdat);
  800534:	83 c4 08             	add    $0x8,%esp
  800537:	53                   	push   %ebx
  800538:	6a 58                	push   $0x58
  80053a:	ff d6                	call   *%esi
			putch('X', putdat);
  80053c:	83 c4 08             	add    $0x8,%esp
  80053f:	53                   	push   %ebx
  800540:	6a 58                	push   $0x58
  800542:	ff d6                	call   *%esi
			break;
  800544:	83 c4 10             	add    $0x10,%esp
  800547:	eb 42                	jmp    80058b <vprintfmt+0x36f>
			putch('0', putdat);
  800549:	83 ec 08             	sub    $0x8,%esp
  80054c:	53                   	push   %ebx
  80054d:	6a 30                	push   $0x30
  80054f:	ff d6                	call   *%esi
			putch('x', putdat);
  800551:	83 c4 08             	add    $0x8,%esp
  800554:	53                   	push   %ebx
  800555:	6a 78                	push   $0x78
  800557:	ff d6                	call   *%esi
			num = (unsigned long long)
  800559:	8b 45 14             	mov    0x14(%ebp),%eax
  80055c:	8b 10                	mov    (%eax),%edx
  80055e:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800563:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800566:	8d 40 04             	lea    0x4(%eax),%eax
  800569:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80056c:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  800571:	83 ec 0c             	sub    $0xc,%esp
  800574:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  800578:	57                   	push   %edi
  800579:	ff 75 d4             	pushl  -0x2c(%ebp)
  80057c:	50                   	push   %eax
  80057d:	51                   	push   %ecx
  80057e:	52                   	push   %edx
  80057f:	89 da                	mov    %ebx,%edx
  800581:	89 f0                	mov    %esi,%eax
  800583:	e8 b6 fb ff ff       	call   80013e <printnum>
			break;
  800588:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  80058b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80058e:	47                   	inc    %edi
  80058f:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800593:	83 f8 25             	cmp    $0x25,%eax
  800596:	0f 84 97 fc ff ff    	je     800233 <vprintfmt+0x17>
			if (ch == '\0')
  80059c:	85 c0                	test   %eax,%eax
  80059e:	0f 84 89 00 00 00    	je     80062d <vprintfmt+0x411>
			putch(ch, putdat);
  8005a4:	83 ec 08             	sub    $0x8,%esp
  8005a7:	53                   	push   %ebx
  8005a8:	50                   	push   %eax
  8005a9:	ff d6                	call   *%esi
  8005ab:	83 c4 10             	add    $0x10,%esp
  8005ae:	eb de                	jmp    80058e <vprintfmt+0x372>
	if (lflag >= 2)
  8005b0:	83 f9 01             	cmp    $0x1,%ecx
  8005b3:	7f 1b                	jg     8005d0 <vprintfmt+0x3b4>
	else if (lflag)
  8005b5:	85 c9                	test   %ecx,%ecx
  8005b7:	74 2c                	je     8005e5 <vprintfmt+0x3c9>
		return va_arg(*ap, unsigned long);
  8005b9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005bc:	8b 10                	mov    (%eax),%edx
  8005be:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005c3:	8d 40 04             	lea    0x4(%eax),%eax
  8005c6:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8005c9:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  8005ce:	eb a1                	jmp    800571 <vprintfmt+0x355>
		return va_arg(*ap, unsigned long long);
  8005d0:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d3:	8b 10                	mov    (%eax),%edx
  8005d5:	8b 48 04             	mov    0x4(%eax),%ecx
  8005d8:	8d 40 08             	lea    0x8(%eax),%eax
  8005db:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8005de:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  8005e3:	eb 8c                	jmp    800571 <vprintfmt+0x355>
		return va_arg(*ap, unsigned int);
  8005e5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e8:	8b 10                	mov    (%eax),%edx
  8005ea:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005ef:	8d 40 04             	lea    0x4(%eax),%eax
  8005f2:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8005f5:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  8005fa:	e9 72 ff ff ff       	jmp    800571 <vprintfmt+0x355>
			putch(ch, putdat);
  8005ff:	83 ec 08             	sub    $0x8,%esp
  800602:	53                   	push   %ebx
  800603:	6a 25                	push   $0x25
  800605:	ff d6                	call   *%esi
			break;
  800607:	83 c4 10             	add    $0x10,%esp
  80060a:	e9 7c ff ff ff       	jmp    80058b <vprintfmt+0x36f>
			putch('%', putdat);
  80060f:	83 ec 08             	sub    $0x8,%esp
  800612:	53                   	push   %ebx
  800613:	6a 25                	push   $0x25
  800615:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800617:	83 c4 10             	add    $0x10,%esp
  80061a:	89 f8                	mov    %edi,%eax
  80061c:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800620:	74 03                	je     800625 <vprintfmt+0x409>
  800622:	48                   	dec    %eax
  800623:	eb f7                	jmp    80061c <vprintfmt+0x400>
  800625:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800628:	e9 5e ff ff ff       	jmp    80058b <vprintfmt+0x36f>
}
  80062d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800630:	5b                   	pop    %ebx
  800631:	5e                   	pop    %esi
  800632:	5f                   	pop    %edi
  800633:	5d                   	pop    %ebp
  800634:	c3                   	ret    

00800635 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800635:	55                   	push   %ebp
  800636:	89 e5                	mov    %esp,%ebp
  800638:	83 ec 18             	sub    $0x18,%esp
  80063b:	8b 45 08             	mov    0x8(%ebp),%eax
  80063e:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800641:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800644:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800648:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80064b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800652:	85 c0                	test   %eax,%eax
  800654:	74 26                	je     80067c <vsnprintf+0x47>
  800656:	85 d2                	test   %edx,%edx
  800658:	7e 29                	jle    800683 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80065a:	ff 75 14             	pushl  0x14(%ebp)
  80065d:	ff 75 10             	pushl  0x10(%ebp)
  800660:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800663:	50                   	push   %eax
  800664:	68 e3 01 80 00       	push   $0x8001e3
  800669:	e8 ae fb ff ff       	call   80021c <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80066e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800671:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800674:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800677:	83 c4 10             	add    $0x10,%esp
}
  80067a:	c9                   	leave  
  80067b:	c3                   	ret    
		return -E_INVAL;
  80067c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800681:	eb f7                	jmp    80067a <vsnprintf+0x45>
  800683:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800688:	eb f0                	jmp    80067a <vsnprintf+0x45>

0080068a <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80068a:	55                   	push   %ebp
  80068b:	89 e5                	mov    %esp,%ebp
  80068d:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800690:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800693:	50                   	push   %eax
  800694:	ff 75 10             	pushl  0x10(%ebp)
  800697:	ff 75 0c             	pushl  0xc(%ebp)
  80069a:	ff 75 08             	pushl  0x8(%ebp)
  80069d:	e8 93 ff ff ff       	call   800635 <vsnprintf>
	va_end(ap);

	return rc;
}
  8006a2:	c9                   	leave  
  8006a3:	c3                   	ret    

008006a4 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006a4:	55                   	push   %ebp
  8006a5:	89 e5                	mov    %esp,%ebp
  8006a7:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006aa:	b8 00 00 00 00       	mov    $0x0,%eax
  8006af:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8006b3:	74 03                	je     8006b8 <strlen+0x14>
		n++;
  8006b5:	40                   	inc    %eax
  8006b6:	eb f7                	jmp    8006af <strlen+0xb>
	return n;
}
  8006b8:	5d                   	pop    %ebp
  8006b9:	c3                   	ret    

008006ba <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8006ba:	55                   	push   %ebp
  8006bb:	89 e5                	mov    %esp,%ebp
  8006bd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006c0:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006c3:	b8 00 00 00 00       	mov    $0x0,%eax
  8006c8:	39 d0                	cmp    %edx,%eax
  8006ca:	74 0b                	je     8006d7 <strnlen+0x1d>
  8006cc:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8006d0:	74 03                	je     8006d5 <strnlen+0x1b>
		n++;
  8006d2:	40                   	inc    %eax
  8006d3:	eb f3                	jmp    8006c8 <strnlen+0xe>
  8006d5:	89 c2                	mov    %eax,%edx
	return n;
}
  8006d7:	89 d0                	mov    %edx,%eax
  8006d9:	5d                   	pop    %ebp
  8006da:	c3                   	ret    

008006db <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8006db:	55                   	push   %ebp
  8006dc:	89 e5                	mov    %esp,%ebp
  8006de:	53                   	push   %ebx
  8006df:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006e2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8006e5:	b8 00 00 00 00       	mov    $0x0,%eax
  8006ea:	8a 14 03             	mov    (%ebx,%eax,1),%dl
  8006ed:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8006f0:	40                   	inc    %eax
  8006f1:	84 d2                	test   %dl,%dl
  8006f3:	75 f5                	jne    8006ea <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8006f5:	89 c8                	mov    %ecx,%eax
  8006f7:	5b                   	pop    %ebx
  8006f8:	5d                   	pop    %ebp
  8006f9:	c3                   	ret    

008006fa <strcat>:

char *
strcat(char *dst, const char *src)
{
  8006fa:	55                   	push   %ebp
  8006fb:	89 e5                	mov    %esp,%ebp
  8006fd:	53                   	push   %ebx
  8006fe:	83 ec 10             	sub    $0x10,%esp
  800701:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800704:	53                   	push   %ebx
  800705:	e8 9a ff ff ff       	call   8006a4 <strlen>
  80070a:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  80070d:	ff 75 0c             	pushl  0xc(%ebp)
  800710:	01 d8                	add    %ebx,%eax
  800712:	50                   	push   %eax
  800713:	e8 c3 ff ff ff       	call   8006db <strcpy>
	return dst;
}
  800718:	89 d8                	mov    %ebx,%eax
  80071a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80071d:	c9                   	leave  
  80071e:	c3                   	ret    

0080071f <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80071f:	55                   	push   %ebp
  800720:	89 e5                	mov    %esp,%ebp
  800722:	53                   	push   %ebx
  800723:	8b 55 0c             	mov    0xc(%ebp),%edx
  800726:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800729:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80072c:	8b 45 08             	mov    0x8(%ebp),%eax
  80072f:	39 d8                	cmp    %ebx,%eax
  800731:	74 0e                	je     800741 <strncpy+0x22>
		*dst++ = *src;
  800733:	40                   	inc    %eax
  800734:	8a 0a                	mov    (%edx),%cl
  800736:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800739:	80 f9 01             	cmp    $0x1,%cl
  80073c:	83 da ff             	sbb    $0xffffffff,%edx
  80073f:	eb ee                	jmp    80072f <strncpy+0x10>
	}
	return ret;
}
  800741:	8b 45 08             	mov    0x8(%ebp),%eax
  800744:	5b                   	pop    %ebx
  800745:	5d                   	pop    %ebp
  800746:	c3                   	ret    

00800747 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800747:	55                   	push   %ebp
  800748:	89 e5                	mov    %esp,%ebp
  80074a:	56                   	push   %esi
  80074b:	53                   	push   %ebx
  80074c:	8b 75 08             	mov    0x8(%ebp),%esi
  80074f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800752:	8b 45 10             	mov    0x10(%ebp),%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800755:	85 c0                	test   %eax,%eax
  800757:	74 22                	je     80077b <strlcpy+0x34>
  800759:	8d 44 06 ff          	lea    -0x1(%esi,%eax,1),%eax
  80075d:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  80075f:	39 c2                	cmp    %eax,%edx
  800761:	74 0f                	je     800772 <strlcpy+0x2b>
  800763:	8a 19                	mov    (%ecx),%bl
  800765:	84 db                	test   %bl,%bl
  800767:	74 07                	je     800770 <strlcpy+0x29>
			*dst++ = *src++;
  800769:	41                   	inc    %ecx
  80076a:	42                   	inc    %edx
  80076b:	88 5a ff             	mov    %bl,-0x1(%edx)
  80076e:	eb ef                	jmp    80075f <strlcpy+0x18>
  800770:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800772:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800775:	29 f0                	sub    %esi,%eax
}
  800777:	5b                   	pop    %ebx
  800778:	5e                   	pop    %esi
  800779:	5d                   	pop    %ebp
  80077a:	c3                   	ret    
  80077b:	89 f0                	mov    %esi,%eax
  80077d:	eb f6                	jmp    800775 <strlcpy+0x2e>

0080077f <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80077f:	55                   	push   %ebp
  800780:	89 e5                	mov    %esp,%ebp
  800782:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800785:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800788:	8a 01                	mov    (%ecx),%al
  80078a:	84 c0                	test   %al,%al
  80078c:	74 08                	je     800796 <strcmp+0x17>
  80078e:	3a 02                	cmp    (%edx),%al
  800790:	75 04                	jne    800796 <strcmp+0x17>
		p++, q++;
  800792:	41                   	inc    %ecx
  800793:	42                   	inc    %edx
  800794:	eb f2                	jmp    800788 <strcmp+0x9>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800796:	0f b6 c0             	movzbl %al,%eax
  800799:	0f b6 12             	movzbl (%edx),%edx
  80079c:	29 d0                	sub    %edx,%eax
}
  80079e:	5d                   	pop    %ebp
  80079f:	c3                   	ret    

008007a0 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8007a0:	55                   	push   %ebp
  8007a1:	89 e5                	mov    %esp,%ebp
  8007a3:	53                   	push   %ebx
  8007a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8007a7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007aa:	89 c3                	mov    %eax,%ebx
  8007ac:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8007af:	eb 02                	jmp    8007b3 <strncmp+0x13>
		n--, p++, q++;
  8007b1:	40                   	inc    %eax
  8007b2:	42                   	inc    %edx
	while (n > 0 && *p && *p == *q)
  8007b3:	39 d8                	cmp    %ebx,%eax
  8007b5:	74 15                	je     8007cc <strncmp+0x2c>
  8007b7:	8a 08                	mov    (%eax),%cl
  8007b9:	84 c9                	test   %cl,%cl
  8007bb:	74 04                	je     8007c1 <strncmp+0x21>
  8007bd:	3a 0a                	cmp    (%edx),%cl
  8007bf:	74 f0                	je     8007b1 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8007c1:	0f b6 00             	movzbl (%eax),%eax
  8007c4:	0f b6 12             	movzbl (%edx),%edx
  8007c7:	29 d0                	sub    %edx,%eax
}
  8007c9:	5b                   	pop    %ebx
  8007ca:	5d                   	pop    %ebp
  8007cb:	c3                   	ret    
		return 0;
  8007cc:	b8 00 00 00 00       	mov    $0x0,%eax
  8007d1:	eb f6                	jmp    8007c9 <strncmp+0x29>

008007d3 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8007d3:	55                   	push   %ebp
  8007d4:	89 e5                	mov    %esp,%ebp
  8007d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8007d9:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8007dc:	8a 10                	mov    (%eax),%dl
  8007de:	84 d2                	test   %dl,%dl
  8007e0:	74 07                	je     8007e9 <strchr+0x16>
		if (*s == c)
  8007e2:	38 ca                	cmp    %cl,%dl
  8007e4:	74 08                	je     8007ee <strchr+0x1b>
	for (; *s; s++)
  8007e6:	40                   	inc    %eax
  8007e7:	eb f3                	jmp    8007dc <strchr+0x9>
			return (char *) s;
	return 0;
  8007e9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007ee:	5d                   	pop    %ebp
  8007ef:	c3                   	ret    

008007f0 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8007f0:	55                   	push   %ebp
  8007f1:	89 e5                	mov    %esp,%ebp
  8007f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8007f6:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8007f9:	8a 10                	mov    (%eax),%dl
  8007fb:	84 d2                	test   %dl,%dl
  8007fd:	74 07                	je     800806 <strfind+0x16>
		if (*s == c)
  8007ff:	38 ca                	cmp    %cl,%dl
  800801:	74 03                	je     800806 <strfind+0x16>
	for (; *s; s++)
  800803:	40                   	inc    %eax
  800804:	eb f3                	jmp    8007f9 <strfind+0x9>
			break;
	return (char *) s;
}
  800806:	5d                   	pop    %ebp
  800807:	c3                   	ret    

00800808 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800808:	55                   	push   %ebp
  800809:	89 e5                	mov    %esp,%ebp
  80080b:	57                   	push   %edi
  80080c:	56                   	push   %esi
  80080d:	53                   	push   %ebx
  80080e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800811:	85 c9                	test   %ecx,%ecx
  800813:	74 36                	je     80084b <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800815:	89 c8                	mov    %ecx,%eax
  800817:	0b 45 08             	or     0x8(%ebp),%eax
  80081a:	a8 03                	test   $0x3,%al
  80081c:	75 24                	jne    800842 <memset+0x3a>
		c &= 0xFF;
  80081e:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800822:	89 d3                	mov    %edx,%ebx
  800824:	c1 e3 08             	shl    $0x8,%ebx
  800827:	89 d0                	mov    %edx,%eax
  800829:	c1 e0 18             	shl    $0x18,%eax
  80082c:	89 d6                	mov    %edx,%esi
  80082e:	c1 e6 10             	shl    $0x10,%esi
  800831:	09 f0                	or     %esi,%eax
  800833:	09 d0                	or     %edx,%eax
  800835:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800837:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  80083a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80083d:	fc                   	cld    
  80083e:	f3 ab                	rep stos %eax,%es:(%edi)
  800840:	eb 09                	jmp    80084b <memset+0x43>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800842:	8b 7d 08             	mov    0x8(%ebp),%edi
  800845:	8b 45 0c             	mov    0xc(%ebp),%eax
  800848:	fc                   	cld    
  800849:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80084b:	8b 45 08             	mov    0x8(%ebp),%eax
  80084e:	5b                   	pop    %ebx
  80084f:	5e                   	pop    %esi
  800850:	5f                   	pop    %edi
  800851:	5d                   	pop    %ebp
  800852:	c3                   	ret    

00800853 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800853:	55                   	push   %ebp
  800854:	89 e5                	mov    %esp,%ebp
  800856:	57                   	push   %edi
  800857:	56                   	push   %esi
  800858:	8b 45 08             	mov    0x8(%ebp),%eax
  80085b:	8b 75 0c             	mov    0xc(%ebp),%esi
  80085e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800861:	39 c6                	cmp    %eax,%esi
  800863:	73 30                	jae    800895 <memmove+0x42>
  800865:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800868:	39 c2                	cmp    %eax,%edx
  80086a:	76 29                	jbe    800895 <memmove+0x42>
		s += n;
		d += n;
  80086c:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80086f:	89 fe                	mov    %edi,%esi
  800871:	09 ce                	or     %ecx,%esi
  800873:	09 d6                	or     %edx,%esi
  800875:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80087b:	75 0e                	jne    80088b <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  80087d:	83 ef 04             	sub    $0x4,%edi
  800880:	8d 72 fc             	lea    -0x4(%edx),%esi
  800883:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800886:	fd                   	std    
  800887:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800889:	eb 07                	jmp    800892 <memmove+0x3f>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80088b:	4f                   	dec    %edi
  80088c:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  80088f:	fd                   	std    
  800890:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800892:	fc                   	cld    
  800893:	eb 1a                	jmp    8008af <memmove+0x5c>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800895:	89 c2                	mov    %eax,%edx
  800897:	09 ca                	or     %ecx,%edx
  800899:	09 f2                	or     %esi,%edx
  80089b:	f6 c2 03             	test   $0x3,%dl
  80089e:	75 0a                	jne    8008aa <memmove+0x57>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8008a0:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  8008a3:	89 c7                	mov    %eax,%edi
  8008a5:	fc                   	cld    
  8008a6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008a8:	eb 05                	jmp    8008af <memmove+0x5c>
		else
			asm volatile("cld; rep movsb\n"
  8008aa:	89 c7                	mov    %eax,%edi
  8008ac:	fc                   	cld    
  8008ad:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8008af:	5e                   	pop    %esi
  8008b0:	5f                   	pop    %edi
  8008b1:	5d                   	pop    %ebp
  8008b2:	c3                   	ret    

008008b3 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8008b3:	55                   	push   %ebp
  8008b4:	89 e5                	mov    %esp,%ebp
  8008b6:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8008b9:	ff 75 10             	pushl  0x10(%ebp)
  8008bc:	ff 75 0c             	pushl  0xc(%ebp)
  8008bf:	ff 75 08             	pushl  0x8(%ebp)
  8008c2:	e8 8c ff ff ff       	call   800853 <memmove>
}
  8008c7:	c9                   	leave  
  8008c8:	c3                   	ret    

008008c9 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8008c9:	55                   	push   %ebp
  8008ca:	89 e5                	mov    %esp,%ebp
  8008cc:	56                   	push   %esi
  8008cd:	53                   	push   %ebx
  8008ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008d4:	89 c6                	mov    %eax,%esi
  8008d6:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8008d9:	39 f0                	cmp    %esi,%eax
  8008db:	74 16                	je     8008f3 <memcmp+0x2a>
		if (*s1 != *s2)
  8008dd:	8a 08                	mov    (%eax),%cl
  8008df:	8a 1a                	mov    (%edx),%bl
  8008e1:	38 d9                	cmp    %bl,%cl
  8008e3:	75 04                	jne    8008e9 <memcmp+0x20>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  8008e5:	40                   	inc    %eax
  8008e6:	42                   	inc    %edx
  8008e7:	eb f0                	jmp    8008d9 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  8008e9:	0f b6 c1             	movzbl %cl,%eax
  8008ec:	0f b6 db             	movzbl %bl,%ebx
  8008ef:	29 d8                	sub    %ebx,%eax
  8008f1:	eb 05                	jmp    8008f8 <memcmp+0x2f>
	}

	return 0;
  8008f3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008f8:	5b                   	pop    %ebx
  8008f9:	5e                   	pop    %esi
  8008fa:	5d                   	pop    %ebp
  8008fb:	c3                   	ret    

008008fc <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8008fc:	55                   	push   %ebp
  8008fd:	89 e5                	mov    %esp,%ebp
  8008ff:	8b 45 08             	mov    0x8(%ebp),%eax
  800902:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800905:	89 c2                	mov    %eax,%edx
  800907:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  80090a:	39 d0                	cmp    %edx,%eax
  80090c:	73 07                	jae    800915 <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
  80090e:	38 08                	cmp    %cl,(%eax)
  800910:	74 03                	je     800915 <memfind+0x19>
	for (; s < ends; s++)
  800912:	40                   	inc    %eax
  800913:	eb f5                	jmp    80090a <memfind+0xe>
			break;
	return (void *) s;
}
  800915:	5d                   	pop    %ebp
  800916:	c3                   	ret    

00800917 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800917:	55                   	push   %ebp
  800918:	89 e5                	mov    %esp,%ebp
  80091a:	57                   	push   %edi
  80091b:	56                   	push   %esi
  80091c:	53                   	push   %ebx
  80091d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800920:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800923:	eb 01                	jmp    800926 <strtol+0xf>
		s++;
  800925:	41                   	inc    %ecx
	while (*s == ' ' || *s == '\t')
  800926:	8a 01                	mov    (%ecx),%al
  800928:	3c 20                	cmp    $0x20,%al
  80092a:	74 f9                	je     800925 <strtol+0xe>
  80092c:	3c 09                	cmp    $0x9,%al
  80092e:	74 f5                	je     800925 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800930:	3c 2b                	cmp    $0x2b,%al
  800932:	74 24                	je     800958 <strtol+0x41>
		s++;
	else if (*s == '-')
  800934:	3c 2d                	cmp    $0x2d,%al
  800936:	74 28                	je     800960 <strtol+0x49>
	int neg = 0;
  800938:	bf 00 00 00 00       	mov    $0x0,%edi
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80093d:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800943:	75 09                	jne    80094e <strtol+0x37>
  800945:	80 39 30             	cmpb   $0x30,(%ecx)
  800948:	74 1e                	je     800968 <strtol+0x51>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  80094a:	85 db                	test   %ebx,%ebx
  80094c:	74 36                	je     800984 <strtol+0x6d>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  80094e:	b8 00 00 00 00       	mov    $0x0,%eax
  800953:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800956:	eb 45                	jmp    80099d <strtol+0x86>
		s++;
  800958:	41                   	inc    %ecx
	int neg = 0;
  800959:	bf 00 00 00 00       	mov    $0x0,%edi
  80095e:	eb dd                	jmp    80093d <strtol+0x26>
		s++, neg = 1;
  800960:	41                   	inc    %ecx
  800961:	bf 01 00 00 00       	mov    $0x1,%edi
  800966:	eb d5                	jmp    80093d <strtol+0x26>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800968:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  80096c:	74 0c                	je     80097a <strtol+0x63>
	else if (base == 0 && s[0] == '0')
  80096e:	85 db                	test   %ebx,%ebx
  800970:	75 dc                	jne    80094e <strtol+0x37>
		s++, base = 8;
  800972:	41                   	inc    %ecx
  800973:	bb 08 00 00 00       	mov    $0x8,%ebx
  800978:	eb d4                	jmp    80094e <strtol+0x37>
		s += 2, base = 16;
  80097a:	83 c1 02             	add    $0x2,%ecx
  80097d:	bb 10 00 00 00       	mov    $0x10,%ebx
  800982:	eb ca                	jmp    80094e <strtol+0x37>
		base = 10;
  800984:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800989:	eb c3                	jmp    80094e <strtol+0x37>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  80098b:	0f be d2             	movsbl %dl,%edx
  80098e:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800991:	3b 55 10             	cmp    0x10(%ebp),%edx
  800994:	7d 37                	jge    8009cd <strtol+0xb6>
			break;
		s++, val = (val * base) + dig;
  800996:	41                   	inc    %ecx
  800997:	0f af 45 10          	imul   0x10(%ebp),%eax
  80099b:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  80099d:	8a 11                	mov    (%ecx),%dl
  80099f:	8d 72 d0             	lea    -0x30(%edx),%esi
  8009a2:	89 f3                	mov    %esi,%ebx
  8009a4:	80 fb 09             	cmp    $0x9,%bl
  8009a7:	76 e2                	jbe    80098b <strtol+0x74>
		else if (*s >= 'a' && *s <= 'z')
  8009a9:	8d 72 9f             	lea    -0x61(%edx),%esi
  8009ac:	89 f3                	mov    %esi,%ebx
  8009ae:	80 fb 19             	cmp    $0x19,%bl
  8009b1:	77 08                	ja     8009bb <strtol+0xa4>
			dig = *s - 'a' + 10;
  8009b3:	0f be d2             	movsbl %dl,%edx
  8009b6:	83 ea 57             	sub    $0x57,%edx
  8009b9:	eb d6                	jmp    800991 <strtol+0x7a>
		else if (*s >= 'A' && *s <= 'Z')
  8009bb:	8d 72 bf             	lea    -0x41(%edx),%esi
  8009be:	89 f3                	mov    %esi,%ebx
  8009c0:	80 fb 19             	cmp    $0x19,%bl
  8009c3:	77 08                	ja     8009cd <strtol+0xb6>
			dig = *s - 'A' + 10;
  8009c5:	0f be d2             	movsbl %dl,%edx
  8009c8:	83 ea 37             	sub    $0x37,%edx
  8009cb:	eb c4                	jmp    800991 <strtol+0x7a>
		// we don't properly detect overflow!
	}

	if (endptr)
  8009cd:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8009d1:	74 05                	je     8009d8 <strtol+0xc1>
		*endptr = (char *) s;
  8009d3:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009d6:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  8009d8:	85 ff                	test   %edi,%edi
  8009da:	74 02                	je     8009de <strtol+0xc7>
  8009dc:	f7 d8                	neg    %eax
}
  8009de:	5b                   	pop    %ebx
  8009df:	5e                   	pop    %esi
  8009e0:	5f                   	pop    %edi
  8009e1:	5d                   	pop    %ebp
  8009e2:	c3                   	ret    

008009e3 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8009e3:	55                   	push   %ebp
  8009e4:	89 e5                	mov    %esp,%ebp
  8009e6:	57                   	push   %edi
  8009e7:	56                   	push   %esi
  8009e8:	53                   	push   %ebx
	asm volatile("int %1\n"
  8009e9:	b8 00 00 00 00       	mov    $0x0,%eax
  8009ee:	8b 55 08             	mov    0x8(%ebp),%edx
  8009f1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009f4:	89 c3                	mov    %eax,%ebx
  8009f6:	89 c7                	mov    %eax,%edi
  8009f8:	89 c6                	mov    %eax,%esi
  8009fa:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8009fc:	5b                   	pop    %ebx
  8009fd:	5e                   	pop    %esi
  8009fe:	5f                   	pop    %edi
  8009ff:	5d                   	pop    %ebp
  800a00:	c3                   	ret    

00800a01 <sys_cgetc>:

int
sys_cgetc(void)
{
  800a01:	55                   	push   %ebp
  800a02:	89 e5                	mov    %esp,%ebp
  800a04:	57                   	push   %edi
  800a05:	56                   	push   %esi
  800a06:	53                   	push   %ebx
	asm volatile("int %1\n"
  800a07:	ba 00 00 00 00       	mov    $0x0,%edx
  800a0c:	b8 01 00 00 00       	mov    $0x1,%eax
  800a11:	89 d1                	mov    %edx,%ecx
  800a13:	89 d3                	mov    %edx,%ebx
  800a15:	89 d7                	mov    %edx,%edi
  800a17:	89 d6                	mov    %edx,%esi
  800a19:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800a1b:	5b                   	pop    %ebx
  800a1c:	5e                   	pop    %esi
  800a1d:	5f                   	pop    %edi
  800a1e:	5d                   	pop    %ebp
  800a1f:	c3                   	ret    

00800a20 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800a20:	55                   	push   %ebp
  800a21:	89 e5                	mov    %esp,%ebp
  800a23:	57                   	push   %edi
  800a24:	56                   	push   %esi
  800a25:	53                   	push   %ebx
  800a26:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800a29:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a2e:	8b 55 08             	mov    0x8(%ebp),%edx
  800a31:	b8 03 00 00 00       	mov    $0x3,%eax
  800a36:	89 cb                	mov    %ecx,%ebx
  800a38:	89 cf                	mov    %ecx,%edi
  800a3a:	89 ce                	mov    %ecx,%esi
  800a3c:	cd 30                	int    $0x30
	if(check && ret > 0)
  800a3e:	85 c0                	test   %eax,%eax
  800a40:	7f 08                	jg     800a4a <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800a42:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a45:	5b                   	pop    %ebx
  800a46:	5e                   	pop    %esi
  800a47:	5f                   	pop    %edi
  800a48:	5d                   	pop    %ebp
  800a49:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800a4a:	83 ec 0c             	sub    $0xc,%esp
  800a4d:	50                   	push   %eax
  800a4e:	6a 03                	push   $0x3
  800a50:	68 24 0f 80 00       	push   $0x800f24
  800a55:	6a 23                	push   $0x23
  800a57:	68 41 0f 80 00       	push   $0x800f41
  800a5c:	e8 1f 00 00 00       	call   800a80 <_panic>

00800a61 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800a61:	55                   	push   %ebp
  800a62:	89 e5                	mov    %esp,%ebp
  800a64:	57                   	push   %edi
  800a65:	56                   	push   %esi
  800a66:	53                   	push   %ebx
	asm volatile("int %1\n"
  800a67:	ba 00 00 00 00       	mov    $0x0,%edx
  800a6c:	b8 02 00 00 00       	mov    $0x2,%eax
  800a71:	89 d1                	mov    %edx,%ecx
  800a73:	89 d3                	mov    %edx,%ebx
  800a75:	89 d7                	mov    %edx,%edi
  800a77:	89 d6                	mov    %edx,%esi
  800a79:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800a7b:	5b                   	pop    %ebx
  800a7c:	5e                   	pop    %esi
  800a7d:	5f                   	pop    %edi
  800a7e:	5d                   	pop    %ebp
  800a7f:	c3                   	ret    

00800a80 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800a80:	55                   	push   %ebp
  800a81:	89 e5                	mov    %esp,%ebp
  800a83:	56                   	push   %esi
  800a84:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800a85:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800a88:	8b 35 00 10 80 00    	mov    0x801000,%esi
  800a8e:	e8 ce ff ff ff       	call   800a61 <sys_getenvid>
  800a93:	83 ec 0c             	sub    $0xc,%esp
  800a96:	ff 75 0c             	pushl  0xc(%ebp)
  800a99:	ff 75 08             	pushl  0x8(%ebp)
  800a9c:	56                   	push   %esi
  800a9d:	50                   	push   %eax
  800a9e:	68 50 0f 80 00       	push   $0x800f50
  800aa3:	e8 82 f6 ff ff       	call   80012a <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800aa8:	83 c4 18             	add    $0x18,%esp
  800aab:	53                   	push   %ebx
  800aac:	ff 75 10             	pushl  0x10(%ebp)
  800aaf:	e8 25 f6 ff ff       	call   8000d9 <vcprintf>
	cprintf("\n");
  800ab4:	c7 04 24 74 0f 80 00 	movl   $0x800f74,(%esp)
  800abb:	e8 6a f6 ff ff       	call   80012a <cprintf>
  800ac0:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800ac3:	cc                   	int3   
  800ac4:	eb fd                	jmp    800ac3 <_panic+0x43>
  800ac6:	66 90                	xchg   %ax,%ax

00800ac8 <__udivdi3>:
  800ac8:	55                   	push   %ebp
  800ac9:	57                   	push   %edi
  800aca:	56                   	push   %esi
  800acb:	53                   	push   %ebx
  800acc:	83 ec 1c             	sub    $0x1c,%esp
  800acf:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800ad3:	8b 74 24 34          	mov    0x34(%esp),%esi
  800ad7:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800adb:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800adf:	85 d2                	test   %edx,%edx
  800ae1:	75 19                	jne    800afc <__udivdi3+0x34>
  800ae3:	39 f7                	cmp    %esi,%edi
  800ae5:	76 45                	jbe    800b2c <__udivdi3+0x64>
  800ae7:	89 e8                	mov    %ebp,%eax
  800ae9:	89 f2                	mov    %esi,%edx
  800aeb:	f7 f7                	div    %edi
  800aed:	31 db                	xor    %ebx,%ebx
  800aef:	89 da                	mov    %ebx,%edx
  800af1:	83 c4 1c             	add    $0x1c,%esp
  800af4:	5b                   	pop    %ebx
  800af5:	5e                   	pop    %esi
  800af6:	5f                   	pop    %edi
  800af7:	5d                   	pop    %ebp
  800af8:	c3                   	ret    
  800af9:	8d 76 00             	lea    0x0(%esi),%esi
  800afc:	39 f2                	cmp    %esi,%edx
  800afe:	76 10                	jbe    800b10 <__udivdi3+0x48>
  800b00:	31 db                	xor    %ebx,%ebx
  800b02:	31 c0                	xor    %eax,%eax
  800b04:	89 da                	mov    %ebx,%edx
  800b06:	83 c4 1c             	add    $0x1c,%esp
  800b09:	5b                   	pop    %ebx
  800b0a:	5e                   	pop    %esi
  800b0b:	5f                   	pop    %edi
  800b0c:	5d                   	pop    %ebp
  800b0d:	c3                   	ret    
  800b0e:	66 90                	xchg   %ax,%ax
  800b10:	0f bd da             	bsr    %edx,%ebx
  800b13:	83 f3 1f             	xor    $0x1f,%ebx
  800b16:	75 3c                	jne    800b54 <__udivdi3+0x8c>
  800b18:	39 f2                	cmp    %esi,%edx
  800b1a:	72 08                	jb     800b24 <__udivdi3+0x5c>
  800b1c:	39 ef                	cmp    %ebp,%edi
  800b1e:	0f 87 9c 00 00 00    	ja     800bc0 <__udivdi3+0xf8>
  800b24:	b8 01 00 00 00       	mov    $0x1,%eax
  800b29:	eb d9                	jmp    800b04 <__udivdi3+0x3c>
  800b2b:	90                   	nop
  800b2c:	89 f9                	mov    %edi,%ecx
  800b2e:	85 ff                	test   %edi,%edi
  800b30:	75 0b                	jne    800b3d <__udivdi3+0x75>
  800b32:	b8 01 00 00 00       	mov    $0x1,%eax
  800b37:	31 d2                	xor    %edx,%edx
  800b39:	f7 f7                	div    %edi
  800b3b:	89 c1                	mov    %eax,%ecx
  800b3d:	31 d2                	xor    %edx,%edx
  800b3f:	89 f0                	mov    %esi,%eax
  800b41:	f7 f1                	div    %ecx
  800b43:	89 c3                	mov    %eax,%ebx
  800b45:	89 e8                	mov    %ebp,%eax
  800b47:	f7 f1                	div    %ecx
  800b49:	89 da                	mov    %ebx,%edx
  800b4b:	83 c4 1c             	add    $0x1c,%esp
  800b4e:	5b                   	pop    %ebx
  800b4f:	5e                   	pop    %esi
  800b50:	5f                   	pop    %edi
  800b51:	5d                   	pop    %ebp
  800b52:	c3                   	ret    
  800b53:	90                   	nop
  800b54:	b8 20 00 00 00       	mov    $0x20,%eax
  800b59:	29 d8                	sub    %ebx,%eax
  800b5b:	88 d9                	mov    %bl,%cl
  800b5d:	d3 e2                	shl    %cl,%edx
  800b5f:	89 54 24 08          	mov    %edx,0x8(%esp)
  800b63:	89 fa                	mov    %edi,%edx
  800b65:	88 c1                	mov    %al,%cl
  800b67:	d3 ea                	shr    %cl,%edx
  800b69:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800b6d:	09 d1                	or     %edx,%ecx
  800b6f:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800b73:	88 d9                	mov    %bl,%cl
  800b75:	d3 e7                	shl    %cl,%edi
  800b77:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800b7b:	89 f7                	mov    %esi,%edi
  800b7d:	88 c1                	mov    %al,%cl
  800b7f:	d3 ef                	shr    %cl,%edi
  800b81:	88 d9                	mov    %bl,%cl
  800b83:	d3 e6                	shl    %cl,%esi
  800b85:	89 ea                	mov    %ebp,%edx
  800b87:	88 c1                	mov    %al,%cl
  800b89:	d3 ea                	shr    %cl,%edx
  800b8b:	09 d6                	or     %edx,%esi
  800b8d:	89 f0                	mov    %esi,%eax
  800b8f:	89 fa                	mov    %edi,%edx
  800b91:	f7 74 24 08          	divl   0x8(%esp)
  800b95:	89 d7                	mov    %edx,%edi
  800b97:	89 c6                	mov    %eax,%esi
  800b99:	f7 64 24 0c          	mull   0xc(%esp)
  800b9d:	39 d7                	cmp    %edx,%edi
  800b9f:	72 13                	jb     800bb4 <__udivdi3+0xec>
  800ba1:	74 09                	je     800bac <__udivdi3+0xe4>
  800ba3:	89 f0                	mov    %esi,%eax
  800ba5:	31 db                	xor    %ebx,%ebx
  800ba7:	e9 58 ff ff ff       	jmp    800b04 <__udivdi3+0x3c>
  800bac:	88 d9                	mov    %bl,%cl
  800bae:	d3 e5                	shl    %cl,%ebp
  800bb0:	39 c5                	cmp    %eax,%ebp
  800bb2:	73 ef                	jae    800ba3 <__udivdi3+0xdb>
  800bb4:	8d 46 ff             	lea    -0x1(%esi),%eax
  800bb7:	31 db                	xor    %ebx,%ebx
  800bb9:	e9 46 ff ff ff       	jmp    800b04 <__udivdi3+0x3c>
  800bbe:	66 90                	xchg   %ax,%ax
  800bc0:	31 c0                	xor    %eax,%eax
  800bc2:	e9 3d ff ff ff       	jmp    800b04 <__udivdi3+0x3c>
  800bc7:	90                   	nop

00800bc8 <__umoddi3>:
  800bc8:	55                   	push   %ebp
  800bc9:	57                   	push   %edi
  800bca:	56                   	push   %esi
  800bcb:	53                   	push   %ebx
  800bcc:	83 ec 1c             	sub    $0x1c,%esp
  800bcf:	8b 74 24 30          	mov    0x30(%esp),%esi
  800bd3:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800bd7:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800bdb:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  800bdf:	85 c0                	test   %eax,%eax
  800be1:	75 19                	jne    800bfc <__umoddi3+0x34>
  800be3:	39 df                	cmp    %ebx,%edi
  800be5:	76 51                	jbe    800c38 <__umoddi3+0x70>
  800be7:	89 f0                	mov    %esi,%eax
  800be9:	89 da                	mov    %ebx,%edx
  800beb:	f7 f7                	div    %edi
  800bed:	89 d0                	mov    %edx,%eax
  800bef:	31 d2                	xor    %edx,%edx
  800bf1:	83 c4 1c             	add    $0x1c,%esp
  800bf4:	5b                   	pop    %ebx
  800bf5:	5e                   	pop    %esi
  800bf6:	5f                   	pop    %edi
  800bf7:	5d                   	pop    %ebp
  800bf8:	c3                   	ret    
  800bf9:	8d 76 00             	lea    0x0(%esi),%esi
  800bfc:	89 f2                	mov    %esi,%edx
  800bfe:	39 d8                	cmp    %ebx,%eax
  800c00:	76 0e                	jbe    800c10 <__umoddi3+0x48>
  800c02:	89 f0                	mov    %esi,%eax
  800c04:	89 da                	mov    %ebx,%edx
  800c06:	83 c4 1c             	add    $0x1c,%esp
  800c09:	5b                   	pop    %ebx
  800c0a:	5e                   	pop    %esi
  800c0b:	5f                   	pop    %edi
  800c0c:	5d                   	pop    %ebp
  800c0d:	c3                   	ret    
  800c0e:	66 90                	xchg   %ax,%ax
  800c10:	0f bd e8             	bsr    %eax,%ebp
  800c13:	83 f5 1f             	xor    $0x1f,%ebp
  800c16:	75 44                	jne    800c5c <__umoddi3+0x94>
  800c18:	39 d8                	cmp    %ebx,%eax
  800c1a:	72 06                	jb     800c22 <__umoddi3+0x5a>
  800c1c:	89 d9                	mov    %ebx,%ecx
  800c1e:	39 f7                	cmp    %esi,%edi
  800c20:	77 08                	ja     800c2a <__umoddi3+0x62>
  800c22:	29 fe                	sub    %edi,%esi
  800c24:	19 c3                	sbb    %eax,%ebx
  800c26:	89 f2                	mov    %esi,%edx
  800c28:	89 d9                	mov    %ebx,%ecx
  800c2a:	89 d0                	mov    %edx,%eax
  800c2c:	89 ca                	mov    %ecx,%edx
  800c2e:	83 c4 1c             	add    $0x1c,%esp
  800c31:	5b                   	pop    %ebx
  800c32:	5e                   	pop    %esi
  800c33:	5f                   	pop    %edi
  800c34:	5d                   	pop    %ebp
  800c35:	c3                   	ret    
  800c36:	66 90                	xchg   %ax,%ax
  800c38:	89 fd                	mov    %edi,%ebp
  800c3a:	85 ff                	test   %edi,%edi
  800c3c:	75 0b                	jne    800c49 <__umoddi3+0x81>
  800c3e:	b8 01 00 00 00       	mov    $0x1,%eax
  800c43:	31 d2                	xor    %edx,%edx
  800c45:	f7 f7                	div    %edi
  800c47:	89 c5                	mov    %eax,%ebp
  800c49:	89 d8                	mov    %ebx,%eax
  800c4b:	31 d2                	xor    %edx,%edx
  800c4d:	f7 f5                	div    %ebp
  800c4f:	89 f0                	mov    %esi,%eax
  800c51:	f7 f5                	div    %ebp
  800c53:	89 d0                	mov    %edx,%eax
  800c55:	31 d2                	xor    %edx,%edx
  800c57:	eb 98                	jmp    800bf1 <__umoddi3+0x29>
  800c59:	8d 76 00             	lea    0x0(%esi),%esi
  800c5c:	ba 20 00 00 00       	mov    $0x20,%edx
  800c61:	29 ea                	sub    %ebp,%edx
  800c63:	89 e9                	mov    %ebp,%ecx
  800c65:	d3 e0                	shl    %cl,%eax
  800c67:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c6b:	89 f8                	mov    %edi,%eax
  800c6d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800c71:	88 d1                	mov    %dl,%cl
  800c73:	d3 e8                	shr    %cl,%eax
  800c75:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800c79:	09 c1                	or     %eax,%ecx
  800c7b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800c7f:	89 e9                	mov    %ebp,%ecx
  800c81:	d3 e7                	shl    %cl,%edi
  800c83:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800c87:	89 d8                	mov    %ebx,%eax
  800c89:	8b 54 24 04          	mov    0x4(%esp),%edx
  800c8d:	88 d1                	mov    %dl,%cl
  800c8f:	d3 e8                	shr    %cl,%eax
  800c91:	89 c7                	mov    %eax,%edi
  800c93:	89 e9                	mov    %ebp,%ecx
  800c95:	d3 e3                	shl    %cl,%ebx
  800c97:	89 f0                	mov    %esi,%eax
  800c99:	88 d1                	mov    %dl,%cl
  800c9b:	d3 e8                	shr    %cl,%eax
  800c9d:	09 d8                	or     %ebx,%eax
  800c9f:	89 e9                	mov    %ebp,%ecx
  800ca1:	d3 e6                	shl    %cl,%esi
  800ca3:	89 f3                	mov    %esi,%ebx
  800ca5:	89 fa                	mov    %edi,%edx
  800ca7:	f7 74 24 08          	divl   0x8(%esp)
  800cab:	89 d1                	mov    %edx,%ecx
  800cad:	f7 64 24 0c          	mull   0xc(%esp)
  800cb1:	89 c6                	mov    %eax,%esi
  800cb3:	89 d7                	mov    %edx,%edi
  800cb5:	39 d1                	cmp    %edx,%ecx
  800cb7:	72 27                	jb     800ce0 <__umoddi3+0x118>
  800cb9:	74 21                	je     800cdc <__umoddi3+0x114>
  800cbb:	89 ca                	mov    %ecx,%edx
  800cbd:	29 f3                	sub    %esi,%ebx
  800cbf:	19 fa                	sbb    %edi,%edx
  800cc1:	89 d0                	mov    %edx,%eax
  800cc3:	8a 4c 24 04          	mov    0x4(%esp),%cl
  800cc7:	d3 e0                	shl    %cl,%eax
  800cc9:	89 e9                	mov    %ebp,%ecx
  800ccb:	d3 eb                	shr    %cl,%ebx
  800ccd:	09 d8                	or     %ebx,%eax
  800ccf:	d3 ea                	shr    %cl,%edx
  800cd1:	83 c4 1c             	add    $0x1c,%esp
  800cd4:	5b                   	pop    %ebx
  800cd5:	5e                   	pop    %esi
  800cd6:	5f                   	pop    %edi
  800cd7:	5d                   	pop    %ebp
  800cd8:	c3                   	ret    
  800cd9:	8d 76 00             	lea    0x0(%esi),%esi
  800cdc:	39 c3                	cmp    %eax,%ebx
  800cde:	73 db                	jae    800cbb <__umoddi3+0xf3>
  800ce0:	2b 44 24 0c          	sub    0xc(%esp),%eax
  800ce4:	1b 54 24 08          	sbb    0x8(%esp),%edx
  800ce8:	89 d7                	mov    %edx,%edi
  800cea:	89 c6                	mov    %eax,%esi
  800cec:	eb cd                	jmp    800cbb <__umoddi3+0xf3>
