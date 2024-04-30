# bpftrace

```
bpftrace --info
```

**bpftrace支持的类型**

```
Probe types
  kprobe: yes
  tracepoint: yes
  perf_event: yes
  kfunc: yes
  iter:task: yes
  iter:task_file: yes
```
**查看支持的列表**

**查看唤醒进程pid**
```
 bpftrace -e 'kfunc:wake_up_process { printf("%s:%d\n",curtask->comm,curtask->pid); }'  |grep -v bpftrace | tee log
```


# bpftool

 ```
 bpftool btf dump file /sys/kernel/btf/vmlinux format c
 ```