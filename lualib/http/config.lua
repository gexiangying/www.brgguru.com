local modename = ...
local M ={}
_G[modename] = M
package.loaded[modename] = M

_ENV = M

maxinput = 500 * 1024 * 1024
maxfilesize = 100 * 1024 * 1024
upload_dir = "uploadfile/"
