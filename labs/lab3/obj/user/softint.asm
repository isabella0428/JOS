
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
  800039:	83 ec 08             	sub    $0x8,%esp
  80003c:	8b 45 08             	mov    0x8(%ebp),%eax
  80003f:	8b 55 0c             	mov    0xc(%ebp),%edx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  800042:	c7 05 04 10 80 00 00 	movl   $0x0,0x801004
  800049:	00 00 00 

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80004c:	85 c0                	test   %eax,%eax
  80004e:	7e 08                	jle    800058 <libmain+0x22>
		binaryname = argv[0];
  800050:	8b 0a                	mov    (%edx),%ecx
  800052:	89 0d 00 10 80 00    	mov    %ecx,0x801000

	// call user main routine
	umain(argc, argv);
  800058:	83 ec 08             	sub    $0x8,%esp
  80005b:	52                   	push   %edx
  80005c:	50                   	push   %eax
  80005d:	e8 d1 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800062:	e8 05 00 00 00       	call   80006c <exit>
}
  800067:	83 c4 10             	add    $0x10,%esp
  80006a:	c9                   	leave  
  80006b:	c3                   	ret    

0080006c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80006c:	55                   	push   %ebp
  80006d:	89 e5                	mov    %esp,%ebp
  80006f:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800072:	6a 00                	push   $0x0
  800074:	e8 42 00 00 00       	call   8000bb <sys_env_destroy>
}
  800079:	83 c4 10             	add    $0x10,%esp
  80007c:	c9                   	leave  
  80007d:	c3                   	ret    

0080007e <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  80007e:	55                   	push   %ebp
  80007f:	89 e5                	mov    %esp,%ebp
  800081:	57                   	push   %edi
  800082:	56                   	push   %esi
  800083:	53                   	push   %ebx
	asm volatile("int %1\n"
  800084:	b8 00 00 00 00       	mov    $0x0,%eax
  800089:	8b 55 08             	mov    0x8(%ebp),%edx
  80008c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80008f:	89 c3                	mov    %eax,%ebx
  800091:	89 c7                	mov    %eax,%edi
  800093:	89 c6                	mov    %eax,%esi
  800095:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800097:	5b                   	pop    %ebx
  800098:	5e                   	pop    %esi
  800099:	5f                   	pop    %edi
  80009a:	5d                   	pop    %ebp
  80009b:	c3                   	ret    

0080009c <sys_cgetc>:

int
sys_cgetc(void)
{
  80009c:	55                   	push   %ebp
  80009d:	89 e5                	mov    %esp,%ebp
  80009f:	57                   	push   %edi
  8000a0:	56                   	push   %esi
  8000a1:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000a2:	ba 00 00 00 00       	mov    $0x0,%edx
  8000a7:	b8 01 00 00 00       	mov    $0x1,%eax
  8000ac:	89 d1                	mov    %edx,%ecx
  8000ae:	89 d3                	mov    %edx,%ebx
  8000b0:	89 d7                	mov    %edx,%edi
  8000b2:	89 d6                	mov    %edx,%esi
  8000b4:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000b6:	5b                   	pop    %ebx
  8000b7:	5e                   	pop    %esi
  8000b8:	5f                   	pop    %edi
  8000b9:	5d                   	pop    %ebp
  8000ba:	c3                   	ret    

008000bb <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000bb:	55                   	push   %ebp
  8000bc:	89 e5                	mov    %esp,%ebp
  8000be:	57                   	push   %edi
  8000bf:	56                   	push   %esi
  8000c0:	53                   	push   %ebx
  8000c1:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8000c4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000c9:	8b 55 08             	mov    0x8(%ebp),%edx
  8000cc:	b8 03 00 00 00       	mov    $0x3,%eax
  8000d1:	89 cb                	mov    %ecx,%ebx
  8000d3:	89 cf                	mov    %ecx,%edi
  8000d5:	89 ce                	mov    %ecx,%esi
  8000d7:	cd 30                	int    $0x30
	if(check && ret > 0)
  8000d9:	85 c0                	test   %eax,%eax
  8000db:	7f 08                	jg     8000e5 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  8000dd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000e0:	5b                   	pop    %ebx
  8000e1:	5e                   	pop    %esi
  8000e2:	5f                   	pop    %edi
  8000e3:	5d                   	pop    %ebp
  8000e4:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8000e5:	83 ec 0c             	sub    $0xc,%esp
  8000e8:	50                   	push   %eax
  8000e9:	6a 03                	push   $0x3
  8000eb:	68 e2 0c 80 00       	push   $0x800ce2
  8000f0:	6a 23                	push   $0x23
  8000f2:	68 ff 0c 80 00       	push   $0x800cff
  8000f7:	e8 1f 00 00 00       	call   80011b <_panic>

008000fc <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  8000fc:	55                   	push   %ebp
  8000fd:	89 e5                	mov    %esp,%ebp
  8000ff:	57                   	push   %edi
  800100:	56                   	push   %esi
  800101:	53                   	push   %ebx
	asm volatile("int %1\n"
  800102:	ba 00 00 00 00       	mov    $0x0,%edx
  800107:	b8 02 00 00 00       	mov    $0x2,%eax
  80010c:	89 d1                	mov    %edx,%ecx
  80010e:	89 d3                	mov    %edx,%ebx
  800110:	89 d7                	mov    %edx,%edi
  800112:	89 d6                	mov    %edx,%esi
  800114:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800116:	5b                   	pop    %ebx
  800117:	5e                   	pop    %esi
  800118:	5f                   	pop    %edi
  800119:	5d                   	pop    %ebp
  80011a:	c3                   	ret    

0080011b <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80011b:	55                   	push   %ebp
  80011c:	89 e5                	mov    %esp,%ebp
  80011e:	56                   	push   %esi
  80011f:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800120:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800123:	8b 35 00 10 80 00    	mov    0x801000,%esi
  800129:	e8 ce ff ff ff       	call   8000fc <sys_getenvid>
  80012e:	83 ec 0c             	sub    $0xc,%esp
  800131:	ff 75 0c             	pushl  0xc(%ebp)
  800134:	ff 75 08             	pushl  0x8(%ebp)
  800137:	56                   	push   %esi
  800138:	50                   	push   %eax
  800139:	68 10 0d 80 00       	push   $0x800d10
  80013e:	e8 b2 00 00 00       	call   8001f5 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800143:	83 c4 18             	add    $0x18,%esp
  800146:	53                   	push   %ebx
  800147:	ff 75 10             	pushl  0x10(%ebp)
  80014a:	e8 55 00 00 00       	call   8001a4 <vcprintf>
	cprintf("\n");
  80014f:	c7 04 24 34 0d 80 00 	movl   $0x800d34,(%esp)
  800156:	e8 9a 00 00 00       	call   8001f5 <cprintf>
  80015b:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80015e:	cc                   	int3   
  80015f:	eb fd                	jmp    80015e <_panic+0x43>

00800161 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800161:	55                   	push   %ebp
  800162:	89 e5                	mov    %esp,%ebp
  800164:	53                   	push   %ebx
  800165:	83 ec 04             	sub    $0x4,%esp
  800168:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80016b:	8b 13                	mov    (%ebx),%edx
  80016d:	8d 42 01             	lea    0x1(%edx),%eax
  800170:	89 03                	mov    %eax,(%ebx)
  800172:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800175:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800179:	3d ff 00 00 00       	cmp    $0xff,%eax
  80017e:	74 08                	je     800188 <putch+0x27>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800180:	ff 43 04             	incl   0x4(%ebx)
}
  800183:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800186:	c9                   	leave  
  800187:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800188:	83 ec 08             	sub    $0x8,%esp
  80018b:	68 ff 00 00 00       	push   $0xff
  800190:	8d 43 08             	lea    0x8(%ebx),%eax
  800193:	50                   	push   %eax
  800194:	e8 e5 fe ff ff       	call   80007e <sys_cputs>
		b->idx = 0;
  800199:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80019f:	83 c4 10             	add    $0x10,%esp
  8001a2:	eb dc                	jmp    800180 <putch+0x1f>

008001a4 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001a4:	55                   	push   %ebp
  8001a5:	89 e5                	mov    %esp,%ebp
  8001a7:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001ad:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001b4:	00 00 00 
	b.cnt = 0;
  8001b7:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001be:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001c1:	ff 75 0c             	pushl  0xc(%ebp)
  8001c4:	ff 75 08             	pushl  0x8(%ebp)
  8001c7:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001cd:	50                   	push   %eax
  8001ce:	68 61 01 80 00       	push   $0x800161
  8001d3:	e8 0f 01 00 00       	call   8002e7 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001d8:	83 c4 08             	add    $0x8,%esp
  8001db:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001e1:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001e7:	50                   	push   %eax
  8001e8:	e8 91 fe ff ff       	call   80007e <sys_cputs>

	return b.cnt;
}
  8001ed:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001f3:	c9                   	leave  
  8001f4:	c3                   	ret    

008001f5 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001f5:	55                   	push   %ebp
  8001f6:	89 e5                	mov    %esp,%ebp
  8001f8:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001fb:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001fe:	50                   	push   %eax
  8001ff:	ff 75 08             	pushl  0x8(%ebp)
  800202:	e8 9d ff ff ff       	call   8001a4 <vcprintf>
	va_end(ap);

	return cnt;
}
  800207:	c9                   	leave  
  800208:	c3                   	ret    

00800209 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800209:	55                   	push   %ebp
  80020a:	89 e5                	mov    %esp,%ebp
  80020c:	57                   	push   %edi
  80020d:	56                   	push   %esi
  80020e:	53                   	push   %ebx
  80020f:	83 ec 1c             	sub    $0x1c,%esp
  800212:	89 c7                	mov    %eax,%edi
  800214:	89 d6                	mov    %edx,%esi
  800216:	8b 45 08             	mov    0x8(%ebp),%eax
  800219:	8b 55 0c             	mov    0xc(%ebp),%edx
  80021c:	89 d1                	mov    %edx,%ecx
  80021e:	89 c2                	mov    %eax,%edx
  800220:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800223:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800226:	8b 45 10             	mov    0x10(%ebp),%eax
  800229:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80022c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80022f:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800236:	39 c2                	cmp    %eax,%edx
  800238:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  80023b:	72 3c                	jb     800279 <printnum+0x70>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80023d:	83 ec 0c             	sub    $0xc,%esp
  800240:	ff 75 18             	pushl  0x18(%ebp)
  800243:	4b                   	dec    %ebx
  800244:	53                   	push   %ebx
  800245:	50                   	push   %eax
  800246:	83 ec 08             	sub    $0x8,%esp
  800249:	ff 75 e4             	pushl  -0x1c(%ebp)
  80024c:	ff 75 e0             	pushl  -0x20(%ebp)
  80024f:	ff 75 dc             	pushl  -0x24(%ebp)
  800252:	ff 75 d8             	pushl  -0x28(%ebp)
  800255:	e8 56 08 00 00       	call   800ab0 <__udivdi3>
  80025a:	83 c4 18             	add    $0x18,%esp
  80025d:	52                   	push   %edx
  80025e:	50                   	push   %eax
  80025f:	89 f2                	mov    %esi,%edx
  800261:	89 f8                	mov    %edi,%eax
  800263:	e8 a1 ff ff ff       	call   800209 <printnum>
  800268:	83 c4 20             	add    $0x20,%esp
  80026b:	eb 11                	jmp    80027e <printnum+0x75>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80026d:	83 ec 08             	sub    $0x8,%esp
  800270:	56                   	push   %esi
  800271:	ff 75 18             	pushl  0x18(%ebp)
  800274:	ff d7                	call   *%edi
  800276:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800279:	4b                   	dec    %ebx
  80027a:	85 db                	test   %ebx,%ebx
  80027c:	7f ef                	jg     80026d <printnum+0x64>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80027e:	83 ec 08             	sub    $0x8,%esp
  800281:	56                   	push   %esi
  800282:	83 ec 04             	sub    $0x4,%esp
  800285:	ff 75 e4             	pushl  -0x1c(%ebp)
  800288:	ff 75 e0             	pushl  -0x20(%ebp)
  80028b:	ff 75 dc             	pushl  -0x24(%ebp)
  80028e:	ff 75 d8             	pushl  -0x28(%ebp)
  800291:	e8 1a 09 00 00       	call   800bb0 <__umoddi3>
  800296:	83 c4 14             	add    $0x14,%esp
  800299:	0f be 80 36 0d 80 00 	movsbl 0x800d36(%eax),%eax
  8002a0:	50                   	push   %eax
  8002a1:	ff d7                	call   *%edi
}
  8002a3:	83 c4 10             	add    $0x10,%esp
  8002a6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002a9:	5b                   	pop    %ebx
  8002aa:	5e                   	pop    %esi
  8002ab:	5f                   	pop    %edi
  8002ac:	5d                   	pop    %ebp
  8002ad:	c3                   	ret    

008002ae <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002ae:	55                   	push   %ebp
  8002af:	89 e5                	mov    %esp,%ebp
  8002b1:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002b4:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8002b7:	8b 10                	mov    (%eax),%edx
  8002b9:	3b 50 04             	cmp    0x4(%eax),%edx
  8002bc:	73 0a                	jae    8002c8 <sprintputch+0x1a>
		*b->buf++ = ch;
  8002be:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002c1:	89 08                	mov    %ecx,(%eax)
  8002c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8002c6:	88 02                	mov    %al,(%edx)
}
  8002c8:	5d                   	pop    %ebp
  8002c9:	c3                   	ret    

008002ca <printfmt>:
{
  8002ca:	55                   	push   %ebp
  8002cb:	89 e5                	mov    %esp,%ebp
  8002cd:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8002d0:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002d3:	50                   	push   %eax
  8002d4:	ff 75 10             	pushl  0x10(%ebp)
  8002d7:	ff 75 0c             	pushl  0xc(%ebp)
  8002da:	ff 75 08             	pushl  0x8(%ebp)
  8002dd:	e8 05 00 00 00       	call   8002e7 <vprintfmt>
}
  8002e2:	83 c4 10             	add    $0x10,%esp
  8002e5:	c9                   	leave  
  8002e6:	c3                   	ret    

008002e7 <vprintfmt>:
{
  8002e7:	55                   	push   %ebp
  8002e8:	89 e5                	mov    %esp,%ebp
  8002ea:	57                   	push   %edi
  8002eb:	56                   	push   %esi
  8002ec:	53                   	push   %ebx
  8002ed:	83 ec 3c             	sub    $0x3c,%esp
  8002f0:	8b 75 08             	mov    0x8(%ebp),%esi
  8002f3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002f6:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002f9:	e9 5b 03 00 00       	jmp    800659 <vprintfmt+0x372>
		padc = ' ';
  8002fe:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  800302:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
		precision = -1;
  800309:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  800310:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		lflag = 0;
  800317:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80031c:	8d 47 01             	lea    0x1(%edi),%eax
  80031f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800322:	8a 17                	mov    (%edi),%dl
  800324:	8d 42 dd             	lea    -0x23(%edx),%eax
  800327:	3c 55                	cmp    $0x55,%al
  800329:	0f 87 ab 03 00 00    	ja     8006da <vprintfmt+0x3f3>
  80032f:	0f b6 c0             	movzbl %al,%eax
  800332:	ff 24 85 c4 0d 80 00 	jmp    *0x800dc4(,%eax,4)
  800339:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  80033c:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  800340:	eb da                	jmp    80031c <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  800342:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800345:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  800349:	eb d1                	jmp    80031c <vprintfmt+0x35>
  80034b:	0f b6 d2             	movzbl %dl,%edx
  80034e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800351:	b8 00 00 00 00       	mov    $0x0,%eax
  800356:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800359:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80035c:	01 c0                	add    %eax,%eax
  80035e:	8d 44 02 d0          	lea    -0x30(%edx,%eax,1),%eax
				ch = *fmt;
  800362:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800365:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800368:	83 f9 09             	cmp    $0x9,%ecx
  80036b:	77 52                	ja     8003bf <vprintfmt+0xd8>
			for (precision = 0; ; ++fmt) {
  80036d:	47                   	inc    %edi
				precision = precision * 10 + ch - '0';
  80036e:	eb e9                	jmp    800359 <vprintfmt+0x72>
			precision = va_arg(ap, int);
  800370:	8b 45 14             	mov    0x14(%ebp),%eax
  800373:	8b 00                	mov    (%eax),%eax
  800375:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800378:	8b 45 14             	mov    0x14(%ebp),%eax
  80037b:	8d 40 04             	lea    0x4(%eax),%eax
  80037e:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800381:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800384:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800388:	79 92                	jns    80031c <vprintfmt+0x35>
				width = precision, precision = -1;
  80038a:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80038d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800390:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  800397:	eb 83                	jmp    80031c <vprintfmt+0x35>
  800399:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80039d:	78 08                	js     8003a7 <vprintfmt+0xc0>
		switch (ch = *(unsigned char *) fmt++) {
  80039f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8003a2:	e9 75 ff ff ff       	jmp    80031c <vprintfmt+0x35>
  8003a7:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  8003ae:	eb ef                	jmp    80039f <vprintfmt+0xb8>
		switch (ch = *(unsigned char *) fmt++) {
  8003b0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8003b3:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  8003ba:	e9 5d ff ff ff       	jmp    80031c <vprintfmt+0x35>
  8003bf:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8003c2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003c5:	eb bd                	jmp    800384 <vprintfmt+0x9d>
			lflag++;
  8003c7:	41                   	inc    %ecx
		switch (ch = *(unsigned char *) fmt++) {
  8003c8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8003cb:	e9 4c ff ff ff       	jmp    80031c <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
  8003d0:	8b 45 14             	mov    0x14(%ebp),%eax
  8003d3:	8d 78 04             	lea    0x4(%eax),%edi
  8003d6:	83 ec 08             	sub    $0x8,%esp
  8003d9:	53                   	push   %ebx
  8003da:	ff 30                	pushl  (%eax)
  8003dc:	ff d6                	call   *%esi
			break;
  8003de:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8003e1:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8003e4:	e9 6d 02 00 00       	jmp    800656 <vprintfmt+0x36f>
			err = va_arg(ap, int);
  8003e9:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ec:	8d 78 04             	lea    0x4(%eax),%edi
  8003ef:	8b 00                	mov    (%eax),%eax
  8003f1:	85 c0                	test   %eax,%eax
  8003f3:	78 2a                	js     80041f <vprintfmt+0x138>
  8003f5:	89 c2                	mov    %eax,%edx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003f7:	83 f8 06             	cmp    $0x6,%eax
  8003fa:	7f 27                	jg     800423 <vprintfmt+0x13c>
  8003fc:	8b 04 85 1c 0f 80 00 	mov    0x800f1c(,%eax,4),%eax
  800403:	85 c0                	test   %eax,%eax
  800405:	74 1c                	je     800423 <vprintfmt+0x13c>
				printfmt(putch, putdat, "%s", p);
  800407:	50                   	push   %eax
  800408:	68 57 0d 80 00       	push   $0x800d57
  80040d:	53                   	push   %ebx
  80040e:	56                   	push   %esi
  80040f:	e8 b6 fe ff ff       	call   8002ca <printfmt>
  800414:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800417:	89 7d 14             	mov    %edi,0x14(%ebp)
  80041a:	e9 37 02 00 00       	jmp    800656 <vprintfmt+0x36f>
  80041f:	f7 d8                	neg    %eax
  800421:	eb d2                	jmp    8003f5 <vprintfmt+0x10e>
				printfmt(putch, putdat, "error %d", err);
  800423:	52                   	push   %edx
  800424:	68 4e 0d 80 00       	push   $0x800d4e
  800429:	53                   	push   %ebx
  80042a:	56                   	push   %esi
  80042b:	e8 9a fe ff ff       	call   8002ca <printfmt>
  800430:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800433:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800436:	e9 1b 02 00 00       	jmp    800656 <vprintfmt+0x36f>
			if ((p = va_arg(ap, char *)) == NULL)
  80043b:	8b 45 14             	mov    0x14(%ebp),%eax
  80043e:	83 c0 04             	add    $0x4,%eax
  800441:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800444:	8b 45 14             	mov    0x14(%ebp),%eax
  800447:	8b 00                	mov    (%eax),%eax
  800449:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80044c:	85 c0                	test   %eax,%eax
  80044e:	74 19                	je     800469 <vprintfmt+0x182>
			if (width > 0 && padc != '-')
  800450:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800454:	7e 06                	jle    80045c <vprintfmt+0x175>
  800456:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  80045a:	75 16                	jne    800472 <vprintfmt+0x18b>
				for (width -= strnlen(p, precision); width > 0; width--)
  80045c:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80045f:	89 c7                	mov    %eax,%edi
  800461:	03 45 d4             	add    -0x2c(%ebp),%eax
  800464:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800467:	eb 62                	jmp    8004cb <vprintfmt+0x1e4>
				p = "(null)";
  800469:	c7 45 cc 47 0d 80 00 	movl   $0x800d47,-0x34(%ebp)
  800470:	eb de                	jmp    800450 <vprintfmt+0x169>
				for (width -= strnlen(p, precision); width > 0; width--)
  800472:	83 ec 08             	sub    $0x8,%esp
  800475:	ff 75 d8             	pushl  -0x28(%ebp)
  800478:	ff 75 cc             	pushl  -0x34(%ebp)
  80047b:	e8 05 03 00 00       	call   800785 <strnlen>
  800480:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800483:	29 c2                	sub    %eax,%edx
  800485:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  800488:	83 c4 10             	add    $0x10,%esp
  80048b:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  80048d:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  800491:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  800494:	eb 0d                	jmp    8004a3 <vprintfmt+0x1bc>
					putch(padc, putdat);
  800496:	83 ec 08             	sub    $0x8,%esp
  800499:	53                   	push   %ebx
  80049a:	ff 75 d4             	pushl  -0x2c(%ebp)
  80049d:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  80049f:	4f                   	dec    %edi
  8004a0:	83 c4 10             	add    $0x10,%esp
  8004a3:	85 ff                	test   %edi,%edi
  8004a5:	7f ef                	jg     800496 <vprintfmt+0x1af>
  8004a7:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8004aa:	89 d0                	mov    %edx,%eax
  8004ac:	85 d2                	test   %edx,%edx
  8004ae:	78 0a                	js     8004ba <vprintfmt+0x1d3>
  8004b0:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8004b3:	29 c2                	sub    %eax,%edx
  8004b5:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8004b8:	eb a2                	jmp    80045c <vprintfmt+0x175>
  8004ba:	b8 00 00 00 00       	mov    $0x0,%eax
  8004bf:	eb ef                	jmp    8004b0 <vprintfmt+0x1c9>
					putch(ch, putdat);
  8004c1:	83 ec 08             	sub    $0x8,%esp
  8004c4:	53                   	push   %ebx
  8004c5:	52                   	push   %edx
  8004c6:	ff d6                	call   *%esi
  8004c8:	83 c4 10             	add    $0x10,%esp
  8004cb:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  8004ce:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004d0:	47                   	inc    %edi
  8004d1:	8a 47 ff             	mov    -0x1(%edi),%al
  8004d4:	0f be d0             	movsbl %al,%edx
  8004d7:	85 d2                	test   %edx,%edx
  8004d9:	74 48                	je     800523 <vprintfmt+0x23c>
  8004db:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004df:	78 05                	js     8004e6 <vprintfmt+0x1ff>
  8004e1:	ff 4d d8             	decl   -0x28(%ebp)
  8004e4:	78 1e                	js     800504 <vprintfmt+0x21d>
				if (altflag && (ch < ' ' || ch > '~'))
  8004e6:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004ea:	74 d5                	je     8004c1 <vprintfmt+0x1da>
  8004ec:	0f be c0             	movsbl %al,%eax
  8004ef:	83 e8 20             	sub    $0x20,%eax
  8004f2:	83 f8 5e             	cmp    $0x5e,%eax
  8004f5:	76 ca                	jbe    8004c1 <vprintfmt+0x1da>
					putch('?', putdat);
  8004f7:	83 ec 08             	sub    $0x8,%esp
  8004fa:	53                   	push   %ebx
  8004fb:	6a 3f                	push   $0x3f
  8004fd:	ff d6                	call   *%esi
  8004ff:	83 c4 10             	add    $0x10,%esp
  800502:	eb c7                	jmp    8004cb <vprintfmt+0x1e4>
  800504:	89 cf                	mov    %ecx,%edi
  800506:	eb 0c                	jmp    800514 <vprintfmt+0x22d>
				putch(' ', putdat);
  800508:	83 ec 08             	sub    $0x8,%esp
  80050b:	53                   	push   %ebx
  80050c:	6a 20                	push   $0x20
  80050e:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800510:	4f                   	dec    %edi
  800511:	83 c4 10             	add    $0x10,%esp
  800514:	85 ff                	test   %edi,%edi
  800516:	7f f0                	jg     800508 <vprintfmt+0x221>
			if ((p = va_arg(ap, char *)) == NULL)
  800518:	8b 45 c8             	mov    -0x38(%ebp),%eax
  80051b:	89 45 14             	mov    %eax,0x14(%ebp)
  80051e:	e9 33 01 00 00       	jmp    800656 <vprintfmt+0x36f>
  800523:	89 cf                	mov    %ecx,%edi
  800525:	eb ed                	jmp    800514 <vprintfmt+0x22d>
	if (lflag >= 2)
  800527:	83 f9 01             	cmp    $0x1,%ecx
  80052a:	7f 1b                	jg     800547 <vprintfmt+0x260>
	else if (lflag)
  80052c:	85 c9                	test   %ecx,%ecx
  80052e:	74 42                	je     800572 <vprintfmt+0x28b>
		return va_arg(*ap, long);
  800530:	8b 45 14             	mov    0x14(%ebp),%eax
  800533:	8b 00                	mov    (%eax),%eax
  800535:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800538:	99                   	cltd   
  800539:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80053c:	8b 45 14             	mov    0x14(%ebp),%eax
  80053f:	8d 40 04             	lea    0x4(%eax),%eax
  800542:	89 45 14             	mov    %eax,0x14(%ebp)
  800545:	eb 17                	jmp    80055e <vprintfmt+0x277>
		return va_arg(*ap, long long);
  800547:	8b 45 14             	mov    0x14(%ebp),%eax
  80054a:	8b 50 04             	mov    0x4(%eax),%edx
  80054d:	8b 00                	mov    (%eax),%eax
  80054f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800552:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800555:	8b 45 14             	mov    0x14(%ebp),%eax
  800558:	8d 40 08             	lea    0x8(%eax),%eax
  80055b:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  80055e:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800561:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800564:	85 c9                	test   %ecx,%ecx
  800566:	78 21                	js     800589 <vprintfmt+0x2a2>
			base = 10;
  800568:	b8 0a 00 00 00       	mov    $0xa,%eax
  80056d:	e9 ca 00 00 00       	jmp    80063c <vprintfmt+0x355>
		return va_arg(*ap, int);
  800572:	8b 45 14             	mov    0x14(%ebp),%eax
  800575:	8b 00                	mov    (%eax),%eax
  800577:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80057a:	99                   	cltd   
  80057b:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80057e:	8b 45 14             	mov    0x14(%ebp),%eax
  800581:	8d 40 04             	lea    0x4(%eax),%eax
  800584:	89 45 14             	mov    %eax,0x14(%ebp)
  800587:	eb d5                	jmp    80055e <vprintfmt+0x277>
				putch('-', putdat);
  800589:	83 ec 08             	sub    $0x8,%esp
  80058c:	53                   	push   %ebx
  80058d:	6a 2d                	push   $0x2d
  80058f:	ff d6                	call   *%esi
				num = -(long long) num;
  800591:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800594:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800597:	f7 da                	neg    %edx
  800599:	83 d1 00             	adc    $0x0,%ecx
  80059c:	f7 d9                	neg    %ecx
  80059e:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8005a1:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005a6:	e9 91 00 00 00       	jmp    80063c <vprintfmt+0x355>
	if (lflag >= 2)
  8005ab:	83 f9 01             	cmp    $0x1,%ecx
  8005ae:	7f 1b                	jg     8005cb <vprintfmt+0x2e4>
	else if (lflag)
  8005b0:	85 c9                	test   %ecx,%ecx
  8005b2:	74 2c                	je     8005e0 <vprintfmt+0x2f9>
		return va_arg(*ap, unsigned long);
  8005b4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b7:	8b 10                	mov    (%eax),%edx
  8005b9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005be:	8d 40 04             	lea    0x4(%eax),%eax
  8005c1:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005c4:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  8005c9:	eb 71                	jmp    80063c <vprintfmt+0x355>
		return va_arg(*ap, unsigned long long);
  8005cb:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ce:	8b 10                	mov    (%eax),%edx
  8005d0:	8b 48 04             	mov    0x4(%eax),%ecx
  8005d3:	8d 40 08             	lea    0x8(%eax),%eax
  8005d6:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005d9:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  8005de:	eb 5c                	jmp    80063c <vprintfmt+0x355>
		return va_arg(*ap, unsigned int);
  8005e0:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e3:	8b 10                	mov    (%eax),%edx
  8005e5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005ea:	8d 40 04             	lea    0x4(%eax),%eax
  8005ed:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005f0:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  8005f5:	eb 45                	jmp    80063c <vprintfmt+0x355>
			putch('X', putdat);
  8005f7:	83 ec 08             	sub    $0x8,%esp
  8005fa:	53                   	push   %ebx
  8005fb:	6a 58                	push   $0x58
  8005fd:	ff d6                	call   *%esi
			putch('X', putdat);
  8005ff:	83 c4 08             	add    $0x8,%esp
  800602:	53                   	push   %ebx
  800603:	6a 58                	push   $0x58
  800605:	ff d6                	call   *%esi
			putch('X', putdat);
  800607:	83 c4 08             	add    $0x8,%esp
  80060a:	53                   	push   %ebx
  80060b:	6a 58                	push   $0x58
  80060d:	ff d6                	call   *%esi
			break;
  80060f:	83 c4 10             	add    $0x10,%esp
  800612:	eb 42                	jmp    800656 <vprintfmt+0x36f>
			putch('0', putdat);
  800614:	83 ec 08             	sub    $0x8,%esp
  800617:	53                   	push   %ebx
  800618:	6a 30                	push   $0x30
  80061a:	ff d6                	call   *%esi
			putch('x', putdat);
  80061c:	83 c4 08             	add    $0x8,%esp
  80061f:	53                   	push   %ebx
  800620:	6a 78                	push   $0x78
  800622:	ff d6                	call   *%esi
			num = (unsigned long long)
  800624:	8b 45 14             	mov    0x14(%ebp),%eax
  800627:	8b 10                	mov    (%eax),%edx
  800629:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  80062e:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800631:	8d 40 04             	lea    0x4(%eax),%eax
  800634:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800637:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  80063c:	83 ec 0c             	sub    $0xc,%esp
  80063f:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  800643:	57                   	push   %edi
  800644:	ff 75 d4             	pushl  -0x2c(%ebp)
  800647:	50                   	push   %eax
  800648:	51                   	push   %ecx
  800649:	52                   	push   %edx
  80064a:	89 da                	mov    %ebx,%edx
  80064c:	89 f0                	mov    %esi,%eax
  80064e:	e8 b6 fb ff ff       	call   800209 <printnum>
			break;
  800653:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  800656:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800659:	47                   	inc    %edi
  80065a:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80065e:	83 f8 25             	cmp    $0x25,%eax
  800661:	0f 84 97 fc ff ff    	je     8002fe <vprintfmt+0x17>
			if (ch == '\0')
  800667:	85 c0                	test   %eax,%eax
  800669:	0f 84 89 00 00 00    	je     8006f8 <vprintfmt+0x411>
			putch(ch, putdat);
  80066f:	83 ec 08             	sub    $0x8,%esp
  800672:	53                   	push   %ebx
  800673:	50                   	push   %eax
  800674:	ff d6                	call   *%esi
  800676:	83 c4 10             	add    $0x10,%esp
  800679:	eb de                	jmp    800659 <vprintfmt+0x372>
	if (lflag >= 2)
  80067b:	83 f9 01             	cmp    $0x1,%ecx
  80067e:	7f 1b                	jg     80069b <vprintfmt+0x3b4>
	else if (lflag)
  800680:	85 c9                	test   %ecx,%ecx
  800682:	74 2c                	je     8006b0 <vprintfmt+0x3c9>
		return va_arg(*ap, unsigned long);
  800684:	8b 45 14             	mov    0x14(%ebp),%eax
  800687:	8b 10                	mov    (%eax),%edx
  800689:	b9 00 00 00 00       	mov    $0x0,%ecx
  80068e:	8d 40 04             	lea    0x4(%eax),%eax
  800691:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800694:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  800699:	eb a1                	jmp    80063c <vprintfmt+0x355>
		return va_arg(*ap, unsigned long long);
  80069b:	8b 45 14             	mov    0x14(%ebp),%eax
  80069e:	8b 10                	mov    (%eax),%edx
  8006a0:	8b 48 04             	mov    0x4(%eax),%ecx
  8006a3:	8d 40 08             	lea    0x8(%eax),%eax
  8006a6:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006a9:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  8006ae:	eb 8c                	jmp    80063c <vprintfmt+0x355>
		return va_arg(*ap, unsigned int);
  8006b0:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b3:	8b 10                	mov    (%eax),%edx
  8006b5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006ba:	8d 40 04             	lea    0x4(%eax),%eax
  8006bd:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006c0:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  8006c5:	e9 72 ff ff ff       	jmp    80063c <vprintfmt+0x355>
			putch(ch, putdat);
  8006ca:	83 ec 08             	sub    $0x8,%esp
  8006cd:	53                   	push   %ebx
  8006ce:	6a 25                	push   $0x25
  8006d0:	ff d6                	call   *%esi
			break;
  8006d2:	83 c4 10             	add    $0x10,%esp
  8006d5:	e9 7c ff ff ff       	jmp    800656 <vprintfmt+0x36f>
			putch('%', putdat);
  8006da:	83 ec 08             	sub    $0x8,%esp
  8006dd:	53                   	push   %ebx
  8006de:	6a 25                	push   $0x25
  8006e0:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006e2:	83 c4 10             	add    $0x10,%esp
  8006e5:	89 f8                	mov    %edi,%eax
  8006e7:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8006eb:	74 03                	je     8006f0 <vprintfmt+0x409>
  8006ed:	48                   	dec    %eax
  8006ee:	eb f7                	jmp    8006e7 <vprintfmt+0x400>
  8006f0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8006f3:	e9 5e ff ff ff       	jmp    800656 <vprintfmt+0x36f>
}
  8006f8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006fb:	5b                   	pop    %ebx
  8006fc:	5e                   	pop    %esi
  8006fd:	5f                   	pop    %edi
  8006fe:	5d                   	pop    %ebp
  8006ff:	c3                   	ret    

00800700 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800700:	55                   	push   %ebp
  800701:	89 e5                	mov    %esp,%ebp
  800703:	83 ec 18             	sub    $0x18,%esp
  800706:	8b 45 08             	mov    0x8(%ebp),%eax
  800709:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80070c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80070f:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800713:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800716:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80071d:	85 c0                	test   %eax,%eax
  80071f:	74 26                	je     800747 <vsnprintf+0x47>
  800721:	85 d2                	test   %edx,%edx
  800723:	7e 29                	jle    80074e <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800725:	ff 75 14             	pushl  0x14(%ebp)
  800728:	ff 75 10             	pushl  0x10(%ebp)
  80072b:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80072e:	50                   	push   %eax
  80072f:	68 ae 02 80 00       	push   $0x8002ae
  800734:	e8 ae fb ff ff       	call   8002e7 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800739:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80073c:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80073f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800742:	83 c4 10             	add    $0x10,%esp
}
  800745:	c9                   	leave  
  800746:	c3                   	ret    
		return -E_INVAL;
  800747:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80074c:	eb f7                	jmp    800745 <vsnprintf+0x45>
  80074e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800753:	eb f0                	jmp    800745 <vsnprintf+0x45>

00800755 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800755:	55                   	push   %ebp
  800756:	89 e5                	mov    %esp,%ebp
  800758:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80075b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80075e:	50                   	push   %eax
  80075f:	ff 75 10             	pushl  0x10(%ebp)
  800762:	ff 75 0c             	pushl  0xc(%ebp)
  800765:	ff 75 08             	pushl  0x8(%ebp)
  800768:	e8 93 ff ff ff       	call   800700 <vsnprintf>
	va_end(ap);

	return rc;
}
  80076d:	c9                   	leave  
  80076e:	c3                   	ret    

0080076f <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80076f:	55                   	push   %ebp
  800770:	89 e5                	mov    %esp,%ebp
  800772:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800775:	b8 00 00 00 00       	mov    $0x0,%eax
  80077a:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80077e:	74 03                	je     800783 <strlen+0x14>
		n++;
  800780:	40                   	inc    %eax
  800781:	eb f7                	jmp    80077a <strlen+0xb>
	return n;
}
  800783:	5d                   	pop    %ebp
  800784:	c3                   	ret    

00800785 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800785:	55                   	push   %ebp
  800786:	89 e5                	mov    %esp,%ebp
  800788:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80078b:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80078e:	b8 00 00 00 00       	mov    $0x0,%eax
  800793:	39 d0                	cmp    %edx,%eax
  800795:	74 0b                	je     8007a2 <strnlen+0x1d>
  800797:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80079b:	74 03                	je     8007a0 <strnlen+0x1b>
		n++;
  80079d:	40                   	inc    %eax
  80079e:	eb f3                	jmp    800793 <strnlen+0xe>
  8007a0:	89 c2                	mov    %eax,%edx
	return n;
}
  8007a2:	89 d0                	mov    %edx,%eax
  8007a4:	5d                   	pop    %ebp
  8007a5:	c3                   	ret    

008007a6 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007a6:	55                   	push   %ebp
  8007a7:	89 e5                	mov    %esp,%ebp
  8007a9:	53                   	push   %ebx
  8007aa:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007ad:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007b0:	b8 00 00 00 00       	mov    $0x0,%eax
  8007b5:	8a 14 03             	mov    (%ebx,%eax,1),%dl
  8007b8:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8007bb:	40                   	inc    %eax
  8007bc:	84 d2                	test   %dl,%dl
  8007be:	75 f5                	jne    8007b5 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8007c0:	89 c8                	mov    %ecx,%eax
  8007c2:	5b                   	pop    %ebx
  8007c3:	5d                   	pop    %ebp
  8007c4:	c3                   	ret    

008007c5 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007c5:	55                   	push   %ebp
  8007c6:	89 e5                	mov    %esp,%ebp
  8007c8:	53                   	push   %ebx
  8007c9:	83 ec 10             	sub    $0x10,%esp
  8007cc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007cf:	53                   	push   %ebx
  8007d0:	e8 9a ff ff ff       	call   80076f <strlen>
  8007d5:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  8007d8:	ff 75 0c             	pushl  0xc(%ebp)
  8007db:	01 d8                	add    %ebx,%eax
  8007dd:	50                   	push   %eax
  8007de:	e8 c3 ff ff ff       	call   8007a6 <strcpy>
	return dst;
}
  8007e3:	89 d8                	mov    %ebx,%eax
  8007e5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007e8:	c9                   	leave  
  8007e9:	c3                   	ret    

008007ea <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007ea:	55                   	push   %ebp
  8007eb:	89 e5                	mov    %esp,%ebp
  8007ed:	53                   	push   %ebx
  8007ee:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007f1:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8007f4:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8007fa:	39 d8                	cmp    %ebx,%eax
  8007fc:	74 0e                	je     80080c <strncpy+0x22>
		*dst++ = *src;
  8007fe:	40                   	inc    %eax
  8007ff:	8a 0a                	mov    (%edx),%cl
  800801:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800804:	80 f9 01             	cmp    $0x1,%cl
  800807:	83 da ff             	sbb    $0xffffffff,%edx
  80080a:	eb ee                	jmp    8007fa <strncpy+0x10>
	}
	return ret;
}
  80080c:	8b 45 08             	mov    0x8(%ebp),%eax
  80080f:	5b                   	pop    %ebx
  800810:	5d                   	pop    %ebp
  800811:	c3                   	ret    

00800812 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800812:	55                   	push   %ebp
  800813:	89 e5                	mov    %esp,%ebp
  800815:	56                   	push   %esi
  800816:	53                   	push   %ebx
  800817:	8b 75 08             	mov    0x8(%ebp),%esi
  80081a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80081d:	8b 45 10             	mov    0x10(%ebp),%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800820:	85 c0                	test   %eax,%eax
  800822:	74 22                	je     800846 <strlcpy+0x34>
  800824:	8d 44 06 ff          	lea    -0x1(%esi,%eax,1),%eax
  800828:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  80082a:	39 c2                	cmp    %eax,%edx
  80082c:	74 0f                	je     80083d <strlcpy+0x2b>
  80082e:	8a 19                	mov    (%ecx),%bl
  800830:	84 db                	test   %bl,%bl
  800832:	74 07                	je     80083b <strlcpy+0x29>
			*dst++ = *src++;
  800834:	41                   	inc    %ecx
  800835:	42                   	inc    %edx
  800836:	88 5a ff             	mov    %bl,-0x1(%edx)
  800839:	eb ef                	jmp    80082a <strlcpy+0x18>
  80083b:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  80083d:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800840:	29 f0                	sub    %esi,%eax
}
  800842:	5b                   	pop    %ebx
  800843:	5e                   	pop    %esi
  800844:	5d                   	pop    %ebp
  800845:	c3                   	ret    
  800846:	89 f0                	mov    %esi,%eax
  800848:	eb f6                	jmp    800840 <strlcpy+0x2e>

0080084a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80084a:	55                   	push   %ebp
  80084b:	89 e5                	mov    %esp,%ebp
  80084d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800850:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800853:	8a 01                	mov    (%ecx),%al
  800855:	84 c0                	test   %al,%al
  800857:	74 08                	je     800861 <strcmp+0x17>
  800859:	3a 02                	cmp    (%edx),%al
  80085b:	75 04                	jne    800861 <strcmp+0x17>
		p++, q++;
  80085d:	41                   	inc    %ecx
  80085e:	42                   	inc    %edx
  80085f:	eb f2                	jmp    800853 <strcmp+0x9>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800861:	0f b6 c0             	movzbl %al,%eax
  800864:	0f b6 12             	movzbl (%edx),%edx
  800867:	29 d0                	sub    %edx,%eax
}
  800869:	5d                   	pop    %ebp
  80086a:	c3                   	ret    

0080086b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80086b:	55                   	push   %ebp
  80086c:	89 e5                	mov    %esp,%ebp
  80086e:	53                   	push   %ebx
  80086f:	8b 45 08             	mov    0x8(%ebp),%eax
  800872:	8b 55 0c             	mov    0xc(%ebp),%edx
  800875:	89 c3                	mov    %eax,%ebx
  800877:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80087a:	eb 02                	jmp    80087e <strncmp+0x13>
		n--, p++, q++;
  80087c:	40                   	inc    %eax
  80087d:	42                   	inc    %edx
	while (n > 0 && *p && *p == *q)
  80087e:	39 d8                	cmp    %ebx,%eax
  800880:	74 15                	je     800897 <strncmp+0x2c>
  800882:	8a 08                	mov    (%eax),%cl
  800884:	84 c9                	test   %cl,%cl
  800886:	74 04                	je     80088c <strncmp+0x21>
  800888:	3a 0a                	cmp    (%edx),%cl
  80088a:	74 f0                	je     80087c <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80088c:	0f b6 00             	movzbl (%eax),%eax
  80088f:	0f b6 12             	movzbl (%edx),%edx
  800892:	29 d0                	sub    %edx,%eax
}
  800894:	5b                   	pop    %ebx
  800895:	5d                   	pop    %ebp
  800896:	c3                   	ret    
		return 0;
  800897:	b8 00 00 00 00       	mov    $0x0,%eax
  80089c:	eb f6                	jmp    800894 <strncmp+0x29>

0080089e <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80089e:	55                   	push   %ebp
  80089f:	89 e5                	mov    %esp,%ebp
  8008a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a4:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8008a7:	8a 10                	mov    (%eax),%dl
  8008a9:	84 d2                	test   %dl,%dl
  8008ab:	74 07                	je     8008b4 <strchr+0x16>
		if (*s == c)
  8008ad:	38 ca                	cmp    %cl,%dl
  8008af:	74 08                	je     8008b9 <strchr+0x1b>
	for (; *s; s++)
  8008b1:	40                   	inc    %eax
  8008b2:	eb f3                	jmp    8008a7 <strchr+0x9>
			return (char *) s;
	return 0;
  8008b4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008b9:	5d                   	pop    %ebp
  8008ba:	c3                   	ret    

008008bb <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008bb:	55                   	push   %ebp
  8008bc:	89 e5                	mov    %esp,%ebp
  8008be:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c1:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8008c4:	8a 10                	mov    (%eax),%dl
  8008c6:	84 d2                	test   %dl,%dl
  8008c8:	74 07                	je     8008d1 <strfind+0x16>
		if (*s == c)
  8008ca:	38 ca                	cmp    %cl,%dl
  8008cc:	74 03                	je     8008d1 <strfind+0x16>
	for (; *s; s++)
  8008ce:	40                   	inc    %eax
  8008cf:	eb f3                	jmp    8008c4 <strfind+0x9>
			break;
	return (char *) s;
}
  8008d1:	5d                   	pop    %ebp
  8008d2:	c3                   	ret    

008008d3 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008d3:	55                   	push   %ebp
  8008d4:	89 e5                	mov    %esp,%ebp
  8008d6:	57                   	push   %edi
  8008d7:	56                   	push   %esi
  8008d8:	53                   	push   %ebx
  8008d9:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008dc:	85 c9                	test   %ecx,%ecx
  8008de:	74 36                	je     800916 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008e0:	89 c8                	mov    %ecx,%eax
  8008e2:	0b 45 08             	or     0x8(%ebp),%eax
  8008e5:	a8 03                	test   $0x3,%al
  8008e7:	75 24                	jne    80090d <memset+0x3a>
		c &= 0xFF;
  8008e9:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008ed:	89 d3                	mov    %edx,%ebx
  8008ef:	c1 e3 08             	shl    $0x8,%ebx
  8008f2:	89 d0                	mov    %edx,%eax
  8008f4:	c1 e0 18             	shl    $0x18,%eax
  8008f7:	89 d6                	mov    %edx,%esi
  8008f9:	c1 e6 10             	shl    $0x10,%esi
  8008fc:	09 f0                	or     %esi,%eax
  8008fe:	09 d0                	or     %edx,%eax
  800900:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800902:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800905:	8b 7d 08             	mov    0x8(%ebp),%edi
  800908:	fc                   	cld    
  800909:	f3 ab                	rep stos %eax,%es:(%edi)
  80090b:	eb 09                	jmp    800916 <memset+0x43>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80090d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800910:	8b 45 0c             	mov    0xc(%ebp),%eax
  800913:	fc                   	cld    
  800914:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800916:	8b 45 08             	mov    0x8(%ebp),%eax
  800919:	5b                   	pop    %ebx
  80091a:	5e                   	pop    %esi
  80091b:	5f                   	pop    %edi
  80091c:	5d                   	pop    %ebp
  80091d:	c3                   	ret    

0080091e <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80091e:	55                   	push   %ebp
  80091f:	89 e5                	mov    %esp,%ebp
  800921:	57                   	push   %edi
  800922:	56                   	push   %esi
  800923:	8b 45 08             	mov    0x8(%ebp),%eax
  800926:	8b 75 0c             	mov    0xc(%ebp),%esi
  800929:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80092c:	39 c6                	cmp    %eax,%esi
  80092e:	73 30                	jae    800960 <memmove+0x42>
  800930:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800933:	39 c2                	cmp    %eax,%edx
  800935:	76 29                	jbe    800960 <memmove+0x42>
		s += n;
		d += n;
  800937:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80093a:	89 fe                	mov    %edi,%esi
  80093c:	09 ce                	or     %ecx,%esi
  80093e:	09 d6                	or     %edx,%esi
  800940:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800946:	75 0e                	jne    800956 <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800948:	83 ef 04             	sub    $0x4,%edi
  80094b:	8d 72 fc             	lea    -0x4(%edx),%esi
  80094e:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800951:	fd                   	std    
  800952:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800954:	eb 07                	jmp    80095d <memmove+0x3f>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800956:	4f                   	dec    %edi
  800957:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  80095a:	fd                   	std    
  80095b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80095d:	fc                   	cld    
  80095e:	eb 1a                	jmp    80097a <memmove+0x5c>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800960:	89 c2                	mov    %eax,%edx
  800962:	09 ca                	or     %ecx,%edx
  800964:	09 f2                	or     %esi,%edx
  800966:	f6 c2 03             	test   $0x3,%dl
  800969:	75 0a                	jne    800975 <memmove+0x57>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  80096b:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  80096e:	89 c7                	mov    %eax,%edi
  800970:	fc                   	cld    
  800971:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800973:	eb 05                	jmp    80097a <memmove+0x5c>
		else
			asm volatile("cld; rep movsb\n"
  800975:	89 c7                	mov    %eax,%edi
  800977:	fc                   	cld    
  800978:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80097a:	5e                   	pop    %esi
  80097b:	5f                   	pop    %edi
  80097c:	5d                   	pop    %ebp
  80097d:	c3                   	ret    

0080097e <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80097e:	55                   	push   %ebp
  80097f:	89 e5                	mov    %esp,%ebp
  800981:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800984:	ff 75 10             	pushl  0x10(%ebp)
  800987:	ff 75 0c             	pushl  0xc(%ebp)
  80098a:	ff 75 08             	pushl  0x8(%ebp)
  80098d:	e8 8c ff ff ff       	call   80091e <memmove>
}
  800992:	c9                   	leave  
  800993:	c3                   	ret    

00800994 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800994:	55                   	push   %ebp
  800995:	89 e5                	mov    %esp,%ebp
  800997:	56                   	push   %esi
  800998:	53                   	push   %ebx
  800999:	8b 45 08             	mov    0x8(%ebp),%eax
  80099c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80099f:	89 c6                	mov    %eax,%esi
  8009a1:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009a4:	39 f0                	cmp    %esi,%eax
  8009a6:	74 16                	je     8009be <memcmp+0x2a>
		if (*s1 != *s2)
  8009a8:	8a 08                	mov    (%eax),%cl
  8009aa:	8a 1a                	mov    (%edx),%bl
  8009ac:	38 d9                	cmp    %bl,%cl
  8009ae:	75 04                	jne    8009b4 <memcmp+0x20>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  8009b0:	40                   	inc    %eax
  8009b1:	42                   	inc    %edx
  8009b2:	eb f0                	jmp    8009a4 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  8009b4:	0f b6 c1             	movzbl %cl,%eax
  8009b7:	0f b6 db             	movzbl %bl,%ebx
  8009ba:	29 d8                	sub    %ebx,%eax
  8009bc:	eb 05                	jmp    8009c3 <memcmp+0x2f>
	}

	return 0;
  8009be:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009c3:	5b                   	pop    %ebx
  8009c4:	5e                   	pop    %esi
  8009c5:	5d                   	pop    %ebp
  8009c6:	c3                   	ret    

008009c7 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009c7:	55                   	push   %ebp
  8009c8:	89 e5                	mov    %esp,%ebp
  8009ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8009cd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8009d0:	89 c2                	mov    %eax,%edx
  8009d2:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8009d5:	39 d0                	cmp    %edx,%eax
  8009d7:	73 07                	jae    8009e0 <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009d9:	38 08                	cmp    %cl,(%eax)
  8009db:	74 03                	je     8009e0 <memfind+0x19>
	for (; s < ends; s++)
  8009dd:	40                   	inc    %eax
  8009de:	eb f5                	jmp    8009d5 <memfind+0xe>
			break;
	return (void *) s;
}
  8009e0:	5d                   	pop    %ebp
  8009e1:	c3                   	ret    

008009e2 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009e2:	55                   	push   %ebp
  8009e3:	89 e5                	mov    %esp,%ebp
  8009e5:	57                   	push   %edi
  8009e6:	56                   	push   %esi
  8009e7:	53                   	push   %ebx
  8009e8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009eb:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009ee:	eb 01                	jmp    8009f1 <strtol+0xf>
		s++;
  8009f0:	41                   	inc    %ecx
	while (*s == ' ' || *s == '\t')
  8009f1:	8a 01                	mov    (%ecx),%al
  8009f3:	3c 20                	cmp    $0x20,%al
  8009f5:	74 f9                	je     8009f0 <strtol+0xe>
  8009f7:	3c 09                	cmp    $0x9,%al
  8009f9:	74 f5                	je     8009f0 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  8009fb:	3c 2b                	cmp    $0x2b,%al
  8009fd:	74 24                	je     800a23 <strtol+0x41>
		s++;
	else if (*s == '-')
  8009ff:	3c 2d                	cmp    $0x2d,%al
  800a01:	74 28                	je     800a2b <strtol+0x49>
	int neg = 0;
  800a03:	bf 00 00 00 00       	mov    $0x0,%edi
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a08:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a0e:	75 09                	jne    800a19 <strtol+0x37>
  800a10:	80 39 30             	cmpb   $0x30,(%ecx)
  800a13:	74 1e                	je     800a33 <strtol+0x51>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a15:	85 db                	test   %ebx,%ebx
  800a17:	74 36                	je     800a4f <strtol+0x6d>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a19:	b8 00 00 00 00       	mov    $0x0,%eax
  800a1e:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800a21:	eb 45                	jmp    800a68 <strtol+0x86>
		s++;
  800a23:	41                   	inc    %ecx
	int neg = 0;
  800a24:	bf 00 00 00 00       	mov    $0x0,%edi
  800a29:	eb dd                	jmp    800a08 <strtol+0x26>
		s++, neg = 1;
  800a2b:	41                   	inc    %ecx
  800a2c:	bf 01 00 00 00       	mov    $0x1,%edi
  800a31:	eb d5                	jmp    800a08 <strtol+0x26>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a33:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a37:	74 0c                	je     800a45 <strtol+0x63>
	else if (base == 0 && s[0] == '0')
  800a39:	85 db                	test   %ebx,%ebx
  800a3b:	75 dc                	jne    800a19 <strtol+0x37>
		s++, base = 8;
  800a3d:	41                   	inc    %ecx
  800a3e:	bb 08 00 00 00       	mov    $0x8,%ebx
  800a43:	eb d4                	jmp    800a19 <strtol+0x37>
		s += 2, base = 16;
  800a45:	83 c1 02             	add    $0x2,%ecx
  800a48:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a4d:	eb ca                	jmp    800a19 <strtol+0x37>
		base = 10;
  800a4f:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800a54:	eb c3                	jmp    800a19 <strtol+0x37>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800a56:	0f be d2             	movsbl %dl,%edx
  800a59:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800a5c:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a5f:	7d 37                	jge    800a98 <strtol+0xb6>
			break;
		s++, val = (val * base) + dig;
  800a61:	41                   	inc    %ecx
  800a62:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a66:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800a68:	8a 11                	mov    (%ecx),%dl
  800a6a:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a6d:	89 f3                	mov    %esi,%ebx
  800a6f:	80 fb 09             	cmp    $0x9,%bl
  800a72:	76 e2                	jbe    800a56 <strtol+0x74>
		else if (*s >= 'a' && *s <= 'z')
  800a74:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a77:	89 f3                	mov    %esi,%ebx
  800a79:	80 fb 19             	cmp    $0x19,%bl
  800a7c:	77 08                	ja     800a86 <strtol+0xa4>
			dig = *s - 'a' + 10;
  800a7e:	0f be d2             	movsbl %dl,%edx
  800a81:	83 ea 57             	sub    $0x57,%edx
  800a84:	eb d6                	jmp    800a5c <strtol+0x7a>
		else if (*s >= 'A' && *s <= 'Z')
  800a86:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a89:	89 f3                	mov    %esi,%ebx
  800a8b:	80 fb 19             	cmp    $0x19,%bl
  800a8e:	77 08                	ja     800a98 <strtol+0xb6>
			dig = *s - 'A' + 10;
  800a90:	0f be d2             	movsbl %dl,%edx
  800a93:	83 ea 37             	sub    $0x37,%edx
  800a96:	eb c4                	jmp    800a5c <strtol+0x7a>
		// we don't properly detect overflow!
	}

	if (endptr)
  800a98:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a9c:	74 05                	je     800aa3 <strtol+0xc1>
		*endptr = (char *) s;
  800a9e:	8b 75 0c             	mov    0xc(%ebp),%esi
  800aa1:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800aa3:	85 ff                	test   %edi,%edi
  800aa5:	74 02                	je     800aa9 <strtol+0xc7>
  800aa7:	f7 d8                	neg    %eax
}
  800aa9:	5b                   	pop    %ebx
  800aaa:	5e                   	pop    %esi
  800aab:	5f                   	pop    %edi
  800aac:	5d                   	pop    %ebp
  800aad:	c3                   	ret    
  800aae:	66 90                	xchg   %ax,%ax

00800ab0 <__udivdi3>:
  800ab0:	55                   	push   %ebp
  800ab1:	57                   	push   %edi
  800ab2:	56                   	push   %esi
  800ab3:	53                   	push   %ebx
  800ab4:	83 ec 1c             	sub    $0x1c,%esp
  800ab7:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800abb:	8b 74 24 34          	mov    0x34(%esp),%esi
  800abf:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800ac3:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800ac7:	85 d2                	test   %edx,%edx
  800ac9:	75 19                	jne    800ae4 <__udivdi3+0x34>
  800acb:	39 f7                	cmp    %esi,%edi
  800acd:	76 45                	jbe    800b14 <__udivdi3+0x64>
  800acf:	89 e8                	mov    %ebp,%eax
  800ad1:	89 f2                	mov    %esi,%edx
  800ad3:	f7 f7                	div    %edi
  800ad5:	31 db                	xor    %ebx,%ebx
  800ad7:	89 da                	mov    %ebx,%edx
  800ad9:	83 c4 1c             	add    $0x1c,%esp
  800adc:	5b                   	pop    %ebx
  800add:	5e                   	pop    %esi
  800ade:	5f                   	pop    %edi
  800adf:	5d                   	pop    %ebp
  800ae0:	c3                   	ret    
  800ae1:	8d 76 00             	lea    0x0(%esi),%esi
  800ae4:	39 f2                	cmp    %esi,%edx
  800ae6:	76 10                	jbe    800af8 <__udivdi3+0x48>
  800ae8:	31 db                	xor    %ebx,%ebx
  800aea:	31 c0                	xor    %eax,%eax
  800aec:	89 da                	mov    %ebx,%edx
  800aee:	83 c4 1c             	add    $0x1c,%esp
  800af1:	5b                   	pop    %ebx
  800af2:	5e                   	pop    %esi
  800af3:	5f                   	pop    %edi
  800af4:	5d                   	pop    %ebp
  800af5:	c3                   	ret    
  800af6:	66 90                	xchg   %ax,%ax
  800af8:	0f bd da             	bsr    %edx,%ebx
  800afb:	83 f3 1f             	xor    $0x1f,%ebx
  800afe:	75 3c                	jne    800b3c <__udivdi3+0x8c>
  800b00:	39 f2                	cmp    %esi,%edx
  800b02:	72 08                	jb     800b0c <__udivdi3+0x5c>
  800b04:	39 ef                	cmp    %ebp,%edi
  800b06:	0f 87 9c 00 00 00    	ja     800ba8 <__udivdi3+0xf8>
  800b0c:	b8 01 00 00 00       	mov    $0x1,%eax
  800b11:	eb d9                	jmp    800aec <__udivdi3+0x3c>
  800b13:	90                   	nop
  800b14:	89 f9                	mov    %edi,%ecx
  800b16:	85 ff                	test   %edi,%edi
  800b18:	75 0b                	jne    800b25 <__udivdi3+0x75>
  800b1a:	b8 01 00 00 00       	mov    $0x1,%eax
  800b1f:	31 d2                	xor    %edx,%edx
  800b21:	f7 f7                	div    %edi
  800b23:	89 c1                	mov    %eax,%ecx
  800b25:	31 d2                	xor    %edx,%edx
  800b27:	89 f0                	mov    %esi,%eax
  800b29:	f7 f1                	div    %ecx
  800b2b:	89 c3                	mov    %eax,%ebx
  800b2d:	89 e8                	mov    %ebp,%eax
  800b2f:	f7 f1                	div    %ecx
  800b31:	89 da                	mov    %ebx,%edx
  800b33:	83 c4 1c             	add    $0x1c,%esp
  800b36:	5b                   	pop    %ebx
  800b37:	5e                   	pop    %esi
  800b38:	5f                   	pop    %edi
  800b39:	5d                   	pop    %ebp
  800b3a:	c3                   	ret    
  800b3b:	90                   	nop
  800b3c:	b8 20 00 00 00       	mov    $0x20,%eax
  800b41:	29 d8                	sub    %ebx,%eax
  800b43:	88 d9                	mov    %bl,%cl
  800b45:	d3 e2                	shl    %cl,%edx
  800b47:	89 54 24 08          	mov    %edx,0x8(%esp)
  800b4b:	89 fa                	mov    %edi,%edx
  800b4d:	88 c1                	mov    %al,%cl
  800b4f:	d3 ea                	shr    %cl,%edx
  800b51:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800b55:	09 d1                	or     %edx,%ecx
  800b57:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800b5b:	88 d9                	mov    %bl,%cl
  800b5d:	d3 e7                	shl    %cl,%edi
  800b5f:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800b63:	89 f7                	mov    %esi,%edi
  800b65:	88 c1                	mov    %al,%cl
  800b67:	d3 ef                	shr    %cl,%edi
  800b69:	88 d9                	mov    %bl,%cl
  800b6b:	d3 e6                	shl    %cl,%esi
  800b6d:	89 ea                	mov    %ebp,%edx
  800b6f:	88 c1                	mov    %al,%cl
  800b71:	d3 ea                	shr    %cl,%edx
  800b73:	09 d6                	or     %edx,%esi
  800b75:	89 f0                	mov    %esi,%eax
  800b77:	89 fa                	mov    %edi,%edx
  800b79:	f7 74 24 08          	divl   0x8(%esp)
  800b7d:	89 d7                	mov    %edx,%edi
  800b7f:	89 c6                	mov    %eax,%esi
  800b81:	f7 64 24 0c          	mull   0xc(%esp)
  800b85:	39 d7                	cmp    %edx,%edi
  800b87:	72 13                	jb     800b9c <__udivdi3+0xec>
  800b89:	74 09                	je     800b94 <__udivdi3+0xe4>
  800b8b:	89 f0                	mov    %esi,%eax
  800b8d:	31 db                	xor    %ebx,%ebx
  800b8f:	e9 58 ff ff ff       	jmp    800aec <__udivdi3+0x3c>
  800b94:	88 d9                	mov    %bl,%cl
  800b96:	d3 e5                	shl    %cl,%ebp
  800b98:	39 c5                	cmp    %eax,%ebp
  800b9a:	73 ef                	jae    800b8b <__udivdi3+0xdb>
  800b9c:	8d 46 ff             	lea    -0x1(%esi),%eax
  800b9f:	31 db                	xor    %ebx,%ebx
  800ba1:	e9 46 ff ff ff       	jmp    800aec <__udivdi3+0x3c>
  800ba6:	66 90                	xchg   %ax,%ax
  800ba8:	31 c0                	xor    %eax,%eax
  800baa:	e9 3d ff ff ff       	jmp    800aec <__udivdi3+0x3c>
  800baf:	90                   	nop

00800bb0 <__umoddi3>:
  800bb0:	55                   	push   %ebp
  800bb1:	57                   	push   %edi
  800bb2:	56                   	push   %esi
  800bb3:	53                   	push   %ebx
  800bb4:	83 ec 1c             	sub    $0x1c,%esp
  800bb7:	8b 74 24 30          	mov    0x30(%esp),%esi
  800bbb:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800bbf:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800bc3:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  800bc7:	85 c0                	test   %eax,%eax
  800bc9:	75 19                	jne    800be4 <__umoddi3+0x34>
  800bcb:	39 df                	cmp    %ebx,%edi
  800bcd:	76 51                	jbe    800c20 <__umoddi3+0x70>
  800bcf:	89 f0                	mov    %esi,%eax
  800bd1:	89 da                	mov    %ebx,%edx
  800bd3:	f7 f7                	div    %edi
  800bd5:	89 d0                	mov    %edx,%eax
  800bd7:	31 d2                	xor    %edx,%edx
  800bd9:	83 c4 1c             	add    $0x1c,%esp
  800bdc:	5b                   	pop    %ebx
  800bdd:	5e                   	pop    %esi
  800bde:	5f                   	pop    %edi
  800bdf:	5d                   	pop    %ebp
  800be0:	c3                   	ret    
  800be1:	8d 76 00             	lea    0x0(%esi),%esi
  800be4:	89 f2                	mov    %esi,%edx
  800be6:	39 d8                	cmp    %ebx,%eax
  800be8:	76 0e                	jbe    800bf8 <__umoddi3+0x48>
  800bea:	89 f0                	mov    %esi,%eax
  800bec:	89 da                	mov    %ebx,%edx
  800bee:	83 c4 1c             	add    $0x1c,%esp
  800bf1:	5b                   	pop    %ebx
  800bf2:	5e                   	pop    %esi
  800bf3:	5f                   	pop    %edi
  800bf4:	5d                   	pop    %ebp
  800bf5:	c3                   	ret    
  800bf6:	66 90                	xchg   %ax,%ax
  800bf8:	0f bd e8             	bsr    %eax,%ebp
  800bfb:	83 f5 1f             	xor    $0x1f,%ebp
  800bfe:	75 44                	jne    800c44 <__umoddi3+0x94>
  800c00:	39 d8                	cmp    %ebx,%eax
  800c02:	72 06                	jb     800c0a <__umoddi3+0x5a>
  800c04:	89 d9                	mov    %ebx,%ecx
  800c06:	39 f7                	cmp    %esi,%edi
  800c08:	77 08                	ja     800c12 <__umoddi3+0x62>
  800c0a:	29 fe                	sub    %edi,%esi
  800c0c:	19 c3                	sbb    %eax,%ebx
  800c0e:	89 f2                	mov    %esi,%edx
  800c10:	89 d9                	mov    %ebx,%ecx
  800c12:	89 d0                	mov    %edx,%eax
  800c14:	89 ca                	mov    %ecx,%edx
  800c16:	83 c4 1c             	add    $0x1c,%esp
  800c19:	5b                   	pop    %ebx
  800c1a:	5e                   	pop    %esi
  800c1b:	5f                   	pop    %edi
  800c1c:	5d                   	pop    %ebp
  800c1d:	c3                   	ret    
  800c1e:	66 90                	xchg   %ax,%ax
  800c20:	89 fd                	mov    %edi,%ebp
  800c22:	85 ff                	test   %edi,%edi
  800c24:	75 0b                	jne    800c31 <__umoddi3+0x81>
  800c26:	b8 01 00 00 00       	mov    $0x1,%eax
  800c2b:	31 d2                	xor    %edx,%edx
  800c2d:	f7 f7                	div    %edi
  800c2f:	89 c5                	mov    %eax,%ebp
  800c31:	89 d8                	mov    %ebx,%eax
  800c33:	31 d2                	xor    %edx,%edx
  800c35:	f7 f5                	div    %ebp
  800c37:	89 f0                	mov    %esi,%eax
  800c39:	f7 f5                	div    %ebp
  800c3b:	89 d0                	mov    %edx,%eax
  800c3d:	31 d2                	xor    %edx,%edx
  800c3f:	eb 98                	jmp    800bd9 <__umoddi3+0x29>
  800c41:	8d 76 00             	lea    0x0(%esi),%esi
  800c44:	ba 20 00 00 00       	mov    $0x20,%edx
  800c49:	29 ea                	sub    %ebp,%edx
  800c4b:	89 e9                	mov    %ebp,%ecx
  800c4d:	d3 e0                	shl    %cl,%eax
  800c4f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c53:	89 f8                	mov    %edi,%eax
  800c55:	89 54 24 04          	mov    %edx,0x4(%esp)
  800c59:	88 d1                	mov    %dl,%cl
  800c5b:	d3 e8                	shr    %cl,%eax
  800c5d:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800c61:	09 c1                	or     %eax,%ecx
  800c63:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800c67:	89 e9                	mov    %ebp,%ecx
  800c69:	d3 e7                	shl    %cl,%edi
  800c6b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800c6f:	89 d8                	mov    %ebx,%eax
  800c71:	8b 54 24 04          	mov    0x4(%esp),%edx
  800c75:	88 d1                	mov    %dl,%cl
  800c77:	d3 e8                	shr    %cl,%eax
  800c79:	89 c7                	mov    %eax,%edi
  800c7b:	89 e9                	mov    %ebp,%ecx
  800c7d:	d3 e3                	shl    %cl,%ebx
  800c7f:	89 f0                	mov    %esi,%eax
  800c81:	88 d1                	mov    %dl,%cl
  800c83:	d3 e8                	shr    %cl,%eax
  800c85:	09 d8                	or     %ebx,%eax
  800c87:	89 e9                	mov    %ebp,%ecx
  800c89:	d3 e6                	shl    %cl,%esi
  800c8b:	89 f3                	mov    %esi,%ebx
  800c8d:	89 fa                	mov    %edi,%edx
  800c8f:	f7 74 24 08          	divl   0x8(%esp)
  800c93:	89 d1                	mov    %edx,%ecx
  800c95:	f7 64 24 0c          	mull   0xc(%esp)
  800c99:	89 c6                	mov    %eax,%esi
  800c9b:	89 d7                	mov    %edx,%edi
  800c9d:	39 d1                	cmp    %edx,%ecx
  800c9f:	72 27                	jb     800cc8 <__umoddi3+0x118>
  800ca1:	74 21                	je     800cc4 <__umoddi3+0x114>
  800ca3:	89 ca                	mov    %ecx,%edx
  800ca5:	29 f3                	sub    %esi,%ebx
  800ca7:	19 fa                	sbb    %edi,%edx
  800ca9:	89 d0                	mov    %edx,%eax
  800cab:	8a 4c 24 04          	mov    0x4(%esp),%cl
  800caf:	d3 e0                	shl    %cl,%eax
  800cb1:	89 e9                	mov    %ebp,%ecx
  800cb3:	d3 eb                	shr    %cl,%ebx
  800cb5:	09 d8                	or     %ebx,%eax
  800cb7:	d3 ea                	shr    %cl,%edx
  800cb9:	83 c4 1c             	add    $0x1c,%esp
  800cbc:	5b                   	pop    %ebx
  800cbd:	5e                   	pop    %esi
  800cbe:	5f                   	pop    %edi
  800cbf:	5d                   	pop    %ebp
  800cc0:	c3                   	ret    
  800cc1:	8d 76 00             	lea    0x0(%esi),%esi
  800cc4:	39 c3                	cmp    %eax,%ebx
  800cc6:	73 db                	jae    800ca3 <__umoddi3+0xf3>
  800cc8:	2b 44 24 0c          	sub    0xc(%esp),%eax
  800ccc:	1b 54 24 08          	sbb    0x8(%esp),%edx
  800cd0:	89 d7                	mov    %edx,%edi
  800cd2:	89 c6                	mov    %eax,%esi
  800cd4:	eb cd                	jmp    800ca3 <__umoddi3+0xf3>
