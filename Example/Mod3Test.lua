local moduleName = ...
local M = {}
_G[moduleName] = M

function M.f2()
    print("f2")
    return("ok!")
end

function M.f1()
print("f1")
end

return M
