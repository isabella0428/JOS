
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
  800038:	57                   	push   %edi
  800039:	56                   	push   %esi
  80003a:	53                   	push   %ebx
  80003b:	83 ec 6c             	sub    $0x6c,%esp
  80003e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	struct Env curenv = envs[ENVX(sys_getenvid())];
  800041:	e8 de 00 00 00       	call   800124 <sys_getenvid>
  800046:	25 ff 03 00 00       	and    $0x3ff,%eax
  80004b:	8d 34 00             	lea    (%eax,%eax,1),%esi
  80004e:	01 c6                	add    %eax,%esi
  800050:	c1 e6 05             	shl    $0x5,%esi
  800053:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  800059:	8d 7d 88             	lea    -0x78(%ebp),%edi
  80005c:	b9 18 00 00 00       	mov    $0x18,%ecx
  800061:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	thisenv = &curenv;
  800063:	8d 45 88             	lea    -0x78(%ebp),%eax
  800066:	a3 04 10 80 00       	mov    %eax,0x801004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80006b:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  80006f:	7e 07                	jle    800078 <libmain+0x43>
		binaryname = argv[0];
  800071:	8b 03                	mov    (%ebx),%eax
  800073:	a3 00 10 80 00       	mov    %eax,0x801000
	
	// call user main routine
	umain(argc, argv);
  800078:	83 ec 08             	sub    $0x8,%esp
  80007b:	53                   	push   %ebx
  80007c:	ff 75 08             	pushl  0x8(%ebp)
  80007f:	e8 af ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800084:	e8 0b 00 00 00       	call   800094 <exit>
}
  800089:	83 c4 10             	add    $0x10,%esp
  80008c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80008f:	5b                   	pop    %ebx
  800090:	5e                   	pop    %esi
  800091:	5f                   	pop    %edi
  800092:	5d                   	pop    %ebp
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
  80009c:	e8 42 00 00 00       	call   8000e3 <sys_env_destroy>
}
  8000a1:	83 c4 10             	add    $0x10,%esp
  8000a4:	c9                   	leave  
  8000a5:	c3                   	ret    

008000a6 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000a6:	55                   	push   %ebp
  8000a7:	89 e5                	mov    %esp,%ebp
  8000a9:	57                   	push   %edi
  8000aa:	56                   	push   %esi
  8000ab:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000ac:	b8 00 00 00 00       	mov    $0x0,%eax
  8000b1:	8b 55 08             	mov    0x8(%ebp),%edx
  8000b4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000b7:	89 c3                	mov    %eax,%ebx
  8000b9:	89 c7                	mov    %eax,%edi
  8000bb:	89 c6                	mov    %eax,%esi
  8000bd:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000bf:	5b                   	pop    %ebx
  8000c0:	5e                   	pop    %esi
  8000c1:	5f                   	pop    %edi
  8000c2:	5d                   	pop    %ebp
  8000c3:	c3                   	ret    

008000c4 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000c4:	55                   	push   %ebp
  8000c5:	89 e5                	mov    %esp,%ebp
  8000c7:	57                   	push   %edi
  8000c8:	56                   	push   %esi
  8000c9:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000ca:	ba 00 00 00 00       	mov    $0x0,%edx
  8000cf:	b8 01 00 00 00       	mov    $0x1,%eax
  8000d4:	89 d1                	mov    %edx,%ecx
  8000d6:	89 d3                	mov    %edx,%ebx
  8000d8:	89 d7                	mov    %edx,%edi
  8000da:	89 d6                	mov    %edx,%esi
  8000dc:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000de:	5b                   	pop    %ebx
  8000df:	5e                   	pop    %esi
  8000e0:	5f                   	pop    %edi
  8000e1:	5d                   	pop    %ebp
  8000e2:	c3                   	ret    

008000e3 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000e3:	55                   	push   %ebp
  8000e4:	89 e5                	mov    %esp,%ebp
  8000e6:	57                   	push   %edi
  8000e7:	56                   	push   %esi
  8000e8:	53                   	push   %ebx
  8000e9:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8000ec:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000f1:	8b 55 08             	mov    0x8(%ebp),%edx
  8000f4:	b8 03 00 00 00       	mov    $0x3,%eax
  8000f9:	89 cb                	mov    %ecx,%ebx
  8000fb:	89 cf                	mov    %ecx,%edi
  8000fd:	89 ce                	mov    %ecx,%esi
  8000ff:	cd 30                	int    $0x30
	if(check && ret > 0)
  800101:	85 c0                	test   %eax,%eax
  800103:	7f 08                	jg     80010d <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800105:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800108:	5b                   	pop    %ebx
  800109:	5e                   	pop    %esi
  80010a:	5f                   	pop    %edi
  80010b:	5d                   	pop    %ebp
  80010c:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80010d:	83 ec 0c             	sub    $0xc,%esp
  800110:	50                   	push   %eax
  800111:	6a 03                	push   $0x3
  800113:	68 0a 0d 80 00       	push   $0x800d0a
  800118:	6a 23                	push   $0x23
  80011a:	68 27 0d 80 00       	push   $0x800d27
  80011f:	e8 1f 00 00 00       	call   800143 <_panic>

00800124 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800124:	55                   	push   %ebp
  800125:	89 e5                	mov    %esp,%ebp
  800127:	57                   	push   %edi
  800128:	56                   	push   %esi
  800129:	53                   	push   %ebx
	asm volatile("int %1\n"
  80012a:	ba 00 00 00 00       	mov    $0x0,%edx
  80012f:	b8 02 00 00 00       	mov    $0x2,%eax
  800134:	89 d1                	mov    %edx,%ecx
  800136:	89 d3                	mov    %edx,%ebx
  800138:	89 d7                	mov    %edx,%edi
  80013a:	89 d6                	mov    %edx,%esi
  80013c:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80013e:	5b                   	pop    %ebx
  80013f:	5e                   	pop    %esi
  800140:	5f                   	pop    %edi
  800141:	5d                   	pop    %ebp
  800142:	c3                   	ret    

00800143 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800143:	55                   	push   %ebp
  800144:	89 e5                	mov    %esp,%ebp
  800146:	56                   	push   %esi
  800147:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800148:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80014b:	8b 35 00 10 80 00    	mov    0x801000,%esi
  800151:	e8 ce ff ff ff       	call   800124 <sys_getenvid>
  800156:	83 ec 0c             	sub    $0xc,%esp
  800159:	ff 75 0c             	pushl  0xc(%ebp)
  80015c:	ff 75 08             	pushl  0x8(%ebp)
  80015f:	56                   	push   %esi
  800160:	50                   	push   %eax
  800161:	68 38 0d 80 00       	push   $0x800d38
  800166:	e8 b2 00 00 00       	call   80021d <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80016b:	83 c4 18             	add    $0x18,%esp
  80016e:	53                   	push   %ebx
  80016f:	ff 75 10             	pushl  0x10(%ebp)
  800172:	e8 55 00 00 00       	call   8001cc <vcprintf>
	cprintf("\n");
  800177:	c7 04 24 5c 0d 80 00 	movl   $0x800d5c,(%esp)
  80017e:	e8 9a 00 00 00       	call   80021d <cprintf>
  800183:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800186:	cc                   	int3   
  800187:	eb fd                	jmp    800186 <_panic+0x43>

00800189 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800189:	55                   	push   %ebp
  80018a:	89 e5                	mov    %esp,%ebp
  80018c:	53                   	push   %ebx
  80018d:	83 ec 04             	sub    $0x4,%esp
  800190:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800193:	8b 13                	mov    (%ebx),%edx
  800195:	8d 42 01             	lea    0x1(%edx),%eax
  800198:	89 03                	mov    %eax,(%ebx)
  80019a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80019d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001a1:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001a6:	74 08                	je     8001b0 <putch+0x27>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8001a8:	ff 43 04             	incl   0x4(%ebx)
}
  8001ab:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001ae:	c9                   	leave  
  8001af:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8001b0:	83 ec 08             	sub    $0x8,%esp
  8001b3:	68 ff 00 00 00       	push   $0xff
  8001b8:	8d 43 08             	lea    0x8(%ebx),%eax
  8001bb:	50                   	push   %eax
  8001bc:	e8 e5 fe ff ff       	call   8000a6 <sys_cputs>
		b->idx = 0;
  8001c1:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001c7:	83 c4 10             	add    $0x10,%esp
  8001ca:	eb dc                	jmp    8001a8 <putch+0x1f>

008001cc <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001cc:	55                   	push   %ebp
  8001cd:	89 e5                	mov    %esp,%ebp
  8001cf:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001d5:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001dc:	00 00 00 
	b.cnt = 0;
  8001df:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001e6:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001e9:	ff 75 0c             	pushl  0xc(%ebp)
  8001ec:	ff 75 08             	pushl  0x8(%ebp)
  8001ef:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001f5:	50                   	push   %eax
  8001f6:	68 89 01 80 00       	push   $0x800189
  8001fb:	e8 0f 01 00 00       	call   80030f <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800200:	83 c4 08             	add    $0x8,%esp
  800203:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800209:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80020f:	50                   	push   %eax
  800210:	e8 91 fe ff ff       	call   8000a6 <sys_cputs>

	return b.cnt;
}
  800215:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80021b:	c9                   	leave  
  80021c:	c3                   	ret    

0080021d <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80021d:	55                   	push   %ebp
  80021e:	89 e5                	mov    %esp,%ebp
  800220:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800223:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800226:	50                   	push   %eax
  800227:	ff 75 08             	pushl  0x8(%ebp)
  80022a:	e8 9d ff ff ff       	call   8001cc <vcprintf>
	va_end(ap);

	return cnt;
}
  80022f:	c9                   	leave  
  800230:	c3                   	ret    

00800231 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800231:	55                   	push   %ebp
  800232:	89 e5                	mov    %esp,%ebp
  800234:	57                   	push   %edi
  800235:	56                   	push   %esi
  800236:	53                   	push   %ebx
  800237:	83 ec 1c             	sub    $0x1c,%esp
  80023a:	89 c7                	mov    %eax,%edi
  80023c:	89 d6                	mov    %edx,%esi
  80023e:	8b 45 08             	mov    0x8(%ebp),%eax
  800241:	8b 55 0c             	mov    0xc(%ebp),%edx
  800244:	89 d1                	mov    %edx,%ecx
  800246:	89 c2                	mov    %eax,%edx
  800248:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80024b:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80024e:	8b 45 10             	mov    0x10(%ebp),%eax
  800251:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800254:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800257:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80025e:	39 c2                	cmp    %eax,%edx
  800260:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  800263:	72 3c                	jb     8002a1 <printnum+0x70>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800265:	83 ec 0c             	sub    $0xc,%esp
  800268:	ff 75 18             	pushl  0x18(%ebp)
  80026b:	4b                   	dec    %ebx
  80026c:	53                   	push   %ebx
  80026d:	50                   	push   %eax
  80026e:	83 ec 08             	sub    $0x8,%esp
  800271:	ff 75 e4             	pushl  -0x1c(%ebp)
  800274:	ff 75 e0             	pushl  -0x20(%ebp)
  800277:	ff 75 dc             	pushl  -0x24(%ebp)
  80027a:	ff 75 d8             	pushl  -0x28(%ebp)
  80027d:	e8 56 08 00 00       	call   800ad8 <__udivdi3>
  800282:	83 c4 18             	add    $0x18,%esp
  800285:	52                   	push   %edx
  800286:	50                   	push   %eax
  800287:	89 f2                	mov    %esi,%edx
  800289:	89 f8                	mov    %edi,%eax
  80028b:	e8 a1 ff ff ff       	call   800231 <printnum>
  800290:	83 c4 20             	add    $0x20,%esp
  800293:	eb 11                	jmp    8002a6 <printnum+0x75>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800295:	83 ec 08             	sub    $0x8,%esp
  800298:	56                   	push   %esi
  800299:	ff 75 18             	pushl  0x18(%ebp)
  80029c:	ff d7                	call   *%edi
  80029e:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8002a1:	4b                   	dec    %ebx
  8002a2:	85 db                	test   %ebx,%ebx
  8002a4:	7f ef                	jg     800295 <printnum+0x64>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002a6:	83 ec 08             	sub    $0x8,%esp
  8002a9:	56                   	push   %esi
  8002aa:	83 ec 04             	sub    $0x4,%esp
  8002ad:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002b0:	ff 75 e0             	pushl  -0x20(%ebp)
  8002b3:	ff 75 dc             	pushl  -0x24(%ebp)
  8002b6:	ff 75 d8             	pushl  -0x28(%ebp)
  8002b9:	e8 1a 09 00 00       	call   800bd8 <__umoddi3>
  8002be:	83 c4 14             	add    $0x14,%esp
  8002c1:	0f be 80 5e 0d 80 00 	movsbl 0x800d5e(%eax),%eax
  8002c8:	50                   	push   %eax
  8002c9:	ff d7                	call   *%edi
}
  8002cb:	83 c4 10             	add    $0x10,%esp
  8002ce:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002d1:	5b                   	pop    %ebx
  8002d2:	5e                   	pop    %esi
  8002d3:	5f                   	pop    %edi
  8002d4:	5d                   	pop    %ebp
  8002d5:	c3                   	ret    

008002d6 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002d6:	55                   	push   %ebp
  8002d7:	89 e5                	mov    %esp,%ebp
  8002d9:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002dc:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8002df:	8b 10                	mov    (%eax),%edx
  8002e1:	3b 50 04             	cmp    0x4(%eax),%edx
  8002e4:	73 0a                	jae    8002f0 <sprintputch+0x1a>
		*b->buf++ = ch;
  8002e6:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002e9:	89 08                	mov    %ecx,(%eax)
  8002eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8002ee:	88 02                	mov    %al,(%edx)
}
  8002f0:	5d                   	pop    %ebp
  8002f1:	c3                   	ret    

008002f2 <printfmt>:
{
  8002f2:	55                   	push   %ebp
  8002f3:	89 e5                	mov    %esp,%ebp
  8002f5:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8002f8:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002fb:	50                   	push   %eax
  8002fc:	ff 75 10             	pushl  0x10(%ebp)
  8002ff:	ff 75 0c             	pushl  0xc(%ebp)
  800302:	ff 75 08             	pushl  0x8(%ebp)
  800305:	e8 05 00 00 00       	call   80030f <vprintfmt>
}
  80030a:	83 c4 10             	add    $0x10,%esp
  80030d:	c9                   	leave  
  80030e:	c3                   	ret    

0080030f <vprintfmt>:
{
  80030f:	55                   	push   %ebp
  800310:	89 e5                	mov    %esp,%ebp
  800312:	57                   	push   %edi
  800313:	56                   	push   %esi
  800314:	53                   	push   %ebx
  800315:	83 ec 3c             	sub    $0x3c,%esp
  800318:	8b 75 08             	mov    0x8(%ebp),%esi
  80031b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80031e:	8b 7d 10             	mov    0x10(%ebp),%edi
  800321:	e9 5b 03 00 00       	jmp    800681 <vprintfmt+0x372>
		padc = ' ';
  800326:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  80032a:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
		precision = -1;
  800331:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  800338:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		lflag = 0;
  80033f:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800344:	8d 47 01             	lea    0x1(%edi),%eax
  800347:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80034a:	8a 17                	mov    (%edi),%dl
  80034c:	8d 42 dd             	lea    -0x23(%edx),%eax
  80034f:	3c 55                	cmp    $0x55,%al
  800351:	0f 87 ab 03 00 00    	ja     800702 <vprintfmt+0x3f3>
  800357:	0f b6 c0             	movzbl %al,%eax
  80035a:	ff 24 85 ec 0d 80 00 	jmp    *0x800dec(,%eax,4)
  800361:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800364:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  800368:	eb da                	jmp    800344 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  80036a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80036d:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  800371:	eb d1                	jmp    800344 <vprintfmt+0x35>
  800373:	0f b6 d2             	movzbl %dl,%edx
  800376:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800379:	b8 00 00 00 00       	mov    $0x0,%eax
  80037e:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800381:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800384:	01 c0                	add    %eax,%eax
  800386:	8d 44 02 d0          	lea    -0x30(%edx,%eax,1),%eax
				ch = *fmt;
  80038a:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  80038d:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800390:	83 f9 09             	cmp    $0x9,%ecx
  800393:	77 52                	ja     8003e7 <vprintfmt+0xd8>
			for (precision = 0; ; ++fmt) {
  800395:	47                   	inc    %edi
				precision = precision * 10 + ch - '0';
  800396:	eb e9                	jmp    800381 <vprintfmt+0x72>
			precision = va_arg(ap, int);
  800398:	8b 45 14             	mov    0x14(%ebp),%eax
  80039b:	8b 00                	mov    (%eax),%eax
  80039d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003a0:	8b 45 14             	mov    0x14(%ebp),%eax
  8003a3:	8d 40 04             	lea    0x4(%eax),%eax
  8003a6:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003a9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8003ac:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8003b0:	79 92                	jns    800344 <vprintfmt+0x35>
				width = precision, precision = -1;
  8003b2:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8003b5:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8003b8:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8003bf:	eb 83                	jmp    800344 <vprintfmt+0x35>
  8003c1:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8003c5:	78 08                	js     8003cf <vprintfmt+0xc0>
		switch (ch = *(unsigned char *) fmt++) {
  8003c7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8003ca:	e9 75 ff ff ff       	jmp    800344 <vprintfmt+0x35>
  8003cf:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  8003d6:	eb ef                	jmp    8003c7 <vprintfmt+0xb8>
		switch (ch = *(unsigned char *) fmt++) {
  8003d8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8003db:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  8003e2:	e9 5d ff ff ff       	jmp    800344 <vprintfmt+0x35>
  8003e7:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8003ea:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003ed:	eb bd                	jmp    8003ac <vprintfmt+0x9d>
			lflag++;
  8003ef:	41                   	inc    %ecx
		switch (ch = *(unsigned char *) fmt++) {
  8003f0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8003f3:	e9 4c ff ff ff       	jmp    800344 <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
  8003f8:	8b 45 14             	mov    0x14(%ebp),%eax
  8003fb:	8d 78 04             	lea    0x4(%eax),%edi
  8003fe:	83 ec 08             	sub    $0x8,%esp
  800401:	53                   	push   %ebx
  800402:	ff 30                	pushl  (%eax)
  800404:	ff d6                	call   *%esi
			break;
  800406:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800409:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  80040c:	e9 6d 02 00 00       	jmp    80067e <vprintfmt+0x36f>
			err = va_arg(ap, int);
  800411:	8b 45 14             	mov    0x14(%ebp),%eax
  800414:	8d 78 04             	lea    0x4(%eax),%edi
  800417:	8b 00                	mov    (%eax),%eax
  800419:	85 c0                	test   %eax,%eax
  80041b:	78 2a                	js     800447 <vprintfmt+0x138>
  80041d:	89 c2                	mov    %eax,%edx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80041f:	83 f8 06             	cmp    $0x6,%eax
  800422:	7f 27                	jg     80044b <vprintfmt+0x13c>
  800424:	8b 04 85 44 0f 80 00 	mov    0x800f44(,%eax,4),%eax
  80042b:	85 c0                	test   %eax,%eax
  80042d:	74 1c                	je     80044b <vprintfmt+0x13c>
				printfmt(putch, putdat, "%s", p);
  80042f:	50                   	push   %eax
  800430:	68 7f 0d 80 00       	push   $0x800d7f
  800435:	53                   	push   %ebx
  800436:	56                   	push   %esi
  800437:	e8 b6 fe ff ff       	call   8002f2 <printfmt>
  80043c:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80043f:	89 7d 14             	mov    %edi,0x14(%ebp)
  800442:	e9 37 02 00 00       	jmp    80067e <vprintfmt+0x36f>
  800447:	f7 d8                	neg    %eax
  800449:	eb d2                	jmp    80041d <vprintfmt+0x10e>
				printfmt(putch, putdat, "error %d", err);
  80044b:	52                   	push   %edx
  80044c:	68 76 0d 80 00       	push   $0x800d76
  800451:	53                   	push   %ebx
  800452:	56                   	push   %esi
  800453:	e8 9a fe ff ff       	call   8002f2 <printfmt>
  800458:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80045b:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  80045e:	e9 1b 02 00 00       	jmp    80067e <vprintfmt+0x36f>
			if ((p = va_arg(ap, char *)) == NULL)
  800463:	8b 45 14             	mov    0x14(%ebp),%eax
  800466:	83 c0 04             	add    $0x4,%eax
  800469:	89 45 c8             	mov    %eax,-0x38(%ebp)
  80046c:	8b 45 14             	mov    0x14(%ebp),%eax
  80046f:	8b 00                	mov    (%eax),%eax
  800471:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800474:	85 c0                	test   %eax,%eax
  800476:	74 19                	je     800491 <vprintfmt+0x182>
			if (width > 0 && padc != '-')
  800478:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80047c:	7e 06                	jle    800484 <vprintfmt+0x175>
  80047e:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  800482:	75 16                	jne    80049a <vprintfmt+0x18b>
				for (width -= strnlen(p, precision); width > 0; width--)
  800484:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800487:	89 c7                	mov    %eax,%edi
  800489:	03 45 d4             	add    -0x2c(%ebp),%eax
  80048c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80048f:	eb 62                	jmp    8004f3 <vprintfmt+0x1e4>
				p = "(null)";
  800491:	c7 45 cc 6f 0d 80 00 	movl   $0x800d6f,-0x34(%ebp)
  800498:	eb de                	jmp    800478 <vprintfmt+0x169>
				for (width -= strnlen(p, precision); width > 0; width--)
  80049a:	83 ec 08             	sub    $0x8,%esp
  80049d:	ff 75 d8             	pushl  -0x28(%ebp)
  8004a0:	ff 75 cc             	pushl  -0x34(%ebp)
  8004a3:	e8 05 03 00 00       	call   8007ad <strnlen>
  8004a8:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8004ab:	29 c2                	sub    %eax,%edx
  8004ad:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  8004b0:	83 c4 10             	add    $0x10,%esp
  8004b3:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  8004b5:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8004b9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8004bc:	eb 0d                	jmp    8004cb <vprintfmt+0x1bc>
					putch(padc, putdat);
  8004be:	83 ec 08             	sub    $0x8,%esp
  8004c1:	53                   	push   %ebx
  8004c2:	ff 75 d4             	pushl  -0x2c(%ebp)
  8004c5:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8004c7:	4f                   	dec    %edi
  8004c8:	83 c4 10             	add    $0x10,%esp
  8004cb:	85 ff                	test   %edi,%edi
  8004cd:	7f ef                	jg     8004be <vprintfmt+0x1af>
  8004cf:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8004d2:	89 d0                	mov    %edx,%eax
  8004d4:	85 d2                	test   %edx,%edx
  8004d6:	78 0a                	js     8004e2 <vprintfmt+0x1d3>
  8004d8:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8004db:	29 c2                	sub    %eax,%edx
  8004dd:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8004e0:	eb a2                	jmp    800484 <vprintfmt+0x175>
  8004e2:	b8 00 00 00 00       	mov    $0x0,%eax
  8004e7:	eb ef                	jmp    8004d8 <vprintfmt+0x1c9>
					putch(ch, putdat);
  8004e9:	83 ec 08             	sub    $0x8,%esp
  8004ec:	53                   	push   %ebx
  8004ed:	52                   	push   %edx
  8004ee:	ff d6                	call   *%esi
  8004f0:	83 c4 10             	add    $0x10,%esp
  8004f3:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  8004f6:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004f8:	47                   	inc    %edi
  8004f9:	8a 47 ff             	mov    -0x1(%edi),%al
  8004fc:	0f be d0             	movsbl %al,%edx
  8004ff:	85 d2                	test   %edx,%edx
  800501:	74 48                	je     80054b <vprintfmt+0x23c>
  800503:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800507:	78 05                	js     80050e <vprintfmt+0x1ff>
  800509:	ff 4d d8             	decl   -0x28(%ebp)
  80050c:	78 1e                	js     80052c <vprintfmt+0x21d>
				if (altflag && (ch < ' ' || ch > '~'))
  80050e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800512:	74 d5                	je     8004e9 <vprintfmt+0x1da>
  800514:	0f be c0             	movsbl %al,%eax
  800517:	83 e8 20             	sub    $0x20,%eax
  80051a:	83 f8 5e             	cmp    $0x5e,%eax
  80051d:	76 ca                	jbe    8004e9 <vprintfmt+0x1da>
					putch('?', putdat);
  80051f:	83 ec 08             	sub    $0x8,%esp
  800522:	53                   	push   %ebx
  800523:	6a 3f                	push   $0x3f
  800525:	ff d6                	call   *%esi
  800527:	83 c4 10             	add    $0x10,%esp
  80052a:	eb c7                	jmp    8004f3 <vprintfmt+0x1e4>
  80052c:	89 cf                	mov    %ecx,%edi
  80052e:	eb 0c                	jmp    80053c <vprintfmt+0x22d>
				putch(' ', putdat);
  800530:	83 ec 08             	sub    $0x8,%esp
  800533:	53                   	push   %ebx
  800534:	6a 20                	push   $0x20
  800536:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800538:	4f                   	dec    %edi
  800539:	83 c4 10             	add    $0x10,%esp
  80053c:	85 ff                	test   %edi,%edi
  80053e:	7f f0                	jg     800530 <vprintfmt+0x221>
			if ((p = va_arg(ap, char *)) == NULL)
  800540:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800543:	89 45 14             	mov    %eax,0x14(%ebp)
  800546:	e9 33 01 00 00       	jmp    80067e <vprintfmt+0x36f>
  80054b:	89 cf                	mov    %ecx,%edi
  80054d:	eb ed                	jmp    80053c <vprintfmt+0x22d>
	if (lflag >= 2)
  80054f:	83 f9 01             	cmp    $0x1,%ecx
  800552:	7f 1b                	jg     80056f <vprintfmt+0x260>
	else if (lflag)
  800554:	85 c9                	test   %ecx,%ecx
  800556:	74 42                	je     80059a <vprintfmt+0x28b>
		return va_arg(*ap, long);
  800558:	8b 45 14             	mov    0x14(%ebp),%eax
  80055b:	8b 00                	mov    (%eax),%eax
  80055d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800560:	99                   	cltd   
  800561:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800564:	8b 45 14             	mov    0x14(%ebp),%eax
  800567:	8d 40 04             	lea    0x4(%eax),%eax
  80056a:	89 45 14             	mov    %eax,0x14(%ebp)
  80056d:	eb 17                	jmp    800586 <vprintfmt+0x277>
		return va_arg(*ap, long long);
  80056f:	8b 45 14             	mov    0x14(%ebp),%eax
  800572:	8b 50 04             	mov    0x4(%eax),%edx
  800575:	8b 00                	mov    (%eax),%eax
  800577:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80057a:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80057d:	8b 45 14             	mov    0x14(%ebp),%eax
  800580:	8d 40 08             	lea    0x8(%eax),%eax
  800583:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800586:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800589:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80058c:	85 c9                	test   %ecx,%ecx
  80058e:	78 21                	js     8005b1 <vprintfmt+0x2a2>
			base = 10;
  800590:	b8 0a 00 00 00       	mov    $0xa,%eax
  800595:	e9 ca 00 00 00       	jmp    800664 <vprintfmt+0x355>
		return va_arg(*ap, int);
  80059a:	8b 45 14             	mov    0x14(%ebp),%eax
  80059d:	8b 00                	mov    (%eax),%eax
  80059f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005a2:	99                   	cltd   
  8005a3:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005a6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a9:	8d 40 04             	lea    0x4(%eax),%eax
  8005ac:	89 45 14             	mov    %eax,0x14(%ebp)
  8005af:	eb d5                	jmp    800586 <vprintfmt+0x277>
				putch('-', putdat);
  8005b1:	83 ec 08             	sub    $0x8,%esp
  8005b4:	53                   	push   %ebx
  8005b5:	6a 2d                	push   $0x2d
  8005b7:	ff d6                	call   *%esi
				num = -(long long) num;
  8005b9:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005bc:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8005bf:	f7 da                	neg    %edx
  8005c1:	83 d1 00             	adc    $0x0,%ecx
  8005c4:	f7 d9                	neg    %ecx
  8005c6:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8005c9:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005ce:	e9 91 00 00 00       	jmp    800664 <vprintfmt+0x355>
	if (lflag >= 2)
  8005d3:	83 f9 01             	cmp    $0x1,%ecx
  8005d6:	7f 1b                	jg     8005f3 <vprintfmt+0x2e4>
	else if (lflag)
  8005d8:	85 c9                	test   %ecx,%ecx
  8005da:	74 2c                	je     800608 <vprintfmt+0x2f9>
		return va_arg(*ap, unsigned long);
  8005dc:	8b 45 14             	mov    0x14(%ebp),%eax
  8005df:	8b 10                	mov    (%eax),%edx
  8005e1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005e6:	8d 40 04             	lea    0x4(%eax),%eax
  8005e9:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005ec:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  8005f1:	eb 71                	jmp    800664 <vprintfmt+0x355>
		return va_arg(*ap, unsigned long long);
  8005f3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f6:	8b 10                	mov    (%eax),%edx
  8005f8:	8b 48 04             	mov    0x4(%eax),%ecx
  8005fb:	8d 40 08             	lea    0x8(%eax),%eax
  8005fe:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800601:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  800606:	eb 5c                	jmp    800664 <vprintfmt+0x355>
		return va_arg(*ap, unsigned int);
  800608:	8b 45 14             	mov    0x14(%ebp),%eax
  80060b:	8b 10                	mov    (%eax),%edx
  80060d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800612:	8d 40 04             	lea    0x4(%eax),%eax
  800615:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800618:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  80061d:	eb 45                	jmp    800664 <vprintfmt+0x355>
			putch('X', putdat);
  80061f:	83 ec 08             	sub    $0x8,%esp
  800622:	53                   	push   %ebx
  800623:	6a 58                	push   $0x58
  800625:	ff d6                	call   *%esi
			putch('X', putdat);
  800627:	83 c4 08             	add    $0x8,%esp
  80062a:	53                   	push   %ebx
  80062b:	6a 58                	push   $0x58
  80062d:	ff d6                	call   *%esi
			putch('X', putdat);
  80062f:	83 c4 08             	add    $0x8,%esp
  800632:	53                   	push   %ebx
  800633:	6a 58                	push   $0x58
  800635:	ff d6                	call   *%esi
			break;
  800637:	83 c4 10             	add    $0x10,%esp
  80063a:	eb 42                	jmp    80067e <vprintfmt+0x36f>
			putch('0', putdat);
  80063c:	83 ec 08             	sub    $0x8,%esp
  80063f:	53                   	push   %ebx
  800640:	6a 30                	push   $0x30
  800642:	ff d6                	call   *%esi
			putch('x', putdat);
  800644:	83 c4 08             	add    $0x8,%esp
  800647:	53                   	push   %ebx
  800648:	6a 78                	push   $0x78
  80064a:	ff d6                	call   *%esi
			num = (unsigned long long)
  80064c:	8b 45 14             	mov    0x14(%ebp),%eax
  80064f:	8b 10                	mov    (%eax),%edx
  800651:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800656:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800659:	8d 40 04             	lea    0x4(%eax),%eax
  80065c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80065f:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  800664:	83 ec 0c             	sub    $0xc,%esp
  800667:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  80066b:	57                   	push   %edi
  80066c:	ff 75 d4             	pushl  -0x2c(%ebp)
  80066f:	50                   	push   %eax
  800670:	51                   	push   %ecx
  800671:	52                   	push   %edx
  800672:	89 da                	mov    %ebx,%edx
  800674:	89 f0                	mov    %esi,%eax
  800676:	e8 b6 fb ff ff       	call   800231 <printnum>
			break;
  80067b:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  80067e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800681:	47                   	inc    %edi
  800682:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800686:	83 f8 25             	cmp    $0x25,%eax
  800689:	0f 84 97 fc ff ff    	je     800326 <vprintfmt+0x17>
			if (ch == '\0')
  80068f:	85 c0                	test   %eax,%eax
  800691:	0f 84 89 00 00 00    	je     800720 <vprintfmt+0x411>
			putch(ch, putdat);
  800697:	83 ec 08             	sub    $0x8,%esp
  80069a:	53                   	push   %ebx
  80069b:	50                   	push   %eax
  80069c:	ff d6                	call   *%esi
  80069e:	83 c4 10             	add    $0x10,%esp
  8006a1:	eb de                	jmp    800681 <vprintfmt+0x372>
	if (lflag >= 2)
  8006a3:	83 f9 01             	cmp    $0x1,%ecx
  8006a6:	7f 1b                	jg     8006c3 <vprintfmt+0x3b4>
	else if (lflag)
  8006a8:	85 c9                	test   %ecx,%ecx
  8006aa:	74 2c                	je     8006d8 <vprintfmt+0x3c9>
		return va_arg(*ap, unsigned long);
  8006ac:	8b 45 14             	mov    0x14(%ebp),%eax
  8006af:	8b 10                	mov    (%eax),%edx
  8006b1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006b6:	8d 40 04             	lea    0x4(%eax),%eax
  8006b9:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006bc:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  8006c1:	eb a1                	jmp    800664 <vprintfmt+0x355>
		return va_arg(*ap, unsigned long long);
  8006c3:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c6:	8b 10                	mov    (%eax),%edx
  8006c8:	8b 48 04             	mov    0x4(%eax),%ecx
  8006cb:	8d 40 08             	lea    0x8(%eax),%eax
  8006ce:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006d1:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  8006d6:	eb 8c                	jmp    800664 <vprintfmt+0x355>
		return va_arg(*ap, unsigned int);
  8006d8:	8b 45 14             	mov    0x14(%ebp),%eax
  8006db:	8b 10                	mov    (%eax),%edx
  8006dd:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006e2:	8d 40 04             	lea    0x4(%eax),%eax
  8006e5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006e8:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  8006ed:	e9 72 ff ff ff       	jmp    800664 <vprintfmt+0x355>
			putch(ch, putdat);
  8006f2:	83 ec 08             	sub    $0x8,%esp
  8006f5:	53                   	push   %ebx
  8006f6:	6a 25                	push   $0x25
  8006f8:	ff d6                	call   *%esi
			break;
  8006fa:	83 c4 10             	add    $0x10,%esp
  8006fd:	e9 7c ff ff ff       	jmp    80067e <vprintfmt+0x36f>
			putch('%', putdat);
  800702:	83 ec 08             	sub    $0x8,%esp
  800705:	53                   	push   %ebx
  800706:	6a 25                	push   $0x25
  800708:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80070a:	83 c4 10             	add    $0x10,%esp
  80070d:	89 f8                	mov    %edi,%eax
  80070f:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800713:	74 03                	je     800718 <vprintfmt+0x409>
  800715:	48                   	dec    %eax
  800716:	eb f7                	jmp    80070f <vprintfmt+0x400>
  800718:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80071b:	e9 5e ff ff ff       	jmp    80067e <vprintfmt+0x36f>
}
  800720:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800723:	5b                   	pop    %ebx
  800724:	5e                   	pop    %esi
  800725:	5f                   	pop    %edi
  800726:	5d                   	pop    %ebp
  800727:	c3                   	ret    

00800728 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800728:	55                   	push   %ebp
  800729:	89 e5                	mov    %esp,%ebp
  80072b:	83 ec 18             	sub    $0x18,%esp
  80072e:	8b 45 08             	mov    0x8(%ebp),%eax
  800731:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800734:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800737:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80073b:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80073e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800745:	85 c0                	test   %eax,%eax
  800747:	74 26                	je     80076f <vsnprintf+0x47>
  800749:	85 d2                	test   %edx,%edx
  80074b:	7e 29                	jle    800776 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80074d:	ff 75 14             	pushl  0x14(%ebp)
  800750:	ff 75 10             	pushl  0x10(%ebp)
  800753:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800756:	50                   	push   %eax
  800757:	68 d6 02 80 00       	push   $0x8002d6
  80075c:	e8 ae fb ff ff       	call   80030f <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800761:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800764:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800767:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80076a:	83 c4 10             	add    $0x10,%esp
}
  80076d:	c9                   	leave  
  80076e:	c3                   	ret    
		return -E_INVAL;
  80076f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800774:	eb f7                	jmp    80076d <vsnprintf+0x45>
  800776:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80077b:	eb f0                	jmp    80076d <vsnprintf+0x45>

0080077d <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80077d:	55                   	push   %ebp
  80077e:	89 e5                	mov    %esp,%ebp
  800780:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800783:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800786:	50                   	push   %eax
  800787:	ff 75 10             	pushl  0x10(%ebp)
  80078a:	ff 75 0c             	pushl  0xc(%ebp)
  80078d:	ff 75 08             	pushl  0x8(%ebp)
  800790:	e8 93 ff ff ff       	call   800728 <vsnprintf>
	va_end(ap);

	return rc;
}
  800795:	c9                   	leave  
  800796:	c3                   	ret    

00800797 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800797:	55                   	push   %ebp
  800798:	89 e5                	mov    %esp,%ebp
  80079a:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80079d:	b8 00 00 00 00       	mov    $0x0,%eax
  8007a2:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007a6:	74 03                	je     8007ab <strlen+0x14>
		n++;
  8007a8:	40                   	inc    %eax
  8007a9:	eb f7                	jmp    8007a2 <strlen+0xb>
	return n;
}
  8007ab:	5d                   	pop    %ebp
  8007ac:	c3                   	ret    

008007ad <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007ad:	55                   	push   %ebp
  8007ae:	89 e5                	mov    %esp,%ebp
  8007b0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007b3:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007b6:	b8 00 00 00 00       	mov    $0x0,%eax
  8007bb:	39 d0                	cmp    %edx,%eax
  8007bd:	74 0b                	je     8007ca <strnlen+0x1d>
  8007bf:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007c3:	74 03                	je     8007c8 <strnlen+0x1b>
		n++;
  8007c5:	40                   	inc    %eax
  8007c6:	eb f3                	jmp    8007bb <strnlen+0xe>
  8007c8:	89 c2                	mov    %eax,%edx
	return n;
}
  8007ca:	89 d0                	mov    %edx,%eax
  8007cc:	5d                   	pop    %ebp
  8007cd:	c3                   	ret    

008007ce <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007ce:	55                   	push   %ebp
  8007cf:	89 e5                	mov    %esp,%ebp
  8007d1:	53                   	push   %ebx
  8007d2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007d5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007d8:	b8 00 00 00 00       	mov    $0x0,%eax
  8007dd:	8a 14 03             	mov    (%ebx,%eax,1),%dl
  8007e0:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8007e3:	40                   	inc    %eax
  8007e4:	84 d2                	test   %dl,%dl
  8007e6:	75 f5                	jne    8007dd <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8007e8:	89 c8                	mov    %ecx,%eax
  8007ea:	5b                   	pop    %ebx
  8007eb:	5d                   	pop    %ebp
  8007ec:	c3                   	ret    

008007ed <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007ed:	55                   	push   %ebp
  8007ee:	89 e5                	mov    %esp,%ebp
  8007f0:	53                   	push   %ebx
  8007f1:	83 ec 10             	sub    $0x10,%esp
  8007f4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007f7:	53                   	push   %ebx
  8007f8:	e8 9a ff ff ff       	call   800797 <strlen>
  8007fd:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800800:	ff 75 0c             	pushl  0xc(%ebp)
  800803:	01 d8                	add    %ebx,%eax
  800805:	50                   	push   %eax
  800806:	e8 c3 ff ff ff       	call   8007ce <strcpy>
	return dst;
}
  80080b:	89 d8                	mov    %ebx,%eax
  80080d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800810:	c9                   	leave  
  800811:	c3                   	ret    

00800812 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800812:	55                   	push   %ebp
  800813:	89 e5                	mov    %esp,%ebp
  800815:	53                   	push   %ebx
  800816:	8b 55 0c             	mov    0xc(%ebp),%edx
  800819:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80081c:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80081f:	8b 45 08             	mov    0x8(%ebp),%eax
  800822:	39 d8                	cmp    %ebx,%eax
  800824:	74 0e                	je     800834 <strncpy+0x22>
		*dst++ = *src;
  800826:	40                   	inc    %eax
  800827:	8a 0a                	mov    (%edx),%cl
  800829:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80082c:	80 f9 01             	cmp    $0x1,%cl
  80082f:	83 da ff             	sbb    $0xffffffff,%edx
  800832:	eb ee                	jmp    800822 <strncpy+0x10>
	}
	return ret;
}
  800834:	8b 45 08             	mov    0x8(%ebp),%eax
  800837:	5b                   	pop    %ebx
  800838:	5d                   	pop    %ebp
  800839:	c3                   	ret    

0080083a <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80083a:	55                   	push   %ebp
  80083b:	89 e5                	mov    %esp,%ebp
  80083d:	56                   	push   %esi
  80083e:	53                   	push   %ebx
  80083f:	8b 75 08             	mov    0x8(%ebp),%esi
  800842:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800845:	8b 45 10             	mov    0x10(%ebp),%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800848:	85 c0                	test   %eax,%eax
  80084a:	74 22                	je     80086e <strlcpy+0x34>
  80084c:	8d 44 06 ff          	lea    -0x1(%esi,%eax,1),%eax
  800850:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  800852:	39 c2                	cmp    %eax,%edx
  800854:	74 0f                	je     800865 <strlcpy+0x2b>
  800856:	8a 19                	mov    (%ecx),%bl
  800858:	84 db                	test   %bl,%bl
  80085a:	74 07                	je     800863 <strlcpy+0x29>
			*dst++ = *src++;
  80085c:	41                   	inc    %ecx
  80085d:	42                   	inc    %edx
  80085e:	88 5a ff             	mov    %bl,-0x1(%edx)
  800861:	eb ef                	jmp    800852 <strlcpy+0x18>
  800863:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800865:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800868:	29 f0                	sub    %esi,%eax
}
  80086a:	5b                   	pop    %ebx
  80086b:	5e                   	pop    %esi
  80086c:	5d                   	pop    %ebp
  80086d:	c3                   	ret    
  80086e:	89 f0                	mov    %esi,%eax
  800870:	eb f6                	jmp    800868 <strlcpy+0x2e>

00800872 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800872:	55                   	push   %ebp
  800873:	89 e5                	mov    %esp,%ebp
  800875:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800878:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80087b:	8a 01                	mov    (%ecx),%al
  80087d:	84 c0                	test   %al,%al
  80087f:	74 08                	je     800889 <strcmp+0x17>
  800881:	3a 02                	cmp    (%edx),%al
  800883:	75 04                	jne    800889 <strcmp+0x17>
		p++, q++;
  800885:	41                   	inc    %ecx
  800886:	42                   	inc    %edx
  800887:	eb f2                	jmp    80087b <strcmp+0x9>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800889:	0f b6 c0             	movzbl %al,%eax
  80088c:	0f b6 12             	movzbl (%edx),%edx
  80088f:	29 d0                	sub    %edx,%eax
}
  800891:	5d                   	pop    %ebp
  800892:	c3                   	ret    

00800893 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800893:	55                   	push   %ebp
  800894:	89 e5                	mov    %esp,%ebp
  800896:	53                   	push   %ebx
  800897:	8b 45 08             	mov    0x8(%ebp),%eax
  80089a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80089d:	89 c3                	mov    %eax,%ebx
  80089f:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008a2:	eb 02                	jmp    8008a6 <strncmp+0x13>
		n--, p++, q++;
  8008a4:	40                   	inc    %eax
  8008a5:	42                   	inc    %edx
	while (n > 0 && *p && *p == *q)
  8008a6:	39 d8                	cmp    %ebx,%eax
  8008a8:	74 15                	je     8008bf <strncmp+0x2c>
  8008aa:	8a 08                	mov    (%eax),%cl
  8008ac:	84 c9                	test   %cl,%cl
  8008ae:	74 04                	je     8008b4 <strncmp+0x21>
  8008b0:	3a 0a                	cmp    (%edx),%cl
  8008b2:	74 f0                	je     8008a4 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008b4:	0f b6 00             	movzbl (%eax),%eax
  8008b7:	0f b6 12             	movzbl (%edx),%edx
  8008ba:	29 d0                	sub    %edx,%eax
}
  8008bc:	5b                   	pop    %ebx
  8008bd:	5d                   	pop    %ebp
  8008be:	c3                   	ret    
		return 0;
  8008bf:	b8 00 00 00 00       	mov    $0x0,%eax
  8008c4:	eb f6                	jmp    8008bc <strncmp+0x29>

008008c6 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008c6:	55                   	push   %ebp
  8008c7:	89 e5                	mov    %esp,%ebp
  8008c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8008cc:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8008cf:	8a 10                	mov    (%eax),%dl
  8008d1:	84 d2                	test   %dl,%dl
  8008d3:	74 07                	je     8008dc <strchr+0x16>
		if (*s == c)
  8008d5:	38 ca                	cmp    %cl,%dl
  8008d7:	74 08                	je     8008e1 <strchr+0x1b>
	for (; *s; s++)
  8008d9:	40                   	inc    %eax
  8008da:	eb f3                	jmp    8008cf <strchr+0x9>
			return (char *) s;
	return 0;
  8008dc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008e1:	5d                   	pop    %ebp
  8008e2:	c3                   	ret    

008008e3 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008e3:	55                   	push   %ebp
  8008e4:	89 e5                	mov    %esp,%ebp
  8008e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e9:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8008ec:	8a 10                	mov    (%eax),%dl
  8008ee:	84 d2                	test   %dl,%dl
  8008f0:	74 07                	je     8008f9 <strfind+0x16>
		if (*s == c)
  8008f2:	38 ca                	cmp    %cl,%dl
  8008f4:	74 03                	je     8008f9 <strfind+0x16>
	for (; *s; s++)
  8008f6:	40                   	inc    %eax
  8008f7:	eb f3                	jmp    8008ec <strfind+0x9>
			break;
	return (char *) s;
}
  8008f9:	5d                   	pop    %ebp
  8008fa:	c3                   	ret    

008008fb <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008fb:	55                   	push   %ebp
  8008fc:	89 e5                	mov    %esp,%ebp
  8008fe:	57                   	push   %edi
  8008ff:	56                   	push   %esi
  800900:	53                   	push   %ebx
  800901:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800904:	85 c9                	test   %ecx,%ecx
  800906:	74 36                	je     80093e <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800908:	89 c8                	mov    %ecx,%eax
  80090a:	0b 45 08             	or     0x8(%ebp),%eax
  80090d:	a8 03                	test   $0x3,%al
  80090f:	75 24                	jne    800935 <memset+0x3a>
		c &= 0xFF;
  800911:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800915:	89 d3                	mov    %edx,%ebx
  800917:	c1 e3 08             	shl    $0x8,%ebx
  80091a:	89 d0                	mov    %edx,%eax
  80091c:	c1 e0 18             	shl    $0x18,%eax
  80091f:	89 d6                	mov    %edx,%esi
  800921:	c1 e6 10             	shl    $0x10,%esi
  800924:	09 f0                	or     %esi,%eax
  800926:	09 d0                	or     %edx,%eax
  800928:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80092a:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  80092d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800930:	fc                   	cld    
  800931:	f3 ab                	rep stos %eax,%es:(%edi)
  800933:	eb 09                	jmp    80093e <memset+0x43>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800935:	8b 7d 08             	mov    0x8(%ebp),%edi
  800938:	8b 45 0c             	mov    0xc(%ebp),%eax
  80093b:	fc                   	cld    
  80093c:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80093e:	8b 45 08             	mov    0x8(%ebp),%eax
  800941:	5b                   	pop    %ebx
  800942:	5e                   	pop    %esi
  800943:	5f                   	pop    %edi
  800944:	5d                   	pop    %ebp
  800945:	c3                   	ret    

00800946 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800946:	55                   	push   %ebp
  800947:	89 e5                	mov    %esp,%ebp
  800949:	57                   	push   %edi
  80094a:	56                   	push   %esi
  80094b:	8b 45 08             	mov    0x8(%ebp),%eax
  80094e:	8b 75 0c             	mov    0xc(%ebp),%esi
  800951:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800954:	39 c6                	cmp    %eax,%esi
  800956:	73 30                	jae    800988 <memmove+0x42>
  800958:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80095b:	39 c2                	cmp    %eax,%edx
  80095d:	76 29                	jbe    800988 <memmove+0x42>
		s += n;
		d += n;
  80095f:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800962:	89 fe                	mov    %edi,%esi
  800964:	09 ce                	or     %ecx,%esi
  800966:	09 d6                	or     %edx,%esi
  800968:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80096e:	75 0e                	jne    80097e <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800970:	83 ef 04             	sub    $0x4,%edi
  800973:	8d 72 fc             	lea    -0x4(%edx),%esi
  800976:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800979:	fd                   	std    
  80097a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80097c:	eb 07                	jmp    800985 <memmove+0x3f>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80097e:	4f                   	dec    %edi
  80097f:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800982:	fd                   	std    
  800983:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800985:	fc                   	cld    
  800986:	eb 1a                	jmp    8009a2 <memmove+0x5c>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800988:	89 c2                	mov    %eax,%edx
  80098a:	09 ca                	or     %ecx,%edx
  80098c:	09 f2                	or     %esi,%edx
  80098e:	f6 c2 03             	test   $0x3,%dl
  800991:	75 0a                	jne    80099d <memmove+0x57>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800993:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800996:	89 c7                	mov    %eax,%edi
  800998:	fc                   	cld    
  800999:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80099b:	eb 05                	jmp    8009a2 <memmove+0x5c>
		else
			asm volatile("cld; rep movsb\n"
  80099d:	89 c7                	mov    %eax,%edi
  80099f:	fc                   	cld    
  8009a0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009a2:	5e                   	pop    %esi
  8009a3:	5f                   	pop    %edi
  8009a4:	5d                   	pop    %ebp
  8009a5:	c3                   	ret    

008009a6 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009a6:	55                   	push   %ebp
  8009a7:	89 e5                	mov    %esp,%ebp
  8009a9:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8009ac:	ff 75 10             	pushl  0x10(%ebp)
  8009af:	ff 75 0c             	pushl  0xc(%ebp)
  8009b2:	ff 75 08             	pushl  0x8(%ebp)
  8009b5:	e8 8c ff ff ff       	call   800946 <memmove>
}
  8009ba:	c9                   	leave  
  8009bb:	c3                   	ret    

008009bc <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009bc:	55                   	push   %ebp
  8009bd:	89 e5                	mov    %esp,%ebp
  8009bf:	56                   	push   %esi
  8009c0:	53                   	push   %ebx
  8009c1:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009c7:	89 c6                	mov    %eax,%esi
  8009c9:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009cc:	39 f0                	cmp    %esi,%eax
  8009ce:	74 16                	je     8009e6 <memcmp+0x2a>
		if (*s1 != *s2)
  8009d0:	8a 08                	mov    (%eax),%cl
  8009d2:	8a 1a                	mov    (%edx),%bl
  8009d4:	38 d9                	cmp    %bl,%cl
  8009d6:	75 04                	jne    8009dc <memcmp+0x20>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  8009d8:	40                   	inc    %eax
  8009d9:	42                   	inc    %edx
  8009da:	eb f0                	jmp    8009cc <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  8009dc:	0f b6 c1             	movzbl %cl,%eax
  8009df:	0f b6 db             	movzbl %bl,%ebx
  8009e2:	29 d8                	sub    %ebx,%eax
  8009e4:	eb 05                	jmp    8009eb <memcmp+0x2f>
	}

	return 0;
  8009e6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009eb:	5b                   	pop    %ebx
  8009ec:	5e                   	pop    %esi
  8009ed:	5d                   	pop    %ebp
  8009ee:	c3                   	ret    

008009ef <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009ef:	55                   	push   %ebp
  8009f0:	89 e5                	mov    %esp,%ebp
  8009f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8009f8:	89 c2                	mov    %eax,%edx
  8009fa:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8009fd:	39 d0                	cmp    %edx,%eax
  8009ff:	73 07                	jae    800a08 <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a01:	38 08                	cmp    %cl,(%eax)
  800a03:	74 03                	je     800a08 <memfind+0x19>
	for (; s < ends; s++)
  800a05:	40                   	inc    %eax
  800a06:	eb f5                	jmp    8009fd <memfind+0xe>
			break;
	return (void *) s;
}
  800a08:	5d                   	pop    %ebp
  800a09:	c3                   	ret    

00800a0a <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a0a:	55                   	push   %ebp
  800a0b:	89 e5                	mov    %esp,%ebp
  800a0d:	57                   	push   %edi
  800a0e:	56                   	push   %esi
  800a0f:	53                   	push   %ebx
  800a10:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a13:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a16:	eb 01                	jmp    800a19 <strtol+0xf>
		s++;
  800a18:	41                   	inc    %ecx
	while (*s == ' ' || *s == '\t')
  800a19:	8a 01                	mov    (%ecx),%al
  800a1b:	3c 20                	cmp    $0x20,%al
  800a1d:	74 f9                	je     800a18 <strtol+0xe>
  800a1f:	3c 09                	cmp    $0x9,%al
  800a21:	74 f5                	je     800a18 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800a23:	3c 2b                	cmp    $0x2b,%al
  800a25:	74 24                	je     800a4b <strtol+0x41>
		s++;
	else if (*s == '-')
  800a27:	3c 2d                	cmp    $0x2d,%al
  800a29:	74 28                	je     800a53 <strtol+0x49>
	int neg = 0;
  800a2b:	bf 00 00 00 00       	mov    $0x0,%edi
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a30:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a36:	75 09                	jne    800a41 <strtol+0x37>
  800a38:	80 39 30             	cmpb   $0x30,(%ecx)
  800a3b:	74 1e                	je     800a5b <strtol+0x51>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a3d:	85 db                	test   %ebx,%ebx
  800a3f:	74 36                	je     800a77 <strtol+0x6d>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a41:	b8 00 00 00 00       	mov    $0x0,%eax
  800a46:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800a49:	eb 45                	jmp    800a90 <strtol+0x86>
		s++;
  800a4b:	41                   	inc    %ecx
	int neg = 0;
  800a4c:	bf 00 00 00 00       	mov    $0x0,%edi
  800a51:	eb dd                	jmp    800a30 <strtol+0x26>
		s++, neg = 1;
  800a53:	41                   	inc    %ecx
  800a54:	bf 01 00 00 00       	mov    $0x1,%edi
  800a59:	eb d5                	jmp    800a30 <strtol+0x26>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a5b:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a5f:	74 0c                	je     800a6d <strtol+0x63>
	else if (base == 0 && s[0] == '0')
  800a61:	85 db                	test   %ebx,%ebx
  800a63:	75 dc                	jne    800a41 <strtol+0x37>
		s++, base = 8;
  800a65:	41                   	inc    %ecx
  800a66:	bb 08 00 00 00       	mov    $0x8,%ebx
  800a6b:	eb d4                	jmp    800a41 <strtol+0x37>
		s += 2, base = 16;
  800a6d:	83 c1 02             	add    $0x2,%ecx
  800a70:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a75:	eb ca                	jmp    800a41 <strtol+0x37>
		base = 10;
  800a77:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800a7c:	eb c3                	jmp    800a41 <strtol+0x37>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800a7e:	0f be d2             	movsbl %dl,%edx
  800a81:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800a84:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a87:	7d 37                	jge    800ac0 <strtol+0xb6>
			break;
		s++, val = (val * base) + dig;
  800a89:	41                   	inc    %ecx
  800a8a:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a8e:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800a90:	8a 11                	mov    (%ecx),%dl
  800a92:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a95:	89 f3                	mov    %esi,%ebx
  800a97:	80 fb 09             	cmp    $0x9,%bl
  800a9a:	76 e2                	jbe    800a7e <strtol+0x74>
		else if (*s >= 'a' && *s <= 'z')
  800a9c:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a9f:	89 f3                	mov    %esi,%ebx
  800aa1:	80 fb 19             	cmp    $0x19,%bl
  800aa4:	77 08                	ja     800aae <strtol+0xa4>
			dig = *s - 'a' + 10;
  800aa6:	0f be d2             	movsbl %dl,%edx
  800aa9:	83 ea 57             	sub    $0x57,%edx
  800aac:	eb d6                	jmp    800a84 <strtol+0x7a>
		else if (*s >= 'A' && *s <= 'Z')
  800aae:	8d 72 bf             	lea    -0x41(%edx),%esi
  800ab1:	89 f3                	mov    %esi,%ebx
  800ab3:	80 fb 19             	cmp    $0x19,%bl
  800ab6:	77 08                	ja     800ac0 <strtol+0xb6>
			dig = *s - 'A' + 10;
  800ab8:	0f be d2             	movsbl %dl,%edx
  800abb:	83 ea 37             	sub    $0x37,%edx
  800abe:	eb c4                	jmp    800a84 <strtol+0x7a>
		// we don't properly detect overflow!
	}

	if (endptr)
  800ac0:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ac4:	74 05                	je     800acb <strtol+0xc1>
		*endptr = (char *) s;
  800ac6:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ac9:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800acb:	85 ff                	test   %edi,%edi
  800acd:	74 02                	je     800ad1 <strtol+0xc7>
  800acf:	f7 d8                	neg    %eax
}
  800ad1:	5b                   	pop    %ebx
  800ad2:	5e                   	pop    %esi
  800ad3:	5f                   	pop    %edi
  800ad4:	5d                   	pop    %ebp
  800ad5:	c3                   	ret    
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
