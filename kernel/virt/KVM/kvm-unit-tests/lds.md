# lds 语法

[toc]

# 基本概念

## SECTION

一个可执行文件有多个段，如.text段、bss段、data段等。这里SECTION即对应可执行程序的段。一个段由以下几个部分组成：

- 段名称

- 段内容
- 段长度信息

段可以定义为Loadable和allocatable两种加载方式:

- loadable: 执行时该section是否需要被加载到内存

- allocatable: 先保留内存的一块空间让程序执行时使用，如.bss段

## Symbol
一个object 档案存放多个symbol，又称为symbol table（符号表）。Symbol通常就是全局变量、静态变量或是函数的名称。我们可以使用`objdump -t `可执行文件 或者` readelf -a `可执行文件_或者`nm `可执行文件_来查看对应可执行文件的符号表。

## LMA V.S. VMA

- LMA: Load Memory Address, 表示程序被装载到内存哪个位置

- VMA: Virutal Memroy Address，表示程序执行的位置，即CPU执行对应程序指令的位置。

通常，LMA = VMA。但是在一些嵌入式体系中， LMA和VMA不一样。而其中最常见的一种情况就是，程序被放到ROM中。而程序要运行时候的地址是内存虚拟地址，也就是VMA。之后小节会有例子做介绍。

# Link Script语法

Link Script可以基本总结如下：

- 以文本形式存放

- 由多个command組成
- 每个command可能是
  - keyword + 参数
  - 设定symbol
- command 可以用;分開，空白會被忽略
- 使用/_* * _/注释
- 字串直接打，如果有用到script保留的字元如.可以用"包住

## 简单链接脚本范例

```lds
SECTIONS
{
  . = 0x10000; // 设定内存位置为0x10000
  .text : { *(.text) } // 把所有输入object 文件中({ (.text) })存放到*输出**object 文件的.text区块中
  . = 0x8000000;  // 设定内存位置为0x8000000
  .data : { *(.data) } // 先放已初始化全局变量（.data），所有输入目标文件中的.data字段都会被打包到此位置
  .bss : { *(.bss) }  // 紧接着再放未初始值的全局变量（.bss）
}
/*
.表示内存位置，起始值为0。
结束值则由链接器计算把所有input section的数据整合到output section的长度。
.如果没有指定明确的内存地址的话，就会被设定为上一个地址的结束地址。

*/
```



## 简单链接脚本命令

ENTRY(symbol) ：设置程序入口点

文件相关命令

_INCLUDE filename
_在看到这个命令的时候才去载入filename这个linker script。可以被放在不同的命令如SETCTION, MEMORY等。
_INPUT(file1 file2 …)
**_指定加载的输入object档案，如abc.o这样的档案。
_GROUP(file1 file2 …)
_指定加载的输入archieve档案，如libabc.a这样的档案。
_AS_NEEDED(file1 file2 …)
_在INPUT和GROUP使用的命令，用来告诉linker说如果object里面的数据有被reference到才link进来，猜测应该可以减少储存空间。范例（未测试请自行斟酌）：INPUT(file1.o file2.o AS_NEEDED(file3.o file4.o))
_OUTPUT(filename)
_和gcc -o filename 一样
**_SEARCH_DIR(path)
_和-L path一样
_*STARTUP(filename)
*_和INPUT相同，唯一差别是ld保证这个档案一定是第一个被link

输出文件格式相关命令

_OUTPUT_FORMAT(bfdname)
**_指定输出object档案的binary 文件格式，可以使用objdump -i列出支持的binary 文件格式
_OUTPUT_FORMAT(default, big, little)
_指定输出object档案预设的binary 文件格式，big endian的binary 文件格式以及little endian的binary 文件格式。可以使用objdump -i列出支持的binary 文件格式
_TARGET(bfdname)
**_告诉ld用那种binary 文件格式读取输入object档案要，可以使用objdump -i列出支持的binary 文件格式

设定内存块别名的命令

REGION_ALIAS(alias, region) 对内存区域设定别名，这样输出段可以灵活地映射。具体可以参考<LD:REGION_ALIAS>

其他链接器相关命令

ASSERT(exp, message) 条件不成立打印message并结束链接过程
EXTERN(symbol1 symbol2 …) 强迫让指定的symbol设成undefined，手册说一般用在刻意要使用非标准的API。
FORCE_COMMON_ALLOCATION 手册和男人说和兼容性有关，手册上是说强迫分配空间给common symbols，即使是link relocate档案。(common symbols不知道是什么)
OUTPUT_ARCH(bfdarch) 指定输出的平台，可以透过objdump -i查询支持平台
INSERT [ AFTER | BEFORE ] output_section 指定在预设linker script命令被执行之前或是之后加上或加入特定的输入section到输出section

符号赋值
简单赋值命令范例
可以在脚本中使用类C语言语法对符号进行赋值，例：

```
 symbol = expression ;
 symbol += expression ;
 symbol -= expression ;
 symbol *= expression ;
 symbol /= expression ;
 symbol <<= expression ; symbol >>= expression ;
 symbol &= expression ;
 symbol |= expression ;
```

一段简单的范例：

```
floating_point = 0;
SECTIONS
{
  .text :
    {
      *(.text)
      _etext = .;
    }
  _bdata = (. + 3) & ~ 3;
  .data : { *(.data) }
}
```


第一行：设定floating_point变量的链接地址为0

第七行：设置_etext的地址为.text之后

第九行：设置_bdata地址为_etext之后4字节alignment的位置。实则是对.data段的起始位置进行字节对齐

HIDDEN
对输出ELF，把其中某个符号定义为目标文件内可见。对上文范例的symbol改写后：

HIDDEN(floating_point = 0);
SECTIONS
{
  .text :
    {
      *(.text)
      HIDDEN(_etext = .);
    }
  HIDDEN(_bdata = (. + 3) & ~ 3);
  .data : { *(.data) }
}
1.
2.
3.
4.
5.
6.
7.
8.
9.
10.
11.
floating_point/_etext/_bdata 为ELF内可见，但是无法导出。即假设目标文件是库文件，其他文件也无法引用使用。

PROVIDE

链接器直接定义一个symbol，如果它没有在任何输入目标文件中定义，则链接时使用PROVIDE定义的符号。如果目标文件中有定义，则使用目标文件中的定义。例如：

SECTIONS
{
  .text :
    {
      *(.text)
      _etext = .;
      PROVIDE(etext = .);
    }
}
1.
2.
3.
4.
5.
6.
7.
8.
9.
__etext_不能在程序中定义，否则链接时有重复定义
_etext_则可定义在程序中定义，这样链接器会使用程序中的定义。
PROVIDE_HIDDEN

类似PROVIDE，差异只在于符号是HIDDEN

源代码引用

C语言内可以引用链接器脚本中定义的变量。例如：

start_of_ROM   = .ROM;
end_of_ROM     = .ROM + sizeof (.ROM);
start_of_FLASH = .FLASH;
1.
2.
3.
则C语言中可以如下引用：

extern char start_of_ROM, end_of_ROM, start_of_FLASH;
memcpy (& start_of_FLASH, & start_of_ROM, & end_of_ROM - & start_of_ROM);
1.
2.
SECTION
SECTION命令告诉链接器如何映射输入的段到输出段，且摆到内存的哪个位置。基本语法如下：

SECTIONS
{
  sections-command
  sections-command
  …
}
1.
2.
3.
4.
5.
6.
SECTION命令可能是以下命令的一种

ENTRY命令
符号赋值
输出段描述
覆盖描述

参考链接：

https://blog.51cto.com/u_15169172/2710689
