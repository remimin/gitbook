# 问题记录

`__attribute__((packed))`

告诉编译器取消结构在编译过程中的优化对齐,按照实际占用字节数进行对齐，是GCC特有的语法



## MSR

MSR 详细列表在Intel SDM v4 CH2 “Model-Specific Registers (MSRs)”

VMX non-Root 模式下MSR指令行为，见Intel SDM v3c CH26 “Changes to Instruction Behavior in VMX Non-Root Operation” 

CPUID 指令可以判断是否支持MSR，CPUID.01H:EDX[5] = 1) 



## MOV 指令和 LEA 指令

Q： `mov -4096(%esp), %eax` 

这个汇编指令的意思是：将栈指针(ESP)减去一个立即数(-4096)，然后将计算结果存储在累加寄存器(EAX)中。在x86汇编语言中，LEA（Load Effective Address）指令可以计算出内存地址或者偏移量的值。它的操作数必须是有效的内存地址或者内存地址的偏移量。在这个例子中，LEA将执行下列操作： 
```
ESP = ESP - 4096
EAX = ESP 
```
通过执行这些指令，可以将ESP作为原初值，减去一个偏移量(-4096)得到一个新的地址，然后将这个新地址存储到寄存器EAX中。可以把这个指令看作是计算使用栈上的一块内存的地址。 举个例子，假设堆栈指针ESP的值为x001_000，执行LEA -4096(%esp), %eax指令后，计算结果如下：
``` 
ESP = x001_000 - 4096 = x000F_FFC   
EAX = x000F_FFC   
```
因此，执行该指令后，EAX寄存器的值将是x000F_FFC，它保存了计算出的新地址值。

Q:  汇编指令`lea -4096(%esp), %eax` 是什么意思？并举例说明

这个汇编指令的意思是：将栈指针(ESP)减去一个立即数(-4096)，然后将计算结果存储在累加寄存器(EAX)中。在x86汇编语言中，LEA（Load Effective Address）指令可以计算出内存地址或者偏移量的值。它的操作数必须是有效的内存地址或者内存地址的偏移量。在这个例子中，LEA将执行下列操作：
``` 
ESP = ESP - 4096       
EAX = ESP   
```
通过执行这些指令，可以将ESP作为原初值，减去一个偏移量(-4096)得到一个新的地址，然后将这个新地址存储到寄存器EAX中。可以把这个指令看作是计算使用栈上的一块内存的地址。 举个例子，假设堆栈指针ESP的值为x001_000，执行LEA -4096(%esp), %eax指令后，计算结果如下：
``` 
ESP = x001_000 - 4096 = x000F_FFC   
EAX = x000F_FFC   
```
因此，执行该指令后，EAX寄存器的值将是x000F_FFC，它保存了计算出的新地址值。

## BIOS_CFG_IOPORT

只有虚拟机有这个port

```
 0510-051b : QEMU0002:00
    0510-051b : fw_cfg_io
```

