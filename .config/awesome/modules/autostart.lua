local awful = require("awful")

do
    local cmds = {
        "lxpolkit",
        "light -S 30",
        "nitrogen --restore",
    }

    for _, value in ipairs(cmds) do
        awful.spawn.with_shell(value .. "&")
    end
end
