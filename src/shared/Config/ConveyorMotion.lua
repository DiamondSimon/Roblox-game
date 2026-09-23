-- Pure shared math; clients present movement, the server validates it independently.
local M={}
function M.position(startZ,started,speed,destroyZ,now)
 return Vector3.new(0,3,math.min(destroyZ,startZ+math.max(0,now-started)*speed))
end
function M.partPosition(part,now)
 local started=part:GetAttribute("StartServerTime")
 local startZ,speed,destroyZ=part:GetAttribute("StartZ"),part:GetAttribute("BeltSpeed"),part:GetAttribute("DestroyZ")
 if type(started)~="number" or type(startZ)~="number" or type(speed)~="number" or type(destroyZ)~="number" then return part.Position end
 return M.position(startZ,started,speed,destroyZ,now)
end
return M
