

# flat文件生成

[toc]



```
# Makefile
%.o: %.S
   $(CC) $(CFLAGS) -c -nostdlib -o $@ $<
cstart.o = $(TEST_DIR)/cstart.o

# x86/Makefile.common
%.elf: LDFLAGS = -nostdlib $(arch_LDFLAGS)
%.elf: %.o $(FLATLIBS) $(SRCDIR)/x86/flat.lds $(cstart.o)
        $(LD) $(LDFLAGS) -T $(SRCDIR)/x86/flat.lds -o $@ \
                $(filter %.o, $^) $(FLATLIBS)
        @chmod a-x $@

%.flat: %.elf
        $(OBJCOPY) -O elf32-i386 $^ $@
        @chmod a-x $@

```



单个flat文件生成，使用make命令如下：

`make x86/debug.flat`

```
# 输出如下
# gcc 编译debug.c 为debug.o
gcc -mno-red-zone -mno-sse -mno-sse2  -fcf-protection=full -m64 -O1 -g -MMD -MF x86/.debug.d -fno-strict-aliasing -fno-common -Wall -Wwrite-strings -Wempty-body -Wuninitialized -Wignored-qualifiers -Wno-missing-braces -Werror  -fno-omit-frame-pointer  -fno-stack-protector    -Wno-frame-address   -fno-pic  -no-pie  -Wclobbered  -Wunused-but-set-parameter  -Wmissing-parameter-type  -Wold-style-declaration -Woverride-init -Wmissing-prototypes -Wstrict-prototypes -std=gnu99 -ffreestanding -I /home/kvm-unit-tests/lib -I /home/kvm-unit-tests/lib/x86 -I lib   -c -o x86/debug.o x86/debug.c

# ld 链接 libcflat.a cstart64.o debug.o
# /home/kvm-unit-tests/x86/flat.lds  链接器脚本
ld -nostdlib -m elf_x86_64 -T /home/kvm-unit-tests/x86/flat.lds -o x86/debug.elf \
        x86/debug.o x86/cstart64.o lib/libcflat.a
        
# objcopy 进行格式转换，将64位的elf，转化位elf32-i386格式的 debug.flat文件
objcopy -O elf32-i386 x86/debug.elf x86/debug.flat
```



##  cstart64.S（x86/cstart64.S）

```
.bss

        . = . + 4096 * max_cpus
        .align 16
stacktop:  //stacktop 变量位于.bss 之后， .data之前

.data

.code32
// 
mb_magic = 0x1BADB002
mb_flags = 0x0

        # multiboot header
        .long mb_magic, mb_flags, 0 - (mb_magic + mb_flags)
mb_cmdline = 16

// load_tss 
.macro load_tss
        movq %rsp, %rdi
        call setup_tss
        // 返回tss 在 gdt中的索引，存储在ax寄存器中
        ltr %ax
        /* LTR（Load/Store Task Register）是x86架构中的一种指令，用于将任务寄存器（Task Register）加载到指定寄存器中或者将指定寄存器的内容存储到任务寄存器中。任务寄存器是用于保存当前任务的状态信息的特殊寄存器，它保存了任务的选择子（索引描述符），用于指向全局描述符表（Global Descriptor Table）中的一个段描述符。

LTR指令包含一个操作数，它用于指定目标寄存器。当LTR指令执行时，它将从目标寄存器中读取选择子，并将该选择子用于加载任务段描述符。在加载任务寄存器后，指令将任务的状态从新任务中切换到当前任务。

该指令通常用于支持多任务操作系统。在多任务环境下，任务寄存器允许处理器在不同的任务之间进行切换，每个任务拥有自己的地址空间和上下文。LTR指令的实现方式取决于处理器的具体架构和实现方式。*/
.endm

.globl start
start:
        mov %ebx, mb_boot_info  // bootloader将multiboot 信息，写入了ebx 寄存器，这里将寄存器的内容，写入到了变量mb_boot_info
        mov $stacktop, %esp  //  stacktop地址 更新到 esp ，栈顶
        setup_percpu_area
        call prepare_64
        jmpl $8, $start64

// 32bit GDT 表 
gdt32:
        .quad 0   // .quad 伪指令，向当前内存写入0
        .quad 0x00cf9b000000ffff // flat 32-bit code segment
        .quad 0x00cf93000000ffff // flat 32-bit data segment
gdt32_end:


.code64
start64:
        call load_idt
        load_tss
        call reset_apic
        call mask_pic_interrupts
        call enable_apic
        call save_id
        // 从当前位置，获取mb_boot_info 地址，写入到rbx 中
        mov mb_boot_info(%rip), %rbx
        // 将rbx 中的mb_boot_info ， 写入rdi 寄存器
        mov %rbx, %rdi
        call setup_multiboot
        call setup_libcflat
        /* 这两句汇编的含义是：

1. 将 %rbx 寄存器加上 mb_cmdline 地址偏移量的值，得到一个指向命令行字符串的地址，然后将这个地址中的值存储到 %eax 寄存器中。

2. 将 %rax 寄存器中的值写入 __args 地址偏移量的位置，其中 __args 是一个相对于 RIP 寄存器的地址偏移量，即当前指令地址加上这个偏移量得到目标地址。这样就将命令行参数传递给了函数或程序。
*/
        mov mb_cmdline(%rbx), %eax
        mov %rax, __args(%rip)
        // 设置全局变量 __argc __argv
        call __setup_args
		
		// cpu 初始化
        call bsp_rest_init

        mov __argc(%rip), %edi
        lea __argv(%rip), %rs
        lea __environ(%rip), %rdx
        call main  // 调用main 函数
        mov %eax, %edi
        call exit
```

### load_idt (x86/desc.c)

```
// 加载idt 描述符表内存地址到idtr；
// idt_decr: 通过编译链接到elf，最终加载到data区域
lidt(&idt_descr);

asm volatile ("lidt %0" : : "m"(*ptr));

struct descriptor_table_ptr idt_descr = {
        .limit = sizeof(boot_idt) - 1,
        .base = (unsigned long)boot_idt,
};
idt_entry_t boot_idt[256] = {0};
```

### setup_percpu_area 

```
// 指定GS的位置为栈顶位置 -4K
.macro setup_percpu_area
        // 将esp -4 k的地址，放到 eax 
        lea -4096(%esp), %eax
        // edx 置0
        mov $0, %edx
        // MSR_GS_BASE = 0xc0000101
        // 0xc0000101 内容 写入到ecx
        mov $MSR_GS_BASE, %ecx
        // intel SDM v2: WRMSR: 将edx:eax 值写入到msr，msr index由ecx 寄存器指定
        wrmsr
.endm
```



### perpare_64

```
.macro load_absolute_addr, addr, reg
#ifdef CONFIG_EFI
        call 1f
1:
        pop \reg
        add \addr - 1b, \reg
#else
        mov \addr, \reg
#endif
.endm

.macro setup_segments
		// 读取$MSR_GS_BASE 到 edx:eax
        mov $MSR_GS_BASE, %ecx
        rdmsr

        mov $0x10, %bx
        mov %bx, %ds
        mov %bx, %es
        mov %bx, %fs
        mov %bx, %gs
        mov %bx, %ss
		
		// 重新写入
        /* restore MSR_GS_BASE */
        wrmsr
.endm


prepare_64:
        // 将gdt_descr 的 表地址，放到 edx
        load_absolute_addr $gdt_descr, %edx
        // gdtr 更新 执行gdt
        lgdtl (%edx)

		// 设置段寄存器
        setup_segments
		// 清空cr4
        xor %eax, %eax
        mov %eax, %cr4
```



### setup_tss



```
lib/x86/desc.h
// TSS_MAIN 是标记tss 的 gdt_entry是从0x80开始的 
#define TSS_MAIN 0x80

lib/x86/apic-defs.h:9:

#define MAX_TEST_CPUS (255)

lib/x86/desc.c
// 定义了x86_64 gdt 表的初始化
gdt_entry_t gdt[TSS_MAIN / 8 + MAX_TEST_CPUS * 2] = {
        {     0, 0, 0, .type_limit_flags = 0x0000}, /* 0x00 null */
        {0xffff, 0, 0, .type_limit_flags = 0xaf9b}, /* 0x08 64-bit code segment */
        {0xffff, 0, 0, .type_limit_flags = 0xcf93}, /* 0x10 32/64-bit data segment */
        {0xffff, 0, 0, .type_limit_flags = 0xaf1b}, /* 0x18 64-bit code segment, not present */
        {0xffff, 0, 0, .type_limit_flags = 0xcf9b}, /* 0x20 32-bit code segment */
        {0xffff, 0, 0, .type_limit_flags = 0x8f9b}, /* 0x28 16-bit code segment */
        {0xffff, 0, 0, .type_limit_flags = 0x8f93}, /* 0x30 16-bit data segment */
        {0xffff, 0, 0, .type_limit_flags = 0xcffb}, /* 0x38 32-bit code segment (user) */
        {0xffff, 0, 0, .type_limit_flags = 0xcff3}, /* 0x40 32/64-bit data segment (user) */
        {0xffff, 0, 0, .type_limit_flags = 0xaffb}, /* 0x48 64-bit code segment (user) */
};

tss64_t tss[MAX_TEST_CPUS] = {0};



/* Setup TSS for the current processor, and return TSS offset within GDT */
unsigned long setup_tss(u8 *stacktop)
{
        u32 id;
        tss64_t *tss_entry;

        id = pre_boot_apic_id();

        /* Runtime address of current TSS */
        /* 每个thread 都有一个apic id, 根据apic id 获取tss 结构 */
        tss_entry = &tss[id];                                                                                                                                 
        /* Update TSS */
        memset((void *)tss_entry, 0, sizeof(tss64_t));

        /* Update TSS descriptors; each descriptor takes up 2 entries */
        /* 将对应的tss entry地址 填入到gdt中，索引地址sel是“TSS_MAIN + id * 16”）
           gdt_entry_t *entry = &gdt[sel >> 3]; 
        */
        set_gdt_entry(TSS_MAIN + id * 16, (unsigned long)tss_entry, 0xffff, 0x89, 0);                                                                         
        return TSS_MAIN + id * 16;
}


// pre_boot_apic_id (lib/x86/apci.c)
// 汇编指令夺取apic id
// 每个logic processor都有apic id
// ./apic-defs.h:21:#define APIC_EXTD              (1UL << 10) # 判断是否enable x2apic mode
uint32_t pre_boot_apic_id(void)
{
        u32 msr_lo, msr_hi;

        asm ("rdmsr" : "=a"(msr_lo), "=d"(msr_hi) : "c"(MSR_IA32_APICBASE));

        return (msr_lo & APIC_EXTD) ? x2apic_id() : xapic_id();
}

xapic_id -> xapic_read(APIC_ID) >> 24
               -> *(volatile u32 *)(g_apic + reg);
                g_apic = APIC_DEFAULT_PHYS_BASE
                
// APIC_BASE_MSR + reg/16 = 802H，即读取apic的 msr index
// 注：为啥用APIC_ID/16 这种方式？ 答：与kernel定义一致
x2apic_id -> x2apic_read(APIC_ID)
              -> asm volatile ("rdmsr" : "=a"(a), "=d"(d) : "c"(APIC_BASE_MSR + reg/16));

// "lib/x86/apic-defs.h"
// 注：与linux kernel (arch/x86/include/asm/apicdef.h)定义一致的
#define APIC_DEFAULT_PHYS_BASE          0xfee00000
#define IO_APIC_DEFAULT_PHYS_BASE       0xfec00000
... 
#define APIC_ID         0x20

...
#define APIC_BASE_MSR   0x800


void set_gdt_entry(int sel, unsigned long base,  u32 limit, u8 type, u8 flags)
{
        // 根据sel 获取gdt entry 地址，gdt entry size是2 ** 3，所以左移3位
        gdt_entry_t *entry = &gdt[sel >> 3];

        /* Setup the descriptor base address */
        entry->base1 = (base & 0xFFFF);
        entry->base2 = (base >> 16) & 0xFF;
        entry->base3 = (base >> 24) & 0xFF;

        /* Setup the descriptor limits, type and flags */
        entry->limit1 = (limit & 0xFFFF);
        entry->type_limit_flags = ((limit & 0xF0000) >> 8) | ((flags & 0xF0) << 8) | type;

#ifdef __x86_64__
        if (!entry->s) {
                struct system_desc64 *entry16 = (struct system_desc64 *)entry;
                entry16->zero = 0;
                entry16->base4 = base >> 32;
        }
#endif
}
```



## [TODO] bsp_rest_init

bsp: bootstrap processor 初始化处理器

MP 初始化协议定义了两类处理器：引导处理器 （BSP） 和应用处理器 （AP）。在 MP 系统通电或重置后，系统硬件动态选择系统总线上的一个处理器作为 BSP。其余处理器被指定为 AP。

```
void bsp_rest_init(void)
{
        bringup_aps();
        enable_x2apic(); // 设置对应的msr，以及ops
        smp_init();
        pmu_init();
}
```

### bringup_aps

```
        /* INIT */
        // #define         APIC_DEST_ALLBUT        0xC0000 （所有的除了自己）
        // #define         APIC_DEST_PHYSICAL      0x00000  （物理模式）
        // #define         APIC_DM_INIT            0x00500  (delivery mode: INIT)
        // #define         APIC_INT_ASSERT         0x04000   (Level)
        apic_icr_write(APIC_DEST_ALLBUT | APIC_DEST_PHYSICAL | APIC_DM_INIT | APIC_INT_ASSERT, 0);

        /* SIPI */
        apic_icr_write(APIC_DEST_ALLBUT | APIC_DEST_PHYSICAL | APIC_DM_STARTUP, 0);


apic_icr_write -> x2apic_icr_write/xapic_icr_write

static void x2apic_icr_write(u32 val, u32 dest)
{
        mb();
        asm volatile ("wrmsr" : : "a"(val), "d"(dest),
                      "c"(APIC_BASE_MSR + APIC_ICR/16));
}

```

####  Interrupt Command Register (ICR)  

ICR是local apic 寄存器，允许通过软件编程方式发送IPI给其他的processor。

In XAPIC mode the ICR is addressed as two 32-bit registers, ICR_LOW (FFE0 0300H) and ICR_HIGH (FFE0 0310H). In x2APIC mode,
the ICR uses MSR 830H.  

详见： SDM v3 11.6.1 Interrupt Command Register (ICR)  



![image-20230505173759068](imgs\apic-icr.png)

### IPI (ISSUING INTERPROCESSOR INTERRUPTS )

以下部分介绍了本地APIC提供的用于发出软件中的处理器间中断(IPIs) 的设施。用于发出IPIs的主要本地APIC设施是中断命令寄存器(ICR)。ICR可用于以下功能：

- 发送一个中断到另一个处理器。 
- 允许处理器将接收但未处理的中断转发到另一个处理器进行处理。
- 指示处理器自身中断(执行自我中断)。
- 向其他处理器提供特殊IPIs，如启动IPI(SIPI)消息。 

使用此设施生成的中断通过系统总线(对于Pentium 4和Intel Xeon处理器)或APIC总线(对于P6家族和Pentium处理器)传递到系统中的其他处理器。处理器发送最低优先级IPI的能力是模型特定的，应由BIOS和操作系统软件避免。

## smp_init
```
void smp_init(void)
{
        int i;
        void ipi_entry(void);
 
        setup_idt(); // 设置idt表，desc.c 下 idt_handlers
        init_apic_map();
        set_idt_entry(IPI_VECTOR, ipi_entry, 0); // 增加ipi_entry 到idt

        setup_smp_id(0); // 设置smp id
        for (i = 1; i < cpu_count(); ++i)
                on_cpu(i, setup_smp_id, 0);

        atomic_inc(&active_cpus);
}
```

## flat.lds



```lds
SECTIONS
{
    . = 4M + SIZEOF_HEADERS; // 起始位置
    stext = .;  // stext 变量记录text段开始位置
    .text : { *(.init) *(.text) *(.text.*) }  // 链接init text 段到目标文件.text 
    etext = .;  // etext 记录text段结束位置
    . = ALIGN(4K);  // 对齐
    .data : {      // data 段
          *(.data)   // 链接所有的.data 
          exception_table_start = .; 
          *(.data.ex)
          exception_table_end = .;
          }
    . = ALIGN(16);  // 对齐 
    .rodata : { *(.rodata) }  // 链接rodata
    . = ALIGN(16);  // 对齐
    .bss : { *(.bss) }  // 链接 .bss
    . = ALIGN(4K);  // 4k 对齐
    edata = .;  //edata 记录 data段结束位置
}

ENTRY(start)  // 入口函数 start

```





## libcflat.a 静态库

```
libcflat := lib/libcflat.a
cflatobjs := \
        lib/argv.o \
        lib/printf.o \
        lib/string.o \
        lib/abort.o \
        lib/report.o \
        lib/stack.o

$(libcflat): $(cflatobjs)
        $(AR) rcs $@ $^

```



## 数据结构

#### mbi_bootinfo

```
struct mbi_bootinfo {
        u32 flags;
        u32 mem_lower;
        u32 mem_upper;
        u32 boot_device;
        u32 cmdline;
        u32 mods_count;
        u32 mods_addr;
        u32 reserved[4];   /* 28-43 */
        u32 mmap_length;
        u32 mmap_addr;
        u32 reserved0[3];  /* 52-63 */
        u32 bootloader;
        u32 reserved1[5];  /* 68-87 */
        u32 size;
};
```



### tss64_t

```
typedef struct  __attribute__((packed)) {
        u32 res1;
        u64 rsp0;
        u64 rsp1;
        u64 rsp2;
        u64 res2;
        u64 ist1;
        u64 ist2;
        u64 ist3;
        u64 ist4;
        u64 ist5;
        u64 ist6;
        u64 ist7;
        u64 res3;
        u16 res4;
        u16 iomap_base;
} tss64_t;

```

![img](imgs\general-regs.webp)
