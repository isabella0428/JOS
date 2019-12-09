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







