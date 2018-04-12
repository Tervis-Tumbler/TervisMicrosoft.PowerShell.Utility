Import-Module -Force TervisMicrosoft.PowerShell.Utility

Describe "Module" {
    it "Remove-PSObjectEmptyOrNullProperty" {
        $Object = [PSCustomObject]@{
            Thing = "thing"
            EmptyThing = ""
            NullThing = $null
            FalseThing = $false
        }
        $Object | Remove-PSObjectEmptyOrNullProperty
        $Object.Thing | should -Be "thing"
        $Object.EmptyThing | Should -BeNullOrEmpty
        $Object.NullThing | Should -BeNullOrEmpty
        $Object.FalseThing | should -Be $false
    }
}