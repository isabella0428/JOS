## Lab4 Preemptive Multitasking

In this lab we will implement preemptive multitasking among multiple simultaneously active user-mode environments.

In part A we will add multiprocessor support to JOS, implement round-robin scheduling, and add basic environment management system calls (calls that create and destroy environments, and allocate/map memory).

In part B, we will implement a Unix-like `fork()`, which allows a user-mode environment to create copies of itself.

Finally, in part C we will add support for inter-process communication (IPC), allowing different user-mode environments to communicate and synchronize with each other explicitly. You will also add support for hardware clock interrupts and preemption.



#### Part A Multiprocessor Support and Cooperative Multitasking

##### Multiprocessor Support

**Exercise 1.** Implement `mmio_map_region` in `kern/pmap.c`. To see how this is used, look at the beginning of `lapic_init` in `kern/lapic.c`. You'll have to do the next exercise, too, before the tests for `mmio_map_region` will run.

```c
void *
mmio_map_region(physaddr_t pa, size_t size)
{
    static uintptr_t base = MMIOBASE;
    uintptr_t prev_base = base;

    // return (void *)prev_base;
    uintptr_t next_base = ROUNDUP(base + size, PGSIZE);
    base = ROUNDDOWN(base, PGSIZE);

    physaddr_t pa_end = ROUNDUP(pa + size, PGSIZE);
    pa = ROUNDDOWN(pa, PGSIZE);

    if (base + size > MMIOLIM)
        panic("MMIO region exceeds MMIOLIM!");

    boot_map_region(kern_pgdir, base, (size_t)(pa_end - pa),
                    pa, PTE_PCD | PTE_PWT | PTE_W);
    base = next_base;

    return (void *)prev_base;
}

```





##### Application Processor Bootstrap

**Exercise 2.** Read `boot_aps()` and `mp_main()` in `kern/init.c`, and the assembly code in `kern/mpentry.S`. Make sure you understand the control flow transfer during the bootstrap of APs. Then modify your implementation of `page_init()` in `kern/pmap.c` to avoid adding the page at `MPENTRY_PADDR` to the free list, so that we can safely copy and run AP bootstrap code at that physical address. Your code should pass the updated `check_page_free_list()` test (but might fail the updated `check_kern_pgdir()` test, which we will fix soon).

##### Answer:

Here we just need to add to line codes to mark `MPENTRY_PADDR` as occupied.

```c
void
page_init(void)
{
	// LAB 4:
	// Change your code to mark the physical page at MPENTRY_PADDR
	// as in use

	size_t i;
	for (i = 0; i < npages; i++)
	{
    ..........
    // Make MPENTRY_PADDR as occupied
		int is_MPENTRY_PADDR = i == ROUNDDOWN(MPENTRY_PADDR, PGSIZE) / PGSIZE;

			if (i == 0 || is_IO_hole || is_kernel_pgdir ||is_MPENTRY_PADDR)
		{
			pages[i].pp_ref = 1;
		}
		else 
		{
			....................
		}
	}
}
```

As is mentioned in the exercise description, we passed `check_page_free_list` but failed in `check_kern_pgdir` test.

```
(process:51584): GLib-WARNING **: 21:10:02.065: ../glib/gmem.c:490: custom memory allocation vtable not supported
6828 decimal is XXX octal!
Physical memory: 131072K available, base = 640K, extended = 130432K
check_page_free_list() succeeded!
check_page_alloc() succeeded!
kernel panic on CPU 0 at kern/pmap.c:1085: assertion failed: check_va2pa(kern_pgdir, mm1) == 0
Welcome to the JOS kernel monitor!
Type 'help' for a list of commands.
```



##### Question

**Q1:** Compare `kern/mpentry.S` side by side with `boot/boot.S`. Bearing in mind that `kern/mpentry.S` is compiled and linked to run above `KERNBASE` just like everything else in the kernel, what is the purpose of macro `MPBOOTPHYS`? Why is it necessary in `kern/mpentry.S` but not in `boot/boot.S`? In other words, what could go wrong if it were omitted in `kern/mpentry.S`?
Hint: recall the differences between the link address and the load address that we have discussed in Lab 1.

##### Answer:

`MPBOOTPHYS` is used to calculate the absolute address of global descriptor table of `mpentry.S`.

We explictly load `mpentry.S` to `MPENTRY_PADDR` before, so the load address of `mpentry` is `MPENTRY_PADDR`. 

But since we haven't set the link address yet, link address can be anything, so `gdtdesc` may not refer to the same physical address as that of the original loaded gdtdesc's.

To eliminate this bug, we replace the global descriptor table's physical address with absolute physical address instead of the one which relates to link address, which is equal to `MPENTRY_PADDR + gdtdesc - mpentry_start`.

In lab1, we can save this trouble. Recall Exercise5 in lab1, there is a line in configure file `Makefrag` that explicitly declares that the link address and load address of boot_loader should be the same.

```makefile
// boot/Makefrag
$(OBJDIR)/boot/boot: $(BOOT_OBJS)
	@echo + ld boot/boot
	$(V)$(LD) $(LDFLAGS) -N -e start -Ttext 0x7C00 -o $@.out $^
	$(V)$(OBJDUMP) -S $@.out >$@.asm
	$(V)$(OBJCOPY) -S -O binary -j .text $@.out $@
	$(V)perl boot/sign.pl $(OBJDIR)/boot/boot
```

```assembly
# Comment in boot/boot.S
# Start the CPU: switch to 32-bit protected mode, jump into C.
# The BIOS loads this code from the first sector of the hard disk into
# memory at physical address 0x7c00 and starts executing in real mode
# with %cs=0 %ip=7c00.
```

The BIOS loads the boot sector into memory starting at address 0x7c00, so this is the boot sector's load address. This is also where the boot sector executes from, so this is also its link address. We set the link address by passing `-Ttext 0x7C00` to the linker in `boot/Makefrag`, so the linker will produce the correct memory addresses in the generated code.



##### Per-CPU State and Initialization

**Exercise 3.** Modify `mem_init_mp()` (in `kern/pmap.c`) to map per-CPU stacks starting at `KSTACKTOP`, as shown in `inc/memlayout.h`. The size of each stack is `KSTKSIZE` bytes plus `KSTKGAP` bytes of unmapped guard pages. Your code should pass the new check in `check_kern_pgdir()`.

##### Answer:

Here we just need to align the start address and end address and map use `boot_map_region `to map them to the physical address `percpu_kstacks[i]`. Remember that we only map `KSTKSIZE` bytes and leave `KSTKGAP` as guard page.

```c
static void
mem_init_mp(void)
{
    for (int i = 0; i < NCPU; i++)
    {
        uintptr_t kstacktop_i = KSTACKTOP - i * (KSTKSIZE + KSTKGAP);
        boot_map_region(kern_pgdir,
                        kstacktop_i - KSTKSIZE,
                        KSTKSIZE,
                        PADDR(percpu_kstacks[i]),
                        PTE_W);
    }
}
```

Now we pass `check_kern_pgdir()`.

```
(process:64768): GLib-WARNING **: 09:09:34.938: ../glib/gmem.c:490: custom memory allocation vtable not supported
6828 decimal is XXX octal!
Physical memory: 131072K available, base = 640K, extended = 130432K
check_page_free_list() succeeded!
check_page_alloc() succeeded!
check_page() succeeded!
check_kern_pgdir() succeeded!
.............................
```



**Exercise 4.** The code in `trap_init_percpu()` (`kern/trap.c`) initializes the TSS and TSS descriptor for the BSP. It worked in Lab 3, but is incorrect when running on other CPUs. Change the code so that it can work on all CPUs. (Note: your new code should not use the global `ts` variable any more.)

##### Answer:

Here we have multiple cpus running at the same time. If we have traps, they should be handled in each cpu's own task segment. 

We need to change the global `ts` to each cpu's own task segment `thiscpu->cpu_ts`, change `gdt[(GD_TSS0 >> 3)]` to `gdt[(GD_TSS0 >> 3) + cpu_id]`. 

When we need to find the corresponding cpu task segment of each cpu, we shift the first task segment selector `GD_TSS0` to the right by three bits and add the cpu_id so that we can get its index in `gdt`, `(GD_TSS0 >> 3) + cpu_id`. When we shift the index to the left by 3 bits, we can get the task segment selector of the given cpu, `GD_TSS0 + 8 * cpu_id`. That is what we are going to load~

```c
// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
	uint8_t cpu_id = thiscpu->cpu_id;

	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
	thiscpu->cpu_ts.ts_esp0 = KSTACKTOP - cpu_id * (KSTKSIZE + KSTKGAP);
	thiscpu->cpu_ts.ts_ss0 = GD_KD;
	thiscpu->cpu_ts.ts_iomb = sizeof(struct Taskstate);

	// Initialize the TSS slot of the gdt.
	gdt[(GD_TSS0 >> 3) + cpu_id] = SEG16(STS_T32A, (uint32_t) (&ts),
					sizeof(struct Taskstate) - 1, 0);
	gdt[(GD_TSS0 >> 3) + cpu_id].sd_s = 0;

	// Load the TSS selector (like other segment selectors, the
	// bottom three bits are special; we leave them 0)
	ltr(GD_TSS0 + 8 * cpu_id);

	// Load the IDT
	lidt(&idt_pd);
}
```

We can see the right info printed in the console.

```
.........................
check_page() succeeded!
check_kern_pgdir() succeeded!
check_page_free_list() succeeded!
check_page_installed_pgdir() succeeded!
SMP: CPU 0 found 4 CPU(s)
enabled interrupts: 1 2
SMP: CPU 1 starting
SMP: CPU 2 starting
SMP: CPU 3 starting
.........................
```



##### Locking

Our current code spins after initializing the AP in `mp_main()`. Before letting the AP get any further, we need to first address race conditions when multiple CPUs run kernel code simultaneously. The simplest way to achieve this is to use a *big kernel lock*. The big kernel lock is a single global lock that is held whenever an environment enters kernel mode, and is released when the environment returns to user mode. In this model, environments in user mode can run concurrently on any available CPUs, but no more than one environment can run in kernel mode; any other environments that try to enter kernel mode are forced to wait.

`kern/spinlock.h` declares the big kernel lock, namely `kernel_lock`. It also provides `lock_kernel()` and `unlock_kernel()`, shortcuts to acquire and release the lock. You should apply the big kernel lock at four locations:

- In `i386_init()`, acquire the lock before the BSP wakes up the other CPUs.
- In `mp_main()`, acquire the lock after initializing the AP, and then call `sched_yield()` to start running environments on this AP.
- In `trap()`, acquire the lock when trapped from user mode. To determine whether a trap happened in user mode or in kernel mode, check the low bits of the `tf_cs`.
- In `env_run()`, release the lock *right before* switching to user mode. Do not do that too early or too late, otherwise you will experience races or deadlocks.



**Exercise 5.** Apply the big kernel lock as described above, by calling `lock_kernel()` and `unlock_kernel()` at the proper locations.

```c
void i386_init(void) {
...............
// Acquire the big kernel lock before waking up APs
// Your code here:
lock_kernel();
...............
}
```

```c
// Setup code for APs
void
mp_main(void)
{
	..................
	// Now that we have finished some basic setup, call sched_yield()
	// to start running processes on this CPU.  But make sure that
	// only one CPU can enter the scheduler at a time!
	//
	// Your code here:
	lock_kernel();
	sched_yield();
	.................
}
```

```c
void trap(struct Trapframe *tf) {
	..................
	cprintf("Incoming TRAP frame at %p\n", tf);
	if ((tf->tf_cs & 3) == 3) {
		// Trapped from user mode.	
		// (if it is in kernel mode, the low 2 bits are 0)
		// Acquire the big kernel lock before doing any
		// serious kernel work.
		// LAB 4: Your code here.
		assert(curenv);
		lock_kernel();

		// Garbage collect if current enviroment is a zombie
		if (curenv->env_status == ENV_DYING) {
			env_free(curenv);
			curenv = NULL;
			sched_yield();
		}

		// Copy trap frame (which is currently on the stack)
		// into 'curenv->env_tf', so that running the environment
		// will restart at the trap point.
		curenv->env_tf = *tf;
		// The trapframe on the stack should be ignored from here on.
		tf = &curenv->env_tf;
	}
	.................
}
```

```c
//
// Context switch from curenv to env e.
// Note: if this is the first call to env_run, curenv is NULL.
//
// This function does not return.
//
void
env_run(struct Env *e)
{
	......................................
	// We need to set e->env_tf.tf_eip! 
	unlock_kernel();
	env_pop_tf(&curenv->env_tf);
}
```



**Question**

It seems that using the big kernel lock guarantees that only one CPU can run the kernel code at a time. Why do we still need separate kernel stacks for each CPU? Describe a scenario in which using a shared kernel stack will go wrong, even with the protection of the big kernel lock.

##### Answer:

Since the lock we set is in `trap()`, it is not until we get into kernel and ready to handle trap when we ask for the lock. Suppose CPU0 and CPU1 are all making system calls, cpu0 first pushes its info onto kernel stack. Since cpu0 does not require the lock yet, cpu1 pushes its info onto the shared kernel stack again, which spoils cpu0's info.



##### Round-Robin Scheduling

**Exercise 6.** Implement round-robin scheduling in `sched_yield()` as described above. Don't forget to modify `syscall()` to dispatch `sys_yield()`.

Make sure to invoke `sched_yield()` in `mp_main`.

Modify `kern/init.c` to create three (or more!) environments that all run the program `user/yield.c`.

Run make qemu. You should see the environments switch back and forth between each other five times before terminating, like below.

Test also with several CPUS: make qemu CPUS=2.

```
...
Hello, I am environment 00001000.
Hello, I am environment 00001001.
Hello, I am environment 00001002.
Back in environment 00001000, iteration 0.
Back in environment 00001001, iteration 0.
Back in environment 00001002, iteration 0.
Back in environment 00001000, iteration 1.
Back in environment 00001001, iteration 1.
Back in environment 00001002, iteration 1.
...
```

After the `yield` programs exit, there will be no runnable environment in the system, the scheduler should invoke the JOS kernel monitor. If any of this does not happen, then fix your code before proceeding.

##### Answer:

First we need to implement function `sched_yield()`.

Start from the next to currrent env circularly check if the env's status is runnable. If we find one, switch to execute that environment, if not, continue executing this one.

One thing to notice, if we call `sched_yield` from `i386_init()`, there is no user environment running yet. So be careful that `curenv` is NULL at that time!

```c
void
sched_yield(void)
{
	int i = 0;

	// Decide if we're running the first user environment
	if (curenv != NULL)
		i = ENVX(curenv->env_id) + 1;

	for (; i < NENV; ++i)
	{
		if (envs[i].env_status == ENV_RUNNABLE) {
			env_run(&envs[i]);
			return;
		}
	}

	for (int i = 0; (curenv != NULL) && (i < ENVX(curenv->env_id)); ++i)
	{
		if (envs[i].env_status == ENV_RUNNABLE)
		{
			env_run(&envs[i]);
			return;
		}
	}

	if (curenv != NULL &&curenv->env_status == ENV_RUNNING)
		return;

	// sched_halt never returns
	sched_halt();
}
```

```
.........................................
Hello, I am environment 00001000.
Hello, I am environment 00001001.
Back in environment 00001000, iteration 0.
Hello, I am environment 00001002.
Back in environment 00001001, iteration 0.
Back in environment 00001000, iteration 1.
Back in environment 00001002, iteration 0.
Back in environment 00001001, iteration 1.
Back in environment 00001000, iteration 2.
Back in environment 00001002, iteration 1.
.........................................
```



**Question**

**Q1**:	In your implementation of `env_run()` you should have called `lcr3()`. Before and after the call to `lcr3()`, your code makes references (at least it should) to the variable `e`, the argument to `env_run`. Upon loading the `%cr3` register, the addressing context used by the MMU is instantly changed. But a virtual address (namely `e`) has meaning relative to a given address context--the address context specifies the physical address to which the virtual address maps. Why can the pointer `e` be dereferenced both before and after the addressing switch?

##### Answer:

Before and after the context switch, we are all using the user environment page table directory. Remember that we have copy kernel page table directory to each user environment page table directory. 

`envs` is allocated with `boot_alloc`, thus the address offset of `KernBase` and each user environment is absolute. So if we fix the virtual address of `KernBase `(defined in kernel page directory table), the virtual address of `e` is fixed.



**Q2:**	Whenever the kernel switches from one environment to another, it must ensure the old environment's registers are saved so they can be restored properly later. Why? Where does this happen?

#####  Answer:

Since we may go back to the old environment and execute it again, we must keep all the registers of the old environments saved.

We must execute `env_run()` in kernel mode, so we should have called trap(). When we were calling trap, it will execute following codes and push all the data onto the stack.

```assembly
// kern/trapentry.S

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
```



