
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
  800041:	57                   	push   %edi
  800042:	56                   	push   %esi
  800043:	53                   	push   %ebx
  800044:	83 ec 6c             	sub    $0x6c,%esp
  800047:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	struct Env curenv = envs[ENVX(sys_getenvid())];
  80004a:	e8 de 00 00 00       	call   80012d <sys_getenvid>
  80004f:	25 ff 03 00 00       	and    $0x3ff,%eax
  800054:	8d 34 00             	lea    (%eax,%eax,1),%esi
  800057:	01 c6                	add    %eax,%esi
  800059:	c1 e6 05             	shl    $0x5,%esi
  80005c:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  800062:	8d 7d 88             	lea    -0x78(%ebp),%edi
  800065:	b9 18 00 00 00       	mov    $0x18,%ecx
  80006a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	thisenv = &curenv;
  80006c:	8d 45 88             	lea    -0x78(%ebp),%eax
  80006f:	a3 04 10 80 00       	mov    %eax,0x801004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800074:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800078:	7e 07                	jle    800081 <libmain+0x43>
		binaryname = argv[0];
  80007a:	8b 03                	mov    (%ebx),%eax
  80007c:	a3 00 10 80 00       	mov    %eax,0x801000
	
	// call user main routine
	umain(argc, argv);
  800081:	83 ec 08             	sub    $0x8,%esp
  800084:	53                   	push   %ebx
  800085:	ff 75 08             	pushl  0x8(%ebp)
  800088:	e8 a6 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80008d:	e8 0b 00 00 00       	call   80009d <exit>
}
  800092:	83 c4 10             	add    $0x10,%esp
  800095:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800098:	5b                   	pop    %ebx
  800099:	5e                   	pop    %esi
  80009a:	5f                   	pop    %edi
  80009b:	5d                   	pop    %ebp
  80009c:	c3                   	ret    

0080009d <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80009d:	55                   	push   %ebp
  80009e:	89 e5                	mov    %esp,%ebp
  8000a0:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8000a3:	6a 00                	push   $0x0
  8000a5:	e8 42 00 00 00       	call   8000ec <sys_env_destroy>
}
  8000aa:	83 c4 10             	add    $0x10,%esp
  8000ad:	c9                   	leave  
  8000ae:	c3                   	ret    

008000af <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000af:	55                   	push   %ebp
  8000b0:	89 e5                	mov    %esp,%ebp
  8000b2:	57                   	push   %edi
  8000b3:	56                   	push   %esi
  8000b4:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000b5:	b8 00 00 00 00       	mov    $0x0,%eax
  8000ba:	8b 55 08             	mov    0x8(%ebp),%edx
  8000bd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000c0:	89 c3                	mov    %eax,%ebx
  8000c2:	89 c7                	mov    %eax,%edi
  8000c4:	89 c6                	mov    %eax,%esi
  8000c6:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000c8:	5b                   	pop    %ebx
  8000c9:	5e                   	pop    %esi
  8000ca:	5f                   	pop    %edi
  8000cb:	5d                   	pop    %ebp
  8000cc:	c3                   	ret    

008000cd <sys_cgetc>:

int
sys_cgetc(void)
{
  8000cd:	55                   	push   %ebp
  8000ce:	89 e5                	mov    %esp,%ebp
  8000d0:	57                   	push   %edi
  8000d1:	56                   	push   %esi
  8000d2:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000d3:	ba 00 00 00 00       	mov    $0x0,%edx
  8000d8:	b8 01 00 00 00       	mov    $0x1,%eax
  8000dd:	89 d1                	mov    %edx,%ecx
  8000df:	89 d3                	mov    %edx,%ebx
  8000e1:	89 d7                	mov    %edx,%edi
  8000e3:	89 d6                	mov    %edx,%esi
  8000e5:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000e7:	5b                   	pop    %ebx
  8000e8:	5e                   	pop    %esi
  8000e9:	5f                   	pop    %edi
  8000ea:	5d                   	pop    %ebp
  8000eb:	c3                   	ret    

008000ec <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000ec:	55                   	push   %ebp
  8000ed:	89 e5                	mov    %esp,%ebp
  8000ef:	57                   	push   %edi
  8000f0:	56                   	push   %esi
  8000f1:	53                   	push   %ebx
  8000f2:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8000f5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000fa:	8b 55 08             	mov    0x8(%ebp),%edx
  8000fd:	b8 03 00 00 00       	mov    $0x3,%eax
  800102:	89 cb                	mov    %ecx,%ebx
  800104:	89 cf                	mov    %ecx,%edi
  800106:	89 ce                	mov    %ecx,%esi
  800108:	cd 30                	int    $0x30
	if(check && ret > 0)
  80010a:	85 c0                	test   %eax,%eax
  80010c:	7f 08                	jg     800116 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80010e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800111:	5b                   	pop    %ebx
  800112:	5e                   	pop    %esi
  800113:	5f                   	pop    %edi
  800114:	5d                   	pop    %ebp
  800115:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800116:	83 ec 0c             	sub    $0xc,%esp
  800119:	50                   	push   %eax
  80011a:	6a 03                	push   $0x3
  80011c:	68 12 0d 80 00       	push   $0x800d12
  800121:	6a 23                	push   $0x23
  800123:	68 2f 0d 80 00       	push   $0x800d2f
  800128:	e8 1f 00 00 00       	call   80014c <_panic>

0080012d <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80012d:	55                   	push   %ebp
  80012e:	89 e5                	mov    %esp,%ebp
  800130:	57                   	push   %edi
  800131:	56                   	push   %esi
  800132:	53                   	push   %ebx
	asm volatile("int %1\n"
  800133:	ba 00 00 00 00       	mov    $0x0,%edx
  800138:	b8 02 00 00 00       	mov    $0x2,%eax
  80013d:	89 d1                	mov    %edx,%ecx
  80013f:	89 d3                	mov    %edx,%ebx
  800141:	89 d7                	mov    %edx,%edi
  800143:	89 d6                	mov    %edx,%esi
  800145:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800147:	5b                   	pop    %ebx
  800148:	5e                   	pop    %esi
  800149:	5f                   	pop    %edi
  80014a:	5d                   	pop    %ebp
  80014b:	c3                   	ret    

0080014c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80014c:	55                   	push   %ebp
  80014d:	89 e5                	mov    %esp,%ebp
  80014f:	56                   	push   %esi
  800150:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800151:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800154:	8b 35 00 10 80 00    	mov    0x801000,%esi
  80015a:	e8 ce ff ff ff       	call   80012d <sys_getenvid>
  80015f:	83 ec 0c             	sub    $0xc,%esp
  800162:	ff 75 0c             	pushl  0xc(%ebp)
  800165:	ff 75 08             	pushl  0x8(%ebp)
  800168:	56                   	push   %esi
  800169:	50                   	push   %eax
  80016a:	68 40 0d 80 00       	push   $0x800d40
  80016f:	e8 b2 00 00 00       	call   800226 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800174:	83 c4 18             	add    $0x18,%esp
  800177:	53                   	push   %ebx
  800178:	ff 75 10             	pushl  0x10(%ebp)
  80017b:	e8 55 00 00 00       	call   8001d5 <vcprintf>
	cprintf("\n");
  800180:	c7 04 24 64 0d 80 00 	movl   $0x800d64,(%esp)
  800187:	e8 9a 00 00 00       	call   800226 <cprintf>
  80018c:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80018f:	cc                   	int3   
  800190:	eb fd                	jmp    80018f <_panic+0x43>

00800192 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800192:	55                   	push   %ebp
  800193:	89 e5                	mov    %esp,%ebp
  800195:	53                   	push   %ebx
  800196:	83 ec 04             	sub    $0x4,%esp
  800199:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80019c:	8b 13                	mov    (%ebx),%edx
  80019e:	8d 42 01             	lea    0x1(%edx),%eax
  8001a1:	89 03                	mov    %eax,(%ebx)
  8001a3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001a6:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001aa:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001af:	74 08                	je     8001b9 <putch+0x27>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8001b1:	ff 43 04             	incl   0x4(%ebx)
}
  8001b4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001b7:	c9                   	leave  
  8001b8:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8001b9:	83 ec 08             	sub    $0x8,%esp
  8001bc:	68 ff 00 00 00       	push   $0xff
  8001c1:	8d 43 08             	lea    0x8(%ebx),%eax
  8001c4:	50                   	push   %eax
  8001c5:	e8 e5 fe ff ff       	call   8000af <sys_cputs>
		b->idx = 0;
  8001ca:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001d0:	83 c4 10             	add    $0x10,%esp
  8001d3:	eb dc                	jmp    8001b1 <putch+0x1f>

008001d5 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001d5:	55                   	push   %ebp
  8001d6:	89 e5                	mov    %esp,%ebp
  8001d8:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001de:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001e5:	00 00 00 
	b.cnt = 0;
  8001e8:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001ef:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001f2:	ff 75 0c             	pushl  0xc(%ebp)
  8001f5:	ff 75 08             	pushl  0x8(%ebp)
  8001f8:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001fe:	50                   	push   %eax
  8001ff:	68 92 01 80 00       	push   $0x800192
  800204:	e8 0f 01 00 00       	call   800318 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800209:	83 c4 08             	add    $0x8,%esp
  80020c:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800212:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800218:	50                   	push   %eax
  800219:	e8 91 fe ff ff       	call   8000af <sys_cputs>

	return b.cnt;
}
  80021e:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800224:	c9                   	leave  
  800225:	c3                   	ret    

00800226 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800226:	55                   	push   %ebp
  800227:	89 e5                	mov    %esp,%ebp
  800229:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80022c:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80022f:	50                   	push   %eax
  800230:	ff 75 08             	pushl  0x8(%ebp)
  800233:	e8 9d ff ff ff       	call   8001d5 <vcprintf>
	va_end(ap);

	return cnt;
}
  800238:	c9                   	leave  
  800239:	c3                   	ret    

0080023a <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80023a:	55                   	push   %ebp
  80023b:	89 e5                	mov    %esp,%ebp
  80023d:	57                   	push   %edi
  80023e:	56                   	push   %esi
  80023f:	53                   	push   %ebx
  800240:	83 ec 1c             	sub    $0x1c,%esp
  800243:	89 c7                	mov    %eax,%edi
  800245:	89 d6                	mov    %edx,%esi
  800247:	8b 45 08             	mov    0x8(%ebp),%eax
  80024a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80024d:	89 d1                	mov    %edx,%ecx
  80024f:	89 c2                	mov    %eax,%edx
  800251:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800254:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800257:	8b 45 10             	mov    0x10(%ebp),%eax
  80025a:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80025d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800260:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800267:	39 c2                	cmp    %eax,%edx
  800269:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  80026c:	72 3c                	jb     8002aa <printnum+0x70>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80026e:	83 ec 0c             	sub    $0xc,%esp
  800271:	ff 75 18             	pushl  0x18(%ebp)
  800274:	4b                   	dec    %ebx
  800275:	53                   	push   %ebx
  800276:	50                   	push   %eax
  800277:	83 ec 08             	sub    $0x8,%esp
  80027a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80027d:	ff 75 e0             	pushl  -0x20(%ebp)
  800280:	ff 75 dc             	pushl  -0x24(%ebp)
  800283:	ff 75 d8             	pushl  -0x28(%ebp)
  800286:	e8 55 08 00 00       	call   800ae0 <__udivdi3>
  80028b:	83 c4 18             	add    $0x18,%esp
  80028e:	52                   	push   %edx
  80028f:	50                   	push   %eax
  800290:	89 f2                	mov    %esi,%edx
  800292:	89 f8                	mov    %edi,%eax
  800294:	e8 a1 ff ff ff       	call   80023a <printnum>
  800299:	83 c4 20             	add    $0x20,%esp
  80029c:	eb 11                	jmp    8002af <printnum+0x75>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80029e:	83 ec 08             	sub    $0x8,%esp
  8002a1:	56                   	push   %esi
  8002a2:	ff 75 18             	pushl  0x18(%ebp)
  8002a5:	ff d7                	call   *%edi
  8002a7:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8002aa:	4b                   	dec    %ebx
  8002ab:	85 db                	test   %ebx,%ebx
  8002ad:	7f ef                	jg     80029e <printnum+0x64>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002af:	83 ec 08             	sub    $0x8,%esp
  8002b2:	56                   	push   %esi
  8002b3:	83 ec 04             	sub    $0x4,%esp
  8002b6:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002b9:	ff 75 e0             	pushl  -0x20(%ebp)
  8002bc:	ff 75 dc             	pushl  -0x24(%ebp)
  8002bf:	ff 75 d8             	pushl  -0x28(%ebp)
  8002c2:	e8 19 09 00 00       	call   800be0 <__umoddi3>
  8002c7:	83 c4 14             	add    $0x14,%esp
  8002ca:	0f be 80 66 0d 80 00 	movsbl 0x800d66(%eax),%eax
  8002d1:	50                   	push   %eax
  8002d2:	ff d7                	call   *%edi
}
  8002d4:	83 c4 10             	add    $0x10,%esp
  8002d7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002da:	5b                   	pop    %ebx
  8002db:	5e                   	pop    %esi
  8002dc:	5f                   	pop    %edi
  8002dd:	5d                   	pop    %ebp
  8002de:	c3                   	ret    

008002df <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002df:	55                   	push   %ebp
  8002e0:	89 e5                	mov    %esp,%ebp
  8002e2:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002e5:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8002e8:	8b 10                	mov    (%eax),%edx
  8002ea:	3b 50 04             	cmp    0x4(%eax),%edx
  8002ed:	73 0a                	jae    8002f9 <sprintputch+0x1a>
		*b->buf++ = ch;
  8002ef:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002f2:	89 08                	mov    %ecx,(%eax)
  8002f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8002f7:	88 02                	mov    %al,(%edx)
}
  8002f9:	5d                   	pop    %ebp
  8002fa:	c3                   	ret    

008002fb <printfmt>:
{
  8002fb:	55                   	push   %ebp
  8002fc:	89 e5                	mov    %esp,%ebp
  8002fe:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800301:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800304:	50                   	push   %eax
  800305:	ff 75 10             	pushl  0x10(%ebp)
  800308:	ff 75 0c             	pushl  0xc(%ebp)
  80030b:	ff 75 08             	pushl  0x8(%ebp)
  80030e:	e8 05 00 00 00       	call   800318 <vprintfmt>
}
  800313:	83 c4 10             	add    $0x10,%esp
  800316:	c9                   	leave  
  800317:	c3                   	ret    

00800318 <vprintfmt>:
{
  800318:	55                   	push   %ebp
  800319:	89 e5                	mov    %esp,%ebp
  80031b:	57                   	push   %edi
  80031c:	56                   	push   %esi
  80031d:	53                   	push   %ebx
  80031e:	83 ec 3c             	sub    $0x3c,%esp
  800321:	8b 75 08             	mov    0x8(%ebp),%esi
  800324:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800327:	8b 7d 10             	mov    0x10(%ebp),%edi
  80032a:	e9 5b 03 00 00       	jmp    80068a <vprintfmt+0x372>
		padc = ' ';
  80032f:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  800333:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
		precision = -1;
  80033a:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  800341:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		lflag = 0;
  800348:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80034d:	8d 47 01             	lea    0x1(%edi),%eax
  800350:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800353:	8a 17                	mov    (%edi),%dl
  800355:	8d 42 dd             	lea    -0x23(%edx),%eax
  800358:	3c 55                	cmp    $0x55,%al
  80035a:	0f 87 ab 03 00 00    	ja     80070b <vprintfmt+0x3f3>
  800360:	0f b6 c0             	movzbl %al,%eax
  800363:	ff 24 85 f4 0d 80 00 	jmp    *0x800df4(,%eax,4)
  80036a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  80036d:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  800371:	eb da                	jmp    80034d <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  800373:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800376:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  80037a:	eb d1                	jmp    80034d <vprintfmt+0x35>
  80037c:	0f b6 d2             	movzbl %dl,%edx
  80037f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800382:	b8 00 00 00 00       	mov    $0x0,%eax
  800387:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  80038a:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80038d:	01 c0                	add    %eax,%eax
  80038f:	8d 44 02 d0          	lea    -0x30(%edx,%eax,1),%eax
				ch = *fmt;
  800393:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800396:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800399:	83 f9 09             	cmp    $0x9,%ecx
  80039c:	77 52                	ja     8003f0 <vprintfmt+0xd8>
			for (precision = 0; ; ++fmt) {
  80039e:	47                   	inc    %edi
				precision = precision * 10 + ch - '0';
  80039f:	eb e9                	jmp    80038a <vprintfmt+0x72>
			precision = va_arg(ap, int);
  8003a1:	8b 45 14             	mov    0x14(%ebp),%eax
  8003a4:	8b 00                	mov    (%eax),%eax
  8003a6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003a9:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ac:	8d 40 04             	lea    0x4(%eax),%eax
  8003af:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003b2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8003b5:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8003b9:	79 92                	jns    80034d <vprintfmt+0x35>
				width = precision, precision = -1;
  8003bb:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8003be:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8003c1:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8003c8:	eb 83                	jmp    80034d <vprintfmt+0x35>
  8003ca:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8003ce:	78 08                	js     8003d8 <vprintfmt+0xc0>
		switch (ch = *(unsigned char *) fmt++) {
  8003d0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8003d3:	e9 75 ff ff ff       	jmp    80034d <vprintfmt+0x35>
  8003d8:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  8003df:	eb ef                	jmp    8003d0 <vprintfmt+0xb8>
		switch (ch = *(unsigned char *) fmt++) {
  8003e1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8003e4:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  8003eb:	e9 5d ff ff ff       	jmp    80034d <vprintfmt+0x35>
  8003f0:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8003f3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003f6:	eb bd                	jmp    8003b5 <vprintfmt+0x9d>
			lflag++;
  8003f8:	41                   	inc    %ecx
		switch (ch = *(unsigned char *) fmt++) {
  8003f9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8003fc:	e9 4c ff ff ff       	jmp    80034d <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
  800401:	8b 45 14             	mov    0x14(%ebp),%eax
  800404:	8d 78 04             	lea    0x4(%eax),%edi
  800407:	83 ec 08             	sub    $0x8,%esp
  80040a:	53                   	push   %ebx
  80040b:	ff 30                	pushl  (%eax)
  80040d:	ff d6                	call   *%esi
			break;
  80040f:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800412:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800415:	e9 6d 02 00 00       	jmp    800687 <vprintfmt+0x36f>
			err = va_arg(ap, int);
  80041a:	8b 45 14             	mov    0x14(%ebp),%eax
  80041d:	8d 78 04             	lea    0x4(%eax),%edi
  800420:	8b 00                	mov    (%eax),%eax
  800422:	85 c0                	test   %eax,%eax
  800424:	78 2a                	js     800450 <vprintfmt+0x138>
  800426:	89 c2                	mov    %eax,%edx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800428:	83 f8 06             	cmp    $0x6,%eax
  80042b:	7f 27                	jg     800454 <vprintfmt+0x13c>
  80042d:	8b 04 85 4c 0f 80 00 	mov    0x800f4c(,%eax,4),%eax
  800434:	85 c0                	test   %eax,%eax
  800436:	74 1c                	je     800454 <vprintfmt+0x13c>
				printfmt(putch, putdat, "%s", p);
  800438:	50                   	push   %eax
  800439:	68 87 0d 80 00       	push   $0x800d87
  80043e:	53                   	push   %ebx
  80043f:	56                   	push   %esi
  800440:	e8 b6 fe ff ff       	call   8002fb <printfmt>
  800445:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800448:	89 7d 14             	mov    %edi,0x14(%ebp)
  80044b:	e9 37 02 00 00       	jmp    800687 <vprintfmt+0x36f>
  800450:	f7 d8                	neg    %eax
  800452:	eb d2                	jmp    800426 <vprintfmt+0x10e>
				printfmt(putch, putdat, "error %d", err);
  800454:	52                   	push   %edx
  800455:	68 7e 0d 80 00       	push   $0x800d7e
  80045a:	53                   	push   %ebx
  80045b:	56                   	push   %esi
  80045c:	e8 9a fe ff ff       	call   8002fb <printfmt>
  800461:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800464:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800467:	e9 1b 02 00 00       	jmp    800687 <vprintfmt+0x36f>
			if ((p = va_arg(ap, char *)) == NULL)
  80046c:	8b 45 14             	mov    0x14(%ebp),%eax
  80046f:	83 c0 04             	add    $0x4,%eax
  800472:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800475:	8b 45 14             	mov    0x14(%ebp),%eax
  800478:	8b 00                	mov    (%eax),%eax
  80047a:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80047d:	85 c0                	test   %eax,%eax
  80047f:	74 19                	je     80049a <vprintfmt+0x182>
			if (width > 0 && padc != '-')
  800481:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800485:	7e 06                	jle    80048d <vprintfmt+0x175>
  800487:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  80048b:	75 16                	jne    8004a3 <vprintfmt+0x18b>
				for (width -= strnlen(p, precision); width > 0; width--)
  80048d:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800490:	89 c7                	mov    %eax,%edi
  800492:	03 45 d4             	add    -0x2c(%ebp),%eax
  800495:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800498:	eb 62                	jmp    8004fc <vprintfmt+0x1e4>
				p = "(null)";
  80049a:	c7 45 cc 77 0d 80 00 	movl   $0x800d77,-0x34(%ebp)
  8004a1:	eb de                	jmp    800481 <vprintfmt+0x169>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004a3:	83 ec 08             	sub    $0x8,%esp
  8004a6:	ff 75 d8             	pushl  -0x28(%ebp)
  8004a9:	ff 75 cc             	pushl  -0x34(%ebp)
  8004ac:	e8 05 03 00 00       	call   8007b6 <strnlen>
  8004b1:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8004b4:	29 c2                	sub    %eax,%edx
  8004b6:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  8004b9:	83 c4 10             	add    $0x10,%esp
  8004bc:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  8004be:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8004c2:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8004c5:	eb 0d                	jmp    8004d4 <vprintfmt+0x1bc>
					putch(padc, putdat);
  8004c7:	83 ec 08             	sub    $0x8,%esp
  8004ca:	53                   	push   %ebx
  8004cb:	ff 75 d4             	pushl  -0x2c(%ebp)
  8004ce:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8004d0:	4f                   	dec    %edi
  8004d1:	83 c4 10             	add    $0x10,%esp
  8004d4:	85 ff                	test   %edi,%edi
  8004d6:	7f ef                	jg     8004c7 <vprintfmt+0x1af>
  8004d8:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8004db:	89 d0                	mov    %edx,%eax
  8004dd:	85 d2                	test   %edx,%edx
  8004df:	78 0a                	js     8004eb <vprintfmt+0x1d3>
  8004e1:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8004e4:	29 c2                	sub    %eax,%edx
  8004e6:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8004e9:	eb a2                	jmp    80048d <vprintfmt+0x175>
  8004eb:	b8 00 00 00 00       	mov    $0x0,%eax
  8004f0:	eb ef                	jmp    8004e1 <vprintfmt+0x1c9>
					putch(ch, putdat);
  8004f2:	83 ec 08             	sub    $0x8,%esp
  8004f5:	53                   	push   %ebx
  8004f6:	52                   	push   %edx
  8004f7:	ff d6                	call   *%esi
  8004f9:	83 c4 10             	add    $0x10,%esp
  8004fc:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  8004ff:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800501:	47                   	inc    %edi
  800502:	8a 47 ff             	mov    -0x1(%edi),%al
  800505:	0f be d0             	movsbl %al,%edx
  800508:	85 d2                	test   %edx,%edx
  80050a:	74 48                	je     800554 <vprintfmt+0x23c>
  80050c:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800510:	78 05                	js     800517 <vprintfmt+0x1ff>
  800512:	ff 4d d8             	decl   -0x28(%ebp)
  800515:	78 1e                	js     800535 <vprintfmt+0x21d>
				if (altflag && (ch < ' ' || ch > '~'))
  800517:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80051b:	74 d5                	je     8004f2 <vprintfmt+0x1da>
  80051d:	0f be c0             	movsbl %al,%eax
  800520:	83 e8 20             	sub    $0x20,%eax
  800523:	83 f8 5e             	cmp    $0x5e,%eax
  800526:	76 ca                	jbe    8004f2 <vprintfmt+0x1da>
					putch('?', putdat);
  800528:	83 ec 08             	sub    $0x8,%esp
  80052b:	53                   	push   %ebx
  80052c:	6a 3f                	push   $0x3f
  80052e:	ff d6                	call   *%esi
  800530:	83 c4 10             	add    $0x10,%esp
  800533:	eb c7                	jmp    8004fc <vprintfmt+0x1e4>
  800535:	89 cf                	mov    %ecx,%edi
  800537:	eb 0c                	jmp    800545 <vprintfmt+0x22d>
				putch(' ', putdat);
  800539:	83 ec 08             	sub    $0x8,%esp
  80053c:	53                   	push   %ebx
  80053d:	6a 20                	push   $0x20
  80053f:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800541:	4f                   	dec    %edi
  800542:	83 c4 10             	add    $0x10,%esp
  800545:	85 ff                	test   %edi,%edi
  800547:	7f f0                	jg     800539 <vprintfmt+0x221>
			if ((p = va_arg(ap, char *)) == NULL)
  800549:	8b 45 c8             	mov    -0x38(%ebp),%eax
  80054c:	89 45 14             	mov    %eax,0x14(%ebp)
  80054f:	e9 33 01 00 00       	jmp    800687 <vprintfmt+0x36f>
  800554:	89 cf                	mov    %ecx,%edi
  800556:	eb ed                	jmp    800545 <vprintfmt+0x22d>
	if (lflag >= 2)
  800558:	83 f9 01             	cmp    $0x1,%ecx
  80055b:	7f 1b                	jg     800578 <vprintfmt+0x260>
	else if (lflag)
  80055d:	85 c9                	test   %ecx,%ecx
  80055f:	74 42                	je     8005a3 <vprintfmt+0x28b>
		return va_arg(*ap, long);
  800561:	8b 45 14             	mov    0x14(%ebp),%eax
  800564:	8b 00                	mov    (%eax),%eax
  800566:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800569:	99                   	cltd   
  80056a:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80056d:	8b 45 14             	mov    0x14(%ebp),%eax
  800570:	8d 40 04             	lea    0x4(%eax),%eax
  800573:	89 45 14             	mov    %eax,0x14(%ebp)
  800576:	eb 17                	jmp    80058f <vprintfmt+0x277>
		return va_arg(*ap, long long);
  800578:	8b 45 14             	mov    0x14(%ebp),%eax
  80057b:	8b 50 04             	mov    0x4(%eax),%edx
  80057e:	8b 00                	mov    (%eax),%eax
  800580:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800583:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800586:	8b 45 14             	mov    0x14(%ebp),%eax
  800589:	8d 40 08             	lea    0x8(%eax),%eax
  80058c:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  80058f:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800592:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800595:	85 c9                	test   %ecx,%ecx
  800597:	78 21                	js     8005ba <vprintfmt+0x2a2>
			base = 10;
  800599:	b8 0a 00 00 00       	mov    $0xa,%eax
  80059e:	e9 ca 00 00 00       	jmp    80066d <vprintfmt+0x355>
		return va_arg(*ap, int);
  8005a3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a6:	8b 00                	mov    (%eax),%eax
  8005a8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005ab:	99                   	cltd   
  8005ac:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005af:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b2:	8d 40 04             	lea    0x4(%eax),%eax
  8005b5:	89 45 14             	mov    %eax,0x14(%ebp)
  8005b8:	eb d5                	jmp    80058f <vprintfmt+0x277>
				putch('-', putdat);
  8005ba:	83 ec 08             	sub    $0x8,%esp
  8005bd:	53                   	push   %ebx
  8005be:	6a 2d                	push   $0x2d
  8005c0:	ff d6                	call   *%esi
				num = -(long long) num;
  8005c2:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005c5:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8005c8:	f7 da                	neg    %edx
  8005ca:	83 d1 00             	adc    $0x0,%ecx
  8005cd:	f7 d9                	neg    %ecx
  8005cf:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8005d2:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005d7:	e9 91 00 00 00       	jmp    80066d <vprintfmt+0x355>
	if (lflag >= 2)
  8005dc:	83 f9 01             	cmp    $0x1,%ecx
  8005df:	7f 1b                	jg     8005fc <vprintfmt+0x2e4>
	else if (lflag)
  8005e1:	85 c9                	test   %ecx,%ecx
  8005e3:	74 2c                	je     800611 <vprintfmt+0x2f9>
		return va_arg(*ap, unsigned long);
  8005e5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e8:	8b 10                	mov    (%eax),%edx
  8005ea:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005ef:	8d 40 04             	lea    0x4(%eax),%eax
  8005f2:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005f5:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  8005fa:	eb 71                	jmp    80066d <vprintfmt+0x355>
		return va_arg(*ap, unsigned long long);
  8005fc:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ff:	8b 10                	mov    (%eax),%edx
  800601:	8b 48 04             	mov    0x4(%eax),%ecx
  800604:	8d 40 08             	lea    0x8(%eax),%eax
  800607:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80060a:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  80060f:	eb 5c                	jmp    80066d <vprintfmt+0x355>
		return va_arg(*ap, unsigned int);
  800611:	8b 45 14             	mov    0x14(%ebp),%eax
  800614:	8b 10                	mov    (%eax),%edx
  800616:	b9 00 00 00 00       	mov    $0x0,%ecx
  80061b:	8d 40 04             	lea    0x4(%eax),%eax
  80061e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800621:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  800626:	eb 45                	jmp    80066d <vprintfmt+0x355>
			putch('X', putdat);
  800628:	83 ec 08             	sub    $0x8,%esp
  80062b:	53                   	push   %ebx
  80062c:	6a 58                	push   $0x58
  80062e:	ff d6                	call   *%esi
			putch('X', putdat);
  800630:	83 c4 08             	add    $0x8,%esp
  800633:	53                   	push   %ebx
  800634:	6a 58                	push   $0x58
  800636:	ff d6                	call   *%esi
			putch('X', putdat);
  800638:	83 c4 08             	add    $0x8,%esp
  80063b:	53                   	push   %ebx
  80063c:	6a 58                	push   $0x58
  80063e:	ff d6                	call   *%esi
			break;
  800640:	83 c4 10             	add    $0x10,%esp
  800643:	eb 42                	jmp    800687 <vprintfmt+0x36f>
			putch('0', putdat);
  800645:	83 ec 08             	sub    $0x8,%esp
  800648:	53                   	push   %ebx
  800649:	6a 30                	push   $0x30
  80064b:	ff d6                	call   *%esi
			putch('x', putdat);
  80064d:	83 c4 08             	add    $0x8,%esp
  800650:	53                   	push   %ebx
  800651:	6a 78                	push   $0x78
  800653:	ff d6                	call   *%esi
			num = (unsigned long long)
  800655:	8b 45 14             	mov    0x14(%ebp),%eax
  800658:	8b 10                	mov    (%eax),%edx
  80065a:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  80065f:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800662:	8d 40 04             	lea    0x4(%eax),%eax
  800665:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800668:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  80066d:	83 ec 0c             	sub    $0xc,%esp
  800670:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  800674:	57                   	push   %edi
  800675:	ff 75 d4             	pushl  -0x2c(%ebp)
  800678:	50                   	push   %eax
  800679:	51                   	push   %ecx
  80067a:	52                   	push   %edx
  80067b:	89 da                	mov    %ebx,%edx
  80067d:	89 f0                	mov    %esi,%eax
  80067f:	e8 b6 fb ff ff       	call   80023a <printnum>
			break;
  800684:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  800687:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80068a:	47                   	inc    %edi
  80068b:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80068f:	83 f8 25             	cmp    $0x25,%eax
  800692:	0f 84 97 fc ff ff    	je     80032f <vprintfmt+0x17>
			if (ch == '\0')
  800698:	85 c0                	test   %eax,%eax
  80069a:	0f 84 89 00 00 00    	je     800729 <vprintfmt+0x411>
			putch(ch, putdat);
  8006a0:	83 ec 08             	sub    $0x8,%esp
  8006a3:	53                   	push   %ebx
  8006a4:	50                   	push   %eax
  8006a5:	ff d6                	call   *%esi
  8006a7:	83 c4 10             	add    $0x10,%esp
  8006aa:	eb de                	jmp    80068a <vprintfmt+0x372>
	if (lflag >= 2)
  8006ac:	83 f9 01             	cmp    $0x1,%ecx
  8006af:	7f 1b                	jg     8006cc <vprintfmt+0x3b4>
	else if (lflag)
  8006b1:	85 c9                	test   %ecx,%ecx
  8006b3:	74 2c                	je     8006e1 <vprintfmt+0x3c9>
		return va_arg(*ap, unsigned long);
  8006b5:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b8:	8b 10                	mov    (%eax),%edx
  8006ba:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006bf:	8d 40 04             	lea    0x4(%eax),%eax
  8006c2:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006c5:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  8006ca:	eb a1                	jmp    80066d <vprintfmt+0x355>
		return va_arg(*ap, unsigned long long);
  8006cc:	8b 45 14             	mov    0x14(%ebp),%eax
  8006cf:	8b 10                	mov    (%eax),%edx
  8006d1:	8b 48 04             	mov    0x4(%eax),%ecx
  8006d4:	8d 40 08             	lea    0x8(%eax),%eax
  8006d7:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006da:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  8006df:	eb 8c                	jmp    80066d <vprintfmt+0x355>
		return va_arg(*ap, unsigned int);
  8006e1:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e4:	8b 10                	mov    (%eax),%edx
  8006e6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006eb:	8d 40 04             	lea    0x4(%eax),%eax
  8006ee:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006f1:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  8006f6:	e9 72 ff ff ff       	jmp    80066d <vprintfmt+0x355>
			putch(ch, putdat);
  8006fb:	83 ec 08             	sub    $0x8,%esp
  8006fe:	53                   	push   %ebx
  8006ff:	6a 25                	push   $0x25
  800701:	ff d6                	call   *%esi
			break;
  800703:	83 c4 10             	add    $0x10,%esp
  800706:	e9 7c ff ff ff       	jmp    800687 <vprintfmt+0x36f>
			putch('%', putdat);
  80070b:	83 ec 08             	sub    $0x8,%esp
  80070e:	53                   	push   %ebx
  80070f:	6a 25                	push   $0x25
  800711:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800713:	83 c4 10             	add    $0x10,%esp
  800716:	89 f8                	mov    %edi,%eax
  800718:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  80071c:	74 03                	je     800721 <vprintfmt+0x409>
  80071e:	48                   	dec    %eax
  80071f:	eb f7                	jmp    800718 <vprintfmt+0x400>
  800721:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800724:	e9 5e ff ff ff       	jmp    800687 <vprintfmt+0x36f>
}
  800729:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80072c:	5b                   	pop    %ebx
  80072d:	5e                   	pop    %esi
  80072e:	5f                   	pop    %edi
  80072f:	5d                   	pop    %ebp
  800730:	c3                   	ret    

00800731 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800731:	55                   	push   %ebp
  800732:	89 e5                	mov    %esp,%ebp
  800734:	83 ec 18             	sub    $0x18,%esp
  800737:	8b 45 08             	mov    0x8(%ebp),%eax
  80073a:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80073d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800740:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800744:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800747:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80074e:	85 c0                	test   %eax,%eax
  800750:	74 26                	je     800778 <vsnprintf+0x47>
  800752:	85 d2                	test   %edx,%edx
  800754:	7e 29                	jle    80077f <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800756:	ff 75 14             	pushl  0x14(%ebp)
  800759:	ff 75 10             	pushl  0x10(%ebp)
  80075c:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80075f:	50                   	push   %eax
  800760:	68 df 02 80 00       	push   $0x8002df
  800765:	e8 ae fb ff ff       	call   800318 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80076a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80076d:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800770:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800773:	83 c4 10             	add    $0x10,%esp
}
  800776:	c9                   	leave  
  800777:	c3                   	ret    
		return -E_INVAL;
  800778:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80077d:	eb f7                	jmp    800776 <vsnprintf+0x45>
  80077f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800784:	eb f0                	jmp    800776 <vsnprintf+0x45>

00800786 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800786:	55                   	push   %ebp
  800787:	89 e5                	mov    %esp,%ebp
  800789:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80078c:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80078f:	50                   	push   %eax
  800790:	ff 75 10             	pushl  0x10(%ebp)
  800793:	ff 75 0c             	pushl  0xc(%ebp)
  800796:	ff 75 08             	pushl  0x8(%ebp)
  800799:	e8 93 ff ff ff       	call   800731 <vsnprintf>
	va_end(ap);

	return rc;
}
  80079e:	c9                   	leave  
  80079f:	c3                   	ret    

008007a0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007a0:	55                   	push   %ebp
  8007a1:	89 e5                	mov    %esp,%ebp
  8007a3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007a6:	b8 00 00 00 00       	mov    $0x0,%eax
  8007ab:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007af:	74 03                	je     8007b4 <strlen+0x14>
		n++;
  8007b1:	40                   	inc    %eax
  8007b2:	eb f7                	jmp    8007ab <strlen+0xb>
	return n;
}
  8007b4:	5d                   	pop    %ebp
  8007b5:	c3                   	ret    

008007b6 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007b6:	55                   	push   %ebp
  8007b7:	89 e5                	mov    %esp,%ebp
  8007b9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007bc:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007bf:	b8 00 00 00 00       	mov    $0x0,%eax
  8007c4:	39 d0                	cmp    %edx,%eax
  8007c6:	74 0b                	je     8007d3 <strnlen+0x1d>
  8007c8:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007cc:	74 03                	je     8007d1 <strnlen+0x1b>
		n++;
  8007ce:	40                   	inc    %eax
  8007cf:	eb f3                	jmp    8007c4 <strnlen+0xe>
  8007d1:	89 c2                	mov    %eax,%edx
	return n;
}
  8007d3:	89 d0                	mov    %edx,%eax
  8007d5:	5d                   	pop    %ebp
  8007d6:	c3                   	ret    

008007d7 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007d7:	55                   	push   %ebp
  8007d8:	89 e5                	mov    %esp,%ebp
  8007da:	53                   	push   %ebx
  8007db:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007de:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007e1:	b8 00 00 00 00       	mov    $0x0,%eax
  8007e6:	8a 14 03             	mov    (%ebx,%eax,1),%dl
  8007e9:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8007ec:	40                   	inc    %eax
  8007ed:	84 d2                	test   %dl,%dl
  8007ef:	75 f5                	jne    8007e6 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8007f1:	89 c8                	mov    %ecx,%eax
  8007f3:	5b                   	pop    %ebx
  8007f4:	5d                   	pop    %ebp
  8007f5:	c3                   	ret    

008007f6 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007f6:	55                   	push   %ebp
  8007f7:	89 e5                	mov    %esp,%ebp
  8007f9:	53                   	push   %ebx
  8007fa:	83 ec 10             	sub    $0x10,%esp
  8007fd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800800:	53                   	push   %ebx
  800801:	e8 9a ff ff ff       	call   8007a0 <strlen>
  800806:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800809:	ff 75 0c             	pushl  0xc(%ebp)
  80080c:	01 d8                	add    %ebx,%eax
  80080e:	50                   	push   %eax
  80080f:	e8 c3 ff ff ff       	call   8007d7 <strcpy>
	return dst;
}
  800814:	89 d8                	mov    %ebx,%eax
  800816:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800819:	c9                   	leave  
  80081a:	c3                   	ret    

0080081b <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80081b:	55                   	push   %ebp
  80081c:	89 e5                	mov    %esp,%ebp
  80081e:	53                   	push   %ebx
  80081f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800822:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800825:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800828:	8b 45 08             	mov    0x8(%ebp),%eax
  80082b:	39 d8                	cmp    %ebx,%eax
  80082d:	74 0e                	je     80083d <strncpy+0x22>
		*dst++ = *src;
  80082f:	40                   	inc    %eax
  800830:	8a 0a                	mov    (%edx),%cl
  800832:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800835:	80 f9 01             	cmp    $0x1,%cl
  800838:	83 da ff             	sbb    $0xffffffff,%edx
  80083b:	eb ee                	jmp    80082b <strncpy+0x10>
	}
	return ret;
}
  80083d:	8b 45 08             	mov    0x8(%ebp),%eax
  800840:	5b                   	pop    %ebx
  800841:	5d                   	pop    %ebp
  800842:	c3                   	ret    

00800843 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800843:	55                   	push   %ebp
  800844:	89 e5                	mov    %esp,%ebp
  800846:	56                   	push   %esi
  800847:	53                   	push   %ebx
  800848:	8b 75 08             	mov    0x8(%ebp),%esi
  80084b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80084e:	8b 45 10             	mov    0x10(%ebp),%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800851:	85 c0                	test   %eax,%eax
  800853:	74 22                	je     800877 <strlcpy+0x34>
  800855:	8d 44 06 ff          	lea    -0x1(%esi,%eax,1),%eax
  800859:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  80085b:	39 c2                	cmp    %eax,%edx
  80085d:	74 0f                	je     80086e <strlcpy+0x2b>
  80085f:	8a 19                	mov    (%ecx),%bl
  800861:	84 db                	test   %bl,%bl
  800863:	74 07                	je     80086c <strlcpy+0x29>
			*dst++ = *src++;
  800865:	41                   	inc    %ecx
  800866:	42                   	inc    %edx
  800867:	88 5a ff             	mov    %bl,-0x1(%edx)
  80086a:	eb ef                	jmp    80085b <strlcpy+0x18>
  80086c:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  80086e:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800871:	29 f0                	sub    %esi,%eax
}
  800873:	5b                   	pop    %ebx
  800874:	5e                   	pop    %esi
  800875:	5d                   	pop    %ebp
  800876:	c3                   	ret    
  800877:	89 f0                	mov    %esi,%eax
  800879:	eb f6                	jmp    800871 <strlcpy+0x2e>

0080087b <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80087b:	55                   	push   %ebp
  80087c:	89 e5                	mov    %esp,%ebp
  80087e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800881:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800884:	8a 01                	mov    (%ecx),%al
  800886:	84 c0                	test   %al,%al
  800888:	74 08                	je     800892 <strcmp+0x17>
  80088a:	3a 02                	cmp    (%edx),%al
  80088c:	75 04                	jne    800892 <strcmp+0x17>
		p++, q++;
  80088e:	41                   	inc    %ecx
  80088f:	42                   	inc    %edx
  800890:	eb f2                	jmp    800884 <strcmp+0x9>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800892:	0f b6 c0             	movzbl %al,%eax
  800895:	0f b6 12             	movzbl (%edx),%edx
  800898:	29 d0                	sub    %edx,%eax
}
  80089a:	5d                   	pop    %ebp
  80089b:	c3                   	ret    

0080089c <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80089c:	55                   	push   %ebp
  80089d:	89 e5                	mov    %esp,%ebp
  80089f:	53                   	push   %ebx
  8008a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008a6:	89 c3                	mov    %eax,%ebx
  8008a8:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008ab:	eb 02                	jmp    8008af <strncmp+0x13>
		n--, p++, q++;
  8008ad:	40                   	inc    %eax
  8008ae:	42                   	inc    %edx
	while (n > 0 && *p && *p == *q)
  8008af:	39 d8                	cmp    %ebx,%eax
  8008b1:	74 15                	je     8008c8 <strncmp+0x2c>
  8008b3:	8a 08                	mov    (%eax),%cl
  8008b5:	84 c9                	test   %cl,%cl
  8008b7:	74 04                	je     8008bd <strncmp+0x21>
  8008b9:	3a 0a                	cmp    (%edx),%cl
  8008bb:	74 f0                	je     8008ad <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008bd:	0f b6 00             	movzbl (%eax),%eax
  8008c0:	0f b6 12             	movzbl (%edx),%edx
  8008c3:	29 d0                	sub    %edx,%eax
}
  8008c5:	5b                   	pop    %ebx
  8008c6:	5d                   	pop    %ebp
  8008c7:	c3                   	ret    
		return 0;
  8008c8:	b8 00 00 00 00       	mov    $0x0,%eax
  8008cd:	eb f6                	jmp    8008c5 <strncmp+0x29>

008008cf <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008cf:	55                   	push   %ebp
  8008d0:	89 e5                	mov    %esp,%ebp
  8008d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d5:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8008d8:	8a 10                	mov    (%eax),%dl
  8008da:	84 d2                	test   %dl,%dl
  8008dc:	74 07                	je     8008e5 <strchr+0x16>
		if (*s == c)
  8008de:	38 ca                	cmp    %cl,%dl
  8008e0:	74 08                	je     8008ea <strchr+0x1b>
	for (; *s; s++)
  8008e2:	40                   	inc    %eax
  8008e3:	eb f3                	jmp    8008d8 <strchr+0x9>
			return (char *) s;
	return 0;
  8008e5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008ea:	5d                   	pop    %ebp
  8008eb:	c3                   	ret    

008008ec <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008ec:	55                   	push   %ebp
  8008ed:	89 e5                	mov    %esp,%ebp
  8008ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f2:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8008f5:	8a 10                	mov    (%eax),%dl
  8008f7:	84 d2                	test   %dl,%dl
  8008f9:	74 07                	je     800902 <strfind+0x16>
		if (*s == c)
  8008fb:	38 ca                	cmp    %cl,%dl
  8008fd:	74 03                	je     800902 <strfind+0x16>
	for (; *s; s++)
  8008ff:	40                   	inc    %eax
  800900:	eb f3                	jmp    8008f5 <strfind+0x9>
			break;
	return (char *) s;
}
  800902:	5d                   	pop    %ebp
  800903:	c3                   	ret    

00800904 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800904:	55                   	push   %ebp
  800905:	89 e5                	mov    %esp,%ebp
  800907:	57                   	push   %edi
  800908:	56                   	push   %esi
  800909:	53                   	push   %ebx
  80090a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80090d:	85 c9                	test   %ecx,%ecx
  80090f:	74 36                	je     800947 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800911:	89 c8                	mov    %ecx,%eax
  800913:	0b 45 08             	or     0x8(%ebp),%eax
  800916:	a8 03                	test   $0x3,%al
  800918:	75 24                	jne    80093e <memset+0x3a>
		c &= 0xFF;
  80091a:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80091e:	89 d3                	mov    %edx,%ebx
  800920:	c1 e3 08             	shl    $0x8,%ebx
  800923:	89 d0                	mov    %edx,%eax
  800925:	c1 e0 18             	shl    $0x18,%eax
  800928:	89 d6                	mov    %edx,%esi
  80092a:	c1 e6 10             	shl    $0x10,%esi
  80092d:	09 f0                	or     %esi,%eax
  80092f:	09 d0                	or     %edx,%eax
  800931:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800933:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800936:	8b 7d 08             	mov    0x8(%ebp),%edi
  800939:	fc                   	cld    
  80093a:	f3 ab                	rep stos %eax,%es:(%edi)
  80093c:	eb 09                	jmp    800947 <memset+0x43>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80093e:	8b 7d 08             	mov    0x8(%ebp),%edi
  800941:	8b 45 0c             	mov    0xc(%ebp),%eax
  800944:	fc                   	cld    
  800945:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800947:	8b 45 08             	mov    0x8(%ebp),%eax
  80094a:	5b                   	pop    %ebx
  80094b:	5e                   	pop    %esi
  80094c:	5f                   	pop    %edi
  80094d:	5d                   	pop    %ebp
  80094e:	c3                   	ret    

0080094f <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80094f:	55                   	push   %ebp
  800950:	89 e5                	mov    %esp,%ebp
  800952:	57                   	push   %edi
  800953:	56                   	push   %esi
  800954:	8b 45 08             	mov    0x8(%ebp),%eax
  800957:	8b 75 0c             	mov    0xc(%ebp),%esi
  80095a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80095d:	39 c6                	cmp    %eax,%esi
  80095f:	73 30                	jae    800991 <memmove+0x42>
  800961:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800964:	39 c2                	cmp    %eax,%edx
  800966:	76 29                	jbe    800991 <memmove+0x42>
		s += n;
		d += n;
  800968:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80096b:	89 fe                	mov    %edi,%esi
  80096d:	09 ce                	or     %ecx,%esi
  80096f:	09 d6                	or     %edx,%esi
  800971:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800977:	75 0e                	jne    800987 <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800979:	83 ef 04             	sub    $0x4,%edi
  80097c:	8d 72 fc             	lea    -0x4(%edx),%esi
  80097f:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800982:	fd                   	std    
  800983:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800985:	eb 07                	jmp    80098e <memmove+0x3f>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800987:	4f                   	dec    %edi
  800988:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  80098b:	fd                   	std    
  80098c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80098e:	fc                   	cld    
  80098f:	eb 1a                	jmp    8009ab <memmove+0x5c>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800991:	89 c2                	mov    %eax,%edx
  800993:	09 ca                	or     %ecx,%edx
  800995:	09 f2                	or     %esi,%edx
  800997:	f6 c2 03             	test   $0x3,%dl
  80099a:	75 0a                	jne    8009a6 <memmove+0x57>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  80099c:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  80099f:	89 c7                	mov    %eax,%edi
  8009a1:	fc                   	cld    
  8009a2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009a4:	eb 05                	jmp    8009ab <memmove+0x5c>
		else
			asm volatile("cld; rep movsb\n"
  8009a6:	89 c7                	mov    %eax,%edi
  8009a8:	fc                   	cld    
  8009a9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009ab:	5e                   	pop    %esi
  8009ac:	5f                   	pop    %edi
  8009ad:	5d                   	pop    %ebp
  8009ae:	c3                   	ret    

008009af <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009af:	55                   	push   %ebp
  8009b0:	89 e5                	mov    %esp,%ebp
  8009b2:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8009b5:	ff 75 10             	pushl  0x10(%ebp)
  8009b8:	ff 75 0c             	pushl  0xc(%ebp)
  8009bb:	ff 75 08             	pushl  0x8(%ebp)
  8009be:	e8 8c ff ff ff       	call   80094f <memmove>
}
  8009c3:	c9                   	leave  
  8009c4:	c3                   	ret    

008009c5 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009c5:	55                   	push   %ebp
  8009c6:	89 e5                	mov    %esp,%ebp
  8009c8:	56                   	push   %esi
  8009c9:	53                   	push   %ebx
  8009ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8009cd:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009d0:	89 c6                	mov    %eax,%esi
  8009d2:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009d5:	39 f0                	cmp    %esi,%eax
  8009d7:	74 16                	je     8009ef <memcmp+0x2a>
		if (*s1 != *s2)
  8009d9:	8a 08                	mov    (%eax),%cl
  8009db:	8a 1a                	mov    (%edx),%bl
  8009dd:	38 d9                	cmp    %bl,%cl
  8009df:	75 04                	jne    8009e5 <memcmp+0x20>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  8009e1:	40                   	inc    %eax
  8009e2:	42                   	inc    %edx
  8009e3:	eb f0                	jmp    8009d5 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  8009e5:	0f b6 c1             	movzbl %cl,%eax
  8009e8:	0f b6 db             	movzbl %bl,%ebx
  8009eb:	29 d8                	sub    %ebx,%eax
  8009ed:	eb 05                	jmp    8009f4 <memcmp+0x2f>
	}

	return 0;
  8009ef:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009f4:	5b                   	pop    %ebx
  8009f5:	5e                   	pop    %esi
  8009f6:	5d                   	pop    %ebp
  8009f7:	c3                   	ret    

008009f8 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009f8:	55                   	push   %ebp
  8009f9:	89 e5                	mov    %esp,%ebp
  8009fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8009fe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a01:	89 c2                	mov    %eax,%edx
  800a03:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a06:	39 d0                	cmp    %edx,%eax
  800a08:	73 07                	jae    800a11 <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a0a:	38 08                	cmp    %cl,(%eax)
  800a0c:	74 03                	je     800a11 <memfind+0x19>
	for (; s < ends; s++)
  800a0e:	40                   	inc    %eax
  800a0f:	eb f5                	jmp    800a06 <memfind+0xe>
			break;
	return (void *) s;
}
  800a11:	5d                   	pop    %ebp
  800a12:	c3                   	ret    

00800a13 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a13:	55                   	push   %ebp
  800a14:	89 e5                	mov    %esp,%ebp
  800a16:	57                   	push   %edi
  800a17:	56                   	push   %esi
  800a18:	53                   	push   %ebx
  800a19:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a1c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a1f:	eb 01                	jmp    800a22 <strtol+0xf>
		s++;
  800a21:	41                   	inc    %ecx
	while (*s == ' ' || *s == '\t')
  800a22:	8a 01                	mov    (%ecx),%al
  800a24:	3c 20                	cmp    $0x20,%al
  800a26:	74 f9                	je     800a21 <strtol+0xe>
  800a28:	3c 09                	cmp    $0x9,%al
  800a2a:	74 f5                	je     800a21 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800a2c:	3c 2b                	cmp    $0x2b,%al
  800a2e:	74 24                	je     800a54 <strtol+0x41>
		s++;
	else if (*s == '-')
  800a30:	3c 2d                	cmp    $0x2d,%al
  800a32:	74 28                	je     800a5c <strtol+0x49>
	int neg = 0;
  800a34:	bf 00 00 00 00       	mov    $0x0,%edi
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a39:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a3f:	75 09                	jne    800a4a <strtol+0x37>
  800a41:	80 39 30             	cmpb   $0x30,(%ecx)
  800a44:	74 1e                	je     800a64 <strtol+0x51>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a46:	85 db                	test   %ebx,%ebx
  800a48:	74 36                	je     800a80 <strtol+0x6d>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a4a:	b8 00 00 00 00       	mov    $0x0,%eax
  800a4f:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800a52:	eb 45                	jmp    800a99 <strtol+0x86>
		s++;
  800a54:	41                   	inc    %ecx
	int neg = 0;
  800a55:	bf 00 00 00 00       	mov    $0x0,%edi
  800a5a:	eb dd                	jmp    800a39 <strtol+0x26>
		s++, neg = 1;
  800a5c:	41                   	inc    %ecx
  800a5d:	bf 01 00 00 00       	mov    $0x1,%edi
  800a62:	eb d5                	jmp    800a39 <strtol+0x26>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a64:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a68:	74 0c                	je     800a76 <strtol+0x63>
	else if (base == 0 && s[0] == '0')
  800a6a:	85 db                	test   %ebx,%ebx
  800a6c:	75 dc                	jne    800a4a <strtol+0x37>
		s++, base = 8;
  800a6e:	41                   	inc    %ecx
  800a6f:	bb 08 00 00 00       	mov    $0x8,%ebx
  800a74:	eb d4                	jmp    800a4a <strtol+0x37>
		s += 2, base = 16;
  800a76:	83 c1 02             	add    $0x2,%ecx
  800a79:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a7e:	eb ca                	jmp    800a4a <strtol+0x37>
		base = 10;
  800a80:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800a85:	eb c3                	jmp    800a4a <strtol+0x37>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800a87:	0f be d2             	movsbl %dl,%edx
  800a8a:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800a8d:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a90:	7d 37                	jge    800ac9 <strtol+0xb6>
			break;
		s++, val = (val * base) + dig;
  800a92:	41                   	inc    %ecx
  800a93:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a97:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800a99:	8a 11                	mov    (%ecx),%dl
  800a9b:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a9e:	89 f3                	mov    %esi,%ebx
  800aa0:	80 fb 09             	cmp    $0x9,%bl
  800aa3:	76 e2                	jbe    800a87 <strtol+0x74>
		else if (*s >= 'a' && *s <= 'z')
  800aa5:	8d 72 9f             	lea    -0x61(%edx),%esi
  800aa8:	89 f3                	mov    %esi,%ebx
  800aaa:	80 fb 19             	cmp    $0x19,%bl
  800aad:	77 08                	ja     800ab7 <strtol+0xa4>
			dig = *s - 'a' + 10;
  800aaf:	0f be d2             	movsbl %dl,%edx
  800ab2:	83 ea 57             	sub    $0x57,%edx
  800ab5:	eb d6                	jmp    800a8d <strtol+0x7a>
		else if (*s >= 'A' && *s <= 'Z')
  800ab7:	8d 72 bf             	lea    -0x41(%edx),%esi
  800aba:	89 f3                	mov    %esi,%ebx
  800abc:	80 fb 19             	cmp    $0x19,%bl
  800abf:	77 08                	ja     800ac9 <strtol+0xb6>
			dig = *s - 'A' + 10;
  800ac1:	0f be d2             	movsbl %dl,%edx
  800ac4:	83 ea 37             	sub    $0x37,%edx
  800ac7:	eb c4                	jmp    800a8d <strtol+0x7a>
		// we don't properly detect overflow!
	}

	if (endptr)
  800ac9:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800acd:	74 05                	je     800ad4 <strtol+0xc1>
		*endptr = (char *) s;
  800acf:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ad2:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800ad4:	85 ff                	test   %edi,%edi
  800ad6:	74 02                	je     800ada <strtol+0xc7>
  800ad8:	f7 d8                	neg    %eax
}
  800ada:	5b                   	pop    %ebx
  800adb:	5e                   	pop    %esi
  800adc:	5f                   	pop    %edi
  800add:	5d                   	pop    %ebp
  800ade:	c3                   	ret    
  800adf:	90                   	nop

00800ae0 <__udivdi3>:
  800ae0:	55                   	push   %ebp
  800ae1:	57                   	push   %edi
  800ae2:	56                   	push   %esi
  800ae3:	53                   	push   %ebx
  800ae4:	83 ec 1c             	sub    $0x1c,%esp
  800ae7:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800aeb:	8b 74 24 34          	mov    0x34(%esp),%esi
  800aef:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800af3:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800af7:	85 d2                	test   %edx,%edx
  800af9:	75 19                	jne    800b14 <__udivdi3+0x34>
  800afb:	39 f7                	cmp    %esi,%edi
  800afd:	76 45                	jbe    800b44 <__udivdi3+0x64>
  800aff:	89 e8                	mov    %ebp,%eax
  800b01:	89 f2                	mov    %esi,%edx
  800b03:	f7 f7                	div    %edi
  800b05:	31 db                	xor    %ebx,%ebx
  800b07:	89 da                	mov    %ebx,%edx
  800b09:	83 c4 1c             	add    $0x1c,%esp
  800b0c:	5b                   	pop    %ebx
  800b0d:	5e                   	pop    %esi
  800b0e:	5f                   	pop    %edi
  800b0f:	5d                   	pop    %ebp
  800b10:	c3                   	ret    
  800b11:	8d 76 00             	lea    0x0(%esi),%esi
  800b14:	39 f2                	cmp    %esi,%edx
  800b16:	76 10                	jbe    800b28 <__udivdi3+0x48>
  800b18:	31 db                	xor    %ebx,%ebx
  800b1a:	31 c0                	xor    %eax,%eax
  800b1c:	89 da                	mov    %ebx,%edx
  800b1e:	83 c4 1c             	add    $0x1c,%esp
  800b21:	5b                   	pop    %ebx
  800b22:	5e                   	pop    %esi
  800b23:	5f                   	pop    %edi
  800b24:	5d                   	pop    %ebp
  800b25:	c3                   	ret    
  800b26:	66 90                	xchg   %ax,%ax
  800b28:	0f bd da             	bsr    %edx,%ebx
  800b2b:	83 f3 1f             	xor    $0x1f,%ebx
  800b2e:	75 3c                	jne    800b6c <__udivdi3+0x8c>
  800b30:	39 f2                	cmp    %esi,%edx
  800b32:	72 08                	jb     800b3c <__udivdi3+0x5c>
  800b34:	39 ef                	cmp    %ebp,%edi
  800b36:	0f 87 9c 00 00 00    	ja     800bd8 <__udivdi3+0xf8>
  800b3c:	b8 01 00 00 00       	mov    $0x1,%eax
  800b41:	eb d9                	jmp    800b1c <__udivdi3+0x3c>
  800b43:	90                   	nop
  800b44:	89 f9                	mov    %edi,%ecx
  800b46:	85 ff                	test   %edi,%edi
  800b48:	75 0b                	jne    800b55 <__udivdi3+0x75>
  800b4a:	b8 01 00 00 00       	mov    $0x1,%eax
  800b4f:	31 d2                	xor    %edx,%edx
  800b51:	f7 f7                	div    %edi
  800b53:	89 c1                	mov    %eax,%ecx
  800b55:	31 d2                	xor    %edx,%edx
  800b57:	89 f0                	mov    %esi,%eax
  800b59:	f7 f1                	div    %ecx
  800b5b:	89 c3                	mov    %eax,%ebx
  800b5d:	89 e8                	mov    %ebp,%eax
  800b5f:	f7 f1                	div    %ecx
  800b61:	89 da                	mov    %ebx,%edx
  800b63:	83 c4 1c             	add    $0x1c,%esp
  800b66:	5b                   	pop    %ebx
  800b67:	5e                   	pop    %esi
  800b68:	5f                   	pop    %edi
  800b69:	5d                   	pop    %ebp
  800b6a:	c3                   	ret    
  800b6b:	90                   	nop
  800b6c:	b8 20 00 00 00       	mov    $0x20,%eax
  800b71:	29 d8                	sub    %ebx,%eax
  800b73:	88 d9                	mov    %bl,%cl
  800b75:	d3 e2                	shl    %cl,%edx
  800b77:	89 54 24 08          	mov    %edx,0x8(%esp)
  800b7b:	89 fa                	mov    %edi,%edx
  800b7d:	88 c1                	mov    %al,%cl
  800b7f:	d3 ea                	shr    %cl,%edx
  800b81:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800b85:	09 d1                	or     %edx,%ecx
  800b87:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800b8b:	88 d9                	mov    %bl,%cl
  800b8d:	d3 e7                	shl    %cl,%edi
  800b8f:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800b93:	89 f7                	mov    %esi,%edi
  800b95:	88 c1                	mov    %al,%cl
  800b97:	d3 ef                	shr    %cl,%edi
  800b99:	88 d9                	mov    %bl,%cl
  800b9b:	d3 e6                	shl    %cl,%esi
  800b9d:	89 ea                	mov    %ebp,%edx
  800b9f:	88 c1                	mov    %al,%cl
  800ba1:	d3 ea                	shr    %cl,%edx
  800ba3:	09 d6                	or     %edx,%esi
  800ba5:	89 f0                	mov    %esi,%eax
  800ba7:	89 fa                	mov    %edi,%edx
  800ba9:	f7 74 24 08          	divl   0x8(%esp)
  800bad:	89 d7                	mov    %edx,%edi
  800baf:	89 c6                	mov    %eax,%esi
  800bb1:	f7 64 24 0c          	mull   0xc(%esp)
  800bb5:	39 d7                	cmp    %edx,%edi
  800bb7:	72 13                	jb     800bcc <__udivdi3+0xec>
  800bb9:	74 09                	je     800bc4 <__udivdi3+0xe4>
  800bbb:	89 f0                	mov    %esi,%eax
  800bbd:	31 db                	xor    %ebx,%ebx
  800bbf:	e9 58 ff ff ff       	jmp    800b1c <__udivdi3+0x3c>
  800bc4:	88 d9                	mov    %bl,%cl
  800bc6:	d3 e5                	shl    %cl,%ebp
  800bc8:	39 c5                	cmp    %eax,%ebp
  800bca:	73 ef                	jae    800bbb <__udivdi3+0xdb>
  800bcc:	8d 46 ff             	lea    -0x1(%esi),%eax
  800bcf:	31 db                	xor    %ebx,%ebx
  800bd1:	e9 46 ff ff ff       	jmp    800b1c <__udivdi3+0x3c>
  800bd6:	66 90                	xchg   %ax,%ax
  800bd8:	31 c0                	xor    %eax,%eax
  800bda:	e9 3d ff ff ff       	jmp    800b1c <__udivdi3+0x3c>
  800bdf:	90                   	nop

00800be0 <__umoddi3>:
  800be0:	55                   	push   %ebp
  800be1:	57                   	push   %edi
  800be2:	56                   	push   %esi
  800be3:	53                   	push   %ebx
  800be4:	83 ec 1c             	sub    $0x1c,%esp
  800be7:	8b 74 24 30          	mov    0x30(%esp),%esi
  800beb:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800bef:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800bf3:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  800bf7:	85 c0                	test   %eax,%eax
  800bf9:	75 19                	jne    800c14 <__umoddi3+0x34>
  800bfb:	39 df                	cmp    %ebx,%edi
  800bfd:	76 51                	jbe    800c50 <__umoddi3+0x70>
  800bff:	89 f0                	mov    %esi,%eax
  800c01:	89 da                	mov    %ebx,%edx
  800c03:	f7 f7                	div    %edi
  800c05:	89 d0                	mov    %edx,%eax
  800c07:	31 d2                	xor    %edx,%edx
  800c09:	83 c4 1c             	add    $0x1c,%esp
  800c0c:	5b                   	pop    %ebx
  800c0d:	5e                   	pop    %esi
  800c0e:	5f                   	pop    %edi
  800c0f:	5d                   	pop    %ebp
  800c10:	c3                   	ret    
  800c11:	8d 76 00             	lea    0x0(%esi),%esi
  800c14:	89 f2                	mov    %esi,%edx
  800c16:	39 d8                	cmp    %ebx,%eax
  800c18:	76 0e                	jbe    800c28 <__umoddi3+0x48>
  800c1a:	89 f0                	mov    %esi,%eax
  800c1c:	89 da                	mov    %ebx,%edx
  800c1e:	83 c4 1c             	add    $0x1c,%esp
  800c21:	5b                   	pop    %ebx
  800c22:	5e                   	pop    %esi
  800c23:	5f                   	pop    %edi
  800c24:	5d                   	pop    %ebp
  800c25:	c3                   	ret    
  800c26:	66 90                	xchg   %ax,%ax
  800c28:	0f bd e8             	bsr    %eax,%ebp
  800c2b:	83 f5 1f             	xor    $0x1f,%ebp
  800c2e:	75 44                	jne    800c74 <__umoddi3+0x94>
  800c30:	39 d8                	cmp    %ebx,%eax
  800c32:	72 06                	jb     800c3a <__umoddi3+0x5a>
  800c34:	89 d9                	mov    %ebx,%ecx
  800c36:	39 f7                	cmp    %esi,%edi
  800c38:	77 08                	ja     800c42 <__umoddi3+0x62>
  800c3a:	29 fe                	sub    %edi,%esi
  800c3c:	19 c3                	sbb    %eax,%ebx
  800c3e:	89 f2                	mov    %esi,%edx
  800c40:	89 d9                	mov    %ebx,%ecx
  800c42:	89 d0                	mov    %edx,%eax
  800c44:	89 ca                	mov    %ecx,%edx
  800c46:	83 c4 1c             	add    $0x1c,%esp
  800c49:	5b                   	pop    %ebx
  800c4a:	5e                   	pop    %esi
  800c4b:	5f                   	pop    %edi
  800c4c:	5d                   	pop    %ebp
  800c4d:	c3                   	ret    
  800c4e:	66 90                	xchg   %ax,%ax
  800c50:	89 fd                	mov    %edi,%ebp
  800c52:	85 ff                	test   %edi,%edi
  800c54:	75 0b                	jne    800c61 <__umoddi3+0x81>
  800c56:	b8 01 00 00 00       	mov    $0x1,%eax
  800c5b:	31 d2                	xor    %edx,%edx
  800c5d:	f7 f7                	div    %edi
  800c5f:	89 c5                	mov    %eax,%ebp
  800c61:	89 d8                	mov    %ebx,%eax
  800c63:	31 d2                	xor    %edx,%edx
  800c65:	f7 f5                	div    %ebp
  800c67:	89 f0                	mov    %esi,%eax
  800c69:	f7 f5                	div    %ebp
  800c6b:	89 d0                	mov    %edx,%eax
  800c6d:	31 d2                	xor    %edx,%edx
  800c6f:	eb 98                	jmp    800c09 <__umoddi3+0x29>
  800c71:	8d 76 00             	lea    0x0(%esi),%esi
  800c74:	ba 20 00 00 00       	mov    $0x20,%edx
  800c79:	29 ea                	sub    %ebp,%edx
  800c7b:	89 e9                	mov    %ebp,%ecx
  800c7d:	d3 e0                	shl    %cl,%eax
  800c7f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c83:	89 f8                	mov    %edi,%eax
  800c85:	89 54 24 04          	mov    %edx,0x4(%esp)
  800c89:	88 d1                	mov    %dl,%cl
  800c8b:	d3 e8                	shr    %cl,%eax
  800c8d:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800c91:	09 c1                	or     %eax,%ecx
  800c93:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800c97:	89 e9                	mov    %ebp,%ecx
  800c99:	d3 e7                	shl    %cl,%edi
  800c9b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800c9f:	89 d8                	mov    %ebx,%eax
  800ca1:	8b 54 24 04          	mov    0x4(%esp),%edx
  800ca5:	88 d1                	mov    %dl,%cl
  800ca7:	d3 e8                	shr    %cl,%eax
  800ca9:	89 c7                	mov    %eax,%edi
  800cab:	89 e9                	mov    %ebp,%ecx
  800cad:	d3 e3                	shl    %cl,%ebx
  800caf:	89 f0                	mov    %esi,%eax
  800cb1:	88 d1                	mov    %dl,%cl
  800cb3:	d3 e8                	shr    %cl,%eax
  800cb5:	09 d8                	or     %ebx,%eax
  800cb7:	89 e9                	mov    %ebp,%ecx
  800cb9:	d3 e6                	shl    %cl,%esi
  800cbb:	89 f3                	mov    %esi,%ebx
  800cbd:	89 fa                	mov    %edi,%edx
  800cbf:	f7 74 24 08          	divl   0x8(%esp)
  800cc3:	89 d1                	mov    %edx,%ecx
  800cc5:	f7 64 24 0c          	mull   0xc(%esp)
  800cc9:	89 c6                	mov    %eax,%esi
  800ccb:	89 d7                	mov    %edx,%edi
  800ccd:	39 d1                	cmp    %edx,%ecx
  800ccf:	72 27                	jb     800cf8 <__umoddi3+0x118>
  800cd1:	74 21                	je     800cf4 <__umoddi3+0x114>
  800cd3:	89 ca                	mov    %ecx,%edx
  800cd5:	29 f3                	sub    %esi,%ebx
  800cd7:	19 fa                	sbb    %edi,%edx
  800cd9:	89 d0                	mov    %edx,%eax
  800cdb:	8a 4c 24 04          	mov    0x4(%esp),%cl
  800cdf:	d3 e0                	shl    %cl,%eax
  800ce1:	89 e9                	mov    %ebp,%ecx
  800ce3:	d3 eb                	shr    %cl,%ebx
  800ce5:	09 d8                	or     %ebx,%eax
  800ce7:	d3 ea                	shr    %cl,%edx
  800ce9:	83 c4 1c             	add    $0x1c,%esp
  800cec:	5b                   	pop    %ebx
  800ced:	5e                   	pop    %esi
  800cee:	5f                   	pop    %edi
  800cef:	5d                   	pop    %ebp
  800cf0:	c3                   	ret    
  800cf1:	8d 76 00             	lea    0x0(%esi),%esi
  800cf4:	39 c3                	cmp    %eax,%ebx
  800cf6:	73 db                	jae    800cd3 <__umoddi3+0xf3>
  800cf8:	2b 44 24 0c          	sub    0xc(%esp),%eax
  800cfc:	1b 54 24 08          	sbb    0x8(%esp),%edx
  800d00:	89 d7                	mov    %edx,%edi
  800d02:	89 c6                	mov    %eax,%esi
  800d04:	eb cd                	jmp    800cd3 <__umoddi3+0xf3>
