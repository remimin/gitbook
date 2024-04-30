arch/x86/kvm/vmx/vmx.c：

struct vmcs_config vmcs_config;

struct vmx_capability vmx_capability;

```
kvm_init -> kvm_arch_hardware_setup
			->  ops->hardware_setup()
					-> vmx.c: hardware_setup
							-> setup_vmcs_config(&vmcs_config, &vmx_capability)
```

