# kprobe event

添加probe event

```
#!/bin/bash -x
echo "p:klustre lustre:ll_direct_rw_pages" >/sys/kernel/debug/tracing/kprobe_events
echo "r:kretlustre lustre:ll_direct_rw_pages" >>/sys/kernel/debug/tracing/kprobe_events
#echo "p:klustre lustre:ll_direct_IO_impl" >/sys/kernel/debug/tracing/kprobe_events
#echo "r:kretlustre lustre:ll_direct_IO_impl" >>/sys/kernel/debug/tracing/kprobe_events
#echo "p:kdio get_user_pages_fast" >>/sys/kernel/debug/tracing/kprobe_events
#echo "r:kretdio get_user_pages_fast" >>/sys/kernel/debug/tracing/kprobe_event
```
