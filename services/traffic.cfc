component output="false" {

void function add(required string endpoint, required string verb) output="false"	{

	queryExecute("
		INSERT
		INTO dbo.Traffic(EndPoint, Verb, IP_checksum, User_Agent)
		VALUES (?, ?, CHECKSUM(?), LEFT(?, 255))
		",
		[arguments.endpoint, arguments.verb, cgi.remote_addr, cgi.http_user_agent]
		);
}


} // end component