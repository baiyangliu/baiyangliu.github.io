title: Win10关闭ULPS
date: 2017-4-7 21:32:36
updated:
tags:
categories:
- 工具
permalink:
---

```
Windows Registry Editor Version 5.00
[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Control\Class\{4D36E968-E325-11CE-BFC1-08002BE10318}\0000]
"EnableULPS"=dword:00000000
[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Control\Class\{4D36E968-E325-11CE-BFC1-08002BE10318}\0001]
"EnableULPS"=dword:00000000
```