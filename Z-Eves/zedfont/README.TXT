        ===================================================

                                Zed

              A FONT FOR THE Z SPECIFICATION LANGUAGE
                                       
                    Release Notes, version 1.0.4

        ===================================================


DESCRIPTION
'Zed' is a font for the Z specification language that can be used on Apple
Macintoshes and under Windows. This release includes a PostScript Type 1 
font, compatible with Adobe Type Manager, a TrueType font and, for the 
Macintosh only, bitmapped fonts in 10, 12, 14, 18 and 24 point sizes.


CHANGES FROM EARLIER VERSIONS

Version 1.0.4
The main changes from Version 1.0.1 are
     + better schema boxes, both on screen and on paper
     + improved bitmap characters
     + 14pt and 18pt bitmaps included
     + AFM file included (for those who need such things)
     + New character, 'there does not exist...'
     + Larger relational composition (semi-colon) character


Version 1.0.1 
This version replaced the font 'Z'. Substantial changes were made, and the 
two fonts are not key compatible, hence the change of name. These changes 
are described below. To preserve existing documents, do not discard the old 
'Z' font. 

	+ Zed supports the Z Base Standard, Version 1.0. It includes all 
	  characters in the standard and those in the Spivey book (the old 
	  Z font was based on Hayes' book). Other characters have also been 
	  added, for example many different types of semantic brackets.
	  
	+ Zed includes characters for drawing schema borders (aside: these
	  look much better on paper than on screen).
	
	+ Zed is no longer a composite of the Symbol font: users will have to 
	  use Symbol explicitly to get, say, greek letters. This change has
	  several advantages:
	      - More characters are available.
	      - Characters are no longer hidden in obscure places requiring
	        multiple keystrokes.
	      - Wherever possible, similar characters have been placed 
	        adjacently (at least on the Macintosh).
	      - Some of the more common characters have been placed in more
	        memorable positions, e.g. "for all" is at A, "there exists" is 
	        at E, ...
	  
	+ Zed includes Type 1  and Truetype fonts for use with Adobe Type 
	  Manager on the Macintosh or under Windows (Z was a Type 3 font).
	  
	+ Zed uses a 'blackboard' font for operators like the powerset symbol P,
	  whereas Z used a serif P. Ditto for Z, F, N, R and Q. The reason for 
	  this change is conformance with general practice rather than aesthetics.
	  
	  
INSTALLATION INSTRUCTIONS FOR THE PC
This release includes the following files for use with Adobe Type Manager
	.PFM		font metrics information
	.PFB		PostScript information
	.AFM		font metrics information (text format)
and a TrueType version of the font
	.TTF		TrueType font
	
The Postscript versions are of a superior quality to the TrueType ones.

	
You must install either the PostScript version or the TrueType version included 
with this release.

The following instructions are believed to be correct.

To install the PostScript font for use with Adobe Type Manager:  

 1. Open the ATM Control Panel under Windows and press the "Add..." button.
 2. Double-click on the drive designator for your floppy in the Directories 
    list box.
 3. Identify a target directory for the PostScript outline font, e.g.
    		"C:\psfonts".
 4. Identify a target directory for the font metrics file, e.g.
    		"c:\psfonts\pfm".
 5. Find and select the Zed font.
 6. Press the "Add" button.
 7. Exit and restart Windows for these changes to take effect.
 
If you are using a PostScript printer:

 1. Make a backup of WIN.INI now!
 2. Open WIN.INI (e.g. with Notepad). In the "Printer driver" section you 
    will see something like: [PostScript,LPT2] followed by a list 
    containing something like this:
    		softfonts5=c:\psfonts\pfm\Zed.PFM
 3. Change this to:
    		softfonts5=c:\psfonts\pfm\Zed.PFM,c:\psfonts\pfm\Zed.PFB
    **Do not use a semi-colon between the two entries or you will cause 
    some rather unpleasant problems.**
 4. "Save" and "Close"
 5. Exit and restart Windows for these changes to take effect.
 
To install the TrueType font:

 1. Open the Fonts Control Panel under Windows and press the "Add..." button.
 2. Select the floppy disk.
 3. Select the Zed font and press the "OK" button.
 4. Press the "Close" button.
 
LINE SPACING PROBLEMS
Users of word processing applications may need to take care to get line 
spacing right, especially at small sizes in schema boxes. Some word 
processors (e.g. Microsoft Word) set the lines spacing (leading) to a fixed 
amount, say 12 points. If you are working at a smaller size, say 10 pt, you 
may need to change the leading from 'Automatic' to 'Exactly 10pt'. Other 
applications (e.g. Aldus PageMaker) can use a proportional leading system 
(e.g. the leading is 120% of the type size) and so do not suffer from 
these problems. 

The second problem is that the space above the middle line in a schema box 
will, in all cases, be too large since the line is made up of underscore 
characters. The solution once again is to adjust the leading. You may find 
6pt leading for this line acceptable if the rest of the schema uses 12pt type. 

LICENSE AGREEMENT
This font is free but not in the public domain and the copyright remains
with the author, Richard Jones. However you may copy and distribute the 
font provided that you include a copy of this license agreement.
(C) Richard Jones, 1995

Richard Jones

===============================================================================

Computing Laboratory                            email: R.E.Jones@ukc.ac.uk
University of Kent at Canterbury                Telephone: 01227 827943
Canterbury, CT2 7NF, U.K.                       FAX: 01227 762811

===============================================================================

