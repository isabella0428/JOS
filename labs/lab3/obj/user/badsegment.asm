
obj/user/badsegment:     file format elf32-i386


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
  80002c:	e8 09 00 00 00       	call   80003a <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

void
umain(int argc, char **argv)
{
	// Try to load the kernel's TSS selector into the DS register.
	asm volatile("movw $0x28,%ax; movw %ax,%ds");
  800033:	66 b8 28 00          	mov    $0x28,%ax
  800037:	8e d8                	mov    %eax,%ds
}
  800039:	c3                   	ret    

0080003a <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80003a:	55                   	push   %ebp
  80003b:	89 e5                	mov    %esp,%ebp
  80003d:	57                   	push   %edi
  80003e:	56                   	push   %esi
  80003f:	53                   	push   %ebx
  800040:	83 ec 6c             	sub    $0x6c,%esp
  800043:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	struct Env curenv = envs[ENVX(sys_getenvid())];
  800046:	e8 de 00 00 00       	call   800129 <sys_getenvid>
  80004b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800050:	8d 34 00             	lea    (%eax,%eax,1),%esi
  800053:	01 c6                	add    %eax,%esi
  800055:	c1 e6 05             	shl    $0x5,%esi
  800058:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  80005e:	8d 7d 88             	lea    -0x78(%ebp),%edi
  800061:	b9 18 00 00 00       	mov    $0x18,%ecx
  800066:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	thisenv = &curenv;
  800068:	8d 45 88             	lea    -0x78(%ebp),%eax
  80006b:	a3 04 10 80 00       	mov    %eax,0x801004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800070:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800074:	7e 07                	jle    80007d <libmain+0x43>
		binaryname = argv[0];
  800076:	8b 03                	mov    (%ebx),%eax
  800078:	a3 00 10 80 00       	mov    %eax,0x801000
	
	// call user main routine
	umain(argc, argv);
  80007d:	83 ec 08             	sub    $0x8,%esp
  800080:	53                   	push   %ebx
  800081:	ff 75 08             	pushl  0x8(%ebp)
  800084:	e8 aa ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800089:	e8 0b 00 00 00       	call   800099 <exit>
}
  80008e:	83 c4 10             	add    $0x10,%esp
  800091:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800094:	5b                   	pop    %ebx
  800095:	5e                   	pop    %esi
  800096:	5f                   	pop    %edi
  800097:	5d                   	pop    %ebp
  800098:	c3                   	ret    

00800099 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800099:	55                   	push   %ebp
  80009a:	89 e5                	mov    %esp,%ebp
  80009c:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  80009f:	6a 00                	push   $0x0
  8000a1:	e8 42 00 00 00       	call   8000e8 <sys_env_destroy>
}
  8000a6:	83 c4 10             	add    $0x10,%esp
  8000a9:	c9                   	leave  
  8000aa:	c3                   	ret    

008000ab <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000ab:	55                   	push   %ebp
  8000ac:	89 e5                	mov    %esp,%ebp
  8000ae:	57                   	push   %edi
  8000af:	56                   	push   %esi
  8000b0:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000b1:	b8 00 00 00 00       	mov    $0x0,%eax
  8000b6:	8b 55 08             	mov    0x8(%ebp),%edx
  8000b9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000bc:	89 c3                	mov    %eax,%ebx
  8000be:	89 c7                	mov    %eax,%edi
  8000c0:	89 c6                	mov    %eax,%esi
  8000c2:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000c4:	5b                   	pop    %ebx
  8000c5:	5e                   	pop    %esi
  8000c6:	5f                   	pop    %edi
  8000c7:	5d                   	pop    %ebp
  8000c8:	c3                   	ret    

008000c9 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000c9:	55                   	push   %ebp
  8000ca:	89 e5                	mov    %esp,%ebp
  8000cc:	57                   	push   %edi
  8000cd:	56                   	push   %esi
  8000ce:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000cf:	ba 00 00 00 00       	mov    $0x0,%edx
  8000d4:	b8 01 00 00 00       	mov    $0x1,%eax
  8000d9:	89 d1                	mov    %edx,%ecx
  8000db:	89 d3                	mov    %edx,%ebx
  8000dd:	89 d7                	mov    %edx,%edi
  8000df:	89 d6                	mov    %edx,%esi
  8000e1:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000e3:	5b                   	pop    %ebx
  8000e4:	5e                   	pop    %esi
  8000e5:	5f                   	pop    %edi
  8000e6:	5d                   	pop    %ebp
  8000e7:	c3                   	ret    

008000e8 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000e8:	55                   	push   %ebp
  8000e9:	89 e5                	mov    %esp,%ebp
  8000eb:	57                   	push   %edi
  8000ec:	56                   	push   %esi
  8000ed:	53                   	push   %ebx
  8000ee:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8000f1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000f6:	8b 55 08             	mov    0x8(%ebp),%edx
  8000f9:	b8 03 00 00 00       	mov    $0x3,%eax
  8000fe:	89 cb                	mov    %ecx,%ebx
  800100:	89 cf                	mov    %ecx,%edi
  800102:	89 ce                	mov    %ecx,%esi
  800104:	cd 30                	int    $0x30
	if(check && ret > 0)
  800106:	85 c0                	test   %eax,%eax
  800108:	7f 08                	jg     800112 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80010a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80010d:	5b                   	pop    %ebx
  80010e:	5e                   	pop    %esi
  80010f:	5f                   	pop    %edi
  800110:	5d                   	pop    %ebp
  800111:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800112:	83 ec 0c             	sub    $0xc,%esp
  800115:	50                   	push   %eax
  800116:	6a 03                	push   $0x3
  800118:	68 0e 0d 80 00       	push   $0x800d0e
  80011d:	6a 23                	push   $0x23
  80011f:	68 2b 0d 80 00       	push   $0x800d2b
  800124:	e8 1f 00 00 00       	call   800148 <_panic>

00800129 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800129:	55                   	push   %ebp
  80012a:	89 e5                	mov    %esp,%ebp
  80012c:	57                   	push   %edi
  80012d:	56                   	push   %esi
  80012e:	53                   	push   %ebx
	asm volatile("int %1\n"
  80012f:	ba 00 00 00 00       	mov    $0x0,%edx
  800134:	b8 02 00 00 00       	mov    $0x2,%eax
  800139:	89 d1                	mov    %edx,%ecx
  80013b:	89 d3                	mov    %edx,%ebx
  80013d:	89 d7                	mov    %edx,%edi
  80013f:	89 d6                	mov    %edx,%esi
  800141:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800143:	5b                   	pop    %ebx
  800144:	5e                   	pop    %esi
  800145:	5f                   	pop    %edi
  800146:	5d                   	pop    %ebp
  800147:	c3                   	ret    

00800148 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800148:	55                   	push   %ebp
  800149:	89 e5                	mov    %esp,%ebp
  80014b:	56                   	push   %esi
  80014c:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80014d:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800150:	8b 35 00 10 80 00    	mov    0x801000,%esi
  800156:	e8 ce ff ff ff       	call   800129 <sys_getenvid>
  80015b:	83 ec 0c             	sub    $0xc,%esp
  80015e:	ff 75 0c             	pushl  0xc(%ebp)
  800161:	ff 75 08             	pushl  0x8(%ebp)
  800164:	56                   	push   %esi
  800165:	50                   	push   %eax
  800166:	68 3c 0d 80 00       	push   $0x800d3c
  80016b:	e8 b2 00 00 00       	call   800222 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800170:	83 c4 18             	add    $0x18,%esp
  800173:	53                   	push   %ebx
  800174:	ff 75 10             	pushl  0x10(%ebp)
  800177:	e8 55 00 00 00       	call   8001d1 <vcprintf>
	cprintf("\n");
  80017c:	c7 04 24 60 0d 80 00 	movl   $0x800d60,(%esp)
  800183:	e8 9a 00 00 00       	call   800222 <cprintf>
  800188:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80018b:	cc                   	int3   
  80018c:	eb fd                	jmp    80018b <_panic+0x43>

0080018e <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80018e:	55                   	push   %ebp
  80018f:	89 e5                	mov    %esp,%ebp
  800191:	53                   	push   %ebx
  800192:	83 ec 04             	sub    $0x4,%esp
  800195:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800198:	8b 13                	mov    (%ebx),%edx
  80019a:	8d 42 01             	lea    0x1(%edx),%eax
  80019d:	89 03                	mov    %eax,(%ebx)
  80019f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001a2:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001a6:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001ab:	74 08                	je     8001b5 <putch+0x27>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8001ad:	ff 43 04             	incl   0x4(%ebx)
}
  8001b0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001b3:	c9                   	leave  
  8001b4:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8001b5:	83 ec 08             	sub    $0x8,%esp
  8001b8:	68 ff 00 00 00       	push   $0xff
  8001bd:	8d 43 08             	lea    0x8(%ebx),%eax
  8001c0:	50                   	push   %eax
  8001c1:	e8 e5 fe ff ff       	call   8000ab <sys_cputs>
		b->idx = 0;
  8001c6:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001cc:	83 c4 10             	add    $0x10,%esp
  8001cf:	eb dc                	jmp    8001ad <putch+0x1f>

008001d1 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001d1:	55                   	push   %ebp
  8001d2:	89 e5                	mov    %esp,%ebp
  8001d4:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001da:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001e1:	00 00 00 
	b.cnt = 0;
  8001e4:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001eb:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001ee:	ff 75 0c             	pushl  0xc(%ebp)
  8001f1:	ff 75 08             	pushl  0x8(%ebp)
  8001f4:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001fa:	50                   	push   %eax
  8001fb:	68 8e 01 80 00       	push   $0x80018e
  800200:	e8 0f 01 00 00       	call   800314 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800205:	83 c4 08             	add    $0x8,%esp
  800208:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80020e:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800214:	50                   	push   %eax
  800215:	e8 91 fe ff ff       	call   8000ab <sys_cputs>

	return b.cnt;
}
  80021a:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800220:	c9                   	leave  
  800221:	c3                   	ret    

00800222 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800222:	55                   	push   %ebp
  800223:	89 e5                	mov    %esp,%ebp
  800225:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800228:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80022b:	50                   	push   %eax
  80022c:	ff 75 08             	pushl  0x8(%ebp)
  80022f:	e8 9d ff ff ff       	call   8001d1 <vcprintf>
	va_end(ap);

	return cnt;
}
  800234:	c9                   	leave  
  800235:	c3                   	ret    

00800236 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800236:	55                   	push   %ebp
  800237:	89 e5                	mov    %esp,%ebp
  800239:	57                   	push   %edi
  80023a:	56                   	push   %esi
  80023b:	53                   	push   %ebx
  80023c:	83 ec 1c             	sub    $0x1c,%esp
  80023f:	89 c7                	mov    %eax,%edi
  800241:	89 d6                	mov    %edx,%esi
  800243:	8b 45 08             	mov    0x8(%ebp),%eax
  800246:	8b 55 0c             	mov    0xc(%ebp),%edx
  800249:	89 d1                	mov    %edx,%ecx
  80024b:	89 c2                	mov    %eax,%edx
  80024d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800250:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800253:	8b 45 10             	mov    0x10(%ebp),%eax
  800256:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800259:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80025c:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800263:	39 c2                	cmp    %eax,%edx
  800265:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  800268:	72 3c                	jb     8002a6 <printnum+0x70>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80026a:	83 ec 0c             	sub    $0xc,%esp
  80026d:	ff 75 18             	pushl  0x18(%ebp)
  800270:	4b                   	dec    %ebx
  800271:	53                   	push   %ebx
  800272:	50                   	push   %eax
  800273:	83 ec 08             	sub    $0x8,%esp
  800276:	ff 75 e4             	pushl  -0x1c(%ebp)
  800279:	ff 75 e0             	pushl  -0x20(%ebp)
  80027c:	ff 75 dc             	pushl  -0x24(%ebp)
  80027f:	ff 75 d8             	pushl  -0x28(%ebp)
  800282:	e8 55 08 00 00       	call   800adc <__udivdi3>
  800287:	83 c4 18             	add    $0x18,%esp
  80028a:	52                   	push   %edx
  80028b:	50                   	push   %eax
  80028c:	89 f2                	mov    %esi,%edx
  80028e:	89 f8                	mov    %edi,%eax
  800290:	e8 a1 ff ff ff       	call   800236 <printnum>
  800295:	83 c4 20             	add    $0x20,%esp
  800298:	eb 11                	jmp    8002ab <printnum+0x75>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80029a:	83 ec 08             	sub    $0x8,%esp
  80029d:	56                   	push   %esi
  80029e:	ff 75 18             	pushl  0x18(%ebp)
  8002a1:	ff d7                	call   *%edi
  8002a3:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8002a6:	4b                   	dec    %ebx
  8002a7:	85 db                	test   %ebx,%ebx
  8002a9:	7f ef                	jg     80029a <printnum+0x64>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002ab:	83 ec 08             	sub    $0x8,%esp
  8002ae:	56                   	push   %esi
  8002af:	83 ec 04             	sub    $0x4,%esp
  8002b2:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002b5:	ff 75 e0             	pushl  -0x20(%ebp)
  8002b8:	ff 75 dc             	pushl  -0x24(%ebp)
  8002bb:	ff 75 d8             	pushl  -0x28(%ebp)
  8002be:	e8 19 09 00 00       	call   800bdc <__umoddi3>
  8002c3:	83 c4 14             	add    $0x14,%esp
  8002c6:	0f be 80 62 0d 80 00 	movsbl 0x800d62(%eax),%eax
  8002cd:	50                   	push   %eax
  8002ce:	ff d7                	call   *%edi
}
  8002d0:	83 c4 10             	add    $0x10,%esp
  8002d3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002d6:	5b                   	pop    %ebx
  8002d7:	5e                   	pop    %esi
  8002d8:	5f                   	pop    %edi
  8002d9:	5d                   	pop    %ebp
  8002da:	c3                   	ret    

008002db <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002db:	55                   	push   %ebp
  8002dc:	89 e5                	mov    %esp,%ebp
  8002de:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002e1:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8002e4:	8b 10                	mov    (%eax),%edx
  8002e6:	3b 50 04             	cmp    0x4(%eax),%edx
  8002e9:	73 0a                	jae    8002f5 <sprintputch+0x1a>
		*b->buf++ = ch;
  8002eb:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002ee:	89 08                	mov    %ecx,(%eax)
  8002f0:	8b 45 08             	mov    0x8(%ebp),%eax
  8002f3:	88 02                	mov    %al,(%edx)
}
  8002f5:	5d                   	pop    %ebp
  8002f6:	c3                   	ret    

008002f7 <printfmt>:
{
  8002f7:	55                   	push   %ebp
  8002f8:	89 e5                	mov    %esp,%ebp
  8002fa:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8002fd:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800300:	50                   	push   %eax
  800301:	ff 75 10             	pushl  0x10(%ebp)
  800304:	ff 75 0c             	pushl  0xc(%ebp)
  800307:	ff 75 08             	pushl  0x8(%ebp)
  80030a:	e8 05 00 00 00       	call   800314 <vprintfmt>
}
  80030f:	83 c4 10             	add    $0x10,%esp
  800312:	c9                   	leave  
  800313:	c3                   	ret    

00800314 <vprintfmt>:
{
  800314:	55                   	push   %ebp
  800315:	89 e5                	mov    %esp,%ebp
  800317:	57                   	push   %edi
  800318:	56                   	push   %esi
  800319:	53                   	push   %ebx
  80031a:	83 ec 3c             	sub    $0x3c,%esp
  80031d:	8b 75 08             	mov    0x8(%ebp),%esi
  800320:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800323:	8b 7d 10             	mov    0x10(%ebp),%edi
  800326:	e9 5b 03 00 00       	jmp    800686 <vprintfmt+0x372>
		padc = ' ';
  80032b:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  80032f:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
		precision = -1;
  800336:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  80033d:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		lflag = 0;
  800344:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800349:	8d 47 01             	lea    0x1(%edi),%eax
  80034c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80034f:	8a 17                	mov    (%edi),%dl
  800351:	8d 42 dd             	lea    -0x23(%edx),%eax
  800354:	3c 55                	cmp    $0x55,%al
  800356:	0f 87 ab 03 00 00    	ja     800707 <vprintfmt+0x3f3>
  80035c:	0f b6 c0             	movzbl %al,%eax
  80035f:	ff 24 85 f0 0d 80 00 	jmp    *0x800df0(,%eax,4)
  800366:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800369:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  80036d:	eb da                	jmp    800349 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  80036f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800372:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  800376:	eb d1                	jmp    800349 <vprintfmt+0x35>
  800378:	0f b6 d2             	movzbl %dl,%edx
  80037b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  80037e:	b8 00 00 00 00       	mov    $0x0,%eax
  800383:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800386:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800389:	01 c0                	add    %eax,%eax
  80038b:	8d 44 02 d0          	lea    -0x30(%edx,%eax,1),%eax
				ch = *fmt;
  80038f:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800392:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800395:	83 f9 09             	cmp    $0x9,%ecx
  800398:	77 52                	ja     8003ec <vprintfmt+0xd8>
			for (precision = 0; ; ++fmt) {
  80039a:	47                   	inc    %edi
				precision = precision * 10 + ch - '0';
  80039b:	eb e9                	jmp    800386 <vprintfmt+0x72>
			precision = va_arg(ap, int);
  80039d:	8b 45 14             	mov    0x14(%ebp),%eax
  8003a0:	8b 00                	mov    (%eax),%eax
  8003a2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003a5:	8b 45 14             	mov    0x14(%ebp),%eax
  8003a8:	8d 40 04             	lea    0x4(%eax),%eax
  8003ab:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003ae:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8003b1:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8003b5:	79 92                	jns    800349 <vprintfmt+0x35>
				width = precision, precision = -1;
  8003b7:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8003ba:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8003bd:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8003c4:	eb 83                	jmp    800349 <vprintfmt+0x35>
  8003c6:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8003ca:	78 08                	js     8003d4 <vprintfmt+0xc0>
		switch (ch = *(unsigned char *) fmt++) {
  8003cc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8003cf:	e9 75 ff ff ff       	jmp    800349 <vprintfmt+0x35>
  8003d4:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  8003db:	eb ef                	jmp    8003cc <vprintfmt+0xb8>
		switch (ch = *(unsigned char *) fmt++) {
  8003dd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8003e0:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  8003e7:	e9 5d ff ff ff       	jmp    800349 <vprintfmt+0x35>
  8003ec:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8003ef:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003f2:	eb bd                	jmp    8003b1 <vprintfmt+0x9d>
			lflag++;
  8003f4:	41                   	inc    %ecx
		switch (ch = *(unsigned char *) fmt++) {
  8003f5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8003f8:	e9 4c ff ff ff       	jmp    800349 <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
  8003fd:	8b 45 14             	mov    0x14(%ebp),%eax
  800400:	8d 78 04             	lea    0x4(%eax),%edi
  800403:	83 ec 08             	sub    $0x8,%esp
  800406:	53                   	push   %ebx
  800407:	ff 30                	pushl  (%eax)
  800409:	ff d6                	call   *%esi
			break;
  80040b:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  80040e:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800411:	e9 6d 02 00 00       	jmp    800683 <vprintfmt+0x36f>
			err = va_arg(ap, int);
  800416:	8b 45 14             	mov    0x14(%ebp),%eax
  800419:	8d 78 04             	lea    0x4(%eax),%edi
  80041c:	8b 00                	mov    (%eax),%eax
  80041e:	85 c0                	test   %eax,%eax
  800420:	78 2a                	js     80044c <vprintfmt+0x138>
  800422:	89 c2                	mov    %eax,%edx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800424:	83 f8 06             	cmp    $0x6,%eax
  800427:	7f 27                	jg     800450 <vprintfmt+0x13c>
  800429:	8b 04 85 48 0f 80 00 	mov    0x800f48(,%eax,4),%eax
  800430:	85 c0                	test   %eax,%eax
  800432:	74 1c                	je     800450 <vprintfmt+0x13c>
				printfmt(putch, putdat, "%s", p);
  800434:	50                   	push   %eax
  800435:	68 83 0d 80 00       	push   $0x800d83
  80043a:	53                   	push   %ebx
  80043b:	56                   	push   %esi
  80043c:	e8 b6 fe ff ff       	call   8002f7 <printfmt>
  800441:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800444:	89 7d 14             	mov    %edi,0x14(%ebp)
  800447:	e9 37 02 00 00       	jmp    800683 <vprintfmt+0x36f>
  80044c:	f7 d8                	neg    %eax
  80044e:	eb d2                	jmp    800422 <vprintfmt+0x10e>
				printfmt(putch, putdat, "error %d", err);
  800450:	52                   	push   %edx
  800451:	68 7a 0d 80 00       	push   $0x800d7a
  800456:	53                   	push   %ebx
  800457:	56                   	push   %esi
  800458:	e8 9a fe ff ff       	call   8002f7 <printfmt>
  80045d:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800460:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800463:	e9 1b 02 00 00       	jmp    800683 <vprintfmt+0x36f>
			if ((p = va_arg(ap, char *)) == NULL)
  800468:	8b 45 14             	mov    0x14(%ebp),%eax
  80046b:	83 c0 04             	add    $0x4,%eax
  80046e:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800471:	8b 45 14             	mov    0x14(%ebp),%eax
  800474:	8b 00                	mov    (%eax),%eax
  800476:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800479:	85 c0                	test   %eax,%eax
  80047b:	74 19                	je     800496 <vprintfmt+0x182>
			if (width > 0 && padc != '-')
  80047d:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800481:	7e 06                	jle    800489 <vprintfmt+0x175>
  800483:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  800487:	75 16                	jne    80049f <vprintfmt+0x18b>
				for (width -= strnlen(p, precision); width > 0; width--)
  800489:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80048c:	89 c7                	mov    %eax,%edi
  80048e:	03 45 d4             	add    -0x2c(%ebp),%eax
  800491:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800494:	eb 62                	jmp    8004f8 <vprintfmt+0x1e4>
				p = "(null)";
  800496:	c7 45 cc 73 0d 80 00 	movl   $0x800d73,-0x34(%ebp)
  80049d:	eb de                	jmp    80047d <vprintfmt+0x169>
				for (width -= strnlen(p, precision); width > 0; width--)
  80049f:	83 ec 08             	sub    $0x8,%esp
  8004a2:	ff 75 d8             	pushl  -0x28(%ebp)
  8004a5:	ff 75 cc             	pushl  -0x34(%ebp)
  8004a8:	e8 05 03 00 00       	call   8007b2 <strnlen>
  8004ad:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8004b0:	29 c2                	sub    %eax,%edx
  8004b2:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  8004b5:	83 c4 10             	add    $0x10,%esp
  8004b8:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  8004ba:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8004be:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8004c1:	eb 0d                	jmp    8004d0 <vprintfmt+0x1bc>
					putch(padc, putdat);
  8004c3:	83 ec 08             	sub    $0x8,%esp
  8004c6:	53                   	push   %ebx
  8004c7:	ff 75 d4             	pushl  -0x2c(%ebp)
  8004ca:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8004cc:	4f                   	dec    %edi
  8004cd:	83 c4 10             	add    $0x10,%esp
  8004d0:	85 ff                	test   %edi,%edi
  8004d2:	7f ef                	jg     8004c3 <vprintfmt+0x1af>
  8004d4:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8004d7:	89 d0                	mov    %edx,%eax
  8004d9:	85 d2                	test   %edx,%edx
  8004db:	78 0a                	js     8004e7 <vprintfmt+0x1d3>
  8004dd:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8004e0:	29 c2                	sub    %eax,%edx
  8004e2:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8004e5:	eb a2                	jmp    800489 <vprintfmt+0x175>
  8004e7:	b8 00 00 00 00       	mov    $0x0,%eax
  8004ec:	eb ef                	jmp    8004dd <vprintfmt+0x1c9>
					putch(ch, putdat);
  8004ee:	83 ec 08             	sub    $0x8,%esp
  8004f1:	53                   	push   %ebx
  8004f2:	52                   	push   %edx
  8004f3:	ff d6                	call   *%esi
  8004f5:	83 c4 10             	add    $0x10,%esp
  8004f8:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  8004fb:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004fd:	47                   	inc    %edi
  8004fe:	8a 47 ff             	mov    -0x1(%edi),%al
  800501:	0f be d0             	movsbl %al,%edx
  800504:	85 d2                	test   %edx,%edx
  800506:	74 48                	je     800550 <vprintfmt+0x23c>
  800508:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80050c:	78 05                	js     800513 <vprintfmt+0x1ff>
  80050e:	ff 4d d8             	decl   -0x28(%ebp)
  800511:	78 1e                	js     800531 <vprintfmt+0x21d>
				if (altflag && (ch < ' ' || ch > '~'))
  800513:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800517:	74 d5                	je     8004ee <vprintfmt+0x1da>
  800519:	0f be c0             	movsbl %al,%eax
  80051c:	83 e8 20             	sub    $0x20,%eax
  80051f:	83 f8 5e             	cmp    $0x5e,%eax
  800522:	76 ca                	jbe    8004ee <vprintfmt+0x1da>
					putch('?', putdat);
  800524:	83 ec 08             	sub    $0x8,%esp
  800527:	53                   	push   %ebx
  800528:	6a 3f                	push   $0x3f
  80052a:	ff d6                	call   *%esi
  80052c:	83 c4 10             	add    $0x10,%esp
  80052f:	eb c7                	jmp    8004f8 <vprintfmt+0x1e4>
  800531:	89 cf                	mov    %ecx,%edi
  800533:	eb 0c                	jmp    800541 <vprintfmt+0x22d>
				putch(' ', putdat);
  800535:	83 ec 08             	sub    $0x8,%esp
  800538:	53                   	push   %ebx
  800539:	6a 20                	push   $0x20
  80053b:	ff d6                	call   *%esi
			for (; width > 0; width--)
  80053d:	4f                   	dec    %edi
  80053e:	83 c4 10             	add    $0x10,%esp
  800541:	85 ff                	test   %edi,%edi
  800543:	7f f0                	jg     800535 <vprintfmt+0x221>
			if ((p = va_arg(ap, char *)) == NULL)
  800545:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800548:	89 45 14             	mov    %eax,0x14(%ebp)
  80054b:	e9 33 01 00 00       	jmp    800683 <vprintfmt+0x36f>
  800550:	89 cf                	mov    %ecx,%edi
  800552:	eb ed                	jmp    800541 <vprintfmt+0x22d>
	if (lflag >= 2)
  800554:	83 f9 01             	cmp    $0x1,%ecx
  800557:	7f 1b                	jg     800574 <vprintfmt+0x260>
	else if (lflag)
  800559:	85 c9                	test   %ecx,%ecx
  80055b:	74 42                	je     80059f <vprintfmt+0x28b>
		return va_arg(*ap, long);
  80055d:	8b 45 14             	mov    0x14(%ebp),%eax
  800560:	8b 00                	mov    (%eax),%eax
  800562:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800565:	99                   	cltd   
  800566:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800569:	8b 45 14             	mov    0x14(%ebp),%eax
  80056c:	8d 40 04             	lea    0x4(%eax),%eax
  80056f:	89 45 14             	mov    %eax,0x14(%ebp)
  800572:	eb 17                	jmp    80058b <vprintfmt+0x277>
		return va_arg(*ap, long long);
  800574:	8b 45 14             	mov    0x14(%ebp),%eax
  800577:	8b 50 04             	mov    0x4(%eax),%edx
  80057a:	8b 00                	mov    (%eax),%eax
  80057c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80057f:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800582:	8b 45 14             	mov    0x14(%ebp),%eax
  800585:	8d 40 08             	lea    0x8(%eax),%eax
  800588:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  80058b:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80058e:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800591:	85 c9                	test   %ecx,%ecx
  800593:	78 21                	js     8005b6 <vprintfmt+0x2a2>
			base = 10;
  800595:	b8 0a 00 00 00       	mov    $0xa,%eax
  80059a:	e9 ca 00 00 00       	jmp    800669 <vprintfmt+0x355>
		return va_arg(*ap, int);
  80059f:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a2:	8b 00                	mov    (%eax),%eax
  8005a4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005a7:	99                   	cltd   
  8005a8:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005ab:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ae:	8d 40 04             	lea    0x4(%eax),%eax
  8005b1:	89 45 14             	mov    %eax,0x14(%ebp)
  8005b4:	eb d5                	jmp    80058b <vprintfmt+0x277>
				putch('-', putdat);
  8005b6:	83 ec 08             	sub    $0x8,%esp
  8005b9:	53                   	push   %ebx
  8005ba:	6a 2d                	push   $0x2d
  8005bc:	ff d6                	call   *%esi
				num = -(long long) num;
  8005be:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005c1:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8005c4:	f7 da                	neg    %edx
  8005c6:	83 d1 00             	adc    $0x0,%ecx
  8005c9:	f7 d9                	neg    %ecx
  8005cb:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8005ce:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005d3:	e9 91 00 00 00       	jmp    800669 <vprintfmt+0x355>
	if (lflag >= 2)
  8005d8:	83 f9 01             	cmp    $0x1,%ecx
  8005db:	7f 1b                	jg     8005f8 <vprintfmt+0x2e4>
	else if (lflag)
  8005dd:	85 c9                	test   %ecx,%ecx
  8005df:	74 2c                	je     80060d <vprintfmt+0x2f9>
		return va_arg(*ap, unsigned long);
  8005e1:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e4:	8b 10                	mov    (%eax),%edx
  8005e6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005eb:	8d 40 04             	lea    0x4(%eax),%eax
  8005ee:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005f1:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  8005f6:	eb 71                	jmp    800669 <vprintfmt+0x355>
		return va_arg(*ap, unsigned long long);
  8005f8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005fb:	8b 10                	mov    (%eax),%edx
  8005fd:	8b 48 04             	mov    0x4(%eax),%ecx
  800600:	8d 40 08             	lea    0x8(%eax),%eax
  800603:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800606:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  80060b:	eb 5c                	jmp    800669 <vprintfmt+0x355>
		return va_arg(*ap, unsigned int);
  80060d:	8b 45 14             	mov    0x14(%ebp),%eax
  800610:	8b 10                	mov    (%eax),%edx
  800612:	b9 00 00 00 00       	mov    $0x0,%ecx
  800617:	8d 40 04             	lea    0x4(%eax),%eax
  80061a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80061d:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  800622:	eb 45                	jmp    800669 <vprintfmt+0x355>
			putch('X', putdat);
  800624:	83 ec 08             	sub    $0x8,%esp
  800627:	53                   	push   %ebx
  800628:	6a 58                	push   $0x58
  80062a:	ff d6                	call   *%esi
			putch('X', putdat);
  80062c:	83 c4 08             	add    $0x8,%esp
  80062f:	53                   	push   %ebx
  800630:	6a 58                	push   $0x58
  800632:	ff d6                	call   *%esi
			putch('X', putdat);
  800634:	83 c4 08             	add    $0x8,%esp
  800637:	53                   	push   %ebx
  800638:	6a 58                	push   $0x58
  80063a:	ff d6                	call   *%esi
			break;
  80063c:	83 c4 10             	add    $0x10,%esp
  80063f:	eb 42                	jmp    800683 <vprintfmt+0x36f>
			putch('0', putdat);
  800641:	83 ec 08             	sub    $0x8,%esp
  800644:	53                   	push   %ebx
  800645:	6a 30                	push   $0x30
  800647:	ff d6                	call   *%esi
			putch('x', putdat);
  800649:	83 c4 08             	add    $0x8,%esp
  80064c:	53                   	push   %ebx
  80064d:	6a 78                	push   $0x78
  80064f:	ff d6                	call   *%esi
			num = (unsigned long long)
  800651:	8b 45 14             	mov    0x14(%ebp),%eax
  800654:	8b 10                	mov    (%eax),%edx
  800656:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  80065b:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  80065e:	8d 40 04             	lea    0x4(%eax),%eax
  800661:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800664:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  800669:	83 ec 0c             	sub    $0xc,%esp
  80066c:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  800670:	57                   	push   %edi
  800671:	ff 75 d4             	pushl  -0x2c(%ebp)
  800674:	50                   	push   %eax
  800675:	51                   	push   %ecx
  800676:	52                   	push   %edx
  800677:	89 da                	mov    %ebx,%edx
  800679:	89 f0                	mov    %esi,%eax
  80067b:	e8 b6 fb ff ff       	call   800236 <printnum>
			break;
  800680:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  800683:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800686:	47                   	inc    %edi
  800687:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80068b:	83 f8 25             	cmp    $0x25,%eax
  80068e:	0f 84 97 fc ff ff    	je     80032b <vprintfmt+0x17>
			if (ch == '\0')
  800694:	85 c0                	test   %eax,%eax
  800696:	0f 84 89 00 00 00    	je     800725 <vprintfmt+0x411>
			putch(ch, putdat);
  80069c:	83 ec 08             	sub    $0x8,%esp
  80069f:	53                   	push   %ebx
  8006a0:	50                   	push   %eax
  8006a1:	ff d6                	call   *%esi
  8006a3:	83 c4 10             	add    $0x10,%esp
  8006a6:	eb de                	jmp    800686 <vprintfmt+0x372>
	if (lflag >= 2)
  8006a8:	83 f9 01             	cmp    $0x1,%ecx
  8006ab:	7f 1b                	jg     8006c8 <vprintfmt+0x3b4>
	else if (lflag)
  8006ad:	85 c9                	test   %ecx,%ecx
  8006af:	74 2c                	je     8006dd <vprintfmt+0x3c9>
		return va_arg(*ap, unsigned long);
  8006b1:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b4:	8b 10                	mov    (%eax),%edx
  8006b6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006bb:	8d 40 04             	lea    0x4(%eax),%eax
  8006be:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006c1:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  8006c6:	eb a1                	jmp    800669 <vprintfmt+0x355>
		return va_arg(*ap, unsigned long long);
  8006c8:	8b 45 14             	mov    0x14(%ebp),%eax
  8006cb:	8b 10                	mov    (%eax),%edx
  8006cd:	8b 48 04             	mov    0x4(%eax),%ecx
  8006d0:	8d 40 08             	lea    0x8(%eax),%eax
  8006d3:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006d6:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  8006db:	eb 8c                	jmp    800669 <vprintfmt+0x355>
		return va_arg(*ap, unsigned int);
  8006dd:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e0:	8b 10                	mov    (%eax),%edx
  8006e2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006e7:	8d 40 04             	lea    0x4(%eax),%eax
  8006ea:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006ed:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  8006f2:	e9 72 ff ff ff       	jmp    800669 <vprintfmt+0x355>
			putch(ch, putdat);
  8006f7:	83 ec 08             	sub    $0x8,%esp
  8006fa:	53                   	push   %ebx
  8006fb:	6a 25                	push   $0x25
  8006fd:	ff d6                	call   *%esi
			break;
  8006ff:	83 c4 10             	add    $0x10,%esp
  800702:	e9 7c ff ff ff       	jmp    800683 <vprintfmt+0x36f>
			putch('%', putdat);
  800707:	83 ec 08             	sub    $0x8,%esp
  80070a:	53                   	push   %ebx
  80070b:	6a 25                	push   $0x25
  80070d:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80070f:	83 c4 10             	add    $0x10,%esp
  800712:	89 f8                	mov    %edi,%eax
  800714:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800718:	74 03                	je     80071d <vprintfmt+0x409>
  80071a:	48                   	dec    %eax
  80071b:	eb f7                	jmp    800714 <vprintfmt+0x400>
  80071d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800720:	e9 5e ff ff ff       	jmp    800683 <vprintfmt+0x36f>
}
  800725:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800728:	5b                   	pop    %ebx
  800729:	5e                   	pop    %esi
  80072a:	5f                   	pop    %edi
  80072b:	5d                   	pop    %ebp
  80072c:	c3                   	ret    

0080072d <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80072d:	55                   	push   %ebp
  80072e:	89 e5                	mov    %esp,%ebp
  800730:	83 ec 18             	sub    $0x18,%esp
  800733:	8b 45 08             	mov    0x8(%ebp),%eax
  800736:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800739:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80073c:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800740:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800743:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80074a:	85 c0                	test   %eax,%eax
  80074c:	74 26                	je     800774 <vsnprintf+0x47>
  80074e:	85 d2                	test   %edx,%edx
  800750:	7e 29                	jle    80077b <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800752:	ff 75 14             	pushl  0x14(%ebp)
  800755:	ff 75 10             	pushl  0x10(%ebp)
  800758:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80075b:	50                   	push   %eax
  80075c:	68 db 02 80 00       	push   $0x8002db
  800761:	e8 ae fb ff ff       	call   800314 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800766:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800769:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80076c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80076f:	83 c4 10             	add    $0x10,%esp
}
  800772:	c9                   	leave  
  800773:	c3                   	ret    
		return -E_INVAL;
  800774:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800779:	eb f7                	jmp    800772 <vsnprintf+0x45>
  80077b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800780:	eb f0                	jmp    800772 <vsnprintf+0x45>

00800782 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800782:	55                   	push   %ebp
  800783:	89 e5                	mov    %esp,%ebp
  800785:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800788:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80078b:	50                   	push   %eax
  80078c:	ff 75 10             	pushl  0x10(%ebp)
  80078f:	ff 75 0c             	pushl  0xc(%ebp)
  800792:	ff 75 08             	pushl  0x8(%ebp)
  800795:	e8 93 ff ff ff       	call   80072d <vsnprintf>
	va_end(ap);

	return rc;
}
  80079a:	c9                   	leave  
  80079b:	c3                   	ret    

0080079c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80079c:	55                   	push   %ebp
  80079d:	89 e5                	mov    %esp,%ebp
  80079f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007a2:	b8 00 00 00 00       	mov    $0x0,%eax
  8007a7:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007ab:	74 03                	je     8007b0 <strlen+0x14>
		n++;
  8007ad:	40                   	inc    %eax
  8007ae:	eb f7                	jmp    8007a7 <strlen+0xb>
	return n;
}
  8007b0:	5d                   	pop    %ebp
  8007b1:	c3                   	ret    

008007b2 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007b2:	55                   	push   %ebp
  8007b3:	89 e5                	mov    %esp,%ebp
  8007b5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007b8:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007bb:	b8 00 00 00 00       	mov    $0x0,%eax
  8007c0:	39 d0                	cmp    %edx,%eax
  8007c2:	74 0b                	je     8007cf <strnlen+0x1d>
  8007c4:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007c8:	74 03                	je     8007cd <strnlen+0x1b>
		n++;
  8007ca:	40                   	inc    %eax
  8007cb:	eb f3                	jmp    8007c0 <strnlen+0xe>
  8007cd:	89 c2                	mov    %eax,%edx
	return n;
}
  8007cf:	89 d0                	mov    %edx,%eax
  8007d1:	5d                   	pop    %ebp
  8007d2:	c3                   	ret    

008007d3 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007d3:	55                   	push   %ebp
  8007d4:	89 e5                	mov    %esp,%ebp
  8007d6:	53                   	push   %ebx
  8007d7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007da:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007dd:	b8 00 00 00 00       	mov    $0x0,%eax
  8007e2:	8a 14 03             	mov    (%ebx,%eax,1),%dl
  8007e5:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8007e8:	40                   	inc    %eax
  8007e9:	84 d2                	test   %dl,%dl
  8007eb:	75 f5                	jne    8007e2 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8007ed:	89 c8                	mov    %ecx,%eax
  8007ef:	5b                   	pop    %ebx
  8007f0:	5d                   	pop    %ebp
  8007f1:	c3                   	ret    

008007f2 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007f2:	55                   	push   %ebp
  8007f3:	89 e5                	mov    %esp,%ebp
  8007f5:	53                   	push   %ebx
  8007f6:	83 ec 10             	sub    $0x10,%esp
  8007f9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007fc:	53                   	push   %ebx
  8007fd:	e8 9a ff ff ff       	call   80079c <strlen>
  800802:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800805:	ff 75 0c             	pushl  0xc(%ebp)
  800808:	01 d8                	add    %ebx,%eax
  80080a:	50                   	push   %eax
  80080b:	e8 c3 ff ff ff       	call   8007d3 <strcpy>
	return dst;
}
  800810:	89 d8                	mov    %ebx,%eax
  800812:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800815:	c9                   	leave  
  800816:	c3                   	ret    

00800817 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800817:	55                   	push   %ebp
  800818:	89 e5                	mov    %esp,%ebp
  80081a:	53                   	push   %ebx
  80081b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80081e:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800821:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800824:	8b 45 08             	mov    0x8(%ebp),%eax
  800827:	39 d8                	cmp    %ebx,%eax
  800829:	74 0e                	je     800839 <strncpy+0x22>
		*dst++ = *src;
  80082b:	40                   	inc    %eax
  80082c:	8a 0a                	mov    (%edx),%cl
  80082e:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800831:	80 f9 01             	cmp    $0x1,%cl
  800834:	83 da ff             	sbb    $0xffffffff,%edx
  800837:	eb ee                	jmp    800827 <strncpy+0x10>
	}
	return ret;
}
  800839:	8b 45 08             	mov    0x8(%ebp),%eax
  80083c:	5b                   	pop    %ebx
  80083d:	5d                   	pop    %ebp
  80083e:	c3                   	ret    

0080083f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80083f:	55                   	push   %ebp
  800840:	89 e5                	mov    %esp,%ebp
  800842:	56                   	push   %esi
  800843:	53                   	push   %ebx
  800844:	8b 75 08             	mov    0x8(%ebp),%esi
  800847:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80084a:	8b 45 10             	mov    0x10(%ebp),%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80084d:	85 c0                	test   %eax,%eax
  80084f:	74 22                	je     800873 <strlcpy+0x34>
  800851:	8d 44 06 ff          	lea    -0x1(%esi,%eax,1),%eax
  800855:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  800857:	39 c2                	cmp    %eax,%edx
  800859:	74 0f                	je     80086a <strlcpy+0x2b>
  80085b:	8a 19                	mov    (%ecx),%bl
  80085d:	84 db                	test   %bl,%bl
  80085f:	74 07                	je     800868 <strlcpy+0x29>
			*dst++ = *src++;
  800861:	41                   	inc    %ecx
  800862:	42                   	inc    %edx
  800863:	88 5a ff             	mov    %bl,-0x1(%edx)
  800866:	eb ef                	jmp    800857 <strlcpy+0x18>
  800868:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  80086a:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80086d:	29 f0                	sub    %esi,%eax
}
  80086f:	5b                   	pop    %ebx
  800870:	5e                   	pop    %esi
  800871:	5d                   	pop    %ebp
  800872:	c3                   	ret    
  800873:	89 f0                	mov    %esi,%eax
  800875:	eb f6                	jmp    80086d <strlcpy+0x2e>

00800877 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800877:	55                   	push   %ebp
  800878:	89 e5                	mov    %esp,%ebp
  80087a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80087d:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800880:	8a 01                	mov    (%ecx),%al
  800882:	84 c0                	test   %al,%al
  800884:	74 08                	je     80088e <strcmp+0x17>
  800886:	3a 02                	cmp    (%edx),%al
  800888:	75 04                	jne    80088e <strcmp+0x17>
		p++, q++;
  80088a:	41                   	inc    %ecx
  80088b:	42                   	inc    %edx
  80088c:	eb f2                	jmp    800880 <strcmp+0x9>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80088e:	0f b6 c0             	movzbl %al,%eax
  800891:	0f b6 12             	movzbl (%edx),%edx
  800894:	29 d0                	sub    %edx,%eax
}
  800896:	5d                   	pop    %ebp
  800897:	c3                   	ret    

00800898 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800898:	55                   	push   %ebp
  800899:	89 e5                	mov    %esp,%ebp
  80089b:	53                   	push   %ebx
  80089c:	8b 45 08             	mov    0x8(%ebp),%eax
  80089f:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008a2:	89 c3                	mov    %eax,%ebx
  8008a4:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008a7:	eb 02                	jmp    8008ab <strncmp+0x13>
		n--, p++, q++;
  8008a9:	40                   	inc    %eax
  8008aa:	42                   	inc    %edx
	while (n > 0 && *p && *p == *q)
  8008ab:	39 d8                	cmp    %ebx,%eax
  8008ad:	74 15                	je     8008c4 <strncmp+0x2c>
  8008af:	8a 08                	mov    (%eax),%cl
  8008b1:	84 c9                	test   %cl,%cl
  8008b3:	74 04                	je     8008b9 <strncmp+0x21>
  8008b5:	3a 0a                	cmp    (%edx),%cl
  8008b7:	74 f0                	je     8008a9 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008b9:	0f b6 00             	movzbl (%eax),%eax
  8008bc:	0f b6 12             	movzbl (%edx),%edx
  8008bf:	29 d0                	sub    %edx,%eax
}
  8008c1:	5b                   	pop    %ebx
  8008c2:	5d                   	pop    %ebp
  8008c3:	c3                   	ret    
		return 0;
  8008c4:	b8 00 00 00 00       	mov    $0x0,%eax
  8008c9:	eb f6                	jmp    8008c1 <strncmp+0x29>

008008cb <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008cb:	55                   	push   %ebp
  8008cc:	89 e5                	mov    %esp,%ebp
  8008ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d1:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8008d4:	8a 10                	mov    (%eax),%dl
  8008d6:	84 d2                	test   %dl,%dl
  8008d8:	74 07                	je     8008e1 <strchr+0x16>
		if (*s == c)
  8008da:	38 ca                	cmp    %cl,%dl
  8008dc:	74 08                	je     8008e6 <strchr+0x1b>
	for (; *s; s++)
  8008de:	40                   	inc    %eax
  8008df:	eb f3                	jmp    8008d4 <strchr+0x9>
			return (char *) s;
	return 0;
  8008e1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008e6:	5d                   	pop    %ebp
  8008e7:	c3                   	ret    

008008e8 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008e8:	55                   	push   %ebp
  8008e9:	89 e5                	mov    %esp,%ebp
  8008eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ee:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8008f1:	8a 10                	mov    (%eax),%dl
  8008f3:	84 d2                	test   %dl,%dl
  8008f5:	74 07                	je     8008fe <strfind+0x16>
		if (*s == c)
  8008f7:	38 ca                	cmp    %cl,%dl
  8008f9:	74 03                	je     8008fe <strfind+0x16>
	for (; *s; s++)
  8008fb:	40                   	inc    %eax
  8008fc:	eb f3                	jmp    8008f1 <strfind+0x9>
			break;
	return (char *) s;
}
  8008fe:	5d                   	pop    %ebp
  8008ff:	c3                   	ret    

00800900 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800900:	55                   	push   %ebp
  800901:	89 e5                	mov    %esp,%ebp
  800903:	57                   	push   %edi
  800904:	56                   	push   %esi
  800905:	53                   	push   %ebx
  800906:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800909:	85 c9                	test   %ecx,%ecx
  80090b:	74 36                	je     800943 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80090d:	89 c8                	mov    %ecx,%eax
  80090f:	0b 45 08             	or     0x8(%ebp),%eax
  800912:	a8 03                	test   $0x3,%al
  800914:	75 24                	jne    80093a <memset+0x3a>
		c &= 0xFF;
  800916:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80091a:	89 d3                	mov    %edx,%ebx
  80091c:	c1 e3 08             	shl    $0x8,%ebx
  80091f:	89 d0                	mov    %edx,%eax
  800921:	c1 e0 18             	shl    $0x18,%eax
  800924:	89 d6                	mov    %edx,%esi
  800926:	c1 e6 10             	shl    $0x10,%esi
  800929:	09 f0                	or     %esi,%eax
  80092b:	09 d0                	or     %edx,%eax
  80092d:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80092f:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800932:	8b 7d 08             	mov    0x8(%ebp),%edi
  800935:	fc                   	cld    
  800936:	f3 ab                	rep stos %eax,%es:(%edi)
  800938:	eb 09                	jmp    800943 <memset+0x43>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80093a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80093d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800940:	fc                   	cld    
  800941:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800943:	8b 45 08             	mov    0x8(%ebp),%eax
  800946:	5b                   	pop    %ebx
  800947:	5e                   	pop    %esi
  800948:	5f                   	pop    %edi
  800949:	5d                   	pop    %ebp
  80094a:	c3                   	ret    

0080094b <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80094b:	55                   	push   %ebp
  80094c:	89 e5                	mov    %esp,%ebp
  80094e:	57                   	push   %edi
  80094f:	56                   	push   %esi
  800950:	8b 45 08             	mov    0x8(%ebp),%eax
  800953:	8b 75 0c             	mov    0xc(%ebp),%esi
  800956:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800959:	39 c6                	cmp    %eax,%esi
  80095b:	73 30                	jae    80098d <memmove+0x42>
  80095d:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800960:	39 c2                	cmp    %eax,%edx
  800962:	76 29                	jbe    80098d <memmove+0x42>
		s += n;
		d += n;
  800964:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800967:	89 fe                	mov    %edi,%esi
  800969:	09 ce                	or     %ecx,%esi
  80096b:	09 d6                	or     %edx,%esi
  80096d:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800973:	75 0e                	jne    800983 <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800975:	83 ef 04             	sub    $0x4,%edi
  800978:	8d 72 fc             	lea    -0x4(%edx),%esi
  80097b:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  80097e:	fd                   	std    
  80097f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800981:	eb 07                	jmp    80098a <memmove+0x3f>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800983:	4f                   	dec    %edi
  800984:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800987:	fd                   	std    
  800988:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80098a:	fc                   	cld    
  80098b:	eb 1a                	jmp    8009a7 <memmove+0x5c>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80098d:	89 c2                	mov    %eax,%edx
  80098f:	09 ca                	or     %ecx,%edx
  800991:	09 f2                	or     %esi,%edx
  800993:	f6 c2 03             	test   $0x3,%dl
  800996:	75 0a                	jne    8009a2 <memmove+0x57>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800998:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  80099b:	89 c7                	mov    %eax,%edi
  80099d:	fc                   	cld    
  80099e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009a0:	eb 05                	jmp    8009a7 <memmove+0x5c>
		else
			asm volatile("cld; rep movsb\n"
  8009a2:	89 c7                	mov    %eax,%edi
  8009a4:	fc                   	cld    
  8009a5:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009a7:	5e                   	pop    %esi
  8009a8:	5f                   	pop    %edi
  8009a9:	5d                   	pop    %ebp
  8009aa:	c3                   	ret    

008009ab <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009ab:	55                   	push   %ebp
  8009ac:	89 e5                	mov    %esp,%ebp
  8009ae:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8009b1:	ff 75 10             	pushl  0x10(%ebp)
  8009b4:	ff 75 0c             	pushl  0xc(%ebp)
  8009b7:	ff 75 08             	pushl  0x8(%ebp)
  8009ba:	e8 8c ff ff ff       	call   80094b <memmove>
}
  8009bf:	c9                   	leave  
  8009c0:	c3                   	ret    

008009c1 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009c1:	55                   	push   %ebp
  8009c2:	89 e5                	mov    %esp,%ebp
  8009c4:	56                   	push   %esi
  8009c5:	53                   	push   %ebx
  8009c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009cc:	89 c6                	mov    %eax,%esi
  8009ce:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009d1:	39 f0                	cmp    %esi,%eax
  8009d3:	74 16                	je     8009eb <memcmp+0x2a>
		if (*s1 != *s2)
  8009d5:	8a 08                	mov    (%eax),%cl
  8009d7:	8a 1a                	mov    (%edx),%bl
  8009d9:	38 d9                	cmp    %bl,%cl
  8009db:	75 04                	jne    8009e1 <memcmp+0x20>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  8009dd:	40                   	inc    %eax
  8009de:	42                   	inc    %edx
  8009df:	eb f0                	jmp    8009d1 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  8009e1:	0f b6 c1             	movzbl %cl,%eax
  8009e4:	0f b6 db             	movzbl %bl,%ebx
  8009e7:	29 d8                	sub    %ebx,%eax
  8009e9:	eb 05                	jmp    8009f0 <memcmp+0x2f>
	}

	return 0;
  8009eb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009f0:	5b                   	pop    %ebx
  8009f1:	5e                   	pop    %esi
  8009f2:	5d                   	pop    %ebp
  8009f3:	c3                   	ret    

008009f4 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009f4:	55                   	push   %ebp
  8009f5:	89 e5                	mov    %esp,%ebp
  8009f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8009fa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8009fd:	89 c2                	mov    %eax,%edx
  8009ff:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a02:	39 d0                	cmp    %edx,%eax
  800a04:	73 07                	jae    800a0d <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a06:	38 08                	cmp    %cl,(%eax)
  800a08:	74 03                	je     800a0d <memfind+0x19>
	for (; s < ends; s++)
  800a0a:	40                   	inc    %eax
  800a0b:	eb f5                	jmp    800a02 <memfind+0xe>
			break;
	return (void *) s;
}
  800a0d:	5d                   	pop    %ebp
  800a0e:	c3                   	ret    

00800a0f <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a0f:	55                   	push   %ebp
  800a10:	89 e5                	mov    %esp,%ebp
  800a12:	57                   	push   %edi
  800a13:	56                   	push   %esi
  800a14:	53                   	push   %ebx
  800a15:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a18:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a1b:	eb 01                	jmp    800a1e <strtol+0xf>
		s++;
  800a1d:	41                   	inc    %ecx
	while (*s == ' ' || *s == '\t')
  800a1e:	8a 01                	mov    (%ecx),%al
  800a20:	3c 20                	cmp    $0x20,%al
  800a22:	74 f9                	je     800a1d <strtol+0xe>
  800a24:	3c 09                	cmp    $0x9,%al
  800a26:	74 f5                	je     800a1d <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800a28:	3c 2b                	cmp    $0x2b,%al
  800a2a:	74 24                	je     800a50 <strtol+0x41>
		s++;
	else if (*s == '-')
  800a2c:	3c 2d                	cmp    $0x2d,%al
  800a2e:	74 28                	je     800a58 <strtol+0x49>
	int neg = 0;
  800a30:	bf 00 00 00 00       	mov    $0x0,%edi
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a35:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a3b:	75 09                	jne    800a46 <strtol+0x37>
  800a3d:	80 39 30             	cmpb   $0x30,(%ecx)
  800a40:	74 1e                	je     800a60 <strtol+0x51>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a42:	85 db                	test   %ebx,%ebx
  800a44:	74 36                	je     800a7c <strtol+0x6d>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a46:	b8 00 00 00 00       	mov    $0x0,%eax
  800a4b:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800a4e:	eb 45                	jmp    800a95 <strtol+0x86>
		s++;
  800a50:	41                   	inc    %ecx
	int neg = 0;
  800a51:	bf 00 00 00 00       	mov    $0x0,%edi
  800a56:	eb dd                	jmp    800a35 <strtol+0x26>
		s++, neg = 1;
  800a58:	41                   	inc    %ecx
  800a59:	bf 01 00 00 00       	mov    $0x1,%edi
  800a5e:	eb d5                	jmp    800a35 <strtol+0x26>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a60:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a64:	74 0c                	je     800a72 <strtol+0x63>
	else if (base == 0 && s[0] == '0')
  800a66:	85 db                	test   %ebx,%ebx
  800a68:	75 dc                	jne    800a46 <strtol+0x37>
		s++, base = 8;
  800a6a:	41                   	inc    %ecx
  800a6b:	bb 08 00 00 00       	mov    $0x8,%ebx
  800a70:	eb d4                	jmp    800a46 <strtol+0x37>
		s += 2, base = 16;
  800a72:	83 c1 02             	add    $0x2,%ecx
  800a75:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a7a:	eb ca                	jmp    800a46 <strtol+0x37>
		base = 10;
  800a7c:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800a81:	eb c3                	jmp    800a46 <strtol+0x37>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800a83:	0f be d2             	movsbl %dl,%edx
  800a86:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800a89:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a8c:	7d 37                	jge    800ac5 <strtol+0xb6>
			break;
		s++, val = (val * base) + dig;
  800a8e:	41                   	inc    %ecx
  800a8f:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a93:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800a95:	8a 11                	mov    (%ecx),%dl
  800a97:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a9a:	89 f3                	mov    %esi,%ebx
  800a9c:	80 fb 09             	cmp    $0x9,%bl
  800a9f:	76 e2                	jbe    800a83 <strtol+0x74>
		else if (*s >= 'a' && *s <= 'z')
  800aa1:	8d 72 9f             	lea    -0x61(%edx),%esi
  800aa4:	89 f3                	mov    %esi,%ebx
  800aa6:	80 fb 19             	cmp    $0x19,%bl
  800aa9:	77 08                	ja     800ab3 <strtol+0xa4>
			dig = *s - 'a' + 10;
  800aab:	0f be d2             	movsbl %dl,%edx
  800aae:	83 ea 57             	sub    $0x57,%edx
  800ab1:	eb d6                	jmp    800a89 <strtol+0x7a>
		else if (*s >= 'A' && *s <= 'Z')
  800ab3:	8d 72 bf             	lea    -0x41(%edx),%esi
  800ab6:	89 f3                	mov    %esi,%ebx
  800ab8:	80 fb 19             	cmp    $0x19,%bl
  800abb:	77 08                	ja     800ac5 <strtol+0xb6>
			dig = *s - 'A' + 10;
  800abd:	0f be d2             	movsbl %dl,%edx
  800ac0:	83 ea 37             	sub    $0x37,%edx
  800ac3:	eb c4                	jmp    800a89 <strtol+0x7a>
		// we don't properly detect overflow!
	}

	if (endptr)
  800ac5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ac9:	74 05                	je     800ad0 <strtol+0xc1>
		*endptr = (char *) s;
  800acb:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ace:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800ad0:	85 ff                	test   %edi,%edi
  800ad2:	74 02                	je     800ad6 <strtol+0xc7>
  800ad4:	f7 d8                	neg    %eax
}
  800ad6:	5b                   	pop    %ebx
  800ad7:	5e                   	pop    %esi
  800ad8:	5f                   	pop    %edi
  800ad9:	5d                   	pop    %ebp
  800ada:	c3                   	ret    
  800adb:	90                   	nop

00800adc <__udivdi3>:
  800adc:	55                   	push   %ebp
  800add:	57                   	push   %edi
  800ade:	56                   	push   %esi
  800adf:	53                   	push   %ebx
  800ae0:	83 ec 1c             	sub    $0x1c,%esp
  800ae3:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800ae7:	8b 74 24 34          	mov    0x34(%esp),%esi
  800aeb:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800aef:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800af3:	85 d2                	test   %edx,%edx
  800af5:	75 19                	jne    800b10 <__udivdi3+0x34>
  800af7:	39 f7                	cmp    %esi,%edi
  800af9:	76 45                	jbe    800b40 <__udivdi3+0x64>
  800afb:	89 e8                	mov    %ebp,%eax
  800afd:	89 f2                	mov    %esi,%edx
  800aff:	f7 f7                	div    %edi
  800b01:	31 db                	xor    %ebx,%ebx
  800b03:	89 da                	mov    %ebx,%edx
  800b05:	83 c4 1c             	add    $0x1c,%esp
  800b08:	5b                   	pop    %ebx
  800b09:	5e                   	pop    %esi
  800b0a:	5f                   	pop    %edi
  800b0b:	5d                   	pop    %ebp
  800b0c:	c3                   	ret    
  800b0d:	8d 76 00             	lea    0x0(%esi),%esi
  800b10:	39 f2                	cmp    %esi,%edx
  800b12:	76 10                	jbe    800b24 <__udivdi3+0x48>
  800b14:	31 db                	xor    %ebx,%ebx
  800b16:	31 c0                	xor    %eax,%eax
  800b18:	89 da                	mov    %ebx,%edx
  800b1a:	83 c4 1c             	add    $0x1c,%esp
  800b1d:	5b                   	pop    %ebx
  800b1e:	5e                   	pop    %esi
  800b1f:	5f                   	pop    %edi
  800b20:	5d                   	pop    %ebp
  800b21:	c3                   	ret    
  800b22:	66 90                	xchg   %ax,%ax
  800b24:	0f bd da             	bsr    %edx,%ebx
  800b27:	83 f3 1f             	xor    $0x1f,%ebx
  800b2a:	75 3c                	jne    800b68 <__udivdi3+0x8c>
  800b2c:	39 f2                	cmp    %esi,%edx
  800b2e:	72 08                	jb     800b38 <__udivdi3+0x5c>
  800b30:	39 ef                	cmp    %ebp,%edi
  800b32:	0f 87 9c 00 00 00    	ja     800bd4 <__udivdi3+0xf8>
  800b38:	b8 01 00 00 00       	mov    $0x1,%eax
  800b3d:	eb d9                	jmp    800b18 <__udivdi3+0x3c>
  800b3f:	90                   	nop
  800b40:	89 f9                	mov    %edi,%ecx
  800b42:	85 ff                	test   %edi,%edi
  800b44:	75 0b                	jne    800b51 <__udivdi3+0x75>
  800b46:	b8 01 00 00 00       	mov    $0x1,%eax
  800b4b:	31 d2                	xor    %edx,%edx
  800b4d:	f7 f7                	div    %edi
  800b4f:	89 c1                	mov    %eax,%ecx
  800b51:	31 d2                	xor    %edx,%edx
  800b53:	89 f0                	mov    %esi,%eax
  800b55:	f7 f1                	div    %ecx
  800b57:	89 c3                	mov    %eax,%ebx
  800b59:	89 e8                	mov    %ebp,%eax
  800b5b:	f7 f1                	div    %ecx
  800b5d:	89 da                	mov    %ebx,%edx
  800b5f:	83 c4 1c             	add    $0x1c,%esp
  800b62:	5b                   	pop    %ebx
  800b63:	5e                   	pop    %esi
  800b64:	5f                   	pop    %edi
  800b65:	5d                   	pop    %ebp
  800b66:	c3                   	ret    
  800b67:	90                   	nop
  800b68:	b8 20 00 00 00       	mov    $0x20,%eax
  800b6d:	29 d8                	sub    %ebx,%eax
  800b6f:	88 d9                	mov    %bl,%cl
  800b71:	d3 e2                	shl    %cl,%edx
  800b73:	89 54 24 08          	mov    %edx,0x8(%esp)
  800b77:	89 fa                	mov    %edi,%edx
  800b79:	88 c1                	mov    %al,%cl
  800b7b:	d3 ea                	shr    %cl,%edx
  800b7d:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800b81:	09 d1                	or     %edx,%ecx
  800b83:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800b87:	88 d9                	mov    %bl,%cl
  800b89:	d3 e7                	shl    %cl,%edi
  800b8b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800b8f:	89 f7                	mov    %esi,%edi
  800b91:	88 c1                	mov    %al,%cl
  800b93:	d3 ef                	shr    %cl,%edi
  800b95:	88 d9                	mov    %bl,%cl
  800b97:	d3 e6                	shl    %cl,%esi
  800b99:	89 ea                	mov    %ebp,%edx
  800b9b:	88 c1                	mov    %al,%cl
  800b9d:	d3 ea                	shr    %cl,%edx
  800b9f:	09 d6                	or     %edx,%esi
  800ba1:	89 f0                	mov    %esi,%eax
  800ba3:	89 fa                	mov    %edi,%edx
  800ba5:	f7 74 24 08          	divl   0x8(%esp)
  800ba9:	89 d7                	mov    %edx,%edi
  800bab:	89 c6                	mov    %eax,%esi
  800bad:	f7 64 24 0c          	mull   0xc(%esp)
  800bb1:	39 d7                	cmp    %edx,%edi
  800bb3:	72 13                	jb     800bc8 <__udivdi3+0xec>
  800bb5:	74 09                	je     800bc0 <__udivdi3+0xe4>
  800bb7:	89 f0                	mov    %esi,%eax
  800bb9:	31 db                	xor    %ebx,%ebx
  800bbb:	e9 58 ff ff ff       	jmp    800b18 <__udivdi3+0x3c>
  800bc0:	88 d9                	mov    %bl,%cl
  800bc2:	d3 e5                	shl    %cl,%ebp
  800bc4:	39 c5                	cmp    %eax,%ebp
  800bc6:	73 ef                	jae    800bb7 <__udivdi3+0xdb>
  800bc8:	8d 46 ff             	lea    -0x1(%esi),%eax
  800bcb:	31 db                	xor    %ebx,%ebx
  800bcd:	e9 46 ff ff ff       	jmp    800b18 <__udivdi3+0x3c>
  800bd2:	66 90                	xchg   %ax,%ax
  800bd4:	31 c0                	xor    %eax,%eax
  800bd6:	e9 3d ff ff ff       	jmp    800b18 <__udivdi3+0x3c>
  800bdb:	90                   	nop

00800bdc <__umoddi3>:
  800bdc:	55                   	push   %ebp
  800bdd:	57                   	push   %edi
  800bde:	56                   	push   %esi
  800bdf:	53                   	push   %ebx
  800be0:	83 ec 1c             	sub    $0x1c,%esp
  800be3:	8b 74 24 30          	mov    0x30(%esp),%esi
  800be7:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800beb:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800bef:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  800bf3:	85 c0                	test   %eax,%eax
  800bf5:	75 19                	jne    800c10 <__umoddi3+0x34>
  800bf7:	39 df                	cmp    %ebx,%edi
  800bf9:	76 51                	jbe    800c4c <__umoddi3+0x70>
  800bfb:	89 f0                	mov    %esi,%eax
  800bfd:	89 da                	mov    %ebx,%edx
  800bff:	f7 f7                	div    %edi
  800c01:	89 d0                	mov    %edx,%eax
  800c03:	31 d2                	xor    %edx,%edx
  800c05:	83 c4 1c             	add    $0x1c,%esp
  800c08:	5b                   	pop    %ebx
  800c09:	5e                   	pop    %esi
  800c0a:	5f                   	pop    %edi
  800c0b:	5d                   	pop    %ebp
  800c0c:	c3                   	ret    
  800c0d:	8d 76 00             	lea    0x0(%esi),%esi
  800c10:	89 f2                	mov    %esi,%edx
  800c12:	39 d8                	cmp    %ebx,%eax
  800c14:	76 0e                	jbe    800c24 <__umoddi3+0x48>
  800c16:	89 f0                	mov    %esi,%eax
  800c18:	89 da                	mov    %ebx,%edx
  800c1a:	83 c4 1c             	add    $0x1c,%esp
  800c1d:	5b                   	pop    %ebx
  800c1e:	5e                   	pop    %esi
  800c1f:	5f                   	pop    %edi
  800c20:	5d                   	pop    %ebp
  800c21:	c3                   	ret    
  800c22:	66 90                	xchg   %ax,%ax
  800c24:	0f bd e8             	bsr    %eax,%ebp
  800c27:	83 f5 1f             	xor    $0x1f,%ebp
  800c2a:	75 44                	jne    800c70 <__umoddi3+0x94>
  800c2c:	39 d8                	cmp    %ebx,%eax
  800c2e:	72 06                	jb     800c36 <__umoddi3+0x5a>
  800c30:	89 d9                	mov    %ebx,%ecx
  800c32:	39 f7                	cmp    %esi,%edi
  800c34:	77 08                	ja     800c3e <__umoddi3+0x62>
  800c36:	29 fe                	sub    %edi,%esi
  800c38:	19 c3                	sbb    %eax,%ebx
  800c3a:	89 f2                	mov    %esi,%edx
  800c3c:	89 d9                	mov    %ebx,%ecx
  800c3e:	89 d0                	mov    %edx,%eax
  800c40:	89 ca                	mov    %ecx,%edx
  800c42:	83 c4 1c             	add    $0x1c,%esp
  800c45:	5b                   	pop    %ebx
  800c46:	5e                   	pop    %esi
  800c47:	5f                   	pop    %edi
  800c48:	5d                   	pop    %ebp
  800c49:	c3                   	ret    
  800c4a:	66 90                	xchg   %ax,%ax
  800c4c:	89 fd                	mov    %edi,%ebp
  800c4e:	85 ff                	test   %edi,%edi
  800c50:	75 0b                	jne    800c5d <__umoddi3+0x81>
  800c52:	b8 01 00 00 00       	mov    $0x1,%eax
  800c57:	31 d2                	xor    %edx,%edx
  800c59:	f7 f7                	div    %edi
  800c5b:	89 c5                	mov    %eax,%ebp
  800c5d:	89 d8                	mov    %ebx,%eax
  800c5f:	31 d2                	xor    %edx,%edx
  800c61:	f7 f5                	div    %ebp
  800c63:	89 f0                	mov    %esi,%eax
  800c65:	f7 f5                	div    %ebp
  800c67:	89 d0                	mov    %edx,%eax
  800c69:	31 d2                	xor    %edx,%edx
  800c6b:	eb 98                	jmp    800c05 <__umoddi3+0x29>
  800c6d:	8d 76 00             	lea    0x0(%esi),%esi
  800c70:	ba 20 00 00 00       	mov    $0x20,%edx
  800c75:	29 ea                	sub    %ebp,%edx
  800c77:	89 e9                	mov    %ebp,%ecx
  800c79:	d3 e0                	shl    %cl,%eax
  800c7b:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c7f:	89 f8                	mov    %edi,%eax
  800c81:	89 54 24 04          	mov    %edx,0x4(%esp)
  800c85:	88 d1                	mov    %dl,%cl
  800c87:	d3 e8                	shr    %cl,%eax
  800c89:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800c8d:	09 c1                	or     %eax,%ecx
  800c8f:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800c93:	89 e9                	mov    %ebp,%ecx
  800c95:	d3 e7                	shl    %cl,%edi
  800c97:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800c9b:	89 d8                	mov    %ebx,%eax
  800c9d:	8b 54 24 04          	mov    0x4(%esp),%edx
  800ca1:	88 d1                	mov    %dl,%cl
  800ca3:	d3 e8                	shr    %cl,%eax
  800ca5:	89 c7                	mov    %eax,%edi
  800ca7:	89 e9                	mov    %ebp,%ecx
  800ca9:	d3 e3                	shl    %cl,%ebx
  800cab:	89 f0                	mov    %esi,%eax
  800cad:	88 d1                	mov    %dl,%cl
  800caf:	d3 e8                	shr    %cl,%eax
  800cb1:	09 d8                	or     %ebx,%eax
  800cb3:	89 e9                	mov    %ebp,%ecx
  800cb5:	d3 e6                	shl    %cl,%esi
  800cb7:	89 f3                	mov    %esi,%ebx
  800cb9:	89 fa                	mov    %edi,%edx
  800cbb:	f7 74 24 08          	divl   0x8(%esp)
  800cbf:	89 d1                	mov    %edx,%ecx
  800cc1:	f7 64 24 0c          	mull   0xc(%esp)
  800cc5:	89 c6                	mov    %eax,%esi
  800cc7:	89 d7                	mov    %edx,%edi
  800cc9:	39 d1                	cmp    %edx,%ecx
  800ccb:	72 27                	jb     800cf4 <__umoddi3+0x118>
  800ccd:	74 21                	je     800cf0 <__umoddi3+0x114>
  800ccf:	89 ca                	mov    %ecx,%edx
  800cd1:	29 f3                	sub    %esi,%ebx
  800cd3:	19 fa                	sbb    %edi,%edx
  800cd5:	89 d0                	mov    %edx,%eax
  800cd7:	8a 4c 24 04          	mov    0x4(%esp),%cl
  800cdb:	d3 e0                	shl    %cl,%eax
  800cdd:	89 e9                	mov    %ebp,%ecx
  800cdf:	d3 eb                	shr    %cl,%ebx
  800ce1:	09 d8                	or     %ebx,%eax
  800ce3:	d3 ea                	shr    %cl,%edx
  800ce5:	83 c4 1c             	add    $0x1c,%esp
  800ce8:	5b                   	pop    %ebx
  800ce9:	5e                   	pop    %esi
  800cea:	5f                   	pop    %edi
  800ceb:	5d                   	pop    %ebp
  800cec:	c3                   	ret    
  800ced:	8d 76 00             	lea    0x0(%esi),%esi
  800cf0:	39 c3                	cmp    %eax,%ebx
  800cf2:	73 db                	jae    800ccf <__umoddi3+0xf3>
  800cf4:	2b 44 24 0c          	sub    0xc(%esp),%eax
  800cf8:	1b 54 24 08          	sbb    0x8(%esp),%edx
  800cfc:	89 d7                	mov    %edx,%edi
  800cfe:	89 c6                	mov    %eax,%esi
  800d00:	eb cd                	jmp    800ccf <__umoddi3+0xf3>
