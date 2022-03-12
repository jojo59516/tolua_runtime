local setmetatable = setmetatable
local profiling = require("unity").profiling

local IsUnityProfilerAvailable = profiling and profiling.IsUnityProfilerAvailable() or false

local UnityProfilerMarker = {}

local DummyProfilerMarkerPrototype = {}
DummyProfilerMarkerPrototype.__index = DummyProfilerMarkerPrototype
do
    function DummyProfilerMarkerPrototype.CreateMarker(name)
        return setmetatable({
            desc = nil,
            name = name,
        }, UnityProfilerMarker)
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
        }, UnityProfilerMarker)
    end

    function UnityProfilerMarkerPrototype:Begin()
        BeginSample(self.desc)
    end

    function UnityProfilerMarkerPrototype:End()
        EndSample(self.desc)
    end
end

UnityProfilerMarker.__index = IsUnityProfilerAvailable
    and UnityProfilerMarkerPrototype
    or DummyProfilerMarkerPrototype

local markers = setmetatable({}, {__mode = "v"})
function UnityProfilerMarker.Get(name)
    local marker = markers[name]
    if not marker then
        marker = UnityProfilerMarker.__index.CreateMarker(name)
        markers[name] = marker
    end
    return marker
end

function UnityProfilerMarker.SetEnabled(enabled)
    UnityProfilerMarker.__index = (IsUnityProfilerAvailable and enabled)
        and UnityProfilerMarkerPrototype
        or DummyProfilerMarkerPrototype
end

function UnityProfilerMarker.SetMarkerEnabled(marker, enabled)
    setmetatable(marker, (IsUnityProfilerAvailable and enabled)
        and UnityProfilerMarkerPrototype
        or DummyProfilerMarkerPrototype)
end

return UnityProfilerMarker