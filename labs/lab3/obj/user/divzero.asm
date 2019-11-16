
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
  800051:	68 00 0d 80 00       	push   $0x800d00
  800056:	e8 e1 00 00 00       	call   80013c <cprintf>
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
  800063:	83 ec 08             	sub    $0x8,%esp
  800066:	8b 45 08             	mov    0x8(%ebp),%eax
  800069:	8b 55 0c             	mov    0xc(%ebp),%edx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  80006c:	c7 05 08 10 80 00 00 	movl   $0x0,0x801008
  800073:	00 00 00 

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800076:	85 c0                	test   %eax,%eax
  800078:	7e 08                	jle    800082 <libmain+0x22>
		binaryname = argv[0];
  80007a:	8b 0a                	mov    (%edx),%ecx
  80007c:	89 0d 00 10 80 00    	mov    %ecx,0x801000

	// call user main routine
	umain(argc, argv);
  800082:	83 ec 08             	sub    $0x8,%esp
  800085:	52                   	push   %edx
  800086:	50                   	push   %eax
  800087:	e8 a7 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80008c:	e8 05 00 00 00       	call   800096 <exit>
}
  800091:	83 c4 10             	add    $0x10,%esp
  800094:	c9                   	leave  
  800095:	c3                   	ret    

00800096 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800096:	55                   	push   %ebp
  800097:	89 e5                	mov    %esp,%ebp
  800099:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  80009c:	6a 00                	push   $0x0
  80009e:	e8 8f 09 00 00       	call   800a32 <sys_env_destroy>
}
  8000a3:	83 c4 10             	add    $0x10,%esp
  8000a6:	c9                   	leave  
  8000a7:	c3                   	ret    

008000a8 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000a8:	55                   	push   %ebp
  8000a9:	89 e5                	mov    %esp,%ebp
  8000ab:	53                   	push   %ebx
  8000ac:	83 ec 04             	sub    $0x4,%esp
  8000af:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000b2:	8b 13                	mov    (%ebx),%edx
  8000b4:	8d 42 01             	lea    0x1(%edx),%eax
  8000b7:	89 03                	mov    %eax,(%ebx)
  8000b9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000bc:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000c0:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000c5:	74 08                	je     8000cf <putch+0x27>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8000c7:	ff 43 04             	incl   0x4(%ebx)
}
  8000ca:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000cd:	c9                   	leave  
  8000ce:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8000cf:	83 ec 08             	sub    $0x8,%esp
  8000d2:	68 ff 00 00 00       	push   $0xff
  8000d7:	8d 43 08             	lea    0x8(%ebx),%eax
  8000da:	50                   	push   %eax
  8000db:	e8 15 09 00 00       	call   8009f5 <sys_cputs>
		b->idx = 0;
  8000e0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8000e6:	83 c4 10             	add    $0x10,%esp
  8000e9:	eb dc                	jmp    8000c7 <putch+0x1f>

008000eb <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8000eb:	55                   	push   %ebp
  8000ec:	89 e5                	mov    %esp,%ebp
  8000ee:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8000f4:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8000fb:	00 00 00 
	b.cnt = 0;
  8000fe:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800105:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800108:	ff 75 0c             	pushl  0xc(%ebp)
  80010b:	ff 75 08             	pushl  0x8(%ebp)
  80010e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800114:	50                   	push   %eax
  800115:	68 a8 00 80 00       	push   $0x8000a8
  80011a:	e8 0f 01 00 00       	call   80022e <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80011f:	83 c4 08             	add    $0x8,%esp
  800122:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800128:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80012e:	50                   	push   %eax
  80012f:	e8 c1 08 00 00       	call   8009f5 <sys_cputs>

	return b.cnt;
}
  800134:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80013a:	c9                   	leave  
  80013b:	c3                   	ret    

0080013c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80013c:	55                   	push   %ebp
  80013d:	89 e5                	mov    %esp,%ebp
  80013f:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800142:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800145:	50                   	push   %eax
  800146:	ff 75 08             	pushl  0x8(%ebp)
  800149:	e8 9d ff ff ff       	call   8000eb <vcprintf>
	va_end(ap);

	return cnt;
}
  80014e:	c9                   	leave  
  80014f:	c3                   	ret    

00800150 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800150:	55                   	push   %ebp
  800151:	89 e5                	mov    %esp,%ebp
  800153:	57                   	push   %edi
  800154:	56                   	push   %esi
  800155:	53                   	push   %ebx
  800156:	83 ec 1c             	sub    $0x1c,%esp
  800159:	89 c7                	mov    %eax,%edi
  80015b:	89 d6                	mov    %edx,%esi
  80015d:	8b 45 08             	mov    0x8(%ebp),%eax
  800160:	8b 55 0c             	mov    0xc(%ebp),%edx
  800163:	89 d1                	mov    %edx,%ecx
  800165:	89 c2                	mov    %eax,%edx
  800167:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80016a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80016d:	8b 45 10             	mov    0x10(%ebp),%eax
  800170:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800173:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800176:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80017d:	39 c2                	cmp    %eax,%edx
  80017f:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  800182:	72 3c                	jb     8001c0 <printnum+0x70>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800184:	83 ec 0c             	sub    $0xc,%esp
  800187:	ff 75 18             	pushl  0x18(%ebp)
  80018a:	4b                   	dec    %ebx
  80018b:	53                   	push   %ebx
  80018c:	50                   	push   %eax
  80018d:	83 ec 08             	sub    $0x8,%esp
  800190:	ff 75 e4             	pushl  -0x1c(%ebp)
  800193:	ff 75 e0             	pushl  -0x20(%ebp)
  800196:	ff 75 dc             	pushl  -0x24(%ebp)
  800199:	ff 75 d8             	pushl  -0x28(%ebp)
  80019c:	e8 37 09 00 00       	call   800ad8 <__udivdi3>
  8001a1:	83 c4 18             	add    $0x18,%esp
  8001a4:	52                   	push   %edx
  8001a5:	50                   	push   %eax
  8001a6:	89 f2                	mov    %esi,%edx
  8001a8:	89 f8                	mov    %edi,%eax
  8001aa:	e8 a1 ff ff ff       	call   800150 <printnum>
  8001af:	83 c4 20             	add    $0x20,%esp
  8001b2:	eb 11                	jmp    8001c5 <printnum+0x75>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001b4:	83 ec 08             	sub    $0x8,%esp
  8001b7:	56                   	push   %esi
  8001b8:	ff 75 18             	pushl  0x18(%ebp)
  8001bb:	ff d7                	call   *%edi
  8001bd:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8001c0:	4b                   	dec    %ebx
  8001c1:	85 db                	test   %ebx,%ebx
  8001c3:	7f ef                	jg     8001b4 <printnum+0x64>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8001c5:	83 ec 08             	sub    $0x8,%esp
  8001c8:	56                   	push   %esi
  8001c9:	83 ec 04             	sub    $0x4,%esp
  8001cc:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001cf:	ff 75 e0             	pushl  -0x20(%ebp)
  8001d2:	ff 75 dc             	pushl  -0x24(%ebp)
  8001d5:	ff 75 d8             	pushl  -0x28(%ebp)
  8001d8:	e8 fb 09 00 00       	call   800bd8 <__umoddi3>
  8001dd:	83 c4 14             	add    $0x14,%esp
  8001e0:	0f be 80 18 0d 80 00 	movsbl 0x800d18(%eax),%eax
  8001e7:	50                   	push   %eax
  8001e8:	ff d7                	call   *%edi
}
  8001ea:	83 c4 10             	add    $0x10,%esp
  8001ed:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001f0:	5b                   	pop    %ebx
  8001f1:	5e                   	pop    %esi
  8001f2:	5f                   	pop    %edi
  8001f3:	5d                   	pop    %ebp
  8001f4:	c3                   	ret    

008001f5 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8001f5:	55                   	push   %ebp
  8001f6:	89 e5                	mov    %esp,%ebp
  8001f8:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8001fb:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8001fe:	8b 10                	mov    (%eax),%edx
  800200:	3b 50 04             	cmp    0x4(%eax),%edx
  800203:	73 0a                	jae    80020f <sprintputch+0x1a>
		*b->buf++ = ch;
  800205:	8d 4a 01             	lea    0x1(%edx),%ecx
  800208:	89 08                	mov    %ecx,(%eax)
  80020a:	8b 45 08             	mov    0x8(%ebp),%eax
  80020d:	88 02                	mov    %al,(%edx)
}
  80020f:	5d                   	pop    %ebp
  800210:	c3                   	ret    

00800211 <printfmt>:
{
  800211:	55                   	push   %ebp
  800212:	89 e5                	mov    %esp,%ebp
  800214:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800217:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80021a:	50                   	push   %eax
  80021b:	ff 75 10             	pushl  0x10(%ebp)
  80021e:	ff 75 0c             	pushl  0xc(%ebp)
  800221:	ff 75 08             	pushl  0x8(%ebp)
  800224:	e8 05 00 00 00       	call   80022e <vprintfmt>
}
  800229:	83 c4 10             	add    $0x10,%esp
  80022c:	c9                   	leave  
  80022d:	c3                   	ret    

0080022e <vprintfmt>:
{
  80022e:	55                   	push   %ebp
  80022f:	89 e5                	mov    %esp,%ebp
  800231:	57                   	push   %edi
  800232:	56                   	push   %esi
  800233:	53                   	push   %ebx
  800234:	83 ec 3c             	sub    $0x3c,%esp
  800237:	8b 75 08             	mov    0x8(%ebp),%esi
  80023a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80023d:	8b 7d 10             	mov    0x10(%ebp),%edi
  800240:	e9 5b 03 00 00       	jmp    8005a0 <vprintfmt+0x372>
		padc = ' ';
  800245:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  800249:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
		precision = -1;
  800250:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  800257:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		lflag = 0;
  80025e:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800263:	8d 47 01             	lea    0x1(%edi),%eax
  800266:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800269:	8a 17                	mov    (%edi),%dl
  80026b:	8d 42 dd             	lea    -0x23(%edx),%eax
  80026e:	3c 55                	cmp    $0x55,%al
  800270:	0f 87 ab 03 00 00    	ja     800621 <vprintfmt+0x3f3>
  800276:	0f b6 c0             	movzbl %al,%eax
  800279:	ff 24 85 a8 0d 80 00 	jmp    *0x800da8(,%eax,4)
  800280:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800283:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  800287:	eb da                	jmp    800263 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  800289:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80028c:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  800290:	eb d1                	jmp    800263 <vprintfmt+0x35>
  800292:	0f b6 d2             	movzbl %dl,%edx
  800295:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800298:	b8 00 00 00 00       	mov    $0x0,%eax
  80029d:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  8002a0:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8002a3:	01 c0                	add    %eax,%eax
  8002a5:	8d 44 02 d0          	lea    -0x30(%edx,%eax,1),%eax
				ch = *fmt;
  8002a9:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8002ac:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8002af:	83 f9 09             	cmp    $0x9,%ecx
  8002b2:	77 52                	ja     800306 <vprintfmt+0xd8>
			for (precision = 0; ; ++fmt) {
  8002b4:	47                   	inc    %edi
				precision = precision * 10 + ch - '0';
  8002b5:	eb e9                	jmp    8002a0 <vprintfmt+0x72>
			precision = va_arg(ap, int);
  8002b7:	8b 45 14             	mov    0x14(%ebp),%eax
  8002ba:	8b 00                	mov    (%eax),%eax
  8002bc:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002bf:	8b 45 14             	mov    0x14(%ebp),%eax
  8002c2:	8d 40 04             	lea    0x4(%eax),%eax
  8002c5:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8002c8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8002cb:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8002cf:	79 92                	jns    800263 <vprintfmt+0x35>
				width = precision, precision = -1;
  8002d1:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8002d4:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8002d7:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8002de:	eb 83                	jmp    800263 <vprintfmt+0x35>
  8002e0:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8002e4:	78 08                	js     8002ee <vprintfmt+0xc0>
		switch (ch = *(unsigned char *) fmt++) {
  8002e6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8002e9:	e9 75 ff ff ff       	jmp    800263 <vprintfmt+0x35>
  8002ee:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  8002f5:	eb ef                	jmp    8002e6 <vprintfmt+0xb8>
		switch (ch = *(unsigned char *) fmt++) {
  8002f7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8002fa:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  800301:	e9 5d ff ff ff       	jmp    800263 <vprintfmt+0x35>
  800306:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800309:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80030c:	eb bd                	jmp    8002cb <vprintfmt+0x9d>
			lflag++;
  80030e:	41                   	inc    %ecx
		switch (ch = *(unsigned char *) fmt++) {
  80030f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800312:	e9 4c ff ff ff       	jmp    800263 <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
  800317:	8b 45 14             	mov    0x14(%ebp),%eax
  80031a:	8d 78 04             	lea    0x4(%eax),%edi
  80031d:	83 ec 08             	sub    $0x8,%esp
  800320:	53                   	push   %ebx
  800321:	ff 30                	pushl  (%eax)
  800323:	ff d6                	call   *%esi
			break;
  800325:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800328:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  80032b:	e9 6d 02 00 00       	jmp    80059d <vprintfmt+0x36f>
			err = va_arg(ap, int);
  800330:	8b 45 14             	mov    0x14(%ebp),%eax
  800333:	8d 78 04             	lea    0x4(%eax),%edi
  800336:	8b 00                	mov    (%eax),%eax
  800338:	85 c0                	test   %eax,%eax
  80033a:	78 2a                	js     800366 <vprintfmt+0x138>
  80033c:	89 c2                	mov    %eax,%edx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80033e:	83 f8 06             	cmp    $0x6,%eax
  800341:	7f 27                	jg     80036a <vprintfmt+0x13c>
  800343:	8b 04 85 00 0f 80 00 	mov    0x800f00(,%eax,4),%eax
  80034a:	85 c0                	test   %eax,%eax
  80034c:	74 1c                	je     80036a <vprintfmt+0x13c>
				printfmt(putch, putdat, "%s", p);
  80034e:	50                   	push   %eax
  80034f:	68 39 0d 80 00       	push   $0x800d39
  800354:	53                   	push   %ebx
  800355:	56                   	push   %esi
  800356:	e8 b6 fe ff ff       	call   800211 <printfmt>
  80035b:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80035e:	89 7d 14             	mov    %edi,0x14(%ebp)
  800361:	e9 37 02 00 00       	jmp    80059d <vprintfmt+0x36f>
  800366:	f7 d8                	neg    %eax
  800368:	eb d2                	jmp    80033c <vprintfmt+0x10e>
				printfmt(putch, putdat, "error %d", err);
  80036a:	52                   	push   %edx
  80036b:	68 30 0d 80 00       	push   $0x800d30
  800370:	53                   	push   %ebx
  800371:	56                   	push   %esi
  800372:	e8 9a fe ff ff       	call   800211 <printfmt>
  800377:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80037a:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  80037d:	e9 1b 02 00 00       	jmp    80059d <vprintfmt+0x36f>
			if ((p = va_arg(ap, char *)) == NULL)
  800382:	8b 45 14             	mov    0x14(%ebp),%eax
  800385:	83 c0 04             	add    $0x4,%eax
  800388:	89 45 c8             	mov    %eax,-0x38(%ebp)
  80038b:	8b 45 14             	mov    0x14(%ebp),%eax
  80038e:	8b 00                	mov    (%eax),%eax
  800390:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800393:	85 c0                	test   %eax,%eax
  800395:	74 19                	je     8003b0 <vprintfmt+0x182>
			if (width > 0 && padc != '-')
  800397:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80039b:	7e 06                	jle    8003a3 <vprintfmt+0x175>
  80039d:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  8003a1:	75 16                	jne    8003b9 <vprintfmt+0x18b>
				for (width -= strnlen(p, precision); width > 0; width--)
  8003a3:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8003a6:	89 c7                	mov    %eax,%edi
  8003a8:	03 45 d4             	add    -0x2c(%ebp),%eax
  8003ab:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8003ae:	eb 62                	jmp    800412 <vprintfmt+0x1e4>
				p = "(null)";
  8003b0:	c7 45 cc 29 0d 80 00 	movl   $0x800d29,-0x34(%ebp)
  8003b7:	eb de                	jmp    800397 <vprintfmt+0x169>
				for (width -= strnlen(p, precision); width > 0; width--)
  8003b9:	83 ec 08             	sub    $0x8,%esp
  8003bc:	ff 75 d8             	pushl  -0x28(%ebp)
  8003bf:	ff 75 cc             	pushl  -0x34(%ebp)
  8003c2:	e8 05 03 00 00       	call   8006cc <strnlen>
  8003c7:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8003ca:	29 c2                	sub    %eax,%edx
  8003cc:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  8003cf:	83 c4 10             	add    $0x10,%esp
  8003d2:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  8003d4:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8003d8:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8003db:	eb 0d                	jmp    8003ea <vprintfmt+0x1bc>
					putch(padc, putdat);
  8003dd:	83 ec 08             	sub    $0x8,%esp
  8003e0:	53                   	push   %ebx
  8003e1:	ff 75 d4             	pushl  -0x2c(%ebp)
  8003e4:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8003e6:	4f                   	dec    %edi
  8003e7:	83 c4 10             	add    $0x10,%esp
  8003ea:	85 ff                	test   %edi,%edi
  8003ec:	7f ef                	jg     8003dd <vprintfmt+0x1af>
  8003ee:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8003f1:	89 d0                	mov    %edx,%eax
  8003f3:	85 d2                	test   %edx,%edx
  8003f5:	78 0a                	js     800401 <vprintfmt+0x1d3>
  8003f7:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8003fa:	29 c2                	sub    %eax,%edx
  8003fc:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8003ff:	eb a2                	jmp    8003a3 <vprintfmt+0x175>
  800401:	b8 00 00 00 00       	mov    $0x0,%eax
  800406:	eb ef                	jmp    8003f7 <vprintfmt+0x1c9>
					putch(ch, putdat);
  800408:	83 ec 08             	sub    $0x8,%esp
  80040b:	53                   	push   %ebx
  80040c:	52                   	push   %edx
  80040d:	ff d6                	call   *%esi
  80040f:	83 c4 10             	add    $0x10,%esp
  800412:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  800415:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800417:	47                   	inc    %edi
  800418:	8a 47 ff             	mov    -0x1(%edi),%al
  80041b:	0f be d0             	movsbl %al,%edx
  80041e:	85 d2                	test   %edx,%edx
  800420:	74 48                	je     80046a <vprintfmt+0x23c>
  800422:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800426:	78 05                	js     80042d <vprintfmt+0x1ff>
  800428:	ff 4d d8             	decl   -0x28(%ebp)
  80042b:	78 1e                	js     80044b <vprintfmt+0x21d>
				if (altflag && (ch < ' ' || ch > '~'))
  80042d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800431:	74 d5                	je     800408 <vprintfmt+0x1da>
  800433:	0f be c0             	movsbl %al,%eax
  800436:	83 e8 20             	sub    $0x20,%eax
  800439:	83 f8 5e             	cmp    $0x5e,%eax
  80043c:	76 ca                	jbe    800408 <vprintfmt+0x1da>
					putch('?', putdat);
  80043e:	83 ec 08             	sub    $0x8,%esp
  800441:	53                   	push   %ebx
  800442:	6a 3f                	push   $0x3f
  800444:	ff d6                	call   *%esi
  800446:	83 c4 10             	add    $0x10,%esp
  800449:	eb c7                	jmp    800412 <vprintfmt+0x1e4>
  80044b:	89 cf                	mov    %ecx,%edi
  80044d:	eb 0c                	jmp    80045b <vprintfmt+0x22d>
				putch(' ', putdat);
  80044f:	83 ec 08             	sub    $0x8,%esp
  800452:	53                   	push   %ebx
  800453:	6a 20                	push   $0x20
  800455:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800457:	4f                   	dec    %edi
  800458:	83 c4 10             	add    $0x10,%esp
  80045b:	85 ff                	test   %edi,%edi
  80045d:	7f f0                	jg     80044f <vprintfmt+0x221>
			if ((p = va_arg(ap, char *)) == NULL)
  80045f:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800462:	89 45 14             	mov    %eax,0x14(%ebp)
  800465:	e9 33 01 00 00       	jmp    80059d <vprintfmt+0x36f>
  80046a:	89 cf                	mov    %ecx,%edi
  80046c:	eb ed                	jmp    80045b <vprintfmt+0x22d>
	if (lflag >= 2)
  80046e:	83 f9 01             	cmp    $0x1,%ecx
  800471:	7f 1b                	jg     80048e <vprintfmt+0x260>
	else if (lflag)
  800473:	85 c9                	test   %ecx,%ecx
  800475:	74 42                	je     8004b9 <vprintfmt+0x28b>
		return va_arg(*ap, long);
  800477:	8b 45 14             	mov    0x14(%ebp),%eax
  80047a:	8b 00                	mov    (%eax),%eax
  80047c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80047f:	99                   	cltd   
  800480:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800483:	8b 45 14             	mov    0x14(%ebp),%eax
  800486:	8d 40 04             	lea    0x4(%eax),%eax
  800489:	89 45 14             	mov    %eax,0x14(%ebp)
  80048c:	eb 17                	jmp    8004a5 <vprintfmt+0x277>
		return va_arg(*ap, long long);
  80048e:	8b 45 14             	mov    0x14(%ebp),%eax
  800491:	8b 50 04             	mov    0x4(%eax),%edx
  800494:	8b 00                	mov    (%eax),%eax
  800496:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800499:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80049c:	8b 45 14             	mov    0x14(%ebp),%eax
  80049f:	8d 40 08             	lea    0x8(%eax),%eax
  8004a2:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  8004a5:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8004a8:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8004ab:	85 c9                	test   %ecx,%ecx
  8004ad:	78 21                	js     8004d0 <vprintfmt+0x2a2>
			base = 10;
  8004af:	b8 0a 00 00 00       	mov    $0xa,%eax
  8004b4:	e9 ca 00 00 00       	jmp    800583 <vprintfmt+0x355>
		return va_arg(*ap, int);
  8004b9:	8b 45 14             	mov    0x14(%ebp),%eax
  8004bc:	8b 00                	mov    (%eax),%eax
  8004be:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004c1:	99                   	cltd   
  8004c2:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8004c5:	8b 45 14             	mov    0x14(%ebp),%eax
  8004c8:	8d 40 04             	lea    0x4(%eax),%eax
  8004cb:	89 45 14             	mov    %eax,0x14(%ebp)
  8004ce:	eb d5                	jmp    8004a5 <vprintfmt+0x277>
				putch('-', putdat);
  8004d0:	83 ec 08             	sub    $0x8,%esp
  8004d3:	53                   	push   %ebx
  8004d4:	6a 2d                	push   $0x2d
  8004d6:	ff d6                	call   *%esi
				num = -(long long) num;
  8004d8:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8004db:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8004de:	f7 da                	neg    %edx
  8004e0:	83 d1 00             	adc    $0x0,%ecx
  8004e3:	f7 d9                	neg    %ecx
  8004e5:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8004e8:	b8 0a 00 00 00       	mov    $0xa,%eax
  8004ed:	e9 91 00 00 00       	jmp    800583 <vprintfmt+0x355>
	if (lflag >= 2)
  8004f2:	83 f9 01             	cmp    $0x1,%ecx
  8004f5:	7f 1b                	jg     800512 <vprintfmt+0x2e4>
	else if (lflag)
  8004f7:	85 c9                	test   %ecx,%ecx
  8004f9:	74 2c                	je     800527 <vprintfmt+0x2f9>
		return va_arg(*ap, unsigned long);
  8004fb:	8b 45 14             	mov    0x14(%ebp),%eax
  8004fe:	8b 10                	mov    (%eax),%edx
  800500:	b9 00 00 00 00       	mov    $0x0,%ecx
  800505:	8d 40 04             	lea    0x4(%eax),%eax
  800508:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80050b:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  800510:	eb 71                	jmp    800583 <vprintfmt+0x355>
		return va_arg(*ap, unsigned long long);
  800512:	8b 45 14             	mov    0x14(%ebp),%eax
  800515:	8b 10                	mov    (%eax),%edx
  800517:	8b 48 04             	mov    0x4(%eax),%ecx
  80051a:	8d 40 08             	lea    0x8(%eax),%eax
  80051d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800520:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  800525:	eb 5c                	jmp    800583 <vprintfmt+0x355>
		return va_arg(*ap, unsigned int);
  800527:	8b 45 14             	mov    0x14(%ebp),%eax
  80052a:	8b 10                	mov    (%eax),%edx
  80052c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800531:	8d 40 04             	lea    0x4(%eax),%eax
  800534:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800537:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  80053c:	eb 45                	jmp    800583 <vprintfmt+0x355>
			putch('X', putdat);
  80053e:	83 ec 08             	sub    $0x8,%esp
  800541:	53                   	push   %ebx
  800542:	6a 58                	push   $0x58
  800544:	ff d6                	call   *%esi
			putch('X', putdat);
  800546:	83 c4 08             	add    $0x8,%esp
  800549:	53                   	push   %ebx
  80054a:	6a 58                	push   $0x58
  80054c:	ff d6                	call   *%esi
			putch('X', putdat);
  80054e:	83 c4 08             	add    $0x8,%esp
  800551:	53                   	push   %ebx
  800552:	6a 58                	push   $0x58
  800554:	ff d6                	call   *%esi
			break;
  800556:	83 c4 10             	add    $0x10,%esp
  800559:	eb 42                	jmp    80059d <vprintfmt+0x36f>
			putch('0', putdat);
  80055b:	83 ec 08             	sub    $0x8,%esp
  80055e:	53                   	push   %ebx
  80055f:	6a 30                	push   $0x30
  800561:	ff d6                	call   *%esi
			putch('x', putdat);
  800563:	83 c4 08             	add    $0x8,%esp
  800566:	53                   	push   %ebx
  800567:	6a 78                	push   $0x78
  800569:	ff d6                	call   *%esi
			num = (unsigned long long)
  80056b:	8b 45 14             	mov    0x14(%ebp),%eax
  80056e:	8b 10                	mov    (%eax),%edx
  800570:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800575:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800578:	8d 40 04             	lea    0x4(%eax),%eax
  80057b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80057e:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  800583:	83 ec 0c             	sub    $0xc,%esp
  800586:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  80058a:	57                   	push   %edi
  80058b:	ff 75 d4             	pushl  -0x2c(%ebp)
  80058e:	50                   	push   %eax
  80058f:	51                   	push   %ecx
  800590:	52                   	push   %edx
  800591:	89 da                	mov    %ebx,%edx
  800593:	89 f0                	mov    %esi,%eax
  800595:	e8 b6 fb ff ff       	call   800150 <printnum>
			break;
  80059a:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  80059d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8005a0:	47                   	inc    %edi
  8005a1:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8005a5:	83 f8 25             	cmp    $0x25,%eax
  8005a8:	0f 84 97 fc ff ff    	je     800245 <vprintfmt+0x17>
			if (ch == '\0')
  8005ae:	85 c0                	test   %eax,%eax
  8005b0:	0f 84 89 00 00 00    	je     80063f <vprintfmt+0x411>
			putch(ch, putdat);
  8005b6:	83 ec 08             	sub    $0x8,%esp
  8005b9:	53                   	push   %ebx
  8005ba:	50                   	push   %eax
  8005bb:	ff d6                	call   *%esi
  8005bd:	83 c4 10             	add    $0x10,%esp
  8005c0:	eb de                	jmp    8005a0 <vprintfmt+0x372>
	if (lflag >= 2)
  8005c2:	83 f9 01             	cmp    $0x1,%ecx
  8005c5:	7f 1b                	jg     8005e2 <vprintfmt+0x3b4>
	else if (lflag)
  8005c7:	85 c9                	test   %ecx,%ecx
  8005c9:	74 2c                	je     8005f7 <vprintfmt+0x3c9>
		return va_arg(*ap, unsigned long);
  8005cb:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ce:	8b 10                	mov    (%eax),%edx
  8005d0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005d5:	8d 40 04             	lea    0x4(%eax),%eax
  8005d8:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8005db:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  8005e0:	eb a1                	jmp    800583 <vprintfmt+0x355>
		return va_arg(*ap, unsigned long long);
  8005e2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e5:	8b 10                	mov    (%eax),%edx
  8005e7:	8b 48 04             	mov    0x4(%eax),%ecx
  8005ea:	8d 40 08             	lea    0x8(%eax),%eax
  8005ed:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8005f0:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  8005f5:	eb 8c                	jmp    800583 <vprintfmt+0x355>
		return va_arg(*ap, unsigned int);
  8005f7:	8b 45 14             	mov    0x14(%ebp),%eax
  8005fa:	8b 10                	mov    (%eax),%edx
  8005fc:	b9 00 00 00 00       	mov    $0x0,%ecx
  800601:	8d 40 04             	lea    0x4(%eax),%eax
  800604:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800607:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  80060c:	e9 72 ff ff ff       	jmp    800583 <vprintfmt+0x355>
			putch(ch, putdat);
  800611:	83 ec 08             	sub    $0x8,%esp
  800614:	53                   	push   %ebx
  800615:	6a 25                	push   $0x25
  800617:	ff d6                	call   *%esi
			break;
  800619:	83 c4 10             	add    $0x10,%esp
  80061c:	e9 7c ff ff ff       	jmp    80059d <vprintfmt+0x36f>
			putch('%', putdat);
  800621:	83 ec 08             	sub    $0x8,%esp
  800624:	53                   	push   %ebx
  800625:	6a 25                	push   $0x25
  800627:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800629:	83 c4 10             	add    $0x10,%esp
  80062c:	89 f8                	mov    %edi,%eax
  80062e:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800632:	74 03                	je     800637 <vprintfmt+0x409>
  800634:	48                   	dec    %eax
  800635:	eb f7                	jmp    80062e <vprintfmt+0x400>
  800637:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80063a:	e9 5e ff ff ff       	jmp    80059d <vprintfmt+0x36f>
}
  80063f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800642:	5b                   	pop    %ebx
  800643:	5e                   	pop    %esi
  800644:	5f                   	pop    %edi
  800645:	5d                   	pop    %ebp
  800646:	c3                   	ret    

00800647 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800647:	55                   	push   %ebp
  800648:	89 e5                	mov    %esp,%ebp
  80064a:	83 ec 18             	sub    $0x18,%esp
  80064d:	8b 45 08             	mov    0x8(%ebp),%eax
  800650:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800653:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800656:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80065a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80065d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800664:	85 c0                	test   %eax,%eax
  800666:	74 26                	je     80068e <vsnprintf+0x47>
  800668:	85 d2                	test   %edx,%edx
  80066a:	7e 29                	jle    800695 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80066c:	ff 75 14             	pushl  0x14(%ebp)
  80066f:	ff 75 10             	pushl  0x10(%ebp)
  800672:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800675:	50                   	push   %eax
  800676:	68 f5 01 80 00       	push   $0x8001f5
  80067b:	e8 ae fb ff ff       	call   80022e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800680:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800683:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800686:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800689:	83 c4 10             	add    $0x10,%esp
}
  80068c:	c9                   	leave  
  80068d:	c3                   	ret    
		return -E_INVAL;
  80068e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800693:	eb f7                	jmp    80068c <vsnprintf+0x45>
  800695:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80069a:	eb f0                	jmp    80068c <vsnprintf+0x45>

0080069c <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80069c:	55                   	push   %ebp
  80069d:	89 e5                	mov    %esp,%ebp
  80069f:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006a2:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006a5:	50                   	push   %eax
  8006a6:	ff 75 10             	pushl  0x10(%ebp)
  8006a9:	ff 75 0c             	pushl  0xc(%ebp)
  8006ac:	ff 75 08             	pushl  0x8(%ebp)
  8006af:	e8 93 ff ff ff       	call   800647 <vsnprintf>
	va_end(ap);

	return rc;
}
  8006b4:	c9                   	leave  
  8006b5:	c3                   	ret    

008006b6 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006b6:	55                   	push   %ebp
  8006b7:	89 e5                	mov    %esp,%ebp
  8006b9:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006bc:	b8 00 00 00 00       	mov    $0x0,%eax
  8006c1:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8006c5:	74 03                	je     8006ca <strlen+0x14>
		n++;
  8006c7:	40                   	inc    %eax
  8006c8:	eb f7                	jmp    8006c1 <strlen+0xb>
	return n;
}
  8006ca:	5d                   	pop    %ebp
  8006cb:	c3                   	ret    

008006cc <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8006cc:	55                   	push   %ebp
  8006cd:	89 e5                	mov    %esp,%ebp
  8006cf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006d2:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006d5:	b8 00 00 00 00       	mov    $0x0,%eax
  8006da:	39 d0                	cmp    %edx,%eax
  8006dc:	74 0b                	je     8006e9 <strnlen+0x1d>
  8006de:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8006e2:	74 03                	je     8006e7 <strnlen+0x1b>
		n++;
  8006e4:	40                   	inc    %eax
  8006e5:	eb f3                	jmp    8006da <strnlen+0xe>
  8006e7:	89 c2                	mov    %eax,%edx
	return n;
}
  8006e9:	89 d0                	mov    %edx,%eax
  8006eb:	5d                   	pop    %ebp
  8006ec:	c3                   	ret    

008006ed <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8006ed:	55                   	push   %ebp
  8006ee:	89 e5                	mov    %esp,%ebp
  8006f0:	53                   	push   %ebx
  8006f1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006f4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8006f7:	b8 00 00 00 00       	mov    $0x0,%eax
  8006fc:	8a 14 03             	mov    (%ebx,%eax,1),%dl
  8006ff:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800702:	40                   	inc    %eax
  800703:	84 d2                	test   %dl,%dl
  800705:	75 f5                	jne    8006fc <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800707:	89 c8                	mov    %ecx,%eax
  800709:	5b                   	pop    %ebx
  80070a:	5d                   	pop    %ebp
  80070b:	c3                   	ret    

0080070c <strcat>:

char *
strcat(char *dst, const char *src)
{
  80070c:	55                   	push   %ebp
  80070d:	89 e5                	mov    %esp,%ebp
  80070f:	53                   	push   %ebx
  800710:	83 ec 10             	sub    $0x10,%esp
  800713:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800716:	53                   	push   %ebx
  800717:	e8 9a ff ff ff       	call   8006b6 <strlen>
  80071c:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  80071f:	ff 75 0c             	pushl  0xc(%ebp)
  800722:	01 d8                	add    %ebx,%eax
  800724:	50                   	push   %eax
  800725:	e8 c3 ff ff ff       	call   8006ed <strcpy>
	return dst;
}
  80072a:	89 d8                	mov    %ebx,%eax
  80072c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80072f:	c9                   	leave  
  800730:	c3                   	ret    

00800731 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800731:	55                   	push   %ebp
  800732:	89 e5                	mov    %esp,%ebp
  800734:	53                   	push   %ebx
  800735:	8b 55 0c             	mov    0xc(%ebp),%edx
  800738:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80073b:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80073e:	8b 45 08             	mov    0x8(%ebp),%eax
  800741:	39 d8                	cmp    %ebx,%eax
  800743:	74 0e                	je     800753 <strncpy+0x22>
		*dst++ = *src;
  800745:	40                   	inc    %eax
  800746:	8a 0a                	mov    (%edx),%cl
  800748:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80074b:	80 f9 01             	cmp    $0x1,%cl
  80074e:	83 da ff             	sbb    $0xffffffff,%edx
  800751:	eb ee                	jmp    800741 <strncpy+0x10>
	}
	return ret;
}
  800753:	8b 45 08             	mov    0x8(%ebp),%eax
  800756:	5b                   	pop    %ebx
  800757:	5d                   	pop    %ebp
  800758:	c3                   	ret    

00800759 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800759:	55                   	push   %ebp
  80075a:	89 e5                	mov    %esp,%ebp
  80075c:	56                   	push   %esi
  80075d:	53                   	push   %ebx
  80075e:	8b 75 08             	mov    0x8(%ebp),%esi
  800761:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800764:	8b 45 10             	mov    0x10(%ebp),%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800767:	85 c0                	test   %eax,%eax
  800769:	74 22                	je     80078d <strlcpy+0x34>
  80076b:	8d 44 06 ff          	lea    -0x1(%esi,%eax,1),%eax
  80076f:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  800771:	39 c2                	cmp    %eax,%edx
  800773:	74 0f                	je     800784 <strlcpy+0x2b>
  800775:	8a 19                	mov    (%ecx),%bl
  800777:	84 db                	test   %bl,%bl
  800779:	74 07                	je     800782 <strlcpy+0x29>
			*dst++ = *src++;
  80077b:	41                   	inc    %ecx
  80077c:	42                   	inc    %edx
  80077d:	88 5a ff             	mov    %bl,-0x1(%edx)
  800780:	eb ef                	jmp    800771 <strlcpy+0x18>
  800782:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800784:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800787:	29 f0                	sub    %esi,%eax
}
  800789:	5b                   	pop    %ebx
  80078a:	5e                   	pop    %esi
  80078b:	5d                   	pop    %ebp
  80078c:	c3                   	ret    
  80078d:	89 f0                	mov    %esi,%eax
  80078f:	eb f6                	jmp    800787 <strlcpy+0x2e>

00800791 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800791:	55                   	push   %ebp
  800792:	89 e5                	mov    %esp,%ebp
  800794:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800797:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80079a:	8a 01                	mov    (%ecx),%al
  80079c:	84 c0                	test   %al,%al
  80079e:	74 08                	je     8007a8 <strcmp+0x17>
  8007a0:	3a 02                	cmp    (%edx),%al
  8007a2:	75 04                	jne    8007a8 <strcmp+0x17>
		p++, q++;
  8007a4:	41                   	inc    %ecx
  8007a5:	42                   	inc    %edx
  8007a6:	eb f2                	jmp    80079a <strcmp+0x9>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007a8:	0f b6 c0             	movzbl %al,%eax
  8007ab:	0f b6 12             	movzbl (%edx),%edx
  8007ae:	29 d0                	sub    %edx,%eax
}
  8007b0:	5d                   	pop    %ebp
  8007b1:	c3                   	ret    

008007b2 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8007b2:	55                   	push   %ebp
  8007b3:	89 e5                	mov    %esp,%ebp
  8007b5:	53                   	push   %ebx
  8007b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8007b9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007bc:	89 c3                	mov    %eax,%ebx
  8007be:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8007c1:	eb 02                	jmp    8007c5 <strncmp+0x13>
		n--, p++, q++;
  8007c3:	40                   	inc    %eax
  8007c4:	42                   	inc    %edx
	while (n > 0 && *p && *p == *q)
  8007c5:	39 d8                	cmp    %ebx,%eax
  8007c7:	74 15                	je     8007de <strncmp+0x2c>
  8007c9:	8a 08                	mov    (%eax),%cl
  8007cb:	84 c9                	test   %cl,%cl
  8007cd:	74 04                	je     8007d3 <strncmp+0x21>
  8007cf:	3a 0a                	cmp    (%edx),%cl
  8007d1:	74 f0                	je     8007c3 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8007d3:	0f b6 00             	movzbl (%eax),%eax
  8007d6:	0f b6 12             	movzbl (%edx),%edx
  8007d9:	29 d0                	sub    %edx,%eax
}
  8007db:	5b                   	pop    %ebx
  8007dc:	5d                   	pop    %ebp
  8007dd:	c3                   	ret    
		return 0;
  8007de:	b8 00 00 00 00       	mov    $0x0,%eax
  8007e3:	eb f6                	jmp    8007db <strncmp+0x29>

008007e5 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8007e5:	55                   	push   %ebp
  8007e6:	89 e5                	mov    %esp,%ebp
  8007e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8007eb:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8007ee:	8a 10                	mov    (%eax),%dl
  8007f0:	84 d2                	test   %dl,%dl
  8007f2:	74 07                	je     8007fb <strchr+0x16>
		if (*s == c)
  8007f4:	38 ca                	cmp    %cl,%dl
  8007f6:	74 08                	je     800800 <strchr+0x1b>
	for (; *s; s++)
  8007f8:	40                   	inc    %eax
  8007f9:	eb f3                	jmp    8007ee <strchr+0x9>
			return (char *) s;
	return 0;
  8007fb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800800:	5d                   	pop    %ebp
  800801:	c3                   	ret    

00800802 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800802:	55                   	push   %ebp
  800803:	89 e5                	mov    %esp,%ebp
  800805:	8b 45 08             	mov    0x8(%ebp),%eax
  800808:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80080b:	8a 10                	mov    (%eax),%dl
  80080d:	84 d2                	test   %dl,%dl
  80080f:	74 07                	je     800818 <strfind+0x16>
		if (*s == c)
  800811:	38 ca                	cmp    %cl,%dl
  800813:	74 03                	je     800818 <strfind+0x16>
	for (; *s; s++)
  800815:	40                   	inc    %eax
  800816:	eb f3                	jmp    80080b <strfind+0x9>
			break;
	return (char *) s;
}
  800818:	5d                   	pop    %ebp
  800819:	c3                   	ret    

0080081a <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80081a:	55                   	push   %ebp
  80081b:	89 e5                	mov    %esp,%ebp
  80081d:	57                   	push   %edi
  80081e:	56                   	push   %esi
  80081f:	53                   	push   %ebx
  800820:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800823:	85 c9                	test   %ecx,%ecx
  800825:	74 36                	je     80085d <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800827:	89 c8                	mov    %ecx,%eax
  800829:	0b 45 08             	or     0x8(%ebp),%eax
  80082c:	a8 03                	test   $0x3,%al
  80082e:	75 24                	jne    800854 <memset+0x3a>
		c &= 0xFF;
  800830:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800834:	89 d3                	mov    %edx,%ebx
  800836:	c1 e3 08             	shl    $0x8,%ebx
  800839:	89 d0                	mov    %edx,%eax
  80083b:	c1 e0 18             	shl    $0x18,%eax
  80083e:	89 d6                	mov    %edx,%esi
  800840:	c1 e6 10             	shl    $0x10,%esi
  800843:	09 f0                	or     %esi,%eax
  800845:	09 d0                	or     %edx,%eax
  800847:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800849:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  80084c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80084f:	fc                   	cld    
  800850:	f3 ab                	rep stos %eax,%es:(%edi)
  800852:	eb 09                	jmp    80085d <memset+0x43>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800854:	8b 7d 08             	mov    0x8(%ebp),%edi
  800857:	8b 45 0c             	mov    0xc(%ebp),%eax
  80085a:	fc                   	cld    
  80085b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80085d:	8b 45 08             	mov    0x8(%ebp),%eax
  800860:	5b                   	pop    %ebx
  800861:	5e                   	pop    %esi
  800862:	5f                   	pop    %edi
  800863:	5d                   	pop    %ebp
  800864:	c3                   	ret    

00800865 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800865:	55                   	push   %ebp
  800866:	89 e5                	mov    %esp,%ebp
  800868:	57                   	push   %edi
  800869:	56                   	push   %esi
  80086a:	8b 45 08             	mov    0x8(%ebp),%eax
  80086d:	8b 75 0c             	mov    0xc(%ebp),%esi
  800870:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800873:	39 c6                	cmp    %eax,%esi
  800875:	73 30                	jae    8008a7 <memmove+0x42>
  800877:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80087a:	39 c2                	cmp    %eax,%edx
  80087c:	76 29                	jbe    8008a7 <memmove+0x42>
		s += n;
		d += n;
  80087e:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800881:	89 fe                	mov    %edi,%esi
  800883:	09 ce                	or     %ecx,%esi
  800885:	09 d6                	or     %edx,%esi
  800887:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80088d:	75 0e                	jne    80089d <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  80088f:	83 ef 04             	sub    $0x4,%edi
  800892:	8d 72 fc             	lea    -0x4(%edx),%esi
  800895:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800898:	fd                   	std    
  800899:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80089b:	eb 07                	jmp    8008a4 <memmove+0x3f>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80089d:	4f                   	dec    %edi
  80089e:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  8008a1:	fd                   	std    
  8008a2:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8008a4:	fc                   	cld    
  8008a5:	eb 1a                	jmp    8008c1 <memmove+0x5c>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008a7:	89 c2                	mov    %eax,%edx
  8008a9:	09 ca                	or     %ecx,%edx
  8008ab:	09 f2                	or     %esi,%edx
  8008ad:	f6 c2 03             	test   $0x3,%dl
  8008b0:	75 0a                	jne    8008bc <memmove+0x57>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8008b2:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  8008b5:	89 c7                	mov    %eax,%edi
  8008b7:	fc                   	cld    
  8008b8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008ba:	eb 05                	jmp    8008c1 <memmove+0x5c>
		else
			asm volatile("cld; rep movsb\n"
  8008bc:	89 c7                	mov    %eax,%edi
  8008be:	fc                   	cld    
  8008bf:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8008c1:	5e                   	pop    %esi
  8008c2:	5f                   	pop    %edi
  8008c3:	5d                   	pop    %ebp
  8008c4:	c3                   	ret    

008008c5 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8008c5:	55                   	push   %ebp
  8008c6:	89 e5                	mov    %esp,%ebp
  8008c8:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8008cb:	ff 75 10             	pushl  0x10(%ebp)
  8008ce:	ff 75 0c             	pushl  0xc(%ebp)
  8008d1:	ff 75 08             	pushl  0x8(%ebp)
  8008d4:	e8 8c ff ff ff       	call   800865 <memmove>
}
  8008d9:	c9                   	leave  
  8008da:	c3                   	ret    

008008db <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8008db:	55                   	push   %ebp
  8008dc:	89 e5                	mov    %esp,%ebp
  8008de:	56                   	push   %esi
  8008df:	53                   	push   %ebx
  8008e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008e6:	89 c6                	mov    %eax,%esi
  8008e8:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8008eb:	39 f0                	cmp    %esi,%eax
  8008ed:	74 16                	je     800905 <memcmp+0x2a>
		if (*s1 != *s2)
  8008ef:	8a 08                	mov    (%eax),%cl
  8008f1:	8a 1a                	mov    (%edx),%bl
  8008f3:	38 d9                	cmp    %bl,%cl
  8008f5:	75 04                	jne    8008fb <memcmp+0x20>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  8008f7:	40                   	inc    %eax
  8008f8:	42                   	inc    %edx
  8008f9:	eb f0                	jmp    8008eb <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  8008fb:	0f b6 c1             	movzbl %cl,%eax
  8008fe:	0f b6 db             	movzbl %bl,%ebx
  800901:	29 d8                	sub    %ebx,%eax
  800903:	eb 05                	jmp    80090a <memcmp+0x2f>
	}

	return 0;
  800905:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80090a:	5b                   	pop    %ebx
  80090b:	5e                   	pop    %esi
  80090c:	5d                   	pop    %ebp
  80090d:	c3                   	ret    

0080090e <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80090e:	55                   	push   %ebp
  80090f:	89 e5                	mov    %esp,%ebp
  800911:	8b 45 08             	mov    0x8(%ebp),%eax
  800914:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800917:	89 c2                	mov    %eax,%edx
  800919:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  80091c:	39 d0                	cmp    %edx,%eax
  80091e:	73 07                	jae    800927 <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
  800920:	38 08                	cmp    %cl,(%eax)
  800922:	74 03                	je     800927 <memfind+0x19>
	for (; s < ends; s++)
  800924:	40                   	inc    %eax
  800925:	eb f5                	jmp    80091c <memfind+0xe>
			break;
	return (void *) s;
}
  800927:	5d                   	pop    %ebp
  800928:	c3                   	ret    

00800929 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800929:	55                   	push   %ebp
  80092a:	89 e5                	mov    %esp,%ebp
  80092c:	57                   	push   %edi
  80092d:	56                   	push   %esi
  80092e:	53                   	push   %ebx
  80092f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800932:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800935:	eb 01                	jmp    800938 <strtol+0xf>
		s++;
  800937:	41                   	inc    %ecx
	while (*s == ' ' || *s == '\t')
  800938:	8a 01                	mov    (%ecx),%al
  80093a:	3c 20                	cmp    $0x20,%al
  80093c:	74 f9                	je     800937 <strtol+0xe>
  80093e:	3c 09                	cmp    $0x9,%al
  800940:	74 f5                	je     800937 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800942:	3c 2b                	cmp    $0x2b,%al
  800944:	74 24                	je     80096a <strtol+0x41>
		s++;
	else if (*s == '-')
  800946:	3c 2d                	cmp    $0x2d,%al
  800948:	74 28                	je     800972 <strtol+0x49>
	int neg = 0;
  80094a:	bf 00 00 00 00       	mov    $0x0,%edi
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80094f:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800955:	75 09                	jne    800960 <strtol+0x37>
  800957:	80 39 30             	cmpb   $0x30,(%ecx)
  80095a:	74 1e                	je     80097a <strtol+0x51>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  80095c:	85 db                	test   %ebx,%ebx
  80095e:	74 36                	je     800996 <strtol+0x6d>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800960:	b8 00 00 00 00       	mov    $0x0,%eax
  800965:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800968:	eb 45                	jmp    8009af <strtol+0x86>
		s++;
  80096a:	41                   	inc    %ecx
	int neg = 0;
  80096b:	bf 00 00 00 00       	mov    $0x0,%edi
  800970:	eb dd                	jmp    80094f <strtol+0x26>
		s++, neg = 1;
  800972:	41                   	inc    %ecx
  800973:	bf 01 00 00 00       	mov    $0x1,%edi
  800978:	eb d5                	jmp    80094f <strtol+0x26>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80097a:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  80097e:	74 0c                	je     80098c <strtol+0x63>
	else if (base == 0 && s[0] == '0')
  800980:	85 db                	test   %ebx,%ebx
  800982:	75 dc                	jne    800960 <strtol+0x37>
		s++, base = 8;
  800984:	41                   	inc    %ecx
  800985:	bb 08 00 00 00       	mov    $0x8,%ebx
  80098a:	eb d4                	jmp    800960 <strtol+0x37>
		s += 2, base = 16;
  80098c:	83 c1 02             	add    $0x2,%ecx
  80098f:	bb 10 00 00 00       	mov    $0x10,%ebx
  800994:	eb ca                	jmp    800960 <strtol+0x37>
		base = 10;
  800996:	bb 0a 00 00 00       	mov    $0xa,%ebx
  80099b:	eb c3                	jmp    800960 <strtol+0x37>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  80099d:	0f be d2             	movsbl %dl,%edx
  8009a0:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  8009a3:	3b 55 10             	cmp    0x10(%ebp),%edx
  8009a6:	7d 37                	jge    8009df <strtol+0xb6>
			break;
		s++, val = (val * base) + dig;
  8009a8:	41                   	inc    %ecx
  8009a9:	0f af 45 10          	imul   0x10(%ebp),%eax
  8009ad:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  8009af:	8a 11                	mov    (%ecx),%dl
  8009b1:	8d 72 d0             	lea    -0x30(%edx),%esi
  8009b4:	89 f3                	mov    %esi,%ebx
  8009b6:	80 fb 09             	cmp    $0x9,%bl
  8009b9:	76 e2                	jbe    80099d <strtol+0x74>
		else if (*s >= 'a' && *s <= 'z')
  8009bb:	8d 72 9f             	lea    -0x61(%edx),%esi
  8009be:	89 f3                	mov    %esi,%ebx
  8009c0:	80 fb 19             	cmp    $0x19,%bl
  8009c3:	77 08                	ja     8009cd <strtol+0xa4>
			dig = *s - 'a' + 10;
  8009c5:	0f be d2             	movsbl %dl,%edx
  8009c8:	83 ea 57             	sub    $0x57,%edx
  8009cb:	eb d6                	jmp    8009a3 <strtol+0x7a>
		else if (*s >= 'A' && *s <= 'Z')
  8009cd:	8d 72 bf             	lea    -0x41(%edx),%esi
  8009d0:	89 f3                	mov    %esi,%ebx
  8009d2:	80 fb 19             	cmp    $0x19,%bl
  8009d5:	77 08                	ja     8009df <strtol+0xb6>
			dig = *s - 'A' + 10;
  8009d7:	0f be d2             	movsbl %dl,%edx
  8009da:	83 ea 37             	sub    $0x37,%edx
  8009dd:	eb c4                	jmp    8009a3 <strtol+0x7a>
		// we don't properly detect overflow!
	}

	if (endptr)
  8009df:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8009e3:	74 05                	je     8009ea <strtol+0xc1>
		*endptr = (char *) s;
  8009e5:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009e8:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  8009ea:	85 ff                	test   %edi,%edi
  8009ec:	74 02                	je     8009f0 <strtol+0xc7>
  8009ee:	f7 d8                	neg    %eax
}
  8009f0:	5b                   	pop    %ebx
  8009f1:	5e                   	pop    %esi
  8009f2:	5f                   	pop    %edi
  8009f3:	5d                   	pop    %ebp
  8009f4:	c3                   	ret    

008009f5 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8009f5:	55                   	push   %ebp
  8009f6:	89 e5                	mov    %esp,%ebp
  8009f8:	57                   	push   %edi
  8009f9:	56                   	push   %esi
  8009fa:	53                   	push   %ebx
	asm volatile("int %1\n"
  8009fb:	b8 00 00 00 00       	mov    $0x0,%eax
  800a00:	8b 55 08             	mov    0x8(%ebp),%edx
  800a03:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a06:	89 c3                	mov    %eax,%ebx
  800a08:	89 c7                	mov    %eax,%edi
  800a0a:	89 c6                	mov    %eax,%esi
  800a0c:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a0e:	5b                   	pop    %ebx
  800a0f:	5e                   	pop    %esi
  800a10:	5f                   	pop    %edi
  800a11:	5d                   	pop    %ebp
  800a12:	c3                   	ret    

00800a13 <sys_cgetc>:

int
sys_cgetc(void)
{
  800a13:	55                   	push   %ebp
  800a14:	89 e5                	mov    %esp,%ebp
  800a16:	57                   	push   %edi
  800a17:	56                   	push   %esi
  800a18:	53                   	push   %ebx
	asm volatile("int %1\n"
  800a19:	ba 00 00 00 00       	mov    $0x0,%edx
  800a1e:	b8 01 00 00 00       	mov    $0x1,%eax
  800a23:	89 d1                	mov    %edx,%ecx
  800a25:	89 d3                	mov    %edx,%ebx
  800a27:	89 d7                	mov    %edx,%edi
  800a29:	89 d6                	mov    %edx,%esi
  800a2b:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800a2d:	5b                   	pop    %ebx
  800a2e:	5e                   	pop    %esi
  800a2f:	5f                   	pop    %edi
  800a30:	5d                   	pop    %ebp
  800a31:	c3                   	ret    

00800a32 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800a32:	55                   	push   %ebp
  800a33:	89 e5                	mov    %esp,%ebp
  800a35:	57                   	push   %edi
  800a36:	56                   	push   %esi
  800a37:	53                   	push   %ebx
  800a38:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800a3b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a40:	8b 55 08             	mov    0x8(%ebp),%edx
  800a43:	b8 03 00 00 00       	mov    $0x3,%eax
  800a48:	89 cb                	mov    %ecx,%ebx
  800a4a:	89 cf                	mov    %ecx,%edi
  800a4c:	89 ce                	mov    %ecx,%esi
  800a4e:	cd 30                	int    $0x30
	if(check && ret > 0)
  800a50:	85 c0                	test   %eax,%eax
  800a52:	7f 08                	jg     800a5c <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800a54:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a57:	5b                   	pop    %ebx
  800a58:	5e                   	pop    %esi
  800a59:	5f                   	pop    %edi
  800a5a:	5d                   	pop    %ebp
  800a5b:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800a5c:	83 ec 0c             	sub    $0xc,%esp
  800a5f:	50                   	push   %eax
  800a60:	6a 03                	push   $0x3
  800a62:	68 1c 0f 80 00       	push   $0x800f1c
  800a67:	6a 23                	push   $0x23
  800a69:	68 39 0f 80 00       	push   $0x800f39
  800a6e:	e8 1f 00 00 00       	call   800a92 <_panic>

00800a73 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800a73:	55                   	push   %ebp
  800a74:	89 e5                	mov    %esp,%ebp
  800a76:	57                   	push   %edi
  800a77:	56                   	push   %esi
  800a78:	53                   	push   %ebx
	asm volatile("int %1\n"
  800a79:	ba 00 00 00 00       	mov    $0x0,%edx
  800a7e:	b8 02 00 00 00       	mov    $0x2,%eax
  800a83:	89 d1                	mov    %edx,%ecx
  800a85:	89 d3                	mov    %edx,%ebx
  800a87:	89 d7                	mov    %edx,%edi
  800a89:	89 d6                	mov    %edx,%esi
  800a8b:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800a8d:	5b                   	pop    %ebx
  800a8e:	5e                   	pop    %esi
  800a8f:	5f                   	pop    %edi
  800a90:	5d                   	pop    %ebp
  800a91:	c3                   	ret    

00800a92 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800a92:	55                   	push   %ebp
  800a93:	89 e5                	mov    %esp,%ebp
  800a95:	56                   	push   %esi
  800a96:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800a97:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800a9a:	8b 35 00 10 80 00    	mov    0x801000,%esi
  800aa0:	e8 ce ff ff ff       	call   800a73 <sys_getenvid>
  800aa5:	83 ec 0c             	sub    $0xc,%esp
  800aa8:	ff 75 0c             	pushl  0xc(%ebp)
  800aab:	ff 75 08             	pushl  0x8(%ebp)
  800aae:	56                   	push   %esi
  800aaf:	50                   	push   %eax
  800ab0:	68 48 0f 80 00       	push   $0x800f48
  800ab5:	e8 82 f6 ff ff       	call   80013c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800aba:	83 c4 18             	add    $0x18,%esp
  800abd:	53                   	push   %ebx
  800abe:	ff 75 10             	pushl  0x10(%ebp)
  800ac1:	e8 25 f6 ff ff       	call   8000eb <vcprintf>
	cprintf("\n");
  800ac6:	c7 04 24 0c 0d 80 00 	movl   $0x800d0c,(%esp)
  800acd:	e8 6a f6 ff ff       	call   80013c <cprintf>
  800ad2:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800ad5:	cc                   	int3   
  800ad6:	eb fd                	jmp    800ad5 <_panic+0x43>

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
