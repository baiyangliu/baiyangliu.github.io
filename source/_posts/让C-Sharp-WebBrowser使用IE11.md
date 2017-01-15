title: '让C# WebBrowser使用IE11'
author: baiyangliu
date: 2015-12-15 15:31:25
categories:
- 工具
tags: [c#]
---
<!--more-->
```
Windows Registry Editor Version 5.00

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Internet Explorer\MAIN\FeatureControl\FEATURE_BROWSER_EMULATION]
"xxx.exe"=dword:2af9

[HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Internet Explorer\MAIN\FeatureControl\FEATURE_BROWSER_EMULATION]
"xxx.exe"=dword:2af9
```
将上述文件中的xxx.exe替换成你的程序名字，保存为.reg文件，运行即可。详情求参考：https://msdn.microsoft.com/en-us/library/ee330730(v=vs.85).aspx#browser_emulation