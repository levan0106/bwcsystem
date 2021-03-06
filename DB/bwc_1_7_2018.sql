USE [master]
GO
/****** Object:  Database [BWC]    Script Date: 7/1/2018 1:04:25 AM ******/
CREATE DATABASE [BWC] ON  PRIMARY 
( NAME = N'BWC', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL10_50.EN2008R2\MSSQL\DATA\BWC.mdf' , SIZE = 5120KB , MAXSIZE = UNLIMITED, FILEGROWTH = 1024KB )
 LOG ON 
( NAME = N'BWC_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL10_50.EN2008R2\MSSQL\DATA\BWC_log.ldf' , SIZE = 10176KB , MAXSIZE = 2048GB , FILEGROWTH = 10%)
GO
ALTER DATABASE [BWC] SET COMPATIBILITY_LEVEL = 100
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [BWC].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [BWC] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [BWC] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [BWC] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [BWC] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [BWC] SET ARITHABORT OFF 
GO
ALTER DATABASE [BWC] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [BWC] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [BWC] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [BWC] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [BWC] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [BWC] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [BWC] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [BWC] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [BWC] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [BWC] SET  DISABLE_BROKER 
GO
ALTER DATABASE [BWC] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [BWC] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [BWC] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [BWC] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [BWC] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [BWC] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [BWC] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [BWC] SET RECOVERY FULL 
GO
ALTER DATABASE [BWC] SET  MULTI_USER 
GO
ALTER DATABASE [BWC] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [BWC] SET DB_CHAINING OFF 
GO
EXEC sys.sp_db_vardecimal_storage_format N'BWC', N'ON'
GO
USE [BWC]
GO
/****** Object:  UserDefinedFunction [dbo].[fn_AuthenticateUser]    Script Date: 7/1/2018 1:04:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		TungLe
-- Create date: 13/1/2016
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[fn_AuthenticateUser] 
(
	@UserName VARCHAR(200)
	,@Password VARCHAR(200)
)
RETURNS INT
AS
BEGIN
	DECLARE @Result INT = 1
			, @Status BIT
			, @Locked BIT
			, @WrongPassword BIT
	
	IF (SELECT TOP 1 1 FROM SEC_User WHERE UserName=@UserName) IS NULL
		SET @Result = 0 -- User is not exist
	ELSE 
	BEGIN
			SELECT @Status=ActiveStatus
					,@Locked=Locked
			FROM SEC_User WHERE UserName=@UserName
			
			IF(SELECT TOP 1 1
				FROM SEC_User WHERE UserName=@UserName AND Password = @Password) IS NULL
			SET @WrongPassword = 1
				
		
		IF @Status = 0
			SET @Result = 2 -- User is inActive
		ELSE IF @Locked = 1
			SET @Result = 3 -- User locked	
		ELSE IF @WrongPassword = 1
			SET @Result = 4 -- Wrong Password
	END
	
	RETURN @Result

END

GO
/****** Object:  Table [dbo].[Category]    Script Date: 7/1/2018 1:04:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Category](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[CategoryName] [nvarchar](500) NOT NULL,
	[ActiveStatus] [int] NULL,
	[CreateBy] [uniqueidentifier] NULL,
	[UpdateBy] [uniqueidentifier] NULL,
	[CreateDTS] [datetime] NULL,
	[UpdateDTS] [datetime] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Color]    Script Date: 7/1/2018 1:04:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Color](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[ColorName] [nvarchar](250) NOT NULL,
	[ActiveStatus] [int] NULL,
	[CreateBy] [uniqueidentifier] NULL,
	[UpdateBy] [uniqueidentifier] NULL,
	[CreateDTS] [datetime] NULL,
	[UpdateDTS] [datetime] NULL,
 CONSTRAINT [PK_Color] PRIMARY KEY CLUSTERED 
(
	[Id] ASC,
	[ColorName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Component]    Script Date: 7/1/2018 1:04:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Component](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[ComponentCode] [nvarchar](250) NULL,
	[ComponentName] [nvarchar](500) NULL,
	[SupplierId] [int] NULL,
	[Price] [decimal](18, 2) NULL,
	[Color] [nvarchar](250) NULL,
	[Unit] [nvarchar](250) NULL,
	[Description] [nvarchar](max) NULL,
	[ActiveStatus] [int] NULL,
	[CreateBy] [uniqueidentifier] NULL,
	[UpdateBy] [uniqueidentifier] NULL,
	[CreateDTS] [datetime] NULL,
	[UpdateDTS] [datetime] NULL,
 CONSTRAINT [PK_Component] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Material]    Script Date: 7/1/2018 1:04:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Material](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[MaterialName] [nvarchar](500) NULL,
	[SupplierId] [int] NULL,
	[Price] [decimal](18, 2) NULL,
	[Description] [nvarchar](max) NULL,
	[ActiveStatus] [int] NULL,
	[CreateBy] [uniqueidentifier] NULL,
	[UpdateBy] [uniqueidentifier] NULL,
	[CreateDTS] [datetime] NULL,
	[UpdateDTS] [datetime] NULL,
 CONSTRAINT [PK_Material] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Order]    Script Date: 7/1/2018 1:04:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Order](
	[Id] [bigint] NOT NULL,
	[EmployeeId] [int] NULL,
	[EmployeeName] [nvarchar](250) NULL,
	[Step] [int] NULL,
	[Taxes] [decimal](18, 2) NULL,
	[Surcharge] [decimal](18, 2) NULL,
	[Discount] [decimal](18, 2) NULL,
	[OrderDate] [datetime] NULL,
	[FirtReceiveDate] [datetime] NULL,
	[LastUpdate] [datetime] NULL,
	[DeliveryDate] [datetime] NULL,
	[Notes] [nvarchar](max) NULL,
	[SupplierId] [int] NULL,
	[SupplierName] [nvarchar](250) NULL,
	[SupplierAddress] [nvarchar](500) NULL,
	[SupplierEmail] [nvarchar](250) NULL,
	[SupplierPhone] [nvarchar](50) NULL,
	[OrderRefNo] [nvarchar](250) NULL,
	[OrderType] [int] NULL,
	[CreateBy] [uniqueidentifier] NULL,
	[UpdateBy] [uniqueidentifier] NULL,
	[CreateDTS] [datetime] NULL,
	[UpdateDTS] [datetime] NULL,
	[ActiveStatus] [int] NULL,
 CONSTRAINT [PK_Purchase] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[OrderComponent]    Script Date: 7/1/2018 1:04:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[OrderComponent](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[OrderId] [bigint] NOT NULL,
	[ComponentId] [int] NOT NULL,
	[ColorId] [int] NULL,
	[Quantity] [int] NULL,
	[Price] [decimal](18, 2) NULL,
	[ExtCharge] [bit] NULL,
	[UnitId] [int] NULL,
	[OrderType] [int] NULL,
	[Step] [int] NULL,
	[AMTExcGST] [decimal](18, 2) NULL,
	[GST] [decimal](18, 2) NULL,
	[AMTIncGST] [decimal](18, 2) NULL,
	[ReceivedAMTExcGST] [decimal](18, 2) NULL,
	[ReceivedGST] [decimal](18, 2) NULL,
	[ReceivedAMTIncGST] [decimal](18, 2) NULL,
	[TotalAmount] [numeric](18, 2) NULL,
	[DeliveryNo] [nvarchar](250) NULL,
	[DeliveryDate] [datetime] NULL,
	[Received] [int] NULL,
	[BackOrder] [int] NULL,
	[CreateBy] [uniqueidentifier] NULL,
	[UpdateBy] [uniqueidentifier] NULL,
	[CreateDTS] [datetime] NULL,
	[UpdateDTS] [datetime] NULL,
 CONSTRAINT [PK_PurchaseComponent] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[OrderInvoice]    Script Date: 7/1/2018 1:04:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[OrderInvoice](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[OrderId] [bigint] NOT NULL,
	[InvoiceNo] [nvarchar](250) NULL,
	[InvoiceDate] [datetime] NULL,
	[InvoiceAmount] [decimal](18, 2) NULL,
	[CutLengthCharge] [nvarchar](250) NULL,
	[DeliveryCharge] [nvarchar](250) NULL,
	[ActiveStatus] [int] NULL,
	[CreateBy] [uniqueidentifier] NULL,
	[UpdateBy] [uniqueidentifier] NULL,
	[CreateDTS] [datetime] NULL,
	[UpdateDTS] [datetime] NULL,
 CONSTRAINT [PK_OrderInvoice] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[OrderPayment]    Script Date: 7/1/2018 1:04:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[OrderPayment](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[OrderId] [bigint] NOT NULL,
	[DatePaid] [datetime] NOT NULL,
	[PaymentType] [nvarchar](250) NULL,
	[AmountPaid] [decimal](18, 2) NULL,
	[ActiveStatus] [int] NULL,
	[CreateBy] [uniqueidentifier] NULL,
	[UpdateBy] [uniqueidentifier] NULL,
	[CreateDTS] [datetime] NULL,
	[UpdateDTS] [datetime] NULL,
 CONSTRAINT [PK_OrderPayment] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[OrderProduct]    Script Date: 7/1/2018 1:04:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[OrderProduct](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[OrderId] [bigint] NULL,
	[ProductId] [int] NULL,
	[MaterialId] [int] NULL,
	[LocationId] [int] NULL,
	[ColorId] [int] NULL,
	[ControlSideId] [int] NULL,
	[UnitId] [int] NULL,
	[Drop] [int] NULL,
	[Width] [int] NULL,
	[Quantity] [int] NULL,
	[Discount] [int] NULL,
	[ExtendPrice] [numeric](18, 2) NULL,
	[UnitPrice] [numeric](18, 2) NULL,
	[TotalAmount] [numeric](18, 2) NULL,
	[DeliveryNo] [nvarchar](250) NULL,
	[DeliveryDate] [datetime] NULL,
	[Received] [int] NULL,
	[BackOrder] [int] NULL,
	[OrderType] [int] NULL,
	[Step] [int] NULL,
	[AMTExcGST] [decimal](18, 2) NULL,
	[GST] [decimal](18, 2) NULL,
	[AMTIncGST] [decimal](18, 2) NULL,
	[ReceivedAMTExcGST] [decimal](18, 2) NULL,
	[ReceivedGST] [decimal](18, 2) NULL,
	[ReceivedAMTIncGST] [decimal](18, 2) NULL,
	[ActiveStatus] [int] NULL,
	[CreateBy] [uniqueidentifier] NULL,
	[UpdateBy] [uniqueidentifier] NULL,
	[CreateDTS] [datetime] NULL,
	[UpdateDTS] [datetime] NULL,
 CONSTRAINT [PK_OrderProduct] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Product]    Script Date: 7/1/2018 1:04:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Product](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[ProductCode] [nvarchar](250) NULL,
	[ProductName] [nvarchar](500) NOT NULL,
	[CategoryId] [int] NULL,
	[Notes] [nvarchar](max) NULL,
	[ActiveStatus] [int] NULL,
	[CreateBy] [uniqueidentifier] NULL,
	[UpdateBy] [uniqueidentifier] NULL,
	[CreateDTS] [datetime] NULL,
	[UpdateDTS] [datetime] NULL,
 CONSTRAINT [PK_Product] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ProductComponent]    Script Date: 7/1/2018 1:04:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ProductComponent](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[ProductId] [int] NOT NULL,
	[ComponentId] [int] NOT NULL,
	[ColorId] [int] NULL,
	[Quantity] [int] NULL,
	[Price] [decimal](18, 2) NULL,
	[ExtCharge] [bit] NULL,
	[CreateBy] [uniqueidentifier] NULL,
	[UpdateBy] [uniqueidentifier] NULL,
	[CreateDTS] [datetime] NULL,
	[UpdateDTS] [datetime] NULL,
 CONSTRAINT [PK_ProductComponent] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ProductMaterial]    Script Date: 7/1/2018 1:04:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ProductMaterial](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[ProductId] [int] NOT NULL,
	[MaterialId] [int] NOT NULL,
	[CreateBy] [uniqueidentifier] NULL,
	[UpdateBy] [uniqueidentifier] NULL,
	[CreateDTS] [datetime] NULL,
	[UpdateDTS] [datetime] NULL,
 CONSTRAINT [PK_ProductMaterial] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ProductPrice]    Script Date: 7/1/2018 1:04:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ProductPrice](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[ProductMaterialId] [int] NOT NULL,
	[Row] [int] NOT NULL,
	[Column] [int] NOT NULL,
	[Value] [decimal](18, 2) NULL,
	[CreateBy] [uniqueidentifier] NULL,
	[UpdateBy] [uniqueidentifier] NULL,
	[CreateDTS] [datetime] NULL,
	[UpdateDTS] [datetime] NULL,
 CONSTRAINT [PK_ProductPrice_1] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[SEC_User]    Script Date: 7/1/2018 1:04:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SEC_User](
	[RecId] [nvarchar](200) NOT NULL,
	[UserName] [nvarchar](200) NOT NULL,
	[FirstName] [nvarchar](250) NULL,
	[LastName] [nvarchar](250) NULL,
	[FullName] [nvarchar](500) NULL,
	[Password] [nvarchar](100) NULL,
	[Email] [nvarchar](150) NULL,
	[Birthday] [datetime] NULL,
	[Age] [int] NULL,
	[Sex] [int] NULL,
	[Address] [nvarchar](500) NULL,
	[City] [nvarchar](50) NULL,
	[State] [nvarchar](50) NULL,
	[PhoneNumber] [nvarchar](15) NULL,
	[CreateDTS] [datetime] NULL,
	[UpdateDTS] [datetime] NULL,
	[LastLoginDTS] [datetime] NULL,
	[CreateBy] [uniqueidentifier] NULL,
	[ActiveStatus] [int] NULL,
	[Locked] [bit] NULL,
	[UpdateBy] [uniqueidentifier] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Supplier]    Script Date: 7/1/2018 1:04:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Supplier](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[FirstName] [nvarchar](250) NULL,
	[LastName] [nvarchar](250) NULL,
	[Company] [nvarchar](250) NULL,
	[Email] [nvarchar](250) NULL,
	[JobTitle] [nvarchar](250) NULL,
	[WebPage] [nvarchar](500) NULL,
	[Notes] [nvarchar](max) NULL,
	[Address] [nvarchar](500) NULL,
	[ZipCode] [nvarchar](250) NULL,
	[City] [nvarchar](250) NULL,
	[State] [nvarchar](250) NULL,
	[Country] [nvarchar](250) NULL,
	[BusinessPhone] [nvarchar](50) NULL,
	[MobilePhone] [nvarchar](50) NULL,
	[HomePhone] [nvarchar](50) NULL,
	[Fax] [nvarchar](50) NULL,
	[ActiveStatus] [int] NULL,
	[CreateBy] [uniqueidentifier] NULL,
	[UpdateBy] [uniqueidentifier] NULL,
	[CreateDTS] [datetime] NULL,
	[UpdateDTS] [datetime] NULL,
 CONSTRAINT [PK_Supplier] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
SET IDENTITY_INSERT [dbo].[Category] ON 

INSERT [dbo].[Category] ([Id], [CategoryName], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1, N'Security', 1, NULL, NULL, NULL, NULL)
INSERT [dbo].[Category] ([Id], [CategoryName], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2, N'Indoor', 1, NULL, NULL, NULL, NULL)
INSERT [dbo].[Category] ([Id], [CategoryName], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3, N'Outdoor', 1, NULL, NULL, NULL, NULL)
SET IDENTITY_INSERT [dbo].[Category] OFF
SET IDENTITY_INSERT [dbo].[Color] ON 

INSERT [dbo].[Color] ([Id], [ColorName], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1, N'NA', 1, NULL, NULL, NULL, NULL)
INSERT [dbo].[Color] ([Id], [ColorName], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2, N'Brown Satin
', 1, NULL, NULL, NULL, NULL)
INSERT [dbo].[Color] ([Id], [ColorName], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3, N'Paperbark Matt
', 1, NULL, NULL, NULL, NULL)
INSERT [dbo].[Color] ([Id], [ColorName], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4, N'Pearl White Gloss
', NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[Color] ([Id], [ColorName], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (5, N'Pottery Satin
', NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[Color] ([Id], [ColorName], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (6, N'Satin Chrome
', NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[Color] ([Id], [ColorName], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (7, N'Stone Beige Matt
', NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[Color] ([Id], [ColorName], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (8, N'White Birch Gloss
', NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[Color] ([Id], [ColorName], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (9, N'Woodland Grey Matt
', NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[Color] ([Id], [ColorName], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (10, N'Satin S/Less Steel
', NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[Color] ([Id], [ColorName], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (11, N'Stainless Steel
', NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[Color] ([Id], [ColorName], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (12, N'Primrose Gloss
', NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[Color] ([Id], [ColorName], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (13, N'Charcoal (Monument)
', NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[Color] ([Id], [ColorName], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (14, N'Merino
', NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[Color] ([Id], [ColorName], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (15, N'Shale Grey
', NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[Color] ([Id], [ColorName], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (16, N'Charcoal (Monument)6.5M
', NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[Color] ([Id], [ColorName], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (17, N'White
', NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[Color] ([Id], [ColorName], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (18, N'Ratio White
', NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[Color] ([Id], [ColorName], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (19, N'Zinc
', NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[Color] ([Id], [ColorName], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (20, N'Ivory
', NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[Color] ([Id], [ColorName], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (21, N'2 Hole
', NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[Color] ([Id], [ColorName], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (22, N'Charcoal(Monument)
', NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[Color] ([Id], [ColorName], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (23, N'Charcoal(Monument)6.5M
', NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[Color] ([Id], [ColorName], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (24, N'Caulfield Green
', NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[Color] ([Id], [ColorName], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (25, N'Pure White
', NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[Color] ([Id], [ColorName], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (26, N'Blue Sky
', NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[Color] ([Id], [ColorName], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (27, N'Silver Grey
', NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[Color] ([Id], [ColorName], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (28, N'Vivid White
', NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[Color] ([Id], [ColorName], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (29, N'Mill Finish
', NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[Color] ([Id], [ColorName], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (30, N'Silver Zinc Plated
', NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[Color] ([Id], [ColorName], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (31, N'Black Satin
', NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[Color] ([Id], [ColorName], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (32, N'Pottery
', NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[Color] ([Id], [ColorName], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (33, N'Paperbark
', NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[Color] ([Id], [ColorName], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (34, N'Pearl White
', NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[Color] ([Id], [ColorName], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (35, N'Satin Black
', NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[Color] ([Id], [ColorName], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (36, N'Dune
', NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[Color] ([Id], [ColorName], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (37, N'Jasper
', NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[Color] ([Id], [ColorName], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (38, N'Woodland Grey
', NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[Color] ([Id], [ColorName], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (39, N'Charcoal
', NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[Color] ([Id], [ColorName], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (40, N'Monument Matte
', NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[Color] ([Id], [ColorName], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (41, N'Sand Black
', NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[Color] ([Id], [ColorName], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (42, N'Aliminium
', NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[Color] ([Id], [ColorName], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (43, N'Blue
', NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[Color] ([Id], [ColorName], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (44, N'Primrose
', NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[Color] ([Id], [ColorName], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (45, N'Custom Black
', NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[Color] ([Id], [ColorName], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (46, N'Monument
', NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[Color] ([Id], [ColorName], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (47, N'Bronze Anod
', NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[Color] ([Id], [ColorName], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (48, N'Brown
', NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[Color] ([Id], [ColorName], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (49, N'Monument Satin
', NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[Color] ([Id], [ColorName], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (50, N'Ultra Sliver
', NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[Color] ([Id], [ColorName], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (51, N'Jasper Satin
', NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[Color] ([Id], [ColorName], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (52, N'Grey
', NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[Color] ([Id], [ColorName], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (53, N'Woodland Grey Satin
', NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[Color] ([Id], [ColorName], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (54, N'Paperback
', NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[Color] ([Id], [ColorName], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (55, N'Sliver Gloss
', NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[Color] ([Id], [ColorName], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (56, N'Ultra Sliver Gloss
', NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[Color] ([Id], [ColorName], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (57, N'Amaranth
', NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[Color] ([Id], [ColorName], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (58, N'Amber
', NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[Color] ([Id], [ColorName], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (59, N'Amethyst
', NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[Color] ([Id], [ColorName], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (60, N'Apricot
', NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[Color] ([Id], [ColorName], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (61, N'Aquamarine
', NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[Color] ([Id], [ColorName], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (62, N'Azure
', NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[Color] ([Id], [ColorName], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (63, N'Baby blue
', NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[Color] ([Id], [ColorName], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (64, N'Beige
', NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[Color] ([Id], [ColorName], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (67, N'Blue-green
', NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[Color] ([Id], [ColorName], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (68, N'Blue-violet
', NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[Color] ([Id], [ColorName], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (69, N'Blush
', NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[Color] ([Id], [ColorName], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (70, N'Bronze
', NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[Color] ([Id], [ColorName], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (72, N'Burgundy
', NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[Color] ([Id], [ColorName], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (73, N'Byzantium
', NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[Color] ([Id], [ColorName], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (74, N'Carmine
', NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[Color] ([Id], [ColorName], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (75, N'Cerise
', NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[Color] ([Id], [ColorName], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (76, N'Cerulean
', NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[Color] ([Id], [ColorName], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (77, N'Champagne
', NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[Color] ([Id], [ColorName], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (78, N'Chartreuse green
', NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[Color] ([Id], [ColorName], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (79, N'Chocolate
', NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[Color] ([Id], [ColorName], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (80, N'Cobalt blue
', NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[Color] ([Id], [ColorName], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (81, N'Coffee
', NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[Color] ([Id], [ColorName], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (82, N'Copper
', NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[Color] ([Id], [ColorName], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (83, N'Coral
', NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[Color] ([Id], [ColorName], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (84, N'Crimson
', NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[Color] ([Id], [ColorName], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (85, N'Cyan
', NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[Color] ([Id], [ColorName], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (86, N'Desert sand
', NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[Color] ([Id], [ColorName], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (87, N'Electric blue
', NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[Color] ([Id], [ColorName], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (88, N'Emerald
', NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[Color] ([Id], [ColorName], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (89, N'Erin
', NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[Color] ([Id], [ColorName], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (90, N'Gold
', NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[Color] ([Id], [ColorName], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (91, N'Gray
', NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[Color] ([Id], [ColorName], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (92, N'Green
', NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[Color] ([Id], [ColorName], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (93, N'Harlequin
', NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[Color] ([Id], [ColorName], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (94, N'Indigo
', NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[Color] ([Id], [ColorName], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (96, N'Jade
', NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[Color] ([Id], [ColorName], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (97, N'Jungle green
', NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[Color] ([Id], [ColorName], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (98, N'Lavender
', NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[Color] ([Id], [ColorName], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (99, N'Lemon
', NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[Color] ([Id], [ColorName], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (100, N'Lilac
', NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[Color] ([Id], [ColorName], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (101, N'Lime
', NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[Color] ([Id], [ColorName], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (102, N'Magenta
', NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[Color] ([Id], [ColorName], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (103, N'Magenta rose
', NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[Color] ([Id], [ColorName], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (104, N'Maroon
', NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[Color] ([Id], [ColorName], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (105, N'Mauve
', NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[Color] ([Id], [ColorName], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (106, N'Navy blue
', NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[Color] ([Id], [ColorName], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (107, N'Ocher
', NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[Color] ([Id], [ColorName], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (108, N'Olive
', NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[Color] ([Id], [ColorName], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (109, N'Orange
', NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[Color] ([Id], [ColorName], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (110, N'Orange-red
', NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[Color] ([Id], [ColorName], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (111, N'Orchid
', NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[Color] ([Id], [ColorName], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (112, N'Peach
', NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[Color] ([Id], [ColorName], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (113, N'Pear
', NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[Color] ([Id], [ColorName], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (114, N'Periwinkle
', NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[Color] ([Id], [ColorName], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (115, N'Persian blue
', NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[Color] ([Id], [ColorName], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (116, N'Pink
', NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[Color] ([Id], [ColorName], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (117, N'Plum
', NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[Color] ([Id], [ColorName], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (118, N'Prussian blue
', NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[Color] ([Id], [ColorName], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (119, N'Puce
', NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[Color] ([Id], [ColorName], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (120, N'Purple
', NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[Color] ([Id], [ColorName], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (121, N'Raspberry
', NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[Color] ([Id], [ColorName], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (122, N'Red
', NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[Color] ([Id], [ColorName], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (123, N'Red-violet
', NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[Color] ([Id], [ColorName], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (124, N'Rose
', NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[Color] ([Id], [ColorName], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (125, N'Ruby
', NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[Color] ([Id], [ColorName], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (126, N'Salmon
', NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[Color] ([Id], [ColorName], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (127, N'Sangria
', NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[Color] ([Id], [ColorName], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (128, N'Sapphire
', NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[Color] ([Id], [ColorName], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (129, N'Scarlet
', NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[Color] ([Id], [ColorName], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (130, N'Silver
', NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[Color] ([Id], [ColorName], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (131, N'Slate gray
', NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[Color] ([Id], [ColorName], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (132, N'Spring bud
', NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[Color] ([Id], [ColorName], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (133, N'Spring green
', NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[Color] ([Id], [ColorName], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (134, N'Tan
', NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[Color] ([Id], [ColorName], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (135, N'Taupe
', NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[Color] ([Id], [ColorName], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (136, N'Teal
', NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[Color] ([Id], [ColorName], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (137, N'Turquoise
', NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[Color] ([Id], [ColorName], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (138, N'Violet
', NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[Color] ([Id], [ColorName], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (139, N'Viridian
', NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[Color] ([Id], [ColorName], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (141, N'Yellow
', NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[Color] ([Id], [ColorName], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (143, N'Black', NULL, NULL, NULL, NULL, NULL)
SET IDENTITY_INSERT [dbo].[Color] OFF
SET IDENTITY_INSERT [dbo].[Component] ON 

INSERT [dbo].[Component] ([Id], [ComponentCode], [ComponentName], [SupplierId], [Price], [Color], [Unit], [Description], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1, N'BWC0002', N'Chain holder', 4, CAST(2000.00 AS Decimal(18, 2)), N'Brown Satin
', N'Each', N'Chain holder', 1, NULL, NULL, CAST(N'2018-06-12T23:11:36.510' AS DateTime), CAST(N'2018-06-30T23:19:59.850' AS DateTime))
INSERT [dbo].[Component] ([Id], [ComponentCode], [ComponentName], [SupplierId], [Price], [Color], [Unit], [Description], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4, N'BWC0004', N'Double bracket ', 5, CAST(120.00 AS Decimal(18, 2)), N'Brown Satin
', N'Each', N'double bracket then no need supply single bracket', 1, NULL, NULL, CAST(N'2018-06-16T17:55:29.103' AS DateTime), CAST(N'2018-06-30T23:19:13.027' AS DateTime))
SET IDENTITY_INSERT [dbo].[Component] OFF
SET IDENTITY_INSERT [dbo].[Material] ON 

INSERT [dbo].[Material] ([Id], [MaterialName], [SupplierId], [Price], [Description], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2, N'SHANN MESH', 4, NULL, N'VALESCO - WHOLESALE PRICE - GST NOT INC.', 1, NULL, NULL, CAST(N'2018-06-14T22:27:14.670' AS DateTime), CAST(N'2018-06-30T23:18:29.453' AS DateTime))
INSERT [dbo].[Material] ([Id], [MaterialName], [SupplierId], [Price], [Description], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4, N'SHAW -SCREEN (2500/3200MM)', 5, NULL, N'SHAW -SCREEN (2500/3200MM)', 1, NULL, NULL, CAST(N'2018-06-14T22:32:04.043' AS DateTime), CAST(N'2018-06-30T23:17:56.497' AS DateTime))
INSERT [dbo].[Material] ([Id], [MaterialName], [SupplierId], [Price], [Description], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (5, N'SHAW -  LE REVE B/O (3000MM) - MANTRA B/O (3000MM)', 5, NULL, N'SHAW -  LE REVE B/O (3000MM) - MANTRA B/O (3000MM)', 1, NULL, NULL, CAST(N'2018-06-17T16:06:42.600' AS DateTime), CAST(N'2018-06-30T23:18:12.630' AS DateTime))
SET IDENTITY_INSERT [dbo].[Material] OFF
INSERT [dbo].[Order] ([Id], [EmployeeId], [EmployeeName], [Step], [Taxes], [Surcharge], [Discount], [OrderDate], [FirtReceiveDate], [LastUpdate], [DeliveryDate], [Notes], [SupplierId], [SupplierName], [SupplierAddress], [SupplierEmail], [SupplierPhone], [OrderRefNo], [OrderType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS], [ActiveStatus]) VALUES (1529590581377, 2, NULL, 3, CAST(10.00 AS Decimal(18, 2)), CAST(0.00 AS Decimal(18, 2)), CAST(0.00 AS Decimal(18, 2)), CAST(N'2018-06-22T00:00:00.000' AS DateTime), NULL, NULL, NULL, NULL, 4, N'tung le', N'quoturm', N'mngo@aperia.com', N'123576787', NULL, 1, NULL, NULL, CAST(N'2018-06-21T21:16:49.643' AS DateTime), CAST(N'2018-06-27T23:28:40.180' AS DateTime), NULL)
INSERT [dbo].[Order] ([Id], [EmployeeId], [EmployeeName], [Step], [Taxes], [Surcharge], [Discount], [OrderDate], [FirtReceiveDate], [LastUpdate], [DeliveryDate], [Notes], [SupplierId], [SupplierName], [SupplierAddress], [SupplierEmail], [SupplierPhone], [OrderRefNo], [OrderType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS], [ActiveStatus]) VALUES (1529590718053, 3, NULL, 3, CAST(10.00 AS Decimal(18, 2)), CAST(0.00 AS Decimal(18, 2)), CAST(0.00 AS Decimal(18, 2)), CAST(N'2018-06-21T00:00:00.000' AS DateTime), NULL, NULL, NULL, NULL, 6, N'tung tung le', N'141-2B Gia tan 3, thong nhat, dong nai', N'tungle@aperia.com', N'123456', NULL, 1, NULL, NULL, CAST(N'2018-06-21T21:18:49.343' AS DateTime), CAST(N'2018-06-30T12:46:25.317' AS DateTime), NULL)
INSERT [dbo].[Order] ([Id], [EmployeeId], [EmployeeName], [Step], [Taxes], [Surcharge], [Discount], [OrderDate], [FirtReceiveDate], [LastUpdate], [DeliveryDate], [Notes], [SupplierId], [SupplierName], [SupplierAddress], [SupplierEmail], [SupplierPhone], [OrderRefNo], [OrderType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS], [ActiveStatus]) VALUES (1529592217856, 1, NULL, 2, CAST(8.00 AS Decimal(18, 2)), CAST(1231.00 AS Decimal(18, 2)), CAST(0.00 AS Decimal(18, 2)), CAST(N'2018-06-21T00:00:00.000' AS DateTime), NULL, NULL, NULL, N'this is note', 5, N'viet tuan', N'quoturm', N'mngo@aperia.com', N'1234', N'123123', 1, NULL, NULL, CAST(N'2018-06-21T21:44:21.587' AS DateTime), CAST(N'2018-06-27T23:28:03.010' AS DateTime), NULL)
INSERT [dbo].[Order] ([Id], [EmployeeId], [EmployeeName], [Step], [Taxes], [Surcharge], [Discount], [OrderDate], [FirtReceiveDate], [LastUpdate], [DeliveryDate], [Notes], [SupplierId], [SupplierName], [SupplierAddress], [SupplierEmail], [SupplierPhone], [OrderRefNo], [OrderType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS], [ActiveStatus]) VALUES (1529595111990, 2, N'Tuan Le', 4, CAST(9.00 AS Decimal(18, 2)), CAST(1234.00 AS Decimal(18, 2)), CAST(0.00 AS Decimal(18, 2)), CAST(N'2018-11-22T00:00:00.000' AS DateTime), CAST(N'2018-04-24T00:00:00.000' AS DateTime), NULL, NULL, N'this is note', 4, N'tung le', N'quoturm', N'mngo@aperia.com', N'1234456', NULL, 1, NULL, NULL, CAST(N'2018-06-21T22:32:37.280' AS DateTime), CAST(N'2018-06-25T21:18:07.170' AS DateTime), NULL)
INSERT [dbo].[Order] ([Id], [EmployeeId], [EmployeeName], [Step], [Taxes], [Surcharge], [Discount], [OrderDate], [FirtReceiveDate], [LastUpdate], [DeliveryDate], [Notes], [SupplierId], [SupplierName], [SupplierAddress], [SupplierEmail], [SupplierPhone], [OrderRefNo], [OrderType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS], [ActiveStatus]) VALUES (1530330251506, 2, N'Tuan Le', 1, CAST(9.00 AS Decimal(18, 2)), CAST(1234.00 AS Decimal(18, 2)), CAST(0.00 AS Decimal(18, 2)), CAST(N'2018-06-30T10:44:15.003' AS DateTime), NULL, NULL, NULL, N'this is note', 4, N'tung le', N'quoturm', N'mngo@aperia.com', N'1234456', NULL, 1, NULL, NULL, CAST(N'2018-06-30T10:44:15.003' AS DateTime), NULL, NULL)
INSERT [dbo].[Order] ([Id], [EmployeeId], [EmployeeName], [Step], [Taxes], [Surcharge], [Discount], [OrderDate], [FirtReceiveDate], [LastUpdate], [DeliveryDate], [Notes], [SupplierId], [SupplierName], [SupplierAddress], [SupplierEmail], [SupplierPhone], [OrderRefNo], [OrderType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS], [ActiveStatus]) VALUES (1530330437904, 1, NULL, 1, CAST(5.00 AS Decimal(18, 2)), CAST(1231.00 AS Decimal(18, 2)), CAST(0.00 AS Decimal(18, 2)), CAST(N'2018-06-30T10:47:17.000' AS DateTime), NULL, NULL, NULL, N'this is note', 5, N'viet tuan', N'quoturm', N'mngo@aperia.com', N'1234', N'123123', 1, NULL, NULL, CAST(N'2018-06-30T10:47:17.990' AS DateTime), CAST(N'2018-06-30T13:04:46.773' AS DateTime), NULL)
INSERT [dbo].[Order] ([Id], [EmployeeId], [EmployeeName], [Step], [Taxes], [Surcharge], [Discount], [OrderDate], [FirtReceiveDate], [LastUpdate], [DeliveryDate], [Notes], [SupplierId], [SupplierName], [SupplierAddress], [SupplierEmail], [SupplierPhone], [OrderRefNo], [OrderType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS], [ActiveStatus]) VALUES (1530330652517, 1, NULL, 1, CAST(8.00 AS Decimal(18, 2)), CAST(1231.00 AS Decimal(18, 2)), CAST(0.00 AS Decimal(18, 2)), CAST(N'2018-06-30T10:50:52.600' AS DateTime), NULL, NULL, NULL, N'this is note', 5, N'viet tuan', N'quoturm', N'mngo@aperia.com', N'1234', N'123123', 1, NULL, NULL, CAST(N'2018-06-30T10:50:52.600' AS DateTime), NULL, NULL)
INSERT [dbo].[Order] ([Id], [EmployeeId], [EmployeeName], [Step], [Taxes], [Surcharge], [Discount], [OrderDate], [FirtReceiveDate], [LastUpdate], [DeliveryDate], [Notes], [SupplierId], [SupplierName], [SupplierAddress], [SupplierEmail], [SupplierPhone], [OrderRefNo], [OrderType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS], [ActiveStatus]) VALUES (1530330861321, 1, NULL, 1, CAST(8.00 AS Decimal(18, 2)), CAST(1231.00 AS Decimal(18, 2)), CAST(0.00 AS Decimal(18, 2)), CAST(N'2018-06-30T10:54:21.403' AS DateTime), NULL, NULL, NULL, N'this is note', 5, N'viet tuan', N'quoturm', N'mngo@aperia.com', N'1234', N'123123', 1, NULL, NULL, CAST(N'2018-06-30T10:54:21.403' AS DateTime), NULL, NULL)
INSERT [dbo].[Order] ([Id], [EmployeeId], [EmployeeName], [Step], [Taxes], [Surcharge], [Discount], [OrderDate], [FirtReceiveDate], [LastUpdate], [DeliveryDate], [Notes], [SupplierId], [SupplierName], [SupplierAddress], [SupplierEmail], [SupplierPhone], [OrderRefNo], [OrderType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS], [ActiveStatus]) VALUES (1530330946656, 1, NULL, 6, CAST(8.00 AS Decimal(18, 2)), CAST(1231.00 AS Decimal(18, 2)), CAST(0.00 AS Decimal(18, 2)), CAST(N'2018-06-30T10:55:46.000' AS DateTime), NULL, NULL, NULL, N'this is note', 5, N'viet tuan', N'quoturm', N'mngo@aperia.com', N'1234', N'123123', 1, NULL, NULL, CAST(N'2018-06-30T10:55:46.763' AS DateTime), CAST(N'2018-06-30T12:46:48.840' AS DateTime), NULL)
INSERT [dbo].[Order] ([Id], [EmployeeId], [EmployeeName], [Step], [Taxes], [Surcharge], [Discount], [OrderDate], [FirtReceiveDate], [LastUpdate], [DeliveryDate], [Notes], [SupplierId], [SupplierName], [SupplierAddress], [SupplierEmail], [SupplierPhone], [OrderRefNo], [OrderType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS], [ActiveStatus]) VALUES (1530331633177, 2, N'Tuan Le', 6, CAST(9.00 AS Decimal(18, 2)), CAST(1234.00 AS Decimal(18, 2)), CAST(0.00 AS Decimal(18, 2)), CAST(N'2018-06-30T11:07:13.000' AS DateTime), NULL, NULL, NULL, N'this is note', 4, N'tung le', N'quoturm', N'mngo@aperia.com', N'1234456', NULL, 1, NULL, NULL, CAST(N'2018-06-30T11:07:13.270' AS DateTime), CAST(N'2018-06-30T18:23:06.390' AS DateTime), NULL)
INSERT [dbo].[Order] ([Id], [EmployeeId], [EmployeeName], [Step], [Taxes], [Surcharge], [Discount], [OrderDate], [FirtReceiveDate], [LastUpdate], [DeliveryDate], [Notes], [SupplierId], [SupplierName], [SupplierAddress], [SupplierEmail], [SupplierPhone], [OrderRefNo], [OrderType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS], [ActiveStatus]) VALUES (1530360311814, 2, N'Tuan Le', 1, CAST(9.00 AS Decimal(18, 2)), CAST(1234.00 AS Decimal(18, 2)), CAST(0.00 AS Decimal(18, 2)), CAST(N'2018-06-30T19:05:11.893' AS DateTime), NULL, NULL, NULL, N'this is note', 4, N'tung le', N'quoturm', N'mngo@aperia.com', N'1234456', NULL, 1, NULL, NULL, CAST(N'2018-06-30T19:05:11.893' AS DateTime), NULL, NULL)
INSERT [dbo].[Order] ([Id], [EmployeeId], [EmployeeName], [Step], [Taxes], [Surcharge], [Discount], [OrderDate], [FirtReceiveDate], [LastUpdate], [DeliveryDate], [Notes], [SupplierId], [SupplierName], [SupplierAddress], [SupplierEmail], [SupplierPhone], [OrderRefNo], [OrderType], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS], [ActiveStatus]) VALUES (1530360334538, 2, N'Tuan Le', 1, CAST(7.00 AS Decimal(18, 2)), CAST(1234.00 AS Decimal(18, 2)), CAST(0.00 AS Decimal(18, 2)), CAST(N'2018-06-30T19:05:34.000' AS DateTime), NULL, NULL, NULL, N'this is note', 4, N'tung le', N'quoturm', N'mngo@aperia.com', N'1234456', NULL, 1, NULL, NULL, CAST(N'2018-06-30T19:05:34.593' AS DateTime), CAST(N'2018-06-30T22:00:36.663' AS DateTime), NULL)
SET IDENTITY_INSERT [dbo].[OrderComponent] ON 

INSERT [dbo].[OrderComponent] ([Id], [OrderId], [ComponentId], [ColorId], [Quantity], [Price], [ExtCharge], [UnitId], [OrderType], [Step], [AMTExcGST], [GST], [AMTIncGST], [ReceivedAMTExcGST], [ReceivedGST], [ReceivedAMTIncGST], [TotalAmount], [DeliveryNo], [DeliveryDate], [Received], [BackOrder], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (6, 1529595111990, 1, 6, 1, CAST(5000.00 AS Decimal(18, 2)), 0, 5, NULL, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, CAST(N'2018-06-25T18:45:37.770' AS DateTime), CAST(N'2018-06-25T23:32:18.743' AS DateTime))
INSERT [dbo].[OrderComponent] ([Id], [OrderId], [ComponentId], [ColorId], [Quantity], [Price], [ExtCharge], [UnitId], [OrderType], [Step], [AMTExcGST], [GST], [AMTIncGST], [ReceivedAMTExcGST], [ReceivedGST], [ReceivedAMTIncGST], [TotalAmount], [DeliveryNo], [DeliveryDate], [Received], [BackOrder], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (8, 1529595111990, 1, 5, 1, CAST(900.00 AS Decimal(18, 2)), 0, 1, NULL, 3, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, CAST(N'2018-06-25T22:14:12.877' AS DateTime), CAST(N'2018-06-30T11:03:46.410' AS DateTime))
INSERT [dbo].[OrderComponent] ([Id], [OrderId], [ComponentId], [ColorId], [Quantity], [Price], [ExtCharge], [UnitId], [OrderType], [Step], [AMTExcGST], [GST], [AMTIncGST], [ReceivedAMTExcGST], [ReceivedGST], [ReceivedAMTIncGST], [TotalAmount], [DeliveryNo], [DeliveryDate], [Received], [BackOrder], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (9, 1529590581377, 1, 3, 2, CAST(200.00 AS Decimal(18, 2)), 0, 1, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, CAST(N'2018-06-29T22:48:50.743' AS DateTime), NULL)
INSERT [dbo].[OrderComponent] ([Id], [OrderId], [ComponentId], [ColorId], [Quantity], [Price], [ExtCharge], [UnitId], [OrderType], [Step], [AMTExcGST], [GST], [AMTIncGST], [ReceivedAMTExcGST], [ReceivedGST], [ReceivedAMTIncGST], [TotalAmount], [DeliveryNo], [DeliveryDate], [Received], [BackOrder], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (10, 1529592217856, 4, 3, 1, CAST(500.00 AS Decimal(18, 2)), 0, 1, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, CAST(N'2018-06-29T22:54:18.010' AS DateTime), NULL)
INSERT [dbo].[OrderComponent] ([Id], [OrderId], [ComponentId], [ColorId], [Quantity], [Price], [ExtCharge], [UnitId], [OrderType], [Step], [AMTExcGST], [GST], [AMTIncGST], [ReceivedAMTExcGST], [ReceivedGST], [ReceivedAMTIncGST], [TotalAmount], [DeliveryNo], [DeliveryDate], [Received], [BackOrder], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (11, 1530330251506, 1, 6, 1, CAST(5000.00 AS Decimal(18, 2)), 0, 5, NULL, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, CAST(N'2018-06-30T10:44:15.007' AS DateTime), NULL)
INSERT [dbo].[OrderComponent] ([Id], [OrderId], [ComponentId], [ColorId], [Quantity], [Price], [ExtCharge], [UnitId], [OrderType], [Step], [AMTExcGST], [GST], [AMTIncGST], [ReceivedAMTExcGST], [ReceivedGST], [ReceivedAMTIncGST], [TotalAmount], [DeliveryNo], [DeliveryDate], [Received], [BackOrder], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (12, 1530330251506, 1, 5, 1, CAST(900.00 AS Decimal(18, 2)), 0, 1, NULL, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, CAST(N'2018-06-30T10:44:15.007' AS DateTime), NULL)
INSERT [dbo].[OrderComponent] ([Id], [OrderId], [ComponentId], [ColorId], [Quantity], [Price], [ExtCharge], [UnitId], [OrderType], [Step], [AMTExcGST], [GST], [AMTIncGST], [ReceivedAMTExcGST], [ReceivedGST], [ReceivedAMTIncGST], [TotalAmount], [DeliveryNo], [DeliveryDate], [Received], [BackOrder], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (13, 1530331633177, 1, 6, 1, CAST(5000.00 AS Decimal(18, 2)), 0, 5, NULL, 1, CAST(5.00 AS Decimal(18, 2)), CAST(10.00 AS Decimal(18, 2)), CAST(5.00 AS Decimal(18, 2)), NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, CAST(N'2018-06-30T11:07:13.273' AS DateTime), CAST(N'2018-06-30T12:43:16.947' AS DateTime))
INSERT [dbo].[OrderComponent] ([Id], [OrderId], [ComponentId], [ColorId], [Quantity], [Price], [ExtCharge], [UnitId], [OrderType], [Step], [AMTExcGST], [GST], [AMTIncGST], [ReceivedAMTExcGST], [ReceivedGST], [ReceivedAMTIncGST], [TotalAmount], [DeliveryNo], [DeliveryDate], [Received], [BackOrder], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (14, 1530331633177, 1, 104, 1, CAST(4000.00 AS Decimal(18, 2)), 0, 1, NULL, 1, CAST(2.00 AS Decimal(18, 2)), CAST(3.00 AS Decimal(18, 2)), CAST(4.00 AS Decimal(18, 2)), NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, CAST(N'2018-06-30T12:43:36.917' AS DateTime), NULL)
INSERT [dbo].[OrderComponent] ([Id], [OrderId], [ComponentId], [ColorId], [Quantity], [Price], [ExtCharge], [UnitId], [OrderType], [Step], [AMTExcGST], [GST], [AMTIncGST], [ReceivedAMTExcGST], [ReceivedGST], [ReceivedAMTIncGST], [TotalAmount], [DeliveryNo], [DeliveryDate], [Received], [BackOrder], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (15, 1530360334538, 1, 3, 1, CAST(500.00 AS Decimal(18, 2)), 0, 1, NULL, 1, CAST(500.00 AS Decimal(18, 2)), CAST(35.00 AS Decimal(18, 2)), CAST(535.00 AS Decimal(18, 2)), CAST(500.00 AS Decimal(18, 2)), CAST(35.00 AS Decimal(18, 2)), CAST(535.00 AS Decimal(18, 2)), CAST(0.00 AS Numeric(18, 2)), NULL, CAST(N'2018-06-29T17:00:00.000' AS DateTime), 1, 0, NULL, NULL, CAST(N'2018-06-30T21:48:42.020' AS DateTime), CAST(N'2018-06-30T22:01:01.897' AS DateTime))
SET IDENTITY_INSERT [dbo].[OrderComponent] OFF
SET IDENTITY_INSERT [dbo].[OrderInvoice] ON 

INSERT [dbo].[OrderInvoice] ([Id], [OrderId], [InvoiceNo], [InvoiceDate], [InvoiceAmount], [CutLengthCharge], [DeliveryCharge], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1, 1529595111990, N'34567', CAST(N'2018-06-27T22:29:46.097' AS DateTime), CAST(3456.00 AS Decimal(18, 2)), NULL, N'ko biet', NULL, NULL, NULL, CAST(N'2018-06-27T22:29:46.097' AS DateTime), CAST(N'2018-06-27T23:05:35.820' AS DateTime))
INSERT [dbo].[OrderInvoice] ([Id], [OrderId], [InvoiceNo], [InvoiceDate], [InvoiceAmount], [CutLengthCharge], [DeliveryCharge], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2, 1529595111990, N'123abc', CAST(N'2018-06-27T22:30:15.030' AS DateTime), CAST(345.00 AS Decimal(18, 2)), NULL, NULL, NULL, NULL, NULL, CAST(N'2018-06-27T22:30:15.030' AS DateTime), CAST(N'2018-06-27T22:57:46.193' AS DateTime))
INSERT [dbo].[OrderInvoice] ([Id], [OrderId], [InvoiceNo], [InvoiceDate], [InvoiceAmount], [CutLengthCharge], [DeliveryCharge], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3, 1529592217856, N'2143', CAST(N'2018-06-29T22:56:45.680' AS DateTime), CAST(500.00 AS Decimal(18, 2)), NULL, NULL, NULL, NULL, NULL, CAST(N'2018-06-29T22:56:45.680' AS DateTime), NULL)
SET IDENTITY_INSERT [dbo].[OrderInvoice] OFF
SET IDENTITY_INSERT [dbo].[OrderPayment] ON 

INSERT [dbo].[OrderPayment] ([Id], [OrderId], [DatePaid], [PaymentType], [AmountPaid], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1, 1529595111990, CAST(N'2018-06-27T22:00:33.330' AS DateTime), N'Check', CAST(234.00 AS Decimal(18, 2)), NULL, NULL, NULL, CAST(N'2018-06-27T22:00:33.330' AS DateTime), CAST(N'2018-06-27T22:18:20.137' AS DateTime))
INSERT [dbo].[OrderPayment] ([Id], [OrderId], [DatePaid], [PaymentType], [AmountPaid], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3, 1529595111990, CAST(N'2018-06-27T22:29:26.327' AS DateTime), N'Credit Card', CAST(333.00 AS Decimal(18, 2)), NULL, NULL, NULL, CAST(N'2018-06-27T22:29:26.327' AS DateTime), NULL)
INSERT [dbo].[OrderPayment] ([Id], [OrderId], [DatePaid], [PaymentType], [AmountPaid], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4, 1529592217856, CAST(N'2018-06-29T22:56:53.560' AS DateTime), N'Cash', CAST(300.00 AS Decimal(18, 2)), NULL, NULL, NULL, CAST(N'2018-06-29T22:56:53.560' AS DateTime), NULL)
INSERT [dbo].[OrderPayment] ([Id], [OrderId], [DatePaid], [PaymentType], [AmountPaid], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (7, 1530331633177, CAST(N'2018-06-30T18:18:26.123' AS DateTime), N'Check', CAST(9000.00 AS Decimal(18, 2)), NULL, NULL, NULL, CAST(N'2018-06-30T18:18:26.123' AS DateTime), NULL)
INSERT [dbo].[OrderPayment] ([Id], [OrderId], [DatePaid], [PaymentType], [AmountPaid], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (8, 1530331633177, CAST(N'2018-06-30T18:18:43.273' AS DateTime), N'Cash', CAST(10000.00 AS Decimal(18, 2)), NULL, NULL, NULL, CAST(N'2018-06-30T18:18:43.273' AS DateTime), NULL)
SET IDENTITY_INSERT [dbo].[OrderPayment] OFF
SET IDENTITY_INSERT [dbo].[OrderProduct] ON 

INSERT [dbo].[OrderProduct] ([Id], [OrderId], [ProductId], [MaterialId], [LocationId], [ColorId], [ControlSideId], [UnitId], [Drop], [Width], [Quantity], [Discount], [ExtendPrice], [UnitPrice], [TotalAmount], [DeliveryNo], [DeliveryDate], [Received], [BackOrder], [OrderType], [Step], [AMTExcGST], [GST], [AMTIncGST], [ReceivedAMTExcGST], [ReceivedGST], [ReceivedAMTIncGST], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1, 1529595111990, 1, 4, 1, 1, 1, 1, 2, 3, 2, 0, CAST(0.00 AS Numeric(18, 2)), CAST(4000.00 AS Numeric(18, 2)), CAST(8000.00 AS Numeric(18, 2)), NULL, NULL, 0, 2, NULL, 2, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, CAST(N'2018-06-25T21:28:10.287' AS DateTime), CAST(N'2018-06-30T11:00:43.423' AS DateTime))
INSERT [dbo].[OrderProduct] ([Id], [OrderId], [ProductId], [MaterialId], [LocationId], [ColorId], [ControlSideId], [UnitId], [Drop], [Width], [Quantity], [Discount], [ExtendPrice], [UnitPrice], [TotalAmount], [DeliveryNo], [DeliveryDate], [Received], [BackOrder], [OrderType], [Step], [AMTExcGST], [GST], [AMTIncGST], [ReceivedAMTExcGST], [ReceivedGST], [ReceivedAMTIncGST], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2, 1529595111990, 2, 4, 1, 1, 4, 1, 1, 2, 2, 4, CAST(0.00 AS Numeric(18, 2)), CAST(2.00 AS Numeric(18, 2)), CAST(4.00 AS Numeric(18, 2)), NULL, NULL, 0, 2, NULL, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, CAST(N'2018-06-25T22:26:06.050' AS DateTime), CAST(N'2018-06-25T22:37:35.543' AS DateTime))
INSERT [dbo].[OrderProduct] ([Id], [OrderId], [ProductId], [MaterialId], [LocationId], [ColorId], [ControlSideId], [UnitId], [Drop], [Width], [Quantity], [Discount], [ExtendPrice], [UnitPrice], [TotalAmount], [DeliveryNo], [DeliveryDate], [Received], [BackOrder], [OrderType], [Step], [AMTExcGST], [GST], [AMTIncGST], [ReceivedAMTExcGST], [ReceivedGST], [ReceivedAMTIncGST], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (3, 1529592217856, 2, 2, 1, 1, 1, 1, 2, 3, 3, 0, CAST(0.00 AS Numeric(18, 2)), CAST(3.00 AS Numeric(18, 2)), CAST(9.00 AS Numeric(18, 2)), NULL, NULL, 0, 3, NULL, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, CAST(N'2018-06-27T23:33:58.537' AS DateTime), CAST(N'2018-06-29T22:54:50.070' AS DateTime))
INSERT [dbo].[OrderProduct] ([Id], [OrderId], [ProductId], [MaterialId], [LocationId], [ColorId], [ControlSideId], [UnitId], [Drop], [Width], [Quantity], [Discount], [ExtendPrice], [UnitPrice], [TotalAmount], [DeliveryNo], [DeliveryDate], [Received], [BackOrder], [OrderType], [Step], [AMTExcGST], [GST], [AMTIncGST], [ReceivedAMTExcGST], [ReceivedGST], [ReceivedAMTIncGST], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4, 1529590581377, 2, 4, 1, 1, 1, 1, 1, 2, 2, 0, CAST(0.00 AS Numeric(18, 2)), CAST(0.00 AS Numeric(18, 2)), CAST(0.00 AS Numeric(18, 2)), NULL, NULL, 0, 2, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, CAST(N'2018-06-29T22:46:37.260' AS DateTime), CAST(N'2018-06-29T22:52:08.097' AS DateTime))
INSERT [dbo].[OrderProduct] ([Id], [OrderId], [ProductId], [MaterialId], [LocationId], [ColorId], [ControlSideId], [UnitId], [Drop], [Width], [Quantity], [Discount], [ExtendPrice], [UnitPrice], [TotalAmount], [DeliveryNo], [DeliveryDate], [Received], [BackOrder], [OrderType], [Step], [AMTExcGST], [GST], [AMTIncGST], [ReceivedAMTExcGST], [ReceivedGST], [ReceivedAMTIncGST], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (5, 1530330251506, 1, 2, 1, 1, 1, 1, 2, 3, 2, 0, CAST(0.00 AS Numeric(18, 2)), CAST(4.00 AS Numeric(18, 2)), CAST(8.00 AS Numeric(18, 2)), NULL, NULL, 0, 2, NULL, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, CAST(N'2018-06-30T10:44:15.010' AS DateTime), NULL)
INSERT [dbo].[OrderProduct] ([Id], [OrderId], [ProductId], [MaterialId], [LocationId], [ColorId], [ControlSideId], [UnitId], [Drop], [Width], [Quantity], [Discount], [ExtendPrice], [UnitPrice], [TotalAmount], [DeliveryNo], [DeliveryDate], [Received], [BackOrder], [OrderType], [Step], [AMTExcGST], [GST], [AMTIncGST], [ReceivedAMTExcGST], [ReceivedGST], [ReceivedAMTIncGST], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (6, 1530330251506, 2, 4, 1, 1, 4, 1, 1, 2, 2, 4, CAST(0.00 AS Numeric(18, 2)), CAST(2.00 AS Numeric(18, 2)), CAST(4.00 AS Numeric(18, 2)), NULL, NULL, 0, 2, NULL, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, CAST(N'2018-06-30T10:44:15.010' AS DateTime), NULL)
INSERT [dbo].[OrderProduct] ([Id], [OrderId], [ProductId], [MaterialId], [LocationId], [ColorId], [ControlSideId], [UnitId], [Drop], [Width], [Quantity], [Discount], [ExtendPrice], [UnitPrice], [TotalAmount], [DeliveryNo], [DeliveryDate], [Received], [BackOrder], [OrderType], [Step], [AMTExcGST], [GST], [AMTIncGST], [ReceivedAMTExcGST], [ReceivedGST], [ReceivedAMTIncGST], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (7, 1530330437904, 2, 2, 1, 1, 1, 1, 2, 3, 3, 0, CAST(0.00 AS Numeric(18, 2)), CAST(3.00 AS Numeric(18, 2)), CAST(9.00 AS Numeric(18, 2)), NULL, NULL, 0, 3, NULL, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, CAST(N'2018-06-30T10:47:18.007' AS DateTime), NULL)
INSERT [dbo].[OrderProduct] ([Id], [OrderId], [ProductId], [MaterialId], [LocationId], [ColorId], [ControlSideId], [UnitId], [Drop], [Width], [Quantity], [Discount], [ExtendPrice], [UnitPrice], [TotalAmount], [DeliveryNo], [DeliveryDate], [Received], [BackOrder], [OrderType], [Step], [AMTExcGST], [GST], [AMTIncGST], [ReceivedAMTExcGST], [ReceivedGST], [ReceivedAMTIncGST], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (8, 1530330652517, 2, 2, 1, 1, 1, 1, 2, 3, 3, 0, CAST(0.00 AS Numeric(18, 2)), CAST(3.00 AS Numeric(18, 2)), CAST(9.00 AS Numeric(18, 2)), NULL, NULL, 0, 3, NULL, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, CAST(N'2018-06-30T10:50:52.620' AS DateTime), NULL)
INSERT [dbo].[OrderProduct] ([Id], [OrderId], [ProductId], [MaterialId], [LocationId], [ColorId], [ControlSideId], [UnitId], [Drop], [Width], [Quantity], [Discount], [ExtendPrice], [UnitPrice], [TotalAmount], [DeliveryNo], [DeliveryDate], [Received], [BackOrder], [OrderType], [Step], [AMTExcGST], [GST], [AMTIncGST], [ReceivedAMTExcGST], [ReceivedGST], [ReceivedAMTIncGST], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (9, 1530330861321, 2, 2, 1, 1, 1, 1, 2, 3, 3, 0, CAST(0.00 AS Numeric(18, 2)), CAST(3.00 AS Numeric(18, 2)), CAST(9.00 AS Numeric(18, 2)), NULL, NULL, 0, 3, NULL, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, CAST(N'2018-06-30T10:54:21.417' AS DateTime), NULL)
INSERT [dbo].[OrderProduct] ([Id], [OrderId], [ProductId], [MaterialId], [LocationId], [ColorId], [ControlSideId], [UnitId], [Drop], [Width], [Quantity], [Discount], [ExtendPrice], [UnitPrice], [TotalAmount], [DeliveryNo], [DeliveryDate], [Received], [BackOrder], [OrderType], [Step], [AMTExcGST], [GST], [AMTIncGST], [ReceivedAMTExcGST], [ReceivedGST], [ReceivedAMTIncGST], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (10, 1530330946656, 2, 2, 1, 1, 1, 1, 2, 3, 3, 0, CAST(0.00 AS Numeric(18, 2)), CAST(3.00 AS Numeric(18, 2)), CAST(9.00 AS Numeric(18, 2)), NULL, NULL, 0, 3, NULL, 6, CAST(0.00 AS Decimal(18, 2)), CAST(0.00 AS Decimal(18, 2)), CAST(0.00 AS Decimal(18, 2)), NULL, NULL, NULL, NULL, NULL, NULL, CAST(N'2018-06-30T10:55:46.777' AS DateTime), CAST(N'2018-06-30T14:02:05.113' AS DateTime))
INSERT [dbo].[OrderProduct] ([Id], [OrderId], [ProductId], [MaterialId], [LocationId], [ColorId], [ControlSideId], [UnitId], [Drop], [Width], [Quantity], [Discount], [ExtendPrice], [UnitPrice], [TotalAmount], [DeliveryNo], [DeliveryDate], [Received], [BackOrder], [OrderType], [Step], [AMTExcGST], [GST], [AMTIncGST], [ReceivedAMTExcGST], [ReceivedGST], [ReceivedAMTIncGST], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (11, 1530331633177, 2, 4, 1, 1, 4, 1, 1, 2, 2, 4, CAST(0.00 AS Numeric(18, 2)), CAST(0.00 AS Numeric(18, 2)), CAST(0.00 AS Numeric(18, 2)), NULL, NULL, 1, 1, NULL, 1, CAST(0.00 AS Decimal(18, 2)), CAST(5.00 AS Decimal(18, 2)), CAST(0.00 AS Decimal(18, 2)), CAST(0.00 AS Decimal(18, 2)), CAST(0.00 AS Decimal(18, 2)), CAST(0.00 AS Decimal(18, 2)), NULL, NULL, NULL, CAST(N'2018-06-30T11:07:13.273' AS DateTime), CAST(N'2018-06-30T19:04:54.127' AS DateTime))
INSERT [dbo].[OrderProduct] ([Id], [OrderId], [ProductId], [MaterialId], [LocationId], [ColorId], [ControlSideId], [UnitId], [Drop], [Width], [Quantity], [Discount], [ExtendPrice], [UnitPrice], [TotalAmount], [DeliveryNo], [DeliveryDate], [Received], [BackOrder], [OrderType], [Step], [AMTExcGST], [GST], [AMTIncGST], [ReceivedAMTExcGST], [ReceivedGST], [ReceivedAMTIncGST], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (12, 1530331633177, 1, 5, 1, 1, 1, 1, 1, 1, 1, 0, CAST(0.00 AS Numeric(18, 2)), CAST(3000.00 AS Numeric(18, 2)), CAST(3000.00 AS Numeric(18, 2)), NULL, NULL, 0, 1, NULL, 1, CAST(2.00 AS Decimal(18, 2)), CAST(5.00 AS Decimal(18, 2)), CAST(10.00 AS Decimal(18, 2)), NULL, NULL, NULL, NULL, NULL, NULL, CAST(N'2018-06-30T12:42:20.607' AS DateTime), NULL)
INSERT [dbo].[OrderProduct] ([Id], [OrderId], [ProductId], [MaterialId], [LocationId], [ColorId], [ControlSideId], [UnitId], [Drop], [Width], [Quantity], [Discount], [ExtendPrice], [UnitPrice], [TotalAmount], [DeliveryNo], [DeliveryDate], [Received], [BackOrder], [OrderType], [Step], [AMTExcGST], [GST], [AMTIncGST], [ReceivedAMTExcGST], [ReceivedGST], [ReceivedAMTIncGST], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (13, 1530330437904, 1, 5, 1, 1, 1, 1, 2, 3, 2, 0, CAST(0.00 AS Numeric(18, 2)), CAST(4000.00 AS Numeric(18, 2)), CAST(8000.00 AS Numeric(18, 2)), NULL, NULL, 0, 0, NULL, 1, CAST(0.00 AS Decimal(18, 2)), CAST(5.00 AS Decimal(18, 2)), CAST(0.00 AS Decimal(18, 2)), NULL, NULL, NULL, NULL, NULL, NULL, CAST(N'2018-06-30T13:04:17.027' AS DateTime), NULL)
INSERT [dbo].[OrderProduct] ([Id], [OrderId], [ProductId], [MaterialId], [LocationId], [ColorId], [ControlSideId], [UnitId], [Drop], [Width], [Quantity], [Discount], [ExtendPrice], [UnitPrice], [TotalAmount], [DeliveryNo], [DeliveryDate], [Received], [BackOrder], [OrderType], [Step], [AMTExcGST], [GST], [AMTIncGST], [ReceivedAMTExcGST], [ReceivedGST], [ReceivedAMTIncGST], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (14, 1530360311814, 2, 4, 1, 1, 4, 1, 1, 2, 1, 4, CAST(0.00 AS Numeric(18, 2)), CAST(3000.00 AS Numeric(18, 2)), CAST(3000.00 AS Numeric(18, 2)), NULL, NULL, 2, -1, NULL, 1, CAST(0.00 AS Decimal(18, 2)), CAST(5.00 AS Decimal(18, 2)), CAST(0.00 AS Decimal(18, 2)), CAST(0.00 AS Decimal(18, 2)), CAST(0.00 AS Decimal(18, 2)), CAST(0.00 AS Decimal(18, 2)), NULL, NULL, NULL, CAST(N'2018-06-30T19:05:11.897' AS DateTime), CAST(N'2018-06-30T19:06:08.543' AS DateTime))
INSERT [dbo].[OrderProduct] ([Id], [OrderId], [ProductId], [MaterialId], [LocationId], [ColorId], [ControlSideId], [UnitId], [Drop], [Width], [Quantity], [Discount], [ExtendPrice], [UnitPrice], [TotalAmount], [DeliveryNo], [DeliveryDate], [Received], [BackOrder], [OrderType], [Step], [AMTExcGST], [GST], [AMTIncGST], [ReceivedAMTExcGST], [ReceivedGST], [ReceivedAMTIncGST], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (15, 1530360311814, 1, 5, 1, 1, 1, 1, 1, 1, 1, 0, CAST(0.00 AS Numeric(18, 2)), CAST(3000.00 AS Numeric(18, 2)), CAST(3000.00 AS Numeric(18, 2)), NULL, NULL, 0, 1, NULL, 1, CAST(2.00 AS Decimal(18, 2)), CAST(5.00 AS Decimal(18, 2)), CAST(10.00 AS Decimal(18, 2)), CAST(0.00 AS Decimal(18, 2)), CAST(0.00 AS Decimal(18, 2)), CAST(0.00 AS Decimal(18, 2)), NULL, NULL, NULL, CAST(N'2018-06-30T19:05:11.897' AS DateTime), CAST(N'2018-06-30T19:06:43.067' AS DateTime))
INSERT [dbo].[OrderProduct] ([Id], [OrderId], [ProductId], [MaterialId], [LocationId], [ColorId], [ControlSideId], [UnitId], [Drop], [Width], [Quantity], [Discount], [ExtendPrice], [UnitPrice], [TotalAmount], [DeliveryNo], [DeliveryDate], [Received], [BackOrder], [OrderType], [Step], [AMTExcGST], [GST], [AMTIncGST], [ReceivedAMTExcGST], [ReceivedGST], [ReceivedAMTIncGST], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (16, 1530360334538, 1, 5, 1, 1, 1, 1, 1, 1, 1, 0, CAST(0.00 AS Numeric(18, 2)), CAST(3000.00 AS Numeric(18, 2)), CAST(3000.00 AS Numeric(18, 2)), N'123456', CAST(N'2018-06-28T17:00:00.000' AS DateTime), 1, 0, NULL, 1, CAST(3000.00 AS Decimal(18, 2)), CAST(210.00 AS Decimal(18, 2)), CAST(3210.00 AS Decimal(18, 2)), CAST(3000.00 AS Decimal(18, 2)), CAST(210.00 AS Decimal(18, 2)), CAST(3210.00 AS Decimal(18, 2)), NULL, NULL, NULL, CAST(N'2018-06-30T19:05:34.597' AS DateTime), CAST(N'2018-06-30T23:08:12.993' AS DateTime))
INSERT [dbo].[OrderProduct] ([Id], [OrderId], [ProductId], [MaterialId], [LocationId], [ColorId], [ControlSideId], [UnitId], [Drop], [Width], [Quantity], [Discount], [ExtendPrice], [UnitPrice], [TotalAmount], [DeliveryNo], [DeliveryDate], [Received], [BackOrder], [OrderType], [Step], [AMTExcGST], [GST], [AMTIncGST], [ReceivedAMTExcGST], [ReceivedGST], [ReceivedAMTIncGST], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (17, 1530360334538, 1, 4, 1, 1, 1, 1, 1, 2, 2, 0, CAST(0.00 AS Numeric(18, 2)), CAST(4000.00 AS Numeric(18, 2)), CAST(8000.00 AS Numeric(18, 2)), N'123abc', CAST(N'2018-06-29T17:00:00.000' AS DateTime), 1, 1, NULL, 1, CAST(8000.00 AS Decimal(18, 2)), CAST(720.00 AS Decimal(18, 2)), CAST(8720.00 AS Decimal(18, 2)), CAST(4000.00 AS Decimal(18, 2)), CAST(360.00 AS Decimal(18, 2)), CAST(4360.00 AS Decimal(18, 2)), NULL, NULL, NULL, CAST(N'2018-06-30T20:01:05.057' AS DateTime), CAST(N'2018-06-30T21:59:13.200' AS DateTime))
SET IDENTITY_INSERT [dbo].[OrderProduct] OFF
SET IDENTITY_INSERT [dbo].[Product] ON 

INSERT [dbo].[Product] ([Id], [ProductCode], [ProductName], [CategoryId], [Notes], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1, N'BWCP00001', N'ROLLER BLIND – BWC', 2, N'ROLLER BLIND - Produce by BWC', 1, NULL, NULL, CAST(N'2018-06-14T23:12:21.447' AS DateTime), CAST(N'2018-06-30T23:15:44.353' AS DateTime))
INSERT [dbo].[Product] ([Id], [ProductCode], [ProductName], [CategoryId], [Notes], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2, N'ACMEDA00002', N'ROLLER BLIND – ACMEDA', 1, N'ROLLER BLIND – Product by ACMEDA', 1, NULL, NULL, CAST(N'2018-06-18T22:58:59.757' AS DateTime), CAST(N'2018-06-30T23:12:16.633' AS DateTime))
SET IDENTITY_INSERT [dbo].[Product] OFF
SET IDENTITY_INSERT [dbo].[ProductComponent] ON 

INSERT [dbo].[ProductComponent] ([Id], [ProductId], [ComponentId], [ColorId], [Quantity], [Price], [ExtCharge], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (2, 1, 4, 3, 2, CAST(5000.00 AS Decimal(18, 2)), 1, NULL, NULL, CAST(N'2018-06-16T17:57:38.873' AS DateTime), CAST(N'2018-06-17T22:26:29.660' AS DateTime))
INSERT [dbo].[ProductComponent] ([Id], [ProductId], [ComponentId], [ColorId], [Quantity], [Price], [ExtCharge], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (9, 1, 1, 1, 4, CAST(2222.00 AS Decimal(18, 2)), 0, NULL, NULL, CAST(N'2018-06-16T20:13:26.663' AS DateTime), CAST(N'2018-06-17T21:06:27.430' AS DateTime))
INSERT [dbo].[ProductComponent] ([Id], [ProductId], [ComponentId], [ColorId], [Quantity], [Price], [ExtCharge], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (10, 0, 1, 1, 2, CAST(12314.00 AS Decimal(18, 2)), 1, NULL, NULL, CAST(N'2018-06-17T21:05:57.227' AS DateTime), NULL)
INSERT [dbo].[ProductComponent] ([Id], [ProductId], [ComponentId], [ColorId], [Quantity], [Price], [ExtCharge], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (12, 0, 1, 1, 1, CAST(0.00 AS Decimal(18, 2)), 0, NULL, NULL, CAST(N'2018-06-18T22:59:30.843' AS DateTime), NULL)
INSERT [dbo].[ProductComponent] ([Id], [ProductId], [ComponentId], [ColorId], [Quantity], [Price], [ExtCharge], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (13, 0, 1, 1, 1, CAST(0.00 AS Decimal(18, 2)), 0, NULL, NULL, CAST(N'2018-06-18T23:03:36.320' AS DateTime), NULL)
INSERT [dbo].[ProductComponent] ([Id], [ProductId], [ComponentId], [ColorId], [Quantity], [Price], [ExtCharge], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (14, 0, 1, 2, 3, CAST(0.00 AS Decimal(18, 2)), 0, NULL, NULL, CAST(N'2018-06-18T23:04:38.840' AS DateTime), NULL)
INSERT [dbo].[ProductComponent] ([Id], [ProductId], [ComponentId], [ColorId], [Quantity], [Price], [ExtCharge], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (15, 0, 1, 1, 1, CAST(0.00 AS Decimal(18, 2)), 0, NULL, NULL, CAST(N'2018-06-18T23:07:37.513' AS DateTime), NULL)
INSERT [dbo].[ProductComponent] ([Id], [ProductId], [ComponentId], [ColorId], [Quantity], [Price], [ExtCharge], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (16, 0, 1, 2, 2, CAST(0.00 AS Decimal(18, 2)), 0, NULL, NULL, CAST(N'2018-06-18T23:09:03.423' AS DateTime), NULL)
INSERT [dbo].[ProductComponent] ([Id], [ProductId], [ComponentId], [ColorId], [Quantity], [Price], [ExtCharge], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (17, 2, 1, 2, 1, CAST(0.00 AS Decimal(18, 2)), 0, NULL, NULL, CAST(N'2018-06-18T23:10:47.840' AS DateTime), CAST(N'2018-06-25T16:32:04.880' AS DateTime))
INSERT [dbo].[ProductComponent] ([Id], [ProductId], [ComponentId], [ColorId], [Quantity], [Price], [ExtCharge], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (18, 2, 4, 5, 1, CAST(23123.00 AS Decimal(18, 2)), 1, NULL, NULL, CAST(N'2018-06-25T16:30:07.797' AS DateTime), NULL)
SET IDENTITY_INSERT [dbo].[ProductComponent] OFF
SET IDENTITY_INSERT [dbo].[ProductMaterial] ON 

INSERT [dbo].[ProductMaterial] ([Id], [ProductId], [MaterialId], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (6, 1, 2, NULL, NULL, CAST(N'2018-06-16T18:07:40.430' AS DateTime), NULL)
INSERT [dbo].[ProductMaterial] ([Id], [ProductId], [MaterialId], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (7, 1, 4, NULL, NULL, CAST(N'2018-06-17T21:05:30.253' AS DateTime), NULL)
INSERT [dbo].[ProductMaterial] ([Id], [ProductId], [MaterialId], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (8, 2, 2, NULL, NULL, CAST(N'2018-06-18T23:05:53.350' AS DateTime), NULL)
INSERT [dbo].[ProductMaterial] ([Id], [ProductId], [MaterialId], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (9, 2, 4, NULL, NULL, CAST(N'2018-06-18T23:08:41.447' AS DateTime), NULL)
INSERT [dbo].[ProductMaterial] ([Id], [ProductId], [MaterialId], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (10, 1, 5, NULL, NULL, CAST(N'2018-06-25T17:37:17.557' AS DateTime), NULL)
INSERT [dbo].[ProductMaterial] ([Id], [ProductId], [MaterialId], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (11, 2, 5, NULL, NULL, CAST(N'2018-06-30T23:52:09.460' AS DateTime), NULL)
SET IDENTITY_INSERT [dbo].[ProductMaterial] OFF
SET IDENTITY_INSERT [dbo].[ProductPrice] ON 

INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (144, 3, 1, 1, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, NULL, CAST(N'2018-06-17T16:12:21.873' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (145, 3, 2, 1, CAST(100.00 AS Decimal(18, 2)), NULL, NULL, NULL, CAST(N'2018-06-17T16:12:21.873' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (146, 3, 3, 1, CAST(200.00 AS Decimal(18, 2)), NULL, NULL, NULL, CAST(N'2018-06-17T16:12:21.873' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (147, 3, 4, 1, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, NULL, CAST(N'2018-06-17T16:12:21.873' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (148, 3, 5, 1, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, NULL, CAST(N'2018-06-17T16:12:21.873' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (149, 3, 6, 1, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, NULL, CAST(N'2018-06-17T16:12:21.873' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (150, 3, 7, 1, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, NULL, CAST(N'2018-06-17T16:12:21.873' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (151, 3, 8, 1, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, NULL, CAST(N'2018-06-17T16:12:21.873' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (152, 3, 9, 1, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, NULL, CAST(N'2018-06-17T16:12:21.873' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (153, 3, 10, 1, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, NULL, CAST(N'2018-06-17T16:12:21.873' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (154, 3, 11, 1, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, NULL, CAST(N'2018-06-17T16:12:21.873' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (155, 3, 1, 2, CAST(100.00 AS Decimal(18, 2)), NULL, NULL, NULL, CAST(N'2018-06-17T16:12:21.873' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (156, 3, 2, 2, CAST(30000.00 AS Decimal(18, 2)), NULL, NULL, NULL, CAST(N'2018-06-17T16:12:21.873' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (157, 3, 3, 2, CAST(40000.00 AS Decimal(18, 2)), NULL, NULL, NULL, CAST(N'2018-06-17T16:12:21.873' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (158, 3, 4, 2, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, NULL, CAST(N'2018-06-17T16:12:21.873' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (159, 3, 5, 2, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, NULL, CAST(N'2018-06-17T16:12:21.873' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (160, 3, 6, 2, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, NULL, CAST(N'2018-06-17T16:12:21.873' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (161, 3, 7, 2, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, NULL, CAST(N'2018-06-17T16:12:21.873' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (162, 3, 8, 2, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, NULL, CAST(N'2018-06-17T16:12:21.873' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (163, 3, 9, 2, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, NULL, CAST(N'2018-06-17T16:12:21.873' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (164, 3, 10, 2, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, NULL, CAST(N'2018-06-17T16:12:21.873' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (165, 3, 11, 2, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, NULL, CAST(N'2018-06-17T16:12:21.873' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (166, 3, 1, 3, CAST(200.00 AS Decimal(18, 2)), NULL, NULL, NULL, CAST(N'2018-06-17T16:12:21.873' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (167, 3, 2, 3, CAST(40000.00 AS Decimal(18, 2)), NULL, NULL, NULL, CAST(N'2018-06-17T16:12:21.873' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (168, 3, 3, 3, CAST(50000.00 AS Decimal(18, 2)), NULL, NULL, NULL, CAST(N'2018-06-17T16:12:21.873' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (169, 3, 4, 3, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, NULL, CAST(N'2018-06-17T16:12:21.873' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (170, 3, 5, 3, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, NULL, CAST(N'2018-06-17T16:12:21.873' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (171, 3, 6, 3, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, NULL, CAST(N'2018-06-17T16:12:21.873' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (172, 3, 7, 3, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, NULL, CAST(N'2018-06-17T16:12:21.873' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (173, 3, 8, 3, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, NULL, CAST(N'2018-06-17T16:12:21.873' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (174, 3, 9, 3, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, NULL, CAST(N'2018-06-17T16:12:21.873' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (175, 3, 10, 3, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, NULL, CAST(N'2018-06-17T16:12:21.873' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (176, 3, 11, 3, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, NULL, CAST(N'2018-06-17T16:12:21.873' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (177, 3, 1, 4, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, NULL, CAST(N'2018-06-17T16:12:21.873' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (178, 3, 2, 4, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, NULL, CAST(N'2018-06-17T16:12:21.873' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (179, 3, 3, 4, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, NULL, CAST(N'2018-06-17T16:12:21.873' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (180, 3, 4, 4, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, NULL, CAST(N'2018-06-17T16:12:21.873' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (181, 3, 5, 4, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, NULL, CAST(N'2018-06-17T16:12:21.873' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (182, 3, 6, 4, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, NULL, CAST(N'2018-06-17T16:12:21.873' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (183, 3, 7, 4, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, NULL, CAST(N'2018-06-17T16:12:21.873' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (184, 3, 8, 4, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, NULL, CAST(N'2018-06-17T16:12:21.873' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (185, 3, 9, 4, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, NULL, CAST(N'2018-06-17T16:12:21.873' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (186, 3, 10, 4, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, NULL, CAST(N'2018-06-17T16:12:21.873' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (187, 3, 11, 4, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, NULL, CAST(N'2018-06-17T16:12:21.873' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (188, 3, 1, 5, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, NULL, CAST(N'2018-06-17T16:12:21.873' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (189, 3, 2, 5, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, NULL, CAST(N'2018-06-17T16:12:21.873' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (190, 3, 3, 5, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, NULL, CAST(N'2018-06-17T16:12:21.873' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (191, 3, 4, 5, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, NULL, CAST(N'2018-06-17T16:12:21.873' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (192, 3, 5, 5, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, NULL, CAST(N'2018-06-17T16:12:21.873' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (193, 3, 6, 5, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, NULL, CAST(N'2018-06-17T16:12:21.873' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (194, 3, 7, 5, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, NULL, CAST(N'2018-06-17T16:12:21.873' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (195, 3, 8, 5, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, NULL, CAST(N'2018-06-17T16:12:21.873' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (196, 3, 9, 5, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, NULL, CAST(N'2018-06-17T16:12:21.873' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (197, 3, 10, 5, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, NULL, CAST(N'2018-06-17T16:12:21.873' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (198, 3, 11, 5, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, NULL, CAST(N'2018-06-17T16:12:21.873' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (199, 3, 1, 6, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, NULL, CAST(N'2018-06-17T16:12:21.873' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (200, 3, 2, 6, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, NULL, CAST(N'2018-06-17T16:12:21.873' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (201, 3, 3, 6, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, NULL, CAST(N'2018-06-17T16:12:21.873' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (202, 3, 4, 6, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, NULL, CAST(N'2018-06-17T16:12:21.873' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (203, 3, 5, 6, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, NULL, CAST(N'2018-06-17T16:12:21.873' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (204, 3, 6, 6, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, NULL, CAST(N'2018-06-17T16:12:21.873' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (205, 3, 7, 6, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, NULL, CAST(N'2018-06-17T16:12:21.873' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (206, 3, 8, 6, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, NULL, CAST(N'2018-06-17T16:12:21.873' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (207, 3, 9, 6, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, NULL, CAST(N'2018-06-17T16:12:21.873' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (208, 3, 10, 6, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, NULL, CAST(N'2018-06-17T16:12:21.873' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (209, 3, 11, 6, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, NULL, CAST(N'2018-06-17T16:12:21.873' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (210, 3, 1, 7, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, NULL, CAST(N'2018-06-17T16:12:21.873' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (211, 3, 2, 7, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, NULL, CAST(N'2018-06-17T16:12:21.873' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (212, 3, 3, 7, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, NULL, CAST(N'2018-06-17T16:12:21.873' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (213, 3, 4, 7, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, NULL, CAST(N'2018-06-17T16:12:21.873' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (214, 3, 5, 7, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, NULL, CAST(N'2018-06-17T16:12:21.873' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (215, 3, 6, 7, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, NULL, CAST(N'2018-06-17T16:12:21.873' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (216, 3, 7, 7, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, NULL, CAST(N'2018-06-17T16:12:21.873' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (217, 3, 8, 7, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, NULL, CAST(N'2018-06-17T16:12:21.873' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (218, 3, 9, 7, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, NULL, CAST(N'2018-06-17T16:12:21.873' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (219, 3, 10, 7, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, NULL, CAST(N'2018-06-17T16:12:21.873' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (220, 3, 11, 7, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, NULL, CAST(N'2018-06-17T16:12:21.873' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (221, 3, 1, 8, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, NULL, CAST(N'2018-06-17T16:12:21.873' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (222, 3, 2, 8, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, NULL, CAST(N'2018-06-17T16:12:21.873' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (223, 3, 3, 8, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, NULL, CAST(N'2018-06-17T16:12:21.873' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (224, 3, 4, 8, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, NULL, CAST(N'2018-06-17T16:12:21.873' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (225, 3, 5, 8, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, NULL, CAST(N'2018-06-17T16:12:21.873' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (226, 3, 6, 8, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, NULL, CAST(N'2018-06-17T16:12:21.873' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (227, 3, 7, 8, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, NULL, CAST(N'2018-06-17T16:12:21.873' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (228, 3, 8, 8, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, NULL, CAST(N'2018-06-17T16:12:21.873' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (229, 3, 9, 8, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, NULL, CAST(N'2018-06-17T16:12:21.873' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (230, 3, 10, 8, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, NULL, CAST(N'2018-06-17T16:12:21.873' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (231, 3, 11, 8, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, NULL, CAST(N'2018-06-17T16:12:21.873' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (297, 5, 1, 1, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-06-17T22:25:53.953' AS DateTime), CAST(N'2018-06-17T22:25:53.953' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (298, 5, 2, 1, CAST(1.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-06-17T22:25:53.953' AS DateTime), CAST(N'2018-06-17T22:25:53.953' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (299, 5, 3, 1, CAST(2.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-06-17T22:25:53.953' AS DateTime), CAST(N'2018-06-17T22:25:53.953' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (300, 5, 4, 1, CAST(3.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-06-17T22:25:53.953' AS DateTime), CAST(N'2018-06-17T22:25:53.953' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (301, 5, 5, 1, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-06-17T22:25:53.953' AS DateTime), CAST(N'2018-06-17T22:25:53.953' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (302, 5, 1, 2, CAST(1.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-06-17T22:25:53.953' AS DateTime), CAST(N'2018-06-17T22:25:53.953' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (303, 5, 2, 2, CAST(2.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-06-17T22:25:53.953' AS DateTime), CAST(N'2018-06-17T22:25:53.953' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (304, 5, 3, 2, CAST(3.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-06-17T22:25:53.953' AS DateTime), CAST(N'2018-06-17T22:25:53.953' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (305, 5, 4, 2, CAST(4.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-06-17T22:25:53.953' AS DateTime), CAST(N'2018-06-17T22:25:53.953' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (306, 5, 5, 2, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-06-17T22:25:53.953' AS DateTime), CAST(N'2018-06-17T22:25:53.953' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (307, 5, 1, 3, CAST(2.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-06-17T22:25:53.953' AS DateTime), CAST(N'2018-06-17T22:25:53.953' AS DateTime))
GO
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (308, 5, 2, 3, CAST(3.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-06-17T22:25:53.953' AS DateTime), CAST(N'2018-06-17T22:25:53.953' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (309, 5, 3, 3, CAST(4.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-06-17T22:25:53.953' AS DateTime), CAST(N'2018-06-17T22:25:53.953' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (310, 5, 4, 3, CAST(5.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-06-17T22:25:53.953' AS DateTime), CAST(N'2018-06-17T22:25:53.953' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (311, 5, 5, 3, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-06-17T22:25:53.953' AS DateTime), CAST(N'2018-06-17T22:25:53.953' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (312, 5, 1, 4, CAST(3.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-06-17T22:25:53.953' AS DateTime), CAST(N'2018-06-17T22:25:53.953' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (313, 5, 2, 4, CAST(4.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-06-17T22:25:53.953' AS DateTime), CAST(N'2018-06-17T22:25:53.953' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (314, 5, 3, 4, CAST(5.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-06-17T22:25:53.953' AS DateTime), CAST(N'2018-06-17T22:25:53.953' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (315, 5, 4, 4, CAST(6.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-06-17T22:25:53.953' AS DateTime), CAST(N'2018-06-17T22:25:53.953' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (316, 5, 5, 4, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-06-17T22:25:53.953' AS DateTime), CAST(N'2018-06-17T22:25:53.953' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (317, 5, 1, 5, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-06-17T22:25:53.953' AS DateTime), CAST(N'2018-06-17T22:25:53.953' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (318, 5, 2, 5, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-06-17T22:25:53.953' AS DateTime), CAST(N'2018-06-17T22:25:53.953' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (319, 5, 3, 5, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-06-17T22:25:53.953' AS DateTime), CAST(N'2018-06-17T22:25:53.953' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (320, 5, 4, 5, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-06-17T22:25:53.953' AS DateTime), CAST(N'2018-06-17T22:25:53.953' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (321, 5, 5, 5, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-06-17T22:25:53.953' AS DateTime), CAST(N'2018-06-17T22:25:53.953' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (462, 7, 1, 1, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-06-25T16:06:47.253' AS DateTime), CAST(N'2018-06-25T16:06:47.253' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (463, 7, 2, 1, CAST(40.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-06-25T16:06:47.253' AS DateTime), CAST(N'2018-06-25T16:06:47.253' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (464, 7, 3, 1, CAST(50.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-06-25T16:06:47.253' AS DateTime), CAST(N'2018-06-25T16:06:47.253' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (465, 7, 4, 1, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-06-25T16:06:47.253' AS DateTime), CAST(N'2018-06-25T16:06:47.253' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (466, 7, 5, 1, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-06-25T16:06:47.253' AS DateTime), CAST(N'2018-06-25T16:06:47.253' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (467, 7, 1, 2, CAST(40.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-06-25T16:06:47.253' AS DateTime), CAST(N'2018-06-25T16:06:47.253' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (468, 7, 2, 2, CAST(4000.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-06-25T16:06:47.253' AS DateTime), CAST(N'2018-06-25T16:06:47.253' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (469, 7, 3, 2, CAST(6000.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-06-25T16:06:47.253' AS DateTime), CAST(N'2018-06-25T16:06:47.253' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (470, 7, 4, 2, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-06-25T16:06:47.253' AS DateTime), CAST(N'2018-06-25T16:06:47.253' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (471, 7, 5, 2, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-06-25T16:06:47.253' AS DateTime), CAST(N'2018-06-25T16:06:47.253' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (472, 7, 1, 3, CAST(50.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-06-25T16:06:47.253' AS DateTime), CAST(N'2018-06-25T16:06:47.253' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (473, 7, 2, 3, CAST(6000.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-06-25T16:06:47.253' AS DateTime), CAST(N'2018-06-25T16:06:47.253' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (474, 7, 3, 3, CAST(7000.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-06-25T16:06:47.253' AS DateTime), CAST(N'2018-06-25T16:06:47.253' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (475, 7, 4, 3, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-06-25T16:06:47.253' AS DateTime), CAST(N'2018-06-25T16:06:47.253' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (476, 7, 5, 3, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-06-25T16:06:47.253' AS DateTime), CAST(N'2018-06-25T16:06:47.253' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (477, 7, 1, 4, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-06-25T16:06:47.253' AS DateTime), CAST(N'2018-06-25T16:06:47.253' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (478, 7, 2, 4, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-06-25T16:06:47.253' AS DateTime), CAST(N'2018-06-25T16:06:47.253' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (479, 7, 3, 4, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-06-25T16:06:47.253' AS DateTime), CAST(N'2018-06-25T16:06:47.253' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (480, 7, 4, 4, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-06-25T16:06:47.253' AS DateTime), CAST(N'2018-06-25T16:06:47.253' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (481, 7, 5, 4, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-06-25T16:06:47.253' AS DateTime), CAST(N'2018-06-25T16:06:47.253' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (482, 7, 1, 5, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-06-25T16:06:47.253' AS DateTime), CAST(N'2018-06-25T16:06:47.253' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (483, 7, 2, 5, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-06-25T16:06:47.253' AS DateTime), CAST(N'2018-06-25T16:06:47.253' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (484, 7, 3, 5, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-06-25T16:06:47.253' AS DateTime), CAST(N'2018-06-25T16:06:47.253' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (485, 7, 4, 5, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-06-25T16:06:47.253' AS DateTime), CAST(N'2018-06-25T16:06:47.253' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (486, 7, 5, 5, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-06-25T16:06:47.253' AS DateTime), CAST(N'2018-06-25T16:06:47.253' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (487, 8, 1, 1, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-06-25T16:27:14.433' AS DateTime), CAST(N'2018-06-25T16:27:14.433' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (488, 8, 2, 1, CAST(2.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-06-25T16:27:14.433' AS DateTime), CAST(N'2018-06-25T16:27:14.433' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (489, 8, 3, 1, CAST(3.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-06-25T16:27:14.433' AS DateTime), CAST(N'2018-06-25T16:27:14.433' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (490, 8, 4, 1, CAST(4.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-06-25T16:27:14.433' AS DateTime), CAST(N'2018-06-25T16:27:14.433' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (491, 8, 5, 1, CAST(5.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-06-25T16:27:14.433' AS DateTime), CAST(N'2018-06-25T16:27:14.433' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (492, 8, 1, 2, CAST(2.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-06-25T16:27:14.433' AS DateTime), CAST(N'2018-06-25T16:27:14.433' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (493, 8, 2, 2, CAST(2.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-06-25T16:27:14.433' AS DateTime), CAST(N'2018-06-25T16:27:14.433' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (494, 8, 3, 2, CAST(3.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-06-25T16:27:14.433' AS DateTime), CAST(N'2018-06-25T16:27:14.433' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (495, 8, 4, 2, CAST(4.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-06-25T16:27:14.433' AS DateTime), CAST(N'2018-06-25T16:27:14.433' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (496, 8, 5, 2, CAST(5.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-06-25T16:27:14.433' AS DateTime), CAST(N'2018-06-25T16:27:14.433' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (497, 8, 1, 3, CAST(3.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-06-25T16:27:14.433' AS DateTime), CAST(N'2018-06-25T16:27:14.433' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (498, 8, 2, 3, CAST(3.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-06-25T16:27:14.433' AS DateTime), CAST(N'2018-06-25T16:27:14.433' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (499, 8, 3, 3, CAST(4.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-06-25T16:27:14.433' AS DateTime), CAST(N'2018-06-25T16:27:14.433' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (500, 8, 4, 3, CAST(5.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-06-25T16:27:14.433' AS DateTime), CAST(N'2018-06-25T16:27:14.433' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (501, 8, 5, 3, CAST(6.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-06-25T16:27:14.433' AS DateTime), CAST(N'2018-06-25T16:27:14.433' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (502, 8, 1, 4, CAST(4.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-06-25T16:27:14.433' AS DateTime), CAST(N'2018-06-25T16:27:14.433' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (503, 8, 2, 4, CAST(4.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-06-25T16:27:14.433' AS DateTime), CAST(N'2018-06-25T16:27:14.433' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (504, 8, 3, 4, CAST(5.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-06-25T16:27:14.433' AS DateTime), CAST(N'2018-06-25T16:27:14.433' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (505, 8, 4, 4, CAST(6.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-06-25T16:27:14.433' AS DateTime), CAST(N'2018-06-25T16:27:14.433' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (506, 8, 5, 4, CAST(7.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-06-25T16:27:14.433' AS DateTime), CAST(N'2018-06-25T16:27:14.433' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (507, 8, 1, 5, CAST(5.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-06-25T16:27:14.433' AS DateTime), CAST(N'2018-06-25T16:27:14.433' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (508, 8, 2, 5, CAST(5.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-06-25T16:27:14.433' AS DateTime), CAST(N'2018-06-25T16:27:14.433' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (509, 8, 3, 5, CAST(6.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-06-25T16:27:14.433' AS DateTime), CAST(N'2018-06-25T16:27:14.433' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (510, 8, 4, 5, CAST(7.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-06-25T16:27:14.433' AS DateTime), CAST(N'2018-06-25T16:27:14.433' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (511, 8, 5, 5, CAST(8.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-06-25T16:27:14.433' AS DateTime), CAST(N'2018-06-25T16:27:14.433' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (512, 8, 6, 1, CAST(6.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-06-25T16:27:14.433' AS DateTime), CAST(N'2018-06-25T16:27:14.433' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (513, 8, 6, 2, CAST(6.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-06-25T16:27:14.433' AS DateTime), CAST(N'2018-06-25T16:27:14.433' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (514, 8, 6, 3, CAST(7.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-06-25T16:27:14.433' AS DateTime), CAST(N'2018-06-25T16:27:14.433' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (515, 8, 6, 4, CAST(8.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-06-25T16:27:14.433' AS DateTime), CAST(N'2018-06-25T16:27:14.433' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (516, 8, 6, 5, CAST(9.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-06-25T16:27:14.433' AS DateTime), CAST(N'2018-06-25T16:27:14.433' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (517, 8, 7, 1, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-06-25T16:27:14.433' AS DateTime), CAST(N'2018-06-25T16:27:14.433' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (518, 8, 7, 2, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-06-25T16:27:14.433' AS DateTime), CAST(N'2018-06-25T16:27:14.433' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (519, 8, 7, 3, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-06-25T16:27:14.433' AS DateTime), CAST(N'2018-06-25T16:27:14.433' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (520, 8, 7, 4, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-06-25T16:27:14.433' AS DateTime), CAST(N'2018-06-25T16:27:14.433' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (521, 8, 7, 5, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-06-25T16:27:14.433' AS DateTime), CAST(N'2018-06-25T16:27:14.433' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (522, 8, 8, 1, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-06-25T16:27:14.433' AS DateTime), CAST(N'2018-06-25T16:27:14.433' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (523, 8, 8, 2, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-06-25T16:27:14.433' AS DateTime), CAST(N'2018-06-25T16:27:14.433' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (524, 8, 8, 3, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-06-25T16:27:14.433' AS DateTime), CAST(N'2018-06-25T16:27:14.433' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (525, 8, 8, 4, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-06-25T16:27:14.433' AS DateTime), CAST(N'2018-06-25T16:27:14.433' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (526, 8, 8, 5, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-06-25T16:27:14.433' AS DateTime), CAST(N'2018-06-25T16:27:14.433' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (527, 8, 1, 6, CAST(6.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-06-25T16:27:14.433' AS DateTime), CAST(N'2018-06-25T16:27:14.433' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (528, 8, 2, 6, CAST(6.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-06-25T16:27:14.433' AS DateTime), CAST(N'2018-06-25T16:27:14.433' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (529, 8, 3, 6, CAST(7.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-06-25T16:27:14.433' AS DateTime), CAST(N'2018-06-25T16:27:14.433' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (530, 8, 4, 6, CAST(8.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-06-25T16:27:14.433' AS DateTime), CAST(N'2018-06-25T16:27:14.433' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (531, 8, 5, 6, CAST(9.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-06-25T16:27:14.433' AS DateTime), CAST(N'2018-06-25T16:27:14.433' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (532, 8, 6, 6, CAST(10.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-06-25T16:27:14.433' AS DateTime), CAST(N'2018-06-25T16:27:14.433' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (533, 8, 7, 6, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-06-25T16:27:14.433' AS DateTime), CAST(N'2018-06-25T16:27:14.433' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (534, 8, 8, 6, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-06-25T16:27:14.433' AS DateTime), CAST(N'2018-06-25T16:27:14.433' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (535, 8, 1, 7, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-06-25T16:27:14.433' AS DateTime), CAST(N'2018-06-25T16:27:14.433' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (536, 8, 2, 7, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-06-25T16:27:14.433' AS DateTime), CAST(N'2018-06-25T16:27:14.433' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (537, 8, 3, 7, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-06-25T16:27:14.433' AS DateTime), CAST(N'2018-06-25T16:27:14.433' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (538, 8, 4, 7, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-06-25T16:27:14.433' AS DateTime), CAST(N'2018-06-25T16:27:14.433' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (539, 8, 5, 7, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-06-25T16:27:14.433' AS DateTime), CAST(N'2018-06-25T16:27:14.433' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (540, 8, 6, 7, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-06-25T16:27:14.433' AS DateTime), CAST(N'2018-06-25T16:27:14.433' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (541, 8, 7, 7, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-06-25T16:27:14.433' AS DateTime), CAST(N'2018-06-25T16:27:14.433' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (542, 8, 8, 7, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-06-25T16:27:14.433' AS DateTime), CAST(N'2018-06-25T16:27:14.433' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (543, 8, 1, 8, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-06-25T16:27:14.433' AS DateTime), CAST(N'2018-06-25T16:27:14.433' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (544, 8, 2, 8, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-06-25T16:27:14.433' AS DateTime), CAST(N'2018-06-25T16:27:14.433' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (545, 8, 3, 8, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-06-25T16:27:14.433' AS DateTime), CAST(N'2018-06-25T16:27:14.433' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (546, 8, 4, 8, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-06-25T16:27:14.433' AS DateTime), CAST(N'2018-06-25T16:27:14.433' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (547, 8, 5, 8, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-06-25T16:27:14.433' AS DateTime), CAST(N'2018-06-25T16:27:14.433' AS DateTime))
GO
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (548, 8, 6, 8, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-06-25T16:27:14.433' AS DateTime), CAST(N'2018-06-25T16:27:14.433' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (549, 8, 7, 8, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-06-25T16:27:14.433' AS DateTime), CAST(N'2018-06-25T16:27:14.433' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (550, 8, 8, 8, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-06-25T16:27:14.433' AS DateTime), CAST(N'2018-06-25T16:27:14.433' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (551, 8, 1, 9, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-06-25T16:27:14.433' AS DateTime), CAST(N'2018-06-25T16:27:14.433' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (552, 8, 2, 9, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-06-25T16:27:14.433' AS DateTime), CAST(N'2018-06-25T16:27:14.433' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (553, 8, 3, 9, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-06-25T16:27:14.433' AS DateTime), CAST(N'2018-06-25T16:27:14.433' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (554, 8, 4, 9, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-06-25T16:27:14.433' AS DateTime), CAST(N'2018-06-25T16:27:14.433' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (555, 8, 5, 9, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-06-25T16:27:14.433' AS DateTime), CAST(N'2018-06-25T16:27:14.433' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (556, 8, 6, 9, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-06-25T16:27:14.433' AS DateTime), CAST(N'2018-06-25T16:27:14.433' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (557, 8, 7, 9, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-06-25T16:27:14.433' AS DateTime), CAST(N'2018-06-25T16:27:14.433' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (558, 8, 8, 9, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-06-25T16:27:14.433' AS DateTime), CAST(N'2018-06-25T16:27:14.433' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (559, 6, 1, 1, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-06-25T17:56:08.013' AS DateTime), CAST(N'2018-06-25T17:56:08.013' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (560, 6, 2, 1, CAST(1.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-06-25T17:56:08.013' AS DateTime), CAST(N'2018-06-25T17:56:08.013' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (561, 6, 3, 1, CAST(2.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-06-25T17:56:08.013' AS DateTime), CAST(N'2018-06-25T17:56:08.013' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (562, 6, 4, 1, CAST(3.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-06-25T17:56:08.013' AS DateTime), CAST(N'2018-06-25T17:56:08.013' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (563, 6, 5, 1, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-06-25T17:56:08.013' AS DateTime), CAST(N'2018-06-25T17:56:08.013' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (564, 6, 1, 2, CAST(1.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-06-25T17:56:08.013' AS DateTime), CAST(N'2018-06-25T17:56:08.013' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (565, 6, 2, 2, CAST(2.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-06-25T17:56:08.013' AS DateTime), CAST(N'2018-06-25T17:56:08.013' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (566, 6, 3, 2, CAST(2.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-06-25T17:56:08.013' AS DateTime), CAST(N'2018-06-25T17:56:08.013' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (567, 6, 4, 2, CAST(3.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-06-25T17:56:08.013' AS DateTime), CAST(N'2018-06-25T17:56:08.013' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (568, 6, 5, 2, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-06-25T17:56:08.013' AS DateTime), CAST(N'2018-06-25T17:56:08.013' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (569, 6, 1, 3, CAST(2.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-06-25T17:56:08.013' AS DateTime), CAST(N'2018-06-25T17:56:08.013' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (570, 6, 2, 3, CAST(2.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-06-25T17:56:08.013' AS DateTime), CAST(N'2018-06-25T17:56:08.013' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (571, 6, 3, 3, CAST(3.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-06-25T17:56:08.013' AS DateTime), CAST(N'2018-06-25T17:56:08.013' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (572, 6, 4, 3, CAST(4.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-06-25T17:56:08.013' AS DateTime), CAST(N'2018-06-25T17:56:08.013' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (573, 6, 5, 3, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-06-25T17:56:08.013' AS DateTime), CAST(N'2018-06-25T17:56:08.013' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (574, 6, 1, 4, CAST(3.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-06-25T17:56:08.013' AS DateTime), CAST(N'2018-06-25T17:56:08.013' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (575, 6, 2, 4, CAST(3.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-06-25T17:56:08.013' AS DateTime), CAST(N'2018-06-25T17:56:08.013' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (576, 6, 3, 4, CAST(4.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-06-25T17:56:08.013' AS DateTime), CAST(N'2018-06-25T17:56:08.013' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (577, 6, 4, 4, CAST(5.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-06-25T17:56:08.013' AS DateTime), CAST(N'2018-06-25T17:56:08.013' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (578, 6, 5, 4, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-06-25T17:56:08.013' AS DateTime), CAST(N'2018-06-25T17:56:08.013' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (579, 6, 1, 5, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-06-25T17:56:08.013' AS DateTime), CAST(N'2018-06-25T17:56:08.013' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (580, 6, 2, 5, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-06-25T17:56:08.013' AS DateTime), CAST(N'2018-06-25T17:56:08.013' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (581, 6, 3, 5, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-06-25T17:56:08.013' AS DateTime), CAST(N'2018-06-25T17:56:08.013' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (582, 6, 4, 5, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-06-25T17:56:08.013' AS DateTime), CAST(N'2018-06-25T17:56:08.013' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (583, 6, 5, 5, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-06-25T17:56:08.013' AS DateTime), CAST(N'2018-06-25T17:56:08.013' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (609, 10, 1, 1, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-06-25T18:40:36.120' AS DateTime), CAST(N'2018-06-25T18:40:36.120' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (610, 10, 2, 1, CAST(2.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-06-25T18:40:36.120' AS DateTime), CAST(N'2018-06-25T18:40:36.120' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (611, 10, 3, 1, CAST(3.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-06-25T18:40:36.120' AS DateTime), CAST(N'2018-06-25T18:40:36.120' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (612, 10, 4, 1, CAST(4.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-06-25T18:40:36.120' AS DateTime), CAST(N'2018-06-25T18:40:36.120' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (613, 10, 5, 1, CAST(5.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-06-25T18:40:36.120' AS DateTime), CAST(N'2018-06-25T18:40:36.120' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (614, 10, 1, 2, CAST(2.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-06-25T18:40:36.120' AS DateTime), CAST(N'2018-06-25T18:40:36.120' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (615, 10, 2, 2, CAST(3000.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-06-25T18:40:36.120' AS DateTime), CAST(N'2018-06-25T18:40:36.120' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (616, 10, 3, 2, CAST(4000.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-06-25T18:40:36.120' AS DateTime), CAST(N'2018-06-25T18:40:36.120' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (617, 10, 4, 2, CAST(5000.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-06-25T18:40:36.120' AS DateTime), CAST(N'2018-06-25T18:40:36.120' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (618, 10, 5, 2, CAST(6000.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-06-25T18:40:36.120' AS DateTime), CAST(N'2018-06-25T18:40:36.120' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (619, 10, 1, 3, CAST(3.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-06-25T18:40:36.120' AS DateTime), CAST(N'2018-06-25T18:40:36.120' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (620, 10, 2, 3, CAST(4000.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-06-25T18:40:36.120' AS DateTime), CAST(N'2018-06-25T18:40:36.120' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (621, 10, 3, 3, CAST(5000.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-06-25T18:40:36.120' AS DateTime), CAST(N'2018-06-25T18:40:36.120' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (622, 10, 4, 3, CAST(6000.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-06-25T18:40:36.120' AS DateTime), CAST(N'2018-06-25T18:40:36.120' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (623, 10, 5, 3, CAST(7000.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-06-25T18:40:36.120' AS DateTime), CAST(N'2018-06-25T18:40:36.120' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (624, 10, 1, 4, CAST(4.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-06-25T18:40:36.120' AS DateTime), CAST(N'2018-06-25T18:40:36.120' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (625, 10, 2, 4, CAST(5000.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-06-25T18:40:36.120' AS DateTime), CAST(N'2018-06-25T18:40:36.120' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (626, 10, 3, 4, CAST(6000.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-06-25T18:40:36.120' AS DateTime), CAST(N'2018-06-25T18:40:36.120' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (627, 10, 4, 4, CAST(7000.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-06-25T18:40:36.120' AS DateTime), CAST(N'2018-06-25T18:40:36.120' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (628, 10, 5, 4, CAST(8000.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-06-25T18:40:36.120' AS DateTime), CAST(N'2018-06-25T18:40:36.120' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (629, 10, 1, 5, CAST(5.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-06-25T18:40:36.120' AS DateTime), CAST(N'2018-06-25T18:40:36.120' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (630, 10, 2, 5, CAST(6000.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-06-25T18:40:36.120' AS DateTime), CAST(N'2018-06-25T18:40:36.120' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (631, 10, 3, 5, CAST(7000.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-06-25T18:40:36.120' AS DateTime), CAST(N'2018-06-25T18:40:36.120' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (632, 10, 4, 5, CAST(8000.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-06-25T18:40:36.120' AS DateTime), CAST(N'2018-06-25T18:40:36.120' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (633, 10, 5, 5, CAST(9000.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-06-25T18:40:36.120' AS DateTime), CAST(N'2018-06-25T18:40:36.120' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (855, 11, 1, 1, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (856, 11, 2, 1, CAST(1.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (857, 11, 3, 1, CAST(2.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (858, 11, 4, 1, CAST(3.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (859, 11, 5, 1, CAST(4.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (860, 11, 6, 1, CAST(5.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (861, 11, 7, 1, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (862, 11, 1, 2, CAST(1.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (863, 11, 2, 2, CAST(2000.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (864, 11, 3, 2, CAST(2000.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (865, 11, 4, 2, CAST(5000.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (866, 11, 5, 2, CAST(6000.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (867, 11, 6, 2, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (868, 11, 7, 2, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (869, 11, 1, 3, CAST(2.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (870, 11, 2, 3, CAST(3000.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (871, 11, 3, 3, CAST(3000.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (872, 11, 4, 3, CAST(6000.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (873, 11, 5, 3, CAST(7000.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (874, 11, 6, 3, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (875, 11, 7, 3, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (876, 11, 1, 4, CAST(3.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (877, 11, 2, 4, CAST(4000.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (878, 11, 3, 4, CAST(4000.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (879, 11, 4, 4, CAST(7000.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (880, 11, 5, 4, CAST(8000.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (881, 11, 6, 4, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (882, 11, 7, 4, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (883, 11, 1, 5, CAST(4.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (884, 11, 2, 5, CAST(5000.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (885, 11, 3, 5, CAST(6000.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (886, 11, 4, 5, CAST(7000.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (887, 11, 5, 5, CAST(9000.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (888, 11, 6, 5, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (889, 11, 7, 5, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (890, 11, 1, 6, CAST(5.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (891, 11, 2, 6, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (892, 11, 3, 6, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (893, 11, 4, 6, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
GO
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (894, 11, 5, 6, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (895, 11, 6, 6, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (896, 11, 7, 6, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (897, 11, 1, 7, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (898, 11, 2, 7, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (899, 11, 3, 7, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (900, 11, 4, 7, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (901, 11, 5, 7, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (902, 11, 6, 7, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (903, 11, 7, 7, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (904, 11, 1, 8, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (905, 11, 2, 8, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (906, 11, 3, 8, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (907, 11, 4, 8, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (908, 11, 5, 8, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (909, 11, 6, 8, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (910, 11, 7, 8, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (911, 11, 1, 9, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (912, 11, 2, 9, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (913, 11, 3, 9, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (914, 11, 4, 9, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (915, 11, 5, 9, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (916, 11, 6, 9, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (917, 11, 7, 9, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (918, 11, 1, 10, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (919, 11, 2, 10, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (920, 11, 3, 10, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (921, 11, 4, 10, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (922, 11, 5, 10, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (923, 11, 6, 10, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (924, 11, 7, 10, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (925, 11, 1, 11, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (926, 11, 2, 11, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (927, 11, 3, 11, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (928, 11, 4, 11, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (929, 11, 5, 11, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (930, 11, 6, 11, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (931, 11, 7, 11, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (932, 11, 1, 12, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (933, 11, 2, 12, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (934, 11, 3, 12, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (935, 11, 4, 12, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (936, 11, 5, 12, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (937, 11, 6, 12, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (938, 11, 7, 12, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (939, 11, 1, 13, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (940, 11, 2, 13, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (941, 11, 3, 13, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (942, 11, 4, 13, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (943, 11, 5, 13, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (944, 11, 6, 13, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (945, 11, 7, 13, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (946, 11, 1, 14, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (947, 11, 2, 14, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (948, 11, 3, 14, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (949, 11, 4, 14, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (950, 11, 5, 14, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (951, 11, 6, 14, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (952, 11, 7, 14, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (953, 11, 1, 15, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (954, 11, 2, 15, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (955, 11, 3, 15, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (956, 11, 4, 15, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (957, 11, 5, 15, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (958, 11, 6, 15, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (959, 11, 7, 15, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (960, 11, 1, 16, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (961, 11, 2, 16, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (962, 11, 3, 16, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (963, 11, 4, 16, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (964, 11, 5, 16, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (965, 11, 6, 16, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (966, 11, 7, 16, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (967, 11, 1, 17, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (968, 11, 2, 17, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (969, 11, 3, 17, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (970, 11, 4, 17, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (971, 11, 5, 17, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (972, 11, 6, 17, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (973, 11, 7, 17, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (974, 11, 1, 18, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (975, 11, 2, 18, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (976, 11, 3, 18, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (977, 11, 4, 18, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (978, 11, 5, 18, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (979, 11, 6, 18, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (980, 11, 7, 18, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (981, 11, 8, 1, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (982, 11, 8, 2, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (983, 11, 8, 3, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (984, 11, 8, 4, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (985, 11, 8, 5, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (986, 11, 8, 6, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (987, 11, 8, 7, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (988, 11, 8, 8, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (989, 11, 8, 9, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (990, 11, 8, 10, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (991, 11, 8, 11, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (992, 11, 8, 12, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (993, 11, 8, 13, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
GO
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (994, 11, 8, 14, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (995, 11, 8, 15, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (996, 11, 8, 16, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (997, 11, 8, 17, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (998, 11, 8, 18, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (999, 11, 9, 1, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1000, 11, 9, 2, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1001, 11, 9, 3, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1002, 11, 9, 4, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1003, 11, 9, 5, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1004, 11, 9, 6, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1005, 11, 9, 7, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1006, 11, 9, 8, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1007, 11, 9, 9, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1008, 11, 9, 10, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1009, 11, 9, 11, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1010, 11, 9, 12, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1011, 11, 9, 13, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1012, 11, 9, 14, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1013, 11, 9, 15, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1014, 11, 9, 16, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1015, 11, 9, 17, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1016, 11, 9, 18, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1017, 11, 10, 1, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1018, 11, 10, 2, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1019, 11, 10, 3, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1020, 11, 10, 4, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1021, 11, 10, 5, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1022, 11, 10, 6, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1023, 11, 10, 7, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1024, 11, 10, 8, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1025, 11, 10, 9, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1026, 11, 10, 10, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1027, 11, 10, 11, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1028, 11, 10, 12, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1029, 11, 10, 13, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1030, 11, 10, 14, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1031, 11, 10, 15, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1032, 11, 10, 16, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1033, 11, 10, 17, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1034, 11, 10, 18, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1035, 11, 11, 1, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1036, 11, 11, 2, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1037, 11, 11, 3, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1038, 11, 11, 4, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1039, 11, 11, 5, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1040, 11, 11, 6, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1041, 11, 11, 7, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1042, 11, 11, 8, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1043, 11, 11, 9, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1044, 11, 11, 10, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1045, 11, 11, 11, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1046, 11, 11, 12, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1047, 11, 11, 13, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1048, 11, 11, 14, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1049, 11, 11, 15, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1050, 11, 11, 16, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1051, 11, 11, 17, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1052, 11, 11, 18, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1053, 11, 12, 1, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1054, 11, 12, 2, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1055, 11, 12, 3, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1056, 11, 12, 4, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1057, 11, 12, 5, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1058, 11, 12, 6, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1059, 11, 12, 7, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1060, 11, 12, 8, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1061, 11, 12, 9, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1062, 11, 12, 10, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1063, 11, 12, 11, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1064, 11, 12, 12, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1065, 11, 12, 13, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1066, 11, 12, 14, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1067, 11, 12, 15, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1068, 11, 12, 16, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1069, 11, 12, 17, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1070, 11, 12, 18, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1071, 11, 13, 1, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1072, 11, 13, 2, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1073, 11, 13, 3, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1074, 11, 13, 4, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1075, 11, 13, 5, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1076, 11, 13, 6, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1077, 11, 13, 7, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1078, 11, 13, 8, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1079, 11, 13, 9, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1080, 11, 13, 10, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1081, 11, 13, 11, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1082, 11, 13, 12, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1083, 11, 13, 13, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1084, 11, 13, 14, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1085, 11, 13, 15, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1086, 11, 13, 16, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1087, 11, 13, 17, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1088, 11, 13, 18, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1089, 11, 14, 1, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1090, 11, 14, 2, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1091, 11, 14, 3, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1092, 11, 14, 4, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1093, 11, 14, 5, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
GO
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1094, 11, 14, 6, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1095, 11, 14, 7, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1096, 11, 14, 8, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1097, 11, 14, 9, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1098, 11, 14, 10, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1099, 11, 14, 11, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1100, 11, 14, 12, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1101, 11, 14, 13, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1102, 11, 14, 14, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1103, 11, 14, 15, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1104, 11, 14, 16, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1105, 11, 14, 17, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1106, 11, 14, 18, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1107, 11, 15, 1, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1108, 11, 15, 2, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1109, 11, 15, 3, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1110, 11, 15, 4, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1111, 11, 15, 5, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1112, 11, 15, 6, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1113, 11, 15, 7, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1114, 11, 15, 8, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1115, 11, 15, 9, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1116, 11, 15, 10, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1117, 11, 15, 11, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1118, 11, 15, 12, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1119, 11, 15, 13, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1120, 11, 15, 14, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1121, 11, 15, 15, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1122, 11, 15, 16, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1123, 11, 15, 17, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1124, 11, 15, 18, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1125, 11, 16, 1, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1126, 11, 16, 2, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1127, 11, 16, 3, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1128, 11, 16, 4, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1129, 11, 16, 5, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1130, 11, 16, 6, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1131, 11, 16, 7, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1132, 11, 16, 8, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1133, 11, 16, 9, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1134, 11, 16, 10, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1135, 11, 16, 11, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1136, 11, 16, 12, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1137, 11, 16, 13, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1138, 11, 16, 14, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1139, 11, 16, 15, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1140, 11, 16, 16, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1141, 11, 16, 17, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1142, 11, 16, 18, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1143, 11, 17, 1, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1144, 11, 17, 2, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1145, 11, 17, 3, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1146, 11, 17, 4, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1147, 11, 17, 5, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1148, 11, 17, 6, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1149, 11, 17, 7, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1150, 11, 17, 8, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1151, 11, 17, 9, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1152, 11, 17, 10, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1153, 11, 17, 11, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1154, 11, 17, 12, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1155, 11, 17, 13, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1156, 11, 17, 14, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1157, 11, 17, 15, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1158, 11, 17, 16, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1159, 11, 17, 17, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1160, 11, 17, 18, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1161, 11, 18, 1, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1162, 11, 18, 2, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1163, 11, 18, 3, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1164, 11, 18, 4, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1165, 11, 18, 5, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1166, 11, 18, 6, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1167, 11, 18, 7, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1168, 11, 18, 8, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1169, 11, 18, 9, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1170, 11, 18, 10, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1171, 11, 18, 11, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1172, 11, 18, 12, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1173, 11, 18, 13, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1174, 11, 18, 14, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1175, 11, 18, 15, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1176, 11, 18, 16, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1177, 11, 18, 17, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1178, 11, 18, 18, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1179, 11, 19, 1, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1180, 11, 19, 2, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1181, 11, 19, 3, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1182, 11, 19, 4, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1183, 11, 19, 5, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1184, 11, 19, 6, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1185, 11, 19, 7, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1186, 11, 19, 8, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1187, 11, 19, 9, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1188, 11, 19, 10, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1189, 11, 19, 11, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1190, 11, 19, 12, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1191, 11, 19, 13, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1192, 11, 19, 14, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1193, 11, 19, 15, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
GO
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1194, 11, 19, 16, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1195, 11, 19, 17, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1196, 11, 19, 18, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1197, 11, 20, 1, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1198, 11, 20, 2, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1199, 11, 20, 3, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1200, 11, 20, 4, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1201, 11, 20, 5, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1202, 11, 20, 6, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1203, 11, 20, 7, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1204, 11, 20, 8, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1205, 11, 20, 9, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1206, 11, 20, 10, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1207, 11, 20, 11, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1208, 11, 20, 12, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1209, 11, 20, 13, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1210, 11, 20, 14, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1211, 11, 20, 15, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1212, 11, 20, 16, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1213, 11, 20, 17, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1214, 11, 20, 18, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:20:53.313' AS DateTime), CAST(N'2018-07-01T00:20:53.313' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1215, 9, 1, 1, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:29:27.530' AS DateTime), CAST(N'2018-07-01T00:29:27.530' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1216, 9, 2, 1, CAST(1.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:29:27.530' AS DateTime), CAST(N'2018-07-01T00:29:27.530' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1217, 9, 3, 1, CAST(2.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:29:27.530' AS DateTime), CAST(N'2018-07-01T00:29:27.530' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1218, 9, 4, 1, CAST(3.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:29:27.530' AS DateTime), CAST(N'2018-07-01T00:29:27.530' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1219, 9, 5, 1, CAST(4.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:29:27.530' AS DateTime), CAST(N'2018-07-01T00:29:27.530' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1220, 9, 1, 2, CAST(1.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:29:27.530' AS DateTime), CAST(N'2018-07-01T00:29:27.530' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1221, 9, 2, 2, CAST(2000.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:29:27.530' AS DateTime), CAST(N'2018-07-01T00:29:27.530' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1222, 9, 3, 2, CAST(3000.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:29:27.530' AS DateTime), CAST(N'2018-07-01T00:29:27.530' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1223, 9, 4, 2, CAST(4000.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:29:27.530' AS DateTime), CAST(N'2018-07-01T00:29:27.530' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1224, 9, 5, 2, CAST(5000.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:29:27.530' AS DateTime), CAST(N'2018-07-01T00:29:27.530' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1225, 9, 1, 3, CAST(2.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:29:27.530' AS DateTime), CAST(N'2018-07-01T00:29:27.530' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1226, 9, 2, 3, CAST(3000.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:29:27.530' AS DateTime), CAST(N'2018-07-01T00:29:27.530' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1227, 9, 3, 3, CAST(4000.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:29:27.530' AS DateTime), CAST(N'2018-07-01T00:29:27.530' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1228, 9, 4, 3, CAST(5000.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:29:27.530' AS DateTime), CAST(N'2018-07-01T00:29:27.530' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1229, 9, 5, 3, CAST(6000.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:29:27.530' AS DateTime), CAST(N'2018-07-01T00:29:27.530' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1230, 9, 1, 4, CAST(3.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:29:27.530' AS DateTime), CAST(N'2018-07-01T00:29:27.530' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1231, 9, 2, 4, CAST(4000.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:29:27.530' AS DateTime), CAST(N'2018-07-01T00:29:27.530' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1232, 9, 3, 4, CAST(5000.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:29:27.530' AS DateTime), CAST(N'2018-07-01T00:29:27.530' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1233, 9, 4, 4, CAST(6000.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:29:27.530' AS DateTime), CAST(N'2018-07-01T00:29:27.530' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1234, 9, 5, 4, CAST(7000.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:29:27.530' AS DateTime), CAST(N'2018-07-01T00:29:27.530' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1235, 9, 1, 5, CAST(4.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:29:27.530' AS DateTime), CAST(N'2018-07-01T00:29:27.530' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1236, 9, 2, 5, CAST(5000.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:29:27.530' AS DateTime), CAST(N'2018-07-01T00:29:27.530' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1237, 9, 3, 5, CAST(6000.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:29:27.530' AS DateTime), CAST(N'2018-07-01T00:29:27.530' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1238, 9, 4, 5, CAST(7000.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:29:27.530' AS DateTime), CAST(N'2018-07-01T00:29:27.530' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1239, 9, 5, 5, CAST(8000.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:29:27.530' AS DateTime), CAST(N'2018-07-01T00:29:27.530' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1240, 9, 1, 6, CAST(5.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:29:27.530' AS DateTime), CAST(N'2018-07-01T00:29:27.530' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1241, 9, 2, 6, CAST(6000.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:29:27.530' AS DateTime), CAST(N'2018-07-01T00:29:27.530' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1242, 9, 3, 6, CAST(7000.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:29:27.530' AS DateTime), CAST(N'2018-07-01T00:29:27.530' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1243, 9, 4, 6, CAST(8000.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:29:27.530' AS DateTime), CAST(N'2018-07-01T00:29:27.530' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1244, 9, 5, 6, CAST(9000.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:29:27.530' AS DateTime), CAST(N'2018-07-01T00:29:27.530' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1245, 9, 1, 7, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:29:27.530' AS DateTime), CAST(N'2018-07-01T00:29:27.530' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1246, 9, 2, 7, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:29:27.530' AS DateTime), CAST(N'2018-07-01T00:29:27.530' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1247, 9, 3, 7, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:29:27.530' AS DateTime), CAST(N'2018-07-01T00:29:27.530' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1248, 9, 4, 7, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:29:27.530' AS DateTime), CAST(N'2018-07-01T00:29:27.530' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1249, 9, 5, 7, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:29:27.530' AS DateTime), CAST(N'2018-07-01T00:29:27.530' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1250, 9, 6, 1, CAST(5.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:29:27.530' AS DateTime), CAST(N'2018-07-01T00:29:27.530' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1251, 9, 6, 2, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:29:27.530' AS DateTime), CAST(N'2018-07-01T00:29:27.530' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1252, 9, 6, 3, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:29:27.530' AS DateTime), CAST(N'2018-07-01T00:29:27.530' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1253, 9, 6, 4, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:29:27.530' AS DateTime), CAST(N'2018-07-01T00:29:27.530' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1254, 9, 6, 5, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:29:27.530' AS DateTime), CAST(N'2018-07-01T00:29:27.530' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1255, 9, 6, 6, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:29:27.530' AS DateTime), CAST(N'2018-07-01T00:29:27.530' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1256, 9, 6, 7, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:29:27.530' AS DateTime), CAST(N'2018-07-01T00:29:27.530' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1257, 9, 7, 1, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:29:27.530' AS DateTime), CAST(N'2018-07-01T00:29:27.530' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1258, 9, 7, 2, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:29:27.530' AS DateTime), CAST(N'2018-07-01T00:29:27.530' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1259, 9, 7, 3, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:29:27.530' AS DateTime), CAST(N'2018-07-01T00:29:27.530' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1260, 9, 7, 4, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:29:27.530' AS DateTime), CAST(N'2018-07-01T00:29:27.530' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1261, 9, 7, 5, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:29:27.530' AS DateTime), CAST(N'2018-07-01T00:29:27.530' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1262, 9, 7, 6, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:29:27.530' AS DateTime), CAST(N'2018-07-01T00:29:27.530' AS DateTime))
INSERT [dbo].[ProductPrice] ([Id], [ProductMaterialId], [Row], [Column], [Value], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (1263, 9, 7, 7, CAST(0.00 AS Decimal(18, 2)), NULL, NULL, CAST(N'2018-07-01T00:29:27.530' AS DateTime), CAST(N'2018-07-01T00:29:27.530' AS DateTime))
SET IDENTITY_INSERT [dbo].[ProductPrice] OFF
INSERT [dbo].[SEC_User] ([RecId], [UserName], [FirstName], [LastName], [FullName], [Password], [Email], [Birthday], [Age], [Sex], [Address], [City], [State], [PhoneNumber], [CreateDTS], [UpdateDTS], [LastLoginDTS], [CreateBy], [ActiveStatus], [Locked], [UpdateBy]) VALUES (N'FCF88E68-CEE2-4020-8C40-8A4D22A73F39', N'tung', N'tug', N'le', NULL, N'tung', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, CAST(N'2018-06-11T21:14:35.510' AS DateTime), NULL, NULL, NULL, 1, NULL, NULL)
SET IDENTITY_INSERT [dbo].[Supplier] ON 

INSERT [dbo].[Supplier] ([Id], [FirstName], [LastName], [Company], [Email], [JobTitle], [WebPage], [Notes], [Address], [ZipCode], [City], [State], [Country], [BusinessPhone], [MobilePhone], [HomePhone], [Fax], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (4, N'tung', N'le', N'aperia', N'mngo@aperia.com', NULL, NULL, NULL, N'quoturm', NULL, N'dallas', N'TEXAS', NULL, NULL, NULL, N'12345689', NULL, NULL, NULL, NULL, CAST(N'2018-06-12T21:55:26.153' AS DateTime), NULL)
INSERT [dbo].[Supplier] ([Id], [FirstName], [LastName], [Company], [Email], [JobTitle], [WebPage], [Notes], [Address], [ZipCode], [City], [State], [Country], [BusinessPhone], [MobilePhone], [HomePhone], [Fax], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (5, N'viet', N'tuan', N'CSC', N'mngo@aperia.com', NULL, NULL, N'this is note', N'quoturm', NULL, N'dallas', N'TEXAS', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, CAST(N'2018-06-13T23:51:43.300' AS DateTime), NULL)
INSERT [dbo].[Supplier] ([Id], [FirstName], [LastName], [Company], [Email], [JobTitle], [WebPage], [Notes], [Address], [ZipCode], [City], [State], [Country], [BusinessPhone], [MobilePhone], [HomePhone], [Fax], [ActiveStatus], [CreateBy], [UpdateBy], [CreateDTS], [UpdateDTS]) VALUES (6, N'Thanh', N'Nguyen', N'BWC Company', N'tungle@aperia.com', N'dev', NULL, NULL, N'123 Syney Australia', NULL, N'dong nai', NULL, NULL, N'123456', NULL, N'123456', NULL, NULL, NULL, NULL, CAST(N'2018-06-14T00:21:42.507' AS DateTime), CAST(N'2018-06-30T23:20:58.600' AS DateTime))
SET IDENTITY_INSERT [dbo].[Supplier] OFF
SET ANSI_PADDING ON
GO
/****** Object:  Index [PK_SEC_Admin]    Script Date: 7/1/2018 1:04:25 AM ******/
ALTER TABLE [dbo].[SEC_User] ADD  CONSTRAINT [PK_SEC_Admin] PRIMARY KEY NONCLUSTERED 
(
	[UserName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
ALTER TABLE [dbo].[SEC_User] ADD  CONSTRAINT [DF__SEC_Admin__RecId__440B1D61]  DEFAULT (newid()) FOR [RecId]
GO
ALTER TABLE [dbo].[SEC_User] ADD  CONSTRAINT [DF__SEC_Admin__Creat__44FF419A]  DEFAULT (getdate()) FOR [CreateDTS]
GO
ALTER TABLE [dbo].[SEC_User] ADD  CONSTRAINT [DF__SEC_Admin__Activ__45F365D3]  DEFAULT ((1)) FOR [ActiveStatus]
GO
/****** Object:  StoredProcedure [dbo].[sp_AuthenticateUser]    Script Date: 7/1/2018 1:04:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author:		tungle
-- Create date: 13/1/2016
-- Description:	<Description,,>
-- =============================================
-- exec sp_AuthenticateAdminUser @UserName='tung', @Password=123

CREATE PROCEDURE [dbo].[sp_AuthenticateUser]
	@UserName varchar(200)
	,@Password varchar(100)
	
AS
BEGIN
	
	DECLARE @Authenticate INT	
	SET @Authenticate = dbo.fn_AuthenticateUser(@UserName,@Password)
	
	IF @Authenticate = 1
		SELECT *, @Authenticate AS Authenticate FROM SEC_User WHERE UserName = @UserName
	ELSE
		SELECT @Authenticate AS Authenticate
	
    
END



GO
/****** Object:  StoredProcedure [dbo].[sp_CopyOrder]    Script Date: 7/1/2018 1:04:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




-- =============================================
-- Author:		tungle
-- Create date: 13/1/2016
-- Description:	<Description,,>
-- =============================================
-- exec [sp_CopyOrder]

CREATE PROCEDURE [dbo].[sp_CopyOrder]
	@Id BIGINT,
	@NewId BIGINT
AS
BEGIN	
	--copy order info
	INSERT INTO [Order]( Id
						,EmployeeId
						,EmployeeName
						,Step
						,Taxes
						,Surcharge
						,Discount
						,OrderDate
						,Notes
						,SupplierId
						,SupplierName
						,SupplierAddress
						,SupplierEmail
						,SupplierPhone
						,OrderRefNo
						,OrderType
						,CreateDTS
						,ActiveStatus)

	SELECT @NewId
		,EmployeeId
		,EmployeeName
		,1
		,Taxes
		,Surcharge
		,Discount
		,GETDATE()
		,Notes
		,SupplierId
		,SupplierName
		,SupplierAddress
		,SupplierEmail
		,SupplierPhone
		,OrderRefNo
		,OrderType
		,GETDATE()
		,ActiveStatus
	FROM [Order] WITH(NOLOCK)
	WHERE Id=@Id

	-- Copy components that step is new(id=1)
	INSERT INTO OrderComponent(	OrderId
								,OrderType
								,ComponentId
								,ColorId
								,Quantity
								,Price
								,ExtCharge
								,UnitId
								,Step
								,AMTExcGST
								,GST
								,AMTIncGST
								,CreateDTS
								)
	SELECT @NewId
			,OrderType
			,ComponentId
			,ColorId
			,Quantity - Received
			,Price
			,ExtCharge
			,UnitId
			,Step
			,AMTExcGST
			,GST
			,AMTIncGST
			,GETDATE()
	FROM OrderComponent WITH(NOLOCK)
	WHERE OrderId = @Id AND Quantity > Received

	-- Copy product that step is new(id=1)
	INSERT INTO OrderProduct(	OrderId
								,OrderType
								,ProductId
								,MaterialId
								,LocationId
								,ColorId
								,ControlSideId
								,UnitId
								,[Drop]
								,Width
								,Quantity
								,Discount
								,ExtendPrice
								,UnitPrice
								,TotalAmount
								,Received
								,BackOrder
								,Step
								,AMTExcGST
								,GST
								,AMTIncGST
								,CreateDTS
								,ActiveStatus
								)
	SELECT @NewId
			,OrderType
			,ProductId
			,MaterialId
			,LocationId
			,ColorId
			,ControlSideId
			,UnitId
			,[Drop]
			,Width
			,Quantity - Received
			,Discount
			,ExtendPrice
			,UnitPrice
			,TotalAmount
			,Received
			,BackOrder
			,Step
			,AMTExcGST
			,GST
			,AMTIncGST
			,GETDATE()
			,ActiveStatus
	FROM OrderProduct WITH(NOLOCK)
	WHERE OrderId = @Id AND Quantity > Received

END




GO
/****** Object:  StoredProcedure [dbo].[sp_DeleteComponent]    Script Date: 7/1/2018 1:04:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




-- =============================================
-- Author:		tungle
-- Create date: 13/1/2016
-- Description:	<Description,,>
-- =============================================
-- exec [sp_DeleteComponent] @Id=1

CREATE PROCEDURE [dbo].[sp_DeleteComponent]
	@Id INT
AS
BEGIN	
	DELETE Component
	WHERE Id =  @Id
    
END




GO
/****** Object:  StoredProcedure [dbo].[sp_DeleteMaterial]    Script Date: 7/1/2018 1:04:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




-- =============================================
-- Author:		tungle
-- Create date: 13/1/2016
-- Description:	<Description,,>
-- =============================================
-- exec [sp_DeleteMaterial] @Id=1

CREATE PROCEDURE [dbo].[sp_DeleteMaterial]
	@Id INT
AS
BEGIN	
	DELETE Material
	WHERE Id =  @Id
    
END




GO
/****** Object:  StoredProcedure [dbo].[sp_DeleteOrder]    Script Date: 7/1/2018 1:04:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




-- =============================================
-- Author:		tungle
-- Create date: 13/1/2016
-- Description:	<Description,,>
-- =============================================
-- exec [sp_DeleteOrder] @Id=1

CREATE PROCEDURE [dbo].[sp_DeleteOrder]
	@Id BIGINT
AS
BEGIN	
	DELETE [Order]
	WHERE Id =  @Id
    
END




GO
/****** Object:  StoredProcedure [dbo].[sp_DeleteOrderComponent]    Script Date: 7/1/2018 1:04:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




-- =============================================
-- Author:		tungle
-- Create date: 13/1/2016
-- Description:	<Description,,>
-- =============================================
-- exec [sp_DeleteOrderComponent] @Id=1

CREATE PROCEDURE [dbo].[sp_DeleteOrderComponent]
	@Id INT
AS
BEGIN	
	DELETE OrderComponent
	WHERE Id =  @Id
    
END




GO
/****** Object:  StoredProcedure [dbo].[sp_DeleteOrderInvoice]    Script Date: 7/1/2018 1:04:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




-- =============================================
-- Author:		tungle
-- Create date: 13/1/2016
-- Description:	<Description,,>
-- =============================================
-- exec [sp_DeleteOrderInvoice] @Id=1

Create PROCEDURE [dbo].[sp_DeleteOrderInvoice]
	@Id INT
AS
BEGIN	
	DELETE OrderInvoice
	WHERE Id =  @Id
    
END




GO
/****** Object:  StoredProcedure [dbo].[sp_DeleteOrderPayment]    Script Date: 7/1/2018 1:04:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




-- =============================================
-- Author:		tungle
-- Create date: 13/1/2016
-- Description:	<Description,,>
-- =============================================
-- exec [sp_DeletePurchasePayment] @Id=1

Create PROCEDURE [dbo].[sp_DeleteOrderPayment]
	@Id INT
AS
BEGIN	
	DELETE OrderPayment
	WHERE Id =  @Id
    
END




GO
/****** Object:  StoredProcedure [dbo].[sp_DeleteOrderProduct]    Script Date: 7/1/2018 1:04:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




-- =============================================
-- Author:		tungle
-- Create date: 13/1/2016
-- Description:	<Description,,>
-- =============================================
-- exec [sp_DeleteOrderProduct] @Id=1

CREATE PROCEDURE [dbo].[sp_DeleteOrderProduct]
	@Id INT
AS
BEGIN	
	DELETE OrderProduct
	WHERE Id =  @Id
    
END




GO
/****** Object:  StoredProcedure [dbo].[sp_DeleteProduct]    Script Date: 7/1/2018 1:04:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




-- =============================================
-- Author:		tungle
-- Create date: 13/1/2016
-- Description:	<Description,,>
-- =============================================
-- exec [sp_DeleteProduct] @Id=1

CREATE PROCEDURE [dbo].[sp_DeleteProduct]
	@Id INT
AS
BEGIN	
	DELETE Product
	WHERE Id =  @Id
    
END




GO
/****** Object:  StoredProcedure [dbo].[sp_DeleteProductComponent]    Script Date: 7/1/2018 1:04:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




-- =============================================
-- Author:		tungle
-- Create date: 13/1/2016
-- Description:	<Description,,>
-- =============================================
-- exec [sp_DeleteProductComponent] @Id=1

CREATE PROCEDURE [dbo].[sp_DeleteProductComponent]
	@Id INT
AS
BEGIN	
	DELETE ProductComponent
	WHERE Id =  @Id
    
END




GO
/****** Object:  StoredProcedure [dbo].[sp_DeleteProductMaterial]    Script Date: 7/1/2018 1:04:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




-- =============================================
-- Author:		tungle
-- Create date: 13/1/2016
-- Description:	<Description,,>
-- =============================================
-- exec [sp_DeleteProductMaterial] @Id=1

CREATE PROCEDURE [dbo].[sp_DeleteProductMaterial]
	@Id INT
AS
BEGIN	
	DELETE ProductMaterial
	WHERE Id =  @Id
    
END




GO
/****** Object:  StoredProcedure [dbo].[sp_DeleteSupplier]    Script Date: 7/1/2018 1:04:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




-- =============================================
-- Author:		tungle
-- Create date: 13/1/2016
-- Description:	<Description,,>
-- =============================================
-- exec [sp_DeleteSupplier] @Id=1

CREATE PROCEDURE [dbo].[sp_DeleteSupplier]
	@Id INT
AS
BEGIN	
	DELETE Supplier	
	WHERE Id =  @Id
    
END




GO
/****** Object:  StoredProcedure [dbo].[sp_GetAllColor]    Script Date: 7/1/2018 1:04:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




-- =============================================
-- Author:		tungle
-- Create date: 13/1/2016
-- Description:	<Description,,>
-- =============================================
-- exec [sp_GetAllColor]

Create PROCEDURE [dbo].[sp_GetAllColor]
	
AS
BEGIN	
	SELECT * FROM Color WITH(NOLOCK)	
    
END




GO
/****** Object:  StoredProcedure [dbo].[sp_GetAllComponent]    Script Date: 7/1/2018 1:04:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




-- =============================================
-- Author:		tungle
-- Create date: 13/1/2016
-- Description:	<Description,,>
-- =============================================
-- exec [sp_GetAllComponent]

CREATE PROCEDURE [dbo].[sp_GetAllComponent]
	
AS
BEGIN	
	SELECT c.*, s.FirstName +' '+ s.LastName AS SupplierName
	FROM Component c WITH(NOLOCK)
	LEFT JOIN Supplier s WITH(NOLOCK) ON c.SupplierId = s.Id
    
END




GO
/****** Object:  StoredProcedure [dbo].[sp_GetAllComponentBySupplier]    Script Date: 7/1/2018 1:04:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




-- =============================================
-- Author:		tungle
-- Create date: 13/1/2016
-- Description:	<Description,,>
-- =============================================
-- exec [sp_GetAllComponentBySupplier]

CREATE PROCEDURE [dbo].[sp_GetAllComponentBySupplier]
	@Id INT
AS
BEGIN	
	SELECT c.*, s.FirstName +' '+ s.LastName AS SupplierName
	FROM Component c WITH(NOLOCK)
	INNER JOIN Supplier s WITH(NOLOCK) ON c.SupplierId = s.Id
	WHERE s.Id = @Id
    
END




GO
/****** Object:  StoredProcedure [dbo].[sp_GetAllMaterial]    Script Date: 7/1/2018 1:04:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




-- =============================================
-- Author:		tungle
-- Create date: 13/1/2016
-- Description:	<Description,,>
-- =============================================
-- exec [sp_GetAllMaterial]

Create PROCEDURE [dbo].[sp_GetAllMaterial]
	
AS
BEGIN	
	SELECT * FROM Material WITH(NOLOCK)	
    
END




GO
/****** Object:  StoredProcedure [dbo].[sp_GetAllOrder]    Script Date: 7/1/2018 1:04:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




-- =============================================
-- Author:		tungle
-- Create date: 13/1/2016
-- Description:	<Description,,>
-- =============================================
-- exec [sp_GetAllOrder] @OrderType=1

CREATE PROCEDURE [dbo].[sp_GetAllOrder]
	@OrderType INT
AS
BEGIN	
	CREATE TABLE #OrderSummary(OrderId BIGINT, TotalAmount DECIMAL(18,2))
	CREATE TABLE #ProcessSummary(OrderId BIGINT, InvoiceAmount DECIMAL(18,2), PaymentAmount DECIMAL(18,2))

	INSERT INTO #OrderSummary
	SELECT tb.OrderId, SUM(tb.TotalAmount) AS TotalAmount FROM (
			SELECT 
				op.OrderId AS OrderId,
				op.TotalAmount AS TotalAmount
			FROM [Order] o WITH(NOLOCK)	
				join OrderProduct op WITH(NOLOCK) ON o.Id = op.OrderId	
			WHERE o.OrderType=@OrderType
			UNION 
			SELECT 
				op.OrderId AS OrderId,
				(op.Quantity * op.Price) AS TotalAmount
			 FROM [Order] o WITH(NOLOCK)	
				join OrderComponent op WITH(NOLOCK) ON o.Id = op.OrderId
			WHERE o.OrderType=@OrderType
		) AS tb
	GROUP BY tb.OrderId

	INSERT INTO #ProcessSummary
	SELECT o.Id AS OrderId
	, ISNULL(SUM(op.AmountPaid),0) AS PaymentAmount
	, ISNULL(SUM(oi.InvoiceAmount),0) AS InvoiceAmount
	FROM [Order] o WITH(NOLOCK)
	LEFT JOIN OrderPayment op WITH(NOLOCK) ON o.Id = op.OrderId
	LEFT JOIN OrderInvoice oi WITH(NOLOCK) ON o.Id = oi.OrderId
    WHERE OrderType=@OrderType
	GROUP BY o.Id

	SELECT o.*
	, ISNULL(os.TotalAmount,0) AS  TotalAmount
	, ISNULL(ps.PaymentAmount,0) AS PaymentAmount
	, ISNULL(ps.InvoiceAmount,0) AS InvoiceAmount
	FROM [Order] o WITH(NOLOCK)
	LEFT JOIN #OrderSummary os WITH(NOLOCK) ON o.Id = os.OrderId	
	LEFT JOIN #ProcessSummary ps WITH(NOLOCK) ON o.Id = ps.OrderId
    WHERE OrderType=@OrderType

	DROP TABLE #ProcessSummary
	DROP TABLE #OrderSummary
END




GO
/****** Object:  StoredProcedure [dbo].[sp_GetAllOrderComponent]    Script Date: 7/1/2018 1:04:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




-- =============================================
-- Author:		tungle
-- Create date: 13/1/2016
-- Description:	<Description,,>
-- =============================================
-- exec [sp_GetAllOrderComponent] @OrderId= 1

CREATE PROCEDURE [dbo].[sp_GetAllOrderComponent]
	@OrderId BIGINT,
	@OrderType INT=1
AS
BEGIN	
	SELECT pc.*
	,c.ColorName AS Color
	,p.ComponentName AS ComponentName
	,p.ComponentCode AS ComponentCode
	FROM OrderComponent pc WITH(NOLOCK)	
	JOIN Component p WITH(NOLOCK)ON pc.ComponentId = p.Id
	LEFT JOIN Color c WITH(NOLOCK) ON pc.ColorId = c.Id
	WHERE pc.OrderId = @OrderId
    
END




GO
/****** Object:  StoredProcedure [dbo].[sp_GetAllOrderInvoice]    Script Date: 7/1/2018 1:04:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




-- =============================================
-- Author:		tungle
-- Create date: 13/1/2016
-- Description:	<Description,,>
-- =============================================
-- exec [sp_GetAllOrderInvoice] @OrderId= 1

CREATE PROCEDURE [dbo].[sp_GetAllOrderInvoice]
	@OrderId BIGINT,
	@OrderType INT=1
AS
BEGIN	
	SELECT pc.*
	FROM OrderInvoice pc WITH(NOLOCK)	
	WHERE pc.OrderId = @OrderId
    
END




GO
/****** Object:  StoredProcedure [dbo].[sp_GetAllOrderPayment]    Script Date: 7/1/2018 1:04:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




-- =============================================
-- Author:		tungle
-- Create date: 13/1/2016
-- Description:	<Description,,>
-- =============================================
-- exec [sp_GetAllOrderPayment] @OrderId= 1

CREATE PROCEDURE [dbo].[sp_GetAllOrderPayment]
	@OrderId BIGINT,
	@OrderType INT=1
AS
BEGIN	
	SELECT pc.*
	FROM OrderPayment pc WITH(NOLOCK)	
	WHERE pc.OrderId = @OrderId
    
END




GO
/****** Object:  StoredProcedure [dbo].[sp_GetAllOrderProduct]    Script Date: 7/1/2018 1:04:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




-- =============================================
-- Author:		tungle
-- Create date: 13/1/2016
-- Description:	<Description,,>
-- =============================================
-- exec [sp_GetAllOrderProduct] @OrderId= 1529595111990

CREATE PROCEDURE [dbo].[sp_GetAllOrderProduct]
	@OrderId BIGINT,
	@OrderType INT=1
AS
BEGIN	
	SELECT pc.*
	,m.MaterialName AS MaterialName
	,c.ColorName AS ColorName
	,p.ProductName AS ProductName
	,p.ProductCode AS ProductCode
	FROM OrderProduct pc WITH(NOLOCK)	
	JOIN Product p WITH(NOLOCK)ON pc.ProductId = p.Id
	LEFT JOIN Color c WITH(NOLOCK) ON pc.ColorId = c.Id
	LEFT JOIN Material m WITH(NOLOCK) ON m.Id = pc.MaterialId
	WHERE pc.OrderId = @OrderId
    
END




GO
/****** Object:  StoredProcedure [dbo].[sp_GetAllProduct]    Script Date: 7/1/2018 1:04:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




-- =============================================
-- Author:		tungle
-- Create date: 13/1/2016
-- Description:	<Description,,>
-- =============================================
-- exec [sp_GetAllProduct]

CREATE PROCEDURE [dbo].[sp_GetAllProduct]
	
AS
BEGIN	
	SELECT p.*, c.CategoryName AS CategoryName 
	FROM Product p WITH(NOLOCK)	
	LEFT JOIN Category c WITH(NOLOCK) ON p.CategoryId = c.Id
    
END




GO
/****** Object:  StoredProcedure [dbo].[sp_GetAllProductComponent]    Script Date: 7/1/2018 1:04:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




-- =============================================
-- Author:		tungle
-- Create date: 13/1/2016
-- Description:	<Description,,>
-- =============================================
-- exec [sp_GetAllProductComponent] @Productid= 1

CREATE PROCEDURE [dbo].[sp_GetAllProductComponent]
	@Productid INT
AS
BEGIN	
	SELECT pc.*
	,c.ColorName AS Color
	,p.ComponentName AS ComponentName
	,p.ComponentCode AS ComponentCode
	FROM ProductComponent pc WITH(NOLOCK)	
	JOIN Component p WITH(NOLOCK)ON pc.ComponentId = p.Id
	LEFT JOIN Color c WITH(NOLOCK) ON pc.ColorId = c.Id
	WHERE pc.ProductId = @Productid
    
END




GO
/****** Object:  StoredProcedure [dbo].[sp_GetAllProductMaterial]    Script Date: 7/1/2018 1:04:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




-- =============================================
-- Author:		tungle
-- Create date: 13/1/2016
-- Description:	<Description,,>
-- =============================================
-- exec [sp_GetAllProductMaterial] @Productid= 1

CREATE PROCEDURE [dbo].[sp_GetAllProductMaterial]
	@Productid INT
AS
BEGIN	
	SELECT pm.*
	,m.MaterialName AS MaterialName
	,m.Description AS [Description]
	FROM ProductMaterial pm WITH(NOLOCK)	
	JOIN Material m WITH(NOLOCK)ON pm.MaterialId = m.Id
	WHERE pm.ProductId = @Productid
    
END




GO
/****** Object:  StoredProcedure [dbo].[sp_GetAllProductPrice]    Script Date: 7/1/2018 1:04:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




-- =============================================
-- Author:		tungle
-- Create date: 13/1/2016
-- Description:	<Description,,>
-- =============================================
-- exec [sp_GetAllProductPrice] @ProductId= 1

CREATE PROCEDURE [dbo].[sp_GetAllProductPrice]
	@ProductId INT
AS
BEGIN	
	SELECT pp.*, pm.MaterialId AS MaterialId,pm.ProductId AS ProductId
	FROM ProductPrice pp WITH(NOLOCK)
	JOIN ProductMaterial pm WITH(NOLOCK) ON pp.ProductMaterialId = pm.Id
	WHERE pm.ProductId= @ProductId
    
END




GO
/****** Object:  StoredProcedure [dbo].[sp_GetAllSupplier]    Script Date: 7/1/2018 1:04:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




-- =============================================
-- Author:		tungle
-- Create date: 13/1/2016
-- Description:	<Description,,>
-- =============================================
-- exec [sp_GetAllSupplier]

Create PROCEDURE [dbo].[sp_GetAllSupplier]
	
AS
BEGIN	
	SELECT * FROM Supplier WITH(NOLOCK)	
    
END




GO
/****** Object:  StoredProcedure [dbo].[sp_GetComponent]    Script Date: 7/1/2018 1:04:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




-- =============================================
-- Author:		tungle
-- Create date: 13/1/2016
-- Description:	<Description,,>
-- =============================================
-- exec [sp_GetComponent] @Id=1

CREATE PROCEDURE [dbo].[sp_GetComponent]
	@Id INT
AS
BEGIN	
	SELECT * FROM Component WITH(NOLOCK)	
	WHERE Id =  @Id
    
END




GO
/****** Object:  StoredProcedure [dbo].[sp_GetItemsInOrder]    Script Date: 7/1/2018 1:04:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




-- =============================================
-- Author:		tungle
-- Create date: 13/1/2016
-- Description:	<Description,,>
-- =============================================
-- exec [sp_GetItemsInOrder] @OrderType=1

CREATE PROCEDURE [dbo].[sp_GetItemsInOrder]
	@OrderType INT
AS
BEGIN	
	SELECT 
		op.Id AS OrderItemId,
		op.OrderId AS OrderId,
		op.ProductId AS ItemId,	
		p.ProductName AS ItemName,
		op.Quantity AS Quantity,
		op.UnitPrice AS Price,
		op.UnitId AS Unit,
		--op.TotalAmount AS Total,
		op.Step AS Step,
		'Product' AS ItemType,
		op.TotalAmount AS TotalAmount
	FROM [Order] o WITH(NOLOCK)	
		join OrderProduct op WITH(NOLOCK) ON o.Id = op.OrderId	
		left join Product p WITH(NOLOCK) ON p.Id = op.ProductId
	WHERE o.OrderType=@OrderType
	UNION 
	SELECT 
		op.Id AS OrderItemId,
		op.OrderId AS OrderId,
		op.ComponentId AS ItemId,
		c.ComponentName AS ItemName,
		op.Quantity AS Quantity,
		op.Price AS Price,
		op.UnitId AS Unit,
		--0 AS Total,
		op.Step AS Step,
		'Component' AS ItemType,
		(op.Quantity * op.Price) AS TotalAmount
	 FROM [Order] o WITH(NOLOCK)	
		join OrderComponent op WITH(NOLOCK) ON o.Id = op.OrderId
		left join Component c WITH(NOLOCK) ON c.Id = op.ComponentId
	WHERE o.OrderType=@OrderType
END




GO
/****** Object:  StoredProcedure [dbo].[sp_GetMaterial]    Script Date: 7/1/2018 1:04:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




-- =============================================
-- Author:		tungle
-- Create date: 13/1/2016
-- Description:	<Description,,>
-- =============================================
-- exec [sp_GetMaterial] @Id=1

Create PROCEDURE [dbo].[sp_GetMaterial]
	@Id INT
AS
BEGIN	
	SELECT * FROM Material WITH(NOLOCK)	
	WHERE Id =  @Id
    
END




GO
/****** Object:  StoredProcedure [dbo].[sp_GetOrder]    Script Date: 7/1/2018 1:04:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




-- =============================================
-- Author:		tungle
-- Create date: 13/1/2016
-- Description:	<Description,,>
-- =============================================
-- exec [sp_GetOrder] @Id=1

CREATE PROCEDURE [dbo].[sp_GetOrder]
	@Id BIGINT,
	@OrderType INT=1
AS
BEGIN	
	CREATE TABLE #OrderSummary(OrderId BIGINT, TotalAmount DECIMAL(18,2), TotalReceived DECIMAL(18,2))

	INSERT INTO #OrderSummary
	SELECT tb.OrderId, 
	SUM(tb.TotalAmount) AS TotalAmount,
	SUM(tb.TotalReceived) AS TotalReceived
	FROM (
			SELECT 
				op.OrderId AS OrderId,
				op.TotalAmount AS TotalAmount,
				op.ReceivedAMTIncGST AS TotalReceived
			FROM [Order] o WITH(NOLOCK)	
				join OrderProduct op WITH(NOLOCK) ON o.Id = op.OrderId	
			WHERE o.Id =  @Id
			UNION 
			SELECT 
				op.OrderId AS OrderId,
				(op.Quantity * op.Price) AS TotalAmount,
				op.ReceivedAMTIncGST AS TotalReceived
			 FROM [Order] o WITH(NOLOCK)	
				join OrderComponent op WITH(NOLOCK) ON o.Id = op.OrderId
			WHERE o.Id =  @Id
		) AS tb
	GROUP BY tb.OrderId

	SELECT o.*, 
	ISNULL(os.TotalAmount,0) AS  TotalAmount,
	ISNULL(os.TotalReceived,0) AS  TotalReceived
	FROM [Order] o WITH(NOLOCK)
	LEFT JOIN #OrderSummary os WITH(NOLOCK) ON o.Id = os.OrderId
	WHERE o.Id =  @Id
    
	DROP TABLE #OrderSummary
END



GO
/****** Object:  StoredProcedure [dbo].[sp_GetOrderComponent]    Script Date: 7/1/2018 1:04:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




-- =============================================
-- Author:		tungle
-- Create date: 13/1/2016
-- Description:	<Description,,>
-- =============================================
-- exec [sp_GetOrderComponent] @Id=1

CREATE PROCEDURE [dbo].[sp_GetOrderComponent]
	@Id INT,
	@OrderType INT=1
AS
BEGIN	
	SELECT pc.*
	,c.ColorName AS Color
	,p.ComponentName AS ComponentName
	,p.ComponentCode AS ComponentCode
	FROM OrderComponent pc WITH(NOLOCK)	
	JOIN Component p WITH(NOLOCK)ON pc.ComponentId = p.Id
	LEFT JOIN Color c WITH(NOLOCK) ON pc.ColorId = c.Id
	WHERE pc.Id = @Id
    
END





GO
/****** Object:  StoredProcedure [dbo].[sp_GetOrderInvoice]    Script Date: 7/1/2018 1:04:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




-- =============================================
-- Author:		tungle
-- Create date: 13/1/2016
-- Description:	<Description,,>
-- =============================================
-- exec [sp_GetOrderInvoice] @Id=1

CREATE PROCEDURE [dbo].[sp_GetOrderInvoice]
	@Id INT,
	@OrderType INT=1
AS
BEGIN	
	SELECT pc.*
	FROM OrderInvoice pc WITH(NOLOCK)	
	WHERE pc.Id = @Id
    
END





GO
/****** Object:  StoredProcedure [dbo].[sp_GetOrderPayment]    Script Date: 7/1/2018 1:04:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




-- =============================================
-- Author:		tungle
-- Create date: 13/1/2016
-- Description:	<Description,,>
-- =============================================
-- exec [sp_GetOrderPayment] @Id=1

CREATE PROCEDURE [dbo].[sp_GetOrderPayment]
	@Id INT,
	@OrderType INT=1
AS
BEGIN	
	SELECT pc.*
	FROM OrderPayment pc WITH(NOLOCK)	
	WHERE pc.Id = @Id
    
END





GO
/****** Object:  StoredProcedure [dbo].[sp_GetOrderProduct]    Script Date: 7/1/2018 1:04:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




-- =============================================
-- Author:		tungle
-- Create date: 13/1/2016
-- Description:	<Description,,>
-- =============================================
-- exec [sp_GetOrderProduct] @Id=1

CREATE PROCEDURE [dbo].[sp_GetOrderProduct]
	@Id INT,
	@OrderType INT=1
AS
BEGIN	
	SELECT pc.*
	,c.ColorName AS Color
	,p.ProductName AS ProductName
	,p.ProductCode AS ProductCode
	FROM OrderProduct pc WITH(NOLOCK)	
	JOIN Product p WITH(NOLOCK)ON pc.ProductId = p.Id
	LEFT JOIN Color c WITH(NOLOCK) ON pc.ColorId = c.Id
	WHERE pc.Id = @Id
    
END





GO
/****** Object:  StoredProcedure [dbo].[sp_GetProduct]    Script Date: 7/1/2018 1:04:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




-- =============================================
-- Author:		tungle
-- Create date: 13/1/2016
-- Description:	<Description,,>
-- =============================================
-- exec [sp_GetProduct] @Id=1

CREATE PROCEDURE [dbo].[sp_GetProduct]
	@Id INT
AS
BEGIN	
	SELECT p.*, c.CategoryName AS CategoryName 
	FROM Product p WITH(NOLOCK)	
	LEFT JOIN Category c WITH(NOLOCK) ON p.CategoryId = c.Id	
	WHERE p.Id =  @Id
    
END




GO
/****** Object:  StoredProcedure [dbo].[sp_GetProductComponent]    Script Date: 7/1/2018 1:04:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




-- =============================================
-- Author:		tungle
-- Create date: 13/1/2016
-- Description:	<Description,,>
-- =============================================
-- exec [sp_GetProductComponent] @Id=1

CREATE PROCEDURE [dbo].[sp_GetProductComponent]
	@Id INT
AS
BEGIN	
	SELECT pc.*
	,c.ColorName AS Color
	,p.ComponentName AS ComponentName
	,p.ComponentCode AS ComponentCode
	FROM ProductComponent pc WITH(NOLOCK)	
	JOIN Component p WITH(NOLOCK)ON pc.ComponentId = p.Id
	LEFT JOIN Color c WITH(NOLOCK) ON pc.ColorId = c.Id
	WHERE pc.Id = @Id
    
END





GO
/****** Object:  StoredProcedure [dbo].[sp_GetProductMaterialPrice]    Script Date: 7/1/2018 1:04:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




-- =============================================
-- Author:		tungle
-- Create date: 13/1/2016
-- Description:	<Description,,>
-- =============================================
-- exec [sp_GetProductMaterialPrice] @ProductMaterialId= 1

CREATE PROCEDURE [dbo].[sp_GetProductMaterialPrice]
	@ProductMaterialId INT
AS
BEGIN	
	SELECT * 
	FROM ProductPrice WITH(NOLOCK)
	WHERE ProductMaterialId= @ProductMaterialId
    
END




GO
/****** Object:  StoredProcedure [dbo].[sp_GetSupplier]    Script Date: 7/1/2018 1:04:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




-- =============================================
-- Author:		tungle
-- Create date: 13/1/2016
-- Description:	<Description,,>
-- =============================================
-- exec [sp_GetSupplier]

Create PROCEDURE [dbo].[sp_GetSupplier]
	@Id INT
AS
BEGIN	
	SELECT * FROM Supplier WITH(NOLOCK)	
	WHERE Id =  @Id
    
END




GO
/****** Object:  StoredProcedure [dbo].[sp_InsertComponent]    Script Date: 7/1/2018 1:04:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





-- =============================================
-- Author:		tungle
-- Create date: 13/1/2016
-- Description:	<Description,,>
-- =============================================
-- exec [sp_InsertComponent]

CREATE PROCEDURE [dbo].[sp_InsertComponent]
    @ComponentCode NVARCHAR(250),
    @ComponentName NVARCHAR(250),
    @SupplierId INT,
    @Price DECIMAL(18,2),
    @Color NVARCHAR(250),
    @Unit NVARCHAR(250),
    @Description  NVARCHAR(MAX),
    @ActiveStatus INT
AS
BEGIN	
	INSERT Component(
		ComponentCode,
		ComponentName,
		SupplierId,
		Price,
		Color,
		Unit,
		Description,
		ActiveStatus,
        CreateDTS)
	SELECT 
        @ComponentCode,
		@ComponentName,
		@SupplierId,
		@Price,
		@Color,
		@Unit,
		@Description,
		@ActiveStatus,
        GETDATE()
    
END





GO
/****** Object:  StoredProcedure [dbo].[sp_InsertMaterial]    Script Date: 7/1/2018 1:04:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





-- =============================================
-- Author:		tungle
-- Create date: 13/1/2016
-- Description:	<Description,,>
-- =============================================
-- exec [sp_InsertMaterial]

CREATE PROCEDURE [dbo].[sp_InsertMaterial]
    @MaterialName NVARCHAR(250),
    @SupplierId INT,
    @Price DECIMAL(18,2),
    @Description NVARCHAR(MAX), 
    @ActiveStatus INT
AS
BEGIN	
	INSERT Material(
		MaterialName,		
		SupplierId,
		Price,
		Description,
		ActiveStatus,
        CreateDTS)
	SELECT 
		@MaterialName,
		@SupplierId,
		@Price,
		@Description,
		@ActiveStatus,
        GETDATE()
    
END





GO
/****** Object:  StoredProcedure [dbo].[sp_InsertOrder]    Script Date: 7/1/2018 1:04:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





-- =============================================
-- Author:		tungle
-- Create date: 13/1/2016
-- Description:	<Description,,>
-- =============================================
-- exec [sp_InsertPurchase]

CREATE PROCEDURE [dbo].[sp_InsertOrder]
	@Id BIGINT,
    @EmployeeId INT,
    @EmployeeName NVARCHAR(250),
    @Step VARCHAR(50),
    @Taxes DECIMAL(18,2),
    @Surcharge DECIMAL(18,2),
    @Discount DECIMAL(18,2),
    @OrderDate DateTime,
    @FirtReceiveDate DateTime,
    @LastUpdate DateTime,
    @DeliveryDate DateTime,
    @Notes NVARCHAR(MAX),
    @SupplierId INT,
    @SupplierName NVARCHAR(500),
    @SupplierAddress NVARCHAR(500),
    @SupplierEmail NVARCHAR(250),
    @SupplierPhone NVARCHAR(250),
    @OrderRefNo NVARCHAR(250),
    @OrderType INT,
    @ActiveStatus INT
AS
BEGIN	
	INSERT [Order](
		Id,
		EmployeeId,
		EmployeeName,
		Step,
		Taxes,
		Surcharge,
		Discount,
		OrderDate,
		FirtReceiveDate,
		LastUpdate,
		DeliveryDate,		
		Notes,
		SupplierId,
		SupplierName,
		SupplierAddress,
		SupplierEmail,
		SupplierPhone,
		OrderRefNo,
		OrderType,
		ActiveStatus,
        CreateDTS)
	SELECT 
		@Id,
        @EmployeeId,
		@EmployeeName,
		@Step,
		@Taxes,
		@Surcharge,
		@Discount,
		@OrderDate,
		@FirtReceiveDate,
		@LastUpdate,
		@DeliveryDate,		
		@Notes,
		@SupplierId,
		@SupplierName,
		@SupplierAddress,
		@SupplierEmail,
		@SupplierPhone,
		@OrderRefNo,
		@OrderType,
		@ActiveStatus,
        GETDATE()
    
END





GO
/****** Object:  StoredProcedure [dbo].[sp_InsertOrderComponent]    Script Date: 7/1/2018 1:04:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





-- =============================================
-- Author:		tungle
-- Create date: 13/1/2016
-- Description:	<Description,,>
-- =============================================
-- exec [sp_InsertOrderComponent]

CREATE PROCEDURE [dbo].[sp_InsertOrderComponent]
    @OrderId BIGINT,
	@OrderType INT=0,
    @ComponentId INT,
    @ColorId INT,
    @Quantity INT,
    @Price DECIMAL(18,2),
    @ExtCharge BIT,
	@UnitId INT,
	@Step INT,
	@AMTExcGST DECIMAL(18,2),
	@GST DECIMAL(18,2),
	@AMTIncGST DECIMAL(18,2),
	@ReceivedAMTExcGST DECIMAL(18,2),
	@ReceivedGST DECIMAL(18,2),
	@ReceivedAMTIncGST DECIMAL(18,2)
AS
BEGIN	
	INSERT OrderComponent(
		OrderId,
		ComponentId,
		ColorId,
		Quantity,
		Price,
		ExtCharge,
		UnitId,
		Step,		
		AMTExcGST,
		GST,
		AMTIncGST,
		ReceivedAMTExcGST,
		ReceivedGST,
		ReceivedAMTIncGST,
        CreateDTS)
	SELECT 
        @OrderId,
		@ComponentId,
		@ColorId,
		@Quantity,
		@Price,
		@ExtCharge,
		@UnitId,
		@Step,
		@AMTExcGST,
		@GST,
		@AMTIncGST,
		@ReceivedAMTExcGST,
		@ReceivedGST,
		@ReceivedAMTIncGST,
        GETDATE()
    
END





GO
/****** Object:  StoredProcedure [dbo].[sp_InsertOrderInvoice]    Script Date: 7/1/2018 1:04:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





-- =============================================
-- Author:		tungle
-- Create date: 13/1/2016
-- Description:	<Description,,>
-- =============================================
-- exec [sp_InsertOrderInvoice]

CREATE PROCEDURE [dbo].[sp_InsertOrderInvoice]
    @OrderId BIGINT,
	@OrderType INT=1,
	@InvoiceNo NVARCHAR(250),
    @InvoiceAmount DECIMAL(18,2),
    @CutLengthCharge NVARCHAR(250),
	@DeliveryCharge NVARCHAR(250),
	@ActiveStatus INT
AS
BEGIN	
	INSERT OrderInvoice(
		OrderId,
		InvoiceNo,
		InvoiceDate,
		InvoiceAmount,
		CutLengthCharge,
		DeliveryCharge,
		CreateDTS)
	SELECT 
        @OrderId,
		@InvoiceNo,
		GETDATE(),
		@InvoiceAmount,
		@CutLengthCharge,
		@DeliveryCharge,
        GETDATE()
    
END





GO
/****** Object:  StoredProcedure [dbo].[sp_InsertOrderPayment]    Script Date: 7/1/2018 1:04:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





-- =============================================
-- Author:		tungle
-- Create date: 13/1/2016
-- Description:	<Description,,>
-- =============================================
-- exec [sp_InsertOrderPayment]

CREATE PROCEDURE [dbo].[sp_InsertOrderPayment]
    @OrderId BIGINT,
	@OrderType INT=1,
    @AmountPaid DECIMAL(18,2),
    @PaymentType NVARCHAR(250),
	@ActiveStatus INT
AS
BEGIN	
	INSERT OrderPayment(
		OrderId,
		DatePaid,
		AmountPaid,
		PaymentType,
		CreateDTS)
	SELECT 
        @OrderId,
		GETDATE(),
		@AmountPaid,
		@PaymentType,
        GETDATE()
    
END





GO
/****** Object:  StoredProcedure [dbo].[sp_InsertOrderProduct]    Script Date: 7/1/2018 1:04:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





-- =============================================
-- Author:		tungle
-- Create date: 13/1/2016
-- Description:	<Description,,>
-- =============================================
-- exec [sp_InsertOrderProduct]

CREATE PROCEDURE [dbo].[sp_InsertOrderProduct]
    @OrderId BIGINT,
	@OrderType INT=0,
	@ProductId INT,
	@MaterialId INT,
	@LocationId INT,
	@ColorId INT,
	@ControlSideId INT,
	@UnitId INT, 
	@Drop INT,
	@Width INT,
	@Quantity INT,
	@Discount INT,
	@ExtendPrice DECIMAL(18,2),
	@UnitPrice DECIMAL(18,2),
	@TotalAmount DECIMAL(18,2),
	@DeliveryNo NVARCHAR(250),
	@DeliveryDate DATETIME,
	@Received INT,
	@BackOrder INT,
	@Step INT,	
	@AMTExcGST DECIMAL(18,2),
	@GST DECIMAL(18,2),
	@AMTIncGST DECIMAL(18,2),
	@ReceivedAMTExcGST DECIMAL(18,2),
	@ReceivedGST DECIMAL(18,2),
	@ReceivedAMTIncGST DECIMAL(18,2)
AS
BEGIN	
	INSERT OrderProduct(
		OrderId,
		ProductId,
		MaterialId,
		LocationId,
		ColorId,
		ControlSideId,
		UnitId,
		[Drop],
		Width,
		Quantity,
		Discount,
		ExtendPrice,
		UnitPrice,
		TotalAmount,
		DeliveryNo,
		DeliveryDate,
		Received,
		BackOrder,
		Step,
		AMTExcGST,
		GST,
		AMTIncGST,
		ReceivedAMTExcGST,
		ReceivedGST,
		ReceivedAMTIncGST,
		CreateDTS)
	SELECT 
        @OrderId,
		@ProductId,
		@MaterialId,
		@LocationId,
		@ColorId,
		@ControlSideId,
		@UnitId,
		@Drop,
		@Width,
		@Quantity,
		@Discount,
		@ExtendPrice,
		@UnitPrice,
		@TotalAmount,
		@DeliveryNo,
		@DeliveryDate,
		@Received,
		@BackOrder,
		@Step,
		@AMTExcGST,
		@GST,
		@AMTIncGST,
		@ReceivedAMTExcGST,
		@ReceivedGST,
		@ReceivedAMTIncGST,
        GETDATE()
    
END





GO
/****** Object:  StoredProcedure [dbo].[sp_InsertProduct]    Script Date: 7/1/2018 1:04:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





-- =============================================
-- Author:		tungle
-- Create date: 13/1/2016
-- Description:	<Description,,>
-- =============================================
-- exec [sp_InsertProduct]

CREATE PROCEDURE [dbo].[sp_InsertProduct]
    @ProductCode NVARCHAR(250),
    @ProductName NVARCHAR(250),
    @CategoryId INT,
    @Notes  NVARCHAR(MAX),
    @ActiveStatus INT
AS
BEGIN	
	INSERT Product(
		ProductCode,
		ProductName,
		CategoryId,
		Notes,
		ActiveStatus,
        CreateDTS)
	SELECT 
        @ProductCode,
		@ProductName,
		@CategoryId,
		@Notes,
		@ActiveStatus,
        GETDATE()
    
END





GO
/****** Object:  StoredProcedure [dbo].[sp_InsertProductComponent]    Script Date: 7/1/2018 1:04:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





-- =============================================
-- Author:		tungle
-- Create date: 13/1/2016
-- Description:	<Description,,>
-- =============================================
-- exec [sp_InsertProductComponent]

CREATE PROCEDURE [dbo].[sp_InsertProductComponent]
    @ProductId INT,
    @ComponentId INT,
    @ColorId INT,
    @Quantity INT,
    @Price DECIMAL(18,2),
    @ExtCharge BIT
AS
BEGIN	
	INSERT ProductComponent(
		ProductId,
		ComponentId,
		ColorId,
		Quantity,
		Price,
		ExtCharge,
        CreateDTS)
	SELECT 
        @ProductId,
		@ComponentId,
		@ColorId,
		@Quantity,
		@Price,
		@ExtCharge,
        GETDATE()
    
END





GO
/****** Object:  StoredProcedure [dbo].[sp_InsertProductMaterial]    Script Date: 7/1/2018 1:04:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





-- =============================================
-- Author:		tungle
-- Create date: 13/1/2016
-- Description:	<Description,,>
-- =============================================
-- exec [sp_InsertProductMaterial]

CREATE PROCEDURE [dbo].[sp_InsertProductMaterial]
    @ProductId INT,
    @MaterialId INT
AS
BEGIN	
	INSERT ProductMaterial(
		ProductId,
		MaterialId,
        CreateDTS)
	SELECT 
        @ProductId,
		@MaterialId,
        GETDATE()
    
END





GO
/****** Object:  StoredProcedure [dbo].[sp_InsertSupplier]    Script Date: 7/1/2018 1:04:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





-- =============================================
-- Author:		tungle
-- Create date: 13/1/2016
-- Description:	<Description,,>
-- =============================================
-- exec [sp_InsertSupplier]

CREATE PROCEDURE [dbo].[sp_InsertSupplier]
    @FirstName NVARCHAR(250),
    @LastName NVARCHAR(250),
    @Company NVARCHAR(250),
    @Email NVARCHAR(250),
    @JobTitle NVARCHAR(250),
    @WebPage NVARCHAR(250),
    @Notes NVARCHAR(max),
    @Address NVARCHAR(500),
    @ZipCode NVARCHAR(250),
    @City NVARCHAR(250),
    @State NVARCHAR(250),
    @Country NVARCHAR(250),
    @BusinessPhone NVARCHAR(250),
    @MobilePhone NVARCHAR(250),
    @HomePhone NVARCHAR(250),
    @Fax NVARCHAR(250)
AS
BEGIN	
	INSERT Supplier(
		FirstName,
        LastName,
        Company,
        Email,
        JobTitle,
        WebPage,
        Notes,
        Address,
        ZipCode,
        City,
        State,
        Country,
        BusinessPhone,
        MobilePhone,
        HomePhone,
        Fax,
        CreateDTS)
	SELECT 
        @FirstName,
        @LastName,
        @Company,
        @Email,
        @JobTitle,
        @WebPage,
        @Notes,
        @Address,
        @ZipCode,
        @City,
        @State,
        @Country,
        @BusinessPhone,
        @MobilePhone,
        @HomePhone,
        @Fax,
        GETDATE()
    
END





GO
/****** Object:  StoredProcedure [dbo].[sp_UpdateComponent]    Script Date: 7/1/2018 1:04:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





-- =============================================
-- Author:		tungle
-- Create date: 13/1/2016
-- Description:	<Description,,>
-- =============================================
-- exec [sp_UpdateSupplier]

CREATE PROCEDURE [dbo].[sp_UpdateComponent]
	@Id INT,
    @ComponentCode NVARCHAR(250),
    @ComponentName NVARCHAR(250),
    @SupplierId INT,
    @Price DECIMAL(18,2),
    @Color NVARCHAR(250),
    @Unit NVARCHAR(250),
    @Description  NVARCHAR(MAX),
    @ActiveStatus INT
AS
BEGIN	
	UPDATE Component
	SET ComponentCode=@ComponentCode,
        ComponentName=@ComponentName,
        SupplierId=@SupplierId,
        Price=@Price,
        Color=@Color,
        Unit=@Unit,
        Description=@Description,
        ActiveStatus=@ActiveStatus,
        UpdateDTS= GETDATE()
    WHERE Id=@Id
    
END





GO
/****** Object:  StoredProcedure [dbo].[sp_UpdateMaterial]    Script Date: 7/1/2018 1:04:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





-- =============================================
-- Author:		tungle
-- Create date: 13/1/2016
-- Description:	<Description,,>
-- =============================================
-- exec [sp_UpdateMaterial]

CREATE PROCEDURE [dbo].[sp_UpdateMaterial]
	@Id INT,
    @MaterialName NVARCHAR(250),
    @SupplierId INT,
    @Price DECIMAL(18,2),
    @Description NVARCHAR(MAX), 
    @ActiveStatus INT
AS
BEGIN	
	UPDATE Material
	SET MaterialName=@MaterialName,
        SupplierId=@SupplierId,
        Price=@Price,
        Description=@Description,                                    
        ActiveStatus=@ActiveStatus,
        UpdateDTS= GETDATE()
    WHERE Id=@Id
    
END





GO
/****** Object:  StoredProcedure [dbo].[sp_UpdateOrder]    Script Date: 7/1/2018 1:04:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





-- =============================================
-- Author:		tungle
-- Create date: 13/1/2016
-- Description:	<Description,,>
-- =============================================
-- exec [sp_UpdateOrder]

CREATE PROCEDURE [dbo].[sp_UpdateOrder]
	@Id BIGINT,
    @EmployeeId INT,
    @EmployeeName NVARCHAR(250),
    @Step VARCHAR(50),
    @Taxes DECIMAL(18,2),
    @Surcharge DECIMAL(18,2),
    @Discount DECIMAL(18,2),
    @OrderDate DateTime,
    @FirtReceiveDate DateTime,
    @LastUpdate DateTime,
    @DeliveryDate DateTime,
    @Notes NVARCHAR(MAX),
    @SupplierId INT,
    @SupplierName NVARCHAR(500),
    @SupplierAddress NVARCHAR(500),
    @SupplierEmail NVARCHAR(250),
    @SupplierPhone NVARCHAR(250),
    @OrderRefNo NVARCHAR(250),
    @OrderType INT,
    @ActiveStatus INT
AS
BEGIN	
	UPDATE [Order]
	SET EmployeeId=@EmployeeId,
		EmployeeName =@EmployeeName,
		Step=@Step,
		Taxes=@Taxes,
        Surcharge=@Surcharge,
        Discount=@Discount,
        OrderDate=@OrderDate,
        FirtReceiveDate=@FirtReceiveDate,
        LastUpdate=@LastUpdate,
        DeliveryDate=@DeliveryDate,
        Notes=@Notes,
        SupplierId=@SupplierId,
        SupplierName=@SupplierName,
        SupplierAddress=@SupplierAddress,
        SupplierEmail=@SupplierEmail,
        SupplierPhone=@SupplierPhone,
        OrderRefNo=@OrderRefNo,
        @OrderType=@OrderType,
        ActiveStatus=@ActiveStatus,
        UpdateDts=GETDATE()
    WHERE Id=@Id
    
END





GO
/****** Object:  StoredProcedure [dbo].[sp_UpdateOrderComponent]    Script Date: 7/1/2018 1:04:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





-- =============================================
-- Author:		tungle
-- Create date: 13/1/2016
-- Description:	<Description,,>
-- =============================================
-- exec [sp_UpdateOrderComponent]

CREATE PROCEDURE [dbo].[sp_UpdateOrderComponent]
	@Id INT,
	@OrderType INT=1,
    @OrderId BIGINT,
    @ComponentId INT,
    @ColorId INT,
    @Quantity INT,
    @Price DECIMAL(18,2),
    @ExtCharge BIT,
	@UnitId INT,
	@Step INT,
	@TotalAmount DECIMAL(18,2),
	@DeliveryNo NVARCHAR(250),
	@DeliveryDate DATETIME,
	@Received INT,
	@BackOrder INT,
	@AMTExcGST DECIMAL(18,2),
	@GST DECIMAL(18,2),
	@AMTIncGST DECIMAL(18,2),
	@ReceivedAMTExcGST DECIMAL(18,2),
	@ReceivedGST DECIMAL(18,2),
	@ReceivedAMTIncGST DECIMAL(18,2)
AS
BEGIN	
	UPDATE OrderComponent
	SET
        OrderId=@OrderId,
		ComponentId=@ComponentId,
		ColorId=@ColorId,
		Quantity=@Quantity,
		Price=@Price,
		ExtCharge=@ExtCharge,
		UnitId=@UnitId,
		Step=@Step,		
		TotalAmount = @TotalAmount,
		DeliveryNo = @DeliveryNo,
		DeliveryDate = @DeliveryDate,
		Received = @Received ,
		BackOrder = @BackOrder,
		AMTExcGST=@AMTExcGST,
		GST=@GST,
		AMTIncGST=@AMTIncGST,
		ReceivedAMTExcGST=@ReceivedAMTExcGST,
		ReceivedGST=@ReceivedGST,
		ReceivedAMTIncGST=@ReceivedAMTIncGST,
        UpdateDTS= GETDATE()
    WHERE
		Id = @Id
    
END





GO
/****** Object:  StoredProcedure [dbo].[sp_UpdateOrderInvoice]    Script Date: 7/1/2018 1:04:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





-- =============================================
-- Author:		tungle
-- Create date: 13/1/2016
-- Description:	<Description,,>
-- =============================================
-- exec [sp_UpdateOrderPayment]

CREATE PROCEDURE [dbo].[sp_UpdateOrderInvoice]
	@Id INT,
	@OrderId BIGINT,
	@OrderType INT=1,
	@InvoiceNo NVARCHAR(250),
    @InvoiceAmount DECIMAL(18,2),
    @CutLengthCharge NVARCHAR(250),
	@DeliveryCharge NVARCHAR(250),
	@ActiveStatus INT
AS
BEGIN	
	UPDATE OrderInvoice
	SET
        OrderId=@OrderId,
		InvoiceNo=@InvoiceNo,
		InvoiceAmount=@InvoiceAmount,
		CutLengthCharge=@CutLengthCharge,
		DeliveryCharge=@DeliveryCharge,
        UpdateDTS= GETDATE()
    WHERE
		Id = @Id
    
END





GO
/****** Object:  StoredProcedure [dbo].[sp_UpdateOrderPayment]    Script Date: 7/1/2018 1:04:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





-- =============================================
-- Author:		tungle
-- Create date: 13/1/2016
-- Description:	<Description,,>
-- =============================================
-- exec [sp_UpdateOrderPayment]

CREATE PROCEDURE [dbo].[sp_UpdateOrderPayment]
	@Id INT,
	@OrderId BIGINT,
	@OrderType INT=1,
    @AmountPaid DECIMAL(18,2),
    @PaymentType NVARCHAR(250),	
	@ActiveStatus INT
AS
BEGIN	
	UPDATE OrderPayment
	SET
        OrderId=@OrderId,
		AmountPaid=@AmountPaid,
		PaymentType=@PaymentType,
        UpdateDTS= GETDATE()
    WHERE
		Id = @Id
    
END





GO
/****** Object:  StoredProcedure [dbo].[sp_UpdateOrderProduct]    Script Date: 7/1/2018 1:04:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





-- =============================================
-- Author:		tungle
-- Create date: 13/1/2016
-- Description:	<Description,,>
-- =============================================
-- exec [sp_UpdateOrderProduct]

CREATE PROCEDURE [dbo].[sp_UpdateOrderProduct]
	@Id INT,
	@OrderId BIGINT,
	@OrderType INT=0,
	@ProductId INT,
	@MaterialId INT,
	@LocationId INT,
	@ColorId INT,
	@ControlSideId INT,
	@UnitId INT, 
	@Drop INT,
	@Width INT,
	@Quantity INT,
	@Discount INT,
	@ExtendPrice DECIMAL(18,2),
	@UnitPrice DECIMAL(18,2),
	@TotalAmount DECIMAL(18,2),
	@DeliveryNo NVARCHAR(250),
	@DeliveryDate DATETIME,
	@Received INT,
	@BackOrder INT,
	@Step INT,
	@AMTExcGST DECIMAL(18,2),
	@GST DECIMAL(18,2),
	@AMTIncGST DECIMAL(18,2),
	@ReceivedAMTExcGST DECIMAL(18,2),
	@ReceivedGST DECIMAL(18,2),
	@ReceivedAMTIncGST DECIMAL(18,2)
AS
BEGIN	
	UPDATE OrderProduct
	SET
        OrderId =@OrderId,
		ProductId = @ProductId,
		MaterialId = @MaterialId,
		LocationId = @LocationId,
		ColorId = @ColorId,
		ControlSideId = @ControlSideId ,
		UnitId = @UnitId ,
		[Drop] = @Drop ,
		Width = @Width ,
		Quantity = @Quantity ,
		Discount = @Discount,
		ExtendPrice = @ExtendPrice,
		UnitPrice = @UnitPrice ,
		TotalAmount = @TotalAmount,
		DeliveryNo = @DeliveryNo,
		DeliveryDate = @DeliveryDate,
		Received = @Received ,
		BackOrder = @BackOrder,
		Step=@Step,		
		AMTExcGST=@AMTExcGST,
		GST=@GST,
		AMTIncGST=@AMTIncGST,
		ReceivedAMTExcGST=@ReceivedAMTExcGST,
		ReceivedGST=@ReceivedGST,
		ReceivedAMTIncGST=@ReceivedAMTIncGST,
        UpdateDTS= GETDATE()
    WHERE
		Id = @Id
    
END





GO
/****** Object:  StoredProcedure [dbo].[sp_UpdateProduct]    Script Date: 7/1/2018 1:04:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





-- =============================================
-- Author:		tungle
-- Create date: 13/1/2016
-- Description:	<Description,,>
-- =============================================
-- exec [sp_UpdateProduct]

CREATE PROCEDURE [dbo].[sp_UpdateProduct]
	@Id INT,
    @ProductCode NVARCHAR(250),
    @ProductName NVARCHAR(250),
    @CategoryId INT,
    @Notes  NVARCHAR(MAX),
    @ActiveStatus INT
AS
BEGIN	
	UPDATE Product
	SET ProductCode=@ProductCode,
        ProductName=@ProductName,
        CategoryId=@CategoryId,
        Notes=@Notes,
        ActiveStatus=@ActiveStatus,
        UpdateDTS= GETDATE()
    WHERE Id=@Id
    
END





GO
/****** Object:  StoredProcedure [dbo].[sp_UpdateProductComponent]    Script Date: 7/1/2018 1:04:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





-- =============================================
-- Author:		tungle
-- Create date: 13/1/2016
-- Description:	<Description,,>
-- =============================================
-- exec [sp_UpdateProductComponent]

CREATE PROCEDURE [dbo].[sp_UpdateProductComponent]
	@Id INT,
    @ProductId INT,
    @ComponentId INT,
    @ColorId INT,
    @Quantity INT,
    @Price DECIMAL(18,2),
    @ExtCharge BIT
AS
BEGIN	
	UPDATE ProductComponent
	SET
        ProductId=@ProductId,
		ComponentId=@ComponentId,
		ColorId=@ColorId,
		Quantity=@Quantity,
		Price=@Price,
		ExtCharge=@ExtCharge,
        UpdateDTS= GETDATE()
    WHERE
		Id = @Id
    
END





GO
/****** Object:  StoredProcedure [dbo].[sp_UpdateProductMaterialPrice]    Script Date: 7/1/2018 1:04:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





-- =============================================
-- Author:		tungle
-- Create date: 13/1/2016
-- Description:	<Description,,>
-- =============================================
-- exec [sp_UpdateProductPrice]

CREATE PROCEDURE [dbo].[sp_UpdateProductMaterialPrice]
	@ProductMaterialId INT,
    @Xml XML
AS
BEGIN	
	IF OBJECT_ID('tempdb..#XMLColumns') IS NOT NULL
	DROP TABLE #XMLColumns

	SELECT x.value('Row[1]', 'INT') AS Row
	,x.value('Column[1]', 'INT') AS [Column]
	,x.value('Value[1]', 'NVARCHAR(50)') AS Value
	INTO #XMLColumns
	FROM @Xml.nodes('/ArrayOfProductPrice/ProductPrice') TempXML (x)
	
    DELETE ProductPrice
	WHERE ProductMaterialId=@ProductMaterialId

	INSERT INTO ProductPrice(ProductMaterialId,Row,[Column],Value,UpdateDTS,CreateDTS)
	select @ProductMaterialId,Row,[Column],Value,GETDATE(),GETDATE() from #XMLColumns
END



GO
/****** Object:  StoredProcedure [dbo].[sp_UpdateSupplier]    Script Date: 7/1/2018 1:04:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





-- =============================================
-- Author:		tungle
-- Create date: 13/1/2016
-- Description:	<Description,,>
-- =============================================
-- exec [sp_UpdateSupplier]

CREATE PROCEDURE [dbo].[sp_UpdateSupplier]
	@Id INT,
    @FirstName NVARCHAR(250),
    @LastName NVARCHAR(250),
    @Company NVARCHAR(250),
    @Email NVARCHAR(250),
    @JobTitle NVARCHAR(250),
    @WebPage NVARCHAR(250),
    @Notes NVARCHAR(max),
    @Address NVARCHAR(500),
    @ZipCode NVARCHAR(250),
    @City NVARCHAR(250),
    @State NVARCHAR(250),
    @Country NVARCHAR(250),
    @BusinessPhone NVARCHAR(250),
    @MobilePhone NVARCHAR(250),
    @HomePhone NVARCHAR(250),
    @Fax NVARCHAR(250)
AS
BEGIN	
	UPDATE Supplier
	SET 
        FirstName=@FirstName,
        LastName=@LastName,
        Company=@Company,
        Email=@Email,
        JobTitle=@JobTitle,
        WebPage=@WebPage,
        Notes=@Notes,
        Address=@Address,
        ZipCode=@ZipCode,
        City=@City,
        State=@State,
        Country=@Country,
        BusinessPhone=@BusinessPhone,
        MobilePhone=@MobilePhone,
        HomePhone=@HomePhone,
        Fax=@Fax,
        UpdateDTS= GETDATE()
    WHERE Id=@Id
    
END





GO
USE [master]
GO
ALTER DATABASE [BWC] SET  READ_WRITE 
GO
