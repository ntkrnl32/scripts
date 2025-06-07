Add-Type -AssemblyName System.Windows.Forms

# Create the main form
$Form = New-Object System.Windows.Forms.Form
$Form.Text = "File Padding Tool"
$Form.Size = New-Object System.Drawing.Size(400,300)
$Form.StartPosition = "CenterScreen"

# Language selection dropdown
$LangLabel = New-Object System.Windows.Forms.Label
$LangLabel.Text = "Language:"
$LangLabel.Location = New-Object System.Drawing.Point(10,10)
$LangLabel.Size = New-Object System.Drawing.Size(80,20)
$Form.Controls.Add($LangLabel)

$LangComboBox = New-Object System.Windows.Forms.ComboBox
$LangComboBox.Location = New-Object System.Drawing.Point(100,10)
$LangComboBox.Size = New-Object System.Drawing.Size(100,20)
$LangComboBox.Items.Add("English")
$LangComboBox.Items.Add("中文")
$LangComboBox.SelectedIndex = 0
$Form.Controls.Add($LangComboBox)

# Labels and buttons
$FileLabel = New-Object System.Windows.Forms.Label
$FileTextBox = New-Object System.Windows.Forms.TextBox
$FileButton = New-Object System.Windows.Forms.Button
$SizeLabel = New-Object System.Windows.Forms.Label
$SizeTextBox = New-Object System.Windows.Forms.TextBox
$UnitLabel = New-Object System.Windows.Forms.Label
$UnitComboBox = New-Object System.Windows.Forms.ComboBox
$ExecuteButton = New-Object System.Windows.Forms.Button

# Function to update text based on selected language
function UpdateLanguage {
    $lang = $LangComboBox.SelectedItem
    if ($lang -eq "English") {
        $FileLabel.Text = "Select File:"
        $FileButton.Text = "Browse"
        $SizeLabel.Text = "Size:"
        $UnitLabel.Text = "Unit:"
        $ExecuteButton.Text = "Add Empty Bytes"
    } else {
        $FileLabel.Text = "选择文件:"
        $FileButton.Text = "浏览"
        $SizeLabel.Text = "大小:"
        $UnitLabel.Text = "单位:"
        $ExecuteButton.Text = "添加空字节"
    }
}

$LangComboBox.Add_SelectedIndexChanged({ UpdateLanguage })

# File selection section
$FileLabel.Location = New-Object System.Drawing.Point(10,50)
$FileLabel.Size = New-Object System.Drawing.Size(80,20)
$Form.Controls.Add($FileLabel)

$FileTextBox.Location = New-Object System.Drawing.Point(100,50)
$FileTextBox.Size = New-Object System.Drawing.Size(200,20)
$Form.Controls.Add($FileTextBox)

$FileButton.Location = New-Object System.Drawing.Point(310,50)
$FileButton.Add_Click({
    $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    if ($OpenFileDialog.ShowDialog() -eq "OK") {
        $FileTextBox.Text = $OpenFileDialog.FileName
    }
})
$Form.Controls.Add($FileButton)

# Size input section
$SizeLabel.Location = New-Object System.Drawing.Point(10,90)
$SizeLabel.Size = New-Object System.Drawing.Size(80,20)
$Form.Controls.Add($SizeLabel)

$SizeTextBox.Location = New-Object System.Drawing.Point(100,90)
$SizeTextBox.Size = New-Object System.Drawing.Size(100,20)
$Form.Controls.Add($SizeTextBox)

# Unit selection
$UnitLabel.Location = New-Object System.Drawing.Point(10,130)
$UnitLabel.Size = New-Object System.Drawing.Size(80,20)
$Form.Controls.Add($UnitLabel)

$UnitComboBox.Location = New-Object System.Drawing.Point(100,130)
$UnitComboBox.Size = New-Object System.Drawing.Size(100,20)
$UnitComboBox.Items.Add("Byte")
$UnitComboBox.Items.Add("KB")
$UnitComboBox.Items.Add("MB")
$UnitComboBox.SelectedIndex = 0
$Form.Controls.Add($UnitComboBox)

# Execute button
$ExecuteButton.Location = New-Object System.Drawing.Point(100,170)
$ExecuteButton.Add_Click({
    $filePath = $FileTextBox.Text
    $size = $SizeTextBox.Text
    $unit = $UnitComboBox.SelectedItem
    $lang = $LangComboBox.SelectedItem

    if (-not (Test-Path $filePath)) {
        $errorMessage = if ($lang -eq "English") {"Invalid file path!"} else {"文件路径无效!"}
        [System.Windows.Forms.MessageBox]::Show($errorMessage, "Error")
        return
    }

    if ($size -match "^\d+$") {
        $size = [int]$size
    } else {
        $errorMessage = if ($lang -eq "English") {"Please enter a valid numeric size!"} else {"请输入有效的数字大小!"}
        [System.Windows.Forms.MessageBox]::Show($errorMessage, "Error")
        return
    }

    if ($unit -eq "KB") { $size *= 1024 }
    elseif ($unit -eq "MB") { $size *= 1024 * 1024 }

    $binWriter = New-Object System.IO.BinaryWriter([System.IO.File]::Open($filePath, "Append"))
    $binWriter.Write((New-Object byte[]($size)))
    $binWriter.Close()

    $successMessage = if ($lang -eq "English") {"Successfully added $size bytes!"} else {"已成功添加 $size 字节!"}
    [System.Windows.Forms.MessageBox]::Show($successMessage, "Completed")
})
$Form.Controls.Add($ExecuteButton)

# Update language on startup
UpdateLanguage

# Show the form
$Form.ShowDialog()
