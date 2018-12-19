-- Approach A
USE [Compression_Demo]
GO

/****** Object:  Table [dbo].[Traffic]    Script Date: 12/18/18 9:16:12 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Traffic](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Endpoint] [varchar](50) NOT NULL,
	[Verb] [varchar](10) NOT NULL,
	[IP] [varchar](15) NOT NULL,
	[User_Agent] [varchar](max) NOT NULL,
	[CreateDate] [smalldatetime] NOT NULL,
 CONSTRAINT [PK_Traffic] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

ALTER TABLE [dbo].[Traffic] ADD  CONSTRAINT [DF_Traffic_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO

CREATE VIEW [dbo].[vwTraffic]
AS

SELECT Endpoint, Verb, IP, CONVERT(date, CreateDate) AS CreateDate, COUNT(*) AS ID_Count
FROM dbo.Traffic
GROUP BY Endpoint, Verb, IP, CONVERT(date, CreateDate) 
GO


