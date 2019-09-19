Add-Type -TypeDefinition @"
    public enum Tactics
    {
        InitialAccess,
        Persistence,
        Execution,
        PrivilegeEscalation,
        DefenseEvasion,
        CredentialAccess,
        LateralMovement,
        Discovery,
        Collection,
        Exfiltration,
        CommandAndControl,
        Impact
    }
"@
