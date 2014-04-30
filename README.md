Resonance
=========


Resonance is a Firefox plugin for a more open and connected web, where the users can meet and discuss as they browse the net and visit websites.
It will allow you to talk instantly with the other people reading the page you're reading, as well as join other people's navigations.


Install
-------
    **Download the extension file :**
        ```
        https://github.com/centime/resonance/raw/master/resonance.xpi
        ```
    **Install from Firefox :**
        ```
        Ctrl + O , and select the file.
        ```

Usage
-----    
    **Display the Add-on bar**
            ```
            View > Toolbars > Add-on bar
            ```
        or
            ```
            Ctrl + Maj + /
            ```

    **Start Resonance on a page**
        ```
        left-click the Resonance icone
        ```
        Resonance will appear at the bottom of the page. 
        On the left side you can start talking.
        On the right side, a list of the other people viewing the page is displayed. You've been given a default random name, which you can change in the settings panel.
        You can click on any user to either start a private conversation or mute him/her. His messages won't be displayed to you anymore.
        The top right menu gives you access to :
            * TopPages :
                When opened, it will get you a `list of pages where people are using Resonance.` If anything looks interesting, go join them !
                You can filter the pages using keywords from the url.
            * PrivateMessages :
                The list of users on the page is remplaced by the `list of users you have started a conversation with.`
                You can select any of them by clicking on it, and then start talking.
            * Notifications :
                An announce is displayed instead of the list of users. We will use it to keep in touch with you !
                Any error will also be printed there.
        Clicking TopPages, PrivateMessages or Notifications will display it.
        Click it again to go back to the main page discussion. 

    **Access the settings panel**
        ```
        right-click the Resonance icone
        ```
        A few options are currently available, to start Resonance by default for a specific website or for every page.
        You can also change your nickname to something else that is not already taken (or generate a random one !). You'll then need to restart firefox.


Technical Description
---------------------    
    Resonance is a IRC client.
    It uses a custom lib, ff-irc, generated from node-irc.
    The informations used for TopPages are managed by a IRC bot for now.
    

Contribute
----------
    **You will need the following projects :**
        ```
        Firefox Add-on manager (cfx)
        https://developer.mozilla.org/en-US/Add-ons/SDK/Tutorials/Installation

        Coffee-script
        http://coffeescript.org/#installation
        (This will require nodejs and npm)
        ```
    **Clone the git repository**
        ```
        git clone https://github.com/centime/resonance/
        ```
    **Compile the sources and start a def instance of firefox**
        ```
        cd resonance
        ./run.sh
        ```
    **You could want to start the bot also...**
        ```
        coffee ircBot/adminBot.coffee
        ```
        ...but you will get a nickname conflict with the one already running.
        the nickname would have to be changed in every of theses files :
            adminBot.coffee
            lib/src/*.coffee
            data/controllers/*.coffee