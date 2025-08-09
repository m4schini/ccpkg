REPO_USERNAME = "m4schini"
REPO_NAME = "ccpkg"
REPO_URL = 'https://raw.githubusercontent.com/%s/%s/refs/heads/main/%s'

local arg_package = ...
local expect = require "cc.expect"
local expect, field = expect.expect, expect.field

local function pkgUrl(pkgName)
    expect(0, REPO_USERNAME, "string")
    expect(0, REPO_NAME, "string")
    expect(1, pkgName, "string")
    return REPO_URL:format(REPO_USERNAME, REPO_NAME, pkgName)
end

print("Downloading", arg_package)
local response, err = http.get(pkgUrl(arg_package))
if err ~= nil then
    error(err)
    return
end
local file = io.open(arg_package, "w")
io.output(file)
io.write(response.readAll())
io.flush()
io.close(file)
