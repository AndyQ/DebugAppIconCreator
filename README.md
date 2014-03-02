DebugAppIconCreator README
========================

by Andy Qua - @AndyQ

OVERVIEW
--------
DebugAppIconCreator is a small command line app designed to add debug information to iOS App Icons.

This has been designed to work mainly with AssetCatalogs but it shoud work fine with normal App Icons (although you may need some tweaking and I haven't done this yet but the principle is the same).

NOTE - This assumes that the output image is a PNG file.

INSTALLATION
------------

1. Download project and build in XCode
2. Build project. XCode will be default install into /usr/local/bin
   IF you want it installed into a different location then if you edit the Target build settings - change the Installation Build Products Location value and the Installation Directory value to your preferred locations.

COMMAND LINE USAGE
------------------
To run from the command line (e.g. to edit a single file use:  
`DebugAppIconCreator <source image file> <destination image file> <build number>`

By default, the App writes out the following info on a white overlay ontop of the source image:  
`DEV  
<buildnr>`

e.g.  
`DEV  
1.2.22`

You can customise this by changing the drawing code as appropriate.

Integrating into XCode Build
----------------------------

The way this works is that we create a seperate set of icons for our dev build. Then, when we build, first step we do is to one at a time, take a copy of each of the production icons, overlay the build number on the icon and then overwrite the same icon in the Dev icon set.

### Setting Up Asset Catalog ###

To have a custom set of images, what we want is the normal App Icon image that will be used for our production code, and then a separate one for Development builds.
So, I'm assuming that you have already got an asset catalog setup and populated with your normal App Icon images. (if you haven't there is plenty of documentation on how to set this up).

* First, open up your Asset catalog
* Copy the existing AppIcon set by Alt-Click and Hold on the AppIcon item and then draw to create a duplicate (will be named AppIcon-1)
* Rename the AppIcon-1 by clicking once on it, waiting about 2 seconds and the clicking again. Rename to something like AppIcon-Dev
* Then, open up the Project settings, select your main target and select the General Tab.
* Scroll down to App Icons, and in the Source drop down, select AppIcon-Dev.


**NOTE - This switches your project over to use the newly created Dev App Icons source. You will need to change this back when releasing your app for production!**  

**A better way would be to create a separate target for development builds (as you may forget to switch this back!)**

### Creating build script ###

Under build Phases for your target (this is why its a good idea to have a seperate target for development builds), add a New Run Script Build Phase.
Move this to just under the Target Dependencies build phase.

The script should be similar to the below - you will need to set the value of the SOURCE\_SUB\_FOLDER but that should be all.  

<code>SOURCE\_SUB\_FOLDER=&lt;subfolder where assets catalog in held under project&gt;  
VERSION=\`/usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" ${SRCROOT}/${INFOPLIST\_FILE}\`  
/users/andy/bin/DebugAppIconCreator "${PROJECT\_DIR}/${SOURCE\_SUB\_FOLDER}/Images.xcassets/AppIcon.appiconset/Icon-120.png" "${PROJECT\_DIR}/${SOURCE\_SUB\_FOLDER}/Images.xcassets/AppIcon-Dev.appiconset/Icon-120.png" ${VERSION}  
/users/andy/bin/DebugAppIconCreator "${PROJECT\_DIR}/${SOURCE\_SUB\_FOLDER}/Images.xcassets/AppIcon.appiconset/Icon-76@2x.png" "${PROJECT\_DIR}/${SOURCE\_SUB\_FOLDER}/Images.xcassets/AppIcon-Dev.appiconset/Icon-76@2x.png" ${VERSION}  
/users/andy/bin/DebugAppIconCreator "${PROJECT\_DIR}/${SOURCE\_SUB\_FOLDER}/Images.xcassets/AppIcon.appiconset/Icon-76.png" "${PROJECT\_DIR}/${SOURCE\_SUB\_FOLDER}/Images.xcassets/AppIcon-Dev.appiconset/Icon-76.png" ${VERSION}
</code>

This pulls out the short version string from your INFO-PLIST file, then updates the Retina iPhone image (Icon-120) and the retina and non-retina iPad images (Icon-76 and Icon-76@2x).  If you want additional images updated them add them also.

Then, build your project, once its completed, check the asset catalog and the AppIcon-Dev and with luck, the icons will have been updated with your build bumber on them.

Deploy out to simulator and you should see the app deployed with the debug info on the icon

License
=======
(MIT Licensed)

Copyright (c) 2014 Andy Qua

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
