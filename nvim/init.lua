local current_file = debug.getinfo(1, "S").source:sub(2)
local nvim_root = current_file:match("(.*)/init.lua")

if nvim_root then
    vim.opt.rtp:prepend(nvim_root)
end

require("core.customcommands")
require("core.options")
require("core.lazy")
