CREATE DATABASE Traffic_B
GO

USE Traffic_B
GO

/****** Object:  Table [dbo].[Endpoint_Enhanced]    Script Date: 12/18/18 9:19:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Endpoint_Enhanced](
	[ID] [tinyint] IDENTITY(1,1) NOT NULL,
	[Endpoint] [varchar](50) NOT NULL,
 CONSTRAINT [PK_Endpoint_Enhanced] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Verb_Enhanced]    Script Date: 12/18/18 9:19:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Verb_Enhanced](
	[ID] [tinyint] NOT NULL,
	[Verb] [varchar](50) NOT NULL,
 CONSTRAINT [PK_Verb_Enhanced] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[User_Agent_Enhanced]    Script Date: 12/18/18 9:19:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[User_Agent_Enhanced](
	[ID] [int] NOT NULL,
	[User_Agent] [varchar](max) NOT NULL,
 CONSTRAINT [PK_User_Agent_Enhanced] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[IP_Enhanced]    Script Date: 12/18/18 9:19:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[IP_Enhanced](
	[ID] [int] NOT NULL,
	[IP] [varchar](15) NOT NULL,
 CONSTRAINT [PK_IP_Enhanced] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Traffic_Enhanced]    Script Date: 12/18/18 9:19:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Traffic_Enhanced](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Endpoint_ID] [tinyint] NOT NULL,
	[Verb_ID] [tinyint] NOT NULL,
	[IP_ID] [int] NOT NULL,
	[User_Agent_ID] [bigint] NOT NULL,
	[CreateDate] [smalldatetime] NOT NULL,
 CONSTRAINT [PK_Traffic_Enhanced] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  View [dbo].[vwTraffic_Enhanced]    Script Date: 12/18/18 9:19:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vwTraffic_Enhanced]
AS
SELECT        dbo.Traffic_Enhanced.ID, dbo.Endpoint_Enhanced.Endpoint, dbo.Verb_Enhanced.Verb, dbo.IP_Enhanced.IP, dbo.User_Agent_Enhanced.User_Agent, dbo.Traffic_Enhanced.CreateDate
FROM            dbo.Endpoint_Enhanced INNER JOIN
                         dbo.Traffic_Enhanced ON dbo.Endpoint_Enhanced.ID = dbo.Traffic_Enhanced.Endpoint_ID INNER JOIN
                         dbo.Verb_Enhanced ON dbo.Traffic_Enhanced.Verb_ID = dbo.Verb_Enhanced.ID INNER JOIN
                         dbo.IP_Enhanced ON dbo.Traffic_Enhanced.IP_ID = dbo.IP_Enhanced.ID INNER JOIN
                         dbo.User_Agent_Enhanced ON dbo.Traffic_Enhanced.User_Agent_ID = dbo.User_Agent_Enhanced.ID

GO
ALTER TABLE [dbo].[Traffic_Enhanced]  WITH CHECK ADD  CONSTRAINT [FK_Traffic_Enhanced_Endpoint_Enhanced] FOREIGN KEY([Endpoint_ID])
REFERENCES [dbo].[Endpoint_Enhanced] ([ID])
GO
ALTER TABLE [dbo].[Traffic_Enhanced] CHECK CONSTRAINT [FK_Traffic_Enhanced_Endpoint_Enhanced]
GO
ALTER TABLE [dbo].[Traffic_Enhanced]  WITH CHECK ADD  CONSTRAINT [FK_Traffic_Enhanced_IP_Enhanced] FOREIGN KEY([IP_ID])
REFERENCES [dbo].[IP_Enhanced] ([ID])
GO
ALTER TABLE [dbo].[Traffic_Enhanced] CHECK CONSTRAINT [FK_Traffic_Enhanced_IP_Enhanced]
GO
ALTER TABLE [dbo].[Traffic_Enhanced]  WITH CHECK ADD  CONSTRAINT [FK_Traffic_Enhanced_Verb_Enhanced] FOREIGN KEY([Verb_ID])
REFERENCES [dbo].[Verb_Enhanced] ([ID])
GO
ALTER TABLE [dbo].[Traffic_Enhanced] CHECK CONSTRAINT [FK_Traffic_Enhanced_Verb_Enhanced]
GO
ALTER TABLE [dbo].[Traffic_Enhanced]  WITH CHECK ADD  CONSTRAINT [FK_Traffic_Enhanced_User_Agent_Enhanced] FOREIGN KEY([User_Agent_ID])
REFERENCES [dbo].[User_Agent_Enhanced] ([ID])
GO
ALTER TABLE [dbo].[Traffic_Enhanced] CHECK CONSTRAINT [FK_Traffic_Enhanced_User_Agent_Enhanced]
GO
