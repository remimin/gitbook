# system architecture overview

[toc]
## 2.1 GDT/LDT (Global and Local Descriptor Tables)



保护模式下，所有的内存访问都是通过GDT/LDT，GDT/LDT表中是段描述符，段描述提供了段的基地址，访问权限，类型和使用信息。

访问段中的字节，需要一个段选择符(segment selector)，段选择符是GDT/IDT表的index，从表中读取线性低级空间的段基地址。

GDTR: 保存了GDT的线性地址基地址；LDTR：保存了LDT的线性基地址。IA-32 和IA-32e的区别就是IA-32eGDTR/LDTR扩展到了64bit，且兼容IA-32



## 2.2 System Segments, Segment Descriptors and Gates

除了代码段、数据段和堆栈段之外，架构还定义了两种系统段：TSS和LDT。GDT不人为是系统段，因为GDT的访问不是通过段选择符和段描述符的方式进行的。


### 2.2.1 TSS 和Task Gates

TSS定义的是一个任务执行环境的状态，包括通用寄存器、段寄存器、EFLAGS寄存器、EIP寄存器、和segment selectors with stack pointers for three stack segments (one stack for each privilege level)，以及与task关联的LDT的段选择符(segment selector)，和（页表基地址？？）the base address of the paging-structure hierarchy.

当前task的TSS的segment selector 存储在task register（任务寄存器中），切换task的指令是CALL/JMP，CALL/JMP指令中的给出新的task的TSS的segment selector，执行如下操作：
1. 存储当前的task的状态到current TSS
2. 将new task的TSS segment selector加载到task registor中
3.  访问GDT中new task TSS的segment descriptor
4.  从new TSS从获取通用寄存器、段寄存器、LDTR、控制寄存器CR3（页表基址寄存器），EFLAGS register 和EIP registor
5.  开始执行新的task

task也可以通过task gate的方式进行访问，task gate和call gate类似，不同之处是，task gate是通过段选择符访问TSS，而call gate是访问的code segment。

注意：IA-32e模式下硬件的task切换是不支持的，但是TSS还是存在的。64-bit TSS还保存了以下信息：

* 每个优先级层的栈指针地址
* interrup stack table的指针地址
* Offset address of the IO-permission bitmap (from the TSS base)

一种特殊的描述符被成为gate（call gates, interrupt gates, trap gates, and task gates）.

## 2.3 中断和异常的处理




![IA-32 寄存器和数据结构](F:\rminmin\notes\gitbook\vmx\imgs\img-1-IA32-regs-ds)

![IA32e 系统寄存器和数据结构及4层页表](F:\rminmin\notes\gitbook\vmx\imgs\img-2-IA32e-4-Level-paging)
