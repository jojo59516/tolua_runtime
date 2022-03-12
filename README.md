# tolua_runtime
## New Features
- 引入了 [Low-level native plug-in Profiler API](https://docs.unity3d.com/2020.3/Documentation/Manual/LowLevelNativePluginProfiler.html) (see unity/unity_profiling.c)
- 封装了 Lua 模块 `UnityProfilerMarker.lua`
### Usage
```Lua
local UnityProfilerMarker = require("UnityProfilerMarker")
local marker = UnityProfilerMarker.Get("module.tick")
function Module.tick()
  marker:Begin()
  -- your heavy stuff
  marker:End()
end
```
### More details
- **在编译 dll 时开启 `ENABLE_PROFILER` 选项时才生效**，否则导入到 Lua 的 `BeginSample`、`End` 都是空函数；
- 在 Lua 侧可通过 `unity.profiling.IsAvailable` 查询 `ENABLE_PROFILER` 是否开启。若未开启，`marker:Begin()`、`marker:End()` 也将会是空函数；
- 主动开关整个 Lua 中的 profiling 功能：
```Lua
local UnityProfilerMarker = require("UnityProfilerMarker")
UnityProfilerMarker.SetEnabled(enabled)
```
- 主动开关单个 marker 的功能（可以自己对 marker 进行分组，然后利用该功能控制某一组或几组 marker 启用或禁用）：
```Lua
local UnityProfilerMarker = require("UnityProfilerMarker")
local marker = UnityProfilerMarker.Get("module.tick")
UnityProfilerMarker.SetMarkerEnabled(marker, enabled)
```

**Build**<br>
pc: build_win32.sh build_win64.h  (mingw + luajit2.0.4) <br>
android: build_arm.sh build_x86.sh (mingw + luajit2.0.4) <br>
mac: build_osx.sh (xcode + luac5.1.5 for luajit can't run on unity5) <br>
ios: build_ios.sh (xcode + luajit2.1 beta) <br>

NDK 版本:android-ndk-r10e 默认安装到 D:/android-ndk-r10e<br>
https://dl.google.com/android/repository/android-ndk-r10e-windows-x86_64.zip<br>
Msys2配置说明<br>
https://github.com/topameng/tolua_runtime/wiki<br>
配置好的Msys2下载<br>
https://pan.baidu.com/s/1c2JzvDQ<br>

# Libs
**cjson**<br>
https://github.com/mpx/lua-cjson<br>
**protoc-gen-lua**<br>
https://github.com/topameng/protoc-gen-lua<br>
**LuaSocket** <br>
https://github.com/diegonehab/luasocket<br>
**struct**<br>
http://www.inf.puc-rio.br/~roberto/struct/<br>
**lpeg**<br>
http://www.inf.puc-rio.br/~roberto/lpeg/lpeg.html
