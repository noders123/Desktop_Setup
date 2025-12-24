Step 1
  Manually install all windows software you want on your system
  ** only wsl is really required for the next steps

Step 2
  Verify WSL is installed properly with: "wsl --version"

step 3
  in wsl run:
``` 
git clone https://github.com/noders123/Desktop_Setup.git
cd Desktop_Setup
bash linux-installs.bash
```


improvement suggestions:
  * add a script that copies importent config files(.bashrc, .bash_aliases, ~/.config) from a source machine
