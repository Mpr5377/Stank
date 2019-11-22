<#
    Names: Matt Robinson, Joshua Weiss, Gino Placella, and Tyler White
    Tool Name: STANK
    Description: Simply put, STANK, is a packet sniffer. It is a powershell tool that allows for recursive file search based on the extension,
    as well as gathering metadata about each of the files that it finds. It conveniently then makes copies of these files and puts them in an 
    ouptut location specified by the user that can be used for further inspection later on. 
 #>


<#
    The following param block is the section that defines what paramaters can be passed
        Variables:
            -a                  Search for all file extensions (default).
            -e [extension]      Specify the file extension to be searched for.
            -h                  Display the help menu.
            -i [path]           Specify the file path for base iteration.
            -o [path]           Specify the output path for resulting files.  
 #>
param (
        [switch]$a = $false,
        $e,
        [switch]$h = $false,
        $i,
        $o
    )


<#
    Function: paramaterCheck
    Params: None
    Returns: Void
    Description: paramaterCheck is the function that gets called when the script runs.
                 It is used in order to check the variables that are passed in and call the
                 proper functions based on the input.
 #>
function paramaterCheck(){
    <# 
        If statement logic:
        Check if -h was passed
        Check to make sure both -i and -o were passed
        Validate both inputs of -i and -o
        Check if -e was passed
            if so -> call fileSearchType $e
            else -> call fileSearchAll
     #>
    if($h){
        # Clear the terminal and display the help menu
        Clear-Host;
        printHelp
    } elseif (!$i -or !$o) {
        # Write Usage Statement to the output
        Write-Host "    USAGE STATEMENT: .\stank.ps1 -i <INPUT_PATH> -o <OUTPUT_PATH>" -ForegroundColor red
        Write-Host "    Please try again or see -h for more help" -ForegroundColor red
    } elseif (!(Test-Path -path $i) -or !(Test-Path -path $o)){
        # Write Usage Statement to the output
        Write-Host "    USAGE STATEMENT: .\stank.ps1 -i <INPUT_PATH> -o <OUTPUT_PATH>" -ForegroundColor red
        Write-Host "    Check the supplied paths and please try again or see -h for more help" -ForegroundColor red 
    } elseif ($e){
        # call fileSearchType $e where $e is the extension to search for
        fileSearchType $e
    } else {
        # call fileSearchAll to find all files
        fileSearchAll
    }
}


<# 
    Function: fileSearchType
    Params: $Extension - The extension to be used when looking and collecting files
    Returns: Void
    Description: Recursively find files that end with the passed in extension and
                 call copyFile passing the file object to it
 #>
function fileSearchType($Extension){
    # Set the extension variable to be passed into the -Filter below
    $Extension = "*." + $Extension;
    # Recursively find files that end with the given extension and pass them to the copyFile function
    Get-ChildItem -Path $i -Recurse -Filter $Extension | ForEach-Object {
        copyFile $_
    }
    # Call jobCompleted to clear screen and print "Request Completed"
    jobCompleted 
}


<# 
    Function: fileSearchAll
    Params: None
    Returns: Void
    Description: Recursively finds all files regardless of their extension and
                 calls copyFile passing the file object to it
 #>
function fileSearchAll(){
    # Recursively find files and pass them to the copyFile function
    Get-ChildItem -Path $i -Recurse -File | ForEach-Object {
        copyFile $_
    }
    # Call jobCompleted to clear screen and print "Request Completed"
    jobCompleted 
}


<# 
    Function: copyFile
    Params: $File - File object to be copied to a seperate location
    Returns: Void
    Description: Given a file, it copies it to the proper directory if it exists, otherwise it creates the directory
                 and the copies the file to it. Also calls getMeta $File for the file that is passed in
 #>
function copyFile($File){
    # Following 7 lines used in order to generate $Path
    $length = [System.IO.Path]::GetExtension($File).length;
    $Extension = [System.IO.Path]::GetExtension($File).substring(1,$length-1);
    if ($o.substring($o.length-1) -ne "\"){
        $Path = $o + "\" + $Extension;
    } else {
        $Path = $o + $Extension;
    }
    # Check if $Path exists
    # Create it if it doesnt, and then copy the file
    # Call getMeta for every file
    if(Test-Path -Path $Path){
        $FileCheck = $Path + "\" + [System.IO.Path]::GetFileName($File);
        if(Test-Path -Path $FileCheck){
            # Rename the File
            $Compare = [System.IO.Path]::GetFileNameWithoutExtension($File) + "*";
            $Count = [System.IO.Directory]::GetFiles("$Path", "$Compare").Count;
            $NewName = [System.IO.Path]::GetFileNameWithoutExtension($File) + $Count + [System.IO.Path]::GetExtension($File);
            $NewPath = $Path + "\" + $NewName;
            Copy-Item -Path $File.FullName -Destination $NewPath;
            getMeta $File $NewName;
        } else {
            Copy-Item -Path $File.FullName -Destination $Path;
            $Temp = [System.IO.Path]::GetFileName($File);
            getMeta $File $Temp; 
        }  
    } else {
        mkdir -Path $Path;
        Copy-Item -Path $File.FullName -Destination $Path;
        $Temp = [System.IO.Path]::GetFileName($File);
        getMeta $File $Temp;
    }
}


<#
    Function: printHelp
    Params: None
    Returns: Void
    Description: Prints out the help menu for the user to view
 #>
function printHelp(){
    asciiArt
    Write-Host ""
    Write-Host "Description:"
    Write-Host "    Stank is a powershell tool that allows for recursive file search based on the extension,"
    Write-Host "    as well as gather metadata about each of the files it finds. It conveniently then makes copies"
    Write-Host "    of these files and puts them in an ouptut location specified by the user that can be used for"
    Write-Host "    further inspection."
    Write-Host ""
    Write-Host "Options:"
    Write-Host "    -a                  Search for all file extensions (default)."
    Write-Host "    -e [extension]      Specify the file extension to be searched for."
    Write-Host "    -h                  Display the help menu."
    Write-Host "    -i [path]           Specify the file path for base iteration."
    Write-Host "    -o [path]           Specify the output path for resulting files."
    Write-Host ""
    Write-Host "Example Usage:"
    Write-Host "    .\stank.ps1 -h"
    Write-Host "    .\stank.ps1 -e pdf -i C:\Users\user\Desktop\Base -o C:\Users\user\Desktop"
    Write-Host "    .\stank.ps1 -i C:\Users\user\Desktop\Base -o C:\Users\user\Desktop"
    Write-Host ""
}


<#
    Function: asciiArt
    Params: None
    Returns: Void
    Description: Ascii Art to display the name of the program. This is only called/shown when the user views the help menu
#>
function asciiArt(){                    
    Write-Host "          _____                _____                      _____                      _____                      _____     ";     
    Write-Host "         /\    \              /\    \                    /\    \                    /\    \                    /\    \    ";     
    Write-Host "        /::\    \            /::\    \                  /::\    \                  /::\____\                  /::\____\   ";     
    Write-Host "       /::::\    \           \:::\    \                /::::\    \                /::::|   |                 /:::/    /        ";
    Write-Host "      /::::::\    \           \:::\    \              /::::::\    \              /:::::|   |                /:::/    /         ";
    Write-Host "     /:::/\:::\    \           \:::\    \            /:::/\:::\    \            /::::::|   |               /:::/    /          ";
    Write-Host "    /:::/__\:::\    \           \:::\    \          /:::/__\:::\    \          /:::/|::|   |              /:::/____/           ";
    Write-Host "    \:::\   \:::\    \          /::::\    \        /::::\   \:::\    \        /:::/ |::|   |             /::::\    \           ";
    Write-Host "  ___\:::\   \:::\    \        /::::::\    \      /::::::\   \:::\    \      /:::/  |::|   | _____      /::::::\____\________  ";
    Write-Host " /\   \:::\   \:::\    \      /:::/\:::\    \    /:::/\:::\   \:::\    \    /:::/   |::|   |/\    \    /:::/\:::::::::::\    \ ";
    Write-Host "/::\   \:::\   \:::\____\    /:::/  \:::\____\  /:::/  \:::\   \:::\____\  /:: /    |::|   /::\____\  /:::/  |:::::::::::\____\";
    Write-Host "\:::\   \:::\   \::/    /   /:::/    \::/    /  \::/    \:::\  /:::/    /  \::/    /|::|  /:::/    /  \::/   |::|~~~|~~~~~";
    Write-Host " \:::\   \:::\   \/____/   /:::/    / \/____/    \/____/ \:::\/:::/    /    \/____/ |::| /:::/    /    \/____|::|   |          ";
    Write-Host "  \:::\   \:::\    \      /:::/    /                      \::::::/    /             |::|/:::/    /           |::|   |          ";
    Write-Host "   \:::\   \:::\____\    /:::/    /                        \::::/    /              |::::::/    /            |::|   |          ";
    Write-Host "    \:::\  /:::/    /   /:::/    /                         /:::/    /               |:::::/    /             |::|   |          ";
    Write-Host "     \:::\/:::/    /   /:::/    /                         /:::/    /                |::::/    /              |::|   |          ";
    Write-Host "      \::::::/    /   /:::/    /                         /:::/    /                 /:::/    /               |::|   |          ";
    Write-Host "       \::::/    /   /:::/    /                         /:::/    /                 /:::/    /                \::|   |          ";
    Write-Host "        \::/    /    \::/    /                          \::/    /                  \::/    /                  \:|   |          ";
    Write-Host "         \/____/      \/____/                            \/____/                    \/____/                    \|___|          ";
}


<#
    Function: getMeta
    Params: File - File object to get metadata for
            NewName - The name to call the file in the metadata file
    Returns: Void
    Description: Creates a file for every extension, or appends to the file if it already exists, metadata
                 for the file that is passed in
#>
function getMeta($File, $NewName){
    # Following 7 lines used in order to generate $FilePath
    $length = [System.IO.Path]::GetExtension($File).length;
    $Extension = [System.IO.Path]::GetExtension($File).substring(1,$length-1);
    if ($o.substring($o.length-1) -ne "\"){
        $FilePath = $o + "\" + $Extension;
    } else {
        $FilePath = $o + $Extension;
    }
    # The rest of the lines write to the proper metadata file based on extension
    # different pieces of metadata information
    $Temp = [System.IO.Path]::GetExtension($File);
    $Fileout = $FilePath + "\" + $Temp.substring(1,$Temp.length-1) + "_meta.txt"
    $FileName = [System.IO.Path]::GetFileName($File);
    if([System.IO.Path]::GetFileName($File) -eq $NewName){
        $WriteFileName = "File Name: " + $FileName
    } else {
        $WriteFileName = "File Name: " + $NewName
    }
    $WriteFileName | Out-File $Fileout -Append
    $FullPath = $File.FullName
    $WriteFilePath = "Full Path: " + $FullPath
    $WriteFilePath | Out-File $Fileout -Append
    $CreationTime = $File.CreationTime.DateTime #[System.IO.File]::GetCreationTime($File)
    $WriteCreationTime = "File Creation Time: " + $CreationTime
    $WriteCreationTime | Out-File $Fileout -Append
    $LastWriteTime = $File.LastWriteTime.DateTime #[System.IO.File]::GetLastAccessTime($File)
    $WriteLastWriteTime = "Last Write Time: " + $LastWriteTime
    $WriteLastWriteTime | Out-File $Fileout -Append
    $FilePermissions = Get-Acl -path $File.FullName | Format-List -Property Owner,Group,AccessToString | Out-String
    $WriteFilePermissions = "File Permissions: " + $FilePermissions.TrimEnd()
    $WriteFilePermissions | Out-File $Fileout -Append 
    " " | Out-File $Fileout -Append
}


<#
    Function: jobCompleted
    Params: None
    Return: Void
    Description: Clears the screen and prints that the request was completed
 #>
function jobCompleted(){
    Clear-Host;
    Write-Host "Request Completed."
}


<#
    Function: main
    Params: None
    Return: Void
    Description: Begins the execution of the program by calling parameterCheck
 #>
function main(){
    paramaterCheck
}


# Call the main function
main