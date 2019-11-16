
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
  80003d:	83 ec 08             	sub    $0x8,%esp
  800040:	8b 45 08             	mov    0x8(%ebp),%eax
  800043:	8b 55 0c             	mov    0xc(%ebp),%edx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  800046:	c7 05 04 10 80 00 00 	movl   $0x0,0x801004
  80004d:	00 00 00 

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800050:	85 c0                	test   %eax,%eax
  800052:	7e 08                	jle    80005c <libmain+0x22>
		binaryname = argv[0];
  800054:	8b 0a                	mov    (%edx),%ecx
  800056:	89 0d 00 10 80 00    	mov    %ecx,0x801000

	// call user main routine
	umain(argc, argv);
  80005c:	83 ec 08             	sub    $0x8,%esp
  80005f:	52                   	push   %edx
  800060:	50                   	push   %eax
  800061:	e8 cd ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800066:	e8 05 00 00 00       	call   800070 <exit>
}
  80006b:	83 c4 10             	add    $0x10,%esp
  80006e:	c9                   	leave  
  80006f:	c3                   	ret    

00800070 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800070:	55                   	push   %ebp
  800071:	89 e5                	mov    %esp,%ebp
  800073:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800076:	6a 00                	push   $0x0
  800078:	e8 42 00 00 00       	call   8000bf <sys_env_destroy>
}
  80007d:	83 c4 10             	add    $0x10,%esp
  800080:	c9                   	leave  
  800081:	c3                   	ret    

00800082 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800082:	55                   	push   %ebp
  800083:	89 e5                	mov    %esp,%ebp
  800085:	57                   	push   %edi
  800086:	56                   	push   %esi
  800087:	53                   	push   %ebx
	asm volatile("int %1\n"
  800088:	b8 00 00 00 00       	mov    $0x0,%eax
  80008d:	8b 55 08             	mov    0x8(%ebp),%edx
  800090:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800093:	89 c3                	mov    %eax,%ebx
  800095:	89 c7                	mov    %eax,%edi
  800097:	89 c6                	mov    %eax,%esi
  800099:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  80009b:	5b                   	pop    %ebx
  80009c:	5e                   	pop    %esi
  80009d:	5f                   	pop    %edi
  80009e:	5d                   	pop    %ebp
  80009f:	c3                   	ret    

008000a0 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000a0:	55                   	push   %ebp
  8000a1:	89 e5                	mov    %esp,%ebp
  8000a3:	57                   	push   %edi
  8000a4:	56                   	push   %esi
  8000a5:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000a6:	ba 00 00 00 00       	mov    $0x0,%edx
  8000ab:	b8 01 00 00 00       	mov    $0x1,%eax
  8000b0:	89 d1                	mov    %edx,%ecx
  8000b2:	89 d3                	mov    %edx,%ebx
  8000b4:	89 d7                	mov    %edx,%edi
  8000b6:	89 d6                	mov    %edx,%esi
  8000b8:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000ba:	5b                   	pop    %ebx
  8000bb:	5e                   	pop    %esi
  8000bc:	5f                   	pop    %edi
  8000bd:	5d                   	pop    %ebp
  8000be:	c3                   	ret    

008000bf <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000bf:	55                   	push   %ebp
  8000c0:	89 e5                	mov    %esp,%ebp
  8000c2:	57                   	push   %edi
  8000c3:	56                   	push   %esi
  8000c4:	53                   	push   %ebx
  8000c5:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8000c8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000cd:	8b 55 08             	mov    0x8(%ebp),%edx
  8000d0:	b8 03 00 00 00       	mov    $0x3,%eax
  8000d5:	89 cb                	mov    %ecx,%ebx
  8000d7:	89 cf                	mov    %ecx,%edi
  8000d9:	89 ce                	mov    %ecx,%esi
  8000db:	cd 30                	int    $0x30
	if(check && ret > 0)
  8000dd:	85 c0                	test   %eax,%eax
  8000df:	7f 08                	jg     8000e9 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  8000e1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000e4:	5b                   	pop    %ebx
  8000e5:	5e                   	pop    %esi
  8000e6:	5f                   	pop    %edi
  8000e7:	5d                   	pop    %ebp
  8000e8:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8000e9:	83 ec 0c             	sub    $0xc,%esp
  8000ec:	50                   	push   %eax
  8000ed:	6a 03                	push   $0x3
  8000ef:	68 e6 0c 80 00       	push   $0x800ce6
  8000f4:	6a 23                	push   $0x23
  8000f6:	68 03 0d 80 00       	push   $0x800d03
  8000fb:	e8 1f 00 00 00       	call   80011f <_panic>

00800100 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800100:	55                   	push   %ebp
  800101:	89 e5                	mov    %esp,%ebp
  800103:	57                   	push   %edi
  800104:	56                   	push   %esi
  800105:	53                   	push   %ebx
	asm volatile("int %1\n"
  800106:	ba 00 00 00 00       	mov    $0x0,%edx
  80010b:	b8 02 00 00 00       	mov    $0x2,%eax
  800110:	89 d1                	mov    %edx,%ecx
  800112:	89 d3                	mov    %edx,%ebx
  800114:	89 d7                	mov    %edx,%edi
  800116:	89 d6                	mov    %edx,%esi
  800118:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80011a:	5b                   	pop    %ebx
  80011b:	5e                   	pop    %esi
  80011c:	5f                   	pop    %edi
  80011d:	5d                   	pop    %ebp
  80011e:	c3                   	ret    

0080011f <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80011f:	55                   	push   %ebp
  800120:	89 e5                	mov    %esp,%ebp
  800122:	56                   	push   %esi
  800123:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800124:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800127:	8b 35 00 10 80 00    	mov    0x801000,%esi
  80012d:	e8 ce ff ff ff       	call   800100 <sys_getenvid>
  800132:	83 ec 0c             	sub    $0xc,%esp
  800135:	ff 75 0c             	pushl  0xc(%ebp)
  800138:	ff 75 08             	pushl  0x8(%ebp)
  80013b:	56                   	push   %esi
  80013c:	50                   	push   %eax
  80013d:	68 14 0d 80 00       	push   $0x800d14
  800142:	e8 b2 00 00 00       	call   8001f9 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800147:	83 c4 18             	add    $0x18,%esp
  80014a:	53                   	push   %ebx
  80014b:	ff 75 10             	pushl  0x10(%ebp)
  80014e:	e8 55 00 00 00       	call   8001a8 <vcprintf>
	cprintf("\n");
  800153:	c7 04 24 38 0d 80 00 	movl   $0x800d38,(%esp)
  80015a:	e8 9a 00 00 00       	call   8001f9 <cprintf>
  80015f:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800162:	cc                   	int3   
  800163:	eb fd                	jmp    800162 <_panic+0x43>

00800165 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800165:	55                   	push   %ebp
  800166:	89 e5                	mov    %esp,%ebp
  800168:	53                   	push   %ebx
  800169:	83 ec 04             	sub    $0x4,%esp
  80016c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80016f:	8b 13                	mov    (%ebx),%edx
  800171:	8d 42 01             	lea    0x1(%edx),%eax
  800174:	89 03                	mov    %eax,(%ebx)
  800176:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800179:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80017d:	3d ff 00 00 00       	cmp    $0xff,%eax
  800182:	74 08                	je     80018c <putch+0x27>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800184:	ff 43 04             	incl   0x4(%ebx)
}
  800187:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80018a:	c9                   	leave  
  80018b:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  80018c:	83 ec 08             	sub    $0x8,%esp
  80018f:	68 ff 00 00 00       	push   $0xff
  800194:	8d 43 08             	lea    0x8(%ebx),%eax
  800197:	50                   	push   %eax
  800198:	e8 e5 fe ff ff       	call   800082 <sys_cputs>
		b->idx = 0;
  80019d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001a3:	83 c4 10             	add    $0x10,%esp
  8001a6:	eb dc                	jmp    800184 <putch+0x1f>

008001a8 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001a8:	55                   	push   %ebp
  8001a9:	89 e5                	mov    %esp,%ebp
  8001ab:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001b1:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001b8:	00 00 00 
	b.cnt = 0;
  8001bb:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001c2:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001c5:	ff 75 0c             	pushl  0xc(%ebp)
  8001c8:	ff 75 08             	pushl  0x8(%ebp)
  8001cb:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001d1:	50                   	push   %eax
  8001d2:	68 65 01 80 00       	push   $0x800165
  8001d7:	e8 0f 01 00 00       	call   8002eb <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001dc:	83 c4 08             	add    $0x8,%esp
  8001df:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001e5:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001eb:	50                   	push   %eax
  8001ec:	e8 91 fe ff ff       	call   800082 <sys_cputs>

	return b.cnt;
}
  8001f1:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001f7:	c9                   	leave  
  8001f8:	c3                   	ret    

008001f9 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001f9:	55                   	push   %ebp
  8001fa:	89 e5                	mov    %esp,%ebp
  8001fc:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001ff:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800202:	50                   	push   %eax
  800203:	ff 75 08             	pushl  0x8(%ebp)
  800206:	e8 9d ff ff ff       	call   8001a8 <vcprintf>
	va_end(ap);

	return cnt;
}
  80020b:	c9                   	leave  
  80020c:	c3                   	ret    

0080020d <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80020d:	55                   	push   %ebp
  80020e:	89 e5                	mov    %esp,%ebp
  800210:	57                   	push   %edi
  800211:	56                   	push   %esi
  800212:	53                   	push   %ebx
  800213:	83 ec 1c             	sub    $0x1c,%esp
  800216:	89 c7                	mov    %eax,%edi
  800218:	89 d6                	mov    %edx,%esi
  80021a:	8b 45 08             	mov    0x8(%ebp),%eax
  80021d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800220:	89 d1                	mov    %edx,%ecx
  800222:	89 c2                	mov    %eax,%edx
  800224:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800227:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80022a:	8b 45 10             	mov    0x10(%ebp),%eax
  80022d:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800230:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800233:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80023a:	39 c2                	cmp    %eax,%edx
  80023c:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  80023f:	72 3c                	jb     80027d <printnum+0x70>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800241:	83 ec 0c             	sub    $0xc,%esp
  800244:	ff 75 18             	pushl  0x18(%ebp)
  800247:	4b                   	dec    %ebx
  800248:	53                   	push   %ebx
  800249:	50                   	push   %eax
  80024a:	83 ec 08             	sub    $0x8,%esp
  80024d:	ff 75 e4             	pushl  -0x1c(%ebp)
  800250:	ff 75 e0             	pushl  -0x20(%ebp)
  800253:	ff 75 dc             	pushl  -0x24(%ebp)
  800256:	ff 75 d8             	pushl  -0x28(%ebp)
  800259:	e8 56 08 00 00       	call   800ab4 <__udivdi3>
  80025e:	83 c4 18             	add    $0x18,%esp
  800261:	52                   	push   %edx
  800262:	50                   	push   %eax
  800263:	89 f2                	mov    %esi,%edx
  800265:	89 f8                	mov    %edi,%eax
  800267:	e8 a1 ff ff ff       	call   80020d <printnum>
  80026c:	83 c4 20             	add    $0x20,%esp
  80026f:	eb 11                	jmp    800282 <printnum+0x75>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800271:	83 ec 08             	sub    $0x8,%esp
  800274:	56                   	push   %esi
  800275:	ff 75 18             	pushl  0x18(%ebp)
  800278:	ff d7                	call   *%edi
  80027a:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  80027d:	4b                   	dec    %ebx
  80027e:	85 db                	test   %ebx,%ebx
  800280:	7f ef                	jg     800271 <printnum+0x64>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800282:	83 ec 08             	sub    $0x8,%esp
  800285:	56                   	push   %esi
  800286:	83 ec 04             	sub    $0x4,%esp
  800289:	ff 75 e4             	pushl  -0x1c(%ebp)
  80028c:	ff 75 e0             	pushl  -0x20(%ebp)
  80028f:	ff 75 dc             	pushl  -0x24(%ebp)
  800292:	ff 75 d8             	pushl  -0x28(%ebp)
  800295:	e8 1a 09 00 00       	call   800bb4 <__umoddi3>
  80029a:	83 c4 14             	add    $0x14,%esp
  80029d:	0f be 80 3a 0d 80 00 	movsbl 0x800d3a(%eax),%eax
  8002a4:	50                   	push   %eax
  8002a5:	ff d7                	call   *%edi
}
  8002a7:	83 c4 10             	add    $0x10,%esp
  8002aa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002ad:	5b                   	pop    %ebx
  8002ae:	5e                   	pop    %esi
  8002af:	5f                   	pop    %edi
  8002b0:	5d                   	pop    %ebp
  8002b1:	c3                   	ret    

008002b2 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002b2:	55                   	push   %ebp
  8002b3:	89 e5                	mov    %esp,%ebp
  8002b5:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002b8:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8002bb:	8b 10                	mov    (%eax),%edx
  8002bd:	3b 50 04             	cmp    0x4(%eax),%edx
  8002c0:	73 0a                	jae    8002cc <sprintputch+0x1a>
		*b->buf++ = ch;
  8002c2:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002c5:	89 08                	mov    %ecx,(%eax)
  8002c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8002ca:	88 02                	mov    %al,(%edx)
}
  8002cc:	5d                   	pop    %ebp
  8002cd:	c3                   	ret    

008002ce <printfmt>:
{
  8002ce:	55                   	push   %ebp
  8002cf:	89 e5                	mov    %esp,%ebp
  8002d1:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8002d4:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002d7:	50                   	push   %eax
  8002d8:	ff 75 10             	pushl  0x10(%ebp)
  8002db:	ff 75 0c             	pushl  0xc(%ebp)
  8002de:	ff 75 08             	pushl  0x8(%ebp)
  8002e1:	e8 05 00 00 00       	call   8002eb <vprintfmt>
}
  8002e6:	83 c4 10             	add    $0x10,%esp
  8002e9:	c9                   	leave  
  8002ea:	c3                   	ret    

008002eb <vprintfmt>:
{
  8002eb:	55                   	push   %ebp
  8002ec:	89 e5                	mov    %esp,%ebp
  8002ee:	57                   	push   %edi
  8002ef:	56                   	push   %esi
  8002f0:	53                   	push   %ebx
  8002f1:	83 ec 3c             	sub    $0x3c,%esp
  8002f4:	8b 75 08             	mov    0x8(%ebp),%esi
  8002f7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002fa:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002fd:	e9 5b 03 00 00       	jmp    80065d <vprintfmt+0x372>
		padc = ' ';
  800302:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  800306:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
		precision = -1;
  80030d:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  800314:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		lflag = 0;
  80031b:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800320:	8d 47 01             	lea    0x1(%edi),%eax
  800323:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800326:	8a 17                	mov    (%edi),%dl
  800328:	8d 42 dd             	lea    -0x23(%edx),%eax
  80032b:	3c 55                	cmp    $0x55,%al
  80032d:	0f 87 ab 03 00 00    	ja     8006de <vprintfmt+0x3f3>
  800333:	0f b6 c0             	movzbl %al,%eax
  800336:	ff 24 85 c8 0d 80 00 	jmp    *0x800dc8(,%eax,4)
  80033d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800340:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  800344:	eb da                	jmp    800320 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  800346:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800349:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  80034d:	eb d1                	jmp    800320 <vprintfmt+0x35>
  80034f:	0f b6 d2             	movzbl %dl,%edx
  800352:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800355:	b8 00 00 00 00       	mov    $0x0,%eax
  80035a:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  80035d:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800360:	01 c0                	add    %eax,%eax
  800362:	8d 44 02 d0          	lea    -0x30(%edx,%eax,1),%eax
				ch = *fmt;
  800366:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800369:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80036c:	83 f9 09             	cmp    $0x9,%ecx
  80036f:	77 52                	ja     8003c3 <vprintfmt+0xd8>
			for (precision = 0; ; ++fmt) {
  800371:	47                   	inc    %edi
				precision = precision * 10 + ch - '0';
  800372:	eb e9                	jmp    80035d <vprintfmt+0x72>
			precision = va_arg(ap, int);
  800374:	8b 45 14             	mov    0x14(%ebp),%eax
  800377:	8b 00                	mov    (%eax),%eax
  800379:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80037c:	8b 45 14             	mov    0x14(%ebp),%eax
  80037f:	8d 40 04             	lea    0x4(%eax),%eax
  800382:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800385:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800388:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80038c:	79 92                	jns    800320 <vprintfmt+0x35>
				width = precision, precision = -1;
  80038e:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800391:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800394:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  80039b:	eb 83                	jmp    800320 <vprintfmt+0x35>
  80039d:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8003a1:	78 08                	js     8003ab <vprintfmt+0xc0>
		switch (ch = *(unsigned char *) fmt++) {
  8003a3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8003a6:	e9 75 ff ff ff       	jmp    800320 <vprintfmt+0x35>
  8003ab:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  8003b2:	eb ef                	jmp    8003a3 <vprintfmt+0xb8>
		switch (ch = *(unsigned char *) fmt++) {
  8003b4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8003b7:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  8003be:	e9 5d ff ff ff       	jmp    800320 <vprintfmt+0x35>
  8003c3:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8003c6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003c9:	eb bd                	jmp    800388 <vprintfmt+0x9d>
			lflag++;
  8003cb:	41                   	inc    %ecx
		switch (ch = *(unsigned char *) fmt++) {
  8003cc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8003cf:	e9 4c ff ff ff       	jmp    800320 <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
  8003d4:	8b 45 14             	mov    0x14(%ebp),%eax
  8003d7:	8d 78 04             	lea    0x4(%eax),%edi
  8003da:	83 ec 08             	sub    $0x8,%esp
  8003dd:	53                   	push   %ebx
  8003de:	ff 30                	pushl  (%eax)
  8003e0:	ff d6                	call   *%esi
			break;
  8003e2:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8003e5:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8003e8:	e9 6d 02 00 00       	jmp    80065a <vprintfmt+0x36f>
			err = va_arg(ap, int);
  8003ed:	8b 45 14             	mov    0x14(%ebp),%eax
  8003f0:	8d 78 04             	lea    0x4(%eax),%edi
  8003f3:	8b 00                	mov    (%eax),%eax
  8003f5:	85 c0                	test   %eax,%eax
  8003f7:	78 2a                	js     800423 <vprintfmt+0x138>
  8003f9:	89 c2                	mov    %eax,%edx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003fb:	83 f8 06             	cmp    $0x6,%eax
  8003fe:	7f 27                	jg     800427 <vprintfmt+0x13c>
  800400:	8b 04 85 20 0f 80 00 	mov    0x800f20(,%eax,4),%eax
  800407:	85 c0                	test   %eax,%eax
  800409:	74 1c                	je     800427 <vprintfmt+0x13c>
				printfmt(putch, putdat, "%s", p);
  80040b:	50                   	push   %eax
  80040c:	68 5b 0d 80 00       	push   $0x800d5b
  800411:	53                   	push   %ebx
  800412:	56                   	push   %esi
  800413:	e8 b6 fe ff ff       	call   8002ce <printfmt>
  800418:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80041b:	89 7d 14             	mov    %edi,0x14(%ebp)
  80041e:	e9 37 02 00 00       	jmp    80065a <vprintfmt+0x36f>
  800423:	f7 d8                	neg    %eax
  800425:	eb d2                	jmp    8003f9 <vprintfmt+0x10e>
				printfmt(putch, putdat, "error %d", err);
  800427:	52                   	push   %edx
  800428:	68 52 0d 80 00       	push   $0x800d52
  80042d:	53                   	push   %ebx
  80042e:	56                   	push   %esi
  80042f:	e8 9a fe ff ff       	call   8002ce <printfmt>
  800434:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800437:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  80043a:	e9 1b 02 00 00       	jmp    80065a <vprintfmt+0x36f>
			if ((p = va_arg(ap, char *)) == NULL)
  80043f:	8b 45 14             	mov    0x14(%ebp),%eax
  800442:	83 c0 04             	add    $0x4,%eax
  800445:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800448:	8b 45 14             	mov    0x14(%ebp),%eax
  80044b:	8b 00                	mov    (%eax),%eax
  80044d:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800450:	85 c0                	test   %eax,%eax
  800452:	74 19                	je     80046d <vprintfmt+0x182>
			if (width > 0 && padc != '-')
  800454:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800458:	7e 06                	jle    800460 <vprintfmt+0x175>
  80045a:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  80045e:	75 16                	jne    800476 <vprintfmt+0x18b>
				for (width -= strnlen(p, precision); width > 0; width--)
  800460:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800463:	89 c7                	mov    %eax,%edi
  800465:	03 45 d4             	add    -0x2c(%ebp),%eax
  800468:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80046b:	eb 62                	jmp    8004cf <vprintfmt+0x1e4>
				p = "(null)";
  80046d:	c7 45 cc 4b 0d 80 00 	movl   $0x800d4b,-0x34(%ebp)
  800474:	eb de                	jmp    800454 <vprintfmt+0x169>
				for (width -= strnlen(p, precision); width > 0; width--)
  800476:	83 ec 08             	sub    $0x8,%esp
  800479:	ff 75 d8             	pushl  -0x28(%ebp)
  80047c:	ff 75 cc             	pushl  -0x34(%ebp)
  80047f:	e8 05 03 00 00       	call   800789 <strnlen>
  800484:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800487:	29 c2                	sub    %eax,%edx
  800489:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  80048c:	83 c4 10             	add    $0x10,%esp
  80048f:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  800491:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  800495:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  800498:	eb 0d                	jmp    8004a7 <vprintfmt+0x1bc>
					putch(padc, putdat);
  80049a:	83 ec 08             	sub    $0x8,%esp
  80049d:	53                   	push   %ebx
  80049e:	ff 75 d4             	pushl  -0x2c(%ebp)
  8004a1:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8004a3:	4f                   	dec    %edi
  8004a4:	83 c4 10             	add    $0x10,%esp
  8004a7:	85 ff                	test   %edi,%edi
  8004a9:	7f ef                	jg     80049a <vprintfmt+0x1af>
  8004ab:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8004ae:	89 d0                	mov    %edx,%eax
  8004b0:	85 d2                	test   %edx,%edx
  8004b2:	78 0a                	js     8004be <vprintfmt+0x1d3>
  8004b4:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8004b7:	29 c2                	sub    %eax,%edx
  8004b9:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8004bc:	eb a2                	jmp    800460 <vprintfmt+0x175>
  8004be:	b8 00 00 00 00       	mov    $0x0,%eax
  8004c3:	eb ef                	jmp    8004b4 <vprintfmt+0x1c9>
					putch(ch, putdat);
  8004c5:	83 ec 08             	sub    $0x8,%esp
  8004c8:	53                   	push   %ebx
  8004c9:	52                   	push   %edx
  8004ca:	ff d6                	call   *%esi
  8004cc:	83 c4 10             	add    $0x10,%esp
  8004cf:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  8004d2:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004d4:	47                   	inc    %edi
  8004d5:	8a 47 ff             	mov    -0x1(%edi),%al
  8004d8:	0f be d0             	movsbl %al,%edx
  8004db:	85 d2                	test   %edx,%edx
  8004dd:	74 48                	je     800527 <vprintfmt+0x23c>
  8004df:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004e3:	78 05                	js     8004ea <vprintfmt+0x1ff>
  8004e5:	ff 4d d8             	decl   -0x28(%ebp)
  8004e8:	78 1e                	js     800508 <vprintfmt+0x21d>
				if (altflag && (ch < ' ' || ch > '~'))
  8004ea:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004ee:	74 d5                	je     8004c5 <vprintfmt+0x1da>
  8004f0:	0f be c0             	movsbl %al,%eax
  8004f3:	83 e8 20             	sub    $0x20,%eax
  8004f6:	83 f8 5e             	cmp    $0x5e,%eax
  8004f9:	76 ca                	jbe    8004c5 <vprintfmt+0x1da>
					putch('?', putdat);
  8004fb:	83 ec 08             	sub    $0x8,%esp
  8004fe:	53                   	push   %ebx
  8004ff:	6a 3f                	push   $0x3f
  800501:	ff d6                	call   *%esi
  800503:	83 c4 10             	add    $0x10,%esp
  800506:	eb c7                	jmp    8004cf <vprintfmt+0x1e4>
  800508:	89 cf                	mov    %ecx,%edi
  80050a:	eb 0c                	jmp    800518 <vprintfmt+0x22d>
				putch(' ', putdat);
  80050c:	83 ec 08             	sub    $0x8,%esp
  80050f:	53                   	push   %ebx
  800510:	6a 20                	push   $0x20
  800512:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800514:	4f                   	dec    %edi
  800515:	83 c4 10             	add    $0x10,%esp
  800518:	85 ff                	test   %edi,%edi
  80051a:	7f f0                	jg     80050c <vprintfmt+0x221>
			if ((p = va_arg(ap, char *)) == NULL)
  80051c:	8b 45 c8             	mov    -0x38(%ebp),%eax
  80051f:	89 45 14             	mov    %eax,0x14(%ebp)
  800522:	e9 33 01 00 00       	jmp    80065a <vprintfmt+0x36f>
  800527:	89 cf                	mov    %ecx,%edi
  800529:	eb ed                	jmp    800518 <vprintfmt+0x22d>
	if (lflag >= 2)
  80052b:	83 f9 01             	cmp    $0x1,%ecx
  80052e:	7f 1b                	jg     80054b <vprintfmt+0x260>
	else if (lflag)
  800530:	85 c9                	test   %ecx,%ecx
  800532:	74 42                	je     800576 <vprintfmt+0x28b>
		return va_arg(*ap, long);
  800534:	8b 45 14             	mov    0x14(%ebp),%eax
  800537:	8b 00                	mov    (%eax),%eax
  800539:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80053c:	99                   	cltd   
  80053d:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800540:	8b 45 14             	mov    0x14(%ebp),%eax
  800543:	8d 40 04             	lea    0x4(%eax),%eax
  800546:	89 45 14             	mov    %eax,0x14(%ebp)
  800549:	eb 17                	jmp    800562 <vprintfmt+0x277>
		return va_arg(*ap, long long);
  80054b:	8b 45 14             	mov    0x14(%ebp),%eax
  80054e:	8b 50 04             	mov    0x4(%eax),%edx
  800551:	8b 00                	mov    (%eax),%eax
  800553:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800556:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800559:	8b 45 14             	mov    0x14(%ebp),%eax
  80055c:	8d 40 08             	lea    0x8(%eax),%eax
  80055f:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800562:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800565:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800568:	85 c9                	test   %ecx,%ecx
  80056a:	78 21                	js     80058d <vprintfmt+0x2a2>
			base = 10;
  80056c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800571:	e9 ca 00 00 00       	jmp    800640 <vprintfmt+0x355>
		return va_arg(*ap, int);
  800576:	8b 45 14             	mov    0x14(%ebp),%eax
  800579:	8b 00                	mov    (%eax),%eax
  80057b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80057e:	99                   	cltd   
  80057f:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800582:	8b 45 14             	mov    0x14(%ebp),%eax
  800585:	8d 40 04             	lea    0x4(%eax),%eax
  800588:	89 45 14             	mov    %eax,0x14(%ebp)
  80058b:	eb d5                	jmp    800562 <vprintfmt+0x277>
				putch('-', putdat);
  80058d:	83 ec 08             	sub    $0x8,%esp
  800590:	53                   	push   %ebx
  800591:	6a 2d                	push   $0x2d
  800593:	ff d6                	call   *%esi
				num = -(long long) num;
  800595:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800598:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80059b:	f7 da                	neg    %edx
  80059d:	83 d1 00             	adc    $0x0,%ecx
  8005a0:	f7 d9                	neg    %ecx
  8005a2:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8005a5:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005aa:	e9 91 00 00 00       	jmp    800640 <vprintfmt+0x355>
	if (lflag >= 2)
  8005af:	83 f9 01             	cmp    $0x1,%ecx
  8005b2:	7f 1b                	jg     8005cf <vprintfmt+0x2e4>
	else if (lflag)
  8005b4:	85 c9                	test   %ecx,%ecx
  8005b6:	74 2c                	je     8005e4 <vprintfmt+0x2f9>
		return va_arg(*ap, unsigned long);
  8005b8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005bb:	8b 10                	mov    (%eax),%edx
  8005bd:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005c2:	8d 40 04             	lea    0x4(%eax),%eax
  8005c5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005c8:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  8005cd:	eb 71                	jmp    800640 <vprintfmt+0x355>
		return va_arg(*ap, unsigned long long);
  8005cf:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d2:	8b 10                	mov    (%eax),%edx
  8005d4:	8b 48 04             	mov    0x4(%eax),%ecx
  8005d7:	8d 40 08             	lea    0x8(%eax),%eax
  8005da:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005dd:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  8005e2:	eb 5c                	jmp    800640 <vprintfmt+0x355>
		return va_arg(*ap, unsigned int);
  8005e4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e7:	8b 10                	mov    (%eax),%edx
  8005e9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005ee:	8d 40 04             	lea    0x4(%eax),%eax
  8005f1:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005f4:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  8005f9:	eb 45                	jmp    800640 <vprintfmt+0x355>
			putch('X', putdat);
  8005fb:	83 ec 08             	sub    $0x8,%esp
  8005fe:	53                   	push   %ebx
  8005ff:	6a 58                	push   $0x58
  800601:	ff d6                	call   *%esi
			putch('X', putdat);
  800603:	83 c4 08             	add    $0x8,%esp
  800606:	53                   	push   %ebx
  800607:	6a 58                	push   $0x58
  800609:	ff d6                	call   *%esi
			putch('X', putdat);
  80060b:	83 c4 08             	add    $0x8,%esp
  80060e:	53                   	push   %ebx
  80060f:	6a 58                	push   $0x58
  800611:	ff d6                	call   *%esi
			break;
  800613:	83 c4 10             	add    $0x10,%esp
  800616:	eb 42                	jmp    80065a <vprintfmt+0x36f>
			putch('0', putdat);
  800618:	83 ec 08             	sub    $0x8,%esp
  80061b:	53                   	push   %ebx
  80061c:	6a 30                	push   $0x30
  80061e:	ff d6                	call   *%esi
			putch('x', putdat);
  800620:	83 c4 08             	add    $0x8,%esp
  800623:	53                   	push   %ebx
  800624:	6a 78                	push   $0x78
  800626:	ff d6                	call   *%esi
			num = (unsigned long long)
  800628:	8b 45 14             	mov    0x14(%ebp),%eax
  80062b:	8b 10                	mov    (%eax),%edx
  80062d:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800632:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800635:	8d 40 04             	lea    0x4(%eax),%eax
  800638:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80063b:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  800640:	83 ec 0c             	sub    $0xc,%esp
  800643:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  800647:	57                   	push   %edi
  800648:	ff 75 d4             	pushl  -0x2c(%ebp)
  80064b:	50                   	push   %eax
  80064c:	51                   	push   %ecx
  80064d:	52                   	push   %edx
  80064e:	89 da                	mov    %ebx,%edx
  800650:	89 f0                	mov    %esi,%eax
  800652:	e8 b6 fb ff ff       	call   80020d <printnum>
			break;
  800657:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  80065a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80065d:	47                   	inc    %edi
  80065e:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800662:	83 f8 25             	cmp    $0x25,%eax
  800665:	0f 84 97 fc ff ff    	je     800302 <vprintfmt+0x17>
			if (ch == '\0')
  80066b:	85 c0                	test   %eax,%eax
  80066d:	0f 84 89 00 00 00    	je     8006fc <vprintfmt+0x411>
			putch(ch, putdat);
  800673:	83 ec 08             	sub    $0x8,%esp
  800676:	53                   	push   %ebx
  800677:	50                   	push   %eax
  800678:	ff d6                	call   *%esi
  80067a:	83 c4 10             	add    $0x10,%esp
  80067d:	eb de                	jmp    80065d <vprintfmt+0x372>
	if (lflag >= 2)
  80067f:	83 f9 01             	cmp    $0x1,%ecx
  800682:	7f 1b                	jg     80069f <vprintfmt+0x3b4>
	else if (lflag)
  800684:	85 c9                	test   %ecx,%ecx
  800686:	74 2c                	je     8006b4 <vprintfmt+0x3c9>
		return va_arg(*ap, unsigned long);
  800688:	8b 45 14             	mov    0x14(%ebp),%eax
  80068b:	8b 10                	mov    (%eax),%edx
  80068d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800692:	8d 40 04             	lea    0x4(%eax),%eax
  800695:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800698:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  80069d:	eb a1                	jmp    800640 <vprintfmt+0x355>
		return va_arg(*ap, unsigned long long);
  80069f:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a2:	8b 10                	mov    (%eax),%edx
  8006a4:	8b 48 04             	mov    0x4(%eax),%ecx
  8006a7:	8d 40 08             	lea    0x8(%eax),%eax
  8006aa:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006ad:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  8006b2:	eb 8c                	jmp    800640 <vprintfmt+0x355>
		return va_arg(*ap, unsigned int);
  8006b4:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b7:	8b 10                	mov    (%eax),%edx
  8006b9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006be:	8d 40 04             	lea    0x4(%eax),%eax
  8006c1:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006c4:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  8006c9:	e9 72 ff ff ff       	jmp    800640 <vprintfmt+0x355>
			putch(ch, putdat);
  8006ce:	83 ec 08             	sub    $0x8,%esp
  8006d1:	53                   	push   %ebx
  8006d2:	6a 25                	push   $0x25
  8006d4:	ff d6                	call   *%esi
			break;
  8006d6:	83 c4 10             	add    $0x10,%esp
  8006d9:	e9 7c ff ff ff       	jmp    80065a <vprintfmt+0x36f>
			putch('%', putdat);
  8006de:	83 ec 08             	sub    $0x8,%esp
  8006e1:	53                   	push   %ebx
  8006e2:	6a 25                	push   $0x25
  8006e4:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006e6:	83 c4 10             	add    $0x10,%esp
  8006e9:	89 f8                	mov    %edi,%eax
  8006eb:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8006ef:	74 03                	je     8006f4 <vprintfmt+0x409>
  8006f1:	48                   	dec    %eax
  8006f2:	eb f7                	jmp    8006eb <vprintfmt+0x400>
  8006f4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8006f7:	e9 5e ff ff ff       	jmp    80065a <vprintfmt+0x36f>
}
  8006fc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006ff:	5b                   	pop    %ebx
  800700:	5e                   	pop    %esi
  800701:	5f                   	pop    %edi
  800702:	5d                   	pop    %ebp
  800703:	c3                   	ret    

00800704 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800704:	55                   	push   %ebp
  800705:	89 e5                	mov    %esp,%ebp
  800707:	83 ec 18             	sub    $0x18,%esp
  80070a:	8b 45 08             	mov    0x8(%ebp),%eax
  80070d:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800710:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800713:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800717:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80071a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800721:	85 c0                	test   %eax,%eax
  800723:	74 26                	je     80074b <vsnprintf+0x47>
  800725:	85 d2                	test   %edx,%edx
  800727:	7e 29                	jle    800752 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800729:	ff 75 14             	pushl  0x14(%ebp)
  80072c:	ff 75 10             	pushl  0x10(%ebp)
  80072f:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800732:	50                   	push   %eax
  800733:	68 b2 02 80 00       	push   $0x8002b2
  800738:	e8 ae fb ff ff       	call   8002eb <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80073d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800740:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800743:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800746:	83 c4 10             	add    $0x10,%esp
}
  800749:	c9                   	leave  
  80074a:	c3                   	ret    
		return -E_INVAL;
  80074b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800750:	eb f7                	jmp    800749 <vsnprintf+0x45>
  800752:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800757:	eb f0                	jmp    800749 <vsnprintf+0x45>

00800759 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800759:	55                   	push   %ebp
  80075a:	89 e5                	mov    %esp,%ebp
  80075c:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80075f:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800762:	50                   	push   %eax
  800763:	ff 75 10             	pushl  0x10(%ebp)
  800766:	ff 75 0c             	pushl  0xc(%ebp)
  800769:	ff 75 08             	pushl  0x8(%ebp)
  80076c:	e8 93 ff ff ff       	call   800704 <vsnprintf>
	va_end(ap);

	return rc;
}
  800771:	c9                   	leave  
  800772:	c3                   	ret    

00800773 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800773:	55                   	push   %ebp
  800774:	89 e5                	mov    %esp,%ebp
  800776:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800779:	b8 00 00 00 00       	mov    $0x0,%eax
  80077e:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800782:	74 03                	je     800787 <strlen+0x14>
		n++;
  800784:	40                   	inc    %eax
  800785:	eb f7                	jmp    80077e <strlen+0xb>
	return n;
}
  800787:	5d                   	pop    %ebp
  800788:	c3                   	ret    

00800789 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800789:	55                   	push   %ebp
  80078a:	89 e5                	mov    %esp,%ebp
  80078c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80078f:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800792:	b8 00 00 00 00       	mov    $0x0,%eax
  800797:	39 d0                	cmp    %edx,%eax
  800799:	74 0b                	je     8007a6 <strnlen+0x1d>
  80079b:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80079f:	74 03                	je     8007a4 <strnlen+0x1b>
		n++;
  8007a1:	40                   	inc    %eax
  8007a2:	eb f3                	jmp    800797 <strnlen+0xe>
  8007a4:	89 c2                	mov    %eax,%edx
	return n;
}
  8007a6:	89 d0                	mov    %edx,%eax
  8007a8:	5d                   	pop    %ebp
  8007a9:	c3                   	ret    

008007aa <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007aa:	55                   	push   %ebp
  8007ab:	89 e5                	mov    %esp,%ebp
  8007ad:	53                   	push   %ebx
  8007ae:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007b1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007b4:	b8 00 00 00 00       	mov    $0x0,%eax
  8007b9:	8a 14 03             	mov    (%ebx,%eax,1),%dl
  8007bc:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8007bf:	40                   	inc    %eax
  8007c0:	84 d2                	test   %dl,%dl
  8007c2:	75 f5                	jne    8007b9 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8007c4:	89 c8                	mov    %ecx,%eax
  8007c6:	5b                   	pop    %ebx
  8007c7:	5d                   	pop    %ebp
  8007c8:	c3                   	ret    

008007c9 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007c9:	55                   	push   %ebp
  8007ca:	89 e5                	mov    %esp,%ebp
  8007cc:	53                   	push   %ebx
  8007cd:	83 ec 10             	sub    $0x10,%esp
  8007d0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007d3:	53                   	push   %ebx
  8007d4:	e8 9a ff ff ff       	call   800773 <strlen>
  8007d9:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  8007dc:	ff 75 0c             	pushl  0xc(%ebp)
  8007df:	01 d8                	add    %ebx,%eax
  8007e1:	50                   	push   %eax
  8007e2:	e8 c3 ff ff ff       	call   8007aa <strcpy>
	return dst;
}
  8007e7:	89 d8                	mov    %ebx,%eax
  8007e9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007ec:	c9                   	leave  
  8007ed:	c3                   	ret    

008007ee <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007ee:	55                   	push   %ebp
  8007ef:	89 e5                	mov    %esp,%ebp
  8007f1:	53                   	push   %ebx
  8007f2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007f5:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8007f8:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8007fe:	39 d8                	cmp    %ebx,%eax
  800800:	74 0e                	je     800810 <strncpy+0x22>
		*dst++ = *src;
  800802:	40                   	inc    %eax
  800803:	8a 0a                	mov    (%edx),%cl
  800805:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800808:	80 f9 01             	cmp    $0x1,%cl
  80080b:	83 da ff             	sbb    $0xffffffff,%edx
  80080e:	eb ee                	jmp    8007fe <strncpy+0x10>
	}
	return ret;
}
  800810:	8b 45 08             	mov    0x8(%ebp),%eax
  800813:	5b                   	pop    %ebx
  800814:	5d                   	pop    %ebp
  800815:	c3                   	ret    

00800816 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800816:	55                   	push   %ebp
  800817:	89 e5                	mov    %esp,%ebp
  800819:	56                   	push   %esi
  80081a:	53                   	push   %ebx
  80081b:	8b 75 08             	mov    0x8(%ebp),%esi
  80081e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800821:	8b 45 10             	mov    0x10(%ebp),%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800824:	85 c0                	test   %eax,%eax
  800826:	74 22                	je     80084a <strlcpy+0x34>
  800828:	8d 44 06 ff          	lea    -0x1(%esi,%eax,1),%eax
  80082c:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  80082e:	39 c2                	cmp    %eax,%edx
  800830:	74 0f                	je     800841 <strlcpy+0x2b>
  800832:	8a 19                	mov    (%ecx),%bl
  800834:	84 db                	test   %bl,%bl
  800836:	74 07                	je     80083f <strlcpy+0x29>
			*dst++ = *src++;
  800838:	41                   	inc    %ecx
  800839:	42                   	inc    %edx
  80083a:	88 5a ff             	mov    %bl,-0x1(%edx)
  80083d:	eb ef                	jmp    80082e <strlcpy+0x18>
  80083f:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800841:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800844:	29 f0                	sub    %esi,%eax
}
  800846:	5b                   	pop    %ebx
  800847:	5e                   	pop    %esi
  800848:	5d                   	pop    %ebp
  800849:	c3                   	ret    
  80084a:	89 f0                	mov    %esi,%eax
  80084c:	eb f6                	jmp    800844 <strlcpy+0x2e>

0080084e <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80084e:	55                   	push   %ebp
  80084f:	89 e5                	mov    %esp,%ebp
  800851:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800854:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800857:	8a 01                	mov    (%ecx),%al
  800859:	84 c0                	test   %al,%al
  80085b:	74 08                	je     800865 <strcmp+0x17>
  80085d:	3a 02                	cmp    (%edx),%al
  80085f:	75 04                	jne    800865 <strcmp+0x17>
		p++, q++;
  800861:	41                   	inc    %ecx
  800862:	42                   	inc    %edx
  800863:	eb f2                	jmp    800857 <strcmp+0x9>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800865:	0f b6 c0             	movzbl %al,%eax
  800868:	0f b6 12             	movzbl (%edx),%edx
  80086b:	29 d0                	sub    %edx,%eax
}
  80086d:	5d                   	pop    %ebp
  80086e:	c3                   	ret    

0080086f <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80086f:	55                   	push   %ebp
  800870:	89 e5                	mov    %esp,%ebp
  800872:	53                   	push   %ebx
  800873:	8b 45 08             	mov    0x8(%ebp),%eax
  800876:	8b 55 0c             	mov    0xc(%ebp),%edx
  800879:	89 c3                	mov    %eax,%ebx
  80087b:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80087e:	eb 02                	jmp    800882 <strncmp+0x13>
		n--, p++, q++;
  800880:	40                   	inc    %eax
  800881:	42                   	inc    %edx
	while (n > 0 && *p && *p == *q)
  800882:	39 d8                	cmp    %ebx,%eax
  800884:	74 15                	je     80089b <strncmp+0x2c>
  800886:	8a 08                	mov    (%eax),%cl
  800888:	84 c9                	test   %cl,%cl
  80088a:	74 04                	je     800890 <strncmp+0x21>
  80088c:	3a 0a                	cmp    (%edx),%cl
  80088e:	74 f0                	je     800880 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800890:	0f b6 00             	movzbl (%eax),%eax
  800893:	0f b6 12             	movzbl (%edx),%edx
  800896:	29 d0                	sub    %edx,%eax
}
  800898:	5b                   	pop    %ebx
  800899:	5d                   	pop    %ebp
  80089a:	c3                   	ret    
		return 0;
  80089b:	b8 00 00 00 00       	mov    $0x0,%eax
  8008a0:	eb f6                	jmp    800898 <strncmp+0x29>

008008a2 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008a2:	55                   	push   %ebp
  8008a3:	89 e5                	mov    %esp,%ebp
  8008a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a8:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8008ab:	8a 10                	mov    (%eax),%dl
  8008ad:	84 d2                	test   %dl,%dl
  8008af:	74 07                	je     8008b8 <strchr+0x16>
		if (*s == c)
  8008b1:	38 ca                	cmp    %cl,%dl
  8008b3:	74 08                	je     8008bd <strchr+0x1b>
	for (; *s; s++)
  8008b5:	40                   	inc    %eax
  8008b6:	eb f3                	jmp    8008ab <strchr+0x9>
			return (char *) s;
	return 0;
  8008b8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008bd:	5d                   	pop    %ebp
  8008be:	c3                   	ret    

008008bf <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008bf:	55                   	push   %ebp
  8008c0:	89 e5                	mov    %esp,%ebp
  8008c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c5:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8008c8:	8a 10                	mov    (%eax),%dl
  8008ca:	84 d2                	test   %dl,%dl
  8008cc:	74 07                	je     8008d5 <strfind+0x16>
		if (*s == c)
  8008ce:	38 ca                	cmp    %cl,%dl
  8008d0:	74 03                	je     8008d5 <strfind+0x16>
	for (; *s; s++)
  8008d2:	40                   	inc    %eax
  8008d3:	eb f3                	jmp    8008c8 <strfind+0x9>
			break;
	return (char *) s;
}
  8008d5:	5d                   	pop    %ebp
  8008d6:	c3                   	ret    

008008d7 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008d7:	55                   	push   %ebp
  8008d8:	89 e5                	mov    %esp,%ebp
  8008da:	57                   	push   %edi
  8008db:	56                   	push   %esi
  8008dc:	53                   	push   %ebx
  8008dd:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008e0:	85 c9                	test   %ecx,%ecx
  8008e2:	74 36                	je     80091a <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008e4:	89 c8                	mov    %ecx,%eax
  8008e6:	0b 45 08             	or     0x8(%ebp),%eax
  8008e9:	a8 03                	test   $0x3,%al
  8008eb:	75 24                	jne    800911 <memset+0x3a>
		c &= 0xFF;
  8008ed:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008f1:	89 d3                	mov    %edx,%ebx
  8008f3:	c1 e3 08             	shl    $0x8,%ebx
  8008f6:	89 d0                	mov    %edx,%eax
  8008f8:	c1 e0 18             	shl    $0x18,%eax
  8008fb:	89 d6                	mov    %edx,%esi
  8008fd:	c1 e6 10             	shl    $0x10,%esi
  800900:	09 f0                	or     %esi,%eax
  800902:	09 d0                	or     %edx,%eax
  800904:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800906:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800909:	8b 7d 08             	mov    0x8(%ebp),%edi
  80090c:	fc                   	cld    
  80090d:	f3 ab                	rep stos %eax,%es:(%edi)
  80090f:	eb 09                	jmp    80091a <memset+0x43>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800911:	8b 7d 08             	mov    0x8(%ebp),%edi
  800914:	8b 45 0c             	mov    0xc(%ebp),%eax
  800917:	fc                   	cld    
  800918:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80091a:	8b 45 08             	mov    0x8(%ebp),%eax
  80091d:	5b                   	pop    %ebx
  80091e:	5e                   	pop    %esi
  80091f:	5f                   	pop    %edi
  800920:	5d                   	pop    %ebp
  800921:	c3                   	ret    

00800922 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800922:	55                   	push   %ebp
  800923:	89 e5                	mov    %esp,%ebp
  800925:	57                   	push   %edi
  800926:	56                   	push   %esi
  800927:	8b 45 08             	mov    0x8(%ebp),%eax
  80092a:	8b 75 0c             	mov    0xc(%ebp),%esi
  80092d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800930:	39 c6                	cmp    %eax,%esi
  800932:	73 30                	jae    800964 <memmove+0x42>
  800934:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800937:	39 c2                	cmp    %eax,%edx
  800939:	76 29                	jbe    800964 <memmove+0x42>
		s += n;
		d += n;
  80093b:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80093e:	89 fe                	mov    %edi,%esi
  800940:	09 ce                	or     %ecx,%esi
  800942:	09 d6                	or     %edx,%esi
  800944:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80094a:	75 0e                	jne    80095a <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  80094c:	83 ef 04             	sub    $0x4,%edi
  80094f:	8d 72 fc             	lea    -0x4(%edx),%esi
  800952:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800955:	fd                   	std    
  800956:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800958:	eb 07                	jmp    800961 <memmove+0x3f>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80095a:	4f                   	dec    %edi
  80095b:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  80095e:	fd                   	std    
  80095f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800961:	fc                   	cld    
  800962:	eb 1a                	jmp    80097e <memmove+0x5c>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800964:	89 c2                	mov    %eax,%edx
  800966:	09 ca                	or     %ecx,%edx
  800968:	09 f2                	or     %esi,%edx
  80096a:	f6 c2 03             	test   $0x3,%dl
  80096d:	75 0a                	jne    800979 <memmove+0x57>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  80096f:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800972:	89 c7                	mov    %eax,%edi
  800974:	fc                   	cld    
  800975:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800977:	eb 05                	jmp    80097e <memmove+0x5c>
		else
			asm volatile("cld; rep movsb\n"
  800979:	89 c7                	mov    %eax,%edi
  80097b:	fc                   	cld    
  80097c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80097e:	5e                   	pop    %esi
  80097f:	5f                   	pop    %edi
  800980:	5d                   	pop    %ebp
  800981:	c3                   	ret    

00800982 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800982:	55                   	push   %ebp
  800983:	89 e5                	mov    %esp,%ebp
  800985:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800988:	ff 75 10             	pushl  0x10(%ebp)
  80098b:	ff 75 0c             	pushl  0xc(%ebp)
  80098e:	ff 75 08             	pushl  0x8(%ebp)
  800991:	e8 8c ff ff ff       	call   800922 <memmove>
}
  800996:	c9                   	leave  
  800997:	c3                   	ret    

00800998 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800998:	55                   	push   %ebp
  800999:	89 e5                	mov    %esp,%ebp
  80099b:	56                   	push   %esi
  80099c:	53                   	push   %ebx
  80099d:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009a3:	89 c6                	mov    %eax,%esi
  8009a5:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009a8:	39 f0                	cmp    %esi,%eax
  8009aa:	74 16                	je     8009c2 <memcmp+0x2a>
		if (*s1 != *s2)
  8009ac:	8a 08                	mov    (%eax),%cl
  8009ae:	8a 1a                	mov    (%edx),%bl
  8009b0:	38 d9                	cmp    %bl,%cl
  8009b2:	75 04                	jne    8009b8 <memcmp+0x20>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  8009b4:	40                   	inc    %eax
  8009b5:	42                   	inc    %edx
  8009b6:	eb f0                	jmp    8009a8 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  8009b8:	0f b6 c1             	movzbl %cl,%eax
  8009bb:	0f b6 db             	movzbl %bl,%ebx
  8009be:	29 d8                	sub    %ebx,%eax
  8009c0:	eb 05                	jmp    8009c7 <memcmp+0x2f>
	}

	return 0;
  8009c2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009c7:	5b                   	pop    %ebx
  8009c8:	5e                   	pop    %esi
  8009c9:	5d                   	pop    %ebp
  8009ca:	c3                   	ret    

008009cb <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009cb:	55                   	push   %ebp
  8009cc:	89 e5                	mov    %esp,%ebp
  8009ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8009d4:	89 c2                	mov    %eax,%edx
  8009d6:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8009d9:	39 d0                	cmp    %edx,%eax
  8009db:	73 07                	jae    8009e4 <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009dd:	38 08                	cmp    %cl,(%eax)
  8009df:	74 03                	je     8009e4 <memfind+0x19>
	for (; s < ends; s++)
  8009e1:	40                   	inc    %eax
  8009e2:	eb f5                	jmp    8009d9 <memfind+0xe>
			break;
	return (void *) s;
}
  8009e4:	5d                   	pop    %ebp
  8009e5:	c3                   	ret    

008009e6 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009e6:	55                   	push   %ebp
  8009e7:	89 e5                	mov    %esp,%ebp
  8009e9:	57                   	push   %edi
  8009ea:	56                   	push   %esi
  8009eb:	53                   	push   %ebx
  8009ec:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009ef:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009f2:	eb 01                	jmp    8009f5 <strtol+0xf>
		s++;
  8009f4:	41                   	inc    %ecx
	while (*s == ' ' || *s == '\t')
  8009f5:	8a 01                	mov    (%ecx),%al
  8009f7:	3c 20                	cmp    $0x20,%al
  8009f9:	74 f9                	je     8009f4 <strtol+0xe>
  8009fb:	3c 09                	cmp    $0x9,%al
  8009fd:	74 f5                	je     8009f4 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  8009ff:	3c 2b                	cmp    $0x2b,%al
  800a01:	74 24                	je     800a27 <strtol+0x41>
		s++;
	else if (*s == '-')
  800a03:	3c 2d                	cmp    $0x2d,%al
  800a05:	74 28                	je     800a2f <strtol+0x49>
	int neg = 0;
  800a07:	bf 00 00 00 00       	mov    $0x0,%edi
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a0c:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a12:	75 09                	jne    800a1d <strtol+0x37>
  800a14:	80 39 30             	cmpb   $0x30,(%ecx)
  800a17:	74 1e                	je     800a37 <strtol+0x51>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a19:	85 db                	test   %ebx,%ebx
  800a1b:	74 36                	je     800a53 <strtol+0x6d>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a1d:	b8 00 00 00 00       	mov    $0x0,%eax
  800a22:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800a25:	eb 45                	jmp    800a6c <strtol+0x86>
		s++;
  800a27:	41                   	inc    %ecx
	int neg = 0;
  800a28:	bf 00 00 00 00       	mov    $0x0,%edi
  800a2d:	eb dd                	jmp    800a0c <strtol+0x26>
		s++, neg = 1;
  800a2f:	41                   	inc    %ecx
  800a30:	bf 01 00 00 00       	mov    $0x1,%edi
  800a35:	eb d5                	jmp    800a0c <strtol+0x26>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a37:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a3b:	74 0c                	je     800a49 <strtol+0x63>
	else if (base == 0 && s[0] == '0')
  800a3d:	85 db                	test   %ebx,%ebx
  800a3f:	75 dc                	jne    800a1d <strtol+0x37>
		s++, base = 8;
  800a41:	41                   	inc    %ecx
  800a42:	bb 08 00 00 00       	mov    $0x8,%ebx
  800a47:	eb d4                	jmp    800a1d <strtol+0x37>
		s += 2, base = 16;
  800a49:	83 c1 02             	add    $0x2,%ecx
  800a4c:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a51:	eb ca                	jmp    800a1d <strtol+0x37>
		base = 10;
  800a53:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800a58:	eb c3                	jmp    800a1d <strtol+0x37>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800a5a:	0f be d2             	movsbl %dl,%edx
  800a5d:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800a60:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a63:	7d 37                	jge    800a9c <strtol+0xb6>
			break;
		s++, val = (val * base) + dig;
  800a65:	41                   	inc    %ecx
  800a66:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a6a:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800a6c:	8a 11                	mov    (%ecx),%dl
  800a6e:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a71:	89 f3                	mov    %esi,%ebx
  800a73:	80 fb 09             	cmp    $0x9,%bl
  800a76:	76 e2                	jbe    800a5a <strtol+0x74>
		else if (*s >= 'a' && *s <= 'z')
  800a78:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a7b:	89 f3                	mov    %esi,%ebx
  800a7d:	80 fb 19             	cmp    $0x19,%bl
  800a80:	77 08                	ja     800a8a <strtol+0xa4>
			dig = *s - 'a' + 10;
  800a82:	0f be d2             	movsbl %dl,%edx
  800a85:	83 ea 57             	sub    $0x57,%edx
  800a88:	eb d6                	jmp    800a60 <strtol+0x7a>
		else if (*s >= 'A' && *s <= 'Z')
  800a8a:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a8d:	89 f3                	mov    %esi,%ebx
  800a8f:	80 fb 19             	cmp    $0x19,%bl
  800a92:	77 08                	ja     800a9c <strtol+0xb6>
			dig = *s - 'A' + 10;
  800a94:	0f be d2             	movsbl %dl,%edx
  800a97:	83 ea 37             	sub    $0x37,%edx
  800a9a:	eb c4                	jmp    800a60 <strtol+0x7a>
		// we don't properly detect overflow!
	}

	if (endptr)
  800a9c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800aa0:	74 05                	je     800aa7 <strtol+0xc1>
		*endptr = (char *) s;
  800aa2:	8b 75 0c             	mov    0xc(%ebp),%esi
  800aa5:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800aa7:	85 ff                	test   %edi,%edi
  800aa9:	74 02                	je     800aad <strtol+0xc7>
  800aab:	f7 d8                	neg    %eax
}
  800aad:	5b                   	pop    %ebx
  800aae:	5e                   	pop    %esi
  800aaf:	5f                   	pop    %edi
  800ab0:	5d                   	pop    %ebp
  800ab1:	c3                   	ret    
  800ab2:	66 90                	xchg   %ax,%ax

00800ab4 <__udivdi3>:
  800ab4:	55                   	push   %ebp
  800ab5:	57                   	push   %edi
  800ab6:	56                   	push   %esi
  800ab7:	53                   	push   %ebx
  800ab8:	83 ec 1c             	sub    $0x1c,%esp
  800abb:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800abf:	8b 74 24 34          	mov    0x34(%esp),%esi
  800ac3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800ac7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800acb:	85 d2                	test   %edx,%edx
  800acd:	75 19                	jne    800ae8 <__udivdi3+0x34>
  800acf:	39 f7                	cmp    %esi,%edi
  800ad1:	76 45                	jbe    800b18 <__udivdi3+0x64>
  800ad3:	89 e8                	mov    %ebp,%eax
  800ad5:	89 f2                	mov    %esi,%edx
  800ad7:	f7 f7                	div    %edi
  800ad9:	31 db                	xor    %ebx,%ebx
  800adb:	89 da                	mov    %ebx,%edx
  800add:	83 c4 1c             	add    $0x1c,%esp
  800ae0:	5b                   	pop    %ebx
  800ae1:	5e                   	pop    %esi
  800ae2:	5f                   	pop    %edi
  800ae3:	5d                   	pop    %ebp
  800ae4:	c3                   	ret    
  800ae5:	8d 76 00             	lea    0x0(%esi),%esi
  800ae8:	39 f2                	cmp    %esi,%edx
  800aea:	76 10                	jbe    800afc <__udivdi3+0x48>
  800aec:	31 db                	xor    %ebx,%ebx
  800aee:	31 c0                	xor    %eax,%eax
  800af0:	89 da                	mov    %ebx,%edx
  800af2:	83 c4 1c             	add    $0x1c,%esp
  800af5:	5b                   	pop    %ebx
  800af6:	5e                   	pop    %esi
  800af7:	5f                   	pop    %edi
  800af8:	5d                   	pop    %ebp
  800af9:	c3                   	ret    
  800afa:	66 90                	xchg   %ax,%ax
  800afc:	0f bd da             	bsr    %edx,%ebx
  800aff:	83 f3 1f             	xor    $0x1f,%ebx
  800b02:	75 3c                	jne    800b40 <__udivdi3+0x8c>
  800b04:	39 f2                	cmp    %esi,%edx
  800b06:	72 08                	jb     800b10 <__udivdi3+0x5c>
  800b08:	39 ef                	cmp    %ebp,%edi
  800b0a:	0f 87 9c 00 00 00    	ja     800bac <__udivdi3+0xf8>
  800b10:	b8 01 00 00 00       	mov    $0x1,%eax
  800b15:	eb d9                	jmp    800af0 <__udivdi3+0x3c>
  800b17:	90                   	nop
  800b18:	89 f9                	mov    %edi,%ecx
  800b1a:	85 ff                	test   %edi,%edi
  800b1c:	75 0b                	jne    800b29 <__udivdi3+0x75>
  800b1e:	b8 01 00 00 00       	mov    $0x1,%eax
  800b23:	31 d2                	xor    %edx,%edx
  800b25:	f7 f7                	div    %edi
  800b27:	89 c1                	mov    %eax,%ecx
  800b29:	31 d2                	xor    %edx,%edx
  800b2b:	89 f0                	mov    %esi,%eax
  800b2d:	f7 f1                	div    %ecx
  800b2f:	89 c3                	mov    %eax,%ebx
  800b31:	89 e8                	mov    %ebp,%eax
  800b33:	f7 f1                	div    %ecx
  800b35:	89 da                	mov    %ebx,%edx
  800b37:	83 c4 1c             	add    $0x1c,%esp
  800b3a:	5b                   	pop    %ebx
  800b3b:	5e                   	pop    %esi
  800b3c:	5f                   	pop    %edi
  800b3d:	5d                   	pop    %ebp
  800b3e:	c3                   	ret    
  800b3f:	90                   	nop
  800b40:	b8 20 00 00 00       	mov    $0x20,%eax
  800b45:	29 d8                	sub    %ebx,%eax
  800b47:	88 d9                	mov    %bl,%cl
  800b49:	d3 e2                	shl    %cl,%edx
  800b4b:	89 54 24 08          	mov    %edx,0x8(%esp)
  800b4f:	89 fa                	mov    %edi,%edx
  800b51:	88 c1                	mov    %al,%cl
  800b53:	d3 ea                	shr    %cl,%edx
  800b55:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800b59:	09 d1                	or     %edx,%ecx
  800b5b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800b5f:	88 d9                	mov    %bl,%cl
  800b61:	d3 e7                	shl    %cl,%edi
  800b63:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800b67:	89 f7                	mov    %esi,%edi
  800b69:	88 c1                	mov    %al,%cl
  800b6b:	d3 ef                	shr    %cl,%edi
  800b6d:	88 d9                	mov    %bl,%cl
  800b6f:	d3 e6                	shl    %cl,%esi
  800b71:	89 ea                	mov    %ebp,%edx
  800b73:	88 c1                	mov    %al,%cl
  800b75:	d3 ea                	shr    %cl,%edx
  800b77:	09 d6                	or     %edx,%esi
  800b79:	89 f0                	mov    %esi,%eax
  800b7b:	89 fa                	mov    %edi,%edx
  800b7d:	f7 74 24 08          	divl   0x8(%esp)
  800b81:	89 d7                	mov    %edx,%edi
  800b83:	89 c6                	mov    %eax,%esi
  800b85:	f7 64 24 0c          	mull   0xc(%esp)
  800b89:	39 d7                	cmp    %edx,%edi
  800b8b:	72 13                	jb     800ba0 <__udivdi3+0xec>
  800b8d:	74 09                	je     800b98 <__udivdi3+0xe4>
  800b8f:	89 f0                	mov    %esi,%eax
  800b91:	31 db                	xor    %ebx,%ebx
  800b93:	e9 58 ff ff ff       	jmp    800af0 <__udivdi3+0x3c>
  800b98:	88 d9                	mov    %bl,%cl
  800b9a:	d3 e5                	shl    %cl,%ebp
  800b9c:	39 c5                	cmp    %eax,%ebp
  800b9e:	73 ef                	jae    800b8f <__udivdi3+0xdb>
  800ba0:	8d 46 ff             	lea    -0x1(%esi),%eax
  800ba3:	31 db                	xor    %ebx,%ebx
  800ba5:	e9 46 ff ff ff       	jmp    800af0 <__udivdi3+0x3c>
  800baa:	66 90                	xchg   %ax,%ax
  800bac:	31 c0                	xor    %eax,%eax
  800bae:	e9 3d ff ff ff       	jmp    800af0 <__udivdi3+0x3c>
  800bb3:	90                   	nop

00800bb4 <__umoddi3>:
  800bb4:	55                   	push   %ebp
  800bb5:	57                   	push   %edi
  800bb6:	56                   	push   %esi
  800bb7:	53                   	push   %ebx
  800bb8:	83 ec 1c             	sub    $0x1c,%esp
  800bbb:	8b 74 24 30          	mov    0x30(%esp),%esi
  800bbf:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800bc3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800bc7:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  800bcb:	85 c0                	test   %eax,%eax
  800bcd:	75 19                	jne    800be8 <__umoddi3+0x34>
  800bcf:	39 df                	cmp    %ebx,%edi
  800bd1:	76 51                	jbe    800c24 <__umoddi3+0x70>
  800bd3:	89 f0                	mov    %esi,%eax
  800bd5:	89 da                	mov    %ebx,%edx
  800bd7:	f7 f7                	div    %edi
  800bd9:	89 d0                	mov    %edx,%eax
  800bdb:	31 d2                	xor    %edx,%edx
  800bdd:	83 c4 1c             	add    $0x1c,%esp
  800be0:	5b                   	pop    %ebx
  800be1:	5e                   	pop    %esi
  800be2:	5f                   	pop    %edi
  800be3:	5d                   	pop    %ebp
  800be4:	c3                   	ret    
  800be5:	8d 76 00             	lea    0x0(%esi),%esi
  800be8:	89 f2                	mov    %esi,%edx
  800bea:	39 d8                	cmp    %ebx,%eax
  800bec:	76 0e                	jbe    800bfc <__umoddi3+0x48>
  800bee:	89 f0                	mov    %esi,%eax
  800bf0:	89 da                	mov    %ebx,%edx
  800bf2:	83 c4 1c             	add    $0x1c,%esp
  800bf5:	5b                   	pop    %ebx
  800bf6:	5e                   	pop    %esi
  800bf7:	5f                   	pop    %edi
  800bf8:	5d                   	pop    %ebp
  800bf9:	c3                   	ret    
  800bfa:	66 90                	xchg   %ax,%ax
  800bfc:	0f bd e8             	bsr    %eax,%ebp
  800bff:	83 f5 1f             	xor    $0x1f,%ebp
  800c02:	75 44                	jne    800c48 <__umoddi3+0x94>
  800c04:	39 d8                	cmp    %ebx,%eax
  800c06:	72 06                	jb     800c0e <__umoddi3+0x5a>
  800c08:	89 d9                	mov    %ebx,%ecx
  800c0a:	39 f7                	cmp    %esi,%edi
  800c0c:	77 08                	ja     800c16 <__umoddi3+0x62>
  800c0e:	29 fe                	sub    %edi,%esi
  800c10:	19 c3                	sbb    %eax,%ebx
  800c12:	89 f2                	mov    %esi,%edx
  800c14:	89 d9                	mov    %ebx,%ecx
  800c16:	89 d0                	mov    %edx,%eax
  800c18:	89 ca                	mov    %ecx,%edx
  800c1a:	83 c4 1c             	add    $0x1c,%esp
  800c1d:	5b                   	pop    %ebx
  800c1e:	5e                   	pop    %esi
  800c1f:	5f                   	pop    %edi
  800c20:	5d                   	pop    %ebp
  800c21:	c3                   	ret    
  800c22:	66 90                	xchg   %ax,%ax
  800c24:	89 fd                	mov    %edi,%ebp
  800c26:	85 ff                	test   %edi,%edi
  800c28:	75 0b                	jne    800c35 <__umoddi3+0x81>
  800c2a:	b8 01 00 00 00       	mov    $0x1,%eax
  800c2f:	31 d2                	xor    %edx,%edx
  800c31:	f7 f7                	div    %edi
  800c33:	89 c5                	mov    %eax,%ebp
  800c35:	89 d8                	mov    %ebx,%eax
  800c37:	31 d2                	xor    %edx,%edx
  800c39:	f7 f5                	div    %ebp
  800c3b:	89 f0                	mov    %esi,%eax
  800c3d:	f7 f5                	div    %ebp
  800c3f:	89 d0                	mov    %edx,%eax
  800c41:	31 d2                	xor    %edx,%edx
  800c43:	eb 98                	jmp    800bdd <__umoddi3+0x29>
  800c45:	8d 76 00             	lea    0x0(%esi),%esi
  800c48:	ba 20 00 00 00       	mov    $0x20,%edx
  800c4d:	29 ea                	sub    %ebp,%edx
  800c4f:	89 e9                	mov    %ebp,%ecx
  800c51:	d3 e0                	shl    %cl,%eax
  800c53:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c57:	89 f8                	mov    %edi,%eax
  800c59:	89 54 24 04          	mov    %edx,0x4(%esp)
  800c5d:	88 d1                	mov    %dl,%cl
  800c5f:	d3 e8                	shr    %cl,%eax
  800c61:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800c65:	09 c1                	or     %eax,%ecx
  800c67:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800c6b:	89 e9                	mov    %ebp,%ecx
  800c6d:	d3 e7                	shl    %cl,%edi
  800c6f:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800c73:	89 d8                	mov    %ebx,%eax
  800c75:	8b 54 24 04          	mov    0x4(%esp),%edx
  800c79:	88 d1                	mov    %dl,%cl
  800c7b:	d3 e8                	shr    %cl,%eax
  800c7d:	89 c7                	mov    %eax,%edi
  800c7f:	89 e9                	mov    %ebp,%ecx
  800c81:	d3 e3                	shl    %cl,%ebx
  800c83:	89 f0                	mov    %esi,%eax
  800c85:	88 d1                	mov    %dl,%cl
  800c87:	d3 e8                	shr    %cl,%eax
  800c89:	09 d8                	or     %ebx,%eax
  800c8b:	89 e9                	mov    %ebp,%ecx
  800c8d:	d3 e6                	shl    %cl,%esi
  800c8f:	89 f3                	mov    %esi,%ebx
  800c91:	89 fa                	mov    %edi,%edx
  800c93:	f7 74 24 08          	divl   0x8(%esp)
  800c97:	89 d1                	mov    %edx,%ecx
  800c99:	f7 64 24 0c          	mull   0xc(%esp)
  800c9d:	89 c6                	mov    %eax,%esi
  800c9f:	89 d7                	mov    %edx,%edi
  800ca1:	39 d1                	cmp    %edx,%ecx
  800ca3:	72 27                	jb     800ccc <__umoddi3+0x118>
  800ca5:	74 21                	je     800cc8 <__umoddi3+0x114>
  800ca7:	89 ca                	mov    %ecx,%edx
  800ca9:	29 f3                	sub    %esi,%ebx
  800cab:	19 fa                	sbb    %edi,%edx
  800cad:	89 d0                	mov    %edx,%eax
  800caf:	8a 4c 24 04          	mov    0x4(%esp),%cl
  800cb3:	d3 e0                	shl    %cl,%eax
  800cb5:	89 e9                	mov    %ebp,%ecx
  800cb7:	d3 eb                	shr    %cl,%ebx
  800cb9:	09 d8                	or     %ebx,%eax
  800cbb:	d3 ea                	shr    %cl,%edx
  800cbd:	83 c4 1c             	add    $0x1c,%esp
  800cc0:	5b                   	pop    %ebx
  800cc1:	5e                   	pop    %esi
  800cc2:	5f                   	pop    %edi
  800cc3:	5d                   	pop    %ebp
  800cc4:	c3                   	ret    
  800cc5:	8d 76 00             	lea    0x0(%esi),%esi
  800cc8:	39 c3                	cmp    %eax,%ebx
  800cca:	73 db                	jae    800ca7 <__umoddi3+0xf3>
  800ccc:	2b 44 24 0c          	sub    0xc(%esp),%eax
  800cd0:	1b 54 24 08          	sbb    0x8(%esp),%edx
  800cd4:	89 d7                	mov    %edx,%edi
  800cd6:	89 c6                	mov    %eax,%esi
  800cd8:	eb cd                	jmp    800ca7 <__umoddi3+0xf3>
