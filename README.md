# PoSh-StatusPageIO:
PowerShell cmdlets for querying a status page running on statuspage.io.
Currently only supports reading data, but will be updated to allow you to POST changes to your own Status Page in the future.

### Cmdlets:

  - `Get-StatusPage` returns a summary off the status page
  - `Get-StatusPageIncident` returns a list of all the urnesolved inceidents. Providing the `-All` switch instead returns all incidents (resolved and unresolved).

### Examples:

Get the summary of Kickstarter's Status Page via URL:
```
Get-StatusPage -Url status.kickstarter.com
```

Get the summary of Kickstarter's Status Page using it's ID/Page Code:
```
Get-StatusPage -Id 4p1vb67yqzdy
```

Get any unresolved incidents from Kickstarter's Status Page:
```
Get-StatusPageIncident -Url status.kickstarter.com
```

Get _all_ resolved and unresolved incidents from Kickstarter's Status Page:
```
Get-StatusPageIncident -Url status.kickstarter.com -All
```

### FAQ:

##### Q: Can't I just do this myself with Invoke-WebRequest:
**A:** Yep! This is just a bit cleaner.