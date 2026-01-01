# Move multiline comments (FB description/changelog) to the top of Declaration section in TcPOU files
$POUsPath = "TcOscatBasic/TcOscatBasic/POUs"
$files = Get-ChildItem -Path $POUsPath -Recurse -Filter *.TcPOU

foreach ($file in $files) {
    $content = Get-Content $file.FullName -Raw

    # Find the first multiline comment block (FB description/changelog)
    $fbCommentMatch = [regex]::Match($content, '(?s)\(\*.*?\*\)')
    if (-not $fbCommentMatch.Success) {
        Write-Host "No FB comment found in $($file.FullName)"
        # Backup original file
        Copy-Item $file.FullName "$($file.FullName).bak"

        # Convert to UTF-8 (read with original encoding, write as UTF-8)
        $tempFile = "$($file.FullName).tmp"
        Get-Content $file.FullName -Raw -Encoding Default | Set-Content $tempFile -Encoding UTF8
        Move-Item -Force $tempFile $file.FullName
    } else 
    {
        $fbComment = $fbCommentMatch.Value.Trim()

        # Remove all instances of this comment from the file
        $contentNoComment = $content -replace [regex]::Escape($fbComment), ''

        # Move to top of Declaration
        $contentNoComment = $contentNoComment -replace '(<Declaration><!\[CDATA\[)', "`$1$fbComment`r`n"

        # Backup original file
        Copy-Item $file.FullName "$($file.FullName).bak"

        # Convert to UTF-8 (read with original encoding, write as UTF-8)
        $tempFile = "$($file.FullName).tmp"
        Get-Content $file.FullName -Raw -Encoding Default | Set-Content $tempFile -Encoding UTF8
        Move-Item -Force $tempFile $file.FullName
        # Write modified content
        [System.IO.File]::WriteAllText($file.FullName, $contentNoComment, [System.Text.Encoding]::UTF8)

        Write-Host "Processed $($file.FullName)"
    }
}