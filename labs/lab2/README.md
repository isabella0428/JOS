

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

