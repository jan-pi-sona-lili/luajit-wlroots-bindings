# luajit-wlroots-bindings
An UNFINISHED shell script that downloads, patches, and flattens the Wayland and WLRoots headers into a LuaJIT file that ideally would be able to be `require`d.

## Tips
  - Make sure that `libvulkan`, `libdrm`, `gcc`, and `wget` (or their respective equivalents) are installed, besides the Wayland and WLRoots packages.
  - You may need to symlink `/usr/include/libdrm/` to `/usr/include/drm/` (`sudo ln -s /usr/include/libdrm /usr/include/drm/`).
  - Also note that THIS PROGRAM **DOES NOT** WORK AS OF 15 OCTOBER 2022.
    - The only reason it doesn't work is because [LuaJIT fails on identical redeclarations, a problem that has apparently remained unfixed, or at least unmodified, for 7 years.](https://github.com/LuaJIT/LuaJIT/issues/28) If someone can 1) figure out a way to work around this, or 2) patch LuaJIT so it does not do that anymore, it would be greatly appreciated. Pull requests are welcomed.
## Who wanted this?
  - Nobody, but I thought I might as well do it since nobody else had yet. Perhaps it will eventually find some sort of use.
## Running
  - After checking through the source code, as is always a good idea before running arbitrary shell scripts from off the internet, you can run `sh generate.sh` and it should, after a little bit, create a file called `wlroots.lua`. You can't actually do anything with this file as of yet.
