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
    It "Split-HashTable" {
        $HashTable = [Ordered]@{
            Thing = "Value"
            Thing2 = "Value2"
        }
        $ArrayOfHashTables = $HashTable | Split-HashTable
        $ArrayOfHashTables.count | Should -Be 2
        $ArrayOfHashTables[0].Keys | Should -Be "Thing"
        $ArrayOfHashTables[1].Keys | Should -Be "Thing2"
    }
}