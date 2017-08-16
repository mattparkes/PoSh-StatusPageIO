Function Invoke-StatusPageRequest {
    [CmdletBinding(DefaultParameterSetName="Url")]
    Param(
        [Parameter(Mandatory=$True, ParameterSetName='Id')][String]$Id,
        [Parameter(Mandatory=$True, ParameterSetName='Url')][String]$Url,
        [Parameter(Mandatory=$False)][Int]$APIVersion = 2,
        [Parameter(Mandatory=$False)][String]$Endpoint = "summary.json"
    )

    # Build the BaseURL for the API Requests, either from the ID or from the URL Supplied
    [String]$BaseUrl = ""
    If ($PSCmdlet.ParameterSetName -Eq "Id") {
        $BaseUrl = "$Id.statuspage.io"
    }
    ElseIf ($PSCmdlet.ParameterSetName -Eq "Url") {
        $BaseUrl = $Url
        $BaseUrl = $BaseUrl.TrimEnd("/")
    }

    $Output = [Ordered]@{}
    $StatusPageWebRequest = @{}

    $StatusPageWebRequest = Invoke-WebRequest -DisableKeepAlive -UseBasicParsing -TimeoutSec 30 -Uri "$BaseUrl/api/v$APIVersion/$Endpoint"

    Return $StatusPageWebRequest
}

Function Get-StatusPage{
    [CmdletBinding(DefaultParameterSetName="Url")]
    Param(
        [Parameter(Mandatory=$True, ParameterSetName='Id', ValueFromPipeline=$True)][String]$Id,
        [Parameter(Mandatory=$True, ParameterSetName='Url',   ValueFromPipeline=$True)][String]$Url
    )

    $StatusPageWebRequest = Invoke-StatusPageRequest @PSBoundParameters -Endpoint "summary.json"

    If ($StatusPageWebRequest.StatusCode -Eq 200) {
        $StatusPage = ($StatusPageWebRequest.Content | ConvertFrom-Json)

        # Clean up the output. This is unnecessary, but if we use CamelCase keys and set some Types, it feels more PowerShell-esque.
        $Output = [ordered]@{
            "Id" = [String]($StatusPage.page.id);
            "Name" = [String]($StatusPage.page.name);
            "Url" = [String]($StatusPage.page.url);
            "Updated" = [DateTime]($StatusPage.page.updated_at);
            "StatusDescription" = [String]($StatusPage.status.description);
            "StatusIndicator" = [String]($StatusPage.status.indicator);
            "Components" = [Array]@();
        };
        $StatusPage.components | ForEach-Object {
            $Output.Components += [ordered]@{
                "Id" = [String]($_.id)
                "Name" = [String]($_.name)
                "Description" = [String]($_.description)
                "Status" = [String]($_.status)
                "CreatedAt" = [DateTime]($_.created_at)
                "UpdatedAt" = [DateTime]($_.updated_at)
                "Position" = [Int]($_.position)
                "Showcase" = [Boolean]($_.showcase)
                "GroupId" = [String]($_.group_id)
                "PageId" = [String]($_.page_id)
                "Group" = [String]($_.group)
                "OnlyShowIfDegraded" = [Boolean]($_.only_show_if_degraded)
            }
        }

        Return $Output
    }
}

Function Get-StatusPageIncident{
    [CmdletBinding(DefaultParameterSetName="Url")]
    Param(
        #TODO: Change ID to StatusPageId and URL to StatusPageURL
        [Parameter(Mandatory=$True, ParameterSetName='Id', ValueFromPipeline=$True)][String]$Id,
        [Parameter(Mandatory=$True, ParameterSetName='Url',   ValueFromPipeline=$True)][String]$Url,
        [Parameter(Mandatory=$False, ValueFromPipeline=$True)][Switch]$All
        #TODO: Add IncidentID (or just ID)
        #TODO: ParameterSet/Alias allowing you to feed in a StatusPage object
        
    )

    $StatusPageWebRequest = @{}
    If ($All) {
        $BoundParameters = $PSBoundParameters
        $BoundParameters.Remove('All')
        $StatusPageWebRequest = Invoke-StatusPageRequest @BoundParameters -Endpoint "/incidents.json"    
    }
    Else {
        $StatusPageWebRequest = Invoke-StatusPageRequest @PSBoundParameters -Endpoint "/incidents/unresolved.json"    
    }
    
    If ($StatusPageWebRequest.StatusCode -Eq 200) {
        $Incidents = ($StatusPageWebRequest.Content | ConvertFrom-Json)
        
        Return $Incidents.incidents
    }
}

Export-ModuleMember *-*