function ConvertFrom-StringUsingRegexCaptureGroup {
    param (        
        [Parameter(Mandatory,ParameterSetName="Regex")][Regex]$Regex,
        [Parameter(Mandatory,ParameterSetName="TemplateFile")][Regex]$TemplateFile,
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
    Get-PropertyNames

    $ReferenceObjectPropertyNames = $DifferenceObject |
    Get-PropertyNames

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
