# MT-Booter, a plugin for Movable Type v4.x and Melody #
 
MT-Booter is a utility plugin that was originally developed to automate one of the most onerous and inefficient parts of the Movable Type Quality Assurance (QA) testing process: The creation and provisioning of rich test data.

It can produce a wide variety of blog data although it's not 100% comprehensive.  It has slightly less than a zillion options which, as a developer/QA tool is nothing short of a crowd pleaser and a badge of honor.

## VERSION ##

1.0 (released June 14th, 2009)

This software is is under constant active developement and is intended for use by experienced developers and QA engineers (don't try this at home!).  Hence, it should be considered incredibly useful but perpetually beta-quality, scary, "use at your own risk", seat-of-your-pants software.

## REQUIREMENTS ##

* Movable Type 4.x or any version of Melody
* Acme::Wabby (included in the distribution)

## LICENSE ##

TBD

## INSTALLATION ##

Simply drop the directory `plugins/MTBooter` contained in this archive
into your `MT_HOME/plugins` directory.

If you are running under FastCGI or other persistent environment, you will
need to restart your webserver in order to activate the plugin in your Movable
Type installation.

## USAGE ##

_To be completed_

## CONFIGURATION ##

_To be completed_

## VERSION HISTORY ##

* **2009/07/12 — Version 0.14.2**
    * Primarily fixes a major issue where merge markers where left in one of the modules.
* **2009/04/18 — Version 0.14.1**
    * Includes a number of minor whitespace and formatting fixes
* For all previous versions, please see [the old Subversion logs](http://code.sixapart.com/trac/mtplugins/log/trunk/MTBooter)
    
## SUPPORT ##

There is absolutely no support for this plugin.  That said, if you really need help, you should try the [Movable Type IRC channel on irc.freenode.net](irc://irc.freenode.net/movabletype).

If you have an idea for a feature or identify a bug you want to fix, please don't hesitate to fork it, fix it and send us a pull request.

## AUTHOR ##

This plugin initially created by Chris Hall who was lead Movable Type QA engineer at the time.  It continues it's steady unending march forward to perfection under the care of a mainly two bloodshot-eyed developers who mostly just enjoy correcting each other's whitespace:

* Steve Cook (http://github.com/snark)
* Jay Allen (http://github.com/jayallen)

## COPYRIGHT ##

Copyright (c) 2007 Six Apart. All rights reserved.
