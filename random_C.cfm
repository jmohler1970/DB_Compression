
<cfscript>
arEndpoints = ["stateprovince","users","login","login/captcha,wiki,settings,pages,pages/fragments"];
arVerbs = ["get","post","put","patch","delete"];

for (i = 1; i < 1000; i++)	{
	invoke("services.traffic", "add", { endpoint : arEndpoints[randRange(1, arEndPoints.len())], verb : arVerbs[randRange(1, arVerbs.len())] });
}
</cfscript>

<h2>Table Status</h2>

<cfquery name="qryStatus">
EXEC sp_estimate_data_compression_savings 'dbo', 'Traffic', NULL, NULL, 'NONE' ;  
</cfquery>

<cfdump var="#qryStatus#">


<h2>View Status</h2>

<cfquery name="qryStatus">
EXEC sp_estimate_data_compression_savings 'dbo', 'vwTraffic', NULL, NULL, 'NONE' ;  
</cfquery>


<cfdump var="#qryStatus#">
