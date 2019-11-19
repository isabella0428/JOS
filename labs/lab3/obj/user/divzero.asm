
obj/user/divzero:     file format elf32-i386


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
  80002c:	e8 2f 00 00 00       	call   800060 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

int zero;

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	zero = 0;
  800039:	c7 05 04 10 80 00 00 	movl   $0x0,0x801004
  800040:	00 00 00 
	cprintf("1/0 is %08x!\n", 1/zero);
  800043:	b8 01 00 00 00       	mov    $0x1,%eax
  800048:	b9 00 00 00 00       	mov    $0x0,%ecx
  80004d:	99                   	cltd   
  80004e:	f7 f9                	idiv   %ecx
  800050:	50                   	push   %eax
  800051:	68 2c 0d 80 00       	push   $0x800d2c
  800056:	e8 0a 01 00 00       	call   800165 <cprintf>
}
  80005b:	83 c4 10             	add    $0x10,%esp
  80005e:	c9                   	leave  
  80005f:	c3                   	ret    

00800060 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800060:	55                   	push   %ebp
  800061:	89 e5                	mov    %esp,%ebp
  800063:	57                   	push   %edi
  800064:	56                   	push   %esi
  800065:	53                   	push   %ebx
  800066:	83 ec 6c             	sub    $0x6c,%esp
  800069:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	struct Env curenv = envs[ENVX(sys_getenvid())];
  80006c:	e8 2b 0a 00 00       	call   800a9c <sys_getenvid>
  800071:	25 ff 03 00 00       	and    $0x3ff,%eax
  800076:	8d 34 00             	lea    (%eax,%eax,1),%esi
  800079:	01 c6                	add    %eax,%esi
  80007b:	c1 e6 05             	shl    $0x5,%esi
  80007e:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  800084:	8d 7d 88             	lea    -0x78(%ebp),%edi
  800087:	b9 18 00 00 00       	mov    $0x18,%ecx
  80008c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	thisenv = &curenv;
  80008e:	8d 45 88             	lea    -0x78(%ebp),%eax
  800091:	a3 08 10 80 00       	mov    %eax,0x801008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800096:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  80009a:	7e 07                	jle    8000a3 <libmain+0x43>
		binaryname = argv[0];
  80009c:	8b 03                	mov    (%ebx),%eax
  80009e:	a3 00 10 80 00       	mov    %eax,0x801000
	
	// call user main routine
	umain(argc, argv);
  8000a3:	83 ec 08             	sub    $0x8,%esp
  8000a6:	53                   	push   %ebx
  8000a7:	ff 75 08             	pushl  0x8(%ebp)
  8000aa:	e8 84 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000af:	e8 0b 00 00 00       	call   8000bf <exit>
}
  8000b4:	83 c4 10             	add    $0x10,%esp
  8000b7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000ba:	5b                   	pop    %ebx
  8000bb:	5e                   	pop    %esi
  8000bc:	5f                   	pop    %edi
  8000bd:	5d                   	pop    %ebp
  8000be:	c3                   	ret    

008000bf <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000bf:	55                   	push   %ebp
  8000c0:	89 e5                	mov    %esp,%ebp
  8000c2:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8000c5:	6a 00                	push   $0x0
  8000c7:	e8 8f 09 00 00       	call   800a5b <sys_env_destroy>
}
  8000cc:	83 c4 10             	add    $0x10,%esp
  8000cf:	c9                   	leave  
  8000d0:	c3                   	ret    

008000d1 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000d1:	55                   	push   %ebp
  8000d2:	89 e5                	mov    %esp,%ebp
  8000d4:	53                   	push   %ebx
  8000d5:	83 ec 04             	sub    $0x4,%esp
  8000d8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000db:	8b 13                	mov    (%ebx),%edx
  8000dd:	8d 42 01             	lea    0x1(%edx),%eax
  8000e0:	89 03                	mov    %eax,(%ebx)
  8000e2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000e5:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000e9:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000ee:	74 08                	je     8000f8 <putch+0x27>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8000f0:	ff 43 04             	incl   0x4(%ebx)
}
  8000f3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000f6:	c9                   	leave  
  8000f7:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8000f8:	83 ec 08             	sub    $0x8,%esp
  8000fb:	68 ff 00 00 00       	push   $0xff
  800100:	8d 43 08             	lea    0x8(%ebx),%eax
  800103:	50                   	push   %eax
  800104:	e8 15 09 00 00       	call   800a1e <sys_cputs>
		b->idx = 0;
  800109:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80010f:	83 c4 10             	add    $0x10,%esp
  800112:	eb dc                	jmp    8000f0 <putch+0x1f>

00800114 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800114:	55                   	push   %ebp
  800115:	89 e5                	mov    %esp,%ebp
  800117:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80011d:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800124:	00 00 00 
	b.cnt = 0;
  800127:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80012e:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800131:	ff 75 0c             	pushl  0xc(%ebp)
  800134:	ff 75 08             	pushl  0x8(%ebp)
  800137:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80013d:	50                   	push   %eax
  80013e:	68 d1 00 80 00       	push   $0x8000d1
  800143:	e8 0f 01 00 00       	call   800257 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800148:	83 c4 08             	add    $0x8,%esp
  80014b:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800151:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800157:	50                   	push   %eax
  800158:	e8 c1 08 00 00       	call   800a1e <sys_cputs>

	return b.cnt;
}
  80015d:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800163:	c9                   	leave  
  800164:	c3                   	ret    

00800165 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800165:	55                   	push   %ebp
  800166:	89 e5                	mov    %esp,%ebp
  800168:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80016b:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80016e:	50                   	push   %eax
  80016f:	ff 75 08             	pushl  0x8(%ebp)
  800172:	e8 9d ff ff ff       	call   800114 <vcprintf>
	va_end(ap);

	return cnt;
}
  800177:	c9                   	leave  
  800178:	c3                   	ret    

00800179 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800179:	55                   	push   %ebp
  80017a:	89 e5                	mov    %esp,%ebp
  80017c:	57                   	push   %edi
  80017d:	56                   	push   %esi
  80017e:	53                   	push   %ebx
  80017f:	83 ec 1c             	sub    $0x1c,%esp
  800182:	89 c7                	mov    %eax,%edi
  800184:	89 d6                	mov    %edx,%esi
  800186:	8b 45 08             	mov    0x8(%ebp),%eax
  800189:	8b 55 0c             	mov    0xc(%ebp),%edx
  80018c:	89 d1                	mov    %edx,%ecx
  80018e:	89 c2                	mov    %eax,%edx
  800190:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800193:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800196:	8b 45 10             	mov    0x10(%ebp),%eax
  800199:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80019c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80019f:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8001a6:	39 c2                	cmp    %eax,%edx
  8001a8:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  8001ab:	72 3c                	jb     8001e9 <printnum+0x70>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001ad:	83 ec 0c             	sub    $0xc,%esp
  8001b0:	ff 75 18             	pushl  0x18(%ebp)
  8001b3:	4b                   	dec    %ebx
  8001b4:	53                   	push   %ebx
  8001b5:	50                   	push   %eax
  8001b6:	83 ec 08             	sub    $0x8,%esp
  8001b9:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001bc:	ff 75 e0             	pushl  -0x20(%ebp)
  8001bf:	ff 75 dc             	pushl  -0x24(%ebp)
  8001c2:	ff 75 d8             	pushl  -0x28(%ebp)
  8001c5:	e8 3a 09 00 00       	call   800b04 <__udivdi3>
  8001ca:	83 c4 18             	add    $0x18,%esp
  8001cd:	52                   	push   %edx
  8001ce:	50                   	push   %eax
  8001cf:	89 f2                	mov    %esi,%edx
  8001d1:	89 f8                	mov    %edi,%eax
  8001d3:	e8 a1 ff ff ff       	call   800179 <printnum>
  8001d8:	83 c4 20             	add    $0x20,%esp
  8001db:	eb 11                	jmp    8001ee <printnum+0x75>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001dd:	83 ec 08             	sub    $0x8,%esp
  8001e0:	56                   	push   %esi
  8001e1:	ff 75 18             	pushl  0x18(%ebp)
  8001e4:	ff d7                	call   *%edi
  8001e6:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8001e9:	4b                   	dec    %ebx
  8001ea:	85 db                	test   %ebx,%ebx
  8001ec:	7f ef                	jg     8001dd <printnum+0x64>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8001ee:	83 ec 08             	sub    $0x8,%esp
  8001f1:	56                   	push   %esi
  8001f2:	83 ec 04             	sub    $0x4,%esp
  8001f5:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001f8:	ff 75 e0             	pushl  -0x20(%ebp)
  8001fb:	ff 75 dc             	pushl  -0x24(%ebp)
  8001fe:	ff 75 d8             	pushl  -0x28(%ebp)
  800201:	e8 fe 09 00 00       	call   800c04 <__umoddi3>
  800206:	83 c4 14             	add    $0x14,%esp
  800209:	0f be 80 44 0d 80 00 	movsbl 0x800d44(%eax),%eax
  800210:	50                   	push   %eax
  800211:	ff d7                	call   *%edi
}
  800213:	83 c4 10             	add    $0x10,%esp
  800216:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800219:	5b                   	pop    %ebx
  80021a:	5e                   	pop    %esi
  80021b:	5f                   	pop    %edi
  80021c:	5d                   	pop    %ebp
  80021d:	c3                   	ret    

0080021e <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80021e:	55                   	push   %ebp
  80021f:	89 e5                	mov    %esp,%ebp
  800221:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800224:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800227:	8b 10                	mov    (%eax),%edx
  800229:	3b 50 04             	cmp    0x4(%eax),%edx
  80022c:	73 0a                	jae    800238 <sprintputch+0x1a>
		*b->buf++ = ch;
  80022e:	8d 4a 01             	lea    0x1(%edx),%ecx
  800231:	89 08                	mov    %ecx,(%eax)
  800233:	8b 45 08             	mov    0x8(%ebp),%eax
  800236:	88 02                	mov    %al,(%edx)
}
  800238:	5d                   	pop    %ebp
  800239:	c3                   	ret    

0080023a <printfmt>:
{
  80023a:	55                   	push   %ebp
  80023b:	89 e5                	mov    %esp,%ebp
  80023d:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800240:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800243:	50                   	push   %eax
  800244:	ff 75 10             	pushl  0x10(%ebp)
  800247:	ff 75 0c             	pushl  0xc(%ebp)
  80024a:	ff 75 08             	pushl  0x8(%ebp)
  80024d:	e8 05 00 00 00       	call   800257 <vprintfmt>
}
  800252:	83 c4 10             	add    $0x10,%esp
  800255:	c9                   	leave  
  800256:	c3                   	ret    

00800257 <vprintfmt>:
{
  800257:	55                   	push   %ebp
  800258:	89 e5                	mov    %esp,%ebp
  80025a:	57                   	push   %edi
  80025b:	56                   	push   %esi
  80025c:	53                   	push   %ebx
  80025d:	83 ec 3c             	sub    $0x3c,%esp
  800260:	8b 75 08             	mov    0x8(%ebp),%esi
  800263:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800266:	8b 7d 10             	mov    0x10(%ebp),%edi
  800269:	e9 5b 03 00 00       	jmp    8005c9 <vprintfmt+0x372>
		padc = ' ';
  80026e:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  800272:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
		precision = -1;
  800279:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  800280:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		lflag = 0;
  800287:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80028c:	8d 47 01             	lea    0x1(%edi),%eax
  80028f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800292:	8a 17                	mov    (%edi),%dl
  800294:	8d 42 dd             	lea    -0x23(%edx),%eax
  800297:	3c 55                	cmp    $0x55,%al
  800299:	0f 87 ab 03 00 00    	ja     80064a <vprintfmt+0x3f3>
  80029f:	0f b6 c0             	movzbl %al,%eax
  8002a2:	ff 24 85 d4 0d 80 00 	jmp    *0x800dd4(,%eax,4)
  8002a9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  8002ac:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  8002b0:	eb da                	jmp    80028c <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  8002b2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8002b5:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  8002b9:	eb d1                	jmp    80028c <vprintfmt+0x35>
  8002bb:	0f b6 d2             	movzbl %dl,%edx
  8002be:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  8002c1:	b8 00 00 00 00       	mov    $0x0,%eax
  8002c6:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  8002c9:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8002cc:	01 c0                	add    %eax,%eax
  8002ce:	8d 44 02 d0          	lea    -0x30(%edx,%eax,1),%eax
				ch = *fmt;
  8002d2:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8002d5:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8002d8:	83 f9 09             	cmp    $0x9,%ecx
  8002db:	77 52                	ja     80032f <vprintfmt+0xd8>
			for (precision = 0; ; ++fmt) {
  8002dd:	47                   	inc    %edi
				precision = precision * 10 + ch - '0';
  8002de:	eb e9                	jmp    8002c9 <vprintfmt+0x72>
			precision = va_arg(ap, int);
  8002e0:	8b 45 14             	mov    0x14(%ebp),%eax
  8002e3:	8b 00                	mov    (%eax),%eax
  8002e5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002e8:	8b 45 14             	mov    0x14(%ebp),%eax
  8002eb:	8d 40 04             	lea    0x4(%eax),%eax
  8002ee:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8002f1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8002f4:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8002f8:	79 92                	jns    80028c <vprintfmt+0x35>
				width = precision, precision = -1;
  8002fa:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8002fd:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800300:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  800307:	eb 83                	jmp    80028c <vprintfmt+0x35>
  800309:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80030d:	78 08                	js     800317 <vprintfmt+0xc0>
		switch (ch = *(unsigned char *) fmt++) {
  80030f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800312:	e9 75 ff ff ff       	jmp    80028c <vprintfmt+0x35>
  800317:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  80031e:	eb ef                	jmp    80030f <vprintfmt+0xb8>
		switch (ch = *(unsigned char *) fmt++) {
  800320:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800323:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  80032a:	e9 5d ff ff ff       	jmp    80028c <vprintfmt+0x35>
  80032f:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800332:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800335:	eb bd                	jmp    8002f4 <vprintfmt+0x9d>
			lflag++;
  800337:	41                   	inc    %ecx
		switch (ch = *(unsigned char *) fmt++) {
  800338:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80033b:	e9 4c ff ff ff       	jmp    80028c <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
  800340:	8b 45 14             	mov    0x14(%ebp),%eax
  800343:	8d 78 04             	lea    0x4(%eax),%edi
  800346:	83 ec 08             	sub    $0x8,%esp
  800349:	53                   	push   %ebx
  80034a:	ff 30                	pushl  (%eax)
  80034c:	ff d6                	call   *%esi
			break;
  80034e:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800351:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800354:	e9 6d 02 00 00       	jmp    8005c6 <vprintfmt+0x36f>
			err = va_arg(ap, int);
  800359:	8b 45 14             	mov    0x14(%ebp),%eax
  80035c:	8d 78 04             	lea    0x4(%eax),%edi
  80035f:	8b 00                	mov    (%eax),%eax
  800361:	85 c0                	test   %eax,%eax
  800363:	78 2a                	js     80038f <vprintfmt+0x138>
  800365:	89 c2                	mov    %eax,%edx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800367:	83 f8 06             	cmp    $0x6,%eax
  80036a:	7f 27                	jg     800393 <vprintfmt+0x13c>
  80036c:	8b 04 85 2c 0f 80 00 	mov    0x800f2c(,%eax,4),%eax
  800373:	85 c0                	test   %eax,%eax
  800375:	74 1c                	je     800393 <vprintfmt+0x13c>
				printfmt(putch, putdat, "%s", p);
  800377:	50                   	push   %eax
  800378:	68 65 0d 80 00       	push   $0x800d65
  80037d:	53                   	push   %ebx
  80037e:	56                   	push   %esi
  80037f:	e8 b6 fe ff ff       	call   80023a <printfmt>
  800384:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800387:	89 7d 14             	mov    %edi,0x14(%ebp)
  80038a:	e9 37 02 00 00       	jmp    8005c6 <vprintfmt+0x36f>
  80038f:	f7 d8                	neg    %eax
  800391:	eb d2                	jmp    800365 <vprintfmt+0x10e>
				printfmt(putch, putdat, "error %d", err);
  800393:	52                   	push   %edx
  800394:	68 5c 0d 80 00       	push   $0x800d5c
  800399:	53                   	push   %ebx
  80039a:	56                   	push   %esi
  80039b:	e8 9a fe ff ff       	call   80023a <printfmt>
  8003a0:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8003a3:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  8003a6:	e9 1b 02 00 00       	jmp    8005c6 <vprintfmt+0x36f>
			if ((p = va_arg(ap, char *)) == NULL)
  8003ab:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ae:	83 c0 04             	add    $0x4,%eax
  8003b1:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8003b4:	8b 45 14             	mov    0x14(%ebp),%eax
  8003b7:	8b 00                	mov    (%eax),%eax
  8003b9:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8003bc:	85 c0                	test   %eax,%eax
  8003be:	74 19                	je     8003d9 <vprintfmt+0x182>
			if (width > 0 && padc != '-')
  8003c0:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8003c4:	7e 06                	jle    8003cc <vprintfmt+0x175>
  8003c6:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  8003ca:	75 16                	jne    8003e2 <vprintfmt+0x18b>
				for (width -= strnlen(p, precision); width > 0; width--)
  8003cc:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8003cf:	89 c7                	mov    %eax,%edi
  8003d1:	03 45 d4             	add    -0x2c(%ebp),%eax
  8003d4:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8003d7:	eb 62                	jmp    80043b <vprintfmt+0x1e4>
				p = "(null)";
  8003d9:	c7 45 cc 55 0d 80 00 	movl   $0x800d55,-0x34(%ebp)
  8003e0:	eb de                	jmp    8003c0 <vprintfmt+0x169>
				for (width -= strnlen(p, precision); width > 0; width--)
  8003e2:	83 ec 08             	sub    $0x8,%esp
  8003e5:	ff 75 d8             	pushl  -0x28(%ebp)
  8003e8:	ff 75 cc             	pushl  -0x34(%ebp)
  8003eb:	e8 05 03 00 00       	call   8006f5 <strnlen>
  8003f0:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8003f3:	29 c2                	sub    %eax,%edx
  8003f5:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  8003f8:	83 c4 10             	add    $0x10,%esp
  8003fb:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  8003fd:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  800401:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  800404:	eb 0d                	jmp    800413 <vprintfmt+0x1bc>
					putch(padc, putdat);
  800406:	83 ec 08             	sub    $0x8,%esp
  800409:	53                   	push   %ebx
  80040a:	ff 75 d4             	pushl  -0x2c(%ebp)
  80040d:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  80040f:	4f                   	dec    %edi
  800410:	83 c4 10             	add    $0x10,%esp
  800413:	85 ff                	test   %edi,%edi
  800415:	7f ef                	jg     800406 <vprintfmt+0x1af>
  800417:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  80041a:	89 d0                	mov    %edx,%eax
  80041c:	85 d2                	test   %edx,%edx
  80041e:	78 0a                	js     80042a <vprintfmt+0x1d3>
  800420:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800423:	29 c2                	sub    %eax,%edx
  800425:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800428:	eb a2                	jmp    8003cc <vprintfmt+0x175>
  80042a:	b8 00 00 00 00       	mov    $0x0,%eax
  80042f:	eb ef                	jmp    800420 <vprintfmt+0x1c9>
					putch(ch, putdat);
  800431:	83 ec 08             	sub    $0x8,%esp
  800434:	53                   	push   %ebx
  800435:	52                   	push   %edx
  800436:	ff d6                	call   *%esi
  800438:	83 c4 10             	add    $0x10,%esp
  80043b:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  80043e:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800440:	47                   	inc    %edi
  800441:	8a 47 ff             	mov    -0x1(%edi),%al
  800444:	0f be d0             	movsbl %al,%edx
  800447:	85 d2                	test   %edx,%edx
  800449:	74 48                	je     800493 <vprintfmt+0x23c>
  80044b:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80044f:	78 05                	js     800456 <vprintfmt+0x1ff>
  800451:	ff 4d d8             	decl   -0x28(%ebp)
  800454:	78 1e                	js     800474 <vprintfmt+0x21d>
				if (altflag && (ch < ' ' || ch > '~'))
  800456:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80045a:	74 d5                	je     800431 <vprintfmt+0x1da>
  80045c:	0f be c0             	movsbl %al,%eax
  80045f:	83 e8 20             	sub    $0x20,%eax
  800462:	83 f8 5e             	cmp    $0x5e,%eax
  800465:	76 ca                	jbe    800431 <vprintfmt+0x1da>
					putch('?', putdat);
  800467:	83 ec 08             	sub    $0x8,%esp
  80046a:	53                   	push   %ebx
  80046b:	6a 3f                	push   $0x3f
  80046d:	ff d6                	call   *%esi
  80046f:	83 c4 10             	add    $0x10,%esp
  800472:	eb c7                	jmp    80043b <vprintfmt+0x1e4>
  800474:	89 cf                	mov    %ecx,%edi
  800476:	eb 0c                	jmp    800484 <vprintfmt+0x22d>
				putch(' ', putdat);
  800478:	83 ec 08             	sub    $0x8,%esp
  80047b:	53                   	push   %ebx
  80047c:	6a 20                	push   $0x20
  80047e:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800480:	4f                   	dec    %edi
  800481:	83 c4 10             	add    $0x10,%esp
  800484:	85 ff                	test   %edi,%edi
  800486:	7f f0                	jg     800478 <vprintfmt+0x221>
			if ((p = va_arg(ap, char *)) == NULL)
  800488:	8b 45 c8             	mov    -0x38(%ebp),%eax
  80048b:	89 45 14             	mov    %eax,0x14(%ebp)
  80048e:	e9 33 01 00 00       	jmp    8005c6 <vprintfmt+0x36f>
  800493:	89 cf                	mov    %ecx,%edi
  800495:	eb ed                	jmp    800484 <vprintfmt+0x22d>
	if (lflag >= 2)
  800497:	83 f9 01             	cmp    $0x1,%ecx
  80049a:	7f 1b                	jg     8004b7 <vprintfmt+0x260>
	else if (lflag)
  80049c:	85 c9                	test   %ecx,%ecx
  80049e:	74 42                	je     8004e2 <vprintfmt+0x28b>
		return va_arg(*ap, long);
  8004a0:	8b 45 14             	mov    0x14(%ebp),%eax
  8004a3:	8b 00                	mov    (%eax),%eax
  8004a5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004a8:	99                   	cltd   
  8004a9:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8004ac:	8b 45 14             	mov    0x14(%ebp),%eax
  8004af:	8d 40 04             	lea    0x4(%eax),%eax
  8004b2:	89 45 14             	mov    %eax,0x14(%ebp)
  8004b5:	eb 17                	jmp    8004ce <vprintfmt+0x277>
		return va_arg(*ap, long long);
  8004b7:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ba:	8b 50 04             	mov    0x4(%eax),%edx
  8004bd:	8b 00                	mov    (%eax),%eax
  8004bf:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004c2:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8004c5:	8b 45 14             	mov    0x14(%ebp),%eax
  8004c8:	8d 40 08             	lea    0x8(%eax),%eax
  8004cb:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  8004ce:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8004d1:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8004d4:	85 c9                	test   %ecx,%ecx
  8004d6:	78 21                	js     8004f9 <vprintfmt+0x2a2>
			base = 10;
  8004d8:	b8 0a 00 00 00       	mov    $0xa,%eax
  8004dd:	e9 ca 00 00 00       	jmp    8005ac <vprintfmt+0x355>
		return va_arg(*ap, int);
  8004e2:	8b 45 14             	mov    0x14(%ebp),%eax
  8004e5:	8b 00                	mov    (%eax),%eax
  8004e7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004ea:	99                   	cltd   
  8004eb:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8004ee:	8b 45 14             	mov    0x14(%ebp),%eax
  8004f1:	8d 40 04             	lea    0x4(%eax),%eax
  8004f4:	89 45 14             	mov    %eax,0x14(%ebp)
  8004f7:	eb d5                	jmp    8004ce <vprintfmt+0x277>
				putch('-', putdat);
  8004f9:	83 ec 08             	sub    $0x8,%esp
  8004fc:	53                   	push   %ebx
  8004fd:	6a 2d                	push   $0x2d
  8004ff:	ff d6                	call   *%esi
				num = -(long long) num;
  800501:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800504:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800507:	f7 da                	neg    %edx
  800509:	83 d1 00             	adc    $0x0,%ecx
  80050c:	f7 d9                	neg    %ecx
  80050e:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800511:	b8 0a 00 00 00       	mov    $0xa,%eax
  800516:	e9 91 00 00 00       	jmp    8005ac <vprintfmt+0x355>
	if (lflag >= 2)
  80051b:	83 f9 01             	cmp    $0x1,%ecx
  80051e:	7f 1b                	jg     80053b <vprintfmt+0x2e4>
	else if (lflag)
  800520:	85 c9                	test   %ecx,%ecx
  800522:	74 2c                	je     800550 <vprintfmt+0x2f9>
		return va_arg(*ap, unsigned long);
  800524:	8b 45 14             	mov    0x14(%ebp),%eax
  800527:	8b 10                	mov    (%eax),%edx
  800529:	b9 00 00 00 00       	mov    $0x0,%ecx
  80052e:	8d 40 04             	lea    0x4(%eax),%eax
  800531:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800534:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  800539:	eb 71                	jmp    8005ac <vprintfmt+0x355>
		return va_arg(*ap, unsigned long long);
  80053b:	8b 45 14             	mov    0x14(%ebp),%eax
  80053e:	8b 10                	mov    (%eax),%edx
  800540:	8b 48 04             	mov    0x4(%eax),%ecx
  800543:	8d 40 08             	lea    0x8(%eax),%eax
  800546:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800549:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  80054e:	eb 5c                	jmp    8005ac <vprintfmt+0x355>
		return va_arg(*ap, unsigned int);
  800550:	8b 45 14             	mov    0x14(%ebp),%eax
  800553:	8b 10                	mov    (%eax),%edx
  800555:	b9 00 00 00 00       	mov    $0x0,%ecx
  80055a:	8d 40 04             	lea    0x4(%eax),%eax
  80055d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800560:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  800565:	eb 45                	jmp    8005ac <vprintfmt+0x355>
			putch('X', putdat);
  800567:	83 ec 08             	sub    $0x8,%esp
  80056a:	53                   	push   %ebx
  80056b:	6a 58                	push   $0x58
  80056d:	ff d6                	call   *%esi
			putch('X', putdat);
  80056f:	83 c4 08             	add    $0x8,%esp
  800572:	53                   	push   %ebx
  800573:	6a 58                	push   $0x58
  800575:	ff d6                	call   *%esi
			putch('X', putdat);
  800577:	83 c4 08             	add    $0x8,%esp
  80057a:	53                   	push   %ebx
  80057b:	6a 58                	push   $0x58
  80057d:	ff d6                	call   *%esi
			break;
  80057f:	83 c4 10             	add    $0x10,%esp
  800582:	eb 42                	jmp    8005c6 <vprintfmt+0x36f>
			putch('0', putdat);
  800584:	83 ec 08             	sub    $0x8,%esp
  800587:	53                   	push   %ebx
  800588:	6a 30                	push   $0x30
  80058a:	ff d6                	call   *%esi
			putch('x', putdat);
  80058c:	83 c4 08             	add    $0x8,%esp
  80058f:	53                   	push   %ebx
  800590:	6a 78                	push   $0x78
  800592:	ff d6                	call   *%esi
			num = (unsigned long long)
  800594:	8b 45 14             	mov    0x14(%ebp),%eax
  800597:	8b 10                	mov    (%eax),%edx
  800599:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  80059e:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  8005a1:	8d 40 04             	lea    0x4(%eax),%eax
  8005a4:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8005a7:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  8005ac:	83 ec 0c             	sub    $0xc,%esp
  8005af:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  8005b3:	57                   	push   %edi
  8005b4:	ff 75 d4             	pushl  -0x2c(%ebp)
  8005b7:	50                   	push   %eax
  8005b8:	51                   	push   %ecx
  8005b9:	52                   	push   %edx
  8005ba:	89 da                	mov    %ebx,%edx
  8005bc:	89 f0                	mov    %esi,%eax
  8005be:	e8 b6 fb ff ff       	call   800179 <printnum>
			break;
  8005c3:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  8005c6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8005c9:	47                   	inc    %edi
  8005ca:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8005ce:	83 f8 25             	cmp    $0x25,%eax
  8005d1:	0f 84 97 fc ff ff    	je     80026e <vprintfmt+0x17>
			if (ch == '\0')
  8005d7:	85 c0                	test   %eax,%eax
  8005d9:	0f 84 89 00 00 00    	je     800668 <vprintfmt+0x411>
			putch(ch, putdat);
  8005df:	83 ec 08             	sub    $0x8,%esp
  8005e2:	53                   	push   %ebx
  8005e3:	50                   	push   %eax
  8005e4:	ff d6                	call   *%esi
  8005e6:	83 c4 10             	add    $0x10,%esp
  8005e9:	eb de                	jmp    8005c9 <vprintfmt+0x372>
	if (lflag >= 2)
  8005eb:	83 f9 01             	cmp    $0x1,%ecx
  8005ee:	7f 1b                	jg     80060b <vprintfmt+0x3b4>
	else if (lflag)
  8005f0:	85 c9                	test   %ecx,%ecx
  8005f2:	74 2c                	je     800620 <vprintfmt+0x3c9>
		return va_arg(*ap, unsigned long);
  8005f4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f7:	8b 10                	mov    (%eax),%edx
  8005f9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005fe:	8d 40 04             	lea    0x4(%eax),%eax
  800601:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800604:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  800609:	eb a1                	jmp    8005ac <vprintfmt+0x355>
		return va_arg(*ap, unsigned long long);
  80060b:	8b 45 14             	mov    0x14(%ebp),%eax
  80060e:	8b 10                	mov    (%eax),%edx
  800610:	8b 48 04             	mov    0x4(%eax),%ecx
  800613:	8d 40 08             	lea    0x8(%eax),%eax
  800616:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800619:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  80061e:	eb 8c                	jmp    8005ac <vprintfmt+0x355>
		return va_arg(*ap, unsigned int);
  800620:	8b 45 14             	mov    0x14(%ebp),%eax
  800623:	8b 10                	mov    (%eax),%edx
  800625:	b9 00 00 00 00       	mov    $0x0,%ecx
  80062a:	8d 40 04             	lea    0x4(%eax),%eax
  80062d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800630:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  800635:	e9 72 ff ff ff       	jmp    8005ac <vprintfmt+0x355>
			putch(ch, putdat);
  80063a:	83 ec 08             	sub    $0x8,%esp
  80063d:	53                   	push   %ebx
  80063e:	6a 25                	push   $0x25
  800640:	ff d6                	call   *%esi
			break;
  800642:	83 c4 10             	add    $0x10,%esp
  800645:	e9 7c ff ff ff       	jmp    8005c6 <vprintfmt+0x36f>
			putch('%', putdat);
  80064a:	83 ec 08             	sub    $0x8,%esp
  80064d:	53                   	push   %ebx
  80064e:	6a 25                	push   $0x25
  800650:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800652:	83 c4 10             	add    $0x10,%esp
  800655:	89 f8                	mov    %edi,%eax
  800657:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  80065b:	74 03                	je     800660 <vprintfmt+0x409>
  80065d:	48                   	dec    %eax
  80065e:	eb f7                	jmp    800657 <vprintfmt+0x400>
  800660:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800663:	e9 5e ff ff ff       	jmp    8005c6 <vprintfmt+0x36f>
}
  800668:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80066b:	5b                   	pop    %ebx
  80066c:	5e                   	pop    %esi
  80066d:	5f                   	pop    %edi
  80066e:	5d                   	pop    %ebp
  80066f:	c3                   	ret    

00800670 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800670:	55                   	push   %ebp
  800671:	89 e5                	mov    %esp,%ebp
  800673:	83 ec 18             	sub    $0x18,%esp
  800676:	8b 45 08             	mov    0x8(%ebp),%eax
  800679:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80067c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80067f:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800683:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800686:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80068d:	85 c0                	test   %eax,%eax
  80068f:	74 26                	je     8006b7 <vsnprintf+0x47>
  800691:	85 d2                	test   %edx,%edx
  800693:	7e 29                	jle    8006be <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800695:	ff 75 14             	pushl  0x14(%ebp)
  800698:	ff 75 10             	pushl  0x10(%ebp)
  80069b:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80069e:	50                   	push   %eax
  80069f:	68 1e 02 80 00       	push   $0x80021e
  8006a4:	e8 ae fb ff ff       	call   800257 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006a9:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006ac:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006af:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006b2:	83 c4 10             	add    $0x10,%esp
}
  8006b5:	c9                   	leave  
  8006b6:	c3                   	ret    
		return -E_INVAL;
  8006b7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8006bc:	eb f7                	jmp    8006b5 <vsnprintf+0x45>
  8006be:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8006c3:	eb f0                	jmp    8006b5 <vsnprintf+0x45>

008006c5 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006c5:	55                   	push   %ebp
  8006c6:	89 e5                	mov    %esp,%ebp
  8006c8:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006cb:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006ce:	50                   	push   %eax
  8006cf:	ff 75 10             	pushl  0x10(%ebp)
  8006d2:	ff 75 0c             	pushl  0xc(%ebp)
  8006d5:	ff 75 08             	pushl  0x8(%ebp)
  8006d8:	e8 93 ff ff ff       	call   800670 <vsnprintf>
	va_end(ap);

	return rc;
}
  8006dd:	c9                   	leave  
  8006de:	c3                   	ret    

008006df <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006df:	55                   	push   %ebp
  8006e0:	89 e5                	mov    %esp,%ebp
  8006e2:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006e5:	b8 00 00 00 00       	mov    $0x0,%eax
  8006ea:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8006ee:	74 03                	je     8006f3 <strlen+0x14>
		n++;
  8006f0:	40                   	inc    %eax
  8006f1:	eb f7                	jmp    8006ea <strlen+0xb>
	return n;
}
  8006f3:	5d                   	pop    %ebp
  8006f4:	c3                   	ret    

008006f5 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8006f5:	55                   	push   %ebp
  8006f6:	89 e5                	mov    %esp,%ebp
  8006f8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006fb:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006fe:	b8 00 00 00 00       	mov    $0x0,%eax
  800703:	39 d0                	cmp    %edx,%eax
  800705:	74 0b                	je     800712 <strnlen+0x1d>
  800707:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80070b:	74 03                	je     800710 <strnlen+0x1b>
		n++;
  80070d:	40                   	inc    %eax
  80070e:	eb f3                	jmp    800703 <strnlen+0xe>
  800710:	89 c2                	mov    %eax,%edx
	return n;
}
  800712:	89 d0                	mov    %edx,%eax
  800714:	5d                   	pop    %ebp
  800715:	c3                   	ret    

00800716 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800716:	55                   	push   %ebp
  800717:	89 e5                	mov    %esp,%ebp
  800719:	53                   	push   %ebx
  80071a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80071d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800720:	b8 00 00 00 00       	mov    $0x0,%eax
  800725:	8a 14 03             	mov    (%ebx,%eax,1),%dl
  800728:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  80072b:	40                   	inc    %eax
  80072c:	84 d2                	test   %dl,%dl
  80072e:	75 f5                	jne    800725 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800730:	89 c8                	mov    %ecx,%eax
  800732:	5b                   	pop    %ebx
  800733:	5d                   	pop    %ebp
  800734:	c3                   	ret    

00800735 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800735:	55                   	push   %ebp
  800736:	89 e5                	mov    %esp,%ebp
  800738:	53                   	push   %ebx
  800739:	83 ec 10             	sub    $0x10,%esp
  80073c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80073f:	53                   	push   %ebx
  800740:	e8 9a ff ff ff       	call   8006df <strlen>
  800745:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800748:	ff 75 0c             	pushl  0xc(%ebp)
  80074b:	01 d8                	add    %ebx,%eax
  80074d:	50                   	push   %eax
  80074e:	e8 c3 ff ff ff       	call   800716 <strcpy>
	return dst;
}
  800753:	89 d8                	mov    %ebx,%eax
  800755:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800758:	c9                   	leave  
  800759:	c3                   	ret    

0080075a <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80075a:	55                   	push   %ebp
  80075b:	89 e5                	mov    %esp,%ebp
  80075d:	53                   	push   %ebx
  80075e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800761:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800764:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800767:	8b 45 08             	mov    0x8(%ebp),%eax
  80076a:	39 d8                	cmp    %ebx,%eax
  80076c:	74 0e                	je     80077c <strncpy+0x22>
		*dst++ = *src;
  80076e:	40                   	inc    %eax
  80076f:	8a 0a                	mov    (%edx),%cl
  800771:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800774:	80 f9 01             	cmp    $0x1,%cl
  800777:	83 da ff             	sbb    $0xffffffff,%edx
  80077a:	eb ee                	jmp    80076a <strncpy+0x10>
	}
	return ret;
}
  80077c:	8b 45 08             	mov    0x8(%ebp),%eax
  80077f:	5b                   	pop    %ebx
  800780:	5d                   	pop    %ebp
  800781:	c3                   	ret    

00800782 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800782:	55                   	push   %ebp
  800783:	89 e5                	mov    %esp,%ebp
  800785:	56                   	push   %esi
  800786:	53                   	push   %ebx
  800787:	8b 75 08             	mov    0x8(%ebp),%esi
  80078a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80078d:	8b 45 10             	mov    0x10(%ebp),%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800790:	85 c0                	test   %eax,%eax
  800792:	74 22                	je     8007b6 <strlcpy+0x34>
  800794:	8d 44 06 ff          	lea    -0x1(%esi,%eax,1),%eax
  800798:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  80079a:	39 c2                	cmp    %eax,%edx
  80079c:	74 0f                	je     8007ad <strlcpy+0x2b>
  80079e:	8a 19                	mov    (%ecx),%bl
  8007a0:	84 db                	test   %bl,%bl
  8007a2:	74 07                	je     8007ab <strlcpy+0x29>
			*dst++ = *src++;
  8007a4:	41                   	inc    %ecx
  8007a5:	42                   	inc    %edx
  8007a6:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007a9:	eb ef                	jmp    80079a <strlcpy+0x18>
  8007ab:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  8007ad:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8007b0:	29 f0                	sub    %esi,%eax
}
  8007b2:	5b                   	pop    %ebx
  8007b3:	5e                   	pop    %esi
  8007b4:	5d                   	pop    %ebp
  8007b5:	c3                   	ret    
  8007b6:	89 f0                	mov    %esi,%eax
  8007b8:	eb f6                	jmp    8007b0 <strlcpy+0x2e>

008007ba <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007ba:	55                   	push   %ebp
  8007bb:	89 e5                	mov    %esp,%ebp
  8007bd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007c0:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007c3:	8a 01                	mov    (%ecx),%al
  8007c5:	84 c0                	test   %al,%al
  8007c7:	74 08                	je     8007d1 <strcmp+0x17>
  8007c9:	3a 02                	cmp    (%edx),%al
  8007cb:	75 04                	jne    8007d1 <strcmp+0x17>
		p++, q++;
  8007cd:	41                   	inc    %ecx
  8007ce:	42                   	inc    %edx
  8007cf:	eb f2                	jmp    8007c3 <strcmp+0x9>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007d1:	0f b6 c0             	movzbl %al,%eax
  8007d4:	0f b6 12             	movzbl (%edx),%edx
  8007d7:	29 d0                	sub    %edx,%eax
}
  8007d9:	5d                   	pop    %ebp
  8007da:	c3                   	ret    

008007db <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8007db:	55                   	push   %ebp
  8007dc:	89 e5                	mov    %esp,%ebp
  8007de:	53                   	push   %ebx
  8007df:	8b 45 08             	mov    0x8(%ebp),%eax
  8007e2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007e5:	89 c3                	mov    %eax,%ebx
  8007e7:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8007ea:	eb 02                	jmp    8007ee <strncmp+0x13>
		n--, p++, q++;
  8007ec:	40                   	inc    %eax
  8007ed:	42                   	inc    %edx
	while (n > 0 && *p && *p == *q)
  8007ee:	39 d8                	cmp    %ebx,%eax
  8007f0:	74 15                	je     800807 <strncmp+0x2c>
  8007f2:	8a 08                	mov    (%eax),%cl
  8007f4:	84 c9                	test   %cl,%cl
  8007f6:	74 04                	je     8007fc <strncmp+0x21>
  8007f8:	3a 0a                	cmp    (%edx),%cl
  8007fa:	74 f0                	je     8007ec <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8007fc:	0f b6 00             	movzbl (%eax),%eax
  8007ff:	0f b6 12             	movzbl (%edx),%edx
  800802:	29 d0                	sub    %edx,%eax
}
  800804:	5b                   	pop    %ebx
  800805:	5d                   	pop    %ebp
  800806:	c3                   	ret    
		return 0;
  800807:	b8 00 00 00 00       	mov    $0x0,%eax
  80080c:	eb f6                	jmp    800804 <strncmp+0x29>

0080080e <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80080e:	55                   	push   %ebp
  80080f:	89 e5                	mov    %esp,%ebp
  800811:	8b 45 08             	mov    0x8(%ebp),%eax
  800814:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800817:	8a 10                	mov    (%eax),%dl
  800819:	84 d2                	test   %dl,%dl
  80081b:	74 07                	je     800824 <strchr+0x16>
		if (*s == c)
  80081d:	38 ca                	cmp    %cl,%dl
  80081f:	74 08                	je     800829 <strchr+0x1b>
	for (; *s; s++)
  800821:	40                   	inc    %eax
  800822:	eb f3                	jmp    800817 <strchr+0x9>
			return (char *) s;
	return 0;
  800824:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800829:	5d                   	pop    %ebp
  80082a:	c3                   	ret    

0080082b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80082b:	55                   	push   %ebp
  80082c:	89 e5                	mov    %esp,%ebp
  80082e:	8b 45 08             	mov    0x8(%ebp),%eax
  800831:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800834:	8a 10                	mov    (%eax),%dl
  800836:	84 d2                	test   %dl,%dl
  800838:	74 07                	je     800841 <strfind+0x16>
		if (*s == c)
  80083a:	38 ca                	cmp    %cl,%dl
  80083c:	74 03                	je     800841 <strfind+0x16>
	for (; *s; s++)
  80083e:	40                   	inc    %eax
  80083f:	eb f3                	jmp    800834 <strfind+0x9>
			break;
	return (char *) s;
}
  800841:	5d                   	pop    %ebp
  800842:	c3                   	ret    

00800843 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800843:	55                   	push   %ebp
  800844:	89 e5                	mov    %esp,%ebp
  800846:	57                   	push   %edi
  800847:	56                   	push   %esi
  800848:	53                   	push   %ebx
  800849:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80084c:	85 c9                	test   %ecx,%ecx
  80084e:	74 36                	je     800886 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800850:	89 c8                	mov    %ecx,%eax
  800852:	0b 45 08             	or     0x8(%ebp),%eax
  800855:	a8 03                	test   $0x3,%al
  800857:	75 24                	jne    80087d <memset+0x3a>
		c &= 0xFF;
  800859:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80085d:	89 d3                	mov    %edx,%ebx
  80085f:	c1 e3 08             	shl    $0x8,%ebx
  800862:	89 d0                	mov    %edx,%eax
  800864:	c1 e0 18             	shl    $0x18,%eax
  800867:	89 d6                	mov    %edx,%esi
  800869:	c1 e6 10             	shl    $0x10,%esi
  80086c:	09 f0                	or     %esi,%eax
  80086e:	09 d0                	or     %edx,%eax
  800870:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800872:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800875:	8b 7d 08             	mov    0x8(%ebp),%edi
  800878:	fc                   	cld    
  800879:	f3 ab                	rep stos %eax,%es:(%edi)
  80087b:	eb 09                	jmp    800886 <memset+0x43>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80087d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800880:	8b 45 0c             	mov    0xc(%ebp),%eax
  800883:	fc                   	cld    
  800884:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800886:	8b 45 08             	mov    0x8(%ebp),%eax
  800889:	5b                   	pop    %ebx
  80088a:	5e                   	pop    %esi
  80088b:	5f                   	pop    %edi
  80088c:	5d                   	pop    %ebp
  80088d:	c3                   	ret    

0080088e <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80088e:	55                   	push   %ebp
  80088f:	89 e5                	mov    %esp,%ebp
  800891:	57                   	push   %edi
  800892:	56                   	push   %esi
  800893:	8b 45 08             	mov    0x8(%ebp),%eax
  800896:	8b 75 0c             	mov    0xc(%ebp),%esi
  800899:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80089c:	39 c6                	cmp    %eax,%esi
  80089e:	73 30                	jae    8008d0 <memmove+0x42>
  8008a0:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008a3:	39 c2                	cmp    %eax,%edx
  8008a5:	76 29                	jbe    8008d0 <memmove+0x42>
		s += n;
		d += n;
  8008a7:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008aa:	89 fe                	mov    %edi,%esi
  8008ac:	09 ce                	or     %ecx,%esi
  8008ae:	09 d6                	or     %edx,%esi
  8008b0:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008b6:	75 0e                	jne    8008c6 <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8008b8:	83 ef 04             	sub    $0x4,%edi
  8008bb:	8d 72 fc             	lea    -0x4(%edx),%esi
  8008be:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  8008c1:	fd                   	std    
  8008c2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008c4:	eb 07                	jmp    8008cd <memmove+0x3f>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8008c6:	4f                   	dec    %edi
  8008c7:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  8008ca:	fd                   	std    
  8008cb:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8008cd:	fc                   	cld    
  8008ce:	eb 1a                	jmp    8008ea <memmove+0x5c>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008d0:	89 c2                	mov    %eax,%edx
  8008d2:	09 ca                	or     %ecx,%edx
  8008d4:	09 f2                	or     %esi,%edx
  8008d6:	f6 c2 03             	test   $0x3,%dl
  8008d9:	75 0a                	jne    8008e5 <memmove+0x57>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8008db:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  8008de:	89 c7                	mov    %eax,%edi
  8008e0:	fc                   	cld    
  8008e1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008e3:	eb 05                	jmp    8008ea <memmove+0x5c>
		else
			asm volatile("cld; rep movsb\n"
  8008e5:	89 c7                	mov    %eax,%edi
  8008e7:	fc                   	cld    
  8008e8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8008ea:	5e                   	pop    %esi
  8008eb:	5f                   	pop    %edi
  8008ec:	5d                   	pop    %ebp
  8008ed:	c3                   	ret    

008008ee <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8008ee:	55                   	push   %ebp
  8008ef:	89 e5                	mov    %esp,%ebp
  8008f1:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8008f4:	ff 75 10             	pushl  0x10(%ebp)
  8008f7:	ff 75 0c             	pushl  0xc(%ebp)
  8008fa:	ff 75 08             	pushl  0x8(%ebp)
  8008fd:	e8 8c ff ff ff       	call   80088e <memmove>
}
  800902:	c9                   	leave  
  800903:	c3                   	ret    

00800904 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800904:	55                   	push   %ebp
  800905:	89 e5                	mov    %esp,%ebp
  800907:	56                   	push   %esi
  800908:	53                   	push   %ebx
  800909:	8b 45 08             	mov    0x8(%ebp),%eax
  80090c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80090f:	89 c6                	mov    %eax,%esi
  800911:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800914:	39 f0                	cmp    %esi,%eax
  800916:	74 16                	je     80092e <memcmp+0x2a>
		if (*s1 != *s2)
  800918:	8a 08                	mov    (%eax),%cl
  80091a:	8a 1a                	mov    (%edx),%bl
  80091c:	38 d9                	cmp    %bl,%cl
  80091e:	75 04                	jne    800924 <memcmp+0x20>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800920:	40                   	inc    %eax
  800921:	42                   	inc    %edx
  800922:	eb f0                	jmp    800914 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800924:	0f b6 c1             	movzbl %cl,%eax
  800927:	0f b6 db             	movzbl %bl,%ebx
  80092a:	29 d8                	sub    %ebx,%eax
  80092c:	eb 05                	jmp    800933 <memcmp+0x2f>
	}

	return 0;
  80092e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800933:	5b                   	pop    %ebx
  800934:	5e                   	pop    %esi
  800935:	5d                   	pop    %ebp
  800936:	c3                   	ret    

00800937 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800937:	55                   	push   %ebp
  800938:	89 e5                	mov    %esp,%ebp
  80093a:	8b 45 08             	mov    0x8(%ebp),%eax
  80093d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800940:	89 c2                	mov    %eax,%edx
  800942:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800945:	39 d0                	cmp    %edx,%eax
  800947:	73 07                	jae    800950 <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
  800949:	38 08                	cmp    %cl,(%eax)
  80094b:	74 03                	je     800950 <memfind+0x19>
	for (; s < ends; s++)
  80094d:	40                   	inc    %eax
  80094e:	eb f5                	jmp    800945 <memfind+0xe>
			break;
	return (void *) s;
}
  800950:	5d                   	pop    %ebp
  800951:	c3                   	ret    

00800952 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800952:	55                   	push   %ebp
  800953:	89 e5                	mov    %esp,%ebp
  800955:	57                   	push   %edi
  800956:	56                   	push   %esi
  800957:	53                   	push   %ebx
  800958:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80095b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80095e:	eb 01                	jmp    800961 <strtol+0xf>
		s++;
  800960:	41                   	inc    %ecx
	while (*s == ' ' || *s == '\t')
  800961:	8a 01                	mov    (%ecx),%al
  800963:	3c 20                	cmp    $0x20,%al
  800965:	74 f9                	je     800960 <strtol+0xe>
  800967:	3c 09                	cmp    $0x9,%al
  800969:	74 f5                	je     800960 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  80096b:	3c 2b                	cmp    $0x2b,%al
  80096d:	74 24                	je     800993 <strtol+0x41>
		s++;
	else if (*s == '-')
  80096f:	3c 2d                	cmp    $0x2d,%al
  800971:	74 28                	je     80099b <strtol+0x49>
	int neg = 0;
  800973:	bf 00 00 00 00       	mov    $0x0,%edi
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800978:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  80097e:	75 09                	jne    800989 <strtol+0x37>
  800980:	80 39 30             	cmpb   $0x30,(%ecx)
  800983:	74 1e                	je     8009a3 <strtol+0x51>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800985:	85 db                	test   %ebx,%ebx
  800987:	74 36                	je     8009bf <strtol+0x6d>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800989:	b8 00 00 00 00       	mov    $0x0,%eax
  80098e:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800991:	eb 45                	jmp    8009d8 <strtol+0x86>
		s++;
  800993:	41                   	inc    %ecx
	int neg = 0;
  800994:	bf 00 00 00 00       	mov    $0x0,%edi
  800999:	eb dd                	jmp    800978 <strtol+0x26>
		s++, neg = 1;
  80099b:	41                   	inc    %ecx
  80099c:	bf 01 00 00 00       	mov    $0x1,%edi
  8009a1:	eb d5                	jmp    800978 <strtol+0x26>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009a3:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8009a7:	74 0c                	je     8009b5 <strtol+0x63>
	else if (base == 0 && s[0] == '0')
  8009a9:	85 db                	test   %ebx,%ebx
  8009ab:	75 dc                	jne    800989 <strtol+0x37>
		s++, base = 8;
  8009ad:	41                   	inc    %ecx
  8009ae:	bb 08 00 00 00       	mov    $0x8,%ebx
  8009b3:	eb d4                	jmp    800989 <strtol+0x37>
		s += 2, base = 16;
  8009b5:	83 c1 02             	add    $0x2,%ecx
  8009b8:	bb 10 00 00 00       	mov    $0x10,%ebx
  8009bd:	eb ca                	jmp    800989 <strtol+0x37>
		base = 10;
  8009bf:	bb 0a 00 00 00       	mov    $0xa,%ebx
  8009c4:	eb c3                	jmp    800989 <strtol+0x37>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  8009c6:	0f be d2             	movsbl %dl,%edx
  8009c9:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  8009cc:	3b 55 10             	cmp    0x10(%ebp),%edx
  8009cf:	7d 37                	jge    800a08 <strtol+0xb6>
			break;
		s++, val = (val * base) + dig;
  8009d1:	41                   	inc    %ecx
  8009d2:	0f af 45 10          	imul   0x10(%ebp),%eax
  8009d6:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  8009d8:	8a 11                	mov    (%ecx),%dl
  8009da:	8d 72 d0             	lea    -0x30(%edx),%esi
  8009dd:	89 f3                	mov    %esi,%ebx
  8009df:	80 fb 09             	cmp    $0x9,%bl
  8009e2:	76 e2                	jbe    8009c6 <strtol+0x74>
		else if (*s >= 'a' && *s <= 'z')
  8009e4:	8d 72 9f             	lea    -0x61(%edx),%esi
  8009e7:	89 f3                	mov    %esi,%ebx
  8009e9:	80 fb 19             	cmp    $0x19,%bl
  8009ec:	77 08                	ja     8009f6 <strtol+0xa4>
			dig = *s - 'a' + 10;
  8009ee:	0f be d2             	movsbl %dl,%edx
  8009f1:	83 ea 57             	sub    $0x57,%edx
  8009f4:	eb d6                	jmp    8009cc <strtol+0x7a>
		else if (*s >= 'A' && *s <= 'Z')
  8009f6:	8d 72 bf             	lea    -0x41(%edx),%esi
  8009f9:	89 f3                	mov    %esi,%ebx
  8009fb:	80 fb 19             	cmp    $0x19,%bl
  8009fe:	77 08                	ja     800a08 <strtol+0xb6>
			dig = *s - 'A' + 10;
  800a00:	0f be d2             	movsbl %dl,%edx
  800a03:	83 ea 37             	sub    $0x37,%edx
  800a06:	eb c4                	jmp    8009cc <strtol+0x7a>
		// we don't properly detect overflow!
	}

	if (endptr)
  800a08:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a0c:	74 05                	je     800a13 <strtol+0xc1>
		*endptr = (char *) s;
  800a0e:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a11:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800a13:	85 ff                	test   %edi,%edi
  800a15:	74 02                	je     800a19 <strtol+0xc7>
  800a17:	f7 d8                	neg    %eax
}
  800a19:	5b                   	pop    %ebx
  800a1a:	5e                   	pop    %esi
  800a1b:	5f                   	pop    %edi
  800a1c:	5d                   	pop    %ebp
  800a1d:	c3                   	ret    

00800a1e <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a1e:	55                   	push   %ebp
  800a1f:	89 e5                	mov    %esp,%ebp
  800a21:	57                   	push   %edi
  800a22:	56                   	push   %esi
  800a23:	53                   	push   %ebx
	asm volatile("int %1\n"
  800a24:	b8 00 00 00 00       	mov    $0x0,%eax
  800a29:	8b 55 08             	mov    0x8(%ebp),%edx
  800a2c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a2f:	89 c3                	mov    %eax,%ebx
  800a31:	89 c7                	mov    %eax,%edi
  800a33:	89 c6                	mov    %eax,%esi
  800a35:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a37:	5b                   	pop    %ebx
  800a38:	5e                   	pop    %esi
  800a39:	5f                   	pop    %edi
  800a3a:	5d                   	pop    %ebp
  800a3b:	c3                   	ret    

00800a3c <sys_cgetc>:

int
sys_cgetc(void)
{
  800a3c:	55                   	push   %ebp
  800a3d:	89 e5                	mov    %esp,%ebp
  800a3f:	57                   	push   %edi
  800a40:	56                   	push   %esi
  800a41:	53                   	push   %ebx
	asm volatile("int %1\n"
  800a42:	ba 00 00 00 00       	mov    $0x0,%edx
  800a47:	b8 01 00 00 00       	mov    $0x1,%eax
  800a4c:	89 d1                	mov    %edx,%ecx
  800a4e:	89 d3                	mov    %edx,%ebx
  800a50:	89 d7                	mov    %edx,%edi
  800a52:	89 d6                	mov    %edx,%esi
  800a54:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800a56:	5b                   	pop    %ebx
  800a57:	5e                   	pop    %esi
  800a58:	5f                   	pop    %edi
  800a59:	5d                   	pop    %ebp
  800a5a:	c3                   	ret    

00800a5b <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800a5b:	55                   	push   %ebp
  800a5c:	89 e5                	mov    %esp,%ebp
  800a5e:	57                   	push   %edi
  800a5f:	56                   	push   %esi
  800a60:	53                   	push   %ebx
  800a61:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800a64:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a69:	8b 55 08             	mov    0x8(%ebp),%edx
  800a6c:	b8 03 00 00 00       	mov    $0x3,%eax
  800a71:	89 cb                	mov    %ecx,%ebx
  800a73:	89 cf                	mov    %ecx,%edi
  800a75:	89 ce                	mov    %ecx,%esi
  800a77:	cd 30                	int    $0x30
	if(check && ret > 0)
  800a79:	85 c0                	test   %eax,%eax
  800a7b:	7f 08                	jg     800a85 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800a7d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a80:	5b                   	pop    %ebx
  800a81:	5e                   	pop    %esi
  800a82:	5f                   	pop    %edi
  800a83:	5d                   	pop    %ebp
  800a84:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800a85:	83 ec 0c             	sub    $0xc,%esp
  800a88:	50                   	push   %eax
  800a89:	6a 03                	push   $0x3
  800a8b:	68 48 0f 80 00       	push   $0x800f48
  800a90:	6a 23                	push   $0x23
  800a92:	68 65 0f 80 00       	push   $0x800f65
  800a97:	e8 1f 00 00 00       	call   800abb <_panic>

00800a9c <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800a9c:	55                   	push   %ebp
  800a9d:	89 e5                	mov    %esp,%ebp
  800a9f:	57                   	push   %edi
  800aa0:	56                   	push   %esi
  800aa1:	53                   	push   %ebx
	asm volatile("int %1\n"
  800aa2:	ba 00 00 00 00       	mov    $0x0,%edx
  800aa7:	b8 02 00 00 00       	mov    $0x2,%eax
  800aac:	89 d1                	mov    %edx,%ecx
  800aae:	89 d3                	mov    %edx,%ebx
  800ab0:	89 d7                	mov    %edx,%edi
  800ab2:	89 d6                	mov    %edx,%esi
  800ab4:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800ab6:	5b                   	pop    %ebx
  800ab7:	5e                   	pop    %esi
  800ab8:	5f                   	pop    %edi
  800ab9:	5d                   	pop    %ebp
  800aba:	c3                   	ret    

00800abb <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800abb:	55                   	push   %ebp
  800abc:	89 e5                	mov    %esp,%ebp
  800abe:	56                   	push   %esi
  800abf:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800ac0:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800ac3:	8b 35 00 10 80 00    	mov    0x801000,%esi
  800ac9:	e8 ce ff ff ff       	call   800a9c <sys_getenvid>
  800ace:	83 ec 0c             	sub    $0xc,%esp
  800ad1:	ff 75 0c             	pushl  0xc(%ebp)
  800ad4:	ff 75 08             	pushl  0x8(%ebp)
  800ad7:	56                   	push   %esi
  800ad8:	50                   	push   %eax
  800ad9:	68 74 0f 80 00       	push   $0x800f74
  800ade:	e8 82 f6 ff ff       	call   800165 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800ae3:	83 c4 18             	add    $0x18,%esp
  800ae6:	53                   	push   %ebx
  800ae7:	ff 75 10             	pushl  0x10(%ebp)
  800aea:	e8 25 f6 ff ff       	call   800114 <vcprintf>
	cprintf("\n");
  800aef:	c7 04 24 38 0d 80 00 	movl   $0x800d38,(%esp)
  800af6:	e8 6a f6 ff ff       	call   800165 <cprintf>
  800afb:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800afe:	cc                   	int3   
  800aff:	eb fd                	jmp    800afe <_panic+0x43>
  800b01:	66 90                	xchg   %ax,%ax
  800b03:	90                   	nop

00800b04 <__udivdi3>:
  800b04:	55                   	push   %ebp
  800b05:	57                   	push   %edi
  800b06:	56                   	push   %esi
  800b07:	53                   	push   %ebx
  800b08:	83 ec 1c             	sub    $0x1c,%esp
  800b0b:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800b0f:	8b 74 24 34          	mov    0x34(%esp),%esi
  800b13:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800b17:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800b1b:	85 d2                	test   %edx,%edx
  800b1d:	75 19                	jne    800b38 <__udivdi3+0x34>
  800b1f:	39 f7                	cmp    %esi,%edi
  800b21:	76 45                	jbe    800b68 <__udivdi3+0x64>
  800b23:	89 e8                	mov    %ebp,%eax
  800b25:	89 f2                	mov    %esi,%edx
  800b27:	f7 f7                	div    %edi
  800b29:	31 db                	xor    %ebx,%ebx
  800b2b:	89 da                	mov    %ebx,%edx
  800b2d:	83 c4 1c             	add    $0x1c,%esp
  800b30:	5b                   	pop    %ebx
  800b31:	5e                   	pop    %esi
  800b32:	5f                   	pop    %edi
  800b33:	5d                   	pop    %ebp
  800b34:	c3                   	ret    
  800b35:	8d 76 00             	lea    0x0(%esi),%esi
  800b38:	39 f2                	cmp    %esi,%edx
  800b3a:	76 10                	jbe    800b4c <__udivdi3+0x48>
  800b3c:	31 db                	xor    %ebx,%ebx
  800b3e:	31 c0                	xor    %eax,%eax
  800b40:	89 da                	mov    %ebx,%edx
  800b42:	83 c4 1c             	add    $0x1c,%esp
  800b45:	5b                   	pop    %ebx
  800b46:	5e                   	pop    %esi
  800b47:	5f                   	pop    %edi
  800b48:	5d                   	pop    %ebp
  800b49:	c3                   	ret    
  800b4a:	66 90                	xchg   %ax,%ax
  800b4c:	0f bd da             	bsr    %edx,%ebx
  800b4f:	83 f3 1f             	xor    $0x1f,%ebx
  800b52:	75 3c                	jne    800b90 <__udivdi3+0x8c>
  800b54:	39 f2                	cmp    %esi,%edx
  800b56:	72 08                	jb     800b60 <__udivdi3+0x5c>
  800b58:	39 ef                	cmp    %ebp,%edi
  800b5a:	0f 87 9c 00 00 00    	ja     800bfc <__udivdi3+0xf8>
  800b60:	b8 01 00 00 00       	mov    $0x1,%eax
  800b65:	eb d9                	jmp    800b40 <__udivdi3+0x3c>
  800b67:	90                   	nop
  800b68:	89 f9                	mov    %edi,%ecx
  800b6a:	85 ff                	test   %edi,%edi
  800b6c:	75 0b                	jne    800b79 <__udivdi3+0x75>
  800b6e:	b8 01 00 00 00       	mov    $0x1,%eax
  800b73:	31 d2                	xor    %edx,%edx
  800b75:	f7 f7                	div    %edi
  800b77:	89 c1                	mov    %eax,%ecx
  800b79:	31 d2                	xor    %edx,%edx
  800b7b:	89 f0                	mov    %esi,%eax
  800b7d:	f7 f1                	div    %ecx
  800b7f:	89 c3                	mov    %eax,%ebx
  800b81:	89 e8                	mov    %ebp,%eax
  800b83:	f7 f1                	div    %ecx
  800b85:	89 da                	mov    %ebx,%edx
  800b87:	83 c4 1c             	add    $0x1c,%esp
  800b8a:	5b                   	pop    %ebx
  800b8b:	5e                   	pop    %esi
  800b8c:	5f                   	pop    %edi
  800b8d:	5d                   	pop    %ebp
  800b8e:	c3                   	ret    
  800b8f:	90                   	nop
  800b90:	b8 20 00 00 00       	mov    $0x20,%eax
  800b95:	29 d8                	sub    %ebx,%eax
  800b97:	88 d9                	mov    %bl,%cl
  800b99:	d3 e2                	shl    %cl,%edx
  800b9b:	89 54 24 08          	mov    %edx,0x8(%esp)
  800b9f:	89 fa                	mov    %edi,%edx
  800ba1:	88 c1                	mov    %al,%cl
  800ba3:	d3 ea                	shr    %cl,%edx
  800ba5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800ba9:	09 d1                	or     %edx,%ecx
  800bab:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800baf:	88 d9                	mov    %bl,%cl
  800bb1:	d3 e7                	shl    %cl,%edi
  800bb3:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800bb7:	89 f7                	mov    %esi,%edi
  800bb9:	88 c1                	mov    %al,%cl
  800bbb:	d3 ef                	shr    %cl,%edi
  800bbd:	88 d9                	mov    %bl,%cl
  800bbf:	d3 e6                	shl    %cl,%esi
  800bc1:	89 ea                	mov    %ebp,%edx
  800bc3:	88 c1                	mov    %al,%cl
  800bc5:	d3 ea                	shr    %cl,%edx
  800bc7:	09 d6                	or     %edx,%esi
  800bc9:	89 f0                	mov    %esi,%eax
  800bcb:	89 fa                	mov    %edi,%edx
  800bcd:	f7 74 24 08          	divl   0x8(%esp)
  800bd1:	89 d7                	mov    %edx,%edi
  800bd3:	89 c6                	mov    %eax,%esi
  800bd5:	f7 64 24 0c          	mull   0xc(%esp)
  800bd9:	39 d7                	cmp    %edx,%edi
  800bdb:	72 13                	jb     800bf0 <__udivdi3+0xec>
  800bdd:	74 09                	je     800be8 <__udivdi3+0xe4>
  800bdf:	89 f0                	mov    %esi,%eax
  800be1:	31 db                	xor    %ebx,%ebx
  800be3:	e9 58 ff ff ff       	jmp    800b40 <__udivdi3+0x3c>
  800be8:	88 d9                	mov    %bl,%cl
  800bea:	d3 e5                	shl    %cl,%ebp
  800bec:	39 c5                	cmp    %eax,%ebp
  800bee:	73 ef                	jae    800bdf <__udivdi3+0xdb>
  800bf0:	8d 46 ff             	lea    -0x1(%esi),%eax
  800bf3:	31 db                	xor    %ebx,%ebx
  800bf5:	e9 46 ff ff ff       	jmp    800b40 <__udivdi3+0x3c>
  800bfa:	66 90                	xchg   %ax,%ax
  800bfc:	31 c0                	xor    %eax,%eax
  800bfe:	e9 3d ff ff ff       	jmp    800b40 <__udivdi3+0x3c>
  800c03:	90                   	nop

00800c04 <__umoddi3>:
  800c04:	55                   	push   %ebp
  800c05:	57                   	push   %edi
  800c06:	56                   	push   %esi
  800c07:	53                   	push   %ebx
  800c08:	83 ec 1c             	sub    $0x1c,%esp
  800c0b:	8b 74 24 30          	mov    0x30(%esp),%esi
  800c0f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800c13:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800c17:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  800c1b:	85 c0                	test   %eax,%eax
  800c1d:	75 19                	jne    800c38 <__umoddi3+0x34>
  800c1f:	39 df                	cmp    %ebx,%edi
  800c21:	76 51                	jbe    800c74 <__umoddi3+0x70>
  800c23:	89 f0                	mov    %esi,%eax
  800c25:	89 da                	mov    %ebx,%edx
  800c27:	f7 f7                	div    %edi
  800c29:	89 d0                	mov    %edx,%eax
  800c2b:	31 d2                	xor    %edx,%edx
  800c2d:	83 c4 1c             	add    $0x1c,%esp
  800c30:	5b                   	pop    %ebx
  800c31:	5e                   	pop    %esi
  800c32:	5f                   	pop    %edi
  800c33:	5d                   	pop    %ebp
  800c34:	c3                   	ret    
  800c35:	8d 76 00             	lea    0x0(%esi),%esi
  800c38:	89 f2                	mov    %esi,%edx
  800c3a:	39 d8                	cmp    %ebx,%eax
  800c3c:	76 0e                	jbe    800c4c <__umoddi3+0x48>
  800c3e:	89 f0                	mov    %esi,%eax
  800c40:	89 da                	mov    %ebx,%edx
  800c42:	83 c4 1c             	add    $0x1c,%esp
  800c45:	5b                   	pop    %ebx
  800c46:	5e                   	pop    %esi
  800c47:	5f                   	pop    %edi
  800c48:	5d                   	pop    %ebp
  800c49:	c3                   	ret    
  800c4a:	66 90                	xchg   %ax,%ax
  800c4c:	0f bd e8             	bsr    %eax,%ebp
  800c4f:	83 f5 1f             	xor    $0x1f,%ebp
  800c52:	75 44                	jne    800c98 <__umoddi3+0x94>
  800c54:	39 d8                	cmp    %ebx,%eax
  800c56:	72 06                	jb     800c5e <__umoddi3+0x5a>
  800c58:	89 d9                	mov    %ebx,%ecx
  800c5a:	39 f7                	cmp    %esi,%edi
  800c5c:	77 08                	ja     800c66 <__umoddi3+0x62>
  800c5e:	29 fe                	sub    %edi,%esi
  800c60:	19 c3                	sbb    %eax,%ebx
  800c62:	89 f2                	mov    %esi,%edx
  800c64:	89 d9                	mov    %ebx,%ecx
  800c66:	89 d0                	mov    %edx,%eax
  800c68:	89 ca                	mov    %ecx,%edx
  800c6a:	83 c4 1c             	add    $0x1c,%esp
  800c6d:	5b                   	pop    %ebx
  800c6e:	5e                   	pop    %esi
  800c6f:	5f                   	pop    %edi
  800c70:	5d                   	pop    %ebp
  800c71:	c3                   	ret    
  800c72:	66 90                	xchg   %ax,%ax
  800c74:	89 fd                	mov    %edi,%ebp
  800c76:	85 ff                	test   %edi,%edi
  800c78:	75 0b                	jne    800c85 <__umoddi3+0x81>
  800c7a:	b8 01 00 00 00       	mov    $0x1,%eax
  800c7f:	31 d2                	xor    %edx,%edx
  800c81:	f7 f7                	div    %edi
  800c83:	89 c5                	mov    %eax,%ebp
  800c85:	89 d8                	mov    %ebx,%eax
  800c87:	31 d2                	xor    %edx,%edx
  800c89:	f7 f5                	div    %ebp
  800c8b:	89 f0                	mov    %esi,%eax
  800c8d:	f7 f5                	div    %ebp
  800c8f:	89 d0                	mov    %edx,%eax
  800c91:	31 d2                	xor    %edx,%edx
  800c93:	eb 98                	jmp    800c2d <__umoddi3+0x29>
  800c95:	8d 76 00             	lea    0x0(%esi),%esi
  800c98:	ba 20 00 00 00       	mov    $0x20,%edx
  800c9d:	29 ea                	sub    %ebp,%edx
  800c9f:	89 e9                	mov    %ebp,%ecx
  800ca1:	d3 e0                	shl    %cl,%eax
  800ca3:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ca7:	89 f8                	mov    %edi,%eax
  800ca9:	89 54 24 04          	mov    %edx,0x4(%esp)
  800cad:	88 d1                	mov    %dl,%cl
  800caf:	d3 e8                	shr    %cl,%eax
  800cb1:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800cb5:	09 c1                	or     %eax,%ecx
  800cb7:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800cbb:	89 e9                	mov    %ebp,%ecx
  800cbd:	d3 e7                	shl    %cl,%edi
  800cbf:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800cc3:	89 d8                	mov    %ebx,%eax
  800cc5:	8b 54 24 04          	mov    0x4(%esp),%edx
  800cc9:	88 d1                	mov    %dl,%cl
  800ccb:	d3 e8                	shr    %cl,%eax
  800ccd:	89 c7                	mov    %eax,%edi
  800ccf:	89 e9                	mov    %ebp,%ecx
  800cd1:	d3 e3                	shl    %cl,%ebx
  800cd3:	89 f0                	mov    %esi,%eax
  800cd5:	88 d1                	mov    %dl,%cl
  800cd7:	d3 e8                	shr    %cl,%eax
  800cd9:	09 d8                	or     %ebx,%eax
  800cdb:	89 e9                	mov    %ebp,%ecx
  800cdd:	d3 e6                	shl    %cl,%esi
  800cdf:	89 f3                	mov    %esi,%ebx
  800ce1:	89 fa                	mov    %edi,%edx
  800ce3:	f7 74 24 08          	divl   0x8(%esp)
  800ce7:	89 d1                	mov    %edx,%ecx
  800ce9:	f7 64 24 0c          	mull   0xc(%esp)
  800ced:	89 c6                	mov    %eax,%esi
  800cef:	89 d7                	mov    %edx,%edi
  800cf1:	39 d1                	cmp    %edx,%ecx
  800cf3:	72 27                	jb     800d1c <__umoddi3+0x118>
  800cf5:	74 21                	je     800d18 <__umoddi3+0x114>
  800cf7:	89 ca                	mov    %ecx,%edx
  800cf9:	29 f3                	sub    %esi,%ebx
  800cfb:	19 fa                	sbb    %edi,%edx
  800cfd:	89 d0                	mov    %edx,%eax
  800cff:	8a 4c 24 04          	mov    0x4(%esp),%cl
  800d03:	d3 e0                	shl    %cl,%eax
  800d05:	89 e9                	mov    %ebp,%ecx
  800d07:	d3 eb                	shr    %cl,%ebx
  800d09:	09 d8                	or     %ebx,%eax
  800d0b:	d3 ea                	shr    %cl,%edx
  800d0d:	83 c4 1c             	add    $0x1c,%esp
  800d10:	5b                   	pop    %ebx
  800d11:	5e                   	pop    %esi
  800d12:	5f                   	pop    %edi
  800d13:	5d                   	pop    %ebp
  800d14:	c3                   	ret    
  800d15:	8d 76 00             	lea    0x0(%esi),%esi
  800d18:	39 c3                	cmp    %eax,%ebx
  800d1a:	73 db                	jae    800cf7 <__umoddi3+0xf3>
  800d1c:	2b 44 24 0c          	sub    0xc(%esp),%eax
  800d20:	1b 54 24 08          	sbb    0x8(%esp),%edx
  800d24:	89 d7                	mov    %edx,%edi
  800d26:	89 c6                	mov    %eax,%esi
  800d28:	eb cd                	jmp    800cf7 <__umoddi3+0xf3>
