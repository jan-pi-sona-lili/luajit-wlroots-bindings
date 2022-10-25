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
	rm -r ./headers/wayland-master/tests/ ./headers/wlroots-master/examples/
	printf " Done.\n"
else
	echo "ERROR: headers folder exists already."
fi

echo "Processing headers... [compiler output starts on next line]"
FILES=$(find ./headers -type f)
USE_UNSTABLE=true
COMMAND="-Wall -E $($USE_UNSTABLE && echo '-DWLR_USE_UNSTABLE' || echo '') -I/usr/include/drm $(find ./headers/wlroots-master/include/ -type d | sed 's/^/-I /')"
mkdir processed
for f in $FILES
do
	after_slash=$(echo $f | sed 's:.*/::')
	pafter="./processed/$after_slash"
	gcc $COMMAND $f | grep -v '^#' | grep -v -e '^$' > $pafter
	echo "local ffi=require('ffi') ffi.cdef[[typedef long double _Float128;typedef unsigned int socklen_t;\n$(cat $pafter)]] return ffi.C" > $pafter
	
	#there has got to be a better way to do this
	perl -0777 -i.orig -pe "s/enum[\n\r]  {[\n\r]    FP_NAN =[\n\r]      0,[\n\r]    FP_INFINITE =[\n\r]      1,[\n\r]    FP_ZERO =[\n\r]      2,[\n\r]    FP_SUBNORMAL =[\n\r]      3,[\n\r]    FP_NORMAL =[\n\r]      4[\n\r]  };//gm" $pafter
	perl -0777 -i.orig -pe "s/struct wl_message {[.\n\r ]*const char \*name;[.\n\r ]*const char \*signature;[.\n\r ]*const struct wl_interface \*\*types;[ .\n\r]*};//gm" $pafter
	perl -0777 -i.orig -pe "s/struct timeval[\n\r]{[\n\r]  __time_t tv_sec;[\n\r]  __suseconds_t tv_usec;[\n\r]};//gm" $pafter
	perl -0777 -i.orig -pe "s/struct wl_interface {[\n\r] const char \*name;[\n\r] int version;[\n\r] int method_count;[\n\r] const struct wl_message \*methods;[\n\r] int event_count;[\n\r] const struct wl_message \*events;[\n\r]};//gm" $pafter
	rm $pafter.orig
	
	no_dot=$(echo $after_slash | sed 's/\..*//')
	mv $pafter ./processed/$no_dot.lua
	echo "local $(echo $no_dot | sed 's/-/_/g')=require('./processed/$no_dot')" >> requires
done
echo "Done."

printf "Consolidating output into single file and cleaning up..."
echo "local ffi=require('ffi')\n ffi.cdef[[enum\n   {\n     FP_NAN =\n       0,\n     FP_INFINITE =\n       1,\n     FP_ZERO =\n       2,\n     FP_SUBNORMAL =\n       3,\n     FP_NORMAL =\n       4\n   };struct wl_message {\n    /** Message name */\n    const char *name;\n    /** Message signature */\n    const char *signature;\n    /** Object argument interfaces */\n    const struct wl_interface **types;\n};typedef long int __time_t; typedef long int __suseconds_t;struct timeval\n{\n  __time_t tv_sec;\n  __suseconds_t tv_usec;\n};struct wl_interface {\n const char *name;\n int version;\n int method_count;\n const struct wl_message *methods;\n int event_count;\n const struct wl_message *events;\n};]] $(cat requires)\nreturn ffi.C" > wlroots.lua
rm -r requires headers
printf " Done.\n"
echo "Done."