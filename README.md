# mac-turnkey

A small shell script to auto install Mac App-Store applications as well as non-app store apps and CLI tools.

It will automatically mount, copy and unmount dmg and zip files. It utilises the [mas-cli](https://github.com/mas-cli/mas) to install app-store applications and [Homebrew](https://github.com/Homebrew/homebrew-core) to install other cli tools.

### How it works:

Place the script and config.txt file in the same directory anywhere that you have permissions to execute the script. 
The configuration file has three directives: (#brew, #app, and #install) you may utilize them as follows to specify which packages/applications will be installed. It's important to provide exactly one space between the colon and application name.

Install packages must directly link to a .dmg or .zip file. 

```
#brew: wget --with-libressl
#app: Slack
#app: xcode
#install: https://dl.google.com/chrome/mac/stable/GGRO/googlechrome.dmg 
```

### How to use it:

It's like running any other script, you'll need to make sure the script has permissions to execute so alter the permissions and run.

```
chmod +x turnkey.sh
./turnkey.sh
```

### Further Development

1) Add configuration for system settings / preferences
2) Add functionaility to remove/update applications on cli
3) Perhaps a hosted target to provide better infrastructure for finding install app updates.
