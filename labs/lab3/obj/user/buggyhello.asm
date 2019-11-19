
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
  80003d:	e8 76 00 00 00       	call   8000b8 <sys_cputs>
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
  80004a:	57                   	push   %edi
  80004b:	56                   	push   %esi
  80004c:	53                   	push   %ebx
  80004d:	83 ec 6c             	sub    $0x6c,%esp
  800050:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	struct Env curenv = envs[ENVX(sys_getenvid())];
  800053:	e8 de 00 00 00       	call   800136 <sys_getenvid>
  800058:	25 ff 03 00 00       	and    $0x3ff,%eax
  80005d:	8d 34 00             	lea    (%eax,%eax,1),%esi
  800060:	01 c6                	add    %eax,%esi
  800062:	c1 e6 05             	shl    $0x5,%esi
  800065:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  80006b:	8d 7d 88             	lea    -0x78(%ebp),%edi
  80006e:	b9 18 00 00 00       	mov    $0x18,%ecx
  800073:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	thisenv = &curenv;
  800075:	8d 45 88             	lea    -0x78(%ebp),%eax
  800078:	a3 04 10 80 00       	mov    %eax,0x801004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80007d:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800081:	7e 07                	jle    80008a <libmain+0x43>
		binaryname = argv[0];
  800083:	8b 03                	mov    (%ebx),%eax
  800085:	a3 00 10 80 00       	mov    %eax,0x801000
	
	// call user main routine
	umain(argc, argv);
  80008a:	83 ec 08             	sub    $0x8,%esp
  80008d:	53                   	push   %ebx
  80008e:	ff 75 08             	pushl  0x8(%ebp)
  800091:	e8 9d ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800096:	e8 0b 00 00 00       	call   8000a6 <exit>
}
  80009b:	83 c4 10             	add    $0x10,%esp
  80009e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000a1:	5b                   	pop    %ebx
  8000a2:	5e                   	pop    %esi
  8000a3:	5f                   	pop    %edi
  8000a4:	5d                   	pop    %ebp
  8000a5:	c3                   	ret    

008000a6 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000a6:	55                   	push   %ebp
  8000a7:	89 e5                	mov    %esp,%ebp
  8000a9:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8000ac:	6a 00                	push   $0x0
  8000ae:	e8 42 00 00 00       	call   8000f5 <sys_env_destroy>
}
  8000b3:	83 c4 10             	add    $0x10,%esp
  8000b6:	c9                   	leave  
  8000b7:	c3                   	ret    

008000b8 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000b8:	55                   	push   %ebp
  8000b9:	89 e5                	mov    %esp,%ebp
  8000bb:	57                   	push   %edi
  8000bc:	56                   	push   %esi
  8000bd:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000be:	b8 00 00 00 00       	mov    $0x0,%eax
  8000c3:	8b 55 08             	mov    0x8(%ebp),%edx
  8000c6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000c9:	89 c3                	mov    %eax,%ebx
  8000cb:	89 c7                	mov    %eax,%edi
  8000cd:	89 c6                	mov    %eax,%esi
  8000cf:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000d1:	5b                   	pop    %ebx
  8000d2:	5e                   	pop    %esi
  8000d3:	5f                   	pop    %edi
  8000d4:	5d                   	pop    %ebp
  8000d5:	c3                   	ret    

008000d6 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000d6:	55                   	push   %ebp
  8000d7:	89 e5                	mov    %esp,%ebp
  8000d9:	57                   	push   %edi
  8000da:	56                   	push   %esi
  8000db:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000dc:	ba 00 00 00 00       	mov    $0x0,%edx
  8000e1:	b8 01 00 00 00       	mov    $0x1,%eax
  8000e6:	89 d1                	mov    %edx,%ecx
  8000e8:	89 d3                	mov    %edx,%ebx
  8000ea:	89 d7                	mov    %edx,%edi
  8000ec:	89 d6                	mov    %edx,%esi
  8000ee:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000f0:	5b                   	pop    %ebx
  8000f1:	5e                   	pop    %esi
  8000f2:	5f                   	pop    %edi
  8000f3:	5d                   	pop    %ebp
  8000f4:	c3                   	ret    

008000f5 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000f5:	55                   	push   %ebp
  8000f6:	89 e5                	mov    %esp,%ebp
  8000f8:	57                   	push   %edi
  8000f9:	56                   	push   %esi
  8000fa:	53                   	push   %ebx
  8000fb:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8000fe:	b9 00 00 00 00       	mov    $0x0,%ecx
  800103:	8b 55 08             	mov    0x8(%ebp),%edx
  800106:	b8 03 00 00 00       	mov    $0x3,%eax
  80010b:	89 cb                	mov    %ecx,%ebx
  80010d:	89 cf                	mov    %ecx,%edi
  80010f:	89 ce                	mov    %ecx,%esi
  800111:	cd 30                	int    $0x30
	if(check && ret > 0)
  800113:	85 c0                	test   %eax,%eax
  800115:	7f 08                	jg     80011f <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800117:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80011a:	5b                   	pop    %ebx
  80011b:	5e                   	pop    %esi
  80011c:	5f                   	pop    %edi
  80011d:	5d                   	pop    %ebp
  80011e:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80011f:	83 ec 0c             	sub    $0xc,%esp
  800122:	50                   	push   %eax
  800123:	6a 03                	push   $0x3
  800125:	68 1a 0d 80 00       	push   $0x800d1a
  80012a:	6a 23                	push   $0x23
  80012c:	68 37 0d 80 00       	push   $0x800d37
  800131:	e8 1f 00 00 00       	call   800155 <_panic>

00800136 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800136:	55                   	push   %ebp
  800137:	89 e5                	mov    %esp,%ebp
  800139:	57                   	push   %edi
  80013a:	56                   	push   %esi
  80013b:	53                   	push   %ebx
	asm volatile("int %1\n"
  80013c:	ba 00 00 00 00       	mov    $0x0,%edx
  800141:	b8 02 00 00 00       	mov    $0x2,%eax
  800146:	89 d1                	mov    %edx,%ecx
  800148:	89 d3                	mov    %edx,%ebx
  80014a:	89 d7                	mov    %edx,%edi
  80014c:	89 d6                	mov    %edx,%esi
  80014e:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800150:	5b                   	pop    %ebx
  800151:	5e                   	pop    %esi
  800152:	5f                   	pop    %edi
  800153:	5d                   	pop    %ebp
  800154:	c3                   	ret    

00800155 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800155:	55                   	push   %ebp
  800156:	89 e5                	mov    %esp,%ebp
  800158:	56                   	push   %esi
  800159:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80015a:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80015d:	8b 35 00 10 80 00    	mov    0x801000,%esi
  800163:	e8 ce ff ff ff       	call   800136 <sys_getenvid>
  800168:	83 ec 0c             	sub    $0xc,%esp
  80016b:	ff 75 0c             	pushl  0xc(%ebp)
  80016e:	ff 75 08             	pushl  0x8(%ebp)
  800171:	56                   	push   %esi
  800172:	50                   	push   %eax
  800173:	68 48 0d 80 00       	push   $0x800d48
  800178:	e8 b2 00 00 00       	call   80022f <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80017d:	83 c4 18             	add    $0x18,%esp
  800180:	53                   	push   %ebx
  800181:	ff 75 10             	pushl  0x10(%ebp)
  800184:	e8 55 00 00 00       	call   8001de <vcprintf>
	cprintf("\n");
  800189:	c7 04 24 6c 0d 80 00 	movl   $0x800d6c,(%esp)
  800190:	e8 9a 00 00 00       	call   80022f <cprintf>
  800195:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800198:	cc                   	int3   
  800199:	eb fd                	jmp    800198 <_panic+0x43>

0080019b <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80019b:	55                   	push   %ebp
  80019c:	89 e5                	mov    %esp,%ebp
  80019e:	53                   	push   %ebx
  80019f:	83 ec 04             	sub    $0x4,%esp
  8001a2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001a5:	8b 13                	mov    (%ebx),%edx
  8001a7:	8d 42 01             	lea    0x1(%edx),%eax
  8001aa:	89 03                	mov    %eax,(%ebx)
  8001ac:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001af:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001b3:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001b8:	74 08                	je     8001c2 <putch+0x27>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8001ba:	ff 43 04             	incl   0x4(%ebx)
}
  8001bd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001c0:	c9                   	leave  
  8001c1:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8001c2:	83 ec 08             	sub    $0x8,%esp
  8001c5:	68 ff 00 00 00       	push   $0xff
  8001ca:	8d 43 08             	lea    0x8(%ebx),%eax
  8001cd:	50                   	push   %eax
  8001ce:	e8 e5 fe ff ff       	call   8000b8 <sys_cputs>
		b->idx = 0;
  8001d3:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001d9:	83 c4 10             	add    $0x10,%esp
  8001dc:	eb dc                	jmp    8001ba <putch+0x1f>

008001de <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001de:	55                   	push   %ebp
  8001df:	89 e5                	mov    %esp,%ebp
  8001e1:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001e7:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001ee:	00 00 00 
	b.cnt = 0;
  8001f1:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001f8:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001fb:	ff 75 0c             	pushl  0xc(%ebp)
  8001fe:	ff 75 08             	pushl  0x8(%ebp)
  800201:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800207:	50                   	push   %eax
  800208:	68 9b 01 80 00       	push   $0x80019b
  80020d:	e8 0f 01 00 00       	call   800321 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800212:	83 c4 08             	add    $0x8,%esp
  800215:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80021b:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800221:	50                   	push   %eax
  800222:	e8 91 fe ff ff       	call   8000b8 <sys_cputs>

	return b.cnt;
}
  800227:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80022d:	c9                   	leave  
  80022e:	c3                   	ret    

0080022f <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80022f:	55                   	push   %ebp
  800230:	89 e5                	mov    %esp,%ebp
  800232:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800235:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800238:	50                   	push   %eax
  800239:	ff 75 08             	pushl  0x8(%ebp)
  80023c:	e8 9d ff ff ff       	call   8001de <vcprintf>
	va_end(ap);

	return cnt;
}
  800241:	c9                   	leave  
  800242:	c3                   	ret    

00800243 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800243:	55                   	push   %ebp
  800244:	89 e5                	mov    %esp,%ebp
  800246:	57                   	push   %edi
  800247:	56                   	push   %esi
  800248:	53                   	push   %ebx
  800249:	83 ec 1c             	sub    $0x1c,%esp
  80024c:	89 c7                	mov    %eax,%edi
  80024e:	89 d6                	mov    %edx,%esi
  800250:	8b 45 08             	mov    0x8(%ebp),%eax
  800253:	8b 55 0c             	mov    0xc(%ebp),%edx
  800256:	89 d1                	mov    %edx,%ecx
  800258:	89 c2                	mov    %eax,%edx
  80025a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80025d:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800260:	8b 45 10             	mov    0x10(%ebp),%eax
  800263:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800266:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800269:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800270:	39 c2                	cmp    %eax,%edx
  800272:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  800275:	72 3c                	jb     8002b3 <printnum+0x70>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800277:	83 ec 0c             	sub    $0xc,%esp
  80027a:	ff 75 18             	pushl  0x18(%ebp)
  80027d:	4b                   	dec    %ebx
  80027e:	53                   	push   %ebx
  80027f:	50                   	push   %eax
  800280:	83 ec 08             	sub    $0x8,%esp
  800283:	ff 75 e4             	pushl  -0x1c(%ebp)
  800286:	ff 75 e0             	pushl  -0x20(%ebp)
  800289:	ff 75 dc             	pushl  -0x24(%ebp)
  80028c:	ff 75 d8             	pushl  -0x28(%ebp)
  80028f:	e8 54 08 00 00       	call   800ae8 <__udivdi3>
  800294:	83 c4 18             	add    $0x18,%esp
  800297:	52                   	push   %edx
  800298:	50                   	push   %eax
  800299:	89 f2                	mov    %esi,%edx
  80029b:	89 f8                	mov    %edi,%eax
  80029d:	e8 a1 ff ff ff       	call   800243 <printnum>
  8002a2:	83 c4 20             	add    $0x20,%esp
  8002a5:	eb 11                	jmp    8002b8 <printnum+0x75>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002a7:	83 ec 08             	sub    $0x8,%esp
  8002aa:	56                   	push   %esi
  8002ab:	ff 75 18             	pushl  0x18(%ebp)
  8002ae:	ff d7                	call   *%edi
  8002b0:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8002b3:	4b                   	dec    %ebx
  8002b4:	85 db                	test   %ebx,%ebx
  8002b6:	7f ef                	jg     8002a7 <printnum+0x64>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002b8:	83 ec 08             	sub    $0x8,%esp
  8002bb:	56                   	push   %esi
  8002bc:	83 ec 04             	sub    $0x4,%esp
  8002bf:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002c2:	ff 75 e0             	pushl  -0x20(%ebp)
  8002c5:	ff 75 dc             	pushl  -0x24(%ebp)
  8002c8:	ff 75 d8             	pushl  -0x28(%ebp)
  8002cb:	e8 18 09 00 00       	call   800be8 <__umoddi3>
  8002d0:	83 c4 14             	add    $0x14,%esp
  8002d3:	0f be 80 6e 0d 80 00 	movsbl 0x800d6e(%eax),%eax
  8002da:	50                   	push   %eax
  8002db:	ff d7                	call   *%edi
}
  8002dd:	83 c4 10             	add    $0x10,%esp
  8002e0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002e3:	5b                   	pop    %ebx
  8002e4:	5e                   	pop    %esi
  8002e5:	5f                   	pop    %edi
  8002e6:	5d                   	pop    %ebp
  8002e7:	c3                   	ret    

008002e8 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002e8:	55                   	push   %ebp
  8002e9:	89 e5                	mov    %esp,%ebp
  8002eb:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002ee:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8002f1:	8b 10                	mov    (%eax),%edx
  8002f3:	3b 50 04             	cmp    0x4(%eax),%edx
  8002f6:	73 0a                	jae    800302 <sprintputch+0x1a>
		*b->buf++ = ch;
  8002f8:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002fb:	89 08                	mov    %ecx,(%eax)
  8002fd:	8b 45 08             	mov    0x8(%ebp),%eax
  800300:	88 02                	mov    %al,(%edx)
}
  800302:	5d                   	pop    %ebp
  800303:	c3                   	ret    

00800304 <printfmt>:
{
  800304:	55                   	push   %ebp
  800305:	89 e5                	mov    %esp,%ebp
  800307:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  80030a:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80030d:	50                   	push   %eax
  80030e:	ff 75 10             	pushl  0x10(%ebp)
  800311:	ff 75 0c             	pushl  0xc(%ebp)
  800314:	ff 75 08             	pushl  0x8(%ebp)
  800317:	e8 05 00 00 00       	call   800321 <vprintfmt>
}
  80031c:	83 c4 10             	add    $0x10,%esp
  80031f:	c9                   	leave  
  800320:	c3                   	ret    

00800321 <vprintfmt>:
{
  800321:	55                   	push   %ebp
  800322:	89 e5                	mov    %esp,%ebp
  800324:	57                   	push   %edi
  800325:	56                   	push   %esi
  800326:	53                   	push   %ebx
  800327:	83 ec 3c             	sub    $0x3c,%esp
  80032a:	8b 75 08             	mov    0x8(%ebp),%esi
  80032d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800330:	8b 7d 10             	mov    0x10(%ebp),%edi
  800333:	e9 5b 03 00 00       	jmp    800693 <vprintfmt+0x372>
		padc = ' ';
  800338:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  80033c:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
		precision = -1;
  800343:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  80034a:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		lflag = 0;
  800351:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800356:	8d 47 01             	lea    0x1(%edi),%eax
  800359:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80035c:	8a 17                	mov    (%edi),%dl
  80035e:	8d 42 dd             	lea    -0x23(%edx),%eax
  800361:	3c 55                	cmp    $0x55,%al
  800363:	0f 87 ab 03 00 00    	ja     800714 <vprintfmt+0x3f3>
  800369:	0f b6 c0             	movzbl %al,%eax
  80036c:	ff 24 85 fc 0d 80 00 	jmp    *0x800dfc(,%eax,4)
  800373:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800376:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  80037a:	eb da                	jmp    800356 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  80037c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80037f:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  800383:	eb d1                	jmp    800356 <vprintfmt+0x35>
  800385:	0f b6 d2             	movzbl %dl,%edx
  800388:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  80038b:	b8 00 00 00 00       	mov    $0x0,%eax
  800390:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800393:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800396:	01 c0                	add    %eax,%eax
  800398:	8d 44 02 d0          	lea    -0x30(%edx,%eax,1),%eax
				ch = *fmt;
  80039c:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  80039f:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8003a2:	83 f9 09             	cmp    $0x9,%ecx
  8003a5:	77 52                	ja     8003f9 <vprintfmt+0xd8>
			for (precision = 0; ; ++fmt) {
  8003a7:	47                   	inc    %edi
				precision = precision * 10 + ch - '0';
  8003a8:	eb e9                	jmp    800393 <vprintfmt+0x72>
			precision = va_arg(ap, int);
  8003aa:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ad:	8b 00                	mov    (%eax),%eax
  8003af:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003b2:	8b 45 14             	mov    0x14(%ebp),%eax
  8003b5:	8d 40 04             	lea    0x4(%eax),%eax
  8003b8:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003bb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8003be:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8003c2:	79 92                	jns    800356 <vprintfmt+0x35>
				width = precision, precision = -1;
  8003c4:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8003c7:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8003ca:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8003d1:	eb 83                	jmp    800356 <vprintfmt+0x35>
  8003d3:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8003d7:	78 08                	js     8003e1 <vprintfmt+0xc0>
		switch (ch = *(unsigned char *) fmt++) {
  8003d9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8003dc:	e9 75 ff ff ff       	jmp    800356 <vprintfmt+0x35>
  8003e1:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  8003e8:	eb ef                	jmp    8003d9 <vprintfmt+0xb8>
		switch (ch = *(unsigned char *) fmt++) {
  8003ea:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8003ed:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  8003f4:	e9 5d ff ff ff       	jmp    800356 <vprintfmt+0x35>
  8003f9:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8003fc:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003ff:	eb bd                	jmp    8003be <vprintfmt+0x9d>
			lflag++;
  800401:	41                   	inc    %ecx
		switch (ch = *(unsigned char *) fmt++) {
  800402:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800405:	e9 4c ff ff ff       	jmp    800356 <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
  80040a:	8b 45 14             	mov    0x14(%ebp),%eax
  80040d:	8d 78 04             	lea    0x4(%eax),%edi
  800410:	83 ec 08             	sub    $0x8,%esp
  800413:	53                   	push   %ebx
  800414:	ff 30                	pushl  (%eax)
  800416:	ff d6                	call   *%esi
			break;
  800418:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  80041b:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  80041e:	e9 6d 02 00 00       	jmp    800690 <vprintfmt+0x36f>
			err = va_arg(ap, int);
  800423:	8b 45 14             	mov    0x14(%ebp),%eax
  800426:	8d 78 04             	lea    0x4(%eax),%edi
  800429:	8b 00                	mov    (%eax),%eax
  80042b:	85 c0                	test   %eax,%eax
  80042d:	78 2a                	js     800459 <vprintfmt+0x138>
  80042f:	89 c2                	mov    %eax,%edx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800431:	83 f8 06             	cmp    $0x6,%eax
  800434:	7f 27                	jg     80045d <vprintfmt+0x13c>
  800436:	8b 04 85 54 0f 80 00 	mov    0x800f54(,%eax,4),%eax
  80043d:	85 c0                	test   %eax,%eax
  80043f:	74 1c                	je     80045d <vprintfmt+0x13c>
				printfmt(putch, putdat, "%s", p);
  800441:	50                   	push   %eax
  800442:	68 8f 0d 80 00       	push   $0x800d8f
  800447:	53                   	push   %ebx
  800448:	56                   	push   %esi
  800449:	e8 b6 fe ff ff       	call   800304 <printfmt>
  80044e:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800451:	89 7d 14             	mov    %edi,0x14(%ebp)
  800454:	e9 37 02 00 00       	jmp    800690 <vprintfmt+0x36f>
  800459:	f7 d8                	neg    %eax
  80045b:	eb d2                	jmp    80042f <vprintfmt+0x10e>
				printfmt(putch, putdat, "error %d", err);
  80045d:	52                   	push   %edx
  80045e:	68 86 0d 80 00       	push   $0x800d86
  800463:	53                   	push   %ebx
  800464:	56                   	push   %esi
  800465:	e8 9a fe ff ff       	call   800304 <printfmt>
  80046a:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80046d:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800470:	e9 1b 02 00 00       	jmp    800690 <vprintfmt+0x36f>
			if ((p = va_arg(ap, char *)) == NULL)
  800475:	8b 45 14             	mov    0x14(%ebp),%eax
  800478:	83 c0 04             	add    $0x4,%eax
  80047b:	89 45 c8             	mov    %eax,-0x38(%ebp)
  80047e:	8b 45 14             	mov    0x14(%ebp),%eax
  800481:	8b 00                	mov    (%eax),%eax
  800483:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800486:	85 c0                	test   %eax,%eax
  800488:	74 19                	je     8004a3 <vprintfmt+0x182>
			if (width > 0 && padc != '-')
  80048a:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80048e:	7e 06                	jle    800496 <vprintfmt+0x175>
  800490:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  800494:	75 16                	jne    8004ac <vprintfmt+0x18b>
				for (width -= strnlen(p, precision); width > 0; width--)
  800496:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800499:	89 c7                	mov    %eax,%edi
  80049b:	03 45 d4             	add    -0x2c(%ebp),%eax
  80049e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8004a1:	eb 62                	jmp    800505 <vprintfmt+0x1e4>
				p = "(null)";
  8004a3:	c7 45 cc 7f 0d 80 00 	movl   $0x800d7f,-0x34(%ebp)
  8004aa:	eb de                	jmp    80048a <vprintfmt+0x169>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004ac:	83 ec 08             	sub    $0x8,%esp
  8004af:	ff 75 d8             	pushl  -0x28(%ebp)
  8004b2:	ff 75 cc             	pushl  -0x34(%ebp)
  8004b5:	e8 05 03 00 00       	call   8007bf <strnlen>
  8004ba:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8004bd:	29 c2                	sub    %eax,%edx
  8004bf:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  8004c2:	83 c4 10             	add    $0x10,%esp
  8004c5:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  8004c7:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8004cb:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8004ce:	eb 0d                	jmp    8004dd <vprintfmt+0x1bc>
					putch(padc, putdat);
  8004d0:	83 ec 08             	sub    $0x8,%esp
  8004d3:	53                   	push   %ebx
  8004d4:	ff 75 d4             	pushl  -0x2c(%ebp)
  8004d7:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8004d9:	4f                   	dec    %edi
  8004da:	83 c4 10             	add    $0x10,%esp
  8004dd:	85 ff                	test   %edi,%edi
  8004df:	7f ef                	jg     8004d0 <vprintfmt+0x1af>
  8004e1:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8004e4:	89 d0                	mov    %edx,%eax
  8004e6:	85 d2                	test   %edx,%edx
  8004e8:	78 0a                	js     8004f4 <vprintfmt+0x1d3>
  8004ea:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8004ed:	29 c2                	sub    %eax,%edx
  8004ef:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8004f2:	eb a2                	jmp    800496 <vprintfmt+0x175>
  8004f4:	b8 00 00 00 00       	mov    $0x0,%eax
  8004f9:	eb ef                	jmp    8004ea <vprintfmt+0x1c9>
					putch(ch, putdat);
  8004fb:	83 ec 08             	sub    $0x8,%esp
  8004fe:	53                   	push   %ebx
  8004ff:	52                   	push   %edx
  800500:	ff d6                	call   *%esi
  800502:	83 c4 10             	add    $0x10,%esp
  800505:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  800508:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80050a:	47                   	inc    %edi
  80050b:	8a 47 ff             	mov    -0x1(%edi),%al
  80050e:	0f be d0             	movsbl %al,%edx
  800511:	85 d2                	test   %edx,%edx
  800513:	74 48                	je     80055d <vprintfmt+0x23c>
  800515:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800519:	78 05                	js     800520 <vprintfmt+0x1ff>
  80051b:	ff 4d d8             	decl   -0x28(%ebp)
  80051e:	78 1e                	js     80053e <vprintfmt+0x21d>
				if (altflag && (ch < ' ' || ch > '~'))
  800520:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800524:	74 d5                	je     8004fb <vprintfmt+0x1da>
  800526:	0f be c0             	movsbl %al,%eax
  800529:	83 e8 20             	sub    $0x20,%eax
  80052c:	83 f8 5e             	cmp    $0x5e,%eax
  80052f:	76 ca                	jbe    8004fb <vprintfmt+0x1da>
					putch('?', putdat);
  800531:	83 ec 08             	sub    $0x8,%esp
  800534:	53                   	push   %ebx
  800535:	6a 3f                	push   $0x3f
  800537:	ff d6                	call   *%esi
  800539:	83 c4 10             	add    $0x10,%esp
  80053c:	eb c7                	jmp    800505 <vprintfmt+0x1e4>
  80053e:	89 cf                	mov    %ecx,%edi
  800540:	eb 0c                	jmp    80054e <vprintfmt+0x22d>
				putch(' ', putdat);
  800542:	83 ec 08             	sub    $0x8,%esp
  800545:	53                   	push   %ebx
  800546:	6a 20                	push   $0x20
  800548:	ff d6                	call   *%esi
			for (; width > 0; width--)
  80054a:	4f                   	dec    %edi
  80054b:	83 c4 10             	add    $0x10,%esp
  80054e:	85 ff                	test   %edi,%edi
  800550:	7f f0                	jg     800542 <vprintfmt+0x221>
			if ((p = va_arg(ap, char *)) == NULL)
  800552:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800555:	89 45 14             	mov    %eax,0x14(%ebp)
  800558:	e9 33 01 00 00       	jmp    800690 <vprintfmt+0x36f>
  80055d:	89 cf                	mov    %ecx,%edi
  80055f:	eb ed                	jmp    80054e <vprintfmt+0x22d>
	if (lflag >= 2)
  800561:	83 f9 01             	cmp    $0x1,%ecx
  800564:	7f 1b                	jg     800581 <vprintfmt+0x260>
	else if (lflag)
  800566:	85 c9                	test   %ecx,%ecx
  800568:	74 42                	je     8005ac <vprintfmt+0x28b>
		return va_arg(*ap, long);
  80056a:	8b 45 14             	mov    0x14(%ebp),%eax
  80056d:	8b 00                	mov    (%eax),%eax
  80056f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800572:	99                   	cltd   
  800573:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800576:	8b 45 14             	mov    0x14(%ebp),%eax
  800579:	8d 40 04             	lea    0x4(%eax),%eax
  80057c:	89 45 14             	mov    %eax,0x14(%ebp)
  80057f:	eb 17                	jmp    800598 <vprintfmt+0x277>
		return va_arg(*ap, long long);
  800581:	8b 45 14             	mov    0x14(%ebp),%eax
  800584:	8b 50 04             	mov    0x4(%eax),%edx
  800587:	8b 00                	mov    (%eax),%eax
  800589:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80058c:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80058f:	8b 45 14             	mov    0x14(%ebp),%eax
  800592:	8d 40 08             	lea    0x8(%eax),%eax
  800595:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800598:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80059b:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80059e:	85 c9                	test   %ecx,%ecx
  8005a0:	78 21                	js     8005c3 <vprintfmt+0x2a2>
			base = 10;
  8005a2:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005a7:	e9 ca 00 00 00       	jmp    800676 <vprintfmt+0x355>
		return va_arg(*ap, int);
  8005ac:	8b 45 14             	mov    0x14(%ebp),%eax
  8005af:	8b 00                	mov    (%eax),%eax
  8005b1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005b4:	99                   	cltd   
  8005b5:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005b8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005bb:	8d 40 04             	lea    0x4(%eax),%eax
  8005be:	89 45 14             	mov    %eax,0x14(%ebp)
  8005c1:	eb d5                	jmp    800598 <vprintfmt+0x277>
				putch('-', putdat);
  8005c3:	83 ec 08             	sub    $0x8,%esp
  8005c6:	53                   	push   %ebx
  8005c7:	6a 2d                	push   $0x2d
  8005c9:	ff d6                	call   *%esi
				num = -(long long) num;
  8005cb:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005ce:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8005d1:	f7 da                	neg    %edx
  8005d3:	83 d1 00             	adc    $0x0,%ecx
  8005d6:	f7 d9                	neg    %ecx
  8005d8:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8005db:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005e0:	e9 91 00 00 00       	jmp    800676 <vprintfmt+0x355>
	if (lflag >= 2)
  8005e5:	83 f9 01             	cmp    $0x1,%ecx
  8005e8:	7f 1b                	jg     800605 <vprintfmt+0x2e4>
	else if (lflag)
  8005ea:	85 c9                	test   %ecx,%ecx
  8005ec:	74 2c                	je     80061a <vprintfmt+0x2f9>
		return va_arg(*ap, unsigned long);
  8005ee:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f1:	8b 10                	mov    (%eax),%edx
  8005f3:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005f8:	8d 40 04             	lea    0x4(%eax),%eax
  8005fb:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005fe:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  800603:	eb 71                	jmp    800676 <vprintfmt+0x355>
		return va_arg(*ap, unsigned long long);
  800605:	8b 45 14             	mov    0x14(%ebp),%eax
  800608:	8b 10                	mov    (%eax),%edx
  80060a:	8b 48 04             	mov    0x4(%eax),%ecx
  80060d:	8d 40 08             	lea    0x8(%eax),%eax
  800610:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800613:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  800618:	eb 5c                	jmp    800676 <vprintfmt+0x355>
		return va_arg(*ap, unsigned int);
  80061a:	8b 45 14             	mov    0x14(%ebp),%eax
  80061d:	8b 10                	mov    (%eax),%edx
  80061f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800624:	8d 40 04             	lea    0x4(%eax),%eax
  800627:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80062a:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  80062f:	eb 45                	jmp    800676 <vprintfmt+0x355>
			putch('X', putdat);
  800631:	83 ec 08             	sub    $0x8,%esp
  800634:	53                   	push   %ebx
  800635:	6a 58                	push   $0x58
  800637:	ff d6                	call   *%esi
			putch('X', putdat);
  800639:	83 c4 08             	add    $0x8,%esp
  80063c:	53                   	push   %ebx
  80063d:	6a 58                	push   $0x58
  80063f:	ff d6                	call   *%esi
			putch('X', putdat);
  800641:	83 c4 08             	add    $0x8,%esp
  800644:	53                   	push   %ebx
  800645:	6a 58                	push   $0x58
  800647:	ff d6                	call   *%esi
			break;
  800649:	83 c4 10             	add    $0x10,%esp
  80064c:	eb 42                	jmp    800690 <vprintfmt+0x36f>
			putch('0', putdat);
  80064e:	83 ec 08             	sub    $0x8,%esp
  800651:	53                   	push   %ebx
  800652:	6a 30                	push   $0x30
  800654:	ff d6                	call   *%esi
			putch('x', putdat);
  800656:	83 c4 08             	add    $0x8,%esp
  800659:	53                   	push   %ebx
  80065a:	6a 78                	push   $0x78
  80065c:	ff d6                	call   *%esi
			num = (unsigned long long)
  80065e:	8b 45 14             	mov    0x14(%ebp),%eax
  800661:	8b 10                	mov    (%eax),%edx
  800663:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800668:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  80066b:	8d 40 04             	lea    0x4(%eax),%eax
  80066e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800671:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  800676:	83 ec 0c             	sub    $0xc,%esp
  800679:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  80067d:	57                   	push   %edi
  80067e:	ff 75 d4             	pushl  -0x2c(%ebp)
  800681:	50                   	push   %eax
  800682:	51                   	push   %ecx
  800683:	52                   	push   %edx
  800684:	89 da                	mov    %ebx,%edx
  800686:	89 f0                	mov    %esi,%eax
  800688:	e8 b6 fb ff ff       	call   800243 <printnum>
			break;
  80068d:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  800690:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800693:	47                   	inc    %edi
  800694:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800698:	83 f8 25             	cmp    $0x25,%eax
  80069b:	0f 84 97 fc ff ff    	je     800338 <vprintfmt+0x17>
			if (ch == '\0')
  8006a1:	85 c0                	test   %eax,%eax
  8006a3:	0f 84 89 00 00 00    	je     800732 <vprintfmt+0x411>
			putch(ch, putdat);
  8006a9:	83 ec 08             	sub    $0x8,%esp
  8006ac:	53                   	push   %ebx
  8006ad:	50                   	push   %eax
  8006ae:	ff d6                	call   *%esi
  8006b0:	83 c4 10             	add    $0x10,%esp
  8006b3:	eb de                	jmp    800693 <vprintfmt+0x372>
	if (lflag >= 2)
  8006b5:	83 f9 01             	cmp    $0x1,%ecx
  8006b8:	7f 1b                	jg     8006d5 <vprintfmt+0x3b4>
	else if (lflag)
  8006ba:	85 c9                	test   %ecx,%ecx
  8006bc:	74 2c                	je     8006ea <vprintfmt+0x3c9>
		return va_arg(*ap, unsigned long);
  8006be:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c1:	8b 10                	mov    (%eax),%edx
  8006c3:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006c8:	8d 40 04             	lea    0x4(%eax),%eax
  8006cb:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006ce:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  8006d3:	eb a1                	jmp    800676 <vprintfmt+0x355>
		return va_arg(*ap, unsigned long long);
  8006d5:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d8:	8b 10                	mov    (%eax),%edx
  8006da:	8b 48 04             	mov    0x4(%eax),%ecx
  8006dd:	8d 40 08             	lea    0x8(%eax),%eax
  8006e0:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006e3:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  8006e8:	eb 8c                	jmp    800676 <vprintfmt+0x355>
		return va_arg(*ap, unsigned int);
  8006ea:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ed:	8b 10                	mov    (%eax),%edx
  8006ef:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006f4:	8d 40 04             	lea    0x4(%eax),%eax
  8006f7:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006fa:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  8006ff:	e9 72 ff ff ff       	jmp    800676 <vprintfmt+0x355>
			putch(ch, putdat);
  800704:	83 ec 08             	sub    $0x8,%esp
  800707:	53                   	push   %ebx
  800708:	6a 25                	push   $0x25
  80070a:	ff d6                	call   *%esi
			break;
  80070c:	83 c4 10             	add    $0x10,%esp
  80070f:	e9 7c ff ff ff       	jmp    800690 <vprintfmt+0x36f>
			putch('%', putdat);
  800714:	83 ec 08             	sub    $0x8,%esp
  800717:	53                   	push   %ebx
  800718:	6a 25                	push   $0x25
  80071a:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80071c:	83 c4 10             	add    $0x10,%esp
  80071f:	89 f8                	mov    %edi,%eax
  800721:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800725:	74 03                	je     80072a <vprintfmt+0x409>
  800727:	48                   	dec    %eax
  800728:	eb f7                	jmp    800721 <vprintfmt+0x400>
  80072a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80072d:	e9 5e ff ff ff       	jmp    800690 <vprintfmt+0x36f>
}
  800732:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800735:	5b                   	pop    %ebx
  800736:	5e                   	pop    %esi
  800737:	5f                   	pop    %edi
  800738:	5d                   	pop    %ebp
  800739:	c3                   	ret    

0080073a <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80073a:	55                   	push   %ebp
  80073b:	89 e5                	mov    %esp,%ebp
  80073d:	83 ec 18             	sub    $0x18,%esp
  800740:	8b 45 08             	mov    0x8(%ebp),%eax
  800743:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800746:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800749:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80074d:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800750:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800757:	85 c0                	test   %eax,%eax
  800759:	74 26                	je     800781 <vsnprintf+0x47>
  80075b:	85 d2                	test   %edx,%edx
  80075d:	7e 29                	jle    800788 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80075f:	ff 75 14             	pushl  0x14(%ebp)
  800762:	ff 75 10             	pushl  0x10(%ebp)
  800765:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800768:	50                   	push   %eax
  800769:	68 e8 02 80 00       	push   $0x8002e8
  80076e:	e8 ae fb ff ff       	call   800321 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800773:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800776:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800779:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80077c:	83 c4 10             	add    $0x10,%esp
}
  80077f:	c9                   	leave  
  800780:	c3                   	ret    
		return -E_INVAL;
  800781:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800786:	eb f7                	jmp    80077f <vsnprintf+0x45>
  800788:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80078d:	eb f0                	jmp    80077f <vsnprintf+0x45>

0080078f <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80078f:	55                   	push   %ebp
  800790:	89 e5                	mov    %esp,%ebp
  800792:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800795:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800798:	50                   	push   %eax
  800799:	ff 75 10             	pushl  0x10(%ebp)
  80079c:	ff 75 0c             	pushl  0xc(%ebp)
  80079f:	ff 75 08             	pushl  0x8(%ebp)
  8007a2:	e8 93 ff ff ff       	call   80073a <vsnprintf>
	va_end(ap);

	return rc;
}
  8007a7:	c9                   	leave  
  8007a8:	c3                   	ret    

008007a9 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007a9:	55                   	push   %ebp
  8007aa:	89 e5                	mov    %esp,%ebp
  8007ac:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007af:	b8 00 00 00 00       	mov    $0x0,%eax
  8007b4:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007b8:	74 03                	je     8007bd <strlen+0x14>
		n++;
  8007ba:	40                   	inc    %eax
  8007bb:	eb f7                	jmp    8007b4 <strlen+0xb>
	return n;
}
  8007bd:	5d                   	pop    %ebp
  8007be:	c3                   	ret    

008007bf <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007bf:	55                   	push   %ebp
  8007c0:	89 e5                	mov    %esp,%ebp
  8007c2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007c5:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007c8:	b8 00 00 00 00       	mov    $0x0,%eax
  8007cd:	39 d0                	cmp    %edx,%eax
  8007cf:	74 0b                	je     8007dc <strnlen+0x1d>
  8007d1:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007d5:	74 03                	je     8007da <strnlen+0x1b>
		n++;
  8007d7:	40                   	inc    %eax
  8007d8:	eb f3                	jmp    8007cd <strnlen+0xe>
  8007da:	89 c2                	mov    %eax,%edx
	return n;
}
  8007dc:	89 d0                	mov    %edx,%eax
  8007de:	5d                   	pop    %ebp
  8007df:	c3                   	ret    

008007e0 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007e0:	55                   	push   %ebp
  8007e1:	89 e5                	mov    %esp,%ebp
  8007e3:	53                   	push   %ebx
  8007e4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007e7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007ea:	b8 00 00 00 00       	mov    $0x0,%eax
  8007ef:	8a 14 03             	mov    (%ebx,%eax,1),%dl
  8007f2:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8007f5:	40                   	inc    %eax
  8007f6:	84 d2                	test   %dl,%dl
  8007f8:	75 f5                	jne    8007ef <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8007fa:	89 c8                	mov    %ecx,%eax
  8007fc:	5b                   	pop    %ebx
  8007fd:	5d                   	pop    %ebp
  8007fe:	c3                   	ret    

008007ff <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007ff:	55                   	push   %ebp
  800800:	89 e5                	mov    %esp,%ebp
  800802:	53                   	push   %ebx
  800803:	83 ec 10             	sub    $0x10,%esp
  800806:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800809:	53                   	push   %ebx
  80080a:	e8 9a ff ff ff       	call   8007a9 <strlen>
  80080f:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800812:	ff 75 0c             	pushl  0xc(%ebp)
  800815:	01 d8                	add    %ebx,%eax
  800817:	50                   	push   %eax
  800818:	e8 c3 ff ff ff       	call   8007e0 <strcpy>
	return dst;
}
  80081d:	89 d8                	mov    %ebx,%eax
  80081f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800822:	c9                   	leave  
  800823:	c3                   	ret    

00800824 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800824:	55                   	push   %ebp
  800825:	89 e5                	mov    %esp,%ebp
  800827:	53                   	push   %ebx
  800828:	8b 55 0c             	mov    0xc(%ebp),%edx
  80082b:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80082e:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800831:	8b 45 08             	mov    0x8(%ebp),%eax
  800834:	39 d8                	cmp    %ebx,%eax
  800836:	74 0e                	je     800846 <strncpy+0x22>
		*dst++ = *src;
  800838:	40                   	inc    %eax
  800839:	8a 0a                	mov    (%edx),%cl
  80083b:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80083e:	80 f9 01             	cmp    $0x1,%cl
  800841:	83 da ff             	sbb    $0xffffffff,%edx
  800844:	eb ee                	jmp    800834 <strncpy+0x10>
	}
	return ret;
}
  800846:	8b 45 08             	mov    0x8(%ebp),%eax
  800849:	5b                   	pop    %ebx
  80084a:	5d                   	pop    %ebp
  80084b:	c3                   	ret    

0080084c <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80084c:	55                   	push   %ebp
  80084d:	89 e5                	mov    %esp,%ebp
  80084f:	56                   	push   %esi
  800850:	53                   	push   %ebx
  800851:	8b 75 08             	mov    0x8(%ebp),%esi
  800854:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800857:	8b 45 10             	mov    0x10(%ebp),%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80085a:	85 c0                	test   %eax,%eax
  80085c:	74 22                	je     800880 <strlcpy+0x34>
  80085e:	8d 44 06 ff          	lea    -0x1(%esi,%eax,1),%eax
  800862:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  800864:	39 c2                	cmp    %eax,%edx
  800866:	74 0f                	je     800877 <strlcpy+0x2b>
  800868:	8a 19                	mov    (%ecx),%bl
  80086a:	84 db                	test   %bl,%bl
  80086c:	74 07                	je     800875 <strlcpy+0x29>
			*dst++ = *src++;
  80086e:	41                   	inc    %ecx
  80086f:	42                   	inc    %edx
  800870:	88 5a ff             	mov    %bl,-0x1(%edx)
  800873:	eb ef                	jmp    800864 <strlcpy+0x18>
  800875:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800877:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80087a:	29 f0                	sub    %esi,%eax
}
  80087c:	5b                   	pop    %ebx
  80087d:	5e                   	pop    %esi
  80087e:	5d                   	pop    %ebp
  80087f:	c3                   	ret    
  800880:	89 f0                	mov    %esi,%eax
  800882:	eb f6                	jmp    80087a <strlcpy+0x2e>

00800884 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800884:	55                   	push   %ebp
  800885:	89 e5                	mov    %esp,%ebp
  800887:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80088a:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80088d:	8a 01                	mov    (%ecx),%al
  80088f:	84 c0                	test   %al,%al
  800891:	74 08                	je     80089b <strcmp+0x17>
  800893:	3a 02                	cmp    (%edx),%al
  800895:	75 04                	jne    80089b <strcmp+0x17>
		p++, q++;
  800897:	41                   	inc    %ecx
  800898:	42                   	inc    %edx
  800899:	eb f2                	jmp    80088d <strcmp+0x9>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80089b:	0f b6 c0             	movzbl %al,%eax
  80089e:	0f b6 12             	movzbl (%edx),%edx
  8008a1:	29 d0                	sub    %edx,%eax
}
  8008a3:	5d                   	pop    %ebp
  8008a4:	c3                   	ret    

008008a5 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008a5:	55                   	push   %ebp
  8008a6:	89 e5                	mov    %esp,%ebp
  8008a8:	53                   	push   %ebx
  8008a9:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ac:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008af:	89 c3                	mov    %eax,%ebx
  8008b1:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008b4:	eb 02                	jmp    8008b8 <strncmp+0x13>
		n--, p++, q++;
  8008b6:	40                   	inc    %eax
  8008b7:	42                   	inc    %edx
	while (n > 0 && *p && *p == *q)
  8008b8:	39 d8                	cmp    %ebx,%eax
  8008ba:	74 15                	je     8008d1 <strncmp+0x2c>
  8008bc:	8a 08                	mov    (%eax),%cl
  8008be:	84 c9                	test   %cl,%cl
  8008c0:	74 04                	je     8008c6 <strncmp+0x21>
  8008c2:	3a 0a                	cmp    (%edx),%cl
  8008c4:	74 f0                	je     8008b6 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008c6:	0f b6 00             	movzbl (%eax),%eax
  8008c9:	0f b6 12             	movzbl (%edx),%edx
  8008cc:	29 d0                	sub    %edx,%eax
}
  8008ce:	5b                   	pop    %ebx
  8008cf:	5d                   	pop    %ebp
  8008d0:	c3                   	ret    
		return 0;
  8008d1:	b8 00 00 00 00       	mov    $0x0,%eax
  8008d6:	eb f6                	jmp    8008ce <strncmp+0x29>

008008d8 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008d8:	55                   	push   %ebp
  8008d9:	89 e5                	mov    %esp,%ebp
  8008db:	8b 45 08             	mov    0x8(%ebp),%eax
  8008de:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8008e1:	8a 10                	mov    (%eax),%dl
  8008e3:	84 d2                	test   %dl,%dl
  8008e5:	74 07                	je     8008ee <strchr+0x16>
		if (*s == c)
  8008e7:	38 ca                	cmp    %cl,%dl
  8008e9:	74 08                	je     8008f3 <strchr+0x1b>
	for (; *s; s++)
  8008eb:	40                   	inc    %eax
  8008ec:	eb f3                	jmp    8008e1 <strchr+0x9>
			return (char *) s;
	return 0;
  8008ee:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008f3:	5d                   	pop    %ebp
  8008f4:	c3                   	ret    

008008f5 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008f5:	55                   	push   %ebp
  8008f6:	89 e5                	mov    %esp,%ebp
  8008f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8008fb:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8008fe:	8a 10                	mov    (%eax),%dl
  800900:	84 d2                	test   %dl,%dl
  800902:	74 07                	je     80090b <strfind+0x16>
		if (*s == c)
  800904:	38 ca                	cmp    %cl,%dl
  800906:	74 03                	je     80090b <strfind+0x16>
	for (; *s; s++)
  800908:	40                   	inc    %eax
  800909:	eb f3                	jmp    8008fe <strfind+0x9>
			break;
	return (char *) s;
}
  80090b:	5d                   	pop    %ebp
  80090c:	c3                   	ret    

0080090d <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80090d:	55                   	push   %ebp
  80090e:	89 e5                	mov    %esp,%ebp
  800910:	57                   	push   %edi
  800911:	56                   	push   %esi
  800912:	53                   	push   %ebx
  800913:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800916:	85 c9                	test   %ecx,%ecx
  800918:	74 36                	je     800950 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80091a:	89 c8                	mov    %ecx,%eax
  80091c:	0b 45 08             	or     0x8(%ebp),%eax
  80091f:	a8 03                	test   $0x3,%al
  800921:	75 24                	jne    800947 <memset+0x3a>
		c &= 0xFF;
  800923:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800927:	89 d3                	mov    %edx,%ebx
  800929:	c1 e3 08             	shl    $0x8,%ebx
  80092c:	89 d0                	mov    %edx,%eax
  80092e:	c1 e0 18             	shl    $0x18,%eax
  800931:	89 d6                	mov    %edx,%esi
  800933:	c1 e6 10             	shl    $0x10,%esi
  800936:	09 f0                	or     %esi,%eax
  800938:	09 d0                	or     %edx,%eax
  80093a:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80093c:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  80093f:	8b 7d 08             	mov    0x8(%ebp),%edi
  800942:	fc                   	cld    
  800943:	f3 ab                	rep stos %eax,%es:(%edi)
  800945:	eb 09                	jmp    800950 <memset+0x43>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800947:	8b 7d 08             	mov    0x8(%ebp),%edi
  80094a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80094d:	fc                   	cld    
  80094e:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800950:	8b 45 08             	mov    0x8(%ebp),%eax
  800953:	5b                   	pop    %ebx
  800954:	5e                   	pop    %esi
  800955:	5f                   	pop    %edi
  800956:	5d                   	pop    %ebp
  800957:	c3                   	ret    

00800958 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800958:	55                   	push   %ebp
  800959:	89 e5                	mov    %esp,%ebp
  80095b:	57                   	push   %edi
  80095c:	56                   	push   %esi
  80095d:	8b 45 08             	mov    0x8(%ebp),%eax
  800960:	8b 75 0c             	mov    0xc(%ebp),%esi
  800963:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800966:	39 c6                	cmp    %eax,%esi
  800968:	73 30                	jae    80099a <memmove+0x42>
  80096a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80096d:	39 c2                	cmp    %eax,%edx
  80096f:	76 29                	jbe    80099a <memmove+0x42>
		s += n;
		d += n;
  800971:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800974:	89 fe                	mov    %edi,%esi
  800976:	09 ce                	or     %ecx,%esi
  800978:	09 d6                	or     %edx,%esi
  80097a:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800980:	75 0e                	jne    800990 <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800982:	83 ef 04             	sub    $0x4,%edi
  800985:	8d 72 fc             	lea    -0x4(%edx),%esi
  800988:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  80098b:	fd                   	std    
  80098c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80098e:	eb 07                	jmp    800997 <memmove+0x3f>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800990:	4f                   	dec    %edi
  800991:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800994:	fd                   	std    
  800995:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800997:	fc                   	cld    
  800998:	eb 1a                	jmp    8009b4 <memmove+0x5c>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80099a:	89 c2                	mov    %eax,%edx
  80099c:	09 ca                	or     %ecx,%edx
  80099e:	09 f2                	or     %esi,%edx
  8009a0:	f6 c2 03             	test   $0x3,%dl
  8009a3:	75 0a                	jne    8009af <memmove+0x57>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009a5:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  8009a8:	89 c7                	mov    %eax,%edi
  8009aa:	fc                   	cld    
  8009ab:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009ad:	eb 05                	jmp    8009b4 <memmove+0x5c>
		else
			asm volatile("cld; rep movsb\n"
  8009af:	89 c7                	mov    %eax,%edi
  8009b1:	fc                   	cld    
  8009b2:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009b4:	5e                   	pop    %esi
  8009b5:	5f                   	pop    %edi
  8009b6:	5d                   	pop    %ebp
  8009b7:	c3                   	ret    

008009b8 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009b8:	55                   	push   %ebp
  8009b9:	89 e5                	mov    %esp,%ebp
  8009bb:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8009be:	ff 75 10             	pushl  0x10(%ebp)
  8009c1:	ff 75 0c             	pushl  0xc(%ebp)
  8009c4:	ff 75 08             	pushl  0x8(%ebp)
  8009c7:	e8 8c ff ff ff       	call   800958 <memmove>
}
  8009cc:	c9                   	leave  
  8009cd:	c3                   	ret    

008009ce <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009ce:	55                   	push   %ebp
  8009cf:	89 e5                	mov    %esp,%ebp
  8009d1:	56                   	push   %esi
  8009d2:	53                   	push   %ebx
  8009d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009d9:	89 c6                	mov    %eax,%esi
  8009db:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009de:	39 f0                	cmp    %esi,%eax
  8009e0:	74 16                	je     8009f8 <memcmp+0x2a>
		if (*s1 != *s2)
  8009e2:	8a 08                	mov    (%eax),%cl
  8009e4:	8a 1a                	mov    (%edx),%bl
  8009e6:	38 d9                	cmp    %bl,%cl
  8009e8:	75 04                	jne    8009ee <memcmp+0x20>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  8009ea:	40                   	inc    %eax
  8009eb:	42                   	inc    %edx
  8009ec:	eb f0                	jmp    8009de <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  8009ee:	0f b6 c1             	movzbl %cl,%eax
  8009f1:	0f b6 db             	movzbl %bl,%ebx
  8009f4:	29 d8                	sub    %ebx,%eax
  8009f6:	eb 05                	jmp    8009fd <memcmp+0x2f>
	}

	return 0;
  8009f8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009fd:	5b                   	pop    %ebx
  8009fe:	5e                   	pop    %esi
  8009ff:	5d                   	pop    %ebp
  800a00:	c3                   	ret    

00800a01 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a01:	55                   	push   %ebp
  800a02:	89 e5                	mov    %esp,%ebp
  800a04:	8b 45 08             	mov    0x8(%ebp),%eax
  800a07:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a0a:	89 c2                	mov    %eax,%edx
  800a0c:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a0f:	39 d0                	cmp    %edx,%eax
  800a11:	73 07                	jae    800a1a <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a13:	38 08                	cmp    %cl,(%eax)
  800a15:	74 03                	je     800a1a <memfind+0x19>
	for (; s < ends; s++)
  800a17:	40                   	inc    %eax
  800a18:	eb f5                	jmp    800a0f <memfind+0xe>
			break;
	return (void *) s;
}
  800a1a:	5d                   	pop    %ebp
  800a1b:	c3                   	ret    

00800a1c <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a1c:	55                   	push   %ebp
  800a1d:	89 e5                	mov    %esp,%ebp
  800a1f:	57                   	push   %edi
  800a20:	56                   	push   %esi
  800a21:	53                   	push   %ebx
  800a22:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a25:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a28:	eb 01                	jmp    800a2b <strtol+0xf>
		s++;
  800a2a:	41                   	inc    %ecx
	while (*s == ' ' || *s == '\t')
  800a2b:	8a 01                	mov    (%ecx),%al
  800a2d:	3c 20                	cmp    $0x20,%al
  800a2f:	74 f9                	je     800a2a <strtol+0xe>
  800a31:	3c 09                	cmp    $0x9,%al
  800a33:	74 f5                	je     800a2a <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800a35:	3c 2b                	cmp    $0x2b,%al
  800a37:	74 24                	je     800a5d <strtol+0x41>
		s++;
	else if (*s == '-')
  800a39:	3c 2d                	cmp    $0x2d,%al
  800a3b:	74 28                	je     800a65 <strtol+0x49>
	int neg = 0;
  800a3d:	bf 00 00 00 00       	mov    $0x0,%edi
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a42:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a48:	75 09                	jne    800a53 <strtol+0x37>
  800a4a:	80 39 30             	cmpb   $0x30,(%ecx)
  800a4d:	74 1e                	je     800a6d <strtol+0x51>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a4f:	85 db                	test   %ebx,%ebx
  800a51:	74 36                	je     800a89 <strtol+0x6d>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a53:	b8 00 00 00 00       	mov    $0x0,%eax
  800a58:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800a5b:	eb 45                	jmp    800aa2 <strtol+0x86>
		s++;
  800a5d:	41                   	inc    %ecx
	int neg = 0;
  800a5e:	bf 00 00 00 00       	mov    $0x0,%edi
  800a63:	eb dd                	jmp    800a42 <strtol+0x26>
		s++, neg = 1;
  800a65:	41                   	inc    %ecx
  800a66:	bf 01 00 00 00       	mov    $0x1,%edi
  800a6b:	eb d5                	jmp    800a42 <strtol+0x26>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a6d:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a71:	74 0c                	je     800a7f <strtol+0x63>
	else if (base == 0 && s[0] == '0')
  800a73:	85 db                	test   %ebx,%ebx
  800a75:	75 dc                	jne    800a53 <strtol+0x37>
		s++, base = 8;
  800a77:	41                   	inc    %ecx
  800a78:	bb 08 00 00 00       	mov    $0x8,%ebx
  800a7d:	eb d4                	jmp    800a53 <strtol+0x37>
		s += 2, base = 16;
  800a7f:	83 c1 02             	add    $0x2,%ecx
  800a82:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a87:	eb ca                	jmp    800a53 <strtol+0x37>
		base = 10;
  800a89:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800a8e:	eb c3                	jmp    800a53 <strtol+0x37>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800a90:	0f be d2             	movsbl %dl,%edx
  800a93:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800a96:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a99:	7d 37                	jge    800ad2 <strtol+0xb6>
			break;
		s++, val = (val * base) + dig;
  800a9b:	41                   	inc    %ecx
  800a9c:	0f af 45 10          	imul   0x10(%ebp),%eax
  800aa0:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800aa2:	8a 11                	mov    (%ecx),%dl
  800aa4:	8d 72 d0             	lea    -0x30(%edx),%esi
  800aa7:	89 f3                	mov    %esi,%ebx
  800aa9:	80 fb 09             	cmp    $0x9,%bl
  800aac:	76 e2                	jbe    800a90 <strtol+0x74>
		else if (*s >= 'a' && *s <= 'z')
  800aae:	8d 72 9f             	lea    -0x61(%edx),%esi
  800ab1:	89 f3                	mov    %esi,%ebx
  800ab3:	80 fb 19             	cmp    $0x19,%bl
  800ab6:	77 08                	ja     800ac0 <strtol+0xa4>
			dig = *s - 'a' + 10;
  800ab8:	0f be d2             	movsbl %dl,%edx
  800abb:	83 ea 57             	sub    $0x57,%edx
  800abe:	eb d6                	jmp    800a96 <strtol+0x7a>
		else if (*s >= 'A' && *s <= 'Z')
  800ac0:	8d 72 bf             	lea    -0x41(%edx),%esi
  800ac3:	89 f3                	mov    %esi,%ebx
  800ac5:	80 fb 19             	cmp    $0x19,%bl
  800ac8:	77 08                	ja     800ad2 <strtol+0xb6>
			dig = *s - 'A' + 10;
  800aca:	0f be d2             	movsbl %dl,%edx
  800acd:	83 ea 37             	sub    $0x37,%edx
  800ad0:	eb c4                	jmp    800a96 <strtol+0x7a>
		// we don't properly detect overflow!
	}

	if (endptr)
  800ad2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ad6:	74 05                	je     800add <strtol+0xc1>
		*endptr = (char *) s;
  800ad8:	8b 75 0c             	mov    0xc(%ebp),%esi
  800adb:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800add:	85 ff                	test   %edi,%edi
  800adf:	74 02                	je     800ae3 <strtol+0xc7>
  800ae1:	f7 d8                	neg    %eax
}
  800ae3:	5b                   	pop    %ebx
  800ae4:	5e                   	pop    %esi
  800ae5:	5f                   	pop    %edi
  800ae6:	5d                   	pop    %ebp
  800ae7:	c3                   	ret    

00800ae8 <__udivdi3>:
  800ae8:	55                   	push   %ebp
  800ae9:	57                   	push   %edi
  800aea:	56                   	push   %esi
  800aeb:	53                   	push   %ebx
  800aec:	83 ec 1c             	sub    $0x1c,%esp
  800aef:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800af3:	8b 74 24 34          	mov    0x34(%esp),%esi
  800af7:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800afb:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800aff:	85 d2                	test   %edx,%edx
  800b01:	75 19                	jne    800b1c <__udivdi3+0x34>
  800b03:	39 f7                	cmp    %esi,%edi
  800b05:	76 45                	jbe    800b4c <__udivdi3+0x64>
  800b07:	89 e8                	mov    %ebp,%eax
  800b09:	89 f2                	mov    %esi,%edx
  800b0b:	f7 f7                	div    %edi
  800b0d:	31 db                	xor    %ebx,%ebx
  800b0f:	89 da                	mov    %ebx,%edx
  800b11:	83 c4 1c             	add    $0x1c,%esp
  800b14:	5b                   	pop    %ebx
  800b15:	5e                   	pop    %esi
  800b16:	5f                   	pop    %edi
  800b17:	5d                   	pop    %ebp
  800b18:	c3                   	ret    
  800b19:	8d 76 00             	lea    0x0(%esi),%esi
  800b1c:	39 f2                	cmp    %esi,%edx
  800b1e:	76 10                	jbe    800b30 <__udivdi3+0x48>
  800b20:	31 db                	xor    %ebx,%ebx
  800b22:	31 c0                	xor    %eax,%eax
  800b24:	89 da                	mov    %ebx,%edx
  800b26:	83 c4 1c             	add    $0x1c,%esp
  800b29:	5b                   	pop    %ebx
  800b2a:	5e                   	pop    %esi
  800b2b:	5f                   	pop    %edi
  800b2c:	5d                   	pop    %ebp
  800b2d:	c3                   	ret    
  800b2e:	66 90                	xchg   %ax,%ax
  800b30:	0f bd da             	bsr    %edx,%ebx
  800b33:	83 f3 1f             	xor    $0x1f,%ebx
  800b36:	75 3c                	jne    800b74 <__udivdi3+0x8c>
  800b38:	39 f2                	cmp    %esi,%edx
  800b3a:	72 08                	jb     800b44 <__udivdi3+0x5c>
  800b3c:	39 ef                	cmp    %ebp,%edi
  800b3e:	0f 87 9c 00 00 00    	ja     800be0 <__udivdi3+0xf8>
  800b44:	b8 01 00 00 00       	mov    $0x1,%eax
  800b49:	eb d9                	jmp    800b24 <__udivdi3+0x3c>
  800b4b:	90                   	nop
  800b4c:	89 f9                	mov    %edi,%ecx
  800b4e:	85 ff                	test   %edi,%edi
  800b50:	75 0b                	jne    800b5d <__udivdi3+0x75>
  800b52:	b8 01 00 00 00       	mov    $0x1,%eax
  800b57:	31 d2                	xor    %edx,%edx
  800b59:	f7 f7                	div    %edi
  800b5b:	89 c1                	mov    %eax,%ecx
  800b5d:	31 d2                	xor    %edx,%edx
  800b5f:	89 f0                	mov    %esi,%eax
  800b61:	f7 f1                	div    %ecx
  800b63:	89 c3                	mov    %eax,%ebx
  800b65:	89 e8                	mov    %ebp,%eax
  800b67:	f7 f1                	div    %ecx
  800b69:	89 da                	mov    %ebx,%edx
  800b6b:	83 c4 1c             	add    $0x1c,%esp
  800b6e:	5b                   	pop    %ebx
  800b6f:	5e                   	pop    %esi
  800b70:	5f                   	pop    %edi
  800b71:	5d                   	pop    %ebp
  800b72:	c3                   	ret    
  800b73:	90                   	nop
  800b74:	b8 20 00 00 00       	mov    $0x20,%eax
  800b79:	29 d8                	sub    %ebx,%eax
  800b7b:	88 d9                	mov    %bl,%cl
  800b7d:	d3 e2                	shl    %cl,%edx
  800b7f:	89 54 24 08          	mov    %edx,0x8(%esp)
  800b83:	89 fa                	mov    %edi,%edx
  800b85:	88 c1                	mov    %al,%cl
  800b87:	d3 ea                	shr    %cl,%edx
  800b89:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800b8d:	09 d1                	or     %edx,%ecx
  800b8f:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800b93:	88 d9                	mov    %bl,%cl
  800b95:	d3 e7                	shl    %cl,%edi
  800b97:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800b9b:	89 f7                	mov    %esi,%edi
  800b9d:	88 c1                	mov    %al,%cl
  800b9f:	d3 ef                	shr    %cl,%edi
  800ba1:	88 d9                	mov    %bl,%cl
  800ba3:	d3 e6                	shl    %cl,%esi
  800ba5:	89 ea                	mov    %ebp,%edx
  800ba7:	88 c1                	mov    %al,%cl
  800ba9:	d3 ea                	shr    %cl,%edx
  800bab:	09 d6                	or     %edx,%esi
  800bad:	89 f0                	mov    %esi,%eax
  800baf:	89 fa                	mov    %edi,%edx
  800bb1:	f7 74 24 08          	divl   0x8(%esp)
  800bb5:	89 d7                	mov    %edx,%edi
  800bb7:	89 c6                	mov    %eax,%esi
  800bb9:	f7 64 24 0c          	mull   0xc(%esp)
  800bbd:	39 d7                	cmp    %edx,%edi
  800bbf:	72 13                	jb     800bd4 <__udivdi3+0xec>
  800bc1:	74 09                	je     800bcc <__udivdi3+0xe4>
  800bc3:	89 f0                	mov    %esi,%eax
  800bc5:	31 db                	xor    %ebx,%ebx
  800bc7:	e9 58 ff ff ff       	jmp    800b24 <__udivdi3+0x3c>
  800bcc:	88 d9                	mov    %bl,%cl
  800bce:	d3 e5                	shl    %cl,%ebp
  800bd0:	39 c5                	cmp    %eax,%ebp
  800bd2:	73 ef                	jae    800bc3 <__udivdi3+0xdb>
  800bd4:	8d 46 ff             	lea    -0x1(%esi),%eax
  800bd7:	31 db                	xor    %ebx,%ebx
  800bd9:	e9 46 ff ff ff       	jmp    800b24 <__udivdi3+0x3c>
  800bde:	66 90                	xchg   %ax,%ax
  800be0:	31 c0                	xor    %eax,%eax
  800be2:	e9 3d ff ff ff       	jmp    800b24 <__udivdi3+0x3c>
  800be7:	90                   	nop

00800be8 <__umoddi3>:
  800be8:	55                   	push   %ebp
  800be9:	57                   	push   %edi
  800bea:	56                   	push   %esi
  800beb:	53                   	push   %ebx
  800bec:	83 ec 1c             	sub    $0x1c,%esp
  800bef:	8b 74 24 30          	mov    0x30(%esp),%esi
  800bf3:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800bf7:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800bfb:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  800bff:	85 c0                	test   %eax,%eax
  800c01:	75 19                	jne    800c1c <__umoddi3+0x34>
  800c03:	39 df                	cmp    %ebx,%edi
  800c05:	76 51                	jbe    800c58 <__umoddi3+0x70>
  800c07:	89 f0                	mov    %esi,%eax
  800c09:	89 da                	mov    %ebx,%edx
  800c0b:	f7 f7                	div    %edi
  800c0d:	89 d0                	mov    %edx,%eax
  800c0f:	31 d2                	xor    %edx,%edx
  800c11:	83 c4 1c             	add    $0x1c,%esp
  800c14:	5b                   	pop    %ebx
  800c15:	5e                   	pop    %esi
  800c16:	5f                   	pop    %edi
  800c17:	5d                   	pop    %ebp
  800c18:	c3                   	ret    
  800c19:	8d 76 00             	lea    0x0(%esi),%esi
  800c1c:	89 f2                	mov    %esi,%edx
  800c1e:	39 d8                	cmp    %ebx,%eax
  800c20:	76 0e                	jbe    800c30 <__umoddi3+0x48>
  800c22:	89 f0                	mov    %esi,%eax
  800c24:	89 da                	mov    %ebx,%edx
  800c26:	83 c4 1c             	add    $0x1c,%esp
  800c29:	5b                   	pop    %ebx
  800c2a:	5e                   	pop    %esi
  800c2b:	5f                   	pop    %edi
  800c2c:	5d                   	pop    %ebp
  800c2d:	c3                   	ret    
  800c2e:	66 90                	xchg   %ax,%ax
  800c30:	0f bd e8             	bsr    %eax,%ebp
  800c33:	83 f5 1f             	xor    $0x1f,%ebp
  800c36:	75 44                	jne    800c7c <__umoddi3+0x94>
  800c38:	39 d8                	cmp    %ebx,%eax
  800c3a:	72 06                	jb     800c42 <__umoddi3+0x5a>
  800c3c:	89 d9                	mov    %ebx,%ecx
  800c3e:	39 f7                	cmp    %esi,%edi
  800c40:	77 08                	ja     800c4a <__umoddi3+0x62>
  800c42:	29 fe                	sub    %edi,%esi
  800c44:	19 c3                	sbb    %eax,%ebx
  800c46:	89 f2                	mov    %esi,%edx
  800c48:	89 d9                	mov    %ebx,%ecx
  800c4a:	89 d0                	mov    %edx,%eax
  800c4c:	89 ca                	mov    %ecx,%edx
  800c4e:	83 c4 1c             	add    $0x1c,%esp
  800c51:	5b                   	pop    %ebx
  800c52:	5e                   	pop    %esi
  800c53:	5f                   	pop    %edi
  800c54:	5d                   	pop    %ebp
  800c55:	c3                   	ret    
  800c56:	66 90                	xchg   %ax,%ax
  800c58:	89 fd                	mov    %edi,%ebp
  800c5a:	85 ff                	test   %edi,%edi
  800c5c:	75 0b                	jne    800c69 <__umoddi3+0x81>
  800c5e:	b8 01 00 00 00       	mov    $0x1,%eax
  800c63:	31 d2                	xor    %edx,%edx
  800c65:	f7 f7                	div    %edi
  800c67:	89 c5                	mov    %eax,%ebp
  800c69:	89 d8                	mov    %ebx,%eax
  800c6b:	31 d2                	xor    %edx,%edx
  800c6d:	f7 f5                	div    %ebp
  800c6f:	89 f0                	mov    %esi,%eax
  800c71:	f7 f5                	div    %ebp
  800c73:	89 d0                	mov    %edx,%eax
  800c75:	31 d2                	xor    %edx,%edx
  800c77:	eb 98                	jmp    800c11 <__umoddi3+0x29>
  800c79:	8d 76 00             	lea    0x0(%esi),%esi
  800c7c:	ba 20 00 00 00       	mov    $0x20,%edx
  800c81:	29 ea                	sub    %ebp,%edx
  800c83:	89 e9                	mov    %ebp,%ecx
  800c85:	d3 e0                	shl    %cl,%eax
  800c87:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c8b:	89 f8                	mov    %edi,%eax
  800c8d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800c91:	88 d1                	mov    %dl,%cl
  800c93:	d3 e8                	shr    %cl,%eax
  800c95:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800c99:	09 c1                	or     %eax,%ecx
  800c9b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800c9f:	89 e9                	mov    %ebp,%ecx
  800ca1:	d3 e7                	shl    %cl,%edi
  800ca3:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800ca7:	89 d8                	mov    %ebx,%eax
  800ca9:	8b 54 24 04          	mov    0x4(%esp),%edx
  800cad:	88 d1                	mov    %dl,%cl
  800caf:	d3 e8                	shr    %cl,%eax
  800cb1:	89 c7                	mov    %eax,%edi
  800cb3:	89 e9                	mov    %ebp,%ecx
  800cb5:	d3 e3                	shl    %cl,%ebx
  800cb7:	89 f0                	mov    %esi,%eax
  800cb9:	88 d1                	mov    %dl,%cl
  800cbb:	d3 e8                	shr    %cl,%eax
  800cbd:	09 d8                	or     %ebx,%eax
  800cbf:	89 e9                	mov    %ebp,%ecx
  800cc1:	d3 e6                	shl    %cl,%esi
  800cc3:	89 f3                	mov    %esi,%ebx
  800cc5:	89 fa                	mov    %edi,%edx
  800cc7:	f7 74 24 08          	divl   0x8(%esp)
  800ccb:	89 d1                	mov    %edx,%ecx
  800ccd:	f7 64 24 0c          	mull   0xc(%esp)
  800cd1:	89 c6                	mov    %eax,%esi
  800cd3:	89 d7                	mov    %edx,%edi
  800cd5:	39 d1                	cmp    %edx,%ecx
  800cd7:	72 27                	jb     800d00 <__umoddi3+0x118>
  800cd9:	74 21                	je     800cfc <__umoddi3+0x114>
  800cdb:	89 ca                	mov    %ecx,%edx
  800cdd:	29 f3                	sub    %esi,%ebx
  800cdf:	19 fa                	sbb    %edi,%edx
  800ce1:	89 d0                	mov    %edx,%eax
  800ce3:	8a 4c 24 04          	mov    0x4(%esp),%cl
  800ce7:	d3 e0                	shl    %cl,%eax
  800ce9:	89 e9                	mov    %ebp,%ecx
  800ceb:	d3 eb                	shr    %cl,%ebx
  800ced:	09 d8                	or     %ebx,%eax
  800cef:	d3 ea                	shr    %cl,%edx
  800cf1:	83 c4 1c             	add    $0x1c,%esp
  800cf4:	5b                   	pop    %ebx
  800cf5:	5e                   	pop    %esi
  800cf6:	5f                   	pop    %edi
  800cf7:	5d                   	pop    %ebp
  800cf8:	c3                   	ret    
  800cf9:	8d 76 00             	lea    0x0(%esi),%esi
  800cfc:	39 c3                	cmp    %eax,%ebx
  800cfe:	73 db                	jae    800cdb <__umoddi3+0xf3>
  800d00:	2b 44 24 0c          	sub    0xc(%esp),%eax
  800d04:	1b 54 24 08          	sbb    0x8(%esp),%edx
  800d08:	89 d7                	mov    %edx,%edi
  800d0a:	89 c6                	mov    %eax,%esi
  800d0c:	eb cd                	jmp    800cdb <__umoddi3+0xf3>
