
# download and extract wayland-master and wlroots-master, extract to ./headers, and scrub ./headers of any non-header files
if ! test -d headers
then 
	printf "Making headers directory..."
	mkdir headers
	printf " Done.\n"
	printf "Downloading wayland-master.zip..."
	wget https://github.com/wayland-project/wayland/zipball/master -O wayland-master.zip -q
	printf " Done.\n"
	printf "Unzipping wayland-master.zip..."
	unzip ./wayland-master.zip -d ./headers 1>/dev/null
	mv ./headers/wayland* ./headers/wayland-master
	rm ./wayland-master.zip
	printf " Done.\n"
	printf "Downloading wlroots-master.zip..."
	wget https://gitlab.freedesktop.org/wlroots/wlroots/-/archive/master/wlroots-master.zip -O wlroots-master.zip -q
	printf " Done.\n"
	printf "Unzipping wlroots-master.zip..."
	unzip ./wlroots-master.zip -d ./headers 1>/dev/null
	rm ./wlroots-master.zip
	printf "Done. \n"
	printf "Sanitizing ./headers of non-header files..."
	find ./headers/ ! -name *.h -delete 2>/dev/null
	printf " Done.\n"
else
	echo "ERROR: 'headers' already exists. Please remove or rename it, then try again."
	exit 1
fi


printf "Collecting constructors..."
touch constructors
echo > fix.lua $(cat <<-END
local arg = arg[1] 
local file=io.open(arg)
local contents=file:read("a")
file:close()

local constructors = {}
for n,c in contents:gmatch("[\\\\n\\\\r]struct ([%w_]+) (%b{});") do 
	constructors[#constructors+1] = "['"..n.."'] = ffi.typeof('"..n.."'),"
end 
for n,c in contents:gmatch("[\\\\n\\\\r]enum ([%w_]+) (%b{});") do 
	constructors[#constructors+1] = "['"..n.."'] = ffi.typeof('"..n.."'),"
end 

local file = io.open("constructors", "a+") 
file:write(table.concat(constructors, " ")) 
file:close()
END
)
for i in $(find ./headers -type f)
do
	luajit fix.lua $i
done
printf " Done.\n"


printf "Processing headers..."
USE_UNSTABLE=true
gcc -E $($USE_UNSTABLE && echo "-DWLR_USE_UNSTABLE" || echo "") -I/usr/include/drm $(find ./headers/wlroots-master/include/ -type d | sed 's/^/-I /') $(find ./headers -type f) | grep -v ^# | grep -v -e '^$' > compiled.h
rm -r ./headers/
printf " Done.\n"


echo > fix.lua $(cat <<-END
local file = io.open("compiled.h")
local contents = file:read("a")
file:close()

contents = contents:gsub("([={};,])[ \\\\n\\\\r\\\\t]+","%1"):gsub("[ \\\\n\\\\r\\\\t]+([={};,])","%1")


local file = io.open("compiled.h","r+")
file:write(contents)
file:close()
END
)
luajit fix.lua


printf "Finalizing..."
echo "local ffi=require('ffi') ffi.cdef[[typedef uintptr_t _Float128; $(cat compiled.h)]] return {$(cat constructors)"} > wlroots.lua
rm compiled.h constructors fix.lua
printf " Done.\n"
echo "Done."
