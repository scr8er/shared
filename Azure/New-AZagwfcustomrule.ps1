$param1 = @{
    'variablename'="RequestMethod" }


$param2 = @{
    'VariableName'="RequestHeaders";
    'Selector'="User'Agent"}


$param3 = @{
        'MatchVariable'="$variable1";
        'Operator'="IPMatch";
        'MatchValue'="192.168.5.4/24";
        'NegationCondition'="$False"}

$param4 = @{
        'MatchVariable'="$variable2";
        'Operator'="Contains";
        'MatchValue'="evilbot";
        'Transform'="Lowercase";
        'NegationCondition'="$False"}


$param5 = @{
        'Name'="myrule";
        'Priority'="100";
        'RuleType'="MatchRule";
        'MatchCondition'="$condition1, $condition2";
        'Action'="Block"}

$variable1 = New-AzApplicationGatewayFirewallMatchVariable $param1
$variable2 = New-AzApplicationGatewayFirewallMatchVariable $param2
$condition1 = New-AzApplicationGatewayFirewallCondition $param3
$condition2 = New-AzApplicationGatewayFirewallCondition $param4
$rule = New-AzApplicationGatewayFirewallCustomRule $param5