# virtual machine extensions

current priviledge level (CPL)



![image-20230410181736431](imgs\vmm-and-guest.png)

CR4.VMXE[bit 13] = 1 

VMXON  

if CR4.VMXE = 0  cause invalid-opcode exception (#UD)

VMXON 执行成功后，CR4.VMXE 不能被清除。

VMXOFF 后，CR4.VMXE 可以被清除。



 IA32_FEATURE_CONTROL MSR (MSR address 3AH) 控制着VMXON，当逻辑处理器被重置reset时这个MSR会被清0。这个MSR相关的bit如下：

Bit 0 is the lock bit。这个bit位被清除，执行VMXON，触发#GP(general-protection exception)，改位被设置时，对这个MSR执行WSMSR则触发#GP，直到power-up reset ，MSR才能够被修改。**BIOS通过设置这个MSR来控制关闭和开启VMX**。BIOS还必须设置bit1和bit2.

Bit 1 enables VMXON in SMX operation

Bit 2 enables VMXON outside SMX operation

