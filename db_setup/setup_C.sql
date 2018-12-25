-- Approach C
CREATE DATABASE Traffic_C
GO

USE Traffic_C
GO

CREATE TABLE [dbo].[Traffic](
	[CreateDate] [smalldatetime] NOT NULL CONSTRAINT [DF_Traffic_C_CreateDate] DEFAULT GETDATE(),
	[EndPoint] [varchar](50) NOT NULL,
	[Verb] [varchar](10) NOT NULL,
	[IP_checksum] [int] NOT NULL,
	[User_Agent] [varchar](255) NOT NULL
) ON [PRIMARY]
WITH (DATA_COMPRESSION = PAGE)

GO


-----------------------------------------

CREATE VIEW [dbo].[vwTraffic] WITH SCHEMABINDING
AS

SELECT Endpoint, Verb, IP_checksum, CONVERT(date, CreateDate) AS CreateDate, COUNT_BIG(*) AS ID_Count
FROM dbo.Traffic
GROUP BY Endpoint, Verb, IP_checksum, CONVERT(date, CreateDate) 
GO



/****** Object:  Index [IX_view]    Script Date: 12/18/18 9:14:24 PM ******/
CREATE UNIQUE CLUSTERED INDEX [IX_view] ON [dbo].[vwTraffic]
(
	[CreateDate] ASC,
	[Endpoint] ASC,
	[Verb] ASC,
	[IP_checksum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

ALTER INDEX IX_view ON dbo.vwTraffic REBUILD PARTITION = ALL  
WITH (DATA_COMPRESSION = PAGE);
GO

-- Some access

USE [master]
GO
CREATE LOGIN [Traffic_user] WITH PASSWORD='Traffic_user', DEFAULT_DATABASE=[Traffic_C], CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF
GO
USE [Traffic_C]
GO
CREATE USER [Traffic_user] FOR LOGIN [Traffic_user]
GO
ALTER ROLE [db_datareader] ADD MEMBER [Traffic_user]
GO
ALTER ROLE [db_datawriter] ADD MEMBER [Traffic_user]
GO
ALTER ROLE [db_owner] ADD MEMBER [Traffic_user]
GO


