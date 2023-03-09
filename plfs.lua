-- A pure Lua filesystem and path library
--
-- https://github.com/UrNightmaree/plfilesystem
-- Scroll down to see LICENSE

---@param func string
---@param arg number
---@param expected_type string
---@param got_type string
local function throw_arg_error(func,arg,expected_type,got_type)
    error(("bad argument #%d to '%s' (%s expected, got %s)"):format(
    arg,
    func,
    expected_type,
    got_type
    ))
end

---@param func string
---@param ... any|string
local function check_arg_type(func,...)
    local argc = 1
    for i = 1,select('#',...),2 do
        local val,ex_type = select(i,...),select(i+1,...)

        if type(val) ~= ex_type then
            throw_arg_error(func,argc,ex_type,type(val))
        end
        argc = argc + 1
    end
end

--[[
Create a copy of a file

```lua
-- a `file` was created with content `foo bar`
plfs.copy("file","myfile") -- copy `file` with name `myfile`

local f = io.open("myfile","r")
print(f:read "a") --> foo bar
f:close()
```
]]
---@param file string
---@param new_file string
---@return boolean
---@return string?
local function plfs_copy(file, new_file)
    check_arg_type("copy",
    file, "string",
    new_file, "string"
    )

    local old_f, of_err = io.open(file, "rb")
    local new_f, nf_err = io.open(new_file,"wb")

    if old_f and new_f and not (of_err and nf_err) then
        new_f:write(old_f:read "*a")
    else
        if not old_f and new_f then
            new_f:close()
            os.remove(new_file)
        elseif old_f and not new_f then
            old_f:close()
        end

        ---@diagnostic disable-next-line:return-type-mismatch
        return false, not old_f and of_err and
                of_err or
            not new_f and nf_err and
                nf_err
    end

    new_f:close()
    old_f:close()
    return true
end

return {
    copy = plfs_copy
}
