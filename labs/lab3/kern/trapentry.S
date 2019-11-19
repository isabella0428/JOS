/* See COPYRIGHT for copyright information. */

#include <inc/mmu.h>
#include <inc/memlayout.h>
#include <inc/trap.h>



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
TRAPHANDLER_NOEC(t_divide, T_DIVIDE);	// 0  divide error
TRAPHANDLER_NOEC(t_debug,  T_DEBUG);	// 1  debug exception
TRAPHANDLER_NOEC(t_nmi, T_NMI);			// 2  non-maskable interrupt
TRAPHANDLER_NOEC(t_brkpt, T_BRKPT);		// 3  breakpoint
TRAPHANDLER_NOEC(t_oflow, T_OFLOW);		// 4  overflow
TRAPHANDLER_NOEC(t_bound, T_BOUND);		// 5  bounds check	
TRAPHANDLER_NOEC(t_illop, T_ILLOP);		// 6  illegal opcode
TRAPHANDLER_NOEC(t_device, T_DEVICE);	// 7  device not available

TRAPHANDLER(t_dblflt, T_DBLFLT);		// 8  double fault
TRAPHANDLER(t_tss, T_TSS);				// 10 invalid task switch segment
TRAPHANDLER(t_segnp, T_SEGNP);			// 11 segment not present
TRAPHANDLER(t_stack, T_STACK);			// 12 stack exception
TRAPHANDLER(t_gpflt, T_GPFLT);			// 13 general protection fault
TRAPHANDLER(t_pgflt, T_PGFLT);			// 14 page fault

TRAPHANDLER_NOEC(t_fperr, T_FPERR);		// 16 floating point error

TRAPHANDLER(t_align, T_ALIGN);			// 17 aligment check

TRAPHANDLER_NOEC(t_mchk, T_MCHK);		// 18 machine check
TRAPHANDLER_NOEC(t_simderr, T_SIMDERR);	// 19 SIMD floating point error
TRAPHANDLER_NOEC(t_syscall, T_SYSCALL);	// 48 SIMD floating point error

 
/* Lab 3: Your code here for _alltraps */
_alltraps:
	// 1. push values to make the stack look like a struct Trapframe
    pushl %ds
    pushl %es
    pushal

	// 2. load GD_KD into %ds and %es
    movw $GD_KD, %ax
    movw %ax, %ds
    movw %ax, %es

	// 3. pushl %esp to pass a pointer to the Trapframe as an argument to trap()
	pushl %esp

	// 4. call trap
    call trap