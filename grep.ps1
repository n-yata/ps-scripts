# 引数のチェック
if ($args.Count -lt 2) {
    Write-Host "Usage: script.ps1 <累計の集計ファイルパス> <1カ月分の集計ファイルパス>"
    exit 1
}

# 引数からファイルのパスを取得
$accumulatedFile = $args[0] # 累計の集計ファイル
$monthlyFile = $args[1] # 1カ月分の集計ファイル
$dateSuffix = Get-Date -Format "yyyyMMddHHmmss" # 現在日付

# CSVファイルを読み込み、データを配列として取得
$accumulatedData = Import-Csv -Path $accumulatedFile
$monthlyData = Import-Csv -Path $monthlyFile

# 前回累計のバックアップ
$backupData = $accumulatedData
$backupFilePath = "bk/combined-$dateSuffix.csv"
$backupData | Export-Csv -Path $backupFilePath -NoTypeInformation -Encoding UTF8

# 1カ月分の集計ファイル（累計に含まれる値を除く）
$accumulatedIDs = $accumulatedData | Select-Object -ExpandProperty ID
$monthlyUniqueData = @()
foreach ($row in $monthlyData) {
    if ($accumulatedIDs -notcontains $row.ID) {
        $monthlyUniqueData += $row
    }
}
$monthlyUniqueFilePath = "monthly_unique-$dateSuffix.csv"
$monthlyUniqueData | Export-Csv -Path $monthlyUniqueFilePath -NoTypeInformation -Encoding UTF8

# 累計 + 1カ月分の集計ファイル（重複した値は除く）
$combinedData = $accumulatedData + $monthlyUniqueData
$combinedFilePath = "combined.csv"
$combinedData | Export-Csv -Path $combinedFilePath -NoTypeInformation -Encoding UTF8

Write-Host "処理が完了しました。以下のファイルが作成されました:"
Write-Host "累計 + 1カ月分の集計: $combinedFilePath"
Write-Host "1カ月分の集計（累計に含まれないもの）: $monthlyUniqueFilePath"
