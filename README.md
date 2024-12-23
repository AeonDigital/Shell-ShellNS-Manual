Shell-ShellNS-Manual
================================

> [Aeon Digital](http://www.aeondigital.com.br)  
> rianna@aeondigital.com.br

&nbsp;

``ShellNS Manual`` allows you to extract the technical information from 
function scripts and prepare them to be used for querying and/or creating 
completion hint messages.  


&nbsp;
&nbsp;

________________________________________________________________________________

## Main

After downloading the repo project, go to its root directory and use one of the 
commands below

``` shell
# Loads the project in the context of the Shell.
# This will download all dependencies if necessary. 
. main.sh "run"



# Installs dependencies (this does not activate them).
. main.sh install

# Update dependencies
. main.sh update

# Removes dependencies
. main.sh uninstall




# Runs unit tests, if they exist.
. main.sh utest

# Runs the unit tests and stops them on the first failure that occurs.
. main.sh utest 1



# Export a new 'package.sh' file for use by the project in standalone mode
. main.sh export
```

&nbsp;
&nbsp;


________________________________________________________________________________

## Standalone

To run the project in standalone mode without having to download the repository 
follow the guidelines below:  

``` shell
# Download with CURL
curl -o "shellns_manual_standalone.sh" \
"https://raw.githubusercontent.com/AeonDigital/Shell-ShellNS-Manual/refs/heads/main/standalone/package.sh"

# Give execution permissions
chmod +x "shellns_manual_standalone.sh"

# Load
. "shellns_manual_standalone.sh"
```


&nbsp;
&nbsp;

________________________________________________________________________________

## Licence

This project uses the [MIT License](LICENCE.md).