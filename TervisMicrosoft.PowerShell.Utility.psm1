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