## Lab3 User Environments

This lab is divided into two parts, user environments and exception handling and Page Faults, Breakpoints Exceptions, and System Calls.

#### Part A: User Environments and Exception Handling

**Exercise 1.** Modify `mem_init()` in `kern/pmap.c` to allocate and map the `envs` array. This array consists of exactly `NENV` instances of the `Env` structure allocated much like how you allocated the `pages` array. Also like the `pages` array, the memory backing `envs` should also be mapped user read-only at `UENVS` (defined in `inc/memlayout.h`) so user processes can read from this array.

You should run your code and make sure `check_kern_pgdir()` succeeds.

##### Answer

This exercise is much like exercise 1 in lab2.

Similarily, we just allocate an array `envs` to hold the pointers to each `Env` structure and map the `envs` to user address space.

```c
void
mem_init(void)
{
	........
	//////////////////////////////////////////////////////////////////////
	// Make 'envs' point to an array of size 'NENV' of 'struct Env'.
	// LAB 3: Your code here.
	envs = boot_alloc(NENV * sizeof(struct ENV*));
	.......
	//////////////////////////////////////////////////////////////////////
	// Map the 'envs' array read-only by the user at linear address UENVS
	// (ie. perm = PTE_U | PTE_P).
	// Permissions:
	//    - the new image at UENVS  -- kernel R, user R
	//    - envs itself -- kernel RW, user NONE
	// LAB 3: Your code here.
	boot_map_region(kern_pgdir, UENVS, PTSIZE, PADDR((void *)envs), PTE_U | PTE_P);
  .....
}
```



**Exercise 2.** In the file `env.c`, finish coding the following functions:

- `env_init()`

  Initialize all of the `Env` structures in the `envs` array and add them to the `env_free_list`. Also calls `env_init_percpu`, which configures the segmentation hardware with separate segments for privilege level 0 (kernel) and privilege level 3 (user).

- `env_setup_vm()`

  Allocate a page directory for a new environment and initialize the kernel portion of the new environment's address space.

- `region_alloc()`

  Allocates and maps physical memory for an environment

- `load_icode()`

  You will need to parse an ELF binary image, much like the boot loader already does, and load its contents into the user address space of a new environment.

- `env_create()`

  Allocate an environment with `env_alloc` and call `load_icode` to load an ELF binary into it.

- `env_run()`

  Start a given environment running in user mode.

As you write these functions, you might find the new cprintf verb `%e` useful -- it prints a description corresponding to an error code. For example,

```
	r = -E_NO_MEM;
	panic("env_alloc: %e", r);
```

will panic with the message "env_alloc: out of memory".



##### Answer:

Here we should inplement the critical functions of environment creations.

1. env_init

Initialization environments is similar to initialization of pages. 

Just link the environments tail by tail. Make sure that env[0] is at the head of the list.

Then we call `env_init_percpu` to load GDT and intializes the segment registers.

```c
void
env_init(void)
{
	// Set up envs array
	// LAB 3: Your code here.
	// Be sure to let envs[0] at the head of `env_free_list`
	env_free_list = NULL;

	for(int i = NENV - 1; i >= 0; --i) {
		envs[i].env_id = 0;
		envs[i].env_link = env_free_list;
		env_free_list = &envs[i];
	}

	// Per-CPU part of the initialization
	env_init_percpu();
}
```



2. env_setup_vm

In this function, we copy the kernel memory into our environment address space.

We can accoplish this by simply allocating a continuous space of size PGSIZE and copying the kernel page table to the environment page table.

In JOS, there is no separate kernel memory. We copy kernel memory each time when we create a new process.

```c
static int
env_setup_vm(struct Env *e)
{
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
		return -E_NO_MEM;
		
  	p->pp_ref++;
	// Allocate a page for this environment's page directory
	e->env_pgdir = (pde_t *)page2kva(p);
	// Map kernel memory into environment's page directory
	memcpy(e->env_pgdir, kern_pgdir, PGSIZE);

	// UVPT maps the env's own page table read-only.
	// Permissions: kernel R, user R
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;

	return 0;
}
```



4. region_alloc

Allocate len bytes of memory to our environment.

We accomplish this by allocating pages and inserting them to the virtual address starting from va.

```c
static void
region_alloc(struct Env * e, void *va, size_t len)
{
	char *start_address = ROUNDDOWN(va, PGSIZE);
	char *end_address = ROUNDUP(len, PGSIZE) + start_address;
	char *current_address = start_address;
	struct PageInfo *p;

	while (current_address < end_address)
	{
		if (!(p = page_alloc(0)))
			panic("Region Allocation for env %d failed", e->env_id);
		page_insert(e->env_pgdir, p, current_address, PTE_U | PTE_W);
		current_address += PGSIZE;
	}
}
```



5. load_icode

Since we haven't set up a file system yet, here we load the elf binary into our system instead. Like bootloader in `main.c`, we load each program segment into our environment.

Remember to change `cr3` when reading segments.

```c
static void
load_icode(struct Env *e, uint8_t *binary)
{
	struct Proghdr *ph, *eph;
	struct PageInfo *stack;
	struct Elf *ELFHDR = (struct Elf *)binary;
	if (ELFHDR->e_magic != ELF_MAGIC)
		panic("It is not a ELF format file!");

	ph = (struct Proghdr *)((uint8_t *)ELFHDR + ELFHDR->e_phoff);

	eph = ph + ELFHDR->e_phnum;

	// Load CR3 to this environment's page directory
	lcr3(PADDR(e->env_pgdir));

	for (; ph < eph; ph++)
	{
		if (ph->p_type != ELF_PROG_LOAD)
			continue;
		region_alloc(e, (void *)ph->p_va, ph->p_memsz);
		memset((void *)ph->p_va, 0, ph->p_memsz);
		memcpy((void *)ph->p_va, binary + ph->p_offset, ph->p_filesz);
	}

	// Make sure that the environment starts executing there
	e->env_tf.tf_eip = ELFHDR->e_entry;

	// Now map one page for the program's initial stack
	// at virtual address USTACKTOP - PGSIZE.

	// LAB 3: Your code here.
	lcr3(PADDR(kern_pgdir));
	region_alloc(e, (void *)USTACKTOP - PGSIZE, PGSIZE);
}
```



4. env_create

In this function, we just combine the `env_alloc` and `load_icode` functions. Allocate a new environment and read program segments into it.

```c
void
env_create(uint8_t *binary, enum EnvType type)
{
	// LAB 3: Your code here.
	struct Env *env;
	int result;

	// Allocates a new env with env_alloc
	result = env_alloc(&env, 0);
	if (result == -E_NO_FREE_ENV)
		panic("env_alloc: %e", result);

	if (result == -E_NO_MEM)
		panic("env_alloc: %e", result);

	//Loads the named elf binary into it with load_icode
	load_icode(env, binary);

	//Set the newly allocated env's type
	env->env_type = type;
}
```



5. env_run

Switch environments and set the new environment's registers.

```c
void
	env_run(struct Env * e)
{
	if (curenv != NULL && curenv->env_status == ENV_RUNNING)
		curenv->env_type = ENV_RUNNABLE;

	// Set 'curenv' to the new environment
	curenv = e;

	// Set its status to ENV_RUNNING,
	curenv->env_type = ENV_RUNNING;

	// Update its 'env_runs' counter
	curenv->env_runs++;

	// Use lcr3() to switch to its address space
	lcr3(PADDR(e->env_pgdir));

	// Use env_pop_tf() to restore the environment's
	//	   registers and drop into user mode in the
	//	   environment.
	env_pop_tf(&e->env_tf);

	panic("env_run not yet implemented");
}
```



**Evaluation** Use make qemu-gdb and set a GDB breakpoint at `env_pop_tf`, which should be the last function you hit before actually entering user mode. Single step through this function using si; the processor should enter user mode after the `iret` instruction. You should then see the first instruction in the user environment's executable, which is the `cmpl` instruction at the label `start` in `lib/entry.S`. Now use b *0x... to set a breakpoint at the `int $0x30` in `sys_cputs()` in `hello` (see `obj/user/hello.asm` for the user-space address). This `int` is the system call to display a character to the console. If you cannot execute as far as the `int`, then something is wrong with your address space setup or program loading code; go back and fix it before continuing.

##### Test

Enter gdb, see if we can successfully execute to the `int $0x30 ` instructions defined in user environment function `sys_calls`

```
(gdb) b env_pop_tf
Breakpoint 1 at 0xf0102e61: file kern/env.c, line 485.
(gdb) c
Continuing.
The target architecture is assumed to be i386
=> 0xf0102e61 <env_pop_tf>:     push   %ebp

Breakpoint 1, env_pop_tf (tf=0xf01f2000) at kern/env.c:485
485     {
(gdb) si
=> 0xf0102e62 <env_pop_tf+1>:   mov    %esp,%ebp
0xf0102e62      485     {
(gdb) si
=> 0xf0102e64 <env_pop_tf+3>:   sub    $0xc,%esp
0xf0102e64      485     {
(gdb) si
=> 0xf0102e67 <env_pop_tf+6>:   mov    0x8(%ebp),%esp
486             asm volatile(
(gdb) si
=> 0xf0102e6a <env_pop_tf+9>:   popa   
0xf0102e6a      486             asm volatile(
(gdb) si
=> 0xf0102e6b <env_pop_tf+10>:  pop    %es
0xf0102e6b in env_pop_tf (
    tf=<error reading variable: Unknown argument list address for `tf'.>) at kern/env.c:486
486             asm volatile(
(gdb) si
=> 0xf0102e6c <env_pop_tf+11>:  pop    %ds
0xf0102e6c      486             asm volatile(
(gdb) si
=> 0xf0102e6d <env_pop_tf+12>:  add    $0x8,%esp
0xf0102e6d      486             asm volatile(
(gdb) si
=> 0xf0102e70 <env_pop_tf+15>:  iret   
0xf0102e70      486             asm volatile(
(gdb) info register
eax            0x0                 0
ecx            0x0                 0
edx            0x0                 0
ebx            0x0                 0
esp            0xf01f2030          0xf01f2030
ebp            0x0                 0x0
esi            0x0                 0
edi            0x0                 0
eip            0xf0102e70          0xf0102e70 <env_pop_tf+15>
eflags         0x96                [ PF AF SF ]
cs             0x8                 8
ss             0x10                16
ds             0x23                35
es             0x23                35
fs             0x23                35
gs             0x23                35
(gdb) si
=> 0x800020:    cmp    $0xeebfe000,%esp			//first instruction we execute in entry.S
0x00800020 in ?? ()													//See if we were started with arguments on the stack
	cmpl $USTACKTOP, %esp

(gdb) info register
eax            0x0                 0
ecx            0x0                 0
edx            0x0                 0
ebx            0x0                 0
esp            0xeebfe000          0xeebfe000
ebp            0x0                 0x0
esi            0x0                 0
edi            0x0                 0
eip            0x800020            0x800020
eflags         0x2                 [ ]
cs             0x1b                27
ss             0x23                35
ds             0x23                35
es             0x23                35
fs             0x23                35
gs             0x23                35
```

Here we can see the register value are changed after we enter the user mode.

The code segment register's value correspond to the definition in function `env_alloc`

```c
int
env_alloc(struct Env * *newenv_store, envid_t parent_id)
{
	............
	e->env_tf.tf_ds = GD_UD | 3;
	e->env_tf.tf_es = GD_UD | 3;
	e->env_tf.tf_ss = GD_UD | 3;
	e->env_tf.tf_esp = USTACKTOP;
	e->env_tf.tf_cs = GD_UT | 3;
	...........
}
```

Then we continue executing. 

Finally we are able to execute to this instruction, which means we did it :-D

```
(gdb) si
=> 0x800a0a:    int    $0x30
0x00800a0a in ?? ()
```

