param endIpAddress string = "0.0.0.0"
param startIpAddress string = "0.0.0.0"
param ruleName string
parameter parentResourceID string

resource postgresSQLServerFirewallRules 'firewallRules@2022-12-01' = {
  name: ruleName
  parent: parentResourceID
  properties: {
    endIpAddress: endIpAddress
    startIpAddress: startIpAddress
  }
}

output firewallRuleId string = postgresSQLServerFirewallRules.id
