# luajit-wlroots-bindings
A shell script that downloads and patches the Wayland and WLRoots headers into a LuaJIT file that ideally would be able to be `require`d.

## Tips
  - Make sure that `libvulkan`, `libdrm`, `gcc`, `perl`, and `wget` (or their respective equivalents) are installed, besides the Wayland and wlroots packages.
  - You may need to symlink `/usr/include/libdrm/` to `/usr/include/drm/`.
  - Also note that this program does *not* work as of 24 October 2022.
    - It doesn't work because [LuaJIT fails on identical redeclarations](https://github.com/LuaJIT/LuaJIT/issues/28). If someone can figure out a way to work around this, or patch LuaJIT so it does not do that anymore, it would be greatly appreciated. The current method I'm using is incredibly inefficient (I manually run LuaJIT, fix each redeclaration error by searching up the declaration in the file that has the error, turn it into a perl-compatible format, and add a command to `generate.sh` to remove all instances of it and add a single new one.)
## Why?
I thought it would be an interesting idea, and not an entirely impractical one with LuaJIT's speed and FFI capabilities. I've always wanted to learn more about Wayland/wlroots, and what better way than to make a library for it that other people might get some use out of, too?
## Running
  - After checking through the source code, as is always a good idea before running arbitrary shell scripts from off the internet, you can run `sh generate.sh` and it should, after a little bit, create a file called `wlroots.lua` and a directory called `processed`. You can't actually do anything with these as of yet.
