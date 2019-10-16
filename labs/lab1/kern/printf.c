// Simple implementation of cprintf console output for the kernel,
//  based on printfmt() and the kernel console's cputchar().

#include <inc/types.h>
#include <inc/stdio.h>
#include <inc/stdarg.h>

/* Print ch and add one to the object cnt points to */
static void
putch(int ch, int *cnt)
{
	cputchar(ch);
	*cnt++;
}

/* print elements of ap in fmt and return the count of the elements*/
int
vcprintf(const char *fmt, va_list ap)
{
	int cnt = 0;

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

