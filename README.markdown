About Quicksilver Plugins on Github
===================================

This repository contains the current source code of a the Quicksilver Plugin / Module. If you're having issues with this plugin, feel free to log them at the [Quicksilver issue tracker](https://github.com/quicksilver/Quicksilver/issues).

Always be sure to check the [Google Groups](http://groups.google.com/group/blacktree-quicksilver/topics?gvc=2) first incase there's a solution to your problem, as well as the [QSApp.com Wiki](http://qsapp.com/wiki/).

Remember The Milk Plugin
------------------------

This plugin was created by [Brian Moore](https://github.com/BinaryMinded) of [Binary Minded Software](http://www.binaryminded.com/). Ownership and the maintaing of the project has since been moved to the Quicksilver organisation.

Remember The Milk for Quicksilver is an open source application released under the BSD open source license. 


Before You Try It Out
---------------------

Before trying out any of these plugins, it's always a good idea to **BACKUP** all of your Quicksilver data.

This is easily done by backing up the following folders 

(`<user>` stands for your short user name):

`/Users/<user>/Library/Application Support/Quicksilver`  
`/Users/<user>/Library/Caches/Quicksilver`

	
Before Building
---------------

Before being able to build any of these plugins, you **MUST** set a new Source Tree for the `QSFramework` in the XCode Preferences.

This is done by going into the XCode preferences, clicking 'Source Trees' and adding a new one with the following options:

Setting Name: `QSFrameworks`  
Display Name: a suitable name, e.g. `Quicksilver Frameworks`  
Path: `/Applications/Quicksilver.app/Contents/Frameworks` (or path of Quicksilver.app if different)

For some plugins to compile correctly a source tree must also be set for `QS_SOURCE_ROOT` that points to the location of the [Quicksilver source code](https://github.com/quicksilver/Quicksilver) you've downloaded onto your local machine.

Setting Name: `QS_SOURCE_ROOT`	
Display Name: a suitable name, e.g. `Quicksilver source code root`	 
Path: `/Users/<user>/<path to Quicksilver source code>`

See the QSApp.com wiki for more information on [Building Quicksilver](http://qsapp.com/wiki/Building_Quicksilver).

Also check out the [Quicksilver Plugins Development Reference](http://projects.skurfer.com/QuicksilverPlug-inReference.mdown), especially the [Building and Testing section](http://projects.skurfer.com/QuicksilverPlug-inReference.mdown#building_and_testing).

Legal Stuff 
-----------

Copyright (c) 2007, Brian Moore
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.