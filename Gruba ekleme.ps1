$OU_Dizini = Read-Host -Prompt 'OU içeriğini yazınız Örnek: "OU=TestUsers,DC=zeynelugurlu,DC=com"'
$CSV_Dizini = Read-Host -Prompt 'CSV Export etmek istediğiniz dizini seçiniz. Örnek:C:\Users\zeynel.ugurlu\Desktop'
$GrupAdı = Read-Host -Prompt 'Eklemek istediğiniz grup adını olduğu gibi yazınız.'
 
 
 Get-ADUser -Filter * -SearchBase $OU_Dizini -Properties * | Select-Object UserPrincipalName | export-csv -path $CSV_Dizini\AddGroup.csv

# Import AD Module
Import-Module ActiveDirectory

# CSV formatındaki veriyi içeri al.
$Users = Import-Csv $CSV_Dizini\AddGroup.csv

# Kullanıcıların ekleneceği grubu ekleyin.
$Group = $GrupAdı

foreach ($User in $Users) {
    # UPN değerini al
    $UPN = $User.UserPrincipalName

    # UPN değeri ile SamAccountName'i eşle.
    $ADUser = Get-ADUser -Filter "UserPrincipalName -eq '$UPN'"

    # Kullanıcı bulunamadıysa
    if (-not $ADUser) {
        Write-Host "$UPN does not exist in AD" -ForegroundColor Red
    }
    else {
        # Kullanıcının üyeliğini geri al
        $ExistingGroups = Get-ADPrincipalGroupMembership $ADUser.SamAccountName

        # Kullanıcı gruba halihazırda üyeyse
        if ($ExistingGroups.Name -contains $Group) {
            Write-Host "$UPN already exists in $Group" -ForeGroundColor Yellow
        }
        else {
            # Kullanıcıyı gruba alalım.
            Add-ADGroupMember -Identity $Group -Members $ADUser.SamAccountName
            Write-Host "Added $UPN to $Group" -ForeGroundColor Green
        }
    }
    } 