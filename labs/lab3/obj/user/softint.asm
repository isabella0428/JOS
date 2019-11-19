
obj/user/softint:     file format elf32-i386


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
  80002c:	e8 05 00 00 00       	call   800036 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
	asm volatile("int $14");	// page fault
  800033:	cd 0e                	int    $0xe
}
  800035:	c3                   	ret    

00800036 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800036:	55                   	push   %ebp
  800037:	89 e5                	mov    %esp,%ebp
  800039:	57                   	push   %edi
  80003a:	56                   	push   %esi
  80003b:	53                   	push   %ebx
  80003c:	83 ec 6c             	sub    $0x6c,%esp
  80003f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	struct Env curenv = envs[ENVX(sys_getenvid())];
  800042:	e8 de 00 00 00       	call   800125 <sys_getenvid>
  800047:	25 ff 03 00 00       	and    $0x3ff,%eax
  80004c:	8d 34 00             	lea    (%eax,%eax,1),%esi
  80004f:	01 c6                	add    %eax,%esi
  800051:	c1 e6 05             	shl    $0x5,%esi
  800054:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  80005a:	8d 7d 88             	lea    -0x78(%ebp),%edi
  80005d:	b9 18 00 00 00       	mov    $0x18,%ecx
  800062:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	thisenv = &curenv;
  800064:	8d 45 88             	lea    -0x78(%ebp),%eax
  800067:	a3 04 10 80 00       	mov    %eax,0x801004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80006c:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800070:	7e 07                	jle    800079 <libmain+0x43>
		binaryname = argv[0];
  800072:	8b 03                	mov    (%ebx),%eax
  800074:	a3 00 10 80 00       	mov    %eax,0x801000
	
	// call user main routine
	umain(argc, argv);
  800079:	83 ec 08             	sub    $0x8,%esp
  80007c:	53                   	push   %ebx
  80007d:	ff 75 08             	pushl  0x8(%ebp)
  800080:	e8 ae ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800085:	e8 0b 00 00 00       	call   800095 <exit>
}
  80008a:	83 c4 10             	add    $0x10,%esp
  80008d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800090:	5b                   	pop    %ebx
  800091:	5e                   	pop    %esi
  800092:	5f                   	pop    %edi
  800093:	5d                   	pop    %ebp
  800094:	c3                   	ret    

00800095 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800095:	55                   	push   %ebp
  800096:	89 e5                	mov    %esp,%ebp
  800098:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  80009b:	6a 00                	push   $0x0
  80009d:	e8 42 00 00 00       	call   8000e4 <sys_env_destroy>
}
  8000a2:	83 c4 10             	add    $0x10,%esp
  8000a5:	c9                   	leave  
  8000a6:	c3                   	ret    

008000a7 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000a7:	55                   	push   %ebp
  8000a8:	89 e5                	mov    %esp,%ebp
  8000aa:	57                   	push   %edi
  8000ab:	56                   	push   %esi
  8000ac:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000ad:	b8 00 00 00 00       	mov    $0x0,%eax
  8000b2:	8b 55 08             	mov    0x8(%ebp),%edx
  8000b5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000b8:	89 c3                	mov    %eax,%ebx
  8000ba:	89 c7                	mov    %eax,%edi
  8000bc:	89 c6                	mov    %eax,%esi
  8000be:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000c0:	5b                   	pop    %ebx
  8000c1:	5e                   	pop    %esi
  8000c2:	5f                   	pop    %edi
  8000c3:	5d                   	pop    %ebp
  8000c4:	c3                   	ret    

008000c5 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000c5:	55                   	push   %ebp
  8000c6:	89 e5                	mov    %esp,%ebp
  8000c8:	57                   	push   %edi
  8000c9:	56                   	push   %esi
  8000ca:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000cb:	ba 00 00 00 00       	mov    $0x0,%edx
  8000d0:	b8 01 00 00 00       	mov    $0x1,%eax
  8000d5:	89 d1                	mov    %edx,%ecx
  8000d7:	89 d3                	mov    %edx,%ebx
  8000d9:	89 d7                	mov    %edx,%edi
  8000db:	89 d6                	mov    %edx,%esi
  8000dd:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000df:	5b                   	pop    %ebx
  8000e0:	5e                   	pop    %esi
  8000e1:	5f                   	pop    %edi
  8000e2:	5d                   	pop    %ebp
  8000e3:	c3                   	ret    

008000e4 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000e4:	55                   	push   %ebp
  8000e5:	89 e5                	mov    %esp,%ebp
  8000e7:	57                   	push   %edi
  8000e8:	56                   	push   %esi
  8000e9:	53                   	push   %ebx
  8000ea:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8000ed:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000f2:	8b 55 08             	mov    0x8(%ebp),%edx
  8000f5:	b8 03 00 00 00       	mov    $0x3,%eax
  8000fa:	89 cb                	mov    %ecx,%ebx
  8000fc:	89 cf                	mov    %ecx,%edi
  8000fe:	89 ce                	mov    %ecx,%esi
  800100:	cd 30                	int    $0x30
	if(check && ret > 0)
  800102:	85 c0                	test   %eax,%eax
  800104:	7f 08                	jg     80010e <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800106:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800109:	5b                   	pop    %ebx
  80010a:	5e                   	pop    %esi
  80010b:	5f                   	pop    %edi
  80010c:	5d                   	pop    %ebp
  80010d:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80010e:	83 ec 0c             	sub    $0xc,%esp
  800111:	50                   	push   %eax
  800112:	6a 03                	push   $0x3
  800114:	68 0a 0d 80 00       	push   $0x800d0a
  800119:	6a 23                	push   $0x23
  80011b:	68 27 0d 80 00       	push   $0x800d27
  800120:	e8 1f 00 00 00       	call   800144 <_panic>

00800125 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800125:	55                   	push   %ebp
  800126:	89 e5                	mov    %esp,%ebp
  800128:	57                   	push   %edi
  800129:	56                   	push   %esi
  80012a:	53                   	push   %ebx
	asm volatile("int %1\n"
  80012b:	ba 00 00 00 00       	mov    $0x0,%edx
  800130:	b8 02 00 00 00       	mov    $0x2,%eax
  800135:	89 d1                	mov    %edx,%ecx
  800137:	89 d3                	mov    %edx,%ebx
  800139:	89 d7                	mov    %edx,%edi
  80013b:	89 d6                	mov    %edx,%esi
  80013d:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80013f:	5b                   	pop    %ebx
  800140:	5e                   	pop    %esi
  800141:	5f                   	pop    %edi
  800142:	5d                   	pop    %ebp
  800143:	c3                   	ret    

00800144 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800144:	55                   	push   %ebp
  800145:	89 e5                	mov    %esp,%ebp
  800147:	56                   	push   %esi
  800148:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800149:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80014c:	8b 35 00 10 80 00    	mov    0x801000,%esi
  800152:	e8 ce ff ff ff       	call   800125 <sys_getenvid>
  800157:	83 ec 0c             	sub    $0xc,%esp
  80015a:	ff 75 0c             	pushl  0xc(%ebp)
  80015d:	ff 75 08             	pushl  0x8(%ebp)
  800160:	56                   	push   %esi
  800161:	50                   	push   %eax
  800162:	68 38 0d 80 00       	push   $0x800d38
  800167:	e8 b2 00 00 00       	call   80021e <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80016c:	83 c4 18             	add    $0x18,%esp
  80016f:	53                   	push   %ebx
  800170:	ff 75 10             	pushl  0x10(%ebp)
  800173:	e8 55 00 00 00       	call   8001cd <vcprintf>
	cprintf("\n");
  800178:	c7 04 24 5c 0d 80 00 	movl   $0x800d5c,(%esp)
  80017f:	e8 9a 00 00 00       	call   80021e <cprintf>
  800184:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800187:	cc                   	int3   
  800188:	eb fd                	jmp    800187 <_panic+0x43>

0080018a <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80018a:	55                   	push   %ebp
  80018b:	89 e5                	mov    %esp,%ebp
  80018d:	53                   	push   %ebx
  80018e:	83 ec 04             	sub    $0x4,%esp
  800191:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800194:	8b 13                	mov    (%ebx),%edx
  800196:	8d 42 01             	lea    0x1(%edx),%eax
  800199:	89 03                	mov    %eax,(%ebx)
  80019b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80019e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001a2:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001a7:	74 08                	je     8001b1 <putch+0x27>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8001a9:	ff 43 04             	incl   0x4(%ebx)
}
  8001ac:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001af:	c9                   	leave  
  8001b0:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8001b1:	83 ec 08             	sub    $0x8,%esp
  8001b4:	68 ff 00 00 00       	push   $0xff
  8001b9:	8d 43 08             	lea    0x8(%ebx),%eax
  8001bc:	50                   	push   %eax
  8001bd:	e8 e5 fe ff ff       	call   8000a7 <sys_cputs>
		b->idx = 0;
  8001c2:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001c8:	83 c4 10             	add    $0x10,%esp
  8001cb:	eb dc                	jmp    8001a9 <putch+0x1f>

008001cd <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001cd:	55                   	push   %ebp
  8001ce:	89 e5                	mov    %esp,%ebp
  8001d0:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001d6:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001dd:	00 00 00 
	b.cnt = 0;
  8001e0:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001e7:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001ea:	ff 75 0c             	pushl  0xc(%ebp)
  8001ed:	ff 75 08             	pushl  0x8(%ebp)
  8001f0:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001f6:	50                   	push   %eax
  8001f7:	68 8a 01 80 00       	push   $0x80018a
  8001fc:	e8 0f 01 00 00       	call   800310 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800201:	83 c4 08             	add    $0x8,%esp
  800204:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80020a:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800210:	50                   	push   %eax
  800211:	e8 91 fe ff ff       	call   8000a7 <sys_cputs>

	return b.cnt;
}
  800216:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80021c:	c9                   	leave  
  80021d:	c3                   	ret    

0080021e <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80021e:	55                   	push   %ebp
  80021f:	89 e5                	mov    %esp,%ebp
  800221:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800224:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800227:	50                   	push   %eax
  800228:	ff 75 08             	pushl  0x8(%ebp)
  80022b:	e8 9d ff ff ff       	call   8001cd <vcprintf>
	va_end(ap);

	return cnt;
}
  800230:	c9                   	leave  
  800231:	c3                   	ret    

00800232 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800232:	55                   	push   %ebp
  800233:	89 e5                	mov    %esp,%ebp
  800235:	57                   	push   %edi
  800236:	56                   	push   %esi
  800237:	53                   	push   %ebx
  800238:	83 ec 1c             	sub    $0x1c,%esp
  80023b:	89 c7                	mov    %eax,%edi
  80023d:	89 d6                	mov    %edx,%esi
  80023f:	8b 45 08             	mov    0x8(%ebp),%eax
  800242:	8b 55 0c             	mov    0xc(%ebp),%edx
  800245:	89 d1                	mov    %edx,%ecx
  800247:	89 c2                	mov    %eax,%edx
  800249:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80024c:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80024f:	8b 45 10             	mov    0x10(%ebp),%eax
  800252:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800255:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800258:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80025f:	39 c2                	cmp    %eax,%edx
  800261:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  800264:	72 3c                	jb     8002a2 <printnum+0x70>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800266:	83 ec 0c             	sub    $0xc,%esp
  800269:	ff 75 18             	pushl  0x18(%ebp)
  80026c:	4b                   	dec    %ebx
  80026d:	53                   	push   %ebx
  80026e:	50                   	push   %eax
  80026f:	83 ec 08             	sub    $0x8,%esp
  800272:	ff 75 e4             	pushl  -0x1c(%ebp)
  800275:	ff 75 e0             	pushl  -0x20(%ebp)
  800278:	ff 75 dc             	pushl  -0x24(%ebp)
  80027b:	ff 75 d8             	pushl  -0x28(%ebp)
  80027e:	e8 55 08 00 00       	call   800ad8 <__udivdi3>
  800283:	83 c4 18             	add    $0x18,%esp
  800286:	52                   	push   %edx
  800287:	50                   	push   %eax
  800288:	89 f2                	mov    %esi,%edx
  80028a:	89 f8                	mov    %edi,%eax
  80028c:	e8 a1 ff ff ff       	call   800232 <printnum>
  800291:	83 c4 20             	add    $0x20,%esp
  800294:	eb 11                	jmp    8002a7 <printnum+0x75>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800296:	83 ec 08             	sub    $0x8,%esp
  800299:	56                   	push   %esi
  80029a:	ff 75 18             	pushl  0x18(%ebp)
  80029d:	ff d7                	call   *%edi
  80029f:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8002a2:	4b                   	dec    %ebx
  8002a3:	85 db                	test   %ebx,%ebx
  8002a5:	7f ef                	jg     800296 <printnum+0x64>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002a7:	83 ec 08             	sub    $0x8,%esp
  8002aa:	56                   	push   %esi
  8002ab:	83 ec 04             	sub    $0x4,%esp
  8002ae:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002b1:	ff 75 e0             	pushl  -0x20(%ebp)
  8002b4:	ff 75 dc             	pushl  -0x24(%ebp)
  8002b7:	ff 75 d8             	pushl  -0x28(%ebp)
  8002ba:	e8 19 09 00 00       	call   800bd8 <__umoddi3>
  8002bf:	83 c4 14             	add    $0x14,%esp
  8002c2:	0f be 80 5e 0d 80 00 	movsbl 0x800d5e(%eax),%eax
  8002c9:	50                   	push   %eax
  8002ca:	ff d7                	call   *%edi
}
  8002cc:	83 c4 10             	add    $0x10,%esp
  8002cf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002d2:	5b                   	pop    %ebx
  8002d3:	5e                   	pop    %esi
  8002d4:	5f                   	pop    %edi
  8002d5:	5d                   	pop    %ebp
  8002d6:	c3                   	ret    

008002d7 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002d7:	55                   	push   %ebp
  8002d8:	89 e5                	mov    %esp,%ebp
  8002da:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002dd:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8002e0:	8b 10                	mov    (%eax),%edx
  8002e2:	3b 50 04             	cmp    0x4(%eax),%edx
  8002e5:	73 0a                	jae    8002f1 <sprintputch+0x1a>
		*b->buf++ = ch;
  8002e7:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002ea:	89 08                	mov    %ecx,(%eax)
  8002ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8002ef:	88 02                	mov    %al,(%edx)
}
  8002f1:	5d                   	pop    %ebp
  8002f2:	c3                   	ret    

008002f3 <printfmt>:
{
  8002f3:	55                   	push   %ebp
  8002f4:	89 e5                	mov    %esp,%ebp
  8002f6:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8002f9:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002fc:	50                   	push   %eax
  8002fd:	ff 75 10             	pushl  0x10(%ebp)
  800300:	ff 75 0c             	pushl  0xc(%ebp)
  800303:	ff 75 08             	pushl  0x8(%ebp)
  800306:	e8 05 00 00 00       	call   800310 <vprintfmt>
}
  80030b:	83 c4 10             	add    $0x10,%esp
  80030e:	c9                   	leave  
  80030f:	c3                   	ret    

00800310 <vprintfmt>:
{
  800310:	55                   	push   %ebp
  800311:	89 e5                	mov    %esp,%ebp
  800313:	57                   	push   %edi
  800314:	56                   	push   %esi
  800315:	53                   	push   %ebx
  800316:	83 ec 3c             	sub    $0x3c,%esp
  800319:	8b 75 08             	mov    0x8(%ebp),%esi
  80031c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80031f:	8b 7d 10             	mov    0x10(%ebp),%edi
  800322:	e9 5b 03 00 00       	jmp    800682 <vprintfmt+0x372>
		padc = ' ';
  800327:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  80032b:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
		precision = -1;
  800332:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  800339:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		lflag = 0;
  800340:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800345:	8d 47 01             	lea    0x1(%edi),%eax
  800348:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80034b:	8a 17                	mov    (%edi),%dl
  80034d:	8d 42 dd             	lea    -0x23(%edx),%eax
  800350:	3c 55                	cmp    $0x55,%al
  800352:	0f 87 ab 03 00 00    	ja     800703 <vprintfmt+0x3f3>
  800358:	0f b6 c0             	movzbl %al,%eax
  80035b:	ff 24 85 ec 0d 80 00 	jmp    *0x800dec(,%eax,4)
  800362:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800365:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  800369:	eb da                	jmp    800345 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  80036b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80036e:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  800372:	eb d1                	jmp    800345 <vprintfmt+0x35>
  800374:	0f b6 d2             	movzbl %dl,%edx
  800377:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  80037a:	b8 00 00 00 00       	mov    $0x0,%eax
  80037f:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800382:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800385:	01 c0                	add    %eax,%eax
  800387:	8d 44 02 d0          	lea    -0x30(%edx,%eax,1),%eax
				ch = *fmt;
  80038b:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  80038e:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800391:	83 f9 09             	cmp    $0x9,%ecx
  800394:	77 52                	ja     8003e8 <vprintfmt+0xd8>
			for (precision = 0; ; ++fmt) {
  800396:	47                   	inc    %edi
				precision = precision * 10 + ch - '0';
  800397:	eb e9                	jmp    800382 <vprintfmt+0x72>
			precision = va_arg(ap, int);
  800399:	8b 45 14             	mov    0x14(%ebp),%eax
  80039c:	8b 00                	mov    (%eax),%eax
  80039e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003a1:	8b 45 14             	mov    0x14(%ebp),%eax
  8003a4:	8d 40 04             	lea    0x4(%eax),%eax
  8003a7:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003aa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8003ad:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8003b1:	79 92                	jns    800345 <vprintfmt+0x35>
				width = precision, precision = -1;
  8003b3:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8003b6:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8003b9:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8003c0:	eb 83                	jmp    800345 <vprintfmt+0x35>
  8003c2:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8003c6:	78 08                	js     8003d0 <vprintfmt+0xc0>
		switch (ch = *(unsigned char *) fmt++) {
  8003c8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8003cb:	e9 75 ff ff ff       	jmp    800345 <vprintfmt+0x35>
  8003d0:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  8003d7:	eb ef                	jmp    8003c8 <vprintfmt+0xb8>
		switch (ch = *(unsigned char *) fmt++) {
  8003d9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8003dc:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  8003e3:	e9 5d ff ff ff       	jmp    800345 <vprintfmt+0x35>
  8003e8:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8003eb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003ee:	eb bd                	jmp    8003ad <vprintfmt+0x9d>
			lflag++;
  8003f0:	41                   	inc    %ecx
		switch (ch = *(unsigned char *) fmt++) {
  8003f1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8003f4:	e9 4c ff ff ff       	jmp    800345 <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
  8003f9:	8b 45 14             	mov    0x14(%ebp),%eax
  8003fc:	8d 78 04             	lea    0x4(%eax),%edi
  8003ff:	83 ec 08             	sub    $0x8,%esp
  800402:	53                   	push   %ebx
  800403:	ff 30                	pushl  (%eax)
  800405:	ff d6                	call   *%esi
			break;
  800407:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  80040a:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  80040d:	e9 6d 02 00 00       	jmp    80067f <vprintfmt+0x36f>
			err = va_arg(ap, int);
  800412:	8b 45 14             	mov    0x14(%ebp),%eax
  800415:	8d 78 04             	lea    0x4(%eax),%edi
  800418:	8b 00                	mov    (%eax),%eax
  80041a:	85 c0                	test   %eax,%eax
  80041c:	78 2a                	js     800448 <vprintfmt+0x138>
  80041e:	89 c2                	mov    %eax,%edx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800420:	83 f8 06             	cmp    $0x6,%eax
  800423:	7f 27                	jg     80044c <vprintfmt+0x13c>
  800425:	8b 04 85 44 0f 80 00 	mov    0x800f44(,%eax,4),%eax
  80042c:	85 c0                	test   %eax,%eax
  80042e:	74 1c                	je     80044c <vprintfmt+0x13c>
				printfmt(putch, putdat, "%s", p);
  800430:	50                   	push   %eax
  800431:	68 7f 0d 80 00       	push   $0x800d7f
  800436:	53                   	push   %ebx
  800437:	56                   	push   %esi
  800438:	e8 b6 fe ff ff       	call   8002f3 <printfmt>
  80043d:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800440:	89 7d 14             	mov    %edi,0x14(%ebp)
  800443:	e9 37 02 00 00       	jmp    80067f <vprintfmt+0x36f>
  800448:	f7 d8                	neg    %eax
  80044a:	eb d2                	jmp    80041e <vprintfmt+0x10e>
				printfmt(putch, putdat, "error %d", err);
  80044c:	52                   	push   %edx
  80044d:	68 76 0d 80 00       	push   $0x800d76
  800452:	53                   	push   %ebx
  800453:	56                   	push   %esi
  800454:	e8 9a fe ff ff       	call   8002f3 <printfmt>
  800459:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80045c:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  80045f:	e9 1b 02 00 00       	jmp    80067f <vprintfmt+0x36f>
			if ((p = va_arg(ap, char *)) == NULL)
  800464:	8b 45 14             	mov    0x14(%ebp),%eax
  800467:	83 c0 04             	add    $0x4,%eax
  80046a:	89 45 c8             	mov    %eax,-0x38(%ebp)
  80046d:	8b 45 14             	mov    0x14(%ebp),%eax
  800470:	8b 00                	mov    (%eax),%eax
  800472:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800475:	85 c0                	test   %eax,%eax
  800477:	74 19                	je     800492 <vprintfmt+0x182>
			if (width > 0 && padc != '-')
  800479:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80047d:	7e 06                	jle    800485 <vprintfmt+0x175>
  80047f:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  800483:	75 16                	jne    80049b <vprintfmt+0x18b>
				for (width -= strnlen(p, precision); width > 0; width--)
  800485:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800488:	89 c7                	mov    %eax,%edi
  80048a:	03 45 d4             	add    -0x2c(%ebp),%eax
  80048d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800490:	eb 62                	jmp    8004f4 <vprintfmt+0x1e4>
				p = "(null)";
  800492:	c7 45 cc 6f 0d 80 00 	movl   $0x800d6f,-0x34(%ebp)
  800499:	eb de                	jmp    800479 <vprintfmt+0x169>
				for (width -= strnlen(p, precision); width > 0; width--)
  80049b:	83 ec 08             	sub    $0x8,%esp
  80049e:	ff 75 d8             	pushl  -0x28(%ebp)
  8004a1:	ff 75 cc             	pushl  -0x34(%ebp)
  8004a4:	e8 05 03 00 00       	call   8007ae <strnlen>
  8004a9:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8004ac:	29 c2                	sub    %eax,%edx
  8004ae:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  8004b1:	83 c4 10             	add    $0x10,%esp
  8004b4:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  8004b6:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8004ba:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8004bd:	eb 0d                	jmp    8004cc <vprintfmt+0x1bc>
					putch(padc, putdat);
  8004bf:	83 ec 08             	sub    $0x8,%esp
  8004c2:	53                   	push   %ebx
  8004c3:	ff 75 d4             	pushl  -0x2c(%ebp)
  8004c6:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8004c8:	4f                   	dec    %edi
  8004c9:	83 c4 10             	add    $0x10,%esp
  8004cc:	85 ff                	test   %edi,%edi
  8004ce:	7f ef                	jg     8004bf <vprintfmt+0x1af>
  8004d0:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8004d3:	89 d0                	mov    %edx,%eax
  8004d5:	85 d2                	test   %edx,%edx
  8004d7:	78 0a                	js     8004e3 <vprintfmt+0x1d3>
  8004d9:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8004dc:	29 c2                	sub    %eax,%edx
  8004de:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8004e1:	eb a2                	jmp    800485 <vprintfmt+0x175>
  8004e3:	b8 00 00 00 00       	mov    $0x0,%eax
  8004e8:	eb ef                	jmp    8004d9 <vprintfmt+0x1c9>
					putch(ch, putdat);
  8004ea:	83 ec 08             	sub    $0x8,%esp
  8004ed:	53                   	push   %ebx
  8004ee:	52                   	push   %edx
  8004ef:	ff d6                	call   *%esi
  8004f1:	83 c4 10             	add    $0x10,%esp
  8004f4:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  8004f7:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004f9:	47                   	inc    %edi
  8004fa:	8a 47 ff             	mov    -0x1(%edi),%al
  8004fd:	0f be d0             	movsbl %al,%edx
  800500:	85 d2                	test   %edx,%edx
  800502:	74 48                	je     80054c <vprintfmt+0x23c>
  800504:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800508:	78 05                	js     80050f <vprintfmt+0x1ff>
  80050a:	ff 4d d8             	decl   -0x28(%ebp)
  80050d:	78 1e                	js     80052d <vprintfmt+0x21d>
				if (altflag && (ch < ' ' || ch > '~'))
  80050f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800513:	74 d5                	je     8004ea <vprintfmt+0x1da>
  800515:	0f be c0             	movsbl %al,%eax
  800518:	83 e8 20             	sub    $0x20,%eax
  80051b:	83 f8 5e             	cmp    $0x5e,%eax
  80051e:	76 ca                	jbe    8004ea <vprintfmt+0x1da>
					putch('?', putdat);
  800520:	83 ec 08             	sub    $0x8,%esp
  800523:	53                   	push   %ebx
  800524:	6a 3f                	push   $0x3f
  800526:	ff d6                	call   *%esi
  800528:	83 c4 10             	add    $0x10,%esp
  80052b:	eb c7                	jmp    8004f4 <vprintfmt+0x1e4>
  80052d:	89 cf                	mov    %ecx,%edi
  80052f:	eb 0c                	jmp    80053d <vprintfmt+0x22d>
				putch(' ', putdat);
  800531:	83 ec 08             	sub    $0x8,%esp
  800534:	53                   	push   %ebx
  800535:	6a 20                	push   $0x20
  800537:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800539:	4f                   	dec    %edi
  80053a:	83 c4 10             	add    $0x10,%esp
  80053d:	85 ff                	test   %edi,%edi
  80053f:	7f f0                	jg     800531 <vprintfmt+0x221>
			if ((p = va_arg(ap, char *)) == NULL)
  800541:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800544:	89 45 14             	mov    %eax,0x14(%ebp)
  800547:	e9 33 01 00 00       	jmp    80067f <vprintfmt+0x36f>
  80054c:	89 cf                	mov    %ecx,%edi
  80054e:	eb ed                	jmp    80053d <vprintfmt+0x22d>
	if (lflag >= 2)
  800550:	83 f9 01             	cmp    $0x1,%ecx
  800553:	7f 1b                	jg     800570 <vprintfmt+0x260>
	else if (lflag)
  800555:	85 c9                	test   %ecx,%ecx
  800557:	74 42                	je     80059b <vprintfmt+0x28b>
		return va_arg(*ap, long);
  800559:	8b 45 14             	mov    0x14(%ebp),%eax
  80055c:	8b 00                	mov    (%eax),%eax
  80055e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800561:	99                   	cltd   
  800562:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800565:	8b 45 14             	mov    0x14(%ebp),%eax
  800568:	8d 40 04             	lea    0x4(%eax),%eax
  80056b:	89 45 14             	mov    %eax,0x14(%ebp)
  80056e:	eb 17                	jmp    800587 <vprintfmt+0x277>
		return va_arg(*ap, long long);
  800570:	8b 45 14             	mov    0x14(%ebp),%eax
  800573:	8b 50 04             	mov    0x4(%eax),%edx
  800576:	8b 00                	mov    (%eax),%eax
  800578:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80057b:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80057e:	8b 45 14             	mov    0x14(%ebp),%eax
  800581:	8d 40 08             	lea    0x8(%eax),%eax
  800584:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800587:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80058a:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80058d:	85 c9                	test   %ecx,%ecx
  80058f:	78 21                	js     8005b2 <vprintfmt+0x2a2>
			base = 10;
  800591:	b8 0a 00 00 00       	mov    $0xa,%eax
  800596:	e9 ca 00 00 00       	jmp    800665 <vprintfmt+0x355>
		return va_arg(*ap, int);
  80059b:	8b 45 14             	mov    0x14(%ebp),%eax
  80059e:	8b 00                	mov    (%eax),%eax
  8005a0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005a3:	99                   	cltd   
  8005a4:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005a7:	8b 45 14             	mov    0x14(%ebp),%eax
  8005aa:	8d 40 04             	lea    0x4(%eax),%eax
  8005ad:	89 45 14             	mov    %eax,0x14(%ebp)
  8005b0:	eb d5                	jmp    800587 <vprintfmt+0x277>
				putch('-', putdat);
  8005b2:	83 ec 08             	sub    $0x8,%esp
  8005b5:	53                   	push   %ebx
  8005b6:	6a 2d                	push   $0x2d
  8005b8:	ff d6                	call   *%esi
				num = -(long long) num;
  8005ba:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005bd:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8005c0:	f7 da                	neg    %edx
  8005c2:	83 d1 00             	adc    $0x0,%ecx
  8005c5:	f7 d9                	neg    %ecx
  8005c7:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8005ca:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005cf:	e9 91 00 00 00       	jmp    800665 <vprintfmt+0x355>
	if (lflag >= 2)
  8005d4:	83 f9 01             	cmp    $0x1,%ecx
  8005d7:	7f 1b                	jg     8005f4 <vprintfmt+0x2e4>
	else if (lflag)
  8005d9:	85 c9                	test   %ecx,%ecx
  8005db:	74 2c                	je     800609 <vprintfmt+0x2f9>
		return va_arg(*ap, unsigned long);
  8005dd:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e0:	8b 10                	mov    (%eax),%edx
  8005e2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005e7:	8d 40 04             	lea    0x4(%eax),%eax
  8005ea:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005ed:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  8005f2:	eb 71                	jmp    800665 <vprintfmt+0x355>
		return va_arg(*ap, unsigned long long);
  8005f4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f7:	8b 10                	mov    (%eax),%edx
  8005f9:	8b 48 04             	mov    0x4(%eax),%ecx
  8005fc:	8d 40 08             	lea    0x8(%eax),%eax
  8005ff:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800602:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  800607:	eb 5c                	jmp    800665 <vprintfmt+0x355>
		return va_arg(*ap, unsigned int);
  800609:	8b 45 14             	mov    0x14(%ebp),%eax
  80060c:	8b 10                	mov    (%eax),%edx
  80060e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800613:	8d 40 04             	lea    0x4(%eax),%eax
  800616:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800619:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  80061e:	eb 45                	jmp    800665 <vprintfmt+0x355>
			putch('X', putdat);
  800620:	83 ec 08             	sub    $0x8,%esp
  800623:	53                   	push   %ebx
  800624:	6a 58                	push   $0x58
  800626:	ff d6                	call   *%esi
			putch('X', putdat);
  800628:	83 c4 08             	add    $0x8,%esp
  80062b:	53                   	push   %ebx
  80062c:	6a 58                	push   $0x58
  80062e:	ff d6                	call   *%esi
			putch('X', putdat);
  800630:	83 c4 08             	add    $0x8,%esp
  800633:	53                   	push   %ebx
  800634:	6a 58                	push   $0x58
  800636:	ff d6                	call   *%esi
			break;
  800638:	83 c4 10             	add    $0x10,%esp
  80063b:	eb 42                	jmp    80067f <vprintfmt+0x36f>
			putch('0', putdat);
  80063d:	83 ec 08             	sub    $0x8,%esp
  800640:	53                   	push   %ebx
  800641:	6a 30                	push   $0x30
  800643:	ff d6                	call   *%esi
			putch('x', putdat);
  800645:	83 c4 08             	add    $0x8,%esp
  800648:	53                   	push   %ebx
  800649:	6a 78                	push   $0x78
  80064b:	ff d6                	call   *%esi
			num = (unsigned long long)
  80064d:	8b 45 14             	mov    0x14(%ebp),%eax
  800650:	8b 10                	mov    (%eax),%edx
  800652:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800657:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  80065a:	8d 40 04             	lea    0x4(%eax),%eax
  80065d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800660:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  800665:	83 ec 0c             	sub    $0xc,%esp
  800668:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  80066c:	57                   	push   %edi
  80066d:	ff 75 d4             	pushl  -0x2c(%ebp)
  800670:	50                   	push   %eax
  800671:	51                   	push   %ecx
  800672:	52                   	push   %edx
  800673:	89 da                	mov    %ebx,%edx
  800675:	89 f0                	mov    %esi,%eax
  800677:	e8 b6 fb ff ff       	call   800232 <printnum>
			break;
  80067c:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  80067f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800682:	47                   	inc    %edi
  800683:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800687:	83 f8 25             	cmp    $0x25,%eax
  80068a:	0f 84 97 fc ff ff    	je     800327 <vprintfmt+0x17>
			if (ch == '\0')
  800690:	85 c0                	test   %eax,%eax
  800692:	0f 84 89 00 00 00    	je     800721 <vprintfmt+0x411>
			putch(ch, putdat);
  800698:	83 ec 08             	sub    $0x8,%esp
  80069b:	53                   	push   %ebx
  80069c:	50                   	push   %eax
  80069d:	ff d6                	call   *%esi
  80069f:	83 c4 10             	add    $0x10,%esp
  8006a2:	eb de                	jmp    800682 <vprintfmt+0x372>
	if (lflag >= 2)
  8006a4:	83 f9 01             	cmp    $0x1,%ecx
  8006a7:	7f 1b                	jg     8006c4 <vprintfmt+0x3b4>
	else if (lflag)
  8006a9:	85 c9                	test   %ecx,%ecx
  8006ab:	74 2c                	je     8006d9 <vprintfmt+0x3c9>
		return va_arg(*ap, unsigned long);
  8006ad:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b0:	8b 10                	mov    (%eax),%edx
  8006b2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006b7:	8d 40 04             	lea    0x4(%eax),%eax
  8006ba:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006bd:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  8006c2:	eb a1                	jmp    800665 <vprintfmt+0x355>
		return va_arg(*ap, unsigned long long);
  8006c4:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c7:	8b 10                	mov    (%eax),%edx
  8006c9:	8b 48 04             	mov    0x4(%eax),%ecx
  8006cc:	8d 40 08             	lea    0x8(%eax),%eax
  8006cf:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006d2:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  8006d7:	eb 8c                	jmp    800665 <vprintfmt+0x355>
		return va_arg(*ap, unsigned int);
  8006d9:	8b 45 14             	mov    0x14(%ebp),%eax
  8006dc:	8b 10                	mov    (%eax),%edx
  8006de:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006e3:	8d 40 04             	lea    0x4(%eax),%eax
  8006e6:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006e9:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  8006ee:	e9 72 ff ff ff       	jmp    800665 <vprintfmt+0x355>
			putch(ch, putdat);
  8006f3:	83 ec 08             	sub    $0x8,%esp
  8006f6:	53                   	push   %ebx
  8006f7:	6a 25                	push   $0x25
  8006f9:	ff d6                	call   *%esi
			break;
  8006fb:	83 c4 10             	add    $0x10,%esp
  8006fe:	e9 7c ff ff ff       	jmp    80067f <vprintfmt+0x36f>
			putch('%', putdat);
  800703:	83 ec 08             	sub    $0x8,%esp
  800706:	53                   	push   %ebx
  800707:	6a 25                	push   $0x25
  800709:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80070b:	83 c4 10             	add    $0x10,%esp
  80070e:	89 f8                	mov    %edi,%eax
  800710:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800714:	74 03                	je     800719 <vprintfmt+0x409>
  800716:	48                   	dec    %eax
  800717:	eb f7                	jmp    800710 <vprintfmt+0x400>
  800719:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80071c:	e9 5e ff ff ff       	jmp    80067f <vprintfmt+0x36f>
}
  800721:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800724:	5b                   	pop    %ebx
  800725:	5e                   	pop    %esi
  800726:	5f                   	pop    %edi
  800727:	5d                   	pop    %ebp
  800728:	c3                   	ret    

00800729 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800729:	55                   	push   %ebp
  80072a:	89 e5                	mov    %esp,%ebp
  80072c:	83 ec 18             	sub    $0x18,%esp
  80072f:	8b 45 08             	mov    0x8(%ebp),%eax
  800732:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800735:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800738:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80073c:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80073f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800746:	85 c0                	test   %eax,%eax
  800748:	74 26                	je     800770 <vsnprintf+0x47>
  80074a:	85 d2                	test   %edx,%edx
  80074c:	7e 29                	jle    800777 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80074e:	ff 75 14             	pushl  0x14(%ebp)
  800751:	ff 75 10             	pushl  0x10(%ebp)
  800754:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800757:	50                   	push   %eax
  800758:	68 d7 02 80 00       	push   $0x8002d7
  80075d:	e8 ae fb ff ff       	call   800310 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800762:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800765:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800768:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80076b:	83 c4 10             	add    $0x10,%esp
}
  80076e:	c9                   	leave  
  80076f:	c3                   	ret    
		return -E_INVAL;
  800770:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800775:	eb f7                	jmp    80076e <vsnprintf+0x45>
  800777:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80077c:	eb f0                	jmp    80076e <vsnprintf+0x45>

0080077e <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80077e:	55                   	push   %ebp
  80077f:	89 e5                	mov    %esp,%ebp
  800781:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800784:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800787:	50                   	push   %eax
  800788:	ff 75 10             	pushl  0x10(%ebp)
  80078b:	ff 75 0c             	pushl  0xc(%ebp)
  80078e:	ff 75 08             	pushl  0x8(%ebp)
  800791:	e8 93 ff ff ff       	call   800729 <vsnprintf>
	va_end(ap);

	return rc;
}
  800796:	c9                   	leave  
  800797:	c3                   	ret    

00800798 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800798:	55                   	push   %ebp
  800799:	89 e5                	mov    %esp,%ebp
  80079b:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80079e:	b8 00 00 00 00       	mov    $0x0,%eax
  8007a3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007a7:	74 03                	je     8007ac <strlen+0x14>
		n++;
  8007a9:	40                   	inc    %eax
  8007aa:	eb f7                	jmp    8007a3 <strlen+0xb>
	return n;
}
  8007ac:	5d                   	pop    %ebp
  8007ad:	c3                   	ret    

008007ae <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007ae:	55                   	push   %ebp
  8007af:	89 e5                	mov    %esp,%ebp
  8007b1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007b4:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007b7:	b8 00 00 00 00       	mov    $0x0,%eax
  8007bc:	39 d0                	cmp    %edx,%eax
  8007be:	74 0b                	je     8007cb <strnlen+0x1d>
  8007c0:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007c4:	74 03                	je     8007c9 <strnlen+0x1b>
		n++;
  8007c6:	40                   	inc    %eax
  8007c7:	eb f3                	jmp    8007bc <strnlen+0xe>
  8007c9:	89 c2                	mov    %eax,%edx
	return n;
}
  8007cb:	89 d0                	mov    %edx,%eax
  8007cd:	5d                   	pop    %ebp
  8007ce:	c3                   	ret    

008007cf <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007cf:	55                   	push   %ebp
  8007d0:	89 e5                	mov    %esp,%ebp
  8007d2:	53                   	push   %ebx
  8007d3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007d6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007d9:	b8 00 00 00 00       	mov    $0x0,%eax
  8007de:	8a 14 03             	mov    (%ebx,%eax,1),%dl
  8007e1:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8007e4:	40                   	inc    %eax
  8007e5:	84 d2                	test   %dl,%dl
  8007e7:	75 f5                	jne    8007de <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8007e9:	89 c8                	mov    %ecx,%eax
  8007eb:	5b                   	pop    %ebx
  8007ec:	5d                   	pop    %ebp
  8007ed:	c3                   	ret    

008007ee <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007ee:	55                   	push   %ebp
  8007ef:	89 e5                	mov    %esp,%ebp
  8007f1:	53                   	push   %ebx
  8007f2:	83 ec 10             	sub    $0x10,%esp
  8007f5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007f8:	53                   	push   %ebx
  8007f9:	e8 9a ff ff ff       	call   800798 <strlen>
  8007fe:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800801:	ff 75 0c             	pushl  0xc(%ebp)
  800804:	01 d8                	add    %ebx,%eax
  800806:	50                   	push   %eax
  800807:	e8 c3 ff ff ff       	call   8007cf <strcpy>
	return dst;
}
  80080c:	89 d8                	mov    %ebx,%eax
  80080e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800811:	c9                   	leave  
  800812:	c3                   	ret    

00800813 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800813:	55                   	push   %ebp
  800814:	89 e5                	mov    %esp,%ebp
  800816:	53                   	push   %ebx
  800817:	8b 55 0c             	mov    0xc(%ebp),%edx
  80081a:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80081d:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800820:	8b 45 08             	mov    0x8(%ebp),%eax
  800823:	39 d8                	cmp    %ebx,%eax
  800825:	74 0e                	je     800835 <strncpy+0x22>
		*dst++ = *src;
  800827:	40                   	inc    %eax
  800828:	8a 0a                	mov    (%edx),%cl
  80082a:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80082d:	80 f9 01             	cmp    $0x1,%cl
  800830:	83 da ff             	sbb    $0xffffffff,%edx
  800833:	eb ee                	jmp    800823 <strncpy+0x10>
	}
	return ret;
}
  800835:	8b 45 08             	mov    0x8(%ebp),%eax
  800838:	5b                   	pop    %ebx
  800839:	5d                   	pop    %ebp
  80083a:	c3                   	ret    

0080083b <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80083b:	55                   	push   %ebp
  80083c:	89 e5                	mov    %esp,%ebp
  80083e:	56                   	push   %esi
  80083f:	53                   	push   %ebx
  800840:	8b 75 08             	mov    0x8(%ebp),%esi
  800843:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800846:	8b 45 10             	mov    0x10(%ebp),%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800849:	85 c0                	test   %eax,%eax
  80084b:	74 22                	je     80086f <strlcpy+0x34>
  80084d:	8d 44 06 ff          	lea    -0x1(%esi,%eax,1),%eax
  800851:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  800853:	39 c2                	cmp    %eax,%edx
  800855:	74 0f                	je     800866 <strlcpy+0x2b>
  800857:	8a 19                	mov    (%ecx),%bl
  800859:	84 db                	test   %bl,%bl
  80085b:	74 07                	je     800864 <strlcpy+0x29>
			*dst++ = *src++;
  80085d:	41                   	inc    %ecx
  80085e:	42                   	inc    %edx
  80085f:	88 5a ff             	mov    %bl,-0x1(%edx)
  800862:	eb ef                	jmp    800853 <strlcpy+0x18>
  800864:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800866:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800869:	29 f0                	sub    %esi,%eax
}
  80086b:	5b                   	pop    %ebx
  80086c:	5e                   	pop    %esi
  80086d:	5d                   	pop    %ebp
  80086e:	c3                   	ret    
  80086f:	89 f0                	mov    %esi,%eax
  800871:	eb f6                	jmp    800869 <strlcpy+0x2e>

00800873 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800873:	55                   	push   %ebp
  800874:	89 e5                	mov    %esp,%ebp
  800876:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800879:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80087c:	8a 01                	mov    (%ecx),%al
  80087e:	84 c0                	test   %al,%al
  800880:	74 08                	je     80088a <strcmp+0x17>
  800882:	3a 02                	cmp    (%edx),%al
  800884:	75 04                	jne    80088a <strcmp+0x17>
		p++, q++;
  800886:	41                   	inc    %ecx
  800887:	42                   	inc    %edx
  800888:	eb f2                	jmp    80087c <strcmp+0x9>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80088a:	0f b6 c0             	movzbl %al,%eax
  80088d:	0f b6 12             	movzbl (%edx),%edx
  800890:	29 d0                	sub    %edx,%eax
}
  800892:	5d                   	pop    %ebp
  800893:	c3                   	ret    

00800894 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800894:	55                   	push   %ebp
  800895:	89 e5                	mov    %esp,%ebp
  800897:	53                   	push   %ebx
  800898:	8b 45 08             	mov    0x8(%ebp),%eax
  80089b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80089e:	89 c3                	mov    %eax,%ebx
  8008a0:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008a3:	eb 02                	jmp    8008a7 <strncmp+0x13>
		n--, p++, q++;
  8008a5:	40                   	inc    %eax
  8008a6:	42                   	inc    %edx
	while (n > 0 && *p && *p == *q)
  8008a7:	39 d8                	cmp    %ebx,%eax
  8008a9:	74 15                	je     8008c0 <strncmp+0x2c>
  8008ab:	8a 08                	mov    (%eax),%cl
  8008ad:	84 c9                	test   %cl,%cl
  8008af:	74 04                	je     8008b5 <strncmp+0x21>
  8008b1:	3a 0a                	cmp    (%edx),%cl
  8008b3:	74 f0                	je     8008a5 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008b5:	0f b6 00             	movzbl (%eax),%eax
  8008b8:	0f b6 12             	movzbl (%edx),%edx
  8008bb:	29 d0                	sub    %edx,%eax
}
  8008bd:	5b                   	pop    %ebx
  8008be:	5d                   	pop    %ebp
  8008bf:	c3                   	ret    
		return 0;
  8008c0:	b8 00 00 00 00       	mov    $0x0,%eax
  8008c5:	eb f6                	jmp    8008bd <strncmp+0x29>

008008c7 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008c7:	55                   	push   %ebp
  8008c8:	89 e5                	mov    %esp,%ebp
  8008ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8008cd:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8008d0:	8a 10                	mov    (%eax),%dl
  8008d2:	84 d2                	test   %dl,%dl
  8008d4:	74 07                	je     8008dd <strchr+0x16>
		if (*s == c)
  8008d6:	38 ca                	cmp    %cl,%dl
  8008d8:	74 08                	je     8008e2 <strchr+0x1b>
	for (; *s; s++)
  8008da:	40                   	inc    %eax
  8008db:	eb f3                	jmp    8008d0 <strchr+0x9>
			return (char *) s;
	return 0;
  8008dd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008e2:	5d                   	pop    %ebp
  8008e3:	c3                   	ret    

008008e4 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008e4:	55                   	push   %ebp
  8008e5:	89 e5                	mov    %esp,%ebp
  8008e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ea:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8008ed:	8a 10                	mov    (%eax),%dl
  8008ef:	84 d2                	test   %dl,%dl
  8008f1:	74 07                	je     8008fa <strfind+0x16>
		if (*s == c)
  8008f3:	38 ca                	cmp    %cl,%dl
  8008f5:	74 03                	je     8008fa <strfind+0x16>
	for (; *s; s++)
  8008f7:	40                   	inc    %eax
  8008f8:	eb f3                	jmp    8008ed <strfind+0x9>
			break;
	return (char *) s;
}
  8008fa:	5d                   	pop    %ebp
  8008fb:	c3                   	ret    

008008fc <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008fc:	55                   	push   %ebp
  8008fd:	89 e5                	mov    %esp,%ebp
  8008ff:	57                   	push   %edi
  800900:	56                   	push   %esi
  800901:	53                   	push   %ebx
  800902:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800905:	85 c9                	test   %ecx,%ecx
  800907:	74 36                	je     80093f <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800909:	89 c8                	mov    %ecx,%eax
  80090b:	0b 45 08             	or     0x8(%ebp),%eax
  80090e:	a8 03                	test   $0x3,%al
  800910:	75 24                	jne    800936 <memset+0x3a>
		c &= 0xFF;
  800912:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800916:	89 d3                	mov    %edx,%ebx
  800918:	c1 e3 08             	shl    $0x8,%ebx
  80091b:	89 d0                	mov    %edx,%eax
  80091d:	c1 e0 18             	shl    $0x18,%eax
  800920:	89 d6                	mov    %edx,%esi
  800922:	c1 e6 10             	shl    $0x10,%esi
  800925:	09 f0                	or     %esi,%eax
  800927:	09 d0                	or     %edx,%eax
  800929:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80092b:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  80092e:	8b 7d 08             	mov    0x8(%ebp),%edi
  800931:	fc                   	cld    
  800932:	f3 ab                	rep stos %eax,%es:(%edi)
  800934:	eb 09                	jmp    80093f <memset+0x43>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800936:	8b 7d 08             	mov    0x8(%ebp),%edi
  800939:	8b 45 0c             	mov    0xc(%ebp),%eax
  80093c:	fc                   	cld    
  80093d:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80093f:	8b 45 08             	mov    0x8(%ebp),%eax
  800942:	5b                   	pop    %ebx
  800943:	5e                   	pop    %esi
  800944:	5f                   	pop    %edi
  800945:	5d                   	pop    %ebp
  800946:	c3                   	ret    

00800947 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800947:	55                   	push   %ebp
  800948:	89 e5                	mov    %esp,%ebp
  80094a:	57                   	push   %edi
  80094b:	56                   	push   %esi
  80094c:	8b 45 08             	mov    0x8(%ebp),%eax
  80094f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800952:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800955:	39 c6                	cmp    %eax,%esi
  800957:	73 30                	jae    800989 <memmove+0x42>
  800959:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80095c:	39 c2                	cmp    %eax,%edx
  80095e:	76 29                	jbe    800989 <memmove+0x42>
		s += n;
		d += n;
  800960:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800963:	89 fe                	mov    %edi,%esi
  800965:	09 ce                	or     %ecx,%esi
  800967:	09 d6                	or     %edx,%esi
  800969:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80096f:	75 0e                	jne    80097f <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800971:	83 ef 04             	sub    $0x4,%edi
  800974:	8d 72 fc             	lea    -0x4(%edx),%esi
  800977:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  80097a:	fd                   	std    
  80097b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80097d:	eb 07                	jmp    800986 <memmove+0x3f>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80097f:	4f                   	dec    %edi
  800980:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800983:	fd                   	std    
  800984:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800986:	fc                   	cld    
  800987:	eb 1a                	jmp    8009a3 <memmove+0x5c>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800989:	89 c2                	mov    %eax,%edx
  80098b:	09 ca                	or     %ecx,%edx
  80098d:	09 f2                	or     %esi,%edx
  80098f:	f6 c2 03             	test   $0x3,%dl
  800992:	75 0a                	jne    80099e <memmove+0x57>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800994:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800997:	89 c7                	mov    %eax,%edi
  800999:	fc                   	cld    
  80099a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80099c:	eb 05                	jmp    8009a3 <memmove+0x5c>
		else
			asm volatile("cld; rep movsb\n"
  80099e:	89 c7                	mov    %eax,%edi
  8009a0:	fc                   	cld    
  8009a1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009a3:	5e                   	pop    %esi
  8009a4:	5f                   	pop    %edi
  8009a5:	5d                   	pop    %ebp
  8009a6:	c3                   	ret    

008009a7 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009a7:	55                   	push   %ebp
  8009a8:	89 e5                	mov    %esp,%ebp
  8009aa:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8009ad:	ff 75 10             	pushl  0x10(%ebp)
  8009b0:	ff 75 0c             	pushl  0xc(%ebp)
  8009b3:	ff 75 08             	pushl  0x8(%ebp)
  8009b6:	e8 8c ff ff ff       	call   800947 <memmove>
}
  8009bb:	c9                   	leave  
  8009bc:	c3                   	ret    

008009bd <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009bd:	55                   	push   %ebp
  8009be:	89 e5                	mov    %esp,%ebp
  8009c0:	56                   	push   %esi
  8009c1:	53                   	push   %ebx
  8009c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009c8:	89 c6                	mov    %eax,%esi
  8009ca:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009cd:	39 f0                	cmp    %esi,%eax
  8009cf:	74 16                	je     8009e7 <memcmp+0x2a>
		if (*s1 != *s2)
  8009d1:	8a 08                	mov    (%eax),%cl
  8009d3:	8a 1a                	mov    (%edx),%bl
  8009d5:	38 d9                	cmp    %bl,%cl
  8009d7:	75 04                	jne    8009dd <memcmp+0x20>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  8009d9:	40                   	inc    %eax
  8009da:	42                   	inc    %edx
  8009db:	eb f0                	jmp    8009cd <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  8009dd:	0f b6 c1             	movzbl %cl,%eax
  8009e0:	0f b6 db             	movzbl %bl,%ebx
  8009e3:	29 d8                	sub    %ebx,%eax
  8009e5:	eb 05                	jmp    8009ec <memcmp+0x2f>
	}

	return 0;
  8009e7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009ec:	5b                   	pop    %ebx
  8009ed:	5e                   	pop    %esi
  8009ee:	5d                   	pop    %ebp
  8009ef:	c3                   	ret    

008009f0 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009f0:	55                   	push   %ebp
  8009f1:	89 e5                	mov    %esp,%ebp
  8009f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8009f9:	89 c2                	mov    %eax,%edx
  8009fb:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8009fe:	39 d0                	cmp    %edx,%eax
  800a00:	73 07                	jae    800a09 <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a02:	38 08                	cmp    %cl,(%eax)
  800a04:	74 03                	je     800a09 <memfind+0x19>
	for (; s < ends; s++)
  800a06:	40                   	inc    %eax
  800a07:	eb f5                	jmp    8009fe <memfind+0xe>
			break;
	return (void *) s;
}
  800a09:	5d                   	pop    %ebp
  800a0a:	c3                   	ret    

00800a0b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a0b:	55                   	push   %ebp
  800a0c:	89 e5                	mov    %esp,%ebp
  800a0e:	57                   	push   %edi
  800a0f:	56                   	push   %esi
  800a10:	53                   	push   %ebx
  800a11:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a14:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a17:	eb 01                	jmp    800a1a <strtol+0xf>
		s++;
  800a19:	41                   	inc    %ecx
	while (*s == ' ' || *s == '\t')
  800a1a:	8a 01                	mov    (%ecx),%al
  800a1c:	3c 20                	cmp    $0x20,%al
  800a1e:	74 f9                	je     800a19 <strtol+0xe>
  800a20:	3c 09                	cmp    $0x9,%al
  800a22:	74 f5                	je     800a19 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800a24:	3c 2b                	cmp    $0x2b,%al
  800a26:	74 24                	je     800a4c <strtol+0x41>
		s++;
	else if (*s == '-')
  800a28:	3c 2d                	cmp    $0x2d,%al
  800a2a:	74 28                	je     800a54 <strtol+0x49>
	int neg = 0;
  800a2c:	bf 00 00 00 00       	mov    $0x0,%edi
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a31:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a37:	75 09                	jne    800a42 <strtol+0x37>
  800a39:	80 39 30             	cmpb   $0x30,(%ecx)
  800a3c:	74 1e                	je     800a5c <strtol+0x51>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a3e:	85 db                	test   %ebx,%ebx
  800a40:	74 36                	je     800a78 <strtol+0x6d>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a42:	b8 00 00 00 00       	mov    $0x0,%eax
  800a47:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800a4a:	eb 45                	jmp    800a91 <strtol+0x86>
		s++;
  800a4c:	41                   	inc    %ecx
	int neg = 0;
  800a4d:	bf 00 00 00 00       	mov    $0x0,%edi
  800a52:	eb dd                	jmp    800a31 <strtol+0x26>
		s++, neg = 1;
  800a54:	41                   	inc    %ecx
  800a55:	bf 01 00 00 00       	mov    $0x1,%edi
  800a5a:	eb d5                	jmp    800a31 <strtol+0x26>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a5c:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a60:	74 0c                	je     800a6e <strtol+0x63>
	else if (base == 0 && s[0] == '0')
  800a62:	85 db                	test   %ebx,%ebx
  800a64:	75 dc                	jne    800a42 <strtol+0x37>
		s++, base = 8;
  800a66:	41                   	inc    %ecx
  800a67:	bb 08 00 00 00       	mov    $0x8,%ebx
  800a6c:	eb d4                	jmp    800a42 <strtol+0x37>
		s += 2, base = 16;
  800a6e:	83 c1 02             	add    $0x2,%ecx
  800a71:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a76:	eb ca                	jmp    800a42 <strtol+0x37>
		base = 10;
  800a78:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800a7d:	eb c3                	jmp    800a42 <strtol+0x37>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800a7f:	0f be d2             	movsbl %dl,%edx
  800a82:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800a85:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a88:	7d 37                	jge    800ac1 <strtol+0xb6>
			break;
		s++, val = (val * base) + dig;
  800a8a:	41                   	inc    %ecx
  800a8b:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a8f:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800a91:	8a 11                	mov    (%ecx),%dl
  800a93:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a96:	89 f3                	mov    %esi,%ebx
  800a98:	80 fb 09             	cmp    $0x9,%bl
  800a9b:	76 e2                	jbe    800a7f <strtol+0x74>
		else if (*s >= 'a' && *s <= 'z')
  800a9d:	8d 72 9f             	lea    -0x61(%edx),%esi
  800aa0:	89 f3                	mov    %esi,%ebx
  800aa2:	80 fb 19             	cmp    $0x19,%bl
  800aa5:	77 08                	ja     800aaf <strtol+0xa4>
			dig = *s - 'a' + 10;
  800aa7:	0f be d2             	movsbl %dl,%edx
  800aaa:	83 ea 57             	sub    $0x57,%edx
  800aad:	eb d6                	jmp    800a85 <strtol+0x7a>
		else if (*s >= 'A' && *s <= 'Z')
  800aaf:	8d 72 bf             	lea    -0x41(%edx),%esi
  800ab2:	89 f3                	mov    %esi,%ebx
  800ab4:	80 fb 19             	cmp    $0x19,%bl
  800ab7:	77 08                	ja     800ac1 <strtol+0xb6>
			dig = *s - 'A' + 10;
  800ab9:	0f be d2             	movsbl %dl,%edx
  800abc:	83 ea 37             	sub    $0x37,%edx
  800abf:	eb c4                	jmp    800a85 <strtol+0x7a>
		// we don't properly detect overflow!
	}

	if (endptr)
  800ac1:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ac5:	74 05                	je     800acc <strtol+0xc1>
		*endptr = (char *) s;
  800ac7:	8b 75 0c             	mov    0xc(%ebp),%esi
  800aca:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800acc:	85 ff                	test   %edi,%edi
  800ace:	74 02                	je     800ad2 <strtol+0xc7>
  800ad0:	f7 d8                	neg    %eax
}
  800ad2:	5b                   	pop    %ebx
  800ad3:	5e                   	pop    %esi
  800ad4:	5f                   	pop    %edi
  800ad5:	5d                   	pop    %ebp
  800ad6:	c3                   	ret    
  800ad7:	90                   	nop

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
