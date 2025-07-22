set -e

rojo build -o Splines.rbxl
run-in-roblox --place Splines.rbxl --script scripts/run-tests.lua
rm Splines.rbxl