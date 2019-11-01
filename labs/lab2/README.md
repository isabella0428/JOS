

## Lab2 Booting a PC

In this lab, we are going to write memory management code for our JOS!!

It is divided into three parts, physical page management, virtual memory and kernel address space.



#### Part1	Physical Page Management

##### Exercise 1	

In the file `kern/pmap.c`, you must implement code for the following functions (probably in the order given).

```
`boot_alloc()`
`mem_init()` (only up to the call to `check_page_free_list(1)`)
`page_init()`
`page_alloc()`
`page_free()
```

`check_page_free_list()` and `check_page_alloc()` test your physical page allocator. You should boot JOS and see whether `check_page_alloc()`reports success. Fix your code so that it passes. You may find it helpful to add your own `assert()`s to verify that your assumptions are correct.



##### Answer

1. boot_alloc

In this function, we allocate a contiguous chunk of memory for kernel page table directory.

When the end of the contiguous chunk does not exceed the maximum physical memory capacity, we return the start of the memory chunk, or we should send the panic message to tell the user that we are running out of memory.

If we try to print out the result value, we can get `f0115000`. Recall that in lab1 kern/entry.S, we know that the c code is linked to run from `[KERNBASE, KERNBASE + 1M]` and the physical memory is from [0, 1M]. So boot_alloc actually return virtual address which is linear of physical address.

```c
static void *
boot_alloc(uint32_t n)
{
  ...........
    
  // Allocate a chunk large enough to hold 'n' bytes, then update
  // nextfree.  Make sure nextfree is kept aligned
  // to a multiple of PGSIZE.
  //
	result = nextfree;			// Start address of the allocated contiguous memory block
	nextfree = ROUNDUP(nextfree + n, PGSIZE);
	if ((uint32_t)nextfree - KERNBASE > (npages * PGSIZE))	// The allocated space exceeds total physical memory
		panic("Out of memory!");

  return result;
}
```



2. mem_init

We allocate an array of PageInfos. To reuse the code, we use the function `boot_alloc` to allocate the contiguous chunk of memory and initialize them with 0.

```c
void
mem_init(void)
{
  ..........
    
  //////////////////////////////////////////////////////////////////////
	// Allocate an array of npages 'struct PageInfo's and store it in 'pages'.
	// The kernel uses this array to keep track of physical pages: for
	// each physical page, there is a corresponding struct PageInfo in this
	// array.  'npages' is the number of physical pages in memory.  Use memset
	// to initialize all fields of each struct PageInfo to 0.
	// Your code goes here:
	pages = boot_alloc(npages * sizeof(struct PageInfo *));
	memset(pages, 0, npages * sizeof(struct PageInfo *));
  
  ............
}
```



3. page_init

According to the description above, now we need to initialize PageInfo for each physical pages.

a. First Page is occupied (for important things like BIOS, real-mode interrupt descriptor table)

b. Rest of base memory, [PGSIZE, npages_basemem * PGSIZE] is free.

c. IO mapped region is allocated

d. First part of extended memory is allocated — For kernel page table

e. rest of extended memory is free

```c
void
page_init(void)
{
	// The example code here marks all physical pages as free.
	// However this is not truly the case.  What memory is free?
	//  1) Mark physical page 0 as in use. (in use:	1)
	//     This way we preserve the real-mode IDT and BIOS structures
	//     in case we ever need them.  (Currently we don't, but...)
	//  2) The rest of base memory, [PGSIZE, npages_basemem * PGSIZE)
	//     is free.
	//  3) Then comes the IO hole [IOPHYSMEM, EXTPHYSMEM), which must
	//     never be allocated.(So IO hole are occupied)
	//  4) Then extended memory [EXTPHYSMEM, ...).
	//     Some of it is in use, some is free. Where is the kernel
	//     in physical memory?  Which pages are already in use for
	//     page tables and other data structures?
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
		for (i = 0; i < npages; i++)
	{
		// number of pages in IO-mapped address range
		int npages_IO = (EXTPHYSMEM - IOPHYSMEM + PGSIZE - 1) / PGSIZE;
		// number of pages of kern_pgdir
		int npages_kern = ((uint32_t)boot_alloc(0) - KERNBASE + PGSIZE - 1) / PGSIZE;

		// if it is in IO hole
		int is_IO_hole = i >= npages_basemem && i <= npages_basemem + npages_IO ;
		// if it is occupied by kernel
		int is_kernel_pgdir = (i >= npages_basemem + npages_IO && i <= npages_basemem + npages_IO + npages_kern);
		
		if (i == 0 || is_IO_hole || is_kernel_pgdir) {
			pages[i].pp_ref = 1;
		}
		else 
		{
			// The rest of base memory, [PGSIZE, npages_basemem * PGSIZE) is free
			// The rest of extended memory is free
			pages[i].pp_ref = 0;
			pages[i].pp_link = page_free_list;
			page_free_list = &pages[i];
		}
	}
}
```



4. page_alloc

Here we allocate a new page.

First we get the first page from the `page_free_list`. Then we remove the newly allocated page from `page_free_list`.If the allocated flag is set, we `memset` the newly allocated address with `'0'`.Finally, we return the newly allocated page's kernel virtual address.

Notice here that we should `memset`  the virtual address of the page, so we use `page2kva` to convert it.



Let's see how `page2kva` works.

```c
static inline void*
page2kva(struct PageInfo *pp)
{
	return KADDR(page2pa(pp));
}
```

First, it use `page2pa` to get the offset address from pages to pp , which is equal to pages's physical address.  Then it convert pages to its kernel virtual address.



Now see the complete codes  :D

```c
struct PageInfo *
page_alloc(int alloc_flags)
{
	// Fill this function in
	struct PageInfo *new_page;

	new_page = page_free_list;

	// Panic if out of free memory
	if (new_page == NULL) {
		return NULL;
	}

	page_free_list = new_page->pp_link;
	new_page->pp_link = NULL;


	// If (alloc_flags & ALLOC_ZERO), fills the entire
	// returned physical page with '\0' bytes.
	if(alloc_flags && ALLOC_ZERO)
	{
		memset(page2kva(new_page), '\0', PGSIZE);
	}

	return new_page;
}
```



5. page_free

This one is not so hard. All we have to do is to add pp to `page_free_list` .

```c
void
page_free(struct PageInfo *pp)
{
	// Fill this function in
	// Hint: You may want to panic if pp->pp_ref is nonzero or
	// pp->pp_link is not NULL.
	if (pp->pp_ref != 0 || pp->pp_link != NULL) {
		panic("Cannot free this page!");
	}

	pp->pp_link = page_free_list;
	page_free_list = pp;
}
```



##### Exercise 2

Look at chapters 5 and 6 of the [Intel 80386 Reference Manual](https://pdos.csail.mit.edu/6.828/2018/readings/i386/toc.htm), if you haven't done so already. Read the sections about page translation and page-based protection closely (5.2 and 6.4). We recommend that you also skim the sections about segmentation; while JOS uses the paging hardware for virtual memory and protection, segment translation and segment-based protection cannot be disabled on the x86, so you will need a basic understanding of it.

##### Answer:

In this part, I read Chapter 5, 6 in book [i386.pdf](https://www.cs.hmc.edu/~rhodes/courses/cs134/sp19/readings/i386.pdf). It introduces segment translation and page translations i. I386， which is useful for following exercises.



##### Exercise 3

While GDB can only access QEMU's memory by virtual address, it's often useful to be able to inspect physical memory while setting up virtual memory. Review the QEMU [monitor commands](https://pdos.csail.mit.edu/6.828/2018/labguide.html#qemu) from the lab tools guide, especially the `xp`command, which lets you inspect physical memory. To access the QEMU monitor, press Ctrl-a c in the terminal (the same binding returns to the serial console).

Use the` xp` command in the QEMU monitor and the `x` command in GDB to inspect memory at corresponding physical and virtual addresses and make sure you see the same data.

Our patched version of QEMU provides an `info pg` command that may also prove useful: it shows a compact but detailed representation of the current page tables, including all mapped memory ranges, permissions, and flags. Stock QEMU also provides an` info` mem command that shows an overview of which ranges of virtual addresses are mapped and with what permissions.

##### Answer:

In order to get familiar with xp command, I set the breakpoint in gdb.

Make sure u set the breakpoint after we set cr3 register.

Then we print out 8 words in these two address. We can now see that the virtual address is now mapped to physical address.

```
(gdb) x/8x  0x00100000
0x100000:       0x1badb002      0x00000000      0xe4524ffe     0x7205c766
0x100010:       0x34000004      0x3000b812      0x220f0011     0xc0200fd8
(gdb) x/8x  0xf0100000
0xf0100000 			0x1badb002      0x00000000    	0xe4524ffe     0x7205c766
0xf0100010   		0x34000004      0x3000b812      0x220f0011     0xc0200fd8
```

Then we try `info pg` command in qemu monitor console.(That means u should press 'Ctrl + a c' to switch from normal qemu mode to monitor mode).

```
(qemu) info pg
VPN range     Entry         Flags        Physical page
[00000-003ff]  PDE[000]     ----A----P
  [00000-00000]  PTE[000]     --------WP 00000
  [00001-0009f]  PTE[001-09f] ---DA---WP 00001-0009f
  [000a0-000b7]  PTE[0a0-0b7] --------WP 000a0-000b7
  [000b8-000b8]  PTE[0b8]     ---DA---WP 000b8
  [000b9-000ff]  PTE[0b9-0ff] --------WP 000b9-000ff
  [00100-00102]  PTE[100-102] ----A---WP 00100-00102
  [00103-00111]  PTE[103-111] --------WP 00103-00111
  [00112-00112]  PTE[112]     ---DA---WP 00112
  [00113-00114]  PTE[113-114] --------WP 00113-00114
  [00115-00156]  PTE[115-156] ---DA---WP 00115-00156
  [00157-00237]  PTE[157-237] --------WP 00157-00237
  [00238-003ff]  PTE[238-3ff] ---DA---WP 00238-003ff
[f0000-f03ff]  PDE[3c0]     ----A---WP
  [f0000-f0000]  PTE[000]     --------WP 00000
  [f0001-f009f]  PTE[001-09f] ---DA---WP 00001-0009f
  [f00a0-f00b7]  PTE[0a0-0b7] --------WP 000a0-000b7
  [f00b8-f00b8]  PTE[0b8]     ---DA---WP 000b8
  [f00b9-f00ff]  PTE[0b9-0ff] --
```

As describes in tool guide provided by the lab website, we can know that we have two page directories up till now, [00000-003ff] and [f0000-f03ff]. And the rest are page table entries.

Finally, let's try out command `info mem`

```
(qemu) info mem
0000000000000000-0000000000400000 0000000000400000 -r-
00000000f0000000-00000000f0400000 0000000000400000 -rw
```

The first memory chunk is mapped read permission, only kernel-visible.

The second memory chunk is mapped read write permission, but also only kernel-visible.



##### Question

1. Assuming that the following JOS kernel code is correct, what type should variable `x` have, `uintptr_t` or `physaddr_t`?

   ```c
   mystery_t x;
   	char* value = return_a_pointer();
   	*value = 10;
   	x = (mystery_t) value;
   ```

##### Answer:

It should be `uintptr_t`. Since the code is correct and we do dereference value above, value should be virtual address. So `mystery_t` is  `uintptr_t`.



##### Exercise 4

In the file `kern/pmap.c`, you must implement code for the following functions.

```
        pgdir_walk()
        boot_map_region()
        page_lookup()
        page_remove()
        page_insert()
	
```

`check_page()`, called from `mem_init()`, tests your page table management routines. You should make sure it reports success before proceeding.

##### Answer:

1. pgdir_walk()

Let's start with pgdir_walk, which is also the core function in this part. Given `pgdir`, a pointer to a page directory table, we are going to find the corresponding page table entry pointer.

According to the  supplyment materials provided on the website, we know that page translation is divided into two different parts, page directory and page table. You can also regard it as two different level page tables.

Recall that we set the virtual address equal to the linear address before by setting the base address to zero.

![image-20191101104124171](/Users/isabella/Desktop/JOS/labs/lab2/README.assets/image-20191101104124171.png)

Using different parts of linear address, we can get the offset in these two level page tables and find the corresponding physical address. 

For example, by adding the offset DIR to pgdir, we get the address of corresponding page directory entry. Using the page directory entry, we can get the adress of page table we want. Then by adding offset PAGE to page table address, we get the address of page table entry.  With page table entry, we can remove the permission bit of it and finally get the physical address of the page we want.

![image-20191101104649285](/Users/isabella/Desktop/JOS/labs/lab2/README.assets/image-20191101104649285.png)



Then comes the code.

```c
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
	pde_t *pg_dir_entry = (pde_t *)(pgdir + (unsigned int)PDX(va));
	struct PageInfo *new_page;
	uintptr_t offset;
	pte_t* page_base;

	if(!(*pg_dir_entry) & PTE_P) {
		// If page table doesn't exist and it is not allowed 
		// to create a new one, return NULL
		if (create == false)
			return NULL;

		// Allocate a new page and if succeeds, add the new page's reference by one
		new_page = page_alloc(1);
		if(new_page == NULL)
			return NULL;
		new_page->pp_ref ++;
		*pg_dir_entry = ((page2pa(new_page)) | PTE_P | PTE_W | PTE_U);
	}

	offset = PTX(va);
	page_base = KADDR(PTE_ADDR(*pg_dir_entry));
	return &page_base[offset];
}
```



2. boot_map_region()

After finishing pgdir_walk, this part is much easier. We just need to iterate over the whole chunk of address space and do the mapping.

```c
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
	// Fill this function in
	int num_pages = size / PGSIZE;
	pte_t  * pt_entry;
	for(int i = 0; i < num_pages; ++i) {
		pt_entry = pgdir_walk(pgdir, (void *)(va + i * PGSIZE), 1);
		*pt_entry = (pa + i * PGSIZE) | PTE_P | perm;
	}
}
```



3. page_lookup()

There we just have to use page table entry with `pgdir_walk` and return the pageInfo of the address.

To find the Page Info, we first get the physical address of the page and calculate the offset of the page in `page` array.

```c
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
	// Fill this function in
	pte_t *pt_entry = pgdir_walk(pgdir, va, false);
	struct PageInfo *ret;

	if(pt_entry == NULL)
		return NULL;
	
	if(!(*pt_entry & PTE_P))
		return NULL;

	if(pte_store != NULL)
		*pte_store = pt_entry;

	ret =  pa2page(PTE_ADDR(*pt_entry));
	return ret;
}
```



4. page_remove

Here we first check if the page exists. If not, do nothing. If exists, we decrease PageInfo 's reference by one and invalidate tlb. 

```c
void
page_remove(pde_t *pgdir, void *va)
{
	// Fill this function in
	pte_t * pte_store;
	struct PageInfo *page = page_lookup(pgdir, va, &pte_store);
	if(page == NULL)
		return;
	page_decref(page);
	tlb_invalidate(pgdir,  va);
	*pte_store = 0;
}
```



5. page_insert()

Here we  need to insert page `pp` to address `va`.  First, we get the page table entry with `pgdir_walk` we have implemented already.  Note that if there is a page exist in the address we want, invalidte tlb and remove it. Finally add the address to the entry and remember to enable the page directory entry!

```c
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
	// Fill this function in
	pte_t *pt_entry = pgdir_walk(pgdir, (void *)va, 1);
	if (pt_entry == NULL) {
		return -E_NO_MEM;
	}

	pp->pp_ref++;
	if (*pt_entry & PTE_P)
	{
		tlb_invalidate(pgdir, va);
		page_remove(pgdir, va);
	}

	*pt_entry = page2pa(pp) | perm | PTE_P;
	// Also enable pagetable directory entry
	pgdir[PDX(va)] |= perm | PTE_P;
	return 0;
}
```

