
obj/user/evilhello:     file format elf32-i386


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
  80002c:	e8 19 00 00 00       	call   80004a <libmain>
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
	// try to print the kernel entry point as a string!  mua ha ha!
	sys_cputs((char*)0xf010000c, 100);
  800039:	6a 64                	push   $0x64
  80003b:	68 0c 00 10 f0       	push   $0xf010000c
  800040:	e8 76 00 00 00       	call   8000bb <sys_cputs>
}
  800045:	83 c4 10             	add    $0x10,%esp
  800048:	c9                   	leave  
  800049:	c3                   	ret    

0080004a <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80004a:	55                   	push   %ebp
  80004b:	89 e5                	mov    %esp,%ebp
  80004d:	57                   	push   %edi
  80004e:	56                   	push   %esi
  80004f:	53                   	push   %ebx
  800050:	83 ec 6c             	sub    $0x6c,%esp
  800053:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	struct Env curenv = envs[ENVX(sys_getenvid())];
  800056:	e8 de 00 00 00       	call   800139 <sys_getenvid>
  80005b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800060:	8d 34 00             	lea    (%eax,%eax,1),%esi
  800063:	01 c6                	add    %eax,%esi
  800065:	c1 e6 05             	shl    $0x5,%esi
  800068:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  80006e:	8d 7d 88             	lea    -0x78(%ebp),%edi
  800071:	b9 18 00 00 00       	mov    $0x18,%ecx
  800076:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	thisenv = &curenv;
  800078:	8d 45 88             	lea    -0x78(%ebp),%eax
  80007b:	a3 04 10 80 00       	mov    %eax,0x801004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800080:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800084:	7e 07                	jle    80008d <libmain+0x43>
		binaryname = argv[0];
  800086:	8b 03                	mov    (%ebx),%eax
  800088:	a3 00 10 80 00       	mov    %eax,0x801000
	
	// call user main routine
	umain(argc, argv);
  80008d:	83 ec 08             	sub    $0x8,%esp
  800090:	53                   	push   %ebx
  800091:	ff 75 08             	pushl  0x8(%ebp)
  800094:	e8 9a ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800099:	e8 0b 00 00 00       	call   8000a9 <exit>
}
  80009e:	83 c4 10             	add    $0x10,%esp
  8000a1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000a4:	5b                   	pop    %ebx
  8000a5:	5e                   	pop    %esi
  8000a6:	5f                   	pop    %edi
  8000a7:	5d                   	pop    %ebp
  8000a8:	c3                   	ret    

008000a9 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000a9:	55                   	push   %ebp
  8000aa:	89 e5                	mov    %esp,%ebp
  8000ac:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8000af:	6a 00                	push   $0x0
  8000b1:	e8 42 00 00 00       	call   8000f8 <sys_env_destroy>
}
  8000b6:	83 c4 10             	add    $0x10,%esp
  8000b9:	c9                   	leave  
  8000ba:	c3                   	ret    

008000bb <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000bb:	55                   	push   %ebp
  8000bc:	89 e5                	mov    %esp,%ebp
  8000be:	57                   	push   %edi
  8000bf:	56                   	push   %esi
  8000c0:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000c1:	b8 00 00 00 00       	mov    $0x0,%eax
  8000c6:	8b 55 08             	mov    0x8(%ebp),%edx
  8000c9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000cc:	89 c3                	mov    %eax,%ebx
  8000ce:	89 c7                	mov    %eax,%edi
  8000d0:	89 c6                	mov    %eax,%esi
  8000d2:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000d4:	5b                   	pop    %ebx
  8000d5:	5e                   	pop    %esi
  8000d6:	5f                   	pop    %edi
  8000d7:	5d                   	pop    %ebp
  8000d8:	c3                   	ret    

008000d9 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000d9:	55                   	push   %ebp
  8000da:	89 e5                	mov    %esp,%ebp
  8000dc:	57                   	push   %edi
  8000dd:	56                   	push   %esi
  8000de:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000df:	ba 00 00 00 00       	mov    $0x0,%edx
  8000e4:	b8 01 00 00 00       	mov    $0x1,%eax
  8000e9:	89 d1                	mov    %edx,%ecx
  8000eb:	89 d3                	mov    %edx,%ebx
  8000ed:	89 d7                	mov    %edx,%edi
  8000ef:	89 d6                	mov    %edx,%esi
  8000f1:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000f3:	5b                   	pop    %ebx
  8000f4:	5e                   	pop    %esi
  8000f5:	5f                   	pop    %edi
  8000f6:	5d                   	pop    %ebp
  8000f7:	c3                   	ret    

008000f8 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000f8:	55                   	push   %ebp
  8000f9:	89 e5                	mov    %esp,%ebp
  8000fb:	57                   	push   %edi
  8000fc:	56                   	push   %esi
  8000fd:	53                   	push   %ebx
  8000fe:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800101:	b9 00 00 00 00       	mov    $0x0,%ecx
  800106:	8b 55 08             	mov    0x8(%ebp),%edx
  800109:	b8 03 00 00 00       	mov    $0x3,%eax
  80010e:	89 cb                	mov    %ecx,%ebx
  800110:	89 cf                	mov    %ecx,%edi
  800112:	89 ce                	mov    %ecx,%esi
  800114:	cd 30                	int    $0x30
	if(check && ret > 0)
  800116:	85 c0                	test   %eax,%eax
  800118:	7f 08                	jg     800122 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80011a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80011d:	5b                   	pop    %ebx
  80011e:	5e                   	pop    %esi
  80011f:	5f                   	pop    %edi
  800120:	5d                   	pop    %ebp
  800121:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800122:	83 ec 0c             	sub    $0xc,%esp
  800125:	50                   	push   %eax
  800126:	6a 03                	push   $0x3
  800128:	68 1e 0d 80 00       	push   $0x800d1e
  80012d:	6a 23                	push   $0x23
  80012f:	68 3b 0d 80 00       	push   $0x800d3b
  800134:	e8 1f 00 00 00       	call   800158 <_panic>

00800139 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800139:	55                   	push   %ebp
  80013a:	89 e5                	mov    %esp,%ebp
  80013c:	57                   	push   %edi
  80013d:	56                   	push   %esi
  80013e:	53                   	push   %ebx
	asm volatile("int %1\n"
  80013f:	ba 00 00 00 00       	mov    $0x0,%edx
  800144:	b8 02 00 00 00       	mov    $0x2,%eax
  800149:	89 d1                	mov    %edx,%ecx
  80014b:	89 d3                	mov    %edx,%ebx
  80014d:	89 d7                	mov    %edx,%edi
  80014f:	89 d6                	mov    %edx,%esi
  800151:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800153:	5b                   	pop    %ebx
  800154:	5e                   	pop    %esi
  800155:	5f                   	pop    %edi
  800156:	5d                   	pop    %ebp
  800157:	c3                   	ret    

00800158 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800158:	55                   	push   %ebp
  800159:	89 e5                	mov    %esp,%ebp
  80015b:	56                   	push   %esi
  80015c:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80015d:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800160:	8b 35 00 10 80 00    	mov    0x801000,%esi
  800166:	e8 ce ff ff ff       	call   800139 <sys_getenvid>
  80016b:	83 ec 0c             	sub    $0xc,%esp
  80016e:	ff 75 0c             	pushl  0xc(%ebp)
  800171:	ff 75 08             	pushl  0x8(%ebp)
  800174:	56                   	push   %esi
  800175:	50                   	push   %eax
  800176:	68 4c 0d 80 00       	push   $0x800d4c
  80017b:	e8 b2 00 00 00       	call   800232 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800180:	83 c4 18             	add    $0x18,%esp
  800183:	53                   	push   %ebx
  800184:	ff 75 10             	pushl  0x10(%ebp)
  800187:	e8 55 00 00 00       	call   8001e1 <vcprintf>
	cprintf("\n");
  80018c:	c7 04 24 70 0d 80 00 	movl   $0x800d70,(%esp)
  800193:	e8 9a 00 00 00       	call   800232 <cprintf>
  800198:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80019b:	cc                   	int3   
  80019c:	eb fd                	jmp    80019b <_panic+0x43>

0080019e <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80019e:	55                   	push   %ebp
  80019f:	89 e5                	mov    %esp,%ebp
  8001a1:	53                   	push   %ebx
  8001a2:	83 ec 04             	sub    $0x4,%esp
  8001a5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001a8:	8b 13                	mov    (%ebx),%edx
  8001aa:	8d 42 01             	lea    0x1(%edx),%eax
  8001ad:	89 03                	mov    %eax,(%ebx)
  8001af:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001b2:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001b6:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001bb:	74 08                	je     8001c5 <putch+0x27>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8001bd:	ff 43 04             	incl   0x4(%ebx)
}
  8001c0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001c3:	c9                   	leave  
  8001c4:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8001c5:	83 ec 08             	sub    $0x8,%esp
  8001c8:	68 ff 00 00 00       	push   $0xff
  8001cd:	8d 43 08             	lea    0x8(%ebx),%eax
  8001d0:	50                   	push   %eax
  8001d1:	e8 e5 fe ff ff       	call   8000bb <sys_cputs>
		b->idx = 0;
  8001d6:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001dc:	83 c4 10             	add    $0x10,%esp
  8001df:	eb dc                	jmp    8001bd <putch+0x1f>

008001e1 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001e1:	55                   	push   %ebp
  8001e2:	89 e5                	mov    %esp,%ebp
  8001e4:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001ea:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001f1:	00 00 00 
	b.cnt = 0;
  8001f4:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001fb:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001fe:	ff 75 0c             	pushl  0xc(%ebp)
  800201:	ff 75 08             	pushl  0x8(%ebp)
  800204:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80020a:	50                   	push   %eax
  80020b:	68 9e 01 80 00       	push   $0x80019e
  800210:	e8 0f 01 00 00       	call   800324 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800215:	83 c4 08             	add    $0x8,%esp
  800218:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80021e:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800224:	50                   	push   %eax
  800225:	e8 91 fe ff ff       	call   8000bb <sys_cputs>

	return b.cnt;
}
  80022a:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800230:	c9                   	leave  
  800231:	c3                   	ret    

00800232 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800232:	55                   	push   %ebp
  800233:	89 e5                	mov    %esp,%ebp
  800235:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800238:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80023b:	50                   	push   %eax
  80023c:	ff 75 08             	pushl  0x8(%ebp)
  80023f:	e8 9d ff ff ff       	call   8001e1 <vcprintf>
	va_end(ap);

	return cnt;
}
  800244:	c9                   	leave  
  800245:	c3                   	ret    

00800246 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800246:	55                   	push   %ebp
  800247:	89 e5                	mov    %esp,%ebp
  800249:	57                   	push   %edi
  80024a:	56                   	push   %esi
  80024b:	53                   	push   %ebx
  80024c:	83 ec 1c             	sub    $0x1c,%esp
  80024f:	89 c7                	mov    %eax,%edi
  800251:	89 d6                	mov    %edx,%esi
  800253:	8b 45 08             	mov    0x8(%ebp),%eax
  800256:	8b 55 0c             	mov    0xc(%ebp),%edx
  800259:	89 d1                	mov    %edx,%ecx
  80025b:	89 c2                	mov    %eax,%edx
  80025d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800260:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800263:	8b 45 10             	mov    0x10(%ebp),%eax
  800266:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800269:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80026c:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800273:	39 c2                	cmp    %eax,%edx
  800275:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  800278:	72 3c                	jb     8002b6 <printnum+0x70>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80027a:	83 ec 0c             	sub    $0xc,%esp
  80027d:	ff 75 18             	pushl  0x18(%ebp)
  800280:	4b                   	dec    %ebx
  800281:	53                   	push   %ebx
  800282:	50                   	push   %eax
  800283:	83 ec 08             	sub    $0x8,%esp
  800286:	ff 75 e4             	pushl  -0x1c(%ebp)
  800289:	ff 75 e0             	pushl  -0x20(%ebp)
  80028c:	ff 75 dc             	pushl  -0x24(%ebp)
  80028f:	ff 75 d8             	pushl  -0x28(%ebp)
  800292:	e8 55 08 00 00       	call   800aec <__udivdi3>
  800297:	83 c4 18             	add    $0x18,%esp
  80029a:	52                   	push   %edx
  80029b:	50                   	push   %eax
  80029c:	89 f2                	mov    %esi,%edx
  80029e:	89 f8                	mov    %edi,%eax
  8002a0:	e8 a1 ff ff ff       	call   800246 <printnum>
  8002a5:	83 c4 20             	add    $0x20,%esp
  8002a8:	eb 11                	jmp    8002bb <printnum+0x75>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002aa:	83 ec 08             	sub    $0x8,%esp
  8002ad:	56                   	push   %esi
  8002ae:	ff 75 18             	pushl  0x18(%ebp)
  8002b1:	ff d7                	call   *%edi
  8002b3:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8002b6:	4b                   	dec    %ebx
  8002b7:	85 db                	test   %ebx,%ebx
  8002b9:	7f ef                	jg     8002aa <printnum+0x64>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002bb:	83 ec 08             	sub    $0x8,%esp
  8002be:	56                   	push   %esi
  8002bf:	83 ec 04             	sub    $0x4,%esp
  8002c2:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002c5:	ff 75 e0             	pushl  -0x20(%ebp)
  8002c8:	ff 75 dc             	pushl  -0x24(%ebp)
  8002cb:	ff 75 d8             	pushl  -0x28(%ebp)
  8002ce:	e8 19 09 00 00       	call   800bec <__umoddi3>
  8002d3:	83 c4 14             	add    $0x14,%esp
  8002d6:	0f be 80 72 0d 80 00 	movsbl 0x800d72(%eax),%eax
  8002dd:	50                   	push   %eax
  8002de:	ff d7                	call   *%edi
}
  8002e0:	83 c4 10             	add    $0x10,%esp
  8002e3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002e6:	5b                   	pop    %ebx
  8002e7:	5e                   	pop    %esi
  8002e8:	5f                   	pop    %edi
  8002e9:	5d                   	pop    %ebp
  8002ea:	c3                   	ret    

008002eb <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002eb:	55                   	push   %ebp
  8002ec:	89 e5                	mov    %esp,%ebp
  8002ee:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002f1:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8002f4:	8b 10                	mov    (%eax),%edx
  8002f6:	3b 50 04             	cmp    0x4(%eax),%edx
  8002f9:	73 0a                	jae    800305 <sprintputch+0x1a>
		*b->buf++ = ch;
  8002fb:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002fe:	89 08                	mov    %ecx,(%eax)
  800300:	8b 45 08             	mov    0x8(%ebp),%eax
  800303:	88 02                	mov    %al,(%edx)
}
  800305:	5d                   	pop    %ebp
  800306:	c3                   	ret    

00800307 <printfmt>:
{
  800307:	55                   	push   %ebp
  800308:	89 e5                	mov    %esp,%ebp
  80030a:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  80030d:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800310:	50                   	push   %eax
  800311:	ff 75 10             	pushl  0x10(%ebp)
  800314:	ff 75 0c             	pushl  0xc(%ebp)
  800317:	ff 75 08             	pushl  0x8(%ebp)
  80031a:	e8 05 00 00 00       	call   800324 <vprintfmt>
}
  80031f:	83 c4 10             	add    $0x10,%esp
  800322:	c9                   	leave  
  800323:	c3                   	ret    

00800324 <vprintfmt>:
{
  800324:	55                   	push   %ebp
  800325:	89 e5                	mov    %esp,%ebp
  800327:	57                   	push   %edi
  800328:	56                   	push   %esi
  800329:	53                   	push   %ebx
  80032a:	83 ec 3c             	sub    $0x3c,%esp
  80032d:	8b 75 08             	mov    0x8(%ebp),%esi
  800330:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800333:	8b 7d 10             	mov    0x10(%ebp),%edi
  800336:	e9 5b 03 00 00       	jmp    800696 <vprintfmt+0x372>
		padc = ' ';
  80033b:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  80033f:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
		precision = -1;
  800346:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  80034d:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		lflag = 0;
  800354:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800359:	8d 47 01             	lea    0x1(%edi),%eax
  80035c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80035f:	8a 17                	mov    (%edi),%dl
  800361:	8d 42 dd             	lea    -0x23(%edx),%eax
  800364:	3c 55                	cmp    $0x55,%al
  800366:	0f 87 ab 03 00 00    	ja     800717 <vprintfmt+0x3f3>
  80036c:	0f b6 c0             	movzbl %al,%eax
  80036f:	ff 24 85 00 0e 80 00 	jmp    *0x800e00(,%eax,4)
  800376:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800379:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  80037d:	eb da                	jmp    800359 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  80037f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800382:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  800386:	eb d1                	jmp    800359 <vprintfmt+0x35>
  800388:	0f b6 d2             	movzbl %dl,%edx
  80038b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  80038e:	b8 00 00 00 00       	mov    $0x0,%eax
  800393:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800396:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800399:	01 c0                	add    %eax,%eax
  80039b:	8d 44 02 d0          	lea    -0x30(%edx,%eax,1),%eax
				ch = *fmt;
  80039f:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8003a2:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8003a5:	83 f9 09             	cmp    $0x9,%ecx
  8003a8:	77 52                	ja     8003fc <vprintfmt+0xd8>
			for (precision = 0; ; ++fmt) {
  8003aa:	47                   	inc    %edi
				precision = precision * 10 + ch - '0';
  8003ab:	eb e9                	jmp    800396 <vprintfmt+0x72>
			precision = va_arg(ap, int);
  8003ad:	8b 45 14             	mov    0x14(%ebp),%eax
  8003b0:	8b 00                	mov    (%eax),%eax
  8003b2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003b5:	8b 45 14             	mov    0x14(%ebp),%eax
  8003b8:	8d 40 04             	lea    0x4(%eax),%eax
  8003bb:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003be:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8003c1:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8003c5:	79 92                	jns    800359 <vprintfmt+0x35>
				width = precision, precision = -1;
  8003c7:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8003ca:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8003cd:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8003d4:	eb 83                	jmp    800359 <vprintfmt+0x35>
  8003d6:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8003da:	78 08                	js     8003e4 <vprintfmt+0xc0>
		switch (ch = *(unsigned char *) fmt++) {
  8003dc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8003df:	e9 75 ff ff ff       	jmp    800359 <vprintfmt+0x35>
  8003e4:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  8003eb:	eb ef                	jmp    8003dc <vprintfmt+0xb8>
		switch (ch = *(unsigned char *) fmt++) {
  8003ed:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8003f0:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  8003f7:	e9 5d ff ff ff       	jmp    800359 <vprintfmt+0x35>
  8003fc:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8003ff:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800402:	eb bd                	jmp    8003c1 <vprintfmt+0x9d>
			lflag++;
  800404:	41                   	inc    %ecx
		switch (ch = *(unsigned char *) fmt++) {
  800405:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800408:	e9 4c ff ff ff       	jmp    800359 <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
  80040d:	8b 45 14             	mov    0x14(%ebp),%eax
  800410:	8d 78 04             	lea    0x4(%eax),%edi
  800413:	83 ec 08             	sub    $0x8,%esp
  800416:	53                   	push   %ebx
  800417:	ff 30                	pushl  (%eax)
  800419:	ff d6                	call   *%esi
			break;
  80041b:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  80041e:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800421:	e9 6d 02 00 00       	jmp    800693 <vprintfmt+0x36f>
			err = va_arg(ap, int);
  800426:	8b 45 14             	mov    0x14(%ebp),%eax
  800429:	8d 78 04             	lea    0x4(%eax),%edi
  80042c:	8b 00                	mov    (%eax),%eax
  80042e:	85 c0                	test   %eax,%eax
  800430:	78 2a                	js     80045c <vprintfmt+0x138>
  800432:	89 c2                	mov    %eax,%edx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800434:	83 f8 06             	cmp    $0x6,%eax
  800437:	7f 27                	jg     800460 <vprintfmt+0x13c>
  800439:	8b 04 85 58 0f 80 00 	mov    0x800f58(,%eax,4),%eax
  800440:	85 c0                	test   %eax,%eax
  800442:	74 1c                	je     800460 <vprintfmt+0x13c>
				printfmt(putch, putdat, "%s", p);
  800444:	50                   	push   %eax
  800445:	68 93 0d 80 00       	push   $0x800d93
  80044a:	53                   	push   %ebx
  80044b:	56                   	push   %esi
  80044c:	e8 b6 fe ff ff       	call   800307 <printfmt>
  800451:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800454:	89 7d 14             	mov    %edi,0x14(%ebp)
  800457:	e9 37 02 00 00       	jmp    800693 <vprintfmt+0x36f>
  80045c:	f7 d8                	neg    %eax
  80045e:	eb d2                	jmp    800432 <vprintfmt+0x10e>
				printfmt(putch, putdat, "error %d", err);
  800460:	52                   	push   %edx
  800461:	68 8a 0d 80 00       	push   $0x800d8a
  800466:	53                   	push   %ebx
  800467:	56                   	push   %esi
  800468:	e8 9a fe ff ff       	call   800307 <printfmt>
  80046d:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800470:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800473:	e9 1b 02 00 00       	jmp    800693 <vprintfmt+0x36f>
			if ((p = va_arg(ap, char *)) == NULL)
  800478:	8b 45 14             	mov    0x14(%ebp),%eax
  80047b:	83 c0 04             	add    $0x4,%eax
  80047e:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800481:	8b 45 14             	mov    0x14(%ebp),%eax
  800484:	8b 00                	mov    (%eax),%eax
  800486:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800489:	85 c0                	test   %eax,%eax
  80048b:	74 19                	je     8004a6 <vprintfmt+0x182>
			if (width > 0 && padc != '-')
  80048d:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800491:	7e 06                	jle    800499 <vprintfmt+0x175>
  800493:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  800497:	75 16                	jne    8004af <vprintfmt+0x18b>
				for (width -= strnlen(p, precision); width > 0; width--)
  800499:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80049c:	89 c7                	mov    %eax,%edi
  80049e:	03 45 d4             	add    -0x2c(%ebp),%eax
  8004a1:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8004a4:	eb 62                	jmp    800508 <vprintfmt+0x1e4>
				p = "(null)";
  8004a6:	c7 45 cc 83 0d 80 00 	movl   $0x800d83,-0x34(%ebp)
  8004ad:	eb de                	jmp    80048d <vprintfmt+0x169>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004af:	83 ec 08             	sub    $0x8,%esp
  8004b2:	ff 75 d8             	pushl  -0x28(%ebp)
  8004b5:	ff 75 cc             	pushl  -0x34(%ebp)
  8004b8:	e8 05 03 00 00       	call   8007c2 <strnlen>
  8004bd:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8004c0:	29 c2                	sub    %eax,%edx
  8004c2:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  8004c5:	83 c4 10             	add    $0x10,%esp
  8004c8:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  8004ca:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8004ce:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8004d1:	eb 0d                	jmp    8004e0 <vprintfmt+0x1bc>
					putch(padc, putdat);
  8004d3:	83 ec 08             	sub    $0x8,%esp
  8004d6:	53                   	push   %ebx
  8004d7:	ff 75 d4             	pushl  -0x2c(%ebp)
  8004da:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8004dc:	4f                   	dec    %edi
  8004dd:	83 c4 10             	add    $0x10,%esp
  8004e0:	85 ff                	test   %edi,%edi
  8004e2:	7f ef                	jg     8004d3 <vprintfmt+0x1af>
  8004e4:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8004e7:	89 d0                	mov    %edx,%eax
  8004e9:	85 d2                	test   %edx,%edx
  8004eb:	78 0a                	js     8004f7 <vprintfmt+0x1d3>
  8004ed:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8004f0:	29 c2                	sub    %eax,%edx
  8004f2:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8004f5:	eb a2                	jmp    800499 <vprintfmt+0x175>
  8004f7:	b8 00 00 00 00       	mov    $0x0,%eax
  8004fc:	eb ef                	jmp    8004ed <vprintfmt+0x1c9>
					putch(ch, putdat);
  8004fe:	83 ec 08             	sub    $0x8,%esp
  800501:	53                   	push   %ebx
  800502:	52                   	push   %edx
  800503:	ff d6                	call   *%esi
  800505:	83 c4 10             	add    $0x10,%esp
  800508:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  80050b:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80050d:	47                   	inc    %edi
  80050e:	8a 47 ff             	mov    -0x1(%edi),%al
  800511:	0f be d0             	movsbl %al,%edx
  800514:	85 d2                	test   %edx,%edx
  800516:	74 48                	je     800560 <vprintfmt+0x23c>
  800518:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80051c:	78 05                	js     800523 <vprintfmt+0x1ff>
  80051e:	ff 4d d8             	decl   -0x28(%ebp)
  800521:	78 1e                	js     800541 <vprintfmt+0x21d>
				if (altflag && (ch < ' ' || ch > '~'))
  800523:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800527:	74 d5                	je     8004fe <vprintfmt+0x1da>
  800529:	0f be c0             	movsbl %al,%eax
  80052c:	83 e8 20             	sub    $0x20,%eax
  80052f:	83 f8 5e             	cmp    $0x5e,%eax
  800532:	76 ca                	jbe    8004fe <vprintfmt+0x1da>
					putch('?', putdat);
  800534:	83 ec 08             	sub    $0x8,%esp
  800537:	53                   	push   %ebx
  800538:	6a 3f                	push   $0x3f
  80053a:	ff d6                	call   *%esi
  80053c:	83 c4 10             	add    $0x10,%esp
  80053f:	eb c7                	jmp    800508 <vprintfmt+0x1e4>
  800541:	89 cf                	mov    %ecx,%edi
  800543:	eb 0c                	jmp    800551 <vprintfmt+0x22d>
				putch(' ', putdat);
  800545:	83 ec 08             	sub    $0x8,%esp
  800548:	53                   	push   %ebx
  800549:	6a 20                	push   $0x20
  80054b:	ff d6                	call   *%esi
			for (; width > 0; width--)
  80054d:	4f                   	dec    %edi
  80054e:	83 c4 10             	add    $0x10,%esp
  800551:	85 ff                	test   %edi,%edi
  800553:	7f f0                	jg     800545 <vprintfmt+0x221>
			if ((p = va_arg(ap, char *)) == NULL)
  800555:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800558:	89 45 14             	mov    %eax,0x14(%ebp)
  80055b:	e9 33 01 00 00       	jmp    800693 <vprintfmt+0x36f>
  800560:	89 cf                	mov    %ecx,%edi
  800562:	eb ed                	jmp    800551 <vprintfmt+0x22d>
	if (lflag >= 2)
  800564:	83 f9 01             	cmp    $0x1,%ecx
  800567:	7f 1b                	jg     800584 <vprintfmt+0x260>
	else if (lflag)
  800569:	85 c9                	test   %ecx,%ecx
  80056b:	74 42                	je     8005af <vprintfmt+0x28b>
		return va_arg(*ap, long);
  80056d:	8b 45 14             	mov    0x14(%ebp),%eax
  800570:	8b 00                	mov    (%eax),%eax
  800572:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800575:	99                   	cltd   
  800576:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800579:	8b 45 14             	mov    0x14(%ebp),%eax
  80057c:	8d 40 04             	lea    0x4(%eax),%eax
  80057f:	89 45 14             	mov    %eax,0x14(%ebp)
  800582:	eb 17                	jmp    80059b <vprintfmt+0x277>
		return va_arg(*ap, long long);
  800584:	8b 45 14             	mov    0x14(%ebp),%eax
  800587:	8b 50 04             	mov    0x4(%eax),%edx
  80058a:	8b 00                	mov    (%eax),%eax
  80058c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80058f:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800592:	8b 45 14             	mov    0x14(%ebp),%eax
  800595:	8d 40 08             	lea    0x8(%eax),%eax
  800598:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  80059b:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80059e:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8005a1:	85 c9                	test   %ecx,%ecx
  8005a3:	78 21                	js     8005c6 <vprintfmt+0x2a2>
			base = 10;
  8005a5:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005aa:	e9 ca 00 00 00       	jmp    800679 <vprintfmt+0x355>
		return va_arg(*ap, int);
  8005af:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b2:	8b 00                	mov    (%eax),%eax
  8005b4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005b7:	99                   	cltd   
  8005b8:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005bb:	8b 45 14             	mov    0x14(%ebp),%eax
  8005be:	8d 40 04             	lea    0x4(%eax),%eax
  8005c1:	89 45 14             	mov    %eax,0x14(%ebp)
  8005c4:	eb d5                	jmp    80059b <vprintfmt+0x277>
				putch('-', putdat);
  8005c6:	83 ec 08             	sub    $0x8,%esp
  8005c9:	53                   	push   %ebx
  8005ca:	6a 2d                	push   $0x2d
  8005cc:	ff d6                	call   *%esi
				num = -(long long) num;
  8005ce:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005d1:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8005d4:	f7 da                	neg    %edx
  8005d6:	83 d1 00             	adc    $0x0,%ecx
  8005d9:	f7 d9                	neg    %ecx
  8005db:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8005de:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005e3:	e9 91 00 00 00       	jmp    800679 <vprintfmt+0x355>
	if (lflag >= 2)
  8005e8:	83 f9 01             	cmp    $0x1,%ecx
  8005eb:	7f 1b                	jg     800608 <vprintfmt+0x2e4>
	else if (lflag)
  8005ed:	85 c9                	test   %ecx,%ecx
  8005ef:	74 2c                	je     80061d <vprintfmt+0x2f9>
		return va_arg(*ap, unsigned long);
  8005f1:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f4:	8b 10                	mov    (%eax),%edx
  8005f6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005fb:	8d 40 04             	lea    0x4(%eax),%eax
  8005fe:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800601:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  800606:	eb 71                	jmp    800679 <vprintfmt+0x355>
		return va_arg(*ap, unsigned long long);
  800608:	8b 45 14             	mov    0x14(%ebp),%eax
  80060b:	8b 10                	mov    (%eax),%edx
  80060d:	8b 48 04             	mov    0x4(%eax),%ecx
  800610:	8d 40 08             	lea    0x8(%eax),%eax
  800613:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800616:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  80061b:	eb 5c                	jmp    800679 <vprintfmt+0x355>
		return va_arg(*ap, unsigned int);
  80061d:	8b 45 14             	mov    0x14(%ebp),%eax
  800620:	8b 10                	mov    (%eax),%edx
  800622:	b9 00 00 00 00       	mov    $0x0,%ecx
  800627:	8d 40 04             	lea    0x4(%eax),%eax
  80062a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80062d:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  800632:	eb 45                	jmp    800679 <vprintfmt+0x355>
			putch('X', putdat);
  800634:	83 ec 08             	sub    $0x8,%esp
  800637:	53                   	push   %ebx
  800638:	6a 58                	push   $0x58
  80063a:	ff d6                	call   *%esi
			putch('X', putdat);
  80063c:	83 c4 08             	add    $0x8,%esp
  80063f:	53                   	push   %ebx
  800640:	6a 58                	push   $0x58
  800642:	ff d6                	call   *%esi
			putch('X', putdat);
  800644:	83 c4 08             	add    $0x8,%esp
  800647:	53                   	push   %ebx
  800648:	6a 58                	push   $0x58
  80064a:	ff d6                	call   *%esi
			break;
  80064c:	83 c4 10             	add    $0x10,%esp
  80064f:	eb 42                	jmp    800693 <vprintfmt+0x36f>
			putch('0', putdat);
  800651:	83 ec 08             	sub    $0x8,%esp
  800654:	53                   	push   %ebx
  800655:	6a 30                	push   $0x30
  800657:	ff d6                	call   *%esi
			putch('x', putdat);
  800659:	83 c4 08             	add    $0x8,%esp
  80065c:	53                   	push   %ebx
  80065d:	6a 78                	push   $0x78
  80065f:	ff d6                	call   *%esi
			num = (unsigned long long)
  800661:	8b 45 14             	mov    0x14(%ebp),%eax
  800664:	8b 10                	mov    (%eax),%edx
  800666:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  80066b:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  80066e:	8d 40 04             	lea    0x4(%eax),%eax
  800671:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800674:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  800679:	83 ec 0c             	sub    $0xc,%esp
  80067c:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  800680:	57                   	push   %edi
  800681:	ff 75 d4             	pushl  -0x2c(%ebp)
  800684:	50                   	push   %eax
  800685:	51                   	push   %ecx
  800686:	52                   	push   %edx
  800687:	89 da                	mov    %ebx,%edx
  800689:	89 f0                	mov    %esi,%eax
  80068b:	e8 b6 fb ff ff       	call   800246 <printnum>
			break;
  800690:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  800693:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800696:	47                   	inc    %edi
  800697:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80069b:	83 f8 25             	cmp    $0x25,%eax
  80069e:	0f 84 97 fc ff ff    	je     80033b <vprintfmt+0x17>
			if (ch == '\0')
  8006a4:	85 c0                	test   %eax,%eax
  8006a6:	0f 84 89 00 00 00    	je     800735 <vprintfmt+0x411>
			putch(ch, putdat);
  8006ac:	83 ec 08             	sub    $0x8,%esp
  8006af:	53                   	push   %ebx
  8006b0:	50                   	push   %eax
  8006b1:	ff d6                	call   *%esi
  8006b3:	83 c4 10             	add    $0x10,%esp
  8006b6:	eb de                	jmp    800696 <vprintfmt+0x372>
	if (lflag >= 2)
  8006b8:	83 f9 01             	cmp    $0x1,%ecx
  8006bb:	7f 1b                	jg     8006d8 <vprintfmt+0x3b4>
	else if (lflag)
  8006bd:	85 c9                	test   %ecx,%ecx
  8006bf:	74 2c                	je     8006ed <vprintfmt+0x3c9>
		return va_arg(*ap, unsigned long);
  8006c1:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c4:	8b 10                	mov    (%eax),%edx
  8006c6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006cb:	8d 40 04             	lea    0x4(%eax),%eax
  8006ce:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006d1:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  8006d6:	eb a1                	jmp    800679 <vprintfmt+0x355>
		return va_arg(*ap, unsigned long long);
  8006d8:	8b 45 14             	mov    0x14(%ebp),%eax
  8006db:	8b 10                	mov    (%eax),%edx
  8006dd:	8b 48 04             	mov    0x4(%eax),%ecx
  8006e0:	8d 40 08             	lea    0x8(%eax),%eax
  8006e3:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006e6:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  8006eb:	eb 8c                	jmp    800679 <vprintfmt+0x355>
		return va_arg(*ap, unsigned int);
  8006ed:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f0:	8b 10                	mov    (%eax),%edx
  8006f2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006f7:	8d 40 04             	lea    0x4(%eax),%eax
  8006fa:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006fd:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  800702:	e9 72 ff ff ff       	jmp    800679 <vprintfmt+0x355>
			putch(ch, putdat);
  800707:	83 ec 08             	sub    $0x8,%esp
  80070a:	53                   	push   %ebx
  80070b:	6a 25                	push   $0x25
  80070d:	ff d6                	call   *%esi
			break;
  80070f:	83 c4 10             	add    $0x10,%esp
  800712:	e9 7c ff ff ff       	jmp    800693 <vprintfmt+0x36f>
			putch('%', putdat);
  800717:	83 ec 08             	sub    $0x8,%esp
  80071a:	53                   	push   %ebx
  80071b:	6a 25                	push   $0x25
  80071d:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80071f:	83 c4 10             	add    $0x10,%esp
  800722:	89 f8                	mov    %edi,%eax
  800724:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800728:	74 03                	je     80072d <vprintfmt+0x409>
  80072a:	48                   	dec    %eax
  80072b:	eb f7                	jmp    800724 <vprintfmt+0x400>
  80072d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800730:	e9 5e ff ff ff       	jmp    800693 <vprintfmt+0x36f>
}
  800735:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800738:	5b                   	pop    %ebx
  800739:	5e                   	pop    %esi
  80073a:	5f                   	pop    %edi
  80073b:	5d                   	pop    %ebp
  80073c:	c3                   	ret    

0080073d <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80073d:	55                   	push   %ebp
  80073e:	89 e5                	mov    %esp,%ebp
  800740:	83 ec 18             	sub    $0x18,%esp
  800743:	8b 45 08             	mov    0x8(%ebp),%eax
  800746:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800749:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80074c:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800750:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800753:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80075a:	85 c0                	test   %eax,%eax
  80075c:	74 26                	je     800784 <vsnprintf+0x47>
  80075e:	85 d2                	test   %edx,%edx
  800760:	7e 29                	jle    80078b <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800762:	ff 75 14             	pushl  0x14(%ebp)
  800765:	ff 75 10             	pushl  0x10(%ebp)
  800768:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80076b:	50                   	push   %eax
  80076c:	68 eb 02 80 00       	push   $0x8002eb
  800771:	e8 ae fb ff ff       	call   800324 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800776:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800779:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80077c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80077f:	83 c4 10             	add    $0x10,%esp
}
  800782:	c9                   	leave  
  800783:	c3                   	ret    
		return -E_INVAL;
  800784:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800789:	eb f7                	jmp    800782 <vsnprintf+0x45>
  80078b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800790:	eb f0                	jmp    800782 <vsnprintf+0x45>

00800792 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800792:	55                   	push   %ebp
  800793:	89 e5                	mov    %esp,%ebp
  800795:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800798:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80079b:	50                   	push   %eax
  80079c:	ff 75 10             	pushl  0x10(%ebp)
  80079f:	ff 75 0c             	pushl  0xc(%ebp)
  8007a2:	ff 75 08             	pushl  0x8(%ebp)
  8007a5:	e8 93 ff ff ff       	call   80073d <vsnprintf>
	va_end(ap);

	return rc;
}
  8007aa:	c9                   	leave  
  8007ab:	c3                   	ret    

008007ac <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007ac:	55                   	push   %ebp
  8007ad:	89 e5                	mov    %esp,%ebp
  8007af:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007b2:	b8 00 00 00 00       	mov    $0x0,%eax
  8007b7:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007bb:	74 03                	je     8007c0 <strlen+0x14>
		n++;
  8007bd:	40                   	inc    %eax
  8007be:	eb f7                	jmp    8007b7 <strlen+0xb>
	return n;
}
  8007c0:	5d                   	pop    %ebp
  8007c1:	c3                   	ret    

008007c2 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007c2:	55                   	push   %ebp
  8007c3:	89 e5                	mov    %esp,%ebp
  8007c5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007c8:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007cb:	b8 00 00 00 00       	mov    $0x0,%eax
  8007d0:	39 d0                	cmp    %edx,%eax
  8007d2:	74 0b                	je     8007df <strnlen+0x1d>
  8007d4:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007d8:	74 03                	je     8007dd <strnlen+0x1b>
		n++;
  8007da:	40                   	inc    %eax
  8007db:	eb f3                	jmp    8007d0 <strnlen+0xe>
  8007dd:	89 c2                	mov    %eax,%edx
	return n;
}
  8007df:	89 d0                	mov    %edx,%eax
  8007e1:	5d                   	pop    %ebp
  8007e2:	c3                   	ret    

008007e3 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007e3:	55                   	push   %ebp
  8007e4:	89 e5                	mov    %esp,%ebp
  8007e6:	53                   	push   %ebx
  8007e7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007ea:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007ed:	b8 00 00 00 00       	mov    $0x0,%eax
  8007f2:	8a 14 03             	mov    (%ebx,%eax,1),%dl
  8007f5:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8007f8:	40                   	inc    %eax
  8007f9:	84 d2                	test   %dl,%dl
  8007fb:	75 f5                	jne    8007f2 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8007fd:	89 c8                	mov    %ecx,%eax
  8007ff:	5b                   	pop    %ebx
  800800:	5d                   	pop    %ebp
  800801:	c3                   	ret    

00800802 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800802:	55                   	push   %ebp
  800803:	89 e5                	mov    %esp,%ebp
  800805:	53                   	push   %ebx
  800806:	83 ec 10             	sub    $0x10,%esp
  800809:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80080c:	53                   	push   %ebx
  80080d:	e8 9a ff ff ff       	call   8007ac <strlen>
  800812:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800815:	ff 75 0c             	pushl  0xc(%ebp)
  800818:	01 d8                	add    %ebx,%eax
  80081a:	50                   	push   %eax
  80081b:	e8 c3 ff ff ff       	call   8007e3 <strcpy>
	return dst;
}
  800820:	89 d8                	mov    %ebx,%eax
  800822:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800825:	c9                   	leave  
  800826:	c3                   	ret    

00800827 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800827:	55                   	push   %ebp
  800828:	89 e5                	mov    %esp,%ebp
  80082a:	53                   	push   %ebx
  80082b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80082e:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800831:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800834:	8b 45 08             	mov    0x8(%ebp),%eax
  800837:	39 d8                	cmp    %ebx,%eax
  800839:	74 0e                	je     800849 <strncpy+0x22>
		*dst++ = *src;
  80083b:	40                   	inc    %eax
  80083c:	8a 0a                	mov    (%edx),%cl
  80083e:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800841:	80 f9 01             	cmp    $0x1,%cl
  800844:	83 da ff             	sbb    $0xffffffff,%edx
  800847:	eb ee                	jmp    800837 <strncpy+0x10>
	}
	return ret;
}
  800849:	8b 45 08             	mov    0x8(%ebp),%eax
  80084c:	5b                   	pop    %ebx
  80084d:	5d                   	pop    %ebp
  80084e:	c3                   	ret    

0080084f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80084f:	55                   	push   %ebp
  800850:	89 e5                	mov    %esp,%ebp
  800852:	56                   	push   %esi
  800853:	53                   	push   %ebx
  800854:	8b 75 08             	mov    0x8(%ebp),%esi
  800857:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80085a:	8b 45 10             	mov    0x10(%ebp),%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80085d:	85 c0                	test   %eax,%eax
  80085f:	74 22                	je     800883 <strlcpy+0x34>
  800861:	8d 44 06 ff          	lea    -0x1(%esi,%eax,1),%eax
  800865:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  800867:	39 c2                	cmp    %eax,%edx
  800869:	74 0f                	je     80087a <strlcpy+0x2b>
  80086b:	8a 19                	mov    (%ecx),%bl
  80086d:	84 db                	test   %bl,%bl
  80086f:	74 07                	je     800878 <strlcpy+0x29>
			*dst++ = *src++;
  800871:	41                   	inc    %ecx
  800872:	42                   	inc    %edx
  800873:	88 5a ff             	mov    %bl,-0x1(%edx)
  800876:	eb ef                	jmp    800867 <strlcpy+0x18>
  800878:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  80087a:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80087d:	29 f0                	sub    %esi,%eax
}
  80087f:	5b                   	pop    %ebx
  800880:	5e                   	pop    %esi
  800881:	5d                   	pop    %ebp
  800882:	c3                   	ret    
  800883:	89 f0                	mov    %esi,%eax
  800885:	eb f6                	jmp    80087d <strlcpy+0x2e>

00800887 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800887:	55                   	push   %ebp
  800888:	89 e5                	mov    %esp,%ebp
  80088a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80088d:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800890:	8a 01                	mov    (%ecx),%al
  800892:	84 c0                	test   %al,%al
  800894:	74 08                	je     80089e <strcmp+0x17>
  800896:	3a 02                	cmp    (%edx),%al
  800898:	75 04                	jne    80089e <strcmp+0x17>
		p++, q++;
  80089a:	41                   	inc    %ecx
  80089b:	42                   	inc    %edx
  80089c:	eb f2                	jmp    800890 <strcmp+0x9>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80089e:	0f b6 c0             	movzbl %al,%eax
  8008a1:	0f b6 12             	movzbl (%edx),%edx
  8008a4:	29 d0                	sub    %edx,%eax
}
  8008a6:	5d                   	pop    %ebp
  8008a7:	c3                   	ret    

008008a8 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008a8:	55                   	push   %ebp
  8008a9:	89 e5                	mov    %esp,%ebp
  8008ab:	53                   	push   %ebx
  8008ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8008af:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008b2:	89 c3                	mov    %eax,%ebx
  8008b4:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008b7:	eb 02                	jmp    8008bb <strncmp+0x13>
		n--, p++, q++;
  8008b9:	40                   	inc    %eax
  8008ba:	42                   	inc    %edx
	while (n > 0 && *p && *p == *q)
  8008bb:	39 d8                	cmp    %ebx,%eax
  8008bd:	74 15                	je     8008d4 <strncmp+0x2c>
  8008bf:	8a 08                	mov    (%eax),%cl
  8008c1:	84 c9                	test   %cl,%cl
  8008c3:	74 04                	je     8008c9 <strncmp+0x21>
  8008c5:	3a 0a                	cmp    (%edx),%cl
  8008c7:	74 f0                	je     8008b9 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008c9:	0f b6 00             	movzbl (%eax),%eax
  8008cc:	0f b6 12             	movzbl (%edx),%edx
  8008cf:	29 d0                	sub    %edx,%eax
}
  8008d1:	5b                   	pop    %ebx
  8008d2:	5d                   	pop    %ebp
  8008d3:	c3                   	ret    
		return 0;
  8008d4:	b8 00 00 00 00       	mov    $0x0,%eax
  8008d9:	eb f6                	jmp    8008d1 <strncmp+0x29>

008008db <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008db:	55                   	push   %ebp
  8008dc:	89 e5                	mov    %esp,%ebp
  8008de:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e1:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8008e4:	8a 10                	mov    (%eax),%dl
  8008e6:	84 d2                	test   %dl,%dl
  8008e8:	74 07                	je     8008f1 <strchr+0x16>
		if (*s == c)
  8008ea:	38 ca                	cmp    %cl,%dl
  8008ec:	74 08                	je     8008f6 <strchr+0x1b>
	for (; *s; s++)
  8008ee:	40                   	inc    %eax
  8008ef:	eb f3                	jmp    8008e4 <strchr+0x9>
			return (char *) s;
	return 0;
  8008f1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008f6:	5d                   	pop    %ebp
  8008f7:	c3                   	ret    

008008f8 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008f8:	55                   	push   %ebp
  8008f9:	89 e5                	mov    %esp,%ebp
  8008fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8008fe:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800901:	8a 10                	mov    (%eax),%dl
  800903:	84 d2                	test   %dl,%dl
  800905:	74 07                	je     80090e <strfind+0x16>
		if (*s == c)
  800907:	38 ca                	cmp    %cl,%dl
  800909:	74 03                	je     80090e <strfind+0x16>
	for (; *s; s++)
  80090b:	40                   	inc    %eax
  80090c:	eb f3                	jmp    800901 <strfind+0x9>
			break;
	return (char *) s;
}
  80090e:	5d                   	pop    %ebp
  80090f:	c3                   	ret    

00800910 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800910:	55                   	push   %ebp
  800911:	89 e5                	mov    %esp,%ebp
  800913:	57                   	push   %edi
  800914:	56                   	push   %esi
  800915:	53                   	push   %ebx
  800916:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800919:	85 c9                	test   %ecx,%ecx
  80091b:	74 36                	je     800953 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80091d:	89 c8                	mov    %ecx,%eax
  80091f:	0b 45 08             	or     0x8(%ebp),%eax
  800922:	a8 03                	test   $0x3,%al
  800924:	75 24                	jne    80094a <memset+0x3a>
		c &= 0xFF;
  800926:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80092a:	89 d3                	mov    %edx,%ebx
  80092c:	c1 e3 08             	shl    $0x8,%ebx
  80092f:	89 d0                	mov    %edx,%eax
  800931:	c1 e0 18             	shl    $0x18,%eax
  800934:	89 d6                	mov    %edx,%esi
  800936:	c1 e6 10             	shl    $0x10,%esi
  800939:	09 f0                	or     %esi,%eax
  80093b:	09 d0                	or     %edx,%eax
  80093d:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80093f:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800942:	8b 7d 08             	mov    0x8(%ebp),%edi
  800945:	fc                   	cld    
  800946:	f3 ab                	rep stos %eax,%es:(%edi)
  800948:	eb 09                	jmp    800953 <memset+0x43>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80094a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80094d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800950:	fc                   	cld    
  800951:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800953:	8b 45 08             	mov    0x8(%ebp),%eax
  800956:	5b                   	pop    %ebx
  800957:	5e                   	pop    %esi
  800958:	5f                   	pop    %edi
  800959:	5d                   	pop    %ebp
  80095a:	c3                   	ret    

0080095b <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80095b:	55                   	push   %ebp
  80095c:	89 e5                	mov    %esp,%ebp
  80095e:	57                   	push   %edi
  80095f:	56                   	push   %esi
  800960:	8b 45 08             	mov    0x8(%ebp),%eax
  800963:	8b 75 0c             	mov    0xc(%ebp),%esi
  800966:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800969:	39 c6                	cmp    %eax,%esi
  80096b:	73 30                	jae    80099d <memmove+0x42>
  80096d:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800970:	39 c2                	cmp    %eax,%edx
  800972:	76 29                	jbe    80099d <memmove+0x42>
		s += n;
		d += n;
  800974:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800977:	89 fe                	mov    %edi,%esi
  800979:	09 ce                	or     %ecx,%esi
  80097b:	09 d6                	or     %edx,%esi
  80097d:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800983:	75 0e                	jne    800993 <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800985:	83 ef 04             	sub    $0x4,%edi
  800988:	8d 72 fc             	lea    -0x4(%edx),%esi
  80098b:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  80098e:	fd                   	std    
  80098f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800991:	eb 07                	jmp    80099a <memmove+0x3f>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800993:	4f                   	dec    %edi
  800994:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800997:	fd                   	std    
  800998:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80099a:	fc                   	cld    
  80099b:	eb 1a                	jmp    8009b7 <memmove+0x5c>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80099d:	89 c2                	mov    %eax,%edx
  80099f:	09 ca                	or     %ecx,%edx
  8009a1:	09 f2                	or     %esi,%edx
  8009a3:	f6 c2 03             	test   $0x3,%dl
  8009a6:	75 0a                	jne    8009b2 <memmove+0x57>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009a8:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  8009ab:	89 c7                	mov    %eax,%edi
  8009ad:	fc                   	cld    
  8009ae:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009b0:	eb 05                	jmp    8009b7 <memmove+0x5c>
		else
			asm volatile("cld; rep movsb\n"
  8009b2:	89 c7                	mov    %eax,%edi
  8009b4:	fc                   	cld    
  8009b5:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009b7:	5e                   	pop    %esi
  8009b8:	5f                   	pop    %edi
  8009b9:	5d                   	pop    %ebp
  8009ba:	c3                   	ret    

008009bb <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009bb:	55                   	push   %ebp
  8009bc:	89 e5                	mov    %esp,%ebp
  8009be:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8009c1:	ff 75 10             	pushl  0x10(%ebp)
  8009c4:	ff 75 0c             	pushl  0xc(%ebp)
  8009c7:	ff 75 08             	pushl  0x8(%ebp)
  8009ca:	e8 8c ff ff ff       	call   80095b <memmove>
}
  8009cf:	c9                   	leave  
  8009d0:	c3                   	ret    

008009d1 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009d1:	55                   	push   %ebp
  8009d2:	89 e5                	mov    %esp,%ebp
  8009d4:	56                   	push   %esi
  8009d5:	53                   	push   %ebx
  8009d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009dc:	89 c6                	mov    %eax,%esi
  8009de:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009e1:	39 f0                	cmp    %esi,%eax
  8009e3:	74 16                	je     8009fb <memcmp+0x2a>
		if (*s1 != *s2)
  8009e5:	8a 08                	mov    (%eax),%cl
  8009e7:	8a 1a                	mov    (%edx),%bl
  8009e9:	38 d9                	cmp    %bl,%cl
  8009eb:	75 04                	jne    8009f1 <memcmp+0x20>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  8009ed:	40                   	inc    %eax
  8009ee:	42                   	inc    %edx
  8009ef:	eb f0                	jmp    8009e1 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  8009f1:	0f b6 c1             	movzbl %cl,%eax
  8009f4:	0f b6 db             	movzbl %bl,%ebx
  8009f7:	29 d8                	sub    %ebx,%eax
  8009f9:	eb 05                	jmp    800a00 <memcmp+0x2f>
	}

	return 0;
  8009fb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a00:	5b                   	pop    %ebx
  800a01:	5e                   	pop    %esi
  800a02:	5d                   	pop    %ebp
  800a03:	c3                   	ret    

00800a04 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a04:	55                   	push   %ebp
  800a05:	89 e5                	mov    %esp,%ebp
  800a07:	8b 45 08             	mov    0x8(%ebp),%eax
  800a0a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a0d:	89 c2                	mov    %eax,%edx
  800a0f:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a12:	39 d0                	cmp    %edx,%eax
  800a14:	73 07                	jae    800a1d <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a16:	38 08                	cmp    %cl,(%eax)
  800a18:	74 03                	je     800a1d <memfind+0x19>
	for (; s < ends; s++)
  800a1a:	40                   	inc    %eax
  800a1b:	eb f5                	jmp    800a12 <memfind+0xe>
			break;
	return (void *) s;
}
  800a1d:	5d                   	pop    %ebp
  800a1e:	c3                   	ret    

00800a1f <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a1f:	55                   	push   %ebp
  800a20:	89 e5                	mov    %esp,%ebp
  800a22:	57                   	push   %edi
  800a23:	56                   	push   %esi
  800a24:	53                   	push   %ebx
  800a25:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a28:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a2b:	eb 01                	jmp    800a2e <strtol+0xf>
		s++;
  800a2d:	41                   	inc    %ecx
	while (*s == ' ' || *s == '\t')
  800a2e:	8a 01                	mov    (%ecx),%al
  800a30:	3c 20                	cmp    $0x20,%al
  800a32:	74 f9                	je     800a2d <strtol+0xe>
  800a34:	3c 09                	cmp    $0x9,%al
  800a36:	74 f5                	je     800a2d <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800a38:	3c 2b                	cmp    $0x2b,%al
  800a3a:	74 24                	je     800a60 <strtol+0x41>
		s++;
	else if (*s == '-')
  800a3c:	3c 2d                	cmp    $0x2d,%al
  800a3e:	74 28                	je     800a68 <strtol+0x49>
	int neg = 0;
  800a40:	bf 00 00 00 00       	mov    $0x0,%edi
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a45:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a4b:	75 09                	jne    800a56 <strtol+0x37>
  800a4d:	80 39 30             	cmpb   $0x30,(%ecx)
  800a50:	74 1e                	je     800a70 <strtol+0x51>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a52:	85 db                	test   %ebx,%ebx
  800a54:	74 36                	je     800a8c <strtol+0x6d>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a56:	b8 00 00 00 00       	mov    $0x0,%eax
  800a5b:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800a5e:	eb 45                	jmp    800aa5 <strtol+0x86>
		s++;
  800a60:	41                   	inc    %ecx
	int neg = 0;
  800a61:	bf 00 00 00 00       	mov    $0x0,%edi
  800a66:	eb dd                	jmp    800a45 <strtol+0x26>
		s++, neg = 1;
  800a68:	41                   	inc    %ecx
  800a69:	bf 01 00 00 00       	mov    $0x1,%edi
  800a6e:	eb d5                	jmp    800a45 <strtol+0x26>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a70:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a74:	74 0c                	je     800a82 <strtol+0x63>
	else if (base == 0 && s[0] == '0')
  800a76:	85 db                	test   %ebx,%ebx
  800a78:	75 dc                	jne    800a56 <strtol+0x37>
		s++, base = 8;
  800a7a:	41                   	inc    %ecx
  800a7b:	bb 08 00 00 00       	mov    $0x8,%ebx
  800a80:	eb d4                	jmp    800a56 <strtol+0x37>
		s += 2, base = 16;
  800a82:	83 c1 02             	add    $0x2,%ecx
  800a85:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a8a:	eb ca                	jmp    800a56 <strtol+0x37>
		base = 10;
  800a8c:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800a91:	eb c3                	jmp    800a56 <strtol+0x37>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800a93:	0f be d2             	movsbl %dl,%edx
  800a96:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800a99:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a9c:	7d 37                	jge    800ad5 <strtol+0xb6>
			break;
		s++, val = (val * base) + dig;
  800a9e:	41                   	inc    %ecx
  800a9f:	0f af 45 10          	imul   0x10(%ebp),%eax
  800aa3:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800aa5:	8a 11                	mov    (%ecx),%dl
  800aa7:	8d 72 d0             	lea    -0x30(%edx),%esi
  800aaa:	89 f3                	mov    %esi,%ebx
  800aac:	80 fb 09             	cmp    $0x9,%bl
  800aaf:	76 e2                	jbe    800a93 <strtol+0x74>
		else if (*s >= 'a' && *s <= 'z')
  800ab1:	8d 72 9f             	lea    -0x61(%edx),%esi
  800ab4:	89 f3                	mov    %esi,%ebx
  800ab6:	80 fb 19             	cmp    $0x19,%bl
  800ab9:	77 08                	ja     800ac3 <strtol+0xa4>
			dig = *s - 'a' + 10;
  800abb:	0f be d2             	movsbl %dl,%edx
  800abe:	83 ea 57             	sub    $0x57,%edx
  800ac1:	eb d6                	jmp    800a99 <strtol+0x7a>
		else if (*s >= 'A' && *s <= 'Z')
  800ac3:	8d 72 bf             	lea    -0x41(%edx),%esi
  800ac6:	89 f3                	mov    %esi,%ebx
  800ac8:	80 fb 19             	cmp    $0x19,%bl
  800acb:	77 08                	ja     800ad5 <strtol+0xb6>
			dig = *s - 'A' + 10;
  800acd:	0f be d2             	movsbl %dl,%edx
  800ad0:	83 ea 37             	sub    $0x37,%edx
  800ad3:	eb c4                	jmp    800a99 <strtol+0x7a>
		// we don't properly detect overflow!
	}

	if (endptr)
  800ad5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ad9:	74 05                	je     800ae0 <strtol+0xc1>
		*endptr = (char *) s;
  800adb:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ade:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800ae0:	85 ff                	test   %edi,%edi
  800ae2:	74 02                	je     800ae6 <strtol+0xc7>
  800ae4:	f7 d8                	neg    %eax
}
  800ae6:	5b                   	pop    %ebx
  800ae7:	5e                   	pop    %esi
  800ae8:	5f                   	pop    %edi
  800ae9:	5d                   	pop    %ebp
  800aea:	c3                   	ret    
  800aeb:	90                   	nop

00800aec <__udivdi3>:
  800aec:	55                   	push   %ebp
  800aed:	57                   	push   %edi
  800aee:	56                   	push   %esi
  800aef:	53                   	push   %ebx
  800af0:	83 ec 1c             	sub    $0x1c,%esp
  800af3:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800af7:	8b 74 24 34          	mov    0x34(%esp),%esi
  800afb:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800aff:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800b03:	85 d2                	test   %edx,%edx
  800b05:	75 19                	jne    800b20 <__udivdi3+0x34>
  800b07:	39 f7                	cmp    %esi,%edi
  800b09:	76 45                	jbe    800b50 <__udivdi3+0x64>
  800b0b:	89 e8                	mov    %ebp,%eax
  800b0d:	89 f2                	mov    %esi,%edx
  800b0f:	f7 f7                	div    %edi
  800b11:	31 db                	xor    %ebx,%ebx
  800b13:	89 da                	mov    %ebx,%edx
  800b15:	83 c4 1c             	add    $0x1c,%esp
  800b18:	5b                   	pop    %ebx
  800b19:	5e                   	pop    %esi
  800b1a:	5f                   	pop    %edi
  800b1b:	5d                   	pop    %ebp
  800b1c:	c3                   	ret    
  800b1d:	8d 76 00             	lea    0x0(%esi),%esi
  800b20:	39 f2                	cmp    %esi,%edx
  800b22:	76 10                	jbe    800b34 <__udivdi3+0x48>
  800b24:	31 db                	xor    %ebx,%ebx
  800b26:	31 c0                	xor    %eax,%eax
  800b28:	89 da                	mov    %ebx,%edx
  800b2a:	83 c4 1c             	add    $0x1c,%esp
  800b2d:	5b                   	pop    %ebx
  800b2e:	5e                   	pop    %esi
  800b2f:	5f                   	pop    %edi
  800b30:	5d                   	pop    %ebp
  800b31:	c3                   	ret    
  800b32:	66 90                	xchg   %ax,%ax
  800b34:	0f bd da             	bsr    %edx,%ebx
  800b37:	83 f3 1f             	xor    $0x1f,%ebx
  800b3a:	75 3c                	jne    800b78 <__udivdi3+0x8c>
  800b3c:	39 f2                	cmp    %esi,%edx
  800b3e:	72 08                	jb     800b48 <__udivdi3+0x5c>
  800b40:	39 ef                	cmp    %ebp,%edi
  800b42:	0f 87 9c 00 00 00    	ja     800be4 <__udivdi3+0xf8>
  800b48:	b8 01 00 00 00       	mov    $0x1,%eax
  800b4d:	eb d9                	jmp    800b28 <__udivdi3+0x3c>
  800b4f:	90                   	nop
  800b50:	89 f9                	mov    %edi,%ecx
  800b52:	85 ff                	test   %edi,%edi
  800b54:	75 0b                	jne    800b61 <__udivdi3+0x75>
  800b56:	b8 01 00 00 00       	mov    $0x1,%eax
  800b5b:	31 d2                	xor    %edx,%edx
  800b5d:	f7 f7                	div    %edi
  800b5f:	89 c1                	mov    %eax,%ecx
  800b61:	31 d2                	xor    %edx,%edx
  800b63:	89 f0                	mov    %esi,%eax
  800b65:	f7 f1                	div    %ecx
  800b67:	89 c3                	mov    %eax,%ebx
  800b69:	89 e8                	mov    %ebp,%eax
  800b6b:	f7 f1                	div    %ecx
  800b6d:	89 da                	mov    %ebx,%edx
  800b6f:	83 c4 1c             	add    $0x1c,%esp
  800b72:	5b                   	pop    %ebx
  800b73:	5e                   	pop    %esi
  800b74:	5f                   	pop    %edi
  800b75:	5d                   	pop    %ebp
  800b76:	c3                   	ret    
  800b77:	90                   	nop
  800b78:	b8 20 00 00 00       	mov    $0x20,%eax
  800b7d:	29 d8                	sub    %ebx,%eax
  800b7f:	88 d9                	mov    %bl,%cl
  800b81:	d3 e2                	shl    %cl,%edx
  800b83:	89 54 24 08          	mov    %edx,0x8(%esp)
  800b87:	89 fa                	mov    %edi,%edx
  800b89:	88 c1                	mov    %al,%cl
  800b8b:	d3 ea                	shr    %cl,%edx
  800b8d:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800b91:	09 d1                	or     %edx,%ecx
  800b93:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800b97:	88 d9                	mov    %bl,%cl
  800b99:	d3 e7                	shl    %cl,%edi
  800b9b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800b9f:	89 f7                	mov    %esi,%edi
  800ba1:	88 c1                	mov    %al,%cl
  800ba3:	d3 ef                	shr    %cl,%edi
  800ba5:	88 d9                	mov    %bl,%cl
  800ba7:	d3 e6                	shl    %cl,%esi
  800ba9:	89 ea                	mov    %ebp,%edx
  800bab:	88 c1                	mov    %al,%cl
  800bad:	d3 ea                	shr    %cl,%edx
  800baf:	09 d6                	or     %edx,%esi
  800bb1:	89 f0                	mov    %esi,%eax
  800bb3:	89 fa                	mov    %edi,%edx
  800bb5:	f7 74 24 08          	divl   0x8(%esp)
  800bb9:	89 d7                	mov    %edx,%edi
  800bbb:	89 c6                	mov    %eax,%esi
  800bbd:	f7 64 24 0c          	mull   0xc(%esp)
  800bc1:	39 d7                	cmp    %edx,%edi
  800bc3:	72 13                	jb     800bd8 <__udivdi3+0xec>
  800bc5:	74 09                	je     800bd0 <__udivdi3+0xe4>
  800bc7:	89 f0                	mov    %esi,%eax
  800bc9:	31 db                	xor    %ebx,%ebx
  800bcb:	e9 58 ff ff ff       	jmp    800b28 <__udivdi3+0x3c>
  800bd0:	88 d9                	mov    %bl,%cl
  800bd2:	d3 e5                	shl    %cl,%ebp
  800bd4:	39 c5                	cmp    %eax,%ebp
  800bd6:	73 ef                	jae    800bc7 <__udivdi3+0xdb>
  800bd8:	8d 46 ff             	lea    -0x1(%esi),%eax
  800bdb:	31 db                	xor    %ebx,%ebx
  800bdd:	e9 46 ff ff ff       	jmp    800b28 <__udivdi3+0x3c>
  800be2:	66 90                	xchg   %ax,%ax
  800be4:	31 c0                	xor    %eax,%eax
  800be6:	e9 3d ff ff ff       	jmp    800b28 <__udivdi3+0x3c>
  800beb:	90                   	nop

00800bec <__umoddi3>:
  800bec:	55                   	push   %ebp
  800bed:	57                   	push   %edi
  800bee:	56                   	push   %esi
  800bef:	53                   	push   %ebx
  800bf0:	83 ec 1c             	sub    $0x1c,%esp
  800bf3:	8b 74 24 30          	mov    0x30(%esp),%esi
  800bf7:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800bfb:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800bff:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  800c03:	85 c0                	test   %eax,%eax
  800c05:	75 19                	jne    800c20 <__umoddi3+0x34>
  800c07:	39 df                	cmp    %ebx,%edi
  800c09:	76 51                	jbe    800c5c <__umoddi3+0x70>
  800c0b:	89 f0                	mov    %esi,%eax
  800c0d:	89 da                	mov    %ebx,%edx
  800c0f:	f7 f7                	div    %edi
  800c11:	89 d0                	mov    %edx,%eax
  800c13:	31 d2                	xor    %edx,%edx
  800c15:	83 c4 1c             	add    $0x1c,%esp
  800c18:	5b                   	pop    %ebx
  800c19:	5e                   	pop    %esi
  800c1a:	5f                   	pop    %edi
  800c1b:	5d                   	pop    %ebp
  800c1c:	c3                   	ret    
  800c1d:	8d 76 00             	lea    0x0(%esi),%esi
  800c20:	89 f2                	mov    %esi,%edx
  800c22:	39 d8                	cmp    %ebx,%eax
  800c24:	76 0e                	jbe    800c34 <__umoddi3+0x48>
  800c26:	89 f0                	mov    %esi,%eax
  800c28:	89 da                	mov    %ebx,%edx
  800c2a:	83 c4 1c             	add    $0x1c,%esp
  800c2d:	5b                   	pop    %ebx
  800c2e:	5e                   	pop    %esi
  800c2f:	5f                   	pop    %edi
  800c30:	5d                   	pop    %ebp
  800c31:	c3                   	ret    
  800c32:	66 90                	xchg   %ax,%ax
  800c34:	0f bd e8             	bsr    %eax,%ebp
  800c37:	83 f5 1f             	xor    $0x1f,%ebp
  800c3a:	75 44                	jne    800c80 <__umoddi3+0x94>
  800c3c:	39 d8                	cmp    %ebx,%eax
  800c3e:	72 06                	jb     800c46 <__umoddi3+0x5a>
  800c40:	89 d9                	mov    %ebx,%ecx
  800c42:	39 f7                	cmp    %esi,%edi
  800c44:	77 08                	ja     800c4e <__umoddi3+0x62>
  800c46:	29 fe                	sub    %edi,%esi
  800c48:	19 c3                	sbb    %eax,%ebx
  800c4a:	89 f2                	mov    %esi,%edx
  800c4c:	89 d9                	mov    %ebx,%ecx
  800c4e:	89 d0                	mov    %edx,%eax
  800c50:	89 ca                	mov    %ecx,%edx
  800c52:	83 c4 1c             	add    $0x1c,%esp
  800c55:	5b                   	pop    %ebx
  800c56:	5e                   	pop    %esi
  800c57:	5f                   	pop    %edi
  800c58:	5d                   	pop    %ebp
  800c59:	c3                   	ret    
  800c5a:	66 90                	xchg   %ax,%ax
  800c5c:	89 fd                	mov    %edi,%ebp
  800c5e:	85 ff                	test   %edi,%edi
  800c60:	75 0b                	jne    800c6d <__umoddi3+0x81>
  800c62:	b8 01 00 00 00       	mov    $0x1,%eax
  800c67:	31 d2                	xor    %edx,%edx
  800c69:	f7 f7                	div    %edi
  800c6b:	89 c5                	mov    %eax,%ebp
  800c6d:	89 d8                	mov    %ebx,%eax
  800c6f:	31 d2                	xor    %edx,%edx
  800c71:	f7 f5                	div    %ebp
  800c73:	89 f0                	mov    %esi,%eax
  800c75:	f7 f5                	div    %ebp
  800c77:	89 d0                	mov    %edx,%eax
  800c79:	31 d2                	xor    %edx,%edx
  800c7b:	eb 98                	jmp    800c15 <__umoddi3+0x29>
  800c7d:	8d 76 00             	lea    0x0(%esi),%esi
  800c80:	ba 20 00 00 00       	mov    $0x20,%edx
  800c85:	29 ea                	sub    %ebp,%edx
  800c87:	89 e9                	mov    %ebp,%ecx
  800c89:	d3 e0                	shl    %cl,%eax
  800c8b:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c8f:	89 f8                	mov    %edi,%eax
  800c91:	89 54 24 04          	mov    %edx,0x4(%esp)
  800c95:	88 d1                	mov    %dl,%cl
  800c97:	d3 e8                	shr    %cl,%eax
  800c99:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800c9d:	09 c1                	or     %eax,%ecx
  800c9f:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800ca3:	89 e9                	mov    %ebp,%ecx
  800ca5:	d3 e7                	shl    %cl,%edi
  800ca7:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800cab:	89 d8                	mov    %ebx,%eax
  800cad:	8b 54 24 04          	mov    0x4(%esp),%edx
  800cb1:	88 d1                	mov    %dl,%cl
  800cb3:	d3 e8                	shr    %cl,%eax
  800cb5:	89 c7                	mov    %eax,%edi
  800cb7:	89 e9                	mov    %ebp,%ecx
  800cb9:	d3 e3                	shl    %cl,%ebx
  800cbb:	89 f0                	mov    %esi,%eax
  800cbd:	88 d1                	mov    %dl,%cl
  800cbf:	d3 e8                	shr    %cl,%eax
  800cc1:	09 d8                	or     %ebx,%eax
  800cc3:	89 e9                	mov    %ebp,%ecx
  800cc5:	d3 e6                	shl    %cl,%esi
  800cc7:	89 f3                	mov    %esi,%ebx
  800cc9:	89 fa                	mov    %edi,%edx
  800ccb:	f7 74 24 08          	divl   0x8(%esp)
  800ccf:	89 d1                	mov    %edx,%ecx
  800cd1:	f7 64 24 0c          	mull   0xc(%esp)
  800cd5:	89 c6                	mov    %eax,%esi
  800cd7:	89 d7                	mov    %edx,%edi
  800cd9:	39 d1                	cmp    %edx,%ecx
  800cdb:	72 27                	jb     800d04 <__umoddi3+0x118>
  800cdd:	74 21                	je     800d00 <__umoddi3+0x114>
  800cdf:	89 ca                	mov    %ecx,%edx
  800ce1:	29 f3                	sub    %esi,%ebx
  800ce3:	19 fa                	sbb    %edi,%edx
  800ce5:	89 d0                	mov    %edx,%eax
  800ce7:	8a 4c 24 04          	mov    0x4(%esp),%cl
  800ceb:	d3 e0                	shl    %cl,%eax
  800ced:	89 e9                	mov    %ebp,%ecx
  800cef:	d3 eb                	shr    %cl,%ebx
  800cf1:	09 d8                	or     %ebx,%eax
  800cf3:	d3 ea                	shr    %cl,%edx
  800cf5:	83 c4 1c             	add    $0x1c,%esp
  800cf8:	5b                   	pop    %ebx
  800cf9:	5e                   	pop    %esi
  800cfa:	5f                   	pop    %edi
  800cfb:	5d                   	pop    %ebp
  800cfc:	c3                   	ret    
  800cfd:	8d 76 00             	lea    0x0(%esi),%esi
  800d00:	39 c3                	cmp    %eax,%ebx
  800d02:	73 db                	jae    800cdf <__umoddi3+0xf3>
  800d04:	2b 44 24 0c          	sub    0xc(%esp),%eax
  800d08:	1b 54 24 08          	sbb    0x8(%esp),%edx
  800d0c:	89 d7                	mov    %edx,%edi
  800d0e:	89 c6                	mov    %eax,%esi
  800d10:	eb cd                	jmp    800cdf <__umoddi3+0xf3>
