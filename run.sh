python2 concat.py
# Compile the background script.
coffee -c ./lib/main.coffee  ./lib/src/*.coffee
# Compile injected application.
coffee -c ./data/controllers/*.coffee 
# Compile the settings panel.
coffee -c ./data/settings/*.coffee
# Compile the attached panel.
coffee -c ./data/attached/*.coffee

cfx xpi &
cfx run --profiledir="~/addon-dev/profiles/centime"
