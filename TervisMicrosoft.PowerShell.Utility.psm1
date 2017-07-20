function ConvertFrom-StringUsingRegexCaptureGroup {
    param (
        [Regex]$Regex,
        [Parameter(ValueFromPipeline)]$Content
    )
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