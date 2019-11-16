
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
  800040:	e8 4d 00 00 00       	call   800092 <sys_cputs>
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
  80004d:	83 ec 08             	sub    $0x8,%esp
  800050:	8b 45 08             	mov    0x8(%ebp),%eax
  800053:	8b 55 0c             	mov    0xc(%ebp),%edx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  800056:	c7 05 04 10 80 00 00 	movl   $0x0,0x801004
  80005d:	00 00 00 

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800060:	85 c0                	test   %eax,%eax
  800062:	7e 08                	jle    80006c <libmain+0x22>
		binaryname = argv[0];
  800064:	8b 0a                	mov    (%edx),%ecx
  800066:	89 0d 00 10 80 00    	mov    %ecx,0x801000

	// call user main routine
	umain(argc, argv);
  80006c:	83 ec 08             	sub    $0x8,%esp
  80006f:	52                   	push   %edx
  800070:	50                   	push   %eax
  800071:	e8 bd ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800076:	e8 05 00 00 00       	call   800080 <exit>
}
  80007b:	83 c4 10             	add    $0x10,%esp
  80007e:	c9                   	leave  
  80007f:	c3                   	ret    

00800080 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800080:	55                   	push   %ebp
  800081:	89 e5                	mov    %esp,%ebp
  800083:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800086:	6a 00                	push   $0x0
  800088:	e8 42 00 00 00       	call   8000cf <sys_env_destroy>
}
  80008d:	83 c4 10             	add    $0x10,%esp
  800090:	c9                   	leave  
  800091:	c3                   	ret    

00800092 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800092:	55                   	push   %ebp
  800093:	89 e5                	mov    %esp,%ebp
  800095:	57                   	push   %edi
  800096:	56                   	push   %esi
  800097:	53                   	push   %ebx
	asm volatile("int %1\n"
  800098:	b8 00 00 00 00       	mov    $0x0,%eax
  80009d:	8b 55 08             	mov    0x8(%ebp),%edx
  8000a0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000a3:	89 c3                	mov    %eax,%ebx
  8000a5:	89 c7                	mov    %eax,%edi
  8000a7:	89 c6                	mov    %eax,%esi
  8000a9:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000ab:	5b                   	pop    %ebx
  8000ac:	5e                   	pop    %esi
  8000ad:	5f                   	pop    %edi
  8000ae:	5d                   	pop    %ebp
  8000af:	c3                   	ret    

008000b0 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000b0:	55                   	push   %ebp
  8000b1:	89 e5                	mov    %esp,%ebp
  8000b3:	57                   	push   %edi
  8000b4:	56                   	push   %esi
  8000b5:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000b6:	ba 00 00 00 00       	mov    $0x0,%edx
  8000bb:	b8 01 00 00 00       	mov    $0x1,%eax
  8000c0:	89 d1                	mov    %edx,%ecx
  8000c2:	89 d3                	mov    %edx,%ebx
  8000c4:	89 d7                	mov    %edx,%edi
  8000c6:	89 d6                	mov    %edx,%esi
  8000c8:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000ca:	5b                   	pop    %ebx
  8000cb:	5e                   	pop    %esi
  8000cc:	5f                   	pop    %edi
  8000cd:	5d                   	pop    %ebp
  8000ce:	c3                   	ret    

008000cf <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000cf:	55                   	push   %ebp
  8000d0:	89 e5                	mov    %esp,%ebp
  8000d2:	57                   	push   %edi
  8000d3:	56                   	push   %esi
  8000d4:	53                   	push   %ebx
  8000d5:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8000d8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000dd:	8b 55 08             	mov    0x8(%ebp),%edx
  8000e0:	b8 03 00 00 00       	mov    $0x3,%eax
  8000e5:	89 cb                	mov    %ecx,%ebx
  8000e7:	89 cf                	mov    %ecx,%edi
  8000e9:	89 ce                	mov    %ecx,%esi
  8000eb:	cd 30                	int    $0x30
	if(check && ret > 0)
  8000ed:	85 c0                	test   %eax,%eax
  8000ef:	7f 08                	jg     8000f9 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  8000f1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000f4:	5b                   	pop    %ebx
  8000f5:	5e                   	pop    %esi
  8000f6:	5f                   	pop    %edi
  8000f7:	5d                   	pop    %ebp
  8000f8:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8000f9:	83 ec 0c             	sub    $0xc,%esp
  8000fc:	50                   	push   %eax
  8000fd:	6a 03                	push   $0x3
  8000ff:	68 f6 0c 80 00       	push   $0x800cf6
  800104:	6a 23                	push   $0x23
  800106:	68 13 0d 80 00       	push   $0x800d13
  80010b:	e8 1f 00 00 00       	call   80012f <_panic>

00800110 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800110:	55                   	push   %ebp
  800111:	89 e5                	mov    %esp,%ebp
  800113:	57                   	push   %edi
  800114:	56                   	push   %esi
  800115:	53                   	push   %ebx
	asm volatile("int %1\n"
  800116:	ba 00 00 00 00       	mov    $0x0,%edx
  80011b:	b8 02 00 00 00       	mov    $0x2,%eax
  800120:	89 d1                	mov    %edx,%ecx
  800122:	89 d3                	mov    %edx,%ebx
  800124:	89 d7                	mov    %edx,%edi
  800126:	89 d6                	mov    %edx,%esi
  800128:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80012a:	5b                   	pop    %ebx
  80012b:	5e                   	pop    %esi
  80012c:	5f                   	pop    %edi
  80012d:	5d                   	pop    %ebp
  80012e:	c3                   	ret    

0080012f <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80012f:	55                   	push   %ebp
  800130:	89 e5                	mov    %esp,%ebp
  800132:	56                   	push   %esi
  800133:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800134:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800137:	8b 35 00 10 80 00    	mov    0x801000,%esi
  80013d:	e8 ce ff ff ff       	call   800110 <sys_getenvid>
  800142:	83 ec 0c             	sub    $0xc,%esp
  800145:	ff 75 0c             	pushl  0xc(%ebp)
  800148:	ff 75 08             	pushl  0x8(%ebp)
  80014b:	56                   	push   %esi
  80014c:	50                   	push   %eax
  80014d:	68 24 0d 80 00       	push   $0x800d24
  800152:	e8 b2 00 00 00       	call   800209 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800157:	83 c4 18             	add    $0x18,%esp
  80015a:	53                   	push   %ebx
  80015b:	ff 75 10             	pushl  0x10(%ebp)
  80015e:	e8 55 00 00 00       	call   8001b8 <vcprintf>
	cprintf("\n");
  800163:	c7 04 24 48 0d 80 00 	movl   $0x800d48,(%esp)
  80016a:	e8 9a 00 00 00       	call   800209 <cprintf>
  80016f:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800172:	cc                   	int3   
  800173:	eb fd                	jmp    800172 <_panic+0x43>

00800175 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800175:	55                   	push   %ebp
  800176:	89 e5                	mov    %esp,%ebp
  800178:	53                   	push   %ebx
  800179:	83 ec 04             	sub    $0x4,%esp
  80017c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80017f:	8b 13                	mov    (%ebx),%edx
  800181:	8d 42 01             	lea    0x1(%edx),%eax
  800184:	89 03                	mov    %eax,(%ebx)
  800186:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800189:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80018d:	3d ff 00 00 00       	cmp    $0xff,%eax
  800192:	74 08                	je     80019c <putch+0x27>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800194:	ff 43 04             	incl   0x4(%ebx)
}
  800197:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80019a:	c9                   	leave  
  80019b:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  80019c:	83 ec 08             	sub    $0x8,%esp
  80019f:	68 ff 00 00 00       	push   $0xff
  8001a4:	8d 43 08             	lea    0x8(%ebx),%eax
  8001a7:	50                   	push   %eax
  8001a8:	e8 e5 fe ff ff       	call   800092 <sys_cputs>
		b->idx = 0;
  8001ad:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001b3:	83 c4 10             	add    $0x10,%esp
  8001b6:	eb dc                	jmp    800194 <putch+0x1f>

008001b8 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001b8:	55                   	push   %ebp
  8001b9:	89 e5                	mov    %esp,%ebp
  8001bb:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001c1:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001c8:	00 00 00 
	b.cnt = 0;
  8001cb:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001d2:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001d5:	ff 75 0c             	pushl  0xc(%ebp)
  8001d8:	ff 75 08             	pushl  0x8(%ebp)
  8001db:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001e1:	50                   	push   %eax
  8001e2:	68 75 01 80 00       	push   $0x800175
  8001e7:	e8 0f 01 00 00       	call   8002fb <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001ec:	83 c4 08             	add    $0x8,%esp
  8001ef:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001f5:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001fb:	50                   	push   %eax
  8001fc:	e8 91 fe ff ff       	call   800092 <sys_cputs>

	return b.cnt;
}
  800201:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800207:	c9                   	leave  
  800208:	c3                   	ret    

00800209 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800209:	55                   	push   %ebp
  80020a:	89 e5                	mov    %esp,%ebp
  80020c:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80020f:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800212:	50                   	push   %eax
  800213:	ff 75 08             	pushl  0x8(%ebp)
  800216:	e8 9d ff ff ff       	call   8001b8 <vcprintf>
	va_end(ap);

	return cnt;
}
  80021b:	c9                   	leave  
  80021c:	c3                   	ret    

0080021d <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80021d:	55                   	push   %ebp
  80021e:	89 e5                	mov    %esp,%ebp
  800220:	57                   	push   %edi
  800221:	56                   	push   %esi
  800222:	53                   	push   %ebx
  800223:	83 ec 1c             	sub    $0x1c,%esp
  800226:	89 c7                	mov    %eax,%edi
  800228:	89 d6                	mov    %edx,%esi
  80022a:	8b 45 08             	mov    0x8(%ebp),%eax
  80022d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800230:	89 d1                	mov    %edx,%ecx
  800232:	89 c2                	mov    %eax,%edx
  800234:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800237:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80023a:	8b 45 10             	mov    0x10(%ebp),%eax
  80023d:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800240:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800243:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80024a:	39 c2                	cmp    %eax,%edx
  80024c:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  80024f:	72 3c                	jb     80028d <printnum+0x70>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800251:	83 ec 0c             	sub    $0xc,%esp
  800254:	ff 75 18             	pushl  0x18(%ebp)
  800257:	4b                   	dec    %ebx
  800258:	53                   	push   %ebx
  800259:	50                   	push   %eax
  80025a:	83 ec 08             	sub    $0x8,%esp
  80025d:	ff 75 e4             	pushl  -0x1c(%ebp)
  800260:	ff 75 e0             	pushl  -0x20(%ebp)
  800263:	ff 75 dc             	pushl  -0x24(%ebp)
  800266:	ff 75 d8             	pushl  -0x28(%ebp)
  800269:	e8 56 08 00 00       	call   800ac4 <__udivdi3>
  80026e:	83 c4 18             	add    $0x18,%esp
  800271:	52                   	push   %edx
  800272:	50                   	push   %eax
  800273:	89 f2                	mov    %esi,%edx
  800275:	89 f8                	mov    %edi,%eax
  800277:	e8 a1 ff ff ff       	call   80021d <printnum>
  80027c:	83 c4 20             	add    $0x20,%esp
  80027f:	eb 11                	jmp    800292 <printnum+0x75>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800281:	83 ec 08             	sub    $0x8,%esp
  800284:	56                   	push   %esi
  800285:	ff 75 18             	pushl  0x18(%ebp)
  800288:	ff d7                	call   *%edi
  80028a:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  80028d:	4b                   	dec    %ebx
  80028e:	85 db                	test   %ebx,%ebx
  800290:	7f ef                	jg     800281 <printnum+0x64>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800292:	83 ec 08             	sub    $0x8,%esp
  800295:	56                   	push   %esi
  800296:	83 ec 04             	sub    $0x4,%esp
  800299:	ff 75 e4             	pushl  -0x1c(%ebp)
  80029c:	ff 75 e0             	pushl  -0x20(%ebp)
  80029f:	ff 75 dc             	pushl  -0x24(%ebp)
  8002a2:	ff 75 d8             	pushl  -0x28(%ebp)
  8002a5:	e8 1a 09 00 00       	call   800bc4 <__umoddi3>
  8002aa:	83 c4 14             	add    $0x14,%esp
  8002ad:	0f be 80 4a 0d 80 00 	movsbl 0x800d4a(%eax),%eax
  8002b4:	50                   	push   %eax
  8002b5:	ff d7                	call   *%edi
}
  8002b7:	83 c4 10             	add    $0x10,%esp
  8002ba:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002bd:	5b                   	pop    %ebx
  8002be:	5e                   	pop    %esi
  8002bf:	5f                   	pop    %edi
  8002c0:	5d                   	pop    %ebp
  8002c1:	c3                   	ret    

008002c2 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002c2:	55                   	push   %ebp
  8002c3:	89 e5                	mov    %esp,%ebp
  8002c5:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002c8:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8002cb:	8b 10                	mov    (%eax),%edx
  8002cd:	3b 50 04             	cmp    0x4(%eax),%edx
  8002d0:	73 0a                	jae    8002dc <sprintputch+0x1a>
		*b->buf++ = ch;
  8002d2:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002d5:	89 08                	mov    %ecx,(%eax)
  8002d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8002da:	88 02                	mov    %al,(%edx)
}
  8002dc:	5d                   	pop    %ebp
  8002dd:	c3                   	ret    

008002de <printfmt>:
{
  8002de:	55                   	push   %ebp
  8002df:	89 e5                	mov    %esp,%ebp
  8002e1:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8002e4:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002e7:	50                   	push   %eax
  8002e8:	ff 75 10             	pushl  0x10(%ebp)
  8002eb:	ff 75 0c             	pushl  0xc(%ebp)
  8002ee:	ff 75 08             	pushl  0x8(%ebp)
  8002f1:	e8 05 00 00 00       	call   8002fb <vprintfmt>
}
  8002f6:	83 c4 10             	add    $0x10,%esp
  8002f9:	c9                   	leave  
  8002fa:	c3                   	ret    

008002fb <vprintfmt>:
{
  8002fb:	55                   	push   %ebp
  8002fc:	89 e5                	mov    %esp,%ebp
  8002fe:	57                   	push   %edi
  8002ff:	56                   	push   %esi
  800300:	53                   	push   %ebx
  800301:	83 ec 3c             	sub    $0x3c,%esp
  800304:	8b 75 08             	mov    0x8(%ebp),%esi
  800307:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80030a:	8b 7d 10             	mov    0x10(%ebp),%edi
  80030d:	e9 5b 03 00 00       	jmp    80066d <vprintfmt+0x372>
		padc = ' ';
  800312:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  800316:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
		precision = -1;
  80031d:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  800324:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		lflag = 0;
  80032b:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800330:	8d 47 01             	lea    0x1(%edi),%eax
  800333:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800336:	8a 17                	mov    (%edi),%dl
  800338:	8d 42 dd             	lea    -0x23(%edx),%eax
  80033b:	3c 55                	cmp    $0x55,%al
  80033d:	0f 87 ab 03 00 00    	ja     8006ee <vprintfmt+0x3f3>
  800343:	0f b6 c0             	movzbl %al,%eax
  800346:	ff 24 85 d8 0d 80 00 	jmp    *0x800dd8(,%eax,4)
  80034d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800350:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  800354:	eb da                	jmp    800330 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  800356:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800359:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  80035d:	eb d1                	jmp    800330 <vprintfmt+0x35>
  80035f:	0f b6 d2             	movzbl %dl,%edx
  800362:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800365:	b8 00 00 00 00       	mov    $0x0,%eax
  80036a:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  80036d:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800370:	01 c0                	add    %eax,%eax
  800372:	8d 44 02 d0          	lea    -0x30(%edx,%eax,1),%eax
				ch = *fmt;
  800376:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800379:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80037c:	83 f9 09             	cmp    $0x9,%ecx
  80037f:	77 52                	ja     8003d3 <vprintfmt+0xd8>
			for (precision = 0; ; ++fmt) {
  800381:	47                   	inc    %edi
				precision = precision * 10 + ch - '0';
  800382:	eb e9                	jmp    80036d <vprintfmt+0x72>
			precision = va_arg(ap, int);
  800384:	8b 45 14             	mov    0x14(%ebp),%eax
  800387:	8b 00                	mov    (%eax),%eax
  800389:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80038c:	8b 45 14             	mov    0x14(%ebp),%eax
  80038f:	8d 40 04             	lea    0x4(%eax),%eax
  800392:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800395:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800398:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80039c:	79 92                	jns    800330 <vprintfmt+0x35>
				width = precision, precision = -1;
  80039e:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8003a1:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8003a4:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8003ab:	eb 83                	jmp    800330 <vprintfmt+0x35>
  8003ad:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8003b1:	78 08                	js     8003bb <vprintfmt+0xc0>
		switch (ch = *(unsigned char *) fmt++) {
  8003b3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8003b6:	e9 75 ff ff ff       	jmp    800330 <vprintfmt+0x35>
  8003bb:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  8003c2:	eb ef                	jmp    8003b3 <vprintfmt+0xb8>
		switch (ch = *(unsigned char *) fmt++) {
  8003c4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8003c7:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  8003ce:	e9 5d ff ff ff       	jmp    800330 <vprintfmt+0x35>
  8003d3:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8003d6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003d9:	eb bd                	jmp    800398 <vprintfmt+0x9d>
			lflag++;
  8003db:	41                   	inc    %ecx
		switch (ch = *(unsigned char *) fmt++) {
  8003dc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8003df:	e9 4c ff ff ff       	jmp    800330 <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
  8003e4:	8b 45 14             	mov    0x14(%ebp),%eax
  8003e7:	8d 78 04             	lea    0x4(%eax),%edi
  8003ea:	83 ec 08             	sub    $0x8,%esp
  8003ed:	53                   	push   %ebx
  8003ee:	ff 30                	pushl  (%eax)
  8003f0:	ff d6                	call   *%esi
			break;
  8003f2:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8003f5:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8003f8:	e9 6d 02 00 00       	jmp    80066a <vprintfmt+0x36f>
			err = va_arg(ap, int);
  8003fd:	8b 45 14             	mov    0x14(%ebp),%eax
  800400:	8d 78 04             	lea    0x4(%eax),%edi
  800403:	8b 00                	mov    (%eax),%eax
  800405:	85 c0                	test   %eax,%eax
  800407:	78 2a                	js     800433 <vprintfmt+0x138>
  800409:	89 c2                	mov    %eax,%edx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80040b:	83 f8 06             	cmp    $0x6,%eax
  80040e:	7f 27                	jg     800437 <vprintfmt+0x13c>
  800410:	8b 04 85 30 0f 80 00 	mov    0x800f30(,%eax,4),%eax
  800417:	85 c0                	test   %eax,%eax
  800419:	74 1c                	je     800437 <vprintfmt+0x13c>
				printfmt(putch, putdat, "%s", p);
  80041b:	50                   	push   %eax
  80041c:	68 6b 0d 80 00       	push   $0x800d6b
  800421:	53                   	push   %ebx
  800422:	56                   	push   %esi
  800423:	e8 b6 fe ff ff       	call   8002de <printfmt>
  800428:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80042b:	89 7d 14             	mov    %edi,0x14(%ebp)
  80042e:	e9 37 02 00 00       	jmp    80066a <vprintfmt+0x36f>
  800433:	f7 d8                	neg    %eax
  800435:	eb d2                	jmp    800409 <vprintfmt+0x10e>
				printfmt(putch, putdat, "error %d", err);
  800437:	52                   	push   %edx
  800438:	68 62 0d 80 00       	push   $0x800d62
  80043d:	53                   	push   %ebx
  80043e:	56                   	push   %esi
  80043f:	e8 9a fe ff ff       	call   8002de <printfmt>
  800444:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800447:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  80044a:	e9 1b 02 00 00       	jmp    80066a <vprintfmt+0x36f>
			if ((p = va_arg(ap, char *)) == NULL)
  80044f:	8b 45 14             	mov    0x14(%ebp),%eax
  800452:	83 c0 04             	add    $0x4,%eax
  800455:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800458:	8b 45 14             	mov    0x14(%ebp),%eax
  80045b:	8b 00                	mov    (%eax),%eax
  80045d:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800460:	85 c0                	test   %eax,%eax
  800462:	74 19                	je     80047d <vprintfmt+0x182>
			if (width > 0 && padc != '-')
  800464:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800468:	7e 06                	jle    800470 <vprintfmt+0x175>
  80046a:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  80046e:	75 16                	jne    800486 <vprintfmt+0x18b>
				for (width -= strnlen(p, precision); width > 0; width--)
  800470:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800473:	89 c7                	mov    %eax,%edi
  800475:	03 45 d4             	add    -0x2c(%ebp),%eax
  800478:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80047b:	eb 62                	jmp    8004df <vprintfmt+0x1e4>
				p = "(null)";
  80047d:	c7 45 cc 5b 0d 80 00 	movl   $0x800d5b,-0x34(%ebp)
  800484:	eb de                	jmp    800464 <vprintfmt+0x169>
				for (width -= strnlen(p, precision); width > 0; width--)
  800486:	83 ec 08             	sub    $0x8,%esp
  800489:	ff 75 d8             	pushl  -0x28(%ebp)
  80048c:	ff 75 cc             	pushl  -0x34(%ebp)
  80048f:	e8 05 03 00 00       	call   800799 <strnlen>
  800494:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800497:	29 c2                	sub    %eax,%edx
  800499:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  80049c:	83 c4 10             	add    $0x10,%esp
  80049f:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  8004a1:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8004a5:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8004a8:	eb 0d                	jmp    8004b7 <vprintfmt+0x1bc>
					putch(padc, putdat);
  8004aa:	83 ec 08             	sub    $0x8,%esp
  8004ad:	53                   	push   %ebx
  8004ae:	ff 75 d4             	pushl  -0x2c(%ebp)
  8004b1:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8004b3:	4f                   	dec    %edi
  8004b4:	83 c4 10             	add    $0x10,%esp
  8004b7:	85 ff                	test   %edi,%edi
  8004b9:	7f ef                	jg     8004aa <vprintfmt+0x1af>
  8004bb:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8004be:	89 d0                	mov    %edx,%eax
  8004c0:	85 d2                	test   %edx,%edx
  8004c2:	78 0a                	js     8004ce <vprintfmt+0x1d3>
  8004c4:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8004c7:	29 c2                	sub    %eax,%edx
  8004c9:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8004cc:	eb a2                	jmp    800470 <vprintfmt+0x175>
  8004ce:	b8 00 00 00 00       	mov    $0x0,%eax
  8004d3:	eb ef                	jmp    8004c4 <vprintfmt+0x1c9>
					putch(ch, putdat);
  8004d5:	83 ec 08             	sub    $0x8,%esp
  8004d8:	53                   	push   %ebx
  8004d9:	52                   	push   %edx
  8004da:	ff d6                	call   *%esi
  8004dc:	83 c4 10             	add    $0x10,%esp
  8004df:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  8004e2:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004e4:	47                   	inc    %edi
  8004e5:	8a 47 ff             	mov    -0x1(%edi),%al
  8004e8:	0f be d0             	movsbl %al,%edx
  8004eb:	85 d2                	test   %edx,%edx
  8004ed:	74 48                	je     800537 <vprintfmt+0x23c>
  8004ef:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004f3:	78 05                	js     8004fa <vprintfmt+0x1ff>
  8004f5:	ff 4d d8             	decl   -0x28(%ebp)
  8004f8:	78 1e                	js     800518 <vprintfmt+0x21d>
				if (altflag && (ch < ' ' || ch > '~'))
  8004fa:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004fe:	74 d5                	je     8004d5 <vprintfmt+0x1da>
  800500:	0f be c0             	movsbl %al,%eax
  800503:	83 e8 20             	sub    $0x20,%eax
  800506:	83 f8 5e             	cmp    $0x5e,%eax
  800509:	76 ca                	jbe    8004d5 <vprintfmt+0x1da>
					putch('?', putdat);
  80050b:	83 ec 08             	sub    $0x8,%esp
  80050e:	53                   	push   %ebx
  80050f:	6a 3f                	push   $0x3f
  800511:	ff d6                	call   *%esi
  800513:	83 c4 10             	add    $0x10,%esp
  800516:	eb c7                	jmp    8004df <vprintfmt+0x1e4>
  800518:	89 cf                	mov    %ecx,%edi
  80051a:	eb 0c                	jmp    800528 <vprintfmt+0x22d>
				putch(' ', putdat);
  80051c:	83 ec 08             	sub    $0x8,%esp
  80051f:	53                   	push   %ebx
  800520:	6a 20                	push   $0x20
  800522:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800524:	4f                   	dec    %edi
  800525:	83 c4 10             	add    $0x10,%esp
  800528:	85 ff                	test   %edi,%edi
  80052a:	7f f0                	jg     80051c <vprintfmt+0x221>
			if ((p = va_arg(ap, char *)) == NULL)
  80052c:	8b 45 c8             	mov    -0x38(%ebp),%eax
  80052f:	89 45 14             	mov    %eax,0x14(%ebp)
  800532:	e9 33 01 00 00       	jmp    80066a <vprintfmt+0x36f>
  800537:	89 cf                	mov    %ecx,%edi
  800539:	eb ed                	jmp    800528 <vprintfmt+0x22d>
	if (lflag >= 2)
  80053b:	83 f9 01             	cmp    $0x1,%ecx
  80053e:	7f 1b                	jg     80055b <vprintfmt+0x260>
	else if (lflag)
  800540:	85 c9                	test   %ecx,%ecx
  800542:	74 42                	je     800586 <vprintfmt+0x28b>
		return va_arg(*ap, long);
  800544:	8b 45 14             	mov    0x14(%ebp),%eax
  800547:	8b 00                	mov    (%eax),%eax
  800549:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80054c:	99                   	cltd   
  80054d:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800550:	8b 45 14             	mov    0x14(%ebp),%eax
  800553:	8d 40 04             	lea    0x4(%eax),%eax
  800556:	89 45 14             	mov    %eax,0x14(%ebp)
  800559:	eb 17                	jmp    800572 <vprintfmt+0x277>
		return va_arg(*ap, long long);
  80055b:	8b 45 14             	mov    0x14(%ebp),%eax
  80055e:	8b 50 04             	mov    0x4(%eax),%edx
  800561:	8b 00                	mov    (%eax),%eax
  800563:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800566:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800569:	8b 45 14             	mov    0x14(%ebp),%eax
  80056c:	8d 40 08             	lea    0x8(%eax),%eax
  80056f:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800572:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800575:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800578:	85 c9                	test   %ecx,%ecx
  80057a:	78 21                	js     80059d <vprintfmt+0x2a2>
			base = 10;
  80057c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800581:	e9 ca 00 00 00       	jmp    800650 <vprintfmt+0x355>
		return va_arg(*ap, int);
  800586:	8b 45 14             	mov    0x14(%ebp),%eax
  800589:	8b 00                	mov    (%eax),%eax
  80058b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80058e:	99                   	cltd   
  80058f:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800592:	8b 45 14             	mov    0x14(%ebp),%eax
  800595:	8d 40 04             	lea    0x4(%eax),%eax
  800598:	89 45 14             	mov    %eax,0x14(%ebp)
  80059b:	eb d5                	jmp    800572 <vprintfmt+0x277>
				putch('-', putdat);
  80059d:	83 ec 08             	sub    $0x8,%esp
  8005a0:	53                   	push   %ebx
  8005a1:	6a 2d                	push   $0x2d
  8005a3:	ff d6                	call   *%esi
				num = -(long long) num;
  8005a5:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005a8:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8005ab:	f7 da                	neg    %edx
  8005ad:	83 d1 00             	adc    $0x0,%ecx
  8005b0:	f7 d9                	neg    %ecx
  8005b2:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8005b5:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005ba:	e9 91 00 00 00       	jmp    800650 <vprintfmt+0x355>
	if (lflag >= 2)
  8005bf:	83 f9 01             	cmp    $0x1,%ecx
  8005c2:	7f 1b                	jg     8005df <vprintfmt+0x2e4>
	else if (lflag)
  8005c4:	85 c9                	test   %ecx,%ecx
  8005c6:	74 2c                	je     8005f4 <vprintfmt+0x2f9>
		return va_arg(*ap, unsigned long);
  8005c8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005cb:	8b 10                	mov    (%eax),%edx
  8005cd:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005d2:	8d 40 04             	lea    0x4(%eax),%eax
  8005d5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005d8:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  8005dd:	eb 71                	jmp    800650 <vprintfmt+0x355>
		return va_arg(*ap, unsigned long long);
  8005df:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e2:	8b 10                	mov    (%eax),%edx
  8005e4:	8b 48 04             	mov    0x4(%eax),%ecx
  8005e7:	8d 40 08             	lea    0x8(%eax),%eax
  8005ea:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005ed:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  8005f2:	eb 5c                	jmp    800650 <vprintfmt+0x355>
		return va_arg(*ap, unsigned int);
  8005f4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f7:	8b 10                	mov    (%eax),%edx
  8005f9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005fe:	8d 40 04             	lea    0x4(%eax),%eax
  800601:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800604:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  800609:	eb 45                	jmp    800650 <vprintfmt+0x355>
			putch('X', putdat);
  80060b:	83 ec 08             	sub    $0x8,%esp
  80060e:	53                   	push   %ebx
  80060f:	6a 58                	push   $0x58
  800611:	ff d6                	call   *%esi
			putch('X', putdat);
  800613:	83 c4 08             	add    $0x8,%esp
  800616:	53                   	push   %ebx
  800617:	6a 58                	push   $0x58
  800619:	ff d6                	call   *%esi
			putch('X', putdat);
  80061b:	83 c4 08             	add    $0x8,%esp
  80061e:	53                   	push   %ebx
  80061f:	6a 58                	push   $0x58
  800621:	ff d6                	call   *%esi
			break;
  800623:	83 c4 10             	add    $0x10,%esp
  800626:	eb 42                	jmp    80066a <vprintfmt+0x36f>
			putch('0', putdat);
  800628:	83 ec 08             	sub    $0x8,%esp
  80062b:	53                   	push   %ebx
  80062c:	6a 30                	push   $0x30
  80062e:	ff d6                	call   *%esi
			putch('x', putdat);
  800630:	83 c4 08             	add    $0x8,%esp
  800633:	53                   	push   %ebx
  800634:	6a 78                	push   $0x78
  800636:	ff d6                	call   *%esi
			num = (unsigned long long)
  800638:	8b 45 14             	mov    0x14(%ebp),%eax
  80063b:	8b 10                	mov    (%eax),%edx
  80063d:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800642:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800645:	8d 40 04             	lea    0x4(%eax),%eax
  800648:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80064b:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  800650:	83 ec 0c             	sub    $0xc,%esp
  800653:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  800657:	57                   	push   %edi
  800658:	ff 75 d4             	pushl  -0x2c(%ebp)
  80065b:	50                   	push   %eax
  80065c:	51                   	push   %ecx
  80065d:	52                   	push   %edx
  80065e:	89 da                	mov    %ebx,%edx
  800660:	89 f0                	mov    %esi,%eax
  800662:	e8 b6 fb ff ff       	call   80021d <printnum>
			break;
  800667:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  80066a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80066d:	47                   	inc    %edi
  80066e:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800672:	83 f8 25             	cmp    $0x25,%eax
  800675:	0f 84 97 fc ff ff    	je     800312 <vprintfmt+0x17>
			if (ch == '\0')
  80067b:	85 c0                	test   %eax,%eax
  80067d:	0f 84 89 00 00 00    	je     80070c <vprintfmt+0x411>
			putch(ch, putdat);
  800683:	83 ec 08             	sub    $0x8,%esp
  800686:	53                   	push   %ebx
  800687:	50                   	push   %eax
  800688:	ff d6                	call   *%esi
  80068a:	83 c4 10             	add    $0x10,%esp
  80068d:	eb de                	jmp    80066d <vprintfmt+0x372>
	if (lflag >= 2)
  80068f:	83 f9 01             	cmp    $0x1,%ecx
  800692:	7f 1b                	jg     8006af <vprintfmt+0x3b4>
	else if (lflag)
  800694:	85 c9                	test   %ecx,%ecx
  800696:	74 2c                	je     8006c4 <vprintfmt+0x3c9>
		return va_arg(*ap, unsigned long);
  800698:	8b 45 14             	mov    0x14(%ebp),%eax
  80069b:	8b 10                	mov    (%eax),%edx
  80069d:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006a2:	8d 40 04             	lea    0x4(%eax),%eax
  8006a5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006a8:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  8006ad:	eb a1                	jmp    800650 <vprintfmt+0x355>
		return va_arg(*ap, unsigned long long);
  8006af:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b2:	8b 10                	mov    (%eax),%edx
  8006b4:	8b 48 04             	mov    0x4(%eax),%ecx
  8006b7:	8d 40 08             	lea    0x8(%eax),%eax
  8006ba:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006bd:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  8006c2:	eb 8c                	jmp    800650 <vprintfmt+0x355>
		return va_arg(*ap, unsigned int);
  8006c4:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c7:	8b 10                	mov    (%eax),%edx
  8006c9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006ce:	8d 40 04             	lea    0x4(%eax),%eax
  8006d1:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006d4:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  8006d9:	e9 72 ff ff ff       	jmp    800650 <vprintfmt+0x355>
			putch(ch, putdat);
  8006de:	83 ec 08             	sub    $0x8,%esp
  8006e1:	53                   	push   %ebx
  8006e2:	6a 25                	push   $0x25
  8006e4:	ff d6                	call   *%esi
			break;
  8006e6:	83 c4 10             	add    $0x10,%esp
  8006e9:	e9 7c ff ff ff       	jmp    80066a <vprintfmt+0x36f>
			putch('%', putdat);
  8006ee:	83 ec 08             	sub    $0x8,%esp
  8006f1:	53                   	push   %ebx
  8006f2:	6a 25                	push   $0x25
  8006f4:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006f6:	83 c4 10             	add    $0x10,%esp
  8006f9:	89 f8                	mov    %edi,%eax
  8006fb:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8006ff:	74 03                	je     800704 <vprintfmt+0x409>
  800701:	48                   	dec    %eax
  800702:	eb f7                	jmp    8006fb <vprintfmt+0x400>
  800704:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800707:	e9 5e ff ff ff       	jmp    80066a <vprintfmt+0x36f>
}
  80070c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80070f:	5b                   	pop    %ebx
  800710:	5e                   	pop    %esi
  800711:	5f                   	pop    %edi
  800712:	5d                   	pop    %ebp
  800713:	c3                   	ret    

00800714 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800714:	55                   	push   %ebp
  800715:	89 e5                	mov    %esp,%ebp
  800717:	83 ec 18             	sub    $0x18,%esp
  80071a:	8b 45 08             	mov    0x8(%ebp),%eax
  80071d:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800720:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800723:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800727:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80072a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800731:	85 c0                	test   %eax,%eax
  800733:	74 26                	je     80075b <vsnprintf+0x47>
  800735:	85 d2                	test   %edx,%edx
  800737:	7e 29                	jle    800762 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800739:	ff 75 14             	pushl  0x14(%ebp)
  80073c:	ff 75 10             	pushl  0x10(%ebp)
  80073f:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800742:	50                   	push   %eax
  800743:	68 c2 02 80 00       	push   $0x8002c2
  800748:	e8 ae fb ff ff       	call   8002fb <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80074d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800750:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800753:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800756:	83 c4 10             	add    $0x10,%esp
}
  800759:	c9                   	leave  
  80075a:	c3                   	ret    
		return -E_INVAL;
  80075b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800760:	eb f7                	jmp    800759 <vsnprintf+0x45>
  800762:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800767:	eb f0                	jmp    800759 <vsnprintf+0x45>

00800769 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800769:	55                   	push   %ebp
  80076a:	89 e5                	mov    %esp,%ebp
  80076c:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80076f:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800772:	50                   	push   %eax
  800773:	ff 75 10             	pushl  0x10(%ebp)
  800776:	ff 75 0c             	pushl  0xc(%ebp)
  800779:	ff 75 08             	pushl  0x8(%ebp)
  80077c:	e8 93 ff ff ff       	call   800714 <vsnprintf>
	va_end(ap);

	return rc;
}
  800781:	c9                   	leave  
  800782:	c3                   	ret    

00800783 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800783:	55                   	push   %ebp
  800784:	89 e5                	mov    %esp,%ebp
  800786:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800789:	b8 00 00 00 00       	mov    $0x0,%eax
  80078e:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800792:	74 03                	je     800797 <strlen+0x14>
		n++;
  800794:	40                   	inc    %eax
  800795:	eb f7                	jmp    80078e <strlen+0xb>
	return n;
}
  800797:	5d                   	pop    %ebp
  800798:	c3                   	ret    

00800799 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800799:	55                   	push   %ebp
  80079a:	89 e5                	mov    %esp,%ebp
  80079c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80079f:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007a2:	b8 00 00 00 00       	mov    $0x0,%eax
  8007a7:	39 d0                	cmp    %edx,%eax
  8007a9:	74 0b                	je     8007b6 <strnlen+0x1d>
  8007ab:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007af:	74 03                	je     8007b4 <strnlen+0x1b>
		n++;
  8007b1:	40                   	inc    %eax
  8007b2:	eb f3                	jmp    8007a7 <strnlen+0xe>
  8007b4:	89 c2                	mov    %eax,%edx
	return n;
}
  8007b6:	89 d0                	mov    %edx,%eax
  8007b8:	5d                   	pop    %ebp
  8007b9:	c3                   	ret    

008007ba <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007ba:	55                   	push   %ebp
  8007bb:	89 e5                	mov    %esp,%ebp
  8007bd:	53                   	push   %ebx
  8007be:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007c1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007c4:	b8 00 00 00 00       	mov    $0x0,%eax
  8007c9:	8a 14 03             	mov    (%ebx,%eax,1),%dl
  8007cc:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8007cf:	40                   	inc    %eax
  8007d0:	84 d2                	test   %dl,%dl
  8007d2:	75 f5                	jne    8007c9 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8007d4:	89 c8                	mov    %ecx,%eax
  8007d6:	5b                   	pop    %ebx
  8007d7:	5d                   	pop    %ebp
  8007d8:	c3                   	ret    

008007d9 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007d9:	55                   	push   %ebp
  8007da:	89 e5                	mov    %esp,%ebp
  8007dc:	53                   	push   %ebx
  8007dd:	83 ec 10             	sub    $0x10,%esp
  8007e0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007e3:	53                   	push   %ebx
  8007e4:	e8 9a ff ff ff       	call   800783 <strlen>
  8007e9:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  8007ec:	ff 75 0c             	pushl  0xc(%ebp)
  8007ef:	01 d8                	add    %ebx,%eax
  8007f1:	50                   	push   %eax
  8007f2:	e8 c3 ff ff ff       	call   8007ba <strcpy>
	return dst;
}
  8007f7:	89 d8                	mov    %ebx,%eax
  8007f9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007fc:	c9                   	leave  
  8007fd:	c3                   	ret    

008007fe <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007fe:	55                   	push   %ebp
  8007ff:	89 e5                	mov    %esp,%ebp
  800801:	53                   	push   %ebx
  800802:	8b 55 0c             	mov    0xc(%ebp),%edx
  800805:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800808:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80080b:	8b 45 08             	mov    0x8(%ebp),%eax
  80080e:	39 d8                	cmp    %ebx,%eax
  800810:	74 0e                	je     800820 <strncpy+0x22>
		*dst++ = *src;
  800812:	40                   	inc    %eax
  800813:	8a 0a                	mov    (%edx),%cl
  800815:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800818:	80 f9 01             	cmp    $0x1,%cl
  80081b:	83 da ff             	sbb    $0xffffffff,%edx
  80081e:	eb ee                	jmp    80080e <strncpy+0x10>
	}
	return ret;
}
  800820:	8b 45 08             	mov    0x8(%ebp),%eax
  800823:	5b                   	pop    %ebx
  800824:	5d                   	pop    %ebp
  800825:	c3                   	ret    

00800826 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800826:	55                   	push   %ebp
  800827:	89 e5                	mov    %esp,%ebp
  800829:	56                   	push   %esi
  80082a:	53                   	push   %ebx
  80082b:	8b 75 08             	mov    0x8(%ebp),%esi
  80082e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800831:	8b 45 10             	mov    0x10(%ebp),%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800834:	85 c0                	test   %eax,%eax
  800836:	74 22                	je     80085a <strlcpy+0x34>
  800838:	8d 44 06 ff          	lea    -0x1(%esi,%eax,1),%eax
  80083c:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  80083e:	39 c2                	cmp    %eax,%edx
  800840:	74 0f                	je     800851 <strlcpy+0x2b>
  800842:	8a 19                	mov    (%ecx),%bl
  800844:	84 db                	test   %bl,%bl
  800846:	74 07                	je     80084f <strlcpy+0x29>
			*dst++ = *src++;
  800848:	41                   	inc    %ecx
  800849:	42                   	inc    %edx
  80084a:	88 5a ff             	mov    %bl,-0x1(%edx)
  80084d:	eb ef                	jmp    80083e <strlcpy+0x18>
  80084f:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800851:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800854:	29 f0                	sub    %esi,%eax
}
  800856:	5b                   	pop    %ebx
  800857:	5e                   	pop    %esi
  800858:	5d                   	pop    %ebp
  800859:	c3                   	ret    
  80085a:	89 f0                	mov    %esi,%eax
  80085c:	eb f6                	jmp    800854 <strlcpy+0x2e>

0080085e <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80085e:	55                   	push   %ebp
  80085f:	89 e5                	mov    %esp,%ebp
  800861:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800864:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800867:	8a 01                	mov    (%ecx),%al
  800869:	84 c0                	test   %al,%al
  80086b:	74 08                	je     800875 <strcmp+0x17>
  80086d:	3a 02                	cmp    (%edx),%al
  80086f:	75 04                	jne    800875 <strcmp+0x17>
		p++, q++;
  800871:	41                   	inc    %ecx
  800872:	42                   	inc    %edx
  800873:	eb f2                	jmp    800867 <strcmp+0x9>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800875:	0f b6 c0             	movzbl %al,%eax
  800878:	0f b6 12             	movzbl (%edx),%edx
  80087b:	29 d0                	sub    %edx,%eax
}
  80087d:	5d                   	pop    %ebp
  80087e:	c3                   	ret    

0080087f <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80087f:	55                   	push   %ebp
  800880:	89 e5                	mov    %esp,%ebp
  800882:	53                   	push   %ebx
  800883:	8b 45 08             	mov    0x8(%ebp),%eax
  800886:	8b 55 0c             	mov    0xc(%ebp),%edx
  800889:	89 c3                	mov    %eax,%ebx
  80088b:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80088e:	eb 02                	jmp    800892 <strncmp+0x13>
		n--, p++, q++;
  800890:	40                   	inc    %eax
  800891:	42                   	inc    %edx
	while (n > 0 && *p && *p == *q)
  800892:	39 d8                	cmp    %ebx,%eax
  800894:	74 15                	je     8008ab <strncmp+0x2c>
  800896:	8a 08                	mov    (%eax),%cl
  800898:	84 c9                	test   %cl,%cl
  80089a:	74 04                	je     8008a0 <strncmp+0x21>
  80089c:	3a 0a                	cmp    (%edx),%cl
  80089e:	74 f0                	je     800890 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008a0:	0f b6 00             	movzbl (%eax),%eax
  8008a3:	0f b6 12             	movzbl (%edx),%edx
  8008a6:	29 d0                	sub    %edx,%eax
}
  8008a8:	5b                   	pop    %ebx
  8008a9:	5d                   	pop    %ebp
  8008aa:	c3                   	ret    
		return 0;
  8008ab:	b8 00 00 00 00       	mov    $0x0,%eax
  8008b0:	eb f6                	jmp    8008a8 <strncmp+0x29>

008008b2 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008b2:	55                   	push   %ebp
  8008b3:	89 e5                	mov    %esp,%ebp
  8008b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b8:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8008bb:	8a 10                	mov    (%eax),%dl
  8008bd:	84 d2                	test   %dl,%dl
  8008bf:	74 07                	je     8008c8 <strchr+0x16>
		if (*s == c)
  8008c1:	38 ca                	cmp    %cl,%dl
  8008c3:	74 08                	je     8008cd <strchr+0x1b>
	for (; *s; s++)
  8008c5:	40                   	inc    %eax
  8008c6:	eb f3                	jmp    8008bb <strchr+0x9>
			return (char *) s;
	return 0;
  8008c8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008cd:	5d                   	pop    %ebp
  8008ce:	c3                   	ret    

008008cf <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008cf:	55                   	push   %ebp
  8008d0:	89 e5                	mov    %esp,%ebp
  8008d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d5:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8008d8:	8a 10                	mov    (%eax),%dl
  8008da:	84 d2                	test   %dl,%dl
  8008dc:	74 07                	je     8008e5 <strfind+0x16>
		if (*s == c)
  8008de:	38 ca                	cmp    %cl,%dl
  8008e0:	74 03                	je     8008e5 <strfind+0x16>
	for (; *s; s++)
  8008e2:	40                   	inc    %eax
  8008e3:	eb f3                	jmp    8008d8 <strfind+0x9>
			break;
	return (char *) s;
}
  8008e5:	5d                   	pop    %ebp
  8008e6:	c3                   	ret    

008008e7 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008e7:	55                   	push   %ebp
  8008e8:	89 e5                	mov    %esp,%ebp
  8008ea:	57                   	push   %edi
  8008eb:	56                   	push   %esi
  8008ec:	53                   	push   %ebx
  8008ed:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008f0:	85 c9                	test   %ecx,%ecx
  8008f2:	74 36                	je     80092a <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008f4:	89 c8                	mov    %ecx,%eax
  8008f6:	0b 45 08             	or     0x8(%ebp),%eax
  8008f9:	a8 03                	test   $0x3,%al
  8008fb:	75 24                	jne    800921 <memset+0x3a>
		c &= 0xFF;
  8008fd:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800901:	89 d3                	mov    %edx,%ebx
  800903:	c1 e3 08             	shl    $0x8,%ebx
  800906:	89 d0                	mov    %edx,%eax
  800908:	c1 e0 18             	shl    $0x18,%eax
  80090b:	89 d6                	mov    %edx,%esi
  80090d:	c1 e6 10             	shl    $0x10,%esi
  800910:	09 f0                	or     %esi,%eax
  800912:	09 d0                	or     %edx,%eax
  800914:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800916:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800919:	8b 7d 08             	mov    0x8(%ebp),%edi
  80091c:	fc                   	cld    
  80091d:	f3 ab                	rep stos %eax,%es:(%edi)
  80091f:	eb 09                	jmp    80092a <memset+0x43>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800921:	8b 7d 08             	mov    0x8(%ebp),%edi
  800924:	8b 45 0c             	mov    0xc(%ebp),%eax
  800927:	fc                   	cld    
  800928:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80092a:	8b 45 08             	mov    0x8(%ebp),%eax
  80092d:	5b                   	pop    %ebx
  80092e:	5e                   	pop    %esi
  80092f:	5f                   	pop    %edi
  800930:	5d                   	pop    %ebp
  800931:	c3                   	ret    

00800932 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800932:	55                   	push   %ebp
  800933:	89 e5                	mov    %esp,%ebp
  800935:	57                   	push   %edi
  800936:	56                   	push   %esi
  800937:	8b 45 08             	mov    0x8(%ebp),%eax
  80093a:	8b 75 0c             	mov    0xc(%ebp),%esi
  80093d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800940:	39 c6                	cmp    %eax,%esi
  800942:	73 30                	jae    800974 <memmove+0x42>
  800944:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800947:	39 c2                	cmp    %eax,%edx
  800949:	76 29                	jbe    800974 <memmove+0x42>
		s += n;
		d += n;
  80094b:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80094e:	89 fe                	mov    %edi,%esi
  800950:	09 ce                	or     %ecx,%esi
  800952:	09 d6                	or     %edx,%esi
  800954:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80095a:	75 0e                	jne    80096a <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  80095c:	83 ef 04             	sub    $0x4,%edi
  80095f:	8d 72 fc             	lea    -0x4(%edx),%esi
  800962:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800965:	fd                   	std    
  800966:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800968:	eb 07                	jmp    800971 <memmove+0x3f>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80096a:	4f                   	dec    %edi
  80096b:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  80096e:	fd                   	std    
  80096f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800971:	fc                   	cld    
  800972:	eb 1a                	jmp    80098e <memmove+0x5c>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800974:	89 c2                	mov    %eax,%edx
  800976:	09 ca                	or     %ecx,%edx
  800978:	09 f2                	or     %esi,%edx
  80097a:	f6 c2 03             	test   $0x3,%dl
  80097d:	75 0a                	jne    800989 <memmove+0x57>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  80097f:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800982:	89 c7                	mov    %eax,%edi
  800984:	fc                   	cld    
  800985:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800987:	eb 05                	jmp    80098e <memmove+0x5c>
		else
			asm volatile("cld; rep movsb\n"
  800989:	89 c7                	mov    %eax,%edi
  80098b:	fc                   	cld    
  80098c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80098e:	5e                   	pop    %esi
  80098f:	5f                   	pop    %edi
  800990:	5d                   	pop    %ebp
  800991:	c3                   	ret    

00800992 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800992:	55                   	push   %ebp
  800993:	89 e5                	mov    %esp,%ebp
  800995:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800998:	ff 75 10             	pushl  0x10(%ebp)
  80099b:	ff 75 0c             	pushl  0xc(%ebp)
  80099e:	ff 75 08             	pushl  0x8(%ebp)
  8009a1:	e8 8c ff ff ff       	call   800932 <memmove>
}
  8009a6:	c9                   	leave  
  8009a7:	c3                   	ret    

008009a8 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009a8:	55                   	push   %ebp
  8009a9:	89 e5                	mov    %esp,%ebp
  8009ab:	56                   	push   %esi
  8009ac:	53                   	push   %ebx
  8009ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009b3:	89 c6                	mov    %eax,%esi
  8009b5:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009b8:	39 f0                	cmp    %esi,%eax
  8009ba:	74 16                	je     8009d2 <memcmp+0x2a>
		if (*s1 != *s2)
  8009bc:	8a 08                	mov    (%eax),%cl
  8009be:	8a 1a                	mov    (%edx),%bl
  8009c0:	38 d9                	cmp    %bl,%cl
  8009c2:	75 04                	jne    8009c8 <memcmp+0x20>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  8009c4:	40                   	inc    %eax
  8009c5:	42                   	inc    %edx
  8009c6:	eb f0                	jmp    8009b8 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  8009c8:	0f b6 c1             	movzbl %cl,%eax
  8009cb:	0f b6 db             	movzbl %bl,%ebx
  8009ce:	29 d8                	sub    %ebx,%eax
  8009d0:	eb 05                	jmp    8009d7 <memcmp+0x2f>
	}

	return 0;
  8009d2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009d7:	5b                   	pop    %ebx
  8009d8:	5e                   	pop    %esi
  8009d9:	5d                   	pop    %ebp
  8009da:	c3                   	ret    

008009db <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009db:	55                   	push   %ebp
  8009dc:	89 e5                	mov    %esp,%ebp
  8009de:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8009e4:	89 c2                	mov    %eax,%edx
  8009e6:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8009e9:	39 d0                	cmp    %edx,%eax
  8009eb:	73 07                	jae    8009f4 <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009ed:	38 08                	cmp    %cl,(%eax)
  8009ef:	74 03                	je     8009f4 <memfind+0x19>
	for (; s < ends; s++)
  8009f1:	40                   	inc    %eax
  8009f2:	eb f5                	jmp    8009e9 <memfind+0xe>
			break;
	return (void *) s;
}
  8009f4:	5d                   	pop    %ebp
  8009f5:	c3                   	ret    

008009f6 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009f6:	55                   	push   %ebp
  8009f7:	89 e5                	mov    %esp,%ebp
  8009f9:	57                   	push   %edi
  8009fa:	56                   	push   %esi
  8009fb:	53                   	push   %ebx
  8009fc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009ff:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a02:	eb 01                	jmp    800a05 <strtol+0xf>
		s++;
  800a04:	41                   	inc    %ecx
	while (*s == ' ' || *s == '\t')
  800a05:	8a 01                	mov    (%ecx),%al
  800a07:	3c 20                	cmp    $0x20,%al
  800a09:	74 f9                	je     800a04 <strtol+0xe>
  800a0b:	3c 09                	cmp    $0x9,%al
  800a0d:	74 f5                	je     800a04 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800a0f:	3c 2b                	cmp    $0x2b,%al
  800a11:	74 24                	je     800a37 <strtol+0x41>
		s++;
	else if (*s == '-')
  800a13:	3c 2d                	cmp    $0x2d,%al
  800a15:	74 28                	je     800a3f <strtol+0x49>
	int neg = 0;
  800a17:	bf 00 00 00 00       	mov    $0x0,%edi
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a1c:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a22:	75 09                	jne    800a2d <strtol+0x37>
  800a24:	80 39 30             	cmpb   $0x30,(%ecx)
  800a27:	74 1e                	je     800a47 <strtol+0x51>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a29:	85 db                	test   %ebx,%ebx
  800a2b:	74 36                	je     800a63 <strtol+0x6d>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a2d:	b8 00 00 00 00       	mov    $0x0,%eax
  800a32:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800a35:	eb 45                	jmp    800a7c <strtol+0x86>
		s++;
  800a37:	41                   	inc    %ecx
	int neg = 0;
  800a38:	bf 00 00 00 00       	mov    $0x0,%edi
  800a3d:	eb dd                	jmp    800a1c <strtol+0x26>
		s++, neg = 1;
  800a3f:	41                   	inc    %ecx
  800a40:	bf 01 00 00 00       	mov    $0x1,%edi
  800a45:	eb d5                	jmp    800a1c <strtol+0x26>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a47:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a4b:	74 0c                	je     800a59 <strtol+0x63>
	else if (base == 0 && s[0] == '0')
  800a4d:	85 db                	test   %ebx,%ebx
  800a4f:	75 dc                	jne    800a2d <strtol+0x37>
		s++, base = 8;
  800a51:	41                   	inc    %ecx
  800a52:	bb 08 00 00 00       	mov    $0x8,%ebx
  800a57:	eb d4                	jmp    800a2d <strtol+0x37>
		s += 2, base = 16;
  800a59:	83 c1 02             	add    $0x2,%ecx
  800a5c:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a61:	eb ca                	jmp    800a2d <strtol+0x37>
		base = 10;
  800a63:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800a68:	eb c3                	jmp    800a2d <strtol+0x37>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800a6a:	0f be d2             	movsbl %dl,%edx
  800a6d:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800a70:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a73:	7d 37                	jge    800aac <strtol+0xb6>
			break;
		s++, val = (val * base) + dig;
  800a75:	41                   	inc    %ecx
  800a76:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a7a:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800a7c:	8a 11                	mov    (%ecx),%dl
  800a7e:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a81:	89 f3                	mov    %esi,%ebx
  800a83:	80 fb 09             	cmp    $0x9,%bl
  800a86:	76 e2                	jbe    800a6a <strtol+0x74>
		else if (*s >= 'a' && *s <= 'z')
  800a88:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a8b:	89 f3                	mov    %esi,%ebx
  800a8d:	80 fb 19             	cmp    $0x19,%bl
  800a90:	77 08                	ja     800a9a <strtol+0xa4>
			dig = *s - 'a' + 10;
  800a92:	0f be d2             	movsbl %dl,%edx
  800a95:	83 ea 57             	sub    $0x57,%edx
  800a98:	eb d6                	jmp    800a70 <strtol+0x7a>
		else if (*s >= 'A' && *s <= 'Z')
  800a9a:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a9d:	89 f3                	mov    %esi,%ebx
  800a9f:	80 fb 19             	cmp    $0x19,%bl
  800aa2:	77 08                	ja     800aac <strtol+0xb6>
			dig = *s - 'A' + 10;
  800aa4:	0f be d2             	movsbl %dl,%edx
  800aa7:	83 ea 37             	sub    $0x37,%edx
  800aaa:	eb c4                	jmp    800a70 <strtol+0x7a>
		// we don't properly detect overflow!
	}

	if (endptr)
  800aac:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ab0:	74 05                	je     800ab7 <strtol+0xc1>
		*endptr = (char *) s;
  800ab2:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ab5:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800ab7:	85 ff                	test   %edi,%edi
  800ab9:	74 02                	je     800abd <strtol+0xc7>
  800abb:	f7 d8                	neg    %eax
}
  800abd:	5b                   	pop    %ebx
  800abe:	5e                   	pop    %esi
  800abf:	5f                   	pop    %edi
  800ac0:	5d                   	pop    %ebp
  800ac1:	c3                   	ret    
  800ac2:	66 90                	xchg   %ax,%ax

00800ac4 <__udivdi3>:
  800ac4:	55                   	push   %ebp
  800ac5:	57                   	push   %edi
  800ac6:	56                   	push   %esi
  800ac7:	53                   	push   %ebx
  800ac8:	83 ec 1c             	sub    $0x1c,%esp
  800acb:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800acf:	8b 74 24 34          	mov    0x34(%esp),%esi
  800ad3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800ad7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800adb:	85 d2                	test   %edx,%edx
  800add:	75 19                	jne    800af8 <__udivdi3+0x34>
  800adf:	39 f7                	cmp    %esi,%edi
  800ae1:	76 45                	jbe    800b28 <__udivdi3+0x64>
  800ae3:	89 e8                	mov    %ebp,%eax
  800ae5:	89 f2                	mov    %esi,%edx
  800ae7:	f7 f7                	div    %edi
  800ae9:	31 db                	xor    %ebx,%ebx
  800aeb:	89 da                	mov    %ebx,%edx
  800aed:	83 c4 1c             	add    $0x1c,%esp
  800af0:	5b                   	pop    %ebx
  800af1:	5e                   	pop    %esi
  800af2:	5f                   	pop    %edi
  800af3:	5d                   	pop    %ebp
  800af4:	c3                   	ret    
  800af5:	8d 76 00             	lea    0x0(%esi),%esi
  800af8:	39 f2                	cmp    %esi,%edx
  800afa:	76 10                	jbe    800b0c <__udivdi3+0x48>
  800afc:	31 db                	xor    %ebx,%ebx
  800afe:	31 c0                	xor    %eax,%eax
  800b00:	89 da                	mov    %ebx,%edx
  800b02:	83 c4 1c             	add    $0x1c,%esp
  800b05:	5b                   	pop    %ebx
  800b06:	5e                   	pop    %esi
  800b07:	5f                   	pop    %edi
  800b08:	5d                   	pop    %ebp
  800b09:	c3                   	ret    
  800b0a:	66 90                	xchg   %ax,%ax
  800b0c:	0f bd da             	bsr    %edx,%ebx
  800b0f:	83 f3 1f             	xor    $0x1f,%ebx
  800b12:	75 3c                	jne    800b50 <__udivdi3+0x8c>
  800b14:	39 f2                	cmp    %esi,%edx
  800b16:	72 08                	jb     800b20 <__udivdi3+0x5c>
  800b18:	39 ef                	cmp    %ebp,%edi
  800b1a:	0f 87 9c 00 00 00    	ja     800bbc <__udivdi3+0xf8>
  800b20:	b8 01 00 00 00       	mov    $0x1,%eax
  800b25:	eb d9                	jmp    800b00 <__udivdi3+0x3c>
  800b27:	90                   	nop
  800b28:	89 f9                	mov    %edi,%ecx
  800b2a:	85 ff                	test   %edi,%edi
  800b2c:	75 0b                	jne    800b39 <__udivdi3+0x75>
  800b2e:	b8 01 00 00 00       	mov    $0x1,%eax
  800b33:	31 d2                	xor    %edx,%edx
  800b35:	f7 f7                	div    %edi
  800b37:	89 c1                	mov    %eax,%ecx
  800b39:	31 d2                	xor    %edx,%edx
  800b3b:	89 f0                	mov    %esi,%eax
  800b3d:	f7 f1                	div    %ecx
  800b3f:	89 c3                	mov    %eax,%ebx
  800b41:	89 e8                	mov    %ebp,%eax
  800b43:	f7 f1                	div    %ecx
  800b45:	89 da                	mov    %ebx,%edx
  800b47:	83 c4 1c             	add    $0x1c,%esp
  800b4a:	5b                   	pop    %ebx
  800b4b:	5e                   	pop    %esi
  800b4c:	5f                   	pop    %edi
  800b4d:	5d                   	pop    %ebp
  800b4e:	c3                   	ret    
  800b4f:	90                   	nop
  800b50:	b8 20 00 00 00       	mov    $0x20,%eax
  800b55:	29 d8                	sub    %ebx,%eax
  800b57:	88 d9                	mov    %bl,%cl
  800b59:	d3 e2                	shl    %cl,%edx
  800b5b:	89 54 24 08          	mov    %edx,0x8(%esp)
  800b5f:	89 fa                	mov    %edi,%edx
  800b61:	88 c1                	mov    %al,%cl
  800b63:	d3 ea                	shr    %cl,%edx
  800b65:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800b69:	09 d1                	or     %edx,%ecx
  800b6b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800b6f:	88 d9                	mov    %bl,%cl
  800b71:	d3 e7                	shl    %cl,%edi
  800b73:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800b77:	89 f7                	mov    %esi,%edi
  800b79:	88 c1                	mov    %al,%cl
  800b7b:	d3 ef                	shr    %cl,%edi
  800b7d:	88 d9                	mov    %bl,%cl
  800b7f:	d3 e6                	shl    %cl,%esi
  800b81:	89 ea                	mov    %ebp,%edx
  800b83:	88 c1                	mov    %al,%cl
  800b85:	d3 ea                	shr    %cl,%edx
  800b87:	09 d6                	or     %edx,%esi
  800b89:	89 f0                	mov    %esi,%eax
  800b8b:	89 fa                	mov    %edi,%edx
  800b8d:	f7 74 24 08          	divl   0x8(%esp)
  800b91:	89 d7                	mov    %edx,%edi
  800b93:	89 c6                	mov    %eax,%esi
  800b95:	f7 64 24 0c          	mull   0xc(%esp)
  800b99:	39 d7                	cmp    %edx,%edi
  800b9b:	72 13                	jb     800bb0 <__udivdi3+0xec>
  800b9d:	74 09                	je     800ba8 <__udivdi3+0xe4>
  800b9f:	89 f0                	mov    %esi,%eax
  800ba1:	31 db                	xor    %ebx,%ebx
  800ba3:	e9 58 ff ff ff       	jmp    800b00 <__udivdi3+0x3c>
  800ba8:	88 d9                	mov    %bl,%cl
  800baa:	d3 e5                	shl    %cl,%ebp
  800bac:	39 c5                	cmp    %eax,%ebp
  800bae:	73 ef                	jae    800b9f <__udivdi3+0xdb>
  800bb0:	8d 46 ff             	lea    -0x1(%esi),%eax
  800bb3:	31 db                	xor    %ebx,%ebx
  800bb5:	e9 46 ff ff ff       	jmp    800b00 <__udivdi3+0x3c>
  800bba:	66 90                	xchg   %ax,%ax
  800bbc:	31 c0                	xor    %eax,%eax
  800bbe:	e9 3d ff ff ff       	jmp    800b00 <__udivdi3+0x3c>
  800bc3:	90                   	nop

00800bc4 <__umoddi3>:
  800bc4:	55                   	push   %ebp
  800bc5:	57                   	push   %edi
  800bc6:	56                   	push   %esi
  800bc7:	53                   	push   %ebx
  800bc8:	83 ec 1c             	sub    $0x1c,%esp
  800bcb:	8b 74 24 30          	mov    0x30(%esp),%esi
  800bcf:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800bd3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800bd7:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  800bdb:	85 c0                	test   %eax,%eax
  800bdd:	75 19                	jne    800bf8 <__umoddi3+0x34>
  800bdf:	39 df                	cmp    %ebx,%edi
  800be1:	76 51                	jbe    800c34 <__umoddi3+0x70>
  800be3:	89 f0                	mov    %esi,%eax
  800be5:	89 da                	mov    %ebx,%edx
  800be7:	f7 f7                	div    %edi
  800be9:	89 d0                	mov    %edx,%eax
  800beb:	31 d2                	xor    %edx,%edx
  800bed:	83 c4 1c             	add    $0x1c,%esp
  800bf0:	5b                   	pop    %ebx
  800bf1:	5e                   	pop    %esi
  800bf2:	5f                   	pop    %edi
  800bf3:	5d                   	pop    %ebp
  800bf4:	c3                   	ret    
  800bf5:	8d 76 00             	lea    0x0(%esi),%esi
  800bf8:	89 f2                	mov    %esi,%edx
  800bfa:	39 d8                	cmp    %ebx,%eax
  800bfc:	76 0e                	jbe    800c0c <__umoddi3+0x48>
  800bfe:	89 f0                	mov    %esi,%eax
  800c00:	89 da                	mov    %ebx,%edx
  800c02:	83 c4 1c             	add    $0x1c,%esp
  800c05:	5b                   	pop    %ebx
  800c06:	5e                   	pop    %esi
  800c07:	5f                   	pop    %edi
  800c08:	5d                   	pop    %ebp
  800c09:	c3                   	ret    
  800c0a:	66 90                	xchg   %ax,%ax
  800c0c:	0f bd e8             	bsr    %eax,%ebp
  800c0f:	83 f5 1f             	xor    $0x1f,%ebp
  800c12:	75 44                	jne    800c58 <__umoddi3+0x94>
  800c14:	39 d8                	cmp    %ebx,%eax
  800c16:	72 06                	jb     800c1e <__umoddi3+0x5a>
  800c18:	89 d9                	mov    %ebx,%ecx
  800c1a:	39 f7                	cmp    %esi,%edi
  800c1c:	77 08                	ja     800c26 <__umoddi3+0x62>
  800c1e:	29 fe                	sub    %edi,%esi
  800c20:	19 c3                	sbb    %eax,%ebx
  800c22:	89 f2                	mov    %esi,%edx
  800c24:	89 d9                	mov    %ebx,%ecx
  800c26:	89 d0                	mov    %edx,%eax
  800c28:	89 ca                	mov    %ecx,%edx
  800c2a:	83 c4 1c             	add    $0x1c,%esp
  800c2d:	5b                   	pop    %ebx
  800c2e:	5e                   	pop    %esi
  800c2f:	5f                   	pop    %edi
  800c30:	5d                   	pop    %ebp
  800c31:	c3                   	ret    
  800c32:	66 90                	xchg   %ax,%ax
  800c34:	89 fd                	mov    %edi,%ebp
  800c36:	85 ff                	test   %edi,%edi
  800c38:	75 0b                	jne    800c45 <__umoddi3+0x81>
  800c3a:	b8 01 00 00 00       	mov    $0x1,%eax
  800c3f:	31 d2                	xor    %edx,%edx
  800c41:	f7 f7                	div    %edi
  800c43:	89 c5                	mov    %eax,%ebp
  800c45:	89 d8                	mov    %ebx,%eax
  800c47:	31 d2                	xor    %edx,%edx
  800c49:	f7 f5                	div    %ebp
  800c4b:	89 f0                	mov    %esi,%eax
  800c4d:	f7 f5                	div    %ebp
  800c4f:	89 d0                	mov    %edx,%eax
  800c51:	31 d2                	xor    %edx,%edx
  800c53:	eb 98                	jmp    800bed <__umoddi3+0x29>
  800c55:	8d 76 00             	lea    0x0(%esi),%esi
  800c58:	ba 20 00 00 00       	mov    $0x20,%edx
  800c5d:	29 ea                	sub    %ebp,%edx
  800c5f:	89 e9                	mov    %ebp,%ecx
  800c61:	d3 e0                	shl    %cl,%eax
  800c63:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c67:	89 f8                	mov    %edi,%eax
  800c69:	89 54 24 04          	mov    %edx,0x4(%esp)
  800c6d:	88 d1                	mov    %dl,%cl
  800c6f:	d3 e8                	shr    %cl,%eax
  800c71:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800c75:	09 c1                	or     %eax,%ecx
  800c77:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800c7b:	89 e9                	mov    %ebp,%ecx
  800c7d:	d3 e7                	shl    %cl,%edi
  800c7f:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800c83:	89 d8                	mov    %ebx,%eax
  800c85:	8b 54 24 04          	mov    0x4(%esp),%edx
  800c89:	88 d1                	mov    %dl,%cl
  800c8b:	d3 e8                	shr    %cl,%eax
  800c8d:	89 c7                	mov    %eax,%edi
  800c8f:	89 e9                	mov    %ebp,%ecx
  800c91:	d3 e3                	shl    %cl,%ebx
  800c93:	89 f0                	mov    %esi,%eax
  800c95:	88 d1                	mov    %dl,%cl
  800c97:	d3 e8                	shr    %cl,%eax
  800c99:	09 d8                	or     %ebx,%eax
  800c9b:	89 e9                	mov    %ebp,%ecx
  800c9d:	d3 e6                	shl    %cl,%esi
  800c9f:	89 f3                	mov    %esi,%ebx
  800ca1:	89 fa                	mov    %edi,%edx
  800ca3:	f7 74 24 08          	divl   0x8(%esp)
  800ca7:	89 d1                	mov    %edx,%ecx
  800ca9:	f7 64 24 0c          	mull   0xc(%esp)
  800cad:	89 c6                	mov    %eax,%esi
  800caf:	89 d7                	mov    %edx,%edi
  800cb1:	39 d1                	cmp    %edx,%ecx
  800cb3:	72 27                	jb     800cdc <__umoddi3+0x118>
  800cb5:	74 21                	je     800cd8 <__umoddi3+0x114>
  800cb7:	89 ca                	mov    %ecx,%edx
  800cb9:	29 f3                	sub    %esi,%ebx
  800cbb:	19 fa                	sbb    %edi,%edx
  800cbd:	89 d0                	mov    %edx,%eax
  800cbf:	8a 4c 24 04          	mov    0x4(%esp),%cl
  800cc3:	d3 e0                	shl    %cl,%eax
  800cc5:	89 e9                	mov    %ebp,%ecx
  800cc7:	d3 eb                	shr    %cl,%ebx
  800cc9:	09 d8                	or     %ebx,%eax
  800ccb:	d3 ea                	shr    %cl,%edx
  800ccd:	83 c4 1c             	add    $0x1c,%esp
  800cd0:	5b                   	pop    %ebx
  800cd1:	5e                   	pop    %esi
  800cd2:	5f                   	pop    %edi
  800cd3:	5d                   	pop    %ebp
  800cd4:	c3                   	ret    
  800cd5:	8d 76 00             	lea    0x0(%esi),%esi
  800cd8:	39 c3                	cmp    %eax,%ebx
  800cda:	73 db                	jae    800cb7 <__umoddi3+0xf3>
  800cdc:	2b 44 24 0c          	sub    0xc(%esp),%eax
  800ce0:	1b 54 24 08          	sbb    0x8(%esp),%edx
  800ce4:	89 d7                	mov    %edx,%edi
  800ce6:	89 c6                	mov    %eax,%esi
  800ce8:	eb cd                	jmp    800cb7 <__umoddi3+0xf3>
