# Stank
### Description: 
    Simply put, STANK, is a file sniffer. It is a powershell tool that allows for recursive file  
    search based on the extension, as well as gathering metadata about each of the files that it finds. 
    It conveniently then makes copies of these files and puts them in an output location specified by 
    the user that can be used for further inspection later on.
### Usage:
    .\stank.ps1 -i <INPUT_PATH> -o <OUTPUT_PATH> [[-e] <extension>]
### Help Page:
    Options:
        -a                    Search for all file extensions (default).
        -e [extension]        Specify the file extension to be searched for.
        -h                    Display the help menu.
        -i [path]             Specify the file path for base iteration
        -o [path]             Specify the output path for resulting files.
### Contributors:
  - Matt Robinson
  - Joshua Weiss
  - Gino Placella
  - Tyler White
