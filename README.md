ohttpd2
=======
This is the second iteration of ohttpd, a generic-purpose HTTP server written in Objective-C.

Difference between original ohttpd and this iteration
-----------------------------------------------------
This version of ohttpd have multiple improvements from original ohttpd:

* Network interface is overhauled and redesigned. The original library I used are not portable. This version is designed to be compatible with both Apple's Objective-C environemt and GNUstep <http://www.gnustep.org> simultaeniously, using BSD sockets.
* Development is steered in favor of WebUIKit. WebUIKit is a set of classes designed to provide a simple yet effective way to design dynamic web contents with Objective-C. For more details, please read the README file in WebUIKit folder.

License and legal
-----------------
This project is free software. See <http://www.maxchan.info/liccense/foss.aspx> for more license detail.
