echo 'Do not forget to start the bot. \n\tnode admin-bot/bot.js'

python2 concat.py
coffee -c ./lib/*.coffee  ./data/controllers/*.coffee

cfx xpi &
cfx run --profiledir="~/addon-dev/profiles/centime"
