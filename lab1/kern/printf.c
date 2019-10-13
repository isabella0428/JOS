// Simple implementation of cprintf console output for the kernel,
// based on printfmt() and the kernel console's cputchar().

#include <inc/types.h>
#include <inc/stdio.h>
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
	cputchar(ch);
	*cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
	int cnt = 0;

	//vprintfmt:		output characters in fmt
	// (void *)putch(int ch, int *cnt):		function pointer
	//				 	int ch: character to put
	//				 	int *cnt: the address of the variable which stores the destination
	// (void *)cnt:	 the address of the variable which stores the destination
	// const char *fmt: the format of output
	// va_list:		 argument list			 		 	
	vprintfmt((void*)putch, &cnt, fmt, ap);
	return cnt;
}

int
cprintf(const char *fmt, ...)
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
	va_end(ap);

	return cnt;
}

