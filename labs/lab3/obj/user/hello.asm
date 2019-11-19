
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
  800039:	68 28 0d 80 00       	push   $0x800d28
  80003e:	e8 20 01 00 00       	call   800163 <cprintf>
	cprintf("i am environment %08x\n", thisenv->env_id);
  800043:	a1 04 10 80 00       	mov    0x801004,%eax
  800048:	8b 40 48             	mov    0x48(%eax),%eax
  80004b:	83 c4 08             	add    $0x8,%esp
  80004e:	50                   	push   %eax
  80004f:	68 36 0d 80 00       	push   $0x800d36
  800054:	e8 0a 01 00 00       	call   800163 <cprintf>
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
  800061:	57                   	push   %edi
  800062:	56                   	push   %esi
  800063:	53                   	push   %ebx
  800064:	83 ec 6c             	sub    $0x6c,%esp
  800067:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	struct Env curenv = envs[ENVX(sys_getenvid())];
  80006a:	e8 2b 0a 00 00       	call   800a9a <sys_getenvid>
  80006f:	25 ff 03 00 00       	and    $0x3ff,%eax
  800074:	8d 34 00             	lea    (%eax,%eax,1),%esi
  800077:	01 c6                	add    %eax,%esi
  800079:	c1 e6 05             	shl    $0x5,%esi
  80007c:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  800082:	8d 7d 88             	lea    -0x78(%ebp),%edi
  800085:	b9 18 00 00 00       	mov    $0x18,%ecx
  80008a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	thisenv = &curenv;
  80008c:	8d 45 88             	lea    -0x78(%ebp),%eax
  80008f:	a3 04 10 80 00       	mov    %eax,0x801004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800094:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800098:	7e 07                	jle    8000a1 <libmain+0x43>
		binaryname = argv[0];
  80009a:	8b 03                	mov    (%ebx),%eax
  80009c:	a3 00 10 80 00       	mov    %eax,0x801000
	
	// call user main routine
	umain(argc, argv);
  8000a1:	83 ec 08             	sub    $0x8,%esp
  8000a4:	53                   	push   %ebx
  8000a5:	ff 75 08             	pushl  0x8(%ebp)
  8000a8:	e8 86 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000ad:	e8 0b 00 00 00       	call   8000bd <exit>
}
  8000b2:	83 c4 10             	add    $0x10,%esp
  8000b5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000b8:	5b                   	pop    %ebx
  8000b9:	5e                   	pop    %esi
  8000ba:	5f                   	pop    %edi
  8000bb:	5d                   	pop    %ebp
  8000bc:	c3                   	ret    

008000bd <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000bd:	55                   	push   %ebp
  8000be:	89 e5                	mov    %esp,%ebp
  8000c0:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8000c3:	6a 00                	push   $0x0
  8000c5:	e8 8f 09 00 00       	call   800a59 <sys_env_destroy>
}
  8000ca:	83 c4 10             	add    $0x10,%esp
  8000cd:	c9                   	leave  
  8000ce:	c3                   	ret    

008000cf <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000cf:	55                   	push   %ebp
  8000d0:	89 e5                	mov    %esp,%ebp
  8000d2:	53                   	push   %ebx
  8000d3:	83 ec 04             	sub    $0x4,%esp
  8000d6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000d9:	8b 13                	mov    (%ebx),%edx
  8000db:	8d 42 01             	lea    0x1(%edx),%eax
  8000de:	89 03                	mov    %eax,(%ebx)
  8000e0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000e3:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000e7:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000ec:	74 08                	je     8000f6 <putch+0x27>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8000ee:	ff 43 04             	incl   0x4(%ebx)
}
  8000f1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000f4:	c9                   	leave  
  8000f5:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8000f6:	83 ec 08             	sub    $0x8,%esp
  8000f9:	68 ff 00 00 00       	push   $0xff
  8000fe:	8d 43 08             	lea    0x8(%ebx),%eax
  800101:	50                   	push   %eax
  800102:	e8 15 09 00 00       	call   800a1c <sys_cputs>
		b->idx = 0;
  800107:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80010d:	83 c4 10             	add    $0x10,%esp
  800110:	eb dc                	jmp    8000ee <putch+0x1f>

00800112 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800112:	55                   	push   %ebp
  800113:	89 e5                	mov    %esp,%ebp
  800115:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80011b:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800122:	00 00 00 
	b.cnt = 0;
  800125:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80012c:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80012f:	ff 75 0c             	pushl  0xc(%ebp)
  800132:	ff 75 08             	pushl  0x8(%ebp)
  800135:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80013b:	50                   	push   %eax
  80013c:	68 cf 00 80 00       	push   $0x8000cf
  800141:	e8 0f 01 00 00       	call   800255 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800146:	83 c4 08             	add    $0x8,%esp
  800149:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80014f:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800155:	50                   	push   %eax
  800156:	e8 c1 08 00 00       	call   800a1c <sys_cputs>

	return b.cnt;
}
  80015b:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800161:	c9                   	leave  
  800162:	c3                   	ret    

00800163 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800163:	55                   	push   %ebp
  800164:	89 e5                	mov    %esp,%ebp
  800166:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800169:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80016c:	50                   	push   %eax
  80016d:	ff 75 08             	pushl  0x8(%ebp)
  800170:	e8 9d ff ff ff       	call   800112 <vcprintf>
	va_end(ap);

	return cnt;
}
  800175:	c9                   	leave  
  800176:	c3                   	ret    

00800177 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800177:	55                   	push   %ebp
  800178:	89 e5                	mov    %esp,%ebp
  80017a:	57                   	push   %edi
  80017b:	56                   	push   %esi
  80017c:	53                   	push   %ebx
  80017d:	83 ec 1c             	sub    $0x1c,%esp
  800180:	89 c7                	mov    %eax,%edi
  800182:	89 d6                	mov    %edx,%esi
  800184:	8b 45 08             	mov    0x8(%ebp),%eax
  800187:	8b 55 0c             	mov    0xc(%ebp),%edx
  80018a:	89 d1                	mov    %edx,%ecx
  80018c:	89 c2                	mov    %eax,%edx
  80018e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800191:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800194:	8b 45 10             	mov    0x10(%ebp),%eax
  800197:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80019a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80019d:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8001a4:	39 c2                	cmp    %eax,%edx
  8001a6:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  8001a9:	72 3c                	jb     8001e7 <printnum+0x70>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001ab:	83 ec 0c             	sub    $0xc,%esp
  8001ae:	ff 75 18             	pushl  0x18(%ebp)
  8001b1:	4b                   	dec    %ebx
  8001b2:	53                   	push   %ebx
  8001b3:	50                   	push   %eax
  8001b4:	83 ec 08             	sub    $0x8,%esp
  8001b7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001ba:	ff 75 e0             	pushl  -0x20(%ebp)
  8001bd:	ff 75 dc             	pushl  -0x24(%ebp)
  8001c0:	ff 75 d8             	pushl  -0x28(%ebp)
  8001c3:	e8 38 09 00 00       	call   800b00 <__udivdi3>
  8001c8:	83 c4 18             	add    $0x18,%esp
  8001cb:	52                   	push   %edx
  8001cc:	50                   	push   %eax
  8001cd:	89 f2                	mov    %esi,%edx
  8001cf:	89 f8                	mov    %edi,%eax
  8001d1:	e8 a1 ff ff ff       	call   800177 <printnum>
  8001d6:	83 c4 20             	add    $0x20,%esp
  8001d9:	eb 11                	jmp    8001ec <printnum+0x75>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001db:	83 ec 08             	sub    $0x8,%esp
  8001de:	56                   	push   %esi
  8001df:	ff 75 18             	pushl  0x18(%ebp)
  8001e2:	ff d7                	call   *%edi
  8001e4:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8001e7:	4b                   	dec    %ebx
  8001e8:	85 db                	test   %ebx,%ebx
  8001ea:	7f ef                	jg     8001db <printnum+0x64>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8001ec:	83 ec 08             	sub    $0x8,%esp
  8001ef:	56                   	push   %esi
  8001f0:	83 ec 04             	sub    $0x4,%esp
  8001f3:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001f6:	ff 75 e0             	pushl  -0x20(%ebp)
  8001f9:	ff 75 dc             	pushl  -0x24(%ebp)
  8001fc:	ff 75 d8             	pushl  -0x28(%ebp)
  8001ff:	e8 fc 09 00 00       	call   800c00 <__umoddi3>
  800204:	83 c4 14             	add    $0x14,%esp
  800207:	0f be 80 57 0d 80 00 	movsbl 0x800d57(%eax),%eax
  80020e:	50                   	push   %eax
  80020f:	ff d7                	call   *%edi
}
  800211:	83 c4 10             	add    $0x10,%esp
  800214:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800217:	5b                   	pop    %ebx
  800218:	5e                   	pop    %esi
  800219:	5f                   	pop    %edi
  80021a:	5d                   	pop    %ebp
  80021b:	c3                   	ret    

0080021c <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80021c:	55                   	push   %ebp
  80021d:	89 e5                	mov    %esp,%ebp
  80021f:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800222:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800225:	8b 10                	mov    (%eax),%edx
  800227:	3b 50 04             	cmp    0x4(%eax),%edx
  80022a:	73 0a                	jae    800236 <sprintputch+0x1a>
		*b->buf++ = ch;
  80022c:	8d 4a 01             	lea    0x1(%edx),%ecx
  80022f:	89 08                	mov    %ecx,(%eax)
  800231:	8b 45 08             	mov    0x8(%ebp),%eax
  800234:	88 02                	mov    %al,(%edx)
}
  800236:	5d                   	pop    %ebp
  800237:	c3                   	ret    

00800238 <printfmt>:
{
  800238:	55                   	push   %ebp
  800239:	89 e5                	mov    %esp,%ebp
  80023b:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  80023e:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800241:	50                   	push   %eax
  800242:	ff 75 10             	pushl  0x10(%ebp)
  800245:	ff 75 0c             	pushl  0xc(%ebp)
  800248:	ff 75 08             	pushl  0x8(%ebp)
  80024b:	e8 05 00 00 00       	call   800255 <vprintfmt>
}
  800250:	83 c4 10             	add    $0x10,%esp
  800253:	c9                   	leave  
  800254:	c3                   	ret    

00800255 <vprintfmt>:
{
  800255:	55                   	push   %ebp
  800256:	89 e5                	mov    %esp,%ebp
  800258:	57                   	push   %edi
  800259:	56                   	push   %esi
  80025a:	53                   	push   %ebx
  80025b:	83 ec 3c             	sub    $0x3c,%esp
  80025e:	8b 75 08             	mov    0x8(%ebp),%esi
  800261:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800264:	8b 7d 10             	mov    0x10(%ebp),%edi
  800267:	e9 5b 03 00 00       	jmp    8005c7 <vprintfmt+0x372>
		padc = ' ';
  80026c:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  800270:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
		precision = -1;
  800277:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  80027e:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		lflag = 0;
  800285:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80028a:	8d 47 01             	lea    0x1(%edi),%eax
  80028d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800290:	8a 17                	mov    (%edi),%dl
  800292:	8d 42 dd             	lea    -0x23(%edx),%eax
  800295:	3c 55                	cmp    $0x55,%al
  800297:	0f 87 ab 03 00 00    	ja     800648 <vprintfmt+0x3f3>
  80029d:	0f b6 c0             	movzbl %al,%eax
  8002a0:	ff 24 85 e4 0d 80 00 	jmp    *0x800de4(,%eax,4)
  8002a7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  8002aa:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  8002ae:	eb da                	jmp    80028a <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  8002b0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8002b3:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  8002b7:	eb d1                	jmp    80028a <vprintfmt+0x35>
  8002b9:	0f b6 d2             	movzbl %dl,%edx
  8002bc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  8002bf:	b8 00 00 00 00       	mov    $0x0,%eax
  8002c4:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  8002c7:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8002ca:	01 c0                	add    %eax,%eax
  8002cc:	8d 44 02 d0          	lea    -0x30(%edx,%eax,1),%eax
				ch = *fmt;
  8002d0:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8002d3:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8002d6:	83 f9 09             	cmp    $0x9,%ecx
  8002d9:	77 52                	ja     80032d <vprintfmt+0xd8>
			for (precision = 0; ; ++fmt) {
  8002db:	47                   	inc    %edi
				precision = precision * 10 + ch - '0';
  8002dc:	eb e9                	jmp    8002c7 <vprintfmt+0x72>
			precision = va_arg(ap, int);
  8002de:	8b 45 14             	mov    0x14(%ebp),%eax
  8002e1:	8b 00                	mov    (%eax),%eax
  8002e3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002e6:	8b 45 14             	mov    0x14(%ebp),%eax
  8002e9:	8d 40 04             	lea    0x4(%eax),%eax
  8002ec:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8002ef:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8002f2:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8002f6:	79 92                	jns    80028a <vprintfmt+0x35>
				width = precision, precision = -1;
  8002f8:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8002fb:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8002fe:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  800305:	eb 83                	jmp    80028a <vprintfmt+0x35>
  800307:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80030b:	78 08                	js     800315 <vprintfmt+0xc0>
		switch (ch = *(unsigned char *) fmt++) {
  80030d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800310:	e9 75 ff ff ff       	jmp    80028a <vprintfmt+0x35>
  800315:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  80031c:	eb ef                	jmp    80030d <vprintfmt+0xb8>
		switch (ch = *(unsigned char *) fmt++) {
  80031e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800321:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  800328:	e9 5d ff ff ff       	jmp    80028a <vprintfmt+0x35>
  80032d:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800330:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800333:	eb bd                	jmp    8002f2 <vprintfmt+0x9d>
			lflag++;
  800335:	41                   	inc    %ecx
		switch (ch = *(unsigned char *) fmt++) {
  800336:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800339:	e9 4c ff ff ff       	jmp    80028a <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
  80033e:	8b 45 14             	mov    0x14(%ebp),%eax
  800341:	8d 78 04             	lea    0x4(%eax),%edi
  800344:	83 ec 08             	sub    $0x8,%esp
  800347:	53                   	push   %ebx
  800348:	ff 30                	pushl  (%eax)
  80034a:	ff d6                	call   *%esi
			break;
  80034c:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  80034f:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800352:	e9 6d 02 00 00       	jmp    8005c4 <vprintfmt+0x36f>
			err = va_arg(ap, int);
  800357:	8b 45 14             	mov    0x14(%ebp),%eax
  80035a:	8d 78 04             	lea    0x4(%eax),%edi
  80035d:	8b 00                	mov    (%eax),%eax
  80035f:	85 c0                	test   %eax,%eax
  800361:	78 2a                	js     80038d <vprintfmt+0x138>
  800363:	89 c2                	mov    %eax,%edx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800365:	83 f8 06             	cmp    $0x6,%eax
  800368:	7f 27                	jg     800391 <vprintfmt+0x13c>
  80036a:	8b 04 85 3c 0f 80 00 	mov    0x800f3c(,%eax,4),%eax
  800371:	85 c0                	test   %eax,%eax
  800373:	74 1c                	je     800391 <vprintfmt+0x13c>
				printfmt(putch, putdat, "%s", p);
  800375:	50                   	push   %eax
  800376:	68 78 0d 80 00       	push   $0x800d78
  80037b:	53                   	push   %ebx
  80037c:	56                   	push   %esi
  80037d:	e8 b6 fe ff ff       	call   800238 <printfmt>
  800382:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800385:	89 7d 14             	mov    %edi,0x14(%ebp)
  800388:	e9 37 02 00 00       	jmp    8005c4 <vprintfmt+0x36f>
  80038d:	f7 d8                	neg    %eax
  80038f:	eb d2                	jmp    800363 <vprintfmt+0x10e>
				printfmt(putch, putdat, "error %d", err);
  800391:	52                   	push   %edx
  800392:	68 6f 0d 80 00       	push   $0x800d6f
  800397:	53                   	push   %ebx
  800398:	56                   	push   %esi
  800399:	e8 9a fe ff ff       	call   800238 <printfmt>
  80039e:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8003a1:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  8003a4:	e9 1b 02 00 00       	jmp    8005c4 <vprintfmt+0x36f>
			if ((p = va_arg(ap, char *)) == NULL)
  8003a9:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ac:	83 c0 04             	add    $0x4,%eax
  8003af:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8003b2:	8b 45 14             	mov    0x14(%ebp),%eax
  8003b5:	8b 00                	mov    (%eax),%eax
  8003b7:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8003ba:	85 c0                	test   %eax,%eax
  8003bc:	74 19                	je     8003d7 <vprintfmt+0x182>
			if (width > 0 && padc != '-')
  8003be:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8003c2:	7e 06                	jle    8003ca <vprintfmt+0x175>
  8003c4:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  8003c8:	75 16                	jne    8003e0 <vprintfmt+0x18b>
				for (width -= strnlen(p, precision); width > 0; width--)
  8003ca:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8003cd:	89 c7                	mov    %eax,%edi
  8003cf:	03 45 d4             	add    -0x2c(%ebp),%eax
  8003d2:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8003d5:	eb 62                	jmp    800439 <vprintfmt+0x1e4>
				p = "(null)";
  8003d7:	c7 45 cc 68 0d 80 00 	movl   $0x800d68,-0x34(%ebp)
  8003de:	eb de                	jmp    8003be <vprintfmt+0x169>
				for (width -= strnlen(p, precision); width > 0; width--)
  8003e0:	83 ec 08             	sub    $0x8,%esp
  8003e3:	ff 75 d8             	pushl  -0x28(%ebp)
  8003e6:	ff 75 cc             	pushl  -0x34(%ebp)
  8003e9:	e8 05 03 00 00       	call   8006f3 <strnlen>
  8003ee:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8003f1:	29 c2                	sub    %eax,%edx
  8003f3:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  8003f6:	83 c4 10             	add    $0x10,%esp
  8003f9:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  8003fb:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8003ff:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  800402:	eb 0d                	jmp    800411 <vprintfmt+0x1bc>
					putch(padc, putdat);
  800404:	83 ec 08             	sub    $0x8,%esp
  800407:	53                   	push   %ebx
  800408:	ff 75 d4             	pushl  -0x2c(%ebp)
  80040b:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  80040d:	4f                   	dec    %edi
  80040e:	83 c4 10             	add    $0x10,%esp
  800411:	85 ff                	test   %edi,%edi
  800413:	7f ef                	jg     800404 <vprintfmt+0x1af>
  800415:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800418:	89 d0                	mov    %edx,%eax
  80041a:	85 d2                	test   %edx,%edx
  80041c:	78 0a                	js     800428 <vprintfmt+0x1d3>
  80041e:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800421:	29 c2                	sub    %eax,%edx
  800423:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800426:	eb a2                	jmp    8003ca <vprintfmt+0x175>
  800428:	b8 00 00 00 00       	mov    $0x0,%eax
  80042d:	eb ef                	jmp    80041e <vprintfmt+0x1c9>
					putch(ch, putdat);
  80042f:	83 ec 08             	sub    $0x8,%esp
  800432:	53                   	push   %ebx
  800433:	52                   	push   %edx
  800434:	ff d6                	call   *%esi
  800436:	83 c4 10             	add    $0x10,%esp
  800439:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  80043c:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80043e:	47                   	inc    %edi
  80043f:	8a 47 ff             	mov    -0x1(%edi),%al
  800442:	0f be d0             	movsbl %al,%edx
  800445:	85 d2                	test   %edx,%edx
  800447:	74 48                	je     800491 <vprintfmt+0x23c>
  800449:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80044d:	78 05                	js     800454 <vprintfmt+0x1ff>
  80044f:	ff 4d d8             	decl   -0x28(%ebp)
  800452:	78 1e                	js     800472 <vprintfmt+0x21d>
				if (altflag && (ch < ' ' || ch > '~'))
  800454:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800458:	74 d5                	je     80042f <vprintfmt+0x1da>
  80045a:	0f be c0             	movsbl %al,%eax
  80045d:	83 e8 20             	sub    $0x20,%eax
  800460:	83 f8 5e             	cmp    $0x5e,%eax
  800463:	76 ca                	jbe    80042f <vprintfmt+0x1da>
					putch('?', putdat);
  800465:	83 ec 08             	sub    $0x8,%esp
  800468:	53                   	push   %ebx
  800469:	6a 3f                	push   $0x3f
  80046b:	ff d6                	call   *%esi
  80046d:	83 c4 10             	add    $0x10,%esp
  800470:	eb c7                	jmp    800439 <vprintfmt+0x1e4>
  800472:	89 cf                	mov    %ecx,%edi
  800474:	eb 0c                	jmp    800482 <vprintfmt+0x22d>
				putch(' ', putdat);
  800476:	83 ec 08             	sub    $0x8,%esp
  800479:	53                   	push   %ebx
  80047a:	6a 20                	push   $0x20
  80047c:	ff d6                	call   *%esi
			for (; width > 0; width--)
  80047e:	4f                   	dec    %edi
  80047f:	83 c4 10             	add    $0x10,%esp
  800482:	85 ff                	test   %edi,%edi
  800484:	7f f0                	jg     800476 <vprintfmt+0x221>
			if ((p = va_arg(ap, char *)) == NULL)
  800486:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800489:	89 45 14             	mov    %eax,0x14(%ebp)
  80048c:	e9 33 01 00 00       	jmp    8005c4 <vprintfmt+0x36f>
  800491:	89 cf                	mov    %ecx,%edi
  800493:	eb ed                	jmp    800482 <vprintfmt+0x22d>
	if (lflag >= 2)
  800495:	83 f9 01             	cmp    $0x1,%ecx
  800498:	7f 1b                	jg     8004b5 <vprintfmt+0x260>
	else if (lflag)
  80049a:	85 c9                	test   %ecx,%ecx
  80049c:	74 42                	je     8004e0 <vprintfmt+0x28b>
		return va_arg(*ap, long);
  80049e:	8b 45 14             	mov    0x14(%ebp),%eax
  8004a1:	8b 00                	mov    (%eax),%eax
  8004a3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004a6:	99                   	cltd   
  8004a7:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8004aa:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ad:	8d 40 04             	lea    0x4(%eax),%eax
  8004b0:	89 45 14             	mov    %eax,0x14(%ebp)
  8004b3:	eb 17                	jmp    8004cc <vprintfmt+0x277>
		return va_arg(*ap, long long);
  8004b5:	8b 45 14             	mov    0x14(%ebp),%eax
  8004b8:	8b 50 04             	mov    0x4(%eax),%edx
  8004bb:	8b 00                	mov    (%eax),%eax
  8004bd:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004c0:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8004c3:	8b 45 14             	mov    0x14(%ebp),%eax
  8004c6:	8d 40 08             	lea    0x8(%eax),%eax
  8004c9:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  8004cc:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8004cf:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8004d2:	85 c9                	test   %ecx,%ecx
  8004d4:	78 21                	js     8004f7 <vprintfmt+0x2a2>
			base = 10;
  8004d6:	b8 0a 00 00 00       	mov    $0xa,%eax
  8004db:	e9 ca 00 00 00       	jmp    8005aa <vprintfmt+0x355>
		return va_arg(*ap, int);
  8004e0:	8b 45 14             	mov    0x14(%ebp),%eax
  8004e3:	8b 00                	mov    (%eax),%eax
  8004e5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004e8:	99                   	cltd   
  8004e9:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8004ec:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ef:	8d 40 04             	lea    0x4(%eax),%eax
  8004f2:	89 45 14             	mov    %eax,0x14(%ebp)
  8004f5:	eb d5                	jmp    8004cc <vprintfmt+0x277>
				putch('-', putdat);
  8004f7:	83 ec 08             	sub    $0x8,%esp
  8004fa:	53                   	push   %ebx
  8004fb:	6a 2d                	push   $0x2d
  8004fd:	ff d6                	call   *%esi
				num = -(long long) num;
  8004ff:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800502:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800505:	f7 da                	neg    %edx
  800507:	83 d1 00             	adc    $0x0,%ecx
  80050a:	f7 d9                	neg    %ecx
  80050c:	83 c4 10             	add    $0x10,%esp
			base = 10;
  80050f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800514:	e9 91 00 00 00       	jmp    8005aa <vprintfmt+0x355>
	if (lflag >= 2)
  800519:	83 f9 01             	cmp    $0x1,%ecx
  80051c:	7f 1b                	jg     800539 <vprintfmt+0x2e4>
	else if (lflag)
  80051e:	85 c9                	test   %ecx,%ecx
  800520:	74 2c                	je     80054e <vprintfmt+0x2f9>
		return va_arg(*ap, unsigned long);
  800522:	8b 45 14             	mov    0x14(%ebp),%eax
  800525:	8b 10                	mov    (%eax),%edx
  800527:	b9 00 00 00 00       	mov    $0x0,%ecx
  80052c:	8d 40 04             	lea    0x4(%eax),%eax
  80052f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800532:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  800537:	eb 71                	jmp    8005aa <vprintfmt+0x355>
		return va_arg(*ap, unsigned long long);
  800539:	8b 45 14             	mov    0x14(%ebp),%eax
  80053c:	8b 10                	mov    (%eax),%edx
  80053e:	8b 48 04             	mov    0x4(%eax),%ecx
  800541:	8d 40 08             	lea    0x8(%eax),%eax
  800544:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800547:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  80054c:	eb 5c                	jmp    8005aa <vprintfmt+0x355>
		return va_arg(*ap, unsigned int);
  80054e:	8b 45 14             	mov    0x14(%ebp),%eax
  800551:	8b 10                	mov    (%eax),%edx
  800553:	b9 00 00 00 00       	mov    $0x0,%ecx
  800558:	8d 40 04             	lea    0x4(%eax),%eax
  80055b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80055e:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  800563:	eb 45                	jmp    8005aa <vprintfmt+0x355>
			putch('X', putdat);
  800565:	83 ec 08             	sub    $0x8,%esp
  800568:	53                   	push   %ebx
  800569:	6a 58                	push   $0x58
  80056b:	ff d6                	call   *%esi
			putch('X', putdat);
  80056d:	83 c4 08             	add    $0x8,%esp
  800570:	53                   	push   %ebx
  800571:	6a 58                	push   $0x58
  800573:	ff d6                	call   *%esi
			putch('X', putdat);
  800575:	83 c4 08             	add    $0x8,%esp
  800578:	53                   	push   %ebx
  800579:	6a 58                	push   $0x58
  80057b:	ff d6                	call   *%esi
			break;
  80057d:	83 c4 10             	add    $0x10,%esp
  800580:	eb 42                	jmp    8005c4 <vprintfmt+0x36f>
			putch('0', putdat);
  800582:	83 ec 08             	sub    $0x8,%esp
  800585:	53                   	push   %ebx
  800586:	6a 30                	push   $0x30
  800588:	ff d6                	call   *%esi
			putch('x', putdat);
  80058a:	83 c4 08             	add    $0x8,%esp
  80058d:	53                   	push   %ebx
  80058e:	6a 78                	push   $0x78
  800590:	ff d6                	call   *%esi
			num = (unsigned long long)
  800592:	8b 45 14             	mov    0x14(%ebp),%eax
  800595:	8b 10                	mov    (%eax),%edx
  800597:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  80059c:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  80059f:	8d 40 04             	lea    0x4(%eax),%eax
  8005a2:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8005a5:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  8005aa:	83 ec 0c             	sub    $0xc,%esp
  8005ad:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  8005b1:	57                   	push   %edi
  8005b2:	ff 75 d4             	pushl  -0x2c(%ebp)
  8005b5:	50                   	push   %eax
  8005b6:	51                   	push   %ecx
  8005b7:	52                   	push   %edx
  8005b8:	89 da                	mov    %ebx,%edx
  8005ba:	89 f0                	mov    %esi,%eax
  8005bc:	e8 b6 fb ff ff       	call   800177 <printnum>
			break;
  8005c1:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  8005c4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8005c7:	47                   	inc    %edi
  8005c8:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8005cc:	83 f8 25             	cmp    $0x25,%eax
  8005cf:	0f 84 97 fc ff ff    	je     80026c <vprintfmt+0x17>
			if (ch == '\0')
  8005d5:	85 c0                	test   %eax,%eax
  8005d7:	0f 84 89 00 00 00    	je     800666 <vprintfmt+0x411>
			putch(ch, putdat);
  8005dd:	83 ec 08             	sub    $0x8,%esp
  8005e0:	53                   	push   %ebx
  8005e1:	50                   	push   %eax
  8005e2:	ff d6                	call   *%esi
  8005e4:	83 c4 10             	add    $0x10,%esp
  8005e7:	eb de                	jmp    8005c7 <vprintfmt+0x372>
	if (lflag >= 2)
  8005e9:	83 f9 01             	cmp    $0x1,%ecx
  8005ec:	7f 1b                	jg     800609 <vprintfmt+0x3b4>
	else if (lflag)
  8005ee:	85 c9                	test   %ecx,%ecx
  8005f0:	74 2c                	je     80061e <vprintfmt+0x3c9>
		return va_arg(*ap, unsigned long);
  8005f2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f5:	8b 10                	mov    (%eax),%edx
  8005f7:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005fc:	8d 40 04             	lea    0x4(%eax),%eax
  8005ff:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800602:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  800607:	eb a1                	jmp    8005aa <vprintfmt+0x355>
		return va_arg(*ap, unsigned long long);
  800609:	8b 45 14             	mov    0x14(%ebp),%eax
  80060c:	8b 10                	mov    (%eax),%edx
  80060e:	8b 48 04             	mov    0x4(%eax),%ecx
  800611:	8d 40 08             	lea    0x8(%eax),%eax
  800614:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800617:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  80061c:	eb 8c                	jmp    8005aa <vprintfmt+0x355>
		return va_arg(*ap, unsigned int);
  80061e:	8b 45 14             	mov    0x14(%ebp),%eax
  800621:	8b 10                	mov    (%eax),%edx
  800623:	b9 00 00 00 00       	mov    $0x0,%ecx
  800628:	8d 40 04             	lea    0x4(%eax),%eax
  80062b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80062e:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  800633:	e9 72 ff ff ff       	jmp    8005aa <vprintfmt+0x355>
			putch(ch, putdat);
  800638:	83 ec 08             	sub    $0x8,%esp
  80063b:	53                   	push   %ebx
  80063c:	6a 25                	push   $0x25
  80063e:	ff d6                	call   *%esi
			break;
  800640:	83 c4 10             	add    $0x10,%esp
  800643:	e9 7c ff ff ff       	jmp    8005c4 <vprintfmt+0x36f>
			putch('%', putdat);
  800648:	83 ec 08             	sub    $0x8,%esp
  80064b:	53                   	push   %ebx
  80064c:	6a 25                	push   $0x25
  80064e:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800650:	83 c4 10             	add    $0x10,%esp
  800653:	89 f8                	mov    %edi,%eax
  800655:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800659:	74 03                	je     80065e <vprintfmt+0x409>
  80065b:	48                   	dec    %eax
  80065c:	eb f7                	jmp    800655 <vprintfmt+0x400>
  80065e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800661:	e9 5e ff ff ff       	jmp    8005c4 <vprintfmt+0x36f>
}
  800666:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800669:	5b                   	pop    %ebx
  80066a:	5e                   	pop    %esi
  80066b:	5f                   	pop    %edi
  80066c:	5d                   	pop    %ebp
  80066d:	c3                   	ret    

0080066e <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80066e:	55                   	push   %ebp
  80066f:	89 e5                	mov    %esp,%ebp
  800671:	83 ec 18             	sub    $0x18,%esp
  800674:	8b 45 08             	mov    0x8(%ebp),%eax
  800677:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80067a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80067d:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800681:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800684:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80068b:	85 c0                	test   %eax,%eax
  80068d:	74 26                	je     8006b5 <vsnprintf+0x47>
  80068f:	85 d2                	test   %edx,%edx
  800691:	7e 29                	jle    8006bc <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800693:	ff 75 14             	pushl  0x14(%ebp)
  800696:	ff 75 10             	pushl  0x10(%ebp)
  800699:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80069c:	50                   	push   %eax
  80069d:	68 1c 02 80 00       	push   $0x80021c
  8006a2:	e8 ae fb ff ff       	call   800255 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006a7:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006aa:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006b0:	83 c4 10             	add    $0x10,%esp
}
  8006b3:	c9                   	leave  
  8006b4:	c3                   	ret    
		return -E_INVAL;
  8006b5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8006ba:	eb f7                	jmp    8006b3 <vsnprintf+0x45>
  8006bc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8006c1:	eb f0                	jmp    8006b3 <vsnprintf+0x45>

008006c3 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006c3:	55                   	push   %ebp
  8006c4:	89 e5                	mov    %esp,%ebp
  8006c6:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006c9:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006cc:	50                   	push   %eax
  8006cd:	ff 75 10             	pushl  0x10(%ebp)
  8006d0:	ff 75 0c             	pushl  0xc(%ebp)
  8006d3:	ff 75 08             	pushl  0x8(%ebp)
  8006d6:	e8 93 ff ff ff       	call   80066e <vsnprintf>
	va_end(ap);

	return rc;
}
  8006db:	c9                   	leave  
  8006dc:	c3                   	ret    

008006dd <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006dd:	55                   	push   %ebp
  8006de:	89 e5                	mov    %esp,%ebp
  8006e0:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006e3:	b8 00 00 00 00       	mov    $0x0,%eax
  8006e8:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8006ec:	74 03                	je     8006f1 <strlen+0x14>
		n++;
  8006ee:	40                   	inc    %eax
  8006ef:	eb f7                	jmp    8006e8 <strlen+0xb>
	return n;
}
  8006f1:	5d                   	pop    %ebp
  8006f2:	c3                   	ret    

008006f3 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8006f3:	55                   	push   %ebp
  8006f4:	89 e5                	mov    %esp,%ebp
  8006f6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006f9:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006fc:	b8 00 00 00 00       	mov    $0x0,%eax
  800701:	39 d0                	cmp    %edx,%eax
  800703:	74 0b                	je     800710 <strnlen+0x1d>
  800705:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800709:	74 03                	je     80070e <strnlen+0x1b>
		n++;
  80070b:	40                   	inc    %eax
  80070c:	eb f3                	jmp    800701 <strnlen+0xe>
  80070e:	89 c2                	mov    %eax,%edx
	return n;
}
  800710:	89 d0                	mov    %edx,%eax
  800712:	5d                   	pop    %ebp
  800713:	c3                   	ret    

00800714 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800714:	55                   	push   %ebp
  800715:	89 e5                	mov    %esp,%ebp
  800717:	53                   	push   %ebx
  800718:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80071b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80071e:	b8 00 00 00 00       	mov    $0x0,%eax
  800723:	8a 14 03             	mov    (%ebx,%eax,1),%dl
  800726:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800729:	40                   	inc    %eax
  80072a:	84 d2                	test   %dl,%dl
  80072c:	75 f5                	jne    800723 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  80072e:	89 c8                	mov    %ecx,%eax
  800730:	5b                   	pop    %ebx
  800731:	5d                   	pop    %ebp
  800732:	c3                   	ret    

00800733 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800733:	55                   	push   %ebp
  800734:	89 e5                	mov    %esp,%ebp
  800736:	53                   	push   %ebx
  800737:	83 ec 10             	sub    $0x10,%esp
  80073a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80073d:	53                   	push   %ebx
  80073e:	e8 9a ff ff ff       	call   8006dd <strlen>
  800743:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800746:	ff 75 0c             	pushl  0xc(%ebp)
  800749:	01 d8                	add    %ebx,%eax
  80074b:	50                   	push   %eax
  80074c:	e8 c3 ff ff ff       	call   800714 <strcpy>
	return dst;
}
  800751:	89 d8                	mov    %ebx,%eax
  800753:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800756:	c9                   	leave  
  800757:	c3                   	ret    

00800758 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800758:	55                   	push   %ebp
  800759:	89 e5                	mov    %esp,%ebp
  80075b:	53                   	push   %ebx
  80075c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80075f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800762:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800765:	8b 45 08             	mov    0x8(%ebp),%eax
  800768:	39 d8                	cmp    %ebx,%eax
  80076a:	74 0e                	je     80077a <strncpy+0x22>
		*dst++ = *src;
  80076c:	40                   	inc    %eax
  80076d:	8a 0a                	mov    (%edx),%cl
  80076f:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800772:	80 f9 01             	cmp    $0x1,%cl
  800775:	83 da ff             	sbb    $0xffffffff,%edx
  800778:	eb ee                	jmp    800768 <strncpy+0x10>
	}
	return ret;
}
  80077a:	8b 45 08             	mov    0x8(%ebp),%eax
  80077d:	5b                   	pop    %ebx
  80077e:	5d                   	pop    %ebp
  80077f:	c3                   	ret    

00800780 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800780:	55                   	push   %ebp
  800781:	89 e5                	mov    %esp,%ebp
  800783:	56                   	push   %esi
  800784:	53                   	push   %ebx
  800785:	8b 75 08             	mov    0x8(%ebp),%esi
  800788:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80078b:	8b 45 10             	mov    0x10(%ebp),%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80078e:	85 c0                	test   %eax,%eax
  800790:	74 22                	je     8007b4 <strlcpy+0x34>
  800792:	8d 44 06 ff          	lea    -0x1(%esi,%eax,1),%eax
  800796:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  800798:	39 c2                	cmp    %eax,%edx
  80079a:	74 0f                	je     8007ab <strlcpy+0x2b>
  80079c:	8a 19                	mov    (%ecx),%bl
  80079e:	84 db                	test   %bl,%bl
  8007a0:	74 07                	je     8007a9 <strlcpy+0x29>
			*dst++ = *src++;
  8007a2:	41                   	inc    %ecx
  8007a3:	42                   	inc    %edx
  8007a4:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007a7:	eb ef                	jmp    800798 <strlcpy+0x18>
  8007a9:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  8007ab:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8007ae:	29 f0                	sub    %esi,%eax
}
  8007b0:	5b                   	pop    %ebx
  8007b1:	5e                   	pop    %esi
  8007b2:	5d                   	pop    %ebp
  8007b3:	c3                   	ret    
  8007b4:	89 f0                	mov    %esi,%eax
  8007b6:	eb f6                	jmp    8007ae <strlcpy+0x2e>

008007b8 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007b8:	55                   	push   %ebp
  8007b9:	89 e5                	mov    %esp,%ebp
  8007bb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007be:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007c1:	8a 01                	mov    (%ecx),%al
  8007c3:	84 c0                	test   %al,%al
  8007c5:	74 08                	je     8007cf <strcmp+0x17>
  8007c7:	3a 02                	cmp    (%edx),%al
  8007c9:	75 04                	jne    8007cf <strcmp+0x17>
		p++, q++;
  8007cb:	41                   	inc    %ecx
  8007cc:	42                   	inc    %edx
  8007cd:	eb f2                	jmp    8007c1 <strcmp+0x9>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007cf:	0f b6 c0             	movzbl %al,%eax
  8007d2:	0f b6 12             	movzbl (%edx),%edx
  8007d5:	29 d0                	sub    %edx,%eax
}
  8007d7:	5d                   	pop    %ebp
  8007d8:	c3                   	ret    

008007d9 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8007d9:	55                   	push   %ebp
  8007da:	89 e5                	mov    %esp,%ebp
  8007dc:	53                   	push   %ebx
  8007dd:	8b 45 08             	mov    0x8(%ebp),%eax
  8007e0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007e3:	89 c3                	mov    %eax,%ebx
  8007e5:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8007e8:	eb 02                	jmp    8007ec <strncmp+0x13>
		n--, p++, q++;
  8007ea:	40                   	inc    %eax
  8007eb:	42                   	inc    %edx
	while (n > 0 && *p && *p == *q)
  8007ec:	39 d8                	cmp    %ebx,%eax
  8007ee:	74 15                	je     800805 <strncmp+0x2c>
  8007f0:	8a 08                	mov    (%eax),%cl
  8007f2:	84 c9                	test   %cl,%cl
  8007f4:	74 04                	je     8007fa <strncmp+0x21>
  8007f6:	3a 0a                	cmp    (%edx),%cl
  8007f8:	74 f0                	je     8007ea <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8007fa:	0f b6 00             	movzbl (%eax),%eax
  8007fd:	0f b6 12             	movzbl (%edx),%edx
  800800:	29 d0                	sub    %edx,%eax
}
  800802:	5b                   	pop    %ebx
  800803:	5d                   	pop    %ebp
  800804:	c3                   	ret    
		return 0;
  800805:	b8 00 00 00 00       	mov    $0x0,%eax
  80080a:	eb f6                	jmp    800802 <strncmp+0x29>

0080080c <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80080c:	55                   	push   %ebp
  80080d:	89 e5                	mov    %esp,%ebp
  80080f:	8b 45 08             	mov    0x8(%ebp),%eax
  800812:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800815:	8a 10                	mov    (%eax),%dl
  800817:	84 d2                	test   %dl,%dl
  800819:	74 07                	je     800822 <strchr+0x16>
		if (*s == c)
  80081b:	38 ca                	cmp    %cl,%dl
  80081d:	74 08                	je     800827 <strchr+0x1b>
	for (; *s; s++)
  80081f:	40                   	inc    %eax
  800820:	eb f3                	jmp    800815 <strchr+0x9>
			return (char *) s;
	return 0;
  800822:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800827:	5d                   	pop    %ebp
  800828:	c3                   	ret    

00800829 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800829:	55                   	push   %ebp
  80082a:	89 e5                	mov    %esp,%ebp
  80082c:	8b 45 08             	mov    0x8(%ebp),%eax
  80082f:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800832:	8a 10                	mov    (%eax),%dl
  800834:	84 d2                	test   %dl,%dl
  800836:	74 07                	je     80083f <strfind+0x16>
		if (*s == c)
  800838:	38 ca                	cmp    %cl,%dl
  80083a:	74 03                	je     80083f <strfind+0x16>
	for (; *s; s++)
  80083c:	40                   	inc    %eax
  80083d:	eb f3                	jmp    800832 <strfind+0x9>
			break;
	return (char *) s;
}
  80083f:	5d                   	pop    %ebp
  800840:	c3                   	ret    

00800841 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800841:	55                   	push   %ebp
  800842:	89 e5                	mov    %esp,%ebp
  800844:	57                   	push   %edi
  800845:	56                   	push   %esi
  800846:	53                   	push   %ebx
  800847:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80084a:	85 c9                	test   %ecx,%ecx
  80084c:	74 36                	je     800884 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80084e:	89 c8                	mov    %ecx,%eax
  800850:	0b 45 08             	or     0x8(%ebp),%eax
  800853:	a8 03                	test   $0x3,%al
  800855:	75 24                	jne    80087b <memset+0x3a>
		c &= 0xFF;
  800857:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80085b:	89 d3                	mov    %edx,%ebx
  80085d:	c1 e3 08             	shl    $0x8,%ebx
  800860:	89 d0                	mov    %edx,%eax
  800862:	c1 e0 18             	shl    $0x18,%eax
  800865:	89 d6                	mov    %edx,%esi
  800867:	c1 e6 10             	shl    $0x10,%esi
  80086a:	09 f0                	or     %esi,%eax
  80086c:	09 d0                	or     %edx,%eax
  80086e:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800870:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800873:	8b 7d 08             	mov    0x8(%ebp),%edi
  800876:	fc                   	cld    
  800877:	f3 ab                	rep stos %eax,%es:(%edi)
  800879:	eb 09                	jmp    800884 <memset+0x43>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80087b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80087e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800881:	fc                   	cld    
  800882:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800884:	8b 45 08             	mov    0x8(%ebp),%eax
  800887:	5b                   	pop    %ebx
  800888:	5e                   	pop    %esi
  800889:	5f                   	pop    %edi
  80088a:	5d                   	pop    %ebp
  80088b:	c3                   	ret    

0080088c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80088c:	55                   	push   %ebp
  80088d:	89 e5                	mov    %esp,%ebp
  80088f:	57                   	push   %edi
  800890:	56                   	push   %esi
  800891:	8b 45 08             	mov    0x8(%ebp),%eax
  800894:	8b 75 0c             	mov    0xc(%ebp),%esi
  800897:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80089a:	39 c6                	cmp    %eax,%esi
  80089c:	73 30                	jae    8008ce <memmove+0x42>
  80089e:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008a1:	39 c2                	cmp    %eax,%edx
  8008a3:	76 29                	jbe    8008ce <memmove+0x42>
		s += n;
		d += n;
  8008a5:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008a8:	89 fe                	mov    %edi,%esi
  8008aa:	09 ce                	or     %ecx,%esi
  8008ac:	09 d6                	or     %edx,%esi
  8008ae:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008b4:	75 0e                	jne    8008c4 <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8008b6:	83 ef 04             	sub    $0x4,%edi
  8008b9:	8d 72 fc             	lea    -0x4(%edx),%esi
  8008bc:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  8008bf:	fd                   	std    
  8008c0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008c2:	eb 07                	jmp    8008cb <memmove+0x3f>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8008c4:	4f                   	dec    %edi
  8008c5:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  8008c8:	fd                   	std    
  8008c9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8008cb:	fc                   	cld    
  8008cc:	eb 1a                	jmp    8008e8 <memmove+0x5c>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008ce:	89 c2                	mov    %eax,%edx
  8008d0:	09 ca                	or     %ecx,%edx
  8008d2:	09 f2                	or     %esi,%edx
  8008d4:	f6 c2 03             	test   $0x3,%dl
  8008d7:	75 0a                	jne    8008e3 <memmove+0x57>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8008d9:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  8008dc:	89 c7                	mov    %eax,%edi
  8008de:	fc                   	cld    
  8008df:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008e1:	eb 05                	jmp    8008e8 <memmove+0x5c>
		else
			asm volatile("cld; rep movsb\n"
  8008e3:	89 c7                	mov    %eax,%edi
  8008e5:	fc                   	cld    
  8008e6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8008e8:	5e                   	pop    %esi
  8008e9:	5f                   	pop    %edi
  8008ea:	5d                   	pop    %ebp
  8008eb:	c3                   	ret    

008008ec <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8008ec:	55                   	push   %ebp
  8008ed:	89 e5                	mov    %esp,%ebp
  8008ef:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8008f2:	ff 75 10             	pushl  0x10(%ebp)
  8008f5:	ff 75 0c             	pushl  0xc(%ebp)
  8008f8:	ff 75 08             	pushl  0x8(%ebp)
  8008fb:	e8 8c ff ff ff       	call   80088c <memmove>
}
  800900:	c9                   	leave  
  800901:	c3                   	ret    

00800902 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800902:	55                   	push   %ebp
  800903:	89 e5                	mov    %esp,%ebp
  800905:	56                   	push   %esi
  800906:	53                   	push   %ebx
  800907:	8b 45 08             	mov    0x8(%ebp),%eax
  80090a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80090d:	89 c6                	mov    %eax,%esi
  80090f:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800912:	39 f0                	cmp    %esi,%eax
  800914:	74 16                	je     80092c <memcmp+0x2a>
		if (*s1 != *s2)
  800916:	8a 08                	mov    (%eax),%cl
  800918:	8a 1a                	mov    (%edx),%bl
  80091a:	38 d9                	cmp    %bl,%cl
  80091c:	75 04                	jne    800922 <memcmp+0x20>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  80091e:	40                   	inc    %eax
  80091f:	42                   	inc    %edx
  800920:	eb f0                	jmp    800912 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800922:	0f b6 c1             	movzbl %cl,%eax
  800925:	0f b6 db             	movzbl %bl,%ebx
  800928:	29 d8                	sub    %ebx,%eax
  80092a:	eb 05                	jmp    800931 <memcmp+0x2f>
	}

	return 0;
  80092c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800931:	5b                   	pop    %ebx
  800932:	5e                   	pop    %esi
  800933:	5d                   	pop    %ebp
  800934:	c3                   	ret    

00800935 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800935:	55                   	push   %ebp
  800936:	89 e5                	mov    %esp,%ebp
  800938:	8b 45 08             	mov    0x8(%ebp),%eax
  80093b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  80093e:	89 c2                	mov    %eax,%edx
  800940:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800943:	39 d0                	cmp    %edx,%eax
  800945:	73 07                	jae    80094e <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
  800947:	38 08                	cmp    %cl,(%eax)
  800949:	74 03                	je     80094e <memfind+0x19>
	for (; s < ends; s++)
  80094b:	40                   	inc    %eax
  80094c:	eb f5                	jmp    800943 <memfind+0xe>
			break;
	return (void *) s;
}
  80094e:	5d                   	pop    %ebp
  80094f:	c3                   	ret    

00800950 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800950:	55                   	push   %ebp
  800951:	89 e5                	mov    %esp,%ebp
  800953:	57                   	push   %edi
  800954:	56                   	push   %esi
  800955:	53                   	push   %ebx
  800956:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800959:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80095c:	eb 01                	jmp    80095f <strtol+0xf>
		s++;
  80095e:	41                   	inc    %ecx
	while (*s == ' ' || *s == '\t')
  80095f:	8a 01                	mov    (%ecx),%al
  800961:	3c 20                	cmp    $0x20,%al
  800963:	74 f9                	je     80095e <strtol+0xe>
  800965:	3c 09                	cmp    $0x9,%al
  800967:	74 f5                	je     80095e <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800969:	3c 2b                	cmp    $0x2b,%al
  80096b:	74 24                	je     800991 <strtol+0x41>
		s++;
	else if (*s == '-')
  80096d:	3c 2d                	cmp    $0x2d,%al
  80096f:	74 28                	je     800999 <strtol+0x49>
	int neg = 0;
  800971:	bf 00 00 00 00       	mov    $0x0,%edi
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800976:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  80097c:	75 09                	jne    800987 <strtol+0x37>
  80097e:	80 39 30             	cmpb   $0x30,(%ecx)
  800981:	74 1e                	je     8009a1 <strtol+0x51>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800983:	85 db                	test   %ebx,%ebx
  800985:	74 36                	je     8009bd <strtol+0x6d>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800987:	b8 00 00 00 00       	mov    $0x0,%eax
  80098c:	89 5d 10             	mov    %ebx,0x10(%ebp)
  80098f:	eb 45                	jmp    8009d6 <strtol+0x86>
		s++;
  800991:	41                   	inc    %ecx
	int neg = 0;
  800992:	bf 00 00 00 00       	mov    $0x0,%edi
  800997:	eb dd                	jmp    800976 <strtol+0x26>
		s++, neg = 1;
  800999:	41                   	inc    %ecx
  80099a:	bf 01 00 00 00       	mov    $0x1,%edi
  80099f:	eb d5                	jmp    800976 <strtol+0x26>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009a1:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8009a5:	74 0c                	je     8009b3 <strtol+0x63>
	else if (base == 0 && s[0] == '0')
  8009a7:	85 db                	test   %ebx,%ebx
  8009a9:	75 dc                	jne    800987 <strtol+0x37>
		s++, base = 8;
  8009ab:	41                   	inc    %ecx
  8009ac:	bb 08 00 00 00       	mov    $0x8,%ebx
  8009b1:	eb d4                	jmp    800987 <strtol+0x37>
		s += 2, base = 16;
  8009b3:	83 c1 02             	add    $0x2,%ecx
  8009b6:	bb 10 00 00 00       	mov    $0x10,%ebx
  8009bb:	eb ca                	jmp    800987 <strtol+0x37>
		base = 10;
  8009bd:	bb 0a 00 00 00       	mov    $0xa,%ebx
  8009c2:	eb c3                	jmp    800987 <strtol+0x37>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  8009c4:	0f be d2             	movsbl %dl,%edx
  8009c7:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  8009ca:	3b 55 10             	cmp    0x10(%ebp),%edx
  8009cd:	7d 37                	jge    800a06 <strtol+0xb6>
			break;
		s++, val = (val * base) + dig;
  8009cf:	41                   	inc    %ecx
  8009d0:	0f af 45 10          	imul   0x10(%ebp),%eax
  8009d4:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  8009d6:	8a 11                	mov    (%ecx),%dl
  8009d8:	8d 72 d0             	lea    -0x30(%edx),%esi
  8009db:	89 f3                	mov    %esi,%ebx
  8009dd:	80 fb 09             	cmp    $0x9,%bl
  8009e0:	76 e2                	jbe    8009c4 <strtol+0x74>
		else if (*s >= 'a' && *s <= 'z')
  8009e2:	8d 72 9f             	lea    -0x61(%edx),%esi
  8009e5:	89 f3                	mov    %esi,%ebx
  8009e7:	80 fb 19             	cmp    $0x19,%bl
  8009ea:	77 08                	ja     8009f4 <strtol+0xa4>
			dig = *s - 'a' + 10;
  8009ec:	0f be d2             	movsbl %dl,%edx
  8009ef:	83 ea 57             	sub    $0x57,%edx
  8009f2:	eb d6                	jmp    8009ca <strtol+0x7a>
		else if (*s >= 'A' && *s <= 'Z')
  8009f4:	8d 72 bf             	lea    -0x41(%edx),%esi
  8009f7:	89 f3                	mov    %esi,%ebx
  8009f9:	80 fb 19             	cmp    $0x19,%bl
  8009fc:	77 08                	ja     800a06 <strtol+0xb6>
			dig = *s - 'A' + 10;
  8009fe:	0f be d2             	movsbl %dl,%edx
  800a01:	83 ea 37             	sub    $0x37,%edx
  800a04:	eb c4                	jmp    8009ca <strtol+0x7a>
		// we don't properly detect overflow!
	}

	if (endptr)
  800a06:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a0a:	74 05                	je     800a11 <strtol+0xc1>
		*endptr = (char *) s;
  800a0c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a0f:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800a11:	85 ff                	test   %edi,%edi
  800a13:	74 02                	je     800a17 <strtol+0xc7>
  800a15:	f7 d8                	neg    %eax
}
  800a17:	5b                   	pop    %ebx
  800a18:	5e                   	pop    %esi
  800a19:	5f                   	pop    %edi
  800a1a:	5d                   	pop    %ebp
  800a1b:	c3                   	ret    

00800a1c <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a1c:	55                   	push   %ebp
  800a1d:	89 e5                	mov    %esp,%ebp
  800a1f:	57                   	push   %edi
  800a20:	56                   	push   %esi
  800a21:	53                   	push   %ebx
	asm volatile("int %1\n"
  800a22:	b8 00 00 00 00       	mov    $0x0,%eax
  800a27:	8b 55 08             	mov    0x8(%ebp),%edx
  800a2a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a2d:	89 c3                	mov    %eax,%ebx
  800a2f:	89 c7                	mov    %eax,%edi
  800a31:	89 c6                	mov    %eax,%esi
  800a33:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a35:	5b                   	pop    %ebx
  800a36:	5e                   	pop    %esi
  800a37:	5f                   	pop    %edi
  800a38:	5d                   	pop    %ebp
  800a39:	c3                   	ret    

00800a3a <sys_cgetc>:

int
sys_cgetc(void)
{
  800a3a:	55                   	push   %ebp
  800a3b:	89 e5                	mov    %esp,%ebp
  800a3d:	57                   	push   %edi
  800a3e:	56                   	push   %esi
  800a3f:	53                   	push   %ebx
	asm volatile("int %1\n"
  800a40:	ba 00 00 00 00       	mov    $0x0,%edx
  800a45:	b8 01 00 00 00       	mov    $0x1,%eax
  800a4a:	89 d1                	mov    %edx,%ecx
  800a4c:	89 d3                	mov    %edx,%ebx
  800a4e:	89 d7                	mov    %edx,%edi
  800a50:	89 d6                	mov    %edx,%esi
  800a52:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800a54:	5b                   	pop    %ebx
  800a55:	5e                   	pop    %esi
  800a56:	5f                   	pop    %edi
  800a57:	5d                   	pop    %ebp
  800a58:	c3                   	ret    

00800a59 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800a59:	55                   	push   %ebp
  800a5a:	89 e5                	mov    %esp,%ebp
  800a5c:	57                   	push   %edi
  800a5d:	56                   	push   %esi
  800a5e:	53                   	push   %ebx
  800a5f:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800a62:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a67:	8b 55 08             	mov    0x8(%ebp),%edx
  800a6a:	b8 03 00 00 00       	mov    $0x3,%eax
  800a6f:	89 cb                	mov    %ecx,%ebx
  800a71:	89 cf                	mov    %ecx,%edi
  800a73:	89 ce                	mov    %ecx,%esi
  800a75:	cd 30                	int    $0x30
	if(check && ret > 0)
  800a77:	85 c0                	test   %eax,%eax
  800a79:	7f 08                	jg     800a83 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800a7b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a7e:	5b                   	pop    %ebx
  800a7f:	5e                   	pop    %esi
  800a80:	5f                   	pop    %edi
  800a81:	5d                   	pop    %ebp
  800a82:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800a83:	83 ec 0c             	sub    $0xc,%esp
  800a86:	50                   	push   %eax
  800a87:	6a 03                	push   $0x3
  800a89:	68 58 0f 80 00       	push   $0x800f58
  800a8e:	6a 23                	push   $0x23
  800a90:	68 75 0f 80 00       	push   $0x800f75
  800a95:	e8 1f 00 00 00       	call   800ab9 <_panic>

00800a9a <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800a9a:	55                   	push   %ebp
  800a9b:	89 e5                	mov    %esp,%ebp
  800a9d:	57                   	push   %edi
  800a9e:	56                   	push   %esi
  800a9f:	53                   	push   %ebx
	asm volatile("int %1\n"
  800aa0:	ba 00 00 00 00       	mov    $0x0,%edx
  800aa5:	b8 02 00 00 00       	mov    $0x2,%eax
  800aaa:	89 d1                	mov    %edx,%ecx
  800aac:	89 d3                	mov    %edx,%ebx
  800aae:	89 d7                	mov    %edx,%edi
  800ab0:	89 d6                	mov    %edx,%esi
  800ab2:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800ab4:	5b                   	pop    %ebx
  800ab5:	5e                   	pop    %esi
  800ab6:	5f                   	pop    %edi
  800ab7:	5d                   	pop    %ebp
  800ab8:	c3                   	ret    

00800ab9 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800ab9:	55                   	push   %ebp
  800aba:	89 e5                	mov    %esp,%ebp
  800abc:	56                   	push   %esi
  800abd:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800abe:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800ac1:	8b 35 00 10 80 00    	mov    0x801000,%esi
  800ac7:	e8 ce ff ff ff       	call   800a9a <sys_getenvid>
  800acc:	83 ec 0c             	sub    $0xc,%esp
  800acf:	ff 75 0c             	pushl  0xc(%ebp)
  800ad2:	ff 75 08             	pushl  0x8(%ebp)
  800ad5:	56                   	push   %esi
  800ad6:	50                   	push   %eax
  800ad7:	68 84 0f 80 00       	push   $0x800f84
  800adc:	e8 82 f6 ff ff       	call   800163 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800ae1:	83 c4 18             	add    $0x18,%esp
  800ae4:	53                   	push   %ebx
  800ae5:	ff 75 10             	pushl  0x10(%ebp)
  800ae8:	e8 25 f6 ff ff       	call   800112 <vcprintf>
	cprintf("\n");
  800aed:	c7 04 24 34 0d 80 00 	movl   $0x800d34,(%esp)
  800af4:	e8 6a f6 ff ff       	call   800163 <cprintf>
  800af9:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800afc:	cc                   	int3   
  800afd:	eb fd                	jmp    800afc <_panic+0x43>
  800aff:	90                   	nop

00800b00 <__udivdi3>:
  800b00:	55                   	push   %ebp
  800b01:	57                   	push   %edi
  800b02:	56                   	push   %esi
  800b03:	53                   	push   %ebx
  800b04:	83 ec 1c             	sub    $0x1c,%esp
  800b07:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800b0b:	8b 74 24 34          	mov    0x34(%esp),%esi
  800b0f:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800b13:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800b17:	85 d2                	test   %edx,%edx
  800b19:	75 19                	jne    800b34 <__udivdi3+0x34>
  800b1b:	39 f7                	cmp    %esi,%edi
  800b1d:	76 45                	jbe    800b64 <__udivdi3+0x64>
  800b1f:	89 e8                	mov    %ebp,%eax
  800b21:	89 f2                	mov    %esi,%edx
  800b23:	f7 f7                	div    %edi
  800b25:	31 db                	xor    %ebx,%ebx
  800b27:	89 da                	mov    %ebx,%edx
  800b29:	83 c4 1c             	add    $0x1c,%esp
  800b2c:	5b                   	pop    %ebx
  800b2d:	5e                   	pop    %esi
  800b2e:	5f                   	pop    %edi
  800b2f:	5d                   	pop    %ebp
  800b30:	c3                   	ret    
  800b31:	8d 76 00             	lea    0x0(%esi),%esi
  800b34:	39 f2                	cmp    %esi,%edx
  800b36:	76 10                	jbe    800b48 <__udivdi3+0x48>
  800b38:	31 db                	xor    %ebx,%ebx
  800b3a:	31 c0                	xor    %eax,%eax
  800b3c:	89 da                	mov    %ebx,%edx
  800b3e:	83 c4 1c             	add    $0x1c,%esp
  800b41:	5b                   	pop    %ebx
  800b42:	5e                   	pop    %esi
  800b43:	5f                   	pop    %edi
  800b44:	5d                   	pop    %ebp
  800b45:	c3                   	ret    
  800b46:	66 90                	xchg   %ax,%ax
  800b48:	0f bd da             	bsr    %edx,%ebx
  800b4b:	83 f3 1f             	xor    $0x1f,%ebx
  800b4e:	75 3c                	jne    800b8c <__udivdi3+0x8c>
  800b50:	39 f2                	cmp    %esi,%edx
  800b52:	72 08                	jb     800b5c <__udivdi3+0x5c>
  800b54:	39 ef                	cmp    %ebp,%edi
  800b56:	0f 87 9c 00 00 00    	ja     800bf8 <__udivdi3+0xf8>
  800b5c:	b8 01 00 00 00       	mov    $0x1,%eax
  800b61:	eb d9                	jmp    800b3c <__udivdi3+0x3c>
  800b63:	90                   	nop
  800b64:	89 f9                	mov    %edi,%ecx
  800b66:	85 ff                	test   %edi,%edi
  800b68:	75 0b                	jne    800b75 <__udivdi3+0x75>
  800b6a:	b8 01 00 00 00       	mov    $0x1,%eax
  800b6f:	31 d2                	xor    %edx,%edx
  800b71:	f7 f7                	div    %edi
  800b73:	89 c1                	mov    %eax,%ecx
  800b75:	31 d2                	xor    %edx,%edx
  800b77:	89 f0                	mov    %esi,%eax
  800b79:	f7 f1                	div    %ecx
  800b7b:	89 c3                	mov    %eax,%ebx
  800b7d:	89 e8                	mov    %ebp,%eax
  800b7f:	f7 f1                	div    %ecx
  800b81:	89 da                	mov    %ebx,%edx
  800b83:	83 c4 1c             	add    $0x1c,%esp
  800b86:	5b                   	pop    %ebx
  800b87:	5e                   	pop    %esi
  800b88:	5f                   	pop    %edi
  800b89:	5d                   	pop    %ebp
  800b8a:	c3                   	ret    
  800b8b:	90                   	nop
  800b8c:	b8 20 00 00 00       	mov    $0x20,%eax
  800b91:	29 d8                	sub    %ebx,%eax
  800b93:	88 d9                	mov    %bl,%cl
  800b95:	d3 e2                	shl    %cl,%edx
  800b97:	89 54 24 08          	mov    %edx,0x8(%esp)
  800b9b:	89 fa                	mov    %edi,%edx
  800b9d:	88 c1                	mov    %al,%cl
  800b9f:	d3 ea                	shr    %cl,%edx
  800ba1:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800ba5:	09 d1                	or     %edx,%ecx
  800ba7:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800bab:	88 d9                	mov    %bl,%cl
  800bad:	d3 e7                	shl    %cl,%edi
  800baf:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800bb3:	89 f7                	mov    %esi,%edi
  800bb5:	88 c1                	mov    %al,%cl
  800bb7:	d3 ef                	shr    %cl,%edi
  800bb9:	88 d9                	mov    %bl,%cl
  800bbb:	d3 e6                	shl    %cl,%esi
  800bbd:	89 ea                	mov    %ebp,%edx
  800bbf:	88 c1                	mov    %al,%cl
  800bc1:	d3 ea                	shr    %cl,%edx
  800bc3:	09 d6                	or     %edx,%esi
  800bc5:	89 f0                	mov    %esi,%eax
  800bc7:	89 fa                	mov    %edi,%edx
  800bc9:	f7 74 24 08          	divl   0x8(%esp)
  800bcd:	89 d7                	mov    %edx,%edi
  800bcf:	89 c6                	mov    %eax,%esi
  800bd1:	f7 64 24 0c          	mull   0xc(%esp)
  800bd5:	39 d7                	cmp    %edx,%edi
  800bd7:	72 13                	jb     800bec <__udivdi3+0xec>
  800bd9:	74 09                	je     800be4 <__udivdi3+0xe4>
  800bdb:	89 f0                	mov    %esi,%eax
  800bdd:	31 db                	xor    %ebx,%ebx
  800bdf:	e9 58 ff ff ff       	jmp    800b3c <__udivdi3+0x3c>
  800be4:	88 d9                	mov    %bl,%cl
  800be6:	d3 e5                	shl    %cl,%ebp
  800be8:	39 c5                	cmp    %eax,%ebp
  800bea:	73 ef                	jae    800bdb <__udivdi3+0xdb>
  800bec:	8d 46 ff             	lea    -0x1(%esi),%eax
  800bef:	31 db                	xor    %ebx,%ebx
  800bf1:	e9 46 ff ff ff       	jmp    800b3c <__udivdi3+0x3c>
  800bf6:	66 90                	xchg   %ax,%ax
  800bf8:	31 c0                	xor    %eax,%eax
  800bfa:	e9 3d ff ff ff       	jmp    800b3c <__udivdi3+0x3c>
  800bff:	90                   	nop

00800c00 <__umoddi3>:
  800c00:	55                   	push   %ebp
  800c01:	57                   	push   %edi
  800c02:	56                   	push   %esi
  800c03:	53                   	push   %ebx
  800c04:	83 ec 1c             	sub    $0x1c,%esp
  800c07:	8b 74 24 30          	mov    0x30(%esp),%esi
  800c0b:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800c0f:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800c13:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  800c17:	85 c0                	test   %eax,%eax
  800c19:	75 19                	jne    800c34 <__umoddi3+0x34>
  800c1b:	39 df                	cmp    %ebx,%edi
  800c1d:	76 51                	jbe    800c70 <__umoddi3+0x70>
  800c1f:	89 f0                	mov    %esi,%eax
  800c21:	89 da                	mov    %ebx,%edx
  800c23:	f7 f7                	div    %edi
  800c25:	89 d0                	mov    %edx,%eax
  800c27:	31 d2                	xor    %edx,%edx
  800c29:	83 c4 1c             	add    $0x1c,%esp
  800c2c:	5b                   	pop    %ebx
  800c2d:	5e                   	pop    %esi
  800c2e:	5f                   	pop    %edi
  800c2f:	5d                   	pop    %ebp
  800c30:	c3                   	ret    
  800c31:	8d 76 00             	lea    0x0(%esi),%esi
  800c34:	89 f2                	mov    %esi,%edx
  800c36:	39 d8                	cmp    %ebx,%eax
  800c38:	76 0e                	jbe    800c48 <__umoddi3+0x48>
  800c3a:	89 f0                	mov    %esi,%eax
  800c3c:	89 da                	mov    %ebx,%edx
  800c3e:	83 c4 1c             	add    $0x1c,%esp
  800c41:	5b                   	pop    %ebx
  800c42:	5e                   	pop    %esi
  800c43:	5f                   	pop    %edi
  800c44:	5d                   	pop    %ebp
  800c45:	c3                   	ret    
  800c46:	66 90                	xchg   %ax,%ax
  800c48:	0f bd e8             	bsr    %eax,%ebp
  800c4b:	83 f5 1f             	xor    $0x1f,%ebp
  800c4e:	75 44                	jne    800c94 <__umoddi3+0x94>
  800c50:	39 d8                	cmp    %ebx,%eax
  800c52:	72 06                	jb     800c5a <__umoddi3+0x5a>
  800c54:	89 d9                	mov    %ebx,%ecx
  800c56:	39 f7                	cmp    %esi,%edi
  800c58:	77 08                	ja     800c62 <__umoddi3+0x62>
  800c5a:	29 fe                	sub    %edi,%esi
  800c5c:	19 c3                	sbb    %eax,%ebx
  800c5e:	89 f2                	mov    %esi,%edx
  800c60:	89 d9                	mov    %ebx,%ecx
  800c62:	89 d0                	mov    %edx,%eax
  800c64:	89 ca                	mov    %ecx,%edx
  800c66:	83 c4 1c             	add    $0x1c,%esp
  800c69:	5b                   	pop    %ebx
  800c6a:	5e                   	pop    %esi
  800c6b:	5f                   	pop    %edi
  800c6c:	5d                   	pop    %ebp
  800c6d:	c3                   	ret    
  800c6e:	66 90                	xchg   %ax,%ax
  800c70:	89 fd                	mov    %edi,%ebp
  800c72:	85 ff                	test   %edi,%edi
  800c74:	75 0b                	jne    800c81 <__umoddi3+0x81>
  800c76:	b8 01 00 00 00       	mov    $0x1,%eax
  800c7b:	31 d2                	xor    %edx,%edx
  800c7d:	f7 f7                	div    %edi
  800c7f:	89 c5                	mov    %eax,%ebp
  800c81:	89 d8                	mov    %ebx,%eax
  800c83:	31 d2                	xor    %edx,%edx
  800c85:	f7 f5                	div    %ebp
  800c87:	89 f0                	mov    %esi,%eax
  800c89:	f7 f5                	div    %ebp
  800c8b:	89 d0                	mov    %edx,%eax
  800c8d:	31 d2                	xor    %edx,%edx
  800c8f:	eb 98                	jmp    800c29 <__umoddi3+0x29>
  800c91:	8d 76 00             	lea    0x0(%esi),%esi
  800c94:	ba 20 00 00 00       	mov    $0x20,%edx
  800c99:	29 ea                	sub    %ebp,%edx
  800c9b:	89 e9                	mov    %ebp,%ecx
  800c9d:	d3 e0                	shl    %cl,%eax
  800c9f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ca3:	89 f8                	mov    %edi,%eax
  800ca5:	89 54 24 04          	mov    %edx,0x4(%esp)
  800ca9:	88 d1                	mov    %dl,%cl
  800cab:	d3 e8                	shr    %cl,%eax
  800cad:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800cb1:	09 c1                	or     %eax,%ecx
  800cb3:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800cb7:	89 e9                	mov    %ebp,%ecx
  800cb9:	d3 e7                	shl    %cl,%edi
  800cbb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800cbf:	89 d8                	mov    %ebx,%eax
  800cc1:	8b 54 24 04          	mov    0x4(%esp),%edx
  800cc5:	88 d1                	mov    %dl,%cl
  800cc7:	d3 e8                	shr    %cl,%eax
  800cc9:	89 c7                	mov    %eax,%edi
  800ccb:	89 e9                	mov    %ebp,%ecx
  800ccd:	d3 e3                	shl    %cl,%ebx
  800ccf:	89 f0                	mov    %esi,%eax
  800cd1:	88 d1                	mov    %dl,%cl
  800cd3:	d3 e8                	shr    %cl,%eax
  800cd5:	09 d8                	or     %ebx,%eax
  800cd7:	89 e9                	mov    %ebp,%ecx
  800cd9:	d3 e6                	shl    %cl,%esi
  800cdb:	89 f3                	mov    %esi,%ebx
  800cdd:	89 fa                	mov    %edi,%edx
  800cdf:	f7 74 24 08          	divl   0x8(%esp)
  800ce3:	89 d1                	mov    %edx,%ecx
  800ce5:	f7 64 24 0c          	mull   0xc(%esp)
  800ce9:	89 c6                	mov    %eax,%esi
  800ceb:	89 d7                	mov    %edx,%edi
  800ced:	39 d1                	cmp    %edx,%ecx
  800cef:	72 27                	jb     800d18 <__umoddi3+0x118>
  800cf1:	74 21                	je     800d14 <__umoddi3+0x114>
  800cf3:	89 ca                	mov    %ecx,%edx
  800cf5:	29 f3                	sub    %esi,%ebx
  800cf7:	19 fa                	sbb    %edi,%edx
  800cf9:	89 d0                	mov    %edx,%eax
  800cfb:	8a 4c 24 04          	mov    0x4(%esp),%cl
  800cff:	d3 e0                	shl    %cl,%eax
  800d01:	89 e9                	mov    %ebp,%ecx
  800d03:	d3 eb                	shr    %cl,%ebx
  800d05:	09 d8                	or     %ebx,%eax
  800d07:	d3 ea                	shr    %cl,%edx
  800d09:	83 c4 1c             	add    $0x1c,%esp
  800d0c:	5b                   	pop    %ebx
  800d0d:	5e                   	pop    %esi
  800d0e:	5f                   	pop    %edi
  800d0f:	5d                   	pop    %ebp
  800d10:	c3                   	ret    
  800d11:	8d 76 00             	lea    0x0(%esi),%esi
  800d14:	39 c3                	cmp    %eax,%ebx
  800d16:	73 db                	jae    800cf3 <__umoddi3+0xf3>
  800d18:	2b 44 24 0c          	sub    0xc(%esp),%eax
  800d1c:	1b 54 24 08          	sbb    0x8(%esp),%edx
  800d20:	89 d7                	mov    %edx,%edi
  800d22:	89 c6                	mov    %eax,%esi
  800d24:	eb cd                	jmp    800cf3 <__umoddi3+0xf3>
