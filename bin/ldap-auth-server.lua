#!/usr/bin/env luajit

local posix = require'posix'
local lfs = require'lfs'
local exit = os.exit
local getenv = os.getenv
local etlua = require'etlua'

local script_dir = posix.dirname(posix.dirname(posix.realpath(arg[0])))

posix.chdir(script_dir)

local ok, config = pcall(require,'etc.config')

if not ok then
    print("Error: could not load " .. script_dir .. "/etc/config.lua")
    exit(1)
end

if not config.nginx then
    print("Error: please provide path to nginx in config")
    exit(1)
end

if not config.ldap_base then
    print("Error: missing ldap search base (ldap_base)")
    exit(1)
end

if not config.ldap_filter then
    print("Error: missing ldap search filter (ldap_filter)")
    exit(1)
end

if not config.log_level then
    config.log_level = "error";
end

if not config.work_dir then
    config.work_dir = getenv("HOME") .. "/.ldap-auth-server"
end

if not config.listen then
    config.listen = "127.0.0.1:8080"
end

if not config.worker_processes then
    config.worker_processes = 1
end

if not config.ldap_host then
    config.ldap_host = "127.0.0.1:389"
end

if not config.expire_time then
    config.expire_time = 60;
end

if not lfs.attributes(config.work_dir) then
    lfs.mkdir(config.work_dir)
end

if not lfs.attributes(config.work_dir .. "/logs") then
    lfs.mkdir(config.work_dir .. "/logs")
end

local lof = io.open(config.work_dir .. "/config.lua", "wb")
lof:write("return {\n")
for k,v in pairs(config) do
    if v then
        local t = type(v)
        if(t == "string") then
            lof:write('  ' .. k ..'="' .. v .. '";\n')
        elseif(t == "number") then
            lof:write('  ' .. k ..'=' .. v .. ';\n')
        end
    end
end
lof:write("}\n")
lof:close()

config.lua_package_path = package.path;
config.lua_package_cpath = package.cpath;

local nf = io.open(script_dir .. "/res/nginx.conf","rb")
local nginx_config_template = nf:read("*all")
nf:close()

local template = etlua.compile(nginx_config_template)

local nof = io.open(config.work_dir .. "/nginx.conf", "wb")
nof:write(template(config))
nof:close()

posix.chdir(config.work_dir)
posix.exec(config.nginx, { "-p", config.work_dir, "-c", "nginx.conf" })

