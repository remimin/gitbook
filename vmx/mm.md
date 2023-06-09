# memory management overview

CPU工作模式：

1. 实模式
2. 保护模式
3. virtual 8086模式
4. 

IA-32架构内存管理机制分为两部分：段和页。分段为task提供的独立的代码段、数据段，使多个程序（或任务）在同一处理器上运行而不会相互干扰。分页提供了一种机制，用于实现常规的按需分页虚拟内存系统，程序运行过程重部分被映射到物理内存中。分页还可以用于在多个任务之间提供隔离。**在保护模式下运行时，必须使用某种形式的分段。没有模式位来禁用分段**。然而，使用**分页是可选的**。 这

分段提供了一种机制，将处理器的可寻址内存空间（称为线性地址空间）划分为较小的保护地址空间，称为段。段可以用于保存程序的代码、数据和栈，也可以用于保存系统数据结构（例如TSS或LDT）。如果在处理器上运行多个程序（或任务），则可以为每个程序分配其自己的段集。处理器然后执行这些段之间的边界，并确保一个程序不会通过写入另一个程序的段来干扰另一个程序的执行。分段机制还允许对段进行分类，从而可以限制可以在特定类型的段上执行的操作。 系统中的所有段都包含在处理器的线性地址空间中。为了定位一个特定段中的字节，必须提供一个**逻辑地址**（也称为far pointer）。逻辑地址由段**选择符和偏移量**组成。段选择符是段的唯一标识符。它提供了到一个数据结构（例如全局描述符表GDT）中的偏移量，该数据结构称为段描述符。每个段都有一个段描述符，它指定了段的大小、访问权限和特权级别、段的类型以及段在线性地址空间中的第一个字节的位置（称为段的基地址）。逻辑地址的偏移量部分加上段的基地址，便可定位段内的一个字节。因此，基地址加上偏移量形成了处理器的线性地址空间中的一个线性地址。

总结如下：

1) 保护模式下，段必须开启，分页可不开启
2) 分段不分页的情况下，逻辑地址 ==>  线性地址 == 物理地址
3) 分段分页的情况下, 逻辑地址==> 线性地址 ==>  物理地址

