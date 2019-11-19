
obj/user/buggyhello2:     file format elf32-i386


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

const char *hello = "hello, world\n";

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	sys_cputs(hello, 1024*1024);
  800039:	68 00 00 10 00       	push   $0x100000
  80003e:	ff 35 00 10 80 00    	pushl  0x801000
  800044:	e8 76 00 00 00       	call   8000bf <sys_cputs>
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
  80005a:	e8 de 00 00 00       	call   80013d <sys_getenvid>
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
  80007f:	a3 08 10 80 00       	mov    %eax,0x801008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800084:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800088:	7e 07                	jle    800091 <libmain+0x43>
		binaryname = argv[0];
  80008a:	8b 03                	mov    (%ebx),%eax
  80008c:	a3 04 10 80 00       	mov    %eax,0x801004
	
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
  8000b5:	e8 42 00 00 00       	call   8000fc <sys_env_destroy>
}
  8000ba:	83 c4 10             	add    $0x10,%esp
  8000bd:	c9                   	leave  
  8000be:	c3                   	ret    

008000bf <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000bf:	55                   	push   %ebp
  8000c0:	89 e5                	mov    %esp,%ebp
  8000c2:	57                   	push   %edi
  8000c3:	56                   	push   %esi
  8000c4:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000c5:	b8 00 00 00 00       	mov    $0x0,%eax
  8000ca:	8b 55 08             	mov    0x8(%ebp),%edx
  8000cd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000d0:	89 c3                	mov    %eax,%ebx
  8000d2:	89 c7                	mov    %eax,%edi
  8000d4:	89 c6                	mov    %eax,%esi
  8000d6:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000d8:	5b                   	pop    %ebx
  8000d9:	5e                   	pop    %esi
  8000da:	5f                   	pop    %edi
  8000db:	5d                   	pop    %ebp
  8000dc:	c3                   	ret    

008000dd <sys_cgetc>:

int
sys_cgetc(void)
{
  8000dd:	55                   	push   %ebp
  8000de:	89 e5                	mov    %esp,%ebp
  8000e0:	57                   	push   %edi
  8000e1:	56                   	push   %esi
  8000e2:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000e3:	ba 00 00 00 00       	mov    $0x0,%edx
  8000e8:	b8 01 00 00 00       	mov    $0x1,%eax
  8000ed:	89 d1                	mov    %edx,%ecx
  8000ef:	89 d3                	mov    %edx,%ebx
  8000f1:	89 d7                	mov    %edx,%edi
  8000f3:	89 d6                	mov    %edx,%esi
  8000f5:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000f7:	5b                   	pop    %ebx
  8000f8:	5e                   	pop    %esi
  8000f9:	5f                   	pop    %edi
  8000fa:	5d                   	pop    %ebp
  8000fb:	c3                   	ret    

008000fc <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000fc:	55                   	push   %ebp
  8000fd:	89 e5                	mov    %esp,%ebp
  8000ff:	57                   	push   %edi
  800100:	56                   	push   %esi
  800101:	53                   	push   %ebx
  800102:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800105:	b9 00 00 00 00       	mov    $0x0,%ecx
  80010a:	8b 55 08             	mov    0x8(%ebp),%edx
  80010d:	b8 03 00 00 00       	mov    $0x3,%eax
  800112:	89 cb                	mov    %ecx,%ebx
  800114:	89 cf                	mov    %ecx,%edi
  800116:	89 ce                	mov    %ecx,%esi
  800118:	cd 30                	int    $0x30
	if(check && ret > 0)
  80011a:	85 c0                	test   %eax,%eax
  80011c:	7f 08                	jg     800126 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80011e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800121:	5b                   	pop    %ebx
  800122:	5e                   	pop    %esi
  800123:	5f                   	pop    %edi
  800124:	5d                   	pop    %ebp
  800125:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800126:	83 ec 0c             	sub    $0xc,%esp
  800129:	50                   	push   %eax
  80012a:	6a 03                	push   $0x3
  80012c:	68 30 0d 80 00       	push   $0x800d30
  800131:	6a 23                	push   $0x23
  800133:	68 4d 0d 80 00       	push   $0x800d4d
  800138:	e8 1f 00 00 00       	call   80015c <_panic>

0080013d <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80013d:	55                   	push   %ebp
  80013e:	89 e5                	mov    %esp,%ebp
  800140:	57                   	push   %edi
  800141:	56                   	push   %esi
  800142:	53                   	push   %ebx
	asm volatile("int %1\n"
  800143:	ba 00 00 00 00       	mov    $0x0,%edx
  800148:	b8 02 00 00 00       	mov    $0x2,%eax
  80014d:	89 d1                	mov    %edx,%ecx
  80014f:	89 d3                	mov    %edx,%ebx
  800151:	89 d7                	mov    %edx,%edi
  800153:	89 d6                	mov    %edx,%esi
  800155:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800157:	5b                   	pop    %ebx
  800158:	5e                   	pop    %esi
  800159:	5f                   	pop    %edi
  80015a:	5d                   	pop    %ebp
  80015b:	c3                   	ret    

0080015c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80015c:	55                   	push   %ebp
  80015d:	89 e5                	mov    %esp,%ebp
  80015f:	56                   	push   %esi
  800160:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800161:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800164:	8b 35 04 10 80 00    	mov    0x801004,%esi
  80016a:	e8 ce ff ff ff       	call   80013d <sys_getenvid>
  80016f:	83 ec 0c             	sub    $0xc,%esp
  800172:	ff 75 0c             	pushl  0xc(%ebp)
  800175:	ff 75 08             	pushl  0x8(%ebp)
  800178:	56                   	push   %esi
  800179:	50                   	push   %eax
  80017a:	68 5c 0d 80 00       	push   $0x800d5c
  80017f:	e8 b2 00 00 00       	call   800236 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800184:	83 c4 18             	add    $0x18,%esp
  800187:	53                   	push   %ebx
  800188:	ff 75 10             	pushl  0x10(%ebp)
  80018b:	e8 55 00 00 00       	call   8001e5 <vcprintf>
	cprintf("\n");
  800190:	c7 04 24 24 0d 80 00 	movl   $0x800d24,(%esp)
  800197:	e8 9a 00 00 00       	call   800236 <cprintf>
  80019c:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80019f:	cc                   	int3   
  8001a0:	eb fd                	jmp    80019f <_panic+0x43>

008001a2 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001a2:	55                   	push   %ebp
  8001a3:	89 e5                	mov    %esp,%ebp
  8001a5:	53                   	push   %ebx
  8001a6:	83 ec 04             	sub    $0x4,%esp
  8001a9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001ac:	8b 13                	mov    (%ebx),%edx
  8001ae:	8d 42 01             	lea    0x1(%edx),%eax
  8001b1:	89 03                	mov    %eax,(%ebx)
  8001b3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001b6:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001ba:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001bf:	74 08                	je     8001c9 <putch+0x27>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8001c1:	ff 43 04             	incl   0x4(%ebx)
}
  8001c4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001c7:	c9                   	leave  
  8001c8:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8001c9:	83 ec 08             	sub    $0x8,%esp
  8001cc:	68 ff 00 00 00       	push   $0xff
  8001d1:	8d 43 08             	lea    0x8(%ebx),%eax
  8001d4:	50                   	push   %eax
  8001d5:	e8 e5 fe ff ff       	call   8000bf <sys_cputs>
		b->idx = 0;
  8001da:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001e0:	83 c4 10             	add    $0x10,%esp
  8001e3:	eb dc                	jmp    8001c1 <putch+0x1f>

008001e5 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001e5:	55                   	push   %ebp
  8001e6:	89 e5                	mov    %esp,%ebp
  8001e8:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001ee:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001f5:	00 00 00 
	b.cnt = 0;
  8001f8:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001ff:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800202:	ff 75 0c             	pushl  0xc(%ebp)
  800205:	ff 75 08             	pushl  0x8(%ebp)
  800208:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80020e:	50                   	push   %eax
  80020f:	68 a2 01 80 00       	push   $0x8001a2
  800214:	e8 0f 01 00 00       	call   800328 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800219:	83 c4 08             	add    $0x8,%esp
  80021c:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800222:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800228:	50                   	push   %eax
  800229:	e8 91 fe ff ff       	call   8000bf <sys_cputs>

	return b.cnt;
}
  80022e:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800234:	c9                   	leave  
  800235:	c3                   	ret    

00800236 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800236:	55                   	push   %ebp
  800237:	89 e5                	mov    %esp,%ebp
  800239:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80023c:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80023f:	50                   	push   %eax
  800240:	ff 75 08             	pushl  0x8(%ebp)
  800243:	e8 9d ff ff ff       	call   8001e5 <vcprintf>
	va_end(ap);

	return cnt;
}
  800248:	c9                   	leave  
  800249:	c3                   	ret    

0080024a <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80024a:	55                   	push   %ebp
  80024b:	89 e5                	mov    %esp,%ebp
  80024d:	57                   	push   %edi
  80024e:	56                   	push   %esi
  80024f:	53                   	push   %ebx
  800250:	83 ec 1c             	sub    $0x1c,%esp
  800253:	89 c7                	mov    %eax,%edi
  800255:	89 d6                	mov    %edx,%esi
  800257:	8b 45 08             	mov    0x8(%ebp),%eax
  80025a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80025d:	89 d1                	mov    %edx,%ecx
  80025f:	89 c2                	mov    %eax,%edx
  800261:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800264:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800267:	8b 45 10             	mov    0x10(%ebp),%eax
  80026a:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80026d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800270:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800277:	39 c2                	cmp    %eax,%edx
  800279:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  80027c:	72 3c                	jb     8002ba <printnum+0x70>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80027e:	83 ec 0c             	sub    $0xc,%esp
  800281:	ff 75 18             	pushl  0x18(%ebp)
  800284:	4b                   	dec    %ebx
  800285:	53                   	push   %ebx
  800286:	50                   	push   %eax
  800287:	83 ec 08             	sub    $0x8,%esp
  80028a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80028d:	ff 75 e0             	pushl  -0x20(%ebp)
  800290:	ff 75 dc             	pushl  -0x24(%ebp)
  800293:	ff 75 d8             	pushl  -0x28(%ebp)
  800296:	e8 55 08 00 00       	call   800af0 <__udivdi3>
  80029b:	83 c4 18             	add    $0x18,%esp
  80029e:	52                   	push   %edx
  80029f:	50                   	push   %eax
  8002a0:	89 f2                	mov    %esi,%edx
  8002a2:	89 f8                	mov    %edi,%eax
  8002a4:	e8 a1 ff ff ff       	call   80024a <printnum>
  8002a9:	83 c4 20             	add    $0x20,%esp
  8002ac:	eb 11                	jmp    8002bf <printnum+0x75>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002ae:	83 ec 08             	sub    $0x8,%esp
  8002b1:	56                   	push   %esi
  8002b2:	ff 75 18             	pushl  0x18(%ebp)
  8002b5:	ff d7                	call   *%edi
  8002b7:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8002ba:	4b                   	dec    %ebx
  8002bb:	85 db                	test   %ebx,%ebx
  8002bd:	7f ef                	jg     8002ae <printnum+0x64>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002bf:	83 ec 08             	sub    $0x8,%esp
  8002c2:	56                   	push   %esi
  8002c3:	83 ec 04             	sub    $0x4,%esp
  8002c6:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002c9:	ff 75 e0             	pushl  -0x20(%ebp)
  8002cc:	ff 75 dc             	pushl  -0x24(%ebp)
  8002cf:	ff 75 d8             	pushl  -0x28(%ebp)
  8002d2:	e8 19 09 00 00       	call   800bf0 <__umoddi3>
  8002d7:	83 c4 14             	add    $0x14,%esp
  8002da:	0f be 80 80 0d 80 00 	movsbl 0x800d80(%eax),%eax
  8002e1:	50                   	push   %eax
  8002e2:	ff d7                	call   *%edi
}
  8002e4:	83 c4 10             	add    $0x10,%esp
  8002e7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002ea:	5b                   	pop    %ebx
  8002eb:	5e                   	pop    %esi
  8002ec:	5f                   	pop    %edi
  8002ed:	5d                   	pop    %ebp
  8002ee:	c3                   	ret    

008002ef <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002ef:	55                   	push   %ebp
  8002f0:	89 e5                	mov    %esp,%ebp
  8002f2:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002f5:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8002f8:	8b 10                	mov    (%eax),%edx
  8002fa:	3b 50 04             	cmp    0x4(%eax),%edx
  8002fd:	73 0a                	jae    800309 <sprintputch+0x1a>
		*b->buf++ = ch;
  8002ff:	8d 4a 01             	lea    0x1(%edx),%ecx
  800302:	89 08                	mov    %ecx,(%eax)
  800304:	8b 45 08             	mov    0x8(%ebp),%eax
  800307:	88 02                	mov    %al,(%edx)
}
  800309:	5d                   	pop    %ebp
  80030a:	c3                   	ret    

0080030b <printfmt>:
{
  80030b:	55                   	push   %ebp
  80030c:	89 e5                	mov    %esp,%ebp
  80030e:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800311:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800314:	50                   	push   %eax
  800315:	ff 75 10             	pushl  0x10(%ebp)
  800318:	ff 75 0c             	pushl  0xc(%ebp)
  80031b:	ff 75 08             	pushl  0x8(%ebp)
  80031e:	e8 05 00 00 00       	call   800328 <vprintfmt>
}
  800323:	83 c4 10             	add    $0x10,%esp
  800326:	c9                   	leave  
  800327:	c3                   	ret    

00800328 <vprintfmt>:
{
  800328:	55                   	push   %ebp
  800329:	89 e5                	mov    %esp,%ebp
  80032b:	57                   	push   %edi
  80032c:	56                   	push   %esi
  80032d:	53                   	push   %ebx
  80032e:	83 ec 3c             	sub    $0x3c,%esp
  800331:	8b 75 08             	mov    0x8(%ebp),%esi
  800334:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800337:	8b 7d 10             	mov    0x10(%ebp),%edi
  80033a:	e9 5b 03 00 00       	jmp    80069a <vprintfmt+0x372>
		padc = ' ';
  80033f:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  800343:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
		precision = -1;
  80034a:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  800351:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		lflag = 0;
  800358:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80035d:	8d 47 01             	lea    0x1(%edi),%eax
  800360:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800363:	8a 17                	mov    (%edi),%dl
  800365:	8d 42 dd             	lea    -0x23(%edx),%eax
  800368:	3c 55                	cmp    $0x55,%al
  80036a:	0f 87 ab 03 00 00    	ja     80071b <vprintfmt+0x3f3>
  800370:	0f b6 c0             	movzbl %al,%eax
  800373:	ff 24 85 10 0e 80 00 	jmp    *0x800e10(,%eax,4)
  80037a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  80037d:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  800381:	eb da                	jmp    80035d <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  800383:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800386:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  80038a:	eb d1                	jmp    80035d <vprintfmt+0x35>
  80038c:	0f b6 d2             	movzbl %dl,%edx
  80038f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800392:	b8 00 00 00 00       	mov    $0x0,%eax
  800397:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  80039a:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80039d:	01 c0                	add    %eax,%eax
  80039f:	8d 44 02 d0          	lea    -0x30(%edx,%eax,1),%eax
				ch = *fmt;
  8003a3:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8003a6:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8003a9:	83 f9 09             	cmp    $0x9,%ecx
  8003ac:	77 52                	ja     800400 <vprintfmt+0xd8>
			for (precision = 0; ; ++fmt) {
  8003ae:	47                   	inc    %edi
				precision = precision * 10 + ch - '0';
  8003af:	eb e9                	jmp    80039a <vprintfmt+0x72>
			precision = va_arg(ap, int);
  8003b1:	8b 45 14             	mov    0x14(%ebp),%eax
  8003b4:	8b 00                	mov    (%eax),%eax
  8003b6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003b9:	8b 45 14             	mov    0x14(%ebp),%eax
  8003bc:	8d 40 04             	lea    0x4(%eax),%eax
  8003bf:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003c2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8003c5:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8003c9:	79 92                	jns    80035d <vprintfmt+0x35>
				width = precision, precision = -1;
  8003cb:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8003ce:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8003d1:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8003d8:	eb 83                	jmp    80035d <vprintfmt+0x35>
  8003da:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8003de:	78 08                	js     8003e8 <vprintfmt+0xc0>
		switch (ch = *(unsigned char *) fmt++) {
  8003e0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8003e3:	e9 75 ff ff ff       	jmp    80035d <vprintfmt+0x35>
  8003e8:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  8003ef:	eb ef                	jmp    8003e0 <vprintfmt+0xb8>
		switch (ch = *(unsigned char *) fmt++) {
  8003f1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8003f4:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  8003fb:	e9 5d ff ff ff       	jmp    80035d <vprintfmt+0x35>
  800400:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800403:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800406:	eb bd                	jmp    8003c5 <vprintfmt+0x9d>
			lflag++;
  800408:	41                   	inc    %ecx
		switch (ch = *(unsigned char *) fmt++) {
  800409:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80040c:	e9 4c ff ff ff       	jmp    80035d <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
  800411:	8b 45 14             	mov    0x14(%ebp),%eax
  800414:	8d 78 04             	lea    0x4(%eax),%edi
  800417:	83 ec 08             	sub    $0x8,%esp
  80041a:	53                   	push   %ebx
  80041b:	ff 30                	pushl  (%eax)
  80041d:	ff d6                	call   *%esi
			break;
  80041f:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800422:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800425:	e9 6d 02 00 00       	jmp    800697 <vprintfmt+0x36f>
			err = va_arg(ap, int);
  80042a:	8b 45 14             	mov    0x14(%ebp),%eax
  80042d:	8d 78 04             	lea    0x4(%eax),%edi
  800430:	8b 00                	mov    (%eax),%eax
  800432:	85 c0                	test   %eax,%eax
  800434:	78 2a                	js     800460 <vprintfmt+0x138>
  800436:	89 c2                	mov    %eax,%edx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800438:	83 f8 06             	cmp    $0x6,%eax
  80043b:	7f 27                	jg     800464 <vprintfmt+0x13c>
  80043d:	8b 04 85 68 0f 80 00 	mov    0x800f68(,%eax,4),%eax
  800444:	85 c0                	test   %eax,%eax
  800446:	74 1c                	je     800464 <vprintfmt+0x13c>
				printfmt(putch, putdat, "%s", p);
  800448:	50                   	push   %eax
  800449:	68 a1 0d 80 00       	push   $0x800da1
  80044e:	53                   	push   %ebx
  80044f:	56                   	push   %esi
  800450:	e8 b6 fe ff ff       	call   80030b <printfmt>
  800455:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800458:	89 7d 14             	mov    %edi,0x14(%ebp)
  80045b:	e9 37 02 00 00       	jmp    800697 <vprintfmt+0x36f>
  800460:	f7 d8                	neg    %eax
  800462:	eb d2                	jmp    800436 <vprintfmt+0x10e>
				printfmt(putch, putdat, "error %d", err);
  800464:	52                   	push   %edx
  800465:	68 98 0d 80 00       	push   $0x800d98
  80046a:	53                   	push   %ebx
  80046b:	56                   	push   %esi
  80046c:	e8 9a fe ff ff       	call   80030b <printfmt>
  800471:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800474:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800477:	e9 1b 02 00 00       	jmp    800697 <vprintfmt+0x36f>
			if ((p = va_arg(ap, char *)) == NULL)
  80047c:	8b 45 14             	mov    0x14(%ebp),%eax
  80047f:	83 c0 04             	add    $0x4,%eax
  800482:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800485:	8b 45 14             	mov    0x14(%ebp),%eax
  800488:	8b 00                	mov    (%eax),%eax
  80048a:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80048d:	85 c0                	test   %eax,%eax
  80048f:	74 19                	je     8004aa <vprintfmt+0x182>
			if (width > 0 && padc != '-')
  800491:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800495:	7e 06                	jle    80049d <vprintfmt+0x175>
  800497:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  80049b:	75 16                	jne    8004b3 <vprintfmt+0x18b>
				for (width -= strnlen(p, precision); width > 0; width--)
  80049d:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8004a0:	89 c7                	mov    %eax,%edi
  8004a2:	03 45 d4             	add    -0x2c(%ebp),%eax
  8004a5:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8004a8:	eb 62                	jmp    80050c <vprintfmt+0x1e4>
				p = "(null)";
  8004aa:	c7 45 cc 91 0d 80 00 	movl   $0x800d91,-0x34(%ebp)
  8004b1:	eb de                	jmp    800491 <vprintfmt+0x169>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004b3:	83 ec 08             	sub    $0x8,%esp
  8004b6:	ff 75 d8             	pushl  -0x28(%ebp)
  8004b9:	ff 75 cc             	pushl  -0x34(%ebp)
  8004bc:	e8 05 03 00 00       	call   8007c6 <strnlen>
  8004c1:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8004c4:	29 c2                	sub    %eax,%edx
  8004c6:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  8004c9:	83 c4 10             	add    $0x10,%esp
  8004cc:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  8004ce:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8004d2:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8004d5:	eb 0d                	jmp    8004e4 <vprintfmt+0x1bc>
					putch(padc, putdat);
  8004d7:	83 ec 08             	sub    $0x8,%esp
  8004da:	53                   	push   %ebx
  8004db:	ff 75 d4             	pushl  -0x2c(%ebp)
  8004de:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8004e0:	4f                   	dec    %edi
  8004e1:	83 c4 10             	add    $0x10,%esp
  8004e4:	85 ff                	test   %edi,%edi
  8004e6:	7f ef                	jg     8004d7 <vprintfmt+0x1af>
  8004e8:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8004eb:	89 d0                	mov    %edx,%eax
  8004ed:	85 d2                	test   %edx,%edx
  8004ef:	78 0a                	js     8004fb <vprintfmt+0x1d3>
  8004f1:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8004f4:	29 c2                	sub    %eax,%edx
  8004f6:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8004f9:	eb a2                	jmp    80049d <vprintfmt+0x175>
  8004fb:	b8 00 00 00 00       	mov    $0x0,%eax
  800500:	eb ef                	jmp    8004f1 <vprintfmt+0x1c9>
					putch(ch, putdat);
  800502:	83 ec 08             	sub    $0x8,%esp
  800505:	53                   	push   %ebx
  800506:	52                   	push   %edx
  800507:	ff d6                	call   *%esi
  800509:	83 c4 10             	add    $0x10,%esp
  80050c:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  80050f:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800511:	47                   	inc    %edi
  800512:	8a 47 ff             	mov    -0x1(%edi),%al
  800515:	0f be d0             	movsbl %al,%edx
  800518:	85 d2                	test   %edx,%edx
  80051a:	74 48                	je     800564 <vprintfmt+0x23c>
  80051c:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800520:	78 05                	js     800527 <vprintfmt+0x1ff>
  800522:	ff 4d d8             	decl   -0x28(%ebp)
  800525:	78 1e                	js     800545 <vprintfmt+0x21d>
				if (altflag && (ch < ' ' || ch > '~'))
  800527:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80052b:	74 d5                	je     800502 <vprintfmt+0x1da>
  80052d:	0f be c0             	movsbl %al,%eax
  800530:	83 e8 20             	sub    $0x20,%eax
  800533:	83 f8 5e             	cmp    $0x5e,%eax
  800536:	76 ca                	jbe    800502 <vprintfmt+0x1da>
					putch('?', putdat);
  800538:	83 ec 08             	sub    $0x8,%esp
  80053b:	53                   	push   %ebx
  80053c:	6a 3f                	push   $0x3f
  80053e:	ff d6                	call   *%esi
  800540:	83 c4 10             	add    $0x10,%esp
  800543:	eb c7                	jmp    80050c <vprintfmt+0x1e4>
  800545:	89 cf                	mov    %ecx,%edi
  800547:	eb 0c                	jmp    800555 <vprintfmt+0x22d>
				putch(' ', putdat);
  800549:	83 ec 08             	sub    $0x8,%esp
  80054c:	53                   	push   %ebx
  80054d:	6a 20                	push   $0x20
  80054f:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800551:	4f                   	dec    %edi
  800552:	83 c4 10             	add    $0x10,%esp
  800555:	85 ff                	test   %edi,%edi
  800557:	7f f0                	jg     800549 <vprintfmt+0x221>
			if ((p = va_arg(ap, char *)) == NULL)
  800559:	8b 45 c8             	mov    -0x38(%ebp),%eax
  80055c:	89 45 14             	mov    %eax,0x14(%ebp)
  80055f:	e9 33 01 00 00       	jmp    800697 <vprintfmt+0x36f>
  800564:	89 cf                	mov    %ecx,%edi
  800566:	eb ed                	jmp    800555 <vprintfmt+0x22d>
	if (lflag >= 2)
  800568:	83 f9 01             	cmp    $0x1,%ecx
  80056b:	7f 1b                	jg     800588 <vprintfmt+0x260>
	else if (lflag)
  80056d:	85 c9                	test   %ecx,%ecx
  80056f:	74 42                	je     8005b3 <vprintfmt+0x28b>
		return va_arg(*ap, long);
  800571:	8b 45 14             	mov    0x14(%ebp),%eax
  800574:	8b 00                	mov    (%eax),%eax
  800576:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800579:	99                   	cltd   
  80057a:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80057d:	8b 45 14             	mov    0x14(%ebp),%eax
  800580:	8d 40 04             	lea    0x4(%eax),%eax
  800583:	89 45 14             	mov    %eax,0x14(%ebp)
  800586:	eb 17                	jmp    80059f <vprintfmt+0x277>
		return va_arg(*ap, long long);
  800588:	8b 45 14             	mov    0x14(%ebp),%eax
  80058b:	8b 50 04             	mov    0x4(%eax),%edx
  80058e:	8b 00                	mov    (%eax),%eax
  800590:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800593:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800596:	8b 45 14             	mov    0x14(%ebp),%eax
  800599:	8d 40 08             	lea    0x8(%eax),%eax
  80059c:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  80059f:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005a2:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8005a5:	85 c9                	test   %ecx,%ecx
  8005a7:	78 21                	js     8005ca <vprintfmt+0x2a2>
			base = 10;
  8005a9:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005ae:	e9 ca 00 00 00       	jmp    80067d <vprintfmt+0x355>
		return va_arg(*ap, int);
  8005b3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b6:	8b 00                	mov    (%eax),%eax
  8005b8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005bb:	99                   	cltd   
  8005bc:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005bf:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c2:	8d 40 04             	lea    0x4(%eax),%eax
  8005c5:	89 45 14             	mov    %eax,0x14(%ebp)
  8005c8:	eb d5                	jmp    80059f <vprintfmt+0x277>
				putch('-', putdat);
  8005ca:	83 ec 08             	sub    $0x8,%esp
  8005cd:	53                   	push   %ebx
  8005ce:	6a 2d                	push   $0x2d
  8005d0:	ff d6                	call   *%esi
				num = -(long long) num;
  8005d2:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005d5:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8005d8:	f7 da                	neg    %edx
  8005da:	83 d1 00             	adc    $0x0,%ecx
  8005dd:	f7 d9                	neg    %ecx
  8005df:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8005e2:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005e7:	e9 91 00 00 00       	jmp    80067d <vprintfmt+0x355>
	if (lflag >= 2)
  8005ec:	83 f9 01             	cmp    $0x1,%ecx
  8005ef:	7f 1b                	jg     80060c <vprintfmt+0x2e4>
	else if (lflag)
  8005f1:	85 c9                	test   %ecx,%ecx
  8005f3:	74 2c                	je     800621 <vprintfmt+0x2f9>
		return va_arg(*ap, unsigned long);
  8005f5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f8:	8b 10                	mov    (%eax),%edx
  8005fa:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005ff:	8d 40 04             	lea    0x4(%eax),%eax
  800602:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800605:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  80060a:	eb 71                	jmp    80067d <vprintfmt+0x355>
		return va_arg(*ap, unsigned long long);
  80060c:	8b 45 14             	mov    0x14(%ebp),%eax
  80060f:	8b 10                	mov    (%eax),%edx
  800611:	8b 48 04             	mov    0x4(%eax),%ecx
  800614:	8d 40 08             	lea    0x8(%eax),%eax
  800617:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80061a:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  80061f:	eb 5c                	jmp    80067d <vprintfmt+0x355>
		return va_arg(*ap, unsigned int);
  800621:	8b 45 14             	mov    0x14(%ebp),%eax
  800624:	8b 10                	mov    (%eax),%edx
  800626:	b9 00 00 00 00       	mov    $0x0,%ecx
  80062b:	8d 40 04             	lea    0x4(%eax),%eax
  80062e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800631:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  800636:	eb 45                	jmp    80067d <vprintfmt+0x355>
			putch('X', putdat);
  800638:	83 ec 08             	sub    $0x8,%esp
  80063b:	53                   	push   %ebx
  80063c:	6a 58                	push   $0x58
  80063e:	ff d6                	call   *%esi
			putch('X', putdat);
  800640:	83 c4 08             	add    $0x8,%esp
  800643:	53                   	push   %ebx
  800644:	6a 58                	push   $0x58
  800646:	ff d6                	call   *%esi
			putch('X', putdat);
  800648:	83 c4 08             	add    $0x8,%esp
  80064b:	53                   	push   %ebx
  80064c:	6a 58                	push   $0x58
  80064e:	ff d6                	call   *%esi
			break;
  800650:	83 c4 10             	add    $0x10,%esp
  800653:	eb 42                	jmp    800697 <vprintfmt+0x36f>
			putch('0', putdat);
  800655:	83 ec 08             	sub    $0x8,%esp
  800658:	53                   	push   %ebx
  800659:	6a 30                	push   $0x30
  80065b:	ff d6                	call   *%esi
			putch('x', putdat);
  80065d:	83 c4 08             	add    $0x8,%esp
  800660:	53                   	push   %ebx
  800661:	6a 78                	push   $0x78
  800663:	ff d6                	call   *%esi
			num = (unsigned long long)
  800665:	8b 45 14             	mov    0x14(%ebp),%eax
  800668:	8b 10                	mov    (%eax),%edx
  80066a:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  80066f:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800672:	8d 40 04             	lea    0x4(%eax),%eax
  800675:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800678:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  80067d:	83 ec 0c             	sub    $0xc,%esp
  800680:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  800684:	57                   	push   %edi
  800685:	ff 75 d4             	pushl  -0x2c(%ebp)
  800688:	50                   	push   %eax
  800689:	51                   	push   %ecx
  80068a:	52                   	push   %edx
  80068b:	89 da                	mov    %ebx,%edx
  80068d:	89 f0                	mov    %esi,%eax
  80068f:	e8 b6 fb ff ff       	call   80024a <printnum>
			break;
  800694:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  800697:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80069a:	47                   	inc    %edi
  80069b:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80069f:	83 f8 25             	cmp    $0x25,%eax
  8006a2:	0f 84 97 fc ff ff    	je     80033f <vprintfmt+0x17>
			if (ch == '\0')
  8006a8:	85 c0                	test   %eax,%eax
  8006aa:	0f 84 89 00 00 00    	je     800739 <vprintfmt+0x411>
			putch(ch, putdat);
  8006b0:	83 ec 08             	sub    $0x8,%esp
  8006b3:	53                   	push   %ebx
  8006b4:	50                   	push   %eax
  8006b5:	ff d6                	call   *%esi
  8006b7:	83 c4 10             	add    $0x10,%esp
  8006ba:	eb de                	jmp    80069a <vprintfmt+0x372>
	if (lflag >= 2)
  8006bc:	83 f9 01             	cmp    $0x1,%ecx
  8006bf:	7f 1b                	jg     8006dc <vprintfmt+0x3b4>
	else if (lflag)
  8006c1:	85 c9                	test   %ecx,%ecx
  8006c3:	74 2c                	je     8006f1 <vprintfmt+0x3c9>
		return va_arg(*ap, unsigned long);
  8006c5:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c8:	8b 10                	mov    (%eax),%edx
  8006ca:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006cf:	8d 40 04             	lea    0x4(%eax),%eax
  8006d2:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006d5:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  8006da:	eb a1                	jmp    80067d <vprintfmt+0x355>
		return va_arg(*ap, unsigned long long);
  8006dc:	8b 45 14             	mov    0x14(%ebp),%eax
  8006df:	8b 10                	mov    (%eax),%edx
  8006e1:	8b 48 04             	mov    0x4(%eax),%ecx
  8006e4:	8d 40 08             	lea    0x8(%eax),%eax
  8006e7:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006ea:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  8006ef:	eb 8c                	jmp    80067d <vprintfmt+0x355>
		return va_arg(*ap, unsigned int);
  8006f1:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f4:	8b 10                	mov    (%eax),%edx
  8006f6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006fb:	8d 40 04             	lea    0x4(%eax),%eax
  8006fe:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800701:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  800706:	e9 72 ff ff ff       	jmp    80067d <vprintfmt+0x355>
			putch(ch, putdat);
  80070b:	83 ec 08             	sub    $0x8,%esp
  80070e:	53                   	push   %ebx
  80070f:	6a 25                	push   $0x25
  800711:	ff d6                	call   *%esi
			break;
  800713:	83 c4 10             	add    $0x10,%esp
  800716:	e9 7c ff ff ff       	jmp    800697 <vprintfmt+0x36f>
			putch('%', putdat);
  80071b:	83 ec 08             	sub    $0x8,%esp
  80071e:	53                   	push   %ebx
  80071f:	6a 25                	push   $0x25
  800721:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800723:	83 c4 10             	add    $0x10,%esp
  800726:	89 f8                	mov    %edi,%eax
  800728:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  80072c:	74 03                	je     800731 <vprintfmt+0x409>
  80072e:	48                   	dec    %eax
  80072f:	eb f7                	jmp    800728 <vprintfmt+0x400>
  800731:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800734:	e9 5e ff ff ff       	jmp    800697 <vprintfmt+0x36f>
}
  800739:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80073c:	5b                   	pop    %ebx
  80073d:	5e                   	pop    %esi
  80073e:	5f                   	pop    %edi
  80073f:	5d                   	pop    %ebp
  800740:	c3                   	ret    

00800741 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800741:	55                   	push   %ebp
  800742:	89 e5                	mov    %esp,%ebp
  800744:	83 ec 18             	sub    $0x18,%esp
  800747:	8b 45 08             	mov    0x8(%ebp),%eax
  80074a:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80074d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800750:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800754:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800757:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80075e:	85 c0                	test   %eax,%eax
  800760:	74 26                	je     800788 <vsnprintf+0x47>
  800762:	85 d2                	test   %edx,%edx
  800764:	7e 29                	jle    80078f <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800766:	ff 75 14             	pushl  0x14(%ebp)
  800769:	ff 75 10             	pushl  0x10(%ebp)
  80076c:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80076f:	50                   	push   %eax
  800770:	68 ef 02 80 00       	push   $0x8002ef
  800775:	e8 ae fb ff ff       	call   800328 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80077a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80077d:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800780:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800783:	83 c4 10             	add    $0x10,%esp
}
  800786:	c9                   	leave  
  800787:	c3                   	ret    
		return -E_INVAL;
  800788:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80078d:	eb f7                	jmp    800786 <vsnprintf+0x45>
  80078f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800794:	eb f0                	jmp    800786 <vsnprintf+0x45>

00800796 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800796:	55                   	push   %ebp
  800797:	89 e5                	mov    %esp,%ebp
  800799:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80079c:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80079f:	50                   	push   %eax
  8007a0:	ff 75 10             	pushl  0x10(%ebp)
  8007a3:	ff 75 0c             	pushl  0xc(%ebp)
  8007a6:	ff 75 08             	pushl  0x8(%ebp)
  8007a9:	e8 93 ff ff ff       	call   800741 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007ae:	c9                   	leave  
  8007af:	c3                   	ret    

008007b0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007b0:	55                   	push   %ebp
  8007b1:	89 e5                	mov    %esp,%ebp
  8007b3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007b6:	b8 00 00 00 00       	mov    $0x0,%eax
  8007bb:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007bf:	74 03                	je     8007c4 <strlen+0x14>
		n++;
  8007c1:	40                   	inc    %eax
  8007c2:	eb f7                	jmp    8007bb <strlen+0xb>
	return n;
}
  8007c4:	5d                   	pop    %ebp
  8007c5:	c3                   	ret    

008007c6 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007c6:	55                   	push   %ebp
  8007c7:	89 e5                	mov    %esp,%ebp
  8007c9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007cc:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007cf:	b8 00 00 00 00       	mov    $0x0,%eax
  8007d4:	39 d0                	cmp    %edx,%eax
  8007d6:	74 0b                	je     8007e3 <strnlen+0x1d>
  8007d8:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007dc:	74 03                	je     8007e1 <strnlen+0x1b>
		n++;
  8007de:	40                   	inc    %eax
  8007df:	eb f3                	jmp    8007d4 <strnlen+0xe>
  8007e1:	89 c2                	mov    %eax,%edx
	return n;
}
  8007e3:	89 d0                	mov    %edx,%eax
  8007e5:	5d                   	pop    %ebp
  8007e6:	c3                   	ret    

008007e7 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007e7:	55                   	push   %ebp
  8007e8:	89 e5                	mov    %esp,%ebp
  8007ea:	53                   	push   %ebx
  8007eb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007ee:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007f1:	b8 00 00 00 00       	mov    $0x0,%eax
  8007f6:	8a 14 03             	mov    (%ebx,%eax,1),%dl
  8007f9:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8007fc:	40                   	inc    %eax
  8007fd:	84 d2                	test   %dl,%dl
  8007ff:	75 f5                	jne    8007f6 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800801:	89 c8                	mov    %ecx,%eax
  800803:	5b                   	pop    %ebx
  800804:	5d                   	pop    %ebp
  800805:	c3                   	ret    

00800806 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800806:	55                   	push   %ebp
  800807:	89 e5                	mov    %esp,%ebp
  800809:	53                   	push   %ebx
  80080a:	83 ec 10             	sub    $0x10,%esp
  80080d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800810:	53                   	push   %ebx
  800811:	e8 9a ff ff ff       	call   8007b0 <strlen>
  800816:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800819:	ff 75 0c             	pushl  0xc(%ebp)
  80081c:	01 d8                	add    %ebx,%eax
  80081e:	50                   	push   %eax
  80081f:	e8 c3 ff ff ff       	call   8007e7 <strcpy>
	return dst;
}
  800824:	89 d8                	mov    %ebx,%eax
  800826:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800829:	c9                   	leave  
  80082a:	c3                   	ret    

0080082b <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80082b:	55                   	push   %ebp
  80082c:	89 e5                	mov    %esp,%ebp
  80082e:	53                   	push   %ebx
  80082f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800832:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800835:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800838:	8b 45 08             	mov    0x8(%ebp),%eax
  80083b:	39 d8                	cmp    %ebx,%eax
  80083d:	74 0e                	je     80084d <strncpy+0x22>
		*dst++ = *src;
  80083f:	40                   	inc    %eax
  800840:	8a 0a                	mov    (%edx),%cl
  800842:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800845:	80 f9 01             	cmp    $0x1,%cl
  800848:	83 da ff             	sbb    $0xffffffff,%edx
  80084b:	eb ee                	jmp    80083b <strncpy+0x10>
	}
	return ret;
}
  80084d:	8b 45 08             	mov    0x8(%ebp),%eax
  800850:	5b                   	pop    %ebx
  800851:	5d                   	pop    %ebp
  800852:	c3                   	ret    

00800853 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800853:	55                   	push   %ebp
  800854:	89 e5                	mov    %esp,%ebp
  800856:	56                   	push   %esi
  800857:	53                   	push   %ebx
  800858:	8b 75 08             	mov    0x8(%ebp),%esi
  80085b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80085e:	8b 45 10             	mov    0x10(%ebp),%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800861:	85 c0                	test   %eax,%eax
  800863:	74 22                	je     800887 <strlcpy+0x34>
  800865:	8d 44 06 ff          	lea    -0x1(%esi,%eax,1),%eax
  800869:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  80086b:	39 c2                	cmp    %eax,%edx
  80086d:	74 0f                	je     80087e <strlcpy+0x2b>
  80086f:	8a 19                	mov    (%ecx),%bl
  800871:	84 db                	test   %bl,%bl
  800873:	74 07                	je     80087c <strlcpy+0x29>
			*dst++ = *src++;
  800875:	41                   	inc    %ecx
  800876:	42                   	inc    %edx
  800877:	88 5a ff             	mov    %bl,-0x1(%edx)
  80087a:	eb ef                	jmp    80086b <strlcpy+0x18>
  80087c:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  80087e:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800881:	29 f0                	sub    %esi,%eax
}
  800883:	5b                   	pop    %ebx
  800884:	5e                   	pop    %esi
  800885:	5d                   	pop    %ebp
  800886:	c3                   	ret    
  800887:	89 f0                	mov    %esi,%eax
  800889:	eb f6                	jmp    800881 <strlcpy+0x2e>

0080088b <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80088b:	55                   	push   %ebp
  80088c:	89 e5                	mov    %esp,%ebp
  80088e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800891:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800894:	8a 01                	mov    (%ecx),%al
  800896:	84 c0                	test   %al,%al
  800898:	74 08                	je     8008a2 <strcmp+0x17>
  80089a:	3a 02                	cmp    (%edx),%al
  80089c:	75 04                	jne    8008a2 <strcmp+0x17>
		p++, q++;
  80089e:	41                   	inc    %ecx
  80089f:	42                   	inc    %edx
  8008a0:	eb f2                	jmp    800894 <strcmp+0x9>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008a2:	0f b6 c0             	movzbl %al,%eax
  8008a5:	0f b6 12             	movzbl (%edx),%edx
  8008a8:	29 d0                	sub    %edx,%eax
}
  8008aa:	5d                   	pop    %ebp
  8008ab:	c3                   	ret    

008008ac <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008ac:	55                   	push   %ebp
  8008ad:	89 e5                	mov    %esp,%ebp
  8008af:	53                   	push   %ebx
  8008b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008b6:	89 c3                	mov    %eax,%ebx
  8008b8:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008bb:	eb 02                	jmp    8008bf <strncmp+0x13>
		n--, p++, q++;
  8008bd:	40                   	inc    %eax
  8008be:	42                   	inc    %edx
	while (n > 0 && *p && *p == *q)
  8008bf:	39 d8                	cmp    %ebx,%eax
  8008c1:	74 15                	je     8008d8 <strncmp+0x2c>
  8008c3:	8a 08                	mov    (%eax),%cl
  8008c5:	84 c9                	test   %cl,%cl
  8008c7:	74 04                	je     8008cd <strncmp+0x21>
  8008c9:	3a 0a                	cmp    (%edx),%cl
  8008cb:	74 f0                	je     8008bd <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008cd:	0f b6 00             	movzbl (%eax),%eax
  8008d0:	0f b6 12             	movzbl (%edx),%edx
  8008d3:	29 d0                	sub    %edx,%eax
}
  8008d5:	5b                   	pop    %ebx
  8008d6:	5d                   	pop    %ebp
  8008d7:	c3                   	ret    
		return 0;
  8008d8:	b8 00 00 00 00       	mov    $0x0,%eax
  8008dd:	eb f6                	jmp    8008d5 <strncmp+0x29>

008008df <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008df:	55                   	push   %ebp
  8008e0:	89 e5                	mov    %esp,%ebp
  8008e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e5:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8008e8:	8a 10                	mov    (%eax),%dl
  8008ea:	84 d2                	test   %dl,%dl
  8008ec:	74 07                	je     8008f5 <strchr+0x16>
		if (*s == c)
  8008ee:	38 ca                	cmp    %cl,%dl
  8008f0:	74 08                	je     8008fa <strchr+0x1b>
	for (; *s; s++)
  8008f2:	40                   	inc    %eax
  8008f3:	eb f3                	jmp    8008e8 <strchr+0x9>
			return (char *) s;
	return 0;
  8008f5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008fa:	5d                   	pop    %ebp
  8008fb:	c3                   	ret    

008008fc <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008fc:	55                   	push   %ebp
  8008fd:	89 e5                	mov    %esp,%ebp
  8008ff:	8b 45 08             	mov    0x8(%ebp),%eax
  800902:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800905:	8a 10                	mov    (%eax),%dl
  800907:	84 d2                	test   %dl,%dl
  800909:	74 07                	je     800912 <strfind+0x16>
		if (*s == c)
  80090b:	38 ca                	cmp    %cl,%dl
  80090d:	74 03                	je     800912 <strfind+0x16>
	for (; *s; s++)
  80090f:	40                   	inc    %eax
  800910:	eb f3                	jmp    800905 <strfind+0x9>
			break;
	return (char *) s;
}
  800912:	5d                   	pop    %ebp
  800913:	c3                   	ret    

00800914 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800914:	55                   	push   %ebp
  800915:	89 e5                	mov    %esp,%ebp
  800917:	57                   	push   %edi
  800918:	56                   	push   %esi
  800919:	53                   	push   %ebx
  80091a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80091d:	85 c9                	test   %ecx,%ecx
  80091f:	74 36                	je     800957 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800921:	89 c8                	mov    %ecx,%eax
  800923:	0b 45 08             	or     0x8(%ebp),%eax
  800926:	a8 03                	test   $0x3,%al
  800928:	75 24                	jne    80094e <memset+0x3a>
		c &= 0xFF;
  80092a:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80092e:	89 d3                	mov    %edx,%ebx
  800930:	c1 e3 08             	shl    $0x8,%ebx
  800933:	89 d0                	mov    %edx,%eax
  800935:	c1 e0 18             	shl    $0x18,%eax
  800938:	89 d6                	mov    %edx,%esi
  80093a:	c1 e6 10             	shl    $0x10,%esi
  80093d:	09 f0                	or     %esi,%eax
  80093f:	09 d0                	or     %edx,%eax
  800941:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800943:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800946:	8b 7d 08             	mov    0x8(%ebp),%edi
  800949:	fc                   	cld    
  80094a:	f3 ab                	rep stos %eax,%es:(%edi)
  80094c:	eb 09                	jmp    800957 <memset+0x43>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80094e:	8b 7d 08             	mov    0x8(%ebp),%edi
  800951:	8b 45 0c             	mov    0xc(%ebp),%eax
  800954:	fc                   	cld    
  800955:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800957:	8b 45 08             	mov    0x8(%ebp),%eax
  80095a:	5b                   	pop    %ebx
  80095b:	5e                   	pop    %esi
  80095c:	5f                   	pop    %edi
  80095d:	5d                   	pop    %ebp
  80095e:	c3                   	ret    

0080095f <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80095f:	55                   	push   %ebp
  800960:	89 e5                	mov    %esp,%ebp
  800962:	57                   	push   %edi
  800963:	56                   	push   %esi
  800964:	8b 45 08             	mov    0x8(%ebp),%eax
  800967:	8b 75 0c             	mov    0xc(%ebp),%esi
  80096a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80096d:	39 c6                	cmp    %eax,%esi
  80096f:	73 30                	jae    8009a1 <memmove+0x42>
  800971:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800974:	39 c2                	cmp    %eax,%edx
  800976:	76 29                	jbe    8009a1 <memmove+0x42>
		s += n;
		d += n;
  800978:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80097b:	89 fe                	mov    %edi,%esi
  80097d:	09 ce                	or     %ecx,%esi
  80097f:	09 d6                	or     %edx,%esi
  800981:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800987:	75 0e                	jne    800997 <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800989:	83 ef 04             	sub    $0x4,%edi
  80098c:	8d 72 fc             	lea    -0x4(%edx),%esi
  80098f:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800992:	fd                   	std    
  800993:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800995:	eb 07                	jmp    80099e <memmove+0x3f>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800997:	4f                   	dec    %edi
  800998:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  80099b:	fd                   	std    
  80099c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80099e:	fc                   	cld    
  80099f:	eb 1a                	jmp    8009bb <memmove+0x5c>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009a1:	89 c2                	mov    %eax,%edx
  8009a3:	09 ca                	or     %ecx,%edx
  8009a5:	09 f2                	or     %esi,%edx
  8009a7:	f6 c2 03             	test   $0x3,%dl
  8009aa:	75 0a                	jne    8009b6 <memmove+0x57>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009ac:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  8009af:	89 c7                	mov    %eax,%edi
  8009b1:	fc                   	cld    
  8009b2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009b4:	eb 05                	jmp    8009bb <memmove+0x5c>
		else
			asm volatile("cld; rep movsb\n"
  8009b6:	89 c7                	mov    %eax,%edi
  8009b8:	fc                   	cld    
  8009b9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009bb:	5e                   	pop    %esi
  8009bc:	5f                   	pop    %edi
  8009bd:	5d                   	pop    %ebp
  8009be:	c3                   	ret    

008009bf <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009bf:	55                   	push   %ebp
  8009c0:	89 e5                	mov    %esp,%ebp
  8009c2:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8009c5:	ff 75 10             	pushl  0x10(%ebp)
  8009c8:	ff 75 0c             	pushl  0xc(%ebp)
  8009cb:	ff 75 08             	pushl  0x8(%ebp)
  8009ce:	e8 8c ff ff ff       	call   80095f <memmove>
}
  8009d3:	c9                   	leave  
  8009d4:	c3                   	ret    

008009d5 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009d5:	55                   	push   %ebp
  8009d6:	89 e5                	mov    %esp,%ebp
  8009d8:	56                   	push   %esi
  8009d9:	53                   	push   %ebx
  8009da:	8b 45 08             	mov    0x8(%ebp),%eax
  8009dd:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009e0:	89 c6                	mov    %eax,%esi
  8009e2:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009e5:	39 f0                	cmp    %esi,%eax
  8009e7:	74 16                	je     8009ff <memcmp+0x2a>
		if (*s1 != *s2)
  8009e9:	8a 08                	mov    (%eax),%cl
  8009eb:	8a 1a                	mov    (%edx),%bl
  8009ed:	38 d9                	cmp    %bl,%cl
  8009ef:	75 04                	jne    8009f5 <memcmp+0x20>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  8009f1:	40                   	inc    %eax
  8009f2:	42                   	inc    %edx
  8009f3:	eb f0                	jmp    8009e5 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  8009f5:	0f b6 c1             	movzbl %cl,%eax
  8009f8:	0f b6 db             	movzbl %bl,%ebx
  8009fb:	29 d8                	sub    %ebx,%eax
  8009fd:	eb 05                	jmp    800a04 <memcmp+0x2f>
	}

	return 0;
  8009ff:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a04:	5b                   	pop    %ebx
  800a05:	5e                   	pop    %esi
  800a06:	5d                   	pop    %ebp
  800a07:	c3                   	ret    

00800a08 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a08:	55                   	push   %ebp
  800a09:	89 e5                	mov    %esp,%ebp
  800a0b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a0e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a11:	89 c2                	mov    %eax,%edx
  800a13:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a16:	39 d0                	cmp    %edx,%eax
  800a18:	73 07                	jae    800a21 <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a1a:	38 08                	cmp    %cl,(%eax)
  800a1c:	74 03                	je     800a21 <memfind+0x19>
	for (; s < ends; s++)
  800a1e:	40                   	inc    %eax
  800a1f:	eb f5                	jmp    800a16 <memfind+0xe>
			break;
	return (void *) s;
}
  800a21:	5d                   	pop    %ebp
  800a22:	c3                   	ret    

00800a23 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a23:	55                   	push   %ebp
  800a24:	89 e5                	mov    %esp,%ebp
  800a26:	57                   	push   %edi
  800a27:	56                   	push   %esi
  800a28:	53                   	push   %ebx
  800a29:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a2c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a2f:	eb 01                	jmp    800a32 <strtol+0xf>
		s++;
  800a31:	41                   	inc    %ecx
	while (*s == ' ' || *s == '\t')
  800a32:	8a 01                	mov    (%ecx),%al
  800a34:	3c 20                	cmp    $0x20,%al
  800a36:	74 f9                	je     800a31 <strtol+0xe>
  800a38:	3c 09                	cmp    $0x9,%al
  800a3a:	74 f5                	je     800a31 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800a3c:	3c 2b                	cmp    $0x2b,%al
  800a3e:	74 24                	je     800a64 <strtol+0x41>
		s++;
	else if (*s == '-')
  800a40:	3c 2d                	cmp    $0x2d,%al
  800a42:	74 28                	je     800a6c <strtol+0x49>
	int neg = 0;
  800a44:	bf 00 00 00 00       	mov    $0x0,%edi
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a49:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a4f:	75 09                	jne    800a5a <strtol+0x37>
  800a51:	80 39 30             	cmpb   $0x30,(%ecx)
  800a54:	74 1e                	je     800a74 <strtol+0x51>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a56:	85 db                	test   %ebx,%ebx
  800a58:	74 36                	je     800a90 <strtol+0x6d>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a5a:	b8 00 00 00 00       	mov    $0x0,%eax
  800a5f:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800a62:	eb 45                	jmp    800aa9 <strtol+0x86>
		s++;
  800a64:	41                   	inc    %ecx
	int neg = 0;
  800a65:	bf 00 00 00 00       	mov    $0x0,%edi
  800a6a:	eb dd                	jmp    800a49 <strtol+0x26>
		s++, neg = 1;
  800a6c:	41                   	inc    %ecx
  800a6d:	bf 01 00 00 00       	mov    $0x1,%edi
  800a72:	eb d5                	jmp    800a49 <strtol+0x26>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a74:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a78:	74 0c                	je     800a86 <strtol+0x63>
	else if (base == 0 && s[0] == '0')
  800a7a:	85 db                	test   %ebx,%ebx
  800a7c:	75 dc                	jne    800a5a <strtol+0x37>
		s++, base = 8;
  800a7e:	41                   	inc    %ecx
  800a7f:	bb 08 00 00 00       	mov    $0x8,%ebx
  800a84:	eb d4                	jmp    800a5a <strtol+0x37>
		s += 2, base = 16;
  800a86:	83 c1 02             	add    $0x2,%ecx
  800a89:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a8e:	eb ca                	jmp    800a5a <strtol+0x37>
		base = 10;
  800a90:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800a95:	eb c3                	jmp    800a5a <strtol+0x37>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800a97:	0f be d2             	movsbl %dl,%edx
  800a9a:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800a9d:	3b 55 10             	cmp    0x10(%ebp),%edx
  800aa0:	7d 37                	jge    800ad9 <strtol+0xb6>
			break;
		s++, val = (val * base) + dig;
  800aa2:	41                   	inc    %ecx
  800aa3:	0f af 45 10          	imul   0x10(%ebp),%eax
  800aa7:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800aa9:	8a 11                	mov    (%ecx),%dl
  800aab:	8d 72 d0             	lea    -0x30(%edx),%esi
  800aae:	89 f3                	mov    %esi,%ebx
  800ab0:	80 fb 09             	cmp    $0x9,%bl
  800ab3:	76 e2                	jbe    800a97 <strtol+0x74>
		else if (*s >= 'a' && *s <= 'z')
  800ab5:	8d 72 9f             	lea    -0x61(%edx),%esi
  800ab8:	89 f3                	mov    %esi,%ebx
  800aba:	80 fb 19             	cmp    $0x19,%bl
  800abd:	77 08                	ja     800ac7 <strtol+0xa4>
			dig = *s - 'a' + 10;
  800abf:	0f be d2             	movsbl %dl,%edx
  800ac2:	83 ea 57             	sub    $0x57,%edx
  800ac5:	eb d6                	jmp    800a9d <strtol+0x7a>
		else if (*s >= 'A' && *s <= 'Z')
  800ac7:	8d 72 bf             	lea    -0x41(%edx),%esi
  800aca:	89 f3                	mov    %esi,%ebx
  800acc:	80 fb 19             	cmp    $0x19,%bl
  800acf:	77 08                	ja     800ad9 <strtol+0xb6>
			dig = *s - 'A' + 10;
  800ad1:	0f be d2             	movsbl %dl,%edx
  800ad4:	83 ea 37             	sub    $0x37,%edx
  800ad7:	eb c4                	jmp    800a9d <strtol+0x7a>
		// we don't properly detect overflow!
	}

	if (endptr)
  800ad9:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800add:	74 05                	je     800ae4 <strtol+0xc1>
		*endptr = (char *) s;
  800adf:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ae2:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800ae4:	85 ff                	test   %edi,%edi
  800ae6:	74 02                	je     800aea <strtol+0xc7>
  800ae8:	f7 d8                	neg    %eax
}
  800aea:	5b                   	pop    %ebx
  800aeb:	5e                   	pop    %esi
  800aec:	5f                   	pop    %edi
  800aed:	5d                   	pop    %ebp
  800aee:	c3                   	ret    
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
