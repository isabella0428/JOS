
obj/user/buggyhello:     file format elf32-i386


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
  80002c:	e8 16 00 00 00       	call   800047 <libmain>
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
	sys_cputs((char*)1, 1);
  800039:	6a 01                	push   $0x1
  80003b:	6a 01                	push   $0x1
  80003d:	e8 4d 00 00 00       	call   80008f <sys_cputs>
}
  800042:	83 c4 10             	add    $0x10,%esp
  800045:	c9                   	leave  
  800046:	c3                   	ret    

00800047 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800047:	55                   	push   %ebp
  800048:	89 e5                	mov    %esp,%ebp
  80004a:	83 ec 08             	sub    $0x8,%esp
  80004d:	8b 45 08             	mov    0x8(%ebp),%eax
  800050:	8b 55 0c             	mov    0xc(%ebp),%edx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  800053:	c7 05 04 10 80 00 00 	movl   $0x0,0x801004
  80005a:	00 00 00 

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80005d:	85 c0                	test   %eax,%eax
  80005f:	7e 08                	jle    800069 <libmain+0x22>
		binaryname = argv[0];
  800061:	8b 0a                	mov    (%edx),%ecx
  800063:	89 0d 00 10 80 00    	mov    %ecx,0x801000

	// call user main routine
	umain(argc, argv);
  800069:	83 ec 08             	sub    $0x8,%esp
  80006c:	52                   	push   %edx
  80006d:	50                   	push   %eax
  80006e:	e8 c0 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800073:	e8 05 00 00 00       	call   80007d <exit>
}
  800078:	83 c4 10             	add    $0x10,%esp
  80007b:	c9                   	leave  
  80007c:	c3                   	ret    

0080007d <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80007d:	55                   	push   %ebp
  80007e:	89 e5                	mov    %esp,%ebp
  800080:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800083:	6a 00                	push   $0x0
  800085:	e8 42 00 00 00       	call   8000cc <sys_env_destroy>
}
  80008a:	83 c4 10             	add    $0x10,%esp
  80008d:	c9                   	leave  
  80008e:	c3                   	ret    

0080008f <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  80008f:	55                   	push   %ebp
  800090:	89 e5                	mov    %esp,%ebp
  800092:	57                   	push   %edi
  800093:	56                   	push   %esi
  800094:	53                   	push   %ebx
	asm volatile("int %1\n"
  800095:	b8 00 00 00 00       	mov    $0x0,%eax
  80009a:	8b 55 08             	mov    0x8(%ebp),%edx
  80009d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000a0:	89 c3                	mov    %eax,%ebx
  8000a2:	89 c7                	mov    %eax,%edi
  8000a4:	89 c6                	mov    %eax,%esi
  8000a6:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000a8:	5b                   	pop    %ebx
  8000a9:	5e                   	pop    %esi
  8000aa:	5f                   	pop    %edi
  8000ab:	5d                   	pop    %ebp
  8000ac:	c3                   	ret    

008000ad <sys_cgetc>:

int
sys_cgetc(void)
{
  8000ad:	55                   	push   %ebp
  8000ae:	89 e5                	mov    %esp,%ebp
  8000b0:	57                   	push   %edi
  8000b1:	56                   	push   %esi
  8000b2:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000b3:	ba 00 00 00 00       	mov    $0x0,%edx
  8000b8:	b8 01 00 00 00       	mov    $0x1,%eax
  8000bd:	89 d1                	mov    %edx,%ecx
  8000bf:	89 d3                	mov    %edx,%ebx
  8000c1:	89 d7                	mov    %edx,%edi
  8000c3:	89 d6                	mov    %edx,%esi
  8000c5:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000c7:	5b                   	pop    %ebx
  8000c8:	5e                   	pop    %esi
  8000c9:	5f                   	pop    %edi
  8000ca:	5d                   	pop    %ebp
  8000cb:	c3                   	ret    

008000cc <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000cc:	55                   	push   %ebp
  8000cd:	89 e5                	mov    %esp,%ebp
  8000cf:	57                   	push   %edi
  8000d0:	56                   	push   %esi
  8000d1:	53                   	push   %ebx
  8000d2:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8000d5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000da:	8b 55 08             	mov    0x8(%ebp),%edx
  8000dd:	b8 03 00 00 00       	mov    $0x3,%eax
  8000e2:	89 cb                	mov    %ecx,%ebx
  8000e4:	89 cf                	mov    %ecx,%edi
  8000e6:	89 ce                	mov    %ecx,%esi
  8000e8:	cd 30                	int    $0x30
	if(check && ret > 0)
  8000ea:	85 c0                	test   %eax,%eax
  8000ec:	7f 08                	jg     8000f6 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  8000ee:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000f1:	5b                   	pop    %ebx
  8000f2:	5e                   	pop    %esi
  8000f3:	5f                   	pop    %edi
  8000f4:	5d                   	pop    %ebp
  8000f5:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8000f6:	83 ec 0c             	sub    $0xc,%esp
  8000f9:	50                   	push   %eax
  8000fa:	6a 03                	push   $0x3
  8000fc:	68 f2 0c 80 00       	push   $0x800cf2
  800101:	6a 23                	push   $0x23
  800103:	68 0f 0d 80 00       	push   $0x800d0f
  800108:	e8 1f 00 00 00       	call   80012c <_panic>

0080010d <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80010d:	55                   	push   %ebp
  80010e:	89 e5                	mov    %esp,%ebp
  800110:	57                   	push   %edi
  800111:	56                   	push   %esi
  800112:	53                   	push   %ebx
	asm volatile("int %1\n"
  800113:	ba 00 00 00 00       	mov    $0x0,%edx
  800118:	b8 02 00 00 00       	mov    $0x2,%eax
  80011d:	89 d1                	mov    %edx,%ecx
  80011f:	89 d3                	mov    %edx,%ebx
  800121:	89 d7                	mov    %edx,%edi
  800123:	89 d6                	mov    %edx,%esi
  800125:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800127:	5b                   	pop    %ebx
  800128:	5e                   	pop    %esi
  800129:	5f                   	pop    %edi
  80012a:	5d                   	pop    %ebp
  80012b:	c3                   	ret    

0080012c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80012c:	55                   	push   %ebp
  80012d:	89 e5                	mov    %esp,%ebp
  80012f:	56                   	push   %esi
  800130:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800131:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800134:	8b 35 00 10 80 00    	mov    0x801000,%esi
  80013a:	e8 ce ff ff ff       	call   80010d <sys_getenvid>
  80013f:	83 ec 0c             	sub    $0xc,%esp
  800142:	ff 75 0c             	pushl  0xc(%ebp)
  800145:	ff 75 08             	pushl  0x8(%ebp)
  800148:	56                   	push   %esi
  800149:	50                   	push   %eax
  80014a:	68 20 0d 80 00       	push   $0x800d20
  80014f:	e8 b2 00 00 00       	call   800206 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800154:	83 c4 18             	add    $0x18,%esp
  800157:	53                   	push   %ebx
  800158:	ff 75 10             	pushl  0x10(%ebp)
  80015b:	e8 55 00 00 00       	call   8001b5 <vcprintf>
	cprintf("\n");
  800160:	c7 04 24 44 0d 80 00 	movl   $0x800d44,(%esp)
  800167:	e8 9a 00 00 00       	call   800206 <cprintf>
  80016c:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80016f:	cc                   	int3   
  800170:	eb fd                	jmp    80016f <_panic+0x43>

00800172 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800172:	55                   	push   %ebp
  800173:	89 e5                	mov    %esp,%ebp
  800175:	53                   	push   %ebx
  800176:	83 ec 04             	sub    $0x4,%esp
  800179:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80017c:	8b 13                	mov    (%ebx),%edx
  80017e:	8d 42 01             	lea    0x1(%edx),%eax
  800181:	89 03                	mov    %eax,(%ebx)
  800183:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800186:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80018a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80018f:	74 08                	je     800199 <putch+0x27>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800191:	ff 43 04             	incl   0x4(%ebx)
}
  800194:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800197:	c9                   	leave  
  800198:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800199:	83 ec 08             	sub    $0x8,%esp
  80019c:	68 ff 00 00 00       	push   $0xff
  8001a1:	8d 43 08             	lea    0x8(%ebx),%eax
  8001a4:	50                   	push   %eax
  8001a5:	e8 e5 fe ff ff       	call   80008f <sys_cputs>
		b->idx = 0;
  8001aa:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001b0:	83 c4 10             	add    $0x10,%esp
  8001b3:	eb dc                	jmp    800191 <putch+0x1f>

008001b5 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001b5:	55                   	push   %ebp
  8001b6:	89 e5                	mov    %esp,%ebp
  8001b8:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001be:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001c5:	00 00 00 
	b.cnt = 0;
  8001c8:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001cf:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001d2:	ff 75 0c             	pushl  0xc(%ebp)
  8001d5:	ff 75 08             	pushl  0x8(%ebp)
  8001d8:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001de:	50                   	push   %eax
  8001df:	68 72 01 80 00       	push   $0x800172
  8001e4:	e8 0f 01 00 00       	call   8002f8 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001e9:	83 c4 08             	add    $0x8,%esp
  8001ec:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001f2:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001f8:	50                   	push   %eax
  8001f9:	e8 91 fe ff ff       	call   80008f <sys_cputs>

	return b.cnt;
}
  8001fe:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800204:	c9                   	leave  
  800205:	c3                   	ret    

00800206 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800206:	55                   	push   %ebp
  800207:	89 e5                	mov    %esp,%ebp
  800209:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80020c:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80020f:	50                   	push   %eax
  800210:	ff 75 08             	pushl  0x8(%ebp)
  800213:	e8 9d ff ff ff       	call   8001b5 <vcprintf>
	va_end(ap);

	return cnt;
}
  800218:	c9                   	leave  
  800219:	c3                   	ret    

0080021a <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80021a:	55                   	push   %ebp
  80021b:	89 e5                	mov    %esp,%ebp
  80021d:	57                   	push   %edi
  80021e:	56                   	push   %esi
  80021f:	53                   	push   %ebx
  800220:	83 ec 1c             	sub    $0x1c,%esp
  800223:	89 c7                	mov    %eax,%edi
  800225:	89 d6                	mov    %edx,%esi
  800227:	8b 45 08             	mov    0x8(%ebp),%eax
  80022a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80022d:	89 d1                	mov    %edx,%ecx
  80022f:	89 c2                	mov    %eax,%edx
  800231:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800234:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800237:	8b 45 10             	mov    0x10(%ebp),%eax
  80023a:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80023d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800240:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800247:	39 c2                	cmp    %eax,%edx
  800249:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  80024c:	72 3c                	jb     80028a <printnum+0x70>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80024e:	83 ec 0c             	sub    $0xc,%esp
  800251:	ff 75 18             	pushl  0x18(%ebp)
  800254:	4b                   	dec    %ebx
  800255:	53                   	push   %ebx
  800256:	50                   	push   %eax
  800257:	83 ec 08             	sub    $0x8,%esp
  80025a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80025d:	ff 75 e0             	pushl  -0x20(%ebp)
  800260:	ff 75 dc             	pushl  -0x24(%ebp)
  800263:	ff 75 d8             	pushl  -0x28(%ebp)
  800266:	e8 55 08 00 00       	call   800ac0 <__udivdi3>
  80026b:	83 c4 18             	add    $0x18,%esp
  80026e:	52                   	push   %edx
  80026f:	50                   	push   %eax
  800270:	89 f2                	mov    %esi,%edx
  800272:	89 f8                	mov    %edi,%eax
  800274:	e8 a1 ff ff ff       	call   80021a <printnum>
  800279:	83 c4 20             	add    $0x20,%esp
  80027c:	eb 11                	jmp    80028f <printnum+0x75>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80027e:	83 ec 08             	sub    $0x8,%esp
  800281:	56                   	push   %esi
  800282:	ff 75 18             	pushl  0x18(%ebp)
  800285:	ff d7                	call   *%edi
  800287:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  80028a:	4b                   	dec    %ebx
  80028b:	85 db                	test   %ebx,%ebx
  80028d:	7f ef                	jg     80027e <printnum+0x64>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80028f:	83 ec 08             	sub    $0x8,%esp
  800292:	56                   	push   %esi
  800293:	83 ec 04             	sub    $0x4,%esp
  800296:	ff 75 e4             	pushl  -0x1c(%ebp)
  800299:	ff 75 e0             	pushl  -0x20(%ebp)
  80029c:	ff 75 dc             	pushl  -0x24(%ebp)
  80029f:	ff 75 d8             	pushl  -0x28(%ebp)
  8002a2:	e8 19 09 00 00       	call   800bc0 <__umoddi3>
  8002a7:	83 c4 14             	add    $0x14,%esp
  8002aa:	0f be 80 46 0d 80 00 	movsbl 0x800d46(%eax),%eax
  8002b1:	50                   	push   %eax
  8002b2:	ff d7                	call   *%edi
}
  8002b4:	83 c4 10             	add    $0x10,%esp
  8002b7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002ba:	5b                   	pop    %ebx
  8002bb:	5e                   	pop    %esi
  8002bc:	5f                   	pop    %edi
  8002bd:	5d                   	pop    %ebp
  8002be:	c3                   	ret    

008002bf <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002bf:	55                   	push   %ebp
  8002c0:	89 e5                	mov    %esp,%ebp
  8002c2:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002c5:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8002c8:	8b 10                	mov    (%eax),%edx
  8002ca:	3b 50 04             	cmp    0x4(%eax),%edx
  8002cd:	73 0a                	jae    8002d9 <sprintputch+0x1a>
		*b->buf++ = ch;
  8002cf:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002d2:	89 08                	mov    %ecx,(%eax)
  8002d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8002d7:	88 02                	mov    %al,(%edx)
}
  8002d9:	5d                   	pop    %ebp
  8002da:	c3                   	ret    

008002db <printfmt>:
{
  8002db:	55                   	push   %ebp
  8002dc:	89 e5                	mov    %esp,%ebp
  8002de:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8002e1:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002e4:	50                   	push   %eax
  8002e5:	ff 75 10             	pushl  0x10(%ebp)
  8002e8:	ff 75 0c             	pushl  0xc(%ebp)
  8002eb:	ff 75 08             	pushl  0x8(%ebp)
  8002ee:	e8 05 00 00 00       	call   8002f8 <vprintfmt>
}
  8002f3:	83 c4 10             	add    $0x10,%esp
  8002f6:	c9                   	leave  
  8002f7:	c3                   	ret    

008002f8 <vprintfmt>:
{
  8002f8:	55                   	push   %ebp
  8002f9:	89 e5                	mov    %esp,%ebp
  8002fb:	57                   	push   %edi
  8002fc:	56                   	push   %esi
  8002fd:	53                   	push   %ebx
  8002fe:	83 ec 3c             	sub    $0x3c,%esp
  800301:	8b 75 08             	mov    0x8(%ebp),%esi
  800304:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800307:	8b 7d 10             	mov    0x10(%ebp),%edi
  80030a:	e9 5b 03 00 00       	jmp    80066a <vprintfmt+0x372>
		padc = ' ';
  80030f:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  800313:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
		precision = -1;
  80031a:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  800321:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		lflag = 0;
  800328:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80032d:	8d 47 01             	lea    0x1(%edi),%eax
  800330:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800333:	8a 17                	mov    (%edi),%dl
  800335:	8d 42 dd             	lea    -0x23(%edx),%eax
  800338:	3c 55                	cmp    $0x55,%al
  80033a:	0f 87 ab 03 00 00    	ja     8006eb <vprintfmt+0x3f3>
  800340:	0f b6 c0             	movzbl %al,%eax
  800343:	ff 24 85 d4 0d 80 00 	jmp    *0x800dd4(,%eax,4)
  80034a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  80034d:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  800351:	eb da                	jmp    80032d <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  800353:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800356:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  80035a:	eb d1                	jmp    80032d <vprintfmt+0x35>
  80035c:	0f b6 d2             	movzbl %dl,%edx
  80035f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800362:	b8 00 00 00 00       	mov    $0x0,%eax
  800367:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  80036a:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80036d:	01 c0                	add    %eax,%eax
  80036f:	8d 44 02 d0          	lea    -0x30(%edx,%eax,1),%eax
				ch = *fmt;
  800373:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800376:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800379:	83 f9 09             	cmp    $0x9,%ecx
  80037c:	77 52                	ja     8003d0 <vprintfmt+0xd8>
			for (precision = 0; ; ++fmt) {
  80037e:	47                   	inc    %edi
				precision = precision * 10 + ch - '0';
  80037f:	eb e9                	jmp    80036a <vprintfmt+0x72>
			precision = va_arg(ap, int);
  800381:	8b 45 14             	mov    0x14(%ebp),%eax
  800384:	8b 00                	mov    (%eax),%eax
  800386:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800389:	8b 45 14             	mov    0x14(%ebp),%eax
  80038c:	8d 40 04             	lea    0x4(%eax),%eax
  80038f:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800392:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800395:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800399:	79 92                	jns    80032d <vprintfmt+0x35>
				width = precision, precision = -1;
  80039b:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80039e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8003a1:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8003a8:	eb 83                	jmp    80032d <vprintfmt+0x35>
  8003aa:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8003ae:	78 08                	js     8003b8 <vprintfmt+0xc0>
		switch (ch = *(unsigned char *) fmt++) {
  8003b0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8003b3:	e9 75 ff ff ff       	jmp    80032d <vprintfmt+0x35>
  8003b8:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  8003bf:	eb ef                	jmp    8003b0 <vprintfmt+0xb8>
		switch (ch = *(unsigned char *) fmt++) {
  8003c1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8003c4:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  8003cb:	e9 5d ff ff ff       	jmp    80032d <vprintfmt+0x35>
  8003d0:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8003d3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003d6:	eb bd                	jmp    800395 <vprintfmt+0x9d>
			lflag++;
  8003d8:	41                   	inc    %ecx
		switch (ch = *(unsigned char *) fmt++) {
  8003d9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8003dc:	e9 4c ff ff ff       	jmp    80032d <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
  8003e1:	8b 45 14             	mov    0x14(%ebp),%eax
  8003e4:	8d 78 04             	lea    0x4(%eax),%edi
  8003e7:	83 ec 08             	sub    $0x8,%esp
  8003ea:	53                   	push   %ebx
  8003eb:	ff 30                	pushl  (%eax)
  8003ed:	ff d6                	call   *%esi
			break;
  8003ef:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8003f2:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8003f5:	e9 6d 02 00 00       	jmp    800667 <vprintfmt+0x36f>
			err = va_arg(ap, int);
  8003fa:	8b 45 14             	mov    0x14(%ebp),%eax
  8003fd:	8d 78 04             	lea    0x4(%eax),%edi
  800400:	8b 00                	mov    (%eax),%eax
  800402:	85 c0                	test   %eax,%eax
  800404:	78 2a                	js     800430 <vprintfmt+0x138>
  800406:	89 c2                	mov    %eax,%edx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800408:	83 f8 06             	cmp    $0x6,%eax
  80040b:	7f 27                	jg     800434 <vprintfmt+0x13c>
  80040d:	8b 04 85 2c 0f 80 00 	mov    0x800f2c(,%eax,4),%eax
  800414:	85 c0                	test   %eax,%eax
  800416:	74 1c                	je     800434 <vprintfmt+0x13c>
				printfmt(putch, putdat, "%s", p);
  800418:	50                   	push   %eax
  800419:	68 67 0d 80 00       	push   $0x800d67
  80041e:	53                   	push   %ebx
  80041f:	56                   	push   %esi
  800420:	e8 b6 fe ff ff       	call   8002db <printfmt>
  800425:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800428:	89 7d 14             	mov    %edi,0x14(%ebp)
  80042b:	e9 37 02 00 00       	jmp    800667 <vprintfmt+0x36f>
  800430:	f7 d8                	neg    %eax
  800432:	eb d2                	jmp    800406 <vprintfmt+0x10e>
				printfmt(putch, putdat, "error %d", err);
  800434:	52                   	push   %edx
  800435:	68 5e 0d 80 00       	push   $0x800d5e
  80043a:	53                   	push   %ebx
  80043b:	56                   	push   %esi
  80043c:	e8 9a fe ff ff       	call   8002db <printfmt>
  800441:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800444:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800447:	e9 1b 02 00 00       	jmp    800667 <vprintfmt+0x36f>
			if ((p = va_arg(ap, char *)) == NULL)
  80044c:	8b 45 14             	mov    0x14(%ebp),%eax
  80044f:	83 c0 04             	add    $0x4,%eax
  800452:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800455:	8b 45 14             	mov    0x14(%ebp),%eax
  800458:	8b 00                	mov    (%eax),%eax
  80045a:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80045d:	85 c0                	test   %eax,%eax
  80045f:	74 19                	je     80047a <vprintfmt+0x182>
			if (width > 0 && padc != '-')
  800461:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800465:	7e 06                	jle    80046d <vprintfmt+0x175>
  800467:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  80046b:	75 16                	jne    800483 <vprintfmt+0x18b>
				for (width -= strnlen(p, precision); width > 0; width--)
  80046d:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800470:	89 c7                	mov    %eax,%edi
  800472:	03 45 d4             	add    -0x2c(%ebp),%eax
  800475:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800478:	eb 62                	jmp    8004dc <vprintfmt+0x1e4>
				p = "(null)";
  80047a:	c7 45 cc 57 0d 80 00 	movl   $0x800d57,-0x34(%ebp)
  800481:	eb de                	jmp    800461 <vprintfmt+0x169>
				for (width -= strnlen(p, precision); width > 0; width--)
  800483:	83 ec 08             	sub    $0x8,%esp
  800486:	ff 75 d8             	pushl  -0x28(%ebp)
  800489:	ff 75 cc             	pushl  -0x34(%ebp)
  80048c:	e8 05 03 00 00       	call   800796 <strnlen>
  800491:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800494:	29 c2                	sub    %eax,%edx
  800496:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  800499:	83 c4 10             	add    $0x10,%esp
  80049c:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  80049e:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8004a2:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8004a5:	eb 0d                	jmp    8004b4 <vprintfmt+0x1bc>
					putch(padc, putdat);
  8004a7:	83 ec 08             	sub    $0x8,%esp
  8004aa:	53                   	push   %ebx
  8004ab:	ff 75 d4             	pushl  -0x2c(%ebp)
  8004ae:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8004b0:	4f                   	dec    %edi
  8004b1:	83 c4 10             	add    $0x10,%esp
  8004b4:	85 ff                	test   %edi,%edi
  8004b6:	7f ef                	jg     8004a7 <vprintfmt+0x1af>
  8004b8:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8004bb:	89 d0                	mov    %edx,%eax
  8004bd:	85 d2                	test   %edx,%edx
  8004bf:	78 0a                	js     8004cb <vprintfmt+0x1d3>
  8004c1:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8004c4:	29 c2                	sub    %eax,%edx
  8004c6:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8004c9:	eb a2                	jmp    80046d <vprintfmt+0x175>
  8004cb:	b8 00 00 00 00       	mov    $0x0,%eax
  8004d0:	eb ef                	jmp    8004c1 <vprintfmt+0x1c9>
					putch(ch, putdat);
  8004d2:	83 ec 08             	sub    $0x8,%esp
  8004d5:	53                   	push   %ebx
  8004d6:	52                   	push   %edx
  8004d7:	ff d6                	call   *%esi
  8004d9:	83 c4 10             	add    $0x10,%esp
  8004dc:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  8004df:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004e1:	47                   	inc    %edi
  8004e2:	8a 47 ff             	mov    -0x1(%edi),%al
  8004e5:	0f be d0             	movsbl %al,%edx
  8004e8:	85 d2                	test   %edx,%edx
  8004ea:	74 48                	je     800534 <vprintfmt+0x23c>
  8004ec:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004f0:	78 05                	js     8004f7 <vprintfmt+0x1ff>
  8004f2:	ff 4d d8             	decl   -0x28(%ebp)
  8004f5:	78 1e                	js     800515 <vprintfmt+0x21d>
				if (altflag && (ch < ' ' || ch > '~'))
  8004f7:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004fb:	74 d5                	je     8004d2 <vprintfmt+0x1da>
  8004fd:	0f be c0             	movsbl %al,%eax
  800500:	83 e8 20             	sub    $0x20,%eax
  800503:	83 f8 5e             	cmp    $0x5e,%eax
  800506:	76 ca                	jbe    8004d2 <vprintfmt+0x1da>
					putch('?', putdat);
  800508:	83 ec 08             	sub    $0x8,%esp
  80050b:	53                   	push   %ebx
  80050c:	6a 3f                	push   $0x3f
  80050e:	ff d6                	call   *%esi
  800510:	83 c4 10             	add    $0x10,%esp
  800513:	eb c7                	jmp    8004dc <vprintfmt+0x1e4>
  800515:	89 cf                	mov    %ecx,%edi
  800517:	eb 0c                	jmp    800525 <vprintfmt+0x22d>
				putch(' ', putdat);
  800519:	83 ec 08             	sub    $0x8,%esp
  80051c:	53                   	push   %ebx
  80051d:	6a 20                	push   $0x20
  80051f:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800521:	4f                   	dec    %edi
  800522:	83 c4 10             	add    $0x10,%esp
  800525:	85 ff                	test   %edi,%edi
  800527:	7f f0                	jg     800519 <vprintfmt+0x221>
			if ((p = va_arg(ap, char *)) == NULL)
  800529:	8b 45 c8             	mov    -0x38(%ebp),%eax
  80052c:	89 45 14             	mov    %eax,0x14(%ebp)
  80052f:	e9 33 01 00 00       	jmp    800667 <vprintfmt+0x36f>
  800534:	89 cf                	mov    %ecx,%edi
  800536:	eb ed                	jmp    800525 <vprintfmt+0x22d>
	if (lflag >= 2)
  800538:	83 f9 01             	cmp    $0x1,%ecx
  80053b:	7f 1b                	jg     800558 <vprintfmt+0x260>
	else if (lflag)
  80053d:	85 c9                	test   %ecx,%ecx
  80053f:	74 42                	je     800583 <vprintfmt+0x28b>
		return va_arg(*ap, long);
  800541:	8b 45 14             	mov    0x14(%ebp),%eax
  800544:	8b 00                	mov    (%eax),%eax
  800546:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800549:	99                   	cltd   
  80054a:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80054d:	8b 45 14             	mov    0x14(%ebp),%eax
  800550:	8d 40 04             	lea    0x4(%eax),%eax
  800553:	89 45 14             	mov    %eax,0x14(%ebp)
  800556:	eb 17                	jmp    80056f <vprintfmt+0x277>
		return va_arg(*ap, long long);
  800558:	8b 45 14             	mov    0x14(%ebp),%eax
  80055b:	8b 50 04             	mov    0x4(%eax),%edx
  80055e:	8b 00                	mov    (%eax),%eax
  800560:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800563:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800566:	8b 45 14             	mov    0x14(%ebp),%eax
  800569:	8d 40 08             	lea    0x8(%eax),%eax
  80056c:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  80056f:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800572:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800575:	85 c9                	test   %ecx,%ecx
  800577:	78 21                	js     80059a <vprintfmt+0x2a2>
			base = 10;
  800579:	b8 0a 00 00 00       	mov    $0xa,%eax
  80057e:	e9 ca 00 00 00       	jmp    80064d <vprintfmt+0x355>
		return va_arg(*ap, int);
  800583:	8b 45 14             	mov    0x14(%ebp),%eax
  800586:	8b 00                	mov    (%eax),%eax
  800588:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80058b:	99                   	cltd   
  80058c:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80058f:	8b 45 14             	mov    0x14(%ebp),%eax
  800592:	8d 40 04             	lea    0x4(%eax),%eax
  800595:	89 45 14             	mov    %eax,0x14(%ebp)
  800598:	eb d5                	jmp    80056f <vprintfmt+0x277>
				putch('-', putdat);
  80059a:	83 ec 08             	sub    $0x8,%esp
  80059d:	53                   	push   %ebx
  80059e:	6a 2d                	push   $0x2d
  8005a0:	ff d6                	call   *%esi
				num = -(long long) num;
  8005a2:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005a5:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8005a8:	f7 da                	neg    %edx
  8005aa:	83 d1 00             	adc    $0x0,%ecx
  8005ad:	f7 d9                	neg    %ecx
  8005af:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8005b2:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005b7:	e9 91 00 00 00       	jmp    80064d <vprintfmt+0x355>
	if (lflag >= 2)
  8005bc:	83 f9 01             	cmp    $0x1,%ecx
  8005bf:	7f 1b                	jg     8005dc <vprintfmt+0x2e4>
	else if (lflag)
  8005c1:	85 c9                	test   %ecx,%ecx
  8005c3:	74 2c                	je     8005f1 <vprintfmt+0x2f9>
		return va_arg(*ap, unsigned long);
  8005c5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c8:	8b 10                	mov    (%eax),%edx
  8005ca:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005cf:	8d 40 04             	lea    0x4(%eax),%eax
  8005d2:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005d5:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  8005da:	eb 71                	jmp    80064d <vprintfmt+0x355>
		return va_arg(*ap, unsigned long long);
  8005dc:	8b 45 14             	mov    0x14(%ebp),%eax
  8005df:	8b 10                	mov    (%eax),%edx
  8005e1:	8b 48 04             	mov    0x4(%eax),%ecx
  8005e4:	8d 40 08             	lea    0x8(%eax),%eax
  8005e7:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005ea:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  8005ef:	eb 5c                	jmp    80064d <vprintfmt+0x355>
		return va_arg(*ap, unsigned int);
  8005f1:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f4:	8b 10                	mov    (%eax),%edx
  8005f6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005fb:	8d 40 04             	lea    0x4(%eax),%eax
  8005fe:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800601:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  800606:	eb 45                	jmp    80064d <vprintfmt+0x355>
			putch('X', putdat);
  800608:	83 ec 08             	sub    $0x8,%esp
  80060b:	53                   	push   %ebx
  80060c:	6a 58                	push   $0x58
  80060e:	ff d6                	call   *%esi
			putch('X', putdat);
  800610:	83 c4 08             	add    $0x8,%esp
  800613:	53                   	push   %ebx
  800614:	6a 58                	push   $0x58
  800616:	ff d6                	call   *%esi
			putch('X', putdat);
  800618:	83 c4 08             	add    $0x8,%esp
  80061b:	53                   	push   %ebx
  80061c:	6a 58                	push   $0x58
  80061e:	ff d6                	call   *%esi
			break;
  800620:	83 c4 10             	add    $0x10,%esp
  800623:	eb 42                	jmp    800667 <vprintfmt+0x36f>
			putch('0', putdat);
  800625:	83 ec 08             	sub    $0x8,%esp
  800628:	53                   	push   %ebx
  800629:	6a 30                	push   $0x30
  80062b:	ff d6                	call   *%esi
			putch('x', putdat);
  80062d:	83 c4 08             	add    $0x8,%esp
  800630:	53                   	push   %ebx
  800631:	6a 78                	push   $0x78
  800633:	ff d6                	call   *%esi
			num = (unsigned long long)
  800635:	8b 45 14             	mov    0x14(%ebp),%eax
  800638:	8b 10                	mov    (%eax),%edx
  80063a:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  80063f:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800642:	8d 40 04             	lea    0x4(%eax),%eax
  800645:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800648:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  80064d:	83 ec 0c             	sub    $0xc,%esp
  800650:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  800654:	57                   	push   %edi
  800655:	ff 75 d4             	pushl  -0x2c(%ebp)
  800658:	50                   	push   %eax
  800659:	51                   	push   %ecx
  80065a:	52                   	push   %edx
  80065b:	89 da                	mov    %ebx,%edx
  80065d:	89 f0                	mov    %esi,%eax
  80065f:	e8 b6 fb ff ff       	call   80021a <printnum>
			break;
  800664:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  800667:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80066a:	47                   	inc    %edi
  80066b:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80066f:	83 f8 25             	cmp    $0x25,%eax
  800672:	0f 84 97 fc ff ff    	je     80030f <vprintfmt+0x17>
			if (ch == '\0')
  800678:	85 c0                	test   %eax,%eax
  80067a:	0f 84 89 00 00 00    	je     800709 <vprintfmt+0x411>
			putch(ch, putdat);
  800680:	83 ec 08             	sub    $0x8,%esp
  800683:	53                   	push   %ebx
  800684:	50                   	push   %eax
  800685:	ff d6                	call   *%esi
  800687:	83 c4 10             	add    $0x10,%esp
  80068a:	eb de                	jmp    80066a <vprintfmt+0x372>
	if (lflag >= 2)
  80068c:	83 f9 01             	cmp    $0x1,%ecx
  80068f:	7f 1b                	jg     8006ac <vprintfmt+0x3b4>
	else if (lflag)
  800691:	85 c9                	test   %ecx,%ecx
  800693:	74 2c                	je     8006c1 <vprintfmt+0x3c9>
		return va_arg(*ap, unsigned long);
  800695:	8b 45 14             	mov    0x14(%ebp),%eax
  800698:	8b 10                	mov    (%eax),%edx
  80069a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80069f:	8d 40 04             	lea    0x4(%eax),%eax
  8006a2:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006a5:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  8006aa:	eb a1                	jmp    80064d <vprintfmt+0x355>
		return va_arg(*ap, unsigned long long);
  8006ac:	8b 45 14             	mov    0x14(%ebp),%eax
  8006af:	8b 10                	mov    (%eax),%edx
  8006b1:	8b 48 04             	mov    0x4(%eax),%ecx
  8006b4:	8d 40 08             	lea    0x8(%eax),%eax
  8006b7:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006ba:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  8006bf:	eb 8c                	jmp    80064d <vprintfmt+0x355>
		return va_arg(*ap, unsigned int);
  8006c1:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c4:	8b 10                	mov    (%eax),%edx
  8006c6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006cb:	8d 40 04             	lea    0x4(%eax),%eax
  8006ce:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006d1:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  8006d6:	e9 72 ff ff ff       	jmp    80064d <vprintfmt+0x355>
			putch(ch, putdat);
  8006db:	83 ec 08             	sub    $0x8,%esp
  8006de:	53                   	push   %ebx
  8006df:	6a 25                	push   $0x25
  8006e1:	ff d6                	call   *%esi
			break;
  8006e3:	83 c4 10             	add    $0x10,%esp
  8006e6:	e9 7c ff ff ff       	jmp    800667 <vprintfmt+0x36f>
			putch('%', putdat);
  8006eb:	83 ec 08             	sub    $0x8,%esp
  8006ee:	53                   	push   %ebx
  8006ef:	6a 25                	push   $0x25
  8006f1:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006f3:	83 c4 10             	add    $0x10,%esp
  8006f6:	89 f8                	mov    %edi,%eax
  8006f8:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8006fc:	74 03                	je     800701 <vprintfmt+0x409>
  8006fe:	48                   	dec    %eax
  8006ff:	eb f7                	jmp    8006f8 <vprintfmt+0x400>
  800701:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800704:	e9 5e ff ff ff       	jmp    800667 <vprintfmt+0x36f>
}
  800709:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80070c:	5b                   	pop    %ebx
  80070d:	5e                   	pop    %esi
  80070e:	5f                   	pop    %edi
  80070f:	5d                   	pop    %ebp
  800710:	c3                   	ret    

00800711 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800711:	55                   	push   %ebp
  800712:	89 e5                	mov    %esp,%ebp
  800714:	83 ec 18             	sub    $0x18,%esp
  800717:	8b 45 08             	mov    0x8(%ebp),%eax
  80071a:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80071d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800720:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800724:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800727:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80072e:	85 c0                	test   %eax,%eax
  800730:	74 26                	je     800758 <vsnprintf+0x47>
  800732:	85 d2                	test   %edx,%edx
  800734:	7e 29                	jle    80075f <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800736:	ff 75 14             	pushl  0x14(%ebp)
  800739:	ff 75 10             	pushl  0x10(%ebp)
  80073c:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80073f:	50                   	push   %eax
  800740:	68 bf 02 80 00       	push   $0x8002bf
  800745:	e8 ae fb ff ff       	call   8002f8 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80074a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80074d:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800750:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800753:	83 c4 10             	add    $0x10,%esp
}
  800756:	c9                   	leave  
  800757:	c3                   	ret    
		return -E_INVAL;
  800758:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80075d:	eb f7                	jmp    800756 <vsnprintf+0x45>
  80075f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800764:	eb f0                	jmp    800756 <vsnprintf+0x45>

00800766 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800766:	55                   	push   %ebp
  800767:	89 e5                	mov    %esp,%ebp
  800769:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80076c:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80076f:	50                   	push   %eax
  800770:	ff 75 10             	pushl  0x10(%ebp)
  800773:	ff 75 0c             	pushl  0xc(%ebp)
  800776:	ff 75 08             	pushl  0x8(%ebp)
  800779:	e8 93 ff ff ff       	call   800711 <vsnprintf>
	va_end(ap);

	return rc;
}
  80077e:	c9                   	leave  
  80077f:	c3                   	ret    

00800780 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800780:	55                   	push   %ebp
  800781:	89 e5                	mov    %esp,%ebp
  800783:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800786:	b8 00 00 00 00       	mov    $0x0,%eax
  80078b:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80078f:	74 03                	je     800794 <strlen+0x14>
		n++;
  800791:	40                   	inc    %eax
  800792:	eb f7                	jmp    80078b <strlen+0xb>
	return n;
}
  800794:	5d                   	pop    %ebp
  800795:	c3                   	ret    

00800796 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800796:	55                   	push   %ebp
  800797:	89 e5                	mov    %esp,%ebp
  800799:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80079c:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80079f:	b8 00 00 00 00       	mov    $0x0,%eax
  8007a4:	39 d0                	cmp    %edx,%eax
  8007a6:	74 0b                	je     8007b3 <strnlen+0x1d>
  8007a8:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007ac:	74 03                	je     8007b1 <strnlen+0x1b>
		n++;
  8007ae:	40                   	inc    %eax
  8007af:	eb f3                	jmp    8007a4 <strnlen+0xe>
  8007b1:	89 c2                	mov    %eax,%edx
	return n;
}
  8007b3:	89 d0                	mov    %edx,%eax
  8007b5:	5d                   	pop    %ebp
  8007b6:	c3                   	ret    

008007b7 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007b7:	55                   	push   %ebp
  8007b8:	89 e5                	mov    %esp,%ebp
  8007ba:	53                   	push   %ebx
  8007bb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007be:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007c1:	b8 00 00 00 00       	mov    $0x0,%eax
  8007c6:	8a 14 03             	mov    (%ebx,%eax,1),%dl
  8007c9:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8007cc:	40                   	inc    %eax
  8007cd:	84 d2                	test   %dl,%dl
  8007cf:	75 f5                	jne    8007c6 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8007d1:	89 c8                	mov    %ecx,%eax
  8007d3:	5b                   	pop    %ebx
  8007d4:	5d                   	pop    %ebp
  8007d5:	c3                   	ret    

008007d6 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007d6:	55                   	push   %ebp
  8007d7:	89 e5                	mov    %esp,%ebp
  8007d9:	53                   	push   %ebx
  8007da:	83 ec 10             	sub    $0x10,%esp
  8007dd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007e0:	53                   	push   %ebx
  8007e1:	e8 9a ff ff ff       	call   800780 <strlen>
  8007e6:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  8007e9:	ff 75 0c             	pushl  0xc(%ebp)
  8007ec:	01 d8                	add    %ebx,%eax
  8007ee:	50                   	push   %eax
  8007ef:	e8 c3 ff ff ff       	call   8007b7 <strcpy>
	return dst;
}
  8007f4:	89 d8                	mov    %ebx,%eax
  8007f6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007f9:	c9                   	leave  
  8007fa:	c3                   	ret    

008007fb <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007fb:	55                   	push   %ebp
  8007fc:	89 e5                	mov    %esp,%ebp
  8007fe:	53                   	push   %ebx
  8007ff:	8b 55 0c             	mov    0xc(%ebp),%edx
  800802:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800805:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800808:	8b 45 08             	mov    0x8(%ebp),%eax
  80080b:	39 d8                	cmp    %ebx,%eax
  80080d:	74 0e                	je     80081d <strncpy+0x22>
		*dst++ = *src;
  80080f:	40                   	inc    %eax
  800810:	8a 0a                	mov    (%edx),%cl
  800812:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800815:	80 f9 01             	cmp    $0x1,%cl
  800818:	83 da ff             	sbb    $0xffffffff,%edx
  80081b:	eb ee                	jmp    80080b <strncpy+0x10>
	}
	return ret;
}
  80081d:	8b 45 08             	mov    0x8(%ebp),%eax
  800820:	5b                   	pop    %ebx
  800821:	5d                   	pop    %ebp
  800822:	c3                   	ret    

00800823 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800823:	55                   	push   %ebp
  800824:	89 e5                	mov    %esp,%ebp
  800826:	56                   	push   %esi
  800827:	53                   	push   %ebx
  800828:	8b 75 08             	mov    0x8(%ebp),%esi
  80082b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80082e:	8b 45 10             	mov    0x10(%ebp),%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800831:	85 c0                	test   %eax,%eax
  800833:	74 22                	je     800857 <strlcpy+0x34>
  800835:	8d 44 06 ff          	lea    -0x1(%esi,%eax,1),%eax
  800839:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  80083b:	39 c2                	cmp    %eax,%edx
  80083d:	74 0f                	je     80084e <strlcpy+0x2b>
  80083f:	8a 19                	mov    (%ecx),%bl
  800841:	84 db                	test   %bl,%bl
  800843:	74 07                	je     80084c <strlcpy+0x29>
			*dst++ = *src++;
  800845:	41                   	inc    %ecx
  800846:	42                   	inc    %edx
  800847:	88 5a ff             	mov    %bl,-0x1(%edx)
  80084a:	eb ef                	jmp    80083b <strlcpy+0x18>
  80084c:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  80084e:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800851:	29 f0                	sub    %esi,%eax
}
  800853:	5b                   	pop    %ebx
  800854:	5e                   	pop    %esi
  800855:	5d                   	pop    %ebp
  800856:	c3                   	ret    
  800857:	89 f0                	mov    %esi,%eax
  800859:	eb f6                	jmp    800851 <strlcpy+0x2e>

0080085b <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80085b:	55                   	push   %ebp
  80085c:	89 e5                	mov    %esp,%ebp
  80085e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800861:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800864:	8a 01                	mov    (%ecx),%al
  800866:	84 c0                	test   %al,%al
  800868:	74 08                	je     800872 <strcmp+0x17>
  80086a:	3a 02                	cmp    (%edx),%al
  80086c:	75 04                	jne    800872 <strcmp+0x17>
		p++, q++;
  80086e:	41                   	inc    %ecx
  80086f:	42                   	inc    %edx
  800870:	eb f2                	jmp    800864 <strcmp+0x9>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800872:	0f b6 c0             	movzbl %al,%eax
  800875:	0f b6 12             	movzbl (%edx),%edx
  800878:	29 d0                	sub    %edx,%eax
}
  80087a:	5d                   	pop    %ebp
  80087b:	c3                   	ret    

0080087c <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80087c:	55                   	push   %ebp
  80087d:	89 e5                	mov    %esp,%ebp
  80087f:	53                   	push   %ebx
  800880:	8b 45 08             	mov    0x8(%ebp),%eax
  800883:	8b 55 0c             	mov    0xc(%ebp),%edx
  800886:	89 c3                	mov    %eax,%ebx
  800888:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80088b:	eb 02                	jmp    80088f <strncmp+0x13>
		n--, p++, q++;
  80088d:	40                   	inc    %eax
  80088e:	42                   	inc    %edx
	while (n > 0 && *p && *p == *q)
  80088f:	39 d8                	cmp    %ebx,%eax
  800891:	74 15                	je     8008a8 <strncmp+0x2c>
  800893:	8a 08                	mov    (%eax),%cl
  800895:	84 c9                	test   %cl,%cl
  800897:	74 04                	je     80089d <strncmp+0x21>
  800899:	3a 0a                	cmp    (%edx),%cl
  80089b:	74 f0                	je     80088d <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80089d:	0f b6 00             	movzbl (%eax),%eax
  8008a0:	0f b6 12             	movzbl (%edx),%edx
  8008a3:	29 d0                	sub    %edx,%eax
}
  8008a5:	5b                   	pop    %ebx
  8008a6:	5d                   	pop    %ebp
  8008a7:	c3                   	ret    
		return 0;
  8008a8:	b8 00 00 00 00       	mov    $0x0,%eax
  8008ad:	eb f6                	jmp    8008a5 <strncmp+0x29>

008008af <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008af:	55                   	push   %ebp
  8008b0:	89 e5                	mov    %esp,%ebp
  8008b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b5:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8008b8:	8a 10                	mov    (%eax),%dl
  8008ba:	84 d2                	test   %dl,%dl
  8008bc:	74 07                	je     8008c5 <strchr+0x16>
		if (*s == c)
  8008be:	38 ca                	cmp    %cl,%dl
  8008c0:	74 08                	je     8008ca <strchr+0x1b>
	for (; *s; s++)
  8008c2:	40                   	inc    %eax
  8008c3:	eb f3                	jmp    8008b8 <strchr+0x9>
			return (char *) s;
	return 0;
  8008c5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008ca:	5d                   	pop    %ebp
  8008cb:	c3                   	ret    

008008cc <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008cc:	55                   	push   %ebp
  8008cd:	89 e5                	mov    %esp,%ebp
  8008cf:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d2:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8008d5:	8a 10                	mov    (%eax),%dl
  8008d7:	84 d2                	test   %dl,%dl
  8008d9:	74 07                	je     8008e2 <strfind+0x16>
		if (*s == c)
  8008db:	38 ca                	cmp    %cl,%dl
  8008dd:	74 03                	je     8008e2 <strfind+0x16>
	for (; *s; s++)
  8008df:	40                   	inc    %eax
  8008e0:	eb f3                	jmp    8008d5 <strfind+0x9>
			break;
	return (char *) s;
}
  8008e2:	5d                   	pop    %ebp
  8008e3:	c3                   	ret    

008008e4 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008e4:	55                   	push   %ebp
  8008e5:	89 e5                	mov    %esp,%ebp
  8008e7:	57                   	push   %edi
  8008e8:	56                   	push   %esi
  8008e9:	53                   	push   %ebx
  8008ea:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008ed:	85 c9                	test   %ecx,%ecx
  8008ef:	74 36                	je     800927 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008f1:	89 c8                	mov    %ecx,%eax
  8008f3:	0b 45 08             	or     0x8(%ebp),%eax
  8008f6:	a8 03                	test   $0x3,%al
  8008f8:	75 24                	jne    80091e <memset+0x3a>
		c &= 0xFF;
  8008fa:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008fe:	89 d3                	mov    %edx,%ebx
  800900:	c1 e3 08             	shl    $0x8,%ebx
  800903:	89 d0                	mov    %edx,%eax
  800905:	c1 e0 18             	shl    $0x18,%eax
  800908:	89 d6                	mov    %edx,%esi
  80090a:	c1 e6 10             	shl    $0x10,%esi
  80090d:	09 f0                	or     %esi,%eax
  80090f:	09 d0                	or     %edx,%eax
  800911:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800913:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800916:	8b 7d 08             	mov    0x8(%ebp),%edi
  800919:	fc                   	cld    
  80091a:	f3 ab                	rep stos %eax,%es:(%edi)
  80091c:	eb 09                	jmp    800927 <memset+0x43>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80091e:	8b 7d 08             	mov    0x8(%ebp),%edi
  800921:	8b 45 0c             	mov    0xc(%ebp),%eax
  800924:	fc                   	cld    
  800925:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800927:	8b 45 08             	mov    0x8(%ebp),%eax
  80092a:	5b                   	pop    %ebx
  80092b:	5e                   	pop    %esi
  80092c:	5f                   	pop    %edi
  80092d:	5d                   	pop    %ebp
  80092e:	c3                   	ret    

0080092f <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80092f:	55                   	push   %ebp
  800930:	89 e5                	mov    %esp,%ebp
  800932:	57                   	push   %edi
  800933:	56                   	push   %esi
  800934:	8b 45 08             	mov    0x8(%ebp),%eax
  800937:	8b 75 0c             	mov    0xc(%ebp),%esi
  80093a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80093d:	39 c6                	cmp    %eax,%esi
  80093f:	73 30                	jae    800971 <memmove+0x42>
  800941:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800944:	39 c2                	cmp    %eax,%edx
  800946:	76 29                	jbe    800971 <memmove+0x42>
		s += n;
		d += n;
  800948:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80094b:	89 fe                	mov    %edi,%esi
  80094d:	09 ce                	or     %ecx,%esi
  80094f:	09 d6                	or     %edx,%esi
  800951:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800957:	75 0e                	jne    800967 <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800959:	83 ef 04             	sub    $0x4,%edi
  80095c:	8d 72 fc             	lea    -0x4(%edx),%esi
  80095f:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800962:	fd                   	std    
  800963:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800965:	eb 07                	jmp    80096e <memmove+0x3f>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800967:	4f                   	dec    %edi
  800968:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  80096b:	fd                   	std    
  80096c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80096e:	fc                   	cld    
  80096f:	eb 1a                	jmp    80098b <memmove+0x5c>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800971:	89 c2                	mov    %eax,%edx
  800973:	09 ca                	or     %ecx,%edx
  800975:	09 f2                	or     %esi,%edx
  800977:	f6 c2 03             	test   $0x3,%dl
  80097a:	75 0a                	jne    800986 <memmove+0x57>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  80097c:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  80097f:	89 c7                	mov    %eax,%edi
  800981:	fc                   	cld    
  800982:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800984:	eb 05                	jmp    80098b <memmove+0x5c>
		else
			asm volatile("cld; rep movsb\n"
  800986:	89 c7                	mov    %eax,%edi
  800988:	fc                   	cld    
  800989:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80098b:	5e                   	pop    %esi
  80098c:	5f                   	pop    %edi
  80098d:	5d                   	pop    %ebp
  80098e:	c3                   	ret    

0080098f <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80098f:	55                   	push   %ebp
  800990:	89 e5                	mov    %esp,%ebp
  800992:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800995:	ff 75 10             	pushl  0x10(%ebp)
  800998:	ff 75 0c             	pushl  0xc(%ebp)
  80099b:	ff 75 08             	pushl  0x8(%ebp)
  80099e:	e8 8c ff ff ff       	call   80092f <memmove>
}
  8009a3:	c9                   	leave  
  8009a4:	c3                   	ret    

008009a5 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009a5:	55                   	push   %ebp
  8009a6:	89 e5                	mov    %esp,%ebp
  8009a8:	56                   	push   %esi
  8009a9:	53                   	push   %ebx
  8009aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ad:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009b0:	89 c6                	mov    %eax,%esi
  8009b2:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009b5:	39 f0                	cmp    %esi,%eax
  8009b7:	74 16                	je     8009cf <memcmp+0x2a>
		if (*s1 != *s2)
  8009b9:	8a 08                	mov    (%eax),%cl
  8009bb:	8a 1a                	mov    (%edx),%bl
  8009bd:	38 d9                	cmp    %bl,%cl
  8009bf:	75 04                	jne    8009c5 <memcmp+0x20>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  8009c1:	40                   	inc    %eax
  8009c2:	42                   	inc    %edx
  8009c3:	eb f0                	jmp    8009b5 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  8009c5:	0f b6 c1             	movzbl %cl,%eax
  8009c8:	0f b6 db             	movzbl %bl,%ebx
  8009cb:	29 d8                	sub    %ebx,%eax
  8009cd:	eb 05                	jmp    8009d4 <memcmp+0x2f>
	}

	return 0;
  8009cf:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009d4:	5b                   	pop    %ebx
  8009d5:	5e                   	pop    %esi
  8009d6:	5d                   	pop    %ebp
  8009d7:	c3                   	ret    

008009d8 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009d8:	55                   	push   %ebp
  8009d9:	89 e5                	mov    %esp,%ebp
  8009db:	8b 45 08             	mov    0x8(%ebp),%eax
  8009de:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8009e1:	89 c2                	mov    %eax,%edx
  8009e3:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8009e6:	39 d0                	cmp    %edx,%eax
  8009e8:	73 07                	jae    8009f1 <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009ea:	38 08                	cmp    %cl,(%eax)
  8009ec:	74 03                	je     8009f1 <memfind+0x19>
	for (; s < ends; s++)
  8009ee:	40                   	inc    %eax
  8009ef:	eb f5                	jmp    8009e6 <memfind+0xe>
			break;
	return (void *) s;
}
  8009f1:	5d                   	pop    %ebp
  8009f2:	c3                   	ret    

008009f3 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009f3:	55                   	push   %ebp
  8009f4:	89 e5                	mov    %esp,%ebp
  8009f6:	57                   	push   %edi
  8009f7:	56                   	push   %esi
  8009f8:	53                   	push   %ebx
  8009f9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009fc:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009ff:	eb 01                	jmp    800a02 <strtol+0xf>
		s++;
  800a01:	41                   	inc    %ecx
	while (*s == ' ' || *s == '\t')
  800a02:	8a 01                	mov    (%ecx),%al
  800a04:	3c 20                	cmp    $0x20,%al
  800a06:	74 f9                	je     800a01 <strtol+0xe>
  800a08:	3c 09                	cmp    $0x9,%al
  800a0a:	74 f5                	je     800a01 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800a0c:	3c 2b                	cmp    $0x2b,%al
  800a0e:	74 24                	je     800a34 <strtol+0x41>
		s++;
	else if (*s == '-')
  800a10:	3c 2d                	cmp    $0x2d,%al
  800a12:	74 28                	je     800a3c <strtol+0x49>
	int neg = 0;
  800a14:	bf 00 00 00 00       	mov    $0x0,%edi
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a19:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a1f:	75 09                	jne    800a2a <strtol+0x37>
  800a21:	80 39 30             	cmpb   $0x30,(%ecx)
  800a24:	74 1e                	je     800a44 <strtol+0x51>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a26:	85 db                	test   %ebx,%ebx
  800a28:	74 36                	je     800a60 <strtol+0x6d>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a2a:	b8 00 00 00 00       	mov    $0x0,%eax
  800a2f:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800a32:	eb 45                	jmp    800a79 <strtol+0x86>
		s++;
  800a34:	41                   	inc    %ecx
	int neg = 0;
  800a35:	bf 00 00 00 00       	mov    $0x0,%edi
  800a3a:	eb dd                	jmp    800a19 <strtol+0x26>
		s++, neg = 1;
  800a3c:	41                   	inc    %ecx
  800a3d:	bf 01 00 00 00       	mov    $0x1,%edi
  800a42:	eb d5                	jmp    800a19 <strtol+0x26>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a44:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a48:	74 0c                	je     800a56 <strtol+0x63>
	else if (base == 0 && s[0] == '0')
  800a4a:	85 db                	test   %ebx,%ebx
  800a4c:	75 dc                	jne    800a2a <strtol+0x37>
		s++, base = 8;
  800a4e:	41                   	inc    %ecx
  800a4f:	bb 08 00 00 00       	mov    $0x8,%ebx
  800a54:	eb d4                	jmp    800a2a <strtol+0x37>
		s += 2, base = 16;
  800a56:	83 c1 02             	add    $0x2,%ecx
  800a59:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a5e:	eb ca                	jmp    800a2a <strtol+0x37>
		base = 10;
  800a60:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800a65:	eb c3                	jmp    800a2a <strtol+0x37>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800a67:	0f be d2             	movsbl %dl,%edx
  800a6a:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800a6d:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a70:	7d 37                	jge    800aa9 <strtol+0xb6>
			break;
		s++, val = (val * base) + dig;
  800a72:	41                   	inc    %ecx
  800a73:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a77:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800a79:	8a 11                	mov    (%ecx),%dl
  800a7b:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a7e:	89 f3                	mov    %esi,%ebx
  800a80:	80 fb 09             	cmp    $0x9,%bl
  800a83:	76 e2                	jbe    800a67 <strtol+0x74>
		else if (*s >= 'a' && *s <= 'z')
  800a85:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a88:	89 f3                	mov    %esi,%ebx
  800a8a:	80 fb 19             	cmp    $0x19,%bl
  800a8d:	77 08                	ja     800a97 <strtol+0xa4>
			dig = *s - 'a' + 10;
  800a8f:	0f be d2             	movsbl %dl,%edx
  800a92:	83 ea 57             	sub    $0x57,%edx
  800a95:	eb d6                	jmp    800a6d <strtol+0x7a>
		else if (*s >= 'A' && *s <= 'Z')
  800a97:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a9a:	89 f3                	mov    %esi,%ebx
  800a9c:	80 fb 19             	cmp    $0x19,%bl
  800a9f:	77 08                	ja     800aa9 <strtol+0xb6>
			dig = *s - 'A' + 10;
  800aa1:	0f be d2             	movsbl %dl,%edx
  800aa4:	83 ea 37             	sub    $0x37,%edx
  800aa7:	eb c4                	jmp    800a6d <strtol+0x7a>
		// we don't properly detect overflow!
	}

	if (endptr)
  800aa9:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800aad:	74 05                	je     800ab4 <strtol+0xc1>
		*endptr = (char *) s;
  800aaf:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ab2:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800ab4:	85 ff                	test   %edi,%edi
  800ab6:	74 02                	je     800aba <strtol+0xc7>
  800ab8:	f7 d8                	neg    %eax
}
  800aba:	5b                   	pop    %ebx
  800abb:	5e                   	pop    %esi
  800abc:	5f                   	pop    %edi
  800abd:	5d                   	pop    %ebp
  800abe:	c3                   	ret    
  800abf:	90                   	nop

00800ac0 <__udivdi3>:
  800ac0:	55                   	push   %ebp
  800ac1:	57                   	push   %edi
  800ac2:	56                   	push   %esi
  800ac3:	53                   	push   %ebx
  800ac4:	83 ec 1c             	sub    $0x1c,%esp
  800ac7:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800acb:	8b 74 24 34          	mov    0x34(%esp),%esi
  800acf:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800ad3:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800ad7:	85 d2                	test   %edx,%edx
  800ad9:	75 19                	jne    800af4 <__udivdi3+0x34>
  800adb:	39 f7                	cmp    %esi,%edi
  800add:	76 45                	jbe    800b24 <__udivdi3+0x64>
  800adf:	89 e8                	mov    %ebp,%eax
  800ae1:	89 f2                	mov    %esi,%edx
  800ae3:	f7 f7                	div    %edi
  800ae5:	31 db                	xor    %ebx,%ebx
  800ae7:	89 da                	mov    %ebx,%edx
  800ae9:	83 c4 1c             	add    $0x1c,%esp
  800aec:	5b                   	pop    %ebx
  800aed:	5e                   	pop    %esi
  800aee:	5f                   	pop    %edi
  800aef:	5d                   	pop    %ebp
  800af0:	c3                   	ret    
  800af1:	8d 76 00             	lea    0x0(%esi),%esi
  800af4:	39 f2                	cmp    %esi,%edx
  800af6:	76 10                	jbe    800b08 <__udivdi3+0x48>
  800af8:	31 db                	xor    %ebx,%ebx
  800afa:	31 c0                	xor    %eax,%eax
  800afc:	89 da                	mov    %ebx,%edx
  800afe:	83 c4 1c             	add    $0x1c,%esp
  800b01:	5b                   	pop    %ebx
  800b02:	5e                   	pop    %esi
  800b03:	5f                   	pop    %edi
  800b04:	5d                   	pop    %ebp
  800b05:	c3                   	ret    
  800b06:	66 90                	xchg   %ax,%ax
  800b08:	0f bd da             	bsr    %edx,%ebx
  800b0b:	83 f3 1f             	xor    $0x1f,%ebx
  800b0e:	75 3c                	jne    800b4c <__udivdi3+0x8c>
  800b10:	39 f2                	cmp    %esi,%edx
  800b12:	72 08                	jb     800b1c <__udivdi3+0x5c>
  800b14:	39 ef                	cmp    %ebp,%edi
  800b16:	0f 87 9c 00 00 00    	ja     800bb8 <__udivdi3+0xf8>
  800b1c:	b8 01 00 00 00       	mov    $0x1,%eax
  800b21:	eb d9                	jmp    800afc <__udivdi3+0x3c>
  800b23:	90                   	nop
  800b24:	89 f9                	mov    %edi,%ecx
  800b26:	85 ff                	test   %edi,%edi
  800b28:	75 0b                	jne    800b35 <__udivdi3+0x75>
  800b2a:	b8 01 00 00 00       	mov    $0x1,%eax
  800b2f:	31 d2                	xor    %edx,%edx
  800b31:	f7 f7                	div    %edi
  800b33:	89 c1                	mov    %eax,%ecx
  800b35:	31 d2                	xor    %edx,%edx
  800b37:	89 f0                	mov    %esi,%eax
  800b39:	f7 f1                	div    %ecx
  800b3b:	89 c3                	mov    %eax,%ebx
  800b3d:	89 e8                	mov    %ebp,%eax
  800b3f:	f7 f1                	div    %ecx
  800b41:	89 da                	mov    %ebx,%edx
  800b43:	83 c4 1c             	add    $0x1c,%esp
  800b46:	5b                   	pop    %ebx
  800b47:	5e                   	pop    %esi
  800b48:	5f                   	pop    %edi
  800b49:	5d                   	pop    %ebp
  800b4a:	c3                   	ret    
  800b4b:	90                   	nop
  800b4c:	b8 20 00 00 00       	mov    $0x20,%eax
  800b51:	29 d8                	sub    %ebx,%eax
  800b53:	88 d9                	mov    %bl,%cl
  800b55:	d3 e2                	shl    %cl,%edx
  800b57:	89 54 24 08          	mov    %edx,0x8(%esp)
  800b5b:	89 fa                	mov    %edi,%edx
  800b5d:	88 c1                	mov    %al,%cl
  800b5f:	d3 ea                	shr    %cl,%edx
  800b61:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800b65:	09 d1                	or     %edx,%ecx
  800b67:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800b6b:	88 d9                	mov    %bl,%cl
  800b6d:	d3 e7                	shl    %cl,%edi
  800b6f:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800b73:	89 f7                	mov    %esi,%edi
  800b75:	88 c1                	mov    %al,%cl
  800b77:	d3 ef                	shr    %cl,%edi
  800b79:	88 d9                	mov    %bl,%cl
  800b7b:	d3 e6                	shl    %cl,%esi
  800b7d:	89 ea                	mov    %ebp,%edx
  800b7f:	88 c1                	mov    %al,%cl
  800b81:	d3 ea                	shr    %cl,%edx
  800b83:	09 d6                	or     %edx,%esi
  800b85:	89 f0                	mov    %esi,%eax
  800b87:	89 fa                	mov    %edi,%edx
  800b89:	f7 74 24 08          	divl   0x8(%esp)
  800b8d:	89 d7                	mov    %edx,%edi
  800b8f:	89 c6                	mov    %eax,%esi
  800b91:	f7 64 24 0c          	mull   0xc(%esp)
  800b95:	39 d7                	cmp    %edx,%edi
  800b97:	72 13                	jb     800bac <__udivdi3+0xec>
  800b99:	74 09                	je     800ba4 <__udivdi3+0xe4>
  800b9b:	89 f0                	mov    %esi,%eax
  800b9d:	31 db                	xor    %ebx,%ebx
  800b9f:	e9 58 ff ff ff       	jmp    800afc <__udivdi3+0x3c>
  800ba4:	88 d9                	mov    %bl,%cl
  800ba6:	d3 e5                	shl    %cl,%ebp
  800ba8:	39 c5                	cmp    %eax,%ebp
  800baa:	73 ef                	jae    800b9b <__udivdi3+0xdb>
  800bac:	8d 46 ff             	lea    -0x1(%esi),%eax
  800baf:	31 db                	xor    %ebx,%ebx
  800bb1:	e9 46 ff ff ff       	jmp    800afc <__udivdi3+0x3c>
  800bb6:	66 90                	xchg   %ax,%ax
  800bb8:	31 c0                	xor    %eax,%eax
  800bba:	e9 3d ff ff ff       	jmp    800afc <__udivdi3+0x3c>
  800bbf:	90                   	nop

00800bc0 <__umoddi3>:
  800bc0:	55                   	push   %ebp
  800bc1:	57                   	push   %edi
  800bc2:	56                   	push   %esi
  800bc3:	53                   	push   %ebx
  800bc4:	83 ec 1c             	sub    $0x1c,%esp
  800bc7:	8b 74 24 30          	mov    0x30(%esp),%esi
  800bcb:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800bcf:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800bd3:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  800bd7:	85 c0                	test   %eax,%eax
  800bd9:	75 19                	jne    800bf4 <__umoddi3+0x34>
  800bdb:	39 df                	cmp    %ebx,%edi
  800bdd:	76 51                	jbe    800c30 <__umoddi3+0x70>
  800bdf:	89 f0                	mov    %esi,%eax
  800be1:	89 da                	mov    %ebx,%edx
  800be3:	f7 f7                	div    %edi
  800be5:	89 d0                	mov    %edx,%eax
  800be7:	31 d2                	xor    %edx,%edx
  800be9:	83 c4 1c             	add    $0x1c,%esp
  800bec:	5b                   	pop    %ebx
  800bed:	5e                   	pop    %esi
  800bee:	5f                   	pop    %edi
  800bef:	5d                   	pop    %ebp
  800bf0:	c3                   	ret    
  800bf1:	8d 76 00             	lea    0x0(%esi),%esi
  800bf4:	89 f2                	mov    %esi,%edx
  800bf6:	39 d8                	cmp    %ebx,%eax
  800bf8:	76 0e                	jbe    800c08 <__umoddi3+0x48>
  800bfa:	89 f0                	mov    %esi,%eax
  800bfc:	89 da                	mov    %ebx,%edx
  800bfe:	83 c4 1c             	add    $0x1c,%esp
  800c01:	5b                   	pop    %ebx
  800c02:	5e                   	pop    %esi
  800c03:	5f                   	pop    %edi
  800c04:	5d                   	pop    %ebp
  800c05:	c3                   	ret    
  800c06:	66 90                	xchg   %ax,%ax
  800c08:	0f bd e8             	bsr    %eax,%ebp
  800c0b:	83 f5 1f             	xor    $0x1f,%ebp
  800c0e:	75 44                	jne    800c54 <__umoddi3+0x94>
  800c10:	39 d8                	cmp    %ebx,%eax
  800c12:	72 06                	jb     800c1a <__umoddi3+0x5a>
  800c14:	89 d9                	mov    %ebx,%ecx
  800c16:	39 f7                	cmp    %esi,%edi
  800c18:	77 08                	ja     800c22 <__umoddi3+0x62>
  800c1a:	29 fe                	sub    %edi,%esi
  800c1c:	19 c3                	sbb    %eax,%ebx
  800c1e:	89 f2                	mov    %esi,%edx
  800c20:	89 d9                	mov    %ebx,%ecx
  800c22:	89 d0                	mov    %edx,%eax
  800c24:	89 ca                	mov    %ecx,%edx
  800c26:	83 c4 1c             	add    $0x1c,%esp
  800c29:	5b                   	pop    %ebx
  800c2a:	5e                   	pop    %esi
  800c2b:	5f                   	pop    %edi
  800c2c:	5d                   	pop    %ebp
  800c2d:	c3                   	ret    
  800c2e:	66 90                	xchg   %ax,%ax
  800c30:	89 fd                	mov    %edi,%ebp
  800c32:	85 ff                	test   %edi,%edi
  800c34:	75 0b                	jne    800c41 <__umoddi3+0x81>
  800c36:	b8 01 00 00 00       	mov    $0x1,%eax
  800c3b:	31 d2                	xor    %edx,%edx
  800c3d:	f7 f7                	div    %edi
  800c3f:	89 c5                	mov    %eax,%ebp
  800c41:	89 d8                	mov    %ebx,%eax
  800c43:	31 d2                	xor    %edx,%edx
  800c45:	f7 f5                	div    %ebp
  800c47:	89 f0                	mov    %esi,%eax
  800c49:	f7 f5                	div    %ebp
  800c4b:	89 d0                	mov    %edx,%eax
  800c4d:	31 d2                	xor    %edx,%edx
  800c4f:	eb 98                	jmp    800be9 <__umoddi3+0x29>
  800c51:	8d 76 00             	lea    0x0(%esi),%esi
  800c54:	ba 20 00 00 00       	mov    $0x20,%edx
  800c59:	29 ea                	sub    %ebp,%edx
  800c5b:	89 e9                	mov    %ebp,%ecx
  800c5d:	d3 e0                	shl    %cl,%eax
  800c5f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c63:	89 f8                	mov    %edi,%eax
  800c65:	89 54 24 04          	mov    %edx,0x4(%esp)
  800c69:	88 d1                	mov    %dl,%cl
  800c6b:	d3 e8                	shr    %cl,%eax
  800c6d:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800c71:	09 c1                	or     %eax,%ecx
  800c73:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800c77:	89 e9                	mov    %ebp,%ecx
  800c79:	d3 e7                	shl    %cl,%edi
  800c7b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800c7f:	89 d8                	mov    %ebx,%eax
  800c81:	8b 54 24 04          	mov    0x4(%esp),%edx
  800c85:	88 d1                	mov    %dl,%cl
  800c87:	d3 e8                	shr    %cl,%eax
  800c89:	89 c7                	mov    %eax,%edi
  800c8b:	89 e9                	mov    %ebp,%ecx
  800c8d:	d3 e3                	shl    %cl,%ebx
  800c8f:	89 f0                	mov    %esi,%eax
  800c91:	88 d1                	mov    %dl,%cl
  800c93:	d3 e8                	shr    %cl,%eax
  800c95:	09 d8                	or     %ebx,%eax
  800c97:	89 e9                	mov    %ebp,%ecx
  800c99:	d3 e6                	shl    %cl,%esi
  800c9b:	89 f3                	mov    %esi,%ebx
  800c9d:	89 fa                	mov    %edi,%edx
  800c9f:	f7 74 24 08          	divl   0x8(%esp)
  800ca3:	89 d1                	mov    %edx,%ecx
  800ca5:	f7 64 24 0c          	mull   0xc(%esp)
  800ca9:	89 c6                	mov    %eax,%esi
  800cab:	89 d7                	mov    %edx,%edi
  800cad:	39 d1                	cmp    %edx,%ecx
  800caf:	72 27                	jb     800cd8 <__umoddi3+0x118>
  800cb1:	74 21                	je     800cd4 <__umoddi3+0x114>
  800cb3:	89 ca                	mov    %ecx,%edx
  800cb5:	29 f3                	sub    %esi,%ebx
  800cb7:	19 fa                	sbb    %edi,%edx
  800cb9:	89 d0                	mov    %edx,%eax
  800cbb:	8a 4c 24 04          	mov    0x4(%esp),%cl
  800cbf:	d3 e0                	shl    %cl,%eax
  800cc1:	89 e9                	mov    %ebp,%ecx
  800cc3:	d3 eb                	shr    %cl,%ebx
  800cc5:	09 d8                	or     %ebx,%eax
  800cc7:	d3 ea                	shr    %cl,%edx
  800cc9:	83 c4 1c             	add    $0x1c,%esp
  800ccc:	5b                   	pop    %ebx
  800ccd:	5e                   	pop    %esi
  800cce:	5f                   	pop    %edi
  800ccf:	5d                   	pop    %ebp
  800cd0:	c3                   	ret    
  800cd1:	8d 76 00             	lea    0x0(%esi),%esi
  800cd4:	39 c3                	cmp    %eax,%ebx
  800cd6:	73 db                	jae    800cb3 <__umoddi3+0xf3>
  800cd8:	2b 44 24 0c          	sub    0xc(%esp),%eax
  800cdc:	1b 54 24 08          	sbb    0x8(%esp),%edx
  800ce0:	89 d7                	mov    %edx,%edi
  800ce2:	89 c6                	mov    %eax,%esi
  800ce4:	eb cd                	jmp    800cb3 <__umoddi3+0xf3>
