-- Approach A
USE [Compression_Demo]
GO

/****** Object:  Table [dbo].[Traffic]    Script Date: 12/18/18 9:16:12 PM ******/
CREATE TABLE [dbo].[Traffic_C](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Endpoint] [varchar](50) NOT NULL,
	[Verb] [varchar](10) NOT NULL,
	[IP_checksum] int NOT NULL,
	[User_Agent] [varchar](255) NOT NULL,
	[CreateDate] [smalldatetime] NOT NULL,
 CONSTRAINT [PK_Traffic] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

ALTER TABLE [dbo].[Traffic_C] ADD  CONSTRAINT [DF_Traffic_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO

ALTER TABLE dbo.Traffic_C REBUILD PARTITION = ALL  
WITH (DATA_COMPRESSION = PAGE);
GO


CREATE VIEW [dbo].[vwTraffic_C] WITH SCHEMABINDING
AS

SELECT Endpoint, Verb, IP, CONVERT(date, CreateDate) AS CreateDate, COUNT_BIG(*) AS ID_Count
FROM dbo.Traffic
GROUP BY Endpoint, Verb, IP, CONVERT(date, CreateDate) 
GO



/****** Object:  Index [IX_view]    Script Date: 12/18/18 9:14:24 PM ******/
CREATE UNIQUE CLUSTERED INDEX [IX_view] ON [dbo].[vwTraffic_C]
(
	[Endpoint] ASC,
	[Verb] ASC,
	[IP] ASC,
	[CreateDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

ALTER INDEX IX_view ON dbo.vwTraffic_C REBUILD PARTITION = ALL  
WITH (DATA_COMPRESSION = PAGE);
GO