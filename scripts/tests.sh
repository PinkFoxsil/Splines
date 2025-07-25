OUTPUT=SplinesTest.rbxl

rojo build --output $OUTPUT || exit -1
run-in-roblox --place $OUTPUT --script scripts/run-tests.lua
rm $OUTPUT