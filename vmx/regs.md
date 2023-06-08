# CPU Registers x86-64

## 通用寄存器

| Monikers |        |        |                              |       | Description                             |
| :------: | :----: | :----: | :--------------------------: | :---: | --------------------------------------- |
|  64-bit  | 32-bit | 16-bit | 8 high bits of lower 16 bits | 8-bit |                                         |
|   RAX    |  EAX   |   AX   |              AH              |  AL   | Accumulator                             |
|   RBX    |  EBX   |   BX   |              BH              |  BL   | Base                                    |
|   RCX    |  ECX   |   CX   |              CH              |  CL   | Counter                                 |
|   RDX    |  EDX   |   DX   |              DH              |  DL   | Data (commonly extends the A register)  |
|   RSI    |  ESI   |   SI   |             N/A              |  SIL  | Source index for string operations      |
|   RDI    |  EDI   |   DI   |             N/A              |  DIL  | Destination index for string operations |
|   RSP    |  ESP   |   SP   |             N/A              |  SPL  | Stack Pointer                           |
|   RBP    |  EBP   |   BP   |             N/A              |  BPL  | Base Pointer (meant for stack frames)   |
|    R8    |  R8D   |  R8W   |             N/A              |  R8B  | General purpose                         |
|    R9    |  R9D   |  R9W   |             N/A              |  R9B  | General purpose                         |
|   R10    |  R10D  |  R10W  |             N/A              | R10B  | General purpose                         |
|   R11    |  R11D  |  R11W  |             N/A              | R11B  | General purpose                         |
|   R12    |  R12D  |  R12W  |             N/A              | R12B  | General purpose                         |
|   R13    |  R13D  |  R13W  |             N/A              | R13B  | General purpose                         |
|   R14    |  R14D  |  R14W  |             N/A              | R14B  | General purpose                         |
|   R15    |  R15D  |  R15W  |             N/A              | R15B  | General purpose                         |

## Pointer Registers

| Monikers |        |        |                     |
| :------: | :----: | :----: | ------------------- |
|  64-bit  | 32-bit | 16-bit |                     |
|   RIP    |  EIP   |   IP   | Instruction Pointer |

## Segment Registers

All these are 16 bits long.

| Moniker |                Description                 |
| :-----: | :----------------------------------------: |
|   CS    |                Code Segment                |
|   DS    |                Data Segment                |
|   SS    |               Stack Segment                |
|   ES    | Extra Segment (used for string operations) |
|   FS    |          General-purpose Segment           |
|   GS    |          General-purpose Segment           |

DS SS ES CS寄存器读取时，基地址永远是0，无论对应的GDT中的段描述符是什么。 

FS/GS 可以使用MSR去更改他们的基地址

####  x86-64处理器模式下的段寄存器

Intel理解到了现代操作系统设计者的想法，于是在x86-64处理器模式中，在微架构层将分段单元中的绝大多数功能都绕开了（注意不是关闭了分段单元）。具体来说，在加载cs、ds、es和ss寄存器时，对应的段描述符中的基地址，限长和部分属性字段一概被忽略，并假设基地址总为0，限长总为2^64-1。同样在使用ds、es和ss段前缀的时候，也都做出同样的假设；同时，这些段寄存器中隐藏部分中与上述对应的字段也被忽略。**因此x86-64处理器模式只支持平坦内存模型，即从0开始到2^48-1结束的规范化的虚拟地址空间，这是x86-64处理器模式中所做的硬性规定，因为这些规定可以进一步加快逻辑地址到虚拟地址的转换效率**。

## Control Registers （控制寄存器）

#### CR0

| Bit(s) | Label |      Description      |
| :----: | :---: | :-------------------: |
|   0    |  PE   | Protected Mode Enable |
|   1    |  MP   | Monitor Co-Processor  |
|   2    |  EM   |       Emulation       |
|   3    |  TS   |     Task Switched     |
|   4    |  ET   |    Extension Type     |
|   5    |  NE   |     Numeric Error     |
|  6-15  |   0   |       Reserved        |
|   16   |  WP   |     Write Protect     |
|   17   |   0   |       Reserved        |
|   18   |  AM   |    Alignment Mask     |
| 19-28  |   0   |       Reserved        |
|   29   |  NW   |   Not-Write Through   |
|   30   |  CD   |     Cache Disable     |
|   31   |  PG   |        Paging         |
| 32-63  |   0   |       Reserved        |

#### CR2

This control register contains the linear (virtual) address which triggered a page fault, available in the page fault's interrupt handler.

#### CR3

|       |              Bit(s)               | Label |       Description        | Condition     |
| :---: | :-------------------------------: | :---: | :----------------------: | ------------- |
| 0-11  |                0-2                |   0   |         Reserved         | CR4.PCIDE = 0 |
|       |                 3                 |  PWT  | Page-Level Write Through |               |
|       |                 5                 |  PCD  | Page-Level Cache Disable |               |
|       |               5-11                |   0   |         Reserved         |               |
|       |               0-11                | PCID  |                          | CR4.PCIDE = 1 |
| 12-63 | Physical Base Address of the PML4 |       |                          |               |

#### CR4

| Bit(s) |   Label    |                         Description                          |
| :----: | :--------: | :----------------------------------------------------------: |
|   0    |    VME     |                 Virtual-8086 Mode Extensions                 |
|   1    |    PVI     |              Protected Mode Virtual Interrupts               |
|   2    |    TSD     |              Time Stamp enabled only in ring 0               |
|   3    |     DE     |                     Debugging Extensions                     |
|   4    |    PSE     |                     Page Size Extension                      |
|   5    |    PAE     |                  Physical Address Extension                  |
|   6    |    MCE     |                   Machine Check Exception                    |
|   7    |    PGE     |                      Page Global Enable                      |
|   8    |    PCE     |            Performance Monitoring Counter Enable             |
|   9    |   OSFXSR   |        OS support for fxsave and fxrstor instructions        |
|   10   | OSXMMEXCPT |    OS Support for unmasked simd floating point exceptions    |
|   11   |    UMIP    | User-Mode Instruction Prevention (SGDT, SIDT, SLDT, SMSW, and STR are disabled in user mode) |
|   12   |     0      |                           Reserved                           |
|   13   |    VMXE    |              Virtual Machine Extensions Enable               |
|   14   |    SMXE    |                 Safer Mode Extensions Enable                 |
|   15   |     0      |                           Reserved                           |
|   16   |  FSGSBASE  | Enables the instructions RDFSBASE, RDGSBASE, WRFSBASE, and WRGSBASE |
|   17   |   PCIDE    |                         PCID Enable                          |
|   18   |  OSXSAVE   |          XSAVE And Processor Extended States Enable          |
|   19   |     0      |                           Reserved                           |
|   20   |    SMEP    |         Supervisor Mode Executions Protection Enable         |
|   21   |    SMAP    |           Supervisor Mode Access Protection Enable           |
|   22   |    PKE     |          Enable protection keys for user-mode pages          |
|   23   |    CET     |          Enable Control-flow Enforcement Technology          |
|   24   |    PKS     |       Enable protection keys for supervisor-mode pages       |
| 25-63  |     0      |                           Reserved                           |

#### CR4

| Bit(s) |   Label    |                         Description                          |
| :----: | :--------: | :----------------------------------------------------------: |
|   0    |    VME     |                 Virtual-8086 Mode Extensions                 |
|   1    |    PVI     |              Protected Mode Virtual Interrupts               |
|   2    |    TSD     |              Time Stamp enabled only in ring 0               |
|   3    |     DE     |                     Debugging Extensions                     |
|   4    |    PSE     |                     Page Size Extension                      |
|   5    |    PAE     |                  Physical Address Extension                  |
|   6    |    MCE     |                   Machine Check Exception                    |
|   7    |    PGE     |                      Page Global Enable                      |
|   8    |    PCE     |            Performance Monitoring Counter Enable             |
|   9    |   OSFXSR   |        OS support for fxsave and fxrstor instructions        |
|   10   | OSXMMEXCPT |    OS Support for unmasked simd floating point exceptions    |
|   11   |    UMIP    | User-Mode Instruction Prevention (SGDT, SIDT, SLDT, SMSW, and STR are disabled in user mode) |
|   12   |     0      |                           Reserved                           |
|   13   |    VMXE    |              Virtual Machine Extensions Enable               |
|   14   |    SMXE    |                 Safer Mode Extensions Enable                 |
|   15   |     0      |                           Reserved                           |
|   16   |  FSGSBASE  | Enables the instructions RDFSBASE, RDGSBASE, WRFSBASE, and WRGSBASE |
|   17   |   PCIDE    |                         PCID Enable                          |
|   18   |  OSXSAVE   |          XSAVE And Processor Extended States Enable          |
|   19   |     0      |                           Reserved                           |
|   20   |    SMEP    |         Supervisor Mode Executions Protection Enable         |
|   21   |    SMAP    |           Supervisor Mode Access Protection Enable           |
|   22   |    PKE     |          Enable protection keys for user-mode pages          |
|   23   |    CET     |          Enable Control-flow Enforcement Technology          |
|   24   |    PKS     |       Enable protection keys for supervisor-mode pages       |
| 25-63  |     0      |                           Reserved                           |

#### CR8

CR8 is a new register accessible in 64-bit mode using the REX prefix. CR8 is used to prioritize external [interrupts](https://wiki.osdev.org/Interrupts) and is referred to as the task-priority register (TPR).

The AMD64 architecture allows software to define up to 15 external interrupt-priority classes. Priority classes are numbered from 1 to 15, with priority-class 1 being the lowest and priority-class 15 the highest. CR8 uses the four low-order bits for specifying a task priority and the remaining 60 bits are reserved and must be written with zeros.

System software can use the TPR register to temporarily block low-priority interrupts from interrupting a high-priority task. This is accomplished by loading TPR with a value corresponding to the highest-priority interrupt that is to be blocked. For example, loading TPR with a value of 9 (1001b) blocks all interrupts with a priority class of 9 or less, while allowing all interrupts with a priority class of 10 or more to be recognized. Loading TPR with 0 enables all external interrupts. Loading TPR with 15 (1111b) disables all external interrupts.

The TPR is cleared to 0 on reset.

| Bit  | Purpose  |
| :--: | :------: |
| 0-3  | Priority |
| 4-63 | Reserved |

#### CR1, CR5-7, CR9-15

Reserved, the cpu will throw a #ud exeption when trying to access them.

## Protected Mode Registers

#### GDTR

| Operand Size |   Label    |                                           |                         |
| :----------: | :--------: | :---------------------------------------: | ----------------------- |
|    64-bit    |   32-bit   |                                           |                         |
|  Bits 0-15   |   Limit    | Size of [GDT](https://wiki.osdev.org/GDT) |                         |
|  Bits 16-79  | Bits 16-47 |                   Base                    | Starting Address of GDT |

#### LDTR

Stores the segment selector of the [LDT](https://wiki.osdev.org/LDT).

#### TR

Stores the segment selector of the [TSS](https://wiki.osdev.org/TSS).

#### IDTR

| Operand Size |            | Label | Description                               |
| :----------: | :--------: | :---: | ----------------------------------------- |
|    64-bit    |   32-bit   |       |                                           |
|  Bits 0-15   | Bits 0-15  | Limit | Size of [IDT](https://wiki.osdev.org/IDT) |
|  Bits 16-79  | Bits 16-47 | Base  | Starting Address of IDT                   |

## MSRs

## Debug Registers