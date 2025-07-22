# Splines

## Description

Spline service creates and handles splines.
These splines can be connected using paths.

If you aren't familiar with splines, how they work, or how to use them
it's highly recommended you watch Freya Holmér's video, "The Continuity of Splines",
before attempting to use this service: https://youtu.be/jvPPXbo87ds

## How To Use

Create the spline you want to use by doing SplineService:createSplineName()
Then to get a point along the spline do spline:sample(t) where t is a value between 0 and 1.
t values aren't equally distant around corners of a spline, if you wish to get equal distance
then use spline:distToT().

```
local bezierSpline = SplineService:createBezier({
  Vector3.new(0, 0, 10),
  Vector3.new(3.3, 3.3, 12.5),
  Vector3.new(6.6, 6.6, 7.5),
  Vector3.new(10, 10, 10)
})

bezierSpline:sample(0.5)

local distanceT = bezierSpline:distToT(2)
bezierSpline:sample(distanceT)
```

To help with understanding and debugging, use `SplineService:viewSpline()` or other relative
visual functions.

If you want to connect multiple splines, use `SplineService:createPath(splines)`.
If you want to automatically create a smooth path between multiple
points, use `SplineService:createCatmullRomPath(splines)`.
