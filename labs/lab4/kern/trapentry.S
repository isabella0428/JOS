/* See COPYRIGHT for copyright information. */

#include <inc/mmu.h>
#include <inc/memlayout.h>
#include <inc/trap.h>

#include <kern/picirq.h>


###################################################################
# exceptions/interrupts
###################################################################

/* TRAPHANDLER defines a globally-visible function for handling a trap.
 * It pushes a trap number onto the stack, then jumps to _alltraps.
 * Use TRAPHANDLER for traps where the CPU automatically pushes an error code.
 *
 * You shouldn't call a TRAPHANDLER function from C, but you may
 * need to _declare_ one in C (for instance, to get a function pointer
 * during IDT setup).  You can declare the function with
 *   void NAME();
 * where NAME is the argument passed to TRAPHANDLER.
 */
#define TRAPHANDLER(name, num)						\
	.globl name;		/* define global symbol for 'name' */	\
	.type name, @function;	/* symbol type is function */		\
	.align 2;		/* align function definition */		\
	name:			/* function starts here */		\
	pushl $(num);							\
	jmp _alltraps

/* Use TRAPHANDLER_NOEC for traps where the CPU doesn't push an error code.
 * It pushes a 0 in place of the error code, so the trap frame has the same
 * format in either case.
 */
#define TRAPHANDLER_NOEC(name, num)					\
	.globl name;							\
	.type name, @function;						\
	.align 2;							\
	name:								\
	pushl $0;							\
	pushl $(num);							\
	jmp _alltraps

.text

/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */

TRAPHANDLER_NOEC(divide_handler, 0)
TRAPHANDLER_NOEC(debug_handler, 1)
TRAPHANDLER_NOEC(nmi_handler, 2)
TRAPHANDLER_NOEC(brkpt_handler, 3)
TRAPHANDLER_NOEC(oflow_handler, 4)
TRAPHANDLER_NOEC(bound_handler, 5)
TRAPHANDLER_NOEC(device_handler, 7)
TRAPHANDLER_NOEC(illop_handler, 6)
TRAPHANDLER(dblflt_handler, 8)
TRAPHANDLER(tss_handler, 10)
TRAPHANDLER(segnp_handler, 11)
TRAPHANDLER(stack_handler, 12)
TRAPHANDLER(gpflt_handler, 13)
TRAPHANDLER(pgflt_handler, 14)
TRAPHANDLER_NOEC(fperr_handler, 16)
TRAPHANDLER(align_handler, 17)
TRAPHANDLER_NOEC(mchk_handler, 18)
TRAPHANDLER_NOEC(simderr_handler, 19)
TRAPHANDLER_NOEC(syscall_handler, 48)


/*
 * Lab 3: Your code here for _alltraps
 */
.global _alltraps
_alltraps:
	# Build trap frame
	pushl %ds
	pushl %es
	pushal

	# Set up data segments
	movw $(GD_KD), %ax
	movw %ax, %ds
	movw %ax, %es

	# Call trap(tf)
	pushl %esp
	call trap


