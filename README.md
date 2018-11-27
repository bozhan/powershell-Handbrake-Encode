# powershell-Handbrake-Encode
Using powerhsell and Handbrake CLI to encode all files in a provided directory with the same encode settings.

Currently uses HandBrakeCLI-1.1.1 located in the ./lib folder
https://handbrake.fr/downloads2.php

Use Handbrake-Encode.ps1 to encode files in specified folder path.
For additional help use the -help operatior with Handbrake-Encode.ps1.

If no destination folder is specified all newly encoded files will be saved in the source folder with the postfix "-1".
After the encoding is done, a report of the size difference will be printed out since the main goal for me using this script is reencoding high resolution and/or high bitrate files to something more managable.

If for some reason you need to interrupt the process, you can use the Compare-Encoded-File-Count.ps1 script to figure out which sub directories have how many files reencoded.

# Example
Let's assume you have a folder with 10 video files with resolution 1920x1080 and an average video bit rate of 3000.
The content of the video files is not that dynamic (e.g. slide presentation or video tutorial) and you know that if you reencode the files with h264/h265
you will get at least 40% compression rate. 

Let's say you want to reencode all files in that folder to frame width 1280 and an RF quality of 23 with audio quality of 128 bit.
Using Handbrake-Encode.ps1 the powershell commad will look as follows:
e.g. folder with video content is C:\username\video\my_presentation

PS C:\powershell-Handbrake-Encode\Handbrake-Encode.ps1 -w 1280 -q 23 -aq 128 -d "C:\username\video\my_presentation"

The -d paramter is mandatory but does not have to be defines in quotes with the rest of the options.
If a path is missing the script will ask for an initial path untill you provide a valid one.
e.g. Source Folder: