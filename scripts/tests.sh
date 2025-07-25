OUTPUT=SplinesTest.rbxl

rojo build --output $OUTPUT
run-in-roblox --place $OUTPUT --script scripts/run-tests.lua