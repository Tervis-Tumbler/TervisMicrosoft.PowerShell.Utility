function Test2 {
    [CmdletBinding()]
    param (
        $Thing
    )
    DynamicParam {
        New-DynamicParameter -Name Thing2
    }
    
    process {
        New-DynamicParameter -CreateVariables -BoundParameters $PSBoundParameters
        $PSBoundParameters
        $Thing
        $thing2
    }
}
test2 -Thing k -thing2 th