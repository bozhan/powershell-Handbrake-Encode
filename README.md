# powershell-Handbrake-Encode
Using powerhsell and Handbrake CLI to encode all files in a provided directory with the same encode settings.

Currently uses HandBrakeCLI-1.1.1 located in the ./lib folder

Use Handbrake-Encode.ps1 to encode files in specified folder path.
For additional help use the -help operatior with Handbrake-Encode.ps1.

If no destination folder is specified all newly encoded files will be saved in the source folder with the postfix "-1".
After the encoding is done, a report of the size difference will be printed out since the main goal for me using this script is reencoding high resolution and/or high bitrate files to something more managable.

If for some reason you need to interrupt the process, you can use the Compare-Encoded-File-Count.ps1 script to figure out which sub directories have how many files reencoded.
