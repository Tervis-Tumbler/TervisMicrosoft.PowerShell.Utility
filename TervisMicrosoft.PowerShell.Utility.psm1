function ConvertFrom-StringUsingRegexCaptureGroup {
    param (        
        [Parameter(Mandatory,ParameterSetName="Regex")][Regex]$Regex,
        [Parameter(Mandatory,ParameterSetName="TemplateFile")]$TemplateFile,
        [Parameter(Mandatory,ValueFromPipeline)]$Content
    )
    begin {
        if($TemplateFile) {
            [Regex]$Regex = Get-Content -Path $TemplateFile | Out-String
        }
    }
    process {
        $Match = $Regex.Match($Content)
        $Object = [pscustomobject]@{} 
        
        foreach ($GroupName in $Regex.GetGroupNames() | select -Skip 1) {
            $Object | 
            Add-Member -MemberType NoteProperty -Name $GroupName -Value $Match.Groups[$GroupName].Value 
        }
        $Object
    }
}

function Compare-ObjectAllProperties {
    param (
        [Parameter(Mandatory)]$ReferenceObject,
        [Parameter(Mandatory)]$DifferenceObject,
        [Switch]$IncludeEqual
    )
    
    $ReferenceObjectPropertyNames = $ReferenceObject |
    Get-PropertyName

    $ReferenceObjectPropertyNames = $DifferenceObject |
    Get-PropertyName

    $Properties = ($ReferenceObjectPropertyNames + $DifferenceObject) |
    Sort-Object -Unique

    Compare-Object -ReferenceObject $ReferenceObject -DifferenceObject $DifferenceObject -Property $Properties -IncludeEqual:$IncludeEqual
}

function ConvertTo-HashTable {
    #Inspired by http://stackoverflow.com/questions/3740128/pscustomobject-to-hashtable
    param(
        [Parameter(ValueFromPipeline)]$Object
    )
    $HashTable = @{}
    $Object.psobject.properties | Foreach { $HashTable[$_.Name] = $_.Value }
    $HashTable
}

function ConvertTo-Variable {
    param (
        [Parameter(ValueFromPipeline)][HashTable]$HashTableToConvert
    )
    foreach ($Key in $HashTableToConvert.Keys) {
        New-Variable -Name $Key -Value $HashTableToConvert[$Key] -Force -Scope 1
    }
}

function Get-Hash {
    param (
        [Parameter(Mandatory,ValueFromPipeline)]$String,
        [ValidateSet("MD5","SHA1","SHA256","SHA384","SHA512")]
        [Parameter(Mandatory)]
        $HashFunction
    )
    begin {
        $HashCryptoServiceProvider = new-object -TypeName System.Security.Cryptography.$($HashFunction)CryptoServiceProvider
        $UTF8 = new-object -TypeName System.Text.UTF8Encoding
    }
    process {  
        [System.BitConverter]::ToString(
            $HashCryptoServiceProvider.ComputeHash(
                $UTF8.GetBytes($String)
            )
        ).replace("-","")
    }
}

function ConvertTo-PSCustomObjectStanza {
    param (
        [Parameter(Mandatory,ValueFromPipeline)]$Object
    )
    begin {
        $Array = @()
    }
    process {
        $OFSBeforeFunctionCall = $OFS
        $OFS = ""
        $PropertyNames = $Object | Get-PropertyName
        
        $Array += @"
[PSCustomObject][Ordered]@{
$(
    foreach ($Property in $PropertyNames) {
        $Value = $($Object.$Property)
        if ($Value) {
            "    $Property = $(if ($Value -is [String]) {'"' + $Value + '"'} else {$Value})`r`n"
        }
    }
)}
"@
    $OFS = $OFSBeforeFunctionCall
    }
    end {
        $Array -join ",`r`n"
    }
}