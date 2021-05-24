The colors-rofi-dark.rasi is just a symbolic link to the output of the pywall cache generated by the current wallpaper. 

The configuration declares a theme given by the name of `colors-rofi-dark.rasi`.

After creating the cache with the command:

```sh
wal -i /path/to/my_wallpaper 
```

You just copy the file to where rofi expects it:

```sh
cp ~/.cache/wal/colors-rofi-dark.rasi ~/.config/rofi/colors-rofi-dark.rasi
```

I do this automatically everytime I refresh the session in my i3 config, using a symbolyc link to this directory.
