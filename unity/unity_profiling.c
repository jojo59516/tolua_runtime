#define LUA_LIB
#include "lua.h"
#include "lauxlib.h"

#include "IUnityProfiler.h"

static IUnityProfiler* s_UnityProfiler = NULL;
static int s_IsDevelopmentBuild = 0;

#ifdef __cplusplus
extern "C" {
#endif

void UNITY_INTERFACE_API UnityPluginLoad(IUnityInterfaces* unityInterfaces) {
    s_UnityProfiler = (IUnityProfiler*)unityInterfaces->GetInterface(IUnityProfiler_GUID);
    if (s_UnityProfiler == NULL) {
        return;
    }

    s_IsDevelopmentBuild = s_UnityProfiler->IsAvailable() != 0;
}

void UNITY_INTERFACE_API UnityPluginUnload() {}

#ifdef __cplusplus
}
#endif

static int IsUnityProfilerAvailable() {
#ifdef ENABLE_PROFILER
    return s_IsDevelopmentBuild;
#else
    return 0;
#endif
}

static int IsUnityProfilerEnabled() {
#ifdef ENABLE_PROFILER
    return s_IsDevelopmentBuild && s_UnityProfiler->IsEnabled();
#else
    return 0;
#endif
}

static const UnityProfilerMarkerDesc* CreateMarker(const char* name) {
#ifdef ENABLE_PROFILER
    if (s_IsDevelopmentBuild) {
        const UnityProfilerMarkerDesc* desc = NULL;
        s_UnityProfiler->CreateMarker(&desc, name, kUnityProfilerCategoryOther, kUnityProfilerMarkerFlagDefault, 0);
        return desc;
    }
#endif
    return NULL;
}

static void BeginSample(const UnityProfilerMarkerDesc* desc) {
#ifdef ENABLE_PROFILER
    if (s_IsDevelopmentBuild) {
        (s_UnityProfiler->EmitEvent)(desc, kUnityProfilerMarkerEventTypeBegin, 0, NULL);
    }
#endif
}

static void EndSample(const UnityProfilerMarkerDesc* desc) {
#ifdef ENABLE_PROFILER
    if (s_IsDevelopmentBuild) {
        (s_UnityProfiler->EmitEvent)(desc, kUnityProfilerMarkerEventTypeEnd, 0, NULL);
    }
#endif
}

static int unity_IsEnabled(lua_State* L) {
    lua_pushboolean(L, IsUnityProfilerEnabled());
    return 1;
}

static int unity_CreateMarker(lua_State* L) {
    const char* name = luaL_checkstring(L, 1);
    const UnityProfilerMarkerDesc* desc = CreateMarker(name);
    if (desc == NULL) {
        lua_pushnil(L);
        lua_pushliteral(L, "create marker failed");
        return 2;
    }
    lua_pushlightuserdata(L, (void*)desc);
    return 1;
}

static int unity_BeginSample(lua_State* L) {
    luaL_checktype(L, 1, LUA_TLIGHTUSERDATA);
    const UnityProfilerMarkerDesc* desc = (const UnityProfilerMarkerDesc*)lua_touserdata(L, 1);
    luaL_argcheck(L, desc, 1, "marker desc is NULL");
    BeginSample(desc);
    return 0;
}

static int unity_EndSample(lua_State* L) {
    luaL_checktype(L, 1, LUA_TLIGHTUSERDATA);
    const UnityProfilerMarkerDesc* desc = (const UnityProfilerMarkerDesc*)lua_touserdata(L, 1);
    luaL_argcheck(L, desc, 1, "marker desc is NULL");
    EndSample(desc);
    return 0;
}

static const luaL_Reg unity_profiling_funcs[] = {
    {"IsEnabled", unity_IsEnabled},
    {"CreateMarker", unity_CreateMarker},
    {"BeginSample", unity_BeginSample},
    {"EndSample", unity_EndSample},
    {NULL, NULL}
};

LUALIB_API int luaopen_unity(lua_State* L) {
    luaL_register(L, "unity.profiling", unity_profiling_funcs); // create and open lib unity.profiling
    lua_pushliteral(L, "IsAvailable");
    lua_pushboolean(L, IsUnityProfilerAvailable());
    lua_settable(L, -3); // unity.profiling.IsAvailable = IsUnityProfilerAvailable()
    return 1;
}
