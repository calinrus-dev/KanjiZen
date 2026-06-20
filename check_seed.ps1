$bytes = [System.IO.File]::ReadAllBytes("$PSScriptRoot\apps\kanjizen_app\assets\data\kanji_seed.json")
$text = [System.Text.Encoding]::UTF8.GetString($bytes)

# Check if any entry has 'radical', 'jlpt', 'joyo', 'isJinmeiyo', 'kanjidicTranslations'
$hasRadical = $text.Contains('"radical":')
$hasJlpt = $text.Contains('"jlpt":')
$hasJoyo = $text.Contains('"joyo":')
$hasJinmeiyo = $text.Contains('"isJinmeiyo":')
$hasKanjidic = $text.Contains('"kanjidicTranslations":')

Write-Host "Has 'radical': $hasRadical"
Write-Host "Has 'jlpt': $hasJlpt"
Write-Host "Has 'joyo': $hasJoyo"
Write-Host "Has 'isJinmeiyo': $hasJinmeiyo"
Write-Host "Has 'kanjidicTranslations': $hasKanjidic"
