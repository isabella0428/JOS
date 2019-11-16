
obj/user/faultwrite:     file format elf32-i386


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
  80002c:	e8 0d 00 00 00       	call   80003e <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
	*(unsigned*)0 = 0;
  800033:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
  80003a:	00 00 00 
}
  80003d:	c3                   	ret    

0080003e <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80003e:	55                   	push   %ebp
  80003f:	89 e5                	mov    %esp,%ebp
  800041:	83 ec 08             	sub    $0x8,%esp
  800044:	8b 45 08             	mov    0x8(%ebp),%eax
  800047:	8b 55 0c             	mov    0xc(%ebp),%edx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  80004a:	c7 05 04 10 80 00 00 	movl   $0x0,0x801004
  800051:	00 00 00 

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800054:	85 c0                	test   %eax,%eax
  800056:	7e 08                	jle    800060 <libmain+0x22>
		binaryname = argv[0];
  800058:	8b 0a                	mov    (%edx),%ecx
  80005a:	89 0d 00 10 80 00    	mov    %ecx,0x801000

	// call user main routine
	umain(argc, argv);
  800060:	83 ec 08             	sub    $0x8,%esp
  800063:	52                   	push   %edx
  800064:	50                   	push   %eax
  800065:	e8 c9 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80006a:	e8 05 00 00 00       	call   800074 <exit>
}
  80006f:	83 c4 10             	add    $0x10,%esp
  800072:	c9                   	leave  
  800073:	c3                   	ret    

00800074 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800074:	55                   	push   %ebp
  800075:	89 e5                	mov    %esp,%ebp
  800077:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  80007a:	6a 00                	push   $0x0
  80007c:	e8 42 00 00 00       	call   8000c3 <sys_env_destroy>
}
  800081:	83 c4 10             	add    $0x10,%esp
  800084:	c9                   	leave  
  800085:	c3                   	ret    

00800086 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800086:	55                   	push   %ebp
  800087:	89 e5                	mov    %esp,%ebp
  800089:	57                   	push   %edi
  80008a:	56                   	push   %esi
  80008b:	53                   	push   %ebx
	asm volatile("int %1\n"
  80008c:	b8 00 00 00 00       	mov    $0x0,%eax
  800091:	8b 55 08             	mov    0x8(%ebp),%edx
  800094:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800097:	89 c3                	mov    %eax,%ebx
  800099:	89 c7                	mov    %eax,%edi
  80009b:	89 c6                	mov    %eax,%esi
  80009d:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  80009f:	5b                   	pop    %ebx
  8000a0:	5e                   	pop    %esi
  8000a1:	5f                   	pop    %edi
  8000a2:	5d                   	pop    %ebp
  8000a3:	c3                   	ret    

008000a4 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000a4:	55                   	push   %ebp
  8000a5:	89 e5                	mov    %esp,%ebp
  8000a7:	57                   	push   %edi
  8000a8:	56                   	push   %esi
  8000a9:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000aa:	ba 00 00 00 00       	mov    $0x0,%edx
  8000af:	b8 01 00 00 00       	mov    $0x1,%eax
  8000b4:	89 d1                	mov    %edx,%ecx
  8000b6:	89 d3                	mov    %edx,%ebx
  8000b8:	89 d7                	mov    %edx,%edi
  8000ba:	89 d6                	mov    %edx,%esi
  8000bc:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000be:	5b                   	pop    %ebx
  8000bf:	5e                   	pop    %esi
  8000c0:	5f                   	pop    %edi
  8000c1:	5d                   	pop    %ebp
  8000c2:	c3                   	ret    

008000c3 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000c3:	55                   	push   %ebp
  8000c4:	89 e5                	mov    %esp,%ebp
  8000c6:	57                   	push   %edi
  8000c7:	56                   	push   %esi
  8000c8:	53                   	push   %ebx
  8000c9:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8000cc:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000d1:	8b 55 08             	mov    0x8(%ebp),%edx
  8000d4:	b8 03 00 00 00       	mov    $0x3,%eax
  8000d9:	89 cb                	mov    %ecx,%ebx
  8000db:	89 cf                	mov    %ecx,%edi
  8000dd:	89 ce                	mov    %ecx,%esi
  8000df:	cd 30                	int    $0x30
	if(check && ret > 0)
  8000e1:	85 c0                	test   %eax,%eax
  8000e3:	7f 08                	jg     8000ed <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  8000e5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000e8:	5b                   	pop    %ebx
  8000e9:	5e                   	pop    %esi
  8000ea:	5f                   	pop    %edi
  8000eb:	5d                   	pop    %ebp
  8000ec:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8000ed:	83 ec 0c             	sub    $0xc,%esp
  8000f0:	50                   	push   %eax
  8000f1:	6a 03                	push   $0x3
  8000f3:	68 ea 0c 80 00       	push   $0x800cea
  8000f8:	6a 23                	push   $0x23
  8000fa:	68 07 0d 80 00       	push   $0x800d07
  8000ff:	e8 1f 00 00 00       	call   800123 <_panic>

00800104 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800104:	55                   	push   %ebp
  800105:	89 e5                	mov    %esp,%ebp
  800107:	57                   	push   %edi
  800108:	56                   	push   %esi
  800109:	53                   	push   %ebx
	asm volatile("int %1\n"
  80010a:	ba 00 00 00 00       	mov    $0x0,%edx
  80010f:	b8 02 00 00 00       	mov    $0x2,%eax
  800114:	89 d1                	mov    %edx,%ecx
  800116:	89 d3                	mov    %edx,%ebx
  800118:	89 d7                	mov    %edx,%edi
  80011a:	89 d6                	mov    %edx,%esi
  80011c:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80011e:	5b                   	pop    %ebx
  80011f:	5e                   	pop    %esi
  800120:	5f                   	pop    %edi
  800121:	5d                   	pop    %ebp
  800122:	c3                   	ret    

00800123 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800123:	55                   	push   %ebp
  800124:	89 e5                	mov    %esp,%ebp
  800126:	56                   	push   %esi
  800127:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800128:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80012b:	8b 35 00 10 80 00    	mov    0x801000,%esi
  800131:	e8 ce ff ff ff       	call   800104 <sys_getenvid>
  800136:	83 ec 0c             	sub    $0xc,%esp
  800139:	ff 75 0c             	pushl  0xc(%ebp)
  80013c:	ff 75 08             	pushl  0x8(%ebp)
  80013f:	56                   	push   %esi
  800140:	50                   	push   %eax
  800141:	68 18 0d 80 00       	push   $0x800d18
  800146:	e8 b2 00 00 00       	call   8001fd <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80014b:	83 c4 18             	add    $0x18,%esp
  80014e:	53                   	push   %ebx
  80014f:	ff 75 10             	pushl  0x10(%ebp)
  800152:	e8 55 00 00 00       	call   8001ac <vcprintf>
	cprintf("\n");
  800157:	c7 04 24 3c 0d 80 00 	movl   $0x800d3c,(%esp)
  80015e:	e8 9a 00 00 00       	call   8001fd <cprintf>
  800163:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800166:	cc                   	int3   
  800167:	eb fd                	jmp    800166 <_panic+0x43>

00800169 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800169:	55                   	push   %ebp
  80016a:	89 e5                	mov    %esp,%ebp
  80016c:	53                   	push   %ebx
  80016d:	83 ec 04             	sub    $0x4,%esp
  800170:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800173:	8b 13                	mov    (%ebx),%edx
  800175:	8d 42 01             	lea    0x1(%edx),%eax
  800178:	89 03                	mov    %eax,(%ebx)
  80017a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80017d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800181:	3d ff 00 00 00       	cmp    $0xff,%eax
  800186:	74 08                	je     800190 <putch+0x27>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800188:	ff 43 04             	incl   0x4(%ebx)
}
  80018b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80018e:	c9                   	leave  
  80018f:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800190:	83 ec 08             	sub    $0x8,%esp
  800193:	68 ff 00 00 00       	push   $0xff
  800198:	8d 43 08             	lea    0x8(%ebx),%eax
  80019b:	50                   	push   %eax
  80019c:	e8 e5 fe ff ff       	call   800086 <sys_cputs>
		b->idx = 0;
  8001a1:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001a7:	83 c4 10             	add    $0x10,%esp
  8001aa:	eb dc                	jmp    800188 <putch+0x1f>

008001ac <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001ac:	55                   	push   %ebp
  8001ad:	89 e5                	mov    %esp,%ebp
  8001af:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001b5:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001bc:	00 00 00 
	b.cnt = 0;
  8001bf:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001c6:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001c9:	ff 75 0c             	pushl  0xc(%ebp)
  8001cc:	ff 75 08             	pushl  0x8(%ebp)
  8001cf:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001d5:	50                   	push   %eax
  8001d6:	68 69 01 80 00       	push   $0x800169
  8001db:	e8 0f 01 00 00       	call   8002ef <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001e0:	83 c4 08             	add    $0x8,%esp
  8001e3:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001e9:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001ef:	50                   	push   %eax
  8001f0:	e8 91 fe ff ff       	call   800086 <sys_cputs>

	return b.cnt;
}
  8001f5:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001fb:	c9                   	leave  
  8001fc:	c3                   	ret    

008001fd <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001fd:	55                   	push   %ebp
  8001fe:	89 e5                	mov    %esp,%ebp
  800200:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800203:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800206:	50                   	push   %eax
  800207:	ff 75 08             	pushl  0x8(%ebp)
  80020a:	e8 9d ff ff ff       	call   8001ac <vcprintf>
	va_end(ap);

	return cnt;
}
  80020f:	c9                   	leave  
  800210:	c3                   	ret    

00800211 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800211:	55                   	push   %ebp
  800212:	89 e5                	mov    %esp,%ebp
  800214:	57                   	push   %edi
  800215:	56                   	push   %esi
  800216:	53                   	push   %ebx
  800217:	83 ec 1c             	sub    $0x1c,%esp
  80021a:	89 c7                	mov    %eax,%edi
  80021c:	89 d6                	mov    %edx,%esi
  80021e:	8b 45 08             	mov    0x8(%ebp),%eax
  800221:	8b 55 0c             	mov    0xc(%ebp),%edx
  800224:	89 d1                	mov    %edx,%ecx
  800226:	89 c2                	mov    %eax,%edx
  800228:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80022b:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80022e:	8b 45 10             	mov    0x10(%ebp),%eax
  800231:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800234:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800237:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80023e:	39 c2                	cmp    %eax,%edx
  800240:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  800243:	72 3c                	jb     800281 <printnum+0x70>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800245:	83 ec 0c             	sub    $0xc,%esp
  800248:	ff 75 18             	pushl  0x18(%ebp)
  80024b:	4b                   	dec    %ebx
  80024c:	53                   	push   %ebx
  80024d:	50                   	push   %eax
  80024e:	83 ec 08             	sub    $0x8,%esp
  800251:	ff 75 e4             	pushl  -0x1c(%ebp)
  800254:	ff 75 e0             	pushl  -0x20(%ebp)
  800257:	ff 75 dc             	pushl  -0x24(%ebp)
  80025a:	ff 75 d8             	pushl  -0x28(%ebp)
  80025d:	e8 56 08 00 00       	call   800ab8 <__udivdi3>
  800262:	83 c4 18             	add    $0x18,%esp
  800265:	52                   	push   %edx
  800266:	50                   	push   %eax
  800267:	89 f2                	mov    %esi,%edx
  800269:	89 f8                	mov    %edi,%eax
  80026b:	e8 a1 ff ff ff       	call   800211 <printnum>
  800270:	83 c4 20             	add    $0x20,%esp
  800273:	eb 11                	jmp    800286 <printnum+0x75>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800275:	83 ec 08             	sub    $0x8,%esp
  800278:	56                   	push   %esi
  800279:	ff 75 18             	pushl  0x18(%ebp)
  80027c:	ff d7                	call   *%edi
  80027e:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800281:	4b                   	dec    %ebx
  800282:	85 db                	test   %ebx,%ebx
  800284:	7f ef                	jg     800275 <printnum+0x64>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800286:	83 ec 08             	sub    $0x8,%esp
  800289:	56                   	push   %esi
  80028a:	83 ec 04             	sub    $0x4,%esp
  80028d:	ff 75 e4             	pushl  -0x1c(%ebp)
  800290:	ff 75 e0             	pushl  -0x20(%ebp)
  800293:	ff 75 dc             	pushl  -0x24(%ebp)
  800296:	ff 75 d8             	pushl  -0x28(%ebp)
  800299:	e8 1a 09 00 00       	call   800bb8 <__umoddi3>
  80029e:	83 c4 14             	add    $0x14,%esp
  8002a1:	0f be 80 3e 0d 80 00 	movsbl 0x800d3e(%eax),%eax
  8002a8:	50                   	push   %eax
  8002a9:	ff d7                	call   *%edi
}
  8002ab:	83 c4 10             	add    $0x10,%esp
  8002ae:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002b1:	5b                   	pop    %ebx
  8002b2:	5e                   	pop    %esi
  8002b3:	5f                   	pop    %edi
  8002b4:	5d                   	pop    %ebp
  8002b5:	c3                   	ret    

008002b6 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002b6:	55                   	push   %ebp
  8002b7:	89 e5                	mov    %esp,%ebp
  8002b9:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002bc:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8002bf:	8b 10                	mov    (%eax),%edx
  8002c1:	3b 50 04             	cmp    0x4(%eax),%edx
  8002c4:	73 0a                	jae    8002d0 <sprintputch+0x1a>
		*b->buf++ = ch;
  8002c6:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002c9:	89 08                	mov    %ecx,(%eax)
  8002cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8002ce:	88 02                	mov    %al,(%edx)
}
  8002d0:	5d                   	pop    %ebp
  8002d1:	c3                   	ret    

008002d2 <printfmt>:
{
  8002d2:	55                   	push   %ebp
  8002d3:	89 e5                	mov    %esp,%ebp
  8002d5:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8002d8:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002db:	50                   	push   %eax
  8002dc:	ff 75 10             	pushl  0x10(%ebp)
  8002df:	ff 75 0c             	pushl  0xc(%ebp)
  8002e2:	ff 75 08             	pushl  0x8(%ebp)
  8002e5:	e8 05 00 00 00       	call   8002ef <vprintfmt>
}
  8002ea:	83 c4 10             	add    $0x10,%esp
  8002ed:	c9                   	leave  
  8002ee:	c3                   	ret    

008002ef <vprintfmt>:
{
  8002ef:	55                   	push   %ebp
  8002f0:	89 e5                	mov    %esp,%ebp
  8002f2:	57                   	push   %edi
  8002f3:	56                   	push   %esi
  8002f4:	53                   	push   %ebx
  8002f5:	83 ec 3c             	sub    $0x3c,%esp
  8002f8:	8b 75 08             	mov    0x8(%ebp),%esi
  8002fb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002fe:	8b 7d 10             	mov    0x10(%ebp),%edi
  800301:	e9 5b 03 00 00       	jmp    800661 <vprintfmt+0x372>
		padc = ' ';
  800306:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  80030a:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
		precision = -1;
  800311:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  800318:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		lflag = 0;
  80031f:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800324:	8d 47 01             	lea    0x1(%edi),%eax
  800327:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80032a:	8a 17                	mov    (%edi),%dl
  80032c:	8d 42 dd             	lea    -0x23(%edx),%eax
  80032f:	3c 55                	cmp    $0x55,%al
  800331:	0f 87 ab 03 00 00    	ja     8006e2 <vprintfmt+0x3f3>
  800337:	0f b6 c0             	movzbl %al,%eax
  80033a:	ff 24 85 cc 0d 80 00 	jmp    *0x800dcc(,%eax,4)
  800341:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800344:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  800348:	eb da                	jmp    800324 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  80034a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80034d:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  800351:	eb d1                	jmp    800324 <vprintfmt+0x35>
  800353:	0f b6 d2             	movzbl %dl,%edx
  800356:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800359:	b8 00 00 00 00       	mov    $0x0,%eax
  80035e:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800361:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800364:	01 c0                	add    %eax,%eax
  800366:	8d 44 02 d0          	lea    -0x30(%edx,%eax,1),%eax
				ch = *fmt;
  80036a:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  80036d:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800370:	83 f9 09             	cmp    $0x9,%ecx
  800373:	77 52                	ja     8003c7 <vprintfmt+0xd8>
			for (precision = 0; ; ++fmt) {
  800375:	47                   	inc    %edi
				precision = precision * 10 + ch - '0';
  800376:	eb e9                	jmp    800361 <vprintfmt+0x72>
			precision = va_arg(ap, int);
  800378:	8b 45 14             	mov    0x14(%ebp),%eax
  80037b:	8b 00                	mov    (%eax),%eax
  80037d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800380:	8b 45 14             	mov    0x14(%ebp),%eax
  800383:	8d 40 04             	lea    0x4(%eax),%eax
  800386:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800389:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  80038c:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800390:	79 92                	jns    800324 <vprintfmt+0x35>
				width = precision, precision = -1;
  800392:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800395:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800398:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  80039f:	eb 83                	jmp    800324 <vprintfmt+0x35>
  8003a1:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8003a5:	78 08                	js     8003af <vprintfmt+0xc0>
		switch (ch = *(unsigned char *) fmt++) {
  8003a7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8003aa:	e9 75 ff ff ff       	jmp    800324 <vprintfmt+0x35>
  8003af:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  8003b6:	eb ef                	jmp    8003a7 <vprintfmt+0xb8>
		switch (ch = *(unsigned char *) fmt++) {
  8003b8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8003bb:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  8003c2:	e9 5d ff ff ff       	jmp    800324 <vprintfmt+0x35>
  8003c7:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8003ca:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003cd:	eb bd                	jmp    80038c <vprintfmt+0x9d>
			lflag++;
  8003cf:	41                   	inc    %ecx
		switch (ch = *(unsigned char *) fmt++) {
  8003d0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8003d3:	e9 4c ff ff ff       	jmp    800324 <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
  8003d8:	8b 45 14             	mov    0x14(%ebp),%eax
  8003db:	8d 78 04             	lea    0x4(%eax),%edi
  8003de:	83 ec 08             	sub    $0x8,%esp
  8003e1:	53                   	push   %ebx
  8003e2:	ff 30                	pushl  (%eax)
  8003e4:	ff d6                	call   *%esi
			break;
  8003e6:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8003e9:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8003ec:	e9 6d 02 00 00       	jmp    80065e <vprintfmt+0x36f>
			err = va_arg(ap, int);
  8003f1:	8b 45 14             	mov    0x14(%ebp),%eax
  8003f4:	8d 78 04             	lea    0x4(%eax),%edi
  8003f7:	8b 00                	mov    (%eax),%eax
  8003f9:	85 c0                	test   %eax,%eax
  8003fb:	78 2a                	js     800427 <vprintfmt+0x138>
  8003fd:	89 c2                	mov    %eax,%edx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003ff:	83 f8 06             	cmp    $0x6,%eax
  800402:	7f 27                	jg     80042b <vprintfmt+0x13c>
  800404:	8b 04 85 24 0f 80 00 	mov    0x800f24(,%eax,4),%eax
  80040b:	85 c0                	test   %eax,%eax
  80040d:	74 1c                	je     80042b <vprintfmt+0x13c>
				printfmt(putch, putdat, "%s", p);
  80040f:	50                   	push   %eax
  800410:	68 5f 0d 80 00       	push   $0x800d5f
  800415:	53                   	push   %ebx
  800416:	56                   	push   %esi
  800417:	e8 b6 fe ff ff       	call   8002d2 <printfmt>
  80041c:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80041f:	89 7d 14             	mov    %edi,0x14(%ebp)
  800422:	e9 37 02 00 00       	jmp    80065e <vprintfmt+0x36f>
  800427:	f7 d8                	neg    %eax
  800429:	eb d2                	jmp    8003fd <vprintfmt+0x10e>
				printfmt(putch, putdat, "error %d", err);
  80042b:	52                   	push   %edx
  80042c:	68 56 0d 80 00       	push   $0x800d56
  800431:	53                   	push   %ebx
  800432:	56                   	push   %esi
  800433:	e8 9a fe ff ff       	call   8002d2 <printfmt>
  800438:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80043b:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  80043e:	e9 1b 02 00 00       	jmp    80065e <vprintfmt+0x36f>
			if ((p = va_arg(ap, char *)) == NULL)
  800443:	8b 45 14             	mov    0x14(%ebp),%eax
  800446:	83 c0 04             	add    $0x4,%eax
  800449:	89 45 c8             	mov    %eax,-0x38(%ebp)
  80044c:	8b 45 14             	mov    0x14(%ebp),%eax
  80044f:	8b 00                	mov    (%eax),%eax
  800451:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800454:	85 c0                	test   %eax,%eax
  800456:	74 19                	je     800471 <vprintfmt+0x182>
			if (width > 0 && padc != '-')
  800458:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80045c:	7e 06                	jle    800464 <vprintfmt+0x175>
  80045e:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  800462:	75 16                	jne    80047a <vprintfmt+0x18b>
				for (width -= strnlen(p, precision); width > 0; width--)
  800464:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800467:	89 c7                	mov    %eax,%edi
  800469:	03 45 d4             	add    -0x2c(%ebp),%eax
  80046c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80046f:	eb 62                	jmp    8004d3 <vprintfmt+0x1e4>
				p = "(null)";
  800471:	c7 45 cc 4f 0d 80 00 	movl   $0x800d4f,-0x34(%ebp)
  800478:	eb de                	jmp    800458 <vprintfmt+0x169>
				for (width -= strnlen(p, precision); width > 0; width--)
  80047a:	83 ec 08             	sub    $0x8,%esp
  80047d:	ff 75 d8             	pushl  -0x28(%ebp)
  800480:	ff 75 cc             	pushl  -0x34(%ebp)
  800483:	e8 05 03 00 00       	call   80078d <strnlen>
  800488:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80048b:	29 c2                	sub    %eax,%edx
  80048d:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  800490:	83 c4 10             	add    $0x10,%esp
  800493:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  800495:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  800499:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  80049c:	eb 0d                	jmp    8004ab <vprintfmt+0x1bc>
					putch(padc, putdat);
  80049e:	83 ec 08             	sub    $0x8,%esp
  8004a1:	53                   	push   %ebx
  8004a2:	ff 75 d4             	pushl  -0x2c(%ebp)
  8004a5:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8004a7:	4f                   	dec    %edi
  8004a8:	83 c4 10             	add    $0x10,%esp
  8004ab:	85 ff                	test   %edi,%edi
  8004ad:	7f ef                	jg     80049e <vprintfmt+0x1af>
  8004af:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8004b2:	89 d0                	mov    %edx,%eax
  8004b4:	85 d2                	test   %edx,%edx
  8004b6:	78 0a                	js     8004c2 <vprintfmt+0x1d3>
  8004b8:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8004bb:	29 c2                	sub    %eax,%edx
  8004bd:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8004c0:	eb a2                	jmp    800464 <vprintfmt+0x175>
  8004c2:	b8 00 00 00 00       	mov    $0x0,%eax
  8004c7:	eb ef                	jmp    8004b8 <vprintfmt+0x1c9>
					putch(ch, putdat);
  8004c9:	83 ec 08             	sub    $0x8,%esp
  8004cc:	53                   	push   %ebx
  8004cd:	52                   	push   %edx
  8004ce:	ff d6                	call   *%esi
  8004d0:	83 c4 10             	add    $0x10,%esp
  8004d3:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  8004d6:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004d8:	47                   	inc    %edi
  8004d9:	8a 47 ff             	mov    -0x1(%edi),%al
  8004dc:	0f be d0             	movsbl %al,%edx
  8004df:	85 d2                	test   %edx,%edx
  8004e1:	74 48                	je     80052b <vprintfmt+0x23c>
  8004e3:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004e7:	78 05                	js     8004ee <vprintfmt+0x1ff>
  8004e9:	ff 4d d8             	decl   -0x28(%ebp)
  8004ec:	78 1e                	js     80050c <vprintfmt+0x21d>
				if (altflag && (ch < ' ' || ch > '~'))
  8004ee:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004f2:	74 d5                	je     8004c9 <vprintfmt+0x1da>
  8004f4:	0f be c0             	movsbl %al,%eax
  8004f7:	83 e8 20             	sub    $0x20,%eax
  8004fa:	83 f8 5e             	cmp    $0x5e,%eax
  8004fd:	76 ca                	jbe    8004c9 <vprintfmt+0x1da>
					putch('?', putdat);
  8004ff:	83 ec 08             	sub    $0x8,%esp
  800502:	53                   	push   %ebx
  800503:	6a 3f                	push   $0x3f
  800505:	ff d6                	call   *%esi
  800507:	83 c4 10             	add    $0x10,%esp
  80050a:	eb c7                	jmp    8004d3 <vprintfmt+0x1e4>
  80050c:	89 cf                	mov    %ecx,%edi
  80050e:	eb 0c                	jmp    80051c <vprintfmt+0x22d>
				putch(' ', putdat);
  800510:	83 ec 08             	sub    $0x8,%esp
  800513:	53                   	push   %ebx
  800514:	6a 20                	push   $0x20
  800516:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800518:	4f                   	dec    %edi
  800519:	83 c4 10             	add    $0x10,%esp
  80051c:	85 ff                	test   %edi,%edi
  80051e:	7f f0                	jg     800510 <vprintfmt+0x221>
			if ((p = va_arg(ap, char *)) == NULL)
  800520:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800523:	89 45 14             	mov    %eax,0x14(%ebp)
  800526:	e9 33 01 00 00       	jmp    80065e <vprintfmt+0x36f>
  80052b:	89 cf                	mov    %ecx,%edi
  80052d:	eb ed                	jmp    80051c <vprintfmt+0x22d>
	if (lflag >= 2)
  80052f:	83 f9 01             	cmp    $0x1,%ecx
  800532:	7f 1b                	jg     80054f <vprintfmt+0x260>
	else if (lflag)
  800534:	85 c9                	test   %ecx,%ecx
  800536:	74 42                	je     80057a <vprintfmt+0x28b>
		return va_arg(*ap, long);
  800538:	8b 45 14             	mov    0x14(%ebp),%eax
  80053b:	8b 00                	mov    (%eax),%eax
  80053d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800540:	99                   	cltd   
  800541:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800544:	8b 45 14             	mov    0x14(%ebp),%eax
  800547:	8d 40 04             	lea    0x4(%eax),%eax
  80054a:	89 45 14             	mov    %eax,0x14(%ebp)
  80054d:	eb 17                	jmp    800566 <vprintfmt+0x277>
		return va_arg(*ap, long long);
  80054f:	8b 45 14             	mov    0x14(%ebp),%eax
  800552:	8b 50 04             	mov    0x4(%eax),%edx
  800555:	8b 00                	mov    (%eax),%eax
  800557:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80055a:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80055d:	8b 45 14             	mov    0x14(%ebp),%eax
  800560:	8d 40 08             	lea    0x8(%eax),%eax
  800563:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800566:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800569:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80056c:	85 c9                	test   %ecx,%ecx
  80056e:	78 21                	js     800591 <vprintfmt+0x2a2>
			base = 10;
  800570:	b8 0a 00 00 00       	mov    $0xa,%eax
  800575:	e9 ca 00 00 00       	jmp    800644 <vprintfmt+0x355>
		return va_arg(*ap, int);
  80057a:	8b 45 14             	mov    0x14(%ebp),%eax
  80057d:	8b 00                	mov    (%eax),%eax
  80057f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800582:	99                   	cltd   
  800583:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800586:	8b 45 14             	mov    0x14(%ebp),%eax
  800589:	8d 40 04             	lea    0x4(%eax),%eax
  80058c:	89 45 14             	mov    %eax,0x14(%ebp)
  80058f:	eb d5                	jmp    800566 <vprintfmt+0x277>
				putch('-', putdat);
  800591:	83 ec 08             	sub    $0x8,%esp
  800594:	53                   	push   %ebx
  800595:	6a 2d                	push   $0x2d
  800597:	ff d6                	call   *%esi
				num = -(long long) num;
  800599:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80059c:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80059f:	f7 da                	neg    %edx
  8005a1:	83 d1 00             	adc    $0x0,%ecx
  8005a4:	f7 d9                	neg    %ecx
  8005a6:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8005a9:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005ae:	e9 91 00 00 00       	jmp    800644 <vprintfmt+0x355>
	if (lflag >= 2)
  8005b3:	83 f9 01             	cmp    $0x1,%ecx
  8005b6:	7f 1b                	jg     8005d3 <vprintfmt+0x2e4>
	else if (lflag)
  8005b8:	85 c9                	test   %ecx,%ecx
  8005ba:	74 2c                	je     8005e8 <vprintfmt+0x2f9>
		return va_arg(*ap, unsigned long);
  8005bc:	8b 45 14             	mov    0x14(%ebp),%eax
  8005bf:	8b 10                	mov    (%eax),%edx
  8005c1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005c6:	8d 40 04             	lea    0x4(%eax),%eax
  8005c9:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005cc:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  8005d1:	eb 71                	jmp    800644 <vprintfmt+0x355>
		return va_arg(*ap, unsigned long long);
  8005d3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d6:	8b 10                	mov    (%eax),%edx
  8005d8:	8b 48 04             	mov    0x4(%eax),%ecx
  8005db:	8d 40 08             	lea    0x8(%eax),%eax
  8005de:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005e1:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  8005e6:	eb 5c                	jmp    800644 <vprintfmt+0x355>
		return va_arg(*ap, unsigned int);
  8005e8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005eb:	8b 10                	mov    (%eax),%edx
  8005ed:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005f2:	8d 40 04             	lea    0x4(%eax),%eax
  8005f5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005f8:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  8005fd:	eb 45                	jmp    800644 <vprintfmt+0x355>
			putch('X', putdat);
  8005ff:	83 ec 08             	sub    $0x8,%esp
  800602:	53                   	push   %ebx
  800603:	6a 58                	push   $0x58
  800605:	ff d6                	call   *%esi
			putch('X', putdat);
  800607:	83 c4 08             	add    $0x8,%esp
  80060a:	53                   	push   %ebx
  80060b:	6a 58                	push   $0x58
  80060d:	ff d6                	call   *%esi
			putch('X', putdat);
  80060f:	83 c4 08             	add    $0x8,%esp
  800612:	53                   	push   %ebx
  800613:	6a 58                	push   $0x58
  800615:	ff d6                	call   *%esi
			break;
  800617:	83 c4 10             	add    $0x10,%esp
  80061a:	eb 42                	jmp    80065e <vprintfmt+0x36f>
			putch('0', putdat);
  80061c:	83 ec 08             	sub    $0x8,%esp
  80061f:	53                   	push   %ebx
  800620:	6a 30                	push   $0x30
  800622:	ff d6                	call   *%esi
			putch('x', putdat);
  800624:	83 c4 08             	add    $0x8,%esp
  800627:	53                   	push   %ebx
  800628:	6a 78                	push   $0x78
  80062a:	ff d6                	call   *%esi
			num = (unsigned long long)
  80062c:	8b 45 14             	mov    0x14(%ebp),%eax
  80062f:	8b 10                	mov    (%eax),%edx
  800631:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800636:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800639:	8d 40 04             	lea    0x4(%eax),%eax
  80063c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80063f:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  800644:	83 ec 0c             	sub    $0xc,%esp
  800647:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  80064b:	57                   	push   %edi
  80064c:	ff 75 d4             	pushl  -0x2c(%ebp)
  80064f:	50                   	push   %eax
  800650:	51                   	push   %ecx
  800651:	52                   	push   %edx
  800652:	89 da                	mov    %ebx,%edx
  800654:	89 f0                	mov    %esi,%eax
  800656:	e8 b6 fb ff ff       	call   800211 <printnum>
			break;
  80065b:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  80065e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800661:	47                   	inc    %edi
  800662:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800666:	83 f8 25             	cmp    $0x25,%eax
  800669:	0f 84 97 fc ff ff    	je     800306 <vprintfmt+0x17>
			if (ch == '\0')
  80066f:	85 c0                	test   %eax,%eax
  800671:	0f 84 89 00 00 00    	je     800700 <vprintfmt+0x411>
			putch(ch, putdat);
  800677:	83 ec 08             	sub    $0x8,%esp
  80067a:	53                   	push   %ebx
  80067b:	50                   	push   %eax
  80067c:	ff d6                	call   *%esi
  80067e:	83 c4 10             	add    $0x10,%esp
  800681:	eb de                	jmp    800661 <vprintfmt+0x372>
	if (lflag >= 2)
  800683:	83 f9 01             	cmp    $0x1,%ecx
  800686:	7f 1b                	jg     8006a3 <vprintfmt+0x3b4>
	else if (lflag)
  800688:	85 c9                	test   %ecx,%ecx
  80068a:	74 2c                	je     8006b8 <vprintfmt+0x3c9>
		return va_arg(*ap, unsigned long);
  80068c:	8b 45 14             	mov    0x14(%ebp),%eax
  80068f:	8b 10                	mov    (%eax),%edx
  800691:	b9 00 00 00 00       	mov    $0x0,%ecx
  800696:	8d 40 04             	lea    0x4(%eax),%eax
  800699:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80069c:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  8006a1:	eb a1                	jmp    800644 <vprintfmt+0x355>
		return va_arg(*ap, unsigned long long);
  8006a3:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a6:	8b 10                	mov    (%eax),%edx
  8006a8:	8b 48 04             	mov    0x4(%eax),%ecx
  8006ab:	8d 40 08             	lea    0x8(%eax),%eax
  8006ae:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006b1:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  8006b6:	eb 8c                	jmp    800644 <vprintfmt+0x355>
		return va_arg(*ap, unsigned int);
  8006b8:	8b 45 14             	mov    0x14(%ebp),%eax
  8006bb:	8b 10                	mov    (%eax),%edx
  8006bd:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006c2:	8d 40 04             	lea    0x4(%eax),%eax
  8006c5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006c8:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  8006cd:	e9 72 ff ff ff       	jmp    800644 <vprintfmt+0x355>
			putch(ch, putdat);
  8006d2:	83 ec 08             	sub    $0x8,%esp
  8006d5:	53                   	push   %ebx
  8006d6:	6a 25                	push   $0x25
  8006d8:	ff d6                	call   *%esi
			break;
  8006da:	83 c4 10             	add    $0x10,%esp
  8006dd:	e9 7c ff ff ff       	jmp    80065e <vprintfmt+0x36f>
			putch('%', putdat);
  8006e2:	83 ec 08             	sub    $0x8,%esp
  8006e5:	53                   	push   %ebx
  8006e6:	6a 25                	push   $0x25
  8006e8:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006ea:	83 c4 10             	add    $0x10,%esp
  8006ed:	89 f8                	mov    %edi,%eax
  8006ef:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8006f3:	74 03                	je     8006f8 <vprintfmt+0x409>
  8006f5:	48                   	dec    %eax
  8006f6:	eb f7                	jmp    8006ef <vprintfmt+0x400>
  8006f8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8006fb:	e9 5e ff ff ff       	jmp    80065e <vprintfmt+0x36f>
}
  800700:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800703:	5b                   	pop    %ebx
  800704:	5e                   	pop    %esi
  800705:	5f                   	pop    %edi
  800706:	5d                   	pop    %ebp
  800707:	c3                   	ret    

00800708 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800708:	55                   	push   %ebp
  800709:	89 e5                	mov    %esp,%ebp
  80070b:	83 ec 18             	sub    $0x18,%esp
  80070e:	8b 45 08             	mov    0x8(%ebp),%eax
  800711:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800714:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800717:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80071b:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80071e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800725:	85 c0                	test   %eax,%eax
  800727:	74 26                	je     80074f <vsnprintf+0x47>
  800729:	85 d2                	test   %edx,%edx
  80072b:	7e 29                	jle    800756 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80072d:	ff 75 14             	pushl  0x14(%ebp)
  800730:	ff 75 10             	pushl  0x10(%ebp)
  800733:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800736:	50                   	push   %eax
  800737:	68 b6 02 80 00       	push   $0x8002b6
  80073c:	e8 ae fb ff ff       	call   8002ef <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800741:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800744:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800747:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80074a:	83 c4 10             	add    $0x10,%esp
}
  80074d:	c9                   	leave  
  80074e:	c3                   	ret    
		return -E_INVAL;
  80074f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800754:	eb f7                	jmp    80074d <vsnprintf+0x45>
  800756:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80075b:	eb f0                	jmp    80074d <vsnprintf+0x45>

0080075d <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80075d:	55                   	push   %ebp
  80075e:	89 e5                	mov    %esp,%ebp
  800760:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800763:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800766:	50                   	push   %eax
  800767:	ff 75 10             	pushl  0x10(%ebp)
  80076a:	ff 75 0c             	pushl  0xc(%ebp)
  80076d:	ff 75 08             	pushl  0x8(%ebp)
  800770:	e8 93 ff ff ff       	call   800708 <vsnprintf>
	va_end(ap);

	return rc;
}
  800775:	c9                   	leave  
  800776:	c3                   	ret    

00800777 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800777:	55                   	push   %ebp
  800778:	89 e5                	mov    %esp,%ebp
  80077a:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80077d:	b8 00 00 00 00       	mov    $0x0,%eax
  800782:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800786:	74 03                	je     80078b <strlen+0x14>
		n++;
  800788:	40                   	inc    %eax
  800789:	eb f7                	jmp    800782 <strlen+0xb>
	return n;
}
  80078b:	5d                   	pop    %ebp
  80078c:	c3                   	ret    

0080078d <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80078d:	55                   	push   %ebp
  80078e:	89 e5                	mov    %esp,%ebp
  800790:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800793:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800796:	b8 00 00 00 00       	mov    $0x0,%eax
  80079b:	39 d0                	cmp    %edx,%eax
  80079d:	74 0b                	je     8007aa <strnlen+0x1d>
  80079f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007a3:	74 03                	je     8007a8 <strnlen+0x1b>
		n++;
  8007a5:	40                   	inc    %eax
  8007a6:	eb f3                	jmp    80079b <strnlen+0xe>
  8007a8:	89 c2                	mov    %eax,%edx
	return n;
}
  8007aa:	89 d0                	mov    %edx,%eax
  8007ac:	5d                   	pop    %ebp
  8007ad:	c3                   	ret    

008007ae <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007ae:	55                   	push   %ebp
  8007af:	89 e5                	mov    %esp,%ebp
  8007b1:	53                   	push   %ebx
  8007b2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007b5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007b8:	b8 00 00 00 00       	mov    $0x0,%eax
  8007bd:	8a 14 03             	mov    (%ebx,%eax,1),%dl
  8007c0:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8007c3:	40                   	inc    %eax
  8007c4:	84 d2                	test   %dl,%dl
  8007c6:	75 f5                	jne    8007bd <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8007c8:	89 c8                	mov    %ecx,%eax
  8007ca:	5b                   	pop    %ebx
  8007cb:	5d                   	pop    %ebp
  8007cc:	c3                   	ret    

008007cd <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007cd:	55                   	push   %ebp
  8007ce:	89 e5                	mov    %esp,%ebp
  8007d0:	53                   	push   %ebx
  8007d1:	83 ec 10             	sub    $0x10,%esp
  8007d4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007d7:	53                   	push   %ebx
  8007d8:	e8 9a ff ff ff       	call   800777 <strlen>
  8007dd:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  8007e0:	ff 75 0c             	pushl  0xc(%ebp)
  8007e3:	01 d8                	add    %ebx,%eax
  8007e5:	50                   	push   %eax
  8007e6:	e8 c3 ff ff ff       	call   8007ae <strcpy>
	return dst;
}
  8007eb:	89 d8                	mov    %ebx,%eax
  8007ed:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007f0:	c9                   	leave  
  8007f1:	c3                   	ret    

008007f2 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007f2:	55                   	push   %ebp
  8007f3:	89 e5                	mov    %esp,%ebp
  8007f5:	53                   	push   %ebx
  8007f6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007f9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8007fc:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007ff:	8b 45 08             	mov    0x8(%ebp),%eax
  800802:	39 d8                	cmp    %ebx,%eax
  800804:	74 0e                	je     800814 <strncpy+0x22>
		*dst++ = *src;
  800806:	40                   	inc    %eax
  800807:	8a 0a                	mov    (%edx),%cl
  800809:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80080c:	80 f9 01             	cmp    $0x1,%cl
  80080f:	83 da ff             	sbb    $0xffffffff,%edx
  800812:	eb ee                	jmp    800802 <strncpy+0x10>
	}
	return ret;
}
  800814:	8b 45 08             	mov    0x8(%ebp),%eax
  800817:	5b                   	pop    %ebx
  800818:	5d                   	pop    %ebp
  800819:	c3                   	ret    

0080081a <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80081a:	55                   	push   %ebp
  80081b:	89 e5                	mov    %esp,%ebp
  80081d:	56                   	push   %esi
  80081e:	53                   	push   %ebx
  80081f:	8b 75 08             	mov    0x8(%ebp),%esi
  800822:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800825:	8b 45 10             	mov    0x10(%ebp),%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800828:	85 c0                	test   %eax,%eax
  80082a:	74 22                	je     80084e <strlcpy+0x34>
  80082c:	8d 44 06 ff          	lea    -0x1(%esi,%eax,1),%eax
  800830:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  800832:	39 c2                	cmp    %eax,%edx
  800834:	74 0f                	je     800845 <strlcpy+0x2b>
  800836:	8a 19                	mov    (%ecx),%bl
  800838:	84 db                	test   %bl,%bl
  80083a:	74 07                	je     800843 <strlcpy+0x29>
			*dst++ = *src++;
  80083c:	41                   	inc    %ecx
  80083d:	42                   	inc    %edx
  80083e:	88 5a ff             	mov    %bl,-0x1(%edx)
  800841:	eb ef                	jmp    800832 <strlcpy+0x18>
  800843:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800845:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800848:	29 f0                	sub    %esi,%eax
}
  80084a:	5b                   	pop    %ebx
  80084b:	5e                   	pop    %esi
  80084c:	5d                   	pop    %ebp
  80084d:	c3                   	ret    
  80084e:	89 f0                	mov    %esi,%eax
  800850:	eb f6                	jmp    800848 <strlcpy+0x2e>

00800852 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800852:	55                   	push   %ebp
  800853:	89 e5                	mov    %esp,%ebp
  800855:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800858:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80085b:	8a 01                	mov    (%ecx),%al
  80085d:	84 c0                	test   %al,%al
  80085f:	74 08                	je     800869 <strcmp+0x17>
  800861:	3a 02                	cmp    (%edx),%al
  800863:	75 04                	jne    800869 <strcmp+0x17>
		p++, q++;
  800865:	41                   	inc    %ecx
  800866:	42                   	inc    %edx
  800867:	eb f2                	jmp    80085b <strcmp+0x9>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800869:	0f b6 c0             	movzbl %al,%eax
  80086c:	0f b6 12             	movzbl (%edx),%edx
  80086f:	29 d0                	sub    %edx,%eax
}
  800871:	5d                   	pop    %ebp
  800872:	c3                   	ret    

00800873 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800873:	55                   	push   %ebp
  800874:	89 e5                	mov    %esp,%ebp
  800876:	53                   	push   %ebx
  800877:	8b 45 08             	mov    0x8(%ebp),%eax
  80087a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80087d:	89 c3                	mov    %eax,%ebx
  80087f:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800882:	eb 02                	jmp    800886 <strncmp+0x13>
		n--, p++, q++;
  800884:	40                   	inc    %eax
  800885:	42                   	inc    %edx
	while (n > 0 && *p && *p == *q)
  800886:	39 d8                	cmp    %ebx,%eax
  800888:	74 15                	je     80089f <strncmp+0x2c>
  80088a:	8a 08                	mov    (%eax),%cl
  80088c:	84 c9                	test   %cl,%cl
  80088e:	74 04                	je     800894 <strncmp+0x21>
  800890:	3a 0a                	cmp    (%edx),%cl
  800892:	74 f0                	je     800884 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800894:	0f b6 00             	movzbl (%eax),%eax
  800897:	0f b6 12             	movzbl (%edx),%edx
  80089a:	29 d0                	sub    %edx,%eax
}
  80089c:	5b                   	pop    %ebx
  80089d:	5d                   	pop    %ebp
  80089e:	c3                   	ret    
		return 0;
  80089f:	b8 00 00 00 00       	mov    $0x0,%eax
  8008a4:	eb f6                	jmp    80089c <strncmp+0x29>

008008a6 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008a6:	55                   	push   %ebp
  8008a7:	89 e5                	mov    %esp,%ebp
  8008a9:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ac:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8008af:	8a 10                	mov    (%eax),%dl
  8008b1:	84 d2                	test   %dl,%dl
  8008b3:	74 07                	je     8008bc <strchr+0x16>
		if (*s == c)
  8008b5:	38 ca                	cmp    %cl,%dl
  8008b7:	74 08                	je     8008c1 <strchr+0x1b>
	for (; *s; s++)
  8008b9:	40                   	inc    %eax
  8008ba:	eb f3                	jmp    8008af <strchr+0x9>
			return (char *) s;
	return 0;
  8008bc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008c1:	5d                   	pop    %ebp
  8008c2:	c3                   	ret    

008008c3 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008c3:	55                   	push   %ebp
  8008c4:	89 e5                	mov    %esp,%ebp
  8008c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c9:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8008cc:	8a 10                	mov    (%eax),%dl
  8008ce:	84 d2                	test   %dl,%dl
  8008d0:	74 07                	je     8008d9 <strfind+0x16>
		if (*s == c)
  8008d2:	38 ca                	cmp    %cl,%dl
  8008d4:	74 03                	je     8008d9 <strfind+0x16>
	for (; *s; s++)
  8008d6:	40                   	inc    %eax
  8008d7:	eb f3                	jmp    8008cc <strfind+0x9>
			break;
	return (char *) s;
}
  8008d9:	5d                   	pop    %ebp
  8008da:	c3                   	ret    

008008db <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008db:	55                   	push   %ebp
  8008dc:	89 e5                	mov    %esp,%ebp
  8008de:	57                   	push   %edi
  8008df:	56                   	push   %esi
  8008e0:	53                   	push   %ebx
  8008e1:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008e4:	85 c9                	test   %ecx,%ecx
  8008e6:	74 36                	je     80091e <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008e8:	89 c8                	mov    %ecx,%eax
  8008ea:	0b 45 08             	or     0x8(%ebp),%eax
  8008ed:	a8 03                	test   $0x3,%al
  8008ef:	75 24                	jne    800915 <memset+0x3a>
		c &= 0xFF;
  8008f1:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008f5:	89 d3                	mov    %edx,%ebx
  8008f7:	c1 e3 08             	shl    $0x8,%ebx
  8008fa:	89 d0                	mov    %edx,%eax
  8008fc:	c1 e0 18             	shl    $0x18,%eax
  8008ff:	89 d6                	mov    %edx,%esi
  800901:	c1 e6 10             	shl    $0x10,%esi
  800904:	09 f0                	or     %esi,%eax
  800906:	09 d0                	or     %edx,%eax
  800908:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80090a:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  80090d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800910:	fc                   	cld    
  800911:	f3 ab                	rep stos %eax,%es:(%edi)
  800913:	eb 09                	jmp    80091e <memset+0x43>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800915:	8b 7d 08             	mov    0x8(%ebp),%edi
  800918:	8b 45 0c             	mov    0xc(%ebp),%eax
  80091b:	fc                   	cld    
  80091c:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80091e:	8b 45 08             	mov    0x8(%ebp),%eax
  800921:	5b                   	pop    %ebx
  800922:	5e                   	pop    %esi
  800923:	5f                   	pop    %edi
  800924:	5d                   	pop    %ebp
  800925:	c3                   	ret    

00800926 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800926:	55                   	push   %ebp
  800927:	89 e5                	mov    %esp,%ebp
  800929:	57                   	push   %edi
  80092a:	56                   	push   %esi
  80092b:	8b 45 08             	mov    0x8(%ebp),%eax
  80092e:	8b 75 0c             	mov    0xc(%ebp),%esi
  800931:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800934:	39 c6                	cmp    %eax,%esi
  800936:	73 30                	jae    800968 <memmove+0x42>
  800938:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80093b:	39 c2                	cmp    %eax,%edx
  80093d:	76 29                	jbe    800968 <memmove+0x42>
		s += n;
		d += n;
  80093f:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800942:	89 fe                	mov    %edi,%esi
  800944:	09 ce                	or     %ecx,%esi
  800946:	09 d6                	or     %edx,%esi
  800948:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80094e:	75 0e                	jne    80095e <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800950:	83 ef 04             	sub    $0x4,%edi
  800953:	8d 72 fc             	lea    -0x4(%edx),%esi
  800956:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800959:	fd                   	std    
  80095a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80095c:	eb 07                	jmp    800965 <memmove+0x3f>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80095e:	4f                   	dec    %edi
  80095f:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800962:	fd                   	std    
  800963:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800965:	fc                   	cld    
  800966:	eb 1a                	jmp    800982 <memmove+0x5c>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800968:	89 c2                	mov    %eax,%edx
  80096a:	09 ca                	or     %ecx,%edx
  80096c:	09 f2                	or     %esi,%edx
  80096e:	f6 c2 03             	test   $0x3,%dl
  800971:	75 0a                	jne    80097d <memmove+0x57>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800973:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800976:	89 c7                	mov    %eax,%edi
  800978:	fc                   	cld    
  800979:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80097b:	eb 05                	jmp    800982 <memmove+0x5c>
		else
			asm volatile("cld; rep movsb\n"
  80097d:	89 c7                	mov    %eax,%edi
  80097f:	fc                   	cld    
  800980:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800982:	5e                   	pop    %esi
  800983:	5f                   	pop    %edi
  800984:	5d                   	pop    %ebp
  800985:	c3                   	ret    

00800986 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800986:	55                   	push   %ebp
  800987:	89 e5                	mov    %esp,%ebp
  800989:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  80098c:	ff 75 10             	pushl  0x10(%ebp)
  80098f:	ff 75 0c             	pushl  0xc(%ebp)
  800992:	ff 75 08             	pushl  0x8(%ebp)
  800995:	e8 8c ff ff ff       	call   800926 <memmove>
}
  80099a:	c9                   	leave  
  80099b:	c3                   	ret    

0080099c <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80099c:	55                   	push   %ebp
  80099d:	89 e5                	mov    %esp,%ebp
  80099f:	56                   	push   %esi
  8009a0:	53                   	push   %ebx
  8009a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009a7:	89 c6                	mov    %eax,%esi
  8009a9:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009ac:	39 f0                	cmp    %esi,%eax
  8009ae:	74 16                	je     8009c6 <memcmp+0x2a>
		if (*s1 != *s2)
  8009b0:	8a 08                	mov    (%eax),%cl
  8009b2:	8a 1a                	mov    (%edx),%bl
  8009b4:	38 d9                	cmp    %bl,%cl
  8009b6:	75 04                	jne    8009bc <memcmp+0x20>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  8009b8:	40                   	inc    %eax
  8009b9:	42                   	inc    %edx
  8009ba:	eb f0                	jmp    8009ac <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  8009bc:	0f b6 c1             	movzbl %cl,%eax
  8009bf:	0f b6 db             	movzbl %bl,%ebx
  8009c2:	29 d8                	sub    %ebx,%eax
  8009c4:	eb 05                	jmp    8009cb <memcmp+0x2f>
	}

	return 0;
  8009c6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009cb:	5b                   	pop    %ebx
  8009cc:	5e                   	pop    %esi
  8009cd:	5d                   	pop    %ebp
  8009ce:	c3                   	ret    

008009cf <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009cf:	55                   	push   %ebp
  8009d0:	89 e5                	mov    %esp,%ebp
  8009d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8009d8:	89 c2                	mov    %eax,%edx
  8009da:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8009dd:	39 d0                	cmp    %edx,%eax
  8009df:	73 07                	jae    8009e8 <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009e1:	38 08                	cmp    %cl,(%eax)
  8009e3:	74 03                	je     8009e8 <memfind+0x19>
	for (; s < ends; s++)
  8009e5:	40                   	inc    %eax
  8009e6:	eb f5                	jmp    8009dd <memfind+0xe>
			break;
	return (void *) s;
}
  8009e8:	5d                   	pop    %ebp
  8009e9:	c3                   	ret    

008009ea <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009ea:	55                   	push   %ebp
  8009eb:	89 e5                	mov    %esp,%ebp
  8009ed:	57                   	push   %edi
  8009ee:	56                   	push   %esi
  8009ef:	53                   	push   %ebx
  8009f0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009f3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009f6:	eb 01                	jmp    8009f9 <strtol+0xf>
		s++;
  8009f8:	41                   	inc    %ecx
	while (*s == ' ' || *s == '\t')
  8009f9:	8a 01                	mov    (%ecx),%al
  8009fb:	3c 20                	cmp    $0x20,%al
  8009fd:	74 f9                	je     8009f8 <strtol+0xe>
  8009ff:	3c 09                	cmp    $0x9,%al
  800a01:	74 f5                	je     8009f8 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800a03:	3c 2b                	cmp    $0x2b,%al
  800a05:	74 24                	je     800a2b <strtol+0x41>
		s++;
	else if (*s == '-')
  800a07:	3c 2d                	cmp    $0x2d,%al
  800a09:	74 28                	je     800a33 <strtol+0x49>
	int neg = 0;
  800a0b:	bf 00 00 00 00       	mov    $0x0,%edi
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a10:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a16:	75 09                	jne    800a21 <strtol+0x37>
  800a18:	80 39 30             	cmpb   $0x30,(%ecx)
  800a1b:	74 1e                	je     800a3b <strtol+0x51>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a1d:	85 db                	test   %ebx,%ebx
  800a1f:	74 36                	je     800a57 <strtol+0x6d>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a21:	b8 00 00 00 00       	mov    $0x0,%eax
  800a26:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800a29:	eb 45                	jmp    800a70 <strtol+0x86>
		s++;
  800a2b:	41                   	inc    %ecx
	int neg = 0;
  800a2c:	bf 00 00 00 00       	mov    $0x0,%edi
  800a31:	eb dd                	jmp    800a10 <strtol+0x26>
		s++, neg = 1;
  800a33:	41                   	inc    %ecx
  800a34:	bf 01 00 00 00       	mov    $0x1,%edi
  800a39:	eb d5                	jmp    800a10 <strtol+0x26>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a3b:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a3f:	74 0c                	je     800a4d <strtol+0x63>
	else if (base == 0 && s[0] == '0')
  800a41:	85 db                	test   %ebx,%ebx
  800a43:	75 dc                	jne    800a21 <strtol+0x37>
		s++, base = 8;
  800a45:	41                   	inc    %ecx
  800a46:	bb 08 00 00 00       	mov    $0x8,%ebx
  800a4b:	eb d4                	jmp    800a21 <strtol+0x37>
		s += 2, base = 16;
  800a4d:	83 c1 02             	add    $0x2,%ecx
  800a50:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a55:	eb ca                	jmp    800a21 <strtol+0x37>
		base = 10;
  800a57:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800a5c:	eb c3                	jmp    800a21 <strtol+0x37>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800a5e:	0f be d2             	movsbl %dl,%edx
  800a61:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800a64:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a67:	7d 37                	jge    800aa0 <strtol+0xb6>
			break;
		s++, val = (val * base) + dig;
  800a69:	41                   	inc    %ecx
  800a6a:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a6e:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800a70:	8a 11                	mov    (%ecx),%dl
  800a72:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a75:	89 f3                	mov    %esi,%ebx
  800a77:	80 fb 09             	cmp    $0x9,%bl
  800a7a:	76 e2                	jbe    800a5e <strtol+0x74>
		else if (*s >= 'a' && *s <= 'z')
  800a7c:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a7f:	89 f3                	mov    %esi,%ebx
  800a81:	80 fb 19             	cmp    $0x19,%bl
  800a84:	77 08                	ja     800a8e <strtol+0xa4>
			dig = *s - 'a' + 10;
  800a86:	0f be d2             	movsbl %dl,%edx
  800a89:	83 ea 57             	sub    $0x57,%edx
  800a8c:	eb d6                	jmp    800a64 <strtol+0x7a>
		else if (*s >= 'A' && *s <= 'Z')
  800a8e:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a91:	89 f3                	mov    %esi,%ebx
  800a93:	80 fb 19             	cmp    $0x19,%bl
  800a96:	77 08                	ja     800aa0 <strtol+0xb6>
			dig = *s - 'A' + 10;
  800a98:	0f be d2             	movsbl %dl,%edx
  800a9b:	83 ea 37             	sub    $0x37,%edx
  800a9e:	eb c4                	jmp    800a64 <strtol+0x7a>
		// we don't properly detect overflow!
	}

	if (endptr)
  800aa0:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800aa4:	74 05                	je     800aab <strtol+0xc1>
		*endptr = (char *) s;
  800aa6:	8b 75 0c             	mov    0xc(%ebp),%esi
  800aa9:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800aab:	85 ff                	test   %edi,%edi
  800aad:	74 02                	je     800ab1 <strtol+0xc7>
  800aaf:	f7 d8                	neg    %eax
}
  800ab1:	5b                   	pop    %ebx
  800ab2:	5e                   	pop    %esi
  800ab3:	5f                   	pop    %edi
  800ab4:	5d                   	pop    %ebp
  800ab5:	c3                   	ret    
  800ab6:	66 90                	xchg   %ax,%ax

00800ab8 <__udivdi3>:
  800ab8:	55                   	push   %ebp
  800ab9:	57                   	push   %edi
  800aba:	56                   	push   %esi
  800abb:	53                   	push   %ebx
  800abc:	83 ec 1c             	sub    $0x1c,%esp
  800abf:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800ac3:	8b 74 24 34          	mov    0x34(%esp),%esi
  800ac7:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800acb:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800acf:	85 d2                	test   %edx,%edx
  800ad1:	75 19                	jne    800aec <__udivdi3+0x34>
  800ad3:	39 f7                	cmp    %esi,%edi
  800ad5:	76 45                	jbe    800b1c <__udivdi3+0x64>
  800ad7:	89 e8                	mov    %ebp,%eax
  800ad9:	89 f2                	mov    %esi,%edx
  800adb:	f7 f7                	div    %edi
  800add:	31 db                	xor    %ebx,%ebx
  800adf:	89 da                	mov    %ebx,%edx
  800ae1:	83 c4 1c             	add    $0x1c,%esp
  800ae4:	5b                   	pop    %ebx
  800ae5:	5e                   	pop    %esi
  800ae6:	5f                   	pop    %edi
  800ae7:	5d                   	pop    %ebp
  800ae8:	c3                   	ret    
  800ae9:	8d 76 00             	lea    0x0(%esi),%esi
  800aec:	39 f2                	cmp    %esi,%edx
  800aee:	76 10                	jbe    800b00 <__udivdi3+0x48>
  800af0:	31 db                	xor    %ebx,%ebx
  800af2:	31 c0                	xor    %eax,%eax
  800af4:	89 da                	mov    %ebx,%edx
  800af6:	83 c4 1c             	add    $0x1c,%esp
  800af9:	5b                   	pop    %ebx
  800afa:	5e                   	pop    %esi
  800afb:	5f                   	pop    %edi
  800afc:	5d                   	pop    %ebp
  800afd:	c3                   	ret    
  800afe:	66 90                	xchg   %ax,%ax
  800b00:	0f bd da             	bsr    %edx,%ebx
  800b03:	83 f3 1f             	xor    $0x1f,%ebx
  800b06:	75 3c                	jne    800b44 <__udivdi3+0x8c>
  800b08:	39 f2                	cmp    %esi,%edx
  800b0a:	72 08                	jb     800b14 <__udivdi3+0x5c>
  800b0c:	39 ef                	cmp    %ebp,%edi
  800b0e:	0f 87 9c 00 00 00    	ja     800bb0 <__udivdi3+0xf8>
  800b14:	b8 01 00 00 00       	mov    $0x1,%eax
  800b19:	eb d9                	jmp    800af4 <__udivdi3+0x3c>
  800b1b:	90                   	nop
  800b1c:	89 f9                	mov    %edi,%ecx
  800b1e:	85 ff                	test   %edi,%edi
  800b20:	75 0b                	jne    800b2d <__udivdi3+0x75>
  800b22:	b8 01 00 00 00       	mov    $0x1,%eax
  800b27:	31 d2                	xor    %edx,%edx
  800b29:	f7 f7                	div    %edi
  800b2b:	89 c1                	mov    %eax,%ecx
  800b2d:	31 d2                	xor    %edx,%edx
  800b2f:	89 f0                	mov    %esi,%eax
  800b31:	f7 f1                	div    %ecx
  800b33:	89 c3                	mov    %eax,%ebx
  800b35:	89 e8                	mov    %ebp,%eax
  800b37:	f7 f1                	div    %ecx
  800b39:	89 da                	mov    %ebx,%edx
  800b3b:	83 c4 1c             	add    $0x1c,%esp
  800b3e:	5b                   	pop    %ebx
  800b3f:	5e                   	pop    %esi
  800b40:	5f                   	pop    %edi
  800b41:	5d                   	pop    %ebp
  800b42:	c3                   	ret    
  800b43:	90                   	nop
  800b44:	b8 20 00 00 00       	mov    $0x20,%eax
  800b49:	29 d8                	sub    %ebx,%eax
  800b4b:	88 d9                	mov    %bl,%cl
  800b4d:	d3 e2                	shl    %cl,%edx
  800b4f:	89 54 24 08          	mov    %edx,0x8(%esp)
  800b53:	89 fa                	mov    %edi,%edx
  800b55:	88 c1                	mov    %al,%cl
  800b57:	d3 ea                	shr    %cl,%edx
  800b59:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800b5d:	09 d1                	or     %edx,%ecx
  800b5f:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800b63:	88 d9                	mov    %bl,%cl
  800b65:	d3 e7                	shl    %cl,%edi
  800b67:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800b6b:	89 f7                	mov    %esi,%edi
  800b6d:	88 c1                	mov    %al,%cl
  800b6f:	d3 ef                	shr    %cl,%edi
  800b71:	88 d9                	mov    %bl,%cl
  800b73:	d3 e6                	shl    %cl,%esi
  800b75:	89 ea                	mov    %ebp,%edx
  800b77:	88 c1                	mov    %al,%cl
  800b79:	d3 ea                	shr    %cl,%edx
  800b7b:	09 d6                	or     %edx,%esi
  800b7d:	89 f0                	mov    %esi,%eax
  800b7f:	89 fa                	mov    %edi,%edx
  800b81:	f7 74 24 08          	divl   0x8(%esp)
  800b85:	89 d7                	mov    %edx,%edi
  800b87:	89 c6                	mov    %eax,%esi
  800b89:	f7 64 24 0c          	mull   0xc(%esp)
  800b8d:	39 d7                	cmp    %edx,%edi
  800b8f:	72 13                	jb     800ba4 <__udivdi3+0xec>
  800b91:	74 09                	je     800b9c <__udivdi3+0xe4>
  800b93:	89 f0                	mov    %esi,%eax
  800b95:	31 db                	xor    %ebx,%ebx
  800b97:	e9 58 ff ff ff       	jmp    800af4 <__udivdi3+0x3c>
  800b9c:	88 d9                	mov    %bl,%cl
  800b9e:	d3 e5                	shl    %cl,%ebp
  800ba0:	39 c5                	cmp    %eax,%ebp
  800ba2:	73 ef                	jae    800b93 <__udivdi3+0xdb>
  800ba4:	8d 46 ff             	lea    -0x1(%esi),%eax
  800ba7:	31 db                	xor    %ebx,%ebx
  800ba9:	e9 46 ff ff ff       	jmp    800af4 <__udivdi3+0x3c>
  800bae:	66 90                	xchg   %ax,%ax
  800bb0:	31 c0                	xor    %eax,%eax
  800bb2:	e9 3d ff ff ff       	jmp    800af4 <__udivdi3+0x3c>
  800bb7:	90                   	nop

00800bb8 <__umoddi3>:
  800bb8:	55                   	push   %ebp
  800bb9:	57                   	push   %edi
  800bba:	56                   	push   %esi
  800bbb:	53                   	push   %ebx
  800bbc:	83 ec 1c             	sub    $0x1c,%esp
  800bbf:	8b 74 24 30          	mov    0x30(%esp),%esi
  800bc3:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800bc7:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800bcb:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  800bcf:	85 c0                	test   %eax,%eax
  800bd1:	75 19                	jne    800bec <__umoddi3+0x34>
  800bd3:	39 df                	cmp    %ebx,%edi
  800bd5:	76 51                	jbe    800c28 <__umoddi3+0x70>
  800bd7:	89 f0                	mov    %esi,%eax
  800bd9:	89 da                	mov    %ebx,%edx
  800bdb:	f7 f7                	div    %edi
  800bdd:	89 d0                	mov    %edx,%eax
  800bdf:	31 d2                	xor    %edx,%edx
  800be1:	83 c4 1c             	add    $0x1c,%esp
  800be4:	5b                   	pop    %ebx
  800be5:	5e                   	pop    %esi
  800be6:	5f                   	pop    %edi
  800be7:	5d                   	pop    %ebp
  800be8:	c3                   	ret    
  800be9:	8d 76 00             	lea    0x0(%esi),%esi
  800bec:	89 f2                	mov    %esi,%edx
  800bee:	39 d8                	cmp    %ebx,%eax
  800bf0:	76 0e                	jbe    800c00 <__umoddi3+0x48>
  800bf2:	89 f0                	mov    %esi,%eax
  800bf4:	89 da                	mov    %ebx,%edx
  800bf6:	83 c4 1c             	add    $0x1c,%esp
  800bf9:	5b                   	pop    %ebx
  800bfa:	5e                   	pop    %esi
  800bfb:	5f                   	pop    %edi
  800bfc:	5d                   	pop    %ebp
  800bfd:	c3                   	ret    
  800bfe:	66 90                	xchg   %ax,%ax
  800c00:	0f bd e8             	bsr    %eax,%ebp
  800c03:	83 f5 1f             	xor    $0x1f,%ebp
  800c06:	75 44                	jne    800c4c <__umoddi3+0x94>
  800c08:	39 d8                	cmp    %ebx,%eax
  800c0a:	72 06                	jb     800c12 <__umoddi3+0x5a>
  800c0c:	89 d9                	mov    %ebx,%ecx
  800c0e:	39 f7                	cmp    %esi,%edi
  800c10:	77 08                	ja     800c1a <__umoddi3+0x62>
  800c12:	29 fe                	sub    %edi,%esi
  800c14:	19 c3                	sbb    %eax,%ebx
  800c16:	89 f2                	mov    %esi,%edx
  800c18:	89 d9                	mov    %ebx,%ecx
  800c1a:	89 d0                	mov    %edx,%eax
  800c1c:	89 ca                	mov    %ecx,%edx
  800c1e:	83 c4 1c             	add    $0x1c,%esp
  800c21:	5b                   	pop    %ebx
  800c22:	5e                   	pop    %esi
  800c23:	5f                   	pop    %edi
  800c24:	5d                   	pop    %ebp
  800c25:	c3                   	ret    
  800c26:	66 90                	xchg   %ax,%ax
  800c28:	89 fd                	mov    %edi,%ebp
  800c2a:	85 ff                	test   %edi,%edi
  800c2c:	75 0b                	jne    800c39 <__umoddi3+0x81>
  800c2e:	b8 01 00 00 00       	mov    $0x1,%eax
  800c33:	31 d2                	xor    %edx,%edx
  800c35:	f7 f7                	div    %edi
  800c37:	89 c5                	mov    %eax,%ebp
  800c39:	89 d8                	mov    %ebx,%eax
  800c3b:	31 d2                	xor    %edx,%edx
  800c3d:	f7 f5                	div    %ebp
  800c3f:	89 f0                	mov    %esi,%eax
  800c41:	f7 f5                	div    %ebp
  800c43:	89 d0                	mov    %edx,%eax
  800c45:	31 d2                	xor    %edx,%edx
  800c47:	eb 98                	jmp    800be1 <__umoddi3+0x29>
  800c49:	8d 76 00             	lea    0x0(%esi),%esi
  800c4c:	ba 20 00 00 00       	mov    $0x20,%edx
  800c51:	29 ea                	sub    %ebp,%edx
  800c53:	89 e9                	mov    %ebp,%ecx
  800c55:	d3 e0                	shl    %cl,%eax
  800c57:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c5b:	89 f8                	mov    %edi,%eax
  800c5d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800c61:	88 d1                	mov    %dl,%cl
  800c63:	d3 e8                	shr    %cl,%eax
  800c65:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800c69:	09 c1                	or     %eax,%ecx
  800c6b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800c6f:	89 e9                	mov    %ebp,%ecx
  800c71:	d3 e7                	shl    %cl,%edi
  800c73:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800c77:	89 d8                	mov    %ebx,%eax
  800c79:	8b 54 24 04          	mov    0x4(%esp),%edx
  800c7d:	88 d1                	mov    %dl,%cl
  800c7f:	d3 e8                	shr    %cl,%eax
  800c81:	89 c7                	mov    %eax,%edi
  800c83:	89 e9                	mov    %ebp,%ecx
  800c85:	d3 e3                	shl    %cl,%ebx
  800c87:	89 f0                	mov    %esi,%eax
  800c89:	88 d1                	mov    %dl,%cl
  800c8b:	d3 e8                	shr    %cl,%eax
  800c8d:	09 d8                	or     %ebx,%eax
  800c8f:	89 e9                	mov    %ebp,%ecx
  800c91:	d3 e6                	shl    %cl,%esi
  800c93:	89 f3                	mov    %esi,%ebx
  800c95:	89 fa                	mov    %edi,%edx
  800c97:	f7 74 24 08          	divl   0x8(%esp)
  800c9b:	89 d1                	mov    %edx,%ecx
  800c9d:	f7 64 24 0c          	mull   0xc(%esp)
  800ca1:	89 c6                	mov    %eax,%esi
  800ca3:	89 d7                	mov    %edx,%edi
  800ca5:	39 d1                	cmp    %edx,%ecx
  800ca7:	72 27                	jb     800cd0 <__umoddi3+0x118>
  800ca9:	74 21                	je     800ccc <__umoddi3+0x114>
  800cab:	89 ca                	mov    %ecx,%edx
  800cad:	29 f3                	sub    %esi,%ebx
  800caf:	19 fa                	sbb    %edi,%edx
  800cb1:	89 d0                	mov    %edx,%eax
  800cb3:	8a 4c 24 04          	mov    0x4(%esp),%cl
  800cb7:	d3 e0                	shl    %cl,%eax
  800cb9:	89 e9                	mov    %ebp,%ecx
  800cbb:	d3 eb                	shr    %cl,%ebx
  800cbd:	09 d8                	or     %ebx,%eax
  800cbf:	d3 ea                	shr    %cl,%edx
  800cc1:	83 c4 1c             	add    $0x1c,%esp
  800cc4:	5b                   	pop    %ebx
  800cc5:	5e                   	pop    %esi
  800cc6:	5f                   	pop    %edi
  800cc7:	5d                   	pop    %ebp
  800cc8:	c3                   	ret    
  800cc9:	8d 76 00             	lea    0x0(%esi),%esi
  800ccc:	39 c3                	cmp    %eax,%ebx
  800cce:	73 db                	jae    800cab <__umoddi3+0xf3>
  800cd0:	2b 44 24 0c          	sub    0xc(%esp),%eax
  800cd4:	1b 54 24 08          	sbb    0x8(%esp),%edx
  800cd8:	89 d7                	mov    %edx,%edi
  800cda:	89 c6                	mov    %eax,%esi
  800cdc:	eb cd                	jmp    800cab <__umoddi3+0xf3>
