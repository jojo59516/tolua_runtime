local setmetatable = setmetatable
local profiling = require("unity.profiling")

local IsUnityProfilerAvailable = profiling and profiling.IsAvailable or false

local ProfilerMarker = {}

local DummyProfilerMarkerPrototype = {}
DummyProfilerMarkerPrototype.__index = DummyProfilerMarkerPrototype
do
    function DummyProfilerMarkerPrototype.CreateMarker(name)
        return setmetatable({
            desc = nil,
            name = name,
        }, ProfilerMarker)
    end

    function DummyProfilerMarkerPrototype:Begin()
    end

    function DummyProfilerMarkerPrototype:End()
    end
end

local UnityProfilerMarkerPrototype = {}
UnityProfilerMarkerPrototype.__index = UnityProfilerMarkerPrototype
if profiling then
    local CreateMarker, BeginSample, EndSample = profiling.CreateMarker, profiling.BeginSample, profiling.EndSample
    profiling.CreateMarker, profiling.BeginSample, profiling.EndSample = nil, nil, nil -- make private

    function UnityProfilerMarkerPrototype.CreateMarker(name)
        return setmetatable({
            desc = CreateMarker(name),
            name = name,
        }, ProfilerMarker)
    end

    function UnityProfilerMarkerPrototype:Begin()
        BeginSample(self.desc)
    end

    function UnityProfilerMarkerPrototype:End()
        EndSample(self.desc)
    end
end

ProfilerMarker.__index = IsUnityProfilerAvailable
    and UnityProfilerMarkerPrototype
    or DummyProfilerMarkerPrototype

local markers = setmetatable({}, {__mode = "v"})
function ProfilerMarker.Get(name)
    local marker = markers[name]
    if not marker then
        marker = ProfilerMarker.__index.CreateMarker(name)
        markers[name] = marker
    end
    return marker
end

function ProfilerMarker.IsEnabled()
    return IsUnityProfilerAvailable and (ProfilerMarker.__index == UnityProfilerMarkerPrototype)
end

function ProfilerMarker.SetEnabled(enabled)
    ProfilerMarker.__index = (IsUnityProfilerAvailable and enabled)
        and UnityProfilerMarkerPrototype
        or DummyProfilerMarkerPrototype
end

function ProfilerMarker.SetMarkerEnabled(marker, enabled)
    setmetatable(marker, (IsUnityProfilerAvailable and enabled)
        and UnityProfilerMarkerPrototype
        or DummyProfilerMarkerPrototype)
end

return ProfilerMarker