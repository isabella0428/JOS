
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
  800044:	e8 4d 00 00 00       	call   800096 <sys_cputs>
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
  800051:	83 ec 08             	sub    $0x8,%esp
  800054:	8b 45 08             	mov    0x8(%ebp),%eax
  800057:	8b 55 0c             	mov    0xc(%ebp),%edx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  80005a:	c7 05 08 10 80 00 00 	movl   $0x0,0x801008
  800061:	00 00 00 

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800064:	85 c0                	test   %eax,%eax
  800066:	7e 08                	jle    800070 <libmain+0x22>
		binaryname = argv[0];
  800068:	8b 0a                	mov    (%edx),%ecx
  80006a:	89 0d 04 10 80 00    	mov    %ecx,0x801004

	// call user main routine
	umain(argc, argv);
  800070:	83 ec 08             	sub    $0x8,%esp
  800073:	52                   	push   %edx
  800074:	50                   	push   %eax
  800075:	e8 b9 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80007a:	e8 05 00 00 00       	call   800084 <exit>
}
  80007f:	83 c4 10             	add    $0x10,%esp
  800082:	c9                   	leave  
  800083:	c3                   	ret    

00800084 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800084:	55                   	push   %ebp
  800085:	89 e5                	mov    %esp,%ebp
  800087:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  80008a:	6a 00                	push   $0x0
  80008c:	e8 42 00 00 00       	call   8000d3 <sys_env_destroy>
}
  800091:	83 c4 10             	add    $0x10,%esp
  800094:	c9                   	leave  
  800095:	c3                   	ret    

00800096 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800096:	55                   	push   %ebp
  800097:	89 e5                	mov    %esp,%ebp
  800099:	57                   	push   %edi
  80009a:	56                   	push   %esi
  80009b:	53                   	push   %ebx
	asm volatile("int %1\n"
  80009c:	b8 00 00 00 00       	mov    $0x0,%eax
  8000a1:	8b 55 08             	mov    0x8(%ebp),%edx
  8000a4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000a7:	89 c3                	mov    %eax,%ebx
  8000a9:	89 c7                	mov    %eax,%edi
  8000ab:	89 c6                	mov    %eax,%esi
  8000ad:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000af:	5b                   	pop    %ebx
  8000b0:	5e                   	pop    %esi
  8000b1:	5f                   	pop    %edi
  8000b2:	5d                   	pop    %ebp
  8000b3:	c3                   	ret    

008000b4 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000b4:	55                   	push   %ebp
  8000b5:	89 e5                	mov    %esp,%ebp
  8000b7:	57                   	push   %edi
  8000b8:	56                   	push   %esi
  8000b9:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000ba:	ba 00 00 00 00       	mov    $0x0,%edx
  8000bf:	b8 01 00 00 00       	mov    $0x1,%eax
  8000c4:	89 d1                	mov    %edx,%ecx
  8000c6:	89 d3                	mov    %edx,%ebx
  8000c8:	89 d7                	mov    %edx,%edi
  8000ca:	89 d6                	mov    %edx,%esi
  8000cc:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000ce:	5b                   	pop    %ebx
  8000cf:	5e                   	pop    %esi
  8000d0:	5f                   	pop    %edi
  8000d1:	5d                   	pop    %ebp
  8000d2:	c3                   	ret    

008000d3 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000d3:	55                   	push   %ebp
  8000d4:	89 e5                	mov    %esp,%ebp
  8000d6:	57                   	push   %edi
  8000d7:	56                   	push   %esi
  8000d8:	53                   	push   %ebx
  8000d9:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8000dc:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000e1:	8b 55 08             	mov    0x8(%ebp),%edx
  8000e4:	b8 03 00 00 00       	mov    $0x3,%eax
  8000e9:	89 cb                	mov    %ecx,%ebx
  8000eb:	89 cf                	mov    %ecx,%edi
  8000ed:	89 ce                	mov    %ecx,%esi
  8000ef:	cd 30                	int    $0x30
	if(check && ret > 0)
  8000f1:	85 c0                	test   %eax,%eax
  8000f3:	7f 08                	jg     8000fd <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  8000f5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000f8:	5b                   	pop    %ebx
  8000f9:	5e                   	pop    %esi
  8000fa:	5f                   	pop    %edi
  8000fb:	5d                   	pop    %ebp
  8000fc:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8000fd:	83 ec 0c             	sub    $0xc,%esp
  800100:	50                   	push   %eax
  800101:	6a 03                	push   $0x3
  800103:	68 08 0d 80 00       	push   $0x800d08
  800108:	6a 23                	push   $0x23
  80010a:	68 25 0d 80 00       	push   $0x800d25
  80010f:	e8 1f 00 00 00       	call   800133 <_panic>

00800114 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800114:	55                   	push   %ebp
  800115:	89 e5                	mov    %esp,%ebp
  800117:	57                   	push   %edi
  800118:	56                   	push   %esi
  800119:	53                   	push   %ebx
	asm volatile("int %1\n"
  80011a:	ba 00 00 00 00       	mov    $0x0,%edx
  80011f:	b8 02 00 00 00       	mov    $0x2,%eax
  800124:	89 d1                	mov    %edx,%ecx
  800126:	89 d3                	mov    %edx,%ebx
  800128:	89 d7                	mov    %edx,%edi
  80012a:	89 d6                	mov    %edx,%esi
  80012c:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80012e:	5b                   	pop    %ebx
  80012f:	5e                   	pop    %esi
  800130:	5f                   	pop    %edi
  800131:	5d                   	pop    %ebp
  800132:	c3                   	ret    

00800133 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800133:	55                   	push   %ebp
  800134:	89 e5                	mov    %esp,%ebp
  800136:	56                   	push   %esi
  800137:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800138:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80013b:	8b 35 04 10 80 00    	mov    0x801004,%esi
  800141:	e8 ce ff ff ff       	call   800114 <sys_getenvid>
  800146:	83 ec 0c             	sub    $0xc,%esp
  800149:	ff 75 0c             	pushl  0xc(%ebp)
  80014c:	ff 75 08             	pushl  0x8(%ebp)
  80014f:	56                   	push   %esi
  800150:	50                   	push   %eax
  800151:	68 34 0d 80 00       	push   $0x800d34
  800156:	e8 b2 00 00 00       	call   80020d <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80015b:	83 c4 18             	add    $0x18,%esp
  80015e:	53                   	push   %ebx
  80015f:	ff 75 10             	pushl  0x10(%ebp)
  800162:	e8 55 00 00 00       	call   8001bc <vcprintf>
	cprintf("\n");
  800167:	c7 04 24 fc 0c 80 00 	movl   $0x800cfc,(%esp)
  80016e:	e8 9a 00 00 00       	call   80020d <cprintf>
  800173:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800176:	cc                   	int3   
  800177:	eb fd                	jmp    800176 <_panic+0x43>

00800179 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800179:	55                   	push   %ebp
  80017a:	89 e5                	mov    %esp,%ebp
  80017c:	53                   	push   %ebx
  80017d:	83 ec 04             	sub    $0x4,%esp
  800180:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800183:	8b 13                	mov    (%ebx),%edx
  800185:	8d 42 01             	lea    0x1(%edx),%eax
  800188:	89 03                	mov    %eax,(%ebx)
  80018a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80018d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800191:	3d ff 00 00 00       	cmp    $0xff,%eax
  800196:	74 08                	je     8001a0 <putch+0x27>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800198:	ff 43 04             	incl   0x4(%ebx)
}
  80019b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80019e:	c9                   	leave  
  80019f:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8001a0:	83 ec 08             	sub    $0x8,%esp
  8001a3:	68 ff 00 00 00       	push   $0xff
  8001a8:	8d 43 08             	lea    0x8(%ebx),%eax
  8001ab:	50                   	push   %eax
  8001ac:	e8 e5 fe ff ff       	call   800096 <sys_cputs>
		b->idx = 0;
  8001b1:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001b7:	83 c4 10             	add    $0x10,%esp
  8001ba:	eb dc                	jmp    800198 <putch+0x1f>

008001bc <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001bc:	55                   	push   %ebp
  8001bd:	89 e5                	mov    %esp,%ebp
  8001bf:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001c5:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001cc:	00 00 00 
	b.cnt = 0;
  8001cf:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001d6:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001d9:	ff 75 0c             	pushl  0xc(%ebp)
  8001dc:	ff 75 08             	pushl  0x8(%ebp)
  8001df:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001e5:	50                   	push   %eax
  8001e6:	68 79 01 80 00       	push   $0x800179
  8001eb:	e8 0f 01 00 00       	call   8002ff <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001f0:	83 c4 08             	add    $0x8,%esp
  8001f3:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001f9:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001ff:	50                   	push   %eax
  800200:	e8 91 fe ff ff       	call   800096 <sys_cputs>

	return b.cnt;
}
  800205:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80020b:	c9                   	leave  
  80020c:	c3                   	ret    

0080020d <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80020d:	55                   	push   %ebp
  80020e:	89 e5                	mov    %esp,%ebp
  800210:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800213:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800216:	50                   	push   %eax
  800217:	ff 75 08             	pushl  0x8(%ebp)
  80021a:	e8 9d ff ff ff       	call   8001bc <vcprintf>
	va_end(ap);

	return cnt;
}
  80021f:	c9                   	leave  
  800220:	c3                   	ret    

00800221 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800221:	55                   	push   %ebp
  800222:	89 e5                	mov    %esp,%ebp
  800224:	57                   	push   %edi
  800225:	56                   	push   %esi
  800226:	53                   	push   %ebx
  800227:	83 ec 1c             	sub    $0x1c,%esp
  80022a:	89 c7                	mov    %eax,%edi
  80022c:	89 d6                	mov    %edx,%esi
  80022e:	8b 45 08             	mov    0x8(%ebp),%eax
  800231:	8b 55 0c             	mov    0xc(%ebp),%edx
  800234:	89 d1                	mov    %edx,%ecx
  800236:	89 c2                	mov    %eax,%edx
  800238:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80023b:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80023e:	8b 45 10             	mov    0x10(%ebp),%eax
  800241:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800244:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800247:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80024e:	39 c2                	cmp    %eax,%edx
  800250:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  800253:	72 3c                	jb     800291 <printnum+0x70>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800255:	83 ec 0c             	sub    $0xc,%esp
  800258:	ff 75 18             	pushl  0x18(%ebp)
  80025b:	4b                   	dec    %ebx
  80025c:	53                   	push   %ebx
  80025d:	50                   	push   %eax
  80025e:	83 ec 08             	sub    $0x8,%esp
  800261:	ff 75 e4             	pushl  -0x1c(%ebp)
  800264:	ff 75 e0             	pushl  -0x20(%ebp)
  800267:	ff 75 dc             	pushl  -0x24(%ebp)
  80026a:	ff 75 d8             	pushl  -0x28(%ebp)
  80026d:	e8 56 08 00 00       	call   800ac8 <__udivdi3>
  800272:	83 c4 18             	add    $0x18,%esp
  800275:	52                   	push   %edx
  800276:	50                   	push   %eax
  800277:	89 f2                	mov    %esi,%edx
  800279:	89 f8                	mov    %edi,%eax
  80027b:	e8 a1 ff ff ff       	call   800221 <printnum>
  800280:	83 c4 20             	add    $0x20,%esp
  800283:	eb 11                	jmp    800296 <printnum+0x75>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800285:	83 ec 08             	sub    $0x8,%esp
  800288:	56                   	push   %esi
  800289:	ff 75 18             	pushl  0x18(%ebp)
  80028c:	ff d7                	call   *%edi
  80028e:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800291:	4b                   	dec    %ebx
  800292:	85 db                	test   %ebx,%ebx
  800294:	7f ef                	jg     800285 <printnum+0x64>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800296:	83 ec 08             	sub    $0x8,%esp
  800299:	56                   	push   %esi
  80029a:	83 ec 04             	sub    $0x4,%esp
  80029d:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002a0:	ff 75 e0             	pushl  -0x20(%ebp)
  8002a3:	ff 75 dc             	pushl  -0x24(%ebp)
  8002a6:	ff 75 d8             	pushl  -0x28(%ebp)
  8002a9:	e8 1a 09 00 00       	call   800bc8 <__umoddi3>
  8002ae:	83 c4 14             	add    $0x14,%esp
  8002b1:	0f be 80 58 0d 80 00 	movsbl 0x800d58(%eax),%eax
  8002b8:	50                   	push   %eax
  8002b9:	ff d7                	call   *%edi
}
  8002bb:	83 c4 10             	add    $0x10,%esp
  8002be:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002c1:	5b                   	pop    %ebx
  8002c2:	5e                   	pop    %esi
  8002c3:	5f                   	pop    %edi
  8002c4:	5d                   	pop    %ebp
  8002c5:	c3                   	ret    

008002c6 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002c6:	55                   	push   %ebp
  8002c7:	89 e5                	mov    %esp,%ebp
  8002c9:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002cc:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8002cf:	8b 10                	mov    (%eax),%edx
  8002d1:	3b 50 04             	cmp    0x4(%eax),%edx
  8002d4:	73 0a                	jae    8002e0 <sprintputch+0x1a>
		*b->buf++ = ch;
  8002d6:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002d9:	89 08                	mov    %ecx,(%eax)
  8002db:	8b 45 08             	mov    0x8(%ebp),%eax
  8002de:	88 02                	mov    %al,(%edx)
}
  8002e0:	5d                   	pop    %ebp
  8002e1:	c3                   	ret    

008002e2 <printfmt>:
{
  8002e2:	55                   	push   %ebp
  8002e3:	89 e5                	mov    %esp,%ebp
  8002e5:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8002e8:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002eb:	50                   	push   %eax
  8002ec:	ff 75 10             	pushl  0x10(%ebp)
  8002ef:	ff 75 0c             	pushl  0xc(%ebp)
  8002f2:	ff 75 08             	pushl  0x8(%ebp)
  8002f5:	e8 05 00 00 00       	call   8002ff <vprintfmt>
}
  8002fa:	83 c4 10             	add    $0x10,%esp
  8002fd:	c9                   	leave  
  8002fe:	c3                   	ret    

008002ff <vprintfmt>:
{
  8002ff:	55                   	push   %ebp
  800300:	89 e5                	mov    %esp,%ebp
  800302:	57                   	push   %edi
  800303:	56                   	push   %esi
  800304:	53                   	push   %ebx
  800305:	83 ec 3c             	sub    $0x3c,%esp
  800308:	8b 75 08             	mov    0x8(%ebp),%esi
  80030b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80030e:	8b 7d 10             	mov    0x10(%ebp),%edi
  800311:	e9 5b 03 00 00       	jmp    800671 <vprintfmt+0x372>
		padc = ' ';
  800316:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  80031a:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
		precision = -1;
  800321:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  800328:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		lflag = 0;
  80032f:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800334:	8d 47 01             	lea    0x1(%edi),%eax
  800337:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80033a:	8a 17                	mov    (%edi),%dl
  80033c:	8d 42 dd             	lea    -0x23(%edx),%eax
  80033f:	3c 55                	cmp    $0x55,%al
  800341:	0f 87 ab 03 00 00    	ja     8006f2 <vprintfmt+0x3f3>
  800347:	0f b6 c0             	movzbl %al,%eax
  80034a:	ff 24 85 e8 0d 80 00 	jmp    *0x800de8(,%eax,4)
  800351:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800354:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  800358:	eb da                	jmp    800334 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  80035a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80035d:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  800361:	eb d1                	jmp    800334 <vprintfmt+0x35>
  800363:	0f b6 d2             	movzbl %dl,%edx
  800366:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800369:	b8 00 00 00 00       	mov    $0x0,%eax
  80036e:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800371:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800374:	01 c0                	add    %eax,%eax
  800376:	8d 44 02 d0          	lea    -0x30(%edx,%eax,1),%eax
				ch = *fmt;
  80037a:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  80037d:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800380:	83 f9 09             	cmp    $0x9,%ecx
  800383:	77 52                	ja     8003d7 <vprintfmt+0xd8>
			for (precision = 0; ; ++fmt) {
  800385:	47                   	inc    %edi
				precision = precision * 10 + ch - '0';
  800386:	eb e9                	jmp    800371 <vprintfmt+0x72>
			precision = va_arg(ap, int);
  800388:	8b 45 14             	mov    0x14(%ebp),%eax
  80038b:	8b 00                	mov    (%eax),%eax
  80038d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800390:	8b 45 14             	mov    0x14(%ebp),%eax
  800393:	8d 40 04             	lea    0x4(%eax),%eax
  800396:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800399:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  80039c:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8003a0:	79 92                	jns    800334 <vprintfmt+0x35>
				width = precision, precision = -1;
  8003a2:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8003a5:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8003a8:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8003af:	eb 83                	jmp    800334 <vprintfmt+0x35>
  8003b1:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8003b5:	78 08                	js     8003bf <vprintfmt+0xc0>
		switch (ch = *(unsigned char *) fmt++) {
  8003b7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8003ba:	e9 75 ff ff ff       	jmp    800334 <vprintfmt+0x35>
  8003bf:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  8003c6:	eb ef                	jmp    8003b7 <vprintfmt+0xb8>
		switch (ch = *(unsigned char *) fmt++) {
  8003c8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8003cb:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  8003d2:	e9 5d ff ff ff       	jmp    800334 <vprintfmt+0x35>
  8003d7:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8003da:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003dd:	eb bd                	jmp    80039c <vprintfmt+0x9d>
			lflag++;
  8003df:	41                   	inc    %ecx
		switch (ch = *(unsigned char *) fmt++) {
  8003e0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8003e3:	e9 4c ff ff ff       	jmp    800334 <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
  8003e8:	8b 45 14             	mov    0x14(%ebp),%eax
  8003eb:	8d 78 04             	lea    0x4(%eax),%edi
  8003ee:	83 ec 08             	sub    $0x8,%esp
  8003f1:	53                   	push   %ebx
  8003f2:	ff 30                	pushl  (%eax)
  8003f4:	ff d6                	call   *%esi
			break;
  8003f6:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8003f9:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8003fc:	e9 6d 02 00 00       	jmp    80066e <vprintfmt+0x36f>
			err = va_arg(ap, int);
  800401:	8b 45 14             	mov    0x14(%ebp),%eax
  800404:	8d 78 04             	lea    0x4(%eax),%edi
  800407:	8b 00                	mov    (%eax),%eax
  800409:	85 c0                	test   %eax,%eax
  80040b:	78 2a                	js     800437 <vprintfmt+0x138>
  80040d:	89 c2                	mov    %eax,%edx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80040f:	83 f8 06             	cmp    $0x6,%eax
  800412:	7f 27                	jg     80043b <vprintfmt+0x13c>
  800414:	8b 04 85 40 0f 80 00 	mov    0x800f40(,%eax,4),%eax
  80041b:	85 c0                	test   %eax,%eax
  80041d:	74 1c                	je     80043b <vprintfmt+0x13c>
				printfmt(putch, putdat, "%s", p);
  80041f:	50                   	push   %eax
  800420:	68 79 0d 80 00       	push   $0x800d79
  800425:	53                   	push   %ebx
  800426:	56                   	push   %esi
  800427:	e8 b6 fe ff ff       	call   8002e2 <printfmt>
  80042c:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80042f:	89 7d 14             	mov    %edi,0x14(%ebp)
  800432:	e9 37 02 00 00       	jmp    80066e <vprintfmt+0x36f>
  800437:	f7 d8                	neg    %eax
  800439:	eb d2                	jmp    80040d <vprintfmt+0x10e>
				printfmt(putch, putdat, "error %d", err);
  80043b:	52                   	push   %edx
  80043c:	68 70 0d 80 00       	push   $0x800d70
  800441:	53                   	push   %ebx
  800442:	56                   	push   %esi
  800443:	e8 9a fe ff ff       	call   8002e2 <printfmt>
  800448:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80044b:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  80044e:	e9 1b 02 00 00       	jmp    80066e <vprintfmt+0x36f>
			if ((p = va_arg(ap, char *)) == NULL)
  800453:	8b 45 14             	mov    0x14(%ebp),%eax
  800456:	83 c0 04             	add    $0x4,%eax
  800459:	89 45 c8             	mov    %eax,-0x38(%ebp)
  80045c:	8b 45 14             	mov    0x14(%ebp),%eax
  80045f:	8b 00                	mov    (%eax),%eax
  800461:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800464:	85 c0                	test   %eax,%eax
  800466:	74 19                	je     800481 <vprintfmt+0x182>
			if (width > 0 && padc != '-')
  800468:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80046c:	7e 06                	jle    800474 <vprintfmt+0x175>
  80046e:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  800472:	75 16                	jne    80048a <vprintfmt+0x18b>
				for (width -= strnlen(p, precision); width > 0; width--)
  800474:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800477:	89 c7                	mov    %eax,%edi
  800479:	03 45 d4             	add    -0x2c(%ebp),%eax
  80047c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80047f:	eb 62                	jmp    8004e3 <vprintfmt+0x1e4>
				p = "(null)";
  800481:	c7 45 cc 69 0d 80 00 	movl   $0x800d69,-0x34(%ebp)
  800488:	eb de                	jmp    800468 <vprintfmt+0x169>
				for (width -= strnlen(p, precision); width > 0; width--)
  80048a:	83 ec 08             	sub    $0x8,%esp
  80048d:	ff 75 d8             	pushl  -0x28(%ebp)
  800490:	ff 75 cc             	pushl  -0x34(%ebp)
  800493:	e8 05 03 00 00       	call   80079d <strnlen>
  800498:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80049b:	29 c2                	sub    %eax,%edx
  80049d:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  8004a0:	83 c4 10             	add    $0x10,%esp
  8004a3:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  8004a5:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8004a9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8004ac:	eb 0d                	jmp    8004bb <vprintfmt+0x1bc>
					putch(padc, putdat);
  8004ae:	83 ec 08             	sub    $0x8,%esp
  8004b1:	53                   	push   %ebx
  8004b2:	ff 75 d4             	pushl  -0x2c(%ebp)
  8004b5:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8004b7:	4f                   	dec    %edi
  8004b8:	83 c4 10             	add    $0x10,%esp
  8004bb:	85 ff                	test   %edi,%edi
  8004bd:	7f ef                	jg     8004ae <vprintfmt+0x1af>
  8004bf:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8004c2:	89 d0                	mov    %edx,%eax
  8004c4:	85 d2                	test   %edx,%edx
  8004c6:	78 0a                	js     8004d2 <vprintfmt+0x1d3>
  8004c8:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8004cb:	29 c2                	sub    %eax,%edx
  8004cd:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8004d0:	eb a2                	jmp    800474 <vprintfmt+0x175>
  8004d2:	b8 00 00 00 00       	mov    $0x0,%eax
  8004d7:	eb ef                	jmp    8004c8 <vprintfmt+0x1c9>
					putch(ch, putdat);
  8004d9:	83 ec 08             	sub    $0x8,%esp
  8004dc:	53                   	push   %ebx
  8004dd:	52                   	push   %edx
  8004de:	ff d6                	call   *%esi
  8004e0:	83 c4 10             	add    $0x10,%esp
  8004e3:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  8004e6:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004e8:	47                   	inc    %edi
  8004e9:	8a 47 ff             	mov    -0x1(%edi),%al
  8004ec:	0f be d0             	movsbl %al,%edx
  8004ef:	85 d2                	test   %edx,%edx
  8004f1:	74 48                	je     80053b <vprintfmt+0x23c>
  8004f3:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004f7:	78 05                	js     8004fe <vprintfmt+0x1ff>
  8004f9:	ff 4d d8             	decl   -0x28(%ebp)
  8004fc:	78 1e                	js     80051c <vprintfmt+0x21d>
				if (altflag && (ch < ' ' || ch > '~'))
  8004fe:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800502:	74 d5                	je     8004d9 <vprintfmt+0x1da>
  800504:	0f be c0             	movsbl %al,%eax
  800507:	83 e8 20             	sub    $0x20,%eax
  80050a:	83 f8 5e             	cmp    $0x5e,%eax
  80050d:	76 ca                	jbe    8004d9 <vprintfmt+0x1da>
					putch('?', putdat);
  80050f:	83 ec 08             	sub    $0x8,%esp
  800512:	53                   	push   %ebx
  800513:	6a 3f                	push   $0x3f
  800515:	ff d6                	call   *%esi
  800517:	83 c4 10             	add    $0x10,%esp
  80051a:	eb c7                	jmp    8004e3 <vprintfmt+0x1e4>
  80051c:	89 cf                	mov    %ecx,%edi
  80051e:	eb 0c                	jmp    80052c <vprintfmt+0x22d>
				putch(' ', putdat);
  800520:	83 ec 08             	sub    $0x8,%esp
  800523:	53                   	push   %ebx
  800524:	6a 20                	push   $0x20
  800526:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800528:	4f                   	dec    %edi
  800529:	83 c4 10             	add    $0x10,%esp
  80052c:	85 ff                	test   %edi,%edi
  80052e:	7f f0                	jg     800520 <vprintfmt+0x221>
			if ((p = va_arg(ap, char *)) == NULL)
  800530:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800533:	89 45 14             	mov    %eax,0x14(%ebp)
  800536:	e9 33 01 00 00       	jmp    80066e <vprintfmt+0x36f>
  80053b:	89 cf                	mov    %ecx,%edi
  80053d:	eb ed                	jmp    80052c <vprintfmt+0x22d>
	if (lflag >= 2)
  80053f:	83 f9 01             	cmp    $0x1,%ecx
  800542:	7f 1b                	jg     80055f <vprintfmt+0x260>
	else if (lflag)
  800544:	85 c9                	test   %ecx,%ecx
  800546:	74 42                	je     80058a <vprintfmt+0x28b>
		return va_arg(*ap, long);
  800548:	8b 45 14             	mov    0x14(%ebp),%eax
  80054b:	8b 00                	mov    (%eax),%eax
  80054d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800550:	99                   	cltd   
  800551:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800554:	8b 45 14             	mov    0x14(%ebp),%eax
  800557:	8d 40 04             	lea    0x4(%eax),%eax
  80055a:	89 45 14             	mov    %eax,0x14(%ebp)
  80055d:	eb 17                	jmp    800576 <vprintfmt+0x277>
		return va_arg(*ap, long long);
  80055f:	8b 45 14             	mov    0x14(%ebp),%eax
  800562:	8b 50 04             	mov    0x4(%eax),%edx
  800565:	8b 00                	mov    (%eax),%eax
  800567:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80056a:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80056d:	8b 45 14             	mov    0x14(%ebp),%eax
  800570:	8d 40 08             	lea    0x8(%eax),%eax
  800573:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800576:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800579:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80057c:	85 c9                	test   %ecx,%ecx
  80057e:	78 21                	js     8005a1 <vprintfmt+0x2a2>
			base = 10;
  800580:	b8 0a 00 00 00       	mov    $0xa,%eax
  800585:	e9 ca 00 00 00       	jmp    800654 <vprintfmt+0x355>
		return va_arg(*ap, int);
  80058a:	8b 45 14             	mov    0x14(%ebp),%eax
  80058d:	8b 00                	mov    (%eax),%eax
  80058f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800592:	99                   	cltd   
  800593:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800596:	8b 45 14             	mov    0x14(%ebp),%eax
  800599:	8d 40 04             	lea    0x4(%eax),%eax
  80059c:	89 45 14             	mov    %eax,0x14(%ebp)
  80059f:	eb d5                	jmp    800576 <vprintfmt+0x277>
				putch('-', putdat);
  8005a1:	83 ec 08             	sub    $0x8,%esp
  8005a4:	53                   	push   %ebx
  8005a5:	6a 2d                	push   $0x2d
  8005a7:	ff d6                	call   *%esi
				num = -(long long) num;
  8005a9:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005ac:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8005af:	f7 da                	neg    %edx
  8005b1:	83 d1 00             	adc    $0x0,%ecx
  8005b4:	f7 d9                	neg    %ecx
  8005b6:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8005b9:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005be:	e9 91 00 00 00       	jmp    800654 <vprintfmt+0x355>
	if (lflag >= 2)
  8005c3:	83 f9 01             	cmp    $0x1,%ecx
  8005c6:	7f 1b                	jg     8005e3 <vprintfmt+0x2e4>
	else if (lflag)
  8005c8:	85 c9                	test   %ecx,%ecx
  8005ca:	74 2c                	je     8005f8 <vprintfmt+0x2f9>
		return va_arg(*ap, unsigned long);
  8005cc:	8b 45 14             	mov    0x14(%ebp),%eax
  8005cf:	8b 10                	mov    (%eax),%edx
  8005d1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005d6:	8d 40 04             	lea    0x4(%eax),%eax
  8005d9:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005dc:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  8005e1:	eb 71                	jmp    800654 <vprintfmt+0x355>
		return va_arg(*ap, unsigned long long);
  8005e3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e6:	8b 10                	mov    (%eax),%edx
  8005e8:	8b 48 04             	mov    0x4(%eax),%ecx
  8005eb:	8d 40 08             	lea    0x8(%eax),%eax
  8005ee:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005f1:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  8005f6:	eb 5c                	jmp    800654 <vprintfmt+0x355>
		return va_arg(*ap, unsigned int);
  8005f8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005fb:	8b 10                	mov    (%eax),%edx
  8005fd:	b9 00 00 00 00       	mov    $0x0,%ecx
  800602:	8d 40 04             	lea    0x4(%eax),%eax
  800605:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800608:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  80060d:	eb 45                	jmp    800654 <vprintfmt+0x355>
			putch('X', putdat);
  80060f:	83 ec 08             	sub    $0x8,%esp
  800612:	53                   	push   %ebx
  800613:	6a 58                	push   $0x58
  800615:	ff d6                	call   *%esi
			putch('X', putdat);
  800617:	83 c4 08             	add    $0x8,%esp
  80061a:	53                   	push   %ebx
  80061b:	6a 58                	push   $0x58
  80061d:	ff d6                	call   *%esi
			putch('X', putdat);
  80061f:	83 c4 08             	add    $0x8,%esp
  800622:	53                   	push   %ebx
  800623:	6a 58                	push   $0x58
  800625:	ff d6                	call   *%esi
			break;
  800627:	83 c4 10             	add    $0x10,%esp
  80062a:	eb 42                	jmp    80066e <vprintfmt+0x36f>
			putch('0', putdat);
  80062c:	83 ec 08             	sub    $0x8,%esp
  80062f:	53                   	push   %ebx
  800630:	6a 30                	push   $0x30
  800632:	ff d6                	call   *%esi
			putch('x', putdat);
  800634:	83 c4 08             	add    $0x8,%esp
  800637:	53                   	push   %ebx
  800638:	6a 78                	push   $0x78
  80063a:	ff d6                	call   *%esi
			num = (unsigned long long)
  80063c:	8b 45 14             	mov    0x14(%ebp),%eax
  80063f:	8b 10                	mov    (%eax),%edx
  800641:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800646:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800649:	8d 40 04             	lea    0x4(%eax),%eax
  80064c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80064f:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  800654:	83 ec 0c             	sub    $0xc,%esp
  800657:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  80065b:	57                   	push   %edi
  80065c:	ff 75 d4             	pushl  -0x2c(%ebp)
  80065f:	50                   	push   %eax
  800660:	51                   	push   %ecx
  800661:	52                   	push   %edx
  800662:	89 da                	mov    %ebx,%edx
  800664:	89 f0                	mov    %esi,%eax
  800666:	e8 b6 fb ff ff       	call   800221 <printnum>
			break;
  80066b:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  80066e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800671:	47                   	inc    %edi
  800672:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800676:	83 f8 25             	cmp    $0x25,%eax
  800679:	0f 84 97 fc ff ff    	je     800316 <vprintfmt+0x17>
			if (ch == '\0')
  80067f:	85 c0                	test   %eax,%eax
  800681:	0f 84 89 00 00 00    	je     800710 <vprintfmt+0x411>
			putch(ch, putdat);
  800687:	83 ec 08             	sub    $0x8,%esp
  80068a:	53                   	push   %ebx
  80068b:	50                   	push   %eax
  80068c:	ff d6                	call   *%esi
  80068e:	83 c4 10             	add    $0x10,%esp
  800691:	eb de                	jmp    800671 <vprintfmt+0x372>
	if (lflag >= 2)
  800693:	83 f9 01             	cmp    $0x1,%ecx
  800696:	7f 1b                	jg     8006b3 <vprintfmt+0x3b4>
	else if (lflag)
  800698:	85 c9                	test   %ecx,%ecx
  80069a:	74 2c                	je     8006c8 <vprintfmt+0x3c9>
		return va_arg(*ap, unsigned long);
  80069c:	8b 45 14             	mov    0x14(%ebp),%eax
  80069f:	8b 10                	mov    (%eax),%edx
  8006a1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006a6:	8d 40 04             	lea    0x4(%eax),%eax
  8006a9:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006ac:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  8006b1:	eb a1                	jmp    800654 <vprintfmt+0x355>
		return va_arg(*ap, unsigned long long);
  8006b3:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b6:	8b 10                	mov    (%eax),%edx
  8006b8:	8b 48 04             	mov    0x4(%eax),%ecx
  8006bb:	8d 40 08             	lea    0x8(%eax),%eax
  8006be:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006c1:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  8006c6:	eb 8c                	jmp    800654 <vprintfmt+0x355>
		return va_arg(*ap, unsigned int);
  8006c8:	8b 45 14             	mov    0x14(%ebp),%eax
  8006cb:	8b 10                	mov    (%eax),%edx
  8006cd:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006d2:	8d 40 04             	lea    0x4(%eax),%eax
  8006d5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006d8:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  8006dd:	e9 72 ff ff ff       	jmp    800654 <vprintfmt+0x355>
			putch(ch, putdat);
  8006e2:	83 ec 08             	sub    $0x8,%esp
  8006e5:	53                   	push   %ebx
  8006e6:	6a 25                	push   $0x25
  8006e8:	ff d6                	call   *%esi
			break;
  8006ea:	83 c4 10             	add    $0x10,%esp
  8006ed:	e9 7c ff ff ff       	jmp    80066e <vprintfmt+0x36f>
			putch('%', putdat);
  8006f2:	83 ec 08             	sub    $0x8,%esp
  8006f5:	53                   	push   %ebx
  8006f6:	6a 25                	push   $0x25
  8006f8:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006fa:	83 c4 10             	add    $0x10,%esp
  8006fd:	89 f8                	mov    %edi,%eax
  8006ff:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800703:	74 03                	je     800708 <vprintfmt+0x409>
  800705:	48                   	dec    %eax
  800706:	eb f7                	jmp    8006ff <vprintfmt+0x400>
  800708:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80070b:	e9 5e ff ff ff       	jmp    80066e <vprintfmt+0x36f>
}
  800710:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800713:	5b                   	pop    %ebx
  800714:	5e                   	pop    %esi
  800715:	5f                   	pop    %edi
  800716:	5d                   	pop    %ebp
  800717:	c3                   	ret    

00800718 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800718:	55                   	push   %ebp
  800719:	89 e5                	mov    %esp,%ebp
  80071b:	83 ec 18             	sub    $0x18,%esp
  80071e:	8b 45 08             	mov    0x8(%ebp),%eax
  800721:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800724:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800727:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80072b:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80072e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800735:	85 c0                	test   %eax,%eax
  800737:	74 26                	je     80075f <vsnprintf+0x47>
  800739:	85 d2                	test   %edx,%edx
  80073b:	7e 29                	jle    800766 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80073d:	ff 75 14             	pushl  0x14(%ebp)
  800740:	ff 75 10             	pushl  0x10(%ebp)
  800743:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800746:	50                   	push   %eax
  800747:	68 c6 02 80 00       	push   $0x8002c6
  80074c:	e8 ae fb ff ff       	call   8002ff <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800751:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800754:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800757:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80075a:	83 c4 10             	add    $0x10,%esp
}
  80075d:	c9                   	leave  
  80075e:	c3                   	ret    
		return -E_INVAL;
  80075f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800764:	eb f7                	jmp    80075d <vsnprintf+0x45>
  800766:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80076b:	eb f0                	jmp    80075d <vsnprintf+0x45>

0080076d <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80076d:	55                   	push   %ebp
  80076e:	89 e5                	mov    %esp,%ebp
  800770:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800773:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800776:	50                   	push   %eax
  800777:	ff 75 10             	pushl  0x10(%ebp)
  80077a:	ff 75 0c             	pushl  0xc(%ebp)
  80077d:	ff 75 08             	pushl  0x8(%ebp)
  800780:	e8 93 ff ff ff       	call   800718 <vsnprintf>
	va_end(ap);

	return rc;
}
  800785:	c9                   	leave  
  800786:	c3                   	ret    

00800787 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800787:	55                   	push   %ebp
  800788:	89 e5                	mov    %esp,%ebp
  80078a:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80078d:	b8 00 00 00 00       	mov    $0x0,%eax
  800792:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800796:	74 03                	je     80079b <strlen+0x14>
		n++;
  800798:	40                   	inc    %eax
  800799:	eb f7                	jmp    800792 <strlen+0xb>
	return n;
}
  80079b:	5d                   	pop    %ebp
  80079c:	c3                   	ret    

0080079d <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80079d:	55                   	push   %ebp
  80079e:	89 e5                	mov    %esp,%ebp
  8007a0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007a3:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007a6:	b8 00 00 00 00       	mov    $0x0,%eax
  8007ab:	39 d0                	cmp    %edx,%eax
  8007ad:	74 0b                	je     8007ba <strnlen+0x1d>
  8007af:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007b3:	74 03                	je     8007b8 <strnlen+0x1b>
		n++;
  8007b5:	40                   	inc    %eax
  8007b6:	eb f3                	jmp    8007ab <strnlen+0xe>
  8007b8:	89 c2                	mov    %eax,%edx
	return n;
}
  8007ba:	89 d0                	mov    %edx,%eax
  8007bc:	5d                   	pop    %ebp
  8007bd:	c3                   	ret    

008007be <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007be:	55                   	push   %ebp
  8007bf:	89 e5                	mov    %esp,%ebp
  8007c1:	53                   	push   %ebx
  8007c2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007c5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007c8:	b8 00 00 00 00       	mov    $0x0,%eax
  8007cd:	8a 14 03             	mov    (%ebx,%eax,1),%dl
  8007d0:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8007d3:	40                   	inc    %eax
  8007d4:	84 d2                	test   %dl,%dl
  8007d6:	75 f5                	jne    8007cd <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8007d8:	89 c8                	mov    %ecx,%eax
  8007da:	5b                   	pop    %ebx
  8007db:	5d                   	pop    %ebp
  8007dc:	c3                   	ret    

008007dd <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007dd:	55                   	push   %ebp
  8007de:	89 e5                	mov    %esp,%ebp
  8007e0:	53                   	push   %ebx
  8007e1:	83 ec 10             	sub    $0x10,%esp
  8007e4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007e7:	53                   	push   %ebx
  8007e8:	e8 9a ff ff ff       	call   800787 <strlen>
  8007ed:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  8007f0:	ff 75 0c             	pushl  0xc(%ebp)
  8007f3:	01 d8                	add    %ebx,%eax
  8007f5:	50                   	push   %eax
  8007f6:	e8 c3 ff ff ff       	call   8007be <strcpy>
	return dst;
}
  8007fb:	89 d8                	mov    %ebx,%eax
  8007fd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800800:	c9                   	leave  
  800801:	c3                   	ret    

00800802 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800802:	55                   	push   %ebp
  800803:	89 e5                	mov    %esp,%ebp
  800805:	53                   	push   %ebx
  800806:	8b 55 0c             	mov    0xc(%ebp),%edx
  800809:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80080c:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80080f:	8b 45 08             	mov    0x8(%ebp),%eax
  800812:	39 d8                	cmp    %ebx,%eax
  800814:	74 0e                	je     800824 <strncpy+0x22>
		*dst++ = *src;
  800816:	40                   	inc    %eax
  800817:	8a 0a                	mov    (%edx),%cl
  800819:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80081c:	80 f9 01             	cmp    $0x1,%cl
  80081f:	83 da ff             	sbb    $0xffffffff,%edx
  800822:	eb ee                	jmp    800812 <strncpy+0x10>
	}
	return ret;
}
  800824:	8b 45 08             	mov    0x8(%ebp),%eax
  800827:	5b                   	pop    %ebx
  800828:	5d                   	pop    %ebp
  800829:	c3                   	ret    

0080082a <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80082a:	55                   	push   %ebp
  80082b:	89 e5                	mov    %esp,%ebp
  80082d:	56                   	push   %esi
  80082e:	53                   	push   %ebx
  80082f:	8b 75 08             	mov    0x8(%ebp),%esi
  800832:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800835:	8b 45 10             	mov    0x10(%ebp),%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800838:	85 c0                	test   %eax,%eax
  80083a:	74 22                	je     80085e <strlcpy+0x34>
  80083c:	8d 44 06 ff          	lea    -0x1(%esi,%eax,1),%eax
  800840:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  800842:	39 c2                	cmp    %eax,%edx
  800844:	74 0f                	je     800855 <strlcpy+0x2b>
  800846:	8a 19                	mov    (%ecx),%bl
  800848:	84 db                	test   %bl,%bl
  80084a:	74 07                	je     800853 <strlcpy+0x29>
			*dst++ = *src++;
  80084c:	41                   	inc    %ecx
  80084d:	42                   	inc    %edx
  80084e:	88 5a ff             	mov    %bl,-0x1(%edx)
  800851:	eb ef                	jmp    800842 <strlcpy+0x18>
  800853:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800855:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800858:	29 f0                	sub    %esi,%eax
}
  80085a:	5b                   	pop    %ebx
  80085b:	5e                   	pop    %esi
  80085c:	5d                   	pop    %ebp
  80085d:	c3                   	ret    
  80085e:	89 f0                	mov    %esi,%eax
  800860:	eb f6                	jmp    800858 <strlcpy+0x2e>

00800862 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800862:	55                   	push   %ebp
  800863:	89 e5                	mov    %esp,%ebp
  800865:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800868:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80086b:	8a 01                	mov    (%ecx),%al
  80086d:	84 c0                	test   %al,%al
  80086f:	74 08                	je     800879 <strcmp+0x17>
  800871:	3a 02                	cmp    (%edx),%al
  800873:	75 04                	jne    800879 <strcmp+0x17>
		p++, q++;
  800875:	41                   	inc    %ecx
  800876:	42                   	inc    %edx
  800877:	eb f2                	jmp    80086b <strcmp+0x9>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800879:	0f b6 c0             	movzbl %al,%eax
  80087c:	0f b6 12             	movzbl (%edx),%edx
  80087f:	29 d0                	sub    %edx,%eax
}
  800881:	5d                   	pop    %ebp
  800882:	c3                   	ret    

00800883 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800883:	55                   	push   %ebp
  800884:	89 e5                	mov    %esp,%ebp
  800886:	53                   	push   %ebx
  800887:	8b 45 08             	mov    0x8(%ebp),%eax
  80088a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80088d:	89 c3                	mov    %eax,%ebx
  80088f:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800892:	eb 02                	jmp    800896 <strncmp+0x13>
		n--, p++, q++;
  800894:	40                   	inc    %eax
  800895:	42                   	inc    %edx
	while (n > 0 && *p && *p == *q)
  800896:	39 d8                	cmp    %ebx,%eax
  800898:	74 15                	je     8008af <strncmp+0x2c>
  80089a:	8a 08                	mov    (%eax),%cl
  80089c:	84 c9                	test   %cl,%cl
  80089e:	74 04                	je     8008a4 <strncmp+0x21>
  8008a0:	3a 0a                	cmp    (%edx),%cl
  8008a2:	74 f0                	je     800894 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008a4:	0f b6 00             	movzbl (%eax),%eax
  8008a7:	0f b6 12             	movzbl (%edx),%edx
  8008aa:	29 d0                	sub    %edx,%eax
}
  8008ac:	5b                   	pop    %ebx
  8008ad:	5d                   	pop    %ebp
  8008ae:	c3                   	ret    
		return 0;
  8008af:	b8 00 00 00 00       	mov    $0x0,%eax
  8008b4:	eb f6                	jmp    8008ac <strncmp+0x29>

008008b6 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008b6:	55                   	push   %ebp
  8008b7:	89 e5                	mov    %esp,%ebp
  8008b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8008bc:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8008bf:	8a 10                	mov    (%eax),%dl
  8008c1:	84 d2                	test   %dl,%dl
  8008c3:	74 07                	je     8008cc <strchr+0x16>
		if (*s == c)
  8008c5:	38 ca                	cmp    %cl,%dl
  8008c7:	74 08                	je     8008d1 <strchr+0x1b>
	for (; *s; s++)
  8008c9:	40                   	inc    %eax
  8008ca:	eb f3                	jmp    8008bf <strchr+0x9>
			return (char *) s;
	return 0;
  8008cc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008d1:	5d                   	pop    %ebp
  8008d2:	c3                   	ret    

008008d3 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008d3:	55                   	push   %ebp
  8008d4:	89 e5                	mov    %esp,%ebp
  8008d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d9:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8008dc:	8a 10                	mov    (%eax),%dl
  8008de:	84 d2                	test   %dl,%dl
  8008e0:	74 07                	je     8008e9 <strfind+0x16>
		if (*s == c)
  8008e2:	38 ca                	cmp    %cl,%dl
  8008e4:	74 03                	je     8008e9 <strfind+0x16>
	for (; *s; s++)
  8008e6:	40                   	inc    %eax
  8008e7:	eb f3                	jmp    8008dc <strfind+0x9>
			break;
	return (char *) s;
}
  8008e9:	5d                   	pop    %ebp
  8008ea:	c3                   	ret    

008008eb <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008eb:	55                   	push   %ebp
  8008ec:	89 e5                	mov    %esp,%ebp
  8008ee:	57                   	push   %edi
  8008ef:	56                   	push   %esi
  8008f0:	53                   	push   %ebx
  8008f1:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008f4:	85 c9                	test   %ecx,%ecx
  8008f6:	74 36                	je     80092e <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008f8:	89 c8                	mov    %ecx,%eax
  8008fa:	0b 45 08             	or     0x8(%ebp),%eax
  8008fd:	a8 03                	test   $0x3,%al
  8008ff:	75 24                	jne    800925 <memset+0x3a>
		c &= 0xFF;
  800901:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800905:	89 d3                	mov    %edx,%ebx
  800907:	c1 e3 08             	shl    $0x8,%ebx
  80090a:	89 d0                	mov    %edx,%eax
  80090c:	c1 e0 18             	shl    $0x18,%eax
  80090f:	89 d6                	mov    %edx,%esi
  800911:	c1 e6 10             	shl    $0x10,%esi
  800914:	09 f0                	or     %esi,%eax
  800916:	09 d0                	or     %edx,%eax
  800918:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80091a:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  80091d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800920:	fc                   	cld    
  800921:	f3 ab                	rep stos %eax,%es:(%edi)
  800923:	eb 09                	jmp    80092e <memset+0x43>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800925:	8b 7d 08             	mov    0x8(%ebp),%edi
  800928:	8b 45 0c             	mov    0xc(%ebp),%eax
  80092b:	fc                   	cld    
  80092c:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80092e:	8b 45 08             	mov    0x8(%ebp),%eax
  800931:	5b                   	pop    %ebx
  800932:	5e                   	pop    %esi
  800933:	5f                   	pop    %edi
  800934:	5d                   	pop    %ebp
  800935:	c3                   	ret    

00800936 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800936:	55                   	push   %ebp
  800937:	89 e5                	mov    %esp,%ebp
  800939:	57                   	push   %edi
  80093a:	56                   	push   %esi
  80093b:	8b 45 08             	mov    0x8(%ebp),%eax
  80093e:	8b 75 0c             	mov    0xc(%ebp),%esi
  800941:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800944:	39 c6                	cmp    %eax,%esi
  800946:	73 30                	jae    800978 <memmove+0x42>
  800948:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80094b:	39 c2                	cmp    %eax,%edx
  80094d:	76 29                	jbe    800978 <memmove+0x42>
		s += n;
		d += n;
  80094f:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800952:	89 fe                	mov    %edi,%esi
  800954:	09 ce                	or     %ecx,%esi
  800956:	09 d6                	or     %edx,%esi
  800958:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80095e:	75 0e                	jne    80096e <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800960:	83 ef 04             	sub    $0x4,%edi
  800963:	8d 72 fc             	lea    -0x4(%edx),%esi
  800966:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800969:	fd                   	std    
  80096a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80096c:	eb 07                	jmp    800975 <memmove+0x3f>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80096e:	4f                   	dec    %edi
  80096f:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800972:	fd                   	std    
  800973:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800975:	fc                   	cld    
  800976:	eb 1a                	jmp    800992 <memmove+0x5c>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800978:	89 c2                	mov    %eax,%edx
  80097a:	09 ca                	or     %ecx,%edx
  80097c:	09 f2                	or     %esi,%edx
  80097e:	f6 c2 03             	test   $0x3,%dl
  800981:	75 0a                	jne    80098d <memmove+0x57>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800983:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800986:	89 c7                	mov    %eax,%edi
  800988:	fc                   	cld    
  800989:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80098b:	eb 05                	jmp    800992 <memmove+0x5c>
		else
			asm volatile("cld; rep movsb\n"
  80098d:	89 c7                	mov    %eax,%edi
  80098f:	fc                   	cld    
  800990:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800992:	5e                   	pop    %esi
  800993:	5f                   	pop    %edi
  800994:	5d                   	pop    %ebp
  800995:	c3                   	ret    

00800996 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800996:	55                   	push   %ebp
  800997:	89 e5                	mov    %esp,%ebp
  800999:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  80099c:	ff 75 10             	pushl  0x10(%ebp)
  80099f:	ff 75 0c             	pushl  0xc(%ebp)
  8009a2:	ff 75 08             	pushl  0x8(%ebp)
  8009a5:	e8 8c ff ff ff       	call   800936 <memmove>
}
  8009aa:	c9                   	leave  
  8009ab:	c3                   	ret    

008009ac <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009ac:	55                   	push   %ebp
  8009ad:	89 e5                	mov    %esp,%ebp
  8009af:	56                   	push   %esi
  8009b0:	53                   	push   %ebx
  8009b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009b7:	89 c6                	mov    %eax,%esi
  8009b9:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009bc:	39 f0                	cmp    %esi,%eax
  8009be:	74 16                	je     8009d6 <memcmp+0x2a>
		if (*s1 != *s2)
  8009c0:	8a 08                	mov    (%eax),%cl
  8009c2:	8a 1a                	mov    (%edx),%bl
  8009c4:	38 d9                	cmp    %bl,%cl
  8009c6:	75 04                	jne    8009cc <memcmp+0x20>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  8009c8:	40                   	inc    %eax
  8009c9:	42                   	inc    %edx
  8009ca:	eb f0                	jmp    8009bc <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  8009cc:	0f b6 c1             	movzbl %cl,%eax
  8009cf:	0f b6 db             	movzbl %bl,%ebx
  8009d2:	29 d8                	sub    %ebx,%eax
  8009d4:	eb 05                	jmp    8009db <memcmp+0x2f>
	}

	return 0;
  8009d6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009db:	5b                   	pop    %ebx
  8009dc:	5e                   	pop    %esi
  8009dd:	5d                   	pop    %ebp
  8009de:	c3                   	ret    

008009df <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009df:	55                   	push   %ebp
  8009e0:	89 e5                	mov    %esp,%ebp
  8009e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8009e8:	89 c2                	mov    %eax,%edx
  8009ea:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8009ed:	39 d0                	cmp    %edx,%eax
  8009ef:	73 07                	jae    8009f8 <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009f1:	38 08                	cmp    %cl,(%eax)
  8009f3:	74 03                	je     8009f8 <memfind+0x19>
	for (; s < ends; s++)
  8009f5:	40                   	inc    %eax
  8009f6:	eb f5                	jmp    8009ed <memfind+0xe>
			break;
	return (void *) s;
}
  8009f8:	5d                   	pop    %ebp
  8009f9:	c3                   	ret    

008009fa <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009fa:	55                   	push   %ebp
  8009fb:	89 e5                	mov    %esp,%ebp
  8009fd:	57                   	push   %edi
  8009fe:	56                   	push   %esi
  8009ff:	53                   	push   %ebx
  800a00:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a03:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a06:	eb 01                	jmp    800a09 <strtol+0xf>
		s++;
  800a08:	41                   	inc    %ecx
	while (*s == ' ' || *s == '\t')
  800a09:	8a 01                	mov    (%ecx),%al
  800a0b:	3c 20                	cmp    $0x20,%al
  800a0d:	74 f9                	je     800a08 <strtol+0xe>
  800a0f:	3c 09                	cmp    $0x9,%al
  800a11:	74 f5                	je     800a08 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800a13:	3c 2b                	cmp    $0x2b,%al
  800a15:	74 24                	je     800a3b <strtol+0x41>
		s++;
	else if (*s == '-')
  800a17:	3c 2d                	cmp    $0x2d,%al
  800a19:	74 28                	je     800a43 <strtol+0x49>
	int neg = 0;
  800a1b:	bf 00 00 00 00       	mov    $0x0,%edi
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a20:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a26:	75 09                	jne    800a31 <strtol+0x37>
  800a28:	80 39 30             	cmpb   $0x30,(%ecx)
  800a2b:	74 1e                	je     800a4b <strtol+0x51>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a2d:	85 db                	test   %ebx,%ebx
  800a2f:	74 36                	je     800a67 <strtol+0x6d>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a31:	b8 00 00 00 00       	mov    $0x0,%eax
  800a36:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800a39:	eb 45                	jmp    800a80 <strtol+0x86>
		s++;
  800a3b:	41                   	inc    %ecx
	int neg = 0;
  800a3c:	bf 00 00 00 00       	mov    $0x0,%edi
  800a41:	eb dd                	jmp    800a20 <strtol+0x26>
		s++, neg = 1;
  800a43:	41                   	inc    %ecx
  800a44:	bf 01 00 00 00       	mov    $0x1,%edi
  800a49:	eb d5                	jmp    800a20 <strtol+0x26>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a4b:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a4f:	74 0c                	je     800a5d <strtol+0x63>
	else if (base == 0 && s[0] == '0')
  800a51:	85 db                	test   %ebx,%ebx
  800a53:	75 dc                	jne    800a31 <strtol+0x37>
		s++, base = 8;
  800a55:	41                   	inc    %ecx
  800a56:	bb 08 00 00 00       	mov    $0x8,%ebx
  800a5b:	eb d4                	jmp    800a31 <strtol+0x37>
		s += 2, base = 16;
  800a5d:	83 c1 02             	add    $0x2,%ecx
  800a60:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a65:	eb ca                	jmp    800a31 <strtol+0x37>
		base = 10;
  800a67:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800a6c:	eb c3                	jmp    800a31 <strtol+0x37>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800a6e:	0f be d2             	movsbl %dl,%edx
  800a71:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800a74:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a77:	7d 37                	jge    800ab0 <strtol+0xb6>
			break;
		s++, val = (val * base) + dig;
  800a79:	41                   	inc    %ecx
  800a7a:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a7e:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800a80:	8a 11                	mov    (%ecx),%dl
  800a82:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a85:	89 f3                	mov    %esi,%ebx
  800a87:	80 fb 09             	cmp    $0x9,%bl
  800a8a:	76 e2                	jbe    800a6e <strtol+0x74>
		else if (*s >= 'a' && *s <= 'z')
  800a8c:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a8f:	89 f3                	mov    %esi,%ebx
  800a91:	80 fb 19             	cmp    $0x19,%bl
  800a94:	77 08                	ja     800a9e <strtol+0xa4>
			dig = *s - 'a' + 10;
  800a96:	0f be d2             	movsbl %dl,%edx
  800a99:	83 ea 57             	sub    $0x57,%edx
  800a9c:	eb d6                	jmp    800a74 <strtol+0x7a>
		else if (*s >= 'A' && *s <= 'Z')
  800a9e:	8d 72 bf             	lea    -0x41(%edx),%esi
  800aa1:	89 f3                	mov    %esi,%ebx
  800aa3:	80 fb 19             	cmp    $0x19,%bl
  800aa6:	77 08                	ja     800ab0 <strtol+0xb6>
			dig = *s - 'A' + 10;
  800aa8:	0f be d2             	movsbl %dl,%edx
  800aab:	83 ea 37             	sub    $0x37,%edx
  800aae:	eb c4                	jmp    800a74 <strtol+0x7a>
		// we don't properly detect overflow!
	}

	if (endptr)
  800ab0:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ab4:	74 05                	je     800abb <strtol+0xc1>
		*endptr = (char *) s;
  800ab6:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ab9:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800abb:	85 ff                	test   %edi,%edi
  800abd:	74 02                	je     800ac1 <strtol+0xc7>
  800abf:	f7 d8                	neg    %eax
}
  800ac1:	5b                   	pop    %ebx
  800ac2:	5e                   	pop    %esi
  800ac3:	5f                   	pop    %edi
  800ac4:	5d                   	pop    %ebp
  800ac5:	c3                   	ret    
  800ac6:	66 90                	xchg   %ax,%ax

00800ac8 <__udivdi3>:
  800ac8:	55                   	push   %ebp
  800ac9:	57                   	push   %edi
  800aca:	56                   	push   %esi
  800acb:	53                   	push   %ebx
  800acc:	83 ec 1c             	sub    $0x1c,%esp
  800acf:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800ad3:	8b 74 24 34          	mov    0x34(%esp),%esi
  800ad7:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800adb:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800adf:	85 d2                	test   %edx,%edx
  800ae1:	75 19                	jne    800afc <__udivdi3+0x34>
  800ae3:	39 f7                	cmp    %esi,%edi
  800ae5:	76 45                	jbe    800b2c <__udivdi3+0x64>
  800ae7:	89 e8                	mov    %ebp,%eax
  800ae9:	89 f2                	mov    %esi,%edx
  800aeb:	f7 f7                	div    %edi
  800aed:	31 db                	xor    %ebx,%ebx
  800aef:	89 da                	mov    %ebx,%edx
  800af1:	83 c4 1c             	add    $0x1c,%esp
  800af4:	5b                   	pop    %ebx
  800af5:	5e                   	pop    %esi
  800af6:	5f                   	pop    %edi
  800af7:	5d                   	pop    %ebp
  800af8:	c3                   	ret    
  800af9:	8d 76 00             	lea    0x0(%esi),%esi
  800afc:	39 f2                	cmp    %esi,%edx
  800afe:	76 10                	jbe    800b10 <__udivdi3+0x48>
  800b00:	31 db                	xor    %ebx,%ebx
  800b02:	31 c0                	xor    %eax,%eax
  800b04:	89 da                	mov    %ebx,%edx
  800b06:	83 c4 1c             	add    $0x1c,%esp
  800b09:	5b                   	pop    %ebx
  800b0a:	5e                   	pop    %esi
  800b0b:	5f                   	pop    %edi
  800b0c:	5d                   	pop    %ebp
  800b0d:	c3                   	ret    
  800b0e:	66 90                	xchg   %ax,%ax
  800b10:	0f bd da             	bsr    %edx,%ebx
  800b13:	83 f3 1f             	xor    $0x1f,%ebx
  800b16:	75 3c                	jne    800b54 <__udivdi3+0x8c>
  800b18:	39 f2                	cmp    %esi,%edx
  800b1a:	72 08                	jb     800b24 <__udivdi3+0x5c>
  800b1c:	39 ef                	cmp    %ebp,%edi
  800b1e:	0f 87 9c 00 00 00    	ja     800bc0 <__udivdi3+0xf8>
  800b24:	b8 01 00 00 00       	mov    $0x1,%eax
  800b29:	eb d9                	jmp    800b04 <__udivdi3+0x3c>
  800b2b:	90                   	nop
  800b2c:	89 f9                	mov    %edi,%ecx
  800b2e:	85 ff                	test   %edi,%edi
  800b30:	75 0b                	jne    800b3d <__udivdi3+0x75>
  800b32:	b8 01 00 00 00       	mov    $0x1,%eax
  800b37:	31 d2                	xor    %edx,%edx
  800b39:	f7 f7                	div    %edi
  800b3b:	89 c1                	mov    %eax,%ecx
  800b3d:	31 d2                	xor    %edx,%edx
  800b3f:	89 f0                	mov    %esi,%eax
  800b41:	f7 f1                	div    %ecx
  800b43:	89 c3                	mov    %eax,%ebx
  800b45:	89 e8                	mov    %ebp,%eax
  800b47:	f7 f1                	div    %ecx
  800b49:	89 da                	mov    %ebx,%edx
  800b4b:	83 c4 1c             	add    $0x1c,%esp
  800b4e:	5b                   	pop    %ebx
  800b4f:	5e                   	pop    %esi
  800b50:	5f                   	pop    %edi
  800b51:	5d                   	pop    %ebp
  800b52:	c3                   	ret    
  800b53:	90                   	nop
  800b54:	b8 20 00 00 00       	mov    $0x20,%eax
  800b59:	29 d8                	sub    %ebx,%eax
  800b5b:	88 d9                	mov    %bl,%cl
  800b5d:	d3 e2                	shl    %cl,%edx
  800b5f:	89 54 24 08          	mov    %edx,0x8(%esp)
  800b63:	89 fa                	mov    %edi,%edx
  800b65:	88 c1                	mov    %al,%cl
  800b67:	d3 ea                	shr    %cl,%edx
  800b69:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800b6d:	09 d1                	or     %edx,%ecx
  800b6f:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800b73:	88 d9                	mov    %bl,%cl
  800b75:	d3 e7                	shl    %cl,%edi
  800b77:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800b7b:	89 f7                	mov    %esi,%edi
  800b7d:	88 c1                	mov    %al,%cl
  800b7f:	d3 ef                	shr    %cl,%edi
  800b81:	88 d9                	mov    %bl,%cl
  800b83:	d3 e6                	shl    %cl,%esi
  800b85:	89 ea                	mov    %ebp,%edx
  800b87:	88 c1                	mov    %al,%cl
  800b89:	d3 ea                	shr    %cl,%edx
  800b8b:	09 d6                	or     %edx,%esi
  800b8d:	89 f0                	mov    %esi,%eax
  800b8f:	89 fa                	mov    %edi,%edx
  800b91:	f7 74 24 08          	divl   0x8(%esp)
  800b95:	89 d7                	mov    %edx,%edi
  800b97:	89 c6                	mov    %eax,%esi
  800b99:	f7 64 24 0c          	mull   0xc(%esp)
  800b9d:	39 d7                	cmp    %edx,%edi
  800b9f:	72 13                	jb     800bb4 <__udivdi3+0xec>
  800ba1:	74 09                	je     800bac <__udivdi3+0xe4>
  800ba3:	89 f0                	mov    %esi,%eax
  800ba5:	31 db                	xor    %ebx,%ebx
  800ba7:	e9 58 ff ff ff       	jmp    800b04 <__udivdi3+0x3c>
  800bac:	88 d9                	mov    %bl,%cl
  800bae:	d3 e5                	shl    %cl,%ebp
  800bb0:	39 c5                	cmp    %eax,%ebp
  800bb2:	73 ef                	jae    800ba3 <__udivdi3+0xdb>
  800bb4:	8d 46 ff             	lea    -0x1(%esi),%eax
  800bb7:	31 db                	xor    %ebx,%ebx
  800bb9:	e9 46 ff ff ff       	jmp    800b04 <__udivdi3+0x3c>
  800bbe:	66 90                	xchg   %ax,%ax
  800bc0:	31 c0                	xor    %eax,%eax
  800bc2:	e9 3d ff ff ff       	jmp    800b04 <__udivdi3+0x3c>
  800bc7:	90                   	nop

00800bc8 <__umoddi3>:
  800bc8:	55                   	push   %ebp
  800bc9:	57                   	push   %edi
  800bca:	56                   	push   %esi
  800bcb:	53                   	push   %ebx
  800bcc:	83 ec 1c             	sub    $0x1c,%esp
  800bcf:	8b 74 24 30          	mov    0x30(%esp),%esi
  800bd3:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800bd7:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800bdb:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  800bdf:	85 c0                	test   %eax,%eax
  800be1:	75 19                	jne    800bfc <__umoddi3+0x34>
  800be3:	39 df                	cmp    %ebx,%edi
  800be5:	76 51                	jbe    800c38 <__umoddi3+0x70>
  800be7:	89 f0                	mov    %esi,%eax
  800be9:	89 da                	mov    %ebx,%edx
  800beb:	f7 f7                	div    %edi
  800bed:	89 d0                	mov    %edx,%eax
  800bef:	31 d2                	xor    %edx,%edx
  800bf1:	83 c4 1c             	add    $0x1c,%esp
  800bf4:	5b                   	pop    %ebx
  800bf5:	5e                   	pop    %esi
  800bf6:	5f                   	pop    %edi
  800bf7:	5d                   	pop    %ebp
  800bf8:	c3                   	ret    
  800bf9:	8d 76 00             	lea    0x0(%esi),%esi
  800bfc:	89 f2                	mov    %esi,%edx
  800bfe:	39 d8                	cmp    %ebx,%eax
  800c00:	76 0e                	jbe    800c10 <__umoddi3+0x48>
  800c02:	89 f0                	mov    %esi,%eax
  800c04:	89 da                	mov    %ebx,%edx
  800c06:	83 c4 1c             	add    $0x1c,%esp
  800c09:	5b                   	pop    %ebx
  800c0a:	5e                   	pop    %esi
  800c0b:	5f                   	pop    %edi
  800c0c:	5d                   	pop    %ebp
  800c0d:	c3                   	ret    
  800c0e:	66 90                	xchg   %ax,%ax
  800c10:	0f bd e8             	bsr    %eax,%ebp
  800c13:	83 f5 1f             	xor    $0x1f,%ebp
  800c16:	75 44                	jne    800c5c <__umoddi3+0x94>
  800c18:	39 d8                	cmp    %ebx,%eax
  800c1a:	72 06                	jb     800c22 <__umoddi3+0x5a>
  800c1c:	89 d9                	mov    %ebx,%ecx
  800c1e:	39 f7                	cmp    %esi,%edi
  800c20:	77 08                	ja     800c2a <__umoddi3+0x62>
  800c22:	29 fe                	sub    %edi,%esi
  800c24:	19 c3                	sbb    %eax,%ebx
  800c26:	89 f2                	mov    %esi,%edx
  800c28:	89 d9                	mov    %ebx,%ecx
  800c2a:	89 d0                	mov    %edx,%eax
  800c2c:	89 ca                	mov    %ecx,%edx
  800c2e:	83 c4 1c             	add    $0x1c,%esp
  800c31:	5b                   	pop    %ebx
  800c32:	5e                   	pop    %esi
  800c33:	5f                   	pop    %edi
  800c34:	5d                   	pop    %ebp
  800c35:	c3                   	ret    
  800c36:	66 90                	xchg   %ax,%ax
  800c38:	89 fd                	mov    %edi,%ebp
  800c3a:	85 ff                	test   %edi,%edi
  800c3c:	75 0b                	jne    800c49 <__umoddi3+0x81>
  800c3e:	b8 01 00 00 00       	mov    $0x1,%eax
  800c43:	31 d2                	xor    %edx,%edx
  800c45:	f7 f7                	div    %edi
  800c47:	89 c5                	mov    %eax,%ebp
  800c49:	89 d8                	mov    %ebx,%eax
  800c4b:	31 d2                	xor    %edx,%edx
  800c4d:	f7 f5                	div    %ebp
  800c4f:	89 f0                	mov    %esi,%eax
  800c51:	f7 f5                	div    %ebp
  800c53:	89 d0                	mov    %edx,%eax
  800c55:	31 d2                	xor    %edx,%edx
  800c57:	eb 98                	jmp    800bf1 <__umoddi3+0x29>
  800c59:	8d 76 00             	lea    0x0(%esi),%esi
  800c5c:	ba 20 00 00 00       	mov    $0x20,%edx
  800c61:	29 ea                	sub    %ebp,%edx
  800c63:	89 e9                	mov    %ebp,%ecx
  800c65:	d3 e0                	shl    %cl,%eax
  800c67:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c6b:	89 f8                	mov    %edi,%eax
  800c6d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800c71:	88 d1                	mov    %dl,%cl
  800c73:	d3 e8                	shr    %cl,%eax
  800c75:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800c79:	09 c1                	or     %eax,%ecx
  800c7b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800c7f:	89 e9                	mov    %ebp,%ecx
  800c81:	d3 e7                	shl    %cl,%edi
  800c83:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800c87:	89 d8                	mov    %ebx,%eax
  800c89:	8b 54 24 04          	mov    0x4(%esp),%edx
  800c8d:	88 d1                	mov    %dl,%cl
  800c8f:	d3 e8                	shr    %cl,%eax
  800c91:	89 c7                	mov    %eax,%edi
  800c93:	89 e9                	mov    %ebp,%ecx
  800c95:	d3 e3                	shl    %cl,%ebx
  800c97:	89 f0                	mov    %esi,%eax
  800c99:	88 d1                	mov    %dl,%cl
  800c9b:	d3 e8                	shr    %cl,%eax
  800c9d:	09 d8                	or     %ebx,%eax
  800c9f:	89 e9                	mov    %ebp,%ecx
  800ca1:	d3 e6                	shl    %cl,%esi
  800ca3:	89 f3                	mov    %esi,%ebx
  800ca5:	89 fa                	mov    %edi,%edx
  800ca7:	f7 74 24 08          	divl   0x8(%esp)
  800cab:	89 d1                	mov    %edx,%ecx
  800cad:	f7 64 24 0c          	mull   0xc(%esp)
  800cb1:	89 c6                	mov    %eax,%esi
  800cb3:	89 d7                	mov    %edx,%edi
  800cb5:	39 d1                	cmp    %edx,%ecx
  800cb7:	72 27                	jb     800ce0 <__umoddi3+0x118>
  800cb9:	74 21                	je     800cdc <__umoddi3+0x114>
  800cbb:	89 ca                	mov    %ecx,%edx
  800cbd:	29 f3                	sub    %esi,%ebx
  800cbf:	19 fa                	sbb    %edi,%edx
  800cc1:	89 d0                	mov    %edx,%eax
  800cc3:	8a 4c 24 04          	mov    0x4(%esp),%cl
  800cc7:	d3 e0                	shl    %cl,%eax
  800cc9:	89 e9                	mov    %ebp,%ecx
  800ccb:	d3 eb                	shr    %cl,%ebx
  800ccd:	09 d8                	or     %ebx,%eax
  800ccf:	d3 ea                	shr    %cl,%edx
  800cd1:	83 c4 1c             	add    $0x1c,%esp
  800cd4:	5b                   	pop    %ebx
  800cd5:	5e                   	pop    %esi
  800cd6:	5f                   	pop    %edi
  800cd7:	5d                   	pop    %ebp
  800cd8:	c3                   	ret    
  800cd9:	8d 76 00             	lea    0x0(%esi),%esi
  800cdc:	39 c3                	cmp    %eax,%ebx
  800cde:	73 db                	jae    800cbb <__umoddi3+0xf3>
  800ce0:	2b 44 24 0c          	sub    0xc(%esp),%eax
  800ce4:	1b 54 24 08          	sbb    0x8(%esp),%edx
  800ce8:	89 d7                	mov    %edx,%edi
  800cea:	89 c6                	mov    %eax,%esi
  800cec:	eb cd                	jmp    800cbb <__umoddi3+0xf3>
