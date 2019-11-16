
obj/user/breakpoint:     file format elf32-i386


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
  80002c:	e8 04 00 00 00       	call   800035 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
	asm volatile("int $3");
  800033:	cc                   	int3   
}
  800034:	c3                   	ret    

00800035 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800035:	55                   	push   %ebp
  800036:	89 e5                	mov    %esp,%ebp
  800038:	83 ec 08             	sub    $0x8,%esp
  80003b:	8b 45 08             	mov    0x8(%ebp),%eax
  80003e:	8b 55 0c             	mov    0xc(%ebp),%edx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  800041:	c7 05 04 10 80 00 00 	movl   $0x0,0x801004
  800048:	00 00 00 

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80004b:	85 c0                	test   %eax,%eax
  80004d:	7e 08                	jle    800057 <libmain+0x22>
		binaryname = argv[0];
  80004f:	8b 0a                	mov    (%edx),%ecx
  800051:	89 0d 00 10 80 00    	mov    %ecx,0x801000

	// call user main routine
	umain(argc, argv);
  800057:	83 ec 08             	sub    $0x8,%esp
  80005a:	52                   	push   %edx
  80005b:	50                   	push   %eax
  80005c:	e8 d2 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800061:	e8 05 00 00 00       	call   80006b <exit>
}
  800066:	83 c4 10             	add    $0x10,%esp
  800069:	c9                   	leave  
  80006a:	c3                   	ret    

0080006b <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80006b:	55                   	push   %ebp
  80006c:	89 e5                	mov    %esp,%ebp
  80006e:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800071:	6a 00                	push   $0x0
  800073:	e8 42 00 00 00       	call   8000ba <sys_env_destroy>
}
  800078:	83 c4 10             	add    $0x10,%esp
  80007b:	c9                   	leave  
  80007c:	c3                   	ret    

0080007d <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  80007d:	55                   	push   %ebp
  80007e:	89 e5                	mov    %esp,%ebp
  800080:	57                   	push   %edi
  800081:	56                   	push   %esi
  800082:	53                   	push   %ebx
	asm volatile("int %1\n"
  800083:	b8 00 00 00 00       	mov    $0x0,%eax
  800088:	8b 55 08             	mov    0x8(%ebp),%edx
  80008b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80008e:	89 c3                	mov    %eax,%ebx
  800090:	89 c7                	mov    %eax,%edi
  800092:	89 c6                	mov    %eax,%esi
  800094:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800096:	5b                   	pop    %ebx
  800097:	5e                   	pop    %esi
  800098:	5f                   	pop    %edi
  800099:	5d                   	pop    %ebp
  80009a:	c3                   	ret    

0080009b <sys_cgetc>:

int
sys_cgetc(void)
{
  80009b:	55                   	push   %ebp
  80009c:	89 e5                	mov    %esp,%ebp
  80009e:	57                   	push   %edi
  80009f:	56                   	push   %esi
  8000a0:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000a1:	ba 00 00 00 00       	mov    $0x0,%edx
  8000a6:	b8 01 00 00 00       	mov    $0x1,%eax
  8000ab:	89 d1                	mov    %edx,%ecx
  8000ad:	89 d3                	mov    %edx,%ebx
  8000af:	89 d7                	mov    %edx,%edi
  8000b1:	89 d6                	mov    %edx,%esi
  8000b3:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000b5:	5b                   	pop    %ebx
  8000b6:	5e                   	pop    %esi
  8000b7:	5f                   	pop    %edi
  8000b8:	5d                   	pop    %ebp
  8000b9:	c3                   	ret    

008000ba <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000ba:	55                   	push   %ebp
  8000bb:	89 e5                	mov    %esp,%ebp
  8000bd:	57                   	push   %edi
  8000be:	56                   	push   %esi
  8000bf:	53                   	push   %ebx
  8000c0:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8000c3:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000c8:	8b 55 08             	mov    0x8(%ebp),%edx
  8000cb:	b8 03 00 00 00       	mov    $0x3,%eax
  8000d0:	89 cb                	mov    %ecx,%ebx
  8000d2:	89 cf                	mov    %ecx,%edi
  8000d4:	89 ce                	mov    %ecx,%esi
  8000d6:	cd 30                	int    $0x30
	if(check && ret > 0)
  8000d8:	85 c0                	test   %eax,%eax
  8000da:	7f 08                	jg     8000e4 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  8000dc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000df:	5b                   	pop    %ebx
  8000e0:	5e                   	pop    %esi
  8000e1:	5f                   	pop    %edi
  8000e2:	5d                   	pop    %ebp
  8000e3:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8000e4:	83 ec 0c             	sub    $0xc,%esp
  8000e7:	50                   	push   %eax
  8000e8:	6a 03                	push   $0x3
  8000ea:	68 e2 0c 80 00       	push   $0x800ce2
  8000ef:	6a 23                	push   $0x23
  8000f1:	68 ff 0c 80 00       	push   $0x800cff
  8000f6:	e8 1f 00 00 00       	call   80011a <_panic>

008000fb <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  8000fb:	55                   	push   %ebp
  8000fc:	89 e5                	mov    %esp,%ebp
  8000fe:	57                   	push   %edi
  8000ff:	56                   	push   %esi
  800100:	53                   	push   %ebx
	asm volatile("int %1\n"
  800101:	ba 00 00 00 00       	mov    $0x0,%edx
  800106:	b8 02 00 00 00       	mov    $0x2,%eax
  80010b:	89 d1                	mov    %edx,%ecx
  80010d:	89 d3                	mov    %edx,%ebx
  80010f:	89 d7                	mov    %edx,%edi
  800111:	89 d6                	mov    %edx,%esi
  800113:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800115:	5b                   	pop    %ebx
  800116:	5e                   	pop    %esi
  800117:	5f                   	pop    %edi
  800118:	5d                   	pop    %ebp
  800119:	c3                   	ret    

0080011a <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80011a:	55                   	push   %ebp
  80011b:	89 e5                	mov    %esp,%ebp
  80011d:	56                   	push   %esi
  80011e:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80011f:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800122:	8b 35 00 10 80 00    	mov    0x801000,%esi
  800128:	e8 ce ff ff ff       	call   8000fb <sys_getenvid>
  80012d:	83 ec 0c             	sub    $0xc,%esp
  800130:	ff 75 0c             	pushl  0xc(%ebp)
  800133:	ff 75 08             	pushl  0x8(%ebp)
  800136:	56                   	push   %esi
  800137:	50                   	push   %eax
  800138:	68 10 0d 80 00       	push   $0x800d10
  80013d:	e8 b2 00 00 00       	call   8001f4 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800142:	83 c4 18             	add    $0x18,%esp
  800145:	53                   	push   %ebx
  800146:	ff 75 10             	pushl  0x10(%ebp)
  800149:	e8 55 00 00 00       	call   8001a3 <vcprintf>
	cprintf("\n");
  80014e:	c7 04 24 34 0d 80 00 	movl   $0x800d34,(%esp)
  800155:	e8 9a 00 00 00       	call   8001f4 <cprintf>
  80015a:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80015d:	cc                   	int3   
  80015e:	eb fd                	jmp    80015d <_panic+0x43>

00800160 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800160:	55                   	push   %ebp
  800161:	89 e5                	mov    %esp,%ebp
  800163:	53                   	push   %ebx
  800164:	83 ec 04             	sub    $0x4,%esp
  800167:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80016a:	8b 13                	mov    (%ebx),%edx
  80016c:	8d 42 01             	lea    0x1(%edx),%eax
  80016f:	89 03                	mov    %eax,(%ebx)
  800171:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800174:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800178:	3d ff 00 00 00       	cmp    $0xff,%eax
  80017d:	74 08                	je     800187 <putch+0x27>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  80017f:	ff 43 04             	incl   0x4(%ebx)
}
  800182:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800185:	c9                   	leave  
  800186:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800187:	83 ec 08             	sub    $0x8,%esp
  80018a:	68 ff 00 00 00       	push   $0xff
  80018f:	8d 43 08             	lea    0x8(%ebx),%eax
  800192:	50                   	push   %eax
  800193:	e8 e5 fe ff ff       	call   80007d <sys_cputs>
		b->idx = 0;
  800198:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80019e:	83 c4 10             	add    $0x10,%esp
  8001a1:	eb dc                	jmp    80017f <putch+0x1f>

008001a3 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001a3:	55                   	push   %ebp
  8001a4:	89 e5                	mov    %esp,%ebp
  8001a6:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001ac:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001b3:	00 00 00 
	b.cnt = 0;
  8001b6:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001bd:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001c0:	ff 75 0c             	pushl  0xc(%ebp)
  8001c3:	ff 75 08             	pushl  0x8(%ebp)
  8001c6:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001cc:	50                   	push   %eax
  8001cd:	68 60 01 80 00       	push   $0x800160
  8001d2:	e8 0f 01 00 00       	call   8002e6 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001d7:	83 c4 08             	add    $0x8,%esp
  8001da:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001e0:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001e6:	50                   	push   %eax
  8001e7:	e8 91 fe ff ff       	call   80007d <sys_cputs>

	return b.cnt;
}
  8001ec:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001f2:	c9                   	leave  
  8001f3:	c3                   	ret    

008001f4 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001f4:	55                   	push   %ebp
  8001f5:	89 e5                	mov    %esp,%ebp
  8001f7:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001fa:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001fd:	50                   	push   %eax
  8001fe:	ff 75 08             	pushl  0x8(%ebp)
  800201:	e8 9d ff ff ff       	call   8001a3 <vcprintf>
	va_end(ap);

	return cnt;
}
  800206:	c9                   	leave  
  800207:	c3                   	ret    

00800208 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800208:	55                   	push   %ebp
  800209:	89 e5                	mov    %esp,%ebp
  80020b:	57                   	push   %edi
  80020c:	56                   	push   %esi
  80020d:	53                   	push   %ebx
  80020e:	83 ec 1c             	sub    $0x1c,%esp
  800211:	89 c7                	mov    %eax,%edi
  800213:	89 d6                	mov    %edx,%esi
  800215:	8b 45 08             	mov    0x8(%ebp),%eax
  800218:	8b 55 0c             	mov    0xc(%ebp),%edx
  80021b:	89 d1                	mov    %edx,%ecx
  80021d:	89 c2                	mov    %eax,%edx
  80021f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800222:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800225:	8b 45 10             	mov    0x10(%ebp),%eax
  800228:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80022b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80022e:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800235:	39 c2                	cmp    %eax,%edx
  800237:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  80023a:	72 3c                	jb     800278 <printnum+0x70>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80023c:	83 ec 0c             	sub    $0xc,%esp
  80023f:	ff 75 18             	pushl  0x18(%ebp)
  800242:	4b                   	dec    %ebx
  800243:	53                   	push   %ebx
  800244:	50                   	push   %eax
  800245:	83 ec 08             	sub    $0x8,%esp
  800248:	ff 75 e4             	pushl  -0x1c(%ebp)
  80024b:	ff 75 e0             	pushl  -0x20(%ebp)
  80024e:	ff 75 dc             	pushl  -0x24(%ebp)
  800251:	ff 75 d8             	pushl  -0x28(%ebp)
  800254:	e8 57 08 00 00       	call   800ab0 <__udivdi3>
  800259:	83 c4 18             	add    $0x18,%esp
  80025c:	52                   	push   %edx
  80025d:	50                   	push   %eax
  80025e:	89 f2                	mov    %esi,%edx
  800260:	89 f8                	mov    %edi,%eax
  800262:	e8 a1 ff ff ff       	call   800208 <printnum>
  800267:	83 c4 20             	add    $0x20,%esp
  80026a:	eb 11                	jmp    80027d <printnum+0x75>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80026c:	83 ec 08             	sub    $0x8,%esp
  80026f:	56                   	push   %esi
  800270:	ff 75 18             	pushl  0x18(%ebp)
  800273:	ff d7                	call   *%edi
  800275:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800278:	4b                   	dec    %ebx
  800279:	85 db                	test   %ebx,%ebx
  80027b:	7f ef                	jg     80026c <printnum+0x64>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80027d:	83 ec 08             	sub    $0x8,%esp
  800280:	56                   	push   %esi
  800281:	83 ec 04             	sub    $0x4,%esp
  800284:	ff 75 e4             	pushl  -0x1c(%ebp)
  800287:	ff 75 e0             	pushl  -0x20(%ebp)
  80028a:	ff 75 dc             	pushl  -0x24(%ebp)
  80028d:	ff 75 d8             	pushl  -0x28(%ebp)
  800290:	e8 1b 09 00 00       	call   800bb0 <__umoddi3>
  800295:	83 c4 14             	add    $0x14,%esp
  800298:	0f be 80 36 0d 80 00 	movsbl 0x800d36(%eax),%eax
  80029f:	50                   	push   %eax
  8002a0:	ff d7                	call   *%edi
}
  8002a2:	83 c4 10             	add    $0x10,%esp
  8002a5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002a8:	5b                   	pop    %ebx
  8002a9:	5e                   	pop    %esi
  8002aa:	5f                   	pop    %edi
  8002ab:	5d                   	pop    %ebp
  8002ac:	c3                   	ret    

008002ad <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002ad:	55                   	push   %ebp
  8002ae:	89 e5                	mov    %esp,%ebp
  8002b0:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002b3:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8002b6:	8b 10                	mov    (%eax),%edx
  8002b8:	3b 50 04             	cmp    0x4(%eax),%edx
  8002bb:	73 0a                	jae    8002c7 <sprintputch+0x1a>
		*b->buf++ = ch;
  8002bd:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002c0:	89 08                	mov    %ecx,(%eax)
  8002c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8002c5:	88 02                	mov    %al,(%edx)
}
  8002c7:	5d                   	pop    %ebp
  8002c8:	c3                   	ret    

008002c9 <printfmt>:
{
  8002c9:	55                   	push   %ebp
  8002ca:	89 e5                	mov    %esp,%ebp
  8002cc:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8002cf:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002d2:	50                   	push   %eax
  8002d3:	ff 75 10             	pushl  0x10(%ebp)
  8002d6:	ff 75 0c             	pushl  0xc(%ebp)
  8002d9:	ff 75 08             	pushl  0x8(%ebp)
  8002dc:	e8 05 00 00 00       	call   8002e6 <vprintfmt>
}
  8002e1:	83 c4 10             	add    $0x10,%esp
  8002e4:	c9                   	leave  
  8002e5:	c3                   	ret    

008002e6 <vprintfmt>:
{
  8002e6:	55                   	push   %ebp
  8002e7:	89 e5                	mov    %esp,%ebp
  8002e9:	57                   	push   %edi
  8002ea:	56                   	push   %esi
  8002eb:	53                   	push   %ebx
  8002ec:	83 ec 3c             	sub    $0x3c,%esp
  8002ef:	8b 75 08             	mov    0x8(%ebp),%esi
  8002f2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002f5:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002f8:	e9 5b 03 00 00       	jmp    800658 <vprintfmt+0x372>
		padc = ' ';
  8002fd:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  800301:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
		precision = -1;
  800308:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  80030f:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		lflag = 0;
  800316:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80031b:	8d 47 01             	lea    0x1(%edi),%eax
  80031e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800321:	8a 17                	mov    (%edi),%dl
  800323:	8d 42 dd             	lea    -0x23(%edx),%eax
  800326:	3c 55                	cmp    $0x55,%al
  800328:	0f 87 ab 03 00 00    	ja     8006d9 <vprintfmt+0x3f3>
  80032e:	0f b6 c0             	movzbl %al,%eax
  800331:	ff 24 85 c4 0d 80 00 	jmp    *0x800dc4(,%eax,4)
  800338:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  80033b:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  80033f:	eb da                	jmp    80031b <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  800341:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800344:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  800348:	eb d1                	jmp    80031b <vprintfmt+0x35>
  80034a:	0f b6 d2             	movzbl %dl,%edx
  80034d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800350:	b8 00 00 00 00       	mov    $0x0,%eax
  800355:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800358:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80035b:	01 c0                	add    %eax,%eax
  80035d:	8d 44 02 d0          	lea    -0x30(%edx,%eax,1),%eax
				ch = *fmt;
  800361:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800364:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800367:	83 f9 09             	cmp    $0x9,%ecx
  80036a:	77 52                	ja     8003be <vprintfmt+0xd8>
			for (precision = 0; ; ++fmt) {
  80036c:	47                   	inc    %edi
				precision = precision * 10 + ch - '0';
  80036d:	eb e9                	jmp    800358 <vprintfmt+0x72>
			precision = va_arg(ap, int);
  80036f:	8b 45 14             	mov    0x14(%ebp),%eax
  800372:	8b 00                	mov    (%eax),%eax
  800374:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800377:	8b 45 14             	mov    0x14(%ebp),%eax
  80037a:	8d 40 04             	lea    0x4(%eax),%eax
  80037d:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800380:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800383:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800387:	79 92                	jns    80031b <vprintfmt+0x35>
				width = precision, precision = -1;
  800389:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80038c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80038f:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  800396:	eb 83                	jmp    80031b <vprintfmt+0x35>
  800398:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80039c:	78 08                	js     8003a6 <vprintfmt+0xc0>
		switch (ch = *(unsigned char *) fmt++) {
  80039e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8003a1:	e9 75 ff ff ff       	jmp    80031b <vprintfmt+0x35>
  8003a6:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  8003ad:	eb ef                	jmp    80039e <vprintfmt+0xb8>
		switch (ch = *(unsigned char *) fmt++) {
  8003af:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8003b2:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  8003b9:	e9 5d ff ff ff       	jmp    80031b <vprintfmt+0x35>
  8003be:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8003c1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003c4:	eb bd                	jmp    800383 <vprintfmt+0x9d>
			lflag++;
  8003c6:	41                   	inc    %ecx
		switch (ch = *(unsigned char *) fmt++) {
  8003c7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8003ca:	e9 4c ff ff ff       	jmp    80031b <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
  8003cf:	8b 45 14             	mov    0x14(%ebp),%eax
  8003d2:	8d 78 04             	lea    0x4(%eax),%edi
  8003d5:	83 ec 08             	sub    $0x8,%esp
  8003d8:	53                   	push   %ebx
  8003d9:	ff 30                	pushl  (%eax)
  8003db:	ff d6                	call   *%esi
			break;
  8003dd:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8003e0:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8003e3:	e9 6d 02 00 00       	jmp    800655 <vprintfmt+0x36f>
			err = va_arg(ap, int);
  8003e8:	8b 45 14             	mov    0x14(%ebp),%eax
  8003eb:	8d 78 04             	lea    0x4(%eax),%edi
  8003ee:	8b 00                	mov    (%eax),%eax
  8003f0:	85 c0                	test   %eax,%eax
  8003f2:	78 2a                	js     80041e <vprintfmt+0x138>
  8003f4:	89 c2                	mov    %eax,%edx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003f6:	83 f8 06             	cmp    $0x6,%eax
  8003f9:	7f 27                	jg     800422 <vprintfmt+0x13c>
  8003fb:	8b 04 85 1c 0f 80 00 	mov    0x800f1c(,%eax,4),%eax
  800402:	85 c0                	test   %eax,%eax
  800404:	74 1c                	je     800422 <vprintfmt+0x13c>
				printfmt(putch, putdat, "%s", p);
  800406:	50                   	push   %eax
  800407:	68 57 0d 80 00       	push   $0x800d57
  80040c:	53                   	push   %ebx
  80040d:	56                   	push   %esi
  80040e:	e8 b6 fe ff ff       	call   8002c9 <printfmt>
  800413:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800416:	89 7d 14             	mov    %edi,0x14(%ebp)
  800419:	e9 37 02 00 00       	jmp    800655 <vprintfmt+0x36f>
  80041e:	f7 d8                	neg    %eax
  800420:	eb d2                	jmp    8003f4 <vprintfmt+0x10e>
				printfmt(putch, putdat, "error %d", err);
  800422:	52                   	push   %edx
  800423:	68 4e 0d 80 00       	push   $0x800d4e
  800428:	53                   	push   %ebx
  800429:	56                   	push   %esi
  80042a:	e8 9a fe ff ff       	call   8002c9 <printfmt>
  80042f:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800432:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800435:	e9 1b 02 00 00       	jmp    800655 <vprintfmt+0x36f>
			if ((p = va_arg(ap, char *)) == NULL)
  80043a:	8b 45 14             	mov    0x14(%ebp),%eax
  80043d:	83 c0 04             	add    $0x4,%eax
  800440:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800443:	8b 45 14             	mov    0x14(%ebp),%eax
  800446:	8b 00                	mov    (%eax),%eax
  800448:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80044b:	85 c0                	test   %eax,%eax
  80044d:	74 19                	je     800468 <vprintfmt+0x182>
			if (width > 0 && padc != '-')
  80044f:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800453:	7e 06                	jle    80045b <vprintfmt+0x175>
  800455:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  800459:	75 16                	jne    800471 <vprintfmt+0x18b>
				for (width -= strnlen(p, precision); width > 0; width--)
  80045b:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80045e:	89 c7                	mov    %eax,%edi
  800460:	03 45 d4             	add    -0x2c(%ebp),%eax
  800463:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800466:	eb 62                	jmp    8004ca <vprintfmt+0x1e4>
				p = "(null)";
  800468:	c7 45 cc 47 0d 80 00 	movl   $0x800d47,-0x34(%ebp)
  80046f:	eb de                	jmp    80044f <vprintfmt+0x169>
				for (width -= strnlen(p, precision); width > 0; width--)
  800471:	83 ec 08             	sub    $0x8,%esp
  800474:	ff 75 d8             	pushl  -0x28(%ebp)
  800477:	ff 75 cc             	pushl  -0x34(%ebp)
  80047a:	e8 05 03 00 00       	call   800784 <strnlen>
  80047f:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800482:	29 c2                	sub    %eax,%edx
  800484:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  800487:	83 c4 10             	add    $0x10,%esp
  80048a:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  80048c:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  800490:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  800493:	eb 0d                	jmp    8004a2 <vprintfmt+0x1bc>
					putch(padc, putdat);
  800495:	83 ec 08             	sub    $0x8,%esp
  800498:	53                   	push   %ebx
  800499:	ff 75 d4             	pushl  -0x2c(%ebp)
  80049c:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  80049e:	4f                   	dec    %edi
  80049f:	83 c4 10             	add    $0x10,%esp
  8004a2:	85 ff                	test   %edi,%edi
  8004a4:	7f ef                	jg     800495 <vprintfmt+0x1af>
  8004a6:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8004a9:	89 d0                	mov    %edx,%eax
  8004ab:	85 d2                	test   %edx,%edx
  8004ad:	78 0a                	js     8004b9 <vprintfmt+0x1d3>
  8004af:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8004b2:	29 c2                	sub    %eax,%edx
  8004b4:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8004b7:	eb a2                	jmp    80045b <vprintfmt+0x175>
  8004b9:	b8 00 00 00 00       	mov    $0x0,%eax
  8004be:	eb ef                	jmp    8004af <vprintfmt+0x1c9>
					putch(ch, putdat);
  8004c0:	83 ec 08             	sub    $0x8,%esp
  8004c3:	53                   	push   %ebx
  8004c4:	52                   	push   %edx
  8004c5:	ff d6                	call   *%esi
  8004c7:	83 c4 10             	add    $0x10,%esp
  8004ca:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  8004cd:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004cf:	47                   	inc    %edi
  8004d0:	8a 47 ff             	mov    -0x1(%edi),%al
  8004d3:	0f be d0             	movsbl %al,%edx
  8004d6:	85 d2                	test   %edx,%edx
  8004d8:	74 48                	je     800522 <vprintfmt+0x23c>
  8004da:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004de:	78 05                	js     8004e5 <vprintfmt+0x1ff>
  8004e0:	ff 4d d8             	decl   -0x28(%ebp)
  8004e3:	78 1e                	js     800503 <vprintfmt+0x21d>
				if (altflag && (ch < ' ' || ch > '~'))
  8004e5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004e9:	74 d5                	je     8004c0 <vprintfmt+0x1da>
  8004eb:	0f be c0             	movsbl %al,%eax
  8004ee:	83 e8 20             	sub    $0x20,%eax
  8004f1:	83 f8 5e             	cmp    $0x5e,%eax
  8004f4:	76 ca                	jbe    8004c0 <vprintfmt+0x1da>
					putch('?', putdat);
  8004f6:	83 ec 08             	sub    $0x8,%esp
  8004f9:	53                   	push   %ebx
  8004fa:	6a 3f                	push   $0x3f
  8004fc:	ff d6                	call   *%esi
  8004fe:	83 c4 10             	add    $0x10,%esp
  800501:	eb c7                	jmp    8004ca <vprintfmt+0x1e4>
  800503:	89 cf                	mov    %ecx,%edi
  800505:	eb 0c                	jmp    800513 <vprintfmt+0x22d>
				putch(' ', putdat);
  800507:	83 ec 08             	sub    $0x8,%esp
  80050a:	53                   	push   %ebx
  80050b:	6a 20                	push   $0x20
  80050d:	ff d6                	call   *%esi
			for (; width > 0; width--)
  80050f:	4f                   	dec    %edi
  800510:	83 c4 10             	add    $0x10,%esp
  800513:	85 ff                	test   %edi,%edi
  800515:	7f f0                	jg     800507 <vprintfmt+0x221>
			if ((p = va_arg(ap, char *)) == NULL)
  800517:	8b 45 c8             	mov    -0x38(%ebp),%eax
  80051a:	89 45 14             	mov    %eax,0x14(%ebp)
  80051d:	e9 33 01 00 00       	jmp    800655 <vprintfmt+0x36f>
  800522:	89 cf                	mov    %ecx,%edi
  800524:	eb ed                	jmp    800513 <vprintfmt+0x22d>
	if (lflag >= 2)
  800526:	83 f9 01             	cmp    $0x1,%ecx
  800529:	7f 1b                	jg     800546 <vprintfmt+0x260>
	else if (lflag)
  80052b:	85 c9                	test   %ecx,%ecx
  80052d:	74 42                	je     800571 <vprintfmt+0x28b>
		return va_arg(*ap, long);
  80052f:	8b 45 14             	mov    0x14(%ebp),%eax
  800532:	8b 00                	mov    (%eax),%eax
  800534:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800537:	99                   	cltd   
  800538:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80053b:	8b 45 14             	mov    0x14(%ebp),%eax
  80053e:	8d 40 04             	lea    0x4(%eax),%eax
  800541:	89 45 14             	mov    %eax,0x14(%ebp)
  800544:	eb 17                	jmp    80055d <vprintfmt+0x277>
		return va_arg(*ap, long long);
  800546:	8b 45 14             	mov    0x14(%ebp),%eax
  800549:	8b 50 04             	mov    0x4(%eax),%edx
  80054c:	8b 00                	mov    (%eax),%eax
  80054e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800551:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800554:	8b 45 14             	mov    0x14(%ebp),%eax
  800557:	8d 40 08             	lea    0x8(%eax),%eax
  80055a:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  80055d:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800560:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800563:	85 c9                	test   %ecx,%ecx
  800565:	78 21                	js     800588 <vprintfmt+0x2a2>
			base = 10;
  800567:	b8 0a 00 00 00       	mov    $0xa,%eax
  80056c:	e9 ca 00 00 00       	jmp    80063b <vprintfmt+0x355>
		return va_arg(*ap, int);
  800571:	8b 45 14             	mov    0x14(%ebp),%eax
  800574:	8b 00                	mov    (%eax),%eax
  800576:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800579:	99                   	cltd   
  80057a:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80057d:	8b 45 14             	mov    0x14(%ebp),%eax
  800580:	8d 40 04             	lea    0x4(%eax),%eax
  800583:	89 45 14             	mov    %eax,0x14(%ebp)
  800586:	eb d5                	jmp    80055d <vprintfmt+0x277>
				putch('-', putdat);
  800588:	83 ec 08             	sub    $0x8,%esp
  80058b:	53                   	push   %ebx
  80058c:	6a 2d                	push   $0x2d
  80058e:	ff d6                	call   *%esi
				num = -(long long) num;
  800590:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800593:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800596:	f7 da                	neg    %edx
  800598:	83 d1 00             	adc    $0x0,%ecx
  80059b:	f7 d9                	neg    %ecx
  80059d:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8005a0:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005a5:	e9 91 00 00 00       	jmp    80063b <vprintfmt+0x355>
	if (lflag >= 2)
  8005aa:	83 f9 01             	cmp    $0x1,%ecx
  8005ad:	7f 1b                	jg     8005ca <vprintfmt+0x2e4>
	else if (lflag)
  8005af:	85 c9                	test   %ecx,%ecx
  8005b1:	74 2c                	je     8005df <vprintfmt+0x2f9>
		return va_arg(*ap, unsigned long);
  8005b3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b6:	8b 10                	mov    (%eax),%edx
  8005b8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005bd:	8d 40 04             	lea    0x4(%eax),%eax
  8005c0:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005c3:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  8005c8:	eb 71                	jmp    80063b <vprintfmt+0x355>
		return va_arg(*ap, unsigned long long);
  8005ca:	8b 45 14             	mov    0x14(%ebp),%eax
  8005cd:	8b 10                	mov    (%eax),%edx
  8005cf:	8b 48 04             	mov    0x4(%eax),%ecx
  8005d2:	8d 40 08             	lea    0x8(%eax),%eax
  8005d5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005d8:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  8005dd:	eb 5c                	jmp    80063b <vprintfmt+0x355>
		return va_arg(*ap, unsigned int);
  8005df:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e2:	8b 10                	mov    (%eax),%edx
  8005e4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005e9:	8d 40 04             	lea    0x4(%eax),%eax
  8005ec:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005ef:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  8005f4:	eb 45                	jmp    80063b <vprintfmt+0x355>
			putch('X', putdat);
  8005f6:	83 ec 08             	sub    $0x8,%esp
  8005f9:	53                   	push   %ebx
  8005fa:	6a 58                	push   $0x58
  8005fc:	ff d6                	call   *%esi
			putch('X', putdat);
  8005fe:	83 c4 08             	add    $0x8,%esp
  800601:	53                   	push   %ebx
  800602:	6a 58                	push   $0x58
  800604:	ff d6                	call   *%esi
			putch('X', putdat);
  800606:	83 c4 08             	add    $0x8,%esp
  800609:	53                   	push   %ebx
  80060a:	6a 58                	push   $0x58
  80060c:	ff d6                	call   *%esi
			break;
  80060e:	83 c4 10             	add    $0x10,%esp
  800611:	eb 42                	jmp    800655 <vprintfmt+0x36f>
			putch('0', putdat);
  800613:	83 ec 08             	sub    $0x8,%esp
  800616:	53                   	push   %ebx
  800617:	6a 30                	push   $0x30
  800619:	ff d6                	call   *%esi
			putch('x', putdat);
  80061b:	83 c4 08             	add    $0x8,%esp
  80061e:	53                   	push   %ebx
  80061f:	6a 78                	push   $0x78
  800621:	ff d6                	call   *%esi
			num = (unsigned long long)
  800623:	8b 45 14             	mov    0x14(%ebp),%eax
  800626:	8b 10                	mov    (%eax),%edx
  800628:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  80062d:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800630:	8d 40 04             	lea    0x4(%eax),%eax
  800633:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800636:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  80063b:	83 ec 0c             	sub    $0xc,%esp
  80063e:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  800642:	57                   	push   %edi
  800643:	ff 75 d4             	pushl  -0x2c(%ebp)
  800646:	50                   	push   %eax
  800647:	51                   	push   %ecx
  800648:	52                   	push   %edx
  800649:	89 da                	mov    %ebx,%edx
  80064b:	89 f0                	mov    %esi,%eax
  80064d:	e8 b6 fb ff ff       	call   800208 <printnum>
			break;
  800652:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  800655:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800658:	47                   	inc    %edi
  800659:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80065d:	83 f8 25             	cmp    $0x25,%eax
  800660:	0f 84 97 fc ff ff    	je     8002fd <vprintfmt+0x17>
			if (ch == '\0')
  800666:	85 c0                	test   %eax,%eax
  800668:	0f 84 89 00 00 00    	je     8006f7 <vprintfmt+0x411>
			putch(ch, putdat);
  80066e:	83 ec 08             	sub    $0x8,%esp
  800671:	53                   	push   %ebx
  800672:	50                   	push   %eax
  800673:	ff d6                	call   *%esi
  800675:	83 c4 10             	add    $0x10,%esp
  800678:	eb de                	jmp    800658 <vprintfmt+0x372>
	if (lflag >= 2)
  80067a:	83 f9 01             	cmp    $0x1,%ecx
  80067d:	7f 1b                	jg     80069a <vprintfmt+0x3b4>
	else if (lflag)
  80067f:	85 c9                	test   %ecx,%ecx
  800681:	74 2c                	je     8006af <vprintfmt+0x3c9>
		return va_arg(*ap, unsigned long);
  800683:	8b 45 14             	mov    0x14(%ebp),%eax
  800686:	8b 10                	mov    (%eax),%edx
  800688:	b9 00 00 00 00       	mov    $0x0,%ecx
  80068d:	8d 40 04             	lea    0x4(%eax),%eax
  800690:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800693:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  800698:	eb a1                	jmp    80063b <vprintfmt+0x355>
		return va_arg(*ap, unsigned long long);
  80069a:	8b 45 14             	mov    0x14(%ebp),%eax
  80069d:	8b 10                	mov    (%eax),%edx
  80069f:	8b 48 04             	mov    0x4(%eax),%ecx
  8006a2:	8d 40 08             	lea    0x8(%eax),%eax
  8006a5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006a8:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  8006ad:	eb 8c                	jmp    80063b <vprintfmt+0x355>
		return va_arg(*ap, unsigned int);
  8006af:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b2:	8b 10                	mov    (%eax),%edx
  8006b4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006b9:	8d 40 04             	lea    0x4(%eax),%eax
  8006bc:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006bf:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  8006c4:	e9 72 ff ff ff       	jmp    80063b <vprintfmt+0x355>
			putch(ch, putdat);
  8006c9:	83 ec 08             	sub    $0x8,%esp
  8006cc:	53                   	push   %ebx
  8006cd:	6a 25                	push   $0x25
  8006cf:	ff d6                	call   *%esi
			break;
  8006d1:	83 c4 10             	add    $0x10,%esp
  8006d4:	e9 7c ff ff ff       	jmp    800655 <vprintfmt+0x36f>
			putch('%', putdat);
  8006d9:	83 ec 08             	sub    $0x8,%esp
  8006dc:	53                   	push   %ebx
  8006dd:	6a 25                	push   $0x25
  8006df:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006e1:	83 c4 10             	add    $0x10,%esp
  8006e4:	89 f8                	mov    %edi,%eax
  8006e6:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8006ea:	74 03                	je     8006ef <vprintfmt+0x409>
  8006ec:	48                   	dec    %eax
  8006ed:	eb f7                	jmp    8006e6 <vprintfmt+0x400>
  8006ef:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8006f2:	e9 5e ff ff ff       	jmp    800655 <vprintfmt+0x36f>
}
  8006f7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006fa:	5b                   	pop    %ebx
  8006fb:	5e                   	pop    %esi
  8006fc:	5f                   	pop    %edi
  8006fd:	5d                   	pop    %ebp
  8006fe:	c3                   	ret    

008006ff <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006ff:	55                   	push   %ebp
  800700:	89 e5                	mov    %esp,%ebp
  800702:	83 ec 18             	sub    $0x18,%esp
  800705:	8b 45 08             	mov    0x8(%ebp),%eax
  800708:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80070b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80070e:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800712:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800715:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80071c:	85 c0                	test   %eax,%eax
  80071e:	74 26                	je     800746 <vsnprintf+0x47>
  800720:	85 d2                	test   %edx,%edx
  800722:	7e 29                	jle    80074d <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800724:	ff 75 14             	pushl  0x14(%ebp)
  800727:	ff 75 10             	pushl  0x10(%ebp)
  80072a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80072d:	50                   	push   %eax
  80072e:	68 ad 02 80 00       	push   $0x8002ad
  800733:	e8 ae fb ff ff       	call   8002e6 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800738:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80073b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80073e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800741:	83 c4 10             	add    $0x10,%esp
}
  800744:	c9                   	leave  
  800745:	c3                   	ret    
		return -E_INVAL;
  800746:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80074b:	eb f7                	jmp    800744 <vsnprintf+0x45>
  80074d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800752:	eb f0                	jmp    800744 <vsnprintf+0x45>

00800754 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800754:	55                   	push   %ebp
  800755:	89 e5                	mov    %esp,%ebp
  800757:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80075a:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80075d:	50                   	push   %eax
  80075e:	ff 75 10             	pushl  0x10(%ebp)
  800761:	ff 75 0c             	pushl  0xc(%ebp)
  800764:	ff 75 08             	pushl  0x8(%ebp)
  800767:	e8 93 ff ff ff       	call   8006ff <vsnprintf>
	va_end(ap);

	return rc;
}
  80076c:	c9                   	leave  
  80076d:	c3                   	ret    

0080076e <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80076e:	55                   	push   %ebp
  80076f:	89 e5                	mov    %esp,%ebp
  800771:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800774:	b8 00 00 00 00       	mov    $0x0,%eax
  800779:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80077d:	74 03                	je     800782 <strlen+0x14>
		n++;
  80077f:	40                   	inc    %eax
  800780:	eb f7                	jmp    800779 <strlen+0xb>
	return n;
}
  800782:	5d                   	pop    %ebp
  800783:	c3                   	ret    

00800784 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800784:	55                   	push   %ebp
  800785:	89 e5                	mov    %esp,%ebp
  800787:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80078a:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80078d:	b8 00 00 00 00       	mov    $0x0,%eax
  800792:	39 d0                	cmp    %edx,%eax
  800794:	74 0b                	je     8007a1 <strnlen+0x1d>
  800796:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80079a:	74 03                	je     80079f <strnlen+0x1b>
		n++;
  80079c:	40                   	inc    %eax
  80079d:	eb f3                	jmp    800792 <strnlen+0xe>
  80079f:	89 c2                	mov    %eax,%edx
	return n;
}
  8007a1:	89 d0                	mov    %edx,%eax
  8007a3:	5d                   	pop    %ebp
  8007a4:	c3                   	ret    

008007a5 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007a5:	55                   	push   %ebp
  8007a6:	89 e5                	mov    %esp,%ebp
  8007a8:	53                   	push   %ebx
  8007a9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007ac:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007af:	b8 00 00 00 00       	mov    $0x0,%eax
  8007b4:	8a 14 03             	mov    (%ebx,%eax,1),%dl
  8007b7:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8007ba:	40                   	inc    %eax
  8007bb:	84 d2                	test   %dl,%dl
  8007bd:	75 f5                	jne    8007b4 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8007bf:	89 c8                	mov    %ecx,%eax
  8007c1:	5b                   	pop    %ebx
  8007c2:	5d                   	pop    %ebp
  8007c3:	c3                   	ret    

008007c4 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007c4:	55                   	push   %ebp
  8007c5:	89 e5                	mov    %esp,%ebp
  8007c7:	53                   	push   %ebx
  8007c8:	83 ec 10             	sub    $0x10,%esp
  8007cb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007ce:	53                   	push   %ebx
  8007cf:	e8 9a ff ff ff       	call   80076e <strlen>
  8007d4:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  8007d7:	ff 75 0c             	pushl  0xc(%ebp)
  8007da:	01 d8                	add    %ebx,%eax
  8007dc:	50                   	push   %eax
  8007dd:	e8 c3 ff ff ff       	call   8007a5 <strcpy>
	return dst;
}
  8007e2:	89 d8                	mov    %ebx,%eax
  8007e4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007e7:	c9                   	leave  
  8007e8:	c3                   	ret    

008007e9 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007e9:	55                   	push   %ebp
  8007ea:	89 e5                	mov    %esp,%ebp
  8007ec:	53                   	push   %ebx
  8007ed:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007f0:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8007f3:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8007f9:	39 d8                	cmp    %ebx,%eax
  8007fb:	74 0e                	je     80080b <strncpy+0x22>
		*dst++ = *src;
  8007fd:	40                   	inc    %eax
  8007fe:	8a 0a                	mov    (%edx),%cl
  800800:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800803:	80 f9 01             	cmp    $0x1,%cl
  800806:	83 da ff             	sbb    $0xffffffff,%edx
  800809:	eb ee                	jmp    8007f9 <strncpy+0x10>
	}
	return ret;
}
  80080b:	8b 45 08             	mov    0x8(%ebp),%eax
  80080e:	5b                   	pop    %ebx
  80080f:	5d                   	pop    %ebp
  800810:	c3                   	ret    

00800811 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800811:	55                   	push   %ebp
  800812:	89 e5                	mov    %esp,%ebp
  800814:	56                   	push   %esi
  800815:	53                   	push   %ebx
  800816:	8b 75 08             	mov    0x8(%ebp),%esi
  800819:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80081c:	8b 45 10             	mov    0x10(%ebp),%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80081f:	85 c0                	test   %eax,%eax
  800821:	74 22                	je     800845 <strlcpy+0x34>
  800823:	8d 44 06 ff          	lea    -0x1(%esi,%eax,1),%eax
  800827:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  800829:	39 c2                	cmp    %eax,%edx
  80082b:	74 0f                	je     80083c <strlcpy+0x2b>
  80082d:	8a 19                	mov    (%ecx),%bl
  80082f:	84 db                	test   %bl,%bl
  800831:	74 07                	je     80083a <strlcpy+0x29>
			*dst++ = *src++;
  800833:	41                   	inc    %ecx
  800834:	42                   	inc    %edx
  800835:	88 5a ff             	mov    %bl,-0x1(%edx)
  800838:	eb ef                	jmp    800829 <strlcpy+0x18>
  80083a:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  80083c:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80083f:	29 f0                	sub    %esi,%eax
}
  800841:	5b                   	pop    %ebx
  800842:	5e                   	pop    %esi
  800843:	5d                   	pop    %ebp
  800844:	c3                   	ret    
  800845:	89 f0                	mov    %esi,%eax
  800847:	eb f6                	jmp    80083f <strlcpy+0x2e>

00800849 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800849:	55                   	push   %ebp
  80084a:	89 e5                	mov    %esp,%ebp
  80084c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80084f:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800852:	8a 01                	mov    (%ecx),%al
  800854:	84 c0                	test   %al,%al
  800856:	74 08                	je     800860 <strcmp+0x17>
  800858:	3a 02                	cmp    (%edx),%al
  80085a:	75 04                	jne    800860 <strcmp+0x17>
		p++, q++;
  80085c:	41                   	inc    %ecx
  80085d:	42                   	inc    %edx
  80085e:	eb f2                	jmp    800852 <strcmp+0x9>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800860:	0f b6 c0             	movzbl %al,%eax
  800863:	0f b6 12             	movzbl (%edx),%edx
  800866:	29 d0                	sub    %edx,%eax
}
  800868:	5d                   	pop    %ebp
  800869:	c3                   	ret    

0080086a <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80086a:	55                   	push   %ebp
  80086b:	89 e5                	mov    %esp,%ebp
  80086d:	53                   	push   %ebx
  80086e:	8b 45 08             	mov    0x8(%ebp),%eax
  800871:	8b 55 0c             	mov    0xc(%ebp),%edx
  800874:	89 c3                	mov    %eax,%ebx
  800876:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800879:	eb 02                	jmp    80087d <strncmp+0x13>
		n--, p++, q++;
  80087b:	40                   	inc    %eax
  80087c:	42                   	inc    %edx
	while (n > 0 && *p && *p == *q)
  80087d:	39 d8                	cmp    %ebx,%eax
  80087f:	74 15                	je     800896 <strncmp+0x2c>
  800881:	8a 08                	mov    (%eax),%cl
  800883:	84 c9                	test   %cl,%cl
  800885:	74 04                	je     80088b <strncmp+0x21>
  800887:	3a 0a                	cmp    (%edx),%cl
  800889:	74 f0                	je     80087b <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80088b:	0f b6 00             	movzbl (%eax),%eax
  80088e:	0f b6 12             	movzbl (%edx),%edx
  800891:	29 d0                	sub    %edx,%eax
}
  800893:	5b                   	pop    %ebx
  800894:	5d                   	pop    %ebp
  800895:	c3                   	ret    
		return 0;
  800896:	b8 00 00 00 00       	mov    $0x0,%eax
  80089b:	eb f6                	jmp    800893 <strncmp+0x29>

0080089d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80089d:	55                   	push   %ebp
  80089e:	89 e5                	mov    %esp,%ebp
  8008a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a3:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8008a6:	8a 10                	mov    (%eax),%dl
  8008a8:	84 d2                	test   %dl,%dl
  8008aa:	74 07                	je     8008b3 <strchr+0x16>
		if (*s == c)
  8008ac:	38 ca                	cmp    %cl,%dl
  8008ae:	74 08                	je     8008b8 <strchr+0x1b>
	for (; *s; s++)
  8008b0:	40                   	inc    %eax
  8008b1:	eb f3                	jmp    8008a6 <strchr+0x9>
			return (char *) s;
	return 0;
  8008b3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008b8:	5d                   	pop    %ebp
  8008b9:	c3                   	ret    

008008ba <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008ba:	55                   	push   %ebp
  8008bb:	89 e5                	mov    %esp,%ebp
  8008bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c0:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8008c3:	8a 10                	mov    (%eax),%dl
  8008c5:	84 d2                	test   %dl,%dl
  8008c7:	74 07                	je     8008d0 <strfind+0x16>
		if (*s == c)
  8008c9:	38 ca                	cmp    %cl,%dl
  8008cb:	74 03                	je     8008d0 <strfind+0x16>
	for (; *s; s++)
  8008cd:	40                   	inc    %eax
  8008ce:	eb f3                	jmp    8008c3 <strfind+0x9>
			break;
	return (char *) s;
}
  8008d0:	5d                   	pop    %ebp
  8008d1:	c3                   	ret    

008008d2 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008d2:	55                   	push   %ebp
  8008d3:	89 e5                	mov    %esp,%ebp
  8008d5:	57                   	push   %edi
  8008d6:	56                   	push   %esi
  8008d7:	53                   	push   %ebx
  8008d8:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008db:	85 c9                	test   %ecx,%ecx
  8008dd:	74 36                	je     800915 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008df:	89 c8                	mov    %ecx,%eax
  8008e1:	0b 45 08             	or     0x8(%ebp),%eax
  8008e4:	a8 03                	test   $0x3,%al
  8008e6:	75 24                	jne    80090c <memset+0x3a>
		c &= 0xFF;
  8008e8:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008ec:	89 d3                	mov    %edx,%ebx
  8008ee:	c1 e3 08             	shl    $0x8,%ebx
  8008f1:	89 d0                	mov    %edx,%eax
  8008f3:	c1 e0 18             	shl    $0x18,%eax
  8008f6:	89 d6                	mov    %edx,%esi
  8008f8:	c1 e6 10             	shl    $0x10,%esi
  8008fb:	09 f0                	or     %esi,%eax
  8008fd:	09 d0                	or     %edx,%eax
  8008ff:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800901:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800904:	8b 7d 08             	mov    0x8(%ebp),%edi
  800907:	fc                   	cld    
  800908:	f3 ab                	rep stos %eax,%es:(%edi)
  80090a:	eb 09                	jmp    800915 <memset+0x43>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80090c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80090f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800912:	fc                   	cld    
  800913:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800915:	8b 45 08             	mov    0x8(%ebp),%eax
  800918:	5b                   	pop    %ebx
  800919:	5e                   	pop    %esi
  80091a:	5f                   	pop    %edi
  80091b:	5d                   	pop    %ebp
  80091c:	c3                   	ret    

0080091d <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80091d:	55                   	push   %ebp
  80091e:	89 e5                	mov    %esp,%ebp
  800920:	57                   	push   %edi
  800921:	56                   	push   %esi
  800922:	8b 45 08             	mov    0x8(%ebp),%eax
  800925:	8b 75 0c             	mov    0xc(%ebp),%esi
  800928:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80092b:	39 c6                	cmp    %eax,%esi
  80092d:	73 30                	jae    80095f <memmove+0x42>
  80092f:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800932:	39 c2                	cmp    %eax,%edx
  800934:	76 29                	jbe    80095f <memmove+0x42>
		s += n;
		d += n;
  800936:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800939:	89 fe                	mov    %edi,%esi
  80093b:	09 ce                	or     %ecx,%esi
  80093d:	09 d6                	or     %edx,%esi
  80093f:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800945:	75 0e                	jne    800955 <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800947:	83 ef 04             	sub    $0x4,%edi
  80094a:	8d 72 fc             	lea    -0x4(%edx),%esi
  80094d:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800950:	fd                   	std    
  800951:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800953:	eb 07                	jmp    80095c <memmove+0x3f>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800955:	4f                   	dec    %edi
  800956:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800959:	fd                   	std    
  80095a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80095c:	fc                   	cld    
  80095d:	eb 1a                	jmp    800979 <memmove+0x5c>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80095f:	89 c2                	mov    %eax,%edx
  800961:	09 ca                	or     %ecx,%edx
  800963:	09 f2                	or     %esi,%edx
  800965:	f6 c2 03             	test   $0x3,%dl
  800968:	75 0a                	jne    800974 <memmove+0x57>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  80096a:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  80096d:	89 c7                	mov    %eax,%edi
  80096f:	fc                   	cld    
  800970:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800972:	eb 05                	jmp    800979 <memmove+0x5c>
		else
			asm volatile("cld; rep movsb\n"
  800974:	89 c7                	mov    %eax,%edi
  800976:	fc                   	cld    
  800977:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800979:	5e                   	pop    %esi
  80097a:	5f                   	pop    %edi
  80097b:	5d                   	pop    %ebp
  80097c:	c3                   	ret    

0080097d <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80097d:	55                   	push   %ebp
  80097e:	89 e5                	mov    %esp,%ebp
  800980:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800983:	ff 75 10             	pushl  0x10(%ebp)
  800986:	ff 75 0c             	pushl  0xc(%ebp)
  800989:	ff 75 08             	pushl  0x8(%ebp)
  80098c:	e8 8c ff ff ff       	call   80091d <memmove>
}
  800991:	c9                   	leave  
  800992:	c3                   	ret    

00800993 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800993:	55                   	push   %ebp
  800994:	89 e5                	mov    %esp,%ebp
  800996:	56                   	push   %esi
  800997:	53                   	push   %ebx
  800998:	8b 45 08             	mov    0x8(%ebp),%eax
  80099b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80099e:	89 c6                	mov    %eax,%esi
  8009a0:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009a3:	39 f0                	cmp    %esi,%eax
  8009a5:	74 16                	je     8009bd <memcmp+0x2a>
		if (*s1 != *s2)
  8009a7:	8a 08                	mov    (%eax),%cl
  8009a9:	8a 1a                	mov    (%edx),%bl
  8009ab:	38 d9                	cmp    %bl,%cl
  8009ad:	75 04                	jne    8009b3 <memcmp+0x20>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  8009af:	40                   	inc    %eax
  8009b0:	42                   	inc    %edx
  8009b1:	eb f0                	jmp    8009a3 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  8009b3:	0f b6 c1             	movzbl %cl,%eax
  8009b6:	0f b6 db             	movzbl %bl,%ebx
  8009b9:	29 d8                	sub    %ebx,%eax
  8009bb:	eb 05                	jmp    8009c2 <memcmp+0x2f>
	}

	return 0;
  8009bd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009c2:	5b                   	pop    %ebx
  8009c3:	5e                   	pop    %esi
  8009c4:	5d                   	pop    %ebp
  8009c5:	c3                   	ret    

008009c6 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009c6:	55                   	push   %ebp
  8009c7:	89 e5                	mov    %esp,%ebp
  8009c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8009cc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8009cf:	89 c2                	mov    %eax,%edx
  8009d1:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8009d4:	39 d0                	cmp    %edx,%eax
  8009d6:	73 07                	jae    8009df <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009d8:	38 08                	cmp    %cl,(%eax)
  8009da:	74 03                	je     8009df <memfind+0x19>
	for (; s < ends; s++)
  8009dc:	40                   	inc    %eax
  8009dd:	eb f5                	jmp    8009d4 <memfind+0xe>
			break;
	return (void *) s;
}
  8009df:	5d                   	pop    %ebp
  8009e0:	c3                   	ret    

008009e1 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009e1:	55                   	push   %ebp
  8009e2:	89 e5                	mov    %esp,%ebp
  8009e4:	57                   	push   %edi
  8009e5:	56                   	push   %esi
  8009e6:	53                   	push   %ebx
  8009e7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009ea:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009ed:	eb 01                	jmp    8009f0 <strtol+0xf>
		s++;
  8009ef:	41                   	inc    %ecx
	while (*s == ' ' || *s == '\t')
  8009f0:	8a 01                	mov    (%ecx),%al
  8009f2:	3c 20                	cmp    $0x20,%al
  8009f4:	74 f9                	je     8009ef <strtol+0xe>
  8009f6:	3c 09                	cmp    $0x9,%al
  8009f8:	74 f5                	je     8009ef <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  8009fa:	3c 2b                	cmp    $0x2b,%al
  8009fc:	74 24                	je     800a22 <strtol+0x41>
		s++;
	else if (*s == '-')
  8009fe:	3c 2d                	cmp    $0x2d,%al
  800a00:	74 28                	je     800a2a <strtol+0x49>
	int neg = 0;
  800a02:	bf 00 00 00 00       	mov    $0x0,%edi
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a07:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a0d:	75 09                	jne    800a18 <strtol+0x37>
  800a0f:	80 39 30             	cmpb   $0x30,(%ecx)
  800a12:	74 1e                	je     800a32 <strtol+0x51>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a14:	85 db                	test   %ebx,%ebx
  800a16:	74 36                	je     800a4e <strtol+0x6d>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a18:	b8 00 00 00 00       	mov    $0x0,%eax
  800a1d:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800a20:	eb 45                	jmp    800a67 <strtol+0x86>
		s++;
  800a22:	41                   	inc    %ecx
	int neg = 0;
  800a23:	bf 00 00 00 00       	mov    $0x0,%edi
  800a28:	eb dd                	jmp    800a07 <strtol+0x26>
		s++, neg = 1;
  800a2a:	41                   	inc    %ecx
  800a2b:	bf 01 00 00 00       	mov    $0x1,%edi
  800a30:	eb d5                	jmp    800a07 <strtol+0x26>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a32:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a36:	74 0c                	je     800a44 <strtol+0x63>
	else if (base == 0 && s[0] == '0')
  800a38:	85 db                	test   %ebx,%ebx
  800a3a:	75 dc                	jne    800a18 <strtol+0x37>
		s++, base = 8;
  800a3c:	41                   	inc    %ecx
  800a3d:	bb 08 00 00 00       	mov    $0x8,%ebx
  800a42:	eb d4                	jmp    800a18 <strtol+0x37>
		s += 2, base = 16;
  800a44:	83 c1 02             	add    $0x2,%ecx
  800a47:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a4c:	eb ca                	jmp    800a18 <strtol+0x37>
		base = 10;
  800a4e:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800a53:	eb c3                	jmp    800a18 <strtol+0x37>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800a55:	0f be d2             	movsbl %dl,%edx
  800a58:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800a5b:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a5e:	7d 37                	jge    800a97 <strtol+0xb6>
			break;
		s++, val = (val * base) + dig;
  800a60:	41                   	inc    %ecx
  800a61:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a65:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800a67:	8a 11                	mov    (%ecx),%dl
  800a69:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a6c:	89 f3                	mov    %esi,%ebx
  800a6e:	80 fb 09             	cmp    $0x9,%bl
  800a71:	76 e2                	jbe    800a55 <strtol+0x74>
		else if (*s >= 'a' && *s <= 'z')
  800a73:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a76:	89 f3                	mov    %esi,%ebx
  800a78:	80 fb 19             	cmp    $0x19,%bl
  800a7b:	77 08                	ja     800a85 <strtol+0xa4>
			dig = *s - 'a' + 10;
  800a7d:	0f be d2             	movsbl %dl,%edx
  800a80:	83 ea 57             	sub    $0x57,%edx
  800a83:	eb d6                	jmp    800a5b <strtol+0x7a>
		else if (*s >= 'A' && *s <= 'Z')
  800a85:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a88:	89 f3                	mov    %esi,%ebx
  800a8a:	80 fb 19             	cmp    $0x19,%bl
  800a8d:	77 08                	ja     800a97 <strtol+0xb6>
			dig = *s - 'A' + 10;
  800a8f:	0f be d2             	movsbl %dl,%edx
  800a92:	83 ea 37             	sub    $0x37,%edx
  800a95:	eb c4                	jmp    800a5b <strtol+0x7a>
		// we don't properly detect overflow!
	}

	if (endptr)
  800a97:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a9b:	74 05                	je     800aa2 <strtol+0xc1>
		*endptr = (char *) s;
  800a9d:	8b 75 0c             	mov    0xc(%ebp),%esi
  800aa0:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800aa2:	85 ff                	test   %edi,%edi
  800aa4:	74 02                	je     800aa8 <strtol+0xc7>
  800aa6:	f7 d8                	neg    %eax
}
  800aa8:	5b                   	pop    %ebx
  800aa9:	5e                   	pop    %esi
  800aaa:	5f                   	pop    %edi
  800aab:	5d                   	pop    %ebp
  800aac:	c3                   	ret    
  800aad:	66 90                	xchg   %ax,%ax
  800aaf:	90                   	nop

00800ab0 <__udivdi3>:
  800ab0:	55                   	push   %ebp
  800ab1:	57                   	push   %edi
  800ab2:	56                   	push   %esi
  800ab3:	53                   	push   %ebx
  800ab4:	83 ec 1c             	sub    $0x1c,%esp
  800ab7:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800abb:	8b 74 24 34          	mov    0x34(%esp),%esi
  800abf:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800ac3:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800ac7:	85 d2                	test   %edx,%edx
  800ac9:	75 19                	jne    800ae4 <__udivdi3+0x34>
  800acb:	39 f7                	cmp    %esi,%edi
  800acd:	76 45                	jbe    800b14 <__udivdi3+0x64>
  800acf:	89 e8                	mov    %ebp,%eax
  800ad1:	89 f2                	mov    %esi,%edx
  800ad3:	f7 f7                	div    %edi
  800ad5:	31 db                	xor    %ebx,%ebx
  800ad7:	89 da                	mov    %ebx,%edx
  800ad9:	83 c4 1c             	add    $0x1c,%esp
  800adc:	5b                   	pop    %ebx
  800add:	5e                   	pop    %esi
  800ade:	5f                   	pop    %edi
  800adf:	5d                   	pop    %ebp
  800ae0:	c3                   	ret    
  800ae1:	8d 76 00             	lea    0x0(%esi),%esi
  800ae4:	39 f2                	cmp    %esi,%edx
  800ae6:	76 10                	jbe    800af8 <__udivdi3+0x48>
  800ae8:	31 db                	xor    %ebx,%ebx
  800aea:	31 c0                	xor    %eax,%eax
  800aec:	89 da                	mov    %ebx,%edx
  800aee:	83 c4 1c             	add    $0x1c,%esp
  800af1:	5b                   	pop    %ebx
  800af2:	5e                   	pop    %esi
  800af3:	5f                   	pop    %edi
  800af4:	5d                   	pop    %ebp
  800af5:	c3                   	ret    
  800af6:	66 90                	xchg   %ax,%ax
  800af8:	0f bd da             	bsr    %edx,%ebx
  800afb:	83 f3 1f             	xor    $0x1f,%ebx
  800afe:	75 3c                	jne    800b3c <__udivdi3+0x8c>
  800b00:	39 f2                	cmp    %esi,%edx
  800b02:	72 08                	jb     800b0c <__udivdi3+0x5c>
  800b04:	39 ef                	cmp    %ebp,%edi
  800b06:	0f 87 9c 00 00 00    	ja     800ba8 <__udivdi3+0xf8>
  800b0c:	b8 01 00 00 00       	mov    $0x1,%eax
  800b11:	eb d9                	jmp    800aec <__udivdi3+0x3c>
  800b13:	90                   	nop
  800b14:	89 f9                	mov    %edi,%ecx
  800b16:	85 ff                	test   %edi,%edi
  800b18:	75 0b                	jne    800b25 <__udivdi3+0x75>
  800b1a:	b8 01 00 00 00       	mov    $0x1,%eax
  800b1f:	31 d2                	xor    %edx,%edx
  800b21:	f7 f7                	div    %edi
  800b23:	89 c1                	mov    %eax,%ecx
  800b25:	31 d2                	xor    %edx,%edx
  800b27:	89 f0                	mov    %esi,%eax
  800b29:	f7 f1                	div    %ecx
  800b2b:	89 c3                	mov    %eax,%ebx
  800b2d:	89 e8                	mov    %ebp,%eax
  800b2f:	f7 f1                	div    %ecx
  800b31:	89 da                	mov    %ebx,%edx
  800b33:	83 c4 1c             	add    $0x1c,%esp
  800b36:	5b                   	pop    %ebx
  800b37:	5e                   	pop    %esi
  800b38:	5f                   	pop    %edi
  800b39:	5d                   	pop    %ebp
  800b3a:	c3                   	ret    
  800b3b:	90                   	nop
  800b3c:	b8 20 00 00 00       	mov    $0x20,%eax
  800b41:	29 d8                	sub    %ebx,%eax
  800b43:	88 d9                	mov    %bl,%cl
  800b45:	d3 e2                	shl    %cl,%edx
  800b47:	89 54 24 08          	mov    %edx,0x8(%esp)
  800b4b:	89 fa                	mov    %edi,%edx
  800b4d:	88 c1                	mov    %al,%cl
  800b4f:	d3 ea                	shr    %cl,%edx
  800b51:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800b55:	09 d1                	or     %edx,%ecx
  800b57:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800b5b:	88 d9                	mov    %bl,%cl
  800b5d:	d3 e7                	shl    %cl,%edi
  800b5f:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800b63:	89 f7                	mov    %esi,%edi
  800b65:	88 c1                	mov    %al,%cl
  800b67:	d3 ef                	shr    %cl,%edi
  800b69:	88 d9                	mov    %bl,%cl
  800b6b:	d3 e6                	shl    %cl,%esi
  800b6d:	89 ea                	mov    %ebp,%edx
  800b6f:	88 c1                	mov    %al,%cl
  800b71:	d3 ea                	shr    %cl,%edx
  800b73:	09 d6                	or     %edx,%esi
  800b75:	89 f0                	mov    %esi,%eax
  800b77:	89 fa                	mov    %edi,%edx
  800b79:	f7 74 24 08          	divl   0x8(%esp)
  800b7d:	89 d7                	mov    %edx,%edi
  800b7f:	89 c6                	mov    %eax,%esi
  800b81:	f7 64 24 0c          	mull   0xc(%esp)
  800b85:	39 d7                	cmp    %edx,%edi
  800b87:	72 13                	jb     800b9c <__udivdi3+0xec>
  800b89:	74 09                	je     800b94 <__udivdi3+0xe4>
  800b8b:	89 f0                	mov    %esi,%eax
  800b8d:	31 db                	xor    %ebx,%ebx
  800b8f:	e9 58 ff ff ff       	jmp    800aec <__udivdi3+0x3c>
  800b94:	88 d9                	mov    %bl,%cl
  800b96:	d3 e5                	shl    %cl,%ebp
  800b98:	39 c5                	cmp    %eax,%ebp
  800b9a:	73 ef                	jae    800b8b <__udivdi3+0xdb>
  800b9c:	8d 46 ff             	lea    -0x1(%esi),%eax
  800b9f:	31 db                	xor    %ebx,%ebx
  800ba1:	e9 46 ff ff ff       	jmp    800aec <__udivdi3+0x3c>
  800ba6:	66 90                	xchg   %ax,%ax
  800ba8:	31 c0                	xor    %eax,%eax
  800baa:	e9 3d ff ff ff       	jmp    800aec <__udivdi3+0x3c>
  800baf:	90                   	nop

00800bb0 <__umoddi3>:
  800bb0:	55                   	push   %ebp
  800bb1:	57                   	push   %edi
  800bb2:	56                   	push   %esi
  800bb3:	53                   	push   %ebx
  800bb4:	83 ec 1c             	sub    $0x1c,%esp
  800bb7:	8b 74 24 30          	mov    0x30(%esp),%esi
  800bbb:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800bbf:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800bc3:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  800bc7:	85 c0                	test   %eax,%eax
  800bc9:	75 19                	jne    800be4 <__umoddi3+0x34>
  800bcb:	39 df                	cmp    %ebx,%edi
  800bcd:	76 51                	jbe    800c20 <__umoddi3+0x70>
  800bcf:	89 f0                	mov    %esi,%eax
  800bd1:	89 da                	mov    %ebx,%edx
  800bd3:	f7 f7                	div    %edi
  800bd5:	89 d0                	mov    %edx,%eax
  800bd7:	31 d2                	xor    %edx,%edx
  800bd9:	83 c4 1c             	add    $0x1c,%esp
  800bdc:	5b                   	pop    %ebx
  800bdd:	5e                   	pop    %esi
  800bde:	5f                   	pop    %edi
  800bdf:	5d                   	pop    %ebp
  800be0:	c3                   	ret    
  800be1:	8d 76 00             	lea    0x0(%esi),%esi
  800be4:	89 f2                	mov    %esi,%edx
  800be6:	39 d8                	cmp    %ebx,%eax
  800be8:	76 0e                	jbe    800bf8 <__umoddi3+0x48>
  800bea:	89 f0                	mov    %esi,%eax
  800bec:	89 da                	mov    %ebx,%edx
  800bee:	83 c4 1c             	add    $0x1c,%esp
  800bf1:	5b                   	pop    %ebx
  800bf2:	5e                   	pop    %esi
  800bf3:	5f                   	pop    %edi
  800bf4:	5d                   	pop    %ebp
  800bf5:	c3                   	ret    
  800bf6:	66 90                	xchg   %ax,%ax
  800bf8:	0f bd e8             	bsr    %eax,%ebp
  800bfb:	83 f5 1f             	xor    $0x1f,%ebp
  800bfe:	75 44                	jne    800c44 <__umoddi3+0x94>
  800c00:	39 d8                	cmp    %ebx,%eax
  800c02:	72 06                	jb     800c0a <__umoddi3+0x5a>
  800c04:	89 d9                	mov    %ebx,%ecx
  800c06:	39 f7                	cmp    %esi,%edi
  800c08:	77 08                	ja     800c12 <__umoddi3+0x62>
  800c0a:	29 fe                	sub    %edi,%esi
  800c0c:	19 c3                	sbb    %eax,%ebx
  800c0e:	89 f2                	mov    %esi,%edx
  800c10:	89 d9                	mov    %ebx,%ecx
  800c12:	89 d0                	mov    %edx,%eax
  800c14:	89 ca                	mov    %ecx,%edx
  800c16:	83 c4 1c             	add    $0x1c,%esp
  800c19:	5b                   	pop    %ebx
  800c1a:	5e                   	pop    %esi
  800c1b:	5f                   	pop    %edi
  800c1c:	5d                   	pop    %ebp
  800c1d:	c3                   	ret    
  800c1e:	66 90                	xchg   %ax,%ax
  800c20:	89 fd                	mov    %edi,%ebp
  800c22:	85 ff                	test   %edi,%edi
  800c24:	75 0b                	jne    800c31 <__umoddi3+0x81>
  800c26:	b8 01 00 00 00       	mov    $0x1,%eax
  800c2b:	31 d2                	xor    %edx,%edx
  800c2d:	f7 f7                	div    %edi
  800c2f:	89 c5                	mov    %eax,%ebp
  800c31:	89 d8                	mov    %ebx,%eax
  800c33:	31 d2                	xor    %edx,%edx
  800c35:	f7 f5                	div    %ebp
  800c37:	89 f0                	mov    %esi,%eax
  800c39:	f7 f5                	div    %ebp
  800c3b:	89 d0                	mov    %edx,%eax
  800c3d:	31 d2                	xor    %edx,%edx
  800c3f:	eb 98                	jmp    800bd9 <__umoddi3+0x29>
  800c41:	8d 76 00             	lea    0x0(%esi),%esi
  800c44:	ba 20 00 00 00       	mov    $0x20,%edx
  800c49:	29 ea                	sub    %ebp,%edx
  800c4b:	89 e9                	mov    %ebp,%ecx
  800c4d:	d3 e0                	shl    %cl,%eax
  800c4f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c53:	89 f8                	mov    %edi,%eax
  800c55:	89 54 24 04          	mov    %edx,0x4(%esp)
  800c59:	88 d1                	mov    %dl,%cl
  800c5b:	d3 e8                	shr    %cl,%eax
  800c5d:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800c61:	09 c1                	or     %eax,%ecx
  800c63:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800c67:	89 e9                	mov    %ebp,%ecx
  800c69:	d3 e7                	shl    %cl,%edi
  800c6b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800c6f:	89 d8                	mov    %ebx,%eax
  800c71:	8b 54 24 04          	mov    0x4(%esp),%edx
  800c75:	88 d1                	mov    %dl,%cl
  800c77:	d3 e8                	shr    %cl,%eax
  800c79:	89 c7                	mov    %eax,%edi
  800c7b:	89 e9                	mov    %ebp,%ecx
  800c7d:	d3 e3                	shl    %cl,%ebx
  800c7f:	89 f0                	mov    %esi,%eax
  800c81:	88 d1                	mov    %dl,%cl
  800c83:	d3 e8                	shr    %cl,%eax
  800c85:	09 d8                	or     %ebx,%eax
  800c87:	89 e9                	mov    %ebp,%ecx
  800c89:	d3 e6                	shl    %cl,%esi
  800c8b:	89 f3                	mov    %esi,%ebx
  800c8d:	89 fa                	mov    %edi,%edx
  800c8f:	f7 74 24 08          	divl   0x8(%esp)
  800c93:	89 d1                	mov    %edx,%ecx
  800c95:	f7 64 24 0c          	mull   0xc(%esp)
  800c99:	89 c6                	mov    %eax,%esi
  800c9b:	89 d7                	mov    %edx,%edi
  800c9d:	39 d1                	cmp    %edx,%ecx
  800c9f:	72 27                	jb     800cc8 <__umoddi3+0x118>
  800ca1:	74 21                	je     800cc4 <__umoddi3+0x114>
  800ca3:	89 ca                	mov    %ecx,%edx
  800ca5:	29 f3                	sub    %esi,%ebx
  800ca7:	19 fa                	sbb    %edi,%edx
  800ca9:	89 d0                	mov    %edx,%eax
  800cab:	8a 4c 24 04          	mov    0x4(%esp),%cl
  800caf:	d3 e0                	shl    %cl,%eax
  800cb1:	89 e9                	mov    %ebp,%ecx
  800cb3:	d3 eb                	shr    %cl,%ebx
  800cb5:	09 d8                	or     %ebx,%eax
  800cb7:	d3 ea                	shr    %cl,%edx
  800cb9:	83 c4 1c             	add    $0x1c,%esp
  800cbc:	5b                   	pop    %ebx
  800cbd:	5e                   	pop    %esi
  800cbe:	5f                   	pop    %edi
  800cbf:	5d                   	pop    %ebp
  800cc0:	c3                   	ret    
  800cc1:	8d 76 00             	lea    0x0(%esi),%esi
  800cc4:	39 c3                	cmp    %eax,%ebx
  800cc6:	73 db                	jae    800ca3 <__umoddi3+0xf3>
  800cc8:	2b 44 24 0c          	sub    0xc(%esp),%eax
  800ccc:	1b 54 24 08          	sbb    0x8(%esp),%edx
  800cd0:	89 d7                	mov    %edx,%edi
  800cd2:	89 c6                	mov    %eax,%esi
  800cd4:	eb cd                	jmp    800ca3 <__umoddi3+0xf3>
