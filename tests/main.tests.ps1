Describe 'Bicep Parameter Tests' {
    It 'Should validate default parameters' {
        $parameters = @{
            environmentType = 'nonprod'
            postgresSQLServerName = 'valid-db-server'
            appServicePlanName = 'valid-plan'
        }
        $template = './main.bicep'
        $result = az bicep build --file $template
        $result | Should -Not -BeNullOrEmpty
    }

    It 'Should fail for invalid parameters' {
        $parameters = @{
            environmentType = 'invalid-env'
            postgresSQLServerName = 'short'
        }
        $template = './main.bicep'
        $result = az bicep build --file $template
        $result | Should -BeNullOrEmpty
    }
}
