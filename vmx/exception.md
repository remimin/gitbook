# Exception and interrupt reference

| 中断/异常                                        | 异常类型(fault/trap/int) | 描述    | ErrorCode | 保存的指令指针                 | Program State change |
| ------------------------------------------------ | ------------------------ | ------- | --------- | ------------------------------ | -------------------- |
| int0-Divide Error Exception (#DE)                | Fault                    | 除数为0 | None      | CS/EIP寄存器指向产生异常的指令 |                      |
| int 1 - Debug Exception (#DB)                    |                          |         |           |                                |                      |
| Interrupt 2—NMI Interrupt                        |                          |         |           |                                |                      |
| Interrupt 3—Breakpoint Exception (#BP)           |                          |         |           |                                |                      |
| Interrupt 4—Overflow Exception (#OF)             |                          |         |           |                                |                      |
| Interrupt 5—BOUND Range Exceeded Exception (#BR) |                          |         |           |                                |                      |
| Interrupt 6—Invalid Opcode Exception (#UD)       |                          |         |           |                                |                      |
| Interrupt 7—Device Not Available Exception (#NM) |                          |         |           |                                |                      |
| Interrupt 8—Double Fault Exception (#DF)         |                          |         |           |                                |                      |
| Interrupt 9—Coprocessor Segment Overrun          |                          |         |           |                                |                      |
| Interrupt 10—Invalid TSS Exception (#TS)         |                          |         |           |                                |                      |
|                                                  |                          |         |           |                                |                      |
|                                                  |                          |         |           |                                |                      |
|                                                  |                          |         |           |                                |                      |
| Interrupt 14—Page-Fault Exception (#PF)          | fault                    |         |           |                                |                      |
|                                                  |                          |         |           |                                |                      |
|                                                  |                          |         |           |                                |                      |
|                                                  |                          |         |           |                                |                      |
|                                                  |                          |         |           |                                |                      |
|                                                  |                          |         |           |                                |                      |

