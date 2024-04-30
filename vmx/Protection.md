# Protection

## CPL RPL DPL


**RPL 存在那里？**
RPL存储在段选择子的最后两位。

**CPL 存在那里？**

CS寄存器的最低两位
```
见vol3A 2.1.1中的描述 
The CPL is defined as the protection level of the currently executing code segment.
```

**权限变化的方式：


## 特权指令
特权指令要求CPL必为0，如果不是的话，产生#GP 异常，如下的系统指令都是特选指令:

* LGDT — Load GDT register.
* LLDT — Load LDT register.
* LTR — Load task register.
* LIDT — Load IDT register.
* MOV (control registers) — Load and store control registers.
* LMSW — Load machine status word.
* CLTS — Clear task-switched flag in register CR0.
* MOV (debug registers) — Load and store debug registers.
* INVD — Invalidate cache, without writeback.
* WBINVD — Invalidate cache, with writeback.
* INVLPG —Invalidate TLB entry.
* HLT— Halt processor.
* RDMSR — Read Model-Specific Registers.
* WRMSR —Write Model-Specific Registers.
* RDPMC — Read Performance-Monitorin