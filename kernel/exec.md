# 进程启动

## exec 系统调用

```mermaid
graph LR
A[do_execve] --> B[do_execveat_common]
C[do_execveat] --> B
B --> D[alloc_bprm]
D --> E[bprm_mm_init]
E --> F[mm_alloc]
B --> G["copy_*"]
B --> H[**bprm_execve]
I[kernel_execve] --> J[getname_kernel]
I --> D
I --> H
K[run_init_process] --> I

subgraph umh.c
a[call_usermodehelper_exec_work] --> b{"sub_info->wait & UMH_WAIT_PROC"}
b --> |Y|[call_usermodehelper_exec_sync]
b --> |

end
```

struct linux_binprm
```
struct linux_binprm {
#ifdef CONFIG_MMU
	struct vm_area_struct *vma;
	unsigned long vma_pages;
#else
# define MAX_ARG_PAGES	32
	struct page *page[MAX_ARG_PAGES];
#endif
	struct mm_struct *mm;
	unsigned long p; /* current top of mem */
	unsigned long argmin; /* rlimit marker for copy_strings() */
	unsigned int
		/* Should an execfd be passed to userspace? */
		have_execfd:1,

		/* Use the creds of a script (see binfmt_misc) */
		execfd_creds:1,
		/*
		 * Set by bprm_creds_for_exec hook to indicate a
		 * privilege-gaining exec has happened. Used to set
		 * AT_SECURE auxv for glibc.
		 */
		secureexec:1,
		/*
		 * Set when errors can no longer be returned to the
		 * original userspace.
		 */
		point_of_no_return:1;
	struct file *executable; /* Executable to pass to the interpreter */
	struct file *interpreter;
	struct file *file;
	struct cred *cred;	/* new credentials */
	int unsafe;		/* how unsafe this exec is (mask of LSM_UNSAFE_*) */
	unsigned int per_clear;	/* bits to clear in current->personality */
	int argc, envc;
	const char *filename;	/* Name of binary as seen by procps */
	const char *interp;	/* Name of the binary really executed. Most
				   of the time same as filename, but could be
				   different for binfmt_{misc,script} */
	const char *fdpath;	/* generated filename for execveat */
	unsigned interp_flags;
	int execfd;		/* File descriptor of the executable */
	unsigned long loader, exec;

	struct rlimit rlim_stack; /* Saved RLIMIT_STACK used during exec. */

	char buf[BINPRM_BUF_SIZE];
} __randomize_layout;


struct linux_binfmt {
	struct list_head lh;
	struct module *module;
	int (*load_binary)(struct linux_binprm *);
	int (*load_shlib)(struct file *);
#ifdef CONFIG_COREDUMP
	int (*core_dump)(struct coredump_params *cprm);
	unsigned long min_coredump;	/* minimal dump size */
#endif
} __randomize_layout;
```