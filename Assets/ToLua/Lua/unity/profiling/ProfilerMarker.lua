local setmetatable = setmetatable
local profiling = require("unity.profiling")

local IsUnityProfilerAvailable = profiling and profiling.IsAvailable or false

local ProfilerMarker = {}

local DummyProfilerMarkerPrototype = {}
DummyProfilerMarkerPrototype.__index = DummyProfilerMarkerPrototype
do
    function DummyProfilerMarkerPrototype:Begin()
    end

    function DummyProfilerMarkerPrototype:End()
    end
end

local UnityProfilerMarkerPrototype = DummyProfilerMarkerPrototype
if IsUnityProfilerAvailable then
    local BeginSample, EndSample = profiling.BeginSample, profiling.EndSample
    profiling.BeginSample, profiling.EndSample = nil, nil -- make private

    UnityProfilerMarkerPrototype = {}
    function UnityProfilerMarkerPrototype:Begin()
        BeginSample(self.desc)
    end

    function UnityProfilerMarkerPrototype:End()
        EndSample(self.desc)
    end
end

ProfilerMarker.__index = UnityProfilerMarkerPrototype

local function CreateProfilerMarker(name)
    return setmetatable({
        -- desc = nil,
        name = name,
    }, ProfilerMarker)
end
if IsUnityProfilerAvailable then
    local CreateMarker = profiling.CreateMarker
    profiling.CreateMarker = nil

    function CreateProfilerMarker(name)
        return setmetatable({
            desc = CreateMarker(name),
            name = name,
        }, ProfilerMarker)
    end
end

local markers = setmetatable({}, {__mode = "v"})
function ProfilerMarker.Get(name)
    local marker = markers[name]
    if not marker then
        marker = CreateProfilerMarker(name)
        markers[name] = marker
    end
    return marker
end

function ProfilerMarker.IsEnabled()
    return IsUnityProfilerAvailable
        and ProfilerMarker.__index == UnityProfilerMarkerPrototype
end

function ProfilerMarker.SetEnabled(enabled)
    ProfilerMarker.__index = enabled
        and UnityProfilerMarkerPrototype
        or DummyProfilerMarkerPrototype
end

function ProfilerMarker.SetMarkerEnabled(marker, enabled)
    setmetatable(marker, enabled
        and UnityProfilerMarkerPrototype
        or DummyProfilerMarkerPrototype)
end

return ProfilerMarker